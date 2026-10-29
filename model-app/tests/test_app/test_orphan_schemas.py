"""Orphan schemas (`services/orphan_schemas.py`, `listOrphanSchemas`, `dropOrphanSchemas`).

The workspace is a MagicMock answered by :class:`_FakeUc`: per catalog, the
schemas with their owners, the tables in them, and the agent's
``_metamodel.domain`` rows. It parses every statement the app sends (the
registry read, the ``information_schema`` listing, the data check, ``DROP
SCHEMA`` and the registry cleanup) and answers from that state, so each
statement is checked for shape and quoting.

Registry rows carry what agent 5.3.3 writes (``_metamodel_registry_records``,
nb 53559-53560): ``business`` is the title-cased segment, ``database_name`` the
prefixed name (``ecm_intake``, ``mvm_ecm_intake``, as in the P0 model.json
files), ``catalog`` the install catalog. Unless a test says otherwise the
registry's business row carries session 0, as the app's import writes it
(``services/import_metamodel_writer.py``) for a version it later deleted. A
real version delete also deletes the runs whose only output it was, so a
deleted run's own session id is unknown to the app.
"""
from __future__ import annotations

import json
import re
from datetime import datetime, timezone
from types import SimpleNamespace
from unittest.mock import MagicMock

import pytest
from sqlmodel import Session, select

import vibe_modeling.backend.core._roles as _roles_mod
from vibe_modeling.backend.db_models import (
    AgentConfig,
    Business,
    Domain,
    MetamodelCleanup,
    ModelVersion,
    ModelVersionInstall,
    Run,
    RunOperation,
    RunSchemaDrop,
)
from vibe_modeling.backend.core._ids import session_id_to_bigint
from vibe_modeling.backend.services import orphan_schemas as orph
from vibe_modeling.backend.services import uninstall_impact as ui

from _assess_helpers import changed_tables, table_digests
from _sql_fakes import response

HOME, OTHER, THIRD = "home_cat", "other_cat", "third_cat"
APP_SP = "app-sp-0000"
# The session an app run used: the BIGINT of its Run's vibe_session_id.
APP_RUN_SESSION = "8f1d3c2e-5b4a-4c1e-9d7f-0a1b2c3d4e5f"
APP_SESSION = str(session_id_to_bigint(APP_RUN_SESSION))
IMPORT_SESSION = "0"
OOB_SESSION = "296524668168293394"

_CHECK_RE = re.compile(
    r"SELECT (\d+) AS i, \(SELECT COUNT\(\*\) FROM \(SELECT 1 FROM "
    r"`([a-z0-9_]+)`\.`([a-z0-9_]+)`\.`([a-z0-9_]+)` LIMIT 1\)\) AS n"
)
_DROP_RE = re.compile(r"^DROP SCHEMA `([a-z0-9_]+)`\.`([a-z0-9_]+)` CASCADE$")
_REGISTRY_RE = re.compile(r"FROM `([a-z0-9_]+)`\.`_metamodel`\.`domain` LIMIT \d+$")
_BUSINESS_RE = re.compile(r"FROM `([a-z0-9_]+)`\.`_metamodel`\.`business` LIMIT \d+$")
_KEY_RE = re.compile(r"LOWER\(business\) = LOWER\('([^']*)'\) AND version = '(\d+)' AND model_scope = '(\w+)'")


class _FakeUc:
    def __init__(self) -> None:
        self.schemas: dict[str, dict[str, str]] = {}
        self.tables: dict[tuple[str, str], list[tuple[str, int]]] = {}
        self.registry: dict[str, list[list]] = {}
        self.business_rows: dict[str, list[list]] = {}
        self.statements: list[str] = []
        self.drops: list[tuple[str, str]] = []
        self.fail_drop: set[str] = set()
        self.error_but_dropped: set[str] = set()
        self.registry_error = False
        self.list_calls = 0
        self.on_list = None

    def schema(self, catalog: str, name: str, owner: str = APP_SP, tables=()) -> "_FakeUc":
        self.schemas.setdefault(catalog, {})[name] = owner
        self.tables[(catalog, name)] = list(tables)
        return self

    def domain(self, catalog: str, business: str, version: int, scope: str, database_name: str,
               domain_catalog: str | None = None, session_id: str | None = IMPORT_SESSION) -> "_FakeUc":
        """A domain row, and the version's business row with ``session_id``
        (None: no business row)."""
        self.registry.setdefault(catalog, []).append(
            [business, str(version), scope, database_name, catalog if domain_catalog is None else domain_catalog]
        )
        rows = self.business_rows.setdefault(catalog, [])
        if session_id is not None and not any(r[:3] == [business, str(version), scope] for r in rows):
            rows.append([business, str(version), scope, session_id])
        return self

    def install(self, ws: MagicMock) -> MagicMock:
        def _list(catalog_name, **_kw):
            self.list_calls += 1
            if self.on_list is not None:
                self.on_list(self, self.list_calls)
            if catalog_name not in self.schemas:
                raise RuntimeError("CATALOG_DOES_NOT_EXIST")
            return iter(SimpleNamespace(name=n, owner=o) for n, o in sorted(self.schemas[catalog_name].items()))

        ws.schemas.list.side_effect = _list
        ws.statement_execution.execute_statement.side_effect = self._execute
        return ws

    def _execute(self, *, statement, warehouse_id, parameters=None, **_kw):
        assert warehouse_id
        self.statements.append(statement)
        params = {p.name: p.value for p in (parameters or [])}
        registry = _REGISTRY_RE.search(statement)
        if registry:
            if self.registry_error:
                return response(error="[INSUFFICIENT_PERMISSIONS] no SELECT on domain")
            cat = registry.group(1)
            if cat not in self.registry:
                return response(error="[TABLE_OR_VIEW_NOT_FOUND] _metamodel.domain")
            return response(self.registry[cat], columns=["business", "version", "model_scope", "database_name", "catalog"])
        business = _BUSINESS_RE.search(statement)
        if business:
            if self.registry_error:
                return response(error="[INSUFFICIENT_PERMISSIONS] no SELECT on business")
            cat = business.group(1)
            if cat not in self.registry:
                return response(error="[TABLE_OR_VIEW_NOT_FOUND] _metamodel.business")
            return response(self.business_rows.get(cat, []), columns=["business", "version", "model_scope", "session_id"])
        if "information_schema" in statement:
            cat = re.search(r"FROM `([a-z0-9_]+)`\.information_schema\.tables", statement).group(1)
            out = [
                [schema, table, "MANAGED"]
                for schema in sorted(set(params.values()))
                for table, _rows in self.tables.get((cat, schema), [])
            ]
            return response(out, columns=["table_schema", "table_name", "table_type"])
        found = _CHECK_RE.findall(statement)
        if found:
            rows = {(c, s, t): r for (c, s), ts in self.tables.items() for t, r in ts}
            return response(
                [[i, "1" if rows.get((c, s, t), 0) else "0"] for i, c, s, t in found], columns=["i", "n"],
            )
        drop = _DROP_RE.match(statement)
        if drop:
            cat, name = drop.groups()
            self.drops.append((cat, name))
            if name in self.fail_drop:
                return response(error="[PERMISSION_DENIED] cannot drop")
            self.schemas[cat].pop(name, None)
            if name in self.error_but_dropped:
                return response(error="[INTERNAL_ERROR] connection reset")
            return response([])
        if statement.startswith("SELECT COUNT(*) AS n FROM"):
            return response([["1"]], columns=["n"])
        if statement.startswith("DELETE FROM"):
            cat = re.search(r"FROM `([a-z0-9_]+)`\.`_metamodel`", statement).group(1)
            business, version, scope = _KEY_RE.search(statement).groups()
            self.registry[cat] = [
                r for r in self.registry.get(cat, [])
                if not (r[0].lower() == business.lower() and r[1] == version and r[2] == scope)
            ]
            return response([])
        raise AssertionError(f"unexpected statement: {statement}")


@pytest.fixture(autouse=True)
def _clean(monkeypatch):
    ui.IMPACT_CACHE.clear()
    ui.SCAN_LIMITER.clear()
    monkeypatch.setattr(orph, "app_application_id", lambda _ws: APP_SP)
    yield
    ui.IMPACT_CACHE.clear()
    ui.SCAN_LIMITER.clear()


def _config(engine, catalog=HOME):
    with Session(engine) as s:
        s.add(AgentConfig(deployment_catalog=catalog, warehouse_id="wh-1"))
        s.commit()


def _business(engine, name="Grain Coop") -> str:
    with Session(engine) as s:
        b = Business(name=name, description="t")
        s.add(b)
        s.commit()
        return b.id


def _app_run(engine, bid):
    """A run of the business that still exists, with :data:`APP_RUN_SESSION`."""
    with Session(engine) as s:
        s.add(Run(business_id=bid, intent="new-base-model", status="completed", vibe_session_id=APP_RUN_SESSION))
        s.commit()


def _open_cleanup(engine, version, scope="ecm", status="failed") -> str:
    with Session(engine) as s:
        row = MetamodelCleanup(business_segment="grain_coop", version=version, scope=scope, catalog=HOME,
                               reason="version_delete", status=status, attempts=3)
        s.add(row)
        s.commit()
        return row.id


def _version(engine, bid, version, scope="ecm", domains=("ecm_intake",), installed_in=()) -> str:
    with Session(engine) as s:
        mv = ModelVersion(
            business_id=bid, version=version, scope=scope, status="completed",
            deployment_status="deployed" if installed_in else "draft",
            uc_catalog=installed_in[0] if installed_in else "",
        )
        s.add(mv)
        s.flush()
        for d in domains:
            s.add(Domain(version_id=mv.id, name=d, database_name=d))
        for n, catalog in enumerate(installed_in):
            s.add(ModelVersionInstall(
                version_id=mv.id, catalog=catalog,
                installed_at=datetime(2026, 10, 1 + n, tzinfo=timezone.utc),
            ))
        s.commit()
        return mv.id


def _discover(engine, ws, bid, catalog):
    with Session(engine) as s:
        b = s.get(Business, bid)
        return orph.discover_orphans(s, ws, b, catalog, orph.read_registry(ws, "wh-1", catalog))


def _names(discovery):
    return {(s.name, s.match, s.owned_by_app) for s in discovery.schemas}


class TestDiscovery:
    def test_registry_only_business_with_no_versions(self, engine):
        bid = _business(engine)
        uc = (
            _FakeUc()
            .schema(HOME, "ecm_intake").schema(HOME, "ecm_sales").schema(HOME, "_metamodel")
            .domain(HOME, "Grain_Coop", 1, "ecm", "ecm_intake")
            .domain(HOME, "Grain_Coop", 1, "ecm", "ecm_sales")
        )
        d = _discover(engine, uc.install(MagicMock()), bid, HOME)
        assert _names(d) == {("ecm_intake", "exact", True), ("ecm_sales", "exact", True)}
        assert d.key_names == {(1, "ecm"): {"ecm_intake", "ecm_sales"}}

    def test_logical_registry_name_matches_the_prefixed_schema_as_inferred(self, engine):
        # Synthetic: an older agent stored the logical name ("party") in database_name.
        bid = _business(engine)
        uc = _FakeUc().schema(HOME, "ecm_party").domain(HOME, "Grain_Coop", 2, "ecm", "party")
        d = _discover(engine, uc.install(MagicMock()), bid, HOME)
        assert _names(d) == {("ecm_party", "inferred", True)}

    def test_mvm_names_as_5_3_3_stores_them(self, engine):
        bid = _business(engine)
        uc = _FakeUc().schema(HOME, "mvm_ecm_intake").domain(HOME, "Grain_Coop", 3, "mvm", "mvm_ecm_intake")
        d = _discover(engine, uc.install(MagicMock()), bid, HOME)
        assert _names(d) == {("mvm_ecm_intake", "exact", True)}

    def test_schemas_of_another_business_are_never_orphans(self, engine):
        bid = _business(engine)
        acme = _business(engine, "Acme Co")
        _version(engine, acme, 1, domains=("ecm_storage",))
        uc = (
            _FakeUc()
            .schema(HOME, "ecm_intake").schema(HOME, "ecm_sales").schema(HOME, "ecm_storage")
            .domain(HOME, "Grain_Coop", 1, "ecm", "ecm_intake")
            .domain(HOME, "Grain_Coop", 1, "ecm", "ecm_sales")
            .domain(HOME, "Grain_Coop", 1, "ecm", "ecm_storage")
            .domain(HOME, "Acme_Co", 4, "ecm", "ecm_sales")
        )
        d = _discover(engine, uc.install(MagicMock()), bid, HOME)
        assert {s.name for s in d.schemas} == {"ecm_intake"}
        assert d.key_names == {(1, "ecm"): {"ecm_intake"}}

    def test_a_prefixed_form_of_another_business_version_is_claimed(self, engine):
        bid = _business(engine)
        acme = _business(engine, "Acme Co")
        _version(engine, acme, 1, domains=("storage",))
        uc = (
            _FakeUc().schema(HOME, "ecm_storage").schema(HOME, "ecm_intake")
            .domain(HOME, "Grain_Coop", 1, "ecm", "ecm_storage")
            .domain(HOME, "Grain_Coop", 1, "ecm", "ecm_intake")
        )
        d = _discover(engine, uc.install(MagicMock()), bid, HOME)
        assert {s.name for s in d.schemas} == {"ecm_intake"}

    def test_schemas_an_installed_version_uses_are_never_orphans(self, engine):
        bid = _business(engine)
        _version(engine, bid, 2, domains=("ecm_intake",), installed_in=(HOME,))
        uc = (
            _FakeUc()
            .schema(HOME, "ecm_intake").schema(HOME, "ecm_sales")
            .domain(HOME, "Grain_Coop", 1, "ecm", "ecm_intake")
            .domain(HOME, "Grain_Coop", 1, "ecm", "ecm_sales")
            .domain(HOME, "Grain_Coop", 2, "ecm", "ecm_intake")
        )
        d = _discover(engine, uc.install(MagicMock()), bid, HOME)
        assert {s.name for s in d.schemas} == {"ecm_sales"}
        assert d.key_names == {(1, "ecm"): {"ecm_sales"}}

    def test_a_known_version_not_installed_here_is_exact_and_keeps_its_registry_rows(self, engine):
        bid = _business(engine)
        _version(engine, bid, 3, domains=("ecm_intake",))
        uc = _FakeUc().schema(HOME, "ecm_intake").domain(HOME, "Grain_Coop", 3, "ecm", "ecm_intake")
        d = _discover(engine, uc.install(MagicMock()), bid, HOME)
        assert _names(d) == {("ecm_intake", "exact", True)}
        assert d.key_names == {}

    def test_a_failed_install_leaves_orphans_only_in_the_catalog_it_targeted(self, engine):
        """E-12: v3's ``mvm_`` install into OTHER failed after the agent made
        some schemas. They are orphan candidates in OTHER; in HOME the version
        holds the names it stores, so another business's ``mvm_intake`` there
        is not offered."""
        bid = _business(engine)
        vid = _version(engine, bid, 3, scope="mvm", domains=("intake",))
        with Session(engine) as s:
            run = Run(business_id=bid, intent="install", status="failed")
            s.add(run)
            s.flush()
            s.add(RunOperation(
                run_id=run.id, step_index=0, operation_name="install", status="failed", parent_version_id=vid,
                dispatched_widgets_json=json.dumps({"deployment_catalog": OTHER, "schema_prefix": "mvm_"}),
            ))
            s.commit()
        uc = _FakeUc()
        for cat in (HOME, OTHER, THIRD):
            uc.schema(cat, "intake").schema(cat, "mvm_intake").schema(cat, "mvm_sales")
        ws = uc.install(MagicMock())
        assert _names(_discover(engine, ws, bid, HOME)) == {("intake", "exact", True)}
        assert _names(_discover(engine, ws, bid, OTHER)) == {("intake", "exact", True), ("mvm_intake", "exact", True)}
        assert _names(_discover(engine, ws, bid, THIRD)) == {("intake", "exact", True)}

    def test_a_schema_the_app_does_not_own_is_listed_not_droppable(self, engine):
        bid = _business(engine)
        uc = (
            _FakeUc().schema(HOME, "ecm_intake", owner="someone@example.com")
            .domain(HOME, "Grain_Coop", 1, "ecm", "ecm_intake")
        )
        d = _discover(engine, uc.install(MagicMock()), bid, HOME)
        (schema,) = d.schemas
        assert (schema.owner, schema.owned_by_app) == ("someone@example.com", False)
        assert d.droppable() == set()

    def test_three_catalogs_and_a_version_installed_in_two(self, engine):
        bid = _business(engine)
        _version(engine, bid, 2, domains=("ecm_intake",), installed_in=(HOME, OTHER))
        uc = _FakeUc()
        for cat in (HOME, OTHER, THIRD):
            uc.schema(cat, "ecm_intake").schema(cat, "ecm_sales")
            uc.domain(cat, "Grain_Coop", 1, "ecm", "ecm_intake").domain(cat, "Grain_Coop", 1, "ecm", "ecm_sales")
        uc.domain(THIRD, "Grain_Coop", 1, "ecm", "ecm_billing", domain_catalog=HOME)
        uc.schema(THIRD, "ecm_billing")
        ws = uc.install(MagicMock())

        assert {s.name for s in _discover(engine, ws, bid, HOME).schemas} == {"ecm_sales"}
        assert {s.name for s in _discover(engine, ws, bid, OTHER).schemas} == {"ecm_sales"}
        third = _discover(engine, ws, bid, THIRD)
        assert {s.name for s in third.schemas} == {"ecm_intake", "ecm_sales"}
        assert third.key_names == {(1, "ecm"): {"ecm_intake", "ecm_sales"}}
        assert third.keep_registry == {(1, "ecm")}
        assert _discover(engine, ws, bid, HOME).keep_registry == set()

    def test_a_version_made_outside_the_app_is_listed_but_not_droppable(self, engine):
        bid = _business(engine)
        uc = (
            _FakeUc().schema(HOME, "ecm_intake").schema(HOME, "ecm_sales")
            .domain(HOME, "Grain_Coop", 1, "ecm", "ecm_intake")
            .domain(HOME, "Grain_Coop", 4, "ecm", "ecm_sales", session_id=OOB_SESSION)
        )
        d = _discover(engine, uc.install(MagicMock()), bid, HOME)
        by_name = {x.name: x for x in d.schemas}
        assert by_name["ecm_intake"].blocked_reason is None
        assert "no record of starting the run that made this version" in by_name["ecm_sales"].blocked_reason
        assert d.droppable() == {"ecm_intake"}
        assert d.key_names == {(1, "ecm"): {"ecm_intake"}}

    @pytest.mark.parametrize("session_id", ["0", "", APP_SESSION])
    def test_app_and_zero_sessions_are_the_apps_versions(self, engine, session_id):
        bid = _business(engine)
        _app_run(engine, bid)
        uc = _FakeUc().schema(HOME, "ecm_sales").domain(HOME, "Grain_Coop", 4, "ecm", "ecm_sales", session_id=session_id)
        assert _discover(engine, uc.install(MagicMock()), bid, HOME).droppable() == {"ecm_sales"}

    def test_a_deleted_app_version_whose_run_is_gone_is_blocked(self, engine):
        bid = _business(engine)
        uc = _FakeUc().schema(HOME, "ecm_sales").domain(HOME, "Grain_Coop", 4, "ecm", "ecm_sales", session_id=APP_SESSION)
        (schema,) = _discover(engine, uc.install(MagicMock()), bid, HOME).schemas
        assert "deleted by an earlier release of the app" in schema.blocked_reason

    def test_an_open_cleanup_makes_an_outside_session_the_apps_deletion(self, engine):
        bid = _business(engine)
        _open_cleanup(engine, 4)
        uc = _FakeUc().schema(HOME, "ecm_sales").domain(HOME, "Grain_Coop", 4, "ecm", "ecm_sales", session_id=OOB_SESSION)
        assert _discover(engine, uc.install(MagicMock()), bid, HOME).droppable() == {"ecm_sales"}

    def test_a_version_with_no_business_row_is_not_droppable(self, engine):
        bid = _business(engine)
        uc = _FakeUc().schema(HOME, "ecm_sales").domain(HOME, "Grain_Coop", 4, "ecm", "ecm_sales", session_id=None)
        (schema,) = _discover(engine, uc.install(MagicMock()), bid, HOME).schemas
        assert "no business record" in schema.blocked_reason

    def test_the_oob_detector_and_the_orphan_drop_share_the_row_rule(self, engine):
        from vibe_modeling.backend import oob_detector

        _app_run(engine, _business(engine))
        with Session(engine) as s:
            rule = oob_detector.OobRowRule.load(s, HOME)
        key = ("grain_coop", 4, "ecm")
        assert rule.outside_app(key, OOB_SESSION) is True
        assert rule.outside_app(key, APP_SESSION) is False
        assert rule.outside_app(key, "0") is False and rule.outside_app(key, None) is False

    def test_a_catalog_per_domain_install_yields_no_orphans_in_its_domain_catalog(self, engine):
        # The agent rewrites database_name with the deploy prefix ("" here) per
        # domain catalog (nb 107060-107063), so the physical schema is "intake".
        bid = _business(engine)
        vid = _version(engine, bid, 2, domains=("ecm_intake",), installed_in=(HOME,))
        with Session(engine) as s:
            run = Run(business_id=bid, intent="install", status="completed", parameters_json="{}")
            s.add(run)
            s.flush()
            s.add(RunOperation(
                run_id=run.id, step_index=0, operation_name="install", params_json="{}",
                status="succeeded", parent_version_id=vid,
                dispatched_widgets_json=json.dumps({
                    "deployment_catalog": HOME, "cataloging_style": "Catalog per Domain",
                    "schema_prefix": "", "schema_suffix": "",
                }),
            ))
            s.commit()
        uc = _FakeUc().schema("cat_intake", "intake").schema(HOME, "_metamodel")
        uc.registry["cat_intake"] = []
        assert _discover(engine, uc.install(MagicMock()), bid, "cat_intake").schemas == []

    def test_reserved_schemas_are_never_candidates(self, engine):
        bid = _business(engine)
        uc = _FakeUc().schema(HOME, "_metrics").domain(HOME, "Grain_Coop", 1, "ecm", "_metrics")
        assert _discover(engine, uc.install(MagicMock()), bid, HOME).schemas == []

    def test_no_registry_table_uses_lakebase_names_only(self, engine):
        bid = _business(engine)
        _version(engine, bid, 1, domains=("ecm_intake",))
        uc = _FakeUc().schema(HOME, "ecm_intake")
        uc.registry.pop(HOME, None)
        d = _discover(engine, uc.install(MagicMock()), bid, HOME)
        assert _names(d) == {("ecm_intake", "exact", True)}

    def test_unreadable_registry_raises(self, engine):
        uc = _FakeUc().schema(HOME, "ecm_intake")
        uc.registry_error = True
        with pytest.raises(orph.OrphanDiscoveryError, match="registry in home_cat could not be read"):
            orph.read_registry(uc.install(MagicMock()), "wh-1", HOME)

    def test_confirm_subject_is_bound_to_the_set(self):
        a = orph.confirm_subject(HOME, ["ecm_sales", "ecm_intake"])
        assert a == orph.confirm_subject(HOME, ["ECM_INTAKE", "ecm_sales"])
        assert a.startswith("drop_destroys_data:home_cat:")
        assert a != orph.confirm_subject(HOME, ["ecm_sales"])
        assert a != orph.confirm_subject(OTHER, ["ecm_sales", "ecm_intake"])


def _orphan_catalog() -> _FakeUc:
    """Deleted v1 ECM of Grain Coop left two schemas in HOME: one with data."""
    return (
        _FakeUc()
        .schema(HOME, "ecm_intake", tables=[("scale_ticket", 12), ("receiving_record", 0)])
        .schema(HOME, "ecm_sales", tables=[("sale", 0)])
        .schema(HOME, "_metamodel")
        .domain(HOME, "Grain_Coop", 1, "ecm", "ecm_intake")
        .domain(HOME, "Grain_Coop", 1, "ecm", "ecm_sales")
    )


class TestRoutes:
    def _url(self, bid, suffix=""):
        return f"/api/businesses/{bid}/orphan-schemas{suffix}"

    def _drop(self, client, bid, schemas, confirmed=(), catalog=HOME):
        return client.post(
            self._url(bid, "/drop"),
            json={"catalog": catalog, "schemas": list(schemas), "confirmed_issues": list(confirmed)},
        )

    def test_list_shape_impact_and_subject(self, client, engine, mock_ws):
        _config(engine)
        bid = _business(engine)
        _orphan_catalog().install(mock_ws)
        r = client.get(self._url(bid))
        assert r.status_code == 200, r.text
        body = r.json()
        assert set(body) == {"catalog", "schemas", "impact", "confirm_subject"}
        assert body["catalog"] == HOME
        assert [(s["name"], s["owned_by_app"], s["table_count"]) for s in body["schemas"]] == [
            ("ecm_intake", True, 2), ("ecm_sales", True, 1),
        ]
        assert body["impact"]["has_data"] == "yes"
        assert body["confirm_subject"] == orph.confirm_subject(HOME, ["ecm_intake", "ecm_sales"])

    def test_list_of_a_selection_without_data_needs_no_subject(self, client, engine, mock_ws):
        _config(engine)
        bid = _business(engine)
        _orphan_catalog().install(mock_ws)
        r = client.get(self._url(bid, "?schemas=ecm_sales"))
        assert r.status_code == 200, r.text
        assert r.json()["impact"]["has_data"] == "no"
        assert r.json()["confirm_subject"] is None

    def test_list_of_a_schema_that_is_not_an_orphan_is_409(self, client, engine, mock_ws):
        _config(engine)
        bid = _business(engine)
        _orphan_catalog().install(mock_ws)
        r = client.get(self._url(bid, "?schemas=_metamodel"))
        assert r.status_code == 409, r.text
        assert r.json()["detail"]["error"] == "not_droppable"

    def test_unconfirmed_drop_of_data_is_422_and_writes_nothing(self, client, engine, mock_ws):
        _config(engine)
        bid = _business(engine)
        uc = _orphan_catalog()
        uc.install(mock_ws)
        before = table_digests(engine)
        r = self._drop(client, bid, ["ecm_intake", "ecm_sales"])
        assert r.status_code == 422, r.text
        detail = r.json()["detail"]
        assert detail["error"] == "needs_confirmation"
        (issue,) = detail["issues"]
        assert issue["subject"] == orph.confirm_subject(HOME, ["ecm_intake", "ecm_sales"])
        assert detail["impact"]["has_data"] == "yes"
        assert "1 of 3 tables hold data" in issue["message"]
        assert changed_tables(before, table_digests(engine)) == set()
        assert uc.drops == []

    def test_confirmed_drop_records_the_run_and_cleans_the_registry(self, client, engine, mock_ws):
        _config(engine)
        bid = _business(engine)
        uc = _orphan_catalog()
        uc.install(mock_ws)
        subject = orph.confirm_subject(HOME, ["ecm_intake", "ecm_sales"])
        r = self._drop(client, bid, ["ecm_sales", "ECM_Intake"], confirmed=[subject])
        assert r.status_code == 200, r.text
        body = r.json()
        assert [(s["name"], s["status"]) for s in body["schemas"]] == [
            ("ecm_intake", "dropped"), ("ecm_sales", "dropped"),
        ]
        assert body["metamodel_cleanup"] == {"done": 1, "pending": 0, "failed": 0}
        assert uc.drops == [(HOME, "ecm_intake"), (HOME, "ecm_sales")]
        assert uc.registry[HOME] == []
        with Session(engine) as s:
            run = s.get(Run, body["run_id"])
            assert (run.intent, run.status, run.version_id) == ("uninstall-orphan-schemas", "completed", None)
            assert json.loads(run.parameters_json)["schemas"] == ["ecm_intake", "ecm_sales"]
            rows = s.exec(select(RunSchemaDrop).where(RunSchemaDrop.run_id == run.id)).all()
            assert sorted((x.schema_name, x.status, x.table_count) for x in rows) == [
                ("ecm_intake", "dropped", 2), ("ecm_sales", "dropped", 1),
            ]
            (cleanup,) = s.exec(select(MetamodelCleanup)).all()
            assert (cleanup.business_segment, cleanup.version, cleanup.scope, cleanup.catalog,
                    cleanup.reason, cleanup.status) == ("grain_coop", 1, "ecm", HOME, "orphan_drop", "done")

    def test_a_drop_closes_the_earlier_unfinished_cleanup_of_the_version(self, client, engine, mock_ws):
        _config(engine)
        bid = _business(engine)
        old = _open_cleanup(engine, 1)
        uc = _FakeUc().schema(HOME, "ecm_sales", tables=[("sale", 0)]).domain(
            HOME, "Grain_Coop", 1, "ecm", "ecm_sales", session_id=APP_SESSION,
        )
        uc.install(mock_ws)
        r = self._drop(client, bid, ["ecm_sales"])
        assert r.status_code == 200, r.text
        assert r.json()["metamodel_cleanup"] == {"done": 1, "pending": 0, "failed": 0}
        with Session(engine) as s:
            rows = {c.id: c for c in s.exec(select(MetamodelCleanup)).all()}
            assert len(rows) == 2 and all(c.status == "done" for c in rows.values())
            assert rows[old].last_error == f"Done by the orphan-schema drop run {r.json()['run_id']}"

    def test_drop_of_empty_schemas_needs_no_confirmation(self, client, engine, mock_ws):
        _config(engine)
        bid = _business(engine)
        uc = _orphan_catalog()
        uc.install(mock_ws)
        r = self._drop(client, bid, ["ecm_sales"])
        assert r.status_code == 200, r.text
        assert uc.drops == [(HOME, "ecm_sales")]
        # ecm_intake is still there, so v1's registry rows stay.
        assert r.json()["metamodel_cleanup"] == {"done": 0, "pending": 0, "failed": 0}
        assert len(uc.registry[HOME]) == 2

    def test_the_run_reports_each_schema_and_cannot_be_retried(self, client, engine, mock_ws):
        _config(engine)
        bid = _business(engine)
        uc = _orphan_catalog()
        uc.fail_drop.add("ecm_intake")
        uc.install(mock_ws)
        subject = orph.confirm_subject(HOME, ["ecm_intake", "ecm_sales"])
        run_id = self._drop(client, bid, ["ecm_intake", "ecm_sales"], confirmed=[subject]).json()["run_id"]
        r = client.get(f"/api/businesses/{bid}/runs/{run_id}/schema-drops")
        assert r.status_code == 200, r.text
        assert [(x["name"], x["status"]) for x in r.json()] == [("ecm_intake", "failed"), ("ecm_sales", "dropped")]
        assert client.get(f"/api/businesses/other/runs/{run_id}/schema-drops").status_code == 404
        before = table_digests(engine)
        retry = client.post(f"/api/businesses/{bid}/runs/{run_id}/retry")
        assert retry.status_code == 422, retry.text
        assert "not retried" in retry.json()["detail"]
        resume = client.post(f"/api/businesses/{bid}/runs/{run_id}/resume")
        assert resume.status_code == 422, resume.text
        assert changed_tables(before, table_digests(engine)) == set()

    def test_a_failed_drop_is_recorded_and_the_rest_continue(self, client, engine, mock_ws):
        _config(engine)
        bid = _business(engine)
        uc = _orphan_catalog()
        uc.fail_drop.add("ecm_intake")
        uc.install(mock_ws)
        subject = orph.confirm_subject(HOME, ["ecm_intake", "ecm_sales"])
        r = self._drop(client, bid, ["ecm_intake", "ecm_sales"], confirmed=[subject])
        assert r.status_code == 200, r.text
        by_name = {s["name"]: s for s in r.json()["schemas"]}
        assert by_name["ecm_intake"]["status"] == "failed"
        assert "PERMISSION_DENIED" in by_name["ecm_intake"]["error"]
        assert by_name["ecm_sales"]["status"] == "dropped"
        assert len(uc.registry[HOME]) == 2
        with Session(engine) as s:
            run = s.get(Run, r.json()["run_id"])
            assert run.status == "failed"
            assert "ecm_intake" in run.error_message

    def test_a_failed_statement_whose_schema_is_gone_counts_as_dropped(self, client, engine, mock_ws):
        _config(engine)
        bid = _business(engine)
        uc = _orphan_catalog()
        uc.error_but_dropped.add("ecm_sales")
        uc.install(mock_ws)
        r = self._drop(client, bid, ["ecm_sales"])
        assert r.status_code == 200, r.text
        assert r.json()["schemas"][0]["status"] == "dropped"

    def test_a_drop_still_running_after_the_timeout_is_failed_with_a_check_again_note(
        self, client, engine, mock_ws, monkeypatch,
    ):
        _config(engine)
        bid = _business(engine)
        uc = _orphan_catalog()
        uc.install(mock_ws)
        real_run = orph._sql.run

        def _run(ws, warehouse_id, sql, *a, **kw):
            if sql.startswith("DROP SCHEMA"):
                assert kw["on_timeout"] == "detach"
                raise orph._sql.SqlStatementError("STILL_RUNNING", "still running", statement_id="s1")
            return real_run(ws, warehouse_id, sql, *a, **kw)

        monkeypatch.setattr(orph._sql, "run", _run)
        r = self._drop(client, bid, ["ecm_sales"])
        assert r.status_code == 200, r.text
        (row,) = r.json()["schemas"]
        assert row["status"] == "failed" and "may still be running" in row["error"]
        with Session(engine) as s:
            assert s.get(Run, r.json()["run_id"]).status == "failed"

    def test_a_version_with_rows_in_another_catalog_keeps_its_registry_rows(self, client, engine, mock_ws):
        _config(engine)
        bid = _business(engine)
        uc = _orphan_catalog().domain(HOME, "Grain_Coop", 1, "ecm", "ecm_billing", domain_catalog=OTHER)
        uc.install(mock_ws)
        subject = orph.confirm_subject(HOME, ["ecm_intake", "ecm_sales"])
        r = self._drop(client, bid, ["ecm_intake", "ecm_sales"], confirmed=[subject])
        assert r.status_code == 200, r.text
        assert [x["status"] for x in r.json()["schemas"]] == ["dropped", "dropped"]
        assert r.json()["metamodel_cleanup"] == {"done": 0, "pending": 0, "failed": 0}
        assert len(uc.registry[HOME]) == 3
        with Session(engine) as s:
            assert s.exec(select(MetamodelCleanup)).all() == []

    def test_a_schema_made_outside_the_app_is_refused_and_nothing_written(self, client, engine, mock_ws):
        _config(engine)
        bid = _business(engine)
        uc = _orphan_catalog().schema(HOME, "ecm_storage").domain(
            HOME, "Grain_Coop", 7, "ecm", "ecm_storage", session_id=OOB_SESSION,
        )
        uc.install(mock_ws)
        before = table_digests(engine)
        r = self._drop(client, bid, ["ecm_storage"])
        assert r.status_code == 409, r.text
        assert r.json()["detail"]["schemas"] == ["ecm_storage"]
        assert changed_tables(before, table_digests(engine)) == set()
        assert uc.drops == []

    def test_a_schema_not_owned_by_the_app_is_refused_and_nothing_written(self, client, engine, mock_ws):
        _config(engine)
        bid = _business(engine)
        uc = _orphan_catalog().schema(HOME, "ecm_storage", owner="someone@example.com")
        uc.domain(HOME, "Grain_Coop", 1, "ecm", "ecm_storage")
        uc.install(mock_ws)
        before = table_digests(engine)
        r = self._drop(client, bid, ["ecm_sales", "ecm_storage"])
        assert r.status_code == 409, r.text
        assert r.json()["detail"]["schemas"] == ["ecm_storage"]
        assert changed_tables(before, table_digests(engine)) == set()
        assert uc.drops == []

    def test_an_active_run_is_409_and_nothing_written(self, client, engine, mock_ws):
        _config(engine)
        bid = _business(engine)
        with Session(engine) as s:
            s.add(Run(business_id=bid, intent="vibe-iterate", status="running"))
            s.commit()
        uc = _orphan_catalog()
        uc.install(mock_ws)
        before = table_digests(engine)
        r = self._drop(client, bid, ["ecm_sales"])
        assert r.status_code == 409, r.text
        assert "active run" in r.json()["detail"]
        assert changed_tables(before, table_digests(engine)) == set()
        assert uc.drops == []

    def test_the_state_is_read_again_under_the_lock(self, client, engine, mock_ws):
        _config(engine)
        bid = _business(engine)
        uc = _orphan_catalog()

        def _owner_changes_after_first_check(fake, calls):
            if calls == 2:
                fake.schemas[HOME]["ecm_sales"] = "someone@example.com"

        uc.on_list = _owner_changes_after_first_check
        uc.install(mock_ws)
        before = table_digests(engine)
        r = self._drop(client, bid, ["ecm_sales"])
        assert r.status_code == 409, r.text
        assert uc.list_calls == 2
        assert changed_tables(before, table_digests(engine)) == set()
        assert uc.drops == []

    def test_an_unreadable_registry_is_503(self, client, engine, mock_ws):
        _config(engine)
        bid = _business(engine)
        uc = _orphan_catalog()
        uc.registry_error = True
        uc.install(mock_ws)
        r = client.get(self._url(bid))
        assert r.status_code == 503, r.text
        assert r.json()["detail"]["error"] == "oob_scan_failed"

    def test_no_warehouse_is_config_missing(self, client, engine, mock_ws):
        with Session(engine) as s:
            s.add(AgentConfig(deployment_catalog=HOME, warehouse_id=""))
            s.commit()
        bid = _business(engine)
        r = client.get(self._url(bid))
        assert r.status_code == 422, r.text
        assert r.json()["detail"]["missing"][0]["key"] == "warehouse"

    @pytest.mark.parametrize("bad", ["Bad-Name", "x" * 300, "1cat"])
    def test_a_catalog_that_is_not_a_uc_name_is_422(self, client, engine, mock_ws, bad):
        _config(engine)
        bid = _business(engine)
        r = self._drop(client, bid, ["ecm_sales"], catalog=bad)
        assert r.status_code == 422, r.text

    def test_unknown_business_is_404(self, client, engine, mock_ws):
        _config(engine)
        assert client.get(self._url("nope")).status_code == 404

    def test_non_admin_is_refused_before_any_read(self, client, engine, mock_ws, monkeypatch):
        monkeypatch.setattr(_roles_mod, "RBAC_ENABLED", True)
        viewer_ws = MagicMock()
        user = MagicMock()
        user.groups = []
        viewer_ws.users.list.return_value = [user]
        client.app.state.workspace_client = viewer_ws
        _config(engine)
        bid = _business(engine)
        headers = {"X-Forwarded-Email": "modeler@example.com"}
        assert client.get(self._url(bid), headers=headers).status_code == 403
        r = client.post(self._url(bid, "/drop"), json={"catalog": HOME, "schemas": ["x"]}, headers=headers)
        assert r.status_code == 403
        mock_ws.schemas.list.assert_not_called()

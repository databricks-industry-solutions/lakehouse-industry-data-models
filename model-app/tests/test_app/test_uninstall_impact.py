"""Uninstall impact (`services/uninstall_impact.py`, `getUninstallImpact`).

The workspace is a MagicMock whose ``schemas.list`` and Statement Execution
calls are answered by :class:`_FakeCatalog`: it parses the two statement
shapes the service sends (the ``information_schema`` listing and the
scalar-subquery data check) and answers from an in-memory catalog, so every
submitted statement is checked for shape, quoting and bound parameters.
"""
from __future__ import annotations

import json
import re
from datetime import datetime, timezone
from types import SimpleNamespace
from unittest.mock import MagicMock
from uuid import uuid4

import pytest
from sqlmodel import Session

import vibe_modeling.backend.core._roles as _roles_mod
from vibe_modeling.backend.db_models import (
    AgentConfig,
    Business,
    Domain,
    ModelVersion,
    ModelVersionInstall,
    Product,
    Run,
    RunOperation,
)
from vibe_modeling.backend.services import uninstall_impact as ui
from vibe_modeling.backend.services.dispatched_widgets import latest_install_widgets

from _sql_fakes import FakeClock, response

CATALOG = "wt_catalog"

_CHECK_RE = re.compile(
    r"SELECT (\d+) AS i, \(SELECT COUNT\(\*\) FROM \(SELECT 1 FROM "
    r"`([A-Za-z0-9_]+)`\.`([A-Za-z0-9_]+)`\.`([A-Za-z0-9_]+)` LIMIT 1\)\) AS n"
)


class _FakeCatalog:
    """One catalog: schemas (with owners), their objects, and table row counts."""

    def __init__(self, clock: FakeClock | None = None) -> None:
        self.schemas: dict[str, str] = {}
        self.objects: dict[str, list[tuple[str, str]]] = {}
        self.rows_in: dict[tuple[str, str], int] = {}
        self.listing_sql: list[str] = []
        self.check_sql: list[str] = []
        self.params: list[dict] = []
        self.timeouts: list[str] = []
        self.fail_listing = False
        self.fail_check_chunks: set[int] = set()
        self.hang_checks = False
        self.fail_schema_list = False
        self.clock = clock
        self.cancelled: set[str] = set()
        self._n = 0

    def schema(self, name: str, owner: str = "app-sp") -> "_FakeCatalog":
        self.schemas[name] = owner
        self.objects.setdefault(name, [])
        return self

    def add(self, schema: str, name: str, kind: str = "MANAGED", rows: int = 0) -> "_FakeCatalog":
        self.objects.setdefault(schema, []).append((name, kind))
        self.rows_in[(schema, name)] = rows
        return self

    def install(self, ws: MagicMock) -> MagicMock:
        def _list(catalog_name, **_kw):
            if self.fail_schema_list or catalog_name != CATALOG:
                raise RuntimeError("PERMISSION_DENIED: cannot list schemas")
            return iter(
                SimpleNamespace(name=n, owner=o) for n, o in sorted(self.schemas.items())
            )

        ws.schemas.list.side_effect = _list
        ws.statement_execution.execute_statement.side_effect = self._execute
        ws.statement_execution.get_statement.side_effect = self._get
        ws.statement_execution.cancel_execution.side_effect = self.cancelled.add
        return ws

    def _sid(self) -> str:
        self._n += 1
        return f"stmt-{self._n}"

    def _execute(self, *, statement, warehouse_id, wait_timeout=None, parameters=None, **_kw):
        assert warehouse_id
        self.timeouts.append(wait_timeout)
        params = {p.name: p.value for p in (parameters or [])}
        self.params.append(params)
        if "information_schema" in statement:
            self.listing_sql.append(statement)
            if self.fail_listing:
                return response(error="[INSUFFICIENT_PERMISSIONS] no USE SCHEMA", statement_id=self._sid())
            wanted = set(params.values())
            out = []
            for schema in sorted(wanted):
                for name, kind in self.objects.get(schema, []):
                    out.append([schema, name, "VOLUME" if kind == "VOLUME" else kind])
            return response(out, columns=["table_schema", "table_name", "table_type"], statement_id=self._sid())
        self.check_sql.append(statement)
        chunk_no = len(self.check_sql) - 1
        if self.hang_checks:
            if self.clock is not None:
                self.clock.advance(int((wait_timeout or "0s").rstrip("s") or 0))
            return response(state="RUNNING", statement_id=self._sid())
        if chunk_no in self.fail_check_chunks:
            return response(error="[TABLE_OR_VIEW_NOT_FOUND] gone", statement_id=self._sid())
        out = []
        for i, cat, schema, table in _CHECK_RE.findall(statement):
            assert cat == CATALOG
            out.append([i, "1" if self.rows_in.get((schema, table), 0) else "0"])
        assert out, statement
        return response(out, columns=["i", "n"], statement_id=self._sid())

    def _get(self, sid):
        if self.clock is not None:
            self.clock.advance(5.0)
        return response(state="CANCELED" if sid in self.cancelled else "RUNNING", statement_id=sid)


@pytest.fixture(autouse=True)
def _reset_cache_and_limiter():
    ui.IMPACT_CACHE.clear()
    ui.SCAN_LIMITER.clear()
    yield
    ui.IMPACT_CACHE.clear()
    ui.SCAN_LIMITER.clear()


def _seed(
    engine,
    *,
    domains=("ecm_customer", "ecm_inventory"),
    scope="ecm",
    uc_catalog=CATALOG,
    deployment_status="deployed",
    table_names=(),
    install_widgets=None,
) -> tuple[str, str]:
    with Session(engine) as s:
        b = Business(name=f"impact-biz-{uuid4().hex[:8]}", description="t")
        s.add(b)
        s.flush()
        mv = ModelVersion(
            business_id=b.id, version=3, scope=scope, status="completed",
            deployment_status=deployment_status, uc_catalog=uc_catalog,
        )
        s.add(mv)
        s.flush()
        domain_ids = []
        for d in domains:
            row = Domain(version_id=mv.id, name=d, database_name=d)
            s.add(row)
            s.flush()
            domain_ids.append(row.id)
        for n, table_name in enumerate(table_names):
            s.add(Product(
                version_id=mv.id, domain_id=domain_ids[0], name=f"p{n}", table_name=table_name,
            ))
        if install_widgets is not None:
            run = Run(business_id=b.id, intent="install", status="succeeded", parameters_json="{}")
            s.add(run)
            s.flush()
            s.add(RunOperation(
                run_id=run.id, step_index=0, operation_name="install", params_json="{}",
                status="succeeded", parent_version_id=mv.id,
                dispatched_widgets_json=json.dumps(install_widgets),
            ))
        s.commit()
        return b.id, mv.id


def _impact(engine, ws, version_id, *, warehouse="wh-1", budget_s=ui.IMPACT_BUDGET_S, style=None):
    with Session(engine) as s:
        mv = s.get(ModelVersion, version_id)
        return ui.compute_uninstall_impact(
            s, ws, warehouse, mv, CATALOG, budget_s=budget_s, cataloging_style=style,
        )


def _failed_ops(engine, business_id, version_id, *ops) -> None:
    """Ops reading ``version_id`` as ``(operation_name, status, widgets)``."""
    with Session(engine) as s:
        run = Run(business_id=business_id, intent="install", status="failed", parameters_json="{}")
        s.add(run)
        s.flush()
        for n, (name, status, widgets) in enumerate(ops):
            s.add(RunOperation(
                run_id=run.id, step_index=n, operation_name=name, params_json="{}", status=status,
                parent_version_id=version_id, dispatched_widgets_json=json.dumps(widgets),
            ))
        s.commit()


def _standard_catalog(clock=None) -> _FakeCatalog:
    fake = _FakeCatalog(clock)
    fake.schema("ecm_customer", owner="app-sp")
    fake.add("ecm_customer", "party", rows=12)
    fake.add("ecm_customer", "address", rows=0)
    fake.add("ecm_customer", "party_v", kind="VIEW")
    fake.add("ecm_customer", "party_metrics", kind="METRIC_VIEW")
    fake.add("ecm_customer", "samples", kind="VOLUME")
    fake.schema("ecm_inventory", owner="someone@example.com")
    fake.add("ecm_inventory", "stock", kind="EXTERNAL", rows=0)
    fake.schema("mvm_customer")
    fake.add("mvm_customer", "party", rows=5)
    return fake


class TestImpact:
    def test_tables_with_data_views_and_volumes(self, engine):
        _, vid = _seed(engine)
        fake = _standard_catalog()
        impact = _impact(engine, fake.install(MagicMock()), vid)

        assert impact.has_data == "yes"
        assert impact.truncated is False
        assert [s.name for s in impact.schemas] == ["ecm_customer", "ecm_inventory"]
        cust, inv = impact.schemas
        assert cust.owner == "app-sp" and inv.owner == "someone@example.com"
        assert [(t.name, t.kind, t.has_data) for t in cust.tables] == [
            ("address", "MANAGED", False), ("party", "MANAGED", True),
        ]
        assert sorted(cust.views) == ["party_metrics", "party_v"]
        assert cust.volumes == ["samples"]
        assert not cust.shared and cust.objects_listed
        assert [(t.name, t.kind, t.has_data) for t in inv.tables] == [("stock", "EXTERNAL", False)]
        assert impact.reasons == ["1 volume will be dropped; the files in volumes are not checked."]
        assert ui.impact_needs_confirmation(impact) is True

    def test_one_listing_and_one_check_statement_with_bound_schemas(self, engine):
        _, vid = _seed(engine)
        fake = _standard_catalog()
        _impact(engine, fake.install(MagicMock()), vid)

        (listing,) = fake.listing_sql
        assert f"`{CATALOG}`.information_schema.tables" in listing
        assert f"`{CATALOG}`.information_schema.volumes" in listing
        assert "ecm_customer" not in listing
        assert f"LIMIT {ui.LISTING_ROW_CAP + 1}" in listing
        assert set(fake.params[0].values()) == {"ecm_customer", "ecm_inventory"}
        (check,) = fake.check_sql
        assert len(_CHECK_RE.findall(check)) == 3
        assert "party_v" not in check and "samples" not in check

    def test_empty_tables_need_no_confirmation(self, engine):
        _, vid = _seed(engine, domains=("inventory",))
        fake = _standard_catalog()
        impact = _impact(engine, fake.install(MagicMock()), vid)

        assert impact.has_data == "no"
        assert impact.truncated is False
        assert ui.impact_needs_confirmation(impact) is False

    def test_no_schemas_in_catalog_for_a_version_not_installed_there(self, engine):
        _, vid = _seed(engine, domains=("billing",), deployment_status="uninstalled")
        fake = _standard_catalog()
        ws = fake.install(MagicMock())
        impact = _impact(engine, ws, vid)

        assert impact.has_data == "no"
        assert impact.schemas == [] and impact.reasons == []
        ws.statement_execution.execute_statement.assert_not_called()

    def test_no_schemas_found_for_an_installed_version_is_unknown(self, engine):
        _, vid = _seed(engine, domains=("billing",))
        ws = _standard_catalog().install(MagicMock())
        impact = _impact(engine, ws, vid)

        assert impact.has_data == "unknown"
        assert impact.schemas == []
        assert "records this version as installed in wt_catalog" in impact.reasons[0]

    def test_camel_case_model_with_one_domain_matched_is_unknown(self, engine):
        _, vid = _seed(engine, domains=("customerParty", "orderLine"))
        fake = _FakeCatalog().schema("ecm_customerparty").add("ecm_customerparty", "party", rows=0)
        impact = _impact(engine, fake.install(MagicMock()), vid)

        assert [s.name for s in impact.schemas] == ["ecm_customerparty"]
        assert impact.has_data == "unknown"
        assert "1 of 2 domain schemas were not found" in impact.reasons[0]

    def test_one_domain_matched_one_missing_is_unknown(self, engine):
        _, vid = _seed(engine, domains=("inventory", "billing"))
        impact = _impact(engine, _standard_catalog().install(MagicMock()), vid)

        assert [s.name for s in impact.schemas] == ["ecm_inventory"]
        assert impact.has_data == "unknown"
        assert impact.reasons == [
            "The app records this version as installed in wt_catalog, but 1 of 2 domain "
            "schemas were not found under the names the app expects."
        ]

    def test_a_missing_domain_of_a_version_not_installed_here_is_not_a_reason(self, engine):
        _, vid = _seed(engine, domains=("inventory", "billing"), deployment_status="uninstalled")
        impact = _impact(engine, _standard_catalog().install(MagicMock()), vid)
        assert impact.has_data == "no" and impact.reasons == []

    def test_listed_names_are_matched_case_insensitively_and_kept(self, engine):
        _, vid = _seed(engine, domains=("Party",))
        fake = _FakeCatalog().schema("ECM_Party").add("ECM_Party", "p", rows=2)
        impact = _impact(engine, fake.install(MagicMock()), vid)

        assert [s.name for s in impact.schemas] == ["ECM_Party"]
        assert impact.schemas[0].tables[0].has_data is True
        assert impact.has_data == "yes"

    def test_an_open_install_row_counts_as_installed(self, engine):
        _, vid = _seed(engine, domains=("billing",), deployment_status="uninstalled", uc_catalog="")
        with Session(engine) as s:
            s.add(ModelVersionInstall(version_id=vid, catalog=CATALOG))
            s.add(ModelVersionInstall(
                version_id=vid, catalog="other_cat", uninstalled_at=datetime.now(timezone.utc),
            ))
            s.commit()
        ws = _standard_catalog().install(MagicMock())
        assert _impact(engine, ws, vid).has_data == "unknown"

    def test_one_impact_per_installed_catalog(self, engine):
        """Installed in two catalogs: the check reads only the one asked for
        and names both."""
        _, vid = _seed(engine, domains=("inventory",), deployment_status="uninstalled", uc_catalog="")
        with Session(engine) as s:
            mv = s.get(ModelVersion, vid)
            from vibe_modeling.backend.services.operations._version_lifecycle import (
                mark_version_deployed,
            )

            mark_version_deployed(s, mv, CATALOG)
            mark_version_deployed(s, mv, "second_cat")
            s.commit()
        ws = _standard_catalog().install(MagicMock())
        impact = _impact(engine, ws, vid)

        assert sorted(impact.installed_catalogs) == sorted([CATALOG, "second_cat"])
        assert [s.name for s in impact.schemas] == ["ecm_inventory"]
        ws.schemas.list.assert_called_once_with(catalog_name=CATALOG)

    def test_a_catalog_the_version_is_not_installed_in_is_scanned(self, engine):
        _, vid = _seed(engine, domains=("inventory",), uc_catalog="second_cat")
        impact = _impact(engine, _standard_catalog().install(MagicMock()), vid)

        assert impact.installed_catalogs == ["second_cat"]
        assert [s.name for s in impact.schemas] == ["ecm_inventory"]
        assert impact.has_data == "no" and impact.reasons == []

    def test_a_closed_install_row_does_not(self, engine):
        _, vid = _seed(engine, domains=("billing",), deployment_status="uninstalled", uc_catalog="")
        with Session(engine) as s:
            s.add(ModelVersionInstall(
                version_id=vid, catalog=CATALOG, uninstalled_at=datetime.now(timezone.utc),
            ))
            s.commit()
        ws = _standard_catalog().install(MagicMock())
        assert _impact(engine, ws, vid).has_data == "no"

    def test_version_without_domains(self, engine):
        _, vid = _seed(engine, domains=(), deployment_status="uninstalled")
        ws = _standard_catalog().install(MagicMock())
        impact = _impact(engine, ws, vid)
        assert impact.has_data == "no" and impact.schemas == []

        _, installed = _seed(engine, domains=())
        assert _impact(engine, ws, installed).has_data == "unknown"

    def test_scope_prefix_picks_the_versions_scope(self, engine):
        _, vid = _seed(engine, scope="mvm", domains=("customer",))
        fake = _standard_catalog()
        impact = _impact(engine, fake.install(MagicMock()), vid)

        assert [s.name for s in impact.schemas] == ["mvm_customer"]
        assert impact.has_data == "yes"

    def test_every_existing_form_is_listed(self, engine):
        _, vid = _seed(engine, domains=("customer",), install_widgets={
            "cataloging_style": "One Catalog", "schema_prefix": "prod_",
        })
        fake = _standard_catalog()
        fake.schema("customer").add("customer", "other_biz", rows=0)
        fake.schema("prod_customer").add("prod_customer", "real", rows=4)
        impact = _impact(engine, fake.install(MagicMock()), vid)

        assert [s.name for s in impact.schemas] == ["customer", "ecm_customer", "prod_customer"]
        assert impact.has_data == "yes"

    def test_a_child_run_and_a_failed_install_elsewhere_do_not_add_their_prefixes(self, engine):
        """E-12: the ECM's child shrink (``mvm_``) and a failed install of it
        into another catalog (``prod_``) are not the schemas this uninstall
        drops."""
        biz, vid = _seed(engine, domains=("customer",), install_widgets={
            "cataloging_style": "One Catalog", "schema_prefix": "ecm_",
        })
        _failed_ops(engine, biz, vid, ("shrink_ecm", "succeeded", {"schema_prefix": "mvm_"}),
                    ("install", "failed", {"schema_prefix": "prod_", "deployment_catalog": "other_cat"}))
        fake = _standard_catalog()
        fake.schema("prod_customer").add("prod_customer", "real", rows=4)
        impact = _impact(engine, fake.install(MagicMock()), vid)

        assert [s.name for s in impact.schemas] == ["ecm_customer"]

    def test_a_failed_install_into_this_catalog_may_have_left_schemas(self, engine):
        biz, vid = _seed(engine, domains=("customer",), install_widgets={
            "cataloging_style": "One Catalog", "schema_prefix": "ecm_",
        })
        _failed_ops(engine, biz, vid,
                    ("install", "failed", {"schema_prefix": "prod_", "deployment_catalog": CATALOG.upper()}))
        fake = _standard_catalog()
        fake.schema("prod_customer").add("prod_customer", "real", rows=4)
        impact = _impact(engine, fake.install(MagicMock()), vid)

        assert [s.name for s in impact.schemas] == ["ecm_customer", "prod_customer"]

    def test_dotted_product_table_prefixes_are_candidates(self, engine):
        _, vid = _seed(engine, domains=("customer",), table_names=("ecm_shared.currency", "plain_table"))
        fake = _FakeCatalog().schema("ecm_shared").add("ecm_shared", "currency", rows=1)
        impact = _impact(engine, fake.install(MagicMock()), vid)

        assert [s.name for s in impact.schemas] == ["ecm_shared"]
        assert impact.has_data == "yes"

    def test_metrics_schema_is_listed_shared_and_scanned(self, engine):
        _, vid = _seed(engine, domains=("inventory",))
        fake = _standard_catalog()
        fake.schema("_metrics").add("_metrics", "party_mv", kind="METRIC_VIEW")
        fake.add("_metrics", "metrics_cache", rows=0)
        impact = _impact(engine, fake.install(MagicMock()), vid)

        assert [(s.name, s.shared) for s in impact.schemas] == [
            ("ecm_inventory", False), ("_metrics", True),
        ]
        metrics = impact.schemas[1]
        assert metrics.views == ["party_mv"]
        assert [(t.name, t.has_data) for t in metrics.tables] == [("metrics_cache", False)]
        assert "_metrics" in fake.params[0].values()
        assert impact.has_data == "no"

    def test_metrics_schema_names_the_other_versions_installed_here(self, engine):
        """Every uninstall drops the whole ``_metrics``: the other versions
        installed in the catalog, of any business, lose their metric views."""
        _, vid = _seed(engine, domains=("inventory",))
        other_biz, other_vid = _seed(engine, domains=("billing",), scope="mvm")
        _, elsewhere = _seed(engine, domains=("billing",), uc_catalog="second_cat")
        _, gone = _seed(engine, domains=("billing",), deployment_status="uninstalled")
        with Session(engine) as s:
            other_name = s.get(Business, other_biz).name
        fake = _standard_catalog()
        fake.schema("_metrics").add("_metrics", "party_mv", kind="METRIC_VIEW")
        fake.add("_metrics", "billing_mv", kind="METRIC_VIEW")
        impact = _impact(engine, fake.install(MagicMock()), vid)

        version_schema, metrics = impact.schemas
        assert version_schema.other_versions == []
        assert metrics.shared and sorted(metrics.views) == ["billing_mv", "party_mv"]
        assert [(o.version_id, o.business_name, o.scope, o.version) for o in metrics.other_versions] == [
            (other_vid, other_name, "mvm", 3),
        ]
        assert elsewhere not in {o.version_id for o in metrics.other_versions}
        assert gone not in {o.version_id for o in metrics.other_versions}
        assert impact.has_data == "no"

    def test_other_versions_match_a_mixed_case_stored_catalog(self, engine):
        _, vid = _seed(engine, domains=("inventory",))
        _, legacy = _seed(engine, domains=("billing",), uc_catalog="WT_Catalog")
        _, rowed = _seed(engine, domains=("billing",), deployment_status="uninstalled", uc_catalog="")
        with Session(engine) as s:
            s.add(ModelVersionInstall(version_id=rowed, catalog="Wt_Catalog"))
            s.commit()
        fake = _standard_catalog()
        fake.schema("_metrics").add("_metrics", "mv", kind="METRIC_VIEW")
        impact = _impact(engine, fake.install(MagicMock()), vid)

        metrics = next(s for s in impact.schemas if s.shared)
        assert {o.version_id for o in metrics.other_versions} == {legacy, rowed}

    def test_metrics_schema_is_listed_even_without_version_schemas(self, engine):
        _, vid = _seed(engine, domains=("billing",), deployment_status="uninstalled")
        fake = _FakeCatalog().schema("_metrics").add("_metrics", "mv", kind="METRIC_VIEW")
        impact = _impact(engine, fake.install(MagicMock()), vid)

        assert [(s.name, s.shared, s.views) for s in impact.schemas] == [("_metrics", True, ["mv"])]
        assert impact.has_data == "no"

    def test_a_volume_alone_makes_the_result_unknown(self, engine):
        _, vid = _seed(engine, domains=("customer",))
        fake = _FakeCatalog().schema("ecm_customer").add("ecm_customer", "files", kind="VOLUME")
        impact = _impact(engine, fake.install(MagicMock()), vid)

        assert impact.has_data == "unknown"
        assert impact.schemas[0].volumes == ["files"]
        assert impact.reasons == ["1 volume will be dropped; the files in volumes are not checked."]

    @pytest.mark.parametrize("style", ["Catalog per Division", "Catalog per Domain"])
    def test_multi_catalog_style_of_the_run_is_unknown(self, engine, style):
        _, vid = _seed(engine, domains=("inventory",))
        impact = _impact(engine, _standard_catalog().install(MagicMock()), vid, style=style)

        assert impact.has_data == "unknown"
        assert impact.reasons[0].startswith(f"This version uses {style}")

    def test_multi_catalog_style_of_the_install_is_unknown(self, engine):
        _, vid = _seed(engine, domains=("inventory",), install_widgets={
            "cataloging_style": "Catalog per Division", "schema_prefix": "",
        })
        impact = _impact(engine, _standard_catalog().install(MagicMock()), vid)
        assert impact.has_data == "unknown"
        assert "Catalog per Division" in impact.reasons[0]

    def test_a_snake_case_style_is_named_by_its_label(self, engine):
        _, vid = _seed(engine, domains=("inventory",), install_widgets={
            "cataloging_style": "catalog_per_domain", "deployment_catalog": CATALOG,
        })
        impact = _impact(engine, _standard_catalog().install(MagicMock()), vid)
        assert impact.reasons[0].startswith("This version uses Catalog per Domain, so")

    def test_the_install_into_this_catalog_decides_the_style(self, engine):
        bid, vid = _seed(engine, domains=("inventory",), install_widgets={
            "cataloging_style": "One Catalog", "deployment_catalog": CATALOG,
        })
        with Session(engine) as s:
            run = Run(business_id=bid, intent="install", status="succeeded", parameters_json="{}")
            s.add(run)
            s.flush()
            s.add(RunOperation(
                run_id=run.id, step_index=0, operation_name="install", params_json="{}",
                status="succeeded", parent_version_id=vid,
                created_at=datetime(2099, 1, 1, tzinfo=timezone.utc),
                dispatched_widgets_json=json.dumps({
                    "cataloging_style": "Catalog per Division", "deployment_catalog": "other_cat",
                }),
            ))
            s.commit()
            assert latest_install_widgets(s, vid)["deployment_catalog"] == "other_cat"
            assert latest_install_widgets(s, vid, "WT_CATALOG")["deployment_catalog"] == CATALOG
            assert latest_install_widgets(s, vid, "no_such")["deployment_catalog"] == "other_cat"
        impact = _impact(engine, _standard_catalog().install(MagicMock()), vid)
        assert impact.has_data == "no" and impact.reasons == []

    def test_one_catalog_style_spellings_are_one_catalog(self, engine):
        _, vid = _seed(engine, domains=("inventory",), install_widgets={"cataloging_style": "one_catalog"})
        impact = _impact(engine, _standard_catalog().install(MagicMock()), vid, style="One Catalog")
        assert impact.has_data == "no" and impact.reasons == []

    def test_unreadable_catalog_is_unknown(self, engine):
        _, vid = _seed(engine)
        fake = _standard_catalog()
        fake.fail_schema_list = True
        impact = _impact(engine, fake.install(MagicMock()), vid)

        assert impact.has_data == "unknown" and impact.truncated is True
        assert impact.schemas == []
        assert impact.reasons == ["The schemas in wt_catalog could not be listed."]
        assert ui.impact_needs_confirmation(impact) is True

    def test_failed_listing_keeps_schemas_and_is_unknown(self, engine):
        _, vid = _seed(engine)
        fake = _standard_catalog()
        fake.fail_listing = True
        impact = _impact(engine, fake.install(MagicMock()), vid)

        assert impact.has_data == "unknown" and impact.truncated is True
        assert [(s.name, s.objects_listed, s.tables) for s in impact.schemas] == [
            ("ecm_customer", False, []), ("ecm_inventory", False, []),
        ]
        assert impact.reasons == ["The tables, views and volumes in these schemas could not be listed."]
        assert fake.check_sql == []

    def test_no_warehouse_is_unknown_without_sql(self, engine):
        _, vid = _seed(engine)
        fake = _standard_catalog()
        ws = fake.install(MagicMock())
        impact = _impact(engine, ws, vid, warehouse="")

        assert impact.has_data == "unknown" and impact.truncated is True
        assert len(impact.schemas) == 2
        assert all(not s.objects_listed for s in impact.schemas)
        ws.statement_execution.execute_statement.assert_not_called()

    def test_failed_check_chunk_is_unknown_and_the_next_chunk_runs(self, engine):
        _, vid = _seed(engine, domains=("customer",))
        fake = _FakeCatalog().schema("ecm_customer")
        for n in range(ui.DATA_CHECK_CHUNK + 1):
            fake.add("ecm_customer", f"t{n:03d}")
        fake.fail_check_chunks = {0}
        impact = _impact(engine, fake.install(MagicMock()), vid)

        assert len(fake.check_sql) == 2
        tables = impact.schemas[0].tables
        assert [t.has_data for t in tables[:ui.DATA_CHECK_CHUNK]] == [None] * ui.DATA_CHECK_CHUNK
        assert tables[-1].has_data is False
        assert impact.has_data == "unknown"
        assert impact.truncated is False

    def test_table_cap_leaves_the_rest_unknown(self, engine):
        _, vid = _seed(engine, domains=("customer",))
        fake = _FakeCatalog().schema("ecm_customer")
        for n in range(ui.DATA_CHECK_TABLE_CAP + 1):
            fake.add("ecm_customer", f"t{n:03d}")
        impact = _impact(engine, fake.install(MagicMock()), vid)

        assert len(fake.check_sql) == ui.DATA_CHECK_TABLE_CAP // ui.DATA_CHECK_CHUNK
        assert all(len(_CHECK_RE.findall(s)) <= ui.DATA_CHECK_CHUNK for s in fake.check_sql)
        tables = impact.schemas[0].tables
        assert sum(t.has_data is None for t in tables) == 1
        assert tables[-1].has_data is None
        assert impact.truncated is True
        assert impact.has_data == "unknown"

    def test_a_table_with_data_beyond_the_cap_still_reports_yes(self, engine):
        _, vid = _seed(engine, domains=("customer",))
        fake = _FakeCatalog().schema("ecm_customer")
        fake.add("ecm_customer", "a_full", rows=3)
        for n in range(ui.DATA_CHECK_TABLE_CAP):
            fake.add("ecm_customer", f"t{n:03d}")
        impact = _impact(engine, fake.install(MagicMock()), vid)

        assert impact.truncated is True
        assert impact.has_data == "yes"

    def test_budget_stops_the_check_and_cancels(self, engine, monkeypatch):
        clock = FakeClock().install(monkeypatch)
        _, vid = _seed(engine, domains=("customer",))
        fake = _FakeCatalog(clock).schema("ecm_customer")
        for n in range(3 * ui.DATA_CHECK_CHUNK):
            fake.add("ecm_customer", f"t{n:03d}")
        fake.hang_checks = True
        impact = _impact(engine, fake.install(MagicMock()), vid)

        assert impact.has_data == "unknown" and impact.truncated is True
        assert all(t.has_data is None for t in impact.schemas[0].tables)
        assert len(fake.check_sql) == 1
        assert fake.cancelled
        assert clock.elapsed <= ui.IMPACT_BUDGET_S + 5.0
        assert fake.timeouts[1] in {f"{s}s" for s in range(0, 41)}

    def test_no_time_left_skips_the_listing(self, engine):
        _, vid = _seed(engine)
        fake = _standard_catalog()
        ws = fake.install(MagicMock())
        impact = _impact(engine, ws, vid, budget_s=0.0)

        assert impact.has_data == "unknown" and impact.truncated is True
        ws.statement_execution.execute_statement.assert_not_called()

    def test_non_identifier_table_names_are_unknown_and_never_in_sql(self, engine):
        _, vid = _seed(engine, domains=("customer",))
        fake = _FakeCatalog().schema("ecm_customer")
        fake.add("ecm_customer", "ok_table", rows=0)
        fake.add("ecm_customer", "bad-name`; DROP", rows=0)
        impact = _impact(engine, fake.install(MagicMock()), vid)

        by_name = {t.name: t.has_data for t in impact.schemas[0].tables}
        assert by_name == {"ok_table": False, "bad-name`; DROP": None}
        assert all("DROP" not in s for s in fake.check_sql)
        assert impact.has_data == "unknown"

    def test_non_identifier_catalog_is_refused(self, engine):
        _, vid = _seed(engine)
        ws = _standard_catalog().install(MagicMock())
        with Session(engine) as s:
            mv = s.get(ModelVersion, vid)
            with pytest.raises(ValueError):
                ui.compute_uninstall_impact(s, ws, "wh-1", mv, "a.b")
        ws.schemas.list.assert_not_called()


class TestRule:
    def test_confirm_subject(self):
        assert ui.uninstall_confirm_subject("mv-1", "cat") == "uninstall_destroys_data:mv-1:cat"

    @pytest.mark.parametrize("has_data,needed", [("yes", True), ("unknown", True), ("no", False)])
    def test_needs_confirmation(self, has_data, needed):
        impact = ui.UninstallImpactOut(version_id="v", catalog="c", has_data=has_data)
        assert ui.impact_needs_confirmation(impact) is needed


class TestCacheAndLimit:
    def _call(self, engine, ws, vid, **kw):
        with Session(engine) as s:
            mv = s.get(ModelVersion, vid)
            return ui.uninstall_impact(s, ws, "wh-1", mv, CATALOG, **kw)

    def test_cached_for_60_seconds(self, engine, monkeypatch):
        clock = FakeClock().install(monkeypatch)
        _, vid = _seed(engine)
        fake = _standard_catalog()
        ws = fake.install(MagicMock())

        first = self._call(engine, ws, vid)
        clock.advance(ui.CACHE_TTL_S - 1)
        second = self._call(engine, ws, vid)
        assert second == first
        assert len(fake.listing_sql) == 1

        clock.advance(2)
        self._call(engine, ws, vid)
        assert len(fake.listing_sql) == 2

    def test_cache_returns_copies(self, engine):
        _, vid = _seed(engine)
        ws = _standard_catalog().install(MagicMock())
        first = self._call(engine, ws, vid)
        first.schemas.clear()
        assert len(self._call(engine, ws, vid).schemas) == 2

    def test_fresh_rescans_and_refreshes_the_cache(self, engine):
        _, vid = _seed(engine, domains=("customer",))
        fake = _FakeCatalog().schema("ecm_customer").add("ecm_customer", "party", rows=12)
        ws = fake.install(MagicMock())
        assert self._call(engine, ws, vid).has_data == "yes"

        fake.rows_in[("ecm_customer", "party")] = 0
        assert self._call(engine, ws, vid).has_data == "yes"
        assert self._call(engine, ws, vid, fresh=True).has_data == "no"
        assert self._call(engine, ws, vid).has_data == "no"
        assert len(fake.listing_sql) == 2

    def test_the_cache_key_includes_the_style(self, engine):
        _, vid = _seed(engine, domains=("customer",))
        fake = _FakeCatalog().schema("ecm_customer").add("ecm_customer", "party", rows=0)
        ws = fake.install(MagicMock())
        assert self._call(engine, ws, vid).has_data == "no"
        assert self._call(engine, ws, vid, cataloging_style="Catalog per Domain").has_data == "unknown"
        assert len(fake.listing_sql) == 2

    def test_per_user_scan_limit(self, engine, monkeypatch):
        clock = FakeClock().install(monkeypatch)
        _, vid = _seed(engine)
        ws = _standard_catalog().install(MagicMock())

        for _ in range(ui.SCANS_PER_USER):
            self._call(engine, ws, vid, user="a@x", fresh=True)
        with pytest.raises(ui.ScanRateLimited) as exc:
            self._call(engine, ws, vid, user="a@x", fresh=True)
        assert 1 <= exc.value.retry_after_s <= ui.SCAN_WINDOW_S

        self._call(engine, ws, vid, user="b@x", fresh=True)
        self._call(engine, ws, vid, user="a@x")

        clock.advance(ui.SCAN_WINDOW_S)
        self._call(engine, ws, vid, user="a@x", fresh=True)

    def test_limiter_retry_after_counts_from_the_oldest_scan(self, monkeypatch):
        clock = FakeClock().install(monkeypatch)
        limiter = ui.ScanLimiter(limit=2, window_s=60)
        limiter.acquire("u")
        clock.advance(20)
        limiter.acquire("u")
        clock.advance(10)
        with pytest.raises(ui.ScanRateLimited) as exc:
            limiter.acquire("u")
        assert exc.value.retry_after_s == 30


class TestRoute:
    def _url(self, bid, vid, catalog=None, **extra):
        url = f"/api/businesses/{bid}/versions/{vid}/uninstall-impact"
        query = ({"catalog": catalog} if catalog is not None else {}) | extra
        return url + ("?" + "&".join(f"{k}={v}" for k, v in query.items()) if query else "")

    @staticmethod
    def _agent_catalog(engine, catalog=CATALOG):
        with Session(engine) as s:
            s.add(AgentConfig(deployment_catalog=catalog, warehouse_id="wh-1"))
            s.commit()

    def test_shape_and_default_catalog_where_the_version_was_installed(self, client, engine, mock_ws):
        self._agent_catalog(engine, "metamodel_cat")
        bid, vid = _seed(engine)
        _standard_catalog().install(mock_ws)
        r = client.get(self._url(bid, vid))
        assert r.status_code == 200, r.text
        body = r.json()
        assert set(body) == {
            "version_id", "catalog", "schemas", "has_data", "truncated", "reasons",
            "installed_catalogs",
        }
        assert body["catalog"] == CATALOG and body["has_data"] == "yes"
        assert body["installed_catalogs"] == [CATALOG]
        assert set(body["schemas"][0]) == {
            "name", "owner", "shared", "objects_listed", "tables", "views", "volumes",
            "other_versions",
        }
        assert set(body["schemas"][0]["tables"][0]) == {"name", "kind", "has_data"}

    def test_default_catalog_from_the_agent_config_when_never_installed(self, client, engine, mock_ws):
        self._agent_catalog(engine)
        bid, vid = _seed(engine, uc_catalog="", deployment_status="uninstalled")
        _standard_catalog().install(mock_ws)
        r = client.get(self._url(bid, vid))
        assert r.status_code == 200, r.text
        assert r.json()["catalog"] == CATALOG
        assert r.json()["installed_catalogs"] == []

    def test_explicit_catalog_is_lowercased(self, client, engine, mock_ws):
        self._agent_catalog(engine, "metamodel_cat")
        bid, vid = _seed(engine, uc_catalog="")
        _standard_catalog().install(mock_ws)
        r = client.get(self._url(bid, vid, "WT_Catalog"))
        assert r.status_code == 200, r.text
        assert r.json()["catalog"] == CATALOG
        mock_ws.schemas.list.assert_called_with(catalog_name=CATALOG)

    def test_cataloging_style_is_passed_through(self, client, engine, mock_ws):
        self._agent_catalog(engine)
        bid, vid = _seed(engine, domains=("inventory",))
        _standard_catalog().install(mock_ws)
        r = client.get(self._url(bid, vid, cataloging_style="Catalog per Domain"))
        assert r.status_code == 200, r.text
        assert r.json()["has_data"] == "unknown"
        bad = client.get(self._url(bid, vid, cataloging_style="Elsewhere"))
        assert bad.status_code == 422, bad.text

    def test_no_catalog_is_422(self, client, engine, mock_ws):
        self._agent_catalog(engine, "")
        bid, vid = _seed(engine, uc_catalog="")
        r = client.get(self._url(bid, vid))
        assert r.status_code == 422, r.text
        assert "No catalog is configured" in r.json()["detail"]["message"]
        mock_ws.schemas.list.assert_not_called()

    @pytest.mark.parametrize("bad", ["a.b", "1abc", "a-b", "x", "_x", "a" * 256])
    def test_a_catalog_the_uninstall_would_refuse_is_422_with_a_message(self, client, engine, mock_ws, bad):
        self._agent_catalog(engine)
        bid, vid = _seed(engine)
        r = client.get(self._url(bid, vid, bad))
        assert r.status_code == 422, r.text
        detail = r.json()["detail"]
        assert isinstance(detail, dict) and "Unity Catalog name" in detail["message"]
        mock_ws.schemas.list.assert_not_called()

    def test_version_of_another_business_is_404(self, client, engine, mock_ws):
        _, vid = _seed(engine)
        r = client.get(self._url("other-business", vid))
        assert r.status_code == 404, r.text

    def test_rate_limited_is_429_with_retry_after(self, client, engine, mock_ws):
        self._agent_catalog(engine)
        bid, vid = _seed(engine)
        _standard_catalog().install(mock_ws)
        for _ in range(ui.SCANS_PER_USER):
            ui.IMPACT_CACHE.clear()
            assert client.get(self._url(bid, vid)).status_code == 200
        assert client.get(self._url(bid, vid)).status_code == 200
        ui.IMPACT_CACHE.clear()
        r = client.get(self._url(bid, vid))
        assert r.status_code == 429, r.text
        retry = r.json()["detail"]["retry_after_s"]
        assert r.headers["Retry-After"] == str(retry)
        assert "Try again in" in r.json()["detail"]["message"]

    def test_viewer_is_refused_before_any_scan(self, client, engine, mock_ws, monkeypatch):
        monkeypatch.setattr(_roles_mod, "RBAC_ENABLED", True)
        viewer_ws = MagicMock()
        user = MagicMock()
        user.groups = []
        viewer_ws.users.list.return_value = [user]
        client.app.state.workspace_client = viewer_ws
        bid, vid = _seed(engine)
        r = client.get(self._url(bid, vid), headers={"X-Forwarded-Email": "viewer@example.com"})
        assert r.status_code == 403, r.text
        mock_ws.schemas.list.assert_not_called()


class TestBudgetConstants:
    def test_minimum_statement_time_covers_one_poll(self):
        from vibe_modeling.backend.core import _sql

        assert ui._MIN_STATEMENT_S == ui._POLL_INTERVAL_S + _sql._FIRST_READ_ESTIMATE_S == 7.0

    def test_a_chunk_is_not_started_with_less_than_seven_seconds_left(self, engine, monkeypatch):
        clock = FakeClock().install(monkeypatch)
        _, vid = _seed(engine, domains=("customer",))
        fake = _FakeCatalog(clock).schema("ecm_customer").add("ecm_customer", "t", rows=0)
        ws = fake.install(MagicMock())
        real_execute = fake._execute

        def _slow_listing(**kw):
            out = real_execute(**kw)
            if "information_schema" in kw["statement"]:
                clock.advance(ui.IMPACT_BUDGET_S - 6.9)
            return out

        ws.statement_execution.execute_statement.side_effect = _slow_listing
        impact = _impact(engine, ws, vid)
        assert fake.check_sql == []
        assert impact.truncated is True and impact.has_data == "unknown"

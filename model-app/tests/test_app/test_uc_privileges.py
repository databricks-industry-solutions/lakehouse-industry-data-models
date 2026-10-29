"""core/_uc_privileges: the one effective-privileges reader, the app's catalog
capability, the run rule (shared fixture with the UI), and the bounded,
positive-only cached capability route (design 4.1, review M4)."""

from __future__ import annotations

import json
import threading
from pathlib import Path
from types import SimpleNamespace as NS
from unittest.mock import MagicMock

import pytest
from databricks.sdk.errors.platform import NotFound, PermissionDenied, ResourceDoesNotExist

from vibe_modeling.backend.core import _app_identity as ident
from vibe_modeling.backend.core import _uc_privileges as up
from vibe_modeling.backend.core._uc_privileges import (
    CatalogCapability,
    app_catalog_capabilities,
    catalog_capability,
    catalog_usable,
    covers,
    missing_privileges,
    run_creates_schemas,
)

FIXTURE = json.loads((Path(__file__).parents[1] / "fixtures" / "catalog_capability_rule_fixture.json").read_text())
SP = "app-sp-1"
GROUPS = frozenset({"vibe-app-group"})
FULL_SCHEMA = {"USE_SCHEMA", "CREATE_TABLE", "MODIFY", "SELECT"}


@pytest.fixture(autouse=True)
def _fresh_cache(monkeypatch):
    up.clear_capability_cache()
    monkeypatch.setattr(up, "app_application_id", lambda ws: SP)
    monkeypatch.setattr(up, "app_group_names", lambda ws: GROUPS)
    monkeypatch.setattr(up, "_CHECK_WS", None)
    monkeypatch.setattr(ident, "_APP_ID_CACHE", {})
    monkeypatch.setattr(ident, "_APP_GROUPS_CACHE", {})
    yield
    up.clear_capability_cache()


def _eff(privs):
    return NS(privilege_assignments=[NS(principal=SP, privileges=[NS(privilege=NS(value=p)) for p in privs])])


def fake_ws(effective: dict, owners: dict | None = None) -> MagicMock:
    """``effective`` maps a full name to a privilege set or an exception; a
    missing key is NotFound. ``owners`` maps a full name to its owner."""
    owners = owners or {}
    ws = MagicMock()

    def get_effective(securable_type, full_name, principal=None):
        assert principal == SP
        v = effective.get(full_name, NotFound(f"{full_name} does not exist"))
        if isinstance(v, Exception):
            raise v
        return _eff(v)

    def owner_of(full_name):
        if full_name not in effective:
            raise NotFound(full_name)
        return NS(owner=owners.get(full_name, "someone@example.com"))

    ws.grants.get_effective.side_effect = get_effective
    ws.catalogs.get.side_effect = owner_of
    ws.schemas.get.side_effect = owner_of
    ws.volumes.read.side_effect = owner_of
    return ws


def ready(catalog="c", **over):
    """A catalog where the app can do everything."""
    eff = {catalog: {"USE_CATALOG", "CREATE_SCHEMA"}, f"{catalog}._metamodel": FULL_SCHEMA,
           f"{catalog}._metamodel.vol_root": {"READ_VOLUME", "WRITE_VOLUME"}}
    eff.update(over)
    return eff


# --- covers / missing_privileges (the ALL_PRIVILEGES rule) ---


@pytest.mark.parametrize("privs,needed,expected", [
    ({"USE_CATALOG", "CREATE_SCHEMA"}, {"USE_CATALOG", "CREATE_SCHEMA"}, True),
    ({"USE_CATALOG", "CREATE_SCHEMA", "BROWSE"}, {"USE_CATALOG"}, True),
    ({"USE_CATALOG"}, {"USE_CATALOG", "CREATE_SCHEMA"}, False),
    ({"ALL_PRIVILEGES"}, {"USE_CATALOG", "CREATE_SCHEMA"}, True),
    (set(), {"USE_SCHEMA"}, False),
    (set(), set(), True),
])
def test_covers_matrix(privs, needed, expected):
    assert covers(privs, needed) is expected
    assert (not missing_privileges(privs, needed)) is expected


def test_missing_privileges_names_only_the_gap():
    assert missing_privileges({"USE_SCHEMA"}, ["USE_SCHEMA", "SELECT", "MODIFY"]) == {"SELECT", "MODIFY"}
    assert missing_privileges({"ALL_PRIVILEGES"}, ["SELECT"]) == set()


def test_effective_privileges_drops_assignments_without_a_privilege():
    ws = MagicMock()
    ws.grants.get_effective.return_value = NS(privilege_assignments=[
        NS(principal="account users", privileges=[NS(privilege=None), NS(privilege=NS(value="BROWSE"))])])
    assert up.effective_privileges(ws, "catalog", "c", SP) == {"BROWSE"}


# --- catalog_capability ---


def test_full_access():
    cap = catalog_capability(fake_ws(ready()), "c", SP)
    assert cap == CatalogCapability(create_schema=True, use_metamodel=True)


def test_all_privileges_on_the_catalog_covers_the_catalog_check():
    cap = catalog_capability(fake_ws(ready(c={"ALL_PRIVILEGES"})), "c", SP)
    assert cap.create_schema is True


def test_no_create_schema_with_a_usable_metamodel():
    """The Dry Run case: _metamodel pre-created by an admin, schema-level grants only."""
    cap = catalog_capability(fake_ws(ready(c={"USE_CATALOG"})), "c", SP)
    assert cap.create_schema is False and cap.use_metamodel is True
    assert cap.create_schema_fix == "GRANT CREATE SCHEMA ON CATALOG `c` TO `app-sp-1`;"
    assert cap.use_metamodel_fix == ""


def test_no_use_catalog_blocks_both():
    cap = catalog_capability(fake_ws(ready(c={"BROWSE"})), "c", SP)
    assert cap.create_schema is False and cap.use_metamodel is False
    assert cap.create_schema_fix == "GRANT CREATE SCHEMA, USE CATALOG ON CATALOG `c` TO `app-sp-1`;"
    assert cap.use_metamodel_fix == "GRANT USE CATALOG ON CATALOG `c` TO `app-sp-1`;"


def test_catalog_ownership_counts_as_all_privileges():
    """get_effective reports no privileges for an owner (live read, 2026-10-23)."""
    ws = fake_ws(ready(c=set()), owners={"c": SP})
    assert catalog_capability(ws, "c", SP).create_schema is True


def test_owned_metamodel_without_grants_is_usable():
    """The app creates _metamodel and vol_root, so it owns them and holds no grants there."""
    eff = ready(**{"c._metamodel": set(), "c._metamodel.vol_root": set()})
    ws = fake_ws(eff, owners={"c._metamodel": SP, "c._metamodel.vol_root": SP})
    assert catalog_capability(ws, "c", SP).use_metamodel is True


def test_absent_metamodel_follows_create_schema():
    eff = {"c": {"USE_CATALOG", "CREATE_SCHEMA"}}
    assert catalog_capability(fake_ws(eff), "c", SP) == CatalogCapability(create_schema=True, use_metamodel=True)
    eff = {"c": {"USE_CATALOG"}}
    cap = catalog_capability(fake_ws(eff), "c", SP)
    assert cap.create_schema is False and cap.use_metamodel is False
    assert cap.use_metamodel_fix == cap.create_schema_fix == "GRANT CREATE SCHEMA ON CATALOG `c` TO `app-sp-1`;"


def test_metamodel_without_schema_privileges_names_the_schema_grant():
    """The wrong-hint case of fact 3: the gap is on the schema, not the catalog."""
    cap = catalog_capability(fake_ws(ready(**{"c._metamodel": {"USE_SCHEMA"}})), "c", SP)
    assert cap.create_schema is True and cap.use_metamodel is False
    assert cap.use_metamodel_fix == "GRANT CREATE TABLE, MODIFY, SELECT ON SCHEMA `c`.`_metamodel` TO `app-sp-1`;"


def test_volume_without_write_names_the_volume_grant():
    cap = catalog_capability(fake_ws(ready(**{"c._metamodel.vol_root": {"READ_VOLUME"}})), "c", SP)
    assert cap.use_metamodel is False
    assert cap.use_metamodel_fix == "GRANT WRITE VOLUME ON VOLUME `c`.`_metamodel`.`vol_root` TO `app-sp-1`;"


def test_absent_volume_needs_create_volume_on_the_schema():
    eff = ready()
    del eff["c._metamodel.vol_root"]
    ws = fake_ws(eff)
    cap = catalog_capability(ws, "c", SP)
    assert cap.use_metamodel is False
    assert cap.use_metamodel_fix == "GRANT CREATE VOLUME ON SCHEMA `c`.`_metamodel` TO `app-sp-1`;"
    eff["c._metamodel"] = FULL_SCHEMA | {"CREATE_VOLUME"}
    assert catalog_capability(fake_ws(eff), "c", SP).use_metamodel is True


def test_missing_volume_answers_resource_does_not_exist():
    eff = ready(**{"c._metamodel.vol_root": ResourceDoesNotExist("Volume does not exist")})
    eff["c._metamodel"] = FULL_SCHEMA | {"CREATE_VOLUME"}
    ws = fake_ws(eff)
    ws.volumes.read.side_effect = ResourceDoesNotExist("Volume does not exist")
    assert catalog_capability(ws, "c", SP).use_metamodel is True


def test_missing_catalog_is_neither():
    assert catalog_capability(fake_ws({}), "nope", SP) == CatalogCapability(create_schema=False, use_metamodel=False)


def test_unreadable_catalog_is_unchecked():
    cap = catalog_capability(fake_ws({"c": PermissionDenied("no READ METADATA")}), "c", SP)
    assert cap == up.UNCHECKED


def test_unreadable_metamodel_leaves_only_that_field_unchecked():
    cap = catalog_capability(fake_ws(ready(**{"c._metamodel": PermissionDenied("no")})), "c", SP)
    assert cap.create_schema is True and cap.use_metamodel is None


def test_names_with_backticks_are_quoted():
    cap = catalog_capability(fake_ws({"we`ird": {"USE_CATALOG"}}), "we`ird", SP)
    assert cap.create_schema_fix == "GRANT CREATE SCHEMA ON CATALOG `we``ird` TO `app-sp-1`;"


def test_the_check_never_grants():
    ws = fake_ws(ready(c={"BROWSE"}))
    catalog_capability(ws, "c", SP)
    ws.grants.update.assert_not_called()


def test_group_ownership_counts_when_the_group_is_the_apps():
    ws = fake_ws(ready(c=set()), owners={"c": "vibe-app-group"})
    assert catalog_capability(ws, "c", SP, GROUPS).create_schema is True


def test_an_unresolved_group_owner_is_unchecked_not_refused():
    """The app may hold the group through nesting; never a false refusal."""
    ws = fake_ws(ready(c=set()), owners={"c": "data-platform-admins"})
    assert catalog_capability(ws, "c", SP, GROUPS) == up.UNCHECKED
    assert catalog_capability(ws, "c", SP, None) == up.UNCHECKED
    eff = ready(**{"c._metamodel": set()})
    cap = catalog_capability(fake_ws(eff, owners={"c._metamodel": "data-platform-admins"}), "c", SP, GROUPS)
    assert cap.create_schema is True and cap.use_metamodel is None


def test_a_user_or_sp_owner_other_than_the_app_is_a_gap():
    for owner in ("someone@example.com", "0f6c2a8e-1111-4222-8333-444455556666"):
        ws = fake_ws(ready(c={"USE_CATALOG"}), owners={"c": owner})
        assert catalog_capability(ws, "c", SP, GROUPS).create_schema is False


def test_a_known_gap_stays_false_when_a_later_read_fails():
    eff = ready(**{"c._metamodel": {"USE_SCHEMA"}, "c._metamodel.vol_root": PermissionDenied("no")})
    cap = catalog_capability(fake_ws(eff), "c", SP)
    assert cap.use_metamodel is False
    assert cap.use_metamodel_fix == "GRANT CREATE TABLE, MODIFY, SELECT ON SCHEMA `c`.`_metamodel` TO `app-sp-1`;"


def test_an_sdk_retry_timeout_is_an_unreadable_read():
    """The SDK raises the builtin TimeoutError when its retry budget runs out."""
    eff = ready(**{"c._metamodel": {"USE_SCHEMA"}, "c._metamodel.vol_root": TimeoutError("Timed out after 0:00:08")})
    cap = catalog_capability(fake_ws(eff), "c", SP)
    assert cap.use_metamodel is False
    assert cap.use_metamodel_fix == "GRANT CREATE TABLE, MODIFY, SELECT ON SCHEMA `c`.`_metamodel` TO `app-sp-1`;"
    assert catalog_capability(fake_ws({"c": TimeoutError("Timed out")}), "c", SP) == up.UNCHECKED


def test_missing_use_catalog_lists_the_metamodel_grants_too():
    eff = ready(c={"BROWSE"}, **{"c._metamodel": {"USE_SCHEMA"}})
    cap = catalog_capability(fake_ws(eff), "c", SP)
    assert cap.use_metamodel is False
    assert cap.use_metamodel_fix.splitlines() == [
        "GRANT USE CATALOG ON CATALOG `c` TO `app-sp-1`;",
        "GRANT CREATE TABLE, MODIFY, SELECT ON SCHEMA `c`.`_metamodel` TO `app-sp-1`;",
    ]


def test_missing_use_catalog_with_unreadable_metamodel_keeps_the_catalog_grant():
    eff = ready(c={"BROWSE"}, **{"c._metamodel": PermissionDenied("no USE CATALOG")})
    cap = catalog_capability(fake_ws(eff), "c", SP)
    assert cap.use_metamodel is False
    assert cap.use_metamodel_fix == "GRANT USE CATALOG ON CATALOG `c` TO `app-sp-1`;"


# --- The run rule, shared with the UI ---


@pytest.mark.parametrize("case", FIXTURE["creates_schemas"],
                         ids=lambda c: f"{c['intent']}-{c['dry_run']}-{c['cataloging_style']}")
def test_run_creates_schemas_matches_the_fixture(case):
    assert run_creates_schemas(case["intent"], case["dry_run"], case["cataloging_style"]) is case["expected"]


def test_the_fixture_styles_are_the_agent_styles():
    options = json.loads((Path(__file__).parents[1] / "fixtures" / "agent_widget_options.json").read_text())
    agent_styles = options["options"]["cataloging_style"]
    assert up.SINGLE_CATALOG_STYLE == agent_styles[0]
    assert {c["cataloging_style"] for c in FIXTURE["creates_schemas"]} - {""} == set(agent_styles)


@pytest.mark.parametrize("case", FIXTURE["usable"])
def test_catalog_usable_matches_the_fixture(case):
    cap = CatalogCapability(create_schema=case["create_schema"], use_metamodel=case["use_metamodel"])
    assert catalog_usable(cap, creates_schemas=case["creates_schemas"]) is case["expected"]


def test_every_intent_is_in_the_fixture():
    from vibe_modeling.backend.models import Intent
    assert {i.value for i in Intent} <= {c["intent"] for c in FIXTURE["creates_schemas"]}


# --- app_catalog_capabilities: cap, pool, timeout, positive-only cache ---


def caps_of(ws, names):
    """``app_catalog_capabilities`` with ``ws`` as the check client (the fixture restores it)."""
    up._CHECK_WS = ws
    return app_catalog_capabilities(names)


def test_dedupes_and_keeps_request_order():
    ws = fake_ws({**ready("a"), **ready("b")})
    out = caps_of(ws, ["b", " a ", "b", "", "a"])
    assert [n for n, _ in out] == ["b", "a"]


def test_cap_leaves_the_rest_unchecked():
    names = [f"c{i}" for i in range(up.CAPABILITY_CHECK_CAP + 3)]
    eff = {}
    for n in names:
        eff.update(ready(n))
    ws = fake_ws(eff)
    out = dict(caps_of(ws, names))
    assert len(out) == len(names)
    checked = {fa.args[1] for fa in ws.grants.get_effective.call_args_list if fa.args[0] == "catalog"}
    assert checked == set(names[:up.CAPABILITY_CHECK_CAP])
    for n in names[up.CAPABILITY_CHECK_CAP:]:
        assert out[n] == up.UNCHECKED


def test_positive_results_are_cached():
    ws = fake_ws(ready())
    caps_of(ws, ["c"])
    assert up.cached_positive("c")
    calls = ws.grants.get_effective.call_count
    assert caps_of(ws, ["c"]) == [("c", CatalogCapability(True, True))]
    assert ws.grants.get_effective.call_count == calls


def test_negative_results_are_never_cached():
    """A grant the message asked for takes effect on the next check (M4)."""
    eff = ready(c={"USE_CATALOG"})
    ws = fake_ws(eff)
    assert dict(caps_of(ws, ["c"]))["c"].create_schema is False
    assert not up.cached_positive("c")
    eff["c"] = {"USE_CATALOG", "CREATE_SCHEMA"}
    assert dict(caps_of(ws, ["c"]))["c"].create_schema is True


def test_partial_results_are_not_cached():
    ws = fake_ws(ready(**{"c._metamodel": PermissionDenied("no")}))
    caps_of(ws, ["c"])
    assert not up.cached_positive("c")


def test_positive_cache_expires(monkeypatch):
    ws = fake_ws(ready())
    caps_of(ws, ["c"])
    now = up.time.monotonic()
    monkeypatch.setattr(up.time, "monotonic", lambda: now + up.POSITIVE_TTL_SECONDS + 1)
    assert not up.cached_positive("c")


def test_a_slow_check_comes_back_unchecked(monkeypatch):
    monkeypatch.setattr(up, "CAPABILITY_TIMEOUT_SECONDS", 0.2)
    release = threading.Event()
    eff = {**ready("fast"), **ready("slow")}
    ws = fake_ws(eff)
    inner = ws.grants.get_effective.side_effect

    def slow(securable_type, full_name, principal=None):
        if full_name.startswith("slow"):
            release.wait(5)
        return inner(securable_type, full_name, principal=principal)

    ws.grants.get_effective.side_effect = slow
    try:
        out = dict(caps_of(ws, ["fast", "slow"]))
    finally:
        release.set()
    assert out["fast"] == CatalogCapability(True, True)
    assert out["slow"] == up.UNCHECKED


def test_an_unexpected_error_is_unchecked():
    ws = fake_ws(ready())
    ws.grants.get_effective.side_effect = RuntimeError("boom")
    assert caps_of(ws, ["c"]) == [("c", up.UNCHECKED)]


def test_the_check_client_has_short_budgets(monkeypatch):
    built = []
    monkeypatch.setattr(up, "short_budget_workspace_client", lambda http, retry: built.append((http, retry)) or object())
    client = up.capability_workspace_client()
    assert built == [(up.CHECK_HTTP_TIMEOUT_SECONDS, up.CHECK_RETRY_TIMEOUT_SECONDS)]
    assert up.CHECK_HTTP_TIMEOUT_SECONDS + up.CHECK_RETRY_TIMEOUT_SECONDS <= up.CAPABILITY_TIMEOUT_SECONDS
    assert up.capability_workspace_client() is client
    assert len(built) == 1


def test_short_budget_workspace_client_passes_both_budgets(monkeypatch):
    from vibe_modeling.backend import _workspace_clients as wc
    config_cls, ws_cls = MagicMock(), MagicMock()
    monkeypatch.setattr(wc, "Config", config_cls)
    monkeypatch.setattr(wc, "WorkspaceClient", ws_cls)
    assert wc.short_budget_workspace_client(6, 8) is ws_cls.return_value
    config_cls.assert_called_once_with(http_timeout_seconds=6, retry_timeout_seconds=8)
    ws_cls.assert_called_once_with(config=config_cls.return_value)


def test_a_positive_expiring_mid_call_does_not_need_a_client(monkeypatch):
    """The cache is read once per call (a TTL boundary used to leave ``ws`` unbound)."""
    answers = iter([True, False, False, False])
    monkeypatch.setattr(up, "cached_positive", lambda name: next(answers))

    def no_client():
        raise AssertionError("no check should run")

    monkeypatch.setattr(up, "capability_workspace_client", no_client)
    assert app_catalog_capabilities(["c"]) == [("c", CatalogCapability(True, True))]


def test_no_check_client_means_unchecked(monkeypatch):
    up._remember("cached", CatalogCapability(True, True))

    def broken():
        raise ValueError("default auth: cannot configure default credentials")

    monkeypatch.setattr(up, "capability_workspace_client", broken)
    assert app_catalog_capabilities(["cached", "c"]) == [("cached", CatalogCapability(True, True)), ("c", up.UNCHECKED)]


def test_the_cap_is_the_fixture_cap():
    assert up.CAPABILITY_CHECK_CAP == FIXTURE["check_cap"]


def test_unknown_app_identity_checks_nothing(monkeypatch):
    monkeypatch.setattr(up, "app_application_id", lambda ws: "")
    ws = fake_ws(ready())
    assert caps_of(ws, ["c"]) == [("c", up.UNCHECKED)]
    ws.grants.get_effective.assert_not_called()


# --- Routes ---


def test_list_catalogs_never_checks_privileges(client, mock_ws):
    mock_ws.catalogs.list.return_value = [NS(name="b", comment=None, owner="o"), NS(name="a", comment="x", owner=None)]
    resp = client.get("/api/catalogs")
    assert resp.status_code == 200
    assert resp.json() == [
        {"name": "b", "comment": "", "owner": "o", "can_create_schema": None},
        {"name": "a", "comment": "x", "owner": "", "can_create_schema": None},
    ]
    mock_ws.grants.get_effective.assert_not_called()


def test_list_catalogs_fills_can_create_schema_from_the_positive_cache(client, mock_ws):
    up._remember("a", CatalogCapability(True, True))
    mock_ws.catalogs.list.return_value = [NS(name="a", comment=None, owner=None), NS(name="b", comment=None, owner=None)]
    resp = client.get("/api/catalogs")
    assert resp.status_code == 200
    assert [c["can_create_schema"] for c in resp.json()] == [True, None]


def test_capabilities_route(client, mock_ws):
    eff = ready("good")
    eff["dry"] = {"USE_CATALOG"}
    eff.update({"dry._metamodel": FULL_SCHEMA, "dry._metamodel.vol_root": {"READ_VOLUME", "WRITE_VOLUME"}})
    up._CHECK_WS = fake_ws(eff)
    resp = client.get("/api/catalogs/capabilities", params=[("names", "good"), ("names", "dry"), ("names", "gone")])
    assert resp.status_code == 200
    assert resp.json() == [
        {"name": "good", "create_schema": True, "use_metamodel": True, "create_schema_fix": "", "use_metamodel_fix": ""},
        {"name": "dry", "create_schema": False, "use_metamodel": True,
         "create_schema_fix": "GRANT CREATE SCHEMA ON CATALOG `dry` TO `app-sp-1`;", "use_metamodel_fix": ""},
        {"name": "gone", "create_schema": False, "use_metamodel": False, "create_schema_fix": "", "use_metamodel_fix": ""},
    ]
    up._CHECK_WS.grants.update.assert_not_called()
    mock_ws.grants.get_effective.assert_not_called()


def test_capabilities_route_without_names_is_empty(client, mock_ws):
    resp = client.get("/api/catalogs/capabilities")
    assert resp.status_code == 200
    assert resp.json() == []


# --- core/_app_identity.app_group_names ---


def test_app_group_names_reads_and_caches_the_apps_groups():
    ws = MagicMock()
    ws.current_user.me.return_value = NS(user_name=SP, groups=[NS(display="g1"), NS(display="g2"), NS(display=None)])
    assert ident.app_group_names(ws) == frozenset({"g1", "g2"})
    ws.current_user.me.side_effect = RuntimeError("down")
    assert ident.app_group_names(ws) == frozenset({"g1", "g2"})


def test_app_group_names_expire_after_the_ttl(monkeypatch):
    ws = MagicMock()
    ws.current_user.me.return_value = NS(user_name=SP, groups=[NS(display="g1")])
    assert ident.app_group_names(ws) == frozenset({"g1"})
    now = ident.time.monotonic()
    monkeypatch.setattr(ident.time, "monotonic", lambda: now + ident.GROUPS_TTL_SECONDS + 1)
    ws.current_user.me.return_value = NS(user_name=SP, groups=[NS(display="g2")])
    assert ident.app_group_names(ws) == frozenset({"g2"})
    assert ident.GROUPS_TTL_SECONDS == up.POSITIVE_TTL_SECONDS


def test_app_application_id_and_groups_share_one_me_call():
    ws = MagicMock()
    ws.current_user.me.return_value = NS(user_name=SP, groups=[NS(display="g1")])
    assert ident.app_application_id(ws) == SP
    assert ident.app_group_names(ws) == frozenset({"g1"})
    assert ws.current_user.me.call_count == 1


def test_app_group_names_is_none_on_error_and_not_cached():
    ws = MagicMock()
    ws.current_user.me.side_effect = PermissionDenied("no")
    assert ident.app_group_names(ws) is None
    ws.current_user.me.side_effect = None
    ws.current_user.me.return_value = NS(user_name=SP, groups=[])
    assert ident.app_group_names(ws) == frozenset()

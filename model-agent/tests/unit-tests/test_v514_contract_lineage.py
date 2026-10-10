"""v5.1.4 contract: decision 10A (head = latest completed non-dry-run version, stale scoped runs refused)
and K3 (model.json `lineage` block for every run).

Behavioral tests drive step_setup_and_clean against a fake `_metamodel.business` registry that honours the
SQL the agent sends (deploy_status filter, DESCRIBE TABLE column check), the fence's refresh_stale_base,
the serialize gate and step_generate_data_model_json. Every test fails on 56ce1eb (dry runs counted as head,
stale scoped runs only warned, no lineage block) and passes on this version.
"""
import copy
import json
import re
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent))
import conftest  # noqa: F401,E402
import agent_helpers as ah  # noqa: E402
import test_v514_vibe_scope_parse as PS  # noqa: E402
import test_v514_vibe_scope_passes as P  # noqa: E402

RAW = PS.RAW
VOV = PS.VOV
NEW_BASE = PS.NEW_BASE
NOT_DRY_RUN = "LOWER(deploy_status) <> 'dry_run'"


@pytest.fixture(autouse=True)
def _isolate_runtime():
    pinned = set(ah._USER_PINNED_DOMAINS_RUNTIME)
    ah.set_vibe_scope_runtime(None)
    yield
    ah.set_vibe_scope_runtime(None)
    ah._USER_PINNED_DOMAINS_RUNTIME.clear()
    ah._USER_PINNED_DOMAINS_RUNTIME.update(pinned)


class _Rows:
    def __init__(self, rows):
        self.rows = rows

    def collect(self):
        return list(self.rows)


class _Registry:
    """Fake `<catalog>._metamodel.business`: answers the queries step_setup_and_clean sends."""

    def __init__(self, rows, has_deploy_status=True):
        self.rows = [dict(r) for r in rows]
        self.has_deploy_status = has_deploy_status
        self.queries = []

    def describe(self):
        cols = ["business", "version", "model_scope", "completed_percent", "completion_date", "location"]
        return [(c, "string", None) for c in cols + (["deploy_status"] if self.has_deploy_status else [])]

    def registered(self):
        return [PS._Row(version=r["version"]) for r in self.rows if r.get("registered", True)]

    def _installed(self, query):
        rows = [r for r in self.rows if r.get("completed_percent", 100.0) == 100.0]
        if NOT_DRY_RUN in query:
            rows = [r for r in rows if r.get("deploy_status") is None or str(r["deploy_status"]).lower() != "dry_run"]
        return rows

    def __call__(self, query):
        q = " ".join(query.split())
        self.queries.append(q)
        if "deploy_status" in q and not self.has_deploy_status:
            raise RuntimeError("[UNRESOLVED_COLUMN] deploy_status")
        if q.startswith("SELECT version FROM") and "ORDER BY TRY_CAST(version AS DOUBLE) DESC NULLS LAST, completion_date DESC NULLS LAST" in q:
            rows = sorted(self._installed(q), key=lambda r: (float(r["version"]), r["completion_date"]), reverse=True)
            return [PS._Row(version=r["version"]) for r in rows]
        if q.startswith("SELECT version,"):
            return [PS._Row(version=r["version"], deploy_status=r.get("deploy_status"), location=r.get("location"))
                    for r in self._installed(q)]
        if "SELECT model_conventions FROM" in q:
            return [PS._Row(model_conventions=json.dumps(RAW["model"]["model_conventions"]))]
        match = re.search(r"version = '([^']+)'", q)
        version = match.group(1) if match else ""
        known = {r["version"]: r for r in self.rows}
        if "SELECT completed_percent FROM" in q:
            return [PS._Row(completed_percent=known[version].get("completed_percent", 100.0))] if version in known else []
        if "COUNT(*) as cnt" in q:
            if q.split("FROM", 1)[1].split()[0].endswith(".business"):
                return [PS._Row(cnt=1 if version in known else 0)]
            return [PS._Row(cnt=5)]
        return []


class _RegistrySpark:
    def __init__(self, registry):
        self.registry = registry
        self.catalog = PS._Catalog(True)

    def sql(self, query):
        if query.strip().upper().startswith("DESCRIBE"):
            return _Rows(self.registry.describe())
        if ".`domain`" in query:
            self.registry.queries.append(" ".join(query.split()))
            return _Rows(self.registry.registered())
        return _Rows([])


def _row(version, deploy_status="installed", day=None, location=None, registered=True):
    return {"version": str(version), "deploy_status": deploy_status, "completed_percent": 100.0,
            "completion_date": day if day is not None else int(version), "location": location, "registered": registered}


def _setup(monkeypatch, wv, registry):
    monkeypatch.setitem(ah.__dict__, "execute_sql", lambda spark, q, logger=None: registry(q))
    monkeypatch.setitem(ah.__dict__, "_ensure_catalog_exists", PS._stop)
    wv["spark"] = _RegistrySpark(registry)
    with pytest.raises(PS._StopAfterBranching):
        ah.step_setup_and_clean(wv)
    return wv


def _latest(monkeypatch, registry):
    monkeypatch.setitem(ah.__dict__, "execute_sql", lambda spark, q, logger=None: registry(q))
    wv = PS._vov_widgets(scope=None)
    captured = {}

    def _stop_and_capture(*_a, **_k):
        captured["probe"] = wv.get("_run_lineage_probe")
        raise PS._StopAfterBranching()

    monkeypatch.setitem(ah.__dict__, "_ensure_catalog_exists", _stop_and_capture)
    wv["spark"] = _RegistrySpark(registry)
    with pytest.raises(PS._StopAfterBranching):
        ah.step_setup_and_clean(wv)
    return captured["probe"]()


def test_head_excludes_a_newer_dry_run(monkeypatch):
    registry = _Registry([_row(1), _row(2, "dry_run")])
    assert _latest(monkeypatch, registry) == "1"
    assert any(NOT_DRY_RUN in q for q in registry.queries if q.startswith("SELECT version FROM"))


def test_head_counts_a_null_deploy_status_as_installed(monkeypatch):
    registry = _Registry([_row(1), _row(2, None)])
    assert _latest(monkeypatch, registry) == "2"


def test_head_on_a_registry_without_deploy_status_keeps_every_completed_row(monkeypatch):
    registry = _Registry([_row(1), _row(2, None)], has_deploy_status=False)
    assert _latest(monkeypatch, registry) == "2"
    assert not any("deploy_status" in q for q in registry.queries)


def test_scoped_vov_is_refused_at_setup_when_a_newer_head_exists(monkeypatch):
    wv = PS._vov_widgets()
    registry = _Registry([_row(1), _row(2), _row(3)])
    monkeypatch.setitem(ah.__dict__, "execute_sql", lambda spark, q, logger=None: registry(q))
    monkeypatch.setitem(ah.__dict__, "_ensure_catalog_exists", PS._stop)
    wv["spark"] = _RegistrySpark(registry)
    with pytest.raises(ValueError) as exc:
        ah.step_setup_and_clean(wv)
    message = str(exc.value)
    assert "vibe_scope run refused at setup" in message
    assert "base v1" in message and "v3" in message
    assert ah.get_vibe_scope_runtime() is None


def test_scoped_vov_on_the_head_with_a_newer_dry_run_draft_is_not_stale(monkeypatch):
    wv = _setup(monkeypatch, PS._vov_widgets(), _Registry([_row(1), _row(2, "dry_run")]))
    assert wv["_vibe_scope_stale_base"]["stale"] is False
    assert wv["_vibe_scope_stale_base"]["latest_completed_version"] == "1"
    assert wv["_run_lineage_start"] == {"base_version": "1", "base_scope": "mvm", "head_at_start": "1", "stale": False, "error": None}


def test_a_newer_dry_run_draft_is_allowed_as_an_explicit_base(monkeypatch):
    wv = PS._vov_widgets()
    wv["model_version"] = "3"
    registry = _Registry([_row(1), _row(2), _row(3, "dry_run")])
    _setup(monkeypatch, wv, registry)
    assert wv["base_version_for_review"] == "3"
    assert wv["_run_lineage_start"]["head_at_start"] == "2" and wv["_run_lineage_start"]["stale"] is False
    assert isinstance(ah.get_vibe_scope_runtime(), ah.VibeScopeFence)


def test_unscoped_vov_on_a_stale_base_is_allowed_and_recorded(monkeypatch):
    wv = _setup(monkeypatch, PS._vov_widgets(scope=None), _Registry([_row(1), _row(2), _row(3)]))
    start = wv["_run_lineage_start"]
    assert start["base_version"] == "1" and start["head_at_start"] == "3" and start["stale"] is True
    assert "_vibe_scope_stale_base" not in wv
    note = next(s for s in wv["_vov_pending_sentinels"] if "[run-lineage FIRED v5.1.4]" in s)
    assert "stale=True" in note and "unscoped run is allowed" in note


def test_default_base_skips_a_newer_dry_run_for_every_run(monkeypatch):
    wv = PS._vov_widgets(scope=None)
    wv["model_version"] = ""
    _setup(monkeypatch, wv, _Registry([_row(1), _row(2, "dry_run")]))
    assert wv["base_version_for_review"] == "1"
    assert wv["current_version"] == "3"
    assert any("[default-base-skips-dry-run FIRED v5.1.4]" in s and "v2 is a Dry Run draft" in s for s in wv["_vov_pending_sentinels"])


def test_default_base_refuses_when_only_dry_runs_exist(monkeypatch):
    wv = PS._vov_widgets(scope=None)
    wv["model_version"] = ""
    registry = _Registry([_row(1, "dry_run")])
    monkeypatch.setitem(ah.__dict__, "execute_sql", lambda spark, q, logger=None: registry(q))
    monkeypatch.setitem(ah.__dict__, "_ensure_catalog_exists", PS._stop)
    wv["spark"] = _RegistrySpark(registry)
    with pytest.raises(ValueError, match=r"newest completed version v1 is a Dry Run draft.*Set '04. Version' to 1"):
        ah.step_setup_and_clean(wv)


def test_explicit_base_needs_no_default_resolution_and_its_head_skips_the_dry_run(monkeypatch):
    wv = _setup(monkeypatch, PS._vov_widgets(scope=None), _Registry([_row(1), _row(2, "dry_run")]))
    assert wv["base_version_for_review"] == "1"
    assert (wv["_run_lineage_start"]["head_at_start"], wv["_run_lineage_start"]["stale"]) == ("1", False)
    assert not any("[default-base-skips-dry-run" in s for s in wv["_vov_pending_sentinels"])


def test_new_base_model_numbering_is_unchanged_by_the_dry_run_filter(monkeypatch):
    wv = PS._widgets(NEW_BASE, "crew")
    _setup(monkeypatch, wv, _Registry([_row(1), _row(2, "dry_run")]))
    assert wv["current_version"] == "3"
    assert wv["_run_lineage_start"]["base_version"] is None and wv["_run_lineage_start"]["head_at_start"] == "1"


def _scoped_fence(probe_values):
    fence = ah.build_vibe_scope_fence(ah.parse_vibe_scope("Some Domains", "crew"), copy.deepcopy(RAW), VOV, P._Log())
    seq = iter(probe_values)
    fence.set_stale_base_probe("1", lambda: next(seq))
    return fence


def test_refresh_stale_base_raises_with_both_versions_when_head_moved():
    fence = _scoped_fence(["1", "4"])
    assert fence.refresh_stale_base(P._Log())["stale"] is False
    with pytest.raises(ah.VibeScopeFenceError) as exc:
        fence.refresh_stale_base(P._Log())
    assert "v4 was completed while this run was working on base v1" in str(exc.value)
    assert exc.value.problems[0]["kind"] == "stale_base"
    assert fence.report()["stale_base"]["stale"] is True and fence.report()["stale_base"]["latest_completed_version"] == "4"


def test_serialize_gate_fails_closed_when_head_moved_during_the_run():
    fence = _scoped_fence(["1", "4"])
    fence.refresh_stale_base(P._Log())
    ah.set_vibe_scope_runtime(fence)
    holder = {}
    m = copy.deepcopy(RAW)
    ah._v337_apply_rename_product(m["model"], "crew", "member", "crew_member")
    with pytest.raises(ah.VibeScopeFenceError, match="v4 was completed while this run was working on base v1"):
        holder["root"], holder["wv"] = P.export_model_json(P._flat(m))
    assert "root" not in holder


def test_failed_stale_gate_records_the_failure_in_the_facts():
    fence = _scoped_fence(["1", "2"])
    fence.refresh_stale_base(P._Log())
    ah.set_vibe_scope_runtime(fence)
    wv = {}
    with pytest.raises(ah.VibeScopeFenceError):
        ah._vibe_scope_serialize_gate(copy.deepcopy(RAW)["model"], wv, P._Log())
    gate = wv["_vibe_scope_facts"]["serialize_gate"]
    assert gate["status"] == "failed" and [v["kind"] for v in gate["violations"]] == ["stale_base"]
    assert wv["_vibe_scope_stale_base"]["stale"] is True


def test_deferred_fence_bind_fails_closed_when_head_moved_after_setup(monkeypatch):
    registry = _Registry([_row(1)])
    wv = PS._vov_widgets(with_model=False)
    _setup(monkeypatch, wv, registry)
    assert ah.get_vibe_scope_runtime() is None and wv["_run_lineage_start"]["stale"] is False
    registry.rows.append(_row(2))
    flat = ah.model_to_widgets_flat(RAW)
    initial_model = ah.widgets_flat_to_model(*flat, agent_version=ah.__AGENT_VERSION__)
    with pytest.raises(ah.VibeScopeFenceError, match="v2 was completed while this run was working on base v1"):
        ah._vibe_scope_bind_engine_baseline(wv, initial_model, P._Log())


def _export(extra, operation=VOV):
    return P.export_model_json(P._flat(copy.deepcopy(RAW)), operation=operation, extra=extra)


def test_model_json_lineage_block_for_an_unscoped_run_on_the_head():
    root, _wv = _export({"_run_lineage_start": {"base_version": "1", "base_scope": "mvm", "head_at_start": "1", "stale": False, "error": None},
                         "_run_lineage_probe": lambda: "1"})
    assert root["lineage"] == {"base_version": "1", "base_scope": "mvm", "output_version": "2", "operation": VOV,
                               "vibe_scope": {"mode": "all", "entries": []}, "head_at_start": "1", "head_at_write": "1",
                               "stale": False, "intervening_versions": []}
    keys = list(root)
    assert keys.index("lineage") < keys.index("model_requirements")


def test_model_json_lineage_block_without_setup_state_falls_back_to_the_widgets():
    root, _wv = _export({})
    lineage = root["lineage"]
    assert (lineage["base_version"], lineage["base_scope"], lineage["head_at_start"], lineage["head_at_write"], lineage["stale"]) == \
        ("1", "mvm", None, None, False)


def test_model_json_lineage_block_for_a_new_base_model():
    root, _wv = _export({"_run_lineage_start": {"base_version": None, "base_scope": None, "head_at_start": "4", "stale": False, "error": None},
                         "_run_lineage_probe": lambda: "4", "current_version": "5"}, operation=NEW_BASE)
    lineage = root["lineage"]
    assert lineage["base_version"] is None and lineage["output_version"] == "5" and lineage["operation"] == NEW_BASE
    assert lineage["stale"] is False and lineage["intervening_versions"] == [] and lineage["head_at_write"] == "4"


def _write_model(tmp_path, version, scope_entries=None, change_domain=None):
    root = copy.deepcopy(RAW)
    if change_domain:
        next(d for d in root["model"]["domains"] if d["name"] == change_domain)["description"] = f"changed in v{version}"
    if scope_entries is not None:
        root["_vibe_scope"] = {"mode": "domains", "entries": list(scope_entries)}
    folder = tmp_path / f"v{version}"
    folder.mkdir()
    (folder / "model.json").write_text(json.dumps(root))
    return str(folder)


def test_model_json_lineage_lists_intervening_versions_for_an_unscoped_stale_run(monkeypatch, tmp_path):
    rows = {2: {"deploy_status": "installed", "location": _write_model(tmp_path, 2, ["crew"], "crew")},
            3: {"deploy_status": None, "location": _write_model(tmp_path, 3, None, "fleet")},
            5: {"deploy_status": "installed", "location": str(tmp_path / "missing")}}
    monkeypatch.setitem(ah.__dict__, "_run_lineage_registry_versions", lambda spark, table, business, scope: dict(rows))
    root, _wv = _export({"_run_lineage_start": {"base_version": "1", "base_scope": "mvm", "head_at_start": "3", "stale": True, "error": None},
                         "_run_lineage_probe": lambda: "3", "spark": object(), "business_context_raw": copy.deepcopy(RAW)})
    lineage = root["lineage"]
    assert lineage["stale"] is True and lineage["head_at_write"] == "3"
    assert lineage["intervening_versions"] == [
        {"version": "2", "deploy_status": "installed", "scope_entries": ["crew"], "changed_domains": ["crew"]},
        {"version": "3", "deploy_status": None, "scope_entries": [], "changed_domains": ["fleet"]},
    ]


def test_registry_versions_exclude_dry_runs_and_tolerate_a_legacy_registry(monkeypatch):
    registry = _Registry([_row(1), _row(2, "dry_run", location="/v2"), _row(3, None, location="/v3")])
    monkeypatch.setitem(ah.__dict__, "execute_sql", lambda spark, q, logger=None: registry(q))
    got = ah._run_lineage_registry_versions(_RegistrySpark(registry), "c._metamodel.business", "Airlines", "mvm")
    assert sorted(got) == [1, 3] and got[3] == {"deploy_status": None, "location": "/v3"}
    legacy = _Registry([_row(1), _row(2, None)], has_deploy_status=False)
    monkeypatch.setitem(ah.__dict__, "execute_sql", lambda spark, q, logger=None: legacy(q))
    got = ah._run_lineage_registry_versions(_RegistrySpark(legacy), "c._metamodel.business", "Airlines", "mvm")
    assert sorted(got) == [1, 2] and got[2]["deploy_status"] is None


def _must_not_probe():
    raise AssertionError("a scoped run reuses the head the serialize gate just refreshed")


def test_model_json_lineage_for_a_scoped_run_uses_the_gate_head_and_the_scope():
    fence = ah.build_vibe_scope_fence(ah.parse_vibe_scope("Some Domains", "crew"), copy.deepcopy(RAW), VOV, P._Log())
    fence.set_stale_base_probe("1", lambda: "1")
    fence.refresh_stale_base(P._Log())
    ah.set_vibe_scope_runtime(fence)
    m = copy.deepcopy(RAW)
    ah._v337_apply_rename_product(m["model"], "crew", "member", "crew_member")
    root, wv = P.export_model_json(P._flat(m), extra={
        "_vibe_scope_spec": ah.parse_vibe_scope("Some Domains", "crew"),
        "_run_lineage_start": {"base_version": "1", "base_scope": "mvm", "head_at_start": "1", "stale": False, "error": None},
        "_run_lineage_probe": _must_not_probe})
    lineage = root["lineage"]
    assert lineage["vibe_scope"] == {"mode": "domains", "entries": ["crew"]}
    assert lineage["head_at_write"] == "1" and lineage["stale"] is False
    assert wv["_vibe_scope_stale_base"]["checks"] == 2
    assert list(root).index("_vibe_scope") < list(root).index("lineage") < list(root).index("model_requirements")


def test_get_widget_values_lets_an_empty_version_reach_the_default_base():
    import ast
    import v514_feedback_util as fu
    tree = ast.parse(fu.nested_main_function("get_widget_values"))
    for node in ast.walk(tree):
        if not isinstance(node, ast.If):
            continue
        test = ast.unparse(node.test)
        sets_exit = any(isinstance(n, ast.Constant) and n.value == "exit_with_warning" for n in ast.walk(ast.Module(body=node.body, type_ignores=[])))
        assert not ("not _eff_version" in test and sets_exit), f"an empty '04. Version' stops the run before the default base resolves: if {test}"


def test_head_is_the_highest_version_even_when_an_older_row_was_touched_later(monkeypatch):
    registry = _Registry([_row(1, day=1), _row(5, day=99), _row(6, day=10), _row(7, "dry_run", day=100)])
    assert _latest(monkeypatch, registry) == "6"


def test_head_skips_a_newer_run_that_never_registered_its_domains(monkeypatch):
    registry = _Registry([_row(1), _row(2, None, registered=False)])
    assert _latest(monkeypatch, registry) == "1"
    assert any(".`domain`" in q for q in registry.queries)


def test_a_scoped_vov_on_the_last_finished_version_is_not_refused_after_a_failed_run(monkeypatch):
    wv = _setup(monkeypatch, PS._vov_widgets(), _Registry([_row(1), _row(2, None, registered=False)]))
    assert wv["_run_lineage_start"]["head_at_start"] == "1" and wv["_run_lineage_start"]["stale"] is False
    assert isinstance(ah.get_vibe_scope_runtime(), ah.VibeScopeFence)
    note = next(s for s in wv["_vov_pending_sentinels"] if "[registry-unregistered-skip FIRED v5.2.7]" in s)
    assert "v2 (mvm)" in note and "not counted as a completed version" in note
    assert sum("[registry-unregistered-skip FIRED v5.2.7]" in s for s in wv["_vov_pending_sentinels"]) == 1


def test_default_base_skips_a_failed_run_and_numbers_past_it(monkeypatch):
    wv = PS._vov_widgets(scope=None)
    wv["model_version"] = ""
    _setup(monkeypatch, wv, _Registry([_row(1), _row(2, None, registered=False)]))
    assert wv["base_version_for_review"] == "1"
    assert wv["current_version"] == "3"


def test_registry_versions_list_only_versions_with_registered_domains(monkeypatch):
    registry = _Registry([_row(1), _row(2, None, location="/v2", registered=False), _row(3, location="/v3")])
    monkeypatch.setitem(ah.__dict__, "execute_sql", lambda spark, q, logger=None: registry(q))
    got = ah._run_lineage_registry_versions(_RegistrySpark(registry), "c._metamodel.business", "Airlines", "mvm")
    assert sorted(got) == [1, 3]


def test_no_version_counts_when_the_registry_has_no_domain_table(monkeypatch):
    registry = _Registry([_row(1), _row(2)])
    spark = _RegistrySpark(registry)
    spark.catalog = type("C", (), {"tableExists": lambda self, name: not str(name).endswith(".`domain`")})()
    assert ah._registry_registered_versions(spark, "c._metamodel.business", "Airlines", "mvm") == set()
    monkeypatch.setitem(ah.__dict__, "execute_sql", lambda spark_, q, logger=None: registry(q))
    assert ah._run_lineage_registry_versions(spark, "c._metamodel.business", "Airlines", "mvm") == {}


def _overview_with_sibling(monkeypatch, registered):
    import v514_feedback_util as fu
    fake = fu.FakeSpark()
    fake.add_table("c._metamodel.business", ["business", "version", "model_scope", "completed_percent"],
                   [{"business": "Airlines", "version": "3", "model_scope": "ecm", "completed_percent": 100.0}])
    fake.add_table("c._metamodel.domain", ["business", "version", "model_scope", "domain"],
                   [{"business": "Airlines", "version": "3", "model_scope": "ecm", "domain": "crew"}] if registered else [])
    sibling_queries = []

    def _execute_sql(_spark, query, logger=None):
        if sibling_queries:
            raise RuntimeError("past the sibling check")
        sibling_queries.append(query)
        return fake.sql(query).collect()

    monkeypatch.setitem(ah.__dict__, "execute_sql", _execute_sql)
    log = fu.RecordingLogger()
    ah.step_generate_model_overview_md({"operation": "shrink ecm", "spark": fake, "logger": log, "model_scope": "mvm",
                                        "current_version": "3", "business_name": "Airlines",
                                        "config": {"MAIN_METAMODEL_TABLES": {"BUSINESS": "c._metamodel.business"}}})
    return log.text()


def test_model_overview_skips_a_sibling_scope_that_never_registered_its_domains(monkeypatch):
    text = _overview_with_sibling(monkeypatch, registered=False)
    assert "[registry-unregistered-skip FIRED v5.2.7] Model overview MD: sibling scope 'ecm' v3" in text
    assert "past the sibling check" not in text
    text = _overview_with_sibling(monkeypatch, registered=True)
    assert "registry-unregistered-skip" not in text and "past the sibling check" in text

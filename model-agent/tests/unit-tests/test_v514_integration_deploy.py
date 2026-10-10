"""v5.1.4 integration fixes on the physical deploy side, driven through the deploy harness.

- item 3: a failed serialize gate halts the run; deploy preflight, install plan and carry-over refuse it.
- item 6: the deploy helpers read the base model through fence.base_model().
- item 7: a scoped Dry Run writes metrics/*.sql with the deploy set (in-scope + P5 views).
- item 8: the unscoped stale-table cleanup drops with catalog-qualified (3-part) names.
"""
import ast
import copy
import json
import re
import sys
import types
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent))
import conftest  # noqa: F401,E402
import agent_helpers as ah  # noqa: E402
import vibe_scope_deploy_harness as h  # noqa: E402

NOTEBOOK = Path(__file__).resolve().parents[2] / "agent" / "dbx_vibe_modelling_agent.ipynb"
VIEWS = ["crew_roster_kpis", "flight_crew_coverage", "fleet_utilization"]


@pytest.fixture(autouse=True)
def _reset_runtime():
    ah.set_vibe_scope_runtime(None)
    yield
    ah.set_vibe_scope_runtime(None)


def _scoped_root():
    root = h.scoped_final_model()
    root["_vibe_scope"] = h.scoped_facts()
    return root


def _run(monkeypatch, *, dry_run=False, fence=True, facts="default", tables=None):
    base = h.base_model()
    final = _scoped_root() if fence else copy.deepcopy(base)
    if fence:
        ah.set_vibe_scope_runtime(ah.build_vibe_scope_fence(ah.parse_vibe_scope("Some Domains", "crew"), base, h.VOV, h.LOG))
    spark = h.FakeSpark(h.base_physical_tables() if tables is None else tables, views=VIEWS)
    wv = h.flat_widgets(final, spark=spark, facts=(h.scoped_facts() if facts == "default" else facts) if fence else None,
                        dry_run=dry_run, statement_model=base)
    res = h.run_deploy_steps(wv, spark, final, lambda name, value: monkeypatch.setitem(ah.__dict__, name, value))
    res["widgets"] = wv
    res["spark"] = spark
    return res


def _main_source():
    nb = json.loads(NOTEBOOK.read_text())
    return next("".join(c["source"]) for c in nb["cells"] if c["cell_type"] == "code" and "def main():" in "".join(c["source"]))


def test_scoped_dry_run_metric_artifacts_hold_the_deploy_set(monkeypatch, caplog):
    res = _run(monkeypatch, dry_run=True)
    assert res["widgets"].get("_vibe_scope_deploy_plan") is not None
    deploy, kept = ah._vibe_scope_dry_run_metric_artifacts(res["widgets"], h.LOG)
    files = {Path(p).name: t for p, t in res["artifacts"].items() if "/metrics/" in p}
    crew = files["skyline_air_crew_metrics_v2_mvm.sql"]
    flight = files["skyline_air_flight_metrics_v2_mvm.sql"]
    fleet = files["skyline_air_fleet_metrics_v2_mvm.sql"]
    assert "`_metrics`.`crew_roster_kpis`" in crew
    assert "`_metrics`.`flight_crew_coverage`" in flight and "`crew`.`crew_member`" in flight and "`crew`.`member`" not in flight
    assert "fleet_utilization" not in "".join(ah.parse_sql_statements(fleet)) and "preserved from the base version" in fleet
    assert sorted(re.search(r"`_metrics`\.`([^`]+)`", s).group(1) for s in deploy) == ["crew_roster_kpis", "flight_crew_coverage"]
    assert kept == ["fleet_utilization"]


def test_dry_run_branch_of_main_writes_the_scoped_metric_artifacts():
    src = _main_source()
    branch = src[src.index("skipped run_track_3 (step_apply_tags + step_apply_metric_views)"):]
    assert branch.index("_vibe_scope_dry_run_metric_artifacts(widgets_values, logger)") < branch.index("_vw_dr3")


def test_unscoped_dry_run_metric_artifacts_are_untouched(monkeypatch):
    res = _run(monkeypatch, dry_run=True, fence=False)
    assert ah._vibe_scope_dry_run_metric_artifacts(res["widgets"], h.LOG) is None


def test_unscoped_stale_table_cleanup_drops_with_three_part_names(monkeypatch):
    res = _run(monkeypatch, fence=False)
    drops = [s for s in res["statements"] if s.upper().startswith("DROP TABLE")]
    assert drops, "the harness catalog carries stale tables team_notes and ops_scratch"
    assert all(re.fullmatch(r"DROP TABLE IF EXISTS `[^`]+`\.`[^`]+`\.`[^`]+`", s.strip().rstrip(";")) for s in drops), drops
    assert "DROP TABLE IF EXISTS `skyline`.`crew`.`team_notes`" in [s.strip().rstrip(";") for s in drops]


def test_failed_serialize_gate_halts_deploy_preflight_and_install():
    ah.set_vibe_scope_runtime(ah.build_vibe_scope_fence(ah.parse_vibe_scope("Some Domains", "crew"), h.base_model(), h.VOV, h.LOG))
    facts = dict(h.scoped_facts(), serialize_gate={"status": "failed", "violations": [{"kind": "frozen_product_changed", "path": "fleet.aircraft"}]})
    with pytest.raises(ah.VibeScopeFenceError, match="serialize gate failed"):
        ah._vibe_scope_deploy_preflight({"_vibe_scope_facts": facts}, h.LOG)
    with pytest.raises(ah.VibeScopeFenceError, match="serialize gate failed"):
        ah._vibe_scope_halt_if_gate_failed({"_vibe_scope_facts": facts}, "the parallel artifact join", h.LOG)
    root = dict(h.scoped_final_model(), _vibe_scope=facts)
    with pytest.raises(ah.VibeScopeFenceError, match="serialize gate failed"):
        ah._vibe_scope_install_plan(root, root["model"])
    ah._vibe_scope_halt_if_gate_failed({"_vibe_scope_facts": h.scoped_facts()}, "x", h.LOG)
    ah._vibe_scope_halt_if_gate_failed({}, "x", h.LOG)


def test_carry_over_never_copies_base_artifacts_into_a_failed_version(monkeypatch):
    calls = []

    class _Files:
        def __getattr__(self, name):
            calls.append(name)
            raise AssertionError("carry-over touched the volume")

    sdk = types.ModuleType("databricks.sdk")
    sdk.WorkspaceClient = lambda *a, **k: type("W", (), {"files": _Files()})()
    monkeypatch.setitem(sys.modules, "databricks", types.ModuleType("databricks"))
    monkeypatch.setitem(sys.modules, "databricks.sdk", sdk)
    cfg = {"TARGET_VOLUME": "/Volumes/c/_metamodel/vol_root/business/b/v2/mvm"}
    wv = {"operation": h.VOV, "base_version_for_review": "1", "current_version": "2", "model_scope": "mvm"}
    ah._carry_over_missing_artifacts_from_previous_version(dict(wv), cfg, h.LOG)
    assert calls, "a passed or unscoped run still carries artifacts over"
    calls.clear()
    wv["_vibe_scope_facts"] = {"serialize_gate": {"status": "failed", "violations": []}}
    ah._carry_over_missing_artifacts_from_previous_version(wv, cfg, h.LOG)
    assert calls == []


def test_main_halts_on_a_failed_gate_before_carry_over_and_before_physical_deploy():
    src = _main_source()
    join = src.index("_vibe_scope_halt_if_gate_failed(widgets_values, \"the parallel artifact join\", logger)")
    assert join < src.index("_carry_over_missing_artifacts_from_previous_version(widgets_values, config, logger)", join)
    reexport = src.index("_vibe_scope_halt_if_gate_failed(widgets_values, \"the model.json re-export after SelfFixer\", logger)")
    assert src.index("Outer guard caught", src.index("vov-remediate-before-modeljson")) < reexport
    step9a = src.index("_vibe_scope_halt_if_gate_failed(widgets_values, \"Step 9a physical deploy\", logger)")
    assert step9a < src.index("_run_step(step_create_physical_schema_stage1", step9a)
    ast.parse(src)


def test_deploy_helpers_read_the_base_through_the_public_accessor():
    base = h.base_model()
    fence = ah.build_vibe_scope_fence(ah.parse_vibe_scope("Some Domains", "crew"), base, h.VOV, h.LOG)
    copy_one = fence.base_model()
    assert copy_one == ah._vibe_scope_model_root(base)
    copy_one["domains"].clear()
    assert fence.base_model()["domains"], "base_model() must return a copy the caller cannot corrupt"
    src = NOTEBOOK.read_text()
    assert "fence._source_model" not in src

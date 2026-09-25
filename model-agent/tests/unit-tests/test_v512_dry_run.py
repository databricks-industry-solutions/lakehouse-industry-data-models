"""v5.1.2 behavioral + structural tests for Dry Run Mode.

Feature (user request): a 'run_type' widget (Full Run / Dry Run, default Full Run).
Dry Run builds the full model + ALL volume artifacts (model.json, schemas/*.sql,
metrics/*.sql) and the _metamodel registry, but SKIPS the physical Unity Catalog
deploy (domain tables Step 9a, FK constraints Step 9b, tags + metric views Track 3).

Design decisions honoured:
  1C: default = 'Full Run' (backward-compatible; automation keeps deploying).
  2A: skip ONLY physical tables/FKs/tags/metric-views; keep artifacts + registry.
  3A: gate GENERATIVE ops only; 'install model'/'uninstall model version' ignore it.

The `_compute_dry_run` behavioral tests fail on pre-patch HEAD (function absent),
and pass post-patch (§8.10 fail-pre/pass-post).
"""
import json
import re
from pathlib import Path

import agent_helpers as ah

NOTEBOOK = Path(__file__).resolve().parents[2] / "agent" / "dbx_vibe_modelling_agent.ipynb"


def _all_source():
    nb = json.loads(NOTEBOOK.read_text())
    return "\n".join("".join(c.get("source", [])) for c in nb["cells"])


GENERATIVE = ("new base model", "vibe modeling of version", "shrink ecm", "enlarge mvm")
NON_GENERATIVE = ("install model", "uninstall model version")


# ---------------------------------------------------------------- behavioral

def test_dry_run_true_for_generative_when_dry():
    for op in GENERATIVE:
        assert ah._compute_dry_run("Dry Run", op) is True, op


def test_full_run_never_dry_for_generative():
    for op in GENERATIVE:
        assert ah._compute_dry_run("Full Run", op) is False, op


def test_default_empty_run_type_is_not_dry():
    # Widget default is 'Full Run'; an empty/missing value must NOT dry-run (1C).
    for op in GENERATIVE:
        assert ah._compute_dry_run("", op) is False, op
        assert ah._compute_dry_run(None, op) is False, op


def test_install_and_uninstall_ignore_dry_run():
    # Decision 3A: explicit deploy/undeploy ops always run their step.
    for op in NON_GENERATIVE:
        assert ah._compute_dry_run("Dry Run", op) is False, op
        assert ah._compute_dry_run("Full Run", op) is False, op


def test_dry_run_case_and_scheme_tolerant():
    for rt in ("Dry Run", "dry run", "DRY RUN", "dry-run", "dry_run", "  Dry Run  "):
        assert ah._compute_dry_run(rt, "new base model") is True, rt


def test_unknown_run_type_is_not_dry():
    assert ah._compute_dry_run("Full", "new base model") is False
    assert ah._compute_dry_run("wet run", "new base model") is False


# ---------------------------------------------------------------- structural

def test_run_type_widget_defined_default_full_run():
    src = _all_source()
    assert 'dbutils.widgets.dropdown("run_type", "Full Run", ["Full Run", "Dry Run"]' in src, (
        "run_type widget must be defined with default 'Full Run' (decision 1C)"
    )


def test_run_type_forwarded_in_notebook_widget_names():
    src = _all_source()
    m = re.search(r"_NOTEBOOK_WIDGET_NAMES\s*=\s*\[(.*?)\]", src, re.DOTALL)
    assert m and '"run_type"' in m.group(1), (
        "run_type must be in _NOTEBOOK_WIDGET_NAMES so self-launch forwards it"
    )


def test_dry_run_flag_set_from_compute_helper():
    src = _all_source()
    assert 'widget_values["_dry_run"] = _compute_dry_run(w_run_type, operation)' in src


def test_stage1_always_called_so_ddl_persists():
    src = _all_source()
    # stage1 is called UNCONDITIONALLY in run_track_1 so schemas/*.sql DDL is written
    # even in Dry Run (the gate lives INSIDE stage1, skipping only execution).
    assert "_run_step(step_create_physical_schema_stage1, widgets_values, _vibe_orchestrator)" in src


def test_physical_execution_gated_inside_stage1():
    src = _all_source()
    # In stage1, after schemas/*.sql are written, a dry-run guard early-returns BEFORE
    # the "Executing Stage 1: Registering and Creating" physical execution phase.
    exec_marker = src.find("Executing Stage 1: Registering and Creating")
    assert exec_marker != -1, "stage1 execution phase marker missing"
    gate = src.rfind('if widgets_values.get("_dry_run"):', 0, exec_marker)
    assert gate != -1, "dry-run execution gate must precede physical execution in stage1"
    seg = src[gate:exec_marker]
    assert "return" in seg, "dry-run gate must early-return before physical execution"
    assert "dry-run-skip-physical FIRED" in seg


def test_fk_execution_gated_on_dry_run():
    src = _all_source()
    # step_apply_foreign_keys EXECUTION is skipped on dry run (FK DDL persisted in stage1).
    assert "\n                    _run_step(step_apply_foreign_keys" in src, (
        "step_apply_foreign_keys must be nested under the dry-run else branch (20-space indent)"
    )


def test_track3_gated_by_dry_run():
    src = _all_source()
    # run_track_3() must be inside an else branch (not called unconditionally).
    assert "\n            run_track_3()\n" in src, (
        "run_track_3() must be indented under the dry-run else branch"
    )


def test_alias_markers_present():
    src = _all_source()
    for alias in ("alias=dry-run-mode", "alias=dry-run-skip-physical"):
        assert alias in src, alias

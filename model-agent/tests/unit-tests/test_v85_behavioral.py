from notebook_source_util import notebook_concat_source

import json
import re
from pathlib import Path

import pytest

AGENT_NB = Path(__file__).resolve().parents[2] / "agent" / "dbx_vibe_modelling_agent.ipynb"


@pytest.fixture(scope="module")
def nb_cells():
    nb = json.loads(AGENT_NB.read_text())
    return {ci: "".join(c["source"]) for ci, c in enumerate(nb["cells"]) if c["cell_type"] == "code"}


@pytest.fixture(scope="module")
def nb_text():
    return AGENT_NB.read_text()


def test_agent_version_is_085(nb_cells):
    src = nb_cells[1]
    m = re.search(r'__AGENT_VERSION__\s*=\s*"(\d+)\.(\d+)\.(\d+)"', src)
    assert m
    ver = (int(m.group(1)), int(m.group(2)), int(m.group(3)))
    assert ver >= (0, 8, 5), f"expected >= 0.8.5 got {m.group(0)}"


@pytest.mark.parametrize("alias", [
    "install-clash-debug-logger-rescue",
    "p58-relaxed-fallback",
    "install-vov-handoff-allow-overwrite",
])
def test_v85_alias_present(nb_text, alias):
    assert alias in nb_text


def test_p60a_cell23_call_site_passes_logger(nb_cells):
    src = nb_cells[23]
    assert "install-clash-debug-logger-rescue" in src
    assert "_check_physical_deployment_clash(spark, _deploy_clash_targets, widgets_values, logger=_clash_logger)" in src
    # The specific old bug pattern must no longer be present in the install path
    assert "_check_physical_deployment_clash(spark, _deploy_clash_targets, widgets_values, logger=None)" not in src, (
        "old logger=None call site at cell 23 must be removed"
    )


def test_p60b_relaxed_fallback_present_in_cell1(nb_cells):
    src = nb_cells[1]
    assert "p58-relaxed-fallback" in src
    assert "_p60_relaxed_promote" in src
    assert "MAX-FAIL" in src
    assert "FIRED-RELAXED" in src


def test_p60b_emits_print_for_visibility(nb_cells):
    src = nb_cells[1]
    fired_ix = src.find("install-vov-handoff-allow-overwrite FIRED]")
    assert fired_ix > 0
    relaxed_ix = src.find("install-vov-handoff-allow-overwrite FIRED-RELAXED]")
    assert relaxed_ix > 0
    # Both branches must call print() so the FIRED marker is visible even when logger is None
    tail_fired = src[fired_ix: fired_ix + 1500]
    tail_relaxed = src[relaxed_ix: relaxed_ix + 1500]
    assert "print(_msg)" in tail_fired
    assert "print(_msg)" in tail_relaxed


def test_p60b_relaxed_only_promotes_for_v_ge_2(nb_cells):
    src = nb_cells[1]
    # ensure the relaxed fallback gates on _cur_v_int >= 2
    assert "_relaxed_rows and _cur_v_int >= 2:" in src


def test_p60b_handles_max_query_exception(nb_cells):
    src = nb_cells[1]
    assert "except Exception as _max_e" in src
    assert "MAX-FAIL" in src


# ─── Anti-regression for v0.8.3 + v0.8.4 ───
@pytest.mark.parametrize("alias", [
    "autofix-p016-user-vibe-skip",
    "connect-table-upsert-fk",
    "install-mv-hard-gate",
    "unconditional-cascade-drop-extras",
    "honest-adherence-precision",
    "next-vibes-sa-target-filter",
    "soft-accept-hard-fail-on-critical-step",
])
def test_prior_aliases_still_present(nb_text, alias):
    assert alias in nb_text, f"prior alias {alias} regressed in v0.8.5"

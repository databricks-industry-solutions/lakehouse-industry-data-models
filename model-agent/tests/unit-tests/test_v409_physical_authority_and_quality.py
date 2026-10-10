import ast
import json
import re
import sys
import textwrap
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import conftest  # noqa: F401,E402
import agent_helpers as ah  # noqa: E402


NB_PATH = Path(__file__).resolve().parents[2] / "agent" / "dbx_vibe_modelling_agent.ipynb"


def _src():
    nb = json.loads(NB_PATH.read_text())
    return "\n".join(
        "".join(c.get("source", []))
        for c in nb.get("cells", [])
        if c.get("cell_type") == "code"
    )


def _extract_diff_scope_fn(src: str):
    tree = ast.parse(src)
    keep = []
    for node in tree.body:
        if isinstance(node, ast.FunctionDef) and node.name == "diff_within_summary_scope":
            keep.append(node)
            break
    mod = ast.Module(body=keep, type_ignores=[])
    ast.fix_missing_locations(mod)
    ns = {"re": re, "_vov_names_in_text": ah._vov_names_in_text,
          "_vov_text_allows_attribute_removal": ah._vov_text_allows_attribute_removal}
    exec(compile(mod, str(NB_PATH), "exec"), ns)
    return ns["diff_within_summary_scope"]


def _extract_quality_fn(src: str):
    m = re.search(
        r"(def _compute_deterministic_confidence_and_status\(\):[\s\S]+?return calculated_confidence, calculated_status)",
        src,
    )
    assert m, "quality function not found"
    fn_src = textwrap.dedent(m.group(1))
    ns = {}
    exec(fn_src, ns)
    return ns["_compute_deterministic_confidence_and_status"], ns


def test_v409_aliases_present():
    src = _src()
    assert "vreq-move-scope-whitelist" in src
    assert "physical-adherence-authoritative" in src
    assert "quality-foundation-plus-delta" in src


def test_move_product_balanced_scope_is_allowed():
    src = _src()
    fn = _extract_diff_scope_fn(src)
    diff = {
        "domains_added": [],
        "domains_removed": [],
        "products_added": [("workforce", "benefit_plan")],
        "products_removed": [("procurement", "benefit_plan")],
        "fks_removed": 0,
        "metric_views_delta": 0,
    }
    ok, msg = fn(diff, "Move procurement.benefit_plan to workforce domain")
    assert ok is True, msg


def test_non_move_remove_still_rejected():
    src = _src()
    fn = _extract_diff_scope_fn(src)
    diff = {
        "domains_added": [],
        "domains_removed": [],
        "products_added": [("workforce", "benefit_plan")],
        "products_removed": [("procurement", "benefit_plan")],
        "fks_removed": 0,
        "metric_views_delta": 0,
    }
    ok, msg = fn(diff, "Refactor architecture and simplify model")
    assert ok is False
    assert "products_removed" in msg


def test_quality_is_foundation_plus_delta_not_min50():
    src = _src()
    fn, ns = _extract_quality_fn(src)

    # rich/sound model -> foundation 50 + delta near 50
    ns["severity_counts"] = {"error": 0, "warning": 0}
    ns["model_stats"] = {
        "domain_count": 10,
        "product_count": 200,
        "fk_count": 800,
        "unlinked_id_count": 0,
        "siloed_count": 0,
    }
    ns["all_issues"] = []
    ns["attributes_data"] = [{"tags": {"division": "operations"}}]
    ns["widgets_values"] = {"_ground_truth_scorecard": {"scored": 10, "pct": 100.0}}
    ns["config"] = {"PROMPT_VARIABLES": {"_next_vibe_metadata": {"confidence_score": 0, "issue_counts": {"warning": 0}}}}

    class _L:
        def info(self, *_):
            pass

    ns["logger"] = _L()
    ns["_LAST_VERIFIED_ADHERENCE"] = 1.0
    score, _ = fn()
    assert score >= 95, score

    # no tags -> lose foundation points (cannot stay near max)
    ns["attributes_data"] = [{}]
    score_no_tags, _ = fn()
    assert score_no_tags < score, (score_no_tags, score)


def test_quality_penalized_by_physical_adherence_gap():
    src = _src()
    fn, ns = _extract_quality_fn(src)
    ns["severity_counts"] = {"error": 0, "warning": 0}
    ns["model_stats"] = {
        "domain_count": 10,
        "product_count": 200,
        "fk_count": 800,
        "unlinked_id_count": 0,
        "siloed_count": 0,
    }
    ns["all_issues"] = []
    ns["attributes_data"] = [{"tags": {"division": "operations"}}]
    ns["config"] = {"PROMPT_VARIABLES": {"_next_vibe_metadata": {"confidence_score": 0, "issue_counts": {"warning": 0}}}}

    class _L:
        def info(self, *_):
            pass

    ns["logger"] = _L()
    ns["_LAST_VERIFIED_ADHERENCE"] = 1.0

    ns["widgets_values"] = {"_ground_truth_scorecard": {"scored": 10, "pct": 100.0}}
    score_100, _ = fn()
    ns["widgets_values"] = {"_ground_truth_scorecard": {"scored": 57, "pct": 66.7}}
    score_667, _ = fn()
    assert score_667 < score_100, (score_667, score_100)


def test_physical_adherence_authoritative_path_present():
    src = _src()
    assert "_gt_scored > 0" in src
    assert "_adh_source = 'physical_ground_truth'" in src
    assert "scorecard['adherence_source'] = _adh_source" in src
    assert "scorecard['physical_adherence_pct']" in src

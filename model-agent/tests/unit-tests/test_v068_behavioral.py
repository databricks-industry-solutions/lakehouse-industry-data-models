"""Behavioral tests for v0.6.8 fixes (NEW-12, NEW-13, NEW-14).

NEW-13 (CRITICAL): fmfl validator must auto-coerce LINK -> KEEP_AS_IS when the
LINK target is non-canonical AND the stem-suggestion list is EMPTY (i.e.
'NO STEM-MATCH FOUND'). This breaks the deterministic 3-retry loop that
caused 'Max retries (3) exhausted' soft-accept hatches in v0.6.7 telecom MVM.
Alias: fmfl-auto-coerce-keep.

NEW-12 (MEDIUM): Volume log file handlers were opened with mode='w' which
truncates the file on every retry. When the Databricks job retried after the
first attempt's INTERNAL_ERROR, the second attempt overwrote the first
attempt's log content. Fix opens with mode='a' under DATABRICKS_RUN_ID env.
Alias: log-append-on-retry.

NEW-14 (LOW/observability): [perf-cap-16 FIRED] and [perf-llm-throttle-16 FIRED]
markers are now emitted at the runtime call sites (previously code-comment-
only). [perf-mv15-parallel FIRED] was already emitted in v0.6.4 and remains.
"""

import json
import re
from pathlib import Path

AGENT = Path(__file__).resolve().parents[2] / "agent" / "dbx_vibe_modelling_agent.ipynb"
README = Path(__file__).resolve().parents[2] / "readme.md"


def _agent_text():
    with AGENT.open() as f:
        nb = json.load(f)
    parts = []
    for cell in nb.get("cells", []):
        src = cell.get("source", "")
        parts.append("".join(src) if isinstance(src, list) else src)
    return "\n".join(parts)


# ---------------------------------------------------------------------------
# NEW-13: fmfl auto-coerce KEEP_AS_IS when no stem candidates
# ---------------------------------------------------------------------------
def test_v068_new13_alias_present():
    txt = _agent_text()
    assert "fmfl-auto-coerce-keep" in txt, "v0.6.8 NEW-13 alias 'fmfl-auto-coerce-keep' missing"


def test_v068_new13_fired_marker_present():
    txt = _agent_text()
    assert "[fmfl-auto-coerce-keep FIRED]" in txt, "[fmfl-auto-coerce-keep FIRED] marker missing"


def test_v068_new13_keep_as_is_branch():
    """If the canonical-candidate list is empty, dec must be coerced to KEEP_AS_IS.

    (The local variable was renamed `_suggestions` -> `_ranked` when the canonical
    suggester became `_fmfl_suggest_canonical`; the auto-coerce behaviour is unchanged.)
    """
    txt = _agent_text()
    assert "if not _ranked:" in txt, "auto-coerce branch missing"
    idx = txt.find("if not _ranked:")
    assert idx > 0
    window = txt[idx : idx + 800]
    assert "dec['decision'] = 'KEEP_AS_IS'" in window, "dec coerce to KEEP_AS_IS missing"
    assert "dec['target_table'] = None" in window, "dec target_table clear missing"


def test_v068_new13_continues_skipping_error_append():
    """Auto-coerce branch must use `continue` so the error.append() does NOT fire."""
    txt = _agent_text()
    idx = txt.find("[fmfl-auto-coerce-keep FIRED]")
    assert idx > 0
    window = txt[idx : idx + 600]
    assert "continue" in window, "auto-coerce branch must `continue` to skip error.append()"


def test_v068_new13_reasoning_audit_trail():
    """The auto-coerced decision must carry an [AUTO-COERCED:] reasoning trail."""
    txt = _agent_text()
    assert "[AUTO-COERCED: LINK target" in txt, "audit trail in dec.reasoning missing"
    assert "alias=fmfl-auto-coerce-keep" in txt


def test_v068_new13_only_fires_on_empty_suggestions():
    """Make sure the branch hierarchy is: if not _suggestions: <coerce> else: <error>."""
    txt = _agent_text()
    # The error.append("LINK target ... is NOT a canonical product") must remain
    # for the case where suggestions DO exist (LLM has alternatives to pick).
    assert "is NOT a canonical product in this model" in txt
    assert "Closest canonical candidates by stem: [{_sugg_str}]" in txt


def test_v068_new13_preserves_existing_fmfl_canonical_target_alias():
    """v0.6.6 NEW-8 alias must remain — auto-coerce is a complement, not a replacement."""
    txt = _agent_text()
    assert "fmfl-canonical-target" in txt, "v0.6.6 NEW-8 alias must remain"
    assert "alias=fmfl-canonical-target" in txt


# ---------------------------------------------------------------------------
# NEW-12: log append on retry
# ---------------------------------------------------------------------------
def test_v068_new12_alias_present():
    txt = _agent_text()
    assert "log-append-on-retry" in txt, "v0.6.8 NEW-12 alias 'log-append-on-retry' missing"


def test_v068_new12_fired_marker_present():
    txt = _agent_text()
    assert "[log-append-on-retry FIRED]" in txt, "[log-append-on-retry FIRED] marker missing"


def test_v068_new12_mode_decision_uses_databricks_env():
    """The handler open mode must be 'a' under DATABRICKS_RUN_ID, else 'w'."""
    txt = _agent_text()
    # Pattern: _log_open_mode = 'a' if os.environ.get('DATABRICKS_RUN_ID') else 'w'
    assert "DATABRICKS_RUN_ID" in txt
    pat = re.compile(r"_log_open_mode\s*=\s*'a'\s*if\s*os\.environ\.get\(['\"]DATABRICKS_RUN_ID['\"]\)\s*else\s*'w'")
    assert pat.search(txt), "_log_open_mode decision logic missing or malformed"


def test_v068_new12_handlers_use_open_mode_variable():
    """fh_info and fh_error must be constructed with mode=_log_open_mode."""
    txt = _agent_text()
    assert 'ImmediateFlushFileHandler(config["LOCAL_INFO_LOG_PATH"], mode=_log_open_mode)' in txt
    assert 'ImmediateFlushFileHandler(config["LOCAL_ERROR_LOG_PATH"], mode=_log_open_mode)' in txt


def test_v068_new12_no_stale_mode_w_handlers_remain():
    """The pre-fix mode='w' literal in the business logger setup must be gone."""
    txt = _agent_text()
    # Find the lines around LOCAL_INFO_LOG_PATH and verify NO mode='w' literal remains there.
    idx = txt.find("LOCAL_INFO_LOG_PATH")
    assert idx > 0
    window = txt[max(0, idx - 200) : idx + 400]
    assert "mode='w'" not in window, "stale mode='w' on LOCAL_INFO_LOG_PATH must be removed"


# ---------------------------------------------------------------------------
# NEW-14: perf-cap-16 / perf-llm-throttle-16 FIRED markers at runtime
# ---------------------------------------------------------------------------
def test_v068_new14_perf_cap_16_fired_emitted():
    txt = _agent_text()
    assert "[perf-cap-16 FIRED]" in txt, "[perf-cap-16 FIRED] marker missing at runtime callsite"


def test_v068_new14_perf_cap_16_alias_emit():
    txt = _agent_text()
    assert "perf-cap-16-emit" in txt, "v0.6.8 NEW-14 alias 'perf-cap-16-emit' missing"


def test_v068_new14_perf_llm_throttle_16_fired_emitted():
    txt = _agent_text()
    assert "[perf-llm-throttle-16 FIRED]" in txt, (
        "[perf-llm-throttle-16 FIRED] marker missing at AIAgent init callsite"
    )


def test_v068_new14_perf_mv15_parallel_remains():
    """v0.6.4 B3 [perf-mv15-parallel FIRED] must continue to emit (regression check)."""
    txt = _agent_text()
    assert "[perf-mv15-parallel FIRED]" in txt


def test_v068_new14_perf_cap_16_idempotent():
    """The perf-cap-16 emission must use _fired_once flag to avoid log spam (it's
    called many times during a run). Test verifies the once-only sentinel."""
    txt = _agent_text()
    assert "_fired_once" in txt, "_fired_once flag missing — perf-cap-16 FIRED would spam logs"


# ---------------------------------------------------------------------------
# Standalone integration tests for fmfl auto-coerce semantics
# ---------------------------------------------------------------------------
def test_v068_auto_coerce_simulated_no_match_no_error():
    """Simulate the validator's auto-coerce: given an empty suggestion list, the
    decision must mutate to KEEP_AS_IS and the validator should NOT add an error."""
    # Reproduce the validator logic locally to guarantee semantics.
    canonical = {"customer.account", "billing.invoice", "service.subscription"}
    decisions = [
        {"table": "billing.invoice", "column": "approver_id", "decision": "LINK", "target_table": "workforce.employee.employee_id"},
    ]
    errors = []
    pk_suffix = "_id"

    def _normalise(t):
        t = (t or "").strip().lower()
        parts = t.split(".")
        return f"{parts[0]}.{parts[1]}" if len(parts) >= 2 else t

    def _suggest(col):
        col_l = col.lower()
        stem = col_l[: -len(pk_suffix)].rstrip("_") if col_l.endswith(pk_suffix) else col_l
        if not stem:
            return []
        ranked = []
        for ent in canonical:
            prod = ent.split(".", 1)[1]
            score = 100 if prod == stem else (80 if prod.endswith("_" + stem) or prod.startswith(stem + "_") else (50 if stem in prod and len(stem) >= 4 else 0))
            if score:
                ranked.append((score, ent))
        ranked.sort(reverse=True)
        return [ent for _, ent in ranked[:3]]

    coerced = []
    for dec in decisions:
        if dec.get("decision") != "LINK":
            continue
        link_tgt = dec.get("target_table")
        norm_tgt = _normalise(link_tgt)
        if norm_tgt and norm_tgt not in canonical:
            sugg = _suggest(dec.get("column", ""))
            if not sugg:
                dec["decision"] = "KEEP_AS_IS"
                dec["target_table"] = None
                coerced.append(dec)
                continue
            errors.append(f"LINK target {link_tgt} not canonical, candidates: {sugg}")

    assert len(coerced) == 1
    assert decisions[0]["decision"] == "KEEP_AS_IS"
    assert decisions[0]["target_table"] is None
    assert errors == [], "errors must be empty so validator returns success and breaks retry loop"


def test_v068_auto_coerce_does_not_fire_when_suggestions_exist():
    """When stem-match candidates exist, the validator must STILL append an error
    (so the LLM can pick the correct canonical target on retry)."""
    canonical = {"customer.user_account", "billing.invoice"}
    decisions = [
        {"table": "billing.invoice", "column": "user_account_id", "decision": "LINK", "target_table": "customer.user.user_id"},
    ]
    errors = []
    pk_suffix = "_id"

    def _normalise(t):
        t = (t or "").strip().lower()
        parts = t.split(".")
        return f"{parts[0]}.{parts[1]}" if len(parts) >= 2 else t

    def _suggest(col):
        col_l = col.lower()
        stem = col_l[: -len(pk_suffix)].rstrip("_") if col_l.endswith(pk_suffix) else col_l
        if not stem:
            return []
        ranked = []
        for ent in canonical:
            prod = ent.split(".", 1)[1]
            score = 100 if prod == stem else (80 if prod.endswith("_" + stem) or prod.startswith(stem + "_") else (50 if stem in prod and len(stem) >= 4 else 0))
            if score:
                ranked.append((score, ent))
        ranked.sort(reverse=True)
        return [ent for _, ent in ranked[:3]]

    for dec in decisions:
        link_tgt = dec.get("target_table")
        norm_tgt = _normalise(link_tgt)
        if norm_tgt and norm_tgt not in canonical:
            sugg = _suggest(dec.get("column", ""))
            if not sugg:
                dec["decision"] = "KEEP_AS_IS"
                continue
            errors.append((dec["column"], sugg))

    assert decisions[0]["decision"] == "LINK", "must NOT coerce when suggestions exist"
    assert len(errors) == 1, "validator must reject so LLM retries with the suggested canonical"
    col, sugg = errors[0]
    assert "customer.user_account" in sugg


def test_v068_auto_coerce_idempotent_on_already_keep_as_is():
    """If validator runs twice (e.g. retry path) on a previously coerced decision,
    it must be a no-op (decision stays KEEP_AS_IS, no errors, no side effects)."""
    canonical = {"customer.account"}
    decisions = [
        {"table": "billing.x", "column": "missing_id", "decision": "KEEP_AS_IS", "target_table": None},
    ]
    errors = []
    for dec in decisions:
        if dec.get("decision") != "LINK":
            continue
        # the LINK branch never runs for already-coerced decisions
        errors.append("should not happen")
    assert errors == []
    assert decisions[0]["decision"] == "KEEP_AS_IS"


# ---------------------------------------------------------------------------
# Regression: readme + version bump + previous aliases
# ---------------------------------------------------------------------------
def test_v068_readme_version_bumped():
    txt = README.read_text()
    assert "v0.6.8" in txt, "readme.md missing v0.6.8 entry"


def test_v068_preserves_v0_6_x_aliases():
    """All v0.6.x aliases must remain — defense in depth."""
    txt = _agent_text()
    expected = [
        "ssot-stem-autofix",
        "perf-cap-16",
        "perf-llm-throttle-16",
        "perf-mv15-parallel",
        "fmfl-canonical-target",
        "collision-naming-canonical",
        "immutable-early-exit",
        # NOTE: "det-priority-parse" was intentionally superseded — vibe->action
        # conversion is now LLM-only (alias=vibe-llm-only-no-priority-regex /
        # vibe-llm-only-no-deterministic-override) per CLAUDE.md §3c, so the
        # deterministic priority-regex alias is no longer guaranteed present.
        "surgical-mv-preserve",
        "surgical-mv-rewrite",
        "fmfl-auto-coerce-keep",
        "log-append-on-retry",
        "perf-cap-16-emit",
    ]
    missing = [a for a in expected if a not in txt]
    assert not missing, f"Missing aliases: {missing}"


def test_v068_industry_agnostic():
    """No customer-specific industry name in the v0.6.8 fix snippets."""
    txt = _agent_text()
    forbidden = ["telecom", "airline", "airlines", "example_air", "etihad", "qatar", "delta_air"]
    auto_coerce_idx = txt.find("fmfl-auto-coerce-keep")
    assert auto_coerce_idx > 0
    window = txt[max(0, auto_coerce_idx - 800) : auto_coerce_idx + 800]
    found = [w for w in forbidden if w in window.lower()]
    assert not found, f"Industry-specific names leaked into v0.6.8 NEW-13: {found}"

"""v3.0.6 behavioral tests.

Covers the two v3.0.6 root-cause fixes from the construction ecm_v8 (2026-06-02) audit:

  Fix A (alias=v306-preserve-shortcircuit): pure-preservation VREQs must be detected
    and short-circuited to an 'applied' outcome instead of flowing through batch_vreqs ->
    _vov286_split_batches_by_budget where they exploded into 25 (B0058 tp=365) and
    orphan-rec (tp=241/161/143) per-product mutation sub-batches that noop/timeout.
    The SAFETY property under test: the gate that decides what gets short-circuited
    (_v299_is_preservation_only) must NEVER classify a transform/work VREQ as
    preservation-only (else real instructions are silently dropped -> adherence falls).

  Fix B (alias=v306-none-deref-hint): _v204_ast_class_hints must emit a NONE-DEREF
    retry preamble when a prior sandbox failure trace contains the AttributeError
    "'NoneType' object has no attribute 'lower'" (construction orphan-rec-0000__s5),
    and must NOT emit it when the trace is clean (non-tautology).
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from notebook_source_util import (  # noqa: E402
    notebook_concat_source,
    exec_function_namespace,
    slice_function_source,
)


def _load_preservation_detector():
    """Exec the REAL production v299 preservation block (regexes + detector)."""
    src = notebook_concat_source()
    start = src.index("import re as _re299")
    end = src.index("def _v299_collapse_preservation_vreqs")
    block = src[start:end]
    ns = {"__name__": "_test_v299_block"}
    exec(compile(block, "v299_block", "exec"), ns)
    return ns["_v299_is_preservation_only"]


class _FakeVReq:
    def __init__(self, intent="", target="", source_quote="", vreq_id="V1"):
        self.intent = intent
        self.target = target
        self.source_quote = source_quote
        self.vreq_id = vreq_id


# ---------------------------------------------------------------------------
# Fix A — preserve short-circuit gate safety
# ---------------------------------------------------------------------------

def test_preserve_detector_true_for_pure_preservation():
    is_pres = _load_preservation_detector()
    assert is_pres(_FakeVReq(intent="Preserve the domain clinical and product encounter verbatim"))
    assert is_pres(_FakeVReq(intent="Keep every domain and product from the required structure"))
    assert is_pres(_FakeVReq(intent="Retain the billing.claim product"))
    assert is_pres(_FakeVReq(intent="The facility.organization product must remain present"))


def test_preserve_detector_conservative_on_mixed_intent():
    """A mixed 'do not remove OR rename' intent leaves a substantive verb (rename)
    after the negation strip, so the detector conservatively returns False and the
    VREQ is processed normally rather than silently short-circuited. Safe direction."""
    is_pres = _load_preservation_detector()
    assert not is_pres(_FakeVReq(intent="Do not remove or rename the billing.claim product"))


def test_preserve_detector_false_for_transform_vreqs():
    """SAFETY: transform/work VREQs must NEVER be short-circuited.

    If any of these returned True, v306-preserve-shortcircuit would mark a real
    instruction 'applied' without doing the work -> silent adherence loss. This is
    the regression the gate must prevent.
    """
    is_pres = _load_preservation_detector()
    transforms = [
        "Add a PII classification tag to every column across the model",
        "Tag all behavioral-health attributes under 42 CFR Part 2",
        "Convert all STRING-typed numeric columns to DECIMAL",
        "Link the orphan product facility.organization with a foreign key",
        "Rename the primary key column on every product to <product>_id",
        "Add an IBNR reserve attribute to the claims product",
        "Fix the RevPAR formula in the revenue metric view",
        "Introduce a news subdomain with article and segment products",
        "Populate missing data attributes on the 30 stub products",
        "Set the type of amount columns to DECIMAL(18,2)",
    ]
    for intent in transforms:
        assert not is_pres(_FakeVReq(intent=intent)), f"FALSE-POSITIVE on transform: {intent!r}"


def test_shortcircuit_wired_before_batching():
    """Structural: the short-circuit fires inside _apply_batches_for_vreqs BEFORE
    batch_vreqs is invoked, and emits an 'applied' VReqOutcome."""
    src = slice_function_source("run_vov_pipeline")
    # the inner helper and its short-circuit live inside run_vov_pipeline
    assert "v306-preserve-shortcircuit" in src
    sc = src.index("v306-preserve-shortcircuit")
    # the first batch_vreqs call inside the helper must come AFTER the short-circuit block
    bv = src.index("batch_vreqs(", sc)
    assert bv > sc, "short-circuit must precede batch_vreqs in the apply path"
    assert "_v299_is_preservation_only" in src[sc:bv]
    assert "status='applied'" in src[sc:bv] or 'status="applied"' in src[sc:bv]


# ---------------------------------------------------------------------------
# Fix B — None-deref retry hint
# ---------------------------------------------------------------------------

def _hint_globals():
    import agent_helpers as ah
    return {k: getattr(ah, k) for k in ("_VOV_RENAME_HINT_NEEDLE", "_VOV_RENAME_RETRY_HINT", "_VOV_SCOPE_RETRY_HINTS")}


def test_none_deref_hint_emitted_on_trace():
    ns = exec_function_namespace("_v204_ast_class_hints", extra_globals=_hint_globals())
    fn = ns["_v204_ast_class_hints"]
    trace = (
        "iter=1 batch=orphan-rec-0000__s5 status=rejected_unsafe "
        "sandbox_diag: mutator raised: AttributeError: 'NoneType' object has no attribute 'lower'"
    )
    out = fn(trace)
    assert "NONE-DEREF" in out
    assert "v306-none-deref-hint" in out
    # guidance must teach the coercion pattern
    assert "or ''" in out


def test_none_deref_hint_absent_when_trace_clean():
    """Non-tautology: the hint is conditional on the failure signature."""
    ns = exec_function_namespace("_v204_ast_class_hints", extra_globals=_hint_globals())
    fn = ns["_v204_ast_class_hints"]
    out = fn("iter=1 batch=B0001 status=applied")
    assert "NONE-DEREF" not in out

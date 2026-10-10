"""Behavioral tests for v2.8.8 — SELFFIXER IMPORT-CONTRADICTION FIX.

Aliases: selffixer-no-import (prompt) + selffixer-retry-hint (retry feedback).

Live <profile>/construction VOV run (2026-05-30) printed, for the VREQs the main pass
missed and handed to the closed-loop SelfFixer:
    [selffixer-sandbox-result FIRED] req=VREQ-003 attempt=0 ok=False ver_ok=False err=unsafe_ast: forbidden AST node: Import
    [selffixer-sandbox-result FIRED] req=VREQ-003 attempt=1 ok=False ver_ok=False err=unsafe_ast: forbidden AST node: Import
    [selffixer-sandbox-result FIRED] req=VREQ-003 attempt=2 ok=False ver_ok=False err=unsafe_ast: forbidden AST node: Import
    [selffixer-sandbox-result FIRED] req=VREQ-004 attempt=0 ok=False ver_ok=False err=unsafe_ast: forbidden AST node: Import

ROOT CAUSE (two reinforcing bugs):
  1. _SELFFIXER_PROMPT invited the LLM to "use re module, copy module, math, json" but never
     said those modules are PRE-IMPORTED in the sandbox runner. So the LLM wrote `import re` /
     `import json`, the sandbox AST validator (validate_ast) rejects every Import node, and the
     mutator was discarded BEFORE running. `math` was never even injected into the runner.
  2. _fix_one_req captured `last_err` but re-called _call_opus with IDENTICAL inputs on every
     retry — no failure feedback — so the LLM repeated the same import mistake on attempt 0/1/2.
     The MAIN synthesis path already feeds prior-failure AST hints back via _v204_ast_class_hints;
     the self-fixer did NOT (a DRY gap). Result: the recovery path for missed VREQs was DEAD on
     any import-emitting fix, capping coverage below 100% (construction 96.5% vs restaurants 99.1%).

FIX:
  - Prompt: state re/copy/json are pre-imported bare names, NEVER write import, drop false `math`.
  - Retry: _fix_one_req now computes _v204_ast_class_hints(last_err) on attempt>0 and passes it as
    retry_hint to _call_opus, which prepends it to the prompt (same corrective the synthesis path uses).

These tests exec the REAL notebook _v204_ast_class_hints and assert the OBSERVABLE corrective output
for the exact live failure trace, plus verify the wiring is live (not dead code, §8.4).
"""
import re

from notebook_source_util import notebook_concat_source, slice_function_source

SRC = notebook_concat_source()

# The exact last_err string _fix_one_req builds when the sandbox rejects an import-using mutator,
# mirroring the live construction log line.
LIVE_IMPORT_TRACE = ("sandbox_or_verifier_failed: ok=False ver_ok=False "
                     "err=unsafe_ast: forbidden AST node: Import diag=")


def _exec_hints_ns():
    import agent_helpers as ah
    ns = {"__name__": "_v288_hints"}
    ns.update({k: getattr(ah, k) for k in ("_VOV_RENAME_HINT_NEEDLE", "_VOV_RENAME_RETRY_HINT", "_VOV_SCOPE_RETRY_HINTS")})
    exec(compile(slice_function_source("_v204_ast_class_hints", source=SRC),
                 "<_v204_ast_class_hints>", "exec"), ns)
    return ns


# ---------- version + sentinel contract ----------

def test_version_288_and_selffixer_aliases_present():
    m = re.search(r'__AGENT_VERSION__\s*=\s*"([^"]+)"', SRC)
    seg = tuple(int(x) for x in (m.group(1).split(".") if m else []))
    assert m and seg >= (2, 8, 8), f"expected >=2.8.8, got {m and m.group(1)}"
    assert "selffixer-no-import" in SRC
    assert "selffixer-retry-hint FIRED" in SRC


# ---------- prompt contract: pre-imported names, no import, no math ----------

def test_selffixer_prompt_states_preimported_and_forbids_import():
    # The new prompt language must be present.
    assert "ALREADY IMPORTED" in SRC
    assert "NEVER write an" in SRC and "import" in SRC.lower()
    # The OLD false promise ("math" as a usable module + un-annotated module list) must be gone.
    assert "string methods, re module, copy module, math, json" not in SRC, \
        "stale prompt line still invites un-annotated modules incl. the never-injected `math`"


# ---------- behavioral: the corrective feedback exists for THIS failure class ----------

def test_v204_hints_emit_import_correction_for_live_trace():
    """Non-tautology: prove _v204_ast_class_hints produces an explicit do-NOT-import preamble for
    the EXACT live failure trace. Pre-patch this corrective was NEVER reached by the self-fixer
    (it re-prompted with no hint); post-patch _fix_one_req threads it in on retry."""
    ns = _exec_hints_ns()
    hint = ns["_v204_ast_class_hints"](LIVE_IMPORT_TRACE)
    assert isinstance(hint, str) and hint.strip(), "hint must be non-empty for an Import failure"
    low = hint.lower()
    assert "import" in low, "hint must mention import"
    # It must tell the model NOT to import and that the modules are pre-imported / bare names.
    assert ("do not" in low or "never" in low or "no `import`" in low or "do not write" in low)
    assert ("re" in low and "json" in low and "copy" in low), \
        "hint must name the pre-imported modules re/json/copy"


def test_v204_hints_empty_for_clean_trace():
    """Gating sanity: a trace with no known AST violation yields no hint, so attempt-0 (no prior
    failure) is unaffected and only genuine failures trigger corrective feedback."""
    ns = _exec_hints_ns()
    assert ns["_v204_ast_class_hints"]("").strip() == ""
    assert ns["_v204_ast_class_hints"]("some unrelated runtime error: KeyError").strip() == ""


# ---------- wiring: the fix is live, not dead code (§8.4) ----------

def _selffixer_class_src():
    """_call_opus / _fix_one_req are SelfFixer METHODS, not module-level defs, so slice the class
    block out of SRC by indentation."""
    lines = SRC.splitlines(keepends=True)
    start = next(i for i, l in enumerate(lines) if l.startswith("class SelfFixer"))
    out = [lines[start]]
    for l in lines[start + 1:]:
        if l.strip() and not l[0].isspace() and not l.startswith(("#",)):
            break
        out.append(l)
    return "".join(out)


def test_call_opus_accepts_and_prepends_retry_hint():
    cls = _selffixer_class_src()
    assert "def _call_opus(self, req_id, req_text, req_evidence, model_digest, retry_hint=" in cls, \
        "_call_opus signature must accept retry_hint"
    assert "prompt = retry_hint + " in cls, "_call_opus must prepend retry_hint to the prompt"


def test_fix_one_req_threads_ast_hints_on_retry():
    cls = _selffixer_class_src()
    # The retry hint must be computed from the prior failure via the shared helper, gated on attempt>0.
    assert "_v204_ast_class_hints(last_err" in cls, \
        "_fix_one_req must feed last_err through _v204_ast_class_hints"
    assert "attempt > 0" in cls and "last_err" in cls, \
        "retry hint must be gated on attempt>0 with a non-empty last_err"
    assert "retry_hint=_retry_hint" in cls, "_fix_one_req must pass retry_hint into _call_opus"

"""Behavioral tests for v2.8.9 — eight VOV/§3c root-cause fixes.

Audit source: killed-swarm line-by-line audit of gov_transport (mvm_v1 agent 2.8.2 / mvm_v2 agent 2.8.5)
and restaurants (ecm_v2 agent 2.8.7), plus the live construction v2.8.8 SelfFixer run.

FIX 1  vov-strip-import-pre-ast    : strip `import`/`from-import` lines before AST validation +
                                     pre-inject a safe stdlib superset as bare names in the sandbox.
FIX 2  vov-surface-sandbox-diag    : feed the REAL sandbox exception (verifier_diag) into the retry
                                     prompt instead of the misleading 'returned NoneType'.
FIX 3  selffixer schema keys       : _SELFFIXER_PROMPT MODEL SHAPE used "product"/"data_type" but the
                                     live model uses "name"/"type" -> every lookup missed -> 'target
                                     product not found'. Fix keys + add CREATE-THEN-MUTATE.
FIX 6  vov-bridge-retry-empty      : empty/None LLM response (429/throttle) crashed complete_json on
                                     the FIRST occurrence; retry with adaptive backoff before raising.
FIX 7  vov-respect/restore-user-product-name : gov_transport next_vibes PRIORITY-1/2 proved the pipeline
                                     stripped user literal 'project_material'->'material' and the
                                     SelfFixer rename-back failed. §3c: never strip/typo a user name;
                                     restore mangled near-matches deterministically.
FIX 8  literal-name contract       : generation prompt must reproduce user names character-for-char
                                     (eoo_compliance, NOT eeo_compliance).

NOT-A-BUG (documented, no code change): FIX 5 fidelity-gate precision<0.85 is the adherence ratio
itself reported correctly; raising adherence (FIX 3/7) raises it. "Fixing" the gate would mask it.
"""
import re
import sys
import types

from notebook_source_util import notebook_concat_source, exec_function_namespace, pk_suffix_globals, vov_ledger_globals

SRC = notebook_concat_source()


# ============================ version + alias contract ============================

def test_version_289_and_all_aliases_present():
    m = re.search(r'__AGENT_VERSION__\s*=\s*"([^"]+)"', SRC)
    seg = tuple(int(x) for x in (m.group(1).split(".") if m else []))
    assert m and seg >= (2, 8, 9), f"expected >=2.8.9, got {m and m.group(1)}"
    for alias in (
        "vov-strip-import-pre-ast FIRED",
        "vov-surface-sandbox-diag FIRED",
        "vov-bridge-retry-empty FIRED",
        "vov-respect-user-product-name FIRED",
        "vov-restore-user-product-name FIRED",
    ):
        assert alias in SRC, f"missing FIRED sentinel: {alias}"


# ============================ FIX 7/8: user-product-name SSOT ============================

def test_user_product_tokens_extracts_vibe_and_musthave():
    ns = exec_function_namespace("_vov_user_product_tokens")
    fn = ns["_vov_user_product_tokens"]
    cfg = {
        "PROMPT_VARIABLES": {"business_config": {
            "vibe_modelling_instructions": "project domain has project_material and project_schedule; hr has eoo_compliance",
            "must_have_data_products": "vendor_contract; pay_estimate",
        }},
    }
    toks = fn(cfg)
    assert "project_material" in toks and "project_schedule" in toks and "eoo_compliance" in toks
    assert "vendor_contract" in toks and "pay_estimate" in toks
    # control: empty/None config -> empty set (no false protection)
    assert fn(None) == set()
    assert fn({}) == set()


def test_levenshtein_distances():
    ns = exec_function_namespace("_vov_levenshtein")
    lev = ns["_vov_levenshtein"]
    assert lev("eeo_compliance", "eoo_compliance") == 1
    assert lev("material", "material") == 0
    assert lev("material", "project_material") >= 3  # far -> not a typo


def test_match_user_token_restores_and_is_conservative():
    """NON-TAUTOLOGY: prove restore fires for the two real gov_transport mangles AND does NOT fire for an
    unrelated product (control) nor for an already-correct name (no-op)."""
    ns = exec_function_namespace(
        "_vov_match_user_token",
        extra_globals={"_vov_levenshtein": exec_function_namespace("_vov_levenshtein")["_vov_levenshtein"]},
    )
    match = ns["_vov_match_user_token"]
    toks = {"project_material", "project_schedule", "eoo_compliance"}
    # (a) prefix-strip mangle: model has 'material' in domain 'project' -> restore 'project_material'
    assert match("material", "project", toks) == "project_material"
    assert match("schedule", "project", toks) == "project_schedule"
    # (b) typo-correction mangle: model has 'eeo_compliance' -> restore 'eoo_compliance'
    assert match("eeo_compliance", "hr", toks) == "eoo_compliance"
    # control 1: a genuinely unrelated product is NOT renamed
    assert match("employee", "hr", toks) is None
    # control 2: already-correct user literal is a no-op (returns None)
    assert match("project_material", "project", toks) is None
    # control 3: ambiguity guard — two tokens equally near -> no action
    assert match("xyz", "d", {"abc", "abd"}) is None


def test_enforce_naming_restores_user_literal_end_to_end():
    """End-to-end on the REAL enforce_naming_conventions: with the user vibe naming
    'project_material', the strip that produced 'material' is REVERSED back to 'project_material'.
    Pre-patch (no config / name not in vibe) the strip stands — proving non-tautology."""
    import re as _re, copy as _copy
    deps = {**vov_ledger_globals(), "re": _re, "copy": _copy, "_VIBE_SCOPE_RUNTIME": None, **pk_suffix_globals()}
    for dep in ("strip_domain_prefix", "apply_convention", "get_pk_suffix", "strip_product_prefix",
                "_vov_user_product_tokens", "_vov_levenshtein", "_vov_match_user_token",
                "_vibe_scope_product_test", "_vibe_scope_note_rename"):
        try:
            deps.update({k: v for k, v in exec_function_namespace(dep, extra_globals=dict(deps)).items() if k == dep})
        except LookupError:
            pass
    ns = exec_function_namespace("enforce_naming_conventions", extra_globals=deps)
    enforce = ns["enforce_naming_conventions"]
    cfg = {"PROMPT_VARIABLES": {"business_config": {
        "vibe_modelling_instructions": "the project domain product list includes project_material and project_schedule",
    }}, "MODEL_CONVENTIONS": {"data_asset_naming_convention": "snake_case"}}

    # the model came out of generation with the prefix STRIPPED (the bug)
    prods = [{"domain": "project", "product": "material", "primary_key": "material_id"}]
    enforce(prods, [], logger=None, config=cfg)
    assert prods[0]["product"] == "project_material", \
        f"§3c restore failed: got {prods[0]['product']!r}"

    # CONTROL (pre-patch behavior): same product, but user vibe does NOT name it -> normal strip stands
    prods2 = [{"domain": "project", "product": "project_temp", "primary_key": "project_temp_id"}]
    enforce(prods2, [], logger=None, config={"MODEL_CONVENTIONS": {"data_asset_naming_convention": "snake_case"}})
    assert prods2[0]["product"] == "temp", \
        f"control failed: redundant prefix should still strip without user protection, got {prods2[0]['product']!r}"


def test_naming_loop_wires_restore_decision():
    """§8.4 wiring guard: the product loop must actually CALL the decision fn and use its result."""
    assert "_vov_match_user_token(product, domain, _vov_user_toks)" in SRC
    assert "_vov_user_toks = _vov_user_product_tokens(config)" in SRC
    assert "cleaned = _vov_restore" in SRC


# ============================ FIX 8: literal-name contract in gen prompt ============================

def test_gen_prompt_has_literal_name_contract():
    assert "LITERAL-NAME CONTRACT" in SRC
    assert "eoo_compliance" in SRC and "never `eeo_compliance`" in SRC
    assert "CHARACTER-FOR-CHARACTER" in SRC


# ============================ FIX 3: selffixer schema keys ============================

def test_selffixer_prompt_uses_correct_keys():
    # the MODEL SHAPE must now declare the canonical live keys
    assert '"name": "<product_name>"' in SRC, "product NAME key must be 'name' (live model shape)"
    assert '{"name": "<col>", "type": "BIGINT"' in SRC, "attribute TYPE key must be 'type'"
    # the stale wrong keys in the SHAPE excerpt must be gone
    assert '"product": "<product_name>"' not in SRC, "stale 'product' product-key still in prompt"
    assert '"data_type": "BIGINT", "foreign_key_to"' not in SRC, "stale 'data_type' attr-key still in prompt"
    # resilient lookup + create-then-mutate guidance present
    assert 'p.get("name") or p.get("product")' in SRC
    assert 'a.get("type") or a.get("data_type")' in SRC
    assert "CREATE-THEN-MUTATE" in SRC


# ============================ FIX 2: surface sandbox diag into retry ============================

def test_retry_feedback_surfaces_sandbox_diag():
    # the None-model guard must now append the real sandbox verifier_diag to the LLM feedback
    assert '_vov_sbx_diag = getattr(result, "verifier_diag", "") or ""' in SRC
    assert 'sandbox_diag: {_vov_sbx_diag}' in SRC


# ============================ FIX 1: import-strip + stdlib superset ============================

def _slice_nested(def_line, end_marker):
    i = SRC.find(def_line)
    assert i != -1, f"{def_line} not found"
    j = SRC.find(end_marker, i)
    assert j != -1
    block = SRC[i:j]
    # dedent to module level
    lines = block.split("\n")
    base = len(lines[0]) - len(lines[0].lstrip())
    return "\n".join(l[base:] if len(l) >= base else l for l in lines)


def test_strip_import_lines_drops_imports_keeps_usage():
    body = _slice_nested("def _vov_strip_import_lines(_src):",
                         "    mutator_src, _vov_msd = _vov_strip_import_lines")
    ns = {}
    exec(compile(body, "<strip>", "exec"), ns)
    strip = ns["_vov_strip_import_lines"]
    src = "import math\nfrom collections import OrderedDict\nx = re.search('a','b')\nreturn model"
    out, dropped = strip(src)
    assert dropped == 2, f"expected 2 import lines dropped, got {dropped}"
    assert "import" not in out, "import lines must be gone"
    assert "re.search" in out and "return model" in out, "real logic must be preserved"
    # control: no imports -> unchanged, zero dropped
    clean = "x = json.dumps({})\nreturn model"
    out2, d2 = strip(clean)
    assert d2 == 0 and out2 == clean


def test_sandbox_prefix_preinjects_stdlib_superset():
    # the subprocess runner must import the safe superset so stripped bare names resolve
    for mod in ("collections", "itertools", "math", "datetime", "string", "functools"):
        assert re.search(rf'^import {mod}$', SRC, re.M), f"sandbox prefix missing pre-import: {mod}"


# ============================ FIX 6: bridge retry on empty/None ============================

def _slice_bridge_complete_json():
    """The v2.8.9 bridge complete_json is the one referencing 'vov_2_0_sandbox'. Slice it as a
    standalone function and dedent so we can exec + call with a fake self."""
    anchor = "def complete_json(self, system: str, user: str, temperature: float = 0.0, response_schema: Any = None) -> Any:"
    i = SRC.find(anchor)
    assert i != -1
    # back up to the start of the def line to capture its leading indentation
    line_start = SRC.rfind("\n", 0, i) + 1
    lines = SRC[line_start:].split("\n")
    def_indent = len(lines[0]) - len(lines[0].lstrip())
    out = [lines[0]]
    for l in lines[1:]:
        if l.strip():
            ind = len(l) - len(l.lstrip())
            # stop at the next sibling method / dedent below the def's own indent
            if ind <= def_indent:
                break
        out.append(l)
    if def_indent:
        out = [l[def_indent:] if len(l) >= def_indent else l for l in out]
    return "\n".join(out)


class _FakeAgent:
    def __init__(self, responses):
        self.responses = list(responses)
        self.calls = 0

    def _call_ai_query(self, **kw):
        r = self.responses[self.calls]
        self.calls += 1
        return r


class _FakeLogger:
    def info(self, *a, **k): pass
    def warning(self, *a, **k): pass
    def error(self, *a, **k): pass


def _make_bridge_fn():
    block = _slice_bridge_complete_json()
    ns = {"Any": object, "json": __import__("json")}
    exec(compile(block, "<bridge>", "exec"), ns)
    return ns["complete_json"]


def test_bridge_retries_empty_then_succeeds(monkeypatch_time=True):
    # speed up: stub time.sleep so backoff doesn't wait
    real_time = sys.modules.get("time")
    fake_time = types.ModuleType("time")
    fake_time.sleep = lambda *_: None
    sys.modules["time"] = fake_time
    try:
        fn = _make_bridge_fn()
        bridge = types.SimpleNamespace(
            ai_agent=_FakeAgent([None, "", '{"ok": 1}']),
            system_prompt_id="VOV_2_SANDBOX",
            logger=_FakeLogger(),
        )
        out = fn(bridge, "sys", "user")
        assert out == {"ok": 1}, f"bridge should recover after 2 empty responses, got {out!r}"
        assert bridge.ai_agent.calls == 3, "should have retried twice before success"
    finally:
        if real_time is not None:
            sys.modules["time"] = real_time


def test_bridge_raises_after_all_empty():
    real_time = sys.modules.get("time")
    fake_time = types.ModuleType("time")
    fake_time.sleep = lambda *_: None
    sys.modules["time"] = fake_time
    try:
        fn = _make_bridge_fn()
        bridge = types.SimpleNamespace(
            ai_agent=_FakeAgent([None, None, None]),
            system_prompt_id="VOV_2_SANDBOX",
            logger=_FakeLogger(),
        )
        raised = False
        try:
            fn(bridge, "sys", "user")
        except RuntimeError as e:
            raised = True
            assert "vov-bridge-no-silent-empty" in str(e)
        assert raised, "all-empty must raise (no silent empty), not return"
        assert bridge.ai_agent.calls == 3, "should attempt exactly 3 times"
    finally:
        if real_time is not None:
            sys.modules["time"] = real_time

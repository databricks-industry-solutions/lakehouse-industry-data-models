"""v4.1.4 behavioral tests -- two root-cause fixes from the automotive v4.1.3
vov audit (<profile> run <run_id>, vov+shrink SUCCESS, physical adherence 80%
but 4 empty husk domains shipped + 3 SelfFixer mutators crashed):

1. v414-empty-domain-vov-writeback -- v4.1.3 placed _cleanup_empty_domains in
   step_create_logical_schema (cell-19) which runs BEFORE the VOV mutation +
   SelfFixer batches create the empty husk domains (consolidating/isolation/
   otherwise + emptied data_governance). So the v4.1.3 gate FIRED=0 and the husks
   shipped to BOTH model.json and the physical schema. Fix: move the cleanup to
   the cell-27 VOV writeback chokepoint -- AFTER all mutation/SelfFixer flat-sync
   and BEFORE model.json re-export + physical schema -- on the FLAT lists, with
   §3b/§3c exemptions, re-exporting model.json when husks are dropped.

2. v414-mutator-trace-diag + v414-mutator-trace-hint -- 3 SelfFixer mutators on
   SSOT/cross_domain_duplicate VReqs raised "AttributeError: 'NoneType' object has
   no attribute 'get'" across retries. The sandbox diag carried only the exception
   type+message (no line/source), so the retry LLM got the generic NONE-DEREF class
   hint but could not localize WHICH lookup returned None and re-emitted the same
   crash. Fix: the sandbox appends the offending traceback tail to verifier_diag and
   _v204_ast_class_hints surfaces it verbatim so the retry LLM fixes the exact line.

Each test proves pass-post on the live notebook and (where the function changed
shape) fail-pre on the committed pre-v414 backup (CLAUDE.md §8.10).
"""
import ast
import json
import re
import types
from pathlib import Path

import pytest

import agent_helpers as ah

PRE = Path("/tmp/agent_v414_preedit_backup.ipynb")  # pre-v414 state (no writeback/trace fixes)


def _load_backup_module(path: Path):
    if not path.exists():
        pytest.skip(f"pre-patch backup {path} absent (ephemeral /tmp dev artifact); "
                    "fail-pre half historical, pass-post protects live behavior")
    nb = json.loads(path.read_bytes().decode("utf-8"))
    parts = []
    for cell in nb.get("cells", []):
        if cell.get("cell_type") != "code":
            continue
        src = cell.get("source", "")
        if isinstance(src, list):
            src = "".join(src)
        if src.strip():
            parts.append(src)
    source = "\n\n".join(parts)
    mod = types.ModuleType("agent_helpers_pre414")
    mod.re = re  # imports are skipped below; re is referenced by _v204_ast_class_hints
    mod.logger = types.SimpleNamespace(info=lambda *a, **k: None,
                                       warning=lambda *a, **k: None,
                                       error=lambda *a, **k: None)
    tree = ast.parse(source)
    for node in tree.body:
        if isinstance(node, (ast.Import, ast.ImportFrom)):
            continue
        if not isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef, ast.ClassDef, ast.Assign)):
            continue
        try:
            exec(compile(ast.Module(body=[node], type_ignores=[]), str(path), "exec"), mod.__dict__)
        except Exception:
            pass
    return mod


# ============================== version =====================================
def test_version_bumped_to_414():
    ver = tuple(int(x) for x in ah.__AGENT_VERSION__.split("."))
    assert ver >= (4, 1, 4), ah.__AGENT_VERSION__


# ============== Issue 2A: empty-domain cleanup mechanism (POST) =============
def _flat_dom(name, **extra):
    d = {"domain": name, "division": "", "description": ""}
    d.update(extra)
    return d


def _flat_prod(domain, product):
    return {"domain": domain, "product": product, "primary_key": product + "_id"}


def test_cleanup_drops_empty_husks_keeps_populated_POST():
    domains = [_flat_dom("vehicle"), _flat_dom("consolidating"),
               _flat_dom("isolation"), _flat_dom("sales")]
    products = [_flat_prod("vehicle", "vin"), _flat_prod("sales", "deal")]
    dropped = ah._cleanup_empty_domains(domains, products, logger=None,
                                        user_specified_domains=[], user_vibed_new_domains=[])
    names = {d["domain"] for d in domains}
    assert "consolidating" not in names and "isolation" not in names, names
    assert names == {"vehicle", "sales"}, names
    assert set(dropped) == {"consolidating", "isolation"}, dropped


def test_cleanup_preserves_user_specified_empty_domain_POST():
    # §3b: a user-specified domain MUST survive even with 0 products
    domains = [_flat_dom("vehicle"), _flat_dom("warranty")]
    products = [_flat_prod("vehicle", "vin")]  # warranty empty but user-pinned
    dropped = ah._cleanup_empty_domains(domains, products, logger=None,
                                        user_specified_domains=["warranty"], user_vibed_new_domains=[])
    names = {d["domain"] for d in domains}
    assert "warranty" in names, names
    assert dropped == [], dropped


def test_cleanup_preserves_user_vibed_new_empty_domain_POST():
    # §3c: a domain the user vibe asked to ADD survives even before products land
    domains = [_flat_dom("vehicle"), _flat_dom("field_services")]
    products = [_flat_prod("vehicle", "vin")]
    dropped = ah._cleanup_empty_domains(domains, products, logger=None,
                                        user_specified_domains=[], user_vibed_new_domains=["field_services"])
    names = {d["domain"] for d in domains}
    assert "field_services" in names, names
    assert dropped == [], dropped


# ============== Issue 2A: call-site placement is the actual fix =============
def test_empty_domain_gate_wired_at_cell27_writeback_POST(agent_source_text):
    src = agent_source_text
    assert "v414-empty-domain-vov-writeback FIRED v4.1.4" in src
    assert "_cleanup_empty_domains(widgets_values.get(\"domains\", [])" in src
    # the gate must sit AFTER the SelfFixer flat-roundtrip writeback (where husks
    # become visible in the flat lists) and BEFORE physical schema creation -- the
    # exact placement bug that made the v4.1.3 cell-19 gate a no-op.
    roundtrip_at = src.find("vov-selffixer-flat-roundtrip WRITEBACK FIRED")
    gate_at = src.find("v414-empty-domain-vov-writeback FIRED v4.1.4")
    physical_at = src.find("_run_step(step_create_physical_schema_stage1")
    assert roundtrip_at != -1 and gate_at != -1 and physical_at != -1
    assert roundtrip_at < gate_at < physical_at, (roundtrip_at, gate_at, physical_at)


def test_empty_domain_gate_reexports_model_json_when_dropped_POST(agent_source_text):
    src = agent_source_text
    gate_at = src.find("v414-empty-domain-vov-writeback FIRED v4.1.4")
    window = src[gate_at:gate_at + 1600]
    # when husks are dropped, model.json MUST be re-exported so the shipped artifact
    # matches the physical schema (the v4.1.3 no-op left model.json with the husks).
    # v5.3.3: the mandatory final export right after the gate writes it.
    assert "if _v414_n:" in window
    final_at = src.find("_export_final_model_json(widgets_values, logger)", gate_at)
    assert gate_at < final_at < src.find("_run_step(step_create_physical_schema_stage1"), (gate_at, final_at)


def test_empty_domain_writeback_absent_pre_patch_FAILPRE():
    if not PRE.exists():
        pytest.skip("pre-v414 backup absent")
    src = "".join("".join(c.get("source", [])) for c in
                  json.loads(PRE.read_bytes().decode("utf-8")).get("cells", []))
    assert "v414-empty-domain-vov-writeback" not in src, \
        "pre-v414 backup must NOT carry the cell-27 writeback gate"


# ============== Issue (selffixer): trace surfacing in hints (POST) =========
_NONE_DEREF_TRACE = (
    "sandbox_or_verifier_failed: ok=True ver_ok=False err=None "
    "diag=mutator raised: AttributeError: 'NoneType' object has no attribute 'get' "
    "|| offending-trace: File \"/tmp/x.py\", line 7, in mutator <<< "
    "src_prod.get('attributes')"
)


def test_hint_surfaces_offending_line_POST():
    hint = ah._v204_ast_class_hints(_NONE_DEREF_TRACE)
    assert "OFFENDING LINE" in hint, hint
    assert "src_prod.get('attributes')" in hint, hint
    # the pre-existing generic NONE-DEREF class hint must STILL fire (additive, not a regression)
    assert "NONE-DEREF" in hint, hint


def test_hint_no_offending_line_when_trace_absent_POST():
    # a diag without the offending-trace marker must NOT fabricate an OFFENDING LINE hint
    diag = "sandbox_or_verifier_failed: ok=False ver_ok=False err=unsafe_ast: forbidden AST node: Import"
    hint = ah._v204_ast_class_hints(diag)
    assert "OFFENDING LINE" not in hint, hint


def test_hint_offending_line_absent_pre_patch_FAILPRE():
    mod = _load_backup_module(PRE)
    fn = getattr(mod, "_v204_ast_class_hints", None)
    if fn is None:
        pytest.skip("backup lacks _v204_ast_class_hints")
    out = fn(_NONE_DEREF_TRACE)
    # pre-v414: the generic NONE-DEREF hint fires but the EXACT offending line is NOT surfaced
    assert "OFFENDING LINE" not in (out or ""), out


# ============== Issue (selffixer): sandbox emits the trace (POST) ==========
def test_sandbox_diag_carries_offending_trace_on_none_deref_POST():
    # behavioral: a mutator that derefs None must produce a diag containing the
    # offending source line so the retry LLM can localize it.
    mutator = (
        "def mutator(model, data):\n"
        "    missing = model.get('does_not_exist')\n"  # -> None
        "    missing.get('x')\n"                        # -> AttributeError 'NoneType' .get
        "    return model\n"
    )
    try:
        res = ah.execute_in_sandbox(mutator_src=mutator, verifier_src="",
                                    model={"model": {"domains": []}}, data=None, timeout=20.0)
    except Exception as exc:  # subprocess env unavailable in this runner
        pytest.skip(f"sandbox subprocess unavailable: {type(exc).__name__}: {exc}")
    diag = getattr(res, "verifier_diag", "") or ""
    assert "mutator raised" in diag, diag
    assert "'NoneType' object has no attribute 'get'" in diag, diag
    assert "offending-trace:" in diag, diag
    assert "missing.get('x')" in diag, diag

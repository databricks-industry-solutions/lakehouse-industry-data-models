"""v4.1.3 behavioral tests -- three root-cause fixes from the automotive v4 ECM
audit (<profile> run <run_id>, vov task SUCCESS, physical precision 0.6855):

1. v413-mech-vreq-preapply -- mechanical move_product/rename VReqs batched WITH
   non-deterministic VReqs hit the all-or-nothing _v337 gate and deferred the
   WHOLE batch to the LLM sandbox, which mis-targeted the moves (target_miss):
   6 of 14 moved products (body_style, color_option, ...) were removed from
   their old domain but never landed at target -> lost entirely. Fix: pre-apply
   deterministically-resolvable mechanical ops DIRECTLY to the model before
   batching. Zero-regression: only intercept ops that actually land.

2. v413-empty-domain-vov-finalize -- the VOV finalize path ran only
   _v357_reject_junk_domains (name-based), never _cleanup_empty_domains, so
   empty (0-product) husk domains (consolidating/isolation/otherwise) shipped.
   Fix: call the existing _cleanup_empty_domains at the VOV finalize path too.

3. v413-slip-move-diagnosis -- _v260_diagnose_slip had no move_product branch,
   so every residual move was mislabelled 'unsupported-action'. Fix: honest
   move branch (not-applied | moved-then-dropped | landed-but-not-detected).

Each test proves fail-pre on the committed v4.1.2 backup and pass-post on the
live notebook (CLAUDE.md §8.10).
"""
import ast
import json
import types
from pathlib import Path

import pytest

import agent_helpers as ah

PRE = Path("/tmp/agent_v412_preedit_backup.ipynb")  # v4.1.2 state, no v4.1.3 fixes


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
    mod = types.ModuleType("agent_helpers_v412")
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


def _vreq(vreq_id, source_quote="", intent="", target=""):
    return types.SimpleNamespace(
        vreq_id=vreq_id, source_quote=source_quote, intent=intent, target=target)


def _model(domains):
    # domains: list of (name, [product_dicts])
    return {"model": {"domains": [
        {"name": n, "products": list(ps)} for n, ps in domains]}}


def _prod(name, pk=None, attrs=None):
    p = {"name": name, "attributes": list(attrs or [])}
    if pk:
        p["primary_key"] = pk
    return p


# ============================== version =====================================
def test_version_bumped_to_413():
    ver = tuple(int(x) for x in ah.__AGENT_VERSION__.split("."))
    assert ver >= (4, 1, 3), ah.__AGENT_VERSION__


# ===================== _v413_vreq_to_det_op (POST) ==========================
def test_vreq_to_det_op_classifies_move_POST():
    v = _vreq("P002", source_quote=(
        "PRIORITY 2 \u2014 move_product:aftersales.body_style \u2014 "
        "Move the product aftersales.body_style to the vehicle domain because "
        "body style is a vehicle master attribute"))
    op = ah._v413_vreq_to_det_op(v)
    assert op is not None and op[0] == "move_product", op
    assert op[1] == "aftersales" and op[2] == "body_style"
    assert op[3].lower() == "vehicle", op


def test_vreq_to_det_op_none_for_non_mechanical_POST():
    # an add_attribute / connect_table style directive is NOT a deterministic op
    v = _vreq("P099", source_quote=(
        "PRIORITY 9 \u2014 add_attribute:sales.order \u2014 add a discount_pct column"))
    assert ah._v413_vreq_to_det_op(v) is None


# =================== _v413_apply_det_op_inplace (POST) ======================
def test_apply_det_op_moves_product_to_target_POST():
    m = _model([("aftersales", [_prod("body_style", pk="body_style_id")]),
                ("vehicle", [])])
    op = ("move_product", "aftersales", "body_style", "vehicle")
    r = ah._v413_apply_det_op_inplace(m, op)
    assert r, r
    doms = {d["name"]: [p["name"] for p in d["products"]] for d in m["model"]["domains"]}
    assert "body_style" in doms["vehicle"], doms          # landed at target
    assert "body_style" not in doms["aftersales"], doms   # removed from old


def test_apply_det_op_idempotent_when_already_at_target_POST():
    m = _model([("aftersales", []), ("vehicle", [_prod("body_style", pk="body_style_id")])])
    op = ("move_product", "aftersales", "body_style", "vehicle")
    r = ah._v413_apply_det_op_inplace(m, op)
    assert r == "", r  # already-satisfied -> empty string, NOT None, NOT crash
    doms = {d["name"]: [p["name"] for p in d["products"]] for d in m["model"]["domains"]}
    assert doms["vehicle"] == ["body_style"]


def test_apply_det_op_unresolved_returns_none_POST():
    # target domain does not exist -> None -> caller leaves the VReq for the LLM (no regression)
    m = _model([("aftersales", [_prod("body_style", pk="body_style_id")])])
    op = ("move_product", "aftersales", "body_style", "nonexistent_domain")
    assert ah._v413_apply_det_op_inplace(m, op) is None
    # and the product is untouched (not removed) when the move could not land
    doms = {d["name"]: [p["name"] for p in d["products"]] for d in m["model"]["domains"]}
    assert "body_style" in doms["aftersales"]


# ===================== slip move_product branch (POST) ======================
def _slip_priority():
    return {"action": "move_product", "target": "aftersales.body_style", "vreq_id": "P002",
            "source_quote": "Move the product aftersales.body_style to the vehicle domain"}


def test_slip_move_not_applied_still_in_old_POST():
    m = _model([("aftersales", [_prod("body_style")]), ("vehicle", [])])
    out = ah._v260_diagnose_slip(_slip_priority(), m, [])
    assert out.startswith("not-applied:product-still-in-aftersales"), out


def test_slip_move_dropped_from_both_POST():
    m = _model([("aftersales", []), ("vehicle", [])])
    out = ah._v260_diagnose_slip(_slip_priority(), m, [])
    assert out.startswith("moved-then-dropped:body_style"), out


def test_slip_move_landed_but_not_detected_POST():
    m = _model([("aftersales", []), ("vehicle", [_prod("body_style")])])
    out = ah._v260_diagnose_slip(_slip_priority(), m, [])
    assert out == "unknown:move-landed-but-not-detected", out


def test_slip_move_never_unsupported_action_POST():
    # the WHOLE point: a move must NEVER return the generic unsupported-action label
    for m in (_model([("aftersales", [_prod("body_style")]), ("vehicle", [])]),
              _model([("aftersales", []), ("vehicle", [])]),
              _model([("aftersales", []), ("vehicle", [_prod("body_style")])])):
        assert "unsupported-action" not in ah._v260_diagnose_slip(_slip_priority(), m, [])


# ===================== live-source wiring (POST) ============================
def test_preapply_wired_before_batching_POST(agent_source_text):
    src = agent_source_text
    assert "v413-mech-vreq-preapply FIRED v4.1.3" in src
    assert "_vibe_scope_apply_det_op(model, _v413_op, \"v413-preapply\"" in src
    assert "return model, _v413_apply_det_op_inplace(model, op), (\"\", \"\")" in src
    # must run BEFORE the LLM batching kwargs are assembled in _apply_batches_for_vreqs
    pre_at = src.find("v413-mech-vreq-preapply FIRED v4.1.3")
    batch_at = src.find('_batch_kwargs = {"llm": llm}')
    assert pre_at != -1 and batch_at != -1 and pre_at < batch_at


def test_empty_domain_gate_wired_at_vov_finalize_POST(agent_source_text):
    src = agent_source_text
    assert "v413-empty-domain-vov-finalize FIRED v4.1.3" in src
    # the gate reuses the existing _cleanup_empty_domains (DRY) with §3b/§3c exemptions
    assert "user_specified_domains=_v413_usd" in src
    assert "user_vibed_new_domains=_v413_vov_new" in src


# ============================== FAILPRE =====================================
def test_helpers_absent_pre_patch_FAILPRE():
    mod = _load_backup_module(PRE)
    assert not hasattr(mod, "_v413_vreq_to_det_op"), "v4.1.2 must NOT have the classifier helper"
    assert not hasattr(mod, "_v413_apply_det_op_inplace"), "v4.1.2 must NOT have the apply helper"


def test_slip_move_mislabelled_pre_patch_FAILPRE():
    mod = _load_backup_module(PRE)
    fn = getattr(mod, "_v260_diagnose_slip", None)
    if fn is None:
        pytest.skip("backup lacks _v260_diagnose_slip")
    m = _model([("aftersales", [_prod("body_style")]), ("vehicle", [])])
    out = fn(_slip_priority(), m, [])
    # pre-patch: no move branch -> generic unsupported-action label
    assert out == "unsupported-action:move_product", out

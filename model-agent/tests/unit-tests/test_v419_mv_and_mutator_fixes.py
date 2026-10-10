import ast
import json
import os
import re

import pytest

from notebook_source_util import vov_ledger_globals

NB_HEAD = os.path.join(os.path.dirname(__file__), "..", "..", "agent", "dbx_vibe_modelling_agent.ipynb")
NB_PRE = "/tmp/agent_pre_v419.ipynb"


def _nb_source(path):
    nb = json.load(open(path))
    return "\n".join(
        "".join(c.get("source", [])) for c in nb.get("cells", []) if c.get("cell_type") == "code"
    )


def _extract_func(src, name):
    """Pull a top-level FunctionDef out of the concatenated notebook source and return its source text."""
    tree = ast.parse(src)
    for node in ast.walk(tree):
        if isinstance(node, ast.FunctionDef) and node.name == name:
            return ast.get_source_segment(src, node)
    return None


# ----------------------------------------------------------------------------
# RC-A: 'name' removed from the MV column-prevalidate keyword denylist.
# Behavioral: a dimension expr referencing a `name` column ABSENT from the table
# must now be flagged bad (prunable). PRE-patch (name in KW) it was skipped.
# ----------------------------------------------------------------------------

# Faithful reproduction of _mvcp_bad_in_expr's token test (the single decision the patch changes).
def _bad_in_expr(expr_raw, src_cols, sql_kw, fns=frozenset()):
    ec = re.sub(r"'[^'\n]*'", " ", expr_raw)
    ec = re.sub(r'"[^"\n]*"', " ", ec)
    ec = re.sub(r"\b([a-z_][a-z0-9_]*)\s*\.", " ", ec)
    bad = set()
    for tm in re.finditer(r"\b([a-z_][a-z0-9_]*)\b", ec.lower()):
        t = tm.group(1)
        if t in sql_kw or t in fns or t.isdigit():
            continue
        if t not in src_cols:
            bad.add(t)
    return bad


def test_rcA_name_flagged_when_absent_post():
    """POST: with 'name' NOT in the denylist, expr 'name' on a table lacking `name` is flagged -> pruned."""
    src_cols = {"format", "created_at", "rating_id", "updated_at", "creative_id"}  # the real MVM advertising_creative cols
    kw_post = {"select", "from", "count", "sum"}  # 'name' NOT present (post-fix)
    assert "name" in _bad_in_expr("name", src_cols, kw_post)


def test_rcA_name_masked_when_in_denylist_pre():
    """PRE: with 'name' in the denylist (the bug), the missing column escapes detection (fail-pre proof)."""
    src_cols = {"format", "created_at", "rating_id", "updated_at", "creative_id"}
    kw_pre = {"select", "from", "count", "sum", "name"}  # 'name' present (pre-fix bug)
    assert "name" not in _bad_in_expr("name", src_cols, kw_pre)


def test_rcA_present_name_never_flagged():
    """A table that HAS `name` keeps it regardless of the denylist (no false prune)."""
    src_cols = {"name", "panel_id", "created_at"}
    assert "name" not in _bad_in_expr("name", src_cols, {"select", "from"})


def test_rcA_name_removed_from_notebook_kw():
    src = _nb_source(NB_HEAD)
    # the exact post-fix denylist line (no 'name')
    assert "'measures','filter','expr',\\n" in src.replace('"', "") or "'measures','filter','expr'," in src
    assert "v419-mvcp-name-not-keyword" in src


def test_rcA_name_present_in_pre_baseline():
    if not os.path.exists(NB_PRE):
        pytest.skip("pre-patch baseline /tmp/agent_pre_v419.ipynb not present")
    pre = _nb_source(NB_PRE)
    assert "'measures','filter','name','expr'" in pre, "pre-patch must still have 'name' in the MV KW denylist"


# ----------------------------------------------------------------------------
# RC-B: raw-SQL FROM/JOIN source existence check for strict-unparseable MVs.
# ----------------------------------------------------------------------------

# Faithful reproduction of _mvcp_referenced_absent_tables.
_ANYTBL = re.compile(r'(?is)(?:\bfrom\b|\bjoin\b|source:)\s*"?`?(?:[a-z_][a-z0-9_]*`?\s*\.\s*`?)*([a-z_][a-z0-9_]*)`?')
_FNFROM = re.compile(r'(?is)\b(?:extract|substring|substr|trim|overlay|position)\s*\([^)]*\)')


def _absent_tables(stmt, table_names):
    scan = _FNFROM.sub(" ", stmt)
    refs = set(m.group(1).lower() for m in _ANYTBL.finditer(scan))
    return sorted(t for t in refs if t and t not in table_names)


def test_rcB_bare_from_absent_table_detected():
    """The real media_broadcasting failure: a vibe-KPI raw SQL with bare FROM artefact_log (absent) -> drop."""
    stmt = "SELECT artefact_type, COUNT(*) AS artefact_count, MAX(generated_at) AS last_generated FROM artefact_log GROUP BY artefact_type"
    assert _absent_tables(stmt, {"ad_campaign", "invoice"}) == ["artefact_log"]


def test_rcB_existing_table_not_dropped():
    stmt = "SELECT * FROM ad_campaign"
    assert _absent_tables(stmt, {"ad_campaign"}) == []


def test_rcB_qualified_source_absent_table():
    stmt = 'source: "vibe_cat.advertising.artefact_log"'
    assert _absent_tables(stmt, {"ad_campaign"}) == ["artefact_log"]


def test_rcB_extract_from_not_false_flagged():
    """EXTRACT(year FROM order_date) must NOT treat order_date as a table (SQL-standard FROM-in-function)."""
    stmt = "SELECT EXTRACT(year FROM order_date) AS y FROM ad_campaign"
    # order_date is stripped with the EXTRACT(...) clause; only ad_campaign (present) remains -> no absent
    assert _absent_tables(stmt, {"ad_campaign"}) == []


def test_rcB_substring_from_not_false_flagged():
    stmt = "SELECT SUBSTRING(code FROM 2) AS c FROM ad_campaign"
    assert _absent_tables(stmt, {"ad_campaign"}) == []


def test_rcB_notebook_has_fix():
    src = _nb_source(NB_HEAD)
    assert "v419-mv-unparseable-source-existence" in src
    assert "_mvcp_referenced_absent_tables" in src
    assert "_mvcp_table_names = set(" in src
    assert "[v419-mv-unparseable-source-existence FIRED]" in src


def test_rcB_absent_in_pre_baseline():
    if not os.path.exists(NB_PRE):
        pytest.skip("pre-patch baseline not present")
    pre = _nb_source(NB_PRE)
    assert "v419-mv-unparseable-source-existence" not in pre
    # pre-patch the branch was a bare keep
    assert "                if not _src_m:\n                    _kept2.append(_stmt)\n                    continue" in pre


# ----------------------------------------------------------------------------
# RC-C: 'list' added to the mutator scalar-attribute hint regex/advice.
# Behavioral: run the REAL _v204_ast_class_hints from the notebook.
# ----------------------------------------------------------------------------

class _DummyLogger:
    def info(self, *a, **k):
        pass

    def warning(self, *a, **k):
        pass


def _load_hint_fn(path):
    src = _nb_source(path)
    fn_src = _extract_func(src, "_v204_ast_class_hints")
    assert fn_src, "_v204_ast_class_hints not found in notebook"
    ns = {**vov_ledger_globals(), "re": re, "logger": _DummyLogger()}
    exec(compile(fn_src, "<hintfn>", "exec"), ns)
    return ns["_v204_ast_class_hints"]


_LIST_SPLIT_TRACE = "sandbox_diag: mutator raised: AttributeError: 'list' object has no attribute 'split' || offending-trace: File \"/tmp/x/_vov_runner.py\", line 200, in mutator <<< tag_set = set(p.get('tags').split(','))"


def test_rcC_list_split_hint_emitted_post():
    fn = _load_hint_fn(NB_HEAD)
    out = fn(_LIST_SPLIT_TRACE)
    assert "LIST-NOT-STRING" in out, "v4.1.9 must surface a list-specific hint for 'list'.split"


def test_rcC_list_get_hint_emitted_post():
    fn = _load_hint_fn(NB_HEAD)
    out = fn("AttributeError: 'list' object has no attribute 'get'")
    assert "LIST-NOT-DICT" in out


def test_rcC_no_list_hint_in_pre_baseline():
    if not os.path.exists(NB_PRE):
        pytest.skip("pre-patch baseline not present")
    fn = _load_hint_fn(NB_PRE)
    out = fn(_LIST_SPLIT_TRACE)
    assert "LIST-NOT-STRING" not in out, "pre-patch must NOT emit a list-split hint (the bug: 'list' omitted from regex)"


def test_rcC_str_hint_unregressed():
    """The pre-existing str-append hint must still fire (no regression to v4.0.2 behavior)."""
    fn = _load_hint_fn(NB_HEAD)
    out = fn("AttributeError: 'str' object has no attribute 'append'")
    assert "STRING-NOT-LIST" in out


def test_rcC_notebook_has_fix():
    src = _nb_source(NB_HEAD)
    assert "(str|list|dict|int|float|bool|bytes|set|tuple)" in src
    assert "v419-list-split-hint" in src
    assert "[v419-list-split-hint FIRED]" in src


# ----------------------------------------------------------------------------
# version bump
# ----------------------------------------------------------------------------

def test_version_bumped_post():
    src = _nb_source(NB_HEAD)
    assert '__AGENT_VERSION__ = "4.2.7"' in src

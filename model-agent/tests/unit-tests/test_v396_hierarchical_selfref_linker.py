import ast
import pytest
from notebook_source_util import notebook_concat_source, slice_function_source

LINKER = "_post_normalization_deterministic_fk_linker"
DETECTOR = "_is_hierarchical_self_ref"


@pytest.fixture(scope="module")
def src():
    return notebook_concat_source()


def _literal_global(src, name):
    tree = ast.parse(src)
    val = _MISS = object()
    for node in tree.body:
        if isinstance(node, ast.Assign):
            for t in node.targets:
                if isinstance(t, ast.Name) and t.id == name:
                    v = node.value
                    # unwrap frozenset({...}) / set(...) which literal_eval rejects
                    if isinstance(v, ast.Call) and isinstance(v.func, ast.Name) and v.func.id in ("frozenset", "set"):
                        inner = ast.literal_eval(v.args[0]) if v.args else []
                        val = frozenset(inner)
                    else:
                        val = ast.literal_eval(v)
    assert val is not _MISS, f"{name} not found"
    return val


class _Logger:
    def info(self, *a, **k):
        pass
    def warning(self, *a, **k):
        pass


def _deps(src, cycle_returns=False):
    """Real detector + tuples; neighbor deps stubbed so the linker reaches the self-ref branch."""
    g = {
        "HIERARCHICAL_SELF_REF_PREFIXES": _literal_global(src, "HIERARCHICAL_SELF_REF_PREFIXES"),
        "_BANNED_SELF_REF_PREFIXES": _literal_global(src, "_BANNED_SELF_REF_PREFIXES"),
        "get_pk_suffix": lambda config: "_id",
        "build_pk_map": lambda products, config: {"org.org_unit": "org_unit_id"},
        "_is_pk_pattern": lambda attr_name, product, suffix, config: False,
        "extract_fk_base_name": lambda attr_name, config: attr_name.lower(),
        "_is_system_identifier_column": lambda base, attr_name=None, config=None: False,
        "_build_fk_adjacency": lambda attrs: {},
        "_would_create_bidirectional_fk": lambda *a, **k: (False, None),
        "_would_create_cycle": lambda *a, **k: cycle_returns,
        "_sync_fk_type_with_pk": lambda attr, fk_ref, attrs, logger: None,
        "_VIBE_SCOPE_RUNTIME": None,
    }
    for dep in ("get_vibe_scope_runtime", "_vibe_scope_product_test"):
        exec(compile(slice_function_source(dep, src), "<vibe-scope>", "exec"), g)
    # real detector
    exec(compile(slice_function_source(DETECTOR, src), "<det>", "exec"), g)
    return g


def _run_linker(src, attributes_data, fn_src=None, cycle_returns=False):
    g = _deps(src, cycle_returns=cycle_returns)
    exec(compile(fn_src or slice_function_source(LINKER, src), "<linker>", "exec"), g)
    products = [{"domain": "org", "product": "org_unit"}]
    g[LINKER]([], products, attributes_data, {}, _Logger())
    return attributes_data


def test_pass_post_links_hierarchical_selfref(src):
    attrs = [
        {"domain": "org", "product": "org_unit", "attribute": "org_unit_id", "is_primary_key": True},
        {"domain": "org", "product": "org_unit", "attribute": "parent_org_unit_id"},
    ]
    out = _run_linker(src, attrs)
    parent = [a for a in out if a["attribute"] == "parent_org_unit_id"][0]
    assert parent.get("foreign_key_to") == "org.org_unit.org_unit_id", parent


def test_selflink_bypasses_cycle_guard(src):
    # even if _would_create_cycle returns True, a SELF link must still land (R5 bypass)
    attrs = [
        {"domain": "org", "product": "org_unit", "attribute": "org_unit_id", "is_primary_key": True},
        {"domain": "org", "product": "org_unit", "attribute": "previous_org_unit_id"},
    ]
    out = _run_linker(src, attrs, cycle_returns=True)
    prev = [a for a in out if a["attribute"] == "previous_org_unit_id"][0]
    assert prev.get("foreign_key_to") == "org.org_unit.org_unit_id", prev


def test_discriminating_banned_prefix_not_linked(src):
    # 'related_' is a BANNED self-ref prefix -> must NOT be linked as a self-ref (anti-tautology)
    attrs = [
        {"domain": "org", "product": "org_unit", "attribute": "org_unit_id", "is_primary_key": True},
        {"domain": "org", "product": "org_unit", "attribute": "related_org_unit_id"},
    ]
    out = _run_linker(src, attrs)
    rel = [a for a in out if a["attribute"] == "related_org_unit_id"][0]
    assert not rel.get("foreign_key_to"), rel


def test_fail_pre_patch_leaves_unlinked(src):
    """Reconstruct the pre-v3.9.6 linker (no self-ref branch) and prove it leaves the
    hierarchical self-ref UNLINKED -> the v3.9.6 patch is what changes observable state."""
    fn = slice_function_source(LINKER, src)
    assert "self_ref_candidate" in fn and "det-link-hierarchical-selfref" in fn, "patch missing from source"
    # strip the v3.9.6 additions to simulate pre-patch behavior
    pre = fn.replace(
        "chosen = same_domain_candidate or cross_domain_candidate or self_ref_candidate",
        "chosen = same_domain_candidate or cross_domain_candidate",
    )
    # collapse the self-ref branch back to the old unconditional skip
    import re
    pre = re.sub(
        r"if _is_hierarchical_self_ref\(attr_name, pk_name=own_pk\):\s*\n\s*self_ref_candidate = candidate\s*\n\s*else:\s*\n\s*skipped_self \+= 1",
        "skipped_self += 1",
        pre,
    )
    assert "self_ref_candidate = candidate" not in pre, "pre-patch reconstruction failed"
    attrs = [
        {"domain": "org", "product": "org_unit", "attribute": "org_unit_id", "is_primary_key": True},
        {"domain": "org", "product": "org_unit", "attribute": "parent_org_unit_id"},
    ]
    out = _run_linker(src, attrs, fn_src=pre)
    parent = [a for a in out if a["attribute"] == "parent_org_unit_id"][0]
    assert not parent.get("foreign_key_to"), "pre-patch should NOT link the self-ref (fail-pre)"

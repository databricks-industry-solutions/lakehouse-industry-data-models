"""v3.3.8 fix#2 — resurrection-guard behavioral tests (CLAUDE.md §8.10).

A user remove_fk un-links an _id column in VOV pass1. The late base-pipeline
FK-investigation (_create_missing_parent_tables_for_unlinked_fks) otherwise
re-links it (resurrection), so the user's remove_fk scores failed.

These tests call the REAL function and assert the observable state change:
  - WITHOUT the ledger: a 'parent_' self-ref _id column is re-linked ([SELF-REF]).
  - WITH the ledger (config["_widgets_values"]["_vov_removed_fk_fqns"]): the same
    column is skipped and stays unlinked (resurrection prevented).
  - NON-TAUTOLOGY: on the pre-fix2 backup, the ledger has NO effect (column is
    still resurrected) — proving the guard is what changed behaviour.
"""
import json, re, os, textwrap, pytest
from collections import defaultdict

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
NB = os.path.join(REPO, "agent", "dbx_vibe_modelling_agent.ipynb")
NB_PRE = "/tmp/agent_pre_v338fix2.ipynb"

FN = "_create_missing_parent_tables_for_unlinked_fks"
SELF_REF_PREFIXES = (
    'parent_', 'manager_', 'reporting_', 'supervisor_', 'alternate_',
    'original_', 'superseded_', 'duplicate_', 'duplicate_of_', 'follow_up_',
    'ultimate_parent_', 'base_', 'amended_', 'reversal_', 'source_', 'target_',
    'previous_', 'next_', 'replacement_', 'primary_', 'default_',
    'upstream_', 'downstream_', 'kit_parent_', 'kit_',
)


def _full_src(path):
    nb = json.load(open(path))
    return "".join(
        "".join(c.get("source", [])) if isinstance(c.get("source"), list) else c.get("source", "")
        for c in nb["cells"]
    )


def _extract_module_fn(src, name):
    m = re.search(rf"\ndef {name}\(.*?(?=\ndef )", src, re.S)
    assert m, f"{name} not found"
    return textwrap.dedent(m.group(0))


class _RecLogger:
    def __init__(self):
        self.lines = []
    def info(self, *a, **k): self.lines.append(("info", " ".join(str(x) for x in a)))
    def warning(self, *a, **k): self.lines.append(("warn", " ".join(str(x) for x in a)))
    def error(self, *a, **k): self.lines.append(("err", " ".join(str(x) for x in a)))
    def debug(self, *a, **k): pass
    def text(self): return "\n".join(t for _, t in self.lines)


def _bind_fn(path):
    src = _full_src(path)
    ns = {
        "defaultdict": defaultdict,
        "HIERARCHICAL_SELF_REF_PREFIXES": SELF_REF_PREFIXES,
        "get_pk_suffix": lambda config: "_id",
        "build_pk_map": lambda products, config: {"hr.job_family": "job_family_id"},
        "build_product_keys_set": lambda products: {"hr.job_family"},
        "_is_pk_pattern": lambda *a, **k: False,
        "extract_fk_base_name": lambda name, config: re.sub(r"_id$", "", name),
        "_is_system_identifier_column": lambda *a, **k: False,
        "normalize_fk_column_name": lambda *a, **k: None,
        "find_product_in_model": lambda *a, **k: None,
        "find_product_by_name": lambda *a, **k: None,
        "_get_vibe_constraints": lambda config: {},
        "_demote_unlinked_fk_attr_to_external_code": lambda *a, **k: False,
        "sanitize_name": lambda x: x,
        "make_product_dict": lambda *a, **k: {},
        "make_attribute_dict": lambda *a, **k: {},
        "safe_add_product": lambda *a, **k: False,
        "ensure_product_has_pk_attribute": lambda *a, **k: None,
        "build_pk_name_from_config": lambda name, config: f"{name}_id",
        "_VIBE_SCOPE_RUNTIME": None,
    }
    for dep in ("_vibe_scope_product_test", "_vibe_scope_inherit_subdomain"):
        exec(_extract_module_fn(_full_src(NB), dep), ns)
    exec(_extract_module_fn(src, FN), ns)
    return ns[FN]


def _scenario(ledger):
    """One hr.job_family product with a 'parent_' self-ref _id column (unlinked)."""
    domains = [{"domain": "hr", "product": None}]
    products = [{"domain": "hr", "product": "job_family"}]
    attrs = [
        {"domain": "hr", "product": "job_family", "attribute": "job_family_id",
         "foreign_key_to": "", "is_primary_key": True},
        {"domain": "hr", "product": "job_family", "attribute": "parent_job_family_id",
         "foreign_key_to": ""},
    ]
    config = {
        "PROMPT_VARIABLES": {"business_config": {"business": "gov_transport", "version": "1"},
                             "model_conventions_config": {"table_id_type": "BIGINT"}},
        "MODEL_SCOPE": "ecm",
        "_widgets_values": {"_vov_removed_fk_fqns": list(ledger)},
    }
    return domains, products, attrs, config


def _parent_attr(attrs):
    return next(a for a in attrs if a["attribute"] == "parent_job_family_id")


def test_without_ledger_column_is_resurrected():
    # Control: with NO ledger, the self-ref _id column gets re-linked (the bug).
    fn = _bind_fn(NB)
    domains, products, attrs, config = _scenario(ledger=[])
    log = _RecLogger()
    fn(domains, products, attrs, config, log)
    assert _parent_attr(attrs)["foreign_key_to"] == "hr.job_family.job_family_id", \
        "control: expected the self-ref column to be re-linked when no ledger present"


def test_with_ledger_column_not_resurrected():
    # Fix: with the user-remove_fk ledger, the column is NOT re-linked.
    fn = _bind_fn(NB)
    domains, products, attrs, config = _scenario(
        ledger=["hr.job_family.parent_job_family_id"])
    log = _RecLogger()
    fn(domains, products, attrs, config, log)
    assert _parent_attr(attrs)["foreign_key_to"] in ("", None), \
        "fix: ledgered column must stay unlinked (resurrection prevented)"
    assert "vov-removed-fk-resurrection-guard FIRED" in log.text(), \
        "guard must self-report a FIRED line"


def test_ledger_is_case_insensitive():
    fn = _bind_fn(NB)
    domains, products, attrs, config = _scenario(
        ledger=["HR.JOB_FAMILY.PARENT_JOB_FAMILY_ID"])
    fn(domains, products, attrs, config, _RecLogger())
    assert _parent_attr(attrs)["foreign_key_to"] in ("", None), \
        "ledger match must be case-insensitive"


def test_unrelated_ledger_does_not_block_legit_link():
    # A ledger that does NOT name this column must not suppress a legitimate re-link.
    fn = _bind_fn(NB)
    domains, products, attrs, config = _scenario(
        ledger=["hr.some_other.some_other_id"])
    fn(domains, products, attrs, config, _RecLogger())
    assert _parent_attr(attrs)["foreign_key_to"] == "hr.job_family.job_family_id", \
        "unrelated ledger entries must not block legitimate self-ref linking"


@pytest.mark.skipif(not os.path.exists(NB_PRE), reason="pre-fix2 backup not present")
def test_pre_patch_ledger_has_no_effect_non_tautology():
    # NON-TAUTOLOGY: on pre-fix2 code, the ledger does NOT exist, so the same
    # ledgered input STILL resurrects the column. Proves the guard is the cause.
    fn = _bind_fn(NB_PRE)
    domains, products, attrs, config = _scenario(
        ledger=["hr.job_family.parent_job_family_id"])
    fn(domains, products, attrs, config, _RecLogger())
    assert _parent_attr(attrs)["foreign_key_to"] == "hr.job_family.job_family_id", \
        "pre-fix2: ledger must have NO effect (column resurrected) — proves non-tautology"

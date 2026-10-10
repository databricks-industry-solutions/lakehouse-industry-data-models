"""v5.1.4 decision 13A: every PK and FK name the agent builds or detects follows primary_key_suffix.

Three families, each run on data-models/airlines/v1/mvm/model.json:
- golden: with the default `_id` config every touched deterministic function returns byte-identical
  output to commit 56ce1eb. Both modules are built in this process from their notebook sources and
  run on identical inputs, so set ordering cannot differ between them.
- behavioral: on a copy of the fixture whose keys use `_key`, with primary_key_suffix='_key', every
  PK and FK name the passes produce ends with `_key` and no `_id` name is left. The same check fails
  on 56ce1eb, which hard-codes `_id`.
- prompts: every naming prompt renders the configured suffix.
"""
import copy
import json
import re
import subprocess
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent))
import conftest  # noqa: E402
import agent_helpers as ah  # noqa: E402

BASE_COMMIT = "56ce1eb"
REPO = Path(__file__).resolve().parents[3]
RAW = json.loads((REPO / "data-models" / "airlines" / "v1" / "mvm" / "model.json").read_text())
ID_NAME = re.compile(r"(?<![A-Za-z0-9])[a-z][a-z0-9_]*_id\b")
PROMPTS = ["VIBE_CREATE_NEXT_PROMPT", "MODEL_ARCHITECT_REVIEW_PROMPT", "DOMAIN_METRICS_PROMPT", "PRODUCT_GENERATE_PROMPT",
           "PRODUCT_MERGE_SIMILAR_PROMPT", "ATTRIBUTE_GENERATE_PROMPT", "ATTRIBUTE_DEDUP_PROMPT", "FK_IN_DOMAIN_LINK_PROMPT",
           "FK_CROSS_DOMAIN_MESH_PROMPT", "FK_PAIRWISE_LINK_PROMPT", "FK_SEMANTIC_CORRECTNESS_GATE_PROMPT", "FK_MANY_TO_MANY_PROMPT",
           "FK_ANOMALY_DETECT_PROMPT", "FK_BROKEN_RESOLVE_PROMPT", "FK_BATCH_RESOLVE_PROMPT", "FK_COLUMN_RENAME_PROMPT",
           "FK_FIND_MISSING_PROMPT", "FK_CYCLE_BREAK_PROMPT", "QUALITY_NORMALIZATION_PROMPT", "DOMAIN_GENERATE_PROMPT",
           "BUSINESS_CONTEXT_PROMPT", "FK_AMBIGUOUS_RESOLVE_PROMPT"]
FORMAT_PROMPTS = {"VIBE_CREATE_NEXT_PROMPT", "FK_PAIRWISE_LINK_PROMPT", "FK_BROKEN_RESOLVE_PROMPT", "FK_SEMANTIC_CORRECTNESS_GATE_PROMPT"}
NON_KEY_TOKENS = {"pii_national_id", "batch_id", "cycle_id", "alpha_id", "alpha_id_id", "id_id"}
SUFFIX_LINE = "- Primary Key Suffix: `{pk_suffix}` (primary key = `<table_name>{pk_suffix}`; a foreign key column ends with its target table's primary key name)"


class _Log:
    def __init__(self):
        self.lines = []

    def _add(self, msg, *a, **k):
        self.lines.append(str(msg))

    info = warning = error = debug = exception = _add


_MODULES = {}


def _module_at(commit):
    if commit not in _MODULES:
        try:
            blob = subprocess.check_output(["git", "show", f"{commit}:model-agent/agent/dbx_vibe_modelling_agent.ipynb"],
                                           cwd=str(REPO), stderr=subprocess.DEVNULL)
        except Exception as exc:
            pytest.skip(f"base commit {commit} is not available in this checkout: {exc}")
        nb = json.loads(blob)
        source = "\n\n".join("".join(c["source"]) if isinstance(c["source"], list) else c["source"]
                             for c in nb["cells"] if c.get("cell_type") == "code" and "".join(c["source"]).strip())
        saved, extract = sys.modules.get("agent_helpers"), conftest._extract_source_from_notebook
        conftest._extract_source_from_notebook = lambda: source
        try:
            _MODULES[commit] = conftest._build_agent_helpers_module()
        finally:
            conftest._extract_source_from_notebook = extract
            sys.modules["agent_helpers"] = saved
    return _MODULES[commit]


def _cfg(sfx):
    return {"MODEL_CONVENTIONS": {"primary_key_suffix": sfx, "foreign_key_suffix": "", "data_asset_naming_convention": "snake_case"},
            "PROMPT_VARIABLES": {"min_data_products_per_domain": 1, "max_data_products_per_domain": 30,
                                 "min_attributes_per_product": 1, "max_attributes_per_product": 80, "max_product_name_words": 4,
                                 "table_id_type": "BIGINT", "business_config": {"business": "Airlines", "version": "2"},
                                 "model_conventions_config": {"table_id_type": "BIGINT"}},
            "MODEL_SCOPE": "mvm", "VIBE_CONTRACT": {"mode": "", "requested_transforms": {}}, "MAX_RETRIES": 1}


def _rekey(value, sfx):
    return re.sub(r"_id\b", sfx, value) if isinstance(value, str) and sfx != "_id" else value


def _fixture(sfx):
    root = copy.deepcopy(RAW)
    root["model"]["metric_views"] = []
    for d in root["model"]["domains"]:
        for p in d["products"]:
            p["primary_key"] = _rekey(p.get("primary_key", ""), sfx)
            for a in p["attributes"]:
                for k in ("name", "column_name", "foreign_key_to"):
                    a[k] = _rekey(a.get(k, ""), sfx)
    return root


def _flat(m, root):
    return [list(x) for x in m.model_to_widgets_flat(copy.deepcopy(root), quiet=True)]


def _use(m, sfx):
    cfg = _cfg(sfx)
    if hasattr(m, "_PIPELINE_CONFIG_RUNTIME"):
        m._PIPELINE_CONFIG_RUNTIME.clear()
        m._PIPELINE_CONFIG_RUNTIME["config"] = cfg
    return cfg


def _product(root, domain, product):
    d = next(d for d in root["model"]["domains"] if d["name"] == domain)
    return next(p for p in d["products"] if p["name"] == product)


def _key_names(products=(), attributes=(), extra=()):
    names = [p.get("primary_key", "") for p in products]
    for a in attributes:
        an = a.get("attribute") or a.get("name") or ""
        if a.get("foreign_key_to") or "primary_key" in str(a.get("tags") or "") or a.get("is_primary_key"):
            names.append(an)
        if a.get("foreign_key_to"):
            names.append(str(a["foreign_key_to"]).split(".")[-1])
    return [n for n in list(names) + list(extra) if n]


RUNNERS = {}


def _runner(fn):
    RUNNERS[fn.__name__] = fn
    return fn


@_runner
def enforce_naming_runtime(m, sfx):
    _use(m, sfx)
    d, p, a, _mv = _flat(m, _fixture(sfx))
    for prod in p:
        if prod["domain"] == "crew" and prod["product"] == "pairing":
            prod["product"] = prod["table_name"] = "crew_pairing"
            prod["primary_key"] = f"crew_pairing{sfx}"
    for attr in a:
        if attr["domain"] == "crew" and attr["product"] == "pairing":
            attr["product"] = "crew_pairing"
            if attr["attribute"] == f"pairing{sfx}":
                attr["attribute"] = attr["column_name"] = f"crew_pairing{sfx}"
        if attr.get("foreign_key_to") == f"crew.pairing.pairing{sfx}":
            attr["foreign_key_to"] = f"crew.crew_pairing.crew_pairing{sfx}"
    fixes = m.enforce_naming_conventions(p, a, _Log(), None)
    renamed = next(x for x in p if x["domain"] == "crew" and x["product"] == "pairing")
    return {"fixes": fixes, "products": p, "attributes": a}, _key_names(p, a, [renamed["primary_key"]])


@_runner
def enforce_naming_config(m, sfx):
    cfg = _use(m, sfx)
    d, p, a, _mv = _flat(m, _fixture(sfx))
    fixes = m.enforce_naming_conventions(p, a, _Log(), cfg)
    return {"fixes": fixes, "products": p, "attributes": a}, _key_names(p, a)


@_runner
def strip_product_prefix(m, sfx):
    _use(m, sfx)
    out = [m.strip_product_prefix(f"pairing{sfx}", "pairing"), m.strip_product_prefix("pairing_code", "pairing")]
    return out, [out[0]]


@_runner
def make_product_dict(m, sfx):
    _use(m, sfx)
    out = m.make_product_dict("Airlines", "crew", "standby_pool")
    return out, [out["primary_key"]]


def _validator(m, cfg, log, data):
    v = m.SmartWorkerValidator(log, cfg)
    v.validate_json_structure = lambda text, required_keys=None: (True, [], data)
    return v


@_runner
def validator_products(m, sfx):
    cfg = _use(m, sfx)
    log = _Log()
    data = {"domain": "crew", "products": [
        {"product": "crew_rest_period", "data_type": "transactional_data", "primary_key": "x"},
        {"product": "group", "data_type": "reference_data", "primary_key": ""},
        {"product": "duty_slot", "data_type": "transactional_data", "primary_key": "duty_slot_id"}]}
    ok, errors = _validator(m, cfg, log, data).validate_products("{}", "crew")
    return {"ok": ok, "errors": errors, "log": log.lines, "data": data}, [p["primary_key"] for p in data["products"]]


@_runner
def validator_attributes(m, sfx):
    cfg = _use(m, sfx)
    log = _Log()
    data = {"attributes": [
        {"attribute": f"standby_pool{sfx}", "type": "BIGINT", "description": "Surrogate key.", "tags": "primary_key"},
        {"attribute": "pool_name", "type": "STRING", "description": "Name of the pool."},
        {"attribute": f"base{sfx}", "type": "BIGINT", "description": "Home base.", "foreign_key_to": f"crew.base.base{sfx}"}]}
    ok, errors = _validator(m, cfg, log, data).validate_attributes("{}", "standby_pool", "crew")
    pk = [a["attribute"] for a in data["attributes"] if "primary_key" in str(a.get("tags") or "") or a.get("is_primary_key")]
    return {"ok": ok, "errors": errors, "log": log.lines, "data": data}, pk + [a["attribute"] for a in data["attributes"] if a.get("foreign_key_to")]


@_runner
def v337_rename_product(m, sfx):
    _use(m, sfx)
    root = _fixture(sfx)
    src = _product(root, "crew", "pairing")
    src["primary_key"] = f"legacy_ref{sfx}"
    for a in src["attributes"]:
        if a["name"] == f"pairing{sfx}":
            a["name"] = a["column_name"] = f"legacy_ref{sfx}"
    mdl = root["model"]
    res = m._v337_apply_rename_product(mdl, "crew", "pairing", "crew_trip")
    p = next(p for d in mdl["domains"] if d["name"] == "crew" for p in d["products"] if p["name"] == "crew_trip")
    return {"result": res, "product": p}, [p["primary_key"]] + _key_names(attributes=p["attributes"])


@_runner
def v337_split_product(m, sfx):
    _use(m, sfx)
    root = _fixture(sfx)
    _product(root, "crew", "pairing")["primary_key"] = ""
    res = m._v337_apply_split_product(root["model"], "crew", "pairing", [("pairing_leg", ["leg_sequence", "duty_slot_ref"])])
    child = _product(root, "crew", "pairing_leg")
    return {"result": res, "child": child}, [child["primary_key"]]


@_runner
def v337_reverse_fk(m, sfx):
    _use(m, sfx)
    root = _fixture(sfx)
    src = _product(root, "flight", "scheduled_flight")
    col = next(a["name"] for a in src["attributes"] if a.get("foreign_key_to", "").startswith("fleet.aircraft_type."))
    res = m._v337_apply_reverse_fk(root["model"], "flight", "scheduled_flight", col)
    tgt = _product(root, "fleet", "aircraft_type")
    return {"result": res, "target": tgt}, _key_names(attributes=tgt["attributes"])


@_runner
def v410_resolve_pk(m, sfx):
    _use(m, sfx)
    root = _fixture(sfx)
    p = _product(root, "crew", "pairing")
    p["primary_key"] = ""
    for a in p["attributes"]:
        a["tags"] = ""
        a.pop("is_primary_key", None)
    p["attributes"].sort(key=lambda a: a["name"] != f"pairing{sfx}")
    p["attributes"].insert(0, {"name": f"zz_ref{sfx}", "type": "BIGINT"})
    out = m._v410_resolve_pk(root["model"], "crew", "pairing")
    return out, [out]


@_runner
def v327_infer_coltype(m, sfx):
    _use(m, sfx)
    return [m._v327_infer_coltype(f"duty_slot{sfx}"), m._v327_infer_coltype("pool_name")], []


@_runner
def build_default_columns(m, sfx):
    cfg = _use(m, sfx)
    out = m.build_default_columns("standby_pool", cfg)
    return out, [c.get("attribute") or c.get("name") for c in (out or []) if isinstance(c, dict) and c.get("is_primary_key")]


@_runner
def product_columns_reference(m, sfx):
    _use(m, sfx)
    d, p, a, _mv = _flat(m, _fixture(sfx))
    crew = [dict(x, primary_key="") for x in p if x["domain"] == "crew"]
    attrs_map = {}
    for x in a:
        attrs_map.setdefault((x["domain"], x["product"]), []).append(x)
    out = m._build_product_columns_reference("crew", crew, attrs_map, None)
    return out, re.findall(r"PK=([A-Za-z0-9_]+)", out)


@_runner
def product_lines_with_attrs(m, sfx):
    _use(m, sfx)
    d, p, a, _mv = _flat(m, _fixture(sfx))
    crew = [{k: v for k, v in x.items() if k != "primary_key"} for x in p if x["domain"] == "crew"]
    by = {}
    for x in a:
        by.setdefault(f"{x['domain']}.{x['product']}", []).append(x["attribute"])
    out = m._format_product_lines_with_attrs(crew, "crew", by)
    return out, re.findall(r"PK: ([A-Za-z0-9_]+)", str(out))


@_runner
def essential_links(m, sfx):
    cfg = _use(m, sfx)
    d, p, a, _mv = _flat(m, _fixture(sfx))
    p = [dict(x, primary_key="") if (x["domain"], x["product"]) == ("crew", "base") else x for x in p]
    wv = {"config": cfg, "products": p, "attributes": a, "_architect_essential_links": [
        {"source_domain": "crew", "source_product": "standby", "target_domain": "crew", "target_product": "base", "reason": "home base"},
        {"source_domain": "flight", "source_product": "scheduled_flight", "target_domain": "crew", "target_product": "zzz_unknown"}]}
    m._apply_architect_essential_links(wv, _Log())
    new = [x for x in a if x.get("_essential_link")]
    return {"new": new, "links": wv.get("_architect_essential_links")}, _key_names(attributes=new)


@_runner
def structural_hardening(m, sfx):
    _use(m, sfx)
    mdl = _fixture(sfx)["model"]
    res = m._v443_structural_hardening(mdl, _Log())
    attrs = [dict(a, attribute=a.get("name")) for d in mdl["domains"] for p in d["products"] for a in p["attributes"]]
    return {"result": res, "model": mdl}, [p["primary_key"] for d in mdl["domains"] for p in d["products"]] + _key_names(attributes=attrs)


@_runner
def pre_static_analysis_autofix(m, sfx):
    cfg = _use(m, sfx)
    d, p, a, _mv = _flat(m, _fixture(sfx))
    res = m._pre_static_analysis_autofix(d, p, a, cfg, _Log())
    return {"result": res, "products": p, "attributes": a}, _key_names(p, a)


@_runner
def static_analysis(m, sfx):
    cfg = _use(m, sfx)
    d, p, a, _mv = _flat(m, _fixture(sfx))
    res = m.run_metamodel_static_analysis(d, p, a, cfg, _Log())
    return res, []


def _next_vibe_context(scope):
    def run(m, sfx):
        cfg = _use(m, sfx)
        d, p, a, _mv = _flat(m, _fixture(sfx))
        out = m._build_next_vibe_llm_context(d, p, a, cfg, {"model_scope": scope, "business_name": "Airlines"})
        return out, []
    run.__name__ = f"next_vibe_context_{scope}"
    return _runner(run)


next_vibe_context_mvm = _next_vibe_context("mvm")
next_vibe_context_ecm = _next_vibe_context("ecm")


def _canonical(value):
    return json.dumps(value, sort_keys=True, default=str)


@pytest.fixture(autouse=True)
def _reset_runtime():
    yield
    for m in [ah] + list(_MODULES.values()):
        if hasattr(m, "_PIPELINE_CONFIG_RUNTIME"):
            m._PIPELINE_CONFIG_RUNTIME.clear()


def _without_tag_list_pk_flags(out):
    out = copy.deepcopy(out)
    dropped = 0
    for d in out["model"]["domains"]:
        for p in d["products"]:
            for a in p["attributes"]:
                if "primary_key" in [t.strip() for t in str(a.get("tags") or "").split(",")] and a.pop("is_primary_key", None):
                    dropped += 1
    out["result"]["g1_pk"] -= dropped
    return out


INTENDED_CHANGES = {"structural_hardening": _without_tag_list_pk_flags}


@pytest.mark.parametrize("name", sorted(RUNNERS))
def test_default_id_output_is_byte_identical_to_56ce1eb(name):
    old = _module_at(BASE_COMMIT)
    new_out, old_out = RUNNERS[name](ah, "_id")[0], RUNNERS[name](old, "_id")[0]
    if name in INTENDED_CHANGES:
        new_out, old_out = INTENDED_CHANGES[name](new_out), INTENDED_CHANGES[name](old_out)
    assert _canonical(new_out) == _canonical(old_out)


FAIL_PRE = {"strip_product_prefix", "make_product_dict", "validator_products", "validator_attributes",
            "v337_rename_product", "v337_split_product", "v337_reverse_fk", "v410_resolve_pk", "product_columns_reference",
            "product_lines_with_attrs", "essential_links"}


def _leftovers(m, name):
    out, names = RUNNERS[name](m, "_key")
    return names, [n for n in names if re.search(r"_id\b", str(n))], [n for n in names if not str(n).endswith("_key")]


@pytest.mark.parametrize("name", sorted(RUNNERS))
def test_key_suffix_every_generated_pk_and_fk_uses_key(name):
    names, ids, not_key = _leftovers(ah, name)
    assert ids == [] and not_key == [], (ids, not_key)
    if name in FAIL_PRE:
        assert names, "runner produced no PK/FK names to check"


@pytest.mark.parametrize("name", sorted(FAIL_PRE))
def test_key_suffix_check_fails_on_56ce1eb(name):
    _names, ids, not_key = _leftovers(_module_at(BASE_COMMIT), name)
    assert ids or not_key, f"{name}: 56ce1eb already honours primary_key_suffix='_key'"


def test_infer_coltype_types_key_columns_as_bigint_only_after_the_fix():
    _use(ah, "_key")
    assert ah._v327_infer_coltype("duty_slot_key") == "BIGINT"
    old = _module_at(BASE_COMMIT)
    assert old._v327_infer_coltype("duty_slot_key") != "BIGINT"


def test_enforce_naming_renames_the_pk_of_a_stripped_product_to_the_configured_suffix():
    pks = []
    for m in (ah, _module_at(BASE_COMMIT)):
        out, _names = RUNNERS["enforce_naming_runtime"](m, "_key")
        pks.append(next(p for p in out["products"] if p["domain"] == "crew" and p["product"] == "pairing")["primary_key"])
    assert pks == ["pairing_key", "crew_pairing_key"]


def test_get_fk_suffix_falls_back_to_the_pk_suffix_when_unset():
    assert ah.get_fk_suffix(_cfg("_key")) == "_key"
    assert ah.get_fk_suffix({"MODEL_CONVENTIONS": {"primary_key_suffix": "_key", "foreign_key_suffix": "_ref"}}) == "_ref"
    _use(ah, "_key")
    assert (ah.get_pk_suffix(), ah.get_fk_suffix(None), ah.get_pk_suffix({})) == ("_key", "_key", "_key")


def _vars(template):
    names = set(re.findall(r"(?<!\{)\{([a-zA-Z_][a-zA-Z0-9_]*)\}(?!\})", template)) - {"pk_suffix", "primary_key_suffix"}
    return {n: f"<<{n}>>" for n in names}


def _render(m, name, sfx, explicit=False):
    template = m.PROMPT_TEMPLATES[name]
    variables = _vars(template)
    if explicit:
        variables.update(pk_suffix=sfx, primary_key_suffix=sfx)
    if name in FORMAT_PROMPTS:
        return template.format(**dict(variables, pk_suffix=sfx))
    return m.load_and_format_prompt(name, variables, _Log())


MV_REF_RULE_LINE = ("   Every window 'order' value and every partition 'include' entry MUST be copied verbatim from the 'name' of a "
                    "dimension in the SAME view, never from its 'display_name'; every AGG(`<measure>`) reference MUST be copied "
                    "verbatim from the 'name' of a measure in the SAME view; a partition MUST carry 'outer_aggregate'. A window "
                    "may not list the same dimension twice. A measure with a 'window' may not AGG() another measure that has "
                    "its own 'window'.")


@pytest.mark.parametrize("name", PROMPTS)
def test_prompt_renders_the_default_suffix_byte_identically_to_56ce1eb(name):
    _use(ah, "_id")
    old = _module_at(BASE_COMMIT)
    new_text = _render(ah, name, "_id", explicit=True).replace(SUFFIX_LINE.replace("{pk_suffix}", "_id") + "\n", "")
    new_text = new_text.replace(MV_REF_RULE_LINE + "\n", "")
    assert new_text == _render(old, name, "_id", explicit=True)


@pytest.mark.parametrize("name", PROMPTS)
def test_prompt_renders_key_suffix_with_no_id_names(name):
    _use(ah, "_key")
    text = _render(ah, name, "_key")
    leaks = sorted(set(ID_NAME.findall(text)) - NON_KEY_TOKENS)
    assert "{pk_suffix}" not in text and leaks == [], leaks[:20]


def test_naming_prompts_carry_id_names_at_56ce1eb():
    old = _module_at(BASE_COMMIT)
    leaking = [n for n in PROMPTS if n in old.PROMPT_TEMPLATES and sorted(set(ID_NAME.findall(old.PROMPT_TEMPLATES[n])) - NON_KEY_TOKENS)]
    assert len(leaking) >= 15, leaking


def test_model_conventions_section_states_the_configured_suffix():
    _use(ah, "_key")
    text = ah.load_and_format_prompt("PRODUCT_GENERATE_PROMPT", _vars(ah.PROMPT_TEMPLATES["PRODUCT_GENERATE_PROMPT"]), _Log())
    assert "- Primary Key Suffix: `_key` (primary key = `<table_name>_key`" in text
    assert "product_name_key" in text and "product_name_id" not in text


@pytest.mark.parametrize("scope", ["mvm", "ecm"])
def test_next_vibe_checklist_renders_the_configured_suffix(scope):
    out, _names = RUNNERS[f"next_vibe_context_{scope}"](ah, "_key")
    checklist = out["scope_aware_checklist"]
    assert "manager_employee_key" in checklist and "employee_id" not in checklist
    old_out, _ = RUNNERS[f"next_vibe_context_{scope}"](_module_at(BASE_COMMIT), "_key")
    assert "employee_id" in old_out["scope_aware_checklist"]

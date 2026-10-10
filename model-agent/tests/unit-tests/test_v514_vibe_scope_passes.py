"""v5.1.4 vibe_scope: every model-wide pass leaves the out-of-scope model untouched.

The fixture is data-models/airlines/v1/mvm/model.json with deterministic perturbations
that give each pass work to do both inside the scope (crew) and outside it (flight,
fleet, ...). Two families of tests:

- golden: with the fence OFF (All Domains) each pass must produce byte-identical output
  to agent 5.1.4 phase 1 (commit 5d386ed), captured before any guard was added. Capture
  with VIBE_SCOPE_CAPTURE_GOLDENS=1 against an unmodified notebook only.
- scoped: with the fence ON (Some Domains = crew) the pass still fixes the in-scope
  cases while fence.check reports zero violations on the out-of-scope records.
"""
import copy
import hashlib
import json
import os
import re
import subprocess
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent))
import conftest  # noqa: F401,E402
import agent_helpers as ah  # noqa: E402

REPO = Path(__file__).resolve().parents[3]
RAW = json.loads((REPO / "data-models" / "airlines" / "v1" / "mvm" / "model.json").read_text())
GOLDEN_PATH = Path(__file__).resolve().parent / "fixtures" / "v514_vibe_scope_pass_goldens.json"
VOV = "vibe modeling of version"
CAPTURE = os.environ.get("VIBE_SCOPE_CAPTURE_GOLDENS") == "1"
TAG_VIBE = (
    "add tag data_owner=crewops to all products in the crew domain\n"
    "add tag data_owner=flightops to all products in the flight domain\n"
    "add tag reviewed=yes to all remarks attributes\n"
)


class _Log:
    def __init__(self):
        self.lines = []

    def _add(self, level, msg, *args, **kwargs):
        self.lines.append((level, str(msg)))

    def info(self, msg, *a, **k):
        self._add("info", msg)

    def warning(self, msg, *a, **k):
        self._add("warning", msg)

    def error(self, msg, *a, **k):
        self._add("error", msg)

    def debug(self, msg, *a, **k):
        self._add("debug", msg)

    def exception(self, msg, *a, **k):
        self._add("error", msg)

    def text(self):
        return "\n".join(m for _, m in self.lines)


def _cfg():
    return {
        "MODEL_CONVENTIONS": {"primary_key_suffix": "_id", "data_asset_naming_convention": "snake_case",
                              "tag_prefix": "", "tag_suffix": ""},
        "PROMPT_VARIABLES": {"business_config": {"business": "airlines", "version": "2"},
                             "model_conventions_config": {"table_id_type": "BIGINT"}},
        "MODEL_SCOPE": "mvm",
        "VIBE_CONTRACT": {"mode": "", "requested_transforms": {}},
        "MAX_RETRIES": 1,
    }


def _domain(root, name):
    return next(d for d in root["model"]["domains"] if d["name"] == name)


def _product(root, domain, product):
    return next(p for p in _domain(root, domain)["products"] if p["name"] == product)


def _col(name, typ="STRING", fk=""):
    return {"name": name, "column_name": name, "type": typ, "business_glossary_term": "",
            "description": f"Test column {name}.", "value_regex": "", "tags": "", "foreign_key_to": fk, "references": ""}


def _perturbed():
    m = copy.deepcopy(RAW)
    mdl = m["model"]
    assert ah.get_vibe_scope_runtime() is None
    ah._v337_apply_rename_product(mdl, "crew", "licence", "crew_licence")
    ah._v337_apply_rename_product(mdl, "flight", "status", "flight_status")
    extra = {
        ("flight", "dispatch_release"): [_col("crew_licence_id", "BIGINT", "crew.crew_licence.crew_licence_id")],
        ("crew", "roster"): [_col("roster_remarks"), _col("backup_member_id", "BIGINT")],
        ("flight", "scheduled_flight"): [_col("scheduled_flight_remarks"),
                                         _col("anchor_flight_leg_id", "BIGINT", "flight.flight_leg.flight_leg_id")],
        ("crew", "crew_licence"): [_col("status")],
        ("fleet", "engine"): [_col("status")],
        ("crew", "duty_period"): [_col("Duty_Remarks"), _col("home_base_key", "BIGINT", "crew.base.wrong_col")],
        ("flight", "flight_leg"): [_col("Leg_Remarks"),
                                   _col("crew_roster_activity_id", "BIGINT", "crew.roster_activity.roster_activity_id")],
        ("flight", "diversion"): [_col("backup_member_id", "BIGINT")],
        ("flight", "cancellation"): [_col("relief_duty_slot_id", "BIGINT")],
        ("crew", "pairing"): [_col("zeta_widget_id", "BIGINT")],
        ("crew", "roster_activity"): [_col("zeta_widget_id", "BIGINT")],
        ("flight", "oooi_event"): [_col("omega_gizmo_id", "BIGINT")],
        ("flight", "fuel_uplift"): [_col("omega_gizmo_id", "BIGINT")],
        ("crew", "absence"): [_col("lone_thing_id", "BIGINT")],
        ("fleet", "lessor"): [_col("solo_thing_id", "BIGINT")],
        ("crew", "member"): [_col("current_roster_id", "BIGINT", "crew.roster.roster_id")],
        ("fleet", "aircraft_type"): [_col("primary_scheduled_flight_id", "BIGINT",
                                          "flight.scheduled_flight.scheduled_flight_id")],
        ("crew", "base"): [_col("anchor_pairing_id", "BIGINT", "crew.pairing.pairing_id")],
        ("flight", "irop_event"): [_col("linked_station_key", "BIGINT", "airport.station")],
    }
    for (dname, pname), cols in extra.items():
        _product(m, dname, pname)["attributes"].extend(cols)
    for dname, pname in (("crew", "training_event"), ("flight", "weight_balance")):
        attrs = _product(m, dname, pname)["attributes"]
        attrs.append(copy.deepcopy(next(a for a in attrs if not a.get("foreign_key_to") and "primary_key" not in a.get("tags", ""))))
    mdl["domains"].append({"name": "legacy_archive", "division": "corporate", "description": "Empty archive domain.",
                           "database_name": "legacy_archive", "references": "", "tags": "", "products": []})
    mdl["domains"].append({"name": "unknown", "division": "business", "description": "Leaked sentinel domain.",
                           "database_name": "unknown", "references": "", "tags": "", "products": [
                               {"name": "orphan_note", "table_name": "orphan_note", "primary_key": "orphan_note_id",
                                "subdomain": "misc", "description": "Orphan note.", "type": "entity", "division": "business",
                                "function": "", "data_type": "", "source_domains": "", "association_edges": "",
                                "reference": "", "tags": "", "attributes": [_col("orphan_note_id", "BIGINT"), _col("note_text")]}]})
    return m


def _flat(model):
    return [list(x) for x in ah.model_to_widgets_flat(model)]


_TS_RE = re.compile(r"\d{4}-\d{2}-\d{2}[ T]\d{2}:\d{2}:\d{2}(\.\d+)?")


def _normalize(obj):
    if isinstance(obj, dict):
        return {str(k): _normalize(v) for k, v in obj.items()}
    if isinstance(obj, (list, tuple)):
        return [_normalize(v) for v in obj]
    if isinstance(obj, (set, frozenset)):
        return sorted((_normalize(v) for v in obj), key=lambda x: json.dumps(x, sort_keys=True, default=repr))
    if isinstance(obj, str):
        return _TS_RE.sub("<ts>", obj)
    return obj


def _digest(obj):
    return hashlib.sha256(json.dumps(_normalize(obj), sort_keys=True, default=repr).encode("utf-8")).hexdigest()


RUNNERS = {}


def _runner(fn):
    RUNNERS[fn.__name__] = fn
    return fn


@_runner
def naming_enforce(model):
    d, p, a, mv = _flat(model)
    n = ah.enforce_naming_conventions(p, a, _Log(), config=_cfg())
    return {"result": n, "domains": d, "products": p, "attributes": a}


@_runner
def naming_apply_case(model):
    d, p, a, mv = _flat(model)
    summary = ah.apply_naming_conventions(d, p, a, _cfg(), _Log())
    return {"result": summary, "domains": d, "products": p, "attributes": a}


@_runner
def naming_step_prefix_suffix(model):
    d, p, a, mv = _flat(model)
    cfg = _cfg()
    cfg["SCHEMA_PREFIX"] = "dbx_"
    cfg["MODEL_CONVENTIONS"]["table_suffix"] = "_tbl"
    wv = {"spark": None, "logger": _Log(), "config": cfg, "business_name": "airlines", "domains": d,
          "products": p, "attributes": a, "vibe_modelling_instructions": TAG_VIBE}
    ah.step_apply_naming_conventions(wv)
    return {"domains": wv["domains"], "products": wv["products"], "attributes": wv["attributes"],
            "table_name_mapping": wv.get("table_name_mapping"), "db_name_mapping": wv.get("db_name_mapping")}


@_runner
def naming_bare_attribute_fix(model):
    d, p, a, mv = _flat(model)
    n = ah._fix_bare_attribute_names(a, _Log())
    return {"result": n, "domains": d, "products": p, "attributes": a}


@_runner
def tags_vibe_custom(model):
    d, p, a, mv = _flat(model)
    n = ah._apply_vibe_custom_tags(d, p, a, {"vibe_modelling_instructions": TAG_VIBE}, _Log())
    return {"result": n, "domains": d, "products": p, "attributes": a}


@_runner
def fk_align_to_parent_pk(model):
    d, p, a, mv = _flat(model)
    n = ah._v493_align_fk_column_names_to_parent_pk(p, a, _cfg(), _Log())
    return {"result": n, "domains": d, "products": p, "attributes": a}


@_runner
def fk_deterministic_linker(model):
    d, p, a, mv = _flat(model)
    n = ah._post_normalization_deterministic_fk_linker(d, p, a, _cfg(), _Log())
    return {"result": n, "domains": d, "products": p, "attributes": a}


@_runner
def fk_missing_parents(model):
    d, p, a, mv = _flat(model)
    n = ah._create_missing_parent_tables_for_unlinked_fks(d, p, a, _cfg(), _Log())
    return {"result": n, "domains": d, "products": p, "attributes": a}


@_runner
def fk_demote_unlinked(model):
    d, p, a, mv = _flat(model)
    hits = [x for x in a if x["attribute"] in ("lone_thing_id", "solo_thing_id")]
    res = [ah._demote_unlinked_fk_attr_to_external_code(x, "_id", _Log()) for x in hits]
    return {"result": res, "domains": d, "products": p, "attributes": a}


@_runner
def autofix_monotonic(model):
    d, p, a, mv = _flat(model)
    n = ah._autofix_with_monotonic_guard(d, p, a, _cfg(), _Log(), stage="test")
    return {"result": n, "domains": d, "products": p, "attributes": a}


@_runner
def cycles_bidirectional_detect(model):
    d, p, a, mv = _flat(model)
    links = ah._detect_direct_bidirectional_links(a, _Log())
    return {"result": links, "domains": d, "products": p, "attributes": a}


@_runner
def cycles_break_internal(model):
    d, p, a, mv = _flat(model)
    cycles = ah._detect_cycles_dfs(p, a, _Log())
    broken, removed = ah._break_cycles_internal(cycles, a, _Log(), ai_agent=None, config=_cfg())
    return {"result": [broken, sorted(r.get("edge_key", "") for r in removed)], "domains": d, "products": p, "attributes": a}


@_runner
def cycles_heuristic(model):
    d, p, a, mv = _flat(model)
    cycles = ah._detect_cycles_dfs(p, a, _Log())
    fk_index = {}
    for attr in a:
        fk = attr.get("foreign_key_to", "")
        if fk and "." in fk:
            parts = fk.split(".")
            key = f"{attr.get('domain')}.{attr.get('product')}\u2192{parts[0]}.{parts[1]}"
            fk_index.setdefault(key, []).append({"source_domain": attr.get("domain", ""), "source_product": attr.get("product", ""),
                                                 "source_attribute": attr.get("attribute", ""), "target_domain": parts[0],
                                                 "target_product": parts[1], "attr_ref": attr})
    broken, removed = ah._break_cycles_heuristic_internal(cycles, a, fk_index, _Log(), excluded_edges=set())
    return {"result": [broken, sorted(r.get("edge_key", "") for r in removed)], "domains": d, "products": p, "attributes": a}


@_runner
def cycles_post_vov(model):
    d, p, a, mv = _flat(model)
    n = ah._v394_break_post_vov_cycles(p, a, _Log())
    return {"result": n, "domains": d, "products": p, "attributes": a}


@_runner
def cycles_serialized(model):
    root = copy.deepcopy(model)
    n = ah._v403_break_cycles_in_serialized_model(root["model"], _Log())
    return {"result": n, "model": root}


@_runner
def empty_domain_cleanup(model):
    d, p, a, mv = _flat(model)
    dropped = ah._cleanup_empty_domains(d, p, logger=_Log(), user_specified_domains=["crew"], user_vibed_new_domains=[])
    return {"result": dropped, "domains": d, "products": p, "attributes": a}


@_runner
def junk_domain_serialized(model):
    root = copy.deepcopy(model)
    n = ah._v424_reject_junk_empty_domains_in_serialized_model(root["model"], _Log(), protected_domains={"crew"})
    return {"result": n, "model": root}


@_runner
def tags_write_time_enrichment(model):
    root = copy.deepcopy(model)
    ah._enrich_model_authoritative_tags(root["model"], _cfg(), _Log())
    return {"model": root}


@_runner
def queued_vibe_operations(model):
    d, p, a, mv = _flat(model)
    pk_map = ah.build_pk_map(p, _cfg())
    res = ah._execute_queued_vibe_operations(
        queued_quality_checks={"dedupe_attributes": {"scope_filter": "*"}, "break_cycles": {}},
        queued_linking_ops={}, queued_generation_ops={}, domains_data=d, products_data=p, attributes_data=a,
        pk_map=pk_map, logger=_Log(), ai_agent=None, config=_cfg(), widgets_values={},
        protected_artifacts={}, vibe_changed_domains=None)
    res = dict(res)
    qr = dict(res.get("quality_results") or {})
    if "break_cycles" in qr:
        qr["break_cycles"] = dict(qr["break_cycles"], broken_edges=sorted(qr["break_cycles"].get("broken_edges") or []))
    res["quality_results"] = qr
    return {"result": res, "domains": d, "products": p, "attributes": a}


_SPARK_TYPE_NAMES = ("BooleanType", "DateType", "DoubleType", "FloatType", "IntegerType", "LongType",
                     "StringType", "TimestampType", "DecimalType")


class _SparkTypeStandIn:
    def __init__(self, *args):
        self.args = args


def _with_spark_type_stand_ins(fn):
    missing = [n for n in _SPARK_TYPE_NAMES if n not in ah.__dict__]
    for n in missing:
        ah.__dict__[n] = _SparkTypeStandIn
    try:
        return fn()
    finally:
        for n in missing:
            ah.__dict__.pop(n, None)


@_runner
def mv_generation_fallback(model):
    d, p, a, mv = _flat(model)
    db_map = {x["domain"]: x["database_name"] or x["domain"] for x in d}
    files, stmts, records = _with_spark_type_stand_ins(lambda: ah._build_domain_metric_sql_artifacts_with_llm(
        "airlines_cat", d, p, a, db_map, "airlines", "2", _Log(), ai_agent=None, config=_cfg()))
    return {"files": sorted(files), "statements": stmts, "records": records}


KPI_PAYLOAD = {"kpi_metric_views": [
    {"view_name": "crew_roster_kpis", "owner_domain": "crew", "primary_product": "roster", "description": "Roster KPIs.",
     "dimensions": [{"name": "approval_status", "expr": "approval_status"}, {"name": "crew_position", "expr": "crew_position"}],
     "measures": [{"name": "total_days_off", "expr": "SUM(days_off_count)"},
                  {"name": "avg_deadhead", "expr": "AVG(deadhead_segments_count)"}]},
    {"view_name": "flight_cancellation_kpis", "owner_domain": "flight", "primary_product": "cancellation",
     "description": "Cancellation KPIs.",
     "dimensions": [{"name": "atc_restriction_type", "expr": "atc_restriction_type"}],
     "measures": [{"name": "total_affected", "expr": "SUM(affected_passenger_count)"},
                  {"name": "avg_notice", "expr": "AVG(advance_notice_hours)"}]},
]}


class _FakeKpiAgent:
    def __init__(self, payload):
        self.payload = payload
        self.calls = 0

    def _call_ai_query(self, **kwargs):
        self.calls += 1
        return json.dumps(self.payload)


@_runner
def mv_kpi_first(model):
    d, p, a, mv = _flat(model)
    cfg = _cfg()
    cfg["TARGET_CATALOG"] = "airlines_cat"
    wv = {"logger": _Log(), "config": cfg, "business_name": "airlines", "domains": d, "products": p, "attributes": a,
          "ai_agent": _FakeKpiAgent(KPI_PAYLOAD), "metric_view_statements": [], "_metric_view_records": []}
    _with_spark_type_stand_ins(lambda: ah.step_generate_kpi_first_metric_views(wv))
    return {"statements": wv.get("metric_view_statements"), "records": wv.get("_metric_view_records")}


ARCHITECT_RESPONSE = {
    "assessment": {"summary": "Scripted review.", "overall_score": 80, "completeness_score": 80, "coverage_score": 80,
                   "duplication_score": 80, "usefulness_score": 80},
    "domains_to_remove": [{"name": "legacy_archive", "reason": "empty"}],
    "domains_to_rename": [{"old_name": "cargo", "new_name": "freight", "reason": "clarity"}],
    "domains_to_add": [],
    "products_to_remove": [{"domain_product_key": "fleet.lessor", "reason": "dup"},
                           {"domain_product_key": "crew.absence", "reason": "dup"}],
    "products_to_rename": [{"domain": "flight", "old_name": "plan", "new_name": "flight_plan", "reason": "clarity"},
                           {"domain": "crew", "old_name": "pairing", "new_name": "trip_pairing", "reason": "clarity"}],
    "products_to_add": [{"name": "duty_slot", "domain": "crew", "description": "Duty slot reference.", "reason": "gap"},
                        {"name": "gate_slot", "domain": "airport", "description": "Gate slot reference.", "reason": "gap"}],
    "products_to_move": [{"product": "diversion", "source_domain": "flight", "target_domain": "crew", "reason": "fit"},
                         {"product": "roster", "source_domain": "crew", "target_domain": "flight", "reason": "fit"}],
}


def _with_scripted_architect(fn):
    original = ah.__dict__["smart_worker_loop"]

    def _fake(**kwargs):
        if kwargs.get("step_name") == "model_architect_review":
            return True, copy.deepcopy(ARCHITECT_RESPONSE), []
        return False, None, ["scripted: no response"]

    ah.__dict__["smart_worker_loop"] = _fake
    try:
        return fn()
    finally:
        ah.__dict__["smart_worker_loop"] = original


@_runner
def architect_review(model):
    d, p, a, mv = _flat(model)
    cfg = _cfg()
    cfg["MAX_ARCHITECT_REVIEW_ITERATIONS"] = 1
    res = _with_scripted_architect(lambda: ah.step_architect_review(d, p, _Log(), None, cfg, widgets_values={}))
    keep = {k: v for k, v in res.items() if k in ("domains_removed", "domains_renamed", "products_added", "products_removed",
                                                   "products_renamed", "products_moved", "domains_added")}
    return {"result": keep, "domains": d, "products": p}


_BUSINESS_ROW = {"business": "airlines", "description": "An airline.", "industry_alignment": "Airlines", "location": "Global",
                 "core_business_processes": "Fly", "orgnaization_divisions": "operations", "data_domains": "",
                 "common_business_jargons": "", "operational_systems_of_records": "", "industry_governing_body": ""}


def export_model_json(flat_lists, operation=VOV, extra=None):
    d, p, a, mv = flat_lists
    uploads = {}

    class _Files:
        def delete(self, file_path):
            uploads.pop(file_path, None)

        def upload(self, file_path, contents, overwrite=True):
            uploads[file_path] = contents.read()

    class _Workspace:
        def __init__(self, *args, **kwargs):
            self.files = _Files()

    cfg = _cfg()
    cfg.update({"TARGET_VOLUME": "/Volumes/c/_metamodel/vol_root/business/airlines/v2/mvm",
                "MAIN_METAMODEL_TABLES": {"BUSINESS": "c._metamodel.business"}})
    wv = {"spark": None, "logger": _Log(), "config": cfg, "business_name": "airlines", "operation": operation,
          "current_version": "2", "base_version_for_review": "1", "model_scope": "mvm", "domains": d, "products": p,
          "attributes": a, "metric_views": mv, "_metric_view_records": [dict(x) for x in mv],
          "metric_view_statements": [x["sql"] for x in mv], "_run_start_time": "2026-01-01T00:00:00",
          "_widget_raw_values": {"business_name": "airlines", "operation": operation}}
    wv.update(extra or {})
    patches = {"WorkspaceClient": _Workspace, "execute_sql": lambda spark, query, logger=None: [dict(_BUSINESS_ROW)]}
    saved = {k: ah.__dict__.get(k, KeyError) for k in patches}
    ah.__dict__.update(patches)
    try:
        import time as _time
        wv["_run_start_timestamp"] = _time.time()
        _with_spark_type_stand_ins(lambda: ah.step_generate_data_model_json(wv))
    finally:
        for k, v in saved.items():
            if v is KeyError:
                ah.__dict__.pop(k, None)
            else:
                ah.__dict__[k] = v
    payload = uploads.get(f"{cfg['TARGET_VOLUME']}/model.json")
    return (json.loads(payload) if payload else None), wv


@_runner
def model_json_export(model):
    root, _wv = export_model_json(_flat(model))
    root["_vibe_session_metadata"].pop("ai_usage", None)
    root["_vibe_session_metadata"].pop("duration_hours", None)
    root.pop("input_outcomes", None)
    root.pop("lineage", None)
    root["agent_version"] = "<agent_version>"
    root["release_version"] = "<release_version>"
    return {"model_json": root, "root_keys": list(root)}


@_runner
def flat_projection(model):
    return {"flat": ah.model_to_widgets_flat(model)}


def _load_goldens():
    if not GOLDEN_PATH.exists():
        return {}
    return json.loads(GOLDEN_PATH.read_text())


GOLDENS = _load_goldens()
_DIGEST_MARKER = "VIBE_SCOPE_PASS_DIGESTS="


def _all_digests():
    assert ah.get_vibe_scope_runtime() is None
    return {name: _digest(fn(_perturbed())) for name, fn in sorted(RUNNERS.items())}


def _digests_with_fixed_hash_seed():
    if os.environ.get("PYTHONHASHSEED") == "0":
        return _all_digests()
    env = dict(os.environ, PYTHONHASHSEED="0")
    proc = subprocess.run([sys.executable, str(Path(__file__).resolve())], env=env, capture_output=True, text=True,
                          cwd=str(Path(__file__).resolve().parent), timeout=900)
    lines = [ln for ln in proc.stdout.splitlines() if ln.startswith(_DIGEST_MARKER)]
    assert proc.returncode == 0 and lines, f"digest subprocess failed rc={proc.returncode}: {proc.stderr[-3000:]}"
    return json.loads(lines[-1][len(_DIGEST_MARKER):])


@pytest.fixture(scope="module")
def current_digests():
    return _digests_with_fixed_hash_seed()


@pytest.fixture(autouse=True)
def _reset_runtime():
    ah.set_vibe_scope_runtime(None)
    yield
    ah.set_vibe_scope_runtime(None)


def test_capture_goldens_from_the_unguarded_notebook():
    if not CAPTURE:
        pytest.skip("golden capture runs only with VIBE_SCOPE_CAPTURE_GOLDENS=1 on an unmodified notebook")
    GOLDEN_PATH.parent.mkdir(parents=True, exist_ok=True)
    GOLDEN_PATH.write_text(json.dumps({"source_commit": "5d386ed", "agent_version": ah.__AGENT_VERSION__,
                                       "python_hash_seed": "0", "digests": _digests_with_fixed_hash_seed()},
                                      indent=2, sort_keys=True) + "\n")


@pytest.mark.parametrize("name", sorted(RUNNERS))
def test_all_domains_output_is_byte_identical_to_the_unguarded_code(name, current_digests):
    if CAPTURE:
        pytest.skip("capturing")
    assert GOLDENS.get("digests"), f"missing golden fixture {GOLDEN_PATH}"
    assert set(GOLDENS["digests"]) == set(RUNNERS)
    assert current_digests[name] == GOLDENS["digests"][name]


def _scoped(entries="crew", mode="Some Domains"):
    base = _perturbed()
    fence = ah.build_vibe_scope_fence(ah.parse_vibe_scope(mode, entries), copy.deepcopy(base), VOV, _Log())
    ah.set_vibe_scope_runtime(fence)
    return base, fence


def _check_out(fence, base, out):
    if "model" in out:
        return fence.check(out["model"])
    d0, p0, a0, mv0 = _flat(base)
    return fence.check_flat(out.get("domains", d0), out.get("products", p0), out.get("attributes", a0), mv0)


def _assert_no_leak(result):
    assert not result.violations, result.violations[:5]
    assert not result.conflicts, result.conflicts[:5]


def _row(rows, domain, product, attribute=None):
    for r in rows:
        if r.get("domain") == domain and r.get("product") == product and (attribute is None or r.get("attribute") == attribute):
            return r
    return None


def _names(rows, domain, product):
    return [r["attribute"] for r in rows if r.get("domain") == domain and r.get("product") == product]


SCOPED = [n for n in sorted(RUNNERS) if n not in ("flat_projection", "model_json_export", "tags_write_time_enrichment")]


@pytest.mark.parametrize("name", SCOPED)
def test_scoped_pass_never_changes_out_of_scope_records(name):
    base, fence = _scoped()
    out = RUNNERS[name](copy.deepcopy(base))
    if name.startswith("mv_"):
        assert {r.get("owner_domain") for r in out["records"]} <= {"crew"}, out["records"][:3]
        return
    _assert_no_leak(_check_out(fence, base, out))


def test_scoped_naming_enforce_renames_in_scope_and_relinks_out_of_scope_fks():
    base, fence = _scoped()
    out = naming_enforce(copy.deepcopy(base))
    p, a = out["products"], out["attributes"]
    assert _row(p, "crew", "licence") and not _row(p, "crew", "crew_licence")
    assert _row(p, "flight", "flight_status") and not _row(p, "flight", "status")
    oos = _row(a, "flight", "dispatch_release", "crew_licence_id")
    assert oos["foreign_key_to"] == "crew.licence.licence_id"
    assert "remarks" in _names(a, "crew", "roster") and "scheduled_flight_remarks" in _names(a, "flight", "scheduled_flight")
    result = _check_out(fence, base, out)
    _assert_no_leak(result)
    assert result.summary()["by_kind"].get("P1", 0) >= 1
    ledger = fence.report()["rename_ledger"]
    assert {"kind": "product", "old": "crew.crew_licence", "new": "crew.licence"} in ledger


def test_scoped_case_and_bare_name_passes_only_touch_in_scope_columns():
    base, fence = _scoped()
    case = naming_apply_case(copy.deepcopy(base))
    assert "duty_remarks" in _names(case["attributes"], "crew", "duty_period")
    assert "Leg_Remarks" in _names(case["attributes"], "flight", "flight_leg")
    bare = naming_bare_attribute_fix(copy.deepcopy(base))
    assert "crew_licence_status" in _names(bare["attributes"], "crew", "crew_licence")
    assert "status" in _names(bare["attributes"], "fleet", "engine")


def test_scoped_prefix_suffix_step_and_vibe_tags_stay_in_scope():
    base, fence = _scoped()
    out = naming_step_prefix_suffix(copy.deepcopy(base))
    dom = {r["domain"]: r for r in out["domains"]}
    assert dom["crew"]["database_name"] == "dbx_crew"
    assert dom["flight"]["database_name"] == _domain(base, "flight")["database_name"]
    assert _row(out["products"], "crew", "roster")["table_name"].endswith("_tbl")
    assert not _row(out["products"], "flight", "scheduled_flight")["table_name"].endswith("_tbl")
    assert "data_owner=crewops" in _row(out["products"], "crew", "roster")["tags"]
    assert "data_owner" not in _row(out["products"], "flight", "scheduled_flight")["tags"]
    tags = tags_vibe_custom(copy.deepcopy(base))
    assert "reviewed=yes" in _row(tags["attributes"], "crew", "roster", "roster_remarks")["tags"]
    assert "reviewed=yes" not in _row(tags["attributes"], "flight", "scheduled_flight", "scheduled_flight_remarks")["tags"]


def test_scoped_fk_align_and_demote_skip_out_of_scope_columns():
    unscoped = fk_align_to_parent_pk(_perturbed())
    assert _row(unscoped["attributes"], "flight", "irop_event", "linked_station_key") is None
    base, fence = _scoped()
    out = fk_align_to_parent_pk(copy.deepcopy(base))
    assert _row(out["attributes"], "crew", "duty_period", "home_base_key")["foreign_key_to"] == "crew.base.base_id"
    assert _row(out["attributes"], "flight", "irop_event", "linked_station_key")["foreign_key_to"] == "airport.station"
    dem = fk_demote_unlinked(copy.deepcopy(base))
    assert dem["result"] == [True, False]
    assert _row(dem["attributes"], "crew", "absence", "lone_thing_code") and _row(dem["attributes"], "fleet", "lessor", "solo_thing_id")


def test_scoped_linker_links_in_scope_and_never_links_out_of_scope_to_base_targets():
    unscoped = fk_deterministic_linker(_perturbed())
    assert _row(unscoped["attributes"], "flight", "diversion", "backup_member_id")["foreign_key_to"] == "crew.member.member_id"
    assert _row(unscoped["attributes"], "flight", "cancellation", "relief_duty_slot_id")["foreign_key_to"] == "airport.slot.slot_id"
    base, fence = _scoped()
    d, p, a, mv = _flat(base)
    a.append(dict(_row(a, "flight", "diversion", "backup_member_id"), domain="crew", product="ftl_legality_check",
                  attribute="relief_member_id", column_name="relief_member_id"))
    ah._post_normalization_deterministic_fk_linker(d, p, a, _cfg(), _Log())
    assert _row(a, "crew", "ftl_legality_check", "relief_member_id")["foreign_key_to"] == "crew.member.member_id"
    assert not _row(a, "flight", "diversion", "backup_member_id")["foreign_key_to"]
    assert not _row(a, "flight", "cancellation", "relief_duty_slot_id")["foreign_key_to"]
    _assert_no_leak(fence.check_flat(d, p, a, mv))


def test_scoped_linker_links_out_of_scope_column_to_new_in_scope_product_as_p3():
    base, fence = _scoped()
    d, p, a, mv = _flat(base)
    p.append({"domain": "crew", "product": "duty_slot", "subdomain": "flight_scheduling", "primary_key": "duty_slot_id"})
    a.append({"domain": "crew", "product": "duty_slot", "attribute": "duty_slot_id", "type": "BIGINT", "tags": "primary_key",
              "is_primary_key": True, "foreign_key_to": ""})
    ah._post_normalization_deterministic_fk_linker(d, p, a, _cfg(), _Log())
    assert not _row(a, "flight", "cancellation", "relief_duty_slot_id")["foreign_key_to"], "P3 needs a ledger create (decision 9A)"
    fence.record_change("create", "crew", "duty_slot", "engine:VREQ-7")
    ah._post_normalization_deterministic_fk_linker(d, p, a, _cfg(), _Log())
    assert _row(a, "flight", "cancellation", "relief_duty_slot_id")["foreign_key_to"] == "crew.duty_slot.duty_slot_id"
    result = fence.check_flat(d, p, a, mv)
    _assert_no_leak(result)
    assert result.summary()["by_kind"].get("P3") == 1


def test_scoped_missing_parents_create_only_in_scope_tables():
    base, fence = _scoped()
    out = fk_missing_parents(copy.deepcopy(base))
    assert _row(out["products"], "crew", "zeta_widget") and not _row(out["products"], "flight", "omega_gizmo")
    assert _row(out["attributes"], "crew", "pairing", "zeta_widget_id")["foreign_key_to"] == "crew.zeta_widget.zeta_widget_id"
    assert not _row(out["attributes"], "flight", "oooi_event", "omega_gizmo_id")["foreign_key_to"]
    assert _row(out["attributes"], "fleet", "lessor", "solo_thing_id")


def test_scoped_missing_parent_inherits_a_listed_subdomain_in_subdomain_mode():
    base, fence = _scoped("crew.flight_scheduling", "Some Subdomains")
    out = fk_missing_parents(copy.deepcopy(base))
    created = _row(out["products"], "crew", "zeta_widget")
    assert created and created["subdomain"] == "flight_scheduling"
    _assert_no_leak(_check_out(fence, base, out))


def test_new_base_subdomain_runs_let_passes_process_unallocated_roster_products():
    d, p, a, mv = _flat(_perturbed())
    for row in p:
        row["subdomain"] = ""
    fence = ah.build_vibe_scope_fence(ah.parse_vibe_scope("Some Subdomains", "crew.crew_records"), None,
                                      "new base model", _Log())
    ah.set_vibe_scope_runtime(fence)
    frozen = ah._vibe_scope_product_test()
    assert frozen("crew", "duty_period") is False and frozen("flight", "flight_leg") is True
    assert fence.is_frozen_product("crew", "duty_period", subdomain="flight_scheduling")
    ah.apply_naming_conventions(d, p, a, _cfg(), _Log())
    assert "duty_remarks" in _names(a, "crew", "duty_period")
    assert "Leg_Remarks" in _names(a, "flight", "flight_leg")
    crew_products = sorted(r["product"] for r in p if r["domain"] == "crew")
    with ah._vibe_scope_contain(d, p, a, _Log(), "new-base"):
        _row(a, "crew", "duty_period", "duty_remarks")["description"] = "in scope"
    assert _row(a, "crew", "duty_period", "duty_remarks")["description"] == "in scope"
    assert sorted(r["product"] for r in p) == crew_products and {r["domain"] for r in d} == {"crew"}
    assert fence.report()["rename_ledger"] == []
    _row(p, "crew", "duty_period")["subdomain"] = "crew_records"
    wv = {"domains": d, "products": p, "attributes": a, "metric_views": []}
    with pytest.raises(ah.VibeScopeFenceError, match="takes product subdomains only from the subdomain allocation"):
        ah._vibe_scope_checkpoint_widgets("after_subdomains", wv, _Log(), allocated=True)
    assert sorted(r["product"] for r in p) == crew_products, "item 2: unassigned products are never pruned silently"
    for row in p:
        if row["product"] != "duty_period":
            row["subdomain"] = "crew_scheduling"
    assert ah._vibe_scope_checkpoint_widgets("after_subdomains", wv, _Log(), allocated=True) == len(crew_products) - 1
    assert [r["product"] for r in p] == ["duty_period"]


def test_vov_subdomain_runs_settle_or_keep_unassigned_new_products():
    base, fence = _scoped("crew.crew_records", "Some Subdomains")
    d, p, a, mv = _flat(base)
    p.append({"domain": "crew", "product": "crew_note", "subdomain": "", "primary_key": "crew_note_id"})
    p.append({"domain": "crew", "product": "crew_memo", "subdomain": "flight_scheduling", "primary_key": "crew_memo_id"})
    wv = {"domains": d, "products": p, "attributes": a, "metric_views": mv}
    ah._vibe_scope_checkpoint_widgets("vov_writeback", wv, _Log())
    assert _row(p, "crew", "crew_note")["subdomain"] == "" and not _row(p, "crew", "crew_memo")
    ah._vibe_scope_checkpoint_widgets("after_subdomains", wv, _Log(), allocated=True)
    assert _row(p, "crew", "crew_note")["subdomain"] == "crew_records"
    assert fence.mark_subdomains_allocated() is False


def test_vov_subdomain_runs_fail_instead_of_pruning_an_unassigned_product_with_two_listed_subdomains():
    base, fence = _scoped("crew.crew_records, crew.flight_scheduling", "Some Subdomains")
    d, p, a, mv = _flat(base)
    p.append({"domain": "crew", "product": "crew_note", "subdomain": "", "primary_key": "crew_note_id"})
    wv = {"domains": d, "products": p, "attributes": a, "metric_views": mv}
    ah._vibe_scope_checkpoint_widgets("vov_writeback", wv, _Log())
    assert _row(p, "crew", "crew_note")["subdomain"] == ""
    with pytest.raises(ah.VibeScopeFenceError, match="their domain lists more than one subdomain"):
        ah._vibe_scope_checkpoint_widgets("after_subdomains", wv, _Log(), allocated=True)
    assert _row(p, "crew", "crew_note")


def test_scoped_cycle_breakers_spare_out_of_scope_edges():
    base, fence = _scoped()
    bid = cycles_bidirectional_detect(copy.deepcopy(base))
    assert not _row(bid["attributes"], "crew", "member", "current_roster_id")["foreign_key_to"]
    assert _row(bid["attributes"], "fleet", "aircraft_type", "primary_scheduled_flight_id")["foreign_key_to"]
    for name in ("cycles_break_internal", "cycles_heuristic", "cycles_post_vov"):
        out = RUNNERS[name](copy.deepcopy(base))
        assert _row(out["attributes"], "flight", "scheduled_flight", "anchor_flight_leg_id")["foreign_key_to"], name
        assert _row(out["attributes"], "flight", "flight_leg", "crew_roster_activity_id")["foreign_key_to"], name
    ser = cycles_serialized(copy.deepcopy(base))
    _assert_no_leak(fence.check(ser["model"]))


def test_scoped_empty_and_junk_domain_guards_keep_out_of_scope_base_domains():
    base, fence = _scoped()
    out = empty_domain_cleanup(copy.deepcopy(base))
    assert "legacy_archive" in [r["domain"] for r in out["domains"]] and out["result"] == []
    ser = junk_domain_serialized(copy.deepcopy(base))
    names = [d["name"] for d in ser["model"]["model"]["domains"]]
    assert "unknown" in names and "legacy_archive" in names
    assert [p["name"] for p in _domain(ser["model"], "unknown")["products"]] == ["orphan_note"]


def test_unscoped_junk_guard_still_drops_junk_and_empty_domains():
    out = junk_domain_serialized(_perturbed())
    names = [d["name"] for d in out["model"]["model"]["domains"]]
    assert "unknown" not in names and "legacy_archive" not in names


def test_scoped_write_time_tag_enrichment_leaves_out_of_scope_subtrees_byte_identical():
    base, fence = _scoped()
    out = tags_write_time_enrichment(copy.deepcopy(base))
    for dom in out["model"]["model"]["domains"]:
        if dom["name"] == "crew":
            assert all("tag_set" in p for p in dom["products"])
        else:
            assert dom == _domain(base, dom["name"]), dom["name"]


def test_scoped_autofix_and_queued_ops_contain_out_of_scope_rows():
    base, fence = _scoped()
    d0, p0, a0, _mv0 = _flat(base)
    dup_counts = lambda attrs, dom, prod: len(_names(attrs, dom, prod)) - len(set(_names(attrs, dom, prod)))
    assert dup_counts(a0, "crew", "training_event") == 1 and dup_counts(a0, "flight", "weight_balance") == 1
    fix = autofix_monotonic(copy.deepcopy(base))
    assert dup_counts(fix["attributes"], "crew", "training_event") == 0
    assert dup_counts(fix["attributes"], "flight", "weight_balance") == 1
    ops = queued_vibe_operations(copy.deepcopy(base))
    assert dup_counts(ops["attributes"], "crew", "training_event") == 0
    assert dup_counts(ops["attributes"], "flight", "weight_balance") == 1
    contained = fence.report()["contained"]
    assert contained.get("autofix:test", 0) > 0 and "queued_vibe_operations" in contained


def test_scoped_architect_review_applies_only_in_scope_proposals():
    base, fence = _scoped()
    assert fence.referenced_from_outside("crew", "absence") and not fence.referenced_from_outside("crew", "pairing")
    out = architect_review(copy.deepcopy(base))
    res, p = out["result"], out["products"]
    assert res["products_removed"] == [] and _row(p, "crew", "absence"), "9A: no ledger drop for a referenced in-scope product"
    fence.record_change("drop", "crew", "absence", "engine:V1")
    out = architect_review(copy.deepcopy(base))
    res, p = out["result"], out["products"]
    assert res["products_removed"] == [{"domain_product_key": "crew.absence", "reason": "dup"}]
    assert [r["new_name"] for r in res["products_renamed"]] == ["trip_pairing"]
    assert [r["product"] for r in res["products_added"]] == ["duty_slot"]
    assert res["products_moved"] == [] and res["domains_renamed"] == [] and res["domains_removed"] == []
    assert _row(p, "fleet", "lessor") and _row(p, "flight", "plan") and _row(p, "flight", "diversion") and _row(p, "crew", "roster")
    assert "cargo" in [r["domain"] for r in out["domains"]] and "legacy_archive" in [r["domain"] for r in out["domains"]]


def test_scoped_mv_generation_only_builds_in_scope_views():
    base, fence = _scoped()
    full = mv_generation_fallback(_perturbed_unscoped())
    scoped = mv_generation_fallback(copy.deepcopy(base))
    assert {r["owner_domain"] for r in scoped["records"]} == {"crew"}
    assert len(scoped["records"]) == sum(1 for r in full["records"] if r["owner_domain"] == "crew")
    kpi = mv_kpi_first(copy.deepcopy(base))
    assert [r["view_name"] for r in kpi["records"]] == ["crew_roster_kpis"]


def _perturbed_unscoped():
    fence = ah.get_vibe_scope_runtime()
    ah.set_vibe_scope_runtime(None)
    try:
        return _perturbed()
    finally:
        ah.set_vibe_scope_runtime(fence)


def test_mv_generation_full_run_is_unchanged_without_a_fence():
    out = mv_generation_fallback(_perturbed())
    assert {"crew", "flight"} <= {r["owner_domain"] for r in out["records"]}


def test_fence_internal_conversions_do_not_print_the_carryforward_line(capsys):
    base, fence = _scoped()
    capsys.readouterr()
    d, p, a, mv = (list(x) for x in ah.model_to_widgets_flat(base, quiet=True))
    fence.check(base)
    fence.check_flat(d, p, a, mv)
    fence.checkpoint("quiet", d, p, a, mv, _Log())
    assert "vov-references-carryforward" not in capsys.readouterr().out
    ah.model_to_widgets_flat(base)
    assert "vov-references-carryforward" in capsys.readouterr().out


def test_checkpoint_widgets_restores_leaks_and_resyncs_metric_view_statements():
    base, fence = _scoped()
    d, p, a, mv = _flat(base)
    frozen_mv = next(m for m in mv if m["owner_domain"] == "flight")
    records = [dict(m, _source="vov_2_0_sandbox") for m in mv]
    statements = [m["sql"] for m in mv]
    _row(p, "flight", "scheduled_flight")["description"] = "leak"
    records.remove(next(r for r in records if r["view_name"] == frozen_mv["view_name"]))
    statements = [s for s in statements if s != frozen_mv["sql"]]
    records.append({"view_name": "leaked_flight_view", "owner_domain": "flight", "owner_product": "scheduled_flight",
                    "sql": "CREATE OR REPLACE VIEW `c`.`_metrics`.`leaked_flight_view` AS SELECT 1"})
    statements.append(records[-1]["sql"])
    wv = {"domains": d, "products": p, "attributes": a, "metric_views": mv, "_metric_view_records": records,
          "metric_view_statements": statements, "config": {}}
    restored = ah._vibe_scope_checkpoint_widgets("unit", wv, _Log())
    assert restored >= 3
    assert _row(p, "flight", "scheduled_flight")["description"] == _product(base, "flight", "scheduled_flight")["description"]
    names = {ah._vov285_san(r["view_name"]) for r in wv["_metric_view_records"]}
    assert ah._vov285_san(frozen_mv["view_name"]) in names and "leakedflightview" not in names
    stmt_names = {ah._vov285_san(ah._extract_metric_view_name_from_statement(s)) for s in wv["metric_view_statements"]}
    assert stmt_names == names
    assert ah._vibe_scope_checkpoint_widgets("unit-again", wv, _Log()) == 0


def test_checkpoint_helpers_are_noops_without_a_fence():
    d, p, a, mv = _flat(_perturbed())
    _row(p, "flight", "scheduled_flight")["description"] = "would be a leak if scoped"
    wv = {"domains": d, "products": p, "attributes": a, "metric_views": mv, "_metric_view_records": list(mv),
          "metric_view_statements": [m["sql"] for m in mv]}
    snapshot = copy.deepcopy(wv)
    assert ah._vibe_scope_checkpoint("x", d, p, a, mv, _Log()) == 0
    assert ah._vibe_scope_checkpoint_widgets("x", wv, _Log()) == 0
    assert wv == snapshot
    assert ah._vibe_scope_product_test() is None and ah._vibe_scope_frozen_edges({}) == frozenset()
    assert ah._vibe_scope_contain_start(d, p, a, _Log(), "x") is None
    assert ah._vibe_scope_filter_architect_response({"a": 1}) == {"a": 1}
    assert ah._vibe_scope_serialize_gate({"domains": []}, {}, _Log()) is None


def test_containment_repairs_in_scope_fks_to_a_renamed_frozen_product():
    base, fence = _scoped()
    d, p, a, mv = _flat(base)
    pk_before = _row(p, "flight", "flight_leg")["primary_key"]
    with ah._vibe_scope_contain(d, p, a, _Log(), "unit-rename"):
        for row in p + a:
            if row.get("domain") == "flight" and row.get("product") == "flight_leg":
                row["product"] = "leg"
        for row in a:
            if str(row.get("foreign_key_to") or "").startswith("flight.flight_leg."):
                row["foreign_key_to"] = row["foreign_key_to"].replace("flight.flight_leg.", "flight.leg.", 1)
    assert _row(p, "flight", "flight_leg")["primary_key"] == pk_before and not _row(p, "flight", "leg")
    assert _row(a, "crew", "pairing", "flight_leg_id")["foreign_key_to"] == "flight.flight_leg.flight_leg_id"
    _assert_no_leak(fence.check_flat(d, p, a, mv))
    assert fence.report()["contained"]["unit-rename"] > 0


if __name__ == "__main__":
    print(_DIGEST_MARKER + json.dumps(_all_digests(), sort_keys=True))

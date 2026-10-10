"""v5.1.4 vibe_scope: fail-closed serialize gate, the model.json `_vibe_scope` block, stale base,
in-scope FK integrity after the splice, and decision 2A (renamed in-scope columns read by an
out-of-scope metric view are re-pointed in the view SQL; only drops are blocked).

step_generate_data_model_json runs end to end with Spark and the Workspace client stubbed, on the
real data-models/airlines/v1/mvm/model.json. Every test fails on 5d386ed (no gate, no block, the
rename was a blocked conflict) and passes on this version.
"""
import copy
import json
import re
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent))
import conftest  # noqa: F401,E402
import agent_helpers as ah  # noqa: E402
import test_v514_vibe_scope_fence as F  # noqa: E402
import test_v514_vibe_scope_passes as P  # noqa: E402
import v514_feedback_util as fu  # noqa: E402

RAW = P.RAW
VOV = P.VOV
CONTRACT_KEYS = {"mode", "label", "entries", "operation", "resolved", "baseline", "frozen", "rename_ledger", "authorizations",
                 "restores", "stale_base", "changed_in_scope_products", "preserved_products", "permitted_deltas",
                 "serialize_gate"}
DELTA_KEYS = {"kind", "domain", "product", "attribute", "old_fk", "new_fk", "view_name", "cause"}


@pytest.fixture(autouse=True)
def _reset_runtime(monkeypatch):
    fu.inject_spark_types(monkeypatch)
    ah.set_vibe_scope_runtime(None)
    yield
    ah.set_vibe_scope_runtime(None)


def _fence(base=RAW, entries="crew", mode="Some Domains", probe=None):
    fence = ah.build_vibe_scope_fence(ah.parse_vibe_scope(mode, entries), copy.deepcopy(base), VOV, P._Log())
    if probe is not None:
        fence.set_stale_base_probe("1", probe)
        fence.refresh_stale_base(P._Log())
    ah.set_vibe_scope_runtime(fence)
    return fence


def _scoped_edit_with_leaks():
    m = copy.deepcopy(RAW)
    ah._v337_apply_rename_product(m["model"], "crew", "member", "crew_member")
    P._product(m, "flight", "scheduled_flight")["description"] = "leak"
    P._product(m, "fleet", "aircraft_type")["attributes"][1]["type"] = "LEAK_TYPE"
    m["model"]["metric_views"][0]["sql"] = "SELECT 1"
    return m


def _all_products(root):
    return [f"{d['name']}.{p['name']}" for d in root["model"]["domains"] for p in d["products"]]


def test_scoped_export_splices_out_of_scope_and_writes_the_vibe_scope_block():
    fence = _fence()
    m = _scoped_edit_with_leaks()
    outcomes = {"scope_rejected": [{"vreq_id": "VREQ-9"}], "scope_dependency_conflict": [], "scope_fence_violation": [],
                "authorized_oos_links": [], "in_scope_vreq_count": 3, "adherence_in_scope_pct": 100.0}
    root, wv = P.export_model_json(P._flat(m), extra={"_vibe_scope_outcomes": outcomes})
    assert root is not None
    assert list(root)[:7] == ["agent_version", "release_version", "_vibe_scope", "entity_changes", "input_outcomes", "lineage", "model_requirements"]
    facts = root["_vibe_scope"]
    assert facts == wv["_vibe_scope_facts"]
    assert CONTRACT_KEYS <= set(facts) and facts["outcomes"] == outcomes
    assert facts["serialize_gate"] == {"status": "passed", "violations": []}
    assert facts["mode"] == "domains" and facts["entries"] == ["crew"]
    source = {d["name"]: d for d in RAW["model"]["domains"]}
    for dom in root["model"]["domains"]:
        if dom["name"] == "crew":
            continue
        expected = copy.deepcopy(source[dom["name"]])
        for prod in expected["products"]:
            for attr in prod["attributes"]:
                if str(attr.get("foreign_key_to") or "").startswith("crew.member."):
                    attr["foreign_key_to"] = "crew.crew_member.crew_member_id"
        assert dom == expected, dom["name"]
    frozen_mvs = [v for v in RAW["model"]["metric_views"] if v["owner_domain"] != "crew"]
    assert [v for v in root["model"]["metric_views"] if v["owner_domain"] != "crew"] == frozen_mvs
    deltas = facts["permitted_deltas"]
    assert len(deltas) == 19 and all(set(d) == DELTA_KEYS for d in deltas)
    assert {d["kind"] for d in deltas} == {"P1"} and {d["new_fk"] for d in deltas} == {"crew.crew_member.crew_member_id"}
    assert all(d["old_fk"].startswith("crew.member.") and d["view_name"] == "" for d in deltas)
    sample = next(d for d in deltas if d["domain"] == "flight" and d["product"] == "dispatch_release")
    assert sample["attribute"] == "member_id"
    changed, preserved = set(facts["changed_in_scope_products"]), set(facts["preserved_products"])
    assert "crew.crew_member" in changed and "flight.scheduled_flight" in preserved
    assert not changed & preserved and changed | preserved == set(_all_products(root))
    assert all(p.split(".", 1)[0] == "crew" for p in changed)
    json.dumps(root)


def test_unscoped_export_has_no_vibe_scope_block():
    root, wv = P.export_model_json(P._flat(copy.deepcopy(RAW)))
    assert "_vibe_scope" not in root and "_vibe_scope_facts" not in wv
    assert list(root) == ["agent_version", "release_version", "input_outcomes", "lineage", "model_requirements", "vreq_adherence_pct",
                          "native_quality_pct", "vov_quality_pct", "_vibe_session_metadata", "model"]


def test_serialize_gate_fails_closed_and_model_json_is_not_written():
    _fence()
    m = copy.deepcopy(RAW)
    next(a for a in P._product(m, "crew", "member")["attributes"] if a["name"] == "member_id")["type"] = "STRING"
    holder = {}

    def _capture():
        root, wv = P.export_model_json(P._flat(m), extra={"_holder": holder})
        holder["root"] = root

    with pytest.raises(ah.VibeScopeFenceError) as exc:
        _capture()
    assert "root" not in holder
    assert exc.value.problems[0]["kind"] == "pk_type_change"


def test_failed_gate_still_records_the_failure_in_the_facts():
    fence = _fence()
    m = copy.deepcopy(RAW)
    next(a for a in P._product(m, "crew", "member")["attributes"] if a["name"] == "member_id")["type"] = "STRING"
    wv = {}
    with pytest.raises(ah.VibeScopeFenceError):
        ah._vibe_scope_serialize_gate(m["model"], wv, P._Log())
    gate = wv["_vibe_scope_facts"]["serialize_gate"]
    assert gate["status"] == "failed" and [v["kind"] for v in gate["violations"]] == ["pk_type_change"]
    assert fence.report()["last_splice"]["remaining"][0]["kind"] == "pk_type_change"


def test_stale_base_is_refreshed_right_before_the_write():
    latest = {"v": "1"}
    fence = _fence(probe=lambda: latest["v"])
    assert fence.report()["stale_base"]["stale"] is False
    root, wv = P.export_model_json(P._flat(_scoped_edit_with_leaks()))
    stale = root["_vibe_scope"]["stale_base"]
    assert stale["stale"] is False and stale["latest_completed_version"] == "1" and stale["checks"] == 2
    latest["v"] = "3"
    with pytest.raises(ah.VibeScopeFenceError, match="v3 was completed while this run was working on base v1"):
        P.export_model_json(P._flat(_scoped_edit_with_leaks()))
    assert fence.report()["stale_base"]["stale"] is True and fence.report()["stale_base"]["checks"] == 3


def test_gate_repairs_in_scope_fks_to_out_of_scope_targets_after_the_splice():
    _fence()
    m = copy.deepcopy(RAW)
    roster = P._product(m, "crew", "roster")
    station = next(a for a in roster["attributes"] if a["name"] == "station_id")
    station["foreign_key_to"] = "airport.station.station_key"
    roster["attributes"].append({"name": "ghost_ref_id", "type": "BIGINT", "foreign_key_to": "airport.ghost_station.ghost_station_id"})
    wv = {}
    facts = ah._vibe_scope_serialize_gate(m["model"], wv, P._Log())
    roster = P._product(m, "crew", "roster")
    assert next(a for a in roster["attributes"] if a["name"] == "station_id")["foreign_key_to"] == "airport.station.station_id"
    assert next(a for a in roster["attributes"] if a["name"] == "ghost_ref_id")["foreign_key_to"] == ""
    assert facts["last_splice"]["repaired_inscope_fks"] == 2


def _mv_base(sql_builder):
    base = copy.deepcopy(RAW)
    mv = next(v for v in base["model"]["metric_views"] if v["view_name"] == "airport_baggage_irregularity")
    mv["sql"] = sql_builder(mv["sql"])
    return base, mv["view_name"]


def _qual_column():
    return P._product(RAW, "crew", "qualification")["attributes"][2]["name"]


def _sql_of(model, view):
    return next(v for v in model["model"]["metric_views"] if v["view_name"] == view)["sql"]


def test_renamed_in_scope_column_read_by_a_frozen_mv_join_is_repointed():
    col = _qual_column()
    base = F._with_frozen_mv_joining_crew_qualification(col)
    fence = _fence(base=base)
    m = copy.deepcopy(base)
    ah._v337_apply_rename_attribute(m["model"], "crew", "qualification", col, col + "_v2")
    before = fence.check(m)
    assert before.ok and not before.conflicts
    assert [d["fix"] for d in before.dangling] == ["P5"]
    assert [a["kind"] for a in fence.reconcile_boundary(m, P._Log())] == ["P5"]
    sql = _sql_of(m, "airport_baggage_irregularity")
    assert sql.count(f"qualification.{col}_v2") == 2
    assert re.search(rf"qualification\.{col}(?![A-Za-z0-9_])", sql) is None
    after = fence.check(m)
    assert after.ok and after.summary()["by_kind"] == {"P5": 1}
    facts = ah._vibe_scope_serialize_gate(m["model"], {}, P._Log())
    p5 = [d for d in facts["permitted_deltas"] if d["kind"] == "P5"]
    assert p5 == [{"kind": "P5", "domain": "airport", "product": "baggage_irregularity", "attribute": "", "old_fk": "",
                   "new_fk": "", "view_name": "airport_baggage_irregularity", "cause": ah._VIBE_SCOPE_PERMIT_CAUSES["P5"]}]


def test_dropping_an_in_scope_column_a_frozen_mv_reads_is_still_blocked():
    col = _qual_column()
    base = F._with_frozen_mv_joining_crew_qualification(col)
    fence = _fence(base=base)
    m = copy.deepcopy(base)
    qual = P._product(m, "crew", "qualification")
    qual["attributes"] = [a for a in qual["attributes"] if a["name"] != col]
    result = fence.check(m)
    assert [c["kind"] for c in result.conflicts] == ["dropped_read_by_frozen_mv"]
    assert result.conflicts[0]["path"] == f"crew.qualification.{col}"
    with pytest.raises(ah.VibeScopeFenceError):
        ah._vibe_scope_serialize_gate(m["model"], {}, P._Log())


def test_a_rename_outside_the_ledger_counts_as_a_drop():
    col = _qual_column()
    base = F._with_frozen_mv_joining_crew_qualification(col)
    fence = _fence(base=base)
    m = copy.deepcopy(base)
    target = next(a for a in P._product(m, "crew", "qualification")["attributes"] if a["name"] == col)
    target["name"] = target["column_name"] = col + "_x"
    assert [c["kind"] for c in fence.check(m).conflicts] == ["dropped_read_by_frozen_mv"]


def test_bare_and_aliased_column_references_are_repointed_when_the_frozen_mv_sources_the_in_scope_table():
    col = _qual_column()

    def _yaml(sql):
        return sql.replace('source: "`airlines_ecm`.`airport`.`baggage_irregularity`"',
                           'source: "`airlines_ecm`.`crew`.`qualification`"', 1).replace(
            "  dimensions:", f"  dimensions:\n    - name: \"{col}\"\n      expr: {col}\n    - name: \"src_{col}\"\n      expr: source.{col}", 1)

    base, view = _mv_base(_yaml)
    fence = _fence(base=base)
    m = copy.deepcopy(base)
    ah._v337_apply_rename_attribute(m["model"], "crew", "qualification", col, col + "_v2")
    assert fence.check(m).ok
    fence.reconcile_boundary(m, P._Log())
    sql = _sql_of(m, view)
    assert f"      expr: {col}_v2\n" in sql and f"      expr: source.{col}_v2" in sql
    assert f"- name: \"{col}\"" in sql
    assert fence.check(m).ok


def test_sql_view_alias_reference_is_repointed():
    col = _qual_column()
    base, view = _mv_base(lambda _sql: f"CREATE OR REPLACE VIEW x AS SELECT q.{col}, COUNT(1) AS n "
                                       f"FROM airlines_ecm.crew.qualification q GROUP BY q.{col}")
    fence = _fence(base=base)
    m = copy.deepcopy(base)
    ah._v337_apply_rename_attribute(m["model"], "crew", "qualification", col, col + "_v2")
    fence.reconcile_boundary(m, P._Log())
    sql = _sql_of(m, view)
    assert sql.count(f"q.{col}_v2") == 2 and f"q.{col} " not in sql
    assert fence.check(m).ok


def test_unresolvable_reference_to_a_renamed_column_is_blocked():
    col = _qual_column()
    base, view = _mv_base(lambda _sql: f"CREATE OR REPLACE VIEW x AS WITH c AS (SELECT * FROM airlines_ecm.crew.qualification) "
                                       f"SELECT c.{col} FROM c JOIN airlines_ecm.airport.station s ON 1 = 1")
    fence = _fence(base=base)
    m = copy.deepcopy(base)
    ah._v337_apply_rename_attribute(m["model"], "crew", "qualification", col, col + "_v2")
    result = fence.check(m)
    assert [c["kind"] for c in result.conflicts] == ["dropped_read_by_frozen_mv"]
    assert "could not be re-pointed" in result.conflicts[0]["detail"]


def test_column_rename_helper_leaves_other_tables_and_yaml_keys_alone():
    sql = ('source: "`c`.`crew`.`qualification`"\n  joins:\n    - name: st\n      source: "`c`.`airport`.`station`"\n'
           "      'on': source.code = st.code\n  dimensions:\n    - name: \"code\"\n      expr: code\n    - name: x\n      expr: st.code\n")
    out, hits, missed = ah._mv_sql_apply_column_renames(sql, [("crew", "qualification")], {"code": "qual_code"})
    assert hits == 2 and missed == []
    assert "source.qual_code = st.code" in out and "      expr: qual_code\n" in out and "expr: st.code" in out
    assert '- name: "code"' in out
    out2, hits2, missed2 = ah._mv_sql_apply_column_renames(sql, [("airport", "station")], {"code": "station_code"})
    assert hits2 == 2 and "st.station_code" in out2 and "source.code" in out2 and "      expr: code\n" in out2

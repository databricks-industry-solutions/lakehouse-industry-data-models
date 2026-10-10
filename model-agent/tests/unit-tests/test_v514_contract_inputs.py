"""v5.1.4 contract K1/K2: feedback-item markers, the item -> requirement map, per-item outcomes and the
vibe_lineage item ids with distinct scope statuses.

Behavioral tests run the production code: marker stripping in the vibe entry function, step_setup_and_clean,
run_vov_pipeline on both branches (priority and extracted VREQs) with canned LLMs, run_vov_2_against_widgets'
outcome block, step_generate_data_model_json and step_generate_vibe_lineage. Every test fails on 56ce1eb (markers
reach the LLM, no map, no input_outcomes, scope statuses folded into missed) and passes on this version.
"""
import copy
import json
import re
import sys
from pathlib import Path
from types import SimpleNamespace

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent))
import conftest  # noqa: F401,E402
import agent_helpers as ah  # noqa: E402
import test_v514_vibe_scope_parse as PS  # noqa: E402
import test_v514_vibe_scope_passes as P  # noqa: E402
import test_v514_vibe_scope_vov_engine as E  # noqa: E402

VOV = "vibe modeling of version"
NEW_BASE = "new base model"
VIBE = (
    "## Domain: crew\n"
    "<!-- vi:aaaa-1 target=crew.member -->\n"
    "- (high) Add a nickname column to crew member so dispatch can greet crew\n"
    "#### Product: roster\n"
    "<!-- vi:bbbb-2 target=crew.roster -->\n"
    "- (medium) Rename roster to duty_roster\n"
    "## Domain: fleet\n"
    "<!-- vi:cccc-3 target=fleet.aircraft -->\n"
    "\n"
    "> Priority: low\n"
    "\n"
    "Track the aircraft lease end date.\n"
    "Keep it nullable.\n"
)
ITEM_TEXT = {
    "aaaa-1": "- (high) Add a nickname column to crew member so dispatch can greet crew",
    "bbbb-2": "- (medium) Rename roster to duty_roster",
    "cccc-3": "> Priority: low\n\nTrack the aircraft lease end date.\nKeep it nullable.",
}


@pytest.fixture(autouse=True)
def _isolate_runtime(monkeypatch):
    pinned = set(ah._USER_PINNED_DOMAINS_RUNTIME)
    monkeypatch.setattr(ah, "logger", E.LOG, raising=False)
    ah.set_vibe_scope_runtime(None)
    yield
    ah.set_vibe_scope_runtime(None)
    ah._USER_PINNED_DOMAINS_RUNTIME.clear()
    ah._USER_PINNED_DOMAINS_RUNTIME.update(pinned)


def _span_texts(text, items):
    return {i: [text[s:e] for s, e in rec["spans"]] for i, rec in items.items()}


def _input_map(text=VIBE):
    stripped, items = ah._vibe_input_strip(text)
    return stripped, {"sha": ah._vibe_input_sha(stripped), "chars": len(stripped), "items": items, "vreqs": {}}


def _vreq(vid, quote, chunk="", intent="do something", target="crew.member"):
    return ah.RawVREQ(vreq_id=vid, intent=intent, target=target, source_quote=quote, source_chunk_id=chunk)


def test_strip_removes_own_line_markers_and_keeps_item_spans():
    stripped, items = ah._vibe_input_strip(VIBE)
    assert "<!--" not in stripped and "vi:" not in stripped
    assert stripped.startswith("## Domain: crew\n- (high) Add a nickname")
    assert "#### Product: roster" in stripped and "## Domain: fleet" in stripped
    assert {i: r["target"] for i, r in items.items()} == {"aaaa-1": "crew.member", "bbbb-2": "crew.roster", "cccc-3": "fleet.aircraft"}
    assert _span_texts(stripped, items) == {i: [t] for i, t in ITEM_TEXT.items()}


def test_strip_handles_inline_markers_targets_with_spaces_and_repeated_ids():
    text = ("- (high) <!-- vi:x-1 target=crew.roster.member_id→crew.member.member_id --> Re-point the roster FK\n"
            "<!-- vi:x-2 target=Model-wide -->\n- (low) Add audit columns everywhere\n"
            "<!-- vi:x-1 target=crew.roster -->\n- (low) and keep it nullable")
    stripped, items = ah._vibe_input_strip(text)
    assert stripped == "- (high) Re-point the roster FK\n- (low) Add audit columns everywhere\n- (low) and keep it nullable"
    assert items["x-1"]["target"] == "crew.roster.member_id→crew.member.member_id"
    assert _span_texts(stripped, items) == {"x-1": ["Re-point the roster FK", "- (low) and keep it nullable"],
                                            "x-2": ["- (low) Add audit columns everywhere"]}


def test_text_without_markers_is_returned_unchanged():
    text = "## Domain: crew\n- (high) add nickname to crew.member <!-- an ordinary comment -->\n"
    assert ah._vibe_input_strip(text) == (text, {})
    wv = {"operation": VOV, "_widget_raw_values": {"vibe_modelling_instructions": text}}
    bcd = {"vibe_modelling_instructions": text}
    assert ah._vov_single_source_vibes(wv, bcd) == text.strip()
    assert "_vibe_input_map" not in wv and "_vov_pending_sentinels" not in wv


@pytest.mark.parametrize("operation", [VOV, NEW_BASE])
def test_vibe_entry_strips_markers_before_any_llm_and_scrubs_every_raw_copy(operation):
    raw = {"vibe_modelling_instructions": VIBE, "model_vibes_source": VIBE}
    wv = {"operation": operation, "_widget_raw_values": raw, "business_context_raw": {"vibe_modelling_instructions": VIBE},
          "model_vibes": VIBE}
    bcd = {"vibe_modelling_instructions": VIBE}
    stripped, expected = _input_map()
    assert ah._vov_single_source_vibes(wv, bcd) == stripped
    assert wv["_vibe_input_map"] == expected
    for value in (bcd["vibe_modelling_instructions"], raw["vibe_modelling_instructions"], raw["model_vibes_source"],
                  wv["business_context_raw"]["vibe_modelling_instructions"], wv["model_vibes"]):
        assert "<!--" not in value
    assert any("[vibe-input-markers FIRED v5.1.4]" in s and "3 item(s)" in s for s in wv["_vov_pending_sentinels"])
    again = ah._vov_single_source_vibes(wv, bcd)
    assert again == stripped and wv["_vibe_input_map"] == expected


def test_setup_hands_only_marker_free_text_to_the_pipeline(monkeypatch):
    wv = PS._vov_widgets(scope=None)
    wv["_widget_raw_values"]["vibe_modelling_instructions"] = VIBE
    wv["business_context_data"]["vibe_modelling_instructions"] = VIBE
    PS._run_setup(monkeypatch, wv, sql=PS._vov_sql(), table_exists=True)
    stripped, expected = _input_map()
    assert wv["vibe_modelling_instructions"] == stripped
    assert wv["_vibe_input_map"]["items"] == expected["items"]
    assert all("<!--" not in r["text"] for r in wv["vibe_requirements_checklist"])
    assert "<!--" not in wv["user_vibes_original"]


def _chunks(stripped):
    return ah.chunk_vibe(stripped)


def test_map_uses_exact_quote_then_single_item_chunk_then_fuzzy_and_never_guesses():
    stripped, imap = _input_map()
    chunks = _chunks(stripped)
    by_item = {i: next(c.chunk_id for c in chunks if any(c.byte_start < e and s < c.byte_end for s, e in r["spans"]))
               for i, r in imap["items"].items()}
    vreqs = [
        _vreq("VREQ-0001", "Add a nickname   column to CREW member", by_item["aaaa-1"]),
        _vreq("VREQ-0002", "please give the roster table its new name", by_item["bbbb-2"]),
        _vreq("VREQ-0003", "Track the aircraft lease end date, nullable", "extract-audit"),
        _vreq("VREQ-0004", "partition every fact table by month", "extract-audit"),
        _vreq("VREQ-0005", "", "extract-audit", intent="keep the aircraft lease end date nullable"),
    ]
    got = ah._vibe_input_map_vreqs(imap, stripped, vreqs, chunks=chunks, logger=P._Log())
    assert got["VREQ-0001"] == {"item_ids": ["aaaa-1"], "method": "exact_quote", "merged_from": []}
    assert got["VREQ-0002"] == {"item_ids": ["bbbb-2"], "method": "single_item_chunk", "merged_from": []}
    assert got["VREQ-0003"] == {"item_ids": ["cccc-3"], "method": "fuzzy", "merged_from": []}
    assert got["VREQ-0004"] == {"item_ids": [], "method": "unmapped", "merged_from": []}
    assert got["VREQ-0005"]["item_ids"] == ["cccc-3"] and got["VREQ-0005"]["method"] == "fuzzy"


def test_quote_spanning_two_items_maps_to_both():
    stripped, imap = _input_map()
    quote = "dispatch can greet crew\n#### Product: roster\n- (medium) Rename roster"
    got = ah._vibe_input_map_vreqs(imap, stripped, [_vreq("VREQ-0001", quote)])
    assert got["VREQ-0001"] == {"item_ids": ["aaaa-1", "bbbb-2"], "method": "exact_quote", "merged_from": []}


def test_merged_requirements_union_their_item_ids_and_the_oos_half_keeps_them():
    stripped, imap = _input_map()
    chunks = _chunks(stripped)
    c1 = next(c.chunk_id for c in chunks if "nickname" in c.text)
    c2 = next(c.chunk_id for c in chunks if "duty_roster" in c.text)
    c3 = next(c.chunk_id for c in chunks if "lease" in c.text)
    raw_dup_a = _vreq("C1_V1", "add audit columns", c1, intent="add audit columns", target="crew")
    raw_dup_b = _vreq("C2_V1", "add audit columns", c2, intent="add audit columns", target="crew")
    final_dup = _vreq("VREQ-0001", "add audit columns", c1, intent="add audit columns", target="crew")
    keep_a = _vreq("C1_V2", "keep member", c1, intent="Preserve the crew.member table verbatim")
    keep_b = _vreq("C3_V1", "keep aircraft", c3, intent="Preserve the fleet.aircraft table verbatim", target="fleet.aircraft")
    collapsed = ah._v299_collapse_preservation_vreqs([final_dup, keep_a, keep_b])
    assert [v.vreq_id for v in collapsed] == ["VREQ-0001", "V299-PRESERVE-ALL"]
    oos_half = _vreq("VREQ-0009#oos", "", "", intent="zzz qqq", target="fleet.engine")
    finals = list(collapsed) + [_vreq("VREQ-0009", "Rename roster to duty_roster", c2), oos_half]
    absorbed = ah._vibe_input_absorbed(finals, [raw_dup_a, raw_dup_b], [final_dup, keep_a, keep_b])
    got = ah._vibe_input_map_vreqs(imap, stripped, finals, chunks=chunks, absorbed=absorbed, logger=P._Log())
    assert got["VREQ-0001"] == {"item_ids": ["aaaa-1", "bbbb-2"], "method": "single_item_chunk", "merged_from": ["C1_V1", "C2_V1"]}
    assert got["V299-PRESERVE-ALL"]["item_ids"] == ["aaaa-1", "cccc-3"]
    assert got["V299-PRESERVE-ALL"]["merged_from"] == ["C1_V2", "C3_V1"]
    assert got["VREQ-0009"]["item_ids"] == ["bbbb-2"]
    assert got["VREQ-0009#oos"] == {"item_ids": ["bbbb-2"], "method": "exact_quote", "merged_from": ["VREQ-0009"]}


def test_map_refuses_spans_from_a_different_text_and_survives_bad_inputs():
    stripped, imap = _input_map()
    log = P._Log()
    got = ah._vibe_input_map_vreqs(imap, stripped + " extra", [_vreq("VREQ-0001", "Add a nickname column to crew member")], logger=log)
    assert got == {"VREQ-0001": {"item_ids": [], "method": "unmapped", "merged_from": []}}
    assert "is not the marker-stripped text" in log.text()
    bad_chunk = SimpleNamespace(chunk_id="C1", byte_start="not-a-number", byte_end=10)
    got = ah._vibe_input_map_vreqs(imap, stripped, [_vreq("VREQ-0001", "Add a nickname column to crew member", "C1")],
                                   chunks=[bad_chunk], logger=log)
    assert got["VREQ-0001"]["method"] == "unmapped"
    assert "mapping FAILED" in log.text()
    assert ah._vibe_input_map_vreqs(None, stripped, [_vreq("VREQ-0001", "x")]) == {}


def test_pipeline_priority_branch_maps_each_priority_to_its_item():
    raw = ("<!-- vi:p-1 target=crew.member -->\n"
           "**PRIORITY 1 — enrich_description: crew.member** — add a crew control description\n"
           "<!-- vi:p-2 target=crew.base -->\n"
           "**PRIORITY 2 — enrich_description: crew.base** — add a crew base description\n")
    stripped, imap = _input_map(raw)
    result = ah.run_vov_pipeline(stripped, E._engine(), E._CannedLLM(), [], [], parallel=False, priority_reapply_loops=1,
                                 vibe_input_map=imap)
    assert result.vibe_input_vreqs == {"P001": {"item_ids": ["p-1"], "method": "exact_quote", "merged_from": []},
                                       "P002": {"item_ids": ["p-2"], "method": "exact_quote", "merged_from": []}}


def test_pipeline_without_markers_returns_an_empty_map():
    vibe = "**PRIORITY 1 — enrich_description: crew.member** — add a crew control description\n"
    result = ah.run_vov_pipeline(vibe, E._engine(), E._CannedLLM(), [], [], parallel=False, priority_reapply_loops=1)
    assert result.vibe_input_vreqs == {}


class _ExtractLLM(E._CannedLLM):
    def __init__(self, by_chunk):
        super().__init__()
        self.by_chunk = by_chunk

    def complete_json(self, system, user, temperature=0.0, response_schema=None):
        if system.startswith("You are a requirements analyst. Read a model-design vibe"):
            return {"sections": []}
        if system.startswith("You are a completeness auditor"):
            return {"missing": []}
        if "group VREQs into BATCHES" in system:
            return {"batches": [{"vreq_ids": [v["vreq_id"]], "intent_summary": v["intent"], "target_entities": [["crew", "member"]],
                                 "data_payload": []} for v in json.loads(user)["vreqs"]]}
        return super().complete_json(system, user, temperature, response_schema)

    def complete_with_tools(self, system, user, tools, tool_handlers, max_iters=6, temperature=0.0, response_schema=None):
        if system.startswith("You are a requirements analyst extracting USER INSTRUCTIONS"):
            chunk_text = user.split("\n\n", 1)[1]
            return {"vreqs": [dict(v) for key, vs in self.by_chunk.items() if key in chunk_text for v in vs]}
        return super().complete_with_tools(system, user, tools, tool_handlers, max_iters, temperature, response_schema)


def test_pipeline_extraction_branch_maps_after_dedupe_collapse_and_triage():
    stripped, imap = _input_map()
    llm = _ExtractLLM({
        "nickname": [{"intent": "add nickname attribute", "target": "crew.member", "source_quote": "Add a nickname column to crew member"},
                     {"intent": "add audit columns", "target": "crew", "source_quote": "add audit columns"},
                     {"intent": "Preserve the crew.member table verbatim", "target": "crew.member", "source_quote": "keep member"}],
        "duty_roster": [{"intent": "rename product", "target": "crew.roster", "source_quote": "rename that roster table please"}],
        "lease": [{"intent": "Preserve the fleet.aircraft table verbatim", "target": "fleet.aircraft", "source_quote": "keep aircraft"},
                  {"intent": "add audit columns", "target": "crew", "source_quote": "add audit columns"}],
    })
    result = ah.run_vov_pipeline(stripped, E._engine(), llm, [], [], parallel=False, priority_reapply_loops=1, vibe_input_map=imap)
    by_quote = {v.source_quote: v.vreq_id for v in result.raw_vreqs}
    got = result.vibe_input_vreqs
    assert set(got) == {v.vreq_id for v in result.raw_vreqs}
    assert got[by_quote["Add a nickname column to crew member"]]["item_ids"] == ["aaaa-1"]
    assert got[by_quote["Add a nickname column to crew member"]]["method"] == "exact_quote"
    assert "rename that roster table please" not in by_quote
    assert got["ANCHOR-001"] == {"item_ids": ["bbbb-2"], "method": "exact_quote", "merged_from": []}
    audit_ids = [v.vreq_id for v in result.raw_vreqs if v.source_quote == "add audit columns"]
    assert audit_ids and all(got[vid]["item_ids"] == ["aaaa-1", "cccc-3"] for vid in audit_ids)
    assert got["V299-PRESERVE-ALL"]["item_ids"] == ["aaaa-1", "cccc-3"]


def _result(outcomes, vreq_ids, deferred=(), vibe_input_vreqs=None):
    return SimpleNamespace(outcomes=outcomes, raw_vreqs=[_vreq(v, "q") for v in vreq_ids],
                           deferred_vreqs=[{"vreq_id": d} for d in deferred], vibe_input_vreqs=vibe_input_vreqs or {})


def _o(vid, status, diag=""):
    return ah.VReqOutcome(batch_id=f"B-{vid}", vreq_ids=(vid,), status=status, diagnostic=diag, attempts=1)


STATUS_OUTCOMES = [
    _o("V1", "verifier_failed", "first try"), _o("V1", "applied"),
    _o("V2", "applied"),
    _o("V2#oos", "scope_rejected", "[vibe-scope-triage] target=fleet.engine | mixed requirement split; the out-of-scope part targets fleet.engine"),
    _o("V3", "exhausted_retries", "no landing"),
    _o("V4", "scope_dependency_conflict", "[vibe-scope-triage] target=crew.member | in-scope PK read by frozen FKs"),
    _o("V5", "scope_fence_violation", "touched fleet.aircraft.description"),
    _o("V7", "scope_rejected", "[vibe-scope-triage] target=fleet.engine | targets out-of-scope product fleet.engine"),
]
STATUS_IDS = ["V1", "V2", "V2#oos", "V3", "V4", "V5", "V6", "V7"]


def test_requirement_statuses_keep_every_terminal_state_distinct():
    got = ah._vibe_input_vreq_statuses(_result(STATUS_OUTCOMES, STATUS_IDS, deferred=["V3", "V6"]))
    assert {k: v["status"] for k, v in got.items()} == {
        "V1": "applied", "V2": "applied", "V2#oos": "scope_rejected", "V3": "failed", "V4": "scope_dependency_conflict",
        "V5": "scope_fence_violation", "V6": "deferred", "V7": "scope_rejected"}
    assert got["V2#oos"]["reason"].startswith("mixed requirement split")
    assert got["V3"]["reason"].startswith("exhausted_retries: no landing")
    assert got["V6"]["reason"] == "not attempted in this run; carried to next_vibes"


def test_item_outcomes_fold_requirements_and_never_report_unmapped_as_applied():
    statuses = ah._vibe_input_vreq_statuses(_result(STATUS_OUTCOMES, STATUS_IDS, deferred=["V6"]))
    items = {f"i{n}": {"target": f"t{n}", "spans": [[n * 10, n * 10 + 5]]} for n in range(1, 10)}
    vreqs = {"V1": ["i1"], "V2": ["i2"], "V2#oos": ["i2"], "V3": ["i3", "i8"], "V4": ["i4"], "V5": ["i5"], "V6": ["i6"], "V7": ["i7", "i8"]}
    imap = {"items": items, "vreqs": {vid: {"item_ids": ids, "method": "exact_quote", "merged_from": []} for vid, ids in vreqs.items()}}
    got = {o["item_id"]: o for o in ah._vibe_input_outcomes(imap, statuses)}
    assert {k: v["status"] for k, v in got.items()} == {
        "i1": "applied", "i2": "partial", "i3": "failed", "i4": "scope_dependency_conflict", "i5": "scope_fence_violation",
        "i6": "deferred", "i7": "scope_rejected", "i8": "failed", "i9": "unmapped"}
    assert got["i2"]["vreq_ids"] == ["V2", "V2#oos"] and "V2#oos scope_rejected" in got["i2"]["reason"]
    assert got["i9"] == {"item_id": "i9", "target": "t9", "status": "unmapped", "vreq_ids": [],
                         "reason": "no requirement extracted from the vibe matched this item"}
    assert [o["item_id"] for o in ah._vibe_input_outcomes(imap, statuses)] == [f"i{n}" for n in range(1, 10)]


def test_vov_shim_records_the_map_and_per_item_outcomes(monkeypatch):
    stripped, imap = _input_map()
    d, p, a, mv = (list(x) for x in ah.model_to_widgets_flat(copy.deepcopy(P.RAW)))
    captured = {}

    def _fake_pipeline(**kwargs):
        captured.update(kwargs)
        model = kwargs["initial_model"]
        return ah.PipelineResult(initial_model=model, final_model=copy.deepcopy(model), outline=None,
                                 raw_vreqs=[_vreq("VREQ-0001", "q"), _vreq("VREQ-0002", "q")], batches=[],
                                 outcomes=[_o("VREQ-0001", "applied"), _o("VREQ-0002", "verifier_failed", "nope")], coverage_pct=50.0,
                                 vibe_input_vreqs={"VREQ-0001": {"item_ids": ["aaaa-1"], "method": "exact_quote", "merged_from": []},
                                                   "VREQ-0002": {"item_ids": ["bbbb-2"], "method": "fuzzy", "merged_from": []}})

    monkeypatch.setattr(ah, "run_vov_pipeline", _fake_pipeline)
    wv = {"ai_agent": object(), "operation": VOV, "domains": d, "products": p, "attributes": a, "metric_views": mv,
          "vibe_modelling_instructions": stripped, "_vibe_input_map": imap, "config": {}}
    ah.run_vov_2_against_widgets(wv, P._Log(), vibe_text=stripped, parallel=False)
    assert captured["vibe_input_map"] is imap
    assert wv["_vibe_input_map"]["vreqs"]["VREQ-0002"]["method"] == "fuzzy"
    assert {o["item_id"]: o["status"] for o in wv["_vibe_input_outcomes"]} == {"aaaa-1": "applied", "bbbb-2": "failed", "cccc-3": "unmapped"}
    assert wv["_vov_vreq_status"]["VREQ-0002"] == {"status": "failed", "reason": "verifier_failed: nope"}


def test_model_json_input_outcomes_for_vov_runs_only():
    outcomes = [{"item_id": "aaaa-1", "target": "crew.member", "status": "applied", "vreq_ids": ["VREQ-0001"], "reason": ""}]
    root, _wv = P.export_model_json(P._flat(copy.deepcopy(P.RAW)), extra={"_vibe_input_outcomes": outcomes})
    assert root["input_outcomes"] == outcomes
    keys = list(root)
    assert keys.index("release_version") < keys.index("input_outcomes") < keys.index("lineage") < keys.index("model_requirements")
    root, _wv = P.export_model_json(P._flat(copy.deepcopy(P.RAW)))
    assert root["input_outcomes"] == []
    _stripped, imap = _input_map()
    root, _wv = P.export_model_json(P._flat(copy.deepcopy(P.RAW)), extra={"_vibe_input_map": imap})
    assert [(o["item_id"], o["status"]) for o in root["input_outcomes"]] == [("aaaa-1", "unmapped"), ("bbbb-2", "unmapped"), ("cccc-3", "unmapped")]
    root, _wv = P.export_model_json(P._flat(copy.deepcopy(P.RAW)), operation=NEW_BASE, extra={"_vibe_input_outcomes": outcomes})
    assert "input_outcomes" not in root and "lineage" in root


def _lineage(monkeypatch, wv):
    writes = []
    monkeypatch.setitem(ah.__dict__, "write_to_dbfs", lambda content, path, logger: writes.append((path, content)))
    base = {"logger": P._Log(), "config": {"TARGET_VOLUME": "/tmp/vscontract_lineage"}, "current_version": "2",
            "model_scope": "mvm", "base_version_for_review": "1", "domains": [], "products": [], "attributes": []}
    base.update(wv)
    ah.step_generate_vibe_lineage(base)
    assert len(writes) == 1, base["logger"].text()
    return json.loads(writes[0][1]), base


def _lineage_inputs():
    stripped, imap = _input_map()
    imap["vreqs"] = {"VREQ-0001": {"item_ids": ["aaaa-1"], "method": "exact_quote", "merged_from": []}}
    raw_vreqs = [{"vreq_id": "VREQ-0001", "intent": "add nickname", "target": "crew.member", "source_quote": "Add a nickname column to crew member"},
                 {"vreq_id": "VREQ-0002", "intent": "rename", "target": "crew.roster", "source_quote": "Rename roster to duty_roster"},
                 {"vreq_id": "VREQ-0003", "intent": "lease", "target": "fleet.aircraft", "source_quote": "Track the aircraft lease end date"},
                 {"vreq_id": "VREQ-0004", "intent": "drop", "target": "fleet.engine", "source_quote": "Drop the fleet engine table"}]
    status = {"VREQ-0001": {"status": "applied", "reason": ""},
              "VREQ-0002": {"status": "scope_dependency_conflict", "reason": "in-scope PK read by frozen FKs"},
              "VREQ-0003": {"status": "scope_fence_violation", "reason": "touched fleet.aircraft"},
              "VREQ-0004": {"status": "scope_rejected", "reason": "targets out-of-scope product fleet.engine"}}
    return stripped, imap, raw_vreqs, status


def test_vibe_lineage_carries_item_ids_and_keeps_scope_statuses_distinct(monkeypatch):
    stripped, imap, raw_vreqs, status = _lineage_inputs()
    checklist = [{"req_id": "VREQ-001", "text": "Add a nickname column to crew member", "status": "fulfilled"},
                 {"req_id": "VREQ-002", "text": "Rename roster to duty_roster", "status": "failed"},
                 {"req_id": "VREQ-003", "text": "Track the aircraft lease end date", "status": "failed"},
                 {"req_id": "VREQ-004", "text": "Drop the fleet engine table", "status": "scope_rejected"}]
    artifact, _wv = _lineage(monkeypatch, {"operation": VOV, "vibe_modelling_instructions": stripped, "_vibe_input_map": imap,
                                           "_vov_2_raw_vreqs": raw_vreqs, "_vov_vreq_status": status,
                                           "vibe_requirements_checklist": checklist})
    entries = {e["requirement_id"]: e for e in artifact["lineage"]}
    assert (entries["VREQ-001"]["outcome"], entries["VREQ-001"]["item_ids"], entries["VREQ-001"]["vreq_ids"]) == ("actioned", ["aaaa-1"], ["VREQ-0001"])
    assert entries["VREQ-002"]["outcome"] == "scope_dependency_conflict" and entries["VREQ-002"]["item_ids"] == ["bbbb-2"]
    assert entries["VREQ-002"]["missed_reason"] == "" and entries["VREQ-002"]["scope_reason"] == "in-scope PK read by frozen FKs"
    assert entries["VREQ-003"]["outcome"] == "scope_fence_violation" and entries["VREQ-003"]["item_ids"] == ["cccc-3"]
    assert entries["VREQ-004"]["outcome"] == "scope_rejected" and entries["VREQ-004"]["actioned"] is False
    assert entries["VREQ-004"]["item_ids"] == [] and entries["VREQ-004"]["vreq_ids"] == ["VREQ-0004"]
    summary = artifact["summary"]
    assert (summary["scope_rejected"], summary["scope_dependency_conflict"], summary["scope_fence_violation"]) == (1, 1, 1)
    assert summary["missed"] == 0


def test_vibe_lineage_does_not_override_a_verified_requirement_with_a_scope_status(monkeypatch):
    stripped, imap, raw_vreqs, status = _lineage_inputs()
    checklist = [{"req_id": "VREQ-007", "text": "Track the aircraft lease end date", "status": "fulfilled"},
                 {"req_id": "VREQ-008", "text": "Rename roster to duty_roster", "status": "partial"}]
    artifact, _wv = _lineage(monkeypatch, {"operation": VOV, "vibe_modelling_instructions": stripped, "_vibe_input_map": imap,
                                           "_vov_2_raw_vreqs": raw_vreqs, "_vov_vreq_status": status,
                                           "vibe_requirements_checklist": checklist})
    entries = {e["requirement_id"]: e for e in artifact["lineage"]}
    assert (entries["VREQ-007"]["outcome"], entries["VREQ-007"]["scope_reason"], entries["VREQ-007"]["vreq_ids"]) == ("actioned", "", ["VREQ-0003"])
    assert entries["VREQ-008"]["outcome"] == "partial"
    assert artifact["summary"]["scope_fence_violation"] == 0 and artifact["summary"]["scope_dependency_conflict"] == 0


def test_vibe_lineage_includes_requirements_the_orchestrator_moved_to_scope_rejected(monkeypatch):
    stripped, imap, raw_vreqs, status = _lineage_inputs()

    def _req(rid, text, req_status):
        return SimpleNamespace(id=rid, original_text=text, intent=text, scope="product", scope_targets=[], priority="high",
                               constraint_type="hard", mode="surgical", status=req_status)

    manifest = SimpleNamespace(requirements=[_req("VREQ-001", "Add a nickname column to crew member", "fulfilled")])
    orchestrator = SimpleNamespace(scope_rejected_requirements=[_req("VREQ-009", "Drop the fleet engine table", "scope_rejected")])
    artifact, _wv = _lineage(monkeypatch, {"operation": VOV, "vibe_modelling_instructions": stripped, "_vibe_input_map": imap,
                                           "_vov_2_raw_vreqs": raw_vreqs, "_vov_vreq_status": status,
                                           "vibe_manifest": manifest, "vibe_orchestrator": orchestrator})
    entries = {e["requirement_id"]: e for e in artifact["lineage"]}
    assert entries["VREQ-009"]["outcome"] == "scope_rejected" and entries["VREQ-009"]["vreq_ids"] == ["VREQ-0004"]
    assert artifact["summary"]["scope_rejected"] == 1


def test_vibe_lineage_maps_items_directly_for_a_new_base_model(monkeypatch):
    stripped, imap = _input_map()
    artifact, wv = _lineage(monkeypatch, {"operation": NEW_BASE, "vibe_modelling_instructions": stripped, "_vibe_input_map": imap,
                                          "vibe_requirements_checklist": [{"req_id": "REQ-1", "text": "Rename roster to duty_roster", "status": "fulfilled"}]})
    entry = artifact["lineage"][0]
    assert entry["item_ids"] == ["bbbb-2"] and entry["vreq_ids"] == [] and entry["outcome"] == "actioned"
    assert "[vibe-lineage-items FIRED v5.1.4] 1/1 requirement(s) carry feedback item ids" in wv["logger"].text()


def test_vibe_lineage_no_longer_reads_the_auto_loaded_next_vibes_flag(monkeypatch):
    artifact, _wv = _lineage(monkeypatch, {"operation": VOV, "vibe_modelling_instructions": "rename roster",
                                           "_auto_loaded_next_vibes": True,
                                           "vibe_requirements_checklist": [{"req_id": "REQ-1", "text": "rename roster", "status": "failed"}]})
    assert artifact["source_vibes_origin"] == "widget"
    assert "_auto_loaded_next_vibes" not in Path(ah.__file__).read_text()

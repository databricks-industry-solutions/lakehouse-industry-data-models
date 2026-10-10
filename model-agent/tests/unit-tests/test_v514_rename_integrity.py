"""v5.1.4 rename integrity: an app feedback "Rename to X." under a product heading must rename, not duplicate.

Field bug: "## Domain: procurement / #### Product: livestock_procurement / - (medium) Rename to
livestock_procurement_allocation." left both products in the model. Root causes (rename RCA, section 4):
F1 rule-based routing could not read heading-anchored directives and the priority branch dropped the user
block; F2 no acceptance point checked that a rename removed the old name; F3 renames were recorded in four
places and nowhere without a fence; F4 _merge_partial resurrected the old side; F5 nothing detected the pair.
Every behavioral test drives production code on the real airlines v1 model.json and fails on 56ce1eb.
"""
import copy
import json
import logging
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent))
import conftest  # noqa: F401,E402
import agent_helpers as ah  # noqa: E402
import v514_feedback_util as fu  # noqa: E402
from notebook_source_util import notebook_concat_source  # noqa: E402

REPO = Path(__file__).resolve().parents[3]
RAW = json.loads((REPO / "data-models" / "airlines" / "v1" / "mvm" / "model.json").read_text())
VOV = "vibe modeling of version"
LOG = logging.getLogger("test_v514_rename_integrity")
_ENGINE = ah.widgets_flat_to_model(*ah.model_to_widgets_flat(RAW), agent_version=ah.__AGENT_VERSION__)
USER = "=== USER VIBES (SUPREME AUTHORITY - APPLY FIRST; the user's own feedback) ===\n"
AUTO = "\n=== AUTO-GENERATED NEXT_VIBES (LOWER PRIORITY - suggestions from the previous run) ===\n"
RENAME_FEEDBACK = "## Domain: crew\n#### Product: member\n- (medium) Rename to crew_member.\n"
CONNECT_ROSTER = "**PRIORITY 1 — connect_table: crew.roster** — add column backup_base_id (BIGINT) with FK to crew.base.base_id\n"

COPY_MUTATOR = (
    "def mutator(model, data):\n"
    "    root = model.get('model', model)\n"
    "    for d in root['domains']:\n"
    "        if d['name'] == 'crew':\n"
    "            src = [p for p in d['products'] if p['name'] == 'member'][0]\n"
    "            twin = copy.deepcopy(src)\n"
    "            twin['name'] = 'crew_member'\n"
    "            d['products'].append(twin)\n"
    "    return model\n"
)
IN_PLACE_NO_FK_MUTATOR = (
    "def mutator(model, data):\n"
    "    root = model.get('model', model)\n"
    "    for d in root['domains']:\n"
    "        for p in d['products']:\n"
    "            if d['name'] == 'crew' and p['name'] == 'member':\n"
    "                p['name'] = 'crew_member'\n"
    "    return model\n"
)
IN_PLACE_MUTATOR = IN_PLACE_NO_FK_MUTATOR.replace(
    "    return model\n",
    "    for d in root['domains']:\n"
    "        for p in d['products']:\n"
    "            for a in p.get('attributes') or []:\n"
    "                fk = a.get('foreign_key_to') or ''\n"
    "                if fk.startswith('crew.member.'):\n"
    "                    a['foreign_key_to'] = 'crew.crew_member.' + fk.split('.', 2)[2]\n"
    "    return model\n",
)
MERGE_MUTATOR = (
    "def mutator(model, data):\n"
    "    root = model.get('model', model)\n"
    "    for d in root['domains']:\n"
    "        if d['name'] == 'crew':\n"
    "            d['products'] = [p for p in d['products'] if p['name'] != 'member']\n"
    "        for p in d.get('products') or []:\n"
    "            for a in p.get('attributes') or []:\n"
    "                fk = a.get('foreign_key_to') or ''\n"
    "                if fk.startswith('crew.member.'):\n"
    "                    a['foreign_key_to'] = 'crew.crew_member.' + fk.split('.', 2)[2]\n"
    "    return model\n"
)
HISTORY_MUTATOR = COPY_MUTATOR.replace("'crew_member'", "'member_history'")


class _FakeLLM(ah.MockLLM):
    def __init__(self, mutator=IN_PLACE_MUTATOR, summary="rename crew.member to crew_member in place", vreqs=None):
        super().__init__(default={"mutator_source": mutator, "expected_changes_summary": summary})
        self.vreqs = list(vreqs or [])
        self.prompts = []

    def complete_json(self, system, user, temperature=0.0, response_schema=None):
        self.prompts.append((system, user))
        if "group VREQs into BATCHES" in system:
            return {"batches": [{"vreq_ids": [v["vreq_id"]], "intent_summary": v["intent"],
                                 "target_entities": [str(v["target"]).split(".")[:2]],
                                 "data_payload": [{"intent": v["intent"], "target": v["target"], "source_quote": v["source_quote"]}]}
                                for v in json.loads(user)["vreqs"]]}
        if "STRUCTURED OUTLINE" in system:
            return {"sections": [], "global_constraints": []}
        if "extracting USER INSTRUCTIONS" in system:
            return {"vreqs": list(self.vreqs) if "\n- " in user or user.split("\n\n", 1)[-1].strip().startswith("Rename") else []}
        if "completeness auditor" in system:
            return {"missing": []}
        return super().complete_json(system, user, temperature)

    def complete_with_tools(self, system, user, tools, tool_handlers, max_iters=6, temperature=0.0, response_schema=None):
        return self.complete_json(system, user, temperature)


class _NoLLM:
    def complete_json(self, *a, **k):
        raise AssertionError("no LLM call expected")

    complete_with_tools = complete_json


@pytest.fixture(autouse=True)
def _reset(monkeypatch):
    monkeypatch.setattr(ah, "logger", LOG, raising=False)
    ah.set_vibe_scope_runtime(None)
    yield
    ah.set_vibe_scope_runtime(None)


def _engine():
    return copy.deepcopy(_ENGINE)


def _domain(model, name):
    return next(d for d in model.get("model", model)["domains"] if d["name"] == name)


def _has(model, domain, product):
    return ah._v251_find_product(model, domain, product)[1] is not None


def _fks_into(model, domain, product):
    return [a.get("foreign_key_to") for _d, _p, a in ah._v251_iter_attribute_rows(model)
            if ah._vov_fk_points_at(a.get("foreign_key_to") or "", domain, product)]


PAIRS = [("product", "crew.member", "crew.crew_member")]


def _rename_batch(target_entities=(("crew", "crew_member"),), intent="Give the crew member table the name the user asked for", target="crew"):
    return ah.Batch(batch_id="B1", vreq_ids=("V1",), intent_summary=intent, target_entities=target_entities,
                    data_payload=({"intent": intent, "target": target, "source_quote": "- (medium) Rename to crew_member."},))


def _handler(src, summary="rename crew.member to crew_member in place"):
    return ah.Handler(batch_id="B1", mutator_src=src, verifier_src="", expected_changes_summary=summary,
                      target_entities=(("crew", "crew_member"),))


def _statuses(result):
    out = {}
    for outcome in result.outcomes:
        for vid in outcome.vreq_ids:
            out.setdefault(vid, []).append(outcome.status)
    return out


def _vreq(intent, target, vid="V1"):
    return ah.RawVREQ(vreq_id=vid, intent=intent, target=target, source_quote=intent, source_chunk_id="C1")


# ---------------------------------------------------------------- F1: rule-based routing of anchored directives


def test_f1_bare_product_target_resolves_to_a_rename_op():
    model = _engine()
    assert ah._v413_vreq_to_det_op(_vreq("Rename to crew_member.", "member"), model) == ("rename_product", "crew", "member", "crew_member")
    assert ah._v413_vreq_to_det_op(_vreq("Rename to crew_member.", "Product: member"), model) == ("rename_product", "crew", "member", "crew_member")
    assert ah._v413_vreq_to_det_op(_vreq("Rename member to crew_member", "crew.member"), model) == ("rename_product", "crew", "member", "crew_member")
    assert ah._v413_vreq_to_det_op(_vreq("Rename to member_key.", "crew.member.member_id"), model) == (
        "rename_attribute", "crew", "member", "member_id", "member_key")
    for vague in ("consider renaming columns", "Rename to", "Rename to something more meaningful", "Rename foo to bar",
                  "Rename the column to x"):
        assert ah._v413_vreq_to_det_op(_vreq(vague, "crew.member"), model) is None, vague
    assert ah._v413_vreq_to_det_op(_vreq("Rename to crew_member.", "crew.no_such_table"), model) is None


def test_f1_batch_fallback_applies_one_intent_only_to_a_single_target():
    model = _engine()
    single = ah.Batch(batch_id="B1", vreq_ids=("V1",), intent_summary="Rename to crew_member.", target_entities=(("crew", "member"),),
                      data_payload=())
    assert ah._v337_build_ops(single, model) == ([("rename_product", "crew", "member", "crew_member")], True)
    multi = ah.Batch(batch_id="B2", vreq_ids=("V1",), intent_summary="rename product to crew_roster_entry",
                     target_entities=(("crew", "member"), ("crew", "roster")), data_payload=())
    assert ah._v337_build_ops(multi, model) == ([], False)


def test_f1_merged_run_applies_the_anchored_rename_before_the_priority_branch():
    vibe = USER + RENAME_FEEDBACK + AUTO + "**PRIORITY 1 — connect_table: crew.member** — add column backup_base_id (BIGINT) with FK to crew.base.base_id\n"
    result = ah.run_vov_pipeline(vibe, _engine(), _NoLLM(), [], [], parallel=False, priority_reapply_loops=2)
    final = result.final_model
    assert not _has(final, "crew", "member") and _has(final, "crew", "crew_member")
    assert _fks_into(final, "crew", "member") == []
    added = ah._v251_find_attribute_row(final, "crew", "crew_member", "backup_base_id")
    assert added is not None and added["foreign_key_to"] == "crew.base.base_id"
    statuses = _statuses(result)
    assert statuses["ANCHOR-001"] == ["applied"] and "applied" in statuses["P001"]
    assert "ANCHOR-001" in {v.vreq_id for v in result.raw_vreqs} and result.coverage_pct == 100.0
    assert ah.vov_rename_events()[0] == {"kind": "product", "old": "crew.member", "new": "crew.crew_member", "cause": "ANCHOR-001"}


def test_f1_priority_branch_extracts_the_user_free_text():
    user_text = "## Domain: crew\n#### Product: member\n- (high) Link each crew member to a backup home base.\n"
    vibe = USER + user_text + AUTO + CONNECT_ROSTER
    llm = _FakeLLM(vreqs=[{"vreq_id": "V1", "target": "crew.member", "severity": "high", "is_user_directive": True,
                           "intent": "connect_table: crew.member — add column backup_home_base_id (BIGINT) with FK to crew.base.base_id",
                           "source_quote": "- (high) Link each crew member to a backup home base."}])
    result = ah.run_vov_pipeline(vibe, _engine(), llm, [], [], parallel=False, priority_reapply_loops=2)
    added = ah._v251_find_attribute_row(result.final_model, "crew", "member", "backup_home_base_id")
    assert added is not None and added["foreign_key_to"] == "crew.base.base_id"
    assert ah._v251_find_attribute_row(result.final_model, "crew", "roster", "backup_base_id") is not None
    user_vreqs = [v for v in result.raw_vreqs if v.vreq_id.startswith("U-")]
    assert len(user_vreqs) == 1 and user_vreqs[0].is_user_directive
    assert "applied" in _statuses(result)[user_vreqs[0].vreq_id]
    extraction_users = [user for system, user in llm.prompts if "extracting USER INSTRUCTIONS" in system]
    assert extraction_users and all("PRIORITY 1" not in u for u in extraction_users)


def test_f1_free_text_extraction_skips_vibes_without_the_merge_sentinels():
    assert ah._vov_extract_user_free_text(CONNECT_ROSTER + "Some prose about the model.\n", _NoLLM(), False, LOG) == []
    assert ah._vov_extract_user_free_text(USER + RENAME_FEEDBACK.replace("- (medium) Rename to crew_member.\n", "") + AUTO + CONNECT_ROSTER,
                                          _NoLLM(), False, LOG) == []


def test_f1_anchored_directives_need_a_named_product_heading_and_a_real_target():
    model = _engine()
    found = ah._vov_anchored_directives(USER + RENAME_FEEDBACK + "##### Attribute: aims_crew_code\n- Rename to aims_code\n" + AUTO
                                        + "## Domain: crew\n#### Product: roster\n- Rename to crew_roster\n", model)
    assert [(p["action"], p["target"], p["new_name"] or p["reason"]) for p in found] == [
        ("rename_product", "crew.member", "crew_member"),
        ("rename_attribute", "crew.member", "rename column aims_crew_code to aims_code")]
    assert found[0]["source_quote"].startswith("## Domain: crew\n#### Product: member\n")
    for text in ("## Domain: crew\n- Rename to crew_x\n", "#### Product: member\n- Rename to crew_member\n",
                 "## Domain: crew\n#### Product: nope\n- Rename to crew_member\n",
                 "## Domain: crew\n#### Product: member\n- consider renaming columns\n",
                 "## Domain: crew\n#### Product: member\n- Rename roster to crew_roster\n"):
        assert ah._vov_anchored_directives(text, model) == [], text


def test_f1_chunks_carry_their_heading_ancestry():
    vibe = "## Domain: procurement\n\n#### Product: livestock_procurement\n- (medium) Rename to livestock_procurement_allocation.\n"
    chunks = ah.chunk_vibe(vibe)
    product_chunk = next(c for c in chunks if "Rename to" in c.text)
    assert product_chunk.text.startswith("## Domain: procurement\n#### Product: livestock_procurement\n")
    assert vibe[product_chunk.byte_start:product_chunk.byte_end].startswith("#### Product:")
    assert next(c for c in chunks if c.text.startswith("## Domain: procurement")).text == "## Domain: procurement\n\n"


def test_f1_extraction_prompt_requires_fully_qualified_targets():
    prompt = ah.EXTRACTION_SYSTEM_PROMPT.format(outline_json="{}")
    assert "FULLY QUALIFIED" in prompt and "'#### Product:'" in prompt


# ---------------------------------------------------------------- F2: rename post-condition at every acceptance point


def test_f2_create_without_remove_is_rejected_after_retries_with_the_rename_hint():
    model = _engine()
    feedback = _rename_batch(intent="Rename to crew_member.", target="crew.member")
    assert ah._vov_rename_pairs_for_batch(feedback, model) == PAIRS
    llm = _FakeLLM(mutator=COPY_MUTATOR)
    inv = ah.capture_invariants(model, [], [])
    new_model, outcome = ah._apply_handler_with_retry(_handler(COPY_MUTATOR), _rename_batch(), model, inv, llm, 3, (), (), 600.0, PAIRS)
    assert new_model is None and outcome.status == "rename_postcondition_failed" and outcome.attempts == 3
    assert "crew.member still exists next to crew.crew_member" in outcome.diagnostic
    retries = [user for system, user in llm.prompts if "careful Python code generator" in system]
    assert len(retries) == 2 and all("RENAME NOT APPLIED IN PLACE" in u for u in retries)
    assert all("CREATE them in your mutator" not in u and "RENAME OR MOVE BATCH" in u for u in retries)


def test_f2_in_place_rename_with_dangling_fks_is_rejected_and_the_correct_one_lands():
    model = _engine()
    inv = ah.capture_invariants(model, [], [])
    _m, bad = ah._apply_handler_with_retry(_handler(IN_PLACE_NO_FK_MUTATOR), _rename_batch(), model, inv,
                                           _FakeLLM(mutator=IN_PLACE_NO_FK_MUTATOR), 1, (), (), 600.0, PAIRS)
    assert bad.status == "rename_postcondition_failed" and "foreign_key_to still point at crew.member" in bad.diagnostic
    new_model, good = ah._apply_handler_with_retry(_handler(IN_PLACE_MUTATOR), _rename_batch(), model, inv,
                                                   _FakeLLM(mutator=IN_PLACE_MUTATOR), 1, (), (), 600.0, PAIRS)
    assert good.status == "applied" and not _has(new_model, "crew", "member") and _has(new_model, "crew", "crew_member")


def test_f2_a_new_product_with_overlapping_columns_is_not_a_rename():
    model = _engine()
    inv = ah.capture_invariants(model, [], [])
    batch = _rename_batch(target_entities=(("crew", "member_history"),), intent="add product crew.member_history keeping member columns",
                          target="crew.member_history")
    new_model, outcome = ah._apply_handler_with_retry(_handler(HISTORY_MUTATOR, "add product member_history"), batch, model, inv,
                                                      _FakeLLM(mutator=HISTORY_MUTATOR, summary="add product member_history"), 1, (), (), 600.0)
    assert outcome.status == "applied" and _has(new_model, "crew", "member") and _has(new_model, "crew", "member_history")


def test_f2_deterministic_preskip_does_not_credit_a_rename_that_has_not_landed():
    model = _engine()
    inv = ah.capture_invariants(model, [], [])
    batch = _rename_batch(intent="Give the crew member table the asked-for name and keep its description", target_entities=(("crew", "member"),))
    llm = _FakeLLM(mutator=IN_PLACE_MUTATOR)
    new_model, outcome = ah._apply_handler_with_retry(_handler("def mutator(model, data):\n    return model\n"), batch, model, inv, llm, 1,
                                                      (), (), 600.0, PAIRS)
    assert outcome.status != "applied" or (new_model is not None and not _has(new_model, "crew", "member"))
    assert not str(outcome.diagnostic).startswith("already-satisfied (deterministic pre-skip)")


def test_f2_already_satisfied_noop_credit_requires_the_rename():
    model = _engine()
    inv = ah.capture_invariants(model, [], [])
    noop = "def mutator(model, data):\n    return model\n"
    _m, outcome = ah._apply_handler_with_retry(_handler(noop, "already satisfied: crew.member is fine"), _rename_batch(), model, inv,
                                               _FakeLLM(mutator=noop, summary="already satisfied: crew.member is fine"), 1, (), (), 600.0, PAIRS)
    assert outcome.status == "rename_postcondition_failed"


def test_f2_else_loop_vetoes_an_applied_rename_that_did_not_land():
    base = _engine()
    outcomes = [ah.VReqOutcome(batch_id="B1", vreq_ids=("V1", "V2"), status="applied", diagnostic="", attempts=1)]
    vreqs = [_vreq("Rename to crew_member.", "crew.member", "V1"), _vreq("Describe crew.roster", "crew.roster", "V2")]
    assert ah._vov_veto_unlanded_renames(outcomes, 0, vreqs, base, base, LOG) == 1
    assert [(o.vreq_ids, o.status) for o in outcomes] == [(("V2",), "applied"), (("V1",), "rename_postcondition_failed")]
    landed = _engine()
    ah._v337_apply_rename_product(ah._v251_model_root(landed), "crew", "member", "crew_member")
    again = [ah.VReqOutcome(batch_id="B1", vreq_ids=("V1",), status="applied", diagnostic="", attempts=1)]
    assert ah._vov_veto_unlanded_renames(again, 0, vreqs[:1], base, landed, LOG) == 0 and again[0].status == "applied"
    src = notebook_concat_source()
    assert "if _vov_veto_unlanded_renames(outcomes, _outcomes_before, _remaining_vreqs, initial_model, model, logger):" in src


class _Sandbox:
    def __init__(self, new_model):
        self.new_model = new_model

    def __call__(self, mutator_src, verifier_src, model, data=None, timeout=20.0, **_k):
        from types import SimpleNamespace
        return SimpleNamespace(ok=True, verifier_ok=True, verifier_diag="", error=None, new_model=copy.deepcopy(self.new_model))


class _Agent:
    def _call_ai_query(self, **kwargs):
        return {"mutator_src": "def mutator(model, data):\n    return model\n", "verifier_src": "def verifier(model, data):\n    return True, ''\n",
                "rationale": "fix"}


def _fixer(new_model):
    fixer = ah.SelfFixer(ai_agent=_Agent(), logger=LOG, sandbox_executor=_Sandbox(new_model), llm_endpoint=None)
    fixer.llm_endpoint = None
    return fixer


def test_f2_selffixer_rejects_a_create_only_rename_and_accepts_a_merge():
    model = _engine()
    twin = copy.deepcopy(model)
    crew = _domain(twin, "crew")
    crew["products"].append(dict(copy.deepcopy(next(p for p in crew["products"] if p["name"] == "member")), name="crew_member"))
    req = {"id": "VREQ-0007", "text": "Rename crew.member to crew_member", "evidence": "both tables exist"}
    ok, _applied, evidence = _fixer(twin)._fix_one_req(copy.deepcopy(model), req, per_req_retries=0)
    assert not ok and "rename post-condition FAILED" in evidence
    leftover = copy.deepcopy(twin)
    merged = copy.deepcopy(twin)
    mcrew = _domain(merged, "crew")
    mcrew["products"] = [p for p in mcrew["products"] if p["name"] != "member"]
    for _d, _p, a in ah._v251_iter_attribute_rows(merged):
        if str(a.get("foreign_key_to") or "").startswith("crew.member."):
            a["foreign_key_to"] = "crew.crew_member." + a["foreign_key_to"].split(".", 2)[2]
    fixer = _fixer(merged)
    ok, _applied, evidence = fixer._fix_one_req(leftover, req, per_req_retries=0)
    assert ok and evidence == "applied" and not _has(leftover, "crew", "member")
    assert ah.vov_rename_events() == []
    fixer._vov_commit_renames("VREQ-0007")
    assert ah.vov_rename_events()[0]["cause"] == "selffixer:VREQ-0007"


def test_f2_rename_batches_lose_the_create_missing_rule_in_both_prompts():
    model = _engine()
    captured = []

    class _Capture(_FakeLLM):
        def complete_json(self, system, user, temperature=0.0, response_schema=None):
            captured.append(user)
            return super().complete_json(system, user, temperature, response_schema)

    ah.synthesize_handler(_rename_batch(intent="Rename to crew_member.", target="crew.member"), _Capture(), model_snapshot=model)
    ah.synthesize_handler(_rename_batch(), _Capture(), model_snapshot=model, rename_pairs=PAIRS)
    plain = ah.Batch(batch_id="B2", vreq_ids=("V2",), intent_summary="add column x to crew.roster", target_entities=(("crew", "roster"),),
                     data_payload=({"intent": "add column x to crew.roster", "target": "crew.roster", "source_quote": "add x"},))
    ah.synthesize_handler(plain, _Capture(), model_snapshot=model)
    for rename_prompt in captured[:2]:
        assert "CREATE them in your mutator" not in rename_prompt and "RENAME OR MOVE BATCH" in rename_prompt
        assert "never create the new name next to the old one" in rename_prompt
    assert "CREATE them in your mutator" in captured[2] and "RENAME OR MOVE BATCH" not in captured[2]
    prompts = []

    class _PromptAgent:
        def _call_ai_query(self, **kwargs):
            prompts.append(kwargs["prompt"])
            return {"mutator_src": "", "verifier_src": "", "rationale": ""}

    fixer = ah.SelfFixer(ai_agent=_PromptAgent(), logger=LOG, sandbox_executor=_Sandbox(model), llm_endpoint=None)
    fixer.llm_endpoint = None
    fixer._call_opus("R1", "Rename crew.member to crew_member", "", "{}", rename=True)
    fixer._call_opus("R2", "Add column x", "", "{}")
    assert "CREATE-THEN-MUTATE" not in prompts[0] and "RENAME OR MOVE REQ" in prompts[0]
    assert "CREATE-THEN-MUTATE" in prompts[1]


def test_f2_scope_fence_violation_gets_its_own_retry_hint():
    trace = "attempt 1: invariants violated: scope_fence_violation: 1 change(s) outside vibe_scope; frozen_product_changed fleet.aircraft"
    hint = ah._v204_ast_class_hints(trace)
    assert "VIBE SCOPE FENCE" in hint and "removed a user-pinned domain or product" not in hint
    pinned = ah._v204_ast_class_hints("attempt 1: invariants violated: user-pinned products removed: [('crew', 'member')]")
    assert "removed a user-pinned domain or product" in pinned and "VIBE SCOPE FENCE" not in pinned
    conflict = ah._v204_ast_class_hints("attempt 2: invariants violated: scope_dependency_conflict: 1 blocked change(s)")
    assert "VIBE SCOPE DEPENDENCY CONFLICT" in conflict


# ---------------------------------------------------------------- F3: one ledger for every run


def test_f3_renames_land_in_one_ledger_without_a_fence():
    model = _engine()
    assert ah.get_vibe_scope_runtime() is None
    ah._v337_apply_rename_product(ah._v251_model_root(model), "crew", "member", "crew_member")
    assert ah.vov_rename_events() == [
        {"kind": "product", "old": "crew.member", "new": "crew.crew_member", "cause": ""},
        {"kind": "attribute", "old": "crew.crew_member.member_id", "new": "crew.crew_member.crew_member_id", "cause": ""}]
    ah._vibe_scope_note_rename("product", "crew.member", "crew.crew_member", "VREQ-1")
    assert ah.vov_rename_events()[0]["cause"] == "VREQ-1" and len(ah.vov_rename_events()) == 2
    ah.vov_ledger_reset()
    assert ah.vov_rename_events() == [] and ah.vov_change_events() == []


def test_f3_ledger_accepts_domain_and_move_kinds_and_the_fence_follows_them():
    fence = ah.build_vibe_scope_fence(ah.parse_vibe_scope("Some Domains", "crew"), RAW, VOV, LOG)
    ah.set_vibe_scope_runtime(fence)
    fence.record_rename("domain", "crew", "aircrew")
    fence.record_rename("move", "aircrew.absence", "safety.absence")
    assert fence._resolve_candidates("crew", "absence", "absence_id") == [("aircrew", "absence", "absence_id"), ("safety", "absence", "absence_id")]
    assert [e["kind"] for e in ah.vov_rename_events()] == ["domain", "move"]
    for bad in (("domain", "crew.x", "aircrew"), ("move", "crew", "safety"), ("attribute", "crew.member", "crew.member2"), ("table", "a.b", "a.c")):
        with pytest.raises(ValueError):
            fence.record_rename(*bad)


def test_f3_review_gate_reads_the_ledger_and_protects_renamed_products_under_their_new_names():
    model = fu.small_model()
    d, p, a, _mv = ah.model_to_widgets_flat(model)
    wv = {"operation": VOV, "_v357_v1_products_snapshot": copy.deepcopy(p), "_v357_v1_attributes_snapshot": copy.deepcopy(a)}
    pre_qa = ah._vov_review_pre_qa_snapshot(wv, p, a)
    p[:] = [x for x in p if x["product"] != "invoice"] + [dict(next(x for x in p if x["product"] == "invoice"), product="bill")]
    ah._vibe_scope_note_rename("product", "billing.invoice", "billing.bill", "VREQ-3")
    assert ah._vov_review_preservation_gate(wv, pre_qa, d, p, a) == 0
    assert "invoice" not in {x["product"] for x in p}
    renamed = ah.model_to_widgets_flat(model)
    d2, p2, a2 = renamed[0], renamed[1], renamed[2]
    for row in p2 + a2:
        if row.get("product") == "invoice":
            row["product"] = "bill"
    pre_qa2 = ah._vov_review_pre_qa_snapshot(wv, p2, a2)
    p2[:] = [x for x in p2 if x["product"] != "bill"]
    a2[:] = [x for x in a2 if x["product"] != "bill"]
    assert ah._vov_review_preservation_gate(wv, pre_qa2, d2, p2, a2) == 1
    assert "bill" in {x["product"] for x in p2} and "invoice" not in {x["product"] for x in p2}
    assert {"kind": "restore", "path": "billing.bill", "cause": "pass:review_preservation_gate", "target": ""} in ah.vov_change_events()


def test_f3_v357_gate_honours_a_ledgered_suffix_rename():
    model = fu.small_model()
    _d, p, a = ah.model_to_widgets_flat(model)[:3]
    v1p, v1a = copy.deepcopy(p), copy.deepcopy(a)
    for row in p + a:
        if row.get("product") == "invoice":
            row["product"] = "invoice_header"
    ah._vibe_scope_note_rename("product", "billing.invoice", "billing.invoice_header", "VREQ-4")
    assert ah._vov_product_rename_map() == {"invoice": "invoice_header"}
    assert ah._v357_enforce_product_preservation_flat(v1p, v1a, _d, p, a, logger=LOG, applied_renames=ah._vov_product_rename_map()) == 0
    assert "applied_renames=_vov_product_rename_map()" in notebook_concat_source()


def test_f3_user_renamed_attributes_live_in_the_ledger():
    ah._record_user_renamed_attribute("clinical", "note_template", "parent_note_template_id", logger=LOG, source="test",
                                      old_attribute_name="parent_id")
    assert ah._is_user_renamed_attribute("clinical", "note_template", "parent_note_template_id") is True
    assert ah._is_user_renamed_attribute("clinical", "note_template", "parent_id") is False
    assert ah.vov_rename_events() == [{"kind": "attribute", "old": "clinical.note_template.parent_id",
                                       "new": "clinical.note_template.parent_note_template_id", "cause": "user:test"}]
    ah._vibe_scope_note_rename("attribute", "crew.member.a", "crew.member.b", "naming")
    assert ah._is_user_renamed_attribute("crew", "member", "b") is False
    assert "_USER_RENAMED_ATTRIBUTES_RUNTIME" not in notebook_concat_source()


def test_f3_v310_redirect_follows_landed_renames_from_the_ledger():
    model = _engine()
    ah._v337_apply_rename_product(ah._v251_model_root(model), "crew", "member", "crew_member")
    prios = [{"action": "connect_table", "target": "crew.member", "reason": "On crew.member, add column x_id with FK to crew.base.base_id"}]
    assert ah._v310_apply_rename_ledger(prios, LOG, model) == 1
    assert prios[0]["target"] == "crew.crew_member" and prios[0]["reason"].startswith("On crew.crew_member,")
    stale = _engine()
    stale_prios = [{"action": "connect_table", "target": "crew.member", "reason": "x"}]
    assert ah._v310_apply_rename_ledger(stale_prios, LOG, stale) == 0 and stale_prios[0]["target"] == "crew.member"


def test_f3_unrecorded_rename_of_a_referenced_in_scope_product_is_renamed_back_not_duplicated():
    fence = ah.build_vibe_scope_fence(ah.parse_vibe_scope("Some Domains", "crew"), RAW, VOV, LOG)
    ah.set_vibe_scope_runtime(fence)
    assert fence.referenced_from_outside("crew", "absence")
    d, p, a, mv = (list(x) for x in ah.model_to_widgets_flat(RAW))
    before = len(p)
    for row in p + a:
        if (row.get("domain"), row.get("product")) == ("crew", "absence"):
            row["product"] = "leave_of_absence"
    fence.checkpoint("after_llm", d, p, a, mv, LOG)
    names = {r["product"] for r in p if r["domain"] == "crew"}
    assert "absence" in names and "leave_of_absence" not in names and len(p) == before
    assert fence.report()["unrequested_drops"][0]["repair"] == "renamed_back"
    assert fence.check_flat(d, p, a, mv).ok


def test_f3_pipeline_records_a_verified_llm_rename_with_its_requirement_id():
    model = _engine()
    crew = _domain(model, "crew")
    crew["products"].append(dict(copy.deepcopy(next(x for x in crew["products"] if x["name"] == "member")), name="crew_member"))
    llm = _FakeLLM(mutator=MERGE_MUTATOR, summary="merge member into crew_member",
                   vreqs=[{"vreq_id": "V1", "intent": "Rename crew.member to crew_member", "target": "crew.member",
                           "source_quote": "Rename crew.member to crew_member.", "severity": "high", "is_user_directive": True}])
    result = ah.run_vov_pipeline("Rename crew.member to crew_member.\n", model, llm, [], [], parallel=False, priority_reapply_loops=1)
    assert not _has(result.final_model, "crew", "member") and _has(result.final_model, "crew", "crew_member")
    event = next(e for e in ah.vov_rename_events() if e["kind"] == "product")
    assert event["old"] == "crew.member" and event["new"] == "crew.crew_member" and event["cause"] == "VREQ-0001"


# ---------------------------------------------------------------- F4: the merge does not resurrect the old side


def test_f4_merge_partial_drops_the_old_side_of_a_verified_rename():
    base = _engine()
    cand = copy.deepcopy(base)
    ah._v337_apply_rename_product(ah._v251_model_root(cand), "crew", "member", "crew_member")
    roster_fk = next(a for a in next(p for p in _domain(base, "crew")["products"] if p["name"] == "roster")["attributes"]
                     if a["name"] == "member_id")
    roster_fk["foreign_key_to"] = "crew.member.member_id"
    targets = (("crew", "crew_member"),)
    resurrected = ah._merge_partial(base, cand, targets)
    assert _has(resurrected, "crew", "member") and _has(resurrected, "crew", "crew_member")
    merged = ah._merge_partial(base, cand, targets, [("product", "crew.member", "crew.crew_member")])
    assert not _has(merged, "crew", "member") and _has(merged, "crew", "crew_member")
    assert _fks_into(merged, "crew", "member") == []
    assert ah._vov_rename_postcondition(base, merged, [("product", "crew.member", "crew.crew_member")]) == (True, "")


# ---------------------------------------------------------------- F5: static gate, autofix, scoring, P73-E


def _leftover_flat(twin="member_record"):
    d, p, a, mv = (list(x) for x in ah.model_to_widgets_flat(RAW))
    member = next(r for r in p if (r["domain"], r["product"]) == ("crew", "member"))
    p.append(dict(member, product=twin, table_name=twin, primary_key=f"{twin}_id"))
    for row in [r for r in a if (r["domain"], r["product"]) == ("crew", "member")]:
        name = f"{twin}_id" if row["attribute"] == "member_id" else row["attribute"]
        a.append(dict(row, product=twin, attribute=name, column_name=name))
    return d, p, a, mv


def test_f5_gate_flags_a_rename_leftover_but_not_a_parent_child_pair():
    d, p, a, _mv = _leftover_flat()
    p.append({"domain": "crew", "product": "roster_line", "primary_key": "roster_line_id"})
    a.append({"domain": "crew", "product": "roster_line", "attribute": "roster_line_id", "type": "BIGINT"})
    a.append({"domain": "crew", "product": "roster_line", "attribute": "roster_id", "type": "BIGINT", "foreign_key_to": "crew.roster.roster_id"})
    a.append({"domain": "crew", "product": "roster_line", "attribute": "line_number", "type": "INT"})
    issues = ah.run_metamodel_static_analysis(d, p, a, {}, LOG)["issues"]
    found = [i for i in issues if i["category"] == "rename_leftover_original"]
    assert len(found) == 1 and found[0]["severity"] == "error" and found[0]["details"]["basis"] == "name_extension"
    assert {found[0]["details"]["old"], found[0]["details"]["new"]} == {"member", "member_record"}
    assert found[0]["details"]["jaccard"] >= 0.7 and found[0]["message"].startswith("Rename crew.")
    d2, p2, a2, _mv2 = _leftover_flat("crew_member")
    ah._vibe_scope_note_rename("product", "crew.member", "crew.crew_member", "VREQ-2")
    issues2 = ah.run_metamodel_static_analysis(d2, p2, a2, {}, LOG)["issues"]
    ledgered = [i for i in issues2 if i["category"] == "rename_leftover_original"]
    assert [(i["details"]["old"], i["details"]["new"], i["details"]["basis"]) for i in ledgered] == [("member", "crew_member", "ledger")]
    assert not [i for i in issues2 if i["category"] == "duplicate_product_pair" and i["details"]["domain"] == "crew"]
    assert ah._vov_rename_similarity(["roster_id", "base_id", "approval_status"], ["roster_line_id", "roster_id", "line_number"],
                                     "roster_id", "roster_line_id") < 0.7


def test_f5_autofix_merges_the_leftover_into_the_ledgered_new_name():
    d, p, a, _mv = _leftover_flat("member_record")
    ah._vibe_scope_note_rename("product", "crew.member", "crew.member_record", "VREQ-9")
    ah._pre_static_analysis_autofix(d, p, a, {}, LOG)
    crew = {r["product"] for r in p if r["domain"] == "crew"}
    assert "member" not in crew and "member_record" in crew
    assert not [r for r in a if str(r.get("foreign_key_to") or "").startswith("crew.member.")]
    assert any(str(r.get("foreign_key_to") or "") == "crew.member_record.member_record_id" for r in a)
    merge = next(e for e in ah.vov_change_events() if e["kind"] == "merge")
    assert merge == {"kind": "merge", "path": "crew.member", "cause": "pass:pre_sa_autofix", "target": "crew.member_record"}
    assert not [i for i in ah.run_metamodel_static_analysis(d, p, a, {}, LOG)["issues"] if i["category"] == "rename_leftover_original"]


def test_f5_a_stub_recreated_under_a_ledgered_old_name_is_reported_as_a_warning_and_never_auto_merged():
    d, p, a, _mv = (list(x) for x in ah.model_to_widgets_flat(RAW))
    for row in p:
        if (row["domain"], row["product"]) == ("crew", "member"):
            row.update(product="crew_member", table_name="crew_member", primary_key="crew_member_id")
    for row in a:
        if (row["domain"], row["product"]) == ("crew", "member"):
            row["product"] = "crew_member"
            if row["attribute"] == "member_id":
                row["attribute"] = row["column_name"] = "crew_member_id"
    ah._vibe_scope_note_rename("product", "crew.member", "crew.crew_member", "VREQ-3")
    p.append({"domain": "crew", "product": "member", "primary_key": "member_id", "subdomain": "crew_records"})
    a += [{"domain": "crew", "product": "member", "attribute": "member_id", "type": "BIGINT"},
          {"domain": "crew", "product": "member", "attribute": "saved_by_employee_id", "type": "BIGINT"}]
    issues = ah.run_metamodel_static_analysis(d, p, a, {}, LOG)["issues"]
    found = [i for i in issues if i["category"] == "rename_leftover_original"]
    assert [(i["severity"], i["details"]["old"], i["details"]["new"], i["details"]["confident"]) for i in found] == [
        ("warning", "member", "crew_member", False)]
    assert not [i for i in issues if i["category"] == "duplicate_product_pair" and i["details"]["domain"] == "crew"]
    assert ah._vov_merge_rename_leftovers(p, a, {}, LOG, "t") == 0
    assert {"member", "crew_member"} <= {r["product"] for r in p if r["domain"] == "crew"}


def test_f5_autofix_skips_frozen_pairs_and_user_named_products():
    d, p, a, _mv = _leftover_flat()
    cfg = {"PROMPT_VARIABLES": {"business_config": {"must_have_data_products": "member"}}}
    assert ah._vov_merge_rename_leftovers(p, a, cfg, LOG, "t") == 0
    fence = ah.build_vibe_scope_fence(ah.parse_vibe_scope("Some Domains", "flight"), RAW, VOV, LOG)
    ah.set_vibe_scope_runtime(fence)
    assert ah._vov_merge_rename_leftovers(p, a, {}, LOG, "t") == 0
    assert {"member", "member_record"} <= {r["product"] for r in p if r["domain"] == "crew"}
    ah.set_vibe_scope_runtime(None)
    assert ah._vov_merge_rename_leftovers(p, a, {}, LOG, "t") == 1


def test_f5_gate_is_wired_into_scoring_requeue_and_p73e():
    src = notebook_concat_source()
    assert "'fk_pk_type_mismatch', 'rename_leftover_original'}" in src
    assert "'duplicate_product_pair', 'duplicate_product_name', 'rename_leftover_original'," in src
    assert '_p73e_merged += _vov_merge_rename_leftovers(products_data, attributes_data, config, logger, "finalize_p73e")' in src


# ---------------------------------------------------------------- item 3: M:N ratio enforcement under 9A


class _NoSuggestionsAgent:
    def _call_ai_query(self, **_kwargs):
        return {"associations_to_remove": []}


def test_m2m_ratio_never_removes_frozen_or_referenced_products_and_records_its_drops():
    fence = ah.build_vibe_scope_fence(ah.parse_vibe_scope("Some Domains", "crew"), RAW, VOV, LOG)
    ah.set_vibe_scope_runtime(fence)
    _d, p, a, _mv = (list(x) for x in ah.model_to_widgets_flat(RAW))
    free = next(r["product"] for r in p if r["domain"] == "crew" and not fence.referenced_from_outside("crew", r["product"]))
    for row in p:
        row["type"] = "associative" if (row["domain"], row["product"]) in {("crew", "absence"), ("crew", free), ("fleet", "aircraft")} else "business"
    p[:] = [r for r in p if r["type"] == "associative"] + [r for r in p if r["type"] != "associative"][:12]
    ah._enforce_m2m_ratio(p, a, _NoSuggestionsAgent(), {"MODEL_SCOPE": "ecm"}, LOG)
    kept = {(r["domain"], r["product"]) for r in p}
    assert ("crew", "absence") in kept and ("fleet", "aircraft") in kept and ("crew", free) not in kept
    assert {"kind": "drop", "path": f"crew.{free}", "cause": "pass:enforce_m2m_ratio", "target": ""} in ah.vov_change_events()

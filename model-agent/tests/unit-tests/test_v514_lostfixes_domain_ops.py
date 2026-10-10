import copy
import json
import logging
import sys
from pathlib import Path
from types import SimpleNamespace

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent))
import conftest  # noqa: F401,E402
import agent_helpers as ah  # noqa: E402

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
VIBES = json.loads((HERE / "fixtures" / "v514_lostfixes_pc_vibes.json").read_text())
VOV = "vibe modeling of version"
LOG = logging.getLogger("test_v514_lostfixes_domain_ops")


@pytest.fixture(autouse=True)
def _no_scope():
    ah.set_vibe_scope_runtime(None)
    yield
    ah.set_vibe_scope_runtime(None)


def _p(name, *extra):
    return {"name": name, "primary_key": name + "_id", "attributes": [{"name": name + "_id", "type": "BIGINT"}] + list(extra)}


def _fk(name, target):
    return {"name": name, "type": "BIGINT", "foreign_key_to": target}


def _pc_model():
    return {"model": {"domains": [
        {"name": "claims", "database_name": "claims", "products": [_p("claim"), _p("claim_status")]},
        {"name": "claimfinancials", "database_name": "claimfinancials", "products": [
            _p("reserve", _fk("claim_id", "claims.claim.claim_id"))]},
        {"name": "riskexposure", "database_name": "riskexposure", "products": [_p("property_risk")]},
        {"name": "catastrophegeography", "database_name": "catastrophegeography", "products": [_p("peril")]},
        {"name": "coverage", "database_name": "coverage", "products": [
            _p(n) for n in ("coverage", "limit", "deductible", "exclusion", "submission", "uw_decision", "quote", "binder")]},
        {"name": "underwriting", "database_name": "underwriting", "products": [_p("uw_guideline")]},
        {"name": "policy", "database_name": "policy", "products": [_p(
            "policy",
            _fk("reserve_ref", "claimfinancials.reserve.reserve_id"),
            _fk("risk_ref", "riskexposure.property_risk.property_risk_id"),
            _fk("peril_ref", "catastrophegeography.peril.peril_id"),
            _fk("submission_ref", "coverage.submission.submission_id"))]},
    ]}}


def _domains(m):
    return m["model"]["domains"]


def _domain(m, name):
    return next(d for d in _domains(m) if d["name"] == name)


def _names(m):
    return [d["name"] for d in _domains(m)]


def _where(m, product):
    return [d["name"] for d in _domains(m) for p in d["products"] if p["name"] == product]


def _policy_fks(m):
    return {a["name"]: a.get("foreign_key_to") for a in _domain(m, "policy")["products"][0]["attributes"]}


def _dangling(m):
    live = {(d["name"], p["name"]) for d in _domains(m) for p in d["products"]}
    return [a["foreign_key_to"] for d in _domains(m) for p in d["products"] for a in p["attributes"]
            if a.get("foreign_key_to") and tuple(a["foreign_key_to"].split(".")[:2]) not in live]


def _flat(m):
    domains = [{"domain": d["name"]} for d in _domains(m)]
    products = [{"domain": d["name"], "product": p["name"]} for d in _domains(m) for p in d["products"]]
    attributes = [{"domain": d["name"], "product": p["name"], "attribute": a["name"], "foreign_key_to": a.get("foreign_key_to", "")}
                  for d in _domains(m) for p in d["products"] for a in p["attributes"]]
    return domains, products, attributes


@pytest.mark.parametrize("order", [("A1", "A2", "A3", "A4"), ("A2", "A1", "A3", "A4"), ("A4", "A3", "A2", "A1")])
def test_a1_to_a4_land_through_the_selffix_precheck_in_every_order(order):
    m = _pc_model()
    for key in order:
        ok, evidence = ah._v410_deterministic_selffix(m, {"id": key, "text": VIBES[key]}, LOG)
        assert ok is True, (key, evidence)
    assert _names(m) == ["claim", "risk", "catastrophe", "coverage", "underwriting", "policy"]
    assert [d["database_name"] for d in _domains(m)][:3] == ["claim", "risk", "catastrophe"]
    reserve = next(p for p in _domain(m, "claim")["products"] if p["name"] == "reserve")
    assert reserve["subdomain"] == "claimfinancials"
    assert next(a for a in reserve["attributes"] if a["name"] == "claim_id")["foreign_key_to"] == "claim.claim.claim_id"
    fks = _policy_fks(m)
    assert fks["reserve_ref"] == "claim.reserve.reserve_id"
    assert fks["risk_ref"] == "risk.property_risk.property_risk_id"
    assert fks["peril_ref"] == "catastrophe.peril.peril_id"
    assert _dangling(m) == []


def test_a1_to_a4_land_through_the_vov_preapply_path():
    m = _pc_model()
    for key in ("A1", "A2", "A3", "A4"):
        op = ah._v413_vreq_to_det_op(SimpleNamespace(source_quote="", intent=VIBES[key], target=""), m)
        assert op is not None and op[0] in ("merge_domain", "rename_domain"), (key, op)
        model, result, verdict = ah._vibe_scope_apply_det_op(m, op, "v413-preapply", (key,), LOG)
        assert result and verdict == ("", ""), (key, result, verdict)
        m = model
    assert _names(m) == ["claim", "risk", "catastrophe", "coverage", "underwriting", "policy"]
    assert _dangling(m) == []


def test_b1_moves_only_the_listed_products_that_exist_and_repoints_their_fks():
    m = _pc_model()
    ok, evidence = ah._v410_deterministic_selffix(m, {"id": "B1", "text": VIBES["B1"]}, LOG)
    assert ok is True, evidence
    assert evidence.startswith("bulk_move 4/4 coverage->underwriting")
    for product in ("submission", "uw_decision", "quote", "binder"):
        assert _where(m, product) == ["underwriting"], product
    for product in ("coverage", "limit", "deductible", "exclusion"):
        assert _where(m, product) == ["coverage"], product
    assert _policy_fks(m)["submission_ref"] == "underwriting.submission.submission_id"
    assert _dangling(m) == []


def test_r3_parenthesised_and_keep_lists_are_never_moved():
    text = ("MOVE the following products FROM the `coverage` domain INTO the `underwriting` domain: submission, quote. "
            "Leave the rest (keep: coverage, limit, deductible, exclusion, binder, uw_decision) in `coverage`. "
            "Keep these in coverage: coverage, limit, deductible, exclusion, uw_decision, binder.")
    assert ah._v337_extract_bulk_move(text) == ("coverage", "underwriting", ["submission", "quote"])
    assert ah._v337_extract_bulk_move(VIBES["B1"]) == ("coverage", "underwriting", VIBES["uw_move_products"])
    m = _pc_model()
    ok, evidence = ah._v410_deterministic_selffix(m, {"id": "R3", "text": text}, LOG)
    assert ok is True, evidence
    assert _where(m, "submission") == ["underwriting"] and _where(m, "quote") == ["underwriting"]
    for product in ("coverage", "limit", "deductible", "exclusion", "binder", "uw_decision"):
        assert _where(m, product) == ["coverage"], product
    assert ah._v337_extract_bulk_move("Do not move the following products FROM the `coverage` domain INTO the "
                                      "`underwriting` domain: submission, quote.") is None


def test_r1_table_product_column_and_negated_renames_never_rename_the_domain():
    assert ah._v337_classify_op("", "", VIBES["A2"], VIBES["A2"]) == ("rename_domain", "claims", "claim")
    assert ah._v337_classify_op("", "", VIBES["A3"], VIBES["A3"]) == ("rename_domain", "riskexposure", "risk")
    for text in ("RENAME the `claims` domain table `claim_status` to `claim_state`",
                 "RENAME the claims domain's claim_status to claim_state",
                 "Rename the claims domain product claim_status to claim_state",
                 "rename domain claims column status to state",
                 "Do not rename the `claims` domain to `claim`."):
        assert ah._v337_extract_domain_rename(text) is None, text
        assert ah._v337_classify_op("", "", text, text) is None, text
        m = _pc_model()
        before = copy.deepcopy(m)
        ok, _evidence = ah._v410_deterministic_selffix(m, {"id": "R1", "text": text}, LOG)
        assert ok is None and m == before, text


def test_r4_hijack_lines_and_published_next_vibes_never_trigger_domain_or_bulk_ops():
    hijacks = (
        "**PRIORITY 99 — rename_product: product.product_category** — rename to category_secondary because domain product "
        "has both category and product_category creating an SSOT violation; merge attributes into category",
        "**PRIORITY 148 — connect_table: service.contract_line** — add column service_contract_id (BIGINT) with FK to "
        "service.service_contract.service_contract_id — after merging service_contract_line into contract_line",
    )
    for text in hijacks:
        assert ah._v337_extract_domain_merge(text) is None, text
    assert ah._v337_extract_domain_merge("Fold `claimfinancials` into `claims` as a subdomain.") == ("claimfinancials", "claims")
    lines = 0
    fires = []
    for path in sorted(REPO.glob("data-models/**/next_vibes.txt")):
        for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
            if not line.strip():
                continue
            lines += 1
            for fn in (ah._v337_extract_domain_rename, ah._v337_extract_domain_merge, ah._v337_extract_bulk_move):
                if fn(line):
                    fires.append((path.name, fn.__name__, line[:120]))
    assert lines > 1000
    assert fires == []


def test_r9_merge_refuses_product_name_collisions(caplog):
    m = _pc_model()
    assert ah._v337_apply_merge_domain(m["model"], "claimfinancials", "claims", LOG).startswith("merge_domain claimfinancials->claims")
    assert "claimfinancials" not in _names(m) and _where(m, "reserve") == ["claims"]
    clash = _pc_model()
    _domain(clash, "claimfinancials")["products"].append(_p("claim_status"))
    before = copy.deepcopy(clash)
    with caplog.at_level(logging.WARNING, logger=LOG.name):
        assert ah._v337_apply_merge_domain(clash["model"], "claimfinancials", "claims", LOG) is None
        assert ah._v337_apply_rename_domain(clash["model"], "claimfinancials", "claims", LOG) is None
    assert clash == before
    assert sum("[v337-merge-domain-collision FIRED v5.1.4]" in r.getMessage() for r in caplog.records) == 2


def _orch(base):
    return ah.VibeOrchestrator({"logger": LOG, "config": {}, "vibe_modelling_instructions": "vibes", "business_context_raw": base})


def _req(text, strategy="state_diff"):
    return ah.VibeRequirement(id="VREQ-T", original_text=text, intent="modify", scope="domain", verification_strategy=strategy)


def test_r2_rename_verdict_preempts_the_preserve_structure_lie():
    base = _pc_model()
    orch = _orch(base)
    d, p, a = _flat(base)
    orch._step_snapshots["step_interpret_model_instructions_before"] = ah.capture_vibe_model_snapshot(d, p, a)
    pre = orch._verify_requirement(_req(VIBES["A2"]), d, p, a)
    assert pre["status"] == "failed", pre
    assert "[verifier-domain-rename FIRED v5.1.4]" in pre["evidence"]
    after = _pc_model()
    assert ah._v410_deterministic_selffix(after, {"id": "A2", "text": VIBES["A2"]}, LOG)[0] is True
    post = orch._verify_requirement(_req(VIBES["A2"]), *_flat(after))
    assert post["status"] == "fulfilled", post


def test_r2_verifier_rules_only_on_names_that_were_domains_in_the_base_model():
    base = _pc_model()
    orch = _orch(base)
    live = _pc_model()
    for text in ("Treat `fraud_case` as a subdomain of `claims`.",
                 "Fold the `fraud_case` domain into `claims`.",
                 "RENAME the `claimz` domain to `claim`.",
                 "MOVE the following products FROM the `legacy` domain INTO the `underwriting` domain: submission, quote."):
        assert orch._verify_domain_structural_op(_req(text), *_flat(live)[:2]) is None, text
    assert orch._verify_domain_structural_op(_req(VIBES["A1"]), *_flat(live)[:2])["status"] == "failed"
    assert ah._v410_deterministic_selffix(live, {"id": "A2", "text": VIBES["A2"]}, LOG)[0] is True
    assert ah._v410_deterministic_selffix(live, {"id": "A1", "text": VIBES["A1"]}, LOG)[0] is True
    assert orch._verify_domain_structural_op(_req(VIBES["A1"]), *_flat(live)[:2])["status"] == "fulfilled"
    unquoted = "The claimfinancials domain is a SUBDOMAIN of claims."
    assert orch._verify_domain_structural_op(_req(unquoted), *_flat(live)[:2])["status"] == "partial"
    assert _orch({"business_context": "no model"})._verify_domain_structural_op(_req(VIBES["A2"]), *_flat(live)[:2]) is None


def test_bulk_move_verdict_is_failed_then_partial_then_fulfilled():
    base = _pc_model()
    orch = _orch(base)
    m = _pc_model()
    assert orch._verify_domain_structural_op(_req(VIBES["B1"]), *_flat(m)[:2])["status"] == "failed"
    ah._v337_apply_move_product(m["model"], "coverage", "submission", "underwriting")
    assert orch._verify_domain_structural_op(_req(VIBES["B1"]), *_flat(m)[:2])["status"] == "partial"
    assert ah._v410_deterministic_selffix(m, {"id": "B1", "text": VIBES["B1"]}, LOG)[0] is True
    verdict = orch._verify_domain_structural_op(_req(VIBES["B1"]), *_flat(m)[:2])
    assert verdict["status"] == "fulfilled" and "4/4" in verdict["evidence"]


def _scope(entries, mode="Some Domains"):
    fence = ah.build_vibe_scope_fence(ah.parse_vibe_scope(mode, entries), _pc_model(), VOV, LOG)
    ah.set_vibe_scope_runtime(fence)
    return fence


def test_r8_domain_ops_that_cross_the_scope_fence_are_refused(caplog):
    with caplog.at_level(logging.WARNING):
        for entries, mode, call in (
                ("claims", "Some Domains", lambda r: ah._v337_apply_rename_domain(r, "claims", "claim", LOG)),
                ("claims", "Some Domains", lambda r: ah._v337_apply_rename_domain(r, "policy", "policies", LOG)),
                ("claimfinancials", "Some Domains", lambda r: ah._v337_apply_merge_domain(r, "claimfinancials", "claims", LOG)),
                ("claimfinancials, claims", "Some Domains", lambda r: ah._v337_apply_merge_domain(r, "claimfinancials", "policy", LOG)),
                ("claims.core", "Some Subdomains", lambda r: ah._v337_apply_rename_domain(r, "claims", "claim", LOG))):
            _scope(entries, mode)
            m = _pc_model()
            before = copy.deepcopy(m)
            assert call(m["model"]) is None, entries
            assert m == before, entries
    assert sum("[v337-domain-op-fence FIRED v5.1.4]" in r.getMessage() for r in caplog.records) == 5
    _scope("claims")
    m = _pc_model()
    assert ah._v410_deterministic_selffix(m, {"id": "A2", "text": VIBES["A2"]}, LOG) == (None, "rename_domain_apply_failed")
    assert "claims" in _names(m)


def test_r8_in_scope_domain_ops_apply_and_call_the_domain_rename_ledger():
    ah.vov_ledger_reset()
    _scope("claims, claim, claimfinancials")
    base = _pc_model()
    m = copy.deepcopy(base)
    assert ah._v337_apply_rename_domain(m["model"], "claims", "claim", LOG).startswith("rename_domain claims->claim")
    assert ah._v337_apply_merge_domain(m["model"], "claimfinancials", "claim", LOG).startswith("merge_domain claimfinancials->claim")
    assert [(e["kind"], e["old"], e["new"]) for e in ah.vov_rename_events()] == [
        ("domain", "claims", "claim"), ("domain", "claimfinancials", "claim")]
    changes = ah.vov_entity_changes(base, m, {"operation": VOV})
    doms = {e["base_path"]: e for e in changes["entries"] if e["kind"] == "domain" and e.get("base_path")}
    assert (doms["claims"]["status"], doms["claims"]["path"]) == ("renamed", "claim")
    assert doms["claimfinancials"]["path"] == "claim"
    assert doms["claimfinancials"]["status"] in ("renamed", "merged")
    reserve = next(e for e in changes["entries"] if e["kind"] == "product" and e.get("base_path") == "claimfinancials.reserve")
    assert reserve["path"] == "claim.reserve" and reserve["status"] != "dropped"
    d, p, a, _mv = ah.model_to_widgets_flat(m, quiet=True)
    assert not [i for i in ah.run_metamodel_static_analysis(d, p, a, {}, LOG)["issues"]
                if i["category"] == "rename_leftover_original"]
    ah.vov_ledger_reset()


def test_r8_bulk_move_refuses_products_whose_move_crosses_the_fence():
    _scope("coverage")
    m = _pc_model()
    before = copy.deepcopy(m)
    assert ah._v410_deterministic_selffix(m, {"id": "B1", "text": VIBES["B1"]}, LOG) == (None, "bulk_move_apply_failed")
    assert m == before
    _scope("coverage, underwriting")
    ok, evidence = ah._v410_deterministic_selffix(m, {"id": "B1", "text": VIBES["B1"]}, LOG)
    assert ok is True and evidence.startswith("bulk_move 4/4")

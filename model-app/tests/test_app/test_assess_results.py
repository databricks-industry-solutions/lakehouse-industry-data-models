import io
import sys
import os
from pathlib import Path
from types import SimpleNamespace as NS

import pytest
from databricks.sdk.errors.platform import NotFound, PermissionDenied
from sqlmodel import Session

sys.path.insert(0, os.path.dirname(__file__))

from test_assess_ingest import FIX, OUT, _fixture_files, _seed_run, _ws_with  # noqa: E402
from vibe_modeling.backend.assessment.ingest import ingest_domain_run  # noqa: E402
from vibe_modeling.backend.db_models import AssessDomainRun  # noqa: E402

WHO = {"X-Forwarded-Email": "dana@example.com"}


@pytest.fixture(name="ingested")
def ingested_fixture(engine):
    dr_id, _, _ = _seed_run(engine)
    with Session(engine) as s:
        ingest_domain_run(s, _ws_with(_fixture_files()), s.get(AssessDomainRun, dr_id))
    return NS(dr_id=dr_id)


def _results(client, dr_id):
    r = client.get(f"/api/assessment-domain-runs/{dr_id}/results")
    assert r.status_code == 200, r.text
    return r.json()


def test_results_shape(client, ingested):
    r = _results(client, ingested.dr_id)
    assert r["grades"] == {"full": 0, "partial": 1, "blocked": 1}
    assert [e["name"] for e in r["entities"]] == ["credit_check", "order"]  # blocked first
    order = next(e for e in r["entities"] if e["name"] == "order")
    assert order["in_model"] is True and order["dup_source"] == 2 and order["deferred_fk"] == 1
    assert order["mapped"] + order["gap"] + order["deferred_fk"] <= len(order["columns"]) == 4
    targets = [c["target"] for c in order["columns"]]
    assert targets == sorted(targets)
    assert any(c["in_model"] for c in order["columns"])
    cc = next(e for e in r["entities"] if e["name"] == "credit_check")
    assert cc["in_model"] is False and cc["net_new_candidate"] is True and cc["columns"] == []
    assert r["pending_decisions"][0]["options"][1]["label"] == "defer"
    assert r["next_vibes"][0]["priority"] == 1
    assert len(r["gaps"]) == 1
    assert r["domain_run"]["id"] == ingested.dr_id


def test_answer_option_then_clear(client, ingested):
    dec = _results(client, ingested.dr_id)["pending_decisions"][0]
    opt = dec["options"][0]["id"]
    a = client.put(f"/api/assessment-decisions/{dec['id']}/answer", json={"option_id": opt}, headers=WHO).json()
    assert a["answer_status"] == "answered" and a["answer_option_id"] == opt
    assert a["answered_by"] == "dana@example.com" and a["answered_at"]
    assert len(a["options"]) == 3
    c = client.delete(f"/api/assessment-decisions/{dec['id']}/answer").json()
    assert c["answer_status"] == "open" and c["answer_option_id"] is None
    assert c["answer_text"] == "" and c["answered_by"] == "" and c["answered_at"] is None


def test_answered_by_is_actor_label_without_email(client, ingested):
    dec = _results(client, ingested.dr_id)["pending_decisions"][0]
    url = f"/api/assessment-decisions/{dec['id']}/answer"
    by_name = client.put(url, json={"text": "t"}, headers={"X-Forwarded-Preferred-Username": "dana"}).json()
    assert by_name["answered_by"] == "dana"
    assert client.put(url, json={"text": "t"}).json()["answered_by"] == "anonymous"


def test_answer_with_text_only(client, ingested):
    dec = _results(client, ingested.dr_id)["pending_decisions"][0]
    a = client.put(f"/api/assessment-decisions/{dec['id']}/answer", json={"text": "  use ERP  "}, headers=WHO).json()
    assert a["answer_status"] == "answered" and a["answer_text"] == "use ERP" and a["answer_option_id"] is None


def test_answer_needs_option_or_text(client, ingested):
    dec_id = _results(client, ingested.dr_id)["pending_decisions"][0]["id"]
    assert client.put(f"/api/assessment-decisions/{dec_id}/answer", json={}).status_code == 422
    assert client.put(f"/api/assessment-decisions/{dec_id}/answer", json={"text": "   "}).status_code == 422


def test_answer_with_foreign_option_is_422(client, engine, ingested):
    from vibe_modeling.backend.db_models import AssessDecisionOption, AssessPendingDecision
    dec_id = _results(client, ingested.dr_id)["pending_decisions"][0]["id"]
    with Session(engine) as s:
        other = AssessPendingDecision(domain_run_id=ingested.dr_id, question="q2")
        s.add(other); s.commit(); s.refresh(other)
        opt = AssessDecisionOption(decision_id=other.id, ordinal=0, label="x")
        s.add(opt); s.commit(); s.refresh(opt)
        opt_id = opt.id
    r = client.put(f"/api/assessment-decisions/{dec_id}/answer", json={"option_id": opt_id})
    assert r.status_code == 422 and "Option does not belong to this decision" in r.text
    assert client.put(f"/api/assessment-decisions/{dec_id}/answer", json={"option_id": "nope"}).status_code == 422


def test_unknown_ids_404(client):
    assert client.get("/api/assessment-domain-runs/nope/results").status_code == 404
    assert client.get("/api/assessment-domain-runs/nope/docs").status_code == 404
    assert client.put("/api/assessment-decisions/nope/answer", json={"text": "x"}).status_code == 404
    assert client.delete("/api/assessment-decisions/nope/answer").status_code == 404


def test_answer_survives_reingest_and_shows_in_results(client, engine, ingested):
    dec = _results(client, ingested.dr_id)["pending_decisions"][0]
    opt = dec["options"][1]["id"]
    client.put(f"/api/assessment-decisions/{dec['id']}/answer", json={"option_id": opt, "text": "later"}, headers=WHO)
    with Session(engine) as s:
        ingest_domain_run(s, _ws_with(_fixture_files()), s.get(AssessDomainRun, ingested.dr_id))
    after = _results(client, ingested.dr_id)["pending_decisions"][0]
    assert after["answer_status"] == "answered" and after["answer_text"] == "later"
    assert after["answered_by"] == "dana@example.com"
    assert after["options"][1]["label"] == "defer" and after["answer_option_id"] == after["options"][1]["id"]


def _f(path, is_dir=False):
    return NS(path=path, name=path.rsplit("/", 1)[-1], is_directory=is_dir)


def test_docs_listing_recurses_builds_urls_sorted(client, mock_ws, ingested):
    tree = {
        f"{OUT}/docs": [_f(f"{OUT}/docs/z.md"), _f(f"{OUT}/docs/design", True)],
        f"{OUT}/docs/design": [_f(f"{OUT}/docs/design/assessment.json")],
    }
    mock_ws.files.list_directory_contents.side_effect = lambda p: iter(tree[p])
    r = client.get(f"/api/assessment-domain-runs/{ingested.dr_id}/docs")
    assert r.status_code == 200
    body = r.json()
    docs = body["docs"]
    assert [d["path"] for d in docs] == [f"{OUT}/docs/design/assessment.json", f"{OUT}/docs/z.md"]
    assert docs[1]["name"] == "z.md" and docs[0]["category"] == "design"
    assert body["folder_url"].startswith(
        "https://test-workspace.databricks.com/explore/data/volumes/test_deployment_catalog/_metamodel/assess_runs?volumePath=/Volumes")
    assert body["folder_url"].endswith("/")


def test_docs_listing_caps_at_200(client, mock_ws, ingested):
    mock_ws.files.list_directory_contents.side_effect = lambda p: iter(
        [_f(f"{OUT}/docs/f{i:04d}.md") for i in range(250)])
    docs = client.get(f"/api/assessment-domain-runs/{ingested.dr_id}/docs").json()["docs"]
    assert len(docs) == 200 and docs[0]["name"] == "f0000.md"


def test_docs_missing_folder_is_empty(client, mock_ws, ingested):
    mock_ws.files.list_directory_contents.side_effect = NotFound("nope")
    r = client.get(f"/api/assessment-domain-runs/{ingested.dr_id}/docs")
    assert r.status_code == 200 and r.json()["docs"] == []


def test_docs_databricks_error_is_409_admin_help_sanitized(client, mock_ws, engine, ingested):
    with Session(engine) as s:
        dr = s.get(AssessDomainRun, ingested.dr_id)
        dr.job_id, dr.databricks_run_id, dr.job_reader = 99, 1000, "reader-1"
        s.add(dr); s.commit()
    token = "dapi" + "a" * 32
    mock_ws.files.list_directory_contents.side_effect = PermissionDenied(f"denied for dana@example.com {token}")
    r = client.get(f"/api/assessment-domain-runs/{ingested.dr_id}/docs")
    assert r.status_code == 409
    assert token not in r.text and "dana@example.com" not in r.text
    host = "https://test-workspace.databricks.com"
    detail = r.json()["detail"]
    assert detail.pop("message").startswith("Could not list run docs: denied for [REDACTED]")
    assert detail == {"error": "admin_help",
                      "job_url": f"{host}/jobs/99", "run_url": f"{host}/jobs/99/runs/1000",
                      "runs_path": OUT, "job_reader": "reader-1"}


# --- results-readability: summary, computed letters, decision detail, urgency ---

def _ingest_new(engine, mutate=None):
    from test_assess_ingest import _new_files
    dr_id, _, _ = _seed_run(engine)
    with Session(engine) as s:
        ingest_domain_run(s, _ws_with(_new_files(mutate)), s.get(AssessDomainRun, dr_id))
    return dr_id


def test_results_new_shape(client, engine):
    def full_gate(d):  # fixture entity is gated partial (=> C); make it Full so 45.2% enrichment grades B
        d["entities"][0]["grade"] = "full"
    r = _results(client, _ingest_new(engine, full_gate))
    assert r["letter_counts"] == {"A": 0, "B": 1, "C": 0, "D": 0, "F": 1}
    order = next(e for e in r["entities"] if e["name"] == "order")
    assert order["letter_grade"] == "B" and order["enrichment_pct"] == 45.2
    assert (order["core_sourced"], order["core_total"], order["enrichment_sourced"], order["enrichment_total"],
            order["deferred_fk_count"]) == (9, 9, 14, 31, 2)
    assert (order["grade_reason"], order["row_filter"]) == ("why", "type='E'")
    assert "deferred_fk" in [c["tier"] for c in order["columns"]]
    cc = next(e for e in r["entities"] if e["name"] == "credit_check")
    assert cc["letter_grade"] == "F" and cc["enrichment_pct"] is None
    dec = r["pending_decisions"][0]
    keep = next(o for o in dec["options"] if o["label"] == "Keep")
    assert keep["recommended"] is True and keep["pros"] == ["p"] and keep["cons"] == ["c"] and keep["impact"] == "i"
    assert [o["recommended"] for o in dec["options"]].count(True) == 1
    assert dec["affected"] == [{"entity": "bill", "column": ""}]
    assert dec["blocks_build"] is True and (dec["context"], dec["why_it_matters"]) == ("c", "w")
    assert dec["recommendation_rationale"] == "r"
    vibe = r["next_vibes"][0]
    assert vibe["urgency"] == "before_build" and vibe["affected_entities"] == ["bill"]
    assert (vibe["problem"], vibe["proposed_change"], vibe["impact_if_skipped"]) == ("p", "c", "i")
    assert r["summary"]["key_findings"] == ["k1"] and r["summary"]["top_risks"] == ["r1"]
    assert r["summary"]["verdict"] == "iterate_first" and r["summary"]["recommended_next_step"] == "s"


def test_results_blocking_decisions_sort_first(client, engine):
    def mut(d):
        d["pending_decisions"] = [
            {**d["pending_decisions"][0], "question": "plain", "blocks_build": False},
            {**d["pending_decisions"][0], "question": "blocking", "blocks_build": True}]
    r = _results(client, _ingest_new(engine, mut))
    assert [d["question"] for d in r["pending_decisions"]] == ["blocking", "plain"]


def test_results_old_run_falls_back(client, ingested):
    r = _results(client, ingested.dr_id)
    assert r["summary"] is None
    assert r["letter_counts"] == {"A": 0, "B": 0, "C": 0, "D": 0, "F": 1}
    order = next(e for e in r["entities"] if e["name"] == "order")
    assert order["letter_grade"] is None and order["enrichment_pct"] is None
    assert next(e for e in r["entities"] if e["name"] == "credit_check")["letter_grade"] == "F"
    dec = r["pending_decisions"][0]
    assert dec["affected"] == [] and dec["blocks_build"] is False
    assert all(o["recommended"] is False and o["pros"] == [] for o in dec["options"])
    assert r["next_vibes"][0]["affected_entities"] == [] and r["next_vibes"][0]["urgency"] == ""


def test_results_preserve_document_order(client, engine):
    def mut(d):
        base = d["pending_decisions"][0]
        d["pending_decisions"] = [
            {**base, "question": f"q{i}", "blocks_build": i == 2,
             "affected": [{"entity": f"e{i}{j}", "column": f"c{j}"} for j in range(3)]} for i in range(3)]
        d["pending_decisions"][0]["options"] = [{"label": "Keep", "pros": ["p1", "p2"], "cons": ["c1", "c2"]}, "Drop"]
        v = d["next_vibes"][0]
        d["next_vibes"] = [{**v, "priority": None, "text": f"v{i}", "affected_entities": ["z", "a", "m"]}
                           for i in range(3)]
    r = _results(client, _ingest_new(engine, mut))
    decs = r["pending_decisions"]
    assert [x["question"] for x in decs] == ["q2", "q0", "q1"]  # blocking first, then document order
    for x in decs:
        i = int(x["question"][1])
        assert [a["entity"] for a in x["affected"]] == [f"e{i}0", f"e{i}1", f"e{i}2"]
    keep = next(o for o in decs[1]["options"] if o["label"] == "Keep")
    assert keep["pros"] == ["p1", "p2"] and keep["cons"] == ["c1", "c2"]
    assert [v["text"] for v in r["next_vibes"]] == ["v0", "v1", "v2"]
    assert all(v["affected_entities"] == ["z", "a", "m"] for v in r["next_vibes"])


# --- structure axis ---

def _ents(r):
    return {e["name"]: e for e in r["entities"]}


def test_results_structure_rework_and_counts(client, engine):
    def mut(d):
        d["pending_decisions"][0].update(kind="structure", blocks_build=True, entity="order", gate="anything")
        d["next_vibes"][0].update(urgency="before_build", affected_entities=["credit_check"])
    r = _results(client, _ingest_new(engine, mut))
    ents = _ents(r)
    assert (ents["order"]["structure"], ents["order"]["structure_refs"]) == ("rework", ["D1"])
    assert (ents["credit_check"]["structure"], ents["credit_check"]["structure_refs"]) == ("review", ["Vibe 1"])
    assert r["structure_counts"] == {"sound": 0, "review": 1, "rework": 1}
    assert r["pending_decisions"][0]["kind"] == "structure"


def test_results_structure_answer_recomputes_without_rerun(client, engine):
    def mut(d):
        d["pending_decisions"][0].update(kind="structure", blocks_build=True, entity="order")
    dr_id = _ingest_new(engine, mut)
    dec = _results(client, dr_id)["pending_decisions"][0]
    assert client.put(f"/api/assessment-decisions/{dec['id']}/answer", json={"text": "ok"}).status_code == 200
    r = _results(client, dr_id)
    assert _ents(r)["order"]["structure"] == "sound" and r["structure_counts"]["rework"] == 0


def test_results_old_run_uses_gate_text_fallback_for_kind(client, ingested):
    r = _results(client, ingested.dr_id)
    dec = r["pending_decisions"][0]  # fixture gate "2C" -> structure, not blocking -> review for credit_check
    assert dec["kind"] == "structure"
    assert _ents(r)["credit_check"]["structure"] == "review"
    assert _ents(r)["credit_check"]["structure_refs"] == ["D1"]
    assert _ents(r)["order"]["structure"] == "sound" and _ents(r)["order"]["structure_refs"] == []
    assert r["structure_counts"] == {"sound": 1, "review": 1, "rework": 0}


def test_results_profiles_by_source_populated_and_ordered(client, engine):
    """Verify profiles_by_source is populated in results API for multi-source columns."""
    import json
    dr_id, _, _ = _seed_run(engine)
    doc = json.loads((FIX / "assessment.json").read_text())
    # Add profiles to first column
    doc["entities"][0]["columns"][0]["profiles_by_source"] = [
        {"system": "sap_sd", "source_table": "vbak", "source_column": "vbeln", "role": "populates",
         "rows": 1200, "null_pct": 0.0},
        {"system": "erp_alt", "source_table": "erp.vbak", "source_column": "doc_id", "role": "populates",
         "rows": 1100, "null_pct": 1.5}
    ]
    # Leave second column without profiles
    files = _fixture_files()
    files[f"{OUT}/docs/design/assessment.json"] = json.dumps(doc).encode()
    with Session(engine) as s:
        ingest_domain_run(s, _ws_with(files), s.get(AssessDomainRun, dr_id))

    r = _results(client, dr_id)
    order = next(e for e in r["entities"] if e["name"] == "order")
    num_col = next(c for c in order["columns"] if c["target"] == "number")
    req_col = next(c for c in order["columns"] if c["target"] == "requested_delivery_date")

    # First column should have 2 profiles in order
    assert len(num_col["profiles_by_source"]) == 2
    assert num_col["profiles_by_source"][0]["system"] == "sap_sd" and num_col["profiles_by_source"][0]["row_count"] == 1200
    assert num_col["profiles_by_source"][1]["system"] == "erp_alt" and num_col["profiles_by_source"][1]["row_count"] == 1100

    # Second column should have empty profiles_by_source
    assert req_col["profiles_by_source"] == []

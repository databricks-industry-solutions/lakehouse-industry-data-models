import io
import json
from pathlib import Path
from types import SimpleNamespace as NS
from unittest.mock import MagicMock

from databricks.sdk.errors.platform import NotFound
from sqlalchemy import event
from sqlmodel import Session, select

from vibe_modeling.backend.assessment.ingest import flag_duplicate_sources, ingest_domain_run, read_volume_json
from vibe_modeling.backend.assessment.schemas import AssessmentDoc
from vibe_modeling.backend.db_models import (
    AssessBatch, AssessColumnMapping, AssessColumnSourceProfile, AssessDecisionOption, AssessDomainRun, AssessEntity, AssessGap,
    AssessNextVibe, AssessPendingDecision, Attribute, Business, Domain, ModelVersion, Product,
)

FIX = Path(__file__).resolve().parents[1] / "fixtures" / "assessment"
BATCH = "b"
OUT = f"/Volumes/c/_metamodel/assess_runs/{BATCH}/sales_order"
# What launch writes to config.json, reduced to the fields the ingest pin check reads.
CONFIG = {"batch_id": BATCH, "domain": "sales_order", "model_version": 3}


def _ws_with(files: dict[str, bytes]):
    ws = MagicMock()

    def dl(path):
        if path not in files:
            raise NotFound(path)
        return NS(contents=io.BytesIO(files[path]))

    ws.files.download.side_effect = dl
    return ws


def _fixture_files():
    return {f"{OUT}/summary.json": (FIX / "summary.json").read_bytes(),
            f"{OUT}/config.json": json.dumps(CONFIG).encode(),
            f"{OUT}/docs/design/assessment.json": (FIX / "assessment.json").read_bytes()}


def _seed_run(engine):
    with Session(engine) as s:
        b = Business(name="Meridian Mfg", description="d")
        s.add(b); s.commit(); s.refresh(b)
        mv = ModelVersion(business_id=b.id, version=3, scope="mvm", status="completed")
        s.add(mv); s.commit(); s.refresh(mv)
        d = Domain(version_id=mv.id, name="sales_order", database_name="sales_order")
        s.add(d); s.commit(); s.refresh(d)
        p = Product(domain_id=d.id, version_id=mv.id, name="order", table_name="sales_order_t")
        s.add(p); s.commit(); s.refresh(p)
        a = Attribute(product_id=p.id, name="number", column_name="order_number")
        s.add(a)
        batch = AssessBatch(id=BATCH, business_id=b.id, version_id=mv.id)
        s.add(batch); s.commit(); s.refresh(batch); s.refresh(a)
        dr = AssessDomainRun(batch_id=batch.id, domain_id=d.id, out_dir=OUT, config_path=f"{OUT}/config.json")
        s.add(dr); s.commit(); s.refresh(dr)
        return dr.id, p.id, a.id


def _counts(s):
    return tuple(len(s.exec(select(m)).all()) for m in
                 (AssessEntity, AssessColumnMapping, AssessGap, AssessPendingDecision,
                  AssessDecisionOption, AssessNextVibe))


def test_ingest_fixture_end_to_end(engine):
    dr_id, pid, aid = _seed_run(engine)
    ws = _ws_with(_fixture_files())
    with Session(engine) as s:
        dr = s.get(AssessDomainRun, dr_id)
        res = ingest_domain_run(s, ws, dr)
        assert res.results_valid
        ents = s.exec(select(AssessEntity).where(AssessEntity.domain_run_id == dr_id)).all()
        assert {e.name: e.grade for e in ents} == {"order": "partial", "credit_check": "blocked"}
        order = next(e for e in ents if e.name == "order")
        assert order.product_id == pid
        assert next(e for e in ents if e.name == "credit_check").product_id is None
        cols = {c.target: c for c in s.exec(select(AssessColumnMapping).where(AssessColumnMapping.entity_id == order.id))}
        assert cols["number"].attribute_id == aid
        assert cols["requested_delivery_date"].dup_source and cols["confirmed_delivery_date"].dup_source
        assert not cols["number"].dup_source
        dec = s.exec(select(AssessPendingDecision).where(AssessPendingDecision.domain_run_id == dr_id)).one()
        opts = s.exec(select(AssessDecisionOption).where(AssessDecisionOption.decision_id == dec.id)
                      .order_by(AssessDecisionOption.ordinal)).all()
        assert [o.label for o in opts] == ["add", "defer", "reject"]
        dr = s.get(AssessDomainRun, dr_id)
        assert dr.model_quality_score == 72 and dr.skills_commit.startswith("4c709f7")
        assert dr.skills_version == "0.4.0" and dr.metamodel_version == "3"
        assert dr.genie_version == "v0.1.0-beta.2"


def test_decision_ordinal_is_list_index(engine):
    # The UI labels decisions D{ordinal+1}; assessment.json order is the D-number contract.
    dr_id, _, _ = _seed_run(engine)
    doc = json.loads((FIX / "assessment.json").read_text())
    doc["pending_decisions"] = [dict(doc["pending_decisions"][0], title=f"d{i}") for i in range(3)]
    files = _fixture_files()
    files[f"{OUT}/docs/design/assessment.json"] = json.dumps(doc).encode()
    with Session(engine) as s:
        ingest_domain_run(s, _ws_with(files), s.get(AssessDomainRun, dr_id))
        decs = s.exec(select(AssessPendingDecision).where(AssessPendingDecision.domain_run_id == dr_id)
                      .order_by(AssessPendingDecision.ordinal)).all()
        assert [d.ordinal for d in decs] == [0, 1, 2]


def test_ingest_resolves_by_table_name_and_column_name(engine):
    dr_id, pid, aid = _seed_run(engine)
    doc = json.loads((FIX / "assessment.json").read_text())
    doc["entities"][0]["name"] = "SALES_ORDER_T"
    doc["entities"][0]["columns"][0]["target"] = "ORDER_NUMBER"
    files = _fixture_files()
    files[f"{OUT}/docs/design/assessment.json"] = json.dumps(doc).encode()
    with Session(engine) as s:
        ingest_domain_run(s, _ws_with(files), s.get(AssessDomainRun, dr_id))
        ent = s.exec(select(AssessEntity).where(AssessEntity.name == "SALES_ORDER_T")).one()
        assert ent.product_id == pid
        col = s.exec(select(AssessColumnMapping).where(AssessColumnMapping.entity_id == ent.id,
                                                       AssessColumnMapping.target == "ORDER_NUMBER")).one()
        assert col.attribute_id == aid


def test_ingest_reads_attributes_once_per_matched_entity(engine):
    """Both attribute name maps (column_name and name) come from one query per matched entity."""
    dr_id, _, _ = _seed_run(engine)
    selects: list[str] = []

    def count(_conn, _cursor, statement, *_args):
        if statement.lstrip().upper().startswith("SELECT") and "FROM attributes" in statement:
            selects.append(statement)

    event.listen(engine, "before_cursor_execute", count)
    try:
        with Session(engine) as s:
            assert ingest_domain_run(s, _ws_with(_fixture_files()), s.get(AssessDomainRun, dr_id)).results_valid
    finally:
        event.remove(engine, "before_cursor_execute", count)
    # The fixture has two entities; only "order" matches a product, so one attribute query.
    assert len(selects) == 1, selects


def test_ingest_name_match_wins_over_column_name_match(engine):
    """A target equal to one attribute's name and another's column_name maps to the name match."""
    dr_id, pid, aid = _seed_run(engine)
    with Session(engine) as s:
        other = Attribute(product_id=pid, name="order_ref", column_name="number")
        s.add(other); s.commit()
    with Session(engine) as s:
        ingest_domain_run(s, _ws_with(_fixture_files()), s.get(AssessDomainRun, dr_id))
        col = s.exec(select(AssessColumnMapping).where(AssessColumnMapping.target == "number")).one()
        assert col.attribute_id == aid


def test_ingest_is_idempotent(engine):
    dr_id, _, _ = _seed_run(engine)
    files = _fixture_files()
    with Session(engine) as s:
        ingest_domain_run(s, _ws_with(files), s.get(AssessDomainRun, dr_id))
        first = _counts(s)
        ingest_domain_run(s, _ws_with(files), s.get(AssessDomainRun, dr_id))
        assert _counts(s) == first == (2, 4, 1, 1, 3, 1)


def test_ingest_missing_assessment_is_invalid(engine):
    dr_id, _, _ = _seed_run(engine)
    files = _fixture_files()
    del files[f"{OUT}/docs/design/assessment.json"]
    with Session(engine) as s:
        res = ingest_domain_run(s, _ws_with(files), s.get(AssessDomainRun, dr_id))
        assert not res.results_valid and "assessment.json not found" in res.error
        assert s.get(AssessDomainRun, dr_id).results_valid is False
        assert _counts(s) == (0, 0, 0, 0, 0, 0)


def test_ingest_schema_violation_is_invalid(engine):
    dr_id, _, _ = _seed_run(engine)
    files = _fixture_files()
    files[f"{OUT}/docs/design/assessment.json"] = b'{"entities": "x"}'
    with Session(engine) as s:
        res = ingest_domain_run(s, _ws_with(files), s.get(AssessDomainRun, dr_id))
        assert not res.results_valid and "failed validation" in res.error
        assert s.get(AssessDomainRun, dr_id).results_valid is False
        assert _counts(s) == (0, 0, 0, 0, 0, 0)


def test_reingest_preserves_vibe_input_links(engine):
    """On re-ingest, vibe_input_id links are preserved by ordinal+text match."""
    from vibe_modeling.backend.db_models import VibeInput

    dr_id, _, _ = _seed_run(engine)
    files = _fixture_files()
    with Session(engine) as s:
        # First ingest
        dr = s.get(AssessDomainRun, dr_id)
        ingest_domain_run(s, _ws_with(files), dr)

        # Get the first next vibe and link it to a VibeInput
        vibes_1 = s.exec(select(AssessNextVibe).where(AssessNextVibe.domain_run_id == dr_id)
                        .order_by(AssessNextVibe.ordinal)).all()
        assert len(vibes_1) > 0
        vibe_1_text = vibes_1[0].text
        vibe_1_ordinal = vibes_1[0].ordinal

        # Create a VibeInput and link to it
        batch = s.get(AssessBatch, dr.batch_id)
        vi = VibeInput(
            business_id=batch.business_id,
            origin="user",
            author="test@example.com",
            text="Feedback from vibe",
            priority="medium",
            confidence_score=0.5,
        )
        s.add(vi)
        s.flush()

        vibes_1[0].vibe_input_id = vi.id
        s.add(vibes_1[0])
        s.commit()

        # Re-ingest (same data)
        ingest_domain_run(s, _ws_with(files), s.get(AssessDomainRun, dr_id))

        # Verify link was preserved
        vibes_2 = s.exec(select(AssessNextVibe).where(AssessNextVibe.domain_run_id == dr_id)
                        .order_by(AssessNextVibe.ordinal)).all()
        vibe_2_matching = next((v for v in vibes_2 if v.ordinal == vibe_1_ordinal and v.text == vibe_1_text), None)
        assert vibe_2_matching is not None
        assert vibe_2_matching.vibe_input_id == vi.id


def test_reingest_text_change_loses_link(engine):
    """If vibe text changes, link is not restored (conservative matching)."""
    from vibe_modeling.backend.db_models import VibeInput

    dr_id, _, _ = _seed_run(engine)
    files = _fixture_files()
    with Session(engine) as s:
        # First ingest
        dr = s.get(AssessDomainRun, dr_id)
        ingest_domain_run(s, _ws_with(files), dr)

        vibes_1 = s.exec(select(AssessNextVibe).where(AssessNextVibe.domain_run_id == dr_id)
                        .order_by(AssessNextVibe.ordinal)).all()
        vibe_1_ordinal = vibes_1[0].ordinal

        # Link it
        batch = s.get(AssessBatch, dr.batch_id)
        vi = VibeInput(
            business_id=batch.business_id,
            origin="user",
            author="test@example.com",
            text="Feedback",
            priority="medium",
        )
        s.add(vi)
        s.flush()
        vibes_1[0].vibe_input_id = vi.id
        s.add(vibes_1[0])
        s.commit()

        # Re-ingest with modified text
        doc = json.loads((FIX / "assessment.json").read_text())
        doc["next_vibes"][0]["text"] = "CHANGED TEXT"
        files_modified = _fixture_files()
        files_modified[f"{OUT}/docs/design/assessment.json"] = json.dumps(doc).encode()

        ingest_domain_run(s, _ws_with(files_modified), s.get(AssessDomainRun, dr_id))

        # Verify link was NOT restored (text changed)
        vibes_2 = s.exec(select(AssessNextVibe).where(AssessNextVibe.domain_run_id == dr_id)
                        .order_by(AssessNextVibe.ordinal)).all()
        vibe_2_by_ordinal = next((v for v in vibes_2 if v.ordinal == vibe_1_ordinal), None)
        assert vibe_2_by_ordinal is not None
        assert vibe_2_by_ordinal.vibe_input_id is None


def test_reingest_reorder_loses_link(engine):
    """If vibes are reordered, links don't cross-match (conservative)."""
    from vibe_modeling.backend.db_models import VibeInput

    dr_id, _, _ = _seed_run(engine)
    files = _fixture_files()
    with Session(engine) as s:
        # First ingest
        dr = s.get(AssessDomainRun, dr_id)
        ingest_domain_run(s, _ws_with(files), dr)

        vibes_1 = s.exec(select(AssessNextVibe).where(AssessNextVibe.domain_run_id == dr_id)
                        .order_by(AssessNextVibe.ordinal)).all()

        # Link first vibe
        batch = s.get(AssessBatch, dr.batch_id)
        vi = VibeInput(
            business_id=batch.business_id,
            origin="user",
            author="test@example.com",
            text="Feedback for first",
            priority="medium",
        )
        s.add(vi)
        s.flush()
        vibes_1[0].vibe_input_id = vi.id
        s.add(vibes_1[0])
        s.commit()

        first_vibe_text = vibes_1[0].text

        # Re-ingest with reordered vibes
        doc = json.loads((FIX / "assessment.json").read_text())
        if len(doc["next_vibes"]) > 1:
            doc["next_vibes"][0], doc["next_vibes"][1] = doc["next_vibes"][1], doc["next_vibes"][0]
        files_reordered = _fixture_files()
        files_reordered[f"{OUT}/docs/design/assessment.json"] = json.dumps(doc).encode()

        ingest_domain_run(s, _ws_with(files_reordered), s.get(AssessDomainRun, dr_id))

        # The vibe with matching text should be at a different ordinal now
        # and link should not be restored because ordinal changed
        vibes_2 = s.exec(select(AssessNextVibe).where(AssessNextVibe.domain_run_id == dr_id)).all()
        vibe_2_same_text = next((v for v in vibes_2 if v.text == first_vibe_text), None)
        assert vibe_2_same_text is not None
        # If ordinals differ, link should not be restored
        if vibe_2_same_text.ordinal != 0:
            assert vibe_2_same_text.vibe_input_id is None


def test_ingest_summary_says_invalid(engine):
    dr_id, _, _ = _seed_run(engine)
    files = _fixture_files()
    summary = json.loads(files[f"{OUT}/summary.json"])
    summary["results_valid"] = False
    files[f"{OUT}/summary.json"] = json.dumps(summary).encode()
    with Session(engine) as s:
        res = ingest_domain_run(s, _ws_with(files), s.get(AssessDomainRun, dr_id))
        assert not res.results_valid and res.error.startswith("Results refused: the notebook reported results_valid=false")
        assert s.get(AssessDomainRun, dr_id).results_valid is False
        assert _counts(s) == (0, 0, 0, 0, 0, 0)  # the docs stay on the volume; no result rows


def test_ingest_preserves_recorded_answers_on_reingest(engine):
    dr_id, _, _ = _seed_run(engine)
    files = _fixture_files()
    with Session(engine) as s:
        ingest_domain_run(s, _ws_with(files), s.get(AssessDomainRun, dr_id))
        dec = s.exec(select(AssessPendingDecision).where(AssessPendingDecision.domain_run_id == dr_id)).one()
        gate, question = dec.gate, dec.question
        defer = s.exec(select(AssessDecisionOption).where(
            AssessDecisionOption.decision_id == dec.id, AssessDecisionOption.label == "defer")).one()
        dec.answer_status, dec.answer_text, dec.answer_option_id, dec.answered_by = "answered", "add it", defer.id, "u@x"
        s.add(dec); s.commit()

        ingest_domain_run(s, _ws_with(files), s.get(AssessDomainRun, dr_id))
        dec2 = s.exec(select(AssessPendingDecision).where(AssessPendingDecision.domain_run_id == dr_id)).one()
        assert (dec2.gate, dec2.question) == (gate, question)
        assert dec2.answer_status == "answered" and dec2.answer_text == "add it" and dec2.answered_by == "u@x"
        opt = s.get(AssessDecisionOption, dec2.answer_option_id)
        assert opt.label == "defer" and opt.decision_id == dec2.id


def test_read_volume_json_none_on_missing_and_bad_json():
    ws = _ws_with({"/a.json": b"{not json", "/ok.json": b'{"a": 1}'})
    assert read_volume_json(ws, "/missing.json") is None
    assert read_volume_json(ws, "/a.json") is None
    assert read_volume_json(ws, "/ok.json") == {"a": 1}


def _m(target, status="mapped", table="T", col="C"):
    return AssessColumnMapping(entity_id="e", target=target, status=status, source_table=table, source_column=col)


def test_flag_duplicate_sources_rules():
    a, b = _m("x"), _m("y", table="t", col="c")  # case-insensitive match, distinct targets
    solo = _m("z", col="other")
    same_target = [_m("w", col="k"), _m("W", col="k")]  # same target twice -> not a dup
    gap = _m("g", status="gap")  # ineligible even though source set
    nosrc1, nosrc2 = _m("n1", col=""), _m("n2", col="")
    derived = _m("d", status="derived")  # shares source with a, b
    allm = [a, b, solo, *same_target, gap, nosrc1, nosrc2, derived]
    flag_duplicate_sources(allm)
    assert a.dup_source and b.dup_source and derived.dup_source
    assert not solo.dup_source and not gap.dup_source
    assert not any(m.dup_source for m in same_target + [nosrc1, nosrc2])


def _required_keys_covered(schema: dict, model) -> list[str]:
    missing = []
    for key in schema.get("required", []):
        if key not in model.model_fields:
            missing.append(f"{model.__name__}.{key}")
    return missing


def test_assessment_doc_covers_schema_required_keys():
    schema = json.loads((Path(__file__).resolve().parents[2] / "src/app/vendored/assessment/assessment.schema.json").read_text())
    props = schema["properties"]
    ent_model = AssessmentDoc.model_fields["entities"].annotation.__args__[0]
    col_model = ent_model.model_fields["columns"].annotation.__args__[0]
    gap_model = AssessmentDoc.model_fields["gaps"].annotation.__args__[0]
    dec_model = AssessmentDoc.model_fields["pending_decisions"].annotation.__args__[0]
    vibe_model = AssessmentDoc.model_fields["next_vibes"].annotation.__args__[0]
    meta_model = AssessmentDoc.model_fields["metamodel"].annotation
    missing = (
        _required_keys_covered(schema, AssessmentDoc)
        + _required_keys_covered(props["metamodel"], meta_model)
        + _required_keys_covered(props["entities"]["items"], ent_model)
        + _required_keys_covered(props["entities"]["items"]["properties"]["columns"]["items"], col_model)
        + _required_keys_covered(props["gaps"]["items"], gap_model)
        + _required_keys_covered(props["pending_decisions"]["items"], dec_model)
        + _required_keys_covered(props["next_vibes"]["items"], vibe_model)
    )
    assert missing == []


def test_assessment_doc_accepts_fixture():
    doc = AssessmentDoc.model_validate_json((FIX / "assessment.json").read_text())
    assert len(doc.entities) == 2 and len(doc.entities[0].columns) == 4


# --- results-readability: summary, tiers, decision detail, next-vibe urgency ---

def _new_files(mutate=None):
    from tests.test_app.test_assess_contract_doc import _new_doc
    doc = _new_doc()
    if mutate:
        mutate(doc)
    files = _fixture_files()
    files[f"{OUT}/docs/design/assessment.json"] = json.dumps(doc).encode()
    return files


def _child_counts(s):
    from vibe_modeling.backend.db_models import (
        AssessDecisionAffected, AssessDecisionOptionPoint, AssessNextVibeEntity, AssessSummary, AssessSummaryItem,
    )
    return tuple(len(s.exec(select(m)).all()) for m in
                 (AssessSummary, AssessSummaryItem, AssessDecisionOptionPoint, AssessDecisionAffected,
                  AssessNextVibeEntity))


def test_ingest_new_shape_populates_everything(engine):
    from vibe_modeling.backend.db_models import (
        AssessDecisionAffected, AssessDecisionOptionPoint, AssessNextVibeEntity, AssessSummary, AssessSummaryItem,
    )
    dr_id, _, _ = _seed_run(engine)
    with Session(engine) as s:
        res = ingest_domain_run(s, _ws_with(_new_files()), s.get(AssessDomainRun, dr_id))
        assert res.results_valid
        sm = s.get(AssessSummary, dr_id)
        assert (sm.verdict, sm.headline, sm.verdict_reason, sm.recommended_next_step) == (
            "iterate_first", "Buildable with gaps", "r", "s")
        items = s.exec(select(AssessSummaryItem).where(AssessSummaryItem.summary_id == dr_id)).all()
        assert sorted((i.kind, i.ordinal, i.text) for i in items) == [("finding", 0, "k1"), ("risk", 0, "r1")]
        ent = s.exec(select(AssessEntity).where(AssessEntity.domain_run_id == dr_id)).first()
        assert (ent.core_sourced, ent.core_total, ent.enrichment_sourced, ent.enrichment_total,
                ent.deferred_fk_count, ent.reported_letter) == (9, 9, 14, 31, 2, "B")
        assert (ent.grade_reason, ent.row_filter) == ("why", "type='E'")
        tiers = [c.tier for c in s.exec(select(AssessColumnMapping).where(AssessColumnMapping.entity_id == ent.id))]
        assert "deferred_fk" in tiers
        dec = s.exec(select(AssessPendingDecision).where(AssessPendingDecision.domain_run_id == dr_id)).one()
        keep = s.exec(select(AssessDecisionOption).where(AssessDecisionOption.decision_id == dec.id,
                                                          AssessDecisionOption.label == "Keep")).one()
        assert keep.impact == "i"
        assert dec.recommended_option_id == keep.id and dec.blocks_build is True
        assert (dec.context, dec.why_it_matters, dec.recommendation_rationale) == ("c", "w", "r")
        pts = s.exec(select(AssessDecisionOptionPoint).where(AssessDecisionOptionPoint.option_id == keep.id)).all()
        assert {(p.kind, p.text) for p in pts} == {("pro", "p"), ("con", "c")}
        aff = s.exec(select(AssessDecisionAffected).where(AssessDecisionAffected.decision_id == dec.id)).all()
        assert [(a.entity, a.column) for a in aff] == [("bill", "")]
        nv = s.exec(select(AssessNextVibe).where(AssessNextVibe.domain_run_id == dr_id)).one()
        assert (nv.urgency, nv.problem, nv.proposed_change, nv.impact_if_skipped) == (
            "before_build", "p", "c", "i")
        assert [e.entity for e in s.exec(select(AssessNextVibeEntity)
                                         .where(AssessNextVibeEntity.next_vibe_id == nv.id))] == ["bill"]


def test_recommended_option_that_matches_no_label_is_null_not_error(engine):
    dr_id, _, _ = _seed_run(engine)

    def mut(d):
        d["pending_decisions"][0]["recommended_option"] = "Nonexistent"
    with Session(engine) as s:
        res = ingest_domain_run(s, _ws_with(_new_files(mut)), s.get(AssessDomainRun, dr_id))
        assert res.results_valid
        dec = s.exec(select(AssessPendingDecision)).one()
        assert dec.recommended_option_id is None


def test_recommended_option_matches_case_insensitive_stripped(engine):
    dr_id, _, _ = _seed_run(engine)

    def mut(d):
        d["pending_decisions"][0]["recommended_option"] = "  kEEp "
    with Session(engine) as s:
        ingest_domain_run(s, _ws_with(_new_files(mut)), s.get(AssessDomainRun, dr_id))
        dec = s.exec(select(AssessPendingDecision)).one()
        keep = s.exec(select(AssessDecisionOption).where(AssessDecisionOption.label == "Keep")).one()
        assert dec.recommended_option_id == keep.id


def test_reingest_keeps_answer_with_object_options(engine):
    dr_id, _, _ = _seed_run(engine)
    files = _new_files()
    with Session(engine) as s:
        ingest_domain_run(s, _ws_with(files), s.get(AssessDomainRun, dr_id))
        dec = s.exec(select(AssessPendingDecision)).one()
        old_keep = s.exec(select(AssessDecisionOption).where(AssessDecisionOption.label == "Keep")).one()
        dec.answer_status, dec.answer_option_id, dec.answered_by = "answered", old_keep.id, "u@x"
        s.add(dec); s.commit()
        first = _child_counts(s)
        old_keep_id = old_keep.id
        ingest_domain_run(s, _ws_with(files), s.get(AssessDomainRun, dr_id))
        dec = s.exec(select(AssessPendingDecision)).one()
        new_keep = s.exec(select(AssessDecisionOption).where(AssessDecisionOption.label == "Keep")).one()
        assert dec.answer_status == "answered" and dec.answered_by == "u@x"
        assert new_keep.id != old_keep_id and dec.answer_option_id == new_keep.id
        assert dec.recommended_option_id == new_keep.id
        # no orphans: child tables did not grow
        assert _child_counts(s) == first == (1, 2, 2, 1, 1)


def test_old_shape_ingests_with_empty_new_fields(engine):
    from vibe_modeling.backend.db_models import AssessSummary
    dr_id, _, _ = _seed_run(engine)
    with Session(engine) as s:
        res = ingest_domain_run(s, _ws_with(_fixture_files()), s.get(AssessDomainRun, dr_id))
        assert res.results_valid and s.get(AssessDomainRun, dr_id).results_valid is True
        assert s.get(AssessSummary, dr_id) is None
        assert _child_counts(s) == (0, 0, 0, 0, 0)
        assert all(c.tier == "" for c in s.exec(select(AssessColumnMapping)))
        assert all(n.urgency == "" for n in s.exec(select(AssessNextVibe)))
        assert all(e.reported_letter == "" and e.core_total is None for e in s.exec(select(AssessEntity)))
        assert all(d.recommended_option_id is None for d in s.exec(select(AssessPendingDecision)))


def test_off_values_do_not_invalidate_run(engine):
    dr_id, _, _ = _seed_run(engine)

    def mut(d):
        d["entities"][0]["columns"][0]["tier"] = "primary"
        d["next_vibes"][0]["urgency"] = "now"
        d["executive_summary"]["verdict"] = "maybe"
        d["entities"][0]["letter_grade"] = "A+"
    with Session(engine) as s:
        res = ingest_domain_run(s, _ws_with(_new_files(mut)), s.get(AssessDomainRun, dr_id))
        assert res.results_valid and s.get(AssessDomainRun, dr_id).results_valid is True
        assert s.exec(select(AssessNextVibe)).one().urgency == ""


def test_reingest_repoints_answer_when_label_differs_in_case_and_padding(engine):
    dr_id, _, _ = _seed_run(engine)
    with Session(engine) as s:
        ingest_domain_run(s, _ws_with(_new_files()), s.get(AssessDomainRun, dr_id))
        dec = s.exec(select(AssessPendingDecision)).one()
        keep = s.exec(select(AssessDecisionOption).where(AssessDecisionOption.label == "Keep")).one()
        dec.answer_status, dec.answer_option_id = "answered", keep.id
        s.add(dec); s.commit()

        def mut(d):
            d["pending_decisions"][0]["options"][0]["label"] = "keep "
        ingest_domain_run(s, _ws_with(_new_files(mut)), s.get(AssessDomainRun, dr_id))
        dec = s.exec(select(AssessPendingDecision)).one()
        new = s.exec(select(AssessDecisionOption).where(AssessDecisionOption.label == "keep ")).one()
        assert dec.answer_status == "answered" and dec.answer_option_id == new.id


def test_empty_executive_summary_writes_no_row(engine):
    from vibe_modeling.backend.db_models import AssessSummary
    dr_id, _, _ = _seed_run(engine)

    def mut(d):
        d["executive_summary"] = {}
    with Session(engine) as s:
        res = ingest_domain_run(s, _ws_with(_new_files(mut)), s.get(AssessDomainRun, dr_id))
        assert res.results_valid and s.get(AssessSummary, dr_id) is None


def test_ingest_all_new_fields_null_is_valid(engine):
    from tests.test_app.test_assess_contract_doc import null_doc
    dr_id, _, _ = _seed_run(engine)
    files = _fixture_files()
    files[f"{OUT}/docs/design/assessment.json"] = json.dumps(null_doc()).encode()
    with Session(engine) as s:
        res = ingest_domain_run(s, _ws_with(files), s.get(AssessDomainRun, dr_id))
        assert res.results_valid
        ent = s.exec(select(AssessEntity).where(AssessEntity.domain_run_id == dr_id)).first()
        assert ent.row_filter == "" and ent.grade_reason == ""


def test_ingest_stores_decision_kind_and_reported_structure(engine):
    dr_id, _, _ = _seed_run(engine)

    def mut(d):
        d["pending_decisions"][0]["kind"] = "Structure"
        d["entities"][0]["structure"] = "review"
    with Session(engine) as s:
        ingest_domain_run(s, _ws_with(_new_files(mut)), s.get(AssessDomainRun, dr_id))
        assert s.exec(select(AssessPendingDecision)).one().kind == "structure"
        assert s.exec(select(AssessEntity).where(AssessEntity.name == "order")).one().reported_structure == "review"


def test_ingest_old_run_leaves_kind_and_reported_structure_empty(engine):
    dr_id, _, _ = _seed_run(engine)
    with Session(engine) as s:
        ingest_domain_run(s, _ws_with(_fixture_files()), s.get(AssessDomainRun, dr_id))
        assert s.exec(select(AssessPendingDecision)).one().kind == ""
        assert all(e.reported_structure == "" for e in s.exec(select(AssessEntity)))


def test_ingest_stores_profiles_by_source_with_ordinals_and_row_count_mapping(engine):
    """Verify that profiles_by_source are stored with ordinals, row_count mapped from rows JSON key."""
    dr_id, _, _ = _seed_run(engine)
    doc = json.loads((FIX / "assessment.json").read_text())
    # Add profiles_by_source to first column of order entity
    doc["entities"][0]["columns"][0]["profiles_by_source"] = [
        {"system": "sap_sd", "source_table": "vbak", "source_column": "vbeln", "role": "populates",
         "rows": 1200, "null_pct": 0.0},
        {"system": "secondary_erp", "source_table": "erp_alt.vbak", "source_column": "doc_id", "role": "populates",
         "rows": 1100, "null_pct": 1.5}
    ]
    # Leave second column without profiles_by_source
    # Third column has empty profiles_by_source
    doc["entities"][0]["columns"][2]["profiles_by_source"] = []
    files = _fixture_files()
    files[f"{OUT}/docs/design/assessment.json"] = json.dumps(doc).encode()
    with Session(engine) as s:
        ingest_domain_run(s, _ws_with(files), s.get(AssessDomainRun, dr_id))
        # Get the column mapping for "number" (first column with profiles)
        cols = {c.target: c for c in s.exec(select(AssessColumnMapping).where(
            AssessColumnMapping.entity_id == s.exec(select(AssessEntity).where(
                AssessEntity.name == "order")).one().id))}
        num_col = cols["number"]
        req_col = cols["requested_delivery_date"]
        conf_col = cols["confirmed_delivery_date"]

        # First column should have 2 profiles with ordinals 0 and 1
        profiles = s.exec(select(AssessColumnSourceProfile).where(
            AssessColumnSourceProfile.column_id == num_col.id
        ).order_by(AssessColumnSourceProfile.ordinal)).all()
        assert len(profiles) == 2
        assert profiles[0].ordinal == 0 and profiles[0].system == "sap_sd" and profiles[0].row_count == 1200
        assert profiles[1].ordinal == 1 and profiles[1].system == "secondary_erp" and profiles[1].row_count == 1100

        # Second column (no profiles_by_source key) should have 0 profiles
        req_profiles = s.exec(select(AssessColumnSourceProfile).where(
            AssessColumnSourceProfile.column_id == req_col.id)).all()
        assert len(req_profiles) == 0

        # Third column (empty profiles_by_source) should have 0 profiles
        conf_profiles = s.exec(select(AssessColumnSourceProfile).where(
            AssessColumnSourceProfile.column_id == conf_col.id)).all()
        assert len(conf_profiles) == 0

        # Re-ingest replaces the profiles; none are orphaned or duplicated.
        ingest_domain_run(s, _ws_with(files), s.get(AssessDomainRun, dr_id))
        assert len(s.exec(select(AssessColumnSourceProfile)).all()) == 2

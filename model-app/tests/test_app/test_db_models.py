"""Test Lakebase database models — schema structure and load-bearing defaults.

Trimmed: tautological default-value / __tablename__ / FK-declaration tests
removed (Pydantic + SQLModel guarantee these). What remains targets:

- The schema-creation surface (all expected tables, all FK constraints) — would
  catch a missed migration / accidental table rename.
- BIGINT widening for `vibe_session_id_bigint` — real bug class (overflow).
- `intent` and `last_consumed_step_id` defaults — directly read by the
  orchestrator wiring.
"""

import sys
import os

import pytest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

from sqlmodel import select
from vibe_modeling.backend import db_models as db
from vibe_modeling.backend.db_models import Run, AssessColumnSourceProfile


class TestRunDefaults:
    def test_intent_default(self):
        r = Run(business_id="fake-id")
        assert r.intent == ""

    def test_last_consumed_step_id_default(self):
        r = Run(business_id="fake-id")
        assert r.last_consumed_step_id == 0

    def test_vibe_session_id_bigint_widening(self):
        # vibe_session_id_bigint must accept values that overflow INT4.
        big = 2**40  # well above 2_147_483_647
        r = Run(business_id="fake-id", vibe_session_id="sid", vibe_session_id_bigint=big)
        assert r.vibe_session_id_bigint == big


class TestRunRejectsUnknownFields:
    """``Run`` declares ``extra="forbid"``, but a SQLModel table model skips
    validation on construction, so ``Run.__init__`` checks the keys itself."""

    def test_unknown_kwarg_raises(self):
        with pytest.raises(TypeError, match="bogus"):
            Run(business_id="fake-id", bogus=1)

    def test_retired_column_name_raises(self):
        with pytest.raises(TypeError, match="run_type"):
            Run(business_id="fake-id", run_type="install model")

    def test_relationship_kwarg_accepted(self):
        r = Run(business_id="fake-id", artifacts=[])
        assert r.artifacts == []

    def test_row_loaded_from_db_round_trips(self, engine):
        from sqlmodel import Session

        with Session(engine) as s:
            biz = db.Business(name="Acme")
            s.add(biz)
            s.commit()
            run = Run(business_id=biz.id, intent="install", status="completed")
            s.add(run)
            s.commit()
            run_id = run.id
        with Session(engine) as s:
            loaded = s.get(Run, run_id)
            assert loaded.intent == "install"
            assert Run.model_validate(loaded.model_dump()).id == run_id


class TestDatabaseSchema:
    def test_all_tables_created(self, engine):
        from sqlalchemy import inspect as sa_inspect
        insp = sa_inspect(engine)
        tables = insp.get_table_names()
        expected = [
            "businesses", "business_contexts", "agent_config",
            "model_versions", "runs", "run_artifacts", "run_progress_events",
            "domains", "products", "attributes", "foreign_key_links",
            # Vibe Inputs redesign (Task 2)
            "vibe_inputs", "vibe_input_context_links", "run_input_links",
            "subdomains", "product_reviews",
            # Vibe Inputs redesign (Task 4) — element rename/merge/delete lineage
            "run_element_lineage",
            # Headless assessment (migration 0.8.0)
            "assess_config", "assess_source_map", "assess_batch", "assess_domain_run",
            "assess_domain_source", "assess_entity", "assess_column_mapping", "assess_gap",
            "assess_pending_decision", "assess_decision_option", "assess_next_vibe",
            "assess_handoff",
            # Assessment results readability
            "assess_summary", "assess_summary_item", "assess_decision_option_point",
            "assess_decision_affected", "assess_next_vibe_entity",
            # Version lifecycle + run report (migration 0.9.0)
            "run_agent_reports", "run_post_install_deletes",
            # Install locations, cleanups, change review, wizard state (migration 0.9.0.1)
            "model_version_installs", "metamodel_cleanups", "run_schema_drops",
            "run_change_decisions", "taxonomy_wizard_states",
        ]
        for table in expected:
            assert table in tables, f"Table '{table}' not created"

    def test_foreign_key_constraints(self, engine):
        from sqlalchemy import inspect as sa_inspect
        insp = sa_inspect(engine)
        assert "businesses" in {fk["referred_table"] for fk in insp.get_foreign_keys("business_contexts")}
        assert "businesses" in {fk["referred_table"] for fk in insp.get_foreign_keys("runs")}
        assert "runs" in {fk["referred_table"] for fk in insp.get_foreign_keys("run_artifacts")}
        assert "runs" in {fk["referred_table"] for fk in insp.get_foreign_keys("run_progress_events")}
        assert "model_versions" in {fk["referred_table"] for fk in insp.get_foreign_keys("domains")}
        assert "domains" in {fk["referred_table"] for fk in insp.get_foreign_keys("products")}
        assert "products" in {fk["referred_table"] for fk in insp.get_foreign_keys("attributes")}
        assert "model_versions" in {fk["referred_table"] for fk in insp.get_foreign_keys("foreign_key_links")}

    def test_vibe_input_foreign_keys(self, engine):
        from sqlalchemy import inspect as sa_inspect
        insp = sa_inspect(engine)
        assert "businesses" in {fk["referred_table"] for fk in insp.get_foreign_keys("vibe_inputs")}

        ctx_referred = {fk["referred_table"] for fk in insp.get_foreign_keys("vibe_input_context_links")}
        for t in ("vibe_inputs", "model_versions", "domains", "subdomains",
                  "products", "attributes", "foreign_key_links"):
            assert t in ctx_referred, f"vibe_input_context_links missing FK→{t}"

        link_referred = {fk["referred_table"] for fk in insp.get_foreign_keys("run_input_links")}
        assert "runs" in link_referred
        assert "vibe_inputs" in link_referred

        sub_referred = {fk["referred_table"] for fk in insp.get_foreign_keys("subdomains")}
        assert "model_versions" in sub_referred
        assert "domains" in sub_referred

        rev_referred = {fk["referred_table"] for fk in insp.get_foreign_keys("product_reviews")}
        assert "model_versions" in rev_referred
        assert "products" in rev_referred

        assert "subdomains" in {fk["referred_table"] for fk in insp.get_foreign_keys("products")}

    def test_self_fk_previous_element_id(self, engine):
        from sqlalchemy import inspect as sa_inspect
        insp = sa_inspect(engine)
        for table in ("domains", "products", "attributes", "foreign_key_links", "subdomains"):
            referred = {fk["referred_table"] for fk in insp.get_foreign_keys(table)}
            assert table in referred, (
                f"{table}.previous_element_id self-FK→{table} missing"
            )


class TestRunElementLineageSchema:
    """Task 4 — the rename/merge/delete edge table."""

    def test_foreign_keys(self, engine):
        from sqlalchemy import inspect as sa_inspect
        insp = sa_inspect(engine)
        referred = {fk["referred_table"] for fk in insp.get_foreign_keys("run_element_lineage")}
        assert "runs" in referred
        assert "model_versions" in referred

    def test_defaults(self):
        row = db.RunElementLineage(
            run_id="run-1",
            version_id="ver-1",
            element_type="product",
            change_kind="delete",
            old_element_id="old-1",
            old_fqn="legacy.thing",
        )
        assert row.new_element_id is None
        assert row.new_fqn == ""
        assert row.reason == ""

    def test_nullable_element_ids(self):
        cols = db.RunElementLineage.__table__.c
        assert cols.old_element_id.nullable is True
        assert cols.new_element_id.nullable is True


class TestVibeInputDefaults:
    def test_defaults(self):
        v = db.VibeInput(business_id="biz-1")
        assert v.origin == "user"
        assert v.author == ""
        assert v.priority == "medium"
        assert v.consumed is False
        assert v.selected_for_run is False
        assert v.status == "active"
        assert v.deprecated_by is None
        assert v.confidence_score is None
        assert v.category is None


class TestVibeInputNullability:
    """N2: lock the nullability flag on every column this task adds, so a
    future accidental NOT NULL (or dropped NULL) is caught at the schema layer."""

    def test_vibe_input_nullable_columns(self):
        cols = db.VibeInput.__table__.c
        assert cols.deprecated_by.nullable is True
        assert cols.confidence_score.nullable is True
        # category is nullable — null for origin=user inputs (v_0_6_3).
        assert cols.category.nullable is True
        # author is NOT NULL with an empty-string default.
        assert cols.author.nullable is False
        assert db.VibeInput(business_id="biz-1").author == ""
        # selected_for_run is NOT NULL with a False default (run-selection flag).
        assert cols.selected_for_run.nullable is False
        assert db.VibeInput(business_id="biz-1").selected_for_run is False

    def test_previous_element_id_nullable(self):
        for model in (db.Domain, db.Product, db.Attribute, db.ForeignKeyLink, db.Subdomain):
            assert model.__table__.c.previous_element_id.nullable is True, (
                f"{model.__name__}.previous_element_id must be nullable"
            )

    def test_product_subdomain_id_nullable(self):
        assert db.Product.__table__.c.subdomain_id.nullable is True


class TestRunInputLinkCompositePK:
    def test_composite_pk(self):
        pk_cols = {c.name for c in db.RunInputLink.__table__.primary_key.columns}
        assert pk_cols == {"run_id", "input_id"}


class TestVibeInputContextLinkModelWide:
    """Edge case 1: an all-element-null context link (model-wide anchor) is a
    valid, persistable row."""

    def test_all_null_element_fks_persist_and_read_back(self, engine):
        from sqlmodel import Session, select

        with Session(engine) as session:
            biz = db.Business(name="ctx-biz")
            session.add(biz)
            session.commit()
            session.refresh(biz)

            mv = db.ModelVersion(business_id=biz.id)
            session.add(mv)
            session.commit()
            session.refresh(mv)

            vi = db.VibeInput(business_id=biz.id)
            session.add(vi)
            session.commit()
            session.refresh(vi)

            link = db.VibeInputContextLink(input_id=vi.id, version_id=mv.id)
            session.add(link)
            session.commit()

            got = session.exec(
                select(db.VibeInputContextLink).where(
                    db.VibeInputContextLink.input_id == vi.id
                )
            ).one()
            assert got.domain_id is None
            assert got.subdomain_id is None
            assert got.product_id is None
            assert got.attribute_id is None
            assert got.fk_link_id is None
            assert got.is_origin is False
            assert got.needs_link_review is False


class TestModelVersionProvenanceColumns:
    """v_0_7_0: nullable agent_version / release_version persist + read back,
    default NULL for pre-existing rows."""

    def test_defaults_null(self):
        mv = db.ModelVersion(business_id="fake-id")
        assert mv.agent_version is None
        assert mv.release_version is None

    def test_persist_and_read_back(self, engine):
        from sqlmodel import Session, select

        with Session(engine) as session:
            biz = db.Business(name="prov-biz")
            session.add(biz)
            session.flush()
            mv = db.ModelVersion(
                business_id=biz.id,
                version=1,
                agent_version="4.9.8",
                release_version="0.8.0",
            )
            session.add(mv)
            session.commit()
            mv_id = mv.id

        with Session(engine) as session:
            got = session.exec(
                select(db.ModelVersion).where(db.ModelVersion.id == mv_id)
            ).one()
            assert got.agent_version == "4.9.8"
            assert got.release_version == "0.8.0"

    def test_columns_present_on_table(self):
        cols = {c.name for c in db.ModelVersion.__table__.columns}
        assert {"agent_version", "release_version"} <= cols


class TestAssessReadabilitySchema:
    """Assessment results readability: summary / tiers / decision detail / next-vibe urgency."""

    def test_new_columns_present(self):
        cols = lambda m: set(m.__table__.columns.keys())  # noqa: E731
        assert {"core_sourced", "core_total", "enrichment_sourced", "enrichment_total",
                "deferred_fk_count", "grade_reason", "row_filter", "reported_letter"} <= cols(db.AssessEntity)
        assert "tier" in cols(db.AssessColumnMapping)
        assert {"context", "why_it_matters", "recommendation_rationale", "blocks_build",
                "recommended_option_id"} <= cols(db.AssessPendingDecision)
        assert "impact" in cols(db.AssessDecisionOption)
        assert {"problem", "proposed_change", "impact_if_skipped", "urgency"} <= cols(db.AssessNextVibe)

    def test_structure_axis_columns_present(self):
        assert "reported_structure" in db.AssessEntity.__table__.columns.keys()
        assert "kind" in db.AssessPendingDecision.__table__.columns.keys()

    def test_new_tables_registered(self):
        for m in (db.AssessSummary, db.AssessSummaryItem, db.AssessDecisionOptionPoint,
                  db.AssessDecisionAffected, db.AssessNextVibeEntity, db.AssessColumnSourceProfile):
            assert m in db.ASSESS_TABLES

    def test_new_table_foreign_keys(self, engine):
        from sqlalchemy import inspect as sa_inspect
        insp = sa_inspect(engine)
        def fks(t):
            return {(fk["referred_table"], fk["options"].get("ondelete")) for fk in insp.get_foreign_keys(t)}
        assert ("assess_domain_run", "CASCADE") in fks("assess_summary")
        assert ("assess_summary", "CASCADE") in fks("assess_summary_item")
        assert ("assess_decision_option", "CASCADE") in fks("assess_decision_option_point")
        assert ("assess_pending_decision", "CASCADE") in fks("assess_decision_affected")
        assert ("assess_next_vibe", "CASCADE") in fks("assess_next_vibe_entity")
        assert ("assess_column_mapping", "CASCADE") in fks("assess_column_source_profile")

    def test_round_trip(self, engine):
        from sqlmodel import Session
        with Session(engine) as session:
            self._round_trip(session)

    def _round_trip(self, session):
        biz = db.Business(name="b")
        session.add(biz); session.commit()
        mv = db.ModelVersion(business_id=biz.id, version=1)
        session.add(mv); session.commit()
        dom = db.Domain(version_id=mv.id, name="d")
        batch = db.AssessBatch(business_id=biz.id, version_id=mv.id)
        session.add(dom); session.add(batch); session.commit()
        run = db.AssessDomainRun(batch_id=batch.id, domain_id=dom.id)
        session.add(run); session.commit()

        session.add(db.AssessSummary(domain_run_id=run.id, headline="h", verdict="ready",
                                     verdict_reason="r", recommended_next_step="n"))
        session.commit()
        session.add(db.AssessSummaryItem(summary_id=run.id, kind="finding", ordinal=0, text="t"))
        ent = db.AssessEntity(domain_run_id=run.id, name="e", grade="partial", core_sourced=3,
                              core_total=4, enrichment_sourced=1, enrichment_total=5,
                              deferred_fk_count=2, grade_reason="why", row_filter="x=1",
                              reported_letter="B")
        session.add(ent); session.commit()
        col = db.AssessColumnMapping(entity_id=ent.id, target="c", status="mapped", tier="core")
        session.add(col); session.commit()
        session.add(db.AssessColumnSourceProfile(column_id=col.id, ordinal=0, system="src1",
                                                 source_table="t1", source_column="c1", role="populates",
                                                 row_count=100, null_pct=2.5, note="test"))
        dec = db.AssessPendingDecision(domain_run_id=run.id, question="q", context="c",
                                       why_it_matters="w", recommendation_rationale="rr",
                                       blocks_build=True)
        session.add(dec); session.commit()
        opt = db.AssessDecisionOption(decision_id=dec.id, label="l", impact="i")
        session.add(opt); session.commit()
        dec.recommended_option_id = opt.id
        session.add(dec)
        session.add(db.AssessDecisionOptionPoint(option_id=opt.id, kind="pro", ordinal=0, text="p"))
        session.add(db.AssessDecisionAffected(decision_id=dec.id, entity="e", column="c"))
        nv = db.AssessNextVibe(domain_run_id=run.id, text="t", problem="p", proposed_change="pc",
                               impact_if_skipped="ii", urgency="high")
        session.add(nv); session.commit()
        session.add(db.AssessNextVibeEntity(next_vibe_id=nv.id, entity="e"))
        session.commit()

        session.refresh(ent); session.refresh(dec)
        assert (ent.core_sourced, ent.reported_letter, ent.row_filter) == (3, "B", "x=1")
        assert dec.recommended_option_id == opt.id and dec.blocks_build is True
        assert nv.urgency == "high"
        profile = session.exec(select(AssessColumnSourceProfile)).first()
        assert profile.system == "src1" and profile.row_count == 100 and profile.null_pct == 2.5


class TestVersionLifecycleSchema:
    """v_0_9_0: lifecycle columns on model_versions, outcome columns on
    run_input_links, consumed_by_run_id on vibe_inputs, the installed-identity
    cache on agent_config, and the two new tables."""

    def test_model_version_defaults(self):
        mv = db.ModelVersion(business_id="fake-id")
        assert mv.dry_run is False
        for name in ("promoted_at", "promoted_by_run_id", "replaced_by_version_id", "replaced_at",
                     "files_catalog", "scope_fence_mode", "scope_base_version", "scope_base_scope"):
            assert getattr(mv, name) is None, name

    def test_set_null_foreign_keys(self, engine):
        from sqlalchemy import inspect as sa_inspect
        insp = sa_inspect(engine)
        expected = {
            ("model_versions", "promoted_by_run_id"): "runs",
            ("model_versions", "replaced_by_version_id"): "model_versions",
            ("vibe_inputs", "consumed_by_run_id"): "runs",
        }
        for (table, column), parent in expected.items():
            fks = [fk for fk in insp.get_foreign_keys(table) if fk["constrained_columns"] == [column]]
            assert len(fks) == 1, (table, column)
            assert fks[0]["referred_table"] == parent
            assert fks[0]["options"].get("ondelete") == "SET NULL"

    def test_promoted_by_run_id_breaks_the_runs_cycle(self):
        (fk,) = db.ModelVersion.__table__.columns["promoted_by_run_id"].foreign_keys
        assert fk.use_alter and fk.name == "model_versions_promoted_by_run_id_fkey"

    def test_run_input_link_outcome_columns_nullable(self):
        cols = db.RunInputLink.__table__.columns
        for name in ("outcome_status", "outcome_reason", "outcome_target"):
            assert cols[name].nullable, name

    def test_agent_config_identity_cache_defaults_null(self):
        cfg = db.AgentConfig()
        for name in ("installed_release_version", "installed_agent_version", "installed_checked_at",
                     "installed_checked_path", "installed_check_error"):
            assert getattr(cfg, name) is None, name

    def test_new_table_keys(self):
        assert {c.name for c in db.RunAgentReport.__table__.primary_key.columns} == {"run_id"}
        assert {c.name for c in db.RunPostInstallDelete.__table__.primary_key.columns} == {"run_id", "version_id"}
        assert not db.RunPostInstallDelete.__table__.columns["version_id"].foreign_keys

    def test_round_trip_and_cascade(self, fk_engine):
        from sqlmodel import Session

        with Session(fk_engine) as session:
            biz = db.Business(name="lifecycle-biz")
            session.add(biz)
            session.flush()
            run = db.Run(business_id=biz.id, intent="install model")
            replacer = db.ModelVersion(business_id=biz.id, version=3, scope="ecm")
            session.add_all([run, replacer])
            session.flush()
            mv = db.ModelVersion(business_id=biz.id, version=5, scope="ecm", dry_run=True,
                                 promoted_by_run_id=run.id, replaced_by_version_id=replacer.id,
                                 files_catalog="cat_a", scope_fence_mode="some_domains",
                                 scope_base_version=4, scope_base_scope="ecm")
            vi = db.VibeInput(business_id=biz.id, consumed=True, consumed_by_run_id=run.id)
            session.add_all([mv, vi])
            session.flush()
            session.add_all([
                db.RunInputLink(run_id=run.id, input_id=vi.id, outcome_status="applied",
                                outcome_reason="done", outcome_target="sales.orders"),
                db.RunAgentReport(run_id=run.id, has_input_outcomes=True, expected_version=5,
                                  fetched_version=5, lineage_stale=False),
                db.RunPostInstallDelete(run_id=run.id, version_id="v-old", version=4, scope="ecm"),
            ])
            session.commit()
            run_id, mv_id, vi_id = run.id, mv.id, vi.id

        with Session(fk_engine) as session:
            got = session.get(db.ModelVersion, mv_id)
            assert (got.dry_run, got.files_catalog, got.scope_base_version) == (True, "cat_a", 4)
            report = session.get(db.RunAgentReport, run_id)
            assert report.has_input_outcomes and report.unmatched_outcome_count == 0
            pending = session.get(db.RunPostInstallDelete, (run_id, "v-old"))
            assert pending.status == "pending" and pending.completed_at is None
            session.delete(session.get(db.Run, run_id))
            session.commit()

        with Session(fk_engine) as session:
            assert session.get(db.ModelVersion, mv_id).promoted_by_run_id is None
            assert session.get(db.VibeInput, vi_id).consumed_by_run_id is None
            assert session.get(db.RunAgentReport, run_id) is None
            assert session.get(db.RunPostInstallDelete, (run_id, "v-old")) is None


class TestAddendumSchema:
    """v_0_9_0_1: install locations, metamodel cleanups, schema drops, change
    decisions, the saved taxonomy wizard, and the new run / agent_config columns."""

    def test_run_and_agent_config_columns_default_null(self):
        run = db.Run(business_id="fake-id")
        assert run.linked_at is None and run.link_evidence is None
        cfg = db.AgentConfig()
        assert cfg.taxonomy_updated_by is None and cfg.taxonomy_updated_at is None

    def test_foreign_keys(self, engine):
        from sqlalchemy import inspect as sa_inspect

        insp = sa_inspect(engine)
        expected = {
            ("model_version_installs", "version_id"): ("model_versions", "CASCADE"),
            ("model_version_installs", "installed_by_run_id"): ("runs", "SET NULL"),
            ("model_version_installs", "uninstalled_by_run_id"): ("runs", "SET NULL"),
            ("run_schema_drops", "run_id"): ("runs", "CASCADE"),
            ("run_change_decisions", "run_id"): ("runs", "CASCADE"),
            ("run_change_decisions", "version_id"): ("model_versions", "CASCADE"),
            ("run_change_decisions", "feedback_input_id"): ("vibe_inputs", "SET NULL"),
            ("taxonomy_wizard_states", "sector_id"): ("sectors", "SET NULL"),
        }
        for (table, column), (parent, action) in expected.items():
            fks = [fk for fk in insp.get_foreign_keys(table) if fk["constrained_columns"] == [column]]
            assert len(fks) == 1, (table, column)
            assert (fks[0]["referred_table"], fks[0]["options"].get("ondelete")) == (parent, action)
        assert not insp.get_foreign_keys("metamodel_cleanups")

    def test_keys_and_indexes(self, engine):
        from sqlalchemy import inspect as sa_inspect

        insp = sa_inspect(engine)
        assert set(db.RunSchemaDrop.__table__.primary_key.columns.keys()) == {"run_id", "catalog", "schema_name"}
        installs = {i["name"]: i for i in insp.get_indexes("model_version_installs")}
        open_ix = installs["uq_model_version_installs_open"]
        assert open_ix["unique"] and open_ix["column_names"] == ["version_id", "catalog"]
        lookup = {i["name"]: i for i in insp.get_indexes("metamodel_cleanups")}["ix_metamodel_cleanups_lookup"]
        assert lookup["column_names"] == ["business_segment", "scope", "catalog", "status"]
        uniques = {u["name"]: u["column_names"] for u in insp.get_unique_constraints("run_change_decisions")}
        assert uniques["uq_run_change_decisions_element"] == ["run_id", "element_kind", "element_path"]
        assert db.TaxonomyWizardState.__table__.columns["owner"].unique
        assert not db.TaxonomyWizardState.__table__.columns["intake_json"].nullable

    def test_one_open_install_row_per_version_and_catalog(self, engine):
        from datetime import datetime, timezone

        import pytest
        from sqlalchemy.exc import IntegrityError
        from sqlmodel import Session

        now = datetime(2026, 10, 22, tzinfo=timezone.utc)
        with Session(engine) as session:
            biz = db.Business(name="installs-biz")
            session.add(biz)
            session.flush()
            mv = db.ModelVersion(business_id=biz.id, version=1, scope="ecm")
            session.add(mv)
            session.flush()
            session.add_all([
                db.ModelVersionInstall(version_id=mv.id, catalog="cat_a", uninstalled_at=now),
                db.ModelVersionInstall(version_id=mv.id, catalog="cat_a", uninstalled_at=now),
                db.ModelVersionInstall(version_id=mv.id, catalog="cat_a"),
                db.ModelVersionInstall(version_id=mv.id, catalog="cat_b"),
            ])
            session.commit()
            session.add(db.ModelVersionInstall(version_id=mv.id, catalog="cat_a"))
            with pytest.raises(IntegrityError):
                session.commit()

    def test_round_trip_and_on_delete(self, fk_engine):
        from datetime import datetime, timedelta, timezone

        from sqlmodel import Session

        now = datetime(2026, 10, 22, tzinfo=timezone.utc)
        with Session(fk_engine) as session:
            sector = db.Sector(name="Retail")
            biz = db.Business(name="addendum-biz")
            session.add_all([sector, biz])
            session.flush()
            run = db.Run(business_id=biz.id, intent="vibe-iterate", linked_at=now, link_evidence="tier 1")
            mv = db.ModelVersion(business_id=biz.id, version=2, scope="ecm")
            session.add_all([run, mv])
            session.flush()
            vi = db.VibeInput(business_id=biz.id, origin="change_rejection", text="put it back")
            session.add(vi)
            session.flush()
            session.add_all([
                db.ModelVersionInstall(version_id=mv.id, catalog="cat_a", installed_by_run_id=run.id),
                db.MetamodelCleanup(business_segment="addendum_biz", version=1, scope="ecm", catalog="cat_a",
                                    reason="version_delete"),
                db.RunSchemaDrop(run_id=run.id, catalog="cat_a", schema_name="ecm_sales", table_count=3),
                db.RunChangeDecision(run_id=run.id, version_id=mv.id, element_kind="product",
                                     element_path="sales.orders", change_kind="removed", decision="rejected",
                                     decided_by="a@b.c", feedback_input_id=vi.id),
                db.TaxonomyWizardState(owner="a@b.c", sector_id=sector.id, intake_json="{}",
                                       expires_at=now + timedelta(days=7)),
            ])
            session.commit()
            ids = (run.id, mv.id, vi.id, sector.id)

        run_id, mv_id, vi_id, sector_id = ids
        with Session(fk_engine) as session:
            got = session.get(db.Run, run_id)
            assert (got.link_evidence, got.linked_at is not None) == ("tier 1", True)
            cleanup = session.exec(select(db.MetamodelCleanup)).one()
            assert (cleanup.status, cleanup.attempts, cleanup.last_error) == ("pending", 0, None)
            drop = session.get(db.RunSchemaDrop, (run_id, "cat_a", "ecm_sales"))
            assert (drop.status, drop.error) == ("pending", None)
            state = session.exec(select(db.TaxonomyWizardState)).one()
            assert (state.step, state.revision, state.strictness, state.tree_json) == (0, 0, "strict", None)
            session.delete(session.get(db.VibeInput, vi_id))
            session.delete(session.get(db.Sector, sector_id))
            session.commit()
            assert session.exec(select(db.RunChangeDecision)).one().feedback_input_id is None
            assert session.exec(select(db.TaxonomyWizardState)).one().sector_id is None
            session.delete(session.get(db.Run, run_id))
            session.commit()
            assert session.exec(select(db.ModelVersionInstall)).one().installed_by_run_id is None
            assert session.exec(select(db.RunSchemaDrop)).all() == []
            assert session.exec(select(db.RunChangeDecision)).all() == []
            session.delete(session.get(db.ModelVersion, mv_id))
            session.commit()
            assert session.exec(select(db.ModelVersionInstall)).all() == []
            assert len(session.exec(select(db.MetamodelCleanup)).all()) == 1


class TestBooleanServerDefaults:
    """``server_default=false()`` / ``true()`` render ``0`` / ``1`` on SQLite and
    ``false`` / ``true`` on Postgres. A quoted ``'false'`` would store the text on
    SQLite, which reads back as True."""

    # (table, column) -> (SQLite rendering, Postgres rendering)
    COLUMNS = {
        ("model_versions", "dry_run"): ("0", "false"),
        ("agent_config", "collect_vibe_run_statistics"): ("1", "true"),
    }

    @staticmethod
    def _raw_insert_omitting(conn, table_name: str, omit: str, row_id: str, **values) -> None:
        """Insert with every other NOT NULL column filled, so only ``omit`` takes its server default."""
        from datetime import datetime, timezone

        from sqlalchemy import Boolean, DateTime, Integer, insert

        table = db.SQLModel.metadata.tables[table_name]
        row = {"id": row_id, **values}
        for col in table.columns:
            if col.name in row or col.name == omit or col.nullable or col.server_default is not None:
                continue
            if isinstance(col.type, DateTime):
                row[col.name] = datetime(2026, 10, 22, tzinfo=timezone.utc)
            elif isinstance(col.type, (Integer, Boolean)):
                row[col.name] = 0
            else:
                row[col.name] = ""
        conn.execute(insert(table).values(**row))

    def test_raw_insert_without_the_column_reads_its_default(self, engine):
        from sqlmodel import Session

        with Session(engine) as session:
            session.add(db.Business(id="b-raw", name="Raw"))
            session.commit()
        with engine.begin() as conn:
            self._raw_insert_omitting(conn, "model_versions", "dry_run", "mv-raw", business_id="b-raw")
            self._raw_insert_omitting(conn, "agent_config", "collect_vibe_run_statistics", "cfg-raw")
        with Session(engine) as session:
            assert session.get(db.ModelVersion, "mv-raw").dry_run is False
            assert session.get(db.AgentConfig, "cfg-raw").collect_vibe_run_statistics is True

    def test_defaults_compile_per_dialect(self):
        from sqlalchemy.dialects import postgresql, sqlite

        for (table, column), (on_sqlite, on_pg) in self.COLUMNS.items():
            default = db.SQLModel.metadata.tables[table].columns[column].server_default.arg
            assert str(default.compile(dialect=sqlite.dialect())) == on_sqlite
            assert str(default.compile(dialect=postgresql.dialect())) == on_pg

    def test_python_defaults_match_the_server_defaults(self):
        assert db.ModelVersion(business_id="b").dry_run is False
        assert db.AgentConfig().collect_vibe_run_statistics is True

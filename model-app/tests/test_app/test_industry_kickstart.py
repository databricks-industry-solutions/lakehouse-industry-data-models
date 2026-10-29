"""Tests for ``services.industry_kickstart`` + the kickstart endpoint.

Story-8 (ADR D-050). Kickstart clones a ``kind='industry'`` version into a
fresh ``kind='business'`` business. The spine invariant: the new business's
model **structure** (domains / products / attributes / FK links) is identical
to the source industry version's — proven by exporting both and comparing
counts. Provenance columns and an audit Run must also be set.
"""

from __future__ import annotations

import json
import time
from types import SimpleNamespace
from unittest.mock import MagicMock

import pytest
from sqlmodel import Session, select

from ._drift.fake_uc import agent_registry_columns
from ._lifecycle_fixtures import require_files_catalog  # noqa: F401
from vibe_modeling.backend.db_models import (
    AgentConfig,
    Attribute,
    Business,
    Domain,
    ForeignKeyLink,
    ModelVersion,
    Product,
    Run,
    RunArtifact,
    VibeInput,
    VibeInputContextLink,
)
from vibe_modeling.backend.model_export import export_model_json
from vibe_modeling.backend.model_sync import ModelSyncService
from vibe_modeling.backend.services.industry_kickstart import (
    KickstartDescriptionRequired,
    KickstartError,
    kickstart_from_industry,
)


def _seed_agent_config(engine, *, deployment_catalog: str = "deploy_cat") -> None:
    """Seed the singleton AgentConfig so the kickstart resolves the deployment
    catalog from it (the sibling of import/Volume-import), not from the empty
    per-model install catalog."""
    with Session(engine) as session:
        session.add(AgentConfig(deployment_catalog=deployment_catalog))
        session.commit()


SAMPLE_MODEL = {
    "type": "business",
    "name": "Retail Industry",
    "version": "v1_ecm",
    "description": "A retail industry template.",
    "domains": [
        {
            "name": "sales",
            "division": "Commercial",
            "description": "Sales domain.",
            "products": [
                {
                    "product": "order",
                    "description": "Customer orders.",
                    "type": "fact",
                    "primary_key": "order_id",
                    "attributes": [
                        {"attribute": "order_id", "type": "bigint"},
                        {
                            "attribute": "customer_id",
                            "type": "bigint",
                            "foreign_key_to": "customer.profile.customer_id",
                        },
                    ],
                },
            ],
        },
        {
            "name": "customer",
            "division": "Commercial",
            "description": "Customer domain.",
            "products": [
                {
                    "product": "profile",
                    "description": "Customer profiles.",
                    "type": "dimension",
                    "primary_key": "customer_id",
                    "attributes": [
                        {"attribute": "customer_id", "type": "bigint"},
                    ],
                },
            ],
        },
    ],
}


def _seed_industry(engine) -> tuple[str, str]:
    """Seed a kind='industry' business + v1 ECM version with SAMPLE_MODEL.

    Returns (industry_id, source_version_id).
    """
    with Session(engine) as session:
        industry = Business(
            name="Retail Industry",
            industry_alignment="Retail",
            description="A retail industry template.",
            kind="industry",
        )
        session.add(industry)
        session.flush()
        mv = ModelVersion(
            business_id=industry.id,
            version=1,
            scope="ecm",
            status="completed",
            uc_catalog="test_cat",
        )
        session.add(mv)
        session.flush()
        ModelSyncService(session).sync_from_model_json(mv.id, SAMPLE_MODEL)
        session.commit()
        return industry.id, mv.id


def _seed_industry_blank_description(engine) -> tuple[str, str]:
    """Like ``_seed_industry`` but the industry itself has a blank
    description - the case an industry seeded from a description-less
    ``model.json`` can end up in. Returns (industry_id, source_version_id)."""
    with Session(engine) as session:
        industry = Business(
            name="Blank Desc Industry",
            industry_alignment="Retail",
            description="",
            kind="industry",
        )
        session.add(industry)
        session.flush()
        mv = ModelVersion(
            business_id=industry.id,
            version=1,
            scope="ecm",
            status="completed",
            uc_catalog="test_cat",
        )
        session.add(mv)
        session.flush()
        ModelSyncService(session).sync_from_model_json(mv.id, SAMPLE_MODEL)
        session.commit()
        return industry.id, mv.id


def _counts(session: Session, version_id: str) -> dict[str, int]:
    domains = session.exec(
        select(Domain).where(Domain.version_id == version_id)
    ).all()
    domain_ids = [d.id for d in domains]
    products = session.exec(
        select(Product).where(Product.domain_id.in_(domain_ids or [""]))
    ).all()
    product_ids = [p.id for p in products]
    attrs = session.exec(
        select(Attribute).where(Attribute.product_id.in_(product_ids or [""]))
    ).all()
    fks = session.exec(
        select(ForeignKeyLink).where(ForeignKeyLink.version_id == version_id)
    ).all()
    return {
        "domains": len(domains),
        "products": len(products),
        "attributes": len(attrs),
        "fks": len(fks),
    }


def _ws_with_artifacts(rel_files: list[str]) -> MagicMock:
    """Mock ws whose Volume version dir contains ``rel_files`` (flat)."""
    ws = MagicMock()
    entries = []
    for rel in rel_files:
        e = MagicMock()
        e.name = rel
        e.is_directory = False
        e.file_size = None
        entries.append(e)
    ws.files.list_directory_contents.return_value = entries

    def _download(path):
        body = MagicMock()
        # The kickstart reads the industry model.json for its schema prefix
        # (``scope_prefix.import_schema_prefix``); every other file is opaque bytes.
        body.contents.read.return_value = (
            json.dumps({"model": SAMPLE_MODEL}).encode() if path.endswith("/model.json") else b"<bytes>"
        )
        return body

    ws.files.download.side_effect = _download
    ws.files.upload = MagicMock()
    return ws


def test_kickstart_roundtrips_structure(engine):
    industry_id, source_version_id = _seed_industry(engine)
    ws = _ws_with_artifacts([])  # no artifacts — structure focus

    with Session(engine) as session:
        new_business = kickstart_from_industry(
            session, ws,
            source_industry_id=industry_id,
            source_version=1,
            new_name="Acme Corp",
        )
        session.commit()
        new_business_id = new_business.id

    with Session(engine) as session:
        src_counts = _counts(session, source_version_id)
        new_mv = session.exec(
            select(ModelVersion).where(
                ModelVersion.business_id == new_business_id
            )
        ).first()
        new_counts = _counts(session, new_mv.id)

        # Structural exports must match domain/product/attr/FK counts.
        assert new_counts == src_counts
        assert src_counts == {
            "domains": 2, "products": 2, "attributes": 3, "fks": 1,
        }

        # And the re-exported model.json structure is equivalent.
        src_export = export_model_json(session, source_version_id)["model"]
        new_export = export_model_json(session, new_mv.id)["model"]
        assert {d["name"] for d in src_export["domains"]} == {
            d["name"] for d in new_export["domains"]
        }


def test_kickstart_sets_provenance_and_audit_run(engine):
    industry_id, _ = _seed_industry(engine)
    ws = _ws_with_artifacts([])

    with Session(engine) as session:
        new_business = kickstart_from_industry(
            session, ws,
            source_industry_id=industry_id,
            source_version=1,
            new_name="Beta LLC",
            new_description="A kickstarted business.",
        )
        session.commit()
        new_id = new_business.id

    with Session(engine) as session:
        biz = session.get(Business, new_id)
        assert biz.kind == "business"
        assert biz.source_industry_id == industry_id
        assert biz.source_version == 1
        assert biz.description == "A kickstarted business."

        runs = session.exec(
            select(Run).where(Run.business_id == new_id)
        ).all()
        assert len(runs) == 1
        assert runs[0].intent == "kickstart-from-industry"
        assert runs[0].status == "completed"


def test_kickstart_falls_back_to_industry_description_when_blank(engine):
    """The agent hard-requires a non-empty business description for
    model-producing runs. When the kickstart request carries no
    ``new_description``, the new business must inherit the source industry's
    description rather than being created with an empty one."""
    industry_id, _ = _seed_industry(engine)
    ws = _ws_with_artifacts([])

    with Session(engine) as session:
        new_business = kickstart_from_industry(
            session, ws,
            source_industry_id=industry_id,
            source_version=1,
            new_name="Gamma LLC",
        )
        session.commit()
        new_id = new_business.id

    with Session(engine) as session:
        biz = session.get(Business, new_id)
        assert biz.description == "A retail industry template."


def test_kickstart_audit_run_is_real_lifecycle_with_lineage(engine):
    """The kickstart audit run is a REAL lifecycle for the background artifact
    copy: born with started_at, driven to completed with completed_at set (a
    proper timeline, not started==completed). It carries the source lineage in
    vibe_instructions_text. (Download's audit run keeps started==completed.)"""
    industry_id, _ = _seed_industry(engine)
    ws = _ws_with_artifacts([])
    with Session(engine) as session:
        # No schedule_copy -> the copy runs inline and drives the run to
        # completed before returning.
        nb = kickstart_from_industry(
            session, ws, source_industry_id=industry_id,
            source_version=1, new_name="Lineage Co",
        )
        new_id = nb.id
    with Session(engine) as session:
        run = session.exec(select(Run).where(Run.business_id == new_id)).first()
        assert run.status == "completed"
        assert run.progress_percent == 100
        assert run.started_at is not None
        assert run.completed_at is not None
        assert run.completed_at >= run.started_at
        # Lineage: source industry name + version + app-relative link.
        assert "Source:" in run.vibe_instructions_text
        assert "Retail Industry v1" in run.vibe_instructions_text
        assert f"/businesses/{industry_id}" in run.vibe_instructions_text


def _seed_running_kickstart_run(engine, name: str) -> str:
    from datetime import datetime, timezone
    with Session(engine) as s:
        b = Business(name=name, description="d")
        s.add(b)
        s.flush()
        run = Run(
            business_id=b.id, intent="kickstart-from-industry",
            status="running", progress_percent=0,
            started_at=datetime.now(timezone.utc),
        )
        s.add(run)
        s.commit()
        return run.id


def test_kickstart_background_two_phase_progress_and_completes(engine, monkeypatch):
    """The two-phase background task (seed then copy) drives the audit run
    0 -> 100 and to completed with completed_at set, with per-phase progress
    messages."""
    import vibe_modeling.backend.services.industry_kickstart as k

    run_id = _seed_running_kickstart_run(engine, "BG Progress Co")
    plan = k._KickstartCopyPlan(
        run_id=run_id, deployment_catalog="deploy_cat",
        src_business_name="Src", new_business_name="BG Progress Co",
        seeds=[({"domains": []}, "ecm", 1)],
        copy_specs=[
            k._ArtifactCopySpec(new_mv_id="mv-ecm", new_version=1, src_version=1, scope="ecm"),
        ],
    )
    # Fake seed (no errors) + fake copy (no files) - test the phase/progress
    # transitions only.
    monkeypatch.setattr(k, "seed_metamodel_one", lambda ws, **kw: {"errors": []})
    monkeypatch.setattr(k, "_copy_version_files", lambda ws, **kw: ("dest", 0))
    monkeypatch.setattr(k, "get_warehouse_id", lambda s: "wh-1")

    messages: list[str] = []
    orig_set = k._set_run

    def _spy_set(session, rid, **fields):
        if "progress_message" in fields:
            messages.append(fields["progress_message"])
        orig_set(session, rid, **fields)

    monkeypatch.setattr(k, "_set_run", _spy_set)

    with Session(engine) as s:
        k._run_kickstart_background(s, MagicMock(), plan)

    with Session(engine) as s:
        run = s.get(Run, run_id)
        assert run.status == "completed"
        assert run.progress_percent == 100
        assert run.completed_at is not None
    # Phase 1 (seed) reported before phase 2 (copy).
    assert any("Seeding metamodel" in m for m in messages)
    assert any("Copying" in m for m in messages)


def test_kickstart_background_seed_failure_marks_run_failed(engine, monkeypatch):
    """A _metamodel seed error in phase 1 still runs the copy phase, then
    marks the RUN failed with the seed failure in error_message; the business
    stays usable."""
    import vibe_modeling.backend.services.industry_kickstart as k

    run_id = _seed_running_kickstart_run(engine, "BG Seed Fail Co")
    copied_scopes: list[str] = []
    plan = k._KickstartCopyPlan(
        run_id=run_id, deployment_catalog="deploy_cat",
        src_business_name="Src", new_business_name="BG Seed Fail Co",
        seeds=[({"domains": []}, "ecm", 1)],
        copy_specs=[
            k._ArtifactCopySpec(new_mv_id="mv-ecm", new_version=1, src_version=1, scope="ecm"),
        ],
    )
    monkeypatch.setattr(k, "get_warehouse_id", lambda s: "wh-1")
    monkeypatch.setattr(
        k, "seed_metamodel_one",
        lambda ws, **kw: {"errors": ["warehouse exploded"]},
    )

    def _track_copy(ws, **kw):
        copied_scopes.append(kw.get("scope"))
        return "dest", 0

    monkeypatch.setattr(k, "_copy_version_files", _track_copy)

    with Session(engine) as s:
        k._run_kickstart_background(s, MagicMock(), plan)

    with Session(engine) as s:
        run = s.get(Run, run_id)
        assert run.status == "failed"
        assert "warehouse exploded" in run.error_message
        assert "ecm v1" in run.error_message
        assert "artifacts were copied" in run.progress_message
        assert run.completed_at is not None
    # The copy phase runs after a failed seed.
    assert copied_scopes == ["ecm"]


def test_kickstart_background_copy_failure_marks_run_failed(engine, monkeypatch):
    """A hard copy failure in phase 2 marks the RUN failed with an
    error_message; the business stays usable (structure/seed already durable)."""
    import vibe_modeling.backend.services.industry_kickstart as k

    run_id = _seed_running_kickstart_run(engine, "BG Copy Fail Co")
    plan = k._KickstartCopyPlan(
        run_id=run_id, deployment_catalog="deploy_cat",
        src_business_name="Src", new_business_name="BG Copy Fail Co",
        seeds=[],  # skip phase 1 for this copy-failure case
        copy_specs=[
            k._ArtifactCopySpec(new_mv_id="mv-ecm", new_version=1, src_version=1, scope="ecm"),
        ],
    )
    monkeypatch.setattr(k, "get_warehouse_id", lambda s: "wh-1")

    def _boom(ws, **kw):
        raise RuntimeError("volume down")

    monkeypatch.setattr(k, "_copy_version_files", _boom)

    with Session(engine) as s:
        k._run_kickstart_background(s, MagicMock(), plan)

    with Session(engine) as s:
        run = s.get(Run, run_id)
        assert run.status == "failed"
        assert "volume down" in run.error_message
        assert run.completed_at is not None


def test_kickstart_copies_and_indexes_artifacts(engine, require_files_catalog):
    """Item 1: a DRAFT industry (source ``uc_catalog=''``) STILL copies +
    indexes because the catalog is resolved from the deployment config, not
    from the empty per-model install catalog."""
    _seed_agent_config(engine, deployment_catalog="deploy_cat")
    industry_id, src_version_id = _seed_industry(engine)
    # Force the draft state the bug hit: the source has NO install catalog.
    with Session(engine) as session:
        src_mv = session.get(ModelVersion, src_version_id)
        src_mv.uc_catalog = ""
        session.add(src_mv)
        session.commit()
    ws = _ws_with_artifacts(["model.json", "vibes/next_vibes.txt"])

    with Session(engine) as session, require_files_catalog:
        new_business = kickstart_from_industry(
            session, ws,
            source_industry_id=industry_id,
            source_version=1,
            new_name="Gamma Inc",
        )
        session.commit()
        new_id = new_business.id
    assert require_files_catalog.checked == 1

    # Uploads happened into the new version dir under the DEPLOYMENT catalog.
    assert ws.files.upload.call_count == 2
    for call in ws.files.upload.call_args_list:
        assert call.args[0].startswith("/Volumes/deploy_cat/")
        # files.upload must receive a binary file-like, NOT raw bytes -
        # passing bytes raises in the real SDK and silently no-ops the copy.
        contents = call.args[1] if len(call.args) > 1 else call.kwargs.get("contents")
        assert hasattr(contents, "read"), (
            "upload must receive a file-like object (io.BytesIO), not raw bytes"
        )

    with Session(engine) as session:
        new_mv = session.exec(
            select(ModelVersion).where(ModelVersion.business_id == new_id)
        ).first()
        arts = session.exec(
            select(RunArtifact).where(
                RunArtifact.model_version_id == new_mv.id
            )
        ).all()
        types = {a.artifact_type for a in arts}
        # Story-5 typing flows through the indexer on the copied bundle.
        assert "model_json" in types
        assert "vibes_text" in types


def test_kickstarted_version_copies_no_install_state_and_reads_its_artifacts(engine):
    """The source is installed in ``test_cat``; the kickstarted version is
    installed nowhere (no install catalog, no install row), and its artifacts
    resolve to the metamodel catalog the kickstart copied them into."""
    from vibe_modeling.backend.core._catalogs import resolve_version_volume_catalog
    from vibe_modeling.backend.db_models import ModelVersionInstall

    _seed_agent_config(engine, deployment_catalog="deploy_cat")
    industry_id, src_version_id = _seed_industry(engine)
    with Session(engine) as session:
        src = session.get(ModelVersion, src_version_id)
        src.deployment_status = "deployed"
        session.add(src)
        session.commit()
    ws = _ws_with_artifacts(["model.json"])

    with Session(engine) as session:
        new_business = kickstart_from_industry(
            session, ws, source_industry_id=industry_id, source_version=1, new_name="Delta Inc",
        )
        session.commit()
        new_id = new_business.id

    with Session(engine) as session:
        new_mv = session.exec(select(ModelVersion).where(ModelVersion.business_id == new_id)).one()
        assert (new_mv.deployment_status, new_mv.uc_catalog, new_mv.files_catalog) == ("draft", "", "deploy_cat")
        assert session.exec(
            select(ModelVersionInstall).where(ModelVersionInstall.version_id == new_mv.id)
        ).all() == []
        assert resolve_version_volume_catalog(new_mv, session) == "deploy_cat"
        arts = session.exec(select(RunArtifact).where(RunArtifact.model_version_id == new_mv.id)).all()
        assert arts and all(a.file_path.startswith("/Volumes/deploy_cat/") for a in arts)


def test_copy_version_files_ignores_src_uc_catalog(engine):
    """Regression: ``_copy_version_files`` uses the passed-in deployment
    catalog for BOTH src and dest dirs, never a per-model install catalog. It
    is pure Volume I/O (no DB), so it takes no session."""
    from vibe_modeling.backend.services.industry_kickstart import (
        _copy_version_files,
    )

    ws = _ws_with_artifacts(["model.json"])
    dest_dir, copied = _copy_version_files(
        ws,
        catalog="deploy_cat",
        src_business_name="Retail Industry",
        src_version=1,
        new_business_name="Delta Co",
        new_version=2,
        scope="ecm",
    )
    assert copied == 1
    # Neither src nor dest path used a source install catalog like 'test_cat'.
    used_paths = [c.args[0] for c in ws.files.download.call_args_list]
    used_paths += [c.args[0] for c in ws.files.upload.call_args_list]
    assert used_paths, "expected at least one Volume path"
    assert all("/test_cat/" not in p for p in used_paths)
    assert all("/deploy_cat/" in p for p in used_paths)
    assert dest_dir.startswith("/Volumes/deploy_cat/")


def test_copy_version_files_one_bad_file_does_not_abort_others():
    """A single uncopyable file is skipped (logged, not raised) - every other
    file in the batch still copies. This must hold under the bounded
    thread-pool parallelization, matching the pre-parallel sequential
    semantics."""
    from vibe_modeling.backend.services.industry_kickstart import (
        _copy_version_files,
    )

    rel_files = [f"file_{i}.txt" for i in range(10)]
    ws = _ws_with_artifacts(rel_files)
    bad_rel = "file_3.txt"

    def flaky_download(path):
        if path.endswith(bad_rel):
            raise RuntimeError("simulated Volume read failure")
        body = MagicMock()
        body.contents.read.return_value = b"<bytes>"
        return body

    ws.files.download.side_effect = flaky_download

    dest_dir, copied = _copy_version_files(
        ws,
        catalog="deploy_cat",
        src_business_name="Retail Industry",
        src_version=1,
        new_business_name="Delta Co",
        new_version=2,
        scope="ecm",
    )

    assert copied == len(rel_files) - 1
    uploaded_paths = [c.args[0] for c in ws.files.upload.call_args_list]
    assert not any(p.endswith(bad_rel) for p in uploaded_paths)


def test_copy_version_files_worker_count_is_bounded():
    """The per-file download+upload copy runs on a bounded worker pool -
    observed concurrency must never exceed
    ``volume_copy.COPY_WORKER_COUNT``, even with more files in
    flight than workers available. A regression to an unbounded pool (one
    thread per file) would show up here as concurrency exceeding the bound."""
    import threading

    from vibe_modeling.backend.services import volume_copy as ik
    from vibe_modeling.backend.services.industry_kickstart import (
        _copy_version_files,
    )

    rel_files = [f"file_{i}.txt" for i in range(3 * ik.COPY_WORKER_COUNT)]
    ws = _ws_with_artifacts(rel_files)

    lock = threading.Lock()
    in_flight = 0
    peak = 0

    def slow_download(_path):
        nonlocal in_flight, peak
        with lock:
            in_flight += 1
            peak = max(peak, in_flight)
        try:
            time.sleep(0.02)
        finally:
            with lock:
                in_flight -= 1
        body = MagicMock()
        body.contents.read.return_value = b"<bytes>"
        return body

    ws.files.download.side_effect = slow_download

    _, copied = _copy_version_files(
        ws,
        catalog="deploy_cat",
        src_business_name="Retail Industry",
        src_version=1,
        new_business_name="Delta Co",
        new_version=2,
        scope="ecm",
    )

    assert copied == len(rel_files)
    assert peak <= ik.COPY_WORKER_COUNT, (
        f"observed concurrency {peak} exceeded the bound "
        f"{ik.COPY_WORKER_COUNT}"
    )
    assert peak > 1, "expected the copy to actually overlap, not run serially"


def test_kickstart_no_open_transaction_during_volume_copy(engine, monkeypatch):
    """The multi-minute Volume artifact copy MUST run with the Postgres
    transaction closed - a held transaction trips Lakebase's
    idle-in-transaction timeout and 500s an otherwise-complete kickstart."""
    import vibe_modeling.backend.services.industry_kickstart as k

    industry_id, _ = _seed_industry(engine)
    seen: list[bool] = []

    with Session(engine) as session:
        def _spy(ws, **kwargs):
            seen.append(session.in_transaction())
            return "", 0

        monkeypatch.setattr(k, "_copy_version_files", _spy)
        kickstart_from_industry(
            session, MagicMock(),
            source_industry_id=industry_id, source_version=1,
            new_name="NoTxn Co", copy_inputs=False,
        )

    assert seen, "the Volume copy phase should run at least once"
    assert all(v is False for v in seen), (
        "structure must be committed before the Volume copy - no open "
        "transaction may be held across the slow I/O"
    )


def test_kickstart_post_commit_attribute_touch_transaction_leak(engine, monkeypatch):
    """Regression for the live pg_stat_activity leak traced against a real
    kickstart run: SQLAlchemy's default ``expire_on_commit=True`` marks
    every ORM object attached to the background session as expired at each
    of ``_run_kickstart_background``'s several commits. If anything touches
    an attribute of one of those objects (e.g. building the next progress
    message off ``run``) before the next slow call, the resulting refresh
    SELECT autobegins a transaction that idles across it - only closing at
    the FOLLOWING commit. ``expire_on_commit=False`` on the background
    session_factory (``routes/industry_models.py``) is the fix. This test
    drives the identical scenario through both session shapes to prove the
    leak is real on the (pre-fix) default and gone with the fix - a bare
    ``session.in_transaction()`` check right after a commit, with no
    intervening attribute touch, would pass either way and miss this.
    """
    import vibe_modeling.backend.services.industry_kickstart as k

    industry_id, _ = _seed_industry(engine)

    def _run_with_session_kwargs(name: str, **session_kwargs) -> list[bool]:
        seen: list[bool] = []
        run_id_holder: dict = {}
        orig_set_run = k._set_run

        def _capture_run_id(session_arg, run_id, **fields):
            run_id_holder["id"] = run_id
            return orig_set_run(session_arg, run_id, **fields)

        def _touch_then_check(ws, **kwargs):
            # Stand-in for the shape the live trace caught: an ORM object
            # attached to this session (`run`, loaded by an earlier
            # `_set_run` call and expired by its commit) gets an attribute
            # read right before the next slow call proceeds.
            run_row = session.get(Run, run_id_holder["id"])
            _ = run_row.progress_message
            seen.append(session.in_transaction())
            return "", 0

        with Session(engine, **session_kwargs) as session:
            monkeypatch.setattr(k, "_set_run", _capture_run_id)
            monkeypatch.setattr(k, "_copy_version_files", _touch_then_check)
            k.kickstart_from_industry(
                session, MagicMock(),
                source_industry_id=industry_id, source_version=1,
                new_name=name, copy_inputs=False,
            )
        return seen

    # Pre-fix shape: default expire_on_commit=True - the touch re-opens a
    # transaction that is NOT closed before the slow call proceeds.
    leaked = _run_with_session_kwargs("TouchLeak Co")
    assert leaked and any(v is True for v in leaked), (
        "expected the default expire_on_commit=True session to reproduce "
        "the leak when an ORM attribute is touched after a commit - if "
        "this fails, the regression trap below is not exercising anything"
    )

    # Fixed shape: matches routes/industry_models.py's background
    # session_factory - the same touch must NOT leave a transaction open.
    safe = _run_with_session_kwargs("TouchSafe Co", expire_on_commit=False)
    assert safe and all(v is False for v in safe), (
        "expire_on_commit=False must prevent the post-commit attribute "
        "touch from re-opening a transaction across the slow call"
    )


def test_kickstart_endpoint_request_session_closed_before_background_task(
    client, engine, monkeypatch,
):
    """Regression for the live pg_stat_activity leak traced on a THIRD
    kickstart run: ``SELECT businesses WHERE id=$1``, opened ~1s into the
    request, idle for the whole background window, clearing only at run
    completion.

    FastAPI does not tear down a ``yield``-based dependency (closing the
    request-scoped ``Depends(Dependencies.Session)``) until AFTER any task
    registered via ``BackgroundTasks.add_task`` during the request has
    completed - Starlette runs background tasks from inside
    ``Response.__call__``, itself called inside the same ``AsyncExitStack``
    that owns the dependency's post-yield teardown
    (``fastapi.routing.request_response``). The kickstart route schedules a
    multi-minute background copy via ``add_task`` - if anything then reads
    from the request session afterward (an explicit refresh, or an implicit
    one from touching an expired ORM attribute during response
    serialization), that read's transaction sits idle-in-transaction for the
    entire background window, only clearing when the session finally closes.

    ``TestClient`` runs background tasks synchronously as part of
    ``client.post(...)``, which makes this directly assertable: by the
    moment the scheduled background task starts running, the request
    session must already have no open transaction.
    """
    from vibe_modeling.backend.core.lakebase import _LakebaseDependency
    import vibe_modeling.backend.routes.industry_models as industry_models_mod

    with Session(engine) as session:
        industry = Business(
            name="TxnClose Industry",
            industry_alignment="Retail",
            description="A retail industry template.",
            kind="industry",
        )
        session.add(industry)
        session.flush()
        mv = ModelVersion(
            business_id=industry.id, version=1, scope="ecm",
            status="completed", uc_catalog="test_cat",
        )
        session.add(mv)
        session.flush()
        ModelSyncService(session).sync_from_model_json(mv.id, SAMPLE_MODEL)
        session.commit()
        industry_id = industry.id

    # Wrap whatever generator the `client` fixture already registered for
    # `Dependencies.Session`, so the actual request-scoped session object is
    # captured regardless of which module object owns it.
    captured_sessions: list[Session] = []
    orig_override = client.app.dependency_overrides[_LakebaseDependency.__call__]

    def _spying_override():
        gen = orig_override()
        request_session = next(gen)
        captured_sessions.append(request_session)
        try:
            yield request_session
        finally:
            try:
                next(gen)
            except StopIteration:
                pass

    client.app.dependency_overrides[_LakebaseDependency.__call__] = _spying_override

    in_txn_when_bg_starts: list[bool] = []
    orig_bg = industry_models_mod.run_kickstart_artifact_copy_bg

    def _spying_bg(session_factory, ws, plan):
        in_txn_when_bg_starts.append(captured_sessions[-1].in_transaction())
        return orig_bg(session_factory, ws, plan)

    monkeypatch.setattr(
        industry_models_mod, "run_kickstart_artifact_copy_bg", _spying_bg,
    )

    resp = client.post(
        f"/api/industry-models/{industry_id}/kickstart",
        json={"source_version": 1, "new_name": "TxnClose Business"},
    )

    assert resp.status_code == 200, resp.text
    assert in_txn_when_bg_starts, "the background task should have run at least once"
    assert all(v is False for v in in_txn_when_bg_starts), (
        "the request session had an open transaction when the scheduled "
        "background task started running - this is exactly the "
        "idle-in-transaction leak traced live via pg_stat_activity "
        "(SELECT businesses WHERE id=$1, held open across the entire "
        "background window)"
    )


# --- Item 2: _metamodel seed on kickstart ---------------------------------


def _seed_agent_config_full(engine, *, catalog="deploy_cat", warehouse="wh-1"):
    with Session(engine) as session:
        session.add(AgentConfig(deployment_catalog=catalog, warehouse_id=warehouse))
        session.commit()


def test_kickstart_seeds_metamodel_per_version(engine, monkeypatch):
    """write_metamodel is invoked once per created scope/version with the
    resolved deployment catalog, business_name=new_name, version=new_mv.version."""
    _seed_agent_config_full(engine, catalog="deploy_cat", warehouse="wh-1")
    industry_id, _ = _seed_industry(engine)  # single ECM v1
    ws = _ws_with_artifacts([])

    calls = []

    def _spy(ws_arg, **kwargs):
        calls.append(kwargs)
        return {"business": 1, "domain": 0, "product": 0, "attribute": 0, "errors": []}

    # seed_metamodel_one (the shared helper) resolves write_metamodel from its
    # own module, so patch it there.
    monkeypatch.setattr(
        "vibe_modeling.backend.services.import_metamodel_writer.write_metamodel", _spy
    )

    with Session(engine) as session:
        kickstart_from_industry(
            session, ws,
            source_industry_id=industry_id,
            source_version=1,
            new_name="Seeded Co",
        )

    assert len(calls) == 1
    kw = calls[0]
    assert kw["catalog"] == "deploy_cat"
    assert kw["warehouse_id"] == "wh-1"
    assert kw["business_name"] == "Seeded Co"
    assert kw["scope"] == "ecm"
    assert kw["version"] == 1
    # The seed model_json is the exported clone structure.
    assert "domains" in (kw["model_json"].get("model") or kw["model_json"])


def test_kickstart_skips_seed_when_unconfigured(engine, monkeypatch):
    """No catalog/warehouse configured → seed skipped, no write, no raise."""
    industry_id, _ = _seed_industry(engine)  # no AgentConfig seeded
    ws = _ws_with_artifacts([])
    calls = []
    monkeypatch.setattr(
        "vibe_modeling.backend.services.import_metamodel_writer.write_metamodel",
        lambda *a, **k: calls.append(k),
    )
    with Session(engine) as session:
        kickstart_from_industry(
            session, ws,
            source_industry_id=industry_id,
            source_version=1,
            new_name="Unconfigured Co",
        )
    assert calls == []


def test_kickstart_seed_feeds_real_export_through_writer(engine):
    """End-to-end: a REAL export_model_json dict flows through write_metamodel's
    payload parsing (only the SQL execution is mocked). Proves the export→seed
    shape contract, not a hand-mocked dict."""
    _seed_agent_config_full(engine, catalog="deploy_cat", warehouse="wh-1")
    industry_id, _ = _seed_industry(engine)
    ws = _ws_with_artifacts([])
    # The registry tables exist (with the agent's columns), so the seed runs
    # no DDL; every statement succeeds.
    ws.tables.get.return_value = SimpleNamespace(columns=[
        SimpleNamespace(name=c) for c, _ in agent_registry_columns("business")
    ])
    stmt = MagicMock()
    resp = MagicMock()
    resp.status.error = None
    resp.status.state = "SUCCEEDED"
    stmt.execute_statement.return_value = resp
    ws.statement_execution = stmt

    with Session(engine) as session:
        kickstart_from_industry(
            session, ws,
            source_industry_id=industry_id,
            source_version=1,
            new_name="RealExport Co",
        )

    # The business INSERT + domain/product/attribute batches all executed.
    assert stmt.execute_statement.call_count >= 1
    stmts = " ".join(c.kwargs.get("statement", "") for c in stmt.execute_statement.call_args_list)
    assert "INSERT INTO `deploy_cat`.`_metamodel`.`business`" in stmts
    assert "CREATE TABLE" not in stmts
    assert "realexport_co" in stmts.lower()


# --- Item 3: VibeInput copy + re-anchor -----------------------------------


def _src_element_ids(session, src_version_id, *, domain, product, attribute):
    dom = session.exec(
        select(Domain).where(Domain.version_id == src_version_id, Domain.name == domain)
    ).first()
    prod = session.exec(
        select(Product).where(
            Product.version_id == src_version_id,
            Product.domain_id == dom.id,
            Product.name == product,
        )
    ).first()
    attr = session.exec(
        select(Attribute).where(
            Attribute.product_id == prod.id, Attribute.name == attribute
        )
    ).first()
    return dom.id, prod.id, attr.id


def _seed_source_inputs(engine, industry_id, src_version_id):
    """Add a user feedback input anchored at sales.order.order_id and an
    agent next-vibe input anchored model-wide, both on the source version."""
    with Session(engine) as session:
        dom_id, prod_id, attr_id = _src_element_ids(
            session, src_version_id, domain="sales", product="order", attribute="order_id"
        )
        fb = VibeInput(
            business_id=industry_id, origin="user", author="alice@example.com",
            text="Fix the order grain.", priority="high", status="active",
            selected_for_run=True, consumed=True,
        )
        session.add(fb)
        session.flush()
        session.add(VibeInputContextLink(
            input_id=fb.id, version_id=src_version_id,
            domain_id=dom_id, product_id=prod_id, attribute_id=attr_id,
            is_origin=True,
        ))
        nv = VibeInput(
            business_id=industry_id, origin="agent_next_vibe", author="",
            text="Consider a returns domain.", category="static_analysis",
            priority="medium", confidence_score=0.8, status="active",
        )
        session.add(nv)
        session.flush()
        session.add(VibeInputContextLink(
            input_id=nv.id, version_id=src_version_id, is_origin=False,
        ))
        session.commit()


def test_kickstart_copies_and_reanchors_inputs(engine):
    """Phase 0 copies ``origin=user`` feedback and re-anchors it. It does NOT
    blindly copy the source's ``agent_next_vibe`` rows — with no next-vibes
    artifact in this test's Volume (``_ws_with_artifacts([])``), the new
    version legitimately gets none; see
    ``test_kickstart_materializes_next_vibes_backlog_from_own_artifact`` for
    the artifact-backed materialization path (Phase 2)."""
    industry_id, src_version_id = _seed_industry(engine)
    _seed_source_inputs(engine, industry_id, src_version_id)
    ws = _ws_with_artifacts([])

    with Session(engine) as session:
        nb = kickstart_from_industry(
            session, ws, source_industry_id=industry_id,
            source_version=1, new_name="Inherit Co", copy_inputs=True,
        )
        new_id = nb.id

    with Session(engine) as session:
        new_inputs = session.exec(
            select(VibeInput).where(VibeInput.business_id == new_id)
        ).all()
        assert len(new_inputs) == 1
        by_origin = {i.origin: i for i in new_inputs}
        assert set(by_origin) == {"user"}

        fb = by_origin["user"]
        # Preserved: submitter, text, is_origin flag; reset: selected/consumed.
        assert fb.author == "alice@example.com"
        assert fb.text == "Fix the order grain."
        assert fb.selected_for_run is False
        assert fb.consumed is False

        # The context link points at the NEW version's element ids.
        new_mv = session.exec(
            select(ModelVersion).where(ModelVersion.business_id == new_id)
        ).first()
        fb_links = session.exec(
            select(VibeInputContextLink).where(VibeInputContextLink.input_id == fb.id)
        ).all()
        assert len(fb_links) == 1
        link = fb_links[0]
        assert link.version_id == new_mv.id
        assert link.is_origin is True
        # Resolve the NEW element ids and confirm the link points at them,
        # NOT the source ids.
        new_dom, new_prod, new_attr = _src_element_ids(
            session, new_mv.id, domain="sales", product="order", attribute="order_id"
        )
        src_dom, src_prod, src_attr = _src_element_ids(
            session, src_version_id, domain="sales", product="order", attribute="order_id"
        )
        assert link.domain_id == new_dom and link.domain_id != src_dom
        assert link.product_id == new_prod and link.product_id != src_prod
        assert link.attribute_id == new_attr and link.attribute_id != src_attr
        assert link.needs_link_review is False


def test_kickstart_copy_inputs_false_copies_nothing(engine):
    industry_id, src_version_id = _seed_industry(engine)
    _seed_source_inputs(engine, industry_id, src_version_id)
    ws = _ws_with_artifacts([])
    with Session(engine) as session:
        nb = kickstart_from_industry(
            session, ws, source_industry_id=industry_id,
            source_version=1, new_name="Clean Slate Co", copy_inputs=False,
        )
        new_id = nb.id
    with Session(engine) as session:
        new_inputs = session.exec(
            select(VibeInput).where(VibeInput.business_id == new_id)
        ).all()
        assert new_inputs == []


_NEXT_VIBES_TXT = (
    "**Model Quality Score: 76/100**\n\n"
    "**Static Analysis Findings (1 actionable):**\n"
    "  - [SA:denormalized_natural_key] Domain 'sales' table 'order' drifts\n\n"
    "**PRIORITY 1 - remove_fk: sales.order** - remove the stale FK on order\n\n"
    "Deterministic score: 76/100\n"
)


def _ws_with_next_vibes_artifact(text: str = _NEXT_VIBES_TXT) -> MagicMock:
    """Mock ws whose Volume dir has one ``vibes/next_vibes.txt`` file, keyed
    by path SUFFIX (not the exact absolute path) so the same real content is
    served whether the caller reads the source dir (Phase 2's copy) or the
    destination dir (the read the copy enables) - mirroring a real
    download-then-reread round trip without needing to compute the exact
    catalog/business/version path the test doesn't otherwise care about."""
    ws = MagicMock()
    entry = MagicMock()
    entry.name = "vibes/next_vibes.txt"
    entry.is_directory = False
    entry.file_size = None
    ws.files.list_directory_contents.return_value = [entry]

    def download(path):
        if path.endswith("vibes/next_vibes.txt"):
            resp = MagicMock()
            resp.contents.read.return_value = text.encode()
            return resp
        raise FileNotFoundError(path)

    ws.files.download.side_effect = download
    ws.files.upload = MagicMock()
    return ws


def test_kickstart_materializes_next_vibes_backlog_from_own_artifact(engine):
    """Bug fix regression (live-verification finding): the agent_next_vibe
    backlog for a kickstarted version comes from Phase 2 materializing the
    NEW version's own (now-copied) next-vibes artifact via
    ``model_sync.ingest_next_vibes`` — the same single producer every other
    entry point uses — NOT from a naive row copy in Phase 0. Re-ingesting the
    SAME artifact against the SAME (new) version_id — what a later resync
    does — must be a no-op, not a duplicate."""
    _seed_agent_config(engine, deployment_catalog="deploy_cat")
    industry_id, src_version_id = _seed_industry(engine)
    ws = _ws_with_next_vibes_artifact()

    with Session(engine) as session:
        nb = kickstart_from_industry(
            session, ws, source_industry_id=industry_id,
            source_version=1, new_name="Backlog Co", copy_inputs=True,
        )
        new_id = nb.id

    with Session(engine) as session:
        new_mv = session.exec(
            select(ModelVersion).where(ModelVersion.business_id == new_id)
        ).first()
        rows = session.exec(
            select(VibeInput).where(
                VibeInput.business_id == new_id,
                VibeInput.origin == "agent_next_vibe",
            )
        ).all()
        # 1 static-analysis finding + 1 PRIORITY directive.
        assert len(rows) == 2
        first_ids = {r.id for r in rows}

    # Simulate a resync: re-ingest the SAME artifact against the SAME
    # version_id. This is exactly what force_resync_version's call into
    # _capture_run_metadata does after clear_version_data (which does not
    # touch VibeInput rows) — it must recompute the SAME uuid5 ids and
    # no-op, not double the backlog.
    from vibe_modeling.backend.model_sync import ingest_next_vibes as _ingest

    with Session(engine) as session:
        n = _ingest(
            ws, session,
            version_dir=f"/Volumes/deploy_cat/_metamodel/vol_root/business/backlog_co/ecm_v1",
            version_id=new_mv.id,
            business_id=new_id,
        )
        session.commit()
        assert n == 0, "re-ingesting the same artifact must not add rows"
        rows_after = session.exec(
            select(VibeInput).where(
                VibeInput.business_id == new_id,
                VibeInput.origin == "agent_next_vibe",
            )
        ).all()
        assert len(rows_after) == 2
        assert {r.id for r in rows_after} == first_ids


def test_kickstart_endpoint_rejects_sub_scope_before_copy(client, engine):
    """whole_model=False 400s regardless of copy_inputs; the copy path is
    never reached (no inputs, no new business)."""
    industry_id, src_version_id = _seed_industry(engine)
    _seed_source_inputs(engine, industry_id, src_version_id)
    resp = client.post(
        f"/api/industry-models/{industry_id}/kickstart",
        json={"source_version": 1, "new_name": "X", "whole_model": False,
              "copy_inputs": True},
    )
    assert resp.status_code == 400
    with Session(engine) as session:
        # No new business, hence no copied inputs.
        biz = session.exec(select(Business).where(Business.name == "X")).all()
        assert biz == []


def test_kickstart_rejects_blank_description_when_industry_also_blank(engine):
    """The industry-description fallback only rescues an empty
    ``new_description`` when the source industry itself has a non-blank
    description. When BOTH are blank (an industry seeded from a
    description-less ``model.json``), kickstart must reject the request
    with ``KickstartDescriptionRequired`` - the same
    ``validate_business_description`` contract ``BusinessIn.description``
    enforces - rather than creating a business with an empty description
    that only fails a minute into the next run's fail-fast preflight."""
    industry_id, _ = _seed_industry_blank_description(engine)
    ws = _ws_with_artifacts([])

    with Session(engine) as session:
        with pytest.raises(KickstartDescriptionRequired) as exc:
            kickstart_from_industry(
                session, ws,
                source_industry_id=industry_id,
                source_version=1,
                new_name="Should Not Exist Co",
            )
    assert "description must not be empty or whitespace-only" in str(exc.value)

    with Session(engine) as session:
        assert session.exec(
            select(Business).where(Business.name == "Should Not Exist Co")
        ).all() == []


def test_kickstart_rejects_non_industry_source(engine, seed_business):
    ws = _ws_with_artifacts([])
    with Session(engine) as session:
        with pytest.raises(KickstartError) as exc:
            kickstart_from_industry(
                session, ws,
                source_industry_id=seed_business,  # kind='business'
                source_version=1,
                new_name="Nope",
            )
    assert "industry" in str(exc.value).lower()


def test_kickstart_rejects_missing_version(engine):
    industry_id, _ = _seed_industry(engine)
    ws = _ws_with_artifacts([])
    with Session(engine) as session:
        with pytest.raises(KickstartError) as exc:
            kickstart_from_industry(
                session, ws,
                source_industry_id=industry_id,
                source_version=99,
                new_name="Nope",
            )
    assert "version" in str(exc.value).lower()


# --- Endpoint -------------------------------------------------------------


def test_kickstart_endpoint_creates_business(client, engine):
    industry_id, _ = _seed_industry(engine)
    resp = client.post(
        f"/api/industry-models/{industry_id}/kickstart",
        json={"source_version": 1, "new_name": "Endpoint Co"},
    )
    assert resp.status_code == 200, resp.text
    body = resp.json()["business"]
    assert body["kind"] == "business"
    assert body["source_industry_id"] == industry_id
    assert body["source_version"] == 1


def test_kickstart_endpoint_rejects_sub_scope(client, engine):
    industry_id, _ = _seed_industry(engine)
    resp = client.post(
        f"/api/industry-models/{industry_id}/kickstart",
        json={"source_version": 1, "new_name": "X", "whole_model": False},
    )
    assert resp.status_code == 400
    assert "whole-model" in resp.json()["detail"].lower()


def test_kickstart_endpoint_422_when_industry_description_also_blank(client, engine):
    """Request-time backstop for the same case the run-preflight gate
    (``business_description_blocker_for_intent``) catches later: a kickstart
    with no ``new_description`` from an industry that itself has a blank
    description must 422 with the SAME shared validator/message the
    create-business path (``BusinessIn.description`` /
    ``validate_business_description``) uses for a missing description - not
    a business created empty that only fails deep in the run pipeline."""
    industry_id, _ = _seed_industry_blank_description(engine)

    resp = client.post(
        f"/api/industry-models/{industry_id}/kickstart",
        json={"source_version": 1, "new_name": "Blank Desc Co", "new_description": ""},
    )
    assert resp.status_code == 422, resp.text
    kickstart_detail = resp.json()["detail"]
    assert "description must not be empty or whitespace-only" in kickstart_detail

    # The create-business path raises the SAME shared validator
    # (validate_business_description) for a whitespace-only description -
    # same underlying message, proving one check backs both surfaces.
    create_resp = client.post(
        "/api/businesses",
        json={"name": "Whatever Co", "description": "   "},
    )
    assert create_resp.status_code == 422, create_resp.text
    create_detail = create_resp.json()["detail"]
    create_msg = (
        create_detail[0]["msg"] if isinstance(create_detail, list) else create_detail
    )
    assert "description must not be empty or whitespace-only" in create_msg

    with Session(engine) as session:
        assert session.exec(
            select(Business).where(Business.name == "Blank Desc Co")
        ).all() == []


def test_kickstart_endpoint_404_for_bad_source(client):
    resp = client.post(
        "/api/industry-models/does-not-exist/kickstart",
        json={"source_version": 1, "new_name": "X"},
    )
    assert resp.status_code == 404
    assert "not found" in resp.json()["detail"].lower()


# --- Fast return / phase-0 deferral ---------------------------------------


def test_kickstart_with_schedule_copy_returns_before_tree_copy(engine):
    """With ``schedule_copy`` set, ``kickstart_from_industry`` returns having
    created ONLY the Business + running Run - no ModelVersion, no tree, no
    VibeInputs. The handed-off plan carries source ids/scopes/versions (not
    already-copied versions) so phase 0 can build them later."""
    industry_id, src_version_id = _seed_industry(engine)
    _seed_source_inputs(engine, industry_id, src_version_id)
    ws = _ws_with_artifacts([])

    plans = []
    with Session(engine) as session:
        new_business = kickstart_from_industry(
            session, ws,
            source_industry_id=industry_id,
            source_version=1,
            new_name="Deferred Co",
            schedule_copy=plans.append,
        )
        new_id = new_business.id

    assert len(plans) == 1
    plan = plans[0]
    assert plan.new_business_id == new_id
    assert plan.source_business_id == industry_id
    assert plan.copy_inputs is True
    assert len(plan.source_specs) == 1
    assert plan.source_specs[0].src_mv_id == src_version_id
    assert plan.source_specs[0].scope == "ecm"
    # Phase 0 has NOT run yet - seeds/copy_specs are still empty.
    assert plan.seeds == []
    assert plan.copy_specs == []

    with Session(engine) as session:
        biz = session.get(Business, new_id)
        assert biz.kind == "business"
        assert session.exec(
            select(ModelVersion).where(ModelVersion.business_id == new_id)
        ).all() == []
        assert session.exec(
            select(VibeInput).where(VibeInput.business_id == new_id)
        ).all() == []

        run = session.exec(select(Run).where(Run.business_id == new_id)).first()
        assert run.status == "running"
        assert run.version_id is None


def test_kickstart_phase0_failure_marks_run_failed_no_orphan_version(engine, monkeypatch):
    """A phase-0 failure (mocked ``copy_model_tree`` raises) marks the audit
    Run ``failed`` and leaves no orphan ModelVersion for the business - the
    Business row itself survives as the audit/retry anchor."""
    import vibe_modeling.backend.services.industry_kickstart as k

    industry_id, _ = _seed_industry(engine)
    ws = _ws_with_artifacts([])

    def _boom(session, *, source_version_id, target_version_id):
        raise RuntimeError("tree copy exploded")

    monkeypatch.setattr(k, "copy_model_tree", _boom)

    with Session(engine) as session:
        new_business = kickstart_from_industry(
            session, ws,
            source_industry_id=industry_id,
            source_version=1,
            new_name="Phase0 Fail Co",
        )
        new_id = new_business.id

    with Session(engine) as session:
        # The business survives (audit/retry anchor)...
        biz = session.get(Business, new_id)
        assert biz is not None
        # ...but no ModelVersion for it does.
        assert session.exec(
            select(ModelVersion).where(ModelVersion.business_id == new_id)
        ).all() == []

        run = session.exec(select(Run).where(Run.business_id == new_id)).first()
        assert run.status == "failed"
        assert "tree copy exploded" in run.error_message
        assert run.version_id is None


def test_kickstart_phase0_failure_leaves_no_orphan_vibe_input(engine, monkeypatch):
    """A phase-0 failure during the VibeInput copy step (which runs AFTER the
    tree copy, in the SAME transaction) rolls back the tree copy too - no
    partially-created ModelVersion/tree survives just because it came first."""
    import vibe_modeling.backend.services.industry_kickstart as k

    industry_id, src_version_id = _seed_industry(engine)
    _seed_source_inputs(engine, industry_id, src_version_id)
    ws = _ws_with_artifacts([])

    def _boom(session, *, source_business_id, new_business_id, version_map):
        raise RuntimeError("vibe input copy exploded")

    monkeypatch.setattr(k, "_copy_vibe_inputs", _boom)

    with Session(engine) as session:
        new_business = kickstart_from_industry(
            session, ws,
            source_industry_id=industry_id,
            source_version=1,
            new_name="Phase0 Input Fail Co",
            copy_inputs=True,
        )
        new_id = new_business.id

    with Session(engine) as session:
        assert session.get(Business, new_id) is not None
        assert session.exec(
            select(ModelVersion).where(ModelVersion.business_id == new_id)
        ).all() == []
        run = session.exec(select(Run).where(Run.business_id == new_id)).first()
        assert run.status == "failed"
        assert "vibe input copy exploded" in run.error_message


def test_kickstart_phase0_sets_run_version_id_on_success(engine):
    """On a successful (inline) kickstart, the audit Run's version_id ends up
    pointing at one of the new business's versions - set by phase 0, not at
    Run-creation time (when no version exists yet)."""
    industry_id, _ = _seed_industry(engine)
    ws = _ws_with_artifacts([])

    with Session(engine) as session:
        new_business = kickstart_from_industry(
            session, ws,
            source_industry_id=industry_id,
            source_version=1,
            new_name="VersionId Co",
        )
        new_id = new_business.id

    with Session(engine) as session:
        new_vids = {
            v.id for v in session.exec(
                select(ModelVersion).where(ModelVersion.business_id == new_id)
            ).all()
        }
        run = session.exec(select(Run).where(Run.business_id == new_id)).first()
        assert run.version_id in new_vids


def test_kickstart_active_run_gate_blocks_iterate_during_background_window(
    client_with_agent, engine, seed_business_with_version,
):
    """The active-run gate (business_id + status in {pending,running,stale})
    keys off the Run row alone, created BEFORE phase 0 - so it still blocks
    a vibe-iterate attempt on the SAME business while phase 0's (now-longer,
    since it includes the tree copy) background window is in flight."""
    from datetime import datetime, timezone

    business_id = seed_business_with_version
    with Session(engine) as s:
        s.add(Run(
            business_id=business_id,
            intent="kickstart-from-industry",
            status="running",
            progress_percent=0,
            started_at=datetime.now(timezone.utc),
        ))
        s.commit()

    # A configured agent: a missing prerequisite would answer before the
    # active run (the pre-flight's level 1 runs first).
    resp = client_with_agent.post(f"/api/businesses/{business_id}/runs", json={
        "intent": "vibe-iterate",
        "catalog": "my_catalog",
        "vibe_instructions": "Add HR tables",
        "business_context_path": "/Volumes/test/ctx/vibes/ctx.json",
    })
    assert resp.status_code == 409
    assert "active run" in resp.json()["detail"].lower()


# --- Phase 1 transaction shape ---------------------------------------------


def test_kickstart_no_open_transaction_during_metamodel_seed(engine, monkeypatch):
    """The _metamodel seed (phase 1) is external SQL-warehouse I/O and MUST
    run with the Postgres transaction closed, same discipline as the Volume
    copy (phase 2) - a held transaction across a multi-second/minute
    warehouse write trips Lakebase's idle-in-transaction timeout."""
    import vibe_modeling.backend.services.industry_kickstart as k

    _seed_agent_config_full(engine, catalog="deploy_cat", warehouse="wh-1")
    industry_id, _ = _seed_industry(engine)
    ws = _ws_with_artifacts([])
    seen: list[bool] = []

    with Session(engine) as session:
        def _spy(ws_arg, **kwargs):
            seen.append(session.in_transaction())
            return {"business": 1, "domain": 0, "product": 0, "attribute": 0, "errors": []}

        monkeypatch.setattr(k, "seed_metamodel_one", _spy)
        kickstart_from_industry(
            session, ws,
            source_industry_id=industry_id, source_version=1,
            new_name="NoTxnSeed Co", copy_inputs=False,
        )

    assert seen, "the _metamodel seed phase should run at least once"
    assert all(v is False for v in seen), (
        "no Postgres transaction may be held open across the external "
        "warehouse write"
    )


def test_kickstart_post_commit_attribute_touch_transaction_leak_metamodel_seed(
    engine, monkeypatch,
):
    """Same regression as ``test_kickstart_post_commit_attribute_touch_
    transaction_leak``, exercised on phase 1 (the _metamodel seed) instead
    of phase 2 (Volume copy) - both are slow external calls the background
    session must not hold a transaction across, even when an ORM attribute
    gets touched right beforehand."""
    import vibe_modeling.backend.services.industry_kickstart as k

    _seed_agent_config_full(engine, catalog="deploy_cat", warehouse="wh-1")
    industry_id, _ = _seed_industry(engine)

    def _run_with_session_kwargs(name: str, **session_kwargs) -> list[bool]:
        ws = _ws_with_artifacts([])
        seen: list[bool] = []
        run_id_holder: dict = {}
        orig_set_run = k._set_run

        def _capture_run_id(session_arg, run_id, **fields):
            run_id_holder["id"] = run_id
            return orig_set_run(session_arg, run_id, **fields)

        def _touch_then_check(ws_arg, **kwargs):
            run_row = session.get(Run, run_id_holder["id"])
            _ = run_row.progress_message
            seen.append(session.in_transaction())
            return {"business": 1, "domain": 0, "product": 0, "attribute": 0, "errors": []}

        with Session(engine, **session_kwargs) as session:
            monkeypatch.setattr(k, "_set_run", _capture_run_id)
            monkeypatch.setattr(k, "seed_metamodel_one", _touch_then_check)
            k.kickstart_from_industry(
                session, ws,
                source_industry_id=industry_id, source_version=1,
                new_name=name, copy_inputs=False,
            )
        return seen

    leaked = _run_with_session_kwargs("TouchLeakSeed Co")
    assert leaked and any(v is True for v in leaked), (
        "expected the default expire_on_commit=True session to reproduce "
        "the leak when an ORM attribute is touched after a commit"
    )

    safe = _run_with_session_kwargs("TouchSafeSeed Co", expire_on_commit=False)
    assert safe and all(v is False for v in safe), (
        "expire_on_commit=False must prevent the post-commit attribute "
        "touch from re-opening a transaction across the warehouse write"
    )

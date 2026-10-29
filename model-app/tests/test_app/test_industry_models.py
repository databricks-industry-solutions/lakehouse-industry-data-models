"""Tests for the industry-model lifecycle router (`/api/industry-models/*`).

Wave 2 Track A: download/materialize (Story 4) + name conflict (Story 7).

Two layers:

- Service unit-ish tests drive ``download_industry_model`` directly against
  a fake GitHub connector (canned ``model.json`` envelope + artifacts) and a
  mock WorkspaceClient.
- Route tests drive ``POST /api/industry-models/download`` through the
  TestClient, injecting the same fake connector by monkeypatching
  ``build_source_connector`` in ``services.industry_download``.
"""

from __future__ import annotations

import json
from pathlib import Path

import pytest
from sqlmodel import Session, select

from _test_app import make_test_app
from vibe_modeling.backend.db_models import (
    AgentConfig,
    Business,
    Domain,
    ModelVersion,
    Run,
    RunArtifact,
    Sector,
)
from vibe_modeling.backend.sources import ModelArtifact, TargetKind
from vibe_modeling.backend.sources.base import SourceNotFoundError


# ---------------------------------------------------------------------------
# Fixtures: a fake connector whose model.json uses the ENVELOPE shape so
# detect_schema must unwrap it (top-level model_name/domains would be the
# routes/sources.py:168 bug — assert we never read those).
# ---------------------------------------------------------------------------

# The agent envelope: the real model lives under "model"; the top-level
# model_name/domains are decoys that must NOT be read.
_MODEL_ENVELOPE = {
    "model_name": "DECOY-top-level-should-not-be-read",
    "domains": ["decoy", "decoy"],
    "model": {
        "type": "business",
        "name": "Acme Retail Industry",
        "version": "v1_ecm",
        "description": "An industry reference model for retail.",
        "domains": [
            {
                "name": "sales",
                "products": [
                    {
                        "name": "orders",
                        "attributes": [
                            {"name": "order_id", "type": "string", "primary_key": True},
                        ],
                    },
                ],
            },
            {"name": "inventory", "products": []},
        ],
    },
}


class _FakeConnector:
    """Minimal SourceConnector stub for download tests.

    Records the raw-bytes fetches the service performs so tests can assert
    materialization happened.
    """

    def __init__(self, *, model_json: dict | None = None, artifacts=None, missing=False):
        self._model_json = _MODEL_ENVELOPE if model_json is None else model_json
        self._artifacts = artifacts if artifacts is not None else _default_artifacts()
        self._missing = missing
        self.raw_fetches: list[str] = []

    def fetch_model_json(self, industry_id: str, model_id: str) -> str:
        if self._missing:
            raise SourceNotFoundError("no such model")
        return json.dumps(self._model_json)

    def fetch_artifacts(self, industry_id: str, model_id: str):
        return list(self._artifacts)

    def _fetch_raw(self, path: str) -> str:
        self.raw_fetches.append(path)
        return f"bytes-of::{path}"


def _default_artifacts():
    return [
        ModelArtifact(
            name="model.json",
            target_kind=TargetKind.MODEL_JSON,
            path="retail/v1/ecm/model.json",
            size=100,
        ),
        ModelArtifact(
            name="sales_schema.sql",
            target_kind=TargetKind.SCHEMAS,
            path="retail/v1/ecm/schemas/sales_schema.sql",
            size=200,
        ),
    ]


@pytest.fixture
def seed_sector(engine) -> str:
    with Session(engine) as session:
        s = Sector(name="Retail", short_name="retail")
        session.add(s)
        session.commit()
        session.refresh(s)
        return s.id


def _patch_connector(monkeypatch, conn):
    """Make the service build our fake connector regardless of config."""
    from vibe_modeling.backend.services import industry_download as mod

    monkeypatch.setattr(mod, "build_source_connector", lambda *a, **k: conn)


# ---------------------------------------------------------------------------
# Service-level: scope inference + fallback
# ---------------------------------------------------------------------------


def test_scope_from_model_id_validates_against_valid_scopes():
    from vibe_modeling.backend.services.industry_download import _scope_from_model_id

    assert _scope_from_model_id("v1_ecm") == "ecm"
    assert _scope_from_model_id("v2_mvm") == "mvm"
    # No known scope segment: no scope (the download refuses it).
    assert _scope_from_model_id("v1_bogus") is None
    assert _scope_from_model_id("weird_model") is None
    assert _scope_from_model_id("ecm") is None


# ---------------------------------------------------------------------------
# Service-level: happy path
# ---------------------------------------------------------------------------


def test_download_creates_industry_business_and_version(
    engine, mock_ws, config, seed_sector, monkeypatch,
):
    conn = _FakeConnector()
    _patch_connector(monkeypatch, conn)
    from vibe_modeling.backend.services.industry_download import download_industry_model

    with Session(engine) as session:
        result = download_industry_model(
            session, mock_ws, config=config,
            sector_id=seed_sector, industry_id="retail", model_id="v1_ecm",
        )
        session.commit()

        biz = session.get(Business, result.business_id)
        assert biz is not None
        # Business identity comes from the UNWRAPPED model.name, not the decoy.
        assert biz.name == "Acme Retail Industry"
        assert biz.kind == "industry"
        assert biz.sector_id == seed_sector
        # A downloaded industry IS the source — not kickstarted from one.
        assert biz.source_industry_id is None

        mv = session.get(ModelVersion, result.version_id)
        assert mv.deployment_status == "draft"
        assert mv.imported_at is not None
        assert mv.import_source_path.startswith("github://")
        # import_source_path is the model's 3-level relpath (industry/version/scope),
        # not the fused model_id.
        assert mv.import_source_path.endswith("/retail/v1/ecm")

        # Domains synced from the unwrapped envelope (sales + inventory = 2),
        # NOT from the top-level decoy domains list.
        domains = session.exec(select(Domain).where(Domain.version_id == mv.id)).all()
        assert {d.name for d in domains} == {"sales", "inventory"}


def test_a_model_id_without_a_scope_is_refused_and_writes_nothing(
    engine, mock_ws, config, seed_sector, monkeypatch,
):
    from fastapi import HTTPException

    from vibe_modeling.backend.services.industry_download import download_industry_model

    from ._assess_helpers import table_digests

    conn = _FakeConnector()
    _patch_connector(monkeypatch, conn)
    before = table_digests(engine)
    with Session(engine) as session:
        with pytest.raises(HTTPException) as exc:
            download_industry_model(
                session, mock_ws, config=config,
                sector_id=seed_sector, industry_id="retail", model_id="weird_model",
            )
    assert exc.value.status_code == 422
    assert "is not an ECM or an MVM model" in str(exc.value.detail)
    assert table_digests(engine) == before
    mock_ws.files.upload.assert_not_called()
    mock_ws.statement_execution.execute_statement.assert_not_called()


def test_download_prefixes_the_apps_copy_rows_and_seed(
    engine, mock_ws, config, seed_sector, monkeypatch,
):
    """The real agriculture MVM (blank prefix): the Volume model.json, the
    Domain rows and the seed name ``mvm_<domain>`` and ``mvm_<view>``; the
    version records the markers; the seed's location is the version folder."""
    from vibe_modeling.backend.core._paths import version_dir_in_volume
    from vibe_modeling.backend.services import industry_download as mod

    from ._fake_volume import FakeVolume

    fixture = json.loads((Path(__file__).parent.parent / "fixtures" / "industry_agriculture_v1_trimmed.json").read_text())
    root = fixture["mvm"]
    root["model"].update({"type": "business", "version": "v1_mvm", "description": "Agriculture."})
    conn = _FakeConnector(model_json=root, artifacts=[])
    _patch_connector(monkeypatch, conn)
    volume = FakeVolume(mock_ws)
    seeds = []
    monkeypatch.setattr(mod, "seed_metamodel_one", lambda ws, **kw: seeds.append(kw) or None)
    with Session(engine) as session:
        result = mod.download_industry_model(
            session, mock_ws, config=config,
            sector_id=seed_sector, industry_id="agriculture", model_id="v1_mvm",
        )
        session.commit()
        mv = session.get(ModelVersion, result.version_id)
        assert (mv.import_schema_prefix_added, mv.import_view_prefix_added) == ("mvm_", "mvm_")
        rows = {d.database_name for d in session.exec(select(Domain).where(Domain.version_id == mv.id)).all()}
        folder = version_dir_in_volume(mv.files_catalog, result.business_name, 1, "mvm")
    assert len(rows) == 14 and all(n.startswith("mvm_") for n in rows)
    copy = volume.json(f"{folder}/model.json")
    assert copy["model"]["version"] == "v1_mvm"
    assert {d["database_name"] for d in copy["model"]["domains"]} == rows
    assert all(v["view_name"].startswith("mvm_") for v in copy["model"]["metric_views"])
    assert [kw["location"] for kw in seeds] == [folder]
    assert {d["database_name"] for d in seeds[0]["model_json"]["domains"]} == rows


def test_download_infers_scope_from_model_id(
    engine, mock_ws, config, seed_sector, monkeypatch,
):
    conn = _FakeConnector()
    _patch_connector(monkeypatch, conn)
    from vibe_modeling.backend.services.industry_download import download_industry_model

    with Session(engine) as session:
        result = download_industry_model(
            session, mock_ws, config=config,
            sector_id=seed_sector, industry_id="retail", model_id="v1_mvm",
        )
        session.commit()
        mv = session.get(ModelVersion, result.version_id)
        assert mv.scope == "mvm"


def test_download_materializes_artifacts_and_indexes(
    engine, mock_ws, config, seed_sector, monkeypatch,
):
    conn = _FakeConnector()
    _patch_connector(monkeypatch, conn)
    from vibe_modeling.backend.services.industry_download import download_industry_model

    # The indexer reads back the Volume dir; mirror what we uploaded.
    uploaded: list[str] = []

    def _upload(path, body, overwrite=False):
        uploaded.append(path)

    mock_ws.files.upload.side_effect = _upload

    def _list_dir(root):
        out = []
        for p in uploaded:
            if p.startswith(root + "/"):
                name = p[len(root) + 1:]
                if "/" in name:
                    # Only direct children are returned by a single listing;
                    # nested files come from recursion into sub-dirs. Emit a
                    # directory entry for the first segment instead.
                    seg = name.split("/", 1)[0]
                    e = type("E", (), {})()
                    e.name = seg
                    e.is_directory = True
                    e.file_size = 0
                    if seg not in {x.name for x in out}:
                        out.append(e)
                    continue
                e = type("E", (), {})()
                e.name = name
                e.is_directory = False
                e.file_size = 10
                out.append(e)
        return out

    mock_ws.files.list_directory_contents.side_effect = _list_dir

    with Session(engine) as session:
        result = download_industry_model(
            session, mock_ws, config=config,
            sector_id=seed_sector, industry_id="retail", model_id="v1_ecm",
        )
        session.commit()
        # Each fetched artifact's bytes were materialized onto the Volume.
        assert mock_ws.files.upload.called
        # CRITICAL (§3c): a companion file under schemas/ lands at the NESTED
        # Volume path, not flattened onto the version root. The source path
        # 'retail/v1/ecm/schemas/sales_schema.sql' has the model-dir prefix
        # 'retail/v1/ecm/' stripped, preserving the 'schemas/' sub-path.
        assert any(
            p.endswith("/schemas/sales_schema.sql") for p in uploaded
        ), uploaded
        assert not any(p.endswith("/sales_schema.sql") and "/schemas/" not in p for p in uploaded), uploaded
        # And indexed against the model version.
        arts = session.exec(
            select(RunArtifact).where(RunArtifact.model_version_id == result.version_id)
        ).all()
        assert len(arts) >= 1


def test_download_creates_audit_run_after_commit(
    engine, mock_ws, config, seed_sector, monkeypatch,
):
    conn = _FakeConnector()
    _patch_connector(monkeypatch, conn)
    from vibe_modeling.backend.services.industry_download import download_industry_model

    with Session(engine) as session:
        result = download_industry_model(
            session, mock_ws, config=config,
            sector_id=seed_sector, industry_id="retail", model_id="v1_ecm",
        )
        session.commit()
        runs = session.exec(select(Run).where(Run.business_id == result.business_id)).all()
        assert len(runs) == 1
        assert runs[0].intent == "download-industry"
        assert runs[0].status == "completed"


def test_download_seeds_metamodel(
    engine, mock_ws, config, seed_sector, monkeypatch,
):
    """A downloaded industry seeds <catalog>._metamodel.* so it is directly
    iterable - write_metamodel invoked once with the resolved catalog,
    business_name, scope, and version."""
    conn = _FakeConnector()
    _patch_connector(monkeypatch, conn)
    from vibe_modeling.backend.services.industry_download import download_industry_model

    calls = []

    def _spy(ws_arg, **kwargs):
        calls.append(kwargs)
        return {"business": 1, "domain": 0, "product": 0, "attribute": 0, "errors": []}

    # The shared seed_metamodel_one resolves write_metamodel from its own
    # module, so patch it there.
    monkeypatch.setattr(
        "vibe_modeling.backend.services.import_metamodel_writer.write_metamodel", _spy
    )

    with Session(engine) as session:
        download_industry_model(
            session, mock_ws, config=config,
            sector_id=seed_sector, industry_id="retail", model_id="v1_ecm",
        )

    assert len(calls) == 1
    kw = calls[0]
    assert kw["catalog"] == "test_deployment_catalog"
    assert kw["warehouse_id"] == "test-warehouse-id"
    assert kw["business_name"] == "Acme Retail Industry"
    assert kw["scope"] == "ecm"
    assert kw["version"] == 1


def test_download_audit_run_has_timestamps_and_lineage(
    engine, mock_ws, config, seed_sector, monkeypatch,
):
    conn = _FakeConnector()
    _patch_connector(monkeypatch, conn)
    from vibe_modeling.backend.services.industry_download import download_industry_model

    with Session(engine) as session:
        result = download_industry_model(
            session, mock_ws, config=config,
            sector_id=seed_sector, industry_id="retail", model_id="v1_ecm",
        )
        run = session.exec(
            select(Run).where(Run.business_id == result.business_id)
        ).first()
        assert run.started_at is not None
        assert run.completed_at is not None
        assert run.started_at == run.completed_at == run.created_at
        assert "Source:" in run.vibe_instructions_text
        assert f"/businesses/{result.business_id}" in run.vibe_instructions_text


def test_download_no_open_transaction_during_materialize(
    engine, mock_ws, config, seed_sector, monkeypatch,
):
    """The slow Volume materialize MUST run with the Postgres transaction
    closed (structure committed first) - a held transaction trips Lakebase's
    idle-in-transaction timeout on multi-minute downloads."""
    conn = _FakeConnector()
    _patch_connector(monkeypatch, conn)
    from vibe_modeling.backend.services import industry_download as mod
    from vibe_modeling.backend.services.industry_download import download_industry_model

    seen: list[bool] = []
    with Session(engine) as session:
        def _spy(ws, connector, **kwargs):
            seen.append(session.in_transaction())

        monkeypatch.setattr(mod, "_materialize_artifacts", _spy)
        download_industry_model(
            session, mock_ws, config=config,
            sector_id=seed_sector, industry_id="retail", model_id="v1_ecm",
        )

    assert seen, "the materialize phase should run"
    assert all(v is False for v in seen), (
        "structure must be committed before the Volume materialize - no open "
        "transaction may be held across the slow I/O"
    )


def test_download_unknown_sector_404(engine, mock_ws, config, monkeypatch):
    conn = _FakeConnector()
    _patch_connector(monkeypatch, conn)
    from fastapi import HTTPException

    from vibe_modeling.backend.services.industry_download import download_industry_model

    with Session(engine) as session:
        with pytest.raises(HTTPException) as ei:
            download_industry_model(
                session, mock_ws, config=config,
                sector_id="does-not-exist", industry_id="retail", model_id="v1_ecm",
            )
        assert ei.value.status_code == 404


# ---------------------------------------------------------------------------
# Story 7: name conflict + on_conflict branches
# ---------------------------------------------------------------------------


def _seed_existing_industry(engine, sector_id, name="Acme Retail Industry") -> str:
    """Seed a ``kind='industry'`` Business with NO model versions.

    This is the ADDITIVE base case: any first-seen scope downloads onto it
    successfully. Use :func:`_seed_existing_industry_with_model` when a test
    needs a same-scope clash to fire.
    """
    with Session(engine) as session:
        b = Business(name=name, kind="industry", sector_id=sector_id)
        session.add(b)
        session.commit()
        session.refresh(b)
        return b.id


def _seed_existing_industry_with_model(
    engine, sector_id, *, scope="ecm", name="Acme Retail Industry",
) -> tuple[str, str]:
    """Seed a ``kind='industry'`` Business that ALREADY carries a version of
    ``scope``. Returns ``(business_id, version_id)``. Use this to force the
    same-scope 409 clash."""
    with Session(engine) as session:
        b = Business(name=name, kind="industry", sector_id=sector_id)
        session.add(b)
        session.flush()
        mv = ModelVersion(
            business_id=b.id, version=1, status="completed",
            deployment_status="draft", scope=scope,
        )
        session.add(mv)
        session.commit()
        session.refresh(b)
        session.refresh(mv)
        return b.id, mv.id


def test_download_same_scope_clash_409(engine, mock_ws, config, seed_sector, monkeypatch):
    """An industry that already carries an ECM version blocks a second ECM
    download outright with the model-scoped 409 (block, never replace)."""
    conn = _FakeConnector()
    _patch_connector(monkeypatch, conn)
    _seed_existing_industry_with_model(engine, seed_sector, scope="ecm")
    from fastapi import HTTPException

    from vibe_modeling.backend.services.industry_download import download_industry_model

    with Session(engine) as session:
        with pytest.raises(HTTPException) as ei:
            download_industry_model(
                session, mock_ws, config=config,
                sector_id=seed_sector, industry_id="retail", model_id="v1_ecm",
            )
        assert ei.value.status_code == 409
        assert ei.value.detail["error"] == "industry_model_already_exists"
        assert ei.value.detail["scope"] == "ecm"


def test_download_adds_new_scope_to_existing_industry(
    engine, mock_ws, config, seed_sector, monkeypatch,
):
    """Industry already carries ECM v1; downloading an MVM model ADDS a
    second ModelVersion under the SAME business. Two versions, distinct
    scopes, per-scope ordinal 1 each, and the first version is untouched."""
    conn = _FakeConnector()
    _patch_connector(monkeypatch, conn)
    existing_id, ecm_vid = _seed_existing_industry_with_model(
        engine, seed_sector, scope="ecm",
    )
    from vibe_modeling.backend.services.industry_download import download_industry_model

    with Session(engine) as session:
        # Seed a domain under the pre-existing ECM version so we can assert it
        # is left intact by the additive MVM download.
        session.add(Domain(version_id=ecm_vid, name="preexisting"))
        session.commit()

    with Session(engine) as session:
        result = download_industry_model(
            session, mock_ws, config=config,
            sector_id=seed_sector, industry_id="retail", model_id="v1_mvm",
        )
        session.commit()
        assert result.business_id == existing_id
        assert result.on_conflict_applied == "added"
        assert result.scope == "mvm"

        versions = session.exec(
            select(ModelVersion).where(ModelVersion.business_id == existing_id)
        ).all()
        assert len(versions) == 2
        by_scope = {v.scope: v for v in versions}
        assert set(by_scope) == {"ecm", "mvm"}
        # Per-scope ordinal is 1 each (independent counters).
        assert by_scope["ecm"].version == 1
        assert by_scope["mvm"].version == 1

        # The pre-existing ECM version's domains are untouched.
        ecm_domains = session.exec(
            select(Domain).where(Domain.version_id == ecm_vid)
        ).all()
        assert {d.name for d in ecm_domains} == {"preexisting"}


def test_download_additive_does_not_mutate_existing_industry(
    engine, mock_ws, config, seed_sector, monkeypatch,
):
    """Key container guarantee: adding a second scope with a DIFFERENT
    request sector_id appends the version but NEVER moves or renames the
    existing industry. The request's sector_id is ignored for an existing
    industry."""
    conn = _FakeConnector()
    _patch_connector(monkeypatch, conn)
    existing_id, _ = _seed_existing_industry_with_model(
        engine, seed_sector, scope="ecm",
    )
    # A second, different sector the caller will (wrongly) try to move into.
    with Session(engine) as session:
        other = Sector(name="Finance", short_name="fin")
        session.add(other)
        session.commit()
        session.refresh(other)
        other_sector_id = other.id
        orig = session.get(Business, existing_id)
        orig_name = orig.name
        orig_desc = orig.description
        orig_sector = orig.sector_id

    from vibe_modeling.backend.services.industry_download import download_industry_model

    with Session(engine) as session:
        result = download_industry_model(
            session, mock_ws, config=config,
            sector_id=other_sector_id,  # different sector — must be ignored
            industry_id="retail", model_id="v1_mvm",
        )
        session.commit()
        assert result.on_conflict_applied == "added"
        biz = session.get(Business, existing_id)
        # Container row is unchanged: sector did NOT move, name/desc intact.
        assert biz.sector_id == orig_sector
        assert biz.sector_id != other_sector_id
        assert biz.name == orig_name
        assert biz.description == orig_desc
        # The new MVM version landed under the SAME business.
        versions = session.exec(
            select(ModelVersion).where(ModelVersion.business_id == existing_id)
        ).all()
        assert {v.scope for v in versions} == {"ecm", "mvm"}


def test_download_first_model_into_existing_industry_no_versions(
    engine, mock_ws, config, seed_sector, monkeypatch,
):
    """An industry business that exists but carries NO versions is the
    additive base case: the download succeeds and adds the first version."""
    conn = _FakeConnector()
    _patch_connector(monkeypatch, conn)
    existing_id = _seed_existing_industry(engine, seed_sector)
    from vibe_modeling.backend.services.industry_download import download_industry_model

    with Session(engine) as session:
        result = download_industry_model(
            session, mock_ws, config=config,
            sector_id=seed_sector, industry_id="retail", model_id="v1_ecm",
        )
        session.commit()
        assert result.business_id == existing_id
        assert result.on_conflict_applied == "added"
        versions = session.exec(
            select(ModelVersion).where(ModelVersion.business_id == existing_id)
        ).all()
        assert len(versions) == 1
        assert versions[0].scope == "ecm"


# ---------------------------------------------------------------------------
# Service-level: source_repo_path round-trip target (ADR D-049)
# ---------------------------------------------------------------------------


def test_download_sets_source_repo_path_new_industry(
    engine, mock_ws, config, seed_sector, monkeypatch,
):
    """A new industry persists the industry-folder repo path (no model_id)."""
    conn = _FakeConnector()
    _patch_connector(monkeypatch, conn)
    from vibe_modeling.backend.services.industry_download import (
        _repo_label,
        download_industry_model,
    )

    from vibe_modeling.backend.sources import github as gh

    with Session(engine) as session:
        result = download_industry_model(
            session, mock_ws, config=config,
            sector_id=seed_sector, industry_id="retail", model_id="v1_ecm",
        )
        session.commit()
        expected_label = _repo_label(session, config)
        # The publish target is scoped under the connector's base path (the
        # data-models/ subtree). Derive the segment parametrically so a future
        # base-path move can't silently break this assertion.
        base = gh.DEFAULT_BASE_PATH.strip("/")
        prefix = f"{base}/" if base else ""
        biz = session.get(Business, result.business_id)
        assert biz.source_repo_path == f"github://{expected_label}/{prefix}retail"
        # The model_id / version / scope are deliberately NOT part of the path —
        # the publish target is the whole industry-folder root.
        assert "v1_ecm" not in biz.source_repo_path
        assert "/v1" not in biz.source_repo_path


def test_download_does_not_overwrite_source_repo_path_on_second_model(
    engine, mock_ws, config, seed_sector, monkeypatch,
):
    """First-download-wins: a second download of a new scope under the SAME
    industry (different industry_id folder) leaves source_repo_path unchanged."""
    conn = _FakeConnector()
    _patch_connector(monkeypatch, conn)
    from vibe_modeling.backend.services.industry_download import download_industry_model

    with Session(engine) as session:
        first = download_industry_model(
            session, mock_ws, config=config,
            sector_id=seed_sector, industry_id="retail", model_id="v1_ecm",
        )
        session.commit()
        first_path = session.get(Business, first.business_id).source_repo_path
    assert first_path.endswith("/retail")

    with Session(engine) as session:
        second = download_industry_model(
            session, mock_ws, config=config,
            sector_id=seed_sector, industry_id="retail_v2_folder", model_id="v1_mvm",
        )
        session.commit()
        assert second.business_id == first.business_id
        assert second.on_conflict_applied == "added"
        biz = session.get(Business, first.business_id)
        # Unchanged despite the second call's different industry_id folder.
        assert biz.source_repo_path == first_path
        assert "retail_v2_folder" not in biz.source_repo_path


# ---------------------------------------------------------------------------
# Endpoint-level: publish target_path threading (ADR D-049)
# ---------------------------------------------------------------------------


def _seed_publishable(engine):
    """Seed a business + completed ECM v2 version and an oauth AgentConfig so
    the publish endpoint resolves a connection (no 422)."""
    from vibe_modeling.backend.db_models import AgentConfig
    from vibe_modeling.backend.model_sync import ModelSyncService
    from .test_model_export import SAMPLE_MODEL

    with Session(engine) as session:
        session.add(
            AgentConfig(
                github_auth_mode="oauth_u2m",
                github_connection_name="github_pr",
                github_repo_owner="acme",
                github_repo_name="models",
            )
        )
        biz = Business(name="Test Retail", industry_alignment="Retail", description="demo")
        session.add(biz)
        session.flush()
        mv = ModelVersion(
            business_id=biz.id, version=2, scope="ecm", status="completed"
        )
        session.add(mv)
        session.flush()
        ModelSyncService(session).sync_from_model_json(mv.id, SAMPLE_MODEL)
        session.commit()
        return biz.id, mv.id


def _publish_app(engine):

    from vibe_modeling.backend.core._defaults import _get_user_ws
    from vibe_modeling.backend.core._roles import require_modeler
    from vibe_modeling.backend.core.lakebase import _LakebaseDependency
    from vibe_modeling.backend.routes.industry_models import router as im_router
    from .test_github_publish import _FakeUserWs

    app = make_test_app(im_router)

    def override_session():
        with Session(engine) as session:
            yield session

    app.dependency_overrides[_LakebaseDependency.__call__] = override_session
    app.dependency_overrides[_get_user_ws] = lambda: _FakeUserWs()
    app.dependency_overrides[require_modeler] = lambda: object()
    return app


def test_publish_endpoint_accepts_no_body_back_compat(engine):
    from fastapi.testclient import TestClient

    bid, vid = _seed_publishable(engine)
    client = TestClient(_publish_app(engine))
    resp = client.post(f"/api/businesses/{bid}/model-versions/{vid}/publish")
    assert resp.status_code == 200, resp.text
    assert resp.json()["target_path"] == "test_retail/v2/ecm"


def test_publish_endpoint_threads_target_path(engine):
    from fastapi.testclient import TestClient

    bid, vid = _seed_publishable(engine)
    client = TestClient(_publish_app(engine))
    resp = client.post(
        f"/api/businesses/{bid}/model-versions/{vid}/publish",
        json={"target_path": "x/y_v1"},
    )
    assert resp.status_code == 200, resp.text
    assert resp.json()["target_path"] == "x/y_v1"


# ---------------------------------------------------------------------------
# Route-level
# ---------------------------------------------------------------------------


def test_route_download_industry_model(client, engine, monkeypatch):
    conn = _FakeConnector()
    _patch_connector(monkeypatch, conn)
    with Session(engine) as session:
        # Download requires metamodel catalog + warehouse + source repo
        # (Track 4 preflight); seed a fully-configured agent.
        session.add(AgentConfig(
            notebook_path="/nb", job_id=1,
            deployment_catalog="metamodel_cat", warehouse_id="wh-1",
            github_repo_owner="acme", github_repo_name="models",
        ))
        s = Sector(name="Retail", short_name="retail")
        session.add(s)
        session.commit()
        session.refresh(s)
        sector_id = s.id

    resp = client.post(
        "/api/industry-models/download",
        json={"sector_id": sector_id, "industry_id": "retail", "model_id": "v1_ecm"},
    )
    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert body["business_name"] == "Acme Retail Industry"
    assert body["scope"] == "ecm"
    assert body["domains"] == 2
    # products/attribute_count/fk_count come from the download's own
    # ImportAnalysis (Task 5 completion dialog), not the source releasenotes:
    # 1 product (orders; inventory has none), 1 attribute (order_id, a PK not
    # an FK), 0 foreign keys.
    assert body["products"] == 1
    assert body["attribute_count"] == 1
    assert body["fk_count"] == 0
    assert body["on_conflict_applied"] == "none"


def test_route_download_same_scope_clash_409(client, engine, monkeypatch):
    conn = _FakeConnector()
    _patch_connector(monkeypatch, conn)
    with Session(engine) as session:
        session.add(AgentConfig(
            notebook_path="/nb", job_id=1,
            deployment_catalog="metamodel_cat", warehouse_id="wh-1",
            github_repo_owner="acme", github_repo_name="models",
        ))
        s = Sector(name="Retail", short_name="retail")
        session.add(s)
        session.commit()
        session.refresh(s)
        sector_id = s.id
        biz = Business(name="Acme Retail Industry", kind="industry", sector_id=sector_id)
        session.add(biz)
        session.flush()
        session.add(
            ModelVersion(
                business_id=biz.id, version=1, status="completed",
                deployment_status="draft", scope="ecm",
            )
        )
        session.commit()

    resp = client.post(
        "/api/industry-models/download",
        json={"sector_id": sector_id, "industry_id": "retail", "model_id": "v1_ecm"},
    )
    assert resp.status_code == 409
    assert resp.json()["detail"]["error"] == "industry_model_already_exists"


def test_industry_models_health(client):
    resp = client.get("/api/industry-models/_health")
    assert resp.status_code == 200
    assert resp.json() == {"ok": True}

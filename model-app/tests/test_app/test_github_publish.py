"""Tests for the GitHub publish flow (Wave 2 Track C, story 10).

Two halves:

* The **service** (``services.github_publish.publish_model_version``) is tested
  with a FAKE ``http_request``-capable client that records every call. We assert
  the request SHAPING — the ENUM method (not a string), the ``json`` arg passed
  as a *string* (``json.dumps``), and the call ORDER: branch-ref create -> N
  content PUTs -> exactly ONE pulls POST. The 422 guards (missing connection /
  deferred secret-PAT) are asserted here too.
* The **endpoint** is tested for the 422 connection-missing guard through the
  router with the OBO/role dependencies overridden.

The real UC-connection publish E2E is HUMAN-GATED (an operator must create the
``github_pr`` UC HTTP connection first), so the testable surface is the guard +
the request shaping, not a live GitHub round-trip.
"""

from __future__ import annotations

import io
import json
import zipfile

import pytest
from fastapi import HTTPException
from sqlmodel import Session
from unittest.mock import MagicMock

from databricks.sdk.service.serving import ExternalFunctionRequestHttpMethod

from _test_app import make_test_app
from vibe_modeling.backend import model_export
from vibe_modeling.backend.db_models import (
    AgentConfig,
    Business,
    ModelVersion,
    Run,
    RunArtifact,
)
from vibe_modeling.backend.model_sync import ModelSyncService
from vibe_modeling.backend.services import github_publish
from vibe_modeling.backend.services.github_publish import publish_model_version

from .test_model_export import SAMPLE_MODEL


# --- Fakes -----------------------------------------------------------------


class _FakeRequestsResp:
    """Minimal requests.Response shape returned by ServingEndpointsExt.http_request."""

    def __init__(self, payload: dict):
        self.text = json.dumps(payload)
        self.status_code = 200


class _FakeServingEndpoints:
    """Records http_request calls and returns canned GitHub-shaped bodies.

    Signature matches ``ServingEndpointsExt.http_request(conn, method, path, *,
    json=None, headers=None, ...)``.  The old fake accepted ``connection_name=``
    as a keyword arg, masking the positional-vs-keyword mismatch in production.
    """

    def __init__(self):
        self.calls: list[dict] = []

    def http_request(self, conn, method, path, *, json=None, **kwargs):
        self.calls.append(
            {
                "connection_name": conn,
                "method": method,
                "path": path,
                "json": json,
                "_extra": kwargs,
            }
        )
        if path.endswith("/git/ref/heads/main") or "/git/ref/heads/" in path:
            return _FakeRequestsResp({"object": {"sha": "basesha"}})
        if path.endswith("/pulls"):
            return _FakeRequestsResp(
                {"number": 7, "html_url": "https://github.com/o/r/pull/7"}
            )
        if path.startswith("/repos/") and path.count("/") == 2:
            return _FakeRequestsResp({"default_branch": "main"})
        return _FakeRequestsResp({})


class _FakeUserWs:
    def __init__(self):
        self.serving_endpoints = _FakeServingEndpoints()
        self.files = MagicMock()
        # Fresh BytesIO per call so repeated reads (iter + zip parity) don't
        # exhaust the stream.
        self.files.download.side_effect = lambda _p: MagicMock(
            contents=io.BytesIO(b"artifact-bytes")
        )


def _seed(engine, *, with_artifact=False) -> tuple[str, str]:
    with Session(engine) as session:
        biz = Business(
            name="Test Retail",
            industry_alignment="Retail",
            description="demo",
        )
        session.add(biz)
        session.flush()
        mv = ModelVersion(
            business_id=biz.id, version=2, scope="ecm", status="completed"
        )
        session.add(mv)
        session.flush()
        ModelSyncService(session).sync_from_model_json(mv.id, SAMPLE_MODEL)
        if with_artifact:
            session.add(
                RunArtifact(
                    model_version_id=mv.id,
                    artifact_type="markdown",
                    file_path="/Volumes/x/y/report.md",
                )
            )
        session.commit()
        return biz.id, mv.id


def _oauth_cfg() -> AgentConfig:
    return AgentConfig(
        github_auth_mode="oauth_u2m",
        github_connection_name="github_pr",
        github_repo_owner="acme",
        github_repo_name="models",
    )


# --- 422 guards ------------------------------------------------------------


def test_publish_422_when_connection_missing(engine):
    bid, vid = _seed(engine)
    cfg = AgentConfig(github_auth_mode="", github_connection_name="")
    with Session(engine) as session:
        with pytest.raises(HTTPException) as ei:
            publish_model_version(
                _FakeUserWs(),
                cfg,
                session=session,
                business_id=bid,
                version_id=vid,
            )
    assert ei.value.status_code == 422
    assert ei.value.detail["error"] == "github_connection_missing"


def test_publish_422_when_oauth_but_no_connection_name(engine):
    bid, vid = _seed(engine)
    cfg = AgentConfig(github_auth_mode="oauth_u2m", github_connection_name="")
    with Session(engine) as session:
        with pytest.raises(HTTPException) as ei:
            publish_model_version(
                _FakeUserWs(),
                cfg,
                session=session,
                business_id=bid,
                version_id=vid,
            )
    assert ei.value.status_code == 422
    assert ei.value.detail["error"] == "github_connection_missing"


def test_publish_422_when_secret_pat(engine):
    bid, vid = _seed(engine)
    cfg = AgentConfig(
        github_auth_mode="secret_pat",
        github_secret_scope="s",
        github_secret_key="k",
    )
    with Session(engine) as session:
        with pytest.raises(HTTPException) as ei:
            publish_model_version(
                _FakeUserWs(),
                cfg,
                session=session,
                business_id=bid,
                version_id=vid,
            )
    assert ei.value.status_code == 422
    assert ei.value.detail["error"] == "github_pat_not_implemented"


# --- SDK contract guard (would fail against pre-fix code) ------------------


def test_publish_connection_name_positional_and_json_is_dict(engine):
    """Guard against regression: connection_name must be passed positionally
    (maps to ``conn`` in ServingEndpointsExt.http_request) and json must be a
    dict (the mixin JSON-encodes it; passing a string double-encodes).

    Pre-fix code passed ``connection_name=`` as a keyword arg, causing:
        TypeError: http_request() got an unexpected keyword argument 'connection_name'
    """
    bid, vid = _seed(engine)
    ws = _FakeUserWs()
    cfg = _oauth_cfg()
    with Session(engine) as session:
        publish_model_version(ws, cfg, session=session, business_id=bid, version_id=vid)

    for call in ws.serving_endpoints.calls:
        assert "_extra" not in call or "connection_name" not in call.get("_extra", {}), (
            "connection_name must be positional, not a keyword arg"
        )
        assert "connection_name" in call and call["connection_name"] == "github_pr"
        if call["json"] is not None:
            assert isinstance(call["json"], dict), (
                f"json must be dict, not {type(call['json']).__name__}"
            )


# --- Request shaping + call ordering ---------------------------------------


def test_publish_request_shaping_and_order(engine):
    bid, vid = _seed(engine)
    ws = _FakeUserWs()
    cfg = _oauth_cfg()
    with Session(engine) as session:
        result = publish_model_version(
            ws, cfg, session=session, business_id=bid, version_id=vid
        )

    calls = ws.serving_endpoints.calls

    # Every call goes through the named UC connection.
    assert all(c["connection_name"] == "github_pr" for c in calls)

    # Method is the SDK ENUM, never a string.
    for c in calls:
        assert isinstance(c["method"], ExternalFunctionRequestHttpMethod)

    # The branch-ref create POST precedes any content PUT.
    ref_idx = next(
        i for i, c in enumerate(calls) if c["path"].endswith("/git/refs")
    )
    put_idxs = [
        i
        for i, c in enumerate(calls)
        if c["method"] is ExternalFunctionRequestHttpMethod.PUT
    ]
    pulls_idxs = [
        i for i, c in enumerate(calls) if c["path"].endswith("/pulls")
    ]
    assert put_idxs, "expected at least one content PUT"
    assert ref_idx < min(put_idxs)
    # Exactly ONE pull request, opened after all the PUTs.
    assert len(pulls_idxs) == 1
    assert pulls_idxs[0] > max(put_idxs)

    # The PUT/POST json args are DICTS (not json.dumps strings).
    for c in calls:
        if c["method"] in (
            ExternalFunctionRequestHttpMethod.PUT,
            ExternalFunctionRequestHttpMethod.POST,
        ):
            assert isinstance(c["json"], dict)

    # Content PUT body carries base64 content + branch.
    put_call = calls[put_idxs[0]]
    put_body = put_call["json"]
    assert "content" in put_body and "branch" in put_body

    assert result.pr_number == 7
    assert result.pr_url == "https://github.com/o/r/pull/7"
    assert result.files  # model.json at least


def test_publish_puts_every_bundle_file(engine):
    """One content PUT per file iter_bundle_files yields (model.json + artifact)."""
    bid, vid = _seed(engine, with_artifact=True)
    ws = _FakeUserWs()
    cfg = _oauth_cfg()
    with Session(engine) as session:
        result = publish_model_version(
            ws, cfg, session=session, business_id=bid, version_id=vid
        )

    put_paths = [
        c["path"]
        for c in ws.serving_endpoints.calls
        if c["method"] is ExternalFunctionRequestHttpMethod.PUT
    ]
    # model.json + report.md
    assert len(put_paths) == 2
    assert any("model.json" in p for p in put_paths)
    assert any("report.md" in p for p in put_paths)
    assert len(result.files) == 2


def test_publish_records_audit_run(engine):
    bid, vid = _seed(engine)
    ws = _FakeUserWs()
    cfg = _oauth_cfg()
    with Session(engine) as session:
        publish_model_version(
            ws, cfg, session=session, business_id=bid, version_id=vid
        )
    with Session(engine) as session:
        from sqlmodel import select

        runs = session.exec(
            select(Run).where(Run.intent == "publish-to-github")
        ).all()
    assert len(runs) == 1
    assert runs[0].status == "completed"
    assert runs[0].version_id == vid
    params = json.loads(runs[0].parameters_json)
    assert params["pr_number"] == 7


# --- Endpoint-level 422 guard ----------------------------------------------


def test_publish_endpoint_422_connection_missing(engine):
    """The route returns 422 github_connection_missing when no UC connection
    is configured (the human-gated step), with OBO + role deps overridden."""
    from fastapi.testclient import TestClient

    from vibe_modeling.backend.core._defaults import _get_user_ws
    from vibe_modeling.backend.core._roles import require_modeler
    from vibe_modeling.backend.core.lakebase import _LakebaseDependency
    from vibe_modeling.backend.routes.industry_models import router as im_router

    bid, vid = _seed(engine)
    # No AgentConfig row -> cfg falls back to empty AgentConfig() -> guard 422.

    app = make_test_app(im_router)

    def override_session():
        with Session(engine) as session:
            yield session

    app.dependency_overrides[_LakebaseDependency.__call__] = override_session
    app.dependency_overrides[_get_user_ws] = lambda: _FakeUserWs()
    app.dependency_overrides[require_modeler] = lambda: MagicMock()

    client = TestClient(app)
    resp = client.post(
        f"/api/businesses/{bid}/model-versions/{vid}/publish"
    )
    assert resp.status_code == 422, resp.text
    assert resp.json()["detail"]["error"] == "github_connection_missing"


# --- resolve_bundle_root precedence (ADR D-049) ----------------------------


def test_bundle_root_override_wins(engine):
    """A non-blank override is returned VERBATIM — no scope_vN re-derivation."""
    from vibe_modeling.backend.model_export import resolve_bundle_root

    with Session(engine) as session:
        biz = Business(
            name="Test Retail", industry_alignment="Retail",
            source_repo_path="github://o/r@main/capital_markets",
        )
        session.add(biz)
        session.flush()
        root = resolve_bundle_root(
            override="caps/ecm_v9", business=biz, scope="ecm", version=2
        )
    assert root == "caps/ecm_v9"


def test_bundle_root_roundtrips_source_repo_path_appends_scope_vN(engine):
    """No override -> take source_repo_path's last segment, build the nested v{N}/scope root."""
    from vibe_modeling.backend.model_export import resolve_bundle_root

    with Session(engine) as session:
        biz = Business(
            name="Test Retail", industry_alignment="Retail",
            source_repo_path="github://o/r@main/capital_markets",
        )
        session.add(biz)
        session.flush()
        root = resolve_bundle_root(
            override=None, business=biz, scope="ecm", version=3
        )
    assert root == "capital_markets/v3/ecm"


def test_bundle_root_ignores_industry_alignment(engine):
    """industry_alignment must NEVER be consulted: a business with
    industry_alignment set but no source_repo_path + no override -> name-based
    fallback (resolve returns name-derived root, NOT 'retail/...')."""
    from vibe_modeling.backend.model_export import resolve_bundle_root

    with Session(engine) as session:
        biz = Business(
            name="Test Retail", industry_alignment="Retail",
            source_repo_path=None,
        )
        session.add(biz)
        session.flush()
        root = resolve_bundle_root(
            override=None, business=biz, scope="ecm", version=2
        )
    # Falls back to the business NAME, not industry_alignment ("retail/...").
    assert root == "test_retail/v2/ecm"


def test_bundle_root_falls_back_to_name(engine):
    """No override, no source_repo_path -> name-derived root."""
    from vibe_modeling.backend.model_export import resolve_bundle_root

    with Session(engine) as session:
        biz = Business(name="Test Retail", description="demo")
        session.add(biz)
        session.flush()
        root = resolve_bundle_root(
            override=None, business=biz, scope="mvm", version=5
        )
    assert root == "test_retail/v5/mvm"


# --- bundle_layout dir_override --------------------------------------------


def test_bundle_layout_dir_override_replaces_dir_and_model_json():
    """dir_override is used RAW (strip surrounding '/'); no agent_business_segment."""
    layout = model_export.bundle_layout(
        "ignored", "ecm", 2, dir_override="/Custom-Path/ecm_v9/"
    )
    assert layout.dir == "Custom-Path/ecm_v9"
    assert layout.model_json_path == "Custom-Path/ecm_v9/model.json"


def test_bundle_layout_without_override_unchanged():
    layout = model_export.bundle_layout("Retail", "ecm", 2)
    assert layout.dir == "retail/v2/ecm"
    assert layout.model_json_path == "retail/v2/ecm/model.json"


# --- publish override / round-trip / target_path ---------------------------


def test_publish_override_replaces_whole_root(engine):
    bid, vid = _seed(engine)
    ws = _FakeUserWs()
    cfg = _oauth_cfg()
    with Session(engine) as session:
        result = publish_model_version(
            ws, cfg, session=session, business_id=bid, version_id=vid,
            target_path="custom/dir_v5",
        )
    put_paths = [
        c["path"]
        for c in ws.serving_endpoints.calls
        if c["method"] is ExternalFunctionRequestHttpMethod.PUT
    ]
    assert put_paths
    for p in put_paths:
        assert "/custom/dir_v5/" in p
    assert result.target_path == "custom/dir_v5"


def test_publish_roundtrips_from_source_repo_path(engine):
    with Session(engine) as session:
        biz = Business(
            name="Test Retail", industry_alignment="Retail", description="demo",
            source_repo_path="github://o/r@main/capital_markets",
        )
        session.add(biz)
        session.flush()
        mv = ModelVersion(
            business_id=biz.id, version=2, scope="ecm", status="completed"
        )
        session.add(mv)
        session.flush()
        ModelSyncService(session).sync_from_model_json(mv.id, SAMPLE_MODEL)
        session.commit()
        bid, vid = biz.id, mv.id

    ws = _FakeUserWs()
    cfg = _oauth_cfg()
    with Session(engine) as session:
        result = publish_model_version(
            ws, cfg, session=session, business_id=bid, version_id=vid
        )
    put_paths = [
        c["path"]
        for c in ws.serving_endpoints.calls
        if c["method"] is ExternalFunctionRequestHttpMethod.PUT
    ]
    assert any(p.endswith("capital_markets/v2/ecm/model.json") for p in put_paths)
    assert result.target_path == "capital_markets/v2/ecm"


def test_publish_falls_back_to_name_not_industry_alignment(engine):
    """The _seed business has industry_alignment='Retail' but name='Test Retail'
    and no source_repo_path — published paths must use the NAME segment."""
    bid, vid = _seed(engine)
    ws = _FakeUserWs()
    cfg = _oauth_cfg()
    with Session(engine) as session:
        result = publish_model_version(
            ws, cfg, session=session, business_id=bid, version_id=vid
        )
    put_paths = [
        c["path"]
        for c in ws.serving_endpoints.calls
        if c["method"] is ExternalFunctionRequestHttpMethod.PUT
    ]
    for p in put_paths:
        assert "/test_retail/v2/ecm/" in p
    assert result.target_path == "test_retail/v2/ecm"


def test_publish_result_carries_target_path(engine):
    bid, vid = _seed(engine)
    ws = _FakeUserWs()
    cfg = _oauth_cfg()
    with Session(engine) as session:
        result = publish_model_version(
            ws, cfg, session=session, business_id=bid, version_id=vid
        )
    assert result.target_path == "test_retail/v2/ecm"


# --- publish vs zip parity for a downloaded industry -----------------------


def test_publish_root_matches_zip_root_for_downloaded_industry(engine):
    """The publish tree and the downloadable zip derive their bundle root from
    the SAME resolver, so a downloaded industry round-trips identically."""
    from vibe_modeling.backend.model_export import resolve_bundle_root

    with Session(engine) as session:
        biz = Business(
            name="Test Retail", industry_alignment="Retail", description="demo",
            source_repo_path="github://o/r@main/capital_markets",
        )
        session.add(biz)
        session.flush()
        mv = ModelVersion(
            business_id=biz.id, version=2, scope="ecm", status="completed"
        )
        session.add(mv)
        session.flush()
        ModelSyncService(session).sync_from_model_json(mv.id, SAMPLE_MODEL)
        session.commit()
        bid, vid = biz.id, mv.id

    ws = _FakeUserWs()
    cfg = _oauth_cfg()
    with Session(engine) as session:
        publish_result = publish_model_version(
            ws, cfg, session=session, business_id=bid, version_id=vid
        )
        biz = session.get(Business, bid)
        mv = session.get(ModelVersion, vid)
        zip_root = resolve_bundle_root(
            override=None, business=biz, scope=mv.scope or "", version=mv.version
        )
    assert publish_result.target_path == zip_root == "capital_markets/v2/ecm"


# --- iter_bundle_files parity with build_bundle_zip_bytes ------------------


def test_iter_bundle_files_matches_zip_entries(engine):
    """The publish tree (iter_bundle_files) and the downloadable zip
    (build_bundle_zip_bytes) MUST enumerate the exact same entries — they
    share the one iterator, so they can't diverge."""
    bid, vid = _seed(engine, with_artifact=True)
    ws = _FakeUserWs()
    with Session(engine) as session:
        model_json = model_export.export_model_json(session, vid)
        mv = session.get(ModelVersion, vid)
        from sqlmodel import select

        artifacts = session.exec(
            select(RunArtifact).where(RunArtifact.model_version_id == vid)
        ).all()
    layout = model_export.bundle_layout("Retail", mv.scope, mv.version)

    iter_paths = [
        path for path, _ in model_export.iter_bundle_files(
            ws, layout, model_json, artifacts
        )
    ]
    body = model_export.build_bundle_zip_bytes(ws, layout, model_json, artifacts)
    with zipfile.ZipFile(io.BytesIO(body)) as zf:
        zip_paths = zf.namelist()

    assert sorted(iter_paths) == sorted(zip_paths)
    assert any(p.endswith("model.json") for p in iter_paths)
    assert any(p.endswith("report.md") for p in iter_paths)

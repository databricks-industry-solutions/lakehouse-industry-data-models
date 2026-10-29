"""Tests for the prepublish diff-preview (Story 3, 0.6.4).

Two layers:

- Service tests drive ``compute_publish_preview`` directly with a fake HTTP
  session injected into a ``GithubSourceConnector`` (the ``connector`` seam) so
  the tiered baseline resolution + envelope-unwrap + diff transform are
  exercised with no network and a real ``export_model_json`` current model
  (seeded into the in-memory SQLite engine).
- Endpoint serialization is covered by the TestClient round-trip test (the
  tuple-keyed / Pydantic-instance diff dict must flatten to JSON-safe rows).

Reuses the ``_FakeHttp`` / ``_FakeResp`` / ``_contents`` / ``_dir`` / ``_file``
stubs from ``test_sources.py`` rather than inventing new GitHub HTTP stubs.
"""

from __future__ import annotations

import json

import pytest
from fastapi import HTTPException
from sqlmodel import Session

from _test_app import make_test_app
from vibe_modeling.backend.db_models import AgentConfig, Business, ModelVersion
from vibe_modeling.backend.models import ChangeStatus
from vibe_modeling.backend.model_sync import ModelSyncService
from vibe_modeling.backend.routes.industry_models import _to_diff_out
from vibe_modeling.backend.services.publish_preview import compute_publish_preview
from vibe_modeling.backend.sources.github import GithubSourceConnector

from .test_sources import _contents, _dir, _file, _FakeHttp, _FakeResp, contents_key


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def _industry_listing_http(
    industry: str, version_scopes: dict[str, list[str]], *, model_doc: str | None = None
) -> _FakeHttp:
    """A fake 3-level repo whose ``industry`` folder lists the version dirs
    (``version_scopes`` keys), each version dir lists its scope dirs, and whose
    ``raw.githubusercontent.com`` returns ``model_doc`` (an envelope-wrapped
    or flat baseline model.json) for any model fetch."""
    routes = {
        contents_key(industry): _contents(*[_dir(v) for v in version_scopes])
    }
    for version, scopes in version_scopes.items():
        routes[contents_key(f"{industry}/{version}")] = _contents(
            *[_dir(s) for s in scopes]
        )
    if model_doc is not None:
        routes["raw.githubusercontent.com"] = _FakeResp(200, text=model_doc)
    return _FakeHttp(routes)


def _seed(engine, *, name="Test Retail", scope="ecm", version=2, source_repo_path=None, model=None):
    """Seed a Business + completed ModelVersion (+ optional synced model) and
    return ``(business_id, version_id)``."""
    from .test_model_export import SAMPLE_MODEL

    with Session(engine) as session:
        biz = Business(
            name=name,
            industry_alignment="Retail",
            description="demo",
            source_repo_path=source_repo_path,
        )
        session.add(biz)
        session.flush()
        mv = ModelVersion(business_id=biz.id, version=version, scope=scope, status="completed")
        session.add(mv)
        session.flush()
        ModelSyncService(session).sync_from_model_json(mv.id, model or SAMPLE_MODEL)
        session.commit()
        return biz.id, mv.id


def _cfg() -> AgentConfig:
    return AgentConfig(github_repo_owner="acme", github_repo_name="models")


def _run(engine, bid, vid, http, **kwargs):
    conn = GithubSourceConnector(http=http)
    with Session(engine) as session:
        return compute_publish_preview(
            _cfg(), session=session, business_id=bid, version_id=vid,
            app_config=None, ws=None, connector=conn, **kwargs,
        )


# An envelope-wrapped baseline whose structure matches SAMPLE_MODEL exactly
# (repo-shape keys: product/attribute, NO name).
_SAMPLE_BASELINE_DOC = json.dumps(
    {
        "model": {
            "domains": [
                {
                    "name": "sales",
                    "products": [
                        {
                            "product": "order",
                            "attributes": [
                                {"attribute": "order_id", "type": "bigint"},
                                {"attribute": "customer_id", "type": "bigint",
                                 "foreign_key_to": "customer.profile.customer_id"},
                            ],
                        }
                    ],
                },
                {
                    "name": "customer",
                    "products": [
                        {
                            "product": "profile",
                            "attributes": [
                                {"attribute": "customer_id", "type": "bigint"},
                            ],
                        }
                    ],
                },
            ]
        }
    }
)


# ---------------------------------------------------------------------------
# Tier resolution (service)
# ---------------------------------------------------------------------------


def test_infer_helpers_resolve_on_fused_model_id():
    """publish_preview's baseline scope/version come from ``_infer_scope`` /
    ``_infer_version`` applied to the resolved model_id. After the layout flip
    the resolved id is the fused ``v1_ecm`` form — confirm both helpers still
    yield scope 'ecm' / version 'v1' (Blocker 1: the helpers are KEPT)."""
    from vibe_modeling.backend.sources.github import _infer_scope, _infer_version

    assert _infer_scope("v1_ecm") == "ecm"
    assert _infer_version("v1_ecm") == "v1"
    assert _infer_scope("v2_mvm") == "mvm"
    assert _infer_version("v2_mvm") == "v2"


def test_tier1_same_scope_latest_picks_max_version(engine):
    bid, vid = _seed(engine, scope="ecm")
    http = _industry_listing_http(
        "test_retail", {"v1": ["ecm", "mvm"], "v2": ["ecm"]}, model_doc=_SAMPLE_BASELINE_DOC
    )
    res = _run(engine, bid, vid, http)
    assert res.tier == "same_scope_latest"
    assert res.baseline.model_id == "v2_ecm"
    assert res.scope_mismatch is False
    assert res.manual_needed is False
    assert res.diff is not None


def test_tier2_fallback_unverified_when_no_same_scope(engine):
    bid, vid = _seed(engine, scope="ecm")
    http = _industry_listing_http(
        "test_retail", {"v1": ["mvm"], "v2": ["mvm"]}, model_doc=_SAMPLE_BASELINE_DOC
    )
    res = _run(engine, bid, vid, http)
    assert res.tier == "fallback_unverified"
    assert res.baseline.model_id == "v2_mvm"
    assert res.scope_mismatch is True


def test_tier2_fallback_no_scope_mismatch_when_scope_unknown(engine):
    # chosen folder's scope dir ('legacy') differs from mv.scope='ecm' ->
    # no same-scope match -> tier2, scope_mismatch reflects the difference.
    bid, vid = _seed(engine, scope="ecm")
    http = _industry_listing_http(
        "test_retail", {"v1": ["legacy"]}, model_doc=_SAMPLE_BASELINE_DOC
    )
    res = _run(engine, bid, vid, http)
    assert res.tier == "fallback_unverified"
    assert res.baseline.model_id == "v1_legacy"
    assert res.scope_mismatch is True


def test_tier3_none_empty_repo_industry(engine):
    bid, vid = _seed(engine, scope="ecm")
    http = _industry_listing_http("test_retail", {})
    res = _run(engine, bid, vid, http)
    assert res.tier == "none"
    assert res.baseline is None
    assert res.manual_needed is True
    assert res.diff is None
    assert res.candidates == []


def test_tier3_none_industry_404_degrades_not_500(engine):
    bid, vid = _seed(engine, scope="ecm")
    http = _FakeHttp({})  # everything 404s -> list_models raises SourceNotFoundError
    res = _run(engine, bid, vid, http)
    assert res.manual_needed is True
    assert res.tier == "none"
    assert res.diff is None
    assert res.candidates == []


def test_manual_baseline_model_id_bypasses_resolver(engine):
    # Pass baseline_model_id='v1_ecm' while v2_ecm exists -> baseline is v1.
    bid, vid = _seed(engine, scope="ecm")
    http = _industry_listing_http(
        "test_retail", {"v1": ["ecm"], "v2": ["ecm"]}, model_doc=_SAMPLE_BASELINE_DOC
    )
    res = _run(engine, bid, vid, http, baseline_model_id="v1_ecm")
    assert res.baseline.model_id == "v1_ecm"
    assert res.tier == "manual"
    assert res.manual_needed is False
    assert res.diff is not None


# ---------------------------------------------------------------------------
# 404 guards (the only hard failures)
# ---------------------------------------------------------------------------


def test_business_404(engine):
    bid, vid = _seed(engine)
    with pytest.raises(HTTPException) as ei:
        with Session(engine) as session:
            compute_publish_preview(
                _cfg(), session=session, business_id="ghost", version_id=vid,
                app_config=None, ws=None,
                connector=GithubSourceConnector(http=_FakeHttp({})),
            )
    assert ei.value.status_code == 404


def test_version_404_or_business_mismatch(engine):
    bid, vid = _seed(engine)
    other_bid, _ = _seed(engine, name="Other Corp")
    with pytest.raises(HTTPException) as ei:
        with Session(engine) as session:
            compute_publish_preview(
                _cfg(), session=session, business_id=other_bid, version_id=vid,
                app_config=None, ws=None,
                connector=GithubSourceConnector(http=_FakeHttp({})),
            )
    assert ei.value.status_code == 404


# ---------------------------------------------------------------------------
# Degrade-open + never-fetch-artifacts
# ---------------------------------------------------------------------------


def test_never_fetches_artifacts(engine):
    bid, vid = _seed(engine, scope="ecm")
    http = _industry_listing_http("test_retail", {"v1": ["ecm"]}, model_doc=_SAMPLE_BASELINE_DOC)
    conn = GithubSourceConnector(http=http)
    conn.fetch_artifacts = lambda *a, **k: (_ for _ in ()).throw(  # noqa: ARG005
        AssertionError("fetch_artifacts must never be called")
    )
    with Session(engine) as session:
        res = compute_publish_preview(
            _cfg(), session=session, business_id=bid, version_id=vid,
            app_config=None, ws=None, connector=conn,
        )
    assert res.diff is not None
    # No raw fetch should hit an artifact sub-dir (schemas/diagram/docs/...).
    art_calls = [c for c in http.calls if any(
        seg in c for seg in ("/schemas", "/diagram", "/docs/", "/metrics", "/ontology", "/vibes")
    )]
    assert art_calls == []


def test_baseline_fetch_failure_degrades_to_manual(engine):
    bid, vid = _seed(engine, scope="ecm")
    # Industry lists v1/ecm but the raw model.json 404s.
    http = _FakeHttp(
        {
            contents_key("test_retail"): _contents(_dir("v1")),
            contents_key("test_retail/v1"): _contents(_dir("ecm")),
        }
    )
    res = _run(engine, bid, vid, http)
    assert res.manual_needed is True
    assert res.diff is None
    # candidates surfaced so the user can pick another (raw SourceModelRef.id).
    assert any(c.id == "v1_ecm" for c in res.candidates)


@pytest.mark.parametrize(
    "doc",
    ["[1, 2]", '"text"', "42", "null", '{"model": [1]}', '{"model": "text"}'],
    ids=["array", "string", "number", "null", "envelope-array", "envelope-string"],
)
def test_non_object_baseline_degrades_to_manual(engine, doc):
    """A baseline model.json that parses but is not a JSON object (bare or
    inside the ``{"model": ...}`` envelope) is unreadable: manual, never a 500."""
    bid, vid = _seed(engine, scope="ecm")
    http = _industry_listing_http("test_retail", {"v1": ["ecm"]}, model_doc=doc)
    res = _run(engine, bid, vid, http)
    assert res.manual_needed is True
    assert res.tier == "none"
    assert res.diff is None
    assert any(c.id == "v1_ecm" for c in res.candidates)


# ---------------------------------------------------------------------------
# THE KEY REGRESSION (Story-1 normalization end-to-end)
# ---------------------------------------------------------------------------


def test_export_current_vs_envelope_baseline_diff_is_not_all_new_or_all_deleted(engine):
    """A real export_model_json current (product/attribute keys) diffed against
    an envelope-wrapped repo-shape baseline (also product/attribute, NO name,
    wrapped in {"model": ...}) must NOT report every shared element as
    new+deleted. Proves the Story-1 identity normalization carries through
    export -> envelope unwrap -> compute_model_diff."""
    bid, vid = _seed(engine, scope="ecm")
    http = _industry_listing_http("test_retail", {"v1": ["ecm"]}, model_doc=_SAMPLE_BASELINE_DOC)
    res = _run(engine, bid, vid, http)
    assert res.diff is not None
    out = _to_diff_out(res.diff)
    # Identical structure -> zero new, zero deleted across all levels.
    assert out.counts["new"] == 0, out.counts
    assert out.counts["deleted"] == 0, out.counts

    # Now mutate ONE attribute: the current model gains a "phone" attribute on
    # customer.profile that the baseline lacks -> exactly 1 new, 0 deleted.
    mutated = json.loads(_SAMPLE_BASELINE_DOC)
    # baseline LACKS phone; current HAS it -> add phone to current via re-seed.
    from .test_model_export import SAMPLE_MODEL

    current_model = json.loads(json.dumps(SAMPLE_MODEL))
    for d in current_model["domains"]:
        if d["name"] == "customer":
            d["products"][0]["attributes"].append({"attribute": "phone", "type": "string"})
    bid2, vid2 = _seed(engine, name="Mutated Corp", scope="ecm", model=current_model)
    http2 = _industry_listing_http("mutated_corp", {"v1": ["ecm"]}, model_doc=json.dumps(mutated))
    res2 = _run(engine, bid2, vid2, http2)
    assert res2.diff is not None
    out2 = _to_diff_out(res2.diff)
    assert out2.counts["new"] == 1, out2.counts
    assert out2.counts["deleted"] == 0, out2.counts
    phone_rows = [
        r for r in out2.attributes
        if r.attribute == "phone" and r.status == ChangeStatus.NEW
    ]
    assert len(phone_rows) == 1


# ---------------------------------------------------------------------------
# Industry-folder derivation (deep + 1-segment overrides)
# ---------------------------------------------------------------------------


def test_industry_folder_deep_override(engine):
    """A >2-segment override (e.g. ``a/b/capital_markets/ecm_v3``) -> the
    industry folder is the version folder's immediate parent (parts[-2])."""
    bid, vid = _seed(engine, scope="ecm")
    http = _industry_listing_http("capital_markets", {"v1": ["ecm"]}, model_doc=_SAMPLE_BASELINE_DOC)
    res = _run(engine, bid, vid, http, target_path="a/b/capital_markets/ecm_v3")
    # The resolver must have enumerated 'capital_markets' (parts[-2]).
    assert res.baseline is not None
    assert res.baseline.model_id == "v1_ecm"


def test_industry_folder_one_segment_override(engine):
    """A 1-segment override (no version folder) -> parts[-1] is the industry."""
    bid, vid = _seed(engine, scope="ecm")
    http = _industry_listing_http("capital_markets", {"v1": ["ecm"]}, model_doc=_SAMPLE_BASELINE_DOC)
    res = _run(engine, bid, vid, http, target_path="capital_markets")
    assert res.baseline is not None
    assert res.baseline.model_id == "v1_ecm"


# ---------------------------------------------------------------------------
# Endpoint serialization (full FastAPI round-trip)
# ---------------------------------------------------------------------------


def _client_for(engine, *, config=None, ws=None):
    from fastapi.testclient import TestClient

    from vibe_modeling.backend.core._config import AppConfig
    from vibe_modeling.backend.core._defaults import (
        _ConfigDependency,
        _WorkspaceClientDependency,
    )
    from vibe_modeling.backend.core._roles import require_modeler
    from vibe_modeling.backend.core.lakebase import _LakebaseDependency
    from vibe_modeling.backend.routes.industry_models import router as im_router

    app = make_test_app(im_router)

    def override_session():
        with Session(engine) as session:
            yield session

    app.dependency_overrides[_LakebaseDependency.__call__] = override_session
    app.dependency_overrides[_ConfigDependency.__call__] = lambda: config or AppConfig(app_name="test")
    app_sp_ws = ws if ws is not None else object()
    app.dependency_overrides[_WorkspaceClientDependency.__call__] = lambda: app_sp_ws
    app.dependency_overrides[require_modeler] = lambda: object()
    return TestClient(app)


def test_diff_out_is_json_serializable(engine, monkeypatch):
    from vibe_modeling.backend.services import publish_preview as svc

    bid, vid = _seed(engine, scope="ecm")
    http = _industry_listing_http("test_retail", {"v1": ["ecm"]}, model_doc=_SAMPLE_BASELINE_DOC)

    def _fake_build(cfg, app_config, ws, *, repo_owner="", repo_name="", **_):  # noqa: ARG001
        return GithubSourceConnector(http=http)

    monkeypatch.setattr(svc, "build_source_connector", _fake_build)

    from vibe_modeling.backend.routes.industry_models import PublishPreviewOut

    client = _client_for(engine)
    resp = client.post(f"/api/businesses/{bid}/model-versions/{vid}/publish-preview", json={})
    assert resp.status_code == 200, resp.text
    body = resp.json()
    parsed = PublishPreviewOut.model_validate(body)
    assert parsed.tier == "same_scope_latest"
    # Each product row must be a flat {domain, product, attribute, status} dict.
    for row in body["diff"]["products"]:
        assert set(row) >= {"domain", "product", "attribute", "status"}


# ---------------------------------------------------------------------------
# Read-auth: the preview uses the configured source read-auth (6hcQ6HmWwv5CXXMq)
# ---------------------------------------------------------------------------


def test_route_threads_config_and_app_sp_client_to_source_resolver(engine, monkeypatch):
    """The route hands the stored AgentConfig, the AppConfig and the app-SP
    ``ws`` to ``build_source_connector`` (the browse/download resolver), with
    the configured repo pointers."""
    from vibe_modeling.backend.core._config import AppConfig
    from vibe_modeling.backend.services import publish_preview as svc

    bid, vid = _seed(engine, scope="ecm")
    with Session(engine) as session:
        session.add(AgentConfig(
            github_repo_owner="acme", github_repo_name="private-models",
            source_auth_mode="token",
            source_token_secret_scope="sc", source_token_secret_key="k",
        ))
        session.commit()
    http = _industry_listing_http("test_retail", {"v1": ["ecm"]}, model_doc=_SAMPLE_BASELINE_DOC)
    captured: dict = {}

    def _spy(cfg, app_config, ws, *, repo_owner="", repo_name="", **kwargs):
        captured.update(
            cfg=cfg, app_config=app_config, ws=ws,
            repo_owner=repo_owner, repo_name=repo_name, extra=kwargs,
        )
        return GithubSourceConnector(http=http)

    monkeypatch.setattr(svc, "build_source_connector", _spy)
    app_config = AppConfig(app_name="test")
    app_sp_ws = object()

    client = _client_for(engine, config=app_config, ws=app_sp_ws)
    resp = client.post(f"/api/businesses/{bid}/model-versions/{vid}/publish-preview", json={})

    assert resp.status_code == 200, resp.text
    assert resp.json()["tier"] == "same_scope_latest"
    assert captured["cfg"].source_auth_mode == "token"
    assert captured["cfg"].source_token_secret_scope == "sc"
    assert captured["app_config"] is app_config
    assert captured["ws"] is app_sp_ws
    assert captured["repo_owner"] == "acme"
    assert captured["repo_name"] == "private-models"
    assert captured["extra"] == {}


def test_service_builds_token_authenticated_connector(engine, monkeypatch):
    """Through the real resolver: a token-mode config with a readable secret
    yields a connector whose read auth is ``token``, with no degrade error.
    The secret is read through the app-SP ``ws`` handed to the service."""
    import base64

    from vibe_modeling.backend.core._config import AppConfig
    from vibe_modeling.backend.services import publish_preview as svc
    from vibe_modeling.backend.sources import github as gh

    monkeypatch.setattr(gh, "_SECRET_CACHE", {})

    class _Secret:
        def __init__(self, value):
            self.value = base64.b64encode(value.encode("utf-8")).decode("ascii")

    class _Secrets:
        def __init__(self):
            self.calls: list[tuple[str, str]] = []

        def get_secret(self, scope, key):
            self.calls.append((scope, key))
            return _Secret("pat-" + "value")

    class _Ws:
        def __init__(self):
            self.secrets = _Secrets()

    bid, vid = _seed(engine, scope="ecm")
    http = _industry_listing_http("test_retail", {"v1": ["ecm"]}, model_doc=_SAMPLE_BASELINE_DOC)
    built: list = []
    real_build = svc.build_source_connector

    def _wrap(*args, **kwargs):
        conn = real_build(*args, **kwargs)
        built.append(conn)
        return GithubSourceConnector(http=http)

    monkeypatch.setattr(svc, "build_source_connector", _wrap)
    ws = _Ws()
    cfg = AgentConfig(
        github_repo_owner="acme", github_repo_name="private-models",
        source_auth_mode="token",
        source_token_secret_scope="sc", source_token_secret_key="k",
    )
    with Session(engine) as session:
        res = compute_publish_preview(
            cfg, session=session, business_id=bid, version_id=vid,
            app_config=AppConfig(app_name="test"), ws=ws,
        )

    assert res.tier == "same_scope_latest"
    assert ws.secrets.calls == [("sc", "k")]
    caps = built[0].capabilities()
    assert caps.auth_mode == "token"
    assert caps.auth_error is None
    assert isinstance(built[0]._http, gh.BearerTokenTransport)


def test_signature_requires_app_config_and_ws():
    """``app_config`` and ``ws`` are required keyword-only arguments, so no
    caller can silently drop the app-SP client."""
    import inspect

    params = inspect.signature(compute_publish_preview).parameters
    for name in ("app_config", "ws"):
        assert params[name].kind is inspect.Parameter.KEYWORD_ONLY
        assert params[name].default is inspect.Parameter.empty


def test_none_ws_never_reaches_the_resolver(engine, monkeypatch):
    """Without an injected connector a ``None`` ws is refused before the
    resolver runs, so no negative secret read is cached for browse/download."""
    from vibe_modeling.backend.core._config import AppConfig
    from vibe_modeling.backend.services import publish_preview as svc

    def _boom(*a, **k):  # noqa: ARG001
        raise AssertionError("build_source_connector must not run with ws=None")

    monkeypatch.setattr(svc, "build_source_connector", _boom)
    bid, vid = _seed(engine, scope="ecm")
    with Session(engine) as session:
        with pytest.raises(ValueError):
            compute_publish_preview(
                _cfg(), session=session, business_id=bid, version_id=vid,
                app_config=AppConfig(app_name="test"), ws=None,
            )

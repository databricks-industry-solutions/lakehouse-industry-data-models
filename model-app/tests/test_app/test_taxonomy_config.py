"""Domain Taxonomy Builder settings: /config/taxonomy (GET/PUT), the Test
button, the model-services picker, the probe cache, the config_missing
helper, and the boot seed."""

import asyncio
import threading
from unittest.mock import MagicMock

import pytest
from databricks.sdk.errors import NotFound, PermissionDenied, TooManyRequests
from fastapi import FastAPI, HTTPException
from fastapi.testclient import TestClient
from sqlalchemy.pool import StaticPool
from sqlmodel import Session, SQLModel, create_engine, select

from _test_app import make_test_app
from vibe_modeling.backend.core._config import AppConfig
from vibe_modeling.backend.core._defaults import _ConfigDependency, _WorkspaceClientDependency
from vibe_modeling.backend.core._roles import UserRole, resolve_user_role
from vibe_modeling.backend.core._taxonomy_seed import seed_taxonomy_model_service
from vibe_modeling.backend.core.lakebase import _LakebaseDependency
from vibe_modeling.backend.db_models import AgentConfig
from vibe_modeling.backend.routes import config as config_routes
from vibe_modeling.backend.routes import taxonomy as taxonomy_routes
from vibe_modeling.backend.taxonomy import llm as llm_module
from vibe_modeling.backend.core._errors import config_missing_error
from vibe_modeling.backend.routes._helpers import (
    _get_or_create_agent_config,
    require_config,
)
from vibe_modeling.backend.taxonomy.access import MODEL_SERVICE_ACCESS, ModelServiceAccess
from vibe_modeling.backend.taxonomy.llm import ProbeResult
from vibe_modeling.backend.taxonomy.slots import TAXONOMY_SLOTS, LLMSlots

SERVICE = "main.ai.drafter"
DEFAULT = "system.ai.claude-sonnet-5-5"
SP_ID = "11111111-2222-3333-4444-555555555555"
OK_REPLY = {"choices": [{"message": {"role": "assistant", "content": "OK"}}]}


def _from(outer, inner):
    try:
        raise outer from inner
    except type(outer) as e:
        return e


@pytest.fixture(autouse=True)
def _fresh_state():
    MODEL_SERVICE_ACCESS.clear()
    yield
    MODEL_SERVICE_ACCESS.clear()
    TAXONOMY_SLOTS.set_capacity(6)


@pytest.fixture
def engine():
    eng = create_engine("sqlite://", connect_args={"check_same_thread": False}, poolclass=StaticPool)
    SQLModel.metadata.create_all(eng)
    return eng


@pytest.fixture
def llm_ws(monkeypatch):
    """The LLM client (taxonomy/llm._LLM_WS): gateway POSTs answer OK unless
    a test sets ``post_exc``."""
    ws = MagicMock()
    ws.config.client_id = SP_ID
    ws.post_exc = None
    ws.get_result = {"name": f"model-services/{SERVICE}"}

    def do(method, path, **kw):
        if method == "POST":
            if ws.post_exc is not None:
                raise ws.post_exc
            return OK_REPLY
        if isinstance(ws.get_result, Exception):
            raise ws.get_result
        return ws.get_result

    ws.api_client.do.side_effect = do
    monkeypatch.setattr(llm_module, "_LLM_WS", ws)
    return ws


def _client(engine, *, installed=True, default="", role=UserRole.APP_ADMIN, app_ws=None) -> TestClient:
    app = make_test_app(config_routes.router, taxonomy_routes.router)
    config = AppConfig(taxonomy_builder_enabled=installed, taxonomy_model_service=default)

    def _session():
        with Session(engine) as s:
            yield s

    app.dependency_overrides[_LakebaseDependency.__call__] = _session
    app.dependency_overrides[_ConfigDependency.__call__] = lambda: config
    app.dependency_overrides[_WorkspaceClientDependency.__call__] = lambda: app_ws or MagicMock()
    app.dependency_overrides[resolve_user_role] = lambda: role
    return TestClient(app)


def _stored(engine):
    with Session(engine) as s:
        return s.exec(select(AgentConfig)).first()


def _seed_row(engine, service="", concurrency=6):
    with Session(engine) as s:
        s.add(AgentConfig(taxonomy_model_service=service, taxonomy_llm_max_concurrency=concurrency))
        s.commit()


# --- GET /config/taxonomy ---------------------------------------------------


def test_get_not_installed(engine):
    body = _client(engine, installed=False).get("/api/config/taxonomy").json()
    assert body == {
        "installed": False, "model_service": "", "install_default_model_service": "",
        "max_concurrency": 6, "ready": False, "last_check": None, "updated_by": None, "updated_at": None,
    }


def test_get_not_installed_never_reads_or_creates_the_agent_config_row(engine):
    _seed_row(engine, service=SERVICE)
    MODEL_SERVICE_ACCESS.record(SERVICE, ProbeResult("denied", "no"))
    body = _client(engine, installed=False, default=DEFAULT).get("/api/config/taxonomy").json()
    assert body["model_service"] == "" and body["last_check"] is None


def test_get_not_installed_on_an_empty_db_creates_no_row(engine):
    _client(engine, installed=False).get("/api/config/taxonomy")
    assert _stored(engine) is None


def test_get_installed_with_default_seeds_new_row(engine):
    body = _client(engine, default=DEFAULT).get("/api/config/taxonomy").json()
    assert body == {
        "installed": True, "model_service": DEFAULT, "install_default_model_service": DEFAULT,
        "max_concurrency": 6, "ready": True, "last_check": None, "updated_by": None, "updated_at": None,
    }


def test_get_installed_without_service_is_not_ready(engine):
    body = _client(engine).get("/api/config/taxonomy").json()
    assert body["installed"] is True and body["ready"] is False and body["model_service"] == ""


@pytest.mark.parametrize("role", [UserRole.MODELER, UserRole.VIEWER])
def test_get_is_open_to_every_role(engine, role):
    assert _client(engine, role=role).get("/api/config/taxonomy").status_code == 200


# --- ready: the one switch for offering the wizard ---------------------------


def _ready(c) -> bool:
    return c.get("/api/config/taxonomy").json()["ready"]


def test_ready_false_when_not_installed_even_with_a_service(engine):
    _seed_row(engine, service=SERVICE)
    assert _ready(_client(engine, installed=False)) is False


def test_ready_true_when_set_and_never_checked(engine):
    _seed_row(engine, service=SERVICE)
    assert _ready(_client(engine)) is True


@pytest.mark.parametrize(
    "status,expected",
    [("ok", True), ("busy", True), ("denied", False), ("not_found", False), ("error", False)],
)
def test_ready_follows_the_last_check(engine, status, expected):
    _seed_row(engine, service=SERVICE)
    MODEL_SERVICE_ACCESS.record(SERVICE, ProbeResult(status, status))
    assert _ready(_client(engine)) is expected


def test_ready_ignores_a_refusal_of_another_service(engine):
    _seed_row(engine, service=SERVICE)
    MODEL_SERVICE_ACCESS.record("other.svc.name", ProbeResult("denied", "no"))
    assert _ready(_client(engine)) is True


def test_revoked_access_hides_until_a_successful_test(engine, llm_ws):
    _seed_row(engine, service=SERVICE)
    c = _client(engine)
    llm_ws.post_exc = PermissionDenied("User does not have permission to use model service")
    assert c.post("/api/config/taxonomy/test").json()["status"] == "denied"
    assert _ready(c) is False
    llm_ws.post_exc = None
    assert c.post("/api/config/taxonomy/test").json()["status"] == "ok"
    assert _ready(c) is True


def test_draft_time_refusal_records_last_check_and_hides_the_wizard(engine, llm_ws):
    _seed_row(engine, service=SERVICE)
    llm_ws.post_exc = PermissionDenied("User does not have permission to use model service")
    with _client(engine, role=UserRole.BUSINESS_ADMIN) as c:
        assert _ready(c) is True
        r = c.post("/api/taxonomy/drafts", json={"company_name": "Acme", "industry": "Utility"})
        assert r.status_code == 400 and r.json()["detail"]["error"] == "model_service_refused"
        assert _ready(c) is False
        assert c.get("/api/config/taxonomy").json()["last_check"]["status"] == "denied"


# --- PUT /config/taxonomy -----------------------------------------------------


def test_put_ok_saves_and_records_last_check(engine, llm_ws):
    r = _client(engine).put("/api/config/taxonomy", json={"model_service": SERVICE, "max_concurrency": 3})
    assert r.status_code == 200
    body = r.json()
    assert body["model_service"] == SERVICE and body["max_concurrency"] == 3 and body["ready"] is True
    assert body["last_check"]["status"] == "ok"
    assert _stored(engine).taxonomy_model_service == SERVICE
    assert MODEL_SERVICE_ACCESS.is_cached(SERVICE)


def test_put_records_who_saved_and_when_like_assess_config(engine, llm_ws):
    """Audit parity: a taxonomy save writes ``taxonomy_updated_by`` / ``_at``
    (the caller's ``actor_label``, UTC now), and GET returns them as
    ``updated_by`` / ``updated_at``, as ``/assess/config`` does."""
    _seed_row(engine, service="old.svc.name")
    c = _client(engine)
    r = c.put("/api/config/taxonomy", json={"model_service": SERVICE}, headers={"X-Forwarded-Email": "ann@x.com"})
    assert r.status_code == 200
    row = _stored(engine)
    assert row.taxonomy_updated_by == "ann@x.com" and row.taxonomy_updated_at is not None
    body = c.get("/api/config/taxonomy").json()
    assert body["updated_by"] == "ann@x.com"
    assert body["updated_at"].endswith(("+00:00", "Z"))
    assert r.json()["updated_by"] == "ann@x.com"


def test_put_clear_records_the_audit_pair_too(engine, llm_ws):
    _seed_row(engine, service=SERVICE)
    r = _client(engine).put("/api/config/taxonomy", json={"model_service": ""}, headers={"X-Forwarded-Email": "bo@x.com"})
    assert r.status_code == 200
    assert _stored(engine).taxonomy_updated_by == "bo@x.com"


def test_saved_concurrency_applies_at_the_next_draft(engine, llm_ws):
    """DraftStore is the one owner of the slot capacity: a save stores the
    value, and the next draft applies it."""
    TAXONOMY_SLOTS.set_capacity(6)
    with _client(engine) as c:
        assert c.put("/api/config/taxonomy", json={"model_service": SERVICE, "max_concurrency": 3}).status_code == 200
        assert TAXONOMY_SLOTS.capacity == 6
        r = c.post("/api/taxonomy/drafts", json={"company_name": "Acme", "industry": "Utility"})
        assert r.status_code == 200
        assert TAXONOMY_SLOTS.capacity == 3
        c.post(f"/api/taxonomy/drafts/{r.json()['draft_id']}/cancel")


@pytest.mark.parametrize(
    "exc,status,needle",
    [
        (PermissionDenied("User does not have permission to use model service. Config: host=x"), "denied", SP_ID),
        (NotFound("does not exist"), "not_found", "exists but the app can't use it yet"),
        (RuntimeError("kaboom"), "error", "failed the test call"),
    ],
)
def test_put_refusal_saves_nothing(engine, llm_ws, exc, status, needle):
    _seed_row(engine, service="old.svc.name")
    llm_ws.post_exc = exc
    r = _client(engine).put("/api/config/taxonomy", json={"model_service": SERVICE})
    assert r.status_code == 400
    detail = r.json()["detail"]
    assert detail["error"] == "model_service_refused" and detail["key"] == "taxonomy_llm"
    assert detail["status"] == status and needle in detail["message"]
    assert _stored(engine).taxonomy_model_service == "old.svc.name"
    assert _stored(engine).taxonomy_updated_by is None and _stored(engine).taxonomy_updated_at is None
    assert MODEL_SERVICE_ACCESS.last_check(SERVICE).status == status
    assert not MODEL_SERVICE_ACCESS.is_cached(SERVICE)


def test_put_not_found_twice_says_not_found(engine, llm_ws):
    llm_ws.post_exc = NotFound("does not exist")
    llm_ws.get_result = NotFound("Resource not found")
    r = _client(engine).put("/api/config/taxonomy", json={"model_service": SERVICE})
    assert r.status_code == 400
    assert r.json()["detail"]["message"] == f"Model service '{SERVICE}' was not found."


def test_put_busy_saves_with_warning_and_is_not_cached(engine, llm_ws):
    llm_ws.post_exc = _from(TimeoutError("Timed out"), TooManyRequests("slow down"))
    r = _client(engine).put("/api/config/taxonomy", json={"model_service": SERVICE})
    assert r.status_code == 200
    assert r.json()["last_check"]["status"] == "busy"
    assert _stored(engine).taxonomy_model_service == SERVICE
    assert not MODEL_SERVICE_ACCESS.is_cached(SERVICE)


@pytest.mark.parametrize("name", ["drafter", "a.b", "a.b.c.d", "a b.c.d", "a/b.c.d"])
def test_put_rejects_non_three_part_name(engine, llm_ws, name):
    r = _client(engine).put("/api/config/taxonomy", json={"model_service": name})
    assert r.status_code == 422
    llm_ws.api_client.do.assert_not_called()


@pytest.mark.parametrize("value", [0, 17])
def test_put_rejects_concurrency_out_of_range(engine, llm_ws, value):
    r = _client(engine).put("/api/config/taxonomy", json={"model_service": SERVICE, "max_concurrency": value})
    assert r.status_code == 422


def test_put_clear_allowed_without_install_default(engine, llm_ws):
    _seed_row(engine, service=SERVICE)
    r = _client(engine).put("/api/config/taxonomy", json={"model_service": ""})
    assert r.status_code == 200
    assert r.json()["ready"] is False
    assert _stored(engine).taxonomy_model_service == ""
    llm_ws.api_client.do.assert_not_called()


def test_put_clear_refused_with_install_default(engine, llm_ws):
    _seed_row(engine, service=SERVICE)
    r = _client(engine, default=DEFAULT).put("/api/config/taxonomy", json={"model_service": ""})
    assert r.status_code == 422
    assert DEFAULT in r.json()["detail"]
    assert _stored(engine).taxonomy_model_service == SERVICE


def test_put_reset_to_install_default_writes_and_probes(engine, llm_ws):
    _seed_row(engine, service=SERVICE)
    r = _client(engine, default=DEFAULT).put("/api/config/taxonomy", json={"model_service": DEFAULT})
    assert r.status_code == 200
    assert r.json()["model_service"] == DEFAULT and r.json()["last_check"]["status"] == "ok"
    assert llm_ws.api_client.do.call_args.kwargs["body"]["model"] == DEFAULT


def test_put_not_installed_is_404(engine, llm_ws):
    r = _client(engine, installed=False).put("/api/config/taxonomy", json={"model_service": SERVICE})
    assert r.status_code == 404
    llm_ws.api_client.do.assert_not_called()


@pytest.mark.parametrize("role", [UserRole.BUSINESS_ADMIN, UserRole.MODELER, UserRole.VIEWER])
def test_put_non_admin_is_403(engine, llm_ws, role):
    r = _client(engine, role=role).put("/api/config/taxonomy", json={"model_service": SERVICE})
    assert r.status_code == 403
    llm_ws.api_client.do.assert_not_called()


# --- POST /config/taxonomy/test ---------------------------------------------


def test_test_probes_the_stored_service_and_updates_last_check(engine, llm_ws):
    _seed_row(engine, service=SERVICE)
    c = _client(engine)
    r = c.post("/api/config/taxonomy/test")
    assert r.status_code == 200 and r.json()["status"] == "ok"
    assert llm_ws.api_client.do.call_args.kwargs["body"]["model"] == SERVICE
    assert c.get("/api/config/taxonomy").json()["last_check"]["status"] == "ok"

    llm_ws.post_exc = PermissionDenied("nope")
    r = c.post("/api/config/taxonomy/test")
    assert r.json()["status"] == "denied"
    assert c.get("/api/config/taxonomy").json()["last_check"]["status"] == "denied"
    assert not MODEL_SERVICE_ACCESS.is_cached(SERVICE)


def test_test_without_a_service(engine, llm_ws):
    r = _client(engine).post("/api/config/taxonomy/test")
    assert r.status_code == 200
    assert r.json()["status"] == "error" and "No model service is configured" in r.json()["message"]
    llm_ws.api_client.do.assert_not_called()


def test_test_not_installed_is_404(engine, llm_ws):
    _seed_row(engine, service=SERVICE)
    assert _client(engine, installed=False).post("/api/config/taxonomy/test").status_code == 404


def test_test_non_admin_is_403(engine, llm_ws):
    _seed_row(engine, service=SERVICE)
    assert _client(engine, role=UserRole.MODELER).post("/api/config/taxonomy/test").status_code == 403


# --- GET /config/taxonomy/model-services -------------------------------------


@pytest.fixture
def list_ws(monkeypatch):
    """Install the listing pages on the LLM client (taxonomy/llm._LLM_WS), the
    bounded client the list route uses."""

    def install(pages):
        ws = MagicMock()
        ws.api_client.do.side_effect = pages
        monkeypatch.setattr(llm_module, "_LLM_WS", ws)
        return ws

    return install


def test_model_services_paginates_strips_prefix_and_sorts_system_ai_last(engine, list_ws):
    ws = list_ws([
        {"model_services": [{"name": "model-services/system.ai.gpt-5"}, {"name": "model-services/main.ai.zeta"}],
         "next_page_token": "abc+/="},
        {"model_services": [], "next_page_token": "def"},
        {"model_services": [{"name": "model-services/main.ai.Alpha"}, {"name": "model-services/system.ai.claude"},
                            {"name": "model-services/main.ai.zeta"}, {"name": "garbage"}]},
    ])
    r = _client(engine).get("/api/config/taxonomy/model-services")
    assert r.status_code == 200
    assert r.json() == {
        "services": ["main.ai.Alpha", "main.ai.zeta", "system.ai.claude", "system.ai.gpt-5"],
        "message": None,
    }
    calls = ws.api_client.do.call_args_list
    assert [c.args for c in calls] == [("GET", "/api/2.1/unity-catalog/model-services")] * 3
    assert calls[0].kwargs["query"] == {"page_size": 200}
    assert calls[1].kwargs["query"] == {"page_size": 200, "page_token": "abc+/="}


def test_model_services_skips_services_without_chat_completions(engine, list_ws):
    list_ws([{"model_services": [
        {"name": "model-services/system.ai.bge-large-en", "supported_api_types": ["mlflow/v1/embeddings"]},
        {"name": "model-services/system.ai.claude", "supported_api_types": ["mlflow/v1/chat/completions", "anthropic/v1/messages"]},
        {"name": "model-services/main.ai.custom"},
    ]}])
    body = _client(engine).get("/api/config/taxonomy/model-services").json()
    assert body["services"] == ["main.ai.custom", "system.ai.claude"]


def test_model_services_page_cap(engine, monkeypatch, list_ws):
    monkeypatch.setattr(config_routes, "MODEL_SERVICES_MAX_PAGES", 2)
    ws = list_ws([
        {"model_services": [{"name": "model-services/a.b.c"}], "next_page_token": "1"},
        {"model_services": [{"name": "model-services/a.b.d"}], "next_page_token": "2"},
    ])
    body = _client(engine).get("/api/config/taxonomy/model-services").json()
    assert body["services"] == ["a.b.c", "a.b.d"]
    assert "Type the full name" in body["message"]
    assert ws.api_client.do.call_count == 2


def test_model_services_error_returns_empty_and_message(engine, list_ws):
    list_ws(PermissionDenied("no list for you"))
    body = _client(engine).get("/api/config/taxonomy/model-services").json()
    assert body["services"] == [] and "no list for you" in body["message"]


def test_model_services_use_the_bounded_llm_client_not_the_app_client(engine, list_ws):
    bounded = list_ws([{"model_services": [{"name": "model-services/main.ai.x"}]}])
    app_ws = MagicMock()
    r = _client(engine, app_ws=app_ws).get("/api/config/taxonomy/model-services")
    assert r.status_code == 200 and r.json()["services"] == ["main.ai.x"]
    assert bounded.api_client.do.call_count == 1
    app_ws.api_client.do.assert_not_called()


def test_model_services_client_construction_failure_returns_the_fallback(engine, monkeypatch):
    def broken():
        raise ValueError("no auth configured")

    monkeypatch.setattr(config_routes, "llm_workspace_client", broken)
    r = _client(engine).get("/api/config/taxonomy/model-services")
    assert r.status_code == 200
    assert r.json()["services"] == [] and "no auth configured" in r.json()["message"]


def test_model_services_stop_at_the_overall_deadline(engine, monkeypatch, list_ws):
    monkeypatch.setattr(config_routes, "MODEL_SERVICES_DEADLINE_SECONDS", 0)
    ws = list_ws([
        {"model_services": [{"name": "model-services/a.b.c"}], "next_page_token": "1"},
        {"model_services": [{"name": "model-services/a.b.d"}]},
    ])
    body = _client(engine).get("/api/config/taxonomy/model-services").json()
    assert body["services"] == ["a.b.c"]
    assert "Type the full name" in body["message"]
    assert ws.api_client.do.call_count == 1


def test_the_llm_client_has_the_90s_timeout_and_1s_retry_budget(monkeypatch):
    monkeypatch.setattr(llm_module, "_LLM_WS", None)
    builder = MagicMock()
    monkeypatch.setattr(llm_module, "short_budget_workspace_client", builder)
    assert llm_module.llm_workspace_client() is builder.return_value
    builder.assert_called_once_with(90, 1)


def test_model_services_not_installed_is_404(engine):
    assert _client(engine, installed=False).get("/api/config/taxonomy/model-services").status_code == 404


def test_model_services_non_admin_is_403(engine):
    assert _client(engine, role=UserRole.MODELER).get("/api/config/taxonomy/model-services").status_code == 403


# --- probe wait / slots (taxonomy/access.py) ---------------------------------


class _SlowLLM:
    model_service = SERVICE

    def __init__(self):
        self.release = threading.Event()

    def probe(self):
        self.release.wait(5)
        return ProbeResult("ok", "late")


def test_probe_wait_timeout_is_busy_and_not_cached():
    access, slots, llm = ModelServiceAccess(), LLMSlots(2), _SlowLLM()

    async def go():
        return await access.probe(llm, slots, wait_seconds=0.05)

    try:
        check = asyncio.run(go())
        assert check.status == "busy" and "busy right now" in check.message
        assert not access.is_cached(SERVICE)
        assert slots.in_use == 1  # the thread still holds its slot
    finally:
        llm.release.set()


def test_probe_without_a_free_slot_is_busy():
    access, slots = ModelServiceAccess(), LLMSlots(1)
    assert slots.try_acquire()
    llm = MagicMock(model_service=SERVICE)
    check = asyncio.run(access.probe(llm, slots))
    assert check.status == "busy"
    llm.probe.assert_not_called()


def test_record_drops_cache_on_denied_and_keeps_it_on_busy():
    access = ModelServiceAccess()
    access.record(SERVICE, ProbeResult("ok", "fine"))
    access.record(SERVICE, ProbeResult("busy", "busy"))
    assert access.is_cached(SERVICE)
    access.record(SERVICE, ProbeResult("denied", "no"))
    assert not access.is_cached(SERVICE)
    assert access.last_check(SERVICE).message == "no"


# --- config_missing helper ----------------------------------------------------


def test_config_missing_error_matches_require_config_shape(engine):
    with Session(engine) as s:
        with pytest.raises(HTTPException) as raised:
            require_config(s, AppConfig(taxonomy_builder_enabled=True), {"taxonomy_llm"}, mode="raise")
    built = config_missing_error("taxonomy_llm", raised.value.detail["message"])
    assert built.status_code == raised.value.status_code == 422
    assert built.detail == raised.value.detail
    assert built.detail["missing"] == [{
        "key": "taxonomy_llm",
        "label": "Domain Taxonomy Builder model service",
        "settings_url": "/settings?tab=platform",
    }]


def test_require_config_collect_has_field_path(engine):
    with Session(engine) as s:
        issues = require_config(s, AppConfig(), {"taxonomy_llm"}, mode="collect")
    assert [i.field_path for i in issues] == ["(agent_config.taxonomy_model_service)"]


# --- install seed ----------------------------------------------------------------


def test_new_row_is_seeded_only_when_installed(engine):
    with Session(engine) as s:
        cfg = _get_or_create_agent_config(s, AppConfig(taxonomy_builder_enabled=False, taxonomy_model_service=DEFAULT))
        assert cfg.taxonomy_model_service == ""
    other = create_engine("sqlite://", connect_args={"check_same_thread": False}, poolclass=StaticPool)
    SQLModel.metadata.create_all(other)
    with Session(other) as s:
        cfg = _get_or_create_agent_config(s, AppConfig(taxonomy_builder_enabled=True, taxonomy_model_service=DEFAULT))
        assert cfg.taxonomy_model_service == DEFAULT


def test_boot_seed_fills_only_an_empty_column(engine):
    _seed_row(engine, service="")
    cfg = AppConfig(taxonomy_builder_enabled=True, taxonomy_model_service=f"  {DEFAULT} ")
    assert seed_taxonomy_model_service(engine, cfg) == 1
    assert _stored(engine).taxonomy_model_service == DEFAULT
    assert seed_taxonomy_model_service(engine, cfg) == 0


def test_boot_seed_never_overwrites_a_saved_value(engine):
    _seed_row(engine, service=SERVICE)
    assert seed_taxonomy_model_service(engine, AppConfig(taxonomy_builder_enabled=True, taxonomy_model_service=DEFAULT)) == 0
    assert _stored(engine).taxonomy_model_service == SERVICE


@pytest.mark.parametrize("installed,default", [(False, DEFAULT), (True, "")])
def test_boot_seed_is_a_no_op_when_not_installed_or_no_default(engine, installed, default):
    _seed_row(engine, service="")
    assert seed_taxonomy_model_service(engine, AppConfig(taxonomy_builder_enabled=installed, taxonomy_model_service=default)) == 0
    assert _stored(engine).taxonomy_model_service == ""


def test_boot_seed_is_registered_as_a_lifespan_after_lakebase():
    from vibe_modeling.backend.core._base import LifespanDependency
    from vibe_modeling.backend.core._taxonomy_seed import _TaxonomySeedDependency

    reg = LifespanDependency._registry
    assert reg.index(_TaxonomySeedDependency) > reg.index(_LakebaseDependency)


# --- self-healing ready (background re-probe) ---------------------------------

from datetime import datetime, timedelta, timezone  # noqa: E402

from vibe_modeling.backend.core._taxonomy_seed import start_boot_probe  # noqa: E402
from vibe_modeling.backend.taxonomy.access import PASSED_TTL, REFUSED_CHECKS, REFUSED_RECHECK_AFTER  # noqa: E402

T0 = datetime(2026, 10, 19, 10, 0, tzinfo=timezone.utc)


class _Clock:
    def __init__(self, now=T0):
        self.now = now

    def __call__(self):
        return self.now


class _GatedLLM:
    """``probe`` blocks until released, so a test can observe the in-flight state."""

    model_service = SERVICE

    def __init__(self, result=("ok", "fine")):
        self.calls = 0
        self.release = threading.Event()
        self.result = ProbeResult(*result)

    def probe(self):
        self.calls += 1
        self.release.wait(5)
        return self.result


def _wait_until(pred, timeout=5):
    import time as _t

    deadline = _t.time() + timeout
    while _t.time() < deadline:
        if pred():
            return
        _t.sleep(0.01)
    raise AssertionError("condition never became true")


def test_refused_statuses_constant():
    assert REFUSED_CHECKS == {"denied", "not_found", "error"}
    assert REFUSED_RECHECK_AFTER == timedelta(minutes=5)


def test_passed_check_expires_after_the_ttl():
    assert PASSED_TTL == timedelta(minutes=15)
    clock = _Clock()
    access = ModelServiceAccess(clock=clock)
    access.record(SERVICE, ProbeResult("ok", "fine"))
    clock.now = T0 + PASSED_TTL - timedelta(seconds=1)
    assert access.is_cached(SERVICE) is True
    clock.now = T0 + PASSED_TTL
    assert access.is_cached(SERVICE) is False
    # The last check is kept for Settings; only the skip-the-probe pass expires.
    check = access.last_check(SERVICE)
    assert check is not None and check.status == "ok"
    clock.now = T0 + PASSED_TTL + timedelta(minutes=1)
    access.record(SERVICE, ProbeResult("ok", "fine again"))
    assert access.is_cached(SERVICE) is True


@pytest.mark.parametrize("status", ["denied", "not_found", "error"])
def test_maybe_recheck_waits_out_the_window_then_probes_once(status):
    clock = _Clock()
    access, slots, llm = ModelServiceAccess(clock=clock), LLMSlots(2), _GatedLLM()
    access.record(SERVICE, ProbeResult(status, "no"))
    clock.now = T0 + REFUSED_RECHECK_AFTER - timedelta(seconds=1)
    assert access.maybe_recheck(SERVICE, lambda: llm, slots) is False
    clock.now = T0 + REFUSED_RECHECK_AFTER + timedelta(seconds=1)
    try:
        assert access.maybe_recheck(SERVICE, lambda: llm, slots) is True
        assert access.maybe_recheck(SERVICE, lambda: llm, slots) is False  # deduplicated while in flight
        assert slots.in_use == 1
    finally:
        llm.release.set()
    _wait_until(lambda: access.last_check(SERVICE).status == "ok")
    assert llm.calls == 1
    assert access.is_cached(SERVICE)
    _wait_until(lambda: slots.in_use == 0)


@pytest.mark.parametrize("status", ["ok", "busy"])
def test_maybe_recheck_ignores_non_refused_checks(status):
    clock = _Clock()
    access = ModelServiceAccess(clock=clock)
    access.record(SERVICE, ProbeResult(status, "x"))
    clock.now = T0 + timedelta(hours=1)
    factory = MagicMock()
    assert access.maybe_recheck(SERVICE, factory, LLMSlots(2)) is False
    factory.assert_not_called()


def test_maybe_recheck_never_checked_does_nothing():
    factory = MagicMock()
    assert ModelServiceAccess().maybe_recheck(SERVICE, factory, LLMSlots(2)) is False
    factory.assert_not_called()


def test_background_probe_without_a_free_slot_starts_nothing():
    access, slots = ModelServiceAccess(), LLMSlots(1)
    assert slots.try_acquire()
    llm = MagicMock(model_service=SERVICE)
    assert access.start_background_probe(llm, slots) is False
    llm.probe.assert_not_called()
    assert access.last_check(SERVICE) is None
    slots.release()
    # Not left marked in flight: the next attempt can start.
    llm.probe.return_value = ProbeResult("ok", "fine")
    assert access.start_background_probe(llm, slots) is True


def test_get_starts_one_background_recheck_and_answers_at_once(engine, llm_ws, monkeypatch):
    _seed_row(engine, service=SERVICE)
    clock = _Clock()
    monkeypatch.setattr(MODEL_SERVICE_ACCESS, "_clock", clock)
    MODEL_SERVICE_ACCESS.record(SERVICE, ProbeResult("denied", "no"))
    c = _client(engine)
    assert _ready(c) is False
    llm_ws.api_client.do.assert_not_called()  # inside the 5-minute window

    clock.now = T0 + REFUSED_RECHECK_AFTER + timedelta(seconds=1)
    gate = threading.Event()
    original = llm_ws.api_client.do.side_effect

    def slow(method, path, **kw):
        gate.wait(5)
        return original(method, path, **kw)

    llm_ws.api_client.do.side_effect = slow
    try:
        first = c.get("/api/config/taxonomy").json()
        second = c.get("/api/config/taxonomy").json()
        assert first["ready"] is False and second["ready"] is False  # current state, no wait
    finally:
        gate.set()
    _wait_until(lambda: MODEL_SERVICE_ACCESS.last_check(SERVICE).status == "ok")
    assert llm_ws.api_client.do.call_count == 1  # two GETs, one probe
    assert _ready(c) is True


def test_get_does_not_recheck_when_not_installed(engine, llm_ws, monkeypatch):
    _seed_row(engine, service=SERVICE)
    clock = _Clock()
    monkeypatch.setattr(MODEL_SERVICE_ACCESS, "_clock", clock)
    MODEL_SERVICE_ACCESS.record(SERVICE, ProbeResult("denied", "no"))
    clock.now = T0 + timedelta(hours=1)
    _client(engine, installed=False).get("/api/config/taxonomy")
    llm_ws.api_client.do.assert_not_called()


def test_boot_probe_records_access_before_the_first_visit(engine, llm_ws):
    _seed_row(engine, service=SERVICE, concurrency=3)
    assert start_boot_probe(engine, AppConfig(taxonomy_builder_enabled=True)) is True
    _wait_until(lambda: MODEL_SERVICE_ACCESS.last_check(SERVICE) is not None)
    assert MODEL_SERVICE_ACCESS.last_check(SERVICE).status == "ok"


def test_boot_probe_refusal_hides_the_card(engine, llm_ws):
    _seed_row(engine, service=SERVICE)
    llm_ws.post_exc = PermissionDenied("User does not have permission to use model service")
    start_boot_probe(engine, AppConfig(taxonomy_builder_enabled=True))
    _wait_until(lambda: MODEL_SERVICE_ACCESS.last_check(SERVICE) is not None)
    assert _ready(_client(engine)) is False


@pytest.mark.parametrize("installed,service", [(False, SERVICE), (True, "")])
def test_boot_probe_is_a_no_op_when_not_installed_or_unset(engine, llm_ws, installed, service):
    _seed_row(engine, service=service)
    assert start_boot_probe(engine, AppConfig(taxonomy_builder_enabled=installed)) is False
    llm_ws.api_client.do.assert_not_called()


def test_boot_probe_with_no_row_is_a_no_op(engine, llm_ws):
    assert start_boot_probe(engine, AppConfig(taxonomy_builder_enabled=True)) is False


# --- review fixes ----------------------------------------------------------------------


@pytest.mark.parametrize(
    "method,path",
    [("PUT", "/api/config/taxonomy"), ("POST", "/api/config/taxonomy/test"), ("GET", "/api/config/taxonomy/model-services")],
)
def test_admin_routes_check_installed_before_role(engine, llm_ws, method, path):
    body = {"model_service": SERVICE} if method == "PUT" else None
    r = _client(engine, installed=False, role=UserRole.VIEWER).request(method, path, json=body)
    assert r.status_code == 404


def test_refused_put_leaves_capacity_unchanged(engine, llm_ws):
    TAXONOMY_SLOTS.set_capacity(6)
    llm_ws.post_exc = PermissionDenied("nope")
    r = _client(engine).put("/api/config/taxonomy", json={"model_service": SERVICE, "max_concurrency": 2})
    assert r.status_code == 400
    assert TAXONOMY_SLOTS.capacity == 6


def test_model_services_error_drops_the_sdk_config_suffix(engine, list_ws):
    list_ws(PermissionDenied("You can't list these. Config: host=https://x, auth_type=oauth-m2m"))
    body = _client(engine).get("/api/config/taxonomy/model-services").json()
    assert body["message"] == "Couldn't list model services: You can't list these"


# --- background probe ordering + in-flight marker ---------------------------------------


def test_slow_background_probe_never_overwrites_a_newer_check():
    clock = _Clock()
    access, slots = ModelServiceAccess(clock=clock), LLMSlots(2)
    llm = _GatedLLM(result=("denied", "late refusal"))
    assert access.start_background_probe(llm, slots) is True  # started at T0
    clock.now = T0 + timedelta(seconds=10)
    access.record(SERVICE, ProbeResult("ok", "Test passed"))  # a Test finishes first
    clock.now = T0 + timedelta(seconds=20)
    llm.release.set()
    _wait_until(lambda: not access.is_in_flight(SERVICE))
    check = access.last_check(SERVICE)
    assert (check.status, check.message) == ("ok", "Test passed")
    assert access.is_cached(SERVICE)


def test_background_probe_result_is_written_when_nothing_newer_exists():
    clock = _Clock()
    access, slots = ModelServiceAccess(clock=clock), LLMSlots(2)
    access.record(SERVICE, ProbeResult("denied", "old"))  # stored at T0
    clock.now = T0 + timedelta(minutes=6)
    llm = _GatedLLM(result=("ok", "fine"))
    access.start_background_probe(llm, slots)
    llm.release.set()
    _wait_until(lambda: not access.is_in_flight(SERVICE))
    assert access.last_check(SERVICE).status == "ok"


def test_submit_failure_clears_the_in_flight_marker():
    access = ModelServiceAccess()
    slots = MagicMock()
    slots.submit.side_effect = RuntimeError("executor shut down")
    llm = MagicMock(model_service=SERVICE)
    with pytest.raises(RuntimeError):
        access.start_background_probe(llm, slots)
    assert not access.is_in_flight(SERVICE)


def test_probe_that_raises_clears_the_in_flight_marker_and_records_nothing():
    access, slots = ModelServiceAccess(), LLMSlots(2)
    llm = MagicMock(model_service=SERVICE)
    llm.probe.side_effect = RuntimeError("probe blew up")
    assert access.start_background_probe(llm, slots) is True
    _wait_until(lambda: not access.is_in_flight(SERVICE))
    assert access.last_check(SERVICE) is None
    _wait_until(lambda: slots.in_use == 0)


# --- executor shutdown at app exit ------------------------------------------------------


def test_taxonomy_executor_shuts_down_at_lifespan_exit(monkeypatch):
    from vibe_modeling.backend.core._base import LifespanDependency
    from vibe_modeling.backend.core._taxonomy_executor import _TaxonomyExecutorDependency
    from vibe_modeling.backend.taxonomy import slots as slots_module

    assert _TaxonomyExecutorDependency in LifespanDependency._registry
    fake = MagicMock()
    monkeypatch.setattr(slots_module, "TAXONOMY_EXECUTOR", fake)

    async def go():
        async with _TaxonomyExecutorDependency().lifespan(FastAPI()):
            fake.shutdown.assert_not_called()

    asyncio.run(go())
    fake.shutdown.assert_called_once_with(wait=False, cancel_futures=True)

"""v0.9.0 X-ATW: failures are visible and writes are atomic.

* createBusiness writes the business and its seed context in one transaction.
* The launch error names the result type; the repr goes to the log only.
* Every ecm/mvm derivation from a scope string goes through
  ``core/_names.normalize_scope``.
* Initial sync's refusal reasons are sanitized before they reach the summary.
"""

from __future__ import annotations

import ast
import logging
import re
from types import SimpleNamespace
from unittest.mock import MagicMock

import pytest
from sqlalchemy import event
from sqlalchemy.exc import IntegrityError
from sqlmodel import Session, select

from vibe_modeling.backend import _query_helpers, job_launcher
from vibe_modeling.backend.db_models import Business, BusinessContext, Run
from vibe_modeling.backend.error_sanitization import MAX_ERROR_LENGTH
from vibe_modeling.backend.initial_sync import InitialSyncService
from vibe_modeling.backend.routes import businesses as businesses_route
from vibe_modeling.backend.services import schema_names
from vibe_modeling.backend.services.orchestrator.dag_factories import _simple

from ._drift.fixtures import fake_uc, mock_model  # noqa: F401
from ._source_scan import BACKEND, is_comment, iter_files, line_of, read_text

def _leaky_text() -> tuple[str, list[str]]:
    # Built from parts so no secret-shaped literal sits in the source.
    token = "dapi" + "a1b2" * 8
    path = "/Workspace/Users/" + "someone@corp.example" + "/job"
    return f"quota exceeded for {path} token {token}", [token, "/Workspace", "someone@corp.example"]


class TestRunNowFailureIsSanitized:

    def test_launch_run_redacts_the_message_and_logs_the_full_text(self, caplog):
        text, leaks = _leaky_text()
        ws = MagicMock()
        ws.jobs.run_now.side_effect = ValueError(text)

        with caplog.at_level(logging.ERROR, logger=job_launcher.logger.name):
            with pytest.raises(RuntimeError) as excinfo:
                job_launcher.launch_run(ws, 7, {"operation": "install"})

        message = str(excinfo.value)
        assert message.startswith("Could not start the job (ValueError)")
        assert "quota exceeded" in message
        assert not any(leak in message for leak in leaks)
        assert leaks[0] in caplog.text

    def test_a_failed_dispatch_stores_a_redacted_run_error(
        self, engine, client_with_agent, mock_ws, seed_business_with_version
    ):
        text, leaks = _leaky_text()
        mock_ws.jobs.run_now.side_effect = ValueError(text)

        response = client_with_agent.post(
            f"/api/businesses/{seed_business_with_version}/runs",
            json={"intent": "vibe-iterate", "catalog": "prod_catalog", "vibe_instructions": "hi"},
        )

        assert response.status_code == 200, response.text
        body = response.json()
        assert body["status"] == "failed"
        with Session(engine) as session:
            stored = session.get(Run, body["id"]).error_message
        for seen in (body["error_message"], stored):
            assert "quota exceeded" in seen
            assert not any(leak in seen for leak in leaks)

    def test_any_dispatch_error_is_redacted_before_it_reaches_the_run(
        self, client_with_agent, mock_ws, seed_business_with_version
    ):
        text, leaks = _leaky_text()
        mock_ws.files.upload.side_effect = ValueError(text)
        long_text = "x" * (job_launcher.VIBE_INSTRUCTIONS_INLINE_LIMIT + 200)

        response = client_with_agent.post(
            f"/api/businesses/{seed_business_with_version}/runs",
            json={"intent": "vibe-iterate", "catalog": "prod_catalog", "vibe_instructions": long_text},
        )

        assert response.status_code == 200, response.text
        message = response.json()["error_message"]
        assert "quota exceeded" in message
        assert not any(leak in message for leak in leaks)


# `x in ("ecm", "mvm")` membership checks stay; a bare `"ecm" in x` is the
# shape of an inline normalizer.
_INLINE_SCOPE_TEST = re.compile(r"""["'](?:ecm|mvm)["']\s+(?:not\s+)?in\s+(?![(\[])""", re.IGNORECASE)

_BODY = {"name": "Acme Retail", "description": "Retail chain"}


class TestCreateBusinessIsOneTransaction:

    def test_a_failed_seed_leaves_no_business_and_the_retry_succeeds(self, engine, client):
        def seed_insert_fails(mapper, connection, target):
            raise RuntimeError("seed insert failed")

        event.listen(BusinessContext, "before_insert", seed_insert_fails)
        try:
            with pytest.raises(RuntimeError, match="seed insert failed"):
                client.post("/api/businesses", json=_BODY)
        finally:
            event.remove(BusinessContext, "before_insert", seed_insert_fails)

        with Session(engine) as session:
            assert session.exec(select(Business)).all() == []
            assert session.exec(select(BusinessContext)).all() == []

        retry = client.post("/api/businesses", json=_BODY)

        assert retry.status_code == 200, retry.text
        with Session(engine) as session:
            (business,) = session.exec(select(Business)).all()
            (context,) = session.exec(select(BusinessContext)).all()
        assert (business.name, context.business_id, context.version_label) == (
            "Acme Retail", business.id, "seed",
        )

    def test_a_name_taken_between_the_check_and_the_insert_is_the_409(self, engine, client, monkeypatch):
        with Session(engine) as session:
            session.add(Business(name="Acme Retail"))
            session.commit()
        real_check = businesses_route.ensure_business_name_available
        calls = []

        def check_passes_once(*args, **kwargs):
            calls.append(1)
            if len(calls) > 1:
                return real_check(*args, **kwargs)

        monkeypatch.setattr(businesses_route, "ensure_business_name_available", check_passes_once)

        response = client.post("/api/businesses", json=_BODY)

        assert response.status_code == 409, response.text
        detail = response.json()["detail"]
        assert (detail["error"], detail["name"]) == ("business_name_taken", "Acme Retail")
        with Session(engine) as session:
            assert [b.name for b in session.exec(select(Business)).all()] == ["Acme Retail"]
            assert session.exec(select(BusinessContext)).all() == []

    def test_an_integrity_error_that_is_not_a_name_clash_is_not_the_409(self, engine, client):
        def insert_violates_a_constraint(mapper, connection, target):
            raise IntegrityError("INSERT INTO businesses", {}, Exception("FOREIGN KEY constraint failed"))

        event.listen(Business, "before_insert", insert_violates_a_constraint)
        try:
            with pytest.raises(IntegrityError, match="FOREIGN KEY"):
                client.post("/api/businesses", json=_BODY)
        finally:
            event.remove(Business, "before_insert", insert_violates_a_constraint)

        with Session(engine) as session:
            assert session.exec(select(Business)).all() == []

    def test_one_message_for_a_name_clash(self):
        assert str(_query_helpers.BusinessNameConflict("Acme", Business(name="acme"))) == _query_helpers.name_taken_message("Acme")


class TestOneBuilderForTheNameTakenPayload:

    def test_no_backend_module_but_the_helper_writes_the_error_code(self):
        offenders = [
            rel for path, rel in iter_files(BACKEND, exempt=["routes/_helpers.py"])
            if '"business_name_taken"' in (read_text(path) or "")
        ]
        assert offenders == []


class TestLaunchErrorNamesTheTypeOnly:

    def test_the_message_has_the_type_and_the_log_has_the_repr(self, caplog):
        class Opaque:
            def __repr__(self) -> str:
                return "Opaque(token=dapi0123, path=/Workspace/Users/someone@corp.example/job)"

        ws = MagicMock()
        ws.jobs.run_now.return_value = Opaque()

        with caplog.at_level(logging.ERROR, logger=job_launcher.logger.name):
            with pytest.raises(RuntimeError) as excinfo:
                job_launcher.launch_run(ws, 7, {"operation": "install"})

        message = str(excinfo.value)
        assert "Opaque" in message
        assert "dapi0123" not in message and "/Workspace" not in message
        assert "dapi0123" in caplog.text


_SCOPE_FORMS = [
    ("ecm", "ecm"),
    ("mvm", "mvm"),
    ("Expanded Coverage Model - ECM", "ecm"),
    ("Minimum Viable Model - MVM", "mvm"),
    ("Expanded Coverage", "ecm"),
    ("Minimum Viable", "mvm"),
]


class TestScopeDerivationsShareNormalizeScope:
    """Each former inline ecm/mvm derivation now agrees with ``normalize_scope``
    on every form of a scope, the abbreviated, the widget label and the
    label's leading words, and keeps its own default for the rest."""

    @pytest.mark.parametrize("scope,short", _SCOPE_FORMS)
    def test_job_tags(self, scope, short):
        tags = job_launcher.build_job_tags(business_name="Acme", model_scope=scope, version="3")
        assert tags["dbx_vibe_modelling_model"] == f"{short}_v3"

    @pytest.mark.parametrize("scope,short", _SCOPE_FORMS)
    def test_schema_names(self, scope, short):
        assert schema_names._scope_short(scope) == short

    @pytest.mark.parametrize("scope,short", _SCOPE_FORMS)
    def test_dag_scope_prefers_the_request_then_the_parent(self, scope, short):
        assert _simple._scope_short(SimpleNamespace(scope=scope), None) == short
        assert _simple._scope_short(SimpleNamespace(scope=None), SimpleNamespace(scope=scope)) == short
        assert _simple._schema_prefix_for(SimpleNamespace(), "One Catalog", SimpleNamespace(scope=scope)) == f"{short}_"

    @pytest.mark.parametrize("scope", [None, "", "other"])
    def test_unknown_scopes_keep_each_default(self, scope):
        assert schema_names._scope_short(scope) == "mvm"
        assert _simple._scope_short(SimpleNamespace(scope=scope), None) == "mvm"
        assert job_launcher.build_job_tags(model_scope=scope or "")["dbx_vibe_modelling_model"] == "ecm"

    def test_no_inline_ecm_or_mvm_substring_test_outside_the_normalizer(self):
        offenders = []
        for path, rel in iter_files(BACKEND, exempt=["core/_names.py"]):
            text = read_text(path) or ""
            exempt = self._infer_scope_lines(text) if rel == "sources/github.py" else range(0)
            for match in _INLINE_SCOPE_TEST.finditer(text):
                lineno = line_of(text, match.start())
                if lineno not in exempt and not is_comment(text.splitlines()[lineno - 1]):
                    offenders.append(f"{rel}:{lineno}")
        assert offenders == []

    @staticmethod
    def _infer_scope_lines(text: str) -> range:
        # `_infer_scope` reads an identifier ("ecmvm_v1" is ECM by its own
        # tie-break, pinned in test_sources_adversarial), not a scope field.
        (func,) = [n for n in ast.walk(ast.parse(text)) if isinstance(n, ast.FunctionDef) and n.name == "_infer_scope"]
        return range(func.lineno, func.end_lineno + 1)

    def test_the_scan_shape_catches_either_case_and_spares_membership_checks(self):
        assert _INLINE_SCOPE_TEST.search('x = "ECM" in scope')
        assert _INLINE_SCOPE_TEST.search("if 'mvm' not in s:")
        assert not _INLINE_SCOPE_TEST.search('scope in ("ecm", "mvm")')


class TestInitialSyncSanitizesRefusalReasons:

    def test_the_release_tag_from_model_json_is_redacted(self, engine, fake_uc):
        model = mock_model()
        model["release_version"] = "v0.0.1 /Volumes/main/secret/model.json owner@corp.example"
        fake_uc.add_agent_version("test_catalog", "Acme", 1, "mvm", model)

        with Session(engine) as session:
            summary = InitialSyncService(session, fake_uc.ws, "wh-123").discover_and_sync("test_catalog")
            session.commit()

        (error,) = summary["errors"]
        (refused,) = summary["refused"]
        for text in (error, refused["reason"]):
            assert "/Volumes/main" not in text and "owner@corp.example" not in text
            assert "not in the compatibility matrix" in text

    def test_a_long_release_tag_does_not_cut_the_fix_step(self, engine, fake_uc):
        model = mock_model()
        model["release_version"] = "v0.0.1-" + "x" * (MAX_ERROR_LENGTH + 100)
        fake_uc.add_agent_version("test_catalog", "Acme", 1, "mvm", model)

        with Session(engine) as session:
            summary = InitialSyncService(session, fake_uc.ws, "wh-123").discover_and_sync("test_catalog")
            session.commit()

        (refused,) = summary["refused"]
        assert len(refused["reason"]) > MAX_ERROR_LENGTH
        assert "Re-run the notebook pinned to" in refused["reason"]

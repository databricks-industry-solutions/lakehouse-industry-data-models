"""Canonical caller identity (``core/_identity.py``) and its consumers.

Covers the identity helper's header precedence, the ``Dependencies.UserIdentity``
gate on the preferences routes (``"local-dev"`` outside the Apps runtime, 401
inside it, ``LOCAL_DEV_USER`` with the forwarded-header gate off), rows
stored under another key (such as a preferred username) staying untouched by
``GET /user/preferences``, the ``DELETE /user/preferences/{key}`` route, and
the typed ``/current-user`` payload.
"""

from __future__ import annotations

import os
import sys

sys.path.insert(
    0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src")
)

import pytest
from fastapi import HTTPException
from sqlalchemy.sql.dml import Delete, Update
from sqlmodel import Session, select

from vibe_modeling.backend.core._headers import DatabricksAppsHeaders
from vibe_modeling.backend.core._identity import (
    ANONYMOUS_IDENTITY,
    LOCAL_DEV_IDENTITY,
    NO_EMAIL_MESSAGE,
    NO_IDENTITY_MESSAGE,
    actor_label,
    current_user_email,
    current_user_identity,
    current_user_profile,
    require_user_email,
    require_user_identity,
)
from vibe_modeling.backend.db_models import UserPreference
from vibe_modeling.backend.models import CurrentUserOut

NO_IDENTITY = {"error": "identity_missing", "message": NO_IDENTITY_MESSAGE}
NO_EMAIL = {"error": "identity_missing", "message": NO_EMAIL_MESSAGE}

ALICE_NAME = "alice"
ALICE_EMAIL = "alice@corp.example"


def _headers(*, email: str | None = None, name: str | None = None) -> DatabricksAppsHeaders:
    return DatabricksAppsHeaders(
        host=None,
        user_name=name,
        user_id=None,
        user_email=email,
        request_id=None,
        token=None,
    )


def _forwarded(*, email: str | None = None, name: str | None = None) -> dict[str, str]:
    out: dict[str, str] = {}
    if email is not None:
        out["X-Forwarded-Email"] = email
    if name is not None:
        out["X-Forwarded-Preferred-Username"] = name
    return out


def _rows(engine) -> set[tuple[str, str, str]]:
    with Session(engine) as s:
        return {(p.user_id, p.key, p.value) for p in s.exec(select(UserPreference)).all()}


def _seed(engine, *rows: tuple[str, str, str]) -> None:
    with Session(engine) as s:
        for user_id, key, value in rows:
            s.add(UserPreference(user_id=user_id, key=key, value=value))
        s.commit()


@pytest.fixture(autouse=True)
def _outside_apps_runtime(monkeypatch):
    monkeypatch.delenv("DATABRICKS_APP_NAME", raising=False)
    monkeypatch.delenv("LOCAL_DEV_USER", raising=False)


# --- current_user_identity ---------------------------------------------------


class TestCurrentUserIdentity:
    def test_username_only(self):
        assert current_user_identity(_headers(name=ALICE_NAME)) == ALICE_NAME

    def test_email_only(self):
        assert current_user_identity(_headers(email=ALICE_EMAIL)) == ALICE_EMAIL

    def test_both_differ_email_wins(self):
        assert current_user_identity(_headers(email=ALICE_EMAIL, name=ALICE_NAME)) == ALICE_EMAIL

    def test_neither_is_none(self):
        assert current_user_identity(_headers()) is None

    def test_empty_strings_are_none(self):
        assert current_user_identity(_headers(email="", name="")) is None

    def test_whitespace_only_headers_are_none(self):
        assert current_user_identity(_headers(email="   ", name="\t ")) is None

    def test_whitespace_email_falls_back_to_username(self):
        assert current_user_identity(_headers(email="  ", name=ALICE_NAME)) == ALICE_NAME

    def test_strips_but_preserves_case(self):
        assert current_user_identity(_headers(email="  Alice@Corp.Example ")) == "Alice@Corp.Example"


class TestActorLabel:
    def test_identity(self):
        assert actor_label(_headers(email=ALICE_EMAIL, name=ALICE_NAME)) == ALICE_EMAIL

    def test_anonymous_fallback(self):
        assert actor_label(_headers()) == ANONYMOUS_IDENTITY == "anonymous"
        assert actor_label(_headers(email=" ", name=" ")) == ANONYMOUS_IDENTITY


# --- require_user_identity ---------------------------------------------------


class TestCurrentUserEmail:
    def test_email_present(self):
        assert current_user_email(_headers(email=" alice@corp.example ", name=ALICE_NAME)) == ALICE_EMAIL

    def test_username_is_not_an_email_substitute(self):
        assert current_user_email(_headers(name=ALICE_NAME)) is None

    def test_blank_is_none(self):
        assert current_user_email(_headers(email="  ")) is None


class TestRequireUserEmail:
    def test_email_present(self):
        assert require_user_email(_headers(email=ALICE_EMAIL)) == ALICE_EMAIL

    def test_absent_outside_apps_raises_401_identity_missing(self):
        with pytest.raises(HTTPException) as exc:
            require_user_email(_headers(name=ALICE_NAME))
        assert exc.value.status_code == 401
        assert exc.value.detail == NO_EMAIL

    def test_absent_inside_apps_raises_401_identity_missing(self, monkeypatch):
        monkeypatch.setenv("DATABRICKS_APP_NAME", "vibe-modeling")
        with pytest.raises(HTTPException) as exc:
            require_user_email(_headers(name=ALICE_NAME))
        assert exc.value.status_code == 401
        assert exc.value.detail == NO_EMAIL


class TestRequireUserIdentity:
    def test_identity_present(self):
        assert require_user_identity(_headers(email=ALICE_EMAIL, name=ALICE_NAME)) == ALICE_EMAIL

    def test_absent_outside_apps_is_local_dev(self):
        assert require_user_identity(_headers()) == LOCAL_DEV_IDENTITY == "local-dev"

    def test_absent_inside_apps_raises_401(self, monkeypatch):
        monkeypatch.setenv("DATABRICKS_APP_NAME", "vibe-modeling")
        with pytest.raises(HTTPException) as exc:
            require_user_identity(_headers())
        assert exc.value.status_code == 401
        assert exc.value.detail == NO_IDENTITY

    def test_no_headers_outside_apps_stores_under_local_dev(self, client, engine):
        assert client.put("/api/user/preferences/k", json={"value": "v"}).status_code == 200
        assert _rows(engine) == {("local-dev", "k", "v")}
        prefs = client.get("/api/user/preferences").json()
        assert [(p["key"], p["value"]) for p in prefs] == [("k", "v")]

    def test_no_headers_inside_apps_get_401(self, client, monkeypatch):
        monkeypatch.setenv("DATABRICKS_APP_NAME", "vibe-modeling")
        response = client.get("/api/user/preferences")
        assert response.status_code == 401
        assert response.json()["detail"] == NO_IDENTITY

    def test_no_headers_inside_apps_put_401_and_no_row(self, client, engine, monkeypatch):
        monkeypatch.setenv("DATABRICKS_APP_NAME", "vibe-modeling")
        response = client.put("/api/user/preferences/k", json={"value": "v"})
        assert response.status_code == 401
        assert response.json()["detail"] == NO_IDENTITY
        assert _rows(engine) == set()

    def test_headers_inside_apps_succeed(self, client, engine, monkeypatch):
        monkeypatch.setenv("DATABRICKS_APP_NAME", "vibe-modeling")
        response = client.put(
            "/api/user/preferences/k", json={"value": "v"}, headers=_forwarded(email=ALICE_EMAIL)
        )
        assert response.status_code == 200
        assert _rows(engine) == {(ALICE_EMAIL, "k", "v")}

    def test_gate_off_with_local_dev_user(self, client, engine, monkeypatch):
        monkeypatch.setenv("TRUST_FORWARDED_HEADERS", "0")
        monkeypatch.setenv("LOCAL_DEV_USER", "dev@example.com")
        # Spoofed headers are dropped by the gate; LOCAL_DEV_USER is the identity.
        response = client.put(
            "/api/user/preferences/k", json={"value": "v"}, headers=_forwarded(email=ALICE_EMAIL)
        )
        assert response.status_code == 200
        assert _rows(engine) == {("dev@example.com", "k", "v")}


# --- GET /user/preferences reads the identity's rows only -------------------


class TestGetPreferencesReadsOnly:
    def test_username_rows_are_not_returned_or_moved(self, client, engine):
        _seed(engine, (ALICE_NAME, "theme", "dark"), (ALICE_EMAIL, "lang", "en"))
        response = client.get(
            "/api/user/preferences", headers=_forwarded(email=ALICE_EMAIL, name=ALICE_NAME)
        )
        assert response.status_code == 200
        assert [(p["key"], p["value"]) for p in response.json()] == [("lang", "en")]
        assert _rows(engine) == {(ALICE_NAME, "theme", "dark"), (ALICE_EMAIL, "lang", "en")}

    def test_get_issues_no_dml(self, client, engine, monkeypatch):
        _seed(engine, (ALICE_NAME, "theme", "dark"), (ALICE_EMAIL, "theme", "light"))
        original_execute = Session.execute
        dml: list[str] = []

        def spying_execute(self, statement, *args, **kwargs):
            if isinstance(statement, (Delete, Update)):
                dml.append(type(statement).__name__)
            return original_execute(self, statement, *args, **kwargs)

        monkeypatch.setattr(Session, "execute", spying_execute)
        response = client.get(
            "/api/user/preferences", headers=_forwarded(email=ALICE_EMAIL, name=ALICE_NAME)
        )
        assert response.status_code == 200
        assert dml == []


# --- DELETE /user/preferences/{key} -------------------------------------------


class TestDeleteUserPreference:
    def test_deletes_own_row_and_get_no_longer_returns_it(self, client, engine):
        headers = _forwarded(email=ALICE_EMAIL)
        _seed(engine, (ALICE_EMAIL, "theme", "dark"), (ALICE_EMAIL, "lang", "en"))
        response = client.delete("/api/user/preferences/theme", headers=headers)
        assert response.status_code == 200
        assert response.json() == {"deleted": True}
        prefs = client.get("/api/user/preferences", headers=headers).json()
        assert [(p["key"], p["value"]) for p in prefs] == [("lang", "en")]

    def test_missing_key_is_idempotent_200(self, client, engine):
        headers = _forwarded(email=ALICE_EMAIL)
        response = client.delete("/api/user/preferences/nope", headers=headers)
        assert response.status_code == 200
        assert response.json() == {"deleted": False}
        _seed(engine, (ALICE_EMAIL, "theme", "dark"))
        assert client.delete("/api/user/preferences/theme", headers=headers).json() == {"deleted": True}
        assert client.delete("/api/user/preferences/theme", headers=headers).json() == {"deleted": False}

    def test_other_users_row_with_same_key_untouched(self, client, engine):
        bob_email = "bob@corp.example"
        _seed(engine, (ALICE_EMAIL, "theme", "dark"), (bob_email, "theme", "light"))
        response = client.delete("/api/user/preferences/theme", headers=_forwarded(email=ALICE_EMAIL))
        assert response.json() == {"deleted": True}
        assert _rows(engine) == {(bob_email, "theme", "light")}

    def test_no_identity_inside_apps_401_and_row_kept(self, client, engine, monkeypatch):
        _seed(engine, ("local-dev", "k", "v"))
        monkeypatch.setenv("DATABRICKS_APP_NAME", "vibe-modeling")
        response = client.delete("/api/user/preferences/k")
        assert response.status_code == 401
        assert response.json()["detail"] == NO_IDENTITY
        assert _rows(engine) == {("local-dev", "k", "v")}

    def test_colon_key_round_trips_put_then_delete(self, client, engine):
        headers = _forwarded(email=ALICE_EMAIL)
        key = "visit:version:biz:3:mvm"
        assert client.put(
            f"/api/user/preferences/{key}", json={"value": "2026-01-01T00:00:00Z"}, headers=headers
        ).status_code == 200
        assert _rows(engine) == {(ALICE_EMAIL, key, "2026-01-01T00:00:00Z")}
        response = client.delete(f"/api/user/preferences/{key}", headers=headers)
        assert response.json() == {"deleted": True}
        assert _rows(engine) == set()

    def test_stale_loaded_row_then_two_deletes_report_true_then_false(self, client, engine):
        headers = _forwarded(email=ALICE_EMAIL)
        _seed(engine, (ALICE_EMAIL, "theme", "dark"))
        stale = Session(engine)
        try:
            assert stale.get(UserPreference, (ALICE_EMAIL, "theme")) is not None
            first = client.delete("/api/user/preferences/theme", headers=headers)
            second = client.delete("/api/user/preferences/theme", headers=headers)
        finally:
            stale.close()
        assert first.json() == {"deleted": True}
        assert second.json() == {"deleted": False}
        assert _rows(engine) == set()

    def test_does_not_touch_rows_under_another_key(self, client, engine):
        _seed(engine, (ALICE_NAME, "theme", "dark"), (ALICE_EMAIL, "lang", "en"))
        client.delete(
            "/api/user/preferences/lang", headers=_forwarded(email=ALICE_EMAIL, name=ALICE_NAME)
        )
        assert _rows(engine) == {(ALICE_NAME, "theme", "dark")}


# --- /current-user -----------------------------------------------------------


class TestCurrentUser:
    def test_profile_helper_returns_typed_model(self):
        assert isinstance(current_user_profile(_headers()), CurrentUserOut)

    def test_email_only(self, client):
        response = client.get("/api/current-user", headers=_forwarded(email=ALICE_EMAIL))
        assert response.status_code == 200
        assert response.json() == {
            "user_name": ALICE_EMAIL,
            "display_name": ALICE_EMAIL,
            "emails": [{"value": ALICE_EMAIL}],
        }

    def test_username_only(self, client):
        response = client.get("/api/current-user", headers=_forwarded(name=ALICE_NAME))
        assert response.status_code == 200
        assert response.json() == {
            "user_name": ALICE_NAME,
            "display_name": ALICE_NAME,
            "emails": [],
        }

    def test_both_headers(self, client):
        response = client.get(
            "/api/current-user", headers=_forwarded(email=ALICE_EMAIL, name=ALICE_NAME)
        )
        assert response.status_code == 200
        assert response.json() == {
            "user_name": ALICE_EMAIL,
            "display_name": ALICE_NAME,
            "emails": [{"value": ALICE_EMAIL}],
        }

    def test_no_headers_is_anonymous(self, client):
        response = client.get("/api/current-user")
        assert response.status_code == 200
        assert response.json() == {
            "user_name": "anonymous",
            "display_name": "Anonymous User",
            "emails": [],
        }

    def test_no_headers_inside_apps_stays_public(self, client, monkeypatch):
        monkeypatch.setenv("DATABRICKS_APP_NAME", "vibe-modeling")
        response = client.get("/api/current-user")
        assert response.status_code == 200
        assert response.json()["user_name"] == "anonymous"

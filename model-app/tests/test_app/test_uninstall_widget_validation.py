"""Defects #1 and #2 from a 2026-05-18 uninstall run that died before any
progress event was written. Two contracts are locked here:

Defect 1: ``core._widgets.build_widget_map`` must raise ``ValueError`` when
``operation`` requires ``model_version`` (uninstall / install / vibe / samples /
revert) and the value is empty — silently emitting a 27-key dict ships a
doomed run that dies in the agent's notebook widget validator before any
progress event is written.

Defect 2: ``POST /api/businesses/{id}/runs`` must 422 for version-bound
intents when no matching ``ModelVersion`` row can be resolved. The previous
behaviour was to dispatch with ``model_version=""``, which triggers Defect 1
agent-side.

A non-version-bound intent (``new-base-model``) and the happy path (a
seeded completed ``ModelVersion``) are also exercised so the gate doesn't
over-fire.
"""

from __future__ import annotations

from types import SimpleNamespace
from unittest.mock import MagicMock

import pytest

from vibe_modeling.backend.core._widgets import (
    _AGENT_OPS_REQUIRING_MODEL_VERSION,
    build_widget_map,
)


def _biz() -> SimpleNamespace:
    return SimpleNamespace(
        name="Test Retail",
        description="Test biz",
        industry_alignment="Retail",
    )


# ---------------------------------------------------------------------------
# Defect 1 — widget-builder validation
# ---------------------------------------------------------------------------


@pytest.mark.parametrize("operation", sorted(_AGENT_OPS_REQUIRING_MODEL_VERSION))
def test_build_widget_map_raises_when_required_model_version_empty(operation):
    """Empty ``model_version`` for a version-bound op → ValueError, not silent drop."""
    with pytest.raises(ValueError, match="model_version"):
        build_widget_map(
            operation=operation,
            data_model_scopes="Expanded Coverage Model - ECM",
            business=_biz(),
            catalog="vibe_modeling_test",
            session_id="abc-123",
            runtime_budget_seconds=21600,
            model_version="",
        )


@pytest.mark.parametrize("operation", sorted(_AGENT_OPS_REQUIRING_MODEL_VERSION))
def test_build_widget_map_raises_when_required_model_version_omitted(operation):
    """Omitting the kwarg entirely (default "") triggers the same gate."""
    with pytest.raises(ValueError, match="model_version"):
        build_widget_map(
            operation=operation,
            data_model_scopes="Expanded Coverage Model - ECM",
            business=_biz(),
            catalog="vibe_modeling_test",
            session_id="abc-123",
            runtime_budget_seconds=21600,
        )


def test_build_widget_map_happy_path_for_version_bound_op():
    """Non-empty ``model_version`` for a version-bound op succeeds."""
    widgets = build_widget_map(
        operation="uninstall model version",
        data_model_scopes="Expanded Coverage Model - ECM",
        business=_biz(),
        catalog="vibe_modeling_test",
        session_id="abc-123",
        runtime_budget_seconds=21600,
        model_version="4",
    )
    assert widgets["model_version"] == "4"
    assert widgets["operation"] == "uninstall model version"


def test_build_widget_map_allows_empty_model_version_for_unbound_op():
    """``new base model`` does NOT require ``model_version`` (creates v1).

    Regression guard for the non-version-bound branch — the gate must not
    over-fire on ops that legitimately have no parent version.
    """
    widgets = build_widget_map(
        operation="new base model",
        data_model_scopes="Expanded Coverage Model - ECM",
        business=_biz(),
        catalog="vibe_modeling_test",
        session_id="abc-123",
        runtime_budget_seconds=21600,
        model_version="",
    )
    # Empty model_version is still dropped from the widget dict for unbound
    # ops — preserves the legacy 28-key shape for ``new base model``.
    assert "model_version" not in widgets
    assert widgets["operation"] == "new base model"


# ---------------------------------------------------------------------------
# Defect 2 — route-level 422 when ModelVersion can't be resolved
# ---------------------------------------------------------------------------


@pytest.mark.parametrize(
    "intent",
    ["uninstall", "install", "vibe-iterate"],
)
def test_create_run_version_bound_intent_with_no_model_version_returns_422(
    intent, client_with_agent, mock_ws, seed_business,
):
    """Version-bound intent + no resolvable ModelVersion → 422, no dispatched run.

    ``seed_business`` intentionally provides NO completed ModelVersion —
    exactly the orphan-schema state observed in that run.
    """
    mock_run = MagicMock()
    mock_run.run_id = 100
    mock_ws.jobs.run_now.return_value = mock_run

    payload = {
        "intent": intent,
        "catalog": "test_cat",
        "business_context_path": "/Volumes/test/ctx/vibes/ctx.json",
    }
    if intent == "vibe-iterate":
        payload["vibe_instructions"] = "noop"

    response = client_with_agent.post(
        f"/api/businesses/{seed_business}/runs", json=payload,
    )
    assert response.status_code == 422, (
        f"expected 422 for {intent!r} with no completed ModelVersion; "
        f"got {response.status_code}: {response.json()}"
    )
    detail = response.json().get("detail", "")
    assert "ModelVersion" in detail or "version_id" in detail, (
        f"detail must explain the gap; got: {detail!r}"
    )
    # Critical: no dispatched run row should have been created.
    runs = client_with_agent.get(
        f"/api/businesses/{seed_business}/runs",
    ).json()
    assert runs == [], (
        f"422 path must not persist a run row; got {len(runs)}: {runs}"
    )
    # And the workspace mock must not have been asked to launch anything.
    assert not mock_ws.jobs.run_now.called


def test_create_run_uninstall_with_resolvable_version_still_dispatches(
    client_with_agent, mock_ws, seed_business_with_version,
):
    """Regression: happy-path uninstall (with a seeded completed v1) still dispatches."""
    mock_run = MagicMock()
    mock_run.run_id = 100
    mock_ws.jobs.run_now.return_value = mock_run

    response = client_with_agent.post(
        f"/api/businesses/{seed_business_with_version}/runs",
        json={
            "intent": "uninstall",
            "catalog": "test_cat",
        },
    )
    assert response.status_code == 200, (
        f"happy-path uninstall must dispatch; got {response.status_code}: "
        f"{response.json()}"
    )
    body = response.json()
    assert body["intent"] == "uninstall"


def test_create_run_new_base_model_no_version_still_succeeds(
    client_with_agent, mock_ws, seed_business,
):
    """Regression: ``new-base-model`` is NOT version-bound (creates v1)."""
    mock_run = MagicMock()
    mock_run.run_id = 100
    mock_ws.jobs.run_now.return_value = mock_run

    response = client_with_agent.post(
        f"/api/businesses/{seed_business}/runs",
        json={
            "intent": "new-base-model",
            "catalog": "test_cat",
            "business_context_path": "/Volumes/test/ctx/vibes/ctx.json",
        },
    )
    assert response.status_code == 200, (
        f"new-base-model must not trip the version-bound gate; got "
        f"{response.status_code}: {response.json()}"
    )

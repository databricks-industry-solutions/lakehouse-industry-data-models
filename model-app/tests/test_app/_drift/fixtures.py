"""Opt-in pytest fixtures for the drift tests.

Import the fixture into the test module that uses it::

    from ._drift.fixtures import fake_uc  # noqa: F401

``conftest.py`` and its shared ``mock_ws`` are not changed. A route-level test
can point the conftest ``client`` at the fake by overriding ``mock_ws`` in its
own module with a fixture that returns ``fake_uc.ws``.
"""
from __future__ import annotations

import json
from pathlib import Path
from typing import Optional

import pytest
from sqlmodel import Session, select

from vibe_modeling.backend.core._names import agent_business_segment
from vibe_modeling.backend.db_models import Business, ModelVersion, ModelVersionInstall
from vibe_modeling.backend.model_sync import ModelSyncService

from .fake_uc import FakeUC

MOCK_MODEL = Path(__file__).resolve().parents[2] / "fixtures" / "mock_model.json"
WAREHOUSE_ID = "wh-drift"


def mock_model() -> dict:
    """A fresh copy of ``tests/fixtures/mock_model.json`` (2 domains, 3
    products, 10 attributes)."""
    return json.loads(MOCK_MODEL.read_text())


def seed_synced_version(
    session: Session,
    fake_uc: FakeUC,
    *,
    catalog: str,
    business_name: str,
    version: int = 1,
    scope: str = "mvm",
    model: Optional[dict] = None,
    uc_catalog: Optional[str] = None,
    deployment_status: str = "deployed",
) -> ModelVersion:
    """An agent-produced version on both sides: the agent's registry rows and
    ``model.json`` in ``catalog`` on the fake, and the Business, a completed
    ModelVersion and its elements in Lakebase through the real
    ``ModelSyncService.sync_model``, called with the agent segment of the name
    as the generation finalize does. ``files_catalog`` is ``catalog`` (where
    the agent wrote it); ``uc_catalog`` defaults to ``catalog`` (One Catalog
    style). A ``deployed`` version with a ``uc_catalog`` also
    gets an open ``ModelVersionInstall`` row there, as an install records it.
    Commits."""
    model = model if model is not None else mock_model()
    fake_uc.add_agent_version(catalog, business_name, version, scope, model)
    business = session.exec(select(Business).where(Business.name == business_name)).first()
    if business is None:
        business = Business(name=business_name)
        session.add(business)
        session.flush()
    mv = ModelVersion(
        business_id=business.id, version=version, scope=scope, status="completed",
        deployment_status=deployment_status,
        uc_catalog=catalog if uc_catalog is None else uc_catalog,
        files_catalog=catalog,
    )
    session.add(mv)
    session.flush()
    if deployment_status == "deployed" and mv.uc_catalog:
        session.add(ModelVersionInstall(version_id=mv.id, catalog=mv.uc_catalog))
    synced = ModelSyncService(session, fake_uc.ws, WAREHOUSE_ID).sync_model(
        mv.id, catalog, agent_business_segment(business_name), str(version), scope,
    )
    assert synced, f"sync_model found no model for {business_name} v{version} {scope} in {catalog}"
    session.commit()
    session.refresh(mv)
    return mv


@pytest.fixture
def fake_uc():
    """A :class:`FakeUC` with the app's ``_metamodel`` seams patched for the
    test. Fails the test at teardown when any SQL reached
    ``ws.statement_execution``, even if the app swallowed the error."""
    fake = FakeUC()
    with fake.patched():
        yield fake
    fake.assert_no_unrecorded_sql()

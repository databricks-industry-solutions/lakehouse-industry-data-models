"""Install of a scoped vibe run's output, from the model version page.

A scoped run (agent 5.3.3) writes a ``model.json`` with a root ``_vibe_scope``
block, saved as a ``draft`` version for a Dry Run. The version page's Install
posts only ``{intent, version_id}``. The install must go through the
version-conventions logic in ``Install.dispatch``: the file's conventions
reach the widgets, so the agent's convention fence does not refuse it.
"""

from __future__ import annotations

import io
import json
from pathlib import Path
from unittest.mock import MagicMock

import pytest
from sqlmodel import Session, select

from vibe_modeling.backend.core._paths import model_json_volume_path
from vibe_modeling.backend.db_models import Business, ModelVersion, RunOperation
from vibe_modeling.backend.services.operations import _registry as _registry_module
from vibe_modeling.backend.services.operations.install import Install

_FIXTURE = Path(__file__).parent.parent / "fixtures" / "vibe_scope_model_v3.json"
_CATALOG = "ridgeline_energy_vibe_model"


@pytest.fixture(autouse=True)
def _install_registered():
    _registry_module.reset_for_tests()
    _registry_module.register(Install())
    yield
    _registry_module.reset_for_tests()


def _seed_scoped_output(engine, *, status: str) -> tuple[str, str, int]:
    """The rows a scoped vibe run leaves: v2 (its base) and v3 (its output)."""
    with Session(engine) as s:
        biz = Business(name="ridgeline_energy", description="Utility")
        s.add(biz)
        s.flush()
        # A completed output is the head: its base was superseded and evicted
        # (B2), so re-installing it is one install step.
        base = ModelVersion(
            business_id=biz.id, version=2, scope="mvm",
            status="completed" if status == "draft" else "superseded",
            deployment_status="deployed" if status == "draft" else "uninstalled",
            uc_catalog=_CATALOG,
        )
        s.add(base)
        s.flush()
        out = ModelVersion(
            business_id=biz.id, version=3, scope="mvm", status=status,
            deployment_status="draft", uc_catalog=_CATALOG, base_version_id=base.id,
            scope_fence_mode="domains", scope_base_version=2, scope_base_scope="mvm",
        )
        s.add(out)
        s.commit()
        return biz.id, out.id, out.version


def _ws_serving(mock_ws: MagicMock, raw: bytes) -> list[str]:
    downloaded: list[str] = []

    def _download(path, *a, **k):
        downloaded.append(path)
        resp = MagicMock()
        resp.contents = io.BytesIO(raw)
        return resp

    mock_ws.files.download.side_effect = _download
    run = MagicMock()
    run.run_id = 31337
    run.response = MagicMock()
    run.response.run_id = 31337
    mock_ws.jobs.run_now.return_value = run
    return downloaded


@pytest.mark.parametrize("status", ["draft", "completed"])
def test_version_page_install_sends_the_scoped_files_conventions(
    client_with_agent, mock_ws, engine, status
):
    business_id, version_id, version = _seed_scoped_output(engine, status=status)
    downloaded = _ws_serving(mock_ws, _FIXTURE.read_bytes())

    resp = client_with_agent.post(
        f"/api/businesses/{business_id}/runs",
        json={"intent": "install", "version_id": version_id, "catalog": _CATALOG},
    )

    assert resp.status_code == 200, resp.text
    with Session(engine) as s:
        op = s.exec(
            select(RunOperation).where(RunOperation.run_id == resp.json()["id"])
        ).one()
    params = json.loads(op.params_json)
    assert params["explicit_convention_keys"] == []
    widgets = json.loads(op.dispatched_widgets_json)
    expected_path = model_json_volume_path(_CATALOG, "ridgeline_energy", version, "mvm")
    assert widgets["context_file"] == expected_path
    assert expected_path in downloaded
    assert widgets["schema_prefix"] == "mvm_v2_"
    assert widgets["naming_convention"] == "snake_case"
    assert widgets["primary_key_suffix"] == "_id"
    assert widgets["table_id_type"] == "BIGINT"

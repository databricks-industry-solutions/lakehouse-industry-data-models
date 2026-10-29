"""Which ``model.json`` an install sends the agent as its ``context_file``.

E-15: a downloaded industry version records ``import_source_path`` as a
``github://`` URI. The agent refuses a ``context_file`` that is not a file path
("Model JSON File must be a FILE PATH"), so the install sends the version's
Volume copy instead. The order is the one ``services/version_files`` gives
every reader of a version's file (install, the vibe pre-fill, the shrink copy):
a ``/Volumes/`` import source first, then the canonical nested folder and the
flat folder under the version's files catalog.

The route resolves the version's candidates (``preflight._simple_dag``,
``version_model_json_candidates``: files catalog, else install catalog, else
the metamodel catalog) and the install step adds the target catalog's folders
last.

Files are the upstream agriculture ECM shape in
``tests/fixtures/industry_agriculture_v1_trimmed.json``.
"""

from __future__ import annotations

import json
from pathlib import Path
from types import SimpleNamespace
from typing import Any, Optional
from unittest.mock import MagicMock, patch

import pytest
from sqlmodel import Session

from vibe_modeling.backend.db_models import AgentConfig, Business, ModelVersion
from vibe_modeling.backend.error_sanitization import sanitize_error_message
from vibe_modeling.backend.models import Intent, RunIn
from vibe_modeling.backend.services.operations import OperationContext
from vibe_modeling.backend.services.operations import install as install_mod
from vibe_modeling.backend.services.operations.install import Install
from vibe_modeling.backend.services.orchestrator.dag_factories._simple import dag_for_install
from vibe_modeling.backend.services.orchestrator.preflight import _simple_dag
from vibe_modeling.backend.services.version_files import (
    model_json_candidates,
    read_version_conventions,
    version_model_json_candidates,
)

_LAUNCH = "vibe_modeling.backend.services.operations.install.launch_run"
_AGRICULTURE = json.loads(
    (Path(__file__).resolve().parents[1] / "fixtures" / "industry_agriculture_v1_trimmed.json").read_text()
)
ECM_FILE = _AGRICULTURE["ecm"]

FILES_CAT = "vibe_modeling_meta"
BUSINESS = SimpleNamespace(name="agriculture")
GITHUB = (
    "github://databricks-industry-solutions/lakehouse-industry-data-models@main/"
    "data-models/agriculture/v1/ecm/model.json"
)
NESTED = f"/Volumes/{FILES_CAT}/_metamodel/vol_root/business/agriculture/v1/ecm/model.json"
FLAT = f"/Volumes/{FILES_CAT}/_metamodel/vol_root/business/agriculture/ecm_v1/model.json"
LEGACY = "/Volumes/landing/imports/agriculture/ecm_v1/model.json"


def _ws_serving(files: dict[str, Any]) -> MagicMock:
    """A client whose ``files.download`` serves ``files`` by path (JSON
    objects, or raw bytes); any other path, a ``github://`` URI included, is
    refused as the Files API refuses it."""
    ws = MagicMock()

    def _download(path):
        if path not in files:
            raise FileNotFoundError(path)
        body = files[path]
        resp = MagicMock()
        resp.contents.read.return_value = body if isinstance(body, bytes) else json.dumps(body).encode()
        return resp

    ws.files.download.side_effect = _download
    return ws


def _install_params(mv: SimpleNamespace, *, catalog: str = FILES_CAT) -> dict:
    """The install step's params, with the version's candidates resolved as
    the route resolves them."""
    req = RunIn(intent="install", catalog=catalog, cataloging_style="One Catalog")
    ctx = SimpleNamespace(
        parent_mv=mv,
        context_file_candidates=version_model_json_candidates(MagicMock(), mv, BUSINESS.name),
    )
    dag = dag_for_install(req, BUSINESS, ctx)
    return dict(dag.steps[0].params)


def _canonical(catalog: str) -> list[str]:
    return model_json_candidates(catalog, "agriculture", 1, "ecm")


def _mv(import_source_path: Optional[str], **kw: Any) -> SimpleNamespace:
    return SimpleNamespace(
        id="mv-1", scope="ecm", version=1, files_catalog=FILES_CAT,
        import_source_path=import_source_path, dry_run=False, **kw,
    )


def _dispatch(params: dict, ws: MagicMock) -> dict:
    captured: dict = {}

    def _fake_launch_run(ws_, job_id, widget_params, *a, **k):
        captured.update(widget_params)
        return 4242

    ctx = OperationContext(
        run_id="run-t", operation_id="op-t", business_id="biz-t",
        parent_version_id="mv-1", params=params,
        inherited_params={"cataloging_style": "One Catalog"},
    )
    with patch(_LAUNCH, _fake_launch_run):
        Install().dispatch(ctx, ws, MagicMock())
    return captured


class TestInstallSendsAFilePath:
    def test_industry_version_with_a_github_source_sends_the_volume_path(self):
        """E-15."""
        ws = _ws_serving({NESTED: ECM_FILE})
        widgets = _dispatch(_install_params(_mv(GITHUB)), ws)
        assert widgets["context_file"] == NESTED
        assert all(not c.args[0].startswith("github://") for c in ws.files.download.call_args_list)

    def test_the_github_source_is_never_a_step_candidate(self):
        assert _install_params(_mv(GITHUB))["context_file_candidates"] == [NESTED, FLAT]

    def test_a_context_without_version_candidates_reads_the_target_catalog(self):
        req = RunIn(intent="install", catalog="other_cat", cataloging_style="One Catalog")
        dag = dag_for_install(req, BUSINESS, SimpleNamespace(parent_mv=_mv(LEGACY)))
        assert dag.steps[0].params["context_file_candidates"] == [LEGACY, *_canonical("other_cat")]

    def test_legacy_dialog_import_sends_its_volume_source(self):
        ws = _ws_serving({LEGACY: ECM_FILE, NESTED: ECM_FILE})
        widgets = _dispatch(_install_params(_mv(LEGACY)), ws)
        assert widgets["context_file"] == LEGACY
        ws.files.download.assert_called_once_with(LEGACY)

    def test_a_deleted_legacy_source_falls_to_the_canonical_folder(self):
        ws = _ws_serving({NESTED: ECM_FILE})
        widgets = _dispatch(_install_params(_mv(LEGACY)), ws)
        assert widgets["context_file"] == NESTED

    def test_the_flat_folder_is_the_last_resort(self):
        ws = _ws_serving({FLAT: ECM_FILE})
        widgets = _dispatch(_install_params(_mv(GITHUB)), ws)
        assert widgets["context_file"] == FLAT

    def test_an_unparseable_candidate_is_skipped(self):
        ws = _ws_serving({NESTED: b"{not json", FLAT: ECM_FILE})
        widgets = _dispatch(_install_params(_mv(GITHUB)), ws)
        assert widgets["context_file"] == FLAT

    def test_an_agent_version_installed_into_another_catalog_reads_its_files_catalog(self):
        params = _install_params(_mv(None), catalog="other_cat")
        assert params["deployment_catalog"] == "other_cat"
        assert params["context_file_candidates"] == [NESTED, FLAT, *_canonical("other_cat")]
        widgets = _dispatch(params, _ws_serving({NESTED: ECM_FILE}))
        assert widgets["context_file"] == NESTED

    def test_a_version_with_no_files_catalog_reads_its_install_catalog_first(self):
        mv = _mv(None, uc_catalog="home_cat")
        mv.files_catalog = None
        params = _install_params(mv, catalog="other_cat")
        assert params["context_file_candidates"] == [*_canonical("home_cat"), *_canonical("other_cat")]


class TestDownloadedOn08x:
    """An industry downloaded on 0.8.x has neither ``files_catalog`` nor
    ``uc_catalog`` (the ``v_0_9_0`` backfill skips rows with an
    ``import_source_path``), and its files sit under the metamodel catalog.
    Installed into another catalog, the route's candidates read that copy, as
    the vibe pre-fill and the shrink copy do."""

    META = "meta_cat"
    TARGET = "other_cat"

    def _seed(self, session: Session, *, occupied: bool = False) -> tuple[Business, ModelVersion]:
        session.add(AgentConfig(notebook_path="/Workspace/test/notebook", deployment_catalog=self.META))
        biz = Business(name="agriculture", description="d")
        session.add(biz)
        session.flush()
        mv = ModelVersion(
            business_id=biz.id, version=1, scope="ecm", status="completed",
            deployment_status="draft", import_source_path=GITHUB,
        )
        session.add(mv)
        if occupied:
            session.add(ModelVersion(
                business_id=biz.id, version=2, scope="ecm", status="completed",
                deployment_status="deployed", uc_catalog=self.TARGET, files_catalog=self.TARGET,
            ))
        session.commit()
        session.refresh(mv)
        return biz, mv

    def _install_step(self, session: Session, biz: Business, mv: ModelVersion) -> dict:
        req = RunIn(intent="install", catalog=self.TARGET, cataloging_style="One Catalog")
        dag = _simple_dag(req, biz, None, Intent.INSTALL, mv, session)
        return dict(next(s for s in dag.steps if s.name == "install").params)

    def test_install_into_another_catalog_reads_the_metamodel_copy(self, engine):
        with Session(engine) as session:
            biz, mv = self._seed(session)
            params = self._install_step(session, biz, mv)
            assert params["deployment_catalog"] == self.TARGET
            assert params["context_file_candidates"] == [*_canonical(self.META), *_canonical(self.TARGET)]
            meta_nested = _canonical(self.META)[0]
            widgets = _dispatch(params, _ws_serving({meta_nested: ECM_FILE}))
            assert widgets["context_file"] == meta_nested

    def test_the_candidates_match_the_vibe_prefill_reader(self, engine):
        with Session(engine) as session:
            biz, mv = self._seed(session)
            params = self._install_step(session, biz, mv)
            own = version_model_json_candidates(session, mv, biz.name)
            assert params["context_file_candidates"][: len(own)] == own

    def test_an_occupied_catalog_installs_with_the_same_candidates(self, engine):
        with Session(engine) as session:
            biz, mv = self._seed(session, occupied=True)
            req = RunIn(intent="install", catalog=self.TARGET, cataloging_style="One Catalog")
            dag = _simple_dag(req, biz, None, Intent.INSTALL, mv, session)
            assert [s.name for s in dag.steps] == ["uninstall", "install"]
            assert dag.steps[1].params["context_file_candidates"] == [
                *_canonical(self.META), *_canonical(self.TARGET),
            ]


class TestNoReadableCandidate:
    def test_the_step_fails_naming_the_version_and_catalog(self):
        with pytest.raises(RuntimeError) as err:
            _dispatch(_install_params(_mv(GITHUB)), _ws_serving({}))
        assert str(err.value) == (
            f"install: couldn't read the model.json of ECM version 1 from its folders in catalog {FILES_CAT}"
        )

    def test_the_message_survives_the_run_sanitizer(self):
        with pytest.raises(RuntimeError) as err:
            _dispatch(_install_params(_mv(LEGACY), catalog="other_cat"), _ws_serving({}))
        message = str(err.value)
        assert sanitize_error_message(message) == message
        assert message.endswith(f"in catalog landing or {FILES_CAT} or other_cat")
        assert "REDACTED" not in sanitize_error_message(message)

    def test_the_server_log_names_every_path_tried(self, caplog):
        with caplog.at_level("ERROR", logger=install_mod.__name__):
            with pytest.raises(RuntimeError):
                _dispatch(_install_params(_mv(LEGACY)), _ws_serving({}))
        tried = caplog.text.split("tried ", 1)[1].strip().split(", ")
        assert tried == [LEGACY, NESTED, FLAT]

    def test_nothing_is_launched(self):
        launched: list = []
        ctx = OperationContext(
            run_id="r", operation_id="o", business_id="b", parent_version_id="mv-1",
            params=_install_params(_mv(GITHUB)), inherited_params={},
        )
        with patch(_LAUNCH, lambda *a, **k: launched.append(a)):
            with pytest.raises(RuntimeError):
                Install().dispatch(ctx, _ws_serving({}), MagicMock())
        assert launched == []


class TestInstallReadBudget:
    """The install needs its file, so each read gets the longer install
    budget; the optional readers keep ``_READ_TIMEOUT_S``."""

    def test_the_install_passes_the_longer_budget(self):
        budgets: list = []

        def _read(ws, path, *, timeout_s=None):
            budgets.append(timeout_s)
            return ECM_FILE

        from vibe_modeling.backend.services.operations import _install_conventions as ic

        # ``version_files.first_readable_model_json`` imports the reader at call time.
        with patch.object(ic, "read_model_json", _read):
            _dispatch(_install_params(_mv(GITHUB)), _ws_serving({}))
        assert budgets == [60]
        assert install_mod.REQUIRED_READ_TIMEOUT_S == 60

    def test_the_optional_readers_keep_the_short_budget(self):
        from vibe_modeling.backend.services.operations import _install_conventions as ic

        assert ic._READ_TIMEOUT_S == 15


class TestSharedCandidateOrder:
    """``version_files.model_json_candidates`` is the one order every reader uses."""

    def test_volume_source_then_nested_then_flat(self):
        assert model_json_candidates(FILES_CAT, "agriculture", 1, "ecm", LEGACY) == [LEGACY, NESTED, FLAT]

    def test_a_non_volume_source_is_dropped(self):
        for source in (GITHUB, "https://example.com/model.json", "dbfs:/x/model.json", "relative/model.json"):
            assert model_json_candidates(FILES_CAT, "agriculture", 1, "ecm", source) == [NESTED, FLAT]

    def test_no_source_is_the_canonical_pair(self):
        assert model_json_candidates(FILES_CAT, "agriculture", 1, "ecm", None) == [NESTED, FLAT]
        assert model_json_candidates(FILES_CAT, "agriculture", 1, "ecm", "  ") == [NESTED, FLAT]

    def test_a_source_equal_to_a_canonical_path_is_listed_once(self):
        assert model_json_candidates(FILES_CAT, "agriculture", 1, "ecm", FLAT) == [FLAT, NESTED]

    def test_a_row_reads_its_files_catalog(self):
        mv = SimpleNamespace(files_catalog=FILES_CAT, uc_catalog="other", version=1, scope="ecm", import_source_path=GITHUB)
        assert version_model_json_candidates(MagicMock(), mv, "agriculture") == [NESTED, FLAT]

    def test_the_shrink_copy_reads_the_volume_copy_of_a_downloaded_version(self):
        """``shrink_to_mvm`` copies its parent's conventions through
        ``read_version_conventions``."""
        mv = SimpleNamespace(files_catalog=FILES_CAT, uc_catalog="", version=1, scope="ecm", import_source_path=GITHUB)
        ws = _ws_serving({NESTED: ECM_FILE})
        conventions = read_version_conventions(MagicMock(), ws, mv, "agriculture")
        assert conventions["data_asset_naming_convention"] == "snake_case"
        assert [c.args[0] for c in ws.files.download.call_args_list] == [NESTED]

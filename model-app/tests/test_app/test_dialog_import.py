"""The import dialogs bring a model in through the app's own folder.

Both routes (``executeImport`` into an existing business,
``createBusinessAndExecuteImport``) settle the scope
(``import_model.import_scope``), refuse an occupied app folder, copy the
file's folder into the app's folder for the version with the app's copy of
the model.json (``scope_prefix``: prefixed unless agent output, stamped),
index the copy, and seed ``_metamodel`` with the copy and its folder.
Real data: the agriculture industry MVM
(``tests/fixtures/industry_agriculture_v1_trimmed.json``, blank prefix,
``data_model_scopes`` "Expanded Coverage Model - ECM").
"""
from __future__ import annotations

import copy
import json
from pathlib import Path

import pytest
from databricks.sdk.errors import PermissionDenied
from sqlmodel import Session, select

from vibe_modeling.backend.core import _runs
from vibe_modeling.backend.core._paths import version_dir_in_volume
from vibe_modeling.backend.core._runs import LOCK_BUSY_MESSAGE, BusinessBusy, active_run_message
from vibe_modeling.backend.db_models import Business, Domain, ModelVersion, Run, RunArtifact
from vibe_modeling.backend.services import dialog_import
from vibe_modeling.backend.services.version_files import version_model_json_candidates

from ._assess_helpers import table_digests
from .conftest import stub_no_metamodel
from ._fake_volume import FakeVolume

CATALOG = "test_metamodel_catalog"
SOURCE = "/Volumes/landing/raw/agri_drop"
FIXTURE = json.loads((Path(__file__).parent.parent / "fixtures" / "industry_agriculture_v1_trimmed.json").read_text())


def _agriculture_mvm(*, version: str | None = "v1_mvm") -> dict:
    root = copy.deepcopy(FIXTURE["mvm"])
    root["model_requirements"]["data_model_scopes"] = "Expanded Coverage Model - ECM"
    model = root["model"]
    model.update({"type": "business", "description": "Agriculture.", "industry_alignment": "Retail"})
    if version is None:
        model.pop("version", None)
    else:
        model["version"] = version
    for domain in model["domains"]:
        domain["products"] = []
    return root


@pytest.fixture
def seeds(monkeypatch):
    calls: list[dict] = []
    monkeypatch.setattr(dialog_import, "seed_metamodel_one", lambda ws, **kw: calls.append(kw) or None)
    return calls


def _volume(mock_ws, root: dict, folder: str = SOURCE) -> FakeVolume:
    volume = FakeVolume(mock_ws)
    volume.put(f"{folder}/model.json", root)
    volume.put(f"{folder}/readme.md", "Agriculture MVM")
    volume.put(f"{folder}/metrics/crop_yield.sql", "CREATE OR REPLACE VIEW `agriculture_ecm`.`_metrics`.`crop_yield`")
    return volume


def _execute(client, biz: str, path: str = f"{SOURCE}/model.json", **extra):
    return client.post(
        f"/api/businesses/{biz}/import/execute",
        json={"volume_path": path, "accept_business_mismatch": True, **extra},
    )


def _version(engine, version_id: str) -> ModelVersion:
    with Session(engine) as s:
        return s.get(ModelVersion, version_id)


class TestExecuteImport:
    def test_the_apps_copy_is_prefixed_and_the_users_file_is_unchanged(
        self, engine, client_with_agent, mock_ws, seed_business, seeds,
    ):
        volume = _volume(mock_ws, _agriculture_mvm())
        before = dict(volume.under(SOURCE))
        r = _execute(client_with_agent, seed_business)
        assert r.status_code == 200, r.text
        folder = version_dir_in_volume(CATALOG, "Test Corp", 1, "mvm")
        assert volume.under(SOURCE) == before
        copied = volume.json(f"{folder}/model.json")["model"]
        assert copied["version"] == "v1_mvm"
        assert copied["model_conventions"]["schema_prefix"] == "mvm_"
        assert all(d["database_name"].startswith("mvm_") for d in copied["domains"])
        assert all(v["view_name"].startswith("mvm_") for v in copied["metric_views"])
        assert volume.files[f"{folder}/readme.md"] == before[f"{SOURCE}/readme.md"]
        assert volume.files[f"{folder}/metrics/crop_yield.sql"] == before[f"{SOURCE}/metrics/crop_yield.sql"]

        mv = _version(engine, r.json()["version_id"])
        assert (mv.scope, mv.files_catalog, mv.import_source_path) == ("mvm", CATALOG, f"{SOURCE}/model.json")
        assert (mv.import_schema_prefix_added, mv.import_view_prefix_added) == ("mvm_", "mvm_")
        with Session(engine) as s:
            rows = {d.database_name for d in s.exec(select(Domain).where(Domain.version_id == mv.id)).all()}
            arts = {a.file_path for a in s.exec(select(RunArtifact).where(RunArtifact.model_version_id == mv.id)).all()}
            assert version_model_json_candidates(s, mv, "Test Corp")[0] == f"{folder}/model.json"
        assert rows == {d["database_name"] for d in copied["domains"]}
        assert arts == {f"{folder}/model.json", f"{folder}/readme.md", f"{folder}/metrics/crop_yield.sql"}
        assert [kw["location"] for kw in seeds] == [folder]
        assert {d["database_name"] for d in seeds[0]["model_json"]["model"]["domains"]} == rows

    def test_agent_output_is_kept_as_written_except_the_stamp(
        self, engine, client_with_agent, mock_ws, seed_business, seeds,
    ):
        root = _agriculture_mvm(version="v4_mvm")
        root["_vibe_scope"] = {"mode": "domains", "base_version": "3", "base_scope": "mvm"}
        volume = _volume(mock_ws, root)
        r = _execute(client_with_agent, seed_business)
        assert r.status_code == 200, r.text
        copied = volume.json(f"{version_dir_in_volume(CATALOG, 'Test Corp', 1, 'mvm')}/model.json")
        expected = copy.deepcopy(root)
        expected["model"]["version"] = "v1_mvm"
        assert copied == expected
        mv = _version(engine, r.json()["version_id"])
        assert (mv.import_schema_prefix_added, mv.import_view_prefix_added) == ("", "")

    def test_a_linked_run_makes_it_agent_output(self, engine, client_with_agent, mock_ws, seed_business, seeds):
        volume = _volume(mock_ws, _agriculture_mvm())
        r = _execute(client_with_agent, seed_business, databricks_run_id=4242)
        assert r.status_code == 200, r.text
        copied = volume.json(f"{version_dir_in_volume(CATALOG, 'Test Corp', 1, 'mvm')}/model.json")["model"]
        assert {d["database_name"] for d in copied["domains"]} == {d["name"] for d in copied["domains"]}

    def test_a_file_in_the_apps_folder_for_the_version_is_kept(
        self, engine, client_with_agent, mock_ws, seed_business, seeds,
    ):
        """A2: an agent version folder that is the destination: no copy, no
        upload, the file unchanged, 200."""
        folder = version_dir_in_volume(CATALOG, "Test Corp", 1, "mvm")
        volume = _volume(mock_ws, _agriculture_mvm(), folder=folder)
        before = dict(volume.files)
        r = _execute(client_with_agent, seed_business, path=f"{folder}/model.json")
        assert r.status_code == 200, r.text
        assert volume.uploads == [] and volume.files == before
        assert [kw["location"] for kw in seeds] == [folder]

    def test_an_occupied_folder_is_refused_and_nothing_is_written(
        self, engine, client_with_agent, mock_ws, seed_business, seeds,
    ):
        volume = _volume(mock_ws, _agriculture_mvm())
        folder = version_dir_in_volume(CATALOG, "Test Corp", 1, "mvm")
        volume.put(f"{folder}/model.json", {"left": "over"})
        before_files = dict(volume.files)
        before = table_digests(engine)
        r = _execute(client_with_agent, seed_business)
        assert r.status_code == 409, r.text
        detail = r.json()["detail"]
        assert detail["error"] == "import_folder_occupied" and detail["path"] == folder
        assert detail["message"] == (
            "The app's folder for this business's v1 MVM, business/test_corp/v1/mvm in the volume "
            f"{CATALOG}._metamodel.vol_root, already holds files from a deleted version or from an agent run "
            "the app did not record. Delete that folder in Catalog Explorer, then import again."
        )
        assert table_digests(engine) == before
        assert volume.files == before_files and seeds == []

    @pytest.mark.parametrize("scope,body,expected", [
        ("v1", {}, "Choose whether this model is an ECM or an MVM."),
        ("v1_mvm", {"scope": "ecm"}, "says it is an MVM"),
    ], ids=["unknown", "contradiction"])
    def test_a_scope_it_cannot_settle_is_refused_and_nothing_is_written(
        self, engine, client_with_agent, mock_ws, seed_business, seeds, scope, body, expected,
    ):
        root = _agriculture_mvm(version=scope)
        root["model_requirements"].pop("data_model_scopes")
        volume = _volume(mock_ws, root)
        before_files = dict(volume.files)
        before = table_digests(engine)
        r = _execute(client_with_agent, seed_business, **body)
        assert r.status_code == 400, r.text
        assert expected in r.json()["detail"]
        assert table_digests(engine) == before and volume.files == before_files

    def test_an_active_run_is_refused_and_nothing_is_written(
        self, engine, client_with_agent, mock_ws, seed_business, seeds,
    ):
        """A running vibe produces the version number the import would take,
        into the same folder: the import is refused before any write."""
        with Session(engine) as s:
            run = Run(business_id=seed_business, status="running")
            s.add(run)
            s.commit()
            run_id = run.id
        volume = _volume(mock_ws, _agriculture_mvm())
        before_files = dict(volume.files)
        before = table_digests(engine)
        r = _execute(client_with_agent, seed_business)
        assert r.status_code == 409, r.text
        assert r.json()["detail"] == {"error": "run_active", "message": active_run_message(run_id)}
        assert table_digests(engine) == before
        assert volume.files == before_files and volume.uploads == [] and seeds == []

    def test_a_held_business_lock_is_refused_and_nothing_is_written(
        self, engine, client_with_agent, mock_ws, seed_business, seeds, monkeypatch,
    ):
        """SQLite ignores ``FOR UPDATE``; the NOWAIT refusal itself is in
        ``test_install_rows_pg.py``. Here the route's answer to it."""
        def held(session, business_id, **_kw):
            raise BusinessBusy(LOCK_BUSY_MESSAGE)

        monkeypatch.setattr(_runs, "lock_business_for_run", held)
        volume = _volume(mock_ws, _agriculture_mvm())
        before_files = dict(volume.files)
        before = table_digests(engine)
        r = _execute(client_with_agent, seed_business)
        assert r.status_code == 409, r.text
        assert r.json()["detail"] == {"error": "business_busy", "message": LOCK_BUSY_MESSAGE}
        assert table_digests(engine) == before
        assert volume.files == before_files and volume.uploads == [] and seeds == []

    def test_the_users_choice_beats_the_requirements(self, engine, client_with_agent, mock_ws, seed_business, seeds):
        """The upstream MVM's requirements say ECM; without a version suffix,
        the user's MVM wins."""
        _volume(mock_ws, _agriculture_mvm(version="v1"))
        r = _execute(client_with_agent, seed_business, scope="mvm")
        assert r.status_code == 200, r.text
        assert _version(engine, r.json()["version_id"]).scope == "mvm"

    @pytest.mark.parametrize("timed_out,status", [(False, 502), (True, 504)])
    def test_a_failed_copy_leaves_no_version(
        self, engine, client_with_agent, mock_ws, seed_business, seeds, monkeypatch, timed_out, status,
    ):
        from vibe_modeling.backend.services.volume_copy import CopyResult

        volume = _volume(mock_ws, _agriculture_mvm())
        folder = version_dir_in_volume(CATALOG, "Test Corp", 1, "mvm")

        def _partial(ws, files, src, dest, **kw):
            volume.put(f"{dest}/readme.md", "half")
            return CopyResult(dest, 1, len(files), () if timed_out else (files[0],), timed_out)

        monkeypatch.setattr(dialog_import, "copy_volume_folder", _partial)
        r = _execute(client_with_agent, seed_business)
        assert r.status_code == status, r.text
        assert "nothing was imported" in r.json()["detail"]
        with Session(engine) as s:
            assert s.exec(select(ModelVersion).where(ModelVersion.business_id == seed_business)).all() == []
            assert s.exec(select(Domain)).all() == []
        assert volume.under(folder) == {} and seeds == []

    def test_analyze_reports_the_scope_and_prefixes(self, client_with_agent, mock_ws, seed_business):
        _volume(mock_ws, _agriculture_mvm())
        r = client_with_agent.post(
            f"/api/businesses/{seed_business}/import/analyze", json={"volume_path": f"{SOURCE}/model.json"},
        )
        assert r.status_code == 200, r.text
        body = r.json()
        assert (body["inferred_scope"], body["agent_output"]) == ("mvm", False)
        assert (body["file_schema_prefix"], body["import_schema_prefix"]) == ("", "mvm_")


class TestCreateBusinessAndImport:
    def _body(self, path=f"{SOURCE}/model.json", **extra):
        return {"volume_path": path, "business_name_override": "Agri Co", "description_override": "Farms.", **extra}

    def test_the_new_business_gets_the_prefixed_copy(self, engine, client_with_agent, mock_ws, seeds):
        volume = _volume(mock_ws, _agriculture_mvm())
        r = client_with_agent.post("/api/import/create-business-and-execute", json=self._body())
        assert r.status_code == 200, r.text
        folder = version_dir_in_volume(CATALOG, "Agri Co", 1, "mvm")
        copied = volume.json(f"{folder}/model.json")["model"]
        assert all(d["database_name"].startswith("mvm_") for d in copied["domains"])
        mv = _version(engine, r.json()["version_id"])
        assert (mv.files_catalog, mv.import_schema_prefix_added) == (CATALOG, "mvm_")
        assert [kw["location"] for kw in seeds] == [folder]

    def test_an_occupied_folder_creates_no_business(self, engine, client_with_agent, mock_ws, seeds):
        volume = _volume(mock_ws, _agriculture_mvm())
        volume.put(f"{version_dir_in_volume(CATALOG, 'Agri Co', 1, 'mvm')}/model.json", {"left": "over"})
        before = table_digests(engine)
        r = client_with_agent.post("/api/import/create-business-and-execute", json=self._body())
        assert r.status_code == 409, r.text
        assert table_digests(engine) == before

    def test_a_failed_copy_deletes_the_business_it_created(self, engine, client_with_agent, mock_ws, seeds, monkeypatch):
        from vibe_modeling.backend.services.volume_copy import CopyResult

        _volume(mock_ws, _agriculture_mvm())
        monkeypatch.setattr(
            dialog_import, "copy_volume_folder",
            lambda ws, files, src, dest, **kw: CopyResult(dest, 0, len(files), tuple(files), False),
        )
        r = client_with_agent.post("/api/import/create-business-and-execute", json=self._body())
        assert r.status_code == 502, r.text
        with Session(engine) as s:
            assert s.exec(select(Business).where(Business.name == "Agri Co")).all() == []
            assert s.exec(select(ModelVersion)).all() == []


class TestMetamodelSetup:
    """A catalog the agent and the installer never touched has no
    ``_metamodel`` or ``vol_root``: both dialog routes create them after
    every check, before the first write, or refuse with the setup's 400."""

    _CREATE_BODY = {"volume_path": f"{SOURCE}/model.json", "business_name_override": "Agri Co", "description_override": "Farms."}

    def test_the_import_sets_up_a_fresh_catalog(self, engine, client_with_agent, mock_ws, seed_business, seeds):
        stub_no_metamodel(mock_ws)
        volume = _volume(mock_ws, _agriculture_mvm())
        r = _execute(client_with_agent, seed_business)
        assert r.status_code == 200, r.text
        mock_ws.schemas.create.assert_called_once_with(name="_metamodel", catalog_name=CATALOG)
        mock_ws.volumes.create.assert_called_once()
        assert f"{version_dir_in_volume(CATALOG, 'Test Corp', 1, 'mvm')}/model.json" in volume.files

    @pytest.mark.parametrize("route", ["execute", "create"])
    def test_a_failed_setup_is_refused_and_nothing_is_written(
        self, engine, client_with_agent, mock_ws, seed_business, seeds, route,
    ):
        stub_no_metamodel(mock_ws)
        mock_ws.config.client_id = "sp-client-123"
        mock_ws.schemas.create.side_effect = PermissionDenied("denied")
        volume = _volume(mock_ws, _agriculture_mvm())
        before_files = dict(volume.files)
        before = table_digests(engine)
        if route == "execute":
            r = _execute(client_with_agent, seed_business)
        else:
            r = client_with_agent.post("/api/import/create-business-and-execute", json=self._CREATE_BODY)
        assert r.status_code == 400, r.text
        assert "can't create `_metamodel`" in r.json()["detail"]
        assert table_digests(engine) == before
        assert volume.files == before_files and volume.uploads == [] and seeds == []

    def test_a_refused_import_sets_up_nothing(self, engine, client_with_agent, mock_ws, seed_business, seeds):
        stub_no_metamodel(mock_ws)
        volume = _volume(mock_ws, _agriculture_mvm())
        volume.put(f"{version_dir_in_volume(CATALOG, 'Test Corp', 1, 'mvm')}/model.json", {"left": "over"})
        r = _execute(client_with_agent, seed_business)
        assert r.status_code == 409, r.text
        mock_ws.schemas.create.assert_not_called()
        mock_ws.volumes.create.assert_not_called()


class TestRecoveryImportScope:
    def _post(self, client, biz, path, **params):
        return client.post(
            f"/api/businesses/{biz}/versions/import-from-volume", params={"volume_path": path, **params},
        )

    def test_a_file_and_path_that_name_no_scope_fail_the_step(self, engine, client_with_agent, mock_ws, seed_business):
        root = _agriculture_mvm(version=None)
        root["model_requirements"].pop("data_model_scopes")
        _volume(mock_ws, root)
        r = self._post(client_with_agent, seed_business, f"{SOURCE}/model.json")
        assert r.status_code == 502, r.text
        # The path is in the step's error; the error handler redacts it here.
        assert "Import did not complete: Could not tell whether" in r.text
        assert "is an ECM or an MVM model; pass scope." in r.text
        with Session(engine) as s:
            assert s.exec(select(ModelVersion).where(ModelVersion.business_id == seed_business)).all() == []

    def test_the_agents_file_is_imported_as_written_in_the_scope_given(
        self, engine, client_with_agent, mock_ws, seed_business,
    ):
        root = _agriculture_mvm(version=None)
        volume = _volume(mock_ws, root)
        before = dict(volume.files)
        r = self._post(client_with_agent, seed_business, f"{SOURCE}/model.json", scope="mvm")
        assert r.status_code == 200, r.text
        mv = _version(engine, r.json()["version_id"])
        assert mv.scope == "mvm" and mv.import_schema_prefix_added is None
        assert volume.files == before


class TestInstallReadsTheAppsCopy:
    """A3: a copied import (markers not NULL) installs from the app's folder,
    an import from before 0.9.0 (NULL) from its ``import_source_path``."""

    @pytest.mark.parametrize("marker,source_first", [("mvm_", False), ("", False), (None, True)])
    def test_the_context_file_of_an_import(self, marker, source_first):
        from types import SimpleNamespace

        from vibe_modeling.backend.models import RunIn
        from vibe_modeling.backend.services.orchestrator.dag_factories._simple import dag_for_install

        mv = SimpleNamespace(
            id="mv", scope="mvm", version=1, files_catalog=CATALOG, uc_catalog=None,
            import_source_path=f"{SOURCE}/model.json", import_schema_prefix_added=marker,
        )
        req = RunIn(intent="install", catalog=CATALOG, cataloging_style="One Catalog")
        dag = dag_for_install(req, SimpleNamespace(name="Test Corp"), SimpleNamespace(parent_mv=mv))
        candidates = dag.steps[0].params["context_file_candidates"]
        canonical = f"{version_dir_in_volume(CATALOG, 'Test Corp', 1, 'mvm')}/model.json"
        if source_first:
            assert candidates[:2] == [f"{SOURCE}/model.json", canonical]
        else:
            assert candidates[0] == canonical and f"{SOURCE}/model.json" not in candidates


class TestDeleteRemovesTheAppsFolder:
    """A deleted import's folder is the app's own: deleting the version or
    the business removes it, so importing again does not hit the 409."""

    def test_delete_then_import_again(self, engine, client_with_agent, mock_ws, seed_business, seeds):
        volume = _volume(mock_ws, _agriculture_mvm())
        folder = version_dir_in_volume(CATALOG, "Test Corp", 1, "mvm")
        r = _execute(client_with_agent, seed_business)
        assert r.status_code == 200, r.text
        assert volume.under(folder)
        d = client_with_agent.delete(f"/api/businesses/{seed_business}/versions/{r.json()['version_id']}")
        assert d.status_code == 200, d.text
        assert volume.under(folder) == {}
        assert volume.under(SOURCE)
        again = _execute(client_with_agent, seed_business)
        assert again.status_code == 200, again.text
        assert again.json()["version"] == 1

    def test_business_delete_then_create_by_import_again(self, engine, client_with_agent, mock_ws, seeds):
        volume = _volume(mock_ws, _agriculture_mvm())
        body = {"volume_path": f"{SOURCE}/model.json", "business_name_override": "Agri Co", "description_override": "Farms."}
        r = client_with_agent.post("/api/import/create-business-and-execute", json=body)
        assert r.status_code == 200, r.text
        d = client_with_agent.delete(f"/api/businesses/{r.json()['business_id']}?cascade=true")
        assert d.status_code == 200, d.text
        assert volume.under(version_dir_in_volume(CATALOG, "Agri Co", 1, "mvm")) == {}
        again = client_with_agent.post("/api/import/create-business-and-execute", json=body)
        assert again.status_code == 200, again.text

    def test_a_file_kept_in_its_own_folder_survives_the_delete(self, engine, client_with_agent, mock_ws, seed_business, seeds):
        folder = version_dir_in_volume(CATALOG, "Test Corp", 1, "mvm")
        volume = _volume(mock_ws, _agriculture_mvm(), folder=folder)
        before = dict(volume.files)
        r = _execute(client_with_agent, seed_business, path=f"{folder}/model.json")
        assert r.status_code == 200, r.text
        d = client_with_agent.delete(f"/api/businesses/{seed_business}/versions/{r.json()['version_id']}")
        assert d.status_code == 200, d.text
        assert volume.files == before


class TestTheChosenFileIsTheModel:
    def test_a_file_not_named_model_json_becomes_the_folders_model_json(
        self, engine, client_with_agent, mock_ws, seed_business, seeds,
    ):
        """F2: the chosen file is written as the app's ``model.json``
        (prefixed); an unrelated ``model.json`` next to it is not copied."""
        volume = _volume(mock_ws, {"unrelated": True})
        volume.put(f"{SOURCE}/agri_mvm.json", _agriculture_mvm())
        r = _execute(client_with_agent, seed_business, path=f"{SOURCE}/agri_mvm.json")
        assert r.status_code == 200, r.text
        folder = version_dir_in_volume(CATALOG, "Test Corp", 1, "mvm")
        copied = volume.json(f"{folder}/model.json")
        assert all(d["database_name"].startswith("mvm_") for d in copied["model"]["domains"])
        assert f"{folder}/agri_mvm.json" not in volume.files
        assert volume.files[f"{folder}/readme.md"] == b"Agriculture MVM"

    def test_a_file_without_conventions_records_the_prefix_it_gets(
        self, engine, client_with_agent, mock_ws, seed_business, seeds,
    ):
        """F3: the copy carries the schema prefix its names got, so its
        install sends it."""
        root = _agriculture_mvm()
        root["model"].pop("model_conventions")
        root.pop("model_requirements")
        volume = _volume(mock_ws, root)
        r = _execute(client_with_agent, seed_business)
        assert r.status_code == 200, r.text
        copied = volume.json(f"{version_dir_in_volume(CATALOG, 'Test Corp', 1, 'mvm')}/model.json")["model"]
        assert copied["model_conventions"] == {"schema_prefix": "mvm_"}
        assert all(d["database_name"].startswith("mvm_") for d in copied["domains"])


class TestScopeSettled:
    def test_only_the_requirements_leave_the_choice_open(self, client_with_agent, mock_ws, seed_business):
        _volume(mock_ws, _agriculture_mvm(version="v1"))
        r = client_with_agent.post(
            f"/api/businesses/{seed_business}/import/analyze", json={"volume_path": f"{SOURCE}/model.json"},
        )
        assert r.status_code == 200, r.text
        assert (r.json()["inferred_scope"], r.json()["scope_settled"]) == ("ecm", False)

    def test_the_version_settles_it(self, client_with_agent, mock_ws, seed_business):
        _volume(mock_ws, _agriculture_mvm())
        r = client_with_agent.post(
            f"/api/businesses/{seed_business}/import/analyze", json={"volume_path": f"{SOURCE}/model.json"},
        )
        assert (r.json()["inferred_scope"], r.json()["scope_settled"]) == ("mvm", True)


def test_a_failed_copy_also_removes_the_industry_it_added(engine, client_with_agent, mock_ws, seeds, monkeypatch):
    """F1: ``create_industry`` added the industry in the same commit; the
    undo removes it with the business."""
    from vibe_modeling.backend.db_models import Industry
    from vibe_modeling.backend.services.volume_copy import CopyResult

    _volume(mock_ws, _agriculture_mvm())
    monkeypatch.setattr(
        dialog_import, "copy_volume_folder",
        lambda ws, files, src, dest, **kw: CopyResult(dest, 0, len(files), tuple(files), False),
    )
    with Session(engine) as s:
        before = {i.id for i in s.exec(select(Industry)).all()}
    r = client_with_agent.post("/api/import/create-business-and-execute", json={
        "volume_path": f"{SOURCE}/model.json", "business_name_override": "Agri Co", "description_override": "Farms.",
        "industry_alignment_override": "Precision Agronomy", "create_industry": True,
    })
    assert r.status_code == 502, r.text
    with Session(engine) as s:
        assert {i.id for i in s.exec(select(Industry)).all()} == before
        assert s.exec(select(Business).where(Business.name == "Agri Co")).all() == []

"""``POST /api/industries/{business_id}/scope-prefixes`` (``applyIndustryScopePrefixes``).

An industry downloaded before 0.9.0 (the real agriculture ECM and MVM, blank
schema prefix, bare view names, no markers) gets the scope prefixes a 0.9.0
download adds: the dry run reports and writes nothing, the apply rewrites the
app's copy, the registry seed and the Domain rows and records the markers, a
rerun changes nothing, installed versions are skipped naming their catalogs.
"""

from __future__ import annotations

import copy
import json
from pathlib import Path
from unittest.mock import MagicMock

import pytest
from sqlmodel import Session, select

import vibe_modeling.backend.core._roles as _roles_mod
from vibe_modeling.backend.core._paths import version_dir_in_volume
from vibe_modeling.backend.db_models import AgentConfig, Business, Domain, ModelVersion, Run
from vibe_modeling.backend.model_sync import ModelSyncService
from vibe_modeling.backend.services import industry_prefix_fix as fix_mod
from vibe_modeling.backend.services.operations._version_lifecycle import mark_version_deployed

from ._assess_helpers import table_digests
from ._fake_volume import FakeVolume

CATALOG = "home_cat"
FIXTURE = json.loads(
    (Path(__file__).parent.parent / "fixtures" / "industry_agriculture_v1_trimmed.json").read_text()
)


def _url(business_id: str) -> str:
    return f"/api/industries/{business_id}/scope-prefixes"


def _model_path(scope: str) -> str:
    return f"{version_dir_in_volume(CATALOG, 'Agriculture', 1, scope)}/model.json"


@pytest.fixture
def volume(mock_ws) -> FakeVolume:
    return FakeVolume(mock_ws)


@pytest.fixture
def registry(monkeypatch):
    """The ``_metamodel`` writes: the deletes and the seeds the fix issues."""
    calls: dict[str, list] = {"deletes": [], "seeds": []}

    def _delete(self, **kw):
        calls["deletes"].append(kw)
        return True

    monkeypatch.setattr(ModelSyncService, "delete_metamodel_rows", _delete)
    monkeypatch.setattr(
        fix_mod, "seed_metamodel_one",
        lambda ws, **kw: calls["seeds"].append(kw) or {"errors": [], "still_running": []},
    )
    return calls


def _industry(engine, volume: FakeVolume, *, kind: str = "industry", source: str = "github://acme/models/data-models/agriculture") -> str:
    """The agriculture industry as a 0.8.x download left it: both scopes, the
    files in the app's folder, Domain rows with bare names, no markers."""
    with Session(engine) as session:
        session.add(AgentConfig(notebook_path="/nb", job_id=1, deployment_catalog=CATALOG, warehouse_id="wh-1"))
        business = Business(name="Agriculture", kind=kind)
        session.add(business)
        session.flush()
        for scope in ("ecm", "mvm"):
            mv = ModelVersion(
                business_id=business.id, version=1, status="completed", deployment_status="draft",
                scope=scope, files_catalog=CATALOG, import_source_path=f"{source}/v1/{scope}/model.json",
            )
            session.add(mv)
            session.flush()
            ModelSyncService(session).sync_from_model_json(mv.id, copy.deepcopy(FIXTURE[scope]))
            volume.put(_model_path(scope), FIXTURE[scope])
        session.commit()
        return business.id


def _versions(engine, business_id: str) -> dict[str, ModelVersion]:
    with Session(engine) as session:
        rows = session.exec(select(ModelVersion).where(ModelVersion.business_id == business_id)).all()
        for mv in rows:
            session.expunge(mv)
        return {mv.scope: mv for mv in rows}


def _domain_names(engine, version_id: str) -> set[str]:
    with Session(engine) as session:
        return {d.database_name for d in session.exec(select(Domain).where(Domain.version_id == version_id)).all()}


class TestDryRun:
    def test_reports_both_scopes_and_writes_nothing(self, client, engine, volume, registry):
        bid = _industry(engine, volume)
        before, files = table_digests(engine), dict(volume.files)
        r = client.post(_url(bid), json={})
        assert r.status_code == 200, r.text
        body = r.json()
        assert body["applied"] is False and body["business_name"] == "Agriculture"
        rows = {row["scope"]: row for row in body["rows"]}
        assert {s: rows[s]["action"] for s in rows} == {"ecm": "changed", "mvm": "changed"}
        assert "ecm_" in rows["ecm"]["reason"] and "97 metric view(s)" in rows["ecm"]["reason"]
        assert "mvm_" in rows["mvm"]["reason"] and "134 metric view(s)" in rows["mvm"]["reason"]
        assert table_digests(engine) == before
        assert volume.files == files and volume.uploads == []
        assert registry == {"deletes": [], "seeds": []}

    def test_no_body_is_a_dry_run(self, client, engine, volume, registry):
        bid = _industry(engine, volume)
        before = table_digests(engine)
        r = client.post(_url(bid))
        assert r.status_code == 200, r.text
        assert r.json()["applied"] is False
        assert table_digests(engine) == before and volume.uploads == []


class TestApply:
    def test_rewrites_the_copy_registry_and_rows(self, client, engine, volume, registry):
        bid = _industry(engine, volume)
        r = client.post(_url(bid), json={"apply": True})
        assert r.status_code == 200, r.text
        assert [row["action"] for row in r.json()["rows"]] == ["changed", "changed"]
        versions = _versions(engine, bid)
        for scope in ("ecm", "mvm"):
            mv = versions[scope]
            prefix = f"{scope}_"
            assert (mv.import_schema_prefix_added, mv.import_view_prefix_added) == (prefix, prefix)
            names = _domain_names(engine, mv.id)
            assert names and all(n.startswith(prefix) for n in names)
            rewritten = volume.json(_model_path(scope))["model"]
            assert rewritten["version"] == f"v1_{scope}"
            assert rewritten["model_conventions"]["schema_prefix"] == prefix
            assert {d["database_name"] for d in rewritten["domains"]} == names
            assert all(v["view_name"].startswith(prefix) for v in rewritten["metric_views"])
            assert volume.json(_model_path(scope) + ".pre090") == FIXTURE[scope]
        folders = {s: _model_path(s).rsplit("/", 1)[0] for s in ("ecm", "mvm")}
        assert sorted(kw["location"] for kw in registry["seeds"]) == sorted(folders.values())
        assert all(kw["catalog"] == CATALOG for kw in registry["seeds"])
        assert all(d["database_name"].startswith(f"{kw['scope']}_") for kw in registry["seeds"] for d in kw["model_json"]["domains"])
        assert sorted((d["business_name"], d["model_scope"], d["version"]) for d in registry["deletes"]) == [
            ("agriculture", "ecm", "1"), ("agriculture", "mvm", "1"),
        ]

    def test_a_rerun_converges(self, client, engine, volume, registry):
        bid = _industry(engine, volume)
        assert client.post(_url(bid), json={"apply": True}).status_code == 200
        before, files, uploads = table_digests(engine), dict(volume.files), list(volume.uploads)
        seeds = len(registry["seeds"])
        for apply in (False, True):
            r = client.post(_url(bid), json={"apply": apply})
            assert r.status_code == 200, r.text
            assert [row["action"] for row in r.json()["rows"]] == ["unchanged", "unchanged"]
        assert table_digests(engine) == before
        assert volume.files == files and volume.uploads == uploads
        assert len(registry["seeds"]) == seeds

    def test_an_installed_version_is_skipped_naming_its_catalog(self, client, engine, volume, registry):
        bid = _industry(engine, volume)
        with Session(engine) as session:
            mv = session.exec(
                select(ModelVersion).where(ModelVersion.business_id == bid, ModelVersion.scope == "ecm")
            ).one()
            mark_version_deployed(session, mv, "business_1")
            session.commit()
        ecm_file = volume.files[_model_path("ecm")]
        r = client.post(_url(bid), json={"apply": True})
        assert r.status_code == 200, r.text
        rows = {row["scope"]: row for row in r.json()["rows"]}
        assert rows["ecm"]["action"] == "skipped" and "business_1" in rows["ecm"]["reason"]
        assert rows["mvm"]["action"] == "changed"
        assert volume.files[_model_path("ecm")] == ecm_file
        assert _model_path("ecm") + ".pre090" not in volume.files
        ecm = _versions(engine, bid)["ecm"]
        assert ecm.import_schema_prefix_added is None
        assert not any(n.startswith("ecm_") for n in _domain_names(engine, ecm.id))
        assert [kw["scope"] for kw in registry["seeds"]] == ["mvm"]

    def test_a_version_not_downloaded_is_left_as_written(self, client, engine, volume, registry):
        bid = _industry(engine, volume, source="/Volumes/u/s/v")
        before = table_digests(engine)
        r = client.post(_url(bid), json={"apply": True})
        assert r.status_code == 200, r.text
        assert [row["action"] for row in r.json()["rows"]] == ["unchanged", "unchanged"]
        assert table_digests(engine) == before and volume.uploads == []

    def test_a_failed_seed_leaves_the_file_and_rows_and_a_rerun_converges(
        self, client, engine, volume, registry, monkeypatch,
    ):
        bid = _industry(engine, volume)
        good_seed = fix_mod.seed_metamodel_one
        monkeypatch.setattr(
            fix_mod, "seed_metamodel_one",
            lambda ws, **kw: {"errors": ["warehouse unavailable"], "still_running": []},
        )
        r = client.post(_url(bid), json={"apply": True})
        assert r.status_code == 200, r.text
        rows = r.json()["rows"]
        assert [row["action"] for row in rows] == ["failed", "failed"]
        assert "model file and database rows are unchanged" in rows[0]["reason"]
        assert "Run the fix again" in rows[0]["reason"]
        assert volume.json(_model_path("ecm")) == FIXTURE["ecm"]
        versions = _versions(engine, bid)
        assert versions["ecm"].import_schema_prefix_added is None
        assert not any(n.startswith("ecm_") for n in _domain_names(engine, versions["ecm"].id))
        monkeypatch.setattr(fix_mod, "seed_metamodel_one", good_seed)
        _assert_rerun_converges(client, engine, volume, bid)

    def test_a_failed_database_write_after_the_seed_converges_on_a_rerun(
        self, client, engine, volume, registry, monkeypatch,
    ):
        bid = _industry(engine, volume)
        real = fix_mod.apply_import_prefix_to_rows

        def _boom(*a, **k):
            raise RuntimeError("database write failed")

        monkeypatch.setattr(fix_mod, "apply_import_prefix_to_rows", _boom)
        r = client.post(_url(bid), json={"apply": True})
        assert r.status_code == 200, r.text
        rows = r.json()["rows"]
        assert [row["action"] for row in rows] == ["failed", "failed"]
        assert "saving its database rows failed" in rows[0]["reason"]
        assert len(registry["seeds"]) == 2
        assert volume.json(_model_path("ecm")) == FIXTURE["ecm"]
        assert _versions(engine, bid)["ecm"].import_schema_prefix_added is None
        monkeypatch.setattr(fix_mod, "apply_import_prefix_to_rows", real)
        _assert_rerun_converges(client, engine, volume, bid)

    def test_a_failed_upload_of_the_rewritten_file_converges_on_a_rerun(
        self, client, engine, volume, registry, mock_ws,
    ):
        bid = _industry(engine, volume)
        real = mock_ws.files.upload.side_effect

        def _upload(path, contents, overwrite=False):
            if path.endswith("/model.json"):
                raise OSError("upload failed")
            return real(path, contents, overwrite=overwrite)

        mock_ws.files.upload.side_effect = _upload
        r = client.post(_url(bid), json={"apply": True})
        assert r.status_code == 200, r.text
        rows = r.json()["rows"]
        assert [row["action"] for row in rows] == ["failed", "failed"]
        assert "registry and database rows are fixed" in rows[0]["reason"]
        ecm = _versions(engine, bid)["ecm"]
        assert ecm.import_schema_prefix_added == "ecm_"
        assert volume.json(_model_path("ecm")) == FIXTURE["ecm"]
        mock_ws.files.upload.side_effect = real
        _assert_rerun_converges(client, engine, volume, bid)

    def test_no_transaction_is_open_across_the_registry_and_volume_writes(
        self, engine, volume, registry, mock_ws, monkeypatch,
    ):
        """The backup, the registry delete and seed, and the rewritten file's
        upload run with the Postgres transaction closed; only the Domain rows
        and markers are written inside one (kickstart / download pattern)."""
        bid = _industry(engine, volume)
        seen: dict[str, list[bool]] = {"seed": [], "delete": [], "upload": []}
        with Session(engine) as session:
            seed_spy = fix_mod.seed_metamodel_one

            def _seed(ws, **kw):
                seen["seed"].append(session.in_transaction())
                return seed_spy(ws, **kw)

            def _delete(self, **kw):
                seen["delete"].append(session.in_transaction())
                return True

            real_upload = mock_ws.files.upload.side_effect

            def _upload(path, contents, overwrite=False):
                seen["upload"].append(session.in_transaction())
                return real_upload(path, contents, overwrite=overwrite)

            monkeypatch.setattr(fix_mod, "seed_metamodel_one", _seed)
            monkeypatch.setattr(ModelSyncService, "delete_metamodel_rows", _delete)
            mock_ws.files.upload.side_effect = _upload
            business = session.get(Business, bid)
            plans = fix_mod.plan_prefix_fix(session, mock_ws, business)
            fix_mod.apply_prefix_fix(session, mock_ws, bid, plans, "wh-1")
        assert [row.action for row in plans] == ["changed", "changed"]
        assert seen["seed"] == [False, False] and seen["delete"] == [False, False]
        assert seen["upload"] == [False] * 4

    def test_the_backup_is_not_indexed_as_an_artifact(self, client, engine, volume, registry, mock_ws):
        from vibe_modeling.backend.db_models import RunArtifact
        from vibe_modeling.backend.services.artifact_indexer import index_artifacts_at_path

        bid = _industry(engine, volume)
        assert client.post(_url(bid), json={"apply": True}).status_code == 200
        folder = _model_path("ecm").rsplit("/", 1)[0]
        with Session(engine) as session:
            ecm = _versions(engine, bid)["ecm"]
            index_artifacts_at_path(mock_ws, session, run_id=None, model_version_id=ecm.id, volume_root_path=folder)
            session.commit()
            paths = [a.file_path for a in session.exec(select(RunArtifact).where(RunArtifact.model_version_id == ecm.id))]
        assert f"{folder}/model.json" in paths
        assert not any(p.endswith(".pre090") for p in paths)


def _prefixed(scope: str) -> dict:
    """The fixture as the fix (or a 0.9.0 download) rewrites it."""
    from vibe_modeling.backend.services.scope_prefix import apply_import_prefix, stamp_scope

    root = copy.deepcopy(FIXTURE[scope])
    apply_import_prefix(root, scope, f"{scope}_")
    return stamp_scope(root, 1, scope)


class TestFinishAPrefixedFile:
    """The file already carries its prefixes but the markers are unset or the
    Domain rows bare (a fix that stopped after the file landed): the plan says
    ``changed`` and the apply finishes the registry, rows and markers without
    a backup or an upload."""

    def _stopped_after_the_file(self, engine, volume, *, backup: bool = True, markers=None) -> str:
        bid = _industry(engine, volume)
        for scope in ("ecm", "mvm"):
            if backup:
                volume.put(_model_path(scope) + ".pre090", FIXTURE[scope])
            volume.put(_model_path(scope), _prefixed(scope))
        if markers is not None:
            with Session(engine) as session:
                for mv in session.exec(select(ModelVersion).where(ModelVersion.business_id == bid)).all():
                    mv.import_schema_prefix_added, mv.import_view_prefix_added = markers(mv.scope)
                    session.add(mv)
                session.commit()
        return bid

    def test_unset_markers_and_bare_rows_are_finished(self, client, engine, volume, registry):
        bid = self._stopped_after_the_file(engine, volume)
        files = dict(volume.files)
        dry = client.post(_url(bid), json={})
        assert dry.status_code == 200, dry.text
        assert [row["action"] for row in dry.json()["rows"]] == ["changed", "changed"]
        assert "already has its scope prefixes" in dry.json()["rows"][0]["reason"]
        r = client.post(_url(bid), json={"apply": True})
        assert r.status_code == 200, r.text
        assert [row["action"] for row in r.json()["rows"]] == ["changed", "changed"]
        assert volume.files == files and volume.uploads == []
        versions = _versions(engine, bid)
        for scope in ("ecm", "mvm"):
            mv = versions[scope]
            assert (mv.import_schema_prefix_added, mv.import_view_prefix_added) == (f"{scope}_", f"{scope}_")
            names = _domain_names(engine, mv.id)
            assert names == {d["database_name"] for d in _prefixed(scope)["model"]["domains"]}
        assert sorted(kw["scope"] for kw in registry["seeds"]) == ["ecm", "mvm"]
        again = client.post(_url(bid), json={"apply": True})
        assert [row["action"] for row in again.json()["rows"]] == ["unchanged", "unchanged"]

    def test_set_markers_with_bare_rows_finish_the_rows(self, client, engine, volume, registry):
        bid = self._stopped_after_the_file(engine, volume, markers=lambda s: (f"{s}_", f"{s}_"))
        r = client.post(_url(bid), json={"apply": True})
        assert r.status_code == 200, r.text
        assert [row["action"] for row in r.json()["rows"]] == ["changed", "changed"]
        ecm = _versions(engine, bid)["ecm"]
        assert all(n.startswith("ecm_") and not n.startswith("ecm_ecm_") for n in _domain_names(engine, ecm.id))
        assert volume.uploads == []

    def test_without_a_backup_the_markers_record_nothing_added(self, client, engine, volume, registry):
        bid = self._stopped_after_the_file(engine, volume, backup=False)
        r = client.post(_url(bid), json={"apply": True})
        assert r.status_code == 200, r.text
        ecm = _versions(engine, bid)["ecm"]
        assert (ecm.import_schema_prefix_added, ecm.import_view_prefix_added) == ("", "")
        assert all(n.startswith("ecm_") for n in _domain_names(engine, ecm.id))


def _assert_rerun_converges(client, engine, volume, bid: str) -> None:
    """A rerun finishes both versions; the next one is ``unchanged``."""
    r = client.post(_url(bid), json={"apply": True})
    assert r.status_code == 200, r.text
    assert [row["action"] for row in r.json()["rows"]] == ["changed", "changed"]
    versions = _versions(engine, bid)
    for scope in ("ecm", "mvm"):
        prefix = f"{scope}_"
        mv = versions[scope]
        assert (mv.import_schema_prefix_added, mv.import_view_prefix_added) == (prefix, prefix)
        names = _domain_names(engine, mv.id)
        assert names and all(n.startswith(prefix) and not n.startswith(prefix * 2) for n in names)
        assert {d["database_name"] for d in volume.json(_model_path(scope))["model"]["domains"]} == names
        assert volume.json(_model_path(scope) + ".pre090") == FIXTURE[scope]
    again = client.post(_url(bid), json={"apply": True})
    assert again.status_code == 200, again.text
    assert [row["action"] for row in again.json()["rows"]] == ["unchanged", "unchanged"]


class TestRefusals:
    def test_a_business_is_refused_and_nothing_is_written(self, client, engine, volume, registry):
        bid = _industry(engine, volume, kind="business")
        before, files = table_digests(engine), dict(volume.files)
        r = client.post(_url(bid), json={"apply": True})
        assert r.status_code == 400, r.text
        assert "not an industry" in r.json()["detail"]
        assert table_digests(engine) == before and volume.files == files

    def test_unknown_industry_is_404(self, client, engine, volume):
        _industry(engine, volume)
        assert client.post(_url("nope"), json={}).status_code == 404

    def test_an_active_run_refuses_the_apply_and_writes_nothing(self, client, engine, volume, registry):
        bid = _industry(engine, volume)
        with Session(engine) as session:
            session.add(Run(business_id=bid, intent="install", status="running"))
            session.commit()
        before, files = table_digests(engine), dict(volume.files)
        r = client.post(_url(bid), json={"apply": True})
        assert r.status_code == 409, r.text
        assert table_digests(engine) == before and volume.files == files
        assert registry == {"deletes": [], "seeds": []}

    def test_non_admin_is_refused(self, client, engine, volume, monkeypatch):
        monkeypatch.setattr(_roles_mod, "RBAC_ENABLED", True)
        viewer_ws = MagicMock()
        user = MagicMock()
        user.groups = []
        viewer_ws.users.list.return_value = [user]
        client.app.state.workspace_client = viewer_ws
        bid = _industry(engine, volume)
        before = table_digests(engine)
        r = client.post(_url(bid), json={"apply": True}, headers={"X-Forwarded-Email": "modeler@example.com"})
        assert r.status_code == 403, r.text
        assert table_digests(engine) == before and volume.uploads == []

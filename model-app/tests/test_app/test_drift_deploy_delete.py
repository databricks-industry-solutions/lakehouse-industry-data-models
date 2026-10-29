"""Drift tests for installs into a second catalog and for version deletes
(v0.9.0 addendum design 10.2, stories B3 and D2).

The app and the agent each keep part of a version's state: the app its
Lakebase rows and its install rows (``model_version_installs``), the agent
its ``_metamodel`` registry rows and the installed schemas. These tests drive
the app's own install and uninstall observers, the installation-status probe
and the delete route against the recording UC fake, emulate the agent's side
of each install and uninstall on the fake, and check after every step that
the two sides agree (``assert_lakebase_metamodel_consistent``).

* **B3, install to X then Y.** Both installs stay recorded, the probe checks
  both catalogs, uninstalling in X closes only X's row, and the probe's
  bare-name fallback does not count another business's schemas.
* **D2, delete.** A Dry Run draft, an installed version (refused), an
  installed-then-uninstalled version, a version installed in another
  catalog, an imported version: the ``_metamodel`` cleanup reaches every
  catalog that holds the version's rows, and the checker is clean after each.
* **Checker.** One registration per install catalog in a shared
  ``_metamodel`` (agent 5.3.3).

The scenarios follow the designed behavior (additions design section 1,
addendum design 6.1 and 10.2).
"""
from __future__ import annotations

from datetime import datetime, timezone
from types import SimpleNamespace

import pytest
from sqlmodel import Session, select

from vibe_modeling.backend.core._names import agent_business_segment
from vibe_modeling.backend.db_models import (
    AgentConfig, Business, MetamodelCleanup, ModelVersion, ModelVersionInstall, Run, RunOperation,
)
from vibe_modeling.backend.services.operations._protocol import OperationContext, OperationDispatchHandle
from vibe_modeling.backend.services.operations.install import Install, InstallParams, _build_install_widgets
from vibe_modeling.backend.services.operations.uninstall import Uninstall

from ._assess_helpers import changed_tables, table_digests
from ._lifecycle_fixtures import agent_exits_ok
from ._drift.consistency import assert_lakebase_metamodel_consistent, check_lakebase_metamodel_consistency
from ._drift.fake_uc import FakeUC
from ._drift.fixtures import WAREHOUSE_ID, fake_uc, mock_model, seed_synced_version  # noqa: F401

HOME = "drift_home"
"""The metamodel catalog: where the agent writes every version's files and home registry rows."""
OTHER = "drift_other"
"""A second install catalog."""
THIRD = "drift_third"
"""A third catalog: another install catalog, or the source Volume of an import."""
BUSINESS = "Acme Co"
SEGMENT = agent_business_segment(BUSINESS)
SCOPE = "mvm"
PREFIX = "mvm_"
"""The One Catalog schema prefix of an MVM install."""
DOMAIN_SCHEMAS = ("sales", "inventory")
"""``database_name`` of the domains of ``tests/fixtures/mock_model.json``."""


@pytest.fixture(name="mock_ws")
def mock_ws_on_the_fake(fake_uc):
    """The conftest clients talk to the fake's workspace."""
    return fake_uc.ws


@pytest.fixture(autouse=True)
def agent_config(fk_engine):
    """A configured agent whose metamodel catalog is ``HOME``."""
    with Session(fk_engine) as session:
        session.add(AgentConfig(
            notebook_path="/Workspace/test/notebook", job_id=99, deployment_catalog=HOME,
            warehouse_id=WAREHOUSE_ID,
        ))
        session.commit()


# ---------------------------------------------------------------------------
# Both sides of a version
# ---------------------------------------------------------------------------


def seed_version(
    engine, fake_uc: FakeUC, *, version: int = 1, status: str = "completed",
    deployment_status: str = "draft", uc_catalog: str = "", dry_run: bool = False,
) -> str:
    """A version the agent wrote into ``HOME`` (registry rows, ``model.json``)
    and the app synced. ``files_catalog`` is ``HOME``. A ``deployed`` version
    also has its schemas in ``uc_catalog`` and an open install row there.
    Returns its id."""
    with Session(engine) as session:
        mv = seed_synced_version(
            session, fake_uc, catalog=HOME, business_name=BUSINESS, version=version, scope=SCOPE,
            deployment_status=deployment_status, uc_catalog=uc_catalog,
        )
        mv.files_catalog = HOME
        mv.status = status
        mv.dry_run = dry_run
        session.add(mv)
        session.commit()
        if deployment_status == "deployed":
            agent_schemas(fake_uc, uc_catalog)
        return mv.id


def agent_schemas(fake_uc: FakeUC, catalog: str) -> None:
    for name in DOMAIN_SCHEMAS:
        fake_uc.add_schema(catalog, f"{PREFIX}{name}", tables=("t",))


def agent_installs(fake_uc: FakeUC, catalog: str, version: int) -> None:
    """The agent's side of an install into ``catalog``: the app sends no
    ``metamodel_catalog`` widget, so the agent registers the version in
    ``catalog``'s own ``_metamodel`` (the notebook's "blank = same as
    Installation Catalog"), and creates the schemas."""
    if fake_uc.registry_entry(catalog, SEGMENT, version, SCOPE) is None:
        fake_uc.add_agent_version(catalog, BUSINESS, version, SCOPE, mock_model(), write_model_json=False)
    agent_schemas(fake_uc, catalog)


def agent_uninstalls(fake_uc: FakeUC, catalog: str) -> None:
    """The agent's side of an uninstall: it drops the schemas and keeps the
    registry rows."""
    for name in DOMAIN_SCHEMAS:
        fake_uc.ws.schemas.delete(f"{catalog}.{PREFIX}{name}", force=True)


def _job_ws(fake_uc: FakeUC):
    """The fake's workspace with a finished, successful agent job whose
    notebook task exits with a registered install (``agent_exits_ok``)."""
    fake_uc.ws.jobs.get_run.return_value = SimpleNamespace(
        state=SimpleNamespace(
            life_cycle_state=SimpleNamespace(value="TERMINATED"),
            result_state=SimpleNamespace(value="SUCCESS"),
            state_message="",
        ),
        tasks=[SimpleNamespace(run_id=4200)],
    )
    agent_exits_ok(fake_uc.ws)
    return fake_uc.ws


def _run(session: Session, business_id: str, intent: str) -> Run:
    run = Run(business_id=business_id, intent=intent, status="completed", parameters_json="{}")
    session.add(run)
    session.commit()
    return run


def _params(mv: ModelVersion, catalog: str) -> dict:
    return {
        "business_name": SEGMENT, "deployment_catalog": catalog, "scope": SCOPE,
        "cataloging_style": "One Catalog", "schema_prefix": PREFIX, "model_version": mv.version,
        "version_id": mv.id,
    }


def install(engine, fake_uc: FakeUC, version_id: str, catalog: str) -> None:
    """A successful install run of the version into ``catalog``, observed by
    the app's ``Install`` operation after the agent did its part."""
    with Session(engine) as session:
        mv = session.get(ModelVersion, version_id)
        agent_installs(fake_uc, catalog, mv.version)
        run = _run(session, mv.business_id, "install")
        ctx = OperationContext(
            run_id=run.id, operation_id="op-install", business_id=mv.business_id,
            parent_version_id=mv.id, params=_params(mv, catalog),
            inherited_params={"cataloging_style": "One Catalog"},
        )
        handle = OperationDispatchHandle(
            databricks_run_id=42, vibe_session_id=None,
            extra={"deployment_catalog": catalog, "schema_prefix": PREFIX, "scope": SCOPE,
                   "model_version": mv.version, "business_name": SEGMENT},
        )
        obs = Install().observe(handle, ctx, _job_ws(fake_uc), session)
        assert obs.is_terminal and obs.terminal_result.succeeded
        session.commit()


def uninstall(engine, fake_uc: FakeUC, version_id: str, catalog: str) -> None:
    """A successful uninstall run of the version from ``catalog``."""
    agent_uninstalls(fake_uc, catalog)
    with Session(engine) as session:
        mv = session.get(ModelVersion, version_id)
        run = _run(session, mv.business_id, "uninstall")
        ctx = OperationContext(
            run_id=run.id, operation_id="op-uninstall", business_id=mv.business_id,
            parent_version_id=mv.id, params=_params(mv, catalog), inherited_params={},
        )
        handle = OperationDispatchHandle(databricks_run_id=43, vibe_session_id=None)
        obs = Uninstall().observe(handle, ctx, _job_ws(fake_uc), session)
        assert obs.is_terminal and obs.terminal_result.succeeded
        session.commit()


def open_install_catalogs(session: Session, version_id: str) -> list[str]:
    return sorted(r.catalog for r in session.exec(select(ModelVersionInstall).where(
        ModelVersionInstall.version_id == version_id, ModelVersionInstall.uninstalled_at.is_(None),
    )))


def probe(client, version_id: str) -> dict:
    response = client.get(f"/api/model-versions/{version_id}/installation-status")
    assert response.status_code == 200, response.text
    return response.json()


def delete(client, engine, version_id: str):
    with Session(engine) as session:
        business_id = session.get(ModelVersion, version_id).business_id
    return client.delete(f"/api/businesses/{business_id}/versions/{version_id}")


def registry_keys(fake_uc: FakeUC) -> set[tuple[str, str]]:
    """``(catalog, version)`` of every registry key the fake holds."""
    return {(e.key.catalog, e.key.version) for e in fake_uc.registry()}


# ---------------------------------------------------------------------------
# B3: install to X, then to Y
# ---------------------------------------------------------------------------


def _installed_in_home_then_other(engine, fake_uc) -> str:
    version_id = seed_version(engine, fake_uc, deployment_status="deployed", uc_catalog=HOME)
    with Session(engine) as session:
        assert_lakebase_metamodel_consistent(session, fake_uc)
    install(engine, fake_uc, version_id, OTHER)
    return version_id


class TestInstallIntoASecondCatalog:

    def test_the_agent_registers_the_install_in_the_install_catalog(self, fk_engine, fake_uc):
        _installed_in_home_then_other(fk_engine, fake_uc)
        assert registry_keys(fake_uc) == {(HOME, "1"), (OTHER, "1")}
        assert fake_uc.calls_to("delete_metamodel_rows") == []

    def test_the_install_catalog_becomes_uc_catalog_and_the_files_stay_home(self, fk_engine, fake_uc):
        version_id = _installed_in_home_then_other(fk_engine, fake_uc)
        with Session(fk_engine) as session:
            mv = session.get(ModelVersion, version_id)
            assert (mv.deployment_status, mv.uc_catalog, mv.files_catalog) == ("deployed", OTHER, HOME)

    def test_both_installs_stay_recorded(self, fk_engine, fake_uc):
        version_id = _installed_in_home_then_other(fk_engine, fake_uc)
        with Session(fk_engine) as session:
            assert open_install_catalogs(session, version_id) == sorted([HOME, OTHER])

    def test_the_checker_is_clean_after_the_second_install(self, fk_engine, fake_uc):
        _installed_in_home_then_other(fk_engine, fake_uc)
        with Session(fk_engine) as session:
            assert_lakebase_metamodel_consistent(session, fake_uc)

    def test_the_probe_is_in_sync_while_both_catalogs_hold_the_schemas(self, fk_engine, fake_uc, fk_client):
        version_id = _installed_in_home_then_other(fk_engine, fake_uc)
        status = probe(fk_client, version_id)
        assert (status["lakebase_says_installed"], status["in_sync"]) == (True, True)
        assert (status["deployment_catalog"], status["also_installed_in"]) == (OTHER, [HOME])
        assert status["found_schemas"] == sorted(f"{PREFIX}{s}" for s in DOMAIN_SCHEMAS)

    def test_the_probe_reports_the_first_catalog_when_its_schemas_are_dropped(
        self, fk_engine, fake_uc, fk_client,
    ):
        """The schemas in X go (dropped outside the app) while the app still
        records the version installed there: the probe reports drift."""
        version_id = _installed_in_home_then_other(fk_engine, fake_uc)
        agent_uninstalls(fake_uc, HOME)
        status = probe(fk_client, version_id)
        assert (status["deployment_catalog"], status["also_installed_in"]) == (OTHER, [HOME])
        assert status["in_sync"] is False
        assert sorted(status["missing_schemas"]) == sorted(f"{HOME}.{PREFIX}{s}" for s in DOMAIN_SCHEMAS)

    def test_uninstalling_the_first_catalog_closes_only_its_row(self, fk_engine, fake_uc):
        version_id = _installed_in_home_then_other(fk_engine, fake_uc)
        uninstall(fk_engine, fake_uc, version_id, HOME)
        with Session(fk_engine) as session:
            mv = session.get(ModelVersion, version_id)
            assert (mv.deployment_status, mv.uc_catalog) == ("deployed", OTHER)
            assert open_install_catalogs(session, version_id) == [OTHER]
            closed = session.exec(select(ModelVersionInstall).where(
                ModelVersionInstall.version_id == version_id, ModelVersionInstall.catalog == HOME,
            )).one()
            assert closed.uninstalled_at is not None and closed.uninstalled_by_run_id is not None

    def test_the_checker_and_the_probe_agree_after_uninstalling_the_first_catalog(
        self, fk_engine, fake_uc, fk_client,
    ):
        version_id = _installed_in_home_then_other(fk_engine, fake_uc)
        uninstall(fk_engine, fake_uc, version_id, HOME)
        with Session(fk_engine) as session:
            assert_lakebase_metamodel_consistent(session, fake_uc)
        status = probe(fk_client, version_id)
        assert (status["deployment_catalog"], status["lakebase_says_installed"], status["in_sync"]) == (
            OTHER, True, True,
        )
        assert status["also_installed_in"] == []

    def test_installing_a_newer_version_elsewhere_leaves_the_older_one_installed(self, fk_engine, fake_uc):
        """Eviction is per catalog: v2 into ``OTHER`` does not take v1 out of ``HOME``."""
        v1 = seed_version(fk_engine, fake_uc, version=1, status="superseded", deployment_status="deployed",
                          uc_catalog=HOME)
        v2 = seed_version(fk_engine, fake_uc, version=2)
        install(fk_engine, fake_uc, v2, OTHER)
        assert registry_keys(fake_uc) == {(HOME, "1"), (HOME, "2"), (OTHER, "2")}
        with Session(fk_engine) as session:
            older, newer = session.get(ModelVersion, v1), session.get(ModelVersion, v2)
            assert (older.deployment_status, older.uc_catalog) == ("deployed", HOME)
            assert (newer.deployment_status, newer.uc_catalog) == ("deployed", OTHER)
            assert open_install_catalogs(session, v1) == [HOME]
            assert open_install_catalogs(session, v2) == [OTHER]
            assert_lakebase_metamodel_consistent(session, fake_uc)

    def test_uninstalling_the_latest_catalog_points_uc_catalog_back_at_the_first(
        self, fk_engine, fake_uc, fk_client,
    ):
        version_id = _installed_in_home_then_other(fk_engine, fake_uc)
        uninstall(fk_engine, fake_uc, version_id, OTHER)
        with Session(fk_engine) as session:
            mv = session.get(ModelVersion, version_id)
            assert (mv.deployment_status, mv.uc_catalog) == ("deployed", HOME)
            assert open_install_catalogs(session, version_id) == [HOME]
            assert_lakebase_metamodel_consistent(session, fake_uc)
        status = probe(fk_client, version_id)
        assert (status["deployment_catalog"], status["also_installed_in"], status["in_sync"]) == (HOME, [], True)

    def test_reconcile_closes_the_first_catalog_when_its_schemas_are_gone(self, fk_engine, fake_uc, fk_client):
        version_id = _installed_in_home_then_other(fk_engine, fake_uc)
        agent_uninstalls(fake_uc, HOME)
        response = fk_client.post(f"/api/model-versions/{version_id}/reconcile-installation")
        assert response.status_code == 200, response.text
        assert (response.json()["previous_deployment_status"], response.json()["new_deployment_status"]) == (
            "deployed", "deployed",
        )
        with Session(fk_engine) as session:
            assert open_install_catalogs(session, version_id) == [OTHER]
            assert session.get(ModelVersion, version_id).uc_catalog == OTHER
            assert_lakebase_metamodel_consistent(session, fake_uc)
        status = probe(fk_client, version_id)
        assert (status["also_installed_in"], status["in_sync"]) == ([], True)

    def test_reconcile_closes_the_latest_catalog_when_its_schemas_are_gone(self, fk_engine, fake_uc, fk_client):
        version_id = _installed_in_home_then_other(fk_engine, fake_uc)
        agent_uninstalls(fake_uc, OTHER)
        response = fk_client.post(f"/api/model-versions/{version_id}/reconcile-installation")
        assert response.status_code == 200, response.text
        assert response.json()["new_deployment_status"] == "deployed"
        with Session(fk_engine) as session:
            assert open_install_catalogs(session, version_id) == [HOME]
            assert session.get(ModelVersion, version_id).uc_catalog == HOME
            assert_lakebase_metamodel_consistent(session, fake_uc)
        status = probe(fk_client, version_id)
        assert (status["deployment_catalog"], status["also_installed_in"], status["in_sync"]) == (HOME, [], True)

    def test_the_install_sends_no_metamodel_catalog(self):
        """The premise of ``agent_installs``: without a ``metamodel_catalog``
        widget the agent's metamodel is the install catalog, so an install
        into Y registers in Y's own ``_metamodel``."""
        widgets = _build_install_widgets(InstallParams(
            scope=SCOPE, business_name=SEGMENT, deployment_catalog=OTHER, schema_prefix=PREFIX, model_version=1,
        ), "1")
        assert widgets["deployment_catalog"] == OTHER
        assert not {"metamodel_catalog", "metamodel_root_catalog"} & set(widgets)

    def test_the_bare_name_fallback_does_not_count_another_businesss_schemas(
        self, fk_engine, fake_uc, fk_client,
    ):
        """Installed in a shared catalog with the ``mvm_`` prefix, then its
        schemas are dropped; another business there owns schemas with the
        bare names. The version is not in sync."""
        version_id = seed_version(fk_engine, fake_uc, deployment_status="deployed", uc_catalog=HOME)
        with Session(fk_engine) as session:
            mv = session.get(ModelVersion, version_id)
            run = _run(session, mv.business_id, "install")
            session.add(RunOperation(
                run_id=run.id, step_index=0, operation_name="install", params_json="{}",
                status="succeeded", parent_version_id=version_id,
                dispatched_widgets_json='{"schema_prefix": "mvm_", "deployment_catalog": "drift_home"}',
            ))
            session.commit()
        agent_uninstalls(fake_uc, HOME)
        for name in DOMAIN_SCHEMAS:
            fake_uc.add_schema(HOME, name, tables=("other_business_table",))
        status = probe(fk_client, version_id)
        assert status["found_schemas"] == []
        assert status["in_sync"] is False


# ---------------------------------------------------------------------------
# D2: delete
# ---------------------------------------------------------------------------


class TestDelete:

    def test_a_dry_run_draft_is_deleted_with_its_registry_rows(self, fk_engine, fake_uc, fk_client):
        seed_version(fk_engine, fake_uc, version=1, deployment_status="deployed", uc_catalog=HOME)
        draft_id = seed_version(fk_engine, fake_uc, version=2, status="draft", dry_run=True)
        assert registry_keys(fake_uc) == {(HOME, "1"), (HOME, "2")}
        response = delete(fk_client, fk_engine, draft_id)
        assert response.status_code == 200, response.text
        assert registry_keys(fake_uc) == {(HOME, "1")}
        with Session(fk_engine) as session:
            assert session.get(ModelVersion, draft_id) is None
            assert_lakebase_metamodel_consistent(session, fake_uc)

    def test_an_installed_version_is_refused_and_nothing_changes(self, fk_engine, fake_uc, fk_client):
        version_id = seed_version(fk_engine, fake_uc, deployment_status="deployed", uc_catalog=HOME)
        before, registry_before = table_digests(fk_engine), fake_uc.registry()
        response = delete(fk_client, fk_engine, version_id)
        assert response.status_code == 409, response.text
        detail = response.json()["detail"]
        assert (detail["error"], detail["catalogs"]) == ("installed", [HOME])
        assert "Uninstall it first" in detail["message"]
        assert changed_tables(before, table_digests(fk_engine)) == set()
        assert fake_uc.registry() == registry_before
        assert fake_uc.calls_to("delete_metamodel_rows") == []

    def test_a_version_installed_in_another_catalog_is_refused_naming_it(self, fk_engine, fake_uc, fk_client):
        version_id = seed_version(fk_engine, fake_uc)
        install(fk_engine, fake_uc, version_id, OTHER)
        before, registry_before = table_digests(fk_engine), fake_uc.registry()
        response = delete(fk_client, fk_engine, version_id)
        assert response.status_code == 409, response.text
        assert response.json()["detail"]["catalogs"] == [OTHER]
        assert changed_tables(before, table_digests(fk_engine)) == set()
        assert fake_uc.registry() == registry_before

    def test_an_installed_then_uninstalled_version_is_cleaned_in_every_catalog(
        self, fk_engine, fake_uc, fk_client,
    ):
        """Written in ``HOME``, installed into ``OTHER``, uninstalled there:
        the agent's rows are in both ``_metamodel`` and both go."""
        version_id = seed_version(fk_engine, fake_uc)
        install(fk_engine, fake_uc, version_id, OTHER)
        uninstall(fk_engine, fake_uc, version_id, OTHER)
        assert registry_keys(fake_uc) == {(HOME, "1"), (OTHER, "1")}
        with Session(fk_engine) as session:
            (row,) = session.exec(select(ModelVersionInstall).where(
                ModelVersionInstall.version_id == version_id, ModelVersionInstall.catalog == OTHER,
            )).all()
            assert row.uninstalled_at is not None and row.installed_by_run_id is not None
            # The rows the agent kept in OTHER belong to the version through its closed install row.
            assert_lakebase_metamodel_consistent(session, fake_uc)
        response = delete(fk_client, fk_engine, version_id)
        assert response.status_code == 200, response.text
        assert registry_keys(fake_uc) == set()
        assert sorted(c.args["catalog"] for c in fake_uc.calls_to("delete_metamodel_rows")) == [HOME, OTHER]
        with Session(fk_engine) as session:
            assert_lakebase_metamodel_consistent(session, fake_uc)

    def test_a_version_installed_in_three_catalogs_is_cleaned_in_all_of_them(
        self, fk_engine, fake_uc, fk_client,
    ):
        """After two uninstalls ``uc_catalog`` names only the last one; the
        first install catalog is reached through its closed install row."""
        version_id = seed_version(fk_engine, fake_uc)
        install(fk_engine, fake_uc, version_id, OTHER)
        install(fk_engine, fake_uc, version_id, THIRD)
        uninstall(fk_engine, fake_uc, version_id, OTHER)
        uninstall(fk_engine, fake_uc, version_id, THIRD)
        with Session(fk_engine) as session:
            mv = session.get(ModelVersion, version_id)
            assert (mv.deployment_status, mv.uc_catalog) == ("uninstalled", THIRD)
            assert_lakebase_metamodel_consistent(session, fake_uc)
        assert registry_keys(fake_uc) == {(HOME, "1"), (OTHER, "1"), (THIRD, "1")}
        response = delete(fk_client, fk_engine, version_id)
        assert response.status_code == 200, response.text
        assert response.json()["metamodel_cleanup"] == {"done": 3, "pending": 0, "failed": 0}
        assert registry_keys(fake_uc) == set()
        assert sorted(c.args["catalog"] for c in fake_uc.calls_to("delete_metamodel_rows")) == [HOME, OTHER, THIRD]

    def test_the_cleanup_is_recorded_per_catalog(self, fk_engine, fake_uc, fk_client):
        version_id = seed_version(fk_engine, fake_uc)
        install(fk_engine, fake_uc, version_id, OTHER)
        uninstall(fk_engine, fake_uc, version_id, OTHER)
        response = delete(fk_client, fk_engine, version_id)
        assert response.status_code == 200, response.text
        assert response.json()["metamodel_cleanup"] == {"done": 2, "pending": 0, "failed": 0}
        with Session(fk_engine) as session:
            rows = session.exec(select(MetamodelCleanup)).all()
            assert sorted((r.catalog, r.status, r.business_segment, r.version) for r in rows) == [
                (HOME, "done", SEGMENT, 1), (OTHER, "done", SEGMENT, 1),
            ]

    def test_a_failed_cleanup_stays_visible_and_the_checker_accounts_for_it(
        self, fk_engine, fake_uc, fk_client, monkeypatch,
    ):
        version_id = seed_version(fk_engine, fake_uc)
        install(fk_engine, fake_uc, version_id, OTHER)
        uninstall(fk_engine, fake_uc, version_id, OTHER)
        real = fake_uc._delete_metamodel_rows

        def fail_in_other(svc, catalog, *args, **kwargs):
            if catalog == OTHER:
                raise RuntimeError("warehouse unavailable")
            return real(svc, catalog, *args, **kwargs)

        monkeypatch.setattr(fake_uc, "_delete_metamodel_rows", fail_in_other)
        response = delete(fk_client, fk_engine, version_id)
        assert response.status_code == 200, response.text
        assert response.json()["metamodel_cleanup"] == {"done": 1, "pending": 0, "failed": 1}
        assert registry_keys(fake_uc) == {(OTHER, "1")}
        with Session(fk_engine) as session:
            failed = session.exec(select(MetamodelCleanup).where(MetamodelCleanup.status == "failed")).one()
            assert (failed.catalog, failed.last_error is not None) == (OTHER, True)
            assert_lakebase_metamodel_consistent(session, fake_uc)

    def test_an_imported_version_is_cleaned_where_the_import_seeded_it(self, fk_engine, fake_uc, fk_client):
        """An import from a Volume in ``THIRD`` seeds its registry rows into
        the metamodel catalog ``HOME`` (``resolve_import_registry_catalog``),
        not the source's catalog, and is never installed. The delete cleans
        ``HOME`` and never touches ``THIRD``, which the app may not own."""
        source = fake_uc.put_file(f"/Volumes/{THIRD}/landing/models/acme/model.json", mock_model())
        version_id = seed_version(fk_engine, fake_uc)
        with Session(fk_engine) as session:
            mv = session.get(ModelVersion, version_id)
            mv.import_source_path = source
            mv.files_catalog = THIRD
            mv.imported_at = datetime.now(timezone.utc)
            session.add(mv)
            session.commit()
            assert_lakebase_metamodel_consistent(session, fake_uc)
        assert registry_keys(fake_uc) == {(HOME, "1")}
        response = delete(fk_client, fk_engine, version_id)
        assert response.status_code == 200, response.text
        assert registry_keys(fake_uc) == set()
        assert [c.args["catalog"] for c in fake_uc.calls_to("delete_metamodel_rows")] == [HOME]
        assert not [c for c in fake_uc.calls if THIRD in str(c.args) and c.seam != "files.download"]
        with Session(fk_engine) as session:
            assert_lakebase_metamodel_consistent(session, fake_uc)

    def test_deleting_the_head_restores_the_prior_version_and_the_checker_stays_clean(
        self, fk_engine, fake_uc, fk_client,
    ):
        prior_id = seed_version(fk_engine, fake_uc, version=1, status="superseded", deployment_status="uninstalled")
        head_id = seed_version(fk_engine, fake_uc, version=2, deployment_status="uninstalled")
        response = delete(fk_client, fk_engine, head_id)
        assert response.status_code == 200, response.text
        assert registry_keys(fake_uc) == {(HOME, "1")}
        with Session(fk_engine) as session:
            assert session.get(ModelVersion, prior_id).status == "completed"
            assert_lakebase_metamodel_consistent(session, fake_uc)

    def test_deleting_the_head_cleans_its_home_rows(self, fk_engine, fake_uc, fk_client):
        """A head installed and uninstalled in ``HOME``: its rows are where
        ``uc_catalog`` points, so every unit cleans them."""
        version_id = seed_version(fk_engine, fake_uc, deployment_status="uninstalled", uc_catalog=HOME)
        response = delete(fk_client, fk_engine, version_id)
        assert response.status_code == 200, response.text
        assert registry_keys(fake_uc) == set()
        with Session(fk_engine) as session:
            assert session.exec(select(Business)).one().name == BUSINESS
            assert_lakebase_metamodel_consistent(session, fake_uc)


# ---------------------------------------------------------------------------
# The checker on per-install-catalog registrations (agent 5.3.3)
# ---------------------------------------------------------------------------


def _register_again_for(fake_uc: FakeUC, install_catalog: str, *, domains: bool = True) -> None:
    """A second registration of v1 in ``HOME``'s ``_metamodel`` for another
    install catalog, as 5.3.3 keeps it: a business row and domain rows whose
    ``catalog`` column names ``install_catalog``; no new product or attribute rows."""
    (home,) = fake_uc.rows(HOME, "business")
    fake_uc.add_rows(HOME, "business", [{**home, "catalog": install_catalog}])
    if domains:
        fake_uc.add_rows(HOME, "domain", [{**r, "catalog": install_catalog} for r in fake_uc.rows(HOME, "domain")])


class TestCheckerOnPerCatalogRegistrations:

    def test_one_registration_per_install_catalog_is_consistent(self, fk_engine, fake_uc):
        seed_version(fk_engine, fake_uc, deployment_status="deployed", uc_catalog=HOME)
        _register_again_for(fake_uc, OTHER)
        with Session(fk_engine) as session:
            assert_lakebase_metamodel_consistent(session, fake_uc)

    def test_a_registration_without_its_domain_rows_is_reported(self, fk_engine, fake_uc):
        seed_version(fk_engine, fake_uc, deployment_status="deployed", uc_catalog=HOME)
        _register_again_for(fake_uc, OTHER, domains=False)
        with Session(fk_engine) as session:
            report = check_lakebase_metamodel_consistency(session, fake_uc)
        assert report.items() == {1}
        assert f"install catalog {OTHER!r}" in report.problems[0].message

    def test_two_registrations_for_one_install_catalog_are_reported(self, fk_engine, fake_uc):
        seed_version(fk_engine, fake_uc, deployment_status="deployed", uc_catalog=HOME)
        _register_again_for(fake_uc, OTHER)
        fake_uc.add_rows(HOME, "business", [{**fake_uc.rows(HOME, "business")[0]}])
        with Session(fk_engine) as session:
            report = check_lakebase_metamodel_consistency(session, fake_uc)
        assert "2 registry business rows" in str(report.problems[0])

    def test_rows_in_a_catalog_the_version_was_never_installed_in_are_orphans(self, fk_engine, fake_uc):
        seed_version(fk_engine, fake_uc, deployment_status="deployed", uc_catalog=HOME)
        fake_uc.add_agent_version(OTHER, BUSINESS, 1, SCOPE, mock_model(), write_model_json=False)
        with Session(fk_engine) as session:
            report = check_lakebase_metamodel_consistency(session, fake_uc)
        assert report.items() == {2}

    def test_a_domain_row_naming_no_registered_install_catalog_is_reported(self, fk_engine, fake_uc):
        """The agent's blank-catalog stamp failed, or an undone install left
        domain rows without their business row."""
        seed_version(fk_engine, fake_uc, deployment_status="deployed", uc_catalog=HOME)
        _register_again_for(fake_uc, OTHER)
        (stray, *_) = fake_uc.rows(HOME, "domain")
        fake_uc.add_rows(HOME, "domain", [{**stray, "catalog": None}, {**stray, "catalog": THIRD}])
        with Session(fk_engine) as session:
            report = check_lakebase_metamodel_consistency(session, fake_uc)
        assert report.items() == {1}
        assert "2 registry domain rows" in report.problems[0].message


class TestCheckerOnInstallCatalogRegistrations:

    def test_a_partial_registration_in_an_install_catalog_is_reported(self, fk_engine, fake_uc):
        version_id = seed_version(fk_engine, fake_uc)
        install(fk_engine, fake_uc, version_id, OTHER)
        fake_uc.edit_rows(OTHER, "domain", lambda rows: rows[1:])
        with Session(fk_engine) as session:
            report = check_lakebase_metamodel_consistency(session, fake_uc)
        assert report.items() == {1}
        assert f"registry in {OTHER!r}" in report.problems[0].message

    def test_a_duplicated_registration_in_an_install_catalog_is_reported(self, fk_engine, fake_uc):
        version_id = seed_version(fk_engine, fake_uc)
        install(fk_engine, fake_uc, version_id, OTHER)
        fake_uc.add_rows(OTHER, "business", fake_uc.rows(OTHER, "business"))
        with Session(fk_engine) as session:
            report = check_lakebase_metamodel_consistency(session, fake_uc)
        assert report.items() == {1}
        assert f"2 registry business rows in {OTHER!r}" in report.problems[0].message

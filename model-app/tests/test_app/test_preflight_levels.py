"""The run pre-flight levels (design addendum §4.2, X-PRE-b).

``run_preflight`` is the one entry point of ``POST /runs/validate`` and
``POST /runs``: level 1 prerequisites, level 2 intent, level 3 preparation.

- A state matrix: for every level outcome, create refuses with validate's
  first blocker, or succeeds with validate's warnings.
- Every refusal leaves the recording UC fake (``_drift/fake_uc.py``) and the
  app database unchanged: no schema, volume, file or job.
- The key orderings: a missing prerequisite before the active run, the
  active run first in level 2, level 3 only after every check and the
  confirmation.
- The unfinished ``_metamodel`` cleanup blocker (R1), across three catalogs.
- The capability rule (§4.1), the 60 s notebook-readable cache, the warehouse
  and catalog existence checks.
"""
from __future__ import annotations

from datetime import datetime, timezone
from unittest.mock import MagicMock

import pytest
from databricks.sdk.errors import NotFound, PermissionDenied
from fastapi.testclient import TestClient
from sqlmodel import Session, select

from _test_app import make_test_app
from vibe_modeling.backend.core import _uc_privileges
from vibe_modeling.backend.core._config import AppConfig  # noqa: F401 - the config fixture's type
from vibe_modeling.backend.core._defaults import _ConfigDependency, _WorkspaceClientDependency
from vibe_modeling.backend.core._names import agent_business_segment
from vibe_modeling.backend.core._tracker import _TrackerDependency
from vibe_modeling.backend.core.lakebase import _LakebaseDependency
from vibe_modeling.backend.db_models import (
    AgentConfig,
    Business,
    MetamodelCleanup,
    ModelVersion,
    ModelVersionInstall,
    Run,
)
from vibe_modeling.backend.models import Intent, RunIn
from vibe_modeling.backend.services.orchestrator import Orchestrator
from vibe_modeling.backend.services.orchestrator.preflight import run_preflight

from ._assess_helpers import changed_tables, table_digests
from ._drift.fake_uc import FakeUC

HOME, OTHER, THIRD = "home_cat", "other_cat", "third_cat"
BUSINESS = "Levels Co"
NOTEBOOK = "/Workspace/agent/levels.ipynb"

# The fake's write seams: a refused request calls none of them.
WRITE_SEAMS = frozenset({
    "files.upload", "files.create_directory", "files.delete", "files.delete_directory",
    "schemas.create", "schemas.delete", "volumes.create",
})


# --------------------------------------------------------------------------- #
# Fixtures
# --------------------------------------------------------------------------- #


@pytest.fixture
def fake():
    """The UC side: three catalogs; ``home_cat`` and ``third_cat`` have a
    ``_metamodel`` with ``vol_root`` (as the agent leaves it), ``other_cat``
    none. Its ``statement_execution`` refuses and records every statement: a
    started run's dispatch reads the warehouse, a refused request must not."""
    uc = FakeUC()
    uc.add_metamodel(HOME)
    uc.add_catalog(OTHER)
    uc.add_metamodel(THIRD)
    uc.ws._rest.jobs.run_now.return_value = MagicMock(run_id=4242)
    uc.ws._rest.config.client_id = "app-sp-id"
    return uc


@pytest.fixture
def biz_id(engine) -> str:
    with Session(engine) as s:
        s.add(AgentConfig(
            notebook_path=NOTEBOOK, job_id=7, job_name="levels_job",
            deployment_catalog=HOME, warehouse_id="wh-1",
            installed_release_version="v0.9.0", installed_agent_version="5.3.3",
            installed_checked_path=NOTEBOOK, installed_checked_at=datetime.now(timezone.utc),
        ))
        b = Business(name=BUSINESS, description="A utility", business_vibes="Model the meters.")
        s.add(b)
        s.commit()
        return b.id


@pytest.fixture
def api(engine, fake, config):
    """A TestClient whose workspace client is the recording fake."""
    app = make_test_app()

    def session():
        with Session(engine) as s:
            yield s

    tracker = MagicMock()
    tracker.orchestrator = Orchestrator(fake.ws, lambda: Session(bind=engine))
    app.dependency_overrides[_LakebaseDependency.__call__] = session
    app.dependency_overrides[_ConfigDependency.__call__] = lambda: config
    app.dependency_overrides[_WorkspaceClientDependency.__call__] = lambda: fake.ws
    app.dependency_overrides[_TrackerDependency.__call__] = lambda: tracker
    return TestClient(app)


def _version(engine, biz_id, *, version=1, scope="ecm", installed=(HOME,), files=HOME) -> str:
    with Session(engine) as s:
        mv = ModelVersion(
            business_id=biz_id, version=version, scope=scope, status="completed",
            deployment_status="deployed" if installed else "draft",
            uc_catalog=installed[0] if installed else "", files_catalog=files,
        )
        s.add(mv)
        s.flush()
        for catalog in installed:
            s.add(ModelVersionInstall(version_id=mv.id, catalog=catalog))
        s.commit()
        return mv.id


def _edit(engine, model, **fields) -> None:
    with Session(engine) as s:
        row = s.exec(select(model)).first()
        for k, v in fields.items():
            setattr(row, k, v)
        s.add(row)
        s.commit()


def _nbm(catalog=HOME) -> dict:
    return {"intent": "new-base-model", "catalog": catalog, "cataloging_style": "One Catalog"}


def _install(vid, catalog=OTHER) -> dict:
    return {"intent": "install", "version_id": vid, "catalog": catalog, "cataloging_style": "One Catalog"}


def _refuse_capability(monkeypatch, *, create_schema=False, use_metamodel=True):
    cap = _uc_privileges.CatalogCapability(
        create_schema=create_schema, use_metamodel=use_metamodel,
        create_schema_fix="" if create_schema else "GRANT CREATE SCHEMA, USE CATALOG ON CATALOG `x` TO `app-sp-id`;",
        use_metamodel_fix="" if use_metamodel else "GRANT USE SCHEMA ON SCHEMA `x`.`_metamodel` TO `app-sp-id`;",
    )
    monkeypatch.setattr(_uc_privileges, "app_catalog_capabilities", lambda names: [(n, cap) for n in names])


# --------------------------------------------------------------------------- #
# The state matrix: one state per level outcome
# --------------------------------------------------------------------------- #


def _s_config_missing(engine, biz_id, fake, mp):
    _edit(engine, AgentConfig, warehouse_id="")
    return _nbm(), 422


def _s_job_missing(engine, biz_id, fake, mp):
    _edit(engine, AgentConfig, job_id=None)
    return _nbm(), 400


def _s_notebook_unreadable(engine, biz_id, fake, mp):
    fake.ws._rest.workspace.get_status.side_effect = PermissionDenied("no access")
    return _nbm(), 400


def _s_warehouse_gone(engine, biz_id, fake, mp):
    fake.ws._rest.warehouses.get.side_effect = NotFound("no warehouse")
    return _nbm(), 400


def _s_catalog_missing(engine, biz_id, fake, mp):
    return _nbm("no_such_cat"), 400


def _s_capability_refused(engine, biz_id, fake, mp):
    _refuse_capability(mp)
    return _nbm(), 400


def _s_active_run(engine, biz_id, fake, mp):
    with Session(engine) as s:
        s.add(Run(business_id=biz_id, intent="install", status="running"))
        s.commit()
    return _nbm(), 409


def _s_unfinished_cleanup(engine, biz_id, fake, mp):
    with Session(engine) as s:
        s.add(MetamodelCleanup(
            business_segment=agent_business_segment(BUSINESS), version=1, scope="ecm",
            catalog=HOME, reason="version_delete", status="failed", attempts=3,
        ))
        s.commit()
    return _nbm(), 400


def _s_nbm_has_versions(engine, biz_id, fake, mp):
    _version(engine, biz_id, installed=())
    return _nbm(), 400


def _s_no_description(engine, biz_id, fake, mp):
    _edit(engine, Business, description="")
    return _nbm(), 400


def _s_install_no_metamodel(engine, biz_id, fake, mp):
    return _install(_version(engine, biz_id, installed=())), 400


def _other_business_version(engine) -> str:
    with Session(engine) as s:
        other = Business(name="Other Co", description="Elsewhere", business_vibes="x")
        s.add(other)
        s.flush()
        mv = ModelVersion(business_id=other.id, version=1, scope="ecm", status="completed")
        s.add(mv)
        s.commit()
        return mv.id


def _s_unknown_version_nbm(engine, biz_id, fake, mp):
    return {**_nbm(), "version_id": "no-such-version"}, 404


def _s_unknown_version_install(engine, biz_id, fake, mp):
    return _install("no-such-version", HOME), 404


def _s_version_of_another_business(engine, biz_id, fake, mp):
    return _install(_other_business_version(engine), HOME), 404


def _s_unknown_parent_version(engine, biz_id, fake, mp):
    return {"intent": "vibe-new-ecm-mvm", "parent_version_id": "no-such-version", "catalog": HOME,
            "cataloging_style": "One Catalog"}, 404


BLOCKED = [
    pytest.param(_s_unknown_version_nbm, "version_id", id="L0-unknown-version-nbm"),
    pytest.param(_s_unknown_version_install, "version_id", id="L0-unknown-version-install"),
    pytest.param(_s_version_of_another_business, "version_id", id="L0-version-of-another-business"),
    pytest.param(_s_unknown_parent_version, "parent_version_id", id="L0-unknown-parent-version"),
    pytest.param(_s_config_missing, "(agent_config.warehouse_id)", id="L1-config-missing"),
    pytest.param(_s_job_missing, "(agent_config.job_id)", id="L1-job-missing"),
    pytest.param(_s_notebook_unreadable, "(agent_config.notebook_path)", id="L1-notebook-unreadable"),
    pytest.param(_s_warehouse_gone, "(agent_config.warehouse_id)", id="L1-warehouse-gone"),
    pytest.param(_s_catalog_missing, "catalog", id="L1-catalog-missing"),
    pytest.param(_s_capability_refused, "catalog", id="L1-capability-refused"),
    pytest.param(_s_active_run, "business_id", id="L2-active-run"),
    pytest.param(_s_unfinished_cleanup, "metamodel_cleanup", id="L2-unfinished-cleanup"),
    pytest.param(_s_nbm_has_versions, "intent", id="L2-nbm-has-versions"),
    pytest.param(_s_no_description, "business_description", id="L2-no-description"),
    pytest.param(_s_install_no_metamodel, "catalog", id="L2-install-no-metamodel"),
]


def _detail_message(resp) -> str:
    detail = resp.json()["detail"]
    return detail["message"] if isinstance(detail, dict) else detail


@pytest.mark.parametrize("state,field_path", BLOCKED)
def test_create_refuses_with_validates_first_blocker_and_writes_nothing(
    api, engine, biz_id, fake, monkeypatch, state, field_path,
):
    body, status = state(engine, biz_id, fake, monkeypatch)
    before = table_digests(engine)

    v = api.post(f"/api/businesses/{biz_id}/runs/validate", json=body)
    assert v.status_code == 200, v.text
    first = v.json()["blockers"][0]
    assert first["field_path"] == field_path, v.json()

    c = api.post(f"/api/businesses/{biz_id}/runs", json=body)
    assert c.status_code == status, c.text
    if status == 422:
        detail = c.json()["detail"]
        assert detail["error"] == "config_missing"
        assert [m["key"] for m in detail["missing"]] == ["warehouse"]
    else:
        assert _detail_message(c) == first["message"]

    assert changed_tables(before, table_digests(engine)) == set()
    assert not [call for call in fake.calls if call.seam in WRITE_SEAMS]
    assert fake.unrecorded_sql == []
    fake.ws._rest.jobs.run_now.assert_not_called()


def _created_run(engine, run_id) -> Run:
    with Session(engine) as s:
        return s.get(Run, run_id)


def test_open_state_creates_with_validates_warnings(api, engine, biz_id, fake):
    """No blocker, no prepare: create starts the run and returns validate's
    warnings, except the run-target override notice the form already showed."""
    body = _nbm(THIRD)
    v = api.post(f"/api/businesses/{biz_id}/runs/validate", json=body)
    assert v.status_code == 200, v.text
    assert v.json()["blockers"] == []
    warnings = [w for w in v.json()["warnings"] if w["severity"] == "warning"]
    assert [w["field_path"] for w in warnings] == ["catalog"]  # the run-target override notice
    assert not [w for w in v.json()["warnings"] if w["severity"] == "prepare"]

    c = api.post(f"/api/businesses/{biz_id}/runs", json=body)
    assert c.status_code == 200, c.text
    assert c.json()["warnings"] == []
    assert _created_run(engine, c.json()["id"]) is not None
    assert not [call for call in fake.calls if call.seam in {"schemas.create", "volumes.create"}]


def test_prepare_state_reports_then_sets_up_before_the_run_row(api, engine, biz_id, fake):
    """Level 3: validate lists the setup as ``prepare`` and creates nothing;
    create sets ``_metamodel`` and ``vol_root`` up, then writes the Run row."""
    body = _nbm(OTHER)
    v = api.post(f"/api/businesses/{biz_id}/runs/validate", json=body)
    assert v.status_code == 200, v.text
    assert v.json()["blockers"] == []
    assert [w["message"] for w in v.json()["warnings"] if w["severity"] == "prepare"] == [
        f"`_metamodel` will be set up in '{OTHER}' when you start the run."
    ]
    assert not [call for call in fake.calls if call.seam in WRITE_SEAMS]

    c = api.post(f"/api/businesses/{biz_id}/runs", json=body)
    assert c.status_code == 200, c.text
    writes = [call.seam for call in fake.calls if call.seam in WRITE_SEAMS]
    assert writes[:2] == ["schemas.create", "volumes.create"]
    assert fake.ws.volumes.read(f"{OTHER}._metamodel.vol_root").name == "vol_root"
    assert all(w["severity"] == "warning" for w in c.json()["warnings"])


def test_long_instructions_are_a_prepare_item(api, engine, biz_id, fake):
    from vibe_modeling.backend.job_launcher import VIBE_INSTRUCTIONS_INLINE_LIMIT

    _edit(engine, Business, business_vibes="m" * (VIBE_INSTRUCTIONS_INLINE_LIMIT + 1))
    v = api.post(f"/api/businesses/{biz_id}/runs/validate", json=_nbm())
    assert v.status_code == 200, v.text
    prepare = [w for w in v.json()["warnings"] if w["severity"] == "prepare"]
    assert [w["field_path"] for w in prepare] == ["vibe_instructions"]
    assert f"'{HOME}._metamodel.vol_root'" in prepare[0]["message"]


# --------------------------------------------------------------------------- #
# Orderings
# --------------------------------------------------------------------------- #


def test_missing_prerequisite_is_reported_before_the_active_run(api, engine, biz_id, fake, monkeypatch):
    """Status change: a missing prerequisite now answers before the active-run 409."""
    _s_active_run(engine, biz_id, fake, monkeypatch)
    fake.ws._rest.workspace.get_status.side_effect = PermissionDenied("no access")

    v = api.post(f"/api/businesses/{biz_id}/runs/validate", json=_nbm())
    assert [b["field_path"] for b in v.json()["blockers"]][:2] == [
        "(agent_config.notebook_path)", "business_id",
    ]
    c = api.post(f"/api/businesses/{biz_id}/runs", json=_nbm())
    assert c.status_code == 400, c.text
    assert "cannot access the agent notebook" in c.json()["detail"]


def test_active_run_comes_first_in_level_two(api, engine, biz_id, fake, monkeypatch):
    _s_active_run(engine, biz_id, fake, monkeypatch)
    _s_nbm_has_versions(engine, biz_id, fake, monkeypatch)
    _s_unfinished_cleanup(engine, biz_id, fake, monkeypatch)
    c = api.post(f"/api/businesses/{biz_id}/runs", json=_nbm())
    assert c.status_code == 409, c.text
    v = api.post(f"/api/businesses/{biz_id}/runs/validate", json=_nbm())
    assert [b["field_path"] for b in v.json()["blockers"]][:3] == [
        "business_id", "metamodel_cleanup", "intent",
    ]


def test_create_stops_at_its_first_blocker(api, engine, biz_id, fake, monkeypatch):
    """Create reads nothing after its first blocker: with the warehouse gone,
    the catalog and ``_metamodel`` probes never run."""
    fake.ws._rest.warehouses.get.side_effect = NotFound("no warehouse")
    c = api.post(f"/api/businesses/{biz_id}/runs", json=_nbm(OTHER))
    assert c.status_code == 400, c.text
    assert not [call for call in fake.calls if call.seam in {"catalogs.get", "schemas.get", "schemas.list"}]


def test_unconfirmed_install_sets_nothing_up(api, engine, biz_id, fake):
    """Level 3 follows the confirmation: an install that still needs one
    answers 422 and creates no ``vol_root``, even when one is missing."""
    fake.add_schema(OTHER, "_metamodel")  # vol_root absent
    _version(engine, biz_id, version=2, installed=(OTHER,))  # occupies other_cat
    older = _version(engine, biz_id, version=1, installed=())
    body = _install(older, OTHER)

    v = api.post(f"/api/businesses/{biz_id}/runs/validate", json=body)
    assert v.status_code == 200, v.text
    kinds = {w["severity"] for w in v.json()["warnings"]}
    assert {"confirm", "prepare"} <= kinds, v.json()

    c = api.post(f"/api/businesses/{biz_id}/runs", json=body)
    assert c.status_code == 422, c.text
    assert c.json()["detail"]["error"] == "needs_confirmation"
    assert not [call for call in fake.calls if call.seam in WRITE_SEAMS]


# --------------------------------------------------------------------------- #
# Unfinished _metamodel cleanup (R1), three catalogs
# --------------------------------------------------------------------------- #


def _cleanup(engine, *, catalog, scope="ecm", status="pending", version=1):
    with Session(engine) as s:
        s.add(MetamodelCleanup(
            business_segment=agent_business_segment(BUSINESS), version=version, scope=scope,
            catalog=catalog, reason="version_delete", status=status,
        ))
        s.commit()


def _cleanup_blockers(engine, biz_id, data: RunIn):
    with Session(engine) as s:
        issues = run_preflight(
            biz_id, data, business=s.get(Business, biz_id),
            agent_config=s.exec(select(AgentConfig)).first(), session=s,
            ws=None, config=None, user=None, create=False,
        ).issues
    return [i.message for i in issues if i.field_path == "metamodel_cleanup"]


def test_unfinished_cleanup_blocks_only_its_scope_and_catalog(engine, biz_id):
    # v2 ECM is installed in home and other; v1 ECM was deleted, and its
    # cleanup is unfinished in other (case differs), done in third.
    v2 = _version(engine, biz_id, version=2, installed=(HOME, OTHER))
    _cleanup(engine, catalog=OTHER.upper(), status="failed")
    _cleanup(engine, catalog=THIRD, status="done")
    _cleanup(engine, catalog=HOME, scope="mvm")

    def vibe(catalog):
        return RunIn(intent=Intent.VIBE_ITERATE, version_id=v2, catalog=catalog,
                     cataloging_style="One Catalog", vibe_instructions="x")

    assert _cleanup_blockers(engine, biz_id, vibe(OTHER)) == [
        f"Cleanup of deleted v1 ECM is not finished in {OTHER.upper()}. Retry it on the business page."
    ]
    assert _cleanup_blockers(engine, biz_id, vibe(HOME)) == []  # only an MVM row there
    assert _cleanup_blockers(engine, biz_id, vibe(THIRD)) == []  # done
    nbm = RunIn(intent=Intent.NEW_BASE_MODEL, catalog=HOME, cataloging_style="One Catalog")
    assert len(_cleanup_blockers(engine, biz_id, nbm)) == 1  # a base model writes both scopes


def test_cleanup_of_another_business_does_not_block(engine, biz_id):
    v2 = _version(engine, biz_id, version=2, installed=(HOME,))
    with Session(engine) as s:
        s.add(MetamodelCleanup(
            business_segment="someone_else", version=1, scope="ecm",
            catalog=HOME, reason="business_delete",
        ))
        s.commit()
    data = RunIn(intent=Intent.VIBE_ITERATE, version_id=v2, catalog=HOME,
                 cataloging_style="One Catalog", vibe_instructions="x")
    assert _cleanup_blockers(engine, biz_id, data) == []


# --------------------------------------------------------------------------- #
# Capability rule (§4.1)
# --------------------------------------------------------------------------- #


def test_capability_refusal_names_the_grant(api, biz_id, monkeypatch):
    _refuse_capability(monkeypatch)
    v = api.post(f"/api/businesses/{biz_id}/runs/validate", json=_nbm())
    blocker = v.json()["blockers"][0]
    assert blocker["message"].startswith(f"The app's service principal can't create schemas in catalog '{HOME}'")
    assert "GRANT CREATE SCHEMA, USE CATALOG ON CATALOG" in blocker["message"]


def test_dry_run_vibe_needs_only_metamodel_access(engine, biz_id, monkeypatch):
    """A Dry Run vibe creates no schemas: a missing CREATE_SCHEMA is no blocker."""
    _refuse_capability(monkeypatch, create_schema=False, use_metamodel=True)
    v2 = _version(engine, biz_id, version=2, installed=(HOME,))
    data = RunIn(intent=Intent.VIBE_ITERATE, version_id=v2, catalog=HOME, dry_run=True,
                 cataloging_style="One Catalog", vibe_instructions="x")
    with Session(engine) as s:
        issues = run_preflight(
            biz_id, data, business=s.get(Business, biz_id),
            agent_config=s.exec(select(AgentConfig)).first(), session=s,
            ws=MagicMock(), config=None, user=None, create=False,
        ).issues
    assert not [i for i in issues if "service principal can't" in i.message]

    _refuse_capability(monkeypatch, create_schema=True, use_metamodel=False)
    with Session(engine) as s:
        issues = run_preflight(
            biz_id, data, business=s.get(Business, biz_id),
            agent_config=s.exec(select(AgentConfig)).first(), session=s,
            ws=MagicMock(), config=None, user=None, create=False,
        ).issues
    assert [i.message for i in issues if "service principal can't" in i.message] == [
        f"The app's service principal can't use `_metamodel` in catalog '{HOME}'. Ask a catalog owner "
        "to run:\nGRANT USE SCHEMA ON SCHEMA `x`.`_metamodel` TO `app-sp-id`;"
    ]


def test_unchecked_capability_warns(api, biz_id, monkeypatch):
    monkeypatch.setattr(
        _uc_privileges, "app_catalog_capabilities",
        lambda names: [(n, _uc_privileges.UNCHECKED) for n in names],
    )
    v = api.post(f"/api/businesses/{biz_id}/runs/validate", json=_nbm())
    assert v.json()["blockers"] == []
    assert f"Couldn't check the app's access to catalog '{HOME}'." in [w["message"] for w in v.json()["warnings"]]


def test_multi_catalog_style_warns_that_derived_catalogs_are_unchecked(api, biz_id):
    body = {"intent": "new-base-model", "catalog": HOME, "cataloging_style": "Catalog per Domain"}
    v = api.post(f"/api/businesses/{biz_id}/runs/validate", json=body)
    assert v.status_code == 200, v.text
    derived = [w for w in v.json()["warnings"] if w["field_path"] == "cataloging_style"]
    assert len(derived) == 1 and "CREATE CATALOG" in derived[0]["message"]


# --------------------------------------------------------------------------- #
# Notebook readable: shared, cached 60 s
# --------------------------------------------------------------------------- #


def test_notebook_read_is_cached_between_validate_and_create(api, biz_id, fake):
    get_status = fake.ws._rest.workspace.get_status
    for _ in range(3):
        assert api.post(f"/api/businesses/{biz_id}/runs/validate", json=_nbm()).status_code == 200
    assert api.post(f"/api/businesses/{biz_id}/runs", json=_nbm()).status_code == 200
    assert get_status.call_count == 1


def test_notebook_cache_expires_and_a_save_reads_fresh(monkeypatch):
    from vibe_modeling.backend.routes import _helpers

    ws = MagicMock()
    clock = [100.0]
    monkeypatch.setattr(_helpers.time, "monotonic", lambda: clock[0])
    assert _helpers.notebook_access(ws, NOTEBOOK) == _helpers.NotebookAccess()
    ws.workspace.get_status.side_effect = PermissionDenied("revoked")
    assert _helpers.notebook_access(ws, NOTEBOOK).refused is None  # kept
    clock[0] += _helpers.NOTEBOOK_ACCESS_TTL_SECONDS + 1
    assert "cannot access the agent notebook" in _helpers.notebook_access(ws, NOTEBOOK).refused
    ws.workspace.get_status.side_effect = None
    assert _helpers.notebook_access(ws, NOTEBOOK).refused is not None  # the refusal is kept too
    assert _helpers.notebook_access(ws, NOTEBOOK, fresh=True) == _helpers.NotebookAccess()
    assert _helpers.notebook_access(ws, NOTEBOOK) == _helpers.NotebookAccess()


def test_transient_notebook_error_is_unchecked_and_not_kept():
    """Only NotFound / PermissionDenied refuse. A 5xx or a timeout is a
    "couldn't check" warning, and the next check reads again."""
    from databricks.sdk.errors import TemporarilyUnavailable

    from vibe_modeling.backend.routes import _helpers

    ws = MagicMock()
    ws.workspace.get_status.side_effect = TemporarilyUnavailable("503")
    access = _helpers.notebook_access(ws, NOTEBOOK)
    assert access.refused is None and "Couldn't check" in access.unchecked
    ws.workspace.get_status.side_effect = None
    assert _helpers.notebook_access(ws, NOTEBOOK) == _helpers.NotebookAccess()
    assert ws.workspace.get_status.call_count == 2


def test_transient_notebook_error_warns_and_create_reads_again(api, engine, biz_id, fake):
    from databricks.sdk.errors import TemporarilyUnavailable

    get_status = fake.ws._rest.workspace.get_status
    get_status.side_effect = TemporarilyUnavailable("503")
    v = api.post(f"/api/businesses/{biz_id}/runs/validate", json=_nbm())
    assert v.status_code == 200, v.text
    assert v.json()["blockers"] == []
    assert any(w["field_path"] == "(agent_config.notebook_path)" and "Couldn't check" in w["message"]
               for w in v.json()["warnings"])
    get_status.side_effect = None
    c = api.post(f"/api/businesses/{biz_id}/runs", json=_nbm())
    assert c.status_code == 200, c.text
    assert get_status.call_count == 2  # create read again


# --------------------------------------------------------------------------- #
# Fix round: empty-scope cleanup, parent count bounds, read errors, texts
# --------------------------------------------------------------------------- #


def test_cleanup_row_with_empty_scope_is_ecm(engine, biz_id):
    """``ModelVersion.scope`` defaults to "" (legacy ECM); its cleanup row
    stores "" and still blocks ECM runs, named as ECM."""
    v2 = _version(engine, biz_id, version=2, scope="", installed=(HOME,))
    _cleanup(engine, catalog=HOME, scope="")
    data = RunIn(intent=Intent.VIBE_ITERATE, version_id=v2, catalog=HOME,
                 cataloging_style="One Catalog", vibe_instructions="x")
    assert _cleanup_blockers(engine, biz_id, data) == [
        f"Cleanup of deleted v1 ECM is not finished in {HOME}. Retry it on the business page."
    ]
    nbm = RunIn(intent=Intent.NEW_BASE_MODEL, catalog=HOME, cataloging_style="One Catalog")
    assert len(_cleanup_blockers(engine, biz_id, nbm)) == 1


class _Count:
    """``statement_execution`` answering one COUNT; records each call."""

    def __init__(self, value=None, error=None):
        self.value, self.error, self.calls = value, error, []

    def execute_statement(self, **kwargs):
        from types import SimpleNamespace

        from _sql_fakes import response

        self.calls.append(kwargs)
        if self.error is not None:
            raise self.error
        if self.value is None:
            return response(state="CANCELED")
        return response([[str(self.value)]])


def _parent_check(engine, biz_id, ws, *, live):
    from vibe_modeling.backend.services.orchestrator.preflight import (
        _check_metamodel_parent_version_present,
    )

    with Session(engine) as s:
        vid = s.exec(select(ModelVersion).where(ModelVersion.business_id == biz_id)).first().id
        data = RunIn(intent=Intent.VIBE_ITERATE, version_id=vid, catalog=HOME,
                     cataloging_style="One Catalog", vibe_instructions="x")
        return _check_metamodel_parent_version_present(
            biz_id, data, s.exec(select(AgentConfig)).first(), s, ws, live=live,
        )


def _running_ws(count: _Count, state="RUNNING"):
    from types import SimpleNamespace

    ws = MagicMock()
    ws.warehouses.get.return_value = SimpleNamespace(state=SimpleNamespace(value=state))
    ws.statement_execution = count
    return ws


@pytest.mark.parametrize("count", [
    _Count(value=0), _Count(value=None), _Count(error=RuntimeError("boom")),
], ids=["zero", "cancelled_at_wait_end", "error"])
def test_validate_keeps_every_parent_count_outcome_for_a_minute(engine, biz_id, count):
    _version(engine, biz_id, version=1, installed=())
    ws = _running_ws(count)
    first = _parent_check(engine, biz_id, ws, live=False)
    for _ in range(3):
        assert _parent_check(engine, biz_id, ws, live=False) == first
    assert len(count.calls) == 1
    assert count.calls[0]["wait_timeout"] == "10s"
    assert getattr(count.calls[0]["on_wait_timeout"], "value", None) == "CANCEL"
    expected = "blocker" if count.value == 0 else "warning"
    assert first.severity == expected


def test_create_counts_again_unless_validate_kept_a_positive(engine, biz_id):
    _version(engine, biz_id, version=1, installed=())
    zero = _Count(value=0)
    assert _parent_check(engine, biz_id, _running_ws(zero), live=False).severity == "blocker"
    assert _parent_check(engine, biz_id, _running_ws(zero), live=True).severity == "blocker"
    assert len(zero.calls) == 2  # create did not reuse the kept zero
    from vibe_modeling.backend.services.orchestrator.preflight import clear_preflight_caches

    clear_preflight_caches()
    one = _Count(value=3)
    assert _parent_check(engine, biz_id, _running_ws(one), live=False) is None
    assert _parent_check(engine, biz_id, _running_ws(one), live=True) is None
    assert len(one.calls) == 1  # create reused the kept positive


def test_validate_does_not_wake_a_stopped_warehouse(engine, biz_id):
    _version(engine, biz_id, version=1, installed=())
    count = _Count(value=3)
    issue = _parent_check(engine, biz_id, _running_ws(count, state="STOPPED"), live=False)
    assert issue.severity == "warning" and "not running" in issue.message
    assert count.calls == []
    assert _parent_check(engine, biz_id, _running_ws(count, state="STOPPED"), live=True) is None
    assert len(count.calls) == 1  # create still counts


def test_one_parent_count_in_flight_per_version(engine, biz_id):
    """While a count runs, a second validate for the same version starts none."""
    import threading

    _version(engine, biz_id, version=1, installed=())
    started, release = threading.Event(), threading.Event()
    count = _Count(value=3)
    real = count.execute_statement

    def slow(**kwargs):
        started.set()
        release.wait(5)
        return real(**kwargs)

    count.execute_statement = slow
    out = {}
    t = threading.Thread(target=lambda: out.setdefault("first", _parent_check(engine, biz_id, _running_ws(count), live=False)))
    t.start()
    assert started.wait(5)
    second = _parent_check(engine, biz_id, _running_ws(count), live=False)
    release.set()
    t.join(5)
    assert second.severity == "warning" and "Checking" in second.message
    assert out["first"] is None
    assert len(count.calls) == 1


def test_read_errors_are_visible_warnings(api, biz_id, fake):
    fake.ws._rest.warehouses.get.side_effect = RuntimeError("503")
    v = api.post(f"/api/businesses/{biz_id}/runs/validate", json=_nbm())
    assert v.status_code == 200, v.text
    assert "Couldn't check that the configured SQL warehouse 'wh-1' exists." in [
        w["message"] for w in v.json()["warnings"]
    ]


def test_unreadable_catalog_and_metamodel_are_visible_warnings(engine, biz_id):
    ws = MagicMock()
    ws.catalogs.get.side_effect = RuntimeError("timeout")
    ws.schemas.get.side_effect = RuntimeError("timeout")
    data = RunIn(intent=Intent.NEW_BASE_MODEL, catalog=HOME, cataloging_style="One Catalog")
    with Session(engine) as s:
        issues = run_preflight(
            biz_id, data, business=s.get(Business, biz_id),
            agent_config=s.exec(select(AgentConfig)).first(), session=s,
            ws=ws, config=None, user=None, create=False,
        ).issues
    messages = [i.message for i in issues if i.severity == "warning"]
    assert f"Couldn't check that catalog '{HOME}' exists." in messages
    assert f"Couldn't check `_metamodel` in catalog '{HOME}'." in messages
    assert not [i for i in issues if i.severity in ("blocker", "prepare")]


def test_denied_metamodel_refuses_with_the_grant(api, engine, biz_id, fake, monkeypatch):
    """The app can't read an existing ``_metamodel``: a blocker naming the
    GRANT, decided from the read; nothing is set up."""
    from vibe_modeling.backend.core import _app_identity

    monkeypatch.setattr(_app_identity, "app_application_id", lambda ws: "app-sp-id")
    real_get = fake.ws.schemas.get

    def denied(full_name, **kw):
        if full_name == f"{HOME}._metamodel":
            raise PermissionDenied("no USE SCHEMA")
        return real_get(full_name, **kw)

    monkeypatch.setattr(fake.ws.schemas, "get", denied)
    before = table_digests(engine)
    v = api.post(f"/api/businesses/{biz_id}/runs/validate", json=_nbm())
    first = v.json()["blockers"][0]
    assert first["field_path"] == "catalog"
    assert "GRANT USE SCHEMA ON SCHEMA `home_cat`.`_metamodel` TO `app-sp-id`;" in first["message"]
    c = api.post(f"/api/businesses/{biz_id}/runs", json=_nbm())
    assert c.status_code == 400, c.text
    assert c.json()["detail"] == first["message"]
    assert not [call for call in fake.calls if call.seam in WRITE_SEAMS]
    assert changed_tables(before, table_digests(engine)) == set()


def test_capability_text_names_the_missing_right(api, biz_id, monkeypatch):
    """A schema-creating run that lacks only use of ``_metamodel`` is told so."""
    _refuse_capability(monkeypatch, create_schema=True, use_metamodel=False)
    v = api.post(f"/api/businesses/{biz_id}/runs/validate", json=_nbm())
    assert v.json()["blockers"][0]["message"].startswith(
        f"The app's service principal can't use `_metamodel` in catalog '{HOME}'."
    )


def test_capability_grant_lines_are_not_repeated(api, biz_id, monkeypatch):
    grant = "GRANT CREATE SCHEMA, USE CATALOG ON CATALOG `x` TO `app-sp-id`;"
    cap = _uc_privileges.CatalogCapability(
        create_schema=False, use_metamodel=False, create_schema_fix=grant, use_metamodel_fix=grant,
    )
    monkeypatch.setattr(_uc_privileges, "app_catalog_capabilities", lambda names: [(n, cap) for n in names])
    v = api.post(f"/api/businesses/{biz_id}/runs/validate", json=_nbm())
    assert v.json()["blockers"][0]["message"].count(grant) == 1


def test_missing_metamodel_catalog_points_at_settings(api, engine, biz_id):
    _edit(engine, AgentConfig, deployment_catalog="gone_cat")
    v = api.post(f"/api/businesses/{biz_id}/runs/validate", json=_nbm(HOME))
    blockers = v.json()["blockers"]
    assert blockers[0]["field_path"] == "(agent_config.deployment_catalog)"
    assert "Settings → Platform" in blockers[0]["message"]


def test_prepare_issue_has_severity_prepare_and_create_returns_none(api, biz_id, fake):
    """The ``_metamodel`` setup notice is severity ``prepare`` (it was a
    ``warning``), in validate's ``warnings`` list, never in ``RunOut``."""
    v = api.post(f"/api/businesses/{biz_id}/runs/validate", json=_nbm(OTHER))
    notice = [w for w in v.json()["warnings"] if "will be set up" in w["message"]]
    assert [w["severity"] for w in notice] == ["prepare"]
    c = api.post(f"/api/businesses/{biz_id}/runs", json=_nbm(OTHER))
    assert c.status_code == 200, c.text
    assert not [w for w in c.json()["warnings"] if w["severity"] == "prepare"]


def test_couldnt_check_warnings_are_not_repeated_after_the_launch(api, biz_id, fake):
    """The "couldn't check" notes are for the form: create still starts and
    leaves them out of ``RunOut.warnings``."""
    from databricks.sdk.errors import TemporarilyUnavailable

    fake.ws._rest.workspace.get_status.side_effect = TemporarilyUnavailable("503")
    fake.ws._rest.warehouses.get.side_effect = RuntimeError("503")
    v = api.post(f"/api/businesses/{biz_id}/runs/validate", json=_nbm(THIRD))
    unchecked = [w for w in v.json()["warnings"] if w["message"].startswith("Couldn't check")]
    assert len(unchecked) == 2, v.json()
    c = api.post(f"/api/businesses/{biz_id}/runs", json=_nbm(THIRD))
    assert c.status_code == 200, c.text
    assert c.json()["warnings"] == []


def test_a_stopped_warehouse_state_is_kept_briefly(engine, biz_id, monkeypatch):
    from vibe_modeling.backend.services.orchestrator import preflight as preflight_mod

    _version(engine, biz_id, version=1, installed=())
    count = _Count(value=3)
    ws = _running_ws(count, state="STOPPED")
    clock = [100.0]
    monkeypatch.setattr(preflight_mod.time, "monotonic", lambda: clock[0])
    for _ in range(3):
        _parent_check(engine, biz_id, ws, live=False)
    assert ws.warehouses.get.call_count == 1
    clock[0] += preflight_mod.WAREHOUSE_STOPPED_TTL_SECONDS + 1
    _parent_check(engine, biz_id, ws, live=False)
    assert ws.warehouses.get.call_count == 2

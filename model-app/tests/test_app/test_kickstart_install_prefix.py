"""Schema prefixes of industry and kickstarted models through install.

* An industry downloaded with 0.9.0 has ``ecm_`` / ``mvm_`` in the app's copy
  of its files (``services/scope_prefix``). Installed directly in One
  Catalog, each scope sends its file's prefix, so its ECM and MVM do not
  share schemas. One downloaded before 0.9.0 sends its file's ``""``.
* A typed prefix other than the file's is refused (m7).
* A business kickstarted from a 0.9.0 industry copies its files verbatim and
  its markers; from an older industry, it gets the import rule: the cloned
  rows, the ``_metamodel`` seed and the copied model.json all name
  ``ecm_crop`` / ``mvm_crop`` and metric views ``ecm_<view>``.
* The T2 J8 flow (kickstart, Full Run vibe, Dry Run, install the draft into
  the metamodel catalog) has no blocker and dispatches the draft file's
  prefix, scoped or not.

The industry conventions are the agriculture model's, verbatim
(lakehouse-industry-data-models data-models/agriculture/v1/mvm/model.json).
"""
from __future__ import annotations

import copy
import json
import re
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import MagicMock

import pytest
from sqlmodel import Session, select

from ._drift.fake_uc import agent_registry_columns
from ._fake_volume import FakeVolume
from vibe_modeling.backend.core._paths import model_json_volume_path, version_dir_in_volume
from vibe_modeling.backend.db_models import Business, Domain, ModelVersion, Run, RunOperation
from vibe_modeling.backend.model_sync import ModelSyncService
from vibe_modeling.backend.services.industry_kickstart import kickstart_from_industry
from vibe_modeling.backend.services.schema_names import install_schema_names
from vibe_modeling.backend.services.scope_prefix import apply_import_prefix, import_schema_prefix

FIXTURE = Path(__file__).parent.parent / "fixtures" / "industry_agriculture_v1_trimmed.json"
CATALOG = "test_metamodel_catalog"
INDUSTRY = "Agriculture"

INDUSTRY_MC = {
    "data_asset_naming_convention": "snake_case",
    "primary_key_suffix": "_id",
    "schema_prefix": "",
    "schema_suffix": "",
    "tag_prefix": "dbx_",
    "tag_suffix": "",
    "table_id_type": "BIGINT",
    "boolean_format": "Boolean (True/False)",
    "date_format": "yyyy-MM-dd",
    "timestamp_format": "yyyy-MM-dd'T'HH:mm:ss.SSSXXX",
    "data_classification_levels": "restricted=restricted, confidential=confidential, internal=Internal, public=public",
    "housekeeping_columns": "",
    "history_tracking_columns": "",
}


def _model(scope: str, *, prefix: str = "", vibe_scope: bool = False) -> dict:
    """A trimmed agriculture model.json: two domains, unprefixed by default."""
    names = [(d, f"{prefix}{d}") for d in ("crop", "land")]
    root = {
        "agent_version": "5.3.3",
        "model": {
            "type": "business",
            "name": INDUSTRY,
            "version": f"v1_{scope}",
            "description": "Agriculture industry model.",
            "model_conventions": {**INDUSTRY_MC, "schema_prefix": prefix},
            "domains": [
                {
                    "name": name,
                    "division": "operations",
                    "description": f"{name} domain.",
                    "database_name": db,
                    "products": [{
                        "product": "field",
                        "table_name": "field",
                        "primary_key": "field_id",
                        "attributes": [{"attribute": "field_id", "column_name": "field_id", "type": "BIGINT"}],
                    }],
                }
                for name, db in names
            ],
        },
    }
    if vibe_scope:
        root["_vibe_scope"] = {"mode": "domains", "preserved_products": [], "base_version": "2", "base_scope": scope}
    return root


_Volume = FakeVolume


def _sql_ok(ws: MagicMock) -> list[str]:
    """Every SQL statement succeeds; returns the list the statements land in."""
    ws.tables.get.return_value = SimpleNamespace(columns=[
        SimpleNamespace(name=c) for c, _ in agent_registry_columns("business")
    ])
    statements: list[str] = []

    def _execute(**kwargs):
        statements.append(kwargs.get("statement", ""))
        return SimpleNamespace(status=SimpleNamespace(error=None, state="SUCCEEDED"), result=None, manifest=None)

    ws.statement_execution.execute_statement.side_effect = _execute
    return statements


def _seed_industry(engine, volume: _Volume, roots: dict | None = None, *, downloaded_090: bool = False) -> dict[str, str]:
    """A downloaded industry (ECM and MVM v1), its files in the metamodel
    catalog as ``industry_download`` lays them out (``roots`` per scope, else
    :func:`_model`). ``downloaded_090``: as 0.9.0 downloads it, the app's copy
    prefixed and the markers recorded; otherwise as before 0.9.0."""
    ids: dict[str, str] = {}
    with Session(engine) as s:
        b = Business(name=INDUSTRY, industry_alignment="Agriculture", description="Agriculture.", kind="industry")
        s.add(b)
        s.flush()
        ids["business"] = b.id
        for scope in ("ecm", "mvm"):
            path = model_json_volume_path(CATALOG, INDUSTRY, 1, scope)
            root = copy.deepcopy((roots or {}).get(scope) or _model(scope))
            markers = {}
            if downloaded_090:
                report = apply_import_prefix(root, scope, import_schema_prefix(scope, ""))
                markers = {"import_schema_prefix_added": report.schema_prefix_added,
                           "import_view_prefix_added": report.view_prefix_added}
            mv = ModelVersion(business_id=b.id, version=1, scope=scope, status="completed",
                              deployment_status="draft", files_catalog=CATALOG, import_source_path=path, **markers)
            s.add(mv)
            s.flush()
            ModelSyncService(s).sync_from_model_json(mv.id, root["model"])
            volume.put(path, root)
            ids[scope] = mv.id
        s.commit()
    return ids


def _install(client, biz: str, vid: str, scope: str, **extra):
    body = {"intent": "install", "version_id": vid, "scope": scope, "catalog": CATALOG,
            "cataloging_style": "One Catalog", **extra}
    out = client.post(f"/api/businesses/{biz}/runs/validate", json=body)
    assert out.status_code == 200, out.text
    body["confirmed_issues"] = [w["subject"] for w in out.json()["warnings"] if w["severity"] == "confirm"]
    r = client.post(f"/api/businesses/{biz}/runs", json=body)
    return out.json(), r


def _dispatched(engine, run_id: str) -> dict:
    """The install's dispatched widgets; the run is then marked finished so
    the business can start the next one."""
    with Session(engine) as s:
        op = s.exec(select(RunOperation).where(
            RunOperation.run_id == run_id, RunOperation.operation_name == "install")).one()
        run = s.get(Run, run_id)
        run.status = "completed"
        s.add(run)
        s.commit()
        return json.loads(op.dispatched_widgets_json)


def _schemas(mock_ws, *names):
    mock_ws.schemas.list.side_effect = lambda *a, **kw: iter(
        [SimpleNamespace(name=n) for n in ("_metamodel", "default", *names)]
    )


def _run_now(mock_ws):
    mock_ws.jobs.run_now.return_value = SimpleNamespace(run_id=777, response=SimpleNamespace(run_id=777))


# --- A downloaded industry installed directly --------------------------------


def test_an_industry_ecm_and_mvm_in_one_catalog_get_different_schemas(engine, client_with_agent, mock_ws):
    volume = _Volume(mock_ws)
    ids = _seed_industry(engine, volume, downloaded_090=True)
    _schemas(mock_ws)
    _run_now(mock_ws)
    prefixes = {}
    for scope in ("ecm", "mvm"):
        out, r = _install(client_with_agent, ids["business"], ids[scope], scope)
        assert out["blockers"] == [], out
        assert r.status_code == 200, r.text
        prefixes[scope] = _dispatched(engine, r.json()["id"])["schema_prefix"]
    assert prefixes == {"ecm": "ecm_", "mvm": "mvm_"}
    with Session(engine) as s:
        ecm = install_schema_names(s, ids["ecm"], prefix=prefixes["ecm"], suffix="")
        mvm = install_schema_names(s, ids["mvm"], prefix=prefixes["mvm"], suffix="")
    assert ecm == {"ecm_crop", "ecm_land"} and mvm == {"mvm_crop", "mvm_land"}


def test_an_industry_downloaded_before_0_9_0_sends_its_files_blank_prefix(engine, client_with_agent, mock_ws):
    """No record decides: the file's ``""`` is sent (the fix script gives such
    an industry its prefixes)."""
    volume = _Volume(mock_ws)
    ids = _seed_industry(engine, volume)
    _schemas(mock_ws)
    _run_now(mock_ws)
    out, r = _install(client_with_agent, ids["business"], ids["ecm"], "ecm")
    assert out["blockers"] == [], out
    assert r.status_code == 200, r.text
    assert _dispatched(engine, r.json()["id"])["schema_prefix"] == ""


def test_a_typed_prefix_other_than_the_files_is_refused(engine, client_with_agent, mock_ws):
    from ._assess_helpers import table_digests

    volume = _Volume(mock_ws)
    ids = _seed_industry(engine, volume, downloaded_090=True)
    _schemas(mock_ws)
    _run_now(mock_ws)
    body = {"intent": "install", "version_id": ids["mvm"], "scope": "mvm", "catalog": CATALOG,
            "cataloging_style": "One Catalog", "schema_prefix": "farm_"}
    out = client_with_agent.post(f"/api/businesses/{ids['business']}/runs/validate", json=body)
    assert out.status_code == 200, out.text
    assert [b["message"] for b in out.json()["blockers"]] == [
        "This version's model file uses the schema prefix 'mvm_'. Installing with 'farm_' renames "
        "its schemas and the agent drops its metric views. Leave Schema Prefix empty."
    ]
    before = table_digests(engine)
    r = client_with_agent.post(f"/api/businesses/{ids['business']}/runs", json=body)
    assert r.status_code == 400, r.text
    assert table_digests(engine) == before
    mock_ws.jobs.run_now.assert_not_called()


def test_the_files_own_prefix_typed_is_accepted_and_a_typed_blank_is_refused(engine, client_with_agent, mock_ws):
    volume = _Volume(mock_ws)
    ids = _seed_industry(engine, volume, downloaded_090=True)
    _schemas(mock_ws)
    _run_now(mock_ws)
    _, r = _install(client_with_agent, ids["business"], ids["mvm"], "mvm", schema_prefix="mvm_")
    assert r.status_code == 200, r.text
    assert _dispatched(engine, r.json()["id"])["schema_prefix"] == "mvm_"
    with Session(engine) as s:
        before = len(s.exec(select(Run)).all())
    r = client_with_agent.post(f"/api/businesses/{ids['business']}/runs", json={
        "intent": "install", "version_id": ids["ecm"], "scope": "ecm", "catalog": CATALOG,
        "cataloging_style": "One Catalog", "schema_prefix": "",
    })
    assert r.status_code == 400, r.text
    with Session(engine) as s:
        assert len(s.exec(select(Run)).all()) == before


# --- Kickstart ----------------------------------------------------------------


def _kickstart(engine, mock_ws, volume: _Volume, roots: dict | None = None, *,
               downloaded_090: bool = False) -> tuple[str, dict[str, str], list[str]]:
    _seed_industry(engine, volume, roots, downloaded_090=downloaded_090)
    with Session(engine) as s:
        industry_id = s.exec(select(Business).where(Business.kind == "industry")).one().id
    statements = _sql_ok(mock_ws)
    with Session(engine) as s:
        business = kickstart_from_industry(
            s, mock_ws, source_industry_id=industry_id, source_version=1, new_name="WT Kick",
        )
        s.commit()
        biz = business.id
    with Session(engine) as s:
        versions = {mv.scope: mv.id for mv in s.exec(select(ModelVersion).where(ModelVersion.business_id == biz)).all()}
    return biz, versions, statements


def test_kickstart_copies_use_the_scope_prefixes(engine, client_with_agent, mock_ws):
    volume = _Volume(mock_ws)
    biz, versions, statements = _kickstart(engine, mock_ws, volume)
    assert set(versions) == {"ecm", "mvm"}
    with Session(engine) as s:
        for scope, vid in versions.items():
            names = {d.database_name for d in s.exec(select(Domain).where(Domain.version_id == vid)).all()}
            assert names == {f"{scope}_crop", f"{scope}_land"}
            copied = volume.json(f"{version_dir_in_volume(CATALOG, 'WT Kick', 1, scope)}/model.json")
            assert copied["model"]["model_conventions"]["schema_prefix"] == f"{scope}_"
            assert [d["database_name"] for d in copied["model"]["domains"]] == [f"{scope}_crop", f"{scope}_land"]
    seeded = " ".join(statements)
    for scope in ("ecm", "mvm"):
        for name in ("crop", "land"):
            # _metamodel.domain rows: (..., domain, division, description, database_name, ...)
            assert f"'{name}', 'operations', '{name} domain.', '{scope}_{name}'" in seeded
            assert f"'{name} domain.', '{name}'" not in seeded
    industry = volume.json(model_json_volume_path(CATALOG, INDUSTRY, 1, "mvm"))
    assert industry["model"]["model_conventions"]["schema_prefix"] == ""
    with Session(engine) as s:
        markers = {mv.scope: (mv.import_schema_prefix_added, mv.import_view_prefix_added)
                   for mv in s.exec(select(ModelVersion).where(ModelVersion.business_id == biz)).all()}
    assert markers == {"ecm": ("ecm_", "ecm_"), "mvm": ("mvm_", "mvm_")}
    assert f"'{version_dir_in_volume(CATALOG, 'WT Kick', 1, 'mvm')}'" in seeded


def test_a_kickstart_of_a_0_9_0_industry_copies_its_files_verbatim_with_its_markers(engine, client_with_agent, mock_ws):
    volume = _Volume(mock_ws)
    fixture = json.loads(FIXTURE.read_text())
    biz, versions, _ = _kickstart(
        engine, mock_ws, volume, {scope: fixture[scope] for scope in ("ecm", "mvm")}, downloaded_090=True,
    )
    with Session(engine) as s:
        for scope, vid in versions.items():
            mv = s.get(ModelVersion, vid)
            assert (mv.import_schema_prefix_added, mv.import_view_prefix_added) == (f"{scope}_", f"{scope}_")
            industry = volume.files[model_json_volume_path(CATALOG, INDUSTRY, 1, scope)]
            assert volume.files[f"{version_dir_in_volume(CATALOG, 'WT Kick', 1, scope)}/model.json"] == industry
            rows = {d.database_name for d in s.exec(select(Domain).where(Domain.version_id == vid)).all()}
            assert rows and all(n.startswith(f"{scope}_") and not n.startswith(f"{scope}_{scope}_") for n in rows)


def test_a_kickstart_of_the_real_agriculture_files_moves_every_view_source(engine, client_with_agent, mock_ws):
    volume = _Volume(mock_ws)
    fixture = json.loads(FIXTURE.read_text())
    biz, versions, _ = _kickstart(engine, mock_ws, volume, {scope: fixture[scope] for scope in ("ecm", "mvm")})
    with Session(engine) as s:
        for scope, vid in versions.items():
            rows = {d.database_name for d in s.exec(select(Domain).where(Domain.version_id == vid)).all()}
            copied = volume.json(f"{version_dir_in_volume(CATALOG, 'WT Kick', 1, scope)}/model.json")["model"]
            assert {d["database_name"] for d in copied["domains"]} == rows
            sources = [re.findall(r'source:\s*"?`[^`]+`\.`([^`]+)`\.`[^`]+`', v["sql"]) for v in copied["metric_views"]]
            assert len(sources) == {"ecm": 97, "mvm": 134}[scope]
            assert all(len(found) == 1 and found[0] in rows for found in sources), scope
            assert all(v["view_name"].startswith(f"{scope}_") for v in copied["metric_views"])


def test_an_unreadable_industry_file_fails_the_kickstart_before_phase_0(engine, client_with_agent, mock_ws):
    volume = _Volume(mock_ws)
    _seed_industry(engine, volume)
    volume.files[model_json_volume_path(CATALOG, INDUSTRY, 1, "ecm")] = b"{not json"
    with Session(engine) as s:
        industry_id = s.exec(select(Business).where(Business.kind == "industry")).one().id
    _sql_ok(mock_ws)
    with Session(engine) as s:
        business = kickstart_from_industry(
            s, mock_ws, source_industry_id=industry_id, source_version=1, new_name="WT Kick",
        )
        s.commit()
        biz = business.id
    with Session(engine) as s:
        assert s.exec(select(ModelVersion).where(ModelVersion.business_id == biz)).all() == []
        run = s.exec(select(Run).where(Run.business_id == biz)).one()
        assert run.status == "failed"
        assert "Could not read the ECM model file" in (run.error_message or "")
    assert not [p for p in volume.files if "/WT Kick/" in p or "wt_kick" in p.lower()]


def test_kickstart_then_install_both_scopes_into_the_metamodel_catalog(engine, client_with_agent, mock_ws):
    """The industry's ``crop`` / ``land`` exist in the catalog: the copies
    write ``ecm_*`` / ``mvm_*`` and clash with nothing."""
    volume = _Volume(mock_ws)
    biz, versions, _ = _kickstart(engine, mock_ws, volume)
    _schemas(mock_ws, "crop", "land")
    _run_now(mock_ws)
    for scope in ("ecm", "mvm"):
        out, r = _install(client_with_agent, biz, versions[scope], scope)
        assert out["blockers"] == [], out
        assert not [w for w in out["warnings"] if "crop" in w["message"] or "land" in w["message"]], out
        assert r.status_code == 200, r.text
        assert _dispatched(engine, r.json()["id"])["schema_prefix"] == f"{scope}_"


def _seed_t2_history(engine, biz: str) -> None:
    """What else T2 left in the app's tables before the J8 install: the
    downloaded industry's ``mvm_`` / ``ecm_`` installs into a second catalog
    failed (E-15), and another business (WT-Conv) has an ECM deployed in the
    metamodel catalog whose New Base Model failed at the shrink (E-16), a
    child op of its ECM dispatched with ``mvm_``."""
    with Session(engine) as s:
        industry = s.exec(select(Business).where(Business.kind == "industry")).one()
        run = Run(business_id=industry.id, intent="install", status="failed")
        s.add(run)
        s.flush()
        for i, mv in enumerate(s.exec(select(ModelVersion).where(ModelVersion.business_id == industry.id)).all()):
            s.add(RunOperation(
                run_id=run.id, step_index=i, operation_name="install", status="failed",
                parent_version_id=mv.id, dispatched_widgets_json=json.dumps({
                    "cataloging_style": "One Catalog", "deployment_catalog": "business_2",
                    "schema_prefix": f"{mv.scope}_",
                }),
            ))
        conv = Business(name="WT Conv", description="d")
        s.add(conv)
        s.flush()
        ecm = ModelVersion(business_id=conv.id, version=1, scope="ecm", status="completed",
                           deployment_status="deployed", uc_catalog=CATALOG, files_catalog=CATALOG)
        s.add(ecm)
        s.flush()
        for name in ("crop", "land"):
            s.add(Domain(version_id=ecm.id, name=name, database_name=name))
        nbm = Run(business_id=conv.id, intent="new-base-model", status="failed")
        s.add(nbm)
        s.flush()
        s.add(RunOperation(
            run_id=nbm.id, step_index=1, operation_name="shrink_ecm", status="failed",
            parent_version_id=ecm.id,
            dispatched_widgets_json=json.dumps({"cataloging_style": "One Catalog", "schema_prefix": "mvm_"}),
        ))
        s.add(RunOperation(
            run_id=nbm.id, step_index=0, operation_name="generate_ecm", status="succeeded",
            output_version_id=ecm.id,
            dispatched_widgets_json=json.dumps({"cataloging_style": "One Catalog", "schema_prefix": "ecm_"}),
        ))
        s.commit()


@pytest.mark.parametrize("t2_history", [False, True], ids=["plain", "with-failed-industry-installs"])
@pytest.mark.parametrize("scoped", [False, True], ids=["dry-run-draft", "scoped-draft"])
def test_j8_kickstart_vibe_dry_run_then_install_the_draft(engine, client_with_agent, mock_ws, scoped, t2_history):
    """T2 J8 with the source industry present: kickstart, a Full Run vibe
    deploys v2 into the metamodel catalog (prefix "" dispatched, as run C,
    j8_dispatch_c.json; a scoped vibe keeps the base's ``mvm_`` in the file),
    a Dry Run makes the v3 draft; installing v3 there is not blocked and
    sends its file's ``mvm_``. With the T2 history (E-12), the industry's
    failed ``mvm_`` install into another catalog and WT-Conv's child shrink
    do not make either of them an owner of ``mvm_crop`` / ``mvm_land``."""
    volume = _Volume(mock_ws)
    biz, versions, _ = _kickstart(engine, mock_ws, volume)
    if t2_history:
        _seed_t2_history(engine, biz)
    with Session(engine) as s:
        v2 = ModelVersion(business_id=biz, version=2, scope="mvm", status="completed",
                          deployment_status="deployed", uc_catalog=CATALOG, files_catalog=CATALOG,
                          base_version_id=versions["mvm"])
        s.add(v2)
        s.flush()
        v3 = ModelVersion(business_id=biz, version=3, scope="mvm", status="draft", dry_run=True,
                          deployment_status="draft", files_catalog=CATALOG, base_version_id=v2.id)
        if scoped:
            v3.scope_fence_mode, v3.scope_base_version, v3.scope_base_scope = "domains", 2, "mvm"
        s.add(v3)
        s.flush()
        for mv in (v2, v3):
            for name in ("crop", "land"):
                s.add(Domain(version_id=mv.id, name=name, database_name=f"mvm_{name}"))
        run = Run(business_id=biz, intent="vibe-iterate", status="completed")
        s.add(run)
        s.flush()
        s.add(RunOperation(
            run_id=run.id, step_index=0, operation_name="vibe_iterate", status="succeeded",
            output_version_id=v2.id, dispatched_widgets_json=json.dumps({
                "cataloging_style": "One Catalog", "deployment_catalog": CATALOG,
                "schema_prefix": "", "schema_suffix": "",
            }),
        ))
        s.commit()
        v3_id = v3.id
    volume.put(model_json_volume_path(CATALOG, "WT Kick", 3, "mvm"), _model("mvm", prefix="mvm_", vibe_scope=scoped))
    _schemas(mock_ws, "crop", "land", "mvm_crop", "mvm_land")
    _run_now(mock_ws)
    out, r = _install(client_with_agent, biz, v3_id, "mvm")
    assert out["blockers"] == [], [b["message"] for b in out["blockers"]]
    assert not [w for w in out["warnings"] if "not recorded by any business" in w["message"]], out
    messages = [i["message"] for i in out["blockers"] + out["warnings"]]
    assert not [m for m in messages if "Agriculture" in m or "WT Conv" in m], messages
    assert r.status_code == 200, r.text
    # v2 occupies the catalog: the run uninstalls it first, then installs v3.
    assert _dispatch_install_step(engine, mock_ws, r.json()["id"])["schema_prefix"] == "mvm_"


def _dispatch_install_step(engine, mock_ws, run_id: str) -> dict:
    """Dispatch the run's install step as the runner would and return the
    widgets it sends."""
    from vibe_modeling.backend.services.operations import OperationContext
    from vibe_modeling.backend.services.operations.install import Install

    with Session(engine) as s:
        op = s.exec(select(RunOperation).where(
            RunOperation.run_id == run_id, RunOperation.operation_name == "install")).one()
        ctx = OperationContext(
            run_id=run_id, operation_id=op.id, business_id="", parent_version_id=op.parent_version_id,
            params=json.loads(op.params_json), inherited_params={},
        )
        return Install().dispatch(ctx, mock_ws, s).dispatched_widgets


# --- An in-place reinstall keeps its recorded prefix (design 5.2) -------------


def _installed_with_scope_default(engine, version_id: str, prefix: str = "ecm_") -> None:
    """A 0.8.0 One Catalog install of the version into CATALOG that sent the
    scope default: an open install row and the succeeded op's widgets."""
    from vibe_modeling.backend.db_models import ModelVersionInstall

    with Session(engine) as s:
        mv = s.get(ModelVersion, version_id)
        mv.deployment_status, mv.uc_catalog = "deployed", CATALOG
        s.add(mv)
        run = Run(business_id=mv.business_id, intent="install", status="completed")
        s.add(run)
        s.flush()
        s.add(ModelVersionInstall(version_id=version_id, catalog=CATALOG, installed_by_run_id=run.id))
        s.add(RunOperation(
            run_id=run.id, step_index=0, operation_name="install", status="succeeded",
            parent_version_id=version_id, dispatched_widgets_json=json.dumps({
                "schema_prefix": prefix, "deployment_catalog": CATALOG, "cataloging_style": "One Catalog",
            }),
        ))
        s.commit()


def test_an_in_place_reinstall_keeps_the_recorded_prefix(engine, client_with_agent, mock_ws):
    """The industry was downloaded and installed before 0.9.0 (``ecm_crop``
    from the scope default, its file ``""``): reinstalling into the same
    catalog sends ``ecm_``, not the file's ``""`` (empty bare schemas)."""
    volume = _Volume(mock_ws)
    ids = _seed_industry(engine, volume)
    _installed_with_scope_default(engine, ids["ecm"])
    _schemas(mock_ws, "ecm_crop", "ecm_land")
    _run_now(mock_ws)
    out, r = _install(client_with_agent, ids["business"], ids["ecm"], "ecm")
    assert out["blockers"] == [], out
    assert r.status_code == 200, r.text
    assert _dispatched(engine, r.json()["id"])["schema_prefix"] == "ecm_"


def test_typing_the_recorded_prefix_is_accepted_in_place(engine, client_with_agent, mock_ws):
    volume = _Volume(mock_ws)
    ids = _seed_industry(engine, volume)
    _installed_with_scope_default(engine, ids["ecm"])
    _schemas(mock_ws, "ecm_crop", "ecm_land")
    _run_now(mock_ws)
    out, r = _install(client_with_agent, ids["business"], ids["ecm"], "ecm", schema_prefix="ecm_")
    assert out["blockers"] == [], out
    assert not [w for w in out["warnings"] if "ecm_crop" in w["message"]], out
    assert r.status_code == 200, r.text
    assert _dispatched(engine, r.json()["id"])["schema_prefix"] == "ecm_"


def test_another_catalog_takes_the_files_prefix(engine, client_with_agent, mock_ws):
    volume = _Volume(mock_ws)
    ids = _seed_industry(engine, volume)
    _installed_with_scope_default(engine, ids["ecm"])
    _schemas(mock_ws)
    _run_now(mock_ws)
    body = {"intent": "install", "version_id": ids["ecm"], "scope": "ecm", "catalog": "other_catalog",
            "cataloging_style": "One Catalog"}
    out = client_with_agent.post(f"/api/businesses/{ids['business']}/runs/validate", json=body)
    assert out.status_code == 200, out.text
    body["confirmed_issues"] = [w["subject"] for w in out.json()["warnings"] if w["severity"] == "confirm"]
    r = client_with_agent.post(f"/api/businesses/{ids['business']}/runs", json=body)
    assert r.status_code == 200, r.text
    assert _dispatched(engine, r.json()["id"])["schema_prefix"] == ""

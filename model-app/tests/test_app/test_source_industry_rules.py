"""Who owns a catalog's schema names: a business, its other scope, and the
industry it was kickstarted from (``orchestrator.source_industry``).

The world: the industry Agriculture with v1 ECM (``ecm_crop``, ``ecm_land``)
installed in business_1 and other_cat, and v1 MVM (``mvm_crop``,
``mvm_land``) installed in business_1; WT-Kick, kickstarted from it, with
the same names, its files in business_1; Other Co with v2 ECM installed in
business_1. third_cat holds nothing of theirs. Names are stored prefixed, as
5.3.3 and a 0.9.0 kickstart store them: a kickstart from a 0.9.0 industry
copies its files verbatim, so the business shares every name with it.
"""
from __future__ import annotations

import json
from types import SimpleNamespace

import pytest
from sqlmodel import Session, select

from vibe_modeling.backend.db_models import Business, Domain, ModelVersion, Run, RunOperation
from vibe_modeling.backend.models import UninstallImpactOut, UninstallImpactSchemaOut, UninstallImpactTableOut
from vibe_modeling.backend.services import uninstall_impact
from vibe_modeling.backend.services.operations._version_lifecycle import mark_version_deployed

from ._assess_helpers import table_digests
from ._drift.fixtures import fake_uc  # noqa: F401
from .test_version_lifecycle_routes import _ws_with_run_now

CAT, OTHER, THIRD = "business_1", "other_cat", "third_cat"
ECM_NAMES = ("ecm_crop", "ecm_land")
MVM_NAMES = ("mvm_crop", "mvm_land")


def _version(s, business, number, scope, names, **extra):
    mv = ModelVersion(business_id=business.id, version=number, scope=scope, status="completed",
                      deployment_status="draft", files_catalog=CAT, **extra)
    s.add(mv)
    s.flush()
    for name in names:
        s.add(Domain(version_id=mv.id, name=name.split("_", 1)[1], database_name=name))
    return mv


def _world(engine) -> SimpleNamespace:
    with Session(engine) as s:
        industry = Business(name="Agriculture", description="d", kind="industry")
        s.add(industry)
        s.flush()
        kick = Business(name="WT-Kick", description="d", source_industry_id=industry.id)
        other = Business(name="Other Co", description="d")
        s.add(kick)
        s.add(other)
        s.flush()
        i_ecm = _version(s, industry, 1, "ecm", ECM_NAMES)
        i_mvm = _version(s, industry, 1, "mvm", MVM_NAMES)
        b_ecm = _version(s, kick, 1, "ecm", ECM_NAMES)
        b_mvm = _version(s, kick, 1, "mvm", MVM_NAMES)
        o_ecm = _version(s, other, 2, "ecm", ("ecm_sales",))
        for mv, catalog in ((i_ecm, OTHER), (i_ecm, CAT), (i_mvm, CAT), (o_ecm, CAT)):
            mark_version_deployed(s, mv, catalog)
        s.commit()
        return SimpleNamespace(
            industry=industry.id, kick=kick.id, other=other.id,
            i_ecm=i_ecm.id, i_mvm=i_mvm.id, b_ecm=b_ecm.id, b_mvm=b_mvm.id, o_ecm=o_ecm.id,
        )


def _listing(mock_ws, *names, by_catalog=None):
    """``schemas.list``: ``names`` in every catalog, or per catalog."""
    def listed(*a, catalog_name=None, **kw):
        found = names if by_catalog is None else by_catalog.get(catalog_name, ())
        return iter([SimpleNamespace(name=n) for n in ("_metamodel", "_metrics", "default", *found)])

    mock_ws.schemas.list.side_effect = listed


@pytest.fixture
def world(engine, mock_ws):
    w = _world(engine)
    _listing(mock_ws, by_catalog={
        CAT: (*ECM_NAMES, *MVM_NAMES, "ecm_sales"), OTHER: ECM_NAMES, THIRD: (),
    })
    _ws_with_run_now(mock_ws)
    return w


def _install_body(vid, catalog=CAT, **extra):
    return {"intent": "install", "version_id": vid, "scope": "ecm", "cataloging_style": "One Catalog",
            "catalog": catalog, **extra}


def _vibe_body(vid, catalog=CAT, **extra):
    return {"intent": "vibe-iterate", "version_id": vid, "vibe_instructions": "Tighten the crop domain",
            "catalog": catalog, **extra}


def _validate(client, biz, body):
    r = client.post(f"/api/businesses/{biz}/runs/validate", json=body)
    assert r.status_code == 200, r.text
    return r.json()


def _create(client, biz, body):
    return client.post(f"/api/businesses/{biz}/runs", json=body)


def _ops(engine, run_id):
    with Session(engine) as s:
        return [
            (op.operation_name, json.loads(op.params_json), op.parent_version_id)
            for op in s.exec(
                select(RunOperation).where(RunOperation.run_id == run_id).order_by(RunOperation.step_index)
            ).all()
        ]


def _rule1(issues):
    return [i for i in issues if "This run uninstalls it first" in i["message"]]


RULE1_TEXT = (
    "Agriculture v1 ECM is installed in business_1. This run uninstalls it first: it drops its "
    "schemas ecm_crop, ecm_land, and the agent's uninstall also drops business_1._metrics, the "
    "metric views of every model installed there: Agriculture v1 MVM, Other Co v2 ECM. Their "
    "metric views come back only when they are installed again."
)


class TestRule1BusinessOverItsIndustry:
    def test_an_install_warns_and_uninstalls_the_industry_first(self, engine, client_with_agent, world):
        out = _validate(client_with_agent, world.kick, _install_body(world.b_ecm))
        assert out["blockers"] == []
        assert [w["message"] for w in _rule1(out["warnings"])] == [RULE1_TEXT]
        # The industry's schemas go with it: no overwrite confirmation for them.
        assert not [w for w in out["warnings"] if w["severity"] == "confirm"]

        r = _create(client_with_agent, world.kick, _install_body(world.b_ecm))
        assert r.status_code == 200, r.text
        assert [w["message"] for w in _rule1(r.json()["warnings"])] == [RULE1_TEXT]
        ops = _ops(engine, r.json()["id"])
        assert [name for name, _, _ in ops] == ["uninstall", "install"]
        (_, uninstall, parent), (_, install, install_parent) = ops
        assert uninstall == {
            "business_name": "agriculture", "deployment_catalog": CAT, "schema_prefix": "ecm_",
            "scope": "ecm", "model_version": 1, "cataloging_style": "One Catalog", "version_id": world.i_ecm,
        }
        assert parent == world.i_ecm
        assert install["version_id"] == world.b_ecm and install_parent == world.b_ecm

    def test_each_catalog_replaces_only_what_is_installed_there(self, engine, client_with_agent, world):
        """other_cat holds the industry's ECM only; third_cat holds nothing of it."""
        out = _validate(client_with_agent, world.kick, _install_body(world.b_ecm, OTHER))
        [warning] = _rule1(out["warnings"])
        assert warning["message"].startswith("Agriculture v1 ECM is installed in other_cat.")
        assert warning["message"].endswith("also drops other_cat._metrics.")
        r = _create(client_with_agent, world.kick, _install_body(world.b_ecm, OTHER))
        assert r.status_code == 200, r.text
        ops = _ops(engine, r.json()["id"])
        assert [(n, p.get("deployment_catalog"), p.get("version_id")) for n, p, _ in ops] == [
            ("uninstall", OTHER, world.i_ecm), ("install", OTHER, world.b_ecm),
        ]

        out = _validate(client_with_agent, world.kick, _install_body(world.b_ecm, THIRD))
        assert _rule1(out["warnings"]) == []

    def test_the_mvm_replaces_the_industrys_mvm(self, engine, client_with_agent, world):
        r = _create(client_with_agent, world.kick, _install_body(world.b_mvm, scope="mvm"))
        assert r.status_code == 200, r.text
        assert [(n, p.get("version_id"), p.get("schema_prefix")) for n, p, _ in _ops(engine, r.json()["id"])] == [
            # The install sends the version file's prefix at dispatch.
            ("uninstall", world.i_mvm, "mvm_"), ("install", world.b_mvm, ""),
        ]
        assert _ops(engine, r.json()["id"])[1][1]["prefix_from_version"] is True

    def test_the_impact_counts_tables_when_it_was_computed(self, engine, client_with_agent, world):
        with Session(engine) as s:
            i_ecm = s.get(ModelVersion, world.i_ecm)
        uninstall_impact.IMPACT_CACHE.put(
            uninstall_impact.uninstall_impact_key(i_ecm.id, CAT, "One Catalog"),
            UninstallImpactOut(version_id=i_ecm.id, catalog=CAT, has_data="yes", schemas=[
                UninstallImpactSchemaOut(name="ecm_crop", tables=[
                    UninstallImpactTableOut(name="field", kind="TABLE", has_data=True),
                    UninstallImpactTableOut(name="harvest", kind="TABLE", has_data=True),
                ]),
                UninstallImpactSchemaOut(name="ecm_land", tables=[
                    UninstallImpactTableOut(name="parcel", kind="TABLE", has_data=False),
                ]),
                UninstallImpactSchemaOut(name="_metrics", shared=True),
            ]),
        )
        try:
            out = _validate(client_with_agent, world.kick, _install_body(world.b_ecm))
        finally:
            uninstall_impact.IMPACT_CACHE.clear()
        [warning] = _rule1(out["warnings"])
        assert "it drops its schemas ecm_crop, ecm_land (2 tables with data), and" in warning["message"]

    def test_a_run_of_the_industry_in_progress_blocks_and_writes_nothing(self, engine, client_with_agent, world):
        with Session(engine) as s:
            s.add(Run(business_id=world.industry, intent="vibe-iterate", status="running"))
            s.commit()
        out = _validate(client_with_agent, world.kick, _install_body(world.b_ecm))
        [blocker] = [b for b in out["blockers"] if "has a run in progress" in b["message"]]
        assert blocker["message"] == (
            "Agriculture has a run in progress. This run must uninstall Agriculture v1 ECM from "
            "business_1 first; wait for that run to finish, then try again."
        )
        before = table_digests(engine)
        r = _create(client_with_agent, world.kick, _install_body(world.b_ecm))
        assert r.status_code == 400, r.text
        assert r.json()["detail"] == blocker["message"]
        assert table_digests(engine) == before

    def test_a_full_vibe_uninstalls_first_and_a_dry_run_does_not(self, engine, client_with_agent, world):
        r = _create(client_with_agent, world.kick, _vibe_body(world.b_ecm))
        assert r.status_code == 200, r.text
        assert [w["message"] for w in _rule1(r.json()["warnings"])] == [RULE1_TEXT]
        assert [(n, p.get("version_id"), parent) for n, p, parent in _ops(engine, r.json()["id"])] == [
            ("uninstall", world.i_ecm, world.i_ecm), ("vibe_iterate", None, world.b_ecm),
        ]
        with Session(engine) as s:
            for run in s.exec(select(Run)).all():
                run.status = "completed"
                s.add(run)
            s.commit()

        body = _vibe_body(world.b_ecm, dry_run=True)
        assert _rule1(_validate(client_with_agent, world.kick, body)["warnings"]) == []
        r = _create(client_with_agent, world.kick, body)
        assert r.status_code == 200, r.text
        assert [n for n, _, _ in _ops(engine, r.json()["id"])] == ["vibe_iterate"]

    def test_vibe_ecm_mvm_uninstalls_first_and_the_vibe_keeps_its_base(self, engine, client_with_agent, world):
        """The shrink writes ``mvm_ecm_crop``: the industry's MVM shares no name."""
        body = {**_vibe_body(world.b_ecm, OTHER), "intent": "vibe-new-ecm-mvm"}
        with Session(engine) as s:
            b_ecm = s.get(ModelVersion, world.b_ecm)
            b_ecm.files_catalog = OTHER
            s.add(b_ecm)
            s.commit()
        r = _create(client_with_agent, world.kick, body)
        assert r.status_code == 200, r.text
        assert [(n, p.get("version_id"), parent) for n, p, parent in _ops(engine, r.json()["id"])] == [
            ("uninstall", world.i_ecm, world.i_ecm),
            ("vibe_iterate", None, world.b_ecm),
            ("shrink_to_mvm", None, None),
        ]

    def test_an_unrelated_business_is_unchanged(self, engine, client_with_agent, world):
        r = _create(client_with_agent, world.other, _install_body(world.o_ecm, THIRD))
        assert r.status_code == 200, r.text
        assert _rule1(r.json()["warnings"]) == []
        assert [n for n, _, _ in _ops(engine, r.json()["id"])] == ["install"]


class TestBusinessAlreadyOverItsIndustry:
    """WT-Kick v1 ECM was installed in business_1 over the industry before;
    the industry's install row stayed open (eviction is per business). Its
    schemas are WT-Kick's now: the run must not dispatch the agent uninstall
    (it would drop them), only close the row and release the rows."""

    @pytest.fixture
    def over(self, engine, world):
        with Session(engine) as s:
            mark_version_deployed(s, s.get(ModelVersion, world.b_ecm), CAT)
            s.commit()
        return world

    RELEASE = {
        "business_name": "agriculture", "deployment_catalog": CAT, "schema_prefix": "ecm_", "scope": "ecm",
        "model_version": 1, "cataloging_style": "One Catalog", "release_only": True,
    }

    @pytest.mark.parametrize("make_body,steps", [
        (lambda w: _install_body(w.b_ecm), ["uninstall", "install"]),
        (lambda w: _vibe_body(w.b_ecm), ["uninstall", "vibe_iterate"]),
        (lambda w: {**_vibe_body(w.b_ecm), "intent": "vibe-new-ecm-mvm"}, ["uninstall", "vibe_iterate", "shrink_to_mvm"]),
    ], ids=["install", "full-vibe", "vibe-ecm-mvm"])
    def test_only_a_release_no_warning_no_refusal(self, engine, client_with_agent, over, mock_ws, make_body, steps):
        body = make_body(over)
        # Other Co's ecm_sales would trip the Vibe ECM + MVM prefix check.
        _listing(mock_ws, by_catalog={CAT: (*ECM_NAMES, *MVM_NAMES), OTHER: ECM_NAMES})
        out = _validate(client_with_agent, over.kick, body)
        assert not [b for b in out["blockers"] if b["field_path"] == "catalog"], out["blockers"]
        assert _rule1(out["warnings"]) == []
        r = _create(client_with_agent, over.kick, body)
        assert r.status_code == 200, r.text
        assert _rule1(r.json()["warnings"]) == []
        ops = _ops(engine, r.json()["id"])
        assert [n for n, _, _ in ops] == steps
        assert ops[0][1] == {**self.RELEASE, "version_id": over.i_ecm}
        mock_ws.jobs.run_now.assert_not_called()

    def test_the_step_closes_the_row_and_releases_the_rows(self, engine, over, fake_uc):
        from vibe_modeling.backend.services.operations import OperationContext, OperationDispatchHandle
        from vibe_modeling.backend.services.operations._version_lifecycle import installed_catalogs
        from vibe_modeling.backend.services.operations.uninstall import Uninstall

        from vibe_modeling.backend.db_models import AgentConfig

        with Session(engine) as s:
            s.add(AgentConfig(job_id=1, job_name="j", warehouse_id="wh-1"))
            s.commit()
        fake_uc.add_agent_version(CAT, "Agriculture", 1, "ecm", {"domains": []}, write_model_json=False)
        ctx = OperationContext(
            run_id="run-1", operation_id="op-1", business_id=over.kick, parent_version_id=over.i_ecm,
            params={**self.RELEASE, "version_id": over.i_ecm}, inherited_params={},
        )
        with Session(engine) as s:
            handle = Uninstall().dispatch(ctx, fake_uc.ws, s)
            obs = Uninstall().observe(handle, ctx, fake_uc.ws, s)
            s.commit()
            assert obs.terminal_result.succeeded
            assert installed_catalogs(s, s.get(ModelVersion, over.i_ecm)) == [OTHER]
            assert CAT in installed_catalogs(s, s.get(ModelVersion, over.b_ecm))
        assert [r["deploy_status"] for r in fake_uc.rows(CAT, "business")] == ["dry_run"]
        fake_uc.ws.jobs.run_now.assert_not_called()


class TestPre090Industry:
    """An industry downloaded before 0.9.0: its domains stored bare (``crop``)
    and installed in business_1 with the recorded scope prefix ``ecm_``, so
    its schemas are ``ecm_crop``. A business kickstarted from it after 0.9.0
    stores ``ecm_crop``."""

    def _world(self, engine):
        with Session(engine) as s:
            industry = Business(name="Old Agri", description="d", kind="industry")
            s.add(industry)
            s.flush()
            kick = Business(name="New Kick", description="d", source_industry_id=industry.id)
            s.add(kick)
            s.flush()
            i_ecm = _version(s, industry, 1, "ecm", ())
            s.add(Domain(version_id=i_ecm.id, name="crop", database_name="crop"))
            b_ecm = _version(s, kick, 1, "ecm", ("ecm_crop",))
            run = Run(business_id=industry.id, intent="install", status="completed")
            s.add(run)
            s.flush()
            s.add(RunOperation(
                run_id=run.id, step_index=0, operation_name="install", status="succeeded",
                parent_version_id=i_ecm.id,
                dispatched_widgets_json=json.dumps({
                    "deployment_catalog": CAT, "schema_prefix": "ecm_", "cataloging_style": "One Catalog",
                }),
            ))
            mark_version_deployed(s, i_ecm, CAT)
            s.commit()
            return SimpleNamespace(industry=industry.id, kick=kick.id, i_ecm=i_ecm.id, b_ecm=b_ecm.id)

    def test_the_business_replaces_it_uninstall_first(self, engine, client_with_agent, mock_ws):
        w = self._world(engine)
        _listing(mock_ws, "ecm_crop")
        _ws_with_run_now(mock_ws)
        r = _create(client_with_agent, w.kick, _install_body(w.b_ecm))
        assert r.status_code == 200, r.text
        [warning] = _rule1(r.json()["warnings"])
        assert warning["message"].startswith(
            "Old Agri v1 ECM is installed in business_1. This run uninstalls it first: it drops its schemas ecm_crop,"
        )
        ops = _ops(engine, r.json()["id"])
        assert [(n, p.get("version_id"), p.get("schema_prefix"), p.get("release_only")) for n, p, _ in ops] == [
            ("uninstall", w.i_ecm, "ecm_", None), ("install", w.b_ecm, "", None),
        ]

    def test_already_installed_over_it_is_release_only(self, engine, client_with_agent, mock_ws):
        w = self._world(engine)
        with Session(engine) as s:
            mark_version_deployed(s, s.get(ModelVersion, w.b_ecm), CAT)
            s.commit()
        _listing(mock_ws, "ecm_crop")
        _ws_with_run_now(mock_ws)
        r = _create(client_with_agent, w.kick, _install_body(w.b_ecm))
        assert r.status_code == 200, r.text
        assert _rule1(r.json()["warnings"]) == []
        ops = _ops(engine, r.json()["id"])
        assert [(n, p.get("version_id"), p.get("release_only")) for n, p, _ in ops] == [
            ("uninstall", w.i_ecm, True), ("install", w.b_ecm, None),
        ]
        mock_ws.jobs.run_now.assert_not_called()


class TestRule2IndustryWhereItsBusinessIsInstalled:
    def test_an_install_of_the_industry_is_refused_and_writes_nothing(self, engine, client_with_agent, world):
        with Session(engine) as s:
            mark_version_deployed(s, s.get(ModelVersion, world.b_ecm), THIRD)
            s.commit()
        out = _validate(client_with_agent, world.industry, _install_body(world.i_ecm, THIRD))
        [blocker] = [b for b in out["blockers"] if "kickstarted from this industry" in b["message"]]
        assert blocker["message"] == (
            "WT-Kick, kickstarted from this industry, is installed in third_cat. "
            "Install the industry into another catalog."
        )
        before = table_digests(engine)
        r = _create(client_with_agent, world.industry, _install_body(world.i_ecm, THIRD))
        assert r.status_code == 400, r.text
        assert r.json()["detail"] == blocker["message"]
        assert table_digests(engine) == before

    def test_a_full_run_of_the_industry_is_refused(self, engine, client_with_agent, world):
        with Session(engine) as s:
            mark_version_deployed(s, s.get(ModelVersion, world.b_mvm), CAT)
            s.commit()
        out = _validate(client_with_agent, world.industry, _vibe_body(world.i_ecm))
        assert any(
            b["message"] == "WT-Kick, kickstarted from this industry, is installed in business_1. "
                            "Run the industry against another catalog."
            for b in out["blockers"]
        )

    def test_a_business_with_only_its_files_there_does_not_block(self, engine, client_with_agent, world):
        """WT-Kick's files and seeded rows are in business_1; it is installed nowhere."""
        out = _validate(client_with_agent, world.industry, _install_body(world.i_ecm))
        assert not [b for b in out["blockers"] if "kickstarted" in b["message"]]


class TestSameBusinessOtherScope:
    """M3: ECM and MVM of one business with the same names in one catalog."""

    def _bare(self, engine):
        with Session(engine) as s:
            b = Business(name="Bare Co", description="d")
            s.add(b)
            s.flush()
            # A Dry Run draft installs with its file's own (here blank) prefix.
            ecm = _version(s, b, 1, "ecm", (), dry_run=True)
            ecm.status = "draft"
            mvm = _version(s, b, 1, "mvm", ())
            for mv in (ecm, mvm):
                s.add(Domain(version_id=mv.id, name="crop", database_name="crop"))
            mark_version_deployed(s, mvm, CAT)
            s.commit()
            return b.id, ecm.id

    def test_the_second_scope_is_refused_and_writes_nothing(self, engine, client_with_agent, mock_ws):
        biz, ecm = self._bare(engine)
        _listing(mock_ws, "crop")
        _ws_with_run_now(mock_ws)
        expected = (
            "v1 MVM of this business is installed in business_1 under the same schema names as this "
            "install: crop. The agent would replace its tables. Install into another catalog, or "
            "uninstall v1 MVM first."
        )
        out = _validate(client_with_agent, biz, _install_body(ecm))
        assert expected in [b["message"] for b in out["blockers"]]
        before = table_digests(engine)
        r = _create(client_with_agent, biz, _install_body(ecm))
        assert r.status_code == 400, r.text
        assert r.json()["detail"] == expected
        assert table_digests(engine) == before

    def test_another_catalog_is_free(self, engine, client_with_agent, mock_ws):
        biz, ecm = self._bare(engine)
        _listing(mock_ws)
        _ws_with_run_now(mock_ws)
        out = _validate(client_with_agent, biz, _install_body(ecm, OTHER))
        assert not [b for b in out["blockers"] if "of this business is installed" in b["message"]]

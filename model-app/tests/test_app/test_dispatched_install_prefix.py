"""Uninstall targets the schema prefix the install dispatched.

A scoped install can dispatch its file's prefix (e.g. ``mvm_v2_``) instead
of the derived ``mvm_``. ``uninstall`` and the uninstall step
of an install over another version read that prefix back from ``RunOperation.dispatched_widgets_json``
(``services/dispatched_widgets.py``) and fall back to the derived default
when no install is recorded.
"""

from __future__ import annotations

import json
import os
import sys
from datetime import datetime, timedelta, timezone
from types import SimpleNamespace
from typing import Optional

import pytest
from sqlmodel import Session, select

sys.path.insert(
    0,
    os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"),
)

from vibe_modeling.backend.db_models import (  # noqa: E402
    Business,
    ModelVersion,
    Run,
    RunOperation,
)
from vibe_modeling.backend.services.uninstall_impact import uninstall_confirm_subject
from vibe_modeling.backend.services.dispatched_widgets import (  # noqa: E402
    dispatched_schema_affixes_for_version,
    install_widgets_into,
    installed_schema_prefix,
    latest_install_widgets,
)
from vibe_modeling.backend.services.orchestrator.dag_factories._simple import (  # noqa: E402
    dag_for_uninstall,
)


def _seed_versions(engine, *, scope: str = "mvm") -> tuple[str, dict[int, str]]:
    """Business + v2 (uninstalled) + v3 (deployed), both ``scope``."""
    with Session(engine) as s:
        b = Business(name="ridgeline_energy", description="t", industry_alignment="Energy")
        s.add(b)
        s.flush()
        ids: dict[int, str] = {}
        for n in (2, 3):
            mv = ModelVersion(
                business_id=b.id, version=n, status="completed", scope=scope,
                uc_catalog="ridgeline_cat",
                deployment_status="deployed" if n == 3 else "uninstalled",
            )
            s.add(mv)
            s.flush()
            ids[n] = mv.id
        s.commit()
        return b.id, ids


def _record_op(
    engine,
    business_id: str,
    version_id: str,
    widgets: Optional[dict],
    *,
    operation_name: str = "install",
    status: str = "succeeded",
    age_s: int = 0,
) -> None:
    """Persist a one-op run whose op consumed ``version_id``."""
    with Session(engine) as s:
        run = Run(business_id=business_id, version_id=version_id, intent="install", status="completed")
        s.add(run)
        s.flush()
        s.add(
            RunOperation(
                run_id=run.id, step_index=0, operation_name=operation_name,
                status=status, parent_version_id=version_id,
                dispatched_widgets_json=json.dumps(widgets) if widgets is not None else "{}",
                created_at=datetime.now(timezone.utc) - timedelta(seconds=age_s),
            )
        )
        s.commit()


def _install_widgets(prefix: str, style: str = "One Catalog", **extra) -> dict:
    return {"operation": "install model", "schema_prefix": prefix, "cataloging_style": style, **extra}


# ---------------------------------------------------------------------------
# services/dispatched_widgets.py
# ---------------------------------------------------------------------------


class TestLatestInstallWidgets:
    def test_none_without_version_or_install(self, engine):
        biz, ids = _seed_versions(engine)
        with Session(engine) as s:
            assert latest_install_widgets(s, None) is None
            assert latest_install_widgets(s, ids[3]) is None

    def test_picks_newest_succeeded_install(self, engine):
        biz, ids = _seed_versions(engine)
        _record_op(engine, biz, ids[3], _install_widgets("mvm_"), age_s=300)
        _record_op(engine, biz, ids[3], _install_widgets("mvm_v2_"), age_s=60)
        _record_op(engine, biz, ids[3], _install_widgets("zzz_"), status="failed")
        _record_op(
            engine, biz, ids[3],
            {"operation": "uninstall model version", "schema_prefix": "yyy_"},
            operation_name="uninstall",
        )
        _record_op(engine, biz, ids[3], None)  # pre-E-03 row, no widgets
        with Session(engine) as s:
            assert latest_install_widgets(s, ids[3])["schema_prefix"] == "mvm_v2_"

    def test_read_error_falls_back(self):
        class _Broken:
            def exec(self, *_a, **_k):
                raise RuntimeError("db down")

        assert latest_install_widgets(_Broken(), "v") is None
        assert dispatched_schema_affixes_for_version(_Broken(), "v") == ([], [])


class TestInstallWidgetsInto:
    def test_newest_succeeded_install_into_the_catalog_only(self, engine):
        biz, ids = _seed_versions(engine)
        _record_op(engine, biz, ids[3], _install_widgets("mvm_", deployment_catalog="cat_a"), age_s=300)
        _record_op(engine, biz, ids[3], _install_widgets("", deployment_catalog="cat_b"), age_s=60)
        _record_op(
            engine, biz, ids[3], _install_widgets("zzz_", deployment_catalog="cat_a"), status="failed",
        )
        with Session(engine) as s:
            assert install_widgets_into(s, ids[3], "CAT_A")["schema_prefix"] == "mvm_"
            assert install_widgets_into(s, ids[3], "cat_b")["schema_prefix"] == ""
            assert install_widgets_into(s, ids[3], "cat_c") is None
            assert install_widgets_into(s, ids[3], None) is None
            assert latest_install_widgets(s, ids[3], "cat_c")["deployment_catalog"] == "cat_b"


class TestInstalledSchemaPrefix:
    def test_same_style_returns_prefix(self):
        assert installed_schema_prefix(_install_widgets("mvm_v2_"), "One Catalog") == "mvm_v2_"

    def test_catalog_per_style_empty_prefix(self):
        w = _install_widgets("", "Catalog per Domain")
        assert installed_schema_prefix(w, "Catalog per Domain") == ""

    @pytest.mark.parametrize(
        "widgets",
        [None, {}, {"operation": "install model", "cataloging_style": "One Catalog"}],
    )
    def test_no_recorded_prefix(self, widgets):
        assert installed_schema_prefix(widgets, "One Catalog") is None

    def test_other_style_is_ignored(self):
        assert installed_schema_prefix(_install_widgets("", "Catalog per Domain"), "One Catalog") is None
        assert installed_schema_prefix(_install_widgets("mvm_"), "Catalog per Domain") is None

    def test_missing_style_means_one_catalog(self):
        w = {"schema_prefix": "mvm_v2_"}
        assert installed_schema_prefix(w, "One Catalog") == "mvm_v2_"


def test_drift_probe_unions_scoped_install_suffix(engine):
    """A scoped install now carries ``schema_suffix``; the drift probe's
    affix reader picks it up alongside the generation op's."""
    biz, ids = _seed_versions(engine)
    _record_op(engine, biz, ids[3], _install_widgets("mvm_v2_", schema_suffix="_wt"))
    with Session(engine) as s:
        prefixes, suffixes = dispatched_schema_affixes_for_version(s, ids[3])
    assert prefixes == ["mvm_v2_"]
    assert suffixes == ["_wt"]


def _record_link(
    engine, business_id: str, widgets: dict, *, operation_name: str,
    parent: Optional[str] = None, output: Optional[str] = None, status: str = "succeeded",
) -> None:
    """One op linked to versions the way the orchestrator stamps them."""
    with Session(engine) as s:
        run = Run(business_id=business_id, version_id=parent or output, intent="vibe-iterate", status="completed")
        s.add(run)
        s.flush()
        s.add(RunOperation(
            run_id=run.id, step_index=0, operation_name=operation_name, status=status,
            parent_version_id=parent, output_version_id=output,
            dispatched_widgets_json=json.dumps(widgets),
        ))
        s.commit()


class TestAffixesCountOnlyWhatDeployedTheVersion:
    """E-12: a version's affixes come from its succeeded generation and its
    succeeded installs, not from a failed install or a child run."""

    def test_a_failed_install_adds_nothing(self, engine):
        biz, ids = _seed_versions(engine)
        _record_link(engine, biz, {"schema_prefix": ""}, operation_name="vibe_iterate", output=ids[3])
        _record_link(
            engine, biz, _install_widgets("mvm_", deployment_catalog="business_2"),
            operation_name="install", parent=ids[3], status="failed",
        )
        with Session(engine) as s:
            assert dispatched_schema_affixes_for_version(s, ids[3]) == ([""], [])

    def test_a_child_run_adds_nothing(self, engine):
        """A shrink or vibe run that read v2 (parent) and made v3 (output)
        carries v3's prefix; v2 keeps its own."""
        biz, ids = _seed_versions(engine)
        _record_link(engine, biz, {"schema_prefix": "ecm_", "schema_suffix": "_a"},
                     operation_name="generate_ecm", output=ids[2])
        _record_link(engine, biz, {"schema_prefix": "mvm_", "schema_suffix": "_b"},
                     operation_name="shrink_ecm", parent=ids[2], output=ids[3])
        with Session(engine) as s:
            assert dispatched_schema_affixes_for_version(s, ids[2]) == (["ecm_"], ["_a"])
            assert dispatched_schema_affixes_for_version(s, ids[3]) == (["mvm_"], ["_b"])

    def test_succeeded_installs_and_generation_still_union(self, engine):
        biz, ids = _seed_versions(engine)
        _record_link(engine, biz, {"schema_prefix": ""}, operation_name="vibe_iterate", output=ids[3])
        _record_op(engine, biz, ids[3], _install_widgets("mvm_", deployment_catalog="business_2"))
        _record_op(engine, biz, ids[3], _install_widgets("zzz_"), status="failed")
        _record_op(
            engine, biz, ids[3], {"schema_prefix": "yyy_"}, operation_name="uninstall",
        )
        _record_link(
            engine, biz, {"schema_prefix": "xxx_"}, operation_name="vibe_iterate",
            parent=ids[3], output=ids[2],
        )
        with Session(engine) as s:
            prefixes, suffixes = dispatched_schema_affixes_for_version(s, ids[3])
        assert sorted(prefixes) == ["", "mvm_"]
        assert suffixes == []


    def test_an_install_does_not_take_a_child_runs_prefix(self, engine):
        """The ECM's affixes are its generation's ``ecm_``, not the child
        shrink's ``mvm_`` (read first); an install takes neither, its prefix
        comes from the version's model file at dispatch."""
        from vibe_modeling.backend.services.orchestrator.dag_factories._simple import install_schema_prefix

        biz, ids = _seed_versions(engine, scope="ecm")
        _record_link(engine, biz, {"schema_prefix": "mvm_"}, operation_name="shrink_ecm",
                     parent=ids[3], output=ids[2])
        _record_link(engine, biz, {"schema_prefix": "ecm_"}, operation_name="generate_ecm", output=ids[3])
        with Session(engine) as s:
            mv = s.get(ModelVersion, ids[3])
            assert mv is not None
            assert dispatched_schema_affixes_for_version(s, ids[3])[0] == ["ecm_"]
        assert install_schema_prefix(SimpleNamespace()) == ("", "version")


# ---------------------------------------------------------------------------
# dag_for_uninstall
# ---------------------------------------------------------------------------


def _uninstall_prefix(req: dict, install_widgets: Optional[dict]) -> str:
    from vibe_modeling.backend.models import RunIn

    ctx = SimpleNamespace(
        parent_mv=SimpleNamespace(id="mv-3", scope="mvm", version=3, import_source_path=None),
        install_widgets=install_widgets,
    )
    dag = dag_for_uninstall(
        RunIn(intent="uninstall", catalog="ridgeline_cat", **req),
        SimpleNamespace(name="ridgeline_energy"),
        ctx,
    )
    return dag.steps[0].params["schema_prefix"]


class TestDagForUninstall:
    def test_uses_installed_prefix(self):
        assert _uninstall_prefix({}, _install_widgets("mvm_v2_")) == "mvm_v2_"

    def test_explicit_request_wins(self):
        assert _uninstall_prefix({"schema_prefix": "custom_"}, _install_widgets("mvm_v2_")) == "custom_"

    def test_no_install_recorded_derives(self):
        assert _uninstall_prefix({}, None) == "mvm_"

    def test_install_in_other_style_derives(self):
        assert _uninstall_prefix({}, _install_widgets("", "Catalog per Domain")) == "mvm_"

    def test_ctx_without_install_widgets_derives(self):
        from vibe_modeling.backend.models import RunIn

        dag = dag_for_uninstall(
            RunIn(intent="uninstall", catalog="ridgeline_cat"),
            SimpleNamespace(name="ridgeline_energy"),
            SimpleNamespace(parent_mv=SimpleNamespace(id="mv-3", scope="mvm", version=3)),
        )
        assert dag.steps[0].params["schema_prefix"] == "mvm_"


def test_post_uninstall_targets_installed_prefix(engine, client_with_agent, mock_ws):
    biz, ids = _seed_versions(engine)
    _record_op(engine, biz, ids[3], _install_widgets("mvm_v2_"))
    run = mock_ws.jobs.run_now.return_value
    run.run_id = run.response.run_id = 5150

    resp = client_with_agent.post(
        f"/api/businesses/{biz}/runs",
        json={"intent": "uninstall", "version_id": ids[3], "catalog": "ridgeline_cat",
              "confirmed_issues": [uninstall_confirm_subject(ids[3], "ridgeline_cat")]},
    )
    assert resp.status_code == 200, resp.text
    with Session(engine) as s:
        op = s.exec(
            select(RunOperation).where(RunOperation.run_id == resp.json()["id"])
        ).one()
    assert json.loads(op.params_json)["schema_prefix"] == "mvm_v2_"
    assert json.loads(op.dispatched_widgets_json)["schema_prefix"] == "mvm_v2_"


# ---------------------------------------------------------------------------
# install of a version last installed without a prefix
# ---------------------------------------------------------------------------


def test_a_typed_blank_install_of_the_same_version_is_refused(
    engine, client_with_agent, mock_ws,
):
    """v2 was last installed with ``""`` in One Catalog (an unprefixed
    industry or kickstarted draft); typing a blank prefix is still refused."""
    biz, ids = _seed_versions(engine)
    _record_op(engine, biz, ids[3], _install_widgets("mvm_"))
    _record_op(engine, biz, ids[2], _install_widgets(""))
    with Session(engine) as s:
        before = len(s.exec(select(Run)).all())
    resp = client_with_agent.post(
        f"/api/businesses/{biz}/runs",
        json={"intent": "install", "version_id": ids[2], "scope": "mvm",
              "catalog": "ridgeline_cat", "cataloging_style": "One Catalog",
              "schema_prefix": ""},
    )
    assert resp.status_code == 400, resp.text
    assert "non-empty schema_prefix" in resp.text
    with Session(engine) as s:
        assert len(s.exec(select(Run)).all()) == before
    mock_ws.jobs.run_now.assert_not_called()

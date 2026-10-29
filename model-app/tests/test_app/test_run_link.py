"""Link an imported version to its Databricks run (``backend/run_link.py``,
``routes/run_link.py``, the import routes' ``databricks_run_id``).

The Jobs API answers are the captured ``get_run`` responses of one
app-launched New Base Model on agent 5.3.3
(``tests/fixtures/jobs_get_run_5_3_3.json``: ``new base model`` wrote ECM v1,
``shrink ecm`` wrote MVM v1, business ``wt_p0_grain_coop`` in catalog
``business_3``). Registry rows are the agent's own ``business`` row
(``agent_shapes/agent_5_3_3.json``, ``run_start`` with the
``_finalize_session`` update applied) keyed and stored per catalog; the
Session Started events are the agent's ``emit_step`` record (cell 124,
lines 1492-1507, the ``_vibe_progress`` columns of cell 116). The fake
answers the SQL the module sends (``core/_sql.rows``) over rows kept per
catalog, with the agent's matching rule.
"""

from __future__ import annotations

import copy
import json
import re
import os
import sys
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Optional
from unittest.mock import MagicMock

import pytest
from sqlalchemy import event
from databricks.sdk.errors import NotFound, PermissionDenied
from databricks.sdk.service.jobs import Run as JobRun
from fastapi.testclient import TestClient
from sqlmodel import Session, select

from vibe_modeling.backend import run_link
from vibe_modeling.backend.core._defaults import _ConfigDependency, _WorkspaceClientDependency
from vibe_modeling.backend.core._names import metamodel_display_business
from vibe_modeling.backend.core._roles import UserRole, resolve_user_role
from vibe_modeling.backend.core.lakebase import _LakebaseDependency
from vibe_modeling.backend.db_models import AgentConfig, Business, ModelVersion, Run, RunOperation

sys.path.insert(0, os.path.dirname(__file__))
from _assess_helpers import changed_tables, table_digests  # noqa: E402
from _test_app import make_test_app  # noqa: E402

FIXTURES = Path(__file__).resolve().parents[1] / "fixtures"
GET_RUN = json.loads((FIXTURES / "jobs_get_run_5_3_3.json").read_text())["runs"]
AGENT_5_3_3 = json.loads((FIXTURES / "agent_shapes" / "agent_5_3_3.json").read_text())

CAT = "business_3"
SEGMENT = "wt_p0_grain_coop"
BASE_RUN = GET_RUN["new_base_model"]
SHRINK_RUN = GET_RUN["shrink_ecm"]
BASE_ID = BASE_RUN["run_id"]
SHRINK_ID = SHRINK_RUN["run_id"]
BASE_SID = int(BASE_RUN["overriding_parameters"]["notebook_params"]["vibe_session_id"])
SHRINK_SID = int(SHRINK_RUN["overriding_parameters"]["notebook_params"]["vibe_session_id"])
AFTER_BOTH = datetime.fromtimestamp(SHRINK_RUN["end_time"] / 1000, tz=timezone.utc) + timedelta(hours=1)


def model_json_path(scope: str, version: int = 1, catalog: str = CAT, segment: str = SEGMENT) -> str:
    return f"/Volumes/{catalog}/_metamodel/vol_root/business/{segment}/v{version}/{scope}/model.json"


def job_run(raw: dict, **notebook_params: str) -> JobRun:
    """A captured response as the SDK returns it; ``notebook_params`` edits
    widget values (synthetic variants are labelled at their call sites)."""
    raw = copy.deepcopy(raw)
    raw["overriding_parameters"]["notebook_params"].update(notebook_params)
    return JobRun.from_dict(raw)


def registry_row(*, catalog: str, version: int, scope: str, session_id: Optional[int], completion: str) -> dict:
    """The agent's finished ``business`` row of a run (5.3.3 cell 124 INSERT,
    cell 116 ``_finalize_session``)."""
    row = dict(AGENT_5_3_3["business_rows"]["run_start"]["values"])
    row.update(
        business=metamodel_display_business(SEGMENT), version=str(version), model_scope=scope, catalog=catalog,
        location=f"/Volumes/{catalog}/_metamodel/vol_root/business/{SEGMENT}/v{version}/{scope}",
        session_id=None if session_id is None else str(session_id), processing_status="done",
        completed_percent="100.0", completion_date=completion,
    )
    return row


SCOPE_LABEL = {"ecm": "Expanded Coverage Model - ECM", "mvm": "Minimum Viable Model - MVM"}


def session_started(*, session_id: int, operation: str, version: int, widget_scope: str, catalog: str, at: str) -> dict:
    """A ``Vibe Session / Session Started`` row: ``result_json`` as cell 124
    lines 1498-1507 build it (``business_name`` title-cased, line 196;
    ``model_scope`` is the ``data_model_scopes`` widget). The lifecycle form
    (cell 118, lines 299-305) has the same keys that matter here."""
    return {
        "session_id": str(session_id), "stage_name": "Vibe Session", "step_name": "Session Started", "at": at,
        "result_json": json.dumps({
            "session_id": session_id, "business_name": SEGMENT.title(), "operation": operation,
            "version": str(version), "model_scope": SCOPE_LABEL[widget_scope], "deploy_catalog": catalog,
            "llm_endpoint": "", "industry_alignment": "Agriculture",
        }),
    }


_FROM = re.compile(r"FROM `(?P<cat>[^`]+)`\.`_metamodel`\.`(?P<table>[^`]+)`")


class FakeRegistry:
    """``<catalog>._metamodel.business`` and ``_vibe_progress`` rows per
    catalog. Answers the module's two queries: the business rows of a key
    (``LOWER(business)``, bare version, short scope) and the Session Started
    events of a session id list."""

    def __init__(self) -> None:
        self.business: dict[str, list[dict]] = {}
        self.progress: dict[str, list[dict]] = {}
        self.reads: list[tuple[str, str]] = []
        self.fail = False

    def add(self, catalog: str, row: dict) -> None:
        self.business.setdefault(catalog, []).append(row)
        self.progress.setdefault(catalog, [])

    def event(self, catalog: str, row: dict) -> None:
        self.progress.setdefault(catalog, []).append(row)
        self.business.setdefault(catalog, [])

    def rows(self, ws, warehouse_id, sql, params=None, **_):
        m = _FROM.search(sql)
        catalog, table = m.group("cat"), m.group("table")
        self.reads.append((catalog, table))
        if self.fail:
            from vibe_modeling.backend.core._sql import SqlStatementError
            raise SqlStatementError("FAILED", "warehouse stopped")
        if table == "_vibe_progress":
            if catalog not in self.progress:
                return None
            ids = {i.strip() for i in re.search(r"session_id IN \(([^)]*)\)", sql).group(1).split(",")}
            return [
                {k: r[k] for k in ("session_id", "at", "result_json")}
                for r in self.progress[catalog]
                if r["session_id"] in ids and r["stage_name"] == "Vibe Session" and r["step_name"] == "Session Started"
            ]
        if catalog not in self.business:
            return None
        return [
            {"session_id": r.get("session_id")}
            for r in self.business[catalog]
            if str(r.get("business") or "").lower() == params["business"].lower()
            and r.get("version") == params["version"] and r.get("model_scope") == params["scope"]
        ]


@pytest.fixture
def registry(monkeypatch) -> FakeRegistry:
    fake = FakeRegistry()
    monkeypatch.setattr(run_link, "rows", fake.rows)
    return fake


@pytest.fixture
def ws():
    ws = MagicMock()
    ws.config.host = "https://test-workspace.databricks.com"
    runs = {BASE_ID: job_run(BASE_RUN), SHRINK_ID: job_run(SHRINK_RUN)}

    def get_run(run_id):
        if run_id not in runs:
            raise NotFound(f"Run {run_id} does not exist.")
        return runs[run_id]

    ws.jobs.get_run.side_effect = get_run
    ws.runs = runs
    return ws


@pytest.fixture
def business(engine) -> str:
    with Session(engine) as s:
        s.add(AgentConfig(notebook_path="/nb", job_id=1, deployment_catalog=CAT, warehouse_id="wh"))
        b = Business(name="WT P0 Grain Coop")
        s.add(b)
        s.commit()
        return b.id


def imported_version(engine, business_id: str, scope: str, *, path: Optional[str] = None, version: int = 1) -> str:
    with Session(engine) as s:
        mv = ModelVersion(
            business_id=business_id, version=version, scope=scope, status="completed",
            import_source_path=path or model_json_path(scope, version), imported_at=AFTER_BOTH,
            files_catalog=CAT, completion_date=AFTER_BOTH,
        )
        s.add(mv)
        s.commit()
        return mv.id


def oob_version(
    engine, business_id: str, scope: str, *, version: int = 1, catalog: Optional[str] = CAT,
    created_at: datetime = AFTER_BOTH,
) -> str:
    """A version as ``initial_sync._write_version`` writes it: the files
    catalog, no ``import_source_path``, no ``imported_at``, no run."""
    with Session(engine) as s:
        mv = ModelVersion(
            business_id=business_id, version=version, scope=scope, status="completed",
            files_catalog=catalog, created_at=created_at,
        )
        s.add(mv)
        s.commit()
        return mv.id


def app_version(engine, business_id: str, scope: str, *, version: int = 1) -> str:
    """A version an app run produced: its RunOperation's ``output_version_id``."""
    with Session(engine) as s:
        mv = ModelVersion(
            business_id=business_id, version=version, scope=scope, status="completed", files_catalog=CAT,
            created_at=AFTER_BOTH,
        )
        s.add(mv)
        s.flush()
        run = Run(business_id=business_id, intent="vibe-iterate", status="completed")
        s.add(run)
        s.flush()
        s.add(RunOperation(
            run_id=run.id, step_index=0, operation_name="vibe_iterate", status="succeeded", output_version_id=mv.id,
        ))
        s.commit()
        return mv.id


# App runs that point at an existing version without producing it:
# (intent, status, operation_name or None). ``Run.version_id`` is their
# target or parent (router.py install / vibe, github_publish._record_publish_run).
RUNS_ON_A_VERSION = [
    pytest.param("install", "completed", "install", id="install"),
    pytest.param("vibe-iterate", "failed", "vibe_iterate", id="failed-vibe"),
    pytest.param("publish-to-github", "completed", None, id="publish"),
]


def run_on_version(engine, business_id: str, version_id: str, intent: str, status: str, operation: Optional[str]) -> None:
    with Session(engine) as s:
        run = Run(business_id=business_id, version_id=version_id, intent=intent, status=status)
        s.add(run)
        s.flush()
        if operation:
            s.add(RunOperation(
                run_id=run.id, step_index=0, operation_name=operation,
                status="succeeded" if status == "completed" else "failed", parent_version_id=version_id,
            ))
        s.commit()


def both_written(registry: FakeRegistry, catalog: str = CAT) -> None:
    """The pair's Session Started events and business rows, plus the session 0
    rows the imports seeded."""
    registry.event(catalog, session_started(session_id=BASE_SID, operation="new base model", version=1,
                                            widget_scope="ecm", catalog=catalog, at="2026-10-24 03:50:40.000"))
    registry.event(catalog, session_started(session_id=SHRINK_SID, operation="shrink ecm", version=1,
                                            widget_scope="mvm", catalog=catalog, at="2026-10-24 04:17:30.000"))
    registry.add(catalog, registry_row(catalog=catalog, version=1, scope="ecm", session_id=BASE_SID,
                                       completion="2026-10-24 04:16:50"))
    registry.add(catalog, registry_row(catalog=catalog, version=1, scope="mvm", session_id=SHRINK_SID,
                                       completion="2026-10-24 04:29:54"))
    registry.add(catalog, registry_row(catalog=catalog, version=1, scope="ecm", session_id=0,
                                       completion="2026-10-25 09:00:00"))


def stamp_ecm_row(registry: FakeRegistry, session_id: Optional[int]) -> None:
    """What a lifecycle run leaves on the ECM v1 business row: an install
    re-registers it with no session (cell 118, lines 444-466), an uninstall
    stamps its own (cell 118, lines 288-298; cell 116, lines 447-457)."""
    for row in registry.business[CAT]:
        if row["model_scope"] == "ecm" and row["session_id"] == str(BASE_SID):
            row["session_id"] = None if session_id is None else str(session_id)

def client(engine, ws, config, role: UserRole = UserRole.APP_ADMIN) -> TestClient:
    app = make_test_app()

    def override_session():
        with Session(engine) as session:
            yield session

    app.dependency_overrides[_LakebaseDependency.__call__] = override_session
    app.dependency_overrides[_ConfigDependency.__call__] = lambda: config
    app.dependency_overrides[_WorkspaceClientDependency.__call__] = lambda: ws
    app.dependency_overrides[resolve_user_role] = lambda: role
    return TestClient(app)


def preview(c: TestClient, bid: str, vid: str, run_id: int):
    return c.post(f"/api/businesses/{bid}/versions/{vid}/link-run/preview", json={"databricks_run_id": run_id})


def link(c: TestClient, bid: str, vid: str, run_id: int):
    return c.post(f"/api/businesses/{bid}/versions/{vid}/link-run", json={"databricks_run_id": run_id})


def runs_of(engine, bid: str) -> list[tuple[Run, list[RunOperation]]]:
    with Session(engine) as s:
        out = []
        for run in s.exec(select(Run).where(Run.business_id == bid)).all():
            ops = s.exec(select(RunOperation).where(RunOperation.run_id == run.id).order_by(RunOperation.step_index)).all()
            out.append((run, list(ops)))
        return out


class TestRunParameters:

    def test_app_run_now_params_come_from_overriding_parameters(self):
        params = run_link.run_parameters(job_run(BASE_RUN))
        assert params["operation"] == "new base model"
        assert params["vibe_session_id"] == str(BASE_SID)
        assert params["deployment_catalog"] == CAT

    def test_a_job_the_agent_launched_carries_them_as_base_parameters(self):
        # Synthetic: the captured widgets moved to the task's base_parameters,
        # where the agent's Job Launch Gate puts them (nb cell 5, lines 186, 223).
        raw = copy.deepcopy(BASE_RUN)
        widgets = raw.pop("overriding_parameters")["notebook_params"]
        raw["tasks"][0]["notebook_task"]["base_parameters"] = widgets
        agent_run = run_link.agent_run_from(JobRun.from_dict(raw))
        assert agent_run.operation == "new base model" and agent_run.session_id == BASE_SID
        assert agent_run.output_scope == "ecm" and agent_run.registry_catalog == CAT

    def test_resize_scope_and_metamodel_catalog_override(self):
        assert run_link.agent_run_from(job_run(SHRINK_RUN)).output_scope == "mvm"
        assert run_link.agent_run_from(job_run(SHRINK_RUN, metamodel_catalog=" meta_cat ")).registry_catalog == "meta_cat"


class TestPreview:

    def test_tier1_session_match_writes_nothing(self, engine, ws, config, business, registry):
        both_written(registry)
        vid = imported_version(engine, business, "ecm")
        before = table_digests(engine)
        resp = preview(client(engine, ws, config), business, vid, BASE_ID)
        assert resp.status_code == 200, resp.text
        body = resp.json()
        assert body["linkable"] is True and body["tier"] == 1 and body["intent"] == "new-base-model"
        assert body["problems"] == []
        assert changed_tables(before, table_digests(engine)) == set()

    @pytest.mark.parametrize("lifecycle", ["install", "uninstall"])
    def test_tier1_survives_an_install_or_uninstall(self, engine, ws, config, business, registry, lifecycle):
        both_written(registry)
        if lifecycle == "install":
            stamp_ecm_row(registry, None)
        else:
            stamp_ecm_row(registry, 77)
            registry.event(CAT, session_started(session_id=77, operation="uninstall model version", version=1,
                                                widget_scope="ecm", catalog=CAT, at="2026-10-25 10:00:00.000"))
        vid = imported_version(engine, business, "ecm")
        body = preview(client(engine, ws, config), business, vid, BASE_ID).json()
        assert body["linkable"] is True and body["tier"] == 1, body

    def test_tier1_refuses_a_later_model_run_of_the_same_version(self, engine, ws, config, business, registry):
        both_written(registry)
        stamp_ecm_row(registry, 123)
        registry.event(CAT, session_started(session_id=123, operation="new base model", version=1,
                                            widget_scope="ecm", catalog=CAT, at="2026-10-24 06:00:00.000"))
        vid = imported_version(engine, business, "ecm")
        body = preview(client(engine, ws, config), business, vid, BASE_ID).json()
        assert body["linkable"] is False and body["tier"] is None
        assert body["problems"] == [
            f"This run didn't write the current v1 ECM in {CAT}: a later run (new base model) wrote it again, "
            "so this import may be that run's output."
        ]

    def test_tier1_refuses_a_run_that_wrote_another_version(self, engine, ws, config, business, registry):
        registry.event(CAT, session_started(session_id=BASE_SID, operation="new base model", version=2,
                                            widget_scope="ecm", catalog=CAT, at="2026-10-24 03:50:40.000"))
        vid = imported_version(engine, business, "ecm")
        body = preview(client(engine, ws, config), business, vid, BASE_ID).json()
        assert body["problems"] == [
            f"This run wrote v2 ECM of {SEGMENT}, not v1 ECM of {SEGMENT}."
        ]

    def test_tier2_when_the_registry_has_no_record(self, engine, ws, config, business, registry):
        vid = imported_version(engine, business, "ecm")
        body = preview(client(engine, ws, config), business, vid, BASE_ID).json()
        assert body["linkable"] is True and body["tier"] == 2
        assert body["evidence"] == [
            f"The agent's registry in {CAT} has no start record of this run.",
            f"Best effort: matched the import folder /Volumes/{CAT}/_metamodel/vol_root/business/{SEGMENT}/v1/ecm, "
            f"business {SEGMENT}, scope ECM and catalog {CAT}.",
            "The version is not checked: a new base model takes the next free number, and a vibe with no "
            "base version picks the latest one.",
            "A later run of the same version writes the same folder.",
        ]

    def test_tier2_when_the_registry_cannot_be_read(self, engine, ws, config, business, registry):
        registry.fail = True
        vid = imported_version(engine, business, "ecm")
        body = preview(client(engine, ws, config), business, vid, BASE_ID).json()
        assert body["tier"] == 2
        assert body["evidence"][0].startswith("The agent's registry could not be read:")

    def test_tier2_holds_a_vibe_to_the_version_after_its_base(self, engine, ws, config, business, registry):
        # Synthetic: the captured base run relabelled as a vibe of v1.
        ws.runs[BASE_ID] = job_run(BASE_RUN, operation="vibe modeling of version", model_version="1")
        c = client(engine, ws, config)
        v2 = imported_version(engine, business, "ecm", version=2)
        v3 = imported_version(engine, business, "ecm", version=3)
        ok = preview(c, business, v2, BASE_ID).json()
        assert ok["tier"] == 2 and "version v2 (the version after its base v1)" in ok["evidence"][1]
        assert preview(c, business, v3, BASE_ID).json()["problems"] == [
            "The run vibed v1, so it would write v2, not v3."
        ]

    def test_tier2_refuses_a_folder_the_run_did_not_write(self, engine, ws, config, business, registry):
        vid = imported_version(engine, business, "ecm", path=model_json_path("ecm", segment="other_biz"))
        body = preview(client(engine, ws, config), business, vid, BASE_ID).json()
        assert body["linkable"] is False
        assert "This version was not imported from the folder the run writes." in body["problems"]

    def test_a_blank_installation_catalog_resolves_as_the_agent_does(self, engine, ws, config, business, registry):
        """Installation Catalog left blank: the agent writes under the business
        segment (cell 124, lines 235-242)."""
        ws.runs[BASE_ID] = job_run(BASE_RUN, deployment_catalog="")
        both_written(registry, catalog=SEGMENT)
        vid = imported_version(engine, business, "ecm", path=model_json_path("ecm", catalog=SEGMENT))
        body = preview(client(engine, ws, config), business, vid, BASE_ID).json()
        assert body["linkable"] is True and body["tier"] == 1, body
        assert registry.reads[0] == (SEGMENT, "_vibe_progress")

    @pytest.mark.parametrize("params,expected", [
        ({"deployment_catalog": "", "catalog_prefix": "dev_", "catalog_suffix": "_x"}, f"dev_{SEGMENT}_x"),
        ({"deployment_catalog": "", "cataloging_style": "Catalog per Domain"}, f"cat_{SEGMENT}"),
        ({"deployment_catalog": "${business}_home"}, f"{SEGMENT}_home"),
        ({"metamodel_catalog": "{business}_meta"}, f"{SEGMENT}_meta"),
    ])
    def test_registry_catalog_derivation(self, params, expected):
        assert run_link.agent_run_from(job_run(BASE_RUN, **params)).registry_catalog == expected

    def test_a_job_the_app_cannot_read_answers_admin_help(self, engine, ws, config, business, registry, monkeypatch):
        ws.jobs.get_run.side_effect = PermissionDenied("User does not have CAN VIEW on job 5")
        monkeypatch.setattr(run_link, "app_application_id", lambda _ws: "app-sp-application-id")
        vid = imported_version(engine, business, "ecm")
        resp = preview(client(engine, ws, config), business, vid, BASE_ID)
        assert resp.status_code == 409
        detail = resp.json()["detail"]
        assert detail["error"] == "admin_help" and detail["job_reader"] == "app-sp-application-id"
        assert "CAN VIEW on that job to app-sp-application-id" in detail["message"]
        assert detail["run_url"] == f"https://test-workspace.databricks.com/jobs/runs/{BASE_ID}"

    def test_hard_rejects(self, engine, ws, config, business, registry):
        both_written(registry)
        failed = copy.deepcopy(BASE_RUN)
        failed["run_id"] = 1
        failed["state"]["result_state"] = "FAILED"
        ws.runs[1] = JobRun.from_dict(failed)
        ws.runs[2] = job_run(BASE_RUN, operation="install model")  # synthetic: an install run
        ws.runs[2].run_id = 2
        vid = imported_version(engine, business, "ecm")
        c = client(engine, ws, config)
        assert preview(c, business, vid, 1).json()["problems"] == [
            "The run did not succeed (FAILED); its model.json may be partial."
        ]
        assert preview(c, business, vid, 2).json()["problems"] == [
            "The run's operation 'install model' does not produce a model version."
        ]
        with Session(engine) as s:
            mv = s.get(ModelVersion, vid)
            mv.imported_at = datetime.fromtimestamp(BASE_RUN["start_time"] / 1000, tz=timezone.utc)
            s.add(mv)
            s.commit()
        assert preview(c, business, vid, BASE_ID).json()["problems"] == [
            "The run ended after this version was imported, so the import cannot be its output."
        ]

    def test_unknown_run(self, engine, ws, config, business, registry):
        vid = imported_version(engine, business, "ecm")
        body = preview(client(engine, ws, config), business, vid, 42).json()
        assert body["linkable"] is False and body["problems"] == ["Databricks run 42 was not found."]

    def test_reads_the_run_registry_catalog_among_three(self, engine, ws, config, business, registry):
        """The same session's record sits in another catalog, a third has a
        different one; only the run's registry catalog is read."""
        registry.event("other_cat", session_started(session_id=BASE_SID, operation="new base model", version=1,
                                                    widget_scope="ecm", catalog="other_cat", at="2026-10-24 03:50:40.000"))
        registry.event("third_cat", session_started(session_id=BASE_SID, operation="new base model", version=4,
                                                    widget_scope="ecm", catalog="third_cat", at="2026-10-24 03:50:40.000"))
        registry.add(CAT, registry_row(catalog=CAT, version=1, scope="ecm", session_id=0, completion="2026-10-25 09:00:00"))
        vid = imported_version(engine, business, "ecm")
        c = client(engine, ws, config)
        body = preview(c, business, vid, BASE_ID).json()
        assert {cat for cat, _ in registry.reads} == {CAT} and body["tier"] == 2
        ws.runs[BASE_ID] = job_run(BASE_RUN, metamodel_catalog="other_cat")
        registry.reads.clear()
        body = preview(c, business, vid, BASE_ID).json()
        assert {cat for cat, _ in registry.reads} == {"other_cat"}
        assert body["problems"] == [
            f"The run wrote v1 ECM under /Volumes/other_cat/_metamodel/vol_root, but this version was imported "
            f"from /Volumes/{CAT}/_metamodel/vol_root/business/{SEGMENT}/v1/ecm."
        ]
        ws.runs[BASE_ID] = job_run(BASE_RUN, metamodel_catalog="third_cat")
        body = preview(c, business, vid, BASE_ID).json()
        assert body["problems"] == [f"This run wrote v4 ECM of {SEGMENT}, not v1 ECM of {SEGMENT}."]

    def test_tier2_refuses_another_files_catalog(self, engine, ws, config, business, registry):
        ws.runs[BASE_ID] = job_run(BASE_RUN, deployment_catalog="third_cat")
        vid = imported_version(engine, business, "ecm")
        body = preview(client(engine, ws, config), business, vid, BASE_ID).json()
        assert f"The run wrote into catalog 'third_cat', not '{CAT}'." in body["problems"]

class TestLink:

    def test_links_a_new_base_model_pair_as_one_run(self, engine, ws, config, business, registry):
        both_written(registry)
        ecm = imported_version(engine, business, "ecm")
        mvm = imported_version(engine, business, "mvm")
        c = client(engine, ws, config)
        first = link(c, business, ecm, BASE_ID)
        assert first.status_code == 200, first.text
        assert first.json()["intent"] == "new-base-model" and first.json()["linked_at"]
        second = link(c, business, mvm, SHRINK_ID)
        assert second.status_code == 200, second.text
        assert second.json()["id"] == first.json()["id"]

        ((run, ops),) = runs_of(engine, business)
        assert run.intent == "new-base-model" and run.status == "completed"
        assert run.databricks_run_id == BASE_ID and run.version_id == mvm
        assert run.vibe_session_id_bigint == BASE_SID
        assert [(o.step_index, o.operation_name, o.databricks_run_id, o.output_version_id, o.status) for o in ops] == [
            (0, "generate_ecm", BASE_ID, ecm, "succeeded"),
            (1, "shrink_to_mvm", SHRINK_ID, mvm, "succeeded"),
        ]
        assert ops[1].parent_version_id == ecm
        assert json.loads(ops[0].dispatched_widgets_json)["operation"] == "new base model"
        assert run.link_evidence.startswith("Tier 1:") and "Step 1, tier 1" in run.link_evidence
        assert "paired by version number, run order and the shrink's source version" in run.link_evidence

        versions = {v["id"]: v for v in c.get(f"/api/businesses/{business}/versions").json()}
        assert versions[ecm]["linked_run_id"] == run.id and versions[mvm]["linked_run_id"] == run.id

    def test_shrink_first_then_its_base_joins_the_same_run(self, engine, ws, config, business, registry):
        both_written(registry)
        ecm = imported_version(engine, business, "ecm")
        mvm = imported_version(engine, business, "mvm")
        c = client(engine, ws, config)
        alone = link(c, business, mvm, SHRINK_ID)
        assert alone.status_code == 200, alone.text
        assert alone.json()["intent"] == "vibe-iterate"
        assert "Produced by shrink to MVM." in alone.json()["link_evidence"]
        assert link(c, business, ecm, BASE_ID).status_code == 200

        ((run, ops),) = runs_of(engine, business)
        assert run.intent == "new-base-model" and run.databricks_run_id == BASE_ID
        assert [(o.step_index, o.operation_name, o.output_version_id) for o in ops] == [
            (0, "generate_ecm", ecm), (1, "shrink_to_mvm", mvm),
        ]
        assert ops[1].parent_version_id == ecm

    def test_a_second_link_is_refused_and_writes_nothing(self, engine, ws, config, business, registry):
        both_written(registry)
        ecm = imported_version(engine, business, "ecm")
        c = client(engine, ws, config)
        run_id = link(c, business, ecm, BASE_ID).json()["id"]
        before = table_digests(engine)
        again = link(c, business, ecm, BASE_ID)
        assert again.status_code == 409
        assert again.json()["detail"]["error"] == "link_refused"
        assert again.json()["detail"]["problems"] == [
            f"This version is already recorded as the output of run {run_id}.",
            f"Databricks run {BASE_ID} is already recorded as run {run_id}.",
        ]
        assert changed_tables(before, table_digests(engine)) == set()

    def test_a_run_the_app_tracks_is_refused(self, engine, ws, config, business, registry):
        both_written(registry)
        with Session(engine) as s:
            app_run = Run(business_id=business, intent="new-base-model", status="completed")
            s.add(app_run)
            s.flush()
            s.add(RunOperation(run_id=app_run.id, step_index=0, operation_name="generate_ecm", databricks_run_id=BASE_ID))
            s.commit()
            app_run_id = app_run.id
        ecm = imported_version(engine, business, "ecm")
        before = table_digests(engine)
        resp = link(client(engine, ws, config), business, ecm, BASE_ID)
        assert resp.status_code == 409
        assert resp.json()["detail"]["problems"] == [f"Databricks run {BASE_ID} is already recorded as run {app_run_id}."]
        assert changed_tables(before, table_digests(engine)) == set()

    def test_a_refused_verification_is_422_and_writes_nothing(self, engine, ws, config, business, registry):
        registry.event(CAT, session_started(session_id=BASE_SID, operation="new base model", version=2,
                                            widget_scope="ecm", catalog=CAT, at="2026-10-24 03:50:40.000"))
        ecm = imported_version(engine, business, "ecm")
        before = table_digests(engine)
        resp = link(client(engine, ws, config), business, ecm, BASE_ID)
        assert resp.status_code == 422
        assert changed_tables(before, table_digests(engine)) == set()

    def test_a_linked_run_links_to_its_run_without_the_app_job(self, engine, ws, config, business, registry):
        both_written(registry)
        ecm = imported_version(engine, business, "ecm")
        c = client(engine, ws, config)
        out = link(c, business, ecm, BASE_ID).json()
        job_less = f"https://test-workspace.databricks.com/jobs/runs/{BASE_ID}"
        assert out["run_page_url"] == job_less
        ops = c.get(f"/api/businesses/{business}/runs/{out['id']}/operations")
        assert ops.status_code == 200, ops.text
        assert [o["run_page_url"] for o in ops.json()] == [job_less]

    def test_an_active_run_holds_the_business(self, engine, ws, config, business, registry):
        both_written(registry)
        with Session(engine) as s:
            s.add(Run(business_id=business, intent="vibe-iterate", status="running"))
            s.commit()
        ecm = imported_version(engine, business, "ecm")
        before = table_digests(engine)
        resp = link(client(engine, ws, config), business, ecm, BASE_ID)
        assert resp.status_code == 409
        assert "already has an active run" in resp.json()["detail"]
        assert changed_tables(before, table_digests(engine)) == set()

    def test_a_failed_write_leaves_nothing(self, engine, ws, config, business, registry, monkeypatch):
        both_written(registry)
        ecm = imported_version(engine, business, "ecm")

        def boom(*args, **kwargs):
            raise RuntimeError("write failed")

        monkeypatch.setattr(run_link, "_operation_row", boom)
        before = table_digests(engine)
        with Session(engine) as s:
            with pytest.raises(RuntimeError):
                run_link.link(s, ws, s.get(Business, business), s.get(ModelVersion, ecm), BASE_ID)
        assert changed_tables(before, table_digests(engine)) == set()

    def test_the_admin_recovery_import_is_linkable(self, engine, ws, config, business, registry):
        """``importVersionFromVolume`` records its import as an
        ``import-from-volume`` Run; the link reads the path from it."""
        both_written(registry)
        with Session(engine) as s:
            mv = ModelVersion(business_id=business, version=1, scope="ecm", status="completed", files_catalog=CAT)
            s.add(mv)
            s.flush()
            imp = Run(business_id=business, intent="import-from-volume", status="completed", started_at=AFTER_BOTH,
                      parameters_json=json.dumps({"volume_path": model_json_path("ecm"), "source": "import_from_volume"}))
            s.add(imp)
            s.flush()
            s.add(RunOperation(run_id=imp.id, step_index=0, operation_name="import_from_volume",
                               status="succeeded", output_version_id=mv.id))
            s.commit()
            vid = mv.id
        resp = link(client(engine, ws, config), business, vid, BASE_ID)
        assert resp.status_code == 200, resp.text
        assert resp.json()["intent"] == "new-base-model" and resp.json()["link_evidence"].startswith("Tier 1:")

    def test_a_version_the_app_produced_is_refused(self, engine, ws, config, business, registry):
        vid = app_version(engine, business, "ecm")
        body = preview(client(engine, ws, config), business, vid, BASE_ID).json()
        assert body["linkable"] is False
        assert body["problems"] == ["Only an imported version can be linked to a run."]


class TestOutOfBandVersion:
    """An out-of-band import (``initial_sync``) records no ``import_source_path``
    and no ``imported_at``; ``run_link.import_sources`` still counts it as
    imported, from its folder in the Volume and its creation time."""

    def test_tier1_matches_the_agents_folder_and_writes_nothing(self, engine, ws, config, business, registry):
        both_written(registry)
        vid = oob_version(engine, business, "ecm")
        before = table_digests(engine)
        body = preview(client(engine, ws, config), business, vid, BASE_ID).json()
        assert body["linkable"] is True and body["tier"] == 1 and body["intent"] == "new-base-model", body
        assert body["problems"] == []
        assert changed_tables(before, table_digests(engine)) == set()

    def test_tier2_names_the_folder_it_derived(self, engine, ws, config, business, registry):
        vid = oob_version(engine, business, "ecm")
        body = preview(client(engine, ws, config), business, vid, BASE_ID).json()
        assert body["linkable"] is True and body["tier"] == 2, body
        assert body["evidence"][1] == (
            f"Best effort: matched the import folder /Volumes/{CAT}/_metamodel/vol_root/business/{SEGMENT}/v1/ecm, "
            f"business {SEGMENT}, scope ECM and catalog {CAT}."
        )

    @pytest.mark.parametrize("intent,status,operation", RUNS_ON_A_VERSION)
    def test_stays_linkable_after_an_app_run_on_it(
        self, engine, ws, config, business, registry, intent, status, operation,
    ):
        both_written(registry)
        vid = oob_version(engine, business, "ecm")
        run_on_version(engine, business, vid, intent, status, operation)
        c = client(engine, ws, config)
        body = preview(c, business, vid, BASE_ID).json()
        assert body["linkable"] is True and body["tier"] == 1, body
        assert link(c, business, vid, BASE_ID).status_code == 200

    def test_a_run_into_another_catalog_is_refused(self, engine, ws, config, business, registry):
        ws.runs[BASE_ID] = job_run(BASE_RUN, deployment_catalog="third_cat")
        vid = oob_version(engine, business, "ecm")
        body = preview(client(engine, ws, config), business, vid, BASE_ID).json()
        assert f"The run wrote into catalog 'third_cat', not '{CAT}'." in body["problems"]

    def test_the_version_must_be_the_one_the_run_wrote(self, engine, ws, config, business, registry):
        vid = oob_version(engine, business, "ecm", version=2)
        body = preview(client(engine, ws, config), business, vid, BASE_ID).json()
        assert body["linkable"] is True and body["tier"] == 2
        registry.event(CAT, session_started(session_id=BASE_SID, operation="new base model", version=1,
                                            widget_scope="ecm", catalog=CAT, at="2026-10-24 03:50:40.000"))
        body = preview(client(engine, ws, config), business, vid, BASE_ID).json()
        assert body["problems"] == [f"This run wrote v1 ECM of {SEGMENT}, not v2 ECM of {SEGMENT}."]

    def test_a_run_that_ended_after_the_row_was_created_is_refused(self, engine, ws, config, business, registry):
        vid = oob_version(engine, business, "ecm", created_at=datetime.fromtimestamp(BASE_RUN["start_time"] / 1000, tz=timezone.utc))
        body = preview(client(engine, ws, config), business, vid, BASE_ID).json()
        assert body["problems"] == [
            "The run ended after this version was imported, so the import cannot be its output."
        ]

    def test_links_a_pair_as_one_run_and_refuses_a_second_link(self, engine, ws, config, business, registry):
        both_written(registry)
        ecm = oob_version(engine, business, "ecm")
        mvm = oob_version(engine, business, "mvm")
        c = client(engine, ws, config)
        first = link(c, business, ecm, BASE_ID)
        assert first.status_code == 200, first.text
        second = link(c, business, mvm, SHRINK_ID)
        assert second.status_code == 200, second.text
        assert second.json()["id"] == first.json()["id"]
        ((run, ops),) = runs_of(engine, business)
        assert run.intent == "new-base-model" and run.link_evidence.startswith("Tier 1:")
        assert [(o.step_index, o.operation_name, o.output_version_id) for o in ops] == [
            (0, "generate_ecm", ecm), (1, "shrink_to_mvm", mvm),
        ]
        before = table_digests(engine)
        again = link(c, business, ecm, BASE_ID)
        assert again.status_code == 409
        assert again.json()["detail"]["problems"][0] == f"This version is already recorded as the output of run {run.id}."
        assert changed_tables(before, table_digests(engine)) == set()

    def test_a_refused_link_writes_nothing(self, engine, ws, config, business, registry):
        vid = oob_version(engine, business, "ecm")
        before = table_digests(engine)
        resp = link(client(engine, ws, config), business, vid, SHRINK_ID)
        assert resp.status_code == 422
        assert changed_tables(before, table_digests(engine)) == set()

    def test_a_version_without_a_files_catalog_is_refused(self, engine, ws, config, business, registry):
        vid = oob_version(engine, business, "ecm", catalog=None)
        body = preview(client(engine, ws, config), business, vid, BASE_ID).json()
        assert body["problems"] == ["Only an imported version can be linked to a run."]


class TestIsImported:
    """``is_imported`` of the versions list is ``run_link.import_sources``:
    the rule the link routes use."""

    def _flags(self, engine, ws, config, business) -> dict[str, bool]:
        body = client(engine, ws, config).get(f"/api/businesses/{business}/versions").json()
        return {v["id"]: v["is_imported"] for v in body}

    def test_flags_each_way_a_version_comes_to_exist(self, engine, ws, config, business, registry):
        dialog = imported_version(engine, business, "ecm")
        oob = oob_version(engine, business, "mvm")
        app = app_version(engine, business, "ecm", version=2)
        with Session(engine) as s:
            mv = ModelVersion(business_id=business, version=3, scope="ecm", status="completed", files_catalog=CAT)
            s.add(mv)
            s.flush()
            imp = Run(business_id=business, intent="import-from-volume", status="completed", started_at=AFTER_BOTH,
                      parameters_json=json.dumps({"volume_path": model_json_path("ecm", 3)}))
            s.add(imp)
            s.flush()
            s.add(RunOperation(run_id=imp.id, step_index=0, operation_name="import_from_volume",
                               status="succeeded", output_version_id=mv.id))
            s.commit()
            recovery = mv.id
        assert self._flags(engine, ws, config, business) == {
            dialog: True, oob: True, recovery: True, app: False,
        }

    @pytest.mark.parametrize("intent,status,operation", RUNS_ON_A_VERSION)
    def test_an_app_run_on_an_out_of_band_version_does_not_make_it_the_apps(
        self, engine, ws, config, business, registry, intent, status, operation,
    ):
        vid = oob_version(engine, business, "ecm")
        run_on_version(engine, business, vid, intent, status, operation)
        assert self._flags(engine, ws, config, business) == {vid: True}

    def test_a_linked_out_of_band_version_stays_imported(self, engine, ws, config, business, registry):
        both_written(registry)
        oob = oob_version(engine, business, "ecm")
        c = client(engine, ws, config)
        assert link(c, business, oob, BASE_ID).status_code == 200
        body = {v["id"]: v for v in c.get(f"/api/businesses/{business}/versions").json()}
        assert body[oob]["is_imported"] is True and body[oob]["linked_run_id"]

    def test_the_copies_of_a_kickstarted_business_are_not_imported(self, engine, ws, config, business, registry):
        """A kickstart seeds its versions with a ``files_catalog`` and no
        run pointing at the second scope's copy; a version out-of-band
        imported after the kickstart finished is still imported."""
        done = AFTER_BOTH
        with Session(engine) as s:
            s.add(Run(business_id=business, intent="kickstart-from-industry", status="completed",
                      created_at=done - timedelta(minutes=5), completed_at=done))
            s.commit()
        copy_ecm = oob_version(engine, business, "ecm", created_at=done - timedelta(minutes=4))
        copy_mvm = oob_version(engine, business, "mvm", created_at=done - timedelta(minutes=4))
        later = oob_version(engine, business, "ecm", version=2, created_at=done + timedelta(days=1))
        assert self._flags(engine, ws, config, business) == {copy_ecm: False, copy_mvm: False, later: True}

    def test_the_list_runs_a_fixed_number_of_queries(self, engine, ws, config, business, registry):
        c = client(engine, ws, config)

        def count_queries() -> int:
            seen: list[str] = []

            def record(conn, cursor, statement, *a):
                seen.append(statement)

            event.listen(engine, "before_cursor_execute", record)
            try:
                assert c.get(f"/api/businesses/{business}/versions").status_code == 200
            finally:
                event.remove(engine, "before_cursor_execute", record)
            return len(seen)

        oob_version(engine, business, "ecm", version=1)
        oob_version(engine, business, "mvm", version=1)
        app_version(engine, business, "ecm", version=2)
        few = count_queries()
        for n in range(3, 13):
            oob_version(engine, business, "mvm", version=n)
            app_version(engine, business, "ecm", version=n)
        assert count_queries() == few


class TestRoles:

    @pytest.mark.parametrize("role", [UserRole.VIEWER, UserRole.MODELER])
    def test_below_business_admin_is_refused(self, engine, ws, config, business, registry, role):
        vid = imported_version(engine, business, "ecm")
        c = client(engine, ws, config, role)
        assert preview(c, business, vid, BASE_ID).status_code == 403
        assert link(c, business, vid, BASE_ID).status_code == 403

    def test_business_admin_links(self, engine, ws, config, business, registry):
        both_written(registry)
        vid = imported_version(engine, business, "ecm")
        c = client(engine, ws, config, UserRole.BUSINESS_ADMIN)
        assert preview(c, business, vid, BASE_ID).status_code == 200
        assert link(c, business, vid, BASE_ID).status_code == 200


class TestImportWithRunId:
    """``executeImport`` with ``databricks_run_id``: the 5.3.3 base-model file
    of MVM v1 from the shrink run's folder."""

    MODEL = json.loads((FIXTURES / "agent_shapes" / "model_json_5_3_3_base.json").read_text())

    def _execute(self, engine, ws, config, business, run_id):
        resp = MagicMock()
        resp.contents.read.return_value = json.dumps(self.MODEL).encode()
        ws.files.download.return_value = resp
        return client(engine, ws, config).post(
            f"/api/businesses/{business}/import/execute",
            json={"volume_path": model_json_path("mvm"), "accept_business_mismatch": True, "databricks_run_id": run_id},
        )

    def test_links_after_the_import(self, engine, ws, config, business, registry):
        both_written(registry)
        resp = self._execute(engine, ws, config, business, SHRINK_ID)
        assert resp.status_code == 200, resp.text
        body = resp.json()
        ((run, ops),) = runs_of(engine, business)
        assert body["linked_run_id"] == run.id and ops[0].output_version_id == body["version_id"]
        assert run.intent == "vibe-iterate" and ops[0].operation_name == "shrink_to_mvm"

    def test_a_failed_link_write_keeps_the_import(self, engine, ws, config, business, registry, monkeypatch):
        both_written(registry)

        def boom(*args, **kwargs):
            raise RuntimeError("connection reset")

        monkeypatch.setattr(run_link, "_write", boom)
        resp = self._execute(engine, ws, config, business, SHRINK_ID)
        assert resp.status_code == 200, resp.text
        body = resp.json()
        assert body["linked_run_id"] is None
        assert any("not linked to Databricks run" in w and "connection reset" in w for w in body["warnings"])
        assert runs_of(engine, business) == []

    def test_a_refused_link_keeps_the_import(self, engine, ws, config, business, registry):
        resp = self._execute(engine, ws, config, business, 42)
        assert resp.status_code == 200, resp.text
        body = resp.json()
        assert body["linked_run_id"] is None
        assert (
            "The version was imported but not linked to Databricks run 42: Databricks run 42 was not found."
            in body["warnings"]
        )
        assert runs_of(engine, business) == []
        with Session(engine) as s:
            assert s.get(ModelVersion, body["version_id"]) is not None

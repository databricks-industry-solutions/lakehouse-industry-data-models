"""``uninstall`` reads the agent's exit JSON (E-14).

The agent's uninstall job ends SUCCESS even when some ``DROP DATABASE`` raised;
its exit JSON carries ``failed`` (nb 108480-108492). The version is still
marked uninstalled, and the schemas left behind become a run warning that
``RunOut.warnings`` returns. An unreadable result keeps the uninstall as it was
and logs one line.
"""
from __future__ import annotations

import json
import logging
import time
from types import SimpleNamespace
from unittest.mock import MagicMock

import pytest
from sqlmodel import Session, select

from vibe_modeling.backend.db_models import Business, Domain, ModelVersion, Run, RunOperation
from vibe_modeling.backend.routes._helpers import _build_run_out
from vibe_modeling.backend.services.operations import OperationContext, OperationDispatchHandle
from vibe_modeling.backend.services.operations import _agent_result, install
from vibe_modeling.backend.services.operations._protocol import RUN_WARNINGS_KEY
from vibe_modeling.backend.services.operations._version_lifecycle import installed_catalogs, mark_version_deployed
from vibe_modeling.backend.services.operations import uninstall as uninstall_op
from vibe_modeling.backend.services.operations.uninstall import Uninstall, failed_drop_count, left_behind_warning

from ._lifecycle_fixtures import UNINSTALL_EXIT_OK, UNINSTALL_EXIT_PARTIAL, install_output

CAT = "business_1"
# 5.3.3 stores the prefix in database_name (ecm_sales); four domains.
DOMAINS = [("Sales", "ecm_sales"), ("Intake", "ecm_intake"), ("Orchard", "ecm_orchard"), ("Production", "ecm_production")]
ALL_FOUR = ["ecm_sales", "ecm_intake", "ecm_orchard", "ecm_production"]
LOGGER = "vibe_modeling.backend.services.operations.uninstall"


@pytest.fixture(autouse=True)
def released(monkeypatch):
    """The registry release goes through (its own tests are in
    ``test_registry_release.py``); the calls are recorded."""
    calls = []
    monkeypatch.setattr(uninstall_op, "get_warehouse_id", lambda session: "wh")
    monkeypatch.setattr(uninstall_op, "set_deploy_status", lambda *a: calls.append(a))
    return calls


def _schemas(*names):
    return [SimpleNamespace(name=n) for n in names]


def _ws(result, *, truncated=False, raises=False, ended_ago_s=0, listing=None):
    """A finished uninstall job. ``listing`` is what ``schemas.list`` returns
    per catalog: a list of names, a dict catalog -> names, or an Exception."""
    ws = MagicMock()
    if isinstance(listing, Exception):
        ws.schemas.list.side_effect = listing
    elif isinstance(listing, dict):
        ws.schemas.list.side_effect = lambda catalog_name: _schemas(*listing.get(catalog_name, []))
    else:
        ws.schemas.list.side_effect = lambda catalog_name: _schemas(*(listing or []))
    job_run = ws.jobs.get_run.return_value
    job_run.state.life_cycle_state.value = "TERMINATED"
    job_run.state.result_state.value = "SUCCESS"
    job_run.state.state_message = ""
    job_run.tasks = [SimpleNamespace(run_id=4242)]
    job_run.end_time = int((time.time() - ended_ago_s) * 1000)
    if raises:
        ws.jobs.get_run_output.side_effect = RuntimeError("temporarily unavailable")
    else:
        ws.jobs.get_run_output.return_value = install_output(result, truncated=truncated)
    return ws


def _seed(engine) -> str:
    with Session(engine) as s:
        biz = Business(name="Wt Linked", description="d")
        s.add(biz)
        s.flush()
        mv = ModelVersion(business_id=biz.id, version=1, scope="ecm", status="completed",
                          deployment_status="deployed", uc_catalog=CAT, files_catalog=CAT)
        s.add(mv)
        s.flush()
        for name, db in DOMAINS:
            s.add(Domain(version_id=mv.id, name=name, database_name=db))
        s.commit()
        return mv.id


def _observe(engine, version_id, ws, **params):
    ctx = OperationContext(
        run_id="run-1", operation_id="op-1", business_id="b", parent_version_id=version_id,
        params={"version_id": version_id, "scope": "ecm", "business_name": "wt_linked",
                "deployment_catalog": CAT, "schema_prefix": "ecm_", "model_version": 1, **params},
        inherited_params={},
    )
    handle = OperationDispatchHandle(databricks_run_id=1, vibe_session_id=None, extra={})
    with Session(engine) as s:
        obs = Uninstall().observe(handle, ctx, ws, s)
        s.commit()
    return obs


def _status(engine, version_id) -> str:
    with Session(engine) as s:
        return s.get(ModelVersion, version_id).deployment_status


def _text(obs) -> str:
    [text] = obs.terminal_result.rollback_state[RUN_WARNINGS_KEY]
    return text


class TestPartialFailure:
    def test_the_survivors_are_listed_and_the_version_is_uninstalled(self, engine):
        vid = _seed(engine)
        listing = [*ALL_FOUR, "default", "information_schema", "someone_elses"]
        obs = _observe(engine, vid, _ws(UNINSTALL_EXIT_PARTIAL, listing=listing))
        assert obs.terminal_result.succeeded is True
        assert obs.terminal_result.error is None
        assert _status(engine, vid) == "uninstalled"
        assert _text(obs) == (
            "v1 ECM is uninstalled from business_1, but these schemas could not be dropped and are still "
            "there: ecm_intake, ecm_orchard, ecm_production, ecm_sales. "
            "Their owner, or someone with the right privileges, can drop them."
        )

    def test_only_the_schemas_that_exist_are_listed(self, engine):
        vid = _seed(engine)
        obs = _observe(engine, vid, _ws({**UNINSTALL_EXIT_PARTIAL, "failed": 2}, listing=["ecm_sales", "ecm_intake", "unrelated"]))
        text = _text(obs)
        assert "still there: ecm_intake, ecm_sales." in text
        assert "unrelated" not in text and "more schema" not in text

    def test_a_failure_the_listing_cannot_name_is_counted(self, engine):
        vid = _seed(engine)
        obs = _observe(engine, vid, _ws(UNINSTALL_EXIT_PARTIAL, listing=["ecm_sales"]))
        text = _text(obs)
        assert "still there: ecm_sales." in text
        assert "3 more schemas could not be identified." in text

    def test_a_metrics_only_failure_lists_no_schema(self, engine):
        vid = _seed(engine)
        obs = _observe(engine, vid, _ws({**UNINSTALL_EXIT_PARTIAL, "failed": 1}, listing=["_metrics"]))
        text = _text(obs)
        assert "the shared _metrics schema in business_1 could not be dropped and is still there" in text
        assert "these schemas" not in text and "schemas could not" not in text
        assert "more schema" not in text
        assert _status(engine, vid) == "uninstalled"

    def test_metrics_with_survivors_is_not_in_the_names(self, engine):
        vid = _seed(engine)
        obs = _observe(engine, vid, _ws({**UNINSTALL_EXIT_PARTIAL, "failed": 3}, listing=["ecm_sales", "ecm_intake", "_metrics"]))
        text = _text(obs)
        assert "still there: ecm_intake, ecm_sales." in text
        assert "The shared _metrics schema in business_1 is also still there." in text
        assert "more schema" not in text

    def test_nothing_found_falls_back_to_the_count(self, engine):
        vid = _seed(engine)
        obs = _observe(engine, vid, _ws(UNINSTALL_EXIT_PARTIAL, listing=[]))
        assert _text(obs) == "v1 ECM is uninstalled from business_1, but 4 schemas could not be dropped and are still there."

    def test_a_listing_failure_falls_back_to_the_count_and_never_fails_the_run(self, engine, caplog):
        vid = _seed(engine)
        with caplog.at_level(logging.WARNING, logger=LOGGER):
            obs = _observe(engine, vid, _ws(UNINSTALL_EXIT_PARTIAL, listing=PermissionError("denied")))
        assert obs.terminal_result.succeeded is True
        assert _status(engine, vid) == "uninstalled"
        assert _text(obs).endswith("but 4 schemas could not be dropped and are still there.")
        assert any("could not read the schemas left" in r.getMessage() for r in caplog.records)

    def test_one_left_reads_in_the_singular(self, engine):
        vid = _seed(engine)
        obs = _observe(engine, vid, _ws({**UNINSTALL_EXIT_PARTIAL, "failed": 1}))
        assert "1 schema could not be dropped and is still there" in _text(obs)

    def test_the_warning_text_alone_gives_the_count(self, engine):
        result = {k: v for k, v in UNINSTALL_EXIT_PARTIAL.items() if k != "failed"}
        vid = _seed(engine)
        obs = _observe(engine, vid, _ws(result, listing=ALL_FOUR))
        assert "ecm_sales" in _text(obs) and "more schema" not in _text(obs)

    def test_a_progress_tracking_note_alone_is_no_left_over_schema(self, engine):
        result = {**UNINSTALL_EXIT_OK, "status": "success_with_warnings", "warning_count": 1,
                  "warnings": ["⚠️ VibeWriter failed to initialize — progress tracking is DISABLED for this uninstall"]}
        vid = _seed(engine)
        ws = _ws(result, listing=ALL_FOUR)
        obs = _observe(engine, vid, ws)
        assert RUN_WARNINGS_KEY not in obs.terminal_result.rollback_state
        assert _status(engine, vid) == "uninstalled"
        ws.schemas.list.assert_not_called()

    @pytest.mark.parametrize(
        ("result", "count"),
        [({"failed": 3}, 3), ({"failed": 0, "warnings": ["⚠️ 2 database(s) failed to drop"]}, 0),
         ({"failed": True}, 0), ({"failed": "4", "warnings": ["⚠️ 4 database(s) failed to drop"]}, 4),
         ({"failed": -1}, 0), ({}, 0), ({"warnings": None}, 0)],
        ids=["count", "zero_wins", "bool_ignored", "text_fallback", "negative", "empty", "null_warnings"],
    )
    def test_failed_drop_count(self, result, count):
        assert failed_drop_count(result) == count


class TestSeveralCatalogs:
    def _installed_in_three(self, engine):
        vid = _seed(engine)
        with Session(engine) as s:
            mv = s.get(ModelVersion, vid)
            mark_version_deployed(s, mv, "other_cat")
            mark_version_deployed(s, mv, "third_cat")
            mark_version_deployed(s, mv, CAT)
            s.commit()
        return vid

    def test_one_catalog_reads_only_the_catalog_uninstalled_from(self, engine):
        vid = self._installed_in_three(engine)
        listing = {CAT: ["ecm_sales"], "other_cat": ["ecm_intake"], "third_cat": ["ecm_orchard"]}
        ws = _ws({**UNINSTALL_EXIT_PARTIAL, "failed": 1}, listing=listing)
        text = _text(_observe(engine, vid, ws))
        assert "still there: ecm_sales." in text and "ecm_intake" not in text and "ecm_orchard" not in text
        assert [c.kwargs for c in ws.schemas.list.call_args_list] == [{"catalog_name": CAT}]
        with Session(engine) as s:
            mv = s.get(ModelVersion, vid)
            assert mv.deployment_status == "deployed"
            assert sorted(installed_catalogs(s, mv)) == ["other_cat", "third_cat"]

    @pytest.mark.parametrize("style", ["Catalog per Division", "Catalog per Domain"])
    def test_catalog_per_style_reads_each_catalog_the_version_lives_in(self, engine, style):
        vid = self._installed_in_three(engine)
        listing = {CAT: ["ecm_sales"], "other_cat": ["ecm_intake"], "third_cat": ["ecm_orchard"]}
        ws = _ws({**UNINSTALL_EXIT_PARTIAL, "failed": 3}, listing=listing)
        text = _text(_observe(engine, vid, ws, cataloging_style=style, schema_prefix=""))
        assert "uninstalled from business_1" in text
        for part in ("ecm_sales", "other_cat.ecm_intake", "third_cat.ecm_orchard"):
            assert part in text
        assert "more schema" not in text
        assert sorted(c.kwargs["catalog_name"] for c in ws.schemas.list.call_args_list) == sorted([CAT, "other_cat", "third_cat"])

    def test_one_catalog_is_listed_once(self, engine):
        vid = _seed(engine)
        ws = _ws(UNINSTALL_EXIT_PARTIAL, listing=ALL_FOUR)
        _observe(engine, vid, ws)
        assert [c.kwargs for c in ws.schemas.list.call_args_list] == [{"catalog_name": CAT}]


class TestInstallNext:
    """An install-over-occupant or a revert uninstalls, then installs another
    version into the same catalog; its names can be the ones left behind."""

    def _next_install(self, engine, run_id, *, catalog=CAT, prefix="ecm_", status="pending"):
        with Session(engine) as s:
            biz = s.exec(select(Business)).first()
            nxt = ModelVersion(business_id=biz.id, version=2, scope="ecm", status="completed",
                               deployment_status="uninstalled", uc_catalog=CAT, files_catalog=CAT)
            s.add(nxt)
            s.flush()
            for name, db in DOMAINS[:2]:
                s.add(Domain(version_id=nxt.id, name=name, database_name=db))
            run = Run(id=run_id, business_id=biz.id, intent="install", status="running", parameters_json="{}")
            s.add(run)
            s.flush()
            s.add(RunOperation(run_id=run.id, step_index=0, operation_name="uninstall", status="running"))
            s.add(RunOperation(run_id=run.id, step_index=1, operation_name="install", status=status,
                               parent_version_id=nxt.id,
                               params_json=json.dumps({"scope": "ecm", "deployment_catalog": catalog,
                                                       "schema_prefix": prefix, "version_id": nxt.id})))
            s.commit()

    def test_the_text_says_the_next_version_takes_the_names(self, engine):
        vid = _seed(engine)
        self._next_install(engine, "run-1")
        obs = _observe(engine, vid, _ws(UNINSTALL_EXIT_PARTIAL, listing=ALL_FOUR))
        text = _text(obs)
        assert "still there: ecm_intake, ecm_orchard, ecm_production, ecm_sales." in text
        assert "v2 ECM installs into ecm_intake, ecm_sales next, so their old tables may remain next to v2's." in text
        assert "can drop them" not in text

    @pytest.mark.parametrize(
        ("kw", "listing"),
        [({"catalog": "other_cat"}, ALL_FOUR), ({"status": "succeeded"}, ALL_FOUR), ({}, ["ecm_orchard"])],
        ids=["other_catalog", "not_pending", "no_overlap"],
    )
    def test_no_claim_when_the_next_install_does_not_take_them(self, engine, kw, listing):
        vid = _seed(engine)
        self._next_install(engine, "run-1", **kw)
        text = _text(_observe(engine, vid, _ws({**UNINSTALL_EXIT_PARTIAL, "failed": len(listing)}, listing=listing)))
        assert "next to v2" not in text and "can drop them" in text

    def test_a_plain_uninstall_has_no_such_claim(self, engine):
        vid = _seed(engine)
        assert "next to v" not in _text(_observe(engine, vid, _ws(UNINSTALL_EXIT_PARTIAL, listing=ALL_FOUR)))


class TestWarningText:
    def test_the_count_only_text_is_plural_and_singular(self):
        assert left_behind_warning(4, "c", 1, "ecm") == "v1 ECM is uninstalled from c, but 4 schemas could not be dropped and are still there."
        assert left_behind_warning(1, "c", 1, "mvm") == "v1 MVM is uninstalled from c, but 1 schema could not be dropped and is still there."


class TestCleanUninstall:
    def test_no_warning_and_the_version_is_uninstalled(self, engine):
        vid = _seed(engine)
        obs = _observe(engine, vid, _ws(UNINSTALL_EXIT_OK))
        assert obs.terminal_result.succeeded is True and obs.terminal_result.error is None
        assert RUN_WARNINGS_KEY not in obs.terminal_result.rollback_state
        assert obs.terminal_result.rollback_state["jobs_terminal_result_state"] == "SUCCESS"
        assert _status(engine, vid) == "uninstalled"


class TestUnreadableResult:
    @pytest.mark.parametrize(
        ("result", "truncated", "why"),
        [(None, False, "empty"), ("", False, "empty"), ("not json", False, "not JSON"),
         ("[1, 2]", False, "not an object"), (UNINSTALL_EXIT_PARTIAL, True, "truncated")],
        ids=["none", "blank", "not_json", "not_object", "truncated"],
    )
    def test_an_unusable_result_keeps_the_uninstall_and_logs_one_line(self, engine, caplog, result, truncated, why):
        vid = _seed(engine)
        with caplog.at_level(logging.WARNING, logger=LOGGER):
            obs = _observe(engine, vid, _ws(result, truncated=truncated))
        assert obs.terminal_result.succeeded is True and obs.terminal_result.error is None
        assert RUN_WARNINGS_KEY not in obs.terminal_result.rollback_state
        assert _status(engine, vid) == "uninstalled"
        [record] = [r for r in caplog.records if r.name == LOGGER]
        assert why in record.getMessage()

    def test_a_raising_read_after_the_deadline_is_the_same(self, engine, caplog):
        vid = _seed(engine)
        ws = _ws(None, raises=True, ended_ago_s=_agent_result.EXIT_RESULT_READ_DEADLINE_S + 5)
        with caplog.at_level(logging.WARNING, logger=LOGGER):
            obs = _observe(engine, vid, ws)
        assert obs.terminal_result.succeeded is True
        assert _status(engine, vid) == "uninstalled"
        assert len([r for r in caplog.records if r.name == LOGGER]) == 1

    def test_a_raising_read_before_the_deadline_is_read_again_on_the_next_poll(self, engine):
        vid = _seed(engine)
        obs = _observe(engine, vid, _ws(None, raises=True, ended_ago_s=10))
        assert obs.is_terminal is False and "reading the agent's result" in obs.progress_message
        assert _status(engine, vid) == "deployed"


class TestSharedReader:
    def test_install_reads_through_the_shared_helper(self):
        assert install.agent_exit_result is _agent_result.agent_exit_result
        assert not hasattr(install, "_agent_exit_result")
        assert not hasattr(install, "EXIT_RESULT_READ_DEADLINE_S")

    def test_the_failure_text_leads_with_the_callers_words(self):
        job_run = SimpleNamespace(tasks=None, end_time=None)
        ws = MagicMock()
        ws.jobs.get_run_output.return_value = install_output("not json")
        got = _agent_result.agent_exit_result(ws, job_run, 7, unreadable="Lead-in.")
        assert got.failure == "Lead-in. (the result is not JSON)"
        ws.jobs.get_run_output.assert_called_once_with(7)

    def test_the_result_is_the_parsed_object(self):
        job_run = SimpleNamespace(tasks=[SimpleNamespace(run_id=9)], end_time=None)
        ws = MagicMock()
        ws.jobs.get_run_output.return_value = install_output(UNINSTALL_EXIT_PARTIAL)
        got = _agent_result.agent_exit_result(ws, job_run, 7, unreadable="x")
        assert got.result == json.loads(json.dumps(UNINSTALL_EXIT_PARTIAL)) and got.failure is None
        ws.jobs.get_run_output.assert_called_once_with(9)


class TestRunOutWarnings:
    def _run(self, engine, rollback_states):
        with Session(engine) as s:
            biz = Business(name="Wt Linked", description="d")
            s.add(biz)
            s.flush()
            run = Run(business_id=biz.id, intent="uninstall", status="completed", parameters_json="{}")
            s.add(run)
            s.flush()
            for i, (status, state) in enumerate(rollback_states):
                s.add(RunOperation(run_id=run.id, step_index=i, operation_name="uninstall", status=status,
                                   rollback_state_json=json.dumps(state)))
            s.commit()
            s.refresh(run)
            return _build_run_out(run, None, s, warnings=[{"message": "from create", "severity": "warning"}])

    def test_a_succeeded_steps_warning_follows_the_create_warnings(self, engine):
        out = self._run(engine, [("succeeded", {RUN_WARNINGS_KEY: ["Left behind."]})])
        assert [w["message"] for w in out.warnings] == ["from create", "Left behind."]
        assert out.warnings[1]["severity"] == "warning" and out.warnings[1]["step_index"] == 0

    def test_nothing_warned_adds_nothing(self, engine):
        out = self._run(engine, [("succeeded", {"jobs_terminal_result_state": "SUCCESS"})])
        assert [w["message"] for w in out.warnings] == ["from create"]

    def test_a_step_that_did_not_succeed_adds_nothing(self, engine):
        out = self._run(engine, [("failed", {RUN_WARNINGS_KEY: ["Left behind."]})])
        assert [w["message"] for w in out.warnings] == ["from create"]

    def test_unusable_state_is_skipped(self, engine):
        out = self._run(engine, [("succeeded", {RUN_WARNINGS_KEY: "Left behind."}), ("succeeded", {RUN_WARNINGS_KEY: [3, ""]})])
        assert [w["message"] for w in out.warnings] == ["from create"]

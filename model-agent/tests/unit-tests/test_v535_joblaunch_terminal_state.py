"""v5.3.5 — the Job Launch Gate parent returns once its child run is terminal.

Live (2026-11-10, serverless): the child run TERMINATED SUCCESS at elapsed=2136s, but the parent kept printing
    [JobLaunchGate] run 584455148427960 life_cycle=RUNLIFECYCLESTATE.TERMINATED result=RUNRESULTSTATE.SUCCESS
until it was cancelled; the v8 parent sat ~12h. The SDK's run states are Enums, so str(state).upper() is
'RUNLIFECYCLESTATE.TERMINATED' and never matched the terminal set. These tests drive the production
JobLauncher.wait_for_run_terminal with Enum states shaped like databricks.sdk.service.jobs; on pre-patch HEAD the
terminal-state tests raise TimeoutError instead of returning.
"""
import ast
import enum
import sys
import types
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent))
import conftest  # noqa: F401,E402
from notebook_source_util import notebook_concat_source  # noqa: E402


class RunLifeCycleState(enum.Enum):  # same shape as databricks.sdk.service.jobs.RunLifeCycleState
    PENDING = "PENDING"
    RUNNING = "RUNNING"
    TERMINATED = "TERMINATED"
    INTERNAL_ERROR = "INTERNAL_ERROR"


class RunResultState(enum.Enum):  # same shape as databricks.sdk.service.jobs.RunResultState
    SUCCESS = "SUCCESS"
    FAILED = "FAILED"
    CANCELED = "CANCELED"


def _load_launcher():
    src = notebook_concat_source()
    tree = ast.parse(src)
    wanted = {"_io_with_timeout", "_v535_run_state_name", "JobLauncher"}
    nodes = [n for n in tree.body if isinstance(n, (ast.FunctionDef, ast.ClassDef)) and n.name in wanted]
    found = {n.name for n in nodes}
    ns = {}
    exec(compile("\n\n".join(ast.get_source_segment(src, n) for n in nodes), "agent", "exec"), ns)
    return ns, found


def _fake_sdk(monkeypatch, states):
    """WorkspaceClient whose jobs.get_run returns the given (life_cycle, result) states in order, then the last."""
    seq = list(states)

    class _Jobs:
        def get_run(self, run_id):
            lcs, rs = seq.pop(0) if len(seq) > 1 else seq[0]
            return types.SimpleNamespace(state=types.SimpleNamespace(life_cycle_state=lcs, result_state=rs))

    class WorkspaceClient:
        def __init__(self, *a, **k):
            self.jobs = _Jobs()

    sdk = types.ModuleType("databricks.sdk")
    sdk.WorkspaceClient = WorkspaceClient
    pkg = types.ModuleType("databricks")
    pkg.sdk = sdk
    monkeypatch.setitem(sys.modules, "databricks", pkg)
    monkeypatch.setitem(sys.modules, "databricks.sdk", sdk)


def _wait(ns, timeout=3):
    return ns["JobLauncher"].wait_for_run_terminal(123, heartbeat_seconds=0, timeout_seconds=timeout,
                                                   log_print=lambda *_: None)


def test_parent_returns_success_when_child_terminates_with_enum_states(monkeypatch):
    ns, _ = _load_launcher()
    _fake_sdk(monkeypatch, [(RunLifeCycleState.RUNNING, None),
                            (RunLifeCycleState.TERMINATED, RunResultState.SUCCESS)])
    assert _wait(ns) == "SUCCESS"


def test_failed_child_is_reported_as_failed_so_the_parent_propagates_it(monkeypatch):
    ns, _ = _load_launcher()
    _fake_sdk(monkeypatch, [(RunLifeCycleState.TERMINATED, RunResultState.FAILED)])
    # the gate raises when the state is in ("FAILED", "TIMEDOUT", "CANCELED", "INTERNAL_ERROR")
    assert _wait(ns) == "FAILED"


def test_internal_error_without_result_state_is_terminal(monkeypatch):
    ns, _ = _load_launcher()
    _fake_sdk(monkeypatch, [(RunLifeCycleState.INTERNAL_ERROR, None)])
    assert _wait(ns) == "INTERNAL_ERROR"


def test_plain_string_states_still_work(monkeypatch):
    ns, _ = _load_launcher()
    _fake_sdk(monkeypatch, [("RUNNING", ""), ("TERMINATED", "SUCCESS")])
    assert _wait(ns) == "SUCCESS"


def test_running_child_is_not_mistaken_for_terminal(monkeypatch):
    # must-exclude case: a child that never finishes keeps the parent waiting until its own timeout
    ns, _ = _load_launcher()
    _fake_sdk(monkeypatch, [(RunLifeCycleState.RUNNING, None)])
    with pytest.raises(TimeoutError):
        _wait(ns, timeout=1)


def test_run_state_name_normalizes_enum_prefixed_and_empty_values():
    ns, found = _load_launcher()
    assert "_v535_run_state_name" in found, "v5.3.5 run-state normalizer missing (expected on pre-patch HEAD)"
    name = ns["_v535_run_state_name"]
    assert name(RunLifeCycleState.TERMINATED) == "TERMINATED"
    assert name(RunResultState.SUCCESS) == "SUCCESS"
    assert name("RunLifeCycleState.TERMINATED") == "TERMINATED"
    assert name("terminated") == "TERMINATED"
    assert name(None) == "" and name("") == ""


def test_gate_gives_child_a_task_run_id_and_capture_reads_ctx_job_run_id():
    src = notebook_concat_source()
    assert src.count('_job_widgets["databricks_task_run_id"] = "{{task.run_id}}"') == 1
    assert "_jctx.jobRunId()" in src and "alias=self-cancel-ctx-jobrunid" in src
    # the injected value is exactly the template the v4.5.8 validator rejects until Databricks substitutes it
    assert src.index('_job_widgets["databricks_task_run_id"]') < src.index("_launcher = JobLauncher(_nb_path, _job_widgets")

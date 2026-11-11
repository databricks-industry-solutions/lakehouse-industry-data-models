"""v5.3.5 — the Job Launch Gate parent stops polling once its child run is terminal.

ROOT CAUSE (live, pension_fund_investment_company, 2026-11-10, serverless, old_ew):
  A job run with an empty vibe_session_id goes through the Job Launch Gate: the parent launches the agent as a child
  job and waits in JobLauncher.wait_for_run_terminal. The child (run 584455148427960) built v9 and TERMINATED SUCCESS
  at elapsed=2136s, but the parent (run 540459755222569) kept polling and printing
      [JobLaunchGate] run 584455148427960 life_cycle=RUNLIFECYCLESTATE.TERMINATED result=RUNRESULTSTATE.SUCCESS
  every 60s until it was cancelled 30+ minutes later; the v8 parent sat RUNNING ~12h the same way. The loop does
  str(state.life_cycle_state).upper(), and the SDK's run states are Enums, so str() is 'RunLifeCycleState.TERMINATED'
  and never matches {'TERMINATED', 'SKIPPED', 'INTERNAL_ERROR'}. The only exit was the 15h timeout_seconds. The same
  normalization feeds the parent's FAILED/CANCELED propagation check, so a failed child could never fail the parent.

  Earlier sessions blamed lingering non-daemon ThreadPoolExecutor workers. Two serverless probes (2026-11-11) ruled
  that out: a run that leaves a non-daemon thread alive and calls dbutils.notebook.exit() (directly, or swallowed
  by `except Exception`) TERMINATES SUCCESS in ~15s.

FIX:
  1. _v535_run_state_name: Enum -> .value, strip any 'Class.' prefix, upper-case. Both wait_for_run_terminal
     definitions use it for life_cycle_state and result_state (alias=joblaunch-terminal-state-enum).
  2. The gate passes databricks_task_run_id={{task.run_id}} to the child it launches, like the repo's launchers
     already do, so the child's control-plane self-cancel arms (alias=joblaunch-child-task-run-id).
  3. Self-cancel run-id capture reads ctx.jobRunId() when the context tags are empty. ctx.toJson() is blocked on
     serverless (Py4JSecurityException -> tag_keys=[]) and currentRunId() raises, but jobRunId() returns the job run
     id (probe 2026-11-11). Replaces a dead `pass` that described a retired self_run_id read
     (alias=self-cancel-ctx-jobrunid).
Industry-agnostic: no model, domain or product names.
"""
import json

NB = "agent/dbx_vibe_modelling_agent.ipynb"
TAG = "patch_v535"
# Edit the RAW notebook text, not a json round-trip (see patch_v534_mv_joins_enabled.py): the diff carries only the
# changed lines.
raw = open(NB, encoding="utf-8").read()
json.loads(raw)  # must parse before


def _enc(s):
    return '",\n    "'.join(json.dumps(p, ensure_ascii=False)[1:-1] for p in s.splitlines(keepends=True))


def repl(old, new, label, count=1):
    global raw
    o, n_ = _enc(old), _enc(new)
    n = raw.count(o)
    if n != count:
        raise SystemExit(f"[{TAG}] '{label}' count={n} (expected {count})")
    raw = raw.replace(o, n_)


# ── 1) version ────────────────────────────────────────────────────────────────────────────────
repl('__AGENT_VERSION__ = "5.3.4"', '__AGENT_VERSION__ = "5.3.5"', "version")

# ── 2) run-state normalizer, right before class JobLauncher ───────────────────────────────────
repl(
    "class JobLauncher:\n",
    '''def _v535_run_state_name(value):
    """Plain upper-case name of a Jobs run state. SDK states are Enums whose str() is 'RunLifeCycleState.TERMINATED',
    which never equals 'TERMINATED' (alias=joblaunch-terminal-state-enum)."""
    if value is None:
        return ""
    text = str(getattr(value, "value", value) or "").strip().upper()
    return text.rsplit(".", 1)[-1]


class JobLauncher:
''',
    "state-normalizer",
)

# ── 3) both wait_for_run_terminal definitions use it ──────────────────────────────────────────
repl(
    "            _lcs = str(getattr(_state, 'life_cycle_state', '') or '').upper()\n"
    "            _rs = str(getattr(_state, 'result_state', '') or '').upper()\n",
    "            _lcs = _v535_run_state_name(getattr(_state, 'life_cycle_state', ''))\n"
    "            _rs = _v535_run_state_name(getattr(_state, 'result_state', ''))\n",
    "poll-state-names",
    count=2,
)

# ── 4) the gate gives its child a task-run id for self-cancel ─────────────────────────────────
repl(
    '            _job_widgets["runtime_budget_seconds"] = "54000"\n',
    '            _job_widgets["runtime_budget_seconds"] = "54000"\n'
    '            # The child arms its control-plane self-cancel from this (alias=joblaunch-child-task-run-id).\n'
    '            _job_widgets["databricks_task_run_id"] = "{{task.run_id}}"\n',
    "child-task-run-id",
)

# ── 5) self-cancel capture falls back to ctx.jobRunId() ───────────────────────────────────────
repl(
    """            # 74633503090396: model BUILT at 23:54 yet run hung 6h post-build until the 15h job
            # timeout). The serverless context exposed NEITHER run_id tags (tag_keys=[]) NOR a
            # usable currentRunId(), so _SELF_CANCEL_CTX stayed empty (has_run_id=False) and the
            # control-plane self-cancel NEVER armed; the process-kill subprocess SIGKILL is
            # independently ineffective on serverless. FIX: the marathon injects the Databricks-native
            # {{job.run_id}} as the self_run_id base_parameter; read it here as the authoritative,
            # environment-independent fallback (substituted at runtime; the {{ guard rejects an
            # un-substituted literal when the agent runs outside a job).
            pass
""",
    """            # Serverless blocks ctx.toJson() (tag_keys=[]) and currentRunId() raises, but ctx.jobRunId()
            # returns this job run's id (alias=self-cancel-ctx-jobrunid).
            try:
                _sc_jr = _jctx.jobRunId()
                try:
                    _sc_jr = _sc_jr.get()
                except Exception:
                    pass
                _sc_jr = str(_sc_jr or "").strip()
                if _sc_jr.isdigit() and int(_sc_jr) > 0:
                    _sc_run_id = _sc_jr
                    _sc_runid_source = "jobRunId"
            except Exception:
                pass
""",
    "self-cancel-jobrunid",
)

json.loads(raw)  # must parse after
open(NB, "w", encoding="utf-8").write(raw)
print(f"[{TAG}] applied")

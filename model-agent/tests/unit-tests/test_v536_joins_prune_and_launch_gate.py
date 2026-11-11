"""v5.3.6 — joined columns survive the pre-install prune; the launch gate runs in place inside a job.

Live (agent 5.3.5, 2026-11-11, child run 1048336217656120): three metric views installed with their joins, but the
pre-install prune checked `dim_portfolio.portfolio_name` against the SOURCE table and pruned every joined dimension,
and ColCheck dropped AVG(performance.twr_net) because the source's domain was not a known qualifier. These tests drive
the production helpers and renderer; on pre-patch HEAD the joined-ref, domain-qualifier, job-context and cancel-child
tests fail (the helpers do not exist, the measure is dropped).
"""
import http.server
import json
import os
import subprocess
import sys
import threading
import types
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent))
import conftest  # noqa: F401,E402
import agent_helpers as ah  # noqa: E402
from notebook_source_util import notebook_concat_source  # noqa: E402
from test_v534_mv_joins import _render  # noqa: E402  (production renderer on the v5.3.4 fixtures)

RENDERED = '''CREATE OR REPLACE VIEW `cat`.`_metrics`.`risk_signal_hit_rate`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  source: "`cat`.`risk`.`factor_signal_prediction`"
  joins:
    - name: dim_factor
      source: "`cat`.`risk`.`factor`"
      'on': source.factor_id = dim_factor.factor_id
      rely:
        at_most_one_match: true
    - name: dim_note
      source: "`cat`.`equity`.`research_note`"
      'on': source.research_note_id = dim_note.research_note_id
      joins:
        - name: dim_security
          source: "`cat`.`equity`.`listed_security`"
          'on': dim_note.listed_security_id = dim_security.listed_security_id
  dimensions:
    - name: "Factor Name"
      expr: dim_factor.factor_name
  measures:
    - name: "Predictions"
      expr: COUNT(*)
$$'''
SRC = {"factor_id", "research_note_id", "prediction_date", "direction_correct_flag"}
JOINS = {"dim_factor": {"factor_id", "factor_name"}, "dim_note": {"research_note_id", "listed_security_id"},
         "dim_security": {"listed_security_id", "gics_sector"}}
KW = {"count", "distinct", "case", "when", "then", "else", "end", "is", "true", "and", "filter", "where"}


# ── 1) prune: joined refs ─────────────────────────────────────────────────────────────────────
def test_join_targets_parsed_from_rendered_view_including_nested_joins():
    assert ah._mv_prevalidate_join_targets(RENDERED) == {"dim_factor": ("risk", "factor"),
                                                   "dim_note": ("equity", "research_note"),
                                                   "dim_security": ("equity", "listed_security")}


def test_single_table_view_has_no_join_targets():
    assert ah._mv_prevalidate_join_targets(RENDERED.split("  joins:")[0] + "  dimensions:\n$$") == {}


@pytest.mark.parametrize("expr", ["dim_factor.factor_name", "dim_security.gics_sector",
                                  "COUNT(DISTINCT dim_note.research_note_id)",
                                  "COUNT(*) FILTER (WHERE direction_correct_flag IS TRUE AND dim_factor.factor_name = 'Momentum')",
                                  "source.prediction_date", "prediction_date"])
def test_resolvable_refs_are_not_pruned(expr):
    assert ah._mv_prevalidate_bad_refs(expr, SRC, (), KW, JOINS) == set()


def test_unresolvable_refs_are_still_pruned():
    # must-exclude cases: a joined column that is not on its join's table, and an unknown bare column
    assert ah._mv_prevalidate_bad_refs("dim_factor.portfolio_name", SRC, (), KW, JOINS) == {"dim_factor.portfolio_name"}
    assert ah._mv_prevalidate_bad_refs("AVG(twr_net)", SRC, (), {"avg"}, JOINS) == {"twr_net"}
    assert ah._mv_prevalidate_bad_refs("dim_factor.factor_name", SRC, (), KW, {}) == {"factor_name"}  # pre-v5.3.6 behaviour without joins


def test_join_with_unknown_columns_keeps_its_refs():
    assert ah._mv_prevalidate_bad_refs("dim_factor.factor_name", SRC, (), KW, {"dim_factor": set()}) == set()


def test_prune_uses_the_join_aware_check():
    src = notebook_concat_source()
    assert "return _mv_prevalidate_bad_refs(_expr_raw, _src_cols, _mvcp_params, _mvcp_SQL_KW, _mvcp_join_cols)" in src
    assert "_mvcp_join_cols = {_a: _mvcp_get_cols(_s, _t) for _a, (_s, _t) in _mv_prevalidate_join_targets(_stmt).items()}" in src


# ── 2) domain / schema-qualified source columns ───────────────────────────────────────────────
def _spec(measures, dims=None):
    return {"metric_views": [{
        "view_name": "order_revenue", "source_product": "order_header",
        "joins": [{"alias": "dim_customer", "target_domain": "party", "target_product": "customer",
                   "on": "source.customer_id = dim_customer.customer_id", "type": "LEFT"}],
        "dimensions": dims or [{"name": "customer_segment", "expr": "dim_customer.customer_segment", "comment": "s"}],
        "measures": measures}]}


def test_domain_qualified_source_column_measure_is_kept():
    yaml_text, _ = _render(_spec([{"name": "Avg Order", "expr": "AVG(sales.order_amount)", "comment": "a"},
                                  {"name": "Total Revenue", "expr": "SUM(sales.order_header.order_amount)", "comment": "r"}]))
    exprs = [l.strip()[len("expr:"):].strip() for l in yaml_text.split("measures:", 1)[1].split("\n") if l.strip().startswith("expr:")]
    assert len(exprs) == 2, exprs  # both kept (pre-patch: both dropped as unresolved {'sales'})
    assert all("order_amount" in e and "sales." not in e and "order_header." not in e for e in exprs), exprs


def test_joined_qualifier_is_not_stripped():
    yaml_text, _ = _render(_spec([{"name": "Customers", "expr": "COUNT(DISTINCT dim_customer.customer_id)", "comment": "c"}]))
    assert "dim_customer.customer_id" in yaml_text and "dim_customer.customer_segment" in yaml_text


def test_joined_product_qualifier_wins_over_a_source_qualifier():
    out = ah._strip_source_product_prefix_in_expr("SUM(party.x) + SUM(sales.y)", "order_header", joined_products=["party"],
                                                  extra_prefixes={"party", "sales"})
    assert out == "SUM(party.x) + SUM(y)"


# ── 3) launch gate inside a job ───────────────────────────────────────────────────────────────
class _Opt:
    def __init__(self, v):
        self.v = v

    def get(self):
        if self.v is None:
            raise RuntimeError("None.get")
        return self.v


class _Ctx:
    def __init__(self, job_id, raise_=False):
        self.job_id, self.raise_ = job_id, raise_

    def jobId(self):
        if self.raise_:
            raise RuntimeError("py4j")
        return _Opt(self.job_id)


def test_job_run_is_detected():
    assert ah._v536_in_job_context(_Ctx(876136757631351)) is True


@pytest.mark.parametrize("ctx", [_Ctx(None), _Ctx(None, raise_=True), _Ctx("0"), _Ctx("{{job.id}}")])
def test_interactive_or_unknown_context_is_not_a_job(ctx):
    assert ah._v536_in_job_context(ctx) is False


def test_gate_runs_in_place_inside_a_job():
    src = notebook_concat_source()
    i = src.index("_v536_job_run = (not _raw_session_id_from_widget) and _v536_in_job_context()")
    j = src.index("if not _raw_session_id_from_widget and not _v536_job_run:")
    k = src.index("_launcher = JobLauncher(_nb_path, _job_widgets")
    assert i < j < k


# ── 4) self-cancel child gated on run state ───────────────────────────────────────────────────
class _Api(http.server.BaseHTTPRequestHandler):
    state, get_status, cancels = "RUNNING", 200, []

    def log_message(self, *a):
        pass

    def do_GET(self):
        body = json.dumps({"state": {"life_cycle_state": _Api.state}}).encode()
        self.send_response(_Api.get_status)
        self.end_headers()
        self.wfile.write(body if _Api.get_status == 200 else b"{}")

    def do_POST(self):
        n = int(self.headers.get("Content-Length") or 0)
        _Api.cancels.append(json.loads(self.rfile.read(n)))
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b"{}")


@pytest.fixture
def api():
    _Api.cancels, _Api.get_status = [], 200
    srv = http.server.HTTPServer(("127.0.0.1", 0), _Api)
    threading.Thread(target=srv.serve_forever, daemon=True).start()
    yield srv
    srv.shutdown()


def _child_code():
    """The -c code the production watchdog hands its self-cancel child (watchdog run with dangerous modules stubbed)."""
    from test_v385_hang_observability import _load_watchdog, _FakeLogger
    spawned = []

    class _Popen:
        def __init__(self, args, **kwargs):
            spawned.append((list(args), kwargs.get("env") or {}))

    fake_sp = types.ModuleType("subprocess")
    fake_sp.DEVNULL, fake_sp.Popen = -3, _Popen
    fake_fh = types.ModuleType("faulthandler")
    fake_fh.dump_traceback_later = lambda *a, **k: None
    with pytest.MonkeyPatch.context() as mp:
        mp.setitem(sys.modules, "subprocess", fake_sp)
        mp.setitem(sys.modules, "faulthandler", fake_fh)
        ns = _load_watchdog()
        ns["_SELF_CANCEL_CTX"].update({"run_id": "1048336217656120", "host": "https://example", "token": "tok", "_diag": {}})
        ns["_spawn_process_kill_watchdog"](grace_seconds=1, source="test", logger=_FakeLogger())
    codes = [a[2] for a, env in spawned if "SCW_RUNID" in env and len(a) > 2 and a[1] == "-c"]
    assert codes, "the watchdog did not arm the self-cancel child"
    return codes[0]


def _run_child(srv, tmp_path, ppid):
    sent = tmp_path / "sentinel.log"
    env = dict(os.environ, SCW_PPID=str(ppid), SCW_GRACE="0", SCW_HOST=f"http://127.0.0.1:{srv.server_port}",
               SCW_TOKEN="t", SCW_RUNID="1048336217656120", SCW_SENTINEL=str(sent))
    subprocess.run([sys.executable, "-c", _child_code()], env=env, timeout=60, check=True)
    return sent.read_text()


def test_cancel_fires_for_an_active_run_even_after_the_parent_exited(api, tmp_path):
    _Api.state = "RUNNING"
    log = _run_child(api, tmp_path, ppid=1)  # parent gone (the os._exit backstop already fired)
    assert _Api.cancels == [{"run_id": 1048336217656120}]
    assert "run-active RUNNING POSTED" in log


def test_no_cancel_for_a_finished_run(api, tmp_path):
    _Api.state = "TERMINATED"
    log = _run_child(api, tmp_path, ppid=os.getpid())
    assert _Api.cancels == [] and "skipped-run-not-active TERMINATED" in log


def test_falls_back_to_parent_alive_when_run_state_is_unknown(api, tmp_path):
    _Api.get_status = 500
    log = _run_child(api, tmp_path, ppid=os.getpid())  # the parent of the child is this test process
    assert _Api.cancels == [{"run_id": 1048336217656120}] and "run-state-unknown" in log


def test_watchdog_child_is_run_state_gated():
    code = _child_code()
    assert "/api/2.1/jobs/runs/get?run_id=" in code and "alive=(os.getppid()==t)" not in code

"""v5.3.6 — joined columns survive the pre-install prune; the launch gate runs in place inside a job.

Live (pension_fund_investment_company v9 -> v10, agent 5.3.5, 2026-11-11, child run 1048336217656120): three
user-named metric views rendered their joins (metric-view-joins-render FIRED x3) and installed WITH the joins, but
  * mv-column-prevalidate-prune checked every column against the SOURCE table only and pruned every joined dimension
    ("physical `performance.portfolio_return` missing col(s) ['portfolio_name']", same for factor_name, gics_sector);
  * ColCheck dropped AVG(performance.twr_net): the LLM qualified a source column with the source's domain/schema,
    and only the product name, `source` and LLM aliases were stripped (mv-cross-table-measure-drop {'performance'}).
The parent (launch gate) ended 15s after the child, so v5.3.5 holds; but a job run with an empty vibe_session_id
still launches a second job for the same work.

FIX:
  1. _mv_prevalidate_join_targets + _mv_prevalidate_bad_refs: the prune checks `alias.col` against THAT join's physical table, and
     `source.col` / unknown-qualifier refs against the source as before (alias=mv-prevalidate-joined-ref).
  2. The source's domain, schema and table name are source qualifiers too; the strip repeats until stable so
     domain.table.col becomes col; a joined product keeps its qualifier (alias=mv-source-domain-prefix-rewrite).
  3. _v536_in_job_context: with an empty session id inside a job run, the gate runs the work in place instead of
     launching a child job (alias=joblaunch-gate-skip-in-job).
  4. The control-plane cancel child (inline in _spawn_process_kill_watchdog, which must stay self-contained) checks whether the run is still active
     (runs/get) instead of whether the parent PID is alive, so the 600s os._exit backstop can no longer stop the
     660s cancel; parent-alive is the fallback when runs/get fails (alias=self-cancel-run-state-gate).
Industry-agnostic: no model, domain or product names.
"""
import json

NB = "agent/dbx_vibe_modelling_agent.ipynb"
TAG = "patch_v536"
raw = open(NB, encoding="utf-8").read()  # raw-text edit (see patch_v534_mv_joins_enabled.py)
json.loads(raw)


def _enc(s):
    return '",\n    "'.join(json.dumps(p, ensure_ascii=False)[1:-1] for p in s.splitlines(keepends=True))


def repl(old, new, label, count=1):
    global raw
    o, n_ = _enc(old), _enc(new)
    n = raw.count(o)
    if n != count:
        raise SystemExit(f"[{TAG}] '{label}' count={n} (expected {count})")
    raw = raw.replace(o, n_)


repl('__AGENT_VERSION__ = "5.3.5"', '__AGENT_VERSION__ = "5.3.6"', "version")

# ── 1) prune: joined refs checked against the join's table ────────────────────────────────────
repl("def step_apply_metric_views(widgets_values):\n", r'''_V536_SOURCE_LINE_RE = re.compile(r'(?is)source:\s*"`?([a-z_][a-z0-9_]*)`?\s*\.\s*`?([a-z_][a-z0-9_]*)`?\s*\.\s*`?([a-z_][a-z0-9_]*)`?`?"')
_V536_QUALIFIED_RE = re.compile(r'\b([a-z_][a-z0-9_]*)\s*\.\s*([a-z_][a-z0-9_]*)\b')
_V536_TOKEN_RE = re.compile(r'\b([a-z_][a-z0-9_]*)\b')


def _mv_prevalidate_join_targets(stmt):
    """{join alias: (schema, table)} for every join in a rendered metric view, nested joins included."""
    out, in_joins, joins_indent, alias = {}, False, None, None
    for line in str(stmt or "").split("\n"):
        body = line.strip()
        if not body:
            continue
        indent = len(line) - len(line.lstrip())
        if not in_joins:
            if body == "joins:":
                in_joins, joins_indent = True, indent
            continue
        if indent <= joins_indent and not body.startswith("-"):
            break
        m = re.match(r'(?:-\s*)?name:\s*"?([A-Za-z_][A-Za-z0-9_]*)"?\s*$', body)
        if m:
            alias = m.group(1).lower()
            continue
        s = _V536_SOURCE_LINE_RE.match(body)
        if s and alias:
            out[alias] = (s.group(2).lower(), s.group(3).lower())
    return out


def _mv_prevalidate_bad_refs(expr_raw, src_cols, params=(), sql_keywords=(), join_cols=None):
    """Column refs in a metric-view expr that the physical tables cannot resolve. `alias.col` is checked against
    that join's columns (an unknown column set keeps the ref); every other ref against the source columns
    (alias=mv-prevalidate-joined-ref)."""
    join_cols = {str(k).lower(): v for k, v in (join_cols or {}).items()}
    ec = re.sub(r"'[^'\n]*'", ' ', str(expr_raw or ''))
    ec = re.sub(r'"[^"\n]*"', ' ', ec).lower()
    fns = set(m.group(1) for m in re.finditer(r'\b([a-z_][a-z0-9_]*)\s*\(', ec))
    bad = set()

    def _q(m):
        qual, col = m.group(1), m.group(2)
        if qual in join_cols:
            cols = join_cols[qual]
            if cols and col not in cols:
                bad.add(f"{qual}.{col}")
            return ' '
        return ' ' + col  # source.col, or a qualifier we cannot place: check the column against the source
    prev = None
    while prev != ec:
        prev, ec = ec, _V536_QUALIFIED_RE.sub(_q, ec)
    for m in _V536_TOKEN_RE.finditer(ec):
        t = m.group(1)
        if t in sql_keywords or t in fns or t.isdigit():
            continue
        if t not in src_cols and t not in params:
            bad.add(t)
    return bad


def step_apply_metric_views(widgets_values):
''', "prune-helpers")

repl('''                def _mvcp_bad_in_expr(_expr_raw):
                    _ec = _mvcp_re.sub(r"'[^'\\n]*'", ' ', _expr_raw)
                    _ec = _mvcp_re.sub(r'"[^"\\n]*"', ' ', _ec)
                    _fns = set(_fm.group(1) for _fm in _mvcp_re.finditer(r'\\b([a-z_][a-z0-9_]*)\\s*\\(', _ec.lower()))
                    _ec = _mvcp_re.sub(r'\\b([a-z_][a-z0-9_]*)\\s*\\.', ' ', _ec)
                    _bad = set()
                    for _tm in _mvcp_token_re.finditer(_ec.lower()):
                        _t = _tm.group(1)
                        if _t in _mvcp_SQL_KW or _t in _fns or _t.isdigit():
                            continue
                        if _t not in _src_cols and _t not in _mvcp_params:
                            _bad.add(_t)
                    return _bad
''', '''                # v5.3.6 alias=mv-prevalidate-joined-ref: a joined column is checked against its join's table
                _mvcp_join_cols = {_a: _mvcp_get_cols(_s, _t) for _a, (_s, _t) in _mv_prevalidate_join_targets(_stmt).items()}
                if _mvcp_join_cols:
                    logger.info(f"  [mv-prevalidate-joined-ref FIRED v5.3.6] {_extract_metric_view_name_from_statement(_stmt)}: joined refs checked against {sorted(_mvcp_join_cols)} alias=mv-prevalidate-joined-ref")
                def _mvcp_bad_in_expr(_expr_raw):
                    return _mv_prevalidate_bad_refs(_expr_raw, _src_cols, _mvcp_params, _mvcp_SQL_KW, _mvcp_join_cols)
''', "prune-wiring")

# ── 2) the source's domain / schema / table are source qualifiers; strip until stable ─────────
repl('''        if qual.lower() in _prefixes_to_strip:
''', '''        if qual.lower() in _prefixes_to_strip and qual.lower() not in _prefixes_to_keep:
''', "strip-keep-wins")
repl('''    return _pat.sub(_sub, expr)

def _rewrite_column_refs_in_expr(expr, col_rewrite_map):
''', '''    # v5.3.6 alias=mv-source-domain-prefix-rewrite: repeat so domain.table.col strips to col
    for _ in range(3):
        _new = _pat.sub(_sub, expr)
        if _new == expr:
            break
        expr = _new
    return expr

def _rewrite_column_refs_in_expr(expr, col_rewrite_map):
''', "strip-multipass")
repl('''        _mv_src_aliases = {'source'}  # v5.3.4 alias=mv-join-on-source-alias
''', '''        _mv_src_aliases = {'source'}  # v5.3.4 alias=mv-join-on-source-alias
        # v5.3.6 alias=mv-source-domain-prefix-rewrite: AVG(performance.twr_net) names a source column
        _mv_src_qualifiers = {str(_q).lower() for _q in (domain_name, _src_db, source_table) if _q}
''', "src-qualifiers")
repl("extra_prefixes=_mv_src_aliases,", "extra_prefixes=_mv_src_aliases | (_mv_src_qualifiers - set(_mv_alias_cols)),",
     "strip-call-sites", count=3)

# ── 3) + 4) launch gate in a job; run-state-gated cancel child ────────────────────────────────
repl("def _v459_resolve_self_cancel_run_id(", '''def _v536_in_job_context(ctx=None):
    """True when this notebook runs as a Databricks job run (ctx.jobId() works on serverless)."""
    try:
        if ctx is None:
            ctx = dbutils.notebook.entry_point.getDbutils().notebook().getContext()
        jid = ctx.jobId()
        try:
            jid = jid.get()
        except Exception:
            pass
        jid = str(jid or "").strip()
        return jid.isdigit() and int(jid) > 0
    except Exception:
        return False


def _v459_resolve_self_cancel_run_id(''', "gate-helper")

repl('''                _sc_stmts = [
                    "import os,time,json,urllib.request",
                    "t=int(os.environ['SCW_PPID']); g=int(os.environ['SCW_GRACE'])",
                    "time.sleep(g)",
                    "host=os.environ['SCW_HOST']; tok=os.environ['SCW_TOKEN']; rid=os.environ['SCW_RUNID']; sent=os.environ.get('SCW_SENTINEL','')",
                    "alive=(os.getppid()==t)",
                    "_st='skipped-parent-exited'",
                    "if alive:",
                    " try:",
                    "  req=urllib.request.Request(host+'/api/2.1/jobs/runs/cancel', data=json.dumps({'run_id':int(rid)}).encode(), headers={'Authorization':'Bearer '+tok,'Content-Type':'application/json'}, method='POST')",
                    "  _r=urllib.request.urlopen(req,timeout=30); _st='POSTED http='+str(_r.getcode())",
                    " except Exception as _e:",
                    "  _st='ERROR '+type(_e).__name__+' '+str(_e)[:200]",
                    "if sent:",
                    " try: open(sent,'a').write('[self-cancel-subproc] run_id='+str(rid)+' '+_st+chr(10))",
                    " except Exception: pass",
                ]
                _sc_code = chr(10).join(_sc_stmts)
''', '''                # v5.3.6 alias=self-cancel-run-state-gate: cancel only while the RUN is still active (runs/get), so the
                # 600s os._exit backstop killing this process can no longer stop the 660s cancel; parent-alive is the
                # fallback when runs/get fails. Kept inline: this function must stay self-contained.
                _sc_stmts = [
                    "import os,time,json,urllib.request",
                    "t=int(os.environ['SCW_PPID']); g=int(os.environ['SCW_GRACE'])",
                    "time.sleep(g)",
                    "host=os.environ['SCW_HOST']; tok=os.environ['SCW_TOKEN']; rid=os.environ['SCW_RUNID']; sent=os.environ.get('SCW_SENTINEL','')",
                    "try:",
                    " q=urllib.request.Request(host+'/api/2.1/jobs/runs/get?run_id='+rid, headers={'Authorization':'Bearer '+tok})",
                    " lcs=json.loads(urllib.request.urlopen(q,timeout=30).read()).get('state',{}).get('life_cycle_state','')",
                    " active=lcs in ('PENDING','QUEUED','RUNNING','TERMINATING','BLOCKED','WAITING_FOR_RETRY')",
                    " _st=('run-active ' if active else 'skipped-run-not-active ')+lcs",
                    "except Exception as _e:",
                    " active=(os.getppid()==t)",
                    " _st='run-state-unknown '+type(_e).__name__+(' parent-alive' if active else ' skipped-parent-exited')",
                    "if active:",
                    " try:",
                    "  req=urllib.request.Request(host+'/api/2.1/jobs/runs/cancel', data=json.dumps({'run_id':int(rid)}).encode(), headers={'Authorization':'Bearer '+tok,'Content-Type':'application/json'}, method='POST')",
                    "  _r=urllib.request.urlopen(req,timeout=30); _st=_st+' POSTED http='+str(_r.getcode())",
                    " except Exception as _e:",
                    "  _st=_st+' ERROR '+type(_e).__name__+' '+str(_e)[:200]",
                    "if sent:",
                    " try: open(sent,'a').write('[self-cancel-subproc] run_id='+str(rid)+' '+_st+chr(10))",
                    " except Exception: pass",
                ]
                _sc_code = chr(10).join(_sc_stmts)
''', "cancel-child-inline")

repl('''    if not _raw_session_id_from_widget:
        # ── v4.9.6 Widget Pre-Flight Validation (alias=widget-preflight-validate) ──
''', '''    # v5.3.6 alias=joblaunch-gate-skip-in-job: an empty session id inside a job run is not an interactive
    # run; launching a child job would only duplicate the work (and the parent is what used to hang).
    _v536_job_run = (not _raw_session_id_from_widget) and _v536_in_job_context()
    if _v536_job_run:
        print("[joblaunch-gate-skip-in-job FIRED v5.3.6] empty vibe_session_id inside a job run: running in place, no child job alias=joblaunch-gate-skip-in-job")
    if not _raw_session_id_from_widget and not _v536_job_run:
        # ── v4.9.6 Widget Pre-Flight Validation (alias=widget-preflight-validate) ──
''', "gate-wiring")

json.loads(raw)
open(NB, "w", encoding="utf-8").write(raw)
print(f"[{TAG}] applied")

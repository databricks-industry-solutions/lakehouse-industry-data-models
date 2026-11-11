"""v5.3.4 — metric-view joins ON by default, with source-alias normalization and a many-to-one guard.

Live probe (2026-11-09, DBR SQL warehouse, YAML version 1.1) of the exact YAML the renderer emits:
  * name/source/'on'/rely.at_most_one_match joins install and query, cross-schema, with joined columns
    in dimensions, measures and filter;
  * a join alias that prefixes a fact column (customer vs customer_id) is fine;
  * the ONLY failing shape is an LLM-invented alias for the primary table in the join condition
    (`o.customer_id = dim_customer.customer_id`) -> UNRESOLVED_COLUMN `o`.`customer_id`,
    the same signature as the v1.0.0 run that got joins disabled (`i`.`order_id` ... did you mean `ord`...).
So joins were never broken; the primary-table alias was never rewritten to `source`. This patch:
  1. MV_ENABLE_JOINS defaults to True (config can still set False).
  2. _mv_normalize_join_on rewrites every non-join qualifier in `on` to `source.` (and bare source columns
     to `source.<col>`), returns the qualifiers it rewrote so dims/measures/filter strip them too.
  3. Many-to-one guard: the join's target-side columns must include the target product's primary key,
     else the join is skipped (a fan-out join silently double-counts every SUM/COUNT).
  4. alias.col references are checked against THAT alias's target columns (not the merged set).
  5. _rewrite_column_refs_in_expr never rewrites a qualified token (alias or alias.col).
  6. Both MV prompts replace the "JOINS ARE DISABLED" hard rule with star-schema join rules.
Industry-agnostic: no model, domain or product names.
"""
import json
import sys

NB = "agent/dbx_vibe_modelling_agent.ipynb"
TAG = "patch_v534"
# Edit the RAW notebook text, not a json round-trip: the file mixes literal and escaped non-ASCII line by line, so any
# re-dump rewrites ~1.5k unrelated lines. A snippet is encoded into the file's source-line-list form and replaced in
# place, so the diff carries only the changed lines.
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


def repl_span(start, end, new, label):
    """Replace text from `start` (inclusive, at a line start) to `end` (exclusive, at a line start)."""
    global raw
    s, e = _enc(start), _enc(end)
    if raw.count(s) != 1:
        raise SystemExit(f"[{TAG}] '{label}' start count={raw.count(s)}")
    a = raw.index(s)
    b = raw.index(e, a)
    if not new.endswith("\n"):
        raise SystemExit(f"[{TAG}] '{label}' replacement must end at a line end")
    raw = raw[:a] + _enc(new) + '",\n    "' + raw[b:]


# ── 1) version ────────────────────────────────────────────────────────────────────────────────
repl('__AGENT_VERSION__ = "5.3.3"', '__AGENT_VERSION__ = "5.3.4"', "version")

# ── 2) helpers, placed right after _emit_mv_joins_yaml ─────────────────────────────────────────
HELPERS = r'''

_MV_JOIN_ON_WORDS = frozenset({"and", "or", "not", "is", "null", "true", "false", "in", "between", "like", "source",
                               "cast", "as", "coalesce", "lower", "upper", "trim", "date", "timestamp"})


def _mv_attr_is_pk(a):
    """True when an attribute dict is its product's primary key (tag, flag or tag_set)."""
    if not isinstance(a, dict):
        return False
    if a.get("is_primary_key") or a.get("is_pk") or a.get("primary_key") is True:
        return True
    _tags = str(a.get("tags") or "").lower().replace(" ", "").split(",")
    if "primary_key" in _tags:
        return True
    for _t in (a.get("tag_set") or []):
        if isinstance(_t, dict) and str(_t.get("key") or "").lower() == "primary_key":
            return True
    return False


def _mv_target_columns(target_obj, target_attrs):
    """(all columns, primary-key columns) of a join target, lower-cased. Empty sets when unknown."""
    cols, pks = set(), set()
    for a in (target_attrs or []):
        if not isinstance(a, dict):
            continue
        cn = str(a.get("column_name") or a.get("attribute") or a.get("name") or "").strip().lower()
        if cn:
            cols.add(cn)
            if _mv_attr_is_pk(a):
                pks.add(cn)
    _pk = (target_obj or {}).get("primary_key") if isinstance(target_obj, dict) else None
    if isinstance(_pk, str) and _pk.strip():
        pks.add(_pk.strip().lower())
    return cols, pks


def _mv_normalize_join_on(on_expr, join_alias, source_columns=None):
    """v5.3.4 alias=mv-join-on-source-alias. In a UC metric view the primary table is ALWAYS `source`.
    LLMs alias it (`i.order_id`, `mc.security_id`, `<product>.col`) and the runtime then fails with
    UNRESOLVED_COLUMN — the v1.0.0 failure that got joins disabled. Rewrite every qualifier that is not
    this join's alias to `source.`, and a bare column of the source table to `source.<col>`.
    Returns (normalized_on, rewritten_source_qualifiers, target_columns_referenced)."""
    if not on_expr or not join_alias:
        return on_expr, set(), set()
    _ja = join_alias.lower()
    _src_quals, _tgt_cols = set(), set()
    _q_re = re.compile(r'(?<![A-Za-z0-9_.])([A-Za-z_][A-Za-z0-9_]*)\.([A-Za-z_][A-Za-z0-9_]*)')

    def _q(m):
        q, c = m.group(1), m.group(2)
        if q.lower() == _ja:
            _tgt_cols.add(c.lower())
            return f"{join_alias}.{c}"
        if q.lower() != "source":
            _src_quals.add(q)
        return f"source.{c}"
    out = _q_re.sub(_q, on_expr.replace("`", ""))
    _src_low = {str(c).lower() for c in (source_columns or [])}
    if _src_low:
        def _b(m):
            tok = m.group(1)
            if tok.lower() in _MV_JOIN_ON_WORDS or tok.lower() not in _src_low:
                return tok
            return f"source.{tok}"
        out = re.sub(r'(?<![A-Za-z0-9_.\'"])([A-Za-z_][A-Za-z0-9_]*)(?![A-Za-z0-9_.(\'"])', _b, out)
    return out, _src_quals, _tgt_cols


def _mv_bad_joined_refs(expr, alias_cols):
    """v5.3.4 alias=mv-joined-ref-check. `alias.col` refs whose column is not on THAT alias's target table.
    The merged valid_columns set would accept a source column under a join alias; the runtime would not."""
    if not expr or not alias_cols:
        return set()
    cleaned = re.sub(r"'[^']*'", "", expr)
    bad = set()
    for q, c in re.findall(r'(?<![A-Za-z0-9_.])([A-Za-z_][A-Za-z0-9_]*)\.([A-Za-z_][A-Za-z0-9_]*)', cleaned):
        _cols = alias_cols.get(q.lower())
        if _cols and c.lower() not in _cols:
            bad.add(f"{q}.{c}")
    return bad
'''
repl("\ndef _is_metric_dimension_eligible(col_lower, pk_suffix='_id'):",
     HELPERS + "\ndef _is_metric_dimension_eligible(col_lower, pk_suffix='_id'):", "helpers")

# ── 3) prefix stripper accepts extra prefixes (the source aliases discovered in join conditions) ──
repl("def _strip_source_product_prefix_in_expr(expr, source_product, joined_products=None, logger=None, view_context=\"\"):\n"
     "    if not expr or not source_product:\n        return expr\n    _prefixes_to_strip = {source_product.lower()}\n",
     "def _strip_source_product_prefix_in_expr(expr, source_product, joined_products=None, logger=None, view_context=\"\", extra_prefixes=None):\n"
     "    if not expr or not source_product:\n        return expr\n    _prefixes_to_strip = {source_product.lower()}\n"
     "    # v5.3.4 alias=mv-join-on-source-alias: `source.` and any alias the LLM gave the primary table\n"
     "    _prefixes_to_strip |= {str(_p).lower() for _p in (extra_prefixes or []) if _p}\n",
     "strip-extra-prefixes")

# ── 4) column rewriter leaves qualified tokens alone ──────────────────────────────────────────
repl("        token = m.group(1)\n        if token.upper() in _METRIC_SQL_KEYWORDS or token in func_names or token.isdigit():\n            continue\n"
     "        canonical = col_rewrite_map.get(token.lower()) or col_rewrite_map.get(token.lower().replace('_', ''))\n",
     "        token = m.group(1)\n        if token.upper() in _METRIC_SQL_KEYWORDS or token in func_names or token.isdigit():\n            continue\n"
     "        # v5.3.4 alias=mv-rewrite-skip-qualified: a join alias or a joined table's column is not a source column\n"
     "        if (m.start() > 0 and cleaned_for_parse[m.start() - 1] == '.') or (m.end() < len(cleaned_for_parse) and cleaned_for_parse[m.end()] == '.'):\n"
     "            continue\n"
     "        canonical = col_rewrite_map.get(token.lower()) or col_rewrite_map.get(token.lower().replace('_', ''))\n",
     "rewrite-skip-qualified")

# ── 5) renderer: flag default ON, normalize on, many-to-one guard ─────────────────────────────
repl("        _valid_joins = []\n        # iteration whenever the LLM emitted joins that we are intentionally suppressing.\n"
     "        if isinstance(_mv_joins_raw, list) and _mv_joins_raw:\n"
     "            logger.info(f\"[Metrics][LLM] [mv-joins-disabled-pending-syntax-fix FIRED] domain='{domain_name}' view='{raw_view_name}' suppressed_joins={len(_mv_joins_raw)} (joins disabled until syntax verified live)\")\n",
     "        _valid_joins = []\n"
     "        _mv_src_aliases = {'source'}  # v5.3.4 alias=mv-join-on-source-alias\n"
     "        _mv_alias_cols = {}  # v5.3.4 alias=mv-joined-ref-check\n"
     "        # v5.3.4 alias=mv-joins-default-on: a live probe proved the emitted join YAML installs; default ON.\n"
     "        _mv_joins_on = bool((config or {}).get('MV_ENABLE_JOINS', True))\n"
     "        if isinstance(_mv_joins_raw, list) and _mv_joins_raw and not _mv_joins_on:\n"
     "            logger.info(f\"[Metrics][LLM] [mv-joins-disabled-pending-syntax-fix FIRED] domain='{domain_name}' view='{raw_view_name}' suppressed_joins={len(_mv_joins_raw)} (MV_ENABLE_JOINS=False)\")\n",
     "joins-default-on")
repl("        if config.get('MV_ENABLE_JOINS') and isinstance(_mv_joins_raw, list) and _mv_joins_raw:\n",
     "        if _mv_joins_on and isinstance(_mv_joins_raw, list) and _mv_joins_raw:\n",
     "joins-gate")
repl("                _t_table = _j_target_obj.get('table_name') or _j_target_obj.get('product') or _j_target_prod\n"
     "                _valid_joins.append({\n",
     "                _t_table = _j_target_obj.get('table_name') or _j_target_obj.get('product') or _j_target_prod\n"
     "                # v5.3.4 alias=mv-join-on-source-alias + mv-join-many-to-one\n"
     "                _j_attrs = ((config or {}).get('_metric_view_all_attrs_by_key') or {}).get(_j_target_key, [])\n"
     "                _j_tcols, _j_tpks = _mv_target_columns(_j_target_obj, _j_attrs)\n"
     "                _j_on_norm, _j_src_q, _j_tused = _mv_normalize_join_on(_j_on, _j_alias, valid_columns)\n"
     "                if _j_tcols and not _j_tused <= _j_tcols:\n"
     "                    logger.warning(f\"[Metrics][LLM][joins] [mv-join-many-to-one FIRED] Skipping join '{_j_alias}' in '{domain_name}/{raw_view_name}': condition columns {sorted(_j_tused - _j_tcols)} are not on {_j_target_key} alias=mv-join-many-to-one\")\n"
     "                    continue\n"
     "                if _j_tpks and not (_j_tused & _j_tpks):\n"
     "                    logger.warning(f\"[Metrics][LLM][joins] [mv-join-many-to-one FIRED] Skipping join '{_j_alias}' in '{domain_name}/{raw_view_name}': condition {_j_on_norm!r} does not reach the primary key {sorted(_j_tpks)} of {_j_target_key}, so it could fan out and double-count alias=mv-join-many-to-one\")\n"
     "                    continue\n"
     "                if _j_on_norm != _j_on:\n"
     "                    logger.info(f\"[Metrics][LLM][joins] [mv-join-on-source-alias FIRED] '{domain_name}/{raw_view_name}' join '{_j_alias}': {_j_on!r} -> {_j_on_norm!r} alias=mv-join-on-source-alias\")\n"
     "                _j_on = _j_on_norm\n"
     "                _mv_src_aliases |= {_q for _q in _j_src_q if _q.lower() not in {(_x.get('alias') or '').lower() for _x in _mv_joins_raw if isinstance(_x, dict)}}\n"
     "                if _j_tcols:\n"
     "                    _mv_alias_cols[_j_alias.lower()] = _j_tcols\n"
     "                _valid_joins.append({\n",
     "join-normalize")

# ── 6) dims / measures / filter: strip the source aliases, check alias.col against that alias ────
repl('joined_products=[_j.get("right_product") for _j in (_valid_joins or []) if isinstance(_j, dict)], logger=logger, view_context=',
     'joined_products=[_j.get("right_product") for _j in (_valid_joins or []) if isinstance(_j, dict)], extra_prefixes=_mv_src_aliases, logger=logger, view_context=',
     "strip-call-sites", count=3)
repl("                _filter_refs = _extract_column_refs_from_expr(metric_filter)\n                _bad_filter = _filter_refs - valid_columns\n",
     "                _filter_refs = _extract_column_refs_from_expr(metric_filter)\n                _bad_filter = (_filter_refs - valid_columns) | _mv_bad_joined_refs(metric_filter, _mv_alias_cols)\n",
     "filter-joined-check")
repl("                col_refs = _extract_column_refs_from_expr(dim_expr)\n                bad_cols = col_refs - valid_columns\n",
     "                col_refs = _extract_column_refs_from_expr(dim_expr)\n                bad_cols = (col_refs - valid_columns) | _mv_bad_joined_refs(dim_expr, _mv_alias_cols)\n",
     "dim-joined-check")
repl("                col_refs = _extract_column_refs_from_expr(meas_expr)\n                bad_cols = col_refs - valid_columns\n",
     "                col_refs = _extract_column_refs_from_expr(meas_expr)\n                bad_cols = (col_refs - valid_columns) | _mv_bad_joined_refs(meas_expr, _mv_alias_cols)\n",
     "meas-joined-check")

# ── 7) prompts ───────────────────────────────────────────────────────────────────────────────
JOIN_RULES = r"""### STAR-SCHEMA JOINS — ALLOWED, MANY-TO-ONE ONLY (v5.3.4 alias=mv-prompt-joins-enabled)

Joins are rendered into the Unity Catalog metric-view `joins:` block. Use one when a KPI needs a column (a slicer, a
rate, a classification) that lives on a PARENT table the source row points at through a foreign key.

**RULES:**
1. Join ONLY along a declared foreign key, FROM the source (the child row that holds the FK column) TO the parent's
   primary key: `"on": "source.<fk_column> = <alias>.<parent_pk>"`. Never join to a child / detail table — a
   one-to-many join fans out and silently double-counts every SUM and COUNT (such joins are skipped at render).
2. The source table is ALWAYS called `source`. Never invent an alias for it. In dimensions and measures reference
   source columns BARE (`amount`) and joined columns with the join alias (`dim_customer.segment`).
3. Name each alias `dim_<target_product>`; each join entry is
   `{{"alias": "dim_<target_product>", "target_domain": "<domain>", "target_product": "<product>", "on": "source.<fk> = dim_<target_product>.<pk>", "type": "LEFT"}}`.
4. Reference ONLY columns that exist on the joined product (see the model column lists). A wrong `alias.column` drops
   that dimension or measure.
5. Prefer a single-table view when the source already carries the columns. Join when the KPI genuinely needs the parent
   (e.g. a classification held only on the parent, a rate from a reference series, a consensus figure to compare to).
6. Leave `joins` as `[]` when no join is needed.

"""
repl_span("### SINGLE-TABLE METRIC VIEWS ONLY — JOINS ARE DISABLED (v1.0.4 mv-prompt-joins-disabled)",
          "**Domain Metric Type Matrix (MANDATORY FOR EXPRESSION VALIDATION):**", JOIN_RULES, "domain-prompt-joins")
repl_span("### SINGLE-TABLE KPIs ONLY — JOINS ARE DISABLED (v1.0.4 mv-prompt-joins-disabled)",
          "### COLUMN REFERENCE RULES", JOIN_RULES, "kpi-prompt-joins")
repl('- For source-table columns: bare names work (`leg.scheduled_departure_time`).\n',
     '- For source-table columns: use bare names (`scheduled_departure_time`); never an alias for the source table.\n',
     "kpi-col-rule")
repl('      "joins": [{{}}],\n      "dimensions": [\n        {{"name": "Region", "expr": "leg.origin_region_code", "comment": "Originating region for slicing"}}\n',
     '      "joins": [{{"alias": "dim_<parent_product>", "target_domain": "<parent_domain>", "target_product": "<parent_product>", "on": "source.<fk_column> = dim_<parent_product>.<parent_pk>", "type": "LEFT"}}],\n'
     '      "dimensions": [\n        {{"name": "Region", "expr": "dim_<parent_product>.<region_column>", "comment": "Region held on the parent row, reached through the FK join"}}\n',
     "kpi-example")
repl('{{"name": "OTP D-15 %", "expr": "ROUND(100.0 * SUM(CASE WHEN leg.actual_arrival_delay_min <= 15',
     '{{"name": "OTP D-15 %", "expr": "ROUND(100.0 * SUM(CASE WHEN actual_arrival_delay_min <= 15',
     "kpi-example-measure")

json.loads(raw)  # must still parse after
with open(NB, "w", encoding="utf-8") as f:
    f.write(raw)
print(f"[{TAG}] applied")

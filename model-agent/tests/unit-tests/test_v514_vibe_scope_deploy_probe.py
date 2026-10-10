"""v5.1.4 deploy fixes from the 2026-10-08 live Unity Catalog probe (fixtures/v514_uc_probe_errors.json).

The UCSpark double in vibe_scope_deploy_harness replays what the probe measured: a parent CREATE OR REPLACE keeps the
child FKs only while the PK keeps its name and columns, a changed PK or a dropped parent deletes them silently, a duplicate
FK / existing column / missing parent raise the probe's texts, and serverless errors carry the JVM frame
QueryExecution.scala:2504. information_schema is answered by sqlite, so the agent's SQL joins run as written.

- probe item 3: P4 columns are added one statement per column; FIELD_ALREADY_EXISTS counts only when the column is read
  back with the expected type; errors are classified by error class, never by text inside a dumped description.
- probe item 4: transient matching uses HTTP status context, error class or SQLSTATE, never digits in a stack frame.
- probe item 5: a parent PK type change replaces the in-scope children; a failed FK re-add is an ERROR and is recorded.
- probe item 6: a removed in-scope table is dropped only after its inbound FKs from preserved tables are unlinked.
- probe item 9: physical FKs are resolved by catalog, schema and constraint name on both sides.
- probe item 10: the catalog quota error says so.
"""
import copy
import json
import logging
import re
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent))
import conftest  # noqa: F401,E402
import agent_helpers as ah  # noqa: E402
import vibe_scope_deploy_harness as h  # noqa: E402
from notebook_source_util import notebook_concat_source  # noqa: E402

P = h.PROBE
W = P["warehouse"]
S = P["serverless"]
VIEWS = ["crew_roster_kpis", "flight_crew_coverage", "fleet_utilization"]
STALE = {"skyline.crew.team_notes": ["note_id"], "skyline.flight.ops_scratch": ["scratch_id"]}
SCHED = "skyline.flight.scheduled_flight"


@pytest.fixture(autouse=True)
def _reset_runtime(monkeypatch):
    ah.set_vibe_scope_runtime(None)
    monkeypatch.setattr(ah.time, "sleep", lambda *_a, **_k: None)
    yield
    ah.set_vibe_scope_runtime(None)


def _serverless(key):
    rec = S[key]
    return h.UCError(rec["str_e_head"] + "\n" + h.RUNCOMMAND_FRAME, rec["getCondition"], rec["getSqlState"])


def _root(model, facts):
    root = copy.deepcopy(model)
    root["_vibe_scope"] = copy.deepcopy(facts)
    return root


def _deploy(monkeypatch, spark, *, base=None, final=None, facts=None, max_retries=None):
    base = base or h.base_model()
    final = final or h.scoped_final_model()
    facts = facts or h.scoped_facts()
    ah.set_vibe_scope_runtime(ah.build_vibe_scope_fence(ah.parse_vibe_scope("Some Domains", "crew"), base, h.VOV, h.LOG))
    wv = h.flat_widgets(final, spark=spark, facts=copy.deepcopy(facts), statement_model=base)
    if max_retries is not None:
        wv["config"] = dict(wv["config"], MAX_RETRIES=max_retries)
    res = h.run_deploy_steps(wv, spark, _root(final, facts), lambda name, value: monkeypatch.setitem(ah.__dict__, name, value))
    res["widgets"] = wv
    res["plan"] = wv["_vibe_scope_deploy_plan"]
    return res


def _ddl(res):
    return [s for s in res["statements"] if s.upper().startswith(("CREATE", "ALTER", "DROP"))]


def _messages(caplog, needle):
    return [r for r in caplog.records if needle in r.getMessage()]


def _with_second_p4(model=None, facts=None):
    final = copy.deepcopy(model or h.scoped_final_model())
    sched = final["model"]["domains"][1]["products"][0]
    sched["attributes"].append(h._col("standby_roster_id", "BIGINT", fk="crew.roster.roster_id"))
    facts = copy.deepcopy(facts or h.scoped_facts())
    facts["permitted_deltas"].append({"kind": "P4", "domain": "flight", "product": "scheduled_flight", "attribute": "standby_roster_id",
                                      "old_fk": "", "new_fk": "crew.roster.roster_id", "view_name": None,
                                      "cause": ah._VIBE_SCOPE_PERMIT_CAUSES["P4"]})
    return final, facts


class _NoColumnProbe(h.UCSpark):
    def sql(self, stmt):
        if "information_schema.columns" in str(stmt) and "LOWER(table_name) IN" in str(stmt):
            self.record(str(stmt))
            raise RuntimeError("[INTERNAL_ERROR] information_schema.columns is temporarily unreadable")
        return super().sql(stmt)


def _uc(cls=h.UCSpark, base=None, **kwargs):
    return cls.from_model(base or h.base_model(), extra_tables=STALE, views=VIEWS, **kwargs)


# ------------------------------------------------------------------------------------------------ error classification


@pytest.mark.parametrize("text,cls,state", [
    (W["U01_create_catalog_quota"], "QUOTA_EXCEEDED.UC_RESOURCE_QUOTA_EXCEEDED", ""),
    (W["U13_constraint_exists"], "DELTA_CONSTRAINT_ALREADY_EXISTS", ""),
    (W["U18_field_exists"], "FIELD_ALREADY_EXISTS", "42710"),
    (W["H6b_multi_column_field_exists"], "FIELD_ALREADY_EXISTS", "42710"),
    (W["D01_fk_parent_missing"], "TABLE_OR_VIEW_NOT_FOUND", "42P01"),
    (W["H5g_fk_type_mismatch"], "", ""),
])
def test_warehouse_probe_texts_classify_by_their_leading_error_class(text, cls, state):
    assert ah._sql_error_class(text) == cls
    assert ah._sql_error_sqlstate(text) == state
    assert ah._http_status_codes(text) == set()


@pytest.mark.parametrize("key,cls", [("S02", ""), ("S05", "DELTA_CONSTRAINT_ALREADY_EXISTS"), ("S06", "FIELD_ALREADY_EXISTS"),
                                     ("S09", "TABLE_OR_VIEW_NOT_FOUND")])
def test_serverless_probe_texts_classify_by_getcondition_and_ignore_the_2504_frame(key, cls):
    exc = _serverless(key)
    plain = RuntimeError(str(exc))
    assert "QueryExecution.scala:2504" in str(exc)
    assert ah._sql_error_class(exc) == cls and ah._sql_error_class(plain) == cls
    assert ah._http_status_codes(exc) == set() and not ah._sql_error_is_concurrent(exc)
    assert ah._sql_error_is_fk_type_mismatch(exc) == (key == "S02")


def test_a_field_exists_dump_that_mentions_table_constraints_is_still_a_column_error():
    text = S["S06"]["str_e_head"] + "\nTable Constraints: [pk_child, fk_b_child_parent_id]\n" + h.RUNCOMMAND_FRAME
    assert ah._sql_error_class(text) == "FIELD_ALREADY_EXISTS"
    assert ah._sql_error_class(text) not in ah._SQL_CONSTRAINT_EXISTS_CLASSES


@pytest.mark.parametrize("text,codes", [
    ("[REMOTE_FUNCTION_HTTP_FAILED_ERROR] The remote HTTP request failed with code 429, and error message 'limit'", {429}),
    ("Error code: 429 - {'error_code': 'REQUEST_LIMIT_EXCEEDED'}", {429}),
    ("HTTP 503 Service Unavailable", {503}),
    ("HTTP Error 504: Gateway Time-out", {504}),
    ('{"status_code": 502, "message": "bad gateway"}', {502}),
    (f"[RequestId={W['statement_id_with_429']} ErrorClass=INTERNAL] request failed", set()),
    ("Context size exceeded. Prompt size: 503 chars", set()),
    (S["S09"]["str_e_head"] + "\n" + h.RUNCOMMAND_FRAME + "\n\tat c.d.ManagedCatalogClientImpl.get(ManagedCatalogClientImpl.scala:4291)", set()),
])
def test_http_status_codes_need_status_context(text, codes):
    assert ah._http_status_codes(text) == codes


# ------------------------------------------------------------------------------------------------ probe item 3: P4 columns


def test_p4_columns_are_added_one_statement_per_column():
    final, facts = _with_second_p4()
    plan = ah._scope_deploy_plan(facts, final, h.LOG, use_runtime=False)
    _create, stmts = plan.table_statements("flight", "scheduled_flight", "`skyline`.`flight`.`scheduled_flight`",
                                           ["`flight_number` STRING COMMENT 'n'", "`rostered_roster_id` BIGINT COMMENT 'a'",
                                            "`standby_roster_id` BIGINT COMMENT 'b'"], "x")
    assert stmts == ["ALTER TABLE `skyline`.`flight`.`scheduled_flight` ADD COLUMNS (`rostered_roster_id` BIGINT COMMENT 'a');",
                     "ALTER TABLE `skyline`.`flight`.`scheduled_flight` ADD COLUMNS (`standby_roster_id` BIGINT COMMENT 'b');"]


def test_one_existing_p4_column_no_longer_blocks_the_other_when_the_column_probe_failed(monkeypatch, caplog):
    spark = _uc(_NoColumnProbe)
    spark.uc[SCHED]["cols"].append(("rostered_roster_id", "bigint"))
    final, facts = _with_second_p4()
    with caplog.at_level(logging.INFO, logger=h.LOG.name):
        res = _deploy(monkeypatch, spark, final=final, facts=facts)
    cols = dict(spark.uc[SCHED]["cols"])
    assert cols.get("standby_roster_id") == "bigint" and cols.get("rostered_roster_id") == "bigint"
    fks = {col: parent for col, parent, _pcol in spark.fks(SCHED).values()}
    assert fks.get("standby_roster_id") == "skyline.crew.roster" and fks.get("rostered_roster_id") == "skyline.crew.roster"
    assert res["plan"].summary()["failures"] == []
    assert _messages(caplog, "[add-column-exists-confirm FIRED v5.1.4]")


def test_an_existing_p4_column_with_the_wrong_type_is_an_error_and_is_recorded(monkeypatch, caplog):
    spark = _uc(_NoColumnProbe)
    spark.uc[SCHED]["cols"].append(("rostered_roster_id", "string"))
    with caplog.at_level(logging.INFO, logger=h.LOG.name):
        res = _deploy(monkeypatch, spark)
    kinds = {f["kind"] for f in res["plan"].summary()["failures"]}
    assert "add_column" in kinds
    outcomes = res["widgets"]["_vibe_scope_outcomes"]["deploy_failures"]
    assert any(f["kind"] == "add_column" and "rostered_roster_id" in f["target"] for f in outcomes)
    assert [r for r in _messages(caplog, "[add-column-exists-confirm FIRED v5.1.4]") if r.levelno == logging.ERROR]
    assert [r for r in _messages(caplog, "[vibe-scope-deploy-failure FIRED v5.1.4]") if r.levelno == logging.ERROR]


def test_a_probed_p4_column_with_the_wrong_type_is_not_added_and_is_recorded(monkeypatch):
    spark = _uc()
    spark.uc[SCHED]["cols"].append(("rostered_roster_id", "string"))
    res = _deploy(monkeypatch, spark)
    assert not [s for s in _ddl(res) if "ADD COLUMNS" in s]
    failures = res["plan"].summary()["failures"]
    assert {"kind": "add_column", "target": f"{SCHED}.rostered_roster_id",
            "error": "P4 column already exists as string; the model declares BIGINT"} in failures


def test_install_executor_accepts_field_already_exists_only_for_a_confirmed_column():
    add = "ALTER TABLE `skyline`.`flight`.`scheduled_flight` ADD COLUMNS (`rostered_roster_id` BIGINT COMMENT 'x');"
    for ctype, expected in (("bigint", 1), ("string", 0)):
        spark = _uc()
        spark.uc[SCHED]["cols"].append(("rostered_roster_id", ctype))
        failures = []
        ok = ah.execute_ddl_statements(spark, [add], mode="serial", logger=h.LOG, file_label="t",
                                       on_failure=lambda s, e: failures.append((s, e)))
        assert ok == expected
        assert [s for s, _e in failures] == ([] if expected else [add])
        assert not failures or failures[0][1].startswith("[FIELD_ALREADY_EXISTS]")


def test_ddl_runner_retry_counts_field_already_exists_only_for_a_confirmed_column():
    add = "ALTER TABLE `skyline`.`flight`.`scheduled_flight` ADD COLUMNS (`rostered_roster_id` BIGINT COMMENT 'x');"
    for ctype, expected in (("bigint", (1, 0)), ("string", (0, 1))):
        spark = _uc()
        spark.uc[SCHED]["cols"].append(("rostered_roster_id", ctype))
        assert ah._execute_sql_parallel_core(spark, [add], "T", h.LOG, 1, None, None, 60, halt_on_error=True) == expected


def test_field_already_exists_with_a_table_constraints_dump_for_a_missing_column_is_a_recorded_failure(monkeypatch):
    spark = _uc()
    real_sql = h.UCSpark.sql

    def _dumped(self, stmt):
        if "ADD COLUMNS" in str(stmt):
            self.record(str(stmt))
            raise RuntimeError(W["U18_field_exists"] + ";\nAddColumns [qualifiedcoltype(None, rostered_roster_id, LongType)]\n"
                               "Table Constraints: [pk_scheduled_flight]")
        return real_sql(self, stmt)

    monkeypatch.setattr(h.UCSpark, "sql", _dumped)
    res = _deploy(monkeypatch, spark)
    assert any(f["kind"] == "add_column" for f in res["plan"].summary()["failures"])


# ------------------------------------------------------------------------------------------------ probe item 4: transient


def test_ddl_runner_halts_on_a_deterministic_error_whose_stack_frame_contains_2504(monkeypatch):
    monkeypatch.setitem(ah.__dict__, "_tracked_sql_with_retries", lambda *a, **k: (_ for _ in ()).throw(_serverless("S02")))

    class _Spark:
        def sql(self, stmt):
            raise _serverless("S02")

    with pytest.raises(h.UCError):
        ah._execute_sql_parallel_core(_Spark(), ["ALTER TABLE x ADD CONSTRAINT y"], "T", h.LOG, 1, None, None, 60, halt_on_error=True)


def test_ddl_runner_halts_on_a_syntax_error_reported_at_position_504():
    class _Spark:
        def sql(self, stmt):
            raise RuntimeError("[PARSE_SYNTAX_ERROR] Syntax error at or near ')'. SQLSTATE: 42601 (line 3, pos 504)")

    with pytest.raises(RuntimeError, match="PARSE_SYNTAX_ERROR"):
        ah._execute_sql_parallel_core(_Spark(), ["CREATE DATABASE x"], "T", h.LOG, 1, None, None, 60, halt_on_error=True)


def test_ddl_runner_still_retries_a_real_http_503():
    calls = []

    class _Spark:
        def sql(self, stmt):
            calls.append(stmt)
            if len(calls) == 1:
                raise RuntimeError("[RequestId=1 ErrorClass=INTERNAL] HTTP 503 Service Unavailable")

    assert ah._execute_sql_parallel_core(_Spark(), ["CREATE DATABASE x"], "T", h.LOG, 1, None, None, 60, halt_on_error=True) == (1, 0)
    assert len(calls) == 2


def test_rate_limit_ladder_does_not_treat_a_429_in_a_stack_frame_as_a_rate_limit():
    text = S["S02"]["str_e_head"] + "\n\tat c.d.ManagedCatalogClientImpl.get(ManagedCatalogClientImpl.scala:4291)\n" + h.RUNCOMMAND_FRAME
    calls = []

    def _work(item):
        calls.append(item)
        raise RuntimeError(text)

    results, errors = ah.run_parallel_with_rate_limit_backoff([1], _work, start_workers=5, logger=h.LOG, return_errors=True)
    assert results == [None] and list(errors) == [0] and len(calls) == 1


def test_rate_limit_ladder_still_backs_off_on_http_429():
    calls = []

    def _work(item):
        calls.append(item)
        if len(calls) == 1:
            raise RuntimeError("[REMOTE_FUNCTION_HTTP_FAILED_ERROR] The remote HTTP request failed with code 429")
        return "ok"

    results, errors = ah.run_parallel_with_rate_limit_backoff([1], _work, start_workers=5, logger=h.LOG, return_errors=True)
    assert results == ["ok"] and errors == {} and len(calls) == 2


def test_context_ladder_raises_at_once_on_an_error_whose_only_429_is_a_request_id():
    calls = []

    def _batch(items, variant=None):
        calls.append(variant)
        raise RuntimeError(f"[RequestId={W['statement_id_with_429']} ErrorClass=PERMISSION_DENIED] endpoint access denied")

    with pytest.raises(RuntimeError, match="PERMISSION_DENIED"):
        ah.run_with_context_ladder([1, 2], _batch, logger=h.LOG)
    assert calls == ["full"]


@pytest.mark.parametrize("text,recoverable,context_limit", [
    (str(_serverless("S02")) + "\n\tat c.d.X.y(X.scala:4291)", False, False),
    (f"[RequestId={W['statement_id_with_429']} ErrorClass=PERMISSION_DENIED] denied", False, False),
    ("[REMOTE_FUNCTION_HTTP_FAILED_ERROR] The remote HTTP request failed with code 429", True, False),
    ("HTTP 400 Bad Request: prompt is too long for the context window", True, True),
    ("[UNRESOLVED_COLUMN] cannot resolve x\n\nJVM stacktrace:\n\tat a.b(C.scala:400)", False, False),
])
def test_llm_error_helpers_read_the_message_not_the_stack(text, recoverable, context_limit):
    assert ah._llm_error_is_recoverable(text) == recoverable
    assert ah._llm_error_is_context_limit(text) == context_limit


def test_verifier_transient_detector_needs_http_context_for_5xx():
    detector = ah.VibeOrchestrator._v108_is_transient_llm_error
    assert detector(RuntimeError("Context size exceeded. Model: m. Prompt size: 503 chars")) is False
    assert detector(RuntimeError("upstream returned HTTP 503 Service Unavailable")) is True
    assert detector(RuntimeError("[REMOTE_FUNCTION_HTTP_FAILED_ERROR] failed")) is True


def test_storage_root_with_403_only_in_a_stack_frame_is_still_accessible(monkeypatch):
    class _Fs:
        def ls(self, path):
            raise RuntimeError("[INTERNAL_ERROR] listing failed\n\nJVM stacktrace:\n\tat com.d.DbfsUtils.ls(DbfsUtils.scala:4031)")

    monkeypatch.setitem(ah.__dict__, "dbutils", type("D", (), {"fs": _Fs()})())
    assert ah._validate_storage_accessible("abfss://x@y/z", logger=h.LOG) is True

    class _Denied:
        def ls(self, path):
            raise RuntimeError("Operation failed: HTTP 403 for abfss://x@y/z")

    monkeypatch.setitem(ah.__dict__, "dbutils", type("D", (), {"fs": _Denied()})())
    assert ah._validate_storage_accessible("abfss://x@y/z", logger=h.LOG) is False


def test_no_bare_http_status_literal_is_matched_against_error_text():
    src = notebook_concat_source()
    bare = re.findall(r"""(['"])\s?(?:4\d\d|5\d\d)\s?\1\s*(?:in\b|,|\))""", src)
    assert bare == []
    for site in ("_recoverable = _llm_error_is_recoverable(e)", "_is_recoverable = _llm_error_is_recoverable(e)",
                 "_gd_recoverable = _llm_error_is_recoverable(_gd_err)", "_ce_rec = _llm_error_is_recoverable(_ce)",
                 "if _llm_error_is_rate_limited(_e):", "is_context_error = _llm_error_is_context_limit(e)",
                 "_is_ctx_exc = _llm_error_is_context_limit(e)", "_llm_error_is_context_limit(str(e))",
                 "404 in _http_status_codes(_get_err)", "403 in _http_status_codes(_ls_err)"):
        assert site in src, site


# ------------------------------------------------------------------------------------------------ probe item 5: PK type


def _pk_base():
    base = h.base_model()
    crew = base["model"]["domains"][0]
    crew["products"].append(h._product("shift_pattern", "shift_pattern_id", [h._col("pattern_code")], subdomain="crew_scheduling"))
    crew["products"][1]["attributes"].append(h._col("shift_pattern_id", "BIGINT", fk="crew.shift_pattern.shift_pattern_id"))
    return base


def _retyped(base, child_type=None):
    final = copy.deepcopy(base)
    crew = final["model"]["domains"][0]
    crew["products"][3]["attributes"][0]["type"] = "STRING"
    if child_type:
        crew["products"][1]["attributes"][-1]["type"] = child_type
    return final


def _serialize(base, final):
    fence = ah.build_vibe_scope_fence(ah.parse_vibe_scope("Some Domains", "crew"), base, h.VOV, h.LOG)
    ah.set_vibe_scope_runtime(fence)
    data_model = copy.deepcopy(final["model"])
    wv = {"config": {}, "model_scope": "mvm", "base_version_for_review": "1"}
    facts = ah._vibe_scope_serialize_gate(data_model, wv, h.LOG)
    return facts, {"model": data_model}


def test_a_parent_pk_type_change_marks_its_in_scope_children_changed_and_retypes_their_fk(caplog):
    base = _pk_base()
    with caplog.at_level(logging.INFO, logger=h.LOG.name):
        facts, model = _serialize(base, _retyped(base))
    assert "crew.roster" in facts["changed_in_scope_products"] and "crew.roster" not in facts["preserved_products"]
    roster = model["model"]["domains"][0]["products"][1]
    assert next(a for a in roster["attributes"] if a["name"] == "shift_pattern_id")["type"] == "STRING"
    assert _messages(caplog, "[vibe-scope-pk-type-cascade FIRED v5.1.4]")


def test_a_child_whose_model_type_already_matches_the_new_pk_is_still_replaced():
    base = _pk_base()
    base["model"]["domains"][0]["products"][1]["attributes"][-1]["type"] = "STRING"
    facts, _model = _serialize(base, _retyped(base))
    assert "crew.roster" in facts["changed_in_scope_products"]


def test_the_retyped_child_is_replaced_and_gets_its_fk_back(monkeypatch):
    base = _pk_base()
    facts, model = _serialize(base, _retyped(base))
    spark = _uc(base=base)
    _deploy(monkeypatch, spark, base=base, final=model, facts=facts)
    roster = "skyline.crew.roster"
    assert dict(spark.uc[roster]["cols"])["shift_pattern_id"] == "string"
    assert any(col == "shift_pattern_id" and parent == "skyline.crew.shift_pattern" for col, parent, _p in spark.fks(roster).values())
    assert any(s.startswith("CREATE OR REPLACE TABLE `skyline`.`crew`.`roster`") for s in spark.statements)


def test_a_failed_fk_re_add_is_an_error_recorded_in_the_summary_and_outcomes(monkeypatch, caplog):
    base = _pk_base()
    final = _retyped(base)
    facts = {"mode": "domains", "label": "Some Domains", "entries": ["crew"], "operation": h.VOV,
             "changed_in_scope_products": ["crew.shift_pattern"],
             "preserved_products": ["crew.member", "crew.roster", "crew.base", "flight.scheduled_flight", "fleet.aircraft",
                                    "fleet.maintenance"],
             "permitted_deltas": []}
    spark = _uc(base=base)
    with caplog.at_level(logging.INFO, logger=h.LOG.name):
        res = _deploy(monkeypatch, spark, base=base, final=final, facts=facts, max_retries=3)
    adds = [s for s in spark.statements if "ADD CONSTRAINT `fk_crew_roster_shift_pattern_id`" in s]
    assert len(adds) == 1
    failures = [f for f in res["plan"].summary()["failures"] if f["kind"] == "fk_readd"]
    assert failures and failures[0]["error"].startswith("The foreign key child column type does not match")
    assert any(f["kind"] == "fk_readd" for f in res["widgets"]["_vibe_scope_outcomes"]["deploy_failures"])
    assert [r for r in _messages(caplog, "[vibe-scope-deploy-failure FIRED v5.1.4] fk_readd") if r.levelno == logging.ERROR]


# ------------------------------------------------------------------------------------------------ probe item 6: stale drop


def test_a_removed_table_is_dropped_after_its_cleared_inbound_fk_is_unlinked(monkeypatch, caplog):
    spark = _uc()
    aircraft = "skyline.fleet.aircraft"
    spark.uc[aircraft]["fks"]["fk_aircraft_home_base_id"] = spark.uc[aircraft]["fks"].pop("fk_fleet_aircraft_home_base_id")
    with caplog.at_level(logging.INFO, logger=h.LOG.name):
        _deploy(monkeypatch, spark)
    assert "skyline.crew.base" not in spark.uc
    unlink = "ALTER TABLE `skyline`.`fleet`.`aircraft` DROP CONSTRAINT IF EXISTS `fk_aircraft_home_base_id`"
    assert unlink in spark.statements
    assert spark.statements.index(unlink) < spark.statements.index("DROP TABLE IF EXISTS `skyline`.`crew`.`base`")
    assert _messages(caplog, "[vibe-scope-p2-physical-unlink FIRED v5.1.4] skyline.fleet.aircraft.home_base_id -> skyline.crew.base")


def test_a_removed_table_the_model_still_references_is_kept_as_a_conflict(monkeypatch, caplog):
    final = h.scoped_final_model()
    final["model"]["domains"][2]["products"][0]["attributes"][1]["foreign_key_to"] = "crew.base.base_id"
    facts = h.scoped_facts()
    facts["permitted_deltas"] = [d for d in facts["permitted_deltas"] if d["kind"] != "P2"]
    spark = _uc()
    with caplog.at_level(logging.INFO, logger=h.LOG.name):
        res = _deploy(monkeypatch, spark, final=final, facts=facts)
    assert "skyline.crew.base" in spark.uc
    assert "fk_fleet_aircraft_home_base_id" in spark.fks("skyline.fleet.aircraft")
    assert "skyline.crew.member" not in spark.uc
    conflicts = [f for f in res["plan"].summary()["failures"] if f["kind"] == "stale_drop_conflict"]
    assert [f["target"] for f in conflicts] == ["skyline.crew.base"]
    assert [r for r in _messages(caplog, "stale_drop_conflict skyline.crew.base") if r.levelno == logging.ERROR]


def test_removed_tables_are_kept_when_inbound_fks_cannot_be_listed(monkeypatch):
    class _NoConstraints(h.UCSpark):
        def sql(self, stmt):
            if "referential_constraints" in str(stmt):
                raise RuntimeError("[INTERNAL_ERROR] information_schema is unavailable")
            return super().sql(stmt)

    spark = _uc(_NoConstraints)
    res = _deploy(monkeypatch, spark)
    assert "skyline.crew.base" in spark.uc and "skyline.crew.member" in spark.uc
    assert sorted(f["target"] for f in res["plan"].summary()["failures"]) == ["skyline.crew.base", "skyline.crew.member"]


# ------------------------------------------------------------------------------------------------ probe item 8: UC facts


@pytest.mark.parametrize("pk_change", ["same_pk", "pk_renamed", "pk_removed", "pk_column_changed"])
def test_preserved_children_of_a_replaced_parent_end_with_the_models_fk(monkeypatch, pk_change):
    spark = _uc()
    roster = "skyline.crew.roster"
    if pk_change != "same_pk":
        name, cols = spark.uc[roster]["pk"]
        spark.uc[roster]["pk"] = {"pk_renamed": ("pk_roster_old", cols), "pk_removed": None,
                                  "pk_column_changed": (name, ["roster_date"])}[pk_change]
    res = _deploy(monkeypatch, spark)
    assert spark.fks("skyline.fleet.maintenance") == {"fk_fleet_maintenance_roster_id": ("roster_id", roster, "roster_id")}
    assert res["plan"].summary()["failures"] == []


def test_create_table_if_not_exists_keeps_the_rows_columns_and_constraints_of_preserved_tables(monkeypatch):
    spark = _uc()
    spark.insert_rows("skyline.fleet.maintenance", 3)
    before = copy.deepcopy(spark.uc["skyline.fleet.maintenance"])
    res = _deploy(monkeypatch, spark)
    after = spark.uc["skyline.fleet.maintenance"]
    assert after["rows"] == 3 and after["cols"] == before["cols"] and after["pk"] == before["pk"]
    assert spark.fks("skyline.flight.scheduled_flight")["fk_flight_scheduled_flight_aircraft_id"] == (
        "aircraft_id", "skyline.fleet.aircraft", "aircraft_id")
    assert res["plan"].summary()["failures"] == []


def test_the_uc_double_replays_the_probe():
    spark = h.UCSpark(tables={})
    spark.sql("CREATE OR REPLACE TABLE `c`.`a`.`parent` (`parent_id` BIGINT, CONSTRAINT pk_parent PRIMARY KEY(`parent_id`))")
    spark.sql("CREATE OR REPLACE TABLE `c`.`b`.`child` (`child_id` BIGINT, `parent_id` BIGINT, CONSTRAINT pk_child PRIMARY KEY(`child_id`))")
    spark.insert_rows("c.b.child")
    fk = "ALTER TABLE `c`.`b`.`child` ADD CONSTRAINT `fk_b_child_parent_id` FOREIGN KEY (`parent_id`) REFERENCES `c`.`a`.`parent`(`parent_id`)"
    spark.sql(fk)
    spark.sql("CREATE OR REPLACE TABLE `c`.`a`.`parent` (`parent_id` BIGINT, `label` STRING, CONSTRAINT pk_parent PRIMARY KEY(`parent_id`))")
    assert spark.fks("c.b.child")
    with pytest.raises(h.UCError, match=r"^\[DELTA_CONSTRAINT_ALREADY_EXISTS\]"):
        spark.sql(fk)
    spark.sql("ALTER TABLE `c`.`b`.`child` ADD COLUMNS (`new_ref_id` BIGINT COMMENT 'probe')")
    with pytest.raises(h.UCError, match=r"^\[FIELD_ALREADY_EXISTS\]"):
        spark.sql("ALTER TABLE `c`.`b`.`child` ADD COLUMNS (`new_ref_id` BIGINT COMMENT 'probe', `second_ref_id` BIGINT)")
    assert "second_ref_id" not in dict(spark.uc["c.b.child"]["cols"])
    spark.sql("CREATE TABLE IF NOT EXISTS `c`.`b`.`child` (`child_id` BIGINT, `parent_id` BIGINT)")
    assert spark.uc["c.b.child"]["rows"] == 1 and spark.fks("c.b.child")
    spark.sql("CREATE OR REPLACE TABLE `c`.`a`.`parent` (`parent_key` BIGINT, CONSTRAINT pk_parent PRIMARY KEY(`parent_key`))")
    assert spark.fks("c.b.child") == {}
    spark.sql("CREATE OR REPLACE TABLE `c`.`a`.`parent` (`parent_id` STRING, CONSTRAINT pk_parent PRIMARY KEY(`parent_id`))")
    with pytest.raises(h.UCError, match="does not match the parent column type"):
        spark.sql(fk)
    spark.sql("CREATE OR REPLACE TABLE `c`.`a`.`parent` (`parent_id` BIGINT, CONSTRAINT pk_parent PRIMARY KEY(`parent_id`))")
    spark.sql(fk)
    spark.sql("DROP TABLE IF EXISTS `c`.`a`.`parent`")
    assert spark.fks("c.b.child") == {}
    with pytest.raises(h.UCError, match=r"^\[TABLE_OR_VIEW_NOT_FOUND\]"):
        spark.sql(fk)


# ------------------------------------------------------------------------------------------------ probe item 9: FK lookup


def _two_address_tables():
    spark = h.UCSpark(tables={})
    for schema in ("customer", "supplier"):
        spark.sql(f"CREATE OR REPLACE TABLE `skyline`.`{schema}`.`address` (`address_id` BIGINT, CONSTRAINT pk_address PRIMARY KEY(`address_id`))")
    spark.sql("CREATE OR REPLACE TABLE `skyline`.`supplier`.`vendor` (`vendor_id` BIGINT, `address_id` BIGINT, "
              "CONSTRAINT pk_vendor PRIMARY KEY(`vendor_id`))")
    spark.sql("ALTER TABLE `skyline`.`supplier`.`vendor` ADD CONSTRAINT `fk_supplier_vendor_address_id` FOREIGN KEY (`address_id`) "
              "REFERENCES `skyline`.`supplier`.`address`(`address_id`)")
    return spark


def test_physical_fk_targets_resolve_the_parent_by_catalog_and_schema_not_by_pk_name():
    spark = _two_address_tables()
    table_map = {("skyline", "customer", "address"): ("customer", "address"),
                 ("skyline", "supplier", "address"): ("supplier", "address"),
                 ("skyline", "supplier", "vendor"): ("supplier", "vendor")}
    index = ah._vibe_physical_fk_targets(spark, {("skyline", "supplier"), ("skyline", "customer")}, table_map, h.LOG)
    assert index == {("skyline", "supplier", "vendor", "address_id"): "supplier.address.address_id"}


def test_uc_foreign_keys_resolve_a_parent_in_another_catalog():
    spark = h.UCSpark(tables={})
    spark.sql("CREATE OR REPLACE TABLE `cat_b`.`crew`.`member` (`member_id` BIGINT, CONSTRAINT pk_member PRIMARY KEY(`member_id`))")
    spark.sql("CREATE OR REPLACE TABLE `cat_a`.`flight`.`leg` (`leg_id` BIGINT, `member_id` BIGINT, CONSTRAINT pk_leg PRIMARY KEY(`leg_id`))")
    spark.sql("ALTER TABLE `cat_a`.`flight`.`leg` ADD CONSTRAINT `fk_flight_leg_member_id` FOREIGN KEY (`member_id`) "
              "REFERENCES `cat_b`.`crew`.`member`(`member_id`)")
    edges, failed = ah._uc_foreign_keys(spark, ["cat_a"], h.LOG)
    assert failed == [] and edges == [{"name": "fk_flight_leg_member_id", "child": "cat_a.flight.leg", "column": "member_id",
                                       "parent": "cat_b.crew.member", "parent_column": "member_id"}]


def test_the_live_sample_audit_resolves_same_named_fks_by_schema():
    import ast as _ast
    script = Path(__file__).resolve().parents[2] / "runner" / "audit_live_samples.py"
    node = next(n for n in _ast.parse(script.read_text()).body
                if isinstance(n, _ast.Assign) and getattr(n.targets[0], "id", "") == "FK_SQL")
    fk_sql = _ast.literal_eval(node.value)
    spark = h.UCSpark(tables={})
    for schema in ("customer", "supplier"):
        spark.sql(f"CREATE OR REPLACE TABLE `skyline`.`{schema}`.`owner` (`owner_id` BIGINT, CONSTRAINT pk_owner PRIMARY KEY(`owner_id`))")
        spark.sql(f"CREATE OR REPLACE TABLE `skyline`.`{schema}`.`account` (`account_id` BIGINT, `owner_id` BIGINT, "
                  f"CONSTRAINT pk_account PRIMARY KEY(`account_id`))")
        spark.sql(f"ALTER TABLE `skyline`.`{schema}`.`account` ADD CONSTRAINT `fk_account_owner` FOREIGN KEY (`owner_id`) "
                  f"REFERENCES `skyline`.`{schema}`.`owner`(`owner_id`)")
    rows = spark.sql(fk_sql.format(catalog="skyline")).collect()
    assert sorted((r["child_schema"], r["parent_schema"]) for r in rows) == [("customer", "customer"), ("supplier", "supplier")]


def test_the_ground_truth_audit_uses_the_qualified_fk_lookup():
    src = notebook_concat_source()
    audit = src[src.index("def _run_ground_truth_audit(widgets_values):"):]
    audit = audit[:audit.index("\ndef ", 10)]
    assert "fk_index = _vibe_physical_fk_targets(spark, cat_schema, table_map, logger)" in audit
    assert "unique_constraint_name=ccu.constraint_name" not in src and "rc.constraint_name=kcu.constraint_name" not in src


# ------------------------------------------------------------------------------------------------ probe item 10: catalog quota


class _QuotaSpark:
    def __init__(self):
        self.statements = []

    def sql(self, stmt):
        self.statements.append(stmt)
        if stmt.startswith("CREATE CATALOG"):
            raise h.UCError(W["U01_create_catalog_quota"])
        return type("R", (), {"collect": lambda self: []})()


def test_catalog_quota_gets_an_accurate_message(caplog):
    with caplog.at_level(logging.INFO, logger=h.LOG.name):
        with pytest.raises(ah.CatalogQuotaExceededError) as err:
            ah._ensure_catalog_exists(_QuotaSpark(), "vs_probe_v514", h.LOG)
    msg = str(err.value)
    assert "catalog quota (1000 of 1000 catalogs)" in msg and "Default Storage" not in msg
    assert "Drop catalogs that are no longer needed" in msg
    assert _messages(caplog, "[catalog-quota-exceeded FIRED v5.1.4]")


def test_stage1_reports_the_quota_hint_instead_of_the_permission_hint(monkeypatch):
    spark = _uc(catalogs=())
    real_sql = h.UCSpark.sql

    def _quota(self, stmt):
        if str(stmt).startswith("CREATE CATALOG"):
            self.record(str(stmt))
            raise h.UCError(W["U01_create_catalog_quota"])
        return real_sql(self, stmt)

    monkeypatch.setattr(h.UCSpark, "sql", _quota)
    with pytest.raises(RuntimeError) as err:
        _deploy(monkeypatch, spark)
    assert "catalog quota" in str(err.value) and "grant CREATE CATALOG permission" not in str(err.value)

"""The installer classifies statement errors by error class and HTTP status context.

Texts come from the agent's live Unity Catalog probe fixture (model-agent/tests/unit-tests/fixtures/
v514_uc_probe_errors.json). Two defects were reachable here:
  - a deterministic error whose serverless JVM stack frame reads QueryExecution.scala:2504 matched the bare "504" token
    and was retried seven times; a request id with "429" in it matched "429";
  - FIELD_ALREADY_EXISTS matched "already exists" and was ignored, so a P4 column that already existed with another type
    was reported as installed.
"""
import copy
import json
import re
from pathlib import Path

from installer_harness import BASE_V1_TABLES, FakeUC, find_cell, load_pipeline, pipeline_cfg, scoped_folder

FIXTURE = Path(__file__).resolve().parents[3] / "model-agent" / "tests" / "unit-tests" / "fixtures" / "v514_uc_probe_errors.json"
PROBE = json.loads(FIXTURE.read_text())
FRAME = "\tat org.apache.spark.sql" + PROBE["serverless_runCommand_context_2504"].split(" | ")[0]
ADD = "ALTER TABLE `demo`.`sales`.`order` ADD COLUMNS (`loyalty_id` BIGINT COMMENT 'Loyalty link')"


class _Raising(object):
    def __init__(self, *errors):
        self.errors = list(errors)
        self.calls = []

    def sql(self, stmt):
        self.calls.append(stmt)
        if self.errors:
            raise RuntimeError(self.errors.pop(0))
        return None


def _executor(spark, monkeypatch, lines=None):
    namespace = {"__name__": "installer_executor", "spark": spark, "log": (lines if lines is not None else []).append}
    exec(compile(find_cell("def _exec_with_backoff"), "<executor-cell>", "exec"), namespace)
    monkeypatch.setattr(namespace["time"], "sleep", lambda *_a, **_k: None)
    return namespace


def _tables(loyalty_type):
    tables = copy.deepcopy(BASE_V1_TABLES)
    order = tables["demo.sales.order"]
    order["columns"] = order["columns"] + ["loyalty_id"]
    order["types"] = {"order_id": "bigint", "customer_id": "bigint", "loyalty_id": loyalty_type}
    return tables


def test_a_deterministic_error_whose_stack_frame_contains_2504_is_not_retried(monkeypatch):
    serverless = PROBE["serverless"]["S09"]["str_e_head"] + "\n" + FRAME
    spark = _Raising(*([serverless] * 8))
    ok, err = _executor(spark, monkeypatch)["_exec_with_backoff"]("ALTER TABLE `demo`.`sales`.`order` ADD CONSTRAINT x")
    assert ok is False and err.startswith("[TABLE_OR_VIEW_NOT_FOUND]")
    assert len(spark.calls) == 1


def test_a_request_id_containing_429_is_not_a_rate_limit(monkeypatch):
    text = "[RequestId=%s ErrorClass=INVALID_PARAMETER_VALUE] the value is invalid" % PROBE["warehouse"]["statement_id_with_429"]
    spark = _Raising(*([text] * 8))
    ok, _err = _executor(spark, monkeypatch)["_exec_with_backoff"]("CREATE SCHEMA IF NOT EXISTS `demo`.`sales`")
    assert ok is False and len(spark.calls) == 1


def test_an_http_503_is_still_retried(monkeypatch):
    spark = _Raising("[RequestId=1 ErrorClass=INTERNAL_ERROR] HTTP 503 Service Unavailable")
    assert _executor(spark, monkeypatch)["_exec_with_backoff"]("CREATE SCHEMA IF NOT EXISTS `demo`.`sales`") == (True, None)
    assert len(spark.calls) == 2


def test_error_classes_decide_what_is_ignorable(monkeypatch):
    ns = _executor(_Raising(), monkeypatch)
    w = PROBE["warehouse"]
    assert ns["_ignorable"](w["U13_constraint_exists"]) is True
    assert ns["_drop_ignorable"](w["D01_fk_parent_missing"]) is True
    assert ns["_ignorable"](w["U18_field_exists"]) is False
    assert ns["_ignorable"](PROBE["serverless"]["S06"]["str_e_head"] + "\nTable Constraints: [pk_child]") is False
    assert ns["_ignorable"](w["U01_create_catalog_quota"]) is False


def test_an_existing_column_counts_only_with_its_expected_type(monkeypatch):
    for loyalty_type, expected in (("bigint", True), ("string", False)):
        lines = []
        ns = _executor(FakeUC(_tables(loyalty_type)), monkeypatch, lines)
        ok, err = ns["_exec_with_backoff"](ADD)
        assert ok is expected
        if expected:
            assert err is None and any("installer-column-exists-confirm" in line for line in lines)
        else:
            assert "loyalty_id (string, expected BIGINT)" in err and ns["_ignorable"](err) is False


def test_a_scoped_install_reports_a_p4_column_that_exists_with_another_type(tmp_path):
    spark = FakeUC(_tables("string"))
    ns = load_pipeline(spark)
    cfg = pipeline_cfg(scoped_folder(tmp_path))
    final, _, _ = ns["install"](cfg, ns["build_plan"](cfg))
    assert [phase for phase, _stmt, _err in final] == ["column_add"]


def test_a_scoped_install_accepts_a_p4_column_already_there_with_the_right_type(tmp_path):
    spark = FakeUC(_tables("bigint"))
    ns = load_pipeline(spark)
    cfg = pipeline_cfg(scoped_folder(tmp_path))
    final, _, _ = ns["install"](cfg, ns["build_plan"](cfg))
    assert final == []
    assert spark.tables["demo.sales.order"]["fks"] == {"fk_order_customer": "demo.sales.customer_v2"}


def test_no_bare_http_status_token_is_matched_against_error_text():
    cell = find_cell("def _exec_with_backoff")
    assert re.findall(r"""(['"])\s?(?:4\d\d|5\d\d)\s?\1\s*(?:in\b|,|\))""", cell) == []

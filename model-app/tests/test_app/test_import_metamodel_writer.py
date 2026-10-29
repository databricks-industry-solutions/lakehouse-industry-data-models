"""Unit tests for ``services.import_metamodel_writer.write_metamodel``.

Verifies the SQL INSERT statements the writer produces match the agent's
column shape for ``_metamodel.{business,domain,product,attribute}``.

The writer never raises — failures land in the returned ``summary["errors"]``.
"""
from __future__ import annotations

import os
import sys
from unittest.mock import MagicMock

import pytest

from vibe_modeling.backend.services import import_metamodel_writer as _w
from vibe_modeling.backend.services.import_metamodel_writer import write_metamodel

sys.path.insert(0, os.path.dirname(__file__))
from _sql_fakes import FakeClock, response, ws_returning  # noqa: E402


@pytest.fixture(autouse=True)
def registry_setup(monkeypatch):
    """The registry setup before the INSERTs, recorded and stubbed: its own
    statements are covered in test_metamodel_registry_setup.py."""
    calls: list[dict] = []

    def ensure(ws, catalog, warehouse_id, *, timeout_s):
        calls.append({"ws": ws, "catalog": catalog, "warehouse_id": warehouse_id, "timeout_s": timeout_s})
        return []

    monkeypatch.setattr(_w, "ensure_metamodel_registry", ensure)
    return calls


@pytest.fixture
def captured_ws():
    """A MagicMock ws whose ``statement_execution.execute_statement`` records
    every statement and returns a successful result."""
    ws = MagicMock()
    statements: list[str] = []

    def execute(*args, statement=None, warehouse_id=None, wait_timeout=None, **kwargs):
        statements.append(statement)
        return response(None)

    ws.statement_execution.execute_statement.side_effect = execute
    ws._captured_statements = statements  # attach for the test to inspect
    return ws


@pytest.fixture
def clock(monkeypatch):
    return FakeClock().install(monkeypatch)


def _payload() -> dict:
    return {
        "model": {
            "type": "business",
            "name": "Mining Corp",
            "version": "v1_ecm",
            "description": "Description text",
            "industry_alignment": "mining",
            "location": "EU",
            "core_business_processes": "p1, p2",
            "orgnaization_divisions": "div1, div2",
            "data_domains": "extraction, processing",
            "common_business_jargons": "tonnage, grade",
            "operational_systems_of_records": "ERP, SCADA",
            "industry_governing_body": "ISO, OSHA",
            "vibe_modelling_instructions": "Mine carefully.",
            "model_conventions": {"primary_key_suffix": "_id"},
            "domains": [
                {
                    "name": "extraction",
                    "division": "Operations",
                    "description": "All extraction activity",
                    "database_name": "extraction",
                    "products": [
                        {
                            "name": "mine_site",
                            "table_name": "mine_site",
                            "primary_key": "mine_site_id",
                            "description": "A mine",
                            "type": "reference",
                            "subdomain": "underground",
                            "attributes": [
                                {"name": "mine_site_id", "column_name": "mine_site_id",
                                 "type": "BIGINT", "description": "PK"},
                                {"name": "country_code", "column_name": "country_code",
                                 "type": "STRING", "description": "ISO country",
                                 "foreign_key_to": "geo.country.country_code"},
                            ],
                        },
                    ],
                },
            ],
        },
    }


class TestWriteMetamodel:
    def test_writes_business_domain_product_attribute_rows(self, captured_ws):
        out = write_metamodel(
            captured_ws,
            catalog="vibe_modeling_test",
            warehouse_id="abc123",
            model_json=_payload(),
            business_name="Mining Corp",
            scope="ecm",
            version=1,
            wait_mode="request",
        )
        assert out["business"] == 1
        assert out["domain"] == 1
        assert out["product"] == 1
        assert out["attribute"] == 2
        assert out["errors"] == []

        # Statements are batched per table: 1 business + 1 domain INSERT
        # (multi-row) + 1 product INSERT + 1 attribute INSERT. Batching
        # collapses what used to be one round-trip per row into one per
        # table-chunk so a multi-thousand-row import returns before the
        # Databricks Apps reverse-proxy timeout instead of wedging.
        stmts = captured_ws._captured_statements
        assert len(stmts) == 4  # business, domain, product, attribute (1 chunk each)
        biz_sql = stmts[0]
        assert biz_sql.startswith("INSERT INTO `vibe_modeling_test`.`_metamodel`.`business`")
        # Business identifier is display-cased to match agent's _metamodel column.
        assert "'Mining_Corp'" in biz_sql
        # version is a STRING in the agent's schema.
        assert "'1'" in biz_sql
        assert "'ecm'" in biz_sql
        # processing_status is 'done' for imports.
        assert "'done'" in biz_sql
        # completed_percent is 100 (the writer emits the float).
        assert "100.0" in biz_sql
        # model_conventions was serialised to JSON-string.
        assert '\"primary_key_suffix\": \"_id\"' in biz_sql or '"primary_key_suffix": "_id"' in biz_sql

        # Domain INSERT carries the right columns.
        domain_sql = stmts[1]
        assert domain_sql.startswith("INSERT INTO `vibe_modeling_test`.`_metamodel`.`domain`")
        assert "'extraction'" in domain_sql
        assert "'Operations'" in domain_sql

        # Product INSERT.
        product_sql = stmts[2]
        assert product_sql.startswith("INSERT INTO `vibe_modeling_test`.`_metamodel`.`product`")
        assert "'mine_site'" in product_sql
        assert "'mine_site_id'" in product_sql  # primary_key

        # Attribute INSERT batches both attribute rows into one multi-row
        # VALUES list; foreign_key_to populated for the FK column.
        attr_sql = stmts[3]
        assert attr_sql.startswith("INSERT INTO `vibe_modeling_test`.`_metamodel`.`attribute`")
        assert "'country_code'" in attr_sql
        assert "'mine_site_id'" in attr_sql
        assert "'geo.country.country_code'" in attr_sql
        # Multi-row VALUES → two value tuples → the join comma is present.
        assert "), (" in attr_sql

    def test_batches_rows_into_bounded_chunks(self, captured_ws):
        """A model with more rows than the chunk size must split each
        table's INSERT into multiple bounded statements — not one giant
        statement, and not one per row. Bounds the synchronous work so
        the import returns promptly on large models."""
        # 250 products in one domain, no attributes — with a 200-row chunk
        # the product INSERT splits into 2 statements (200 + 50).
        products = [
            {"name": f"p{i}", "table_name": f"p{i}", "attributes": []}
            for i in range(250)
        ]
        payload = {
            "model": {
                "name": "Big Corp", "version": "v1_ecm",
                "domains": [{"name": "d0", "products": products}],
            }
        }
        out = write_metamodel(
            captured_ws,
            catalog="cat", warehouse_id="wh",
            model_json=payload, business_name="Big Corp",
            scope="ecm", version=1, chunk_size=200,
            wait_mode="request",
        )
        assert out["product"] == 250
        assert out["errors"] == []
        stmts = captured_ws._captured_statements
        product_stmts = [s for s in stmts if "`_metamodel`.`product`" in s]
        # 250 products / 200-row chunk → 2 INSERTs (not 250, not 1).
        assert len(product_stmts) == 2

    def test_seed_statement_count_is_bounded_at_representative_scale(self, captured_ws):
        """A kickstart-scale model (~150 products, ~6.5k attributes - the
        scope this repo's perf work profiled) must issue a small, bounded
        number of warehouse round trips, not one per row. Regression guard:
        a change that reverts to a per-row INSERT loop would blow this
        assertion up from dozens of statements to thousands."""
        n_products = 150
        attrs_per_product = 43  # 150 * 43 = 6450, representative of ~6.5k
        products = [
            {
                "name": f"p{i}", "table_name": f"p{i}",
                "attributes": [
                    {"name": f"p{i}_a{j}", "column_name": f"p{i}_a{j}", "type": "STRING"}
                    for j in range(attrs_per_product)
                ],
            }
            for i in range(n_products)
        ]
        payload = {
            "model": {
                "name": "Kickstart Corp", "version": "v1_ecm",
                "domains": [{"name": "d0", "products": products}],
            }
        }
        out = write_metamodel(
            captured_ws,
            catalog="cat", warehouse_id="wh",
            model_json=payload, business_name="Kickstart Corp",
            scope="ecm", version=1,
            wait_mode="request",
        )
        assert out["product"] == n_products
        assert out["attribute"] == n_products * attrs_per_product
        assert out["errors"] == []

        stmts = captured_ws._captured_statements
        # 1 business + 1 domain + ceil(150/10000) product + ceil(6450/10000)
        # attribute = 1 + 1 + 1 + 1 = 4 - three orders of magnitude below
        # the 6602-row total, proving the batching is not per-row.
        assert len(stmts) <= 40, (
            f"expected a bounded statement count, got {len(stmts)} for "
            f"{out['attribute']} attribute rows"
        )
        total_rows = out["business"] + out["domain"] + out["product"] + out["attribute"]
        assert len(stmts) < total_rows / 100

    def test_missing_args_returns_error_without_raising(self, captured_ws):
        out = write_metamodel(
            captured_ws,
            catalog="",
            warehouse_id="abc",
            model_json=_payload(),
            business_name="x",
            scope="ecm",
            version=1,
            wait_mode="request",
        )
        assert out["business"] == 0
        assert out["errors"], "expected an error message for missing catalog"
        captured_ws.statement_execution.execute_statement.assert_not_called()

    def test_apostrophe_in_text_is_escaped(self, captured_ws):
        p = _payload()
        p["model"]["description"] = "It's a test — apostrophe ok"
        out = write_metamodel(
            captured_ws,
            catalog="cat",
            warehouse_id="wh",
            model_json=p,
            business_name="biz",
            scope="ecm",
            version=1,
            wait_mode="request",
        )
        assert out["business"] == 1
        biz_sql = captured_ws._captured_statements[0]
        # Single quotes must be doubled to avoid breaking the literal.
        assert "It''s a test" in biz_sql

    def test_seed_writes_display_cased_business(self, captured_ws):
        """W1 regression guard: the ``business`` column must be written with
        the agent's display-casing (``Terranova_Copy``) not the raw lowercase
        slug (``terranova_copy``). Pre-fix code fails this assertion."""
        out = write_metamodel(
            captured_ws,
            catalog="cat",
            warehouse_id="wh",
            model_json={"model": {"name": "Terranova Copy", "version": "v1_ecm", "domains": []}},
            business_name="terranova_copy",
            scope="ecm",
            version=1,
            wait_mode="request",
        )
        assert out["errors"] == []
        biz_sql = captured_ws._captured_statements[0]
        assert "'Terranova_Copy'" in biz_sql, (
            f"expected display-cased value in SQL, got: {biz_sql[:300]}"
        )
        assert "'terranova_copy'" not in biz_sql, (
            "lowercase slug must not appear in business column after W1 fix"
        )

    def test_sql_error_status_appends_to_errors(self):
        """If the warehouse returns an error status, write_metamodel should
        surface it via summary["errors"] without raising."""
        ws = MagicMock()

        ws.statement_execution.execute_statement.return_value = response(
            error="syntax error near INSERT"
        )
        out = write_metamodel(
            ws,
            catalog="c", warehouse_id="w",
            model_json=_payload(), business_name="b", scope="ecm", version=1,
            wait_mode="request",
        )
        assert out["business"] == 0
        assert out["errors"]
        assert "syntax error" in out["errors"][0]

    def test_response_without_success_state_is_an_error(self):
        """A response with no SUCCEEDED state is not a write: it lands in errors."""
        ws = MagicMock()
        ws.statement_execution.execute_statement.return_value = MagicMock(status=None)
        out = write_metamodel(
            ws,
            catalog="c", warehouse_id="w",
            model_json=_payload(), business_name="b", scope="ecm", version=1,
            wait_mode="request",
        )
        assert out["business"] == 0
        assert out["errors"]

    @pytest.mark.parametrize("mode", ["request", "background"])
    def test_cold_warehouse_insert_polls_to_success(self, clock, mode):
        """A cold warehouse: the business INSERT is still PENDING after the 50 s
        server wait and two blocking polls (5.2 s each, as on a real warehouse),
        then SUCCEEDED; the write completes with no error and no cancel."""
        seq = iter([
            response(state="PENDING", statement_id="ins-1"),
            response(state="RUNNING", statement_id="ins-1"),
            response(None, statement_id="ins-1"),
        ])
        ws = ws_returning(
            response(state="PENDING", statement_id="ins-1"),
            response(None, statement_id="ins-2"),
            response(None, statement_id="ins-3"),
            response(None, statement_id="ins-4"),
            clock=clock, poll_cost_s=5.2, polls=lambda sid: next(seq),
        )
        out = write_metamodel(
            ws,
            catalog="c", warehouse_id="w",
            model_json=_payload(), business_name="b", scope="ecm", version=1,
            wait_mode=mode,
        )
        assert out["errors"] == []
        assert out["still_running"] == []
        assert out["business"] == 1 and out["attribute"] == 2
        assert ws.statement_execution.get_statement.call_count == 3
        assert ws.waits[0] == "50s"
        assert clock.elapsed <= _w._REQUEST_BUDGET_S
        ws.statement_execution.cancel_execution.assert_not_called()

    def test_business_row_is_the_first_insert_and_gets_the_full_wait(self, clock):
        ws = ws_returning(response(None), clock=clock)
        write_metamodel(
            ws,
            catalog="c", warehouse_id="w",
            model_json=_payload(), business_name="b", scope="ecm", version=1,
            wait_mode="request",
        )
        assert ws.statements[0].startswith("INSERT INTO `c`.`_metamodel`.`business`")
        assert ws.waits[0] == "50s"

    def test_background_insert_still_running_after_its_bound_is_cancelled(self, clock):
        """Background: each INSERT waits about 10 minutes of wall-clock time with
        blocking polls, then is cancelled and reported; no further statement."""
        ws = ws_returning(response(state="PENDING", statement_id="ins-1"), clock=clock, poll_cost_s=5.3)
        out = write_metamodel(
            ws,
            catalog="c", warehouse_id="w",
            model_json=_payload(), business_name="b", scope="ecm", version=1,
            wait_mode="background",
        )
        assert out["business"] == 0
        assert out["errors"] and "TIMEOUT" in out["errors"][0]
        assert out["still_running"] == []
        assert ws.statement_execution.execute_statement.call_count == 1
        ws.statement_execution.cancel_execution.assert_called_once_with("ins-1")
        assert _w._BACKGROUND_INSERT_TIMEOUT_S - 15 <= clock.elapsed <= _w._BACKGROUND_INSERT_TIMEOUT_S + 5.3

    def test_background_insert_is_clamped_to_what_is_left_of_the_write_cap(self, clock):
        """The business and domain INSERTs each finish after about 540 s, inside
        their own 600 s bound; the product INSERT never finishes. It gets only the
        ~120 s left of the 1200 s write cap, not a fresh 600 s, and the
        attribute INSERT is never submitted."""
        def polls(sid):
            if sid in ("ins-1", "ins-2"):
                clock.advance(480)  # with the 50 s wait, 5 s sleep and 5.2 s read: ~540 s
                return response(None, statement_id=sid)
            state = "CANCELED" if ws.statement_execution.cancel_execution.called else "RUNNING"
            return response(state=state, statement_id=sid)

        ws = ws_returning(
            response(state="PENDING", statement_id="ins-1"),
            response(state="PENDING", statement_id="ins-2"),
            response(state="PENDING", statement_id="ins-3"),
            clock=clock, poll_cost_s=5.2, polls=polls,
        )
        out = write_metamodel(
            ws,
            catalog="c", warehouse_id="w",
            model_json=_payload(), business_name="b", scope="ecm", version=1,
            wait_mode="background",
        )
        assert out["business"] == 1
        assert out["errors"] and "TIMEOUT" in out["errors"][0]
        assert ws.statement_execution.execute_statement.call_count == 3
        ws.statement_execution.cancel_execution.assert_called_once_with("ins-3")
        # One poll plus the final read after the cancel may run past the cap.
        assert clock.elapsed <= _w._BACKGROUND_WRITE_TIMEOUT_S + 2 * 5.2 + 5

    def test_background_spent_write_cap_submits_nothing_more(self, clock):
        def polls(sid):
            clock.advance(400)
            return response(None, statement_id=sid)

        ws = ws_returning(response(state="PENDING", statement_id="ins"), clock=clock, polls=polls)
        out = write_metamodel(
            ws,
            catalog="c", warehouse_id="w",
            model_json=_payload(), business_name="b", scope="ecm", version=1,
            wait_mode="background",
        )
        assert out["errors"] and "cap" in out["errors"][0]
        assert ws.statement_execution.execute_statement.call_count == 3

    def test_request_mode_stops_waiting_without_cancelling(self, clock):
        """Request: with blocking 5.3 s polls the write still stops waiting inside
        90 s. Every statement keeps running in the warehouse, is listed in
        still_running (a warning, not an error), and nothing is cancelled."""
        ids = iter(f"ins-{i}" for i in range(1, 10))
        ws = ws_returning(clock=clock, poll_cost_s=5.3)
        ws.statement_execution.execute_statement.side_effect = None
        waits: list[str] = []

        def _execute(*_a, wait_timeout=None, **_kw):
            waits.append(wait_timeout)
            clock.advance(int(wait_timeout.rstrip("s")))
            return response(state="PENDING", statement_id=next(ids))

        ws.statement_execution.execute_statement.side_effect = _execute
        out = write_metamodel(
            ws,
            catalog="c", warehouse_id="w",
            model_json=_payload(), business_name="b", scope="ecm", version=1,
            wait_mode="request",
        )
        assert out["errors"] == []
        assert out["still_running"] == ["ins-1", "ins-2", "ins-3", "ins-4"]
        assert waits[0] == "50s"
        assert all(int(w.rstrip("s")) < 10 for w in waits[1:])
        assert clock.elapsed <= _w._REQUEST_BUDGET_S
        ws.statement_execution.cancel_execution.assert_not_called()

    def test_request_mode_later_statements_share_the_budget(self, clock):
        """The 90 s budget is for the whole write: once the business INSERT took
        70 s, the next one waits only the 20 s left, with no polls."""
        state = {"n": 0}
        waits: list[str] = []
        ws = ws_returning(clock=clock, poll_cost_s=5.3)

        def _execute(*_a, wait_timeout=None, **_kw):
            waits.append(wait_timeout)
            state["n"] += 1
            if state["n"] == 1:
                clock.advance(70)
                return response(None, statement_id="ins-1")
            clock.advance(int(wait_timeout.rstrip("s")))
            return response(state="PENDING", statement_id=f"ins-{state['n']}")

        ws.statement_execution.execute_statement.side_effect = _execute
        out = write_metamodel(
            ws,
            catalog="c", warehouse_id="w",
            model_json=_payload(), business_name="b", scope="ecm", version=1,
            wait_mode="request",
        )
        assert waits == ["50s", "20s", "0s", "0s"]
        assert out["still_running"] == ["ins-2", "ins-3", "ins-4"]
        assert out["errors"] == []
        ws.statement_execution.get_statement.assert_not_called()

    def test_request_mode_real_failure_is_still_an_error(self, clock):
        ws = ws_returning(
            response(state="PENDING", statement_id="ins-1"), clock=clock, poll_cost_s=5.3,
            polls=lambda sid: response(error="[DELTA_CONCURRENT_APPEND] conflict", statement_id=sid),
        )
        out = write_metamodel(
            ws,
            catalog="c", warehouse_id="w",
            model_json=_payload(), business_name="b", scope="ecm", version=1,
            wait_mode="request",
        )
        assert out["errors"] and "DELTA_CONCURRENT_APPEND" in out["errors"][0]
        assert out["still_running"] == []

    def test_seed_producers_choose_their_wait_mode(self):
        """The in-request producers wait briefly; only the background kickstart polls to terminal."""
        import inspect

        from vibe_modeling.backend.services import dialog_import, industry_download, industry_kickstart

        for mod in (dialog_import, industry_download):
            assert 'wait_mode="request"' in inspect.getsource(mod), mod.__name__
            assert 'wait_mode="background"' not in inspect.getsource(mod), mod.__name__
        assert 'wait_mode="background"' in inspect.getsource(industry_kickstart)

    def test_seed_logs_still_running_as_a_warning(self, clock, caplog):
        from vibe_modeling.backend.services.import_metamodel_writer import seed_metamodel_one

        ws = ws_returning(response(state="PENDING", statement_id="ins-x"), clock=clock, poll_cost_s=5.3)
        with caplog.at_level("WARNING", logger="vibe_modeling.backend.services.import_metamodel_writer"):
            out = seed_metamodel_one(
                ws, catalog="c", warehouse_id="w", model_json=_payload(),
                business_name="b", scope="ecm", version=1,
                log_prefix="execute_import", wait_mode="request",
            )
        assert out["still_running"] and out["errors"] == []
        warnings = [r for r in caplog.records if r.levelname == "WARNING"]
        assert any("still being written" in r.getMessage() and "ins-x" in r.getMessage() for r in warnings)
        assert not [r for r in caplog.records if r.levelname == "ERROR"]

    def test_failed_domain_insert_after_business_row_is_reported(self):
        """The business row lands, the domain INSERT fails: errors name the failure."""
        ws = MagicMock()
        ws.statement_execution.execute_statement.side_effect = [
            response(None),
            response(error="[DELTA_CONCURRENT_APPEND] conflict"),
        ]
        out = write_metamodel(
            ws,
            catalog="c", warehouse_id="w",
            model_json=_payload(), business_name="b", scope="ecm", version=1,
            wait_mode="request",
        )
        assert out["business"] == 1
        assert out["errors"] and "DELTA_CONCURRENT_APPEND" in out["errors"][0]


class TestRegistrySetupFirst:
    def test_setup_runs_before_the_first_insert_within_the_request_budget(self, captured_ws, monkeypatch):
        order: list[str] = []
        seen: list[tuple] = []
        original = captured_ws.statement_execution.execute_statement.side_effect

        def execute(*args, **kwargs):
            order.append("insert")
            return original(*args, **kwargs)

        def ensure(ws, catalog, warehouse_id, *, timeout_s):
            order.append("setup")
            seen.append((catalog, warehouse_id, timeout_s))
            return []

        captured_ws.statement_execution.execute_statement.side_effect = execute
        monkeypatch.setattr(_w, "ensure_metamodel_registry", ensure)
        out = write_metamodel(
            captured_ws, catalog="cat", warehouse_id="wh", model_json=_payload(),
            business_name="Mining Corp", scope="ecm", version=1, wait_mode="request",
        )
        assert out["errors"] == []
        assert order == ["setup", "insert", "insert", "insert", "insert"]
        catalog, warehouse_id, timeout_s = seen[0]
        assert (catalog, warehouse_id) == ("cat", "wh")
        assert 0 < timeout_s <= _w._REQUEST_BUDGET_S

    def test_background_setup_gets_the_write_cap(self, captured_ws, registry_setup):
        write_metamodel(
            captured_ws, catalog="cat", warehouse_id="wh", model_json=_payload(),
            business_name="Mining Corp", scope="ecm", version=1, wait_mode="background",
        )
        assert _w._REQUEST_BUDGET_S < registry_setup[0]["timeout_s"] <= _w._BACKGROUND_WRITE_TIMEOUT_S

    def test_failed_setup_writes_nothing_and_reports_the_setup_message(self, captured_ws, monkeypatch):
        from vibe_modeling.backend.services.metamodel_setup import MetamodelSetupError

        def refuse(*_a, **_kw):
            raise MetamodelSetupError("Couldn't create the agent's registry tables.", step="tables")

        monkeypatch.setattr(_w, "ensure_metamodel_registry", refuse)
        out = write_metamodel(
            captured_ws, catalog="cat", warehouse_id="wh", model_json=_payload(),
            business_name="Mining Corp", scope="ecm", version=1, wait_mode="request",
        )
        assert out["errors"] == ["Couldn't create the agent's registry tables."]
        assert out["business"] == 0
        assert captured_ws._captured_statements == []


class TestSeedWarnings:
    def test_clean_seed_and_unconfigured_skip_have_no_warning(self):
        assert _w.seed_warnings(None) == []
        assert _w.seed_warnings({"errors": [], "still_running": []}) == []

    def test_errors_and_still_running_are_named(self):
        out = _w.seed_warnings({"errors": ["boom one", "boom two"], "still_running": ["sid-1"]})
        assert len(out) == 2
        assert "can't be the base of a vibe run" in out[0]
        assert "boom one; boom two" in out[0]
        assert "still being written" in out[1]


class TestSeedErrorText:
    def test_a_warehouse_error_keeps_its_reason_but_not_the_echoed_statement(self):
        ws = MagicMock()
        ws.statement_execution.execute_statement.return_value = response(
            None,
            error="[INSUFFICIENT_PERMISSIONS] no MODIFY on table. SQLSTATE: 42501\n== SQL ==\n"
                  "INSERT INTO `cat`.`_metamodel`.`business` VALUES ('Secret Co', 'private text')",
        )
        out = write_metamodel(
            ws, catalog="cat", warehouse_id="wh", model_json=_payload(),
            business_name="Mining Corp", scope="ecm", version=1, wait_mode="request",
        )
        [error] = out["errors"]
        assert "INSUFFICIENT_PERMISSIONS" in error
        assert "== SQL ==" not in error and "private text" not in error
        [warning] = _w.seed_warnings(out)
        assert "private text" not in warning

    def test_a_connection_error_is_the_fixed_text_with_a_reference(self):
        from vibe_modeling.backend.error_sanitization import CONNECTION_ERROR_MESSAGE

        ws = MagicMock()
        ws.statement_execution.execute_statement.side_effect = ConnectionError(
            "HTTPSConnectionPool(host='secret-host.example', port=443)"
        )
        out = write_metamodel(
            ws, catalog="cat", warehouse_id="wh", model_json=_payload(),
            business_name="Mining Corp", scope="ecm", version=1, wait_mode="request",
        )
        [error] = out["errors"]
        assert "secret-host" not in error
        assert error.startswith(f"{CONNECTION_ERROR_MESSAGE} Reference: ")

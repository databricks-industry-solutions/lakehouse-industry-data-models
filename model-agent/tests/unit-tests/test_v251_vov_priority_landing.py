import copy
import re
import time
from dataclasses import dataclass
from types import SimpleNamespace
from typing import Any, Optional

from notebook_source_util import notebook_concat_source, slice_function_source, vov_ledger_globals


SRC = notebook_concat_source()


class _ListLogger:
    def __init__(self):
        self.info_msgs = []
        self.warn_msgs = []
        self.error_msgs = []

    def info(self, msg, *args, **kwargs):
        self.info_msgs.append(str(msg))

    def warning(self, msg, *args, **kwargs):
        self.warn_msgs.append(str(msg))

    def error(self, msg, *args, **kwargs):
        self.error_msgs.append(str(msg))


@dataclass
class RawVREQ:
    vreq_id: str
    intent: str
    target: str
    source_quote: str
    source_chunk_id: str
    severity: str = "medium"  # v2.9.6 alias=vov-severity-first
    is_user_directive: bool = False  # v2.9.6 alias=vov-merge-user-first
    priority_id: int = 9999  # v2.9.6 alias=vov-severity-first


@dataclass
class VReqOutcome:
    batch_id: str
    vreq_ids: tuple[str, ...]
    status: str
    diagnostic: str
    attempts: int


@dataclass
class VibeOutline:
    sections: tuple[Any, ...]
    full_text: str
    global_constraints: tuple[Any, ...]
    declared_entities_global: tuple[Any, ...]


@dataclass
class PipelineResult:
    initial_model: dict
    final_model: dict
    outline: VibeOutline
    raw_vreqs: list[Any]
    batches: list[Any]
    outcomes: list[VReqOutcome]
    coverage_pct: float
    rejected_handlers: list[tuple[str, str]]
    deferred_vreqs: list = None  # v2.9.6 alias=vov-defer-low-severity (defaulted for the test stub)
    vibe_input_vreqs: dict = None


def _exec_v251_namespace():
    ns = {
        **vov_ledger_globals(),
        "__name__": "_v251_test_ns",
        "copy": copy,
        "re": re,
        "time": time,
        "Optional": Optional,
        "RawVREQ": RawVREQ,
        "VReqOutcome": VReqOutcome,
        "VibeOutline": VibeOutline,
        "PipelineResult": PipelineResult,
        "Handler": object,
        "Batch": object,
        "InvariantSnapshot": object,
        "LLMClient": object,
        "logger": _ListLogger(),
        # v2.9.6 alias=vov-severity-first — the sort const used by the extracted helpers.
        "_V296_SEV_RANK": {"critical": 0, "high": 1, "medium": 2, "low": 3},
        # v4.1.5 test-harness debt fix: _v320_vov_calls/_reset_calls read these module-level
        # globals (the VOV LLM-bridge call counter + its lock). The isolated namespace must
        # provide them or run_vov_pipeline NameErrors mid-pipeline. Stub with real values.
        "_VOV_BRIDGE_CALL_LOCK": __import__("threading").Lock(),
        "_VOV_BRIDGE_CALL_COUNT": 0,
        "_VIBE_SCOPE_RUNTIME": None,
        "_vibe_scope_start_requested": lambda *args, **kwargs: None,
    }
    ordered_defs = [
        "_V251_PRIORITY_LINE_RE",
        # v2.9.6: run_vov_pipeline + _v251_priority_to_vreq now reference these helpers.
        "_v296_norm_severity",
        "_v296_sev_rank",
        "_v296_sort_vreqs",
        "_v251_parse_priorities",
        "_v251_priority_to_vreq",
        "_v251_model_root",
        "_v251_product_list",
        "_v251_find_domain",
        "_v251_find_product",
        "_v251_find_attribute_row",
        "_v251_iter_attribute_rows",
        "_v251_parse_priority_details",
        "_v410_resolve_pk",
        "_v415_complete_connect_details",
        "_v251_prevalidate_priority",
        "_v327_infer_coltype",
        "_vibe_scope_note_rename",
        "_v251_apply_priority_deterministic",
        "_v310_apply_rename_ledger",
        "_v251_apply_pass1_priorities",
        "_apply_handler_with_retry",
        "_v328_pack_budget",
        # v4.1.5 test-harness debt fix: run_vov_pipeline transitively calls these module-level
        # helpers; the hand-curated namespace list had drifted (pre-existing failures at v4.1.4
        # baseline aafc1c8 too). Add the real defs so the run_vov_pipeline tests can execute.
        "_v207_get_runtime_budget",
        "_v260_diagnose_slip",
        "_v260_priority_to_vreq_with_feedback",
        "_v261_vreq_with_feedback",
        "_v292_audit_extraction_completeness",
        "_v292_residual_signature",
        "_v299_collapse_preservation_vreqs",
        "_v299_is_preservation_only",
        "_v320_vov_calls",
        "_v320_vov_reset_calls",
        "_v330_recover_dropped_priorities",
        "_v413_vreq_to_det_op",
        "_v413_apply_det_op_inplace",
        "_vibe_scope_apply_pass1",
        "_vibe_scope_apply_det_op",
        "_vibe_scope_engine_gate",
        "_vibe_input_absorbed",
        "_vibe_input_map_vreqs",
        "run_vov_pipeline",
    ]
    for name in ordered_defs:
        if name == "_V251_PRIORITY_LINE_RE":
            idx = SRC.find("_V251_PRIORITY_LINE_RE = re.compile(")
            end = SRC.find("\n\n", idx)
            chunk = SRC[idx:end]
        else:
            chunk = slice_function_source(name, source=SRC)
        exec(compile(chunk, f"<{name}>", "exec"), ns)
    return ns


def test_v251_version_and_aliases_present():
    m = re.search(r'__AGENT_VERSION__\s*=\s*"([^"]+)"', SRC)
    assert m, "__AGENT_VERSION__ not found"
    # The v251 aliases must survive forward; the version moves on (>= 2.5.2,
    # single-digit semver per CLAUDE.md 3a). Do not pin an exact stale value.
    parts = tuple(int(x) for x in m.group(1).split("."))
    assert parts >= (2, 5, 2), f"expected >= 2.5.2, got {m.group(1)}"
    assert all(0 <= p <= 9 for p in parts), f"semver segments single-digit: {m.group(1)}"
    for marker in [
        "v251-vov-target-prevalidate FIRED",
        "v251-rename-atomic FIRED",
        "v251-vov-pass1-deterministic FIRED",
        "v251-vov-budget-exceeded FIRED",
    ]:
        assert marker in SRC


def test_v251_prevalidate_rejects_missing_target_and_fk():
    ns = _exec_v251_namespace()
    parse_details = ns["_v251_parse_priority_details"]
    prevalidate = ns["_v251_prevalidate_priority"]

    model = {
        "model": {
            "domains": [
                {
                    "name": "sales",
                    "products": [
                        {
                            "name": "order",
                            "attributes": [{"name": "order_id", "type": "BIGINT"}],
                        }
                    ],
                }
            ]
        }
    }

    p_missing_product = {
        "priority_id": 1,
        "action": "connect_table",
        "target": "sales.invoice",
        "reason": "add column order_id (BIGINT) with FK to sales.order.order_id",
    }
    ok1, reason1 = prevalidate(p_missing_product, model, parse_details(p_missing_product))
    assert ok1 is False
    assert reason1 == "target-domain-product-missing"

    p_missing_fk = {
        "priority_id": 2,
        "action": "connect_table",
        "target": "sales.order",
        "reason": "add column invoice_id (BIGINT) with FK to sales.invoice.invoice_id",
    }
    ok2, reason2 = prevalidate(p_missing_fk, model, parse_details(p_missing_fk))
    assert ok2 is False
    assert reason2 == "fk-target-missing"


def test_v251_atomic_rename_product_updates_fks_and_drops_old():
    ns = _exec_v251_namespace()
    parse_details = ns["_v251_parse_priority_details"]
    apply_det = ns["_v251_apply_priority_deterministic"]
    logger = _ListLogger()

    model = {
        "model": {
            "domains": [
                {
                    "name": "store",
                    "products": [
                        {"name": "store_cluster", "attributes": [{"name": "store_cluster_id", "type": "BIGINT"}]},
                        {"name": "cluster", "attributes": [{"name": "cluster_id", "type": "BIGINT"}]},
                        {
                            "name": "planogram",
                            "attributes": [
                                {
                                    "name": "store_cluster_id",
                                    "type": "BIGINT",
                                    "foreign_key_to": "store.store_cluster.store_cluster_id",
                                }
                            ],
                        },
                    ],
                }
            ]
        }
    }
    priority = {
        "priority_id": 4,
        "action": "rename_product",
        "target": "store.store_cluster",
        "reason": "rename to cluster because duplicate",
    }
    ok, diag = apply_det(priority, parse_details(priority), model, logger)
    assert ok is True
    assert diag == "applied"

    products = model["model"]["domains"][0]["products"]
    names = [p["name"] for p in products]
    assert "store_cluster" not in names
    assert "cluster" in names
    planogram_fk = products[-1]["attributes"][0]["foreign_key_to"]
    assert planogram_fk.startswith("store.cluster.")


def test_v251_atomic_rename_attribute_updates_foreign_keys():
    ns = _exec_v251_namespace()
    parse_details = ns["_v251_parse_priority_details"]
    apply_det = ns["_v251_apply_priority_deterministic"]

    model = {
        "model": {
            "domains": [
                {
                    "name": "inventory",
                    "products": [
                        {
                            "name": "shrinkage_event",
                            "attributes": [{"name": "shared_employee_id", "type": "BIGINT"}],
                        },
                        {
                            "name": "approval",
                            "attributes": [
                                {
                                    "name": "actor_id",
                                    "type": "BIGINT",
                                    "foreign_key_to": "inventory.shrinkage_event.shared_employee_id",
                                }
                            ],
                        },
                    ],
                }
            ]
        }
    }
    priority = {
        "priority_id": 28,
        "action": "rename_attribute",
        "target": "inventory.shrinkage_event",
        "reason": "rename column shared_employee_id to approver_employee_id",
    }
    ok, diag = apply_det(priority, parse_details(priority), model, _ListLogger())
    assert ok is True
    assert diag == "applied"

    attrs = model["model"]["domains"][0]["products"][0]["attributes"]
    attr_names = [a["name"] for a in attrs]
    assert "shared_employee_id" not in attr_names
    assert "approver_employee_id" in attr_names
    fk = model["model"]["domains"][0]["products"][1]["attributes"][0]["foreign_key_to"]
    assert fk == "inventory.shrinkage_event.approver_employee_id"


def test_v251_pass1_applies_resolved_and_marks_unresolvable():
    ns = _exec_v251_namespace()
    apply_pass1 = ns["_v251_apply_pass1_priorities"]

    model = {
        "model": {
            "domains": [
                {
                    "name": "sales",
                    "products": [
                        {"name": "order", "attributes": [{"name": "order_id", "type": "BIGINT"}]},
                        {"name": "invoice", "attributes": [{"name": "invoice_id", "type": "BIGINT"}]},
                    ],
                }
            ]
        }
    }
    priorities = [
        {
            "priority_id": 1,
            "vreq_id": "P001",
            "action": "connect_table",
            "target": "sales.invoice",
            "reason": "add column order_id (BIGINT) with FK to sales.order.order_id",
        },
        {
            "priority_id": 2,
            "vreq_id": "P002",
            "action": "connect_table",
            "target": "sales.payment",
            "reason": "add column invoice_id (BIGINT) with FK to sales.invoice.invoice_id",
        },
    ]

    logger = _ListLogger()
    updated, outcomes, residual = apply_pass1(priorities, model, logger)
    assert updated is model
    assert residual == []
    assert outcomes[0].status == "applied"
    assert outcomes[1].status == "structural_unresolvable"
    assert "[unresolvable] needs-sourcing-decision" in outcomes[1].diagnostic
    assert any("v251-vov-target-prevalidate FIRED" in m for m in logger.warn_msgs)
    assert any("v251-vov-pass1-deterministic FIRED" in m for m in logger.info_msgs)


def test_v251_run_pipeline_uses_deterministic_first_without_llm_batches():
    ns = _exec_v251_namespace()
    run_pipeline = ns["run_vov_pipeline"]

    called = {"batch_vreqs": 0}

    def _batch_vreqs(*args, **kwargs):
        called["batch_vreqs"] += 1
        return []

    ns["batch_vreqs"] = _batch_vreqs
    ns["build_outline"] = lambda *a, **k: None
    ns["chunk_vibe"] = lambda *a, **k: []
    ns["extract_all"] = lambda *a, **k: []
    ns["dedupe_vreqs"] = lambda *a, **k: []
    ns["capture_invariants"] = lambda *a, **k: None
    ns["synthesize_batch_handlers"] = lambda *a, **k: []
    ns["plan_waves"] = lambda *a, **k: []
    ns["_merge_partial"] = lambda model, new_m, targets: model

    vibe_text = "**PRIORITY 1 — connect_table: sales.invoice** — add column order_id (BIGINT) with FK to sales.order.order_id"
    model = {
        "model": {
            "domains": [
                {
                    "name": "sales",
                    "products": [
                        {"name": "order", "attributes": [{"name": "order_id", "type": "BIGINT"}]},
                        {"name": "invoice", "attributes": [{"name": "invoice_id", "type": "BIGINT"}]},
                    ],
                }
            ]
        }
    }
    result = run_pipeline(vibe_text, model, llm=object(), user_pinned_domains=(), user_pinned_products=(), parallel=False)
    assert called["batch_vreqs"] == 0
    assert result.coverage_pct == 100.0
    assert any(o.status == "applied" for o in result.outcomes)


def test_v251_run_pipeline_reapplies_missing_priorities_for_configured_loops():
    ns = _exec_v251_namespace()
    run_pipeline = ns["run_vov_pipeline"]

    calls = {"pass1": 0, "batch_vreqs": 0}

    def _fake_pass1(priorities, model, logger):
        calls["pass1"] += 1
        out = []
        for p in priorities:
            vid = str(p.get("vreq_id") or f"P{int(p.get('priority_id') or 0):03d}")
            out.append(VReqOutcome(batch_id=vid, vreq_ids=(vid,), status="skipped_unsafe", diagnostic="forced-miss", attempts=1))
        return model, out, []

    def _batch_vreqs(*args, **kwargs):
        calls["batch_vreqs"] += 1
        return []

    ns["_v251_apply_pass1_priorities"] = _fake_pass1
    ns["batch_vreqs"] = _batch_vreqs
    ns["capture_invariants"] = lambda *a, **k: None
    ns["synthesize_batch_handlers"] = lambda *a, **k: []
    ns["plan_waves"] = lambda *a, **k: []
    ns["_merge_partial"] = lambda model, new_m, targets: model

    vibe_text = "**PRIORITY 1 — connect_table: sales.invoice** — add column order_id (BIGINT) with FK to sales.order.order_id"
    model = {
        "model": {
            "domains": [
                {
                    "name": "sales",
                    "products": [
                        {"name": "order", "attributes": [{"name": "order_id", "type": "BIGINT"}]},
                        {"name": "invoice", "attributes": [{"name": "invoice_id", "type": "BIGINT"}]},
                    ],
                }
            ]
        }
    }
    result = run_pipeline(
        vibe_text,
        model,
        llm=object(),
        user_pinned_domains=(),
        user_pinned_products=(),
        parallel=False,
        priority_reapply_loops=3,
    )
    # v260 STALE-BREAK: when a reapply iteration makes ZERO progress (every
    # priority still skipped_unsafe), the agentic loop breaks early instead of
    # burning the remaining configured loops on a permanently-failing priority.
    # So pass1 is invoked at least twice (initial + >=1 reapply) but may stop
    # before exhausting all 3 loops. The contract is: it DID reapply, and the
    # residual priority is reported unfulfilled.
    assert 2 <= calls["pass1"] <= 3, f"expected 2-3 reapply invocations, got {calls['pass1']}"
    assert calls["batch_vreqs"] == 0
    assert any(o.status == "agentic_loop_unfulfilled" for o in result.outcomes)


def test_v251_apply_handler_stops_on_budget():
    ns = _exec_v251_namespace()
    fn = ns["_apply_handler_with_retry"]

    handler = SimpleNamespace(batch_id="b1", mutator_src="x", verifier_src="y", expected_changes_summary="")
    batch = SimpleNamespace(batch_id="b1", vreq_ids=("P001",), data_payload=())
    new_model, outcome = fn(
        handler,
        batch,
        {},
        invariants=None,
        llm=None,
        max_retries=3,
        pinned_domains=(),
        pinned_products=(),
        max_elapsed_s=-1.0,
    )
    assert new_model is None
    assert outcome.status == "time_budget_exceeded"
    assert "time-budget-exceeded" in outcome.diagnostic

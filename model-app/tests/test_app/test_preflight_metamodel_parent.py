"""Item 4: the parent-metamodel preflight gate.

A parent-reading iterate (VIBE_ITERATE / VIBE_NEW_ECM_MVM) whose parent
version has zero ``_metamodel.business`` rows would fail deep inside the agent
run at version resolution. ``_check_metamodel_parent_version_present`` turns
that into an actionable create-time 400 blocker. It is intent-only and
lenient: only a SUCCESSFUL COUNT returning zero blocks.
"""

from __future__ import annotations

from unittest.mock import MagicMock

import pytest

from sqlmodel import Session

from vibe_modeling.backend.db_models import AgentConfig, Business, ModelVersion
from vibe_modeling.backend.models import Intent, RunIn
from vibe_modeling.backend.services.orchestrator.preflight import _check_metamodel_parent_version_present

from _sql_fakes import response


def _seed(engine, *, catalog="deploy_cat", warehouse="wh-1"):
    with Session(engine) as s:
        s.add(AgentConfig(deployment_catalog=catalog, warehouse_id=warehouse))
        biz = Business(name="Iter Co", kind="business")
        s.add(biz)
        s.flush()
        mv = ModelVersion(
            business_id=biz.id, version=1, scope="ecm", status="completed",
        )
        s.add(mv)
        s.commit()
        return biz.id, mv.id


def _ws_count(n: int) -> MagicMock:
    ws = MagicMock()
    ws.statement_execution.execute_statement.return_value = response([[str(n)]])
    return ws


def _agent_config(catalog="deploy_cat"):
    return AgentConfig(deployment_catalog=catalog, warehouse_id="wh-1")


def test_gated_intent_zero_rows_blocks(engine):
    biz_id, parent_id = _seed(engine)
    ws = _ws_count(0)
    for intent in (Intent.VIBE_ITERATE, Intent.VIBE_NEW_ECM_MVM):
        data = RunIn(intent=intent, version_id=parent_id)
        with Session(engine) as s:
            blocker = _check_metamodel_parent_version_present(
                biz_id, data, _agent_config(), s, ws, live=True
            )
        assert blocker is not None and blocker.severity == "blocker", intent
        assert blocker.field_path != "business_id"  # → 400, not the 409 lock
        assert "metamodel" in blocker.message.lower()


def test_gated_intent_nonzero_rows_passes(engine):
    biz_id, parent_id = _seed(engine)
    ws = _ws_count(1)
    data = RunIn(intent=Intent.VIBE_ITERATE, version_id=parent_id)
    with Session(engine) as s:
        assert _check_metamodel_parent_version_present(
            biz_id, data, _agent_config(), s, ws, live=True
        ) is None


def test_non_gated_intents_never_blocked(engine):
    biz_id, parent_id = _seed(engine)
    ws = _ws_count(0)  # even with zero rows
    for intent in (
        Intent.NEW_BASE_MODEL, Intent.INSTALL, Intent.UNINSTALL,
    ):
        data = RunIn(intent=intent, version_id=parent_id)
        with Session(engine) as s:
            assert _check_metamodel_parent_version_present(
                biz_id, data, _agent_config(), s, ws, live=True
            ) is None, intent


def test_new_base_model_with_parent_version_id_not_triggered(engine):
    """Intent-only gate: a parent_version_id on NEW_BASE_MODEL does NOT fire."""
    biz_id, parent_id = _seed(engine)
    ws = _ws_count(0)
    data = RunIn(intent=Intent.NEW_BASE_MODEL, parent_version_id=parent_id)
    with Session(engine) as s:
        assert _check_metamodel_parent_version_present(
            biz_id, data, _agent_config(), s, ws, live=True
        ) is None
    # And the SQL was never even issued for a non-gated intent.
    ws.statement_execution.execute_statement.assert_not_called()


def test_unconfigured_catalog_passes_through(engine):
    biz_id, parent_id = _seed(engine)
    ws = _ws_count(0)
    data = RunIn(intent=Intent.VIBE_ITERATE, version_id=parent_id)
    with Session(engine) as s:
        # No deployment catalog on the agent config → lenient pass-through.
        assert _check_metamodel_parent_version_present(
            biz_id, data, _agent_config(catalog=""), s, ws, live=True
        ) is None
    ws.statement_execution.execute_statement.assert_not_called()


def test_unconfigured_warehouse_passes_through(engine):
    biz_id, parent_id = _seed(engine, warehouse="")
    ws = _ws_count(0)
    data = RunIn(intent=Intent.VIBE_ITERATE, version_id=parent_id)
    with Session(engine) as s:
        assert _check_metamodel_parent_version_present(
            biz_id, data, _agent_config(), s, ws, live=True
        ) is None
    ws.statement_execution.execute_statement.assert_not_called()


def test_preflight_uses_lower_comparison(engine):
    """Q1 regression guard: the iterate-preflight SQL must use
    ``LOWER(business) = LOWER(...)`` rather than a bare case-sensitive ``=``.
    Pre-fix code fails this assertion because it emits ``business = 'iter_co'``."""
    biz_id, parent_id = _seed(engine)
    ws = _ws_count(1)
    data = RunIn(intent=Intent.VIBE_ITERATE, version_id=parent_id)
    with Session(engine) as s:
        _check_metamodel_parent_version_present(biz_id, data, _agent_config(), s, ws, live=True)
    call_args = ws.statement_execution.execute_statement.call_args
    sql = call_args.kwargs.get("statement", "")
    assert "LOWER(business)" in sql, (
        f"preflight must use LOWER(business), got: {sql!r}"
    )
    assert "LOWER(" in sql and "= LOWER(" in sql, (
        f"preflight must wrap both sides in LOWER(), got: {sql!r}"
    )
    assert " business = " not in sql, (
        f"bare case-sensitive business = must be gone after Q1 fix, got: {sql!r}"
    )


def test_seed_to_preflight_roundtrip_invariant(engine):
    """Causal round-trip: the display-cased value W1 seeds is found by Q1's
    ``LOWER()``-based preflight for every business name class.

    The proof has two parts:

    (1) Algebraic: for each name, ``LOWER(metamodel_display_business(name))``
        equals ``LOWER(agent_business_segment(name))``.  Since ``.title()`` is
        a pure case transform, the underlying characters are identical.

    (2) Structural: the preflight SQL's ``LOWER()`` argument is
        ``agent_business_segment(business.name)`` (confirmed by the captured
        SQL from ``test_preflight_uses_lower_comparison``).  Combined with (1),
        the seeded column value and the lookup value lowercase to the same
        string — the ``LOWER()`` comparison succeeds.

    The test suite fails on reverts:
    - W1 revert → ``test_seed_writes_display_cased_business`` fails because the
      INSERT no longer contains ``'Terranova_Copy'``.
    - Q1 revert → ``test_preflight_uses_lower_comparison`` fails because the SQL
      reverts to a bare ``business = '...'``.
    - This test fails if ``metamodel_display_business`` produces different
      *characters* (not just different case) from ``agent_business_segment``,
      which would silently break the lookup even with both W1 and Q1 in place.

    Pre-fix: ``metamodel_display_business`` does not exist → ImportError.
    """
    from vibe_modeling.backend.core._names import (
        agent_business_segment,
        metamodel_display_business,
    )

    names = [
        "terranova_copy",
        "retail2b",
        "cpg",
        "Terranova Copy",
    ]
    for name in names:
        seeded = metamodel_display_business(name)
        lookup = agent_business_segment(name)
        assert seeded.lower() == lookup.lower(), (
            f"{name!r}: LOWER(seeded={seeded!r}) != LOWER(preflight={lookup!r}) — "
            f"the LOWER()-based preflight will not find the display-cased seed"
        )

    biz_id, parent_id = _seed(engine)
    ws = _ws_count(1)
    data = RunIn(intent=Intent.VIBE_ITERATE, version_id=parent_id)
    with Session(engine) as s:
        result = _check_metamodel_parent_version_present(biz_id, data, _agent_config(), s, ws, live=True)
    assert result is None, "preflight with count=1 must return no blocker (row found)"

    sql = ws.statement_execution.execute_statement.call_args.kwargs.get("statement", "")
    import re as _re
    m = _re.search(r"LOWER\('([^']*)'\)", sql)
    assert m, f"could not extract LOWER() argument from preflight SQL: {sql!r}"
    preflight_arg = m.group(1)
    expected_seg = agent_business_segment("Iter Co")
    assert preflight_arg == expected_seg, (
        f"preflight LOWER() arg {preflight_arg!r} != agent_business_segment('Iter Co')={expected_seg!r}; "
        f"the preflight is not looking up the right segment"
    )
    display_cased = metamodel_display_business("Iter Co")
    assert display_cased.lower() == preflight_arg.lower(), (
        f"LOWER(display_cased={display_cased!r}) != LOWER(preflight_arg={preflight_arg!r}) — "
        f"the causal link is broken"
    )


def test_query_error_is_lenient(engine):
    biz_id, parent_id = _seed(engine)
    ws = MagicMock()
    ws.statement_execution.execute_statement.side_effect = RuntimeError("boom")
    data = RunIn(intent=Intent.VIBE_ITERATE, version_id=parent_id)
    with Session(engine) as s:
        issue = _check_metamodel_parent_version_present(
            biz_id, data, _agent_config(), s, ws, live=True
        )
    # Lenient: a count that could not be read is a "couldn't check" warning.
    assert issue is not None and issue.severity == "warning"


@pytest.mark.parametrize("answer", [
    response(error="[INSUFFICIENT_PERMISSIONS] no SELECT on business"),
    response(state="CANCELED", statement_id="s1"),
    response(error="[TABLE_OR_VIEW_NOT_FOUND] `deploy_cat`.`_metamodel`.`business`"),
], ids=["failed", "timeout", "missing_table"])
def test_an_unreadable_count_is_a_warning_never_a_blocker(engine, answer):
    """Lenient by design: only a count that came back zero blocks. A failed
    count, one the server cancelled at the end of its wait, or a missing
    business table is a "couldn't check" warning, and nothing else is called
    (the server cancels; no client cancel, no extra read)."""
    biz_id, parent_id = _seed(engine)
    ws = MagicMock()
    ws.statement_execution.execute_statement.return_value = answer
    data = RunIn(intent=Intent.VIBE_ITERATE, version_id=parent_id)
    with Session(engine) as s:
        issue = _check_metamodel_parent_version_present(
            biz_id, data, _agent_config(), s, ws, live=True
        )
    assert issue is not None and issue.severity == "warning"
    assert "Couldn't check" in issue.message
    kwargs = ws.statement_execution.execute_statement.call_args.kwargs
    assert kwargs["wait_timeout"] == "30s"
    assert kwargs["on_wait_timeout"].value == "CANCEL"
    ws.statement_execution.cancel_execution.assert_not_called()
    ws.statement_execution.get_statement.assert_not_called()

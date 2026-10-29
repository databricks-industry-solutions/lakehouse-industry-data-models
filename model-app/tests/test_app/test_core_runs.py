"""``core/_runs.py``: in-flight count and the per-business active run.

The router uses both (``GET /health`` and the create-time per-business lock)
and keeps no inline copy of the in-flight statuses.
"""

from __future__ import annotations

import inspect

import pytest
from sqlmodel import Session, SQLModel, create_engine

from vibe_modeling.backend import router as router_module
from vibe_modeling.backend.core._runs import (
    IN_FLIGHT_RUN_STATUSES,
    active_run_for_business,
    count_in_flight_runs,
)
from vibe_modeling.backend.db_models import Business, Run

ALL_STATUSES = (
    "pending", "running", "stale", "completed", "failed", "cancelled", "rolled_back_failed",
)


@pytest.fixture
def session():
    engine = create_engine("sqlite://")
    SQLModel.metadata.create_all(engine)
    with Session(engine) as s:
        yield s


def _business(session, name: str) -> Business:
    b = Business(name=name)
    session.add(b)
    session.commit()
    session.refresh(b)
    return b


def _runs(session, business: Business, statuses) -> list[Run]:
    rows = [Run(business_id=business.id, status=s) for s in statuses]
    session.add_all(rows)
    session.commit()
    return rows


def test_the_router_has_no_inline_copy():
    source = inspect.getsource(router_module)
    assert "Run.status.in_(" not in source
    assert '"pending", "running"' not in source and "IN_FLIGHT_STATUSES" not in source
    assert not hasattr(router_module, "_count_in_flight_runs")


def test_empty_database_counts_zero(session):
    assert count_in_flight_runs(session) == 0


def test_count_across_every_status(session):
    a, b = _business(session, "A"), _business(session, "B")
    _runs(session, a, ALL_STATUSES)
    _runs(session, b, ("running", "completed"))
    assert count_in_flight_runs(session) == 4


@pytest.mark.parametrize("status", ALL_STATUSES)
def test_active_run_for_each_status(session, status):
    a, b = _business(session, "A"), _business(session, "B")
    rows = _runs(session, a, (status,))
    _runs(session, b, ("running",))
    mine = active_run_for_business(session, a.id)
    assert (mine.id if mine else None) == (rows[0].id if status in IN_FLIGHT_RUN_STATUSES else None)


def test_active_run_ignores_other_businesses(session):
    a, b = _business(session, "A"), _business(session, "B")
    _runs(session, b, ("pending",))
    assert active_run_for_business(session, a.id) is None

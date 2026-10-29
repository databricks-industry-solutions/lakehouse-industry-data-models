"""Seeding a settings singleton row from install-time defaults.

An install flag may seed a setting's first value; after that, Settings own it
(conventions §2). Two moments seed:

- **Row creation** (:func:`get_or_create_settings_row`): the first read
  creates the singleton with the install defaults.
- **Boot** (:func:`seed_blank`): an install that already has a row (an
  upgrade, or a feature enabled later) never reaches row creation, so boot
  fills a column only while it is still blank (NULL, empty or whitespace). A
  value saved in Settings is never touched, and reads never update the row.
"""

from __future__ import annotations

from typing import Any, TypeVar

from sqlalchemy import func, or_, update
from sqlmodel import Session, SQLModel, col, select

RowT = TypeVar("RowT", bound=SQLModel)


def get_or_create_settings_row(session: Session, model: type[RowT], defaults: dict[str, Any]) -> RowT:
    """The singleton ``model`` row, created with ``defaults`` (and committed)
    when none exists. An existing row is returned as it is."""
    row = session.exec(select(model).limit(1)).first()
    if row is not None:
        return row
    row = model(**defaults)
    session.add(row)
    session.commit()
    session.refresh(row)
    return row


def seed_blank(executor, column, value: str | None) -> int:
    """Fill ``column`` with ``value`` on every row where it is blank, in one
    atomic UPDATE. ``executor`` is a SQLAlchemy ``Connection`` or ``Session``;
    the caller commits and, with a ``Session``, refreshes the rows it holds
    (the identity map is not synchronized). A blank ``value`` is a no-op.
    Returns the rows updated."""
    value = (value or "").strip()
    if not value:
        return 0
    stmt = (
        update(column.class_)
        .where(or_(col(column).is_(None), func.trim(col(column)) == ""))
        .values({column.key: value})
        .execution_options(synchronize_session=False)
    )
    return executor.execute(stmt).rowcount or 0

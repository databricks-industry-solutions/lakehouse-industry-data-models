"""Saved Domain Taxonomy wizard: one row per user in ``taxonomy_wizard_states``.

The wizard autosaves its whole document (step, intake, sector, strictness,
the finished tree and sections) so a reload, a closed tab or an app restart
does not lose the work. Expired rows (``SAVED_TTL`` after the last save) are
purged on every load and save.

Two tabs: every save names the revision it was based on. The write is one
conditional ``UPDATE ... WHERE revision = :based_on``, so of two racing saves
one wins and the other gets ``StaleRevision`` with the current revision.
"""

from __future__ import annotations

import json
from dataclasses import dataclass
from datetime import datetime, timedelta, timezone

from typing import cast

from sqlalchemy import CursorResult, delete, update
from sqlalchemy.exc import IntegrityError
from sqlmodel import Session, col, select

from ..core._time import as_utc
from ..db_models import Sector, TaxonomyWizardState
from .models import TaxonomyIntake, TaxonomySection, TaxonomyTree, TaxonomyWizardStateIn, TaxonomyWizardStateOut

SAVED_TTL = timedelta(days=7)
# The stored document (intake, tree and sections as JSON). A real wizard is a
# few tens of KB; the cap keeps one user's row bounded.
MAX_DOCUMENT_BYTES = 1_000_000


@dataclass(frozen=True)
class StaleRevision(Exception):
    """The save was based on an older revision; ``current`` is the stored one
    (0 when nothing is stored)."""

    current: int


@dataclass(frozen=True)
class DocumentTooLarge(Exception):
    size: int


def _now() -> datetime:
    return datetime.now(timezone.utc)


def purge_expired(session: Session, now: datetime) -> None:
    session.execute(
        delete(TaxonomyWizardState).where(col(TaxonomyWizardState.expires_at) < now)
        .execution_options(synchronize_session=False)
    )


def _row(session: Session, owner: str) -> TaxonomyWizardState | None:
    return session.exec(select(TaxonomyWizardState).where(TaxonomyWizardState.owner == owner)).first()


def _out(row: TaxonomyWizardState) -> TaxonomyWizardStateOut:
    sections = json.loads(row.sections_json) if row.sections_json else {}
    return TaxonomyWizardStateOut(
        revision=row.revision,
        step=row.step,
        sector_id=row.sector_id,
        strictness=row.strictness,  # type: ignore[arg-type]
        intake=TaxonomyIntake.model_validate_json(row.intake_json),
        tree=TaxonomyTree.model_validate_json(row.tree_json) if row.tree_json else None,
        sections={k: TaxonomySection.model_validate(v) for k, v in sections.items()},
        updated_at=as_utc(row.updated_at),
        expires_at=as_utc(row.expires_at),
    )


def load(session: Session, owner: str, *, now: datetime | None = None) -> TaxonomyWizardStateOut | None:
    now = now or _now()
    purge_expired(session, now)
    session.commit()
    row = _row(session, owner)
    return _out(row) if row is not None else None


def _sector_or_none(session: Session, sector_id: str | None) -> str | None:
    """A sector deleted since the user picked it saves as none, as the FK's
    ON DELETE SET NULL would have left it."""
    if not sector_id:
        return None
    return sector_id if session.get(Sector, sector_id) is not None else None


def _write(session: Session, owner: str, based_on: int, values: dict, now: datetime) -> None:
    """One attempt: insert (``based_on`` 0) or the conditional update, then
    commit. Raises ``StaleRevision`` when the row is not at ``based_on``, and
    lets any other ``IntegrityError`` through (rolled back)."""
    try:
        if based_on == 0:
            session.add(TaxonomyWizardState(owner=owner, created_at=now, **values))
            session.flush()
        else:
            moved = cast(CursorResult, session.execute(
                update(TaxonomyWizardState)
                .where(col(TaxonomyWizardState.owner) == owner, col(TaxonomyWizardState.revision) == based_on)
                .values(**values)
                .execution_options(synchronize_session=False)
            )).rowcount
            if moved != 1:
                session.rollback()
                current = _row(session, owner)
                raise StaleRevision(current.revision if current is not None else 0)
        session.commit()
    except IntegrityError:
        session.rollback()
        current = _row(session, owner)
        if based_on == 0 and current is not None:  # another tab saved first
            raise StaleRevision(current.revision) from None
        raise


def save(
    session: Session, owner: str, data: TaxonomyWizardStateIn, *, now: datetime | None = None,
) -> TaxonomyWizardStateOut:
    """Write the caller's wizard if ``data.revision`` is the stored revision
    (0 when nothing is stored), as revision + 1. Raises ``StaleRevision``, or
    ``DocumentTooLarge`` before writing anything."""
    now = now or _now()
    intake_json = data.intake.model_dump_json()
    tree_json = data.tree.model_dump_json() if data.tree is not None else None
    sections_json = json.dumps({k: v.model_dump() for k, v in data.sections.items()}) if data.sections else None
    size = sum(len(x.encode()) for x in (intake_json, tree_json, sections_json) if x)
    if size > MAX_DOCUMENT_BYTES:
        raise DocumentTooLarge(size)
    purge_expired(session, now)
    # Committed on its own, so the rollback of a stale save keeps the purge.
    session.commit()
    values = {
        "step": data.step,
        "sector_id": _sector_or_none(session, data.sector_id),
        "strictness": data.strictness,
        "intake_json": intake_json,
        "tree_json": tree_json,
        "sections_json": sections_json,
        "revision": data.revision + 1,
        "updated_at": now,
        "expires_at": now + SAVED_TTL,
    }
    try:
        _write(session, owner, data.revision, values, now)
    except IntegrityError:
        # Not a stale revision: the sector was deleted between the check and
        # the write. Decide from the state read again: save without it.
        if values["sector_id"] is None or _sector_or_none(session, values["sector_id"]) is not None:
            raise
        values["sector_id"] = None
        _write(session, owner, data.revision, values, now)
    return TaxonomyWizardStateOut(
        revision=values["revision"], step=data.step, sector_id=values["sector_id"], strictness=data.strictness,
        intake=data.intake, tree=data.tree, sections=data.sections,
        updated_at=now, expires_at=values["expires_at"],
    )


def discard(session: Session, owner: str) -> bool:
    """Delete the caller's saved wizard. False when there was none."""
    removed = cast(CursorResult, session.execute(
        delete(TaxonomyWizardState).where(col(TaxonomyWizardState.owner) == owner)
        .execution_options(synchronize_session=False)
    )).rowcount
    session.commit()
    return bool(removed)

"""Resolve free-text industry alignment to a catalog ``Industry``.

One rule for every place that turns an ``industry_alignment`` string into an
``industry_id``: the import analyze and execute routes, initial sync, and
``createBusiness`` / ``updateBusiness``. The UI mirrors :func:`industry_slug`
and :func:`pick_industry` in ``ui/lib/industry.ts``; both sides are tested
against ``tests/fixtures/industry_slug_fixture.json``. The
``v_0_9_0_1`` migration keeps its own frozen copy of the slug rule, pinned to
this one by the same fixture.

Matching compares slugs in Python. The table is small, and SQL ``LIKE`` would
treat ``_`` and ``%`` in the text as wildcards.
"""

from __future__ import annotations

import logging
import re
from collections.abc import Iterable
from typing import Optional, Protocol, TypeVar

from sqlmodel import Session, select

from .db_models import Industry

logger = logging.getLogger(__name__)

_NON_ALNUM = re.compile(r"[^a-z0-9]+")


class IndustryLike(Protocol):
    name: str
    short_name: str
    is_active: bool
    is_auto_created: bool


_I = TypeVar("_I", bound=IndustryLike)


def industry_slug(value: Optional[str]) -> str:
    """Lowercase; every run of non-alphanumerics becomes one hyphen; hyphens
    trimmed. ``"Energy - Utilities"`` and ``"energy_utilities"`` both give
    ``"energy-utilities"``. An empty slug matches nothing."""
    return _NON_ALNUM.sub("-", (value or "").strip().lower()).strip("-")


def matching_industries(industries: Iterable[_I], text: Optional[str]) -> list[_I]:
    """Every active industry whose ``name`` or ``short_name`` slug equals the
    slug of ``text``; empty for an empty slug."""
    slug = industry_slug(text)
    if not slug:
        return []
    return [
        i for i in industries
        if i.is_active and slug in (industry_slug(i.name), industry_slug(i.short_name))
    ]


def pick_industry(industries: Iterable[_I], text: Optional[str]) -> Optional[_I]:
    """The one industry of :func:`matching_industries`. A curated industry
    wins over an auto-created one. Two matches of the same kind are ambiguous
    and give ``None``, as does no match or an empty slug."""
    matches = matching_industries(industries, text)
    curated = [i for i in matches if not i.is_auto_created]
    best = curated or matches
    if len(best) == 1:
        return best[0]
    if best:
        logger.warning("industry %r matches %d catalog industries; left unassigned", text, len(best))
    return None


def resolve_industry(session: Session, text: Optional[str]) -> Optional[Industry]:
    """:func:`pick_industry` over the ``industries`` table."""
    if not industry_slug(text):
        return None
    return pick_industry(session.exec(select(Industry)).all(), text)


def industry_candidates(session: Session, text: Optional[str]) -> list[Industry]:
    """:func:`matching_industries` over the ``industries`` table."""
    if not industry_slug(text):
        return []
    return matching_industries(session.exec(select(Industry)).all(), text)


def resolve_industry_id(session: Session, text: Optional[str]) -> Optional[str]:
    industry = resolve_industry(session, text)
    return industry.id if industry is not None else None


def industry_ambiguous_detail(text: str, candidates: Iterable[Industry]) -> dict:
    """The 409 detail for an industry that would share its slug with active
    catalog industries: the candidates go under their own key so the dialog
    can offer them."""
    found = sorted(candidates, key=lambda i: i.name)
    names = ", ".join(f"'{i.name}'" for i in found)
    return {
        "error": "industry_ambiguous",
        "industries": [{"id": i.id, "name": i.name} for i in found],
        "message": f"'{text}' matches {len(found)} catalog industr{'y' if len(found) == 1 else 'ies'} ({names}). Pick one of them.",
    }

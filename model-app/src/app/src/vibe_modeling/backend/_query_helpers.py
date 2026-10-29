"""Scope-aware ModelVersion lookup + version-allocation helpers.

Background: the agent's per-scope version counter — ECM v=N and MVM v=N
are siblings produced by `shrink ecm` (ECM v=N → MVM v=N, opposite
scope). The DB used to store a single global counter, which made
``select(MV).where(MV.version==N, MV.business_id==X)`` ambiguous whenever
both an ECM and an MVM existed at the same ordinal.

This module is the single source of truth for:

* :func:`resolve_model_version` — look up a unique row by the
  `(business_id, version_int, scope)` natural key. Use this everywhere
  instead of querying by ``(business, version)`` alone.
* :func:`next_version_for_scope` — compute ``max(version) + 1`` scoped
  to a single ``(business_id, scope)`` pair. Use this at every MV
  creation site so ECM and MVM number independently.
* :func:`parse_generated_from_version` — parse the agent's
  ``"v{N}_{scope}"`` lineage tag; :func:`parse_version_number` reads any
  agent version label (that tag or a bare number) as an int.
* :func:`resolve_lineage_parent` — combines the above two: parse the
  tag and find the parent MV row; :func:`resolve_model_json_parent` — the
  parent a model.json names (5.3.3 ``lineage`` block, else the tag).
* :func:`businesses_by_segment` — businesses keyed by the agent's
  ``_metamodel`` business segment; :func:`metamodel_row_key` — the
  ``(segment, version, scope)`` key of a ``_metamodel.business`` row.
"""

from __future__ import annotations

import re
from typing import Optional

from sqlmodel import Session, select

from .agent_compat import generated_from_version_tag, model_json_block
from .core._names import agent_business_segment, normalize_scope
from .db_models import Business, ModelVersion


_GENERATED_FROM_RE = re.compile(r"^v(\d+)_(ecm|mvm)$")
_BARE_VERSION_RE = re.compile(r"^v?(\d+)$")


def name_taken_message(name: str) -> str:
    """The user-facing text for a business/industry name clash."""
    return (
        f"A business or industry named '{name}' already exists "
        f"(names must be unique after normalization)."
    )


class BusinessNameConflict(ValueError):
    """A business/industry name is unavailable because it normalizes to an
    existing row's ``agent_business_segment``.

    The raw ``Business.name`` unique constraint only blocks EXACT clashes.
    This is the sanitization-aware guard: two names that collapse to the same
    ``agent_business_segment`` (case + punctuation folded - the ``_metamodel``
    key) would silently overwrite each other's Delta rows once seeded, even
    though they never trip the raw-name unique constraint. Carries the
    offending ``name`` and the ``existing`` row so each caller can shape its
    own 409 detail.
    """

    def __init__(self, name: str, existing: Business) -> None:
        self.name = name
        self.existing = existing
        super().__init__(name_taken_message(name))


def resolve_model_json_parent(
    session: Session, business_id: str, model_json: object
) -> Optional[ModelVersion]:
    """The parent version an agent model.json names, or ``None``.

    Agent 5.3.3 writes the parent in its ``lineage`` block (``base_version``
    and ``base_scope``); older and hand-edited files carry a
    ``generated_from_version`` tag at the root or in ``model``
    (:func:`agent_compat.generated_from_version_tag`). The lineage block
    wins. ``None`` when neither names a version this business has.
    """
    lineage = model_json_block(model_json, "lineage")
    if isinstance(lineage, dict):
        base = parse_version_number(lineage.get("base_version"))
        scope = normalize_scope(str(lineage.get("base_scope") or ""))
        if base and scope:
            parent = resolve_model_version(session, business_id, base, scope)
            if parent is not None:
                return parent
    tag = generated_from_version_tag(model_json)
    return resolve_lineage_parent(session, business_id, tag) if tag else None


def ensure_business_name_available(
    session: Session, name: str, *, exclude_id: Optional[str] = None
) -> None:
    """Raise :class:`BusinessNameConflict` if ``name`` collides with any
    existing business/industry after ``agent_business_segment`` normalization.

    Case- AND punctuation-insensitive: ``"Acme Retail"``, ``"acme_retail"``,
    and ``"Acme & Co."``/``"Acme Co"`` all collapse to the same segment and so
    are mutually exclusive. ``exclude_id`` skips one row (a no-op self-rename).

    Scans every ``Business`` row (kind-agnostic - industries are ``Business``
    rows too, so cross-kind clashes are caught both directions). The table is
    small (tens to low hundreds); a stored ``name_segment`` column is only
    worth it if a profile later shows this hot.
    """
    seg = agent_business_segment(name)
    if not seg:
        return
    for b in businesses_by_segment(session).get(seg, []):
        if exclude_id is not None and b.id == exclude_id:
            continue
        raise BusinessNameConflict(name, b)


def businesses_by_segment(session: Session) -> dict[str, list[Business]]:
    """Every business and industry, grouped by ``agent_business_segment(name)``,
    the key the agent stores in ``_metamodel``.

    ``Business.name`` is unique but the segment is not ("WT Base" and
    "WT-Base" both give ``wt_base``), so a segment can map to several rows;
    callers that resolve a ``_metamodel`` row to one business treat that as
    ambiguous.
    """
    out: dict[str, list[Business]] = {}
    for b in session.exec(select(Business).order_by(Business.name)).all():
        seg = agent_business_segment(b.name)
        if seg:
            out.setdefault(seg, []).append(b)
    return out


def resolve_model_version(
    session: Session,
    business_id: str,
    version_int: int,
    scope: str,
) -> Optional[ModelVersion]:
    """Look up the unique MV identified by ``(business, version, scope)``.

    Returns ``None`` if not found. Use this everywhere instead of querying
    by ``(business, version)`` alone — that's now ambiguous.
    """
    if not business_id or not scope or version_int <= 0:
        return None
    return session.exec(
        select(ModelVersion)
        .where(ModelVersion.business_id == business_id)
        .where(ModelVersion.version == version_int)
        .where(ModelVersion.scope == scope)
    ).first()


def next_version_for_scope(
    session: Session, business_id: str, scope: str
) -> int:
    """Return the next per-scope ``version`` integer for a business.

    Computes ``max(version WHERE business_id=X AND scope=this_scope) + 1``,
    defaulting to 1 when no rows exist. Match the agent's per-scope
    counter so DB ordinals line up with the agent's ``v{N}_{scope}``
    Volume folders.
    """
    if not business_id:
        return 1
    rows = session.exec(
        select(ModelVersion)
        .where(ModelVersion.business_id == business_id)
        .where(ModelVersion.scope == (scope or ""))
        .order_by(ModelVersion.version.desc())
    ).all()
    if not rows:
        return 1
    # Defensive: order_by + first() should be enough but a stale-cache /
    # mock SQLite view sometimes misorders — pick the literal max.
    return max(r.version for r in rows) + 1


def parse_generated_from_version(value: str) -> Optional[tuple[int, str]]:
    """Parse an agent ``generated_from_version`` tag.

    ``'v1_ecm'`` → ``(1, 'ecm')``; ``'unknown'`` / ``''`` / malformed → ``None``.
    """
    m = _GENERATED_FROM_RE.match(value or "")
    if not m:
        return None
    return (int(m.group(1)), m.group(2))


def parse_version_number(value: object) -> Optional[int]:
    """The integer of an agent version label, or ``None``.

    A ``v{N}_{scope}`` tag goes through :func:`parse_generated_from_version`;
    otherwise a bare number is accepted (``7``, ``"7"``, ``"v7"``). Booleans
    and anything else give ``None``.
    """
    if isinstance(value, bool):
        return None
    if isinstance(value, int):
        return value
    text = str(value or "").strip()
    parsed = parse_generated_from_version(text)
    if parsed:
        return parsed[0]
    m = _BARE_VERSION_RE.match(text)
    return int(m.group(1)) if m else None


def resolve_lineage_parent(
    session: Session, business_id: str, generated_from_version: str
) -> Optional[ModelVersion]:
    """Look up the parent MV from a ``generated_from_version`` tag.

    Combines :func:`parse_generated_from_version` and
    :func:`resolve_model_version`. Returns ``None`` when the tag is
    missing/malformed or no row matches.
    """
    parsed = parse_generated_from_version(generated_from_version)
    if not parsed:
        return None
    version_int, scope = parsed
    return resolve_model_version(session, business_id, version_int, scope)


def metamodel_row_key(row: dict) -> Optional[tuple[str, int, str]]:
    """``(agent_business_segment, version, normalize_scope)`` of a
    ``_metamodel.business`` row, or None when a part is missing or invalid.

    The agent stores the display-cased segment (``Wt_Base``), a bare or
    ``v``-prefixed version and the short scope; this is the key that matches
    an app business and version to the row.
    """
    segment = agent_business_segment(row.get("business") or "")
    version = parse_version_number(row.get("version"))
    scope = normalize_scope(row.get("model_scope") or "")
    if not segment or not version or version <= 0 or not scope:
        return None
    return segment, version, scope


__all__ = [
    "resolve_model_version",
    "next_version_for_scope",
    "parse_generated_from_version",
    "parse_version_number",
    "resolve_lineage_parent",
    "resolve_model_json_parent",
    "ensure_business_name_available",
    "businesses_by_segment",
    "metamodel_row_key",
    "BusinessNameConflict",
]

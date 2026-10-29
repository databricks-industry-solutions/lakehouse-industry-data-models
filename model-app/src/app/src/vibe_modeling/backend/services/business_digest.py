"""Extract business identity + context from a model.json payload.

Agent exports carry the business identity in two places:

- ``model_requirements.business_name`` / ``model_requirements.description``
  — what the user typed when starting the run
- ``model.industry_alignment`` and ``model.{core_business_processes,
  orgnaization_divisions, common_business_jargons,
  operational_systems_of_records, industry_governing_body}`` —
  the agent's mirror of the business-context block

This module unwraps both layouts (envelope and flat) and returns a
single ``BusinessDigest`` the import flow uses for two things:

1. Story 1 (create-business-by-importing): seed the new ``Business`` row
   without making the user retype identity that's already in the file.
2. Story 2 (import into existing business): diff the digest against the
   target ``Business`` so the UI can warn on mismatched name/industry
   before the import lands.
"""

from __future__ import annotations

import re
from typing import Any, Optional

from ..industry_resolve import industry_slug
from ..models import BusinessDigest, FieldMismatch


# Free-form business-context fields the agent stamps onto the inner
# ``model`` block. Keep in lock-step with the agent's writer (see
# ``tests/fixtures/mock_vibe_agent/mock_vibe_agent.py``).
_CONTEXT_FIELDS = (
    "core_business_processes",
    "data_domains",
    "orgnaization_divisions",  # agent typo — keep canonical
    "common_business_jargons",
    "operational_systems_of_records",
    "industry_governing_body",
)


def _split_items(value: str) -> list[str]:
    """Split a comma-separated agent field into items, ignoring commas nested
    inside parentheses. The agent comma-joins list entries but uses ``;`` as
    the inner separator inside ``TERM (a; b; c)`` parentheticals, so a paren-
    depth-aware split keeps each entry intact."""
    items: list[str] = []
    buf: list[str] = []
    depth = 0
    for ch in value:
        if ch == "(":
            depth += 1
            buf.append(ch)
        elif ch == ")":
            depth = max(0, depth - 1)
            buf.append(ch)
        elif ch == "," and depth == 0:
            items.append("".join(buf).strip())
            buf = []
        else:
            buf.append(ch)
    items.append("".join(buf).strip())
    return [i for i in items if i]


_JARGON_RE = re.compile(r"^(?P<term>.+?)\s*\((?P<meaning>.+)\)$")


def _as_jargon(item: str) -> str:
    """Render a ``TERM (meaning)`` jargon entry as ``TERM: meaning``; leave
    other shapes untouched."""
    m = _JARGON_RE.match(item)
    if m:
        return f"{m.group('term').strip()}: {m.group('meaning').strip()}"
    return item


def _bullet_list(value: Any, *, jargon: bool = False) -> str:
    """Build an alphabetically-sorted Markdown bullet list from a dict, list,
    or comma-separated string. Dict entries render as ``key: value``; when
    ``jargon``, ``TERM (meaning)`` string entries also become ``TERM: meaning``.
    Returns ``""`` when the source has no entries."""
    if isinstance(value, dict):
        items = [
            f"{str(k).strip()}: {str(v).strip()}"
            for k, v in value.items()
            if str(k).strip()
        ]
    elif isinstance(value, (list, tuple)):
        items = [str(x).strip() for x in value if str(x).strip()]
    else:
        items = _split_items(str(value or ""))
        if jargon:
            items = [_as_jargon(i) for i in items]
    items = sorted(items, key=str.casefold)
    return "\n".join(f"- {i}" for i in items)


def _assemble_business_vibes(
    *,
    description: str,
    core_business_processes: Any,
    data_domains: Any,
    operational_systems_of_records: Any,
    industry_governing_body: Any,
    org_divisions: Any,
    common_business_jargons: Any,
) -> str:
    """Draft a detailed-description Markdown doc from the agent's enriched
    business-context fields — the ``business_vibes`` seed on import. The lead
    is the free-form description; each remaining section becomes an
    alphabetically-sorted bullet list (jargon as ``TERM: meaning``), emitted
    only when its source has entries. This is a *starting point* the user
    edits: the detailed description is never stored in model.json, so we
    rebuild it from the context the agent did persist."""
    parts: list[str] = []
    if description.strip():
        parts.append(description.strip())
    for heading, value, jargon in (
        ("Core business processes", core_business_processes, False),
        ("Data domains", data_domains, False),
        ("Systems of record", operational_systems_of_records, False),
        ("Governing bodies & regulators", industry_governing_body, False),
        ("Organization divisions", org_divisions, False),
        ("Common business jargon", common_business_jargons, True),
    ):
        body = _bullet_list(value, jargon=jargon)
        if body:
            parts.append(f"## {heading}\n{body}")
    return "\n\n".join(parts)


def _unwrap(model_payload: dict) -> tuple[dict, dict]:
    """Return ``(requirements, model)`` from either the envelope or flat shape.

    Envelope: ``{"model_requirements": {...}, "model": {...}}``.
    Flat: ``{"type": "business", "name": "...", ...}`` — treat the same
    dict as both requirements + model so callers can read uniformly.
    """
    if not isinstance(model_payload, dict):
        return {}, {}
    requirements = model_payload.get("model_requirements")
    inner = model_payload.get("model")
    if isinstance(requirements, dict) and isinstance(inner, dict):
        return requirements, inner
    # Flat shape — the payload IS the model. Reuse it for requirements
    # so name/description lookups still resolve to the file's own values.
    return model_payload, model_payload


def extract_business_digest(model_payload: dict) -> Optional[BusinessDigest]:
    """Pull the business identity + context fields out of a model.json.

    Returns ``None`` when no identifying name is present (the import is
    almost certainly invalid downstream, but we leave the schema gate to
    ``detect_schema``). The name lookup order is:
    ``model_requirements.business_name`` → ``model.name`` — agent exports
    fill the first, flat hand-edited files only fill the second.
    """
    requirements, inner = _unwrap(model_payload)

    business_name = (
        str(requirements.get("business_name") or "").strip()
        or str(inner.get("name") or "").strip()
    )
    if not business_name:
        return None

    description = (
        str(requirements.get("description") or "").strip()
        or str(inner.get("description") or "").strip()
    )
    industry_alignment = str(inner.get("industry_alignment") or "").strip()
    # Top-level on the envelope (agent v0.6.9+ stamps it); empty on flat files.
    agent_version = str(model_payload.get("agent_version") or "").strip()

    context = {f: str(inner.get(f) or "").strip() for f in _CONTEXT_FIELDS}
    # The agent's inner ``orgnaization_divisions`` is often blank; fall back to
    # what the user typed in ``model_requirements.org_divisions``.
    org_divisions = context["orgnaization_divisions"] or str(
        requirements.get("org_divisions") or ""
    ).strip()

    # Assemble from the *raw* values (not the stringified ``context`` copies)
    # so a dict-shaped ``common_business_jargons`` can render as ``key: value``.
    raw_org_divisions = inner.get("orgnaization_divisions") or requirements.get(
        "org_divisions"
    )
    business_vibes = _assemble_business_vibes(
        description=description,
        core_business_processes=inner.get("core_business_processes"),
        data_domains=inner.get("data_domains"),
        operational_systems_of_records=inner.get("operational_systems_of_records"),
        industry_governing_body=inner.get("industry_governing_body"),
        org_divisions=raw_org_divisions,
        common_business_jargons=inner.get("common_business_jargons"),
    )

    return BusinessDigest(
        business_name=business_name,
        industry_alignment=industry_alignment,
        description=description,
        agent_version=agent_version,
        data_domains=context["data_domains"],
        core_business_processes=context["core_business_processes"],
        orgnaization_divisions=org_divisions,
        common_business_jargons=context["common_business_jargons"],
        operational_systems_of_records=context["operational_systems_of_records"],
        industry_governing_body=context["industry_governing_body"],
        business_vibes=business_vibes,
    )


def diff_business_digest(
    digest: BusinessDigest,
    *,
    current_name: str,
    current_industry_alignment: str,
    digest_industry_id: Optional[str] = None,
    current_industry_id: Optional[str] = None,
) -> list[FieldMismatch]:
    """Return the fields where ``digest`` disagrees with the existing Business.

    Only ``business_name`` and ``industry_alignment`` are checked — those
    are the two identity fields the user needs to confirm before
    importing into a business that may not match the file. Description +
    business-context fields are free-form prose and would generate noisy
    false positives. Names compare case-insensitively. Industries agree
    when the digest's alignment resolves to the business's ``industry_id``
    (``digest_industry_id``, from ``industry_resolve``), else when their
    industry slugs are equal: the import dialog stores the catalog name
    ("Energy - Utilities") of the agent's slug ("energy-utilities").
    """
    mismatches: list[FieldMismatch] = []

    if (digest.business_name or "").strip().casefold() != (current_name or "").strip().casefold():
        mismatches.append(FieldMismatch(
            field="business_name",
            source_value=digest.business_name,
            current_value=current_name,
        ))
    same_industry = (
        digest_industry_id is not None and digest_industry_id == current_industry_id
    ) or industry_slug(digest.industry_alignment) == industry_slug(current_industry_alignment)
    # A silent file is "I don't know", not a disagreement.
    if digest.industry_alignment and not same_industry:
        mismatches.append(FieldMismatch(
            field="industry_alignment",
            source_value=digest.industry_alignment,
            current_value=current_industry_alignment,
        ))

    return mismatches

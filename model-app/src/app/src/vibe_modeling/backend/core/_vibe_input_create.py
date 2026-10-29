"""Shared helper for creating VibeInputs with anchor resolution.

Used by:
- routes/vibe_inputs.py::create_vibe_input (compose-surface feedback)
- routes/assessments.py::addNextVibeToFeedback (assessment result conversion)
- run_changes.py::add_rejected_as_feedback (``origin=change_rejection``)
"""
from __future__ import annotations

from typing import Optional

from sqlmodel import Session

from ..db_models import VibeInput, VibeInputContextLink
from ..models import FeedbackContext, VibeInputOrigin, VibeInputPriority
from .anchor_resolve import resolve_feedback_anchor


def create_vibe_input_with_anchor(
    session: Session,
    business_id: str,
    text: str,
    author: str,
    version_id: str,
    origin: VibeInputOrigin,
    priority: VibeInputPriority,
    confidence_score: Optional[float],
    domain_id: Optional[str] = None,
    product_id: Optional[str] = None,
    attribute_id: Optional[str] = None,
    subdomain_id: Optional[str] = None,
    fk_link_id: Optional[str] = None,
    origin_context: Optional[FeedbackContext] = None,
    needs_link_review: bool = False,
) -> VibeInput:
    """Create a VibeInput + materialize its origin VibeInputContextLink.

    This helper adds and flushes both entities (VibeInput + VibeInputContextLink)
    to the session but does NOT commit. Callers own the commit lifecycle.

    Args:
        session: Database session.
        business_id: Business owning the input.
        text: Feedback text.
        author: User email.
        version_id: Model version being viewed.
        origin: Origin enum (user, agent_next_vibe, change_rejection).
        priority: Priority enum.
        confidence_score: Optional confidence (0.0-1.0).
        domain_id: Explicit domain anchor (compose-surface).
        product_id: Explicit product anchor (compose-surface).
        attribute_id: Explicit attribute anchor (compose-surface).
        subdomain_id: Explicit subdomain anchor (compose-surface).
        fk_link_id: Explicit FK link anchor (compose-surface).
        origin_context: Name-based anchor ("Add Feedback" compose or assessment context).
        needs_link_review: Flag the explicit (or model-wide) anchor for review,
            e.g. when the caller's own name resolution degraded to a parent.

    Returns:
        VibeInput with its origin VibeInputContextLink added to session (not yet committed).
    """
    vi = VibeInput(
        business_id=business_id,
        origin=origin.value,
        author=author,
        text=text.strip(),
        priority=priority.value,
        confidence_score=confidence_score,
    )
    session.add(vi)
    session.flush()

    # Explicit element ids win; else resolve origin_context by name; else model-wide.
    has_explicit = any((domain_id, subdomain_id, product_id, attribute_id, fk_link_id))
    link_kwargs = dict(
        domain_id=domain_id,
        subdomain_id=subdomain_id,
        product_id=product_id,
        attribute_id=attribute_id,
        fk_link_id=fk_link_id,
        needs_link_review=needs_link_review,
    )
    if not has_explicit and origin_context is not None:
        anchor = resolve_feedback_anchor(session, version_id, origin_context)
        link_kwargs = dict(
            domain_id=anchor.domain_id,
            subdomain_id=anchor.subdomain_id,
            product_id=anchor.product_id,
            attribute_id=anchor.attribute_id,
            fk_link_id=anchor.fk_link_id,
            needs_link_review=anchor.needs_link_review,
        )

    link = VibeInputContextLink(
        input_id=vi.id,
        version_id=version_id,
        is_origin=True,
        **link_kwargs,
    )
    session.add(link)
    session.flush()
    return vi

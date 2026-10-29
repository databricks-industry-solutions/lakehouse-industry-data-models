"""Shared value types for the orchestrator service.

Currently exposes the validation :class:`Issue` type (see
``docs/orchestrator-design.md`` §2.4). The ``Dag`` and ``Orchestrator``
types come from a separate Phase 1 slice and will be added there.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Literal, Optional

Severity = Literal["warning", "blocker", "confirm"]


@dataclass(frozen=True, slots=True)
class Issue:
    """A single validation finding raised against a DAG or one of its
    :class:`OperationStep`s.

    ``blocker`` issues reject ``POST /runs`` with HTTP 400. ``warning``
    issues are echoed back to the UI so it can render a "Submit anyway"
    confirmation; the run is still created. ``confirm`` issues carry a
    ``subject`` key the request must list in ``RunIn.confirmed_issues``.
    See §2.4 of the design doc for the full validation flow.
    """

    field_path: str
    """Dotted path to the offending field, e.g. ``"deployment_catalog"``
    or ``"params.schema_prefix"``. ``""`` when the issue is not bound to
    a specific field."""

    step_index: int
    """Index of the ``OperationStep`` that raised this issue. ``-1`` for
    DAG-level findings that span multiple steps."""

    message: str
    """Human-readable description rendered inline in the form."""

    severity: Severity
    """``"warning"``, ``"blocker"`` or ``"confirm"``."""

    subject: Optional[str] = None
    """Set on ``confirm`` issues only: the key bound to what the
    confirmation is about (``install_over_newer:<head id>``,
    ``install_replaces_in_catalog:<occupying version id>``)."""

    versions: tuple[int, ...] = ()
    """The version numbers the issue names, when it names some
    (``install_over_newer``: the versions the install replaces;
    ``vibe_scope_base``: the versions to delete first). The UI reads them
    instead of parsing ``message``."""

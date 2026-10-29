"""Operation primitive contract for the orchestrator.

See `docs/orchestrator-design.md` §2 for the full design rationale.

An ``Operation`` is the smallest unit the orchestrator can dispatch. Each
implementation owns a single Databricks job launch (or a single in-process
side effect) and exposes a deterministic rollback. ``Operation`` instances
are singletons registered at startup; the runtime state of a single use of
an operation lives in ``RunOperation`` rows persisted by the orchestrator.

The dataclasses below are the value objects exchanged between the
orchestrator and operation implementations:

* ``OperationContext`` — read-only inputs an operation receives at dispatch
  time.
* ``OperationDispatchHandle`` — opaque cookie returned by ``dispatch()`` so
  ``observe()`` can find the in-flight work again across poll cycles or
  process restarts.
* ``OperationObservation`` — snapshot of progress the orchestrator polls.
* ``OperationResult`` — terminal payload describing what the operation
  produced and how to roll it back.
"""

from __future__ import annotations

from abc import ABC, abstractmethod
from dataclasses import dataclass, field
from typing import Any, Optional

from pydantic import BaseModel


@dataclass(frozen=True, slots=True)
class OperationContext:
    """Read-only inputs an operation receives at dispatch time."""

    run_id: str
    """The Run that owns this operation invocation."""

    operation_id: str
    """PK of the RunOperation row (one row per OperationStep in the DAG)."""

    business_id: str
    """Source-of-truth for org config and naming conventions."""

    parent_version_id: Optional[str]
    """The ModelVersion this op operates on, if any."""

    params: dict
    """Operation-specific parameters; type-validated by the impl's
    ``params_model`` before this context is constructed."""

    inherited_params: dict
    """Carry-keys propagated from the Run intent
    (e.g. ``cataloging_style``)."""


@dataclass(frozen=True, slots=True)
class OperationDispatchHandle:
    """Opaque cookie returned by :meth:`Operation.dispatch`, passed back to
    :meth:`Operation.observe`.

    The orchestrator persists the handle's data on the ``RunOperation`` row
    so it can resume polling after a process restart. Operations should keep
    the handle minimal — it is not a place to cache large derived state.
    """

    databricks_run_id: Optional[int]
    """Databricks Jobs run id, if the op launched a job."""

    vibe_session_id: Optional[str]
    """Vibe agent session id, if the op started an agent session."""

    extra: dict = field(default_factory=dict)
    """Primitive-specific state the op needs to find its work again."""

    dispatched_widgets: dict = field(default_factory=dict)
    """The exact widget map handed to ``jobs.run_now()`` (or the
    equivalent launch call), if the op launched a job. This is a
    write-once audit value distinct from ``extra``. ``extra`` is
    carry-forward state ``observe()`` needs to rebuild its context
    (op-specific field names, e.g. ``deployment_catalog``); by contrast
    ``dispatched_widgets`` is the literal wire payload (agent widget
    names, e.g. ``data_model_scopes``) with no re-parse contract. The
    orchestrator persists it verbatim on ``RunOperation.
    dispatched_widgets_json`` at dispatch time and never overwrites it
    again. It is the durable answer to "what did we actually send the
    agent for this op." Leave empty for ops that don't launch a job, or
    on the idempotent-resume path where the original widget map isn't
    reconstructable."""


# ``rollback_state`` key for the warnings a succeeded op reports: texts, or
# ``{"message", "sql"}`` for a warning with a statement an admin can run.
RUN_WARNINGS_KEY = "run_warnings"


@dataclass(frozen=True, slots=True)
class OperationResult:
    """What an operation tells the orchestrator on terminal completion."""

    succeeded: bool
    """``True`` iff the op finished cleanly."""

    output_version_id: Optional[str]
    """ID of the new ModelVersion the op produced, if any. Operations with
    ``produces_version=False`` MUST set this to ``None``."""

    output_artifacts: list[dict]
    """Rows to insert into ``RunArtifact``
    (``{"artifact_type": ..., "file_path": ...}``)."""

    rollback_state: dict
    """Opaque blob the op's :meth:`Operation.rollback` can use to undo this
    invocation. Persisted as JSON on the ``RunOperation`` row. A succeeded
    op that finished with something the user should know sets
    :data:`RUN_WARNINGS_KEY` to a list of texts; the run page shows them
    (``RunOut.warnings``)."""

    error: Optional[str]
    """Populated when ``succeeded=False``; ``None`` otherwise."""


@dataclass(frozen=True, slots=True)
class OperationObservation:
    """Snapshot of an in-flight operation's state.

    ``observe()`` MUST never block. Each call returns the current snapshot;
    the orchestrator decides when to call again.
    """

    progress_percent: int
    """0..100. The orchestrator does not interpolate between observations."""

    progress_message: str
    """Short human-readable status, surfaced on the run detail UI."""

    is_terminal: bool
    """``True`` iff the operation has reached a terminal state. When
    ``True``, ``terminal_result`` MUST be set."""

    terminal_result: Optional[OperationResult]
    """Set iff ``is_terminal=True``; ``None`` otherwise."""


class Operation(ABC):
    """Primitive contract.

    Implementations live under ``services/operations/{name}.py`` (Phase 2)
    and are registered at startup via :func:`._registry.register`.

    Subclasses MUST set the four required class attributes below and
    implement :meth:`dispatch`, :meth:`observe`, and :meth:`rollback`;
    ``rollback_is_noop`` defaults to False.
    """

    name: str
    """Stable string id, e.g. ``"generate_ecm"``, ``"install"``,
    ``"shrink_to_mvm"``. Must be unique across the registry."""

    params_model: type[BaseModel]
    """Pydantic schema for ``OperationStep.params``. Field-level and
    within-step cross-field rules live here. Used by both the live
    form-feedback validator and the orchestrator's revalidation gates."""

    is_idempotent: bool
    """If ``True``, the orchestrator may retry the op on transient errors."""

    produces_version: bool
    """If ``True``, the orchestrator expects ``output_version_id`` to be
    populated on success."""

    rollback_is_noop: bool = False
    """``True`` when :meth:`rollback` undoes nothing (the op's effect stands,
    e.g. an uninstall): a rolled-back run then keeps the step
    ``succeeded``, because ``rolled_back`` would be untrue."""

    @abstractmethod
    def dispatch(
        self,
        ctx: OperationContext,
        ws: Any,
        session: Any,
    ) -> OperationDispatchHandle:
        """Launch the underlying job/work; return a handle for
        :meth:`observe`.

        MUST be idempotent against re-call with the same
        ``(ctx.run_id, ctx.operation_id)`` — the orchestrator may resume
        from a crash and call ``dispatch()`` for an op that already started.
        """

    @abstractmethod
    def observe(
        self,
        handle: OperationDispatchHandle,
        ctx: OperationContext,
        ws: Any,
        session: Any,
    ) -> OperationObservation:
        """Read current state. Called by the orchestrator's poll loop.

        Returns a snapshot; never blocks.
        """

    @abstractmethod
    def rollback(
        self,
        ctx: OperationContext,
        rollback_state: dict,
        ws: Any,
        session: Any,
    ) -> None:
        """Reverse this operation's side effects. Raises on failure.

        Called in reverse-DAG order on cancel-with-rollback or on a failed
        DAG that has prior operations to undo. MUST be idempotent —
        replaying the same rollback against an already-rolled-back op is a
        no-op, not an error.
        """

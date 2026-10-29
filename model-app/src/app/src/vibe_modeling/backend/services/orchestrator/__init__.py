"""Orchestrator service: DAG construction, validation, dispatch, polling.

Phase 3 introduces the runtime :class:`Orchestrator` that walks a DAG
of :class:`OperationStep`s through their primitive sequence (see
``docs/orchestrator-design.md`` §4 + §6).
"""

from ._runner import (
    CANCEL_REFUSED_PHASE_SUCCEEDED,
    AdvanceOutcome,
    CancelResult,
    Orchestrator,
)
from ._types import Issue, Severity
from .dag import Dag, OperationStep
from .dag_factories import dag_for_new_base_model, dag_for_vibe_new_ecm_mvm
from .validate import ValidationResult, validate_dag, validate_dag_request

__all__ = [
    "CANCEL_REFUSED_PHASE_SUCCEEDED",
    "AdvanceOutcome",
    "CancelResult",
    "Dag",
    "Issue",
    "OperationStep",
    "Orchestrator",
    "Severity",
    "ValidationResult",
    "dag_for_new_base_model",
    "dag_for_vibe_new_ecm_mvm",
    "validate_dag",
    "validate_dag_request",
]

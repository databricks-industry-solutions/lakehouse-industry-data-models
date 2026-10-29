"""DAG factories — one function per :class:`Intent` that maps a
``POST /runs`` request into a :class:`Dag` ready for the orchestrator.

Per ``docs/orchestrator-design.md`` §3, factories live alongside the
wirers. Phase 4 splits them across three worktrees by intent group;
each group's module re-exports its factories from here.

Factories are pure functions: they read a request + the resolved
business / context / agent-config and return a ``Dag``. They MUST NOT
touch the DB or the workspace client — that belongs in the route
handler. Validation runs separately via
:func:`services.orchestrator.validate.validate_dag` after the factory
returns.
"""

from ._recovery import dag_for_import_from_volume
from ._simple import (
    dag_for_install,
    dag_for_uninstall,
    dag_for_vibe_iterate,
)
from ._unified import dag_for_new_base_model
from ._vibe_new_ecm_mvm import dag_for_vibe_new_ecm_mvm

__all__ = [
    "dag_for_import_from_volume",
    "dag_for_install",
    "dag_for_new_base_model",
    "dag_for_uninstall",
    "dag_for_vibe_iterate",
    "dag_for_vibe_new_ecm_mvm",
]

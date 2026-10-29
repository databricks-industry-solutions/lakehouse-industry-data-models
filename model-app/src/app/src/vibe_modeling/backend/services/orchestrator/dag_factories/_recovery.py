"""DAG factories for the recovery-flavoured intents.

Two shapes land here per ``docs/orchestrator-design.md`` §3 + §8:

* :func:`uninstall_then_install` - the 2-op DAG that installs a version into
  a catalog another version occupies (``dag_for_install``).
* :func:`uninstalls_first` - the same uninstalls in front of any DAG, for
  versions of another business a run replaces (a source industry).
* ``import-from-volume`` - 1-op DAG. The ``import_from_volume`` primitive
  is synthetic (no agent job) and does the full read → ModelVersion
  insert → Lakebase sync inline; the factory just hands it the volume
  path.

Factories are pure: they take a small request payload + the resolved
:class:`Business` + a context carrying agent-derived values, and return
a frozen :class:`Dag`. The wirer (route handler) owns DB writes and
calls :func:`validate_dag` before passing the DAG to
:meth:`Orchestrator.start`.
"""

from __future__ import annotations

from collections.abc import Iterable
from dataclasses import dataclass, replace
from typing import Optional

from ..dag import Dag, OperationStep


@dataclass(frozen=True, slots=True)
class ImportFromVolumeRequest:
    """Inputs the import-from-volume factory needs.

    The primitive resolves ``business_name`` / ``deployment_catalog``
    from :class:`OperationContext` when omitted (spec §2 — the context
    is the source of truth for org config). The factory only needs the
    volume path.
    """

    volume_path: str
    """Absolute UC Volume path ending in ``model.json``. Validated by
    the primitive's ``params_model``."""

    deployment_catalog: str = ""
    """Optional override; primitive resolves from inherited_params /
    business when blank."""

    business_name: str = ""
    """Optional override; primitive resolves from
    :attr:`OperationContext.business_id` when blank."""

    scope: Optional[str] = None
    """The admin's ECM / MVM choice; the primitive settles the scope with
    ``import_model.import_scope``."""


def uninstall_then_install(intent: str, uninstall: dict, install: dict) -> Dag:
    """The 2-op DAG that uninstalls one version, then installs another.

    Step 0 strips the UC schemas the old install laid down, so step 1 finds
    none of its schemas and installs the whole file fresh (in One Catalog
    mode ECM and MVM share a catalog and only the schema prefix tells them
    apart). Both ops act on versions that already exist, so the DAG carries
    no ``needs_version_from``; the orchestrator runs the install only after
    the uninstall succeeds. If the install fails, the orchestrator rolls
    back only the steps that succeeded (the uninstall's rollback is a no-op)
    and never the failed install: the old version stays uninstalled, the new
    one is not deployed, the head is unchanged, and any schemas the agent
    created before it failed stay in the catalog (only a cancel mid-step
    reaches ``Install.rollback``).
    """
    return Dag(
        intent=intent,
        steps=(
            OperationStep(name="uninstall", params=uninstall),
            OperationStep(name="install", params=install, needs_version_from=None),
        ),
    )


def uninstalls_first(dag: Dag, uninstalls: Iterable[dict]) -> Dag:
    """``dag`` with an ``uninstall`` step per ``uninstalls`` params in front:
    the :func:`uninstall_then_install` shape for versions of another
    business the run replaces (a source industry,
    ``orchestrator.source_industry``). Each uninstall names its version
    (``version_id``), so its row acts on that one; the later steps are
    unchanged. A failure of a later step leaves those versions
    uninstalled."""
    steps = tuple(OperationStep(name="uninstall", params=params) for params in uninstalls)
    return replace(dag, steps=steps + dag.steps) if steps else dag


def dag_for_import_from_volume(req: ImportFromVolumeRequest) -> Dag:
    """Build the 1-op import-from-volume DAG.

    The ``import_from_volume`` primitive is synthetic and runs entirely
    inside ``dispatch`` — it reads the model.json off the Volume,
    inserts a fresh :class:`ModelVersion`, and syncs Lakebase. The
    factory hands it the volume path; the primitive's ``params_model``
    enforces the ``/Volumes/`` path-shape gate (spec §2.4 — field-level
    rules live with the primitive).
    """
    params: dict = {
        "volume_path": req.volume_path,
    }
    # Optional fields — only populate when set so the primitive's
    # context-resolution path stays the default.
    if req.deployment_catalog:
        params["deployment_catalog"] = req.deployment_catalog
    if req.business_name:
        params["business_name"] = req.business_name
    if req.scope:
        params["scope"] = req.scope

    return Dag(
        intent="import-from-volume",
        steps=(
            OperationStep(
                name="import_from_volume",
                params=params,
            ),
        ),
    )

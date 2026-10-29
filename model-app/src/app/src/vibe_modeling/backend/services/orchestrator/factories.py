"""DAG factories — public surface (per spec §3 example).

This module is the canonical import path for DAG factories called by
route handlers. Each factory takes a request payload + the resolved
:class:`Business` + a session and returns a frozen :class:`Dag`.

The intent-specific implementations live under ``dag_factories/`` (one
sub-module per intent group) so the file count stays manageable as more
factories land in later phases. ``factories`` re-exports a small public
surface that:

* Accepts the spec-canonical ``(req, business, session)`` signature.
* Resolves the routing-level gates that belong to "the wirer"
  (path-traversal rejection → 400).
* Builds the typed dataclass request expected by the inner factory and
  delegates to it.

Routes that already build the typed request inline (legacy admin
endpoints in :mod:`backend.routes.versions`) keep importing the inner
factory from ``dag_factories._recovery`` — both paths produce the same
:class:`Dag`. Tests and any new route code import from this module.

The Phase 4 wirer test agents (skeptical-tester pass) and any future
consumers reach for the public path::

    from vibe_modeling.backend.services.orchestrator import factories
    factories.dag_for_new_base_model(...)

The actual implementations live under ``dag_factories/_unified.py`` (and
sibling modules for the recovery / simple wirers, once they land). This
module exists purely as a stable, documented public surface so adding
a new factory does not require callers to know which private module it
lives in.
"""

from __future__ import annotations

from typing import Any

from fastapi import HTTPException

from ...core._names import agent_business_segment, normalize_scope
from ...db_models import Business
from .dag import Dag
from .dag_factories import dag_for_new_base_model
from .dag_factories._recovery import (
    ImportFromVolumeRequest,
    dag_for_import_from_volume as _dag_for_import_from_volume_impl,
)


__all__ = [
    "dag_for_import_from_volume",
    "dag_for_new_base_model",
]


def dag_for_import_from_volume(
    req: Any, business: Business, session: Any
) -> Dag:
    """Build the 1-op import-from-volume DAG.

    ``req`` carries ``volume_path`` (required) and optionally
    ``deployment_catalog`` and ``scope`` (the ECM / MVM choice) overrides. Path-traversal / non-Volumes-root
    paths reject with 400 here so the bad path never reaches
    ``Orchestrator.start`` — the primitive's ``params_model`` enforces
    the same rule, but surfacing it as a routing-level 400 (rather than
    a Pydantic 422 mid-orchestrator-start) matches spec §2.4's
    "blocker" semantics.
    """
    volume_path = getattr(req, "volume_path", "") or ""
    if not volume_path:
        raise HTTPException(
            status_code=400,
            detail="volume_path is required for import-from-volume",
        )
    if not volume_path.startswith("/Volumes/"):
        raise HTTPException(
            status_code=400,
            detail=(
                "Invalid volume_path: must be an absolute UC Volume path "
                "(starts with '/Volumes/'). Path rejected as a blocker."
            ),
        )
    segments = [s for s in volume_path.split("/") if s]
    if any(s == ".." for s in segments):
        raise HTTPException(
            status_code=400,
            detail=(
                "Invalid volume_path: path-traversal '..' segments are "
                "rejected as a blocker (spec §2.4)."
            ),
        )

    deployment_catalog = getattr(req, "deployment_catalog", "") or ""
    name_slug = agent_business_segment(business.name)
    scope = normalize_scope(getattr(req, "scope", "") or "")

    inner = ImportFromVolumeRequest(
        volume_path=volume_path,
        deployment_catalog=deployment_catalog,
        business_name=name_slug,
        scope=scope if scope in ("ecm", "mvm") else None,
    )
    return _dag_for_import_from_volume_impl(inner)

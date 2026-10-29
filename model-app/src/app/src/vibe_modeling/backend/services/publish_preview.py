"""Prepublish diff-preview service (Story 3, 0.6.4).

Before opening a publish PR, diff the ``model.json`` that WOULD be published
against the repo's LATEST same-scope version, with a tiered baseline fallback
plus manual-pick / skip. ``model.json`` ONLY — companion artifacts are NEVER
fetched. Preview failure must never block publish, so this is **degrade-open**
throughout: only the two existence checks (business + model version) raise; a
missing / unfetchable / unparseable baseline degrades to ``manual_needed``.

Repo reads use the installation's configured source read-auth (GitHub App /
token / anonymous) via :func:`build_source_connector`, the same resolver the
browse and download paths use, so a private industry repo previews like it
browses. Any referenced secret is read by the app service principal ``ws``; no
UC OAuth connection and no ``UserClient``, so the preview stays smoke-testable
and a missing baseline is normal, never a 500.

The service returns a plain :class:`PublishPreviewResult` dataclass; the route
maps it to the co-located ``PublishPreviewOut`` (and ``_to_diff_out``). Keeping
the Pydantic Out models in the route avoids a route -> service -> route import
cycle (``services/`` never imports ``routes/``).
"""

from __future__ import annotations

import json
import logging
from dataclasses import dataclass, field
from typing import Optional

from sqlmodel import Session

from ..db_models import AgentConfig, Business, ModelVersion
from ..model_diff import compute_model_diff
from ..model_export import export_model_json, resolve_bundle_root
from ..sources.base import SourceError, SourceModelRef
from ..sources.github import (
    _infer_scope,
    _infer_version,
    build_source_connector,
    find_latest_same_scope_version,
)

logger = logging.getLogger(__name__)


@dataclass
class BaselineInfo:
    model_id: str
    industry_id: str
    scope: Optional[str] = None
    version: Optional[str] = None


@dataclass
class PublishPreviewResult:
    """Field-for-field mirror of ``PublishPreviewOut`` (sans the flattened
    ``DiffOut`` — the raw ``compute_model_diff`` dict is carried in ``diff`` and
    the route flattens it via ``_to_diff_out``)."""

    baseline: Optional[BaselineInfo]
    tier: str  # "same_scope_latest" | "fallback_unverified" | "none" | "manual"
    scope_mismatch: bool = False
    manual_needed: bool = False
    candidates: list[SourceModelRef] = field(default_factory=list)
    diff: Optional[dict] = None  # raw compute_model_diff dict; None == manual_needed


def _industry_folder(business: Business | None, mv: ModelVersion, target_path: str | None) -> str:
    """The repo INDUSTRY folder for enumeration (e.g. ``capital_markets``),
    NOT the full bundle root (``capital_markets/v3/ecm``).

    Derived from the D-049 resolver so override / round-trip / name-fallback
    precedence matches publish exactly (do NOT re-read ``source_repo_path``).
    The canonical root is nested ``<industry>/v{N}/<scope>`` (agent 4.9.8+), so
    the version folder is the trailing ``v{N}/<scope>`` pair and the industry is
    its parent (``parts[-3]``). A legacy flat override
    (``a/b/capital_markets/ecm_v3``) keeps its single-segment version folder, so
    the industry is ``parts[-2]``. A raw 1-segment override (no version folder)
    falls back to ``parts[-1]`` so it never IndexErrors.
    """
    root = resolve_bundle_root(
        override=target_path, business=business, scope=mv.scope or "", version=mv.version
    )
    parts = root.strip("/").split("/")
    # Nested version folder = trailing "v{N}/{scope}" pair -> industry is parts[-3].
    if (
        len(parts) >= 3
        and parts[-1] in ("ecm", "mvm")
        and parts[-2].startswith("v")
        and parts[-2][1:].isdigit()
    ):
        return parts[-3]
    # Flat version folder = single trailing segment -> industry is parts[-2].
    return parts[-2] if len(parts) >= 2 else parts[-1]


def compute_publish_preview(
    cfg: AgentConfig,
    *,
    session: Session,
    business_id: str,
    version_id: str,
    target_path: str | None = None,
    baseline_model_id: str | None = None,
    app_config,
    ws,
    connector=None,
) -> PublishPreviewResult:
    """``app_config`` and ``ws`` (the app-SP client) are required: the resolver
    reads the read-auth secret with ``ws``. A ``None`` ws is only valid with an
    injected ``connector``; reaching the resolver with it would cache a negative
    secret read process-wide and break browse and download for its TTL."""
    from fastapi import HTTPException

    if connector is None and ws is None:
        raise ValueError("compute_publish_preview needs the app-SP ws unless a connector is injected")

    # 1. 404-guard (mirrors github_publish): the ONLY hard failures.
    mv = session.get(ModelVersion, version_id)
    if mv is None or mv.business_id != business_id:
        raise HTTPException(status_code=404, detail="ModelVersion not found")
    business = session.get(Business, business_id)
    if business is None:
        raise HTTPException(status_code=404, detail="Business not found")

    # 2. Industry folder for enumeration (D-049 precedence, version segment stripped).
    industry_id = _industry_folder(business, mv, target_path)

    # 3. Connector with the configured read-auth (test seam: caller may inject one).
    connector = connector or build_source_connector(
        cfg,
        app_config,
        ws,
        repo_owner=cfg.github_repo_owner,
        repo_name=cfg.github_repo_name,
    )

    # 4. Baseline resolution.
    if baseline_model_id:
        # Manual pick -> bypass the tiered resolver; tier="manual".
        scope = version = None
        try:
            for m in connector.list_models(industry_id):
                if m.id == baseline_model_id:
                    scope, version = m.scope, m.version
                    break
        except SourceError:
            pass  # listing failed; proceed with the model_id only.
        baseline = BaselineInfo(
            model_id=baseline_model_id, industry_id=industry_id, scope=scope, version=version
        )
        return _diff_against(
            session, version_id, connector, industry_id, baseline,
            tier="manual", scope_mismatch=False,
        )

    try:
        resolution = find_latest_same_scope_version(connector, industry_id, mv.scope)
    except SourceError:
        # Listing failed (unknown industry / transport) -> Tier 3, manual.
        return PublishPreviewResult(
            baseline=None, tier="none", manual_needed=True, candidates=[]
        )

    # 5. No baseline -> manual pick from candidates (may be empty).
    if resolution.model_id is None:
        return PublishPreviewResult(
            baseline=None, tier="none", manual_needed=True,
            candidates=list(resolution.candidates),
        )

    baseline = BaselineInfo(
        model_id=resolution.model_id, industry_id=industry_id,
        scope=_infer_scope(resolution.model_id),
        version=_infer_version(resolution.model_id),
    )
    return _diff_against(
        session, version_id, connector, industry_id, baseline,
        tier=resolution.tier, scope_mismatch=resolution.scope_mismatch,
    )


def _diff_against(
    session, version_id, connector, industry_id, baseline, *, tier, scope_mismatch
) -> PublishPreviewResult:
    """Fetch the baseline model.json ONLY, unwrap the envelope, diff against the
    exported current model. Any list/fetch/JSON failure, or a baseline that is
    not a JSON object (bare or inside the envelope), degrades to manual."""
    try:
        raw = connector.fetch_model_json(industry_id, baseline.model_id)
        baseline_model = json.loads(raw)
    except (SourceError, ValueError) as exc:
        logger.info("Publish preview baseline fetch/parse failed: %s", exc)
        return _manual(connector, industry_id)

    if isinstance(baseline_model, dict):
        baseline_model = baseline_model.get("model", baseline_model)
    if not isinstance(baseline_model, dict):
        logger.info("Publish preview baseline is not a JSON object model; degrading to manual")
        return _manual(connector, industry_id)

    current = export_model_json(session, version_id)["model"]
    diff = compute_model_diff(baseline_model, current)
    return PublishPreviewResult(
        baseline=baseline, tier=tier, scope_mismatch=scope_mismatch,
        manual_needed=False, candidates=[], diff=diff,
    )


def _manual(connector, industry_id) -> PublishPreviewResult:
    return PublishPreviewResult(
        baseline=None, tier="none", manual_needed=True,
        candidates=_safe_candidates(connector, industry_id),
    )


def _safe_candidates(connector, industry_id) -> list[SourceModelRef]:
    try:
        return list(connector.list_models(industry_id))
    except SourceError:
        return []

"""Industry kickstart — clone a published industry version into a fresh business.

Story-8 (ADR D-050). "Kickstarting" takes a ``kind='industry'`` meta-business
at a specific published version and stamps out a brand-new ``kind='business'``
row whose model structure + companion artifacts are a faithful copy of that
industry version. The new business records its provenance
(``source_industry_id`` / ``source_version``) so the UI can show "kickstarted
from <industry> v<N>".

The synchronous, in-request part is deliberately tiny: validate the source,
create the ``Business`` row and a ``status="running"`` audit ``Run``, commit,
return. Everything else - the model-tree copy, the VibeInput copy, the
``_metamodel`` seed, and the Volume artifact copy - runs in the background
(three phases, driving the audit Run's progress):

- **Phase 0** (:func:`_run_phase0`): for each source ``ModelVersion`` at the
  requested version int (an industry version may comprise both an ECM and an
  MVM scope), create a matching new ``ModelVersion`` and copy the model
  **structure** via :func:`copy_model_tree` (domains/products/attributes/
  fk_links, fresh ids); when ``copy_inputs`` is set, also copy the industry's
  ``origin=user`` ``VibeInput`` (feedback) rows, re-anchoring each context
  link to the cloned version's element ids by natural-key (name)
  re-resolution. All of this lands in ONE transaction, so a failure partway
  leaves no orphan ``ModelVersion`` / half-copied tree - only the
  ``Business`` and the audit ``Run`` (already committed synchronously)
  survive a phase-0 failure. On success, the audit Run's ``version_id`` is
  set to the first cloned version. The ``agent_next_vibe`` backlog is
  deliberately NOT copied here - see Phase 2.
- **Phase 1** (:func:`_run_kickstart_background`): seed
  ``<deployment_catalog>._metamodel.*`` for each cloned version via
  :func:`import_metamodel_writer.seed_metamodel_one` (which creates the
  agent's registry tables first when they are missing) so the new business
  is directly iterable (the agent reads its parent model only from
  ``_metamodel``). A failed seed does not stop phase 2; the run then ends
  ``failed`` with the seed failure in its ``error_message``.
- **Phase 2**: copy the source version's Volume artifacts (download → upload
  into the new version's Volume dir under the deployment catalog) using
  :func:`artifact_indexer.walk_volume_dir`, then index them as ``RunArtifact``
  rows via :func:`artifact_indexer.index_artifacts_at_path`. When
  ``copy_inputs`` is set, also materializes the ``agent_next_vibe`` backlog
  for the NEW version from its own (now-copied) next-vibes artifact via
  :func:`model_sync.ingest_next_vibes` - the single canonical producer of
  those rows, keyed off the NEW version's id from the start so a later
  resync's re-parse of the same artifact is a no-op (see
  :func:`_copy_vibe_inputs`'s docstring).

Schema prefix: an industry downloaded with 0.9.0 is already prefixed
(``ecm_crop``, metric views ``ecm_<view>``; its version records the markers,
``ModelVersion.import_schema_prefix_added``), so its copy is verbatim and
carries the same markers. An industry downloaded before 0.9.0 (no markers) is
read before phase 0 and gets the import rule
(``scope_prefix.import_schema_prefix``): phase 0 rewrites the cloned
``Domain.database_name`` rows (so the phase 1 seed and the app's schema names
agree) and phase 2 rewrites the copied model.json
(``scope_prefix.apply_import_prefix``: schemas, metric view sources and
names), and the version records what was added. An industry file that is
there but cannot be read fails the kickstart before phase 0
(:class:`KickstartModelUnreadable`).

Structure is the contract a kickstart preserves (domains / products /
attributes / FK links), copied directly via :func:`copy_model_tree`.
Run-provenance metadata is left at defaults on the
new version because it describes the *source* generation, not the copy:
``confidence_score`` (source self-assessment), ``vibe_instructions`` (source
run-time prompt), ``sync_state`` / ``sync_error_text`` (start ``ok`` - we sync
it ourselves). The model-level description lives on the ``Business`` row: an
explicit ``new_description`` wins, otherwise it falls back to the source
industry's description (the agent hard-requires a non-empty description for
model-producing runs, so kickstart never leaves it empty). If both are blank
(an industry seeded from a description-less ``model.json``), the request is
rejected with a 422 - the same contract ``BusinessIn.description`` enforces
on every other Business-write surface - instead of letting the business get
created and only failing a minute into the next run's fail-fast preflight.
"""

from __future__ import annotations

import json
import logging
import time
from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Any, Callable, Optional

from sqlalchemy import insert as sa_insert
from sqlmodel import Session, select

from .._query_helpers import BusinessNameConflict, ensure_business_name_available
from ..core import resolve_metamodel_catalog
from ..core._intents import INTENT_KICKSTART_FROM_INDUSTRY
from ..core._paths import version_dir_candidates, version_dir_in_volume
from ..core._warehouse import get_warehouse_id
from ..core.anchor_resolve import (
    AnchorMaps,
    _AnchorFKs,
    capture_named_anchor,
    prefetch_anchor_maps,
    resolve_named_anchor,
)
from ..error_sanitization import recorded_error_text, sanitize_error_message
from ..db_models import (
    Business,
    ModelVersion,
    Run,
    VibeInput,
    VibeInputContextLink,
)
from ..models import VibeInputOrigin, validate_business_description
from ..model_export import export_model_json
from ..model_sync import ingest_next_vibes
from ._bulk_model_io import _row_values, copy_model_tree
from .artifact_indexer import index_artifacts_at_path, walk_volume_dir
from .import_metamodel_writer import seed_metamodel_one
from .metamodel_registry import setup_error_message
from .metamodel_setup import MetamodelSetupError, ensure_metamodel_schema_and_volume
from .schema_names import scope_schema_prefix
from .scope_prefix import apply_import_prefix, apply_import_prefix_to_rows, import_schema_prefix
from .version_files import model_json_candidates, read_conventions
from .volume_copy import copy_volume_folder

logger = logging.getLogger(__name__)


class KickstartError(ValueError):
    """Raised when the kickstart request is invalid (bad source / version)."""

    @property
    def detail(self) -> str:
        """The message as raised, for the route's 400: an ``AppMessage`` (the
        setup's GRANT text) stays one, so the error handler keeps its length."""
        return self.args[0] if self.args and isinstance(self.args[0], str) else str(self)


class KickstartSourceNotFound(KickstartError):
    """Raised when the source industry / requested version does not exist.

    The endpoint maps this to 404 (the addressed source/version is absent),
    distinct from a malformed request (400) or a name collision (409).
    """


class KickstartNameConflict(KickstartError):
    """Raised when ``new_name`` collides with an existing business name.

    ``Business.name`` is unique at the DB layer; pre-checking here turns the
    would-be ``IntegrityError`` (500) into a clean 409 at the endpoint.
    """


class KickstartDescriptionRequired(KickstartError):
    """Raised when neither ``new_description`` nor the source industry's own
    description can seed the new business.

    Same contract as creating a Business directly (``BusinessIn.description``,
    enforced by :func:`validate_business_description`): a business is never
    created with an empty description. The industry-description fallback
    (below) usually makes this a non-issue, but an industry seeded from a
    ``model.json`` that itself lacked a description can be blank too - this
    catches that case at request time instead of a minute into the next run's
    fail-fast preflight.
    """


def kickstart_from_industry(
    session: Session,
    ws,
    *,
    source_industry_id: str,
    source_version: int,
    new_name: str,
    new_description: str = "",
    config=None,
    copy_inputs: bool = True,
    schedule_copy: Optional[Callable[["_KickstartCopyPlan"], None]] = None,
) -> Business:
    """Clone an industry version into a fresh ``kind='business'`` business.

    Only the ``Business`` row and a ``status="running"`` audit ``Run`` are
    created synchronously - the response time is independent of model size.
    The model-tree copy, VibeInput copy, ``_metamodel`` seed and Volume
    artifact copy all run in the background (see the module docstring's
    phase 0/1/2 breakdown), driving the audit Run's progress to ``completed``.
    The new business is not usable/iterable until phase 0 lands, and not
    directly iterable by the agent until phase 1 lands; the iterate preflight
    returns an actionable 400 for a business kickstarted but not yet seeded.

    Args:
        session: SQLModel session (caller owns the transaction boundary).
        ws: Databricks ``WorkspaceClient`` for Volume artifact copy. May be
            ``None`` — structure still copies; the artifact-copy step is a
            best-effort no-op without a client.
        source_industry_id: The ``kind='industry'`` business to clone from.
        source_version: The industry's per-scope version integer to clone.
        new_name: Name for the new business (also seeds its description-level
            ``name``; must be unique).
        new_description: Optional short summary for the new business. When
            blank, falls back to the source industry's description so the
            new business is never created with an empty one.
        config: AppConfig used to resolve the deployment catalog (AgentConfig
            singleton, else the AppConfig env default). ``None`` in direct
            unit calls that seed AgentConfig themselves.
        copy_inputs: When True (default), copy the industry's feedback
            (``origin=user`` VibeInputs) into the new business, re-anchored
            to the cloned version's elements, AND materialize the
            ``agent_next_vibe`` backlog for the new version from its own
            copied next-vibes artifact.
        schedule_copy: Optional callback that hands the :class:`_KickstartCopyPlan`
            to a background runner (the route passes one so the request returns
            immediately). When ``None`` (direct/unit callers) the artifact copy
            runs INLINE on ``session`` before returning.

    Returns:
        The newly-created ``Business`` (flushed, with ``id`` assigned).

    Raises:
        KickstartError: source is missing / not an industry / version absent.
        KickstartDescriptionRequired: neither ``new_description`` nor the
            source industry's own description is non-blank.
        KickstartError: the deployment catalog's ``_metamodel`` schema or
            ``vol_root`` volume does not exist and cannot be created (the
            message says which privilege is missing).
    """
    industry = session.get(Business, source_industry_id)
    if industry is None:
        raise KickstartSourceNotFound(
            f"source industry {source_industry_id!r} not found"
        )
    if industry.kind != "industry":
        raise KickstartError(
            f"source {source_industry_id!r} is kind={industry.kind!r}, "
            f"not 'industry' — kickstart requires an industry source"
        )

    source_versions = session.exec(
        select(ModelVersion)
        .where(ModelVersion.business_id == source_industry_id)
        .where(ModelVersion.version == source_version)
        .order_by(ModelVersion.scope)
    ).all()
    if not source_versions:
        raise KickstartSourceNotFound(
            f"industry {source_industry_id!r} has no version "
            f"{source_version} to kickstart from"
        )

    try:
        ensure_business_name_available(session, new_name)
    except BusinessNameConflict as exc:
        raise KickstartNameConflict(str(exc)) from exc

    # The _metamodel Volume + Delta live under the DEPLOYMENT catalog, never
    # the per-model install catalog (empty for a draft industry). Resolve it
    # once so both artifact copy and the metamodel seed agree.
    deployment_catalog = resolve_metamodel_catalog(session, config)

    # The agent hard-requires a non-empty business description for
    # model-producing runs (industry inference + complexity-tier sizing).
    # An explicit ``new_description`` wins (the user's own words); otherwise
    # fall back to the source industry's description so a kickstarted
    # business is never born with an empty one (download already does this
    # via ``inner.get("description")``; kickstart just needs to propagate
    # it one hop further).
    resolved_description = new_description.strip() or industry.description
    try:
        validate_business_description(resolved_description)
    except ValueError as exc:
        raise KickstartDescriptionRequired(str(exc)) from exc

    # Every check that can refuse the request is behind us: only now touch
    # Unity Catalog. A fresh catalog has no ``_metamodel`` schema or
    # ``vol_root`` volume yet, and the background seed and artifact copy write
    # to both. ``ws`` is None for direct callers without a workspace.
    if ws is not None and deployment_catalog:
        try:
            ensure_metamodel_schema_and_volume(ws, deployment_catalog)
        except MetamodelSetupError as exc:
            raise KickstartError(setup_error_message(ws, deployment_catalog, exc)) from exc

    new_business = Business(
        name=new_name,
        description=resolved_description,
        kind="business",
        industry_id=industry.industry_id,
        industry_alignment=industry.industry_alignment,
        sector_id=industry.sector_id,
        source_industry_id=source_industry_id,
        source_version=source_version,
    )
    session.add(new_business)
    session.flush()  # assigns new_business.id

    src_industry_name = industry.name
    new_business_id = new_business.id

    # Plain captured values (no ORM rows referenced) for phase 0, which runs
    # in the background - one spec per source scope (an industry version may
    # comprise both an ECM and an MVM ModelVersion).
    source_specs = [
        _SourceVersionSpec(
            src_mv_id=src_mv.id,
            scope=src_mv.scope or "ecm",
            src_version=int(src_mv.version),
            schema_prefix_added=src_mv.import_schema_prefix_added,
            view_prefix_added=src_mv.import_view_prefix_added,
        )
        for src_mv in source_versions
    ]

    # Audit Run is a REAL lifecycle for ALL of the background work: born
    # status="running" with started_at set (no completed_at) so the runs page
    # shows ticking progress throughout; version_id starts NULL (no
    # ModelVersion exists yet) and is set once phase 0 creates one.
    # vibe_instructions_text carries the source lineage (the run-detail UI
    # already renders the field; the app-relative URL survives deployments).
    now = datetime.now(timezone.utc)
    run = Run(
        business_id=new_business_id,
        version_id=None,
        intent=INTENT_KICKSTART_FROM_INDUSTRY,
        status="running",
        progress_percent=0,
        progress_message=(
            f"Kickstarting from industry {industry.name!r} v{source_version}"
        ),
        vibe_instructions_text=(
            f"Source: {industry.name} v{source_version} "
            f"(/businesses/{source_industry_id})"
        ),
        created_at=now,
        started_at=now,
    )
    session.add(run)
    session.flush()  # assigns run.id
    run_id = run.id

    # Commit ONLY the durable audit anchor (business + running run) before
    # ANY of the slow work - the response returns the instant this lands,
    # independent of model size.
    session.commit()

    # `schedule_copy` below (when provided) hands off to
    # ``BackgroundTasks.add_task`` - FastAPI does not tear down this
    # request's ``Depends(Dependencies.Session)`` (closing `session`) until
    # AFTER that background task completes, because Starlette runs
    # background tasks from inside ``Response.__call__``, itself called
    # inside the same ``AsyncExitStack`` that owns the dependency's
    # post-yield teardown. Any read on `session` issued after
    # `schedule_copy` runs - an explicit refresh, or an implicit one
    # triggered later by touching an expired attribute during response
    # serialization - opens a transaction that then sits idle-in-transaction
    # for the entire multi-minute background window. Refresh `new_business`
    # and close that read's transaction HERE, before `schedule_copy` runs.
    # `expire_on_commit` is turned off only for this one commit (then
    # restored) so it doesn't immediately re-expire what was just loaded,
    # without changing the session's behaviour for anything downstream
    # (e.g. the inline direct-caller branch's own commits below).
    session.refresh(new_business)
    prior_expire_on_commit = session.expire_on_commit
    session.expire_on_commit = False
    session.commit()
    session.expire_on_commit = prior_expire_on_commit

    plan = _KickstartCopyPlan(
        run_id=run_id,
        deployment_catalog=deployment_catalog,
        src_business_name=src_industry_name,
        new_business_name=new_name,
        seeds=[],
        copy_specs=[],
        new_business_id=new_business_id,
        source_business_id=source_industry_id,
        copy_inputs=copy_inputs,
        source_specs=source_specs,
    )
    logger.info(
        "kickstart: business=%s from industry=%s v%s (%d scope(s)); "
        "structure+seed+copy %s",
        new_business_id, source_industry_id, source_version,
        len(source_specs),
        "scheduled in background" if schedule_copy else "running inline",
    )
    if schedule_copy is not None:
        # Fast return: the request completes now; structure + seed + copy
        # run in the background on a fresh session, driving the audit run to
        # completed.
        schedule_copy(plan)
    else:
        # Direct/unit callers: run structure + seed + copy inline on this
        # session.
        _run_kickstart_background(session, ws, plan)

    return new_business


def _copy_vibe_inputs(
    session: Session,
    *,
    source_business_id: str,
    new_business_id: str,
    version_map: dict[str, str],
) -> None:
    """Copy the industry's ``origin=user`` ``VibeInput`` (feedback) rows into
    the new business, re-anchoring each context link on a kickstarted source
    version to the cloned version's element ids.

    ``origin=agent_next_vibe`` rows are deliberately EXCLUDED here.
    ``model_sync.materialize_next_vibe_inputs`` is the single producer of
    those rows, keyed by a deterministic ``uuid5(version_id, ordinal)`` so
    re-ingesting the SAME artifact against the SAME version is a no-op. A
    naive copy from the source version would stamp fresh random ids onto the
    new version — ids the materializer has never seen — so the FIRST sync/
    resync of the kickstarted version (which re-parses the (now copied)
    next-vibes artifact through the same materializer) treats every finding
    as new and doubles the backlog. Phase 2 of the kickstart
    (:func:`_run_kickstart_background`) materializes the next-vibes backlog
    for the new version itself, via :func:`model_sync.ingest_next_vibes`,
    once the artifact has landed in the new version's own Volume folder -
    the SAME single producer, keyed against the NEW version_id from the
    start.

    An input is carried when it either links to at least one kickstarted
    source version or has no context links at all (a pure business-level
    input). Only links on kickstarted versions are re-created; links onto
    non-kickstarted versions are ignored (not part of this snapshot).
    ``origin`` / ``author`` (submitter) / ``text`` / ``category`` /
    ``priority`` / ``status`` / ``confidence_score`` and the created/updated
    timestamps are preserved so lineage reads correctly;
    ``selected_for_run`` / ``consumed`` start at their column defaults so a
    fresh business does not auto-dispatch inherited inputs.

    Re-anchoring resolves every carried link's natural key against an
    :class:`AnchorMaps` prefetched once per distinct target version (not
    once per link), and the resulting ``VibeInputContextLink`` rows go in
    with a single multi-row INSERT, instead of a per-link resolve + insert.
    """
    src_inputs = session.exec(
        select(VibeInput).where(
            VibeInput.business_id == source_business_id,
            VibeInput.origin == VibeInputOrigin.USER.value,
        )
    ).all()

    new_inputs: list[VibeInput] = []
    pending_links: list[tuple[VibeInput, VibeInputContextLink, str]] = []
    for src_input in src_inputs:
        carried_links = [
            link for link in src_input.context_links
            if link.version_id in version_map
        ]
        # Skip inputs anchored only to versions we did NOT kickstart. An input
        # with no links at all is a business-level input and IS carried.
        if not carried_links and src_input.context_links:
            continue

        new_input = VibeInput(
            business_id=new_business_id,
            origin=src_input.origin,
            author=src_input.author,
            text=src_input.text,
            category=src_input.category,
            priority=src_input.priority,
            confidence_score=src_input.confidence_score,
            status=src_input.status,
            created_at=src_input.created_at,
            updated_at=src_input.updated_at,
        )
        session.add(new_input)
        new_inputs.append(new_input)
        for link in carried_links:
            pending_links.append((new_input, link, version_map[link.version_id]))

    if new_inputs:
        session.flush()  # persist the new VibeInput rows the links FK into

    maps_by_version: dict[str, AnchorMaps] = {}
    link_rows = []
    for new_input, link, target_version_id in pending_links:
        maps = maps_by_version.get(target_version_id)
        if maps is None:
            maps = prefetch_anchor_maps(session, target_version_id)
            maps_by_version[target_version_id] = maps
        fks = _reanchor_context_link(session, link, target_version_id, maps)
        link_rows.append(_row_values(VibeInputContextLink(
            input_id=new_input.id,
            version_id=target_version_id,
            domain_id=fks.domain_id,
            subdomain_id=fks.subdomain_id,
            product_id=fks.product_id,
            attribute_id=fks.attribute_id,
            fk_link_id=fks.fk_link_id,
            is_origin=link.is_origin,
            needs_link_review=fks.needs_link_review,
        )))

    if link_rows:
        session.execute(sa_insert(VibeInputContextLink), link_rows)


def _reanchor_context_link(
    session: Session,
    link: VibeInputContextLink,
    new_version_id: str,
    maps: Optional[AnchorMaps] = None,
) -> _AnchorFKs:
    """Re-resolve a source context link's element anchors into
    ``new_version_id`` by natural key (element NAME), since kickstart
    regenerates the element tree with fresh ids.

    Captures the anchor by element name(s) from the OLD link, then resolves
    those names against the cloned version. Shares the canonical
    :func:`capture_named_anchor` / :func:`resolve_named_anchor` helpers with the
    force-resync path (``model_sync._delete_existing``) so both solve the same
    old-name -> new-id problem with one resolver (subdomain + attribute aware,
    degrades UP the hierarchy, flags ``needs_link_review`` on a below-level
    landing). ``maps`` is an optional prefetched :class:`AnchorMaps` for
    ``new_version_id``, passed through to ``resolve_named_anchor`` unchanged.
    """
    named = capture_named_anchor(session, link)
    return resolve_named_anchor(session, new_version_id, named, maps)


@dataclass
class _ArtifactCopySpec:
    """Plain captured values for the post-commit Volume artifact copy - no ORM
    row is referenced, so the copy runs safely with the transaction closed."""

    new_mv_id: str
    new_version: int
    src_version: int
    scope: str


@dataclass
class _SourceVersionSpec:
    """Plain captured values for one source scope's phase-0 clone - no ORM
    row is referenced, so phase 0 can run on a fresh (background) session."""

    src_mv_id: str
    scope: str
    src_version: int
    # The source version's import markers; ``None`` for an industry
    # downloaded before 0.9.0, whose copy gets the import rule.
    schema_prefix_added: Optional[str] = None
    view_prefix_added: Optional[str] = None


@dataclass
class _KickstartCopyPlan:
    """Everything the (possibly background) structure copy + seed + artifact
    copy needs, as plain values - the request session may be long closed by
    the time it runs.

    ``source_specs`` drives phase 0 (ModelVersion + tree + VibeInput copy);
    it is populated at plan-creation time and empty for a plan built with
    phase 0 already done (used by unit tests that exercise phase 1/2 in
    isolation). ``seeds``/``copy_specs`` start empty and are populated by
    phase 0 for the phases that follow: ``seeds`` are ``(exported_model_json,
    scope, version)`` tuples for phase 1 (_metamodel seed); ``copy_specs``
    drive phase 2 (Volume artifact copy)."""

    run_id: str
    deployment_catalog: str
    src_business_name: str
    new_business_name: str
    seeds: list[tuple[dict, str, int]]
    copy_specs: list[_ArtifactCopySpec]
    new_business_id: str = ""
    source_business_id: str = ""
    copy_inputs: bool = False
    source_specs: list[_SourceVersionSpec] = field(default_factory=list)
    # scope -> the schema prefix the copy's model.json is rewritten for
    # (``scope_prefix.apply_import_prefix``; ``None`` keeps its schemas and
    # renames only its metric views); a scope not in it is copied verbatim.
    rewrites: dict[str, Optional[str]] = field(default_factory=dict)
    # scope -> the (schema, view) markers the copy records.
    markers: dict[str, tuple[str, str]] = field(default_factory=dict)


# --- The kickstart schema prefix ---------------------------------------------


class KickstartModelUnreadable(KickstartError):
    """The industry model.json exists but could not be read, so the copy's
    schema prefix cannot be set; nothing is copied."""


def _industry_schema_prefix(ws, catalog: str, business_name: str, version: int, scope: str) -> Optional[str]:
    """The industry model.json's ``schema_prefix`` (``""`` when its
    conventions name none), or ``None`` when the version has no model.json
    (nothing to rewrite).

    Raises :class:`KickstartModelUnreadable` when the file is there but the
    bounded read fails (timeout, size cap, bad JSON). Copying anyway would
    leave that scope with the industry's bare names while the other scope
    gets its prefix, so the kickstart fails before phase 0 writes anything
    and the user can retry.
    """
    if not (ws and catalog and business_name):
        return None

    def _present(path: str) -> bool:
        directory = path.rsplit("/", 1)[0]
        return path in walk_volume_dir(ws, directory)

    found = read_conventions(
        ws, model_json_candidates(catalog, business_name, version, scope), exists=_present
    )
    if found.unreadable:
        raise KickstartModelUnreadable(
            f"Could not read the {scope.upper()} model file of industry {business_name!r} "
            f"v{version} to set the copy's schema prefix. Nothing was copied; kickstart again."
        )
    if found.path is None:
        return None
    return str((found.conventions or {}).get("schema_prefix") or "")


def _plan_scope_prefix(ws, plan: "_KickstartCopyPlan", spec: _SourceVersionSpec) -> None:
    """Record how ``spec``'s copy is prefixed: verbatim with the source's
    markers for a 0.9.0 industry; otherwise the import rule over the
    industry file's prefix (``scope_prefix.import_schema_prefix``), its
    metric views renamed too. No industry file: verbatim, nothing added."""
    if spec.schema_prefix_added is not None:
        plan.markers[spec.scope] = (spec.schema_prefix_added, spec.view_prefix_added or "")
        return
    file_prefix = _industry_schema_prefix(
        ws, plan.deployment_catalog, plan.src_business_name, spec.src_version, spec.scope,
    )
    if file_prefix is None:
        plan.markers[spec.scope] = ("", "")
        return
    prefix = import_schema_prefix(spec.scope, file_prefix)
    plan.rewrites[spec.scope] = prefix
    plan.markers[spec.scope] = (prefix or "", scope_schema_prefix(spec.scope))


def _set_run(session: Session, run_id: str, **fields) -> None:
    """Apply ``fields`` to the audit Run and commit in a short transaction.
    No-op if the run is gone."""
    run = session.get(Run, run_id)
    if run is None:
        return
    for k, v in fields.items():
        setattr(run, k, v)
    session.add(run)
    session.commit()


def _run_phase0(session: Session, plan: _KickstartCopyPlan) -> None:
    """Phase 0: create the new business's ModelVersion(s), copy each source
    version's element tree, and (when requested) copy re-anchored VibeInputs
    - all in ONE transaction, so a failure partway rolls back the whole phase
    and leaves no orphan ``ModelVersion`` / half-copied tree. Populates
    ``plan.seeds`` / ``plan.copy_specs`` for phases 1/2, and points the audit
    Run's ``version_id`` at the first cloned version once this commits.

    A no-op when ``plan.source_specs`` is empty (a plan built with phase 0
    already done, e.g. a unit test exercising phase 1/2 directly).
    """
    if not plan.source_specs:
        return

    phase0_started = time.monotonic()
    copy_tree_elapsed = 0.0
    export_elapsed = 0.0
    version_map: dict[str, str] = {}
    first_new_mv_id: Optional[str] = None
    for spec in plan.source_specs:
        new_mv = ModelVersion(
            business_id=plan.new_business_id,
            version=1,
            status="completed",
            deployment_status="draft",
            scope=spec.scope,
            # Not installed anywhere: no install catalog. Its files are seeded
            # and copied into the metamodel catalog, so they resolve there.
            files_catalog=plan.deployment_catalog or None,
            import_schema_prefix_added=plan.markers.get(spec.scope, ("", ""))[0],
            import_view_prefix_added=plan.markers.get(spec.scope, ("", ""))[1],
        )
        session.add(new_mv)
        session.flush()  # assigns new_mv.id

        copy_tree_started = time.monotonic()
        copy_model_tree(
            session, source_version_id=spec.src_mv_id, target_version_id=new_mv.id,
        )
        copy_tree_elapsed += time.monotonic() - copy_tree_started
        prefix = plan.rewrites.get(spec.scope)
        if prefix:
            apply_import_prefix_to_rows(session, new_mv.id, prefix)
            session.flush()

        export_started = time.monotonic()
        exported = export_model_json(session, new_mv.id)
        export_elapsed += time.monotonic() - export_started

        version_map[spec.src_mv_id] = new_mv.id
        if first_new_mv_id is None:
            first_new_mv_id = new_mv.id
        plan.seeds.append((exported, spec.scope, new_mv.version))
        plan.copy_specs.append(_ArtifactCopySpec(
            new_mv_id=new_mv.id,
            new_version=new_mv.version,
            src_version=spec.src_version,
            scope=spec.scope,
        ))

    inputs_elapsed = 0.0
    if plan.copy_inputs:
        inputs_started = time.monotonic()
        _copy_vibe_inputs(
            session,
            source_business_id=plan.source_business_id,
            new_business_id=plan.new_business_id,
            version_map=version_map,
        )
        inputs_elapsed = time.monotonic() - inputs_started

    session.commit()
    _set_run(session, plan.run_id, version_id=first_new_mv_id)
    phase0_elapsed = time.monotonic() - phase0_started
    logger.info(
        "kickstart: phase 0 (structure copy) for run %s took %.2fs "
        "(copy_model_tree=%.2fs, export_model_json=%.2fs, copy_vibe_inputs=%.2fs, "
        "%d source spec(s))",
        plan.run_id, phase0_elapsed, copy_tree_elapsed, export_elapsed,
        inputs_elapsed, len(plan.source_specs),
    )


def _run_kickstart_background(session: Session, ws, plan: _KickstartCopyPlan) -> None:
    """Three-phase background work for a kickstart, updating the audit run's
    progress as it goes and driving it to a terminal state:

    - Phase 0: create the ModelVersion(s), copy the model tree, copy
      VibeInputs (see :func:`_run_phase0`). The business is not usable at all
      until this lands.
    - Phase 1: seed ``_metamodel`` per version (minutes of external SQL-warehouse
      Delta writes). The business is not iterable until this lands - the iterate
      preflight (commit 6) returns an actionable 400 in the meantime.
    - Phase 2: copy the per-scope Volume artifacts + index the RunArtifact rows.

    Runs with NO transaction held across the slow work (phase 0's DB writes
    commit before phase 1 starts; each seed/copy in phase 1/2 is external or
    pure Volume I/O with only short progress/index writes as committed
    transactions). Non-fatal to the business, which is already durable: a
    hard failure in ANY phase marks the RUN ``failed`` with an
    ``error_message`` (phase 0 failure = no version/tree survives, business
    stays a bare shell; copy failure = artifacts partial). A seed failure
    still runs phase 2, then fails the run naming the seed failure (the
    model stays un-iterable, caught by the preflight). Per-file copy failures
    and unconfigured-catalog seed skips are tolerated (not run-failing).
    """
    kickstart_started = time.monotonic()
    step = 1 if plan.source_specs else 0
    try:
        if plan.source_specs:
            _set_run(
                session, plan.run_id,
                progress_message="Copying model structure",
            )
            for spec in plan.source_specs:
                _plan_scope_prefix(ws, plan, spec)
            _run_phase0(session, plan)

        total = step + len(plan.seeds) + len(plan.copy_specs)
        # Phase 1: _metamodel seed. Resolve the warehouse (opens a read txn)
        # then commit to close it before the external writes.
        warehouse_id = get_warehouse_id(session)
        session.commit()
        phase1_started = time.monotonic()
        # A failed seed does not stop the artifact copy: the run fails after
        # phase 2, naming the seed failure.
        seed_errors: list[str] = []
        for exported, scope, version in plan.seeds:
            summary = seed_metamodel_one(
                ws,
                catalog=plan.deployment_catalog,
                warehouse_id=warehouse_id,
                model_json=exported,
                business_name=plan.new_business_name,
                scope=scope,
                version=version,
                log_prefix="kickstart",
                wait_mode="background",
                location=version_dir_in_volume(
                    plan.deployment_catalog, plan.new_business_name, version, scope,
                ) if plan.deployment_catalog else None,
            )
            if summary is not None and summary.get("errors"):
                seed_errors.append(f"{scope} v{version}: {'; '.join(map(str, summary['errors']))}")
            step += 1
            _set_run(
                session, plan.run_id,
                progress_percent=int(step / total * 100) if total else 100,
                progress_message=f"Seeding metamodel ({step}/{len(plan.seeds)} scope(s))",
            )
        phase1_elapsed = time.monotonic() - phase1_started
        logger.info(
            "kickstart: phase 1 (_metamodel seed, outer loop) for run %s took "
            "%.2fs across %d scope(s)",
            plan.run_id, phase1_elapsed, len(plan.seeds),
        )

        # Phase 2: Volume artifact copy.
        phase2_started = time.monotonic()
        index_elapsed = 0.0
        next_vibes_elapsed = 0.0
        for spec in plan.copy_specs:
            dest_dir, copied = _copy_version_files(
                ws,
                catalog=plan.deployment_catalog,
                src_business_name=plan.src_business_name,
                src_version=spec.src_version,
                new_business_name=plan.new_business_name,
                new_version=spec.new_version,
                scope=spec.scope,
                rewrite=spec.scope in plan.rewrites,
                schema_prefix=plan.rewrites.get(spec.scope),
            )
            if copied:
                index_started = time.monotonic()
                index_artifacts_at_path(
                    ws, session,
                    run_id=None,
                    model_version_id=spec.new_mv_id,
                    volume_root_path=dest_dir,
                )
                index_elapsed += time.monotonic() - index_started
                # Materialize the next-vibes backlog for the NEW version now
                # that its own copy of the artifact has landed, via the same
                # single producer (model_sync.materialize_next_vibe_inputs)
                # every other entry point uses. Keying off spec.new_mv_id
                # from the start means a later resync's re-parse of this
                # SAME artifact recomputes the SAME uuid5 ids and no-ops
                # (see _copy_vibe_inputs' docstring for why a naive
                # VibeInput copy would double the backlog on first resync).
                if plan.copy_inputs:
                    next_vibes_started = time.monotonic()
                    ingest_next_vibes(
                        ws, session,
                        version_dir=dest_dir,
                        version_id=spec.new_mv_id,
                        business_id=plan.new_business_id,
                    )
                    session.commit()
                    next_vibes_elapsed += time.monotonic() - next_vibes_started
            step += 1
            _set_run(
                session, plan.run_id,
                progress_percent=int(step / total * 100) if total else 100,
                progress_message=f"Copying {spec.scope} artifacts",
            )
        phase2_elapsed = time.monotonic() - phase2_started
        logger.info(
            "kickstart: phase 2 (artifact copy) for run %s took %.2fs across "
            "%d spec(s) (index_artifacts_at_path=%.2fs, ingest_next_vibes=%.2fs; "
            "per-scope file-copy timing logged separately above)",
            plan.run_id, phase2_elapsed, len(plan.copy_specs),
            index_elapsed, next_vibes_elapsed,
        )
        if seed_errors:
            _set_run(
                session, plan.run_id,
                status="failed",
                progress_percent=100,
                progress_message="The model and its artifacts were copied, but seeding the "
                                 "agent's registry (_metamodel) failed, so the business "
                                 "can't be vibed yet.",
                error_message=sanitize_error_message(
                    f"_metamodel seed failed for {', '.join(seed_errors)}"
                ),
                completed_at=datetime.now(timezone.utc),
            )
            logger.error(
                "kickstart: run %s copied its artifacts but the _metamodel seed failed: %s",
                plan.run_id, seed_errors,
            )
            return
        _set_run(
            session, plan.run_id,
            status="completed",
            progress_percent=100,
            progress_message="Kickstart complete",
            completed_at=datetime.now(timezone.utc),
        )
        kickstart_elapsed = time.monotonic() - kickstart_started
        logger.info(
            "kickstart: background work for run %s completed in %.2fs total",
            plan.run_id, kickstart_elapsed,
        )
    except Exception as exc:
        kickstart_elapsed = time.monotonic() - kickstart_started
        logger.exception(
            "kickstart: background work failed for run %s after %.2fs (business "
            "row survives; any uncommitted version/tree for this phase does not)",
            plan.run_id, kickstart_elapsed,
        )
        try:
            session.rollback()
        except Exception:
            pass
        _set_run(
            session, plan.run_id,
            status="failed",
            progress_message="Kickstart background work failed; the business "
                             "is created but may not yet be iterable / its "
                             "artifacts may be incomplete.",
            error_message=recorded_error_text(exc, "Kickstart background work"),
            completed_at=datetime.now(timezone.utc),
        )


def run_kickstart_artifact_copy_bg(
    session_factory: Callable[[], Session], ws, plan: _KickstartCopyPlan
) -> None:
    """Background entry point: open a FRESH session (never the request's) and
    run the two-phase seed + copy. Never raises - the request has returned."""
    try:
        with session_factory() as session:
            _run_kickstart_background(session, ws, plan)
    except Exception:
        logger.exception(
            "kickstart: background task crashed for run %s", plan.run_id,
        )


def _copy_version_files(
    ws,
    *,
    catalog: str,
    src_business_name: str,
    src_version: int,
    new_business_name: str,
    new_version: int,
    scope: str,
    rewrite: bool = False,
    schema_prefix: Optional[str] = None,
) -> tuple[str, int]:
    """Copy the source version's Volume files under the new version's folder
    (``volume_copy.copy_volume_folder``); with ``rewrite``, its ``model.json``
    goes through ``scope_prefix.apply_import_prefix`` for ``schema_prefix``.
    Pure Volume I/O - touches no database, so it runs with the Postgres
    transaction closed.

    Returns ``(dest_dir, copied_count)``. ``catalog`` is the DEPLOYMENT catalog
    (where the ``_metamodel`` Volume lives), NOT the per-model install catalog
    (empty for a draft industry); both folders build off it. The source may be
    a pre-upgrade (flat) folder: nested first, then flat, whichever holds
    files; the destination is always nested. Best-effort: a missing ``ws`` /
    catalog / source folder yields ``("", 0)``; a file that fails is logged
    and skipped.
    """
    if not (ws and catalog and src_business_name):
        return "", 0
    try:
        src_candidates = version_dir_candidates(catalog, src_business_name, src_version, scope)
        dest_dir = version_dir_in_volume(catalog, new_business_name, new_version, scope)
    except ValueError:
        return "", 0

    def _rewrite(payload: bytes) -> bytes:
        root = json.loads(payload)
        apply_import_prefix(root, scope, schema_prefix)
        return json.dumps(root).encode()

    for src_dir in src_candidates:
        files = walk_volume_dir(ws, src_dir)
        if files:
            result = copy_volume_folder(
                ws, files, src_dir, dest_dir,
                model_json_transform=_rewrite if rewrite else None,
                log_prefix=f"kickstart {new_business_name} v{new_version} {scope}",
            )
            return dest_dir, result.copied
    return dest_dir, 0


__all__ = [
    "KickstartModelUnreadable",
    "kickstart_from_industry",
    "run_kickstart_artifact_copy_bg",
    "KickstartError",
    "KickstartSourceNotFound",
    "KickstartNameConflict",
    "KickstartDescriptionRequired",
]

"""Download + materialize a GitHub industry model into Lakebase (Story 4/7).

Pulls a published ``model.json`` (and its companion artifacts) out of the
configured GitHub source and lands it as a brand-new ``kind='industry'``
:class:`Business` plus its first :class:`ModelVersion`. Synchronous: unlike
the agent run path, there is no Databricks job — the bytes already exist at
rest in the repo, so a download is a read + sync.

Flow (``download_industry_model``):

1. Build the GitHub connector from the installation's ``agent_config``
   (mirrors :func:`routes.sources._connector`).
2. The scope from the model id (an id with no ``ecm`` / ``mvm`` scope is
   refused, 422, before anything is read) → ``fetch_model_json`` →
   ``json.loads`` → the app's copy gets
   the scope prefix (:func:`scope_prefix.apply_import_prefix`: a blank file
   prefix becomes ``ecm_`` / ``mvm_`` on its schemas, metric view sources and
   metric view names) → :func:`import_model.detect_schema`,
   which UNWRAPS the ``{"model": ...}`` envelope. The business identity and
   the synced domains come from the unwrapped inner ``model`` — never the
   top-level ``model_name``/``domains`` keys (the routes/sources.py:168 bug).
3. Validate the target sector exists (404 otherwise).
4. Reconcile per the model-scope conflict unit: create a new industry,
   add a never-seen scope to an existing one, or 409 a same-scope clash.
   Once every refusal is behind us, set up ``<deployment_catalog>._metamodel``
   and its ``vol_root`` volume (:func:`metamodel_registry.ensure_metamodel_or_refuse`,
   idempotent) so the uploads and the seed below have somewhere to land; a
   refused request creates nothing in Unity Catalog.
5. Construct the ``Business`` directly here (NOT via the create_business
   route): ``kind='industry'``, ``sector_id`` set, ``source_industry_id``
   left NULL — a downloaded industry is itself the source, not a kickstart.
6. Create the draft ``ModelVersion`` + sync the model via
   :class:`ModelSyncService`.
7. Materialize each fetched artifact's bytes onto the Volume (the model.json
   is the app's rewritten, scope-stamped copy; companion artifacts verbatim), index them with
   :func:`services.artifact_indexer.index_artifacts_at_path`, and materialize
   the source's next-vibe backlog via :func:`model_sync.ingest_next_vibes`.
8. Commit, then seed ``<deployment_catalog>._metamodel.*`` via
   :func:`import_metamodel_writer.write_metamodel` (which creates the agent's
   registry tables first when they are missing) so the downloaded industry
   is directly iterable (the agent reads its parent model only from
   ``_metamodel``). Best-effort, external, post-commit, non-fatal: a seed
   failure is returned in ``DownloadResult.warnings``.
9. Write the audit :class:`Run` (``Run.business_id`` is required, so the
   business must be committed first); its timestamps are stamped equal and it
   carries the source lineage in ``vibe_instructions_text``.
"""

from __future__ import annotations

import io
import json
import logging
from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Optional

from fastapi import HTTPException
from sqlmodel import Session, select

from .._query_helpers import (
    BusinessNameConflict,
    ensure_business_name_available,
    next_version_for_scope,
)
from ..core import _paths, resolve_metamodel_catalog
from ..core._paths import _VALID_SCOPES
from ..core._warehouse import get_warehouse_id
from ..db_models import Business, ModelVersion, Run, Sector
from ..import_model import detect_schema
from ..model_sync import ModelSyncService, ingest_next_vibes
from ..sources import build_source_connector
from ..sources.github import SourceNotFoundError, model_id_to_relpath
from .artifact_indexer import index_artifacts_at_path
from .import_metamodel_writer import seed_metamodel_one, seed_warnings
from .metamodel_registry import ensure_metamodel_or_refuse
from .scope_prefix import apply_import_prefix, file_schema_prefix, import_schema_prefix, stamp_scope

logger = logging.getLogger(__name__)

@dataclass
class DownloadResult:
    """Outcome of a synchronous industry-model download.

    ``on_conflict_applied`` is one of ``"none"`` (created a brand-new
    industry business) or ``"added"`` (added a never-seen scope under an
    existing industry business). Same-scope re-downloads are blocked with a
    409 (see :func:`download_industry_model`) and never produce a result.
    """

    business_id: str
    business_name: str
    version_id: str
    version: int
    scope: str
    domains: int
    products: int
    attribute_count: int
    fk_count: int
    on_conflict_applied: str
    run_id: Optional[str] = None
    warnings: list[str] = field(default_factory=list)


def _scope_from_model_id(model_id: str) -> Optional[str]:
    """The scope of a downloaded model: the ``<scope>`` segment of its
    ``<version>_<scope>`` id (:func:`sources.github.model_id_to_relpath`), or
    ``None`` when the id names no ``ecm`` / ``mvm`` scope."""
    try:
        cand = model_id_to_relpath(model_id).split("/")[1]
    except (SourceNotFoundError, IndexError):
        return None
    return cand if cand in _VALID_SCOPES else None


def _model_relpath(model_id: str) -> str:
    """The ``<version>/<scope>`` relpath for a fused model id, with a graceful
    fallback to the raw id. In production a malformed id 404s at
    ``fetch_model_json`` long before this is reached; the fallback only guards
    the never-hit-in-prod path so provenance/Volume builders never raise."""
    try:
        return model_id_to_relpath(model_id)
    except SourceNotFoundError:
        return model_id


def _connector(session: Session, config, ws):
    """Build the GitHub source connector from the installation config.

    Mirrors :func:`routes.sources._connector` (one convergent construction, no
    divergence). Imported indirectly so tests can monkeypatch
    ``build_source_connector`` on this module. Read transport is resolved from
    the ``AgentConfig`` ``source_*`` columns (GitHub App / token / anonymous),
    falling back to the deployment's GitHub App env creds then anonymous when
    unconfigured; any referenced secret is read via the app service principal
    ``ws``. Transport selection is centralised in ``build_source_connector``.
    """
    from ..routes._helpers import _get_or_create_agent_config

    cfg = _get_or_create_agent_config(session, config)
    return build_source_connector(
        cfg,
        config,
        ws,
        repo_owner=cfg.github_repo_owner,
        repo_name=cfg.github_repo_name,
    )


def _materialize_artifacts(
    ws,
    connector,
    *,
    industry_id: str,
    model_id: str,
    version_dir: str,
    model_json_text: str,
    warnings: list[str],
) -> None:
    """Fetch each companion artifact's bytes and upload them under the
    version directory, preserving the source-relative sub-path beneath the
    model dir (``schemas/...``, ``diagram/...``, …). The ``model.json`` is
    written from the already-fetched text. Best-effort per file; failures are
    logged AND appended to ``warnings`` so the operator sees them on the 200.
    """
    # The model.json we already hold in memory.
    _upload(ws, f"{version_dir}/model.json", model_json_text, name="model.json", warnings=warnings)

    model_dir_prefix = f"{industry_id}/{_model_relpath(model_id)}/"
    try:
        artifacts = connector.fetch_artifacts(industry_id, model_id)
    except Exception as exc:
        logger.exception(
            "industry_download: fetch_artifacts failed for %s/%s (non-fatal)",
            industry_id, model_id,
        )
        warnings.append(
            f"Could not fetch companion artifacts from the source: {exc}"
        )
        return

    for art in artifacts:
        # The model.json is handled above; skip the duplicate.
        if art.path.endswith("/model.json") or art.path == "model.json":
            continue
        rel = art.path[len(model_dir_prefix):] if art.path.startswith(model_dir_prefix) else art.name
        try:
            text = connector._fetch_raw(art.path)
        except Exception as exc:
            logger.warning("industry_download: could not fetch artifact %s", art.path)
            warnings.append(
                f"Could not fetch artifact {art.name} from the source: {exc}"
            )
            continue
        _upload(ws, f"{version_dir}/{rel}", text, name=art.name, warnings=warnings)


def _upload(ws, path: str, text: str, *, name: str, warnings: list[str]) -> None:
    try:
        ws.files.upload(path, io.BytesIO(text.encode("utf-8")), overwrite=True)
    except Exception as exc:
        logger.warning("industry_download: upload to %s failed (non-fatal)", path)
        warnings.append(
            f"Failed to upload artifact {name} to the Volume: {exc}"
        )


def download_industry_model(
    session: Session,
    ws,
    *,
    config,
    sector_id: str,
    industry_id: str,
    model_id: str,
) -> DownloadResult:
    """Download a GitHub industry model into a ``kind='industry'`` Business.

    The conflict unit is the MODEL (scope) WITHIN an industry, not the
    industry as a whole. Three cases:

    1. No industry business by this name → create it + add the model.
    2. Industry exists, this scope NOT yet present → ADD the model as a new
       :class:`ModelVersion` under the existing business. The existing
       business row is NOT mutated (name/description/sector_id/etc. stay
       exactly as the first download left them); ``sector_id`` from the
       request is IGNORED for an existing industry. The SOLE exception is
       ``source_repo_path`` (ADR D-049): if still NULL it is backfilled here
       (first-download-wins), never overwritten once set.
    3. Industry exists AND this scope already present → block with a 409
       ``industry_model_already_exists``. No append, no replace.

    See module docstring for the full flow. Raises :class:`HTTPException`
    (404 for a missing sector / source object, 403 on a source access denial,
    409 on a same-scope clash).

    ``ws`` is the app service principal (writes the fetched bytes to the
    Volume). Source reads authenticate as the deployment's GitHub App when its
    credentials are configured, falling back to anonymous browsing otherwise.
    """
    warnings: list[str] = []

    # The scope names the Volume folder, the version row and the prefix.
    scope = _scope_from_model_id(model_id)
    if scope is None:
        raise HTTPException(
            status_code=422,
            detail=f"The source model {model_id!r} is not an ECM or an MVM model, so it can't be downloaded.",
        )

    # 1. Build connector + fetch the raw model.json.
    connector = _connector(session, config, ws)
    from ..sources import SourceError, SourceNotFoundError, SourcePermissionError

    try:
        raw = connector.fetch_model_json(industry_id, model_id)
    except SourceNotFoundError as exc:
        raise HTTPException(status_code=404, detail=str(exc)) from exc
    except SourcePermissionError as exc:
        raise HTTPException(status_code=403, detail=str(exc)) from exc
    except SourceError as exc:
        raise HTTPException(status_code=502, detail=f"Source unavailable: {exc}") from exc

    try:
        model_json = json.loads(raw)
    except (ValueError, TypeError) as exc:
        raise HTTPException(
            status_code=422, detail=f"model.json from source is not valid JSON: {exc}"
        ) from exc

    # The app's copy carries the scope prefix (the source file is unchanged).
    schema_prefix = import_schema_prefix(scope, file_schema_prefix(model_json))
    prefix_report = apply_import_prefix(model_json, scope, schema_prefix)
    warnings.extend(prefix_report.warnings)

    # 2. Route through detect_schema — it UNWRAPS the {"model": ...} envelope.
    analysis = detect_schema(model_json)
    if not analysis.valid:
        raise HTTPException(status_code=422, detail=analysis.message)
    warnings.extend(analysis.warnings)
    inner = analysis._model or {}

    # The business identity comes from the UNWRAPPED model, never the
    # top-level decoy keys.
    industry_name = str(inner.get("name") or "").strip()
    if not industry_name:
        raise HTTPException(
            status_code=422, detail="model.json carries no model name to use as the industry name."
        )
    description = str(inner.get("description") or "").strip()

    # 5. Resolve the conflict unit: the MODEL (scope) within the industry.
    existing = session.exec(
        select(Business).where(Business.name.ilike(industry_name))
    ).first()

    on_conflict_applied = "none"
    business: Business
    if existing is not None:
        # Industry exists → the sector is fixed by the first download. The
        # request's sector_id is IGNORED; a second model never moves the
        # industry to a different sector (and never mutates the row at all —
        # only appends a ModelVersion).
        scope_clash = session.exec(
            select(ModelVersion)
            .where(ModelVersion.business_id == existing.id)
            .where(ModelVersion.scope == scope)
        ).first()
        if scope_clash is not None:
            raise HTTPException(
                status_code=409,
                detail={
                    "error": "industry_model_already_exists",
                    "scope": scope,
                    "message": (
                        f"This model ({scope}) is already downloaded for "
                        f"{existing.name}. Delete it in the app first to "
                        f"re-download."
                    ),
                },
            )
    else:
        # 3. New industry → the sanitization-aware name guard rejects a name
        # that normalizes (via agent_business_segment) to any existing
        # business/industry, even when it does not exactly clash on the raw
        # name (case/punctuation variants collapse to the same _metamodel key).
        # The additive-scope branch above is exempt - it is a legitimate
        # re-download onto the SAME industry.
        try:
            ensure_business_name_available(session, industry_name)
        except BusinessNameConflict as exc:
            from ..routes._helpers import business_name_taken_error

            raise business_name_taken_error(industry_name, str(exc)) from exc
        # Validate the requested target sector exists. sector_id is only
        # honoured for a new industry.
        if session.get(Sector, sector_id) is None:
            raise HTTPException(status_code=404, detail=f"Sector '{sector_id}' not found.")

    # Every check that can refuse the request is behind us. The model's files
    # and the agent's registry rows land under the deployment catalog: make
    # sure its ``_metamodel`` schema and ``vol_root`` volume exist before the
    # first row or Unity Catalog write, since a fresh catalog has neither.
    deployment_catalog = resolve_metamodel_catalog(session, config)
    ensure_metamodel_or_refuse(ws, deployment_catalog)

    if existing is not None:
        # Additive: a never-seen scope under an existing industry. No row
        # mutation, no conflict.
        business = existing
        on_conflict_applied = "added"
        # First-download-wins: backfill the round-trip publish target only if
        # never set. Sole exception to this branch's no-mutate invariant (ADR D-049).
        if not existing.source_repo_path:
            existing.source_repo_path = _industry_repo_path(session, config, industry_id)
    else:
        business = _new_industry(
            industry_name, description, sector_id,
            _industry_repo_path(session, config, industry_id),
        )
        session.add(business)
        session.flush()

    # 6. Create the draft ModelVersion + sync the model.
    new_version_num = next_version_for_scope(session, business.id, scope)
    now_ts = datetime.now(timezone.utc)
    source_path = f"{_repo_base_uri(session, config)}/{industry_id}/{_model_relpath(model_id)}"
    mv = ModelVersion(
        business_id=business.id,
        version=new_version_num,
        status="completed",
        deployment_status="draft",
        scope=scope,
        completion_date=now_ts,
        import_source_path=source_path,
        imported_at=now_ts,
        files_catalog=deployment_catalog or None,
        import_schema_prefix_added=prefix_report.schema_prefix_added,
        import_view_prefix_added=prefix_report.view_prefix_added,
    )
    session.add(mv)
    session.flush()

    stamp_scope(model_json, new_version_num, scope)
    model_json_text = json.dumps(model_json)
    ModelSyncService(session).sync_from_model_json(mv.id, inner)

    # Resolve the Volume dir and capture the primitives
    # the post-commit steps need, THEN commit the structure BEFORE the slow
    # Volume materialize. Holding a Postgres transaction across the
    # multi-minute artifact upload trips Lakebase's idle-in-transaction
    # timeout and 500s an otherwise-complete download. This also keeps the
    # design ordering: Lakebase durable before the external _metamodel write.
    version_dir = (
        _paths.version_dir_in_volume(
            deployment_catalog, business.name, new_version_num, scope,
        )
        if deployment_catalog else ""
    )
    business_id = business.id
    business_name = business.name
    mv_id = mv.id
    domain_count = analysis.domain_count
    session.commit()

    # 7. Materialize artifact bytes onto the Volume (slow I/O, NO open
    # transaction), then index + ingest next-vibes in a SHORT fresh
    # transaction committed right after.
    if deployment_catalog:
        try:
            _materialize_artifacts(
                ws, connector,
                industry_id=industry_id, model_id=model_id,
                version_dir=version_dir, model_json_text=model_json_text,
                warnings=warnings,
            )
            index_artifacts_at_path(
                ws, session,
                run_id=None, model_version_id=mv_id, volume_root_path=version_dir,
            )
            # Materialize structured next-vibe inputs from the source's
            # next_vibes.txt (the shared load-then-materialize helper), so a
            # downloaded industry carries the same backlog a run/import would.
            ingest_next_vibes(
                ws, session,
                version_dir=version_dir,
                version_id=mv_id,
                business_id=business_id,
            )
            session.commit()
        except Exception as exc:
            # Clear the failed index/ingest transaction; the structure is
            # already durable and the files are on the Volume (re-indexable).
            session.rollback()
            logger.exception(
                "industry_download: materialize/index failed for version %s (non-fatal)",
                mv_id,
            )
            warnings.append(
                f"Artifact materialization/indexing failed; the model imported "
                f"without companion artifacts: {exc}"
            )

    # 8. Seed the agent's ``_metamodel.*`` so a downloaded industry is directly
    # iterable (the agent reads its parent model ONLY from _metamodel on
    # iterate/enlarge/shrink). Resolve the warehouse then commit to close the
    # read transaction, so no Postgres transaction is held across the external
    # SQL-warehouse write. Best-effort, non-fatal (shared seed helper, which
    # creates the registry tables first in a catalog the agent never ran in);
    # a failure is a warning on the 200.
    warehouse_id = get_warehouse_id(session)
    session.commit()
    seed = seed_metamodel_one(
        ws,
        catalog=deployment_catalog,
        warehouse_id=warehouse_id,
        model_json=inner,
        business_name=business_name,
        scope=scope,
        version=new_version_num,
        log_prefix="industry_download",
        wait_mode="request",
        location=version_dir or None,
    )
    warnings.extend(seed_warnings(seed))

    # 9. Audit Run: synchronous pseudo-run, so stamp all three timestamps equal
    # (a completed run with NULL started/completed renders as perpetually
    # "running"). Carry the source lineage in the otherwise-unused
    # vibe_instructions_text (the run-detail UI renders it): the github source
    # URL plus the industry's app-relative path.
    run = Run(
        business_id=business_id,
        version_id=mv_id,
        intent="download-industry",
        status="completed",
        progress_percent=100,
        vibe_instructions_text=f"Source: {source_path} (/businesses/{business_id})",
        created_at=now_ts,
        started_at=now_ts,
        completed_at=now_ts,
        parameters_json=json.dumps({
            "operation": "download-industry",
            "sector_id": sector_id,
            "industry_id": industry_id,
            "model_id": model_id,
            "source_path": source_path,
            "on_conflict_applied": on_conflict_applied,
        }),
    )
    session.add(run)
    session.commit()
    run_id = run.id

    return DownloadResult(
        business_id=business_id,
        business_name=business_name,
        version_id=mv_id,
        version=new_version_num,
        scope=scope,
        domains=domain_count,
        products=analysis.product_count,
        attribute_count=analysis.attribute_count,
        fk_count=analysis.fk_count,
        on_conflict_applied=on_conflict_applied,
        run_id=run_id,
        warnings=warnings,
    )


def _new_industry(
    name: str, description: str, sector_id: str, source_repo_path: str
) -> Business:
    """Construct a ``kind='industry'`` Business. ``source_industry_id`` stays
    NULL — a downloaded industry is the source, not a kickstart.
    ``source_repo_path`` is the industry-folder root for the publish round-trip
    (ADR D-049)."""
    return Business(
        name=name,
        description=description,
        kind="industry",
        sector_id=sector_id,
        source_repo_path=source_repo_path,
    )


def _repo_label(session: Session, config) -> str:
    """``owner/repo@ref`` label for the import_source_path provenance."""
    from ..routes._helpers import _get_or_create_agent_config
    from ..sources.github import DEFAULT_REF, DEFAULT_REPO_NAME, DEFAULT_REPO_OWNER

    cfg = _get_or_create_agent_config(session, config)
    owner = cfg.github_repo_owner or DEFAULT_REPO_OWNER
    name = cfg.github_repo_name or DEFAULT_REPO_NAME
    return f"{owner}/{name}@{DEFAULT_REF}"


def _repo_base_uri(session: Session, config) -> str:
    """``github://owner/repo@ref[/<base_path>]`` — the model-tree root URI that
    every ``github://`` provenance/publish path hangs off. Scoped under the
    connector's ``DEFAULT_BASE_PATH`` (the ``data-models/`` subtree); an empty
    base path leaves the URI at the repo root (pre-move layout). The single
    base-path-aware builder so the import-source and publish-target paths can't
    drift apart from the connector's read scope."""
    from ..sources.github import DEFAULT_BASE_PATH

    base = DEFAULT_BASE_PATH.strip("/")
    label = _repo_label(session, config)
    return f"github://{label}/{base}" if base else f"github://{label}"


def _industry_repo_path(session: Session, config, industry_id: str) -> str:
    """``github://owner/repo@ref/data-models/<industry_id>`` — the industry-folder
    root the publish dialog pre-fills (ADR D-049). The model_id (scope_vN) is
    deliberately omitted — the publish target is the WHOLE bundle root, not a
    single model."""
    return f"{_repo_base_uri(session, config)}/{industry_id}"

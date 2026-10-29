"""Launch a batch: snapshot sources, write per-domain config.json, run_now per domain."""
from __future__ import annotations

import io
import json
from datetime import datetime, timezone

from databricks.sdk import WorkspaceClient
from sqlmodel import Session, select

from ..core._names import agent_business_segment, normalize_scope
from ..error_sanitization import recorded_error_text, sanitize_error_message
from ..db_models import (
    AssessBatch, AssessConfig, AssessDomainRun, AssessDomainSource, Business, Domain, ModelVersion,
    AssessColumnMapping, AssessEntity,
)
from .assets import read_versions
from .config_service import assess_ready
from .constants import domain_out_dir
from .metamodel import MetamodelLocation, resolve_metamodel_location
from .schemas import AssessBatchIn, SourceIn
from ..services.schema_names import domain_schema_name


class LaunchNotReady(Exception):
    """``assess_ready`` is false; ``missing`` holds the plain reasons."""

    def __init__(self, missing: list[str]):
        self.missing = missing
        super().__init__("Assessment isn't set up yet: " + "; ".join(missing))


def ensure_launch_ready(cfg: AssessConfig, installed: bool) -> None:
    """Refuse a launch unless the stored setup is ready (``assess_ready``). Raises ``LaunchNotReady``."""
    ready, missing = assess_ready(cfg, installed)
    if not ready:
        raise LaunchNotReady(missing)


def prior_tiers_for(session: Session, *, business_id: str, version_id: str, domain_id: str,
                    exclude_batch_id: str) -> dict | None:
    """Tiers from the newest completed run of the same business + version + domain, or None.

    Shape: {source_domain_run_id, assessed_at, entities: {entity_lower: {column_lower: tier}}}; non-empty tiers only.
    """
    runs = session.exec(
        select(AssessDomainRun).join(AssessBatch, AssessBatch.id == AssessDomainRun.batch_id)
        .where(AssessBatch.business_id == business_id, AssessBatch.version_id == version_id,
               AssessDomainRun.domain_id == domain_id, AssessDomainRun.status == "completed",
               AssessBatch.id != exclude_batch_id)
        .order_by(AssessDomainRun.ended_at.desc().nulls_last())
    ).all()
    for run in runs:
        rows = session.exec(
            select(AssessEntity.name, AssessColumnMapping.target, AssessColumnMapping.tier)
            .join(AssessEntity, AssessEntity.id == AssessColumnMapping.entity_id)
            .where(AssessEntity.domain_run_id == run.id, AssessColumnMapping.tier != "")
        ).all()
        if not rows:
            continue
        entities: dict[str, dict[str, str]] = {}
        for name, target, tier in rows:
            entities.setdefault(name.lower(), {})[target.lower()] = tier
        return {"source_domain_run_id": run.id,
                "assessed_at": run.ended_at.isoformat() if run.ended_at else None,
                "entities": entities}
    return None


def build_domain_config(*, batch, business, version, domain, mm: MetamodelLocation, sources: list[SourceIn],
                        cfg: AssessConfig, versions: dict, out_dir: str, prior_tiers: dict | None = None) -> dict:
    bronze = {s.source_name: f"{s.catalog_name}.{s.schema_name}" for s in sources}
    payload = {
        "batch_id": batch.id, "domain": domain.name, "customer": business.name,
        "metamodel_business": agent_business_segment(business.name),
        "vibe_catalog": version.uc_catalog, "physical_schema": domain_schema_name(domain.database_name, domain.name),
        "metamodel_schema": mm.schema, "metamodel_prefix": mm.prefix, "model_version": version.version,
        "model_scope": normalize_scope(version.scope),
        "bronze_sources": bronze, "bronze_catalog": sources[0].catalog_name,
        "silver_catalog": version.uc_catalog, "gold_catalog": version.uc_catalog,
        "output_model": batch.output_model, "etl_type": batch.etl_type, "reasoning_effort": batch.reasoning_effort,
        "warehouse_id": cfg.warehouse_id,
        "genie": versions["genie"], "databricks_cli": versions["databricks_cli"], "genie_model": versions["genie_model"],
        "skills": versions["staged_skills"],
        "max_resumes": 12, "backoff_base_seconds": 60, "timeout_minutes": 170, "out_dir": out_dir,
    }
    if prior_tiers is not None:
        payload["prior_tiers"] = prior_tiers
    return payload


def launch_batch(session: Session, ws: WorkspaceClient, *, business: Business, version: ModelVersion,
                 domains: list[tuple[Domain, list[SourceIn]]], body: AssessBatchIn, cfg: AssessConfig,
                 deployment_catalog: str, user: str, installed: bool = True) -> AssessBatch:
    """One AssessDomainRun per domain, each pinned to the job, reader and notebook folder it launched with."""
    ensure_launch_ready(cfg, installed)
    versions = read_versions()
    batch = AssessBatch(business_id=business.id, version_id=version.id, output_model=body.output_model,
                        etl_type=body.etl_type, reasoning_effort=body.reasoning_effort, created_by=user)
    session.add(batch); session.commit(); session.refresh(batch)
    for domain, sources in domains:
        out_dir = domain_out_dir(deployment_catalog, batch.id, domain.name)
        dr = AssessDomainRun(batch_id=batch.id, domain_id=domain.id, out_dir=out_dir,
                             config_path=f"{out_dir}/config.json", genie_version=versions["genie"]["tag"],
                             job_id=cfg.job_id, job_reader=cfg.job_reader, notebook_folder=cfg.workspace_path)
        session.add(dr)
        for s in sources:
            session.add(AssessDomainSource(domain_run_id=dr.id, source_name=s.source_name,
                                           catalog_name=s.catalog_name, schema_name=s.schema_name))
        session.commit(); session.refresh(dr)
        try:
            mm = resolve_metamodel_location(ws, version.uc_catalog, domain_schema_name(domain.database_name, domain.name))
            if mm is None:
                raise RuntimeError(f"No metamodel found in {version.uc_catalog}")
            prior_tiers = None
            if body.reuse_prior_tiers:
                prior_tiers = prior_tiers_for(session, business_id=business.id, version_id=version.id,
                                             domain_id=domain.id, exclude_batch_id=batch.id)
            payload = build_domain_config(batch=batch, business=business, version=version, domain=domain, mm=mm,
                                          sources=sources, cfg=cfg, versions=versions, out_dir=out_dir,
                                          prior_tiers=prior_tiers)
            ws.files.upload(dr.config_path, io.BytesIO(json.dumps(payload, indent=2).encode()), overwrite=True)
            run = ws.jobs.run_now(job_id=dr.job_id, job_parameters={"config_path": dr.config_path})
            dr.databricks_run_id = run.run_id
        except Exception as e:
            dr.status = "failed"
            dr.error_message = "Launch failed: " + recorded_error_text(
                e, f"Launch of domain run {dr.id}", f"{type(e).__name__}: {sanitize_error_message(str(e))}")[:1900]
            dr.ended_at = datetime.now(timezone.utc)
        session.add(dr); session.commit()
    session.refresh(batch)
    return batch

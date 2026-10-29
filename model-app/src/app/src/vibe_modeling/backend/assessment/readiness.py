"""Pre-launch readiness checks for the reader SP (blocking on confirmed failures)."""
from __future__ import annotations

from databricks.sdk import WorkspaceClient
from databricks.sdk.errors.base import DatabricksError

from ..core._uc_privileges import covers, effective_privileges
from ..db_models import AssessConfig, Domain, ModelVersion
from ..services.metamodel_setup import METAMODEL_SCHEMA
from .config_service import assess_ready
from .reader_sp import find_reader_sp, reader_not_found_message
from .constants import ADMIN_HELP, RUNS_VOLUME
from .metamodel import resolve_metamodel_location
from .schemas import Check, DomainReadiness, ReadinessOut, SourceIn
from ..services.schema_names import domain_schema_name

_READ = {"USE_SCHEMA", "SELECT"}
_WH_OK = {"CAN_USE", "CAN_MANAGE", "IS_OWNER"}


def _v(x) -> str:
    return getattr(x, "value", x)


def _has(privs: set[str] | None, needed: set[str]) -> str:
    if privs is None:
        return "unverified"
    return "ok" if covers(privs, needed) else "blocked"


def warehouse_state(ws: WorkspaceClient, warehouse_id: str, reader: str, sp) -> str:
    """ok on a direct/known-group grant; unverified when access may come via a nested group or sp is unknown."""
    try:
        perms = ws.warehouses.get_permissions(warehouse_id)
    except DatabricksError:
        return "unverified"
    known = {g.display for g in (getattr(sp, "groups", None) or [])} | {"users"}
    maybe_nested = False
    for acl in perms.access_control_list or []:
        if not any(_v(p.permission_level) in _WH_OK for p in (acl.all_permissions or [])):
            continue
        if acl.service_principal_name == reader or (acl.group_name and acl.group_name in known):
            return "ok"
        if acl.group_name:
            maybe_nested = True
    return "unverified" if (maybe_nested or sp is None) else "blocked"


def _read_check(ws, key: str, label: str, reader: str, catalog: str, schemas: list[str]) -> Check:
    """USE CATALOG on the catalog + USE SCHEMA/SELECT on every schema; worst state wins."""
    schemas = list(dict.fromkeys(schemas))
    states = [_has(effective_privileges(ws, "catalog", catalog, reader), {"USE_CATALOG"})]
    states += [_has(effective_privileges(ws, "schema", f"{catalog}.{s}", reader), _READ) for s in schemas]
    state = "blocked" if "blocked" in states else ("unverified" if "unverified" in states else "ok")
    fix = ""
    if state != "ok":
        fix = f"GRANT USE CATALOG ON CATALOG `{catalog}` TO `{reader}`;\n" + "\n".join(
            f"GRANT USE SCHEMA ON SCHEMA `{catalog}`.`{s}` TO `{reader}`;\nGRANT SELECT ON SCHEMA `{catalog}`.`{s}` TO `{reader}`;"
            for s in schemas)
    where = ", ".join(f"{catalog}.{s}" for s in schemas)
    detail = {"ok": "", "blocked": f"Reader can't read {where}.",
              "unverified": f"The app can't read grants on {where}; the job pre-flight will check it."}[state]
    return Check(key=key, label=label, state=state, detail=detail, fix_sql=fix)


def evaluate_readiness(session, ws: WorkspaceClient, cfg: AssessConfig, *, deployment_catalog: str,
                       version: ModelVersion, domains: list[tuple[Domain, list[SourceIn]]]) -> ReadinessOut:
    reader = cfg.reader_application_id
    g: list[Check] = []
    if not reader:
        g.append(Check(key="reader_configured", label="Reader service principal", state="blocked",
                       detail="No reader SP configured.", fix_action="open_settings"))
        return ReadinessOut(global_checks=g, domains=[
            DomainReadiness(domain_id=d.id, domain_name=d.name, checks=[], blocked=True) for d, _ in domains])
    sp, sp_unverified = None, False
    try:
        sp = find_reader_sp(ws, reader)
    except DatabricksError:
        sp_unverified = True
    if sp_unverified:
        g.append(Check(key="reader_configured", label="Reader service principal", state="unverified",
                       detail="The app couldn't look up the reader service principal; the job pre-flight will confirm."))
    else:
        g.append(Check(key="reader_configured", label="Reader service principal",
                       state="ok" if sp else "blocked", detail="" if sp else reader_not_found_message(reader),
                       fix_action="" if sp else "open_settings"))
    job_ok, missing = assess_ready(cfg, installed=True)
    g.append(Check(key="job_ready", label="Assessment job runs as reader",
                   state="ok" if job_ok else "blocked", detail="; ".join(missing),
                   fix_action="" if job_ok else "open_settings"))
    # The app's job sync sets these two up; a failure is for the admin, so no SQL is offered.
    schema_full = f"{deployment_catalog}.{METAMODEL_SCHEMA}"
    vol = _has(effective_privileges(ws, "volume", f"{schema_full}.{RUNS_VOLUME}", reader),
               {"READ_VOLUME", "WRITE_VOLUME"})
    g.append(Check(key="runs_volume", label="Runs volume", state=vol,
                   detail=f"The reader can't read and write {schema_full}.{RUNS_VOLUME}." if vol == "blocked" else "",
                   fix_action=ADMIN_HELP if vol == "blocked" else ""))
    mm_schema = _has(effective_privileges(ws, "schema", schema_full, reader), {"USE_SCHEMA"})
    g.append(Check(key="metamodel_access", label="Deployment _metamodel schema", state=mm_schema,
                   detail=f"The reader can't use {schema_full}." if mm_schema == "blocked" else "",
                   fix_action=ADMIN_HELP if mm_schema == "blocked" else ""))
    wh = cfg.warehouse_id
    wstate = warehouse_state(ws, wh, reader, sp) if wh else "blocked"
    g.append(Check(key="warehouse", label="SQL warehouse", state=wstate,
                   detail=("No warehouse configured for assessments." if not wh else
                           "Access may come through a nested group; the job pre-flight will confirm."
                           if wstate == "unverified" else ""),
                   fix_action="" if wstate == "ok" else "warehouse_permissions"))
    global_blocked = any(c.state == "blocked" for c in g)

    out: list[DomainReadiness] = []
    for d, sources in domains:
        phys = domain_schema_name(d.database_name, d.name)
        mm = resolve_metamodel_location(ws, version.uc_catalog, phys)
        checks = [Check(key="metamodel", label="Metamodel", state="ok" if mm else "blocked",
                        detail=(mm.fqn + (f" ({mm.prefix}*)" if mm.prefix else "")) if mm
                        else f"No metamodel found in {version.uc_catalog}.")]
        # One model_read check covers the physical schema and (when different) the metamodel schema.
        schemas = [phys] + ([mm.schema] if mm and mm.schema != phys else [])
        checks.append(_read_check(ws, "model_read", "Model catalog", reader, version.uc_catalog, schemas))
        for s in sources:
            checks.append(_read_check(ws, f"bronze:{s.source_name}", f"Bronze {s.source_name}",
                                      reader, s.catalog_name, [s.schema_name]))
        out.append(DomainReadiness(domain_id=d.id, domain_name=d.name, checks=checks,
                                   blocked=global_blocked or any(c.state == "blocked" for c in checks)))
    return ReadinessOut(global_checks=g, domains=out)


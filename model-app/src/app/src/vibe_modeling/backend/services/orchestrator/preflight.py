"""The run pre-flight shared by ``POST /runs/validate`` and ``POST /runs``.

:func:`run_preflight` is the one entry point: it normalizes the request, runs
the three levels of design addendum §4.2 (prerequisites, intent, preparation)
and returns a :class:`Preflight`. Validate returns its issues; create takes
the business lock between levels 1 and 2 (held until its Run row commits),
raises its first refusal (:meth:`Preflight.raise_refusal`), starts its DAG
and, right before the Run row, runs level 3 (:meth:`Preflight.prepare`). The checks it
calls (metamodel schema and parent probes, the target-catalog clash,
vibe-scope and Dry Run, the agent-marker gate, the dispatch catalog's
registry checks and the install and uninstall confirmations) live here too.
"""

import logging
import re
import threading
import time
from dataclasses import dataclass, field
from typing import TYPE_CHECKING, Any, Optional

from fastapi import HTTPException
from sqlmodel import select

from ..._compile import compile_inputs
from ...core import (
    resolve_install_target_catalog,
    resolve_metamodel_catalog,
    resolve_run_target_catalog,
    resolve_uninstall_target_catalog,
)
from ...core._errors import config_missing_error, config_requirement_key, needs_confirmation_error
from ...core._names import normalize_scope
from ...core._runs import BusinessBusy, active_run_for_business, active_run_message, lock_business_for_run
from ...core._vibe_scope import run_scope_domains
from ...db_models import ModelVersion
from ...error_sanitization import AppMessage
from ...job_launcher import widget_value_to_ascii
from ...models import Intent, IssueOut, RunIn
from ...routes._helpers import (
    _validate_next_vibe_ids,
    notebook_access,
    require_config,
    resolve_warehouse_id,
)
from .. import metamodel_setup as _setup
from ..metamodel_registry import invisible_metamodel_refusal, setup_error_message
from ..operations import get as _operations_registry_get
from . import validate as _orch_validate

if TYPE_CHECKING:
    from sqlmodel import Session

    from ...db_models import AgentConfig
    from ...models import CompileOut
    from ._types import Issue
    from .dag import Dag

logger = logging.getLogger(__name__)


def _resolve_parent_model_version(
    business_id: str, data: RunIn, intent: Intent, session
) -> Optional[ModelVersion]:
    """Pick the ``ModelVersion`` an orchestrator-routed run targets.

    All four simple intents (vibe-iterate, install, uninstall,
    generate-samples) operate on a specific version. The user-facing
    contract: when ``data.version_id`` is supplied we use that row;
    otherwise we fall back to the latest completed version on the
    business so the model-version page can submit "install latest"
    without re-resolving the id client-side.
    """
    parent_mv: Optional[ModelVersion] = None
    if data.version_id:
        parent_mv = session.get(ModelVersion, data.version_id)
    if parent_mv is not None:
        return parent_mv
    return session.exec(
        select(ModelVersion)
        .where(
            ModelVersion.business_id == business_id,
            ModelVersion.status == "completed",
        )
        .order_by(ModelVersion.version.desc())
    ).first()


def _issue_to_out(issue) -> IssueOut:
    """Adapter: orchestrator's :class:`Issue` dataclass → wire shape."""
    return IssueOut(
        field_path=issue.field_path,
        step_index=issue.step_index,
        message=issue.message,
        severity=issue.severity,
        subject=getattr(issue, "subject", None),
        versions=list(getattr(issue, "versions", ()) or ()),
    )


def _apply_default_catalog(business_id: str, data: RunIn, agent_config, session) -> None:
    """Fill ``data.catalog`` for a One Catalog run that names none, before any
    check reads it, so validate and create check the catalog the run will
    target: an install where the version is installed, else where its files
    are; an uninstall where it was last installed; any other run the
    configured metamodel catalog."""
    cataloging_style = (data.cataloging_style or "One Catalog").strip()
    if cataloging_style != "One Catalog" or (data.catalog or "").strip():
        return
    intent_value = data.intent.value if data.intent is not None else ""
    if intent_value in (Intent.INSTALL.value, Intent.UNINSTALL.value):
        target_mv = _resolve_parent_model_version(business_id, data, data.intent, session)
        resolve = (
            resolve_install_target_catalog
            if intent_value == Intent.INSTALL.value
            else resolve_uninstall_target_catalog
        )
        data.catalog = resolve(data, target_mv, agent_config)
    else:
        data.catalog = resolve_run_target_catalog(data, agent_config)


def _resolve_iterate_parent_version(
    business_id: str, data: RunIn, session
) -> Optional[ModelVersion]:
    """Resolve an iterate's parent ``ModelVersion`` the way the create handler
    does: explicit ``version_id`` / ``parent_version_id`` wins, else the latest
    completed ECM on the business. Single source of truth so the parent-scope
    gate and the parent-metamodel gate resolve identically.

    Distinct from :func:`_resolve_parent_model_version` (the orchestrator's
    any-scope latest-completed resolver that ignores ``parent_version_id``);
    this one is the ECM-parent resolver the vibe-new-ecm-mvm scope gate uses.
    """
    parent_id = data.version_id or data.parent_version_id
    parent_mv: Optional[ModelVersion] = None
    if parent_id:
        parent_mv = session.get(ModelVersion, parent_id)
    if parent_mv is None:
        parent_mv = session.exec(
            select(ModelVersion)
            .where(
                ModelVersion.business_id == business_id,
                ModelVersion.status == "completed",
                ModelVersion.scope.in_(["", "ecm"]),
            )
            .order_by(ModelVersion.version.desc())
        ).first()
    return parent_mv


# Schemas that are not "user data" for clash-detection purposes:
# - ``information_schema`` / ``default``: UC-builtin
# - ``_metamodel``: the agent's own bookkeeping schema, present in every
#   deployment catalog the agent has ever touched. It survives uninstalls
#   on purpose.
# - ``_metrics``: the agent's metric-views layer; the agent recreates it
#   per run and its presence does not block a fresh new-base-model.
# Anything starting with ``_`` is also treated as agent/system bookkeeping —
# matches the agent's own ``_INTERNAL_SCHEMAS`` + leading-underscore
# convention in ``_early_clash_detection``.
_SYSTEM_SCHEMAS_DEFAULT_OK = frozenset({
    "information_schema", "default", "_metamodel", "_metrics",
})

# Intents that build new schemas under the deployment catalog and therefore
# need the pre-flight clash check. ``vibe-iterate`` is included because it
# can re-emit the parent's schemas at a new version int — which clashes if
# stale per-version schemas were left behind by a prior partial run.
_CLASH_CHECK_INTENTS = frozenset({
    Intent.NEW_BASE_MODEL.value,
    Intent.VIBE_NEW_ECM_MVM.value,
    Intent.VIBE_ITERATE.value,
    Intent.INSTALL.value,
})


def _resolve_clash_check_prefixes(data: RunIn) -> list[tuple[str, str]]:
    """Return the per-scope prefixes the run will write under, as
    ``[(field_path, prefix), ...]``.

    Defaults mirror ``orchestrator.dag_factories._unified``:

    - One Catalog → ``ecm_schema_prefix="ecm_"`` and
      ``mvm_schema_prefix="mvm_"`` when the user didn't override them.
    - Catalog per Division/Domain → both empty by default; per-scope
      catalog naming already isolates ECM from MVM.

    For ``vibe-iterate`` we additionally include ``schema_prefix`` (the
    legacy single-prefix field).

    Empty effective prefixes are filtered out — the check can't enumerate
    "every schema" without a prefix anchor (and the agent's own clash
    detection is the backstop for that case).
    """
    cataloging_style = (data.cataloging_style or "One Catalog").strip()
    intent_value = data.intent.value if data.intent is not None else ""

    out: list[tuple[str, str]] = []

    # ECM + MVM scopes (new-base-model and vibe-new-ecm-mvm). Use explicit
    # user value when supplied, else the cataloging-style default.
    if intent_value in (Intent.NEW_BASE_MODEL.value, Intent.VIBE_NEW_ECM_MVM.value):
        ecm_explicit = data.ecm_schema_prefix
        ecm_pref = (
            ecm_explicit
            if ecm_explicit is not None
            else ("ecm_" if cataloging_style == "One Catalog" else "")
        )
        mvm_explicit = data.mvm_schema_prefix
        mvm_pref = (
            mvm_explicit
            if mvm_explicit is not None
            else ("mvm_" if cataloging_style == "One Catalog" else "")
        )
        if ecm_pref:
            out.append(("ecm_schema_prefix", ecm_pref))
        if mvm_pref:
            out.append(("mvm_schema_prefix", mvm_pref))

        # Catalog-per-Division / Catalog-per-Domain: the per-scope ECM/MVM
        # prefixes are empty (catalogs themselves isolate scopes), so the
        # filter anchor is the user's ``catalog_prefix`` instead. Match the
        # agent's catalog-level enumeration in ``_early_clash_detection``.
        if cataloging_style != "One Catalog":
            cat_prefix = (data.catalog_prefix or "").strip()
            if cat_prefix:
                out.append(("catalog_prefix", cat_prefix))

    # vibe-iterate uses the legacy single ``schema_prefix`` (no per-scope
    # split for the simple branch).
    if intent_value == Intent.VIBE_ITERATE.value:
        single = (data.schema_prefix or "").strip()
        if single:
            out.append(("schema_prefix", single))

    return out


def _suggest_free_prefix(used_prefixes: set[str], base: str) -> str:
    """Suggest a free prefix derived from ``base`` (e.g. ``ecm_``) that
    doesn't collide with any of ``used_prefixes`` (lower-cased)."""
    used = {p.lower() for p in used_prefixes}
    base_l = base.lower()
    # Try base + "v2_", "v3_", … which the user can rename freely.
    for n in range(2, 100):
        candidate = f"{base_l}v{n}_"
        if candidate not in used:
            return candidate
    return f"{base_l}new_"


def _metamodel_owned_schemas(
    session: "Session",
    business_id: str,
    scope: str,
    target_catalog: str,
    prefix: str = "",
) -> tuple[set[str], bool]:
    """Return the set of schema names this business has previously
    deployed under ``scope``, plus a flag for "a prior install completed".

    Returns ``(owned_database_names, has_completed_install_in_catalog)``:

    - ``owned_database_names`` — the physical schema of each
      ``Domain.database_name`` across every ModelVersion for this business
      + scope (``services.schema_names.physical_schema_name`` with
      ``prefix``: 5.3.3 names already carry it, older logical names get it). These
      are the explicit "we own this schema" records the model_sync layer
      mirrors from the agent's metamodel table.
    - ``has_completed_install_in_catalog`` — ``True`` if a completed Run
      row exists for this business whose ``parameters_json`` mentions the
      target catalog. Used as a fallback ownership signal when the
      Domain mirror is empty (model_sync lag) — without it, a partial
      mirror would false-block legitimate re-runs.

    A ModelVersion alone is NOT enough to claim ownership: the unified
    pipeline writes ModelVersion rows at job-launch time, and a
    cancelled/failed pipeline can leave behind a ModelVersion with no
    actual physical schemas. Tying the fallback to a completed Run row +
    catalog mention catches the real "we already deployed here" case
    while staying strict about hostile clashes.
    """
    from ...db_models import Domain, Run

    if not business_id:
        return (set(), False)

    try:
        rows = session.exec(
            select(Domain.database_name)
            .join(ModelVersion, Domain.version_id == ModelVersion.id)
            .where(
                ModelVersion.business_id == business_id,
                ModelVersion.scope == scope,
            )
        ).all()

        completed_runs = session.exec(
            select(Run.parameters_json).where(
                Run.business_id == business_id,
                Run.status == "completed",
            )
        ).all()
    except Exception as exc:  # noqa: BLE001
        logger.warning(
            "Pre-flight catalog clash — metamodel lookup failed for "
            "business=%r scope=%r: %s",
            business_id, scope, exc,
        )
        return (set(), False)

    from ..schema_names import physical_schema_name

    owned = {physical_schema_name(r, prefix) for r in rows if r}
    target_lower = target_catalog.lower() if target_catalog else ""
    has_completed = False
    if target_lower:
        for params_json in completed_runs:
            if not params_json:
                continue
            if target_lower in params_json.lower():
                has_completed = True
                break
    return (owned, has_completed)


# Intents whose dispatch reads/writes the agent's ``_metamodel`` schema
# under the target catalog. ``import-from-volume`` creates the schema
# implicitly via the sync step (no pre-existing requirement), and the
# stub intents are rejected upstream. Everything else uses _metamodel
# as the model.json / Delta-table root.
_METAMODEL_REQUIRED_INTENTS = frozenset({
    Intent.NEW_BASE_MODEL.value,
    Intent.VIBE_ITERATE.value,
    Intent.VIBE_NEW_ECM_MVM.value,
    Intent.INSTALL.value,
    Intent.UNINSTALL.value,
})


# The parent-metamodel count per (catalog, segment, version): every outcome
# is kept PARENT_METAMODEL_TTL_SECONDS and at most one count per key is in
# flight, so validate (every form change) queries the warehouse at most once a
# minute per version. Create reuses only a positive count.
PARENT_METAMODEL_TTL_SECONDS = 60.0
# Validate's statement wait; the statement is cancelled when it runs longer.
PARENT_METAMODEL_VALIDATE_WAIT = "10s"
PARENT_METAMODEL_CREATE_WAIT = "30s"
_PRESENT, _ABSENT, _UNCHECKED = "present", "absent", "unchecked"
_parent_metamodel_seen: dict[tuple[str, str, str], tuple[float, str]] = {}
_parent_metamodel_in_flight: set[tuple[str, str, str]] = set()
# A warehouse read as not running, kept this long before validate reads again.
WAREHOUSE_STOPPED_TTL_SECONDS = 20.0
_warehouse_stopped: dict[str, float] = {}
_parent_metamodel_lock = threading.Lock()


def clear_preflight_caches() -> None:
    """Forget the kept parent-metamodel counts (tests)."""
    with _parent_metamodel_lock:
        _parent_metamodel_seen.clear()
        _parent_metamodel_in_flight.clear()
        _warehouse_stopped.clear()


# Intents whose run reads its PARENT model from `_metamodel` at version
# resolution (the agent's `_version_exists` gate). A parent with zero
# `_metamodel.business` rows fails deep inside the run with a confusing
# "version does not exist"; the preflight turns that into an actionable
# blocker. Deliberately intent-only: NEW_BASE_MODEL has no parent;
# INSTALL/UNINSTALL read model.json from the Volume, not the
# `_metamodel`-first version gate.
_PARENT_METAMODEL_GATED_INTENTS = frozenset({
    Intent.VIBE_ITERATE.value,
    Intent.VIBE_NEW_ECM_MVM.value,
})


def _check_metamodel_parent_version_present(
    business_id: str,
    data: RunIn,
    agent_config: Optional["AgentConfig"],
    session: "Session",
    ws,
    *,
    live: bool,
) -> Optional[IssueOut]:
    """Refuse to dispatch a parent-reading iterate when the parent version has
    no ``_metamodel.business`` rows.

    The agent resolves its parent model ONLY from
    ``<catalog>._metamodel.business`` on iterate / new-ecm-mvm runs; a version
    that was kickstarted/downloaded before seeding (or whose seed failed) has
    none, so the run would fail deep at version resolution. This is the
    belt-and-suspenders read-time gate on top of the write-time seed.

    Intent-only gate (``_PARENT_METAMODEL_GATED_INTENTS``). Lenient: an
    unconfigured warehouse/catalog skips it, and a count that could not be
    read is a "couldn't check" warning, never a blocker. Only a SUCCESSFUL
    query returning zero rows blocks. Every outcome is kept
    ``PARENT_METAMODEL_TTL_SECONDS`` and one count per version is in flight
    at a time. Validate (``live=False``) does not wake a stopped warehouse,
    waits ``PARENT_METAMODEL_VALIDATE_WAIT`` and then cancels the statement;
    create counts again unless a positive count is kept.
    """
    if data.intent is None or data.intent.value not in _PARENT_METAMODEL_GATED_INTENTS:
        return None
    if agent_config is None:
        return None
    # The agent resolves the parent from the dispatch catalog's _metamodel.
    # The catalog comes from the request: one that is not a plain identifier
    # never reaches SQL (lenient, like every other skip here).
    from ...core._sql import safe_identifier

    catalog = resolve_run_target_catalog(data, agent_config)
    if not catalog or ws is None:
        return None
    try:
        table = ".".join(safe_identifier(p) for p in (catalog, "_metamodel", "business"))
    except ValueError:
        return None

    from ...core._names import agent_business_segment, escape_sql_literal
    from ...core._warehouse import get_warehouse_id
    from ...db_models import Business

    warehouse_id = get_warehouse_id(session)
    if not warehouse_id:
        return None

    parent_mv = _resolve_iterate_parent_version(business_id, data, session)
    if parent_mv is None:
        # No parent to check - the intent's own parent requirement fires
        # elsewhere; this gate only speaks to a resolved-but-unseeded parent.
        return None

    business = session.get(Business, business_id)
    if business is None:
        return None
    seg = agent_business_segment(business.name)
    if not seg:
        return None

    key = (catalog.lower(), seg.lower(), str(parent_mv.version))
    sql = (
        f"SELECT COUNT(*) AS n FROM {table} "
        f"WHERE LOWER(business) = LOWER('{escape_sql_literal(seg)}') "
        f"AND version = '{escape_sql_literal(str(parent_mv.version))}'"
    )
    label = f"{_version_label(parent_mv)} in '{catalog}'"
    now = time.monotonic()
    with _parent_metamodel_lock:
        kept = _parent_metamodel_seen.get(key)
        outcome = kept[1] if kept is not None and kept[0] > now else None
        if outcome is not None and live and outcome != _PRESENT:
            outcome = None
        if outcome is None and not live and key in _parent_metamodel_in_flight:
            return _parent_unchecked(f"Checking that {label} has agent metamodel data; "
                                     "the run checks again when it starts.")
        if outcome is None:
            _parent_metamodel_in_flight.add(key)
    if outcome is None:
        try:
            if not live and not _warehouse_running(ws, warehouse_id):
                # Validate doesn't wake a stopped warehouse; create checks.
                return _parent_unchecked(
                    f"Not checked that {label} has agent metamodel data: the SQL warehouse "
                    "is not running. The run checks it when it starts."
                )
            outcome = _parent_count(ws, warehouse_id, sql, live=live)
            with _parent_metamodel_lock:
                _parent_metamodel_seen[key] = (time.monotonic() + PARENT_METAMODEL_TTL_SECONDS, outcome)
        finally:
            with _parent_metamodel_lock:
                _parent_metamodel_in_flight.discard(key)

    if outcome == _PRESENT:
        return None
    if outcome == _UNCHECKED:
        return _parent_unchecked(f"Couldn't check that {label} has agent metamodel data.")
    return IssueOut(
        field_path="version_id",
        step_index=-1,
        message=(
            "This model version has no agent metamodel data, so it can't be "
            "iterated. Re-run the download/kickstart or re-sync the version, "
            "then try again."
        ),
        severity="blocker",
    )


def _parent_unchecked(message: str) -> IssueOut:
    return IssueOut(field_path="version_id", step_index=-1, message=message, severity="warning")


def _warehouse_running(ws, warehouse_id: str) -> bool:
    """Whether the warehouse is running. A "not running" answer (or an
    unreadable state) is kept ``WAREHOUSE_STOPPED_TTL_SECONDS``, so validate
    reads the state of a stopped warehouse at most that often."""
    from ...oob_detector import warehouse_is_running

    with _parent_metamodel_lock:
        stopped_until = _warehouse_stopped.get(warehouse_id)
    if stopped_until is not None and stopped_until > time.monotonic():
        return False
    try:
        running = warehouse_is_running(ws, warehouse_id)
    except Exception as exc:  # noqa: BLE001 - unknown state: don't wake it
        logger.warning("Could not read the state of SQL warehouse %r: %s", warehouse_id, exc)
        running = False
    with _parent_metamodel_lock:
        if running:
            _warehouse_stopped.pop(warehouse_id, None)
        else:
            _warehouse_stopped[warehouse_id] = time.monotonic() + WAREHOUSE_STOPPED_TTL_SECONDS
    return running


def _parent_count(ws, warehouse_id: str, sql: str, *, live: bool) -> str:
    """``_PRESENT`` / ``_ABSENT`` from one count, ``_UNCHECKED`` when it could
    not be read (any ``SqlStatementError``, a missing table included). The
    server cancels the statement at the end of its one wait."""
    from ...core._sql import SqlStatementError, scalar

    try:
        n = scalar(
            ws, warehouse_id, sql,
            wait_timeout=PARENT_METAMODEL_CREATE_WAIT if live else PARENT_METAMODEL_VALIDATE_WAIT,
            on_timeout="server_cancel",
        )
        if n is None:
            return _UNCHECKED
        return _PRESENT if int(n) > 0 else _ABSENT
    except (SqlStatementError, TypeError, ValueError):  # unchecked, never a refusal
        return _UNCHECKED


def _check_target_catalog_clash(
    business_id: str,
    data: RunIn,
    agent_config: Optional["AgentConfig"],
    session: "Session",
    ws,
) -> list[IssueOut]:
    """Refuse to dispatch a run that would create new schemas where
    user-data schemas already live under the same prefix.

    Broadened over the original (PR #176) narrow check: the original only
    rejected when the user named the *exact* schemas the run was about to
    create; the agent's own ``_early_clash_detection`` (see
    ``modelling_agent/agent/dbx_vibe_modelling_agent.ipynb``) refuses on
    *any* schema under the configured prefix that doesn't have a matching
    metamodel record. Without parity, the user could submit a run that
    looks fine to the App and then aborts mid-flight with the agent's
    "PHYSICAL DEPLOYMENT CLASH DETECTED" error. Spec §F5 dev.

    Algorithm (matches the agent's heuristic branch):

    1. Resolve effective per-scope prefixes (``ecm_schema_prefix``,
       ``mvm_schema_prefix``, or legacy ``schema_prefix`` for vibe-iterate).
    2. Enumerate ``ws.schemas.list(catalog_name=target_catalog)``.
    3. Filter schemas matching the prefix, minus preserved bookkeeping
       schemas (``_metamodel``, ``_metrics``, ``default``,
       ``information_schema``, anything starting with ``_``).
    4. Subtract schemas that already match a stored ``Domain.database_name``
       for this business+scope+catalog (re-install of our own model).
    5. Anything remaining is a hostile clash → blocker.

    Returns a list of blockers (one per scope that clashes) — empty when
    the catalog is clean. Returning a list (vs. ``Optional``) lets the
    form surface ECM and MVM clashes side-by-side instead of staggering
    them across two submits.
    """
    intent_value = data.intent.value
    if intent_value not in _CLASH_CHECK_INTENTS:
        return []

    target_catalog = resolve_run_target_catalog(data, agent_config)
    if not target_catalog:
        return []
    if ws is None:
        return []

    prefixes = _resolve_clash_check_prefixes(data)

    try:
        schemas = list(ws.schemas.list(catalog_name=target_catalog))
    except Exception as exc:  # noqa: BLE001
        logger.warning(
            "Pre-flight catalog clash check skipped — could not list "
            "schemas in %r: %s",
            target_catalog,
            exc,
        )
        return []

    # Lower-case for case-insensitive matching (UC schemas are
    # case-insensitive identifiers).
    schema_names_lower = sorted({
        (s.name or "").lower()
        for s in schemas
        if s.name
    })

    # Bookkeeping schemas the agent owns — never user clashes.
    def _is_preserved(name: str) -> bool:
        if name in _SYSTEM_SCHEMAS_DEFAULT_OK:
            return True
        if name.startswith("_"):  # _metamodel, _metrics, etc.
            return True
        return False

    candidate_schemas = [n for n in schema_names_lower if not _is_preserved(n)]

    if intent_value == Intent.INSTALL.value:
        return _install_schema_clash(
            business_id, data, session, target_catalog, set(candidate_schemas),
        )

    if not prefixes:
        # No anchor prefix to filter on. For One Catalog + new-base-model
        # this is unsafe IF the catalog already contains user schemas —
        # without a prefix the run's ECM/MVM schemas would land at the
        # catalog root and stomp on whatever's there (the bug that
        # motivated this gate). When the user explicitly overrode both
        # prefixes to empty AND the catalog is empty, we allow it (they
        # know what they're doing).
        cataloging_style_2 = (data.cataloging_style or "One Catalog").strip()
        if (
            intent_value in (Intent.NEW_BASE_MODEL.value, Intent.VIBE_NEW_ECM_MVM.value)
            and cataloging_style_2 == "One Catalog"
            and candidate_schemas
        ):
            sample = ", ".join(candidate_schemas[:5])
            more = "" if len(candidate_schemas) <= 5 else (
                f" (+{len(candidate_schemas) - 5} more)"
            )
            return [IssueOut(
                field_path="ecm_schema_prefix",
                step_index=-1,
                message=(
                    f"A schema prefix is required for One Catalog "
                    f"{intent_value} runs when the deployment catalog "
                    f"is non-empty. Target catalog {target_catalog!r} "
                    f"already contains {len(candidate_schemas)} user "
                    f"schema(s): {sample}{more}. Set "
                    "`ecm_schema_prefix` and `mvm_schema_prefix` (or "
                    "leave the defaults of `ecm_` / `mvm_`) to isolate "
                    "this run, or pick an empty deployment catalog."
                ),
                severity="blocker",
            )]
        # Other modes (Catalog per Division/Domain without `catalog_prefix`,
        # or vibe-iterate without a legacy prefix) — agent's own clash
        # detection is the backstop.
        return []

    issues: list[IssueOut] = []

    for field_path, prefix in prefixes:
        prefix_l = prefix.lower()
        matching = [n for n in candidate_schemas if n.startswith(prefix_l)]
        if not matching:
            continue

        # Determine scope label for metamodel lookup.
        if field_path == "ecm_schema_prefix":
            scope = "ecm"
        elif field_path == "mvm_schema_prefix":
            scope = "mvm"
        elif field_path == "catalog_prefix":
            # Catalog-per-Division/Domain enumerates catalogs by prefix
            # across BOTH scopes — accept either ECM or MVM as ownership
            # evidence.
            scope = None
        else:
            # vibe-iterate's single prefix: the schemas are the base
            # version's own, so ownership is read on the base's scope (a
            # vibe of an MVM writes its ``mvm_`` schemas). The agent skips
            # its early clash detection for ``vibe modeling of version``
            # and runs the ownership-aware teardown instead (nb 8117-8125),
            # so the business's own schemas must not block here.
            base = _resolve_parent_model_version(business_id, data, Intent.VIBE_ITERATE, session)
            scope = (
                normalize_scope(data.scope or "")
                or normalize_scope(getattr(base, "scope", "") or "")
                or "ecm"
            )

        if scope is None:
            ecm_owned, ecm_prior = _metamodel_owned_schemas(
                session, business_id, "ecm", target_catalog,
            )
            mvm_owned, mvm_prior = _metamodel_owned_schemas(
                session, business_id, "mvm", target_catalog,
            )
            registered = ecm_owned | mvm_owned
            has_prior_install = ecm_prior or mvm_prior
        else:
            registered, has_prior_install = _metamodel_owned_schemas(
                session, business_id, scope, target_catalog, prefix_l,
            )
        # If a prior ModelVersion exists for this business+scope and the
        # Domain mirror is empty (or partial), trust the prior install to
        # own any matching-prefix schemas. Only when the business has
        # never deployed this scope do we treat unregistered prefix-
        # matches as a hostile clash. This mirrors the agent's metamodel-
        # aware fast path while staying robust to mirror lag.
        if has_prior_install and not registered:
            continue
        unmatched = [n for n in matching if n not in registered]
        if not unmatched:
            continue

        sample = ", ".join(unmatched[:5])
        more = "" if len(unmatched) <= 5 else f" (+{len(unmatched) - 5} more)"
        # Suggest a free prefix to nudge the user toward isolation.
        used = {n.split("_", 1)[0] + "_" for n in candidate_schemas if "_" in n}
        suggestion = _suggest_free_prefix(used, prefix)

        issues.append(IssueOut(
            field_path=field_path,
            step_index=-1,
            message=(
                f"Target catalog {target_catalog!r} already contains "
                f"{len(unmatched)} schema(s) under prefix {prefix!r}: "
                f"{sample}{more}. A {intent_value} run would clash with "
                "them. To proceed, either:\n"
                f"  - change the schema prefix (e.g. {suggestion!r}),\n"
                "  - drop the existing schemas, or\n"
                "  - target a different deployment catalog."
            ),
            severity="blocker",
        ))

    return issues


def install_writes(session, data: RunIn, target_mv: ModelVersion, target_catalog: str) -> set[str]:
    """The schemas an install of ``target_mv`` into ``target_catalog``
    writes (names per :func:`_install_schema_clash`): a scoped file or a Dry
    Run draft keeps its stored names with its suffix; any other install its
    stored names, or an in-place reinstall's recorded prefix
    (:func:`inplace_install_prefix`). A typed prefix other than the file's
    is refused (:func:`_typed_prefix_blocker`)."""
    from ..dispatched_widgets import dispatched_schema_affixes_for_version
    from ..schema_names import install_schema_names, pick_affix

    if target_mv.scope_fence_mode is not None or target_mv.dry_run:
        _, suffixes = dispatched_schema_affixes_for_version(session, target_mv.id)
        suffix = data.schema_suffix or pick_affix(suffixes, "")
        return install_schema_names(session, target_mv.id, prefix="", suffix=suffix)
    recorded = inplace_install_prefix(
        session, target_mv, target_catalog, (data.cataloging_style or "One Catalog").strip() or "One Catalog",
    )
    return install_schema_names(session, target_mv.id, prefix=recorded or "", suffix="")


def _install_schema_clash(
    business_id: str,
    data: RunIn,
    session: "Session",
    target_catalog: str,
    present: set[str],
) -> list[IssueOut]:
    """The install case of :func:`_check_target_catalog_clash`: existing
    schemas the install writes into that this business does not own in the
    target catalog.

    What the agent does with them depends on the file:

    * an unscoped install never runs the agent's ownership check:
      ``install model`` returns (nb 110016) before ``step_setup_and_clean``,
      and ``_check_physical_deployment_clash`` takes its legacy path, which
      soft-replaces (``CREATE OR REPLACE TABLE``) when the catalog's registry
      has the version, the version is newer than the business's newest
      there, or the version is above 1 and the catalog has a ``_metamodel``;
      otherwise it refuses. So the app asks: a ``confirm`` issue
      ``install_overwrites_schemas:<version>:<catalog>`` naming each schema
      and its owner;
    * a scoped install on its ``base_match`` path sets
      ``_schema_ownership`` (nb 106979) and the agent's
      ``_schema_ownership_gate`` (nb 8398-8434) refuses any schema it does
      not own, so the app refuses too (a blocker). That snapshot skips the
      in-flight version (nb 8356-8360), so here the installed version itself
      owns nothing.

    Dry Run drafts own nothing on either path: the snapshot skips
    ``dry_run`` registry rows (nb 8374), and a draft deployed nothing.

    Names follow ``services.schema_names``. The install's own
    (``install_schema_names``): an ordinary install sends the prefix of the
    version's model.json (``dag_factories._simple.install_schema_prefix``;
    a typed prefix other than the file's is refused,
    :func:`_typed_prefix_blocker`), which its stored names carry, and no
    ``schema_suffix`` (``_install_conventions.effective_install_params``
    drops it), so it writes its stored names; a ``_vibe_scope`` file or a
    Dry Run draft is installed with the file's own conventions, so its
    stored names are kept, with the suffix its generation was dispatched
    with (or the request's). Every other version installed in the catalog
    now, before (any install row), or last installed there (``uc_catalog``;
    ``_version_lifecycle._ever_installed_in``) holds ``recorded_schema_names``.
    A version with only its files and registry rows there (a download, an
    import, a kickstart) owns nothing: the app seeds its rows ``dry_run``,
    which the agent's ownership snapshot skips (nb 7926-7927). An unscoped
    install counts its own recorded names as this business's, as the
    agent's exact-row soft-replace does.

    Refused first, a blocker: another scope of this business installed in
    the catalog under some of the same names
    (:func:`source_industry.same_business_scope_clash`). The source-industry
    versions the run uninstalls first (Rule 1,
    :func:`source_industry.industry_replacements`) own nothing here.
    """
    from ...db_models import Business
    from ..operations._version_lifecycle import _ever_installed_in, is_draft
    from ..schema_names import recorded_schema_names
    from .source_industry import industry_replacements, same_business_scope_clash

    target_mv = _resolve_parent_model_version(business_id, data, Intent.INSTALL, session)
    if target_mv is None:
        return []
    scoped = target_mv.scope_fence_mode is not None
    writes = install_writes(session, data, target_mv, target_catalog)
    clash = same_business_scope_clash(session, target_mv, target_catalog, writes)
    if clash is not None:
        return [clash]
    # The run uninstalls these source-industry versions first (Rule 1), and
    # with them the schemas they share with this install.
    replacements = industry_replacements(session, data, target_mv, target_catalog, writes)
    replaced = {r.version.id for r in replacements}
    dropped = {n for r in replacements if not r.replaced for n in r.names}
    existing = sorted((writes & present) - dropped)
    if not existing:
        return []

    mine: set[str] = set()
    theirs: dict[str, set[str]] = {}
    for mv, owner in session.exec(
        select(ModelVersion, Business.name)
        .join(Business, ModelVersion.business_id == Business.id)
        .where(_ever_installed_in(target_catalog, fold_case=True))
    ).all():
        if is_draft(mv) or (scoped and mv.id == target_mv.id) or mv.id in replaced:
            continue
        if mv.id == target_mv.id:
            names = writes
        else:
            names = recorded_schema_names(session, mv.id, mv.scope, target_catalog)
        names &= set(existing)
        if mv.business_id == business_id:
            mine |= names
        else:
            for name in names:
                theirs.setdefault(name, set()).add(owner)

    refused = []
    for name in existing:
        if name in mine and name not in theirs:
            continue
        owners = sorted(theirs.get(name, ()))
        who = f"owned by {', '.join(owners)}" if owners else "not recorded by any business"
        if name in mine and owners:
            who += " and by this business"
        refused.append(f"{name} ({who})")
    if not refused:
        return []
    listed = "; ".join(refused[:10])
    more = "" if len(refused) <= 10 else f" (+{len(refused) - 10} more)"
    if scoped:
        return [IssueOut(
            field_path="catalog",
            step_index=-1,
            message=(
                f"The agent refuses this install: catalog {target_catalog!r} already has "
                f"{len(refused)} schema(s) it writes into that this business does not own "
                f"there: {listed}{more}. Its ownership check runs for scoped installs. "
                + (
                    "Install into another catalog."
                    if any(name in mine and name in theirs for name in existing)
                    else "Install into another catalog, or drop those schemas first."
                )
            ),
            severity="blocker",
        )]
    from .validate import install_overwrites_subject

    return [IssueOut(
        field_path="catalog",
        step_index=-1,
        message=(
            f"Catalog {target_catalog} already has {len(refused)} schema(s) this install writes "
            f"into that this business does not own there: {listed}{more}. The agent will "
            "replace the tables of this model in them (CREATE OR REPLACE TABLE), losing their "
            "rows, or refuse the install. To keep them, install into another catalog instead."
        ),
        severity="confirm",
        subject=install_overwrites_subject(target_mv.id, target_catalog),
    )]


# Field paths of the vibe-scope / Dry Run preflight blockers. ``create_run``
# maps exactly these to 422 ("your input is wrong"); every other blocker keeps
# its existing 400/409, e.g. the ``version_id`` metamodel-parent blocker.
_VIBE_SCOPE_BLOCKER_FIELD_PATHS = frozenset({
    "vibe_scope",
    "vibe_scope_domains",
    "dry_run",
    "vibe_scope_base",
    "vibe_scope_inputs",
    "vibe_scope_agent",
})


def _scope_status(issue: Optional[IssueOut]) -> int:
    """The status create refuses a blocker with, by its field path: 422 for a
    vibe-scope / Dry Run request-shape blocker, else 400."""
    return 422 if issue is not None and issue.field_path in _VIBE_SCOPE_BLOCKER_FIELD_PATHS else 400


def _scope_blocker(field_path: str, message: str) -> IssueOut:
    return IssueOut(field_path=field_path, step_index=-1, message=message, severity="blocker")


def _version_label(mv: ModelVersion) -> str:
    return f"v{mv.version} {(mv.scope or 'ecm').upper()}"


# The agent's own split of ``business_domains`` (5.3.3, design §3).
_SCOPE_LIST_SEPARATOR_RE = re.compile(r"[,;\n]")


def _unreceivable_domain_message(name: str) -> str:
    return (
        f"The domain name '{name}' has characters the agent cannot receive "
        "(run parameters are sent as plain ASCII), so the agent would not find "
        "this domain. Rename the domain, or run on All domains."
    )


def _collect_vibe_scope_blockers(
    business_id: str, data: RunIn, session: "Session"
) -> list[IssueOut]:
    """The vibe-scope and Dry Run request checks (design §5.3).

    Pure Lakebase reads, no agent or workspace needed, so the caller runs them
    before its agent-not-configured early return. On success it rewrites
    ``data.vibe_scope_domains`` to the base version's stored domain names, so
    the DAG factory dispatches the canonical spelling.
    """
    from ...core._vibe_scope import resolve_scope_domains, scope_key, scoped_base_blocker
    from ...db_models import Domain
    from ...models import VibeScope

    scoped = data.vibe_scope != VibeScope.ALL_DOMAINS
    if not scoped and not data.dry_run and not data.vibe_scope_domains:
        return []

    intent_value = data.intent.value if data.intent is not None else ""
    if (scoped or data.dry_run) and (
        intent_value != Intent.VIBE_ITERATE.value or data.next_vibe_ids
    ):
        return [_scope_blocker(
            "vibe_scope" if scoped else "dry_run",
            "Vibe scope and Dry Run are available for Vibe iteration runs only.",
        )]

    if data.vibe_scope == VibeScope.SOME_SUBDOMAINS:
        return [_scope_blocker(
            "vibe_scope", "Some Subdomains is not supported yet. Choose Some domains."
        )]

    requested = [d.strip() for d in data.vibe_scope_domains if d and d.strip()]
    if not scoped:
        if requested:
            return [_scope_blocker(
                "vibe_scope_domains",
                "Domains are only used with Some domains. Clear the domain list, "
                "or choose Some domains.",
            )]
        return []

    if not requested:
        return [_scope_blocker(
            "vibe_scope_domains", "Pick at least one domain to scope this run to."
        )]

    malformed = [d for d in requested if "." in d or not scope_key(d)]
    if malformed:
        # An entry with no letters or digits may still be a real domain whose
        # name is all non-ASCII; say that rather than "not a domain name".
        stored: set[str] = set()
        if not any("." in d for d in malformed):
            mv = _resolve_parent_model_version(business_id, data, Intent.VIBE_ITERATE, session)
            if mv is not None:
                stored = set(session.exec(
                    select(Domain.name).where(Domain.version_id == mv.id)
                ).all())
        return [
            _scope_blocker("vibe_scope_domains", _unreceivable_domain_message(d))
            if d in stored else
            _scope_blocker(
                "vibe_scope_domains",
                f"'{d}' is not a domain name. Use the name of a domain only, "
                "without a subdomain or product after a dot.",
            )
            for d in malformed
        ]

    blockers: list[IssueOut] = []
    if (data.business_domains or "").strip():
        blockers.append(_scope_blocker(
            "vibe_scope_domains",
            "Business domains and the vibe scope can't both be set; the scope "
            "list is sent as the domains. Clear Business domains.",
        ))

    base_mv = _resolve_parent_model_version(business_id, data, Intent.VIBE_ITERATE, session)
    if base_mv is None:
        blockers.append(_scope_blocker(
            "vibe_scope_base",
            "Scoped runs need a finished model version to start from.",
        ))
        return blockers

    base_domain_names = list(session.exec(
        select(Domain.name).where(Domain.version_id == base_mv.id).distinct()
    ).all())
    canonical, unknown = resolve_scope_domains(requested, base_domain_names)
    for entry, suggestions in unknown:
        hint = f" Did you mean: {', '.join(suggestions)}?" if suggestions else ""
        blockers.append(_scope_blocker(
            "vibe_scope_domains",
            f"'{entry}' is not a domain of {_version_label(base_mv)}.{hint} The agent "
            "would treat it as a new domain and change nothing in the one you meant.",
        ))

    base_message = scoped_base_blocker(session, base_mv)
    if base_message:
        blockers.append(_scope_blocker("vibe_scope_base", base_message))

    if unknown:
        return blockers

    # The agent splits the scope list on [,;\n] and receives ASCII-only
    # widgets, so a stored name must survive both to match its own domain.
    name_blockers: list[IssueOut] = []
    for name in canonical:
        if _SCOPE_LIST_SEPARATOR_RE.search(name):
            name_blockers.append(_scope_blocker(
                "vibe_scope_domains",
                f"The domain name '{name}' contains a comma, semicolon or line "
                "break, which the agent cannot take in a scope list. Rename the "
                "domain, or run on All domains.",
            ))
            continue
        sent_key = scope_key(widget_value_to_ascii(name))
        if not sent_key or sent_key != scope_key(name):
            name_blockers.append(_scope_blocker(
                "vibe_scope_domains", _unreceivable_domain_message(name)
            ))
    if name_blockers:
        return blockers + name_blockers
    data.vibe_scope_domains = canonical

    # Free-text scoped runs (no selected inputs) stay valid; only a selection
    # that the scoped compile reduces to nothing is refused.
    if data.input_ids:
        compiled = compile_inputs(
            session, base_mv.id, data.input_ids, scope_domains=canonical
        )
        if not compiled.included_input_ids:
            blockers.append(_scope_blocker(
                "vibe_scope_inputs",
                f"None of the selected inputs are anchored in {', '.join(canonical)}. "
                "Select feedback on that domain, or widen the scope.",
            ))
    return blockers


def _marker_gated_subject(
    business_id: str, data: RunIn, session: "Session"
) -> Optional[str]:
    """What needs agent ``MIN_AGENT_MARKER_FOR_SCOPE``, or None.

    A scoped or Dry vibe: an older agent ignores both widgets and would run
    unscoped, or deploy a "Dry Run". An install of a Dry Run draft or of a
    file with a ``_vibe_scope`` block (B4 ``install_agent_marker``): an older
    agent has neither path.
    """
    from ...models import VibeScope

    intent_value = data.intent.value if data.intent is not None else ""
    if intent_value == Intent.INSTALL.value:
        target_mv = _resolve_parent_model_version(business_id, data, Intent.INSTALL, session)
        if target_mv is not None and (target_mv.dry_run or target_mv.scope_fence_mode):
            return "install"
        return None
    if data.vibe_scope == VibeScope.ALL_DOMAINS and not data.dry_run:
        return None
    return "vibe"


def _read_identity_apart(session, ws, agent_config, installed_identity):
    """``installed_identity`` in its own session, so a live read stores the
    identity on its own connection and never commits the create's session,
    which holds the business lock here (``_lock_business``; a commit would
    release it)."""
    from sqlmodel import Session as _Session

    from ...db_models import AgentConfig as _AgentConfig

    if agent_config.id is None:
        return installed_identity(session, ws, agent_config)
    with _Session(session.get_bind()) as own:
        cfg = own.get(_AgentConfig, agent_config.id)
        if cfg is None:
            return installed_identity(session, ws, agent_config)
        return installed_identity(own, ws, cfg)


def _check_scope_agent_marker(
    business_id: str,
    data: RunIn,
    agent_config: "AgentConfig",
    session: "Session",
    ws,
    *,
    live: bool,
) -> Optional[IssueOut]:
    """Refuse a run :func:`_marker_gated_subject` names when the configured
    notebook predates ``MIN_AGENT_MARKER_FOR_SCOPE``.

    The marker comes from the identity cache (``core._agent_identity``).
    ``live`` (create) reads the notebook when the cache is older than its TTL
    or was read from another path, in a session of its own
    (:func:`_read_identity_apart`); otherwise (validate) only the stored
    identity is read, never the notebook, and an identity not read yet gives
    no blocker (create reads it). A read error or a missing marker is a
    blocker, never a 500.
    """
    from ...agent_compat import is_newer_tag
    from ...core._agent_identity import (
        _NO_MARKER_ERROR,
        cached_identity_for_current_path,
        installed_identity,
    )
    from ...core._vibe_scope import MIN_AGENT_MARKER_FOR_SCOPE

    gated = _marker_gated_subject(business_id, data, session)
    if gated is None:
        return None
    if live:
        identity = _read_identity_apart(session, ws, agent_config, installed_identity)
    else:
        identity = cached_identity_for_current_path(agent_config)
        if identity.checked_at is None:
            return None
    reported = (identity.marker or "").strip().lstrip("vV")
    if not reported and identity.error and identity.error != _NO_MARKER_ERROR:
        return _scope_blocker(
            "vibe_scope_agent",
            "Could not read the configured agent notebook to check its version.",
        )
    if gated == "install":
        if not reported or is_newer_tag(MIN_AGENT_MARKER_FOR_SCOPE, reported):
            return _scope_blocker(
                "vibe_scope_agent",
                f"Needs agent {MIN_AGENT_MARKER_FOR_SCOPE}. Switch to the bundled agent in Settings.",
            )
        return None
    reinstall = "Switch to the bundled agent in Settings."
    if not reported:
        return _scope_blocker(
            "vibe_scope_agent",
            f"Scoped and Dry runs need agent {MIN_AGENT_MARKER_FOR_SCOPE} or later; "
            f"the configured notebook reports no agent version. {reinstall}",
        )
    if is_newer_tag(MIN_AGENT_MARKER_FOR_SCOPE, reported):
        return _scope_blocker(
            "vibe_scope_agent",
            f"Scoped and Dry runs need agent {MIN_AGENT_MARKER_FOR_SCOPE} or later; "
            f"the configured notebook reports {reported}. {reinstall}",
        )
    return None


# --- The run pre-flight: one entry point, three levels -----------------------
#
# ``run_preflight`` is the one implementation behind ``POST /runs/validate``
# and ``POST /runs`` (design addendum §4.2):
#
# 1. prerequisites: configuration, the agent notebook readable, the warehouse
#    and the catalogs exist, the app's capability in the run's catalog (§4.1);
# 2. intent: what this request asks for in the current state;
# 3. preparation: what create sets up itself, after every check and right
#    before the Run row (conv §6, check then act). Validate reports it with
#    severity ``prepare``.
#
# Validate runs levels 1 and 2 in full and returns every issue in level order;
# the ``confirm`` issues and level 3 follow only when nothing blocks. Create
# runs the same checks in the same order and stops at its first blocker, which
# is therefore validate's first blocker too.


# The agent creates the catalogs a multi-catalog style derives
# (``_ensure_catalog_exists``, nb 7738-7750, called per derived catalog at nb
# 85478); the app checks only the run's own catalog.
_DERIVED_CATALOGS_WARNING = (
    "The {style} style deploys into catalogs the agent derives and creates; the "
    "app checks its access to '{catalog}' only. Creating a catalog needs CREATE "
    "CATALOG on the metastore."
)

# The intents that dispatch the agent against a resolved model version.
_VERSION_BOUND_INTENTS = frozenset({
    Intent.VIBE_ITERATE.value,
    Intent.INSTALL.value,
    Intent.UNINSTALL.value,
})

_AGENT_JOB_MISSING = (
    "The agent job does not exist yet. Open Settings → Agent and save to create it."
)

@dataclass
class _Finding:
    issue: IssueOut
    status: int = 400
    # The HTTPException detail create raises; the message when None.
    detail: Any = None
    # Returned in ``RunOut.warnings`` too (a warning the form already showed
    # and that needs no reminder after the launch is not).
    echo: bool = True


@dataclass
class Preflight:
    """What :func:`run_preflight` found, plus what create needs to go on.

    ``issues`` is the ordered list validate returns. ``dag`` is the validated
    DAG of an orchestrator-routed intent (None for the legacy launch path).
    ``compiled`` and ``selected_next_vibes`` are the request's compiled inputs
    and next-vibe selections; ``parent_mv`` the version the run acts on.
    """

    findings: list[_Finding] = field(default_factory=list)
    dag: Optional["Dag"] = None
    compiled: Optional["CompileOut"] = None
    selected_next_vibes: list = field(default_factory=list)
    next_vibe_error: Optional[str] = None
    parent_mv: Optional[ModelVersion] = None
    _prepare: list[tuple[str, tuple[str, ...]]] = field(default_factory=list)

    @property
    def issues(self) -> list[IssueOut]:
        return [f.issue for f in self.findings]

    @property
    def blocked(self) -> bool:
        return any(f.issue.severity == "blocker" for f in self.findings)

    @property
    def warnings(self) -> list[IssueOut]:
        """The warnings create returns in ``RunOut.warnings``."""
        return [f.issue for f in self.findings if f.issue.severity == "warning" and f.echo]

    def add(
        self, issue: Optional[IssueOut], status: Optional[int] = None, detail: Any = None,
        *, echo: bool = True,
    ) -> None:
        if issue is not None:
            self.findings.append(_Finding(issue, status or _scope_status(issue), detail, echo))

    def included_input_ids(self, data: RunIn) -> list[str]:
        return _included_input_ids(data, self.compiled)

    def raise_refusal(self, data: RunIn) -> None:
        """Create's refusal: the first blocker with its status, else 422
        ``needs_confirmation`` for a ``confirm`` subject the request did not
        list in ``confirmed_issues``."""
        for f in self.findings:
            if f.issue.severity == "blocker":
                raise HTTPException(
                    status_code=f.status,
                    # App-written text; a clash blocker ends in its "To proceed" steps.
                    detail=f.detail if f.detail is not None else AppMessage(f.issue.message),
                )
        _raise_needs_confirmation(data, self.issues)

    def prepare(self, ws) -> None:
        """Level 3 on create: set up what validate reported as ``prepare``.
        Called after every check, right before the Run row is written."""
        for catalog, volumes in self._prepare:
            try:
                _setup.ensure_metamodel_schema_and_volume(ws, catalog, volumes)
            except _setup.MetamodelSetupError as exc:
                raise HTTPException(
                    status_code=400, detail=setup_error_message(ws, catalog, exc, volumes),
                ) from exc


class _Stop(Exception):
    """Create found its first blocker; the remaining checks don't run."""


def run_preflight(
    business_id: str,
    data: RunIn,
    *,
    business,
    agent_config: Optional["AgentConfig"],
    session: "Session",
    ws,
    config,
    user: Optional[str],
    create: bool,
) -> Preflight:
    """The run pre-flight shared by ``POST /runs/validate`` and ``POST /runs``.

    Resolves the default catalog and the base version first; level 2 then
    compiles the selected inputs (and a first model's instructions), so both
    endpoints check the payload create dispatches. Then runs the three levels
    (module comment above). ``create`` stops at the first
    blocker, reads the agent identity live and recomputes the uninstall
    impact; nothing here writes outside the app's database.
    """
    pf = Preflight()
    unknown = _unknown_version_blocker(business_id, data, session)
    if unknown is not None:
        pf.add(unknown, 404, unknown.message)
        return pf
    _normalize_request(business_id, data, business, agent_config, session, pf)

    def check(
        issue: Optional[IssueOut], status: Optional[int] = None, detail: Any = None,
        *, echo: bool = True,
    ) -> None:
        pf.add(issue, status, detail, echo=echo)
        if create and issue is not None and issue.severity == "blocker":
            raise _Stop

    try:
        _level_prerequisites(business_id, data, agent_config, session, ws, config, check)
        if create and business is not None:
            _lock_business(session, business_id, check)
        meta = _level_intent(business_id, data, business, agent_config, session, ws, create, check, pf)
        if pf.blocked:
            return pf
        for issue in _confirm_issues(
            business_id, data, agent_config, session, ws,
            warehouse_id=resolve_warehouse_id(session, config) if config is not None else "",
            user=user, fresh=create,
        ):
            check(issue)
        _level_preparation(data, agent_config, meta, pf)
    except _Stop:
        pass
    return pf


def _unknown_version_blocker(business_id: str, data: RunIn, session) -> Optional[IssueOut]:
    """A blocker for a ``version_id`` or ``parent_version_id`` that is not a
    version of this business. Create answers it with 404 before any row is
    written; without it a run of another intent, or a version of another
    business, reaches the ``runs`` insert and fails on the foreign key."""
    for field_path in ("version_id", "parent_version_id"):
        version_id = getattr(data, field_path, None)
        if not version_id:
            continue
        mv = session.get(ModelVersion, version_id)
        if mv is None or mv.business_id != business_id:
            return _blocker(field_path, "Model version not found")
    return None


def _lock_business(session, business_id: str, check) -> None:
    """Create takes the business lock (``core._runs.lock_business_for_run``)
    after level 1 and before level 2's active-run check, which the lock's
    re-check is. Level 1's workspace reads run before it; the caller commits
    nothing until its Run row is written (a commit releases the lock). A held
    lock propagates its 409 ("Another request for this business is in
    progress"); an active run keeps the level-2 blocker."""
    try:
        lock_business_for_run(session, business_id)
    except BusinessBusy as busy:
        if busy.active_run_id is None:
            raise
        check(_blocker("business_id", busy.message), 409)


# --- Request normalization ------------------------------------------------


def _compile_inputs_into_instructions(session, version_id, data) -> Optional["CompileOut"]:
    """Set ``data.vibe_instructions`` to the compiled agent markdown of the
    selected Vibe Inputs anchored to ``version_id``, and return the compile.

    Inputs are the sole source of run instructions (Task 5 §5/§7). The agent is
    sent ``agent_markdown`` (inline anchors + K1 markers), filtered by the run's
    vibe scope. Returns ``None`` (a no-op) when ``data.input_ids`` is empty or
    there is no version, so the first-model description-mode path (run 1, no
    inputs) and free-text instructions are left untouched.
    """
    input_ids = getattr(data, "input_ids", None) or []
    if not input_ids or not version_id:
        return None
    compiled = compile_inputs(
        session, version_id, input_ids,
        scope_domains=run_scope_domains(data.vibe_scope, data.vibe_scope_domains),
    )
    data.vibe_instructions = compiled.agent_markdown
    return compiled


def _included_input_ids(data, compiled: Optional["CompileOut"]) -> list[str]:
    """The input ids a launch actually sent: the compile's ``included_input_ids``
    (excluded items are never linked, so never consumed). Without a compile
    (no base version to anchor to), every requested id, as before."""
    if compiled is not None:
        return list(compiled.included_input_ids)
    return list(getattr(data, "input_ids", None) or [])


def _run_base_version(business_id: str, data: RunIn, session) -> Optional[ModelVersion]:
    """The version a run of ``data.intent`` acts on, resolved the way its
    create branch does: the ECM parent of a ``vibe-new-ecm-mvm``, the target
    of a version-bound intent (latest completed when none is named), else the
    named ``version_id``."""
    intent_value = data.intent.value if data.intent is not None else ""
    if intent_value == Intent.VIBE_NEW_ECM_MVM.value:
        return _resolve_iterate_parent_version(business_id, data, session)
    if intent_value in _VERSION_BOUND_INTENTS:
        return _resolve_parent_model_version(business_id, data, data.intent, session)
    return session.get(ModelVersion, data.version_id) if data.version_id else None


def _normalize_request(business_id, data, business, agent_config, session, pf: Preflight) -> None:
    """Resolve what every check reads: the default catalog, the base version
    and the next-vibe selections."""
    # Validate and create do not fill or check the conventions a vibe locks
    # (``services/run_defaults``): the run form pre-fills and disables them,
    # and the agent keeps the base's values whatever the request sends. A
    # direct API caller (a future MCP that starts runs) can send other values
    # and is not told they are ignored.
    _apply_default_catalog(business_id, data, agent_config, session)
    pf.parent_mv = _run_base_version(business_id, data, session)
    if data.next_vibe_ids:
        # Agent-proposed next-vibe selections are validated against the base's
        # structured agent ``VibeInput`` rows; unknown ids are a 400 blocker.
        if not (data.version_id or data.parent_version_id):
            pf.next_vibe_error = "next_vibe_ids require a base version_id"
        elif pf.parent_mv is not None:
            try:
                pf.selected_next_vibes = _validate_next_vibe_ids(
                    session, pf.parent_mv.id, data.next_vibe_ids
                )
            except HTTPException as exc:
                pf.next_vibe_error = str(exc.detail)


def _compile_request(data, business, session, pf: Preflight, *, with_inputs: bool) -> None:
    """Set ``data.vibe_instructions`` as create dispatches it."""
    # The selected Vibe Inputs ARE the instructions.
    if with_inputs:
        pf.compiled = _compile_inputs_into_instructions(
            session, pf.parent_mv.id if pf.parent_mv is not None else None, data
        )
    # The first model has no composed inputs: its instructions (the leading
    # generate_ecm step's ``model_vibes`` widget) are the business's detailed
    # description. ``model_vibes`` spills to a Volume file when large (level 3).
    if (
        data.intent == Intent.NEW_BASE_MODEL
        and not (data.vibe_instructions or "").strip()
        and business is not None
    ):
        data.vibe_instructions = (getattr(business, "business_vibes", "") or "").strip()


# --- Level 1: prerequisites -------------------------------------------------


def _level_prerequisites(business_id, data, agent_config, session, ws, config, check) -> None:
    """Configuration, then the workspace objects the run needs."""

    config_blockers = require_config(
        session, config, ["agent_job", "metamodel_catalog", "warehouse"], mode="collect",
    )
    if config_blockers:
        # Create answers with the structured 422 ``config_missing`` payload
        # (every missing key) the other operations emit.
        keys = [config_requirement_key(b.field_path) for b in config_blockers]
        detail = config_missing_error([k for k in keys if k]).detail
        for blocker in config_blockers:
            check(blocker, 422, detail)
    if agent_config is None or not (agent_config.notebook_path or "").strip():
        return
    if not agent_config.job_id:
        check(_blocker("(agent_config.job_id)", _AGENT_JOB_MISSING), 400, _AGENT_JOB_MISSING)
    if ws is None:
        return

    access = notebook_access(ws, agent_config.notebook_path)
    if access.refused is not None:
        check(_blocker("(agent_config.notebook_path)", access.refused), 400, access.refused)
    elif access.unchecked is not None:
        check(_warning("(agent_config.notebook_path)", access.unchecked), echo=False)

    warehouse_id = (agent_config.warehouse_id or "").strip()
    if warehouse_id:
        _check_unechoed_warning(check, _warehouse_issue(ws, warehouse_id))

    metamodel_catalog = resolve_metamodel_catalog(session, config)
    target = resolve_run_target_catalog(data, agent_config)
    missing_catalog = False
    for catalog in dict.fromkeys(c for c in (metamodel_catalog, target) if c):
        issue = _catalog_issue(ws, catalog, configured=catalog == metamodel_catalog)
        missing_catalog = missing_catalog or (issue is not None and issue.severity == "blocker")
        _check_unechoed_warning(check, issue)
    if target and not missing_catalog:
        for issue in _capability_issues(data, target):
            check(issue)


def _blocker(field_path: str, message: str) -> IssueOut:
    return IssueOut(field_path=field_path, step_index=-1, message=message, severity="blocker")


def _check_unechoed_warning(check, issue: Optional[IssueOut]) -> None:
    """``check`` an issue whose warning form is a "couldn't check" note: the
    form shows it, ``RunOut.warnings`` doesn't repeat it after the launch."""
    check(issue, echo=issue is None or issue.severity != "warning")


def _warning(field_path: str, message: str) -> IssueOut:
    return IssueOut(field_path=field_path, step_index=-1, message=message, severity="warning")


def _warehouse_issue(ws, warehouse_id: str) -> Optional[IssueOut]:
    """A blocker when the configured warehouse is gone or hidden from the app.
    Any other error leaves it unchecked, which a warning says."""
    from databricks.sdk.errors import NotFound, PermissionDenied

    try:
        ws.warehouses.get(warehouse_id)
    except (NotFound, PermissionDenied):
        return _blocker(
            "(agent_config.warehouse_id)",
            f"The configured SQL warehouse '{warehouse_id}' does not exist or the app's "
            "service principal can't use it. Pick another one in Settings → Platform.",
        )
    except Exception as exc:  # noqa: BLE001 - unchecked, not refused
        logger.warning("Could not read SQL warehouse %r: %s", warehouse_id, exc)
        return _warning(
            "(agent_config.warehouse_id)",
            f"Couldn't check that the configured SQL warehouse '{warehouse_id}' exists.",
        )
    return None


def _catalog_issue(ws, catalog: str, *, configured: bool) -> Optional[IssueOut]:
    """A blocker when ``catalog`` does not exist (or the app can't see it), a
    warning when it could not be read. The agent would create a missing
    catalog (``_ensure_catalog_exists``, nb 57001-57005); the app refuses
    instead, so a typo never becomes a catalog. ``configured``: the catalog
    is the configured metamodel catalog (not the run form's), fixed in
    Settings."""
    from databricks.sdk.errors import NotFound

    field_path = "(agent_config.deployment_catalog)" if configured else "catalog"
    try:
        ws.catalogs.get(catalog)
    except NotFound:
        fix = (
            "Pick an existing one in Settings → Platform" if configured
            else "Pick an existing catalog"
        )
        what = "The configured metamodel catalog" if configured else "Catalog"
        return _blocker(
            field_path,
            f"{what} '{catalog}' does not exist, or the app's service principal can't "
            f"see it. {fix}, or ask a metastore admin to create it.",
        )
    except Exception as exc:  # noqa: BLE001 - unchecked, not refused
        logger.warning("Could not read catalog %r: %s", catalog, exc)
        return _warning(field_path, f"Couldn't check that catalog '{catalog}' exists.")
    return None


def _capability_issues(data: RunIn, catalog: str) -> list[IssueOut]:
    """The capability rule of design §4.1 in the run's catalog: CREATE_SCHEMA
    when the run creates schemas there (or ``_metamodel`` is absent), else
    use of ``_metamodel`` and ``vol_root``. Checked live: only full positives
    are cached (``core._uc_privileges``)."""
    from ...core import _uc_privileges as privileges

    intent_value = data.intent.value if data.intent is not None else ""
    if intent_value not in _METAMODEL_REQUIRED_INTENTS:
        return []
    style = (data.cataloging_style or privileges.SINGLE_CATALOG_STYLE).strip()
    creates = privileges.run_creates_schemas(intent_value, bool(data.dry_run), style)
    issues: list[IssueOut] = []
    [(_, cap)] = privileges.app_catalog_capabilities([catalog])
    usable = privileges.catalog_usable(cap, creates_schemas=creates)
    if usable is False:
        # An absent ``_metamodel`` repeats the catalog's GRANT in its own fix.
        fix = "\n".join(dict.fromkeys(line for part in (
            cap.create_schema_fix if creates and cap.create_schema is False else "",
            cap.use_metamodel_fix if cap.use_metamodel is False else "",
        ) for line in part.splitlines() if line))
        need = (
            "create schemas in" if creates and cap.create_schema is False
            else "use `_metamodel` in"
        )
        issues.append(_blocker(
            "catalog",
            f"The app's service principal can't {need} catalog '{catalog}'. "
            f"Ask a catalog owner to run:\n{fix}" if fix else
            f"The app's service principal can't {need} catalog '{catalog}'.",
        ))
    elif usable is None:
        issues.append(IssueOut(
            field_path="catalog", step_index=-1, severity="warning",
            message=f"Couldn't check the app's access to catalog '{catalog}'.",
        ))
    if style != privileges.SINGLE_CATALOG_STYLE and intent_value in (
        Intent.NEW_BASE_MODEL.value, Intent.VIBE_NEW_ECM_MVM.value,
        Intent.VIBE_ITERATE.value, Intent.INSTALL.value,
    ):
        issues.append(IssueOut(
            field_path="cataloging_style", step_index=-1, severity="warning",
            message=_DERIVED_CATALOGS_WARNING.format(style=style, catalog=catalog),
        ))
    return issues


# --- Level 2: intent ----------------------------------------------------------


def _level_intent(business_id, data, business, agent_config, session, ws, create, check, pf):
    """What the request asks for in the current state. Returns the target
    catalog's ``_metamodel`` state for level 3 (None when not read)."""
    from .validate import business_description_blocker_for_intent, deployed_version_reinstall_warning

    intent_value = data.intent.value if data.intent is not None else ""

    # Create's lock (``_lock_business``) re-checked the active run already.
    if business_id and not create:
        active = active_run_for_business(session, business_id)
        if active is not None:
            check(_blocker("business_id", active_run_message(active.id)), 409)

    for issue in _unfinished_cleanup_blockers(business, data, agent_config, pf.parent_mv, session):
        check(issue)

    if business is not None:
        # Any ModelVersion row, including superseded, blocks new-base-model.
        if intent_value == Intent.NEW_BASE_MODEL.value and session.exec(
            select(ModelVersion.id).where(ModelVersion.business_id == business_id).limit(1)
        ).first():
            check(_blocker(
                "intent",
                "New Base Model needs a business with no model versions. "
                "Delete its versions one by one from their pages (uninstall installed ones first), "
                "or create a new business.",
            ))
        # A model-producing intent dispatched with an empty business
        # description fails ~1 minute into agent compute.
        description = business_description_blocker_for_intent(
            intent_value, business,
            business_context_text=data.business_context_text,
            business_context_path=data.business_context_path,
        )
        if description is not None:
            check(_issue_to_out(description))

    # Lakebase-only request checks: reported even before an agent is configured.
    scope_issues = _collect_vibe_scope_blockers(business_id, data, session)
    for issue in scope_issues:
        check(issue)

    # The next-vibe selections and the compiled inputs, after the scope
    # checks rewrote ``vibe_scope_domains`` to the stored domain names (a
    # refused scope has nothing to compile).
    if pf.next_vibe_error is not None:
        check(_blocker("next_vibe_ids", pf.next_vibe_error), 400, pf.next_vibe_error)
    _compile_request(data, business, session, pf, with_inputs=not scope_issues)

    if intent_value == Intent.VIBE_NEW_ECM_MVM.value:
        parent_blocker = _orch_validate.parent_scope_blocker_for_intent(intent_value, pf.parent_mv)
        if parent_blocker is not None:
            out = _issue_to_out(parent_blocker)
            check(out, 400, {"blockers": [out.model_dump()], "warnings": []})

    if intent_value in _VERSION_BOUND_INTENTS and pf.parent_mv is None:
        check(_blocker("version_id", _no_target_version_message(intent_value)), 422,
              _no_target_version_message(intent_value))

    _dag_findings(business_id, data, business, agent_config, session, pf, check)

    # Without a configured agent the workspace and catalog checks below can't
    # run meaningfully (level 1 has the agent-not-configured blocker).
    if agent_config is None or not (agent_config.notebook_path or "").strip():
        return None

    target = resolve_run_target_catalog(data, agent_config)
    cataloging_style = (data.cataloging_style or "One Catalog").strip()
    if cataloging_style == "One Catalog" and not target:
        check(_blocker(
            "catalog",
            "Deployment catalog is required when cataloging style "
            "is 'One Catalog' and no default metamodel catalog is "
            "configured. Pick a target catalog on the run form.",
        ))

    meta = None
    if intent_value in _METAMODEL_REQUIRED_INTENTS and target and ws is not None:
        meta = _setup.metamodel_state(ws, target)
        if meta.denied:
            check(_metamodel_denied_blocker(ws, target))
        elif meta.schema is None:
            check(_warning("catalog", f"Couldn't check `_metamodel` in catalog '{target}'."), echo=False)
        elif meta.schema is False and intent_value != Intent.NEW_BASE_MODEL.value:
            check(_blocker(
                "catalog",
                f"Catalog '{target}' has no `_metamodel` schema. "
                "Run the installer's catalog setup (`install/grant_catalog.py`) "
                "or pick a different catalog. The agent writes model.json + "
                "Delta tables under `<catalog>/_metamodel/...`.",
            ))

    check(_check_scope_agent_marker(business_id, data, agent_config, session, ws, live=create))
    # Its "couldn't check" warnings are for the form; the launch doesn't repeat them.
    parent_count = _check_metamodel_parent_version_present(
        business_id, data, agent_config, session, ws, live=create,
    )
    check(parent_count, echo=parent_count is None or parent_count.severity != "warning")
    for issue in _check_target_catalog_clash(business_id, data, agent_config, session, ws):
        check(issue)
    from .source_industry import source_industry_issues

    for issue in source_industry_issues(session, data, agent_config, pf.parent_mv):
        check(issue)
    for issue in _vibe_catalog_issues(business_id, data, agent_config, session):
        check(issue)

    # Informational (never a blocker): a run whose target catalog differs from
    # the configured metamodel catalog lands its _metamodel + artifacts under
    # the override, the agent's designed per-run _metamodel selector.
    override = (data.catalog or "").strip()
    configured = (agent_config.deployment_catalog or "").strip()
    if override and configured and override != configured:
        check(IssueOut(
            field_path="catalog",
            step_index=-1,
            message=(
                f"This run's `_metamodel` and artifacts will live under "
                f"'{override}'; installation-wide sync and out-of-band "
                f"detection only watch the configured metamodel catalog "
                f"'{configured}'."
            ),
            severity="warning",
        ), echo=False)
    # Install over a version already recorded as deployed in this catalog:
    # a warning, since a re-install after an out-of-band DROP SCHEMA is legitimate.
    if intent_value == Intent.INSTALL.value:
        check(_issue_out_or_none(deployed_version_reinstall_warning(
            intent_value, pf.parent_mv, target, session,
        )))
        check(_typed_prefix_blocker(data, pf, ws))
    return meta


def _typed_prefix_blocker(data: RunIn, pf: Preflight, ws) -> Optional[IssueOut]:
    """An install whose typed ``schema_prefix`` differs from the prefix in the
    version's model.json (``install.typed_prefix_refusal``), read where the
    install step reads it. ``None`` without a typed prefix, a built DAG or a
    readable file (the step then decides at dispatch)."""
    if data.schema_prefix is None or pf.dag is None or ws is None:
        return None
    from ..operations.install import InstallParams, read_install_model_json, typed_prefix_refusal

    step = next((s for s in pf.dag.steps if s.name == "install"), None)
    if step is None:
        return None
    try:
        params = InstallParams(**step.params)
    except ValueError:
        return None
    _, root = read_install_model_json(ws, params)
    refusal = typed_prefix_refusal(params, root)
    return _blocker("schema_prefix", refusal) if refusal is not None else None


def _metamodel_denied_blocker(ws, catalog: str, volumes: tuple[str, ...] = (_setup.VOL_ROOT,)) -> IssueOut:
    """The refusal when ``<catalog>._metamodel`` exists but the app can't see
    it (a denied read here): the run reads and writes it, and setting it up
    again would fail the same way. The wording and the GRANTs are
    ``metamodel_registry.invisible_metamodel_refusal``."""
    return _blocker("catalog", invisible_metamodel_refusal(ws, catalog, volumes))


def _issue_out_or_none(issue) -> Optional[IssueOut]:
    return _issue_to_out(issue) if issue is not None else None


def _no_target_version_message(intent_value: str) -> str:
    return (
        f"Could not resolve a target ModelVersion for intent "
        f"{intent_value!r}. Pass `version_id` explicitly, or run "
        "new-base-model first. If the deployment catalog still holds "
        "schemas of versions the app no longer has, an admin can drop "
        "them on the business's Edit page, under Deployment, Orphan schemas, "
        "or by hand with `DROP SCHEMA <catalog>.<schema> CASCADE`."
    )


def _run_scopes(data: RunIn, base: Optional[ModelVersion]) -> set[str]:
    """The model scopes a run writes in its catalog's registry."""
    intent_value = data.intent.value if data.intent is not None else ""
    if intent_value in (Intent.NEW_BASE_MODEL.value, Intent.VIBE_NEW_ECM_MVM.value):
        return {"ecm", "mvm"}
    if base is not None:
        return {normalize_scope(base.scope or "") or "ecm"}
    return set()


def _unfinished_cleanup_blockers(business, data, agent_config, base, session) -> list[IssueOut]:
    """Design addendum §6.1 (R1): while a deleted version's ``_metamodel``
    cleanup is unfinished in the run's catalog, the agent still sees that
    version as the head of its scope there, so the next run of the scope
    would build on it (or fail ``version_mismatch``)."""
    from ...core._metamodel_cleanups import unfinished_cleanups
    from ...core._names import agent_business_segment

    if business is None:
        return []
    catalog = resolve_run_target_catalog(data, agent_config).lower()
    scopes = _run_scopes(data, base)
    if not catalog or not scopes:
        return []
    # An empty scope is a legacy ECM version (``ModelVersion.scope`` defaults
    # to ""), as on the run side (``_run_scopes``).
    rows = [
        (r, normalize_scope(r.scope or "") or "ecm")
        for r in unfinished_cleanups(session, agent_business_segment(business.name))
        if (r.catalog or "").lower() == catalog
    ]
    return [
        _blocker(
            "metamodel_cleanup",
            f"Cleanup of deleted v{r.version} {scope.upper()} is not finished in "
            f"{r.catalog}. Retry it on the business page.",
        )
        for r, scope in rows
        if scope in scopes
    ]


def _business_context(session, business_id: str):
    from ...db_models import BusinessContext

    return session.exec(
        select(BusinessContext)
        .where(BusinessContext.business_id == business_id)
        .order_by(BusinessContext.created_at.desc())
    ).first()


def _dag_findings(business_id, data, business, agent_config, session, pf: Preflight, check) -> None:
    """Build and validate the run's DAG: the multi-step DAG of
    ``new-base-model`` / ``vibe-new-ecm-mvm`` (``validate_dag_request``), or the
    simple DAG of a version-bound intent with a resolved version. Its blockers
    reject create with the ``{"blockers", "warnings"}`` payload the form
    renders; ``pf.dag`` is the DAG create starts."""
    intent_value = data.intent.value if data.intent is not None else ""
    if business is None:
        return
    intent = _orchestrated_simple_intent(data)
    if intent is not None and pf.parent_mv is not None and agent_config is not None:
        dag = _simple_dag(data, business, agent_config, intent, pf.parent_mv, session)
        result = _orch_validate.validate_dag(dag, registry_get=_operations_registry_get)
    else:
        result = _orch_validate.validate_dag_request(
            data, business, _business_context(session, business_id), agent_config
        )
    # Rule 1, for every DAG: the source-industry versions the run replaces
    # are uninstalled (or, already replaced, released) first.
    if result.dag is not None:
        from .dag_factories._recovery import uninstalls_first
        from .dag_factories._simple import _resolved_cataloging_style
        from .source_industry import industry_uninstall_steps

        uninstalls = industry_uninstall_steps(
            session, data, agent_config, pf.parent_mv, _resolved_cataloging_style(data),
        )
        if uninstalls:
            composed = _orch_validate.validate_dag(
                uninstalls_first(result.dag, uninstalls), registry_get=_operations_registry_get,
            )
            composed.warnings[:0] = result.warnings
            result = composed
    blockers = [_issue_to_out(i) for i in result.blockers]
    warnings = [_issue_to_out(i) for i in result.warnings]
    detail = {
        "blockers": [b.model_dump() for b in blockers],
        "warnings": [w.model_dump() for w in warnings],
    }
    for blocker in blockers:
        check(blocker, 400, detail)
    for warning in warnings:
        check(warning)
    pf.dag = result.dag if not blockers else None


# --- The simple (single-step) DAGs -------------------------------------------


def _simple_factories():
    from .dag_factories import dag_for_install, dag_for_uninstall, dag_for_vibe_iterate

    return {
        Intent.VIBE_ITERATE: dag_for_vibe_iterate,
        Intent.INSTALL: dag_for_install,
        Intent.UNINSTALL: dag_for_uninstall,
    }


# Each simple intent and the primitive its DAG dispatches. Used as a
# registry-readiness probe: when test isolation has emptied the operations
# registry (the primitives register once per process), create falls back to
# the legacy launch path.
_INTENT_TO_PRIMITIVE: dict[Intent, str] = {
    Intent.VIBE_ITERATE: "vibe_iterate",
    Intent.INSTALL: "install",
    Intent.UNINSTALL: "uninstall",
}


def _orchestrator_intent_registered(intent: Intent) -> bool:
    primitive = _INTENT_TO_PRIMITIVE.get(intent)
    if primitive is None:
        return False
    try:
        _operations_registry_get(primitive)
    except KeyError:
        return False
    return True


def _orchestrated_simple_intent(data: RunIn) -> Optional[Intent]:
    """The simple intent of ``data`` when the orchestrator runs it, else None."""
    intent = data.intent if data.intent in _INTENT_TO_PRIMITIVE else None
    if intent is None or not _orchestrator_intent_registered(intent):
        return None
    return intent


class _SimpleRunFactoryContext:
    """``ctx`` of the simple-run DAG factories.

    ``parent_mv`` is the version the run acts on. ``install_widgets`` (uninstall
    only) is the widget map of its latest install: ``dag_for_uninstall``
    targets the prefix it used; ``None`` without a recorded install.
    ``occupant`` (install only) is the version installed in the target catalog
    that the request confirmed replacing (``dag_for_install`` then uninstalls
    it first); ``occupant_install_widgets`` is its latest install's widget map.
    ``context_file_candidates`` (install only) are the paths its model.json
    may be at (``version_files.version_model_json_candidates``).
    ``recorded_install_prefix`` (install only) is the prefix an in-place
    reinstall keeps (:func:`inplace_install_prefix`).
    """

    __slots__ = (
        "parent_mv", "install_widgets", "occupant", "occupant_install_widgets", "context_file_candidates",
        "recorded_install_prefix",
    )

    def __init__(
        self, parent_mv, install_widgets=None, occupant=None, occupant_install_widgets=None,
        context_file_candidates=(), recorded_install_prefix=None,
    ):
        self.parent_mv = parent_mv
        self.install_widgets = install_widgets
        self.occupant = occupant
        self.occupant_install_widgets = occupant_install_widgets
        self.context_file_candidates = context_file_candidates
        self.recorded_install_prefix = recorded_install_prefix


def _simple_dag(data, business, agent_config, intent: Intent, parent_mv, session) -> "Dag":
    from ..dispatched_widgets import latest_install_widgets
    from ..operations._version_lifecycle import catalog_occupant
    from ..version_files import version_model_json_candidates

    # An install into a catalog that holds another version of the scope
    # uninstalls that version first, once the request confirmed it
    # (``install_replaces_in_catalog``).
    occupant = None
    install_widgets = None
    context_file_candidates: list[str] = []
    recorded_install_prefix: Optional[str] = None
    if intent == Intent.INSTALL:
        target = resolve_install_target_catalog(data, parent_mv, agent_config)
        occupant = catalog_occupant(session, parent_mv, target)
        context_file_candidates = version_model_json_candidates(session, parent_mv, business.name)
        recorded_install_prefix = inplace_install_prefix(
            session, parent_mv, target, (data.cataloging_style or "One Catalog").strip() or "One Catalog",
        )
    elif intent == Intent.UNINSTALL:
        install_widgets = latest_install_widgets(session, parent_mv.id)
    ctx = _SimpleRunFactoryContext(
        parent_mv=parent_mv,
        install_widgets=install_widgets,
        occupant=occupant,
        occupant_install_widgets=(
            latest_install_widgets(session, occupant.id) if occupant is not None else None
        ),
        context_file_candidates=context_file_candidates,
        recorded_install_prefix=recorded_install_prefix,
    )
    return _simple_factories()[intent](data, business, ctx, agent_config)


def inplace_install_prefix(session, mv, target_catalog: str, cataloging_style: str) -> Optional[str]:
    """The ``schema_prefix`` an install of ``mv`` into ``target_catalog``
    keeps because ``mv`` is installed there now (an open install row, or a
    pre-row ``deployed`` ``uc_catalog``): the prefix its latest install into
    that catalog dispatched in this cataloging style. ``None`` otherwise.

    An in-place reinstall writes into the schemas that install made: a 0.8.0
    One Catalog install got the scope default (``ecm_crop``) while its file
    says ``""``, and taking the file would create empty bare schemas next to
    the data."""
    from ..dispatched_widgets import install_widgets_into, installed_schema_prefix
    from ..operations._version_lifecycle import _installed_in

    target = (target_catalog or "").strip()
    if mv is None or not target:
        return None
    here = session.exec(
        select(ModelVersion.id).where(ModelVersion.id == mv.id, _installed_in(target, fold_case=True))
    ).first()
    if here is None:
        return None
    return installed_schema_prefix(install_widgets_into(session, mv.id, target), cataloging_style)


# --- Level 3: preparation -----------------------------------------------------


def _level_preparation(data: RunIn, agent_config, meta, pf: Preflight) -> None:
    """What create sets up before the Run row: a missing ``_metamodel`` of a
    first model, and a missing ``vol_root`` (the agent's model.json and
    staged-instruction volume) for any run that reads ``_metamodel``."""
    from ...job_launcher import VIBE_INSTRUCTIONS_INLINE_LIMIT

    if meta is None:
        return
    target = resolve_run_target_catalog(data, agent_config)
    if meta.schema is False:
        # Only reached by new-base-model: the other intents were refused above.
        pf.add(_metamodel_setup_prepare(target))
        pf._prepare.append((target, meta.missing_volumes))
    elif meta.schema is True and meta.missing_volumes:
        for volume in meta.missing_volumes:
            pf.add(IssueOut(
                field_path="catalog", step_index=-1, severity="prepare",
                message=f"The `{volume}` volume will be created in '{target}.{_setup.METAMODEL_SCHEMA}' "
                        "when you start the run.",
            ))
        pf._prepare.append((target, meta.missing_volumes))
    if len(data.vibe_instructions or "") > VIBE_INSTRUCTIONS_INLINE_LIMIT:
        pf.add(IssueOut(
            field_path="vibe_instructions", step_index=-1, severity="prepare",
            message=(
                f"The instructions are longer than {VIBE_INSTRUCTIONS_INLINE_LIMIT} characters, "
                f"so the run saves them as a file in '{target}.{_setup.METAMODEL_SCHEMA}."
                f"{_setup.VOL_ROOT}' and sends the agent its path."
            ),
        ))


def _metamodel_setup_prepare(target_catalog: str) -> IssueOut:
    """The level-3 item of a first model in a catalog with no ``_metamodel``."""
    return IssueOut(
        field_path="catalog",
        step_index=-1,
        message=f"`_metamodel` will be set up in '{target_catalog}' when you start the run.",
        severity="prepare",
    )


def _vibe_catalog_issues(
    business_id: str, data: RunIn, agent_config: Optional["AgentConfig"], session: "Session"
) -> list[IssueOut]:
    """B10 and F6 for a vibe: what the dispatch catalog's registry holds for
    its base (``validate.vibe_catalog_issues``)."""
    from ...models import VibeScope

    intent_value = data.intent.value if data.intent is not None else ""
    if intent_value == Intent.VIBE_ITERATE.value:
        base_mv = _resolve_parent_model_version(business_id, data, Intent.VIBE_ITERATE, session)
    elif intent_value == Intent.VIBE_NEW_ECM_MVM.value:
        base_mv = _resolve_iterate_parent_version(business_id, data, session)
    else:
        return []
    issues = _orch_validate.vibe_catalog_issues(
        session,
        base_mv,
        resolve_run_target_catalog(data, agent_config),
        scoped=data.vibe_scope != VibeScope.ALL_DOMAINS,
        dry_run=bool(data.dry_run),
        intent=intent_value,
    )
    return [_issue_to_out(i) for i in issues]


def _confirm_issues(
    business_id: str,
    data: RunIn,
    agent_config: Optional["AgentConfig"],
    session: "Session",
    ws,
    *,
    warehouse_id: str,
    user: Optional[str],
    fresh: bool,
) -> list[IssueOut]:
    """The subject-bound ``confirm`` issues of an install (B4: install over a
    newer version, an occupied catalog) or a plain uninstall (add §6.2: its
    tables hold rows or could not be checked). Validate and create compute
    them here, so a subject that appears in between is new and unconfirmed."""
    intent_value = data.intent.value if data.intent is not None else ""
    if intent_value == Intent.INSTALL.value:
        target_mv = _resolve_parent_model_version(business_id, data, Intent.INSTALL, session)
        issues = _orch_validate.install_confirm_issues(
            session, target_mv, resolve_install_target_catalog(data, target_mv, agent_config),
        )
    elif intent_value == Intent.UNINSTALL.value:
        target_mv = _resolve_parent_model_version(business_id, data, Intent.UNINSTALL, session)
        issues = _orch_validate.uninstall_confirm_issues(
            session, ws, warehouse_id, target_mv,
            resolve_uninstall_target_catalog(data, target_mv, agent_config),
            cataloging_style=data.cataloging_style,
            confirmed=set(data.confirmed_issues or []),
            user=user,
            fresh=fresh,
        )
    else:
        return []
    return [_issue_to_out(i) for i in issues]


def _raise_needs_confirmation(data: RunIn, issues: list[IssueOut]) -> None:
    """422 ``needs_confirmation`` when a ``confirm`` subject is not in
    ``data.confirmed_issues``. ``issues`` carries every confirm issue the run
    needs (the same set validate returns), so the dialog re-renders with any
    subject that appeared since validate."""
    confirmed = set(data.confirmed_issues or [])
    pending = [i for i in issues if i.severity == "confirm" and i.subject not in confirmed]
    if not pending:
        return
    raise needs_confirmation_error(
        [i.model_dump() for i in issues if i.severity == "confirm"],
        "Confirm what this run changes before it starts: " + " ".join(i.message for i in pending),
    )

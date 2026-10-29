"""``vibe_iterate`` primitive — agent ``vibe modeling of version`` op.

Iterates an existing ModelVersion with a fresh batch of vibe instructions.
The agent reads the parent version's model.json, applies the vibe text, and
writes a NEW version next to it (e.g. ``v3_ecm`` → ``v4_ecm``). On terminal
success this primitive:

* allocates a new ``ModelVersion`` row in Lakebase (sequential per-business
  ``version`` integer);
* syncs its structure into Lakebase via :class:`ModelSyncService`;
* marks the parent version as ``superseded`` so the Explorer surfaces the
  new iteration by default. Rollback restores the parent's prior status;
* records a Full Run's version deployed in its catalog (the agent installs
  it), evicting what the agent replaced there (``deploy_evicts_every_scope``).

A Dry Run (``dry_run=True``, agent ``run_type="Dry Run"``) saves its version
as ``status="draft"`` and supersedes nothing. ``vibe_scope`` /
``vibe_scope_domains`` fence the run to some domains (agent widget 06a, with
the list sent as ``business_domains``).

See ``docs/orchestrator-design.md`` §2 (table) and §10 (failure modes).
"""

from __future__ import annotations

import json
import logging
import time
from datetime import datetime, timezone
from typing import Any, Literal, Optional

from pydantic import BaseModel, Field, field_validator
from sqlmodel import select

from ...core._intents import AGENT_OP_VIBE
from ...error_sanitization import recorded_error_text
from ...agent_compat import model_json_block
from ...db_models import (
    AgentConfig,
    Business,
    ModelVersion,
    RunOperation,
)
from ..._query_helpers import (
    next_version_for_scope,
    parse_version_number,
    resolve_model_json_parent,
    resolve_model_version,
)
from ...run_report import (
    OUTCOME_REASON_MAX,
    clear_agent_report,
    persist_agent_report,
)
from ...job_launcher import (
    finalize_widgets_or_raise,
    generate_session_id,
    job_tags_for_config,
    launch_run,
    map_run_params_to_widgets,
    scope_label_for,
    session_id_to_bigint,
)
from ...core._names import agent_business_segment
from ...core._sql import SqlStatementError, rows
from ...core._uc_privileges import SINGLE_CATALOG_STYLE
from ...core._vibe_scope import (
    RUN_TYPE_DRY,
    RUN_TYPE_FULL,
    VIBE_SCOPE_WIDGET_LABELS,
)
from ...core._warehouse import get_warehouse_id
from ...model_sync import ModelSyncService, _SyncEmptyError
from ...runtime_budget import runtime_budget_seconds as budget_seconds, stored_runtime_budget_hours
from ...version_resolution_parser import lookup_resolved_version
from ._deployment_widgets import CATALOG_NAME_PATTERN
from ._version_lifecycle import (
    deploy_evicts_every_scope,
    base_is_latest_installed,
    evict_deployed_siblings,
    mark_version_deployed,
    restore_evicted_deployments,
    restore_superseded_priors,
    supersede_same_scope_priors,
)
from ._registry import register
from ._protocol import (
    Operation,
    OperationContext,
    OperationDispatchHandle,
    OperationObservation,
    OperationResult,
)

logger = logging.getLogger(__name__)


_AGENT_OP = AGENT_OP_VIBE


class VibeIterateParams(BaseModel):
    """Parameters for the ``vibe_iterate`` primitive.

    Per spec §2 (OperationContext is the source of truth), a few fields are
    optional in the params_model and resolved at dispatch time from
    :class:`OperationContext`:

    * ``business_name`` — derived from ``ctx.business_id`` lookup if blank.
    * ``parent_version_int`` — derived from ``ctx.parent_version_id`` if 0.
    * ``cataloging_style`` — read from ``ctx.inherited_params`` if blank.

    The validator below rejects empty/whitespace ``vibe_instructions``.
    """

    business_name: str = Field(default="", pattern=r"^[a-z][a-z0-9_]*$|^$")
    deployment_catalog: str = Field(default="", pattern=f"{CATALOG_NAME_PATTERN}|^$")
    parent_version_int: int = Field(default=0, ge=0)
    vibe_instructions: str = Field(min_length=1)
    cataloging_style: str = ""
    schema_prefix: str = ""

    # Carry-keys (optional; defaulted to match the agent's expectations)
    business_description: str = ""
    business_description_override: str = ""
    business_context_path: str = ""
    industry_alignment: str = ""
    business_domains: str = ""
    org_divisions: str = "Operations"
    catalog_prefix: str = ""
    catalog_suffix: str = ""
    naming_convention: str = "snake_case"
    primary_key_suffix: str = "_id"
    schema_suffix: str = ""
    tag_prefix: str = "dbx_"
    tag_suffix: str = ""
    table_id_type: str = "BIGINT"
    boolean_format: str = "Boolean (True/False)"
    date_format: str = "yyyy-MM-dd"
    timestamp_format: str = "yyyy-MM-dd HH:mm:ss"
    classification_levels: str = ""
    housekeeping_columns: str = "No"
    history_tracking_columns: str = "No"
    model_size: str = "small model"

    # Agent widgets 06a (``vibe_scope``) and 03a (``run_type``). Defaults keep
    # today's unscoped Full Run. Under ``some_domains`` the scope list is sent
    # as the ``business_domains`` widget.
    vibe_scope: Literal["all_domains", "some_domains"] = "all_domains"
    vibe_scope_domains: list[str] = Field(default_factory=list)
    dry_run: bool = False

    @field_validator("vibe_instructions")
    @classmethod
    def _reject_blank_vibe_instructions(cls, v: str) -> str:
        if not v or not v.strip():
            raise ValueError("vibe_instructions must be non-empty (no whitespace-only)")
        return v


class VibeIterate(Operation):
    """Wrap the agent's ``vibe modeling of version`` op as an Operation."""

    name = "vibe_iterate"
    params_model = VibeIterateParams
    is_idempotent = False
    produces_version = True

    # ------------------------------------------------------------------
    # dispatch
    # ------------------------------------------------------------------

    def dispatch(
        self,
        ctx: OperationContext,
        ws: Any,
        session: Any,
    ) -> OperationDispatchHandle:
        """Launch the Databricks job for ``vibe modeling of version``.

        A retry reuses the run, so the previous attempt's agent report is
        cleared first: every attempt starts with no report.
        """
        clear_agent_report(session, ctx.run_id)
        # Per spec §2 / reconciliation brief #1: parent_version_id from the
        # context drives the parent-version int lookup, not a duplicate
        # params field. Resolve it FIRST so a missing-parent error surfaces
        # before we touch AgentConfig or Business — the test asserts the
        # error mentions the parent.
        parent_version_id = ctx.parent_version_id
        parent_mv: Optional[ModelVersion] = None
        if parent_version_id:
            parent_mv = session.get(ModelVersion, parent_version_id)
            if parent_mv is None:
                raise ValueError(
                    f"vibe_iterate: parent ModelVersion not found "
                    f"(parent_version_id={parent_version_id!r})"
                )

        params = self.params_model(**ctx.params)
        business = session.get(Business, ctx.business_id)
        if business is None:
            raise RuntimeError(
                f"vibe_iterate: business {ctx.business_id} not found"
            )

        # Derive carry-key fallbacks from the context.
        cataloging_style = _cataloging_style(params, ctx)
        parent_version_int = params.parent_version_int or (
            int(parent_mv.version) if parent_mv and parent_mv.version else 0
        )
        if parent_version_int <= 0:
            # No parent supplied either way — vibe_iterate inherently needs one.
            raise ValueError(
                "vibe_iterate: parent version is required "
                "(set ctx.parent_version_id or params.parent_version_int)"
            )

        agent_config = session.exec(select(AgentConfig).limit(1)).first()
        # Tests don't seed an AgentConfig — fall through with a stub job id
        # if one isn't configured. The orchestrator path always seeds a
        # config at startup.
        job_id = int(agent_config.job_id) if agent_config and agent_config.job_id else 0

        sid = generate_session_id()
        sid_bigint = session_id_to_bigint(sid)
        # vibe-iterate's params_json snapshot stores the catalog under
        # ``catalog`` (legacy) while new-base-model uses
        # ``deployment_catalog``. Read either so the dispatch resolves
        # correctly regardless of which intent's snapshot we got. The
        # upstream agent PR (#28) will canonicalise widget naming to
        # remove the dual-key absurdity entirely.
        inherited = ctx.inherited_params or {}
        deployment_catalog = (
            params.deployment_catalog
            or inherited.get("deployment_catalog")
            or inherited.get("catalog")
            or ""
        )

        # A vibe-iterate runs in the PARENT version's scope - it targets a
        # specific existing version, so the scope is fixed and cannot be
        # re-chosen from model_size. Passing the parent's scope stops the
        # agent from defaulting to MVM and hard-failing on an ECM-only version
        # ("Version 'N' with model_scope 'mvm' does not exist").
        parent_scope = (parent_mv.scope if parent_mv and parent_mv.scope else "ecm")
        # Under a scope the agent reads ``business_domains`` as the scope
        # list; unscoped runs keep sending the seed list unchanged.
        scoped = params.vibe_scope != "all_domains"
        business_domains = (
            ", ".join(params.vibe_scope_domains)
            if scoped
            else params.business_domains
        )
        widgets = map_run_params_to_widgets(
            operation=_AGENT_OP,
            business=business,
            catalog=deployment_catalog,
            session_id=sid,
            runtime_budget_seconds=budget_seconds(
                stored_runtime_budget_hours(inherited, agent_config)
            ),
            vibe_instructions=params.vibe_instructions,
            model_size=params.model_size,
            data_model_scopes=scope_label_for(parent_scope),
            business_context_path=params.business_context_path,
            business_description_override=params.business_description_override,
            model_version=str(parent_version_int),
            naming_convention=params.naming_convention,
            primary_key_suffix=params.primary_key_suffix,
            schema_prefix=params.schema_prefix,
            schema_suffix=params.schema_suffix,
            tag_prefix=params.tag_prefix,
            tag_suffix=params.tag_suffix,
            table_id_type=params.table_id_type,
            boolean_format=params.boolean_format,
            date_format=params.date_format,
            timestamp_format=params.timestamp_format,
            cataloging_style=cataloging_style,
            catalog_prefix=params.catalog_prefix,
            catalog_suffix=params.catalog_suffix,
            org_divisions=params.org_divisions,
            business_domains=business_domains,
            classification_levels=params.classification_levels,
            housekeeping_columns=params.housekeeping_columns,
            history_tracking_columns=params.history_tracking_columns,
            vibe_scope=VIBE_SCOPE_WIDGET_LABELS[params.vibe_scope],
            run_type=RUN_TYPE_DRY if params.dry_run else RUN_TYPE_FULL,
        )
        widgets["operation"] = _AGENT_OP
        widgets["vibe_session_id"] = str(sid_bigint)
        widgets = finalize_widgets_or_raise(
            ws,
            widgets,
            catalog=deployment_catalog,
            business_name=business.name,
            session_id=sid,
            raw_vibes=params.vibe_instructions,
        )

        job_tags = job_tags_for_config(
            agent_config,
            business_name=business.name,
            model_scope=widgets.get("data_model_scopes", ""),
            version=str(parent_version_int),
            operation=_AGENT_OP,
            session_id=sid,
        )

        dbx_run_id = launch_run(
            ws,
            job_id,
            widgets,
            job_tags=job_tags,
        )

        # Persist the dispatch on the RunOperation row so the resume guard
        # short-circuits a second dispatch with the same operation_id.
        # Tests call dispatch directly without the orchestrator; upsert a
        # stub row when none exists.
        # Stash the agent-normalized business name (lowercase + space->_)
        # so the observe-side sync builds the same Volume path the agent
        # wrote to. Storing the raw DB literal here would cause the
        # /Volumes/.../business/<biz>/{scope}_v{N}/model.json lookup to
        # 404 silently and leave Lakebase empty for the new version.
        agent_biz = agent_business_segment(business.name)
        _upsert_run_op_dispatch(
            session, ctx, dbx_run_id=int(dbx_run_id), vibe_session_id=sid,
        )

        return OperationDispatchHandle(
            databricks_run_id=int(dbx_run_id),
            vibe_session_id=sid,
            extra={
                "session_id_bigint": int(sid_bigint),
                "deployment_catalog": deployment_catalog,
                "business_name": agent_biz,
                "parent_version_int": int(parent_version_int),
            },
            # Write-once audit of the exact widget map dispatched to the
            # Jobs API (see OperationDispatchHandle.dispatched_widgets).
            # Persisted verbatim onto RunOperation.dispatched_widgets_json
            # so the run-detail "What you submitted → Dispatched widgets"
            # block populates for vibe-iterate runs, matching install/
            # uninstall/generate_samples + the generation primitives.
            dispatched_widgets=widgets,
        )

    # ------------------------------------------------------------------
    # observe
    # ------------------------------------------------------------------

    def observe(
        self,
        handle: OperationDispatchHandle,
        ctx: OperationContext,
        ws: Any,
        session: Any,
    ) -> OperationObservation:
        """Poll Delta + Jobs API for terminal state.

        Mirrors the agent-progress polling semantics
        but in pull-only form: we never sleep, we never mutate ``Run`` rows.
        Returns a fresh snapshot on every call.
        """
        if not handle.databricks_run_id:
            return OperationObservation(
                progress_percent=0,
                progress_message="Waiting for dispatch",
                is_terminal=False,
                terminal_result=None,
            )

        # Step 1: Jobs API check — terminal failure short-circuits.
        try:
            job_run = ws.jobs.get_run(handle.databricks_run_id)
            lcs = (
                job_run.state.life_cycle_state.value
                if job_run.state and job_run.state.life_cycle_state
                else ""
            )
            rs = (
                job_run.state.result_state.value
                if job_run.state and job_run.state.result_state
                else ""
            )
        except Exception as e:
            logger.warning(
                "vibe_iterate.observe: Jobs API poll failed for run_id=%s: %r",
                handle.databricks_run_id, e,
            )
            return OperationObservation(
                progress_percent=0,
                progress_message="Polling Databricks…",
                is_terminal=False,
                terminal_result=None,
            )

        if lcs == "TERMINATED" and rs != "SUCCESS":
            return OperationObservation(
                progress_percent=0,
                progress_message=f"Failed ({rs})",
                is_terminal=True,
                terminal_result=OperationResult(
                    succeeded=False,
                    output_version_id=None,
                    output_artifacts=[],
                    rollback_state={},
                    error=(
                        getattr(job_run.state, "state_message", "")
                        or f"Job ended with {rs}"
                    ),
                ),
            )
        if lcs in ("INTERNAL_ERROR", "SKIPPED"):
            return OperationObservation(
                progress_percent=0,
                progress_message=f"Failed ({lcs})",
                is_terminal=True,
                terminal_result=OperationResult(
                    succeeded=False,
                    output_version_id=None,
                    output_artifacts=[],
                    rollback_state={},
                    error=(
                        getattr(job_run.state, "state_message", "")
                        or lcs
                    ),
                ),
            )

        # Step 2: on Jobs SUCCESS, the agent's contract is to have written
        # `model.json` under the version dir. Verify by attempting a fetch;
        # a missing file means the agent succeeded by Jobs metrics but
        # didn't produce the expected artifact (spec §10 failure mode 2).
        if lcs == "TERMINATED" and rs == "SUCCESS":
            try:
                model_json, fetch_info = self._fetch_model_json(
                    handle, ctx, ws, session
                )
            except Exception as e:
                logger.info(
                    "vibe_iterate.observe: model.json fetch failed for run_id=%s: %r",
                    handle.databricks_run_id, e,
                )
                return OperationObservation(
                    progress_percent=0,
                    progress_message="Failed (model.json missing)",
                    is_terminal=True,
                    terminal_result=OperationResult(
                        succeeded=False,
                        output_version_id=None,
                        output_artifacts=[],
                        rollback_state={},
                        error=f"model.json missing or unreadable: {e}",
                    ),
                )
            terminal = self._finalize_success(
                handle, ctx, ws, session,
                model_json=model_json, fetch_info=fetch_info,
            )
            if not terminal.succeeded:
                return OperationObservation(
                    progress_percent=0,
                    progress_message="Failed (model.json version mismatch)",
                    is_terminal=True,
                    terminal_result=terminal,
                )
            return OperationObservation(
                progress_percent=100,
                progress_message="Completed",
                is_terminal=True,
                terminal_result=terminal,
            )

        # Step 3: in-flight - best-effort Delta poll for percent. Lenient on
        # purpose: it only feeds the observation's percent and label, and the
        # progress tracker mirrors the agent's events and session row (and
        # shows its read failures) on every tick. One 5 s wait, then cancel.
        sid_bigint = handle.extra.get("session_id_bigint") if handle.extra else None
        catalog = handle.extra.get("deployment_catalog") if handle.extra else None
        completed_percent = 0
        processing_status = ""
        if sid_bigint and catalog:
            try:
                sql = (
                    f"SELECT processing_status, completed_percent, completion_date "
                    f"FROM `{catalog}`.`_metamodel`.`business` "
                    f"WHERE session_id = {int(sid_bigint)} LIMIT 1"
                )
                found = rows(
                    ws, get_warehouse_id(session), sql,
                    wait_timeout="5s", missing_table="none",
                )
                if found:
                    row = found[0]
                    processing_status = (row[0] or "").lower()
                    try:
                        completed_percent = int(float(row[1])) if row[1] else 0
                    except (TypeError, ValueError):
                        completed_percent = 0
            except SqlStatementError as e:
                logger.debug(
                    "vibe_iterate.observe: Delta poll failed for sid=%s: %s",
                    sid_bigint, e,
                )

        return OperationObservation(
            progress_percent=completed_percent,
            progress_message=processing_status or "Running",
            is_terminal=False,
            terminal_result=None,
        )

    def _fetch_model_json(
        self,
        handle: OperationDispatchHandle,
        ctx: OperationContext,
        ws: Any,
        session: Any,
    ) -> tuple[dict, dict]:
        """Fetch + parse the agent's model.json. Raises on any failure.

        Returns ``(model_json, fetch_info)``. ``fetch_info`` carries the
        expected output version (computed ONCE here and handed to
        :meth:`_finalize_success` so allocation and fetch cannot disagree),
        the scope it was computed for, the version folder the file actually
        came from, and ``version_mismatch``.

        Fetch rules (design D13): only the expected version's candidates are
        retried through every attempt. Under Volume lag a Full Run's v{N+2}
        may not be visible yet while a prior Dry Run's v{N+1} is, so the
        parent+1 / parent folders are tried once each only after every
        attempt failed, and a file found there is flagged
        ``version_mismatch``. A ``lineage.output_version`` that differs from
        the expected version is flagged the same way.
        """
        from ...core._paths import model_json_volume_candidates

        extra = handle.extra or {}
        catalog = extra.get("deployment_catalog", "")
        biz_name = extra.get("business_name", "")
        parent_int = int(extra.get("parent_version_int") or 0)
        parent_mv: Optional[ModelVersion] = None
        if ctx.parent_version_id:
            parent_mv = session.get(ModelVersion, ctx.parent_version_id)
        scope = (parent_mv.scope if parent_mv and parent_mv.scope else "ecm")
        if not biz_name:
            biz = session.get(Business, ctx.business_id)
            # Same agent-side normalization as the dispatch path; the
            # downstream Volume lookup interpolates this verbatim and
            # will 404 on the raw DB literal.
            biz_name = agent_business_segment(biz.name) if biz else ""

        expected = _expected_output_version(session, ctx, scope)

        def _candidates_for(v: int) -> list[str]:
            # Nested (agent 4.9.8+) first, then legacy flat.
            if v <= 0 or not (catalog and biz_name):
                return []
            try:
                return model_json_volume_candidates(catalog, biz_name, v, scope)
            except ValueError:
                return []

        expected_candidates = _candidates_for(expected)
        if not expected_candidates and not (catalog and biz_name):
            # No path resolvable — still attempt a generic download so a
            # mock-side-effect test that only checks `download.called`
            # produces a deterministic outcome.
            expected_candidates = ["/Volumes/_unknown/model.json"]
        resolved_paths = bool(catalog and biz_name)

        def _try(path: str) -> dict:
            resp = ws.files.download(path)
            doc = json.loads(resp.contents.read())
            return doc if isinstance(doc, dict) else {"model": doc}

        def _info(fetched_version: Optional[int], mismatch: bool) -> dict:
            return {
                "expected_version": expected,
                "scope": scope,
                "fetched_version": fetched_version,
                "version_mismatch": mismatch,
            }

        # Volume FUSE writes are eventually consistent w.r.t. Files API
        # reads — the agent reports SUCCESS to Jobs API the instant its
        # notebook returns, but the freshly-written model.json may take
        # a few seconds to be visible through ws.files.download(). Retry
        # the expected version with bounded backoff before giving up.
        # Caps at ~15s of sleep (5 attempts: 1s, 2s, 4s, 8s between).
        last_exc: Optional[Exception] = None
        max_attempts = 5
        for attempt in range(max_attempts if expected_candidates else 0):
            for path in expected_candidates:
                try:
                    doc = _try(path)
                except Exception as e:
                    last_exc = e
                    continue
                info = _info(expected if resolved_paths else None, False)
                _flag_lineage_mismatch(doc, info)
                return doc, info
            if attempt < max_attempts - 1:
                time.sleep(2 ** attempt)  # 1, 2, 4, 8 seconds

        # Last resort: the expected folder never became visible. Probe
        # parent+1 then parent once each as an existence check. Whatever is
        # found there is not the expected version, so its outcomes must not
        # drive consume.
        for v in (parent_int + 1, parent_int):
            if v == expected:
                continue
            for path in _candidates_for(v):
                try:
                    doc = _try(path)
                except Exception as e:
                    last_exc = e
                    continue
                logger.warning(
                    "vibe_iterate: model.json for expected v%d (%s) not "
                    "visible after %d attempts; using v%d as a fallback, "
                    "version_mismatch set (run=%s)",
                    expected, scope, max_attempts, v, ctx.run_id,
                )
                return doc, _info(v, True)
        raise RuntimeError(
            f"model.json not fetched after {max_attempts} attempts; "
            f"last error: {last_exc}"
        )

    def _finalize_success(
        self,
        handle: OperationDispatchHandle,
        ctx: OperationContext,
        ws: Any,
        session: Any,
        model_json: Optional[dict] = None,
        fetch_info: Optional[dict] = None,
    ) -> OperationResult:
        """Finish the op from the fetched model.json; may return a FAILED result.

        On the expected version: allocate the new ModelVersion, sync it into
        Lakebase and supersede same-scope priors. On a ``version_mismatch``
        it returns ``succeeded=False`` (see the last paragraph).

        Returns an :class:`OperationResult` whose ``rollback_state`` carries
        the new version id and the list of ids flipped to ``superseded`` so
        :meth:`rollback` can delete the new row and restore each prior.

        ``fetch_info`` (from :meth:`_fetch_model_json`) supplies the expected
        version that was fetched, so the allocated ordinal is the same one.
        A Dry Run (``params.dry_run``) is saved as ``status="draft"`` with
        ``dry_run=True`` and supersedes nothing. The agent's report (per-input
        outcomes, version facts, lineage) is written as rows by
        ``run_report.persist_agent_report`` inside the sync savepoint, so it
        lands only with a synced version.

        A fetched file that is not the expected version (``version_mismatch``)
        fails the op: no version row is created, nothing is synced, and only
        the report row is written, so the run report can say why.
        """
        params = self.params_model(**ctx.params)
        business = session.get(Business, ctx.business_id)
        # Same priority chain as `_fetch_model_json` and `dispatch`: the
        # dispatch side persists the
        # agent-normalized business name into ``handle.extra``; honor that
        # first. Fall back to deriving from the DB row, finally to
        # params. Reading the raw ``business.name`` here would re-introduce
        # the v3/v4 sync drift (Volume folders are agent-normalized).
        extra = handle.extra or {}
        biz_name = extra.get("business_name", "")
        if not biz_name:
            biz_name = (
                agent_business_segment(business.name)
                if business
                else agent_business_segment(params.business_name)
            )

        # Resolve parent (the version we iterated from): the one model.json
        # names (the 5.3.3 ``lineage`` block, else the
        # ``generated_from_version`` tag), which carries the parent's scope.
        # Then fall back to ctx.parent_version_id, then the
        # parent_version_int + scope carried on the handle (the legacy path).
        parent: Optional[ModelVersion] = resolve_model_json_parent(
            session, ctx.business_id, model_json,
        )
        if parent is None and ctx.parent_version_id:
            parent = session.get(ModelVersion, ctx.parent_version_id)
        if parent is None:
            # Fall back to a (business, version, scope) lookup using the
            # parent_version_int + parent's scope. We need a scope to
            # disambiguate (post-refactor `version` alone is ambiguous);
            # default to "ecm" when nothing else is known so the legacy
            # code path keeps producing a deterministic answer.
            parent_version_int = (
                handle.extra.get("parent_version_int") if handle.extra else None
            ) or params.parent_version_int
            if parent_version_int:
                parent = resolve_model_version(
                    session,
                    ctx.business_id,
                    int(parent_version_int),
                    "ecm",
                ) or resolve_model_version(
                    session,
                    ctx.business_id,
                    int(parent_version_int),
                    "mvm",
                )

        scope = (parent.scope if parent else "ecm") or "ecm"

        # Vibe-iterate inherits the parent's scope and increments the
        # per-scope counter. Without per-scope allocation an iterate of
        # MVM v1 would land at v(N+1) where N is the global max — which
        # could collide with an unrelated ECM ordinal.
        # The expected version (agent Version Resolution override, else the
        # next per-scope ordinal) is computed once in `_fetch_model_json`
        # and reused here. Recompute only when the fetch was for another
        # scope (the model.json lineage tag named a different parent); the
        # fetched file then cannot be trusted for outcomes either.
        version_mismatch = False
        if fetch_info and fetch_info.get("scope") == scope:
            new_version_num = int(fetch_info["expected_version"])
            version_mismatch = bool(fetch_info.get("version_mismatch"))
        else:
            new_version_num = _expected_output_version(session, ctx, scope)
            if fetch_info:
                version_mismatch = True
                logger.warning(
                    "vibe_iterate: fetch scope %r differs from resolved "
                    "parent scope %r (run=%s); version_mismatch set",
                    fetch_info.get("scope"), scope, ctx.run_id,
                )
        agent_report = _build_agent_outcomes(
            model_json,
            expected_version=new_version_num,
            fetched_version=(fetch_info or {}).get("fetched_version"),
            version_mismatch=version_mismatch,
        )
        if version_mismatch:
            persist_agent_report(session, ctx.run_id, agent_report)
            return OperationResult(
                succeeded=False,
                output_version_id=None,
                output_artifacts=[],
                rollback_state={},
                error=_version_mismatch_error(
                    new_version_num, scope, agent_report["fetched_version"],
                ),
            )
        deployment_catalog = params.deployment_catalog or (
            handle.extra.get("deployment_catalog") if handle.extra else ""
        )
        # A Full Run vibe deploys: the agent runs the physical schema stages
        # (``step_create_physical_schema_stage1``, skipped only on Dry Run)
        # and registers the version ``installed``. So a Full Run with a
        # catalog is born deployed there and evicts what the agent replaced in
        # that catalog (below, outside the sync savepoint): the same scope when it
        # kept the installed tables or the run was scoped, every scope of the
        # business when its staging teardown dropped them first. A Dry Run's
        # version is a draft (design D7): status="draft" keeps it out of every
        # "latest completed" query, so it never becomes the head or a base,
        # and it supersedes nothing below. Both write their files to the
        # dispatch catalog.
        new_mv = ModelVersion(
            business_id=ctx.business_id,
            version=new_version_num,
            status="draft" if params.dry_run else "completed",
            dry_run=bool(params.dry_run),
            base_version_id=parent.id if parent else None,
            vibe_instructions=params.vibe_instructions,
            scope=scope,
            files_catalog=deployment_catalog or None,
            completion_date=datetime.now(timezone.utc),
        )
        deploys = bool(deployment_catalog) and not params.dry_run
        session.add(new_mv)
        session.flush()
        if deploys:
            mark_version_deployed(session, new_mv, deployment_catalog, run_id=ctx.run_id)

        # Evict what the agent's deploy replaced in the catalog, outside the
        # sync savepoint: the agent dropped or overwrote it whatever our sync
        # does. Only a same-scope eviction is restorable on rollback.
        evicted_ids: list[str] = []
        if deploys:
            every_scope = deploy_evicts_every_scope(
                _AGENT_OP,
                cataloging_style=_cataloging_style(params, ctx),
                scoped=params.vibe_scope != "all_domains",
                keeps_installed=parent is not None and base_is_latest_installed(
                    session, parent, deployment_catalog, new_version_id=new_mv.id,
                ),
            )
            evicted = evict_deployed_siblings(session, new_mv, same_scope=not every_scope, run_id=ctx.run_id)
            evicted_ids = [] if every_scope else evicted

        # Promote-and-sync region wrapped in a SAVEPOINT. new_mv was flushed
        # OUTSIDE it (above), so the row survives a rollback. Inside: flip
        # every other completed MV in (business, scope) to superseded (covers
        # the parent plus any lingering completed siblings), sync into
        # Lakebase (the agent writes the per-scope `{scope}_v{new_version_num}`
        # Volume folder, v0.5.9+), then write the agent's report rows. On any
        # raise the savepoint reverts the supersede flip, the partial element
        # writes and the report, so the prior good version stays active and
        # un-superseded and no feedback is consumed for a version that did
        # not sync.
        auto_superseded_ids: list[str] = []
        sync_succeeded = False
        try:
            with session.begin_nested():
                if not params.dry_run:
                    auto_superseded_ids = supersede_same_scope_priors(
                        session, ctx.business_id, scope, new_mv.id,
                    )
                sync = ModelSyncService(session, ws, get_warehouse_id(session))
                sync._drain_progress_fn = handle.extra.get("progress_drain")
                sync_ok = sync.sync_model(
                    new_mv.id,
                    deployment_catalog,
                    biz_name,
                    str(new_version_num),
                    scope,
                    run_id=ctx.run_id,
                )
                if not sync_ok:
                    # sync_model returned False: no model.json in Volumes and
                    # no Delta fallback. Raise so the savepoint rolls back and
                    # new_mv lands sync_empty rather than a silent
                    # completed/ok version with 0 domains.
                    raise _SyncEmptyError(
                        f"No model data found for {biz_name} "
                        f"v{new_version_num} ({scope}) in Volumes or Delta"
                    )
                persist_agent_report(session, ctx.run_id, agent_report)
            sync_succeeded = True
        except _SyncEmptyError as exc:
            # No model structure was found (no Volume, no Delta) or the payload
            # parsed to 0 domains. A resync won't help until the agent's Volume
            # output is populated, so this is distinct from incomplete_metadata.
            # The Operation still succeeds (see the succeeded=True return below).
            auto_superseded_ids = []
            new_mv.sync_state = "sync_empty"
            new_mv.sync_error_text = str(exc)[:500]
            session.add(new_mv)
            session.commit()
            logger.error(
                "vibe_iterate: no model data found; new_mv=%s marked "
                "sync_state=sync_empty (Operation still succeeded)",
                new_mv.id,
            )
        except Exception as exc:
            # Savepoint rolled back: the supersede flip and partial writes are
            # undone, so nothing was auto-superseded. Surface the failure on
            # the (surviving) new_mv row so the version detail page can render
            # a banner. Without this the only signal was a stack trace and the
            # version sat at status=completed/sync_state=ok forever.
            auto_superseded_ids = []
            new_mv.sync_state = "incomplete_metadata"
            new_mv.sync_error_text = recorded_error_text(
                exc, f"Lakebase sync of version {new_mv.id}", str(exc)[:500])
            session.add(new_mv)
            session.commit()
            logger.exception(
                "vibe_iterate: Lakebase sync raised; new_mv=%s marked "
                "sync_state=incomplete_metadata (Operation still succeeded)",
                new_mv.id,
            )

        # Index Volume artifacts as RunArtifact rows so the Artifacts tab
        # is populated for vibe-produced versions, mirroring what
        # ``_generation_common._terminal_success`` does for ``generate_ecm``
        # / ``shrink_to_mvm``. Pre-fix: only those two op paths indexed
        # artifacts; vibe-produced versions had empty Artifacts tabs and
        # had to rely on the explorer's Strategy-0 file probe to render
        # at all. Best-effort — never fails the operation.
        if sync_succeeded:
            run_id = getattr(ctx, "run_id", "") or ""
            run_row = None
            if run_id:
                try:
                    from ...db_models import Run as DbRun
                    run_row = session.get(DbRun, run_id)
                except Exception:
                    run_row = None
            if run_row is not None and deployment_catalog and biz_name:
                try:
                    from ...progress_tracker import index_artifacts_for_version
                    index_artifacts_for_version(
                        ws,
                        run_row,
                        new_mv,
                        session,
                        deployment_catalog,
                        biz_name,
                        int(new_version_num),
                        scope,
                    )
                except Exception:
                    logger.exception(
                        "vibe_iterate: artifact indexing failed for "
                        "version %s (non-fatal)",
                        new_mv.id,
                    )

        # Output artifact entry pointing at the agent's model.json so
        # downstream consumers (and the post-run UI) can find it directly
        # off the OperationResult without re-deriving the path.
        artifacts: list[dict] = []
        try:
            from ...core._paths import model_json_volume_path
            mj_path = model_json_volume_path(
                deployment_catalog, biz_name, new_version_num, scope
            ) if deployment_catalog and biz_name else ""
            if mj_path:
                artifacts.append(
                    {"artifact_type": "model_json", "file_path": mj_path}
                )
        except Exception:
            # Path-builder rejection is non-fatal — the artifact list is a
            # convenience, not a contract requirement.
            pass

        return OperationResult(
            succeeded=True,
            output_version_id=new_mv.id,
            output_artifacts=artifacts,
            rollback_state={
                "new_version_id": new_mv.id,
                "parent_version_id": parent.id if parent else None,
                "auto_superseded_ids": auto_superseded_ids,
                "evicted_ids": evicted_ids,
                "deployment_catalog": deployment_catalog if deploys else "",
            },
            error=None,
        )

    # ------------------------------------------------------------------
    # rollback
    # ------------------------------------------------------------------

    def rollback(
        self,
        ctx: OperationContext,
        rollback_state: dict,
        ws: Any,
        session: Any,
    ) -> None:
        """Delete the new version + un-supersede same-scope priors + reinstate
        the versions it evicted from its catalog + clear the run's agent
        report rows.

        Idempotent: missing rows are no-ops. The canonical key is
        ``auto_superseded_ids`` (list of ids that ``supersede_same_scope_priors``
        flipped at terminal-success time). External callers passing the
        legacy ``superseded_parent_ids`` shape are honoured for
        compatibility with cancel-with-rollback paths that rebuild state
        from a flat list of parent ids.
        """
        new_id = rollback_state.get("new_version_id")
        auto_superseded_ids = rollback_state.get("auto_superseded_ids") or []
        legacy_superseded_ids = rollback_state.get("superseded_parent_ids") or []
        # Legacy shape from older rollback_state blobs (parent + prior status).
        legacy_parent_id = rollback_state.get("parent_version_id")
        legacy_prior_status = rollback_state.get("parent_prior_status")

        # 1) Clear Lakebase model data for the new version (FK chain
        #    requires this before deleting the ModelVersion row).
        if new_id:
            mv = session.get(ModelVersion, new_id)
            if mv is not None:
                try:
                    sync = ModelSyncService(session, ws, get_warehouse_id(session))
                    sync.clear_version_data(new_id)
                except Exception:
                    logger.exception(
                        "vibe_iterate.rollback: clear_version_data failed for %s",
                        new_id,
                    )
                session.delete(mv)
                session.flush()

        # 2) Restore status='superseded' rows flipped by the helper, and the
        #    deployments the new version evicted.
        restore_superseded_priors(session, auto_superseded_ids)
        restore_evicted_deployments(
            session, rollback_state.get("evicted_ids") or [],
            catalog=rollback_state.get("deployment_catalog") or None,
        )
        # 3) Legacy/external shape — restore the flat parent-id list.
        restore_superseded_priors(session, legacy_superseded_ids)
        # 4) Legacy single-parent shape with explicit prior status.
        if legacy_parent_id:
            parent = session.get(ModelVersion, legacy_parent_id)
            if parent is not None and parent.status == "superseded":
                parent.status = legacy_prior_status or "completed"
                session.add(parent)
        if (
            auto_superseded_ids
            or legacy_superseded_ids
            or legacy_parent_id
        ):
            session.flush()
        if ctx.run_id:
            clear_agent_report(session, ctx.run_id)


def _cataloging_style(params: VibeIterateParams, ctx: OperationContext) -> str:
    """The run's cataloging style: the params', else the run's, else One Catalog."""
    return (
        params.cataloging_style
        or (ctx.inherited_params or {}).get("cataloging_style")
        or SINGLE_CATALOG_STYLE
    )


def _expected_output_version(session: Any, ctx: OperationContext, scope: str) -> int:
    """The version ordinal this run's output is expected at, for ``scope``.

    The agent's Version Resolution override wins when present (it means the
    agent auto-resolved a collision and wrote a different folder; see
    ``backend.version_resolution_parser``), else the next per-scope ordinal.
    Mirrors the same gate in ``_generation_common._terminal_success``.
    """
    allocated = next_version_for_scope(session, ctx.business_id, scope)
    agent_resolved = lookup_resolved_version(session, ctx.run_id, scope)
    if agent_resolved is not None and agent_resolved != allocated:
        logger.info(
            "vibe_iterate: applying agent Version Resolution override on "
            "run=%s scope=%s — App-allocated v%d, agent resolved to v%d",
            ctx.run_id, scope, allocated, agent_resolved,
        )
        return int(agent_resolved)
    return int(allocated)


def _version_mismatch_error(expected: int, scope: str, fetched: Optional[int]) -> str:
    """The user-facing error of a run whose model.json is not the expected version."""
    found = (
        f"the file is v{fetched}"
        if fetched is not None and fetched != expected
        else "the file names a different output version or scope"
    )
    return (
        f"The agent's model.json is not the expected version v{expected} "
        f"({scope}): {found}. No version was saved and no feedback was marked "
        "done. Retry the run."
    )


def _flag_lineage_mismatch(model_json: dict, info: dict) -> None:
    """Set ``info["version_mismatch"]`` when ``lineage.output_version`` disagrees.

    The disagreeing version becomes ``info["fetched_version"]``, so the report
    shows the version the file names.
    """
    lineage = model_json_block(model_json, "lineage")
    if not isinstance(lineage, dict):
        return
    raw = lineage.get("output_version")
    out = parse_version_number(raw)
    if out is None and raw not in (None, ""):
        logger.warning(
            "vibe_iterate: model.json lineage.output_version=%r is not a "
            "version label; the version check is skipped", raw,
        )
    if out is not None and out != info["expected_version"]:
        logger.warning(
            "vibe_iterate: model.json lineage.output_version=v%d differs from "
            "expected v%d (%s); version_mismatch set",
            out, info["expected_version"], info["scope"],
        )
        info["version_mismatch"] = True
        info["fetched_version"] = out


_MISSING = object()


def _optional_text(value: Any) -> Optional[str]:
    text = str(value).strip() if value is not None else ""
    return text or None


def _outcome_entry(o: dict) -> dict:
    """One ``input_outcomes`` entry, normalized for the report rows."""
    reason = _optional_text(o.get("reason"))
    return {
        "item_id": str(o.get("item_id") or "").strip(),
        "target": _optional_text(o.get("target")),
        "status": (_optional_text(o.get("status")) or "").lower() or None,
        "reason": reason[:OUTCOME_REASON_MAX] if reason else None,
    }


def _build_agent_outcomes(
    model_json: Optional[dict],
    *,
    expected_version: int,
    fetched_version: Optional[int],
    version_mismatch: bool,
) -> dict:
    """The agent's report on the run, read from the model.json root blocks.

    The single parser for ``run_report.persist_agent_report``. Never raises.
    Fails closed: a present ``input_outcomes`` that is not a list (or cannot
    be read) logs a warning and reports ``has_input_outcomes=True`` with no
    items and ``input_outcomes_malformed=True``, so nothing is consumed. Only
    a MISSING key reports ``has_input_outcomes=False``, which also consumes
    nothing. ``lineage`` versions are parsed to ints.
    """
    summary: dict = {
        "expected_version": expected_version,
        "fetched_version": fetched_version,
        "version_mismatch": bool(version_mismatch),
        "has_input_outcomes": False,
        "input_outcomes": [],
        "input_outcomes_malformed": False,
        "lineage": {},
    }
    present = False
    try:
        outcomes = model_json_block(model_json, "input_outcomes", _MISSING)
        present = outcomes is not _MISSING
        if present:
            summary["has_input_outcomes"] = True
            if isinstance(outcomes, list):
                summary["input_outcomes"] = [
                    _outcome_entry(o) for o in outcomes if isinstance(o, dict)
                ]
            else:
                summary["input_outcomes_malformed"] = True
                logger.warning(
                    "vibe_iterate: model.json input_outcomes is %s, not a "
                    "list; consuming no inputs", type(outcomes).__name__,
                )
        lineage = model_json_block(model_json, "lineage")
        if isinstance(lineage, dict):
            stale = lineage.get("stale")
            summary["lineage"] = {
                "base_version": parse_version_number(lineage.get("base_version")),
                "head_at_write": parse_version_number(lineage.get("head_at_write")),
                "stale": stale if isinstance(stale, bool) else None,
            }
    except Exception:
        logger.warning(
            "vibe_iterate: could not summarize agent outcomes", exc_info=True,
        )
        summary["has_input_outcomes"] = bool(present)
        summary["input_outcomes"] = []
        summary["input_outcomes_malformed"] = bool(present)
    return summary


def _upsert_run_op_dispatch(
    session: Any,
    ctx: OperationContext,
    *,
    dbx_run_id: int,
    vibe_session_id: Optional[str],
) -> None:
    """Persist the dispatch-side identifiers on the RunOperation row.

    The orchestrator normally creates the row in :meth:`Orchestrator.start`;
    when dispatch runs outside the orchestrator (e.g. unit tests) the row
    is missing, so we insert a stub keyed on ``ctx.operation_id``. This
    keeps the resume guard (the ``run_op.databricks_run_id`` check above)
    correct on a re-call with the same operation_id.

    Does NOT write ``rollback_state_json`` - the orchestrator's
    ``_dispatch_pending`` persists ``handle.extra`` onto that column right
    after ``dispatch()`` returns, for every primitive generically.
    """
    try:
        run_op = session.get(RunOperation, ctx.operation_id)
    except Exception:
        run_op = None
    if run_op is None:
        run_op = RunOperation(
            id=ctx.operation_id,
            run_id=ctx.run_id,
            step_index=0,
            operation_name="vibe_iterate",
            params_json=json.dumps(ctx.params or {}),
            status="running",
            parent_version_id=ctx.parent_version_id,
        )
        session.add(run_op)
    run_op.databricks_run_id = int(dbx_run_id)
    run_op.vibe_session_id = vibe_session_id
    session.flush()


# Singleton registration on import.
register(VibeIterate())


__all__ = ["VibeIterate", "VibeIterateParams"]

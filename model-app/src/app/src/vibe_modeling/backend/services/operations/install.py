"""``install`` deployment primitive.

Wraps the agent's ``install model`` notebook operation. The op is a pure
deployment side-effect — it does NOT produce a new ``ModelVersion``; the
orchestrator owns version creation and the install consumes whatever
ModelVersion the prior generation step produced.

See ``docs/orchestrator-design.md`` §2 + §10:

- ``produces_version=False``: the install never creates a row in
  ``ModelVersion``. ``parent_version_id`` on ``OperationContext`` points at
  the version being deployed.
- Polling: Jobs API only, no Delta polling. Lifecycle ops don't surface
  ``_vibe_progress`` rows (see ``backend.job_launcher.LIFECYCLE_OPS``).
- Rollback: emit an ``uninstall_schema`` against the catalog + scope_short
  by re-launching the agent's ``uninstall model version`` job.
- Safety gate: rollback refuses (raises) if the in-flight Databricks job
  has already TERMINATED with SUCCESS. The orchestrator's cancel-with-
  rollback path checks Jobs API state first and surfaces a 409 — this
  primitive's rollback enforces the same invariant defensively in case
  the gate is ever bypassed.
"""

from __future__ import annotations

import ast
import logging
import re
from typing import Any, Literal, Optional

from pydantic import BaseModel, Field, model_validator
from sqlmodel import select

from ...core import volume_path_catalog
from ...core._intents import AGENT_OP_INSTALL, AGENT_OP_UNINSTALL
from ...db_models import AgentConfig, ModelVersion
from ...job_launcher import (
    build_job_tags_from_session,
    generate_session_id,
    launch_run,
    session_id_to_bigint,
)
from ..version_files import first_readable_model_json, model_json_candidates
from ._agent_result import agent_exit_result
from ._deployment_widgets import CATALOG_NAME_PATTERN, SCHEMA_PREFIX_PATTERN, scope_label
from ._install_conventions import (
    apply_file_prefix,
    effective_install_params,
    REQUIRED_READ_TIMEOUT_S,
    parse_scoped_conventions,
)
from ..scope_prefix import file_schema_prefix
from ._version_lifecycle import (
    PROMOTED_VERSION_KEY,
    REPLACED_VERSIONS_KEY,
    record_install,
)
from ._protocol import (
    Operation,
    OperationContext,
    OperationDispatchHandle,
    OperationObservation,
    OperationResult,
)

logger = logging.getLogger(__name__)

class InstallParams(BaseModel):
    """Parameters for the ``install`` primitive.

    The agent's ``install model`` op is parameterised by scope, target
    catalog, schema_prefix (chosen by the DAG factory upstream via
    :func:`dag_factories._simple.install_schema_prefix`), the version to install,
    and the cataloging style. Naming-convention pass-throughs are
    forwarded to the agent so the install lays out schemas the same way
    the corresponding generation op did.
    """

    scope: Literal["ecm", "mvm"]
    business_name: str = Field(pattern=r"^[a-z][a-z0-9_]+$")
    deployment_catalog: str = Field(pattern=CATALOG_NAME_PATTERN)
    schema_prefix: str = Field(default="", pattern=SCHEMA_PREFIX_PATTERN)
    model_version: int = Field(gt=0)
    cataloging_style: Literal[
        "One Catalog", "Catalog per Division", "Catalog per Domain"
    ] = "One Catalog"
    naming_convention: str = "snake_case"
    primary_key_suffix: str = "_id"
    table_id_type: str = "BIGINT"
    # The paths the version's ``model.json`` may be at, most likely first
    # (``dag_for_install``): the version's own candidates
    # (``version_files.version_model_json_candidates``: the ``/Volumes/`` file
    # an import read, then the nested and flat folders under its files
    # catalog), then those folders under ``deployment_catalog``.
    # ``Install.dispatch`` sends the first one that parses as the agent's
    # ``context_file``. Empty (a hand-built context): the folders under
    # ``deployment_catalog``.
    context_file_candidates: list[str] = []
    # Convention keys the request set explicitly (``RunIn`` attribute not
    # ``None`` or ``""``); recorded by ``dag_for_install``. For a
    # ``_vibe_scope`` model.json these keep the request value instead of
    # the file's.
    explicit_convention_keys: list[str] = []
    # Lakebase id of the version being installed. Set by the multi-step DAG
    # (uninstall-then-install), whose RunOperation rows carry no
    # ``parent_version_id``; wins over ``ctx.parent_version_id``.
    version_id: Optional[str] = None
    # The request's explicit value, forwarded by ``dag_for_install``. Sent
    # as a widget only for a ``_vibe_scope`` file, where it beats the
    # file's value (``_install_conventions.effective_install_params``).
    # Ordinary installs drop it and the agent uses its own widget defaults.
    schema_suffix: Optional[str] = None
    tag_prefix: Optional[str] = None
    # The ``schema_prefix`` is the installed model.json's own
    # (``_install_conventions.apply_file_conventions`` / ``apply_file_prefix``),
    # never the request's. A blank one is valid in One Catalog: the agent
    # accepts a blank prefix (widget "or blank", nb 37285) and its convention
    # fence needs the file's own value (nb 103772-103786).
    prefix_from_record: bool = False
    # Set by ``dag_for_install`` when the request names no prefix:
    # ``Install.dispatch`` sends the model.json's ``schema_prefix``, ``""``
    # included, and fails the step when the file can't be read.
    prefix_from_version: bool = False
    # The prefix of the version's install into this catalog when it is
    # installed there now (``preflight.inplace_install_prefix``); a typed
    # prefix equal to it is accepted (``typed_prefix_refusal``).
    recorded_prefix: Optional[str] = None

    @model_validator(mode="after")
    def _schema_prefix_matches_cataloging_style(self):
        """Enforce the cross-field rule from spec §2.4.

        - ``One Catalog``: a typed ``schema_prefix`` must not be empty,
          because all scopes share the same catalog and need a per-scope
          namespace. The file's own prefix (``prefix_from_record``, or
          ``prefix_from_version`` before dispatch reads it) may be blank.
        - ``Catalog per Division`` / ``Catalog per Domain``: the per-scope
          catalog already provides the namespace, so a typed
          ``schema_prefix`` is forbidden; the file's own is allowed (its
          stored schema names carry it).
        """
        from_file = self.prefix_from_record or self.prefix_from_version
        if self.cataloging_style == "One Catalog" and not self.schema_prefix and not from_file:
            raise ValueError(
                "One Catalog cataloging_style requires a non-empty schema_prefix"
            )
        if self.cataloging_style != "One Catalog" and self.schema_prefix and not from_file:
            raise ValueError(
                f"{self.cataloging_style} cataloging_style forbids schema_prefix; "
                "leave it empty"
            )
        return self


def _install_context_candidates(p: InstallParams) -> list[str]:
    """The paths to try for this install's ``model.json``, in order."""
    return p.context_file_candidates or model_json_candidates(
        p.deployment_catalog, p.business_name, int(p.model_version), p.scope
    )


def _first_parsed_model_json(
    ws: Any, p: InstallParams, candidates: list[str]
) -> tuple[str, Any]:
    """The first of ``candidates`` that reads and parses, with its content.

    Each read gets ``REQUIRED_READ_TIMEOUT_S`` (upstream industry files reach
    about 24 MB). When none parses, the paths tried go to the server log and
    the step fails with a ``RuntimeError`` naming the scope, version and catalogs: the agent refuses
    an install whose ``context_file`` is not a readable file, and the run's
    error sanitizer redacts ``/Volumes/`` paths, so the message carries none.
    """
    path, root = first_readable_model_json(ws, candidates, timeout_s=REQUIRED_READ_TIMEOUT_S)
    if path is not None:
        return path, root
    logger.error(
        "install: no readable model.json for %s v%s of %s; tried %s",
        p.scope, p.model_version, p.business_name, ", ".join(candidates),
    )
    catalogs = list(dict.fromkeys(filter(None, map(volume_path_catalog, candidates))))
    where = f" in catalog {' or '.join(catalogs)}" if catalogs else ""
    raise RuntimeError(
        f"install: couldn't read the model.json of {p.scope.upper()} version "
        f"{p.model_version} from its folders{where}"
    )


def read_install_model_json(ws: Any, p: InstallParams) -> tuple[Optional[str], Any]:
    """The model.json an install of ``p`` sends and its content: the first
    candidate that reads and parses, else ``(None, None)``. For the
    validate / create checks; ``Install.dispatch`` fails the step instead
    (:func:`_first_parsed_model_json`)."""
    try:
        return _first_parsed_model_json(ws, p, _install_context_candidates(p))
    except RuntimeError:
        return None, None


def typed_prefix_refusal(p: InstallParams, root: Any) -> Optional[str]:
    """Why a typed ``schema_prefix`` (the request set it,
    ``explicit_convention_keys``) is refused, or ``None``: it differs from the
    prefix in the version's readable model.json and, for an in-place
    reinstall, from the recorded one (``recorded_prefix``). The agent would rebuild
    every schema name with the typed prefix (``_convention_changed``, nb
    103545-103576) and drop the metric views that then fail (nb
    104295-104355)."""
    if "schema_prefix" not in p.explicit_convention_keys:
        return None
    if p.recorded_prefix is not None and p.schema_prefix == p.recorded_prefix:
        return None
    file_prefix = file_schema_prefix(root)
    if file_prefix is None or file_prefix == p.schema_prefix:
        return None
    uses = f"the schema prefix {file_prefix!r}" if file_prefix else "no schema prefix"
    return (
        f"This version's model file uses {uses}. Installing with {p.schema_prefix!r} renames "
        "its schemas and the agent drops its metric views. Leave Schema Prefix empty."
    )


def _build_install_widgets(
    p: InstallParams, session_id_bigint: str, context_file: Optional[str] = None
) -> dict[str, str]:
    """Compose the ``install model`` widget map.

    The DAG factory resolves ``deployment_catalog`` and ``schema_prefix``
    (:func:`dag_factories._simple.install_schema_prefix`) before
    constructing the params; ``Install.dispatch`` only swaps in the
    model.json's own prefix (``_install_conventions``).

    ``context_file`` is the readable candidate ``Install.dispatch`` chose
    (:func:`_first_parsed_model_json`); without one, the version's first
    candidate path.

    ``schema_suffix`` and ``tag_prefix`` are added only when set, which
    ``Install.dispatch`` allows only for a ``_vibe_scope`` file; every
    other install sends the ordinary widget set.
    """
    widgets = {
        "operation": AGENT_OP_INSTALL,
        "business_name": p.business_name,
        "deployment_catalog": p.deployment_catalog,
        "data_model_scopes": scope_label(p.scope),
        "model_version": str(p.model_version),
        "context_file": context_file or _install_context_candidates(p)[0],
        "schema_prefix": p.schema_prefix,
        "cataloging_style": p.cataloging_style,
        "naming_convention": p.naming_convention,
        "primary_key_suffix": p.primary_key_suffix,
        "table_id_type": p.table_id_type,
        "vibe_session_id": session_id_bigint,
    }
    if p.schema_suffix is not None:
        widgets["schema_suffix"] = p.schema_suffix
    if p.tag_prefix is not None:
        widgets["tag_prefix"] = p.tag_prefix
    return widgets


def _resolve_agent_job_id(session: Any) -> Optional[int]:
    """Look up the configured agent job id, or ``None`` if unconfigured."""
    cfg = session.exec(select(AgentConfig).limit(1)).first()
    if not cfg or not cfg.job_id:
        return None
    return cfg.job_id


def _record_install(
    session: Any, version_id: Optional[str], catalog: str, run_id: str, cataloging_style: str,
) -> dict:
    """Apply a successful install to the target version's state
    (:func:`_version_lifecycle.record_install`): installed in ``catalog``,
    displaced same-scope versions there uninstalled, and promoted to the
    scope head when the install makes it current. Returns the promotion
    keys for the op's ``rollback_state`` (empty when nothing was promoted),
    which the run's terminal step reads to move the feedback.

    No-op for a missing ``version_id`` or row (a hand-built context).
    """
    if not version_id:
        return {}
    mv = session.get(ModelVersion, version_id)
    if mv is None:
        return {}
    outcome = record_install(
        session, mv, run_id=run_id, catalog=catalog, cataloging_style=cataloging_style,
    )
    if not outcome.promoted:
        return {}
    return {PROMOTED_VERSION_KEY: mv.id, REPLACED_VERSIONS_KEY: outcome.replaced_ids}


_UNREADABLE = (
    "The agent's result could not be read, so the install is not recorded as "
    "installed. Install again."
)


_INTEGRITY_FAILED = "INTEGRITY CHECK FAILED"

# The registrar's summary warning (nb 53659-53662): "[metamodel-registrar
# FIRED v5.1.4] <business> v<N> (<scope>) -> <db>: domains d/D, products p/P,
# attributes a/A, business_row=..., deploy_status=..., errors=[...]", where
# ``errors`` is the repr of its first three error strings (nb 53613: "delete
# <table>: <exception text cut at 200>").
_REGISTRAR_SUMMARY = re.compile(
    r"\[metamodel-registrar FIRED [^\]]*\].*?"
    r"domains (\d+)/(\d+), products (\d+)/(\d+), attributes (\d+)/(\d+),"
    r".*?errors=(\[.*\]) alias=metamodel-registrar",
    re.DOTALL,
)
_CONCURRENT_WRITE = re.compile(r"Concurrent\w*Exception|DELTA_CONCURRENT_")

_CONCURRENT_REGISTRY_WRITE_MESSAGE = (
    "The agent created the tables but a concurrent write to its registry "
    "failed. Run the install again; it finishes the registration."
)


def _is_concurrent_registry_write(result: dict, warnings: list[str]) -> bool:
    """True when the only registration error is the agent's ``DELETE`` of its
    own ``_metamodel.business`` row losing a Delta write race.

    The agent's progress flush updates that row from a background thread
    (``VibeWriter._update_session_ready``, nb 52878-52886) while the
    registrar deletes and re-inserts it (nb 53609-53613) with no retry. The
    registrar still writes every domain, product and attribute row, so the
    summary shows full counts. A second install deletes and re-inserts the
    row cleanly.
    """
    physical = result.get("physical")
    if not (isinstance(physical, dict) and physical.get("success") is True):
        return False
    for warning in warnings:
        match = _REGISTRAR_SUMMARY.search(warning)
        if not match:
            continue
        counts = [int(n) for n in match.groups()[:6]]
        if any(done != total for done, total in zip(counts[::2], counts[1::2])):
            return False
        try:
            errors = ast.literal_eval(match.group(7))
        except (ValueError, SyntaxError):
            return False
        return (
            isinstance(errors, list) and len(errors) > 0
            and all(
                isinstance(e, str) and e.startswith("delete business:")
                and _CONCURRENT_WRITE.search(e) is not None
                for e in errors
            )
        )
    return False


def _registration_failure(result: Optional[dict]) -> Optional[str]:
    """Why an install the job reports as succeeded did not register, or None.

    The agent's ``install model`` exit JSON (nb 108138-108150) carries
    ``metamodel.success`` (its ``_metamodel`` registration of the version) and
    the warnings, among them its post-install integrity check (nb
    108093-108101: "INTEGRITY CHECK FAILED: expected N domain schemas ...,
    found M"). The job still ends SUCCESS with status
    ``success_with_warnings``. Either signal means the agent's registry does
    not hold the version, so its later uninstall finds nothing to remove.
    """
    if not result:
        return None
    metamodel = result.get("metamodel")
    failed_registration = isinstance(metamodel, dict) and metamodel.get("success") is False
    warnings = [str(w).strip() for w in (result.get("warnings") or []) if str(w).strip()]
    integrity = [w for w in warnings if _INTEGRITY_FAILED in w]
    if not failed_registration and not integrity:
        return None
    from ...error_sanitization import sanitize_error_message

    if not integrity and _is_concurrent_registry_write(result, warnings):
        return _CONCURRENT_REGISTRY_WRITE_MESSAGE

    detail = "; ".join(integrity + [w for w in warnings if "Metamodel" in w and w not in integrity])
    return sanitize_error_message(
        "The agent created the tables but did not register the version in its "
        "_metamodel registry, so it is not recorded as installed. Run the "
        "install again." + (f" Agent: {detail}" if detail else "")
    )


def _terminal_observation(
    *, succeeded: bool, error: Optional[str], rollback_state: dict
) -> OperationObservation:
    """Build a terminal observation."""
    return OperationObservation(
        progress_percent=100,
        progress_message="completed" if succeeded else (error or "failed"),
        is_terminal=True,
        terminal_result=OperationResult(
            succeeded=succeeded,
            output_version_id=None,  # install never produces a version
            output_artifacts=[],
            rollback_state=rollback_state,
            error=error,
        ),
    )


class Install(Operation):
    """``install model`` primitive (Group B — deployment).

    See module docstring for the rollback strategy and safety gate.
    """

    name = "install"
    params_model = InstallParams
    is_idempotent = True
    produces_version = False

    def dispatch(
        self,
        ctx: OperationContext,
        ws: Any,
        session: Any,
    ) -> OperationDispatchHandle:
        params = InstallParams(**ctx.params)

        job_id = _resolve_agent_job_id(session)
        if not job_id:
            raise RuntimeError(
                "Agent not configured — cannot dispatch `install` primitive."
            )

        # A ``_vibe_scope`` model.json must be installed with its own
        # conventions or the agent's convention fence rejects it, and a Dry
        # Run draft is installed with the conventions the user reviewed.
        # Read the exact file this dispatch sends: the first candidate that
        # parses (none: the step fails naming the catalogs). Any other file
        # sends the ordinary install widgets, with the file's own prefix when
        # the step takes the version's (``prefix_from_version``).
        target_id = params.version_id or ctx.parent_version_id
        target = session.get(ModelVersion, target_id) if target_id else None
        context_file, root = _first_parsed_model_json(
            ws, params, _install_context_candidates(params)
        )
        refusal = typed_prefix_refusal(params, root)
        if refusal is not None:
            raise RuntimeError(refusal)
        params, conventions_source = effective_install_params(
            params,
            parse_scoped_conventions(root, any_file=getattr(target, "dry_run", False) is True),
        )
        if conventions_source is None and params.prefix_from_version:
            params, conventions_source = apply_file_prefix(
                params, parse_scoped_conventions(root, any_file=True) or {},
            )

        sid = generate_session_id()
        sid_bigint = str(session_id_to_bigint(sid))
        widgets = _build_install_widgets(params, sid_bigint, context_file)

        job_tags = build_job_tags_from_session(
            session,
            business_name=params.business_name,
            model_scope=params.scope,
            version=str(params.model_version),
            operation="install",
            session_id=sid,
        )
        dbx_run_id = launch_run(ws, job_id, widgets, job_tags=job_tags)
        return OperationDispatchHandle(
            databricks_run_id=dbx_run_id,
            vibe_session_id=sid,
            extra={
                "scope": params.scope,
                "deployment_catalog": params.deployment_catalog,
                "schema_prefix": params.schema_prefix,
                "model_version": params.model_version,
                "business_name": params.business_name,
                "cataloging_style": params.cataloging_style,
                **(
                    {"conventions_source": conventions_source}
                    if conventions_source is not None
                    else {}
                ),
            },
            dispatched_widgets=widgets,
        )

    def observe(
        self,
        handle: OperationDispatchHandle,
        ctx: OperationContext,
        ws: Any,
        session: Any,
    ) -> OperationObservation:
        if handle.databricks_run_id is None:
            return OperationObservation(
                progress_percent=0,
                progress_message="awaiting dispatch",
                is_terminal=False,
                terminal_result=None,
            )

        try:
            job_run = ws.jobs.get_run(handle.databricks_run_id)
        except Exception as e:  # noqa: BLE001 — surface the message
            return OperationObservation(
                progress_percent=0,
                progress_message=f"poll error: {e!r}",
                is_terminal=False,
                terminal_result=None,
            )

        state = getattr(job_run, "state", None)
        lcs = ""
        rs = ""
        state_message = ""
        if state is not None:
            lcs_obj = getattr(state, "life_cycle_state", None)
            rs_obj = getattr(state, "result_state", None)
            lcs = getattr(lcs_obj, "value", "") if lcs_obj is not None else ""
            rs = getattr(rs_obj, "value", "") if rs_obj is not None else ""
            state_message = getattr(state, "state_message", "") or ""

        rollback_state = {
            "databricks_run_id": handle.databricks_run_id,
            "deployment_catalog": handle.extra.get("deployment_catalog", ""),
            "schema_prefix": handle.extra.get("schema_prefix", ""),
            "scope": handle.extra.get("scope", ""),
            "model_version": handle.extra.get("model_version"),
            "business_name": handle.extra.get("business_name", ""),
            "cataloging_style": handle.extra.get("cataloging_style", ""),
            "jobs_terminal_result_state": rs,
        }

        if lcs == "TERMINATED":
            succeeded = rs == "SUCCESS"
            error = None if succeeded else (state_message or f"Job ended with {rs}")
            if succeeded:
                exit_result = agent_exit_result(
                    ws, job_run, handle.databricks_run_id, unreadable=_UNREADABLE,
                )
                if exit_result.retry:
                    return OperationObservation(
                        progress_percent=90,
                        progress_message="reading the agent's result",
                        is_terminal=False,
                        terminal_result=None,
                    )
                refusal = exit_result.failure or _registration_failure(exit_result.result)
                if refusal is not None:
                    # The tables may exist but the app cannot confirm the
                    # agent registered this version, so it is not recorded
                    # as installed and nothing is promoted or evicted. The
                    # failed row is not rolled back by the orchestrator; its
                    # rollback state keeps the run diagnostics.
                    from ...error_sanitization import sanitize_error_message

                    return _terminal_observation(
                        succeeded=False, error=sanitize_error_message(refusal), rollback_state=rollback_state,
                    )
                # The agent's install job just created the target schemas:
                # record that in Lakebase (deployed + uc_catalog, and the
                # promotion when this install makes the version current).
                params = InstallParams(**ctx.params)
                rollback_state.update(_record_install(
                    session,
                    params.version_id or ctx.parent_version_id,
                    handle.extra.get("deployment_catalog", ""),
                    ctx.run_id,
                    params.cataloging_style,
                ))
            return _terminal_observation(
                succeeded=succeeded, error=error, rollback_state=rollback_state
            )
        if lcs in ("INTERNAL_ERROR", "SKIPPED"):
            return _terminal_observation(
                succeeded=False,
                error=state_message or lcs,
                rollback_state=rollback_state,
            )
        return OperationObservation(
            progress_percent=10,
            progress_message=f"{lcs}/{rs}" if lcs else "running",
            is_terminal=False,
            terminal_result=None,
        )

    def rollback(
        self,
        ctx: OperationContext,
        rollback_state: dict,
        ws: Any,
        session: Any,
    ) -> None:
        """Emit an ``uninstall model version`` against the install target.

        Idempotent: a re-call against an already-uninstalled schema is the
        agent's responsibility to handle as a no-op (it does — uninstall
        is itself idempotent against missing schemas, see §10 failure
        table for the ``uninstall`` primitive).

        Safety gate: refuse to roll back if the in-flight job terminated
        SUCCESS. The orchestrator's cancel-with-rollback path performs
        the same check up front; this is a defence-in-depth invariant so
        the gate cannot be silently bypassed by a future caller.
        """
        terminal_rs = rollback_state.get("jobs_terminal_result_state", "")
        if terminal_rs == "SUCCESS" or rollback_state.get("job_terminated_success"):
            # Last observation reported the install completed cleanly. We
            # never tear down a successful install — the operator must do
            # that explicitly via the uninstall route.
            raise RuntimeError(
                "Refusing to roll back `install`: the in-flight Databricks "
                "job terminated SUCCESS at cancel time. Use the "
                "`uninstall` primitive directly to tear down a completed "
                "install."
            )

        # Accept either the canonical legacy widget key (``deployment_catalog``)
        # or the short-form key (``catalog``) the orchestrator may pass when
        # constructing rollback_state from a different source. Same for
        # ``model_version`` vs the legacy internal name ``version_int``.
        catalog = rollback_state.get("deployment_catalog") or rollback_state.get(
            "catalog", ""
        )
        version = rollback_state.get("model_version") or rollback_state.get(
            "version_int"
        )
        business_name = rollback_state.get("business_name", "")
        if not catalog or not version or not business_name:
            # Insufficient state to reverse — likely the original dispatch
            # never reached the agent (RuntimeError before
            # ``launch_run``). Treat as no-op rather than blowing up the
            # rollback chain.
            return

        job_id = _resolve_agent_job_id(session)
        if not job_id:
            # Agent unconfigured — schemas can't be torn down here.
            # No-op fallback rather than failing the chain.
            return

        sid = generate_session_id()
        sid_bigint = str(session_id_to_bigint(sid))
        # ``model_version`` may arrive as an int (from observe()) or a str
        # (from a hand-constructed rollback_state). The agent's metamodel
        # stores the bare integer; sending "v<n>" makes the uninstall's
        # version_candidates regex (^(\d+)) miss every install. Strip a
        # leading 'v' if present.
        model_version_widget = (
            str(version)[1:] if str(version).startswith("v") else str(version)
        )
        widgets = {
            "operation": AGENT_OP_UNINSTALL,
            "business_name": business_name,
            "deployment_catalog": catalog,
            "model_version": model_version_widget,
            "schema_prefix": rollback_state.get("schema_prefix", ""),
            "cataloging_style": rollback_state.get("cataloging_style", "One Catalog"),
            "vibe_session_id": sid_bigint,
        }
        # Fire-and-forget: the rollback chain is non-blocking. The
        # uninstall run is visible in the Jobs UI for operator follow-up.
        rollback_job_tags = build_job_tags_from_session(
            session,
            business_name=business_name,
            version=model_version_widget,
            operation=AGENT_OP_UNINSTALL,
            session_id=sid,
        )
        launch_run(ws, job_id, widgets, job_tags=rollback_job_tags)

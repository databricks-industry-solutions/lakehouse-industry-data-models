"""DAG validator — the single pure function called by both
``POST /runs/validate`` (live form feedback) and ``POST /runs`` (hard
submit). See ``docs/orchestrator-design.md`` §2.4 + §2.4.1.

This module owns the ``validate_dag`` primitive: given a built ``Dag``
plus a way to look operations up by name, walk the DAG and collect every
field-level (Pydantic) and cross-step (Dag) issue without raising.

The higher-level ``validate_dag_request(req, business, context,
agent_config)`` coordinator — which selects the DAG factory from
``req.intent`` and produces the ``Dag`` — belongs to the Phase 4 wirer
slice. Phase 1 owns only this primitive.
"""

from dataclasses import dataclass
from typing import Callable, Collection, Optional, TYPE_CHECKING

from pydantic import ValidationError

from ._types import Issue
from .dag import Dag

from ..operations._protocol import Operation
from ...models import Intent

if TYPE_CHECKING:
    from ...db_models import AgentConfig, Business, BusinessContext
    from ...models import RunIn


@dataclass(frozen=True, slots=True)
class ValidationResult:
    """Outcome of validating a Dag.

    ``dag`` is the original DAG when there are no blockers (so the
    caller can carry it forward into ``orchestrator.start``), and
    ``None`` when at least one blocker was found (``POST /runs`` returns
    400 in that case).

    ``warnings`` flow through to ``POST /runs`` callers regardless — the
    UI surfaces them as "Submit anyway" confirmations per spec §2.4.
    """

    dag: Optional[Dag]
    blockers: list[Issue]
    warnings: list[Issue]


def validate_dag(
    dag: Dag,
    *,
    registry_get: Callable[[str], Operation],
) -> ValidationResult:
    """Validate every step of ``dag`` and collect all findings.

    Pure function. No I/O, no DB, no logging. ``registry_get`` is
    injected so:

    - Unit tests pass a fake registry without bootstrapping the real one.
    - The Phase 4 wirers can pass ``services.operations._registry.get``
      after the integrator merges that branch.

    The validation walks per spec §2.4.1:

    1. Gate A — name resolution: ``registry_get(step.name)``.
       ``KeyError`` → blocker, continue (skip Gate B for this step).
    2. Gate B — field-level + within-step: ``op.params_model(**params)``.
       ``ValidationError`` → one blocker per ``err`` in
       ``e.errors()``.
    3. Gate C — cross-step: ``dag.validate_cross_step()``.

    Warnings are emitted only by DAG factories (Phase 4) before the DAG
    reaches this function; the validator itself currently produces only
    blockers. The ``warnings`` field is preserved on the result so the
    coordinator (``validate_dag_request``, Phase 4) can pass through any
    warnings it received from the factory.
    """
    blockers: list[Issue] = []
    warnings: list[Issue] = []

    # Track which step names belong to version-producing ops so we can
    # flag duplicate ``output_version_id`` bindings (rule below). The
    # orchestrator binds an op's ``output_version_id`` to its step name
    # at dispatch time (see ``Orchestrator._inherit_parent_version``);
    # two version-producing steps that share a name would emit two
    # ModelVersions under one identifier, silently breaking lineage.
    version_producing_step_indices: dict[str, list[int]] = {}

    for i, step in enumerate(dag.steps):
        # Gate A — does this primitive exist?
        try:
            op = registry_get(step.name)
        except KeyError:
            blockers.append(
                Issue(
                    field_path=f"steps[{i}].name",
                    step_index=i,
                    message=f"Unknown primitive: '{step.name}'",
                    severity="blocker",
                )
            )
            # Skip Gate B for this step; we have nothing to validate
            # ``params`` against.
            continue

        # Gate B — field-level + within-step rules via Pydantic.
        try:
            op.params_model(**step.params)
        except ValidationError as e:
            for err in e.errors():
                # err["loc"] is a tuple like ("schema_prefix",) or
                # ("nested", "field"). Join it for a stable
                # ``field_path`` the UI can render.
                loc = ".".join(str(p) for p in err["loc"])
                blockers.append(
                    Issue(
                        field_path=(
                            f"steps[{i}].params.{loc}"
                            if loc
                            else f"steps[{i}].params"
                        ),
                        step_index=i,
                        message=err["msg"],
                        severity="blocker",
                    )
                )

        # Track version-producing steps for the duplicate-output rule
        # below. Skip non-producing primitives (``install``, etc.) —
        # multi-catalog DAGs legitimately repeat them once per scope.
        if getattr(op, "produces_version", False):
            version_producing_step_indices.setdefault(step.name, []).append(i)

    # Cross-step rule — duplicate ``output_version_id`` binding. Lives
    # here (not in ``Dag.validate_cross_step``) because it needs the
    # registry to know which steps actually produce a ModelVersion.
    # Flag every duplicate after the first so the operator sees which
    # step name needs renaming.
    for step_name, indices in version_producing_step_indices.items():
        if len(indices) <= 1:
            continue
        for i in indices[1:]:
            blockers.append(
                Issue(
                    field_path=f"steps[{i}].name",
                    step_index=i,
                    message=(
                        f"Duplicate output_version_id: step name "
                        f"'{step_name}' is bound by {len(indices)} "
                        f"version-producing steps; output lineage cannot "
                        f"be disambiguated"
                    ),
                    severity="blocker",
                )
            )

    # Gate C — cross-step rules.
    blockers.extend(dag.validate_cross_step())

    return ValidationResult(
        dag=dag if not blockers else None,
        blockers=blockers,
        warnings=warnings,
    )


# --- Coordinator -----------------------------------------------------------
#
# Higher-level entry point used by both ``POST /runs/validate`` and
# ``POST /runs`` per spec §2.4.1. Picks the DAG factory by ``req.intent``,
# composes the DAG, then delegates to ``validate_dag`` for Gates A–C.


def validate_dag_request(
    req: "RunIn",
    business: "Business",
    business_context: "Optional[BusinessContext]" = None,
    agent_config: "Optional[AgentConfig]" = None,
    *,
    registry_get: Optional[Callable[[str], Operation]] = None,
) -> ValidationResult:
    """Build the DAG for ``req.intent`` and validate it.

    Pure function — no DB, no I/O. The route handler is responsible for
    loading ``business`` / ``business_context`` / ``agent_config`` from
    Lakebase before calling this.

    Returns a :class:`ValidationResult`:

    - ``dag``: the composed :class:`Dag` (``None`` when blockers found).
    - ``blockers``: list of ``Issue(severity="blocker")``.
    - ``warnings``: list of ``Issue(severity="warning")``.

    The handler maps ``blockers`` to HTTP 400 on ``POST /runs`` and
    echoes them inline for the ``POST /runs/validate`` form-feedback
    surface; warnings flow through to both gates so the UI can show a
    "Submit anyway" confirmation.
    """
    # Lazy import: avoid a circular edge between models.py + this module
    # at import time. ``models.py`` does not depend on the orchestrator
    # package — keeping this import inside the function keeps it that
    # way.
    from .dag_factories import (
        dag_for_new_base_model,
        dag_for_vibe_new_ecm_mvm,
    )
    from ..operations._registry import get as default_registry_get

    rget = registry_get or default_registry_get

    # Pick the factory. New intents land here as additional branches —
    # the other Phase 4 wirers (simple, recovery) own theirs.
    intent_value = (
        req.intent.value if req.intent is not None else None
    )

    if intent_value == Intent.NEW_BASE_MODEL.value:
        dag = dag_for_new_base_model(req, business, business_context, agent_config)
        return validate_dag(dag, registry_get=rget)

    if intent_value == Intent.VIBE_NEW_ECM_MVM.value:
        dag = dag_for_vibe_new_ecm_mvm(
            req, business, business_context, agent_config
        )
        return validate_dag(dag, registry_get=rget)

    # No DAG factory wired for this intent yet. This is not a submission
    # blocker: intents outside the two wired above (vibe-iterate, install,
    # uninstall, import-from-volume) still submit
    # through the standard (non-orchestrator) pipeline; only the
    # ``POST /runs/validate`` preview is unavailable. Surface a warning so
    # the run form's "Submit anyway" flow stays open per spec §2.4.
    return ValidationResult(
        dag=None,
        blockers=[],
        warnings=[
            Issue(
                field_path="intent",
                step_index=-1,
                message=(
                    f"Run-plan preview is not available for intent "
                    f"{intent_value!r} yet; submission uses the standard "
                    f"pipeline."
                ),
                severity="warning",
            )
        ],
    )


# --- Per-intent gates that require DB lookups -------------------------------
#
# ``validate_dag_request`` is a pure function: no DB session, no workspace
# client. A handful of cross-step rules need to consult the resolved parent
# ``ModelVersion`` (e.g. "for vibe-new-ecm-mvm the parent must be
# ECM-scoped"). The route handler resolves that row and calls these helpers
# directly before / alongside ``validate_dag_request``.


def parent_scope_blocker_for_intent(intent_value: str, parent_mv) -> Optional[Issue]:
    """Return a blocker if the parent ``ModelVersion`` is the wrong scope
    for the supplied intent, or ``None`` when the parent is acceptable
    (or no scope rule exists for this intent).

    Today only ``vibe-new-ecm-mvm`` carries a parent-scope constraint:
    the run vibes the parent ECM and then shrinks it to MVM, so an
    MVM parent would be nonsensical. Empty/unset scope on the parent
    is treated as legacy ECM (the original ECM rows pre-date the
    ``scope`` column's per-scope values).
    """
    if intent_value != Intent.VIBE_NEW_ECM_MVM.value:
        return None
    if parent_mv is None:
        return Issue(
            field_path="parent_version_id",
            step_index=-1,
            message=(
                "vibe-new-ecm-mvm requires a parent ECM model version; "
                "none was supplied."
            ),
            severity="blocker",
        )
    raw = (getattr(parent_mv, "scope", "") or "").strip().lower()
    # "" (legacy) and "ecm" both qualify as ECM. Anything else (notably
    # "mvm") is rejected.
    if raw in ("", "ecm"):
        return None
    return Issue(
        field_path="parent_version_id",
        step_index=-1,
        message="Parent version must be an ECM scope",
        severity="blocker",
    )


# Intents that dispatch a generation-group agent op with an empty
# ``business_description`` widget when the business has no description (and no
# inline/file override); the agent's notebook widget validator hard-rejects
# ("Business description is required") for every operation except
# install/uninstall/generate-samples, but only these three intents reach that
# validator via a FRESH description-mode dispatch with no already-durable
# model.json to fall back on: install/uninstall/generate-samples operate on
# an already-completed version (exempted agent-side) and import-from-volume
# never reaches the agent at all.
_DESCRIPTION_REQUIRED_INTENTS: frozenset[str] = frozenset({
    Intent.NEW_BASE_MODEL.value,
    Intent.VIBE_ITERATE.value,
    Intent.VIBE_NEW_ECM_MVM.value,
})


def business_description_blocker_for_intent(
    intent_value: str,
    business,
    *,
    business_context_text: str = "",
    business_context_path: str = "",
) -> Optional[Issue]:
    """Return a blocker when a model-producing intent would dispatch to the
    agent with an empty ``business_description`` widget and no rescuing
    context, or ``None`` when the business carries enough context (or the
    intent has no such requirement).

    The agent needs EITHER a non-empty description OR an already-loaded
    context file to resolve the business identity/complexity tier; without
    either it aborts ~1 minute into compute with "Business description is
    required" (see the agent's per-op required-widget validator). Catching
    this here turns that wasted minute into an inline submit-time blocker.

    Both overrides rescue a blank description for all three gated intents:
    ``business_context_text`` (inline text) feeds ``business_description``
    directly, and ``business_context_path`` (a Volume model.json path) feeds
    the agent's ``context_file`` widget; every DAG factory that reaches a
    gated intent threads both through (``dag_for_vibe_iterate`` via
    ``_optional_convention_params``'s ``business_context_path`` carry-key,
    the unified factory via ``req.business_context_path`` directly).
    """
    if intent_value not in _DESCRIPTION_REQUIRED_INTENTS:
        return None
    description = (
        (business_context_text or "").strip()
        or (getattr(business, "description", "") or "").strip()
    )
    if description:
        return None
    if (business_context_path or "").strip():
        return None
    return Issue(
        field_path="business_description",
        step_index=-1,
        message=(
            "Add a business description (Edit business) before launching "
            "a run."
        ),
        severity="blocker",
    )


def deployed_version_reinstall_warning(
    intent_value: str,
    target_mv,
    target_catalog: str,
    session,
) -> Optional[Issue]:
    """Return a warning when an install run targets a ``ModelVersion``
    that's already recorded as deployed to this exact catalog, or ``None``
    when the run is safe (or the gate doesn't apply).

    Submitting an install over an already-installed version dispatches the
    agent, which burns ~6 minutes of compute before its own downstream
    clash guard rejects the run (installing over an already-installed
    version is illegal). Catching the same fact here turns that wasted
    run into an inline, submit-time notice.

    The version's installed catalogs are its open install rows
    (``_version_lifecycle.installed_catalogs``), so a version installed in
    several catalogs warns for each.

    Deliberately a warning, never a blocker: re-installing after an
    out-of-band ``DROP SCHEMA``, or a stale reconcile/drift read, are
    legitimate workflows this gate must not prevent.

    Called once, by the run pre-flight (``preflight.run_preflight``), whose
    warnings feed both the ``POST /runs/validate`` live form-warning surface
    and ``RunOut.warnings`` on the actual submit.
    """
    if intent_value != Intent.INSTALL.value:
        return None
    if target_mv is None:
        return None
    catalog = (target_catalog or "").strip()
    if not catalog:
        return None
    from ..operations._version_lifecycle import installed_catalogs

    if catalog.lower() not in {c.lower() for c in installed_catalogs(session, target_mv)}:
        return None
    return Issue(
        field_path="version_id",
        step_index=-1,
        message=(
            f"This version is already recorded as deployed to {catalog}; "
            "re-installing without uninstalling first will fail the "
            "agent's clash check."
        ),
        severity="warning",
    )


# --- Install confirmations (subject-bound) ---------------------------------

INSTALL_OVER_NEWER = "install_over_newer"
INSTALL_REPLACES_IN_CATALOG = "install_replaces_in_catalog"
INSTALL_OVERWRITES_SCHEMAS = "install_overwrites_schemas"


def confirm_subject(kind: str, *parts: str) -> str:
    """A confirm issue's subject: its kind and what it is bound to, joined
    by ``:``. A catalog part is lower-cased (Unity Catalog folds names), so
    validate and create build the same key."""
    return ":".join([kind, *parts])


def install_over_newer_subject(head_id: str) -> str:
    return confirm_subject(INSTALL_OVER_NEWER, head_id)


def install_replaces_subject(occupant_id: str) -> str:
    return confirm_subject(INSTALL_REPLACES_IN_CATALOG, occupant_id)


def install_overwrites_subject(version_id: str, catalog: str) -> str:
    """The confirm subject of an install into schemas this business does not
    own in ``catalog``."""
    return confirm_subject(INSTALL_OVERWRITES_SCHEMAS, version_id, (catalog or "").strip().lower())


_SUMMARY_MAX = 120


def _versions_phrase(numbers: list[int]) -> str:
    labels = [f"v{n}" for n in numbers]
    if len(labels) <= 1:
        return "".join(labels)
    return ", ".join(labels[:-1]) + f" and {labels[-1]}"


def _instructions_summary(mv) -> str:
    text = " ".join((getattr(mv, "vibe_instructions", "") or "").split())
    if not text:
        return f"v{mv.version}: no instructions recorded"
    if len(text) > _SUMMARY_MAX:
        text = text[: _SUMMARY_MAX - 1].rstrip() + "…"
    return f"v{mv.version}: {text}"


def install_confirm_issues(session, target_mv, target_catalog: str) -> list[Issue]:
    """The ``confirm`` issues an install of ``target_mv`` into
    ``target_catalog`` needs, each bound to its subject.

    * ``install_over_newer:<head id>`` when the install makes ``target_mv``
      current (``_version_lifecycle.will_promote``) and drops newer versions:
      names each one, what it changed, and the feedback that is reopened.
    * ``install_replaces_in_catalog:<occupying version id>`` when another
      version of the business and scope is installed in the catalog: the
      install uninstalls it first and recreates every table.

    Both ``POST /runs/validate`` and ``POST /runs`` compute them here, so a
    subject that appears between the two (another run finished) is new and
    unconfirmed.
    """
    from ...core._vibe_scope import scope_head
    from ..operations._version_lifecycle import (
        agent_counts_in,
        catalog_occupant,
        dropped_versions,
        inputs_to_reopen,
        will_promote,
    )

    issues: list[Issue] = []
    if target_mv is None:
        return issues
    scope = (target_mv.scope or "").upper()
    target = f"v{target_mv.version}"
    occupant = catalog_occupant(session, target_mv, target_catalog)
    if will_promote(session, target_mv, target_catalog):
        dropped = dropped_versions(session, target_mv)
        if dropped:
            head = scope_head(session, target_mv.business_id, target_mv.scope) or dropped[0]
            numbers = sorted(int(mv.version) for mv in dropped)
            names = _versions_phrase(numbers)
            reopened = len(inputs_to_reopen(session, dropped))
            feedback = (
                f"{reopened} feedback item{'s' if reopened != 1 else ''} applied in {names} "
                f"{'are' if reopened != 1 else 'is'} reopened (not selected; you can select "
                f"them after the install)."
                if reopened
                else f"No feedback applied in {names} is recorded, so none is reopened."
            )
            changes = "; ".join(_instructions_summary(mv) for mv in sorted(dropped, key=lambda m: m.version))
            # The replaced versions above the target that the agent's registry in this
            # catalog still counts after the install block a scoped run on it there
            # (``vibe_catalog_issues``). A lower one never does. The occupant does not:
            # the install uninstalls it first, which releases its rows. The
            # ``vibe_scope_base`` blocker also counts earlier-replaced versions and Dry
            # Run drafts above the target and names them at run time.
            above = [mv for mv in dropped if int(mv.version) > int(target_mv.version)
                     and (occupant is None or mv.id != occupant.id)]
            counted = agent_counts_in(session, [mv.id for mv in above], target_catalog, fold_case=True)
            blocking = sorted(int(mv.version) for mv in above if mv.id in counted)
            scoped_note = (
                f" Scoped runs on {target} in {target_catalog} are refused by the agent until "
                f"{_versions_phrase(blocking)} {'are' if len(blocking) > 1 else 'is'} "
                f"deleted: {'they stay' if len(blocking) > 1 else 'it stays'} in the agent's "
                f"registry there after {'they are' if len(blocking) > 1 else 'it is'} replaced."
                if blocking
                else ""
            )
            issues.append(Issue(
                field_path="version_id",
                step_index=-1,
                message=(
                    f"v{head.version} is the latest {scope} version. Installing {target} makes "
                    f"{target} the latest and replaces {names}. Their changes that are not in "
                    f"{target} are dropped: {changes}. {feedback}{scoped_note}"
                ),
                severity="confirm",
                subject=install_over_newer_subject(head.id),
                versions=tuple(numbers),
            ))
    if occupant is not None:
        held = f"v{occupant.version}"
        issues.append(Issue(
            field_path="catalog",
            step_index=-1,
            message=(
                f"Catalog {target_catalog} holds {held}. To install {target} there, the app "
                f"first uninstalls {held}, then installs {target} in full. Every table of this "
                f"model in {target_catalog} is recreated and loses its rows. If the install "
                f"fails after the uninstall, {target_catalog} is left without this model until "
                f"you install a version again. To keep {target_catalog} as it is, install "
                f"{target} into another catalog instead."
            ),
            severity="confirm",
            subject=install_replaces_subject(occupant.id),
        ))
    return issues


# --- Plain uninstall: data loss (subject-bound) ------------------------------

# The subject is ``uninstall_destroys_data:<version id>:<catalog>`` (add §6.2):
# ``services.uninstall_impact.uninstall_confirm_subject`` builds it. An
# uninstall-then-install asks only ``install_replaces_in_catalog``, which
# carries the same loss, so the dialog has one checkbox for one action.


def uninstall_confirm_issues(
    session,
    ws,
    warehouse_id: str,
    target_mv,
    target_catalog: str,
    *,
    cataloging_style: Optional[str],
    confirmed: Collection[str],
    user: Optional[str] = None,
    fresh: bool = False,
) -> list[Issue]:
    """The ``confirm`` issue a plain uninstall of ``target_mv`` from
    ``target_catalog`` needs when its tables hold rows or could not be checked.

    A subject already in ``confirmed`` covers the worst case, so the impact
    is not computed again for it (R8): the usual create runs no scan while it
    holds the business. Otherwise the impact comes from
    ``services.uninstall_impact`` (cached 60 s; ``fresh`` skips the cache, for
    a create that was not confirmed). A scan the per-user limit refuses
    counts as unknown, which needs the confirmation.
    """
    from .. import uninstall_impact as _impact

    # Lower case, as getUninstallImpact and the impact cache key it.
    catalog = (target_catalog or "").strip().lower()
    if target_mv is None or not catalog:
        return []
    subject = _impact.uninstall_confirm_subject(target_mv.id, catalog)
    label = f"v{target_mv.version}"
    if subject in confirmed:
        return [_uninstall_issue(
            subject,
            f"Uninstalling {label} from {catalog} drops its schemas and every table in "
            "them, with their rows. You confirmed the loss.",
        )]
    try:
        impact = _impact.uninstall_impact(
            session, ws, warehouse_id, target_mv, catalog,
            cataloging_style=cataloging_style, user=user, fresh=fresh,
        )
    except _impact.ScanRateLimited:
        return [_uninstall_issue(
            subject,
            f"Uninstalling {label} from {catalog} drops its schemas and every table in "
            "them. Too many checks were started in the last minute, so whether they hold "
            "rows was not checked; treat them as holding data.",
        )]
    except ValueError:
        return [_uninstall_issue(
            subject,
            f"Uninstalling {label} from {catalog} drops its schemas and every table in "
            f"them. {catalog} is not a plain catalog name, so they were not checked; treat "
            "them as holding data.",
        )]
    if not _impact.impact_needs_confirmation(impact):
        return []
    return [_uninstall_issue(subject, _uninstall_message(label, catalog, impact))]


def _uninstall_issue(subject: str, message: str) -> Issue:
    return Issue(
        field_path="version_id", step_index=-1, message=message,
        severity="confirm", subject=subject,
    )


def _uninstall_message(label: str, catalog: str, impact) -> str:
    tables = [t for schema in impact.schemas for t in schema.tables]
    holding = sum(1 for t in tables if t.has_data is True)
    unchecked = sum(1 for t in tables if t.has_data is None)
    schemas = len(impact.schemas)
    parts = [
        f"Uninstalling {label} from {catalog} drops {schemas} "
        f"schema{'s' if schemas != 1 else ''} and every table in them."
    ]
    if holding:
        parts.append(f"{holding} of {len(tables)} tables hold data, and their rows are lost.")
    if unchecked:
        parts.append(f"{unchecked} tables could not be checked; treat them as holding data.")
    parts.extend(impact.reasons)
    return " ".join(parts)


# --- Vibe runs: the dispatch catalog's registry (B10, F6) ------------------


def _newer_versions_in_catalog(session, base_mv, statuses: tuple[str, ...], in_catalog) -> list:
    """The versions of ``base_mv``'s business and scope numbered above it, with
    a status in ``statuses`` and matching the ``in_catalog`` clause
    (``_version_lifecycle._installed_in`` or ``_recorded_in``), by version."""
    from sqlmodel import col, select

    from ...db_models import ModelVersion

    return list(session.exec(
        select(ModelVersion)
        .where(
            ModelVersion.business_id == base_mv.business_id,
            ModelVersion.scope == base_mv.scope,
            ModelVersion.id != base_mv.id,
            col(ModelVersion.status).in_(statuses),
            col(ModelVersion.version) > int(base_mv.version),
            in_catalog,
        )
        .order_by(col(ModelVersion.version))
    ).all())


def _older_base_issues(session, base_mv, catalog: str, *, combined: bool) -> list[Issue]:
    """The ``base_version`` warning of an unscoped Vibe Modeling Full Run, or
    of Vibe ECM + MVM (``combined``), on a base older than versions of its
    scope installed in ``catalog`` now."""
    from ..operations._version_lifecycle import _installed_in

    installed_newer = _newer_versions_in_catalog(
        session, base_mv, ("completed", "superseded"), _installed_in(catalog, fold_case=True),
    )
    if not installed_newer:
        return []
    names = _versions_phrase([int(mv.version) for mv in installed_newer])
    many = len(installed_newer) > 1
    if combined:
        scope = (base_mv.scope or "ecm").upper()
        theirs = "their" if many else f"{names}'s"
        message = (
            f"{names} {scope} {'are' if many else 'is'} installed in {catalog}. This run builds from "
            f"v{base_mv.version}, replaces {theirs} tables and leaves {theirs} changes out of the new versions."
        )
    else:
        theirs = "their" if many else f"{names}'s"
        message = (
            f"{names} {'are' if many else 'is'} installed in {catalog}. This Full Run builds from "
            f"v{base_mv.version}, drops {theirs} tables and leaves {theirs} changes out of the new version."
        )
    return [Issue(field_path="base_version", step_index=-1, message=message, severity="warning")]


def vibe_catalog_issues(
    session,
    base_mv,
    target_catalog: str,
    *,
    scoped: bool,
    dry_run: bool,
    intent: str,
) -> list[Issue]:
    """What the agent will make of a vibe on ``base_mv`` dispatched to
    ``target_catalog``.

    The agent reads the base and its versions from the dispatch catalog's
    ``_metamodel``. A version is registered there when
    ``_version_lifecycle._recorded_in`` says so (its files are there or it
    was installed there), the catalog compared in any case. Registry
    rows survive uninstall and replacement; after a successful uninstall
    the app sets them ``dry_run`` (``_version_lifecycle.released_from``),
    and the agent's checks below skip ``dry_run`` rows. So:

    * a base not registered there is refused ("Version 'N' does not exist",
      P0 F6): a ``catalog`` blocker;
    * a scoped run refuses a base behind the newest completed version
      registered there (the stale-base probe, ``_get_latest_completed_version``):
      every version with registered domains counts except ``deploy_status =
      'dry_run'`` (``_RUN_LINEAGE_NOT_DRY_RUN_SQL``). A Dry Run draft
      registers ``deploy_status`` NULL (P0 attempt 5) and a replaced version
      keeps ``installed`` until it is released, so Dry Run drafts and
      unreleased replaced versions newer than the base count: a
      ``vibe_scope_base`` blocker naming them, until they are deleted. A
      replaced version uninstalled from there with its release done (a
      "Make this version current" over it) does not count
      (``_version_lifecycle.agent_counts_in``);
    * an unscoped Dry Run on a base that newer non-draft versions registered
      there follow: a ``dry_run`` warning that installing the draft would
      replace them;
    * an unscoped Vibe Modeling Full Run (``intent`` ``vibe-iterate``), or a
      Vibe ECM + MVM run (``vibe-new-ecm-mvm``), on a base older than
      versions installed there now: a ``base_version`` warning. The agent's
      staging teardown rebuilds the schemas this business owns when the base
      is not the installed latest version (``_vov_keeps_installed_tables``,
      nb 8031-8038, 8084-8086); the shrink step of Vibe ECM + MVM drops them
      whatever the base (``_vov_keeps_installed_tables`` is False for it). Either way the newer installed
      version's tables go and its changes are left out.

    A base with no recorded catalog at all (rows from before 0.9.0) is not
    checked.
    """
    from sqlmodel import select

    from ...db_models import ModelVersion
    from ..operations._version_lifecycle import _recorded_in, agent_counts_in

    catalog = (target_catalog or "").strip()
    if base_mv is None or not catalog:
        return []
    label = f"v{base_mv.version}"
    registered = session.exec(
        select(ModelVersion.id).where(ModelVersion.id == base_mv.id, _recorded_in(catalog, fold_case=True))
    ).first() is not None
    if not registered:
        known = sorted({
            c.strip() for c in (base_mv.files_catalog, base_mv.uc_catalog) if (c or "").strip()
        })
        if not known:
            return []
        return [Issue(
            field_path="catalog",
            step_index=-1,
            message=(
                f"The agent cannot find {label} in {catalog}: its files and registry rows "
                f"are in {', '.join(known)}. Run in that catalog, or install "
                f"{label} into {catalog} first."
            ),
            severity="blocker",
        )]
    if not (scoped or dry_run):
        if intent in (Intent.VIBE_ITERATE.value, Intent.VIBE_NEW_ECM_MVM.value):
            return _older_base_issues(
                session, base_mv, catalog, combined=intent == Intent.VIBE_NEW_ECM_MVM.value,
            )
        return []
    newer = _newer_versions_in_catalog(
        session, base_mv, ("completed", "superseded", "draft"), _recorded_in(catalog, fold_case=True),
    )
    if scoped:
        stale = [mv for mv in newer if mv.replaced_at is not None or mv.status == "draft"]
        counted = agent_counts_in(session, [mv.id for mv in stale], catalog, fold_case=True)
        stale = [mv for mv in stale if mv.id in counted]
        if not stale:
            return []
        names = _versions_phrase([int(mv.version) for mv in stale])
        many = len(stale) > 1
        kinds = sorted({"Dry Run draft" if mv.status == "draft" else "replaced" for mv in stale})
        why = " and ".join(kinds) if len(kinds) > 1 else kinds[0]
        return [Issue(
            field_path="vibe_scope_base",
            step_index=-1,
            message=(
                f"The agent refuses scoped runs on {label} while {names} "
                f"{'are' if many else 'is'} in its registry in {catalog}. Delete "
                f"{'them' if many else 'it'} ({why}), then retry."
            ),
            severity="blocker",
            versions=tuple(int(mv.version) for mv in stale),
        )]
    kept = [mv for mv in newer if mv.replaced_at is None and mv.status != "draft"]
    if not kept:
        return []
    names = _versions_phrase([int(mv.version) for mv in kept])
    verb = "are" if len(kept) > 1 else "is"
    return [Issue(
        field_path="dry_run",
        step_index=-1,
        message=(
            f"{names} {verb} newer than {label}. You can still install this Dry Run later; "
            f"that would replace {names}."
        ),
        severity="warning",
    )]

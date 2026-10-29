"""Who owns a catalog's schema names between a business, its other scope, and
the industry it was kickstarted from.

A business kickstarted from an industry (``Business.source_industry_id``)
carries the industry's schema names. The agent does not tell them apart:

- an ordinary install soft-replaces when the catalog's registry has any row
  for the business and version, whatever the scope (nb 7542-7550), and the
  business's other scope with the same names is replaced in place;
- in the catalog where the industry is installed, an install of the
  business soft-replaces the industry's tables silently, the industry's
  registry rows stay ``installed`` so the business's later scoped installs
  and Full Runs see a shared owner (nb 7942-7960), and the industry schemas
  the business does not write stay; elsewhere a v1 install hard-clashes
  (nb 7645-7800).

So the pre-flight (validate and create alike) decides:

- :func:`same_business_scope_clash` (M3): an install is refused while
  another scope of the same business is installed in the catalog under some
  of the same names.
- Rule 1, :func:`industry_replacements`: an install or Full Run of a
  business into a catalog where its source industry has a version installed
  under some of the same names uninstalls that version first (a warning
  that names what the uninstall drops, :func:`source_industry_issues`; a
  blocker while the industry has a run in progress). The DAG gets one
  ``uninstall`` step per such version (:func:`industry_uninstall_steps`),
  and the uninstall releases its registry rows. When the business already
  holds those names there (it was installed over the industry before), the
  agent uninstall would drop the business's tables: the step is
  ``release_only`` (the install row closes, the rows are released) and
  there is no warning.
- Rule 2: an install or Full Run of an industry into a catalog where a
  business kickstarted from it is installed is refused.

"Installed" is installed now (an open install row, or ``deployed`` in
``uc_catalog``: ``_version_lifecycle.versions_installed_in``). A Dry Run is
not a Full Run and none of this applies to it.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import TYPE_CHECKING, Any, Optional

from sqlmodel import select

from ...core import resolve_install_target_catalog, resolve_run_target_catalog
from ...core._runs import active_run_for_business
from ...db_models import Business, ModelVersion
from ...models import Intent, IssueOut, RunIn
from ..dispatched_widgets import latest_install_widgets
from ..operations._version_lifecycle import versions_installed_in
from ..schema_names import install_schema_names, physical_schema_name, recorded_schema_names
from ..uninstall_impact import cached_uninstall_impact, other_versions_installed_in

if TYPE_CHECKING:
    from sqlmodel import Session

_LISTED = 10
_FULL_RUN_INTENTS = (Intent.VIBE_ITERATE.value, Intent.VIBE_NEW_ECM_MVM.value)


@dataclass(frozen=True)
class Replacement:
    """A source-industry version the run uninstalls first, and the schema
    names it shares with the run."""

    industry: Business
    version: ModelVersion
    names: tuple[str, ...]
    # The run's business already holds every shared name in the catalog (it
    # was installed over the industry before): the agent uninstall would drop
    # the business's own tables, so the version is only released.
    replaced: bool = False


def _label(mv: ModelVersion, business: Optional[Business] = None) -> str:
    own = f"v{mv.version} {(mv.scope or '').upper()}".strip()
    return f"{business.name} {own}" if business is not None else own


def _listed(names) -> str:
    ordered = sorted(names)
    more = "" if len(ordered) <= _LISTED else f" (+{len(ordered) - _LISTED} more)"
    return ", ".join(ordered[:_LISTED]) + more


def same_business_scope_clash(
    session: "Session", target_mv: ModelVersion, catalog: str, writes: set[str],
) -> Optional[IssueOut]:
    """M3: the blocker when another scope of ``target_mv``'s business is
    installed in ``catalog`` under some of the names the install writes. The
    agent's soft-replace matches business and version only (nb 7542-7550),
    so the install would replace that scope's tables."""
    if not catalog or not writes:
        return None
    for mv in versions_installed_in(session, catalog):
        if mv.business_id != target_mv.business_id or mv.id == target_mv.id or mv.scope == target_mv.scope:
            continue
        shared = recorded_schema_names(session, mv.id, mv.scope, catalog) & writes
        if shared:
            other = _label(mv)
            return IssueOut(
                field_path="catalog", step_index=-1, severity="blocker",
                message=(
                    f"{other} of this business is installed in {catalog} under the same schema names "
                    f"as this install: {_listed(shared)}. The agent would replace its tables. Install "
                    f"into another catalog, or uninstall {other} first."
                ),
            )
    return None


def _full_run(data: RunIn) -> bool:
    intent = data.intent.value if data.intent is not None else ""
    return intent in _FULL_RUN_INTENTS and not data.dry_run


def run_target(
    session: "Session", data: RunIn, agent_config: Any, base: Optional[ModelVersion],
) -> Optional[tuple[str, set[str]]]:
    """``(catalog, schema names)`` an install or Full Run of ``base``'s
    business deploys, or None for any other run. An install writes
    ``preflight.install_writes``; a vibe keeps its base's stored names (the
    agent locks the prefix, nb 54167-54177); Vibe ECM + MVM also writes the
    shrink's names, the MVM prefix on the ECM names."""
    if base is None or data.intent is None:
        return None
    if data.intent == Intent.INSTALL:
        from .preflight import install_writes

        catalog = resolve_install_target_catalog(data, base, agent_config)
        return (catalog, install_writes(session, data, base, catalog)) if catalog else None
    if not _full_run(data):
        return None
    catalog = resolve_run_target_catalog(data, agent_config)
    if not catalog:
        return None
    names = install_schema_names(session, base.id, prefix="", suffix="")
    if data.intent == Intent.VIBE_NEW_ECM_MVM:
        from .dag_factories._unified import _resolve_cataloging_style, _resolve_mvm_prefix

        mvm_prefix = _resolve_mvm_prefix(data, _resolve_cataloging_style(data))
        names |= {physical_schema_name(n, mvm_prefix) for n in names}
    return catalog, names


def industry_replacements(
    session: "Session", data: RunIn, base: ModelVersion, catalog: str, writes: set[str],
) -> list[Replacement]:
    """Rule 1: the versions of ``base``'s business's source industry
    installed in ``catalog`` under some of ``writes``. Empty for a Dry Run
    and for a business that was not kickstarted from an industry. A version
    whose shared names a version of the business installed there already
    holds is ``replaced``: it gets a release, no agent uninstall."""
    if data.intent in (Intent.VIBE_ITERATE, Intent.VIBE_NEW_ECM_MVM) and data.dry_run:
        return []
    business = session.get(Business, base.business_id)
    source_id = getattr(business, "source_industry_id", None) if business is not None else None
    industry = session.get(Business, source_id) if source_id and source_id != base.business_id else None
    if industry is None or not catalog or not writes:
        return []
    installed = versions_installed_in(session, catalog)
    own: set[str] = set()
    for mv in installed:
        if mv.business_id == base.business_id:
            own |= recorded_schema_names(session, mv.id, mv.scope, catalog)
    out: list[Replacement] = []
    for mv in installed:
        if mv.business_id != industry.id:
            continue
        shared = recorded_schema_names(session, mv.id, mv.scope, catalog) & writes
        if shared:
            out.append(Replacement(
                industry=industry, version=mv, names=tuple(sorted(shared)), replaced=shared <= own,
            ))
    return out


def _replacement_warning(
    session: "Session", r: Replacement, catalog: str, keep: set[str], cataloging_style: Optional[str],
) -> IssueOut:
    """The Rule 1 warning: what uninstalling ``r`` drops (M6). The table
    count comes from an impact the uninstall check already computed
    (``uninstall_impact``), else it is left out."""
    names = list(r.names)
    count = ""
    impact = cached_uninstall_impact(r.version, catalog, cataloging_style)
    if impact is not None:
        dropped = [s for s in impact.schemas if not s.shared]
        if dropped:
            names = [s.name for s in dropped]
        with_data = sum(1 for s in dropped for t in s.tables if t.has_data)
        count = f" ({with_data} {'table' if with_data == 1 else 'tables'} with data)"
    others = sorted(
        f"{o.business_name} v{o.version} {o.scope.upper()}".strip()
        for o in other_versions_installed_in(session, r.version, catalog)
        if o.version_id not in keep
    )
    metrics = f"the agent's uninstall also drops {catalog}._metrics"
    if others:
        metrics += (
            f", the metric views of every model installed there: {', '.join(others)}. "
            "Their metric views come back only when they are installed again."
        )
    else:
        metrics += "."
    return IssueOut(
        field_path="catalog", step_index=-1, severity="warning",
        message=(
            f"{_label(r.version, r.industry)} is installed in {catalog}. This run uninstalls it first: "
            f"it drops its schemas {_listed(names)}{count}, and {metrics}"
        ),
    )


def _kickstarted_installed(session: "Session", industry_id: str, catalog: str) -> list[Business]:
    """Rule 2: the businesses kickstarted from ``industry_id`` with a version
    installed in ``catalog``."""
    children = {
        b.id: b for b in session.exec(select(Business).where(Business.source_industry_id == industry_id)).all()
        if b.id != industry_id
    }
    if not children:
        return []
    found: dict[str, Business] = {}
    for mv in versions_installed_in(session, catalog):
        if mv.business_id in children:
            found.setdefault(mv.business_id, children[mv.business_id])
    return sorted(found.values(), key=lambda b: b.name or "")


def source_industry_issues(
    session: "Session", data: RunIn, agent_config: Any, base: Optional[ModelVersion],
) -> list[IssueOut]:
    """Rule 1's warnings (and its blocker while the industry has a run in
    progress) and Rule 2's blocker for an install or Full Run of ``base``'s
    business."""
    target = run_target(session, data, agent_config, base)
    if target is None or base is None:
        return []
    catalog, writes = target
    issues: list[IssueOut] = []
    kicked = _kickstarted_installed(session, base.business_id, catalog)
    if kicked:
        verb = "Install the industry into" if data.intent == Intent.INSTALL else "Run the industry against"
        names = ", ".join(b.name for b in kicked)
        issues.append(IssueOut(
            field_path="catalog", step_index=-1, severity="blocker",
            message=(
                f"{names}, kickstarted from this industry, {'is' if len(kicked) == 1 else 'are'} "
                f"installed in {catalog}. {verb} another catalog."
            ),
        ))
    replacements = industry_replacements(session, data, base, catalog, writes)
    if not replacements:
        return issues
    industry = replacements[0].industry
    active = active_run_for_business(session, industry.id)
    if active is not None:
        listed = ", ".join(_label(r.version) for r in replacements)
        issues.append(IssueOut(
            field_path="catalog", step_index=-1, severity="blocker",
            message=(
                f"{industry.name} has a run in progress. This run must uninstall {industry.name} "
                f"{listed} from {catalog} first; wait for that run to finish, then try again."
            ),
        ))
    keep = {base.id, *(r.version.id for r in replacements)}
    issues.extend(
        _replacement_warning(session, r, catalog, keep, data.cataloging_style)
        for r in replacements if not r.replaced
    )
    return issues


def industry_uninstall_steps(
    session: "Session", data: RunIn, agent_config: Any, base: Optional[ModelVersion], cataloging_style: str,
) -> list[dict]:
    """The ``uninstall`` step params the DAG runs first (Rule 1): each
    version as its last install into the catalog laid it down
    (``dag_factories._simple.uninstall_step_params``); an already
    ``replaced`` one with ``release_only`` (no agent job: its install row
    closes and its registry rows are released)."""
    from .dag_factories._simple import uninstall_step_params

    target = run_target(session, data, agent_config, base)
    if target is None or base is None:
        return []
    catalog, writes = target
    return [
        {
            **uninstall_step_params(
                r.industry, r.version, catalog, cataloging_style,
                latest_install_widgets(session, r.version.id, catalog),
            ),
            **({"release_only": True} if r.replaced else {}),
        }
        for r in industry_replacements(session, data, base, catalog, writes)
    ]

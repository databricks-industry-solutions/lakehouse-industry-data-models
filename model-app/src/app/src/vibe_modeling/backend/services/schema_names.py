"""The physical Unity Catalog schema names a model version installs.

One home for the expected-schema rule. Callers:

- the installation drift probe and reconcile (``routes/versions.py``);
- the uninstall impact (``services/uninstall_impact.py``);
- the schemas an uninstall left behind (:func:`surviving_schemas`, read by
  ``operations/uninstall.py``).

:func:`expected_schema_candidates_for_version` builds every name form a
version's domains can have; :func:`match_schema_candidates` picks, per
domain, the form that exists in a catalog listing;
:func:`resolve_expected_and_found_schemas` lists the catalog and matches.
:func:`uninstall_schema_candidates` is the wider set an uninstall may drop:
every form of every domain schema and of every dotted product table prefix,
for the caller to keep each one that exists.
:func:`physical_schema_name` is the one rule for turning a stored
``database_name`` into the schema the agent writes, and
:func:`install_schema_names` applies it to the schemas an install writes.
:func:`pick_affix` is the one rule for the affix to assume from the
dispatched widgets. The orphan-schema drop (``services/orphan_schemas.py``) uses them too.
"""

from __future__ import annotations

import logging
import re
from collections.abc import Iterable
from dataclasses import dataclass, field
from itertools import islice
from typing import Any, Optional

from sqlmodel import select

from ..core._names import normalize_scope
from ..db_models import Domain, ModelVersion, Product
from .dispatched_widgets import (
    dispatched_schema_affixes_for_version,
    failed_install_widgets_into,
    generation_widgets_for_version,
    install_widgets_into,
    schema_affixes_of,
)

logger = logging.getLogger(__name__)

SchemaCandidates = list[tuple[str, list[str]]]

# Schemas that are never a model version's own: the agent's registry, the
# shared metric views, and Unity Catalog's built-ins.
RESERVED_SCHEMAS = frozenset({"_metamodel", "_metrics", "information_schema", "default"})
METRICS_SCHEMA = "_metrics"
SURVIVOR_LISTING_CAP = 5000
SURVIVOR_MAX_CATALOGS = 5


def agent_snake_case(name: str) -> str:
    """The agent's ``apply_convention(name, "snake_case")`` (nb 43442-43480):
    spaces and hyphens to ``_``, word breaks at case changes, other
    characters to ``_``, lower case, a repeated leading word dropped once
    (``element_element_id`` to ``element_id``). The agent's own rule, which
    differs from the taxonomy's ``taxonomy.naming.snake``."""
    s = (name or "").strip()
    if not s:
        return ""
    s = s.replace(" ", "_").replace("-", "_")
    s = re.sub(r"([A-Z]+)([A-Z][a-z])", r"\1_\2", s)
    s = re.sub(r"([a-z\d])([A-Z])", r"\1_\2", s)
    s = re.sub(r"[^a-zA-Z0-9_]", "_", s)
    words = [w.lower() for w in re.sub(r"_+", "_", s).strip("_").split("_") if w]
    for length in range(1, len(words) // 2 + 1):
        if words[:length] == words[length:2 * length]:
            words = words[:length] + words[2 * length:]
            break
    return "_".join(words)


def physical_schema_name(
    database_name: str, prefix: str = "", suffix: str = "", *, domain_name: Optional[str] = None,
) -> str:
    """The schema the agent writes for a domain's stored ``database_name``.

    * The stored name carries the schema prefix it was generated with:
      generation sets it (nb 81765-81782) and 5.3.3 stores ``ecm_sales`` or
      ``mvm_ecm_sales``. A name that starts with ``prefix`` is kept.
    * A name that does not start with ``prefix`` was generated with another
      prefix, or is an older logical name (``sales``). When an install
      sends a prefix other than the file's, the agent rebuilds every name as
      ``prefix + apply_convention(domain name)`` (``_convention_changed``,
      nb 106953; registry nb 107063, DDL nb 107191). With ``domain_name``
      this does the same; without it, ``prefix`` is put in front of the
      stored name.
    * ``CatalogResolver.resolve_schema`` (nb 7541-7560) then adds the
      suffix the deploy uses, only when the name does not end with it.
      Generation never puts the suffix into ``database_name``.

    Lower case: Unity Catalog folds schema names.
    """
    name = (database_name or "").strip().lower()
    prefix = (prefix or "").lower()
    suffix = (suffix or "").lower()
    if prefix and not name.startswith(prefix):
        base = agent_snake_case(domain_name) if domain_name else name
        name = f"{prefix}{base}" if base else ""
    if not name:
        return ""
    if suffix and not name.endswith(suffix):
        name = f"{name}{suffix}"
    return name


def domain_schema_name(database_name: Optional[str], name: Optional[str], *, suffix: str = "") -> str:
    """A domain's schema as the agent resolves it (``resolve_schema``,
    nb 7541-7560): its ``database_name``, else ``apply_convention`` of the
    domain name, with ``suffix`` when missing. For readers that know the
    domain row but not the install's prefix."""
    return physical_schema_name(database_name or agent_snake_case(name or ""), "", suffix)


def install_schema_names(session, version_id: str, *, prefix: str, suffix: str) -> set[str]:
    """The schemas an install of ``version_id`` writes with the
    ``schema_prefix`` and ``schema_suffix`` it deploys with
    (:func:`physical_schema_name` with each domain's name)."""
    rows = session.exec(
        select(Domain.database_name, Domain.name).where(Domain.version_id == version_id)
    ).all()
    names = {
        physical_schema_name(db or "", prefix, suffix, domain_name=name or None)
        for db, name in rows
    }
    return {n for n in names if n}


def pick_affix(values: list[str], fallback: str) -> str:
    """The one affix to assume from the dispatched ``values``
    (:func:`dispatched_widgets.dispatched_schema_affixes_for_version`).

    The longest non-empty value: a One Catalog model links a generation op
    (which may carry an empty ``schema_prefix``) and an install op (the
    prefix it sent, ``_simple.install_schema_prefix``: the request's, the
    recorded one or the file's), and row order must not decide. When every
    recorded value is ``""`` (a Catalog-per-* install, or an industry or
    business kickstarted before 0.9.0, which the agent deploys unprefixed)
    it is ``""``.
    ``fallback`` only when nothing was recorded."""
    non_empty = [v for v in values if v]
    if non_empty:
        return max(non_empty, key=len)
    if values:
        return ""
    return fallback


def recorded_schema_names(session, version_id: str, scope: Optional[str], catalog: str) -> set[str]:
    """The schemas a version recorded in ``catalog`` holds there: with the
    prefix and suffix its latest install into ``catalog`` sent, else the
    ones the op that produced it was dispatched with (the agent's ownership
    snapshot resolves registry rows with the run's own conventions,
    nb 8356-8372).

    Without an install record into ``catalog`` the version claims its stored
    names as they are, the form the agent's snapshot resolves
    (``resolve_schema`` of the registry ``database_name``, nb 7943-7950),
    and the producing op's prefix. An install into another catalog, a failed
    install and a child run that read the version claim nothing here. Only a
    version deployed in ``catalog`` (its ``uc_catalog``) also claims the
    scope-prefixed form, which an older logical name (``sales``) took there;
    a version that only has files and registry rows in ``catalog`` (an
    industry seed, a kickstarted copy not installed yet) holds just what its
    rows name."""
    install = install_widgets_into(session, version_id, catalog)
    if install is not None and "schema_prefix" in install:
        prefix = str(install.get("schema_prefix") or "")
        suffix = str(install.get("schema_suffix") or "")
        return install_schema_names(session, version_id, prefix=prefix, suffix=suffix)
    produced = generation_widgets_for_version(session, version_id)
    prefixes, suffixes = schema_affixes_of(w for w in (produced, install) if w)
    scope_prefix = scope_schema_prefix(scope)
    mv = session.get(ModelVersion, version_id)
    target = (catalog or "").strip().lower()
    deployed_here = bool(target) and mv is not None and (mv.uc_catalog or "").strip().lower() == target
    suffix = pick_affix(suffixes, "")
    forms = {"", pick_affix(prefixes, scope_prefix if deployed_here else "")}
    if deployed_here:
        forms.add(scope_prefix)
    names: set[str] = set()
    for prefix in forms:
        names |= install_schema_names(session, version_id, prefix=prefix, suffix=suffix)
    return names


def failed_install_schema_names(session, version_id: str, catalog: str) -> set[str]:
    """The schemas a failed install of ``version_id`` into ``catalog`` may
    have left there: the names its prefix and suffix give the domains. For
    the orphan scan, which must offer them. They are not a claim, so the
    install clash pre-flight does not credit them
    (:func:`recorded_schema_names` does not return them)."""
    names: set[str] = set()
    for widgets in failed_install_widgets_into(session, version_id, catalog):
        if "schema_prefix" in widgets:
            names |= install_schema_names(
                session, version_id,
                prefix=str(widgets.get("schema_prefix") or ""),
                suffix=str(widgets.get("schema_suffix") or ""),
            )
    return names


def _scope_short(scope: Optional[str]) -> str:
    """Match `dag_factories._simple._schema_prefix_for`'s scope
    normalisation: "ecm" for any form of the ECM scope, else "mvm"."""
    return "ecm" if normalize_scope(scope or "") == "ecm" else "mvm"


def scope_schema_prefix(scope: Optional[str]) -> str:
    """The One Catalog schema prefix of ``scope``: ``ecm_`` or ``mvm_``."""
    return f"{_scope_short(scope)}_"


def expected_schema_candidates_for_version(
    session, version_id: str, scope: Optional[str], catalog: str
) -> SchemaCandidates:
    """Return ``(default_expected, [candidate_forms])`` per domain of
    ``version_id`` in ``catalog``.

    ``Domain.database_name`` carries the schema prefix in agent 5.3.3
    output (``ecm_sales``); older versions stored a logical name
    (``party_db``). Every form goes through :func:`physical_schema_name`,
    which adds a prefix or suffix only where the name lacks it.

    - ``schema_prefix`` is ``f"{scope_short}_"`` for the default
      ``"One Catalog"`` style (so an ECM and MVM install into the same
      catalog don't collide) and empty for ``Catalog per Division`` /
      ``Catalog per Domain`` (a dedicated per-scope catalog namespaces
      them instead). See ``dag_factories._simple._schema_prefix_for``.
    - ``schema_suffix`` is a user naming-standard affix (e.g. ``_wt``) the
      generation op forwards to the agent.

    The cataloging style is not persisted, so the affixes come from what was
    actually dispatched to the agent (``RunOperation.dispatched_widgets_json``).
    When the version's latest install into ``catalog`` recorded a
    ``schema_prefix``, only that prefix is probed there: the bare and
    scope-prefixed guesses would count another business's same-named schemas
    in a shared catalog as this version's. The prefix is per catalog: a
    version deployed in one catalog by a Full Run (the agent applies
    ``ecm_``) and installed into another with ``""`` keeps ``ecm_`` in the
    first. Otherwise (no recorded install into ``catalog``: pre-E-03 installs,
    a deploy by a generation or vibe run) the candidates are the
    ``{scope}_``-prefixed and bare forms plus any dispatched prefix. The caller resolves each domain's forms
    against the live catalog listing and picks whichever is actually present.

    Every domain on the version is probed, with no cap: one
    ``ws.schemas.list`` call plus local set matching is sub-second regardless
    of domain count.
    """
    names = _column_values(session.exec(
        select(Domain.database_name).where(Domain.version_id == version_id)
    ).all())
    scope_prefix = f"{_scope_short(scope)}_"
    disp_prefixes, disp_suffixes, probe_prefixes, probe_suffixes = _probe_affixes(
        session, version_id, scope
    )

    # The single most-actionable name to report as "expected"/"missing"
    # when NONE of the forms exist in the catalog: what the agent was told
    # to use (:func:`pick_affix`), else the legacy scope-prefixed default.
    install = install_widgets_into(session, version_id, catalog)
    if install is not None and "schema_prefix" in install:
        default_prefix = str(install.get("schema_prefix") or "")
        probe_prefixes = [default_prefix]
    else:
        default_prefix = pick_affix(disp_prefixes, scope_prefix)
    default_suffix = pick_affix(disp_suffixes, "")

    seen: SchemaCandidates = []
    seen_set: set[str] = set()
    for name in names:
        if not name or name in seen_set:
            continue
        seen_set.add(name)
        forms: list[str] = []
        for pfx in probe_prefixes:
            for sfx in probe_suffixes:
                form = physical_schema_name(name, pfx, sfx)
                if form not in forms:
                    forms.append(form)
        default_expected = physical_schema_name(name, default_prefix, default_suffix)
        seen.append((default_expected, forms))
    return seen


def _probe_affixes(
    session, version_id: str, scope: Optional[str], failed_into: Optional[str] = None
) -> tuple[list[str], list[str], list[str], list[str]]:
    """``(dispatched_prefixes, dispatched_suffixes, probe_prefixes, probe_suffixes)``.

    Prefixes to probe: always the scope-prefixed and bare forms, plus any
    prefix the agent was actually handed. Suffixes: always the blank form,
    plus any dispatched suffix. With ``failed_into`` (a catalog), also the
    affixes of the version's failed installs that targeted it, which may
    have left schemas there; they are probed, not returned as dispatched.
    """
    disp_prefixes, disp_suffixes = dispatched_schema_affixes_for_version(
        session, version_id
    )
    probe_prefixes: list[str] = [f"{_scope_short(scope)}_", ""]
    probe_suffixes: list[str] = [""]
    failed_prefixes, failed_suffixes = schema_affixes_of(
        failed_install_widgets_into(session, version_id, failed_into) if failed_into else ()
    )
    for p in (*disp_prefixes, *failed_prefixes):
        if p not in probe_prefixes:
            probe_prefixes.append(p)
    for s in (*disp_suffixes, *failed_suffixes):
        if s not in probe_suffixes:
            probe_suffixes.append(s)
    return disp_prefixes, disp_suffixes, probe_prefixes, probe_suffixes


def _column_values(rows) -> list[str]:
    out = []
    for r in rows:
        # session.exec() yields the column value directly for a one-column select.
        value = r if isinstance(r, str) else (r[0] if r else "")
        out.append((value or "").strip())
    return out


@dataclass(frozen=True)
class SchemaNameGroup:
    """The name forms of one base schema name (``forms``). ``domain`` is True for a
    domain's ``database_name``, False for a dotted product table prefix."""

    forms: tuple[str, ...]
    domain: bool


def uninstall_schema_candidates(
    session, version_id: str, scope: Optional[str], catalog: Optional[str] = None
) -> list[SchemaNameGroup]:
    """Every schema name an uninstall of ``version_id`` may drop in its catalog.

    The agent's uninstall drops each domain's ``database_name`` (with the
    model's schema suffix) and the schema part of every dotted product
    ``table_name``. The app does not know which prefix the physical names
    carry, so every probe form of each base name is returned, and the
    caller keeps every one that exists: listing a name the agent leaves
    alone overstates the impact, missing one it drops would understate it.
    So, unlike :func:`expected_schema_candidates_for_version`, the bare and
    scope-prefixed forms stay even when the installs recorded a prefix.
    Forms are lower case: Unity Catalog stores schema names folded to lower
    case. A product prefix that equals a domain name is not repeated.

    With ``catalog``, the forms also include the prefix of a failed install
    that targeted that catalog: it may have left schemas there that an
    uninstall of the version drops. Claims by installed versions pass no
    catalog, so a failed install never claims a name.
    """
    domain_bases: list[str] = []
    for name in _column_values(session.exec(
        select(Domain.database_name).where(Domain.version_id == version_id)
    ).all()):
        name = name.lower()
        if name and name not in domain_bases:
            domain_bases.append(name)
    table_bases: list[str] = []
    for table_name in _column_values(session.exec(
        select(Product.table_name).where(Product.version_id == version_id)
    ).all()):
        if "." not in table_name:
            continue
        part = table_name.split(".", 1)[0].strip().lower()
        if part and part not in domain_bases and part not in table_bases:
            table_bases.append(part)

    _, _, prefixes, suffixes = _probe_affixes(session, version_id, scope, catalog)

    def _forms(base: str) -> tuple[str, ...]:
        forms: list[str] = []
        for pfx in prefixes:
            for sfx in suffixes:
                form = physical_schema_name(base, pfx, sfx)
                if form not in forms:
                    forms.append(form)
        return tuple(forms)

    return [SchemaNameGroup(_forms(b), True) for b in domain_bases] + [
        SchemaNameGroup(_forms(b), False) for b in table_bases
    ]


def match_schema_candidates(
    candidates: SchemaCandidates, present: Iterable[str]
) -> tuple[list[str], list[str]]:
    """Per domain, the first candidate form in ``present``.

    When none is present, the domain's ``default_expected`` is reported: the
    most actionable name for an operator staring at a missing-schema list
    (the dispatched affixes when known, else the default "One Catalog"
    scope-prefixed convention).

    Returns ``(expected_schemas, found_schemas)``; ``found`` is sorted.
    """
    names = set(present)
    expected: list[str] = []
    found: list[str] = []
    for default_expected, forms in candidates:
        match = next((f for f in forms if f in names), None)
        if match is not None:
            expected.append(match)
            found.append(match)
        else:
            expected.append(default_expected)
    return expected, sorted(found)


def resolve_expected_and_found_schemas(
    ws, catalog: str, candidates: SchemaCandidates
) -> tuple[list[str], list[str]]:
    """List ``catalog``'s schemas once and match ``candidates`` against them.

    Raises whatever ``ws.schemas.list`` raises, after logging it; the caller
    decides what an unreadable catalog means.

    Returns ``(expected_schemas, found_schemas)``.
    """
    if not catalog or not candidates:
        return [], []
    try:
        all_names = {(s.name or "").lower() for s in ws.schemas.list(catalog_name=catalog)}
    except Exception as exc:  # noqa: BLE001
        logger.warning(
            "Drift probe could not list schemas in %r: %s", catalog, exc
        )
        raise
    return match_schema_candidates(candidates, all_names)


@dataclass(frozen=True)
class SurvivingSchemas:
    """What is still in the catalogs after an uninstall: the version's own
    schemas as ``(catalog, schema)`` and the catalogs where the shared
    ``_metrics`` schema is still present."""

    schemas: tuple[tuple[str, str], ...] = ()
    metrics_catalogs: tuple[str, ...] = ()
    catalogs_read: tuple[str, ...] = field(default=())


def surviving_schemas(
    session, ws: Any, version_id: str, scope: Optional[str], catalogs: Iterable[str], *, prefix: str = "",
) -> SurvivingSchemas:
    """The schemas of ``version_id`` that exist in ``catalogs`` now.

    The names the version holds in a catalog (:func:`recorded_schema_names`,
    plus the ones ``prefix`` gives its domains) intersected with one
    ``ws.schemas.list`` per catalog, at most :data:`SURVIVOR_MAX_CATALOGS`
    catalogs and :data:`SURVIVOR_LISTING_CAP` schemas each. ``_metrics`` is
    reported apart, never among the schemas. Names compare in lower case.

    Raises whatever ``ws.schemas.list`` raises: the caller decides what an
    unreadable catalog means.
    """
    seen: list[str] = []
    for catalog in catalogs:
        cat = (catalog or "").strip()
        if cat and cat.lower() not in {c.lower() for c in seen}:
            seen.append(cat)
    seen = seen[:SURVIVOR_MAX_CATALOGS]
    schemas: list[tuple[str, str]] = []
    metrics: list[str] = []
    for catalog in seen:
        listed = {
            (s.name or "").lower()
            for s in islice(ws.schemas.list(catalog_name=catalog), SURVIVOR_LISTING_CAP)
        }
        expected = {n.lower() for n in recorded_schema_names(session, version_id, scope, catalog)}
        if prefix:
            expected |= {n.lower() for n in install_schema_names(session, version_id, prefix=prefix, suffix="")}
        schemas.extend((catalog, n) for n in sorted((expected & listed) - RESERVED_SCHEMAS))
        if METRICS_SCHEMA in listed:
            metrics.append(catalog)
    return SurvivingSchemas(tuple(schemas), tuple(metrics), tuple(seen))

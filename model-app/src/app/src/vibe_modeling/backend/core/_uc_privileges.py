"""Read a principal's effective Unity Catalog privileges, read-only.

The one home for "does principal P hold privileges X on securable S": the
assessment reader checks (``assessment/readiness.py``), the assessment job
sync's grant-what-is-missing step (``assessment/job_sync.py``), and the app's
own catalog capability (the deployment catalog picker and the run pre-flight,
which use ``app_catalog_capabilities`` and ``run_creates_schemas``). Nothing here grants
(conv §4): a refusal carries the GRANT an admin runs.

What ``grants.get_effective`` reports (read on a live workspace, 2026-10-23):

- privileges inherited from groups (``account users``) and parent securables;
- not ownership: an owner shows no privileges, so the capability check reads
  the securable's owner when the privileges fall short (``_holds``);
- a missing schema answers ``NotFound``, a missing volume
  ``ResourceDoesNotExist`` (a ``NotFound`` subclass).

An owner that is one of the principal's groups counts as ownership. A group
owner the check can't resolve (not among the principal's direct groups, which
may still hold it through nesting) leaves the answer unchecked, never refused.
"""

from __future__ import annotations

import logging
import re
import threading
import time
from concurrent.futures import Future, ThreadPoolExecutor, wait
from dataclasses import dataclass
from typing import Callable, Iterable, Optional

from databricks.sdk import WorkspaceClient
from databricks.sdk.errors.platform import DatabricksError, NotFound

from .._workspace_clients import short_budget_workspace_client
from ..services.metamodel_setup import METAMODEL_SCHEMA, VOL_ROOT
from ._app_identity import app_application_id, app_group_names

logger = logging.getLogger(__name__)

ALL_PRIVILEGES = "ALL_PRIVILEGES"

# What the app needs in a catalog. CREATE_SCHEMA_NEEDS on the catalog lets a
# run create its model schemas (and ``_metamodel`` when absent). The
# ``_metamodel`` sets mirror what ``install/grant_catalog.py`` grants there.
CREATE_SCHEMA_NEEDS = frozenset({"USE_CATALOG", "CREATE_SCHEMA"})
METAMODEL_SCHEMA_NEEDS = frozenset({"USE_SCHEMA", "CREATE_TABLE", "MODIFY", "SELECT"})
VOL_ROOT_NEEDS = frozenset({"READ_VOLUME", "WRITE_VOLUME"})

# Intents whose runs create schemas in the run's catalog (model schemas on a
# Full Run, or the install target). A Dry Run vibe writes only ``_metamodel``.
_SCHEMA_CREATING_INTENTS = frozenset({"new-base-model", "vibe-new-ecm-mvm", "install"})

# Bounds for the capability route (design M4). The cap is shared with the UI
# through tests/fixtures/catalog_capability_rule_fixture.json.
CAPABILITY_CHECK_CAP = 25
CAPABILITY_TIMEOUT_SECONDS = 15.0
POSITIVE_TTL_SECONDS = 600.0
# Budgets of the check client: one HTTP call gives up after the first, retries
# stop after the second, so a hung read ends (HTTP + retry) inside the
# route's deadline and frees its worker for the next request.
CHECK_HTTP_TIMEOUT_SECONDS = 6
CHECK_RETRY_TIMEOUT_SECONDS = 8
_POOL = ThreadPoolExecutor(max_workers=4, thread_name_prefix="uc-capability")

_UUID = re.compile(r"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", re.I)


def effective_privileges(ws: WorkspaceClient, securable_type: str, full_name: str, principal: str) -> set[str] | None:
    """Effective (incl. inherited) privileges, or None when the app can't evaluate them."""
    try:
        return _read_effective(ws, securable_type, full_name, principal)
    except DatabricksError:
        return None


def missing_privileges(privs: set[str], needed: Iterable[str]) -> set[str]:
    """The privileges of ``needed`` that ``privs`` lacks; none when it holds ALL_PRIVILEGES."""
    if ALL_PRIVILEGES in privs:
        return set()
    return set(needed) - privs


def covers(privs: set[str], needed: Iterable[str]) -> bool:
    """True when ``privs`` holds every privilege of ``needed`` (ALL_PRIVILEGES holds all)."""
    return not missing_privileges(privs, needed)


def _read_effective(ws: WorkspaceClient, securable_type: str, full_name: str, principal: str) -> set[str]:
    res = ws.grants.get_effective(securable_type, full_name, principal=principal)
    return {getattr(p.privilege, "value", p.privilege)
            for a in (res.privilege_assignments or []) for p in (a.privileges or []) if p.privilege}


# --- The app's capability in one catalog ---


@dataclass(frozen=True)
class CatalogCapability:
    """What a principal can do in one catalog. None = could not be checked.

    ``create_schema``: USE_CATALOG + CREATE_SCHEMA on the catalog.
    ``use_metamodel``: the app can use ``<catalog>._metamodel`` and its
    ``vol_root`` volume, creating whichever is absent (an absent ``_metamodel``
    therefore needs ``create_schema``).
    The ``*_fix`` fields hold the GRANT statements for every gap the check
    found, empty when there is none.
    """

    create_schema: Optional[bool]
    use_metamodel: Optional[bool]
    create_schema_fix: str = ""
    use_metamodel_fix: str = ""


UNCHECKED = CatalogCapability(create_schema=None, use_metamodel=None)


class _Unreadable(Exception):
    """The privileges or the owner of one securable could not be read or resolved."""


# A failed read: an API error, or the SDK's builtin TimeoutError when its retry
# budget runs out.
_READ_FAILURES = (DatabricksError, TimeoutError)


def _q(*parts: str) -> str:
    return ".".join("`" + p.replace("`", "``") + "`" for p in parts)


def _grant(privs: Iterable[str], securable_type: str, name: str, principal: str) -> str:
    listed = ", ".join(sorted(p.replace("_", " ") for p in privs))
    return f"GRANT {listed} ON {securable_type.upper()} {name} TO {_q(principal)};"


def grant_statement(privs: Iterable[str], securable_type: str, parts: tuple[str, ...], principal: str) -> str:
    """The GRANT an admin runs to give ``principal`` ``privs`` on the securable
    named by ``parts`` (quoted)."""
    return _grant(privs, securable_type, _q(*parts), principal)


def _is_group_name(owner: str) -> bool:
    """Owners are a user (an email), a service principal (an application id) or a group."""
    return "@" not in owner and not _UUID.match(owner)


def _holds(ws: WorkspaceClient, securable_type: str, parts: tuple[str, ...], principal: str,
           groups: Optional[frozenset[str]], needed: frozenset[str],
           owner_of: Callable[[str], object]) -> set[str] | None:
    """The privileges of ``needed`` the principal lacks on the securable (empty = holds all).

    None when the securable does not exist. Ownership, by the principal or one
    of its ``groups``, counts as holding all. Raises ``_Unreadable`` when the
    privileges or owner can't be read, or the owner is a group not resolved.
    """
    full_name = ".".join(parts)
    try:
        missing = missing_privileges(_read_effective(ws, securable_type, full_name, principal), needed)
    except NotFound:
        return None
    except _READ_FAILURES as e:
        raise _Unreadable(full_name) from e
    if not missing:
        return missing
    try:
        owner = getattr(owner_of(full_name), "owner", None) or ""
    except NotFound:
        return None
    except _READ_FAILURES as e:
        raise _Unreadable(full_name) from e
    if owner == principal or (groups is not None and owner in groups):
        return set()
    if owner and _is_group_name(owner):
        raise _Unreadable(f"{full_name} is owned by group {owner!r}")
    return missing


def catalog_capability(ws: WorkspaceClient, catalog: str, principal: str,
                       groups: Optional[frozenset[str]] = None) -> CatalogCapability:
    """Check, read-only and uncached, what ``principal`` can do in ``catalog``.

    ``groups`` are the principal's group names (None = unknown). A catalog that
    does not exist (or that the reader can't see) reads as neither. A step that
    can't be read leaves its field None, unless a gap was already found.
    """
    if not catalog or not principal:
        return UNCHECKED
    try:
        cat_missing = _holds(ws, "catalog", (catalog,), principal, groups, CREATE_SCHEMA_NEEDS, ws.catalogs.get)
    except _Unreadable:
        return UNCHECKED
    if cat_missing is None:
        return CatalogCapability(create_schema=False, use_metamodel=False)
    create_schema = not cat_missing
    create_fix = "" if create_schema else _grant(cat_missing, "catalog", _q(catalog), principal)
    known: list[str] = []
    if "USE_CATALOG" in cat_missing:
        known.append(_grant({"USE_CATALOG"}, "catalog", _q(catalog), principal))
    use_metamodel, metamodel_fix = _metamodel_access(ws, catalog, principal, groups, create_schema, create_fix, known)
    return CatalogCapability(create_schema=create_schema, use_metamodel=use_metamodel,
                             create_schema_fix=create_fix, use_metamodel_fix=metamodel_fix)


def _metamodel_access(ws: WorkspaceClient, catalog: str, principal: str, groups: Optional[frozenset[str]],
                      create_schema: bool, create_fix: str, known: list[str]) -> tuple[Optional[bool], str]:
    """``(use_metamodel, fix)``. ``known`` holds gaps already found (USE CATALOG):
    they make the answer False, and the reads below add the rest of the GRANTs
    when they can; a read that fails then keeps the known gaps."""
    fixes = list(known)

    def gap_or_unknown() -> tuple[Optional[bool], str]:
        return (False, "\n".join(fixes)) if fixes else (None, "")

    schema = (catalog, METAMODEL_SCHEMA)
    try:
        schema_missing = _holds(ws, "schema", schema, principal, groups, METAMODEL_SCHEMA_NEEDS, ws.schemas.get)
    except _Unreadable:
        return gap_or_unknown()
    if schema_missing is None:
        # The app creates ``_metamodel`` and its volume, and owns both.
        return create_schema, create_fix
    if schema_missing:
        fixes.append(_grant(schema_missing, "schema", _q(*schema), principal))
    try:
        vol_missing = _holds(ws, "volume", (*schema, VOL_ROOT), principal, groups, VOL_ROOT_NEEDS, ws.volumes.read)
        if vol_missing is None:
            create_vol = _holds(ws, "schema", schema, principal, groups, frozenset({"CREATE_VOLUME"}), ws.schemas.get)
            if create_vol:
                fixes.append(_grant(create_vol, "schema", _q(*schema), principal))
        elif vol_missing:
            fixes.append(_grant(vol_missing, "volume", _q(*schema, VOL_ROOT), principal))
    except _Unreadable:
        return gap_or_unknown()
    return not fixes, "\n".join(fixes)


# --- Which runs need what ---


SINGLE_CATALOG_STYLE = "One Catalog"


def run_creates_schemas(intent: str, dry_run: bool, cataloging_style: str = SINGLE_CATALOG_STYLE) -> bool:
    """True when a run of ``intent`` creates schemas in its (``deployment_catalog``) catalog.

    Those runs need CREATE_SCHEMA there; the others (a Dry Run vibe, an
    uninstall, sample generation, an import) need only ``_metamodel`` access.
    In the multi-catalog styles the model schemas go to derived catalogs, so
    the run's catalog holds only ``_metamodel``; derived catalogs are not
    checked here.
    """
    if (cataloging_style or SINGLE_CATALOG_STYLE) != SINGLE_CATALOG_STYLE:
        return False
    if intent == "vibe-iterate":
        return not dry_run
    return intent in _SCHEMA_CREATING_INTENTS


def catalog_usable(cap: CatalogCapability, *, creates_schemas: bool) -> Optional[bool]:
    """Whether a run can use the catalog: False when a needed check failed,
    None when one could not be made, else True."""
    needed = [cap.use_metamodel] + ([cap.create_schema] if creates_schemas else [])
    if False in needed:
        return False
    if None in needed:
        return None
    return True


# --- The app's own capabilities, bounded and positively cached ---


_CHECK_WS: WorkspaceClient | None = None


def capability_workspace_client() -> WorkspaceClient:
    """The app SP's client for the capability checks: the default auth of the
    shared app client, with short HTTP and retry budgets. Built lazily, cached."""
    global _CHECK_WS
    if _CHECK_WS is None:
        _CHECK_WS = short_budget_workspace_client(CHECK_HTTP_TIMEOUT_SECONDS, CHECK_RETRY_TIMEOUT_SECONDS)
    return _CHECK_WS


_positive: dict[str, float] = {}
_positive_lock = threading.Lock()


def cached_positive(catalog: str) -> bool:
    """True when a check in the last ``POSITIVE_TTL_SECONDS`` found every capability."""
    with _positive_lock:
        expiry = _positive.get(catalog)
        if expiry is None:
            return False
        if expiry <= time.monotonic():
            del _positive[catalog]
            return False
        return True


def _remember(catalog: str, cap: CatalogCapability) -> None:
    # Only full positives are kept: a grant an admin adds after a refusal
    # must show on the next check.
    if cap.create_schema and cap.use_metamodel:
        with _positive_lock:
            _positive[catalog] = time.monotonic() + POSITIVE_TTL_SECONDS


def clear_capability_cache() -> None:
    with _positive_lock:
        _positive.clear()


_FULL = CatalogCapability(create_schema=True, use_metamodel=True)


def app_catalog_capabilities(names: Iterable[str]) -> list[tuple[str, CatalogCapability]]:
    """The app service principal's capability in each catalog of ``names``,
    read on ``capability_workspace_client``.

    Unique non-empty names in request order. At most ``CAPABILITY_CHECK_CAP``
    are checked, on a pool of 4, within ``CAPABILITY_TIMEOUT_SECONDS``; the rest,
    and any check that does not finish in time, come back unchecked.
    """
    unique = list(dict.fromkeys(n.strip() for n in names if n and n.strip()))
    checked, beyond = unique[:CAPABILITY_CHECK_CAP], unique[CAPABILITY_CHECK_CAP:]
    results: dict[str, CatalogCapability] = {}
    pending: dict[str, Future] = {}
    # One read of the cache, so a positive expiring mid-call can't send a
    # name to the check without a client.
    for name in checked:
        if cached_positive(name):
            results[name] = _FULL
    to_check = [n for n in checked if n not in results]
    if to_check:
        try:
            ws = capability_workspace_client()
        except Exception:  # noqa: BLE001 - no client means nothing can be checked
            logger.warning("Could not build the capability check client", exc_info=True)
            to_check = []
    principal = ""
    groups: Optional[frozenset[str]] = None
    for name in to_check:
        if not principal:
            principal = app_application_id(ws)
            if not principal:
                break
            groups = app_group_names(ws)
        pending[name] = _POOL.submit(catalog_capability, ws, name, principal, groups)
    if pending:
        wait(pending.values(), timeout=CAPABILITY_TIMEOUT_SECONDS)
    for name, fut in pending.items():
        if not fut.done():
            fut.cancel()
            logger.warning("Catalog capability check for %r did not finish in %ss", name, CAPABILITY_TIMEOUT_SECONDS)
            continue
        try:
            cap = fut.result()
        except Exception:  # noqa: BLE001 - an unexpected failure is an unchecked catalog
            logger.warning("Catalog capability check for %r failed", name, exc_info=True)
            continue
        _remember(name, cap)
        results[name] = cap
    return [(n, results.get(n, UNCHECKED)) for n in checked + beyond]

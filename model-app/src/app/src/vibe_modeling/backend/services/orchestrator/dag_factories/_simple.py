"""Single-step DAG factories for the "simple" intents (vibe-iterate, install, uninstall).

Each intent covered here maps to exactly one
:class:`OperationStep` — no fan-out, no skip predicates, no
``needs_version_from`` chains. The orchestrator persists one
``RunOperation`` row per run, dispatches it on ``start()``, and walks
to a terminal state in a single observe pass once the underlying
Databricks job completes.

Per ``docs/orchestrator-design.md`` §3:

* Factories are pure (no DB, no workspace client). The route handler
  passes in the ``req`` (the validated ``RunIn`` body), the resolved
  ``Business`` / ``BusinessContext`` / ``AgentConfig`` rows, and any
  carry-keys the handler already worked out (e.g. the resolved target
  catalog and the parent ``ModelVersion`` row).
* Factories may emit warnings via the returned ``Dag``'s validation
  surface — but for the simple intents there is no cross-step rule
  to violate, so today every Dag returned here has zero warnings.

Per the Phase-4 briefing, the route handler is responsible for
populating the ``RunOperation.parent_version_id`` field on the
persisted row before the orchestrator advances the DAG. The factory
itself does NOT thread ``parent_version_id`` through ``params`` — it
flows on the :class:`OperationContext` instead (spec §2 reconciliation
brief #1).
"""

from __future__ import annotations

from collections.abc import Iterable
from typing import Any, Optional

from ....core import (
    resolve_install_target_catalog,
    resolve_run_target_catalog,
    resolve_uninstall_target_catalog,
)
from ....core._names import agent_business_segment, normalize_scope
from ....models import RUN_CONVENTION_FIELDS, Intent
from ...dispatched_widgets import installed_schema_prefix
from ...operations._install_conventions import CONVENTION_FILE_KEYS
from ...version_files import model_json_candidates, readable_import_source
from ..dag import Dag, OperationStep
from ._recovery import uninstall_then_install


def _sanitized_business_name(business: Any) -> str:
    """Coerce ``Business.name`` into the lowercase-snake form the
    install/uninstall primitives expect.

    The ``install`` / ``uninstall`` params
    models constrain ``business_name`` to ``^[a-z][a-z0-9_]+$`` (a
    legal UC catalog segment fragment). Phase 4 of the drift-unification
    plan reconciles this helper with the canonical
    :func:`agent_business_segment` (the agent's own
    ``sanitize_name(strip_stop_words=False)`` rule that produces the
    on-disk Volume path segment) so that the value carried in
    ``business_name`` matches the agent's actual filesystem layout.

    For realistic business labels the two sanitizers are empirically
    identical (see ``tests/test_app/test_core_names.py::
    test_agent_segment_eq_catalog_segment_for_business_names``); the
    only divergences are empty-default and digit-prefix, and both
    produce a value the pydantic regex rejects up-front anyway. Using
    the agent rule keeps every path-builder consumer consistent.
    """
    return agent_business_segment(getattr(business, "name", "") or "")


def _resolved_cataloging_style(req: Any) -> str:
    """One of the three cataloging styles the agent supports."""
    style = (getattr(req, "cataloging_style", None) or "").strip()
    return style or "One Catalog"


def _scope_short(req: Any, parent_mv: Any) -> str:
    """``"ecm"`` or ``"mvm"`` — the short form the primitives expect.

    Prefers an explicit ``req.scope`` (the route handler / form already
    resolved it) and falls back to ``parent_mv.scope`` so the route
    handler can pass either signal. Both eventually agree because the
    install/uninstall/samples primitives only operate on a deployed
    ModelVersion whose own scope IS the run's scope.
    """
    explicit = normalize_scope(getattr(req, "scope", None) or "")
    if explicit in ("ecm", "mvm"):
        return explicit
    raw = normalize_scope(getattr(parent_mv, "scope", "") or "")
    return "ecm" if raw == "ecm" else "mvm"


def _model_version_int(req: Any, parent_mv: Any) -> int:
    """The integer version this run operates on. ``0`` if unresolvable
    (the validator will reject it because all three deployment
    primitives require ``model_version > 0``)."""
    explicit = getattr(req, "version_int", None)
    if isinstance(explicit, int) and explicit > 0:
        return explicit
    if parent_mv is None:
        return 0
    try:
        return int(getattr(parent_mv, "version", 0) or 0)
    except (TypeError, ValueError):
        return 0


def _schema_prefix_for(
    req: Any,
    cataloging_style: str,
    parent_mv: Any = None,
    installed: Optional[str] = None,
) -> str:
    """The ``schema_prefix`` an uninstall sends (also the uninstall step
    of an install that replaces another version).

    In order: ``req.schema_prefix`` (a typed value, ``""`` included, which
    the primitive's One Catalog rule refuses); ``installed``, the prefix the
    version's latest install dispatched in this cataloging style; ``""`` for
    Catalog per Division / Domain; else the scope default of ``parent_mv``
    (``ecm_`` / ``mvm_``, ``mvm_`` with no scope), the prefix One Catalog
    installs used before the app recorded them.
    """
    explicit = getattr(req, "schema_prefix", None)
    if explicit is not None:
        # Explicit user choice — pass through verbatim. The primitive's
        # validator will surface a blocker if the value combined with
        # the cataloging_style is illegal.
        return explicit
    if installed is not None:
        return installed
    if cataloging_style != "One Catalog":
        # Catalog per Division / per Domain: the per-scope catalog
        # already provides the namespace; passing a prefix would
        # double-namespace and fail validation.
        return ""
    # One Catalog: derive from the parent model version's scope.
    scope = ""
    if parent_mv is not None:
        scope = normalize_scope(getattr(parent_mv, "scope", "") or "")
    # No parent scope information: fall back to ``mvm_``. Most callers
    # of these single-step ops target a deployed (MVM) model.
    return "ecm_" if scope == "ecm" else "mvm_"


def install_schema_prefix(req: Any, recorded: Optional[str] = None) -> tuple[str, str]:
    """The ``schema_prefix`` an install sends, and where it comes from:
    ``(prefix, source)``.

    - ``"request"``: the request names ``schema_prefix``. A typed prefix
      other than the version's file's (and, in place, its recorded one) is
      refused before the run starts and again at dispatch
      (``install.typed_prefix_refusal``): the agent would rename the schemas
      and drop the metric views. A typed ``""`` is kept, so the One Catalog
      rule still refuses it.
    - ``"record"``: ``recorded``, the prefix of the version's install into the
      target catalog when it is installed there now
      (``preflight.inplace_install_prefix``): an in-place reinstall keeps the
      schemas that install made.
    - ``"version"``: otherwise. ``Install.dispatch`` sends the prefix of the
      model.json it installs, ``""`` included (``apply_file_prefix``), and
      fails the step when that file can't be read. Every import writes its
      scope prefix into the app's copy of the file
      (``services/scope_prefix``), so an ECM and an MVM installed into one
      catalog get ``ecm_`` / ``mvm_``.
    """
    explicit = getattr(req, "schema_prefix", None)
    if explicit is not None:
        return explicit, "request"
    if recorded is not None:
        return recorded, "record"
    return "", "version"


def dag_for_vibe_iterate(
    req: Any,
    business: Any,
    ctx: Any = None,
    agent_cfg: Any = None,
) -> Dag:
    """Single-op DAG for the ``vibe-iterate`` intent.

    The agent's ``vibe modeling of version`` op iterates an existing
    ModelVersion: it reads the parent's ``model.json``, applies the
    user's vibe text, and writes a NEW version. ``parent_version_id``
    flows through :class:`OperationContext` (set by the route handler
    on the persisted ``RunOperation`` row) — NOT through the params
    dict.
    """
    return Dag(
        intent=Intent.VIBE_ITERATE.value,
        steps=(
            OperationStep(
                name="vibe_iterate",
                params={
                    "business_name": _sanitized_business_name(business),
                    "deployment_catalog": resolve_run_target_catalog(req, agent_cfg),
                    "vibe_instructions": getattr(req, "vibe_instructions", "") or "",
                    "cataloging_style": _resolved_cataloging_style(req),
                    "schema_prefix": getattr(req, "schema_prefix", "") or "",
                    "vibe_scope": getattr(req, "vibe_scope", "all_domains") or "all_domains",
                    "vibe_scope_domains": getattr(req, "vibe_scope_domains", []) or [],
                    "dry_run": getattr(req, "dry_run", False) or False,
                    # Carry-keys (the params model defaults already match
                    # the agent's expectations; these only fire when the
                    # caller wants to override). Keep this list narrow —
                    # vibe_iterate's params model accepts a wide surface
                    # but most fields are intentionally optional.
                    **_optional_convention_params(req),
                },
            ),
        ),
    )


def dag_for_install(
    req: Any,
    business: Any,
    ctx: Any = None,
    agent_cfg: Any = None,
) -> Dag:
    """DAG for the ``install`` intent.

    ``ctx.parent_mv`` is the version being installed (its scope, number and
    file locations). The target catalog is the request's, else the
    version's install catalog, else its files catalog, else the run default
    (``resolve_install_target_catalog``). The step carries the paths the
    version's model.json may be at (``context_file_candidates``):
    ``ctx.context_file_candidates``, the route's
    ``version_files.version_model_json_candidates`` (its ``/Volumes/`` import
    source, then the nested and flat folders under its files catalog,
    ``resolve_version_volume_catalog``), then the folders under the target
    catalog, each path once. A ``ctx`` without them starts from the import
    source; a 0.9.0 import (markers set) has none, its file is the app's
    copy in its folder.

    ``ctx.occupant`` is another version of the same business and scope
    installed in the target catalog that the request confirmed replacing:
    the DAG then uninstalls it first (with the prefix its last install
    dispatched, ``ctx.occupant_install_widgets``) and installs the version
    fresh (:func:`uninstall_then_install`). Otherwise it is one install step.

    The ``schema_prefix`` is :func:`install_schema_prefix`'s: the request's,
    else the recorded one of an in-place reinstall
    (``ctx.recorded_install_prefix``), else the one in the version's
    model.json, read at dispatch.
    The orchestrator's ``parent_version_id`` is set on the persisted rows by
    the route handler; the install step also names the version
    (``version_id``).
    """
    parent_mv = getattr(ctx, "parent_mv", None) if ctx is not None else None
    occupant = getattr(ctx, "occupant", None) if ctx is not None else None
    cataloging_style = _resolved_cataloging_style(req)
    business_name = _sanitized_business_name(business)
    catalog = resolve_install_target_catalog(req, parent_mv, agent_cfg)
    scope = _scope_short(req, parent_mv)
    version = _model_version_int(req, parent_mv)
    version_candidates = list(getattr(ctx, "context_file_candidates", None) or ())
    target_candidates = model_json_candidates(
        catalog, business_name, version, scope, readable_import_source(parent_mv),
    )
    context_file_candidates = list(dict.fromkeys(version_candidates + target_candidates))
    # The convention keys the caller set. A blank counts as unset here: the
    # defaults below replace it, and the agent's install merge also treats a
    # blank widget as "no override". For a ``_vibe_scope`` model.json,
    # ``Install.dispatch`` keeps these and takes the rest from the file.
    explicit = _set_request_fields(req, CONVENTION_FILE_KEYS, blank_is_unset=True)
    # ``schema_suffix`` / ``tag_prefix`` have no install default, so their
    # explicit values ride along in the params. They reach the widget map
    # only for a ``_vibe_scope`` file (``effective_install_params``).
    optional_keys = {
        key: explicit[key] for key in ("schema_suffix", "tag_prefix") if key in explicit
    }
    recorded = getattr(ctx, "recorded_install_prefix", None) if ctx is not None else None
    prefix, prefix_source = install_schema_prefix(req, recorded)
    install_params = {
        "scope": scope,
        "business_name": business_name,
        "deployment_catalog": catalog,
        "schema_prefix": prefix,
        **({"prefix_from_record": True} if prefix_source == "record" else {}),
        **({"prefix_from_version": True} if prefix_source == "version" else {}),
        **({"recorded_prefix": recorded} if recorded is not None else {}),
        "model_version": version,
        "cataloging_style": cataloging_style,
        "naming_convention": (
            getattr(req, "naming_convention", None) or "snake_case"
        ),
        "primary_key_suffix": (
            getattr(req, "primary_key_suffix", None) or "_id"
        ),
        "table_id_type": (
            getattr(req, "table_id_type", None) or "BIGINT"
        ),
        "context_file_candidates": context_file_candidates,
        "explicit_convention_keys": list(explicit),
        "version_id": getattr(parent_mv, "id", None),
        **optional_keys,
    }
    if occupant is None:
        dag = Dag(
            intent="install",
            steps=(OperationStep(name="install", params=install_params),),
        )
    else:
        dag = uninstall_then_install(
            "install",
            uninstall_step_params(
                business, occupant, catalog, cataloging_style,
                getattr(ctx, "occupant_install_widgets", None),
            ),
            install_params,
        )
    return dag


def uninstall_step_params(
    business: Any, mv: Any, catalog: str, cataloging_style: str, install_widgets: Optional[dict],
) -> dict:
    """The params of an ``uninstall`` step that removes ``mv`` (of
    ``business``) from ``catalog`` as its last install laid it down: the
    prefix that install dispatched in this style (``install_widgets``), else
    its scope default."""
    installed = installed_schema_prefix(install_widgets, cataloging_style)
    return {
        "business_name": _sanitized_business_name(business),
        "deployment_catalog": catalog,
        "schema_prefix": _schema_prefix_for(None, cataloging_style, mv, installed),
        "scope": _scope_short(None, mv),
        "model_version": int(mv.version),
        "cataloging_style": cataloging_style,
        "version_id": mv.id,
    }


def dag_for_uninstall(
    req: Any,
    business: Any,
    ctx: Any = None,
    agent_cfg: Any = None,
) -> Dag:
    """Single-op DAG for the ``uninstall`` intent.

    Mirror of :func:`dag_for_install` but emits the ``uninstall``
    primitive. The two share a params surface; we narrow to the
    fields ``UninstallParams`` actually accepts (no naming convention
    pass-through — the agent's uninstall op doesn't use them).

    With no catalog in the request it targets where the version was last
    installed (``resolve_uninstall_target_catalog``).

    ``ctx.install_widgets`` (the widgets of the version's latest install,
    resolved by the route) supplies the prefix that install really used,
    so a scoped install made with its file's prefix is uninstalled with
    the same one.
    """
    parent_mv = getattr(ctx, "parent_mv", None) if ctx is not None else None
    cataloging_style = _resolved_cataloging_style(req)
    installed = installed_schema_prefix(
        getattr(ctx, "install_widgets", None), cataloging_style
    )
    return Dag(
        intent="uninstall",
        steps=(
            OperationStep(
                name="uninstall",
                params={
                    "business_name": _sanitized_business_name(business),
                    "deployment_catalog": resolve_uninstall_target_catalog(req, parent_mv, agent_cfg),
                    "schema_prefix": _schema_prefix_for(
                        req, cataloging_style, parent_mv, installed
                    ),
                    "scope": _scope_short(req, parent_mv),
                    "model_version": _model_version_int(req, parent_mv),
                    "cataloging_style": cataloging_style,
                    "version_id": getattr(parent_mv, "id", None),
                },
            ),
        ),
    )


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def _set_request_fields(
    req: Any, fields: Iterable[str], *, blank_is_unset: bool
) -> dict[str, Any]:
    """The ``fields`` the request set, in ``fields`` order.

    ``None`` (absent from the body) is always unset. ``""`` is a value
    unless ``blank_is_unset``: ``vibe_iterate`` forwards an explicit blank
    (e.g. ``tag_prefix=""`` means no tag prefix), while install treats a
    blank as "no override" (see :func:`dag_for_install`).
    """
    out: dict[str, Any] = {}
    for field in fields:
        v = getattr(req, field, None)
        if v is None or (blank_is_unset and v == ""):
            continue
        out[field] = v
    return out


def _optional_convention_params(req: Any) -> dict:
    """Forward only the convention overrides the user actually set.

    ``vibe_iterate`` params model accepts a large surface (carry-keys
    for the agent's ``vibe modeling of version`` op). For each field
    we forward only when the caller explicitly supplied a value —
    leaving Pydantic to pick its default for everything else. This
    keeps the persisted ``params_json`` blob narrow on the happy path
    and avoids accidentally locking in a stale default.
    """
    out = _set_request_fields(
        req, RUN_CONVENTION_FIELDS, blank_is_unset=False
    )
    # Inline business context override → the agent's
    # business_description carry-key (mirrors the legacy router).
    biz_text = getattr(req, "business_context_text", "") or ""
    if biz_text.strip():
        out["business_description_override"] = biz_text.strip()
    biz_path = getattr(req, "business_context_path", "") or ""
    if biz_path.strip():
        out["business_context_path"] = biz_path.strip()
    model_size = getattr(req, "model_size", None)
    if model_size:
        out["model_size"] = model_size
    return out


__all__ = [
    "dag_for_install",
    "dag_for_uninstall",
    "dag_for_vibe_iterate",
    "uninstall_step_params",
]

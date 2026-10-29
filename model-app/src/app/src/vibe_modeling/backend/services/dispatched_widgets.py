"""Read back the widget maps the app actually dispatched to the agent.

``RunOperation.dispatched_widgets_json`` is the write-once audit of the
exact widget map each op handed to ``jobs.run_now()`` (see
``OperationDispatchHandle.dispatched_widgets``). Code that needs to know
how a version was really generated or installed reads it here instead of
re-deriving the values from defaults:

- :func:`dispatched_schema_affixes_for_version` - every ``schema_prefix`` /
  ``schema_suffix`` the version's succeeded generation and install ops
  carried (the installation drift probe); :func:`schema_affixes_of` reads
  them off any widget maps.
- :func:`install_widgets_into` - the widget map of the version's most
  recent successful install into one catalog (the drift probe trusts its
  ``schema_prefix`` over the scope-prefixed and bare guesses there).
- :func:`latest_install_widgets` - the widget map of the version's most
  recent successful install (into a given catalog when there is one).
- :func:`installed_schema_prefix` - that install's ``schema_prefix``, for
  uninstall and delete-with-reinstall to target the schemas install made.
- :func:`generation_widgets_for_version` - the widget map of the succeeded
  op that produced the version (an app run's step or a linked run's job),
  for the run form's pre-fill.

An op links to a version via ``output_version_id`` (a generation op) or
``parent_version_id`` (an install/uninstall op, or a child run that read it).
Callers fall back to the derived default when no op is found.
"""

from __future__ import annotations

import json
import logging
from collections.abc import Iterable, Iterator
from typing import Any, Optional

from sqlmodel import and_, col, or_, select

from ..db_models import RunOperation

logger = logging.getLogger(__name__)


def _widget_maps(blobs: Iterable[Any]) -> Iterator[dict]:
    """Parse ``dispatched_widgets_json`` values, skipping empty or bad ones."""
    for r in blobs:
        # ``session.exec`` yields the column value for a one-column select;
        # accept a row tuple too.
        blob = r if isinstance(r, str) else (r[0] if r else "")
        if not blob or blob == "{}":
            continue
        try:
            widgets = json.loads(blob)
        except (json.JSONDecodeError, TypeError):
            continue
        if isinstance(widgets, dict):
            yield widgets


def schema_affixes_of(widget_maps: Iterable[dict]) -> tuple[list[str], list[str]]:
    """The ``schema_prefix`` / ``schema_suffix`` values of ``widget_maps``,
    de-duplicated and in order. ``""`` is a real value (the Catalog-per-*
    prefix); only an absent key carries no signal."""
    prefixes: list[str] = []
    suffixes: list[str] = []
    for widgets in widget_maps:
        if "schema_prefix" in widgets:
            p = str(widgets.get("schema_prefix") or "")
            if p not in prefixes:
                prefixes.append(p)
        if "schema_suffix" in widgets:
            s = str(widgets.get("schema_suffix") or "")
            if s not in suffixes:
                suffixes.append(s)
    return prefixes, suffixes


def dispatched_schema_affixes_for_version(
    session, version_id: str
) -> tuple[list[str], list[str]]:
    """Every ``schema_prefix`` / ``schema_suffix`` dispatched for the op(s)
    that produced or installed ``version_id``.

    Only succeeded ops count: those whose ``output_version_id`` is the
    version (its generation) and the ``install`` ops whose
    ``parent_version_id`` is the version. A failed install deployed nothing,
    and a child op that merely read the version (a shrink or vibe run with
    it as ``parent_version_id``) carries the prefix of the version it made.

    ``schema_prefix`` appears in both install and generation widgets;
    ``schema_suffix`` in the generation/vibe-iterate widgets and in a
    scoped install's widgets, so every linked op is scanned and the values
    unioned.

    Returns ``(prefixes, suffixes)`` - de-duplicated, order-preserving, and
    EMPTY when no op carries a ``dispatched_widgets_json`` (pre-E-03
    installs, hand-built rows). Empty lists are the caller's signal to fall
    back to the legacy scope-prefixed / bare probing.
    """
    try:
        rows = session.exec(
            select(RunOperation.dispatched_widgets_json).where(
                RunOperation.status == "succeeded",
                or_(
                    RunOperation.output_version_id == version_id,
                    and_(
                        RunOperation.operation_name == "install",
                        RunOperation.parent_version_id == version_id,
                    ),
                ),
            )
        ).all()
    except Exception as exc:  # noqa: BLE001 - best-effort enrichment only
        logger.debug(
            "Could not read dispatched widgets for %s: %s", version_id, exc,
        )
        return [], []
    return schema_affixes_of(_widget_maps(rows))


def generation_widgets_for_version(session, version_id: Optional[str]) -> Optional[dict]:
    """The widget map of the most recent succeeded op whose output is
    ``version_id``, or ``None`` when there is none (an imported or kickstarted
    version, a pre-audit run) or it cannot be read."""
    if not version_id:
        return None
    try:
        rows = session.exec(
            select(RunOperation.dispatched_widgets_json)
            .where(
                RunOperation.output_version_id == version_id,
                RunOperation.status == "succeeded",
            )
            .order_by(col(RunOperation.created_at).desc())
        ).all()
    except Exception as exc:  # noqa: BLE001 - callers fall back to defaults
        logger.debug(
            "Could not read generation widgets for %s: %s", version_id, exc,
        )
        return None
    return next(_widget_maps(rows), None)


def _install_widget_maps(
    session, version_id: Optional[str], status: str = "succeeded"
) -> list[dict]:
    """The widget maps of ``version_id``'s install ops with ``status``,
    newest first; empty when there is none (or they cannot be read)."""
    if not version_id:
        return []
    try:
        rows = session.exec(
            select(RunOperation.dispatched_widgets_json)
            .where(
                RunOperation.parent_version_id == version_id,
                RunOperation.operation_name == "install",
                RunOperation.status == status,
            )
            .order_by(col(RunOperation.created_at).desc())
        ).all()
    except Exception as exc:  # noqa: BLE001 - callers fall back to defaults
        logger.debug(
            "Could not read install widgets for %s: %s", version_id, exc,
        )
        return []
    return list(_widget_maps(rows))


def _install_into(maps: list[dict], catalog: Optional[str]) -> Optional[dict]:
    target = (catalog or "").strip().lower()
    if not target:
        return None
    for widgets in maps:
        if str(widgets.get("deployment_catalog") or "").strip().lower() == target:
            return widgets
    return None


def failed_install_widgets_into(session, version_id: Optional[str], catalog: Optional[str]) -> list[dict]:
    """The widget maps of ``version_id``'s failed install ops that targeted
    ``catalog`` (their ``deployment_catalog``, compared in lower case),
    newest first. A failed install can leave schemas it created before it
    failed, in the catalog it targeted only."""
    target = (catalog or "").strip().lower()
    if not target:
        return []
    return [
        w for w in _install_widget_maps(session, version_id, "failed")
        if str(w.get("deployment_catalog") or "").strip().lower() == target
    ]


def install_widgets_into(session, version_id: Optional[str], catalog: Optional[str]) -> Optional[dict]:
    """The widget map of ``version_id``'s most recent succeeded install into
    ``catalog`` (its ``deployment_catalog``, compared in lower case), or
    ``None`` when no recorded install targeted that catalog."""
    return _install_into(_install_widget_maps(session, version_id), catalog)


def latest_install_widgets(
    session, version_id: Optional[str], catalog: Optional[str] = None
) -> Optional[dict]:
    """The widget map of ``version_id``'s most recent succeeded install op,
    or ``None`` when there is none (or it cannot be read).

    With ``catalog``, the most recent install into that catalog (its
    ``deployment_catalog``, compared in lower case) when there is one, else
    the most recent install."""
    maps = _install_widget_maps(session, version_id)
    into = _install_into(maps, catalog)
    if into is not None:
        return into
    return maps[0] if maps else None


def installed_schema_prefix(
    install_widgets: Optional[dict], cataloging_style: str
) -> Optional[str]:
    """The ``schema_prefix`` an install dispatched, or ``None``.

    ``None`` when there is no recorded install, it carried no
    ``schema_prefix``, or it used another cataloging style (a prefix only
    means something together with its style).
    """
    if not install_widgets or "schema_prefix" not in install_widgets:
        return None
    if (install_widgets.get("cataloging_style") or "One Catalog") != cataloging_style:
        return None
    return str(install_widgets.get("schema_prefix") or "")

"""Identity of the configured agent notebook, and who owns it.

The notebook at ``AgentConfig.notebook_path`` declares a release
(``__RELEASE_VERSION__``, e.g. ``v0.8.0``) and an agent-logic marker
(``__AGENT_VERSION__``, e.g. ``5.3.3``). Reading them takes one workspace
export, so the values are cached on the ``agent_config.installed_*`` columns
for ``IDENTITY_TTL`` and refreshed live when the cache is older, empty, or was
read from another path. Boot reads it live (``installed_identity`` with
``max_age=timedelta(0)``); the Settings save (``PUT /config/agent``) and the
switch route record what they read or uploaded. ``IDENTITY_TTL`` and the
live fallback of ``installed_identity`` serve the marker gates the A3 and C2
units move onto this cache. The polled ``GET /config/agent-compat`` serves
the stored values only (``cached_identity_for_current_path``) and never
reads the notebook.

Ownership: a notebook in the app's own agent folder
(``bundled_agent_install.app_agent_folder``) belongs to the app, which
upgrades it on boot; any other path belongs to the admin and is never
overwritten.
"""

from __future__ import annotations

import logging
import posixpath
from dataclasses import dataclass
from datetime import datetime, timedelta, timezone
from typing import TYPE_CHECKING, Callable, Literal, Optional

from ..agent_compat import is_newer_tag
from ..error_sanitization import sanitize_error_message
from ..models import InstalledVsBundled
from ._time import as_utc

if TYPE_CHECKING:
    from ..bundled_agent import BundledAgent
    from ..db_models import AgentConfig

logger = logging.getLogger(__name__)

IDENTITY_TTL = timedelta(minutes=10)

AgentOwner = Literal["app", "admin"]

_NO_MARKER_ERROR = (
    "The notebook has no __RELEASE_VERSION__ / __AGENT_VERSION__ marker, so its "
    "agent version is unknown."
)


@dataclass(frozen=True)
class NotebookIdentity:
    """A notebook's (release, marker) as last read, with when, from where and why not."""

    release: Optional[str]
    marker: Optional[str]
    checked_at: Optional[datetime]
    path: Optional[str]
    error: Optional[str]


def _now() -> datetime:
    return datetime.now(timezone.utc)


def cached_identity(cfg: "AgentConfig") -> NotebookIdentity:
    """The identity stored on ``cfg``, without reading the notebook."""
    return NotebookIdentity(
        release=cfg.installed_release_version,
        marker=cfg.installed_agent_version,
        checked_at=as_utc(cfg.installed_checked_at),
        path=cfg.installed_checked_path,
        error=cfg.installed_check_error,
    )


def cached_identity_for_current_path(cfg: "AgentConfig") -> NotebookIdentity:
    """The stored identity when it was read from the configured path, else an
    empty one. Never reads the notebook and never writes: for hot read paths
    such as ``GET /config/agent-compat``, which the New Run form polls."""
    if not cfg.notebook_path or cfg.installed_checked_path != cfg.notebook_path:
        return NotebookIdentity(None, None, None, None, None)
    return cached_identity(cfg)


def supports_scope(marker: Optional[str]) -> Optional[bool]:
    """Whether an agent marker supports scoped and Dry runs
    (``core._vibe_scope.MIN_AGENT_MARKER_FOR_SCOPE``); None when unknown."""
    from ._vibe_scope import MIN_AGENT_MARKER_FOR_SCOPE

    if not marker:
        return None
    return not is_newer_tag(MIN_AGENT_MARKER_FOR_SCOPE, marker)


def _is_fresh(cfg: "AgentConfig", now: datetime, max_age: timedelta) -> bool:
    checked_at = as_utc(cfg.installed_checked_at)
    return (
        checked_at is not None
        and cfg.installed_checked_path == cfg.notebook_path
        and (now - checked_at) <= max_age
    )


def record_installed_identity(
    cfg: "AgentConfig",
    *,
    path: str,
    release: Optional[str],
    marker: Optional[str],
    error: Optional[str] = None,
    now: Optional[datetime] = None,
) -> None:
    """Store an identity on ``cfg``; the caller commits.

    Used directly when the identity is known without reading the file (the
    app has just uploaded the bundled notebook to ``path``).
    """
    cfg.installed_release_version = release
    cfg.installed_agent_version = marker.lstrip("vV") if marker else None
    cfg.installed_check_error = error
    cfg.installed_checked_path = path
    cfg.installed_checked_at = now or _now()


def record_read_identity(
    cfg: "AgentConfig",
    *,
    path: str,
    release: Optional[str],
    marker: Optional[str],
    now: Optional[datetime] = None,
) -> None:
    """Store the result of a successful notebook read; the caller commits.

    A notebook without markers records why its identity is unknown.
    """
    record_installed_identity(
        cfg,
        path=path,
        release=release,
        marker=marker,
        error=None if (release or marker) else _NO_MARKER_ERROR,
        now=now,
    )


def installed_identity(
    session,
    ws,
    cfg: "AgentConfig",
    *,
    max_age: timedelta = IDENTITY_TTL,
    now: Optional[datetime] = None,
    store_if: Optional[Callable[[], bool]] = None,
) -> NotebookIdentity:
    """The configured notebook's identity, read live when the cache is stale.

    A live read stores the result on ``cfg`` and commits. A failed read
    records the error and keeps the last-good versions when they were read
    from the same path (another path's versions are dropped). With no
    notebook configured, returns an empty identity and writes nothing.
    ``max_age=timedelta(0)`` forces a live read. ``store_if``, called after
    the read, can veto the write (the boot upgrade passes "the deadline has
    not passed and the stored path is unchanged"); the read is then returned
    without being stored.
    """
    from ..routes._helpers import _detect_notebook_identity

    path = cfg.notebook_path
    if not path:
        return NotebookIdentity(None, None, None, None, None)
    now = now or _now()
    if max_age > timedelta(0) and _is_fresh(cfg, now, max_age):
        return cached_identity(cfg)

    error = None
    try:
        release, marker = _detect_notebook_identity(ws, path)
    except Exception as e:  # noqa: BLE001 - any read failure is recorded, never raised
        error = sanitize_error_message(f"{type(e).__name__}: {e}")
        logger.warning("agent identity: could not read %s: %s", path, error)
        same_path = cfg.installed_checked_path == path
        release = cfg.installed_release_version if same_path else None
        marker = cfg.installed_agent_version if same_path else None
    if store_if is not None and not store_if():
        return NotebookIdentity(
            release, marker.lstrip("vV") if marker else None, now, path, error
        )
    if error is not None:
        record_installed_identity(
            cfg, path=path, release=release, marker=marker, error=error, now=now
        )
    else:
        record_read_identity(cfg, path=path, release=release, marker=marker, now=now)
    session.add(cfg)
    session.commit()
    return cached_identity(cfg)


def compare_to_bundled(
    release: Optional[str], marker: Optional[str], bundled: Optional["BundledAgent"]
) -> InstalledVsBundled:
    """Compare an installed (release, marker) with the bundled agent, release first.

    Pre-0.8.0 notebooks report their marker as the release
    (``routes/_helpers._detect_notebook_identity``), so an old notebook sorts
    as an older release. Within one release the marker decides.
    """
    if bundled is None or not release:
        return "unknown"
    if is_newer_tag(bundled.pinned_tag, release):
        return "older"
    if is_newer_tag(release, bundled.pinned_tag):
        return "newer"
    if not marker or not bundled.agent_version:
        return "unknown"
    if is_newer_tag(bundled.agent_version, marker):
        return "older"
    if is_newer_tag(marker, bundled.agent_version):
        return "newer"
    return "same"


def is_app_owned(path: str, sp_home: str) -> bool:
    """True when ``path`` is inside the app's own agent folder under ``sp_home``.

    Workspace paths are accepted with or without the ``/Workspace`` prefix,
    and ``.`` / ``..`` segments are resolved first, so a path that climbs out
    of the folder is not app-owned.
    """
    from ..bundled_agent_install import app_agent_folder

    if not path or not sp_home:
        return False
    normalized = posixpath.normpath(path)
    if normalized.startswith("/Workspace/"):
        normalized = normalized[len("/Workspace"):]
    return normalized.startswith(app_agent_folder(sp_home) + "/")


def agent_owner(path: str, sp_home: str) -> Optional[AgentOwner]:
    """``app`` or ``admin`` for a configured ``path``; None with no path or no known home."""
    if not path or not sp_home:
        return None
    return "app" if is_app_owned(path, sp_home) else "admin"

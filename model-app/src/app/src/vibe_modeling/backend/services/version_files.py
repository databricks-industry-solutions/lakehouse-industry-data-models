"""Where a model version's files are, and the conventions its ``model.json`` holds.

- :func:`model_json_candidates` - the paths a version's ``model.json`` may be
  at, in the order to try them: the file an import read, when it is a
  ``/Volumes/`` path; then the agent's nested and flat layouts
  (``core/_paths.model_json_volume_candidates``). A source that is not a
  Volume path (a downloaded industry version records ``github://...``) is
  never a candidate: the agent and the Files API read Volume paths only.
- :func:`version_model_json_candidates` - the same for a ``ModelVersion``
  row: its ``import_source_path`` (unless the import copied the file into
  the app's folder), then the layouts under its files catalog
  (``resolve_version_volume_catalog``).
- :func:`is_app_copy` / :func:`readable_import_source` - a version whose
  file is the copy a 0.9.0 import wrote into the app's folder never reads its
  ``import_source_path`` (the user's file); :func:`app_written_folder` is the
  folder the app wrote for it, which deleting the version removes.
- :func:`read_conventions` - the ``model.model_conventions`` of the first
  candidate that reads (bounded, ``_install_conventions.read_model_json``).
  With ``exists``, a candidate that is not there is skipped and one that is
  there but cannot be read is reported as ``unreadable``. Never raises.
- :func:`read_version_conventions` - :func:`read_conventions` over a
  version's candidates; ``None`` when none reads.
- :func:`first_readable_model_json` - the first candidate that reads and
  parses, with its content (bounded per read; the install passes its longer
  budget).

The vibe pre-fill (``run_defaults``), the shrink step's copy of its parent
ECM's conventions and the industry kickstart's prefix read all go through
:func:`read_conventions`.
"""

from __future__ import annotations

import logging
from typing import Any, Callable, NamedTuple, Optional

from ..core import resolve_version_volume_catalog, volume_path_catalog
from ..core._paths import file_in_folder, model_json_volume_candidates, version_dir_in_volume
from ..import_model import model_conventions

logger = logging.getLogger(__name__)


class ConventionsRead(NamedTuple):
    """What :func:`read_conventions` found: the path it read (``None`` when no
    candidate was there or readable), the file's ``model_conventions``
    (``None`` when it has none) and whether a present file failed to read."""

    path: Optional[str]
    conventions: Optional[dict]
    unreadable: bool = False


def model_json_candidates(
    catalog: str,
    business_name: str,
    version: int,
    scope: str,
    source_path: Optional[str] = None,
) -> list[str]:
    """The paths a version's ``model.json`` may be at, most likely first.

    The ``/Volumes/`` source path leads because an import or a legacy dialog
    import owns that file; the canonical folders can hold files of a deleted
    version at the same number."""
    out: list[str] = []
    source = (source_path or "").strip()
    if volume_path_catalog(source) is not None:
        out.append(source)
    if catalog:
        try:
            out.extend(model_json_volume_candidates(catalog, business_name, int(version), scope))
        except ValueError:
            # A malformed scope: no canonical path to try.
            logger.warning("no canonical model.json path for scope %r", scope)
    return [p for i, p in enumerate(out) if p not in out[:i]]


def is_app_copy(mv: Any) -> bool:
    """Whether ``mv``'s file is the copy a 0.9.0 import wrote into the app's
    folder (its import markers are set, ``""`` included)."""
    return getattr(mv, "import_schema_prefix_added", None) is not None


def readable_import_source(mv: Any) -> Optional[str]:
    """The ``import_source_path`` to try for ``mv``'s model.json: ``None`` for
    an app copy (:func:`is_app_copy`), whose source is the user's file
    without the app's prefix."""
    return None if is_app_copy(mv) else getattr(mv, "import_source_path", None)


def app_written_folder(session: Any, mv: Any, business_name: str) -> Optional[str]:
    """The version folder the app wrote for ``mv``: an app copy's folder
    (``core/_paths.version_dir_in_volume`` under its files catalog), unless
    the import kept a file that was already there (the folder is the file's
    own). ``None`` for every other version: the agent or the user wrote its
    files."""
    if not is_app_copy(mv):
        return None
    try:
        folder = version_dir_in_volume(
            resolve_version_volume_catalog(mv, session), business_name, int(mv.version), mv.scope,
        )
    except ValueError:
        return None
    source = (getattr(mv, "import_source_path", None) or "").strip()
    if source and file_in_folder(source, folder):
        return None
    return folder


def version_model_json_candidates(session: Any, mv: Any, business_name: str) -> list[str]:
    """The paths ``mv``'s ``model.json`` may be at, most likely first
    (:func:`readable_import_source`, then the layouts under its files
    catalog)."""
    return model_json_candidates(
        resolve_version_volume_catalog(mv, session),
        business_name,
        mv.version,
        mv.scope,
        readable_import_source(mv),
    )


def read_conventions(
    ws: Any,
    paths: list[str],
    *,
    exists: Optional[Callable[[str], bool]] = None,
    timeout_s: Optional[float] = None,
) -> ConventionsRead:
    """Read the first of ``paths`` that reads; see the module docstring.
    ``timeout_s`` is each read's budget (``read_model_json``'s default when
    ``None``)."""
    # Imported here: ``services.operations`` imports this module (the shrink
    # step), so a module-level import would make a cycle on a cold import.
    from .operations._install_conventions import read_model_json

    for path in paths:
        if exists is not None and not exists(path):
            continue
        root = read_model_json(ws, path, timeout_s=timeout_s)
        if root is None:
            if exists is not None:
                return ConventionsRead(path, None, unreadable=True)
            continue
        return ConventionsRead(path, model_conventions(root))
    return ConventionsRead(None, None)


def first_readable_model_json(
    ws: Any, paths: list[str], *, timeout_s: Optional[float] = None
) -> tuple[Optional[str], Any]:
    """The first of ``paths`` that reads and parses, with its content, else
    ``(None, None)``. Each read is bounded by ``timeout_s``
    (``_install_conventions.read_model_json``)."""
    from .operations._install_conventions import read_model_json

    for path in paths:
        root = read_model_json(ws, path, timeout_s=timeout_s)
        if root is not None:
            return path, root
    return None, None


def read_version_conventions(
    session: Any, ws: Any, mv: Any, business_name: str
) -> Optional[dict]:
    """The ``model.model_conventions`` of ``mv``'s ``model.json``, or ``None``
    when no candidate path can be read or the file has none."""
    return read_conventions(ws, version_model_json_candidates(session, mv, business_name)).conventions

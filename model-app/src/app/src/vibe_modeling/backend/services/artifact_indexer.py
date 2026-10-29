"""Shared Volume → RunArtifact indexer.

Walks every file under a Volume folder and writes one ``RunArtifact``
row per file, linked to both the producing ``Run`` (audit) and the
resulting ``ModelVersion`` (navigation). Idempotent — re-indexing the
same (run, path) pair is a no-op except to backfill a NULL
``model_version_id``.

Used by:

- ``services/operations/vibe_iterate.py`` — indexes artifacts after a
  successful vibe sync.
- ``progress_tracker._terminal_success`` — indexes for
  ``generate_ecm`` / ``shrink_to_mvm`` ops.
- ``routes/businesses.execute_import`` — indexes the imported model's
  Volume sibling files (``diagram/``, ``docs/``, ``ontology/``,
  ``schemas/``, ``metrics/``, ``vibes/``, plus top-level ``readme.md``)
  so the Artifacts tab is populated for imported versions too.

Best-effort — every failure is logged and swallowed. Indexing must
never raise from a caller's success path.
"""
from __future__ import annotations

import logging
from typing import Optional

from sqlalchemy import insert as sa_insert
from sqlmodel import Session, select

from ..core._paths import is_app_backup
from ._bulk_model_io import _row_values

logger = logging.getLogger(__name__)


# Extension → artifact_type. Order matters only for collisions; none today.
# Plain-extension mapping is the fallback. Path-specific rules
# (model.json, vibes/next_vibes.json, top-level readme.md) override.
_EXT_TO_TYPE: dict[str, str] = {
    ".json": "json",
    ".sql": "sql",
    ".csv": "csv",
    ".xlsx": "excel",
    ".txt": "text",
    ".md": "markdown",
    ".svg": "svg",
    ".png": "image",
    ".ttl": "rdf",
    ".dbml": "dbml",
}


def infer_artifact_type(path: str, root: Optional[str] = None) -> str:
    """Return the canonical ``artifact_type`` for a file path.

    ``root`` is the Volume folder the walker started from; when provided
    we can distinguish ``vibes/next_vibes.json`` (a typed next-vibes
    blob) from a generic ``model.json``, etc.

    Falls back to extension-based mapping; returns ``"other"`` for
    unknown extensions.
    """
    low = path.lower()
    # Strip the root prefix for cleaner sub-path matching when known.
    sub = low
    if root:
        rlow = root.rstrip("/").lower()
        if low.startswith(rlow + "/"):
            sub = low[len(rlow) + 1:]
    # Path-specific rules first.
    if sub.endswith("/model.json") or sub == "model.json":
        return "model_json"
    if sub.endswith("/vibes/next_vibes.json") or sub == "vibes/next_vibes.json":
        return "next_vibes_json"
    if sub.startswith("vibes/") and sub.endswith(".md"):
        return "vibes_doc"
    if sub.startswith("docs/") and sub.endswith(".xlsx"):
        return "excel"
    if sub.startswith("docs/") and sub.endswith(".csv"):
        return "csv"
    if sub.startswith("docs/") and sub.endswith(".md"):
        return "markdown"
    if sub.startswith("ontology/") and sub.endswith(".ttl"):
        return "turtle"
    if sub.startswith("schemas/") and sub.endswith(".sql"):
        return "sql_ddl"
    if sub.startswith("metrics/") and sub.endswith(".sql"):
        return "metric_sql"
    if sub.startswith("diagram/") and sub.endswith(".dbml"):
        return "dbml"
    if sub == "readme.md":
        return "readme"
    # ``.txt`` companions: type by the parent folder so a downloaded /
    # kickstarted bundle's plain-text siblings index meaningfully rather
    # than collapsing to the generic ``text`` fallback. ``vibes/*.txt`` is
    # the agent's running ``next_vibes.txt`` log; ``ontology/*.txt`` is a
    # text rendering of the ontology; ``docs/*.txt`` is plain documentation.
    # A ``.txt`` outside any known folder still falls through to ``text``
    # via the extension map below.
    if sub.startswith("vibes/") and sub.endswith(".txt"):
        return "vibes_text"
    if sub.startswith("ontology/") and sub.endswith(".txt"):
        return "ontology_text"
    if sub.startswith("docs/") and sub.endswith(".txt"):
        return "text"
    # Extension fallback.
    for ext, t in _EXT_TO_TYPE.items():
        if low.endswith(ext):
            return t
    return "other"


def walk_volume_dir(ws, root: str) -> list[str]:
    """Return absolute file paths under a Volume directory, recursing into
    subdirectories. Missing paths / permission errors yield ``[]`` —
    artifact indexing is best-effort.
    """
    return [path for path, _size in walk_volume_dir_with_size(ws, root)]


def walk_volume_dir_with_size(ws, root: str) -> list[tuple[str, Optional[int]]]:
    """Same as :func:`walk_volume_dir` but also returns ``file_size`` per
    entry when the SDK surfaces it (``None`` when missing).

    Used by the import preview endpoint to show the user how big each
    companion artifact is before they commit to the import.
    """
    out: list[tuple[str, Optional[int]]] = []
    try:
        entries = list(ws.files.list_directory_contents(root))
    except Exception:
        return out
    for entry in entries:
        name = getattr(entry, "name", None)
        if not name:
            continue
        path = f"{root}/{name}"
        if bool(getattr(entry, "is_directory", False)):
            out.extend(walk_volume_dir_with_size(ws, path))
        else:
            size = getattr(entry, "file_size", None)
            out.append((path, size if isinstance(size, int) else None))
    return out


def index_artifacts_at_path(
    ws,
    session: Session,
    *,
    run_id: Optional[str] = None,
    model_version_id: str,
    volume_root_path: str,
) -> int:
    """Walk ``volume_root_path`` and write a ``RunArtifact`` row per file.

    ``run_id`` is ``None`` for imports (no producing Run — imports are
    a synchronous Volume → Lakebase sync); the agent path passes the
    producing Run.id. Either way, the indexer keys the dedupe lookup
    off ``model_version_id`` when run_id is None so re-indexing an
    imported version stays idempotent.

    Returns the number of NEW rows inserted (existing rows are
    silently backfilled with the ``model_version_id`` if it was NULL).
    Never raises — caller's success path is preserved.

    Batched: the existing-row dedupe lookup is ONE select for the whole
    scope (all rows for ``run_id``, or all rows for ``model_version_id``
    when ``run_id`` is None), keyed into a ``file_path`` dict up front, so
    the per-file insert-vs-backfill decision below is an in-memory lookup
    - not one ``session.exec(...).first()`` round trip per file - and every
    new row goes in with a single multi-row INSERT.
    """
    from ..db_models import RunArtifact

    if not ws or not volume_root_path:
        return 0
    try:
        # The app's backups (``model.json.pre090``) are not artifacts of the version.
        files = [f for f in walk_volume_dir(ws, volume_root_path) if not is_app_backup(f)]
        if not files:
            logger.info(
                "artifact_indexer: no files under %s for version %s",
                volume_root_path, model_version_id,
            )
            return 0

        # Dedupe scope by (run_id) when we have one; fall back to
        # (model_version_id) for imports - the same scope the per-file
        # lookups collectively covered, loaded once instead of per file.
        if run_id is not None:
            scope = select(RunArtifact).where(RunArtifact.run_id == run_id)
        else:
            scope = select(RunArtifact).where(
                RunArtifact.run_id.is_(None),
                RunArtifact.model_version_id == model_version_id,
            )
        existing_by_path = {
            row.file_path: row for row in session.exec(scope).all()
        }

        inserted = 0
        backfilled = 0
        new_rows = []
        for path in files:
            existing = existing_by_path.get(path)
            if existing is not None:
                if not existing.model_version_id:
                    existing.model_version_id = model_version_id
                    session.add(existing)
                    backfilled += 1
                continue
            new_rows.append(RunArtifact(
                run_id=run_id,
                model_version_id=model_version_id,
                artifact_type=infer_artifact_type(path, root=volume_root_path),
                file_path=path,
            ))
            inserted += 1
        if new_rows:
            session.execute(sa_insert(RunArtifact), [_row_values(r) for r in new_rows])
        session.flush()
        logger.info(
            "artifact_indexer: version=%s root=%s inserted=%d backfilled=%d",
            model_version_id, volume_root_path, inserted, backfilled,
        )
        return inserted
    except Exception:
        logger.exception(
            "artifact_indexer: indexing failed for run %s version %s "
            "(non-fatal)", run_id, model_version_id,
        )
        return 0

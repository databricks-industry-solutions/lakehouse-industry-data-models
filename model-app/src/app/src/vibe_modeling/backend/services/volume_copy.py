"""Copy a version's folder of Volume files into another folder.

:func:`copy_volume_folder` downloads every file under a source folder and
uploads it under a destination folder, keeping the relative paths, with a
bounded worker pool. Its ``model.json`` (the file at the folder's top) can be
rewritten on the way. Pure Volume I/O: it touches no database, so callers run
it with no Postgres transaction open (a multi-minute copy would trip
Lakebase's idle-in-transaction timeout).

Callers: the industry kickstart (``services/industry_kickstart``, in the
background, no deadline) and the dialog imports (``services/dialog_import``,
in the request, with a deadline).
"""

from __future__ import annotations

import io
import logging
import time
from concurrent.futures import ThreadPoolExecutor, wait
from dataclasses import dataclass
from typing import Callable, Optional

from ..core._paths import is_app_backup

logger = logging.getLogger(__name__)

# The app runs next to the workspace (low latency to Volumes), so a modest
# pool overlaps most of the per-file round trip without a burst of
# concurrent requests against the Files API.
COPY_WORKER_COUNT = 6

ModelJsonTransform = Callable[[bytes], bytes]


@dataclass(frozen=True)
class CopyResult:
    """What :func:`copy_volume_folder` did: ``copied`` of ``total`` files
    landed; ``failed`` lists the source paths that did not; ``timed_out``
    is set when the deadline passed before every file was tried."""

    dest_dir: str
    copied: int
    total: int
    failed: tuple[str, ...] = ()
    timed_out: bool = False

    @property
    def complete(self) -> bool:
        return not self.timed_out and not self.failed and self.copied == self.total


def _copy_one(ws, src_path: str, dest_path: str, transform: Optional[ModelJsonTransform], *, log_prefix: str) -> bool:
    """Download ``src_path`` and upload it to ``dest_path``; ``transform``
    rewrites a ``model.json`` on the way. ``True`` on success, ``False`` on
    any failure (logged, never raised)."""
    try:
        payload = ws.files.download(src_path).contents.read()
        if transform is not None and src_path.rsplit("/", 1)[-1] == "model.json":
            payload = transform(payload)
        # files.upload takes a binary file-like object, not raw bytes.
        ws.files.upload(dest_path, io.BytesIO(payload), overwrite=True)
        return True
    except Exception as exc:  # noqa: BLE001 - reported per file
        logger.warning("%s: could not copy %s -> %s: %s", log_prefix, src_path, dest_path, exc)
        return False


def copy_volume_folder(
    ws,
    files: list[str],
    src_dir: str,
    dest_dir: str,
    *,
    model_json_transform: Optional[ModelJsonTransform] = None,
    deadline: Optional[float] = None,
    log_prefix: str = "copy",
) -> CopyResult:
    """Copy ``files`` (absolute paths under ``src_dir``, as
    ``artifact_indexer.walk_volume_dir`` lists them) to the same relative
    paths under ``dest_dir``, except the app's backups
    (``core/_paths.is_app_backup``). ``model_json_transform`` rewrites the
    top-level ``model.json``. With ``deadline`` (``time.monotonic``), the copy stops
    when it passes: files not started are not copied, and the ones in flight
    (at most :data:`COPY_WORKER_COUNT`) finish before it returns."""
    src = src_dir.rstrip("/")
    pairs = []
    for path in files:
        rel = path[len(src):].lstrip("/") if path.startswith(src + "/") else ""
        if rel and not is_app_backup(rel):
            pairs.append((path, f"{dest_dir}/{rel}"))
    started = time.monotonic()
    copied = 0
    failed: list[str] = []
    timed_out = False
    if pairs:
        pool = ThreadPoolExecutor(max_workers=COPY_WORKER_COUNT)
        try:
            futures = {
                pool.submit(
                    _copy_one, ws, s, d,
                    model_json_transform if s == f"{src}/model.json" else None,
                    log_prefix=log_prefix,
                ): s
                for s, d in pairs
            }
            timeout = None if deadline is None else max(deadline - time.monotonic(), 0.0)
            done, pending = wait(futures, timeout=timeout)
            if pending:
                timed_out = True
                for future in pending:
                    future.cancel()
            for future in done:
                if future.result():
                    copied += 1
                else:
                    failed.append(futures[future])
        finally:
            # Files not started are dropped; the ones in flight finish before
            # this returns, so nothing lands after a caller cleans up.
            pool.shutdown(wait=True, cancel_futures=True)
    logger.info(
        "%s: copied %d/%d file(s) %s -> %s in %.1fs%s",
        log_prefix, copied, len(pairs), src, dest_dir, time.monotonic() - started,
        " (deadline passed)" if timed_out else "",
    )
    return CopyResult(dest_dir, copied, len(pairs), tuple(sorted(failed)), timed_out)


REMOVE_BUDGET_S = 60.0


def remove_volume_folder(ws, folder: str, *, budget_s: float = REMOVE_BUDGET_S, log_prefix: str = "remove") -> int:
    """Delete every file under ``folder`` (``artifact_indexer.walk_volume_dir``)
    with the copy's bounded pool, stopping after ``budget_s``. Best-effort:
    a file that fails is logged, never raised. Returns the files removed."""
    from .artifact_indexer import walk_volume_dir

    files = walk_volume_dir(ws, folder)
    if not files:
        return 0
    deadline = time.monotonic() + budget_s

    def _delete(path: str) -> bool:
        if time.monotonic() > deadline:
            return False
        try:
            ws.files.delete(path)
            return True
        except Exception as exc:  # noqa: BLE001 - best-effort cleanup
            logger.warning("%s: could not remove %s: %s", log_prefix, path, exc)
            return False

    with ThreadPoolExecutor(max_workers=COPY_WORKER_COUNT) as pool:
        removed = sum(1 for ok in pool.map(_delete, files) if ok)
    if removed < len(files):
        logger.warning("%s: removed %d/%d file(s) under %s", log_prefix, removed, len(files), folder)
    return removed


__all__ = ["COPY_WORKER_COUNT", "CopyResult", "copy_volume_folder", "remove_volume_folder"]

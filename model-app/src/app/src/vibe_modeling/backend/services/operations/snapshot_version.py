"""``snapshot_version`` primitive — synthetic, in-process.

Bundles a model version's Volume artifacts (``model.json``, ``next_vibes``,
``vibes/``, ``docs/``, …) into a single zip stored under the
``_snapshots/`` sub-folder of the business's metamodel root, and records a
``RunArtifact`` row pointing at the zip. Produces no new ``ModelVersion``.

Synthetic conventions:

* :meth:`dispatch` performs the zip + upload synchronously and returns a
  handle whose ``extra`` carries the snapshot path.
* :meth:`observe` returns ``is_terminal=True`` immediately.
* :meth:`rollback` deletes the snapshot artifact rows tied to this op.
  The ModelVersion itself is intentionally untouched — snapshots are
  archival, not mutation.

See ``docs/orchestrator-design.md`` §2 (table) and §10 (failure modes).
"""

from __future__ import annotations

import io
import logging
import re
import zipfile
from datetime import datetime, timezone
from typing import Any, Optional

from pydantic import BaseModel, Field, field_validator

from ...core import resolve_version_volume_catalog
from ...core._paths import metamodel_root_for_business, version_dir_candidates
from ...db_models import Business, ModelVersion, RunArtifact, RunOperation
from ..artifact_indexer import walk_volume_dir
from ._registry import register
from ._protocol import (
    Operation,
    OperationContext,
    OperationDispatchHandle,
    OperationObservation,
    OperationResult,
)

logger = logging.getLogger(__name__)


# Allow only alphanumerics, underscore, and dash. Dots are excluded so
# `..` segments from a maliciously-crafted label can never survive the
# sanitiser intact (path traversal defense — see the
# `test_params_model_rejects_or_sanitizes_evil_labels` adversarial cases).
_SAFE_LABEL = re.compile(r"[^a-zA-Z0-9_-]+")


_MAX_LABEL_LEN = 256


class SnapshotVersionParams(BaseModel):
    """Parameters for the ``snapshot_version`` primitive.

    ``label`` is required and is sanitised at validation time so a
    malicious / sloppy paste cannot inject path separators, shell
    metacharacters, or control whitespace into the snapshot's filename.
    Empty/whitespace-only labels are rejected outright.

    ``business_name``, ``deployment_catalog`` and ``version_id`` are
    optional in the params_model and resolved at dispatch time from
    :class:`OperationContext` (spec §2: OperationContext is the source of
    truth for org config and the parent version).
    """

    label: str = Field(min_length=1, max_length=_MAX_LABEL_LEN)
    business_name: str = ""
    deployment_catalog: str = ""
    version_id: str = ""

    @field_validator("label")
    @classmethod
    def _sanitize_label(cls, v: str) -> str:
        if v is None or not str(v).strip():
            raise ValueError(
                "label must be non-empty (no whitespace-only)"
            )
        cleaned = _SAFE_LABEL.sub("_", v).strip("_")
        if not cleaned:
            raise ValueError(
                "label must contain at least one safe character "
                "(letters, digits, '_', '.', '-')"
            )
        if len(cleaned) > _MAX_LABEL_LEN:
            cleaned = cleaned[:_MAX_LABEL_LEN]
        return cleaned


class SnapshotVersion(Operation):
    """Synthetic primitive — zip a version's Volume dir into an archive."""

    name = "snapshot_version"
    params_model = SnapshotVersionParams
    is_idempotent = False
    produces_version = False

    # ------------------------------------------------------------------
    # dispatch — does the zip + upload synchronously
    # ------------------------------------------------------------------

    def dispatch(
        self,
        ctx: OperationContext,
        ws: Any,
        session: Any,
    ) -> OperationDispatchHandle:
        """Read the version's Volume dir, zip every file, upload the archive.

        Idempotent against re-call: if an artifact row was already written
        for this ``operation_id`` we re-emit the same handle without
        re-zipping. The orchestrator may resume from a crash and call
        ``dispatch()`` for an op that already finished.

        Soft-failure semantics (spec §10): empty source dir yields a
        success with zero artifacts (snapshots are archival, an empty
        archive is a legal record of state). Upload failures yield
        ``handle.extra["error"]`` so observe() can surface a terminal
        failure with the underlying message — neither raises.
        """
        params = self.params_model(**ctx.params)

        # Resume guard — RunArtifact rows index by run_id, but we attach the
        # operation_id into file_path's `_snapshots/{op_id}_*.zip` naming so
        # we can detect a prior dispatch by scanning the run's artifacts.
        run_op = session.get(RunOperation, ctx.operation_id)
        if run_op is not None and run_op.rollback_state_json and run_op.rollback_state_json != "{}":
            try:
                import json as _json  # local — avoid module-top dep churn
                prior = _json.loads(run_op.rollback_state_json)
            except (ValueError, TypeError):
                prior = {}
            if prior.get("snapshot_path") or prior.get("empty"):
                return OperationDispatchHandle(
                    databricks_run_id=None,
                    vibe_session_id=None,
                    extra={
                        "completed": True,
                        "snapshot_path": prior.get("snapshot_path"),
                        "artifact_ids": prior.get("artifact_ids", []),
                        "empty": prior.get("empty", False),
                    },
                )

        # Resolve the version: prefer ctx.parent_version_id (spec §2 — the
        # OperationContext is the source of truth for the parent version),
        # fall back to params.version_id when present (legacy callers).
        version_id = ctx.parent_version_id or params.version_id
        if not version_id:
            raise ValueError(
                "snapshot_version: version is required "
                "(set ctx.parent_version_id or params.version_id)"
            )
        mv = session.get(ModelVersion, version_id)
        if mv is None:
            raise ValueError(
                f"snapshot_version: ModelVersion {version_id!r} not found"
            )

        scope = mv.scope or "ecm"
        version_int = mv.version
        if version_int is None:
            raise ValueError(
                "snapshot_version: ModelVersion has no integer version"
            )

        # Resolve catalog: params-first (the run's dispatched truth), else the
        # catalog the version's files are in (resolve_version_volume_catalog,
        # a session-only read).
        deployment_catalog = (
            params.deployment_catalog
            or resolve_version_volume_catalog(mv, session)
        )
        business_name = params.business_name
        if not business_name:
            biz = session.get(Business, ctx.business_id)
            business_name = biz.name if biz else ""

        # Nested (agent 4.9.8+) first, legacy flat fallback for pre-upgrade
        # rows: archive whichever version dir actually holds files.
        version_dir = ""
        if deployment_catalog and business_name:
            candidates = version_dir_candidates(
                deployment_catalog, business_name, int(version_int), scope
            )
            version_dir = candidates[0]
            for cand in candidates:
                if walk_volume_dir(ws, cand):
                    version_dir = cand
                    break

        # List + read every file in the version dir, zip into memory.
        zip_buf = io.BytesIO()
        files_added = 0
        if version_dir:
            with zipfile.ZipFile(zip_buf, "w", compression=zipfile.ZIP_DEFLATED) as zf:
                for entry_path in walk_volume_dir(ws, version_dir):
                    try:
                        resp = ws.files.download(entry_path)
                        payload = resp.contents.read()
                    except Exception:
                        logger.warning(
                            "snapshot_version: skipping unreadable %s",
                            entry_path,
                        )
                        continue
                    rel = entry_path[len(version_dir):].lstrip("/")
                    zf.writestr(rel or entry_path.rsplit("/", 1)[-1], payload)
                    files_added += 1

        if files_added == 0:
            # Empty source dir is NOT a failure — snapshots are archival.
            # Record the no-op so observe() can return a clean success with
            # zero artifacts and the resume guard short-circuits a re-call.
            _upsert_run_op_dispatch(
                session, ctx,
                rollback_extra={
                    "empty": True,
                    "artifact_ids": [],
                },
            )
            return OperationDispatchHandle(
                databricks_run_id=None,
                vibe_session_id=None,
                extra={
                    "completed": True,
                    "snapshot_path": None,
                    "artifact_ids": [],
                    "version_id": mv.id,
                    "files_added": 0,
                    "empty": True,
                },
            )

        # Compose the archive path. `_snapshots/` lives next to the version
        # folders so a single business's archives accumulate in one place.
        ts = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
        # The validator already cleaned the label — pass through verbatim
        # except for the empty-string edge.
        label_segment = params.label
        suffix = f"_{label_segment}" if label_segment else ""
        archive_name = f"v{version_int}_{scope}_{ts}{suffix}.zip"
        archive_path = (
            f"{metamodel_root_for_business(deployment_catalog, business_name)}"
            f"/_snapshots/{archive_name}"
        )

        zip_buf.seek(0)
        try:
            ws.files.upload(archive_path, zip_buf, overwrite=False)
        except Exception as e:
            return OperationDispatchHandle(
                databricks_run_id=None,
                vibe_session_id=None,
                extra={
                    "completed": True,
                    "error": (
                        f"upload to {archive_path} failed: {e} "
                        f"(write permission denied?)"
                    ),
                },
            )

        artifact = RunArtifact(
            run_id=ctx.run_id,
            model_version_id=mv.id,
            artifact_type="snapshot_zip",
            file_path=archive_path,
        )
        session.add(artifact)
        session.flush()

        _upsert_run_op_dispatch(
            session, ctx,
            rollback_extra={
                "snapshot_path": archive_path,
                "artifact_ids": [artifact.id],
            },
        )

        return OperationDispatchHandle(
            databricks_run_id=None,
            vibe_session_id=None,
            extra={
                "completed": True,
                "snapshot_path": archive_path,
                "artifact_ids": [artifact.id],
                "version_id": mv.id,
                "files_added": files_added,
            },
        )

    # ------------------------------------------------------------------
    # observe — terminal immediately
    # ------------------------------------------------------------------

    def observe(
        self,
        handle: OperationDispatchHandle,
        ctx: OperationContext,
        ws: Any,
        session: Any,
    ) -> OperationObservation:
        """Always terminal — dispatch performed the whole thing.

        Reads the soft-failure / empty-source markers stowed by
        :meth:`dispatch` and translates them into the appropriate
        terminal_result. ``produces_version=False`` ⇒
        ``output_version_id`` is always ``None``.
        """
        extra = handle.extra or {}

        # Hard failure (e.g. upload denied) — surface the error verbatim.
        err = extra.get("error")
        if err:
            return OperationObservation(
                progress_percent=0,
                progress_message="Failed",
                is_terminal=True,
                terminal_result=OperationResult(
                    succeeded=False,
                    output_version_id=None,
                    output_artifacts=[],
                    rollback_state={},
                    error=str(err),
                ),
            )

        # Empty source dir — snapshots are archival, success with zero
        # artifacts is the legal record of "version had no files".
        if extra.get("empty") or (
            not extra.get("snapshot_path") and "files_added" in extra
        ):
            return OperationObservation(
                progress_percent=100,
                progress_message="Nothing to snapshot",
                is_terminal=True,
                terminal_result=OperationResult(
                    succeeded=True,
                    output_version_id=None,
                    output_artifacts=[],
                    rollback_state={"artifact_ids": []},
                    error=None,
                ),
            )

        snapshot_path = extra.get("snapshot_path")
        if not snapshot_path:
            return OperationObservation(
                progress_percent=0,
                progress_message="No snapshot produced",
                is_terminal=True,
                terminal_result=OperationResult(
                    succeeded=False,
                    output_version_id=None,
                    output_artifacts=[],
                    rollback_state={},
                    error="snapshot_version: dispatch produced no archive",
                ),
            )

        artifact_ids = extra.get("artifact_ids", [])
        return OperationObservation(
            progress_percent=100,
            progress_message="Snapshot archived",
            is_terminal=True,
            terminal_result=OperationResult(
                succeeded=True,
                output_version_id=None,  # produces_version=False
                output_artifacts=[
                    {
                        "artifact_type": "snapshot_zip",
                        "file_path": snapshot_path,
                    }
                ],
                rollback_state={
                    "snapshot_path": snapshot_path,
                    "artifact_ids": list(artifact_ids),
                },
                error=None,
            ),
        )

    # ------------------------------------------------------------------
    # rollback — delete artifact rows; leave the version + zip in place
    # ------------------------------------------------------------------

    def rollback(
        self,
        ctx: OperationContext,
        rollback_state: dict,
        ws: Any,
        session: Any,
    ) -> None:
        """Delete the RunArtifact rows produced by this op.

        Per spec §2, snapshots have no version impact: we drop the bookkeeping
        rows so the UI's artifact list returns to its pre-op state. The
        physical zip on the Volume is intentionally left alone — re-running
        the op would just produce a new timestamped name beside it.
        """
        artifact_ids = rollback_state.get("artifact_ids") or []
        for aid in artifact_ids:
            row = session.get(RunArtifact, aid)
            if row is None:
                continue  # idempotent — already gone
            session.delete(row)
        session.flush()


# ---------------------------------------------------------------------------
# helpers
# ---------------------------------------------------------------------------


def _upsert_run_op_dispatch(
    session: Any,
    ctx: OperationContext,
    *,
    rollback_extra: dict,
) -> None:
    """Persist the dispatch outcome on the RunOperation row so the resume
    guard short-circuits a second dispatch with the same operation_id.
    Tests call dispatch directly without the orchestrator; insert a stub
    row when one isn't present.

    Unlike ``vibe_iterate``/``import_from_volume`` (whose resume guards key
    off a dedicated column - ``databricks_run_id`` / ``output_version_id``),
    this synthetic no-job, no-version primitive has no such column, so its
    own ``dispatch()`` resume guard (above) reads ``rollback_state_json``
    itself as the idempotency signal. This write must stay - it is not the
    generic dispatch-extras carry-forward that ``_dispatch_pending`` in
    ``orchestrator/_runner.py`` performs for every primitive, it is the
    resume signal for THIS primitive's own re-entrant ``dispatch()`` calls.
    """
    try:
        run_op = session.get(RunOperation, ctx.operation_id)
    except Exception:
        run_op = None
    import json as _json
    if run_op is None:
        run_op = RunOperation(
            id=ctx.operation_id,
            run_id=ctx.run_id,
            step_index=0,
            operation_name="snapshot_version",
            params_json=_json.dumps(ctx.params or {}),
            status="succeeded",
        )
        session.add(run_op)
    run_op.rollback_state_json = _json.dumps(rollback_extra or {})
    session.flush()


# Singleton registration on import.
register(SnapshotVersion())


__all__ = ["SnapshotVersion", "SnapshotVersionParams"]

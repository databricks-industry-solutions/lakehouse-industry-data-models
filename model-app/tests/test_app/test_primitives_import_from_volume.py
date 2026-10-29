"""Adversarial tests for the ``import_from_volume`` operation primitive.

See ``docs/orchestrator-design.md`` §2 + §10. The primitive refactors the
existing in-process import flow (`POST /businesses/{id}/import/execute`)
into a one-shot Operation: dispatch reads model.json from a Volume,
validates the schema, creates a new ModelVersion, and syncs the Lakebase
rows. Rollback deletes the version + clears Lakebase model data.

Because the operation is non-job (in-process), ``observe()`` MUST return
``is_terminal=True`` immediately without polling.

These tests are independent of the dev implementation; the local
``# STUB-FOR-INTEGRATION`` shim raises so failures on ``main`` are loud.
"""

from __future__ import annotations

import json
from unittest.mock import MagicMock

import pytest
from pydantic import BaseModel, ValidationError
from sqlmodel import Session, select

from ._lifecycle_fixtures import require_files_catalog  # noqa: F401
from vibe_modeling.backend.db_models import (
    Business,
    ModelVersion,
    Run,
)
from vibe_modeling.backend.services.operations import (
    Operation,
    OperationContext,
    OperationDispatchHandle,
    OperationObservation,
    OperationResult,
)
from vibe_modeling.backend.import_model import ImportScopeError, import_scope


class TestScopeFromVolumePath:
    """With nothing in the file, the scope comes from the version folder
    (``core/_paths.version_dir_key``): nested first, flat as a fallback."""

    @staticmethod
    def _scope(path: str) -> str:
        return import_scope({"model": {"domains": []}}, path, None)

    def test_nested_layout_standalone_scope_segment(self):
        assert self._scope("/Volumes/cat/_metamodel/vol_root/business/acme/v2/mvm/model.json") == "mvm"

    def test_nested_layout_ecm(self):
        assert self._scope("/Volumes/cat/_metamodel/vol_root/business/acme/v1/ecm") == "ecm"

    def test_flat_layout_fallback(self):
        assert self._scope("/Volumes/cat/_metamodel/vol_root/business/acme/ecm_v3/model.json") == "ecm"

    def test_nested_takes_precedence_over_flatish_business_segment(self):
        assert self._scope("/Volumes/cat/_metamodel/vol_root/business/ecm_corp/v5/mvm/model.json") == "mvm"

    def test_no_answer_is_refused(self):
        with pytest.raises(ImportScopeError):
            self._scope("/Volumes/cat/whatever/model.json")


# --------------------------------------------------------------------------
# Primitive import — STUB-FOR-INTEGRATION fallback.
# --------------------------------------------------------------------------


try:
    from vibe_modeling.backend.services.operations.import_from_volume import (  # type: ignore
        ImportFromVolume,
        ImportFromVolumeParams,
    )
    PRIMITIVE_AVAILABLE = True
except Exception:  # pragma: no cover — STUB-FOR-INTEGRATION
    PRIMITIVE_AVAILABLE = False

    class ImportFromVolumeParams(BaseModel):  # STUB-FOR-INTEGRATION
        # Real schema lives in the dev impl. The stub is a sentinel so
        # tests that hit the params_model surface can still run.
        pass

    class ImportFromVolume(Operation):  # STUB-FOR-INTEGRATION
        name = "import_from_volume"
        params_model = ImportFromVolumeParams
        is_idempotent = False
        produces_version = True

        def dispatch(self, ctx, ws, session):
            raise NotImplementedError(
                "import_from_volume primitive is not implemented on this branch"
            )

        def observe(self, handle, ctx, ws, session):
            raise NotImplementedError(
                "import_from_volume primitive is not implemented on this branch"
            )

        def rollback(self, ctx, rollback_state, ws, session):
            raise NotImplementedError(
                "import_from_volume primitive is not implemented on this branch"
            )


# --------------------------------------------------------------------------
# Helpers
# --------------------------------------------------------------------------


def _valid_model_json_bytes(
    version_str: str = "v1_ecm",
    *,
    agent_version: str | None = None,
    release_version: str | None = None,
) -> bytes:
    env: dict = {
        "model": {
            "type": "business",
            "name": "test",
            "version": version_str,
            "description": "imported",
            "domains": [
                {
                    "name": "Sales",
                    "products": [
                        {
                            "name": "orders",
                            "attributes": [
                                {"name": "order_id", "type": "BIGINT"},
                            ],
                        }
                    ],
                }
            ],
        }
    }
    # Version provenance keys live at the ENVELOPE top level (Finding B).
    if agent_version is not None:
        env["agent_version"] = agent_version
    if release_version is not None:
        env["release_version"] = release_version
    return json.dumps(env).encode("utf-8")


def _ws_with_download(content: bytes | Exception) -> MagicMock:
    ws = MagicMock()
    if isinstance(content, Exception):
        ws.files.download.side_effect = content
        return ws
    download = MagicMock()
    download.contents.read.return_value = content
    ws.files.download.return_value = download
    return ws


@pytest.fixture
def primitive() -> ImportFromVolume:
    return ImportFromVolume()


@pytest.fixture
def run_row(engine, seed_business) -> str:
    with Session(engine) as s:
        r = Run(
            business_id=seed_business,
            intent="import-from-volume",
            status="pending",
            parameters_json="{}",
        )
        s.add(r)
        s.commit()
        s.refresh(r)
        return r.id


def _ctx(
    *, run_id: str, business_id: str, params: dict, op_id: str = "op-import-1"
) -> OperationContext:
    return OperationContext(
        run_id=run_id,
        operation_id=op_id,
        business_id=business_id,
        parent_version_id=None,
        params=params,
        inherited_params={},
    )


# --------------------------------------------------------------------------
# Class-level contract attributes.
# --------------------------------------------------------------------------


def test_class_attributes(primitive):
    """§2 contract attributes for import_from_volume.

    ``is_idempotent`` is ``False`` because dispatch creates a new
    ModelVersion row (externally-visible non-idempotent effect, per the
    reconciliation rubric and spec §2: "if True, orchestrator may retry
    on transient errors"). Re-dispatch with the same ``(run_id, op_id)``
    is still a no-op via the RunOperation resume guard, but the boolean
    flag governs the orchestrator's automatic-retry policy, not the
    in-process dedupe.
    """
    assert PRIMITIVE_AVAILABLE, (
        "vibe_modeling.backend.services.operations.import_from_volume must "
        "exist and export ImportFromVolume + ImportFromVolumeParams"
    )
    assert primitive.name == "import_from_volume"
    assert primitive.is_idempotent is False
    assert primitive.produces_version is True
    assert issubclass(primitive.params_model, BaseModel)
    assert primitive.__class__.__module__.startswith(
        "vibe_modeling.backend.services.operations"
    )


# --------------------------------------------------------------------------
# 1. Volume path doesn't exist → terminal succeeded=False with file-not-found.
# --------------------------------------------------------------------------


def test_missing_volume_path_returns_terminal_failure(
    engine, primitive, seed_business, run_row
):
    ws = _ws_with_download(Exception("404: Files API: not found"))
    ctx = _ctx(
        run_id=run_row,
        business_id=seed_business,
        params={"volume_path": "/Volumes/cat/sch/vol/missing.json"},
    )
    with Session(engine) as s:
        handle = primitive.dispatch(ctx, ws, s)
        obs = primitive.observe(handle, ctx, ws, s)

    assert obs.is_terminal is True, (
        "non-job primitive must finish in dispatch and report terminal "
        "immediately on observe()"
    )
    assert obs.terminal_result is not None
    assert obs.terminal_result.succeeded is False
    assert obs.terminal_result.output_version_id is None
    assert obs.terminal_result.error
    assert "not found" in obs.terminal_result.error.lower() or \
           "404" in obs.terminal_result.error or \
           "missing" in obs.terminal_result.error.lower()


# --------------------------------------------------------------------------
# 2. Malformed JSON → succeeded=False with parse error.
# --------------------------------------------------------------------------


def test_malformed_json_returns_terminal_failure(
    engine, primitive, seed_business, run_row
):
    ws = _ws_with_download(b"{this is not, valid json::::")
    ctx = _ctx(
        run_id=run_row,
        business_id=seed_business,
        params={"volume_path": "/Volumes/cat/sch/vol/bad.json"},
    )
    with Session(engine) as s:
        handle = primitive.dispatch(ctx, ws, s)
        obs = primitive.observe(handle, ctx, ws, s)

    assert obs.is_terminal is True
    assert obs.terminal_result is not None
    assert obs.terminal_result.succeeded is False
    assert obs.terminal_result.error
    err = obs.terminal_result.error.lower()
    assert any(tok in err for tok in ("json", "parse", "decode", "invalid")), (
        f"error must mention parse/JSON failure: {obs.terminal_result.error!r}"
    )

    # No partial state — no ModelVersion created.
    with Session(engine) as s:
        rows = s.exec(
            select(ModelVersion).where(ModelVersion.business_id == seed_business)
        ).all()
    assert rows == []


# --------------------------------------------------------------------------
# 3. Schema invalid (missing required keys) → succeeded=False with validation
#    error.
# --------------------------------------------------------------------------


def test_schema_missing_required_keys_returns_terminal_failure(
    engine, primitive, seed_business, run_row
):
    bad = json.dumps({"model": {"name": "missing other keys"}}).encode("utf-8")
    ws = _ws_with_download(bad)
    ctx = _ctx(
        run_id=run_row,
        business_id=seed_business,
        params={"volume_path": "/Volumes/cat/sch/vol/incomplete.json"},
    )
    with Session(engine) as s:
        handle = primitive.dispatch(ctx, ws, s)
        obs = primitive.observe(handle, ctx, ws, s)

    assert obs.is_terminal is True
    assert obs.terminal_result is not None
    assert obs.terminal_result.succeeded is False
    err = (obs.terminal_result.error or "").lower()
    assert any(tok in err for tok in ("missing", "required", "schema", "field")), (
        f"error must mention the missing required field(s): "
        f"{obs.terminal_result.error!r}"
    )


# --------------------------------------------------------------------------
# 4. Lakebase sync fails → succeeded=True (model.json existed) but version
#    is rolled back via rollback().
# --------------------------------------------------------------------------


def test_rollback_deletes_version_and_clears_lakebase(
    engine, primitive, seed_business, run_row
):
    # Pre-build the post-import state: a ModelVersion exists. rollback()
    # must delete it.
    with Session(engine) as s:
        mv = ModelVersion(
            business_id=seed_business,
            version=1,
            status="completed",
            scope="ecm",
        )
        s.add(mv)
        s.commit()
        s.refresh(mv)
        mv_id = mv.id

    rollback_state = {"new_version_id": mv_id}
    ctx = _ctx(
        run_id=run_row,
        business_id=seed_business,
        params={"volume_path": "/Volumes/cat/sch/vol/x.json"},
    )
    with Session(engine) as s:
        primitive.rollback(ctx, rollback_state, MagicMock(), s)
        s.commit()

    with Session(engine) as s:
        gone = s.exec(select(ModelVersion).where(ModelVersion.id == mv_id)).first()
    assert gone is None


# --------------------------------------------------------------------------
# 5. Path traversal attempt rejected at params validation.
# --------------------------------------------------------------------------


@pytest.mark.parametrize(
    "evil_path",
    [
        "/Volumes/cat/sch/vol/../../etc/passwd",
        "/Volumes/cat/sch/vol/../../../root/.ssh/id_rsa",
        "/Volumes/../etc/shadow",
        "/etc/passwd",  # not under /Volumes/ at all
        "../../etc/passwd",
        "/Volumes/cat/sch/vol/foo/../../bar/model.json",
    ],
)
def test_params_model_rejects_path_traversal(evil_path):
    """Per the C-10 volume_path validator pattern: any path containing '..'
    segments OR not anchored at /Volumes/ must be rejected at the schema
    layer, not at runtime.
    """
    with pytest.raises(ValidationError):
        ImportFromVolumeParams(volume_path=evil_path)


def test_params_model_accepts_clean_volume_path():
    p = ImportFromVolumeParams(
        volume_path="/Volumes/cat/sch/vol/folder/model.json"
    )
    assert p.volume_path.startswith("/Volumes/")


# --------------------------------------------------------------------------
# 6. Idempotent re-import: if a version with the same name+content already
#    exists, return existing version's id; do not duplicate.
# --------------------------------------------------------------------------


def test_idempotent_reimport_returns_existing_version_id(
    engine, primitive, seed_business, run_row
):
    body = _valid_model_json_bytes(version_str="v1_ecm")
    ws = _ws_with_download(body)

    ctx = _ctx(
        run_id=run_row,
        business_id=seed_business,
        params={"volume_path": "/Volumes/cat/sch/vol/dup.json"},
    )
    with Session(engine) as s:
        h1 = primitive.dispatch(ctx, ws, s)
        obs1 = primitive.observe(h1, ctx, ws, s)
        s.commit()
        first_vid = obs1.terminal_result.output_version_id if obs1.terminal_result else None

    # Re-dispatch with the same op_id — must reuse and not create a 2nd MV.
    ws2 = _ws_with_download(body)
    with Session(engine) as s:
        h2 = primitive.dispatch(ctx, ws2, s)
        obs2 = primitive.observe(h2, ctx, ws2, s)
        s.commit()
        second_vid = obs2.terminal_result.output_version_id if obs2.terminal_result else None

    with Session(engine) as s:
        rows = s.exec(
            select(ModelVersion).where(ModelVersion.business_id == seed_business)
        ).all()

    assert first_vid is not None
    assert second_vid == first_vid, (
        f"second import with same volume_path/op must return the same "
        f"version id; got {first_vid!r} and {second_vid!r}"
    )
    assert len(rows) == 1, (
        f"idempotent re-import must not create a duplicate ModelVersion; "
        f"found {len(rows)} rows"
    )


def test_dispatch_stamps_version_provenance_from_envelope(
    engine, primitive, seed_business, run_row
):
    """The import-from-volume primitive stamps agent_version /
    release_version onto the ModelVersion from the full model.json envelope
    (import_from_volume.py) — a regression that drops the stamp fails here."""
    body = _valid_model_json_bytes(
        version_str="v1_ecm", agent_version="4.9.8", release_version="0.8.0"
    )
    ws = _ws_with_download(body)
    ctx = _ctx(
        run_id=run_row,
        business_id=seed_business,
        params={"volume_path": "/Volumes/cat/sch/vol/prov.json"},
    )
    with Session(engine) as s:
        h = primitive.dispatch(ctx, ws, s)
        obs = primitive.observe(h, ctx, ws, s)
        s.commit()
        vid = obs.terminal_result.output_version_id if obs.terminal_result else None

    assert vid is not None
    with Session(engine) as s:
        mv = s.get(ModelVersion, vid)
        assert mv is not None
        assert mv.agent_version == "4.9.8"
        assert mv.release_version == "0.8.0"


# --------------------------------------------------------------------------
# 7. observe() returns is_terminal=True without polling for non-job ops.
# --------------------------------------------------------------------------


def test_observe_is_terminal_without_polling(
    engine, primitive, seed_business, run_row
):
    body = _valid_model_json_bytes()
    ws = _ws_with_download(body)
    ctx = _ctx(
        run_id=run_row,
        business_id=seed_business,
        params={"volume_path": "/Volumes/cat/sch/vol/x.json"},
    )
    with Session(engine) as s:
        h = primitive.dispatch(ctx, ws, s)
        obs = primitive.observe(h, ctx, ws, s)

    assert obs.is_terminal is True
    assert obs.terminal_result is not None
    # No Jobs API polling for this primitive.
    assert not ws.jobs.get_run.called, (
        "import_from_volume must not poll the Jobs API — it finishes in dispatch"
    )


# --------------------------------------------------------------------------
# 8. Successful import creates exactly one ModelVersion and reports it.
# --------------------------------------------------------------------------


def test_successful_import_creates_one_model_version(
    engine, primitive, seed_business, run_row, require_files_catalog
):
    body = _valid_model_json_bytes()
    ws = _ws_with_download(body)
    ctx = _ctx(
        run_id=run_row,
        business_id=seed_business,
        params={"volume_path": "/Volumes/cat/sch/vol/ok.json"},
    )
    with Session(engine) as s, require_files_catalog:
        h = primitive.dispatch(ctx, ws, s)
        obs = primitive.observe(h, ctx, ws, s)
        s.commit()

    assert require_files_catalog.checked == 1
    assert obs.terminal_result and obs.terminal_result.succeeded is True
    assert obs.terminal_result.output_version_id

    with Session(engine) as s:
        rows = s.exec(
            select(ModelVersion).where(ModelVersion.business_id == seed_business)
        ).all()
    assert len(rows) == 1
    assert rows[0].id == obs.terminal_result.output_version_id


# --------------------------------------------------------------------------
# 9. Rollback is idempotent — replay against an already-rolled-back state
#    must not raise.
# --------------------------------------------------------------------------


def test_rollback_idempotent(
    engine, primitive, seed_business, run_row
):
    rollback_state = {"new_version_id": "definitely-not-real"}
    ctx = _ctx(
        run_id=run_row,
        business_id=seed_business,
        params={"volume_path": "/Volumes/cat/sch/vol/x.json"},
    )
    with Session(engine) as s:
        primitive.rollback(ctx, rollback_state, MagicMock(), s)
        primitive.rollback(ctx, rollback_state, MagicMock(), s)


# --------------------------------------------------------------------------
# 10. Empty volume_path is rejected.
# --------------------------------------------------------------------------


def test_params_model_rejects_empty_volume_path():
    with pytest.raises(ValidationError):
        ImportFromVolumeParams(volume_path="")


# --------------------------------------------------------------------------
# 11. Wrong root (not /Volumes/) is rejected.
# --------------------------------------------------------------------------


def test_params_model_rejects_non_volumes_root():
    for bad in ("/tmp/model.json", "s3://bucket/model.json", "model.json"):
        with pytest.raises(ValidationError):
            ImportFromVolumeParams(volume_path=bad)


# --------------------------------------------------------------------------
# 12. model.json with type != "business" rejected at observe().
# --------------------------------------------------------------------------


def test_wrong_type_field_returns_terminal_failure(
    engine, primitive, seed_business, run_row
):
    bad = json.dumps({
        "model": {
            "type": "ontology",  # not "business"
            "name": "x",
            "version": "v1_ecm",
            "description": "",
            "domains": [],
        }
    }).encode("utf-8")
    ws = _ws_with_download(bad)
    ctx = _ctx(
        run_id=run_row,
        business_id=seed_business,
        params={"volume_path": "/Volumes/cat/sch/vol/wrongtype.json"},
    )
    with Session(engine) as s:
        h = primitive.dispatch(ctx, ws, s)
        obs = primitive.observe(h, ctx, ws, s)
    assert obs.is_terminal is True
    assert obs.terminal_result is not None
    assert obs.terminal_result.succeeded is False


# --------------------------------------------------------------------------
# TestRollbackAdversarial — rollback edge cases per design doc §2 + §10.
#
# import_from_volume rollback contract (§10): "Lakebase sync fails →
# rollback deletes version + clears lakebase model data".
#
# Adversarial scenarios:
#   1. Rollback replay (idempotency invariant from §2).
#   2. Dependent ModelVersion already deleted between dispatch and rollback.
#   3. Rollback's underlying call raises → propagated to orchestrator.
#   4. Path traversal regression — rollback can only delete the version
#      it produced (it must not be tricked into deleting siblings via
#      a malicious rollback_state payload).
# --------------------------------------------------------------------------


class TestRollbackAdversarial:
    """Adversarial rollback cases for import_from_volume.

    Per ``services/orchestrator/_runner.py::_rollback_one``, rollback
    exceptions propagate to the orchestrator's caller-aware halt. So
    "rollback raises" is the contract, not a bug.
    """

    def test_rollback_idempotent_under_replay(
        self, engine, primitive, seed_business, run_row
    ):
        """§2 invariant: replaying ``rollback`` against an already-rolled-back
        state MUST be a no-op (not raise)."""
        with Session(engine) as s:
            mv = ModelVersion(
                business_id=seed_business,
                version=1,
                status="completed",
                scope="ecm",
            )
            s.add(mv)
            s.commit()
            s.refresh(mv)
            mv_id = mv.id

        rollback_state = {"version_id": mv_id, "new_version_id": mv_id}
        ctx = _ctx(
            run_id=run_row,
            business_id=seed_business,
            params={"volume_path": "/Volumes/cat/sch/vol/x.json"},
        )
        with Session(engine) as s:
            primitive.rollback(ctx, rollback_state, MagicMock(), s)
            s.commit()
            # Replay — version is already gone, must succeed.
            primitive.rollback(ctx, rollback_state, MagicMock(), s)
            s.commit()

    def test_rollback_when_dependent_version_already_deleted(
        self, engine, primitive, seed_business, run_row
    ):
        """The ModelVersion the rollback wants to delete may be gone before
        the rollback runs (raced cleanup). Must succeed without raising."""
        rollback_state = {
            "version_id": "ghost-version-never-existed",
            "new_version_id": "ghost-version-never-existed",
        }
        ctx = _ctx(
            run_id=run_row,
            business_id=seed_business,
            params={"volume_path": "/Volumes/cat/sch/vol/x.json"},
        )
        with Session(engine) as s:
            primitive.rollback(ctx, rollback_state, MagicMock(), s)
            s.commit()

    def test_rollback_propagates_underlying_exception(
        self, engine, primitive, seed_business, run_row
    ):
        """When the rollback's underlying ``session.delete`` (or equivalent)
        raises, the exception must propagate so the orchestrator's
        ``_rollback_one`` can catch it. Swallowing errors silently would
        leave the orchestrator thinking the chain succeeded when it didn't.
        """
        with Session(engine) as s:
            mv = ModelVersion(
                business_id=seed_business,
                version=1,
                status="completed",
                scope="ecm",
            )
            s.add(mv)
            s.commit()
            s.refresh(mv)
            mv_id = mv.id

        rollback_state = {"version_id": mv_id, "new_version_id": mv_id}
        ctx = _ctx(
            run_id=run_row,
            business_id=seed_business,
            params={"volume_path": "/Volumes/cat/sch/vol/x.json"},
        )

        class _BoomSession:
            def __init__(self, real):
                self._real = real

            def __getattr__(self, name):
                return getattr(self._real, name)

            def get(self, *a, **kw):
                return self._real.get(*a, **kw)

            def delete(self, *a, **kw):
                raise RuntimeError("simulated lakebase delete failure")

            def flush(self, *a, **kw):
                return self._real.flush(*a, **kw)

            def add(self, *a, **kw):
                return self._real.add(*a, **kw)

        with Session(engine) as s:
            boom = _BoomSession(s)
            with pytest.raises(RuntimeError):
                primitive.rollback(ctx, rollback_state, MagicMock(), boom)

    def test_rollback_path_traversal_regression(
        self, engine, primitive, seed_business, run_row
    ):
        """Mirror of dispatch-path test #C-10 (`test_params_model_rejects_path_traversal`)
        for the rollback scope.

        rollback() takes a ``version_id`` (a primary key in Lakebase) — not
        a file path. So the only way an attacker could "trick" rollback
        into deleting outside its scope is if it interpreted the
        rollback_state in a way that touched the Volume / file system.
        Verify: a rollback_state with traversal-shaped strings only
        affects the keyed ModelVersion row and never touches the
        ``ws.files`` API.
        """
        # Seed a "victim" ModelVersion that an attacker would want to
        # leave alone — the real version belongs to a different op.
        with Session(engine) as s:
            victim = ModelVersion(
                business_id=seed_business,
                version=99,
                status="completed",
                scope="ecm",
            )
            s.add(victim)
            s.commit()
            s.refresh(victim)
            victim_id = victim.id

        ws = MagicMock()
        # Rollback_state with a path-traversal-shaped string in places the
        # impl might read it. The ``version_id`` is intentionally a string
        # that does NOT match any DB row — rollback must just no-op, not
        # try to interpret the string as a path.
        evil_rollback_state = {
            "version_id": "../../etc/passwd",
            "new_version_id": "/Volumes/foo/../bar",
            "volume_path": "/Volumes/cat/sch/vol/../../../../etc/passwd",
        }
        ctx = _ctx(
            run_id=run_row,
            business_id=seed_business,
            params={"volume_path": "/Volumes/cat/sch/vol/x.json"},
        )
        with Session(engine) as s:
            # Must not raise.
            primitive.rollback(ctx, evil_rollback_state, ws, s)
            s.commit()

        # Victim row untouched.
        with Session(engine) as s:
            still_there = s.exec(
                select(ModelVersion).where(ModelVersion.id == victim_id)
            ).first()
        assert still_there is not None, (
            "rollback with a malicious version_id must not delete unrelated "
            "ModelVersion rows"
        )
        # Rollback never touches the ws.files API — version_id is a DB key,
        # not a file path. Any "delete file" call would be a smell.
        assert not ws.files.delete.called, (
            "rollback must not interpret version_id as a file path; "
            "ws.files.delete was called"
        )

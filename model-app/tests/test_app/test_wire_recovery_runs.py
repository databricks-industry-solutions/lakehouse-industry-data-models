"""Adversarial tests for the recovery DAG factories and the orchestrator.

Covers the ``import-from-volume`` factory and primitive, the orchestrator's
failure semantics for the uninstall-then-install DAG that an install into an
occupied catalog uses, and the delete-version route.

See ``docs/orchestrator-design.md`` §3 (DAG factories), §6 (failure
semantics), §8 (API contract changes).

Coverage map:

uninstall-then-install DAG (install over an occupant)
    - uninstall fails -> install does NOT dispatch; rollback runs
    - install fails -> uninstall already succeeded -> rollback replays

import-from-volume intent
    - 1-op DAG persists with the right ``volume_path``
    - Path-traversal attempt -> 400 with blocker
    - Volume path doesn't exist -> terminal failure, succeeded=False,
      error mentions file-not-found
    - Re-import same path -> idempotent (returns existing version's id)
    - Malformed model.json -> terminal failure with parse error

delete-version route
    - Repeating the delete does not double-execute
    - A request still carrying ``reinstall_previous`` starts no run
"""

from __future__ import annotations

import json
import os
import sys
from typing import Any, Optional
from unittest.mock import MagicMock

# Ensure the in-tree source wins over any installed wheel — same pattern
# as ``tests/test_app/conftest.py``. Belt and braces in case this file
# is collected without the conftest path injection.
sys.path.insert(
    0,
    os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"),
)

import pytest
from sqlmodel import Session, select

from vibe_modeling.backend.db_models import (
    Business,
    ModelVersion,
    Run,
    RunOperation,
)
from vibe_modeling.backend.services.orchestrator.dag import Dag, OperationStep


# ---------------------------------------------------------------------------
# STUB-FOR-INTEGRATION: import the Phase 4 DAG factories.
# ---------------------------------------------------------------------------


WIRER_AVAILABLE = False
WIRER_IMPORT_ERROR: Optional[str] = None

try:
    from vibe_modeling.backend.services.orchestrator.factories import (  # type: ignore[import-not-found]
        dag_for_import_from_volume,
    )
    WIRER_AVAILABLE = True
except ImportError as _e:  # pragma: no cover — STUB-FOR-INTEGRATION
    WIRER_IMPORT_ERROR = str(_e)

    def dag_for_import_from_volume(*args: Any, **kwargs: Any) -> Dag:  # STUB-FOR-INTEGRATION
        raise NotImplementedError(
            "dag_for_import_from_volume is not implemented on this branch — "
            "merge feat/wire-recovery-runs (Phase 4)."
        )


@pytest.fixture(autouse=True)
def _require_wirer():
    """Tests MUST fail on a branch where the wirers don't exist with a
    clear single-line reason — not skip."""
    if not WIRER_AVAILABLE:
        raise ImportError(
            "wire-recovery-runs DAG factories are not yet importable from "
            "vibe_modeling.backend.services.orchestrator.factories — "
            "STUB-FOR-INTEGRATION. Last import error: "
            f"{WIRER_IMPORT_ERROR}"
        )


@pytest.fixture(autouse=True)
def _ensure_primitive_registry():
    """Sibling test files (``test_primitives_*``, ``test_operation_protocol``)
    use ``_registry.reset_for_tests()`` in their teardown to keep their
    own assertions hermetic. That leaves the process-global primitive
    registry EMPTY for any test that runs afterwards in the same suite —
    so route-level assertions that go through ``validate_dag`` (e.g.
    "uninstall" / "install" name resolution) flake on test order.

    Repopulate the production registry once per test from this module so
    tests pass deterministically regardless of where pytest places this
    file in the collection order."""
    from vibe_modeling.backend.services.operations import _registry as _reg
    from vibe_modeling.backend.services.operations import (
        EnlargeToEcm,
        GenerateEcm,
        GenerateSamples,
        Install,
        ShrinkToMvm,
        Uninstall,
    )
    from vibe_modeling.backend.services.operations.import_from_volume import (
        ImportFromVolume,
    )
    from vibe_modeling.backend.services.operations.snapshot_version import (
        SnapshotVersion,
    )
    from vibe_modeling.backend.services.operations.vibe_iterate import (
        VibeIterate,
    )

    for cls in (
        GenerateEcm,
        ShrinkToMvm,
        EnlargeToEcm,
        Install,
        Uninstall,
        GenerateSamples,
        ImportFromVolume,
        SnapshotVersion,
        VibeIterate,
    ):
        try:
            _reg.register(cls())
        except ValueError:
            # Already registered — fine.
            pass
    yield


# ---------------------------------------------------------------------------
# Helpers / fixtures local to this module
# ---------------------------------------------------------------------------


def _seed_business_with_two_versions(
    engine, *, deployed_version: int = 2
) -> tuple[str, dict[int, str]]:
    """Seed a Business + two ModelVersions where the higher one is
    ``deployment_status="deployed"``. Returns
    ``(business_id, {version_int: version_id})``."""
    with Session(engine) as s:
        b = Business(
            name="recover_corp",
            description="recovery target",
            industry_alignment="Retail",
        )
        s.add(b)
        s.flush()
        biz_id = b.id

        v_ids: dict[int, str] = {}
        for n in (1, 2):
            mv = ModelVersion(
                business_id=biz_id,
                version=n,
                status="completed",
                scope="ecm",
                uc_catalog="recover_cat",
                deployment_status="deployed" if n == deployed_version else "uninstalled",
            )
            s.add(mv)
            s.flush()
            v_ids[n] = mv.id
        s.commit()
    return biz_id, v_ids


def _seed_business_single_version(engine) -> tuple[str, str]:
    """Seed a Business with a single (deployed) ModelVersion."""
    with Session(engine) as s:
        b = Business(name="single", description="t", industry_alignment="Retail")
        s.add(b)
        s.flush()
        mv = ModelVersion(
            business_id=b.id,
            version=1,
            status="completed",
            scope="ecm",
            uc_catalog="cat",
            deployment_status="deployed",
        )
        s.add(mv)
        s.commit()
        return b.id, mv.id


def _seed_business_no_install(engine) -> str:
    """Seed a Business with no deployed versions (only draft / uninstalled)."""
    with Session(engine) as s:
        b = Business(name="noinst", description="t", industry_alignment="Retail")
        s.add(b)
        s.flush()
        mv = ModelVersion(
            business_id=b.id,
            version=1,
            status="completed",
            scope="ecm",
            uc_catalog="cat",
            deployment_status="uninstalled",
        )
        s.add(mv)
        s.commit()
        return b.id


def _make_run(engine, business_id: str, *, intent: str = "") -> str:
    with Session(engine) as s:
        r = Run(
            business_id=business_id,
            intent=intent,
            status="pending",
            parameters_json="{}",
        )
        s.add(r)
        s.commit()
        s.refresh(r)
        return r.id


class _ImportReq:
    """Stand-in for the Phase 4 ``RunRequest`` shape for import-from-volume.

    Mirrors ``ImportFromVolumeParams`` (the primitive's params_model)
    plus an ``intent`` discriminator."""

    def __init__(
        self,
        *,
        business_id: str,
        volume_path: str,
        intent: str = "import-from-volume",
    ) -> None:
        self.intent = intent
        self.business_id = business_id
        self.volume_path = volume_path
        self.parent_version_id = None
        self.form_overrides: dict = {}


# ---------------------------------------------------------------------------
# uninstall-then-install DAG — orchestrator-driven failure semantics
# ---------------------------------------------------------------------------


def _install_over_occupant_dag(engine, biz_id: str, v_ids: dict[int, str]) -> Dag:
    """The DAG of installing v1 into the catalog v2 occupies."""
    from types import SimpleNamespace

    from vibe_modeling.backend.services.orchestrator.dag_factories import dag_for_install

    req = SimpleNamespace(
        catalog=None, deployment_catalog=None, cataloging_style="One Catalog",
        scope=None, schema_prefix=None, version_int=None, naming_convention=None,
        primary_key_suffix=None, table_id_type=None, schema_suffix=None, tag_prefix=None,
    )
    with Session(engine) as s:
        biz = s.get(Business, biz_id)
        ctx = SimpleNamespace(
            parent_mv=s.get(ModelVersion, v_ids[1]),
            occupant=s.get(ModelVersion, v_ids[2]),
            occupant_install_widgets=None,
        )
        return dag_for_install(req, biz, ctx, SimpleNamespace(deployment_catalog="meta_cat"))


class TestUninstallThenInstallFailures:
    """Failure-mode tests that go through the full orchestrator
    (``orch.start`` → ``advance``) so we observe the persisted
    ``RunOperation`` lifecycle, not just the DAG shape.

    Each test patches the registry with a small fake operation pair so
    the tests don't dispatch real Databricks jobs."""

    def _make_orch_with_fakes(self, *, uninstall_succeeds: bool, install_succeeds: bool):
        """Build an Orchestrator with a fake registry where uninstall /
        install behaviours are configurable.

        Returns ``(orchestrator, fakes)`` so tests can assert on call
        counts.
        """
        from vibe_modeling.backend.services.operations._protocol import (
            Operation,
            OperationContext,
            OperationDispatchHandle,
            OperationObservation,
            OperationResult,
        )
        from vibe_modeling.backend.services.orchestrator import Orchestrator
        from pydantic import BaseModel

        class _AnyParams(BaseModel):
            model_config = {"extra": "allow"}

        class _Fake(Operation):
            params_model = _AnyParams
            is_idempotent = False
            produces_version = False
            _next_dbx_id = 50_000

            def __init__(self, *, name: str, succeeds: bool):
                self.name = name
                self._succeeds = succeeds
                self.dispatch_calls = 0
                self.rollback_calls = 0

            def dispatch(self, ctx, ws, session):
                self.dispatch_calls += 1
                _Fake._next_dbx_id += 1
                return OperationDispatchHandle(
                    databricks_run_id=_Fake._next_dbx_id,
                    vibe_session_id=f"sess-{_Fake._next_dbx_id}",
                    extra={},
                )

            def observe(self, handle, ctx, ws, session):
                if self._succeeds:
                    return OperationObservation(
                        progress_percent=100,
                        progress_message="ok",
                        is_terminal=True,
                        terminal_result=OperationResult(
                            succeeded=True,
                            output_version_id=None,
                            output_artifacts=[],
                            rollback_state={
                                "deployment_catalog": "recover_cat",
                                "model_version": 1,
                                "business_name": "recover_corp",
                                "schema_prefix": "",
                                "scope": "ecm",
                                "cataloging_style": "One Catalog",
                            },
                            error=None,
                        ),
                    )
                return OperationObservation(
                    progress_percent=100,
                    progress_message="boom",
                    is_terminal=True,
                    terminal_result=OperationResult(
                        succeeded=False,
                        output_version_id=None,
                        output_artifacts=[],
                        rollback_state={},
                        error=f"{self.name} blew up",
                    ),
                )

            def rollback(self, ctx, rollback_state, ws, session):
                self.rollback_calls += 1

        uninstall = _Fake(name="uninstall", succeeds=uninstall_succeeds)
        install = _Fake(name="install", succeeds=install_succeeds)
        registry = {"uninstall": uninstall, "install": install}

        def _get(name: str):
            return registry[name]

        orch = Orchestrator(MagicMock(), session_factory=None, registry_get=_get)
        return orch, uninstall, install

    def test_uninstall_fails_install_does_not_dispatch(self, engine):
        """3. Uninstall reports terminal-failure → install must NOT
        dispatch (its row stays ``pending`` → ``rolled_back`` or stays
        ``pending`` post-rollback, but never ``running``). Run ends
        in ``failed``."""
        biz_id, v_ids = _seed_business_with_two_versions(engine)
        orch, uninstall, install = self._make_orch_with_fakes(
            uninstall_succeeds=False, install_succeeds=True
        )
        dag = _install_over_occupant_dag(engine, biz_id, v_ids)

        run_id = _make_run(engine, biz_id, intent="install")

        with Session(engine) as s:
            run = s.get(Run, run_id)
            orch.start(run, dag, s)
            s.commit()

        # First advance observes the uninstall failure.
        with Session(engine) as s:
            run = s.get(Run, run_id)
            orch.advance(run, s)
            s.commit()

        # Install must never have been dispatched.
        assert install.dispatch_calls == 0, (
            "install must not dispatch when uninstall reports terminal-failure"
        )
        with Session(engine) as s:
            rows = list(
                s.exec(
                    select(RunOperation)
                    .where(RunOperation.run_id == run_id)
                    .order_by(RunOperation.step_index)
                ).all()
            )
            assert rows[0].operation_name == "uninstall"
            assert rows[0].status == "failed"
            assert rows[1].operation_name == "install"
            # Install was never started; it stays at pending (or gets
            # promoted to skipped if the orchestrator chose to mark
            # remaining ops as skipped on chain-halt; either is valid
            # provided `running`/`succeeded` is not the result).
            assert rows[1].status in ("pending", "skipped"), (
                f"install must not have been dispatched after uninstall "
                f"failure; got status={rows[1].status!r}"
            )
            run = s.get(Run, run_id)
            assert run.status == "failed", run.status

    def test_install_fails_after_uninstall_succeeds_rollback_reinstalls_original(
        self, engine
    ):
        """4. Uninstall succeeded; install reports terminal-failure.
        The orchestrator MUST replay rollback() on the prior succeeded
        ``uninstall`` row in reverse order. ``Uninstall.rollback`` is
        defined as a no-op (uninstall IS the rollback per spec §2 +
        §10 footer); the orchestrator's contract is therefore "call
        rollback on the prior succeeded ops, expect no exceptions" —
        and the operator must manually re-install the original
        version per the spec.

        We verify two observable contract points:

        (a) ``Uninstall.rollback`` is invoked on the failure path
            (the orchestrator does NOT skip rollback for ops with
             trivial rollback semantics — it's the op's responsibility
             to no-op safely),
        (b) The Run terminates in ``failed`` (not ``rolled_back_failed``).
        """
        biz_id, v_ids = _seed_business_with_two_versions(engine)
        orch, uninstall, install = self._make_orch_with_fakes(
            uninstall_succeeds=True, install_succeeds=False
        )
        dag = _install_over_occupant_dag(engine, biz_id, v_ids)

        run_id = _make_run(engine, biz_id, intent="install")

        with Session(engine) as s:
            run = s.get(Run, run_id)
            orch.start(run, dag, s)
            s.commit()

        # Drive the walker until terminal: uninstall observes success →
        # install dispatches → install observes failure → rollback runs.
        for _ in range(5):
            with Session(engine) as s:
                run = s.get(Run, run_id)
                outcome = orch.advance(run, s)
                s.commit()
                if run.status in ("failed", "rolled_back_failed", "completed"):
                    break

        # uninstall.rollback was called as part of the reverse walk.
        assert uninstall.rollback_calls >= 1, (
            "rollback chain must invoke Uninstall.rollback on the prior "
            "succeeded uninstall step (its own no-op semantics are an "
            "implementation detail of the primitive, not the orchestrator)"
        )
        with Session(engine) as s:
            run = s.get(Run, run_id)
            assert run.status == "failed", (
                f"all rollbacks succeeded → Run must be 'failed' (not "
                f"'rolled_back_failed'); got {run.status!r}"
            )
            rows = list(
                s.exec(
                    select(RunOperation)
                    .where(RunOperation.run_id == run_id)
                    .order_by(RunOperation.step_index)
                ).all()
            )
            assert rows[0].status == "rolled_back"
            assert rows[1].status == "failed"


# ---------------------------------------------------------------------------
# delete-version route
# ---------------------------------------------------------------------------


class TestDeleteVersionRoute:
    """End-to-end through the FastAPI delete-version route.

    The route is operation_id ``deleteVersion`` (path:
    ``DELETE /businesses/{business_id}/versions/{version_id}``); it
    deletes the target version's rows without dispatching an
    orchestrator DAG. These tests assert that invariant.
    """

    def test_repeated_delete_does_not_duplicate(
        self, engine, client_with_agent
    ):
        """Issuing the same delete request twice must not double-
        execute. The first call returns 200 and deletes the row; the second call returns 404 because
        the row is gone. Either way no orchestrator dispatch happens
        and no active Runs leak."""
        # An installed version cannot be deleted: v2 is the uninstalled head.
        biz_id, v_ids = _seed_business_with_two_versions(engine, deployed_version=0)
        current_id = v_ids[2]

        r1 = client_with_agent.delete(
            f"/api/businesses/{biz_id}/versions/{current_id}"
        )
        assert r1.status_code in (200, 201), (
            f"first delete should succeed; got {r1.status_code}: {r1.text}"
        )

        r2 = client_with_agent.delete(
            f"/api/businesses/{biz_id}/versions/{current_id}"
        )
        # Acceptable: 404 (default delete path — the row is gone after
        # r1, so r2 can't find it), 400 (version is no longer the
        # latest in its scope), 409 (per-business active-run lock), or
        # an idempotent 200.
        assert r2.status_code in (200, 201, 400, 404, 409), (
            f"second delete must not double-execute; got "
            f"{r2.status_code}: {r2.text}"
        )

        with Session(engine) as s:
            runs = list(
                s.exec(select(Run).where(Run.business_id == biz_id)).all()
            )
            active = [
                r for r in runs if r.status in ("pending", "running", "stale")
            ]
            assert len(active) <= 1, (
                f"two identical DELETEs left {len(active)} "
                f"active Runs (must be at most one): {active!r}"
            )

    def test_unknown_version_id_is_rejected_without_a_run(
        self, engine, client_with_agent
    ):
        """A version_id that does not exist on the business is rejected
        before any orchestrator state is mutated."""
        biz_id, _v_ids = _seed_business_with_two_versions(engine)

        # The route gates with 404 before any DAG construction.
        r = client_with_agent.delete(
            f"/api/businesses/{biz_id}/versions/does-not-exist"
        )
        assert r.status_code in (404, 422), (
            f"non-existent version_id must be rejected before any "
            f"orchestrator state is mutated; got {r.status_code}: {r.text}"
        )

        # And no Run row was created.
        with Session(engine) as s:
            runs = list(
                s.exec(select(Run).where(Run.business_id == biz_id)).all()
            )
            assert runs == [], (
                f"a rejected delete must not persist a Run; got {runs!r}"
            )


# ---------------------------------------------------------------------------
# import-from-volume intent — DAG-level tests
# ---------------------------------------------------------------------------


class TestImportFromVolumeDagFactory:
    """The import-from-volume factory yields a single-step DAG —
    one ``import_from_volume`` op carrying the ``volume_path``.
    The primitive is synthetic (no Databricks job)."""

    def test_1_op_dag_persists_with_right_volume_path(self, engine):
        """8. Single OperationStep, name=import_from_volume, params
        carry the user-supplied volume_path verbatim."""
        biz_id, _ = _seed_business_with_two_versions(engine)
        path = "/Volumes/cat/_metamodel/vol_root/business/test/v3_mvm/model.json"
        req = _ImportReq(business_id=biz_id, volume_path=path)

        with Session(engine) as s:
            biz = s.get(Business, biz_id)
            dag = dag_for_import_from_volume(req, biz, s)

        assert isinstance(dag, Dag)
        assert dag.intent == "import-from-volume"
        assert len(dag.steps) == 1, (
            f"import-from-volume DAG must be a single op; got {len(dag.steps)} "
            f"steps: {[s.name for s in dag.steps]}"
        )
        step = dag.steps[0]
        assert step.name == "import_from_volume"
        assert step.params.get("volume_path") == path, (
            f"import step must carry volume_path verbatim; got "
            f"{step.params.get('volume_path')!r}"
        )

    def test_path_traversal_attempt_returns_400_with_blocker(self, engine):
        """9. ``..`` segments in the volume_path are a path-traversal
        attack; the factory must reject with 400 (blocker). The same
        rule lives on ``ImportFromVolumeParams._validate_volume_path``
        but the factory MUST surface it as a routing-level 400 (not let
        it fall through to a Pydantic 422 mid-orchestrator-start)."""
        from fastapi import HTTPException

        biz_id, _ = _seed_business_with_two_versions(engine)
        bad_path = "/Volumes/cat/_metamodel/vol_root/../../../../etc/passwd"
        req = _ImportReq(business_id=biz_id, volume_path=bad_path)

        with Session(engine) as s:
            biz = s.get(Business, biz_id)
            with pytest.raises(HTTPException) as excinfo:
                dag_for_import_from_volume(req, biz, s)

        # 400 (blocker → spec §2.4 behaviour for hard-submit) or 422
        # (Pydantic ValidationError surfacing through). We accept both —
        # what matters is the explicit "blocker" / traversal rejection.
        assert excinfo.value.status_code in (400, 422)
        detail = (str(excinfo.value.detail) or "").lower()
        assert any(
            tok in detail for tok in ("traversal", "..", "blocker", "invalid", "path")
        ), (
            f"path-traversal rejection must mention the unsafe path: "
            f"{excinfo.value.detail!r}"
        )

    def test_factory_dag_passes_cross_step_validation(self, engine):
        """The DAG produced for import-from-volume passes
        ``Dag.validate_cross_step``."""
        biz_id, _ = _seed_business_with_two_versions(engine)
        path = "/Volumes/c/_metamodel/vol_root/b/test/v1_ecm/model.json"
        req = _ImportReq(business_id=biz_id, volume_path=path)

        with Session(engine) as s:
            biz = s.get(Business, biz_id)
            dag = dag_for_import_from_volume(req, biz, s)

        issues = dag.validate_cross_step()
        blockers = [i for i in issues if i.severity == "blocker"]
        assert blockers == [], (
            f"import-from-volume DAG produced cross-step blockers: "
            f"{blockers}"
        )


# ---------------------------------------------------------------------------
# import-from-volume intent — orchestrator + primitive integration
# ---------------------------------------------------------------------------


class TestImportFromVolumeOrchestration:
    """End-to-end with the real ``ImportFromVolume`` primitive (it's
    synthetic — no Databricks jobs, so we can drive it with a mock
    workspace). The orchestrator calls ``dispatch`` then ``observe``;
    the primitive does all the work in dispatch."""

    def _orch_with_real_registry(self, ws):
        """An orchestrator that resolves names against the production
        registry — so ``import_from_volume`` lookups hit the real
        ``ImportFromVolume`` primitive."""
        from vibe_modeling.backend.services import operations as _ops_pkg
        from vibe_modeling.backend.services.orchestrator import Orchestrator

        return Orchestrator(ws, session_factory=None, registry_get=_ops_pkg.get)

    def _ws_with_download(self, content):
        ws = MagicMock()
        if isinstance(content, BaseException):
            ws.files.download.side_effect = content
            return ws
        download = MagicMock()
        download.contents.read.return_value = content
        ws.files.download.return_value = download
        return ws

    def _valid_model_json_bytes(self) -> bytes:
        return json.dumps({
            "model": {
                "type": "business",
                "name": "imported",
                "domains": [
                    {
                        "name": "Sales",
                        "products": [
                            {
                                "name": "orders",
                                "attributes": [
                                    {"name": "order_id", "type": "BIGINT"}
                                ],
                            }
                        ],
                    }
                ],
            }
        }).encode("utf-8")

    def test_volume_path_doesnt_exist_terminal_failure(self, engine):
        """10. Volume path that doesn't resolve → terminal failure,
        succeeded=False, error mentions file-not-found / inaccessible."""
        biz_id, _ = _seed_business_with_two_versions(engine)
        ws = self._ws_with_download(Exception("404: Files API: not found"))
        path = "/Volumes/cat/_metamodel/vol_root/business/test/v9/mvm/model.json"
        req = _ImportReq(business_id=biz_id, volume_path=path)

        with Session(engine) as s:
            biz = s.get(Business, biz_id)
            dag = dag_for_import_from_volume(req, biz, s)

        run_id = _make_run(engine, biz_id, intent="import-from-volume")
        orch = self._orch_with_real_registry(ws)

        with Session(engine) as s:
            run = s.get(Run, run_id)
            orch.start(run, dag, s)
            s.commit()
        # Synthetic primitive returns terminal in dispatch → next advance
        # observes it.
        with Session(engine) as s:
            run = s.get(Run, run_id)
            orch.advance(run, s)
            s.commit()

        with Session(engine) as s:
            row = s.exec(
                select(RunOperation).where(RunOperation.run_id == run_id)
            ).first()
            assert row is not None
            assert row.operation_name == "import_from_volume"
            assert row.status == "failed", row.status
            assert row.error_message
            err = row.error_message.lower()
            assert any(
                tok in err for tok in ("not found", "404", "missing", "file")
            ), (
                f"file-not-found path must surface a recognisable "
                f"file-error message; got {row.error_message!r}"
            )
            run = s.get(Run, run_id)
            assert run.status == "failed"

    def test_malformed_model_json_terminal_failure_with_parse_error(
        self, engine
    ):
        """12. Malformed JSON in the Volume → terminal failure with
        a parse-error message. No partial ModelVersion is created."""
        biz_id, _ = _seed_business_with_two_versions(engine)
        ws = self._ws_with_download(b"{ definitely not, json ::::")
        path = "/Volumes/cat/_metamodel/vol_root/business/test/v9/mvm/model.json"
        req = _ImportReq(business_id=biz_id, volume_path=path)

        with Session(engine) as s:
            biz = s.get(Business, biz_id)
            dag = dag_for_import_from_volume(req, biz, s)

        run_id = _make_run(engine, biz_id, intent="import-from-volume")
        orch = self._orch_with_real_registry(ws)

        with Session(engine) as s:
            run = s.get(Run, run_id)
            orch.start(run, dag, s)
            s.commit()
        with Session(engine) as s:
            run = s.get(Run, run_id)
            orch.advance(run, s)
            s.commit()

        with Session(engine) as s:
            row = s.exec(
                select(RunOperation).where(RunOperation.run_id == run_id)
            ).first()
            assert row is not None
            assert row.status == "failed"
            err = (row.error_message or "").lower()
            assert any(
                tok in err for tok in ("json", "parse", "decode", "invalid")
            ), (
                f"malformed JSON must surface a parse error; got "
                f"{row.error_message!r}"
            )
            # No ModelVersion was added beyond the seed pair.
            mvs = list(
                s.exec(
                    select(ModelVersion).where(
                        ModelVersion.business_id == biz_id
                    )
                ).all()
            )
            # Two seeded versions; no new one from a failed import.
            assert len(mvs) == 2, (
                f"failed import must not leave a stray ModelVersion; "
                f"got {len(mvs)} versions"
            )

    def test_re_import_same_path_is_idempotent(self, engine):
        """11. Re-running an import-from-volume against the same
        ``(run_id, operation_id)`` returns the existing version's id
        and does NOT create a duplicate ModelVersion. Idempotency is
        guaranteed by the primitive's RunOperation-row resume guard."""
        biz_id = _seed_business_no_install(engine)  # start from clean slate
        ws = self._ws_with_download(self._valid_model_json_bytes())
        path = "/Volumes/cat/_metamodel/vol_root/business/test/v9/mvm/model.json"
        req = _ImportReq(business_id=biz_id, volume_path=path)

        with Session(engine) as s:
            biz = s.get(Business, biz_id)
            dag = dag_for_import_from_volume(req, biz, s)

        run_id = _make_run(engine, biz_id, intent="import-from-volume")
        orch = self._orch_with_real_registry(ws)

        # First run-through.
        with Session(engine) as s:
            run = s.get(Run, run_id)
            orch.start(run, dag, s)
            s.commit()
        with Session(engine) as s:
            run = s.get(Run, run_id)
            orch.advance(run, s)
            s.commit()
        with Session(engine) as s:
            row = s.exec(
                select(RunOperation).where(RunOperation.run_id == run_id)
            ).first()
            assert row is not None and row.status == "succeeded", (
                f"first import must have succeeded for an idempotency check; "
                f"got status={row.status if row else None}, error="
                f"{row.error_message if row else None}"
            )
            v_id_first = row.output_version_id
            assert v_id_first

        # Count versions after first import — should be seeded(1) + new(1).
        with Session(engine) as s:
            mvs = list(
                s.exec(
                    select(ModelVersion).where(
                        ModelVersion.business_id == biz_id
                    )
                ).all()
            )
            initial_count = len(mvs)

        # Re-call: simulate the orchestrator resuming after a crash by
        # re-driving start + advance on the same run / operation_id.
        # The primitive's RunOperation-row guard short-circuits.
        with Session(engine) as s:
            run = s.get(Run, run_id)
            orch.start(run, dag, s)
            s.commit()
        with Session(engine) as s:
            run = s.get(Run, run_id)
            orch.advance(run, s)
            s.commit()

        with Session(engine) as s:
            # Same RunOperation row, same output_version_id, no duplicate.
            row2 = s.exec(
                select(RunOperation).where(RunOperation.run_id == run_id)
            ).first()
            assert row2.output_version_id == v_id_first, (
                "re-import must return the existing version's id"
            )
            mvs2 = list(
                s.exec(
                    select(ModelVersion).where(
                        ModelVersion.business_id == biz_id
                    )
                ).all()
            )
            assert len(mvs2) == initial_count, (
                f"re-import duplicated a ModelVersion: was "
                f"{initial_count}, now {len(mvs2)}"
            )


# ---------------------------------------------------------------------------
# Generic — POST /runs validation envelope
# ---------------------------------------------------------------------------


class TestRunsRouteValidationEnvelope:
    """Generic gates: 422 for missing intent-specific fields, 200 +
    warnings echoed when the request validates with non-blocker
    issues."""

    def test_delete_with_reinstall_previous_starts_no_run(
        self, engine, client_with_agent
    ):
        """``reinstall_previous`` was removed from the delete route: a
        request still carrying it deletes the version and persists no Run
        (making a prior version current is an install of it)."""
        biz_id, v_ids = _seed_business_with_two_versions(engine, deployed_version=0)
        current_id = v_ids[2]

        r = client_with_agent.delete(
            f"/api/businesses/{biz_id}/versions/{current_id}"
            f"?reinstall_previous=true"
        )

        assert r.status_code == 200, r.text
        assert "run_id" not in r.json()
        with Session(engine) as s:
            assert s.exec(select(Run).where(Run.business_id == biz_id)).all() == []

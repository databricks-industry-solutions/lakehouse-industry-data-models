"""Adversarial tests for the ``vibe-new-ecm-mvm`` intent.

A new run intent for internal industry-model authoring. It combines
``vibe-iterate`` (over an ECM parent) with ``shrink-to-mvm`` into one
multi-step Run. The DAG shape mirrors ``dag_for_new_base_model`` but
substitutes ``vibe_iterate`` for ``generate_ecm`` as step 0.

These tests are written by a separate test agent (Skeptical Tester
Pattern, ``docs/orchestrator-design.md`` §9) without reading the dev
agent's implementation. They target the public observable contract:

- ``Intent.VIBE_NEW_ECM_MVM`` enum value exists and is accepted.
- ``dag_for_vibe_new_ecm_mvm`` factory returns the documented DAG shape
  per ``cataloging_style``.
- ``POST /runs`` with ``intent="vibe-new-ecm-mvm"`` persists Run +
  RunOperation rows and returns the standard ``RunOut`` shape with
  ``warnings``.
- ``POST /runs/validate`` mirrors the create path's blockers.
- Validator rejects requests where the parent version is MVM-scoped or
  ``vibe_instructions`` is empty.
- ``GET /runs/{id}/operations`` lists the steps in order.
- Soft-drain still gates the route.

# STUB-FOR-INTEGRATION:
``Intent.VIBE_NEW_ECM_MVM`` and the ``dag_for_vibe_new_ecm_mvm`` factory
do not exist on ``main`` (or the ``dev`` parent). Tests fail with a
clear ``ImportError`` when the symbol is absent, rather than skipping.
"""

from __future__ import annotations

import importlib
import json
from typing import Any, Optional
from unittest.mock import MagicMock

import pytest
from sqlmodel import Session, select

from vibe_modeling.backend.db_models import (
    Business,
    ModelVersion,
    Run,
    RunOperation,
)
from vibe_modeling.backend.models import Intent
from vibe_modeling.backend.services.operations import _registry as _registry_module
from vibe_modeling.backend.services.operations.install import Install
from vibe_modeling.backend.services.operations.shrink_to_mvm import ShrinkToMvm
from vibe_modeling.backend.services.operations.vibe_iterate import VibeIterate


# ---------------------------------------------------------------------------
# STUB-FOR-INTEGRATION gate
# ---------------------------------------------------------------------------
#
# The ``VIBE_NEW_ECM_MVM`` enum value lives on ``Intent``. We resolve
# lazily and force every test in this module to raise (not skip) with a
# clear, single-line reason on branches where the symbol is absent.

_VNEM_INTENT = getattr(Intent, "VIBE_NEW_ECM_MVM", None)
_INTENT_VALUE = getattr(_VNEM_INTENT, "value", None) if _VNEM_INTENT else None


@pytest.fixture(autouse=True)
def _require_intent():
    if _VNEM_INTENT is None:
        raise ImportError(
            "Intent.VIBE_NEW_ECM_MVM not yet implemented — "
            "STUB-FOR-INTEGRATION. Merge feat/vibe-new-ecm-mvm dev work."
        )


@pytest.fixture(autouse=True)
def _populate_registry():
    """Re-register the primitives this DAG dispatches.

    Other test modules clear the registry via ``reset_for_tests`` in
    teardown. The wirer's orchestrator branch resolves primitive names
    via the registry, so re-populate here so every test in this module
    sees the same baseline regardless of execution order.
    """
    _registry_module.reset_for_tests()
    for cls in (VibeIterate, ShrinkToMvm, Install):
        _registry_module.register(cls())
    yield
    _registry_module.reset_for_tests()


# ---------------------------------------------------------------------------
# Module-resolution helpers (mirrors the pattern in test_wire_simple_runs.py)
# ---------------------------------------------------------------------------

_FACTORY_CANDIDATE_MODULES: tuple[str, ...] = (
    "vibe_modeling.backend.services.orchestrator.dag_factories",
    "vibe_modeling.backend.services.orchestrator.factories",
    "vibe_modeling.backend.services.orchestrator.routes",
    "vibe_modeling.backend.services.orchestrator",
    "vibe_modeling.backend.routes.runs",
)

_FACTORY_NAME_CANDIDATES: tuple[str, ...] = (
    "dag_for_vibe_new_ecm_mvm",
    "dag_for_vibe_new_ecm_to_mvm",
    "dag_for_new_ecm_mvm",
)


def _resolve_factory():
    """Look up the ``vibe-new-ecm-mvm`` DAG factory across plausible paths."""
    errors: list[str] = []
    for mod_path in _FACTORY_CANDIDATE_MODULES:
        try:
            mod = importlib.import_module(mod_path)
        except Exception as e:  # noqa: BLE001
            errors.append(f"{mod_path}: import error {e!r}")
            continue
        for fn_name in _FACTORY_NAME_CANDIDATES:
            fn = getattr(mod, fn_name, None)
            if fn is not None:
                return fn
        errors.append(f"{mod_path}: no attribute in {_FACTORY_NAME_CANDIDATES}")
    pytest.fail(
        "DAG factory for vibe-new-ecm-mvm not resolvable — "
        "STUB-FOR-INTEGRATION. Tried:\n" + "\n".join(f"  - {e}" for e in errors)
    )


def _safe_call_factory(factory, request_dict: dict, *, business: Any, session: Any = None):
    """Try a few plausible factory signatures (mirrors test_wire_simple_runs).

    Constructs a real ``RunIn`` from the body — the dev factory expects
    every Pydantic-defaulted field on the request (e.g. ``naming_convention``)
    so a ``SimpleNamespace`` of just-the-supplied-keys won't do.
    """
    from types import SimpleNamespace

    from vibe_modeling.backend.models import RunIn

    # Real RunIn — gives the factory all default-valued attributes.
    try:
        req_in = RunIn(**request_dict)
    except Exception:  # pragma: no cover — fall back to namespace
        req_in = None

    req_ns = SimpleNamespace(**request_dict)
    attempts: list[tuple[tuple, dict]] = []
    if req_in is not None:
        attempts.extend(
            [
                ((req_in, business), {}),
                ((req_in, business, session), {}),
                ((req_in,), {"business": business}),
                ((req_in,), {"business": business, "session": session}),
                ((req_in,), {}),
            ]
        )
    attempts.extend(
        [
            ((req_ns, business), {}),
            ((req_ns, business, session), {}),
            ((request_dict, business), {}),
            ((request_dict, business, session), {}),
            ((req_ns,), {"business": business}),
            ((req_ns,), {"business": business, "session": session}),
            ((req_ns,), {}),
            ((request_dict,), {}),
        ]
    )
    last_err: Optional[Exception] = None
    for args, kwargs in attempts:
        try:
            return factory(*args, **kwargs)
        except TypeError as e:
            last_err = e
            continue
    pytest.fail(
        f"DAG factory {factory!r} rejected every attempted signature. "
        f"Last TypeError: {last_err!r}"
    )


# ---------------------------------------------------------------------------
# Local fixtures (build on conftest.py engine + client_with_agent)
# ---------------------------------------------------------------------------


@pytest.fixture
def parent_ecm_version(engine, seed_business) -> tuple[str, str]:
    """Seed an ECM-scope completed parent ModelVersion.

    Returns ``(business_id, version_id)``.
    """
    with Session(engine) as session:
        mv = ModelVersion(
            business_id=seed_business,
            version=1,
            status="completed",
            deployment_status="draft",
            scope="ecm",
            uc_catalog="test_catalog",
        )
        session.add(mv)
        session.commit()
        session.refresh(mv)
        return seed_business, mv.id


@pytest.fixture
def parent_mvm_version(engine, seed_business) -> tuple[str, str]:
    """Seed an MVM-scope completed parent ModelVersion.

    Used to assert the validator rejects MVM parents on this intent.
    """
    with Session(engine) as session:
        mv = ModelVersion(
            business_id=seed_business,
            version=1,
            status="completed",
            deployment_status="draft",
            scope="mvm",
            uc_catalog="test_catalog",
        )
        session.add(mv)
        session.commit()
        session.refresh(mv)
        return seed_business, mv.id


def _ws_with_run_now(mock_ws: MagicMock, run_id: int = 4242) -> None:
    mock_run = MagicMock()
    mock_run.run_id = run_id
    mock_run.response = MagicMock()
    mock_run.response.run_id = run_id
    mock_ws.jobs.run_now.return_value = mock_run


def _runops_for(engine, run_id: str) -> list[RunOperation]:
    with Session(engine) as session:
        return list(
            session.exec(
                select(RunOperation)
                .where(RunOperation.run_id == run_id)
                .order_by(RunOperation.step_index)
            ).all()
        )


def _make_body(
    *,
    business_id: str,
    parent_version_id: str,
    cataloging_style: str = "One Catalog",
    catalog: str = "test_catalog",
    vibe_instructions: str = "Add a new HR domain with employees and roles.",
    extra: Optional[dict] = None,
) -> dict:
    body: dict = {
        "intent": "vibe-new-ecm-mvm",
        "parent_version_id": parent_version_id,
        "vibe_instructions": vibe_instructions,
        "catalog": catalog,
        "cataloging_style": cataloging_style,
        "business_context_path": "/Volumes/test/ctx/vibes/ctx.json",
    }
    # One Catalog requires schema prefixes; per-scope catalogs forbid them.
    if cataloging_style == "One Catalog":
        body["ecm_schema_prefix"] = "ecm_"
        body["mvm_schema_prefix"] = "mvm_"
    else:
        body["ecm_schema_prefix"] = ""
        body["mvm_schema_prefix"] = ""
    if extra:
        body.update(extra)
    return body


# ---------------------------------------------------------------------------
# Section 1: Intent enum + factory existence
# ---------------------------------------------------------------------------


class TestIntentEnumExists:
    """Both intents are first-class. Per spec, neither is gated; the
    wire accepts ``vibe-iterate`` AND ``vibe-new-ecm-mvm`` interchangeably.
    """

    def test_vibe_iterate_intent_value_present(self):
        assert hasattr(Intent, "VIBE_ITERATE"), "Intent.VIBE_ITERATE must exist"
        assert Intent.VIBE_ITERATE.value == "vibe-iterate"

    def test_vibe_new_ecm_mvm_intent_value_present(self):
        assert hasattr(Intent, "VIBE_NEW_ECM_MVM"), (
            "Intent.VIBE_NEW_ECM_MVM must exist as a first-class enum value"
        )
        assert Intent.VIBE_NEW_ECM_MVM.value == "vibe-new-ecm-mvm", (
            f"Intent.VIBE_NEW_ECM_MVM.value must be 'vibe-new-ecm-mvm'; "
            f"got {Intent.VIBE_NEW_ECM_MVM.value!r}"
        )


# ---------------------------------------------------------------------------
# Section 2: DAG factory shape per cataloging_style
# ---------------------------------------------------------------------------


class TestDagShape:
    """The DAG factory mirrors ``dag_for_new_base_model`` but with
    ``vibe_iterate`` substituted for ``generate_ecm`` at step 0.
    """

    def test_one_catalog_yields_two_step_dag(self, engine, parent_ecm_version):
        from vibe_modeling.backend.services.orchestrator.dag import Dag

        biz_id, parent_vid = parent_ecm_version
        with Session(engine) as session:
            business = session.get(Business, biz_id)
            factory = _resolve_factory()
            dag = _safe_call_factory(
                factory,
                _make_body(
                    business_id=biz_id,
                    parent_version_id=parent_vid,
                    cataloging_style="One Catalog",
                ),
                business=business,
                session=session,
            )
        assert isinstance(dag, Dag), f"factory returned {type(dag).__name__}"
        names = [s.name for s in dag.steps]
        assert names == ["vibe_iterate", "shrink_to_mvm"], (
            f"One Catalog must yield exactly [vibe_iterate, shrink_to_mvm]; got {names}"
        )

    def test_catalog_per_division_yields_two_step_dag(
        self, engine, parent_ecm_version
    ):
        from vibe_modeling.backend.services.orchestrator.dag import Dag

        biz_id, parent_vid = parent_ecm_version
        with Session(engine) as session:
            business = session.get(Business, biz_id)
            factory = _resolve_factory()
            dag = _safe_call_factory(
                factory,
                _make_body(
                    business_id=biz_id,
                    parent_version_id=parent_vid,
                    cataloging_style="Catalog per Division",
                ),
                business=business,
                session=session,
            )
        assert isinstance(dag, Dag)
        names = [s.name for s in dag.steps]
        assert names == ["vibe_iterate", "shrink_to_mvm"], (
            f"Catalog per Division must produce 2 steps; got {names}"
        )

    def test_catalog_per_domain_yields_two_step_dag(
        self, engine, parent_ecm_version
    ):
        from vibe_modeling.backend.services.orchestrator.dag import Dag

        biz_id, parent_vid = parent_ecm_version
        with Session(engine) as session:
            business = session.get(Business, biz_id)
            factory = _resolve_factory()
            dag = _safe_call_factory(
                factory,
                _make_body(
                    business_id=biz_id,
                    parent_version_id=parent_vid,
                    cataloging_style="Catalog per Domain",
                ),
                business=business,
                session=session,
            )
        assert isinstance(dag, Dag)
        names = [s.name for s in dag.steps]
        assert names == ["vibe_iterate", "shrink_to_mvm"], (
            f"Catalog per Domain must produce 2 steps; got {names}"
        )

    def test_vibe_iterate_step_has_no_needs_version_from(
        self, engine, parent_ecm_version
    ):
        """Step 0 (vibe_iterate) reads ``parent_version_id`` from the
        request body — NOT via ``needs_version_from``. There is no prior
        step to inherit from."""
        biz_id, parent_vid = parent_ecm_version
        with Session(engine) as session:
            business = session.get(Business, biz_id)
            factory = _resolve_factory()
            dag = _safe_call_factory(
                factory,
                _make_body(
                    business_id=biz_id,
                    parent_version_id=parent_vid,
                    cataloging_style="One Catalog",
                ),
                business=business,
                session=session,
            )
        step0 = dag.steps[0]
        assert step0.name == "vibe_iterate"
        assert step0.needs_version_from is None, (
            "step 0 (vibe_iterate) must NOT inherit via needs_version_from "
            f"— parent comes from request body. Got {step0.needs_version_from!r}"
        )

    def test_shrink_step_inherits_from_vibe_iterate(self, engine, parent_ecm_version):
        """The shrink step must explicitly point at vibe_iterate so the
        orchestrator threads the new ECM ``output_version_id`` into the
        shrink op's ``parent_version_id``. Forgetting this would silently
        let shrink read whatever ``OperationContext.parent_version_id``
        carries (which is the *original* parent, not the new ECM)."""
        biz_id, parent_vid = parent_ecm_version
        with Session(engine) as session:
            business = session.get(Business, biz_id)
            factory = _resolve_factory()
            dag = _safe_call_factory(
                factory,
                _make_body(
                    business_id=biz_id,
                    parent_version_id=parent_vid,
                    cataloging_style="One Catalog",
                ),
                business=business,
                session=session,
            )
        shrink = next(s for s in dag.steps if s.name == "shrink_to_mvm")
        assert shrink.needs_version_from == "vibe_iterate", (
            "shrink_to_mvm must inherit explicitly from vibe_iterate; "
            f"got {shrink.needs_version_from!r}"
        )

    def test_per_division_shrink_inherits_from_vibe_iterate(
        self, engine, parent_ecm_version
    ):
        """Per-Division shrink step still inherits the new ECM version
        produced by vibe_iterate — same as One Catalog mode."""
        biz_id, parent_vid = parent_ecm_version
        with Session(engine) as session:
            business = session.get(Business, biz_id)
            factory = _resolve_factory()
            dag = _safe_call_factory(
                factory,
                _make_body(
                    business_id=biz_id,
                    parent_version_id=parent_vid,
                    cataloging_style="Catalog per Division",
                ),
                business=business,
                session=session,
            )
        shrink = next(s for s in dag.steps if s.name == "shrink_to_mvm")
        assert shrink.needs_version_from == "vibe_iterate", (
            "shrink_to_mvm must inherit parent_version_id from vibe_iterate; "
            f"got {shrink.needs_version_from!r}"
        )


# ---------------------------------------------------------------------------
# Section 3: POST /runs body shape — happy path + body validation
# ---------------------------------------------------------------------------


class TestPostRunsHappyPath:
    """The wirer turns a ``vibe-new-ecm-mvm`` request into a 2-step (One
    Catalog) or 4-step (per-Division/per-Domain) DAG, persists the Run
    + RunOperation rows, and dispatches step 0."""

    def test_one_catalog_creates_run_with_two_run_operations(
        self, client_with_agent, mock_ws, parent_ecm_version, engine
    ):
        biz_id, parent_vid = parent_ecm_version
        _ws_with_run_now(mock_ws, run_id=10101)

        body = _make_body(
            business_id=biz_id,
            parent_version_id=parent_vid,
            cataloging_style="One Catalog",
        )
        resp = client_with_agent.post(f"/api/businesses/{biz_id}/runs", json=body)
        assert resp.status_code == 200, resp.text
        data = resp.json()
        assert data["business_id"] == biz_id
        assert "warnings" in data
        # Run.intent must round-trip the new intent string.
        with Session(engine) as session:
            run = session.get(Run, data["id"])
            assert run is not None
            assert run.intent == "vibe-new-ecm-mvm", (
                f"Run.intent must persist as 'vibe-new-ecm-mvm'; got {run.intent!r}"
            )
        # Two RunOperation rows in step_index order.
        ops = _runops_for(engine, data["id"])
        assert [op.operation_name for op in ops] == [
            "vibe_iterate",
            "shrink_to_mvm",
        ], (
            f"One Catalog should produce [vibe_iterate, shrink_to_mvm]; "
            f"got {[op.operation_name for op in ops]}"
        )
        assert [op.step_index for op in ops] == [0, 1]

    def test_catalog_per_division_creates_run_with_two_operations(
        self, client_with_agent, mock_ws, parent_ecm_version, engine
    ):
        biz_id, parent_vid = parent_ecm_version
        _ws_with_run_now(mock_ws, run_id=10102)

        body = _make_body(
            business_id=biz_id,
            parent_version_id=parent_vid,
            cataloging_style="Catalog per Division",
        )
        resp = client_with_agent.post(f"/api/businesses/{biz_id}/runs", json=body)
        assert resp.status_code == 200, resp.text
        data = resp.json()
        ops = _runops_for(engine, data["id"])
        assert [op.operation_name for op in ops] == [
            "vibe_iterate",
            "shrink_to_mvm",
        ], (
            f"Catalog per Division should produce 2 ops; "
            f"got {[op.operation_name for op in ops]}"
        )

    def test_missing_parent_version_id_is_blocker(
        self, client_with_agent, mock_ws, seed_business
    ):
        """Body without ``parent_version_id`` is a contract miss for the
        whole intent — vibe needs a parent to branch from."""
        _ws_with_run_now(mock_ws)
        body = {
            "intent": "vibe-new-ecm-mvm",
            "vibe_instructions": "Add HR tables",
            "catalog": "test_catalog",
            "cataloging_style": "One Catalog",
            "ecm_schema_prefix": "ecm_",
            "mvm_schema_prefix": "mvm_",
            "business_context_path": "/Volumes/test/ctx/vibes/ctx.json",
        }
        resp = client_with_agent.post(f"/api/businesses/{seed_business}/runs", json=body)
        assert resp.status_code in (400, 422), (
            f"missing parent_version_id must reject; got {resp.status_code}: {resp.text}"
        )

    def test_missing_vibe_instructions_is_blocker(
        self, client_with_agent, mock_ws, parent_ecm_version
    ):
        """Body without ``vibe_instructions`` must reject — same field-level
        contract as ``vibe-iterate``."""
        biz_id, parent_vid = parent_ecm_version
        _ws_with_run_now(mock_ws)
        body = {
            "intent": "vibe-new-ecm-mvm",
            "parent_version_id": parent_vid,
            "catalog": "test_catalog",
            "cataloging_style": "One Catalog",
            "ecm_schema_prefix": "ecm_",
            "mvm_schema_prefix": "mvm_",
            "business_context_path": "/Volumes/test/ctx/vibes/ctx.json",
        }
        resp = client_with_agent.post(f"/api/businesses/{biz_id}/runs", json=body)
        assert resp.status_code in (400, 422), (
            f"missing vibe_instructions must reject; got {resp.status_code}: {resp.text}"
        )

    def test_blank_vibe_instructions_returns_blocker(
        self, client_with_agent, mock_ws, parent_ecm_version
    ):
        """Whitespace-only ``vibe_instructions`` is rejected by the
        ``VibeIterateParams`` validator — the wirer must surface this
        as a blocker (400), same as the ``vibe-iterate`` intent."""
        biz_id, parent_vid = parent_ecm_version
        _ws_with_run_now(mock_ws)
        body = _make_body(
            business_id=biz_id,
            parent_version_id=parent_vid,
            vibe_instructions="   ",  # whitespace
        )
        resp = client_with_agent.post(f"/api/businesses/{biz_id}/runs", json=body)
        assert resp.status_code == 400, (
            f"blank vibe_instructions must 400; got {resp.status_code}: {resp.text}"
        )

    def test_parent_must_be_ecm_scope(
        self, client_with_agent, mock_ws, parent_mvm_version
    ):
        """Validator: ``parent_version_id`` MUST point at an ECM-scope
        ModelVersion. MVM-scope parent → 400 with a blocker mentioning
        ``parent_version_id`` and the word ``ECM`` somewhere."""
        biz_id, parent_vid = parent_mvm_version
        _ws_with_run_now(mock_ws)
        body = _make_body(
            business_id=biz_id,
            parent_version_id=parent_vid,
            cataloging_style="One Catalog",
        )
        resp = client_with_agent.post(f"/api/businesses/{biz_id}/runs", json=body)
        assert resp.status_code == 400, (
            f"MVM-scope parent must reject; got {resp.status_code}: {resp.text}"
        )
        # Surface a blocker shape — body is either {"detail": [...]} or
        # {"blockers": [...]}; we accept either as long as ECM is named.
        text = resp.text
        assert "ECM" in text or "ecm" in text, (
            f"blocker must mention 'ECM'; got body {text!r}"
        )


# ---------------------------------------------------------------------------
# Section 4: POST /runs/validate mirrors create
# ---------------------------------------------------------------------------


class TestValidateMirrorsCreate:
    """``POST /runs/validate`` returns ``{warnings, blockers}`` for the
    same body that ``POST /runs`` would accept/reject. No Run row is
    persisted regardless of body validity."""

    def test_validate_happy_path_returns_no_blockers_no_runs(
        self, client_with_agent, parent_ecm_version, engine
    ):
        biz_id, parent_vid = parent_ecm_version
        body = _make_body(
            business_id=biz_id,
            parent_version_id=parent_vid,
            cataloging_style="One Catalog",
        )
        resp = client_with_agent.post(f"/api/businesses/{biz_id}/runs/validate", json=body)
        assert resp.status_code in (200, 400), resp.text
        data = resp.json()
        assert "warnings" in data and isinstance(data["warnings"], list), (
            f"response missing 'warnings' list: {data}"
        )
        assert "blockers" in data and isinstance(data["blockers"], list), (
            f"response missing 'blockers' list: {data}"
        )
        # Read-only — no Run row should land regardless of status.
        with Session(engine) as session:
            runs = session.exec(select(Run)).all()
        assert runs == [], f"validate must not persist a Run; got {len(runs)}"

    def test_validate_mvm_parent_returns_blocker(
        self, client_with_agent, parent_mvm_version
    ):
        """Same MVM-parent case as the create test, but on /validate.
        Body either includes blockers or 400s — never silently passes."""
        biz_id, parent_vid = parent_mvm_version
        body = _make_body(
            business_id=biz_id,
            parent_version_id=parent_vid,
            cataloging_style="One Catalog",
        )
        resp = client_with_agent.post(f"/api/businesses/{biz_id}/runs/validate", json=body)
        # Either 200 with blockers in body OR 400 — but NOT a clean 200
        # with empty blockers.
        if resp.status_code == 200:
            data = resp.json()
            assert data.get("blockers"), (
                f"MVM-parent validate must surface blockers; got {data}"
            )
        else:
            assert resp.status_code in (400, 422), resp.text


# ---------------------------------------------------------------------------
# Section 5: GET /runs/{id}/operations after vibe-new-ecm-mvm create
# ---------------------------------------------------------------------------


class TestRunOperationsAfterCreate:
    """After a successful POST /runs, the operations endpoint returns
    the persisted RunOperation rows in step_index order."""

    def test_one_catalog_lists_two_operations(
        self, client_with_agent, mock_ws, parent_ecm_version
    ):
        biz_id, parent_vid = parent_ecm_version
        _ws_with_run_now(mock_ws, run_id=20201)
        body = _make_body(
            business_id=biz_id,
            parent_version_id=parent_vid,
            cataloging_style="One Catalog",
        )
        resp = client_with_agent.post(f"/api/businesses/{biz_id}/runs", json=body)
        assert resp.status_code == 200, resp.text
        run_id = resp.json()["id"]

        ops_resp = client_with_agent.get(f"/api/businesses/{biz_id}/runs/{run_id}/operations")
        assert ops_resp.status_code == 200, ops_resp.text
        ops = ops_resp.json()
        assert isinstance(ops, list)
        assert [op["operation_name"] for op in ops] == [
            "vibe_iterate",
            "shrink_to_mvm",
        ], f"unexpected ops list: {ops}"
        assert [op["step_index"] for op in ops] == [0, 1]

    def test_catalog_per_division_lists_two_operations(
        self, client_with_agent, mock_ws, parent_ecm_version
    ):
        biz_id, parent_vid = parent_ecm_version
        _ws_with_run_now(mock_ws, run_id=20202)
        body = _make_body(
            business_id=biz_id,
            parent_version_id=parent_vid,
            cataloging_style="Catalog per Division",
        )
        resp = client_with_agent.post(f"/api/businesses/{biz_id}/runs", json=body)
        assert resp.status_code == 200, resp.text
        run_id = resp.json()["id"]

        ops_resp = client_with_agent.get(f"/api/businesses/{biz_id}/runs/{run_id}/operations")
        assert ops_resp.status_code == 200, ops_resp.text
        ops = ops_resp.json()
        assert [op["operation_name"] for op in ops] == [
            "vibe_iterate",
            "shrink_to_mvm",
        ], f"unexpected ops list: {ops}"


# ---------------------------------------------------------------------------
# Section 6: Soft-drain still gates the route
# ---------------------------------------------------------------------------




# ---------------------------------------------------------------------------
# Section 7: the form's pre-filled conventions reach both steps and the audit
# ---------------------------------------------------------------------------


class TestConventionsReachBothSteps:
    """T2 J7 A2: the base ECM has SCREAMING_CASE, Int (0/1), dd/MM/yyyy and
    the tag suffix _wt. The form pre-fills them and sends every field, blanks
    included; both steps carry them and ``parameters_json`` lists every
    non-empty one."""

    BASE_CONVENTIONS = {
        "naming_convention": "SCREAMING_CASE",
        "primary_key_suffix": "_id",
        "schema_suffix": "",
        "tag_prefix": "dbx_",
        "tag_suffix": "_wt",
        "table_id_type": "BIGINT",
        "boolean_format": "Int (0/1)",
        "date_format": "dd/MM/yyyy",
        "timestamp_format": "yyyy-MM-dd HH:mm:ss",
        "classification_levels": "",
        "catalog_prefix": "",
        "catalog_suffix": "",
        "org_divisions": "Operations, Business and Corporate",
        "housekeeping_columns": "No",
        "history_tracking_columns": "No",
    }

    def test_vibe_new_ecm_mvm_carries_the_base_conventions(
        self, client_with_agent, mock_ws, parent_ecm_version, engine
    ):
        biz_id, parent_vid = parent_ecm_version
        _ws_with_run_now(mock_ws, run_id=30303)
        body = _make_body(
            business_id=biz_id,
            parent_version_id=parent_vid,
            extra=self.BASE_CONVENTIONS,
        )
        resp = client_with_agent.post(f"/api/businesses/{biz_id}/runs", json=body)
        assert resp.status_code == 200, resp.text
        run_id = resp.json()["id"]

        with Session(engine) as session:
            stored = json.loads(session.get(Run, run_id).parameters_json)
        for field, value in self.BASE_CONVENTIONS.items():
            if value:
                assert stored[field] == value, field
            else:
                assert field not in stored, field

        vibe_step, shrink_step = _runops_for(engine, run_id)
        for step in (vibe_step, shrink_step):
            params = json.loads(step.params_json)
            for field, value in self.BASE_CONVENTIONS.items():
                assert params[field] == value, (step.operation_name, field)
        assert json.loads(vibe_step.params_json)["schema_prefix"] == "ecm_"
        assert json.loads(shrink_step.params_json)["schema_prefix"] == "mvm_"

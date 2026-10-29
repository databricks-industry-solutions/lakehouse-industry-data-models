"""Adversarial tests for the Phase-4 *wire-simple-runs* slice.

Covers the single-step intents (``vibe-iterate``, ``install``,
``uninstall``) — each maps to a one-step DAG. See
``docs/orchestrator-design.md`` §3 (DAG description), §6 (failure
semantics) and §8 (POST /runs / RunOut API contract).

Tests target *observable* behaviour:

* HTTP status returned by ``POST /api/runs``.
* Response body (RunOut shape with ``warnings``).
* Persisted ``Run`` rows in Lakebase.
* Persisted ``RunOperation`` rows (one per ``OperationStep`` in the
  one-step DAGs).
* DAG factory return shape (single ``OperationStep`` with the right
  primitive ``name`` and Pydantic-valid ``params``).

The DAG-factory imports are guarded:  the integrator's branch lands
``dag_for_vibe_iterate`` / ``dag_for_install`` / ``dag_for_uninstall``
somewhere under
``services.orchestrator.*`` (the design doc §3 cites
``services/orchestrator/routes.py`` and gives ``dag_for_new_base_model``
as the naming convention).  We resolve them through a tolerant lookup
that falls back to a clear "STUB-FOR-INTEGRATION" failure if the symbol
isn't there yet.

These tests fail on ``main``: the DAG factories don't exist there, the
``POST /runs`` body still requires ``run_type`` (not ``intent``), and no
``RunOperation`` rows are written by the legacy wirer.
"""

from __future__ import annotations

import importlib
import json
from typing import Any, Optional
from unittest.mock import MagicMock

import pytest
from sqlmodel import Session, select

from vibe_modeling.backend.db_models import (
    AgentConfig,
    Business,
    BusinessContext,
    ModelVersion,
    Run,
    RunOperation,
)
from vibe_modeling.backend.services.uninstall_impact import uninstall_confirm_subject
from vibe_modeling.backend.services.operations import _registry as _registry_module
from vibe_modeling.backend.services.operations.generate_samples import GenerateSamples
from vibe_modeling.backend.services.operations.install import Install
from vibe_modeling.backend.services.operations.uninstall import Uninstall
from vibe_modeling.backend.services.operations.vibe_iterate import VibeIterate


@pytest.fixture(autouse=True)
def _populate_registry():
    """Ensure the four primitives this slice owns are registered.

    Other test modules clear the registry via ``reset_for_tests`` in
    teardown — primitive ``register(...)`` calls fire only once per
    process, so anything running after them sees an empty registry.
    Re-populate here so the route's orchestrator branch activates
    and we exercise the wirer (rather than silently falling through
    to the legacy walker)."""
    _registry_module.reset_for_tests()
    for cls in (VibeIterate, Install, Uninstall, GenerateSamples):
        _registry_module.register(cls())
    yield
    _registry_module.reset_for_tests()


# ---------------------------------------------------------------------------
# Module-resolution helpers (STUB-FOR-INTEGRATION)
# ---------------------------------------------------------------------------
#
# The dev branch lands the DAG factories somewhere under
# ``vibe_modeling.backend.services.orchestrator.*``. We try a few module
# paths the design doc gestures at; if none of them resolve, the helper
# raises an AssertionError with a clear "factory missing" message so the
# test fails (rather than erroring out at import time).
#
# We intentionally do NOT import from a single fixed module because the
# point of this test slice is to validate observable contract behaviour
# without coupling to the integrator's internal layout.

_FACTORY_CANDIDATE_MODULES: tuple[str, ...] = (
    "vibe_modeling.backend.services.orchestrator.dag_factories",
    "vibe_modeling.backend.services.orchestrator.factories",
    "vibe_modeling.backend.services.orchestrator.routes",
    "vibe_modeling.backend.services.orchestrator",
    "vibe_modeling.backend.routes.runs",
)


def _resolve_factory(name: str):
    """Look up a DAG factory function by short name across plausible modules.

    ``name`` example: ``"dag_for_vibe_iterate"``.  Returns the resolved
    callable, or raises ``AssertionError`` so the test fails with a clear
    "STUB-FOR-INTEGRATION" message when none of the candidate modules
    expose the symbol yet.
    """
    errors: list[str] = []
    for mod_path in _FACTORY_CANDIDATE_MODULES:
        try:
            mod = importlib.import_module(mod_path)
        except Exception as e:  # noqa: BLE001 — collect every failure
            errors.append(f"{mod_path}: import error {e!r}")
            continue
        fn = getattr(mod, name, None)
        if fn is not None:
            return fn
        errors.append(f"{mod_path}: no attribute {name}")
    pytest.fail(
        # STUB-FOR-INTEGRATION — ``dag_for_*`` factories are owned by the
        # Phase-4 wirer agent. The dev branch ships them; on ``main`` this
        # function does not exist, so this test fails (per acceptance).
        f"DAG factory '{name}' not resolvable.  Tried:\n"
        + "\n".join(f"  - {e}" for e in errors)
    )


# ---------------------------------------------------------------------------
# Test fixtures (build on conftest.py's engine + client_with_agent)
# ---------------------------------------------------------------------------


@pytest.fixture
def deployed_version(engine, seed_business) -> tuple[str, str, int]:
    """Seed a 'completed' ModelVersion the install/uninstall/samples ops
    can target.  Returns ``(business_id, version_id, version_int)``."""
    with Session(engine) as session:
        mv = ModelVersion(
            business_id=seed_business,
            version=1,
            status="completed",
            deployment_status="deployed",
            scope="ecm",
            uc_catalog="test_catalog",
        )
        session.add(mv)
        session.commit()
        session.refresh(mv)
        return seed_business, mv.id, mv.version


@pytest.fixture
def parent_version_for_vibe(engine, seed_business) -> tuple[str, str]:
    """Seed a parent ModelVersion vibe-iterate can branch from. Returns
    ``(business_id, version_id)``."""
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


def _ws_with_run_now(mock_ws: MagicMock, run_id: int = 4242) -> None:
    mock_run = MagicMock()
    mock_run.run_id = run_id
    mock_run.response = MagicMock()
    mock_run.response.run_id = run_id
    mock_ws.jobs.run_now.return_value = mock_run


def _post_runs(client, business_id: str, payload: dict):
    """Convenience wrapper — POST a run under the nested business path."""
    return client.post(f"/api/businesses/{business_id}/runs", json=payload)


def _runops_for(engine, run_id: str) -> list[RunOperation]:
    with Session(engine) as session:
        return list(
            session.exec(
                select(RunOperation)
                .where(RunOperation.run_id == run_id)
                .order_by(RunOperation.step_index)
            ).all()
        )


def _run_row(engine, run_id: str) -> Optional[Run]:
    with Session(engine) as session:
        return session.get(Run, run_id)


# ---------------------------------------------------------------------------
# 1-4. POST /runs happy paths (one per intent)
# ---------------------------------------------------------------------------


class TestPostRunsHappyPaths:
    """The wirer turns each ``intent`` into a 1-step DAG, persists the Run
    and the matching RunOperation row, and dispatches step 0."""

    def test_vibe_iterate_creates_run_and_run_operation(
        self, client_with_agent, mock_ws, parent_version_for_vibe, engine
    ):
        biz_id, parent_vid = parent_version_for_vibe
        _ws_with_run_now(mock_ws, run_id=10101)

        resp = _post_runs(
            client_with_agent,
            biz_id,
            {
                "intent": "vibe-iterate",
                "parent_version_id": parent_vid,
                "vibe_instructions": "Add HR domain tables",
                "catalog": "test_catalog",
                "business_context_path": "/Volumes/test/ctx/vibes/ctx.json",
            },
        )
        assert resp.status_code == 200, resp.text
        body = resp.json()
        assert body["business_id"] == biz_id
        # Body MUST echo warnings (empty list on the happy path).  Per
        # design doc §2.4 the field is always present in RunOut.
        assert "warnings" in body
        assert body["warnings"] == []

        # One RunOperation row, primitive name 'vibe_iterate'.
        ops = _runops_for(engine, body["id"])
        assert len(ops) == 1, f"expected exactly 1 RunOperation, got {ops}"
        assert ops[0].operation_name == "vibe_iterate"
        assert ops[0].step_index == 0

    def test_install_creates_run_and_run_operation(
        self, client_with_agent, mock_ws, deployed_version, engine
    ):
        biz_id, vid, vint = deployed_version
        _ws_with_run_now(mock_ws, run_id=20202)

        resp = _post_runs(
            client_with_agent,
            biz_id,
            {
                "intent": "install",
                "version_id": vid,
                "scope": "ecm",
                "version_int": vint,
                "catalog": "test_catalog",
                "deployment_catalog": "test_catalog",
                "schema_prefix": "ecm_",
                "cataloging_style": "One Catalog",
            },
        )
        assert resp.status_code == 200, resp.text
        body = resp.json()
        # ``deployed_version`` is already deployment_status="deployed" to
        # this exact catalog, so the re-install clash warning fires here -
        # non-blocking, see TestDeployedVersionReinstallWarning below.
        assert body["warnings"] == [
            {
                "field_path": "version_id",
                "step_index": -1,
                "message": (
                    "This version is already recorded as deployed to "
                    "test_catalog; re-installing without uninstalling "
                    "first will fail the agent's clash check."
                ),
                "severity": "warning",
                "subject": None,
                "versions": [],
            }
        ]

        ops = _runops_for(engine, body["id"])
        assert len(ops) == 1
        assert ops[0].operation_name == "install"
        # The request set schema_prefix explicitly, so it is recorded as
        # explicit; params_json keeps the request-time resolution.
        params = json.loads(ops[0].params_json)
        assert params["explicit_convention_keys"] == ["schema_prefix"]
        assert params["schema_prefix"] == "ecm_"

    def test_uninstall_creates_run_and_run_operation(
        self, client_with_agent, mock_ws, deployed_version, engine
    ):
        biz_id, vid, vint = deployed_version
        _ws_with_run_now(mock_ws, run_id=30303)

        resp = _post_runs(
            client_with_agent,
            biz_id,
            {
                "intent": "uninstall",
                "version_id": vid,
                "scope": "ecm",
                "version_int": vint,
                "catalog": "test_catalog",
                "deployment_catalog": "test_catalog",
                "cataloging_style": "One Catalog",
                "confirmed_issues": [uninstall_confirm_subject(vid, "test_catalog")],
            },
        )
        assert resp.status_code == 200, resp.text
        body = resp.json()
        assert body["warnings"] == []

        ops = _runops_for(engine, body["id"])
        assert len(ops) == 1
        assert ops[0].operation_name == "uninstall"

    def test_uninstall_dispatch_exposes_data_model_scopes_via_run_detail_api(
        self, client_with_agent, mock_ws, deployed_version, engine
    ):
        """Regression for the live bug: an uninstall dispatch carried
        ``data_model_scopes`` in the widget map sent to ``jobs.run_now()``,
        but the run detail API showed no way to see it — an operator had
        to go straight to the Databricks Jobs API to verify what was
        actually dispatched. ``GET .../runs/{id}/operations`` must expose
        the dispatched widget map, including ``data_model_scopes`` set to
        the correct value for the dispatched ``scope``.
        """
        biz_id, vid, vint = deployed_version
        _ws_with_run_now(mock_ws, run_id=30304)

        resp = _post_runs(
            client_with_agent,
            biz_id,
            {
                "intent": "uninstall",
                "version_id": vid,
                "scope": "ecm",
                "version_int": vint,
                "catalog": "test_catalog",
                "deployment_catalog": "test_catalog",
                "cataloging_style": "One Catalog",
                "confirmed_issues": [uninstall_confirm_subject(vid, "test_catalog")],
            },
        )
        assert resp.status_code == 200, resp.text
        run_id = resp.json()["id"]

        ops_resp = client_with_agent.get(
            f"/api/businesses/{biz_id}/runs/{run_id}/operations"
        )
        assert ops_resp.status_code == 200, ops_resp.text
        ops_body = ops_resp.json()
        assert len(ops_body) == 1
        widgets = ops_body[0]["dispatched_widgets"]
        assert widgets.get("data_model_scopes") == "Expanded Coverage Model - ECM", (
            f"expected the ECM scope label dispatched to run_now(), got {widgets!r}"
        )
        assert widgets.get("operation") == "uninstall model version"

    def test_install_without_schema_prefix_takes_the_files(
        self, client_with_agent, mock_ws, deployed_version, engine
    ):
        """The install forms don't expose a schema_prefix input. With none in
        the request the step takes the version's own (``prefix_from_version``)
        and dispatch sends the prefix of its model.json.

        Distinct from the explicit-empty case (covered by
        ``test_install_one_catalog_without_schema_prefix_returns_blocker``):
        explicit empty string is still rejected so curl callers that
        deliberately say "empty" hit the validator.
        """
        from ._lifecycle_fixtures import model_json_readable

        biz_id, vid, vint = deployed_version  # scope="ecm" in fixture
        _ws_with_run_now(mock_ws, run_id=20203)
        model_json_readable(mock_ws, "ecm_")

        resp = _post_runs(
            client_with_agent,
            biz_id,
            {
                "intent": "install",
                "version_id": vid,
                "scope": "ecm",
                "version_int": vint,
                "catalog": "test_catalog",
                "deployment_catalog": "test_catalog",
                # schema_prefix INTENTIONALLY OMITTED — the form-default
                # path the live walkthrough hit.
                "cataloging_style": "One Catalog",
            },
        )
        assert resp.status_code == 200, resp.text
        body = resp.json()
        # ``deployed_version`` is already deployed to this exact catalog -
        # the re-install clash warning fires here too (non-blocking; the
        # schema_prefix derivation this test targets is unaffected). See
        # TestDeployedVersionReinstallWarning for the dedicated coverage.
        assert len(body["warnings"]) == 1
        assert "already recorded as deployed" in body["warnings"][0]["message"]

        ops = _runops_for(engine, body["id"])
        assert len(ops) == 1
        params = json.loads(ops[0].params_json)
        assert params["prefix_from_version"] is True
        assert json.loads(ops[0].dispatched_widgets_json)["schema_prefix"] == "ecm_"
        # No convention key was set on the request.
        assert params["explicit_convention_keys"] == []

# ---------------------------------------------------------------------------
# 5. Bad business_id → 404 (or 400 with blocker telling the user).
# ---------------------------------------------------------------------------


class TestBadInputs:
    def test_unknown_business_id_returns_404(
        self, client_with_agent, mock_ws
    ):
        _ws_with_run_now(mock_ws)

        resp = _post_runs(
            client_with_agent,
            "does-not-exist",
            {
                "intent": "vibe-iterate",
                "parent_version_id": "also-fake",
                "vibe_instructions": "irrelevant",
                "catalog": "test_catalog",
            },
        )
        # Per the design doc the wirer should refuse — 404 (Business
        # missing) or 400 (validator blocker).  Either is acceptable;
        # 200 is not.  Both legacy and Phase-4 paths must satisfy this
        # invariant — this test pins shared behaviour, not a wirer-only
        # contract.
        assert resp.status_code in (400, 404), resp.text

    # --------------------- 7.  Bad params → 400 with blockers ----------------

    def test_install_one_catalog_without_schema_prefix_returns_blocker(
        self, client_with_agent, mock_ws, deployed_version
    ):
        """Cross-field rule from ``InstallParams._schema_prefix_matches_cataloging_style``:
        ``One Catalog`` requires a non-empty ``schema_prefix``.
        """
        biz_id, vid, vint = deployed_version
        _ws_with_run_now(mock_ws)

        resp = _post_runs(
            client_with_agent,
            biz_id,
            {
                "intent": "install",
                "version_id": vid,
                "scope": "ecm",
                "version_int": vint,
                "catalog": "test_catalog",
                "deployment_catalog": "test_catalog",
                "schema_prefix": "",  # empty — invalid for One Catalog
                "cataloging_style": "One Catalog",
            },
        )
        assert resp.status_code == 400, resp.text
        # Body must surface the blocker so the form can render it.
        body = resp.json()
        # Conventional FastAPI error envelope is "detail"; design doc
        # §2.4 shows ``detail = {"blockers": [...], "warnings": [...]}``
        # for the validator path.
        assert "detail" in body
        detail = body["detail"]
        # Either a structured envelope OR a string mentioning schema_prefix.
        if isinstance(detail, dict):
            blockers = detail.get("blockers", [])
            assert blockers, f"expected a blocker, got {detail!r}"
            # At least one blocker mentions schema_prefix or cataloging.
            messages = " ".join(
                str(b.get("message", "")) for b in blockers if isinstance(b, dict)
            ).lower()
            assert (
                "schema_prefix" in messages or "cataloging" in messages
            ), f"blockers didn't mention schema_prefix: {blockers!r}"
        else:
            assert "schema_prefix" in str(detail).lower() or "cataloging" in str(detail).lower()

    def test_install_catalog_per_division_with_schema_prefix_returns_blocker(
        self, client_with_agent, mock_ws, deployed_version
    ):
        """Inverse rule: non-One-Catalog styles forbid ``schema_prefix``."""
        biz_id, vid, vint = deployed_version
        _ws_with_run_now(mock_ws)

        resp = _post_runs(
            client_with_agent,
            biz_id,
            {
                "intent": "install",
                "version_id": vid,
                "scope": "ecm",
                "version_int": vint,
                "catalog": "test_catalog",
                "deployment_catalog": "test_catalog",
                "schema_prefix": "ecm_",  # set — invalid for Catalog per Division
                "cataloging_style": "Catalog per Division",
            },
        )
        assert resp.status_code == 400, resp.text

    def test_vibe_iterate_blank_instructions_returns_blocker(
        self, client_with_agent, mock_ws, parent_version_for_vibe
    ):
        """``VibeIterateParams._reject_blank_vibe_instructions`` rejects
        whitespace-only text.  The wirer should surface this as a blocker."""
        biz_id, parent_vid = parent_version_for_vibe
        _ws_with_run_now(mock_ws)

        resp = _post_runs(
            client_with_agent,
            biz_id,
            {
                "intent": "vibe-iterate",
                "parent_version_id": parent_vid,
                "vibe_instructions": "   ",  # whitespace — Pydantic blocks
                "catalog": "test_catalog",
                "business_context_path": "/Volumes/test/ctx/vibes/ctx.json",
            },
        )
        assert resp.status_code == 400, resp.text


# ---------------------------------------------------------------------------
# 8. Validation warnings only → run still created, warnings echoed back.
# ---------------------------------------------------------------------------


class TestWarningsAreNonBlocking:
    def test_warnings_create_run_and_are_echoed(
        self, client_with_agent, mock_ws, parent_version_for_vibe, engine
    ):
        """Per design doc §2.4 + §2.4.1, ``warning`` issues do NOT reject
        the request — the Run is created with the form-submitted values
        persisted, and the warnings flow through to ``RunOut.warnings``.

        We monkey-patch the validator with a stub that emits a single
        warning + no blockers.  The route handler MUST still create the
        Run + RunOperation row and echo the warning.
        """
        biz_id, parent_vid = parent_version_for_vibe
        _ws_with_run_now(mock_ws, run_id=70707)

        from vibe_modeling.backend.services.orchestrator import validate as _validate
        from vibe_modeling.backend.services.orchestrator._types import Issue

        # STUB-FOR-INTEGRATION: the wirer calls into either ``validate_dag``
        # or a higher-level ``validate_dag_request``.  Patch the lower
        # primitive — the test passes if EITHER hook is reachable; we
        # only care that warnings flow through.
        original = _validate.validate_dag

        def _validate_dag_with_warning(dag, *, registry_get):
            result = original(dag, registry_get=registry_get)
            return _validate.ValidationResult(
                dag=result.dag,
                blockers=result.blockers,
                warnings=[
                    Issue(
                        field_path="vibe_instructions",
                        step_index=0,
                        message="Marginal length — review before submit",
                        severity="warning",
                    )
                ],
            )

        _validate.validate_dag = _validate_dag_with_warning  # type: ignore[assignment]
        try:
            resp = _post_runs(
                client_with_agent,
                biz_id,
                {
                    "intent": "vibe-iterate",
                    "parent_version_id": parent_vid,
                    "vibe_instructions": "Add HR tables",
                    "catalog": "test_catalog",
                    "business_context_path": "/Volumes/test/ctx/vibes/ctx.json",
                },
            )
        finally:
            _validate.validate_dag = original  # type: ignore[assignment]

        # Run still created + warnings surfaced.
        assert resp.status_code == 200, resp.text
        body = resp.json()
        assert "warnings" in body
        # Warnings list non-empty AND mentions our injected message.
        assert any(
            "marginal" in str(w.get("message", "")).lower()
            for w in body["warnings"]
            if isinstance(w, dict)
        ), f"expected injected warning to flow through, got {body['warnings']!r}"

        # Run row persisted, RunOperation row persisted.
        run = _run_row(engine, body["id"])
        assert run is not None
        assert run.intent == "vibe-iterate"
        ops = _runops_for(engine, body["id"])
        assert len(ops) == 1


# ---------------------------------------------------------------------------
# 9.  DAG factories: each intent produces a 1-step DAG with the right name.
# ---------------------------------------------------------------------------


class TestDagFactories:
    """Each factory returns ``Dag(intent=<intent>, steps=(OperationStep(...),))``
    where the single step has the matching primitive name and Pydantic-valid
    params (a snapshot of the form-submitted values)."""

    def test_dag_for_vibe_iterate_returns_one_step(
        self, engine, parent_version_for_vibe
    ):
        from vibe_modeling.backend.services.orchestrator.dag import Dag

        biz_id, parent_vid = parent_version_for_vibe
        with Session(engine) as session:
            business = session.get(Business, biz_id)
            assert business is not None

            factory = _resolve_factory("dag_for_vibe_iterate")
            # The factory contract is "build the Dag from a request +
            # the seeded business".  Phase 4 will refine the request
            # type — we pass a duck-typed dict that any sensible
            # constructor can ``getattr`` or ``__getitem__`` against.
            dag = _safe_call_factory(
                factory,
                {
                    "intent": "vibe-iterate",
                    "parent_version_id": parent_vid,
                    "vibe_instructions": "Add HR tables",
                    "deployment_catalog": "test_catalog",
                    "catalog": "test_catalog",
                    "model_size": "small model",
                    "generate_samples": False,
                },
                business=business,
                session=session,
            )

        assert isinstance(dag, Dag), f"factory returned {type(dag).__name__}"
        assert len(dag.steps) == 1
        assert dag.steps[0].name == "vibe_iterate"
        # Per spec §3 example: the intent on the Dag is human-readable.
        assert dag.intent in ("vibe-iterate", "vibe_iterate")

    def test_dag_for_install_returns_one_step(
        self, engine, deployed_version
    ):
        from vibe_modeling.backend.services.orchestrator.dag import Dag

        biz_id, vid, vint = deployed_version
        with Session(engine) as session:
            business = session.get(Business, biz_id)
            factory = _resolve_factory("dag_for_install")
            dag = _safe_call_factory(
                factory,
                {
                    "intent": "install",
                    "version_id": vid,
                    "scope": "ecm",
                    "version_int": vint,
                    "deployment_catalog": "test_catalog",
                    "catalog": "test_catalog",
                    "schema_prefix": "ecm_",
                    "cataloging_style": "One Catalog",
                },
                business=business,
                session=session,
            )

        assert isinstance(dag, Dag)
        assert len(dag.steps) == 1
        assert dag.steps[0].name == "install"
        # The DAG factory must propagate the user's scope down into
        # ``OperationStep.params['scope']`` — that's the only place
        # the install primitive learns ECM vs MVM.
        assert dag.steps[0].params.get("scope") == "ecm"

    def test_dag_for_install_ui_request_has_no_explicit_convention_keys(
        self, engine, deployed_version
    ):
        """The UI sends only ``{intent, version_id}``: no convention key
        is explicit, so a ``_vibe_scope`` file's values win at dispatch.
        The factory's own resolution is unchanged."""
        biz_id, vid, vint = deployed_version
        with Session(engine) as session:
            business = session.get(Business, biz_id)
            dag = _safe_call_factory(
                _resolve_factory("dag_for_install"),
                {"intent": "install", "version_id": vid},
                business=business,
                session=session,
            )
        params = dag.steps[0].params
        assert params["explicit_convention_keys"] == []
        assert params["naming_convention"] == "snake_case"
        assert params["primary_key_suffix"] == "_id"
        assert params["table_id_type"] == "BIGINT"
        assert "schema_suffix" not in params
        assert "tag_prefix" not in params

    def test_dag_for_install_lists_explicit_convention_keys(
        self, engine, deployed_version
    ):
        biz_id, vid, vint = deployed_version
        with Session(engine) as session:
            business = session.get(Business, biz_id)
            dag = _safe_call_factory(
                _resolve_factory("dag_for_install"),
                {
                    "intent": "install",
                    "version_id": vid,
                    "schema_prefix": "ecm_",
                    "naming_convention": "camelCase",
                    "table_id_type": "INT",
                    "tag_prefix": "acme_",
                    "schema_suffix": None,
                    "tag_suffix": "_t",
                },
                business=business,
                session=session,
            )
        params = dag.steps[0].params
        assert sorted(params["explicit_convention_keys"]) == [
            "naming_convention",
            "schema_prefix",
            "table_id_type",
            "tag_prefix",
        ]
        # An explicit tag_prefix rides along in the params so it beats a
        # scoped file's value at dispatch; ordinary installs drop it there
        # (test_primitives_install::
        # test_ordinary_file_drops_explicit_suffix_and_tag_prefix).
        # The unset schema_suffix is not carried.
        assert params["tag_prefix"] == "acme_"
        assert "schema_suffix" not in params
        assert "tag_suffix" not in params

    def test_dag_for_install_empty_string_fields_are_not_explicit(
        self, engine, deployed_version
    ):
        """``""`` counts as unset: the factory replaces it with the
        default, so it must not block a scoped file's value either."""
        biz_id, vid, vint = deployed_version
        with Session(engine) as session:
            business = session.get(Business, biz_id)
            dag = _safe_call_factory(
                _resolve_factory("dag_for_install"),
                {
                    "intent": "install",
                    "version_id": vid,
                    "naming_convention": "",
                    "primary_key_suffix": "",
                    "table_id_type": "",
                    "schema_suffix": "",
                    "tag_prefix": "",
                },
                business=business,
                session=session,
            )
        params = dag.steps[0].params
        assert params["explicit_convention_keys"] == []
        assert params["naming_convention"] == "snake_case"
        assert params["primary_key_suffix"] == "_id"
        assert params["table_id_type"] == "BIGINT"
        assert "schema_suffix" not in params
        assert "tag_prefix" not in params

    def test_dag_for_uninstall_returns_one_step(
        self, engine, deployed_version
    ):
        from vibe_modeling.backend.services.orchestrator.dag import Dag

        biz_id, vid, vint = deployed_version
        with Session(engine) as session:
            business = session.get(Business, biz_id)
            factory = _resolve_factory("dag_for_uninstall")
            dag = _safe_call_factory(
                factory,
                {
                    "intent": "uninstall",
                    "version_id": vid,
                    "scope": "ecm",
                    "version_int": vint,
                    "deployment_catalog": "test_catalog",
                    "catalog": "test_catalog",
                    "cataloging_style": "One Catalog",
                },
                business=business,
                session=session,
            )

        assert isinstance(dag, Dag)
        assert len(dag.steps) == 1
        assert dag.steps[0].name == "uninstall"

# ---------------------------------------------------------------------------
# 10. Per-primitive: dag.validate_cross_step() returns no issues for happy
#     inputs (the 1-step DAGs trivially have no cross-step rules to fail).
# ---------------------------------------------------------------------------


class TestPerPrimitiveCrossStep:
    def test_vibe_iterate_no_cross_step_issues(
        self, engine, parent_version_for_vibe
    ):
        biz_id, parent_vid = parent_version_for_vibe
        with Session(engine) as session:
            business = session.get(Business, biz_id)
            factory = _resolve_factory("dag_for_vibe_iterate")
            dag = _safe_call_factory(
                factory,
                {
                    "intent": "vibe-iterate",
                    "parent_version_id": parent_vid,
                    "vibe_instructions": "Add HR tables",
                    "deployment_catalog": "test_catalog",
                    "catalog": "test_catalog",
                },
                business=business,
                session=session,
            )
        assert dag.validate_cross_step() == []

    def test_install_no_cross_step_issues(self, engine, deployed_version):
        biz_id, vid, vint = deployed_version
        with Session(engine) as session:
            business = session.get(Business, biz_id)
            factory = _resolve_factory("dag_for_install")
            dag = _safe_call_factory(
                factory,
                {
                    "intent": "install",
                    "version_id": vid,
                    "scope": "ecm",
                    "version_int": vint,
                    "deployment_catalog": "test_catalog",
                    "catalog": "test_catalog",
                    "schema_prefix": "ecm_",
                    "cataloging_style": "One Catalog",
                },
                business=business,
                session=session,
            )
        assert dag.validate_cross_step() == []

    def test_uninstall_no_cross_step_issues(self, engine, deployed_version):
        biz_id, vid, vint = deployed_version
        with Session(engine) as session:
            business = session.get(Business, biz_id)
            factory = _resolve_factory("dag_for_uninstall")
            dag = _safe_call_factory(
                factory,
                {
                    "intent": "uninstall",
                    "version_id": vid,
                    "scope": "ecm",
                    "version_int": vint,
                    "deployment_catalog": "test_catalog",
                    "catalog": "test_catalog",
                    "cataloging_style": "One Catalog",
                },
                business=business,
                session=session,
            )
        assert dag.validate_cross_step() == []

# ---------------------------------------------------------------------------
# 11. Edge cases: missing required field, unknown intent, parallel runs.
# ---------------------------------------------------------------------------


class TestEdgeCases:
    def test_unknown_business_id_returns_404(
        self, client_with_agent, mock_ws
    ):
        """``business_id`` is now a URL path parameter (no longer a body
        field). Hitting ``/api/businesses/<does-not-exist>/runs`` resolves
        to a 404 once the ``Business`` lookup fails inside ``create_run``.
        Previously this asserted 422 because ``business_id`` was a
        required RunIn body field; the move to nested routes makes that
        contract obsolete — body validation can't detect the missing bid
        because the URL provides one (even if it points at no row)."""
        _ws_with_run_now(mock_ws)
        resp = client_with_agent.post(
            "/api/businesses/does-not-exist/runs",
            json={"intent": "vibe-iterate", "vibe_instructions": "x"},
        )
        assert resp.status_code == 404, resp.text
        assert "Business not found" in resp.text

    def test_unknown_intent_returns_400(
        self, client_with_agent, mock_ws, seed_business
    ):
        _ws_with_run_now(mock_ws)
        resp = _post_runs(
            client_with_agent,
            seed_business,
            {
                "intent": "warp-the-fabric-of-spacetime",
                "catalog": "test_catalog",
            },
        )
        # Either 400 (the wirer rejects unknown intent strings) or 422
        # (Pydantic enum constraint catches it before the handler runs).
        assert resp.status_code in (400, 422), resp.text

    def test_two_intents_for_different_businesses_create_independent_runs(
        self, client_with_agent, mock_ws, engine
    ):
        """The per-business in-flight lock is a real constraint.  Two
        DIFFERENT businesses should both succeed without racing — each
        run's RunOperation rows are isolated."""
        _ws_with_run_now(mock_ws, run_id=80808)

        # Two businesses + a deployed version each.
        with Session(engine) as session:
            b1 = Business(name="biz-one", description="", industry_alignment="")
            b2 = Business(name="biz-two", description="", industry_alignment="")
            session.add(b1)
            session.add(b2)
            session.commit()
            session.refresh(b1)
            session.refresh(b2)

            for b in (b1, b2):
                mv = ModelVersion(
                    business_id=b.id,
                    version=1,
                    status="completed",
                    deployment_status="deployed",
                    scope="ecm",
                    uc_catalog="test_catalog",
                )
                session.add(mv)
            session.commit()
            v1 = session.exec(
                select(ModelVersion).where(ModelVersion.business_id == b1.id)
            ).first()
            v2 = session.exec(
                select(ModelVersion).where(ModelVersion.business_id == b2.id)
            ).first()
            b1_id, b2_id = b1.id, b2.id
            v1_id, v1_int = v1.id, v1.version
            v2_id, v2_int = v2.id, v2.version

        resp1 = _post_runs(
            client_with_agent,
            b1_id,
            {
                "intent": "uninstall",
                "version_id": v1_id,
                "scope": "ecm",
                "version_int": v1_int,
                "deployment_catalog": "test_catalog",
                "catalog": "test_catalog",
                "cataloging_style": "One Catalog",
                "confirmed_issues": [uninstall_confirm_subject(v1_id, "test_catalog")],
            },
        )
        resp2 = _post_runs(
            client_with_agent,
            b2_id,
            {
                "intent": "uninstall",
                "version_id": v2_id,
                "scope": "ecm",
                "version_int": v2_int,
                "deployment_catalog": "test_catalog",
                "catalog": "test_catalog",
                "cataloging_style": "One Catalog",
                "confirmed_issues": [uninstall_confirm_subject(v2_id, "test_catalog")],
            },
        )
        assert resp1.status_code == 200, resp1.text
        assert resp2.status_code == 200, resp2.text

        ops1 = _runops_for(engine, resp1.json()["id"])
        ops2 = _runops_for(engine, resp2.json()["id"])
        assert len(ops1) == 1 and ops1[0].operation_name == "uninstall"
        assert len(ops2) == 1 and ops2[0].operation_name == "uninstall"
        # Verify independence: each run owns its own RunOperation row.
        assert ops1[0].run_id != ops2[0].run_id


# ---------------------------------------------------------------------------
# 12. RunOut shape: every happy-path response carries ``warnings``.
# ---------------------------------------------------------------------------


class TestRunOutShape:
    def test_run_out_always_has_warnings_field(
        self, client_with_agent, mock_ws, deployed_version
    ):
        """Per design doc §2.4 + §8: ``RunOut.warnings`` is a non-optional
        list — empty on the trivial happy path, populated when the
        validator emitted warning-severity issues."""
        biz_id, vid, vint = deployed_version
        _ws_with_run_now(mock_ws, run_id=90909)

        resp = _post_runs(
            client_with_agent,
            biz_id,
            {
                "intent": "uninstall",
                "version_id": vid,
                "scope": "ecm",
                "version_int": vint,
                "deployment_catalog": "test_catalog",
                "catalog": "test_catalog",
                "cataloging_style": "One Catalog",
                "confirmed_issues": [uninstall_confirm_subject(vid, "test_catalog")],
            },
        )
        assert resp.status_code == 200, resp.text
        body = resp.json()
        # Field present, list-typed, defaults to [].
        assert "warnings" in body
        assert isinstance(body["warnings"], list)


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def _safe_call_factory(factory, request_dict: dict, *, business: Any, session: Any):
    """Try a few plausible factory signatures.

    Phase 4's exact signature isn't pinned by the design doc — it cites
    ``dag_for_new_base_model(req, business)`` as illustrative.  We
    attempt:

    1. ``factory(req_dict, business)``
    2. ``factory(req_dict, business, session)``
    3. ``factory(req_dict)``
    4. ``factory(**req_dict, business=business)``

    On each we treat a TypeError as "wrong signature, try the next" but
    let the factory's own validation/raise propagate.  The caller sees
    a clear failure if every signature is rejected.
    """
    # Wrap the dict into a SimpleNamespace so factories that do
    # ``req.business_id`` get attribute access too.
    from types import SimpleNamespace

    req_ns = SimpleNamespace(**request_dict)

    attempts: list[tuple[tuple, dict]] = [
        ((req_ns, business), {}),
        ((req_ns, business, session), {}),
        ((request_dict, business), {}),
        ((request_dict, business, session), {}),
        ((req_ns,), {"business": business}),
        ((req_ns,), {"business": business, "session": session}),
        ((req_ns,), {}),
        ((request_dict,), {}),
    ]
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
# dag_for_install: import_source_path → context_file_candidates
# ---------------------------------------------------------------------------


class TestInstallDagContextFileOverride:
    """Locks the v0.4.0 install BLOCKER fix surfaced by the 2026-05-18
    walkthrough: the install DAG factory MUST consult
    ``ModelVersion.import_source_path`` and pass it first through the
    install step's ``context_file_candidates`` param. Without this, imported and
    reference-seeded versions crash at install with "Model JSON File not
    found" on the constructed convention path."""

    def test_install_passes_import_source_path_when_set(
        self, client_with_agent, mock_ws, seed_business, engine
    ):
        """Imported version with import_source_path set → flows through."""
        with Session(engine) as session:
            mv = ModelVersion(
                business_id=seed_business,
                version=1,
                status="completed",
                deployment_status="draft",
                scope="mvm",
                uc_catalog="vibe_modeling_test",
                import_source_path=(
                    "/Volumes/vibe_modeling_test/_metamodel/vol_root/"
                    "walkthrough_2026_05_18/import_test/model.json"
                ),
            )
            session.add(mv)
            session.commit()
            session.refresh(mv)
            vid, vint = mv.id, mv.version

        _ws_with_run_now(mock_ws, run_id=42424)
        resp = _post_runs(
            client_with_agent, seed_business,
            {
                "intent": "install",
                "version_id": vid,
                "scope": "mvm",
                "version_int": vint,
                "catalog": "vibe_modeling_test",
                "deployment_catalog": "vibe_modeling_test",
                "schema_prefix": "mvm_",
                "cataloging_style": "One Catalog",
            },
        )
        assert resp.status_code == 200, resp.text
        ops = _runops_for(engine, resp.json()["id"])
        assert len(ops) == 1
        params = json.loads(ops[0].params_json)
        assert params["context_file_candidates"][0] == (
            "/Volumes/vibe_modeling_test/_metamodel/vol_root/"
            "walkthrough_2026_05_18/import_test/model.json"
        )

    def test_install_passes_only_the_canonical_paths_when_import_source_path_absent(
        self, client_with_agent, mock_ws, deployed_version, engine
    ):
        """Agent-produced version (import_source_path NULL) → only the
        canonical nested and flat paths are candidates."""
        biz_id, vid, vint = deployed_version
        _ws_with_run_now(mock_ws, run_id=42425)
        resp = _post_runs(
            client_with_agent, biz_id,
            {
                "intent": "install",
                "version_id": vid,
                "scope": "ecm",
                "version_int": vint,
                "catalog": "test_catalog",
                "deployment_catalog": "test_catalog",
                "schema_prefix": "ecm_",
                "cataloging_style": "One Catalog",
            },
        )
        assert resp.status_code == 200, resp.text
        ops = _runops_for(engine, resp.json()["id"])
        assert len(ops) == 1
        params = json.loads(ops[0].params_json)
        candidates = params["context_file_candidates"]
        assert len(candidates) == 2
        assert all(p.startswith("/Volumes/") and p.endswith("/model.json") for p in candidates)


# ---------------------------------------------------------------------------
# Deployed-version re-install clash warning (0.6.6 smalls item 6 /
# an internal tracker item).
#
# An install run whose target ModelVersion is already recorded
# deployment_status="deployed" for the exact catalog being installed to
# would otherwise dispatch the agent and burn ~6 minutes of compute before
# the agent's own clash guard rejects it. The gate lives in
# ``deployed_version_reinstall_warning`` (services/orchestrator/validate.py)
# and is called once, by the shared ``run_preflight``, whose warnings feed
# both ``POST /runs/validate`` and ``RunOut.warnings`` on the actual
# ``POST /runs`` submit - non-blocking in both cases, since re-install after an out-of-band ``DROP SCHEMA`` (or a
# stale reconcile read) is a legitimate workflow.
# ---------------------------------------------------------------------------


class TestDeployedVersionReinstallWarning:
    def test_install_deployed_version_warns_but_still_creates_run(
        self, client_with_agent, mock_ws, deployed_version, engine
    ):
        """Test 1: a deployed version + install intent surfaces the warning
        on the create-run response AND the run is still created (never
        blocked)."""
        biz_id, vid, vint = deployed_version  # deployment_status="deployed",
        # uc_catalog="test_catalog" per the fixture.
        _ws_with_run_now(mock_ws, run_id=50505)

        resp = _post_runs(
            client_with_agent,
            biz_id,
            {
                "intent": "install",
                "version_id": vid,
                "scope": "ecm",
                "version_int": vint,
                "catalog": "test_catalog",
                "deployment_catalog": "test_catalog",
                "schema_prefix": "ecm_",
                "cataloging_style": "One Catalog",
            },
        )
        assert resp.status_code == 200, resp.text
        body = resp.json()
        assert body["warnings"] == [
            {
                "field_path": "version_id",
                "step_index": -1,
                "message": (
                    "This version is already recorded as deployed to "
                    "test_catalog; re-installing without uninstalling "
                    "first will fail the agent's clash check."
                ),
                "severity": "warning",
                "subject": None,
                "versions": [],
            }
        ]

        # The run was NOT blocked - a RunOperation row exists and the Run
        # row is persisted.
        ops = _runops_for(engine, body["id"])
        assert len(ops) == 1
        assert ops[0].operation_name == "install"
        assert _run_row(engine, body["id"]) is not None

    def test_install_draft_version_has_no_warning(
        self, client_with_agent, mock_ws, engine, seed_business
    ):
        """Test 2: a draft (non-deployed) version + install intent surfaces
        no such warning."""
        with Session(engine) as session:
            mv = ModelVersion(
                business_id=seed_business,
                version=1,
                status="completed",
                deployment_status="draft",
                scope="ecm",
                uc_catalog="",
            )
            session.add(mv)
            session.commit()
            session.refresh(mv)
            vid, vint = mv.id, mv.version

        _ws_with_run_now(mock_ws, run_id=50506)
        resp = _post_runs(
            client_with_agent,
            seed_business,
            {
                "intent": "install",
                "version_id": vid,
                "scope": "ecm",
                "version_int": vint,
                "catalog": "test_catalog",
                "deployment_catalog": "test_catalog",
                "schema_prefix": "ecm_",
                "cataloging_style": "One Catalog",
            },
        )
        assert resp.status_code == 200, resp.text
        assert resp.json()["warnings"] == []

    def test_install_deployed_to_a_different_catalog_has_no_warning(
        self, client_with_agent, mock_ws, deployed_version, engine
    ):
        """A version deployed to catalog A, now being installed into
        catalog B, is a legitimate multi-catalog install, not a clash,
        so no warning fires."""
        biz_id, vid, vint = deployed_version  # uc_catalog="test_catalog"
        _ws_with_run_now(mock_ws, run_id=50507)

        resp = _post_runs(
            client_with_agent,
            biz_id,
            {
                "intent": "install",
                "version_id": vid,
                "scope": "ecm",
                "version_int": vint,
                "catalog": "other_catalog",
                "deployment_catalog": "other_catalog",
                "schema_prefix": "ecm_",
                "cataloging_style": "One Catalog",
            },
        )
        assert resp.status_code == 200, resp.text
        assert resp.json()["warnings"] == []

    def test_validate_run_surfaces_the_same_warning(
        self, client_with_agent, deployed_version
    ):
        """The live-form ``POST /runs/validate`` preview (what the FE's
        debounced warnings renderer reads) surfaces the identical warning,
        via the shared ``run_preflight``."""
        biz_id, vid, vint = deployed_version

        resp = client_with_agent.post(
            f"/api/businesses/{biz_id}/runs/validate",
            json={
                "intent": "install",
                "version_id": vid,
                "scope": "ecm",
                "version_int": vint,
                "catalog": "test_catalog",
                "deployment_catalog": "test_catalog",
                "schema_prefix": "ecm_",
                "cataloging_style": "One Catalog",
            },
        )
        assert resp.status_code == 200, resp.text
        body = resp.json()
        assert any(
            "already recorded as deployed" in w.get("message", "")
            for w in body.get("warnings", [])
        ), body
        # Non-blocking: validate must not turn this into a blocker.
        assert not any(
            "already recorded as deployed" in b.get("message", "")
            for b in body.get("blockers", [])
        )

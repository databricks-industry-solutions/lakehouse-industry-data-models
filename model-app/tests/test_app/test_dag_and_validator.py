"""Phase 1 — DAG + validator contract tests.

These tests exercise the public surface only:

- ``Dag.validate_cross_step`` — cross-step invariants.
- ``services.orchestrator.validate.validate_dag`` — coordinator that
  walks a DAG, runs each step's ``params_model``, and collects issues.
- ``Intent`` enum — string round-trip.

A small fake registry replaces the real ``services.operations`` lookup
so tests don't depend on the parallel ``phase1/operation-protocol``
slice.
"""

from typing import Optional

import pytest
from pydantic import BaseModel, Field

from vibe_modeling.backend.models import Intent
from vibe_modeling.backend.services.orchestrator.dag import (
    Dag,
    OperationStep,
)
from vibe_modeling.backend.services.orchestrator.validate import (
    ValidationResult,
    validate_dag,
)


# --- Fake registry helpers ---------------------------------------------------


class _AcceptAnythingParams(BaseModel):
    """Pydantic model that accepts any kwargs — used by happy-path
    tests that don't care about per-field rules."""

    model_config = {"extra": "allow"}


class _RequiresBusinessName(BaseModel):
    """Pydantic model that requires a non-empty string ``business_name``.
    Drives the bad-params test — emits one Pydantic ``ValidationError``
    per missing/invalid field."""

    business_name: str = Field(min_length=1)


class _FakeOp:
    """Stand-in for the real ``Operation`` ABC.

    ``validate_dag`` reads ``params_model`` and ``produces_version`` —
    tests construct ``_FakeOp(params_model=..., produces_version=...)``
    and stash them in a dict. ``produces_version`` defaults to ``False``
    so the existing tests (which only care about params validation) keep
    working without changes; the duplicate-output rule below sets it
    explicitly.
    """

    def __init__(
        self,
        name: str,
        params_model: type[BaseModel],
        produces_version: bool = False,
    ):
        self.name = name
        self.params_model = params_model
        self.produces_version = produces_version


def _make_registry(ops: dict[str, _FakeOp]):
    """Return a ``registry_get(name)`` callable backed by ``ops``."""

    def _get(name: str):
        try:
            return ops[name]
        except KeyError:
            # Same shape as the real registry — see
            # services/operations/_registry.py.
            raise KeyError(name)

    return _get


# --- Dag.validate_cross_step -------------------------------------------------


class TestValidateCrossStep:
    """Cross-step invariants: ``needs_version_from`` references."""

    def test_linear_ecm_install_mvm_install_has_no_issues(self):
        """Happy path mirroring the legacy 4-phase DAG (spec §3): each
        ``needs_version_from`` points at a unique prior step."""
        dag = Dag(
            intent="new-base-model",
            steps=(
                OperationStep("generate_ecm", {}),
                OperationStep(
                    "install",
                    {"scope": "ecm"},
                    needs_version_from="generate_ecm",
                ),
                OperationStep(
                    "shrink_to_mvm",
                    {},
                    needs_version_from="generate_ecm",
                ),
                OperationStep(
                    "install",
                    {"scope": "mvm"},
                    needs_version_from="shrink_to_mvm",
                ),
            ),
        )

        assert dag.validate_cross_step() == []

    def test_needs_version_from_pointing_at_future_step_is_blocker(self):
        """A step at index 0 cannot inherit a version from a step at
        index 1 — at dispatch time the later step has not run."""
        dag = Dag(
            intent="vibe-iterate",
            steps=(
                OperationStep(
                    "shrink_to_mvm",
                    {},
                    needs_version_from="generate_ecm",
                ),
                OperationStep("generate_ecm", {}),
            ),
        )

        issues = dag.validate_cross_step()

        assert len(issues) == 1
        assert issues[0].severity == "blocker"
        assert issues[0].step_index == 0
        assert issues[0].field_path == "steps[0].needs_version_from"
        assert "generate_ecm" in issues[0].message

    def test_needs_version_from_pointing_at_unknown_name_is_blocker(self):
        """Reference to a step name that does not appear anywhere in
        the DAG."""
        dag = Dag(
            intent="new-base-model",
            steps=(
                OperationStep("generate_ecm", {}),
                OperationStep(
                    "install",
                    {"scope": "ecm"},
                    needs_version_from="nonexistent_step",
                ),
            ),
        )

        issues = dag.validate_cross_step()

        assert len(issues) == 1
        assert issues[0].severity == "blocker"
        assert issues[0].step_index == 1
        assert "nonexistent_step" in issues[0].message

    def test_ambiguous_prior_step_name_is_blocker(self):
        """Two prior steps share a name → orchestrator cannot decide
        which output_version_id to inherit."""
        dag = Dag(
            intent="new-base-model",
            steps=(
                OperationStep("generate_ecm", {}),
                OperationStep("generate_ecm", {}),
                OperationStep(
                    "install",
                    {"scope": "ecm"},
                    needs_version_from="generate_ecm",
                ),
            ),
        )

        issues = dag.validate_cross_step()

        assert len(issues) == 1
        assert issues[0].severity == "blocker"
        assert issues[0].step_index == 2
        assert "Ambiguous" in issues[0].message
        # Surfaces the count so the operator sees how many duplicates
        # exist — useful when the DAG is long.
        assert "2" in issues[0].message


# --- validate_dag ------------------------------------------------------------


class TestValidateDag:
    """Top-level ``validate_dag`` — registry lookup + Pydantic + cross-step."""

    def test_unknown_step_name_yields_blocker(self):
        """A step whose ``name`` is not in the registry produces a
        blocker. The validator does NOT then try to validate that
        step's params (no params_model to validate against)."""
        registry = _make_registry({})  # empty
        dag = Dag(
            intent="new-base-model",
            steps=(OperationStep("never_registered", {"foo": "bar"}),),
        )

        result = validate_dag(dag, registry_get=registry)

        assert result.dag is None
        assert result.warnings == []
        assert len(result.blockers) == 1
        assert result.blockers[0].severity == "blocker"
        assert result.blockers[0].step_index == 0
        assert result.blockers[0].field_path == "steps[0].name"
        assert "never_registered" in result.blockers[0].message

    def test_bad_params_yield_per_field_blockers(self):
        """A step whose params fail Pydantic validation produces one
        blocker per offending field, with ``field_path`` pointing into
        ``steps[i].params.<field>``."""
        registry = _make_registry(
            {
                "generate_ecm": _FakeOp(
                    "generate_ecm", _RequiresBusinessName
                ),
            }
        )
        dag = Dag(
            intent="new-base-model",
            # business_name is missing entirely → required-field error.
            steps=(OperationStep("generate_ecm", {}),),
        )

        result = validate_dag(dag, registry_get=registry)

        assert result.dag is None
        assert len(result.blockers) == 1
        b = result.blockers[0]
        assert b.severity == "blocker"
        assert b.step_index == 0
        assert b.field_path == "steps[0].params.business_name"

    def test_bad_params_with_multiple_fields_yields_multiple_blockers(self):
        """Pydantic emits one error per invalid field; validate_dag
        propagates each as its own blocker so the UI can render them
        individually next to each form field."""

        class _TwoFields(BaseModel):
            business_name: str = Field(min_length=1)
            schema_prefix: str = Field(min_length=1)

        registry = _make_registry(
            {"generate_ecm": _FakeOp("generate_ecm", _TwoFields)}
        )
        dag = Dag(
            intent="new-base-model",
            steps=(OperationStep("generate_ecm", {}),),
        )

        result = validate_dag(dag, registry_get=registry)

        assert result.dag is None
        field_paths = {b.field_path for b in result.blockers}
        assert field_paths == {
            "steps[0].params.business_name",
            "steps[0].params.schema_prefix",
        }

    def test_good_dag_returns_empty_blockers_and_carries_dag_through(self):
        """Happy path: every step name resolves, every params model
        accepts the input, and no cross-step rule fires."""
        registry = _make_registry(
            {
                "generate_ecm": _FakeOp(
                    "generate_ecm", _AcceptAnythingParams
                ),
                "install": _FakeOp("install", _AcceptAnythingParams),
                "shrink_to_mvm": _FakeOp(
                    "shrink_to_mvm", _AcceptAnythingParams
                ),
            }
        )
        dag = Dag(
            intent="new-base-model",
            steps=(
                OperationStep("generate_ecm", {"business_name": "acme"}),
                OperationStep(
                    "install",
                    {"scope": "ecm"},
                    needs_version_from="generate_ecm",
                ),
                OperationStep(
                    "shrink_to_mvm",
                    {},
                    needs_version_from="generate_ecm",
                ),
                OperationStep(
                    "install",
                    {"scope": "mvm"},
                    needs_version_from="shrink_to_mvm",
                ),
            ),
        )

        result = validate_dag(dag, registry_get=registry)

        assert isinstance(result, ValidationResult)
        assert result.blockers == []
        assert result.warnings == []
        assert result.dag is dag

    def test_cross_step_violation_is_reported_alongside_field_errors(self):
        """A DAG with both a missing required field AND a bad
        ``needs_version_from`` yields blockers for both — the validator
        must not short-circuit after the first finding."""
        registry = _make_registry(
            {
                "generate_ecm": _FakeOp(
                    "generate_ecm", _RequiresBusinessName
                ),
                "install": _FakeOp("install", _AcceptAnythingParams),
            }
        )
        dag = Dag(
            intent="new-base-model",
            steps=(
                # missing business_name → field blocker
                OperationStep("generate_ecm", {}),
                # references a later step → cross-step blocker
                OperationStep(
                    "install",
                    {},
                    needs_version_from="future_step",
                ),
            ),
        )

        result = validate_dag(dag, registry_get=registry)

        # Two distinct blockers from two different gates.
        assert result.dag is None
        kinds = {b.field_path for b in result.blockers}
        assert "steps[0].params.business_name" in kinds
        assert "steps[1].needs_version_from" in kinds


# --- Zero-step DAG -----------------------------------------------------------


class TestZeroStepDag:
    """A DAG with no steps produces a Run with no work — almost
    certainly a programming error in the factory. Per the orchestrator
    runner's own ``start()`` comment ("validators reject empty DAGs at
    create time"), this MUST be a blocker."""

    def test_empty_dag_is_blocker(self):
        """The base case: ``Dag(steps=())`` returns one DAG-level
        blocker pointing at ``steps`` with ``step_index=-1``."""
        dag = Dag(intent="new-base-model", steps=())

        issues = dag.validate_cross_step()

        assert len(issues) == 1
        assert issues[0].severity == "blocker"
        assert issues[0].field_path == "steps"
        assert issues[0].step_index == -1
        assert "zero" in issues[0].message.lower()

    def test_single_step_dag_does_not_trip_zero_step_rule(self):
        """The boundary: a one-step DAG is the smallest legal DAG. The
        zero-step rule must not fire."""
        dag = Dag(
            intent="install",
            steps=(OperationStep("install", {}),),
        )

        issues = dag.validate_cross_step()

        # Whatever issues appear, none of them should be the zero-step
        # blocker — that path returns early on an empty steps tuple.
        for issue in issues:
            assert issue.field_path != "steps"

    def test_validate_dag_rejects_empty_dag_with_no_dag_returned(self):
        """End-to-end: ``validate_dag`` on an empty DAG returns a
        ``ValidationResult`` whose ``dag`` is None (because there's a
        blocker) and whose blockers contain the zero-step finding. The
        coordinator must NOT short-circuit before the cross-step gate."""
        registry = _make_registry({})
        dag = Dag(intent="new-base-model", steps=())

        result = validate_dag(dag, registry_get=registry)

        assert result.dag is None
        zero_step_blockers = [
            b for b in result.blockers if "zero" in b.message.lower()
        ]
        assert len(zero_step_blockers) == 1


# --- skip_if step reference --------------------------------------------------


class TestSkipIfStepReference:
    """``skip_if`` predicates that use the ``<step>.<status>`` shape
    must reference a step name that appears elsewhere in the DAG."""

    def test_skip_if_references_existing_step_passes(self):
        """Happy path: ``skip_if="prep.failed"`` where ``prep`` is
        another step in the DAG produces no blocker."""
        dag = Dag(
            intent="new-base-model",
            steps=(
                OperationStep("prep", {}),
                OperationStep(
                    "install",
                    {},
                    skip_if="prep.failed",
                ),
            ),
        )

        issues = dag.validate_cross_step()

        # No skip_if blocker. (Other rules might still fire, but not
        # for this surface.)
        skip_if_issues = [i for i in issues if i.field_path.endswith(".skip_if")]
        assert skip_if_issues == []

    def test_skip_if_references_unknown_step_is_blocker(self):
        """``skip_if="ghost.failed"`` where ``ghost`` is not a step
        anywhere in the DAG — surface a blocker pointing at the
        offending step's ``skip_if`` field."""
        dag = Dag(
            intent="new-base-model",
            steps=(
                OperationStep("generate_ecm", {}),
                OperationStep(
                    "install",
                    {},
                    skip_if="ghost.failed",
                ),
            ),
        )

        issues = dag.validate_cross_step()

        skip_if_issues = [i for i in issues if i.field_path.endswith(".skip_if")]
        assert len(skip_if_issues) == 1
        assert skip_if_issues[0].severity == "blocker"
        assert skip_if_issues[0].step_index == 1
        assert skip_if_issues[0].field_path == "steps[1].skip_if"
        assert "ghost" in skip_if_issues[0].message

    def test_skip_if_with_inherited_param_predicate_is_not_a_step_ref(self):
        """Edge case: predicates like
        ``"cataloging_style != 'One Catalog'"`` reference inherited_params,
        not steps, and use no ``<step>.<status>`` shape. The rule must
        not flag them — they're not step references."""
        dag = Dag(
            intent="new-base-model",
            steps=(
                OperationStep(
                    "install",
                    {},
                    skip_if="cataloging_style != 'One Catalog'",
                ),
            ),
        )

        issues = dag.validate_cross_step()

        skip_if_issues = [i for i in issues if i.field_path.endswith(".skip_if")]
        assert skip_if_issues == []


# --- Duplicate output_version_id ---------------------------------------------


class TestDuplicateOutputVersionId:
    """Two version-producing steps that share a name would emit two
    ``output_version_id``s under one identifier — downstream lineage
    (``needs_version_from`` resolves by name) breaks silently. Lives in
    ``validate_dag`` because the rule needs the registry to know which
    primitives produce versions; non-producing primitives like
    ``install`` legitimately repeat in multi-catalog DAGs."""

    def test_two_distinct_producing_steps_are_fine(self):
        """Happy path: two version-producing steps with distinct names
        (``generate_ecm`` then ``shrink_to_mvm``) — no duplicate."""
        registry = _make_registry(
            {
                "generate_ecm": _FakeOp(
                    "generate_ecm",
                    _AcceptAnythingParams,
                    produces_version=True,
                ),
                "shrink_to_mvm": _FakeOp(
                    "shrink_to_mvm",
                    _AcceptAnythingParams,
                    produces_version=True,
                ),
            }
        )
        dag = Dag(
            intent="new-base-model",
            steps=(
                OperationStep("generate_ecm", {}),
                OperationStep(
                    "shrink_to_mvm",
                    {},
                    needs_version_from="generate_ecm",
                ),
            ),
        )

        result = validate_dag(dag, registry_get=registry)

        assert result.blockers == []
        assert result.dag is dag

    def test_two_producing_steps_with_same_name_is_blocker(self):
        """Two ``generate_ecm`` steps both produce a ModelVersion under
        the step name ``generate_ecm`` — a downstream
        ``needs_version_from="generate_ecm"`` cannot disambiguate."""
        registry = _make_registry(
            {
                "generate_ecm": _FakeOp(
                    "generate_ecm",
                    _AcceptAnythingParams,
                    produces_version=True,
                ),
            }
        )
        dag = Dag(
            intent="new-base-model",
            steps=(
                OperationStep("generate_ecm", {}),
                OperationStep("generate_ecm", {}),
            ),
        )

        result = validate_dag(dag, registry_get=registry)

        assert result.dag is None
        dup_blockers = [
            b
            for b in result.blockers
            if "Duplicate output_version_id" in b.message
        ]
        assert len(dup_blockers) == 1
        assert dup_blockers[0].step_index == 1
        assert dup_blockers[0].field_path == "steps[1].name"

    def test_two_non_producing_steps_with_same_name_are_fine(self):
        """Edge case: two ``install`` steps in a multi-catalog DAG (one
        for ECM scope, one for MVM scope) is the production-blessed
        shape from ``dag_for_new_base_model``. The rule must NOT fire on
        non-producing primitives."""
        registry = _make_registry(
            {
                "generate_ecm": _FakeOp(
                    "generate_ecm",
                    _AcceptAnythingParams,
                    produces_version=True,
                ),
                "install": _FakeOp(
                    "install",
                    _AcceptAnythingParams,
                    produces_version=False,
                ),
                "shrink_to_mvm": _FakeOp(
                    "shrink_to_mvm",
                    _AcceptAnythingParams,
                    produces_version=True,
                ),
            }
        )
        dag = Dag(
            intent="new-base-model",
            steps=(
                OperationStep("generate_ecm", {}),
                OperationStep(
                    "install",
                    {"scope": "ecm"},
                    needs_version_from="generate_ecm",
                ),
                OperationStep(
                    "shrink_to_mvm",
                    {},
                    needs_version_from="generate_ecm",
                ),
                OperationStep(
                    "install",
                    {"scope": "mvm"},
                    needs_version_from="shrink_to_mvm",
                ),
            ),
        )

        result = validate_dag(dag, registry_get=registry)

        # The two ``install`` steps share a name but neither produces a
        # version — the rule must not fire.
        dup_blockers = [
            b
            for b in result.blockers
            if "Duplicate output_version_id" in b.message
        ]
        assert dup_blockers == []


# --- inherited_params contradiction ------------------------------------------


class TestInheritedParamsContradiction:
    """When the DAG-level ``inherited_params`` sets a carry-key (e.g.
    ``cataloging_style``) AND a step's literal ``params`` sets a
    different value for the same key, the orchestrator can't honour
    both. The primitive sees two competing values — that's a blocker."""

    def test_matching_inherited_and_step_params_pass(self):
        """Happy path: ``inherited_params['cataloging_style'] = 'One Catalog'``
        and the step's ``params['cataloging_style']`` matches. No blocker."""
        dag = Dag(
            intent="new-base-model",
            steps=(
                OperationStep(
                    "generate_ecm",
                    {"cataloging_style": "One Catalog"},
                ),
            ),
            inherited_params={"cataloging_style": "One Catalog"},
        )

        issues = dag.validate_cross_step()

        ip_issues = [i for i in issues if "inherited_params" in i.message]
        assert ip_issues == []

    def test_contradicting_value_is_blocker(self):
        """``inherited_params['cataloging_style'] = 'One Catalog'`` and
        the step has ``params['cataloging_style'] = 'Catalog per Domain'``
        — surface one blocker pointing at the step's params field."""
        dag = Dag(
            intent="new-base-model",
            steps=(
                OperationStep(
                    "generate_ecm",
                    {"cataloging_style": "Catalog per Domain"},
                ),
            ),
            inherited_params={"cataloging_style": "One Catalog"},
        )

        issues = dag.validate_cross_step()

        ip_issues = [i for i in issues if "inherited_params" in i.message]
        assert len(ip_issues) == 1
        assert ip_issues[0].severity == "blocker"
        assert ip_issues[0].step_index == 0
        assert ip_issues[0].field_path == "steps[0].params.cataloging_style"
        assert "Catalog per Domain" in ip_issues[0].message
        assert "One Catalog" in ip_issues[0].message

    def test_step_param_absent_from_inherited_is_fine(self):
        """Edge case: the step sets ``cataloging_style`` but
        ``inherited_params`` doesn't carry that key. There's no
        contradiction — the step's value is the source of truth."""
        dag = Dag(
            intent="new-base-model",
            steps=(
                OperationStep(
                    "generate_ecm",
                    {"cataloging_style": "Catalog per Domain"},
                ),
            ),
            # inherited_params is empty / omits the key entirely.
            inherited_params={"naming_convention": "snake_case"},
        )

        issues = dag.validate_cross_step()

        ip_issues = [i for i in issues if "inherited_params" in i.message]
        assert ip_issues == []


# --- Intent enum -------------------------------------------------------------


class TestIntent:
    """Phase 1 only adds the type. The wirer change (POST /runs body)
    happens in Phase 4."""

    def test_intent_round_trips_through_string_value(self):
        """The contract: each enum member is constructible from its
        on-the-wire string. Spec §8 — wire shape is the kebab-case
        string, e.g. ``"new-base-model"``."""
        assert Intent("new-base-model") is Intent.NEW_BASE_MODEL
        assert Intent.NEW_BASE_MODEL.value == "new-base-model"

    @pytest.mark.parametrize(
        "wire_value",
        [
            "new-base-model",
            "vibe-iterate",
            "vibe-new-ecm-mvm",
            "revert",
            "import-from-volume",
            "install",
            "uninstall",
            "generate-samples",
        ],
    )
    def test_every_intent_member_has_kebab_case_value(self, wire_value):
        """Exhaustive coverage of every Intent enum member — a future
        accidental rename breaks this test loudly."""
        assert Intent(wire_value).value == wire_value

    def test_intent_is_string_enum_for_fastapi_pydantic(self):
        """``Intent`` MUST inherit ``str`` so FastAPI/Pydantic can
        serialize it directly — same pattern as ``OperationType``."""
        assert isinstance(Intent.NEW_BASE_MODEL, str)


# --- validate_dag_request: unwired-intent fallback --------------------------


class TestValidateDagRequestUnwiredIntentFallback:
    """``validate_dag_request`` only has DAG factories wired for
    ``new-base-model`` and ``vibe-new-ecm-mvm`` (see the coordinator's
    ``if``/``if`` branches). Every other *known* ``Intent`` member falls
    into the trailing branch, which used to return a ``blocker``; this
    silently disabled ``POST /runs`` submission from the run form the
    moment validate blockers started disabling "Start Run", even though
    those intents actually submit fine through the legacy pipeline. The
    fallback must downgrade to a non-blocking ``warning`` instead."""

    @pytest.mark.parametrize(
        "wire_value",
        [
            "vibe-iterate",
            "import-from-volume",
            "install",
            "uninstall",
        ],
    )
    def test_known_unwired_intent_yields_zero_blockers_and_one_warning(
        self, wire_value
    ):
        from vibe_modeling.backend.models import RunIn
        from vibe_modeling.backend.services.orchestrator.validate import (
            validate_dag_request,
        )

        req = RunIn(intent=Intent(wire_value))

        result = validate_dag_request(req, business=None)  # type: ignore[arg-type]

        assert result.blockers == []
        assert result.dag is None
        assert len(result.warnings) == 1
        assert "not available" in result.warnings[0].message.lower()


class TestBusinessDescriptionBlockerForIntent:
    """``business_description_blocker_for_intent`` is the fail-fast gate for
    the release-blocking bug where a kickstarted-from-industry business (born
    with an empty description before the kickstart fix) reaches the agent
    for a model-producing run and dies ~1 minute into compute with
    "Business description is required". Gated intents: new-base-model,
    vibe-iterate, vibe-new-ecm-mvm - the three that dispatch a FRESH
    description-mode agent op. install/uninstall/generate-samples/
    import-from-volume/revert are not gated here (see the function
    docstring for why)."""

    @staticmethod
    def _business(description: str = ""):
        from types import SimpleNamespace

        return SimpleNamespace(description=description)

    @pytest.mark.parametrize(
        "intent_value",
        ["new-base-model", "vibe-iterate", "vibe-new-ecm-mvm"],
    )
    def test_blocks_when_description_and_overrides_all_empty(self, intent_value):
        from vibe_modeling.backend.services.orchestrator.validate import (
            business_description_blocker_for_intent,
        )

        blocker = business_description_blocker_for_intent(
            intent_value, self._business("")
        )

        assert blocker is not None
        assert blocker.severity == "blocker"
        assert blocker.field_path == "business_description"
        assert "description" in blocker.message.lower()

    @pytest.mark.parametrize(
        "intent_value",
        ["install", "uninstall", "generate-samples", "import-from-volume", "revert"],
    )
    def test_does_not_gate_non_generation_intents(self, intent_value):
        from vibe_modeling.backend.services.orchestrator.validate import (
            business_description_blocker_for_intent,
        )

        assert business_description_blocker_for_intent(
            intent_value, self._business("")
        ) is None

    @pytest.mark.parametrize(
        "intent_value",
        ["new-base-model", "vibe-iterate", "vibe-new-ecm-mvm"],
    )
    def test_business_description_alone_satisfies_the_gate(self, intent_value):
        from vibe_modeling.backend.services.orchestrator.validate import (
            business_description_blocker_for_intent,
        )

        assert business_description_blocker_for_intent(
            intent_value, self._business("A retail industry template.")
        ) is None

    @pytest.mark.parametrize(
        "intent_value",
        ["new-base-model", "vibe-iterate", "vibe-new-ecm-mvm"],
    )
    def test_inline_business_context_text_rescues_a_blank_description(
        self, intent_value
    ):
        from vibe_modeling.backend.services.orchestrator.validate import (
            business_description_blocker_for_intent,
        )

        assert business_description_blocker_for_intent(
            intent_value,
            self._business(""),
            business_context_text="Ad-hoc inline business context.",
        ) is None

    @pytest.mark.parametrize(
        "intent_value",
        ["new-base-model", "vibe-iterate", "vibe-new-ecm-mvm"],
    )
    def test_business_context_path_rescues_all_three_gated_intents(
        self, intent_value
    ):
        """Every DAG factory that reaches a gated intent threads
        ``business_context_path`` through to the agent's ``context_file``
        widget: the unified factory (new-base-model / vibe-new-ecm-mvm) via
        ``req.business_context_path`` directly, and ``dag_for_vibe_iterate``
        via ``_optional_convention_params``'s ``business_context_path``
        carry-key -> ``VibeIterateParams.business_context_path`` ->
        ``context_file`` widget."""
        from vibe_modeling.backend.services.orchestrator.validate import (
            business_description_blocker_for_intent,
        )

        assert business_description_blocker_for_intent(
            intent_value,
            self._business(""),
            business_context_path="/Volumes/cat/schema/vol/model.json",
        ) is None

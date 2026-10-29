"""``core/_intents``: the one home of the intent <-> agent operation maps."""

from __future__ import annotations

import pytest

from vibe_modeling.backend.core import _intents
from vibe_modeling.backend.core._intents import (
    AGENT_OP_TO_PRIMITIVE,
    INTENT_TO_AGENT_OP,
    MODEL_PRODUCING_AGENT_OPS,
    infer_intent,
)
from vibe_modeling.backend.core._widgets import MODEL_PRODUCING_OPS
from vibe_modeling.backend.models import Intent
from vibe_modeling.backend.services.operations import _registry
from vibe_modeling.backend.services.operations._generation_common import (
    AGENT_OP_ENLARGE_MVM,
    AGENT_OP_NEW_BASE_MODEL,
    AGENT_OP_SHRINK_ECM,
)


def test_forward_map_is_the_launch_vocabulary():
    assert INTENT_TO_AGENT_OP == {
        "new-base-model": "new base model",
        "vibe-iterate": "vibe modeling of version",
        "vibe-new-ecm-mvm": "vibe modeling of version",
        "install": "install model",
        "uninstall": "uninstall model version",
        "revert": "revert model version",
        "import-from-volume": "import model version",
    }


def test_one_set_of_producing_ops():
    assert MODEL_PRODUCING_OPS is MODEL_PRODUCING_AGENT_OPS
    assert (AGENT_OP_NEW_BASE_MODEL, AGENT_OP_SHRINK_ECM, AGENT_OP_ENLARGE_MVM) == (
        _intents.AGENT_OP_NEW_BASE_MODEL, _intents.AGENT_OP_SHRINK_ECM, _intents.AGENT_OP_ENLARGE_MVM,
    )
    assert set(AGENT_OP_TO_PRIMITIVE) == MODEL_PRODUCING_AGENT_OPS


def test_every_producing_op_maps_to_a_registered_primitive():
    for primitive in AGENT_OP_TO_PRIMITIVE.values():
        assert _registry.get(primitive).produces_version, primitive


@pytest.mark.parametrize("agent_op,paired,expected", [
    ("new base model", None, Intent.NEW_BASE_MODEL),
    ("new base model", "shrink ecm", Intent.NEW_BASE_MODEL),
    ("vibe modeling of version", None, Intent.VIBE_ITERATE),
    ("vibe modeling of version", "shrink ecm", Intent.VIBE_NEW_ECM_MVM),
    ("shrink ecm", "new base model", Intent.NEW_BASE_MODEL),
    ("shrink ecm", "vibe modeling of version", Intent.VIBE_NEW_ECM_MVM),
    ("shrink ecm", None, Intent.VIBE_ITERATE),
    ("enlarge mvm", None, Intent.VIBE_ITERATE),
    (" Shrink ECM ", None, Intent.VIBE_ITERATE),
    ("install model", None, None),
    ("uninstall model version", None, None),
    ("revert model version", None, None),
    ("", None, None),
])
def test_infer_intent(agent_op, paired, expected):
    assert infer_intent(agent_op, paired_agent_op=paired) == expected


def test_inverse_agrees_with_the_forward_map_for_single_run_intents():
    for intent in (Intent.NEW_BASE_MODEL, Intent.VIBE_ITERATE):
        assert infer_intent(INTENT_TO_AGENT_OP[intent.value]) == intent

"""The app's run intents and the agent's ``operation`` widget, both ways.

The durable ``Run.intent`` speaks the orchestrator vocabulary
(``models.Intent``); the agent notebook speaks its own (the ``operation``
widget: ``new base model``, ``vibe modeling of version``, ...). This module
holds the agent's operation strings, the forward map the launch path uses,
and :func:`infer_intent`, the inverse for a run the app did not launch.

The forward map is not invertible: ``vibe-iterate`` and ``vibe-new-ecm-mvm``
both lead with ``vibe modeling of version``, and ``new-base-model`` is two
agent runs (``new base model`` then ``shrink ecm``). So the inverse is a
relation that also looks at the run paired with this one.
"""

from __future__ import annotations

from typing import Optional

from ..models import Intent

INTENT_KICKSTART_FROM_INDUSTRY = "kickstart-from-industry"
"""``Run.intent`` of the audit Run of a business created from an industry model
(``industry_kickstart``); the app launches no agent job for it."""

AGENT_OP_NEW_BASE_MODEL = "new base model"
AGENT_OP_VIBE = "vibe modeling of version"
AGENT_OP_SHRINK_ECM = "shrink ecm"
AGENT_OP_ENLARGE_MVM = "enlarge mvm"
AGENT_OP_INSTALL = "install model"
AGENT_OP_UNINSTALL = "uninstall model version"
AGENT_OP_REVERT = "revert model version"
AGENT_OP_IMPORT = "import model version"
AGENT_OP_GENERATE_SAMPLES = "generate sample data"

MODEL_PRODUCING_AGENT_OPS: frozenset[str] = frozenset({
    AGENT_OP_NEW_BASE_MODEL,
    AGENT_OP_VIBE,
    AGENT_OP_SHRINK_ECM,
    AGENT_OP_ENLARGE_MVM,
})
"""Agent operations that write a model version (through ``VibeWriter``)."""

RESIZE_AGENT_OPS: frozenset[str] = frozenset({AGENT_OP_SHRINK_ECM, AGENT_OP_ENLARGE_MVM})
"""Agent operations that derive a version of the other scope from one version."""

INTENT_TO_AGENT_OP: dict[str, str] = {
    Intent.NEW_BASE_MODEL.value: AGENT_OP_NEW_BASE_MODEL,
    Intent.VIBE_ITERATE.value: AGENT_OP_VIBE,
    # ``vibe-new-ecm-mvm`` is multi-step: the first step is the agent's
    # vibe op (mirrors VIBE_ITERATE's translation). The downstream
    # ``shrink_to_mvm`` primitive translates separately when its widgets
    # are built; this mapping is the lead-step label for monitoring tags.
    Intent.VIBE_NEW_ECM_MVM.value: AGENT_OP_VIBE,
    Intent.INSTALL.value: AGENT_OP_INSTALL,
    Intent.UNINSTALL.value: AGENT_OP_UNINSTALL,
    Intent.REVERT.value: AGENT_OP_REVERT,
    Intent.IMPORT_FROM_VOLUME.value: AGENT_OP_IMPORT,
}
"""Intent -> the ``operation`` widget of its first agent run."""

AGENT_OP_TO_PRIMITIVE: dict[str, str] = {
    AGENT_OP_NEW_BASE_MODEL: "generate_ecm",
    AGENT_OP_VIBE: "vibe_iterate",
    AGENT_OP_SHRINK_ECM: "shrink_to_mvm",
    AGENT_OP_ENLARGE_MVM: "enlarge_to_ecm",
}
"""The orchestrator primitive (``RunOperation.operation_name``) that dispatches
each model-producing agent operation."""


def infer_intent(agent_op: str, *, paired_agent_op: Optional[str] = None) -> Optional[Intent]:
    """The intent the app would have recorded for an agent run with
    ``operation`` = ``agent_op``; None when the run produces no version.

    ``paired_agent_op`` is the operation of the other run of a two-run
    session: the ``shrink ecm`` that followed a ``new base model`` or a vibe,
    or the run that came before a ``shrink ecm``.

    - ``new base model``: ``new-base-model``, alone or with its shrink.
    - ``vibe modeling of version``: ``vibe-new-ecm-mvm`` with a shrink paired,
      else ``vibe-iterate``.
    - ``shrink ecm`` paired with the run before it: that run's intent.
    - ``shrink ecm`` or ``enlarge mvm`` alone: ``vibe-iterate`` (the app has
      no standalone resize intent; the caller notes the resize).
    - install, uninstall, revert, import: None.
    """
    op = (agent_op or "").strip().lower()
    paired = (paired_agent_op or "").strip().lower() or None
    if op == AGENT_OP_NEW_BASE_MODEL:
        return Intent.NEW_BASE_MODEL
    if op == AGENT_OP_VIBE:
        return Intent.VIBE_NEW_ECM_MVM if paired == AGENT_OP_SHRINK_ECM else Intent.VIBE_ITERATE
    if op == AGENT_OP_SHRINK_ECM and paired in (AGENT_OP_NEW_BASE_MODEL, AGENT_OP_VIBE):
        return infer_intent(paired, paired_agent_op=op)
    if op in RESIZE_AGENT_OPS:
        return Intent.VIBE_ITERATE
    return None


__all__ = [
    "INTENT_KICKSTART_FROM_INDUSTRY",
    "AGENT_OP_ENLARGE_MVM",
    "AGENT_OP_GENERATE_SAMPLES",
    "AGENT_OP_IMPORT",
    "AGENT_OP_INSTALL",
    "AGENT_OP_NEW_BASE_MODEL",
    "AGENT_OP_REVERT",
    "AGENT_OP_SHRINK_ECM",
    "AGENT_OP_UNINSTALL",
    "AGENT_OP_VIBE",
    "AGENT_OP_TO_PRIMITIVE",
    "INTENT_TO_AGENT_OP",
    "MODEL_PRODUCING_AGENT_OPS",
    "RESIZE_AGENT_OPS",
    "infer_intent",
]

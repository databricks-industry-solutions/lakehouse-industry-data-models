"""The agent writes `base_version`, `base_scope` and `base_catalog` at the root of `_vibe_scope`.
The installer guard looks the base version up for `base_scope`, like the agent's own install
precondition, and falls back to the artifact's scope when the block has none.
"""
from installer_harness import REGISTRY_COLUMNS, FakeRegistry, registry_row
from test_scoped_install_guard import USED, guard, refused, scoped_model


def _block(**extra):
    block = {"mode": "domains", "entries": ["crew"], "base_version": "1", "operation": "vibe modeling of version",
             "base_catalog": "demo"}
    block.update(extra)
    return block


def test_the_base_version_is_matched_for_the_base_scope():
    rows = [registry_row(1, model_scope="ecm"), registry_row(3, model_scope="mvm")]
    result, ns = guard(FakeRegistry(USED, REGISTRY_COLUMNS, rows), scoped_model(vibe_scope=_block(base_scope="ecm")))
    assert result == 1
    assert any("(ecm, built in catalog 'demo')" in line for line in ns["_log_lines"])


def test_a_base_scope_with_a_different_installed_version_is_refused():
    rows = [registry_row(1, model_scope="mvm"), registry_row(4, model_scope="ecm")]
    message = refused(FakeRegistry(USED, REGISTRY_COLUMNS, rows), scoped_model(vibe_scope=_block(base_scope="ecm")))
    assert "base v1" in message and "is v4" in message


def test_without_a_base_scope_the_artifact_scope_is_used():
    rows = [registry_row(1, model_scope="mvm")]
    assert guard(FakeRegistry(USED, REGISTRY_COLUMNS, rows), scoped_model(vibe_scope=_block()))[0] == 1

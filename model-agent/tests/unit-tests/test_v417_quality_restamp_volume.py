import io
import json
import os
import sys
import textwrap
import types

NB_HEAD = os.path.join(os.path.dirname(__file__), "..", "..", "agent", "dbx_vibe_modelling_agent.ipynb")
NB_PRE = "/tmp/agent_pre_v417.ipynb"


def _nb_source(path):
    nb = json.load(open(path))
    return "\n".join("".join(c.get("source", [])) for c in nb.get("cells", []) if c.get("cell_type") == "code")


def _extract_restamp_volume(src):
    """Extract the v4.1.7 volume-restamp body (the lines under the try:, from the `_qb417 =`
    line up to but excluding `except Exception as _e417`). Returns dedented code or None."""
    lines = src.split("\n")
    for i, l in enumerate(lines):
        if "_qb417 = globals().get('_LAST_VOV_QUALITY_BREAKDOWN')" in l:
            block = []
            for w in lines[i:]:
                if "except Exception as _e417" in w:
                    return textwrap.dedent("\n".join(block))
                block.append(w)
    return None


class _FakeUpload:
    """Captures the last upload so the test can assert the re-stamped content."""
    last = {}


def _install_fake_sdk(stale_root):
    """Inject a fake databricks.sdk.WorkspaceClient whose files.download returns stale_root
    and whose files.upload records the uploaded bytes into _FakeUpload.last."""
    sdk = types.ModuleType("databricks.sdk")
    pkg = types.ModuleType("databricks")
    pkg.sdk = sdk

    class _Resp:
        def __init__(self, b):
            self.contents = io.BytesIO(b)

    class _Files:
        def download(self, path):
            return _Resp(json.dumps(stale_root).encode("utf-8"))

        def upload(self, file_path=None, contents=None, overwrite=False):
            raw = contents.read() if hasattr(contents, "read") else contents
            _FakeUpload.last = {"path": file_path, "root": json.loads(raw)}

    class _WC:
        def __init__(self, *a, **k):
            self.files = _Files()

    sdk.WorkspaceClient = _WC
    sys.modules["databricks"] = pkg
    sys.modules["databricks.sdk"] = sdk


def _run_snippet(code, breakdown, stale_root, target_volume="/Volumes/vibe_x_v1/_metamodel/vol_root/business/x/v3/ecm"):
    _FakeUpload.last = {}
    _install_fake_sdk(stale_root)

    class _L:
        def info(self, *a, **k):
            pass

    g = {"_LAST_VOV_QUALITY_BREAKDOWN": breakdown, "logger": _L(), "json": json, "io": io}
    ns = {"widgets_values": {"config": {"TARGET_VOLUME": target_volume}}, "logger": _L()}
    exec(code, g, ns)
    return _FakeUpload.last


_AUTHORITATIVE = {
    "vreq_adherence_pct": 62.3,
    "native_quality_pct": 36.9,
    "vov_quality_pct": 49.61,
    "adherence_source": "physical_ground_truth",
}
# stale logical-time model.json (what step_generate_data_model_json wrote pre-physical)
_STALE_ROOT = {
    "agent_version": "4.1.7",
    "model_requirements": {"x": 1},
    "vreq_adherence_pct": None,
    "native_quality_pct": 36.63,
    "vov_quality_pct": 36.63,
    "_vibe_session_metadata": {},
    "model": {"domains": []},
}


def test_post_patch_snippet_present_and_compiles():
    code = _extract_restamp_volume(_nb_source(NB_HEAD))
    assert code is not None, "v4.1.7 volume-restamp snippet missing from notebook"
    compile(code, "<restamp-volume>", "exec")


def test_rc_quality_restamp_volume_post():
    """POST: the authoritative physical-ground-truth breakdown is written to the volume model.json,
    overwriting the stale adherence=None + native-only quality."""
    code = _extract_restamp_volume(_nb_source(NB_HEAD))
    assert code is not None
    up = _run_snippet(code, dict(_AUTHORITATIVE), dict(_STALE_ROOT))
    assert up, "no upload happened — restamp did not fire for an authoritative breakdown"
    root = up["root"]
    assert root["vreq_adherence_pct"] == 62.3
    assert root["native_quality_pct"] == 36.9
    assert root["vov_quality_pct"] == 49.61


def test_key_order_preserved_agent_version_first():
    """§3a-bis: re-stamping only updates EXISTING keys, so agent_version stays the first key."""
    code = _extract_restamp_volume(_nb_source(NB_HEAD))
    assert code is not None
    up = _run_snippet(code, dict(_AUTHORITATIVE), dict(_STALE_ROOT))
    assert list(up["root"].keys())[0] == "agent_version"


def test_gate_skips_non_authoritative_source():
    """Gate: a breakdown whose source is not physical/verified (e.g. shrink/base adh=None) must
    NOT touch the volume model.json (no upload)."""
    code = _extract_restamp_volume(_nb_source(NB_HEAD))
    assert code is not None
    shrink = {"vreq_adherence_pct": None, "native_quality_pct": 78.56, "vov_quality_pct": 78.56, "adherence_source": None}
    up = _run_snippet(code, shrink, dict(_STALE_ROOT))
    assert up == {}, "restamp must NOT fire for a non-authoritative breakdown"


def test_gate_skips_empty_breakdown():
    code = _extract_restamp_volume(_nb_source(NB_HEAD))
    assert code is not None
    up = _run_snippet(code, {}, dict(_STALE_ROOT))
    assert up == {}, "restamp must NOT fire when the breakdown global is empty"


def test_rc_quality_restamp_volume_pre_fails():
    """PRE (v4.1.6 baseline): the volume-restamp snippet does not exist, proving the v4.1.7 patch
    changes observable behavior."""
    if not os.path.exists(NB_PRE):
        import pytest

        pytest.skip("pre-patch baseline /tmp/agent_pre_v417.ipynb not present")
    code = _extract_restamp_volume(_nb_source(NB_PRE))
    assert code is None, "pre-patch baseline must NOT contain the v4.1.7 volume-restamp snippet"

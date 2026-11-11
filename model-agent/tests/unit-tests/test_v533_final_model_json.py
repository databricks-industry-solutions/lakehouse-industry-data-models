"""v5.3.3: model.json is written from the final in-memory model before the registry and the physical deploy.

Two New Base Model runs asked for at most 30 products. Their registry rows, DDL and run summary held 30 products in
3 domains, while model.json held an earlier, larger model (51 products in 4 domains, and 45 in 4). The parallel
artifact thread writes model.json before the VibeOrchestrator, the SelfFixer and the empty-domain gate run, and the
SelfFixer may shrink the model toward the user's product cap. The re-export after the SelfFixer only logged a warning
when it failed, and the artifact join could time out while the first writer was still running, so a late first upload
could overwrite the re-export. These tests drive _join_parallel_artifacts, _export_final_model_json and
step_generate_data_model_json with a fake Files API.
"""
import ast
import json
import threading
import time
import types
from pathlib import Path

import pytest

import conftest  # noqa: F401
import agent_helpers as ah
import test_v516_pk_integrity as pk

NOTEBOOK = Path(__file__).resolve().parents[2] / "agent" / "dbx_vibe_modelling_agent.ipynb"
TARGET_VOLUME = "/Volumes/c/_metamodel/vol_root/business/vs514_retail/v1/mvm"
MODEL_JSON = f"{TARGET_VOLUME}/model.json"
DROPPED_DOMAIN = "order"
DROPPED_PRODUCT = ("product", "digital_asset")


class _Volume:
    """Fake Files API. With hold_first set, the first upload waits for release before it lands."""

    def __init__(self, hold_first=False):
        self.files = {}
        self.landed = []
        self.release = threading.Event()
        self._hold_first = hold_first
        self._calls = 0
        self._lock = threading.Lock()

    def client(self, *args, **kwargs):
        return types.SimpleNamespace(files=self)

    def delete(self, file_path):
        self.files.pop(file_path, None)

    def upload(self, file_path, contents, overwrite=True):
        data = contents.read()
        with self._lock:
            self._calls += 1
            first = self._calls == 1
        if first and self._hold_first:
            assert self.release.wait(10), "the held first upload was never released"
        self.files[file_path] = data
        self.landed.append(json.loads(data))

    def model(self):
        return json.loads(self.files[MODEL_JSON])


def _widgets(tmp_path, monkeypatch, volume):
    d, p, a, mv = pk._flat()
    cfg = pk._cfg()
    cfg.update({"TARGET_VOLUME": TARGET_VOLUME, "MAIN_METAMODEL_TABLES": {"BUSINESS": "c._metamodel.business"},
                "PRODUCTS_FILE_PATH": str(tmp_path / "products.json"), "ATTRIBUTES_FILE_PATH": str(tmp_path / "attributes.json"),
                "DOMAINS_FILE_PATH": str(tmp_path / "domains.json")})
    for key, rows in (("PRODUCTS_FILE_PATH", p), ("ATTRIBUTES_FILE_PATH", a), ("DOMAINS_FILE_PATH", d)):
        Path(cfg[key]).write_text(json.dumps(rows))
    log, cap = pk._logger()
    wv = {"spark": None, "logger": log, "config": cfg, "business_name": "vs514 retail", "operation": "new base model",
          "current_version": "1", "model_scope": "mvm", "domains": d, "products": p, "attributes": a, "metric_views": [],
          "_metric_view_records": [], "metric_view_statements": [], "_run_start_time": "2026-10-08T22:00:00",
          "_run_start_timestamp": time.time(), "_widget_raw_values": {"business_name": "vs514 retail", "operation": "new base model"}}
    monkeypatch.setitem(ah.__dict__, "WorkspaceClient", volume.client)
    monkeypatch.setitem(ah.__dict__, "execute_sql", lambda spark, query, logger=None: [dict(pk._BUSINESS_ROW)])
    return wv, log, cap


def _shrink(wv):
    """What the SelfFixer write-back does after a shrink toward the user's cap: new flat lists, FKs to dropped tables cleared."""
    keep = {(p["domain"], p["product"]) for p in wv["products"]
            if p["domain"] != DROPPED_DOMAIN and (p["domain"], p["product"]) != DROPPED_PRODUCT}
    attributes = []
    for a in wv["attributes"]:
        if (a["domain"], a["product"]) not in keep:
            continue
        a = dict(a)
        if a.get("foreign_key_to") and tuple(str(a["foreign_key_to"]).split(".")[:2]) not in keep:
            a["foreign_key_to"] = ""
        attributes.append(a)
    wv["domains"] = [dict(d) for d in wv["domains"] if d["domain"] != DROPPED_DOMAIN]
    wv["products"] = [dict(p) for p in wv["products"] if (p["domain"], p["product"]) in keep]
    wv["attributes"] = attributes
    return keep


def _products(root):
    return {(d["name"], p["name"]) for d in root["model"]["domains"] for p in d["products"]}


def _attribute_count(root):
    return sum(len(p["attributes"]) for d in root["model"]["domains"] for p in d["products"])


def _main_source():
    nb = json.loads(NOTEBOOK.read_text())
    return next("".join(c["source"]) for c in nb["cells"] if c["cell_type"] == "code" and "def main():" in "".join(c["source"]))


def test_a_model_shrunk_after_the_first_write_ends_with_model_json_equal_to_the_final_model(tmp_path, monkeypatch):
    volume = _Volume()
    wv, log, cap = _widgets(tmp_path, monkeypatch, volume)
    ah.step_generate_data_model_json(wv)
    first = volume.model()
    assert any(dom == DROPPED_DOMAIN for dom, _ in _products(first))
    keep = _shrink(wv)
    ah._export_final_model_json(wv, log)
    final = volume.model()
    assert _products(final) == keep == {(p["domain"], p["product"]) for p in wv["products"]}
    assert {d["name"] for d in final["model"]["domains"]} == {d["domain"] for d in wv["domains"]}
    assert _attribute_count(final) == len(wv["attributes"]) < _attribute_count(first)
    assert f"[final-modeljson-export FIRED v5.3.3] model.json written from the final model: domains=2 products={len(keep)}" in pk._text(cap)


def test_a_failed_final_export_fails_the_run(tmp_path, monkeypatch):
    volume = _Volume()
    wv, log, cap = _widgets(tmp_path, monkeypatch, volume)

    def _drop_pk(data_model, logger=None):
        prod = pk._nested_product({"domains": data_model["domains"]}, "customer", "campaign")
        prod["attributes"] = [a for a in prod["attributes"] if a["name"] != "campaign_id"]
        return {}

    monkeypatch.setitem(ah.__dict__, "_v443_structural_hardening", _drop_pk)
    monkeypatch.setitem(ah.__dict__, "_v516_modeljson_parity_repair", lambda data_model, widgets_values, config, logger, frozen: ({}, set()))
    with pytest.raises(ah.ModelJsonParityError):
        ah._export_final_model_json(wv, log)
    assert MODEL_JSON not in volume.files
    assert "[final-modeljson-export FIRED v5.3.3] FAILED: ModelJsonParityError" in pk._text(cap)


def test_a_failed_upload_in_the_final_export_fails_the_run(tmp_path, monkeypatch):
    volume = _Volume()
    wv, log, cap = _widgets(tmp_path, monkeypatch, volume)

    def _upload_fails(file_path, contents, overwrite=True):
        raise OSError("volume unavailable")

    volume.upload = _upload_fails
    with pytest.raises(OSError, match="volume unavailable"):
        ah._export_final_model_json(wv, log)
    assert "[final-modeljson-export FIRED v5.3.3] FAILED: OSError" in pk._text(cap)


def test_a_delayed_first_write_cannot_overwrite_the_final_one(tmp_path, monkeypatch):
    volume = _Volume(hold_first=True)
    wv, log, cap = _widgets(tmp_path, monkeypatch, volume)
    threads, errors, _, _ = ah._run_parallel_artifacts([(ah.step_generate_data_model_json, "Data Model JSON")], wv, wv["config"], log)
    assert [t.name for t in threads] == [ah._MODEL_JSON_ARTIFACT_THREAD]
    releaser = threading.Timer(0.5, volume.release.set)
    for t in threads:
        t.start()
    releaser.start()
    try:
        ah._join_parallel_artifacts(threads, 0.05, log)
        assert not any(t.is_alive() for t in threads)
        assert errors == []
        assert len(volume.landed) == 1
        keep = _shrink(wv)
        ah._export_final_model_json(wv, log)
    finally:
        volume.release.set()
        releaser.cancel()
        for t in threads:
            t.join(10)
    time.sleep(0.1)
    assert len(volume.landed) == 2
    assert any(dom == DROPPED_DOMAIN for dom, _ in _products(volume.landed[0]))
    assert _products(volume.model()) == keep
    text = pk._text(cap)
    assert f"{ah._MODEL_JSON_ARTIFACT_THREAD} still running after 0.05s" in text
    assert "[modeljson-writer-join FIRED v5.3.3]" in text


def test_other_artifact_threads_keep_the_join_timeout():
    release = threading.Event()
    log, cap = pk._logger()
    slow = threading.Thread(target=release.wait, args=(10,), name="artifact_readme", daemon=True)
    slow.start()
    try:
        started = time.time()
        ah._join_parallel_artifacts([slow], 0.05, log)
        assert time.time() - started < 2
        assert slow.is_alive()
        assert "artifact_readme still running after 0.05s" in pk._text(cap)
        assert "modeljson-writer-join" not in pk._text(cap)
    finally:
        release.set()
        slow.join(10)


def _ancestors(tree, target):
    parents = {}
    for node in ast.walk(tree):
        for child in ast.iter_child_nodes(node):
            parents[child] = node
    chain, node = [], target
    while node in parents:
        node = parents[node]
        chain.append(node)
    return chain


def _reraises(handler):
    return bool(handler.body) and isinstance(handler.body[-1], ast.Raise)


def test_main_runs_the_final_export_after_the_last_model_change_and_lets_its_failure_stop_the_run():
    src = _main_source()
    tree = ast.parse(src)
    calls = [n for n in ast.walk(tree) if isinstance(n, ast.Call) and getattr(n.func, "id", None) == "_export_final_model_json"]
    assert len(calls) == 1
    for anc in _ancestors(tree, calls[0]):
        if isinstance(anc, ast.Try) and any(calls[0] is n for stmt in anc.body for n in ast.walk(stmt)):
            assert all(_reraises(h) for h in anc.handlers), f"a try at line {anc.lineno} swallows the final export's failure"
    final = src.index("_export_final_model_json(widgets_values, logger)")
    assert src.index("Outer guard caught") < final
    assert src.index("[v414-empty-domain-vov-writeback ERROR v4.1.4]") < final
    assert final < src.index('_vibe_scope_halt_if_gate_failed(widgets_values, "Step 9a physical deploy", logger)')
    assert final < src.index("_run_step(step_create_physical_schema_stage1")
    assert "step_generate_data_model_json(widgets_values)" not in src
    assert "_join_parallel_artifacts(_art_threads, _art_join_timeout, logger)" in src
    assert '(step_generate_data_model_json, "Data Model JSON")' in src, "the label _MODEL_JSON_ARTIFACT_THREAD is derived from"

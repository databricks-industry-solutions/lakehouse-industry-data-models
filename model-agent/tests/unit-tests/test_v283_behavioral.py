"""Behavioral tests for v2.8.3 — VOV-LANDING root-cause fixes.

Context: 18 VOV runs churned for 5+ hours at 0% adherence. Three root causes:

  (a) vov-synth-target-aware-digest — the synthesizer's CURRENT_MODEL_DIGEST took the
      FIRST 50 domains x 60 products and hard-truncated the JSON at 32KB. On big ECM
      models (400+ products) the batch's TARGET product fell past the truncation, so the
      synthesizer never saw the entity it had to mutate and emitted empty-diff mutators
      (noop_failed) on every batch -> 0% coverage. Fix: serialize the FULL
      products+attributes of every (domain,product) in batch.target_entities FIRST and
      unconditionally, before the broader (still-truncated) digest.

  (b) vov-outcome-summary — synth/sandbox loggers are not routed to the volume log, so the
      reason batches failed was invisible. Fix: emit a per-iteration [VOV-OUTCOME-SUMMARY]
      by_status breakdown + per-batch [VOV-OUTCOME-DIAG] on the routed vov2-pipeline logger.

  (c) vov-tools-inline-fix — complete_with_tools called vibe_section({'section_id': sid})
      (passing a dict where a str was expected) and then checked isinstance(result, str)
      (vibe_section returns a dict), so 0 sections were EVER inlined and the extractor LLM
      got zero entity context. Fix: pass a str section_id and read the dict's .text.

Each behavioral test slices the ACTUAL shipped code block out of the notebook and execs it,
so the assertion fails on the pre-patch HEAD (which never emits TARGET_ENTITIES_FULL,
[VOV-OUTCOME-SUMMARY], or a populated _inlined_chunks).
"""
import json

from notebook_source_util import vov_ledger_globals
import re
import textwrap
import logging
from pathlib import Path

NB_PATH = Path(__file__).parent.parent.parent / "agent" / "dbx_vibe_modelling_agent.ipynb"


def _nb_src():
    cells = json.loads(NB_PATH.read_text()).get("cells", [])
    return "\n".join("".join(c.get("source", [])) for c in cells if c.get("cell_type") == "code")


# ---------------- version + alias presence ----------------

def test_agent_version_283():
    m = re.search(r'__AGENT_VERSION__\s*=\s*"([^"]+)"', _nb_src())
    assert m, "version constant missing"
    assert tuple(int(x) for x in m.group(1).split(".")) >= (2, 8, 3), m.group(1)


def test_all_three_aliases_present():
    src = _nb_src()
    assert "alias=vov-synth-target-aware-digest" in src
    assert "alias=vov-outcome-summary" in src
    assert "alias=vov-tools-inline-fix" in src
    # FIRED markers
    assert "[vov-synth-target-aware-digest FIRED v2.8.3]" in src
    assert "[VOV-OUTCOME-SUMMARY FIRED v2.8.3]" in src


# ---------------- (a) behavioral: target-aware digest ----------------

def _slice(src, start_marker, end_marker):
    s = src.find(start_marker)
    assert s >= 0, f"start marker not found: {start_marker!r}"
    e = src.find(end_marker, s + len(start_marker))
    assert e > s, f"end marker not found after start: {end_marker!r}"
    return src[s:e]


def test_digest_includes_target_beyond_truncation():
    """Build a model whose TARGET product sits past the first-50/32KB window. The shipped
    digest block must still surface its full attributes via TARGET_ENTITIES_FULL."""
    src = _nb_src()
    block = _slice(
        src,
        "        _current_model = (model_snapshot if isinstance(model_snapshot, dict) else None) or {}",
        "    except Exception as _digest_err:",
    )
    block = textwrap.dedent(block)

    class _Batch:
        target_entities = (("sales", "orders"),)

    # 130 filler domains (push the target past first-50 + blow the 32KB digest budget),
    # then the real target domain at the very end.
    domains = []
    for i in range(130):
        domains.append({
            "name": f"filler_{i}",
            "products": [{"name": f"p_{i}", "attributes": [
                {"name": f"col_{j}", "data_type": "STRING"} for j in range(20)
            ]}],
        })
    domains.append({
        "name": "sales",
        "products": [{"name": "orders", "attributes": [
            {"name": "order_id", "data_type": "BIGINT"},
            {"name": "order_total", "data_type": "DECIMAL", "foreign_key_to": None},
            {"name": "customer_id", "data_type": "BIGINT", "foreign_key_to": "crm.customer.id"},
        ]}],
    })
    model_snapshot = {"model": {"domains": domains, "metric_views": []}}

    ns = {"model_snapshot": model_snapshot, "batch": _Batch(), "user": "", "json": json, "logging": logging}
    exec(compile(block, "<digest>", "exec"), ns)
    user = ns["user"]

    assert "TARGET_ENTITIES_FULL" in user, "target-aware section header missing"
    # The full target product + its deep attributes must be present even though it is the
    # 131st domain (pre-patch first-50/32KB truncation would have dropped it entirely).
    ti = user.find("TARGET_ENTITIES_FULL")
    di = user.find("CURRENT_MODEL_DIGEST")
    targeted_section = user[ti:di]
    assert '"orders"' in targeted_section
    assert "order_total" in targeted_section
    assert "crm.customer.id" in targeted_section, "FK on a deep target attr must survive"


def test_digest_empty_target_attributes_signalled():
    """A target product with no attributes yet must still appear (empty list) so the
    synthesizer is told to ADD attributes rather than silently skip."""
    src = _nb_src()
    block = textwrap.dedent(_slice(
        src,
        "        _current_model = (model_snapshot if isinstance(model_snapshot, dict) else None) or {}",
        "    except Exception as _digest_err:",
    ))

    class _Batch:
        target_entities = (("ops", "shipments"),)

    model_snapshot = {"model": {"domains": [
        {"name": "ops", "products": [{"name": "shipments", "attributes": []}]},
    ], "metric_views": []}}
    ns = {"model_snapshot": model_snapshot, "batch": _Batch(), "user": "", "json": json, "logging": logging}
    exec(compile(block, "<digest2>", "exec"), ns)
    ti = ns["user"].find("TARGET_ENTITIES_FULL")
    di = ns["user"].find("CURRENT_MODEL_DIGEST")
    assert '"shipments"' in ns["user"][ti:di]


# ---------------- (b) behavioral: outcome summary ----------------

class _FakeLogger:
    def __init__(self):
        self.infos = []
        self.warnings = []

    def info(self, m):
        self.infos.append(m)

    def warning(self, m):
        self.warnings.append(m)


class _OC:
    def __init__(self, batch_id, status, vreq_ids, diagnostic):
        self.batch_id = batch_id
        self.status = status
        self.vreq_ids = vreq_ids
        self.diagnostic = diagnostic


def test_outcome_summary_reports_by_status():
    """The else-branch summary block must emit a by_status Counter and per-batch diags for
    non-applied outcomes."""
    src = _nb_src()
    block = textwrap.dedent(_slice(
        src,
        "            try:\n                from collections import Counter as _C283\n",
        "            _applied_ids = {",
    ))
    new_outcomes = [
        _OC("B1", "applied", ["VREQ-1"], ""),
        _OC("B2", "noop_failed", ["VREQ-2"], "EMPTY-DIFF NOOP — model bit-identical"),
        _OC("B3", "noop_failed", ["VREQ-3"], "EMPTY-DIFF NOOP"),
        _OC("B4", "rejected_unsafe", ["VREQ-4"], "post-condition FAILED — none intersected target_entities"),
    ]
    lg = _FakeLogger()
    ns = {**vov_ledger_globals(), "_new_outcomes": new_outcomes, "_eloop": 2, "logger": lg,
          "outcomes": list(new_outcomes), "_outcomes_before": 0, "_remaining_vreqs": [], "initial_model": {}, "model": {}}
    exec(compile(block, "<summary>", "exec"), ns)

    summ = [m for m in lg.infos if "VOV-OUTCOME-SUMMARY FIRED" in m]
    assert len(summ) == 1, lg.infos
    assert "applied=1" in summ[0]
    assert "noop_failed" in summ[0] and "rejected_unsafe" in summ[0]
    diags = [m for m in lg.infos if "VOV-OUTCOME-DIAG" in m]
    assert len(diags) == 3, "one diag per non-applied batch"
    assert any("EMPTY-DIFF NOOP" in m for m in diags)


# ---------------- (c) behavioral: tool-bridge inlining ----------------

def test_bridge_inlines_section_via_str_and_dict_text():
    """The fixed inlining loop must pass a STR section_id to the handler and read the
    returned dict's .text — populating _inlined_chunks. Pre-patch (dict arg + isinstance str
    check) produced 0 chunks."""
    src = _nb_src()
    block = textwrap.dedent(_slice(
        src,
        "                    for _sid in _section_ids:\n",
        "            except Exception:\n                pass\n            if _inlined_chunks:",
    ))

    calls = {"args": []}

    def _sec_handler(section_id):
        calls["args"].append(section_id)
        # mirrors the notebook vibe_section contract: str in, dict out
        assert isinstance(section_id, str), "handler must receive a str section_id"
        return {"section_id": section_id, "text": f"BODY-OF-{section_id}"}

    ns = {"_section_ids": ["sec-A", "sec-B"], "_sec_handler": _sec_handler, "_inlined_chunks": []}
    exec(compile(block, "<inline>", "exec"), ns)

    assert len(ns["_inlined_chunks"]) == 2, ns["_inlined_chunks"]
    assert all(isinstance(a, str) for a in calls["args"]), "all handler args were str"
    assert any("BODY-OF-sec-A" in c for c in ns["_inlined_chunks"])
    assert any("[SECTION sec-B]" in c for c in ns["_inlined_chunks"])

"""v5.1.4 vibe_scope prompt enforcement.

- Static AST gate: every function that sends a prompt through ai_query, serving endpoints or OpenAI
  calls _apply_vibe_scope_to_prompt.
- Capturing fake transports (OpenAI client, WorkspaceClient REST, Spark ai_query SQL, the VOV bridge)
  carry the fence block exactly once when scoped, and the unchanged prompt for All Domains.
- The mutating prompts carry slots; All Domains output is byte-identical to the 5d386ed templates.
- Synthesis and SelfFixer digests mark FK-adjacent out-of-scope products FROZEN and omit the rest.
Behavioral tests fail on pre-patch 5d386ed.
"""
import ast
import copy
import hashlib
import json
import logging
import re
import sys
import types
from pathlib import Path
from types import SimpleNamespace

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent))
import conftest  # noqa: F401,E402
import agent_helpers as ah  # noqa: E402

REPO = Path(__file__).resolve().parents[3]
NOTEBOOK = REPO / "model-agent" / "agent" / "dbx_vibe_modelling_agent.ipynb"
RAW = json.loads((REPO / "data-models" / "airlines" / "v1" / "mvm" / "model.json").read_text())
VOV = "vibe modeling of version"
LOG = logging.getLogger("test_v514_prompts")
_ENGINE = ah.widgets_flat_to_model(*ah.model_to_widgets_flat(RAW), agent_version=ah.__AGENT_VERSION__)

GOLDEN_5D386ED = {
    "synthesis": "45ed6737dacd3a04367da1c1742568f2b0d9a811a8262ed502e6fd99982f9dc5",
    "extraction": "1489dd51ffbe39b19bf452a727db0a0113a47758665ca0967537d1255b490b07",
    "selffixer": "06772a928a1b58fc72b60c8991ae5ca439c99707dd45178195749e4eff6b6dab",
    "selffixer_digest_airlines": "b95b55fe95bec678b9477f4b45cffe79588a182268af3d82519ec25d35bcaac1",
}
KNOWN_TRANSPORTS = {
    ("DatabricksLLM", "complete_json"),
    ("DatabricksLLM", "complete_with_tools"),
    ("AIAgent", "_call_ai_query_impl"),
    ("AIAgent", "_v207_call_llm_spark_free"),
}
_AI_QUERY_SQL = re.compile(r"\bai_query\(", re.I)


@pytest.fixture(autouse=True)
def _reset_runtime():
    ah.set_vibe_scope_runtime(None)
    yield
    ah.set_vibe_scope_runtime(None)


def _fence(entries="crew"):
    fence = ah.build_vibe_scope_fence(ah.parse_vibe_scope("Some Domains", entries), RAW, VOV, LOG)
    ah.set_vibe_scope_runtime(fence)
    fence.bind_engine_baseline(_ENGINE, LOG)
    return fence


def _sha(text):
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def _sentinels(text):
    return text.count(ah._VIBE_SCOPE_PROMPT_SENTINEL)


def _is_transport(node, docstrings):
    if isinstance(node, ast.Call):
        func = node.func
        name = func.id if isinstance(func, ast.Name) else getattr(func, "attr", "")
        if name == "OpenAI":
            return True
        if isinstance(func, ast.Attribute) and func.attr == "query" and isinstance(func.value, ast.Attribute) and func.value.attr == "serving_endpoints":
            return True
    if isinstance(node, ast.Constant) and isinstance(node.value, str) and id(node) not in docstrings:
        return bool(_AI_QUERY_SQL.search(node.value)) or "/serving-endpoints/" in node.value
    return False


def _transport_owners():
    owners = {}
    notebook = json.loads(NOTEBOOK.read_text(encoding="utf-8"))
    for cell in notebook["cells"]:
        if cell.get("cell_type") != "code":
            continue
        tree = ast.parse("".join(cell["source"]))
        parents = {}
        for node in ast.walk(tree):
            for child in ast.iter_child_nodes(node):
                parents[child] = node
        docstrings = {id(n.body[0].value) for n in ast.walk(tree)
                      if isinstance(n, (ast.FunctionDef, ast.AsyncFunctionDef, ast.ClassDef, ast.Module)) and n.body
                      and isinstance(n.body[0], ast.Expr) and isinstance(n.body[0].value, ast.Constant)}
        for node in ast.walk(tree):
            if not _is_transport(node, docstrings):
                continue
            fn = parents.get(node)
            while fn is not None and not isinstance(fn, (ast.FunctionDef, ast.AsyncFunctionDef)):
                fn = parents.get(fn)
            if fn is None:
                continue
            owner = parents.get(fn)
            key = (owner.name if isinstance(owner, ast.ClassDef) else "", fn.name)
            owners[key] = any(isinstance(n, ast.Call) and isinstance(n.func, ast.Name) and n.func.id == "_apply_vibe_scope_to_prompt"
                              for n in ast.walk(fn))
    return owners


def test_every_llm_transport_applies_the_scope_block():
    owners = _transport_owners()
    assert KNOWN_TRANSPORTS <= set(owners)
    assert sorted(key for key, applies in owners.items() if not applies) == []


_EXTRACTION_TARGET_5D386ED = ("  - target: the entity, scope, or set the instruction applies to (e.g. \"all HR products derived from DDL "
                              "emp_history\", \"domain count\", \"every CDE row attribute\")\n")


def test_all_domains_prompts_are_byte_identical_to_5d386ed():
    assert _sha(ah._apply_vibe_scope_to_prompt(ah.SYNTHESIS_SYSTEM_PROMPT)) == GOLDEN_5D386ED["synthesis"]
    extraction = ah._apply_vibe_scope_to_prompt(ah.EXTRACTION_SYSTEM_PROMPT.format(outline_json='{"sections": []}'))
    fq_line = next(line for line in extraction.splitlines(keepends=True) if line.startswith("  - target: "))
    assert "FULLY QUALIFIED" in fq_line and "'## Domain:' / '#### Product:' / '##### Attribute:'" in fq_line
    assert _sha(extraction.replace(fq_line, _EXTRACTION_TARGET_5D386ED, 1)) == GOLDEN_5D386ED["extraction"]
    assert _sha(ah._apply_vibe_scope_to_prompt(ah._SELFFIXER_PROMPT)) == GOLDEN_5D386ED["selffixer"]
    plain = "a prompt without slots"
    assert ah._apply_vibe_scope_to_prompt(plain) is plain
    assert ah._apply_vibe_scope_to_prompt(None) is None


def test_mutating_prompts_carry_their_slots():
    assert "\n{vibe_scope_fence}\n" in ah.SYNTHESIS_SYSTEM_PROMPT
    assert "\n{vibe_scope_fence}\n" in ah._SELFFIXER_PROMPT
    assert "\n{vibe_scope_extraction}\n" in ah.EXTRACTION_SYSTEM_PROMPT.format(outline_json="{}")


def test_scoped_slots_are_filled_once_and_idempotently():
    fence = _fence()
    block = fence.prompt_block()
    for template in (ah.SYNTHESIS_SYSTEM_PROMPT, ah._SELFFIXER_PROMPT):
        out = ah._apply_vibe_scope_to_prompt(template)
        assert _sentinels(out) == 1 and "{vibe_scope_" not in out and block in out
        assert ah._apply_vibe_scope_to_prompt(out) == out
    extraction = ah._apply_vibe_scope_to_prompt(ah.EXTRACTION_SYSTEM_PROMPT.format(outline_json="{}"))
    assert _sentinels(extraction) == 1 and ah._VIBE_SCOPE_EXTRACTION_RULES in extraction
    assert extraction.index(block) < extraction.index("OUTLINE OF THE FULL VIBE")
    assert ah._apply_vibe_scope_to_prompt("hello") == block + "\n\nhello"
    assert ah._apply_vibe_scope_to_prompt("hello", prepend=False) == "hello"


def _fake_openai(monkeypatch):
    sink = []

    class _Completions:
        def create(self, **kwargs):
            sink.append([dict(m) for m in kwargs["messages"]])
            return SimpleNamespace(choices=[SimpleNamespace(message=SimpleNamespace(content='{"ok": true}', tool_calls=None))])

    class _OpenAI:
        def __init__(self, api_key=None, base_url=None):
            self.chat = SimpleNamespace(completions=_Completions())

    monkeypatch.setitem(sys.modules, "openai", SimpleNamespace(OpenAI=_OpenAI))
    return sink


def test_databricks_llm_complete_json_and_tools_carry_the_block(monkeypatch):
    sink = _fake_openai(monkeypatch)
    llm = ah.DatabricksLLM("ep", token="t", workspace="https://w")
    llm.complete_json("SYSTEM", "USER")
    assert sink[-1] == [{"role": "system", "content": "SYSTEM"}, {"role": "user", "content": "USER"}]
    fence = _fence()
    llm.complete_json("SYSTEM", "USER")
    system, user = sink[-1][0]["content"], sink[-1][1]["content"]
    assert system == fence.prompt_block() + "\n\nSYSTEM" and user == "USER"
    llm.complete_with_tools(ah.EXTRACTION_SYSTEM_PROMPT.format(outline_json="{}"), "CHUNK", [], {})
    system, user = sink[-1][0]["content"], sink[-1][1]["content"]
    assert _sentinels(system) == 1 and ah._VIBE_SCOPE_EXTRACTION_RULES in system and "{vibe_scope_" not in system and user == "CHUNK"
    llm.complete_json("SYSTEM", ah.SYNTHESIS_SYSTEM_PROMPT)
    system, user = sink[-1][0]["content"], sink[-1][1]["content"]
    assert system == "SYSTEM" and _sentinels(user) == 1


def _fake_workspace(monkeypatch):
    sink = []

    class _Api:
        def do(self, method, path, body=None):
            sink.append(body)
            return {"choices": [{"message": {"content": "{}"}}]}

    class _WorkspaceClient:
        def __init__(self):
            self.api_client = _Api()

    sdk = types.ModuleType("databricks.sdk")
    sdk.WorkspaceClient = _WorkspaceClient
    pkg = types.ModuleType("databricks")
    pkg.sdk = sdk
    monkeypatch.setitem(sys.modules, "databricks", pkg)
    monkeypatch.setitem(sys.modules, "databricks.sdk", sdk)
    return sink


def _agent():
    agent = object.__new__(ah.AIAgent)
    agent.logger = LOG
    agent._models_lookup = {}
    agent._prompt_settings = {}
    agent.system_config = {}
    return agent


def test_spark_free_transport_carries_the_block(monkeypatch):
    sink = _fake_workspace(monkeypatch)
    agent = _agent()
    agent._v207_call_llm_spark_free(model="databricks-x", prompt=ah._SELFFIXER_PROMPT, response_schema=None, max_tokens=10)
    assert _sha(sink[-1]["messages"][0]["content"]) == GOLDEN_5D386ED["selffixer"]
    _fence()
    agent._v207_call_llm_spark_free(model="databricks-x", prompt=ah._SELFFIXER_PROMPT, response_schema=None, max_tokens=10)
    content = sink[-1]["messages"][0]["content"]
    assert _sentinels(content) == 1 and "{vibe_scope_fence}" not in content
    assert content.index(ah._VIBE_SCOPE_PROMPT_SENTINEL) < content.index("REQ ID: __REQ_ID__")
    agent._v207_call_llm_spark_free(model="databricks-x", prompt="plain prompt", response_schema=None, max_tokens=10)
    assert sink[-1]["messages"][0]["content"].startswith(ah._VIBE_SCOPE_PROMPT_SENTINEL)


def _sql_agent(monkeypatch):
    sink = []

    def _fake_sql(spark, sql, logger, timeout_seconds=None):
        sink.append(sql)
        return [SimpleNamespace(ai_response='{"ok": true}')]

    monkeypatch.setattr(ah, "execute_sql_with_timeout", _fake_sql)
    agent = _agent()
    agent._manager = SimpleNamespace(acquire=lambda: None, release=lambda: None, record_call=lambda m: None,
                                     record_success=lambda *a, **k: None)
    agent._get_model_config_for_prompt = lambda name: {"llm_endpoint_name": "databricks-x", "llm_output_context_tokens_count": 100}
    agent._is_model_broken = lambda m: False
    agent._is_batch_incapable = lambda m: False
    agent._record_success = lambda m: None
    agent.spark = None
    return agent, sink


def test_ai_query_transport_and_vov_bridge_carry_the_block(monkeypatch):
    agent, sink = _sql_agent(monkeypatch)
    agent._call_ai_query_impl("P", "PROMPT BODY", None, "s", skip_honesty_extraction=True)
    assert ah._VIBE_SCOPE_PROMPT_SENTINEL not in sink[-1] and "PROMPT BODY" in sink[-1]
    _fence()
    agent._call_ai_query_impl("P", "PROMPT BODY", None, "s", skip_honesty_extraction=True)
    assert _sentinels(sink[-1]) == 1
    bridge = ah.AIAgentLLMBridge(agent, LOG)
    bridge.complete_json("SYS", ah.SYNTHESIS_SYSTEM_PROMPT)
    assert _sentinels(sink[-1]) == 1 and "{vibe_scope_fence}" not in sink[-1]
    bridge.complete_with_tools(ah.EXTRACTION_SYSTEM_PROMPT.format(outline_json="{}"), "CHUNK", [], {})
    assert _sentinels(sink[-1]) == 1 and "never drop a requirement because of scope" in sink[-1] and "{vibe_scope_" not in sink[-1]


class _CaptureLLM:
    def __init__(self):
        self.calls = []

    def complete_json(self, system, user, temperature=0.0, response_schema=None):
        self.calls.append((system, user))
        return {"mutator_source": "def mutator(model, data):\n    return model\n", "expected_changes_summary": "noop"}


def _batch():
    return ah.Batch("B1", ("V1",), "describe crew.member", (("crew", "member"),),
                    ({"intent": "describe crew.member", "target": "crew.member", "source_quote": "describe crew.member"},))


def _unique_hidden_product(marks):
    names = {}
    for d in _ENGINE["model"]["domains"]:
        for p in d.get("products") or d.get("data_products") or []:
            names.setdefault(p["name"], []).append((ah._vov285_san(d["name"]), ah._vov285_san(p["name"])))
    hidden = marks[0] - marks[1]
    return next(name for name, keys in sorted(names.items()) if len(keys) == 1 and keys[0] in hidden)


def test_synthesis_prompt_carries_block_and_frozen_digest():
    _fence()
    marks = ah._vibe_scope_digest_marks(_ENGINE)
    assert marks[1] and marks[0] - marks[1]
    hidden_name = _unique_hidden_product(marks)
    llm = _CaptureLLM()
    ah.synthesize_handler(_batch(), llm, model_snapshot=_ENGINE)
    user = llm.calls[-1][1]
    assert _sentinels(user) == 1 and "{vibe_scope_fence}" not in user
    assert '"frozen": true' in user and "VIBE SCOPE: products marked" in user
    assert f'"name": "{hidden_name}"' not in user
    ah.set_vibe_scope_runtime(None)
    ah.synthesize_handler(_batch(), llm, model_snapshot=_ENGINE)
    plain = llm.calls[-1][1]
    assert ah._VIBE_SCOPE_PROMPT_SENTINEL not in plain and '"frozen": true' not in plain and "{vibe_scope_" not in plain
    assert "VIBE SCOPE: products marked" not in plain


def test_synthesis_digest_lists_metric_view_names():
    small = copy.deepcopy(_ENGINE)
    crew = next(d for d in small["model"]["domains"] if d["name"] == "crew")
    crew["products"] = [p for p in crew["products"] if p["name"] in ("member", "base", "qualification")]
    small["model"]["domains"] = [crew]
    small["model"]["metric_views"] = [mv for mv in small["model"]["metric_views"] if mv.get("owner_domain") == "crew"]
    views = [mv["view_name"] for mv in small["model"]["metric_views"]]
    assert views and not [mv for mv in small["model"]["metric_views"] if "name" in mv]
    llm = _CaptureLLM()
    ah.synthesize_handler(_batch(), llm, model_snapshot=small)
    user = llm.calls[-1][1]
    assert "truncated at 16KB" not in user
    assert '"metric_views": ["' + '", "'.join(views) + '"]' in user


def test_selffixer_digest_marks_frozen_neighbours_and_is_unchanged_without_a_fence():
    assert _sha(ah._selffixer_model_digest(_ENGINE)) == GOLDEN_5D386ED["selffixer_digest_airlines"]
    _fence()
    marks = ah._vibe_scope_digest_marks(_ENGINE)
    digest = ah._selffixer_model_digest(_ENGINE)
    assert "[FROZEN]" in digest
    assert f"vibe_scope: {len(marks[0] - marks[1])} out-of-scope product(s) omitted" in digest
    assert f"{_unique_hidden_product(marks)}(pk=" not in digest
    assert "member(pk=member_id)" in digest and "member(pk=member_id) [FROZEN]" not in digest


def test_digest_marks_classify_adjacency():
    _fence()
    frozen, adjacent = ah._vibe_scope_digest_marks(_ENGINE)
    assert ("flight", "plan") in adjacent
    assert not {key for key in frozen if key[0] == "crew"}
    assert ah._vibe_scope_digest_state((frozen, adjacent), "crew", "member") == "open"
    assert ah._vibe_scope_digest_state((frozen, adjacent), "flight", "plan") == "frozen"
    assert ah._vibe_scope_digest_state(None, "flight", "plan") == "open"

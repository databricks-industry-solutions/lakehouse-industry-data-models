import ast
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import conftest  # noqa: F401,E402
import agent_helpers as ah  # noqa: E402

NB_PATH = Path(__file__).resolve().parents[2] / "agent" / "dbx_vibe_modelling_agent.ipynb"

# Function-name prefixes the deterministic SelfFixer fallback (v4.1.0) depends on. We extract every
# top-level def with these prefixes from the notebook and exec them into one namespace so the
# behavioral tests exercise the REAL production code path (no stubs), per CLAUDE.md §8.10.
_PREFIXES = ("_v410_", "_v251_", "_v337_", "_v327_")


def _build_ns():
    src = "\n".join(
        "".join(c.get("source", []))
        for c in json.loads(NB_PATH.read_text()).get("cells", [])
        if c.get("cell_type") == "code"
    )
    tree = ast.parse(src)
    keep = [n for n in tree.body if isinstance(n, ast.FunctionDef) and n.name.startswith(_PREFIXES)]
    mod = ast.Module(body=keep, type_ignores=[])
    ast.fix_missing_locations(mod)
    ns = dict(vars(ah), re=__import__("re"), copy=__import__("copy"))
    exec(compile(mod, str(NB_PATH), "exec"), ns)
    return ns


class _L:
    def info(self, *a, **k):
        pass

    def warning(self, *a, **k):
        pass


def _model():
    return {
        "model": {
            "domains": [
                {"name": "experience", "products": [
                    {"name": "program", "primary_key": "program_id",
                     "attributes": [{"name": "program_id", "type": "BIGINT"}]}
                ]},
                {"name": "property", "products": [
                    {"name": "property", "primary_key": "property_id",
                     "attributes": [{"name": "property_id", "type": "BIGINT"}]}
                ]},
                {"name": "reservation", "products": [
                    {"name": "reservation_booking", "primary_key": "reservation_booking_id",
                     "attributes": [{"name": "reservation_booking_id", "type": "BIGINT"},
                                    {"name": "room_type_requested", "type": "STRING"}]}
                ]},
                {"name": "inventory", "products": [
                    {"name": "room_type", "primary_key": "room_type_id",
                     "attributes": [{"name": "room_type_id", "type": "BIGINT"}]}
                ]},
                {"name": "procurement", "products": [
                    {"name": "benefit_plan", "primary_key": "benefit_plan_id",
                     "attributes": [{"name": "benefit_plan_id", "type": "BIGINT"}]}
                ]},
                {"name": "workforce", "products": [
                    {"name": "employee", "primary_key": "employee_id",
                     "attributes": [{"name": "employee_id", "type": "BIGINT"}]}
                ]},
            ]
        }
    }


def _attr(model, dom, prod, col):
    for d in model["model"]["domains"]:
        if d["name"] != dom:
            continue
        for p in d.get("products", []):
            if p["name"] != prod:
                continue
            for a in p.get("attributes", []):
                if a.get("name") == col:
                    return a
    return None


def test_v410_fix_functions_exist():
    # Fail-pre proof: on pre-patch HEAD these defs do not exist -> KeyError here.
    ns = _build_ns()
    for fn in ("_v410_resolve_pk", "_v410_parse_req_to_action", "_v410_deterministic_selffix"):
        assert fn in ns, fn


def test_v410_connect_table_adds_fk_deterministically():
    ns = _build_ns()
    model = _model()
    req = {"id": "VREQ-031",
           "text": "P2: Connect experience.program to property by adding a property_id column (BIGINT) with an FK to property.property.property_id because programs run at a property."}
    assert _attr(model, "experience", "program", "property_id") is None
    ok, ev = ns["_v410_deterministic_selffix"](model, req, _L())
    assert ok is True, ev
    a = _attr(model, "experience", "program", "property_id")
    assert a is not None and a.get("foreign_key_to") == "property.property.property_id", a


def test_v410_two_part_fk_resolves_pk_and_links():
    ns = _build_ns()
    model = _model()
    req = {"id": "VREQ-023",
           "text": "Add a missing foreign key from reservation.reservation_booking to inventory.room_type. Currently room_type_requested is just a string."}
    ok, ev = ns["_v410_deterministic_selffix"](model, req, _L())
    assert ok is True, ev
    # the existing room_type_requested column should now carry the resolved FK to the PK
    a = _attr(model, "reservation", "reservation_booking", "room_type_requested")
    assert a is not None and a.get("foreign_key_to") == "inventory.room_type.room_type_id", a


def test_v410_move_product_relocates_deterministically():
    ns = _build_ns()
    model = _model()
    req = {"id": "VREQ-046", "text": "P17: Move the product procurement.benefit_plan to the workforce domain because benefit plans are an HR function."}
    ok, ev = ns["_v410_deterministic_selffix"](model, req, _L())
    assert ok is True, ev
    proc = [d for d in model["model"]["domains"] if d["name"] == "procurement"][0]
    work = [d for d in model["model"]["domains"] if d["name"] == "workforce"][0]
    assert all(p["name"] != "benefit_plan" for p in proc.get("products", [])), "still in source"
    assert any(p["name"] == "benefit_plan" for p in work.get("products", [])), "not in target"


def test_v410_generative_req_returns_none_stays_on_llm():
    ns = _build_ns()
    model = _model()
    # generative expand -> no mechanical action -> must NOT be applied deterministically
    act = ns["_v410_parse_req_to_action"](
        "revenue.segment_program_eligibility is a thin product with only 5 attributes; expand it with additional relevant attributes.",
        model,
    )
    assert act is None


def test_v410_unresolvable_target_returns_none():
    ns = _build_ns()
    model = _model()
    # connect against a source product that does not exist -> conservative None (stay on LLM path)
    act = ns["_v410_parse_req_to_action"](
        "Connect ghost.missing to property by adding a property_id column with an FK to property.property.property_id.",
        model,
    )
    assert act is None


def test_v410_resolve_pk_prefers_declared_then_id_suffix():
    ns = _build_ns()
    model = _model()
    assert ns["_v410_resolve_pk"](model, "inventory", "room_type") == "room_type_id"

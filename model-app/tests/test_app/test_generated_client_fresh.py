"""The committed generated client matches the code (docs/conventions.md section 9).

``ui/lib/api.ts`` is generated from the backend OpenAPI and
``ui/types/routeTree.gen.ts`` from the files under ``ui/routes/``. Both are
committed, so a route or model change, or a rebase, can leave them stale. This
test compares, without running any generator:

- the OpenAPI of the real app (``backend.app.app``, its own router list) with
  ``api.ts``: the same operation ids, and per operation the same method and
  path;
- the files under ``ui/routes/`` with the imports in ``routeTree.gen.ts``.

Regenerate with ``apx dev check`` in ``src/app`` (or ``scripts/dev/regen_client.sh``
where the checkout has it). Property-level schema drift is not compared.
"""

from __future__ import annotations

import importlib
import logging
import re
from dataclasses import dataclass
from pathlib import Path

import pytest

UI = Path(__file__).resolve().parents[2] / "src/app/src/vibe_modeling/ui"
API_TS = UI / "lib" / "api.ts"
ROUTE_TREE = UI / "types" / "routeTree.gen.ts"
ROUTES = UI / "routes"

HTTP_METHODS = ("get", "post", "put", "patch", "delete")
REGEN_HINT = (
    "The generated client is stale. Regenerate it with `apx dev check` in src/app (or "
    "`bash scripts/dev/regen_client.sh` where the checkout has it) and commit the result; "
    "never edit it by hand (docs/conventions.md section 9)."
)

_EXPORT = re.compile(r"^export const (\w+) = async \(", re.M)
_FETCH_LITERAL = re.compile(r"fetch\((\"|`)(.*?)\1")
_URL_ELSE = re.compile(r"const url = queryString \? `[^`]*` : (\"|`)(.*?)\1;")
_METHOD = re.compile(r'method: "([A-Z]+)"')
_PARAM = re.compile(r"\$\{params\.(\w+)\}")
_ROUTE_IMPORT = re.compile(r"from '\./\.\./routes/([^']+)'")


@dataclass(frozen=True)
class Operation:
    method: str
    path: str


def openapi_operations(spec: dict) -> dict[str, Operation]:
    ops = {}
    for path, item in spec["paths"].items():
        for method in HTTP_METHODS:
            if method in item:
                ops[item[method]["operationId"]] = Operation(method.upper(), path)
    return ops


def client_operations(api_ts: str) -> dict[str, Operation]:
    """Operation id -> method and path of every ``export const <id> = async``."""
    ops = {}
    starts = list(_EXPORT.finditer(api_ts))
    for i, m in enumerate(starts):
        end = starts[i + 1].start() if i + 1 < len(starts) else len(api_ts)
        body = api_ts[m.end():end]
        url = _FETCH_LITERAL.search(body) or _URL_ELSE.search(body)
        method = _METHOD.search(body)
        path = _PARAM.sub(r"{\1}", url.group(2)) if url else "?"
        ops[m.group(1)] = Operation(method.group(1) if method else "GET", path)
    return ops


def stale_operations(spec_ops: dict[str, Operation], client_ops: dict[str, Operation]) -> list[str]:
    problems = []
    for op_id in sorted(spec_ops.keys() - client_ops.keys()):
        problems.append(f"missing from api.ts: {op_id} ({spec_ops[op_id].method} {spec_ops[op_id].path})")
    for op_id in sorted(client_ops.keys() - spec_ops.keys()):
        problems.append(f"in api.ts but not in the app: {op_id}")
    for op_id in sorted(spec_ops.keys() & client_ops.keys()):
        want, have = spec_ops[op_id], client_ops[op_id]
        if want != have:
            problems.append(f"{op_id}: app {want.method} {want.path}, api.ts {have.method} {have.path}")
    return problems


@pytest.fixture(scope="module")
def spec_ops() -> dict[str, Operation]:
    # Importing the app runs its logging.basicConfig(force=True). Restore the
    # root logger afterwards so the rest of the session logs as before and no
    # handler keeps pytest's capture stream past its end.
    root = logging.getLogger()
    handlers, level = root.handlers[:], root.level
    try:
        app = importlib.import_module("vibe_modeling.backend.app").app
        return openapi_operations(app.openapi())
    finally:
        root.handlers[:] = handlers
        root.setLevel(level)


@pytest.fixture(scope="module")
def client_text() -> str:
    return API_TS.read_text()


def test_root_logging_is_left_as_it_was(spec_ops) -> None:
    root = logging.getLogger()
    assert not any(
        type(h) is logging.StreamHandler for h in root.handlers
    ), "importing the app left its StreamHandler on the root logger"


def test_api_ts_matches_the_app_openapi(spec_ops, client_text) -> None:
    problems = stale_operations(spec_ops, client_operations(client_text))
    assert not problems, REGEN_HINT + "\n" + "\n".join(problems)


def test_every_client_function_was_parsed(client_text) -> None:
    ops = client_operations(client_text)
    assert ops, "no operations parsed from api.ts"
    unparsed = sorted(op_id for op_id, op in ops.items() if op.path == "?")
    assert not unparsed, f"could not read the fetch path of: {unparsed}"


def test_route_tree_matches_the_route_files() -> None:
    files = {
        p.relative_to(ROUTES).with_suffix("").as_posix()
        for p in ROUTES.rglob("*")
        if p.is_file() and p.suffix in (".tsx", ".ts")
    }
    imported = set(_ROUTE_IMPORT.findall(ROUTE_TREE.read_text()))
    problems = [f"not in routeTree.gen.ts: routes/{f}" for f in sorted(files - imported)]
    problems += [f"routeTree.gen.ts imports a missing file: routes/{f}" for f in sorted(imported - files)]
    assert not problems, REGEN_HINT + "\n" + "\n".join(problems)


def test_comparison_reports_a_removed_and_a_moved_operation(spec_ops, client_text) -> None:
    ops = client_operations(client_text)
    victim, moved = sorted(ops)[:2]
    tampered_text = re.sub(rf"^export const {victim} = async \(", "export const _gone = async (",
                           client_text, flags=re.M)
    tampered = client_operations(tampered_text)
    del tampered["_gone"]
    tampered[moved] = Operation(tampered[moved].method, tampered[moved].path + "/elsewhere")
    problems = stale_operations(spec_ops, tampered)
    assert any(p.startswith(f"missing from api.ts: {victim} ") for p in problems), problems
    assert any(p.startswith(f"{moved}: app ") and p.endswith("/elsewhere") for p in problems), problems


def test_client_parser_reads_query_string_and_path_params() -> None:
    sample = (
        "export const listThings = async (params?: P, options?: RequestInit): Promise<X> =>{\n"
        "    const url = queryString ? `/api/things/${params.thing_id}?${queryString}` : "
        "`/api/things/${params.thing_id}`;\n"
        "    const res = await fetch(url, {\n        ...options,\n        method: \"GET\"\n    });\n"
        "};\n"
        "export const makeThing = async (options?: RequestInit): Promise<X> =>{\n"
        "    const res = await fetch(\"/api/things\", {\n        method: \"POST\",\n    });\n"
        "};\n"
    )
    assert client_operations(sample) == {
        "listThings": Operation("GET", "/api/things/{thing_id}"),
        "makeThing": Operation("POST", "/api/things"),
    }

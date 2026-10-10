"""Build inventory of agent notebook symbols vs agent_helpers load surface."""
from __future__ import annotations

import ast
import json
from pathlib import Path
from typing import Any

REPO_ROOT = Path(__file__).resolve().parents[2]
NOTEBOOK_PATH = REPO_ROOT / "agent" / "dbx_vibe_modelling_agent.ipynb"


def notebook_code_cells() -> list[str]:
    nb = json.loads(NOTEBOOK_PATH.read_text(encoding="utf-8"))
    parts = []
    for cell in nb.get("cells", []):
        if cell.get("cell_type") != "code":
            continue
        src = cell.get("source", "")
        if isinstance(src, list):
            src = "".join(src)
        if src.strip():
            parts.append(src)
    return parts


def notebook_concat_source() -> str:
    return "\n\n".join(notebook_code_cells())


def notebook_symbol_inventory() -> dict[str, Any]:
    """AST inventory: module funcs, methods, nested (unique qualified names)."""
    source = notebook_concat_source()
    tree = ast.parse(source)
    by_name: dict[str, dict[str, Any]] = {}
    for node in tree.body:
        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
            by_name[node.name] = {"scope": "module", "name": node.name}
        elif isinstance(node, ast.ClassDef):
            for item in node.body:
                if isinstance(item, (ast.FunctionDef, ast.AsyncFunctionDef)):
                    q = f"{node.name}.{item.name}"
                    by_name[q] = {
                        "scope": "method",
                        "name": item.name,
                        "class": node.name,
                    }
    return {
        "module_functions": sorted(
            k for k, v in by_name.items() if v["scope"] == "module"
        ),
        "methods": sorted(k for k, v in by_name.items() if v["scope"] == "method"),
        "all_qualified": sorted(by_name.keys()),
        "counts": {
            "module_functions": sum(1 for v in by_name.values() if v["scope"] == "module"),
            "methods": sum(1 for v in by_name.values() if v["scope"] == "method"),
            "total": len(by_name),
        },
    }


def agent_helpers_surface() -> dict[str, Any]:
    import agent_helpers as ah

    funcs = sorted(
        k
        for k, v in ah.__dict__.items()
        if callable(v) and not k.startswith("__") and not isinstance(v, type)
    )
    classes = sorted(
        k for k, v in ah.__dict__.items() if isinstance(v, type) and not k.startswith("_")
    )
    return {
        "functions": funcs,
        "classes": classes,
        "load_errors": list(getattr(ah, "_load_errors", [])),
        "loaded_node_count": getattr(ah, "_loaded_node_count", None),
    }

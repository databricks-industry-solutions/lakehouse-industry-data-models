"""Drift lock: a caught database error is not stored or returned as text (E-11).

The text of a database or connection error carries the SQL statement, its
bound parameters and the Lakebase host. A catch site that keeps it in a stored
or returned error field (``error_message``, ``last_message``,
``last_poll_error``, ``sync_error_text``, ``sync_error``, ``progress_message``,
``error``, ``detail``) builds that value with
``error_sanitization.recorded_error_text`` (or ``unhandled_error_detail``, or
consults ``is_opaque_error``).

Scope of the rule, so it stays quiet:
- Only handlers that can catch a database error: ``except Exception``,
  ``BaseException``, a bare ``except``, or a SQLAlchemy / psycopg / requests
  class. A handler for ``ValueError``, ``NotFound`` or an app-defined error
  cannot receive a driver error.
- Only a value that reads the caught name as text: ``str(e)``, ``repr(e)``,
  ``{e}`` or ``{e!r}`` in an f-string, or ``type(e).__name__``-style
  attribute reads, assigned to an attribute or name, passed as a keyword, or
  put under a string key of a dict literal. An error passed on as a plain
  positional argument is not seen.
- ``sanitize_error_message`` alone does not clear a site: it redacts paths
  and tokens, not SQL. A site where it is enough is allow-listed below with
  the reason.
"""

from __future__ import annotations

import ast

from ._source_scan import BACKEND, iter_files

FIELDS = frozenset({
    "error_message", "last_message", "last_poll_error", "sync_error_text",
    "sync_error", "progress_message", "error", "detail",
})
CLEARING_CALLS = frozenset({"recorded_error_text", "unhandled_error_detail", "is_opaque_error"})
_WIDE = frozenset({"Exception", "BaseException", "<bare>"})
_DB_CLASS_MARKERS = ("SQLAlchemy", "DBAPI", "OperationalError", "IntegrityError", "psycopg", "RequestException")

_SDK_ONLY = "wraps one Databricks SDK call; the error cannot be a database error"
ALLOWED: dict[tuple[str, str, str], str] = {
    ("_artifact_io.py", "read_artifact_bytes", "detail"): _SDK_ONLY + " (Volume file read)",
    ("assessment/job_sync.py", "sync_assessment_job", "error"): _SDK_ONLY + " (job and permission calls)",
    ("core/_agent_identity.py", "installed_identity", "error"): _SDK_ONLY + " (file read), and the text is sanitized",
    ("explorer.py", "_read_volume_json", "detail"): _SDK_ONLY + " (Volume file read)",
    ("routes/config.py", "set_agent_config", "detail"): _SDK_ONLY + " (job creation)",
    ("routes/platform.py", "list_catalogs", "detail"): _SDK_ONLY + " (catalog list)",
    ("routes/uc_browse.py", "browse_volumes", "detail"): _SDK_ONLY + " (Unity Catalog browse)",
    ("routes/versions.py", "reconcile_installation", "detail"): _SDK_ONLY + " (schema list)",
    ("routes/versions.py", "import_version_from_volume", "detail"): _SDK_ONLY + " (Volume file read)",
    ("services/operations/_install_conventions.py", "_worker", "error"): _SDK_ONLY + " (file download), kept as an object",
    ("services/operations/generate_samples.py", "observe", "progress_message"): "poll error around ws.jobs.get_run only",
    ("services/operations/install.py", "observe", "progress_message"): "poll error around ws.jobs.get_run only",
    ("services/operations/uninstall.py", "observe", "progress_message"): "poll error around ws.jobs.get_run only",
    ("services/operations/import_from_volume.py", "dispatch", "error"): _SDK_ONLY + " (Volume download)",
    ("services/operations/snapshot_version.py", "dispatch", "error"): _SDK_ONLY + " (Volume upload)",
    ("services/operations/vibe_iterate.py", "observe", "error"): _SDK_ONLY + " (model.json download)",
}


def _names(node: ast.expr | None) -> list[str]:
    if node is None:
        return ["<bare>"]
    if isinstance(node, ast.Tuple):
        return [n for e in node.elts for n in _names(e)]
    if isinstance(node, ast.Name):
        return [node.id]
    if isinstance(node, ast.Attribute):
        return [node.attr]
    return ["?"]


def _catches_db_errors(types: list[str]) -> bool:
    return any(t in _WIDE or any(m in t for m in _DB_CLASS_MARKERS) for t in types)


def _field(target: ast.AST) -> str | None:
    if isinstance(target, ast.Attribute):
        return target.attr
    if isinstance(target, ast.Name):
        return target.id
    if isinstance(target, ast.Subscript) and isinstance(target.slice, ast.Constant):
        return target.slice.value if isinstance(target.slice.value, str) else None
    return None


def _reads_as_text(value: ast.AST, name: str) -> bool:
    return any(isinstance(n, ast.Name) and n.id == name for n in ast.walk(value))


def _clears(value: ast.AST) -> bool:
    return any(
        isinstance(n, ast.Call) and getattr(n.func, "id", getattr(n.func, "attr", None)) in CLEARING_CALLS
        for n in ast.walk(value)
    )


def _stores(handler: ast.ExceptHandler):
    """``(field, value, line)`` for each field-named store in the handler body."""
    for stmt in handler.body:
        for node in ast.walk(stmt):
            if isinstance(node, ast.Assign):
                for target in node.targets:
                    yield _field(target), node.value, node.lineno
            elif isinstance(node, ast.AugAssign):
                yield _field(node.target), node.value, node.lineno
            elif isinstance(node, ast.keyword) and node.arg:
                yield node.arg, node.value, node.value.lineno
            elif isinstance(node, ast.Dict):
                for key, value in zip(node.keys, node.values):
                    if isinstance(key, ast.Constant) and isinstance(key.value, str):
                        yield key.value, value, value.lineno


class _Scan(ast.NodeVisitor):
    def __init__(self) -> None:
        self.found: list[tuple[str, str, int]] = []
        self._functions: list[str] = []

    def _function(self, node) -> None:
        self._functions.append(node.name)
        self.generic_visit(node)
        self._functions.pop()

    visit_FunctionDef = visit_AsyncFunctionDef = _function

    def visit_ExceptHandler(self, node: ast.ExceptHandler) -> None:
        if node.name and _catches_db_errors(_names(node.type)):
            for field, value, line in _stores(node):
                if field in FIELDS and _reads_as_text(value, node.name) and not _clears(value):
                    self.found.append((self._functions[-1] if self._functions else "<module>", field, line))
        self.generic_visit(node)


def scan_source(source: str) -> list[tuple[str, str, int]]:
    """``(function, field, line)`` of each unclear store of caught-error text."""
    scan = _Scan()
    scan.visit(ast.parse(source))
    return scan.found


def test_no_caught_error_text_is_stored_or_returned_unclear():
    offenders: list[str] = []
    seen: set[tuple[str, str, str]] = set()
    for path, rel in iter_files(BACKEND, exempt=()):
        if rel.startswith("migrations/"):
            continue
        for function, field, line in scan_source(path.read_text()):
            key = (rel, function, field)
            if key in ALLOWED:
                seen.add(key)
            else:
                offenders.append(f"{rel}:{line} {function}() stores caught-error text in {field!r}")
    assert not offenders, (
        "A caught database or connection error must not be kept as text. Build the value with "
        "error_sanitization.recorded_error_text (docs/conventions.md section 6), or allow-list the site "
        "in ALLOWED with the reason it cannot receive a database error:\n" + "\n".join(offenders)
    )
    stale = sorted(set(ALLOWED) - seen)
    assert not stale, f"ALLOWED entries that no longer match a store: {stale}"


class TestScanner:
    """One snippet per form, so a loosened scanner fails here."""

    LEAKS = {
        "assign str": "def f(run):\n    try:\n        pass\n    except Exception as e:\n        run.error_message = str(e)\n",
        "assign repr": "def f(run):\n    try:\n        pass\n    except Exception as e:\n        run.last_poll_error = repr(e)\n",
        "fstring": "def f(r):\n    try:\n        pass\n    except Exception as e:\n        r.progress_message = f'x {e!r}'\n",
        "sanitize only": "def f(r):\n    try:\n        pass\n    except Exception as e:\n        r.error_message = sanitize_error_message(str(e))\n",
        "keyword": "def f(r):\n    try:\n        pass\n    except Exception as e:\n        g(error_message=f'{e}')\n",
        "dict key": "def f():\n    try:\n        pass\n    except Exception as e:\n        return {'error': str(e)}\n",
        "http detail": "def f():\n    try:\n        pass\n    except Exception as e:\n        raise HTTPException(500, detail=f'x {e}')\n",
        "db class": "def f(r):\n    try:\n        pass\n    except SQLAlchemyError as e:\n        r.sync_error_text = str(e)[:500]\n",
        "bare except tuple": "def f(r):\n    try:\n        pass\n    except (ValueError, Exception) as e:\n        r.error_message = str(e)\n",
    }

    def test_each_form_is_found(self):
        for name, source in self.LEAKS.items():
            assert scan_source(source), name

    def test_cleared_and_out_of_scope_stores_are_quiet(self):
        quiet = {
            "recorded": "def f(r):\n    try:\n        pass\n    except Exception as e:\n        r.error_message = recorded_error_text(e, 'x', str(e))\n",
            "unhandled": "def f(r):\n    try:\n        pass\n    except Exception as e:\n        r.error_message = unhandled_error_detail(e)\n",
            "predicate": "def f(r):\n    try:\n        pass\n    except Exception as e:\n        r.error_message = 'x' if is_opaque_error(e) else str(e)\n",
            "narrow": "def f(r):\n    try:\n        pass\n    except ValueError as e:\n        r.error_message = str(e)\n",
            "other field": "def f(r):\n    try:\n        pass\n    except Exception as e:\n        r.name = str(e)\n",
            "no name": "def f(r):\n    try:\n        pass\n    except Exception:\n        r.error_message = 'failed'\n",
        }
        for name, source in quiet.items():
            assert not scan_source(source), name

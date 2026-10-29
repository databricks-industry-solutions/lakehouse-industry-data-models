"""Drift lock: a version's install state has one writer (addendum design 10.2, R6).

``ModelVersion.deployment_status`` and ``ModelVersion.uc_catalog`` mirror the
version's open ``model_version_installs`` rows. Only
``services/operations/_version_lifecycle.py`` (and the migrations) may write
any of them, so the rows and the columns cannot disagree.

The lock parses every backend module and fails on these write forms:

* an attribute assignment (``mv.uc_catalog = ...``, augmented, annotated or
  in a tuple), and one to an install row's own columns (``uninstalled_at``,
  ``installed_at``, ``uninstalled_by_run_id``, ``installed_by_run_id``);
* a ``ModelVersion(...)`` keyword, a value passed in a variable included
  (``deployment_status=status``); ``deployment_status="draft"`` at creation
  is the one exception;
* a dict with those keys, literal or held in a variable (``kw = {...}``,
  ``kw["uc_catalog"] = ...``), passed to ``ModelVersion(**kw)``,
  ``ModelVersion.model_validate``, ``sqlmodel_update``, ``.values``,
  ``Query.update``, ``bulk_update_mappings`` / ``bulk_insert_mappings`` or
  ``execute(stmt, [rows])``, also inside a list of rows;
* ``setattr(obj, "deployment_status" | "uc_catalog", ...)``;
* ``update`` / ``insert`` / ``delete`` of ``ModelVersionInstall`` and
  ``ModelVersionInstall(...)``;
* SQL text that updates or inserts those ``model_versions`` columns, or that
  updates, inserts into or deletes from ``model_version_installs``.

Not detectable from the source alone, so not locked: ``session.delete(row)``
of an install row held in a variable (its type is not in the AST), and a dict
built by a function call rather than a literal or a subscript assignment.
The rows also go by ON DELETE CASCADE with their version, which is not a
write here.

The detector is tested on one snippet per form, so a lock that silently stops
matching fails too.
"""
from __future__ import annotations

import ast
import re
from pathlib import Path

import pytest

BACKEND = Path(__file__).resolve().parents[2] / "src" / "app" / "src" / "vibe_modeling" / "backend"
OWNER = BACKEND / "services" / "operations" / "_version_lifecycle.py"
MIGRATIONS = BACKEND / "migrations"

FIELDS = frozenset({"deployment_status", "uc_catalog"})
INSTALL_ROW_FIELDS = frozenset({"uninstalled_at", "installed_at", "uninstalled_by_run_id", "installed_by_run_id"})
ALLOWED_CREATION = ("deployment_status", "draft")
INSTALL_ROW = "ModelVersionInstall"
# Calls whose dict (or list of dicts) arguments become column values.
ROW_WRITE_CALLS = frozenset({
    "ModelVersion", "values", "update", "sqlmodel_update", "bulk_update_mappings",
    "bulk_insert_mappings", "execute",
})

_SQL_WRITE = re.compile(
    r"\bUPDATE\s+[\w.\"`]*model_versions\b.*?\bSET\b.*?\b(deployment_status|uc_catalog)\b"
    r"|\bINSERT\s+INTO\s+[\w.\"`]*model_versions\b[^)]*\b(deployment_status|uc_catalog)\b"
    r"|\b(UPDATE|INSERT\s+INTO|DELETE\s+FROM)\s+[\w.\"`]*model_version_installs\b",
    re.IGNORECASE | re.DOTALL,
)


def _call_name(func: ast.expr) -> str:
    if isinstance(func, ast.Name):
        return func.id
    if isinstance(func, ast.Attribute):
        return func.attr
    return ""


def _dict_keys(node: ast.expr) -> set[str]:
    if isinstance(node, ast.Dict):
        return {k.value for k in node.keys if isinstance(k, ast.Constant) and isinstance(k.value, str)}
    return set()


def _string_of(node: ast.expr) -> str:
    if isinstance(node, ast.Constant) and isinstance(node.value, str):
        return node.value
    if isinstance(node, ast.JoinedStr):
        return "".join(v.value for v in node.values if isinstance(v, ast.Constant) and isinstance(v.value, str))
    return ""


def _targets(node: ast.AST) -> list[ast.expr]:
    if isinstance(node, ast.Assign):
        out: list[ast.expr] = []
        for target in node.targets:
            out.extend(target.elts if isinstance(target, (ast.Tuple, ast.List)) else [target])
        return out
    if isinstance(node, (ast.AugAssign, ast.AnnAssign)):
        return [node.target]
    return []


def _field_dict_names(tree: ast.AST) -> set[str]:
    """Variables that hold a dict with an install-state key: ``kw = {...}``
    or ``kw["uc_catalog"] = ...``."""
    names: set[str] = set()
    for node in ast.walk(tree):
        if isinstance(node, ast.Assign) and _dict_keys(node.value) & FIELDS:
            names.update(t.id for t in node.targets if isinstance(t, ast.Name))
        for target in _targets(node):
            if (
                isinstance(target, ast.Subscript) and isinstance(target.value, ast.Name)
                and _string_of(target.slice) in FIELDS
            ):
                names.add(target.value.id)
    return names


def _carries_fields(node: ast.expr, dict_names: set[str]) -> bool:
    if _dict_keys(node) & FIELDS:
        return True
    if isinstance(node, ast.Name) and node.id in dict_names:
        return True
    if isinstance(node, (ast.List, ast.Tuple)):
        return any(_carries_fields(e, dict_names) for e in node.elts)
    return False


def install_state_writes(source: str) -> list[tuple[int, str]]:
    """``(line, form)`` of every install-state write in ``source``."""
    tree = ast.parse(source)
    dict_names = _field_dict_names(tree)
    found: list[tuple[int, str]] = []
    for node in ast.walk(tree):
        for target in _targets(node):
            if isinstance(target, ast.Attribute) and target.attr in FIELDS | INSTALL_ROW_FIELDS:
                found.append((node.lineno, f"assignment to .{target.attr}"))
        if isinstance(node, ast.Call):
            name = _call_name(node.func)
            receiver = node.func.value if isinstance(node.func, ast.Attribute) else None
            first = node.args[0] if node.args else None
            if name == INSTALL_ROW:
                found.append((node.lineno, f"{INSTALL_ROW}(...)"))
            if name in ("update", "insert", "delete") and isinstance(first, ast.Name) and first.id == INSTALL_ROW:
                found.append((node.lineno, f"{name}({INSTALL_ROW})"))
            if name == "setattr" and len(node.args) >= 2 and _string_of(node.args[1]) in FIELDS:
                found.append((node.lineno, f"setattr(..., {_string_of(node.args[1])!r})"))
            writes_rows = name in ROW_WRITE_CALLS or (
                name == "model_validate" and isinstance(receiver, ast.Name) and receiver.id == "ModelVersion"
            )
            if writes_rows:
                for kw in node.keywords:
                    if kw.arg in FIELDS and name in ("ModelVersion", "values"):
                        value = kw.value.value if isinstance(kw.value, ast.Constant) else None
                        if name == "ModelVersion" and (kw.arg, value) == ALLOWED_CREATION:
                            continue
                        found.append((node.lineno, f"{name}({kw.arg}=...)"))
                    elif kw.arg is None and _carries_fields(kw.value, dict_names):
                        found.append((node.lineno, f"{name}(**{{...}})"))
                for arg in node.args:
                    if _carries_fields(arg, dict_names):
                        found.append((node.lineno, f"{name}({{...}})"))
        text = _string_of(node) if isinstance(node, (ast.Constant, ast.JoinedStr)) else ""
        if text and _SQL_WRITE.search(text):
            found.append((getattr(node, "lineno", 0), "SQL write to model_versions / model_version_installs"))
    return found


def _scanned_modules() -> list[Path]:
    return sorted(
        p for p in BACKEND.rglob("*.py")
        if p != OWNER and MIGRATIONS not in p.parents
    )


def test_the_backend_tree_is_found():
    assert OWNER.is_file()
    assert len(_scanned_modules()) > 100


def test_only_the_version_lifecycle_writes_install_state():
    offenders = [
        f"{path.relative_to(BACKEND)}:{line}: {form}"
        for path in _scanned_modules()
        for line, form in install_state_writes(path.read_text())
    ]
    assert not offenders, (
        "Install state (ModelVersion.deployment_status / uc_catalog and model_version_installs rows) "
        "is written only through services/operations/_version_lifecycle.py "
        "(mark_version_deployed, mark_version_uninstalled, evict_deployed_siblings, "
        "restore_evicted_deployments):\n" + "\n".join(offenders)
    )


def test_the_owner_writes_through_the_rows():
    """The owner itself writes these columns (otherwise the lock guards nothing)."""
    forms = {form for _, form in install_state_writes(OWNER.read_text())}
    assert {
        "assignment to .deployment_status", "assignment to .uc_catalog", "assignment to .uninstalled_at",
        "ModelVersionInstall(...)",
    } <= forms


@pytest.mark.parametrize(
    "snippet",
    [
        "mv.deployment_status = 'deployed'",
        "mv.uc_catalog = catalog",
        "mv.deployment_status: str = 'uninstalled'",
        "mv.uc_catalog += ''",
        "a.uc_catalog, b = x, y",
        "ModelVersion(business_id=b, uc_catalog=catalog)",
        "ModelVersion(business_id=b, deployment_status='deployed')",
        "status = 'deployed' if c else 'draft'\nModelVersion(deployment_status=status)",
        "models.ModelVersion(uc_catalog='')",
        "ModelVersion(**{'uc_catalog': c})",
        "setattr(mv, 'deployment_status', 'deployed')",
        "update(ModelVersion).values(deployment_status='uninstalled')",
        "update(ModelVersion).values({'uc_catalog': 'x'})",
        "session.execute(text('UPDATE model_versions SET deployment_status = :s WHERE id = :i'))",
        "sql = ('UPDATE model_versions '\n       'SET uc_catalog = :c')",
        "sql = f'UPDATE {schema}.model_versions SET uc_catalog = {c!r}'",
        "sql = 'INSERT INTO model_versions (id, uc_catalog) VALUES (:i, :c)'",
        "session.add(ModelVersionInstall(version_id=v, catalog=c))",
        "session.query(ModelVersion).filter(ModelVersion.id == i).update({'uc_catalog': c})",
        "session.bulk_update_mappings(ModelVersion, [{'id': i, 'deployment_status': 'deployed'}])",
        "session.execute(update(ModelVersion), [{'id': i, 'uc_catalog': c}])",
        "mv.sqlmodel_update({'uc_catalog': c})",
        "ModelVersion.model_validate({'uc_catalog': c, 'business_id': b})",
        "row.uninstalled_at = now",
        "row.installed_by_run_id = run_id",
        "text('UPDATE model_version_installs SET uninstalled_at = now()')",
        "'DELETE FROM model_version_installs WHERE version_id = :v'",
        "update(ModelVersionInstall).values(uninstalled_at=now)",
        "delete(ModelVersionInstall).where(ModelVersionInstall.version_id == v)",
        "kw = {'uc_catalog': c}\nModelVersion(**kw)",
        "d = {'uc_catalog': c}\nupdate(ModelVersion).values(d)",
        "d = {}\nd['deployment_status'] = 'deployed'\nsession.execute(update(ModelVersion), [d])",
        "'update public.model_versions mv set uc_catalog = :c'",
    ],
)
def test_each_write_form_is_caught(snippet):
    assert install_state_writes(snippet), snippet


@pytest.mark.parametrize(
    "snippet",
    [
        "ModelVersion(business_id=b, status='draft', deployment_status='draft')",
        "catalog = mv.uc_catalog",
        "deployment_status = mv.deployment_status",
        "VersionTreeOut(deployment_status=v.deployment_status, uc_catalog=v.uc_catalog)",
        "if mv.deployment_status == 'deployed': pass",
        "select(ModelVersion).where(ModelVersion.uc_catalog == c)",
        "'SELECT uc_catalog FROM model_versions WHERE deployment_status = :s'",
        "out.model_copy(update={'is_head': True})",
        "out.model_copy(update={'deployment_status': 'deployed'})",
        "ModelVersionOut.model_validate(mv, from_attributes=True)",
        "payload = {'uc_catalog': mv.uc_catalog}\nreturn JSONResponse(payload)",
        "select(ModelVersionInstall).where(ModelVersionInstall.uninstalled_at.is_(None))",
        "'SELECT catalog FROM model_version_installs WHERE uninstalled_at IS NULL'",
    ],
)
def test_reads_and_the_draft_default_pass(snippet):
    assert install_state_writes(snippet) == [], snippet

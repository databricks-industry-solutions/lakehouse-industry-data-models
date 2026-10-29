"""Drift locks for the platform rules in docs/conventions.md sections 3-5.

Shared folder. Files the app creates live under the app service principal's
home (``core/_app_identity.app_sp_home``). ``/Workspace/Shared`` is writable by
every workspace user, so no ``/Workspace/Shared`` or ``/Shared/`` literal may
appear in the backend, the installer, the vendored notebooks or
``databricks.yml``.

Grants. The app grants only on objects it owns. Grant and permission calls
(``.grants.update(``, ``.permissions.update(``, ``.permissions.set(``,
``set_permissions(``, ``update_permissions(``) appear only in the modules
listed in ``GRANT_ALLOWED``, each with its reason. Adding a module needs a
maintainer's agreement in the PR.

Model calls. Models are called as Unity Catalog model services through the AI
Gateway. The backend and the installer contain no ``serving_endpoints.query``,
no ``/serving-endpoints/`` or ``/invocations`` path and no ``openai`` import,
and the ``/ai-gateway/`` path appears only in the model client
(``MODEL_CLIENT``). ``serving_endpoints.http_request`` calls Unity Catalog HTTP
connections, a different API, and is allowed.
"""

from __future__ import annotations

import re

from ._source_scan import BACKEND, INSTALL, REPO, VENDORED, is_comment, iter_files, read_text, line_of

_SHARED_LITERAL = re.compile(r"/Workspace/Shared\b|[\"']/Shared/")

GRANT_ALLOWED = {
    "src/app/src/vibe_modeling/backend/assessment/job_sync.py": (
        "reader SP on the app's runs volume and _metamodel schema; job folder ACL"
    ),
    "install/grant_catalog.py": "installer: the app SP on the deployment catalog",
}
_GRANT_CALL = re.compile(
    r"\.grants\.update\(|\.permissions\.(?:update|set)\(|\b(?:set|update)_permissions\("
)

MODEL_CLIENT = "src/app/src/vibe_modeling/backend/taxonomy/llm.py"
_LEGACY_MODEL_CALL = re.compile(
    r"serving_endpoints\.query\b|/serving-endpoints/|/invocations\b"
    r"|^\s*(?:import\s+openai\b|from\s+openai\b)",
    re.M,
)
_GATEWAY_PATH = re.compile(r"/ai-gateway/")


def _app_sources(suffixes=(".py",)):
    for root in (BACKEND, INSTALL):
        for path, _rel in iter_files(root, suffixes):
            yield path, path.relative_to(REPO).as_posix()


def _offenders(pattern: re.Pattern[str], files, skip_comments: bool) -> list[str]:
    found = []
    for path, rel in files:
        text = read_text(path)
        if text is None:
            continue
        for m in pattern.finditer(text):
            line_no = line_of(text, m.start())
            line = text.splitlines()[line_no - 1]
            if skip_comments and is_comment(line):
                continue
            found.append(f"{rel}:{line_no}: {line.strip()[:120]}")
    return found


def test_no_shared_workspace_folder() -> None:
    files = []
    for root in (BACKEND, INSTALL, VENDORED):
        files += [(p, p.relative_to(REPO).as_posix()) for p, _ in iter_files(root, None)]
    files.append((REPO / "databricks.yml", "databricks.yml"))
    offenders = _offenders(_SHARED_LITERAL, files, skip_comments=False)
    assert not offenders, (
        "A /Workspace/Shared path is writable by every workspace user. Put app files "
        "under core/_app_identity.app_sp_home(ws) (docs/conventions.md section 3):\n"
        + "\n".join(offenders)
    )


def test_grant_calls_only_in_allowed_modules() -> None:
    files = [(p, rel) for p, rel in _app_sources() if rel not in GRANT_ALLOWED]
    offenders = _offenders(_GRANT_CALL, files, skip_comments=True)
    assert not offenders, (
        "Grant or permission call outside the allow-list. The app grants only on objects "
        "it owns; for anything else, check access read-only and show the admin the "
        "command (docs/conventions.md section 4). Extending GRANT_ALLOWED needs a "
        "maintainer's agreement:\n" + "\n".join(offenders)
    )


def test_allowed_grant_modules_still_grant() -> None:
    for rel, reason in GRANT_ALLOWED.items():
        assert reason
        text = (REPO / rel).read_text()
        assert _GRANT_CALL.search(text), f"{rel} no longer grants; drop it from GRANT_ALLOWED"


def test_no_legacy_model_calls() -> None:
    offenders = _offenders(_LEGACY_MODEL_CALL, _app_sources(), skip_comments=True)
    assert not offenders, (
        "Call models as Unity Catalog model services through the AI Gateway, not legacy "
        "serving endpoints or an OpenAI client (docs/conventions.md section 5):\n"
        + "\n".join(offenders)
    )


def test_ai_gateway_path_only_in_the_model_client() -> None:
    files = [(p, rel) for p, rel in _app_sources() if rel != MODEL_CLIENT]
    offenders = _offenders(_GATEWAY_PATH, files, skip_comments=True)
    assert not offenders, (
        f"Only {MODEL_CLIENT} calls the AI Gateway. A second feature that calls a model "
        "moves that client into a shared module first (docs/conventions.md section 5):\n"
        + "\n".join(offenders)
    )
    assert _GATEWAY_PATH.search((REPO / MODEL_CLIENT).read_text())


def test_patterns_match_the_banned_shapes() -> None:
    assert _SHARED_LITERAL.search('FOLDER = "/Workspace/Shared/vibe-modeling"')
    assert _SHARED_LITERAL.search("path = '/Shared/x'")
    assert _SHARED_LITERAL.search('"path": "/Workspace/Shared"')
    assert not _SHARED_LITERAL.search('f"/Workspace/Users/{sp}/vibe"')
    assert not _SHARED_LITERAL.search("shared_folder = home")

    assert _GRANT_CALL.search("ws.grants.update(securable_type, name, changes=[])")
    assert _GRANT_CALL.search("w.permissions.update('directories', oid)")
    assert _GRANT_CALL.search("ws.permissions.set('jobs', jid, access_control_list=[])")
    assert _GRANT_CALL.search("ws.jobs.set_permissions(job_id=1)")
    assert _GRANT_CALL.search("ws.workspace.update_permissions(...)")
    assert not _GRANT_CALL.search("ws.grants.get(securable_type, name)")
    assert not _GRANT_CALL.search("ws.permissions.get('jobs', jid)")

    assert _LEGACY_MODEL_CALL.search("ws.serving_endpoints.query(name='x')")
    assert _LEGACY_MODEL_CALL.search('url = f"/serving-endpoints/{name}/invocations"')
    assert _LEGACY_MODEL_CALL.search("import openai")
    assert _LEGACY_MODEL_CALL.search("    from openai import OpenAI")
    assert not _LEGACY_MODEL_CALL.search("ws.serving_endpoints.http_request(conn='gh')")
    assert not _LEGACY_MODEL_CALL.search("# OpenAI-compatible request body")

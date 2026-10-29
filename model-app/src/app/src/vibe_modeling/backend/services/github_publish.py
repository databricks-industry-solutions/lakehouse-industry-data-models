"""Publish an exported model version to GitHub as a single pull request.

The publish flow is the write-side sibling of the read-only bundle export
(``model_export.build_bundle_zip_bytes``): it reconstructs the version's
``model.json`` + companion artifacts via the SAME single-source iterator
(:func:`model_export.iter_bundle_files`) so the published tree and the
downloadable zip can never diverge on layout, then pushes every file to a
fresh branch on the configured GitHub repo through the Unity Catalog HTTP
connection and opens one PR. The published files lose the schema and view
prefixes a 0.9.0 import added (:class:`PublishStrip`); the zip keeps the
app's names.

Auth is OAuth U2M only for now: the request is shaped through the user's
own WorkspaceClient (OBO) against a UC HTTP connection
(``AgentConfig.github_connection_name``) so the commits are attributed to the
acting user. The secret-PAT fallback is NOT implemented yet — it returns a
clear 422 rather than silently doing nothing.

This module deliberately does the HTTP shaping itself (rather than reusing the
read-side ``sources/github.py`` client) because that client speaks the SDK's
plain ``requests`` path against the public read mirror, whereas publish must go
through the UC connection's ``serving_endpoints.http_request`` so the token
never touches the app. The two share only the default-repo constants.
"""

from __future__ import annotations

import base64
import copy
import json
import logging
from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Any, Iterable, Optional

from databricks.sdk.service.serving import ExternalFunctionRequestHttpMethod
from fastapi import HTTPException
from sqlmodel import Session, select

from .._artifact_io import artifact_path_suffix, read_artifact_bytes
from ..db_models import AgentConfig, Business, Domain, ModelVersion, Run, RunArtifact
from ..model_export import (
    bundle_layout,
    export_model_json,
    iter_bundle_files,
    resolve_bundle_root,
)
from ..sources.github import DEFAULT_REPO_NAME, DEFAULT_REPO_OWNER
from .operations._install_conventions import REQUIRED_READ_TIMEOUT_S, read_volume_bytes
from .scope_prefix import (
    metric_view_names,
    schema_strip_map,
    strip_import_prefix,
    strip_import_prefix_sql,
)
from .version_files import read_conventions, version_model_json_candidates

logger = logging.getLogger(__name__)


@dataclass(frozen=True)
class PublishResult:
    """Outcome of a successful publish."""

    branch: str
    pr_number: int
    pr_url: str
    files: list[str] = field(default_factory=list)
    target_path: str = ""


def _http_json(resp) -> dict:
    """Parse the JSON body of a UC ``http_request`` response.

    ``ServingEndpointsExt.http_request`` returns a ``requests.Response`` whose
    body is on ``.text``. A base ``HttpRequestResponse`` instead exposes a
    ``contents`` stream. Handle both; returns ``{}`` on an empty/unparseable body.
    """
    text = getattr(resp, "text", None)
    if isinstance(text, str):
        if not text:
            return {}
        try:
            return json.loads(text)
        except (ValueError, TypeError):
            return {}
    contents = getattr(resp, "contents", None)
    if contents is None:
        return {}
    raw = contents.read() if hasattr(contents, "read") else contents
    if isinstance(raw, bytes):
        raw = raw.decode("utf-8", errors="replace")
    if not raw:
        return {}
    try:
        return json.loads(raw)
    except (ValueError, TypeError):
        return {}


# --- The prefixes an import added (stripped on publish) --------------------


def _unreadable(mv: ModelVersion, path: str) -> HTTPException:
    """The refusal when a file the strip needs cannot be read: nothing is
    published, so the repository never gets the app's prefixed names."""
    label = f"v{mv.version} {(mv.scope or '').upper()}".strip()
    return HTTPException(
        status_code=502,
        detail={
            "message": (
                f"Could not read the model file of {label} to remove the prefixes "
                "the app added at import. Nothing was published; try again."
            ),
            "path": path,
        },
    )


@dataclass(frozen=True)
class PublishStrip:
    """What a publish removes: the schema and view prefixes a 0.9.0 import
    added (``services/scope_prefix``), so the industry repository gets the
    names it had. ``schema_map`` is ``prefixed -> original`` (lower-case
    keys); ``view_names`` are the version's metric view names, which a
    stripped view name must not take; ``model_files`` holds each
    ``model_json`` artifact read once, by Volume path: its bytes and the
    parsed model dict (``None`` when the file is not a JSON object). Nothing
    to strip: both prefixes empty."""

    schema_prefix: str = ""
    view_prefix: str = ""
    schema_map: dict[str, str] = field(default_factory=dict)
    view_names: tuple[str, ...] = ()
    model_files: dict[str, tuple[bytes, Any]] = field(default_factory=dict, compare=False)

    @property
    def active(self) -> bool:
        return bool(self.schema_map or self.view_prefix)

    def model_json(self, root: Any, view_names: Iterable[str] = ()) -> Any:
        """Strip ``root`` (a model.json, changed in place); returns it.
        ``view_names`` adds names in use to :attr:`view_names`."""
        if not self.active:
            return root
        return strip_import_prefix(
            root,
            self.schema_prefix if self.schema_map else "",
            self.view_prefix,
            self.schema_map,
            (*self.view_names, *view_names),
        )

    def read(self, ws: Any, artifact: RunArtifact) -> bytes:
        """The bytes to publish for ``artifact``: a ``model_json`` artifact
        (from :attr:`model_files`) and a ``.sql`` file stripped, anything
        else as read. A file the strip does not change, or that is not a JSON
        object, keeps its bytes. A stripped model.json is written with
        ``indent=2``, non-ASCII characters kept as such when the file had
        any."""
        cached = self.model_files.get(artifact.file_path)
        if cached is not None:
            data, root = cached
            if self.active and isinstance(root, dict):
                stripped = self.model_json(copy.deepcopy(root), metric_view_names(root))
                if stripped != root:
                    return json.dumps(stripped, indent=2, ensure_ascii=data.isascii()).encode("utf-8")
            return data
        data = read_artifact_bytes(ws, artifact.file_path)
        if self.active and artifact_path_suffix(artifact.file_path) == ".sql":
            try:
                text = data.decode("utf-8")
            except UnicodeDecodeError:
                logger.warning("publish: %s is not UTF-8; published as is", artifact.file_path)
                return data
            out = strip_import_prefix_sql(text, self.schema_map, self.view_prefix, self.view_names)
            return data if out == text else out.encode("utf-8")
        return data


def _json_object(data: bytes, path: str) -> Optional[dict]:
    """``data`` parsed when it is a JSON object, else ``None`` (the file is
    published as read)."""
    try:
        root = json.loads(data)
    except ValueError:
        logger.warning("publish: %s is not JSON; published as is", path)
        return None
    return root if isinstance(root, dict) else None


def publish_markers(session: Session, mv: ModelVersion) -> tuple[str, str, bool]:
    """``(schema marker, view marker, inherited)`` for publishing ``mv``.

    A version a 0.9.0 import brought in records its markers (``""`` when it
    added nothing, agent output included). A version with none (NULL: an
    agent run, an older row) takes those of its nearest ancestor along
    ``base_version_id`` in the same business AND the same scope: a vibe of an
    imported ECM keeps the ECM's names, while an MVM shrunk from an ECM does
    not take the ECM's markers (its views carry ``ecm_`` names next to the
    MVM's own). No such ancestor: nothing to strip.
    """
    scope = (mv.scope or "").lower()
    seen: set[str] = set()
    current: ModelVersion | None = mv
    while current is not None and current.id not in seen:
        seen.add(current.id)
        if current.import_schema_prefix_added is not None or current.import_view_prefix_added is not None:
            return (
                current.import_schema_prefix_added or "",
                current.import_view_prefix_added or "",
                current is not mv,
            )
        parent = session.get(ModelVersion, current.base_version_id) if current.base_version_id else None
        if parent is None or parent.business_id != mv.business_id or (parent.scope or "").lower() != scope:
            break
        current = parent
    return "", "", False


def build_publish_strip(
    session: Session,
    ws: Any,
    mv: ModelVersion,
    business_name: str,
    artifacts: Iterable[RunArtifact],
) -> PublishStrip:
    """The :class:`PublishStrip` for ``mv`` (:func:`publish_markers`).

    An inherited schema marker applies only when ``mv``'s own model.json still
    uses it as its ``schema_prefix`` (a vibe may have changed it); a version's
    own marker is the prefix its import wrote into that file. The schema map
    comes from ``mv``'s ``Domain.database_name`` rows; a strip that would give
    two schemas one name is skipped (:func:`scope_prefix.schema_strip_map`).
    With a marker, every ``model_json`` artifact is read here, once, for the
    strip and for the version's view names, so a stripped view never takes
    the name of another. One that reads but is not a JSON object is
    published as read.

    Each read gets ``REQUIRED_READ_TIMEOUT_S``. A read that fails or times out
    raises a 502 (:func:`_unreadable`): publishing the file unstripped would
    put the app's names in the repository. The caller builds this before it
    writes anything to GitHub.
    """
    schema_marker, view_marker, inherited = publish_markers(session, mv)
    if not (schema_marker or view_marker):
        return PublishStrip()
    budget = REQUIRED_READ_TIMEOUT_S
    if schema_marker and inherited:
        paths = version_model_json_candidates(session, mv, business_name)
        found = read_conventions(ws, paths, timeout_s=budget)
        if found.path is None:
            raise _unreadable(mv, paths[0] if paths else "")
        if str((found.conventions or {}).get("schema_prefix") or "") != schema_marker:
            schema_marker = ""
    schema_map: dict[str, str] = {}
    if schema_marker:
        names = session.exec(select(Domain.database_name).where(Domain.version_id == mv.id)).all()
        schema_map = schema_strip_map(names, schema_marker)
    model_files: dict[str, tuple[bytes, Any]] = {}
    for a in artifacts:
        if a.artifact_type == "model_json" and a.file_path and a.file_path not in model_files:
            data = read_volume_bytes(ws, a.file_path, timeout_s=budget)
            if data is None:
                raise _unreadable(mv, a.file_path)
            model_files[a.file_path] = (data, _json_object(data, a.file_path))
    view_names = tuple(n for _data, root in model_files.values() for n in metric_view_names(root))
    return PublishStrip(schema_marker, view_marker, schema_map, view_names, model_files)


def publish_model_version(
    user_ws,
    cfg: AgentConfig,
    *,
    session: Session,
    business_id: str,
    version_id: str,
    target_path: str | None = None,
) -> PublishResult:
    """Publish a model version's bundle to GitHub as a single PR.

    Resolves the GitHub config off ``cfg`` and GUARDS hard:

    * ``github_auth_mode != "oauth_u2m"`` or no ``github_connection_name`` ->
      ``HTTPException(422, github_connection_missing)``. This is the
      human-gated boundary: the UC HTTP connection must be created by an
      operator and named in Settings before publish can work.
    * ``github_auth_mode == "secret_pat"`` -> ``HTTPException(422,
      github_pat_not_implemented)``; the PAT publish path is deferred.

    On the happy path it reconstructs ``model.json`` + artifacts via
    :func:`iter_bundle_files`, with the prefixes an import added stripped
    (:func:`build_publish_strip`), PUTs each file to a new branch via the
    GitHub Contents API (routed through the UC connection), opens one PR, and
    records an audit :class:`Run`.
    """
    if cfg.github_auth_mode == "secret_pat":
        raise HTTPException(
            status_code=422,
            detail={
                "error": "github_pat_not_implemented",
                "message": "Secret-PAT GitHub publish is not implemented yet. "
                "Use the OAuth U2M UC HTTP connection.",
            },
        )

    if cfg.github_auth_mode != "oauth_u2m" or not cfg.github_connection_name:
        raise HTTPException(
            status_code=422,
            detail={
                "error": "github_connection_missing",
                "message": "Create the github_pr UC HTTP connection and set it "
                "in Settings.",
            },
        )

    owner = cfg.github_repo_owner or DEFAULT_REPO_OWNER
    repo = cfg.github_repo_name or DEFAULT_REPO_NAME
    connection_name = cfg.github_connection_name

    mv = session.get(ModelVersion, version_id)
    if mv is None or mv.business_id != business_id:
        raise HTTPException(status_code=404, detail="ModelVersion not found")

    business = session.get(Business, business_id)
    root = resolve_bundle_root(
        override=target_path,
        business=business,
        scope=mv.scope or "",
        version=mv.version,
    )

    layout = bundle_layout(
        mv.scope or "", mv.scope or "", mv.version, dir_override=root
    )
    artifacts = session.exec(
        select(RunArtifact)
        .where(RunArtifact.model_version_id == version_id)
        .order_by(RunArtifact.created_at.desc())
    ).all()
    strip = build_publish_strip(
        session, user_ws, mv, business.name if business else "", artifacts
    )
    model_json = strip.model_json(export_model_json(session, version_id))

    base_branch = _default_branch(user_ws, connection_name, owner, repo)
    base_sha = _branch_head_sha(
        user_ws, connection_name, owner, repo, base_branch
    )

    ts = datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S")
    branch = f"publish/{layout.industry}-{layout.scope}-v{layout.version}-{ts}"

    _create_branch_ref(user_ws, connection_name, owner, repo, branch, base_sha)

    published: list[str] = []
    for bundle_path, data in iter_bundle_files(
        user_ws, layout, model_json, artifacts,
        read_artifact=lambda a: strip.read(user_ws, a),
    ):
        _put_file(
            user_ws,
            connection_name,
            owner,
            repo,
            branch,
            bundle_path,
            data,
        )
        published.append(bundle_path)

    pr = _open_pull_request(
        user_ws,
        connection_name,
        owner,
        repo,
        head=branch,
        base=base_branch,
        title=f"Publish {layout.industry} {layout.scope} v{layout.version}",
        body=(
            f"Automated publish of model version `{version_id}` "
            f"({len(published)} files)."
        ),
    )
    pr_number = int(pr.get("number", 0))
    pr_url = pr.get("html_url", "")

    _record_audit(
        session,
        business_id=business_id,
        version_id=version_id,
        branch=branch,
        pr_number=pr_number,
        pr_url=pr_url,
        files=published,
    )

    return PublishResult(
        branch=branch,
        pr_number=pr_number,
        pr_url=pr_url,
        files=published,
        target_path=layout.dir,
    )


# --- GitHub Contents/Git API calls (all via the UC HTTP connection) --------


def _default_branch(user_ws, connection_name, owner, repo) -> str:
    resp = user_ws.serving_endpoints.http_request(
        connection_name,
        ExternalFunctionRequestHttpMethod.GET,
        f"/repos/{owner}/{repo}",
    )
    return _http_json(resp).get("default_branch") or "main"


def _branch_head_sha(user_ws, connection_name, owner, repo, branch) -> str:
    resp = user_ws.serving_endpoints.http_request(
        connection_name,
        ExternalFunctionRequestHttpMethod.GET,
        f"/repos/{owner}/{repo}/git/ref/heads/{branch}",
    )
    obj = _http_json(resp).get("object") or {}
    sha = obj.get("sha")
    if not sha:
        raise HTTPException(
            status_code=502,
            detail=f"Could not resolve head SHA of {branch!r} on {owner}/{repo}",
        )
    return sha


def _create_branch_ref(user_ws, connection_name, owner, repo, branch, base_sha):
    user_ws.serving_endpoints.http_request(
        connection_name,
        ExternalFunctionRequestHttpMethod.POST,
        f"/repos/{owner}/{repo}/git/refs",
        json={"ref": f"refs/heads/{branch}", "sha": base_sha},
    )


def _put_file(user_ws, connection_name, owner, repo, branch, bundle_path, data):
    user_ws.serving_endpoints.http_request(
        connection_name,
        ExternalFunctionRequestHttpMethod.PUT,
        f"/repos/{owner}/{repo}/contents/{bundle_path}",
        json={
            "message": f"Publish {bundle_path}",
            "content": base64.b64encode(data).decode("ascii"),
            "branch": branch,
        },
    )


def _open_pull_request(
    user_ws, connection_name, owner, repo, *, head, base, title, body
) -> dict:
    resp = user_ws.serving_endpoints.http_request(
        connection_name,
        ExternalFunctionRequestHttpMethod.POST,
        f"/repos/{owner}/{repo}/pulls",
        json={"title": title, "head": head, "base": base, "body": body},
    )
    return _http_json(resp)


def _record_audit(
    session: Session,
    *,
    business_id: str,
    version_id: str,
    branch: str,
    pr_number: int,
    pr_url: str,
    files: list[str],
) -> None:
    """Record a terminal-success audit ``Run`` for the publish.

    Publish is synchronous (no Databricks job), so the Run is stamped
    completed inline; its ``parameters_json`` carries the PR provenance so the
    run history reads as "published version X to PR #Y".
    """
    now = datetime.now(timezone.utc)
    run = Run(
        business_id=business_id,
        version_id=version_id,
        intent="publish-to-github",
        status="completed",
        progress_percent=100,
        progress_message=f"Published to PR #{pr_number}",
        parameters_json=json.dumps(
            {
                "source": "github_publish",
                "branch": branch,
                "pr_number": pr_number,
                "pr_url": pr_url,
                "files": files,
            }
        ),
        started_at=now,
        completed_at=now,
    )
    session.add(run)
    session.commit()

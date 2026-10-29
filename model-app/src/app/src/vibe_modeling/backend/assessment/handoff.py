"""Copy a domain run's project (conventions.yml + docs/) into the caller's workspace home for Genie Code.

Volume reads use the app SP client; every workspace write goes through the
caller's on-behalf-of client, so the files land as the caller's own.
"""
from __future__ import annotations

import base64
import io
import json
import logging
from itertools import islice

from databricks.sdk import WorkspaceClient
from databricks.sdk.errors.platform import DatabricksError, NotFound, PermissionDenied
from databricks.sdk.service.workspace import ExportFormat, ImportFormat
from sqlmodel import Session, select

from ..db_models import AssessDecisionOption, AssessDomainRun, AssessHandoff, AssessPendingDecision
from ..error_sanitization import sanitize_error_message
from .assets import SKILL_VERSION_FILE
from .constants import SKILLS_WORKSPACE_DIR, domain_segment
from .schemas import HandoffPrompt, NextStepOut, SkillStatus

logger = logging.getLogger(__name__)

MAX_FILES = 2000
EXPECTED_HANDOFFS = ["docs/design/ (S2T report, Gap Registry)",
                     "docs/design/business_requirements.md + etl_detailed_spec.md (the build inputs, written by the "
                     "Continue step)",
                     "conventions.yml"]
USER_SCOPE_NOTE = ("Skills are looked up in your user folder (/Workspace/Users/<you>/.assistant/skills) first, then "
                   "workspace-wide (/Workspace/.assistant/skills). Installing them in your own folder keeps them yours.")


def user_home(user_email: str) -> str:
    """The caller's workspace home, ``/Workspace/Users/<email>``."""
    return f"/Workspace/Users/{user_email}"


def user_skill_dir(user_email: str, name: str) -> str:
    """One Genie Code skill's folder in the caller's home, ``<home>/.assistant/skills/<name>``."""
    return f"{user_home(user_email)}/.assistant/skills/{name}"


def default_handoff_path(user_email: str, business_name: str, domain_name: str, batch_id: str) -> str:
    """``<caller home>/vibe-assess/<business>/<domain>/<batch>``; the batch segment keeps earlier hand-offs."""
    return (f"{user_home(user_email)}/vibe-assess/{domain_segment(business_name)}/{domain_segment(domain_name)}"
            f"/{batch_id}")


def render_decisions_md(decisions) -> str:
    lines = ["# Decisions recorded in the Vibe Modeling app", "",
             "Use these as the human answers for the Phase 5 iteration loop.", ""]
    for d, opts in decisions:
        label = next((o.label for o in opts if o.id == d.answer_option_id), None)
        if d.answer_status == "answered":
            ans = " — ".join(x for x in (label, d.answer_text) if x)
        else:
            ans = f"_not answered — default taken: {d.default_taken}_"
        lines += [f"## {d.gate} — {d.question}", f"- **Entity:** {d.entity or '—'}",
                  f"- **Options:** {', '.join(o.label for o in opts) or '—'}",
                  f"- **Default taken:** {d.default_taken}", f"- **Answer:** {ans}", ""]
    return "\n".join(lines)


def _prompt_steps(root: str, output_model: str) -> list[tuple[str, str, str, str]]:
    """``(key, title, skill, prompt)`` per Genie Code prompt, in run order; the one list of hand-off steps.

    Build inputs live in ``docs/design/``: Phase 6 of the assessment writes ``business_requirements.md`` and
    ``etl_detailed_spec.md`` there, and the ETL skill reads them plus the gold design from there. A hybrid model
    builds and validates each layer in turn (the validation and documentation skills expect one validation run
    per layer): silver first, then Mode B gold derivation, the gold build and the gold validation.
    """
    hybrid = output_model == "hybrid"
    layer = " against the silver layer" if hybrid else ""
    steps = [
        ("continue", "Continue the assessment", "domain-model-assessment",
         f"Run my $domain-model-assessment skill at {root} (load $autonomous-validation alongside it). "
         "Phases 0–4 are done — read docs/design/. Run Phase 5 (iteration loop) using the answers in "
         "docs/inputs/decisions.md, then Phase 6 to generate the build handoff docs."),
        ("build", "Build silver" if hybrid else "Build", "etl-development-framework",
         f"Run my $etl-development-framework skill at {root} (load $autonomous-validation alongside it) "
         "using the build handoff docs in docs/design/ (business_requirements.md, etl_detailed_spec.md)."),
        ("validate", "Validate silver" if hybrid else "Validate", "domain-model-validation",
         f"Run my $domain-model-validation skill at {root} (load $autonomous-validation alongside it){layer}."),
    ]
    if hybrid:
        steps += [
            ("gold", "Derive gold", "domain-model-assessment",
             "Silver is built and populated — run Mode B (gold derivation) of my $domain-model-assessment "
             f"skill at {root} (load $autonomous-validation alongside it), then write the gold handoff "
             "for $etl-development-framework to docs/design/."),
            ("build_gold", "Build gold", "etl-development-framework",
             f"Run my $etl-development-framework skill at {root} (load $autonomous-validation alongside it) "
             "to build the gold layer from the gold design in docs/design/ (gold_requirements.md, or the "
             "gold_layer_assessment.md written by the Derive gold step)."),
            ("validate_gold", "Validate gold", "domain-model-validation",
             f"Run my $domain-model-validation skill at {root} (load $autonomous-validation alongside it) "
             "against the gold layer."),
        ]
    steps.append(("document", "Document", "domain-documentation", f"Run my $domain-documentation skill at {root}."))
    return steps


def build_prompts(root: str, output_model: str = "normalized") -> list[HandoffPrompt]:
    """Genie Code prompts in run order, numbered (four; seven for a hybrid model)."""
    return [HandoffPrompt(key=k, title=f"{i}. {t}", skill=sk, prompt=p)
            for i, (k, t, sk, p) in enumerate(_prompt_steps(root, output_model), 1)]


def render_readme(*, business: str, domain: str, model_version: int, batch_id: str, dr: AssessDomainRun,
                  prompts: list[HandoffPrompt]) -> str:
    lines = ["# Vibe Modeling assessment hand-off", "",
             f"- **Business:** {business}", f"- **Domain:** {domain}", f"- **Model version:** v{model_version}",
             f"- **Batch:** {batch_id}",
             f"- **Skills:** commit {dr.skills_commit or '—'}, version {dr.skills_version or '—'}",
             f"- **Genie version:** {dr.genie_version or '—'}", "",
             "Re-running the hand-off overwrites these files.", "",
             "Paste these prompts into Genie Code, in order:", ""]
    for p in prompts:
        lines += [f"## {p.title}", "", p.prompt, ""]
    return "\n".join(lines)


def _plural(n: int, noun: str) -> str:
    return f"{n} {noun}" + ("" if n == 1 else "s")


_PROMPT_COUNT_WORDS = {4: "four", 7: "seven"}


def build_next_steps(*, verdict: str | None, open_blocking: int, open_total: int, before_build_vibes: int,
                     copied: bool, skills_ok: bool = True, blocked_entities: int = 0,
                     output_model: str = "normalized") -> list[NextStepOut]:
    """Ordered checklist for the hand-off tab; steps whose count is zero are skipped."""
    steps: list[tuple[str, str]] = []
    if verdict == "blocked" or blocked_entities > 0:
        n = blocked_entities
        steps.append(("Resolve the blocked entities before building",
                      f"{_plural(n, 'entity').replace('entitys', 'entities')} {'is' if n == 1 else 'are'} blocked — their "
                      "sources don't exist or record a different process; add the ingestion before building."
                      if n else "Blocked entities can't be built until they are resolved."))
    if open_blocking:
        steps.append((f"Answer {_plural(open_blocking, 'blocking decision')}",
                      "Building is gated on these answers; they are written to docs/inputs/decisions.md."))
    elif open_total:
        steps.append((f"Review {_plural(open_total, 'open decision')}",
                      "Unanswered decisions fall back to their defaults."))
    if before_build_vibes:
        steps.append((f"Iterate the model on {_plural(before_build_vibes, 'change')} before building",
                      "Use the vibe inputs in the app."))
    if not skills_ok:
        steps.append(("Install the Genie Code skills", "Some of the six skills are missing or out of date."))
    steps.append(("Copy the assessment to your workspace",
                  "Done." if copied else "Copies conventions.yml and docs/ to a workspace folder."))
    titles = [t for _, t, _, _ in _prompt_steps("", output_model)]
    steps.append((f"In Genie Code, run {' → '.join(titles)}",
                  f"Paste the {_PROMPT_COUNT_WORDS[len(titles)]} prompts in order."))
    copy_title = "Copy the assessment to your workspace"
    return [NextStepOut(order=i, title=t, detail=d, done=copied and t == copy_title)
            for i, (t, d) in enumerate(steps, 1)]


def _probe(client: WorkspaceClient, skill_dir: str) -> str | None:
    """Installed version marker of a skill dir: None when the dir is absent, '' when it has no marker."""
    try:
        client.workspace.get_status(skill_dir)
    except NotFound:
        return None
    try:
        return client.workspace.download(f"{skill_dir}/{SKILL_VERSION_FILE}", format=ExportFormat.AUTO).read().decode().strip()
    except NotFound:
        return ""


def token_scopes(token: str | None) -> list[str] | None:
    """Granted scopes from a JWT's unverified ``scope``/``scp`` claim; None for opaque tokens. Nothing else is read."""
    try:
        seg = (token or "").split(".")[1]
        claims = json.loads(base64.urlsafe_b64decode(seg + "=" * (-len(seg) % 4)))
        raw = claims.get("scope", claims.get("scp"))
        if isinstance(raw, str):
            return raw.split()
        return [str(x) for x in raw] if isinstance(raw, list) else None
    except Exception:  # opaque / malformed token: nothing to report
        return None


SCOPE_MESSAGE = ("The app needs one more permission to {action} {target}. Reload the app and accept the "
                 "permission prompt (or sign out of the app and back in). If no prompt appears, ask a workspace "
                 "admin to allow the app's 'workspace.workspace' scope.")


def scope_message(target: str, error: str, *, action: str = "write to") -> str:
    """The re-consent text for a scope error on the caller's token, with the error it saw.

    ``action`` names what the token was refused: "write to" (hand-off, install) or "read" (skills check).
    """
    return f"{SCOPE_MESSAGE.format(action=action, target=target)} Error: {error}"


def is_scope_error(e: Exception) -> bool:
    """True for a permission/403/scope failure (the signature of an OBO token missing a scope)."""
    return (isinstance(e, PermissionDenied) or getattr(e, "error_code", None) == "PERMISSION_DENIED"
            or getattr(e, "status_code", None) == 403 or "scope" in str(e).lower())


SIGN_IN_TO_CHECK_SKILLS = "Sign in through the deployed app to check the skills in your own folder."


def skills_check_with_note(ws: WorkspaceClient, user_ws: WorkspaceClient | None, expected: list[str], *,
                           user_email: str, bundled: dict[str, str]) -> tuple[list[SkillStatus], str]:
    """Statuses plus a plain note saying what couldn't be read ("" when everything was read).

    Each distinct problem appears once, in order: no caller token, then any folder read failure.

    The caller's folder is read only with the caller's own token; the workspace-wide folder
    with the app's. Nothing is retried as another identity: a skill whose places couldn't all
    be read, and that wasn't found in the ones that could, is ``unknown``.
    """
    own = user_ws if user_email else None  # the caller's folder is read only with the caller's token
    notes: list[str] = [] if own is not None else [SIGN_IN_TO_CHECK_SKILLS]
    failed: set[str] = set()
    out: list[SkillStatus] = []
    for name in expected:
        want, unread, found = bundled.get(name, ""), own is None, None
        places: list[tuple[str, WorkspaceClient, str, str]] = []
        if own is not None:
            places.append(("user", own, user_skill_dir(user_email, name), "your skills folder"))
        places.append(("workspace", ws, f"{SKILLS_WORKSPACE_DIR}/{name}", "the workspace skills folder"))
        for loc, client, d, where in places:
            try:
                have = _probe(client, d)
            except DatabricksError as e:  # permission, throttling, 5xx
                error = sanitize_error_message(str(e))
                logger.warning("Skill read failed (%s) %s: %s: %s", loc, d, type(e).__name__, error)
                unread = True
                if where not in failed:
                    failed.add(where)
                    # A scope error on the caller's own token is fixed by re-consenting; say so.
                    notes.append(scope_message(where, error, action="read") if client is own and is_scope_error(e)
                                 else f"Couldn't read {where}: {error}")
                continue
            if have is not None:
                found = (loc, have)
                break
        if found:
            loc, have = found
            out.append(SkillStatus(name=name, state="present" if have and have == want else "update_available",
                                   location=loc, bundled_version=want, installed_version=have))
        else:
            out.append(SkillStatus(name=name, state="unknown" if unread else "missing", location="none",
                                   bundled_version=want))
    return out, " ".join(notes)


def skills_check(ws: WorkspaceClient, user_ws: WorkspaceClient | None, expected: list[str], *, user_email: str,
                 bundled: dict[str, str]) -> list[SkillStatus]:
    """Look for each skill in the caller's own folder, then workspace-wide; compare its marker to the bundled one."""
    return skills_check_with_note(ws, user_ws, expected, user_email=user_email, bundled=bundled)[0]


def _walk(ws: WorkspaceClient, path: str):
    for e in ws.files.list_directory_contents(path):
        if e.is_directory:
            yield from _walk(ws, e.path)
        else:
            yield e.path


def allowed_handoff_target(path: str, user_email: str) -> bool:
    """True when ``path`` is a strict subpath of the caller's own home folder."""
    if not user_email:
        return False
    root = user_home(user_email) + "/"
    return path.lower().startswith(root.lower()) and len(path) > len(root)


class HandoffWriteError(Exception):
    """A write with the caller's token failed (``cause`` is the SDK error); reads are not wrapped."""

    def __init__(self, cause: Exception):
        super().__init__(str(cause))
        self.cause = cause


def handoff_domain_run(session: Session, ws: WorkspaceClient, user_ws: WorkspaceClient, dr: AssessDomainRun, *,
                       path: str, user_email: str, readme: str) -> AssessHandoff:
    """Read the run's files with ``ws`` (app SP), write them with ``user_ws`` (the caller); record the hand-off.

    A failed write raises ``HandoffWriteError``; a failed Volume read raises the SDK error itself, so
    only the caller's own calls can be read as a missing-scope error.
    """
    made: set[str] = set()

    def put(dest: str, data: bytes) -> None:
        try:
            parent = dest.rsplit("/", 1)[0]
            if parent not in made:
                user_ws.workspace.mkdirs(parent)
                made.add(parent)
            user_ws.workspace.upload(dest, io.BytesIO(data), format=ImportFormat.RAW, overwrite=True)
        except DatabricksError as e:
            raise HandoffWriteError(e) from e

    out = dr.out_dir.rstrip("/")
    wanted = [f"{out}/conventions.yml"] if any(
        e.path == f"{out}/conventions.yml" for e in ws.files.list_directory_contents(out)) else []
    try:
        wanted += list(islice(_walk(ws, f"{out}/docs"), MAX_FILES + 1))
    except NotFound:
        pass  # a run with no docs/ still hands off its decisions + README
    if len(wanted) > MAX_FILES:
        raise DatabricksError(f"The docs folder exceeds the hand-off limit of {MAX_FILES} files.")
    for src in wanted:
        put(f"{path}/{src[len(out):].lstrip('/')}", ws.files.download(src).contents.read())

    decs = session.exec(select(AssessPendingDecision).where(AssessPendingDecision.domain_run_id == dr.id)).all()
    pairs = [(d, session.exec(select(AssessDecisionOption).where(AssessDecisionOption.decision_id == d.id)
                              .order_by(AssessDecisionOption.ordinal)).all()) for d in decs]
    put(f"{path}/docs/inputs/decisions.md", render_decisions_md(pairs).encode())
    put(f"{path}/README.md", readme.encode())
    h = AssessHandoff(domain_run_id=dr.id, path=path, created_by=user_email)
    session.add(h); session.commit(); session.refresh(h)
    return h

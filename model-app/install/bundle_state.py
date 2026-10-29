"""The bundle's deployment state per app, and the deploy that never deletes or recreates the app.

``databricks.yml`` sets ``workspace.root_path`` to ``~/.bundle/vibe-modeling/<app>``: one bundle root, and so
one deployment state, per app name (``bundle_root``). Two apps deploy side by side from one identity, and
the ``dev`` and ``github-publish`` targets, which differ only by a resource on the same app, update the same
app. ``install/install.sh`` deploys through ``deploy``:

1. the CLI is at least ``MIN_CLI`` (``bundle plan -o json`` and ``bundle deploy --plan`` with the direct
   engine, the only engine from that version on);
2. the local state cache ``.databricks/bundle/<target>/`` is deleted first, so the plan always comes from
   the remote state of the app's own root (a cache records no workspace and is per target, not per app);
3. the remote state under the app's root, when present, manages this app only. When the root has no
   state, the state of an install made before this layout (``~/.bundle/vibe-modeling/dev`` or
   ``.../github-publish``) that manages this app is copied there (the old root is left in place). When
   both earlier roots manage the app, the deploy refuses and names both: their serials can't be compared
   across lineages;
4. an earlier root's state is not copied when the app's active deployment runs from the app's own root
   (that state is older than the app's deployments, the app's own root state was deleted): the app is
   then handled like an app with no state;
5. an app that exists with no state anywhere is never taken over silently. With ``--adopt-if-ours`` (the
   caller read the app and recognised it as this bundle's app: ``_install_common.is_our_app``) and an app
   the deploying identity created, it is bound after the plan check; created by another identity, the
   deploy asks y/N on a terminal (``--yes`` does not answer it) and otherwise needs
   ``--adopt-existing-app``. Any other app stops with its creator and description, and is bound only
   with ``--adopt-existing-app``;
6. when an existing app is taken into this bundle (a legacy state copy or ``--adopt-existing-app``) and
   its creator is not the deploying identity, the deploy warns and asks y/N on a terminal; with no
   terminal it refuses unless ``--yes``;
7. ``databricks bundle plan -o json`` writes ``install/.generated/plans/<app>.json``; any delete, recreate
   or id change of ``resources.apps.vibe-modeling-app`` (or an action this module does not know, or no
   entry for the app) refuses, and removes the state this run copied into the app's root. For an
   adoption the plan is checked before the bind and again after it; anything that stops the run after the
   bind (a refusal, a failed plan, an interrupt) unbinds and removes the state the bind wrote, since the
   root held none before. An empty root state (no resources at all: what an unbind leaves) counts as no
   state;
8. ``databricks bundle deploy --plan <that file>`` applies exactly that plan, so nothing changes between
   the check and the apply (``deploy --plan`` does not build again: the plan's build is the one deployed).
   ``--apply-without-plan-file`` (or ``VIBE_MODELING_APPLY_WITHOUT_PLAN_FILE=1`` where the environment is
   read: not under ``--ignore-env``, which ``install.sh`` passes) applies with a plain ``bundle deploy``
   after the same check, for a CLI where ``deploy --plan`` fails.

App existence comes from ``_install_common.find_app``. Remote state is read and written through the SDK
(``workspace.export`` / ``workspace.import_``; a missing file is the SDK's ``NotFound``).

CLI::

    python install/bundle_state.py check-cli
    python install/bundle_state.py source-path --user <user> --app-name <app>
    python install/bundle_state.py deploy --app-name <app> --target <target> [--profile <p>]
        [--adopt-existing-app | --adopt-if-ours] [--yes] [--apply-without-plan-file] [--ignore-env]

Exit codes: 0 ok; 2 refused (the message says why; nothing was deployed); 1 a call failed.
"""

from __future__ import annotations

import argparse
import base64
import json
import os
import posixpath
import re
import shutil
import subprocess
import sys
from collections.abc import Callable, Iterable
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Protocol

from _install_common import AppLookupError, NotConfirmed, confirm, find_app, workspace_client

INSTALL_DIR = Path(__file__).resolve().parent
REPO_ROOT = INSTALL_DIR.parent
PLAN_DIR = INSTALL_DIR / ".generated" / "plans"

BUNDLE_NAME = "vibe-modeling"
APP_RESOURCE = "vibe-modeling-app"
APP_PLAN_KEY = f"resources.apps.{APP_RESOURCE}"
LEGACY_TARGETS = ("dev", "github-publish")
DIRECT_STATE, TERRAFORM_STATE = "resources.json", "terraform.tfstate"
STATE_FILES = (DIRECT_STATE, TERRAFORM_STATE)
MIN_CLI = (1, 20, 0)
REFUSED_ACTIONS = frozenset({"delete", "recreate", "update_id"})
KNOWN_ACTIONS = frozenset({"", "skip", "create", "update", "resize"}) | REFUSED_ACTIONS
APPLY_WITHOUT_PLAN_FILE_ENV = "VIBE_MODELING_APPLY_WITHOUT_PLAN_FILE"

REFUSED, FAILED = 2, 1

ADOPT_NEEDED = ("App '{app}' already exists, and no bundle state manages it: not under {root}, and not under "
                "an earlier install's root ({legacy}). It may be another user's or another team's app. Creator: {creator}. Description: "
                "{description}. If it is the app you installed, re-run install/install.sh with "
                "--adopt-existing-app, which binds it to this bundle; otherwise pick another --app-name. "
                "Nothing was deployed.")
PLAN_REFUSED = ("The deploy plan for app '{app}' would {what}. Nothing was deployed. The bundle state may "
                "manage another app name; see INSTALL.md 'Troubleshooting' ('The deploy plan would delete or "
                "recreate the app'). Plan: {path}")
LEGACY_AMBIGUOUS = ("Both earlier bundle roots hold a state that manages app '{app}': {roots}. Their order can't "
                    "be told from the state files. Keep the one the app runs from (`databricks apps get {app}` "
                    "shows its source path), move the other root's state folder away, and re-run. Nothing was "
                    "deployed.")
OURS_NO_STATE = ("app '{app}' has no deployment state (its bundle folder may have been deleted); it is the "
                 "vibe-modeling app read above: binding it after the plan check")
FOREIGN_OURS_NO_TERMINAL = ("App '{app}' has no deployment state, and {creator} created it, not {user}. Binding it "
                            "to this checkout needs a confirmation on a terminal (--yes does not give it), or "
                            "--adopt-existing-app. Nothing was deployed.")
FOREIGN_APP = ("App '{app}' was created by {creator}, not by {user} (this deploy's identity). Taking it into "
               "this bundle lets this checkout deploy over it.")


class BundleStateError(Exception):
    """A deploy this module refuses (``code`` 2) or could not do (``code`` 1)."""

    def __init__(self, message: str, code: int = REFUSED):
        super().__init__(message)
        self.code = code


def bundle_root(user: str, app_name: str) -> str:
    """The app's bundle root in the workspace (``databricks.yml`` ``workspace.root_path``)."""
    return f"/Workspace/Users/{user}/.bundle/{BUNDLE_NAME}/{app_name}"


def legacy_root(user: str, target: str) -> str:
    """The bundle root of an install made before the root was keyed by app name (keyed by target)."""
    return f"/Workspace/Users/{user}/.bundle/{BUNDLE_NAME}/{target}"


def source_code_path(user: str, app_name: str) -> str:
    """Where ``bundle deploy`` uploads the built app; ``databricks apps deploy --source-code-path`` takes it."""
    return f"{bundle_root(user, app_name)}/files/src/app/.build"


class StateMismatch(ValueError):
    """A direct-engine state entry whose id (the app it acts on) and name disagree; the message names both."""

    def __init__(self, message: str, apps: tuple[str, str]):
        super().__init__(message)
        self.apps = apps


def state_app_names(filename: str, text: str) -> list[str] | None:
    """App names a bundle state file manages; None when the format is not recognized (fail closed).

    ``resources.json`` (direct engine): the id is the identity, since the engine plans and applies against
    it: every ``resources.apps.<key>`` entry's ``__id__`` (else ``state.name``), and ``StateMismatch`` when
    an entry's ``__id__`` and ``state.name`` both exist and differ. ``terraform.tfstate``: every
    ``databricks_app`` instance's ``name``. Its ``id`` attribute is the app's service principal client id,
    not a name, so it is not compared.
    """
    try:
        doc = json.loads(text)
    except ValueError:
        return None
    if not isinstance(doc, dict):
        return None
    names: set[str] = set()
    if filename.endswith(".tfstate"):
        resources = doc.get("resources")
        if not isinstance(resources, list):
            return None
        for r in resources:
            if isinstance(r, dict) and r.get("type") == "databricks_app":
                for inst in r.get("instances") or []:
                    names.add(str(((inst or {}).get("attributes") or {}).get("name") or ""))
        return sorted(names) if all(names) else None
    state = doc.get("state")
    if not isinstance(state, dict):
        return None
    for key, val in state.items():
        parts = key.split(".")
        if len(parts) != 3 or parts[:2] != ["resources", "apps"]:
            continue
        val = val if isinstance(val, dict) else {}
        names.add(_identity(key, val.get("__id__"), (val.get("state") or {}).get("name")))
    if not all(names):
        return None
    return sorted(names)


# --- the CLI version ---


def parse_cli_version(text: str) -> tuple[int, int, int] | None:
    m = re.search(r"v?(\d+)\.(\d+)\.(\d+)", text or "")
    return (int(m.group(1)), int(m.group(2)), int(m.group(3))) if m else None


def check_cli(run: Callable[..., Any] = subprocess.run) -> tuple[int, int, int]:
    """The CLI version; ``BundleStateError`` below ``MIN_CLI`` or when it can't be read."""
    want = ".".join(map(str, MIN_CLI))
    try:
        proc = run(["databricks", "version"], capture_output=True, text=True, timeout=60)
    except (OSError, subprocess.TimeoutExpired) as exc:
        raise BundleStateError(f"could not run `databricks version`: {exc}") from None
    got = parse_cli_version(proc.stdout) if proc.returncode == 0 else None
    if got is None:
        raise BundleStateError(f"could not read the Databricks CLI version (`databricks version` exited "
                               f"{proc.returncode}); the installer needs {want} or later")
    if got < MIN_CLI:
        raise BundleStateError(f"Databricks CLI {'.'.join(map(str, got))} is below {want}, the first version "
                               f"whose `bundle deploy --plan` works with this bundle. Upgrade the CLI "
                               f"(INSTALL.md 'Prerequisites') and re-run; nothing was deployed.")
    return got


# --- the local state cache ---


def local_state_dir(repo_root: Path, target: str) -> Path:
    return repo_root / ".databricks" / "bundle" / target


# --- remote state ---


class RemoteFiles(Protocol):
    def read(self, path: str) -> str | None: ...

    def write(self, path: str, text: str) -> None: ...

    def delete(self, path: str) -> None: ...


class SdkRemoteFiles:
    """Workspace files through the SDK: ``read`` is None on ``NotFound``; any other error raises."""

    def __init__(self, w: Any):
        self.w = w

    def read(self, path: str) -> str | None:
        from databricks.sdk.errors import NotFound
        from databricks.sdk.service.workspace import ExportFormat
        try:
            content = self.w.workspace.export(path, format=ExportFormat.AUTO).content or ""
        except NotFound:
            return None
        return base64.b64decode(content).decode("utf-8")

    def write(self, path: str, text: str) -> None:
        from databricks.sdk.service.workspace import ImportFormat
        self.w.workspace.mkdirs(posixpath.dirname(path))
        self.w.workspace.import_(path, content=base64.b64encode(text.encode("utf-8")).decode("ascii"),
                                 format=ImportFormat.AUTO, overwrite=False)

    def delete(self, path: str) -> None:
        self.w.workspace.delete(path)


def read_state(remote: RemoteFiles, root: str) -> dict[str, str]:
    """The state files under ``<root>/state`` that exist, by file name."""
    out = {}
    for name in STATE_FILES:
        text = remote.read(f"{root}/state/{name}")
        if text is not None:
            out[name] = text
    return out


def _identity(entry: str, app_id: Any, name: Any) -> str:
    """The app an entry acts on ('' when it names none); ``StateMismatch`` when its id and name differ."""
    if app_id and name and app_id != name:
        raise StateMismatch(f"{entry} acts on app '{app_id}' (its id) but its name is '{name}'",
                            (str(app_id), str(name)))
    return str(app_id or name or "")


def is_empty_state(filename: str, text: str) -> bool:
    """A state file that holds no resources at all (a direct ``state`` of ``{}``, a Terraform ``resources``
    of ``[]``): what ``bundle deployment unbind`` leaves."""
    try:
        doc = json.loads(text)
    except ValueError:
        return False
    if not isinstance(doc, dict):
        return False
    key, empty = ("resources", []) if filename.endswith(".tfstate") else ("state", {})
    return doc.get(key) == empty


def names_in(files: dict[str, str]) -> list[str] | None:
    names: set[str] = set()
    for name, text in files.items():
        found = state_app_names(name, text)
        if found is None:
            return None
        names.update(found)
    return sorted(names)


@dataclass
class LegacyState:
    root: str
    files: dict[str, str]


def legacy_states(remote: RemoteFiles, user: str, app_name: str) -> tuple[list[LegacyState], list[str]]:
    """(earlier-layout states that manage exactly this app, roots whose state could not be read)."""
    found, unreadable = [], []
    for target in LEGACY_TARGETS:
        root = legacy_root(user, target)
        try:
            files = read_state(remote, root)
        except Exception:  # noqa: BLE001  (an unreadable root is reported, never taken as absent)
            unreadable.append(root)
            continue
        if not files:
            continue
        try:
            names = names_in(files)
        except StateMismatch as exc:
            if app_name not in exc.apps:
                _say(f"skipped the bundle state under {root}/state: it is inconsistent ({exc}) and not about "
                     f"app '{app_name}'")
                continue
            raise BundleStateError(f"the bundle state under {root}/state is inconsistent: {exc}. A deploy from it "
                                   f"would act on that app. Fix or move it away. Nothing was deployed.") from None
        if names is None:
            unreadable.append(root)
        elif names == [app_name]:
            found.append(LegacyState(root, files))
    return found, unreadable


def copy_state(remote: RemoteFiles, legacy: LegacyState, root: str) -> list[str]:
    """Copy the earlier root's state files into ``<root>/state``; the paths written."""
    written = []
    for name, text in legacy.files.items():
        path = f"{root}/state/{name}"
        remote.write(path, text)
        written.append(path)
    return written


# --- the plan ---


def plan_problems(doc: Any) -> list[str]:
    """Why a ``bundle plan -o json`` document must not be applied; [] when it may."""
    entries = doc.get("plan") if isinstance(doc, dict) else None
    if not isinstance(entries, dict):
        return ["the plan has no 'plan' map (an unknown plan format)"]
    problems = []
    if not isinstance(entries.get(APP_PLAN_KEY), dict):
        problems.append(f"the plan has no entry for {APP_PLAN_KEY}")
    for key, entry in sorted(entries.items()):
        action = entry.get("action", "") if isinstance(entry, dict) else None
        if action in REFUSED_ACTIONS:
            problems.append(f"{action} {key}")
        elif action not in KNOWN_ACTIONS:
            problems.append(f"{key}: unknown action {action!r}")
    return problems


def app_action(doc: Any) -> str:
    entry = ((doc or {}).get("plan") or {}).get(APP_PLAN_KEY) if isinstance(doc, dict) else None
    return (entry.get("action") or "unchanged") if isinstance(entry, dict) else "absent"


# --- the deploy ---


def _say(msg: str) -> None:
    print(f"    {msg}", file=sys.stderr)


def _cli(*args: str, target: str, app_name: str, profile: str) -> list[str]:
    return ["databricks", "bundle", *args, "--target", target, "--var", f"app_name={app_name}",
            *(["--profile", profile] if profile else [])]


def _run_cli(run: Callable[..., Any], cmd: list[str], **kw: Any) -> int:
    try:
        return run(cmd, cwd=str(REPO_ROOT), **kw).returncode
    except OSError as exc:
        raise BundleStateError(f"could not run {' '.join(cmd[:3])}: {exc}", FAILED) from None


def confirm_foreign_app(app: dict[str, Any], app_name: str, user: str, assume_yes: bool,
                        stdin: Any = None) -> None:
    """Warn and ask y/N when the app was created by another identity; ``--yes`` skips the question and no
    terminal without it refuses (the in-flight guard's rule)."""
    creator = app.get("creator") or ""
    if creator and creator == user:
        return
    _say(f"WARNING: {FOREIGN_APP.format(app=app_name, creator=creator or 'an unknown identity', user=user)}")
    try:
        confirm("Take it over?", assume_yes=assume_yes, stdin=stdin,
                no_terminal="refusing to take the app over without confirmation, and there is no terminal to ask "
                            "on. Re-run with --yes if it is your app. Nothing was deployed.")
    except NotConfirmed as exc:
        raise BundleStateError(str(exc)) from None


@dataclass
class Prepared:
    """What ``prepare_state`` did or left to do: state files it copied (removed again if the plan is
    refused) and whether the app still has to be bound (after the first plan check)."""
    copied: list[str]
    bind: bool = False


def _lookup(lookup: Callable[[str, str], dict[str, Any] | None], app_name: str, profile: str) -> dict[str, Any] | None:
    try:
        return lookup(app_name, profile)
    except AppLookupError as exc:
        raise BundleStateError(f"could not tell whether app '{app_name}' exists: {exc}", FAILED) from None


def _runs_from(app: dict[str, Any] | None, root: str) -> bool:
    """Whether the app's active deployment was deployed from under ``root``."""
    path = ((app or {}).get("active_deployment") or {}).get("source_code_path") or ""
    return path == root or path.startswith(root.rstrip("/") + "/")


def _bind_ours(app: dict[str, Any], app_name: str, user: str, stdin: Any) -> None:
    """``--adopt-if-ours`` on an app with no state: bind an app this identity created; ask for one another
    identity created, on a terminal only."""
    creator = app.get("creator") or ""
    if creator and creator == user:
        _say(OURS_NO_STATE.format(app=app_name))
        return
    who = creator or "an unknown identity"
    _say(f"WARNING: {FOREIGN_APP.format(app=app_name, creator=who, user=user)}")
    try:
        confirm("Take it over?", assume_yes=False, stdin=stdin,
                no_terminal=FOREIGN_OURS_NO_TERMINAL.format(app=app_name, creator=who, user=user))
    except NotConfirmed as exc:
        raise BundleStateError(str(exc)) from None
    _say(OURS_NO_STATE.format(app=app_name))


def prepare_state(*, remote: RemoteFiles, user: str, app_name: str, target: str, profile: str, adopt: bool,
                  adopt_if_ours: bool = False, assume_yes: bool = False,
                  lookup: Callable[[str, str], dict[str, Any] | None] = find_app, stdin: Any = None) -> Prepared:
    """Make the app's root hold its state, or know it is a new app or one to bind; refuse a silent takeover."""
    root = bundle_root(user, app_name)
    try:
        files = read_state(remote, root)
    except Exception as exc:  # noqa: BLE001
        raise BundleStateError(f"could not read the bundle state under {root}/state: {exc}", FAILED) from None
    if files:
        try:
            names = names_in(files)
        except StateMismatch as exc:
            raise BundleStateError(f"the bundle state under {root}/state is inconsistent: {exc}. A deploy from it "
                                   f"would act on that app, not '{app_name}'. Nothing was deployed.") from None
        if names is None or not set(names) <= {app_name}:
            raise BundleStateError(f"the bundle state under {root}/state manages {names or 'an unreadable state'}, "
                                   f"not '{app_name}'; a deploy would replace it. Nothing was deployed.")
        if names:
            return Prepared(copied=[])
        if not all(is_empty_state(name, text) for name, text in files.items()):
            raise BundleStateError(f"the bundle state under {root}/state holds resources but no app; this "
                                   f"installer does not know it. Check it and delete it if it is not in use. "
                                   f"Nothing was deployed.")
        paths = [f"{root}/state/{name}" for name in files]
        try:
            _remove_state(remote, paths, "an empty state (it holds no resources)", strict=True)
        except Exception as exc:  # noqa: BLE001
            raise BundleStateError(f"could not remove the empty state under {root}/state ({exc}); delete "
                                   f"{', '.join(paths)} by hand and re-run. Nothing was deployed.", FAILED) from None
    legacy, unreadable = legacy_states(remote, user, app_name)
    if len(legacy) > 1:
        raise BundleStateError(LEGACY_AMBIGUOUS.format(app=app_name, roots=" and ".join(
            f"{s.root}/state" for s in legacy)))
    app = _lookup(lookup, app_name, profile) if legacy else None
    if legacy and _runs_from(app, root):
        _say(f"not copying the earlier state under {legacy[0].root}/state: app '{app_name}' runs from {root}, so "
             f"that state is older than its deployments")
        legacy = []
    if legacy:
        if app is not None:
            confirm_foreign_app(app, app_name, user, assume_yes, stdin)
        try:
            copied = copy_state(remote, legacy[0], root)
        except Exception as exc:  # noqa: BLE001
            raise BundleStateError(f"could not copy the bundle state from {legacy[0].root}/state to {root}/state "
                                   f"({exc}); remove what was written under {root}/state and re-run. Nothing was "
                                   f"deployed.", FAILED) from None
        _say(f"copied the bundle state of app '{app_name}' from {legacy[0].root}/state to {root}/state "
             f"(the earlier root is left in place)")
        return Prepared(copied=copied)
    app = app if app is not None else _lookup(lookup, app_name, profile)
    if app is None:
        _say(f"app '{app_name}' does not exist yet: the deploy creates it under {root}")
        return Prepared(copied=[])
    if unreadable:
        raise BundleStateError(f"app '{app_name}' exists and the bundle state under {', '.join(unreadable)} "
                               f"cannot be read, so whether it manages the app is unknown. Nothing was deployed.")
    creator = app.get("creator") or "unknown"
    description = app.get("description") or "none"
    if adopt_if_ours and not adopt:
        _bind_ours(app, app_name, user, stdin)
        return Prepared(copied=[], bind=True)
    if not adopt:
        raise BundleStateError(ADOPT_NEEDED.format(app=app_name, root=root, creator=creator, description=description,
                                                   legacy=", ".join(legacy_root(user, t) for t in LEGACY_TARGETS)))
    confirm_foreign_app(app, app_name, user, assume_yes, stdin)
    _say(f"adopting existing app '{app_name}' (creator: {creator}; description: {description}): the plan is "
         f"checked, then `bundle deployment bind`, then checked again")
    return Prepared(copied=[], bind=True)


def plan_checked(*, app_name: str, target: str, profile: str, plan_dir: Path,
                 run: Callable[..., Any]) -> Path:
    """``bundle plan -o json`` to the plan file; ``BundleStateError`` when it fails or must not be applied."""
    plan_dir.mkdir(parents=True, exist_ok=True)
    plan_path = plan_dir / f"{app_name}.json"
    with open(plan_path, "w") as out:
        rc = _run_cli(run, _cli("plan", "-o", "json", target=target, app_name=app_name, profile=profile), stdout=out)
    if rc != 0:
        raise BundleStateError(f"`databricks bundle plan` failed (exit {rc}); nothing was deployed", FAILED)
    try:
        doc = json.loads(plan_path.read_text())
    except ValueError:
        doc = None
    problems = plan_problems(doc)
    if problems:
        raise BundleStateError(PLAN_REFUSED.format(app=app_name, what="; ".join(problems), path=plan_path))
    _say(f"deploy plan: {APP_PLAN_KEY} {app_action(doc)} (no delete or recreate); {plan_path}")
    return plan_path


def _bind(run: Callable[..., Any], *, app_name: str, target: str, profile: str, undo: bool = False) -> None:
    verb = ("deployment", "unbind", APP_RESOURCE) if undo else (
        "deployment", "bind", APP_RESOURCE, app_name, "--auto-approve")
    if _run_cli(run, _cli(*verb, target=target, app_name=app_name, profile=profile), stdout=sys.stderr) != 0:
        what = "unbind" if undo else "bind"
        raise BundleStateError(f"`databricks bundle deployment {what}` failed for app '{app_name}'", FAILED)


def plan_and_apply(*, app_name: str, target: str, profile: str, plan_dir: Path = PLAN_DIR,
                   run: Callable[..., Any] = subprocess.run, without_plan_file: bool = False,
                   bind: bool = False, before_apply_failed: Callable[[], None] = lambda: None,
                   after_unbind: Callable[[], None] = lambda: None, leftovers: str = "") -> None:
    """Plan once to JSON, refuse a plan that deletes or recreates the app, then apply that plan. With
    ``bind``: plan and check first, bind, plan and check again, then apply; anything that stops the run
    after the bind (incl. an interrupt) unbinds and runs ``after_unbind`` (the caller removes the state the
    bind wrote); when that undo fails, the error names the original reason, whether the app is still bound,
    and what to remove by hand (``leftovers``).
    ``before_apply_failed`` runs when anything stops the run before the apply starts."""
    try:
        plan_path = plan_checked(app_name=app_name, target=target, profile=profile, plan_dir=plan_dir, run=run)
        if bind:
            _bind(run, app_name=app_name, target=target, profile=profile)
            try:
                plan_path = plan_checked(app_name=app_name, target=target, profile=profile, plan_dir=plan_dir,
                                         run=run)
            except BaseException as exc:
                reason = str(exc) or type(exc).__name__
                unbound = False
                try:
                    _bind(run, app_name=app_name, target=target, profile=profile, undo=True)
                    unbound = True
                    after_unbind()
                except Exception as undo_exc:  # noqa: BLE001  (report both, then the manual way back)
                    if unbound:
                        raise BundleStateError(f"{reason}\nThe app is unbound again, but removing what the bind "
                                               f"wrote failed ({undo_exc}). Delete {leftovers} by hand.",
                                               FAILED) from None
                    unbind = " ".join(_cli("deployment", "unbind", APP_RESOURCE, target=target, app_name=app_name,
                                           profile=profile))
                    raise BundleStateError(f"{reason}\nThe app is still bound to this bundle: undoing the bind "
                                           f"failed ({undo_exc}). To recover, run `{unbind}` from this checkout, "
                                           f"then delete {leftovers}.", FAILED) from None
                _say(f"unbound app '{app_name}' again and removed the state the bind wrote: the run stopped "
                     f"after the bind")
                raise
    except BaseException:
        before_apply_failed()
        raise
    if without_plan_file:
        _say("--apply-without-plan-file: applying with a plain `bundle deploy`, which plans again")
        cmd = _cli("deploy", target=target, app_name=app_name, profile=profile)
    else:
        cmd = _cli("deploy", "--plan", str(plan_path), target=target, app_name=app_name, profile=profile)
    rc = _run_cli(run, cmd, stdout=sys.stderr)
    if rc != 0:
        raise BundleStateError(f"`databricks bundle deploy` failed (exit {rc})", FAILED)


def _remove_state(remote: RemoteFiles, paths: list[str], what: str, strict: bool = False) -> None:
    """Delete state files this run wrote (or that manage nothing); ``strict`` raises on the first failure."""
    for path in paths:
        try:
            remote.delete(path)
        except Exception as exc:  # noqa: BLE001  (the run's own result comes first; say what is left)
            if strict:
                raise
            _say(f"WARNING: could not remove {what} {path}: {exc}; delete it by hand")
            continue
        _say(f"removed {what} {path}")


def _undo_bind_files(remote: RemoteFiles, root: str, local_dir: Path) -> None:
    """After an unbind this run caused: the root held no state before the bind, so remove what the bind and
    the unbind wrote there (an empty state) and the local cache they wrote."""
    if local_dir.exists():
        shutil.rmtree(local_dir)
    files = read_state(remote, root)
    _remove_state(remote, [f"{root}/state/{name}" for name in files], "the state the bind wrote", strict=True)


def deploy(*, app_name: str, target: str, profile: str, adopt: bool, adopt_if_ours: bool = False,
           assume_yes: bool = False, without_plan_file: bool = False, remote: RemoteFiles | None = None,
           user: str = "",
           run: Callable[..., Any] = subprocess.run,
           lookup: Callable[[str, str], dict[str, Any] | None] = find_app, repo_root: Path = REPO_ROOT,
           plan_dir: Path = PLAN_DIR, stdin: Any = None) -> None:
    check_cli(run)
    if remote is None or not user:
        w = workspace_client(profile or None)
        user = user or (w.current_user.me().user_name or "")
        remote = remote or SdkRemoteFiles(w)
    if not user:
        raise BundleStateError("could not read the deploying identity's user name", FAILED)
    local_dir = local_state_dir(repo_root, target)
    if local_dir.exists():
        shutil.rmtree(local_dir)
        _say(f"removed the local bundle state cache {local_dir}: the plan comes from the app's remote state")
    prepared = prepare_state(remote=remote, user=user, app_name=app_name, target=target, profile=profile,
                             adopt=adopt, adopt_if_ours=adopt_if_ours, assume_yes=assume_yes, lookup=lookup,
                             stdin=stdin)
    root = bundle_root(user, app_name)
    leftovers = (f"{root}/state/{DIRECT_STATE} (and {TERRAFORM_STATE} if present) and the local cache "
                 f"{local_dir}")
    plan_and_apply(app_name=app_name, target=target, profile=profile, plan_dir=plan_dir, run=run,
                   without_plan_file=without_plan_file, bind=prepared.bind,
                   before_apply_failed=lambda: _remove_state(remote, prepared.copied,
                                                             "the copied state (the earlier root is unchanged)"),
                   after_unbind=lambda: _undo_bind_files(remote, root, local_dir), leftovers=leftovers)


def main(argv: Iterable[str] | None = None) -> int:
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = p.add_subparsers(dest="cmd", required=True)
    sub.add_parser("check-cli", help=f"Exit 2 when the Databricks CLI is below {'.'.join(map(str, MIN_CLI))}")
    src = sub.add_parser("source-path", help="Print the app's uploaded source path")
    src.add_argument("--user", required=True)
    src.add_argument("--app-name", required=True)
    dep = sub.add_parser("deploy", help="Prepare the app's state, plan, refuse a destructive plan, apply it")
    dep.add_argument("--app-name", required=True)
    dep.add_argument("--target", required=True)
    dep.add_argument("--profile", default="")
    dep.add_argument("--adopt-existing-app", action="store_true")
    dep.add_argument("--adopt-if-ours", action="store_true",
                     help="The caller recognised the app as this bundle's: bind it when no state manages it")
    dep.add_argument("--yes", action="store_true", help="Take over an app another identity created without asking")
    dep.add_argument("--apply-without-plan-file", action="store_true",
                     help="After the plan check, apply with a plain `bundle deploy`")
    dep.add_argument("--ignore-env", action="store_true",
                     help=f"Do not read {APPLY_WITHOUT_PLAN_FILE_ENV} from the environment (install.sh)")
    args = p.parse_args(list(argv) if argv is not None else sys.argv[1:])
    try:
        if args.cmd == "check-cli":
            got = check_cli()
            _say(f"databricks CLI {'.'.join(map(str, got))}")
        elif args.cmd == "source-path":
            print(source_code_path(args.user, args.app_name))
        else:
            without = args.apply_without_plan_file or (
                not args.ignore_env and os.environ.get(APPLY_WITHOUT_PLAN_FILE_ENV) == "1")
            deploy(app_name=args.app_name, target=args.target, profile=args.profile, adopt=args.adopt_existing_app,
                   adopt_if_ours=args.adopt_if_ours, assume_yes=args.yes, without_plan_file=without)
    except BundleStateError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return exc.code
    except KeyboardInterrupt:
        print("ERROR: interrupted; nothing more was done (see the lines above for what was undone).", file=sys.stderr)
        return 130
    return 0


if __name__ == "__main__":
    sys.exit(main())

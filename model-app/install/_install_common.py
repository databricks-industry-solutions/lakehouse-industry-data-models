"""Helpers shared by the ``install/*.py`` scripts.

The scripts run as ``python install/<script>.py``, so this module is imported
as ``_install_common`` (``install/`` is ``sys.path[0]``). It depends only on the
standard library and ``databricks-sdk``; without the SDK, ``load_backend_module``
still works and ``workspace_client`` raises ``RuntimeError``. The scripts that use it need more of the
operator env: ``provision_lakebase.py`` also needs ``protobuf``, and ``psycopg`` for its
ownership step.

``find_app`` answers "does this Databricks App exist" for every deploy script,
from ``databricks apps list --output json`` (``list_apps``): the exit code and a
membership check on the name, never the text of an error. Shell callers run it as::

    python install/_install_common.py app-exists <name> [--profile <p>]

which exits 0 and prints the app as JSON when it exists, 3 when it does not,
and 1 when the lookup failed (the reason on stderr).
``python install/_install_common.py uses-github-connection < app.json`` exits 0
when that app declares the ``github_pr`` connection resource, 3 when not.

This module is the shared home of a ``databricks`` CLI subprocess call (``run_cli``:
bounded, the exit code decides, ``CliError`` otherwise) and of a y/N question
(``confirm``); new installer code uses them.
"""

from __future__ import annotations

import argparse
import functools
import importlib.util
import json
import subprocess
import sys
from pathlib import Path
from types import ModuleType
from typing import TYPE_CHECKING, Any

if TYPE_CHECKING:
    from databricks.sdk import WorkspaceClient as SdkWorkspaceClient

try:
    from databricks.sdk import WorkspaceClient
    from databricks.sdk.core import Config
except ImportError:  # deploy_settings.py also runs in the bundle build hook, where the SDK may be absent
    WorkspaceClient = Config = None  # type: ignore[assignment,misc]


@functools.lru_cache(maxsize=None)
def load_backend_module(path: Path) -> ModuleType:
    """A dependency-light backend module loaded by file path (the installer runs without the app package)."""
    if not path.is_file():
        raise RuntimeError(f"{path} not found; run from a repo checkout")
    spec = importlib.util.spec_from_file_location(f"_vibe_install_{path.stem}", path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {path}; run from a repo checkout")
    module = importlib.util.module_from_spec(spec)
    # Registered before exec so a @dataclass under `from __future__ import annotations`
    # can resolve its own module.
    sys.modules[spec.name] = module
    try:
        spec.loader.exec_module(module)
    except BaseException:
        sys.modules.pop(spec.name, None)
        raise
    return module


def workspace_client(profile: str | None, **cfg: Any) -> SdkWorkspaceClient:
    """``WorkspaceClient`` for a CLI profile, or the SDK's default auth when ``profile`` is empty.

    ``cfg`` takes any SDK ``Config`` attribute (``host``, ``http_timeout_seconds``,
    ``retry_timeout_seconds``, ...); an unknown key raises ``TypeError``, since
    ``Config`` would silently keep it. It goes through ``Config`` because the
    ``WorkspaceClient`` constructor accepts only some of them.
    """
    if Config is None or WorkspaceClient is None:
        raise RuntimeError("databricks-sdk is not installed: python -m pip install 'databricks-sdk>=0.74'")
    unknown = sorted(k for k in cfg if not hasattr(Config, k))
    if unknown:
        raise TypeError(f"not SDK Config attributes: {', '.join(unknown)}")
    if profile:
        cfg = {"profile": profile, **cfg}
    return WorkspaceClient(config=Config(**cfg))


APP_EXISTS, APP_ABSENT, APP_LOOKUP_FAILED = 0, 3, 1


class CliError(RuntimeError):
    """A ``databricks`` CLI call failed: it could not run, exited non-zero, or printed nothing usable."""


class AppLookupError(CliError):
    """The app list could not be read, so whether the app exists is unknown."""


def run_cli(args: list[str], profile: str = "", run: Any = subprocess.run, timeout: int = 300,
            error: type[CliError] = CliError) -> str:
    """The stdout of ``databricks <args> [--profile <profile>]``; ``error`` when the CLI can't run, exits
    non-zero (with the last 300 characters of its output) or prints nothing. ``run`` is ``subprocess.run``
    (a seam for tests)."""
    cmd = ["databricks", *args, *(["--profile", profile] if profile else [])]
    what = " ".join(cmd[:3])
    try:
        proc = run(cmd, capture_output=True, text=True, timeout=timeout)
    except (OSError, subprocess.TimeoutExpired) as exc:
        raise error(f"{what} could not run: {exc}") from None
    if proc.returncode != 0:
        detail = " ".join((proc.stderr or proc.stdout or "").split())[-300:]
        raise error(f"{what} exited {proc.returncode}: {detail}")
    if not (proc.stdout or "").strip():
        raise error(f"{what} printed nothing")
    return proc.stdout


def run_cli_json(args: list[str], profile: str = "", run: Any = subprocess.run, timeout: int = 300,
                 error: type[CliError] = CliError) -> Any:
    """``run_cli``'s output parsed as JSON; ``error`` when it is not JSON."""
    out = run_cli(args, profile, run, timeout, error)
    try:
        return json.loads(out)
    except ValueError:
        raise error(f"{' '.join(['databricks', *args[:2]])} did not print JSON") from None


def list_apps(profile: str = "", run: Any = subprocess.run, timeout: int = 300) -> list[dict[str, Any]]:
    """Every app ``databricks apps list --output json`` reports (the CLI reads all pages).

    ``AppLookupError`` when the CLI fails, prints nothing, or prints anything but a JSON list of apps
    (an object only as ``{"apps": [...]}`` with no ``next_page_token``, so a partial page is never taken
    for the whole list). ``run`` is ``subprocess.run`` (a seam for tests).
    """
    what = "databricks apps list"
    apps = run_cli_json(["apps", "list", "--output", "json"], profile, run, timeout, AppLookupError)
    if isinstance(apps, dict):
        if not isinstance(apps.get("apps"), list) or apps.get("next_page_token"):
            raise AppLookupError(f"{what} printed an object that is not a complete app list")
        apps = apps["apps"]
    if not isinstance(apps, list) or not all(isinstance(app, dict) for app in apps):
        raise AppLookupError(f"{what} did not print an app list")
    return apps


def find_app(name: str, profile: str = "", run: Any = subprocess.run, timeout: int = 300) -> dict[str, Any] | None:
    """The app called ``name`` from ``list_apps``, or None when absent.

    Decided from the CLI's exit code and the list's membership only; ``AppLookupError`` otherwise.
    """
    return next((app for app in list_apps(profile, run, timeout) if app.get("name") == name), None)


GITHUB_CONNECTION = "github_pr"


def uses_github_connection(app: dict[str, Any]) -> bool:
    """True when the app declares the ``github_pr`` UC connection resource (the ``github-publish`` target)."""
    for resource in app.get("resources") or []:
        securable = (resource or {}).get("uc_securable") or {}
        if securable.get("securable_full_name") == GITHUB_CONNECTION:
            return True
    return False


def get_app(name: str, profile: str = "", run: Any = subprocess.run, timeout: int = 300) -> dict[str, Any]:
    """``databricks apps get <name> --output json``; ``CliError`` when it fails or is not an app object."""
    app = run_cli_json(["apps", "get", name, "--output", "json"], profile, run, timeout)
    if not isinstance(app, dict):
        raise CliError("databricks apps get did not print an app")
    return app


def export_workspace_file(path: str, profile: str = "", run: Any = subprocess.run, timeout: int = 300) -> str:
    """A workspace file's text (``databricks workspace export <path> --format SOURCE``); ``CliError`` when
    it can't be read (a missing file exits 1: ``Error: Path (...) doesn't exist.``)."""
    return run_cli(["workspace", "export", path, "--format", "SOURCE"], profile, run, timeout)


def lakebase_project_name(project_id: str) -> str:
    return f"projects/{project_id}"


def lakebase_branch_name(project_id: str, branch_id: str = "production") -> str:
    return f"{lakebase_project_name(project_id)}/branches/{branch_id}"


def lakebase_endpoint_name(project_id: str, branch_id: str = "production", endpoint_id: str = "primary") -> str:
    return f"{lakebase_branch_name(project_id, branch_id)}/endpoints/{endpoint_id}"


def get_lakebase_endpoint(project_id: str, profile: str = "", run: Any = subprocess.run,
                          timeout: int = 300) -> dict[str, Any]:
    """The ``primary`` endpoint of the project's ``production`` branch (``databricks postgres get-endpoint
    ... --output json``); ``CliError`` when it fails or is not an object."""
    endpoint = run_cli_json(["postgres", "get-endpoint", lakebase_endpoint_name(project_id), "--output", "json"],
                            profile, run, timeout)
    if not isinstance(endpoint, dict):
        raise CliError("databricks postgres get-endpoint did not print an endpoint")
    return endpoint


def _json_list(value: Any, key: str, what: str) -> list[dict[str, Any]]:
    """A CLI list answer: a JSON list, or ``{key: [...]}`` without a ``next_page_token``; ``CliError`` otherwise."""
    if isinstance(value, dict) and not value.get("next_page_token"):
        value = value.get(key, [])
    if not isinstance(value, list) or not all(isinstance(item, dict) for item in value):
        raise CliError(f"{what} did not print a complete list")
    return value


def list_lakebase_projects(profile: str = "", run: Any = subprocess.run, timeout: int = 300) -> list[dict[str, Any]]:
    """Every Lakebase project (``databricks postgres list-projects --output json``; names ``projects/<id>``)."""
    out = run_cli_json(["postgres", "list-projects", "--output", "json"], profile, run, timeout)
    return _json_list(out, "projects", "databricks postgres list-projects")


def list_lakebase_roles(project_id: str, profile: str = "", run: Any = subprocess.run,
                        timeout: int = 300) -> list[dict[str, Any]]:
    """The Postgres roles of the project's ``production`` branch (``databricks postgres list-roles``); a service
    principal's role carries its application id in ``status.postgres_role``."""
    out = run_cli_json(["postgres", "list-roles", lakebase_branch_name(project_id), "--output", "json"], profile, run,
                       timeout)
    return _json_list(out, "roles", "databricks postgres list-roles")


def get_lakebase_role(name: str, profile: str = "", run: Any = subprocess.run, timeout: int = 300) -> dict[str, Any]:
    """One Postgres role by its resource name (``databricks postgres get-role <name>``)."""
    role = run_cli_json(["postgres", "get-role", name, "--output", "json"], profile, run, timeout)
    if not isinstance(role, dict):
        raise CliError("databricks postgres get-role did not print a role")
    return role


def get_grants(securable_type: str, full_name: str, profile: str = "", run: Any = subprocess.run,
               timeout: int = 300) -> list[dict[str, Any]]:
    """The direct privilege assignments on a Unity Catalog securable (``databricks grants get``)."""
    out = run_cli_json(["grants", "get", securable_type, full_name, "--output", "json"], profile, run, timeout)
    if not isinstance(out, dict):
        raise CliError("databricks grants get did not print grants")
    return _json_list(out.get("privilege_assignments") or [], "privilege_assignments", "databricks grants get")


def list_catalogs(profile: str = "", run: Any = subprocess.run, timeout: int = 300) -> list[dict[str, Any]]:
    """Every Unity Catalog catalog the identity sees (``databricks catalogs list --output json``)."""
    out = run_cli_json(["catalogs", "list", "--output", "json"], profile, run, timeout)
    return _json_list(out, "catalogs", "databricks catalogs list")


def get_schema(full_name: str, profile: str = "", run: Any = subprocess.run, timeout: int = 300) -> dict[str, Any]:
    """A Unity Catalog schema (``databricks schemas get <catalog.schema>``), e.g. for its ``owner``."""
    schema = run_cli_json(["schemas", "get", full_name, "--output", "json"], profile, run, timeout)
    if not isinstance(schema, dict):
        raise CliError("databricks schemas get did not print a schema")
    return schema


# The description databricks.yml gives the app (every release since 0.8.0); with the app.yml settings below,
# what marks an app as one this installer deployed.
APP_DESCRIPTION = "Vibe Data Modeling control plane"
OUR_APP_YML_KEYS = ("VIBE_MODELING_LAKEBASE_PROJECT", "VIBE_MODELING_DATABASE_NAME", "VIBE_MODELING_DEPLOYMENT_CATALOG")


def our_apps(apps: list[dict[str, Any]]) -> list[dict[str, Any]]:
    """The apps with this bundle's description: the only candidates of an "is it ours" check."""
    return [app for app in apps if (app.get("description") or "") == APP_DESCRIPTION]


def is_our_app(app: dict[str, Any], app_yml_env: dict[str, str] | None) -> bool:
    """An app this installer deployed: this bundle's description, and its running app.yml sets the Lakebase
    project, database and catalog (``app_yml_env`` from ``render_app_yaml.read_env``; None when unread)."""
    return bool(our_apps([app])) and app_yml_env is not None and all(k in app_yml_env for k in OUR_APP_YML_KEYS)


def read_active_app_yml(active: Any, profile: str = "", run: Any = subprocess.run, timeout: int = 300,
                        snapshot_only: bool = False) -> tuple[str, str, str]:
    """``(app.yml text, its path, which deployment it belongs to)`` of an app's active deployment; ``CliError``
    with the reason otherwise.

    A snapshot deployment (``deployment_artifacts``) is read from its snapshot only: the source folder it
    was deployed from may since hold another app's files (0.8.x deployed every app of an identity from one
    folder), or be gone. Only a deployment without a snapshot is read from its source folder, and not at all
    with ``snapshot_only``.
    """
    if not isinstance(active, dict) or not active:
        raise CliError("the app has no active deployment")
    deployment = active.get("deployment_id") or "unknown"
    artifacts = active.get("deployment_artifacts")
    if artifacts:
        snapshot = (artifacts.get("source_code_path") or "") if isinstance(artifacts, dict) else ""
        if not snapshot:
            raise CliError(f"the active deployment {deployment} names no snapshot path")
        try:
            return (export_workspace_file(f"{snapshot}/app.yml", profile, run, timeout), f"{snapshot}/app.yml",
                    f"the snapshot of the running deployment {deployment}")
        except CliError as exc:
            creator = active.get("creator") or "its creator"
            raise CliError(f"the app.yml of the running deployment {deployment} could not be read ({exc}); its "
                           f"creator ({creator}) or a workspace admin can read it") from None
    if snapshot_only:
        raise CliError(f"the active deployment {deployment} has no snapshot")
    folder = active.get("source_code_path") or ""
    if not folder:
        raise CliError(f"the active deployment {deployment} names no source code path")
    return (export_workspace_file(f"{folder}/app.yml", profile, run, timeout), f"{folder}/app.yml",
            f"the source folder of deployment {deployment}; it can be newer than what runs")


class NotConfirmed(Exception):
    """The operator did not confirm, or there was no terminal to ask on; the message says what to do."""


_YES = ("y", "Y", "yes", "YES", "Yes")
NOT_CONFIRMED = "not confirmed; nothing was deployed."


def confirm(question: str, *, assume_yes: bool, no_terminal: str, declined: str = NOT_CONFIRMED,
            stdin: Any = None) -> None:
    """Ask ``question`` y/N on stderr. ``assume_yes`` (``--yes``) skips it; with no terminal on stdin it raises
    ``NotConfirmed(no_terminal)``; anything but yes, an empty line, end of input or Ctrl-C raises
    ``NotConfirmed(declined)``."""
    stdin = sys.stdin if stdin is None else stdin
    if assume_yes:
        print("    Continuing (--yes).", file=sys.stderr)
        return
    if not stdin.isatty():
        raise NotConfirmed(no_terminal)
    print(f"    {question} [y/N] ", end="", file=sys.stderr, flush=True)
    try:
        answer = (stdin.readline() or "").strip()
    except (KeyboardInterrupt, EOFError):
        print(file=sys.stderr)
        raise NotConfirmed(declined) from None
    if answer not in _YES:
        raise NotConfirmed(declined)
    print("    Continuing (confirmed).", file=sys.stderr)


def _main(argv: list[str]) -> int:
    p = argparse.ArgumentParser(prog="_install_common.py")
    sub = p.add_subparsers(dest="cmd", required=True)
    exists = sub.add_parser("app-exists", help="Exit 0 (and print the app as JSON) when the app exists, "
                                               "3 when not, 1 when unknown (the reason on stderr)")
    exists.add_argument("name")
    exists.add_argument("--profile", default="")
    sub.add_parser("uses-github-connection",
                   help="Read an app's JSON on stdin: exit 0 when it declares the github_pr connection, 3 when not")
    args = p.parse_args(argv)
    if args.cmd == "uses-github-connection":
        try:
            app = json.loads(sys.stdin.read() or "null")
        except ValueError:
            print("not an app JSON", file=sys.stderr)
            return APP_LOOKUP_FAILED
        if not isinstance(app, dict):
            print("not an app JSON", file=sys.stderr)
            return APP_LOOKUP_FAILED
        return APP_EXISTS if uses_github_connection(app) else APP_ABSENT
    try:
        app = find_app(args.name, args.profile)
    except AppLookupError as exc:
        print(str(exc), file=sys.stderr)
        return APP_LOOKUP_FAILED
    if app is None:
        return APP_ABSENT
    print(json.dumps(app))
    return APP_EXISTS


if __name__ == "__main__":
    sys.exit(_main(sys.argv[1:]))

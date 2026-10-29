"""Deploy settings: the values every deploy renders into the App.

``install/install.sh``, other deploy scripts that read the environment, and the bundle build hook
(``install/build_and_render.sh``) all resolve the settings here. For each value
the first source that has it wins:

1. a flag of the calling script, passed as ``--set NAME=VALUE`` (source ``flag``);
2. the environment, ``VIBE_MODELING_*`` (source ``env``); ``install.sh`` passes
   ``--ignore-env``, so only its flags change a value. A value that replaces a
   different deployed one gets a note;
3. with ``--read-deployed`` (``install.sh``, and any deploy script, on an app that
   exists), the running app (source ``deployed``, ``read_deployed``): the
   rendered values from the ``app.yml`` of its active deployment's snapshot
   (from its source folder only for a deployment without a snapshot), with the
   deployment's ``env_vars`` on top, the bundle target from its resources (the
   ``github_pr`` connection means ``github-publish``), the Lakebase range from
   its project's ``primary`` endpoint. Read only, at most three CLI calls of
   ``READ_TIMEOUT_S`` each; a value an older release did not render
   (``PREDATES``) takes the default with a note;
4. the default in ``install/_feature_defaults.sh`` (source ``default``).

No file left by an earlier run is read: not a settings file, not the checkout's
``src/app/app.yml`` or ``src/app/.build/app.yml`` (the template holds defaults,
and ``apx build`` copies it into ``.build`` on every build). The source of each
value is printed, so a deploy that would drop a setting shows it. With
``--confirm`` the resolver asks y/N before every deploy of an existing app,
also when every value is flagged (``--yes`` takes the values; with no terminal
it refuses).

Fail closed (exit 2): without an app name (``--app-name``,
``VIBE_MODELING_APP_NAME``, ``BUNDLE_VAR_app_name`` or the hook's
``--bundle-app-name``); when any of ``REQUIRED`` (every value rendered into
app.yml, and the bundle target; the model service and the reader only while
their feature is on) is neither flagged, exported nor read from the running
app, naming every missing one and why it could not be read, so a feature is
never turned off silently. A stopped app has no active deployment: the message
says so and gives both ways on, the flags or ``databricks apps start``. The
caller allows defaults with ``--fresh-ok`` (``install.sh`` for an app that does
not exist yet), and so does ``VIBE_MODELING_ALLOW_DEFAULT_SETTINGS=1`` where the
environment is read. The bundle hook renders exported values only and reads
nothing from the workspace (``NOT_EXPORTED``).

The bundle hook passes the target and the app name the CLI deploys
(``--bundle-target``, ``--bundle-app-name``, interpolated from ``${bundle.target}``
and ``${var.app_name}``): a target other than the exported one refuses with
``TARGET_MISMATCH``, and an exported app name other than the deployed one with
``APP_NAME_MISMATCH``.

Defaults for a new app are per app name: the Lakebase project is the app name,
the catalog and database are the app name with ``-`` as ``_`` (``isolation_defaults``).

Shared resources (``shared_resource_check``, read only, bounded): only for a
Lakebase project or catalog value that differs from the app's own deployed
value (or when its own value could not be read); a plain re-run makes no call.
The candidates are the other apps with this bundle's description
(``_install_common.our_apps``). A project another app's service principal has a
role on refuses (``SHARED_PROJECT``; no flag lifts it), and so does a project
whose roles can't be read. A catalog that another app's running app.yml sets,
or that its service principal holds privileges on (``<catalog>._metamodel``
first, else the catalog), refuses with ``SHARED_CATALOG`` unless this run sets
``VIBE_MODELING_ALLOW_SHARED_RESOURCES`` (a flag, or the environment where it is
read); when neither signal can see some apps, it warns and goes on.

Usage (the shell callers ``eval`` the ``--shell`` output, ``export`` lines with
shell-quoted values)::

    python install/deploy_settings.py resolve [--app-name <name>] [--profile <p>]
        [--set NAME=VALUE ...] [--ignore-env] [--fresh-ok] [--shell]
        [--read-deployed [--confirm [--yes]] [--install-flags]]   (an existing app)
        [--no-guard] [--database-follows-catalog]
        [--bundle-app-name <name> --bundle-target <target>]   (the bundle build hook)
    python install/deploy_settings.py resolve --check [--app-name <name>] [--set NAME=VALUE ...]

``--check`` validates the flags offline and prints nothing. Without ``--profile``
(or with an empty one) the profile is ``DATABRICKS_CONFIG_PROFILE``.

Exit codes: 0 ok; 2 refused or invalid (the message says why).
"""

from __future__ import annotations

import argparse
import functools
import math
import os
import re
import shlex
import subprocess
import sys
import time
from collections.abc import Callable, Mapping
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

from _install_common import (CliError, NotConfirmed, confirm, get_app, get_grants, get_lakebase_endpoint,
                             get_lakebase_role, get_schema, is_our_app, lakebase_endpoint_name, list_apps, list_catalogs,
                             list_lakebase_projects, list_lakebase_roles, load_backend_module, our_apps,
                             read_active_app_yml, uses_github_connection)
from render_app_yaml import BUNDLE_TARGETS, ENV_TARGETS, read_env

INSTALL_DIR = Path(__file__).resolve().parent
REPO_ROOT = INSTALL_DIR.parent
DEFAULTS_FILE = INSTALL_DIR / "_feature_defaults.sh"
SERVICE_NAME_PATH = REPO_ROOT / "src/app/src/vibe_modeling/backend/taxonomy/service_name.py"

PROJECT = "VIBE_MODELING_LAKEBASE_PROJECT"
DATABASE = "VIBE_MODELING_DATABASE_NAME"
CATALOG = "VIBE_MODELING_DEPLOYMENT_CATALOG"
WAREHOUSE = "VIBE_MODELING_WAREHOUSE_ID"
TAXONOMY = "VIBE_MODELING_TAXONOMY_BUILDER_ENABLED"
MODEL_SERVICE = "VIBE_MODELING_TAXONOMY_MODEL_SERVICE"
ASSESSMENT = "VIBE_MODELING_ASSESSMENT_ENABLED"
READER = "VIBE_MODELING_ASSESS_READER_SP"
RUN_TAGS = "VIBE_MODELING_RUN_TAGS_DEFAULT"
TARGET = "VIBE_MODELING_BUNDLE_TARGET"
MIN_CU = "VIBE_MODELING_LAKEBASE_MIN_CU"
MAX_CU = "VIBE_MODELING_LAKEBASE_MAX_CU"
ALLOW_SHARED = "VIBE_MODELING_ALLOW_SHARED_RESOURCES"

SETTINGS = (PROJECT, DATABASE, CATALOG, WAREHOUSE, TAXONOMY, MODEL_SERVICE, ASSESSMENT, READER, RUN_TAGS,
            TARGET, MIN_CU, MAX_CU, ALLOW_SHARED)
BOOLEANS = (TAXONOMY, ASSESSMENT, RUN_TAGS, ALLOW_SHARED)
# An existing app's deploy needs each of these from a flag, the environment or the running app: every value
# rendered into app.yml, and the bundle target. The Lakebase range is not: only install.sh uses it (it creates
# a project with it; an existing one changes only on --lakebase-resize).
REQUIRED = (*ENV_TARGETS, TARGET)
# Needed only while their feature is on.
_ONLY_WHEN_ON = {MODEL_SERVICE: TAXONOMY, READER: ASSESSMENT}
# The install.sh flag that sets each setting, for the refusal of values that could not be read.
INSTALL_FLAGS = {PROJECT: "--project", DATABASE: "--database|--catalog", CATALOG: "--catalog",
                 WAREHOUSE: "--warehouse-id",
                 TAXONOMY: "--enable-taxonomy-builder (with --taxonomy-model-service)|--disable-taxonomy-builder",
                 MODEL_SERVICE: "--taxonomy-model-service",
                 ASSESSMENT: "--enable-assessment (with --assess-reader-sp)|--disable-assessment",
                 READER: "--assess-reader-sp",
                 RUN_TAGS: "--run-tags|--no-run-tags", TARGET: "--enable-github-publish|--disable-github-publish"}
# The release that added each rendered value an older app.yml may not have: an app that runs without it
# predates that release, so the default applies (said in a note) and the value is not missing.
PREDATES = {RUN_TAGS: "0.9.0", TAXONOMY: "0.8.0", MODEL_SERVICE: "0.8.0", ASSESSMENT: "0.8.0", READER: "0.8.0"}
# Each CLI call of the readback (at most three: apps get, workspace export, postgres get-endpoint).
READ_TIMEOUT_S = 120
# install.sh's app lookup (``_install_common.find_app``); the check reads the app list with the same bound.
LOOKUP_TIMEOUT_S = 300
# The shared-resource check: each call, the whole check, the other apps whose snapshot it reads, the roles it
# looks up one by one.
GUARD_CALL_TIMEOUT_S = 60
GUARD_BUDGET_S = 180
GUARD_APPS_CAP = 25
GUARD_ROLES_CAP = 20

APP_NAME_ENV = "VIBE_MODELING_APP_NAME"
BUNDLE_VAR_APP_NAME = "BUNDLE_VAR_app_name"
ALLOW_DEFAULTS_ENV = "VIBE_MODELING_ALLOW_DEFAULT_SETTINGS"
PROFILE_ENV = "DATABRICKS_CONFIG_PROFILE"
DEFAULT_APP_NAME = "APP_NAME"

# Lakebase Autoscaling: 0.5-32 CU, and the range may span at most 16 CU.
CU_MIN, CU_MAX, CU_SPREAD = 0.5, 32.0, 16.0

FAIL_CLOSED = ("This deploy would reset the app's settings to defaults. Run install/install.sh, or export "
               "VIBE_MODELING_APP_NAME and the app's VIBE_MODELING_* settings, or set "
               "VIBE_MODELING_ALLOW_DEFAULT_SETTINGS=1.")
NOT_EXPORTED = ("This deploy of app '{app}' does not export {missing}. install.sh reads them from "
                "the running app and exports them; a hand-run bundle deploy must export every one "
                "(`install/install.sh --dry-run --app-name {app}` prints the values the app runs with).")
UNREAD_INSTALL = ("App '{app}' already exists. These settings could not be read from it: {reasons}. Pass these "
                  "install.sh flags with the values the app runs with (an empty value is allowed, e.g. "
                  "--warehouse-id ''): {missing}.")
UNREAD_ENV = ("App '{app}': these settings could not be read from it: {reasons}. Export them with the values the "
              "app runs with: {missing} (VIBE_MODELING_ALLOW_DEFAULT_SETTINGS=1 deploys the defaults instead).")
STOPPED = ("app '{app}' is stopped, so it has no active deployment to read its settings from: pass them (below), "
           "or start the app (`databricks apps start {app}`) and re-run so they are read")
DEPLOYED_INTRO = "App '{app}' exists. The values marked (deployed) were read from the app as it runs now:"
CONFIRM_QUESTION = "Deploy app '{app}' with these settings?"
NOT_CONFIRMED_SETTINGS = ("not confirmed; nothing was deployed. To change a value, pass its flag (a flag wins over "
                          "the deployed value).")
NO_TERMINAL_SETTINGS = ("refusing to deploy the settings read from the running app without confirmation, and there "
                        "is no terminal to ask on. Check them with --dry-run, then re-run with --yes (pass a flag to "
                        "change any value). Nothing was deployed.")
RUN_TAGS_PREDATES = ("VIBE_MODELING_RUN_TAGS_DEFAULT is not in the deployed app.yml (added in 0.9.0): the default "
                     "'true' applies; the first upgrade to 0.9.0 or later turns run tags on, pass --no-run-tags to "
                     "keep them off.")
TARGET_MISMATCH = ("This deploy runs the '{cli}' bundle target, but app '{app}' is set to '{resolved}' ({source}). "
                   "Deploy with --target {resolved}, or switch the app's target with install/install.sh "
                   "--enable-github-publish or --disable-github-publish (or export VIBE_MODELING_BUNDLE_TARGET={cli}).")
APP_NAME_MISMATCH = ("This deploy deploys app '{deployed}' (the bundle's app_name variable), but {env}='{exported}' "
                     "names another app; its settings would be rendered into '{deployed}'. Export the same name, "
                     "or unset {env}.")
SHARED_PROJECT = ("App '{other}' already uses the Lakebase project '{value}' on this workspace ({evidence}), and "
                  "this deploy points app '{app}' at it too. Two apps can't share a Lakebase project: they would "
                  "share its compute endpoint, its CU range and its roles, and with one database provisioning makes "
                  "the newer app's service principal the owner of the other's tables. Pass another --project "
                  "(VIBE_MODELING_LAKEBASE_PROJECT for a hand-run deploy). Moving an installed app "
                  "to another project starts it with an empty database. No flag lifts this.")
PROJECT_UNCHECKED = ("could not check whether another app uses Lakebase project '{value}': {reason}. Nothing was "
                     "deployed.")
SHARED_CATALOG = ("The catalog '{value}' looks used by app '{other}' on this workspace ({evidence}), and this deploy "
                  "points app '{app}' at it too. Two apps on one catalog share its _metamodel: one app's installs, "
                  "uninstalls and deletes act on the other's models. Pass another --catalog, or keep the share on "
                  "this run with install.sh --allow-shared-resources (VIBE_MODELING_ALLOW_SHARED_RESOURCES=true "
                  "where the environment is read).")
CATALOG_UNCHECKED = ("could not check whether app(s) {apps} use the catalog '{value}' ({why}); continuing: make sure "
                     "no other app uses it")
OWN_UNREAD = ("the app's own {what} could not be read, so '{value}' is checked like a new one against the other "
              "apps")

# A value flag -> (its flag name, the setting that must be on, that setting's enable flag).
_NEEDS_ENABLED = {MODEL_SERVICE: ("--taxonomy-model-service", TAXONOMY, "--enable-taxonomy-builder"),
                  READER: ("--assess-reader-sp", ASSESSMENT, "--enable-assessment")}
_DEFAULT_LINE = re.compile(r'^DEFAULT_([A-Z_]+)="([^"$`\\]*)"$')
_APP_NAME = re.compile(r"^[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?$")
_UUID = re.compile(r"^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$")


class SettingsError(Exception):
    """A deploy the settings refuse; the message tells the operator what to do."""


@dataclass
class Resolution:
    app_name: str
    values: dict[str, str] = field(default_factory=dict)
    sources: dict[str, str] = field(default_factory=dict)
    notes: list[str] = field(default_factory=list)
    # Where the deployed values were read (app.yml path and deployment, bundle target, Lakebase endpoint).
    origin: list[str] = field(default_factory=list)
    # The running app was read and is this bundle's app (``_install_common.is_our_app``).
    recognized: bool = False


@dataclass
class DeployedRead:
    """What ``read_deployed`` read from the running app: ``values`` per setting, ``unread`` (setting -> why
    not), ``predates`` (a rendered setting absent from an app.yml older than the release that added it ->
    that release), ``origin`` (where each part was read), ``notes`` and ``recognized`` (this bundle's app)."""
    values: dict[str, str] = field(default_factory=dict)
    unread: dict[str, str] = field(default_factory=dict)
    predates: dict[str, str] = field(default_factory=dict)
    origin: list[str] = field(default_factory=list)
    notes: list[str] = field(default_factory=list)
    recognized: bool = False


def load_defaults(path: Path = DEFAULTS_FILE) -> dict[str, str]:
    """``NAME -> default`` from ``_feature_defaults.sh`` (literal assignments only)."""
    out: dict[str, str] = {}
    for lineno, raw in enumerate(path.read_text().splitlines(), 1):
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        m = _DEFAULT_LINE.match(line)
        if not m:
            raise RuntimeError(f"{path.name}:{lineno}: not a literal DEFAULT_<NAME>=\"<value>\" line")
        out[m.group(1)] = m.group(2)
    missing = [k for k in (*SETTINGS, DEFAULT_APP_NAME) if k not in out]
    if missing:
        raise RuntimeError(f"{path.name} has no default for {', '.join(missing)}")
    return out


def isolation_defaults(app_name: str) -> dict[str, str]:
    """A new app's own Lakebase project, database and catalog: the app name, and the app name with '-' as '_'
    (a UC catalog and a Postgres database name take no hyphens). ``vibe-modeling`` gives today's defaults."""
    snake = app_name.replace("-", "_")
    return {PROJECT: app_name, DATABASE: snake, CATALOG: snake}


def check_capacity(min_cu: str | float, max_cu: str | float) -> tuple[float, float]:
    """The Lakebase autoscaling range as floats; ``ValueError`` when Lakebase would reject it."""
    try:
        lo, hi = float(min_cu), float(max_cu)
    except (TypeError, ValueError):
        raise ValueError(f"Lakebase capacity must be numbers of CU, got min '{min_cu}', max '{max_cu}'") from None
    if not (CU_MIN <= lo <= hi <= CU_MAX):
        raise ValueError(f"Lakebase capacity {lo:g}-{hi:g} CU: need {CU_MIN:g} <= min <= max <= {CU_MAX:g}")
    if hi - lo > CU_SPREAD:
        raise ValueError(f"Lakebase capacity {lo:g}-{hi:g} CU: max - min may be at most {CU_SPREAD:g} CU")
    return lo, hi


def validate_app_name(name: str) -> str:
    if not _APP_NAME.match(name):
        raise SettingsError(f"app name '{name}' is not a Databricks App name (lowercase letters, digits, '-')")
    return name


def app_name_from_env(env: Mapping[str, str]) -> str:
    """The app name the bundle hook deploys: ``VIBE_MODELING_APP_NAME`` or ``BUNDLE_VAR_app_name``."""
    explicit, bundle_var = env.get(APP_NAME_ENV, ""), env.get(BUNDLE_VAR_APP_NAME, "")
    if explicit and bundle_var and explicit != bundle_var:
        raise SettingsError(f"{APP_NAME_ENV}='{explicit}' and {BUNDLE_VAR_APP_NAME}='{bundle_var}' differ")
    return explicit or bundle_var


def _apply_env_vars(out: DeployedRead, active: Mapping[str, Any]) -> None:
    """The deployment's ``env_vars`` override the app.yml values they set; one with only ``value_from`` is unread."""
    for item in active.get("env_vars") or []:
        name = (item or {}).get("name") if isinstance(item, Mapping) else None
        if name not in ENV_TARGETS:
            continue
        if item.get("value") is not None:
            out.values[name] = str(item["value"])
            out.unread.pop(name, None)
            out.predates.pop(name, None)
        elif item.get("value_from"):
            out.values.pop(name, None)
            out.unread[name] = f"the active deployment sets it from '{item['value_from']}' (env_vars), not a value"
    if any(isinstance(item, Mapping) and item.get("name") in ENV_TARGETS for item in active.get("env_vars") or []):
        out.origin.append("env_vars of the active deployment (over its app.yml)")


def read_deployed(app_name: str, profile: str = "", run: Any = subprocess.run,
                  timeout: int = READ_TIMEOUT_S) -> DeployedRead:
    """The settings the app runs with, read from the workspace (read only; at most three CLI calls, each
    bounded by ``timeout``, no retries).

    The rendered values come from the active deployment's ``app.yml`` (``render_app_yaml.read_env``) with its
    ``env_vars`` on top, the bundle target from the app's resources (the ``github_pr`` connection means
    ``github-publish``), the Lakebase range from the deployed project's ``primary`` endpoint. Anything that
    can't be read is in ``unread`` with the reason (the Lakebase range only gets a note: it is not required).
    A stopped app has no active deployment; its reason says how to go on.
    """
    out = DeployedRead()
    try:
        app = get_app(app_name, profile, run, timeout)
    except CliError as exc:
        out.unread = {key: str(exc) for key in REQUIRED}
        out.notes.append("the Lakebase capacity was not read (the app could not be read): the default applies")
        return out
    target = "github-publish" if uses_github_connection(app) else "dev"
    out.values[TARGET] = target
    out.origin.append(f"bundle target '{target}': the app declares "
                      f"{'the' if target == 'github-publish' else 'no'} github_pr UC connection resource")
    active = app.get("active_deployment")
    try:
        if not isinstance(active, Mapping) or not active:
            if (app.get("compute_status") or {}).get("state") == "STOPPED":
                raise CliError(STOPPED.format(app=app_name))
            raise CliError(f"app '{app_name}' has no active deployment")
        text, path, what = read_active_app_yml(active, profile, run, timeout)
    except CliError as exc:
        out.unread.update({key: str(exc) for key in ENV_TARGETS})
        out.notes.append("the Lakebase capacity was not read (the app's Lakebase project is unknown): the default "
                         "applies")
        return out
    out.origin.append(f"app.yml: {path} ({what})")
    env = read_env(text)
    out.recognized = is_our_app(app, env)
    for key in ENV_TARGETS:
        if key in env:
            out.values[key] = env[key]
        elif key in PREDATES:
            out.predates[key] = PREDATES[key]
        else:
            out.unread[key] = f"{path} sets no value for it"
    _apply_env_vars(out, active)
    project = out.values.get(PROJECT, "")
    if project:
        _read_capacity(out, project, profile, run, timeout)
    return out


def _read_capacity(out: DeployedRead, project: str, profile: str, run: Any, timeout: int) -> None:
    """The deployed Lakebase range into ``out`` when the endpoint reports one that ``check_capacity`` takes;
    otherwise a note, and the default applies."""
    name = lakebase_endpoint_name(project)
    try:
        status = get_lakebase_endpoint(project, profile, run, timeout).get("status") or {}
    except CliError as exc:
        out.notes.append(f"the Lakebase capacity was not read ({exc}): the default applies")
        return
    lo, hi = status.get("autoscaling_limit_min_cu"), status.get("autoscaling_limit_max_cu")
    if lo is None or hi is None:
        out.notes.append(f"{name} reports no autoscaling range yet: the default Lakebase capacity applies")
        return
    try:
        lo_f, hi_f = check_capacity(lo, hi)
    except ValueError as exc:
        out.notes.append(f"{name}: {exc}; the default Lakebase capacity applies")
        return
    out.values[MIN_CU], out.values[MAX_CU] = f"{lo_f:g}", f"{hi_f:g}"
    out.origin.append(f"Lakebase capacity: {name}")


def _check_value(key: str, value: str) -> str:
    """One setting's value on its own; ``SettingsError`` when no merge could make it valid. Returns it normalized."""
    if "\n" in value or "\r" in value:
        raise SettingsError(f"{key} contains a line break")
    if key in BOOLEANS:
        value = value.strip().lower()
        if value not in ("true", "false"):
            raise SettingsError(f"{key} must be true or false, got '{value}'")
    if key == TARGET and value not in BUNDLE_TARGETS:
        raise SettingsError(f"{TARGET} must be one of {', '.join(BUNDLE_TARGETS)}, got '{value}'")
    if key == READER and value and not _UUID.match(value):
        raise SettingsError(f"--assess-reader-sp must be a service principal application id (UUID), got '{value}'")
    if key in (MIN_CU, MAX_CU):
        try:
            float(value)
        except ValueError:
            raise SettingsError(f"Lakebase capacity must be numbers of CU, got '{value}'") from None
    return value


def _validate(values: dict[str, str]) -> None:
    for key in SETTINGS:
        values[key] = _check_value(key, values[key])
    try:
        check_capacity(values[MIN_CU], values[MAX_CU])
    except ValueError as exc:
        raise SettingsError(str(exc)) from None
    if values[TAXONOMY] == "true":
        _check_model_service(values[MODEL_SERVICE])


def _check_model_service(name: str) -> None:
    try:
        load_backend_module(SERVICE_NAME_PATH).split_model_service_name(name)
    except ValueError as exc:
        raise SettingsError(str(exc)) from None


def check_flags(flags: Mapping[str, str], app_name: str = "") -> None:
    """The checks a flag passes on its own, before any tool or workspace call (``resolve --check``)."""
    unknown = sorted(set(flags) - set(SETTINGS))
    if unknown:
        raise SettingsError(f"not deploy settings: {', '.join(unknown)}")
    if app_name:
        validate_app_name(app_name)
    for key, value in flags.items():
        _check_value(key, value)
    if MIN_CU in flags and MAX_CU in flags:
        try:
            check_capacity(flags[MIN_CU], flags[MAX_CU])
        except ValueError as exc:
            raise SettingsError(str(exc)) from None
    if flags.get(MODEL_SERVICE):
        _check_model_service(flags[MODEL_SERVICE])
    for key, (flag, enable_key, enable_flag) in _NEEDS_ENABLED.items():
        if flags.get(key) and flags.get(enable_key, "").strip().lower() == "false":
            raise SettingsError(f"{flag} requires {enable_flag}")


def _same_name(a: str | None, b: str | None) -> bool:
    """Lakebase project ids and Unity Catalog names compare without case and surrounding whitespace."""
    return (a or "").strip().lower() == (b or "").strip().lower()


def _differs(key: str, a: str, b: str) -> bool:
    if key in BOOLEANS:
        return a.strip().lower() != b.strip().lower()
    return a != b


def _unread_reasons(deployed: DeployedRead, missing: list[str]) -> str:
    """The reason each missing setting was not read, one group per reason: ``<reason> (KEY, KEY)``."""
    groups: dict[str, list[str]] = {}
    for key in missing:
        groups.setdefault(deployed.unread.get(key, "not read"), []).append(key)
    return "; ".join(f"{reason} ({', '.join(keys)})" for reason, keys in groups.items())


class _Budget:
    """The shared-resource check's time budget; each call gets at most ``GUARD_CALL_TIMEOUT_S``."""

    def __init__(self, seconds: float = GUARD_BUDGET_S, clock: Callable[[], float] = time.monotonic):
        self.clock, self.deadline = clock, clock() + seconds

    def timeout(self) -> int:
        left = self.deadline - self.clock()
        if left <= 0:
            raise CliError(f"the check's time budget ({GUARD_BUDGET_S} s) ran out")
        return max(1, min(GUARD_CALL_TIMEOUT_S, math.ceil(left)))


def _project_owner(value: str, sps: Mapping[str, str], profile: str, run: Any, budget: _Budget) -> tuple[str, str] | None:
    """``(app, evidence)`` when another app's service principal has a role on the project; ``CliError`` when that
    can't be told (roles unreadable, or more than ``GUARD_ROLES_CAP`` roles to look up one by one)."""
    projects = list_lakebase_projects(profile, run, budget.timeout())
    ids = {(p.get("project_id") or (p.get("name") or "").rsplit("/", 1)[-1]).lower() for p in projects}
    if value.strip().lower() not in ids:
        return None
    lookups = 0
    for role in list_lakebase_roles(value.strip(), profile, run, budget.timeout()):
        principal = (role.get("status") or {}).get("postgres_role")
        if not principal:
            lookups += 1
            if lookups > GUARD_ROLES_CAP:
                raise CliError(f"more than {GUARD_ROLES_CAP} of its roles report no principal, the most this check "
                               f"looks up one by one")
            principal = (get_lakebase_role(role.get("name") or "", profile, run, budget.timeout()).get("status")
                         or {}).get("postgres_role")
        if principal and principal in sps:
            return sps[principal], "its service principal has a role on the project"
    return None


def _catalog_grantees(value: str, profile: str, run: Any, budget: _Budget) -> tuple[dict[str, str], str]:
    """``(principal -> evidence, why unreadable)``: the owner and grantees of ``<catalog>._metamodel``, else the
    catalog's grantees; ``why`` is '' when one of them could be read."""
    schema = f"{value}._metamodel"
    try:
        found = {g.get("principal", ""): f"its service principal has privileges on {schema}"
                 for g in get_grants("schema", schema, profile, run, budget.timeout())}
        owner = get_schema(schema, profile, run, budget.timeout()).get("owner") or ""
        if owner:
            found[owner] = f"its service principal owns {schema}"
        return found, ""
    except CliError as schema_exc:
        try:
            return ({g.get("principal", ""): f"its service principal has privileges on catalog {value}"
                     for g in get_grants("catalog", value, profile, run, budget.timeout())}, "")
        except CliError as exc:
            return {}, f"the grants of {schema} and of catalog {value} can't be read: {schema_exc}; {exc}"


def _catalog_user(value: str, apps: list[dict[str, Any]], sps: Mapping[str, str], profile: str, run: Any,
                  budget: _Budget) -> tuple[tuple[str, str] | None, list[str], str]:
    """``((app, evidence) or None, apps not checked, why the grants are unreadable)``."""
    grantees, grants_unreadable = _catalog_grantees(value, profile, run, budget)
    for principal, evidence in grantees.items():
        if principal in sps:
            return (sps[principal], evidence), [], ""
    unchecked = []
    for i, app in enumerate(apps):
        name = app.get("name", "?")
        if i >= GUARD_APPS_CAP:
            unchecked.append(name)
            continue
        try:
            text = read_active_app_yml(app.get("active_deployment"), profile, run, budget.timeout(),
                                       snapshot_only=True)[0]
        except CliError:
            unchecked.append(name)
            continue
        if _same_name(read_env(text).get(CATALOG), value):
            return (name, "its running app.yml sets it"), [], ""
    return None, unchecked, grants_unreadable


def _catalog_may_exist(value: str, profile: str, run: Any, budget: _Budget) -> bool:
    """False only when the catalog list (read in full) lacks the catalog: a new catalog has no other app on it."""
    try:
        names = {(c.get("name") or "").lower() for c in list_catalogs(profile, run, budget.timeout())}
    except CliError:
        return True
    return value.strip().lower() in names


def shared_resource_check(res: Resolution, own: Mapping[str, str], own_unread: Mapping[str, str], *,
                          profile: str = "", run: Any = subprocess.run,
                          clock: Callable[[], float] = time.monotonic) -> None:
    """Refuse a Lakebase project, or a catalog unless this run allows the share, that another app of ours uses.

    Only a value that differs from the app's own deployed one is checked (a plain re-run makes no call); a value
    the readback could not see is checked like a new one, with a note. Read only, bounded by ``_Budget``.
    """
    fresh, own_notes = [], []
    for key, what in ((PROJECT, "Lakebase project"), (CATALOG, "catalog")):
        value = res.values[key]
        if not value.strip() or (key in own and _same_name(own[key], value)):
            continue
        if key in own_unread:
            own_notes.append(OWN_UNREAD.format(what=what, value=value))
        fresh.append(key)
    res.notes += own_notes
    if not fresh:
        return

    def refuse(message: str) -> SettingsError:
        return SettingsError(message + "".join(f" Note: {note}." for note in own_notes))

    try:
        apps = [a for a in our_apps(list_apps(profile, run, LOOKUP_TIMEOUT_S)) if a.get("name") != res.app_name]
    except CliError as exc:
        if PROJECT in fresh:
            raise refuse(PROJECT_UNCHECKED.format(value=res.values[PROJECT], reason=exc)) from None
        res.notes.append(CATALOG_UNCHECKED.format(apps="on this workspace", value=res.values[CATALOG],
                                                  why=f"the app list can't be read: {exc}"))
        return
    sps = {a["service_principal_client_id"]: a.get("name", "?") for a in apps if a.get("service_principal_client_id")}
    budget = _Budget(clock=clock)
    if PROJECT in fresh:
        try:
            hit = _project_owner(res.values[PROJECT], sps, profile, run, budget)
        except CliError as exc:
            raise refuse(PROJECT_UNCHECKED.format(value=res.values[PROJECT], reason=exc)) from None
        if hit:
            raise refuse(SHARED_PROJECT.format(other=hit[0], value=res.values[PROJECT], app=res.app_name,
                                                      evidence=hit[1]))
    if CATALOG not in fresh:
        return
    try:
        hit, unchecked, grants_unreadable = _catalog_user(res.values[CATALOG], apps, sps, profile, run, budget)
    except CliError as exc:
        hit, unchecked, grants_unreadable = None, [a.get("name", "?") for a in apps], str(exc)
    if hit:
        if res.values[ALLOW_SHARED] == "true" and res.sources[ALLOW_SHARED] in ("flag", "env"):
            res.notes.append(f"sharing the catalog '{res.values[CATALOG]}' with app '{hit[0]}' ({hit[1]}; "
                             f"{ALLOW_SHARED}=true, {res.sources[ALLOW_SHARED]})")
            return
        raise refuse(SHARED_CATALOG.format(value=res.values[CATALOG], other=hit[0], evidence=hit[1],
                                           app=res.app_name))
    if unchecked and grants_unreadable and _catalog_may_exist(res.values[CATALOG], profile, run, budget):
        res.notes.append(CATALOG_UNCHECKED.format(apps=", ".join(f"'{a}'" for a in unchecked),
                                                  value=res.values[CATALOG],
                                                  why=f"their running app.yml can't be read, and {grants_unreadable}"))


def resolve(*, app_name: str, flags: Mapping[str, str], env: Mapping[str, str], use_env: bool = True,
            allow_defaults: bool = False, defaults: Mapping[str, str] | None = None, install_flags: bool = False,
            database_follows_catalog: bool = False, bundle_target: str = "", deployed: DeployedRead | None = None,
            check_shared: Callable[[Resolution, Mapping[str, str], Mapping[str, str]], None] | None = None
            ) -> Resolution:
    """Merge flags, environment, the running app (``deployed``) and defaults; ``SettingsError`` when the deploy
    must not go on.

    ``bundle_target`` is the target the CLI deploys (the build hook passes it); empty when unknown.
    ``check_shared(res, own, own_unread)`` runs the shared-resource check (``shared_resource_check``).
    """
    defaults = dict(defaults if defaults is not None else load_defaults())
    if app_name:
        defaults.update(isolation_defaults(app_name))
    # The override is an environment switch, so it counts only where the environment does (not install.sh).
    allow = allow_defaults or (use_env and env.get(ALLOW_DEFAULTS_ENV, "") == "1")
    unknown = sorted(set(flags) - set(SETTINGS))
    if unknown:
        raise SettingsError(f"not deploy settings: {', '.join(unknown)}")
    if not app_name and not allow:
        raise SettingsError(FAIL_CLOSED)
    if app_name:
        validate_app_name(app_name)

    res = Resolution(app_name=app_name, recognized=bool(deployed and deployed.recognized))
    read = dict(deployed.values) if deployed else {}
    if PROJECT in flags and PROJECT in read and not _same_name(flags[PROJECT], read[PROJECT]) and MIN_CU in read:
        del read[MIN_CU], read[MAX_CU]
        res.notes.append(f"the deployed Lakebase capacity belongs to project '{read[PROJECT]}', not "
                         f"'{flags[PROJECT]}': the default applies (pass --lakebase-min-cu / --lakebase-max-cu)")
    if database_follows_catalog and CATALOG in flags and DATABASE not in flags:
        base_db = read.get(DATABASE, "")
        if base_db and base_db != read.get(CATALOG, ""):
            res.notes.append(f"keeping the deployed database '{base_db}' (it differs from the catalog); "
                             f"pass --database to change it")
        else:
            flags = {**flags, DATABASE: flags[CATALOG]}
    for key in SETTINGS:
        if key in flags:
            res.values[key], res.sources[key] = flags[key], "flag"
            if key in read and _differs(key, read[key], flags[key]):
                res.notes.append(f"{key}: the flag replaces the deployed value '{read[key] or '<empty>'}'")
        elif use_env and key in env:
            res.values[key], res.sources[key] = env[key], "env"
            if key in read and _differs(key, read[key], env[key]):
                res.notes.append(f"{key}: the environment replaces the deployed value '{read[key] or '<empty>'}'")
        elif key in read:
            res.values[key], res.sources[key] = read[key], "deployed"
        else:
            res.values[key] = "" if key == MODEL_SERVICE else defaults[key]
            res.sources[key] = "default"
    if deployed:
        res.origin = list(deployed.origin)
        res.notes += deployed.notes
        for key in deployed.predates:
            if res.sources[key] == "default":
                res.notes.append(RUN_TAGS_PREDATES if key == RUN_TAGS else
                                 f"{key} is not in the deployed app.yml (added in {deployed.predates[key]}): the "
                                 f"default '{res.values[key] or '<empty>'}' applies")

    if not allow:
        missing = [key for key in REQUIRED if res.sources[key] == "default"
                   and not (key in _ONLY_WHEN_ON and res.values[_ONLY_WHEN_ON[key]].strip().lower() != "true")
                   and key not in (deployed.predates if deployed else {})]
        if missing and deployed is None:
            raise SettingsError(NOT_EXPORTED.format(app=app_name, missing=", ".join(missing)))
        if missing and deployed is not None:
            reasons = _unread_reasons(deployed, missing)
            if install_flags:
                names = " ".join(dict.fromkeys(f"{INSTALL_FLAGS[key]} ({key})" for key in missing))
                raise SettingsError(UNREAD_INSTALL.format(app=app_name, reasons=reasons, missing=names))
            raise SettingsError(UNREAD_ENV.format(app=app_name, reasons=reasons, missing=" ".join(missing)))

    if res.values[TAXONOMY].strip().lower() == "true" and not res.values[MODEL_SERVICE]:
        res.values[MODEL_SERVICE], res.sources[MODEL_SERVICE] = defaults[MODEL_SERVICE], "default"
    _validate(res.values)
    for key, (flag, enable_key, enable_flag) in _NEEDS_ENABLED.items():
        if res.sources[key] == "flag" and res.values[key] and res.values[enable_key] != "true":
            raise SettingsError(f"{flag} requires {enable_flag}")

    if bundle_target and bundle_target != res.values[TARGET]:
        if res.sources[TARGET] != "default":
            raise SettingsError(TARGET_MISMATCH.format(cli=bundle_target, app=app_name or "<unset>",
                                                       resolved=res.values[TARGET], source=res.sources[TARGET]))
        res.values[TARGET], res.sources[TARGET] = bundle_target, "bundle"
        _validate(res.values)
    deployed_target = read.get(TARGET)
    if deployed_target and res.values[TARGET] != deployed_target:
        res.notes.append(f"the bundle target changes from '{deployed_target}' (deployed) to '{res.values[TARGET]}' "
                         f"({res.sources[TARGET]}): an update of the same app")
    if check_shared:
        check_shared(res, read, deployed.unread if deployed else {})
    return res


def format_table(res: Resolution) -> str:
    lines = [f"    deploy settings for app '{res.app_name or '<unset>'}':"]
    width = max(len(k) for k in SETTINGS)
    for key in SETTINGS:
        lines.append(f"      {key:<{width}} = {res.values[key] or '<empty>'}  ({res.sources[key]})")
    lines += [f"    note: {note}" for note in res.notes]
    return "\n".join(lines)


def format_origin(res: Resolution) -> str:
    """Where the ``(deployed)`` values were read, after ``DEPLOYED_INTRO``; '' when none is deployed."""
    if "deployed" not in res.sources.values():
        return ""
    return "\n".join([f"    {DEPLOYED_INTRO.format(app=res.app_name)}", *(f"      {line}" for line in res.origin)])


def shell_exports(res: Resolution) -> str:
    """``export`` lines for every setting (and the app name), then one plain assignment (not exported): whether
    the running app was read and is this bundle's app (``DEPLOY_SETTINGS_RECOGNIZED=true|false``)."""
    pairs = [(key, res.values[key]) for key in SETTINGS]
    if res.app_name:
        pairs.append((APP_NAME_ENV, res.app_name))
    lines = [f"export {key}={shlex.quote(value)}" for key, value in pairs]
    lines.append(f"DEPLOY_SETTINGS_RECOGNIZED={'true' if res.recognized else 'false'}")
    return "\n".join(lines)


def _parse_set(items: list[str]) -> dict[str, str]:
    out: dict[str, str] = {}
    for item in items:
        key, sep, value = item.partition("=")
        if not sep:
            raise SettingsError(f"--set expects NAME=VALUE, got '{item}'")
        out[key] = value
    return out


def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = p.add_subparsers(dest="cmd", required=True)
    r = sub.add_parser("resolve", help="Merge the settings, print their sources; --shell prints export lines")
    r.add_argument("--app-name", default=None, help="App name (default: VIBE_MODELING_APP_NAME or "
                                                    "BUNDLE_VAR_app_name)")
    r.add_argument("--profile", default="",
                   help="CLI profile of this deploy (empty: DATABRICKS_CONFIG_PROFILE)")
    r.add_argument("--set", dest="sets", action="append", default=[], metavar="NAME=VALUE",
                   help="A value from a flag of the calling script")
    r.add_argument("--ignore-env", action="store_true", help="Do not read VIBE_MODELING_* from the environment")
    r.add_argument("--fresh-ok", action="store_true", help="Allow defaults (a first install)")
    r.add_argument("--check", action="store_true",
                   help="Only validate the flags offline (before any tool or workspace call); prints nothing")
    r.add_argument("--no-guard", action="store_true",
                   help="Skip the shared-resource check (install.sh's dry run when the app lookup failed)")
    r.add_argument("--database-follows-catalog", action="store_true",
                   help="A flagged catalog also sets the database, unless the deployed database differs from its "
                        "catalog")
    r.add_argument("--install-flags", action="store_true",
                   help="Name install.sh's flags when settings could not be read (install.sh, existing app)")
    r.add_argument("--read-deployed", action="store_true",
                   help="Read the settings from the running app (an existing app)")
    r.add_argument("--confirm", action="store_true",
                   help="Ask y/N before deploying (refused with no terminal)")
    r.add_argument("--yes", action="store_true", help="With --confirm: take the settings without asking")
    r.add_argument("--shell", action="store_true", help="Print shell export lines on stdout")
    r.add_argument("--bundle-app-name", default="",
                   help="The app the CLI deploys (the build hook's ${var.app_name}); an exported app name must match")
    r.add_argument("--bundle-target", default="",
                   help="The target the CLI deploys (the build hook's ${bundle.target}); must match the resolved one")
    args = p.parse_args(argv if argv is not None else sys.argv[1:])

    env = os.environ
    # An empty --profile (install.sh without one) still honors DATABRICKS_CONFIG_PROFILE, like the CLI calls.
    profile = args.profile or env.get(PROFILE_ENV, "")
    try:
        flags = _parse_set(args.sets)
        if args.check:
            check_flags(flags, args.app_name or "")
            return 0
        app_name = args.app_name if args.app_name is not None else app_name_from_env(env)
        if args.bundle_app_name:
            if app_name and app_name != args.bundle_app_name:
                env_name = APP_NAME_ENV if env.get(APP_NAME_ENV) else BUNDLE_VAR_APP_NAME
                raise SettingsError(APP_NAME_MISMATCH.format(deployed=args.bundle_app_name, env=env_name,
                                                             exported=app_name))
            app_name = args.bundle_app_name
        deployed = read_deployed(validate_app_name(app_name), profile) if args.read_deployed and app_name else None
        guard: Callable[[Resolution, Mapping[str, str], Mapping[str, str]], None] | None = None
        if (args.read_deployed or args.fresh_ok) and not args.no_guard:
            guard = functools.partial(shared_resource_check, profile=profile)
        res = resolve(app_name=app_name, flags=flags, env=env, use_env=not args.ignore_env,
                      allow_defaults=args.fresh_ok, install_flags=args.install_flags,
                      database_follows_catalog=args.database_follows_catalog, bundle_target=args.bundle_target,
                      deployed=deployed, check_shared=guard)
        print(format_table(res), file=sys.stderr)
        origin = format_origin(res)
        if origin:
            print(origin, file=sys.stderr)
        if args.confirm:
            confirm(CONFIRM_QUESTION.format(app=app_name), assume_yes=args.yes, no_terminal=NO_TERMINAL_SETTINGS,
                    declined=NOT_CONFIRMED_SETTINGS)
    except (SettingsError, NotConfirmed) as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 2
    if args.shell:
        print(shell_exports(res))
    return 0


if __name__ == "__main__":
    sys.exit(main())

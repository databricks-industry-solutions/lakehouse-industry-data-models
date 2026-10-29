"""Tag the Databricks App with the app identity tags. Warn-only and idempotent.

Run by ``install/install.sh`` after ``apps deploy``:

    python install/tag_app.py [--profile <cli-profile>] --app-name <app>

The tags are the ones every job the app creates carries, from the same module
(``backend/core/_job_tags.py``, loaded by file path): ``managed_by``,
``dbx_vibe_modelling_app`` (the app name) and ``dbx_vibe_modelling_app_version``.
The version is the one the deployed app reports as ``vibe_modeling.__version__``:
the ``_version.py`` the build just wrote (both callers build before they deploy),
else ``[project].version`` of ``src/app/pyproject.toml``. They are operational and
carry no business or person data.

The script lists the app's tags, then creates the missing ones and updates the
ones that differ. When a create fails it reads the tag again and decides from
what it reads. Every failure prints a warning and the script exits 0; only a
usage error exits 2. Writing a tag needs CAN MANAGE on the app, plus ASSIGN on a
governed tag key.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
JOB_TAGS_PATH = REPO_ROOT / "src/app/src/vibe_modeling/backend/core/_job_tags.py"
PYPROJECT_PATH = REPO_ROOT / "src/app/pyproject.toml"
BUILT_VERSION_PATH = REPO_ROOT / "src/app/src/vibe_modeling/_version.py"
_BUILT_VERSION_RE = re.compile(r'^version\s*=\s*"([^"]+)"', re.MULTILINE)

ENTITY_TYPE = "apps"
CLIENT_CONFIG = {"http_timeout_seconds": 30, "retry_timeout_seconds": 20}
ERROR_MAX_CHARS = 300
MANAGE_HINT = "needs CAN MANAGE on the app"
GOVERNED_HINT = "for a governed tag, you also need ASSIGN on it"
SDK_HINT = "databricks-sdk too old for app tags; upgrade to >=0.74"


def _ok(message: str) -> None:
    print(f"    [ok]   {message}")


def _warn(message: str) -> None:
    print(f"    [warn] {message}")


def _reason(exc: BaseException) -> str:
    return (str(exc) or type(exc).__name__)[:ERROR_MAX_CHARS]


def read_version(built: Path | None = None, pyproject: Path | None = None) -> str:
    """The app version: the built ``_version.py`` when present, else ``pyproject.toml``."""
    built = built or BUILT_VERSION_PATH
    if built.is_file():
        m = _BUILT_VERSION_RE.search(built.read_text())
        if m:
            return m.group(1)
    import tomllib  # Python 3.11+; install.sh only warns below that

    with open(pyproject or PYPROJECT_PATH, "rb") as f:
        return tomllib.load(f)["project"]["version"]


def desired_tags(app_name: str, version: str) -> dict[str, str]:
    from _install_common import load_backend_module

    return load_backend_module(JOB_TAGS_PATH).app_identity_tags(app_name, version)


def apply_tags(api, tag_assignment_cls, app_name: str, desired: dict[str, str]) -> int:
    """Converge the app's tags on ``desired``; returns the number of warnings printed."""
    try:
        current = {t.tag_key: t.tag_value for t in api.list_tag_assignments(ENTITY_TYPE, app_name)}
    except Exception as exc:
        _warn(f"could not read the tags of app '{app_name}': {_reason(exc)} ({MANAGE_HINT})")
        return 1

    def assignment(key: str, value: str):
        return tag_assignment_cls(entity_type=ENTITY_TYPE, entity_id=app_name, tag_key=key, tag_value=value)

    def update(key: str, value: str) -> bool:
        try:
            api.update_tag_assignment(ENTITY_TYPE, app_name, key, assignment(key, value), update_mask="tag_value")
        except Exception as exc:
            _warn(f"could not update tag {key}: {_reason(exc)} ({MANAGE_HINT}; {GOVERNED_HINT})")
            return False
        _ok(f"{key}={value} (updated)")
        return True

    warnings = 0
    for key, value in desired.items():
        if key in current:
            if current[key] == value:
                _ok(f"{key}={value} (unchanged)")
            elif not update(key, value):
                warnings += 1
            continue
        try:
            api.create_tag_assignment(assignment(key, value))
        except Exception as create_exc:
            try:
                now = api.get_tag_assignment(ENTITY_TYPE, app_name, key).tag_value
            except Exception:
                _warn(f"could not create tag {key}: {_reason(create_exc)} ({MANAGE_HINT}; {GOVERNED_HINT})")
                warnings += 1
                continue
            if now == value:
                _ok(f"{key}={value} (unchanged)")
            elif not update(key, value):
                warnings += 1
            continue
        _ok(f"{key}={value} (created)")
    return warnings


def _parse_args(argv: list[str]) -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Tag the Databricks App with the app identity tags (warn-only).")
    p.add_argument("--profile", default="", help="Databricks CLI profile (omit for the SDK's default auth)")
    p.add_argument("--app-name", required=True, help="Databricks App resource name")
    return p.parse_args(argv)


def main(argv: list[str] | None = None, *, client_factory=None) -> int:
    args = _parse_args(argv if argv is not None else sys.argv[1:])
    try:
        desired = desired_tags(args.app_name, read_version())
    except Exception as exc:
        _warn(f"could not work out the app tags: {_reason(exc)}")
        return 0
    try:
        if client_factory is None:
            from _install_common import workspace_client as client_factory
        w = client_factory(args.profile or None, **CLIENT_CONFIG)
    except Exception as exc:
        _warn(f"could not build a workspace client: {_reason(exc)}")
        return 0
    api = getattr(w, "workspace_entity_tag_assignments", None)
    if api is None:
        _warn(SDK_HINT)
        return 0
    try:
        from databricks.sdk.service.tags import TagAssignment
    except ImportError:
        _warn(SDK_HINT)
        return 0
    warnings = apply_tags(api, TagAssignment, args.app_name, desired)
    if warnings:
        _warn(f"{warnings} app tag(s) not written; the install continues")
    return 0


if __name__ == "__main__":
    sys.exit(main())

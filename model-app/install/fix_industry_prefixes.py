"""Give industries downloaded before 0.9.0 the scope prefixes a 0.9.0 download adds.

Run it once after upgrading an app from 0.8.x, first without ``--apply``::

    python install/fix_industry_prefixes.py --profile <p> --app-name <app> --all
    python install/fix_industry_prefixes.py --profile <p> --app-name <app> --industry Agriculture --apply

It calls the app's ``POST /api/industries/<id>/scope-prefixes`` for each
industry (the caller must be an app Admin) and prints one row per version:
``changed`` (with ``--apply``; without it, would change), ``unchanged``,
``skipped`` or ``failed`` (a rerun finishes it) with the reason. It renames no schema, table or metric view in
Unity Catalog; it rewrites the app's copies of the model files and the app's
registry rows, and skips every installed version.

The token comes from ``databricks auth token --profile <p>``; the app URL from
``_install_common.find_app``. Exit codes: 0 done, nothing skipped; 2 done, a
version was skipped; 1 an error (no token, no app, a refused or failed
request, a version that failed); 3 a usage error. Stdlib only.
"""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
import urllib.error
import urllib.parse
import urllib.request
from typing import Any, Callable

from _install_common import AppLookupError, find_app

EXIT_OK, EXIT_ERROR, EXIT_SKIPPED, EXIT_USAGE = 0, 1, 2, 3

# The apply rewrites files and waits on the SQL warehouse for the registry
# rows (up to 90 s per version, plus the deletes), so it gets a long budget.
LIST_TIMEOUT_S = 60
FIX_TIMEOUT_S = 900
CLI_TIMEOUT_S = 120


class FixError(RuntimeError):
    """A step failed; the message says which and why."""


class _Parser(argparse.ArgumentParser):
    def error(self, message: str) -> None:  # type: ignore[override]
        self.print_usage(sys.stderr)
        print(f"{self.prog}: error: {message}", file=sys.stderr)
        raise SystemExit(EXIT_USAGE)


def parse_args(argv: list[str]) -> argparse.Namespace:
    p = _Parser(prog="fix_industry_prefixes.py", description=(__doc__ or "").split("\n\n")[0])
    p.add_argument("--profile", default="", help="Databricks CLI profile of the app's workspace")
    p.add_argument("--app-name", required=True, help="The Databricks App to fix")
    which = p.add_mutually_exclusive_group(required=True)
    which.add_argument("--industry", help="One industry, by name (any case) or id")
    which.add_argument("--all", action="store_true", help="Every industry in the app")
    p.add_argument("--apply", action="store_true", help="Make the changes (default: report only)")
    return p.parse_args(argv)


def get_token(profile: str, run: Callable[..., Any] = subprocess.run) -> str:
    """An access token from ``databricks auth token``."""
    cmd = ["databricks", "auth", "token", "--output", "json", *(["--profile", profile] if profile else [])]
    try:
        proc = run(cmd, capture_output=True, text=True, timeout=CLI_TIMEOUT_S)
    except (OSError, subprocess.TimeoutExpired) as exc:
        raise FixError(f"databricks auth token could not run: {exc}") from None
    try:
        token = json.loads(proc.stdout or "").get("access_token") if proc.returncode == 0 else None
    except (ValueError, AttributeError):
        token = None
    if not token:
        where = f"profile {profile}" if profile else "the default profile"
        raise FixError(f"no token for {where}; run databricks auth login first")
    return str(token)


def get_app_url(app_name: str, profile: str, run: Callable[..., Any] = subprocess.run) -> str:
    """The app's URL, from ``_install_common.find_app``."""
    try:
        app = find_app(app_name, profile, run)
    except AppLookupError as exc:
        raise FixError(str(exc)) from None
    if app is None:
        raise FixError(f"there is no app called {app_name}")
    url = str(app.get("url") or "").rstrip("/")
    if not url:
        raise FixError(f"app {app_name} has no URL yet; start it first")
    return url if "://" in url else f"https://{url}"


class AppApi:
    """The two app calls, with a bearer token; ``opener`` is ``urlopen`` (a seam for tests)."""

    def __init__(self, base_url: str, token: str, opener: Callable[..., Any] = urllib.request.urlopen):
        self.base_url, self.token, self.opener = base_url, token, opener

    def _call(self, method: str, path: str, body: Any, timeout: int) -> Any:
        data = None if body is None else json.dumps(body).encode("utf-8")
        req = urllib.request.Request(
            f"{self.base_url}{path}", data=data, method=method,
            headers={"Authorization": f"Bearer {self.token}", "Content-Type": "application/json"},
        )
        try:
            with self.opener(req, timeout=timeout) as resp:
                return json.loads(resp.read() or b"null")
        except urllib.error.HTTPError as exc:
            raise FixError(f"{method} {path} answered {exc.code}: {_detail(exc)}") from None
        except (urllib.error.URLError, OSError, ValueError) as exc:
            raise FixError(f"{method} {path} failed: {exc}") from None

    def industries(self) -> list[dict[str, Any]]:
        rows = self._call("GET", "/api/businesses?kind=industry", None, LIST_TIMEOUT_S)
        if not isinstance(rows, list):
            raise FixError("the app's industry list is not a list")
        return [r for r in rows if isinstance(r, dict)]

    def fix(self, business_id: str, apply: bool) -> dict[str, Any]:
        path = f"/api/industries/{urllib.parse.quote(business_id, safe='')}/scope-prefixes"
        out = self._call("POST", path, {"apply": apply}, FIX_TIMEOUT_S)
        if not isinstance(out, dict):
            raise FixError(f"POST {path} did not answer an object")
        return out


def _detail(exc: urllib.error.HTTPError) -> str:
    try:
        body = json.loads(exc.read() or b"null")
    except (ValueError, OSError):
        return exc.reason or "no detail"
    detail = body.get("detail") if isinstance(body, dict) else body
    if isinstance(detail, dict):
        detail = detail.get("message") or detail
    return str(detail)


def select_industries(industries: list[dict[str, Any]], wanted: str | None) -> list[dict[str, Any]]:
    """Every industry, or the one whose id or name (any case) is ``wanted``."""
    if wanted is None:
        return industries
    by_id = [i for i in industries if i.get("id") == wanted]
    match = by_id or [i for i in industries if str(i.get("name") or "").lower() == wanted.lower()]
    if not match:
        names = ", ".join(sorted(str(i.get("name")) for i in industries)) or "none"
        raise FixError(f"no industry called {wanted} (industries: {names})")
    if len(match) > 1:
        raise FixError(f"{len(match)} industries are called {wanted}; pass its id")
    return match


def print_result(result: dict[str, Any], out: Any = None) -> set[str]:
    """Print one industry's rows (to ``out``, default stdout); the actions seen."""
    out = out or sys.stdout
    print(f"{result.get('business_name')} ({result.get('business_id')})", file=out)
    actions: set[str] = set()
    for row in result.get("rows") or []:
        action = str(row.get("action"))
        actions.add(action)
        label = f"v{row.get('version')} {str(row.get('scope') or '').upper()}"
        print(f"  {label:<8} {action:<10} {row.get('reason') or ''}", file=out)
        for warning in row.get("warnings") or []:
            print(f"  {'':<8} {'':<10} warning: {warning}", file=out)
    if not result.get("rows"):
        print("  no versions", file=out)
    return actions


def main(
    argv: list[str],
    *,
    run: Callable[..., Any] = subprocess.run,
    opener: Callable[..., Any] = urllib.request.urlopen,
) -> int:
    args = parse_args(argv)
    try:
        api = AppApi(get_app_url(args.app_name, args.profile, run), get_token(args.profile, run), opener)
        targets = select_industries(api.industries(), None if args.all else args.industry)
    except FixError as exc:
        print(f"error: {exc}", file=sys.stderr)
        return EXIT_ERROR
    if not targets:
        print("The app has no industries; nothing to fix.")
        return EXIT_OK
    failed = skipped = False
    for industry in targets:
        try:
            actions = print_result(api.fix(str(industry.get("id")), args.apply))
            failed = failed or "failed" in actions
            skipped = skipped or "skipped" in actions
        except FixError as exc:
            failed = True
            print(f"{industry.get('name')} ({industry.get('id')})\n  error: {exc}", file=sys.stderr)
    if not args.apply:
        print("Dry run: nothing was changed. Run again with --apply to make the changes.")
    if failed:
        return EXIT_ERROR
    return EXIT_SKIPPED if skipped else EXIT_OK


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

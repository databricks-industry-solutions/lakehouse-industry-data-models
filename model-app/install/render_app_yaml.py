"""Substitute install-time values into ``src/app/app.yml`` env vars.

Driven by ``install/install.sh`` so a single CLI invocation produces an
``app.yml`` whose env block matches what was provisioned in Lakebase. The
matched env names are exactly the ones the app reads via
``DatabaseConfig`` and ``AppConfig`` (see ``backend/core/lakebase.py`` and
``backend/core/_config.py``):

  - ``VIBE_MODELING_LAKEBASE_PROJECT``    (Lakebase project id)
  - ``VIBE_MODELING_DATABASE_NAME``       (Postgres database name)
  - ``VIBE_MODELING_DEPLOYMENT_CATALOG``  (UC catalog seeded into AgentConfig)
  - ``VIBE_MODELING_WAREHOUSE_ID``        (SQL warehouse id, optional)
  - ``VIBE_MODELING_TAXONOMY_BUILDER_ENABLED`` (``true``/``false``; Domain
    Taxonomy Builder install flag, default ``false``)
  - ``VIBE_MODELING_TAXONOMY_MODEL_SERVICE``   (UC model service full name
    seeded into AgentConfig, optional)
  - ``VIBE_MODELING_ASSESSMENT_ENABLED``  (``true``/``false``; bronze
    assessment skill install flag, default ``false``)
  - ``VIBE_MODELING_ASSESS_READER_SP``    (reader service principal
    application id seeded into AssessConfig, optional)
  - ``VIBE_MODELING_RUN_TAGS_DEFAULT``    (``true``/``false``; seed of
    Settings -> Agent -> "Annotate jobs with run tags", default ``true``;
    ``install.sh --no-run-tags`` renders ``false``)

The render is line-oriented (no full YAML parser): for each known env
``name`` we rewrite the next ``value:`` line. Unrelated content — comments,
ordering, the ``command`` block, other env entries — is preserved verbatim.
Idempotent: re-running with the same inputs produces the same output.

With ``--bundle-scopes-out`` the same ``--assessment`` value also renders the
bundle fragment that ``databricks.yml`` includes (``install/.generated/*.yml``):
with the assessment on, a per-target override that sets the App's
``user_api_scopes: [workspace.workspace]`` (the hand-off writes into the user's
home with the user's own token); with it off, the file is deleted, so the App
declares no ``user_api_scopes`` at all (the same state as a fresh clone). An
empty list is never emitted, and a redeploy that turns the assessment off
removes an earlier "on" fragment.

``--bundle-hook`` marks the call from ``databricks.yml``'s build hook. The CLI
has already loaded the include by then, so if the fragment this render produces
differs from the one that was there (including absent vs present), the deploy
in progress carries the old scopes: the render keeps the new fragment and
exits 3 asking for a re-run. ``install.sh`` and the other deploy scripts render
before ``bundle deploy``, so they never trip it.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

# Targets we know how to rewrite. Order is irrelevant; the rewriter
# matches each independently.
ENV_TARGETS = (
    "VIBE_MODELING_LAKEBASE_PROJECT",
    "VIBE_MODELING_DATABASE_NAME",
    "VIBE_MODELING_DEPLOYMENT_CATALOG",
    "VIBE_MODELING_WAREHOUSE_ID",
    "VIBE_MODELING_TAXONOMY_BUILDER_ENABLED",
    "VIBE_MODELING_TAXONOMY_MODEL_SERVICE",
    "VIBE_MODELING_ASSESSMENT_ENABLED",
    "VIBE_MODELING_ASSESS_READER_SP",
    "VIBE_MODELING_RUN_TAGS_DEFAULT",
)

# The bundle targets in ``databricks.yml`` (a test keeps this in step), and the
# user scope the in-app assessment's hand-off needs.
BUNDLE_TARGETS = ("dev", "github-publish")
ASSESSMENT_USER_API_SCOPES = ("workspace.workspace",)
APP_RESOURCE_KEY = "vibe-modeling-app"
SCOPES_CHANGED_EXIT = 3
SCOPES_CHANGED_MESSAGE = ("The app's user API scopes changed (assessment on/off); "
                          "re-run the deploy so the bundle picks them up.")


# Line patterns we look for. We match the canonical apx app.yml shape:
#
#   - name: VIBE_MODELING_LAKEBASE_PROJECT
#     value: "vibe-modeling"
#
# both the bullet form and inline form. The value line must immediately
# follow the name line (with optional blank/comment lines between).
_NAME_RE = re.compile(r'^(\s*-?\s*name:\s*)(\S+)\s*$')
_VALUE_RE = re.compile(r'^(\s*value:\s*)(.*)$')


def yaml_quote(value: str) -> str:
    """``value`` as a YAML double-quoted scalar. JSON string syntax is a subset
    of YAML's double-quoted style, so ``"`` and ``\\`` come out escaped."""
    return json.dumps(value)


def render(source: str, values: dict[str, str]) -> str:
    """Return ``source`` with the value of each env var in ``values`` rewritten."""
    lines = source.splitlines(keepends=True)
    out: list[str] = []
    pending_target: str | None = None
    for line in lines:
        if pending_target is not None:
            value_match = _VALUE_RE.match(line.rstrip("\n").rstrip("\r"))
            if value_match:
                indent = value_match.group(1)
                eol = line[len(line.rstrip("\r\n")):]  # preserve \n / \r\n
                out.append(f"{indent}{yaml_quote(values[pending_target])}{eol}")
                pending_target = None
                continue
            # Anything that isn't a `value:` line clears the pending state
            # so we don't mis-attribute a later value: line. The original
            # line passes through unchanged.
            pending_target = None

        name_match = _NAME_RE.match(line.rstrip("\n").rstrip("\r"))
        if name_match and name_match.group(2) in values:
            pending_target = name_match.group(2)
        out.append(line)

    return "".join(out)


def _scalar(raw: str) -> str | None:
    """A ``value:`` scalar as text: double-quoted (JSON string syntax, what ``render`` writes), single-quoted
    (``''`` is a quote) or bare, with a trailing ``# comment`` dropped; None for no value at all (``""`` is
    an empty text) or one this reader does not understand."""
    raw = raw.strip()
    if raw.startswith('"'):
        try:
            value, end = json.JSONDecoder().raw_decode(raw)
        except ValueError:
            return None
        rest = raw[end:].strip()
        return value if isinstance(value, str) and (not rest or rest.startswith("#")) else None
    if raw.startswith("'"):
        m = re.match(r"'((?:[^']|'')*)'\s*(#.*)?$", raw)
        return m.group(1).replace("''", "'") if m else None
    value = re.split(r"\s+#", raw, maxsplit=1)[0].strip()
    return value or None


def read_env(text: str) -> dict[str, str]:
    """The value each ``ENV_TARGETS`` entry of an ``app.yml`` sets, the inverse of ``render``: the line after
    the ``name:`` line must be its ``value:``. An entry set by ``valueFrom``, with no value, or not in the file is
    absent; other env entries are never read."""
    out: dict[str, str] = {}
    pending: str | None = None
    for raw in text.splitlines():
        line = raw.rstrip("\r")
        if pending is not None:
            value_match = _VALUE_RE.match(line)
            target, pending = pending, None
            if value_match:
                value = _scalar(value_match.group(2))
                if value is not None:
                    out[target] = value
                continue
        name_match = _NAME_RE.match(line)
        if name_match and name_match.group(2) in ENV_TARGETS:
            pending = name_match.group(2)
    return out


def render_bundle_scopes(assessment: bool) -> str | None:
    """The ``databricks.yml`` include fragment for the App's ``user_api_scopes``, or None when off.

    A target override per bundle target when ``assessment`` is on (an included
    file can't re-declare the App resource itself: the CLI rejects a second
    definition of the same resource key).
    """
    if not assessment:
        return None
    lines = ["# Generated by install/render_app_yaml.py (--bundle-scopes-out); do not edit.\n", "targets:\n"]
    for target in BUNDLE_TARGETS:
        lines += [f"  {target}:\n", "    resources:\n", "      apps:\n", f"        {APP_RESOURCE_KEY}:\n",
                  "          user_api_scopes:\n"]
        lines += [f"            - {scope}\n" for scope in ASSESSMENT_USER_API_SCOPES]
    return "".join(lines)


def write_bundle_scopes(path: Path, assessment: bool) -> bool:
    """Write (on) or delete (off) the fragment at ``path``; True when it changed, incl. absent vs present."""
    before = path.read_text() if path.exists() else None
    after = render_bundle_scopes(assessment)
    if after is None:
        path.unlink(missing_ok=True)
    else:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(after)
    return before != after


def _parse_args(argv: list[str]) -> argparse.Namespace:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--in", dest="input", required=True, help="Path to source app.yml")
    p.add_argument("--out", dest="output", required=True, help="Path to write rendered app.yml")
    p.add_argument("--project", required=True, help="Lakebase project id")
    p.add_argument("--database", required=True, help="Postgres database name")
    p.add_argument(
        "--deployment-catalog",
        required=True,
        help="UC catalog the agent uses for _metamodel; seeds AgentConfig on first boot",
    )
    p.add_argument(
        "--warehouse-id",
        default="",
        help="SQL warehouse id (optional; empty leaves the user to configure via UI)",
    )
    p.add_argument(
        "--taxonomy-builder",
        choices=("true", "false"),
        default="false",
        help="Install the Domain Taxonomy Builder (default: false)",
    )
    p.add_argument(
        "--taxonomy-model-service",
        default="",
        help="UC model service full name seeded into AgentConfig (optional)",
    )
    p.add_argument(
        "--assessment",
        choices=("true", "false"),
        default="false",
        help="Install the bronze assessment skill (default: false)",
    )
    p.add_argument(
        "--assess-reader-sp",
        default="",
        help="Reader service principal application id (a UUID, not the display name) seeded into AssessConfig (optional)",
    )
    p.add_argument(
        "--run-tags",
        choices=("true", "false"),
        default="true",
        help="Initial value of Settings -> Agent -> 'Annotate jobs with run tags' (default: true)",
    )
    p.add_argument(
        "--bundle-scopes-out",
        default="",
        help="Also write (assessment on) or delete (off) the databricks.yml include fragment for the App's "
             "user_api_scopes",
    )
    p.add_argument(
        "--bundle-hook",
        action="store_true",
        help="Called from the bundle's build hook: exit 3 when the scopes fragment changed (re-run the deploy)",
    )
    return p.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = _parse_args(argv if argv is not None else sys.argv[1:])
    source = Path(args.input).read_text()
    values = {
        "VIBE_MODELING_LAKEBASE_PROJECT": args.project,
        "VIBE_MODELING_DATABASE_NAME": args.database,
        "VIBE_MODELING_DEPLOYMENT_CATALOG": args.deployment_catalog,
        "VIBE_MODELING_WAREHOUSE_ID": args.warehouse_id,
        "VIBE_MODELING_TAXONOMY_BUILDER_ENABLED": args.taxonomy_builder,
        "VIBE_MODELING_TAXONOMY_MODEL_SERVICE": args.taxonomy_model_service,
        "VIBE_MODELING_ASSESSMENT_ENABLED": args.assessment,
        "VIBE_MODELING_ASSESS_READER_SP": args.assess_reader_sp,
        "VIBE_MODELING_RUN_TAGS_DEFAULT": args.run_tags,
    }
    rendered = render(source, values)

    rewritten_targets = [k for k in ENV_TARGETS if f"name: {k}" in source]
    missing = [k for k in rewritten_targets if f"value: {yaml_quote(values[k])}" not in rendered]
    if missing:
        print(
            f"ERROR: render_app_yaml could not rewrite {missing} — "
            f"app.yml shape changed?",
            file=sys.stderr,
        )
        return 1

    Path(args.output).write_text(rendered)
    if args.bundle_scopes_out:
        changed = write_bundle_scopes(Path(args.bundle_scopes_out), args.assessment == "true")
        if changed and args.bundle_hook:
            print(f"ERROR: {SCOPES_CHANGED_MESSAGE}", file=sys.stderr)
            return SCOPES_CHANGED_EXIT
    return 0


if __name__ == "__main__":
    sys.exit(main())

"""Agent release-tag compatibility matrix for the import-from-volume path.

The app pins a single supported agent tag (`SUPPORTED_AGENT_VERSION`), but the
auditor at `compat_matrix.json` surveyed a range of
adjacent tags and produced a verdict per tag. This module encodes that
verdict map as data so the import endpoints can reject imports from tags we
have not vetted and route `needs-adapter` tags through a (future) shim
layer.

All three verdict branches (`compatible`, `needs-adapter`, `breaking`) are
implemented even though today's matrix only contains `compatible` entries;
the shape of the API must not change when the next agent release classifies
differently.

This module also carries a forward-looking **known-upstream-changes** table
(`KNOWN_UPSTREAM_CHANGES`, newest at top) so the release-monitor CI job and
the `/api/config/agent-compat` endpoint can render human-readable compat
summaries for tags the app has not yet adopted. Entries here do NOT imply
the tag is vetted for import — they are pre-populated by whoever surveyed
the upstream diff. Treat them as metadata that feeds the monitor UI.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Literal


Verdict = Literal["compatible", "needs-adapter", "breaking", "unknown"]

Severity = Literal["breaking", "info"]


_COMPAT_MATRIX: dict[str, Verdict] = {
    "v0.5.2": "compatible",
    "v0.5.3": "compatible",
    "v0.5.4": "compatible",
    "v0.5.5": "compatible",
    "v0.5.6": "compatible",
    "v0.5.7": "compatible",
    "v0.5.8": "compatible",
    # v0.5.9 introduced the {scope}_v{N} Volume folder rename. Marked
    # compatible in this release since the app's volume-path readers
    # are updated alongside the v0.7.1 pin (the rename has been the
    # stable layout since the v0.6.0 series).
    "v0.5.9": "compatible",
    "v0.5.10": "compatible",
    # v0.6.1 - v0.6.9 are root-cause-fix patch releases on top of v0.6.0
    # (each "v0.6.N: 3 root-cause fixes from <previous> audit"). Per
    # audit_report.md the
    # integration contract is unchanged across the series. v0.6.0 itself
    # is intentionally absent — its no-marker notebook + SHRINK-NEW-SILO
    # no-retry behaviour are superseded by v0.7.1's auto-recovery path.
    "v0.6.1": "compatible",
    "v0.6.2": "compatible",
    "v0.6.3": "compatible",
    "v0.6.4": "compatible",
    "v0.6.5": "compatible",
    "v0.6.6": "compatible",
    "v0.6.7": "compatible",
    "v0.6.8": "compatible",
    # v0.6.9 added an `agent_version` first-key marker to model.json — the
    # app's `detect_tag_from_model_json` already probes that key so the
    # change is backwards-compatible.
    "v0.6.9": "compatible",
    # v0.7.0 added a new "Architect Review" stage with Step 3.6 / 3.7
    # sub-events plus a `domain_architect_review` block in
    # `Creating Data Products` `result_json`. Both are append-only — the
    # app persists events verbatim and tolerates unknown result_json keys.
    "v0.7.0": "compatible",
    # v0.7.1 is the consolidated 14-fix release that resolves
    # SHRINK-NEW-SILO via deterministic auto-recovery
    # (`shrink-fk-densest-fallback` + `shrink-cascade-iterate` +
    # `shrink-orphan-drop`) and adds `session-end-status-honest` so
    # error paths report `stage_failed` instead of the v0.7.0 hardcoded
    # `stage_ended`. App's compat shim around hardcoded `stage_ended`
    # remains for back-compat with older Lakebase rows.
    "v0.7.1": "compatible",
    # v0.7.2 ships `agent_version: 0.7.2` model.json outputs that have
    # already appeared in the wild (vibe-business-data-models repo:
    # energy_utilities/, education/, legal/, mining/, ngo/). The upstream
    # tag isn't published yet — the maintainer is iterating in untagged
    # commits — but a structural diff across 3 v0.7.1 + 5 v0.7.2 samples
    # found 0 differences across 27 JSON path slots (same envelope,
    # same model.*/domains[]/products[]/attributes[] keys). The commit
    # messages between v0.7.1 and v0.7.2 describe agent-behaviour fixes
    # ("strict-VOV-authority overhaul", "user-vibe-authority-hardening"),
    # not schema changes. Promoting as compatible so imports succeed.
    "v0.7.2": "compatible",
    # v0.7.3–v0.7.7: the strict-VOV / USER-AUTHORITY hardening line
    # (healthcare-audit root-cause fixes, 15h job timeout, vreq-revalidate
    # retry). All agent-behaviour changes — the integration surface (widgets,
    # progress/Delta events, model.json envelope + model.*/domains[]/products[]/
    # attributes[] layout) is unchanged. Promoted as compatible so imports of
    # v0.7.x model.json succeed; v0.7.7 is the bundled pin. Revert to v0.7.1 if
    # a v0.7.7 run misbehaves.
    "v0.7.3": "compatible",
    "v0.7.4": "compatible",
    "v0.7.5": "compatible",
    "v0.7.6": "compatible",
    "v0.7.7": "compatible",
    # v0.8.0 decoupled the version fields: `agent_version` became an
    # independent agent-logic counter (`4.x.y`, e.g. 4.3.2) and the git
    # release tag moved to a new top-level `release_version` ("0.8.0").
    # `detect_tag_from_model_json` reads `release_version` first so these
    # models classify as v0.8.0, not the bogus "v4.3.2". Accepted as
    # compatible by the maintainer 2026-08-24; the model.json
    # envelope (model.*/domains[]/products[]/attributes[]) is unchanged.
    "v0.8.0": "compatible",
}

SUPPORTED_TAGS: frozenset[str] = frozenset(_COMPAT_MATRIX.keys())

_LATEST_SUPPORTED_TAG = "v0.8.0"


# Newest-first. Each entry describes what changed in an upstream tag versus
# the previously pinned release, from the app's integration perspective. The
# monitor surfaces `breaking` changes as action-required; `info` entries are
# annotations only. Keep entries short and link-free so they render cleanly
# in both the GitHub-issue body and the Settings card.
KNOWN_UPSTREAM_CHANGES: dict[str, list[dict[str, str]]] = {
    "v0.8.0": [
        {
            "severity": "info",
            "area": "volume-layout",
            "summary": (
                "model.json now sits at the top level of `v{N}/{scope}/`; "
                "the app reads there first and falls back to the flat "
                "`{scope}_v{N}` layout for pre-upgrade rows, so both resolve."
            ),
        },
        {
            "severity": "info",
            "area": "version-fields",
            "summary": (
                "`agent_version` and `release_version` split: "
                "`agent_version` is now an independent agent-logic counter "
                "(`4.x.y`) and `release_version` carries the git tag "
                "(\"0.8.0\"). `detect_tag_from_model_json` reads "
                "`release_version` first."
            ),
        },
        {
            "severity": "info",
            "area": "run-resilience",
            "summary": (
                "Blocker-A empty-tasks guard: the agent no longer aborts a "
                "run when a stage yields an empty task list, avoiding the "
                "hard failure the app previously surfaced as a stage error."
            ),
        },
    ],
    "v0.7.2": [
        {
            "severity": "info",
            "area": "model_json",
            "summary": (
                "Structural diff vs v0.7.1: 0 changes across 27 path slots "
                "(envelope, model.*/domains[]/products[]/attributes[]). "
                "Agent-behaviour patches only (strict-VOV-authority "
                "overhaul, user-vibe-authority-hardening per upstream "
                "commit messages). Schema-identical with v0.7.1."
            ),
        },
        {
            "severity": "info",
            "area": "release-status",
            "summary": (
                "No upstream tag yet — maintainer iterating in untagged "
                "commits. Promoted on the strength of the structural diff "
                "across 8 in-the-wild samples (energy_utilities, "
                "education, legal, mining, ngo)."
            ),
        },
    ],
    "v0.7.1": [
        {
            "severity": "info",
            "area": "shrink-resilience",
            "summary": (
                "`shrink-fk-densest-fallback` + `shrink-cascade-iterate` + "
                "`shrink-orphan-drop` replace the v0.7.0 ValueError raise "
                "on SHRINK-NEW-SILO with deterministic auto-recovery. The "
                "'validator will retry the LLM' lying message is removed."
            ),
        },
        {
            "severity": "info",
            "area": "session-end-status",
            "summary": (
                "`session-end-status-honest` — `_finalize_common("
                "end_status=\"stage_failed\")` on the error path. App's "
                "compat shim around hardcoded `stage_ended` is no longer "
                "required for new runs but kept for back-compat with "
                "older Lakebase rows."
            ),
        },
        {
            "severity": "info",
            "area": "install-resilience",
            "summary": (
                "`install-ddl-retry-skip` — recoverable error classes "
                "(`TABLE_OR_VIEW_ALREADY_EXISTS`, `DELTA_CONCURRENT_*`, "
                "`503/504`) get backoff + retry instead of halting "
                "install. Reduces App-side rollback dispatches."
            ),
        },
        {
            "severity": "info",
            "area": "metric-views",
            "summary": (
                "`mv-stale-catalog-rewrite` rewrites stale catalog refs "
                "in MV YAML; `mv-date-interval-autofix` rewrites "
                "`(date1 - date2)` -> `DATEDIFF(...)`; "
                "`mv-prevalidate-keywords-extend` adds ~80 SQL keywords. "
                "Agent-internal — App persists verbatim."
            ),
        },
        {
            "severity": "info",
            "area": "next-vibes",
            "summary": (
                "New auto-recovery flag entries appear in "
                "`next_vibes.txt`: `SHRINK_ORPHAN_DROPPED`, "
                "`SHRINK_FK_DENSEST_FALLBACK_USED`, "
                "`SHRINK_CASCADE_AUTO_RECOVERED`, "
                "`ENSEMBLE_SINGLESHOT_FALLBACK_USED`. The App's sync-time "
                "next-vibes parser does NOT surface these tokens; only "
                "static-analysis / PRIORITY / other-known-issue findings "
                "become structured inputs."
            ),
        },
        {
            "severity": "info",
            "area": "prompt-mutation",
            "summary": (
                "`vibe-attr-cap-override` — agent now mutates "
                "`PROMPT_VARIABLES.{min,max}_attributes_per_product` "
                "server-side when vibe text matches "
                "'between N and M attributes per product'. "
                "App-invisible but worth knowing."
            ),
        },
    ],
    "v0.7.0": [
        {
            "severity": "info",
            "area": "stages",
            "summary": (
                "New 'Architect Review' stage with Step 3.6 (per-domain, "
                "parallel) and Step 3.7 (global) sub-events. App persists "
                "events verbatim — no parsing change required."
            ),
        },
        {
            "severity": "info",
            "area": "result_json",
            "summary": (
                "New `domain_architect_review` block in 'Creating Data "
                "Products' stage_succeeded result_json (alongside existing "
                "`architect_review_changes`). Append-only."
            ),
        },
        {
            "severity": "info",
            "area": "model_json",
            "summary": (
                "From v0.6.9: `agent_version` is now the first top-level "
                "key of every model.json. App's "
                "`detect_tag_from_model_json` already probes this key — "
                "backwards-compatible."
            ),
        },
    ],
    "v0.6.9": [
        {
            "severity": "info",
            "area": "model_json",
            "summary": (
                "Adds `agent_version` first-key marker to model.json + "
                "global `__AGENT_VERSION__` traceability. Backwards-compat."
            ),
        },
    ],
    "v0.5.10": [
        {
            "severity": "info",
            "area": "runner",
            "summary": (
                "Runner hotfix that matches the v0.5.9 folder-path format. "
                "Carries the v0.5.9 scope-prefixed folder layout. No new "
                "contract surface."
            ),
        },
    ],
    "v0.5.9": [
        {
            "severity": "breaking",
            "area": "volume-layout",
            "summary": (
                "Volume folder naming flipped from 'v{N}_{scope}' to "
                "'{scope}_v{N}'. The app's model_sync.py and router.py read "
                "the old format at three hardcoded sites and will 404 on "
                "model.json lookups until the paths are updated."
            ),
        },
        {
            "severity": "info",
            "area": "install-check",
            "summary": (
                "New install integrity check runs inside the agent. "
                "App-agnostic."
            ),
        },
    ],
}


def known_changes_for_tag(tag: str) -> list[dict[str, str]]:
    """Return the known-upstream-changes entries for a tag (may be empty)."""
    normal = _normalise(tag)
    if not normal:
        return []
    return list(KNOWN_UPSTREAM_CHANGES.get(normal, []))


def has_breaking_change(tag: str) -> bool:
    """True if any known-change entry for this tag is marked `breaking`."""
    return any(e.get("severity") == "breaking" for e in known_changes_for_tag(tag))


# Latest upstream tag we have metadata about. Populated by the release
# monitor CI job (or hand-updated when research lands ahead of CI). Distinct
# from `_LATEST_SUPPORTED_TAG` — the latter is what the app is vetted to
# import; this one is what upstream has shipped.
LATEST_KNOWN_UPSTREAM_TAG = "v0.8.0"


def _normalise(tag: str) -> str:
    t = (tag or "").strip()
    if not t:
        return ""
    if not t.startswith("v") and t[:1].isdigit():
        t = f"v{t}"
    return t


def classify_tag(tag: str) -> Verdict:
    """Return the compatibility verdict for an agent release tag.

    An empty or unrecognised tag returns ``"unknown"`` so the caller can
    surface a precise error message rather than silently accepting.
    """
    normal = _normalise(tag)
    if not normal:
        return "unknown"
    return _COMPAT_MATRIX.get(normal, "unknown")


def latest_supported_tag() -> str:
    """Return the tag the app recommends pinning."""
    return _LATEST_SUPPORTED_TAG


def latest_known_upstream_tag() -> str:
    """Return the newest upstream tag the app has metadata about.

    Distinct from :func:`latest_supported_tag` — that one is the vetted-for-
    import tag, this one is whatever the release monitor last saw on the
    upstream repo. Used by the health surface so operators can tell the app
    is behind upstream even before the next supported tag is promoted.
    """
    return LATEST_KNOWN_UPSTREAM_TAG


def _tag_sort_key(tag: str) -> tuple[int, ...]:
    """Parse a 'vMAJOR.MINOR[.PATCH]' tag into a comparable tuple.

    Returns `(0,)` for unparseable input so malformed entries sort before
    anything semver-ish and do not crash the comparison.
    """
    normal = _normalise(tag).lstrip("v")
    if not normal:
        return (0,)
    parts: list[int] = []
    for chunk in normal.split("."):
        try:
            parts.append(int(chunk))
        except ValueError:
            # Stop at first non-integer chunk; treat remaining components
            # as zero so e.g. 'v0.5.9-rc1' sorts stably alongside 'v0.5.9'.
            break
    return tuple(parts) if parts else (0,)


def is_newer_tag(candidate: str, baseline: str) -> bool:
    """True iff `candidate` sorts strictly after `baseline` by semver order."""
    return _tag_sort_key(candidate) > _tag_sort_key(baseline)


def describe_incompatibility(tag: str, verdict: Verdict) -> str:
    """Build a user-facing message for a rejected import."""
    normal = _normalise(tag) or "(missing)"
    latest = latest_supported_tag()
    if verdict == "breaking":
        return (
            f"Agent tag {normal!r} introduces a breaking change against the "
            f"contract the app targets. Re-run the notebook pinned to "
            f"{latest!r} (see the Config page for the current supported tag) "
            f"and re-import the resulting model.json."
        )
    if verdict == "unknown":
        return (
            f"Agent tag {normal!r} is not in the compatibility matrix. "
            f"Supported tags: {sorted(SUPPORTED_TAGS)}. Re-run the notebook "
            f"pinned to {latest!r} and re-import the resulting model.json."
        )
    return (
        f"Agent tag {normal!r} verdict={verdict!r}. Latest supported: {latest!r}."
    )


def detect_tag_from_model_json(model_json: dict, fallback: str | None = None) -> str:
    """Probe a model.json for the agent's git release tag.

    From v0.8.0 the agent stamps the git release tag in ``release_version``
    ("0.8.0"), decoupled from ``agent_version`` — which became an independent
    agent-logic counter (``4.x.y``, e.g. ``4.3.2``) and is NO LONGER the
    release identifier. So ``release_version`` is probed FIRST. For
    v0.6.9–v0.7.x exports (which predate ``release_version`` and stamped
    ``agent_version`` == the release semver) the ``agent_version`` probes
    still apply. Falls back to the provided pinned ``fallback`` if it is in
    the supported set; otherwise returns ``""`` so the caller routes through
    the classification branches rather than silently accepting.
    """
    if not isinstance(model_json, dict):
        return ""

    # Per scope, release_version precedes agent_version so v0.8.0+ models
    # resolve to their release tag rather than the bogus "v<agent_version>".
    candidates: list[object] = []
    candidates.append(model_json.get("release_version"))
    candidates.append(model_json.get("agent_version"))
    candidates.append(model_json.get("agent_tag"))

    meta = model_json.get("_vibe_session_metadata")
    if isinstance(meta, dict):
        candidates.append(meta.get("release_version"))
        candidates.append(meta.get("agent_version"))
        candidates.append(meta.get("agent_tag"))
        candidates.append(meta.get("agent_release_tag"))

    inner = model_json.get("model")
    if isinstance(inner, dict):
        candidates.append(inner.get("release_version"))
        candidates.append(inner.get("agent_version"))
        candidates.append(inner.get("agent_tag"))

    for c in candidates:
        if isinstance(c, str) and c.strip():
            return _normalise(c)

    if fallback:
        normal = _normalise(fallback)
        if normal in SUPPORTED_TAGS:
            return normal
    return ""


def _probe_agent_version(model_json: dict) -> str | None:
    """Return the raw ``agent_version`` string from a model.json envelope.

    Probes the top level, ``_vibe_session_metadata`` and the inner ``model``
    block (same locations :func:`detect_tag_from_model_json` reads), returning
    the value verbatim (no ``v`` normalisation — the agent counter is
    ``4.x.y``). ``None`` when absent.
    """
    for src in (
        model_json,
        model_json.get("_vibe_session_metadata"),
        model_json.get("model"),
    ):
        if isinstance(src, dict):
            val = src.get("agent_version")
            if isinstance(val, str) and val.strip():
                return val.strip()
    return None


def extract_version_provenance(model_json: object) -> tuple[str | None, str | None]:
    """Return ``(agent_version, release_version)`` from a model.json envelope.

    Both are the version provenance stamped on ``ModelVersion`` at sync/import
    time:

    * ``agent_version`` — the agent-logic counter (``4.x.y`` from the 0.8.0
      agent line on), read verbatim via :func:`_probe_agent_version`.
    * ``release_version`` — the public/compat release identity resolved via
      :func:`detect_tag_from_model_json` (which prefers ``release_version`` but
      falls back to ``agent_version``/``agent_tag`` for pre-0.8.0 exports),
      with the leading ``v`` dropped so it matches the semver the agent stamps
      (``0.8.0``, not ``v0.8.0``).

    Both ``None`` when the envelope carries no signal (legacy rows, Delta-only
    payloads) — the columns stay NULL and downstream re-reads model.json to
    classify.
    """
    if not isinstance(model_json, dict):
        return None, None

    agent_version = _probe_agent_version(model_json)

    release_tag = detect_tag_from_model_json(model_json)
    if release_tag.startswith("v"):
        release_version: str | None = release_tag[1:]
    else:
        release_version = release_tag or None
    return agent_version, release_version


def extract_vibe_scope_facts(
    model_json: object,
) -> tuple[str | None, int | None, str | None]:
    """Return ``(fence_mode, base_version, base_scope)`` from a model.json's
    root ``_vibe_scope`` block.

    The agent writes the block on a vibe run (``mode`` is ``all`` for an
    All-domains run, ``some_domains`` for a scoped one) with the base it
    scoped against (``base_version`` as a string, ``base_scope`` short and
    lowercase). Each value is ``None`` when the file has no block or the key
    is missing or unreadable.
    """
    block = model_json_block(model_json, "_vibe_scope")
    if not isinstance(block, dict):
        return None, None, None
    mode = block.get("mode")
    mode = mode.strip() if isinstance(mode, str) and mode.strip() else None
    try:
        base_version: int | None = int(float(str(block.get("base_version")).strip()))
    except (TypeError, ValueError):
        base_version = None
    scope = block.get("base_scope")
    base_scope = scope.strip().lower() if isinstance(scope, str) and scope.strip() else None
    return mode, base_version, base_scope


@dataclass(frozen=True)
class CompatGate:
    """The compatibility verdict on one model.json, as every import applies it.

    ``refused``: ``breaking`` or ``unknown``; the import must not proceed.
    ``needs_adapter``: it proceeds with :attr:`adapter_warning`.
    """

    tag: str
    verdict: Verdict

    @property
    def refused(self) -> bool:
        return self.verdict in ("breaking", "unknown")

    @property
    def needs_adapter(self) -> bool:
        return self.verdict == "needs-adapter"

    @property
    def refusal_message(self) -> str:
        return describe_incompatibility(self.tag, self.verdict)

    @property
    def adapter_warning(self) -> str:
        return (
            f"Agent tag {self.tag!r} is classified needs-adapter and no adapter exists yet, "
            f"so the import uses the compatible code path. Check the model before installing it."
        )

    def refusal_detail(self) -> dict:
        """The 422 ``incompatible_agent_tag`` detail the import routes answer."""
        return {
            "error": "incompatible_agent_tag",
            "detected_agent_tag": self.tag,
            "compat_verdict": self.verdict,
            "latest_supported_tag": latest_supported_tag(),
            "supported_tags": sorted(SUPPORTED_TAGS),
            "message": self.refusal_message,
        }


def gate_model_json(model_json: object, *, fallback: str | None) -> CompatGate:
    """Detect the agent release of ``model_json`` and classify it.

    ``fallback`` is the tag assumed when the file names none (the import
    routes pass ``SUPPORTED_AGENT_VERSION`` for a valid file, ``None`` for an
    invalid one, which then classifies as ``unknown``).
    """
    tag = detect_tag_from_model_json(model_json, fallback=fallback) if isinstance(model_json, dict) else ""
    return CompatGate(tag=tag, verdict=classify_tag(tag))


def model_json_block(model_json: object, key: str, default: object = None) -> object:
    """The ``key`` block of an agent model.json, read at the root only.

    The agent writes its run blocks (``_vibe_scope``, ``input_outcomes``,
    ``lineage``, ``entity_changes``) at the top level of the file, next to the
    ``model`` envelope (nb 100448-100451), so a key inside ``model`` is not
    one of them. ``default`` when ``model_json`` is not a dict or has no
    ``key``; pass a sentinel to tell a missing key from a ``null`` value.
    """
    if not isinstance(model_json, dict):
        return default
    return model_json.get(key, default)


def generated_from_version_tag(model_json: object) -> str:
    """The ``generated_from_version`` lineage tag of a model.json, or ``""``.

    Read at the root, then in the ``model`` envelope (hand-edited and older
    files carry it in either place). Agent exports keep theirs inside
    ``_vibe_session_metadata``, which this does not read: there it labels the
    run's output, not its parent.
    """
    if not isinstance(model_json, dict):
        return ""
    for blob in (model_json, model_json.get("model")):
        if isinstance(blob, dict) and blob.get("generated_from_version"):
            return str(blob["generated_from_version"])
    return ""

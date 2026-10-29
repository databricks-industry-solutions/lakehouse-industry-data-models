"""Vibe scope validation and normalization for scoped vibe iterations.

Holds side-effect-free helpers for scope domain matching, normalization, and
base-version validation. ``scope_key`` and ``resolve_scope_domains`` are pure;
``scoped_base_blocker`` reads (never writes) the version rows of the business
through the session it is given. Nothing here imports from the router layer,
so the helpers are safe to call from the preflight validation path.

References: Integration Guide §16 "Model App Contract", Design Guide "Vibe Scope Semantics".
"""

import difflib
import re
from typing import Optional

from sqlmodel import col, select

from ..db_models import ModelVersion

# Widget labels exposed to the agent (exact strings the agent expects)
VIBE_SCOPE_WIDGET_LABELS = {
    "all_domains": "All Domains",
    "some_domains": "Some Domains",
    "some_subdomains": "Some Subdomains",
}

# Run type labels exposed to the agent (exact strings the agent expects)
RUN_TYPE_FULL = "Full Run"
RUN_TYPE_DRY = "Dry Run"

# Minimum agent version (marker) that supports scoped and Dry runs.
# Compared after stripping the "v" prefix. Blocks at create time (D14).
MIN_AGENT_MARKER_FOR_SCOPE = "5.3.3"

# Regex for normalizing scope domain names: keep only lowercase letters and digits.
_SCOPE_KEY_RE = re.compile(r"[^a-z0-9]")


def run_scope_domains(vibe_scope, domains) -> list[str]:
    """The scope list a run filters by: ``domains`` under a scoped run
    (``vibe_scope`` other than ``all_domains``), else empty (unscoped).

    ``vibe_scope`` may be the request enum or the stored string of a run's
    launch parameters.
    """
    if getattr(vibe_scope, "value", vibe_scope) in (None, "all_domains"):
        return []
    return [d for d in (domains or []) if isinstance(d, str)]


def scope_key(name: str) -> str:
    """Normalize a domain or scope name to the agent's canonical form.

    The agent's rule (design guide "Entries"):
    - Lowercase the name
    - Keep only letters and digits: remove spaces, punctuation, underscores, etc.

    Examples (verified against the 5.3.3 notebook):
        "Customer Service" -> "customerservice"
        "meter_to_cash" -> "metertocash"
        "Meter To Cash" -> "metertocash"

    Args:
        name: The domain or scope name from the base version or user input.

    Returns:
        The normalized key: lowercase with only [a-z0-9] characters.
    """
    return _SCOPE_KEY_RE.sub("", str(name).lower())


def resolve_scope_domains(
    requested: list[str],
    base_domain_names: list[str],
) -> tuple[list[str], list[tuple[str, list[str]]]]:
    """Match requested scope domain names against the base version's domains.

    Returns canonical (stored) domain names for each requested name, with
    suggestions for any unmatched names using fuzzy matching and substring hits.

    Deduplicates the result: if the same canonical name is matched twice
    (e.g., "customer_service" and "Customer Service" both normalize to the
    same domain), only one canonical name is returned.

    Args:
        requested: User-provided domain names (e.g., ["meter_to_cash"]).
        base_domain_names: Stored domain names from the base version
            (e.g., ["Meter To Cash", "Customer Service"]).

    Returns:
        A tuple:
        - List of canonical (stored) domain names, in the order requested
          (deduplicated).
        - List of (unknown_name, [closest_suggestions]) tuples for any
          requested names that did not match. Each tuple has up to 3
          suggestions from difflib.get_close_matches (cutoff 0.6) plus any
          substring matches.
    """
    # Build a map from scope_key to the canonical (stored) name.
    # If multiple domain names normalize to the same key, the first one wins.
    # (The design guide assumes domains within a version have distinct normalized keys.)
    key_to_canonical = {}
    for canonical_name in base_domain_names:
        key = scope_key(canonical_name)
        if key not in key_to_canonical:
            key_to_canonical[key] = canonical_name

    # Match each requested name.
    matched = []
    unknown = []
    seen_canonical = set()

    for req_name in requested:
        req_key = scope_key(req_name)
        if req_key in key_to_canonical:
            # Found a match.
            canonical = key_to_canonical[req_key]
            if canonical not in seen_canonical:
                matched.append(canonical)
                seen_canonical.add(canonical)
        else:
            # No match: gather suggestions.
            # Suggestions: difflib matches on the normalized keys, plus substring hits.
            difflib_suggestions = difflib.get_close_matches(
                req_key, key_to_canonical.keys(), n=3, cutoff=0.6
            )
            # Also find substring matches: canonical keys that contain the requested key.
            substring_suggestions = [
                k for k in key_to_canonical.keys()
                if req_key in k and k not in difflib_suggestions
            ]
            # Combine: difflib first (similarity-ranked), then substring.
            all_keys = difflib_suggestions + substring_suggestions[:3 - len(difflib_suggestions)]
            # Map keys back to canonical names.
            suggestions = [key_to_canonical[k] for k in all_keys]
            unknown.append((req_name, suggestions))

    return matched, unknown


def scope_head(session, business_id: str, scope: str) -> Optional[ModelVersion]:
    """The scope head: the ``completed`` version of ``(business_id, scope)``.

    Supersede keeps at most one completed row per scope; if legacy data holds
    more, the highest version wins. None when the scope has no completed
    version (only drafts, superseded or failed rows).
    """
    return session.exec(
        select(ModelVersion)
        .where(
            ModelVersion.business_id == business_id,
            ModelVersion.scope == scope,
            ModelVersion.status == "completed",
        )
        .order_by(col(ModelVersion.version).desc())
    ).first()


def scoped_base_blocker(session, base_mv) -> Optional[str]:
    """Check if a base version is valid for a scoped run (must be the head).

    A scoped run starts only from the scope head (:func:`scope_head`, D6,
    §5.3, §16.6). The head is the completed row, not the highest number: an
    install that made an older version current leaves newer, replaced
    versions above it.

    Returns None when ``base_mv`` is the head, else a blocker message naming
    the base and the head.
    """
    head = scope_head(session, base_mv.business_id, base_mv.scope)

    if base_mv.status != "completed":
        if head is None:
            if base_mv.status == "draft":
                return (
                    f"Scoped runs must start from the latest version. "
                    f"No completed version exists for {base_mv.scope}."
                )
            return (
                f"v{base_mv.version} is marked superseded and can't be used as a "
                f"scoped base. Scoped runs must start from a completed version."
            )
        if base_mv.status == "draft":
            return (
                f"Scoped runs must start from the latest version. "
                f"v{base_mv.version} is a Dry Run draft; the latest is v{head.version}."
            )
        return (
            f"v{base_mv.version} is no longer the latest version of this model (v{head.version} is). "
            f"Scoped runs must start from the latest version."
        )

    if head is None or base_mv.id == head.id:
        return None

    return (
        f"v{base_mv.version} is behind v{head.version}, the latest version. "
        f"A scoped run on v{base_mv.version} would lose the changes made after it. "
        f"Start from v{head.version}."
    )

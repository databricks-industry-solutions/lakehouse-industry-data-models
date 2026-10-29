"""Shared string-safety transforms used across the backend.

Three different concerns share this module because they're all small,
related, and called from many places:

- ``sanitize_tag`` — Databricks job tag value safety. It lives in the
  stdlib-only ``core/_job_tags.py`` (the installer loads that file by path)
  and is re-exported here.
- ``sanitize_catalog_segment`` — UC catalog-identifier safety.
- ``escape_sql_literal`` — SQL single-quoted string-literal escaping.

These are not interchangeable: a catalog segment is a UC identifier
(no quoting), a tag is a Databricks tag value, and a SQL literal is a
value we're about to wrap in ``'…'``. Mixing them produces either
broken SQL or broken identifiers. Pick the one that matches the target
grammar.
"""

import logging
import re

from ._job_tags import sanitize_tag

logger = logging.getLogger(__name__)

__all__ = [
    "agent_business_segment",
    "escape_sql_literal",
    "metamodel_display_business",
    "normalize_scope",
    "sanitize_catalog_segment",
    "sanitize_tag",
]

# Catalog segment: lowercase [a-z0-9_], underscores collapsed.
_CATALOG_SEGMENT_NON_SAFE = re.compile(r"[^a-z0-9_]+")
_CATALOG_SEGMENT_UNDERSCORES = re.compile(r"_+")

# Per-character probe for the agent boundary warning. The agent's
# `sanitize_name(strip_stop_words=False)` rule REPLACES every
# non-[a-z0-9_] char with `_` (then collapses + strips), so a single
# match means the input wasn't pre-normalized. Plain space included.
_AGENT_SEGMENT_NON_SAFE = re.compile(r"[^a-z0-9_]")


def sanitize_catalog_segment(value: str) -> str:
    """Lowercase + replace non-[a-z0-9_] with ``_`` + collapse underscores.

    Used to derive multi-catalog names from a user-provided
    ``deployment_catalog`` so the result is a legal UC catalog identifier.
    Returns ``"vibe"`` if the input is empty or reduces to nothing.
    """
    s = _CATALOG_SEGMENT_NON_SAFE.sub("_", (value or "").lower())
    s = _CATALOG_SEGMENT_UNDERSCORES.sub("_", s).strip("_")
    return s or "vibe"


def agent_business_segment(name: str) -> str:
    """Normalize a business name to the form the agent uses on Volume paths
    and as the ``business_name`` widget value.

    Mirrors the bundled agent's ``sanitize_name(strip_stop_words=False)``
    (see ``src/app/vendored/agent/vibe_modelling_agent_v5.3.3.ipynb``,
    cell defining ``def sanitize_name(name, strip_stop_words=True):  #
    GEN-RUL-002``). The strip-stop-words branch is intentionally NOT
    applied here because the app passes raw business identifiers.

    Rule (in order):

    1. Lowercase.
    2. Replace every non-[a-z0-9_] char with ``_``.
    3. Collapse runs of ``_`` to a single ``_``.
    4. Strip leading/trailing ``_``.
    5. If the result starts with a digit, prepend ``_`` (UC catalog
       identifiers can't start with a digit).

    Examples (verified against the agent's notebook):

        ``'Test Retail.'`` → ``'test_retail'``
        ``'Acme.Inc'``     → ``'acme_inc'``
        ``'Acme & Co.'``   → ``'acme_co'``
        ``'  Foo Bar  '``  → ``'foo_bar'``
        ``'7-eleven'``     → ``'_7_eleven'``

    Empty/None → ``""``. The agent itself returns ``"unnamed_model"`` for
    empty input but only after a warning; for our boundary callers we
    want a falsy sentinel so callers can detect "no name was passed"
    rather than silently route everyone to a single shared folder.

    Use this whenever passing a business name to the model-sync layer,
    constructing a Volume path, or sending the ``business_name`` widget
    value to the agent.

    Distinguishes from :func:`sanitize_catalog_segment` only in (a) the
    digit-prefix guard and (b) the empty-default. Phase 4 of the
    drift-unification plan will collapse the two helpers; for Phase 1
    they're kept separate to keep call-site semantics explicit.
    """
    if not name:
        return ""
    s = _CATALOG_SEGMENT_NON_SAFE.sub("_", str(name).lower())
    s = _CATALOG_SEGMENT_UNDERSCORES.sub("_", s).strip("_")
    if s and s[0].isdigit():
        s = "_" + s
    return s


def metamodel_display_business(name: str) -> str:
    """The value the agent stores in ``_metamodel.business.business``.

    The agent's ``step_setup_and_clean`` (Cell 120) applies ``.title()`` to
    the ``business_name`` widget value, which the app sends as
    ``agent_business_segment(name)`` (a lowercase slug).  This helper
    mirrors that chain:

        agent_business_segment(name)  →  lowercase slug (e.g. ``terranova_copy``)
        .strip().title()              →  display-cased slug (e.g. ``Terranova_Copy``)

    Python's ``.title()`` capitalises after every non-alphabetical character,
    including ``_`` AND digits.  For example ``"retail2b"`` → ``"Retail2B"``
    (the ``b`` follows the digit ``2``).

    Use for ``business`` column values in ``_metamodel.business`` INSERTs.
    Prefer ``LOWER()`` wrapping in SQL for defensive reads so that rows
    written by older app versions (lowercase) still match.

    Never use for Volume path segments — those stay lowercase via
    :func:`agent_business_segment`.
    """
    seg = agent_business_segment(name)
    return seg.strip().title() if seg else ""


def escape_sql_literal(s: object) -> str:
    """Escape a value for inclusion inside a SQL single-quoted string.

    Doubles embedded single quotes, backslash-escapes backslashes, strips
    NUL bytes that would upset Databricks SQL parsing. Input is coerced
    to string. Intended only for values we're about to wrap in ``'…'`` —
    **never for identifiers**. Use ``sanitize_catalog_segment`` for UC
    catalog names or validate-against-allowlist for other identifiers.

    Stripping NUL bytes changes the value, so it logs a warning with the
    count; the value itself is not logged.
    """
    if s is None:
        return ""
    text = str(s)
    nul_count = text.count("\x00")
    if nul_count:
        logger.warning(
            "escape_sql_literal: stripped %d NUL byte(s) from a SQL literal", nul_count
        )
        text = text.replace("\x00", "")
    return text.replace("\\", "\\\\").replace("'", "''")


def normalize_scope(scope: str) -> str:
    """Collapse any form of `model_scope` to its abbreviated form (`mvm` or
    `ecm`).

    The widget contract accepts the long form (`"Minimum Viable Model - MVM"`
    / `"Expanded Coverage Model - ECM"`) and the agent stores the abbreviated
    form in the metamodel Delta tables. Callers passing the long form into
    a WHERE clause match zero rows silently, which is how v3 auto-sync
    bricked. Normalising here means the rest of the pipeline can pass
    whatever `data_model_scopes` widget value it has without caring.
    """
    if not scope:
        return ""
    s = scope.strip().lower()
    if "mvm" in s or "minimum viable" in s:
        return "mvm"
    if "ecm" in s or "expanded coverage" in s:
        return "ecm"
    return s  # unknown value — pass through and hope it matches

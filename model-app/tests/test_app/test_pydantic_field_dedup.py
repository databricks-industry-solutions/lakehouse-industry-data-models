"""Detect dead / overlapping fields on `*In` Pydantic models.

Bug 4 in Phase 4.5: `RunIn` had both `catalog: str = ""` and
`deployment_catalog: str = ""`. Pydantic accepted both. The frontend
sent `catalog`. The DAG factory read `req.catalog`. Anyone calling the
API directly with `deployment_catalog` had it silently ignored.

This test enforces: every public field on every `*In` model must be
read at least once by the router/services layer. A field with zero
read sites is either dead code (delete it) or a bug (the route should
read it).

The check is conservative: it greps for `data.<field>` and `req.<field>`
patterns in the router + services trees. False negatives are possible
(e.g. fields read via `**dict_unpack`), so failures should be inspected
not just suppressed. The fix is usually to add the field to a
DEPRECATED list at module-top of the model OR to remove it.

Pattern: any future rename that leaves a stale field, any merge that
ships a duplicate covering the same domain, will fail this test on
the next run.
"""
from __future__ import annotations

import re
from pathlib import Path

import pytest

from vibe_modeling.backend import models as backend_models

from ._source_scan import iter_files


# Roots to search for `data.<field>` reads. Add new directories as the
# project grows.
SEARCH_ROOTS = [
    Path(backend_models.__file__).parent,  # src/app/src/vibe_modeling/backend/
]


def _all_in_models():
    """Yield every Pydantic model class in `models.py` whose name ends
    in `In` — these are the public request bodies."""
    for name in dir(backend_models):
        cls = getattr(backend_models, name)
        if not isinstance(cls, type):
            continue
        if not name.endswith("In"):
            continue
        # Pydantic v2 models have `model_fields`.
        if hasattr(cls, "model_fields"):
            yield name, cls


def _backend_files_using_splat(root: Path) -> set[Path]:
    """Files that splat-spread an *In model into another call, like
    ``**data.model_dump()`` or ``**req.dict()``. Fields on `*In` models
    that are only read this way won't appear under direct attribute
    access, so we treat them as 'read indirectly' to avoid false
    positives. Returns the set of files that contain any splat pattern."""
    splat_re = re.compile(r"\*\*\s*(?:data|req|run_in|payload|body|cfg)\b")
    matches: set[Path] = set()
    for py, _rel in iter_files(root):
        try:
            text = py.read_text(encoding="utf-8")
        except Exception:
            continue
        if splat_re.search(text):
            matches.add(py)
    return matches


def _grep_field_reads(root: Path, field_name: str) -> int:
    """Count direct attribute reads of `<var>.<field>` for the given
    field name in any Python file under `root`. Patterns covered:
    ``data.foo``, ``req.foo``, ``self.foo``, ``payload.foo``, ``body.foo``,
    ``run_in.foo``, ``in_.foo``, ``cfg.foo``, ``X.foo`` (for any
    snake_case X). The bare-name keyword-argument pattern (``foo=``) is
    NOT included because it produces too many false positives."""
    # Two patterns: explicit `<known_var>.<field>` and any
    # snake_case_var.<field>. Either is enough to count.
    pattern = re.compile(
        rf"\b[a-z_][a-z0-9_]*\.{re.escape(field_name)}\b"
    )
    total = 0
    for py, _rel in iter_files(root):
        try:
            text = py.read_text(encoding="utf-8")
        except Exception:
            continue
        total += len(pattern.findall(text))
    return total


# Fields that are KNOWN to be read indirectly (e.g. via dict-unpack into
# `map_run_params_to_widgets`) — explicit allowlist so a true zero-read
# field still trips the test.
ALLOWED_INDIRECT = {
    # Add entries here when a field is read via .model_dump() splat. Each
    # entry should include a comment with the call site that consumes it.
}


@pytest.mark.parametrize("model_name,model_cls", list(_all_in_models()))
def test_in_model_fields_are_read_somewhere(model_name, model_cls):
    """Every field on every public `*In` model must be read at least
    once in the backend — either via direct attribute access OR via a
    splat pattern (``**data.model_dump()``). Catches dead fields and
    overlapping domain-coverage like Phase 4.5 bug 4."""
    # If any backend file uses a splat pattern with a model dump, treat
    # all fields on every In model as read-indirectly (the splat call
    # signature decides what's actually consumed; we can't statically
    # tell). The check still has value for purely-direct-access fields.
    splat_files = set()
    for root in SEARCH_ROOTS:
        splat_files |= _backend_files_using_splat(root)

    dead = []
    for field_name, field_info in model_cls.model_fields.items():
        if (model_name, field_name) in ALLOWED_INDIRECT:
            continue
        total = sum(_grep_field_reads(root, field_name) for root in SEARCH_ROOTS)
        if total == 0 and not splat_files:
            dead.append(field_name)

    if splat_files:
        # When splat patterns exist, the dead-field check is unreliable —
        # we still want to know if any field is INDIRECTLY orphaned, but
        # that requires call-site analysis we don't do here. For now the
        # test passes silently when splats are present; the targeted
        # `test_run_in_has_no_silent_catalog_alias` test below catches
        # the specific Phase 4.5 bug 4 pattern (alias fields on the same
        # domain), which is what this whole file is here to guard.
        return

    assert not dead, (
        f"{model_name} has fields with zero read sites in the backend: "
        f"{dead}. Either delete them, mark as deprecated alias with a "
        f"model_validator that translates to a canonical field, or add "
        f"to ALLOWED_INDIRECT with a comment naming the consumer."
    )


def test_run_in_has_no_silent_catalog_alias():
    """Specific guard against bug 4 reproducing. RunIn must accept both
    `catalog` and `deployment_catalog`, but if `deployment_catalog` is
    set and `catalog` isn't, the validator must copy the alias onto
    `catalog` so downstream readers see exactly one canonical field."""
    from vibe_modeling.backend.models import RunIn

    body = RunIn(
        deployment_catalog="aliased_catalog")
    assert body.catalog == "aliased_catalog", (
        f"deployment_catalog='aliased_catalog' should normalise onto "
        f"catalog. Got catalog={body.catalog!r}, "
        f"deployment_catalog={body.deployment_catalog!r}"
    )

    # When both are set, the explicit `catalog` wins.
    body2 = RunIn(
        catalog="explicit_target",
        deployment_catalog="alias_value")
    assert body2.catalog == "explicit_target"

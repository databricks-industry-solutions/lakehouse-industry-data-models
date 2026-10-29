"""``explorer._load_prev_model``: which version a diff compares against (D13b).

The lineage base (``base_version_id``) wins only when it has the same scope and
is not a Dry Run draft. Otherwise the previous version is the highest
same-scope, non-draft version below N. Shrink and enlarge stamp a cross-scope
base (an MVM built from an ECM), which must not become the comparison point.
"""

from __future__ import annotations

import pytest
from sqlmodel import Session

from vibe_modeling.backend import explorer
from vibe_modeling.backend.db_models import Business, ModelVersion


@pytest.fixture
def loaded(monkeypatch):
    """Record which (version, scope) ``_load_prev_model`` asks to load."""
    calls = []

    def fake_load_model(session, ws, business_id, version_int, scope):
        calls.append((version_int, scope))
        return {"version": version_int, "scope": scope}

    monkeypatch.setattr(explorer, "_load_model", fake_load_model)
    return calls


def _seed(engine, rows):
    """rows: list of (key, version, scope, status, base_key)."""
    with Session(engine) as s:
        biz = Business(name="Prev Co", description="d")
        s.add(biz)
        s.flush()
        ids = {}
        for key, version, scope, status, base_key in rows:
            mv = ModelVersion(
                business_id=biz.id, version=version, scope=scope, status=status,
                base_version_id=ids.get(base_key),
            )
            s.add(mv)
            s.flush()
            ids[key] = mv.id
        s.commit()
        return biz.id


def _prev(engine, biz_id, version, scope):
    with Session(engine) as s:
        return explorer._load_prev_model(s, None, biz_id, version, scope)


def test_full_run_after_dry_run_diffs_against_its_base(engine, loaded):
    biz = _seed(engine, [
        ("v6", 6, "ecm", "superseded", None),
        ("v7", 7, "ecm", "draft", "v6"),       # Dry Run
        ("v8", 8, "ecm", "completed", "v6"),   # Full Run on the same base
    ])
    assert _prev(engine, biz, 8, "ecm") == {"version": 6, "scope": "ecm"}
    assert loaded == [(6, "ecm")]


def test_draft_skipped_when_no_base(engine, loaded):
    biz = _seed(engine, [
        ("v6", 6, "ecm", "completed", None),
        ("v7", 7, "ecm", "draft", None),
        ("v8", 8, "ecm", "completed", None),
    ])
    assert _prev(engine, biz, 8, "ecm")["version"] == 6


def test_draft_base_falls_back_to_highest_non_draft(engine, loaded):
    biz = _seed(engine, [
        ("v5", 5, "ecm", "superseded", None),
        ("v6", 6, "ecm", "draft", "v5"),
        ("v7", 7, "ecm", "completed", "v6"),
    ])
    assert _prev(engine, biz, 7, "ecm")["version"] == 5


def test_cross_scope_base_falls_back_to_same_scope(engine, loaded):
    """Shrink: an MVM whose base_version_id is an ECM diffs against the prior MVM."""
    biz = _seed(engine, [
        ("mvm1", 1, "mvm", "superseded", None),
        ("ecm3", 3, "ecm", "completed", None),
        ("mvm2", 2, "mvm", "completed", "ecm3"),
    ])
    assert _prev(engine, biz, 2, "mvm") == {"version": 1, "scope": "mvm"}


def test_cross_scope_base_with_no_prior_same_scope_has_no_prev(engine, loaded):
    biz = _seed(engine, [
        ("ecm1", 1, "ecm", "completed", None),
        ("mvm2", 2, "mvm", "completed", "ecm1"),
    ])
    assert _prev(engine, biz, 2, "mvm") is None
    assert loaded == []


def test_same_scope_base_beats_newer_intermediate(engine, loaded):
    """A same-scope base below an intermediate non-draft version still wins."""
    biz = _seed(engine, [
        ("v4", 4, "ecm", "superseded", None),
        ("v5", 5, "ecm", "failed", "v4"),
        ("v6", 6, "ecm", "completed", "v4"),
    ])
    assert _prev(engine, biz, 6, "ecm")["version"] == 4


def test_first_version_has_no_prev(engine, loaded):
    biz = _seed(engine, [("v1", 1, "ecm", "completed", None)])
    assert _prev(engine, biz, 1, "ecm") is None
    assert loaded == []

"""Tests for the same-scope ModelVersion supersession invariant.

Conceptual rule under test: at any point in time there is at most one
``status='completed'`` :class:`ModelVersion` per ``(business_id, scope)``.
Creating a new completed version of a scope flips every other completed
version of the same scope to ``superseded``. Different-scope versions
(e.g. the paired ECM/MVM produced by a unified pipeline) are untouched.

These tests exercise the helper directly + the ``vibe_iterate`` and
``_terminal_success`` call sites that wire it in.
"""

from __future__ import annotations

from unittest.mock import MagicMock

import pytest
from sqlmodel import Session, select

from vibe_modeling.backend.db_models import Business, ModelVersion
from vibe_modeling.backend.services.operations._generation_common import (
    restore_superseded_priors,
    supersede_same_scope_priors,
)
from vibe_modeling.backend.services.operations.vibe_iterate import VibeIterate


# ---------------------------------------------------------------------------
# Fixtures
# ---------------------------------------------------------------------------


@pytest.fixture
def two_businesses(engine) -> tuple[str, str]:
    with Session(engine) as s:
        a = Business(name="Acme Co")
        b = Business(name="Other Co")
        s.add(a)
        s.add(b)
        s.commit()
        s.refresh(a)
        s.refresh(b)
        return a.id, b.id


def _mv(
    session: Session,
    business_id: str,
    *,
    scope: str,
    version: int,
    status: str = "completed",
    catalog: str = "cat_one",
) -> str:
    mv = ModelVersion(
        business_id=business_id,
        version=version,
        status=status,
        scope=scope,
        uc_catalog=catalog,
    )
    session.add(mv)
    session.commit()
    session.refresh(mv)
    return mv.id


def _status(session: Session, mv_id: str) -> str:
    row = session.exec(
        select(ModelVersion).where(ModelVersion.id == mv_id)
    ).one()
    return row.status


# ---------------------------------------------------------------------------
# Helper-level invariants
# ---------------------------------------------------------------------------


class TestHelperBehaviour:
    def test_helper_supersedes_only_same_scope_completed_priors(
        self, engine, two_businesses
    ):
        """Same scope + completed → flipped. Different scope → untouched.
        Different business → untouched. Already non-completed → untouched."""
        biz_a, biz_b = two_businesses
        with Session(engine) as s:
            ecm_v1 = _mv(s, biz_a, scope="ecm", version=1)
            ecm_v2 = _mv(s, biz_a, scope="ecm", version=2)  # the new one
            mvm_v1 = _mv(s, biz_a, scope="mvm", version=1)  # different scope
            other_ecm = _mv(s, biz_b, scope="ecm", version=1)  # different biz
            failed_ecm = _mv(
                s, biz_a, scope="ecm", version=3, status="failed"
            )

            flipped = supersede_same_scope_priors(s, biz_a, "ecm", ecm_v2)
            s.commit()

        with Session(engine) as s:
            assert _status(s, ecm_v1) == "superseded"
            assert _status(s, ecm_v2) == "completed"  # exclude_id intact
            assert _status(s, mvm_v1) == "completed"  # different scope
            assert _status(s, other_ecm) == "completed"  # different biz
            assert _status(s, failed_ecm) == "failed"  # not completed

        assert flipped == [ecm_v1]

    def test_helper_returns_empty_when_no_priors(self, engine, two_businesses):
        biz_a, _ = two_businesses
        with Session(engine) as s:
            new_id = _mv(s, biz_a, scope="ecm", version=1)
            flipped = supersede_same_scope_priors(s, biz_a, "ecm", new_id)
            s.commit()
        assert flipped == []

    def test_helper_rejects_empty_scope(self, engine, two_businesses):
        biz_a, _ = two_businesses
        with Session(engine) as s:
            new_id = _mv(s, biz_a, scope="ecm", version=1)
            with pytest.raises(ValueError):
                supersede_same_scope_priors(s, biz_a, "", new_id)
            with pytest.raises(ValueError):
                supersede_same_scope_priors(s, biz_a, "   ", new_id)

    def test_restore_unflips_only_still_superseded_rows(
        self, engine, two_businesses
    ):
        """Restore flips ``superseded`` → ``completed``; rows that have
        moved to other states (or been deleted) are left alone."""
        biz_a, _ = two_businesses
        with Session(engine) as s:
            a = _mv(s, biz_a, scope="ecm", version=1, status="superseded")
            b = _mv(s, biz_a, scope="ecm", version=2, status="failed")
            restore_superseded_priors(s, [a, b, "ghost-id"])
            s.commit()
        with Session(engine) as s:
            assert _status(s, a) == "completed"
            assert _status(s, b) == "failed"


# ---------------------------------------------------------------------------
# vibe_iterate rollback wiring
# ---------------------------------------------------------------------------


class TestVibeIterateRollback:
    def test_rollback_uses_auto_superseded_ids(
        self, engine, two_businesses
    ):
        """Rollback restores rows listed in ``auto_superseded_ids`` even
        when the legacy parent_prior_status keys are absent."""
        biz_a, _ = two_businesses
        with Session(engine) as s:
            prior = _mv(s, biz_a, scope="ecm", version=1, status="superseded")
            new_mv = _mv(s, biz_a, scope="ecm", version=2)

        primitive = VibeIterate()
        ctx = MagicMock()
        ctx.business_id = biz_a
        ctx.run_id = "run-without-report"
        rollback_state = {
            "new_version_id": new_mv,
            "auto_superseded_ids": [prior],
        }
        with Session(engine) as s:
            primitive.rollback(ctx, rollback_state, MagicMock(), s)
            s.commit()

        with Session(engine) as s:
            assert _status(s, prior) == "completed"
            gone = s.exec(
                select(ModelVersion).where(ModelVersion.id == new_mv)
            ).first()
            assert gone is None

    def test_rollback_cross_business_isolation(
        self, engine, two_businesses
    ):
        """Rollback only restores ids it was given — it never reaches
        across businesses on its own."""
        biz_a, biz_b = two_businesses
        with Session(engine) as s:
            other = _mv(
                s, biz_b, scope="ecm", version=1, status="superseded"
            )
            new_mv = _mv(s, biz_a, scope="ecm", version=1)

        primitive = VibeIterate()
        ctx = MagicMock()
        ctx.business_id = biz_a
        ctx.run_id = "run-without-report"
        with Session(engine) as s:
            primitive.rollback(
                ctx,
                {"new_version_id": new_mv, "auto_superseded_ids": []},
                MagicMock(),
                s,
            )
            s.commit()

        with Session(engine) as s:
            # Other-business row never touched.
            assert _status(s, other) == "superseded"


# ---------------------------------------------------------------------------
# Cross-scope (paired ECM/MVM) isolation
# ---------------------------------------------------------------------------


class TestCrossScopeIsolation:
    def test_creating_new_mvm_does_not_touch_paired_ecm(
        self, engine, two_businesses
    ):
        """vibe-new-ecm-mvm Phase 2: the just-created Phase 1 ECM is the
        ``current`` ECM. Phase 2's MVM supersession sweep must not touch
        it (different scope)."""
        biz_a, _ = two_businesses
        with Session(engine) as s:
            ecm_v2_just_created = _mv(s, biz_a, scope="ecm", version=2)
            mvm_v1_prior = _mv(s, biz_a, scope="mvm", version=1)
            mvm_v2_new = _mv(s, biz_a, scope="mvm", version=2)
            flipped = supersede_same_scope_priors(
                s, biz_a, "mvm", mvm_v2_new
            )
            s.commit()

        assert flipped == [mvm_v1_prior]
        with Session(engine) as s:
            assert _status(s, ecm_v2_just_created) == "completed"
            assert _status(s, mvm_v1_prior) == "superseded"
            assert _status(s, mvm_v2_new) == "completed"

    def test_enlarge_mvm_to_ecm_keeps_source_mvm_completed(
        self, engine, two_businesses
    ):
        """Enlarging MVM v1 → ECM v2: the source MVM stays ``completed``
        because it's a different scope. A pre-existing ECM v1 (if any)
        is the one that flips to ``superseded``."""
        biz_a, _ = two_businesses
        with Session(engine) as s:
            mvm_v1_source = _mv(s, biz_a, scope="mvm", version=1)
            ecm_v1_old = _mv(s, biz_a, scope="ecm", version=1)
            ecm_v2_new = _mv(s, biz_a, scope="ecm", version=2)
            flipped = supersede_same_scope_priors(
                s, biz_a, "ecm", ecm_v2_new
            )
            s.commit()

        assert flipped == [ecm_v1_old]
        with Session(engine) as s:
            assert _status(s, mvm_v1_source) == "completed"
            assert _status(s, ecm_v1_old) == "superseded"
            assert _status(s, ecm_v2_new) == "completed"

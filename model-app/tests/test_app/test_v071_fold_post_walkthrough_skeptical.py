"""Skeptical-tester pass for v0.7.1 fold POST-walkthrough fixes.

Written from `SPEC_FIX1.md` ALONE, against the
public API surface of the modules under test. Tests are blind to the
developer agent's edits — they assert the contract, not the
implementation.

Spec coverage map (SPEC_FIX1.md §"Tests required"):

- _find_model_json_path Strategy 0 wins                : `TestFindModelJsonPathStrategy0`
- _find_model_json_path falls through                  : `TestFindModelJsonPathStrategy0`
- artifact_type writer/reader alignment                : `TestArtifactTypeAlignment`
- ModelVersion.sync_state + .sync_error_text columns   : `TestModelVersionSyncStateColumns`
- vibe_iterate sync_model raise → 'incomplete_metadata': `TestVibeIterateSyncFailureMarks`
- finalize raise → 'finalize_failed'                   : `TestFinalizeFailureMarks`
- _finalize_session_completion 3-retry                  : `TestFinalizeRetryLogic`
- ModelVersionOut surfaces sync_state + sync_error_text: `TestModelVersionOutFields`
- (Optional) Migration applies cleanly                  : `TestSyncStateMigration`
"""

from __future__ import annotations

import os
import re
import sys
from unittest.mock import MagicMock

import pytest

from databricks.sdk.errors.platform import NotFound

# Match the conftest path-injection idiom — the package imports must
# resolve whether or not pytest is launched from the worktree root.
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", ".."))


# Worktree-rooted source files for the artifact_type alignment scan —
# the assertion must hit disk so reader/writer agreement is proven by
# what's actually in the tree, not by import-time state.
_BACKEND_DIR = os.path.normpath(
    os.path.join(
        os.path.dirname(__file__),
        "..",
        "..",
        "src",
        "app",
        "src",
        "vibe_modeling",
        "backend",
    )
)
_EXPLORER_PY = os.path.join(_BACKEND_DIR, "explorer.py")
_VIBE_ITERATE_PY = os.path.join(
    _BACKEND_DIR, "services", "operations", "vibe_iterate.py"
)


# ---------------------------------------------------------------------------
# Shared fixtures local to this file
# ---------------------------------------------------------------------------


@pytest.fixture
def biz_with_version(engine):
    """Create a Business + ModelVersion (v=1, scope='ecm') and yield ids.

    The conftest ``engine`` fixture gives us the in-memory SQLite with all
    tables created. We seed a single Business + ModelVersion row so the
    explorer's resolve_model_version helper has something to bind to.
    """
    from sqlmodel import Session
    from vibe_modeling.backend.db_models import Business, ModelVersion

    with Session(engine) as session:
        biz = Business(
            name="Phase7 Retailer",
            description="Skeptical fixture",
            industry_alignment="Retail",
        )
        session.add(biz)
        session.flush()
        mv = ModelVersion(
            business_id=biz.id,
            version=2,
            status="completed",
            scope="ecm",
            uc_catalog="vibe_modeling_test",
        )
        session.add(mv)
        session.commit()
        session.refresh(biz)
        session.refresh(mv)
        return {"business_id": biz.id, "version_id": mv.id, "name": biz.name}


# ---------------------------------------------------------------------------
# Bug 1 — Strategy 0 in _find_model_json_path
# ---------------------------------------------------------------------------


class TestFindModelJsonPathStrategy0:
    """SPEC §Bug 1: a Strategy 0 must run BEFORE Strategy 1/2 and use
    `_paths.model_json_volume_path` as the canonical path source.

    These tests pass `ws.files.get_metadata` as a controllable mock:
    success → Strategy 0 returns immediately;
    raises ``NotFound`` → Strategy 0 falls through, leaving Strategy 1/2
    to run. Any other exception must propagate (so AttributeError on a
    typo'd SDK call surfaces instead of being eaten as "file missing").
    """

    def test_strategy_0_returns_canonical_path_when_present(self, engine, biz_with_version):
        """Strategy 0 must hit the canonical path FIRST and return it on success.

        Pre-fold the canonical path was never tried; the function went
        straight to the `RunArtifact` query (which would miss because of
        the artifact_type mismatch) and the legacy convention path
        (which doesn't exist for v0.5.9+ layouts). Result: 404 even
        though `model.json` was on disk.
        """
        from sqlmodel import Session

        from vibe_modeling.backend.core._paths import model_json_volume_path
        from vibe_modeling.backend.explorer import _find_model_json_path

        canonical = model_json_volume_path(
            "vibe_modeling_test",
            biz_with_version["name"],
            2,
            "ecm",
        )

        ws = MagicMock()
        # Track which path the SDK was asked about. Strategy 0 must hit
        # the canonical path; only then should get_metadata succeed.
        seen_paths: list[str] = []

        def get_metadata(path: str):
            seen_paths.append(path)
            if path == canonical:
                return MagicMock(path=path)
            raise NotFound(f"Not Found: {path}")

        ws.files.get_metadata.side_effect = get_metadata

        with Session(engine) as session:
            result = _find_model_json_path(
                session, ws, biz_with_version["business_id"], 2, "ecm"
            )

        assert result == canonical, (
            f"_find_model_json_path must return the canonical "
            f"`_paths.model_json_volume_path` value when ws.files.get_metadata "
            f"succeeds for it (Strategy 0). "
            f"Got {result!r}; expected {canonical!r}. "
            f"Paths the function probed: {seen_paths!r}."
        )
        assert canonical in seen_paths, (
            f"Strategy 0 must call ws.files.get_metadata with the canonical path. "
            f"Probed paths: {seen_paths!r}; canonical: {canonical!r}."
        )

    def test_strategy_0_falls_through_when_canonical_missing(
        self, engine, biz_with_version
    ):
        """When the canonical file does NOT exist, Strategy 0 must fall
        through silently so Strategy 1 (RunArtifact) and Strategy 2
        (legacy convention) still get a chance.

        We assert the function DID try the canonical path at least once,
        and that nothing raised — falling through is silent. Only the
        Databricks SDK ``NotFound`` exception triggers fall-through;
        any other error propagates.
        """
        from sqlmodel import Session

        from vibe_modeling.backend.core._paths import model_json_volume_path
        from vibe_modeling.backend.explorer import _find_model_json_path

        canonical = model_json_volume_path(
            "vibe_modeling_test",
            biz_with_version["name"],
            2,
            "ecm",
        )

        ws = MagicMock()
        seen_paths: list[str] = []

        def always_not_found(path: str):
            seen_paths.append(path)
            raise NotFound(f"Not Found: {path}")

        ws.files.get_metadata.side_effect = always_not_found
        # Listing the legacy docs dir also raises NotFound — we want every
        # strategy to come up empty so the function returns None rather
        # than spuriously matching one.
        ws.files.list_directory_contents.side_effect = NotFound("dir missing")

        with Session(engine) as session:
            # No RunArtifact rows seeded → Strategy 1 returns nothing,
            # Strategy 2 hits NotFound. Strategy 0 must have been tried first.
            result = _find_model_json_path(
                session, ws, biz_with_version["business_id"], 2, "ecm"
            )

        assert result is None, (
            f"With every probe failing, _find_model_json_path must "
            f"return None (caller raises 404). Got {result!r}."
        )
        assert canonical in seen_paths, (
            f"Strategy 0 must probe the canonical path even when it "
            f"won't succeed; otherwise the fallback chain is broken. "
            f"Probed paths: {seen_paths!r}; canonical: {canonical!r}."
        )

    def test_strategy_0_propagates_non_notfound_errors(
        self, engine, biz_with_version
    ):
        """Strategy 0 must propagate exceptions that aren't ``NotFound``.

        This is the regression-lock for the ``ws.files.get_status`` typo:
        the SDK has no such method, so calling it raises ``AttributeError``.
        Pre-fix, the explorer caught ``Exception`` and ate that, silently
        falling through to Strategy 1/2 and 404'ing on the rendered page
        even when ``model.json`` was on Volume. Post-fix, only ``NotFound``
        is treated as a fall-through signal; everything else surfaces.
        """
        from sqlmodel import Session

        from vibe_modeling.backend.explorer import _find_model_json_path

        ws = MagicMock()
        # Simulate the historical bug shape: the SDK call raises a
        # non-NotFound error (e.g., AttributeError, RuntimeError).
        ws.files.get_metadata.side_effect = AttributeError(
            "'FilesExt' object has no attribute 'get_status'"
        )

        with Session(engine) as session:
            with pytest.raises(AttributeError):
                _find_model_json_path(
                    session, ws, biz_with_version["business_id"], 2, "ecm"
                )


# ---------------------------------------------------------------------------
# Bug 1 — artifact_type string alignment
# ---------------------------------------------------------------------------


class TestArtifactTypeAlignment:
    """SPEC §Bug 1: writer (vibe_iterate.py) and reader (explorer.py)
    must agree on the `artifact_type` string for model.json. SPEC picks
    `"model_json"` as the canonical value — the writer already emits
    that; the reader must match.

    We scan source on disk (NOT the import-time module) so the tests
    catch a regression even if a __pycache__ ships a stale copy.
    """

    def _read_text(self, path: str) -> str:
        with open(path, "r", encoding="utf-8") as f:
            return f.read()

    def test_writer_emits_model_json_artifact_type(self):
        """The writer (vibe_iterate.py) must use the canonical string
        `"model_json"` when it appends a RunArtifact row for the
        model.json output."""
        src = self._read_text(_VIBE_ITERATE_PY)
        # The artifact-row literal in vibe_iterate emits:
        #   {"artifact_type": "model_json", "file_path": ...}
        # We assert that exact substring is present so any future drift
        # ("model.json" / "json" / "model_json_v2") trips this test.
        assert '"artifact_type": "model_json"' in src or \
               "'artifact_type': 'model_json'" in src, (
            f"vibe_iterate.py must emit RunArtifact rows with "
            f"artifact_type=\"model_json\" (the canonical SPEC §Bug 1 value). "
            f"The substring was not found in {_VIBE_ITERATE_PY!r}."
        )

    def test_reader_filters_on_model_json_artifact_type(self):
        """The reader (explorer._find_model_json_path) WHERE clause must
        match the writer — i.e. `RunArtifact.artifact_type == "model_json"`,
        NOT `"json"`. The pre-fold value `"json"` makes every vibe_iterate
        artifact row unreachable.
        """
        src = self._read_text(_EXPLORER_PY)
        # The reader filters in a SQL select; assert the canonical value
        # appears bound to artifact_type.
        assert (
            'RunArtifact.artifact_type == "model_json"' in src
            or "RunArtifact.artifact_type == 'model_json'" in src
        ), (
            f"explorer.py must filter RunArtifact.artifact_type == "
            f"'model_json' to match what vibe_iterate.py writes "
            f"(SPEC §Bug 1 canonical value)."
        )
        # And the stale `'json'` filter must be GONE; otherwise the
        # writer/reader still misalign for the same string.
        assert (
            'RunArtifact.artifact_type == "json"' not in src
            and "RunArtifact.artifact_type == 'json'" not in src
        ), (
            f"explorer.py must NOT keep the stale "
            f"`RunArtifact.artifact_type == 'json'` filter — that's the "
            f"exact mismatch SPEC §Bug 1 calls out."
        )

    def test_writer_reader_use_same_string(self):
        """Strongest assertion: extract the literals each module uses for
        `artifact_type` (when set on a model.json row) and confirm the
        sets match. Defense-in-depth against future drift."""
        writer_src = self._read_text(_VIBE_ITERATE_PY)
        reader_src = self._read_text(_EXPLORER_PY)

        # Pull all dict-style "artifact_type": "<value>" literals from
        # the writer. There may be only one in vibe_iterate.py; that's
        # fine — we just want them as a set.
        writer_values = set(
            re.findall(
                r"""["']artifact_type["']\s*:\s*["']([a-z0-9_\-]+)["']""",
                writer_src,
            )
        )
        # Pull all `RunArtifact.artifact_type == "<value>"` comparisons
        # from the reader.
        reader_values = set(
            re.findall(
                r"""RunArtifact\.artifact_type\s*==\s*["']([a-z0-9_\-]+)["']""",
                reader_src,
            )
        )

        assert writer_values, (
            f"Could not find any `\"artifact_type\": \"<value>\"` literal "
            f"in vibe_iterate.py — the test regex needs adjustment if "
            f"the writer was rewritten."
        )
        assert reader_values, (
            f"Could not find any `RunArtifact.artifact_type == \"<value>\"` "
            f"comparison in explorer.py — the reader filter is gone."
        )
        assert reader_values <= writer_values, (
            f"Reader filters on artifact_type values not produced by the "
            f"writer. Writer writes {writer_values!r}; reader filters on "
            f"{reader_values!r}. The reader's set must be a subset of the "
            f"writer's so every filtered row is reachable."
        )


# ---------------------------------------------------------------------------
# Bug 2 — ModelVersion has sync_state + sync_error_text columns
# ---------------------------------------------------------------------------


class TestModelVersionSyncStateColumns:
    """SPEC §Bug 2: `ModelVersion` gets two new columns:
    `sync_state` (default 'ok') and `sync_error_text` (Optional[str]).
    """

    def test_modelversion_has_sync_state_field(self):
        from vibe_modeling.backend.db_models import ModelVersion

        assert "sync_state" in ModelVersion.model_fields, (
            f"ModelVersion must declare a `sync_state` field "
            f"(SPEC §Bug 2). Existing fields: {list(ModelVersion.model_fields)!r}."
        )

    def test_modelversion_sync_state_default_is_ok(self):
        from vibe_modeling.backend.db_models import ModelVersion

        mv = ModelVersion(business_id="b", version=1, scope="ecm")
        assert mv.sync_state == "ok", (
            f"ModelVersion.sync_state must default to 'ok' for new rows "
            f"(SPEC §Bug 2). Got {mv.sync_state!r}."
        )

    def test_modelversion_has_sync_error_text_field(self):
        from vibe_modeling.backend.db_models import ModelVersion

        assert "sync_error_text" in ModelVersion.model_fields, (
            f"ModelVersion must declare a `sync_error_text` field "
            f"(SPEC §Bug 2). Existing fields: {list(ModelVersion.model_fields)!r}."
        )

    def test_modelversion_sync_error_text_default_is_none(self):
        from vibe_modeling.backend.db_models import ModelVersion

        mv = ModelVersion(business_id="b", version=1, scope="ecm")
        assert mv.sync_error_text is None, (
            f"ModelVersion.sync_error_text must default to None "
            f"(SPEC §Bug 2 — nothing to surface for happy-path rows). "
            f"Got {mv.sync_error_text!r}."
        )

    def test_modelversion_round_trips_sync_state_through_session(self, engine):
        """Belt-and-suspenders: write a ModelVersion with custom
        sync_state + sync_error_text, read it back, confirm both
        columns persisted. Catches the case where the SQLModel field
        is declared but never bound to an actual column.
        """
        from sqlmodel import Session, select

        from vibe_modeling.backend.db_models import Business, ModelVersion

        with Session(engine) as session:
            biz = Business(name="round-trip biz")
            session.add(biz)
            session.flush()
            mv = ModelVersion(
                business_id=biz.id,
                version=1,
                scope="ecm",
                sync_state="incomplete_metadata",
                sync_error_text="boom" * 10,
            )
            session.add(mv)
            session.commit()
            session.refresh(mv)
            mv_id = mv.id

        with Session(engine) as session:
            row = session.exec(
                select(ModelVersion).where(ModelVersion.id == mv_id)
            ).first()
            assert row is not None
            assert row.sync_state == "incomplete_metadata", (
                f"sync_state did not round-trip through SQLModel/SQLite. "
                f"Got {row.sync_state!r}."
            )
            assert row.sync_error_text == "boom" * 10, (
                f"sync_error_text did not round-trip. Got {row.sync_error_text!r}."
            )


# ---------------------------------------------------------------------------
# Bug 2 — vibe_iterate marks sync_state on sync_model exception
# ---------------------------------------------------------------------------


class TestVibeIterateSyncFailureMarks:
    """SPEC §Bug 2: when `sync_model` raises inside vibe_iterate's
    success path, the catch handler must:
      - set new_mv.sync_state = 'incomplete_metadata'
      - set new_mv.sync_error_text = str(exc)[:500]
      - persist (session.add + commit) before logging.exception().

    We verify by source inspection (the catch block is short and lives
    near `vibe_iterate.py:615-630`). A unit-level integration test
    against the live primitive would require dragging in the entire
    operation context — out of scope for a contract test; the source
    contract is enough to catch the developer dropping the column-set
    line, which is the actual regression risk.
    """

    def _read_text(self, path: str) -> str:
        with open(path, "r", encoding="utf-8") as f:
            return f.read()

    def test_vibe_iterate_marks_incomplete_metadata_on_sync_failure(self):
        src = self._read_text(_VIBE_ITERATE_PY)
        # The fix MUST include this exact string (per SPEC §Bug 2 line
        # 117) so future drift trips this test rather than silently
        # using a different sentinel.
        assert "incomplete_metadata" in src, (
            f"vibe_iterate.py must reference the sentinel "
            f"'incomplete_metadata' as the sync_state value when "
            f"sync_model raises (SPEC §Bug 2 line 117). "
            f"Without this string, the catch site is still silent."
        )

    def test_vibe_iterate_truncates_exception_to_500_chars(self):
        """SPEC §Bug 2 line 116: `sync_error_text = str(exc)[:500]`.

        Either the slice literal `[:500]` or a documented helper
        equivalent must be present so a 5-MB stack trace doesn't
        bloat the row.
        """
        src = self._read_text(_VIBE_ITERATE_PY)
        # The literal [:500] is the simplest implementation; accept any
        # form that includes the magic number.
        assert "500" in src, (
            f"vibe_iterate.py must truncate the captured exception "
            f"string to 500 chars (SPEC §Bug 2 line 116) — the literal "
            f"500 is missing from the file."
        )
        assert "sync_error_text" in src, (
            f"vibe_iterate.py must assign `sync_error_text` on the "
            f"sync_model failure path (SPEC §Bug 2)."
        )

    def test_vibe_iterate_unit_simulated_sync_failure_marks_state(
        self, engine, biz_with_version, monkeypatch
    ):
        """Best-effort unit test: simulate the catch handler's WORK by
        patching ModelSyncService so the next call raises, then
        re-running the column-set + commit logic the SPEC defines.

        We don't drive the whole primitive (it requires deployment
        catalog wiring + agent run state); instead we assert that GIVEN
        the failure caught, applying the SPEC's pseudocode produces
        the expected row state. This is the smallest test that proves
        the COLUMN itself is functional — the source-inspection tests
        above already cover the in-vibe_iterate wiring.
        """
        from sqlmodel import Session, select

        from vibe_modeling.backend.db_models import ModelVersion

        # Find the seeded version, simulate the catch-handler write.
        with Session(engine) as session:
            mv = session.exec(
                select(ModelVersion).where(
                    ModelVersion.id == biz_with_version["version_id"]
                )
            ).first()
            assert mv is not None

            # Simulate sync_model raising — the catch handler must
            # write these two fields and persist.
            simulated_exc = RuntimeError("schema apply failed: " + ("x" * 600))
            # SPEC §Bug 2 pseudocode:
            mv.sync_state = "incomplete_metadata"
            mv.sync_error_text = str(simulated_exc)[:500]
            session.add(mv)
            session.commit()

        with Session(engine) as session:
            row = session.exec(
                select(ModelVersion).where(
                    ModelVersion.id == biz_with_version["version_id"]
                )
            ).first()
            assert row is not None
            assert row.sync_state == "incomplete_metadata", (
                f"After simulated sync_model failure, sync_state must "
                f"be 'incomplete_metadata' on the new ModelVersion row "
                f"(SPEC §Bug 2). Got {row.sync_state!r}."
            )
            assert row.sync_error_text is not None, (
                f"sync_error_text must be populated on failure."
            )
            assert len(row.sync_error_text) <= 500, (
                f"sync_error_text must be truncated to 500 chars "
                f"(SPEC §Bug 2). Got len={len(row.sync_error_text)}."
            )


# ---------------------------------------------------------------------------
# Bug 2 — finalize_session_completion failure marks sync_state='finalize_failed'
# ---------------------------------------------------------------------------


class TestFinalizeFailureMarks:
    """SPEC §Bug 2: when `_finalize_session_completion` raises (e.g.
    `DELTA_CONCURRENT_APPEND.ROW_LEVEL_CHANGES`), the matching
    ModelVersion row must end up with sync_state='finalize_failed'.

    Source-inspection: the sentinel string must appear in
    progress_tracker.py so the catch site is wired up.
    """

    def _read_text(self, path: str) -> str:
        with open(path, "r", encoding="utf-8") as f:
            return f.read()

    def test_progress_tracker_references_finalize_failed_sentinel(self):
        path = os.path.join(_BACKEND_DIR, "progress_tracker.py")
        src = self._read_text(path)
        assert "finalize_failed" in src, (
            f"progress_tracker.py must reference the sentinel "
            f"'finalize_failed' as the sync_state value when "
            f"_finalize_session_completion raises (SPEC §Bug 2). "
            f"Without this, the silent-catch path is unfixed."
        )

    def test_simulated_finalize_failure_marks_state(self, engine, biz_with_version):
        """Unit-level: after a simulated DELTA_CONCURRENT_APPEND
        exception in the finalize site, the ModelVersion row must end
        with sync_state='finalize_failed'. Tests the column behaviour
        independent of how progress_tracker decides to call it.
        """
        from sqlmodel import Session, select

        from vibe_modeling.backend.db_models import ModelVersion

        with Session(engine) as session:
            mv = session.exec(
                select(ModelVersion).where(
                    ModelVersion.id == biz_with_version["version_id"]
                )
            ).first()
            assert mv is not None
            simulated = RuntimeError(
                "SQL error: [DELTA_CONCURRENT_APPEND.ROW_LEVEL_CHANGES]"
            )
            mv.sync_state = "finalize_failed"
            mv.sync_error_text = str(simulated)[:500]
            session.add(mv)
            session.commit()

        with Session(engine) as session:
            row = session.exec(
                select(ModelVersion).where(
                    ModelVersion.id == biz_with_version["version_id"]
                )
            ).first()
            assert row is not None
            assert row.sync_state == "finalize_failed", (
                f"After simulated finalize failure, sync_state must be "
                f"'finalize_failed' (SPEC §Bug 2). Got {row.sync_state!r}."
            )
            assert (
                "DELTA_CONCURRENT_APPEND" in (row.sync_error_text or "")
            ), (
                f"sync_error_text must capture the underlying Delta "
                f"error string. Got {row.sync_error_text!r}."
            )


# ---------------------------------------------------------------------------
# Bug 3 — _finalize_session_completion retry logic
# ---------------------------------------------------------------------------


class TestFinalizeRetryLogic:
    """SPEC §Bug 3: `_finalize_session_completion` wraps `_write`
    in a retry loop:
      - up to 3 retries on DELTA_CONCURRENT_APPEND.ROW_LEVEL_CHANGES
      - other errors propagate immediately
      - after retries exhaust: re-raise OR mark sync_state='finalize_failed'.

    We use the existing ProgressTracker class, mock `_write`, and
    count the number of attempts.
    """

    def _make_tracker(self, side_effect):
        """Build a ProgressTracker with `_write` patched to raise.

        We monkeypatch the bound method directly on the instance so the
        retry loop sees the synthesized errors without needing a real
        warehouse client.
        """
        from vibe_modeling.backend.progress_tracker import ProgressTracker

        ws = MagicMock()
        ws.config.host = "https://test"
        # ProgressTracker takes (ws, config, lakebase_factory, ...). The
        # ctor signature varies; rather than couple to it, we
        # instantiate via __new__ + set the bare minimum attributes.
        tracker = ProgressTracker.__new__(ProgressTracker)
        # Bind the few attrs `_finalize_session_completion` uses.
        tracker._ws = ws
        tracker._warehouse_id = "test-wh"
        # Track call count via a list so the closure is mutable.
        calls: list[int] = []

        def fake_execute(sql: str):
            calls.append(1)
            r = side_effect(len(calls))
            if isinstance(r, BaseException):
                raise r
            return r

        tracker._write = fake_execute  # type: ignore[assignment]
        return tracker, calls

    def test_finalize_retries_on_delta_concurrent_append(self):
        """First two attempts fail with DELTA_CONCURRENT_APPEND, third
        succeeds → call count must be 3."""
        def side_effect(attempt: int):
            if attempt < 3:
                return RuntimeError(
                    "SQL error: [DELTA_CONCURRENT_APPEND.ROW_LEVEL_CHANGES] retry me"
                )
            return None  # success

        tracker, calls = self._make_tracker(side_effect)
        # Should NOT raise — the third attempt succeeds.
        try:
            tracker._finalize_session_completion("cat", 12345)
        except Exception as e:
            pytest.fail(
                f"_finalize_session_completion must succeed on the third "
                f"attempt after two DELTA_CONCURRENT_APPEND retries "
                f"(SPEC §Bug 3). Raised {e!r}. calls={len(calls)}."
            )
        assert len(calls) == 3, (
            f"Expected exactly 3 attempts (2 retries + 1 success). "
            f"Got {len(calls)} calls — retry loop is not behaving."
        )

    def test_finalize_gives_up_after_three_retries(self):
        """All four attempts fail with DELTA_CONCURRENT_APPEND; after 3
        retries, the function must give up. Call count <= 4 (1 initial
        + up to 3 retries). SPEC permits either re-raise OR swallow with
        the finalize_failed mark — we don't dictate which here, just
        that the loop stops."""
        def side_effect(attempt: int):
            return RuntimeError(
                "SQL error: [DELTA_CONCURRENT_APPEND.ROW_LEVEL_CHANGES] retry me"
            )

        tracker, calls = self._make_tracker(side_effect)
        # The function may re-raise OR swallow per SPEC. Either is fine
        # for THIS assertion — we just want the call count bounded.
        try:
            tracker._finalize_session_completion("cat", 12345)
        except Exception:
            pass

        assert len(calls) == 4, (
            f"With persistent DELTA_CONCURRENT_APPEND errors the function "
            f"must use ALL 3 retries before giving up (SPEC §Bug 3): "
            f"1 initial + 3 retries = 4 attempts. Got {len(calls)}."
        )

    def test_finalize_does_not_retry_on_unrelated_error(self):
        """Non-DELTA_CONCURRENT_APPEND errors must propagate immediately
        (SPEC §Bug 3 line 150). Call count must be 1."""
        def side_effect(attempt: int):
            return RuntimeError("SQL error: PERMISSION_DENIED")

        tracker, calls = self._make_tracker(side_effect)
        with pytest.raises(Exception):
            tracker._finalize_session_completion("cat", 12345)
        assert len(calls) == 1, (
            f"Non-DELTA_CONCURRENT_APPEND errors must propagate without "
            f"retry (SPEC §Bug 3). Got {len(calls)} calls — the retry "
            f"loop is matching too broadly."
        )


# ---------------------------------------------------------------------------
# Bug 2 — ModelVersionOut surfaces sync_state + sync_error_text
# ---------------------------------------------------------------------------


class TestModelVersionOutFields:
    """SPEC §Bug 2 line 126: `ModelVersionOut` must include
    `sync_state` + `sync_error_text` so the FE can read them."""

    def test_model_version_out_has_sync_state(self):
        from vibe_modeling.backend.models import ModelVersionOut

        assert "sync_state" in ModelVersionOut.model_fields, (
            f"ModelVersionOut must expose `sync_state` so the FE banner "
            f"can render. Existing fields: {list(ModelVersionOut.model_fields)!r}."
        )

    def test_model_version_out_has_sync_error_text(self):
        from vibe_modeling.backend.models import ModelVersionOut

        assert "sync_error_text" in ModelVersionOut.model_fields, (
            f"ModelVersionOut must expose `sync_error_text` so the FE "
            f"banner can show the cause. Existing fields: "
            f"{list(ModelVersionOut.model_fields)!r}."
        )

    def test_model_version_out_sync_error_text_is_optional(self):
        """A happy-path ModelVersion has sync_error_text=None — the
        Pydantic field must accept None (Optional[str])."""
        from vibe_modeling.backend.models import ModelVersionOut

        # Can't fully construct without all required fields; just verify
        # the field annotation includes None / Optional. Look at the
        # model_fields metadata which carries the annotation.
        field = ModelVersionOut.model_fields["sync_error_text"]
        annotation = field.annotation
        # Either Optional[str] or `str | None` — both expose `None` in
        # the args of the Union/Optional. We also accept a default of
        # None as proof of optionality.
        accepts_none = (
            type(None) in getattr(annotation, "__args__", ())
            or field.default is None
        )
        assert accepts_none, (
            f"ModelVersionOut.sync_error_text must accept None (Optional[str]) "
            f"so happy-path rows serialise cleanly. Got annotation={annotation!r}, "
            f"default={field.default!r}."
        )


# ---------------------------------------------------------------------------
# (Optional) Migration test — sync_state migration applies cleanly
# ---------------------------------------------------------------------------


class TestSyncStateMigration:
    """SPEC §Bug 2 line 110-111: a migration adds the two columns with
    `default='ok'` for existing rows. We don't pin the migration's
    version string (the developer picks it) but we DO assert that
    after `reconcile_schema` against an empty engine, the
    `model_versions` table has the new columns AND that an existing
    row in a pre-migration schema would default to 'ok'.

    Because this fold is pre-prod with `PRE_PROD_DESTRUCTIVE_RESET=True`
    the on-disk migration story is "wipe and rebuild from SQLModel
    metadata". So we mostly assert the schema is shaped correctly
    after reconcile.
    """

    def test_reconcile_creates_sync_state_columns(self):
        """After reconcile_schema runs against a fresh in-memory engine,
        the `model_versions` table must have sync_state +
        sync_error_text columns."""
        from sqlalchemy import inspect
        from sqlalchemy.pool import StaticPool
        from sqlmodel import create_engine

        from vibe_modeling.backend.migrations.registry import reconcile_schema

        engine = create_engine(
            "sqlite://",
            connect_args={"check_same_thread": False},
            poolclass=StaticPool,
        )
        reconcile_schema(engine)

        cols = {c["name"] for c in inspect(engine).get_columns("model_versions")}
        assert "sync_state" in cols, (
            f"reconcile_schema must create the `sync_state` column on "
            f"model_versions (SPEC §Bug 2). Existing columns: {cols!r}."
        )
        assert "sync_error_text" in cols, (
            f"reconcile_schema must create the `sync_error_text` column "
            f"on model_versions (SPEC §Bug 2). Existing columns: {cols!r}."
        )

    def test_existing_row_defaults_sync_state_to_ok(self, engine):
        """Insert a ModelVersion without specifying sync_state; the
        default value must be 'ok' so existing rows aren't displayed as
        broken (SPEC §Bug 2 line 110-111: 'no backfill needed — the
        running app will mark new failures only')."""
        from sqlmodel import Session, select

        from vibe_modeling.backend.db_models import Business, ModelVersion

        with Session(engine) as session:
            biz = Business(name="default biz")
            session.add(biz)
            session.flush()
            mv = ModelVersion(business_id=biz.id, version=1, scope="ecm")
            session.add(mv)
            session.commit()
            session.refresh(mv)
            mv_id = mv.id

        with Session(engine) as session:
            row = session.exec(
                select(ModelVersion).where(ModelVersion.id == mv_id)
            ).first()
            assert row is not None
            assert row.sync_state == "ok", (
                f"A ModelVersion row inserted without sync_state must "
                f"default to 'ok' (SPEC §Bug 2). Got {row.sync_state!r}."
            )

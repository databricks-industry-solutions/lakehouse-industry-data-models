"""Skeptical tests for the ``v_0_3_0`` migration (Phase 5 — state-machine
retirement).

The migration's contract per ``docs/orchestrator-design.md`` §5.1:

1. Drop ``runs.run_type`` if it exists.
2. Drop ``runs.rollback_plan`` if it exists.
3. Be idempotent — re-applying against a database whose columns are
   already gone (or only one of them is gone) must succeed silently.
4. Be registered in ``vibe_modeling.backend.migrations.MIGRATIONS`` so
   ``reconcile_schema()`` picks it up at boot.
5. Have a stable version key (``"0.3.0"``) that sorts strictly higher
   than ``"0.2.0"``.

Plus the parallel owner-script contract: ``scripts/db/migrate.py`` must
expose a ``DROP_COLUMNS`` list whose entries cover the same ``(table,
column)`` pairs the registry would drop. The drift coverage is mirrored
in ``test_migration_drift_owner.py``; this file tests the symbol's
existence and basic shape.

Stub-for-integration pattern
----------------------------

The dev agent owns the implementation files in parallel. We never import
``v_0_3_0`` directly — we only test through the public registry surface
(``MIGRATIONS``, ``reconcile_schema``). When a contract is testable only
via a freshly-introduced symbol (e.g., ``DROP_COLUMNS`` in the owner
script) we attempt the import lazily and ``pytest.fail`` (NOT skip) with
a clear ``STUB-FOR-INTEGRATION`` message — failure is the correct signal
during the parallel-agent merge window.
"""

from __future__ import annotations

import importlib.util
import pathlib
import re
from typing import Any

import pytest
from sqlalchemy import inspect, text
from sqlalchemy.pool import StaticPool
from sqlmodel import Session, SQLModel, create_engine, select

from vibe_modeling.backend import migrations
from vibe_modeling.backend.migrations import registry as reg
from vibe_modeling.backend.db_models import LakebaseSchemaVersion

from ._source_scan import BACKEND, is_comment, iter_files


# --- Constants ----------------------------------------------------------------


_V030_VERSION = "0.3.0"
_DOOMED_COLUMNS: tuple[str, ...] = ("run_type", "rollback_plan")
_OWNER_SCRIPT_PATH = (
    pathlib.Path(__file__).resolve().parents[2] / "scripts" / "db" / "migrate.py"
)


# --- Fixtures -----------------------------------------------------------------


@pytest.fixture
def empty_engine():
    """Fresh in-memory SQLite engine — no tables, no version row.

    We stand up a clean engine per-test rather than reusing the conftest
    ``engine`` fixture so each scenario starts from a known-empty
    baseline. ``StaticPool`` keeps the in-memory database alive across
    sessions.
    """
    engine = create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    return engine


@pytest.fixture(autouse=True)
def _reset_lifecycle_constants(monkeypatch):
    """Default each test to the production-style partial-upgrade branch.

    Pre-prod's destructive-reset path wipes the schema on any version
    mismatch, which would mask "did the drop actually happen?" — we want
    the test to see the post-migration table shape, not a fresh
    ``create_all``. Tests that need destructive-reset on can re-flip via
    their own monkeypatch.
    """
    monkeypatch.setattr(reg, "PRE_PROD_DESTRUCTIVE_RESET", False)
    monkeypatch.setattr(reg, "INSTALL_POLICY", "permissive")


# --- Helpers ------------------------------------------------------------------


def _create_legacy_runs_table(engine, *, with_run_type: bool, with_rollback_plan: bool):
    """Build a synthetic ``runs`` table whose column shape matches the
    pre-Phase-5 schema. We can't rely on ``SQLModel.metadata.create_all``
    because the live ``Run`` model has already had the columns removed
    in code — we need to materialise the *legacy* shape on disk so the
    migration has something to drop.

    Returns nothing; the engine is mutated in place. Each scenario calls
    this with a different combination of doomed columns to exercise the
    fully-applied / half-applied / already-gone states.
    """
    cols = ["id INTEGER PRIMARY KEY"]
    if with_run_type:
        cols.append("run_type TEXT")
    if with_rollback_plan:
        cols.append("rollback_plan TEXT")
    cols.append("status TEXT DEFAULT 'pending'")
    ddl = f"CREATE TABLE runs ({', '.join(cols)})"
    with engine.begin() as conn:
        conn.execute(text(ddl))


def _runs_columns(engine) -> set[str]:
    """Return the column names present on the ``runs`` table.

    SQLAlchemy's ``inspect`` is dialect-agnostic — works for the SQLite
    fixture we use here and for a real Postgres engine on a test workspace.
    """
    return {col["name"] for col in inspect(engine).get_columns("runs")}


def _bootstrap_version_row(engine, version: str) -> None:
    """Stamp the ``_lakebase_schema_version`` singleton at ``version``.

    Mirrors what reconcile would do after a fresh install. Used by tests
    that need to skip the create_all bootstrap and pretend an earlier
    migration already finished.
    """
    SQLModel.metadata.create_all(engine, tables=[LakebaseSchemaVersion.__table__])
    with Session(bind=engine) as session:
        existing = session.exec(
            select(LakebaseSchemaVersion).where(LakebaseSchemaVersion.id == 1)
        ).first()
        if existing is None:
            session.add(
                LakebaseSchemaVersion(id=1, version=version, applied_at=reg._now())
            )
        else:
            existing.version = version
            existing.applied_at = reg._now()
            session.add(existing)
        session.commit()


def _v030_or_fail() -> Any:
    """Return the ``v_0_3_0`` Migration from the registry, or fail with
    a STUB-FOR-INTEGRATION message.

    We refuse to ``pytest.skip`` here — the integrator's merge window is
    exactly when "missing v_0_3_0" should be a loud failure so the dev
    agent's commit and the test agent's commit land together.
    """
    for m in migrations.MIGRATIONS:
        if m.version == _V030_VERSION:
            return m
    pytest.fail(
        f"v_0_3_0 is not yet registered in MIGRATIONS — "
        f"STUB-FOR-INTEGRATION. Current versions: "
        f"{[m.version for m in migrations.MIGRATIONS]!r}"
    )


def _load_owner_script_module() -> Any:
    """Import ``scripts/db/migrate.py`` without executing ``main()``.

    The script is a top-level file; we use ``spec_from_file_location``
    to load only its module-scope definitions, the same way
    ``test_migration_drift_owner.py`` does.
    """
    assert _OWNER_SCRIPT_PATH.exists(), (
        f"owner script not found at {_OWNER_SCRIPT_PATH}"
    )
    spec = importlib.util.spec_from_file_location(
        "owner_migrate_script_v030_test", str(_OWNER_SCRIPT_PATH)
    )
    assert spec is not None and spec.loader is not None
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


# --- Tests --------------------------------------------------------------------


def test_v_0_3_0_is_registered_in_migrations_list():
    """``v_0_3_0`` must appear in ``MIGRATIONS`` so ``reconcile_schema``
    picks it up at boot. Without this registration the migration is
    dead code — the column drops never run on a live workspace.
    """
    versions = [m.version for m in migrations.MIGRATIONS]
    assert _V030_VERSION in versions, (
        f"v_0_3_0 not registered in MIGRATIONS — STUB-FOR-INTEGRATION. "
        f"Current registered versions: {versions!r}"
    )


def test_v_0_3_0_appears_before_any_later_migration():
    """The ``MIGRATIONS`` list is order-sensitive: ``reconcile_schema``
    walks it sequentially. ``v_0_3_0`` (Phase 5 column drops) must
    appear before any later migration so the drop runs before any
    follow-up ALTER on ``runs``.

    Originally guarded that ``v_0_3_0`` was the tail; relaxed when
    ``v_0_4_0`` (post-run sync surfacing) landed. The invariant we
    actually care about is ordering.
    """
    versions = [m.version for m in migrations.MIGRATIONS]
    assert versions, "MIGRATIONS list is empty"
    assert _V030_VERSION in versions, "v_0_3_0 missing from MIGRATIONS"
    idx = versions.index(_V030_VERSION)
    later = versions[idx + 1 :]
    for v in later:
        assert v > _V030_VERSION, (
            f"migration {v!r} sorts before v_0_3_0 but is registered after it. "
            f"Full list: {versions!r}"
        )


def test_v_0_3_0_sorts_strictly_after_v_0_2_0():
    """The version key must compare strictly greater than ``"0.2.0"``
    under the same string-ordering reconcile uses (``installed >
    latest``). If ``v_0_3_0`` ever ships as e.g. ``"0.2.10"``, naive
    string comparison would wrongly place it before ``"0.2.0"`` lexically
    only when the next field is shorter — but ``"0.3.0" > "0.2.0"`` is
    safe under both string and tuple ordering. This test pins the
    registered key to that safe shape.
    """
    assert _V030_VERSION > "0.2.0", (
        f"version key {_V030_VERSION!r} does not sort strictly after '0.2.0'"
    )


def test_apply_on_fresh_db_drops_both_columns(empty_engine):
    """End-to-end: empty engine in, full reconcile out, neither doomed
    column survives on the ``runs`` table.

    This is the load-bearing scenario — a fresh Lakebase project where the
    runtime registry walks every migration in order. After
    ``reconcile_schema`` completes, the ``runs`` table reflects the
    *current* model definition (no ``run_type``, no ``rollback_plan``).
    """
    _v030_or_fail()  # fail-fast if the migration isn't registered yet

    migrations.reconcile_schema(empty_engine)

    cols = _runs_columns(empty_engine)
    for doomed in _DOOMED_COLUMNS:
        assert doomed not in cols, (
            f"column {doomed!r} survived reconcile on a fresh DB; "
            f"runs columns: {sorted(cols)!r}"
        )


def test_idempotent_reapply_against_already_clean_db(empty_engine):
    """Re-applying ``v_0_3_0`` against a database where the doomed
    columns are already gone must succeed silently.

    Simulates the "workspace where the owner already ran ``scripts/db/migrate.py``"
    flow: the columns are gone, then the app boots and reconcile runs
    the registered migration. The drop is a no-op but must not raise.
    """
    v030 = _v030_or_fail()

    # Bootstrap: create the version row at 0.2.0, materialise a runs
    # table that matches the *post*-Phase-5 shape (no doomed columns)
    # — i.e., the owner already cleaned up.
    _bootstrap_version_row(empty_engine, "0.2.0")
    _create_legacy_runs_table(
        empty_engine, with_run_type=False, with_rollback_plan=False
    )

    # Apply the migration directly — we don't go through reconcile here
    # because reconcile would re-run every migration newer than 0.2.0,
    # and we want to isolate v_0_3_0's drop logic.
    v030.apply(empty_engine)

    # No exception — and the table is still there with no doomed columns.
    cols = _runs_columns(empty_engine)
    for doomed in _DOOMED_COLUMNS:
        assert doomed not in cols, (
            f"column {doomed!r} unexpectedly present after no-op apply"
        )


def test_idempotent_reapply_called_twice(empty_engine):
    """``apply()`` called twice in a row must not raise.

    Distinct from the "already clean" scenario: here the migration
    actually runs the drop the first time, then runs it AGAIN against
    its own output. Catches a class of bug where an implementation
    issues an unconditional ``DROP COLUMN`` (no ``IF EXISTS``) and the
    second call blows up.
    """
    v030 = _v030_or_fail()

    _bootstrap_version_row(empty_engine, "0.2.0")
    _create_legacy_runs_table(
        empty_engine, with_run_type=True, with_rollback_plan=True
    )

    v030.apply(empty_engine)
    v030.apply(empty_engine)  # must not raise

    cols = _runs_columns(empty_engine)
    for doomed in _DOOMED_COLUMNS:
        assert doomed not in cols


def test_half_applied_state_completes_cleanly(empty_engine):
    """One column dropped, the other still present — the migration must
    finish the job without raising.

    Models a partial-failure state where the migration crashed between
    the two drops on a previous run. Each individual drop must guard
    against "column already gone" so the second-run cleanup works.
    """
    v030 = _v030_or_fail()

    _bootstrap_version_row(empty_engine, "0.2.0")
    # run_type already gone, rollback_plan still present — the half
    # state. The opposite half is symmetric and we cover it implicitly
    # by the loop in the migration; one direction is enough here.
    _create_legacy_runs_table(
        empty_engine, with_run_type=False, with_rollback_plan=True
    )

    v030.apply(empty_engine)

    cols = _runs_columns(empty_engine)
    for doomed in _DOOMED_COLUMNS:
        assert doomed not in cols, (
            f"column {doomed!r} should have been dropped from the half-applied "
            f"state; runs columns: {sorted(cols)!r}"
        )


def test_empty_runs_table_survives_migration(empty_engine):
    """Degenerate case: ``runs`` table exists with the legacy columns
    but is empty (TRUNCATEd). The migration must succeed and leave the
    table in place (rows: 0, columns: post-Phase-5).
    """
    v030 = _v030_or_fail()

    _bootstrap_version_row(empty_engine, "0.2.0")
    _create_legacy_runs_table(
        empty_engine, with_run_type=True, with_rollback_plan=True
    )
    # Explicit truncate — table already empty, but make the intent
    # legible in case a future change seeds rows in the helper.
    with empty_engine.begin() as conn:
        conn.execute(text("DELETE FROM runs"))

    v030.apply(empty_engine)

    # Table still exists, doomed columns gone, row count is zero.
    assert "runs" in inspect(empty_engine).get_table_names()
    cols = _runs_columns(empty_engine)
    for doomed in _DOOMED_COLUMNS:
        assert doomed not in cols
    with empty_engine.connect() as conn:
        n = conn.execute(text("SELECT COUNT(*) FROM runs")).scalar_one()
    assert n == 0


def test_reconcile_refuses_downgrade_past_v_0_3_0(empty_engine):
    """If the recorded version is ahead of what's registered, reconcile
    must refuse to start — never roll the schema back.

    Equivalent of ``test_installed_newer_than_code_refuses_to_start``
    in ``test_migrations.py``, but pinned to ``v_0_3_0``'s presence in
    the migration list. This guards against a future commit that
    accidentally drops ``v_0_3_0`` from the registry: the test fails
    loudly because the registered "latest" silently rewinds to 0.2.0.
    """
    _v030_or_fail()

    # Stamp a version higher than v_0_3_0.
    _bootstrap_version_row(empty_engine, "9.9.9")

    with pytest.raises(reg.LakebaseInstallError) as exc_info:
        migrations.reconcile_schema(empty_engine)

    assert "newer than" in str(exc_info.value)


def test_owner_script_drop_columns_covers_phase_5_columns():
    """``scripts/db/migrate.py`` must expose a ``DROP_COLUMNS`` list (or
    equivalent) whose entries include both Phase 5 column drops.

    The runtime registry and the owner script are coupled by hand —
    ``test_migration_drift_owner.py`` enforces the ADD COLUMN side; this
    test enforces the DROP COLUMN side for v_0_3_0 specifically. We
    deliberately FAIL (not skip) on missing symbols so the parallel dev
    agent's merge surfaces the gap immediately.
    """
    owner = _load_owner_script_module()

    # Try the most likely symbol names in priority order. The dev agent
    # may have picked any of these; whichever shows up first wins.
    candidates = ("DROP_COLUMNS", "DROPS", "COLUMNS_TO_DROP")
    drops = None
    chosen_name = None
    for name in candidates:
        if hasattr(owner, name):
            drops = getattr(owner, name)
            chosen_name = name
            break

    if drops is None:
        pytest.fail(
            "scripts/db/migrate.py does not expose any of "
            f"{candidates!r} — STUB-FOR-INTEGRATION. The owner script "
            "must declare a list of (table, column) drops mirroring the "
            "v_0_3_0 registry migration so the test workspaces' owner-impersonation "
            "flow drops the same columns the runtime registry would."
        )

    # Whatever name was chosen, every entry must be a (table, column)
    # 2-tuple — owner script DDL is built from these positionally.
    drops_list = list(drops)
    drop_pairs = set()
    for entry in drops_list:
        assert len(entry) == 2, (
            f"owner script {chosen_name!r} entry {entry!r} should be a "
            f"(table, column) 2-tuple"
        )
        drop_pairs.add((entry[0], entry[1]))

    expected = {("runs", "run_type"), ("runs", "rollback_plan")}
    missing = expected - drop_pairs
    assert not missing, (
        f"owner script {chosen_name!r} is missing Phase 5 drops: {sorted(missing)!r}. "
        f"Found entries: {sorted(drop_pairs)!r}"
    )


def test_no_production_reads_of_dropped_columns():
    """Static guard: production source under ``backend/`` must not read
    or assign ``runs.run_type`` / ``runs.rollback_plan`` after Phase 5.

    Phase 5 Stage 1 supposedly already removed every reference; this
    test pins that removal so a future commit that re-introduces
    ``run.run_type`` (e.g., during a careless merge) fails loudly here
    rather than at first query against a Lakebase project where the
    column has been dropped.

    Allowed exceptions:
    * the ``v_0_3_0`` migration itself — it MUST mention the names to
      drop them, by definition;
    * ``db_models.py`` comments referencing the legacy names as
      historical context (Phase 5 retirement notes).

    Heuristic match: lines that contain the column name and look like
    Python expressions/strings (not pure comments). We strip
    ``#``-prefixed lines so the historical-context comments don't trip
    the regex.
    """
    assert BACKEND.is_dir(), f"backend directory not found: {BACKEND}"

    # Files that may contain the widget key "run_type" (agent widget 03a for
    # Dry Run toggle). This is unrelated to the dropped DB column runs.run_type;
    # it's a parameter sent to the notebook. Allowed pattern: the string literal
    # in _WIDGET_UI_LABELS or widget dict assignments (not attribute access).
    widget_key_files = {
        "job_launcher.py",  # _WIDGET_UI_LABELS["run_type"]
        "core/_widgets.py",  # widget dict key
    }

    # Match an attribute access (``.run_type`` or ``.rollback_plan``) or
    # a quoted column name as a string literal. Excludes word-boundary
    # matches inside other identifiers like ``run_type_thing``.
    attr_pattern = re.compile(r"\.run_type\b")
    patterns = [
        attr_pattern,
        re.compile(r"\.rollback_plan\b"),
        re.compile(r"['\"]run_type['\"]"),
        re.compile(r"['\"]rollback_plan['\"]"),
    ]
    # Widget key pattern: "run_type" as a dict key in assignments like
    # "run_type": ... or { "run_type": ... (excludes attribute access .run_type).
    widget_key_pattern = re.compile(r'["\']run_type["\']\s*:')

    hits: list[tuple[str, int, str]] = []
    # The migration file itself may name the retired columns.
    for path, rel in iter_files(BACKEND, exempt={"migrations/v_0_3_0.py"}):
        text_ = path.read_text()
        for lineno, line in enumerate(text_.splitlines(), start=1):
            if is_comment(line):
                continue  # pure comment; legacy context allowed
            for pat in patterns:
                if pat.search(line):
                    # The widget-key exception: only in the allowed files,
                    # only for the dict-key form, and never on a line that
                    # also reads the retired ``.run_type`` attribute.
                    if (
                        rel in widget_key_files
                        and pat.pattern == r"['\"]run_type['\"]"
                        and widget_key_pattern.search(line)
                        and not attr_pattern.search(line)
                    ):
                        break  # This hit is allowed; skip to next line.
                    hits.append((str(path), lineno, line.strip()))
                    break

    assert not hits, (
        "Production code under backend/ still references retired Run "
        f"columns (run_type / rollback_plan): {hits!r}"
    )

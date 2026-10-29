"""taxonomy/saved_state.py: the per-user saved Domain Taxonomy wizard."""

from datetime import datetime, timedelta, timezone

import pytest
from sqlalchemy.pool import StaticPool
from sqlmodel import Session, SQLModel, create_engine, select

from vibe_modeling.backend.db_models import Sector, TaxonomyWizardState
from vibe_modeling.backend.taxonomy import saved_state
from vibe_modeling.backend.taxonomy.example import load_ridgeline_example
from vibe_modeling.backend.taxonomy.models import TaxonomyIntake, TaxonomyWizardStateIn

EX = load_ridgeline_example()
T0 = datetime(2026, 10, 23, 9, 0, tzinfo=timezone.utc)


@pytest.fixture
def session():
    engine = create_engine("sqlite://", connect_args={"check_same_thread": False}, poolclass=StaticPool)
    SQLModel.metadata.create_all(engine)
    with Session(engine) as s:
        yield s


def _state(revision=0, **kw) -> TaxonomyWizardStateIn:
    kw.setdefault("step", 1)
    kw.setdefault("intake", TaxonomyIntake(company_name="Ridgeline Energy", industry="Utility"))
    return TaxonomyWizardStateIn(revision=revision, **kw)


def test_nothing_saved_loads_none(session):
    assert saved_state.load(session, "a@x.com", now=T0) is None


def test_save_then_load_round_trips_every_part(session):
    data = _state(step=2, strictness="guided", tree=EX.tree, sections={"company": EX.sections["company"]})
    out = saved_state.save(session, "a@x.com", data, now=T0)
    assert out.revision == 1
    loaded = saved_state.load(session, "a@x.com", now=T0)
    assert loaded is not None
    assert loaded == out
    assert (loaded.step, loaded.strictness) == (2, "guided")
    assert loaded.intake == data.intake
    assert loaded.tree == EX.tree
    assert loaded.sections == {"company": EX.sections["company"]}
    assert loaded.updated_at == T0 and loaded.updated_at.tzinfo is not None
    assert loaded.expires_at == T0 + saved_state.SAVED_TTL


def test_unfinished_parts_save_as_empty(session):
    saved_state.save(session, "a@x.com", _state(step=1), now=T0)
    row = session.exec(select(TaxonomyWizardState)).one()
    assert row.tree_json is None and row.sections_json is None
    loaded = saved_state.load(session, "a@x.com", now=T0)
    assert loaded is not None and loaded.tree is None and loaded.sections == {}


def test_each_save_bumps_the_revision_and_the_expiry(session):
    saved_state.save(session, "a@x.com", _state(0), now=T0)
    later = T0 + timedelta(days=3)
    out = saved_state.save(session, "a@x.com", _state(1, step=3, tree=EX.tree), now=later)
    assert (out.revision, out.step) == (2, 3)
    assert out.expires_at == later + saved_state.SAVED_TTL
    assert len(session.exec(select(TaxonomyWizardState)).all()) == 1


def test_save_from_an_older_revision_is_stale_and_writes_nothing(session):
    saved_state.save(session, "a@x.com", _state(0, step=1), now=T0)
    saved_state.save(session, "a@x.com", _state(1, step=2), now=T0)  # the other tab
    with pytest.raises(saved_state.StaleRevision) as exc:
        saved_state.save(session, "a@x.com", _state(1, step=3), now=T0)
    assert exc.value.current == 2
    loaded = saved_state.load(session, "a@x.com", now=T0)
    assert loaded is not None and (loaded.revision, loaded.step) == (2, 2)


def test_first_save_when_another_tab_already_saved_is_stale(session):
    saved_state.save(session, "a@x.com", _state(0), now=T0)
    with pytest.raises(saved_state.StaleRevision) as exc:
        saved_state.save(session, "a@x.com", _state(0, step=3), now=T0)
    assert exc.value.current == 1
    assert len(session.exec(select(TaxonomyWizardState)).all()) == 1


def test_save_after_a_discard_elsewhere_is_stale_with_revision_zero(session):
    saved_state.save(session, "a@x.com", _state(0), now=T0)
    assert saved_state.discard(session, "a@x.com") is True
    with pytest.raises(saved_state.StaleRevision) as exc:
        saved_state.save(session, "a@x.com", _state(1), now=T0)
    assert exc.value.current == 0
    assert saved_state.save(session, "a@x.com", _state(0), now=T0).revision == 1


def test_discard_when_nothing_is_saved(session):
    assert saved_state.discard(session, "a@x.com") is False


def test_owners_are_isolated(session):
    saved_state.save(session, "a@x.com", _state(0, step=1), now=T0)
    saved_state.save(session, "b@x.com", _state(0, step=3), now=T0)
    a, b = saved_state.load(session, "a@x.com", now=T0), saved_state.load(session, "b@x.com", now=T0)
    assert a is not None and b is not None and (a.step, b.step) == (1, 3)
    assert saved_state.discard(session, "b@x.com") is True
    assert saved_state.load(session, "a@x.com", now=T0) is not None
    assert saved_state.load(session, "b@x.com", now=T0) is None


def test_expired_rows_are_purged_on_load(session):
    saved_state.save(session, "a@x.com", _state(0), now=T0)
    just_before = T0 + saved_state.SAVED_TTL - timedelta(seconds=1)
    assert saved_state.load(session, "a@x.com", now=just_before) is not None
    after = T0 + saved_state.SAVED_TTL + timedelta(seconds=1)
    assert saved_state.load(session, "a@x.com", now=after) is None
    assert session.exec(select(TaxonomyWizardState)).all() == []


def test_expired_rows_of_every_owner_are_purged_on_save(session):
    saved_state.save(session, "old@x.com", _state(0), now=T0)
    later = T0 + saved_state.SAVED_TTL + timedelta(minutes=1)
    saved_state.save(session, "a@x.com", _state(0), now=later)
    owners = [r.owner for r in session.exec(select(TaxonomyWizardState)).all()]
    assert owners == ["a@x.com"]


def test_save_onto_an_expired_own_row_starts_from_revision_zero(session):
    saved_state.save(session, "a@x.com", _state(0), now=T0)
    later = T0 + saved_state.SAVED_TTL + timedelta(minutes=1)
    with pytest.raises(saved_state.StaleRevision) as exc:
        saved_state.save(session, "a@x.com", _state(1), now=later)
    assert exc.value.current == 0


def test_sector_is_kept_when_it_exists_and_dropped_when_it_does_not(session):
    sector = Sector(name="Energy")
    session.add(sector)
    session.commit()
    out = saved_state.save(session, "a@x.com", _state(0, sector_id=sector.id), now=T0)
    assert out.sector_id == sector.id
    out = saved_state.save(session, "a@x.com", _state(1, sector_id="gone"), now=T0)
    assert out.sector_id is None


def test_unknown_section_key_is_refused_by_the_model():
    with pytest.raises(ValueError, match="unknown section keys: nope"):
        _state(sections={"nope": EX.sections["company"]})


@pytest.mark.parametrize("step", [-1, 4])
def test_step_out_of_range_is_refused_by_the_model(step):
    with pytest.raises(ValueError):
        _state(step=step)


def test_a_document_over_the_cap_is_refused_and_writes_nothing(session, monkeypatch):
    monkeypatch.setattr(saved_state, "MAX_DOCUMENT_BYTES", 2_000)
    big = TaxonomyIntake(company_name="Ridgeline Energy", industry="Utility", pasted_doc="x" * 3_000)
    with pytest.raises(saved_state.DocumentTooLarge):
        saved_state.save(session, "a@x.com", _state(0, intake=big), now=T0)
    assert session.exec(select(TaxonomyWizardState)).all() == []
    assert saved_state.save(session, "a@x.com", _state(0), now=T0).revision == 1


def test_the_save_response_is_the_written_document(session):
    data = _state(step=2, tree=EX.tree, sections={"company": EX.sections["company"]})
    out = saved_state.save(session, "a@x.com", data, now=T0)
    assert out == saved_state.load(session, "a@x.com", now=T0)


@pytest.fixture
def fk_session():
    """SQLite with foreign keys enforced, as Postgres does."""
    from sqlalchemy import event

    engine = create_engine("sqlite://", connect_args={"check_same_thread": False}, poolclass=StaticPool)
    event.listen(engine, "connect", lambda conn, _: conn.execute("PRAGMA foreign_keys=ON"))
    SQLModel.metadata.create_all(engine)
    with Session(engine) as s:
        yield s


@pytest.mark.parametrize("based_on", [0, 1])
def test_a_sector_deleted_between_the_check_and_the_write_saves_as_none(fk_session, monkeypatch, based_on):
    if based_on:
        saved_state.save(fk_session, "a@x.com", _state(0), now=T0)
    real = saved_state._sector_or_none
    calls = []

    def racy(session, sector_id):
        calls.append(sector_id)
        return sector_id if len(calls) == 1 else real(session, sector_id)  # the check saw it; then it was deleted

    monkeypatch.setattr(saved_state, "_sector_or_none", racy)
    out = saved_state.save(fk_session, "a@x.com", _state(based_on, sector_id="gone"), now=T0)
    assert len(calls) == 2  # the write failed on the FK and the state was read again
    assert out.sector_id is None and out.revision == based_on + 1
    row = fk_session.exec(select(TaxonomyWizardState)).one()
    assert row.sector_id is None and row.revision == based_on + 1

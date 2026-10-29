"""Test the shared bulk model-tree I/O module (services/_bulk_model_io.py).

Two kinds of coverage:

1. Equivalence: an introspection-driven fixture populates every
   business-content column of Domain/Product/Attribute/ForeignKeyLink with
   sentinel values, runs ``copy_model_tree`` (the SQLite/ORM fallback, since
   the test engine is SQLite), and asserts the copy matches the source
   row-for-row modulo remapped ids and the three deliberately-reset columns
   (``created_at`` / ``previous_element_id`` / ``subdomain_id``). Walking
   table metadata rather than hardcoding field names means this can't go
   stale on a schema change.
2. Structural: asserts the column list the Postgres bulk-SQL path would
   generate (``_copy_columns``) equals table metadata minus the same
   reset/remap sets the ORM path uses - the single shared helper both
   dialect branches call, so they cannot silently drift from each other.
3. Compile: builds the actual Core INSERT...SELECT statements the Postgres
   path executes (``_domain_copy_insert``/``_product_copy_insert``/
   ``_attribute_copy_insert``/``_fk_link_copy_insert``) and compiles them
   against the ``postgresql`` dialect. ``Domain.references`` and
   ``Attribute.references`` are a genuine Postgres reserved word (the
   ``REFERENCES`` keyword in FK syntax) - an f-string-interpolated raw SQL
   statement referencing it unquoted is a syntax error on real Postgres,
   which is exactly what shipped and was only caught in live fork
   verification, because the equivalence/structural tests above only ever
   exercise the SQLite ORM fallback and never compile the Postgres SQL.
"""

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

from datetime import datetime, timezone

import sqlalchemy as sa
from sqlalchemy.dialects import postgresql
from sqlmodel import Session, select

from vibe_modeling.backend.db_models import (
    Attribute,
    Business,
    Domain,
    ForeignKeyLink,
    ModelVersion,
    Product,
)
from vibe_modeling.backend.services._bulk_model_io import (
    _PRODUCT_RESET_COLUMNS,
    _RESET_COLUMNS,
    _attribute_copy_insert,
    _copy_columns,
    _domain_copy_insert,
    _fk_link_copy_insert,
    _product_copy_insert,
    _temp_map_table,
    bulk_delete_version_elements,
    bulk_insert_elements,
    copy_model_tree,
)


def _make_business_and_versions(session: Session) -> tuple[str, str]:
    biz = Business(name="bulk-io-test-biz", kind="business")
    session.add(biz)
    session.flush()
    src = ModelVersion(business_id=biz.id, version=1, status="completed")
    tgt = ModelVersion(business_id=biz.id, version=2, status="draft")
    session.add(src)
    session.add(tgt)
    session.flush()
    return src.id, tgt.id


def _sentinel_value(column, tag: str):
    """A non-default sentinel for a column's Python type, tagged so two
    calls never collide (guards against a false-positive column match).

    Datetime columns are recognized by their SQL type: newer sqlmodel wraps
    them in a ``TypeDecorator`` whose ``python_type`` is not implemented."""
    if isinstance(getattr(column.type, "impl", column.type), sa.DateTime):
        return datetime(2020, 1, 1, tzinfo=timezone.utc)
    try:
        py_type = column.type.python_type
    except (AttributeError, NotImplementedError):
        py_type = str
    if py_type is bool:
        return True
    if py_type in (int, float):
        return 42
    return f"sentinel-{tag}"


def _fill_sentinels(obj, *, exclude: set[str]):
    for c in obj.__table__.columns:
        if c.name in exclude:
            continue
        setattr(obj, c.name, _sentinel_value(c, f"{obj.__table__.name}-{c.name}"))


def test_copy_model_tree_equivalence(engine):
    """Every business-content column round-trips through the ORM fallback
    copy unchanged; the three reset columns and all ids are NOT copied."""
    with Session(engine) as session:
        src_version_id, tgt_version_id = _make_business_and_versions(session)

        domain = Domain(version_id=src_version_id)
        _fill_sentinels(domain, exclude={"id", "version_id"})
        session.add(domain)
        session.flush()

        product = Product(domain_id=domain.id, version_id=src_version_id)
        _fill_sentinels(product, exclude={"id", "domain_id", "version_id"})
        session.add(product)
        session.flush()

        attribute = Attribute(product_id=product.id)
        _fill_sentinels(attribute, exclude={"id", "product_id"})
        session.add(attribute)

        fk_link = ForeignKeyLink(version_id=src_version_id)
        _fill_sentinels(fk_link, exclude={"id", "version_id"})
        session.add(fk_link)
        session.flush()

        counts = copy_model_tree(
            session, source_version_id=src_version_id, target_version_id=tgt_version_id
        )
        assert counts == {"domains": 1, "products": 1, "attributes": 1, "fk_links": 1}

        new_domain = session.exec(
            select(Domain).where(Domain.version_id == tgt_version_id)
        ).one()
        new_product = session.exec(
            select(Product).where(Product.version_id == tgt_version_id)
        ).one()
        new_attribute = session.exec(
            select(Attribute).where(Attribute.product_id == new_product.id)
        ).one()
        new_fk_link = session.exec(
            select(ForeignKeyLink).where(ForeignKeyLink.version_id == tgt_version_id)
        ).one()

        # Fresh ids, correctly re-parented.
        assert new_domain.id != domain.id
        assert new_product.id != product.id
        assert new_product.domain_id == new_domain.id
        assert new_attribute.id != attribute.id
        assert new_attribute.product_id == new_product.id
        assert new_fk_link.id != fk_link.id

        for col in _copy_columns(Domain, exclude=_RESET_COLUMNS, remap={"version_id"}):
            assert getattr(new_domain, col) == getattr(domain, col), col
        for col in _copy_columns(
            Product, exclude=_PRODUCT_RESET_COLUMNS, remap={"version_id", "domain_id"}
        ):
            assert getattr(new_product, col) == getattr(product, col), col
        for col in _copy_columns(Attribute, exclude=_RESET_COLUMNS, remap={"product_id"}):
            assert getattr(new_attribute, col) == getattr(attribute, col), col
        for col in _copy_columns(ForeignKeyLink, exclude=_RESET_COLUMNS, remap={"version_id"}):
            assert getattr(new_fk_link, col) == getattr(fk_link, col), col

        # Reset columns are NOT carried over from the source's sentinel values.
        assert new_domain.created_at != domain.created_at
        assert new_domain.previous_element_id is None
        assert new_product.previous_element_id is None
        assert new_product.subdomain_id is None
        assert new_attribute.previous_element_id is None
        assert new_fk_link.previous_element_id is None


def test_bulk_delete_version_elements_orm_fallback(engine):
    """SQLite fallback deletes every element row for the version, leaving
    other versions untouched - same outcome as the pre-existing per-row
    ``_delete_existing`` loop it replaces."""
    with Session(engine) as session:
        v1, v2 = _make_business_and_versions(session)

        d1 = Domain(version_id=v1, name="d1")
        session.add(d1)
        session.flush()
        p1 = Product(domain_id=d1.id, version_id=v1, name="p1")
        session.add(p1)
        session.flush()
        session.add(Attribute(product_id=p1.id, name="a1"))
        session.add(ForeignKeyLink(version_id=v1, source_domain="d1"))

        d2 = Domain(version_id=v2, name="d2")
        session.add(d2)
        session.flush()

        session.flush()

        bulk_delete_version_elements(session, v1)

        assert session.exec(select(Domain).where(Domain.version_id == v1)).all() == []
        assert session.exec(select(Product).where(Product.version_id == v1)).all() == []
        assert session.exec(
            select(ForeignKeyLink).where(ForeignKeyLink.version_id == v1)
        ).all() == []
        remaining_domains = session.exec(select(Domain)).all()
        assert [d.id for d in remaining_domains] == [d2.id]


def test_bulk_insert_elements_orm_fallback(engine):
    """SQLite fallback writes every object passed in, ids already assigned
    before the call (no DB round trip needed to learn a parent id)."""
    with Session(engine) as session:
        v1, _ = _make_business_and_versions(session)

        domain = Domain(version_id=v1, name="d1")
        product = Product(domain_id=domain.id, version_id=v1, name="p1")
        attribute = Attribute(product_id=product.id, name="a1")
        fk_link = ForeignKeyLink(version_id=v1, source_domain="d1")

        bulk_insert_elements(
            session,
            domains=[domain],
            products=[product],
            attributes=[attribute],
            fk_links=[fk_link],
        )

        assert session.exec(select(Domain).where(Domain.id == domain.id)).one()
        assert session.exec(select(Product).where(Product.id == product.id)).one()
        assert session.exec(select(Attribute).where(Attribute.id == attribute.id)).one()
        assert session.exec(select(ForeignKeyLink).where(ForeignKeyLink.id == fk_link.id)).one()


def test_copy_columns_structural_parity():
    """The column list both dialect branches of ``copy_model_tree`` build
    from (the Postgres INSERT...SELECT column list and the ORM fallback's
    kwarg list) come from the SAME ``_copy_columns`` helper - so a future
    schema change can't add a column to one path and silently miss the
    other. This asserts the helper's output against table metadata
    directly, independent of which dialect branch runs."""
    domain_cols = set(_copy_columns(Domain, exclude=_RESET_COLUMNS, remap={"version_id"}))
    all_domain_cols = {c.name for c in Domain.__table__.columns}
    assert domain_cols == all_domain_cols - _RESET_COLUMNS - {"version_id"}

    product_cols = set(
        _copy_columns(Product, exclude=_PRODUCT_RESET_COLUMNS, remap={"version_id", "domain_id"})
    )
    all_product_cols = {c.name for c in Product.__table__.columns}
    assert product_cols == all_product_cols - _PRODUCT_RESET_COLUMNS - {"version_id", "domain_id"}

    attribute_cols = set(_copy_columns(Attribute, exclude=_RESET_COLUMNS, remap={"product_id"}))
    all_attribute_cols = {c.name for c in Attribute.__table__.columns}
    assert attribute_cols == all_attribute_cols - _RESET_COLUMNS - {"product_id"}

    fk_link_cols = set(_copy_columns(ForeignKeyLink, exclude=_RESET_COLUMNS, remap={"version_id"}))
    all_fk_link_cols = {c.name for c in ForeignKeyLink.__table__.columns}
    assert fk_link_cols == all_fk_link_cols - _RESET_COLUMNS - {"version_id"}


def test_references_is_a_reserved_word_regression_trap():
    """``references`` (on ``Domain`` and ``Attribute``) is kept in this
    fixture set FOREVER as a deliberate regression trap: it is a genuine
    Postgres reserved word (the ``REFERENCES`` keyword used in
    ``REFERENCES <table>`` FK syntax), so an unquoted raw-SQL column
    reference to it is a syntax error on real Postgres. This test asserts
    that fact explicitly so nobody "cleans up" the fixture by renaming the
    column away from a reserved word - doing so would silently gut the
    compile tests below of the one case they exist to catch."""
    assert "references" in {c.name for c in Domain.__table__.columns}
    assert "references" in {c.name for c in Attribute.__table__.columns}

    preparer = postgresql.dialect().preparer(postgresql.dialect())
    assert preparer._requires_quotes("references") is True


def test_postgres_copy_statements_compile_with_reserved_word_column():
    """Every Core INSERT...SELECT statement the Postgres copy path builds
    must actually compile against the ``postgresql`` dialect, and the
    compiled SQL must double-quote the reserved-word ``references`` column -
    the exact failure this module shipped with (an f-string interpolating
    ``references`` unquoted into raw SQL, a syntax error on real Postgres)
    is impossible here because Core construction routes every identifier
    through the dialect's own quoting logic."""
    domain_map = _temp_map_table("_bulk_domain_map")
    product_map = _temp_map_table("_bulk_product_map")

    dialect = postgresql.dialect()

    compiled_domain = str(_domain_copy_insert(domain_map).compile(dialect=dialect))
    compiled_product = str(_product_copy_insert(domain_map, product_map).compile(dialect=dialect))
    compiled_attribute = str(_attribute_copy_insert(product_map).compile(dialect=dialect))
    compiled_fk_link = str(_fk_link_copy_insert().compile(dialect=dialect))

    assert '"references"' in compiled_domain
    assert '"references"' in compiled_attribute
    # Sanity: Product/ForeignKeyLink carry no reserved-word column, so their
    # compiled SQL never needs to quote "references" at all.
    assert "references" not in compiled_product
    assert "references" not in compiled_fk_link

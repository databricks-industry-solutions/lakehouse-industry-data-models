"""Drift lock between the ON DELETE rule sources and the ``db_models`` ``ondelete=`` pairing.

Two migrations hold ON DELETE rules for FKs on tables that existed before them:
``FK_RULES`` (``migrations/v_0_6_6.py``, re-points live Postgres constraints) and
``SET_NULL_FKS`` (``migrations/v_0_9_0.py``, adds the FK columns inline). Tables a
migration creates from the final models (``db_models.ASSESS_TABLES`` in ``v_0_8_0``,
``v_0_9_0.NEW_TABLES``, ``v_0_9_0_1.NEW_TABLES``) take their rules from ``db_models`` directly. Fresh installs
(both dialects) take every rule from ``db_models`` via ``create_all``. The test reads
SQLAlchemy metadata (``fk.ondelete``) rather than source, so it survives however the
FK is spelled in the model.
"""

from __future__ import annotations

from sqlmodel import SQLModel

import vibe_modeling.backend.db_models  # noqa: F401 - registers tables on metadata
from vibe_modeling.backend.db_models import ASSESS_TABLES
from vibe_modeling.backend.migrations.v_0_6_6 import FK_RULES, SELF_FK_INDEX_COLUMNS
from vibe_modeling.backend.migrations.v_0_9_0 import NEW_TABLES as V_0_9_0_TABLES, SET_NULL_FKS
from vibe_modeling.backend.migrations.v_0_9_0_1 import NEW_TABLES as V_0_9_0_1_TABLES


def _normalise(action: str | None) -> str | None:
    if action is None:
        return None
    return " ".join(action.upper().split())


def _ondelete_for(child: str, column: str) -> tuple[str | None, str | None]:
    """Return ``(ondelete, referred_table)`` for the single-column FK on
    ``child.column`` from SQLAlchemy metadata, or ``(None, None)`` if absent."""
    table = SQLModel.metadata.tables[child]
    for fkc in table.foreign_key_constraints:
        cols = [c.name for c in fkc.columns]
        if cols == [column]:
            referred = list(fkc.elements)[0].column.table.name
            return _normalise(fkc.ondelete), referred
    return None, None


# Tables whose FKs come straight from the final models (create_all in their migration).
_MODEL_BUILT_TABLES = {t.__tablename__ for t in ASSESS_TABLES} | set(V_0_9_0_TABLES) | set(V_0_9_0_1_TABLES)


def _rule_sources() -> dict[tuple[str, str], list[tuple[str, str, str]]]:
    """``(child, column) -> [(source, parent, action), ...]`` over both rule lists."""
    rules: dict[tuple[str, str], list[tuple[str, str, str]]] = {}
    for child, column, parent, action in FK_RULES:
        rules.setdefault((child, column), []).append(("FK_RULES", parent, action))
    for child, column, parent in SET_NULL_FKS:
        rules.setdefault((child, column), []).append(("SET_NULL_FKS", parent, "SET NULL"))
    return rules


def test_every_on_delete_rule_source_matches_db_models_both_ways():
    """Rules to models: every rule names a db_models FK with that parent and action.
    Models to rules: every db_models FK with an ``ondelete`` is in exactly one rule
    list, or on a table its migration built from the final models."""
    rules = _rule_sources()
    problems = [f"{k} listed twice: {v}" for k, v in rules.items() if len(v) > 1]
    for (child, column), [(source, parent, action), *_] in rules.items():
        found_action, referred = _ondelete_for(child, column)
        if found_action != _normalise(action) or referred != parent:
            problems.append(
                f"{source} {child}.{column} -> expected {parent} ON DELETE {action}, "
                f"got {referred} ON DELETE {found_action}"
            )
    for table in SQLModel.metadata.sorted_tables:
        for fkc in table.foreign_key_constraints:
            column = [c.name for c in fkc.columns][0]
            if fkc.ondelete and (table.name, column) not in rules and table.name not in _MODEL_BUILT_TABLES:
                problems.append(
                    f"{table.name}.{column} ON DELETE {fkc.ondelete} is in no rule list "
                    "(add it to the migration that introduces it)"
                )
    assert not problems, "ON DELETE rule drift:\n" + "\n".join(problems)


def test_no_action_anchors_stay_no_action():
    """The deliberate NO-ACTION guards must NOT carry an ondelete (they are
    absent from FK_RULES on purpose - the design's 'Keep NO ACTION' table)."""
    no_action = [
        ("businesses", "industry_id"),
        ("businesses", "sector_id"),
        ("vibe_input_context_links", "domain_id"),
        ("vibe_input_context_links", "subdomain_id"),
        ("vibe_input_context_links", "product_id"),
        ("vibe_input_context_links", "attribute_id"),
        ("vibe_input_context_links", "fk_link_id"),
    ]
    for child, column in no_action:
        found_action, _referred = _ondelete_for(child, column)
        assert found_action is None, (
            f"{child}.{column} should stay NO ACTION but carries "
            f"ON DELETE {found_action}"
        )


def test_self_fk_index_columns_indexed_in_db_models():
    """Every column the migration indexes (`SELF_FK_INDEX_COLUMNS`) must also
    carry an index in db_models, so fresh installs (create_all) and existing
    installs (migration) converge. Locks the sibling-omission class: a SET NULL
    self-FK added without an index on the child column is a seq-scan trap.
    """
    missing = []
    for table_name, column in SELF_FK_INDEX_COLUMNS:
        table = SQLModel.metadata.tables[table_name]
        indexed_single_cols = {
            list(ix.columns)[0].name
            for ix in table.indexes
            if len(ix.columns) == 1
        }
        # A single-column Field(index=True) also sets Column.index; accept either.
        col_index = table.columns[column].index
        if column not in indexed_single_cols and not col_index:
            missing.append(f"{table_name}.{column}")
    assert not missing, (
        "SET NULL self-FK columns indexed by the migration but NOT by db_models "
        f"(fresh installs would miss the index): {missing}"
    )

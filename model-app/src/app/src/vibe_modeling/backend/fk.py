"""Element-identity / foreign-key serialization boundary.

This module is the single home for forming the read/display FQN and for
parsing the unstructured ``Attribute.foreign_key_to`` string. Every surface
that needs to know "is this attribute an FK", "how many FKs are here", or
"what does this FK point at" routes through here, so the FK-presence predicate
is defined exactly once. It has no intra-package dependencies, so any module
(``explorer``, ``diagram``, ``evolution_metrics``, ``model_sync``) can import
it without creating an import cycle.

NOTE (fk-target parsing): the ideal fix resolves an attribute's FK target to
structured ids + fqn at model-sync time (model.json → Lakebase) so read-time
parsing disappears. That was deferred because sync-time resolution has
forward-reference edge cases (an FK can target a product that hasn't been
synced yet within the same run); doing it safely needs a second resolve pass
after all products land. Until then this ONE parser is the single call path —
no ad-hoc ``split(".")`` remain.
"""

from collections.abc import Iterable
from typing import NamedTuple, Optional


def build_fqn(*parts: str) -> str:
    """Join element name parts into the canonical dot-FQN — the single source
    of the separator + ordering at this serialization boundary."""
    return ".".join(parts)


def product_fqn(domain_name: str, product_name: str) -> str:
    """The canonical product FQN ``"<domain>.<product>"`` — the shape the FE's
    ``selected_node_id`` / the diagram node id / the ``table:`` scope use."""
    return build_fqn(domain_name, product_name)


def fk_edge_id(source_node: str, source_column: str,
               target_node: str, target_column: str) -> str:
    """The diagram's FK edge id ``fk:<src_node>.<src_col>><tgt_node>.<tgt_col>``.

    Nodes are product FQNs. ``source_column`` is the source attribute's
    ``column_name`` (what the diagram draws); ``target_column`` is the column
    named in ``foreign_key_to``. The FE echoes the id back as
    ``selected_edge_id``; :func:`parse_fk_edge_id` reads it."""
    return f"fk:{source_node}.{source_column}>{target_node}.{target_column}"


def parse_fk_edge_id(
    edge_id: str,
) -> Optional[tuple[str, str, Optional[str], str, str, Optional[str]]]:
    """Parse an :func:`fk_edge_id` into ``(src_domain, src_product, src_column,
    tgt_domain, tgt_product, tgt_column)``. A side without a column gives None
    for it; an id that doesn't parse gives None."""
    if not edge_id.startswith("fk:") or ">" not in edge_id:
        return None
    src_part, tgt_part = edge_id[3:].split(">", 1)
    src_bits = src_part.split(".", 2)
    tgt_bits = tgt_part.split(".", 2)
    if len(src_bits) < 2 or len(tgt_bits) < 2:
        return None
    return (
        src_bits[0], src_bits[1], src_bits[2] if len(src_bits) == 3 else None,
        tgt_bits[0], tgt_bits[1], tgt_bits[2] if len(tgt_bits) == 3 else None,
    )


class FkTarget(NamedTuple):
    """Parsed ``foreign_key_to`` target. ``domain`` is ``None`` for the 2-part
    ``"table.column"`` shape (the caller then infers the domain)."""

    domain: Optional[str]
    table: str
    column: str


def parse_fk_target(fk_to: str) -> Optional[FkTarget]:
    """Parse an attribute's ``foreign_key_to`` into ``(domain, table, column)``.

    Accepts ``"domain.table.column"`` (3-part) and ``"table.column"`` (2-part,
    ``domain=None``); returns ``None`` for empty/malformed (<2-part). The single
    parser for every FK-target consumer."""
    if not fk_to:
        return None
    parts = fk_to.split(".")
    if len(parts) >= 3:
        return FkTarget(domain=parts[0], table=parts[1], column=parts[2])
    if len(parts) == 2:
        return FkTarget(domain=None, table=parts[0], column=parts[1])
    return None


def is_fk_attribute(attr: dict) -> bool:
    """Whether an attribute is a foreign key — the single FK-presence predicate.

    True iff its ``foreign_key_to`` parses to a structured target (≥2 parts).
    A non-empty-but-unparseable string (e.g. a single token with no ``.``) is
    NOT an FK. Because every counting/flagging surface routes through this one
    predicate, a malformed target is treated identically everywhere — the old
    truthy-``foreign_key_to``-vs-``parse_fk_target`` divergence cannot
    reappear."""
    return parse_fk_target(attr.get("foreign_key_to", "")) is not None


def count_fk_attributes(attributes: Iterable[dict]) -> int:
    """The single definition of "how many FK attributes" for an attribute
    iterable — used by every FK total (model summary, domain detail, deleted
    products, diagram nodes, evolution-metrics size) so they can never drift."""
    return sum(1 for a in attributes if is_fk_attribute(a))


def fk_target_keys(attributes: list[dict]) -> set[str]:
    """The set of target product keys an attribute list references.

    Each ``foreign_key_to`` is parsed via the canonical ``parse_fk_target``;
    a 3-part target yields the ``"<domain>.<table>"`` product FQN (what the
    ontology graph matches against node ids), a 2-part target yields
    ``"<table>.<column>"`` (the historical first-two-parts shape)."""
    keys: set[str] = set()
    for a in attributes:
        target = parse_fk_target(a.get("foreign_key_to", ""))
        if target is None:
            continue
        if target.domain is not None:
            keys.add(product_fqn(target.domain, target.table))
        else:
            keys.add(build_fqn(target.table, target.column))
    return keys

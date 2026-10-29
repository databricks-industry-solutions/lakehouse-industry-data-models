"""Anchor resolution: decode a FeedbackContext's name-based selection and
resolve it to element FK ids within a specific model version.

Callers:

- **Live capture** (``resolve_feedback_anchor``): the "Add Feedback" dialog
  passes the name-context it has (the FE holds element names, not DB ids: the
  explorer Out projections and the cached diagram layout are name-keyed). The
  create endpoint resolves it against the version the caller is viewing, so the
  input anchors to the exact element on that version.
- **Natural-key re-anchor** (``capture_named_anchor`` / ``resolve_named_anchor``):
  the kickstart clone and the force-resync teardown both capture a context
  link's anchor by element name and resolve it against a rewritten version.

The resolver never raises and never drops: an all-null result is a legal
model-wide anchor. A coordinate that degrades below its intended level flags
``needs_link_review`` so the re-link queue can surface it.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Optional

from sqlmodel import Session, select

from ..db_models import Attribute, Domain, ForeignKeyLink, Product, Subdomain
from ..fk import fk_edge_id, parse_fk_edge_id, product_fqn
from ..models import FeedbackContext

# An FK's natural key: (source_domain, source_product, source_column,
# target_domain, target_product, target_column), the ForeignKeyLink columns.
# source_column is the source attribute's NAME (what model sync stores). A
# column may be None when the caller doesn't know it; then only the four
# names match (see _resolve_fk).
FkKey = tuple[str, str, Optional[str], str, str, Optional[str]]


@dataclass
class _AnchorFKs:
    domain_id: Optional[str] = None
    subdomain_id: Optional[str] = None
    product_id: Optional[str] = None
    attribute_id: Optional[str] = None
    fk_link_id: Optional[str] = None
    needs_link_review: bool = False


@dataclass
class _Coords:
    """Decoded anchor coordinates (names) from a FeedbackContext or scope.

    ``intended_model_wide`` distinguishes a genuine model-wide anchor
    (scope=model / no selection) from a fallback that landed model-wide
    because nothing resolved — only the latter flags needs_link_review.
    """

    domain_name: Optional[str] = None
    product_name: Optional[str] = None
    attribute_name: Optional[str] = None
    # A diagram edge (parse_fk_edge_id): an FkKey shape whose source column is
    # the attribute's column_name, translated to its name before matching.
    fk_edge: Optional[FkKey] = None
    intended_model_wide: bool = False


def _coords_from_feedback_context(ctx: FeedbackContext) -> _Coords:
    """Decode anchor coordinates from a FeedbackContext. A context with no
    node/edge/domain selector decodes to an explicit model-wide anchor."""
    if ctx.selected_node_id:
        parts = ctx.selected_node_id.split(".", 1)
        if len(parts) == 2:
            return _Coords(
                domain_name=parts[0],
                product_name=parts[1],
                attribute_name=ctx.selected_attribute or None,
            )
        return _Coords(domain_name=parts[0])
    if ctx.selected_edge_id:
        fk_edge = parse_fk_edge_id(ctx.selected_edge_id)
        if fk_edge is not None:
            return _Coords(fk_edge=fk_edge)
        return _Coords(intended_model_wide=False)  # unparseable edge → model-wide fallback
    if ctx.domain_filter:
        return _Coords(domain_name=ctx.domain_filter)
    return _Coords(intended_model_wide=True)


def _resolve_domain(session: Session, version_id: str, name: str) -> Optional[str]:
    return session.exec(
        select(Domain.id).where(Domain.version_id == version_id, Domain.name == name)
    ).first()


def _resolve_product(session: Session, version_id: str, domain_id: str, name: str) -> Optional[str]:
    pid = session.exec(
        select(Product.id).where(
            Product.version_id == version_id,
            Product.domain_id == domain_id,
            Product.name == name,
        )
    ).first()
    if pid is not None:
        return pid
    # selected_node_id can carry the physical table name — try table_name.
    return session.exec(
        select(Product.id).where(
            Product.version_id == version_id,
            Product.domain_id == domain_id,
            Product.table_name == name,
        )
    ).first()


def _resolve_fk(
    session: Session,
    version_id: str,
    key: FkKey,
    maps: Optional["AnchorMaps"] = None,
) -> Optional[str]:
    """The one FK in ``version_id`` with natural key ``key``.

    With both columns known, only the exact six-name match counts: a product
    pair can carry several FKs (child / parent / root to the same table). With
    a column unknown, the four names must match exactly one FK; several give
    None, so the caller degrades with ``needs_link_review`` instead of picking
    one."""
    src_d, src_p, src_c, tgt_d, tgt_p, tgt_c = key
    if src_c is not None and tgt_c is not None:
        if maps is not None:
            return maps.fk_links.get(key)
        return session.exec(
            select(ForeignKeyLink.id).where(
                ForeignKeyLink.version_id == version_id,
                ForeignKeyLink.source_domain == src_d,
                ForeignKeyLink.source_product == src_p,
                ForeignKeyLink.source_column == src_c,
                ForeignKeyLink.target_domain == tgt_d,
                ForeignKeyLink.target_product == tgt_p,
                ForeignKeyLink.target_column == tgt_c,
            ).order_by(ForeignKeyLink.id)
        ).first()
    ids = session.exec(
        select(ForeignKeyLink.id).where(
            ForeignKeyLink.version_id == version_id,
            ForeignKeyLink.source_domain == src_d,
            ForeignKeyLink.source_product == src_p,
            ForeignKeyLink.target_domain == tgt_d,
            ForeignKeyLink.target_product == tgt_p,
        )
    ).all()
    return ids[0] if len(ids) == 1 else None


def _fk_key_from_edge(session: Session, version_id: str, edge: FkKey) -> FkKey:
    """Translate a diagram edge's source column (the attribute's
    ``column_name``) to the attribute name ForeignKeyLink stores. Kept as is
    when no attribute has that column_name."""
    src_d, src_p, src_c, tgt_d, tgt_p, tgt_c = edge
    if src_c is None:
        return edge
    dom = _resolve_domain(session, version_id, src_d)
    if dom is None:
        return edge
    prod = _resolve_product(session, version_id, dom, src_p)
    if prod is None:
        return edge
    name = session.exec(
        select(Attribute.name).where(
            Attribute.product_id == prod, Attribute.column_name == src_c,
        ).order_by(Attribute.id)
    ).first()
    return (src_d, src_p, name or src_c, tgt_d, tgt_p, tgt_c)


def fk_link_edge_ids(session: Session, fks: list[ForeignKeyLink]) -> dict[str, str]:
    """``{fk_link_id: diagram edge id}`` for ``fks``, the id the diagram gives
    the same relationship (source column = the source attribute's
    ``column_name``). One query for all of them."""
    if not fks:
        return {}
    versions = {fk.version_id for fk in fks}
    names = {fk.source_column for fk in fks}
    column_names: dict[tuple[str, str, str, str], str] = {}
    for version_id, d_name, p_name, a_name, col in session.exec(
        select(Product.version_id, Domain.name, Product.name, Attribute.name, Attribute.column_name)
        .join(Product, Product.id == Attribute.product_id)
        .join(Domain, Domain.id == Product.domain_id)
        .where(Product.version_id.in_(versions), Attribute.name.in_(names))
    ):
        if col:
            column_names.setdefault((version_id, d_name, p_name, a_name), col)
    return {
        fk.id: fk_edge_id(
            product_fqn(fk.source_domain, fk.source_product),
            column_names.get(
                (fk.version_id, fk.source_domain, fk.source_product, fk.source_column),
                fk.source_column,
            ),
            product_fqn(fk.target_domain, fk.target_product),
            fk.target_column,
        )
        for fk in fks
    }


def _resolve_attribute(
    session: Session,
    product_id: str,
    name: str,
    maps: Optional["AnchorMaps"] = None,
) -> Optional[str]:
    if maps is not None:
        return maps.attributes.get((product_id, name))
    return session.exec(
        select(Attribute.id).where(
            Attribute.product_id == product_id,
            Attribute.name == name,
        )
    ).first()


def _resolve_coords(
    session: Session,
    version_id: str,
    coords: _Coords,
    maps: Optional["AnchorMaps"] = None,
) -> _AnchorFKs:
    """Resolve decoded coordinates to element FKs in ``version_id``, walking UP
    to the deepest resolvable ancestor when a coordinate doesn't resolve.

    ``maps`` is an optional prefetched :class:`AnchorMaps` (from
    :func:`prefetch_anchor_maps`): when given, every lookup below resolves via
    an in-memory dict instead of a session query, for callers resolving many
    coordinates against the same version. Omit it (the default) for the
    original one-off, session-backed resolution - the same convention
    :func:`resolve_named_anchor` already uses.
    """
    if coords.intended_model_wide:
        return _AnchorFKs()  # exact model-wide → no review

    domain_name = coords.domain_name
    product_name = coords.product_name
    # A coordinate that degrades below its intended level flags review. The
    # fk path is the only case where an EXACT lower-level resolution is still
    # a fallback (intended fk → resolved product/domain), so track it.
    fk_fallback = False

    if coords.fk_edge is not None:
        key = _fk_key_from_edge(session, version_id, coords.fk_edge)
        fk_id = _resolve_fk(session, version_id, key, maps)
        if fk_id is not None:
            return _AnchorFKs(fk_link_id=fk_id)
        # Fall through to the SOURCE side product/domain — this is a fallback.
        fk_fallback = True
        domain_name = coords.fk_edge[0]
        product_name = coords.fk_edge[1]

    if product_name is not None:
        if domain_name is None:
            return _AnchorFKs(needs_link_review=True)
        dom = (
            maps.domains.get(domain_name)
            if maps is not None
            else _resolve_domain(session, version_id, domain_name)
        )
        if dom is None:
            return _AnchorFKs(needs_link_review=True)  # domain unresolvable → model-wide
        if maps is not None:
            prod = maps.products_any.get((dom, product_name))
            if prod is None:
                # selected_node_id can carry the physical table name — try it,
                # mirroring _resolve_product's table_name fallback.
                prod = maps.products_by_table_name.get((dom, product_name))
        else:
            prod = _resolve_product(session, version_id, dom, product_name)
        if prod is None:
            return _AnchorFKs(domain_id=dom, needs_link_review=True)  # fallback → domain
        if coords.attribute_name:
            attr = _resolve_attribute(session, prod, coords.attribute_name, maps)
            if attr is None:
                # fallback → product
                return _AnchorFKs(domain_id=dom, product_id=prod, needs_link_review=True)
            return _AnchorFKs(domain_id=dom, product_id=prod, attribute_id=attr)
        return _AnchorFKs(domain_id=dom, product_id=prod, needs_link_review=fk_fallback)

    if domain_name is not None:
        dom = (
            maps.domains.get(domain_name)
            if maps is not None
            else _resolve_domain(session, version_id, domain_name)
        )
        if dom is not None:
            return _AnchorFKs(domain_id=dom, needs_link_review=fk_fallback)
        return _AnchorFKs(needs_link_review=True)  # fallback → model-wide

    return _AnchorFKs()


def resolve_feedback_anchor(session: Session, version_id: str,
                            ctx: FeedbackContext) -> _AnchorFKs:
    """Live entry: resolve a FeedbackContext's name-based selection to element
    FKs in ``version_id`` (the version the user is viewing)."""
    return _resolve_coords(session, version_id, _coords_from_feedback_context(ctx))


# --- Natural-key re-anchor (subdomain + attribute aware) ---------------------
#
# Two callers solve the same old-name -> new-id problem within a rewritten
# version: kickstart clones a version and re-anchors its inputs onto the clone
# (``services/industry_kickstart``), and force-resync tears down and rebuilds a
# version's elements while the ``ModelVersion`` row survives
# (``model_sync._delete_existing``). Both capture each context link's anchor by
# element NAME(s) from the OLD rows, then resolve those names against the NEW
# same-version rows. This carries the subdomain axis that ``_resolve_coords``
# (live capture) deliberately does not, while reusing its element-level
# primitives (``_resolve_domain``/``_resolve_fk``/``_resolve_attribute``).


@dataclass
class NamedAnchor:
    """A context link's anchor captured by element NAME(s), version-independent."""

    domain_name: Optional[str] = None
    subdomain_name: Optional[str] = None
    product_name: Optional[str] = None
    attribute_name: Optional[str] = None
    fk_parts: Optional[FkKey] = None

    def is_model_wide(self) -> bool:
        return not any((
            self.domain_name, self.subdomain_name, self.product_name,
            self.attribute_name, self.fk_parts,
        ))


def capture_named_anchor(
    session: Session, link, maps: Optional["IdNameMaps"] = None,
) -> NamedAnchor:
    """Read a context link's current element-id anchors back to their NAMES.

    Walks up the tree so a product-only or attribute-only anchor still recovers
    its domain (and subdomain) name. An all-null link yields an all-null
    :class:`NamedAnchor` (a genuine model-wide anchor).

    ``maps`` is an optional prefetched :class:`IdNameMaps` (from
    :func:`prefetch_id_name_maps`): when given, every id -> name lookup below
    resolves via an in-memory dict instead of a ``session.get`` point read,
    for callers capturing many links against the same version. Omit it (the
    default) for the original one-off, session-backed lookup. A missing id in
    ``maps`` behaves identically to ``session.get`` returning ``None`` (the
    row is gone) - the resolved name stays unset."""
    domain_name = subdomain_name = product_name = attribute_name = None
    fk_parts: Optional[FkKey] = None

    if link.domain_id:
        if maps is not None:
            domain_name = maps.domain_names.get(link.domain_id)
        else:
            d = session.get(Domain, link.domain_id)
            domain_name = d.name if d else None
    if link.subdomain_id:
        if maps is not None:
            subdomain_name = maps.subdomain_names.get(link.subdomain_id)
        else:
            sd = session.get(Subdomain, link.subdomain_id)
            subdomain_name = sd.name if sd else None
    if link.product_id:
        if maps is not None:
            prod = maps.products.get(link.product_id)
            if prod is not None:
                product_name, p_domain_id, p_subdomain_id = prod
                if domain_name is None and p_domain_id:
                    domain_name = maps.domain_names.get(p_domain_id)
                if subdomain_name is None and p_subdomain_id:
                    subdomain_name = maps.subdomain_names.get(p_subdomain_id)
        else:
            p = session.get(Product, link.product_id)
            if p:
                product_name = p.name
                if domain_name is None and p.domain_id:
                    pd = session.get(Domain, p.domain_id)
                    domain_name = pd.name if pd else None
                if subdomain_name is None and p.subdomain_id:
                    psd = session.get(Subdomain, p.subdomain_id)
                    subdomain_name = psd.name if psd else None
    if link.attribute_id:
        if maps is not None:
            attr = maps.attributes.get(link.attribute_id)
            if attr is not None:
                attribute_name, a_product_id = attr
                if product_name is None:
                    ap = maps.products.get(a_product_id)
                    if ap is not None:
                        product_name, ap_domain_id, ap_subdomain_id = ap
                        if domain_name is None and ap_domain_id:
                            domain_name = maps.domain_names.get(ap_domain_id)
                        if subdomain_name is None and ap_subdomain_id:
                            subdomain_name = maps.subdomain_names.get(ap_subdomain_id)
        else:
            a = session.get(Attribute, link.attribute_id)
            if a:
                attribute_name = a.name
                if product_name is None:
                    ap = session.get(Product, a.product_id)
                    if ap:
                        product_name = ap.name
                        if domain_name is None and ap.domain_id:
                            ad = session.get(Domain, ap.domain_id)
                            domain_name = ad.name if ad else None
                        if subdomain_name is None and ap.subdomain_id:
                            asd = session.get(Subdomain, ap.subdomain_id)
                            subdomain_name = asd.name if asd else None
    if link.fk_link_id:
        if maps is not None:
            fk_parts = maps.fk_links.get(link.fk_link_id)
        else:
            fk = session.get(ForeignKeyLink, link.fk_link_id)
            if fk:
                fk_parts = (
                    fk.source_domain, fk.source_product, fk.source_column,
                    fk.target_domain, fk.target_product, fk.target_column,
                )

    return NamedAnchor(
        domain_name=domain_name,
        subdomain_name=subdomain_name,
        product_name=product_name,
        attribute_name=attribute_name,
        fk_parts=fk_parts,
    )


@dataclass
class IdNameMaps:
    """Per-version id -> name(+parent id) maps for :func:`capture_named_anchor`,
    built by :func:`prefetch_id_name_maps`.

    Companion to :class:`AnchorMaps` (name -> id, used by
    :func:`resolve_named_anchor` on the REBUILD/resolve side): this is the
    reverse direction, id -> name, used by ``capture_named_anchor`` on the
    CAPTURE side to snapshot a link's CURRENT element ids as names without a
    point read per link. A capture loop over many links used to have each
    call issue its own ``session.get`` round trips (up to five per link,
    walking up the tree); building this once per version turns that into
    five SELECTs total, with the capture itself done as in-memory dict
    lookups.
    """

    domain_names: dict[str, str] = field(default_factory=dict)
    subdomain_names: dict[str, str] = field(default_factory=dict)
    # product_id -> (name, domain_id, subdomain_id)
    products: dict[str, tuple[str, Optional[str], Optional[str]]] = field(default_factory=dict)
    # attribute_id -> (name, product_id)
    attributes: dict[str, tuple[str, str]] = field(default_factory=dict)
    # fk_link_id -> its FkKey (six names)
    fk_links: dict[str, FkKey] = field(default_factory=dict)


def prefetch_id_name_maps(session: Session, version_id: str) -> IdNameMaps:
    """Build the :class:`IdNameMaps` for ``version_id`` with one SELECT per
    element table (domains/subdomains/products/attributes/fk_links)."""
    maps = IdNameMaps()
    for id_, name in session.exec(
        select(Domain.id, Domain.name).where(Domain.version_id == version_id)
    ):
        maps.domain_names[id_] = name
    for id_, name in session.exec(
        select(Subdomain.id, Subdomain.name).where(Subdomain.version_id == version_id)
    ):
        maps.subdomain_names[id_] = name
    for id_, name, domain_id, subdomain_id in session.exec(
        select(Product.id, Product.name, Product.domain_id, Product.subdomain_id).where(
            Product.version_id == version_id
        )
    ):
        maps.products[id_] = (name, domain_id, subdomain_id)
    for id_, name, product_id in session.exec(
        select(Attribute.id, Attribute.name, Attribute.product_id)
        .join(Product, Product.id == Attribute.product_id)
        .where(Product.version_id == version_id)
    ):
        maps.attributes[id_] = (name, product_id)
    for id_, src_d, src_p, src_c, tgt_d, tgt_p, tgt_c in session.exec(
        select(
            ForeignKeyLink.id, ForeignKeyLink.source_domain, ForeignKeyLink.source_product,
            ForeignKeyLink.source_column, ForeignKeyLink.target_domain,
            ForeignKeyLink.target_product, ForeignKeyLink.target_column,
        ).where(ForeignKeyLink.version_id == version_id)
    ):
        maps.fk_links[id_] = (src_d, src_p, src_c, tgt_d, tgt_p, tgt_c)
    return maps


@dataclass
class AnchorMaps:
    """Per-version name -> id maps for :func:`resolve_named_anchor`, built by
    :func:`prefetch_anchor_maps`.

    A re-anchor loop resolving many :class:`NamedAnchor` values against the
    same ``version_id`` used to have each call issue its own point lookups
    (one round trip per anchor per element table). Building this once per
    version and passing it into every :func:`resolve_named_anchor` call
    turns that into five SELECTs total, with the resolution itself done as
    in-memory dict lookups. The key shapes mirror exactly what the
    session-backed lookups below query on, so passing ``maps`` changes HOW
    an anchor resolves, never WHAT it resolves to.
    """

    domains: dict[str, str] = field(default_factory=dict)
    subdomains: dict[tuple[str, str], str] = field(default_factory=dict)
    products_by_subdomain: dict[tuple[str, str, str], str] = field(default_factory=dict)
    products_any: dict[tuple[str, str], str] = field(default_factory=dict)
    # (domain_id, table_name) -> product_id — mirrors _resolve_product's
    # table_name fallback for the maps-backed path of _resolve_coords.
    products_by_table_name: dict[tuple[str, str], str] = field(default_factory=dict)
    attributes: dict[tuple[str, str], str] = field(default_factory=dict)
    # FkKey (six names) -> id, for _resolve_fk's exact match.
    fk_links: dict[FkKey, str] = field(default_factory=dict)


def prefetch_anchor_maps(session: Session, version_id: str) -> AnchorMaps:
    """Build the :class:`AnchorMaps` for ``version_id`` with one SELECT per
    element table (domains/subdomains/products/attributes/fk_links).

    ``products_by_subdomain`` keys on ``(domain_id, subdomain_id, name)`` for
    the subdomain-scoped lookup ``resolve_named_anchor`` tries first;
    ``products_any`` keys on ``(domain_id, name)`` (first match, any
    subdomain) for its fallback, matching the two-step query the session
    path runs.
    """
    maps = AnchorMaps()
    for name, id_ in session.exec(
        select(Domain.name, Domain.id).where(Domain.version_id == version_id)
    ):
        maps.domains[name] = id_
    for domain_id, name, id_ in session.exec(
        select(Subdomain.domain_id, Subdomain.name, Subdomain.id).where(
            Subdomain.version_id == version_id
        )
    ):
        maps.subdomains[(domain_id, name)] = id_
    for domain_id, subdomain_id, name, table_name, id_ in session.exec(
        select(
            Product.domain_id, Product.subdomain_id, Product.name,
            Product.table_name, Product.id,
        ).where(Product.version_id == version_id)
    ):
        maps.products_any.setdefault((domain_id, name), id_)
        if subdomain_id is not None:
            maps.products_by_subdomain[(domain_id, subdomain_id, name)] = id_
        if table_name is not None:
            maps.products_by_table_name.setdefault((domain_id, table_name), id_)
    for product_id, name, id_ in session.exec(
        select(Attribute.product_id, Attribute.name, Attribute.id)
        .join(Product, Product.id == Attribute.product_id)
        .where(Product.version_id == version_id)
    ):
        maps.attributes[(product_id, name)] = id_
    for src_d, src_p, src_c, tgt_d, tgt_p, tgt_c, id_ in session.exec(
        select(
            ForeignKeyLink.source_domain, ForeignKeyLink.source_product,
            ForeignKeyLink.source_column, ForeignKeyLink.target_domain,
            ForeignKeyLink.target_product, ForeignKeyLink.target_column,
            ForeignKeyLink.id,
        ).where(ForeignKeyLink.version_id == version_id).order_by(ForeignKeyLink.id)
    ):
        maps.fk_links.setdefault((src_d, src_p, src_c, tgt_d, tgt_p, tgt_c), id_)
    return maps


def resolve_named_anchor(
    session: Session,
    version_id: str,
    named: NamedAnchor,
    maps: Optional[AnchorMaps] = None,
) -> _AnchorFKs:
    """Resolve a :class:`NamedAnchor` to element FKs in ``version_id``.

    Degrades UP the hierarchy (attribute -> product -> domain -> model-wide)
    like the canonical resolver, flagging ``needs_link_review`` when a
    coordinate lands below its captured level.

    ``maps`` is an optional prefetched :class:`AnchorMaps` (from
    :func:`prefetch_anchor_maps`): when given, every lookup below resolves
    via an in-memory dict instead of a session query, for callers resolving
    many anchors against the same version. Omit it (the default) for the
    original one-off, session-backed resolution.
    """
    if named.is_model_wide():
        return _AnchorFKs()

    domain_name = named.domain_name
    product_name = named.product_name
    review = False

    if named.fk_parts is not None:
        fk_id = _resolve_fk(session, version_id, named.fk_parts, maps)
        if fk_id is not None:
            return _AnchorFKs(fk_link_id=fk_id)
        review = True
        domain_name = domain_name or named.fk_parts[0]
        product_name = product_name or named.fk_parts[1]

    dom_id = None
    if domain_name:
        dom_id = (
            maps.domains.get(domain_name)
            if maps is not None
            else _resolve_domain(session, version_id, domain_name)
        )
        if dom_id is None:
            return _AnchorFKs(needs_link_review=True)  # domain gone -> model-wide

    sub_id = None
    if dom_id and named.subdomain_name:
        if maps is not None:
            sub_id = maps.subdomains.get((dom_id, named.subdomain_name))
        else:
            sub_id = session.exec(
                select(Subdomain.id).where(
                    Subdomain.version_id == version_id,
                    Subdomain.domain_id == dom_id,
                    Subdomain.name == named.subdomain_name,
                )
            ).first()

    prod_id = None
    if product_name and dom_id:
        if maps is not None:
            if sub_id is not None:
                prod_id = maps.products_by_subdomain.get((dom_id, sub_id, product_name))
            if prod_id is None:
                prod_id = maps.products_any.get((dom_id, product_name))
        else:
            base = select(Product.id).where(
                Product.version_id == version_id,
                Product.domain_id == dom_id,
                Product.name == product_name,
            )
            if sub_id is not None:
                prod_id = session.exec(base.where(Product.subdomain_id == sub_id)).first()
            if prod_id is None:
                prod_id = session.exec(base).first()
    if product_name and prod_id is None:
        return _AnchorFKs(domain_id=dom_id, subdomain_id=sub_id, needs_link_review=True)

    attr_id = None
    if named.attribute_name and prod_id:
        attr_id = _resolve_attribute(session, prod_id, named.attribute_name, maps)
        if attr_id is None:
            review = True  # attribute gone -> degrade to product

    return _AnchorFKs(
        domain_id=dom_id,
        subdomain_id=sub_id,
        product_id=prod_id,
        attribute_id=attr_id,
        needs_link_review=review,
    )

"""Pure structural diff of two model dicts — no DB, no session, no I/O.

The single home for "compare two model versions -> change-status maps". Consumes
the dict shape produced by BOTH explorer._load_model (carries "name" on every
element) AND model_export.export_model_json / a raw repo model.json (carries
"product"/"attribute", NO "name"). Identity is normalized at read so the two
shapes diff identically. Imports only the OpenAPI output models + the FK
serialization boundary, so any module can import it without an import cycle.
"""

from .fk import count_fk_attributes, product_fqn
from .models import AttributeOut, ChangeStatus, DomainSummaryOut, ProductSummaryOut


def _product_key(p: dict) -> str:
    return p.get("name") or p.get("product") or ""


def _attr_key(a: dict) -> str:
    return a.get("name") or a.get("attribute") or ""


def _same_type(a, b, case_sensitive: bool) -> bool:
    if case_sensitive or not isinstance(a, str) or not isinstance(b, str):
        return a == b
    return a.casefold() == b.casefold()


def compute_model_diff(
    old_model: dict | None, new_model: dict, *, type_case_sensitive: bool = True,
) -> dict:
    """Compare two model versions and return change status maps.

    An attribute is modified when its type, ``foreign_key_to`` or the first
    100 characters of its description differ. ``type_case_sensitive=False``
    ignores a case-only type change (``string`` vs ``STRING``).

    Returns a dict with:
      - domains: {name: ChangeStatus}
      - products: {(domain, product): ChangeStatus}
      - attributes: {(domain, product, attr): ChangeStatus}
      - deleted_domains: [DomainSummaryOut, ...]
      - deleted_products: {domain: [ProductSummaryOut, ...]}
      - deleted_attributes: {(domain, product): [AttributeOut, ...]}
    """
    if not old_model:
        return {"domains": {}, "products": {}, "attributes": {},
                "deleted_domains": [], "deleted_products": {}, "deleted_attributes": {}}

    # Index old model
    old_domains = {}
    old_products = {}  # (domain, product) -> product dict
    old_attrs = {}     # (domain, product, attr) -> attr dict
    for d in old_model.get("domains", []):
        dn = d.get("name", "")
        old_domains[dn] = d
        for p in d.get("products", []):
            pn = _product_key(p)
            old_products[(dn, pn)] = p
            for a in p.get("attributes", []):
                an = _attr_key(a)
                old_attrs[(dn, pn, an)] = a

    # Index new model
    new_domains = {}
    new_products = {}
    new_attrs = {}
    for d in new_model.get("domains", []):
        dn = d.get("name", "")
        new_domains[dn] = d
        for p in d.get("products", []):
            pn = _product_key(p)
            new_products[(dn, pn)] = p
            for a in p.get("attributes", []):
                an = _attr_key(a)
                new_attrs[(dn, pn, an)] = a

    domain_status = {}
    product_status = {}
    attr_status = {}

    # Attribute-level changes
    for key, a in new_attrs.items():
        if key not in old_attrs:
            attr_status[key] = ChangeStatus.NEW
        else:
            old_a = old_attrs[key]
            if (not _same_type(a.get("type"), old_a.get("type"), type_case_sensitive) or
                a.get("foreign_key_to") != old_a.get("foreign_key_to") or
                a.get("description", "")[:100] != old_a.get("description", "")[:100]):
                attr_status[key] = ChangeStatus.MODIFIED

    # Product-level changes
    for key, p in new_products.items():
        dn, pn = key
        if key not in old_products:
            product_status[key] = ChangeStatus.NEW
        else:
            # Check if any child attrs changed
            has_child_changes = any(
                attr_status.get((dn, pn, _attr_key(a)))
                for a in p.get("attributes", [])
            )
            has_deleted_attrs = any(
                k not in new_attrs for k in old_attrs if k[0] == dn and k[1] == pn
            )
            if has_child_changes or has_deleted_attrs:
                product_status[key] = ChangeStatus.MODIFIED

    # Domain-level changes
    for dn, d in new_domains.items():
        if dn not in old_domains:
            domain_status[dn] = ChangeStatus.NEW
        else:
            has_child_changes = any(
                product_status.get((dn, _product_key(p)))
                for p in d.get("products", [])
            )
            has_deleted_products = any(
                k not in new_products for k in old_products if k[0] == dn
            )
            if has_child_changes or has_deleted_products:
                domain_status[dn] = ChangeStatus.MODIFIED

    # Deleted items
    deleted_domains = []
    for dn, d in old_domains.items():
        if dn not in new_domains:
            deleted_domains.append(DomainSummaryOut(
                name=dn, division=d.get("division", ""),
                description=d.get("description", ""),
                product_count=len(d.get("products", [])),
                change_status=ChangeStatus.DELETED,
            ))

    deleted_products: dict[str, list] = {}
    for (dn, pn), p in old_products.items():
        if dn in new_domains and (dn, pn) not in new_products:
            if dn not in deleted_products:
                deleted_products[dn] = []
            attrs = p.get("attributes", [])
            deleted_products[dn].append(ProductSummaryOut(
                fqn=product_fqn(dn, pn),
                name=pn, table_name=p.get("table_name", pn),
                description=p.get("description", ""),
                attribute_count=len(attrs), fk_count=count_fk_attributes(attrs),
                change_status=ChangeStatus.DELETED,
            ))

    deleted_attributes: dict[tuple, list] = {}
    for (dn, pn, an), a in old_attrs.items():
        if (dn, pn) in new_products and (dn, pn, an) not in new_attrs:
            key = (dn, pn)
            if key not in deleted_attributes:
                deleted_attributes[key] = []
            deleted_attributes[key].append(AttributeOut(
                name=an, column_name=a.get("column_name", an),
                type=a.get("type", ""), description=a.get("description", ""),
                change_status=ChangeStatus.DELETED,
            ))

    return {
        "domains": domain_status,
        "products": product_status,
        "attributes": attr_status,
        "deleted_domains": deleted_domains,
        "deleted_products": deleted_products,
        "deleted_attributes": deleted_attributes,
    }

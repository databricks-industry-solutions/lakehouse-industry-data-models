"""Independent parity check for a scoped (or strict All Domains) vibe modeling of version run.

It compares a base model.json with the model.json the run wrote and lists every difference outside the scope.
It does not import the agent or the fence: the scope test and the delta rules below are written from the
contract in design-guide.md (Vibe Scope Semantics), so a fence bug cannot hide itself.

A difference outside the scope is accepted only when the run declared it in _vibe_scope.permitted_deltas and
the change has the declared shape:
  P1  an existing FK column gets a new foreign_key_to that points at an in-scope product;
  P2  an existing FK column has its foreign_key_to cleared and keeps every other field;
  P3  an existing unlinked column gets a foreign_key_to to a product the run created in scope;
  P4  a new column on an out-of-scope product whose foreign_key_to points into the scope;
  P5  an out-of-scope metric view whose SQL changed (only the names substitution is allowed).

Live use: set VS_PARITY_BASE and VS_PARITY_NEW to the two model.json paths, VS_PARITY_MODE to domains,
subdomains or requested, and VS_PARITY_ENTRIES to the scope entries (for requested runs, the entries of
_vibe_scope in the new model.json are used when VS_PARITY_ENTRIES is empty).
"""
import copy
import json
import os
import re
from pathlib import Path

import pytest

_HOUSEKEEPING = {"version", "agent_version", "release_version", "_vibe_scope", "lineage", "entity_changes",
                 "input_outcomes", "_vibe_session_metadata"}


def _norm(name):
    return re.sub(r"[^a-z0-9]", "", str(name or "").lower())


_KEY_ALIASES = {"references": "reference"}
_SERIALIZER_DEFAULTS = {"nullable": True, "is_nullable": True}


def _canon(record, drop=()):
    """The record as the contract sees it: a key the serializer adds with an empty or default value, or renames
    (references -> reference), is not a change."""
    out = {}
    for key, value in (record or {}).items():
        if key in drop:
            continue
        key = _KEY_ALIASES.get(key, key)
        if value is None or value == "" or value == [] or value == {} or value is False:
            continue
        if key in _SERIALIZER_DEFAULTS and value == _SERIALIZER_DEFAULTS[key]:
            continue
        out[key] = value
    return out


def _root(model):
    return model.get("model") if isinstance(model.get("model"), dict) else model


def _products(model):
    out = {}
    for dom in _root(model).get("domains") or []:
        for prod in dom.get("products") or dom.get("data_products") or []:
            out[(_norm(dom.get("name")), _norm(prod.get("name")))] = (dom, prod)
    return out


def _attr_name(attr):
    return str(attr.get("name") or attr.get("attribute") or "")


def _fk(attr):
    return str(attr.get("foreign_key_to") or "").strip()


def _fk_product(fk):
    parts = [p for p in str(fk or "").split(".") if p]
    return (_norm(parts[0]), _norm(parts[1])) if len(parts) >= 2 else None


class Scope:
    def __init__(self, mode, entries):
        self.mode = mode
        self.domains, self.subdomains, self.products = set(), set(), set()
        for entry in entries:
            parts = [p for p in str(entry).split(".") if p]
            if not parts:
                continue
            if mode == "domains" or len(parts) == 1:
                self.domains.add(_norm(parts[0]))
            elif mode == "subdomains":
                self.subdomains.add((_norm(parts[0]), _norm(parts[1])))
            else:
                self.products.add((_norm(parts[0]), _norm(parts[1])))

    def product_in(self, dkey, pkey, subdomain):
        if dkey in self.domains:
            return True
        if self.mode == "subdomains":
            return (dkey, _norm(subdomain)) in self.subdomains
        return (dkey, pkey) in self.products

    def domain_record_in(self, dkey):
        return dkey in self.domains


def _declared(new_model):
    deltas = {}
    for item in ((new_model.get("_vibe_scope") or {}).get("permitted_deltas") or []):
        path = item.get("path") or item.get("view_name") or ".".join(str(item.get(k) or "") for k in ("domain", "product", "attribute") if item.get(k))
        deltas.setdefault(str(path or ""), set()).add(str(item.get("kind") or ""))
    return deltas


def compare(base_model, new_model, scope):
    """Return the list of unexplained differences outside the scope (empty when the run kept its fence)."""
    problems = []
    declared = _declared(new_model)
    base_p, new_p = _products(base_model), _products(new_model)
    created_in_scope = {k for k, (dom, prod) in new_p.items() if k not in base_p and scope.product_in(k[0], k[1], prod.get("subdomain"))}

    renamed_from = {}
    for event in ((new_model.get("_vibe_scope") or {}).get("rename_ledger") or []):
        old, target = _fk_product(event.get("old")), _fk_product(event.get("new"))
        if event.get("kind") in ("product", "move") and old in base_p and target:
            renamed_from[target] = old

    def _in_scope(key, rec):
        old = renamed_from.get(key)
        if old is not None and scope.product_in(old[0], old[1], base_p[old][1].get("subdomain")):
            return True
        return rec is not None and scope.product_in(key[0], key[1], rec[1].get("subdomain"))

    def _points_in(fk):
        key = _fk_product(fk)
        if key is None:
            return False
        return _in_scope(key, new_p.get(key) or base_p.get(key))

    base_domains = {_norm(d.get("name")): d for d in _root(base_model).get("domains") or []}
    new_domains = {_norm(d.get("name")): d for d in _root(new_model).get("domains") or []}
    for dkey, bdom in base_domains.items():
        if scope.domain_record_in(dkey):
            continue
        ndom = new_domains.get(dkey)
        if ndom is None:
            problems.append(f"domain {bdom.get('name')} is missing")
            continue
        strip = lambda d: _canon(d, drop=("products", "data_products", "subdomains", "association_edges"))
        if strip(bdom) != strip(ndom):
            changed = sorted(k for k in set(strip(bdom)) | set(strip(ndom)) if strip(bdom).get(k) != strip(ndom).get(k))
            problems.append(f"domain record {bdom.get('name')} changed: {changed}")
    for dkey in new_domains:
        if dkey not in base_domains and not scope.domain_record_in(dkey) and not any(k[0] == dkey for k in created_in_scope):
            problems.append(f"new domain {new_domains[dkey].get('name')} outside the scope")

    for key, (bdom, bprod) in base_p.items():
        if scope.product_in(key[0], key[1], bprod.get("subdomain")):
            continue
        path = f"{bdom.get('name')}.{bprod.get('name')}"
        if key not in new_p:
            problems.append(f"out-of-scope product {path} is missing")
            continue
        nprod = new_p[key][1]
        brow = _canon(bprod, drop=("attributes",))
        nrow = _canon(nprod, drop=("attributes",))
        if brow != nrow:
            changed = sorted(k for k in set(brow) | set(nrow) if brow.get(k) != nrow.get(k))
            problems.append(f"out-of-scope product {path} changed fields {changed}")
        battrs = {_norm(_attr_name(a)): a for a in bprod.get("attributes") or []}
        nattrs = {_norm(_attr_name(a)): a for a in nprod.get("attributes") or []}
        for akey, battr in battrs.items():
            apath = f"{path}.{_attr_name(battr)}"
            nattr = nattrs.get(akey)
            if nattr is None:
                problems.append(f"out-of-scope column {apath} is missing")
                continue
            if _canon(battr) == _canon(nattr):
                continue
            rest_b = _canon(battr, drop=("foreign_key_to",))
            rest_n = _canon(nattr, drop=("foreign_key_to",))
            kinds = declared.get(apath, set())
            if rest_b != rest_n:
                changed = sorted(k for k in set(rest_b) | set(rest_n) if rest_b.get(k) != rest_n.get(k))
                problems.append(f"out-of-scope column {apath} changed fields {changed}")
            elif _fk(battr) and not _fk(nattr):
                if "P2" not in kinds:
                    problems.append(f"out-of-scope FK {apath} cleared without a declared P2")
            elif _fk(battr) and _fk(nattr):
                if "P1" not in kinds or not _points_in(_fk(nattr)):
                    problems.append(f"out-of-scope FK {apath} re-pointed {_fk(battr)} -> {_fk(nattr)} without a valid P1")
            elif not _fk(battr) and _fk(nattr):
                if "P3" not in kinds or _fk_product(_fk(nattr)) not in created_in_scope:
                    problems.append(f"out-of-scope column {apath} linked to {_fk(nattr)} without a valid P3")
        for akey, nattr in nattrs.items():
            if akey in battrs:
                continue
            apath = f"{path}.{_attr_name(nattr)}"
            if "P4" not in declared.get(apath, set()) or not _points_in(_fk(nattr)):
                problems.append(f"new column {apath} on an out-of-scope product without a valid P4")
        if [k for k in battrs if k in nattrs] != [k for k in nattrs if k in battrs]:
            problems.append(f"out-of-scope product {path} column order changed")

    for key, (ndom, nprod) in new_p.items():
        if key not in base_p and not _in_scope(key, (ndom, nprod)):
            problems.append(f"new product {ndom.get('name')}.{nprod.get('name')} outside the scope")

    base_mvs = {_norm(mv.get("view_name") or mv.get("name")): mv for mv in _root(base_model).get("metric_views") or []}
    new_mvs = {_norm(mv.get("view_name") or mv.get("name")): mv for mv in _root(new_model).get("metric_views") or []}
    for mkey, bmv in base_mvs.items():
        owner = (_norm(bmv.get("owner_domain")), _norm(bmv.get("owner_product")))
        owner_rec = base_p.get(owner)
        in_scope = scope.domain_record_in(owner[0]) or (owner_rec is not None and scope.product_in(owner[0], owner[1], owner_rec[1].get("subdomain")))
        if in_scope:
            continue
        nmv = new_mvs.get(mkey)
        name = bmv.get("view_name") or bmv.get("name")
        if nmv is None:
            problems.append(f"out-of-scope metric view {name} is missing")
        elif _canon(bmv) != _canon(nmv):
            cb, cn = _canon(bmv), _canon(nmv)
            changed = sorted(k for k in set(cb) | set(cn) if cb.get(k) != cn.get(k))
            if changed != ["sql"] or "P5" not in declared.get(str(name), set()):
                problems.append(f"out-of-scope metric view {name} changed fields {changed}")
    return problems


def _live_inputs():
    base, new = os.environ.get("VS_PARITY_BASE"), os.environ.get("VS_PARITY_NEW")
    if not base or not new:
        return None
    base_model, new_model = json.loads(Path(base).read_text()), json.loads(Path(new).read_text())
    mode = os.environ.get("VS_PARITY_MODE") or ((new_model.get("_vibe_scope") or {}).get("mode")) or "domains"
    entries = [e.strip() for e in (os.environ.get("VS_PARITY_ENTRIES") or "").split(",") if e.strip()]
    entries = entries or list((new_model.get("_vibe_scope") or {}).get("entries") or [])
    return base_model, new_model, Scope(mode, entries)


@pytest.mark.skipif(_live_inputs() is None, reason="set VS_PARITY_BASE and VS_PARITY_NEW to compare a live run")
def test_live_run_changed_nothing_outside_its_scope():
    base_model, new_model, scope = _live_inputs()
    problems = compare(base_model, new_model, scope)
    assert problems == [], "\n".join(problems[:60])


def _base():
    return {"model": {"domains": [
        {"name": "order", "description": "Orders.", "products": [
            {"name": "sales_order", "subdomain": "oms", "primary_key": "sales_order_id", "attributes": [
                {"name": "sales_order_id", "type": "STRING"}]},
            {"name": "return_line", "subdomain": "returns", "primary_key": "return_line_id", "attributes": [
                {"name": "return_line_id", "type": "STRING"}]}]},
        {"name": "inventory", "description": "Stock.", "products": [
            {"name": "grn_line", "subdomain": "inbound", "primary_key": "grn_line_id", "attributes": [
                {"name": "grn_line_id", "type": "STRING"},
                {"name": "return_line_id", "type": "STRING", "foreign_key_to": "order.return_line.return_line_id"}]}]},
        {"name": "customer", "description": "Customers.", "products": [
            {"name": "profile", "subdomain": "identity", "primary_key": "profile_id", "attributes": [
                {"name": "profile_id", "type": "STRING"}]}]}],
        "metric_views": [{"view_name": "inventory_grn", "owner_domain": "inventory", "owner_product": "grn_line", "sql": "SELECT 1"}]}}


def _scoped_new(declare=True):
    new = json.loads(json.dumps(_base()))
    order, inventory, customer = new["model"]["domains"]
    order["products"] = [p for p in order["products"] if p["name"] != "return_line"]
    order["products"].append({"name": "order_note", "subdomain": "oms", "primary_key": "order_note_id",
                              "attributes": [{"name": "order_note_id", "type": "STRING"}]})
    inventory["products"][0]["attributes"][1]["foreign_key_to"] = ""
    customer["products"][0]["attributes"].append({"name": "preferred_sales_order_id", "type": "STRING",
                                                  "foreign_key_to": "order.sales_order.sales_order_id"})
    new["_vibe_scope"] = {"mode": "domains", "entries": ["order"], "permitted_deltas": [
        {"kind": "P2", "path": "inventory.grn_line.return_line_id"},
        {"kind": "P4", "path": "customer.profile.preferred_sales_order_id"}] if declare else []}
    return new


def test_declared_p2_and_p4_deltas_are_the_only_out_of_scope_changes():
    assert compare(_base(), _scoped_new(), Scope("domains", ["order"])) == []


def test_undeclared_boundary_changes_are_reported():
    problems = compare(_base(), _scoped_new(declare=False), Scope("domains", ["order"]))
    assert any("cleared without a declared P2" in p for p in problems)
    assert any("without a valid P4" in p for p in problems)


@pytest.mark.parametrize("mutate,needle", [
    (lambda m: m["model"]["domains"][2]["products"][0]["attributes"][0].update(description="changed"), "changed fields ['description']"),
    (lambda m: m["model"]["domains"][1]["products"][0].update(name="goods_receipt_line"), "is missing"),
    (lambda m: m["model"]["domains"][2]["products"].append({"name": "household", "attributes": []}), "outside the scope"),
    (lambda m: m["model"]["metric_views"][0].update(sql="SELECT 2"), "metric view inventory_grn changed"),
    (lambda m: m["model"]["domains"][2].update(description="Changed."), "domain record customer changed"),
])
def test_any_other_out_of_scope_change_is_reported(mutate, needle):
    new = _scoped_new()
    mutate(new)
    problems = compare(_base(), new, Scope("domains", ["order"]))
    assert any(needle in p for p in problems), problems


def test_serializer_defaults_and_key_renames_are_not_changes():
    new = json.loads(json.dumps(_base()))
    prof = new["model"]["domains"][2]["products"][0]
    prof["attributes"][0].update(nullable=True, is_nullable=True, sample_values=[], classification="", data_type="")
    prof.update(natural_keys=[], row_estimate="")
    new["model"]["domains"][2]["association_edges"] = []
    base = _base()
    base["model"]["domains"][2]["references"] = "ISO"
    new["model"]["domains"][2]["reference"] = "ISO"
    assert compare(base, new, Scope("domains", ["order"])) == []


def test_a_requested_run_freezes_every_product_it_does_not_name():
    new = json.loads(json.dumps(_base()))
    new["model"]["domains"][0]["products"][0]["attributes"].append({"name": "gift_card_id", "type": "STRING"})
    new["model"]["domains"][0]["products"][1]["attributes"].append({"name": "reason", "type": "STRING"})
    problems = compare(_base(), new, Scope("requested", ["order.sales_order"]))
    assert problems == ["new column order.return_line.reason on an out-of-scope product without a valid P4"]


def test_a_declared_p1_into_a_moved_in_scope_product_is_accepted():
    base = _base()
    profile = next(p for d in base["model"]["domains"] for p in d["products"] if p["name"] == "profile")
    profile["attributes"].append({"name": "last_order_id", "type": "STRING", "foreign_key_to": "order.sales_order.sales_order_id"})
    new = copy.deepcopy(base)
    order = next(d for d in new["model"]["domains"] if d["name"] == "order")
    moved = next(p for p in order["products"] if p["name"] == "sales_order")
    order["products"].remove(moved)
    next(d for d in new["model"]["domains"] if d["name"] == "customer")["products"].append(moved)
    pointing = [(d["name"], p["name"], a["name"]) for d in new["model"]["domains"] for p in d["products"] for a in p["attributes"]
                if str(a.get("foreign_key_to") or "").startswith("order.sales_order.")]
    for d in new["model"]["domains"]:
        for p in d["products"]:
            for a in p["attributes"]:
                if str(a.get("foreign_key_to") or "").startswith("order.sales_order."):
                    a["foreign_key_to"] = "customer.sales_order." + a["foreign_key_to"].split(".", 2)[2]
    new["_vibe_scope"] = {"rename_ledger": [{"kind": "move", "old": "order.sales_order", "new": "customer.sales_order"}],
                          "permitted_deltas": [{"kind": "P1", "path": f"{d}.{p}.{a}"} for d, p, a in pointing]}
    assert pointing == [("customer", "profile", "last_order_id")]
    problems = compare(base, new, Scope("requested", ["order.sales_order"]))
    assert not [x for x in problems if "re-pointed" in x], problems
    new["_vibe_scope"]["permitted_deltas"] = []
    assert [x for x in compare(base, new, Scope("requested", ["order.sales_order"])) if "re-pointed" in x]

"""Single-domain (focal) diagram layout — placement, four-side anchoring, and
orthogonal cross-domain routing.

Ported faithfully from the validated spike (``diagram-spikes/``:
``candidates_placement.py`` + ``candidates.py``). The pure geometry lives here;
the canonical graph-construction helpers are IMPORTED from ``diagram.py`` so this
module never forks ``_build_product_index`` / ``_collect_fk_edges`` /
``_determine_included_products`` / ``_node_size`` / ``_run_elk_layout`` /
``ELK_DOMAIN_OPTIONS`` (unify, not patch).

Scope: this is the focal view only. The overview / all-domains path
(``domain is None``) stays on the untouched ``_build_elk_graph`` /
``_extract_layout`` pipeline in ``diagram.py``.

Determinism: every domain set is sorted by name and ELK's ``randomSeed`` is
pinned, so identical input always yields identical coordinates — required for
the Lakebase layout cache to stay stable.
"""

from __future__ import annotations

import math
from collections import defaultdict

from .diagram import (
    ELK_DOMAIN_OPTIONS,
    _build_product_index,
    _collect_fk_edges,
    _determine_included_products,
    _node_size,
    _product_node_meta,
    _run_elk_layout,
)
from .fk import count_fk_attributes, fk_edge_id
from .models import (
    ChangeStatus,
    DiagramDomainGroup,
    DiagramEdge,
    DiagramLayoutOut,
    DiagramNode,
    DiagramNodePort,
)

_NORMAL = {"left": (-1.0, 0.0), "right": (1.0, 0.0), "top": (0.0, -1.0), "bottom": (0.0, 1.0)}


# ---------------------------------------------------------------------------
# Geometry primitives
# ---------------------------------------------------------------------------


def _side_of(anchor, node) -> str:
    """Which side of ``node`` the ``anchor`` point sits on."""
    x, y = anchor
    eps = 1.0
    if abs(x - node.x) <= eps:
        return "left"
    if abs(x - (node.x + node.width)) <= eps:
        return "right"
    if abs(y - node.y) <= eps:
        return "top"
    return "bottom"


def _center(n) -> tuple:
    return n.x + n.width / 2, n.y + n.height / 2


def _anchor_on_side(node, side: str, frac: float) -> tuple:
    if side == "right":
        return node.x + node.width, node.y + frac * node.height
    if side == "left":
        return node.x, node.y + frac * node.height
    if side == "top":
        return node.x + frac * node.width, node.y
    return node.x + frac * node.width, node.y + node.height  # bottom


def _endpoint_side(table, group, focal: str, focal_c: tuple, other_c: tuple) -> str:
    """Choose which table side an edge attaches to.

    Focal (hub) tables: nearest side toward the other endpoint (edges radiate all
    ways). External tables: exit BROADSIDE out of the domain's row toward the
    focal, so the line never runs under the row of sibling tables. A wide (row)
    domain exits top/bottom; a tall (column) domain exits left/right; the
    specific edge is the one facing the focal.
    """
    cx, cy = _center(table)
    if group.domain == focal:
        dx, dy = other_c[0] - cx, other_c[1] - cy
        if abs(dx) >= abs(dy):
            return "right" if dx >= 0 else "left"
        return "bottom" if dy >= 0 else "top"
    # external: broadside toward focal
    if group.width >= group.height:  # horizontal row
        return "bottom" if focal_c[1] >= cy else "top"
    return "right" if focal_c[0] >= cx else "left"  # vertical column


def _ortho_link(ps, pt, s_horiz: bool, t_horiz: bool, lane: float = 0.0) -> list:
    """Orthogonal mid-points between the two stub ends.

    Same-axis links (Z: HVH or VHV) take the ``lane`` offset on their shared
    break coordinate and stay orthogonal. Mixed-axis links (single L corner)
    must NOT be offset: shifting the corner turns the right angle into a
    diagonal, so they keep a clean corner (their parallel runs are already
    separated by the spread anchors).
    """
    if s_horiz and t_horiz:
        mx = (ps[0] + pt[0]) / 2 + lane
        return [(mx, ps[1]), (mx, pt[1])]
    if not s_horiz and not t_horiz:
        my = (ps[1] + pt[1]) / 2 + lane
        return [(ps[0], my), (pt[0], my)]
    if s_horiz:
        return [(pt[0], ps[1])]
    return [(ps[0], pt[1])]


# ---------------------------------------------------------------------------
# Cross-domain anchoring + routing
# ---------------------------------------------------------------------------


def placement_anchors(layout: DiagramLayoutOut, focal: str) -> dict:
    """``{edge.id: (side_s, offset_s, x1, y1, side_t, offset_t, x2, y2)}`` for
    every cross-domain edge, using the broadside-for-external rule then spreading
    along each chosen side so no two edges share a point.

    Offsets are the fraction (0..1) of the way along the chosen side, so the
    frontend can pin the same anchor without re-deriving the geometry.
    """
    groups = {g.domain: g for g in layout.groups}
    fg = groups.get(focal)
    if fg is None:
        return {}
    focal_c = _center(fg)
    nodes = {n.id: n for n in layout.nodes}
    node_dom = {n.id: n.domain for n in layout.nodes}

    # (node_id, side) -> [(edge_id, role, sortkey)]
    reqs: dict[tuple, list] = defaultdict(list)
    for e in layout.edges:
        sd, td = node_dom.get(e.source_node), node_dom.get(e.target_node)
        if sd == td or sd is None or td is None:
            continue
        s, t = nodes[e.source_node], nodes[e.target_node]
        scx, scy = _center(s)
        tcx, tcy = _center(t)
        s_side = _endpoint_side(s, groups[sd], focal, focal_c, (tcx, tcy))
        t_side = _endpoint_side(t, groups[td], focal, focal_c, (scx, scy))
        reqs[(e.source_node, s_side)].append(
            (e.id, "s", tcx if s_side in ("top", "bottom") else tcy)
        )
        reqs[(e.target_node, t_side)].append(
            (e.id, "t", scx if t_side in ("top", "bottom") else scy)
        )

    # (edge_id, role) -> (side, offset_frac, x, y)
    pt: dict[tuple, tuple] = {}
    for (nid, side), lst in sorted(reqs.items()):
        node = nodes[nid]
        lst.sort(key=lambda r: r[2])
        n = len(lst)
        for i, (eid, role, _k) in enumerate(lst):
            frac = (i + 1) / (n + 1)
            x, y = _anchor_on_side(node, side, frac)
            pt[(eid, role)] = (side, frac, x, y)

    out: dict[str, tuple] = {}
    for e in layout.edges:
        sp, tp = pt.get((e.id, "s")), pt.get((e.id, "t"))
        if sp and tp:
            out[e.id] = (sp[0], sp[1], sp[2], sp[3], tp[0], tp[1], tp[2], tp[3])
    return out


def orthogonal_cross_domain(
    layout: DiagramLayoutOut,
    anchors: dict,
    stub: float = 26.0,
    lane_step: float = 8.0,
    use_lanes: bool = True,
) -> dict:
    """``{edge.id: [points]}`` — cross-domain edges as orthogonal polylines from
    the given anchor map. Edges sharing a domain pair are fanned into distinct
    lanes so their breaks don't coincide. Deterministic: pairs and edges are
    sorted by id.
    """
    nodes = {nd.id: nd for nd in layout.nodes}
    node_dom = {nd.id: nd.domain for nd in layout.nodes}
    by_pair: dict[tuple, list] = defaultdict(list)
    for e in layout.edges:
        if node_dom.get(e.source_node) != node_dom.get(e.target_node) and e.id in anchors:
            by_pair[
                tuple(sorted((node_dom[e.source_node], node_dom[e.target_node])))
            ].append(e)

    polys: dict[str, list] = {}
    for _pair in sorted(by_pair):
        elist = sorted(by_pair[_pair], key=lambda e: e.id)
        m = len(elist)
        for i, e in enumerate(elist):
            lane = ((i - (m - 1) / 2) * lane_step) if use_lanes else 0.0
            _ss, _so, x1, y1, _ts, _to, x2, y2 = anchors[e.id]
            s, t = nodes[e.source_node], nodes[e.target_node]
            ss, ts = _side_of((x1, y1), s), _side_of((x2, y2), t)
            nsx, nsy = _NORMAL[ss]
            ntx, nty = _NORMAL[ts]
            ps = (x1 + nsx * stub, y1 + nsy * stub)
            pe = (x2 + ntx * stub, y2 + nty * stub)
            mids = _ortho_link(ps, pe, ss in ("left", "right"), ts in ("left", "right"), lane)
            polys[e.id] = [(x1, y1), ps, *mids, pe, (x2, y2)]
    return polys


# ---------------------------------------------------------------------------
# Per-domain placement
# ---------------------------------------------------------------------------


def _domain_table_sizes(model: dict, domain: str, keys: list, column_mode: str) -> list:
    """``[(key, w, h)]`` for a domain's tables, sized exactly like production
    (``_node_size``). ``column_mode`` threads through so keys/all boxes fit (D2).
    """
    pidx = _build_product_index(model)
    out = []
    for k in keys:
        info = pidx.get(k, {})
        if info.get("_domain") != domain:
            continue
        tn = info.get("table_name", info.get("name", ""))
        attrs = info.get("attributes", [])
        pk = info.get("primary_key", "")
        pkc = {c.strip() for c in pk.split(",") if c.strip()} if pk else set()
        w, h = _node_size(tn, len(attrs), len(pkc) + count_fk_attributes(attrs), column_mode)
        out.append((k, w, h))
    return out


def _arrange_line(
    sizes: list,
    vertical: bool,
    gap: float = 28.0,
    pad_x: float = 16.0,
    pad_top: float = 40.0,
    pad_bottom: float = 16.0,
    wrap: int = 15,
):
    """Place tables in a single row (``vertical=False``) or column
    (``vertical=True``), wrapping into multiple rows/columns past ``wrap`` tables
    (a single line of 30+ tables is unusable). Returns
    ``((box_w, box_h), {key: (x, y, w, h)})`` relative to the box origin.
    """
    coords = {}
    if not sizes:
        return (80.0, 50.0), coords
    lines = [sizes[i:i + wrap] for i in range(0, len(sizes), wrap)]
    if vertical:  # each line is a COLUMN; columns placed left to right
        x, max_h = pad_x, 0.0
        for col in lines:
            y, col_w = pad_top, max(w for _, w, _ in col)
            for k, w, h in col:
                coords[k] = (x, y, w, h)
                y += h + gap
            max_h = max(max_h, y - gap)
            x += col_w + gap
        return (x - gap + pad_x, max_h + pad_bottom), coords
    # each line is a ROW; rows stacked top to bottom
    y, max_w = pad_top, 0.0
    for row in lines:
        x, row_h = pad_x, max(h for _, _, h in row)
        for k, w, h in row:
            coords[k] = (x, y, w, h)
            x += w + gap
        max_w = max(max_w, x - gap)
        y += row_h + gap
    return (max_w + pad_x, y - gap + pad_bottom), coords


def _resolve_overlaps(
    boxes: dict, pinned: str, margin: float = 45.0, iters: int = 600
) -> None:
    """Separate overlapping domain boxes in place. Each iteration finds AABB
    overlaps (inflated by ``margin``) and pushes the colliding pair apart along
    the axis of least overlap. The pinned box (focal) never moves; the other
    takes the full push. Local, box-edge based — does not inflate the whole
    diagram.

    Cap-60 ring fallback (Increment 1 addition): the pairwise relaxation does not
    converge for very dense fan-outs within the iteration budget, and gets
    quadratically expensive. Past 60 related boxes (>61 total) we abandon the
    iterative solver and lay the related boxes on a single guaranteed-spacing
    ring around the pinned box — the ring radius is chosen so the arc spacing
    between neighbours exceeds the widest box plus the margin, which guarantees
    no residual overlaps. Deterministic: related boxes are placed in sorted-key
    order.
    """
    related = sorted(k for k in boxes if k != pinned)
    if len(related) > 60:
        _ring_fallback(boxes, pinned, related, margin)
        return

    keys = list(boxes)
    for _ in range(iters):
        moved = False
        for i in range(len(keys)):
            for j in range(i + 1, len(keys)):
                ka, kb = keys[i], keys[j]
                a, b = boxes[ka], boxes[kb]
                ox = min(a[0] + a[2], b[0] + b[2]) - max(a[0], b[0]) + margin
                oy = min(a[1] + a[3], b[1] + b[3]) - max(a[1], b[1]) + margin
                if ox <= 0 or oy <= 0:
                    continue
                moved = True
                horiz = ox < oy
                amt = ox if horiz else oy
                if horiz:
                    s = 1.0 if (b[0] + b[2] / 2) >= (a[0] + a[2] / 2) else -1.0
                else:
                    s = 1.0 if (b[1] + b[3] / 2) >= (a[1] + a[3] / 2) else -1.0
                a_pin, b_pin = ka == pinned, kb == pinned
                if a_pin and b_pin:
                    continue
                if a_pin or b_pin:
                    mover, sign = (b, s) if a_pin else (a, -s)
                    mover[0 if horiz else 1] += sign * amt
                else:
                    a[0 if horiz else 1] -= s * amt / 2
                    b[0 if horiz else 1] += s * amt / 2
        if not moved:
            return


def _ring_fallback(boxes: dict, pinned: str, related: list, margin: float) -> None:
    """Place ``related`` boxes on one ring centred on the pinned box, spaced so
    neighbours can't overlap. Pinned box stays put."""
    pb = boxes[pinned]
    pcx, pcy = pb[0] + pb[2] / 2, pb[1] + pb[3] / 2
    n = len(related)
    widest = max(max(boxes[k][2], boxes[k][3]) for k in related)
    pinned_ext = max(pb[2], pb[3]) / 2
    # Chord between neighbours must exceed (widest + margin): chord = 2 r sin(pi/n)
    step = 2 * math.pi / n
    min_chord = widest + margin
    sin_half = math.sin(step / 2) or 1e-6
    radius = max(pinned_ext + widest / 2 + margin, (min_chord / 2) / sin_half)
    for i, k in enumerate(related):
        a = -math.pi / 2 + step * i
        cx, cy = pcx + radius * math.cos(a), pcy + radius * math.sin(a)
        bw, bh = boxes[k][2], boxes[k][3]
        boxes[k] = [cx - bw / 2, cy - bh / 2, bw, bh]


def layout_one_domain(
    model: dict, domain_name: str, direction: str, prod_keys: list,
    column_mode: str = "hide", include_intra: bool = True,
):
    """Run ELK on a single domain in isolation. Returns
    ``(box_wh, coords, intra_routes)`` where ``coords = {prod_key: (x,y,w,h)}``
    relative to the domain origin and ``intra_routes = {edge_id: [points]}``
    (also relative to the domain origin).

    With ``include_intra=False`` the intra edges are omitted so ELK places every
    table in one layer (direction=DOWN -> single horizontal row, RIGHT -> single
    vertical column), making box orientation reliable.
    """
    pidx = _build_product_index(model)
    keys = [k for k in prod_keys if pidx.get(k, {}).get("_domain") == domain_name]
    table_nodes = []
    for k in keys:
        info = pidx[k]
        pn = info.get("name", "")
        tn = info.get("table_name", pn)
        attrs = info.get("attributes", [])
        pk = info.get("primary_key", "")
        pkc = {c.strip() for c in pk.split(",") if c.strip()} if pk else set()
        w, h = _node_size(tn, len(attrs), len(pkc) + count_fk_attributes(attrs), column_mode)
        table_nodes.append({"id": k, "width": w, "height": h, "labels": [{"text": tn}]})

    keyset = set(keys)
    intra_edges = []
    if include_intra:
        for e in _collect_fk_edges(model, pidx, None):
            if (
                e["source_domain"] == domain_name
                and e["target_domain"] == domain_name
                and e["source_node"] in keyset
                and e["target_node"] in keyset
            ):
                intra_edges.append({
                    "id": fk_edge_id(e["source_node"], e["source_column"], e["target_node"], e["target_column"]),
                    "sources": [e["source_node"]],
                    "targets": [e["target_node"]],
                })

    graph = {
        "id": f"domain:{domain_name}",
        "layoutOptions": {**ELK_DOMAIN_OPTIONS, "elk.direction": direction},
        "children": table_nodes,
        "edges": intra_edges,
    }
    res = _run_elk_layout(graph)
    box = (res.get("width", 0.0), res.get("height", 0.0))
    coords = {
        c["id"]: (c.get("x", 0.0), c.get("y", 0.0), c.get("width", 0.0), c.get("height", 0.0))
        for c in res.get("children", [])
    }
    routes: dict[str, list] = {}
    for e in res.get("edges", []):
        eid = e.get("id", "")
        pts = []
        for sec in e.get("sections", []):
            sp = sec.get("startPoint")
            if sp:
                pts.append((sp["x"], sp["y"]))
            for bp in sec.get("bendPoints", []):
                pts.append((bp["x"], bp["y"]))
            ep = sec.get("endPoint")
            if ep:
                pts.append((ep["x"], ep["y"]))
        if len(pts) >= 2 and eid:
            routes[eid] = pts
    return box, coords, routes


def two_phase_layout(
    model: dict,
    focal: str,
    column_mode: str,
    product_change_status: dict[tuple[str, str], ChangeStatus] | None = None,
):
    """Build the single-domain focal view with per-domain orientation + even-ring
    placement. Returns ``(DiagramLayoutOut, intra_routes)`` where
    ``intra_routes = {edge_id: [absolute points]}`` for the focal's internal
    edges.

    Each node carries the SAME frontend display metadata as the overview path
    (via the shared ``_product_node_meta`` helper): product_type (table color),
    description, per-column ports (keys/all modes), and change_status. Groups
    carry the domain ``division``.

    Even-ring placement (direction-weighting deferred — D1). Only domains within
    a tight wedge of the pure left/right axis go vertical (column); higher/lower
    domains stay horizontal rows.
    """
    change_map = product_change_status or {}
    division_by_domain = {
        d.get("name", ""): d.get("division", "") for d in model.get("domains", [])
    }
    pidx = _build_product_index(model)
    edges_f = _collect_fk_edges(model, pidx, focal)
    included = _determine_included_products(model, pidx, edges_f, focal)
    domains = sorted({pidx[k]["_domain"] for k in included})
    related = [d for d in domains if d != focal]
    n = len(related)

    side_wedge_sin = math.sin(math.radians(30))  # within 30 deg of horizontal axis
    angle, direction = {}, {focal: "DOWN"}
    for i, d in enumerate(related):
        a = -math.pi / 2 + 2 * math.pi * i / max(n, 1)
        angle[d] = a
        direction[d] = "RIGHT" if abs(math.sin(a)) <= side_wedge_sin else "DOWN"

    box, coords, routes = {}, {}, {}
    for d in domains:
        keys = [k for k in included if pidx[k]["_domain"] == d]
        if d == focal:
            box[d], coords[d], routes[d] = layout_one_domain(
                model, d, "DOWN", keys, column_mode=column_mode, include_intra=True
            )
        else:
            sizes = _domain_table_sizes(model, d, keys, column_mode)
            box[d], coords[d] = _arrange_line(sizes, vertical=(direction[d] == "RIGHT"))
            routes[d] = {}

    fb = box[focal]
    fext = max(fb) / 2
    boxes = {focal: [-fb[0] / 2, -fb[1] / 2, fb[0], fb[1]]}
    for d in related:
        bw, bh = box[d]
        r = fext + max(bw, bh) / 2 + 70.0
        cx, cy = r * math.cos(angle[d]), r * math.sin(angle[d])
        boxes[d] = [cx - bw / 2, cy - bh / 2, bw, bh]
    _resolve_overlaps(boxes, pinned=focal, margin=45.0)

    nodes, groups = [], []
    intra_routes: dict[str, list] = {}
    for d in domains:
        ox, oy, bw, bh = boxes[d]
        groups.append(DiagramDomainGroup(
            id=f"domain:{d}", domain=d, division=division_by_domain.get(d, ""),
            x=ox, y=oy, width=bw, height=bh,
            is_external=(d != focal), product_count=len(coords[d]),
        ))
        for k, (x, y, w, h) in coords[d].items():
            v = pidx[k]
            pk_str = v.get("primary_key", "")
            pk_cols = {c.strip() for c in pk_str.split(",") if c.strip()} if pk_str else set()
            meta = _product_node_meta(v, k, pk_cols, column_mode, change_map)
            nodes.append(DiagramNode(
                id=k, domain=d, product=meta["product"],
                table_name=meta["table_name"],
                product_type=meta["product_type"],
                description=meta["description"],
                x=ox + x, y=oy + y, width=w, height=h,
                columns=[DiagramNodePort(**c) for c in meta["columns"]],
                column_count=meta["column_count"], fk_count=meta["fk_count"],
                change_status=meta["change_status"],
            ))
        if d == focal:
            for eid, poly in routes[d].items():
                intra_routes[eid] = [(px + ox, py + oy) for (px, py) in poly]

    de = [
        DiagramEdge(
            id=fk_edge_id(e["source_node"], e["source_column"], e["target_node"], e["target_column"]),
            source_node=e["source_node"], source_column=e["source_column"],
            target_node=e["target_node"], target_column=e["target_column"],
        )
        for e in edges_f
    ]

    layout = DiagramLayoutOut(
        nodes=nodes, edges=de, groups=groups, domain_filter=focal,
        total_products=len(nodes), total_edges=len(de),
    )
    return layout, intra_routes


# ---------------------------------------------------------------------------
# Public entry
# ---------------------------------------------------------------------------


def compute_focal_layout(
    model: dict,
    focal: str,
    column_mode: str,
    product_change_status: dict[tuple[str, str], ChangeStatus] | None = None,
) -> DiagramLayoutOut:
    """Compute the single-domain (focal) diagram layout.

    Placement is even-ring; ``column_mode`` threads into related-box sizing (D2).
    Intra (focal-internal) edges carry the translated ELK routes as
    ``waypoints``; cross-domain edges get orthogonal waypoints + four-side
    anchors ONLY when ``column_mode == "hide"`` (else ``waypoints=[]`` and the
    frontend falls back to its per-column smoothstep edges).
    """
    layout, intra_routes = two_phase_layout(
        model, focal, column_mode, product_change_status=product_change_status
    )
    layout.show_columns = column_mode != "hide"

    node_dom = {n.id: n.domain for n in layout.nodes}

    # Intra (focal-internal) edges: attach the ELK route.
    for e in layout.edges:
        if node_dom.get(e.source_node) == focal and node_dom.get(e.target_node) == focal:
            poly = intra_routes.get(e.id)
            if not poly:
                continue
            e.waypoints = poly

    # Cross-domain edges: orthogonal routing only in hide mode.
    if column_mode == "hide":
        anchors = placement_anchors(layout, focal)
        polys = orthogonal_cross_domain(layout, anchors)
        for e in layout.edges:
            if anchors.get(e.id) is None:
                continue
            e.waypoints = polys.get(e.id, [])

    return layout

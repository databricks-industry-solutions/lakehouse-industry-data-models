"""ER Diagram API — compute ELK layout for model visualization."""

import asyncio
import atexit
import concurrent.futures
import hashlib
import json
import logging
import subprocess
import threading
import time
from collections import OrderedDict
from concurrent.futures import Future, ThreadPoolExecutor
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Callable, Optional

from typing import Annotated

from dataclasses import dataclass

from fastapi import HTTPException, Path as PathParam, Request
from fastapi.responses import JSONResponse
from sqlalchemy import event
from sqlmodel import Session, select

from ._query_helpers import resolve_model_version
from .core import Dependencies, create_router
from .db_models import DiagramLayout
from .error_sanitization import sanitize_error_detail, sanitize_error_message
from .explorer import (
    _load_model,
    _load_prev_model,
)
from .model_diff import compute_model_diff
from .fk import (
    count_fk_attributes,
    fk_edge_id,
    is_fk_attribute,
    parse_fk_target,
    product_fqn,
)
from .models import (
    ChangeStatus,
    DiagramDomainGroup,
    DiagramEdge,
    DiagramLayoutOut,
    DiagramNode,
    DiagramNodePort,
    DiagramPendingOut,
)

logger = logging.getLogger(__name__)
router = create_router()

# ---------------------------------------------------------------------------
# Rendering constants — adjust these to tune the diagram appearance.
# All sizes are in pixels. ELK spacing values are strings (ELK convention).
# ---------------------------------------------------------------------------

# Node sizing
NODE_MIN_WIDTH = 200  # minimum table node width
NODE_CHAR_WIDTH = 8  # approximate px per character for table name
NODE_NAME_PADDING = 60  # extra px for padding around table name
NODE_HEADER_HEIGHT = 36  # height of the table header bar
NODE_COLUMN_ROW_HEIGHT = 22  # height per column row when columns are shown
NODE_SUMMARY_HEIGHT = 28  # height of the summary line ("N columns, M FKs")
NODE_BORDER_PADDING = 8  # extra px to account for CSS borders, outline, padding
NODE_MAX_VISIBLE_COLUMNS = 40  # cap columns to prevent giant nodes

# ELK layout options — root level (inter-domain).
#
# `stress` is a force-directed algorithm that treats edges as undirected
# springs — appropriate for ER diagrams where the FK source→target
# direction does NOT carry the "before/after" semantics that the
# `layered` algorithm assumes. Densely-connected domains naturally
# gravitate toward the center; less-connected ones float outward. Across
# both pure-sink focal domains (e.g. a `product` reference target) and
# mixed-connectivity ones (e.g. `customer` with FKs flowing both ways),
# `stress` produces a layout that uses the canvas symmetrically rather
# than collapsing all related domains onto one side.
#
# `randomSeed` pinned so the layout is deterministic across runs — the
# Lakebase cache key already commits to specific (x,y) coordinates per
# (business, version, scope, domain_filter, column_mode), so the
# algorithm needs to converge to the same output on identical input.
ELK_ROOT_OPTIONS = {
    "elk.algorithm": "stress",
    "elk.stress.iterationLimit": "300",
    "elk.aspectRatio": "1.6",
    "elk.spacing.nodeNode": "120",
    "elk.spacing.componentComponent": "100",
    "elk.spacing.edgeEdge": "15",
    "elk.spacing.edgeNode": "25",
    "elk.edgeRouting": "ORTHOGONAL",
    "elk.hierarchyHandling": "INCLUDE_CHILDREN",
    "elk.separateConnectedComponents": "true",
    "elk.randomSeed": "1",
}

# ELK layout options — domain compound nodes (intra-domain).
#
# Reverted to `layered` (direction=DOWN) after a 2026-05-06 detour
# through `radial` (broke on cyclic graphs) and `force` (clean cycle
# handling but tangled spaghetti edges on dense domains). Layered with
# orthogonal edge routing produces clean, readable columns of tables
# inside each domain compound — that's the property that matters most
# for intra-domain readability. Centrality / "graph-center as root" is
# nice in theory but loses to legibility in practice.
#
# Inter-domain distribution (root level — see ELK_ROOT_OPTIONS) is the
# remaining un-solved case; tracked separately as a Backlog task to
# rethink the inter-domain layout (custom compass-point positioning
# around the focal) along with the table-node port-side UI bug that
# forces all edges to attach to the same side of every node.
ELK_DOMAIN_OPTIONS = {
    "elk.algorithm": "layered",
    "elk.direction": "DOWN",
    "elk.spacing.nodeNode": "35",
    "elk.layered.spacing.nodeNodeBetweenLayers": "60",
    "elk.layered.spacing.edgeNodeBetweenLayers": "25",
    "elk.layered.spacing.edgeEdgeBetweenLayers": "15",
    "elk.spacing.edgeEdge": "15",
    "elk.spacing.edgeNode": "20",
    "elk.edgeRouting": "ORTHOGONAL",
    "elk.padding": "[top=45,left=25,bottom=25,right=25]",
    "elk.layered.nodePlacement.strategy": "NETWORK_SIMPLEX",
    "elk.layered.crossingMinimization.strategy": "LAYER_SWEEP",
}

# Path to the ELK layout subprocess script
ELK_SCRIPT = Path(__file__).parent / "elk_layout.cjs"

@dataclass(frozen=True)
class _LayoutError:
    """A failed background layout job, kept so the next viewer poll can
    report it. ``detail`` is already sanitized; ``status_code`` is the
    original one (a missing model stays a 404)."""

    status_code: int
    detail: Any
    at_ms: int


# A cached failure older than this is dropped and the layout recomputed: the
# viewer polls every few seconds, so a fresh failure still reaches it, while
# one left by the post-version prefetch minutes earlier does not.
_LAYOUT_ERROR_TTL_MS = 60_000

# In-memory layout cache: hash -> layout | failed job
_layout_cache: dict[str, DiagramLayoutOut | _LayoutError] = {}
_cache_lock = threading.Lock()

# Track in-progress background computations to avoid duplicate work.
# ``OrderedDict`` preserves insertion order so we can report queue position
# back to polling clients (task #104). Values are the last-heartbeat
# ms-epoch for that key; updated on enqueue and again when the worker
# actually starts / makes progress on the job.
_in_progress: "OrderedDict[str, int]" = OrderedDict()
_in_progress_lock = threading.Lock()

# Async prefetch scheduler — Phase 3 #52 P-4 unification.
#
# Pre-#52 the ER-diagram prefetch worker owned its own
# ``ThreadPoolExecutor``; the tracker and orchestrator each had their
# own runtimes too. This class collapses the prefetch worker onto the
# asyncio loop the orchestrator / tracker run on — keeping the
# blocking ELK call on a worker thread (via the asyncio default
# executor) but routing scheduling through a single event loop so
# shutdown and observability all live in one place.
#
# The diagram-prefetch worker does NOT become an Operation: per
# ``docs/orchestrator-design.md`` §4 it is an App-side performance
# concern (warm the cache so the diagram view is instant), not part
# of any Run's intent. It has no rollback semantics and produces no
# RunOperation row.
#
# Backwards-compat: tests and route handlers call
# ``_prefetch_pool.submit(fn, *args)`` and treat the return as a
# ``concurrent.futures.Future``. The scheduler exposes the same shape
# (a ``submit()`` method returning a Future) so existing callers work
# without changes — they just route through the asyncio loop instead
# of a dedicated thread pool.
class _AsyncPrefetchScheduler:
    """Schedule blocking prefetch jobs on the asyncio loop.

    On a live event loop, ``submit`` calls
    ``loop.run_in_executor(_executor, fn, *args)`` so the heavy work
    still runs on a worker thread (ELK is a blocking subprocess), but
    the *scheduling* — and the lifecycle of the underlying executor —
    is owned by the loop the tracker and orchestrator already run on.

    Outside an event loop (tests, scripts), it falls back to the
    classic ThreadPoolExecutor behaviour so no caller has to know.
    """

    def __init__(self, max_workers: int = 1, thread_name_prefix: str = "elk-prefetch") -> None:
        self._executor = ThreadPoolExecutor(
            max_workers=max_workers, thread_name_prefix=thread_name_prefix
        )
        self._loop: Optional[asyncio.AbstractEventLoop] = None

    def attach_loop(self, loop: asyncio.AbstractEventLoop) -> None:
        """Bind the scheduler to a running asyncio loop. Called once
        from the lifespan startup so all subsequent ``submit`` calls
        route work through that loop's default executor."""
        self._loop = loop

    def submit(self, fn: Callable[..., Any], *args: Any, **kwargs: Any) -> Future:
        """Schedule ``fn(*args, **kwargs)`` on a worker thread.

        On a live event loop, schedules via the loop so the work
        runs concurrently with the tracker / orchestrator on the same
        runtime. Outside an event loop, delegates to the underlying
        ThreadPoolExecutor.
        """
        loop = self._loop
        if loop is not None and not loop.is_closed():
            try:
                running_loop = asyncio.get_running_loop()
            except RuntimeError:
                running_loop = None
            if running_loop is loop:
                return loop.run_in_executor(
                    self._executor, lambda: fn(*args, **kwargs)
                )
            # Submit thread-safely from another thread context.
            cf = concurrent.futures.Future()

            def _runner() -> None:
                try:
                    cf.set_result(fn(*args, **kwargs))
                except Exception as e:  # noqa: BLE001 — surface to caller
                    cf.set_exception(e)

            try:
                loop.call_soon_threadsafe(
                    lambda: loop.run_in_executor(self._executor, _runner)
                )
                return cf
            except RuntimeError:
                # Loop closed mid-call — fall through to direct submit.
                pass
        return self._executor.submit(fn, *args, **kwargs)

    def shutdown(self, wait: bool = True) -> None:
        """Shut the underlying executor down. Idempotent."""
        try:
            self._executor.shutdown(wait=wait)
        except Exception:  # noqa: BLE001 — best-effort
            pass


_prefetch_pool = _AsyncPrefetchScheduler(
    max_workers=1, thread_name_prefix="elk-prefetch"
)


def _shutdown_prefetch_pool() -> None:
    """Tear down the prefetch scheduler at interpreter exit."""
    _prefetch_pool.shutdown(wait=False)


atexit.register(_shutdown_prefetch_pool)


def attach_prefetch_loop(loop: asyncio.AbstractEventLoop) -> None:
    """Public entry point for the lifespan to bind the prefetch
    scheduler to the running event loop. Called from
    :class:`ProgressTracker.resume_running_runs` so the diagram
    prefetch worker shares the runtime with the orchestrator."""
    _prefetch_pool.attach_loop(loop)


def _now_ms() -> int:
    """Current wall-clock time in milliseconds since the epoch."""
    return int(time.time() * 1000)


def _touch_heartbeat(key: str) -> None:
    """Update the heartbeat timestamp for a pending key (best-effort).

    Called by the background worker when it picks up a job and again after
    the layout finishes, so the 202 polling endpoint can report freshness.
    No-op if the key is no longer tracked (e.g. job already finished).
    """
    with _in_progress_lock:
        if key in _in_progress:
            _in_progress[key] = _now_ms()


# ---------------------------------------------------------------------------
# Graph construction
# ---------------------------------------------------------------------------


def _node_size(
    table_name: str, num_columns: int, num_keys: int, column_mode: str
) -> tuple[float, float]:
    """Compute node width and height based on table name and visible column count.

    column_mode: "hide" | "keys" | "all"
    """
    width = max(NODE_MIN_WIDTH, len(table_name) * NODE_CHAR_WIDTH + NODE_NAME_PADDING)
    if column_mode == "all" and num_columns > 0:
        visible = min(num_columns, NODE_MAX_VISIBLE_COLUMNS)
        height = NODE_HEADER_HEIGHT + NODE_COLUMN_ROW_HEIGHT * visible + NODE_SUMMARY_HEIGHT
    elif column_mode == "keys" and num_keys > 0:
        visible = min(num_keys, NODE_MAX_VISIBLE_COLUMNS)
        height = NODE_HEADER_HEIGHT + NODE_COLUMN_ROW_HEIGHT * visible + NODE_SUMMARY_HEIGHT
    else:
        height = NODE_HEADER_HEIGHT + NODE_SUMMARY_HEIGHT
    # Add padding for CSS borders/outline that the browser renders outside the ELK box
    height += NODE_BORDER_PADDING
    return float(width), float(height)


def _build_product_index(model: dict) -> dict:
    """Build a lookup: 'domain.product' -> product dict with domain info."""
    index = {}
    for domain in model.get("domains", []):
        dn = domain.get("name", "")
        for product in domain.get("products", []):
            pn = product.get("name", "")
            index[product_fqn(dn, pn)] = {**product, "_domain": dn, "_division": domain.get("division", "")}
    return index


def _collect_fk_edges(model: dict, product_index: dict, domain_filter: str | None) -> list[dict]:
    """Extract FK edges from model, validating targets exist."""
    edges = []
    seen = set()
    for domain in model.get("domains", []):
        dn = domain.get("name", "")
        for product in domain.get("products", []):
            pn = product.get("name", "")
            source_node = product_fqn(dn, pn)
            for attr in product.get("attributes", []):
                target = parse_fk_target(attr.get("foreign_key_to", ""))
                if target is None or target.domain is None:
                    continue
                target_domain, target_product, target_column = (
                    target.domain, target.table, target.column
                )
                target_node = product_fqn(target_domain, target_product)
                if target_node not in product_index:
                    continue  # broken FK reference, skip
                edge_id = fk_edge_id(
                    source_node, attr.get("column_name", attr.get("name", "")),
                    target_node, target_column,
                )
                if edge_id in seen:
                    continue
                seen.add(edge_id)
                # If domain filter is set, only include edges touching the filtered domain
                if domain_filter:
                    if dn != domain_filter and target_domain != domain_filter:
                        continue
                edges.append({
                    "source_node": source_node,
                    "source_column": attr.get("column_name", attr.get("name", "")),
                    "target_node": target_node,
                    "target_column": target_column,
                    "source_domain": dn,
                    "target_domain": target_domain,
                })
    return edges


def _determine_included_products(
    model: dict,
    product_index: dict,
    edges: list[dict],
    domain_filter: str | None,
) -> set[str]:
    """Determine which products to include in the diagram."""
    if not domain_filter:
        return set(product_index.keys())

    included = set()
    # All products in the target domain
    for key, info in product_index.items():
        if info["_domain"] == domain_filter:
            included.add(key)

    # Products from other domains that have FK relationships with the filtered domain
    for edge in edges:
        included.add(edge["source_node"])
        included.add(edge["target_node"])

    return included


def _product_node_meta(
    info: dict,
    prod_key: str,
    pk_cols: set[str],
    column_mode: str,
    change_status: dict[tuple[str, str], ChangeStatus],
) -> dict:
    """Build the frontend display metadata for a single product/table node.

    Canonical for BOTH the overview path (``_build_elk_graph`` /
    ``_extract_layout``) and the focal path (``diagram_layout.two_phase_layout``)
    so the two cannot drift on product_type / columns / change_status. Returns the
    same dict shape ``_extract_layout`` consumes when constructing ``DiagramNode``.
    """
    pn = info.get("name", "")
    table_name = info.get("table_name", pn)
    attrs = info.get("attributes", [])

    columns_meta = []
    for attr in attrs:
        col_name = attr.get("column_name", attr.get("name", ""))
        columns_meta.append({
            "id": f"{prod_key}.{col_name}",
            "name": col_name,
            "is_pk": col_name in pk_cols,
            "is_fk": is_fk_attribute(attr),
            "type": attr.get("type", ""),
            "description": attr.get("description", ""),
            "fk_target": attr.get("foreign_key_to", ""),
        })
    columns_meta.sort(
        key=lambda c: (0 if c["is_pk"] else 1 if c["is_fk"] else 2, c["name"].lower())
    )

    return {
        "domain": info["_domain"],
        "product": pn,
        "table_name": table_name,
        "product_type": info.get("type", ""),
        "description": info.get("description", ""),
        "columns": columns_meta if column_mode != "hide" else [],
        "column_count": len(attrs),
        "fk_count": count_fk_attributes(attrs),
        "change_status": change_status.get(
            (info["_domain"], pn), ChangeStatus.UNCHANGED
        ),
    }


def _build_elk_graph(
    model: dict,
    domain_filter: str | None,
    column_mode: str,
    product_change_status: dict[tuple[str, str], ChangeStatus] | None = None,
) -> tuple[dict, dict]:
    """Build an ELK-compatible hierarchical graph from the model JSON.

    Returns (elk_graph, metadata) where metadata maps node/group IDs to extra info.

    product_change_status: optional map of (domain, product) -> ChangeStatus used to
    annotate node metadata. Products not present in the map are treated as UNCHANGED.
    """
    product_index = _build_product_index(model)
    edges = _collect_fk_edges(model, product_index, domain_filter)
    included = _determine_included_products(model, product_index, edges, domain_filter)
    change_map = product_change_status or {}

    # Group included products by domain
    domain_products: dict[str, list[str]] = {}
    for prod_key in sorted(included):
        info = product_index[prod_key]
        dn = info["_domain"]
        domain_products.setdefault(dn, []).append(prod_key)

    # Build metadata for frontend consumption
    metadata: dict[str, dict] = {}

    # Build ELK compound nodes for each domain
    elk_children = []
    for dn, prod_keys in sorted(domain_products.items()):
        is_external = domain_filter is not None and dn != domain_filter

        # Get domain info from model
        domain_info = None
        for d in model.get("domains", []):
            if d.get("name") == dn:
                domain_info = d
                break

        domain_id = f"domain:{dn}"
        label = f"{dn} (related)" if is_external else dn
        metadata[domain_id] = {
            "domain": dn,
            "division": domain_info.get("division", "") if domain_info else "",
            "is_external": is_external,
            "product_count": len(prod_keys),
        }

        # Build table nodes inside this domain
        table_nodes = []
        for prod_key in prod_keys:
            info = product_index[prod_key]
            pn = info.get("name", "")
            table_name = info.get("table_name", pn)
            attrs = info.get("attributes", [])
            pk_str = info.get("primary_key", "")
            pk_cols = {c.strip() for c in pk_str.split(",") if c.strip()} if pk_str else set()

            fk_count = count_fk_attributes(attrs)
            key_count = len(pk_cols) + fk_count
            width, height = _node_size(table_name, len(attrs), key_count, column_mode)

            metadata[prod_key] = _product_node_meta(
                info, prod_key, pk_cols, column_mode, change_map
            )

            table_node = {
                "id": prod_key,
                "width": width,
                "height": height,
                "labels": [{"text": table_name}],
            }
            table_nodes.append(table_node)

        domain_opts = {**ELK_DOMAIN_OPTIONS}

        domain_node = {
            "id": domain_id,
            "labels": [{"text": label}],
            "layoutOptions": domain_opts,
            "children": table_nodes,
        }

        # Intra-domain edges (node-level, no ports)
        intra_edges = []
        for edge in edges:
            if edge["source_domain"] == dn and edge["target_domain"] == dn:
                edge_id = fk_edge_id(edge["source_node"], edge["source_column"], edge["target_node"], edge["target_column"])
                elk_edge = {
                    "id": edge_id,
                    "sources": [edge["source_node"]],
                    "targets": [edge["target_node"]],
                }
                intra_edges.append(elk_edge)
        if intra_edges:
            domain_node["edges"] = intra_edges

        elk_children.append(domain_node)

    elk_graph = {
        "id": "root",
        "layoutOptions": {**ELK_ROOT_OPTIONS},
        "children": elk_children,
    }

    # Inter-domain edges (node-level, at root level)
    inter_edges = []
    for edge in edges:
        if edge["source_domain"] != edge["target_domain"]:
            edge_id = fk_edge_id(edge["source_node"], edge["source_column"], edge["target_node"], edge["target_column"])
            elk_edge = {
                "id": edge_id,
                "sources": [edge["source_node"]],
                "targets": [edge["target_node"]],
            }
            inter_edges.append(elk_edge)
    if inter_edges:
        elk_graph["edges"] = inter_edges

    return elk_graph, metadata


# ---------------------------------------------------------------------------
# Persistent ELK subprocess
# ---------------------------------------------------------------------------

_elk_proc: subprocess.Popen | None = None
_elk_lock = threading.Lock()


def _ensure_elk_process() -> subprocess.Popen:
    """Start (or restart) the persistent Node.js ELK process."""
    global _elk_proc
    if _elk_proc is not None and _elk_proc.poll() is None:
        return _elk_proc
    logger.info("Starting persistent ELK layout process")
    _elk_proc = subprocess.Popen(
        ["node", "--stack-size=65536", str(ELK_SCRIPT)],  # 64MB stack for large graphs
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        bufsize=1,  # line-buffered
    )
    # Wait for the "ready" signal
    ready_line = _elk_proc.stdout.readline()
    if not ready_line:
        raise HTTPException(500, "ELK process failed to start")
    ready = json.loads(ready_line)
    if not ready.get("ready"):
        raise HTTPException(500, f"ELK process unexpected startup: {ready_line[:200]}")
    logger.info("ELK layout process ready (pid=%d)", _elk_proc.pid)
    return _elk_proc


def _run_elk_layout(elk_graph: dict) -> dict:
    """Send a layout request to the persistent ELK process and read the result."""
    with _elk_lock:
        proc = _ensure_elk_process()
        request_line = json.dumps(elk_graph) + "\n"
        try:
            proc.stdin.write(request_line)
            proc.stdin.flush()
        except (BrokenPipeError, OSError):
            # Process died — restart and retry once
            logger.warning("ELK process pipe broken, restarting")
            proc = _ensure_elk_process()
            proc.stdin.write(request_line)
            proc.stdin.flush()

        response_line = proc.stdout.readline()
        if not response_line:
            raise HTTPException(500, "ELK process returned empty response")

    response = json.loads(response_line)
    if "error" in response:
        raise HTTPException(500, f"ELK layout failed: {response['error']}")
    return response["result"]


def _shutdown_elk() -> None:
    """Terminate the persistent ELK process on interpreter exit."""
    global _elk_proc
    if _elk_proc is not None and _elk_proc.poll() is None:
        _elk_proc.terminate()
        _elk_proc.wait(timeout=5)
        logger.info("ELK layout process terminated")


atexit.register(_shutdown_elk)


# ---------------------------------------------------------------------------
# Position extraction
# ---------------------------------------------------------------------------


def _extract_layout(elk_result: dict, metadata: dict, edges: list[dict]) -> DiagramLayoutOut:
    """Walk the ELK result tree and extract positioned nodes, groups, edges."""
    nodes = []
    groups = []

    for domain_node in elk_result.get("children", []):
        domain_id = domain_node["id"]
        dm = metadata.get(domain_id, {})
        domain_x = domain_node.get("x", 0)
        domain_y = domain_node.get("y", 0)

        groups.append(DiagramDomainGroup(
            id=domain_id,
            domain=dm.get("domain", ""),
            division=dm.get("division", ""),
            x=domain_x,
            y=domain_y,
            width=domain_node.get("width", 0),
            height=domain_node.get("height", 0),
            is_external=dm.get("is_external", False),
            product_count=dm.get("product_count", 0),
        ))

        for table_node in domain_node.get("children", []):
            node_id = table_node["id"]
            nm = metadata.get(node_id, {})
            # Positions are relative to parent, convert to absolute
            abs_x = domain_x + table_node.get("x", 0)
            abs_y = domain_y + table_node.get("y", 0)

            columns = [
                DiagramNodePort(**col) for col in nm.get("columns", [])
            ]

            nodes.append(DiagramNode(
                id=node_id,
                domain=nm.get("domain", ""),
                product=nm.get("product", ""),
                table_name=nm.get("table_name", ""),
                product_type=nm.get("product_type", ""),
                description=nm.get("description", ""),
                x=abs_x,
                y=abs_y,
                width=table_node.get("width", 0),
                height=table_node.get("height", 0),
                columns=columns,
                column_count=nm.get("column_count", 0),
                fk_count=nm.get("fk_count", 0),
                change_status=nm.get("change_status", ChangeStatus.UNCHANGED),
            ))

    diagram_edges = [
        DiagramEdge(
            id=fk_edge_id(e["source_node"], e["source_column"], e["target_node"], e["target_column"]),
            source_node=e["source_node"],
            source_column=e["source_column"],
            target_node=e["target_node"],
            target_column=e["target_column"],
        )
        for e in edges
    ]

    return DiagramLayoutOut(
        nodes=nodes,
        edges=diagram_edges,
        groups=groups,
        total_products=len(nodes),
        total_edges=len(diagram_edges),
    )


# ---------------------------------------------------------------------------
# Caching
# ---------------------------------------------------------------------------


# Bump this when ELK_ROOT_OPTIONS or ELK_DOMAIN_OPTIONS changes the
# layout algorithm or any options that materially affect coordinates,
# so cached Lakebase / in-memory layouts from prior algorithms are
# invalidated organically without requiring a manual cache wipe.
_LAYOUT_ALGORITHM_VERSION = 7  # v7: deterministic column ordering (PK, FK, rest; each alpha). v6: focal nodes carry display metadata (product_type/columns/change_status) via shared _product_node_meta + nodes emit height; invalidates v5 layouts cached with empty columns (keys/all dropped edges). v5: focal view uses diagram_layout.compute_focal_layout (even-ring placement + four-side anchoring + orthogonal cross-domain routing); overview path unchanged. v4: stress (root) + layered (domain) - reverted intra-domain after force/radial detour; v3: stress+force; v2: stress+radial; v1: layered+layered

class _ModelNotReadyError(Exception):
    """Raised by _compute_layout when the model has no domains yet.

    Signals that the model is not ready for layout computation (sync
    has not completed). _background_compute catches this without caching
    an empty success, so a later post-sync request will recompute the
    layout and produce a real result.
    """


def _cache_key(business_id: str, version_int: int, scope: str, domain: str | None, column_mode: str) -> str:
    payload = json.dumps(
        {
            "b": business_id, "v": version_int, "s": scope, "d": domain, "c": column_mode,
            "alg": _LAYOUT_ALGORITHM_VERSION,
        },
        sort_keys=True,
    )
    return hashlib.sha256(payload.encode()).hexdigest()[:16]


def _resolve_version_id(session, business_id: str, version_int: int, scope: str) -> str | None:
    """Look up the ModelVersion.id for the (business, version, scope) triple. Returns None if not found."""
    mv = resolve_model_version(session, business_id, version_int, scope)
    return mv.id if mv else None


def _read_lakebase_layout(session, business_id: str, cache_key: str) -> DiagramLayoutOut | None:
    """Return a cached layout from Lakebase, or None if missing."""
    row = session.exec(
        select(DiagramLayout).where(
            DiagramLayout.business_id == business_id,
            DiagramLayout.cache_key == cache_key,
        )
    ).first()
    if not row:
        return None
    try:
        data = json.loads(row.layout_json)
        return DiagramLayoutOut(**data)
    except (json.JSONDecodeError, TypeError, ValueError):
        logger.warning("Failed to deserialize cached layout %s; recomputing", cache_key)
        return None


def _write_lakebase_layout(
    session,
    business_id: str,
    version_id: str,
    cache_key: str,
    layout: DiagramLayoutOut,
) -> None:
    """Upsert a layout into the Lakebase cache. Best-effort; logs on failure."""
    try:
        existing = session.exec(
            select(DiagramLayout).where(
                DiagramLayout.business_id == business_id,
                DiagramLayout.cache_key == cache_key,
            )
        ).first()
        now = datetime.now(timezone.utc)
        payload = layout.model_dump_json()
        if existing:
            existing.layout_json = payload
            existing.version_id = version_id
            existing.updated_at = now
            session.add(existing)
        else:
            session.add(DiagramLayout(
                business_id=business_id,
                version_id=version_id,
                cache_key=cache_key,
                layout_json=payload,
            ))
        session.commit()
    except Exception:
        logger.exception("Failed to persist layout %s to Lakebase", cache_key)
        try:
            session.rollback()
        except Exception:
            pass


def _invalidate_business_layouts(session, business_id: str, keep_version_id: str) -> None:
    """Delete cached layouts for a business that aren't for the given version_id.

    Called on new ModelVersion completion or import to keep the cache lean.
    """
    try:
        rows = session.exec(
            select(DiagramLayout).where(
                DiagramLayout.business_id == business_id,
                DiagramLayout.version_id != keep_version_id,
            )
        ).all()
        for row in rows:
            session.delete(row)
        if rows:
            session.commit()
            logger.info("Invalidated %d stale layouts for business %s", len(rows), business_id)
    except Exception:
        logger.exception("Failed to invalidate stale layouts for %s", business_id)
        try:
            session.rollback()
        except Exception:
            pass


def _invalidate_empty_layouts(
    session, business_id: str, version_id: str | None = None
) -> int:
    """Delete cached layouts that have zero nodes (pre-sync stale empties).

    Targeted cleanup for the bug where an all-domains layout was prefetched
    before the model finished syncing, producing an empty layout that was
    cached as the durable answer. After the guard in ``_background_compute``
    is deployed, new empty layouts are never persisted. This function clears
    any that were written before the guard.

    Pass ``version_id`` to scope the cleanup to a specific version, or omit
    it to scan all versions for the given business.

    Returns the number of rows deleted. Best-effort: logs and returns 0 on
    any failure, never raises.

    Intended use: one-shot repair on affected deployments (e.g. a forked Lakebase branch).
    Do NOT run against production without explicit confirmation.
    """
    try:
        query = select(DiagramLayout).where(
            DiagramLayout.business_id == business_id,
        )
        if version_id is not None:
            query = query.where(DiagramLayout.version_id == version_id)
        rows = session.exec(query).all()

        to_delete = []
        for row in rows:
            try:
                data = json.loads(row.layout_json)
                if not data.get("nodes"):
                    to_delete.append(row)
            except (json.JSONDecodeError, TypeError):
                to_delete.append(row)

        for row in to_delete:
            session.delete(row)
        if to_delete:
            session.commit()
            logger.info(
                "Purged %d empty cached layouts for business %s",
                len(to_delete), business_id,
            )
        return len(to_delete)
    except Exception:
        logger.exception(
            "Failed to purge empty layouts for business %s", business_id
        )
        try:
            session.rollback()
        except Exception:
            pass
        return 0


# ---------------------------------------------------------------------------
# Public helper: post-version layout prefetch
# ---------------------------------------------------------------------------


def _after_transaction(session: "Session", fn: Callable[[], None], *, what: str) -> None:
    """Run ``fn`` once the transaction ``session`` is in has ended, unless it
    rolled back.

    Commit and a plain ``close()`` both run it: a request session closes
    without committing after reading rows an earlier commit wrote, and those
    rows are visible to a fresh session. A rollback of the outer transaction
    drops ``fn`` (a savepoint rollback doesn't). ``fn`` runs inside the
    commit, so its errors are logged, never raised into the caller's commit.
    """
    root = session.get_transaction()

    def _run() -> None:
        try:
            fn()
        except Exception:
            logger.exception("Deferred %s failed (non-fatal)", what)

    state = {"rolled_back": False, "done": False}

    def _on_rollback(sess: "Session") -> None:
        if not sess.in_nested_transaction():
            state["rolled_back"] = True

    def _on_end(sess: "Session", transaction: Any) -> None:
        if transaction is not root or state["done"]:
            return
        state["done"] = True
        if state["rolled_back"]:
            logger.info("Dropped %s: the transaction rolled back", what)
            return
        _run()

    event.listen(session, "after_rollback", _on_rollback)
    event.listen(session, "after_transaction_end", _on_end)


def queue_layout_prefetch_for_version(
    session: "Session",
    session_factory: Callable[[], "Session"],
    ws: Any,
    *,
    business_id: str,
    version_int: int,
    scope: str,
) -> int:
    """Queue ELK layout prefetch jobs for every diagram view of the given
    (business, version, scope) tuple.

    Submits up to ``3 + len(domains)`` background jobs:
      - overview (no domain filter) × {hide, keys, all} column modes
      - per-domain × ``hide`` column mode

    Each job is a no-op if the same cache key is already in flight or
    already cached; this method is safe to call multiple times.

    Used in two places:
      1. ``POST /businesses/{id}/versions/import-from-volume`` route
         (manual user-triggered model.json import).
      2. The orchestrator's per-op terminal-success path for any
         ``produces_version=True`` operation (``generate_ecm``,
         ``shrink_to_mvm``, ``enlarge_to_ecm``, ``vibe_iterate``) so a
         freshly-generated model has its diagrams pre-computed before
         the user opens the explorer.

    Best-effort: on any failure logs and returns ``0``. Never raises.
    The number returned is the count of jobs queued (jobs skipped because
    their key was already in flight don't count).

    Two session parameters because the caller already has a live
    request-scoped ``session`` we use synchronously to enumerate the
    domains, while the background ELK workers run after the caller's
    session has closed and need a ``session_factory`` to open their
    own session bound to the app engine.

    The jobs are submitted only when the caller's transaction ends (see
    ``_after_transaction``): the orchestrator queues the prefetch in the
    same transaction that creates the version, and a worker that starts
    before that commit can't see it.
    """
    submitted = 0
    try:
        from .db_models import Domain as DbDomain

        mv = resolve_model_version(session, business_id, version_int, scope)
        if mv is None:
            logger.warning(
                "queue_layout_prefetch_for_version: ModelVersion not found "
                "for business=%s version=%s scope=%s — nothing to queue",
                business_id, version_int, scope,
            )
            return 0

        domain_rows = session.exec(
            select(DbDomain).where(DbDomain.version_id == mv.id)
        ).all()
        domain_names = [d.name for d in domain_rows if d.name]

        if not domain_names:
            logger.info(
                "queue_layout_prefetch_for_version: no domains for "
                "business=%s version=%s scope=%s — skipping prefetch "
                "(model not ready yet)",
                business_id, version_int, scope,
            )
            return 0

        to_queue: list[tuple[str | None, str]] = []
        for mode in ("hide", "keys", "all"):
            to_queue.append((None, mode))
        for dn in domain_names:
            to_queue.append((dn, "hide"))

        jobs = [
            (domain_filter, column_mode,
             _cache_key(business_id, version_int, scope, domain_filter, column_mode))
            for domain_filter, column_mode in to_queue
        ]
        with _in_progress_lock:
            jobs = [job for job in jobs if job[2] not in _in_progress]
        submitted = len(jobs)

        def _submit() -> None:
            for domain_filter, column_mode, key in jobs:
                with _in_progress_lock:
                    if key in _in_progress:
                        continue
                    _in_progress[key] = _now_ms()
                try:
                    _prefetch_pool.submit(
                        _background_compute,
                        session_factory, ws, business_id, version_int,
                        scope, domain_filter, column_mode, key,
                    )
                except Exception:
                    with _in_progress_lock:
                        _in_progress.pop(key, None)
                    raise
            logger.info(
                "queue_layout_prefetch_for_version: submitted %d jobs for "
                "business=%s version=%s scope=%s",
                len(jobs), business_id, version_int, scope,
            )

        _after_transaction(session, _submit, what=(
            f"layout prefetch business={business_id} "
            f"version={version_int} scope={scope}"
        ))
    except Exception:
        logger.exception(
            "queue_layout_prefetch_for_version: failed for "
            "business=%s version=%s scope=%s — non-fatal",
            business_id, version_int, scope,
        )
    return submitted


# ---------------------------------------------------------------------------
# Endpoint
# ---------------------------------------------------------------------------


def _load_layout_inputs(
    session, ws, business_id: str, version_int: int, scope: str,
) -> tuple[dict, dict | None, str | None]:
    """Read everything the layout computation needs, and nothing else.

    Callers must release ``session`` (commit or close it) right after this
    returns — the layout algorithm that follows is CPU-bound and can run
    for minutes on a large model, and none of that work touches the
    database. Holding the read transaction open across it would leave an
    idle-in-transaction connection checked out of the pool for the whole
    computation.
    """
    model = _load_model(session, ws, business_id, version_int, scope)
    version_id = _resolve_version_id(session, business_id, version_int, scope)
    prev_model = (
        _load_prev_model(session, ws, business_id, version_int, scope)
        if model.get("domains") else None
    )
    return model, prev_model, version_id


def _compute_layout(
    model: dict, prev_model: dict | None, domain: str | None, column_mode: str,
) -> DiagramLayoutOut:
    """Compute the ELK layout for an already-loaded model. Pure CPU-bound
    work — takes no database session and performs no I/O other than the
    (local, subprocess-based) ELK layout call, so it is safe to run for as
    long as the algorithm needs without holding any connection open.
    """
    if not model.get("domains"):
        raise _ModelNotReadyError(
            "model has no domains — layout deferred until sync completes"
        )

    # Compute per-product change status vs the previous version so the frontend
    # can render modified/new badges on table nodes. Mirrors the pattern in
    # explorer.py for domain/product/attribute badges.
    diff = compute_model_diff(prev_model, model)
    product_change_status = diff.get("products", {})

    if domain:
        from . import diagram_layout

        layout = diagram_layout.compute_focal_layout(
            model, domain, column_mode, product_change_status
        )
    else:
        product_index = _build_product_index(model)
        fk_edges = _collect_fk_edges(model, product_index, domain)
        elk_graph, metadata = _build_elk_graph(
            model, domain, column_mode, product_change_status
        )
        elk_result = _run_elk_layout(elk_graph)
        layout = _extract_layout(elk_result, metadata, fk_edges)

    layout.domain_filter = domain
    layout.show_columns = column_mode != "hide"
    return layout


def _layout_error(exc: Exception) -> _LayoutError:
    """The cached form of a failed layout job: the original status (an
    ``HTTPException`` keeps its own, anything else is a 500) and a sanitized
    detail."""
    if isinstance(exc, HTTPException):
        return _LayoutError(exc.status_code, sanitize_error_detail(exc.detail), _now_ms())
    return _LayoutError(
        500, sanitize_error_message(f"Layout computation failed: {exc}"), _now_ms(),
    )


def _background_compute(
    session_factory, ws, business_id: str, version_int: int, scope: str,
    domain: str | None, column_mode: str, key: str,
) -> None:
    """Run layout computation in the background thread pool.

    Must receive a **callable** that opens a fresh SQLAlchemy session, not
    a session instance — the worker runs asynchronously after the HTTP
    request (or tracker poll loop) that submitted it has returned, and
    any session scoped to that caller is already closed by the time we
    get here. Opening our own session inside the worker guarantees
    we're querying against a live connection.

    Session lifecycle is split in two around the slow ELK computation: a
    short-lived session reads the model structure and releases (commits)
    before ``_compute_layout`` runs, and — only if there's a result worth
    persisting — a second, fresh session is opened afterwards to write the
    cache entry back. No session is ever held open across the CPU-bound
    layout algorithm.
    """
    # Worker has picked up the job — emit a heartbeat so polling clients
    # see the "last update" timestamp advance past enqueue time.
    _touch_heartbeat(key)
    try:
        with session_factory() as session:
            model, prev_model, version_id = _load_layout_inputs(
                session, ws, business_id, version_int, scope
            )
            session.commit()

        layout = _compute_layout(model, prev_model, domain, column_mode)

        with _cache_lock:
            _layout_cache[key] = layout

        # Persist to Lakebase so the cache survives app restarts and
        # redeploys. Opens a brand-new session rather than reusing the one
        # above — that one is done with the moment the read commits.
        if version_id:
            with session_factory() as session:
                _write_lakebase_layout(session, business_id, version_id, key, layout)
    except _ModelNotReadyError:
        # Model has no domains yet (sync not complete). Don't cache anything —
        # the next request will recompute once the model is ready.
        logger.debug("Layout deferred for %s: model not ready (no domains yet)", key)
    except Exception as e:
        logger.warning("Background prefetch failed for %s: %s", key, e)
        # Kept briefly so the viewer's next poll reports it instead of
        # re-queueing the same failing job (see ``_LAYOUT_ERROR_TTL_MS``).
        with _cache_lock:
            _layout_cache[key] = _layout_error(e)
    finally:
        with _in_progress_lock:
            _in_progress.pop(key, None)


@router.get(
    "/businesses/{business_id}/versions/{version_int}/{scope}/diagram",
    response_model=DiagramLayoutOut,
    operation_id="getDiagramLayout",
)
def get_diagram_layout(
    request: Request,
    business_id: str,
    version_int: int,
    scope: Annotated[str, PathParam(pattern="^(ecm|mvm)$")],
    session: Dependencies.Session,
    ws: Dependencies.Client,
    domain: Optional[str] = None,
    column_mode: str = "hide",
    prefetch: bool = False,
):
    """Compute and return a positioned ER diagram layout for a model version.

    column_mode: "hide" | "keys" | "all"
    prefetch: if true, queue computation in background and return 202 immediately
    """
    if column_mode not in ("hide", "keys", "all"):
        column_mode = "hide"

    key = _cache_key(business_id, version_int, scope, domain, column_mode)

    # Tier 1: in-memory cache (fastest)
    with _cache_lock:
        if key in _layout_cache:
            cached = _layout_cache[key]
            if isinstance(cached, _LayoutError):
                # Reported once, then dropped so the next request recomputes.
                # A warm-up request (prefetch) or a stale failure recomputes
                # at once: neither has a viewer waiting on that failure.
                del _layout_cache[key]
                fresh = _now_ms() - cached.at_ms < _LAYOUT_ERROR_TTL_MS
                if fresh and not prefetch:
                    raise HTTPException(cached.status_code, cached.detail)
            else:
                cached.domain_filter = domain
                cached.show_columns = column_mode != "hide"
                return cached

    # Tier 2: Lakebase cache (survives app restart). Don't gate behind prefetch
    # flag — a Lakebase hit is essentially free and returns instantly.
    lakebase_layout = _read_lakebase_layout(session, business_id, key)
    if lakebase_layout is not None:
        lakebase_layout.domain_filter = domain
        lakebase_layout.show_columns = column_mode != "hide"
        # Populate in-memory cache for subsequent calls
        with _cache_lock:
            _layout_cache[key] = lakebase_layout
        return lakebase_layout

    # The request-scoped `session` closes as soon as this handler returns, but
    # the prefetch worker runs asynchronously — hand the worker a factory that
    # opens its own session when it's time to do work. Lazy evaluation keeps
    # tests that stub _prefetch_pool.submit happy even if they don't set up
    # app.state.engine. expire_on_commit=False: a single-writer background
    # session that must survive past its own read-commit (see
    # ``_load_layout_inputs``'s docstring) into the CPU-bound ELK layout call
    # - any later touch of an ORM attribute loaded before that commit would
    # otherwise re-open a transaction that then idles across the layout
    # computation, the same leak shape traced against a live kickstart Run.
    session_factory = lambda: Session(
        bind=request.app.state.engine, expire_on_commit=False,
    )

    # Prefetch mode: queue in background, return 202 immediately
    if prefetch:
        with _in_progress_lock:
            if key not in _in_progress:
                _in_progress[key] = _now_ms()
                _prefetch_pool.submit(
                    _background_compute,
                    session_factory, ws, business_id, version_int, scope, domain, column_mode, key,
                )
        return _pending_response(key)

    # Normal mode: also compute in background and return 202
    # This avoids blocking uvicorn workers on large layouts
    with _in_progress_lock:
        if key not in _in_progress:
            _in_progress[key] = _now_ms()
            _prefetch_pool.submit(
                _background_compute,
                session_factory, ws, business_id, version_int, scope, domain, column_mode, key,
            )
    return _pending_response(key)


def _pending_response(key: str) -> JSONResponse:
    """Build the 202 heartbeat body for ``key``.

    Returns queue position (1-indexed), total pending jobs, and the last
    heartbeat timestamp. Defensive against the key having already completed
    between the 202 decision and this call: we fall back to a fresh
    ``now_ms`` + ``queue_position=None`` in that race.
    """
    with _in_progress_lock:
        keys = list(_in_progress.keys())
        total = len(keys)
        if key in _in_progress:
            # OrderedDict preserves insertion order; index() is O(N) but N is
            # tiny (bounded by the prefetch fan-out) so this is fine.
            position: Optional[int] = keys.index(key) + 1
            last_heartbeat_ms = _in_progress[key]
        else:
            position = None
            last_heartbeat_ms = _now_ms()
    body = DiagramPendingOut(
        status="computing",
        key=key,
        last_heartbeat_ms=last_heartbeat_ms,
        queue_position=position,
        total_in_queue=total,
    )
    return JSONResponse(status_code=202, content=body.model_dump())

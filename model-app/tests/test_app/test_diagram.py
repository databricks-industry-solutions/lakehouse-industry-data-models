"""Test the diagram.py module — ER diagram graph construction and layout extraction.

Tests the pure computation functions (graph building, node sizing, FK edge
collection, layout extraction) without invoking the ELK subprocess.
"""

import json
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

import pytest

from _test_app import make_test_app
from vibe_modeling.backend.diagram import (
    _build_elk_graph,
    _build_product_index,
    _cache_key,
    _collect_fk_edges,
    _determine_included_products,
    _extract_layout,
    _node_size,
    _product_node_meta,
    NODE_BORDER_PADDING,
    NODE_COLUMN_ROW_HEIGHT,
    NODE_HEADER_HEIGHT,
    NODE_MAX_VISIBLE_COLUMNS,
    NODE_MIN_WIDTH,
    NODE_SUMMARY_HEIGHT,
)
from vibe_modeling.backend.models import DiagramLayoutOut

@pytest.fixture
def mock_model():
    """A model matching the Lakebase-loaded format (uses 'name' key for products/attrs)."""
    return {
        "domains": [
            {
                "name": "sales",
                "division": "Commercial",
                "products": [
                    {
                        "name": "customer",
                        "table_name": "customer",
                        "type": "Master",
                        "primary_key": "customer_id",
                        "description": "Customer master data",
                        "attributes": [
                            {"name": "customer_id", "column_name": "customer_id",
                             "type": "BIGINT", "description": "PK", "foreign_key_to": ""},
                            {"name": "customer_name", "column_name": "customer_name",
                             "type": "STRING", "description": "Name", "foreign_key_to": ""},
                            {"name": "email", "column_name": "email",
                             "type": "STRING", "description": "Email", "foreign_key_to": ""},
                            {"name": "segment_id", "column_name": "segment_id",
                             "type": "BIGINT", "description": "FK",
                             "foreign_key_to": "sales.customer_segment.segment_id"},
                        ],
                    },
                    {
                        "name": "customer_segment",
                        "table_name": "customer_segment",
                        "type": "Reference",
                        "primary_key": "segment_id",
                        "description": "Segments",
                        "attributes": [
                            {"name": "segment_id", "column_name": "segment_id",
                             "type": "BIGINT", "description": "PK", "foreign_key_to": ""},
                            {"name": "segment_name", "column_name": "segment_name",
                             "type": "STRING", "description": "Name", "foreign_key_to": ""},
                        ],
                    },
                ],
            },
            {
                "name": "inventory",
                "division": "Operations",
                "products": [
                    {
                        "name": "product_catalog",
                        "table_name": "product_catalog",
                        "type": "Master",
                        "primary_key": "product_id",
                        "description": "Product catalog",
                        "attributes": [
                            {"name": "product_id", "column_name": "product_id",
                             "type": "BIGINT", "description": "PK", "foreign_key_to": ""},
                            {"name": "product_name", "column_name": "product_name",
                             "type": "STRING", "description": "Name", "foreign_key_to": ""},
                            {"name": "unit_price", "column_name": "unit_price",
                             "type": "DECIMAL(10,2)", "description": "Price", "foreign_key_to": ""},
                            {"name": "category_code", "column_name": "category_code",
                             "type": "STRING", "description": "Category", "foreign_key_to": ""},
                        ],
                    },
                ],
            },
        ],
    }


@pytest.fixture
def large_model():
    """A model with cross-domain FKs for edge testing."""
    return {
        "domains": [
            {
                "name": "sales",
                "division": "Commercial",
                "products": [
                    {
                        "name": "order",
                        "table_name": "order",
                        "primary_key": "order_id",
                        "attributes": [
                            {"name": "order_id", "type": "BIGINT", "foreign_key_to": ""},
                            {"name": "customer_id", "type": "BIGINT",
                             "foreign_key_to": "crm.customer.customer_id"},
                            {"name": "product_id", "type": "BIGINT",
                             "foreign_key_to": "inventory.product.product_id"},
                        ],
                    },
                ],
            },
            {
                "name": "crm",
                "division": "Commercial",
                "products": [
                    {
                        "name": "customer",
                        "table_name": "customer",
                        "primary_key": "customer_id",
                        "attributes": [
                            {"name": "customer_id", "type": "BIGINT", "foreign_key_to": ""},
                            {"name": "segment_id", "type": "BIGINT",
                             "foreign_key_to": "crm.segment.segment_id"},
                        ],
                    },
                    {
                        "name": "segment",
                        "table_name": "segment",
                        "primary_key": "segment_id",
                        "attributes": [
                            {"name": "segment_id", "type": "BIGINT", "foreign_key_to": ""},
                        ],
                    },
                ],
            },
            {
                "name": "inventory",
                "division": "Operations",
                "products": [
                    {
                        "name": "product",
                        "table_name": "product",
                        "primary_key": "product_id",
                        "attributes": [
                            {"name": "product_id", "type": "BIGINT", "foreign_key_to": ""},
                        ],
                    },
                ],
            },
        ],
    }


# ---------------------------------------------------------------------------
# Node sizing
# ---------------------------------------------------------------------------


class TestNodeSize:
    def test_hide_mode_returns_header_plus_summary(self):
        w, h = _node_size("customer", 10, 3, "hide")
        assert h == NODE_HEADER_HEIGHT + NODE_SUMMARY_HEIGHT + NODE_BORDER_PADDING

    def test_all_mode_caps_at_max_columns(self):
        w, h = _node_size("customer", 100, 5, "all")
        expected = (
            NODE_HEADER_HEIGHT
            + NODE_COLUMN_ROW_HEIGHT * NODE_MAX_VISIBLE_COLUMNS
            + NODE_SUMMARY_HEIGHT
            + NODE_BORDER_PADDING
        )
        assert h == expected


# ---------------------------------------------------------------------------
# Product index
# ---------------------------------------------------------------------------


class TestBuildProductIndex:
    def test_indexes_all_products_with_domain_info(self, mock_model):
        idx = _build_product_index(mock_model)
        assert "sales.customer" in idx
        assert "sales.customer_segment" in idx
        assert "inventory.product_catalog" in idx
        assert len(idx) == 3
        assert idx["sales.customer"]["_domain"] == "sales"
        assert idx["sales.customer"]["_division"] == "Commercial"


# ---------------------------------------------------------------------------
# FK edge collection
# ---------------------------------------------------------------------------


class TestCollectFkEdges:
    def test_collects_cross_domain_edges(self, large_model):
        idx = _build_product_index(large_model)
        edges = _collect_fk_edges(large_model, idx, None)
        # order->customer (cross), order->product (cross), customer->segment (intra)
        assert len(edges) == 3

    def test_broken_fk_reference_skipped(self):
        model = {
            "domains": [{
                "name": "d1",
                "products": [{
                    "name": "t1",
                    "attributes": [
                        {"name": "col", "foreign_key_to": "nonexistent.table.col"},
                    ],
                }],
            }],
        }
        idx = _build_product_index(model)
        edges = _collect_fk_edges(model, idx, None)
        assert len(edges) == 0


# ---------------------------------------------------------------------------
# Determine included products
# ---------------------------------------------------------------------------


class TestDetermineIncludedProducts:
    def test_filter_includes_related_products(self, large_model):
        idx = _build_product_index(large_model)
        edges = _collect_fk_edges(large_model, idx, "sales")
        included = _determine_included_products(large_model, idx, edges, "sales")
        # sales.order is in domain, crm.customer and inventory.product are related
        assert "sales.order" in included
        assert "crm.customer" in included
        assert "inventory.product" in included
        # crm.segment is not related to sales
        assert "crm.segment" not in included


# ---------------------------------------------------------------------------
# ELK graph construction
# ---------------------------------------------------------------------------


class TestBuildElkGraph:
    def test_graph_has_root_with_domain_children(self, mock_model):
        graph, meta = _build_elk_graph(mock_model, None, "hide")
        assert graph["id"] == "root"
        assert len(graph["children"]) == 2  # sales and inventory domains
        sales_domain = next(c for c in graph["children"] if c["id"] == "domain:sales")
        assert len(sales_domain["children"]) == 2  # customer, customer_segment
        # intra-domain edge inside the domain node
        assert "edges" in sales_domain
        assert len(sales_domain["edges"]) == 1
        # metadata for domain + product
        assert meta["domain:sales"]["domain"] == "sales"
        assert meta["sales.customer"]["product"] == "customer"
        assert meta["sales.customer"]["column_count"] == 4

    def test_inter_domain_edges_at_root(self, large_model):
        graph, _ = _build_elk_graph(large_model, None, "hide")
        assert "edges" in graph
        # order->customer (sales->crm) and order->product (sales->inventory)
        assert len(graph["edges"]) == 2

    def test_domain_filter_marks_external(self, large_model):
        _, meta = _build_elk_graph(large_model, "sales", "hide")
        assert not meta["domain:sales"]["is_external"]
        assert meta["domain:crm"]["is_external"]
        assert meta["domain:inventory"]["is_external"]

    def test_column_visibility_modes(self, mock_model):
        _, meta_hide = _build_elk_graph(mock_model, None, "hide")
        assert meta_hide["sales.customer"]["columns"] == []
        _, meta_all = _build_elk_graph(mock_model, None, "all")
        assert len(meta_all["sales.customer"]["columns"]) == 4


# ---------------------------------------------------------------------------
# Layout extraction
# ---------------------------------------------------------------------------


class TestExtractLayout:
    def test_extracts_nodes_and_groups(self):
        """Test that _extract_layout correctly reads a minimal ELK result."""
        elk_result = {
            "children": [{
                "id": "domain:sales",
                "x": 10,
                "y": 20,
                "width": 400,
                "height": 300,
                "children": [{
                    "id": "sales.customer",
                    "x": 5,
                    "y": 45,
                    "width": 200,
                    "height": 80,
                }],
            }],
        }
        metadata = {
            "domain:sales": {
                "domain": "sales",
                "division": "Commercial",
                "is_external": False,
                "product_count": 1,
            },
            "sales.customer": {
                "domain": "sales",
                "product": "customer",
                "table_name": "customer",
                "product_type": "Master",
                "description": "Customers",
                "columns": [],
                "column_count": 4,
                "fk_count": 1,
            },
        }
        edges = [{
            "source_node": "sales.customer",
            "source_column": "segment_id",
            "target_node": "sales.customer_segment",
            "target_column": "segment_id",
        }]

        layout = _extract_layout(elk_result, metadata, edges)
        assert len(layout.groups) == 1
        assert layout.groups[0].domain == "sales"
        assert layout.groups[0].x == 10

        assert len(layout.nodes) == 1
        node = layout.nodes[0]
        assert node.id == "sales.customer"
        # Absolute position: domain_x + table_x
        assert node.x == 15
        assert node.y == 65

        assert len(layout.edges) == 1
        assert layout.edges[0].source_node == "sales.customer"

# ---------------------------------------------------------------------------
# Cache key
# ---------------------------------------------------------------------------


class TestCacheKey:
    def test_same_inputs_same_key(self):
        k1 = _cache_key("b1", 1, "mvm", None, "hide")
        k2 = _cache_key("b1", 1, "mvm", None, "hide")
        assert k1 == k2

    def test_each_input_affects_key(self):
        # Render mode, domain filter, and scope all participate in the cache
        # key — flip each individually and confirm the key differs.
        base = _cache_key("b1", 1, "mvm", None, "hide")
        assert base != _cache_key("b1", 1, "mvm", None, "all")  # render mode
        assert base != _cache_key("b1", 1, "mvm", "sales", "hide")  # domain filter
        assert base != _cache_key("b1", 1, "ecm", None, "hide")  # scope


# ---------------------------------------------------------------------------
# Change status propagation (#128)
# ---------------------------------------------------------------------------


class TestChangeStatus:
    """Diagram nodes should carry per-product change_status so the UI can render
    new/modified/deleted badges on ER tables, mirroring the explorer.
    """

    def test_unchanged_by_default(self, mock_model):
        """With no diff map, every node is UNCHANGED."""
        from vibe_modeling.backend.models import ChangeStatus

        _, meta = _build_elk_graph(mock_model, None, "hide")
        assert meta["sales.customer"]["change_status"] == ChangeStatus.UNCHANGED

    def test_modified_product_marked(self, mock_model):
        """A diff marking a product MODIFIED propagates to node metadata."""
        from vibe_modeling.backend.models import ChangeStatus

        change_map = {("sales", "customer"): ChangeStatus.MODIFIED}
        _, meta = _build_elk_graph(mock_model, None, "hide", change_map)
        assert meta["sales.customer"]["change_status"] == ChangeStatus.MODIFIED
        # Other products unaffected
        assert meta["sales.customer_segment"]["change_status"] == ChangeStatus.UNCHANGED

    def test_new_product_marked(self, mock_model):
        from vibe_modeling.backend.models import ChangeStatus

        change_map = {("inventory", "product_catalog"): ChangeStatus.NEW}
        _, meta = _build_elk_graph(mock_model, None, "hide", change_map)
        assert meta["inventory.product_catalog"]["change_status"] == ChangeStatus.NEW

    def test_compute_diff_to_elk_graph(self):
        """End-to-end: given prev + new model with a modified product, the ELK
        graph metadata carries change_status=MODIFIED for that product.
        Mirrors the pattern in explorer.py where _compute_diff feeds domain/
        product/attribute change_status fields.
        """
        from vibe_modeling.backend.explorer import _compute_diff
        from vibe_modeling.backend.models import ChangeStatus

        prev = {
            "domains": [
                {
                    "name": "sales",
                    "products": [
                        {
                            "name": "customer",
                            "table_name": "customer",
                            "primary_key": "customer_id",
                            "attributes": [
                                {"name": "customer_id", "type": "BIGINT", "foreign_key_to": ""},
                                {"name": "name", "type": "STRING", "foreign_key_to": ""},
                            ],
                        },
                    ],
                },
            ],
        }
        new = {
            "domains": [
                {
                    "name": "sales",
                    "products": [
                        {
                            "name": "customer",
                            "table_name": "customer",
                            "primary_key": "customer_id",
                            "attributes": [
                                {"name": "customer_id", "type": "BIGINT", "foreign_key_to": ""},
                                # 'name' attr type changed → product is MODIFIED
                                {"name": "name", "type": "VARCHAR", "foreign_key_to": ""},
                            ],
                        },
                        {
                            "name": "new_table",
                            "table_name": "new_table",
                            "primary_key": "id",
                            "attributes": [
                                {"name": "id", "type": "BIGINT", "foreign_key_to": ""},
                            ],
                        },
                    ],
                },
            ],
        }
        diff = _compute_diff(prev, new)
        assert diff["products"][("sales", "customer")] == ChangeStatus.MODIFIED
        assert diff["products"][("sales", "new_table")] == ChangeStatus.NEW

        _, meta = _build_elk_graph(new, None, "hide", diff["products"])
        assert meta["sales.customer"]["change_status"] == ChangeStatus.MODIFIED
        assert meta["sales.new_table"]["change_status"] == ChangeStatus.NEW

    def test_extract_layout_surfaces_change_status(self):
        """_extract_layout must copy change_status from metadata onto DiagramNode."""
        from vibe_modeling.backend.models import ChangeStatus

        elk_result = {
            "children": [{
                "id": "domain:sales",
                "x": 0, "y": 0, "width": 400, "height": 300,
                "children": [{
                    "id": "sales.customer",
                    "x": 0, "y": 0, "width": 200, "height": 80,
                }],
            }],
        }
        metadata = {
            "domain:sales": {
                "domain": "sales", "division": "", "is_external": False, "product_count": 1,
            },
            "sales.customer": {
                "domain": "sales", "product": "customer", "table_name": "customer",
                "product_type": "", "description": "", "columns": [],
                "column_count": 1, "fk_count": 0,
                "change_status": ChangeStatus.MODIFIED,
            },
        }
        layout = _extract_layout(elk_result, metadata, [])
        assert len(layout.nodes) == 1
        assert layout.nodes[0].change_status == ChangeStatus.MODIFIED


# ---------------------------------------------------------------------------
# 202 heartbeat response (task #104)
# ---------------------------------------------------------------------------


class TestPendingHeartbeat:
    """The 202 "layout still computing" body should carry a heartbeat
    timestamp, queue position, and total-in-queue count so the frontend
    can show "we're alive, you're #N in queue" instead of an opaque
    spinner."""

    def _clear(self) -> None:
        from vibe_modeling.backend import diagram as diagram_mod

        with diagram_mod._in_progress_lock:
            diagram_mod._in_progress.clear()
        with diagram_mod._cache_lock:
            diagram_mod._layout_cache.clear()

    def test_pending_response_shape_first_in_queue(self):
        """When the polled key is the only pending job, queue_position=1
        and total_in_queue=1."""
        from vibe_modeling.backend import diagram as diagram_mod

        self._clear()
        key = "test-key-A"
        now = diagram_mod._now_ms()
        with diagram_mod._in_progress_lock:
            diagram_mod._in_progress[key] = now

        resp = diagram_mod._pending_response(key)
        assert resp.status_code == 202
        body = json.loads(resp.body)
        assert body["status"] == "computing"
        assert body["key"] == key
        assert body["queue_position"] == 1
        assert body["total_in_queue"] == 1
        # Heartbeat matches what we enqueued with (exact match since we
        # wrote it ourselves).
        assert body["last_heartbeat_ms"] == now
        self._clear()

    def test_pending_response_shape_third_in_queue(self):
        """A polled key inserted third should report queue_position=3 of 3."""
        from vibe_modeling.backend import diagram as diagram_mod

        self._clear()
        now = diagram_mod._now_ms()
        with diagram_mod._in_progress_lock:
            diagram_mod._in_progress["first"] = now
            diagram_mod._in_progress["second"] = now + 1
            diagram_mod._in_progress["third"] = now + 2

        resp = diagram_mod._pending_response("third")
        assert resp.status_code == 202
        body = json.loads(resp.body)
        assert body["queue_position"] == 3
        assert body["total_in_queue"] == 3
        assert body["key"] == "third"
        assert body["last_heartbeat_ms"] == now + 2
        self._clear()

    def test_pending_response_key_missing_returns_null_position(self):
        """If the key is no longer tracked (race: job completed between the
        202 decision and the body-building), position is None but the call
        still succeeds."""
        from vibe_modeling.backend import diagram as diagram_mod

        self._clear()
        with diagram_mod._in_progress_lock:
            diagram_mod._in_progress["other"] = diagram_mod._now_ms()

        resp = diagram_mod._pending_response("gone")
        assert resp.status_code == 202
        body = json.loads(resp.body)
        assert body["key"] == "gone"
        assert body["queue_position"] is None
        assert body["total_in_queue"] == 1  # still counts "other"
        assert body["last_heartbeat_ms"] > 0  # falls back to now_ms
        self._clear()

    def test_touch_heartbeat_updates_timestamp(self):
        """``_touch_heartbeat`` advances the stored heartbeat without
        changing queue order (OrderedDict key-replacement)."""
        from vibe_modeling.backend import diagram as diagram_mod

        self._clear()
        with diagram_mod._in_progress_lock:
            diagram_mod._in_progress["only"] = 1000  # small synthetic value

        diagram_mod._touch_heartbeat("only")
        with diagram_mod._in_progress_lock:
            updated = diagram_mod._in_progress["only"]
        assert updated > 1000  # advanced to real now_ms
        self._clear()

    def test_touch_heartbeat_unknown_key_is_noop(self):
        """Touching a key that isn't tracked must not create it."""
        from vibe_modeling.backend import diagram as diagram_mod

        self._clear()
        diagram_mod._touch_heartbeat("nope")
        with diagram_mod._in_progress_lock:
            assert "nope" not in diagram_mod._in_progress
        self._clear()

    def test_get_diagram_layout_202_returns_heartbeat_fields(
        self, tmp_path, monkeypatch
    ):
        """End-to-end: hitting the diagram endpoint when no cache exists
        should return a 202 with the new heartbeat/queue fields.

        We stub out the prefetch pool so the test is synchronous (no real
        ELK process launched)."""
        from vibe_modeling.backend import diagram as diagram_mod

        self._clear()

        # Stub the prefetch pool submit so the background job never runs
        # (and therefore never removes the key from _in_progress during
        # assertion).
        class _NoopFuture:
            def result(self, timeout=None):
                return None

        monkeypatch.setattr(
            diagram_mod._prefetch_pool,
            "submit",
            lambda *a, **kw: _NoopFuture(),
        )
        # Also prevent Lakebase lookups from hitting anything real.
        monkeypatch.setattr(
            diagram_mod,
            "_read_lakebase_layout",
            lambda *a, **kw: None,
        )

        from fastapi.testclient import TestClient

        app = make_test_app(diagram_mod.router)

        # Minimal dependency overrides. The 202 path doesn't actually touch
        # the session or workspace client (both are captured and submitted
        # to the stubbed pool).
        from vibe_modeling.backend.core._defaults import _WorkspaceClientDependency
        from vibe_modeling.backend.core.lakebase import _LakebaseDependency

        app.dependency_overrides[_LakebaseDependency.__call__] = lambda: object()
        app.dependency_overrides[_WorkspaceClientDependency.__call__] = lambda: object()

        client = TestClient(app)

        resp = client.get("/api/businesses/biz-1/versions/1/mvm/diagram")
        assert resp.status_code == 202
        body = resp.json()
        # Shape: existing contract preserved
        assert body["status"] == "computing"
        assert "key" in body and body["key"]
        # New fields from task #104
        assert "last_heartbeat_ms" in body
        assert isinstance(body["last_heartbeat_ms"], int)
        assert body["last_heartbeat_ms"] > 0
        assert body["queue_position"] == 1
        assert body["total_in_queue"] == 1

        # Second distinct key should land at position 2 of 2 (queue grew).
        resp2 = client.get(
            "/api/businesses/biz-2/versions/1/ecm/diagram?column_mode=keys"
        )
        assert resp2.status_code == 202
        body2 = resp2.json()
        assert body2["queue_position"] == 2
        assert body2["total_in_queue"] == 2

        self._clear()

    def test_background_compute_opens_its_own_session(self, monkeypatch):
        """Regression: the background worker must open a fresh SQLAlchemy
        session from the caller-supplied factory, not reuse a request-
        scoped session that's already closed by the time the worker runs.

        This guards the C-01 fix: passing a live Session into
        ``_prefetch_pool.submit`` produced a ``This session is closed``
        exception inside the worker (which then got cached as the string
        error and surfaced to the user as a 500 on the next poll).
        """
        from vibe_modeling.backend import diagram as diagram_mod

        self._clear()

        opened_sessions: list[object] = []

        class _FakeSession:
            def __enter__(self):
                opened_sessions.append(self)
                return self

            def __exit__(self, exc_type, exc, tb):
                return False

            def commit(self):
                pass

        def _factory():
            return _FakeSession()

        captured_session: dict = {}

        def _fake_load_layout_inputs(session, *_args, **_kwargs):
            captured_session["value"] = session
            # domains=[] short-circuits _compute_layout before it needs a
            # prev_model or a version_id, so no write-back session opens.
            return {"domains": []}, None, None

        monkeypatch.setattr(diagram_mod, "_load_layout_inputs", _fake_load_layout_inputs)

        diagram_mod._background_compute(
            _factory, None, "biz-1", 1, "mvm", None, "hide", "test-key-session"
        )

        # Factory must have been called exactly once — no session reuse.
        assert len(opened_sessions) == 1
        # The session passed to _load_layout_inputs must be the one the
        # factory produced, not a caller-supplied (possibly closed) one.
        assert captured_session["value"] is opened_sessions[0]
        self._clear()

    def test_background_compute_releases_read_session_before_layout(self, engine, monkeypatch):
        """Regression: the ELK layout computation (minutes of pure CPU/
        algorithm time on a big model, no DB or network I/O) must run with
        the read session already committed and released — never held open
        across it.

        This is the idle-in-transaction shape traced against a live
        kickstart Run: a Postgres backend whose last statement was a
        SELECT on ``businesses`` (matching ``Business`` load inside
        ``_load_model``/``_load_layout_inputs`` here), released only ~90s
        later by a pool ROLLBACK rather than an explicit app commit.
        """
        from sqlmodel import Session

        from vibe_modeling.backend import diagram as diagram_mod
        from vibe_modeling.backend.db_models import Business, Domain, ModelVersion

        self._clear()

        with Session(engine) as seed:
            seed.add(Business(id="biz-txn", name="Txn Co"))
            seed.add(ModelVersion(id="mv-txn", business_id="biz-txn", version=1, scope="ecm"))
            seed.add(Domain(version_id="mv-txn", name="sales"))
            seed.commit()

        opened_sessions: list[Session] = []

        def _factory():
            s = Session(engine)
            opened_sessions.append(s)
            return s

        seen_in_transaction: list[bool] = []

        def _fake_compute_layout(model, prev_model, domain, column_mode):
            read_session = opened_sessions[0]
            seen_in_transaction.append(read_session.in_transaction())
            return diagram_mod.DiagramLayoutOut(domain_filter=domain, show_columns=False)

        monkeypatch.setattr(diagram_mod, "_compute_layout", _fake_compute_layout)

        diagram_mod._background_compute(
            _factory, None, "biz-txn", 1, "ecm", None, "hide", "test-key-txn"
        )

        assert seen_in_transaction, "the layout computation should run at least once"
        assert all(v is False for v in seen_in_transaction), (
            "the ELK layout algorithm must run with the read transaction "
            "already released — holding it open across the CPU-bound "
            "computation is the idle-in-transaction leak this test guards."
        )
        self._clear()

    def test_background_compute_post_commit_attribute_touch_transaction_leak(
        self, engine, monkeypatch,
    ):
        """Regression for the live pg_stat_activity leak traced against a
        real kickstart run, applied to the diagram prefetch path.
        SQLAlchemy's default ``expire_on_commit=True`` marks every ORM
        object attached to a session as expired at its commit. If anything
        touches an attribute of one of those objects AFTER that commit but
        while the session is still open (e.g. building a cache key or log
        message off the loaded ``Business`` right before the read session's
        ``with`` block exits), the resulting refresh SELECT autobegins a
        transaction that is then never closed before the CPU-bound ELK
        layout call runs. ``expire_on_commit=False`` on the prefetch's
        session_factory (``get_diagram_layout`` / ``queue_layout_prefetch_
        for_version`` callers) is the fix.

        ``_load_layout_inputs`` itself only returns plain dict/str values
        today, so there's no reachable attribute touch on the real code
        path - this test exercises the underlying session mechanism the fix
        guards against (via a stand-in ``_load_layout_inputs`` that does the
        touch the live trace caught), so a future change that starts
        threading an ORM object through this path stays covered. A bare
        ``in_transaction()`` check right after the commit, with no
        intervening attribute touch (as in
        ``test_background_compute_releases_read_session_before_layout``
        above), would pass either way and miss this.
        """
        from sqlmodel import Session

        from vibe_modeling.backend import diagram as diagram_mod
        from vibe_modeling.backend.db_models import Business, Domain, ModelVersion

        self._clear()

        with Session(engine) as seed:
            seed.add(Business(id="biz-touch", name="Touch Co"))
            seed.add(ModelVersion(id="mv-touch", business_id="biz-touch", version=1, scope="ecm"))
            seed.add(Domain(version_id="mv-touch", name="sales"))
            seed.commit()

        def _run_with_session_kwargs(**session_kwargs) -> list[bool]:
            seen_in_transaction: list[bool] = []

            def _factory():
                return Session(engine, **session_kwargs)

            def _touching_load_layout_inputs(session, ws, business_id, version_int, scope):
                business = session.get(Business, business_id)
                # The commit a real read phase makes to release the session
                # before the slow work - expires `business` under the
                # default expire_on_commit=True.
                session.commit()
                # Stand-in for a later touch of that now-expired object
                # (e.g. a log/cache-key message built off it) before the
                # session hands off to the slow ELK computation.
                _ = business.name
                seen_in_transaction.append(session.in_transaction())
                return {"domains": []}, None, None

            monkeypatch.setattr(
                diagram_mod, "_load_layout_inputs", _touching_load_layout_inputs,
            )
            diagram_mod._background_compute(
                _factory, None, "biz-touch", 1, "ecm", None, "hide",
                f"test-key-touch-{session_kwargs}",
            )
            return seen_in_transaction

        # Pre-fix shape: default expire_on_commit=True - the touch re-opens
        # a transaction that is NOT closed before the layout call proceeds.
        leaked = _run_with_session_kwargs()
        assert leaked and any(v is True for v in leaked), (
            "expected the default expire_on_commit=True session to "
            "reproduce the leak when an ORM attribute is touched after a "
            "commit - if this fails, the regression trap below is not "
            "exercising anything"
        )

        # Fixed shape: matches get_diagram_layout's background
        # session_factory - the same touch must NOT leave a transaction open.
        safe = _run_with_session_kwargs(expire_on_commit=False)
        assert safe and all(v is False for v in safe), (
            "expire_on_commit=False must prevent the post-commit attribute "
            "touch from re-opening a transaction across the ELK layout call"
        )
        self._clear()


# ---------------------------------------------------------------------------
# Focal layout + four-side anchoring + orthogonal routing (Increment 1)
# Ported geometry from diagram-spikes/. TDD off the story acceptance lines.
# ---------------------------------------------------------------------------


from vibe_modeling.backend import diagram_layout as dl
from vibe_modeling.backend.models import (
    DiagramDomainGroup,
    DiagramEdge,
    DiagramNode,
)


def _node(nid, domain, x, y, w=200.0, h=72.0):
    return DiagramNode(
        id=nid, domain=domain, product=nid.split(".")[-1],
        table_name=nid.split(".")[-1], x=x, y=y, width=w, height=h,
    )


def _group(domain, x, y, w, h, external=False):
    return DiagramDomainGroup(
        id=f"domain:{domain}", domain=domain, x=x, y=y, width=w, height=h,
        is_external=external, product_count=1,
    )


class TestArrangeLine:
    def test_single_row_horizontal(self):
        sizes = [("a", 100.0, 50.0), ("b", 120.0, 60.0), ("c", 80.0, 40.0)]
        (bw, bh), coords = dl._arrange_line(sizes, vertical=False)
        # all three tables share a single row -> distinct, increasing x; same y
        ys = {round(coords[k][1], 3) for k in ("a", "b", "c")}
        assert len(ys) == 1
        xs = [coords[k][0] for k in ("a", "b", "c")]
        assert xs == sorted(xs) and len(set(xs)) == 3
        assert bw > 0 and bh > 0

    def test_vertical_column(self):
        sizes = [("a", 100.0, 50.0), ("b", 120.0, 60.0)]
        (bw, bh), coords = dl._arrange_line(sizes, vertical=True)
        xs = {round(coords[k][0], 3) for k in ("a", "b")}
        assert len(xs) == 1  # single column -> shared x
        assert coords["b"][1] > coords["a"][1]  # stacked downward

    def test_wrap_past_15(self):
        sizes = [(f"t{i}", 100.0, 40.0) for i in range(31)]
        (bw, bh), coords = dl._arrange_line(sizes, vertical=False, wrap=15)
        # 31 tables, wrap 15 -> 3 rows. Distinct y per row.
        rows = sorted({round(coords[k][1], 3) for k in coords})
        assert len(rows) == 3
        # every table placed
        assert len(coords) == 31

    def test_empty(self):
        (bw, bh), coords = dl._arrange_line([], vertical=False)
        assert coords == {}
        assert bw > 0 and bh > 0


class TestResolveOverlaps:
    def test_separates_overlapping_boxes(self):
        boxes = {
            "focal": [0.0, 0.0, 200.0, 200.0],
            "a": [50.0, 50.0, 200.0, 200.0],
        }
        dl._resolve_overlaps(boxes, pinned="focal", margin=45.0)
        # focal must not have moved
        assert boxes["focal"] == [0.0, 0.0, 200.0, 200.0]
        # 'a' pushed clear of focal (AABB no longer overlaps, ignoring margin)
        f, a = boxes["focal"], boxes["a"]
        overlap_x = min(f[0] + f[2], a[0] + a[2]) - max(f[0], a[0])
        overlap_y = min(f[1] + f[3], a[1] + a[3]) - max(f[1], a[1])
        assert overlap_x <= 0 or overlap_y <= 0

    def test_no_overlap_invariant_many_boxes(self):
        boxes = {"focal": [-100.0, -100.0, 200.0, 200.0]}
        for i in range(8):
            boxes[f"d{i}"] = [0.0, 0.0, 150.0, 150.0]  # all stacked on origin
        dl._resolve_overlaps(boxes, pinned="focal", margin=45.0)
        keys = list(boxes)
        for i in range(len(keys)):
            for j in range(i + 1, len(keys)):
                a, b = boxes[keys[i]], boxes[keys[j]]
                ox = min(a[0] + a[2], b[0] + b[2]) - max(a[0], b[0])
                oy = min(a[1] + a[3], b[1] + b[3]) - max(a[1], b[1])
                assert ox <= 0.5 or oy <= 0.5, f"{keys[i]} overlaps {keys[j]}"

    def test_cap_60_ring_fallback_guarantees_spacing(self):
        # 70 related boxes piled on the origin: the iterative solver can't
        # converge within the iter budget, so the ring fallback must place them
        # on a guaranteed-spaced ring with NO residual overlaps.
        boxes = {"focal": [-150.0, -150.0, 300.0, 300.0]}
        for i in range(70):
            boxes[f"d{i}"] = [0.0, 0.0, 200.0, 120.0]
        dl._resolve_overlaps(boxes, pinned="focal", margin=45.0)
        keys = list(boxes)
        for i in range(len(keys)):
            for j in range(i + 1, len(keys)):
                a, b = boxes[keys[i]], boxes[keys[j]]
                ox = min(a[0] + a[2], b[0] + b[2]) - max(a[0], b[0])
                oy = min(a[1] + a[3], b[1] + b[3]) - max(a[1], b[1])
                assert ox <= 0.5 or oy <= 0.5, f"{keys[i]} overlaps {keys[j]}"


class TestEndpointSide:
    def test_focal_table_picks_nearest_side_toward_other(self):
        # focal table at origin; other endpoint to the right -> "right"
        t = _node("f.a", "f", 0.0, 0.0)
        g = _group("f", -10.0, -10.0, 220.0, 92.0)
        focal_c = (100.0, 36.0)
        side = dl._endpoint_side(t, g, "f", focal_c, other_c=(1000.0, 36.0))
        assert side == "right"
        side2 = dl._endpoint_side(t, g, "f", focal_c, other_c=(-1000.0, 36.0))
        assert side2 == "left"

    def test_external_row_domain_exits_broadside(self):
        # external WIDE (row) domain above the focal -> exits its bottom
        t = _node("e.a", "e", 0.0, 0.0)
        g = _group("e", -10.0, -10.0, 600.0, 100.0, external=True)  # wide row
        focal_c = (300.0, 900.0)  # focal is below
        side = dl._endpoint_side(t, g, "f", focal_c, other_c=focal_c)
        assert side == "bottom"

    def test_external_column_domain_exits_side(self):
        t = _node("e.a", "e", 0.0, 0.0)
        g = _group("e", -10.0, -10.0, 120.0, 600.0, external=True)  # tall column
        focal_c = (900.0, 300.0)  # focal to the right
        side = dl._endpoint_side(t, g, "f", focal_c, other_c=focal_c)
        assert side == "right"


class TestPlacementAnchors:
    def _layout(self):
        # focal "f" centred; two external nodes both FK into f.a
        nodes = [
            _node("f.a", "f", 0.0, 0.0),
            _node("e1.x", "e1", 0.0, -400.0),
            _node("e2.y", "e2", 0.0, 400.0),
        ]
        groups = [
            _group("f", -10.0, -10.0, 220.0, 92.0),
            _group("e1", -10.0, -410.0, 220.0, 92.0, external=True),
            _group("e2", -10.0, 390.0, 220.0, 92.0, external=True),
        ]
        edges = [
            DiagramEdge(id="fk:e1.x.fa>f.a.id", source_node="e1.x",
                        source_column="fa", target_node="f.a", target_column="id"),
            DiagramEdge(id="fk:e2.y.fa>f.a.id", source_node="e2.y",
                        source_column="fa", target_node="f.a", target_column="id"),
        ]
        return DiagramLayoutOut(nodes=nodes, edges=edges, groups=groups, domain_filter="f")

    def test_returns_side_offset_and_coords_per_cross_edge(self):
        anchors = dl.placement_anchors(self._layout(), "f")
        assert set(anchors) == {"fk:e1.x.fa>f.a.id", "fk:e2.y.fa>f.a.id"}
        for v in anchors.values():
            # (s_side, s_offset, x1, y1, t_side, t_offset, x2, y2)
            assert len(v) == 8
            assert v[0] in ("left", "right", "top", "bottom")
            assert 0.0 <= v[1] <= 1.0
            assert v[4] in ("left", "right", "top", "bottom")
            assert 0.0 <= v[5] <= 1.0

    def test_distinct_offsets_when_sharing_a_side(self):
        # both edges land on f.a — their anchor points on f.a must differ
        anchors = dl.placement_anchors(self._layout(), "f")
        # the focal-side endpoint of each edge (target role) is on f.a
        p1 = (anchors["fk:e1.x.fa>f.a.id"][6], anchors["fk:e1.x.fa>f.a.id"][7])
        p2 = (anchors["fk:e2.y.fa>f.a.id"][6], anchors["fk:e2.y.fa>f.a.id"][7])
        assert p1 != p2


class TestOrthogonalRouter:
    def test_axis_aligned_segments(self):
        layout = TestPlacementAnchors()._layout()
        anchors = dl.placement_anchors(layout, "f")
        polys = dl.orthogonal_cross_domain(layout, anchors)
        assert polys
        for poly in polys.values():
            for (x1, y1), (x2, y2) in zip(poly, poly[1:]):
                # every segment must be horizontal or vertical
                assert abs(x1 - x2) < 1e-6 or abs(y1 - y2) < 1e-6

    def test_l_corner_not_offset(self):
        # mixed-axis (one horizontal stub, one vertical stub) -> single clean
        # corner, must stay orthogonal even with a lane offset.
        ps, pt = (0.0, 0.0), (100.0, 100.0)
        mids = dl._ortho_link(ps, pt, s_horiz=True, t_horiz=False, lane=20.0)
        assert len(mids) == 1
        # corner is at (pt.x, ps.y) — the lane must NOT shift it
        assert mids[0] == (100.0, 0.0)

    def test_z_link_offset_applied(self):
        ps, pt = (0.0, 0.0), (100.0, 80.0)
        mids = dl._ortho_link(ps, pt, s_horiz=True, t_horiz=True, lane=10.0)
        assert len(mids) == 2
        mx = (0.0 + 100.0) / 2 + 10.0
        assert mids[0][0] == mx and mids[1][0] == mx


class TestSideOf:
    def test_classifies_each_side(self):
        n = _node("f.a", "f", 0.0, 0.0, 200.0, 100.0)
        assert dl._side_of((0.0, 50.0), n) == "left"
        assert dl._side_of((200.0, 50.0), n) == "right"
        assert dl._side_of((100.0, 0.0), n) == "top"
        assert dl._side_of((100.0, 100.0), n) == "bottom"


class TestComputeFocalLayout:
    def test_cross_domain_anchors_and_waypoints_hide_mode(self, large_model):
        layout = dl.compute_focal_layout(large_model, "sales", "hide")
        assert layout.domain_filter == "sales"
        assert layout.show_columns is False
        # cross-domain edges (sales.order -> crm.customer, -> inventory.product)
        node_dom = {n.id: n.domain for n in layout.nodes}
        cross = [e for e in layout.edges
                 if node_dom.get(e.source_node) != node_dom.get(e.target_node)]
        assert cross, "expected cross-domain edges in focal view"
        for e in cross:
            assert e.waypoints, "hide-mode cross edges must carry waypoints"
            assert len(e.waypoints) >= 2

    def test_keys_mode_leaves_cross_waypoints_empty(self, large_model):
        layout = dl.compute_focal_layout(large_model, "sales", "keys")
        assert layout.show_columns is True
        for e in layout.edges:
            assert e.waypoints == []

    def test_intra_edges_carry_elk_routes(self, large_model):
        # focal=crm has an intra edge customer->segment
        layout = dl.compute_focal_layout(large_model, "crm", "hide")
        node_dom = {n.id: n.domain for n in layout.nodes}
        intra = [e for e in layout.edges
                 if node_dom.get(e.source_node) == "crm"
                 and node_dom.get(e.target_node) == "crm"]
        assert intra, "expected an intra-domain edge for crm"
        assert any(e.waypoints for e in intra), "intra edge should carry ELK route waypoints"

    def test_deterministic(self, large_model):
        a = dl.compute_focal_layout(large_model, "sales", "hide")
        b = dl.compute_focal_layout(large_model, "sales", "hide")
        assert a.model_dump_json() == b.model_dump_json()

    def test_edge_scope_only_focal_incident(self, large_model):
        # crm.segment is NOT related to sales -> no edge incident to it in the
        # sales focal view.
        layout = dl.compute_focal_layout(large_model, "sales", "hide")
        node_ids = {n.id for n in layout.nodes}
        assert "crm.segment" not in node_ids
        for e in layout.edges:
            assert e.source_node in node_ids and e.target_node in node_ids

    def test_even_ring_distinct_sectors(self):
        # focal with 4 related domains -> the related boxes occupy distinct
        # sectors around the focal (not stacked on one side).
        import math
        model = {"domains": [
            {"name": "f", "products": [
                {"name": "hub", "table_name": "hub", "primary_key": "id",
                 "attributes": [{"name": "id", "type": "BIGINT", "foreign_key_to": ""}]},
            ]},
        ]}
        for i in range(4):
            model["domains"].append({"name": f"r{i}", "products": [
                {"name": "t", "table_name": "t", "primary_key": "id", "attributes": [
                    {"name": "id", "type": "BIGINT", "foreign_key_to": ""},
                    {"name": "fk", "type": "BIGINT", "foreign_key_to": "f.hub.id"},
                ]},
            ]})
        layout = dl.compute_focal_layout(model, "f", "hide")
        fg = next(g for g in layout.groups if g.domain == "f")
        fcx, fcy = fg.x + fg.width / 2, fg.y + fg.height / 2
        angles = []
        for g in layout.groups:
            if g.domain == "f":
                continue
            cx, cy = g.x + g.width / 2, g.y + g.height / 2
            angles.append(round(math.atan2(cy - fcy, cx - fcx), 2))
        assert len(set(angles)) == len(angles), "related domains share a sector"

    def test_keys_mode_box_sizing_taller(self, large_model):
        # D2: column_mode threads into related-box sizing. keys/all related
        # nodes are taller than hide (they show key rows).
        hide = dl.compute_focal_layout(large_model, "sales", "hide")
        keys = dl.compute_focal_layout(large_model, "sales", "keys")
        h_hide = {n.id: n.height for n in hide.nodes}
        h_keys = {n.id: n.height for n in keys.nodes}
        # crm.customer has a PK + an FK -> key rows -> taller in keys mode
        assert h_keys["crm.customer"] >= h_hide["crm.customer"]

    def test_focal_nodes_carry_product_type(self, mock_model):
        # Regression: focal nodes must populate product_type (drives table color)
        # the SAME way the overview path does (info["type"]).
        layout = dl.compute_focal_layout(mock_model, "sales", "hide")
        by_id = {n.id: n for n in layout.nodes}
        assert by_id["sales.customer"].product_type == "Master"
        assert by_id["sales.customer_segment"].product_type == "Reference"

    def test_focal_nodes_carry_description(self, mock_model):
        layout = dl.compute_focal_layout(mock_model, "sales", "hide")
        by_id = {n.id: n for n in layout.nodes}
        assert by_id["sales.customer"].description == "Customer master data"

    def test_focal_nodes_columns_populated_keys_mode(self, mock_model):
        # keys/all modes must carry the column ports (id "domain.product.col"
        # with is_pk/is_fk) so the FE renders columns + binds edge handles.
        layout = dl.compute_focal_layout(mock_model, "sales", "keys")
        cust = next(n for n in layout.nodes if n.id == "sales.customer")
        assert cust.columns, "keys mode focal node must carry columns"
        by_id = {c.id: c for c in cust.columns}
        assert "sales.customer.customer_id" in by_id
        assert by_id["sales.customer.customer_id"].is_pk is True
        assert by_id["sales.customer.segment_id"].is_fk is True

    def test_focal_nodes_columns_populated_all_mode(self, mock_model):
        layout = dl.compute_focal_layout(mock_model, "sales", "all")
        cust = next(n for n in layout.nodes if n.id == "sales.customer")
        assert len(cust.columns) == 4
        assert all(c.id.startswith("sales.customer.") for c in cust.columns)

    def test_focal_nodes_columns_empty_hide_mode(self, mock_model):
        # hide mode must NOT carry columns (waypoint-driven, no column rows).
        layout = dl.compute_focal_layout(mock_model, "sales", "hide")
        for n in layout.nodes:
            assert n.columns == []

    def test_focal_groups_carry_division(self, mock_model):
        layout = dl.compute_focal_layout(mock_model, "sales", "hide")
        by_dom = {g.domain: g for g in layout.groups}
        assert by_dom["sales"].division == "Commercial"

    def test_focal_nodes_carry_change_status(self, mock_model):
        from vibe_modeling.backend.models import ChangeStatus

        change_map = {("sales", "customer"): ChangeStatus.MODIFIED}
        layout = dl.compute_focal_layout(
            mock_model, "sales", "hide", product_change_status=change_map
        )
        by_id = {n.id: n for n in layout.nodes}
        assert by_id["sales.customer"].change_status == ChangeStatus.MODIFIED
        assert by_id["sales.customer_segment"].change_status == ChangeStatus.UNCHANGED


class TestDiagramEdgeContract:
    def test_six_key_shape_and_defaults(self):
        e = DiagramEdge(id="fk:x", source_node="a.b", source_column="c",
                        target_node="d.e", target_column="f")
        keys = set(e.model_dump().keys())
        assert keys == {
            "id", "source_node", "source_column", "target_node", "target_column",
            "waypoints",
        }
        assert e.waypoints == []

    def test_tuple_list_json_round_trip(self):
        e = DiagramEdge(id="fk:x", source_node="a.b", source_column="c",
                        target_node="d.e", target_column="f",
                        waypoints=[(1.0, 2.0), (3.0, 4.0)])
        payload = e.model_dump_json()
        back = DiagramEdge(**json.loads(payload))
        assert [tuple(p) for p in back.waypoints] == [(1.0, 2.0), (3.0, 4.0)]


class TestProductNodeMetaColumnOrdering:
    """Item 1 (0.6.6): columns_meta sorts by (pk=0/fk=1/rest=2, name.lower())."""

    def _info(self):
        # Attrs deliberately out of order, mixing PK-only, FK-only, PK+FK, and plain columns.
        return {
            "_domain": "sales",
            "name": "order_line",
            "table_name": "order_line",
            "type": "Fact",
            "description": "",
            "attributes": [
                {"name": "zeta_plain", "column_name": "zeta_plain",
                 "type": "STRING", "description": "", "foreign_key_to": ""},
                {"name": "customer_id", "column_name": "customer_id",
                 "type": "BIGINT", "description": "",
                 "foreign_key_to": "sales.customer.customer_id"},
                {"name": "order_id", "column_name": "order_id",
                 "type": "BIGINT", "description": "", "foreign_key_to": ""},
                {"name": "alpha_plain", "column_name": "alpha_plain",
                 "type": "STRING", "description": "", "foreign_key_to": ""},
                {"name": "line_id", "column_name": "line_id",
                 "type": "BIGINT", "description": "",
                 "foreign_key_to": "sales.order_line.line_id"},
                {"name": "product_id", "column_name": "product_id",
                 "type": "BIGINT", "description": "",
                 "foreign_key_to": "sales.product.product_id"},
            ],
        }

    def test_columns_sorted_pk_fk_rest_each_alpha(self):
        from vibe_modeling.backend.models import ChangeStatus

        info = self._info()
        # order_id + line_id are PK; line_id is ALSO an FK (PK+FK -> PK group).
        pk_cols = {"order_id", "line_id"}
        meta = _product_node_meta(info, "sales.order_line", pk_cols, "all", {})
        names = [c["name"] for c in meta["columns"]]
        assert names == [
            "line_id", "order_id",  # PK group, alpha
            "customer_id", "product_id",  # FK group, alpha
            "alpha_plain", "zeta_plain",  # rest, alpha
        ]
        by_name = {c["name"]: c for c in meta["columns"]}
        assert by_name["line_id"]["is_pk"] is True
        assert by_name["line_id"]["is_fk"] is True

    def test_columns_order_is_stable_across_calls(self):
        info = self._info()
        pk_cols = {"order_id", "line_id"}
        first = [c["name"] for c in _product_node_meta(
            info, "sales.order_line", pk_cols, "all", {}
        )["columns"]]
        second = [c["name"] for c in _product_node_meta(
            info, "sales.order_line", pk_cols, "all", {}
        )["columns"]]
        assert first == second

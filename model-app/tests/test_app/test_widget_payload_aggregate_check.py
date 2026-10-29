"""Tests for ``finalize_widgets_or_raise`` — the per-value vibe offload +
aggregate widget-payload size check that gates ``run_now`` dispatch.

Covers:

* The unit-level branch matrix of ``finalize_widgets_or_raise``: short vs.
  long vibes, under-limit vs. over-limit aggregate, offload-helps vs.
  offload-doesn't-help, missing catalog, empty vibes.
* The two production call sites that invoke the helper:
  ``_generation_common.dispatch_generation_op`` and
  ``vibe_iterate.VibeIterate.dispatch``.
"""
from __future__ import annotations

from types import SimpleNamespace
from unittest.mock import MagicMock, patch

import pytest
from sqlmodel import Session

from vibe_modeling.backend.db_models import ModelVersion, Run
from vibe_modeling.backend.job_launcher import (
    plan_widget_payload,
    VIBE_INSTRUCTIONS_INLINE_LIMIT,
    WIDGET_PAYLOAD_LIMIT_BYTES,
    WidgetPayloadTooLargeError,
    _widget_payload_bytes,
    finalize_widgets_or_raise,
)
from vibe_modeling.backend.services.operations._generation_common import (
    dispatch_generation_op,
)
from vibe_modeling.backend.services.operations._protocol import OperationContext
from vibe_modeling.backend.services.operations.vibe_iterate import VibeIterate


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def _make_ws_with_upload(path_prefix: str = "/Volumes/cat/_metamodel/vol_root/business/biz/_vibe_inputs/"):
    """Mock WorkspaceClient that records `files.upload` calls.

    `write_vibe_instructions_to_volume` itself builds the path; we just
    need a mock that doesn't crash when called.
    """
    ws = MagicMock()
    ws.files.upload = MagicMock()
    return ws


def _widgets_with_filler(filler_size: int, vibes: str = "") -> dict[str, str]:
    """Build a synthetic widget map of approximately ``filler_size`` bytes
    in ``business_description`` plus the given vibe instructions."""
    return {
        "operation": "new base model",
        "business_name": "biz",
        "business_description": "a" * filler_size,
        "model_vibes": vibes,
        "deployment_catalog": "cat",
        "data_model_scopes": "MVM",
    }


# ---------------------------------------------------------------------------
# 1. Short vibes, small payload → no offload, no raise.
# ---------------------------------------------------------------------------


def test_short_vibes_small_payload_no_offload():
    ws = _make_ws_with_upload()
    short_vibes = "be concise"
    widgets = _widgets_with_filler(filler_size=200, vibes=short_vibes)
    original = dict(widgets)

    out = finalize_widgets_or_raise(
        ws,
        widgets,
        catalog="cat",
        business_name="biz",
        session_id="sid-1",
        raw_vibes=short_vibes,
    )

    ws.files.upload.assert_not_called()
    assert out == original
    assert out["model_vibes"] == short_vibes


# ---------------------------------------------------------------------------
# 2. Long vibes (per-value > 1800), payload still small → MUST offload.
# ---------------------------------------------------------------------------


def test_long_vibes_per_value_forces_offload_even_when_aggregate_fits():
    ws = _make_ws_with_upload()
    long_vibes = "v" * (VIBE_INSTRUCTIONS_INLINE_LIMIT + 700)  # 2500 chars
    widgets = _widgets_with_filler(filler_size=100, vibes=long_vibes)

    out = finalize_widgets_or_raise(
        ws,
        widgets,
        catalog="cat",
        business_name="biz",
        session_id="sid-2",
        raw_vibes=long_vibes,
    )

    assert ws.files.upload.call_count == 1
    # The widget value was rewritten to the Volume path, not the inline text.
    assert out["model_vibes"].startswith("/Volumes/")
    assert long_vibes not in out["model_vibes"]
    # The widget is the path the upload wrote to.
    assert out["model_vibes"] == ws.files.upload.call_args.args[0]


# ---------------------------------------------------------------------------
# 3. Short vibes, payload too large, offloading wouldn't help → no offload, raise.
# ---------------------------------------------------------------------------


def test_short_vibes_aggregate_overflow_offload_useless_no_offload_then_raise():
    ws = _make_ws_with_upload()
    short_vibes = "v" * 500  # under the per-value limit
    # Other fields together push well past the aggregate limit.
    huge_filler = WIDGET_PAYLOAD_LIMIT_BYTES + 3000  # ~12.5KB
    widgets = _widgets_with_filler(filler_size=huge_filler, vibes=short_vibes)

    with pytest.raises(WidgetPayloadTooLargeError) as exc_info:
        finalize_widgets_or_raise(
            ws,
            widgets,
            catalog="cat",
            business_name="biz",
            session_id="sid-3",
            raw_vibes=short_vibes,
        )

    # Did NOT waste a Volume write — offloading 500 bytes of vibes can't
    # bring 12KB+ under the limit.
    ws.files.upload.assert_not_called()

    err = exc_info.value
    assert err.total_bytes > WIDGET_PAYLOAD_LIMIT_BYTES
    assert len(err.top_fields) == 3
    # Top field has the largest size; uses UI labels.
    label, size = err.top_fields[0]
    assert label == "Business description"
    assert size >= huge_filler


# ---------------------------------------------------------------------------
# 4. Short vibes, payload borderline, offloading WOULD help → offload, no raise.
# ---------------------------------------------------------------------------


def test_short_vibes_aggregate_overflow_offload_rescues():
    ws = _make_ws_with_upload()
    # Vibes 1500 chars (under per-value limit) but big enough that
    # offloading drops the aggregate below the limit.
    vibes = "v" * 1500
    # Filler chosen so total > limit but total - len(vibes) + 200 <= limit.
    filler = WIDGET_PAYLOAD_LIMIT_BYTES - 700  # well under by itself
    widgets = _widgets_with_filler(filler_size=filler, vibes=vibes)

    pre_total = _widget_payload_bytes(widgets)
    assert pre_total > WIDGET_PAYLOAD_LIMIT_BYTES, (
        f"test setup invalid: pre-offload total {pre_total} not over limit"
    )

    out = finalize_widgets_or_raise(
        ws,
        widgets,
        catalog="cat",
        business_name="biz",
        session_id="sid-4",
        raw_vibes=vibes,
    )

    assert ws.files.upload.call_count == 1
    assert out["model_vibes"].startswith("/Volumes/")
    # Final widget map fits.
    assert _widget_payload_bytes(out) <= WIDGET_PAYLOAD_LIMIT_BYTES


# ---------------------------------------------------------------------------
# 5. Long vibes + huge other fields: still too large after the offload, so
#    it raises before writing the vibe file.
# ---------------------------------------------------------------------------


def test_long_vibes_aggregate_still_too_large_raises_before_writing():
    ws = _make_ws_with_upload()
    long_vibes = "v" * 5000  # over per-value limit
    huge_filler = WIDGET_PAYLOAD_LIMIT_BYTES + 4000
    widgets = _widgets_with_filler(filler_size=huge_filler, vibes=long_vibes)

    with pytest.raises(WidgetPayloadTooLargeError):
        finalize_widgets_or_raise(
            ws,
            widgets,
            catalog="cat",
            business_name="biz",
            session_id="sid-5",
            raw_vibes=long_vibes,
        )

    # The planned map (with the Volume path) is measured first: a refused
    # payload writes no file.
    ws.files.upload.assert_not_called()
    with pytest.raises(WidgetPayloadTooLargeError):
        plan_widget_payload(
            widgets, catalog="cat", business_name="biz", session_id="sid-5", raw_vibes=long_vibes,
        )


# ---------------------------------------------------------------------------
# 6. No catalog → can't offload, fall through.
# ---------------------------------------------------------------------------


def test_no_catalog_skips_offload_under_limit_no_raise():
    ws = _make_ws_with_upload()
    long_vibes = "v" * 5000
    widgets = _widgets_with_filler(filler_size=50, vibes=long_vibes)
    # Override the catalog on the widget map AND pass empty catalog.
    widgets["deployment_catalog"] = ""

    # Total here is dominated by the 5000-char vibes (~5KB) — under the
    # 9500-byte limit, so no raise even without offload.
    out = finalize_widgets_or_raise(
        ws,
        widgets,
        catalog="",
        business_name="biz",
        session_id="sid-6a",
        raw_vibes=long_vibes,
    )
    ws.files.upload.assert_not_called()
    # Vibes stay inline (no Volume to write to).
    assert out["model_vibes"] == long_vibes


def test_no_catalog_over_limit_raises_without_offload():
    ws = _make_ws_with_upload()
    long_vibes = "v" * 5000
    huge_filler = WIDGET_PAYLOAD_LIMIT_BYTES + 1000
    widgets = _widgets_with_filler(filler_size=huge_filler, vibes=long_vibes)
    widgets["deployment_catalog"] = ""

    with pytest.raises(WidgetPayloadTooLargeError):
        finalize_widgets_or_raise(
            ws,
            widgets,
            catalog="",
            business_name="biz",
            session_id="sid-6b",
            raw_vibes=long_vibes,
        )

    ws.files.upload.assert_not_called()


# ---------------------------------------------------------------------------
# 7. Empty vibes → no-op.
# ---------------------------------------------------------------------------


def test_empty_vibes_noop():
    ws = _make_ws_with_upload()
    widgets = _widgets_with_filler(filler_size=200, vibes="")
    original = dict(widgets)

    out = finalize_widgets_or_raise(
        ws,
        widgets,
        catalog="cat",
        business_name="biz",
        session_id="sid-7",
        raw_vibes="",
    )
    ws.files.upload.assert_not_called()
    assert out == original


# ---------------------------------------------------------------------------
# 8. WidgetPayloadTooLargeError message format — labels + sort order.
# ---------------------------------------------------------------------------


def test_error_message_uses_ui_labels_and_descending_order():
    ws = _make_ws_with_upload()
    short_vibes = "x" * 100
    # Construct widgets where we know the three biggest fields.
    widgets = {
        "operation": "new base model",
        "business_name": "biz",
        "business_description": "a" * (WIDGET_PAYLOAD_LIMIT_BYTES + 2000),
        "industry_alignment": "b" * 3000,
        "business_domains": "c" * 1500,
        "model_vibes": short_vibes,
        "deployment_catalog": "cat",
    }

    with pytest.raises(WidgetPayloadTooLargeError) as exc_info:
        finalize_widgets_or_raise(
            ws,
            widgets,
            catalog="cat",
            business_name="biz",
            session_id="sid-8",
            raw_vibes=short_vibes,
        )

    err = exc_info.value
    # total_bytes matches the actual payload size we built.
    assert err.total_bytes == _widget_payload_bytes(widgets)

    # Top-3 are sorted descending by size and use UI labels (not raw keys).
    labels = [name for name, _size in err.top_fields]
    sizes = [size for _name, size in err.top_fields]
    assert sizes == sorted(sizes, reverse=True)
    assert labels[0] == "Business description"
    assert labels[1] == "Industry alignment"
    assert labels[2] == "Business domains"
    # Raw widget keys must NOT leak into the labels.
    assert "business_description" not in labels
    assert "industry_alignment" not in labels


# ---------------------------------------------------------------------------
# 9. dispatch_generation_op offloads long vibes (the Zalando regression).
# ---------------------------------------------------------------------------


def test_dispatch_generation_op_offloads_long_vibes():
    long_vibes = "x" * 9000  # > per-value limit; > aggregate limit alone
    business = SimpleNamespace(
        name="zalando",
        description="short biz description",
        industry_alignment="retail",
    )
    ctx = SimpleNamespace(
        operation_id="op-9",
        params={
            "deployment_catalog": "vibe_modeling_test",
            "model_vibes": long_vibes,
            "cataloging_style": "One Catalog",
        },
        inherited_params={"runtime_budget_hours": 6},
    )
    ws = _make_ws_with_upload()
    session = MagicMock()
    session.get.return_value = None  # no existing RunOperation

    expected_path = (
        "/Volumes/vibe_modeling_test/_metamodel/vol_root/business/"
        "zalando/_vibe_inputs/sid-gen-9.txt"
    )

    with (
        patch(
            "vibe_modeling.backend.job_launcher"
            ".write_vibe_instructions_to_volume",
            return_value=expected_path,
        ) as write_mock,
        patch(
            "vibe_modeling.backend.services.operations._generation_common.launch_run",
            return_value=999_111,
        ) as launch_mock,
        patch(
            "vibe_modeling.backend.services.operations._generation_common."
            "generate_session_id",
            return_value="sid-gen-9",
        ),
    ):
        dispatch_generation_op(
            operation="generate ecm",
            data_model_scopes="ECM (Expanded Coverage Model)",
            ctx=ctx,
            ws=ws,
            session=session,
            business=business,
            job_id=42,
            warehouse_id="wh1",
        )

    assert write_mock.call_count == 1
    assert launch_mock.call_count == 1
    widgets_passed = launch_mock.call_args.args[2]
    assert widgets_passed["model_vibes"] == expected_path
    assert long_vibes not in widgets_passed["model_vibes"]


# ---------------------------------------------------------------------------
# 10. dispatch_generation_op raises with top-3 labels on aggregate overflow
#     when offloading the (short) vibes wouldn't help.
# ---------------------------------------------------------------------------


def test_dispatch_generation_op_raises_on_aggregate_overflow():
    short_vibes = "v" * 1000  # under per-value limit
    huge_description = "d" * (WIDGET_PAYLOAD_LIMIT_BYTES + 2000)
    business = SimpleNamespace(
        name="megacorp",
        description=huge_description,
        industry_alignment="retail",
    )
    ctx = SimpleNamespace(
        operation_id="op-10",
        params={
            "deployment_catalog": "vibe_modeling_test",
            "model_vibes": short_vibes,
            "cataloging_style": "One Catalog",
        },
        inherited_params={"runtime_budget_hours": 6},
    )
    ws = _make_ws_with_upload()
    session = MagicMock()
    session.get.return_value = None

    with (
        patch(
            "vibe_modeling.backend.job_launcher"
            ".write_vibe_instructions_to_volume",
        ) as write_mock,
        patch(
            "vibe_modeling.backend.services.operations._generation_common.launch_run",
            return_value=42,
        ) as launch_mock,
        patch(
            "vibe_modeling.backend.services.operations._generation_common."
            "generate_session_id",
            return_value="sid-gen-10",
        ),
    ):
        with pytest.raises(WidgetPayloadTooLargeError) as exc_info:
            dispatch_generation_op(
                operation="generate ecm",
                data_model_scopes="ECM (Expanded Coverage Model)",
                ctx=ctx,
                ws=ws,
                session=session,
                business=business,
                job_id=42,
                warehouse_id="wh1",
            )

    # Offloading short vibes wouldn't bring 11KB+ under 9500 → skipped.
    write_mock.assert_not_called()
    # We never reached launch_run because the helper raised first.
    launch_mock.assert_not_called()

    err = exc_info.value
    assert err.total_bytes > WIDGET_PAYLOAD_LIMIT_BYTES
    assert err.top_fields[0][0] == "Business description"


# ---------------------------------------------------------------------------
# 11. vibe_iterate.dispatch also offloads long vibes (sanity for the
#     unification — the original path that already had the offload still
#     works after the helper swap).
# ---------------------------------------------------------------------------


def test_vibe_iterate_dispatch_offloads_long_vibes(
    engine, seed_business
):
    """End-to-end through ``VibeIterate.dispatch``: the long-vibes path
    must hand a Volume path (not the raw 9KB) to ``run_now``.
    """
    long_vibes = "z" * 9000

    # Seed a parent ModelVersion + Run row so dispatch can resolve them.
    with Session(engine) as s:
        parent = ModelVersion(
            business_id=seed_business,
            version=1,
            status="completed",
            scope="ecm",
            uc_catalog="test_catalog",
        )
        s.add(parent)
        run = Run(
            business_id=seed_business,
            intent="vibe-iterate",
            status="pending",
            parameters_json="{}",
        )
        s.add(run)
        s.commit()
        s.refresh(parent)
        s.refresh(run)
        parent_id = parent.id
        run_id = run.id

    ctx = OperationContext(
        run_id=run_id,
        operation_id="op-vibe-iter-11",
        business_id=seed_business,
        parent_version_id=parent_id,
        params={
            "vibe_instructions": long_vibes,
            "deployment_catalog": "test_catalog",
        },
        inherited_params={"cataloging_style": "One Catalog"},
    )

    ws = _make_ws_with_upload()
    captured: dict[str, dict[str, str]] = {}

    def _run_now(**kw):
        captured["notebook_params"] = kw.get("notebook_params") or {}
        m = MagicMock()
        m.response.run_id = 12345
        return m

    ws.jobs.run_now.side_effect = _run_now

    primitive = VibeIterate()
    with Session(engine) as s:
        primitive.dispatch(ctx, ws, s)

    assert ws.files.upload.call_count == 1, (
        "long vibes should trigger a single Volume write"
    )
    notebook_params = captured["notebook_params"]
    assert notebook_params["model_vibes"].startswith("/Volumes/")
    assert long_vibes not in notebook_params["model_vibes"]

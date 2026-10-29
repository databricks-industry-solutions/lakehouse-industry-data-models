"""Scoped compile, agent_markdown (K1 markers) and included-only run linking.

Design: docs/superpowers/specs/2026-10-18-single-domain-vibe-scope-design.md
§5.2, §6, D8, D9, D12. Contract: integration guide §16.3 (K1 marker format).
"""

import json
import os
import re
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

from unittest.mock import MagicMock

import pytest
from sqlmodel import Session, select

from vibe_modeling.backend import router as router_mod
from vibe_modeling.backend.services.orchestrator import preflight as preflight_mod
from vibe_modeling.backend._compile import compile_inputs
from vibe_modeling.backend.db_models import (
    Attribute,
    Business,
    Domain,
    ForeignKeyLink,
    ModelVersion,
    Product,
    Run,
    RunInputLink,
    RunOperation,
    Subdomain,
    VibeInput,
    VibeInputContextLink,
)
from vibe_modeling.backend.models import RunIn

# The agent's own parser (5.3.3 ``_VIBE_INPUT_MARKER_RE``), per contract §3.
K1_RE = re.compile(r"<!--\s*vi:([A-Za-z0-9_.:-]+)\s+target=(.*?)\s*-->")


# --------------------------------------------------------------------------- #
# Seed helpers
# --------------------------------------------------------------------------- #


@pytest.fixture
def model(engine):
    """Business + completed ECM v1 with two domains, a product, an attribute,
    a subdomain and an FK. Returns a dict of ids/names."""
    with Session(engine) as s:
        b = Business(name="Acme", description="A test co", industry_alignment="Retail")
        s.add(b)
        s.commit()
        mv = ModelVersion(
            business_id=b.id, version=1, status="completed",
            deployment_status="draft", scope="ecm", uc_catalog="test_catalog",
        )
        s.add(mv)
        s.commit()
        sales = Domain(version_id=mv.id, name="Meter To Cash")
        ops = Domain(version_id=mv.id, name="Operations")
        s.add_all([sales, ops])
        s.commit()
        sub = Subdomain(version_id=mv.id, domain_id=sales.id, name="billing")
        s.add(sub)
        s.commit()
        orders = Product(version_id=mv.id, domain_id=sales.id, name="orders")
        assets = Product(version_id=mv.id, domain_id=ops.id, name="assets")
        s.add_all([orders, assets])
        s.commit()
        attr = Attribute(product_id=orders.id, name="order_id", type="string")
        s.add(attr)
        s.commit()
        fk = ForeignKeyLink(
            version_id=mv.id,
            source_domain="Operations", source_product="assets", source_column="order_id",
            target_domain="Meter To Cash", target_product="orders", target_column="order_id",
        )
        s.add(fk)
        s.commit()
        return {
            "bid": b.id, "vid": mv.id, "sales": sales.id, "ops": ops.id,
            "sub": sub.id, "orders": orders.id, "assets": assets.id,
            "attr": attr.id, "fk": fk.id,
        }


def _input(s, bid, text, priority="high", status="open") -> str:
    vi = VibeInput(business_id=bid, text=text, origin="user", priority=priority,
                   author="a@x.com", status=status)
    s.add(vi)
    s.commit()
    return vi.id


def _link(s, iid, vid, **anchor) -> None:
    s.add(VibeInputContextLink(input_id=iid, version_id=vid, **anchor))
    s.commit()


@pytest.fixture
def items(engine, model):
    """One input per anchor kind. Returns name -> input id."""
    m = model
    with Session(engine) as s:
        ids = {
            "model_wide": _input(s, m["bid"], "use snake_case"),
            "domain": _input(s, m["bid"], "tighten domain"),
            "product": _input(s, m["bid"], "rename orders"),
            "attribute": _input(s, m["bid"], "order id is a uuid"),
            "subdomain": _input(s, m["bid"], "split billing"),
            "other_domain": _input(s, m["bid"], "ops change"),
            "fk": _input(s, m["bid"], "drop that fk"),
        }
        _link(s, ids["model_wide"], m["vid"])
        _link(s, ids["domain"], m["vid"], domain_id=m["sales"])
        _link(s, ids["product"], m["vid"], product_id=m["orders"])  # product-only
        _link(s, ids["attribute"], m["vid"], attribute_id=m["attr"])  # attribute-only
        _link(s, ids["subdomain"], m["vid"], subdomain_id=m["sub"])  # subdomain-only
        _link(s, ids["other_domain"], m["vid"], product_id=m["assets"])
        _link(s, ids["fk"], m["vid"], fk_link_id=m["fk"])
    return ids


# --------------------------------------------------------------------------- #
# Scope filter
# --------------------------------------------------------------------------- #


def test_unscoped_compile_includes_everything(engine, model, items):
    with Session(engine) as s:
        out = compile_inputs(s, model["vid"], list(items.values()))
        none_scope = compile_inputs(s, model["vid"], list(items.values()), scope_domains=None)
        empty_scope = compile_inputs(s, model["vid"], list(items.values()), scope_domains=[])
    assert sorted(out.included_input_ids) == sorted(items.values())
    assert out.excluded_input_ids == []
    assert none_scope == out
    assert empty_scope == out


def test_scoped_compile_in_out_model_wide_subdomain(engine, model, items):
    with Session(engine) as s:
        # Normalized match: "meter_to_cash" == "Meter To Cash" under scope_key.
        out = compile_inputs(s, model["vid"], list(items.values()),
                             scope_domains=["meter_to_cash"])
    included = set(out.included_input_ids)
    # In scope: domain, product-only and attribute-only anchors (walked up to
    # their domain) and the subdomain-only anchor (via Subdomain.domain_id).
    assert included == {items["domain"], items["product"], items["attribute"],
                        items["subdomain"]}
    assert out.excluded_reasons == {
        items["model_wide"]: "model_wide_in_scoped_run",
        items["other_domain"]: "out_of_scope",
        # An FK belongs to its SOURCE domain (Operations).
        items["fk"]: "out_of_scope",
    }
    assert sorted(out.excluded_input_ids) == sorted(out.excluded_reasons)
    assert "use snake_case" not in out.markdown
    assert "ops change" not in out.markdown
    assert "## Model-wide" not in out.agent_markdown


def test_fk_in_scope_by_source_domain(engine, model, items):
    with Session(engine) as s:
        out = compile_inputs(s, model["vid"], [items["fk"], items["other_domain"]],
                             scope_domains=["Operations"])
    assert set(out.included_input_ids) == {items["fk"], items["other_domain"]}


def test_input_scope_domains_per_anchor_kind(engine, model, items):
    with Session(engine) as s:
        out = compile_inputs(s, model["vid"], list(items.values()))
    assert out.input_scope_domains == {
        items["model_wide"]: None,
        items["domain"]: "Meter To Cash",
        items["product"]: "Meter To Cash",
        items["attribute"]: "Meter To Cash",
        items["subdomain"]: "Meter To Cash",
        items["other_domain"]: "Operations",
        # An FK is anchored to its source domain, where the column lives.
        items["fk"]: "Operations",
    }


def test_input_scope_domains_equals_the_scoped_filter_for_every_kind(engine, model, items):
    """The pre-fill and the scoped compile share one rule: an input is included
    by scope [d] exactly when input_scope_domains maps it to d, and a None
    input is excluded by every scope."""
    with Session(engine) as s:
        domains = compile_inputs(s, model["vid"], list(items.values())).input_scope_domains
        for scope in ("Meter To Cash", "Operations"):
            scoped = compile_inputs(s, model["vid"], list(items.values()), scope_domains=[scope])
            assert scoped.input_scope_domains == domains
            assert set(scoped.included_input_ids) == {
                iid for iid, d in domains.items() if d == scope
            }
    assert set(domains.values()) == {None, "Meter To Cash", "Operations"}


def test_input_scope_domains_is_filled_unscoped_and_scoped_alike(engine, model, items):
    with Session(engine) as s:
        unscoped = compile_inputs(s, model["vid"], list(items.values()))
        scoped = compile_inputs(s, model["vid"], list(items.values()), scope_domains=["Operations"])
    assert scoped.input_scope_domains == unscoped.input_scope_domains


def test_input_scope_domains_none_without_a_link_and_absent_for_missing_or_deprecated(
    engine, model, items
):
    m = model
    with Session(engine) as s:
        unlinked = _input(s, m["bid"], "never anchored")
        deprecated = _input(s, m["bid"], "old", status="deprecated")
        _link(s, deprecated, m["vid"], domain_id=m["sales"])
        out = compile_inputs(s, m["vid"], [unlinked, deprecated, "missing-id", items["domain"]])
    assert out.input_scope_domains == {unlinked: None, items["domain"]: "Meter To Cash"}
    assert out.excluded_reasons[unlinked] == "no_anchor_on_version"


def test_input_scope_domains_follows_the_requested_version(engine, model, items):
    """An input anchored on v1 only has no domain on v2."""
    m = model
    with Session(engine) as s:
        v2 = ModelVersion(
            business_id=m["bid"], version=2, status="completed",
            deployment_status="draft", scope="ecm", uc_catalog="test_catalog",
        )
        s.add(v2)
        s.commit()
        d2 = Domain(version_id=v2.id, name="Billing")
        s.add(d2)
        s.commit()
        _link(s, items["model_wide"], v2.id, domain_id=d2.id)
        out = compile_inputs(s, v2.id, [items["model_wide"], items["domain"]])
    assert out.input_scope_domains == {items["model_wide"]: "Billing", items["domain"]: None}


def test_scoped_exclusion_leaves_selection_and_status_untouched(engine, model, items):
    with Session(engine) as s:
        vi = s.get(VibeInput, items["other_domain"])
        vi.selected_for_run = True
        s.add(vi)
        s.commit()
        compile_inputs(s, model["vid"], [items["other_domain"]], scope_domains=["Meter To Cash"])
    with Session(engine) as s:
        vi = s.get(VibeInput, items["other_domain"])
        assert vi.selected_for_run is True
        assert vi.status == "open"
        assert vi.consumed is False


def test_markdown_byte_identical_with_and_without_scope(engine, model, items):
    """When the scope excludes nothing, ``markdown`` and ``agent_markdown`` are
    unchanged by the scope; for an excluding scope, ``markdown`` equals the
    unscoped compile of the included ids."""
    in_scope = [items["domain"], items["product"], items["attribute"], items["subdomain"]]
    with Session(engine) as s:
        plain = compile_inputs(s, model["vid"], in_scope)
        scoped = compile_inputs(s, model["vid"], in_scope, scope_domains=["Meter To Cash"])
        wide = compile_inputs(s, model["vid"], list(items.values()),
                              scope_domains=["Meter To Cash"])
    assert scoped.markdown == plain.markdown
    assert scoped.agent_markdown == plain.agent_markdown
    assert scoped.blocks == plain.blocks
    assert wide.markdown == plain.markdown


# --------------------------------------------------------------------------- #
# agent_markdown: inline anchor + K1 markers
# --------------------------------------------------------------------------- #


def test_agent_markdown_targets_and_round_trip(engine, model, items):
    with Session(engine) as s:
        out = compile_inputs(s, model["vid"], list(items.values()))
    parsed = dict(K1_RE.findall(out.agent_markdown))
    assert parsed == {
        items["model_wide"]: "model",
        items["domain"]: "Meter To Cash",
        items["product"]: "Meter To Cash.orders",
        items["attribute"]: "Meter To Cash.orders.order_id",
        items["subdomain"]: "Meter To Cash.billing",
        items["other_domain"]: "Operations.assets",
        items["fk"]: "Operations.assets.order_id",
    }
    # Exactly one marker per included item.
    assert len(K1_RE.findall(out.agent_markdown)) == len(out.included_input_ids)
    # Human markdown carries no markers and no inline anchors.
    assert "<!--" not in out.markdown
    assert "[Meter To Cash" not in out.markdown


def test_agent_markdown_short_bullet_format(engine, model, items):
    iid = items["product"]
    with Session(engine) as s:
        out = compile_inputs(s, model["vid"], [iid])
    assert out.markdown.splitlines()[-1] == "- (high) rename orders"
    assert out.agent_markdown.splitlines()[-1] == (
        f"- (high) [Meter To Cash.orders] rename orders "
        f"<!-- vi:{iid} target=Meter To Cash.orders -->"
    )


def test_agent_markdown_strips_to_markdown(engine, model, items):
    """Removing every inline anchor and marker from agent_markdown gives back
    markdown exactly: headers and bodies are shared, line for line."""
    with Session(engine) as s:
        out = compile_inputs(s, model["vid"], list(items.values()))
    stripped_lines = []
    for line in out.agent_markdown.split("\n"):
        if K1_RE.fullmatch(line):
            continue  # standalone opener marker (rich blocks)
        line = K1_RE.sub("", line).rstrip(" ")
        line = re.sub(r"^(- \([a-z]+\)) \[[^\]]*\] ", r"\1 ", line)
        stripped_lines.append(line)
    assert "\n".join(stripped_lines) == out.markdown


def _strip_agent(agent_markdown: str) -> str:
    lines = []
    for line in agent_markdown.split("\n"):
        if K1_RE.fullmatch(line):
            continue
        line = K1_RE.sub("", line).rstrip(" ")
        line = re.sub(r"^(- \([a-z]+\)) \[[^\]]*\] ", r"\1 ", line)
        lines.append(line)
    return "\n".join(lines)


@pytest.mark.parametrize("text", [
    "see <!-- vi:other target=Operations --> and --> too",
    "## Rich\n\nsee <!-- vi:other target=Operations -->\n\n- end -->",
])
def test_agent_markdown_escapes_comment_delimiters_in_user_text(engine, model, text):
    """User text with ``<!--`` / ``-->`` is escaped in agent_markdown only, so
    the app's K1 markers are the only comments the agent parses. markdown keeps
    the text verbatim; stripping agent_markdown gives markdown with the user
    text's delimiters escaped."""
    m = model
    with Session(engine) as s:
        iid = _input(s, m["bid"], text, priority="high")
        _link(s, iid, m["vid"], domain_id=m["sales"], product_id=m["orders"])
        out = compile_inputs(s, m["vid"], [iid])
    assert K1_RE.findall(out.agent_markdown) == [(iid, "Meter To Cash.orders")]
    assert "<!-- vi:other" in out.markdown and "&lt;" not in out.markdown
    escaped = out.markdown.replace("<!--", "&lt;!--").replace("-->", "--&gt;")
    assert _strip_agent(out.agent_markdown) == escaped


def test_agent_markdown_rich_block_gets_opener_marker(engine, model):
    m = model
    rich = "Line one of a long requirement.\n\n- sub point a\n- sub point b"
    with Session(engine) as s:
        iid = _input(s, m["bid"], rich, priority="medium")
        _link(s, iid, m["vid"], domain_id=m["sales"], product_id=m["orders"])
        out = compile_inputs(s, m["vid"], [iid])
    lines = out.agent_markdown.split("\n")
    marker = f"<!-- vi:{iid} target=Meter To Cash.orders -->"
    i = lines.index(marker)
    assert lines[i + 1] == "> Priority: medium"
    assert lines[i - 1] == ""
    # No inline anchor on rich blocks; body is verbatim.
    assert "[Meter To Cash.orders]" not in out.agent_markdown
    assert "- sub point a" in lines
    assert "<!--" not in out.markdown
    assert K1_RE.findall(out.agent_markdown) == [(iid, "Meter To Cash.orders")]


def test_agent_markdown_empty_selection(engine, model):
    with Session(engine) as s:
        out = compile_inputs(s, model["vid"], [], scope_domains=["Operations"])
    assert out.markdown == "" and out.agent_markdown == ""


# --------------------------------------------------------------------------- #
# Router: compile into instructions + included-only links
# --------------------------------------------------------------------------- #


def _run_in(vid, input_ids, **kw) -> RunIn:
    return RunIn(intent="vibe-iterate", version_id=vid, parent_version_id=vid,
                 input_ids=input_ids, **kw)


def test_compile_into_instructions_sends_agent_markdown_and_scope(engine, model, items):
    ids = [items["product"], items["other_domain"]]
    with Session(engine) as s:
        data = _run_in(model["vid"], ids, vibe_scope="some_domains",
                       vibe_scope_domains=["Meter To Cash"])
        compiled = preflight_mod._compile_inputs_into_instructions(s, model["vid"], data)
    assert compiled is not None
    assert data.vibe_instructions == compiled.agent_markdown
    assert compiled.included_input_ids == [items["product"]]
    assert compiled.excluded_reasons == {items["other_domain"]: "out_of_scope"}
    assert preflight_mod._included_input_ids(data, compiled) == [items["product"]]


def test_compile_into_instructions_ignores_domains_when_all_domains(engine, model, items):
    ids = [items["product"], items["other_domain"]]
    with Session(engine) as s:
        data = _run_in(model["vid"], ids, vibe_scope_domains=["Meter To Cash"])
        compiled = preflight_mod._compile_inputs_into_instructions(s, model["vid"], data)
    assert sorted(compiled.included_input_ids) == sorted(ids)


def test_compile_into_instructions_noop_without_inputs(engine, model):
    with Session(engine) as s:
        data = _run_in(model["vid"], [], vibe_instructions="free text")
        assert preflight_mod._compile_inputs_into_instructions(s, model["vid"], data) is None
    assert data.vibe_instructions == "free text"
    assert preflight_mod._included_input_ids(data, None) == []


def test_stored_included_input_ids_fallback():
    f = router_mod._stored_included_input_ids
    assert f({"included_input_ids": ["a"], "input_ids": ["a", "b"]}) == ["a"]
    assert f({"included_input_ids": [], "input_ids": ["a"]}) == []
    assert f({"input_ids": ["a", "b"]}) == ["a", "b"]
    assert f({}) == []
    assert f(None) == []


def _links(engine, run_id) -> list[str]:
    with Session(engine) as s:
        return sorted(lk.input_id for lk in s.exec(
            select(RunInputLink).where(RunInputLink.run_id == run_id)).all())


def test_scoped_launch_links_only_sent_items(
    client_with_agent, mock_ws, engine, model, items, monkeypatch
):
    """Orchestrator vibe-iterate launch under Some Domains: only the in-scope
    item is linked and recorded; the excluded one stays selected and open.
    Preflight is stubbed so this tests the link sites, not the scope blockers."""
    monkeypatch.setattr(preflight_mod, "_collect_vibe_scope_blockers", lambda *a, **k: [])
    mock_ws.jobs.run_now.return_value = MagicMock(run_id=81001)
    with Session(engine) as s:
        vi = s.get(VibeInput, items["other_domain"])
        vi.selected_for_run = True
        s.add(vi)
        s.commit()
    body = {
        "intent": "vibe-iterate",
        "parent_version_id": model["vid"],
        "version_id": model["vid"],
        "catalog": "test_catalog",
        "cataloging_style": "One Catalog",
        "vibe_instructions": "",
        "input_ids": [items["product"], items["other_domain"]],
        "vibe_scope": "some_domains",
        "vibe_scope_domains": ["Meter To Cash"],
    }
    r = client_with_agent.post(f"/api/businesses/{model['bid']}/runs", json=body)
    assert r.status_code == 200, r.text
    run_id = r.json()["id"]
    assert _links(engine, run_id) == [items["product"]]
    with Session(engine) as s:
        run = s.get(Run, run_id)
        params = json.loads(run.parameters_json)
        assert params["included_input_ids"] == [items["product"]]
        assert params["input_ids"] == [items["product"], items["other_domain"]]
        assert f"<!-- vi:{items['product']} target=Meter To Cash.orders -->" \
            in run.vibe_instructions_text
        assert items["other_domain"] not in run.vibe_instructions_text
        vi = s.get(VibeInput, items["other_domain"])
        assert vi.selected_for_run is True and vi.consumed is False


def test_unscoped_launch_does_not_link_deprecated(
    client_with_agent, mock_ws, engine, model, items
):
    """D12: an unscoped run no longer links a deprecated (never-sent) item."""
    mock_ws.jobs.run_now.return_value = MagicMock(run_id=81002)
    with Session(engine) as s:
        dep = _input(s, model["bid"], "stale", status="deprecated")
        _link(s, dep, model["vid"], domain_id=model["sales"])
    body = {
        "intent": "vibe-new-ecm-mvm",
        "parent_version_id": model["vid"],
        "catalog": "test_catalog",
        "cataloging_style": "One Catalog",
        "ecm_schema_prefix": "ecm_",
        "mvm_schema_prefix": "mvm_",
        "vibe_instructions": "",
        "input_ids": [items["domain"], dep],
    }
    r = client_with_agent.post(f"/api/businesses/{model['bid']}/runs", json=body)
    assert r.status_code == 200, r.text
    run_id = r.json()["id"]
    assert _links(engine, run_id) == [items["domain"]]
    with Session(engine) as s:
        params = json.loads(s.get(Run, run_id).parameters_json)
    assert params["included_input_ids"] == [items["domain"]]


# --------------------------------------------------------------------------- #
# retry_run re-links only included_input_ids
# --------------------------------------------------------------------------- #


def _failed_run(engine, model, params, *, orchestrated: bool) -> str:
    with Session(engine) as s:
        run = Run(business_id=model["bid"], version_id=model["vid"],
                  intent="vibe-iterate", status="failed",
                  parameters_json=json.dumps(params))
        s.add(run)
        s.commit()
        if orchestrated:
            s.add(RunOperation(run_id=run.id, step_index=0, operation_name="vibe_iterate",
                               params_json="{}", status="failed"))
            s.commit()
        return run.id


def test_orchestrator_retry_relinks_only_included(
    client_with_agent, mock_tracker, engine, model, items
):
    params = {"input_ids": [items["product"], items["other_domain"]],
              "included_input_ids": [items["product"]]}
    run_id = _failed_run(engine, model, params, orchestrated=True)
    mock_tracker.orchestrator.resume = MagicMock()
    r = client_with_agent.post(f"/api/businesses/{model['bid']}/runs/{run_id}/retry")
    assert r.status_code == 200, r.text
    assert _links(engine, run_id) == [items["product"]]


def test_orchestrator_retry_older_run_falls_back_to_input_ids(
    client_with_agent, mock_tracker, engine, model, items
):
    params = {"input_ids": [items["product"], items["other_domain"]]}
    run_id = _failed_run(engine, model, params, orchestrated=True)
    mock_tracker.orchestrator.resume = MagicMock()
    r = client_with_agent.post(f"/api/businesses/{model['bid']}/runs/{run_id}/retry")
    assert r.status_code == 200, r.text
    assert _links(engine, run_id) == sorted([items["product"], items["other_domain"]])


def test_legacy_retry_relinks_included_and_keeps_it_out_of_widgets(
    client_with_agent, mock_ws, engine, model, items
):
    mock_ws.jobs.run_now.return_value = MagicMock(run_id=81003)
    params = {"operation": "vibe modeling of version", "model_vibes": "x", "deployment_catalog": "test_catalog",
              "included_input_ids": [items["product"]]}
    run_id = _failed_run(engine, model, params, orchestrated=False)
    r = client_with_agent.post(f"/api/businesses/{model['bid']}/runs/{run_id}/retry")
    assert r.status_code == 200, r.text
    assert _links(engine, run_id) == [items["product"]]
    sent = mock_ws.jobs.run_now.call_args.kwargs["notebook_params"]
    assert sent.get("model_vibes") == "x"
    assert "included_input_ids" not in sent
    assert all(isinstance(v, str) for v in sent.values())
    with Session(engine) as s:
        stored = json.loads(s.get(Run, run_id).parameters_json)
    assert stored["included_input_ids"] == [items["product"]]


def test_legacy_launch_always_records_included_input_ids(
    client_with_agent, mock_ws, engine, model, monkeypatch
):
    """The legacy launch path records ``included_input_ids`` even when empty,
    like the orchestrator path, so a retry never falls back to ``input_ids``."""
    monkeypatch.setattr(preflight_mod, "_orchestrator_intent_registered", lambda _i: False)
    mock_ws.jobs.run_now.return_value = MagicMock(run_id=81004)
    body = {
        "intent": "install",
        "version_id": model["vid"],
        "catalog": "test_catalog",
        "cataloging_style": "One Catalog",
    }
    r = client_with_agent.post(f"/api/businesses/{model['bid']}/runs", json=body)
    assert r.status_code == 200, r.text
    with Session(engine) as s:
        params = json.loads(s.get(Run, r.json()["id"]).parameters_json)
    assert params["included_input_ids"] == []

"""v5.1.4 vibe_scope: widget parsing, preflight validation and setup branching.

Behavioral tests call the production code (parse_vibe_scope,
_validate_required_widget_values, step_setup_and_clean with Spark stubbed out).
They fail on pre-patch 5.1.3 (the symbols and branches do not exist) and pass
on 5.1.4 (CLAUDE.md 8.10 fail-pre / pass-post).
"""
import copy
import json
import re
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent))
import conftest  # noqa: F401,E402
import agent_helpers as ah  # noqa: E402
from notebook_source_util import notebook_concat_source, slice_function_source  # noqa: E402

REPO = Path(__file__).resolve().parents[3]
AIRLINES = REPO / "data-models" / "airlines" / "v1" / "mvm" / "model.json"
RAW = json.loads(AIRLINES.read_text())
VOV = "vibe modeling of version"
NEW_BASE = "new base model"


@pytest.fixture(autouse=True)
def _isolate_runtime():
    pinned = set(ah._USER_PINNED_DOMAINS_RUNTIME)
    yield
    ah.set_vibe_scope_runtime(None)
    ah._USER_PINNED_DOMAINS_RUNTIME.clear()
    ah._USER_PINNED_DOMAINS_RUNTIME.update(pinned)


def _legacy_business_domains_parse(raw):
    out = []
    if raw:
        out = [t.strip().lower() for t in str(raw).replace(";", ",").split(",") if t.strip()]
    seen = set()
    return [d for d in out if not (d in seen or seen.add(d))]


def _validate(operation=VOV, **kw):
    base = dict(operation=operation, business_name="Airlines", business_description="An airline.",
                model_version="1", deployment_catalog="cat", context_file_loaded=True, model_folder="/Volumes/x",
                model_vibes="add nickname to crew.member")
    base.update(kw)
    return ah._validate_required_widget_values(**base)


@pytest.mark.parametrize("raw,expected", [
    (None, "all"), ("", "all"), ("All Domains", "all"), ("all domains", "all"), ("ALL_DOMAINS", "all"),
    ("Some Domains", "domains"), ("some-domains", "domains"), ("SOME_DOMAINS", "domains"), ("domains", "domains"),
    ("Some Subdomains", "subdomains"), ("some sub-domains", "subdomains"), ("SOME_SUBDOMAINS", "subdomains"),
    ("subdomains", "subdomains"),
])
def test_normalize_mode_tolerates_case_and_separators(raw, expected):
    assert ah._normalize_vibe_scope_mode(raw) == expected


@pytest.mark.parametrize("raw", ["Most Domains", "some", "domain", "every domain", "All Products"])
def test_normalize_mode_rejects_unknown(raw):
    assert ah._normalize_vibe_scope_mode(raw) is None


@pytest.mark.parametrize("raw", [
    "", None, "crew", "Crew, Flight", "crew;flight", " crew , crew ,  ,FLIGHT;", "a.b, c.d;a.b", "x,,y",
])
def test_split_domain_list_is_the_legacy_business_domains_tokenizer(raw):
    assert ah._split_domain_list(raw) == _legacy_business_domains_parse(raw)


def test_setup_uses_the_shared_tokenizer_for_the_legacy_parse():
    body = slice_function_source("step_setup_and_clean")
    assert "_split_domain_list(user_data_domains)" in body
    assert '.replace(";", ",").split(",")' not in body


def test_all_domains_spec_ignores_business_domains():
    spec = ah.parse_vibe_scope("All Domains", "crew.x, flight")
    assert (spec.mode, spec.entries, spec.domains, spec.subdomains, spec.errors) == ("all", (), frozenset(), frozenset(), ())
    assert not spec.active
    assert spec.label == "All Domains"


def test_some_domains_spec_matches_by_normalized_name():
    spec = ah.parse_vibe_scope("Some Domains", "Crew, flight_ops; crew")
    assert spec.mode == "domains" and spec.active
    assert spec.entries == ("crew", "flight_ops")
    assert spec.domains == frozenset({"crew", "flightops"})
    assert spec.domain_labels() == ["crew", "flight_ops"]


def test_some_subdomains_spec_builds_domain_subdomain_pairs():
    spec = ah.parse_vibe_scope("Some Subdomains", "crew.crew_records, Flight.Schedule_Planning, crew.compliance_training")
    assert spec.mode == "subdomains" and spec.active
    assert spec.subdomains == frozenset({("crew", "crewrecords"), ("flight", "scheduleplanning"), ("crew", "compliancetraining")})
    assert spec.domains == frozenset({"crew", "flight"})
    assert spec.domain_labels() == ["crew", "flight"]


def test_spec_is_frozen():
    spec = ah.parse_vibe_scope("Some Domains", "crew")
    with pytest.raises(Exception):
        spec.mode = "all"


def test_preflight_unknown_value():
    errs = _validate(vibe_scope="Most Domains", business_domains="crew")
    assert len(errs) == 1 and "Unknown vibe_scope value 'Most Domains'" in errs[0]


@pytest.mark.parametrize("operation", ["install model", "uninstall model version", "shrink ecm", "enlarge mvm"])
def test_preflight_rejects_unsupported_operations(operation):
    errs = _validate(operation=operation, vibe_scope="Some Domains", business_domains="crew")
    assert any("only supported for 'vibe modeling of version' and 'new base model'" in e for e in errs), errs


@pytest.mark.parametrize("operation", [VOV, NEW_BASE])
def test_preflight_accepts_supported_operations(operation):
    assert _validate(operation=operation, vibe_scope="Some Domains", business_domains="crew") == []


@pytest.mark.parametrize("mode", ["Some Domains", "Some Subdomains"])
@pytest.mark.parametrize("domains", ["", "  ", " , ;"])
def test_preflight_scoped_needs_business_domains(mode, domains):
    errs = _validate(operation=NEW_BASE, vibe_scope=mode, business_domains=domains)
    assert any("needs a non-empty '06. Business Domains' list" in e for e in errs), errs


@pytest.mark.parametrize("entry", ["crew", "crew.records.extra", "crew..records"])
def test_preflight_subdomain_entry_needs_exactly_one_dot(entry):
    errs = _validate(operation=NEW_BASE, vibe_scope="Some Subdomains", business_domains=f"flight.ops, {entry}")
    assert any(f"entry '{entry}' must be exactly 'domain.subdomain'" in e for e in errs), errs


@pytest.mark.parametrize("entry", [".records", "crew.", "!!.records"])
def test_preflight_subdomain_entry_parts_must_be_non_empty(entry):
    errs = _validate(operation=NEW_BASE, vibe_scope="Some Subdomains", business_domains=entry)
    assert any("has an empty domain or subdomain part" in e for e in errs), errs


def test_preflight_domain_entry_must_not_contain_a_dot():
    errs = _validate(operation=NEW_BASE, vibe_scope="Some Domains", business_domains="crew, flight.ops")
    assert len(errs) == 1 and "entry 'flight.ops' contains a dot" in errs[0]


def test_preflight_no_longer_rejects_scoped_vov_convention_widgets():
    assert _validate(vibe_scope="Some Domains", business_domains="crew") == []
    with pytest.raises(TypeError):
        _validate(vibe_scope="Some Domains", business_domains="crew", base_model=RAW, model_conventions={"tag_prefix": "zz_"})


def test_base_conventions_come_only_from_a_real_base_model():
    mc = RAW["model"]["model_conventions"]
    assert ah._vibe_scope_model_conventions(RAW) == mc
    assert ah._vibe_scope_model_conventions(RAW["model"]) == mc
    assert ah._vibe_scope_model_conventions({"business_context": {"model_conventions": {"tag_prefix": "x_"}}}) == {"tag_prefix": "x_"}
    widget_built = {"business_information": {"business": "A"}, "model_conventions": {"tag_prefix": "dbx_"}}
    assert ah._vibe_scope_model_conventions(widget_built) is None
    assert ah._vibe_scope_model_conventions(None) is None


def test_preflight_all_domains_and_absent_kwargs_add_no_errors():
    assert _validate() == []
    assert _validate(vibe_scope="All Domains", business_domains="crew.x") == []
    assert _validate(vibe_scope="", business_domains="") == []


def test_preflight_emits_fired_line(capsys):
    _validate(vibe_scope="Some Subdomains", business_domains="crew")
    assert "[vibe-scope-preflight FIRED v5.1.4]" in capsys.readouterr().out


def test_widget_is_declared_and_forwarded_to_the_child_job():
    src = notebook_concat_source()
    assert ('dbutils.widgets.dropdown("vibe_scope", "All Domains", ["All Domains", "Some Domains", "Some Subdomains"], '
            '"06a. Vibe Scope")') in src
    names = re.search(r"_NOTEBOOK_WIDGET_NAMES\s*=\s*\[(.*?)\]", src, re.DOTALL).group(1)
    assert '"vibe_scope"' in names


def test_both_preflight_callers_pass_the_scope_kwargs():
    main_src = slice_function_source("main")
    assert 'w_vibe_scope = _safe_widget("vibe_scope", "All Domains")' in main_src
    assert "vibe_scope=w_vibe_scope," in main_src and "business_domains=w_domains," in main_src
    assert "base_model=_context_file_data," not in main_src and "model_conventions=_widget_model_conventions," not in main_src
    assert 'vibe_scope=_pf_w("vibe_scope"),' in main_src and 'business_domains=_pf_w("business_domains"),' in main_src
    assert '_widget_raw_values["vibe_scope"] = _eff_vibe_scope' in main_src


class _Row:
    def __init__(self, **kw):
        self.__dict__.update(kw)


class _Catalog:
    def __init__(self, exists):
        self.exists = exists

    def tableExists(self, name):
        return self.exists


class _Collect:
    def __init__(self, rows):
        self.rows = rows

    def collect(self):
        return list(self.rows)


class _Spark:
    def __init__(self, exists, handler=None):
        self.catalog = _Catalog(exists)
        self.handler = handler

    def sql(self, query):
        if self.handler is not None and ".`domain`" in query:
            return _Collect(self.handler(query))
        return None


class _StopAfterBranching(Exception):
    pass


def _stop(*_a, **_k):
    raise _StopAfterBranching()


def _vov_sql(latest="1", stored_conventions=None):
    def handler(query):
        if "SELECT version FROM" in query:
            return [_Row(version=latest)]
        if "SELECT model_conventions FROM" in query:
            return [_Row(model_conventions=json.dumps(stored_conventions or RAW["model"]["model_conventions"]))]
        match = re.search(r"version = '([^']+)'", query)
        version = match.group(1) if match else ""
        if "SELECT completed_percent FROM" in query:
            return [_Row(completed_percent=100.0)] if version == "1" else []
        if "COUNT(*) as cnt" in query:
            table = query.split("FROM", 1)[1].split()[0]
            if table.endswith(".business"):
                return [_Row(cnt=1 if version == "1" else 0)]
            return [_Row(cnt=5)]
        return []
    return handler


def _run_setup(monkeypatch, wv, sql=None, table_exists=False):
    captured = {}
    real_overrides = ah.apply_vibe_authority_overrides

    def _capture(config, widgets_values, logger=None):
        captured["config"] = config
        return real_overrides(config, widgets_values, logger=logger)

    monkeypatch.setitem(ah.__dict__, "execute_sql", (lambda spark, q, logger=None: sql(q)) if sql else (lambda *a, **k: []))
    monkeypatch.setitem(ah.__dict__, "_ensure_catalog_exists", _stop)
    monkeypatch.setitem(ah.__dict__, "apply_vibe_authority_overrides", _capture)
    wv["spark"] = _Spark(table_exists, sql)
    with pytest.raises(_StopAfterBranching):
        ah.step_setup_and_clean(wv)
    return captured["config"]


def _widgets(operation, business_domains, vibe_scope=None, vibes="", data_domains=None):
    wv = copy.deepcopy(ah.TECHNICAL_CONTEXT)
    raw_values = {"business_name": "Airlines", "business_domains": business_domains, "operation": operation}
    if vibe_scope is not None:
        raw_values["vibe_scope"] = vibe_scope
    wv.update({
        "business_name": "Airlines", "operation": operation, "model_version": "1" if operation == VOV else "",
        "data_model_scopes": "Minimum Viable Model - MVM", "deployment_catalog": "", "cataloging_style": "one_catalog",
        "catalog_prefix": "", "catalog_suffix": "", "metamodel_catalog": "", "vibe_modelling_instructions": vibes,
        "llm_input_context_tokens_count": 200000, "llm_output_context_tokens_count": 64000,
        "_widget_raw_values": raw_values,
        "business_context_data": {
            "business_information": {"business": "Airlines", "description": "An airline.",
                                     "data_domains": business_domains if data_domains is None else data_domains},
            "model_conventions": copy.deepcopy(RAW["model"]["model_conventions"]),
            "vibe_modelling_instructions": vibes,
        },
    })
    return wv


def _vov_widgets(scope="Some Domains", domains="crew", with_model=True):
    wv = _widgets(VOV, domains, scope, vibes="rename crew.member to crew_member and add product flight.delay_code to flight",
                  data_domains=RAW["model"]["data_domains"])
    wv["business_context_raw"] = copy.deepcopy(RAW) if with_model else copy.deepcopy(wv["business_context_data"])
    return wv


def test_setup_scoped_new_base_subdomains_builds_empty_fence_and_domain_roster(monkeypatch):
    wv = _widgets(NEW_BASE, "crew.crew_records, flight.schedule_planning", "Some Subdomains")
    config = _run_setup(monkeypatch, wv)
    fence = ah.get_vibe_scope_runtime()
    assert isinstance(fence, ah.VibeScopeFence)
    assert fence.report()["baseline"] == {"domains": 0, "products": 0, "metric_views": 0}
    assert wv["_user_specified_domains"] == ["crew", "flight"]
    assert wv["sizing_directives"]["user_domains_exhaustive"] is True
    assert config["PROMPT_VARIABLES"]["business_config"]["business_context"]["data_domains"] == "crew, flight"
    assert ah._USER_PINNED_DOMAINS_RUNTIME == {"crew", "flight"}
    assert any("[vibe-scope-spec FIRED v5.1.4]" in s for s in wv["_vov_pending_sentinels"])


def test_setup_scoped_new_base_domains_keeps_the_legacy_roster(monkeypatch):
    wv = _widgets(NEW_BASE, "Crew, flight", "Some Domains")
    _run_setup(monkeypatch, wv)
    assert wv["_user_specified_domains"] == _legacy_business_domains_parse("Crew, flight")
    assert wv["sizing_directives"]["user_domains_exhaustive"] is True
    assert isinstance(ah.get_vibe_scope_runtime(), ah.VibeScopeFence)


def test_setup_scoped_vov_pins_scope_skips_exhaustive_and_closure_filter(monkeypatch):
    wv = _vov_widgets()
    _run_setup(monkeypatch, wv, sql=_vov_sql(), table_exists=True)
    fence = ah.get_vibe_scope_runtime()
    assert isinstance(fence, ah.VibeScopeFence)
    assert fence.report()["frozen"]["domains"] == 14 and fence.report()["frozen"]["products"] == 192
    assert wv["_user_specified_domains"] == ["crew"]
    assert "user_domains_exhaustive" not in (wv.get("sizing_directives") or {})
    assert ("flight", "delay_code") in wv["_vov_user_closure"]
    assert wv["_vibe_scope_spec"].entries == ("crew",)
    assert any("[vibe-scope-exhaustive-skip FIRED v5.1.4]" in s for s in wv["_vov_pending_sentinels"])


def test_setup_scoped_vov_stale_base_is_refused_and_names_both_versions(monkeypatch):
    wv = _vov_widgets()
    with pytest.raises(ValueError, match=r"vibe_scope run refused at setup: base v1 is behind v3"):
        _run_setup(monkeypatch, wv, sql=_vov_sql(latest="3"), table_exists=True)
    assert ah.get_vibe_scope_runtime() is None and "_vibe_scope_stale_base" not in wv


def test_setup_scoped_vov_current_base_is_not_stale(monkeypatch):
    wv = _vov_widgets()
    _run_setup(monkeypatch, wv, sql=_vov_sql(latest="1"), table_exists=True)
    assert wv["_vibe_scope_stale_base"]["stale"] is False


def test_setup_scoped_vov_base_conventions_win_over_a_widget_mismatch(monkeypatch):
    wv = _vov_widgets()
    wv["business_context_data"]["model_conventions"]["tag_prefix"] = "zz_"
    config = _run_setup(monkeypatch, wv, sql=_vov_sql(), table_exists=True)
    assert config["MODEL_CONVENTIONS"]["tag_prefix"] == "dbx_" and config["TAG_PREFIX"] == "dbx_"
    assert "tag_prefix='zz_' (base 'dbx_')" in wv["_vov_conventions_override_warn"]
    assert wv["has_convention_changes"] is False
    assert isinstance(ah.get_vibe_scope_runtime(), ah.VibeScopeFence)


def test_setup_scoped_vov_uses_metamodel_conventions_when_no_base_json(monkeypatch):
    wv = _vov_widgets(with_model=False)
    stored = dict(RAW["model"]["model_conventions"], primary_key_suffix="_key")
    config = _run_setup(monkeypatch, wv, sql=_vov_sql(stored_conventions=stored), table_exists=True)
    assert config["MODEL_CONVENTIONS"]["primary_key_suffix"] == "_key"
    assert "primary_key_suffix='_id' (base '_key')" in wv["_vov_conventions_override_warn"]
    assert wv["has_convention_changes"] is False


def test_setup_defers_the_fence_to_vov_engine_start_when_base_json_missing(monkeypatch):
    wv = _vov_widgets(with_model=False)
    _run_setup(monkeypatch, wv, sql=_vov_sql(latest="1"), table_exists=True)
    assert ah.get_vibe_scope_runtime() is None
    assert wv["_vibe_scope_spec"].active
    flat = ah.model_to_widgets_flat(RAW)
    initial_model = ah.widgets_flat_to_model(*flat, agent_version=ah.__AGENT_VERSION__)
    fence = ah._vibe_scope_bind_engine_baseline(wv, initial_model, None)
    assert fence is ah.get_vibe_scope_runtime()
    assert fence.report()["bind"]["differing"] == 0
    assert fence.report()["stale_base"]["stale"] is False


@pytest.mark.parametrize("operation", [NEW_BASE, VOV])
def test_setup_all_domains_is_a_strict_noop(monkeypatch, operation):
    if operation == NEW_BASE:
        wv = _widgets(NEW_BASE, "Crew, flight; crew")
        _run_setup(monkeypatch, wv)
        assert wv["_user_specified_domains"] == _legacy_business_domains_parse("Crew, flight; crew")
        assert wv["sizing_directives"]["user_domains_exhaustive"] is True
    else:
        wv = _vov_widgets(scope=None)
        _run_setup(monkeypatch, wv, sql=_vov_sql(latest="3"), table_exists=True)
        assert wv["_user_specified_domains"] == _legacy_business_domains_parse(RAW["model"]["data_domains"])
        assert "user_domains_exhaustive" not in (wv.get("sizing_directives") or {})
    assert ah.get_vibe_scope_runtime() is None
    assert "_vibe_scope_spec" not in wv and "_vibe_scope_stale_base" not in wv
    assert not any("vibe-scope" in str(s) for s in wv.get("_vov_pending_sentinels", []))


def test_setup_all_domains_clears_a_stale_runtime_from_a_previous_run(monkeypatch):
    ah.set_vibe_scope_runtime(ah.build_vibe_scope_fence(ah.parse_vibe_scope("Some Domains", "crew"), None, NEW_BASE))
    wv = _widgets(NEW_BASE, "crew")
    _run_setup(monkeypatch, wv)
    assert ah.get_vibe_scope_runtime() is None


@pytest.mark.parametrize("scope,domains,operation", [
    ("Most Domains", "crew", NEW_BASE),
    ("Some Domains", "", NEW_BASE),
    ("Some Subdomains", "crew", NEW_BASE),
    ("Some Domains", "crew", "shrink ecm"),
])
def test_setup_fails_closed_on_an_invalid_scope_that_bypassed_preflight(monkeypatch, scope, domains, operation):
    wv = _widgets(operation, domains, scope)
    wv["spark"] = _Spark(False)
    monkeypatch.setitem(ah.__dict__, "_ensure_catalog_exists", _stop)
    with pytest.raises(ValueError, match="vibe_scope configuration invalid"):
        ah.step_setup_and_clean(wv)

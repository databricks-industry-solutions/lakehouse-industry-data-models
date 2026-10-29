import io
import os
import sys
from types import SimpleNamespace as NS
from unittest.mock import MagicMock

import pytest
from databricks.sdk.errors.platform import DatabricksError, NotFound, PermissionDenied
from sqlmodel import Session, select

sys.path.insert(0, os.path.dirname(__file__))

from _assess_helpers import seed_domain_run  # noqa: E402
from test_assess_ingest import OUT, _fixture_files, _seed_run, _ws_with  # noqa: E402
from vibe_modeling.backend.assessment.assets import resolve_vendored_assessment  # noqa: E402
from vibe_modeling.backend.assessment.handoff import (  # noqa: E402
    EXPECTED_HANDOFFS, SIGN_IN_TO_CHECK_SKILLS, build_next_steps, build_prompts, default_handoff_path,
    render_decisions_md, skills_check, skills_check_with_note,
)
from vibe_modeling.backend.assessment.ingest import ingest_domain_run  # noqa: E402
from vibe_modeling.backend.db_models import (  # noqa: E402
    AssessDecisionOption, AssessDomainRun, AssessHandoff, AssessPendingDecision,
)

WHO = {"X-Forwarded-Email": "dana@example.com"}


@pytest.fixture(autouse=True)
def _no_skill_markers(mock_ws):
    mock_ws.workspace.download.side_effect = NotFound("no marker")


@pytest.fixture(name="user_ws")
def user_ws_fixture(client):
    """The caller's on-behalf-of client; hand-off writes go through it."""
    from vibe_modeling.backend.core._defaults import _get_user_ws_optional
    uw = MagicMock()
    uw.workspace.get_status.side_effect = NotFound("none")
    uw.workspace.download.side_effect = NotFound("no marker")
    client.app.dependency_overrides[_get_user_ws_optional] = lambda: uw
    yield uw
    client.app.dependency_overrides.pop(_get_user_ws_optional, None)


@pytest.fixture(name="ingested_completed")
def ingested_completed_fixture(engine):
    dr_id, _, _ = _seed_run(engine)
    with Session(engine) as s:
        dr = s.get(AssessDomainRun, dr_id)
        ingest_domain_run(s, _ws_with(_fixture_files()), dr)
        dr = s.get(AssessDomainRun, dr_id)
        dr.status = "completed"
        s.add(dr); s.commit()
        out_dir = dr.out_dir
    return NS(dr_id=dr_id, out_dir=out_dir)


def _wire_volume(mock_ws, out, files=None):
    tree = {
        out: [NS(path=f"{out}/conventions.yml", is_directory=False),
              NS(path=f"{out}/docs", is_directory=True),
              NS(path=f"{out}/events.jsonl", is_directory=False),
              NS(path=f"{out}/stderr.log", is_directory=False)],
        f"{out}/docs": [NS(path=f"{out}/docs/design", is_directory=True)],
        f"{out}/docs/design": [NS(path=f"{out}/docs/design/s2t.md", is_directory=False)],
    }
    mock_ws.files.list_directory_contents.side_effect = lambda p: iter(tree.get(p, []))
    mock_ws.files.download.side_effect = lambda p: NS(contents=io.BytesIO((files or {}).get(p, b"x")))
    mock_ws.workspace.get_status.return_value.object_id = 11


def _uploads(client_ws):
    return {c.args[0]: c.args[1].read() for c in client_ws.workspace.upload.call_args_list}


HOME = "/Workspace/Users/dana@example.com"


def test_default_path_is_safe():
    assert default_handoff_path("dana@example.com", "Meridian Mfg", "../sales", "b1") == \
        f"{HOME}/vibe-assess/Meridian_Mfg/___sales/b1"


def test_default_path_names_with_spaces_dots_slashes():
    p = default_handoff_path("dana@example.com", "Acme Corp. / EU", "a b.c/d", "b1")
    assert p == f"{HOME}/vibe-assess/Acme_Corp____EU/a_b_c_d/b1"
    assert ".." not in p and " " not in p and p.count("/") == 7


def _dec(gate, q, status, default="defer", answer_option_id=None, answer_text="", entity="credit_check"):
    return NS(gate=gate, question=q, answer_status=status, default_taken=default,
              answer_option_id=answer_option_id, answer_text=answer_text, entity=entity, id=gate)


def test_render_decisions_md_lists_answers_and_defaults():
    opts = [NS(id="o1", label="add"), NS(id="o2", label="defer")]
    md = render_decisions_md([
        (_dec("2C", "Add net-new entity credit_check?", "answered", answer_option_id="o1"), opts),
        (_dec("3A", "Merge duplicates?", "open"), opts),
    ])
    assert "## 2C — Add net-new entity credit_check?" in md
    assert "**Answer:** add" in md
    assert "## 3A — Merge duplicates?" in md
    assert "**Answer:** _not answered — default taken: defer_" in md


def test_render_decisions_md_option_plus_text():
    opts = [NS(id="o1", label="add")]
    md = render_decisions_md([(_dec("2C", "q", "answered", answer_option_id="o1", answer_text="but later"), opts)])
    assert "**Answer:** add — but later" in md


def test_prompts_reference_project_root_and_skills():
    ps = {p.key: p for p in build_prompts("/Workspace/Users/dana@example.com/vibe-assess/M/s/b1")}
    assert set(ps) == {"continue", "build", "validate", "document"}
    assert "/Workspace/Users/dana@example.com/vibe-assess/M/s/b1" in ps["continue"].prompt
    assert "docs/inputs/decisions.md" in ps["continue"].prompt and "Phase 5" in ps["continue"].prompt
    assert ps["validate"].skill == "domain-model-validation" and "autonomous-validation" in ps["validate"].prompt
    assert ps["build"].skill == "etl-development-framework" and ps["document"].skill == "domain-documentation"
    assert all("/Workspace/Users/dana@example.com/vibe-assess/M/s/b1" in p.prompt for p in ps.values())
    assert [p.key for p in build_prompts("/x")] == ["continue", "build", "validate", "document"]


def test_hybrid_prompts_build_and_validate_each_layer():
    ps = build_prompts("/x", "hybrid")
    assert [p.key for p in ps] == ["continue", "build", "validate", "gold", "build_gold", "validate_gold", "document"]
    assert [p.title.split(".")[0] for p in ps] == ["1", "2", "3", "4", "5", "6", "7"]
    by = {p.key: p for p in ps}
    assert by["build"].title == "2. Build silver" and by["validate"].title == "3. Validate silver"
    assert "silver layer" in by["validate"].prompt
    gold = by["gold"]
    assert gold.skill == "domain-model-assessment" and gold.title == "4. Derive gold"
    assert "Mode B" in gold.prompt and "autonomous-validation" in gold.prompt and "etl-development-framework" in gold.prompt
    assert "docs/design/" in gold.prompt
    bg = by["build_gold"]
    assert bg.skill == "etl-development-framework" and bg.title == "5. Build gold"
    assert "autonomous-validation" in bg.prompt and "gold layer" in bg.prompt
    assert "docs/design/" in bg.prompt and "gold_requirements.md" in bg.prompt and "gold_layer_assessment.md" in bg.prompt
    vg = by["validate_gold"]
    assert vg.skill == "domain-model-validation" and vg.title == "6. Validate gold" and "gold layer" in vg.prompt
    assert all("/x" in p.prompt for p in ps)


def test_non_hybrid_prompts_have_no_gold_step():
    for om in ("normalized", "dimensional"):
        ps = build_prompts("/x", om)
        assert [p.key for p in ps] == ["continue", "build", "validate", "document"]
        assert [p.title.split(".")[0] for p in ps] == ["1", "2", "3", "4"]


@pytest.mark.parametrize("om", ["normalized", "dimensional", "hybrid"])
def test_next_steps_run_step_follows_the_prompts(om):
    """The last checklist step names every prompt title in order (gold steps only for hybrid)."""
    step = build_next_steps(verdict=None, open_blocking=0, open_total=0, before_build_vibes=0, copied=False,
                            output_model=om)[-1]
    titles = [p.title.split(". ", 1)[1] for p in build_prompts("/x", om)]
    assert step.title == "In Genie Code, run " + " → ".join(titles)
    assert step.detail == f"Paste the {'seven' if om == 'hybrid' else 'four'} prompts in order."


def test_build_prompts_name_the_files_the_vendored_skills_use():
    """Build inputs are in docs/design/, where the assessment writes them and the ETL skill reads them;
    docs/.pipeline/handoffs/ holds what the build and validation skills write, so no prompt points there."""
    skills = resolve_vendored_assessment() / "skills"
    etl = (skills / "etl-development-framework" / "SKILL.md").read_text()
    assess = (skills / "domain-model-assessment" / "SKILL.md").read_text()
    gold_protocol = (skills / "domain-model-assessment" / "gold-derivation-protocol.md").read_text()
    for name in ("business_requirements.md", "etl_detailed_spec.md"):
        assert f"docs/design/{name}" in etl and f"docs/design/{name}" in assess
    assert "docs/design/gold_requirements.md" in etl and "gold_layer_assessment.md" in gold_protocol
    by = {p.key: p for p in build_prompts("/x", "hybrid")}
    assert "business_requirements.md" in by["build"].prompt and "etl_detailed_spec.md" in by["build"].prompt
    assert all(".pipeline/handoffs" not in p.prompt for p in by.values())
    assert all(".pipeline/handoffs" not in h for h in EXPECTED_HANDOFFS)
    assert any("business_requirements.md" in h and "etl_detailed_spec.md" in h for h in EXPECTED_HANDOFFS)


USER = "dana@example.com"
UDIR = f"/Workspace/Users/{USER}/.assistant/skills"
WDIR = "/Workspace/.assistant/skills"


def _skills_ws(tree: dict):
    """Fake ws keyed by path: a dir -> marker text; a dir mapped to an Exception raises it."""
    ws = MagicMock()

    def get_status(path):
        d = path.rstrip("/")
        v = tree.get(d)
        if isinstance(v, Exception):
            raise v
        if d not in tree:
            raise NotFound("no")
        return NS(path=d)

    def download(path, **kw):
        d = path.rsplit("/", 1)[0]
        v = tree.get(d)
        if not isinstance(v, str):
            raise NotFound("no marker")
        return io.BytesIO(v.encode())

    ws.workspace.get_status.side_effect = get_status
    ws.workspace.download.side_effect = download
    return ws


def _st(statuses):
    return {s.name: (s.state, s.location, s.installed_version) for s in statuses}


def test_skills_check_user_level_current():
    ws = _skills_ws({f"{UDIR}/a": "1.0 r1"})
    got = skills_check(ws, ws, ["a"], user_email=USER, bundled={"a": "1.0 r1"})
    assert _st(got) == {"a": ("present", "user", "1.0 r1")}
    assert got[0].bundled_version == "1.0 r1"


def test_skills_check_workspace_only():
    ws = _skills_ws({f"{WDIR}/a": "1.0 r1"})
    assert _st(skills_check(ws, ws, ["a"], user_email=USER, bundled={"a": "1.0 r1"})) == {
        "a": ("present", "workspace", "1.0 r1")}


def test_skills_check_old_marker_and_missing_marker_update_available():
    ws = _skills_ws({f"{UDIR}/a": "0.3.0 old", f"{UDIR}/b": None})
    ws.workspace.download.side_effect = lambda p, **kw: (
        io.BytesIO(b"0.3.0 old") if "/a/" in p else (_ for _ in ()).throw(NotFound("x")))
    ws.workspace.get_status.side_effect = lambda p: NS(path=p) if p.startswith(UDIR) else (_ for _ in ()).throw(NotFound("x"))
    got = _st(skills_check(ws, ws, ["a", "b"], user_email=USER, bundled={"a": "1.0 r1", "b": "1.0 r1"}))
    assert got == {"a": ("update_available", "user", "0.3.0 old"), "b": ("update_available", "user", "")}


def test_skills_check_user_beats_workspace_and_missing():
    ws = _skills_ws({f"{UDIR}/a": "1.0 r1", f"{WDIR}/a": "0.1", f"{WDIR}/b": "0.1"})
    got = _st(skills_check(ws, ws, ["a", "b", "c"], user_email=USER,
                           bundled={"a": "1.0 r1", "b": "1.0 r1", "c": "1.0 r1"}))
    assert got["a"][:2] == ("present", "user")
    assert got["b"][:2] == ("update_available", "workspace")
    assert got["c"] == ("missing", "none", "")


def test_skills_check_uses_user_client_for_user_path():
    ws = _skills_ws({})
    uws = _skills_ws({f"{UDIR}/a": "1.0 r1"})
    got = skills_check(ws, uws, ["a"], user_email=USER, bundled={"a": "1.0 r1"})
    assert _st(got)["a"][:2] == ("present", "user")


def test_skills_check_permission_denied_is_unknown():
    ws = _skills_ws({f"{UDIR}/a": PermissionDenied("no"), f"{WDIR}/a": PermissionDenied("no")})
    got = skills_check(ws, ws, ["a"], user_email=USER, bundled={"a": "v"})
    assert _st(got) == {"a": ("unknown", "none", "")}


def test_skills_check_finds_a_workspace_skill_when_your_folder_is_unreadable():
    ws = _skills_ws({f"{UDIR}/a": PermissionDenied("no"), f"{WDIR}/a": "v"})
    assert _st(skills_check(ws, ws, ["a"], user_email=USER, bundled={"a": "v"}))["a"][:2] == ("present", "workspace")


def test_next_steps_all_clear_and_copied():
    steps = build_next_steps(verdict="ready_to_build", open_blocking=0, open_total=0, before_build_vibes=0,
                             copied=True, skills_ok=True)
    assert [s.order for s in steps] == [1, 2]
    assert steps[0].title.startswith("Copy the assessment") and "done" in steps[0].detail.lower()
    assert steps[0].done is True and steps[1].done is False


def test_next_steps_copy_not_done_when_not_copied():
    steps = build_next_steps(verdict=None, open_blocking=0, open_total=0, before_build_vibes=0, copied=False)
    assert steps[0].title.startswith("Copy the assessment") and steps[0].done is False
    assert "Continue" in steps[1].title and "Validate" in steps[1].title


def test_next_steps_blocked_verdict():
    steps = build_next_steps(verdict="blocked", open_blocking=2, open_total=3, before_build_vibes=0,
                             copied=False, skills_ok=True, blocked_entities=4)
    assert steps[0].title == "Resolve the blocked entities before building"
    assert steps[0].detail.startswith("4 entities are blocked")
    assert "2" not in steps[0].detail  # the decision count is not presented as entities
    assert steps[1].title == "Answer 2 blocking decisions"


def test_skills_check_generic_sdk_error_degrades():
    ws = _skills_ws({f"{UDIR}/a": DatabricksError("boom"), f"{WDIR}/a": "v"})
    assert _st(skills_check(ws, ws, ["a"], user_email=USER, bundled={"a": "v"}))["a"][:2] == ("present", "workspace")
    ws = _skills_ws({f"{UDIR}/a": DatabricksError("boom"), f"{WDIR}/a": DatabricksError("boom")})
    assert _st(skills_check(ws, ws, ["a"], user_email=USER, bundled={"a": "v"}))["a"][:2] == ("unknown", "none")


def test_next_steps_blocking_decisions_and_vibes_in_order():
    steps = build_next_steps(verdict="iterate_first", open_blocking=2, open_total=5, before_build_vibes=3,
                             copied=False, skills_ok=True)
    assert [s.title.split()[0] for s in steps] == ["Answer", "Iterate", "Copy", "In"]
    assert "2 blocking decisions" in steps[0].title and "3 changes" in steps[1].title
    assert [s.order for s in steps] == [1, 2, 3, 4]


def test_next_steps_review_open_and_skills_step():
    steps = build_next_steps(verdict=None, open_blocking=0, open_total=1, before_build_vibes=1,
                             copied=False, skills_ok=False)
    assert steps[0].title == "Review 1 open decision"
    assert steps[1].title == "Iterate the model on 1 change before building"
    assert steps[2].title == "Install the Genie Code skills"


def test_handoff_writes_into_the_callers_home_through_obo(client, mock_ws, user_ws, ingested_completed):
    _wire_volume(mock_ws, ingested_completed.out_dir)
    r = client.post(f"/api/assessment-domain-runs/{ingested_completed.dr_id}/handoff", json={}, headers=WHO)
    assert r.status_code == 200, r.text
    up = _uploads(user_ws)
    root = r.json()["path"]
    batch_id = root.rsplit("/", 1)[-1]
    assert root == f"{HOME}/vibe-assess/Meridian_Mfg/sales_order/{batch_id}"
    assert f"{root}/conventions.yml" in up and f"{root}/docs/design/s2t.md" in up
    assert f"{root}/docs/inputs/decisions.md" in up and f"{root}/README.md" in up
    assert not any(u.endswith(("events.jsonl", "stderr.log")) for u in up)
    assert len(up) == 4
    mock_ws.workspace.upload.assert_not_called(); mock_ws.workspace.mkdirs.assert_not_called()
    mock_ws.permissions.update.assert_not_called(); user_ws.permissions.update.assert_not_called()
    user_ws.files.download.assert_not_called()  # volume reads stay on the app SP client
    body = r.json()
    assert [p["key"] for p in body["prompts"]] == ["continue", "build", "validate", "gold", "build_gold", "validate_gold", "document"]
    assert body["created_by"] == "dana@example.com" and body["created_at"]
    assert body["folder_url"] == f"https://test-workspace.databricks.com/#workspace{root}"


def test_handoff_mkdirs_deduped_per_folder(client, mock_ws, user_ws, ingested_completed):
    _wire_volume(mock_ws, ingested_completed.out_dir)
    client.post(f"/api/assessment-domain-runs/{ingested_completed.dr_id}/handoff", json={}, headers=WHO)
    dirs = [c.args[0] for c in user_ws.workspace.mkdirs.call_args_list]
    assert len(dirs) == len(set(dirs))


def test_handoff_content_has_decisions_and_readme(client, mock_ws, user_ws, engine, ingested_completed):
    _wire_volume(mock_ws, ingested_completed.out_dir)
    with Session(engine) as s:
        dec = s.exec(select(AssessPendingDecision)).first()
        opt = s.exec(select(AssessDecisionOption).where(AssessDecisionOption.decision_id == dec.id)
                     .order_by(AssessDecisionOption.ordinal)).first()
        dec.answer_status, dec.answer_option_id = "answered", opt.id
        s.add(dec); s.commit()
        question, label = dec.question, opt.label
    r = client.post(f"/api/assessment-domain-runs/{ingested_completed.dr_id}/handoff", json={}, headers=WHO)
    root = r.json()["path"]
    up = _uploads(user_ws)
    md = up[f"{root}/docs/inputs/decisions.md"].decode()
    assert question in md and f"**Answer:** {label}" in md
    readme = up[f"{root}/README.md"].decode()
    for needle in ("Meridian Mfg", "sales_order", "v3", "0.4.0", "v0.1.0-beta.2", "4c709f7"):
        assert needle in readme, needle
    pos = [readme.index(t) for t in ("Continue the assessment", "Build", "Validate", "Document")]
    assert pos == sorted(pos)


def test_handoff_without_user_email_is_401_identity_missing_and_writes_nothing(client, mock_ws, user_ws, engine,
                                                                               ingested_completed):
    from vibe_modeling.backend.core._identity import NO_EMAIL_MESSAGE
    _wire_volume(mock_ws, ingested_completed.out_dir)
    r = client.post(f"/api/assessment-domain-runs/{ingested_completed.dr_id}/handoff", json={})
    assert r.status_code == 401, r.text
    assert r.json()["detail"] == {"error": "identity_missing", "message": NO_EMAIL_MESSAGE}
    user_ws.workspace.upload.assert_not_called()
    with Session(engine) as s:
        assert s.exec(select(AssessHandoff)).all() == []


def test_handoff_custom_path_and_get_reports_last(client, mock_ws, user_ws, ingested_completed):
    _wire_volume(mock_ws, ingested_completed.out_dir)
    dr = ingested_completed.dr_id
    g0 = client.get(f"/api/assessment-domain-runs/{dr}/handoff", headers=WHO).json()
    assert g0["created_at"] is None and g0["path"].startswith(f"{HOME}/vibe-assess/")
    assert [s["name"] for s in g0["skills"]][:2] == ["domain-model-assessment", "autonomous-validation"]
    assert g0["user_scope_note"] and g0["expected_handoffs"] and len(g0["prompts"]) == 7
    mine = "/Workspace/Users/Dana@Example.com/proj"
    r = client.post(f"/api/assessment-domain-runs/{dr}/handoff", json={"path": mine}, headers=WHO)
    assert r.status_code == 200 and r.json()["path"] == mine
    g1 = client.get(f"/api/assessment-domain-runs/{dr}/handoff").json()
    assert g1["path"] == mine and g1["created_by"] == "dana@example.com"
    assert g1["created_at"] and mine in g1["prompts"][0]["prompt"]


def test_handoff_failure_is_409_with_runs_path_and_records_nothing(client, mock_ws, user_ws, engine, ingested_completed):
    _wire_volume(mock_ws, ingested_completed.out_dir)
    user_ws.workspace.upload.side_effect = DatabricksError("boom")
    r = client.post(f"/api/assessment-domain-runs/{ingested_completed.dr_id}/handoff", json={}, headers=WHO)
    assert r.status_code == 409
    d = r.json()["detail"]
    # ``runs_path`` is structural and passes through. The message leaves the
    # target folder out: the user chose it and sees it in the form.
    assert d["error"] == "admin_help" and d["runs_path"] == ingested_completed.out_dir
    assert d["message"] == "Hand-off failed writing to the chosen folder: boom"
    with Session(engine) as s:
        assert s.exec(select(AssessHandoff)).all() == []


def test_handoff_file_cap_is_409_admin_help(client, mock_ws, user_ws, ingested_completed, monkeypatch):
    from vibe_modeling.backend.assessment import handoff
    monkeypatch.setattr(handoff, "MAX_FILES", 1)
    _wire_volume(mock_ws, ingested_completed.out_dir)
    r = client.post(f"/api/assessment-domain-runs/{ingested_completed.dr_id}/handoff", json={}, headers=WHO)
    assert r.status_code == 409 and r.json()["detail"]["error"] == "admin_help"


def test_handoff_rejects_bad_path(client, ingested_completed):
    for bad in ["/Users/x", "/Workspace/Shared/../Users/x", "/Workspace//x", "/Workspace/a;b", "/Workspace/x/", "/Workspace",
                f"{HOME}/vibe-assess/x\n", f"{HOME}/vibe-assess/ x", f"{HOME}/vibe-assess/x /y",
                f"{HOME}/vibe-assess/ /y", f"{HOME}/vibe-assess/.hidden"]:
        assert client.post(f"/api/assessment-domain-runs/{ingested_completed.dr_id}/handoff",
                           json={"path": bad}).status_code == 422, bad


def test_handoff_requires_completed(client, engine):
    dr = seed_domain_run(engine, status="assessing")
    assert client.post(f"/api/assessment-domain-runs/{dr}/handoff", json={}).status_code == 409


def test_handoff_refused_for_results_invalid(client, mock_ws, user_ws, engine):
    dr = seed_domain_run(engine, status="results_invalid")
    _wire_volume(mock_ws, "/Volumes/c/_metamodel/assess_runs/b/d")
    assert client.post(f"/api/assessment-domain-runs/{dr}/handoff", json={}, headers=WHO).status_code == 409
    user_ws.workspace.upload.assert_not_called()


def test_handoff_without_obo_client_is_409_with_runs_path(client, mock_ws, engine, ingested_completed):
    _wire_volume(mock_ws, ingested_completed.out_dir)
    r = client.post(f"/api/assessment-domain-runs/{ingested_completed.dr_id}/handoff", json={}, headers=WHO)
    assert r.status_code == 409
    assert r.json()["detail"] == {"error": "admin_help",
                                  "message": "Sign in through the deployed app to hand off the assessment.",
                                  "runs_path": ingested_completed.out_dir}
    mock_ws.workspace.upload.assert_not_called()
    with Session(engine) as s:
        assert s.exec(select(AssessHandoff)).all() == []


def _pin_links(engine, dr_id):
    with Session(engine) as s:
        dr = s.get(AssessDomainRun, dr_id)
        dr.job_id, dr.databricks_run_id, dr.job_reader = 99, 1234, "reader-1"
        s.add(dr); s.commit()


def test_handoff_generic_write_failure_is_409_with_run_links(client, mock_ws, user_ws, engine, ingested_completed):
    _pin_links(engine, ingested_completed.dr_id)
    _wire_volume(mock_ws, ingested_completed.out_dir)
    user_ws.workspace.mkdirs.side_effect = NotFound("parent folder does not exist")
    r = client.post(f"/api/assessment-domain-runs/{ingested_completed.dr_id}/handoff", json={}, headers=WHO)
    assert r.status_code == 409
    d = r.json()["detail"]
    assert "parent folder does not exist" in d["message"] and "re-consent" not in d["message"]
    assert d["job_url"].endswith("/jobs/99") and d["run_url"].endswith("/jobs/99/runs/1234")
    assert d["job_reader"] == "reader-1" and d["runs_path"] == ingested_completed.out_dir


def test_handoff_volume_read_denied_is_not_a_scope_error(client, mock_ws, user_ws, ingested_completed):
    _wire_volume(mock_ws, ingested_completed.out_dir)
    mock_ws.files.download.side_effect = PermissionDenied("app SP cannot read the volume")
    r = client.post(f"/api/assessment-domain-runs/{ingested_completed.dr_id}/handoff", json={}, headers=WHO)
    assert r.status_code == 409
    d = r.json()["detail"]
    assert d["message"] == "Hand-off failed reading the run's files: app SP cannot read the volume"
    user_ws.workspace.upload.assert_not_called()


def test_handoff_scope_error_is_409_with_scope_message_and_run_links(client, mock_ws, user_ws, engine, ingested_completed):
    with Session(engine) as s:
        dr = s.get(AssessDomainRun, ingested_completed.dr_id)
        dr.job_id, dr.databricks_run_id, dr.job_reader = 99, 1234, "reader-1"
        s.add(dr); s.commit()
    _wire_volume(mock_ws, ingested_completed.out_dir)
    user_ws.workspace.mkdirs.side_effect = PermissionDenied("Provided OAuth token does not have required scopes")
    r = client.post(f"/api/assessment-domain-runs/{ingested_completed.dr_id}/handoff", json={}, headers=WHO)
    assert r.status_code == 409
    d = r.json()["detail"]
    assert "write to your workspace folder" in d["message"] and d["runs_path"] == ingested_completed.out_dir
    assert d["message"].endswith("Error: Provided OAuth token does not have required scopes")
    assert d["job_url"].endswith("/jobs/99") and d["run_url"].endswith("/jobs/99/runs/1234")
    assert d["job_reader"] == "reader-1"


def test_handoff_404(client):
    assert client.post("/api/assessment-domain-runs/nope/handoff", json={}).status_code == 404
    assert client.get("/api/assessment-domain-runs/nope/handoff").status_code == 404


@pytest.mark.parametrize("bad", [
    "/Workspace/Shared/vibe-assess/mine",
    "/Workspace/Shared/vibe-modeling/assessment/1",
    "/Workspace/.assistant/skills/domain-sync",
    "/Workspace/Shared",
    "/Workspace/Shared/vibe-assess",
    "/Workspace/Shared/vibe-assess/",
    "/Workspace/Shared/vibe-assessor/x",
    "/Workspace/Users/other@example.com/x",
    "/Workspace/Users/dana@example.com",
    "/Workspace/Users/dana@example.com/.hidden/x",
])
def test_handoff_target_outside_the_callers_home_is_422(client, mock_ws, user_ws, ingested_completed, bad):
    _wire_volume(mock_ws, ingested_completed.out_dir)
    r = client.post(f"/api/assessment-domain-runs/{ingested_completed.dr_id}/handoff", json={"path": bad}, headers=WHO)
    assert r.status_code == 422, bad
    user_ws.workspace.upload.assert_not_called()


def test_handoff_outside_home_message_keeps_the_home_folder_hint(client, mock_ws, user_ws, ingested_completed):
    _wire_volume(mock_ws, ingested_completed.out_dir)
    r = client.post(f"/api/assessment-domain-runs/{ingested_completed.dr_id}/handoff",
                    json={"path": "/Workspace/Users/other@example.com/x"}, headers=WHO)
    assert r.status_code == 422
    assert r.json() == {"detail": "Hand-off folder must be a subfolder of your own home folder "
                                  "(/Workspace/Users/<your email>/)."}


def test_handoff_home_subpath_ok_and_needs_email(client, mock_ws, user_ws, ingested_completed):
    _wire_volume(mock_ws, ingested_completed.out_dir)
    url = f"/api/assessment-domain-runs/{ingested_completed.dr_id}/handoff"
    assert client.post(url, json={"path": f"{HOME}/x"}, headers=WHO).status_code == 200
    assert client.post(url, json={"path": f"{HOME}/x"}).status_code == 401


def test_readme_notes_overwrite(client, mock_ws, user_ws, ingested_completed):
    _wire_volume(mock_ws, ingested_completed.out_dir)
    r = client.post(f"/api/assessment-domain-runs/{ingested_completed.dr_id}/handoff", json={}, headers=WHO)
    assert "Re-running the hand-off overwrites these files." in _uploads(user_ws)[f"{r.json()['path']}/README.md"].decode()


def test_walk_stops_at_cap(client, mock_ws, user_ws, ingested_completed, monkeypatch):
    from vibe_modeling.backend.assessment import handoff
    monkeypatch.setattr(handoff, "MAX_FILES", 3)
    out = ingested_completed.out_dir
    seen = []

    def lst(p):
        if p == out:
            return iter([])
        seen.append(p)
        return iter([NS(path=f"{p}/f{i}", is_directory=False) for i in range(50)] + [NS(path=f"{p}/sub", is_directory=True)])
    mock_ws.files.list_directory_contents.side_effect = lst
    r = client.post(f"/api/assessment-domain-runs/{ingested_completed.dr_id}/handoff", json={}, headers=WHO)
    assert r.status_code == 409 and "docs folder exceeds" in r.json()["detail"]["message"]
    assert len(seen) == 1  # never recursed into sub/


def test_get_handoff_reports_next_steps_and_skill_locations(client, mock_ws, ingested_completed):
    r = client.get(f"/api/assessment-domain-runs/{ingested_completed.dr_id}/handoff", headers=WHO)
    body = r.json()
    assert [s["order"] for s in body["next_steps"]] == list(range(1, len(body["next_steps"]) + 1))
    assert body["next_steps"][-1]["title"].startswith("In Genie Code")
    # No caller token: the caller's folder is not read (not even as the app), only the workspace-wide one.
    assert {s["location"] for s in body["skills"]} == {"workspace"}
    assert body["skills_note"] == SIGN_IN_TO_CHECK_SKILLS
    assert not any(c.args[0].startswith("/Workspace/Users/") for c in mock_ws.workspace.get_status.call_args_list)
    assert {s["state"] for s in body["skills"]} == {"update_available"}  # marker unreadable -> not current
    assert any(s["title"] == "Install the Genie Code skills" for s in body["next_steps"])
    assert all(s["bundled_version"].startswith("0.5.0") for s in body["skills"])


def test_get_handoff_without_email_reports_skills_unknown(client, mock_ws, ingested_completed):
    from databricks.sdk.errors.platform import NotFound
    mock_ws.workspace.get_status.side_effect = NotFound("missing")
    body = client.get(f"/api/assessment-domain-runs/{ingested_completed.dr_id}/handoff").json()
    assert {s["state"] for s in body["skills"]} == {"unknown"}
    assert body["skills_note"] == SIGN_IN_TO_CHECK_SKILLS
    assert body["path"] is None and body["folder_url"] == ""  # no email, no home to propose
    assert "<your hand-off folder>" in body["prompts"][0]["prompt"]


def test_next_steps_blocked_entities_without_verdict():
    steps = build_next_steps(verdict=None, open_blocking=0, open_total=0, before_build_vibes=0, copied=False,
                             blocked_entities=2)
    assert steps[0].title == "Resolve the blocked entities before building"
    assert steps[0].detail.startswith("2 entities are blocked")


def test_skills_check_never_reads_your_folder_as_the_app(caplog):
    """A scope error on the caller's token is reported plainly; the app does not re-read the folder itself."""
    sp = _skills_ws({f"{UDIR}/a": "0.1"})
    obo = _skills_ws({f"{UDIR}/a": PermissionDenied("Provided OAuth token does not have required scopes")})
    with caplog.at_level("WARNING"):
        got, note = skills_check_with_note(sp, obo, ["a"], user_email=USER, bundled={"a": "1.0 r1"})
    assert _st(got) == {"a": ("unknown", "none", "")}
    assert note.startswith("The app needs one more permission to read your skills folder.")
    assert note.endswith("Error: Provided OAuth token does not have required scopes")
    assert [c.args[0] for c in sp.workspace.get_status.call_args_list] == [f"{WDIR}/a"]
    assert any("PermissionDenied" in r.getMessage() and UDIR in r.getMessage() for r in caplog.records)


def test_skills_check_note():
    ws = _skills_ws({f"{UDIR}/a": "1.0 r1"})
    assert skills_check_with_note(ws, ws, ["a"], user_email=USER, bundled={"a": "1.0 r1"})[1] == ""
    bad = _skills_ws({f"{UDIR}/a": DatabricksError("boom"), f"{WDIR}/a": DatabricksError("boom")})
    assert skills_check_with_note(bad, bad, ["a"], user_email=USER, bundled={"a": "v"})[1] == (
        "Couldn't read your skills folder: boom Couldn't read the workspace skills folder: boom")
    got, note = skills_check_with_note(_skills_ws({}), None, ["a"], user_email=USER, bundled={"a": "v"})
    assert _st(got) == {"a": ("unknown", "none", "")} and note == SIGN_IN_TO_CHECK_SKILLS


def test_skills_check_without_a_token_still_reports_a_workspace_read_failure():
    """The sign-in note does not hide a failed workspace-wide read; each problem appears once."""
    ws = _skills_ws({f"{WDIR}/a": DatabricksError("boom"), f"{WDIR}/b": DatabricksError("boom")})
    got, note = skills_check_with_note(ws, None, ["a", "b"], user_email=USER, bundled={"a": "v", "b": "v"})
    assert {s.state for s in got} == {"unknown"}
    assert note == f"{SIGN_IN_TO_CHECK_SKILLS} Couldn't read the workspace skills folder: boom"


def test_skills_check_workspace_read_failure_is_not_a_scope_message():
    """Only the caller's own token is told to re-consent; an app-side read failure says what failed."""
    ws = _skills_ws({f"{WDIR}/a": PermissionDenied("no grant")})
    uws = _skills_ws({})
    got, note = skills_check_with_note(ws, uws, ["a"], user_email=USER, bundled={"a": "v"})
    assert _st(got) == {"a": ("unknown", "none", "")}
    assert note == "Couldn't read the workspace skills folder: no grant"


def test_token_scopes_decodes_jwt_scope_only():
    import base64, json
    from vibe_modeling.backend.assessment.handoff import token_scopes
    def jwt(claims):
        b = lambda d: base64.urlsafe_b64encode(json.dumps(d).encode()).rstrip(b"=").decode()
        return f"{b({'alg': 'none'})}.{b(claims)}.sig"
    assert token_scopes(jwt({"scope": "sql workspace.workspace", "sub": "x"})) == ["sql", "workspace.workspace"]
    assert token_scopes(jwt({"scp": ["a", "b"]})) == ["a", "b"]
    assert token_scopes("dapi-not-a-jwt") is None

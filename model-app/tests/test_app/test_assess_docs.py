"""In-app doc viewing: run-scoped path guard, capped reader, categories, folder link."""
import io
import os
import sys
from types import SimpleNamespace as NS

import pytest
from databricks.sdk.errors.platform import NotFound, PermissionDenied
from sqlmodel import Session

sys.path.insert(0, os.path.dirname(__file__))

from test_assess_ingest import OUT, _fixture_files, _seed_run, _ws_with  # noqa: E402
from vibe_modeling.backend.assessment.docs import read_doc, resolve_doc_path  # noqa: E402
from vibe_modeling.backend.assessment.ingest import ingest_domain_run  # noqa: E402
from vibe_modeling.backend.db_models import AssessDomainRun  # noqa: E402

GUARD_OUT = "/Volumes/c/_metamodel/assess_runs/b1/meter_to_cash"


@pytest.mark.parametrize("p", [
    "docs/../../b2/meter_to_cash/x.md",
    "/Volumes/c/_metamodel/assess_runs/b2/m/x.md",
    "/Volumes/c/_metamodel/assess_runs/b1/meter_to_cash_2/docs/x.md",  # sibling sharing a prefix
    "docs/design/", "docs/design", "docs/%2e%2e/x.md", "docs/%252e%252e/x.md", "docs/design/x.exe", "",
    "docs/design/x.md/", "   ", "docs/x%00.md", "docs/x\x00.md",
    "docs/%25252e%25252e/x.md", "config.json", "docs/../config.json", "summary.json", "assessment.json",
    "progress.json", "conventions.yml/", "other/x.md",
])
def test_rejects(p):
    with pytest.raises(ValueError):
        resolve_doc_path(GUARD_OUT, p)


@pytest.mark.parametrize("p,want", [
    ("docs/design/s2t_map.md", f"{GUARD_OUT}/docs/design/s2t_map.md"),
    (f"{GUARD_OUT}/docs/design/gap_registry.md", f"{GUARD_OUT}/docs/design/gap_registry.md"),
    ("conventions.yml", f"{GUARD_OUT}/conventions.yml"),
    (f"{GUARD_OUT}/conventions.yml", f"{GUARD_OUT}/conventions.yml"),
    ("docs/./design//x.yaml", f"{GUARD_OUT}/docs/design/x.yaml"),
])
def test_accepts(p, want):
    assert resolve_doc_path(GUARD_OUT, p) == want


def test_read_doc_caps_and_decodes():
    ws = NS(files=NS(download=lambda p: NS(contents=io.BytesIO(b"a" * 600_000))))
    text, truncated = read_doc(ws, "/x.md")
    assert truncated is True and len(text) == 512_000
    ws = NS(files=NS(download=lambda p: NS(contents=io.BytesIO(b"ok \xff"))))
    assert read_doc(ws, "/x.md") == ("ok �", False)


@pytest.fixture(name="dr_id")
def dr_id_fixture(engine):
    dr_id, _, _ = _seed_run(engine)
    with Session(engine) as s:
        ingest_domain_run(s, _ws_with(_fixture_files()), s.get(AssessDomainRun, dr_id))
    return dr_id


def _content(client, dr_id, path):
    return client.get(f"/api/assessment-domain-runs/{dr_id}/docs/content", params={"path": path})


def test_content_ok(client, mock_ws, dr_id):
    mock_ws.files.download.side_effect = lambda p: NS(contents=io.BytesIO(b"# hi"))
    r = _content(client, dr_id, "docs/design/s2t_map.md")
    assert r.status_code == 200
    assert r.json() == {"path": f"{OUT}/docs/design/s2t_map.md", "content": "# hi", "truncated": False}
    mock_ws.files.download.assert_called_with(f"{OUT}/docs/design/s2t_map.md")


def test_content_truncated(client, mock_ws, dr_id):
    mock_ws.files.download.side_effect = lambda p: NS(contents=io.BytesIO(b"a" * 600_000))
    j = _content(client, dr_id, "docs/x.md").json()
    assert j["truncated"] is True and len(j["content"]) == 512_000


def test_content_not_found_404(client, mock_ws, dr_id):
    mock_ws.files.download.side_effect = NotFound("nope")
    assert _content(client, dr_id, "docs/x.md").status_code == 404


def test_content_bad_path_422_without_download(client, mock_ws, dr_id):
    mock_ws.files.download.reset_mock()
    for p in ["docs/../../x.md", "docs/x.exe", "", "docs/"]:
        assert _content(client, dr_id, p).status_code == 422
    mock_ws.files.download.assert_not_called()


def test_content_other_error_409_admin_help_sanitized(client, mock_ws, dr_id):
    mock_ws.files.download.side_effect = PermissionDenied("denied for dana@example.com dapi" + "a" * 32)
    r = _content(client, dr_id, "docs/x.md")
    assert r.status_code == 409 and "dapi" + "a" * 32 not in r.text
    detail = r.json()["detail"]
    assert detail["error"] == "admin_help" and detail["runs_path"] == OUT
    assert detail["message"].startswith("Could not read doc: denied for [REDACTED]")


def test_content_unknown_run_404(client):
    assert _content(client, "nope", "docs/x.md").status_code == 404


def test_docs_categories_and_folder_url(client, mock_ws, dr_id):
    def f(path):
        return NS(path=path, name=path.rsplit("/", 1)[-1], is_directory=False)
    mock_ws.files.list_directory_contents.side_effect = lambda p: iter([
        f(f"{OUT}/docs/design/s2t_map.md"),
        f(f"{OUT}/docs/commentary/assessment-improvement-recommendations.md"),
        f(f"{OUT}/docs/readme.md")])
    r = client.get(f"/api/assessment-domain-runs/{dr_id}/docs")
    assert r.status_code == 200
    body = r.json()
    cats = {d["name"]: d["category"] for d in body["docs"]}
    assert cats == {"s2t_map.md": "design", "assessment-improvement-recommendations.md": "commentary",
                    "readme.md": "other"}
    assert all("url" not in d for d in body["docs"])
    assert body["folder_url"] == (
        "https://test-workspace.databricks.com/explore/data/volumes/test_deployment_catalog/_metamodel/"
        f"assess_runs?volumePath=/Volumes/{OUT[len('/Volumes/'):]}/")


def test_docs_missing_folder_is_empty_with_folder_url(client, mock_ws, dr_id):
    mock_ws.files.list_directory_contents.side_effect = NotFound("nope")
    body = client.get(f"/api/assessment-domain-runs/{dr_id}/docs").json()
    assert body["docs"] == [] and body["folder_url"]

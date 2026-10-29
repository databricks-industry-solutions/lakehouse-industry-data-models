"""Publishing to the industry repository strips the prefixes an import added.

Real agriculture data (``tests/fixtures/industry_agriculture_v1_trimmed.json``,
blank schema prefix, 97 ECM and 134 MVM metric views) is imported the way the
app imports it (``scope_prefix.apply_import_prefix``), stored as the version's
Lakebase domains and Volume files, then published through
``github_publish.publish_model_version`` with a fake UC connection. The PUT
bodies are what the repository would get.
"""
from __future__ import annotations

import base64
import copy
import io
import json
import zipfile
from pathlib import Path
from typing import Optional

import pytest
from fastapi import HTTPException
from sqlmodel import Session, select

from vibe_modeling.backend.db_models import Business, Domain, ModelVersion, RunArtifact
from vibe_modeling.backend.model_export import (
    build_bundle_zip_bytes,
    bundle_layout,
    export_model_json,
)
from vibe_modeling.backend.services.github_publish import (
    PublishStrip,
    build_publish_strip,
    publish_markers,
    publish_model_version,
)
from vibe_modeling.backend.services.scope_prefix import apply_import_prefix
from vibe_modeling.backend.services.version_files import version_model_json_candidates

from .test_github_publish import _FakeServingEndpoints, _oauth_cfg

FIXTURE = json.loads(
    (Path(__file__).parent.parent / "fixtures" / "industry_agriculture_v1_trimmed.json").read_text()
)
README = b"Schemas: ecm_crop, mvm_crop. Views: ecm_crop_cover_crop.\n"


class _Files:
    """``ws.files`` serving fixed bytes per Volume path."""

    def __init__(self):
        self.by_path: dict[str, bytes] = {}
        self.reads: list[str] = []
        self.failing: set[str] = set()

    def download(self, path):
        self.reads.append(path)
        if path in self.failing:
            raise TimeoutError(path)
        if path not in self.by_path:
            raise FileNotFoundError(path)
        return type("Resp", (), {"contents": io.BytesIO(self.by_path[path])})()


class _Ws:
    def __init__(self):
        self.serving_endpoints = _FakeServingEndpoints()
        self.files = _Files()

    def published(self) -> dict[str, bytes]:
        return {
            c["path"].split("/contents/", 1)[1]: base64.b64decode(c["json"]["content"])
            for c in self.serving_endpoints.calls
            if "/contents/" in c["path"]
        }


def _original(scope: str) -> dict:
    return copy.deepcopy(FIXTURE[scope])


def _imported(scope: str) -> tuple[dict, str, str]:
    root = _original(scope)
    report = apply_import_prefix(root, scope, f"{scope}_")
    return root, report.schema_prefix_added, report.view_prefix_added


def _views_sql(root: dict, count: int = 3) -> str:
    return "\n\n".join(v["sql"] for v in root["model"]["metric_views"][:count])


def _version(
    session: Session,
    ws: _Ws,
    biz: Business,
    *,
    scope: str,
    version: int,
    root: dict,
    markers: tuple[Optional[str], Optional[str]] = (None, None),
    base: Optional[ModelVersion] = None,
) -> ModelVersion:
    """A version with ``root``'s domains as Lakebase rows and three Volume
    files: its model.json (the canonical path), a metrics companion with the
    SQL of three of its views, and a readme."""
    mv = ModelVersion(
        business_id=biz.id, version=version, scope=scope, status="completed",
        files_catalog="agriculture_ecm", base_version_id=base.id if base else None,
        import_schema_prefix_added=markers[0], import_view_prefix_added=markers[1],
    )
    session.add(mv)
    session.flush()
    for d in root["model"]["domains"]:
        session.add(Domain(version_id=mv.id, name=d["name"], database_name=d["database_name"]))
    model_path = version_model_json_candidates(session, mv, biz.name)[0]
    folder = model_path.rsplit("/", 1)[0]
    files = {
        model_path: ("model_json", json.dumps(root, indent=2).encode("utf-8")),
        f"{folder}/metrics/{scope}_metric_views.sql": ("metric_sql", _views_sql(root).encode("utf-8")),
        f"{folder}/README.md": ("readme", README),
    }
    for path, (atype, data) in files.items():
        ws.files.by_path[path] = data
        session.add(RunArtifact(model_version_id=mv.id, artifact_type=atype, file_path=path))
    session.flush()
    return mv


def _business(session: Session) -> Business:
    biz = Business(name="Agriculture", kind="industry")
    session.add(biz)
    session.flush()
    return biz


def _artifacts(session: Session, mv: ModelVersion) -> list[RunArtifact]:
    return list(session.exec(select(RunArtifact).where(RunArtifact.model_version_id == mv.id)).all())


def _publish(session: Session, ws: _Ws, mv: ModelVersion) -> dict[str, bytes]:
    session.commit()
    publish_model_version(ws, _oauth_cfg(), session=session, business_id=mv.business_id, version_id=mv.id)
    return ws.published()


def _by_name(published: dict[str, bytes], suffix: str) -> bytes:
    (data,) = [d for p, d in published.items() if p.endswith(suffix)]
    return data


def _exported(published: dict[str, bytes]) -> dict:
    (data,) = [d for p, d in published.items() if p.endswith("/model.json") and "model_1" not in p]
    return json.loads(data)


@pytest.mark.parametrize("scope", ["ecm", "mvm"])
def test_publish_strips_the_import_prefixes_from_the_model_and_its_sql(engine, scope):
    ws = _Ws()
    with Session(engine) as session:
        biz = _business(session)
        root, schema_marker, view_marker = _imported(scope)
        mv = _version(session, ws, biz, scope=scope, version=1, root=root,
                      markers=(schema_marker, view_marker))
        published = _publish(session, ws, mv)

    original = _original(scope)
    assert {d["database_name"] for d in _exported(published)["model"]["domains"]} == {
        d["database_name"] for d in original["model"]["domains"]
    }
    assert json.loads(_by_name(published, "model_1.json")) == original
    assert _by_name(published, f"{scope}_metric_views.sql").decode("utf-8") == _views_sql(original)
    assert _by_name(published, "README.md") == README


def test_the_zip_download_keeps_the_apps_names(engine):
    ws = _Ws()
    with Session(engine) as session:
        biz = _business(session)
        root, schema_marker, view_marker = _imported("ecm")
        mv = _version(session, ws, biz, scope="ecm", version=1, root=root,
                      markers=(schema_marker, view_marker))
        artifacts = _artifacts(session, mv)
        layout = bundle_layout("agriculture", "ecm", 1)
        data = build_bundle_zip_bytes(ws, layout, export_model_json(session, mv.id), artifacts)

    with zipfile.ZipFile(io.BytesIO(data)) as zf:
        contents = {n.rsplit("/", 1)[-1]: zf.read(n) for n in zf.namelist()}
    assert {d["database_name"] for d in json.loads(contents["model.json"])["model"]["domains"]} == {
        d["database_name"] for d in root["model"]["domains"]
    }
    assert json.loads(contents["model_1.json"]) == root
    assert contents["ecm_metric_views.sql"].decode("utf-8") == _views_sql(root)


def test_agent_output_imported_as_written_is_published_as_is(engine):
    """An import of agent output records ``""`` markers: its names are the
    agent's, ``ecm_`` ones included, and publish keeps every byte."""
    ws = _Ws()
    with Session(engine) as session:
        biz = _business(session)
        root, _, _ = _imported("ecm")
        mv = _version(session, ws, biz, scope="ecm", version=1, root=root, markers=("", ""))
        stored = dict(ws.files.by_path)
        published = _publish(session, ws, mv)
        model_path = version_model_json_candidates(session, mv, biz.name)[0]

    assert {d["database_name"] for d in _exported(published)["model"]["domains"]} == {
        d["database_name"] for d in root["model"]["domains"]
    }
    assert _by_name(published, "model_1.json") == stored[model_path]
    assert _by_name(published, "ecm_metric_views.sql") == _views_sql(root).encode("utf-8")


def test_a_vibe_of_an_imported_version_inherits_its_markers(engine):
    """The vibe (NULL markers, the agent's run) of an imported ECM keeps the
    ECM's ``ecm_`` prefix in its file, so publish strips it like the import."""
    ws = _Ws()
    with Session(engine) as session:
        biz = _business(session)
        root, schema_marker, view_marker = _imported("ecm")
        base = _version(session, ws, biz, scope="ecm", version=1, root=root,
                        markers=(schema_marker, view_marker))
        child = _version(session, ws, biz, scope="ecm", version=2, root=copy.deepcopy(root), base=base)
        assert publish_markers(session, child) == ("ecm_", "ecm_", True)
        published = _publish(session, ws, child)

    original = _original("ecm")
    assert json.loads(_by_name(published, "model_1.json")) == original
    assert _by_name(published, "ecm_metric_views.sql").decode("utf-8") == _views_sql(original)


def test_an_inherited_schema_marker_needs_the_file_to_still_use_it(engine):
    """A descendant whose model.json names another schema prefix keeps its
    schema names; its views still lose the inherited view marker."""
    ws = _Ws()
    with Session(engine) as session:
        biz = _business(session)
        root, schema_marker, view_marker = _imported("ecm")
        base = _version(session, ws, biz, scope="ecm", version=1, root=root,
                        markers=(schema_marker, view_marker))
        changed = copy.deepcopy(root)
        changed["model"]["model_conventions"]["schema_prefix"] = "farm_"
        child = _version(session, ws, biz, scope="ecm", version=2, root=changed, base=base)
        session.flush()
        strip = build_publish_strip(session, ws, child, biz.name, _artifacts(session, child))
    assert strip.schema_map == {} and strip.view_prefix == "ecm_"


def test_an_mvm_shrunk_from_an_imported_ecm_takes_no_markers(engine):
    """Markers follow same-scope ancestors only: an MVM whose base is the ECM
    (a shrink) keeps the ``ecm_`` names it carries, published as is."""
    ws = _Ws()
    with Session(engine) as session:
        biz = _business(session)
        root, schema_marker, view_marker = _imported("ecm")
        ecm = _version(session, ws, biz, scope="ecm", version=1, root=root,
                       markers=(schema_marker, view_marker))
        mvm = _version(session, ws, biz, scope="mvm", version=2, root=copy.deepcopy(root), base=ecm)
        assert publish_markers(session, mvm) == ("", "", False)
        stored = ws.files.by_path[version_model_json_candidates(session, mvm, biz.name)[0]]
        published = _publish(session, ws, mvm)

    assert _by_name(published, "model_1.json") == stored


def test_markers_stop_at_another_business_and_at_a_cycle(engine):
    ws = _Ws()
    with Session(engine) as session:
        biz = _business(session)
        other = Business(name="Other")
        session.add(other)
        session.flush()
        root, _, _ = _imported("ecm")
        foreign = _version(session, ws, other, scope="ecm", version=1, root=root, markers=("ecm_", "ecm_"))
        mv = _version(session, ws, biz, scope="ecm", version=2, root=root, base=foreign)
        assert publish_markers(session, mv) == ("", "", False)
        a = _version(session, ws, biz, scope="ecm", version=3, root=root)
        b = _version(session, ws, biz, scope="ecm", version=4, root=root, base=a)
        a.base_version_id = b.id
        session.flush()
        assert publish_markers(session, b) == ("", "", False)


def test_a_strip_that_would_take_an_existing_name_is_skipped(engine):
    """A fresh agent view ``crop_cover_crop`` next to the import's
    ``ecm_crop_cover_crop``, and a schema ``crop`` next to ``ecm_crop``: the
    prefixed ones keep their prefix; the rest are stripped."""
    ws = _Ws()
    with Session(engine) as session:
        biz = _business(session)
        root, schema_marker, view_marker = _imported("ecm")
        model = root["model"]
        first = model["metric_views"][0]
        fresh_name = first["view_name"][len("ecm_"):]
        model["metric_views"].append({
            "view_name": fresh_name,
            "sql": first["sql"].replace(f"`{first['view_name']}`", f"`{fresh_name}`"),
        })
        model["domains"].append({"name": "crop legacy", "database_name": "crop"})
        mv = _version(session, ws, biz, scope="ecm", version=1, root=root,
                      markers=(schema_marker, view_marker))
        strip = build_publish_strip(session, ws, mv, biz.name, _artifacts(session, mv))
        assert "ecm_crop" not in strip.schema_map and strip.schema_map["ecm_land"] == "land"

        stripped = strip.model_json(copy.deepcopy(root))
        names = [v["view_name"] for v in stripped["model"]["metric_views"]]
        assert first["view_name"] in names and names.count(fresh_name) == 1
        assert len(set(names)) == len(names)
        assert names[1] == model["metric_views"][1]["view_name"][len("ecm_"):]
        schemas = [d["database_name"] for d in stripped["model"]["domains"]]
        assert schemas.count("crop") == 1 and "ecm_crop" in schemas

        sql_artifact = RunArtifact(artifact_type="metric_sql", file_path="/Volumes/x/metrics/a.sql")
        ws.files.by_path[sql_artifact.file_path] = first["sql"].encode("utf-8")
        sql = strip.read(ws, sql_artifact).decode("utf-8")
        assert f"`{first['view_name']}`" in sql


def test_nothing_to_strip_reads_no_file(engine):
    """A version without markers (an agent run) publishes without reading its
    files for the strip: only the bundle reads them."""
    ws = _Ws()
    with Session(engine) as session:
        biz = _business(session)
        root, _, _ = _imported("ecm")
        mv = _version(session, ws, biz, scope="ecm", version=1, root=root)
        strip = build_publish_strip(session, ws, mv, biz.name, _artifacts(session, mv))
    assert strip == PublishStrip() and not strip.active
    assert ws.files.reads == []


def _ddl(root: dict, domains: int = 2) -> str:
    """Schema DDL the way the agent writes ``schemas/*.sql`` (agriculture
    v1): a database per domain, its tags, a table and a foreign key."""
    picked = root["model"]["domains"][:domains]
    names = [d["database_name"] for d in picked]
    out = []
    for name, domain in zip(names, (d["name"] for d in picked)):
        out += [
            f"CREATE DATABASE IF NOT EXISTS `agriculture_ecm`.`{name}` COMMENT 'The {domain} domain.';",
            f"ALTER SCHEMA `agriculture_ecm`.`{name}` SET TAGS ('dbx_domain' = '{domain}');",
            f"CREATE OR REPLACE TABLE `agriculture_ecm`.`{name}`.`event` (`id` BIGINT);",
            f"ALTER TABLE `agriculture_ecm`.`{name}`.`event` ADD CONSTRAINT `fk` FOREIGN KEY (`id`) "
            f"REFERENCES agriculture_ecm.{names[0]}.`event`(`id`);",
        ]
    return "\n".join(out)


def test_a_vibes_schema_ddl_is_stripped_and_a_name_sharing_the_prefix_is_kept(engine):
    """A vibe's DDL companion names its schemas ``ecm_<domain>`` in every
    statement; publish gives them the upstream names. ``ecm_crop_extra`` is no
    schema of the model and stays as written."""
    ws = _Ws()
    with Session(engine) as session:
        biz = _business(session)
        root, schema_marker, view_marker = _imported("ecm")
        base = _version(session, ws, biz, scope="ecm", version=1, root=root,
                        markers=(schema_marker, view_marker))
        child = _version(session, ws, biz, scope="ecm", version=2, root=copy.deepcopy(root), base=base)
        folder = version_model_json_candidates(session, child, biz.name)[0].rsplit("/", 1)[0]
        extra = "ALTER TABLE `agriculture_ecm`.`ecm_crop_extra`.`t` SET TAGS ('a' = 'ecm_crop');"
        path = f"{folder}/schemas/agriculture_schema_v2_ecm.sql"
        ws.files.by_path[path] = (_ddl(root) + "\n" + extra).encode("utf-8")
        session.add(RunArtifact(model_version_id=child.id, artifact_type="sql_ddl", file_path=path))
        published = _publish(session, ws, child)

    expected = _ddl(_original("ecm")) + "\n" + extra
    assert "ecm_crop`" in _ddl(root)
    assert _by_name(published, "agriculture_schema_v2_ecm.sql").decode("utf-8") == expected


def _contents_calls(ws: _Ws) -> list[dict]:
    return [c for c in ws.serving_endpoints.calls if "/contents/" in c["path"] or c["path"].endswith("/git/refs")]


def test_an_unreadable_model_file_for_an_inherited_marker_refuses_the_publish(engine):
    """The vibe's model.json cannot be read, so publish cannot tell whether
    the inherited schema marker still applies: 502, nothing on GitHub."""
    ws = _Ws()
    with Session(engine) as session:
        biz = _business(session)
        root, schema_marker, view_marker = _imported("ecm")
        base = _version(session, ws, biz, scope="ecm", version=1, root=root,
                        markers=(schema_marker, view_marker))
        child = _version(session, ws, biz, scope="ecm", version=2, root=copy.deepcopy(root), base=base)
        ws.files.failing.update(version_model_json_candidates(session, child, biz.name))
        with pytest.raises(HTTPException) as ei:
            _publish(session, ws, child)
    assert ei.value.status_code == 502
    assert "Nothing was published" in ei.value.detail["message"]
    assert _contents_calls(ws) == []


def test_an_unreadable_model_json_artifact_refuses_the_publish(engine):
    ws = _Ws()
    with Session(engine) as session:
        biz = _business(session)
        root, schema_marker, view_marker = _imported("mvm")
        mv = _version(session, ws, biz, scope="mvm", version=1, root=root,
                      markers=(schema_marker, view_marker))
        model_path = version_model_json_candidates(session, mv, biz.name)[0]
        ws.files.failing.add(model_path)
        with pytest.raises(HTTPException) as ei:
            _publish(session, ws, mv)
    assert ei.value.status_code == 502
    assert ei.value.detail["path"] == model_path
    assert _contents_calls(ws) == []


def test_each_model_json_artifact_is_read_once(engine):
    ws = _Ws()
    with Session(engine) as session:
        biz = _business(session)
        root, schema_marker, view_marker = _imported("ecm")
        mv = _version(session, ws, biz, scope="ecm", version=1, root=root,
                      markers=(schema_marker, view_marker))
        model_path = version_model_json_candidates(session, mv, biz.name)[0]
        _publish(session, ws, mv)
    assert ws.files.reads.count(model_path) == 1


@pytest.mark.parametrize("body", [b"{not json", b"[1, 2]", b"", b"42", b'{"notes": "ecm_crop"}'])
def test_an_extra_model_json_that_is_no_model_is_published_as_read(engine, body):
    """A ``model_json`` artifact that reads but is no model dict (broken
    JSON, a list, empty, a scalar, a dict without a model) passes through
    byte for byte; the version's model.json is still stripped."""
    ws = _Ws()
    with Session(engine) as session:
        biz = _business(session)
        root, schema_marker, view_marker = _imported("ecm")
        mv = _version(session, ws, biz, scope="ecm", version=1, root=root,
                      markers=(schema_marker, view_marker))
        folder = version_model_json_candidates(session, mv, biz.name)[0].rsplit("/", 1)[0]
        extra = f"{folder}/vibes/model.json"
        ws.files.by_path[extra] = body
        session.add(RunArtifact(model_version_id=mv.id, artifact_type="model_json", file_path=extra))
        published = _publish(session, ws, mv)

    companions = [d for p, d in published.items() if p.rsplit("/", 1)[-1] in ("model_1.json", "model_2.json")]
    assert body in companions
    (stripped,) = [d for d in companions if d != body]
    assert json.loads(stripped) == _original("ecm")


def test_a_stripped_model_json_keeps_non_ascii_text_and_ascii_files_stay_byte_exact(engine):
    """An agent file written with ``ensure_ascii=False`` keeps its characters;
    the ASCII upstream file comes back byte for byte as ``indent=2`` JSON."""
    ws = _Ws()
    with Session(engine) as session:
        biz = _business(session)
        root, schema_marker, view_marker = _imported("ecm")
        root["model"]["description"] = "Gestão agrícola — safra"
        mv = _version(session, ws, biz, scope="ecm", version=1, root=root,
                      markers=(schema_marker, view_marker))
        model_path = version_model_json_candidates(session, mv, biz.name)[0]
        ws.files.by_path[model_path] = json.dumps(root, indent=2, ensure_ascii=False).encode("utf-8")
        published = _publish(session, ws, mv)

    original = _original("ecm")
    original["model"]["description"] = "Gestão agrícola — safra"
    data = _by_name(published, "model_1.json")
    assert data == json.dumps(original, indent=2, ensure_ascii=False).encode("utf-8")
    assert b"\\u" not in data

    ws = _Ws()
    with Session(engine) as session:
        biz = Business(name="Agriculture Two", kind="industry")
        session.add(biz)
        session.flush()
        root, schema_marker, view_marker = _imported("mvm")
        mv = _version(session, ws, biz, scope="mvm", version=1, root=root,
                      markers=(schema_marker, view_marker))
        published = _publish(session, ws, mv)
    assert _by_name(published, "model_1.json") == json.dumps(_original("mvm"), indent=2).encode("utf-8")

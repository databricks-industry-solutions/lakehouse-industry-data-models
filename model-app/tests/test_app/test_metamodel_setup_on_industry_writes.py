"""Industry download and kickstart set up ``<catalog>._metamodel`` first.

Both write to the deployment catalog's ``_metamodel`` volume and registry, and
a catalog changed in Settings has neither. Each now calls the canonical
``ensure_metamodel_schema_and_volume`` after every check that can refuse the
request (conventions section 6), so a refused request writes nothing, in
Lakebase or in Unity Catalog. Runs on the recording UC fake.
"""
from __future__ import annotations

import pytest
from databricks.sdk.errors import PermissionDenied
from fastapi import HTTPException
from sqlmodel import Session, select

from vibe_modeling.backend.db_models import AgentConfig, Business, ModelVersion, Run, Sector
from vibe_modeling.backend.services.industry_download import download_industry_model
from vibe_modeling.backend.services.industry_kickstart import KickstartError, kickstart_from_industry

from ._drift.fixtures import fake_uc  # noqa: F401
from .test_industry_kickstart import _seed_industry
from .test_industry_models import _FakeConnector, _patch_connector

UC_WRITES = {"schemas.create", "volumes.create", "files.upload", "files.create_directory", "files.delete"}
CAT = "test_deployment_catalog"
VERSION_DIR = f"/Volumes/{CAT}/_metamodel/vol_root/business/acme_retail_industry/v1/ecm"


def _writes(fake):
    return [c.seam for c in fake.calls if c.seam in UC_WRITES]


def _digest(engine):
    with Session(engine) as session:
        return {
            model.__name__: sorted(r.id for r in session.exec(select(model)).all())
            for model in (Business, ModelVersion, Run)
        }


@pytest.fixture
def sector_id(engine):
    with Session(engine) as session:
        s = Sector(name="Retail", short_name="retail")
        session.add(s)
        session.commit()
        return s.id


def _download(engine, fake, config, sector_id, **over):
    args = dict(sector_id=sector_id, industry_id="retail", model_id="v1_ecm")
    args.update(over)
    with Session(engine) as session:
        return download_industry_model(session, fake.ws, config=config, **args)


class TestDownload:
    def test_fresh_catalog_gets_the_schema_and_volume_then_the_artifacts(
        self, engine, fake_uc, config, sector_id, monkeypatch,
    ):
        fake_uc.add_catalog(CAT)
        _patch_connector(monkeypatch, _FakeConnector())

        result = _download(engine, fake_uc, config, sector_id)

        writes = _writes(fake_uc)
        assert writes[:2] == ["schemas.create", "volumes.create"]
        assert "files.upload" in writes[2:]
        assert fake_uc.ws.volumes.read(f"{CAT}._metamodel.vol_root").name == "vol_root"
        assert fake_uc.read_json(f"{VERSION_DIR}/model.json")["model"]["name"] == "Acme Retail Industry"
        assert f"{VERSION_DIR}/schemas/sales_schema.sql" in fake_uc._files
        assert result.warnings == []

    def test_existing_metamodel_is_left_as_is(self, engine, fake_uc, config, sector_id, monkeypatch):
        fake_uc.add_metamodel(CAT)
        _patch_connector(monkeypatch, _FakeConnector())

        _download(engine, fake_uc, config, sector_id)

        assert "schemas.create" not in _writes(fake_uc)
        assert "volumes.create" not in _writes(fake_uc)
        assert f"{VERSION_DIR}/schemas/sales_schema.sql" in fake_uc._files

    def test_schema_without_the_volume_gets_only_the_volume(
        self, engine, fake_uc, config, sector_id, monkeypatch,
    ):
        fake_uc.add_schema(CAT, "_metamodel")
        _patch_connector(monkeypatch, _FakeConnector())

        _download(engine, fake_uc, config, sector_id)

        assert [c.seam for c in fake_uc.calls if c.seam.endswith(".create")] == ["volumes.create"]

    def test_additive_scope_download_sets_up_too(self, engine, fake_uc, config, sector_id, monkeypatch):
        fake_uc.add_catalog(CAT)
        with Session(engine) as session:
            b = Business(name="Acme Retail Industry", kind="industry", sector_id=sector_id)
            session.add(b)
            session.flush()
            session.add(ModelVersion(business_id=b.id, version=1, status="completed", scope="mvm"))
            session.commit()
        _patch_connector(monkeypatch, _FakeConnector())

        result = _download(engine, fake_uc, config, sector_id)

        assert result.on_conflict_applied == "added"
        assert _writes(fake_uc)[:2] == ["schemas.create", "volumes.create"]

    def test_same_scope_clash_writes_nothing(self, engine, fake_uc, config, sector_id, monkeypatch):
        fake_uc.add_catalog(CAT)
        with Session(engine) as session:
            b = Business(name="Acme Retail Industry", kind="industry", sector_id=sector_id)
            session.add(b)
            session.flush()
            session.add(ModelVersion(business_id=b.id, version=1, status="completed", scope="ecm"))
            session.commit()
        _patch_connector(monkeypatch, _FakeConnector())
        before = _digest(engine)

        with pytest.raises(HTTPException) as refused:
            _download(engine, fake_uc, config, sector_id)

        assert refused.value.status_code == 409
        assert fake_uc.calls == []
        assert _digest(engine) == before

    def test_unknown_sector_writes_nothing(self, engine, fake_uc, config, sector_id, monkeypatch):
        fake_uc.add_catalog(CAT)
        _patch_connector(monkeypatch, _FakeConnector())
        before = _digest(engine)

        with pytest.raises(HTTPException) as refused:
            _download(engine, fake_uc, config, "no-such-sector")

        assert refused.value.status_code == 404
        assert fake_uc.calls == []
        assert _digest(engine) == before

    def test_name_clash_with_a_business_writes_nothing(self, engine, fake_uc, config, sector_id, monkeypatch):
        fake_uc.add_catalog(CAT)
        with Session(engine) as session:
            session.add(Business(name="acme-retail industry", kind="business"))
            session.commit()
        _patch_connector(monkeypatch, _FakeConnector())
        before = _digest(engine)

        with pytest.raises(HTTPException) as refused:
            _download(engine, fake_uc, config, sector_id)

        assert refused.value.status_code == 409
        assert fake_uc.calls == []
        assert _digest(engine) == before

    def test_setup_refused_by_unity_catalog_refuses_the_download_and_writes_nothing(
        self, engine, fake_uc, config, sector_id, monkeypatch,
    ):
        fake_uc.add_catalog(CAT)

        def deny(*_a, **_k):
            raise PermissionDenied("denied")

        monkeypatch.setattr(fake_uc.ws.schemas, "create", deny)
        _patch_connector(monkeypatch, _FakeConnector())
        before = _digest(engine)

        with pytest.raises(HTTPException) as refused:
            _download(engine, fake_uc, config, sector_id)

        assert refused.value.status_code == 400
        assert "can't create `_metamodel`" in refused.value.detail
        assert "files.upload" not in _writes(fake_uc)
        assert _digest(engine) == before


def _seed_config(engine, catalog=CAT):
    with Session(engine) as session:
        session.add(AgentConfig(deployment_catalog=catalog, warehouse_id="wh-1"))
        session.commit()


def _kickstart(engine, fake, industry_id, **over):
    args = dict(source_industry_id=industry_id, source_version=1, new_name="Kick Co")
    args.update(over)
    with Session(engine) as session:
        return kickstart_from_industry(session, fake.ws, **args)


class TestKickstart:
    def test_fresh_catalog_gets_the_schema_and_volume_before_the_seed(self, engine, fake_uc):
        _seed_config(engine)
        fake_uc.add_catalog(CAT)
        industry_id, _ = _seed_industry(engine)

        _kickstart(engine, fake_uc, industry_id)

        assert _writes(fake_uc)[:2] == ["schemas.create", "volumes.create"]
        seams = [c.seam for c in fake_uc.calls]
        assert seams.index("volumes.create") < seams.index("seed_metamodel_one")
        assert fake_uc.ws.volumes.read(f"{CAT}._metamodel.vol_root").name == "vol_root"

    def test_existing_metamodel_is_left_as_is(self, engine, fake_uc):
        _seed_config(engine)
        fake_uc.add_metamodel(CAT)
        industry_id, _ = _seed_industry(engine)

        _kickstart(engine, fake_uc, industry_id)

        assert "schemas.create" not in _writes(fake_uc)
        assert "volumes.create" not in _writes(fake_uc)
        assert "seed_metamodel_one" in [c.seam for c in fake_uc.calls]

    def test_without_a_workspace_client_nothing_is_set_up(self, engine):
        _seed_config(engine)
        industry_id, _ = _seed_industry(engine)

        with Session(engine) as session:
            business = kickstart_from_industry(
                session, None, source_industry_id=industry_id, source_version=1, new_name="Offline Co",
            )
            assert business.id

    @pytest.mark.parametrize("refusal", ["missing_version", "name_taken", "no_description"])
    def test_refused_kickstart_writes_nothing(self, engine, fake_uc, refusal):
        _seed_config(engine)
        fake_uc.add_catalog(CAT)
        industry_id, _ = _seed_industry(engine)
        args = {}
        if refusal == "missing_version":
            args["source_version"] = 99
        elif refusal == "name_taken":
            with Session(engine) as session:
                session.add(Business(name="Kick Co", kind="business"))
                session.commit()
        else:
            with Session(engine) as session:
                industry = session.get(Business, industry_id)
                industry.description = ""
                session.add(industry)
                session.commit()
            args["new_description"] = "  "
        before = _digest(engine)

        with pytest.raises(Exception):
            _kickstart(engine, fake_uc, industry_id, **args)

        assert fake_uc.calls == []
        assert _digest(engine) == before

    def test_setup_refused_by_unity_catalog_refuses_the_kickstart_and_writes_nothing(
        self, engine, fake_uc, monkeypatch,
    ):
        _seed_config(engine)
        fake_uc.add_catalog(CAT)
        industry_id, _ = _seed_industry(engine)

        def deny(*_a, **_k):
            raise PermissionDenied("denied")

        monkeypatch.setattr(fake_uc.ws.schemas, "create", deny)
        before = _digest(engine)

        with pytest.raises(KickstartError, match="can't create `_metamodel`"):
            _kickstart(engine, fake_uc, industry_id)

        assert "seed_metamodel_one" not in [c.seam for c in fake_uc.calls]
        assert _digest(engine) == before


LONG_CAT = "cat_" + "x" * 120
SP_ID = "app-sp-0123456789abcdef"


def _invisible_metamodel(fake, monkeypatch, catalog):
    """``<catalog>._metamodel`` exists but the app can't see it: reads are
    denied and the create answers SCHEMA_ALREADY_EXISTS."""
    from databricks.sdk.errors import BadRequest

    from vibe_modeling.backend.core import _app_identity

    fake.add_catalog(catalog)

    def denied(*_a, **_k):
        raise PermissionDenied("no USE SCHEMA")

    def exists(*_a, **_k):
        raise BadRequest("[SCHEMA_ALREADY_EXISTS] exists", error_code="SCHEMA_ALREADY_EXISTS")

    monkeypatch.setattr(fake.ws.schemas, "get", denied)
    monkeypatch.setattr(fake.ws.schemas, "create", exists)
    monkeypatch.setattr(_app_identity, "app_application_id", lambda ws: SP_ID)


def _assert_full_grants(text: str, catalog: str) -> None:
    from vibe_modeling.backend.error_sanitization import MAX_ERROR_LENGTH, sanitize_error_detail

    shown = sanitize_error_detail(text)
    assert len(shown) > MAX_ERROR_LENGTH
    last = f"GRANT READ VOLUME, WRITE VOLUME ON VOLUME `{catalog}`.`_metamodel`.`vol_root` TO `{SP_ID}`;"
    assert shown.rstrip().endswith(last), shown[-200:]
    assert f"GRANT USE SCHEMA ON SCHEMA `{catalog}`.`_metamodel` TO `{SP_ID}`;" in shown


class TestInvisibleMetamodelRefusal:
    def test_download_400_carries_every_grant(self, engine, fake_uc, config, sector_id, monkeypatch):
        _seed_config(engine, catalog=LONG_CAT)
        _invisible_metamodel(fake_uc, monkeypatch, LONG_CAT)
        _patch_connector(monkeypatch, _FakeConnector())
        before = _digest(engine)

        with pytest.raises(HTTPException) as refused:
            _download(engine, fake_uc, config, sector_id)

        assert refused.value.status_code == 400
        _assert_full_grants(refused.value.detail, LONG_CAT)
        assert "files.upload" not in _writes(fake_uc)
        assert _digest(engine) == before

    def test_kickstart_error_carries_every_grant(self, engine, fake_uc, monkeypatch):
        _seed_config(engine, catalog=LONG_CAT)
        _invisible_metamodel(fake_uc, monkeypatch, LONG_CAT)
        industry_id, _ = _seed_industry(engine)
        before = _digest(engine)

        with pytest.raises(KickstartError) as refused:
            _kickstart(engine, fake_uc, industry_id)

        _assert_full_grants(refused.value.detail, LONG_CAT)
        assert _digest(engine) == before

    def test_kickstart_route_answers_the_full_grants(self, client, monkeypatch):
        from vibe_modeling.backend.error_sanitization import AppMessage
        from vibe_modeling.backend.routes import industry_models

        text = AppMessage("x" * 600 + " GRANT USE SCHEMA ON SCHEMA `c`.`_metamodel` TO `sp`;")

        def refuse(*_a, **_k):
            raise KickstartError(text)

        monkeypatch.setattr(industry_models, "kickstart_from_industry", refuse)
        resp = client.post("/api/industry-models/ind-1/kickstart", json={"source_version": 1, "new_name": "Kick Co"})

        assert resp.status_code == 400, resp.text
        assert resp.json()["detail"].endswith("TO `sp`;")

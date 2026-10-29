"""Tests for ``DELETE /businesses/{business_id}/versions/{version_id}``.

The route is operation_id ``deleteVersion`` and goes through the one delete
service (``_version_lifecycle.delete_version``).

Covers:
  - latest imported ECM v2 → 200, cascade rows gone, no run started
  - a Dry Run draft or a replaced version that is not installed → 200,
    wherever it sits in the scope
  - a version with a newer one above it → 409 "Delete the newer versions
    first"; an installed version → 409 ``installed``; an active run on the
    business → 409; a refusal writes nothing
  - ``reinstall_previous`` is gone: the route never starts a run
  - cross-scope sanity: deleting ECM v1 while MVM v1 exists succeeds
"""

from __future__ import annotations

import os
import sys

sys.path.insert(
    0,
    os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"),
)

import pytest
from sqlmodel import Session, select

from vibe_modeling.backend.db_models import (
    Attribute,
    Business,
    DiagramLayout,
    Domain,
    ForeignKeyLink,
    ModelVersion,
    Product,
    Run,
    RunArtifact,
)


def _seed_business_with_two_scoped_versions(
    engine,
    *,
    scope: str = "ecm",
    latest_deployed: bool = False,
    latest_imported: bool = False,
    latest_uc_catalog: str = "cat_a",
) -> tuple[str, dict[int, str]]:
    """Seed a Business + two same-scope ModelVersions (v1 + v2).

    Adds structure rows on v2 so the cascade has something to clean.
    """
    with Session(engine) as s:
        b = Business(
            name="delete_corp",
            description="t",
            industry_alignment="Retail",
        )
        s.add(b)
        s.flush()
        biz_id = b.id

        v_ids: dict[int, str] = {}
        for n in (1, 2):
            kwargs: dict = dict(
                business_id=biz_id,
                version=n,
                status="completed",
                scope=scope,
                uc_catalog=latest_uc_catalog if n == 2 else "cat_a",
                deployment_status=(
                    "deployed" if n == 2 and latest_deployed else "uninstalled"
                ),
            )
            if n == 2 and latest_imported:
                # Imports record source path + clear the catalog (route
                # accepts no catalog as "never installed").
                kwargs["uc_catalog"] = ""
                kwargs["import_source_path"] = (
                    "/Volumes/cat_a/_metamodel/vol_root/business/delete_corp/v2_ecm/model.json"
                )
                kwargs["deployment_status"] = "draft"
            mv = ModelVersion(**kwargs)
            s.add(mv)
            s.flush()
            v_ids[n] = mv.id

        # Structure rows + a layout + an artifact on v2 so we can prove
        # cascade actually fires.
        d = Domain(version_id=v_ids[2], name="dom_x", database_name="dom_x_v2")
        s.add(d)
        s.flush()
        p = Product(domain_id=d.id, version_id=v_ids[2], name="prod_x")
        s.add(p)
        s.flush()
        a = Attribute(product_id=p.id, name="col_x")
        s.add(a)
        fkl = ForeignKeyLink(
            version_id=v_ids[2],
            source_domain="dom_x", source_product="prod_x", source_column="col_x",
            target_domain="dom_x", target_product="prod_x", target_column="col_x",
        )
        s.add(fkl)
        dl = DiagramLayout(
            business_id=biz_id, version_id=v_ids[2],
            cache_key="k", layout_json="{}",
        )
        s.add(dl)
        ra = RunArtifact(
            run_id=None, model_version_id=v_ids[2],
            artifact_type="json", file_path="x.json",
        )
        s.add(ra)
        s.commit()

    return biz_id, v_ids


def _count_structure_rows(engine, version_id: str) -> dict[str, int]:
    with Session(engine) as s:
        domains = list(s.exec(select(Domain).where(Domain.version_id == version_id)).all())
        product_count = 0
        attr_count = 0
        for d in domains:
            prods = list(s.exec(select(Product).where(Product.domain_id == d.id)).all())
            product_count += len(prods)
            for p in prods:
                attrs = list(
                    s.exec(select(Attribute).where(Attribute.product_id == p.id)).all()
                )
                attr_count += len(attrs)
        return {
            "domains": len(domains),
            "products": product_count,
            "attributes": attr_count,
            "fk_links": len(list(
                s.exec(select(ForeignKeyLink).where(ForeignKeyLink.version_id == version_id)).all()
            )),
            "layouts": len(list(
                s.exec(select(DiagramLayout).where(DiagramLayout.version_id == version_id)).all()
            )),
            "artifacts": len(list(
                s.exec(select(RunArtifact).where(RunArtifact.model_version_id == version_id)).all()
            )),
        }


class TestDeleteVersionDefault:
    """Deleting the latest version of a scope."""

    def test_delete_latest_imported_ecm_succeeds_no_orchestrator(
        self, fk_engine, fk_client
    ):
        # Runs under FK enforcement: the element tree, layout, and artifact all
        # die via the DB ``version_id`` ON DELETE CASCADE when the version row
        # goes.
        biz_id, v_ids = _seed_business_with_two_scoped_versions(
            fk_engine, scope="ecm", latest_imported=True
        )

        r = fk_client.delete(
            f"/api/businesses/{biz_id}/versions/{v_ids[2]}"
        )
        assert r.status_code == 200, r.text
        body = r.json()
        assert body["deleted_version"] == 2
        assert body["previous_version"] == 1
        assert "run_id" not in body
        with Session(fk_engine) as s:
            assert s.exec(select(Run).where(Run.business_id == biz_id)).all() == []

        # Cascade rows gone.
        rows = _count_structure_rows(fk_engine, v_ids[2])
        assert rows == {
            "domains": 0, "products": 0, "attributes": 0,
            "fk_links": 0, "layouts": 0, "artifacts": 0,
        }
        # ModelVersion row gone.
        with Session(fk_engine) as s:
            assert s.get(ModelVersion, v_ids[2]) is None
            assert s.get(ModelVersion, v_ids[1]) is not None

    def test_delete_latest_when_only_version_in_scope(
        self, engine, client_with_agent
    ):
        """A single same-scope version still counts as "the latest"; the
        delete succeeds and reports previous_version=None."""
        with Session(engine) as s:
            b = Business(name="lone", description="t", industry_alignment="Retail")
            s.add(b)
            s.flush()
            mv = ModelVersion(
                business_id=b.id, version=1, status="completed", scope="mvm",
                uc_catalog="cat", deployment_status="uninstalled",
            )
            s.add(mv)
            s.commit()
            biz_id, vid = b.id, mv.id

        r = client_with_agent.delete(f"/api/businesses/{biz_id}/versions/{vid}")
        assert r.status_code == 200, r.text
        body = r.json()
        assert body["deleted_version"] == 1
        assert body["previous_version"] is None

    def test_delete_non_latest_in_scope_rejected(
        self, engine, client_with_agent
    ):
        biz_id, v_ids = _seed_business_with_two_scoped_versions(engine, scope="ecm")
        r = client_with_agent.delete(
            f"/api/businesses/{biz_id}/versions/{v_ids[1]}"
        )
        assert r.status_code == 409, r.text
        assert r.json()["detail"] == "Delete the newer versions first (v2)"

        # Nothing was deleted.
        with Session(engine) as s:
            assert s.get(ModelVersion, v_ids[1]) is not None
            assert s.get(ModelVersion, v_ids[2]) is not None

    def test_cross_scope_does_not_block_delete(
        self, engine, client_with_agent
    ):
        """Business has ECM v1 + MVM v1. Deleting ECM v1 (latest in its
        scope) must succeed; MVM v1 is unaffected."""
        with Session(engine) as s:
            b = Business(name="cross", description="t", industry_alignment="Retail")
            s.add(b)
            s.flush()
            mv_ecm = ModelVersion(
                business_id=b.id, version=1, status="completed",
                scope="ecm", uc_catalog="cat", deployment_status="uninstalled",
            )
            mv_mvm = ModelVersion(
                business_id=b.id, version=1, status="completed",
                scope="mvm", uc_catalog="cat", deployment_status="uninstalled",
            )
            s.add(mv_ecm)
            s.add(mv_mvm)
            s.commit()
            biz_id, ecm_id, mvm_id = b.id, mv_ecm.id, mv_mvm.id

        r = client_with_agent.delete(f"/api/businesses/{biz_id}/versions/{ecm_id}")
        assert r.status_code == 200, r.text

        with Session(engine) as s:
            assert s.get(ModelVersion, ecm_id) is None
            assert s.get(ModelVersion, mvm_id) is not None

    def test_delete_clears_run_version_id_pointer(
        self, fk_engine, fk_client
    ):
        """A run that only REFERENCES the deleted version as a source
        (``Run.version_id`` pointer, no RunOperation that produced it) is kept;
        its ``version_id`` is SET NULL via the DB ON DELETE rule. Runs under FK
        enforcement so the SET NULL actually fires."""
        biz_id, v_ids = _seed_business_with_two_scoped_versions(fk_engine, scope="ecm")
        with Session(fk_engine) as s:
            r = Run(
                business_id=biz_id, version_id=v_ids[2],
                intent="vibe-iterate", status="completed",
                parameters_json="{}",
            )
            s.add(r)
            s.commit()
            run_id = r.id

        resp = fk_client.delete(
            f"/api/businesses/{biz_id}/versions/{v_ids[2]}"
        )
        assert resp.status_code == 200, resp.text

        with Session(fk_engine) as s:
            run = s.get(Run, run_id)
            assert run is not None
            assert run.version_id is None


def _seed_ladder(engine) -> tuple[str, dict[int, str]]:
    """v3 replaced, v4 superseded, v5 the installed head, v6 a Dry Run draft."""
    from datetime import datetime, timezone

    with Session(engine) as s:
        b = Business(name="ladder", description="t", industry_alignment="Retail")
        s.add(b)
        s.flush()
        ids: dict[int, str] = {}
        for n, status, deployment, extra in (
            (3, "superseded", "uninstalled", {"replaced_at": datetime.now(timezone.utc)}),
            (4, "superseded", "uninstalled", {}),
            (5, "completed", "deployed", {}),
            (6, "draft", "draft", {"dry_run": True}),
        ):
            mv = ModelVersion(
                business_id=b.id, version=n, status=status, scope="ecm",
                uc_catalog="cat", files_catalog="cat", deployment_status=deployment, **extra,
            )
            s.add(mv)
            s.flush()
            ids[n] = mv.id
        s.commit()
        return b.id, ids


class TestDeleteVersionRules:
    """Base B6: drafts and replaced versions are deletable anywhere in the
    scope; an active run blocks every delete."""

    @pytest.mark.parametrize("n", [3, 6])
    def test_replaced_or_draft_version_is_deletable(self, engine, client_with_agent, n):
        biz_id, ids = _seed_ladder(engine)
        r = client_with_agent.delete(f"/api/businesses/{biz_id}/versions/{ids[n]}")
        assert r.status_code == 200, r.text
        assert r.json()["deleted_version"] == n
        with Session(engine) as s:
            assert s.get(ModelVersion, ids[n]) is None
            assert s.get(ModelVersion, ids[5]) is not None

    def test_superseded_version_in_the_middle_is_refused(self, engine, client_with_agent):
        biz_id, ids = _seed_ladder(engine)
        r = client_with_agent.delete(f"/api/businesses/{biz_id}/versions/{ids[4]}")
        assert r.status_code == 409, r.text
        assert r.json()["detail"] == "Delete the newer versions first (v5)"
        with Session(engine) as s:
            assert s.get(ModelVersion, ids[4]) is not None

    def test_installed_replaced_version_is_refused(self, engine, client_with_agent):
        biz_id, ids = _seed_ladder(engine)
        with Session(engine) as s:
            mv = s.get(ModelVersion, ids[3])
            mv.deployment_status = "deployed"
            s.add(mv)
            s.commit()
        r = client_with_agent.delete(f"/api/businesses/{biz_id}/versions/{ids[3]}")
        assert r.status_code == 409, r.text
        assert r.json()["detail"]["error"] == "installed"
        assert r.json()["detail"]["catalogs"] == ["cat"]

    def test_active_run_refuses_and_writes_nothing(self, engine, client_with_agent, mock_ws):
        biz_id, ids = _seed_ladder(engine)
        with Session(engine) as s:
            s.add(Run(business_id=biz_id, intent="vibe-iterate", status="running"))
            s.commit()
        r = client_with_agent.delete(f"/api/businesses/{biz_id}/versions/{ids[6]}")
        assert r.status_code == 409, r.text
        assert "active run" in r.json()["detail"]
        mock_ws.statement_execution.execute_statement.assert_not_called()
        with Session(engine) as s:
            assert s.get(ModelVersion, ids[6]) is not None

    def test_reinstall_previous_starts_no_run(self, engine, client_with_agent):
        biz_id, ids = _seed_ladder(engine)
        r = client_with_agent.delete(
            f"/api/businesses/{biz_id}/versions/{ids[6]}?reinstall_previous=true"
        )
        assert r.status_code == 200, r.text
        assert "run_id" not in r.json()
        with Session(engine) as s:
            assert s.exec(select(Run).where(Run.business_id == biz_id)).all() == []

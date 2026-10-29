"""Integration tests for API routes using the real router.py with dependency overrides.

Tests all CRUD operations against the actual FastAPI route handlers in router.py,
with in-memory SQLite replacing Lakebase and a mock WorkspaceClient replacing the SDK.
"""

import json
from types import SimpleNamespace

import pytest
from databricks.sdk.errors import NotFound


# --- Business CRUD ---


class TestBusinessCRUD:
    def test_list_empty(self, client):
        response = client.get("/api/businesses")
        assert response.status_code == 200
        assert response.json() == []

    def test_create_business(self, client):
        response = client.post("/api/businesses", json={
            "name": "Acme Corp",
            "description": "Test company",
            "industry_alignment": "Retail",
        })
        assert response.status_code == 200
        data = response.json()
        assert data["name"] == "Acme Corp"
        assert data["description"] == "Test company"
        assert data["industry_alignment"] == "Retail"
        assert "id" in data
        assert "created_at" in data
        assert "updated_at" in data

    def test_create_industry_kind_and_filter(self, client):
        """ADR D-046: an industry is a ``businesses`` row with kind='industry'.
        The list endpoint takes an optional ``kind`` filter; absent → all rows.
        """
        biz = client.post(
            "/api/businesses",
            json={"name": "Plain Co", "description": "A normal business"},
        )
        assert biz.status_code == 200
        assert biz.json()["kind"] == "business"

        ind = client.post(
            "/api/businesses",
            json={
                "name": "Retail Industry",
                "description": "An industry template",
                "kind": "industry",
            },
        )
        assert ind.status_code == 200
        assert ind.json()["kind"] == "industry"

        # No filter → both rows.
        all_rows = client.get("/api/businesses").json()
        assert {r["name"] for r in all_rows} == {"Plain Co", "Retail Industry"}

        # kind=business → only the plain business.
        biz_rows = client.get("/api/businesses", params={"kind": "business"}).json()
        assert [r["name"] for r in biz_rows] == ["Plain Co"]
        assert all(r["kind"] == "business" for r in biz_rows)

        # kind=industry → only the industry.
        ind_rows = client.get("/api/businesses", params={"kind": "industry"}).json()
        assert [r["name"] for r in ind_rows] == ["Retail Industry"]
        assert all(r["kind"] == "industry" for r in ind_rows)

    def test_create_business_with_sector(self, client):
        """``sector_id`` set on create is echoed back on the business row."""
        sec = client.post(
            "/api/sectors",
            json={"name": "Consumer", "short_name": "consumer"},
        )
        assert sec.status_code == 200, sec.text
        sector_id = sec.json()["id"]
        biz = client.post(
            "/api/businesses",
            json={
                "name": "Sectored Co",
                "description": "Belongs to a sector",
                "sector_id": sector_id,
            },
        )
        assert biz.status_code == 200, biz.text
        assert biz.json()["sector_id"] == sector_id

    def test_create_business_with_dangling_sector_returns_404(self, client):
        """A non-existent ``sector_id`` on create is rejected with a structured
        404 instead of persisting a dangling FK (punch-list F3 / ADR D-047)."""
        resp = client.post(
            "/api/businesses",
            json={
                "name": "Dangling Co",
                "description": "Points at a missing sector",
                "sector_id": "sec-does-not-exist",
            },
        )
        assert resp.status_code == 404, resp.text
        detail = resp.json()["detail"]
        assert detail["error"] == "sector_not_found"
        assert detail["sector_id"] == "sec-does-not-exist"
        # The row must NOT have been created.
        rows = client.get("/api/businesses").json()
        assert all(r["name"] != "Dangling Co" for r in rows)

    def test_update_business_with_dangling_sector_returns_404(self, client):
        """The update path mirrors create: a dangling ``sector_id`` is a 404,
        and the existing row's sector is left untouched."""
        created = client.post(
            "/api/businesses",
            json={"name": "Updatable Co", "description": "x"},
        )
        assert created.status_code == 200, created.text
        biz_id = created.json()["id"]

        resp = client.put(
            f"/api/businesses/{biz_id}",
            json={
                "name": "Updatable Co",
                "description": "x",
                "sector_id": "sec-missing",
            },
        )
        assert resp.status_code == 404, resp.text
        assert resp.json()["detail"]["error"] == "sector_not_found"

    def test_update_business_persists_valid_sector(self, client):
        """A valid ``sector_id`` on update is persisted and echoed back."""
        sec = client.post(
            "/api/sectors", json={"name": "Energy", "short_name": "energy"}
        )
        sector_id = sec.json()["id"]
        created = client.post(
            "/api/businesses",
            json={"name": "Movable Co", "description": "x"},
        )
        biz_id = created.json()["id"]
        resp = client.put(
            f"/api/businesses/{biz_id}",
            json={"name": "Movable Co", "description": "x", "sector_id": sector_id},
        )
        assert resp.status_code == 200, resp.text
        assert resp.json()["sector_id"] == sector_id

    def test_update_business_without_sector_id_preserves_existing(self, client):
        """Regression: a PUT that OMITS ``sector_id`` must NOT null the stored
        sector. ``BusinessIn.sector_id`` defaults to None, so an unconditional
        ``business.sector_id = data.sector_id`` silently wiped the sector on
        every edit form that didn't send the field. The update path is
        patch-style for ``sector_id``: it only overwrites when the field is
        actually present in the request body."""
        sec = client.post(
            "/api/sectors", json={"name": "Telecom", "short_name": "telecom"}
        )
        sector_id = sec.json()["id"]
        created = client.post(
            "/api/businesses",
            json={"name": "Sticky Sector Co", "description": "x", "sector_id": sector_id},
        )
        assert created.status_code == 200, created.text
        biz_id = created.json()["id"]
        assert created.json()["sector_id"] == sector_id

        # Edit something else, OMITTING sector_id entirely.
        resp = client.put(
            f"/api/businesses/{biz_id}",
            json={"name": "Sticky Sector Co", "description": "edited description"},
        )
        assert resp.status_code == 200, resp.text
        assert resp.json()["sector_id"] == sector_id, (
            "omitting sector_id on update must preserve the existing sector"
        )

        # An explicit null still clears it (opt-in detach).
        resp = client.put(
            f"/api/businesses/{biz_id}",
            json={"name": "Sticky Sector Co", "description": "y", "sector_id": None},
        )
        assert resp.status_code == 200, resp.text
        assert resp.json()["sector_id"] is None

    def test_update_omitting_industry_alignment_preserves_it_and_industry_id(self, client, engine):
        """Regression: a PUT that OMITS ``industry_alignment`` must NOT null the
        stored alignment, and must leave the derived ``industry_id`` FK intact.
        ``industry_alignment`` defaults to ``""`` on ``BusinessIn``, so an
        unconditional ``business.industry_alignment = data.industry_alignment``
        wiped it (and cascade-nulled ``industry_id`` via ``resolve_industry_id``)
        on every edit form that dropped the field."""
        from sqlmodel import Session
        from vibe_modeling.backend.db_models import Business, Industry

        with Session(engine) as session:
            ind = Industry(name="Retail", short_name="retail", is_active=True)
            session.add(ind)
            session.commit()
            session.refresh(ind)
            industry_id = ind.id

        created = client.post("/api/businesses", json={
            "name": "Aligned Co",
            "description": "x",
            "industry_alignment": "Retail",
        })
        assert created.status_code == 200, created.text
        biz_id = created.json()["id"]
        with Session(engine) as session:
            assert session.get(Business, biz_id).industry_id == industry_id

        # Edit something else, OMITTING industry_alignment entirely.
        resp = client.put(f"/api/businesses/{biz_id}", json={
            "name": "Aligned Co",
            "description": "edited",
        })
        assert resp.status_code == 200, resp.text
        assert resp.json()["industry_alignment"] == "Retail", (
            "omitting industry_alignment must preserve the stored value"
        )
        with Session(engine) as session:
            assert session.get(Business, biz_id).industry_id == industry_id, (
                "omitting industry_alignment must preserve the derived industry_id"
            )

    def test_update_explicit_industry_alignment_recomputes_industry_id(self, client, engine):
        """An explicit new ``industry_alignment`` is applied and ``industry_id``
        is recomputed from it in lockstep."""
        from sqlmodel import Session
        from vibe_modeling.backend.db_models import Business, Industry

        with Session(engine) as session:
            ind = Industry(name="Energy", short_name="energy", is_active=True)
            session.add(ind)
            session.commit()
            session.refresh(ind)
            energy_id = ind.id

        created = client.post("/api/businesses", json={"name": "Switcher Co", "description": "x"})
        biz_id = created.json()["id"]
        with Session(engine) as session:
            assert session.get(Business, biz_id).industry_id is None

        resp = client.put(f"/api/businesses/{biz_id}", json={
            "name": "Switcher Co",
            "description": "x",
            "industry_alignment": "Energy",
        })
        assert resp.status_code == 200, resp.text
        assert resp.json()["industry_alignment"] == "Energy"
        with Session(engine) as session:
            assert session.get(Business, biz_id).industry_id == energy_id

    def test_update_explicit_blank_industry_alignment_clears_it(self, client, engine):
        """An explicit empty-string ``industry_alignment`` clears both the text
        and the derived ``industry_id`` (opt-in detach, mirroring sector_id=null)."""
        from sqlmodel import Session
        from vibe_modeling.backend.db_models import Business, Industry

        with Session(engine) as session:
            ind = Industry(name="Telco", short_name="telco", is_active=True)
            session.add(ind)
            session.commit()
            session.refresh(ind)
            telco_id = ind.id

        created = client.post("/api/businesses", json={
            "name": "Clearable Co",
            "description": "x",
            "industry_alignment": "Telco",
        })
        biz_id = created.json()["id"]
        with Session(engine) as session:
            assert session.get(Business, biz_id).industry_id == telco_id

        resp = client.put(f"/api/businesses/{biz_id}", json={
            "name": "Clearable Co",
            "description": "x",
            "industry_alignment": "",
        })
        assert resp.status_code == 200, resp.text
        assert resp.json()["industry_alignment"] == ""
        with Session(engine) as session:
            assert session.get(Business, biz_id).industry_id is None

    def test_update_omitting_business_vibes_preserves_it(self, client, engine):
        """Regression: a PUT that OMITS ``business_vibes`` must NOT wipe it.
        The runs-detail inline edit dialog never sends ``business_vibes``;
        ``BusinessIn.business_vibes`` defaults to ``""`` so an unconditional
        assignment silently cleared the detailed vibes on every such edit."""
        from sqlmodel import Session
        from vibe_modeling.backend.db_models import Business

        created = client.post("/api/businesses", json={
            "name": "Vibey Co",
            "description": "x",
            "business_vibes": "Detailed markdown vibes that must survive an edit.",
        })
        assert created.status_code == 200, created.text
        biz_id = created.json()["id"]

        resp = client.put(f"/api/businesses/{biz_id}", json={
            "name": "Vibey Co",
            "description": "edited summary",
        })
        assert resp.status_code == 200, resp.text
        with Session(engine) as session:
            assert session.get(Business, biz_id).business_vibes == (
                "Detailed markdown vibes that must survive an edit."
            ), "omitting business_vibes must preserve the stored value"

    def test_update_explicit_business_vibes_applied(self, client, engine):
        """An explicit ``business_vibes`` value is persisted."""
        from sqlmodel import Session
        from vibe_modeling.backend.db_models import Business

        created = client.post("/api/businesses", json={"name": "Editable Vibes Co", "description": "x"})
        biz_id = created.json()["id"]

        resp = client.put(f"/api/businesses/{biz_id}", json={
            "name": "Editable Vibes Co",
            "description": "x",
            "business_vibes": "Freshly authored vibes.",
        })
        assert resp.status_code == 200, resp.text
        with Session(engine) as session:
            assert session.get(Business, biz_id).business_vibes == "Freshly authored vibes."

    def test_update_unchanged_name_does_not_trip_clash_check(self, client, engine):
        """Prove the name branch is guarded by ``data.name != business.name``:
        editing ``description`` while re-sending the SAME name must NOT run the
        clash query (which would otherwise 409 against the row's own name) and
        must patch-apply the new description. ``name``/``description`` are
        required on ``BusinessIn`` so they always travel on the wire; the
        patch-style behavior that matters for them is "skip the clash check and
        leave the value untouched when it's unchanged"."""
        from sqlmodel import Session
        from vibe_modeling.backend.db_models import Business

        created = client.post("/api/businesses", json={
            "name": "Patchy Co",
            "description": "original description",
        })
        assert created.status_code == 200, created.text
        biz_id = created.json()["id"]

        # Re-send the same name, change only the description.
        resp = client.put(f"/api/businesses/{biz_id}", json={
            "name": "Patchy Co",
            "description": "edited description",
        })
        assert resp.status_code == 200, resp.text
        assert resp.json()["name"] == "Patchy Co"
        assert resp.json()["description"] == "edited description"
        with Session(engine) as session:
            biz = session.get(Business, biz_id)
            assert biz.name == "Patchy Co"
            assert biz.description == "edited description"

    def test_list_businesses_carries_sector_id_and_kind(self, client):
        """BusinessListOut exposes both ``sector_id`` and ``kind`` so the
        list view can resolve the Sector column without a second fetch
        (punch-list F1 contract)."""
        sec = client.post(
            "/api/sectors", json={"name": "Media", "short_name": "media"}
        )
        sector_id = sec.json()["id"]
        client.post(
            "/api/businesses",
            json={
                "name": "Listed Co",
                "description": "x",
                "sector_id": sector_id,
                "kind": "industry",
            },
        )
        rows = client.get("/api/businesses").json()
        row = next(r for r in rows if r["name"] == "Listed Co")
        assert row["sector_id"] == sector_id
        assert row["kind"] == "industry"

    def test_list_businesses_downloaded_scopes_reflects_versions(self, client, engine):
        """BusinessListOut.downloaded_scopes is the sorted, deduped set of
        ``version.scope`` for the business's already-loaded ``versions``
        (no extra query) - the source-explorer badge's data source."""
        from sqlmodel import Session
        from vibe_modeling.backend.db_models import Business, ModelVersion

        created = client.post(
            "/api/businesses",
            json={"name": "Scoped Co", "description": "x", "kind": "industry"},
        )
        biz_id = created.json()["id"]

        with Session(engine) as session:
            session.add(ModelVersion(business_id=biz_id, version=1, scope="ecm"))
            session.add(ModelVersion(business_id=biz_id, version=1, scope="mvm"))
            # A blank scope must never surface as a phantom "" entry.
            session.add(ModelVersion(business_id=biz_id, version=2, scope=""))
            session.commit()

        rows = client.get("/api/businesses").json()
        row = next(r for r in rows if r["id"] == biz_id)
        assert row["downloaded_scopes"] == ["ecm", "mvm"]

    def test_list_businesses_no_versions_has_empty_downloaded_scopes(self, client):
        client.post("/api/businesses", json={"name": "No Versions Co", "description": "x"})
        rows = client.get("/api/businesses").json()
        row = next(r for r in rows if r["name"] == "No Versions Co")
        assert row["downloaded_scopes"] == []

    def test_create_and_list(self, client):
        client.post(
            "/api/businesses",
            json={"name": "Business A", "description": "First business for list-after-create test"},
        )
        client.post(
            "/api/businesses",
            json={"name": "Business B", "description": "Second business for list-after-create test"},
        )
        response = client.get("/api/businesses")
        assert response.status_code == 200
        assert len(response.json()) == 2

    def test_create_rejects_empty_description(self, client):
        """v0.4.0 Task #6 — Business description is dispatched as primary
        agent context. Empty/whitespace-only descriptions produce low-signal
        models; reject at the API boundary so every Business-write surface
        (new form, edit, inline-edit, import dialog) sees the same contract.
        """
        # Empty string
        resp = client.post("/api/businesses", json={"name": "Empty Desc Co", "description": ""})
        assert resp.status_code == 422, resp.text
        # Whitespace only
        resp = client.post("/api/businesses", json={"name": "Empty Desc Co", "description": "   \n\t  "})
        assert resp.status_code == 422, resp.text
        # Missing field entirely
        resp = client.post("/api/businesses", json={"name": "Empty Desc Co"})
        assert resp.status_code == 422, resp.text

    def test_update_rejects_empty_description(self, client, seed_business):
        """PUT /businesses/{id} enforces the same non-empty description contract."""
        resp = client.put(
            f"/api/businesses/{seed_business}",
            json={"name": "Test Corp", "description": ""},
        )
        assert resp.status_code == 422, resp.text
        resp = client.put(
            f"/api/businesses/{seed_business}",
            json={"name": "Test Corp", "description": "  "},
        )
        assert resp.status_code == 422, resp.text

    def test_get_business(self, client, seed_business):
        response = client.get(f"/api/businesses/{seed_business}")
        assert response.status_code == 200
        assert response.json()["name"] == "Test Corp"
        assert response.json()["id"] == seed_business

    def test_get_nonexistent(self, client):
        response = client.get("/api/businesses/nonexistent-id")
        assert response.status_code == 404

    def test_update_business(self, client, seed_business):
        response = client.put(f"/api/businesses/{seed_business}", json={
            "name": "Updated Corp",
            "description": "New desc",
            "industry_alignment": "Healthcare",
        })
        assert response.status_code == 200
        data = response.json()
        assert data["name"] == "Updated Corp"
        assert data["description"] == "New desc"
        assert data["industry_alignment"] == "Healthcare"

    def test_update_nonexistent(self, client):
        response = client.put(
            "/api/businesses/fake",
            json={"name": "X", "description": "A real description so the request reaches the 404 path"},
        )
        assert response.status_code == 404

    def test_delete_business(self, client, seed_business):
        del_resp = client.delete(f"/api/businesses/{seed_business}")
        assert del_resp.status_code == 200
        assert del_resp.json()["ok"] is True
        # Verify deleted
        get_resp = client.get(f"/api/businesses/{seed_business}")
        assert get_resp.status_code == 404

    def test_delete_nonexistent(self, client):
        response = client.delete("/api/businesses/fake")
        assert response.status_code == 404

    def test_create_resolves_industry_id_from_short_name(self, client, engine):
        """When ``industry_alignment`` matches an Industry.short_name (case-insensitive),
        the auto-resolver populates ``Business.industry_id`` so the canonical FK
        is set. Matches the import path where the agent writes the kebab-case
        ``digital-fashion-commerce`` slug into ``model.business_information.industry_alignment``.
        """
        from sqlmodel import Session
        from vibe_modeling.backend.db_models import Business, Industry

        with Session(engine) as session:
            ind = Industry(
                name="Digital Fashion Commerce",
                short_name="digital-fashion-commerce",
                is_active=True,
            )
            session.add(ind)
            session.commit()
            session.refresh(ind)
            industry_id = ind.id

        resp = client.post("/api/businesses", json={
            "name": "Zalando Test",
            "description": "x",
            "industry_alignment": "Digital-Fashion-Commerce",  # case differs
        })
        assert resp.status_code == 200, resp.text
        biz_id = resp.json()["id"]

        with Session(engine) as session:
            biz = session.get(Business, biz_id)
            assert biz is not None
            assert biz.industry_id == industry_id

    def test_create_leaves_industry_id_null_when_unknown(self, client, engine):
        """When the alignment text matches no Industry, the business is still
        created but ``industry_id`` is None. The request must not fail."""
        from sqlmodel import Session
        from vibe_modeling.backend.db_models import Business

        resp = client.post("/api/businesses", json={
            "name": "Mystery Co",
            "description": "Business with an industry alignment not in the catalog",
            "industry_alignment": "Not An Industry",
        })
        assert resp.status_code == 200, resp.text
        biz_id = resp.json()["id"]

        with Session(engine) as session:
            biz = session.get(Business, biz_id)
            assert biz is not None
            assert biz.industry_id is None

    def test_update_resolves_industry_id_when_alignment_changes(self, client, engine, seed_business):
        """PUT /businesses re-resolves ``industry_id`` from the new alignment
        text. Mirrors create so the FK stays consistent after edits."""
        from sqlmodel import Session
        from vibe_modeling.backend.db_models import Business, Industry

        with Session(engine) as session:
            ind = Industry(name="Healthcare", short_name="healthcare", is_active=True)
            session.add(ind)
            session.commit()
            session.refresh(ind)
            industry_id = ind.id

        resp = client.put(f"/api/businesses/{seed_business}", json={
            "name": "Test Corp",
            "description": "d",
            "industry_alignment": "Healthcare",
        })
        assert resp.status_code == 200, resp.text

        with Session(engine) as session:
            biz = session.get(Business, seed_business)
            assert biz is not None
            assert biz.industry_id == industry_id

    def test_cascade_delete_with_run_operations(self, fk_client, fk_engine):
        """Cascade-deleting a business with a run + run_operation removes both.

        The ``run_operations.run_id`` FK carries ``ON DELETE CASCADE``, and
        ``runs.business_id`` cascades from the business, so the whole chain
        dies server-side. Runs under FK enforcement so the DB cascade is the
        thing actually being exercised.
        """
        from sqlmodel import Session
        from vibe_modeling.backend.db_models import Business, Run, RunOperation

        # Seed: business + a Run + one RunOperation pointing at it.
        with Session(fk_engine) as session:
            biz = Business(
                name="Test Corp", description="d", industry_alignment="Retail",
            )
            session.add(biz)
            session.commit()
            session.refresh(biz)
            biz_id = biz.id
            run = Run(
                business_id=biz_id,
                intent="new-base-model",
                status="failed",
                parameters_json="{}",
            )
            session.add(run)
            session.commit()
            session.refresh(run)
            run_op = RunOperation(
                run_id=run.id,
                step_index=0,
                operation_name="generate_ecm",
                params_json='{"scope": "ecm"}',
                status="failed",
                error_message="agent crashed",
            )
            session.add(run_op)
            session.commit()
            run_id = run.id
            run_op_id = run_op.id

        # Cascade delete the business.
        resp = fk_client.delete(f"/api/businesses/{biz_id}?cascade=true")
        assert resp.status_code == 200, resp.text
        assert resp.json()["ok"] is True

        # Verify the run + run_operation are both gone.
        with Session(fk_engine) as session:
            assert session.get(Run, run_id) is None
            assert session.get(RunOperation, run_op_id) is None


# --- Context CRUD ---


class TestContextCRUD:
    def test_create_context(self, client, seed_business):
        response = client.post(f"/api/businesses/{seed_business}/contexts", json={
            "version_label": "v1.0",
            "context_json": '{"business": "test"}',
            "conventions_json": '{"pk_suffix": "_id"}',
        })
        assert response.status_code == 200
        data = response.json()
        assert data["version_label"] == "v1.0"
        assert data["business_id"] == seed_business
        assert data["is_active"] is True

    def test_create_context_nonexistent_business(self, client):
        response = client.post("/api/businesses/fake/contexts", json={
            "version_label": "v1",
        })
        assert response.status_code == 404

    def test_list_contexts(self, client, seed_business):
        client.post(f"/api/businesses/{seed_business}/contexts", json={"version_label": "v1"})
        client.post(f"/api/businesses/{seed_business}/contexts", json={"version_label": "v2"})
        response = client.get(f"/api/businesses/{seed_business}/contexts")
        assert response.status_code == 200
        assert len(response.json()) == 2

    def test_contexts_isolated_per_business(self, client):
        resp1 = client.post(
            "/api/businesses",
            json={"name": "Biz A", "description": "First business for context-isolation test"},
        )
        resp2 = client.post(
            "/api/businesses",
            json={"name": "Biz B", "description": "Second business for context-isolation test"},
        )
        bid1 = resp1.json()["id"]
        bid2 = resp2.json()["id"]
        client.post(f"/api/businesses/{bid1}/contexts", json={"version_label": "v1"})
        client.post(f"/api/businesses/{bid2}/contexts", json={"version_label": "v1"})
        # create_business auto-seeds one context (version_label="seed") so
        # the Explorer page isn't empty on a fresh business. Plus the one we
        # just created explicitly = 2. Second business has its own seed + one
        # explicit = 2 too. Isolation holds: each business's contexts belong
        # to it alone.
        biz_a_contexts = client.get(f"/api/businesses/{bid1}/contexts").json()
        biz_b_contexts = client.get(f"/api/businesses/{bid2}/contexts").json()
        assert len(biz_a_contexts) == 2
        assert len(biz_b_contexts) == 2
        assert all(c["business_id"] == bid1 for c in biz_a_contexts)
        assert all(c["business_id"] == bid2 for c in biz_b_contexts)


# --- Versions ---


class TestVersions:
    def test_list_versions_empty(self, client, seed_business):
        response = client.get(f"/api/businesses/{seed_business}/versions")
        assert response.status_code == 200
        assert response.json() == []

    def test_list_versions_includes_superseded(self, client, engine, seed_business):
        """``listVersions`` must not 500 when a row carries
        ``status='superseded'``.

        ``vibe_iterate`` marks the parent ModelVersion as superseded when
        producing a derived version (services/operations/vibe_iterate.py:609).
        Before the fix, ``ModelStatus`` only enumerated draft/generating/
        completed/failed and the response Pydantic model rejected the row,
        breaking the FE Base Version dropdown for any business that had
        ever been vibed.
        """
        from sqlmodel import Session
        from vibe_modeling.backend.db_models import ModelVersion

        with Session(engine) as session:
            # Mix of statuses so we exercise the response coercion across
            # ALL enum entries, not just the new one in isolation.
            for v_int, status in (
                (1, "superseded"),
                (2, "completed"),
                (3, "draft"),
            ):
                session.add(
                    ModelVersion(
                        business_id=seed_business,
                        version=v_int,
                        status=status,
                        deployment_status="draft",
                        scope="ecm",
                        uc_catalog="test_catalog",
                    )
                )
            session.commit()

        response = client.get(f"/api/businesses/{seed_business}/versions")
        # Pre-fix: this returned 500 (Pydantic ResponseValidationError).
        assert response.status_code == 200, response.text
        data = response.json()
        statuses = sorted(row["status"] for row in data)
        assert statuses == ["completed", "draft", "superseded"]


# --- Run CRUD ---


class TestRunCRUD:
    def test_create_run_no_agent_config(self, client, seed_business):
        """With no agent configured, run creation answers the pre-flight's
        level-1 structured 422 ``config_missing``."""
        response = client.post(f"/api/businesses/{seed_business}/runs", json={
            "intent": "new-base-model",
            "catalog": "test_catalog",
            "business_context_path": "/Volumes/test/ctx/vibes/ctx.json",
        })
        assert response.status_code == 422, response.text
        detail = response.json()["detail"]
        assert detail["error"] == "config_missing"
        assert "agent_job" in {m["key"] for m in detail["missing"]}

    def test_create_run_with_agent(self, client_with_agent, mock_ws, seed_business):
        """With AgentConfig seeded, run triggers and becomes running."""
        from unittest.mock import MagicMock
        mock_run = MagicMock()
        mock_run.run_id = 12345
        mock_ws.jobs.run_now.return_value = mock_run

        response = client_with_agent.post(f"/api/businesses/{seed_business}/runs", json={
            "intent": "new-base-model",
            "catalog": "test_catalog",
            "business_context_path": "/Volumes/test/ctx/vibes/ctx.json",
        })
        assert response.status_code == 200
        data = response.json()
        assert data["business_id"] == seed_business
        assert data["status"] == "running"
        assert data["intent"] == "new-base-model"
        assert data["databricks_run_id"] == 12345

    def test_create_run_nonexistent_business(self, client, seed_agent_config):
        response = client.post(f"/api/businesses/{"fake"}/runs", json={
            "intent": "new-base-model",
        })
        assert response.status_code == 404

    def test_create_run_blocked_when_notebook_inaccessible(
        self, client_with_agent, mock_ws, seed_business
    ):
        """Run creation refuses if the SP can no longer access the notebook.

        Covers the failure mode where the notebook gets moved/re-permissioned
        after save — without this guard the job runs and fails with a cryptic
        Databricks error, leaving the app run stuck. Validate reports the same
        refusal as a blocker (the pre-flight's level 1).
        """
        mock_ws.workspace.get_status.side_effect = NotFound("RESOURCE_DOES_NOT_EXIST")
        body = {
            "intent": "new-base-model",
            "catalog": "test_catalog",
            "business_context_path": "/Volumes/test/ctx.json",
        }
        validated = client_with_agent.post(f"/api/businesses/{seed_business}/runs/validate", json=body)
        assert validated.status_code == 200, validated.text
        first = validated.json()["blockers"][0]
        assert first["field_path"] == "(agent_config.notebook_path)"
        response = client_with_agent.post(f"/api/businesses/{seed_business}/runs", json=body)
        assert response.status_code == 400
        assert response.json()["detail"] == first["message"]
        assert "cannot access" in response.json()["detail"].lower()
        mock_ws.jobs.run_now.assert_not_called()

    def test_get_run(self, client, seed_run):
        bid, run_id = seed_run
        response = client.get(f"/api/businesses/{bid}/runs/{run_id}")
        assert response.status_code == 200
        assert response.json()["id"] == run_id

    def test_get_nonexistent_run(self, client, seed_business):
        bid = seed_business
        response = client.get(f"/api/businesses/{bid}/runs/fake")
        assert response.status_code == 404

    def test_list_runs(self, client_with_agent, mock_ws, seed_business):
        """List runs for a business. Need agent config since create_run requires it."""
        bid = seed_business
        from unittest.mock import MagicMock
        mock_run = MagicMock()
        mock_run.run_id = 100
        mock_ws.jobs.run_now.return_value = mock_run

        # Create first run
        client_with_agent.post(f"/api/businesses/{seed_business}/runs", json={
            "intent": "new-base-model",
            "catalog": "test_catalog",
            "business_context_path": "/Volumes/test/ctx/vibes/ctx.json",
        })

        # Complete first run so we can create second (per-business lock)
        runs = client_with_agent.get(f"/api/businesses/{seed_business}/runs").json()
        run_id = runs[0]["id"]
        # Cancel to release the lock
        client_with_agent.post(f"/api/businesses/{bid}/runs/{run_id}/cancel")

        # Create second run. Use ``new-base-model`` again so the test
        # doesn't have to bootstrap a completed ModelVersion just to satisfy
        # the version-bound gate on ``install`` (post-uninstall-diagnosis
        # 2026-05-18). The test only cares that two runs end up listable.
        mock_run.run_id = 200
        client_with_agent.post(f"/api/businesses/{seed_business}/runs", json={
            "intent": "new-base-model",
            "catalog": "test_cat",
            "business_context_path": "/Volumes/test/ctx/vibes/ctx.json",
        })

        response = client_with_agent.get(f"/api/businesses/{seed_business}/runs")
        assert response.status_code == 200
        assert len(response.json()) == 2

    def test_runs_isolated_per_business(self, client_with_agent, mock_ws):
        from unittest.mock import MagicMock
        mock_run = MagicMock()
        mock_run.run_id = 100
        mock_ws.jobs.run_now.return_value = mock_run

        resp1 = client_with_agent.post(
            "/api/businesses",
            json={"name": "Biz A", "description": "First business for run-isolation test"},
        )
        resp2 = client_with_agent.post(
            "/api/businesses",
            json={"name": "Biz B", "description": "Second business for run-isolation test"},
        )
        bid1 = resp1.json()["id"]
        bid2 = resp2.json()["id"]
        client_with_agent.post(f"/api/businesses/{bid1}/runs", json={"catalog": "test_catalog", "business_context_path": "/Volumes/test/ctx/vibes/ctx.json"})
        mock_run.run_id = 200
        client_with_agent.post(f"/api/businesses/{bid2}/runs", json={"catalog": "test_catalog", "business_context_path": "/Volumes/test/ctx/vibes/ctx.json"})
        assert len(client_with_agent.get(f"/api/businesses/{bid1}/runs").json()) == 1
        assert len(client_with_agent.get(f"/api/businesses/{bid2}/runs").json()) == 1

    def test_per_business_lock_409(self, client_with_agent, mock_ws, seed_business):
        """Creating a second run on the same business while one is active returns 409."""
        from unittest.mock import MagicMock
        mock_run = MagicMock()
        mock_run.run_id = 100
        mock_ws.jobs.run_now.return_value = mock_run

        # First run
        resp1 = client_with_agent.post(f"/api/businesses/{seed_business}/runs", json={
            "catalog": "test_catalog",
            "business_context_path": "/Volumes/test/ctx/vibes/ctx.json",
        })
        assert resp1.status_code == 200
        assert resp1.json()["status"] == "running"

        # Second run on same business should get 409
        resp2 = client_with_agent.post(f"/api/businesses/{seed_business}/runs", json={
            "catalog": "test_catalog",
            "business_context_path": "/Volumes/test/ctx/vibes/ctx.json",
        })
        assert resp2.status_code == 409
        assert "active run" in resp2.json()["detail"]

    def test_run_params_widget_format(self, client_with_agent, mock_ws, seed_business_with_version):
        """Parameters snapshot for an orchestrator-routed vibe-iterate run.

        ``vibe-iterate`` is version-bound; with a resolvable completed
        ModelVersion (seeded by ``seed_business_with_version``), the
        request flows through ``_create_run_via_orchestrator`` and
        ``parameters_json`` is the user-submitted ``RunIn`` snapshot per
        spec §5.1 — NOT the legacy widget map. Pre-uninstall-diagnosis
        (2026-05-18) this test exercised the broken legacy path that
        silently dropped ``model_version`` and shipped a doomed run.
        """
        from unittest.mock import MagicMock
        mock_run = MagicMock()
        mock_run.run_id = 100
        mock_ws.jobs.run_now.return_value = mock_run
        seed_business = seed_business_with_version

        response = client_with_agent.post(f"/api/businesses/{seed_business}/runs", json={
            "intent": "vibe-iterate",
            "catalog": "my_catalog",
            "vibe_instructions": "Add HR tables",
            "model_size": "large model",
            "generate_samples": True,
            "business_context_path": "/Volumes/test/ctx/vibes/ctx.json",
        })
        assert response.status_code == 200, response.text
        data = response.json()
        params = json.loads(data["parameters_json"])
        # Orchestrator snapshot uses the user-submitted form keys.
        assert params["intent"] == "vibe-iterate"
        assert params["catalog"] == "my_catalog"
        assert params["vibe_instructions"] == "Add HR tables"
        assert params["model_size"] == "large model"
        # Accepted but never sent to the agent, so not part of the audit.
        assert "generate_samples" not in params


    def test_vibe_iterate_compiles_input_ids_into_instructions(
        self, client_with_agent, mock_ws, seed_business_with_version, engine
    ):
        """A vibe-iterate run sends empty vibe_instructions + input_ids; the
        server compiles the selected inputs into the instruction doc so the run
        dispatches instead of failing the empty-instructions validator."""
        from unittest.mock import MagicMock
        from sqlmodel import Session, select
        from vibe_modeling.backend.db_models import (
            ModelVersion,
            VibeInput,
            VibeInputContextLink,
        )

        mock_run = MagicMock()
        mock_run.run_id = 101
        mock_ws.jobs.run_now.return_value = mock_run
        bid = seed_business_with_version
        with Session(engine) as s:
            vid = s.exec(
                select(ModelVersion.id).where(ModelVersion.business_id == bid)
            ).first()
            vi = VibeInput(
                business_id=bid, origin="user", text="Use snake_case naming",
                priority="medium", selected_for_run=True,
            )
            s.add(vi)
            s.commit()
            iid = vi.id
            s.add(VibeInputContextLink(input_id=iid, version_id=vid, is_origin=True))
            s.commit()

        resp = client_with_agent.post(f"/api/businesses/{bid}/runs", json={
            "intent": "vibe-iterate",
            "catalog": "my_catalog",
            "version_id": vid,
            "vibe_instructions": "",
            "model_size": "small model",
            "input_ids": [iid],
        })
        assert resp.status_code == 200, resp.text
        params = json.loads(resp.json()["parameters_json"])
        assert params["vibe_instructions"].strip() != "", "compiled instructions must be non-empty"
        assert "snake_case" in params["vibe_instructions"]


class TestRunBusinessScoping:
    """Run endpoints nest under ``/api/businesses/{business_id}/runs/...``.

    The router uses ``get_run_in_business`` to enforce that the run id in
    the URL belongs to the bid in the URL — a probe for a run owned by
    business B1 against business B2's path must 404, not 200, so the API
    does not leak run existence across tenants. Both reads and mutating
    routes share the helper so the guard fires identically on both.
    """

    def _seed_two_businesses_with_run_under_b1(self, engine):
        from sqlmodel import Session as _Session
        from vibe_modeling.backend.db_models import Business, Run

        with _Session(engine) as session:
            b1 = Business(
                name="Biz One", description="d", industry_alignment="Retail"
            )
            b2 = Business(
                name="Biz Two", description="d", industry_alignment="Retail"
            )
            session.add(b1)
            session.add(b2)
            session.commit()
            session.refresh(b1)
            session.refresh(b2)
            # The run is owned by b1; we then probe through b2's path.
            run = Run(
                business_id=b1.id,
                intent="new-base-model",
                status="running",
                databricks_run_id=99999,
                vibe_session_id="cross-tenant-probe",
                parameters_json='{"operation": "new base model"}',
            )
            session.add(run)
            session.commit()
            session.refresh(run)
            return b1.id, b2.id, run.id

    def test_get_run_via_wrong_business_returns_404(self, client, engine):
        """GET via the wrong business URL must 404 (not 200, not 403).

        Same response as if the run id did not exist at all — the
        existence of cross-tenant runs must not leak."""
        b1, b2, run_id = self._seed_two_businesses_with_run_under_b1(engine)

        # Sanity: the correct path returns 200.
        ok = client.get(f"/api/businesses/{b1}/runs/{run_id}")
        assert ok.status_code == 200, (
            f"baseline: same-business GET must succeed; got {ok.status_code}"
        )

        # Cross-tenant probe: must 404.
        cross = client.get(f"/api/businesses/{b2}/runs/{run_id}")
        assert cross.status_code == 404, (
            f"cross-business GET must 404 (not 200/403); "
            f"got {cross.status_code}: {cross.text}"
        )
        assert "Run not found" in cross.text

    def test_cancel_run_via_wrong_business_returns_404(self, client, engine):
        """The guard fires on writes too — cancelling a B1 run via B2's
        path must 404 before the cancel side-effect fires. Otherwise a
        B2-scoped caller could disrupt a B1 run by guessing run ids."""
        b1, b2, run_id = self._seed_two_businesses_with_run_under_b1(engine)

        cross = client.post(
            f"/api/businesses/{b2}/runs/{run_id}/cancel"
        )
        assert cross.status_code == 404, (
            f"cross-business cancel must 404; "
            f"got {cross.status_code}: {cross.text}"
        )
        assert "Run not found" in cross.text


# --- User Preferences ---


class TestUserPreferences:
    def test_get_preferences_empty(self, client):
        response = client.get("/api/user/preferences")
        assert response.status_code == 200
        assert response.json() == []

    def test_set_and_get_preference(self, client):
        response = client.put(
            "/api/user/preferences/last_business_id",
            json={"value": "biz-123"},
        )
        assert response.status_code == 200
        data = response.json()
        assert data["key"] == "last_business_id"
        assert data["value"] == "biz-123"
        assert "updated_at" in data

        response = client.get("/api/user/preferences")
        assert response.status_code == 200
        prefs = response.json()
        assert len(prefs) == 1
        assert prefs[0]["key"] == "last_business_id"
        assert prefs[0]["value"] == "biz-123"

    def test_upsert_preference(self, client):
        client.put("/api/user/preferences/theme", json={"value": "dark"})
        client.put("/api/user/preferences/theme", json={"value": "light"})
        response = client.get("/api/user/preferences")
        prefs = response.json()
        assert len(prefs) == 1
        assert prefs[0]["value"] == "light"

    def test_preferences_scoped_to_user(self, client):
        """Without user headers (outside the Apps runtime), preferences are
        stored under the fixed 'local-dev' identity."""
        client.put("/api/user/preferences/key1", json={"value": "val1"})
        # With a user header, should get empty preferences (different user)
        response = client.get(
            "/api/user/preferences",
            headers={"X-Forwarded-Preferred-Username": "alice@example.com"},
        )
        assert response.status_code == 200
        assert response.json() == []

    def test_preferences_scoped_to_user_by_email(self, client):
        """The email header is the identity: a different email is a different
        bucket, and the same email sees its own rows."""
        alice = {"X-Forwarded-Email": "alice@example.com"}
        bob = {"X-Forwarded-Email": "bob@example.com"}
        client.put("/api/user/preferences/key1", json={"value": "val1"}, headers=alice)
        assert client.get("/api/user/preferences", headers=bob).json() == []
        assert client.get("/api/user/preferences").json() == []
        prefs = client.get("/api/user/preferences", headers=alice).json()
        assert [(p["key"], p["value"]) for p in prefs] == [("key1", "val1")]


# --- Artifacts ---


class TestArtifacts:
    def test_list_artifacts_empty(self, client, seed_run):
        bid, run_id = seed_run
        response = client.get(f"/api/businesses/{bid}/runs/{run_id}/artifacts")
        assert response.status_code == 200
        assert response.json() == []


# --- Agent Config Endpoints ---


class TestAgentConfigEndpoints:
    def test_get_agent_config_lazy_seeds_row(self, client):
        """GET /config/agent now lazily creates the singleton row from env vars
        on first read instead of returning 404. The seeded row has empty
        notebook_path / no job_id, so callers that need a fully-configured
        agent (e.g. /runs) still trip the agent-not-configured gate."""
        response = client.get("/api/config/agent")
        assert response.status_code == 200
        data = response.json()
        assert data["notebook_path"] == ""
        assert data["job_id"] is None
        # Bootstrap copied the AppConfig values into the new row.
        assert data["deployment_catalog"] == "test_deployment_catalog"
        assert data["warehouse_id"] == "test-warehouse-id"

    def test_get_deployment_catalog_returns_env_seed_on_first_read(self, client):
        """GET /config/deployment-catalog returns the env-seeded value the
        first time it's hit, rather than `is_configured: false`."""
        response = client.get("/api/config/deployment-catalog")
        assert response.status_code == 200
        data = response.json()
        assert data["deployment_catalog"] == "test_deployment_catalog"
        assert data["is_configured"] is True

    def test_get_warehouse_returns_env_seed_on_first_read(self, client):
        """GET /config/warehouse mirrors the deployment-catalog behaviour."""
        response = client.get("/api/config/warehouse")
        assert response.status_code == 200
        data = response.json()
        assert data["warehouse_id"] == "test-warehouse-id"
        assert data["is_configured"] is True

    def test_set_deployment_catalog_overrides_env_seed(self, client):
        """A PUT to /config/deployment-catalog updates the bootstrapped row;
        subsequent GETs return the user-saved value, not the env seed."""
        response = client.put(
            "/api/config/deployment-catalog",
            json={"deployment_catalog": "user_chosen_catalog"},
        )
        assert response.status_code == 200
        assert response.json()["deployment_catalog"] == "user_chosen_catalog"
        # Re-read confirms persistence + that the env seed is NOT consulted again.
        get_resp = client.get("/api/config/deployment-catalog")
        assert get_resp.json()["deployment_catalog"] == "user_chosen_catalog"

    def test_agent_config_exposes_metamodel_catalog_mirror(self, client):
        """AgentConfigOut mirrors deployment_catalog into metamodel_catalog
        (concern-A rename); both keys carry the same value."""
        data = client.get("/api/config/agent").json()
        assert data["deployment_catalog"] == "test_deployment_catalog"
        assert data["metamodel_catalog"] == "test_deployment_catalog"

    def test_get_metamodel_catalog_returns_env_seed(self, client):
        """GET /config/metamodel-catalog returns the env-seeded value under the
        concern-A key, delegating to the legacy deployment-catalog reader."""
        response = client.get("/api/config/metamodel-catalog")
        assert response.status_code == 200
        data = response.json()
        assert data["metamodel_catalog"] == "test_deployment_catalog"
        assert data["is_configured"] is True

    def test_set_metamodel_catalog_round_trips_and_aliases(self, client):
        """PUT /config/metamodel-catalog persists to the same column the legacy
        deployment-catalog endpoint reads (single source of truth)."""
        response = client.put(
            "/api/config/metamodel-catalog",
            json={"metamodel_catalog": "mm_chosen"},
        )
        assert response.status_code == 200
        assert response.json()["metamodel_catalog"] == "mm_chosen"
        # New reader and legacy reader agree - same underlying column.
        assert (
            client.get("/api/config/metamodel-catalog").json()["metamodel_catalog"]
            == "mm_chosen"
        )
        assert (
            client.get("/api/config/deployment-catalog").json()["deployment_catalog"]
            == "mm_chosen"
        )
        assert client.get("/api/config/agent").json()["metamodel_catalog"] == "mm_chosen"

    @pytest.mark.parametrize("path,key", [
        ("/api/config/metamodel-catalog", "metamodel_catalog"),
        ("/api/config/deployment-catalog", "deployment_catalog"),
    ])
    @pytest.mark.parametrize("name", ["my-catalog", "My_Catalog", "1cat", "c", "x" * 256])
    def test_set_metamodel_catalog_refuses_a_name_the_agent_cant_take(self, client, path, key, name):
        """The server applies the Settings form's rule (``CATALOG_NAME_PATTERN``):
        400 ``setting_refused`` and the stored catalog is unchanged."""
        before = client.get("/api/config/metamodel-catalog").json()["metamodel_catalog"]
        response = client.put(path, json={key: name})
        assert response.status_code == 400, response.text
        detail = response.json()["detail"]
        assert detail["error"] == "setting_refused" and detail["key"] == "metamodel_catalog"
        assert "letters, digits and underscores" in detail["message"]
        assert client.get("/api/config/metamodel-catalog").json()["metamodel_catalog"] == before

    def test_set_metamodel_catalog_can_clear_it(self, client):
        response = client.put("/api/config/metamodel-catalog", json={"metamodel_catalog": ""})
        assert response.status_code == 200
        assert response.json()["is_configured"] is False

    def test_legacy_deployment_catalog_still_answers(self, client):
        """Old endpoint keeps answering (delegate kept one release); a PUT there
        is visible through the new metamodel-catalog reader too."""
        client.put(
            "/api/config/deployment-catalog",
            json={"deployment_catalog": "legacy_write"},
        )
        assert (
            client.get("/api/config/metamodel-catalog").json()["metamodel_catalog"]
            == "legacy_write"
        )

    def test_bootstrap_runs_at_most_once(self, client, engine):
        """Hitting the endpoint twice produces a single AgentConfig row, not two."""
        from sqlmodel import Session, select
        from vibe_modeling.backend.db_models import AgentConfig

        client.get("/api/config/agent")
        client.get("/api/config/deployment-catalog")
        client.get("/api/config/warehouse")
        with Session(engine) as session:
            rows = session.exec(select(AgentConfig)).all()
        assert len(rows) == 1, (
            f"Expected exactly one AgentConfig row after multiple reads, got {len(rows)}"
        )

    def test_get_agent_config_exists(self, client_with_agent):
        response = client_with_agent.get("/api/config/agent")
        assert response.status_code == 200
        data = response.json()
        assert data["notebook_path"] == "/Workspace/test/notebook"
        assert data["job_id"] == 99

    def test_set_agent_config(self, client, mock_ws):
        """PUT /config/agent creates a job and stores the config."""
        from unittest.mock import MagicMock
        mock_job = MagicMock()
        mock_job.job_id = 42
        mock_ws.jobs.create.return_value = mock_job

        response = client.put("/api/config/agent", json={
            "notebook_path": "/Workspace/my/notebook",
        })
        assert response.status_code == 200
        data = response.json()
        assert data["notebook_path"] == "/Workspace/my/notebook"
        assert data["job_id"] == 42
        # Default lands at the minimum.
        assert data["max_concurrent_runs"] == 3

    def test_set_agent_config_persists_collect_vibe_run_statistics(self, client, mock_ws):
        """The run-tags setting ("Annotate jobs with run tags") round-trips, starts
        on for a fresh row, and a PUT that leaves the field out keeps the stored
        value (a PUT may send the notebook path alone)."""
        from unittest.mock import MagicMock
        mock_job = MagicMock()
        mock_job.job_id = 42
        mock_ws.jobs.create.return_value = mock_job
        base = {"notebook_path": "/Workspace/my/notebook", "max_concurrent_runs": 3}

        def put(**extra):
            response = client.put("/api/config/agent", json={**base, **extra})
            assert response.status_code == 200
            return response.json()["collect_vibe_run_statistics"]

        response = client.get("/api/config/agent")
        assert response.status_code == 200
        assert response.json()["collect_vibe_run_statistics"] is True

        assert put() is True
        assert put(collect_vibe_run_statistics=False) is False
        assert put() is False
        response = client.get("/api/config/agent")
        assert response.status_code == 200
        assert response.json()["collect_vibe_run_statistics"] is False
        assert put(collect_vibe_run_statistics=None) is False
        assert put(collect_vibe_run_statistics=True) is True

    def test_set_agent_config_max_concurrent_runs_below_min_rejected(self, client, mock_ws):
        """Sub-3 values for max_concurrent_runs return 422 with a clear
        minimum-is-3 message — the documented benign overlaps (unified-
        pipeline phase transition, cancel-with-rollback cleanup) require
        slack above the D-012 single-run gate."""
        from unittest.mock import MagicMock
        mock_job = MagicMock()
        mock_job.job_id = 42
        mock_ws.jobs.create.return_value = mock_job

        response = client.put("/api/config/agent", json={
            "notebook_path": "/Workspace/my/notebook",
            "max_concurrent_runs": 2,
        })
        assert response.status_code == 422
        detail_blob = str(response.json())
        # Pydantic surfaces the ge constraint via msg/loc/type; assert both
        # the field is the failure site and the floor is 3.
        assert "max_concurrent_runs" in detail_blob
        assert "3" in detail_blob
        # No job should have been provisioned on validation failure.
        mock_ws.jobs.create.assert_not_called()

    def test_set_agent_config_max_concurrent_runs_at_min_accepted(self, client, mock_ws):
        """3 is the floor and must succeed."""
        from unittest.mock import MagicMock
        mock_job = MagicMock()
        mock_job.job_id = 42
        mock_ws.jobs.create.return_value = mock_job

        response = client.put("/api/config/agent", json={
            "notebook_path": "/Workspace/my/notebook",
            "max_concurrent_runs": 3,
        })
        assert response.status_code == 200
        assert response.json()["max_concurrent_runs"] == 3

    def test_set_agent_config_max_concurrent_runs_above_min_accepted(self, client, mock_ws):
        """Above-floor values pass through and persist."""
        from unittest.mock import MagicMock
        mock_job = MagicMock()
        mock_job.job_id = 42
        mock_ws.jobs.create.return_value = mock_job

        response = client.put("/api/config/agent", json={
            "notebook_path": "/Workspace/my/notebook",
            "max_concurrent_runs": 10,
        })
        assert response.status_code == 200
        assert response.json()["max_concurrent_runs"] == 10
        # Re-read confirms persistence on the GET.
        get_resp = client.get("/api/config/agent")
        assert get_resp.json()["max_concurrent_runs"] == 10

    def test_set_agent_config_propagates_max_concurrent_to_jobs_create(self, client, mock_ws):
        """First-save (no existing job_id) -> ws.jobs.create is called with
        max_concurrent_runs=<configured value>. Locks the job_launcher's
        create() path against future drift where the literal 3 might
        sneak back in."""
        from unittest.mock import MagicMock
        mock_job = MagicMock()
        mock_job.job_id = 42
        mock_ws.jobs.create.return_value = mock_job

        response = client.put("/api/config/agent", json={
            "notebook_path": "/Workspace/my/notebook",
            "max_concurrent_runs": 7,
        })
        assert response.status_code == 200
        mock_ws.jobs.create.assert_called_once()
        kwargs = mock_ws.jobs.create.call_args.kwargs
        assert kwargs.get("max_concurrent_runs") == 7

    def test_set_agent_config_propagates_max_concurrent_to_jobs_reset(self, client_with_agent, mock_ws):
        """When an AgentConfig row already has a job_id, a settings save
        re-resets the existing job (no create()) with the new
        max_concurrent_runs — so an operator changing the value sees the
        cap update inside the same PUT request, not on the next
        deploy/restart."""
        # client_with_agent seeds an AgentConfig with job_id=99. The save
        # re-reads the job afterwards; like the Jobs API, return what was reset.
        mock_ws.jobs.get.side_effect = lambda job_id: SimpleNamespace(
            settings=mock_ws.jobs.reset.call_args.kwargs["new_settings"]
        )
        response = client_with_agent.put("/api/config/agent", json={
            "notebook_path": "/Workspace/test/notebook",
            "max_concurrent_runs": 5,
        })
        assert response.status_code == 200
        mock_ws.jobs.reset.assert_called_once()
        kwargs = mock_ws.jobs.reset.call_args.kwargs
        new_settings = kwargs.get("new_settings")
        assert new_settings is not None
        # JobSettings stores the value as an attribute on the SDK type.
        assert getattr(new_settings, "max_concurrent_runs", None) == 5
        # And no fallback to create() since the existing job_id was valid.
        mock_ws.jobs.create.assert_not_called()

    def test_set_agent_config_preflight_fails(self, client, mock_ws):
        """PUT /config/agent returns 400 when the SP can't reach the notebook."""
        mock_ws.workspace.get_status.side_effect = NotFound("RESOURCE_DOES_NOT_EXIST")
        response = client.put("/api/config/agent", json={
            "notebook_path": "/Workspace/Users/someone/private/notebook",
        })
        assert response.status_code == 400
        assert "cannot access" in response.json()["detail"]
        # Ensure we did NOT create a job when the preflight failed.
        mock_ws.jobs.create.assert_not_called()

    def test_check_agent_notebook_ok(self, client, mock_ws):
        """GET check-notebook returns ok=true when the path is reachable.

        When the notebook has no embedded marker AND the pinned tag is in
        the known-no-marker set (currently empty — v0.7.1 stamps a
        marker), the response carries a `message`. Otherwise it returns
        a `warning` field. Callers must tolerate either shape.
        """
        mock_ws.workspace.get_status.return_value = object()
        # No export content configured → version detection returns None.
        # The pin (v0.7.1) stamps a marker in its notebook, so on this
        # mock-with-no-content path we land in the `warning` branch.
        mock_ws.workspace.export.return_value.content = None
        response = client.get("/api/config/agent/check-notebook?path=/Workspace/ok")
        assert response.status_code == 200
        body = response.json()
        assert body["ok"] is True

    def test_check_agent_notebook_not_found(self, client, mock_ws):
        """GET check-notebook returns ok=false with a reason."""
        mock_ws.workspace.get_status.side_effect = NotFound("RESOURCE_DOES_NOT_EXIST")
        response = client.get("/api/config/agent/check-notebook?path=/nope")
        assert response.status_code == 200
        body = response.json()
        assert body["ok"] is False
        assert "RESOURCE_DOES_NOT_EXIST" in body["reason"]

    def test_check_agent_notebook_version_match(self, client, mock_ws):
        """Notebook whose `__RELEASE_VERSION__` matches the pinned release → ok.
        The gate compares the notebook's release version against
        SUPPORTED_AGENT_VERSION; the agent marker (`__AGENT_VERSION__`) is
        reported for display only."""
        import base64
        from vibe_modeling.backend.core._defaults import (
            SUPPORTED_AGENT_MARKER,
            SUPPORTED_AGENT_VERSION,
        )
        rel = SUPPORTED_AGENT_VERSION.lstrip("v")
        src = (
            f"__AGENT_VERSION__ = '{SUPPORTED_AGENT_MARKER}'\n"
            f"__RELEASE_VERSION__ = '{rel}'\n"
        ).encode()
        mock_ws.workspace.get_status.return_value = object()
        mock_ws.workspace.export.return_value.content = base64.b64encode(src).decode()
        response = client.get("/api/config/agent/check-notebook?path=/Workspace/nb")
        assert response.status_code == 200
        body = response.json()
        assert body["ok"] is True
        assert body["version"] == SUPPORTED_AGENT_VERSION
        assert body["marker"].lstrip("v") == SUPPORTED_AGENT_MARKER.lstrip("v")

    def test_check_agent_notebook_version_mismatch(self, client, mock_ws):
        """Notebook declares a marker that doesn't match → ok=false."""
        import base64
        src = b"__AGENT_VERSION__ = '4.0.0'\n"
        mock_ws.workspace.get_status.return_value = object()
        mock_ws.workspace.export.return_value.content = base64.b64encode(src).decode()
        response = client.get("/api/config/agent/check-notebook?path=/Workspace/nb")
        assert response.status_code == 200
        body = response.json()
        assert body["ok"] is False
        assert "4.0.0" in body["reason"]

    def test_check_agent_notebook_release_gate_pass_drift_and_mismatch(
        self, client, mock_ws
    ):
        """Compatibility gates on the release version, not the agent marker.

        A notebook on the pinned release (0.8.0) passes; a patch bump of the
        agent marker within the same release still passes (the marker is a
        per-fix build counter); a different release fails."""
        import base64

        mock_ws.workspace.get_status.return_value = object()

        src_ok = b"__AGENT_VERSION__ = '4.9.9'\n__RELEASE_VERSION__ = '0.8.0'\n"
        mock_ws.workspace.export.return_value.content = base64.b64encode(src_ok).decode()
        ok = client.get("/api/config/agent/check-notebook?path=/Workspace/nb").json()
        assert ok["ok"] is True
        assert ok["version"] == "v0.8.0"
        assert ok["marker"] == "v4.9.9"

        src_drift = b"__AGENT_VERSION__ = '4.9.10'\n__RELEASE_VERSION__ = '0.8.0'\n"
        mock_ws.workspace.export.return_value.content = base64.b64encode(src_drift).decode()
        drift = client.get("/api/config/agent/check-notebook?path=/Workspace/nb").json()
        assert drift["ok"] is True
        assert drift["marker"] == "v4.9.10"

        src_bad = b"__AGENT_VERSION__ = '4.9.9'\n__RELEASE_VERSION__ = '0.7.7'\n"
        mock_ws.workspace.export.return_value.content = base64.b64encode(src_bad).decode()
        bad = client.get("/api/config/agent/check-notebook?path=/Workspace/nb").json()
        assert bad["ok"] is False
        assert "0.7.7" in bad["reason"]

    def test_check_agent_notebook_no_marker(self, client, mock_ws):
        """Notebook has no __version__ marker.

        Two response shapes are possible depending on the pinned tag:
        - If the pin is in `_NO_MARKER_TAGS` (currently empty — v0.7.1
          stamps a marker), the route returns ok=true with `version` +
          `message="Reachable; assuming v0.7.1 (no embedded marker)"`.
        - Otherwise the route returns ok=true with a `warning` field.
          With the current pin (v0.7.1) this is the path taken.
        """
        import base64
        from vibe_modeling.backend.core._defaults import SUPPORTED_AGENT_VERSION
        from vibe_modeling.backend.routes.config import _NO_MARKER_TAGS
        src = b"# just a plain notebook, no version\n"
        mock_ws.workspace.get_status.return_value = object()
        mock_ws.workspace.export.return_value.content = base64.b64encode(src).decode()
        response = client.get("/api/config/agent/check-notebook?path=/Workspace/nb")
        assert response.status_code == 200
        body = response.json()
        assert body["ok"] is True
        if SUPPORTED_AGENT_VERSION in _NO_MARKER_TAGS:
            assert body.get("version") == SUPPORTED_AGENT_VERSION
            assert "message" in body
            assert "no embedded marker" in body["message"]
            assert "warning" not in body
        else:
            assert "warning" in body

    def test_set_agent_config_version_mismatch(self, client, mock_ws):
        """PUT rejects when the notebook's __version__ disagrees with the pin."""
        import base64
        src = b"__version__ = 'v0.4.9'\n"
        mock_ws.workspace.get_status.return_value = object()
        mock_ws.workspace.export.return_value.content = base64.b64encode(src).decode()
        response = client.put("/api/config/agent", json={
            "notebook_path": "/Workspace/wrong-version",
        })
        assert response.status_code == 400
        assert "release mismatch" in response.json()["detail"].lower()
        mock_ws.jobs.create.assert_not_called()

    def test_agent_ready_no_config(self, client):
        """No AgentConfig at all → not ready."""
        response = client.get("/api/config/agent/ready")
        assert response.status_code == 200
        body = response.json()
        assert body["ready"] is False
        assert "configured" in body["reason"].lower()

    def test_agent_ready_accessible(self, client_with_agent, mock_ws):
        """Agent configured and notebook reachable → ready."""
        mock_ws.workspace.get_status.return_value = object()
        response = client_with_agent.get("/api/config/agent/ready")
        body = response.json()
        assert body["ready"] is True

    def test_agent_ready_notebook_inaccessible(self, client_with_agent, mock_ws):
        """Agent configured but notebook no longer visible → not ready."""
        mock_ws.workspace.get_status.side_effect = NotFound("RESOURCE_DOES_NOT_EXIST")
        response = client_with_agent.get("/api/config/agent/ready")
        body = response.json()
        assert body["ready"] is False
        assert "can no longer access" in body["reason"]


# --- Progress Events ---


class TestProgressEvents:
    def test_get_progress_empty(self, client, seed_run):
        bid, run_id = seed_run
        response = client.get(f"/api/businesses/{bid}/runs/{run_id}/progress")
        assert response.status_code == 200
        assert response.json() == []

    def test_get_progress_chronological_order_when_step_id_reused(
        self, client, seed_run, engine
    ):
        """Replays the Zalando 2026-05-10 architect-review pattern: a parent
        step's terminal events fire AFTER per-iteration progress events but
        share the parent's smaller step_id (because the agent reuses
        step_id within a logical step). The API must return events in
        wall-clock order, NOT step_id order, so the run-detail UI renders
        them coherently.
        """
        from datetime import datetime, timedelta, timezone
        from sqlmodel import Session
        from vibe_modeling.backend.db_models import RunProgressEvent

        bid, run_id = seed_run
        parent_step = 1778438483801
        iter1_step = 1778438548343
        iter2_step = 1778438659076
        t0 = datetime(2026, 5, 10, 18, 41, 30, tzinfo=timezone.utc)
        with Session(engine) as s:
            s.add_all(
                [
                    RunProgressEvent(
                        run_id=run_id, step_id=parent_step, event_seq=37,
                        stage_name="Architect Review",
                        step_name="Principal Data Architect Review",
                        status="running", message="Starting holistic review",
                        progress_increment=0.0, result_json=None,
                        created_at=t0,
                    ),
                    RunProgressEvent(
                        run_id=run_id, step_id=iter1_step, event_seq=38,
                        stage_name="Architect Review",
                        step_name="Principal Architect — Iteration 1/3",
                        status="running", message="Iter 1/3 in progress",
                        progress_increment=0.3, result_json=None,
                        created_at=t0 + timedelta(minutes=1, seconds=2),
                    ),
                    RunProgressEvent(
                        run_id=run_id, step_id=iter2_step, event_seq=39,
                        stage_name="Architect Review",
                        step_name="Principal Architect — Iteration 2/3",
                        status="running", message="Iter 2/3 in progress",
                        progress_increment=0.3, result_json=None,
                        created_at=t0 + timedelta(minutes=2, seconds=52),
                    ),
                    RunProgressEvent(
                        run_id=run_id, step_id=parent_step, event_seq=40,
                        stage_name="Architect Review",
                        step_name="Principal Data Architect Review",
                        status="warning",
                        message="No valid output produced — skipping changes",
                        progress_increment=2.0, result_json=None,
                        created_at=t0 + timedelta(minutes=7, seconds=9),
                    ),
                    RunProgressEvent(
                        run_id=run_id, step_id=parent_step, event_seq=41,
                        stage_name="Architect Review",
                        step_name="Principal Data Architect Review",
                        status="completed",
                        message="Architect review complete: 10 changes",
                        progress_increment=2.0, result_json=None,
                        created_at=t0 + timedelta(minutes=7, seconds=9, microseconds=300),
                    ),
                ]
            )
            s.commit()

        response = client.get(f"/api/businesses/{bid}/runs/{run_id}/progress")
        assert response.status_code == 200
        events = response.json()
        statuses = [(e["step_name"], e["status"]) for e in events]
        assert statuses == [
            ("Principal Data Architect Review", "running"),
            ("Principal Architect — Iteration 1/3", "running"),
            ("Principal Architect — Iteration 2/3", "running"),
            ("Principal Data Architect Review", "warning"),
            ("Principal Data Architect Review", "completed"),
        ]


# --- Runs-for-version / Lineage ---


class TestRunsForVersion:
    def _seed_version(self, engine, business_id: str, *, version: int = 1, base_id=None):
        from sqlmodel import Session
        from vibe_modeling.backend.db_models import ModelVersion

        with Session(engine) as session:
            mv = ModelVersion(
                business_id=business_id,
                version=version,
                status="completed",
                deployment_status="deployed",
                base_version_id=base_id,
                uc_catalog="test_cat",
                scope="mvm",
            )
            session.add(mv)
            session.commit()
            session.refresh(mv)
            return mv.id

    _RUN_TYPE_TO_INTENT = {
        "new base model": "new-base-model",
        "vibe modeling of version": "vibe-iterate",
        "vibe iterate": "vibe-iterate",
        "install model": "install",
        "uninstall model version": "uninstall",
        "generate sample data": "generate-samples",
        "import from volume": "import-from-volume",
        "snapshot version": "snapshot",
        "shrink": "shrink",
        "enlarge": "enlarge",
        "revert model version": "revert",
    }

    def _seed_run(
        self, engine, *, business_id, version_id=None, run_type=None, intent=None,
    ):
        from sqlmodel import Session
        from vibe_modeling.backend.db_models import Run

        if intent is None:
            intent = self._RUN_TYPE_TO_INTENT.get(run_type or "install model", "install")

        with Session(engine) as session:
            r = Run(
                business_id=business_id,
                version_id=version_id,
                intent=intent,
                status="completed",
                parameters_json="{}",
            )
            session.add(r)
            session.commit()
            session.refresh(r)
            return r.id

    def test_list_runs_for_version_empty(self, client, engine, seed_business):
        vid = self._seed_version(engine, seed_business, version=1)
        resp = client.get(f"/api/model-versions/{vid}/runs")
        assert resp.status_code == 200
        assert resp.json() == []

    def test_list_runs_for_version_includes_operates_on(self, client, engine, seed_business):
        vid = self._seed_version(engine, seed_business, version=1)
        run_id = self._seed_run(engine, business_id=seed_business, version_id=vid, run_type="install model")
        resp = client.get(f"/api/model-versions/{vid}/runs")
        assert resp.status_code == 200
        body = resp.json()
        assert len(body) == 1
        assert body[0]["id"] == run_id
        assert body[0]["intent"] == "install"

    def test_list_runs_for_version_excludes_descendant_runs(self, client, engine, seed_business):
        """A run whose version_id points at a descendant version must NOT appear
        under the parent's runs query.

        This is the new contract: only directly-involved runs (Run.version_id ==
        version_id, or runs that produced this version via RunOperation) are
        listed. Descendants surface on their own pages.
        """
        base_id = self._seed_version(engine, seed_business, version=1)
        child_id = self._seed_version(engine, seed_business, version=2, base_id=base_id)
        run_id = self._seed_run(
            engine,
            business_id=seed_business,
            version_id=child_id,
            run_type="vibe modeling of version",
        )
        resp = client.get(f"/api/model-versions/{base_id}/runs")
        assert resp.status_code == 200
        run_ids = [r["id"] for r in resp.json()]
        assert run_id not in run_ids

    def test_list_runs_for_version_excludes_vibe_iterate_against_parent(self, client, engine, seed_business):
        """Regression for #53: a vibe-iterate run with version_id = parent_mvm
        must NOT appear under parent_ecm's runs query.

        Prior behavior fanned out via base_version_id, so v=1 ECM's "Runs for
        this version" included vibe-iterate runs that took v=1 MVM as parent.
        """
        # parent_ecm v=1, with parent_mvm v=1 as its child (base_version_id pointer)
        parent_ecm_id = self._seed_version(engine, seed_business, version=1)
        parent_mvm_id = self._seed_version(engine, seed_business, version=2, base_id=parent_ecm_id)

        # a vibe-iterate run that took parent_mvm as the version it operates on
        vibe_iterate_run_id = self._seed_run(
            engine,
            business_id=seed_business,
            version_id=parent_mvm_id,
            run_type="vibe iterate",
        )

        resp = client.get(f"/api/model-versions/{parent_ecm_id}/runs")
        assert resp.status_code == 200
        run_ids = [r["id"] for r in resp.json()]
        assert vibe_iterate_run_id not in run_ids, (
            "vibe-iterate run on child version leaked into parent's runs list"
        )

    def test_list_runs_for_version_includes_run_that_produced_it(self, client, engine, seed_business):
        """A run that produced this version (via RunOperation.output_version_id)
        is listed even if Run.version_id doesn't point at it directly."""
        from sqlmodel import Session
        from vibe_modeling.backend.db_models import RunOperation

        parent_id = self._seed_version(engine, seed_business, version=1)
        produced_id = self._seed_version(engine, seed_business, version=2, base_id=parent_id)

        # Run.version_id = parent (dispatch-time value); RunOperation.output_version_id = produced
        run_id = self._seed_run(
            engine,
            business_id=seed_business,
            version_id=parent_id,
            run_type="vibe modeling of version",
        )
        with Session(engine) as session:
            op = RunOperation(
                run_id=run_id,
                step_index=0,
                operation_name="vibe_iterate",
                parent_version_id=parent_id,
                output_version_id=produced_id,
                status="succeeded",
            )
            session.add(op)
            session.commit()

        resp = client.get(f"/api/model-versions/{produced_id}/runs")
        assert resp.status_code == 200
        run_ids = [r["id"] for r in resp.json()]
        assert run_id in run_ids

    def test_list_runs_for_version_not_found(self, client):
        resp = client.get("/api/model-versions/missing-id/runs")
        assert resp.status_code == 404


class TestRunLineage:
    def _mv(self, engine, business_id, *, version, base_id=None):
        from sqlmodel import Session
        from vibe_modeling.backend.db_models import ModelVersion

        with Session(engine) as session:
            mv = ModelVersion(
                business_id=business_id,
                version=version,
                status="completed",
                deployment_status="deployed",
                base_version_id=base_id,
                uc_catalog="test_cat",
                scope="mvm",
            )
            session.add(mv)
            session.commit()
            session.refresh(mv)
            return mv.id

    _RUN_TYPE_TO_INTENT = {
        "new base model": "new-base-model",
        "vibe modeling of version": "vibe-iterate",
        "vibe iterate": "vibe-iterate",
        "install model": "install",
        "uninstall model version": "uninstall",
        "generate sample data": "generate-samples",
        "import from volume": "import-from-volume",
        "snapshot version": "snapshot",
        "shrink": "shrink",
        "enlarge": "enlarge",
        "revert model version": "revert",
    }

    def _run(self, engine, *, business_id, version_id, run_type, status="completed"):
        from sqlmodel import Session
        from vibe_modeling.backend.db_models import Run

        intent_value = self._RUN_TYPE_TO_INTENT.get(run_type, run_type)
        with Session(engine) as session:
            r = Run(
                business_id=business_id,
                version_id=version_id,
                intent=intent_value,
                status=status,
                parameters_json="{}",
            )
            session.add(r)
            session.commit()
            session.refresh(r)
            return r.id

    def test_lineage_install_run_operates_on(self, client, engine, seed_business):
        bid = seed_business
        vid = self._mv(engine, seed_business, version=1)
        run_id = self._run(engine, business_id=seed_business, version_id=vid, run_type="install model")
        resp = client.get(f"/api/businesses/{bid}/runs/{run_id}/lineage")
        assert resp.status_code == 200
        body = resp.json()
        assert body["intent"] == "install"
        assert body["operates_on_version"]["id"] == vid
        assert body["source_version"] is None
        assert body["generated_version"] is None

    def test_lineage_uninstall_operates_on(self, client, engine, seed_business):
        bid = seed_business
        vid = self._mv(engine, seed_business, version=1)
        run_id = self._run(
            engine, business_id=seed_business, version_id=vid, run_type="uninstall model version"
        )
        body = client.get(f"/api/businesses/{bid}/runs/{run_id}/lineage").json()
        assert body["operates_on_version"]["id"] == vid
        assert body["source_version"] is None

    def test_lineage_samples_operates_on(self, client, engine, seed_business):
        bid = seed_business
        vid = self._mv(engine, seed_business, version=1)
        run_id = self._run(
            engine, business_id=seed_business, version_id=vid, run_type="generate sample data"
        )
        body = client.get(f"/api/businesses/{bid}/runs/{run_id}/lineage").json()
        assert body["operates_on_version"]["id"] == vid

    def test_lineage_vibe_run_with_completed_child(self, client, engine, seed_business):
        """After a vibe run completes, Run.version_id points at the OUTPUT child.
        Lineage returns source = base, generated = child."""
        bid = seed_business
        base_id = self._mv(engine, seed_business, version=1)
        child_id = self._mv(engine, seed_business, version=2, base_id=base_id)
        run_id = self._run(
            engine,
            business_id=seed_business,
            version_id=child_id,
            run_type="vibe modeling of version",
        )
        body = client.get(f"/api/businesses/{bid}/runs/{run_id}/lineage").json()
        assert body["source_version"]["id"] == base_id
        assert body["generated_version"]["id"] == child_id

    def test_lineage_vibe_run_before_completion(self, client, engine, seed_business):
        """Before completion, Run.version_id still points at the BASE (no child
        exists yet). Lineage returns source = base, generated = None."""
        bid = seed_business
        base_id = self._mv(engine, seed_business, version=1)
        run_id = self._run(
            engine,
            business_id=seed_business,
            version_id=base_id,
            run_type="vibe modeling of version",
        )
        body = client.get(f"/api/businesses/{bid}/runs/{run_id}/lineage").json()
        assert body["source_version"]["id"] == base_id
        assert body["generated_version"] is None

    def test_lineage_running_vibe_run_against_v_n_treats_version_id_as_source(
        self, client, engine, seed_business
    ):
        """REGRESSION: when a vibe-iterate run is still in flight AND the
        picked base itself has a base_version_id (e.g. picking v=1 MVM
        which was produced by shrink from v=1 ECM), the lineage endpoint
        used to mis-render the base AS the OUTPUT and walk back further
        to its grandparent for the source. Captured 2026-04-27 from run
        2b6a192e-ce31-42cb-a60a-8805142154f1: form picked v=1 MVM, run
        was still ``running``, and lineage returned
        ``source=v1 ECM, generated=v1 MVM`` — both wrong; the actual
        truth is ``source=v1 MVM, generated=Pending``.
        """
        bid = seed_business
        from sqlmodel import Session
        from vibe_modeling.backend.db_models import ModelVersion, Run

        # Two model_versions that together model the natural state after a
        # successful new-base-model: v=1 ECM + v=1 MVM (with MVM pointing
        # back at ECM via base_version_id).
        with Session(engine) as session:
            ecm = ModelVersion(
                business_id=seed_business, version=1, scope="ecm",
                status="completed", deployment_status="uninstalled",
                uc_catalog="test_cat",
            )
            session.add(ecm)
            session.commit()
            session.refresh(ecm)
            ecm_id = ecm.id
            mvm = ModelVersion(
                business_id=seed_business, version=1, scope="mvm",
                status="completed", deployment_status="deployed",
                base_version_id=ecm_id, uc_catalog="test_cat",
            )
            session.add(mvm)
            session.commit()
            session.refresh(mvm)
            mvm_id = mvm.id

        # In-flight vibe-iterate run picking v=1 MVM as the base.
        with Session(engine) as session:
            r = Run(
                business_id=seed_business,
                version_id=mvm_id,
                intent="vibe-iterate",
                status="running",  # not completed
                parameters_json="{}",
            )
            session.add(r)
            session.commit()
            session.refresh(r)
            run_id = r.id

        body = client.get(f"/api/businesses/{bid}/runs/{run_id}/lineage").json()
        assert body["source_version"]["id"] == mvm_id, (
            "Source must be the picked base (v=1 MVM); pre-fix this returned v=1 ECM"
        )
        assert body["generated_version"] is None, (
            "Generated must be None until the run completes; pre-fix this returned v=1 MVM"
        )

    def test_lineage_new_base_model_generated(self, client, engine, seed_business):
        bid = seed_business
        vid = self._mv(engine, seed_business, version=1)
        run_id = self._run(
            engine, business_id=seed_business, version_id=vid, run_type="new base model"
        )
        body = client.get(f"/api/businesses/{bid}/runs/{run_id}/lineage").json()
        assert body["generated_version"]["id"] == vid
        assert body["source_version"] is None

    def test_lineage_run_not_found(self, client, seed_business):
        bid = seed_business
        resp = client.get(f"/api/businesses/{bid}/runs/missing-id/lineage")
        assert resp.status_code == 404


# --- Database Schema ---


class TestDatabaseSchema:
    def test_all_tables_created(self, engine):
        from sqlalchemy import inspect as sa_inspect
        insp = sa_inspect(engine)
        tables = insp.get_table_names()
        expected = [
            "businesses", "business_contexts", "agent_config",
            "model_versions", "runs", "run_artifacts", "run_progress_events",
            "domains", "products", "attributes", "foreign_key_links",
        ]
        for table in expected:
            assert table in tables, f"Table '{table}' not created"

    def test_foreign_key_constraints(self, engine):
        from sqlalchemy import inspect as sa_inspect
        insp = sa_inspect(engine)
        assert "businesses" in {fk["referred_table"] for fk in insp.get_foreign_keys("business_contexts")}
        assert "businesses" in {fk["referred_table"] for fk in insp.get_foreign_keys("runs")}
        assert "runs" in {fk["referred_table"] for fk in insp.get_foreign_keys("run_artifacts")}

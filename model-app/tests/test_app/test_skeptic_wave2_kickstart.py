"""INDEPENDENT skeptical tester sweep for Wave-2 kickstart work (PR #284).

Distrustful, adversarial coverage of three targets:

* ``artifact_indexer.infer_artifact_type`` .txt folder rules (story 5) —
  ordering (path rule before ext fallback), case-insensitivity, top-level
  bare .txt, unknown folder, .md-still-wins.
* ``industry_kickstart.kickstart_from_industry`` + endpoint (story 8) —
  validation status codes, ECM+MVM multi-scope copy, deep structural
  equality (not just counts), artifact copy + story-5 typing, audit Run,
  and the *name-collision* contract the prompt asserts (409).
* The ``snapshot_version._walk_volume_dir`` → public ``walk_volume_dir``
  convergence: a populated version dir must actually index files (the
  migration's whole point — a wrong stub reading ``entry.path`` would
  index 0).

This file edits NO production source. It complements (does not replace)
the dev-authored suites.
"""

from __future__ import annotations

import json
from unittest.mock import MagicMock

import pytest
from sqlmodel import Session, select

from vibe_modeling.backend.db_models import (
    AgentConfig,
    Attribute,
    Business,
    Domain,
    ForeignKeyLink,
    ModelVersion,
    Product,
    Run,
    RunArtifact,
)
from vibe_modeling.backend.model_export import export_model_json
from vibe_modeling.backend.model_sync import ModelSyncService
from vibe_modeling.backend.services.artifact_indexer import (
    infer_artifact_type,
    walk_volume_dir,
)
from vibe_modeling.backend.services.industry_kickstart import (
    KickstartError,
    kickstart_from_industry,
)


# ==========================================================================
# Target (a): infer_artifact_type — story-5 .txt folder rules, adversarial
# ==========================================================================

_ROOT = "/Volumes/cat/_metamodel/vol_root/business/acme/ecm_v1"


@pytest.mark.parametrize(
    "sub, expected",
    [
        # vibes/*.txt -> vibes_text  (NOT plain "text")
        ("vibes/next_vibes.txt", "vibes_text"),
        ("vibes/deep/nested.txt", "vibes_text"),
        # ontology/*.txt -> ontology_text
        ("ontology/o.txt", "ontology_text"),
        # docs/*.txt -> text (deliberate: docs keeps generic text)
        ("docs/d.txt", "text"),
        # bare top-level .txt -> text (extension fallback)
        ("loose.txt", "text"),
        # unknown folder .txt -> text fallback (folder rule doesn't apply)
        ("randomdir/x.txt", "text"),
        ("a/b/c/deep.txt", "text"),
    ],
)
def test_txt_folder_rules(sub, expected):
    assert infer_artifact_type(f"{_ROOT}/{sub}", root=_ROOT) == expected


def test_md_still_wins_over_txt_in_vibes():
    """.md in vibes/ must remain vibes_doc, unaffected by the .txt rules."""
    assert infer_artifact_type(f"{_ROOT}/vibes/note.md", root=_ROOT) == "vibes_doc"


def test_ordering_path_rule_beats_ext_fallback():
    """A vibes/.txt must NOT collapse to the .txt->'text' extension entry.

    Ordering bug guard: the path-specific folder rule for vibes/*.txt is
    evaluated BEFORE the _EXT_TO_TYPE fallback. If the order were reversed
    this would return 'text'.
    """
    assert infer_artifact_type(f"{_ROOT}/vibes/x.txt", root=_ROOT) == "vibes_text"
    # And the generic fallback still applies where no folder rule matches.
    assert infer_artifact_type(f"{_ROOT}/x.txt", root=_ROOT) == "text"


def test_case_insensitivity_of_txt_rules():
    """Folder + extension matching is lower-cased; mixed case still types."""
    assert infer_artifact_type(f"{_ROOT}/VIBES/Next_Vibes.TXT", root=_ROOT) == "vibes_text"
    assert infer_artifact_type(f"{_ROOT}/Ontology/O.Txt", root=_ROOT) == "ontology_text"
    assert infer_artifact_type(f"{_ROOT}/MODEL.JSON", root=_ROOT) == "model_json"


def test_txt_rules_without_root():
    """Bare sub-paths (no root) type identically — root-strip is optional."""
    assert infer_artifact_type("vibes/x.txt") == "vibes_text"
    assert infer_artifact_type("ontology/x.txt") == "ontology_text"
    assert infer_artifact_type("docs/x.txt") == "text"
    assert infer_artifact_type("x.txt") == "text"
    assert infer_artifact_type("unknown/x.txt") == "text"


def test_root_prefix_not_a_substring_false_match():
    """A path that merely *contains* the folder name mid-segment must not
    be mis-typed. 'archive_vibes/x.txt' is not 'vibes/'."""
    # With root stripping, the sub starts at 'archive_vibes/...'; the rule
    # requires the sub to START with 'vibes/'.
    p = "/Volumes/cat/_metamodel/vol_root/business/acme/ecm_v1/archive_vibes/x.txt"
    assert infer_artifact_type(p, root=_ROOT) == "text"


# ==========================================================================
# Target (b): kickstart — validation, multi-scope, deep equality, collision
# ==========================================================================

SAMPLE_ECM = {
    "type": "business",
    "name": "Retail Industry",
    "version": "v1_ecm",
    "description": "A retail industry template.",
    "domains": [
        {
            "name": "sales",
            "division": "Commercial",
            "description": "Sales domain.",
            "products": [
                {
                    "product": "order",
                    "description": "Customer orders.",
                    "type": "fact",
                    "primary_key": "order_id",
                    "attributes": [
                        {"attribute": "order_id", "type": "bigint"},
                        {
                            "attribute": "customer_id",
                            "type": "bigint",
                            "foreign_key_to": "customer.profile.customer_id",
                        },
                    ],
                },
            ],
        },
        {
            "name": "customer",
            "division": "Commercial",
            "description": "Customer domain.",
            "products": [
                {
                    "product": "profile",
                    "description": "Customer profiles.",
                    "type": "dimension",
                    "primary_key": "customer_id",
                    "attributes": [
                        {"attribute": "customer_id", "type": "bigint"},
                    ],
                },
            ],
        },
    ],
}

SAMPLE_MVM = {
    "type": "business",
    "name": "Retail Industry",
    "version": "v1_mvm",
    "description": "Minimal viable model.",
    "domains": [
        {
            "name": "core",
            "division": "Commercial",
            "description": "Core domain.",
            "products": [
                {
                    "product": "txn",
                    "description": "Transactions.",
                    "type": "fact",
                    "primary_key": "txn_id",
                    "attributes": [
                        {"attribute": "txn_id", "type": "bigint"},
                        {"attribute": "amount", "type": "double"},
                    ],
                },
            ],
        },
    ],
}


def _seed_industry_ecm_mvm(engine) -> tuple[str, str, str]:
    """Seed kind='industry' with BOTH a v1 ECM and a v1 MVM version.

    Returns (industry_id, ecm_version_id, mvm_version_id).
    """
    with Session(engine) as session:
        industry = Business(
            name="Retail Industry MultiScope",
            industry_alignment="Retail",
            description="multi-scope template",
            kind="industry",
        )
        session.add(industry)
        session.flush()

        ecm = ModelVersion(
            business_id=industry.id, version=1, scope="ecm",
            status="completed", uc_catalog="test_cat",
        )
        mvm = ModelVersion(
            business_id=industry.id, version=1, scope="mvm",
            status="completed", uc_catalog="test_cat",
        )
        session.add(ecm)
        session.add(mvm)
        session.flush()
        ModelSyncService(session).sync_from_model_json(ecm.id, SAMPLE_ECM)
        ModelSyncService(session).sync_from_model_json(mvm.id, SAMPLE_MVM)
        session.commit()
        return industry.id, ecm.id, mvm.id


def _seed_single_ecm(engine, name="Retail Single") -> tuple[str, str]:
    with Session(engine) as session:
        industry = Business(
            name=name, industry_alignment="Retail",
            description="single", kind="industry",
        )
        session.add(industry)
        session.flush()
        mv = ModelVersion(
            business_id=industry.id, version=1, scope="ecm",
            status="completed", uc_catalog="test_cat",
        )
        session.add(mv)
        session.flush()
        ModelSyncService(session).sync_from_model_json(mv.id, SAMPLE_ECM)
        session.commit()
        return industry.id, mv.id


def _deep_model(session: Session, version_id: str) -> dict:
    """Normalised, comparable structural projection of a version's model.

    Strips ids / version labels / model name so two versions can be deep
    compared on *structure* alone (domain/product/attr/FK shape + fields).
    """
    model = export_model_json(session, version_id)["model"]
    domains = []
    for d in sorted(model["domains"], key=lambda x: x["name"]):
        products = []
        for p in sorted(d.get("products", []), key=lambda x: x.get("product", x.get("name", ""))):
            attrs = []
            for a in sorted(p.get("attributes", []), key=lambda x: x.get("attribute", x.get("name", ""))):
                attrs.append({
                    "name": a.get("attribute", a.get("name")),
                    "type": a.get("type"),
                    "primary_key": a.get("primary_key", False),
                    "foreign_key_to": a.get("foreign_key_to"),
                })
            products.append({
                "name": p.get("product", p.get("name")),
                "type": p.get("type"),
                "primary_key": p.get("primary_key"),
                "description": p.get("description"),
                "attributes": attrs,
            })
        domains.append({
            "name": d["name"],
            "division": d.get("division"),
            "description": d.get("description"),
            "products": products,
        })
    return {"domains": domains}


def _counts(session: Session, version_id: str) -> dict[str, int]:
    domains = session.exec(
        select(Domain).where(Domain.version_id == version_id)
    ).all()
    domain_ids = [d.id for d in domains]
    products = session.exec(
        select(Product).where(Product.domain_id.in_(domain_ids or [""]))
    ).all()
    product_ids = [p.id for p in products]
    attrs = session.exec(
        select(Attribute).where(Attribute.product_id.in_(product_ids or [""]))
    ).all()
    fks = session.exec(
        select(ForeignKeyLink).where(ForeignKeyLink.version_id == version_id)
    ).all()
    return {
        "domains": len(domains),
        "products": len(products),
        "attributes": len(attrs),
        "fks": len(fks),
    }


def _ws_flat(rel_files: list[str]) -> MagicMock:
    """ws whose Volume dir lists ``rel_files`` flat (no recursion)."""
    ws = MagicMock()
    entries = []
    for rel in rel_files:
        e = MagicMock()
        e.name = rel
        e.is_directory = False
        e.file_size = None
        entries.append(e)
    ws.files.list_directory_contents.return_value = entries

    def _download(path):
        body = MagicMock()
        # The kickstart reads the industry model.json for its schema prefix
        # (``scope_prefix.import_schema_prefix``); every other file is opaque bytes.
        body.contents.read.return_value = (
            json.dumps({"model": {"model_conventions": {"schema_prefix": ""}, "domains": []}}).encode()
            if path.endswith("/model.json") else b"<bytes>"
        )
        return body

    ws.files.download.side_effect = _download
    ws.files.upload = MagicMock()
    return ws


# --- Deep structural fidelity (not just counts) ---------------------------


def test_kickstart_deep_field_equality(engine):
    industry_id, src_ecm_id = _seed_single_ecm(engine, name="DeepCheck Retail")
    ws = _ws_flat([])

    with Session(engine) as s:
        nb = kickstart_from_industry(
            s, ws, source_industry_id=industry_id,
            source_version=1, new_name="DeepCheck Co",
        )
        s.commit()
        nb_id = nb.id

    with Session(engine) as s:
        new_mv = s.exec(
            select(ModelVersion).where(ModelVersion.business_id == nb_id)
        ).first()
        src_deep = _deep_model(s, src_ecm_id)
        new_deep = _deep_model(s, new_mv.id)
        # Full deep equality: domain/product/attr names, types, PK, FK target,
        # descriptions all preserved through export->sync round-trip.
        assert new_deep == src_deep
        # Sanity: the FK actually survived with its target string.
        fk_targets = [
            a["foreign_key_to"]
            for d in new_deep["domains"]
            for p in d["products"]
            for a in p["attributes"]
            if a["foreign_key_to"]
        ]
        assert "customer.profile.customer_id" in fk_targets


# --- ECM + MVM multi-scope kickstart --------------------------------------


def test_kickstart_copies_both_ecm_and_mvm_scopes(engine):
    industry_id, ecm_id, mvm_id = _seed_industry_ecm_mvm(engine)
    ws = _ws_flat([])

    with Session(engine) as s:
        nb = kickstart_from_industry(
            s, ws, source_industry_id=industry_id,
            source_version=1, new_name="MultiScope Co",
        )
        s.commit()
        nb_id = nb.id

    with Session(engine) as s:
        new_versions = s.exec(
            select(ModelVersion).where(ModelVersion.business_id == nb_id)
        ).all()
        scopes = {v.scope for v in new_versions}
        assert scopes == {"ecm", "mvm"}, (
            f"both source scopes must be kickstarted, got {scopes}"
        )

        by_scope = {v.scope: v for v in new_versions}
        # ECM structure matches source ECM; MVM matches source MVM.
        assert _counts(s, by_scope["ecm"].id) == _counts(s, ecm_id)
        assert _counts(s, by_scope["mvm"].id) == _counts(s, mvm_id)
        assert _deep_model(s, by_scope["ecm"].id) == _deep_model(s, ecm_id)
        assert _deep_model(s, by_scope["mvm"].id) == _deep_model(s, mvm_id)
        # Cross-check: ECM and MVM are genuinely different shapes.
        assert _deep_model(s, by_scope["ecm"].id) != _deep_model(s, by_scope["mvm"].id)


# --- Artifact copy + story-5 typing on the kickstarted bundle -------------


def test_kickstart_artifacts_typed_with_story5_rules(engine):
    industry_id, _ = _seed_single_ecm(engine, name="ArtType Retail")
    # Artifacts land under the deployment catalog resolved from AgentConfig
    # (the source's per-model uc_catalog is not the metamodel catalog).
    with Session(engine) as s:
        s.add(AgentConfig(deployment_catalog="deploy_cat"))
        s.commit()
    ws = _ws_flat([
        "model.json",
        "vibes/next_vibes.txt",
        "ontology/o.txt",
        "docs/d.txt",
        "loose.txt",
    ])

    with Session(engine) as s:
        nb = kickstart_from_industry(
            s, ws, source_industry_id=industry_id,
            source_version=1, new_name="ArtType Co",
        )
        s.commit()
        nb_id = nb.id

    assert ws.files.upload.call_count == 5

    with Session(engine) as s:
        new_mv = s.exec(
            select(ModelVersion).where(ModelVersion.business_id == nb_id)
        ).first()
        arts = s.exec(
            select(RunArtifact).where(RunArtifact.model_version_id == new_mv.id)
        ).all()
        by_path_type = {a.file_path.rsplit("/", 1)[-1]: a.artifact_type for a in arts}
        types = {a.artifact_type for a in arts}
        assert "model_json" in types
        assert "vibes_text" in types
        assert "ontology_text" in types
        # docs/.txt and bare .txt both type as generic 'text'
        assert by_path_type.get("d.txt") == "text"
        assert by_path_type.get("loose.txt") == "text"
        # All indexer rows for an import carry run_id=None.
        assert all(a.run_id is None for a in arts)


# --- Audit Run committed after structural commit --------------------------


def test_kickstart_audit_run_points_at_new_version(engine):
    industry_id, _, _ = _seed_industry_ecm_mvm(engine)
    ws = _ws_flat([])
    with Session(engine) as s:
        nb = kickstart_from_industry(
            s, ws, source_industry_id=industry_id,
            source_version=1, new_name="Audit Co",
        )
        s.commit()
        nb_id = nb.id

    with Session(engine) as s:
        runs = s.exec(select(Run).where(Run.business_id == nb_id)).all()
        assert len(runs) == 1
        run = runs[0]
        assert run.intent == "kickstart-from-industry"
        assert run.status == "completed"
        # version_id must point at one of the new business's versions.
        new_vids = {
            v.id for v in s.exec(
                select(ModelVersion).where(ModelVersion.business_id == nb_id)
            ).all()
        }
        assert run.version_id in new_vids


# --- Validation: status codes the prompt asserts --------------------------


def test_service_rejects_non_industry(engine, seed_business):
    ws = _ws_flat([])
    with Session(engine) as s:
        with pytest.raises(KickstartError) as exc:
            kickstart_from_industry(
                s, ws, source_industry_id=seed_business,
                source_version=1, new_name="Nope",
            )
    assert "industry" in str(exc.value).lower()


def test_service_rejects_missing_version(engine):
    industry_id, _ = _seed_single_ecm(engine, name="MissingVer Retail")
    ws = _ws_flat([])
    with Session(engine) as s:
        with pytest.raises(KickstartError) as exc:
            kickstart_from_industry(
                s, ws, source_industry_id=industry_id,
                source_version=99, new_name="Nope",
            )
    assert "version" in str(exc.value).lower()


def test_endpoint_non_industry_source_400(client, engine, seed_business):
    resp = client.post(
        f"/api/industry-models/{seed_business}/kickstart",
        json={"source_version": 1, "new_name": "X"},
    )
    assert resp.status_code == 400
    assert "industry" in resp.json()["detail"].lower()


def test_endpoint_missing_source_400_not_404(client, engine):
    """A missing ``source_version`` on a valid industry maps to 404 (the
    addressed source/version is absent), NOT 400. 400 is reserved for
    malformed requests (non-industry source, whole_model=false)."""
    industry_id, _ = _seed_single_ecm(engine, name="EndpointMissingVer")
    resp = client.post(
        f"/api/industry-models/{industry_id}/kickstart",
        json={"source_version": 99, "new_name": "X"},
    )
    assert resp.status_code == 404
    assert "version" in resp.json()["detail"].lower()


def test_endpoint_bad_source_id_404(client):
    """An unknown source business id is a missing source -> 404."""
    resp = client.post(
        "/api/industry-models/no-such-id/kickstart",
        json={"source_version": 1, "new_name": "X"},
    )
    assert resp.status_code == 404
    assert "not found" in resp.json()["detail"].lower()


def test_endpoint_whole_model_false_400(client, engine):
    industry_id, _ = _seed_single_ecm(engine, name="WholeModelFalse")
    resp = client.post(
        f"/api/industry-models/{industry_id}/kickstart",
        json={"source_version": 1, "new_name": "X", "whole_model": False},
    )
    assert resp.status_code == 400
    assert "whole-model" in resp.json()["detail"].lower()


def test_endpoint_name_collision_contract(client, engine):
    """A ``new_name`` that collides with an existing business yields a clean
    409 (NOT an unhandled DB IntegrityError / 500).

    ``Business.name`` is UNIQUE at the DB layer. The service pre-checks the
    name and raises ``KickstartNameConflict``; the endpoint maps it to a 409
    with the structured detail shape ``{"error": "business_name_taken",
    "name": ...}`` mirroring the import_root/businesses 409 contract.
    """
    industry_id, _ = _seed_single_ecm(engine, name="Collision Industry")
    # First kickstart with a given name succeeds.
    r1 = client.post(
        f"/api/industry-models/{industry_id}/kickstart",
        json={"source_version": 1, "new_name": "Duplicate Name Co"},
    )
    assert r1.status_code == 200, r1.text

    # Second kickstart with the SAME name -> clean 409, no second business.
    r2 = client.post(
        f"/api/industry-models/{industry_id}/kickstart",
        json={"source_version": 1, "new_name": "Duplicate Name Co"},
    )
    assert r2.status_code == 409, r2.text
    detail = r2.json()["detail"]
    assert detail["error"] == "business_name_taken"
    assert detail["name"] == "Duplicate Name Co"


# ==========================================================================
# Target (c): convergence regression — public walk_volume_dir actually
# indexes a populated dir (the migration's whole point).
# ==========================================================================


def _ws_recursive_tree(file_listing: list[str]) -> MagicMock:
    """ws mock with a recursive directory tree keyed by relative dir path.

    Mirrors the real Files API: list_directory_contents is non-recursive and
    returns immediate children (files + sub-dirs) each carrying ``.name``.
    The public walker MUST read ``entry.name`` and build ``f"{root}/{name}"``
    itself, recursing per directory. A stub that read ``entry.path`` (the old
    private walker shape) would return 0 files here.
    """
    ws = MagicMock()
    children: dict[str, dict[str, bool]] = {}
    for rel in file_listing:
        parts = rel.split("/")
        for depth in range(len(parts)):
            parent = "/".join(parts[:depth])
            name = parts[depth]
            is_dir = depth < len(parts) - 1
            children.setdefault(parent, {})
            children[parent][name] = children[parent].get(name, False) or is_dir

    registered = sorted((k for k in children if k), key=len, reverse=True)

    def _rel_key(abs_root: str) -> str:
        abs_root = abs_root.rstrip("/")
        for key in registered:
            if abs_root.endswith("/" + key) or abs_root == key:
                return key
        return ""

    def _list(root: str):
        entries = []
        for name, is_dir in children.get(_rel_key(root), {}).items():
            e = MagicMock()
            e.name = name
            e.is_directory = is_dir
            e.file_size = 123
            entries.append(e)
        return entries

    ws.files.list_directory_contents.side_effect = _list
    return ws


def test_public_walker_reads_entry_name_recursively():
    """The convergence's whole point: the public walker reads ``entry.name``
    and recurses. A populated tree yields the FULL flattened file list, not 0.
    """
    root = "/Volumes/cat/_metamodel/vol/business/acme/ecm_v1"
    files = [
        "model.json",
        "vibes/next_vibes.txt",
        "vibes/notes.md",
        "docs/data_model.xlsx",
        "ontology/o.ttl",
        "diagram/model.dbml",
    ]
    ws = _ws_recursive_tree(files)
    got = walk_volume_dir(ws, root)
    expected = {f"{root}/{f}" for f in files}
    assert set(got) == expected, (
        f"public walker must flatten the recursive tree; got {got}"
    )
    assert len(got) == len(files)


def test_public_walker_empty_and_error_yield_empty():
    """Missing/permission-denied dirs are best-effort -> []."""
    ws_err = MagicMock()
    ws_err.files.list_directory_contents.side_effect = Exception("403")
    assert walk_volume_dir(ws_err, "/Volumes/x") == []

    ws_empty = MagicMock()
    ws_empty.files.list_directory_contents.return_value = []
    assert walk_volume_dir(ws_empty, "/Volumes/y") == []


def test_public_walker_skips_entries_without_name():
    """Entries lacking ``.name`` are skipped (defensive against SDK shape)."""
    ws = MagicMock()
    good = MagicMock(); good.name = "f.json"; good.is_directory = False; good.file_size = 1
    bad = MagicMock(); bad.name = None; bad.is_directory = False
    ws.files.list_directory_contents.return_value = [good, bad]
    got = walk_volume_dir(ws, "/Volumes/z")
    assert got == ["/Volumes/z/f.json"]


def test_snapshot_indexes_populated_dir_via_public_walker(engine, seed_business):
    """End-to-end convergence check: a snapshot of a POPULATED version dir
    reads real files through the public walker and zips them. If the walker
    were a wrong stub (reading entry.path / 0 files), files_added would be 0
    and this would be the empty-snapshot path. We assert the populated path.
    """
    from vibe_modeling.backend.services.operations.snapshot_version import (
        SnapshotVersion,
    )
    from vibe_modeling.backend.services.operations import OperationContext

    with Session(engine) as s:
        mv = ModelVersion(
            business_id=seed_business, version=1, status="completed",
            scope="ecm", uc_catalog="test_cat",
        )
        s.add(mv)
        r = Run(business_id=seed_business, intent="snapshot", status="pending",
                parameters_json="{}")
        s.add(r)
        s.commit()
        s.refresh(mv); s.refresh(r)
        mv_id, run_id = mv.id, r.id

    files = ["model.json", "vibes/next_vibes.txt", "docs/data_model.xlsx"]
    ws = _ws_recursive_tree(files)
    body = MagicMock()
    body.contents.read.return_value = b"<bytes>"
    ws.files.download.return_value = body
    ws.files.upload = MagicMock()

    ctx = OperationContext(
        run_id=run_id, operation_id="op-conv-1", business_id=seed_business,
        parent_version_id=mv_id, params={"label": "convergence"},
        inherited_params={},
    )
    prim = SnapshotVersion()
    with Session(engine) as s:
        handle = prim.dispatch(ctx, ws, s)
        obs = prim.observe(handle, ctx, ws, s)
        s.commit()

    assert handle.extra.get("files_added") == len(files), (
        f"populated dir must zip {len(files)} files via the public walker; "
        f"got files_added={handle.extra.get('files_added')!r} — a 0 here would "
        f"mean the walker stub is broken (reads wrong attr / no recursion)"
    )
    assert obs.terminal_result.succeeded is True
    assert obs.terminal_result.output_artifacts, "snapshot must record the zip artifact"
    # download() was called once per file -> the walker truly enumerated them.
    assert ws.files.download.call_count == len(files)

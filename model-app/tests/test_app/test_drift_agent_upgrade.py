"""Drift tests for a bundled agent change (v0.9.0 design 10.3, story C2).

When the bundled agent moves from 4.9.9 to 5.3.3 the app meets versions the
older agent left behind next to ones the new agent writes. These tests build
both from the agents' own writers (``fixtures/agent_shapes``, captured by
``capture.py`` from the notebooks, README there) and check that, across the
change, the app's sync, export, run report, vibe pre-flight and the
Lakebase/UC consistency checker stay consistent, on the recording UC fake.

Layers:

* **Pins.** The committed shapes equal what the vendored notebook's writers
  emit; vendoring another agent fails them until the fixtures are recaptured.
* **Shapes.** Each model.json shape syncs, classifies and unwraps the same way.
* **Upgrade.** Rows of both agents side by side, in both Volume layouts and
  before and after the 5.3.3 registry migration; 5.3.3 writing on top of
  4.9.9 rows; the boot upgrade leaving versions readable.
* **Reports.** The run report of a run whose output either agent wrote.

Expected inconsistencies are strict xfails naming the unit that fixes them.
"""
from __future__ import annotations

import copy
import importlib.util
import json
import re
import sys
from dataclasses import dataclass
from datetime import datetime, timezone
from functools import lru_cache
from pathlib import Path
from types import SimpleNamespace
from typing import Optional

import pytest
from sqlmodel import Session, select

from vibe_modeling.backend.agent_compat import (
    SUPPORTED_TAGS,
    classify_tag,
    detect_tag_from_model_json,
    extract_version_provenance,
    is_newer_tag,
)
from vibe_modeling.backend.core._defaults import SUPPORTED_AGENT_VERSION
from vibe_modeling.backend.core._names import agent_business_segment, metamodel_display_business
from vibe_modeling.backend.core._paths import version_dir_candidates
from vibe_modeling.backend.db_models import (
    AgentConfig, Attribute, Business, Domain, ForeignKeyLink, ModelVersion, ModelVersionInstall, Product, Run,
    RunAgentReport, RunInputLink, RunOperation, VibeInput,
)
from vibe_modeling.backend.import_model import model_payload
from vibe_modeling.backend.initial_sync import InitialSyncService
from vibe_modeling.backend.model_sync import ModelSyncService, _count_source_elements, _unwrap_model_envelope
from vibe_modeling.backend.models import Intent, RunIn
from vibe_modeling.backend.oob_detector import OobDetector
from vibe_modeling.backend.run_report import build_run_report, persist_agent_report
from vibe_modeling.backend.services.operations.vibe_iterate import VibeIterate, _build_agent_outcomes
from vibe_modeling.backend.services.orchestrator.preflight import _check_metamodel_parent_version_present

from .test_agent_boot_upgrade import (  # noqa: F401 - the boot upgrade's fixtures and helpers
    NEW_PATH,
    OLD_PATH,
    _app_id_cache,
    _boot as boot_run,
    _seed as boot_seed,
    _stored as boot_stored,
    agent,
    installed,
    job,
    ws,
)
from ._drift.consistency import assert_lakebase_metamodel_consistent
from ._drift.fake_uc import DELTA_WRITER_COLUMNS, IMPORT_WRITER_COLUMNS, REGISTRY_TABLES, FakeUC
from ._drift.fixtures import WAREHOUSE_ID, fake_uc  # noqa: F401

REPO = Path(__file__).resolve().parents[2]
SHAPES = REPO / "tests" / "fixtures" / "agent_shapes"
VENDORED_AGENT = REPO / "src" / "app" / "vendored" / "agent"
VENDORED_NOTEBOOK = VENDORED_AGENT / json.loads((VENDORED_AGENT / "VERSIONS.json").read_text())["notebook_file"]
REAL_0_7_1 = REPO / "tests" / "fixtures" / "real_agent_model_sample.json"

CAT = "drift_cat"
BUSINESS = "Acme Co"
SESSION_ID = "5862025805566066695"
TS = "2026-05-08 02:27:55.896"
RESULTS_JSON = '{"artifact": "model_json", "total_domains": 2, "total_products": 3}'
EXPECTED_COUNTS = {"domains": 2, "products": 3, "attributes": 9, "fk_links": 2}


# ---------------------------------------------------------------------------
# The captured shapes
# ---------------------------------------------------------------------------


def _load_capture_module():
    spec = importlib.util.spec_from_file_location("agent_shapes_capture", SHAPES / "capture.py")
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


capture = _load_capture_module()


def _json(name: str) -> dict:
    return json.loads((SHAPES / name).read_text())


def stamp_version(doc: dict, version: int, scope: str = "mvm") -> dict:
    """A copy of ``doc`` that names ``version`` of ``scope`` as the version it wrote,
    in the model, the session metadata and the lineage."""
    doc = copy.deepcopy(doc)
    doc["model"]["version"] = f"v{version}_{scope}"
    doc["model"]["location"] = doc["model"]["location"].rsplit("/v", 1)[0] + f"/v{version}/{scope}"
    doc["_vibe_session_metadata"]["generated_from_version"] = f"v{version}_{scope}"
    doc["_vibe_session_metadata"]["target_model_version"] = str(version)
    if isinstance(doc.get("lineage"), dict):
        doc["lineage"]["output_version"] = str(version)
    return doc


@dataclass(frozen=True)
class Era:
    """One agent's captured shapes and the model.json it writes."""

    label: str
    shapes: dict
    base_doc: dict

    @property
    def has_deploy_status(self) -> bool:
        return "deploy_status" in self.shapes.get("migration_columns", [])

    def doc(self, version: int, scope: str = "mvm") -> dict:
        """The era's model.json for a version of ``scope``, naming that version as its output."""
        return stamp_version(self.base_doc, version, scope)


ERA_4_9_9 = Era("4.9.9", _json("agent_4_9_9.json"), _json("model_json_4_9_9.json"))
ERA_5_3_3 = Era("5.3.3", _json("agent_5_3_3.json"), _json("model_json_5_3_3_base.json"))
NO_4_9_9_INSTALL = (
    "4.9.9's install registrar is inline code (cell 204), not a function to lift; its install rows are not captured"
)
ERAS = pytest.mark.parametrize("era", [ERA_4_9_9, ERA_5_3_3], ids=lambda e: e.label)
LAYOUTS = pytest.mark.parametrize("layout", ["nested", "flat"])

MODEL_SHAPES = {
    "flat": _json("model_json_flat.json"),
    "agent_0_7_1": json.loads(REAL_0_7_1.read_text()),
    "agent_4_9_9": _json("model_json_4_9_9.json"),
    "agent_5_3_3_base": _json("model_json_5_3_3_base.json"),
    "agent_5_3_3_vibe": _json("model_json_5_3_3_vibe.json"),
    "agent_5_3_3_vibe_stale": _json("model_json_5_3_3_vibe_stale.json"),
}
ALL_SHAPES = pytest.mark.parametrize("shape", sorted(MODEL_SHAPES))


@lru_cache(maxsize=1)
def vendored_writers():
    """The vendored 5.3.3 notebook's writers, lifted out of it (about a second)."""
    return capture.AgentWriters(VENDORED_NOTEBOOK)


def run_table_rows(era: Era, doc: dict, *, business: str, version: int, scope: str) -> dict[str, list[dict]]:
    """The domain, product and attribute rows a run's final merge appends: the
    columns of its ``StructType`` blocks, NULL where the pipeline record has no
    value. Every column the notebook writes needs a source here, so a new
    column fails the build of the row instead of going unchecked."""
    key = {"business": business, "version": str(version), "model_scope": scope}
    model = model_payload(doc)
    sources = {
        "domain": lambda d: {"domain": d["name"], "division": d["division"], "description": d["description"],
                             "database_name": d["database_name"], "reference": d["references"]},
        "product": lambda d, p: {"domain": d["name"], "subdomain": p["subdomain"], "product": p["name"],
                                 "description": p["description"], "type": p["type"], "division": p["division"],
                                 "function": p["function"], "data_type": p["data_type"],
                                 "source_domains": p["source_domains"], "association_edges": p["association_edges"],
                                 "primary_key": p["primary_key"], "reference": p["reference"],
                                 "table_name": p["table_name"], "sample_path": None, "tags": p["tags"]},
        "attribute": lambda d, p, a: {"domain": d["name"], "product": p["name"], "attribute": a["name"],
                                      "column_name": a["column_name"], "type": a["type"], "tags": a["tags"],
                                      "value_regex": a["value_regex"], "foreign_key_to": a["foreign_key_to"],
                                      "business_glossary_term": a["business_glossary_term"],
                                      "description": a["description"], "reference": a["references"]},
    }
    columns = era.shapes["run_merge_columns"]
    rows: dict[str, list[dict]] = {"domain": [], "product": [], "attribute": []}
    for d in model["domains"]:
        rows["domain"].append(sources["domain"](d))
        for p in d["products"]:
            rows["product"].append(sources["product"](d, p))
            for a in p["attributes"]:
                rows["attribute"].append(sources["attribute"](d, p, a))
    return {
        table: [{c: ({**key, **row})[c] for c in columns[table]} for row in table_rows]
        for table, table_rows in rows.items()
    }


def business_row(
    era: Era, state: str, *, business: str, version: int, scope: str, catalog: str,
    layout: str = "nested",
) -> dict:
    """A ``business`` row in ``state``, from the agent's own INSERT.

    ``run_start`` is the row ``insert_business_row`` writes; ``initialized``,
    ``ready`` and ``finalized`` apply the ``VibeWriter`` UPDATEs that follow
    (``initialize_session``, ``_update_session_ready``, ``_finalize_session``);
    ``installed`` is the row the install replaces it with
    (``insert_deployed_business_row``), which carries no session columns."""
    kind = "installed" if state == "installed" else "run_start"
    row = dict(era.shapes["business_rows"][kind]["values"])
    folder = f"{scope}_v{version}" if layout == "flat" else f"v{version}/{scope}"
    row.update(
        business=business, version=str(version), model_scope=scope, catalog=catalog,
        location=f"/Volumes/{catalog}/_metamodel/vol_root/business/{agent_business_segment(business)}/{folder}",
    )
    if state in ("initialized", "ready", "finalized"):
        row.update(
            session_id=SESSION_ID, processing_status="done", completed_percent="0.0",
            session_started_at=TS, last_updated_at=TS, session_json="{}", results_json="{}",
        )
    if state == "ready":
        row.update(completed_percent="99.0", processing_status="ready")
    if state == "finalized":
        row.update(
            completed_percent="100.0", processing_status="done", last_updated_at=TS,
            completion_date=TS, results_json=RESULTS_JSON,
        )
    if state == "installed":
        row.update(completion_date=TS)
    if era.has_deploy_status:
        row["deploy_status"] = "installed" if state == "installed" else None
    return row


def seed_agent_version(
    fake_uc: FakeUC, era: Era, *, catalog: str = CAT, name: str = BUSINESS, version: int = 1, scope: str = "mvm",
    layout: str = "nested", state: str = "finalized", model_json: bool = True, doc: Optional[dict] = None,
) -> dict:
    """Registry rows and ``model.json`` for one version as ``era``'s agent leaves them.

    A run's domain, product and attribute rows are its final merge's; a state of
    ``installed`` has the install registrar's rows instead (5.3.3 only).
    Returns the model.json written."""
    doc = doc if doc is not None else era.doc(version, scope)
    registry_name = metamodel_display_business(name)
    fake_uc.add_metamodel(catalog)
    fake_uc.add_rows(catalog, "business", [business_row(
        era, state, business=registry_name, version=version, scope=scope, catalog=catalog,
        layout=layout,
    )])
    if state == "installed":
        tables = vendored_writers().installer_rows(model_payload(doc), registry_name, str(version), scope, catalog)
    else:
        tables = run_table_rows(era, doc, business=registry_name, version=version, scope=scope)
    for table, rows in tables.items():
        fake_uc.add_rows(catalog, table, rows)
    if model_json:
        nested, flat = version_dir_candidates(catalog, name, version, scope)
        fake_uc.put_file(f"{flat if layout == 'flat' else nested}/model.json", doc)
    return doc


def apply_5_3_3_registry_migration(fake_uc: FakeUC, catalog: str = CAT) -> None:
    """What 5.3.3's ``_ensure_metamodel_registry`` does to an older ``business``
    table: ADD COLUMN for each missing migration column (NULL on existing rows),
    then fill ``completed_percent`` from ``work_completed_percent`` where NULL."""
    migration = ERA_5_3_3.shapes["migration_columns"]

    def migrate(rows: list[dict]) -> list[dict]:
        for row in rows:
            for column in migration:
                row.setdefault(column, None)
            legacy = row.get("work_completed_percent")
            if row.get("completed_percent") is None and legacy is not None:
                row["completed_percent"] = str(float(legacy.replace("%", "")))
        return rows

    fake_uc.edit_rows(catalog, "business", migrate)


def discover(engine, fake_uc: FakeUC, catalog: str = CAT) -> dict:
    with Session(engine) as session:
        summary = InitialSyncService(session, fake_uc.ws, WAREHOUSE_ID).discover_and_sync(catalog)
        session.commit()
    return summary


def sync_counts(session: Session, version_id: str) -> dict[str, int]:
    return {
        "domains": len(session.exec(select(Domain).where(Domain.version_id == version_id)).all()),
        "products": len(session.exec(select(Product).where(Product.version_id == version_id)).all()),
        "attributes": len(session.exec(
            select(Attribute).join(Product, Attribute.product_id == Product.id).where(Product.version_id == version_id)
        ).all()),
        "fk_links": len(session.exec(select(ForeignKeyLink).where(ForeignKeyLink.version_id == version_id)).all()),
    }


def register_install_5_3_3(
    fake_uc: FakeUC, doc: dict, *, name: str = BUSINESS, version: int = 1, scope: str = "mvm",
    catalog: str = CAT, deploy_status: str = "installed",
) -> None:
    """``_register_model_json_in_metamodel`` of the 5.3.3 notebook (cell 118) on the fake.

    The install into ``catalog`` registers in the ``_metamodel`` of ``CAT``. Without a
    registration of the same version in another catalog it deletes the version's
    rows and inserts its own. With one (``install-registry-keeps-deployment``) it
    keeps that registration's business and domain rows and adds its own, so the
    key then has one business row and one set of domain rows per install catalog;
    product and attribute rows stay one set. The business row it inserts has no
    session columns.

    The rows are the registrar's with ``names=None``, the shape the bootstrap
    registration uses (cell 124). The real install passes a ``names`` mapping
    (cell 210, near the ``_register_model_json_in_metamodel`` call) that resolves
    each domain's catalog, the table and column names, the primary key and the
    column types, so installs with a catalog per domain, a prefix or key types
    differ from these rows. ``capture.emulated_sources`` hashes the code this
    function reproduces."""
    business = metamodel_display_business(name)
    ver = str(version)

    def in_key(row: dict) -> bool:
        return (
            (row["business"] or "").lower() == business.lower() and row["version"] == ver
            and row["model_scope"] in (scope, None)
        )

    def has_catalog(row: dict, cat: str) -> bool:
        return (row.get("catalog") or "").lower() == cat.lower()

    others: list[str] = []
    for row in fake_uc.rows(CAT, "business"):
        cat, status = (row.get("catalog") or "").strip(), (row.get("deploy_status") or "").strip().lower()
        if in_key(row) and cat and cat.lower() != catalog.lower() and status != "dry_run" and cat not in others:
            others.append(cat)
    mine = (lambda r: in_key(r) and has_catalog(r, catalog)) if others else in_key
    if others:
        fake_uc.edit_rows(CAT, "domain", lambda rows: [
            {**r, "catalog": others[0]} if in_key(r) and not r.get("catalog") else r for r in rows
        ])
    for table, matches in (("attribute", in_key), ("product", in_key), ("domain", mine), ("business", mine)):
        fake_uc.edit_rows(CAT, table, lambda rows, m=matches: [r for r in rows if not m(r)])
    row = business_row(ERA_5_3_3, "installed", business=business, version=version, scope=scope, catalog=catalog)
    row["deploy_status"] = deploy_status
    fake_uc.add_rows(CAT, "business", [row])
    for table, rows in vendored_writers().installer_rows(model_payload(doc), business, ver, scope, catalog).items():
        fake_uc.add_rows(CAT, table, rows)


def ensure_install_rows(session: Session) -> None:
    """Keep the install rows in step with ``deployment_status``: an open row in
    ``uc_catalog`` for a deployed version, none for any other. A2b's lifecycle
    writers do this (an internal tracker item, every install-state writer through
    ``_version_lifecycle``); initial sync writes no install row today, so the tests
    apply it after each discovery and the checker's item 3 stays about the agent
    change. Once A2b lands the calls change nothing and can go."""
    for mv in session.exec(select(ModelVersion)).all():
        open_rows = session.exec(select(ModelVersionInstall).where(
            ModelVersionInstall.version_id == mv.id, ModelVersionInstall.uninstalled_at.is_(None),
        )).all()
        if mv.deployment_status == "deployed" and mv.uc_catalog and not open_rows:
            session.add(ModelVersionInstall(version_id=mv.id, catalog=mv.uc_catalog))
        elif mv.deployment_status != "deployed":
            for row in open_rows:
                row.uninstalled_at = datetime.now(timezone.utc)
                session.add(row)
    session.commit()


def versions_by_key(session: Session) -> dict[tuple[int, str], ModelVersion]:
    return {(mv.version, mv.scope): mv for mv in session.exec(select(ModelVersion)).all()}


# ---------------------------------------------------------------------------
# Pins: the fixtures are what the notebooks' writers emit
# ---------------------------------------------------------------------------


class TestShapePins:

    def test_the_code_the_tests_emulate_is_unchanged(self):
        now = capture.emulated_source_hashes(vendored_writers().cells)
        changed = sorted(
            name for name in now.keys() | ERA_5_3_3.shapes["emulated_sources"].keys()
            if now.get(name) != ERA_5_3_3.shapes["emulated_sources"].get(name)
        )
        assert not changed, (
            f"agent code that `register_install_5_3_3`, `apply_5_3_3_registry_migration` and `business_row` "
            f"reproduce by hand changed: {changed}. Re-read it, adjust the emulation, then recapture."
        )

    def test_committed_5_3_3_shapes_are_what_the_vendored_notebook_writes(self):
        assert capture.capture(VENDORED_NOTEBOOK) == ERA_5_3_3.shapes, (
            "the vendored notebook's writers no longer produce the committed shapes; review what changed for "
            "the sync, then run: python tests/fixtures/agent_shapes/capture.py "
            "src/app/vendored/agent/<notebook> tests/fixtures/agent_shapes/agent_<version>.json"
        )

    def test_the_4_9_9_shapes_come_from_the_4_9_9_notebook(self):
        shapes = ERA_4_9_9.shapes
        assert (shapes["agent_version"], shapes["release_version"]) == ("4.9.9", "0.8.0")
        assert shapes["notebook_sha256"] == "90595dda8a4c7cb793bcfcf800d74851e825cca6276473c32fc5951236a3d7f3"

    def test_update_statements_that_move_a_run_row_are_in_the_notebook(self):
        writers = vendored_writers()
        source = writers.cells[writers.where["VibeWriter._build_insert_sql"]]
        for fragments in capture.STATE_UPDATES.values():
            for fragment in fragments:
                assert fragment in source, fragment
        registrar = writers.cells[writers.where["_metamodel_registry_records"]]
        assert "SET deploy_status = " in registrar

    def test_the_fixtures_build_rows_with_the_stored_values_of_each_state(self):
        run = business_row(ERA_5_3_3, "finalized", business="Acme_Co", version=1, scope="mvm", catalog=CAT)
        installed = business_row(ERA_5_3_3, "installed", business="Acme_Co", version=1, scope="mvm", catalog=CAT)
        assert set(run) == set(ERA_5_3_3.shapes["business_columns"]) | {"deploy_status"}
        assert (run["processing_status"], run["completed_percent"], run["session_id"]) == ("done", "100.0", SESSION_ID)
        assert run["deploy_status"] is None
        assert (installed["deploy_status"], installed["session_id"], installed["session_json"]) == ("installed", None, None)
        assert installed["completed_percent"] == "100.0" and installed["completion_date"] == TS

    @pytest.mark.parametrize("shape, era", [
        ("agent_4_9_9", ERA_4_9_9), ("agent_5_3_3_base", ERA_5_3_3), ("agent_5_3_3_vibe", ERA_5_3_3),
        ("agent_5_3_3_vibe_stale", ERA_5_3_3),
    ])
    def test_model_json_fixtures_carry_the_keys_the_writer_builds(self, shape, era):
        doc, keys = MODEL_SHAPES[shape], era.shapes["model_json_keys"]
        model = doc["model"]
        domains = model["domains"]
        products = [p for d in domains for p in d["products"]]
        attributes = [a for p in products for a in p["attributes"]]
        assert (len(domains), len(products), len(attributes)) == (2, 3, 9)
        optional_root = {"_vibe_scope", "entity_changes", "input_outcomes"}
        assert set(doc) - optional_root == set(keys["root"]["always"])
        assert set(doc) & optional_root <= set(keys["root"]["when_present"])
        assert set(model) == set(keys["model"]["always"])
        for domain in domains:
            assert set(domain) == set(keys["domain"]["always"])
        for product in products:
            assert set(product) == set(keys["product"]["always"])
        for attribute in attributes:
            assert set(keys["attribute"]["always"]) <= set(attribute) <= set(
                keys["attribute"]["always"] + keys["attribute"]["when_present"]
            )

    def test_what_5_3_3_adds_to_4_9_9(self):
        old, new = ERA_4_9_9.shapes, ERA_5_3_3.shapes
        assert old["business_columns"] == new["business_columns"]
        assert old["other_table_columns"] == new["other_table_columns"]
        assert old["run_merge_columns"] == new["run_merge_columns"]
        for kind in ("run_start", "installed"):
            assert old["business_rows"][kind] == new["business_rows"][kind]
        assert "migration_columns" not in old and new["migration_columns"][-1] == "deploy_status"
        added = {"root": ({"lineage"}, {"_vibe_scope", "entity_changes", "input_outcomes"}), "model": (set(), set()),
                 "domain": (set(), set()), "product": ({"steward"}, set()), "attribute": (set(), {"steward"})}
        assert set(old["model_json_keys"]) == set(new["model_json_keys"]) == set(added)
        for block, (always, when_present) in added.items():
            before, after = old["model_json_keys"][block], new["model_json_keys"][block]
            assert set(after["always"]) - set(before["always"]) == always, block
            assert set(before["always"]) - set(after["always"]) == set(), block
            assert set(after["when_present"]) - set(before["when_present"]) == when_present, block
            assert set(before["when_present"]) - set(after["when_present"]) == set(), block

    def test_the_fakes_import_writer_rows_are_not_the_agents_run_rows(self):
        """``FakeUC.add_agent_version`` writes the app import writer's columns. A run's
        final merge leaves ``catalog`` and ``tags`` NULL on domain rows, and the
        install registrar fills them: the gap the seeds above close."""
        run = ERA_5_3_3.shapes["run_merge_columns"]
        # The seed also writes the migration column deploy_status ('dry_run').
        assert IMPORT_WRITER_COLUMNS["business"] == (*ERA_5_3_3.shapes["business_columns"], "deploy_status")
        assert set(IMPORT_WRITER_COLUMNS["domain"]) - set(run["domain"]) == {"catalog", "tags"}
        assert tuple(run["product"]) == IMPORT_WRITER_COLUMNS["product"]
        assert tuple(run["attribute"]) == IMPORT_WRITER_COLUMNS["attribute"]
        assert tuple(ERA_5_3_3.shapes["installer_columns"]["domain"]) == IMPORT_WRITER_COLUMNS["domain"]
        assert DELTA_WRITER_COLUMNS["domain"] == IMPORT_WRITER_COLUMNS["domain"]
        assert set(REGISTRY_TABLES) == {"business", "domain", "product", "attribute"}


# ---------------------------------------------------------------------------
# Shapes: what each model.json shape does in the app
# ---------------------------------------------------------------------------

SHAPE_FACTS = {
    # shape: (agent_version, release version, tag without fallback, tag the import routes use)
    "flat": (None, None, "", "v0.8.0"),
    "agent_0_7_1": ("0.7.1", "0.7.1", "v0.7.1", "v0.7.1"),
    "agent_4_9_9": ("4.9.9", "0.8.0", "v0.8.0", "v0.8.0"),
    "agent_5_3_3_base": ("5.3.3", "0.8.0", "v0.8.0", "v0.8.0"),
    "agent_5_3_3_vibe": ("5.3.3", "0.8.0", "v0.8.0", "v0.8.0"),
    "agent_5_3_3_vibe_stale": ("5.3.3", "0.8.0", "v0.8.0", "v0.8.0"),
}


def _new_version(session: Session, scope: str = "mvm", version: int = 1, name: str = BUSINESS) -> ModelVersion:
    business = session.exec(select(Business).where(Business.name == name)).first()
    if business is None:
        business = Business(name=name)
        session.add(business)
        session.flush()
    mv = ModelVersion(business_id=business.id, version=version, scope=scope, status="completed")
    session.add(mv)
    session.flush()
    return mv


class TestModelJsonShapes:

    @ALL_SHAPES
    def test_every_shape_unwraps_the_same_way(self, shape):
        doc = MODEL_SHAPES[shape]
        assert model_payload(doc) is _unwrap_model_envelope(doc)
        assert model_payload(doc)["domains"]
        wrapped = shape != "flat"
        assert (model_payload(doc) is not doc) is wrapped

    @ALL_SHAPES
    def test_every_shape_syncs_to_the_counts_it_carries(self, engine, shape):
        doc = MODEL_SHAPES[shape]
        expected = _count_source_elements(doc)
        with Session(engine) as session:
            mv = _new_version(session)
            counts = ModelSyncService(session).sync_from_model_json(mv.id, doc)
            session.commit()
            assert counts == expected
            assert sync_counts(session, mv.id) == expected
        if shape != "agent_0_7_1":
            assert expected == EXPECTED_COUNTS

    @ALL_SHAPES
    def test_version_provenance_and_the_import_gate_agree_with_the_shape(self, shape):
        doc = MODEL_SHAPES[shape]
        agent_version, release_version, tag, gate_tag = SHAPE_FACTS[shape]
        assert extract_version_provenance(doc) == (agent_version, release_version)
        assert detect_tag_from_model_json(doc) == tag
        assert detect_tag_from_model_json(doc, fallback=SUPPORTED_AGENT_VERSION) == gate_tag
        assert classify_tag(gate_tag) == "compatible"

    @ALL_SHAPES
    def test_a_synced_shape_keeps_its_provenance(self, engine, shape):
        doc = MODEL_SHAPES[shape]
        with Session(engine) as session:
            mv = _new_version(session)
            ModelSyncService(session)._capture_run_metadata(mv.id, CAT, BUSINESS, "1", "mvm", doc)
            session.commit()
            session.refresh(mv)
            assert (mv.agent_version, mv.release_version) == SHAPE_FACTS[shape][:2]

    @pytest.mark.parametrize("tag", sorted(SUPPORTED_TAGS))
    def test_every_tag_the_matrix_accepts_syncs(self, engine, tag):
        """The classification and the sync agree across the whole matrix: a
        5.3.3 model.json stamped as each supported release, in the pre-0.8.0
        scheme (``agent_version`` is the release) or the 0.8.0 one
        (``release_version``), is compatible and syncs in full."""
        doc = copy.deepcopy(MODEL_SHAPES["agent_5_3_3_base"])
        if not is_newer_tag("v0.8.0", tag):
            doc["release_version"] = tag.lstrip("v")
        else:
            doc.pop("release_version")
            doc["agent_version"] = tag.lstrip("v")
        detected = detect_tag_from_model_json(doc, fallback=SUPPORTED_AGENT_VERSION)
        assert detected == tag
        assert classify_tag(detected) == "compatible"
        with Session(engine) as session:
            mv = _new_version(session)
            assert ModelSyncService(session).sync_from_model_json(mv.id, doc) == EXPECTED_COUNTS

    @pytest.mark.parametrize("stamps", [
        {"release_version": "0.9.0"}, {"release_version": None, "agent_version": "4.9.9"},
    ], ids=["a_release_the_matrix_lacks", "an_agent_counter_without_a_release"])
    def test_the_direct_sync_path_does_not_read_the_compat_matrix(self, engine, stamps):
        """``ModelSyncService.sync_from_model_json`` is the writer under every caller and
        reads no tag: a model.json whose tag the matrix lacks (``unknown``) syncs in full.
        Gating happens in the callers: the import routes refuse it, discovery should
        (next test)."""
        doc = copy.deepcopy(MODEL_SHAPES["agent_5_3_3_base"])
        for key, value in stamps.items():
            doc.pop(key, None) if value is None else doc.__setitem__(key, value)
        assert classify_tag(detect_tag_from_model_json(doc, fallback=SUPPORTED_AGENT_VERSION)) == "unknown"
        with Session(engine) as session:
            mv = _new_version(session)
            assert ModelSyncService(session).sync_from_model_json(mv.id, doc) == EXPECTED_COUNTS

    @pytest.mark.parametrize("stamps", [
        {"release_version": "0.9.0"}, {"release_version": None, "agent_version": "4.9.9"},
    ], ids=["a_release_the_matrix_lacks", "an_agent_counter_without_a_release"])
    def test_discovery_applies_the_gate_the_import_routes_apply(self, engine, fake_uc, stamps):
        doc = copy.deepcopy(ERA_5_3_3.doc(1))
        for key, value in stamps.items():
            doc.pop(key, None) if value is None else doc.__setitem__(key, value)
        assert classify_tag(detect_tag_from_model_json(doc, fallback=SUPPORTED_AGENT_VERSION)) == "unknown"
        seed_agent_version(fake_uc, ERA_5_3_3, doc=doc)
        summary = discover(engine, fake_uc)
        assert summary["versions_synced"] == 0 and summary["errors"]


# ---------------------------------------------------------------------------
# Upgrade: both agents' rows side by side
# ---------------------------------------------------------------------------


def _seed_mixed(fake_uc: FakeUC, *, migrated: bool) -> None:
    """Business 'Acme Co': 4.9.9 left v1 MVM (nested folder) and v1 ECM (the
    legacy flat folder); 5.3.3 added v2 MVM, which migrated the table first."""
    seed_agent_version(fake_uc, ERA_4_9_9, version=1, scope="mvm")
    seed_agent_version(fake_uc, ERA_4_9_9, version=1, scope="ecm", layout="flat")
    if migrated:
        apply_5_3_3_registry_migration(fake_uc)
        seed_agent_version(fake_uc, ERA_5_3_3, version=2, scope="mvm")


class TestAgentRowsSideBySide:

    @pytest.mark.parametrize("migrated", [False, True], ids=["table_only_4_9_9_wrote", "after_5_3_3_migrated_it"])
    def test_discovery_syncs_every_version_whichever_agent_wrote_it(self, engine, fake_uc, migrated):
        _seed_mixed(fake_uc, migrated=migrated)
        summary = discover(engine, fake_uc)
        assert summary["errors"] == []
        assert summary["versions_synced"] == (3 if migrated else 2)
        with Session(engine) as session:
            found = versions_by_key(session)
            assert set(found) == ({(1, "mvm"), (1, "ecm"), (2, "mvm")} if migrated else {(1, "mvm"), (1, "ecm")})
            for key, mv in found.items():
                # One completed version per scope: 5.3.3's v2 MVM supersedes 4.9.9's v1 MVM.
                expected = "superseded" if migrated and key == (1, "mvm") else "completed"
                assert (mv.status, mv.sync_state) == (expected, "ok")
                assert sync_counts(session, mv.id) == EXPECTED_COUNTS
            assert {(k, mv.agent_version, mv.release_version) for k, mv in found.items()} == {
                ((1, "mvm"), "4.9.9", "0.8.0"), ((1, "ecm"), "4.9.9", "0.8.0"),
                *([((2, "mvm"), "5.3.3", "0.8.0")] if migrated else []),
            }
            ensure_install_rows(session)
            assert_lakebase_metamodel_consistent(session, fake_uc)

    def test_the_migration_does_not_change_what_discovery_finds(self, engine, fake_uc):
        _seed_mixed(fake_uc, migrated=False)
        assert discover(engine, fake_uc)["versions_synced"] == 2
        apply_5_3_3_registry_migration(fake_uc)
        again = discover(engine, fake_uc)
        assert (again["versions_synced"], again["businesses_created"], again["errors"]) == (0, 0, [])
        with Session(engine) as session:
            assert len(versions_by_key(session)) == 2
            ensure_install_rows(session)
            assert_lakebase_metamodel_consistent(session, fake_uc)

    def _old_table_without_the_migration(self, fake_uc) -> None:
        """The oldest tables carry ``work_completed_percent`` ('100%') and a NULL
        ``completed_percent``; the 5.3.3 registry migration fills the second from the first."""
        seed_agent_version(fake_uc, ERA_4_9_9, version=1, scope="mvm")
        fake_uc.edit_rows(CAT, "business", lambda rows: [
            {**r, "completed_percent": None, "work_completed_percent": "100%"} for r in rows
        ])

    def test_the_oldest_table_syncs_once_the_migration_has_filled_it(self, engine, fake_uc):
        self._old_table_without_the_migration(fake_uc)
        apply_5_3_3_registry_migration(fake_uc)
        assert discover(engine, fake_uc)["versions_synced"] == 1

    def test_the_oldest_table_reports_that_it_waits_for_the_migration(self, engine, fake_uc):
        self._old_table_without_the_migration(fake_uc)
        summary = discover(engine, fake_uc)
        assert summary["versions_synced"] == 0 and summary["errors"]

    def test_a_registry_row_without_a_scope_does_not_stop_the_business(self, engine, fake_uc):
        seed_agent_version(fake_uc, ERA_4_9_9, version=1, scope="mvm", model_json=False)
        for table in REGISTRY_TABLES:
            fake_uc.edit_rows(CAT, table, lambda rows: [{**r, "model_scope": None} for r in rows])
        business_folder = version_dir_candidates(CAT, BUSINESS, 1, "mvm")[0].rsplit("/v1/", 1)[0]
        fake_uc.put_file(f"{business_folder}/v1/model.json", ERA_4_9_9.doc(1))
        summary = discover(engine, fake_uc)
        assert (summary["versions_synced"], summary["errors"]) == (1, [])

    @ERAS
    @LAYOUTS
    def test_each_agent_in_each_volume_layout(self, engine, fake_uc, era, layout):
        seed_agent_version(fake_uc, era, layout=layout)
        assert discover(engine, fake_uc)["versions_synced"] == 1
        with Session(engine) as session:
            (mv,) = session.exec(select(ModelVersion)).all()
            assert sync_counts(session, mv.id) == EXPECTED_COUNTS
            ensure_install_rows(session)
            assert_lakebase_metamodel_consistent(session, fake_uc)

    @ERAS
    @pytest.mark.parametrize("state", ["finalized", "ready", "installed"])
    def test_the_rows_of_every_lifecycle_state_are_read_the_same(self, engine, fake_uc, era, state):
        """Discovery looks at ``completed_percent`` and ``completion_date`` only, so a
        run row the app has not acknowledged yet (``ready``, 99 percent) is not a
        version, and the installed row that replaces a finished one is."""
        if state == "installed" and era is ERA_4_9_9:
            pytest.skip(NO_4_9_9_INSTALL)
        seed_agent_version(fake_uc, era, state=state)
        expected = 0 if state == "ready" else 1
        assert discover(engine, fake_uc)["versions_synced"] == expected

    @ERAS
    def test_the_delta_fallback_reads_the_agents_rows(self, engine, fake_uc, era):
        """No model.json: the structure comes from the registry rows. They carry no
        agent or release version, so the version's provenance stays empty."""
        seed_agent_version(fake_uc, era, model_json=False)
        nested, _flat = version_dir_candidates(CAT, BUSINESS, 1, "mvm")
        fake_uc.ws.files.create_directory(nested)
        assert discover(engine, fake_uc)["versions_synced"] == 1
        assert fake_uc.calls_to("query_delta_table")
        with Session(engine) as session:
            (mv,) = session.exec(select(ModelVersion)).all()
            assert sync_counts(session, mv.id) == EXPECTED_COUNTS
            assert (mv.agent_version, mv.release_version) == (None, None)
            ensure_install_rows(session)
            assert_lakebase_metamodel_consistent(session, fake_uc)

    def test_the_out_of_band_scan_has_nothing_to_report_after_discovery(self, engine, fake_uc):
        _seed_mixed(fake_uc, migrated=True)
        discover(engine, fake_uc)
        with Session(engine) as session:
            assert OobDetector(session, fake_uc.ws, WAREHOUSE_ID).detect(CAT) == []

    def test_the_out_of_band_scan_knows_a_business_the_app_named_with_a_space(self, engine, fake_uc):
        seed_agent_version(fake_uc, ERA_5_3_3)
        with Session(engine) as session:
            business = Business(name=BUSINESS)
            session.add(business)
            session.flush()
            mv = ModelVersion(business_id=business.id, version=1, scope="mvm", status="completed")
            session.add(mv)
            session.flush()
            ModelSyncService(session, fake_uc.ws, WAREHOUSE_ID).sync_model(
                mv.id, CAT, agent_business_segment(BUSINESS), "1", "mvm",
            )
            session.commit()
            assert OobDetector(session, fake_uc.ws, WAREHOUSE_ID).detect(CAT) == []


# ---------------------------------------------------------------------------
# Upgrade: 5.3.3 writing on top of 4.9.9 rows
# ---------------------------------------------------------------------------

SECOND_CATALOG = "drift_cat_b"


def _discovered_4_9_9_version(engine, fake_uc) -> None:
    seed_agent_version(fake_uc, ERA_4_9_9, version=1, scope="mvm")
    assert discover(engine, fake_uc)["versions_synced"] == 1
    with Session(engine) as session:
        ensure_install_rows(session)


class TestFiveThreeThreeOnTopOfFourNineNine:

    def test_an_install_replaces_the_run_rows_and_nothing_drifts(self, engine, fake_uc):
        _discovered_4_9_9_version(engine, fake_uc)
        apply_5_3_3_registry_migration(fake_uc)
        register_install_5_3_3(fake_uc, ERA_4_9_9.doc(1))
        (row,) = fake_uc.rows(CAT, "business")
        assert (row["deploy_status"], row["session_id"], row["processing_status"], row["completed_percent"]) == (
            "installed", None, "done", "100.0",
        )
        assert {r["catalog"] for r in fake_uc.rows(CAT, "domain")} == {CAT}
        again = discover(engine, fake_uc)
        assert (again["versions_synced"], again["errors"]) == (0, [])
        with Session(engine) as session:
            (mv,) = session.exec(select(ModelVersion)).all()
            assert sync_counts(session, mv.id) == EXPECTED_COUNTS
            assert_lakebase_metamodel_consistent(session, fake_uc)

    def test_a_resync_after_the_install_reads_the_same_version(self, engine, fake_uc):
        _discovered_4_9_9_version(engine, fake_uc)
        apply_5_3_3_registry_migration(fake_uc)
        register_install_5_3_3(fake_uc, ERA_4_9_9.doc(1))
        with Session(engine) as session:
            (mv,) = session.exec(select(ModelVersion)).all()
            assert ModelSyncService(session, fake_uc.ws, WAREHOUSE_ID).sync_model(
                mv.id, CAT, agent_business_segment(BUSINESS), "1", "mvm",
            )
            session.commit()
            assert sync_counts(session, mv.id) == EXPECTED_COUNTS
            assert_lakebase_metamodel_consistent(session, fake_uc)

    def test_the_app_reregisters_a_version_over_the_agents_install_rows(self, engine, fake_uc):
        """The app writes a version's rows after deleting the agent's (``write_model_to_delta``
        skips a key that has a business row, so the delete comes first): its rows replace
        the install registrar's, in the writer's own shape, and the version stays consistent."""
        _discovered_4_9_9_version(engine, fake_uc)
        apply_5_3_3_registry_migration(fake_uc)
        register_install_5_3_3(fake_uc, ERA_4_9_9.doc(1))
        (installed,) = fake_uc.rows(CAT, "business")
        assert installed["deploy_status"] == "installed"
        volume = f"/Volumes/{CAT}/_metamodel/vol_root/business/acme_co/v1/mvm"
        segment = agent_business_segment(BUSINESS)
        with Session(engine) as session:
            svc = ModelSyncService(session, fake_uc.ws, WAREHOUSE_ID)
            assert svc.write_model_to_delta(CAT, segment, "1", "mvm", volume, ERA_4_9_9.doc(1)["model"]) is False
            assert fake_uc.rows(CAT, "business") == [installed]
            assert svc.delete_metamodel_rows(CAT, segment, "1", "mvm") is True
            assert fake_uc.rows(CAT, "business") == []
            assert svc.write_model_to_delta(CAT, segment, "1", "mvm", volume, ERA_4_9_9.doc(1)["model"]) is True
            (replaced,) = fake_uc.rows(CAT, "business")
            assert "deploy_status" not in replaced and replaced["location"] == volume
            assert (len(fake_uc.rows(CAT, "domain")), len(fake_uc.rows(CAT, "product")),
                    len(fake_uc.rows(CAT, "attribute"))) == (2, 3, 9)
            assert_lakebase_metamodel_consistent(session, fake_uc)

    def test_a_second_install_catalog_adds_a_registration_and_the_app_stays_whole(self, engine, fake_uc):
        _discovered_4_9_9_version(engine, fake_uc)
        apply_5_3_3_registry_migration(fake_uc)
        register_install_5_3_3(fake_uc, ERA_4_9_9.doc(1))
        register_install_5_3_3(fake_uc, ERA_4_9_9.doc(1), catalog=SECOND_CATALOG)
        businesses = fake_uc.rows(CAT, "business")
        assert sorted(r["catalog"] for r in businesses) == [CAT, SECOND_CATALOG]
        assert sorted({r["catalog"] for r in fake_uc.rows(CAT, "domain")}) == [CAT, SECOND_CATALOG]
        assert len(fake_uc.rows(CAT, "product")) == 3 and len(fake_uc.rows(CAT, "attribute")) == 9
        again = discover(engine, fake_uc)
        assert (again["versions_synced"], again["errors"]) == (0, [])
        with Session(engine) as session:
            (mv,) = session.exec(select(ModelVersion)).all()
            assert sync_counts(session, mv.id) == EXPECTED_COUNTS
            assert OobDetector(session, fake_uc.ws, WAREHOUSE_ID).detect(CAT) == []

    def test_the_checker_accepts_one_registration_per_install_catalog(self, engine, fake_uc):
        _discovered_4_9_9_version(engine, fake_uc)
        apply_5_3_3_registry_migration(fake_uc)
        register_install_5_3_3(fake_uc, ERA_4_9_9.doc(1))
        register_install_5_3_3(fake_uc, ERA_4_9_9.doc(1), catalog=SECOND_CATALOG)
        with Session(engine) as session:
            assert_lakebase_metamodel_consistent(session, fake_uc)

    def test_discovery_leaves_a_draft_alone_when_the_registry_row_says_dry_run(self, engine, fake_uc):
        _discovered_4_9_9_version(engine, fake_uc)
        apply_5_3_3_registry_migration(fake_uc)
        seed_agent_version(fake_uc, ERA_5_3_3, version=2, scope="mvm", state="finalized")
        register_install_5_3_3(fake_uc, ERA_5_3_3.doc(2), version=2, deploy_status="dry_run")
        with Session(engine) as session:
            business = session.exec(select(Business)).one()
            draft = ModelVersion(
                business_id=business.id, version=2, scope="mvm", status="draft", dry_run=True,
                deployment_status="draft", uc_catalog=None,
            )
            session.add(draft)
            session.commit()
        again = discover(engine, fake_uc)
        assert (again["versions_synced"], again["errors"]) == (0, [])
        with Session(engine) as session:
            found = versions_by_key(session)
            assert set(found) == {(1, "mvm"), (2, "mvm")}
            assert (found[(2, "mvm")].status, found[(2, "mvm")].deployment_status) == ("draft", "draft")
            assert session.exec(select(ModelVersionInstall).where(
                ModelVersionInstall.version_id == found[(2, "mvm")].id)).all() == []

    def test_a_dry_run_unknown_to_the_app_is_not_taken_for_a_deployed_version(self, engine, fake_uc):
        seed_agent_version(fake_uc, ERA_5_3_3, version=1, scope="mvm", state="finalized")
        register_install_5_3_3(fake_uc, ERA_5_3_3.doc(1), deploy_status="dry_run")
        assert discover(engine, fake_uc)["versions_synced"] == 1
        with Session(engine) as session:
            (mv,) = session.exec(select(ModelVersion)).all()
            assert mv.deployment_status != "deployed"


# ---------------------------------------------------------------------------
# Export, vibe pre-flight and the boot upgrade across the change
# ---------------------------------------------------------------------------


class _CountingWarehouse:
    """A ``ws`` whose ``statement_execution`` answers the parent-metamodel pre-flight's
    ``COUNT(*)`` from the fake's business rows, matching them as the SQL does:
    ``LOWER(business) = LOWER(x) AND version = 'n'``. Any other statement fails."""

    def __init__(self, fake_uc: FakeUC) -> None:
        self.fake_uc = fake_uc
        self.statements: list[str] = []
        self.unmatched: list[str] = []
        self.statement_execution = SimpleNamespace(execute_statement=self._execute)

    def _execute(self, *, statement: str, warehouse_id: str, wait_timeout: str, on_wait_timeout=None, parameters=None):
        self.statements.append(statement)
        m = re.fullmatch(
            r"SELECT COUNT\(\*\) AS n FROM `(\w+)`\.`_metamodel`\.`business` "
            r"WHERE LOWER\(business\) = LOWER\('(\w+)'\) AND version = '(\w+)'", statement,
        )
        if m is None:
            self.unmatched.append(statement)
            raise AssertionError(f"unexpected statement: {statement}")
        catalog, business, version = m.groups()
        n = sum(
            1 for r in self.fake_uc.rows(catalog, "business")
            if (r["business"] or "").lower() == business.lower() and r["version"] == version
        )
        from _sql_fakes import response

        return response([[str(n)]])


def _preflight_blocker(engine, fake_uc: FakeUC, warehouse: _CountingWarehouse):
    with Session(engine) as session:
        session.add(AgentConfig(deployment_catalog=CAT, warehouse_id=WAREHOUSE_ID))
        business = session.exec(select(Business)).one()
        parent = session.exec(select(ModelVersion).where(ModelVersion.scope == "ecm")).one()
        session.commit()
        data = RunIn(intent=Intent.VIBE_ITERATE, version_id=parent.id)
        blocker = _check_metamodel_parent_version_present(
            business.id, data, session.exec(select(AgentConfig)).one(), session, warehouse,
            live=True,
        )
    assert warehouse.unmatched == []
    return blocker


class TestAcrossTheChange:

    @ERAS
    @pytest.mark.parametrize("state", ["finalized", "installed"])
    def test_vibe_preflight_finds_the_parent_each_agent_registered(self, engine, fake_uc, era, state):
        if state == "installed" and era is ERA_4_9_9:
            pytest.skip(NO_4_9_9_INSTALL)
        seed_agent_version(fake_uc, era, scope="ecm", state=state)
        discover(engine, fake_uc)
        warehouse = _CountingWarehouse(fake_uc)
        assert _preflight_blocker(engine, fake_uc, warehouse) is None
        assert len(warehouse.statements) == 1

    def test_vibe_preflight_blocks_a_parent_whose_registry_rows_are_gone(self, engine, fake_uc):
        seed_agent_version(fake_uc, ERA_5_3_3, scope="ecm")
        discover(engine, fake_uc)
        fake_uc.edit_rows(CAT, "business", lambda rows: [])
        blocker = _preflight_blocker(engine, fake_uc, _CountingWarehouse(fake_uc))
        assert blocker is not None and blocker.field_path == "version_id"

    def test_vibe_preflight_finds_a_parent_installed_in_two_catalogs(self, engine, fake_uc):
        seed_agent_version(fake_uc, ERA_4_9_9, scope="ecm")
        discover(engine, fake_uc)
        apply_5_3_3_registry_migration(fake_uc)
        doc = ERA_4_9_9.doc(1, "ecm")
        register_install_5_3_3(fake_uc, doc, scope="ecm")
        register_install_5_3_3(fake_uc, doc, scope="ecm", catalog=SECOND_CATALOG)
        assert _preflight_blocker(engine, fake_uc, _CountingWarehouse(fake_uc)) is None

    def test_export_round_trips_the_version_of_each_agent(self, engine, fake_uc, client):
        _seed_mixed(fake_uc, migrated=True)
        discover(engine, fake_uc)
        with Session(engine) as session:
            found = versions_by_key(session)
            business_id = next(iter(found.values())).business_id
            exports = {}
            for key, mv in found.items():
                response = client.get(f"/api/businesses/{business_id}/model-versions/{mv.id}/export")
                assert response.status_code == 200, response.text
                exports[key] = response.json()
            for key, exported in exports.items():
                assert _count_source_elements(exported) == EXPECTED_COUNTS, key
                tag = detect_tag_from_model_json(exported, fallback=SUPPORTED_AGENT_VERSION)
                assert classify_tag(tag) == "compatible", key
                again = _new_version(session, version=10 + key[0], scope=key[1], name="Round Trip")
                assert ModelSyncService(session).sync_from_model_json(again.id, exported) == EXPECTED_COUNTS

    def test_the_boot_upgrade_leaves_the_versions_readable(
        self, engine, fake_uc, ws, agent, job, installed,
    ):
        _seed_mixed(fake_uc, migrated=False)
        discover(engine, fake_uc)
        with Session(engine) as session:
            ensure_install_rows(session)
            before = {k: (mv.id, sync_counts(session, mv.id)) for k, mv in versions_by_key(session).items()}
        boot_seed(engine, OLD_PATH)
        boot_run(engine, ws)
        stored = boot_stored(engine)
        assert (stored.notebook_path, stored.installed_agent_version) == (NEW_PATH, "5.3.3")
        with Session(engine) as session:
            after = {k: (mv.id, sync_counts(session, mv.id)) for k, mv in versions_by_key(session).items()}
            assert after == before
            for key, mv in versions_by_key(session).items():
                assert classify_tag(f"v{mv.release_version}") == "compatible", key
                assert ModelSyncService(session, fake_uc.ws, WAREHOUSE_ID).sync_model(
                    mv.id, CAT, agent_business_segment(BUSINESS), str(mv.version), mv.scope,
                ), key
            session.commit()
            assert_lakebase_metamodel_consistent(session, fake_uc)
        apply_5_3_3_registry_migration(fake_uc)
        seed_agent_version(fake_uc, ERA_5_3_3, version=2, scope="mvm")
        assert discover(engine, fake_uc)["versions_synced"] == 1
        with Session(engine) as session:
            ensure_install_rows(session)
            assert_lakebase_metamodel_consistent(session, fake_uc)


# ---------------------------------------------------------------------------
# Reports: the run report of a run whose output either agent wrote
# ---------------------------------------------------------------------------

INPUT_IDS = ("item-add-email", "item-rename-sales", "item-unlisted")


def _run_with_output(
    engine, fake_uc: FakeUC, output_doc: dict, output_era: Era, *, output_version: int = 2,
) -> str:
    """A vibe run on a 4.9.9 parent (v1) whose output ``output_era``'s agent wrote:
    fetch the file as the vibe operation does, persist the report, then sync the
    output version. An output above v2 has the versions between it and v1 written
    by 4.9.9 and known to the app. Returns the run id."""
    for version in range(1, output_version):
        seed_agent_version(fake_uc, ERA_4_9_9, version=version, scope="mvm")
    assert discover(engine, fake_uc)["versions_synced"] == output_version - 1
    if output_era is ERA_5_3_3:
        apply_5_3_3_registry_migration(fake_uc)
    seed_agent_version(fake_uc, output_era, version=output_version, scope="mvm", doc=output_doc)
    with Session(engine) as session:
        business = session.exec(select(Business)).one()
        parent = session.exec(select(ModelVersion).where(ModelVersion.version == 1)).one()
        run = Run(business_id=business.id, intent=Intent.VIBE_ITERATE.value, status="completed",
                  parameters_json=json.dumps({"dry_run": False}))
        session.add(run)
        session.flush()
        for input_id in INPUT_IDS:
            session.add(VibeInput(id=input_id, business_id=business.id, text=input_id, selected_for_run=True))
            session.flush()
            session.add(RunInputLink(run_id=run.id, input_id=input_id))
        session.commit()
        operation = VibeIterate()
        handle = SimpleNamespace(extra={
            "deployment_catalog": CAT, "business_name": agent_business_segment(BUSINESS), "parent_version_int": 1,
        })
        ctx = SimpleNamespace(parent_version_id=parent.id, business_id=business.id, run_id=run.id)
        model_json, info = operation._fetch_model_json(handle, ctx, fake_uc.ws, session)
        summary = _build_agent_outcomes(
            model_json, expected_version=info["expected_version"], fetched_version=info["fetched_version"],
            version_mismatch=info["version_mismatch"],
        )
        persist_agent_report(session, run.id, summary)
        if not info["version_mismatch"]:
            output = ModelVersion(business_id=business.id, version=output_version, scope="mvm", status="completed",
                                  deployment_status="draft", uc_catalog=CAT, base_version_id=parent.id)
            session.add(output)
            session.flush()
            ModelSyncService(session, fake_uc.ws, WAREHOUSE_ID).sync_model(
                output.id, CAT, agent_business_segment(BUSINESS), str(output_version), "mvm", run_id=run.id,
            )
            session.add(RunOperation(
                run_id=run.id, step_index=0, operation_name="vibe_iterate", params_json="{}",
                status="succeeded", output_version_id=output.id,
            ))
        session.commit()
        return run.id


def _outcomes(session: Session, run_id: str) -> dict[str, tuple[Optional[str], Optional[str]]]:
    return {
        link.input_id: (link.outcome_status, link.outcome_reason)
        for link in session.exec(select(RunInputLink).where(RunInputLink.run_id == run_id)).all()
    }


class TestRunReportAcrossTheChange:

    def test_a_5_3_3_run_reports_each_feedback_item_on_a_4_9_9_parent(self, engine, fake_uc):
        run_id = _run_with_output(engine, fake_uc, MODEL_SHAPES["agent_5_3_3_vibe"], ERA_5_3_3)
        with Session(engine) as session:
            report = build_run_report(session, session.get(Run, run_id))
            assert report.consume_note is None
            assert (report.has_agent_report, report.has_input_outcomes, report.version_mismatch) == (True, True, False)
            assert (report.lineage_base_version, report.lineage_head_at_write, report.lineage_stale) == (1, 1, False)
            assert report.unmatched_outcome_count == 0
            assert _outcomes(session, run_id) == {
                "item-add-email": ("applied", None),
                "item-rename-sales": ("deferred", "needs a decision on the order header"),
                "item-unlisted": ("not_reported", None),
            }
            assert session.get(RunAgentReport, run_id) is not None
            ensure_install_rows(session)
            assert_lakebase_metamodel_consistent(session, fake_uc)

    def test_a_run_that_found_a_newer_version_reports_the_head_it_wrote_against(self, engine, fake_uc):
        """``head_at_start`` and ``head_at_write`` differ when a version landed during the run:
        the report keeps the second, and the run is stale."""
        doc = MODEL_SHAPES["agent_5_3_3_vibe_stale"]
        assert (doc["lineage"]["head_at_start"], doc["lineage"]["head_at_write"]) == (1, 2)
        run_id = _run_with_output(engine, fake_uc, doc, ERA_5_3_3, output_version=3)
        with Session(engine) as session:
            report = build_run_report(session, session.get(Run, run_id))
            assert report.consume_note is None
            assert (report.lineage_base_version, report.lineage_head_at_write, report.lineage_stale) == (1, 2, True)
            assert _outcomes(session, run_id)["item-add-email"] == ("applied", None)
            ensure_install_rows(session)
            assert_lakebase_metamodel_consistent(session, fake_uc)

    def test_a_4_9_9_run_has_no_outcomes_and_the_report_says_so(self, engine, fake_uc):
        run_id = _run_with_output(engine, fake_uc, ERA_4_9_9.doc(2), ERA_4_9_9)
        with Session(engine) as session:
            report = build_run_report(session, session.get(Run, run_id))
            assert report.consume_note == "no_outcomes_reported"
            assert (report.has_agent_report, report.has_input_outcomes, report.version_mismatch) == (True, False, False)
            assert report.lineage_base_version is None
            assert set(_outcomes(session, run_id).values()) == {(None, None)}
            ensure_install_rows(session)
            assert_lakebase_metamodel_consistent(session, fake_uc)

    def test_a_5_3_3_base_model_file_is_not_taken_for_the_vibe_output(self, engine, fake_uc):
        """The file names its own output version in ``lineage``; one that is not the
        expected version fails the run's report and saves no version."""
        doc = ERA_5_3_3.doc(2)
        doc["lineage"]["output_version"] = "1"
        run_id = _run_with_output(engine, fake_uc, doc, ERA_5_3_3)
        with Session(engine) as session:
            report = build_run_report(session, session.get(Run, run_id))
            assert report.consume_note == "version_mismatch"
            assert (report.expected_version, report.fetched_version) == (2, 1)
            assert report.version_mismatch is True
            assert set(_outcomes(session, run_id).values()) == {(None, None)}
            assert [mv.version for mv in session.exec(select(ModelVersion)).all()] == [1]

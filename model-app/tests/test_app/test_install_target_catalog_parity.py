"""BE half of the install-target catalog contract (tests/fixtures/install_target_catalog_fixture.json).

The New Run form pre-fills its catalog from a version row with
``ui/lib/install-catalog.installTargetCatalog``, which mirrors
``core/_catalogs.resolve_install_target_catalog``. The UI half is
``ui/__tests__/install-catalog.test.ts``. A version installed in two catalogs is
also driven through the real lifecycle writers, so ``uc_catalog`` is what they
leave and not what a fixture claims.
"""

import json
import os
import sys
from pathlib import Path
from types import SimpleNamespace

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src"))

import pytest
from sqlmodel import Session

from vibe_modeling.backend.core._catalogs import resolve_install_target_catalog
from vibe_modeling.backend.db_models import Business, ModelVersion
from vibe_modeling.backend.services.operations import _version_lifecycle as lifecycle

FIXTURE = json.loads(
    (Path(__file__).parents[1] / "fixtures" / "install_target_catalog_fixture.json").read_text()
)
NO_REQUEST_CATALOG = SimpleNamespace(deployment_catalog="", catalog="")


@pytest.mark.parametrize("case", FIXTURE["cases"], ids=lambda c: c["name"])
def test_fixture_cases_equal_the_backend_resolver(case):
    mv = SimpleNamespace(**case["version"])
    assert resolve_install_target_catalog(NO_REQUEST_CATALOG, mv, None) == case["expected"]


def _version(s: Session, files_catalog: str) -> ModelVersion:
    b = Business(name="Acme", description="x", industry_alignment="Retail")
    s.add(b)
    s.commit()
    mv = ModelVersion(
        business_id=b.id, version=1, status="completed", scope="mvm",
        deployment_status="draft", uc_catalog="", files_catalog=files_catalog,
    )
    s.add(mv)
    s.commit()
    return mv


def test_a_version_installed_in_two_catalogs_targets_the_latest_open_install(engine):
    with Session(engine) as s:
        mv = _version(s, "home_cat")
        assert resolve_install_target_catalog(NO_REQUEST_CATALOG, mv, None) == "home_cat"
        lifecycle.mark_version_deployed(s, mv, "other_cat", run_id="r1")
        s.commit()
        assert resolve_install_target_catalog(NO_REQUEST_CATALOG, mv, None) == "other_cat"
        lifecycle.mark_version_deployed(s, mv, "third_cat", run_id="r2")
        s.commit()
        assert lifecycle.installed_catalogs(s, mv) == ["third_cat", "other_cat"]
        assert resolve_install_target_catalog(NO_REQUEST_CATALOG, mv, None) == "third_cat"


def test_uninstalling_every_catalog_returns_to_the_files_catalog(engine):
    with Session(engine) as s:
        mv = _version(s, "home_cat")
        lifecycle.mark_version_deployed(s, mv, "other_cat", run_id="r1")
        lifecycle.mark_version_uninstalled(s, mv, "other_cat")
        s.commit()
        assert mv.deployment_status == "uninstalled"
        assert mv.uc_catalog == "other_cat"
        assert resolve_install_target_catalog(NO_REQUEST_CATALOG, mv, None) == "home_cat"

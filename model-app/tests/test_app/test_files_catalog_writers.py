"""Every version is created knowing where its files are (``files_catalog``).

The opt-in ``require_files_catalog`` guard runs on the real creation-path
tests (vibe and generation finalize, import from volume, initial sync); this
module checks the guard itself and keeps a cheap source scan: every
``ModelVersion(...)`` constructor in the backend passes ``files_catalog``.
"""
from __future__ import annotations

import ast

import pytest
from sqlmodel import Session

from vibe_modeling.backend.core import volume_path_catalog
from vibe_modeling.backend.db_models import Business, ModelVersion

from ._lifecycle_fixtures import require_files_catalog  # noqa: F401
from ._source_scan import BACKEND, iter_files


def test_guard_flags_an_agent_row_without_files_catalog(engine, require_files_catalog):
    with Session(engine) as s:
        b = Business(name="Guard Co", description="d")
        s.add(b)
        s.flush()
        with pytest.raises(AssertionError, match="without files_catalog"):
            with require_files_catalog:
                s.add(ModelVersion(business_id=b.id, version=1, scope="ecm"))
                s.flush()


def test_guard_ignores_imports_and_rows_outside_the_block(engine, require_files_catalog):
    with Session(engine) as s:
        b = Business(name="Guard Co", description="d")
        s.add(b)
        s.flush()
        s.add(ModelVersion(business_id=b.id, version=1, scope="ecm"))
        s.flush()
        with require_files_catalog:
            s.add(ModelVersion(business_id=b.id, version=2, scope="ecm", import_source_path="/Volumes/a/b"))
            s.flush()
        assert require_files_catalog.checked == 1


def test_every_model_version_constructor_sets_files_catalog():
    offenders: list[str] = []
    for path, rel in iter_files(BACKEND):
        tree = ast.parse(path.read_text())
        for node in ast.walk(tree):
            if (
                isinstance(node, ast.Call)
                and isinstance(node.func, ast.Name)
                and node.func.id == "ModelVersion"
                and "files_catalog" not in {k.arg for k in node.keywords}
            ):
                offenders.append(f"{rel}:{node.lineno}")
    assert not offenders, "ModelVersion(...) without files_catalog: " + ", ".join(offenders)


@pytest.mark.parametrize(
    ("path", "catalog"),
    [
        ("/Volumes/cat_a/_metamodel/vol_root/x/model.json", "cat_a"),
        ("/Volumes/cat_b", "cat_b"),
        ("github://org/repo/x", None),
        ("", None),
        (None, None),
    ],
)
def test_volume_path_catalog(path, catalog):
    assert volume_path_catalog(path) == catalog

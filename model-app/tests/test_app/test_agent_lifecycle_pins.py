"""The vendored agent facts the version lifecycle is built on.

If an agent upgrade changes one of these, the promotion, replaced-version and
uninstall-then-install rules in ``services/operations/_version_lifecycle.py``
and ``dag_factories`` must be revisited:

1. ``install model`` ignores ``run_type``, so a Dry Run draft can be installed,
   and an install registers the version ``installed``.
2. Uninstall drops the schemas but keeps the registry rows and the files.
3. The agent's "latest installed" is a max over every registered installed
   version, so an older version installed later never becomes its head.
4. A scoped file installs over its own base when the base is the latest
   installed version there ("base_match", out-of-scope tables kept), which is
   why a version's base is not an occupant; into a catalog holding none of
   its schemas it installs fresh, which is why a catalog another version
   holds is uninstalled first.
"""
from __future__ import annotations

import pytest

from ._source_scan import agent_notebook_source


@pytest.fixture(scope="module")
def notebook() -> str:
    return agent_notebook_source()


def _function(source: str, name: str) -> str:
    start = source.index(f"def {name}(")
    end = source.find("\ndef ", start + 1)
    return source[start:end if end != -1 else None]


def test_install_ignores_run_type_and_registers_installed(notebook):
    dry = _function(notebook, "_compute_dry_run")
    assert '_generative = ("new base model", "vibe modeling of version", "shrink ecm", "enlarge mvm")' in dry
    assert "install model" not in dry.split("_generative")[1]
    assert 'deploy_status="installed"' in notebook


def test_uninstall_preserves_registry_rows_and_files(notebook):
    assert '"metamodel": "preserved", "files": "preserved"' in notebook


def test_latest_installed_is_a_max_over_registered_versions(notebook):
    latest = _function(notebook, "_latest_installed_version")
    assert "LOWER(deploy_status) = 'installed'" in latest
    assert "return str(max(numbers)) if numbers else None" in latest


def test_scoped_install_base_match_and_fresh_paths(notebook):
    pre = _function(notebook, "_scoped_install_precondition")
    assert 'return "base_match"' in pre
    assert "present = _model_schemas_present(spark, model, resolver)" in pre
    assert 'return "fresh"' in pre

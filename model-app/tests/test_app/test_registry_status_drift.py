"""Pin: the agent facts the app's registry ownership rests on.

The app seeds a version's ``_metamodel.business`` row with ``deploy_status =
'dry_run'`` (``import_metamodel_writer.write_metamodel``) and releases an
uninstalled version's rows to ``dry_run``
(``metamodel_registry.set_deploy_status``), so that neither owns schema
names. That holds only while the vendored agent:

- knows exactly the statuses ``installed`` and ``dry_run`` (nb 51578);
- skips ``dry_run`` rows in its ownership snapshot (nb 7926-7927);
- counts only NULL or ``installed`` rows as installed (nb 51855);
- keys a row by business in any case, the version, and the scope or a NULL
  scope (nb 51597-51602), the key the release uses;
- writes nothing to the registry when it uninstalls (``_run_undeploy_model``,
  nb 104796-105060), which is why the app releases the rows;
- reads a row's ``location`` as the folder its ``model.json`` is in (nb 53581).

An agent upgrade that changes any of these fails here.
"""
from __future__ import annotations

import re

import pytest

from vibe_modeling.backend.services import import_metamodel_writer, metamodel_registry
from vibe_modeling.backend.services.operations import uninstall

from ._source_scan import agent_notebook_source


@pytest.fixture(scope="module")
def nb() -> str:
    return agent_notebook_source()


def _function(source: str, name: str) -> str:
    """The source of ``def name(`` up to the next ``def`` at the same indent
    (for a top-level function, the next unindented line). A nested function
    can hold unindented lines inside triple-quoted strings."""
    match = re.search(rf"^([ \t]*)def {re.escape(name)}\(", source, re.MULTILINE)
    assert match, f"{name} is not in the vendored notebook"
    indent = match.group(1)
    start = source.index("\n", match.end()) + 1
    end = re.compile(rf"^{indent}def \w+\(" if indent else r"^\S", re.MULTILINE).search(source, start)
    return source[match.start():end.start() if end else len(source)]


def test_the_agents_statuses_are_the_apps(nb):
    statuses = re.search(r"^_METAMODEL_DEPLOY_STATUSES = (\(.*\))$", nb, re.MULTILINE)
    assert statuses and eval(statuses.group(1)) == ("installed", "dry_run")  # noqa: S307 - a literal tuple
    assert metamodel_registry.DEPLOY_STATUSES == ("installed", "dry_run")
    # The seed and the uninstall release write the one shared constant.
    assert import_metamodel_writer.DRY_RUN_STATUS is uninstall.DRY_RUN_STATUS is metamodel_registry.DRY_RUN_STATUS


def test_the_ownership_snapshot_skips_dry_run_rows(nb):
    assert '"status": str(r.get("deploy_status") or "").strip().lower()' in nb
    assert re.search(r'if run\["status"\] == "dry_run":\n\s+continue', nb)


def test_installed_means_null_or_installed(nb):
    body = _function(nb, "_latest_installed_version")
    assert "AND (deploy_status IS NULL OR LOWER(deploy_status) = 'installed')" in body


def test_the_registry_key_matches_the_release(nb):
    assert "OR model_scope IS NULL)" in _function(nb, "_metamodel_scope_sql")
    key = _function(nb, "_metamodel_key_sql")
    assert "LOWER(business) = LOWER(" in key and "AND version = " in key
    statement = metamodel_registry.deploy_status_statement("cat", "acme", 1, "mvm", "dry_run")
    assert "LOWER(business) = LOWER('Acme')" in statement
    assert "version = '1'" in statement
    assert "(model_scope = 'mvm' OR model_scope IS NULL)" in statement


def test_the_agents_uninstall_writes_no_status(nb):
    body = _function(nb, "_run_undeploy_model")
    # The whole function: it drops the domain schemas and then ``_metrics``.
    assert "DROP DATABASE" in body and "_metrics" in body
    assert "deploy_status" not in body
    assert "_set_metamodel_deploy_status" not in body


def test_a_rows_location_is_its_folder(nb):
    body = _function(nb, "_run_lineage_read_model")
    assert "f\"{str(location).rstrip('/')}/model.json\"" in body

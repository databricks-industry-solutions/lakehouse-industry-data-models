"""BE half of the agent widget-options contract (tests/fixtures/agent_widget_options.json).

The fixture holds the agent's dropdown values for the widgets the New Run form
sets. This file pins it to the vendored notebook, to the mock agent and to the
backend's own copies of those lists; the FE half is ui/__tests__/run-options.test.ts.
"""

from __future__ import annotations

import ast
import json
import re
from pathlib import Path

import pytest

from vibe_modeling.backend.core._vibe_scope import MIN_AGENT_MARKER_FOR_SCOPE
from vibe_modeling.backend.models import BOOLEAN_FORMATS, ORG_DIVISIONS_PRESETS
from vibe_modeling.backend.services.operations import _install_conventions

from ._source_scan import agent_notebook_source

_REPO = Path(__file__).resolve().parents[2]
_MOCK_AGENT = _REPO / "tests" / "fixtures" / "mock_vibe_agent" / "mock_vibe_agent.py"
FIXTURE = json.loads((_REPO / "tests" / "fixtures" / "agent_widget_options.json").read_text())
OPTIONS: dict[str, list[str]] = FIXTURE["options"]

# dbutils.widgets.dropdown("<name>", "<default>", [<choices>], ...); the choice
# strings never contain "]", so the lazy list match is safe.
_DROPDOWN_RE = re.compile(
    r'dbutils\.widgets\.dropdown\(\s*"(\w+)"\s*,\s*"[^"]*"\s*,\s*(\[.*?\])', re.DOTALL
)


def _dropdowns(source: str) -> dict[str, list[str]]:
    return {name: ast.literal_eval(choices) for name, choices in _DROPDOWN_RE.findall(source)}


@pytest.fixture(scope="module")
def notebook_dropdowns() -> dict[str, list[str]]:
    return _dropdowns(agent_notebook_source())


@pytest.mark.parametrize("widget", sorted(OPTIONS))
def test_fixture_equals_the_vendored_agent(widget, notebook_dropdowns):
    assert notebook_dropdowns.get(widget) == OPTIONS[widget]


@pytest.mark.parametrize("widget", sorted(OPTIONS))
def test_mock_agent_offers_the_same_values(widget):
    mock = _dropdowns(_MOCK_AGENT.read_text())
    assert mock.get(widget) == OPTIONS[widget]


def test_form_omissions_are_agent_values():
    for widget, omitted in FIXTURE["form_omits"].items():
        assert set(omitted) <= set(OPTIONS[widget])


def test_backend_lists_match_the_fixture():
    assert list(BOOLEAN_FORMATS) == OPTIONS["boolean_format"]
    assert list(ORG_DIVISIONS_PRESETS) == OPTIONS["org_divisions"]
    assert list(_install_conventions._NAMING_CHOICES) == OPTIONS["naming_convention"]
    assert list(_install_conventions._TABLE_ID_TYPES) == OPTIONS["table_id_type"]


def test_min_agent_marker_matches_the_fixture():
    assert MIN_AGENT_MARKER_FOR_SCOPE == FIXTURE["min_agent_marker_for_scope"]


# Locked on a vibe although the agent's MODEL_CONVENTION_KEYS does not list
# them: on a live Dry Run (T2 re-check, PR-8 check 3) the agent ignored an edited
# tag_suffix and schema_suffix and wrote the base's values to model.json.
IGNORED_IN_PRACTICE = {"schema_suffix", "tag_suffix"}


def test_vibe_lock_set_is_the_agents_model_convention_keys():
    """The fields the run form locks on a vibe are the agent's
    ``MODEL_CONVENTION_KEYS`` (the keys ``_vov_base_conventions_win`` sets to
    the base's value), minus ``table_suffix``, which the form has no field
    for, plus ``schema_suffix`` and ``tag_suffix``. Those two are outside
    ``MODEL_CONVENTION_KEYS`` but locked because the agent ignores them in
    practice. When the agent's list changes, so must the lock set."""
    match = re.search(r"^MODEL_CONVENTION_KEYS = (\[.*?\])", agent_notebook_source(), re.M | re.S)
    assert match, "MODEL_CONVENTION_KEYS not found in the vendored notebook"
    agent_keys = set(ast.literal_eval(match.group(1)))
    table = _install_conventions.RUN_CONVENTION_FILE_KEYS
    locked_keys = {table[f] for f in _install_conventions.VIBE_LOCKED_FIELDS}
    assert locked_keys == (agent_keys - {"table_suffix"}) | IGNORED_IN_PRACTICE
    assert "table_suffix" in agent_keys
    assert IGNORED_IN_PRACTICE.isdisjoint(agent_keys)

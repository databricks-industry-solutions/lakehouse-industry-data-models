import importlib.util
import json
import os

import pytest

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SCRIPT = os.path.join(REPO, "scripts", "refactor_notebook_layout.py")
NB = os.path.join(REPO, "agent", "dbx_vibe_modelling_agent.ipynb")


def _load():
    spec = importlib.util.spec_from_file_location("refactor_notebook_layout_under_test", SCRIPT)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def _nb(md_source, agent="7.3.1", release="2.4.6"):
    code = (
        f'__AGENT_VERSION__ = "{agent}"  # alias=agent-version-global\n'
        f'__RELEASE_VERSION__ = "{release}"  # alias=release-version-public\n'
        "def helper_one():\n"
        "    return 1\n"
    )
    cells = []
    if md_source is not None:
        cells.append({"cell_type": "markdown", "metadata": {"k": "v"}, "source": md_source})
    cells.append({"cell_type": "code", "metadata": {}, "outputs": [], "execution_count": None, "source": [code]})
    return {"nbformat": 4, "nbformat_minor": 5, "metadata": {}, "cells": cells}


def test_cell0_is_carried_over_verbatim():
    md = ["# Custom Title\n", "\n", "Current widget table with `vibe_scope`.\n"]
    out = _load().refactor(_nb(md))
    assert out["cells"][0]["cell_type"] == "markdown"
    assert out["cells"][0]["source"] == md
    assert "generate_samples" not in "".join(out["cells"][0]["source"])


def test_versions_come_from_the_source_notebook():
    out = _load().refactor(_nb(["# t\n"], agent="7.3.1", release="2.4.6"))
    body = "".join(out["cells"][1]["source"])
    assert '__AGENT_VERSION__ = "7.3.1"' in body
    assert '__RELEASE_VERSION__ = "2.4.6"' in body


def test_missing_leading_markdown_refuses_instead_of_inventing_cell0():
    with pytest.raises(SystemExit):
        _load().refactor(_nb(None))


def test_real_notebook_round_trip_keeps_cell0_and_version():
    nb = json.load(open(NB))
    out = _load().refactor(nb)
    assert out["cells"][0]["source"] == nb["cells"][0]["source"]
    src_ver = next(
        ln for c in nb["cells"] if c["cell_type"] == "code"
        for ln in "".join(c["source"]).splitlines() if ln.strip().startswith("__AGENT_VERSION__")
    ).strip()
    assert src_ver.split("#")[0].strip() in "".join(out["cells"][1]["source"])


def test_script_has_no_embedded_notebook_cell0_copy():
    text = open(SCRIPT).read()
    assert "# Vibe Modelling Agent" not in text
    assert "WIDGET_DOCS_MD" not in text

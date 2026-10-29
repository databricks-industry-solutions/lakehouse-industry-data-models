"""The import modules load on their own in a fresh interpreter: no cycle
through ``services.operations`` (``install`` imports ``scope_prefix``)."""
from __future__ import annotations

import subprocess
import sys
from pathlib import Path

import pytest

SRC = Path(__file__).resolve().parents[2] / "src" / "app" / "src"


@pytest.mark.parametrize("module", [
    "vibe_modeling.backend.services.scope_prefix",
    "vibe_modeling.backend.services.dialog_import",
    "vibe_modeling.backend.services.industry_download",
    "vibe_modeling.backend.services.industry_kickstart",
])
def test_cold_import(module):
    out = subprocess.run(
        [sys.executable, "-c", f"import {module}"],
        cwd=SRC, capture_output=True, text=True, timeout=120,
        env={"PYTHONPATH": str(SRC), "PATH": "/usr/bin:/bin"},
    )
    assert out.returncode == 0, out.stderr[-2000:]

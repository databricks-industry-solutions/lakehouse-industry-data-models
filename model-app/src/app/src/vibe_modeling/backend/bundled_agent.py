"""Resolve the vibe-modelling-agent notebook that ships alongside this app.

The notebook is copied into `src/app/vendored/agent/` at repo build time and
force-included into the wheel under `vibe_modeling/vendored/agent/` via the
`[tool.hatch.build.targets.wheel.force-include]` entry in pyproject.toml.

At runtime we look it up through `importlib.resources` against the installed
`vibe_modeling` package. For in-tree dev (editable install, pytest), we also
fall back to the repo-relative `src/app/vendored/agent/` path.
"""

from __future__ import annotations

import json
import logging
from dataclasses import dataclass
from importlib import resources
from pathlib import Path
from typing import Optional

logger = logging.getLogger(__name__)


@dataclass(frozen=True)
class BundledAgent:
    """A vendored agent notebook and its manifest metadata.

    ``pinned_tag`` is the agent release (``__RELEASE_VERSION__``, e.g.
    ``v0.8.0``) and ``agent_version`` the agent-logic marker
    (``__AGENT_VERSION__``, e.g. ``5.3.3``), both read from ``VERSIONS.json``
    (``pinned_tag`` and ``pinned_agent_version``). The manifest is the one
    source of the bundled marker; a contract test ties it to
    ``core._defaults.SUPPORTED_AGENT_MARKER``.
    """

    file_path: Path
    file_name: str
    pinned_tag: str
    supported_tags: list[str]
    agent_version: str


def _candidate_roots() -> list[Path]:
    """Return plausible locations of the vendored/agent/ directory.

    We look in two places so both installed wheels and editable in-tree
    checkouts (what tests and `apx dev` run against) resolve correctly.
    """
    roots: list[Path] = []
    try:
        pkg_root = resources.files("vibe_modeling")
        # `resources.files` returns a Traversable; Path wrapping works for
        # file-system-backed packages which is the only case we support.
        roots.append(Path(str(pkg_root)) / "vendored" / "agent")
    except (ModuleNotFoundError, TypeError, AttributeError):
        pass
    # src/app/vendored/agent/ relative to the backend source tree —
    # backend/bundled_agent.py sits at src/app/src/vibe_modeling/backend/.
    here = Path(__file__).resolve()
    roots.append(here.parents[3] / "vendored" / "agent")
    return roots


def vendored_agent_file(name: str) -> Optional[Path]:
    """A file shipped next to the vendored notebook, or None if absent."""
    for root in _candidate_roots():
        if (root / name).is_file():
            return root / name
    return None


def resolve_bundled_agent() -> Optional[BundledAgent]:
    """Locate the vendored notebook + manifest, or return None if absent."""
    for root in _candidate_roots():
        manifest = root / "VERSIONS.json"
        if not manifest.is_file():
            continue
        try:
            data = json.loads(manifest.read_text())
        except (OSError, json.JSONDecodeError) as e:
            logger.warning("Could not parse %s: %s", manifest, e)
            continue
        pinned = str(data.get("pinned_tag", "")).strip()
        supported = [str(t) for t in data.get("supported_tags", []) if t]
        marker = str(data.get("pinned_agent_version", "")).strip().lstrip("vV")
        if not pinned:
            continue
        notebook = _find_notebook(root, pinned, str(data.get("notebook_file", "")).strip())
        if notebook is None:
            continue
        return BundledAgent(
            file_path=notebook,
            file_name=notebook.name,
            pinned_tag=pinned,
            supported_tags=supported,
            agent_version=marker,
        )
    return None


def _find_notebook(root: Path, pinned_tag: str, notebook_file: str = "") -> Optional[Path]:
    # Prefer the manifest's file name, then the exact tagged filename; fall
    # back to any v-prefixed notebook so a half-refreshed vendor dir still
    # resolves.
    if notebook_file and (root / notebook_file).is_file():
        return root / notebook_file
    for ext in (".ipynb", ".py"):
        exact = root / f"vibe_modelling_agent_{pinned_tag}{ext}"
        if exact.is_file():
            return exact
    for ext in (".ipynb", ".py"):
        matches = sorted(root.glob(f"vibe_modelling_agent_v*{ext}"))
        if matches:
            return matches[-1]
    return None

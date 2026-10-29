"""Source scanning shared by the drift-lock tests.

The drift locks grep the app's own sources for banned shapes. They all walk
the same trees, skip the same caches and report ``<rel>:<line>`` offenders,
so the walk lives here once. :func:`agent_notebook_source` is the vendored
agent's code for the tests that pin agent facts.
"""

from __future__ import annotations

import json
from collections.abc import Iterable, Iterator
from functools import lru_cache
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
BACKEND = REPO / "src/app/src/vibe_modeling/backend"
INSTALL = REPO / "install"
VENDORED = REPO / "src/app/vendored"

_SKIP_PARTS = {"__pycache__", "node_modules", ".pytest_cache"}


def iter_files(
    root: Path,
    suffixes: Iterable[str] | None = (".py",),
    exempt: Iterable[str] = (),
) -> Iterator[tuple[Path, str]]:
    """Yield ``(path, posix path relative to root)`` for every file under
    ``root``, sorted. ``suffixes=None`` yields every file; ``exempt`` holds
    relative paths to skip."""
    wanted = None if suffixes is None else set(suffixes)
    skip = set(exempt)
    for path in sorted(root.rglob("*")):
        if not path.is_file() or _SKIP_PARTS.intersection(path.parts):
            continue
        rel = path.relative_to(root).as_posix()
        if rel in skip or (wanted is not None and path.suffix not in wanted):
            continue
        yield path, rel


def read_text(path: Path) -> str | None:
    """The file as text, or ``None`` for a binary file."""
    data = path.read_bytes()
    if b"\0" in data[:8192]:
        return None
    return data.decode("utf-8", errors="replace")


def line_of(text: str, offset: int) -> int:
    return text.count("\n", 0, offset) + 1


def is_comment(line: str) -> bool:
    return line.lstrip().startswith("#")


@lru_cache(maxsize=1)
def agent_notebook_source() -> str:
    """The vendored agent notebook's cell sources (the file ``VERSIONS.json``
    names), one cell per line block."""
    agent = VENDORED / "agent"
    versions = json.loads((agent / "VERSIONS.json").read_text())
    nb = json.loads((agent / versions["notebook_file"]).read_text())
    return "\n".join("".join(cell.get("source", [])) for cell in nb["cells"])

"""Drift-lock: SQL statements run only through core/_sql.

``core/_sql`` polls a statement to a terminal state within the caller's
bound, cancels it on timeout and raises ``SqlStatementError`` on every
failure, so a failed or still-running query never reads as zero rows. A
direct ``statement_execution.execute_statement(`` call elsewhere brings back
a local helper with its own failure rules. This test fails on one anywhere
in the backend, the vendored job code, the installer or the scripts.

Exempt:

- ``backend/core/_sql.py``: the one caller.
- ``vendored/assessment/assess_domain.py``: the assessment job's notebook. It
  runs on a job cluster as a standalone file and cannot import the app
  package; it has its own bounded poll loop.
"""

from __future__ import annotations

import re

from ._source_scan import BACKEND, INSTALL, REPO, VENDORED, is_comment, iter_files, line_of

SCRIPTS = REPO / "scripts"

_CALL = re.compile(r"statement_execution\s*\.\s*execute_statement\s*\(")

_ROOTS = {
    "backend": (BACKEND, {"core/_sql.py"}),
    "vendored": (VENDORED, {"assessment/assess_domain.py"}),
    "install": (INSTALL, set()),
    "scripts": (SCRIPTS, set()),
}


def _offenders(text: str, rel: str) -> list[str]:
    lines = text.splitlines()
    out = []
    for m in _CALL.finditer(text):
        n = line_of(text, m.start())
        if not is_comment(lines[n - 1]):
            out.append(f"{rel}:{n}: {lines[n - 1].strip()}")
    return out


def test_no_direct_statement_execution_outside_core_sql():
    offenders: list[str] = []
    for name, (root, exempt) in _ROOTS.items():
        for path, rel in iter_files(root, exempt=exempt):
            offenders += _offenders(path.read_text(), f"{name}/{rel}")
    assert not offenders, (
        "Direct statement_execution.execute_statement( found. Use core/_sql "
        "rows / scalar / run and state the call site's failure choice:\n"
        + "\n".join(offenders)
    )


def test_exemptions_still_exist():
    """A stale exemption would hide nothing; drop it with the file."""
    for name, (root, exempt) in _ROOTS.items():
        for rel in exempt:
            assert (root / rel).is_file(), f"{name}/{rel} is exempt but gone"
            assert _CALL.search((root / rel).read_text()), f"{name}/{rel} no longer needs its exemption"


def test_the_scan_catches_a_call_split_across_lines():
    text = "x = 1\nresult = ws.statement_execution.execute_statement(\n    statement='SELECT 1')\n"
    assert _offenders(text, "probe.py") == ["probe.py:2: result = ws.statement_execution.execute_statement("]
    assert _offenders("# ws.statement_execution.execute_statement(\n", "p.py") == []

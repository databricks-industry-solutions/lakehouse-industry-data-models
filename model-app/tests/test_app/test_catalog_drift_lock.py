"""Drift-lock: no cross-concern inline catalog fallback outside core/_catalogs.

Track 4 collapsed every catalog-shaped concern onto the three resolvers in
``core/_catalogs.py``. The banned pattern is a CROSS-CONCERN fallback: code
that reaches for one concern's value and, when empty, silently falls back to
another concern's source (typically the installation ``deployment_catalog``).
That is the exact bug class the resolvers exist to kill, so any re-introduction
must fail this test.

Allowed (NOT flagged):
- ``x.deployment_catalog or ""`` / ``or None`` - an empty-default read, not a
  cross-concern fallback (e.g. the RunIn alias normalizer, concern-B probes).
- ``mv.uc_catalog or ""`` - concern B (install catalog) has no resolver by
  design; ``""`` means draft.
- ``params.deployment_catalog or <run-scoped>`` - params are the run's truth.

Banned (flagged), in both single-line and multi-line ``if not catalog:`` forms:
- ``<anything> or <cfg-obj>.deployment_catalog``
- ``<cfg-obj>.deployment_catalog or <non-empty>``
- ``<x>.uc_catalog or <non-empty>``
where ``<cfg-obj>`` is one of agent_config / agent_cfg / cfg / config.
"""

from __future__ import annotations

import re

from ._source_scan import BACKEND as _BACKEND
from ._source_scan import is_comment, iter_files

# Files exempt from the ban: the resolver module itself is the one legitimate
# home of the fallback logic.
_EXEMPT = {"core/_catalogs.py"}

_CFG = r"(?:agent_config|agent_cfg|cfg|config)"

# X or <cfg-obj>.deployment_catalog
_RHS_CFG_FALLBACK = re.compile(rf"\bor\s+{_CFG}\.deployment_catalog\b")
# <cfg-obj>.deployment_catalog or <something-other-than a string literal / None>
_LHS_CFG_FALLBACK = re.compile(
    rf"\b{_CFG}\.deployment_catalog\s+or\s+(?![\"']|None\b)"
)
# <x>.uc_catalog or <something-other-than a string literal / None>
_UC_CATALOG_FALLBACK = re.compile(
    r"\.uc_catalog\s+or\s+(?![\"']|None\b)"
)

# Multi-line: `if not <ident>:` then within a few lines `<ident> = <cfg>.deployment_catalog`
_IF_NOT = re.compile(r"^\s*if\s+not\s+([A-Za-z_][A-Za-z0-9_]*)\s*:\s*$")
_ASSIGN_CFG = re.compile(rf"=\s*{_CFG}\.deployment_catalog\b")


def test_no_single_line_cross_concern_catalog_fallback():
    offenders: list[str] = []
    for path, rel in iter_files(_BACKEND, exempt=_EXEMPT):
        for i, line in enumerate(path.read_text().splitlines(), start=1):
            if is_comment(line):
                continue
            if (
                _RHS_CFG_FALLBACK.search(line)
                or _LHS_CFG_FALLBACK.search(line)
                or _UC_CATALOG_FALLBACK.search(line)
            ):
                offenders.append(f"{rel}:{i}: {line.strip()}")
    assert not offenders, (
        "Cross-concern inline catalog fallback found outside core/_catalogs.py. "
        "Use resolve_metamodel_catalog / resolve_run_target_catalog / "
        "resolve_version_volume_catalog instead:\n" + "\n".join(offenders)
    )


def test_no_multiline_if_not_catalog_fallback():
    offenders: list[str] = []
    for path, rel in iter_files(_BACKEND, exempt=_EXEMPT):
        lines = path.read_text().splitlines()
        for i, line in enumerate(lines):
            m = _IF_NOT.match(line)
            if not m:
                continue
            var = m.group(1)
            # Look at the next few lines for `<var> = <cfg>.deployment_catalog`
            for j in range(i + 1, min(i + 5, len(lines))):
                nxt = lines[j]
                if is_comment(nxt):
                    continue
                if re.search(rf"\b{re.escape(var)}\s*=\s*", nxt) and _ASSIGN_CFG.search(nxt):
                    offenders.append(f"{rel}:{j + 1}: {nxt.strip()}")
    assert not offenders, (
        "Multi-line `if not <catalog>:` cross-concern fallback found outside "
        "core/_catalogs.py. Use a resolver instead:\n" + "\n".join(offenders)
    )


def test_resolvers_are_the_only_home():
    # Sanity: the exempt module actually contains the fallback logic, so the
    # drift-lock isn't vacuously green because everything was deleted.
    src = (_BACKEND / "core/_catalogs.py").read_text()
    assert "uc_catalog" in src and "resolve_metamodel_catalog" in src

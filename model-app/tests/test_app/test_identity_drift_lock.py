"""Drift-lock: caller identity is read only through core/_identity.

Header precedence ("email first, then preferred username") is decided in one
place, ``core/_identity.py``. Any direct read of the identity header fields
elsewhere under ``backend/`` re-introduces a parallel identity expression,
which is how preferences ended up keyed on a different identity than RBAC and
the vibe-input actor. Such a read must fail this test.

Banned (flagged) outside ``core/_identity.py`` and ``core/_headers.py``:
- ``<anything>.user_email`` (no SDK user object exposes it, so any receiver
  counts);
- ``headers.user_name`` (``user_name`` alone is also an SDK user attribute,
  so only the ``headers`` receiver is flagged);
- ``getattr(headers, "user_email" | "user_name", ...)``, matched against the
  whole file so a call split across lines is still caught.

Banned outside ``core/_headers.py`` (the only module that binds the headers):
the literals ``X-Forwarded-Email`` and ``X-Forwarded-Preferred-Username``, in
any case, which would let a route read the raw header and bypass both the
trust gate and the precedence rule.

SDK user objects (``ws.current_user.me().user_name``, ``me.user_name``) are
not headers and are not matched.
"""

from __future__ import annotations

import re

from ._source_scan import BACKEND as _BACKEND
from ._source_scan import is_comment, iter_files, line_of

_FIELD_EXEMPT = {"core/_identity.py", "core/_headers.py"}
_LITERAL_EXEMPT = {"core/_headers.py"}

_EMAIL_FIELD = re.compile(r"\.user_email\b")
_HEADERS_USER_NAME = re.compile(r"\bheaders\.user_name\b")
_GETATTR_READ = re.compile(
    r"getattr\(\s*headers\s*,\s*[\"']user_(?:email|name)", re.S
)
_HEADER_LITERAL = re.compile(
    r"x-forwarded-(?:email|preferred-username)\b", re.I
)


def test_no_direct_identity_field_reads_outside_identity_module():
    offenders: list[str] = []
    for path, rel in iter_files(_BACKEND, exempt=_FIELD_EXEMPT):
        text = path.read_text()
        for i, line in enumerate(text.splitlines(), start=1):
            if is_comment(line):
                continue
            if _EMAIL_FIELD.search(line) or _HEADERS_USER_NAME.search(line):
                offenders.append(f"{rel}:{i}: {line.strip()}")
        for m in _GETATTR_READ.finditer(text):
            offenders.append(f"{rel}:{line_of(text, m.start())}: {m.group(0)!r}")
    assert not offenders, (
        "Direct identity-header read found outside core/_identity.py. Use "
        "current_user_identity / actor_label / Dependencies.UserIdentity / "
        "current_user_profile instead:\n"
        + "\n".join(offenders)
    )


def test_no_forwarded_identity_header_literals_outside_headers_module():
    offenders: list[str] = []
    for path, rel in iter_files(_BACKEND, exempt=_LITERAL_EXEMPT):
        text = path.read_text()
        for m in _HEADER_LITERAL.finditer(text):
            offenders.append(f"{rel}:{line_of(text, m.start())}: {m.group(0)}")
    assert not offenders, (
        "Forwarded identity header literal found outside core/_headers.py. "
        "Read identity through core/_identity.py instead:\n" + "\n".join(offenders)
    )


def test_patterns_match_the_banned_shapes():
    assert _EMAIL_FIELD.search("x = headers.user_email")
    assert _EMAIL_FIELD.search("x = hdrs.user_email or y")
    assert _HEADERS_USER_NAME.search("x = headers.user_name or 'anon'")
    assert _GETATTR_READ.search('getattr(headers, "user_name", None)')
    assert _GETATTR_READ.search("getattr( headers , 'user_email')")
    assert _GETATTR_READ.search('getattr(\n    headers,\n    "user_email",\n)')
    assert _HEADER_LITERAL.search('request.headers.get("X-Forwarded-Email")')
    assert _HEADER_LITERAL.search("'x-forwarded-preferred-username'")
    assert not _HEADERS_USER_NAME.search("ws.current_user.me().user_name")
    assert not _HEADERS_USER_NAME.search('me.user_name or ""')
    assert not _GETATTR_READ.search('getattr(me, "user_name", None)')
    assert not _HEADER_LITERAL.search('"X-Forwarded-Access-Token"')


def test_identity_module_is_the_only_home():
    src = (_BACKEND / "core/_identity.py").read_text()
    assert "headers.user_email" in src and "def current_user_identity" in src
    headers_src = (_BACKEND / "core/_headers.py").read_text()
    assert "X-Forwarded-Email" in headers_src

"""v5.1.5: SQL string literals keep their single quotes.

Spark SQL does not read '' inside a single-quoted literal as an escaped quote: 'a''b' is two adjacent
literals that concatenate to "ab" (probed live on the SQL warehouse 2026-10-09: SELECT 'a''b' -> ab,
SELECT 'a\\'b' -> a'b). Every writer that escaped with .replace("'", "''") silently deleted the
quotes. Live evidence: vs514 retail v1 stored model_conventions.timestamp_format as
yyyy-MM-ddTHH:mm:ss.SSSXXX (from yyyy-MM-dd'T'HH:mm:ss.SSSXXX) in _metamodel.business, and the
'vibe modeling of version' run 1079936862964808 then treated that corrupted value as the base convention.
"""
import json
import re
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent))
import conftest  # noqa: F401,E402
import agent_helpers as ah  # noqa: E402
from notebook_source_util import notebook_concat_source  # noqa: E402

REPO = Path(__file__).resolve().parents[3]
INSTALLER = REPO / "model-installer" / "data-model-installer.ipynb"
TRICKY = ["yyyy-MM-dd'T'HH:mm:ss.SSSXXX", "customer's order", "o''brien", "back\\slash", "end\\", "'", "plain"]


def spark_literal(sql_text):
    """Decode a run of adjacent single-quoted literals the way Spark SQL parses them."""
    out, i, n = [], 0, len(sql_text)
    while i < n:
        if sql_text[i] != "'":
            raise AssertionError(f"not a literal at {i}: {sql_text[i:i + 20]!r}")
        i += 1
        while i < n and sql_text[i] != "'":
            if sql_text[i] == "\\" and i + 1 < n:
                out.append(sql_text[i + 1])
                i += 2
                continue
            out.append(sql_text[i])
            i += 1
        i += 1
    return "".join(out)


@pytest.mark.parametrize("value", TRICKY)
def test_the_shared_escape_round_trips_through_spark_literal_parsing(value):
    assert spark_literal("'" + ah._sql_string_escape(value) + "'") == value


def test_quote_doubling_is_what_lost_the_quotes():
    assert spark_literal("'" + TRICKY[0].replace("'", "''") + "'") == "yyyy-MM-ddTHH:mm:ss.SSSXXX"


def test_the_business_row_insert_keeps_the_timestamp_format_and_apostrophes():
    conventions = json.dumps({"timestamp_format": "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"})
    sql = ah.VibeWriter._build_insert_sql("cat._metamodel.business", {
        "business": "Joe's Retail", "version": "1", "model_scope": "mvm", "description": "the customer's store",
        "model_conventions": conventions, "completed_percent": 0.0})
    literals = re.findall(r"'(?:[^'\\]|\\.)*'", sql)
    decoded = [spark_literal(x) for x in literals]
    assert "Joe's Retail" in decoded and "the customer's store" in decoded
    assert json.loads(next(d for d in decoded if d.startswith("{")))["timestamp_format"] == "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"


def test_the_scope_in_list_keeps_a_quoted_name():
    sql = ah._vibe_scope_sql_in(["o'brien", "plain"])
    assert [spark_literal(x) for x in re.findall(r"'(?:[^'\\]|\\.)*'", sql)] == ["o'brien", "plain"]


def test_no_quote_doubling_escape_is_left_in_the_agent_or_the_installer():
    nb = json.loads(INSTALLER.read_text(encoding="utf-8"))
    installer = "\n".join("".join(c.get("source", [])) for c in nb["cells"] if c.get("cell_type") == "code")
    for name, src in (("agent", notebook_concat_source()), ("installer", installer)):
        hits = [l.strip() for l in src.split("\n") if re.search(r"""replace\(\s*"'"\s*,\s*"''"\s*\)""", l)]
        assert hits == [], f"{name} still escapes quotes by doubling them: {hits[:5]}"

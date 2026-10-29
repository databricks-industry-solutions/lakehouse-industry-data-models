"""Reading the JSON-object text columns (``RunOperation.params_json``,
``rollback_state_json``): a missing, malformed or non-object value reads as
an empty dict."""
from __future__ import annotations

import json
from typing import Optional


def json_object(text: Optional[str]) -> dict:
    try:
        value = json.loads(text or "{}")
    except (TypeError, ValueError):
        return {}
    return value if isinstance(value, dict) else {}

"""The Advanced Options a vibe of a base version starts from (``getRunDefaults``).

One rule, :func:`run_defaults`, for every field the run form pre-fills on
Vibe Modeling and Vibe ECM + MVM. The run time budget and Business Domains are
not pre-filled; the form keeps its own values for them.

- The fields a vibe locks (``VIBE_LOCKED_FIELDS``): the base ``model.json``'s
  ``model.model_conventions``, which is what the agent compares with
  (``_vov_base_conventions_win``, nb 52132-52149). A field the base sets is
  locked on every vibe; a field it leaves empty is locked only on a Some
  domains vibe (``exact``). ``ALWAYS_LOCKED_FIELDS`` are locked on every
  vibe, an empty base value included: ``boolean_format``, because the agent
  canonicalizes the base value first, so an empty or unknown one becomes
  "Boolean (True/False)" (:func:`agent_boolean_label`); ``schema_suffix`` and
  ``tag_suffix``, because the agent ignores an edit of them (see
  ``RUN_CONVENTION_FILE_KEYS``). When the file cannot
  be read, or holds a value the app cannot send, the value is unknown and the
  field is locked: the agent still keeps the base's own value. These fields never come from the producing run's widgets:
  on a vibed base those are the values the agent overrode.
- The other options (catalog prefix and suffix, organization divisions,
  housekeeping and history columns): the producing run's widgets, else the
  app default.
"""

from __future__ import annotations

from typing import Any, Optional

from ..models import RunDefaultFieldOut, RunDefaultsOut
from .dispatched_widgets import generation_widgets_for_version
from .operations._generation_common import (
    DEFAULT_BOOLEAN_FORMAT,
    DEFAULT_DATE_FORMAT,
    DEFAULT_HISTORY_TRACKING_COLUMNS,
    DEFAULT_HOUSEKEEPING_COLUMNS,
    DEFAULT_NAMING_CONVENTION,
    DEFAULT_ORG_DIVISIONS,
    DEFAULT_PRIMARY_KEY_SUFFIX,
    DEFAULT_TABLE_ID_TYPE,
    DEFAULT_TAG_PREFIX,
    DEFAULT_TIMESTAMP_FORMAT,
)
from .operations._install_conventions import (
    RUN_CONVENTION_FILE_KEYS,
    VIBE_LOCKED_FIELDS,
    run_field_file_value,
)
from .version_files import read_version_conventions

# The app's own value for each pre-filled field when nothing else sets it
# (the defaults ``build_generation_widgets`` sends).
FIELD_DEFAULTS: dict[str, str] = {
    "naming_convention": DEFAULT_NAMING_CONVENTION,
    "primary_key_suffix": DEFAULT_PRIMARY_KEY_SUFFIX,
    "schema_prefix": "",
    "schema_suffix": "",
    "tag_prefix": DEFAULT_TAG_PREFIX,
    "tag_suffix": "",
    "table_id_type": DEFAULT_TABLE_ID_TYPE,
    "boolean_format": DEFAULT_BOOLEAN_FORMAT,
    "date_format": DEFAULT_DATE_FORMAT,
    "timestamp_format": DEFAULT_TIMESTAMP_FORMAT,
    "classification_levels": "",
    "catalog_prefix": "",
    "catalog_suffix": "",
    "org_divisions": DEFAULT_ORG_DIVISIONS,
    "housekeeping_columns": DEFAULT_HOUSEKEEPING_COLUMNS,
    "history_tracking_columns": DEFAULT_HISTORY_TRACKING_COLUMNS,
}

# Locked fields the form shows as a list of values; an empty base value
# leaves them on the app default rather than blank.
_LIST_FIELDS = frozenset(
    {"naming_convention", "table_id_type", "boolean_format", "date_format", "timestamp_format"}
)


# The agent's ``_normalize_boolean_format_label`` (nb 52069-52086), which
# ``_vov_base_conventions_win`` applies to the base value (nb 52136-52138).
_AGENT_BOOLEAN_ALIASES = {
    "boolean": "Boolean (True/False)",
    "bool": "Boolean (True/False)",
    "true/false": "Boolean (True/False)",
    "tinyint": "Int (0/1)",
    "bit": "Int (0/1)",
    "1/0": "Int (0/1)",
    "yes/no": "String (Y/N)",
    "y/n": "String (Y/N)",
}
_AGENT_BOOLEAN_LABELS = ("boolean (true/false)", "int (0/1)", "string (y/n)")


def agent_boolean_label(raw: Any) -> str:
    """The ``boolean_format`` the agent keeps for a base value ``raw``: an
    empty, missing or unknown value becomes "Boolean (True/False)", so a vibe
    always locks this field."""
    text = "" if raw is None else str(raw).strip()
    mapped = _AGENT_BOOLEAN_ALIASES.get(text.lower())
    if mapped:
        return mapped
    return text if text.lower() in _AGENT_BOOLEAN_LABELS else "Boolean (True/False)"


# Locked on every vibe, whether or not the base sets them.
ALWAYS_LOCKED_FIELDS = frozenset({"boolean_format", "schema_suffix", "tag_suffix"})


def _locked_field(field: str, file_mc: Optional[dict]) -> RunDefaultFieldOut:
    if file_mc is None:
        return RunDefaultFieldOut(source="unknown", locked=True, locked_scoped=True)
    raw = file_mc.get(RUN_CONVENTION_FILE_KEYS[field])
    if field in ALWAYS_LOCKED_FIELDS:
        # The agent canonicalizes ``boolean_format`` before its "base empty"
        # test, and ignores the suffixes, so the request never sets these.
        base = agent_boolean_label(raw) if field == "boolean_format" else ("" if raw is None else raw)
        value = run_field_file_value(field, base)
        if value is None:
            return RunDefaultFieldOut(source="unknown", locked=True, locked_scoped=True)
        return RunDefaultFieldOut(value=value, source="base_file", locked=True, locked_scoped=True)
    if raw is None or not str(raw).strip():
        if field in _LIST_FIELDS:
            return RunDefaultFieldOut(
                value=FIELD_DEFAULTS[field], source="default", locked_scoped=True
            )
        return RunDefaultFieldOut(value="", source="base_file", locked_scoped=True)
    value = run_field_file_value(field, raw)
    if value is None:
        return RunDefaultFieldOut(source="unknown", locked=True, locked_scoped=True)
    return RunDefaultFieldOut(value=value, source="base_file", locked=True, locked_scoped=True)


def _widget_value(field: str, widgets: Optional[dict]) -> Optional[str]:
    if widgets is None or not isinstance(widgets.get(field), str):
        return None
    return widgets[field]


def _open_field(field: str, widgets: Optional[dict]) -> RunDefaultFieldOut:
    widget = _widget_value(field, widgets)
    if widget is not None:
        return RunDefaultFieldOut(value=widget, source="base_run")
    return RunDefaultFieldOut(value=FIELD_DEFAULTS[field], source="default")


def run_defaults(session: Any, ws: Any, business: Any, base_mv: Any) -> RunDefaultsOut:
    """Every pre-filled field of a vibe of ``base_mv`` (see the module
    docstring). Reads the base's ``model.json`` once, bounded."""
    file_mc = read_version_conventions(session, ws, base_mv, business.name)
    widgets = generation_widgets_for_version(session, base_mv.id)
    fields = {
        field: (
            _locked_field(field, file_mc)
            if field in VIBE_LOCKED_FIELDS
            else _open_field(field, widgets)
        )
        for field in FIELD_DEFAULTS
    }
    return RunDefaultsOut(base_version_id=base_mv.id, file_read=file_mc is not None, fields=fields)

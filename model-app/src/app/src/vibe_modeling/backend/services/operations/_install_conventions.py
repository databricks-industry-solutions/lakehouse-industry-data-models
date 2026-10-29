"""Model conventions for installing a scoped (``_vibe_scope``) or Dry Run version.

The agent's ``install model`` op compares the install widgets against the
``model_conventions`` saved in the ``model.json`` it installs. For a file
with a root ``_vibe_scope`` block, any difference in the four compared keys
(naming convention, primary key suffix, schema prefix, table id type)
raises ``VibeScopeFenceError`` at setup. The app does not store a version's
conventions in Lakebase, so ``Install.dispatch`` reads them from the same
``context_file`` the agent will read and sends the file's values.

Files with a root ``_vibe_scope`` block are affected, and so is the file of
a Dry Run version (``any_file``): the user reviewed that draft with its own
conventions, so its install lays the schemas out the same way. Every other
install sends exactly the widgets it sends without this module.

- :func:`parse_scoped_conventions` - pure: the file's ``model_conventions``
  for a ``_vibe_scope`` file (any file with ``any_file``), else ``None``.
- :func:`read_model_json` - bounded read of ``model.json``: a daemon
  worker thread, a wall-clock cap and a byte cap. Never raises, never hangs,
  and never touches the DB session. :func:`read_scoped_conventions` parses
  its result.
- :func:`apply_file_prefix` - pure: for an ordinary file, only the file's
  ``schema_prefix`` (``""`` included), when the install takes the version's
  own prefix (``InstallParams.prefix_from_version``, set by
  ``dag_for_install`` when the request names none).
- :func:`effective_install_params` - pure: the params dispatch sends. An
  ordinary file gets the ordinary widget set; a scoped file goes through
  :func:`apply_file_conventions`.
- :func:`apply_file_conventions` - pure: merge the file's values into the
  install params with precedence explicit request > file > today's default.

The run side reads the same file block: ``RUN_CONVENTION_FILE_KEYS`` maps
every ``RunIn`` convention field to its ``model_conventions`` key (a vibe
locks all of them, ``VIBE_LOCKED_FIELDS``), and
:func:`run_field_file_value` checks one file value as a run would send it
(the vibe pre-fill in ``services/run_defaults`` and the shrink step's copy
of its parent ECM's conventions).
"""

from __future__ import annotations

import json
import logging
import re
import threading
from typing import TYPE_CHECKING, Any, Optional

from pydantic import ValidationError

from ...agent_compat import model_json_block
from ...import_model import model_conventions
from ...models import normalize_boolean_format
from ._deployment_widgets import SCHEMA_PREFIX_PATTERN

if TYPE_CHECKING:
    from .install import InstallParams

logger = logging.getLogger(__name__)

_READ_TIMEOUT_S: float = 15
# The budget for reads a step or publish cannot proceed without.
REQUIRED_READ_TIMEOUT_S: float = 60
_MAX_BYTES: int = 32 * 1024 * 1024

_NAMING_CHOICES = ("snake_case", "camelCase", "PascalCase", "SCREAMING_CASE")
_TABLE_ID_TYPES = ("BIGINT", "INT", "LONG", "STRING")

# The install convention keys: ``InstallParams`` field (and ``RunIn``
# attribute) -> ``model_conventions`` key in the agent's model.json.
# ``dag_for_install`` records which of these the request set explicitly.
CONVENTION_FILE_KEYS = {
    "schema_prefix": "schema_prefix",
    "naming_convention": "data_asset_naming_convention",
    "primary_key_suffix": "primary_key_suffix",
    "table_id_type": "table_id_type",
    "schema_suffix": "schema_suffix",
    "tag_prefix": "tag_prefix",
}

# Every ``RunIn`` convention field the ``model.model_conventions`` block of a
# model.json carries -> its key there (the agent's widget-to-convention map,
# nb 102800-102817). A vibe locks every one of them: on ``vibe modeling of
# version`` the agent sets each ``MODEL_CONVENTION_KEYS`` key (nb 52097-52108)
# to the base's value, for every key on a Some domains run and for the keys
# the base sets otherwise (``_vov_base_conventions_win``, nb 52132-52149,
# called with ``exact=_vibe_scope_on`` at nb 54301). ``table_suffix`` has no
# form field. ``schema_suffix`` and ``tag_suffix`` are not in
# ``MODEL_CONVENTION_KEYS`` but are locked too: on a live All domains Dry Run
# the agent ignored an edited ``tag_suffix`` (the base had ``_wt``) and an
# edited ``schema_suffix`` (the base's was empty); the registry row kept the
# edits and the model.json the base's. Run defaults lock both on every vibe,
# an empty base value included (``run_defaults.ALWAYS_LOCKED_FIELDS``).
# ``tests/test_app/test_agent_widget_options.py`` pins the keys to the
# notebook.
RUN_CONVENTION_FILE_KEYS: dict[str, str] = {
    "naming_convention": "data_asset_naming_convention",
    "primary_key_suffix": "primary_key_suffix",
    "schema_prefix": "schema_prefix",
    "schema_suffix": "schema_suffix",
    "tag_prefix": "tag_prefix",
    "tag_suffix": "tag_suffix",
    "table_id_type": "table_id_type",
    "boolean_format": "boolean_format",
    "date_format": "date_format",
    "timestamp_format": "timestamp_format",
    "classification_levels": "data_classification_levels",
}
VIBE_LOCKED_FIELDS: frozenset[str] = frozenset(RUN_CONVENTION_FILE_KEYS)


def parse_scoped_conventions(model_json: Any, *, any_file: bool = False) -> Optional[dict]:
    """Return the ``model_conventions`` of a ``_vibe_scope`` model.json.

    ``None`` unless ``model_json`` is a dict with a truthy root
    ``_vibe_scope`` block (the agent's ``root.get("_vibe_scope")`` test), or
    ``any_file`` is set (a Dry Run version's file).
    The conventions come from ``root["model"]`` when that is a dict,
    otherwise from the root (the legacy flat layout); a root-level
    ``model_conventions`` is ignored when a ``model`` dict exists. A JSON
    string is parsed. Anything that is not a dict gives ``None``.
    """
    if not isinstance(model_json, dict):
        return None
    if not any_file and not model_json_block(model_json, "_vibe_scope"):
        return None
    return model_conventions(model_json)


def _warn_unreadable(context_file: str, reason: Any) -> None:
    logger.warning(
        "install: could not read model conventions from %s (%s)",
        context_file,
        reason,
    )


def read_scoped_conventions(
    ws: Any, context_file: str, *, any_file: bool = False
) -> Optional[dict]:
    """Read ``context_file`` (:func:`read_model_json`) and return its scoped
    conventions, or ``None`` (``any_file``: see
    :func:`parse_scoped_conventions`)."""
    return parse_scoped_conventions(read_model_json(ws, context_file), any_file=any_file)


def read_model_json(ws: Any, context_file: str, *, timeout_s: Optional[float] = None) -> Any:
    """Read and parse ``context_file`` (:func:`read_volume_bytes`); ``None``
    when it cannot be read or is not JSON (logged)."""
    data = read_volume_bytes(ws, context_file, timeout_s=timeout_s)
    if data is None:
        return None
    try:
        return json.loads(data)
    except Exception as e:  # noqa: BLE001 - any failure falls back
        _warn_unreadable(context_file, repr(e))
        return None


def read_volume_bytes(ws: Any, context_file: str, *, timeout_s: Optional[float] = None) -> Optional[bytes]:
    """The bytes of ``context_file``; ``None`` when it cannot be read.

    Both ``ws.files.download`` and ``.contents.read`` run in a daemon
    thread, joined for at most ``timeout_s`` seconds (default
    ``_READ_TIMEOUT_S``, the budget of the optional readers; the install,
    which needs the file, passes a longer one): the SDK's own
    per-request timeout and retry window are far longer, and a daemon
    thread (unlike a ``ThreadPoolExecutor`` worker) never blocks the caller
    or interpreter exit. The body is capped by bytes actually read
    (``read(_MAX_BYTES + 1)``) because ``content_length`` may be ``None``.
    The worker closes the response stream when it finishes. A timed-out
    worker is not stopped: it keeps running until the SDK request ends and
    may hold up to the capped number of bytes until then.

    Any failure (missing file, permission, timeout, over-size body, a mock
    client) logs a warning and returns ``None``.
    """
    holder: dict[str, Any] = {}

    def _worker() -> None:
        contents = None
        try:
            resp = ws.files.download(context_file)
            contents = resp.contents
            holder["data"] = contents.read(_MAX_BYTES + 1)
        except BaseException as e:  # noqa: BLE001 - reported by the caller
            holder["error"] = e
        finally:
            close = getattr(contents, "close", None)
            if callable(close):
                try:
                    close()
                except Exception:  # noqa: BLE001 - best-effort cleanup
                    pass

    worker = threading.Thread(
        target=_worker, name="install-conventions-read", daemon=True
    )
    budget = _READ_TIMEOUT_S if timeout_s is None else timeout_s
    worker.start()
    worker.join(budget)
    if worker.is_alive():
        _warn_unreadable(context_file, f"timed out after {budget}s")
        return None
    if "error" in holder:
        _warn_unreadable(context_file, repr(holder["error"]))
        return None
    try:
        data = holder.get("data")
        if not isinstance(data, (bytes, bytearray, str)):
            raise TypeError(f"unexpected body type {type(data).__name__}")
        if len(data) > _MAX_BYTES:
            _warn_unreadable(context_file, f"larger than {_MAX_BYTES} bytes")
            return None
    except Exception as e:  # noqa: BLE001 - any failure falls back
        _warn_unreadable(context_file, repr(e))
        return None
    return data.encode("utf-8") if isinstance(data, str) else bytes(data)


def _file_value(key: str, raw: Any, cataloging_style: str) -> tuple[bool, Any]:
    """Check one file value for ``key``. Returns ``(usable, value)``."""
    if key == "schema_prefix":
        # Every cataloging style takes the file's prefix, "" included: the
        # file's stored schema names carry it, the agent accepts a blank
        # prefix (nb 37285) and its fence compares it with the file's (nb
        # 103772-103786).
        if isinstance(raw, str) and re.fullmatch(SCHEMA_PREFIX_PATTERN, raw):
            return True, raw
        return False, None
    if key == "naming_convention":
        return (True, raw) if raw in _NAMING_CHOICES else (False, None)
    if key == "boolean_format":
        try:
            return True, normalize_boolean_format(raw)
        except (TypeError, ValueError):
            return False, None
    if key == "table_id_type":
        if raw is None or raw == "":
            return True, "BIGINT"
        if isinstance(raw, str) and raw.upper() in _TABLE_ID_TYPES:
            return True, raw.upper()
        return False, None
    # The other text widgets (suffixes, tag prefix, date and timestamp
    # formats, classification levels): verbatim.
    return (True, raw) if isinstance(raw, str) else (False, None)


def run_field_file_value(field: str, raw: Any) -> Optional[str]:
    """A ``model_conventions`` value for the ``RunIn`` ``field`` as a run
    request would send it, or ``None`` when the API would refuse it or the
    agent replace it (an unknown naming convention or boolean format). The
    rule is :func:`_file_value`'s with One Catalog, where a ``schema_prefix``,
    ``""`` included, must match the shared prefix pattern."""
    usable, value = _file_value(field, raw, "One Catalog")
    return value if usable else None


def effective_install_params(
    params: "InstallParams", file_mc: Optional[dict]
) -> tuple["InstallParams", Optional[str]]:
    """The params ``Install.dispatch`` sends, plus the conventions source.

    ``file_mc`` is :func:`parse_scoped_conventions` of the dispatched
    ``context_file`` (:func:`read_model_json`). ``None`` (an ordinary file, or a failed
    read) sends exactly the ordinary install widgets: an explicit request
    ``schema_suffix``/``tag_prefix`` is dropped and the agent keeps its own
    widget defaults. A scoped file is merged by
    :func:`apply_file_conventions`. The source is ``None`` for the ordinary
    case.
    """
    if file_mc is None:
        return params.model_copy(update={"schema_suffix": None, "tag_prefix": None}), None
    return apply_file_conventions(params, file_mc)


def apply_file_conventions(
    params: "InstallParams", file_mc: dict
) -> tuple["InstallParams", str]:
    """Merge a scoped file's conventions into the install params.

    For each of ``schema_prefix``, ``naming_convention``,
    ``primary_key_suffix``, ``table_id_type``, ``schema_suffix`` and
    ``tag_prefix``: a key listed in ``params.explicit_convention_keys``
    keeps the request value; otherwise a file value that passes its check
    is used; otherwise today's value is kept (``None`` for
    ``schema_suffix``/``tag_prefix``, so the widget is not sent).
    A ``schema_prefix`` taken from the file sets ``prefix_from_record``, so
    the file's ``""`` passes the One Catalog rule of ``InstallParams``.

    Returns ``(effective_params, source)``. ``source`` is ``"file"`` when
    every key the file carries was used, ``"request"`` when none was, and
    ``"partial"`` otherwise. If the merged params fail validation, the
    unmerged params are returned with ``"request"``.
    """
    explicit = set(params.explicit_convention_keys)
    updates: dict[str, Any] = {}
    present = 0
    for key, file_key in CONVENTION_FILE_KEYS.items():
        if file_key not in file_mc:
            if (
                key == "schema_prefix"
                and key not in explicit
                and params.cataloging_style == "One Catalog"
            ):
                logger.warning(
                    "install: scoped model.json has no schema_prefix; keeping "
                    "%r, the agent's convention fence will reject this install",
                    params.schema_prefix,
                )
            continue
        present += 1
        if key in explicit:
            continue
        raw = file_mc[file_key]
        usable, value = _file_value(key, raw, params.cataloging_style)
        if usable:
            updates[key] = value
        elif key == "schema_prefix" and params.cataloging_style == "One Catalog":
            logger.warning(
                "install: scoped model.json schema_prefix %r not usable; "
                "keeping %r, the agent's convention fence will reject this "
                "install",
                raw,
                params.schema_prefix,
            )
        elif key != "schema_prefix":
            logger.warning(
                "install: scoped model.json %s %r not usable; keeping %r",
                file_key,
                raw,
                getattr(params, key),
            )

    if not updates:
        return params, "request"
    source = "file" if len(updates) == present else "partial"
    if "schema_prefix" in updates:
        updates["prefix_from_record"] = True
    try:
        merged = type(params)(**{**params.model_dump(), **updates})
    except ValidationError as e:
        logger.warning(
            "install: file conventions %r failed validation (%s); using "
            "request/default conventions",
            updates,
            e,
        )
        return params, "request"
    return merged, source


def apply_file_prefix(
    params: "InstallParams", file_mc: Optional[dict]
) -> tuple["InstallParams", Optional[str]]:
    """Send the version's own ``schema_prefix`` for an ordinary file.

    ``file_mc`` is the file's ``model_conventions`` (any file; ``{}`` for a
    file that has none). Its ``schema_prefix``, ``""`` included (an absent
    key reads as ``""``), replaces the prefix the DAG resolved and marks
    ``prefix_from_record``; source ``"prefix"``. Every import writes its scope
    prefix into the app's copy of the file (``services/scope_prefix``), so
    the file decides. ``None`` (no file) or a value that fails
    :func:`_file_value` keeps ``params`` (source ``None``). Only the prefix
    is taken: the other widgets stay the ordinary set.
    """
    if file_mc is None:
        return params, None
    raw = str(file_mc.get("schema_prefix") or "")
    usable, value = _file_value("schema_prefix", raw, params.cataloging_style)
    if not usable:
        logger.warning(
            "install: model.json schema_prefix %r not usable with %s; keeping %r",
            raw, params.cataloging_style, params.schema_prefix,
        )
        return params, None
    return params.model_copy(update={"schema_prefix": value, "prefix_from_record": True}), "prefix"

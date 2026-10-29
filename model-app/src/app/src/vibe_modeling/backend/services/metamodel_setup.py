"""Idempotent ``<catalog>._metamodel`` + MANAGED volume setup (``vol_root`` by default).

Canonical implementation for the app and the installer:
``install/grant_catalog.py`` loads this file by path (``vibe_modeling`` is not
installed in the operator env), so it imports only the stdlib and
``databricks.sdk``. The helper always raises on failure; the policy lives in
the callers (the app refuses the run, the installer logs the manual SQL and
continues). The run pre-flight (``services/orchestrator/preflight.py``,
level 3) reads :func:`metamodel_state` and, on create, calls this after every
check and right before the Run row is written, so a brand-new base model in a
fresh catalog is not blocked on a manual installer step: step-0 dispatch may
spill ``model_vibes`` into ``vol_root`` before the agent can create
``_metamodel`` itself.

The app-only side (the agent's registry tables, the refusal text with its
GRANTs) is ``services/metamodel_registry.py``, which builds on this module.

Identity: the app passes the ``Dependencies.Client`` workspace client, which
is the App service principal (``WorkspaceClient()`` built in the lifespan from
the app's injected credentials), NOT the on-behalf-of user. So the SP needs
``USE_CATALOG`` + ``CREATE_SCHEMA`` on the catalog for this to succeed.
"""

from __future__ import annotations

import logging
from dataclasses import dataclass
from typing import Optional

from databricks.sdk.errors import BadRequest, NotFound, PermissionDenied
from databricks.sdk.service.catalog import VolumeType

logger = logging.getLogger(__name__)

METAMODEL_SCHEMA = "_metamodel"
VOL_ROOT = "vol_root"


class MetamodelSetupError(Exception):
    """Setup failed at ``step`` (``"schema"``, ``"volume"`` or ``"tables"``). ``str(exc)`` is
    a fixed, user-safe message (no raw SDK exception text); the raw error is
    logged server-side. ``invisible`` is set when ``_metamodel`` exists but
    the app can't see it (:func:`invisible_metamodel_message`)."""

    def __init__(self, message: str, *, step: str, invisible: bool = False) -> None:
        super().__init__(message)
        self.step = step
        self.invisible = invisible


def invisible_metamodel_message(catalog: str, volumes: tuple[str, ...] = (VOL_ROOT,)) -> str:
    """The one wording for a ``_metamodel`` that exists but the app can't
    see: the run pre-flight's denied-schema blocker and the setup's refusal
    after ``SCHEMA_ALREADY_EXISTS``. ``volumes`` are the volumes being set up
    (``vol_root``, plus ``assess_runs`` for the assessment job)."""
    schema_full = f"{catalog}.{METAMODEL_SCHEMA}"
    listed = " and ".join(f"`{schema_full}.{v}`" for v in volumes)
    return (
        f"`{METAMODEL_SCHEMA}` exists in '{catalog}' but the app can't see it (needs "
        f"USE SCHEMA on `{schema_full}`, plus READ VOLUME and WRITE VOLUME on {listed})."
    )


def _schema_already_exists(exc: Exception) -> bool:
    """UC's answer to creating a schema that exists: ``BadRequest`` with
    ``SCHEMA_ALREADY_EXISTS``, also when the caller can't see it."""
    return isinstance(exc, BadRequest) and getattr(exc, "error_code", None) == "SCHEMA_ALREADY_EXISTS"


def app_principal(ws) -> str:
    """Best-effort App service-principal client id for the error message."""
    client_id = getattr(getattr(ws, "config", None), "client_id", None)
    if isinstance(client_id, str) and client_id.strip():
        return f"({client_id.strip()})"
    return "(its client id is on the app's Authorization/Environment page)"


def _generic_failure_message(ws, catalog: str, step: str, volume: str = VOL_ROOT) -> str:
    if step == "volume":
        return (
            f"Couldn't set up `_metamodel` in '{catalog}' automatically (the "
            f"`{volume}` volume step failed). Check that the app's service "
            f"principal {app_principal(ws)} has USE_SCHEMA + CREATE_VOLUME on "
            f"'{catalog}.{METAMODEL_SCHEMA}', or run `install/grant_catalog.py`, "
            f"then retry."
        )
    return (
        f"Couldn't set up `_metamodel` in '{catalog}' automatically. Check that the "
        f"catalog exists and the app's service principal {app_principal(ws)} has "
        f"USE_CATALOG + CREATE_SCHEMA on it, or run `install/grant_catalog.py`, "
        f"then retry."
    )


def _permission_message(ws, catalog: str, step: str, volume: str = VOL_ROOT) -> str:
    if step == "volume":
        return (
            f"The app can't create the `{volume}` volume in "
            f"'{catalog}.{METAMODEL_SCHEMA}' (needs USE_SCHEMA + CREATE_VOLUME on "
            f"that schema). Ask a catalog owner to grant the app's service "
            f"principal {app_principal(ws)} those privileges, or run "
            f"`install/grant_catalog.py`."
        )
    return (
        f"The app can't create `_metamodel` in '{catalog}' (needs USE_CATALOG + "
        f"CREATE_SCHEMA on the catalog). Ask a catalog owner to grant the app's "
        f"service principal {app_principal(ws)} those privileges, or run "
        f"`install/grant_catalog.py`."
    )


def _probe(ws, catalog: str, *, step: str, probe, full_name: str, volume: str = VOL_ROOT) -> bool:
    """Pre-create probe: True when ``probe(full_name)`` reads the object.

    ``NotFound`` / ``PermissionDenied`` return False so the caller attempts the
    create; any other error fails the step with its generic message.
    """
    try:
        probe(full_name)
    except (NotFound, PermissionDenied):
        return False
    except Exception as exc:  # noqa: BLE001 — an unreadable object fails the step
        logger.warning("Probing %s failed: %s", full_name, exc, exc_info=True)
        raise MetamodelSetupError(
            _generic_failure_message(ws, catalog, step, volume), step=step
        ) from exc
    return True


def _readable_now(probe, full_name: str, *, denied: Optional[list] = None) -> bool:
    """Post-failure re-probe: True when the object exists now. Never raises, so
    the caller can re-raise the original create error. A ``PermissionDenied``
    re-probe is appended to ``denied`` when given."""
    try:
        probe(full_name)
    except Exception as exc:  # noqa: BLE001 — any error means "not confirmed"
        logger.warning("%s not readable after a failed create: %s", full_name, exc)
        if denied is not None and isinstance(exc, PermissionDenied):
            denied.append(exc)
        return False
    return True


@dataclass(frozen=True)
class MetamodelState:
    """What :func:`metamodel_state` read in one catalog.

    ``schema``: ``True`` present, ``False`` absent, ``None`` unreadable.
    ``missing_volumes``: the volumes of the probe that are absent (all of
    them when the schema is absent; empty when the schema is unreadable).
    """

    schema: Optional[bool]
    missing_volumes: tuple[str, ...] = ()
    # Reading the schema answered ``PermissionDenied``: the reader may not use it.
    denied: bool = False


def _exists(probe, full_name: str) -> Optional[bool]:
    try:
        probe(full_name)
    except NotFound:
        return False
    except PermissionDenied:
        raise
    except Exception as exc:  # noqa: BLE001 - unreadable is not absent
        logger.warning("Probing %s failed: %s", full_name, exc)
        return None
    return True


def _volume_exists(ws, full_name: str) -> Optional[bool]:
    try:
        return _exists(ws.volumes.read, full_name)
    except PermissionDenied:
        return None


def metamodel_state(ws, catalog: str, volumes: tuple[str, ...] = (VOL_ROOT,)) -> MetamodelState:
    """Read, without creating anything, whether ``<catalog>._metamodel`` and
    each volume of ``volumes`` exist: the probe the run pre-flight reports
    and :func:`ensure_metamodel_schema_and_volume` then acts on.

    Only ``NotFound`` reads as absent. A schema read answered with
    ``PermissionDenied`` is ``denied`` (the reader may not use it). Any other error leaves
    the object unreadable, so a check built on this never claims an object
    is missing when it could not see it. A volume that can't be read is not
    listed as missing.
    """
    schema_full = f"{catalog}.{METAMODEL_SCHEMA}"
    try:
        schema = _exists(ws.schemas.get, schema_full)
    except PermissionDenied:
        return MetamodelState(schema=None, denied=True)
    if schema is False:
        return MetamodelState(schema=False, missing_volumes=tuple(volumes))
    if schema is None:
        return MetamodelState(schema=None)
    missing = tuple(v for v in volumes if _volume_exists(ws, f"{schema_full}.{v}") is False)
    return MetamodelState(schema=True, missing_volumes=missing)


def ensure_metamodel_schema_and_volume(ws, catalog: str, volumes: tuple[str, ...] = (VOL_ROOT,)) -> list[str]:
    """Create ``<catalog>._metamodel`` and each MANAGED volume in ``volumes`` if absent.

    ``volumes`` defaults to ``("vol_root",)``; the assessment job sync passes
    ``("vol_root", "assess_runs")``. Returns the list of resources actually created
    (``[]`` when all already existed). Each object is probed first and skipped
    when it exists. Any failed create is followed by a re-probe and decided
    from state: UC reports an existing schema as ``BadRequest``
    (``SCHEMA_ALREADY_EXISTS``) and an existing volume as
    ``ResourceAlreadyExists``, so the error type alone does not say whether the
    object exists. Readable now = success; otherwise the original create error
    maps to :class:`MetamodelSetupError` (with ``step``) and a fixed,
    actionable message naming the volume.
    """
    created: list[str] = []
    schema_full = f"{catalog}.{METAMODEL_SCHEMA}"
    step, volume = "schema", volumes[0] if volumes else VOL_ROOT
    try:
        if not _probe(ws, catalog, step=step, probe=ws.schemas.get, full_name=schema_full):
            try:
                ws.schemas.create(name=METAMODEL_SCHEMA, catalog_name=catalog)
                created.append(f"schema {schema_full}")
            except Exception as exc:
                denied: list = []
                if not _readable_now(ws.schemas.get, schema_full, denied=denied):
                    if _schema_already_exists(exc) and denied:
                        # Without USE SCHEMA there is no state to re-read: the
                        # create's error code is the only evidence it exists.
                        logger.warning("%s exists but the app can't see it: %s", schema_full, exc)
                        raise MetamodelSetupError(
                            invisible_metamodel_message(catalog, tuple(volumes) or (VOL_ROOT,)),
                            step="schema", invisible=True,
                        ) from exc
                    raise
        step = "volume"
        for volume in volumes:
            vol_full = f"{schema_full}.{volume}"
            if _probe(ws, catalog, step=step, probe=ws.volumes.read, full_name=vol_full, volume=volume):
                continue
            try:
                ws.volumes.create(
                    catalog_name=catalog,
                    schema_name=METAMODEL_SCHEMA,
                    name=volume,
                    volume_type=VolumeType.MANAGED,
                )
                created.append(f"managed volume {vol_full}")
            except Exception:
                if not _readable_now(ws.volumes.read, vol_full):
                    raise
    except MetamodelSetupError:
        # Keep the outer ``except Exception`` from re-wrapping the step error
        # (a MetamodelSetupError can't match ``except PermissionDenied``).
        raise
    except PermissionDenied as exc:
        logger.warning("No permission to set up %s (%s step): %s", schema_full, step, exc)
        raise MetamodelSetupError(_permission_message(ws, catalog, step, volume), step=step) from exc
    except Exception as exc:  # noqa: BLE001 — any SDK/transport error becomes a blocker
        logger.warning("Setting up %s failed (%s step): %s", schema_full, step, exc,
                       exc_info=True)
        raise MetamodelSetupError(_generic_failure_message(ws, catalog, step, volume), step=step) from exc

    if created:
        logger.info("Auto-created in %s: %s", catalog, ", ".join(created))
    return created


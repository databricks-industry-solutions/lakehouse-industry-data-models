"""Grant Unity Catalog privileges to the app service principal post-install.

Issued after ``provision_lakebase.py`` because we need the App's SP UUID
(captured from ``databricks apps get`` after ``bundle deploy``).

Creates the install catalog, the ``_metamodel`` schema, and its ``vol_root``
MANAGED volume if absent (the app's industry-download writes model artifacts
to ``/Volumes/{catalog}/_metamodel/vol_root/...`` before any vibe run, so they
must exist at install time; the agent also creates all three idempotently on
first run). The schema + volume step runs the app's canonical
``src/app/src/vibe_modeling/backend/services/metamodel_setup.py``, loaded by
file path, so the script must run from a repo checkout. Then grants the SP at
two best-effort levels, each tried
independently — a failure on one does not block the next:

  1. ``CATALOG``: USE_CATALOG, CREATE_SCHEMA, BROWSE on the install catalog.
                  USE_CATALOG + CREATE_SCHEMA so the App can list catalogs
                  in the New Run picker and so the agent can create its
                  ``_metamodel`` schema on first vibe run. BROWSE is
                  required by the agent's ``CREATE DATABASE IF NOT EXISTS``
                  on the auto-generated ``_metrics`` schema (the existence
                  probe reads catalog metadata) — verified empirically
                  on 2026-05-08 when a fresh SP without BROWSE failed at
                  agent's ``_create_metrics_database_if_needed`` step.
  2. ``SCHEMA``:  USE_SCHEMA, CREATE_TABLE, MODIFY, SELECT, READ_VOLUME,
                  WRITE_VOLUME, CREATE_VOLUME, MANAGE on
                  ``<catalog>._metamodel`` *if* the schema already exists. SELECT and the *_VOLUME
                  privileges cover the cross-install case: the schema /
                  tables / ``vol_root`` volume were created by a previous
                  install's SP (or another principal), so the new SP
                  needs to read existing rows and read/write existing
                  volume files, not just write new ones. Schema-level
                  ``*_VOLUME`` cascades to current and future volumes in
                  the schema, so no separate volume-level grant is
                  needed. Newly-created schemas are owned by the SP that
                  creates them, so the SP-as-creator path still needs no
                  grant. CREATE_VOLUME and MANAGE are granted on EVERY
                  install, whether or not the bronze assessment skill is
                  enabled: the app creates and owns its ``assess_runs``
                  volume and grants the assessment reader access to it and
                  USE SCHEMA on ``_metamodel``, so enabling the skill later
                  (reader set in Settings) needs no admin step.

Permission requirement: the caller must own the catalog OR have MANAGE
privilege on it OR be a metastore admin. If the call lacks permission,
the equivalent SQL is logged so the right person can run it later, and
the script exits 0 — the install does not abort.

Idempotent. Safe to re-run.
"""

from __future__ import annotations

import argparse
import logging
import sys
from pathlib import Path

from databricks.sdk import WorkspaceClient
from databricks.sdk.errors import NotFound, PermissionDenied
from databricks.sdk.service.catalog import PermissionsChange, Privilege

from _install_common import load_backend_module, workspace_client

logger = logging.getLogger("install.grant_catalog")
logging.basicConfig(format="%(message)s", level=logging.INFO)

CATALOG_PRIVS = [Privilege.USE_CATALOG, Privilege.CREATE_SCHEMA, Privilege.BROWSE]
SCHEMA_PRIVS = [
    Privilege.USE_SCHEMA,
    Privilege.CREATE_TABLE,
    Privilege.MODIFY,
    Privilege.SELECT,
    Privilege.READ_VOLUME,
    Privilege.WRITE_VOLUME,
    Privilege.CREATE_VOLUME,
    Privilege.MANAGE,
]

METAMODEL_SETUP_PATH = (
    Path(__file__).resolve().parents[1]
    / "src/app/src/vibe_modeling/backend/services/metamodel_setup.py"
)


def _load_metamodel_setup():
    """The app's canonical ``_metamodel`` setup module (``vibe_modeling`` is not
    installed in the operator env). Loaded lazily so the script imports, and
    ``--help`` works, without the app source."""
    return load_backend_module(METAMODEL_SETUP_PATH)


def _grant(
    w: WorkspaceClient,
    *,
    securable_type: str,
    full_name: str,
    principal: str,
    privileges: list[Privilege],
    sql_fallback: str,
) -> bool:
    """Apply one grant. Returns True on success, False on any failure."""
    try:
        w.grants.update(
            securable_type=securable_type,
            full_name=full_name,
            changes=[PermissionsChange(principal=principal, add=privileges)],
        )
    except PermissionDenied as exc:
        logger.warning(
            f"[warn] no permission to grant on {securable_type} {full_name}: {exc}"
        )
        logger.warning(f"[warn] manually run: {sql_fallback}")
        return False
    except Exception as exc:  # noqa: BLE001 — best-effort: surface and continue
        logger.warning(
            f"[warn] grant on {securable_type} {full_name} failed: {exc}"
        )
        logger.warning(f"[warn] manually run: {sql_fallback}")
        return False
    privs = ", ".join(p.value for p in privileges)
    logger.info(
        f"[ok]   granted {privs} on {securable_type} {full_name} -> {principal}"
    )
    return True


def _exists(getter, full_name: str, *, label: str) -> bool:
    """True if ``getter(full_name)`` returns; False on NotFound;
    None-equivalent (logs warn, returns False) on PermissionDenied so
    we don't block the rest of the script when the caller can't read
    metadata for a level it might still be allowed to grant on."""
    try:
        getter(full_name)
        return True
    except NotFound:
        return False
    except PermissionDenied as exc:
        logger.warning(
            f"[warn] cannot read {label} '{full_name}' to check existence: {exc} "
            f"— skipping that grant level."
        )
        return False


def _ensure_schema_and_volume(w: WorkspaceClient, *, catalog: str) -> bool:
    """Create ``<catalog>._metamodel`` and its ``vol_root`` MANAGED volume if
    absent. Returns True if the schema is present afterwards (pre-existing or
    just created), False if it could not be verified or created.

    The app's industry-download writes model artifacts to
    ``/Volumes/{catalog}/_metamodel/vol_root/...`` *before* any vibe run, so
    the schema + volume must exist at install time. The agent also creates both
    on its first run with ``CREATE ... IF NOT EXISTS``, so pre-creating here is
    idempotent. Best-effort: a failure logs the equivalent SQL and does not
    abort the install. The work is done by the app's canonical
    ``ensure_metamodel_schema_and_volume``; its error text is written for app
    users, so it is not logged here (the helper logs the raw error itself).
    """
    setup = _load_metamodel_setup()
    schema_full = f"{catalog}.{setup.METAMODEL_SCHEMA}"
    vol_full = f"{schema_full}.{setup.VOL_ROOT}"
    try:
        created = setup.ensure_metamodel_schema_and_volume(w, catalog)
    except setup.MetamodelSetupError as exc:
        if exc.step == "schema":
            logger.warning(f"[warn] could not verify or create schema {schema_full}")
            logger.warning(
                f"[warn] manually run: CREATE SCHEMA IF NOT EXISTS {schema_full};"
            )
            return False
        logger.warning(f"[warn] could not verify or create volume {vol_full}")
        logger.warning(f"[warn] manually run: CREATE VOLUME IF NOT EXISTS {vol_full};")
        return True
    for item in created:
        logger.info(f"[ok]   created {item}")
    return True


def catalog_grant_sql(catalog: str, app_sp: str) -> str:
    return f"GRANT USE CATALOG, CREATE SCHEMA, BROWSE ON CATALOG {catalog} TO `{app_sp}`;"


def schema_grant_sql(schema_full: str, app_sp: str) -> str:
    return (
        f"GRANT USE SCHEMA, CREATE TABLE, MODIFY, SELECT, "
        f"READ VOLUME, WRITE VOLUME, CREATE VOLUME, MANAGE ON SCHEMA {schema_full} "
        f"TO `{app_sp}`;"
    )


def grant_all(*, profile: str | None, catalog: str, app_sp: str) -> int:
    w = workspace_client(profile)

    if not _exists(w.catalogs.get, catalog, label="catalog"):
        # The installer creates the catalog if absent (INSTALL.md documents
        # this, and lists "create UC catalogs" as a Path-B privilege). Same
        # best-effort contract as the grants below: on a permission failure,
        # log the equivalent SQL and continue without aborting the install.
        try:
            w.catalogs.create(name=catalog)
            logger.info(f"[ok]   created catalog '{catalog}'")
        except PermissionDenied as exc:
            logger.warning(
                f"[warn] no permission to create catalog '{catalog}': {exc}"
            )
            logger.warning(
                f"[warn] manually run: CREATE CATALOG IF NOT EXISTS {catalog};"
                f"  then re-run install/grant_catalog.py"
            )
            return 0
        except Exception as exc:  # noqa: BLE001 — best-effort: surface and continue
            logger.warning(f"[warn] create catalog '{catalog}' failed: {exc}")
            msg = str(exc).lower()
            if "default storage" in msg or "storage root" in msg:
                # Metastore uses Default Storage (no metastore-level
                # storage root). A catalog cannot be created via the API here,
                # and a non-metastore-admin cannot create one via the UI either,
                # so "CREATE CATALOG" is the wrong advice. Create the catalog
                # through the workspace UI (or ask a workspace/metastore admin)
                # with the same name, then re-run this script to apply grants.
                logger.warning(
                    f"[warn] this metastore uses Default Storage, so catalog '{catalog}' "
                    f"cannot be created via API/CLI (UI-only) and requires metastore-admin "
                    f"rights. Create it via the workspace UI (or have a workspace/metastore "
                    f"admin create it) named '{catalog}', then re-run install/grant_catalog.py."
                )
            else:
                logger.warning(
                    f"[warn] manually run: CREATE CATALOG IF NOT EXISTS {catalog};"
                    f"  then re-run install/grant_catalog.py"
                )
            return 0

    _grant(
        w,
        securable_type="CATALOG",
        full_name=catalog,
        principal=app_sp,
        privileges=CATALOG_PRIVS,
        sql_fallback=catalog_grant_sql(catalog, app_sp),
    )

    try:
        setup = _load_metamodel_setup()
    except (RuntimeError, ImportError):
        # The canonical constants live in the unloadable file, so the fallback
        # SQL spells the names out.
        schema_full = f"{catalog}._metamodel"
        logger.warning(
            f"[warn] app source {METAMODEL_SETUP_PATH} missing or not loadable; "
            f"skipping the _metamodel schema, vol_root volume and schema grant. Re-run "
            f"install/grant_catalog.py from a repo checkout, or manually run:"
        )
        logger.warning(f"[warn]   CREATE SCHEMA IF NOT EXISTS {schema_full};")
        logger.warning(f"[warn]   CREATE VOLUME IF NOT EXISTS {schema_full}.vol_root;")
        logger.warning(f"[warn]   {schema_grant_sql(schema_full, app_sp)}")
        return 0

    schema_full = f"{catalog}.{setup.METAMODEL_SCHEMA}"
    if _ensure_schema_and_volume(w, catalog=catalog):
        _grant(
            w,
            securable_type="SCHEMA",
            full_name=schema_full,
            principal=app_sp,
            privileges=SCHEMA_PRIVS,
            sql_fallback=schema_grant_sql(schema_full, app_sp),
        )
    else:
        logger.info(
            f"[skip] schema {schema_full} not present and could not be verified or "
            f"created; the agent creates it (and vol_root) on first vibe run, owned "
            f"by the app SP."
        )

    return 0


def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--profile", default=None, help="Databricks CLI profile")
    p.add_argument("--catalog", required=True, help="Unity Catalog name to grant on")
    p.add_argument(
        "--app-sp",
        required=True,
        help="App service principal application_id (UUID)",
    )
    args = p.parse_args(argv if argv is not None else sys.argv[1:])
    return grant_all(profile=args.profile, catalog=args.catalog, app_sp=args.app_sp)


if __name__ == "__main__":
    sys.exit(main())

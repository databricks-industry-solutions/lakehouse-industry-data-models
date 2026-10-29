"""Read-only install-time check that a principal can use a UC model service.

Run by ``install/install.sh`` once the app service principal exists, before the
app starts. It never grants anything: model service access is the customer's
governance call, and a DENY would win anyway.

- ``--enable-taxonomy-builder`` checks the app SP itself (``--principal``
  defaults to ``--app-sp``); a missing privilege stops the install.
- ``--enable-assessment --assess-reader-sp`` checks the reader SP
  (``--principal <reader>``). This mode is WARN-ONLY: every finding is a
  warning and the exit code is 0. It also warns when the reader does not exist
  and prints a reminder that the app SP needs the Service Principal User role
  on the reader (to run the assessment job as it); that role is not checked.

1. ``GET /api/2.1/unity-catalog/model-services/<full_name>``. A 404 stops the
   install ("not found"). A 403 or any other failure warns and continues; the
   app's own test call in Settings is then the check.
2. The SP's effective privileges (``/api/2.1/unity-catalog/effective-permissions``)
   must include ``EXECUTE`` on the model service, ``USE_CATALOG`` on its
   catalog and ``USE_SCHEMA`` on its schema. Each level also passes on
   ``ALL_PRIVILEGES`` or when the SP owns that securable. Effective
   permissions are reported per granting principal (e.g. the ``account users``
   group, observed on a test workspace), so privileges are unioned across assignments.
   A missing privilege stops the install with the exact ``databricks grants
   update`` commands (Catalog Explorer -> Permissions is the UI alternative).
   A response the script can't read (403, unexpected shape) warns and
   continues. A DENY may not show here; the app's test call as the SP catches it.

Exit codes: 0 = ok or could not verify (warned), 1 = stop the install
(app SP mode only), 2 = usage error (not a three-part name).

install.sh validates the name up front through ``install/deploy_settings.py``,
which applies the same rule.

The name rule is the app's canonical
``src/app/src/vibe_modeling/backend/taxonomy/service_name.py``, loaded by file
path (``vibe_modeling`` is not installed in the operator env), so the script
must run from a repo checkout.
"""

from __future__ import annotations

import argparse
import json
import logging
import shlex
import sys
from pathlib import Path
from typing import Any

from databricks.sdk import WorkspaceClient
from databricks.sdk.errors import NotFound

from _install_common import load_backend_module, workspace_client

logger = logging.getLogger("install.check_model_service")
logging.basicConfig(format="%(message)s", level=logging.INFO)

BACKEND_DIR = Path(__file__).resolve().parents[1] / "src/app/src/vibe_modeling/backend"
SERVICE_NAME_PATH = BACKEND_DIR / "taxonomy/service_name.py"
READER_SP_PATH = BACKEND_DIR / "assessment/reader_sp.py"

EXIT_OK = 0
EXIT_STOP = 1
EXIT_USAGE = 2

ALL_PRIVILEGES = "ALL_PRIVILEGES"


def _load_service_name():
    return load_backend_module(SERVICE_NAME_PATH)


class _Unverifiable(Exception):
    """The effective-permissions answer could not be read or interpreted."""


def _effective_privileges(w: WorkspaceClient, securable: str, full_name: str, principal: str) -> set[str]:
    try:
        resp = w.api_client.do(
            "GET",
            f"/api/2.1/unity-catalog/effective-permissions/{securable}/{full_name}",
            query={"principal": principal},
        )
    except Exception as exc:  # noqa: BLE001 - 403 or anything else: can't verify
        raise _Unverifiable(f"{securable} {full_name}: {exc}") from exc
    if not isinstance(resp, dict) or not isinstance(resp.get("privilege_assignments"), list):
        raise _Unverifiable(f"{securable} {full_name}: unexpected response {str(resp)[:200]}")
    privileges: set[str] = set()
    for assignment in resp["privilege_assignments"]:
        entries = assignment.get("privileges") if isinstance(assignment, dict) else None
        if not isinstance(entries, list):
            raise _Unverifiable(f"{securable} {full_name}: unexpected response {str(resp)[:200]}")
        for entry in entries:
            if isinstance(entry, dict) and isinstance(entry.get("privilege"), str):
                privileges.add(entry["privilege"])
    return privileges


def _owners(record: Any) -> set[str]:
    if not isinstance(record, dict):
        return set()
    return {v for k in ("owner", "effective_owner") if isinstance(v := record.get(k), str) and v}


def _securable_owners(w: WorkspaceClient, getter, full_name: str) -> set[str]:
    try:
        obj = getter(full_name)
    except Exception:  # noqa: BLE001 - ownership is a bonus pass, never a failure
        return set()
    owner = getattr(obj, "owner", None)
    return {owner} if isinstance(owner, str) and owner else set()


def _reader_exists(w: WorkspaceClient, principal: str) -> bool | None:
    """True/False when the workspace answers; None when it can't be read. The lookup is the app's ``find_reader_sp``."""
    try:
        return load_backend_module(READER_SP_PATH).find_reader_sp(w, principal) is not None
    except Exception as exc:  # noqa: BLE001 - warn-only: report and continue
        logger.warning(f"[warn] could not look up service principal {principal}: {exc}")
        return None


def check_reader(w: WorkspaceClient, *, reader: str, app_sp: str) -> None:
    """Warn-only: the reader must exist; the Service Principal User role is a reminder, not a check."""
    exists = _reader_exists(w, reader)
    if exists is False:
        logger.warning(
            f"[warn] reader service principal {reader} does not exist in this workspace. "
            f"Create it (or add it to the workspace), then set it in Settings -> Platform (Optional features)."
        )
    elif exists:
        logger.info(f"[ok]   reader service principal {reader} exists")
    logger.warning(
        f"[note] give the app SP {app_sp} the Service Principal User role on {reader} "
        f"(Service principals -> {reader} -> Permissions); without it the app cannot run the "
        f"assessment job as the reader."
    )


def grant_commands(missing: list[tuple[str, str, str]], app_sp: str) -> list[str]:
    """The Databricks CLI command for each missing ``(securable, full_name, privilege)``.

    All three levels use ``databricks grants update``: Unity Gateway model
    services are not granted through SQL, and one form for all three keeps the
    hint uniform. The CLI accepting ``model_service`` was confirmed on a test workspace
    (2026-10-18). Arguments are shell-quoted, so odd names stay one argument."""
    out = []
    for securable, full_name, privilege in missing:
        changes = json.dumps({"changes": [{"principal": app_sp, "add": [privilege]}]}, separators=(",", ":"))
        out.append(f"databricks grants update {securable} {shlex.quote(full_name)} --json {shlex.quote(changes)}")
    return out


def check(
    *,
    profile: str | None,
    model_service: str,
    app_sp: str,
    principal: str | None = None,
) -> int:
    """Check ``principal`` (default: the app SP) can use ``model_service``.

    A ``principal`` other than the app SP is the assessment reader: the check is
    warn-only (always exits 0), also warns when the reader does not exist, and
    reminds the admin of the app SP's Service Principal User role on it."""
    names = _load_service_name()
    try:
        catalog, schema, _service = names.split_model_service_name(model_service)
    except ValueError as exc:
        logger.error(f"ERROR: {exc}")
        return EXIT_USAGE
    principal = principal or app_sp
    warn_only = principal != app_sp
    who = f"the reader SP {principal}" if warn_only else f"the app service principal {app_sp}"
    schema_full = f"{catalog}.{schema}"
    w = workspace_client(profile)

    if warn_only:
        check_reader(w, reader=principal, app_sp=app_sp)

    service_owners: set[str] = set()
    try:
        record = w.api_client.do("GET", f"/api/2.1/unity-catalog/model-services/{model_service}")
    except NotFound:
        if warn_only:
            logger.warning(f"[warn] Model service '{model_service}' not found.")
            return EXIT_OK
        logger.error(f"ERROR: Model service '{model_service}' not found.")
        return EXIT_STOP
    except Exception as exc:  # noqa: BLE001 - 403 / other: the app's test call decides
        logger.warning(f"[warn] could not read model service '{model_service}': {exc}")
        record = None
    if isinstance(record, dict):
        listed = names.strip_resource_prefix(str(record.get("name", "")))
        if listed and listed != model_service:
            logger.warning(f"[warn] UC returned model service '{listed}' for '{model_service}'")
        service_owners = _owners(record)
        logger.info(f"[ok]   model service '{model_service}' exists")

    levels = [
        ("model_service", model_service, "EXECUTE", lambda: service_owners),
        ("catalog", catalog, "USE_CATALOG", lambda: _securable_owners(w, w.catalogs.get, catalog)),
        ("schema", schema_full, "USE_SCHEMA", lambda: _securable_owners(w, w.schemas.get, schema_full)),
    ]
    missing: list[tuple[str, str, str]] = []
    unverified: list[str] = []
    for securable, full_name, needed, owners in levels:
        try:
            have = _effective_privileges(w, securable, full_name, principal)
        except _Unverifiable as exc:
            label = "the reader SP's" if warn_only else "the app SP's"
            logger.warning(f"[warn] could not read {label} effective privileges on {exc}")
            unverified.append(f"{needed.replace('_', ' ')} on {securable} {full_name}")
            continue
        if needed in have or ALL_PRIVILEGES in have or principal in owners():
            label = "reader SP" if warn_only else "app SP"
            logger.info(f"[ok]   {label} has {needed} on {securable} {full_name}")
        else:
            missing.append((securable, full_name, needed))

    if missing:
        report = logger.warning if warn_only else logger.error
        prefix = "[warn]" if warn_only else "ERROR:"
        report(
            f"{prefix} {who} cannot use model service '{model_service}'. "
            f"Missing: " + ", ".join(f"{p} on {s} {n}" for s, n, p in missing) + "."
        )
        report(f"{'[warn] ' if warn_only else ''}An admin must run (Databricks CLI):")
        for stmt in grant_commands(missing, principal):
            report(f"  {stmt}")
        report(f"{'[warn] ' if warn_only else ''}Or grant the same privileges in Catalog Explorer -> Permissions on each object.")
        if catalog == "system":
            report(f"{'[warn] ' if warn_only else ''}Grants on the system catalog need a metastore admin or the MANAGE privilege.")
        if warn_only:
            logger.warning("[warn] Assessments run by this reader fail until then; the install continues.")
            return EXIT_OK
        logger.error("Then re-run install/install.sh.")
        return EXIT_STOP
    if unverified:
        if warn_only:
            logger.warning(
                f"[warn] confirm the reader SP {principal} has: {'; '.join(unverified)}. A failed "
                f"assessment run reports any gap."
            )
        else:
            logger.warning(
                f"[warn] confirm the app SP {app_sp} has: {'; '.join(unverified)}. The app's test "
                f"call in Settings -> Platform reports any gap."
            )
    return EXIT_OK


def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--profile", default=None, help="Databricks CLI profile")
    p.add_argument("--model-service", required=True, help="UC model service full name (catalog.schema.service)")
    p.add_argument("--app-sp", required=True, help="App service principal application_id (UUID)")
    p.add_argument(
        "--principal",
        default=None,
        help="Principal to check (default: --app-sp). Another principal is the assessment reader: warn-only.",
    )
    args = p.parse_args(argv if argv is not None else sys.argv[1:])
    return check(
        profile=args.profile,
        model_service=args.model_service,
        app_sp=args.app_sp,
        principal=args.principal,
    )


if __name__ == "__main__":
    sys.exit(main())

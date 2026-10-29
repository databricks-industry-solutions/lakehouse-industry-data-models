"""Provision Lakebase Autoscaling infrastructure for the vibe-modeling app.

Runs after `databricks bundle deploy` (the app service principal must exist) to
ensure the target workspace has:
  1. A Lakebase Autoscaling Postgres **Project** (hosts branches + endpoints)
  2. A `production` **Branch** with a `primary` **Endpoint** (the compute)
  3. A Postgres **Role** for the app service principal
  4. A Postgres **Database** named after `--catalog`, **owned by the app SP**
  5. Optional Postgres **Roles** for human operators (via `--grant-user`)

Capacity: a new project's compute autoscales between `--min-cu` and `--max-cu`
(defaults in `install/_feature_defaults.sh`, validated by
`deploy_settings.check_capacity`). For an existing project the script prints the
primary endpoint's current range and changes it only with `--resize`.

The app's Lakebase Postgres holds control-plane state (businesses, runs,
agent_config, model_versions) — internal to the app, never exposed to UC. The
`--catalog` flag also drives the UC catalog name where the agent stores its
``_metamodel`` schema and per-business deploys, but that catalog is a regular
managed UC catalog the agent reads/writes directly via SQL warehouse — it is
not bound to this Postgres database, and `install/grant_catalog.py` issues the
relevant grants there separately.

The app SP owning the database is what makes the install self-contained: the
SP inherits USAGE+CREATE on schema `public` via `pg_database_owner` membership,
so no separate `GRANT` step is needed, and tables created by `create_all()`
on first boot are owned by the SP.

The script is **idempotent** and **non-destructive**:
  - Every `create_*` is gated by a `get_*` / `list_*` check — re-running is a no-op
  - If the database already exists with a different owner (legacy installs),
    ownership is transferred via `ALTER DATABASE … OWNER TO` and `REASSIGN OWNED
    BY` while connected as the installing user (who holds
    `databricks_superuser` membership by virtue of being the project creator).
  - No `delete_*` / `force=True` / `purge=True` is ever called
  - An existing endpoint's autoscaling range changes only with `--resize`

Designed to run against any Databricks workspace (AWS or Azure) using the
standard CLI profile. See `INSTALL.md` and `install/install.sh` for end-to-end
usage.

Usage:
    python install/provision_lakebase.py \\
        --profile my-workspace \\
        --project  vibe-modeling \\
        --catalog  vibe_modeling \\
        --app-sp   <app-service-principal-application-id> \\
        [--min-cu 1 --max-cu 4] [--resize]
"""

from __future__ import annotations

import argparse
import sys
import time
from datetime import timedelta
from urllib.parse import urlsplit, urlunsplit

from databricks.sdk import WorkspaceClient
from databricks.sdk.errors import NotFound
from databricks.sdk.service.database import (
    DatabaseInstance,
)
from databricks.sdk.service.postgres import (
    Branch,
    BranchSpec,
    Database,
    DatabaseDatabaseSpec,
    Endpoint,
    EndpointSpec,
    EndpointType,
    InitialEndpointSpec,
    Project,
    ProjectDefaultEndpointSettings,
    ProjectSpec,
    Role,
    RoleAuthMethod,
    RoleIdentityType,
    RoleRoleSpec,
)
from google.protobuf.field_mask_pb2 import FieldMask

from _install_common import lakebase_branch_name, lakebase_endpoint_name, lakebase_project_name, workspace_client
from deploy_settings import MAX_CU, MIN_CU, check_capacity, load_defaults


def get_or_create_project(
    w: WorkspaceClient,
    project_id: str,
    *,
    display_name: str | None = None,
    pg_version: int = 16,
    min_cu: float,
    max_cu: float,
) -> Project:
    """Return the existing Autoscaling project or create a new one.

    A new project is created with an initial `production` branch and a `primary`
    compute endpoint sized for autoscaling (min_cu..max_cu). Wait for the LRO.
    """
    try:
        proj = w.postgres.get_project(name=lakebase_project_name(project_id))
        print(f"[ok] project '{project_id}' exists")
        return proj
    except NotFound:
        print(
            f"[create] provisioning Autoscaling project '{project_id}' "
            f"(pg v{pg_version}, autoscaling {min_cu}-{max_cu} CU)"
        )
        print(f"[wait]   initial endpoint + branch provisioning takes 1-3 minutes...")
        try:
            op = w.postgres.create_project(
                project=Project(
                    spec=ProjectSpec(
                        display_name=display_name or project_id,
                        pg_version=pg_version,
                        default_endpoint_settings=ProjectDefaultEndpointSettings(
                            autoscaling_limit_min_cu=min_cu,
                            autoscaling_limit_max_cu=max_cu,
                        ),
                    ),
                    initial_endpoint_spec=InitialEndpointSpec(),
                ),
                project_id=project_id,
            )
        except Exception as e:
            if "already exists" in str(e).lower():
                sys.exit(
                    f"[abort] project id '{project_id}' is reserved by a recent deletion.\n"
                    f"        Lakebase reserves deleted project IDs for ~7 days.\n"
                    f"        Either wait or pick a different --project (e.g. '{project_id}-v2')."
                )
            raise
        return op.wait()


def reconcile_capacity(
    w: WorkspaceClient,
    *,
    project_id: str,
    min_cu: float,
    max_cu: float,
    resize: bool,
) -> bool:
    """Report the primary endpoint's autoscaling range; set ``min_cu..max_cu`` only with ``resize``.

    Returns True when the endpoint was updated.
    """
    name = lakebase_endpoint_name(project_id)
    ep = w.postgres.get_endpoint(name=name)
    status = ep.status
    current = (status.autoscaling_limit_min_cu, status.autoscaling_limit_max_cu) if status else (None, None)
    shown = f"{current[0]:g}-{current[1]:g} CU" if None not in current else "not reported yet"
    if current == (min_cu, max_cu):
        print(f"[ok] compute autoscaling {shown}")
        return False
    if not resize and None in current:
        print(f"[info] compute autoscaling range not reported yet (requested {min_cu:g}-{max_cu:g} CU)")
        return False
    if not resize:
        print(f"[info] compute autoscaling is {shown}; requested {min_cu:g}-{max_cu:g} CU. "
              f"Re-run with --lakebase-resize (install.sh) or --resize to change it.")
        return False
    print(f"[update] compute autoscaling {shown} -> {min_cu:g}-{max_cu:g} CU")
    op = w.postgres.update_endpoint(
        name=name,
        # endpoint_type is a required field of the spec; the mask leaves it unchanged.
        endpoint=Endpoint(spec=EndpointSpec(
            endpoint_type=(status.endpoint_type if status and status.endpoint_type
                           else EndpointType.ENDPOINT_TYPE_READ_WRITE),
            autoscaling_limit_min_cu=min_cu,
            autoscaling_limit_max_cu=max_cu,
        )),
        update_mask=FieldMask(paths=["spec.autoscaling_limit_min_cu", "spec.autoscaling_limit_max_cu"]),
    )
    op.wait()
    return True


def get_or_create_endpoint(
    w: WorkspaceClient,
    *,
    project_id: str,
    branch_id: str = "production",
    endpoint_id: str = "primary",
) -> Endpoint:
    """Return the primary endpoint (created by `initial_endpoint_spec`) or create one."""
    try:
        ep = w.postgres.get_endpoint(name=lakebase_endpoint_name(project_id, branch_id, endpoint_id))
        host = ep.status.hosts.host if ep.status and ep.status.hosts else "(no host)"
        print(f"[ok] endpoint '{endpoint_id}' on '{branch_id}' exists (host={host})")
        return ep
    except NotFound:
        print(f"[create] endpoint '{endpoint_id}' on branch '{branch_id}'")
        op = w.postgres.create_endpoint(
            parent=lakebase_branch_name(project_id, branch_id),
            endpoint=Endpoint(
                spec=EndpointSpec(endpoint_type=EndpointType.ENDPOINT_TYPE_READ_WRITE),
            ),
            endpoint_id=endpoint_id,
        )
        return op.wait()


def ensure_database_owned_by(
    w: WorkspaceClient,
    *,
    project_id: str,
    postgres_database: str,
    owner_role: Role,
    endpoint_host: str,
    branch_id: str = "production",
) -> Database:
    """Ensure the Postgres DB exists with the given role as owner.

    Three paths:
    - Fresh install: create with `spec.role = <owner>`
    - Re-run, owner already correct: no-op
    - Re-run, owner is some other role: transfer ownership and all objects
      inside the DB to the new owner via SQL (requires `databricks_superuser`
      membership, which the installer has by virtue of creating the project).

    `Database` resources in the Autoscaling API have system-generated resource
    names (`db-<random>`); the user-visible Postgres database name lives in
    `status.postgres_database`. We list existing DBs and match on that.
    """
    parent = lakebase_branch_name(project_id, branch_id)
    existing: Database | None = None
    for d in w.postgres.list_databases(parent=parent):
        full = w.postgres.get_database(name=d.name)
        status_db = full.status.postgres_database if full.status else None
        if status_db == postgres_database:
            existing = full
            break

    owner_resource = owner_role.name
    owner_pg_name = owner_role.status.postgres_role if owner_role.status else None

    if existing is None:
        print(f"[create] postgres database '{postgres_database}' (owner={owner_pg_name})")
        op = w.postgres.create_database(
            parent=parent,
            database=Database(
                spec=DatabaseDatabaseSpec(
                    postgres_database=postgres_database,
                    role=owner_resource,
                ),
            ),
        )
        return op.wait()

    current_owner_resource = existing.status.role if existing.status else None
    if current_owner_resource == owner_resource:
        print(f"[ok] postgres database '{postgres_database}' exists, owner correct ({owner_pg_name})")
        return existing

    # Owner mismatch — transfer.
    old_owner_pg_name = None
    if current_owner_resource:
        try:
            old_role = w.postgres.get_role(name=current_owner_resource)
            old_owner_pg_name = old_role.status.postgres_role if old_role.status else None
        except Exception:
            pass
    print(
        f"[transfer] postgres database '{postgres_database}' owner: "
        f"{old_owner_pg_name!r} -> {owner_pg_name!r}"
    )
    # Step 1 — flip the DB owner via the Autoscaling API. This avoids the
    # SQL `ALTER DATABASE OWNER TO` path, which requires the executor to be a
    # member of the new owner role (not something we can arrange from the
    # outside on Lakebase).
    try:
        op = w.postgres.update_database(
            name=existing.name,
            database=Database(spec=DatabaseDatabaseSpec(role=owner_resource)),
            update_mask=FieldMask(paths=["spec.role"]),
        )
        op.wait()
        print(f"[ok]   database owner transferred via postgres.update_database")
    except Exception as e:
        print(f"[warn] update_database(spec.role) failed: {e}")
        return existing

    # Step 2 — reassign any tables/sequences the old owner still holds inside
    # this DB. Common case after the app has been running: zero objects (the
    # app SP already created everything), and this is a no-op.
    _reassign_old_owner_objects(
        w=w,
        project_id=project_id,
        postgres_database=postgres_database,
        endpoint_host=endpoint_host,
        new_owner_pg_name=owner_pg_name,
        old_owner_pg_name=old_owner_pg_name,
    )
    return existing


def get_or_create_role(
    w: WorkspaceClient,
    *,
    project_id: str,
    postgres_role: str,
    identity_type: RoleIdentityType,
    branch_id: str = "production",
) -> Role:
    """Create a Postgres role for a Databricks identity (user, SP, group) if missing.

    Matches an existing role by its `status.postgres_role` (the Postgres
    role name, usually the SP application_id or user email).
    """
    parent = lakebase_branch_name(project_id, branch_id)
    for r in w.postgres.list_roles(parent=parent):
        full = w.postgres.get_role(name=r.name)
        existing_pg_role = full.status.postgres_role if full.status else None
        if existing_pg_role == postgres_role:
            print(f"[ok] role for '{postgres_role}' ({identity_type.value}) exists")
            return full
    print(f"[create] role for {identity_type.value} '{postgres_role}'")
    op = w.postgres.create_role(
        parent=parent,
        role=Role(
            spec=RoleRoleSpec(
                postgres_role=postgres_role,
                identity_type=identity_type,
                auth_method=RoleAuthMethod.LAKEBASE_OAUTH_V1,
            ),
        ),
    )
    return op.wait()


def _generate_pg_token(w: WorkspaceClient, project_id: str, branch_id: str = "production") -> str:
    """Generate a short-lived Postgres auth token for the current caller.

    The app service principal and any human user granted via `get_or_create_role`
    can both obtain tokens this way to authenticate via pg OAuth.
    """
    cred = w.postgres.generate_database_credential(
        endpoint=lakebase_endpoint_name(project_id, branch_id),
    )
    if not cred.token:
        sys.exit(f"[abort] generate_database_credential returned empty token for '{project_id}'")
    return cred.token


def _reassign_old_owner_objects(
    w: WorkspaceClient,
    *,
    project_id: str,
    postgres_database: str,
    endpoint_host: str,
    new_owner_pg_name: str | None,
    old_owner_pg_name: str | None,
) -> None:
    """Move any tables/sequences still owned by the old role to the new owner.

    The DB owner flip is handled via `w.postgres.update_database`; this step
    is only needed when objects inside the DB are owned by the prior user role
    (a legacy case — most installs have the app SP as the creator of all
    tables, so this is a no-op).

    `REASSIGN OWNED BY <old> TO <new>` requires the executor to have the
    privileges of both roles. The installer has the old owner's privileges
    (they are that role). Membership in the new owner is routed via
    `SET ROLE databricks_superuser`, which Lakebase sets up so it carries the
    necessary membership chain.
    """
    if not new_owner_pg_name or not old_owner_pg_name or old_owner_pg_name == new_owner_pg_name:
        return
    try:
        import psycopg  # type: ignore
    except ImportError:
        print("[warn] psycopg not installed; skipping REASSIGN step")
        return

    token = _generate_pg_token(w, project_id)
    user_name = w.current_user.me().user_name

    try:
        conn = psycopg.connect(
            host=endpoint_host,
            port=5432,
            dbname=postgres_database,
            user=user_name,
            password=token,
            sslmode="require",
            autocommit=True,
        )
    except Exception as e:
        print(f"[warn] could not connect to '{postgres_database}' for REASSIGN: {e}")
        return

    try:
        cur = conn.cursor()
        cur.execute(
            "SELECT COUNT(*) FROM pg_class c "
            "JOIN pg_roles r ON c.relowner = r.oid "
            "WHERE r.rolname = %s AND c.relnamespace "
            "NOT IN (SELECT oid FROM pg_namespace WHERE nspname IN ('pg_catalog','information_schema','__db_system'))",
            (old_owner_pg_name,),
        )
        (owned_count,) = cur.fetchone()
        if owned_count == 0:
            print(f"[ok]   no user objects owned by \"{old_owner_pg_name}\" — REASSIGN not needed")
            return
        new_q = new_owner_pg_name.replace('"', '""')
        old_q = old_owner_pg_name.replace('"', '""')
        try:
            cur.execute(f'REASSIGN OWNED BY "{old_q}" TO "{new_q}"')
            print(f"[ok]   REASSIGN OWNED BY \"{old_owner_pg_name}\" TO \"{new_owner_pg_name}\" ({owned_count} objects)")
        except Exception as e:
            print(f"[warn] REASSIGN OWNED BY failed (continuing): {e}")
    finally:
        conn.close()


def _normalize_host(w: WorkspaceClient, profile: str | None) -> WorkspaceClient:
    """Strip any path or query (e.g. `/?o=<workspace-id>`) from the configured host.

    Azure workspace URLs often include a `?o=<workspace-id>` query string. The
    SDK concatenates `<host>/api/...` which produces a malformed URL when the
    host has a query string. Strip it for API calls.
    """
    raw_host = w.config.host or ""
    split = urlsplit(raw_host)
    if split.query or split.path.rstrip("/"):
        clean = urlunsplit((split.scheme, split.netloc, "", "", ""))
        if clean != raw_host:
            print(f"[info] normalizing host '{raw_host}' -> '{clean}'")
            return workspace_client(profile, host=clean)
    return w


def _endpoint_host_or_wait(
    w: WorkspaceClient,
    *,
    project_id: str,
    timeout_seconds: int = 300,
) -> str:
    """Return the endpoint host, polling until it's assigned."""
    deadline = time.time() + timeout_seconds
    while True:
        ep = w.postgres.get_endpoint(name=lakebase_endpoint_name(project_id))
        host = ep.status.hosts.host if ep.status and ep.status.hosts else None
        if host:
            return host
        if time.time() > deadline:
            sys.exit(f"[abort] endpoint for project '{project_id}' has no host after {timeout_seconds}s")
        print(f"[wait]   endpoint host not yet assigned; retrying...")
        time.sleep(5)


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument(
        "--profile",
        default=None,
        help="Databricks CLI profile name (default: env vars / default profile)",
    )
    p.add_argument(
        "--project",
        required=True,
        help="Lakebase Autoscaling project ID (e.g. 'vibe-modeling')",
    )
    p.add_argument(
        "--catalog",
        required=True,
        help=(
            "UC catalog name the agent uses for `_metamodel` and per-business "
            "deploys. Also used as the default Postgres database name inside "
            "the Lakebase project."
        ),
    )
    p.add_argument(
        "--database",
        default=None,
        help="Postgres database name inside the project (defaults to --catalog)",
    )
    p.add_argument(
        "--app-sp",
        required=True,
        help=(
            "Service principal application_id of the Databricks App. The Postgres "
            "database is created with this SP as its owner, so the app has inherent "
            "CREATE/USAGE on schema public without explicit grants. Capture the SP "
            "from `databricks apps get vibe-modeling` after `bundle deploy`."
        ),
    )
    p.add_argument(
        "--grant-user",
        action="append",
        default=[],
        help=(
            "User email(s) who should get a Postgres login role for ad-hoc ops "
            "(connecting to psql, running migrations). Optional — the app does not "
            "need any human role to function. May be repeated."
        ),
    )
    defaults = load_defaults()
    p.add_argument("--min-cu", default=defaults[MIN_CU],
                   help="Autoscaling minimum in CU for a new project (default: %(default)s)")
    p.add_argument("--max-cu", default=defaults[MAX_CU],
                   help="Autoscaling maximum in CU for a new project (default: %(default)s)")
    p.add_argument("--resize", action="store_true",
                   help="Also apply --min-cu/--max-cu to an existing project's primary endpoint")
    # Back-compat alias: accept --instance (the legacy flag from the deprecated
    # `w.database.create_database_instance` API path)
    p.add_argument(
        "--instance",
        default=None,
        help="(deprecated) Alias for --project",
    )
    args = p.parse_args()

    if args.instance and not args.project:
        args.project = args.instance
    try:
        min_cu, max_cu = check_capacity(args.min_cu, args.max_cu)
    except ValueError as exc:
        p.error(str(exc))

    w = workspace_client(args.profile)
    w = _normalize_host(w, args.profile)
    print(f"[info] targeting workspace: {w.config.host}")

    postgres_db = args.database or args.catalog

    # 1. Autoscaling project (+ initial production branch + primary endpoint).
    #    The installer is the project creator and gets `databricks_superuser`
    #    membership automatically, which is what allows them to run the
    #    ownership-transfer SQL in step 4 if needed.
    get_or_create_project(w, args.project, min_cu=min_cu, max_cu=max_cu)

    # 2. Primary endpoint (verify / create if somehow missing), and its
    #    autoscaling range (changed on an existing project only with --resize).
    get_or_create_endpoint(w, project_id=args.project)
    reconcile_capacity(w, project_id=args.project, min_cu=min_cu, max_cu=max_cu, resize=args.resize)
    endpoint_host = _endpoint_host_or_wait(w, project_id=args.project)

    # 3. Postgres role for the app service principal. Created before the
    #    database so the database can be created with the SP as its owner.
    app_sp_role = get_or_create_role(
        w,
        project_id=args.project,
        postgres_role=args.app_sp,
        identity_type=RoleIdentityType.SERVICE_PRINCIPAL,
    )

    # 4. Postgres database. Owned by the app SP — that membership implicitly
    #    grants USAGE+CREATE on schema public (via pg_database_owner), so no
    #    explicit grants are needed and tables the app creates at boot are
    #    owned by the SP as well.
    ensure_database_owned_by(
        w,
        project_id=args.project,
        postgres_database=postgres_db,
        owner_role=app_sp_role,
        endpoint_host=endpoint_host,
    )

    # 5. Optional human login roles for ad-hoc ops. The app does not need these.
    for user in args.grant_user:
        get_or_create_role(
            w,
            project_id=args.project,
            postgres_role=user,
            identity_type=RoleIdentityType.USER,
        )

    # 6. Print connection details
    print("---")
    print("Provisioning complete. Connection details:")
    print(f"  LAKEBASE_PROJECT={args.project}")
    print(f"  LAKEBASE_HOST={endpoint_host}")
    print(f"  LAKEBASE_PORT=5432")
    print(f"  LAKEBASE_DATABASE_NAME={postgres_db}")
    print("")
    print("The app reads these via env vars in src/app/app.yml:")
    print(f"  VIBE_MODELING_LAKEBASE_PROJECT={args.project}")
    print(f"  VIBE_MODELING_DATABASE_NAME={postgres_db}")
    print(f"  VIBE_MODELING_DEPLOYMENT_CATALOG={args.catalog}")


if __name__ == "__main__":
    main()

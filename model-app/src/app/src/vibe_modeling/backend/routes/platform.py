"""Platform / workspace bootstrap endpoints.

Covers identity, RBAC role lookup, per-user preferences, the workspace
catalog picker, and the bundled-agent routes surfaced in Settings. These are the cross-cutting endpoints the UI hits to stand up the
shell of the app — none of them are scoped to a single business or run.
"""

from __future__ import annotations

import logging
from datetime import datetime, timezone

from fastapi import APIRouter, HTTPException, Query
from pydantic import BaseModel, Field
from sqlalchemy import delete
from sqlmodel import select

from ..._metadata import api_prefix
from ..core import Dependencies
from ..core._bundled_agent_init import AgentChangeAborted, point_agent_at_bundled
from ..core._identity import actor_label, current_user_profile
from ..core._runs import count_in_flight_runs
from ..core._uc_privileges import app_catalog_capabilities, cached_positive
from ..db_models import UserPreference
from ..models import (
    AgentConfigOut,
    CatalogCapabilityOut,
    CatalogOut,
    CurrentUserOut,
    UserPreferenceDeleteOut,
    UserPreferenceIn,
    UserPreferenceOut,
    VersionOut,
)
from ._helpers import _build_dbx_job_url, _get_or_create_agent_config

logger = logging.getLogger(__name__)

router = APIRouter(prefix=api_prefix)


@router.get("/version", response_model=VersionOut, operation_id="version")
async def version():
    return VersionOut.from_metadata()


class ClientGatewayErrorIn(BaseModel):
    """A transient edge-proxy failure (502/503/504) the browser observed on an
    app request, reported so it lands in the APP logs.

    A client-side auto-retry (E-04, kickstart POST) otherwise recovers the
    request in the browser and the 502 never reaches `databricks apps logs`,
    hiding a real recurrence. The client beacons every occurrence here - even
    ones a later retry recovers - so the edge condition stays observable
    server-side. Co-located here (not `models.py`): this is a platform-level
    observability contract with no DB/Out counterpart, mirroring the
    lifecycle-endpoint co-location convention in `routes.industry_models`.
    """

    status: int = Field(description="Gateway status the browser saw (502/503/504).")
    path: str = Field(description="App request path that failed, e.g. /api/.../kickstart.")
    attempt: int = Field(description="1-based attempt number that failed.")
    will_retry: bool = Field(
        default=False, description="Whether the client will auto-retry this attempt."
    )
    context: str | None = Field(
        default=None,
        description="Free-form context (e.g. kickstart industry id + new name).",
    )


class ClientTelemetryAck(BaseModel):
    """Ack for a client telemetry beacon (the event was logged server-side)."""

    logged: bool


@router.post(
    "/client-telemetry/gateway-error",
    response_model=ClientTelemetryAck,
    operation_id="reportClientGatewayError",
)
def report_client_gateway_error(
    data: ClientGatewayErrorIn, headers: Dependencies.Headers
) -> ClientTelemetryAck:
    """Record a browser-observed transient gateway error in the app logs.

    Emits one WARNING per occurrence (retried or not) so an E-04-style 502
    recurrence stays diagnosable in `databricks apps logs` even when a
    client-side retry recovers it. Deliberately does nothing else - no DB
    write, no fan-out - so the beacon is cheap and cannot itself fail the
    user's flow.
    """
    logger.warning(
        "client-reported gateway error: status=%s path=%s attempt=%s "
        "will_retry=%s user=%s context=%s",
        data.status,
        data.path,
        data.attempt,
        data.will_retry,
        actor_label(headers),
        data.context,
    )
    return ClientTelemetryAck(logged=True)


@router.get("/current-user", response_model=CurrentUserOut, operation_id="currentUser")
def me(headers: Dependencies.Headers) -> CurrentUserOut:
    """Get current user info from Databricks Apps headers, or return anonymous.

    Public by design (no `Dependencies.UserIdentity`): the UI calls it before
    role data is available, and an identity-less caller gets the anonymous
    profile instead of a 401.
    """
    return current_user_profile(headers)


@router.get("/user/role", response_model=dict, operation_id="getUserRole")
def get_user_role(role: Dependencies.Role):
    """Get the current user's resolved RBAC role."""
    return {"role": role.value, "display_name": role.value.replace("_", " ").title()}


# --- User Preferences ---


@router.get(
    "/user/preferences",
    response_model=list[UserPreferenceOut],
    operation_id="getUserPreferences",
)
def get_user_preferences(
    session: Dependencies.Session,
    user_id: Dependencies.UserIdentity,
):
    """Get all preferences for the current user."""
    return session.exec(
        select(UserPreference).where(UserPreference.user_id == user_id)
    ).all()


@router.put(
    "/user/preferences/{key}",
    response_model=UserPreferenceOut,
    operation_id="setUserPreference",
)
def set_user_preference(
    key: str,
    body: UserPreferenceIn,
    session: Dependencies.Session,
    user_id: Dependencies.UserIdentity,
):
    """Upsert a user preference."""
    pref = session.get(UserPreference, (user_id, key))
    if pref:
        pref.value = body.value
        pref.updated_at = datetime.now(timezone.utc)
    else:
        pref = UserPreference(user_id=user_id, key=key, value=body.value)
        session.add(pref)
    session.commit()
    session.refresh(pref)
    return pref


@router.delete(
    "/user/preferences/{key}",
    response_model=UserPreferenceDeleteOut,
    operation_id="deleteUserPreference",
)
def delete_user_preference(
    key: str,
    session: Dependencies.Session,
    user_id: Dependencies.UserIdentity,
):
    """Delete the caller's preference row for ``key``.

    Idempotent: a missing row returns ``{"deleted": false}``, never 404.
    Touches only the caller's own row.
    """
    result = session.execute(
        delete(UserPreference).where(
            UserPreference.user_id == user_id, UserPreference.key == key
        )
    )
    session.commit()
    return UserPreferenceDeleteOut(deleted=result.rowcount > 0)


# --- Workspace catalogs (used by run-form pickers) ---


@router.get(
    "/catalogs",
    response_model=list[CatalogOut],
    operation_id="listCatalogs",
)
def list_catalogs(ws: Dependencies.Client):
    """Return the UC catalogs visible to the app service principal.

    Populates the catalog pickers. The list is naturally filtered by what the
    SP can `USE CATALOG` on: catalogs the SP cannot see are not returned by
    `w.catalogs.list()`. No privilege check runs here, so the list never
    waits on one; `can_create_schema` is filled only from a cached positive
    check (`getCatalogCapabilities` does the checking).
    """
    try:
        catalogs = list(ws.catalogs.list())
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to list catalogs: {e}") from e
    return [
        CatalogOut(
            name=c.name,
            comment=c.comment or "",
            owner=c.owner or "",
            can_create_schema=True if cached_positive(c.name) else None,
        )
        for c in catalogs
        if c.name
    ]


@router.get(
    "/catalogs/capabilities",
    response_model=list[CatalogCapabilityOut],
    operation_id="getCatalogCapabilities",
)
def get_catalog_capabilities(names: list[str] = Query(default=[])):
    """What the app service principal can do in each named catalog, read-only.

    Checks at most `CAPABILITY_CHECK_CAP` unique names per call, in request
    order, on a bounded pool with a timeout; the rest come back unchecked
    (`null` fields). Positive results are cached for ten minutes, negative
    ones never, so a grant an admin adds shows on the next call. The reads go
    through the app SP's own short-timeout client, not `Dependencies.Client`.
    """
    return [
        CatalogCapabilityOut(
            name=name,
            create_schema=cap.create_schema,
            use_metamodel=cap.use_metamodel,
            create_schema_fix=cap.create_schema_fix,
            use_metamodel_fix=cap.use_metamodel_fix,
        )
        for name, cap in app_catalog_capabilities(names)
    ]


# --- Bundled agent notebook ---


@router.post(
    "/admin/agent/switch-to-bundled",
    response_model=AgentConfigOut,
    operation_id="switchToBundledAgent",
)
def switch_to_bundled_agent(
    session: Dependencies.Session,
    ws: Dependencies.Client,
    config: Dependencies.Config,
    _role: Dependencies.AdminOnly,
) -> AgentConfigOut:
    """Point the agent configuration at the bundled notebook.

    Uploads the bundled notebook into the app's agent folder, then moves
    ``AgentConfig.notebook_path`` and the persistent job to it in one save
    (``core/_bundled_agent_init.point_agent_at_bundled``, the step the boot
    upgrade runs). From then on the app owns the notebook and upgrades it on
    boot. The admin's own notebook is left in place, unchanged.

    409 while a run is in flight (the job must not move under it), also when
    a run starts or the configuration is saved during the switch. 500 (the
    app's error handler sanitizes the detail) when the build has no bundled notebook, the upload fails, or
    the job cannot be updated; in each case the configuration is unchanged.
    """
    in_flight = count_in_flight_runs(session)
    if in_flight:
        raise HTTPException(
            status_code=409,
            detail=(
                f"{in_flight} run(s) in flight. Wait for them to finish, or cancel them "
                "on their run pages, then switch to the bundled agent."
            ),
        )
    cfg = _get_or_create_agent_config(session, config)
    try:
        point_agent_at_bundled(session, ws, cfg, expected_path=cfg.notebook_path)
    except AgentChangeAborted as e:
        raise HTTPException(
            status_code=409, detail=f"The agent was not switched: {e}. Try again."
        ) from e
    except RuntimeError as e:
        raise HTTPException(status_code=500, detail=str(e)) from e
    return AgentConfigOut(
        **cfg.model_dump(),
        job_url=_build_dbx_job_url(ws, cfg.job_id),
    )

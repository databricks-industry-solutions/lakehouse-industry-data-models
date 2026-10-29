"""The app's router list (``ROUTERS``) and a walker over the routes it mounts.

``app.py`` passes ``ROUTERS`` to ``create_app`` and re-exports it. Tests and dev
scripts that need the app's route surface import it from here: importing
``app.py`` builds the app and reconfigures root logging, this module does neither.
"""

from __future__ import annotations

from collections.abc import Iterable

from fastapi import APIRouter
from fastapi.routing import APIRoute

from .router import router
from . import explorer  # noqa: F401 - registers explorer routes on the shared router
from . import diagram  # noqa: F401 - registers diagram routes on the shared router
from .routes import (
    _dev_fixtures,
    assessments,
    businesses,
    config,
    deployment,
    import_root,
    industries,
    industry_models,
    oob,
    orphan_schemas,
    platform,
    run_changes,
    run_link,
    run_report,
    sectors,
    sources,
    taxonomy,
    uc_browse,
    versions,
    vibe_inputs,
)

ROUTERS: tuple[APIRouter, ...] = (
    router,
    platform.router,
    industries.router,
    sectors.router,
    config.router,
    businesses.router,
    versions.router,
    run_report.router,
    run_changes.config_router,
    run_changes.router,
    deployment.router,
    sources.router,
    taxonomy.router,
    industry_models.router,
    uc_browse.router,
    import_root.router,
    oob.router,
    vibe_inputs.router,
    _dev_fixtures.router,
    assessments.config_router,
    assessments.router,
    run_link.router,
    orphan_schemas.router,
)


def iter_api_routes(routes: Iterable) -> list[tuple[str, APIRoute]]:
    """(full path, route) for every API route, through included routers.

    FastAPI 0.135 flattens ``include_router`` into ``app.routes`` as
    ``APIRoute`` objects. FastAPI 0.143 keeps each included router as one
    nested entry whose ``effective_route_contexts()`` walks its routes
    recursively. Each context carries the full ``path``, the ``methods`` and
    the effective ``dependant`` (route, router and ``include_router``
    dependencies together, as the flattened route has on 0.135), so the
    context itself stands in for the route.
    """
    out: list[tuple[str, APIRoute]] = []
    for r in routes:
        if isinstance(r, APIRoute):
            out.append((r.path, r))
        elif hasattr(r, "effective_route_contexts"):
            for ctx in r.effective_route_contexts():
                if isinstance(ctx.original_route, APIRoute):
                    out.append((ctx.path, ctx))
    return out


def iter_route_methods(routes: Iterable) -> list[tuple[str, str, APIRoute]]:
    """(method, full path, route) for every API route, HEAD and OPTIONS left out."""
    return [
        (method, path, r)
        for path, r in iter_api_routes(routes)
        for method in r.methods or []
        if method not in ("HEAD", "OPTIONS")
    ]

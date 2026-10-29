from __future__ import annotations

from collections.abc import AsyncIterator
from contextlib import asynccontextmanager
from functools import lru_cache

from fastapi import APIRouter, FastAPI

from ..._metadata import api_prefix, app_name, dist_dir
from ._base import LifespanDependency
from ._config import logger

# --- Lifespan ---


@asynccontextmanager
async def _chain_dep_lifespans(
    deps: list[LifespanDependency],
    app: FastAPI,
) -> AsyncIterator[None]:
    """Chain multiple dependency lifespans into a single nested context manager."""
    if not deps:
        yield
        return

    head, *tail = deps

    async with head.lifespan(app):
        async with _chain_dep_lifespans(tail, app):
            yield


# --- Factory ---


def create_app(
    *,
    routers: list[APIRouter] | None = None,
) -> FastAPI:
    """Create and configure a FastAPI application.

    Dependencies are discovered automatically from the Dependency registry.
    All concrete Dependency subclasses that have been imported are instantiated
    and their lifespans are chained in import order.

    Args:
        routers: List of APIRouter instances to include in the app.

    Returns:
        Configured FastAPI application instance.
    """
    all_deps: list[LifespanDependency] = []
    for dep in LifespanDependency._registry:
        try:
            all_deps.append(dep())
        except Exception as e:
            logger.error(f"Failed to instantiate dependency {dep.__name__}: {e}")
            raise e

    @asynccontextmanager
    async def _composed_lifespan(app: FastAPI):
        async with _chain_dep_lifespans(all_deps, app):
            yield

    app = FastAPI(title=app_name, lifespan=_composed_lifespan)

    # PLAN #53 — request-id correlation must wrap every other middleware
    # so the ContextVar is set before any handler / dependency runs.
    from ._request_id import RequestIdMiddleware

    app.add_middleware(RequestIdMiddleware)

    api_router: APIRouter = create_router()
    for dep in all_deps:
        for r in dep.get_routers():
            api_router.include_router(r)
    app.include_router(api_router)

    for router in routers or []:
        if router is not api_router:
            app.include_router(router)

    from ..error_sanitization import register_error_handlers

    if dist_dir.exists():
        from ._static import CachedStaticFiles, spa_fallback

        app.mount("/", CachedStaticFiles(directory=dist_dir, html=True))
        register_error_handlers(app, spa_fallback=spa_fallback)
    else:
        register_error_handlers(app)

    return app


# singleton APIRouter with the application's API prefix
@lru_cache(maxsize=1)
def create_router() -> APIRouter:
    """Return the singleton APIRouter with the application's API prefix."""
    return APIRouter(prefix=api_prefix)

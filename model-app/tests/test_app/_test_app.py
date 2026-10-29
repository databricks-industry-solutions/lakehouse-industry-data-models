"""The app under test: app routers plus the production error handlers.

Route tests build their app here, so they see the HTTP error bodies the
deployed app returns (``error_sanitization.register_error_handlers``). With
no arguments the app mounts every app router (``backend._routers.ROUTERS``);
a test that needs its own small app passes just the routers it exercises.
"""

from __future__ import annotations

from fastapi import APIRouter, FastAPI

from vibe_modeling.backend._routers import ROUTERS
from vibe_modeling.backend.error_sanitization import register_error_handlers


def make_test_app(*routers: APIRouter) -> FastAPI:
    """A FastAPI app with ``routers`` (default: every app router) and the production error handlers."""
    app = FastAPI()
    for r in routers or ROUTERS:
        app.include_router(r)
    register_error_handlers(app)
    return app

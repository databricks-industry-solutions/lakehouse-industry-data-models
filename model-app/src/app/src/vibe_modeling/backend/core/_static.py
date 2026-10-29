from __future__ import annotations

import os

from fastapi import Request
from fastapi.responses import FileResponse
from starlette.datastructures import Headers
from starlette.responses import Response
from starlette.staticfiles import NotModifiedResponse, StaticFiles
from starlette.types import Scope

from ..._metadata import api_prefix, dist_dir


class CachedStaticFiles(StaticFiles):
    """StaticFiles with proper Cache-Control headers for SPA deployments.

    - Hashed assets (Vite `assets/` dir): cached immutably (hash changes on every build).
    - Everything else (index.html, etc.): `no-cache` — always revalidate via ETag/304.
    """

    def file_response(
        self,
        full_path: str | os.PathLike[str],
        stat_result: os.stat_result,
        scope: Scope,
        status_code: int = 200,
    ) -> Response:
        request_headers = Headers(scope=scope)
        response = FileResponse(
            full_path, status_code=status_code, stat_result=stat_result
        )

        if "/assets/" in str(full_path):
            response.headers["cache-control"] = "public, max-age=31536000, immutable"
        else:
            response.headers["cache-control"] = "no-cache"

        if self.is_not_modified(response.headers, request_headers):
            return NotModifiedResponse(response.headers)
        return response


def spa_fallback(request: Request) -> Response | None:
    """The SPA's ``index.html`` for a browser page navigation that matched no
    API route or static file, so the client router can handle it; ``None``
    for everything else (API paths, assets, non-GET, non-HTML requests).

    ``error_sanitization.register_error_handlers`` consults it for 404s.
    """
    path = request.url.path
    if path.startswith(api_prefix):
        return None
    if request.method != "GET" or "text/html" not in request.headers.get("accept", ""):
        return None
    # A last segment with a dot looks like a file: answer the real 404.
    if "." in path.split("/")[-1]:
        return None
    return FileResponse(dist_dir / "index.html")

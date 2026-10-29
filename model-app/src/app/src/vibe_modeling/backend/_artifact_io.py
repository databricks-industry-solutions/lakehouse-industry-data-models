"""Shared artifact I/O helpers used by per-run and per-version artifact endpoints.

The endpoints themselves live in `router.py` (`/runs/.../artifacts/...`) and
`routes/versions.py` (`/businesses/.../model-versions/.../artifacts/...`). The Volume read,
filename derivation, zip-pack logic, content preview (text + hex), and
inline-download MIME mapping are identical across both surfaces, so they
live here to avoid drift between the two endpoints.
"""

from __future__ import annotations

import io
import zipfile
from typing import Any, Iterable, Literal

from fastapi import HTTPException
from fastapi.responses import StreamingResponse

from .db_models import RunArtifact


# --- Preview / download tuning ---------------------------------------------

MAX_ARTIFACT_TEXT_BYTES = 512 * 1024  # 500 KB cap for UTF-8 text preview
HEX_PREVIEW_BYTES = 4096

# Extensions we treat as UTF-8 text for GET .../content?format=text
ARTIFACT_TEXT_SUFFIXES: frozenset[str] = frozenset(
    {
        ".md", ".mdx", ".txt", ".json", ".jsonl", ".ndjson",
        ".sql", ".csv", ".tsv", ".yml", ".yaml", ".xml",
        ".html", ".htm", ".toml", ".ini", ".cfg", ".conf",
        ".properties", ".env", ".rst", ".ipynb", ".graphql",
        ".gql", ".log",
        ".py", ".pyi", ".pyw",
        ".ts", ".tsx", ".jsx", ".mjs", ".cjs", ".js",
        ".css", ".scss", ".sass", ".less", ".vue", ".svelte",
        ".rs", ".go", ".rb", ".java", ".kt", ".scala", ".php",
        ".pl", ".pm", ".r", ".c", ".h", ".cpp", ".cc", ".cxx",
        ".hpp", ".hh", ".cs", ".swift",
        ".sh", ".bash", ".zsh", ".ps1", ".bat", ".cmd",
        ".tf", ".hcl", ".gradle", ".lock", ".cmake", ".mk",
        ".dockerignore", ".editorconfig", ".gitattributes",
        ".feature", ".dart", ".ex", ".exs", ".erl",
        ".hs", ".lhs", ".ml", ".mli", ".fs", ".fsx",
        ".clj", ".cljs", ".edn", ".lua", ".vim",
        ".proto", ".avsc", ".wsdl", ".xsl",
        ".jsonld", ".ttl", ".rdf", ".nt", ".nq", ".n3",
        ".trig", ".owl", ".shex", ".shacl",
    }
)

# Safe inline Content-Types for ?inline=1 (browser embedding). Omit HTML —
# HTML preview uses the text API + sandboxed srcDoc in the UI.
ARTIFACT_INLINE_MEDIA_TYPES: dict[str, str] = {
    ".pdf": "application/pdf",
    ".png": "image/png",
    ".jpg": "image/jpeg",
    ".jpeg": "image/jpeg",
    ".gif": "image/gif",
    ".webp": "image/webp",
    ".bmp": "image/bmp",
    ".svg": "image/svg+xml",
    ".ico": "image/x-icon",
    ".tif": "image/tiff",
    ".tiff": "image/tiff",
}


def artifact_path_suffix(path: str) -> str:
    """Lowercased extension including the leading dot, or ``""`` if none."""
    if not path or "." not in path:
        return ""
    return "." + path.rsplit(".", 1)[-1].lower()


def artifact_filename(path: str) -> str:
    """Extract a safe filename from a Volume path for Content-Disposition."""
    name = path.rsplit("/", 1)[-1] if "/" in path else path
    return name or "artifact"


def read_artifact_bytes(ws, path: str) -> bytes:
    try:
        resp = ws.files.download(path)
        return resp.contents.read()
    except Exception as e:
        raise HTTPException(
            status_code=502,
            detail=f"Could not read artifact file {artifact_filename(path)!r}: {e}",
        )


def build_artifact_content_response(
    ws,
    artifact: RunArtifact,
    content_format: Literal["text", "hex"],
) -> dict[str, Any]:
    """Read artifact bytes from its Volume path and return a preview payload.

    * ``format=text`` (default at the route layer): returns
      ``{content, truncated, size_bytes}`` for UTF-8 text-like extensions
      (markdown, code, config, etc.), capped at :data:`MAX_ARTIFACT_TEXT_BYTES`.
    * ``format=hex``: returns ``{hex, size_bytes, bytes_previewed, truncated}``
      for **any** artifact — first :data:`HEX_PREVIEW_BYTES` as hex for
      binary inspection in the UI.

    Raises ``HTTPException(404)`` if the artifact has no file path, ``415`` if
    a text preview is requested for a non-text suffix or invalid UTF-8, and
    ``502`` (via :func:`read_artifact_bytes`) on a Volume read failure.
    """
    path = artifact.file_path or ""
    if not path:
        raise HTTPException(status_code=404, detail="Artifact has no file path")

    suffix = artifact_path_suffix(path)
    data = read_artifact_bytes(ws, path)
    size = len(data)

    if content_format == "hex":
        preview = data[:HEX_PREVIEW_BYTES]
        return {
            "hex": preview.hex(),
            "size_bytes": size,
            "bytes_previewed": len(preview),
            "truncated": size > len(preview),
        }

    if suffix not in ARTIFACT_TEXT_SUFFIXES:
        raise HTTPException(
            status_code=415,
            detail=(
                f"Cannot decode {suffix!r} as UTF-8 text for preview. "
                "Try format=hex for a hex dump, or download the file."
            ),
        )

    truncated = size > MAX_ARTIFACT_TEXT_BYTES
    chunk = data[:MAX_ARTIFACT_TEXT_BYTES] if truncated else data
    try:
        text = chunk.decode("utf-8")
    except UnicodeDecodeError:
        raise HTTPException(status_code=415, detail="File is not valid UTF-8 text")

    return {"content": text, "truncated": truncated, "size_bytes": size}


def build_artifact_download_response(
    ws,
    artifact: RunArtifact,
    *,
    inline: bool,
) -> StreamingResponse:
    """Stream a single artifact's raw bytes as a file download.

    When ``inline=True`` AND the file extension is in
    :data:`ARTIFACT_INLINE_MEDIA_TYPES`, returns ``Content-Disposition: inline``
    with a browser-friendly Content-Type so the UI can embed PDFs / images
    directly. Otherwise returns ``attachment`` with ``application/octet-stream``.
    """
    path = artifact.file_path or ""
    if not path:
        raise HTTPException(status_code=404, detail="Artifact has no file path")

    data = read_artifact_bytes(ws, path)
    filename = artifact_filename(path)
    suffix = artifact_path_suffix(path)
    if inline and suffix in ARTIFACT_INLINE_MEDIA_TYPES:
        media_type = ARTIFACT_INLINE_MEDIA_TYPES[suffix]
        disp = "inline"
    else:
        media_type = "application/octet-stream"
        disp = "attachment"
    return StreamingResponse(
        iter([data]),
        media_type=media_type,
        headers={"Content-Disposition": f'{disp}; filename="{filename}"'},
    )


def dedupe_arcname(seen: set[str], name: str) -> str:
    """Return a unique arcname for ``name`` given the already-emitted ``seen``.

    If ``name`` is free, returns it unchanged. If it collides, suffixes the base
    with an incrementing ``_n`` (``model.json`` -> ``model_1.json``;
    extensionless ``README`` -> ``README_1``) until free. The chosen name is
    added to ``seen`` so consecutive calls stay collision-free. The single home
    for filename-collision dedupe so the flat-download, bundle-export, and
    GitHub-publish surfaces can't drift.
    """
    arcname = name
    if arcname in seen:
        base, _, ext = arcname.rpartition(".")
        n = 1
        while True:
            candidate = f"{base}_{n}.{ext}" if base else f"{arcname}_{n}"
            if candidate not in seen:
                arcname = candidate
                break
            n += 1
    seen.add(arcname)
    return arcname


def write_artifacts_to_zip(
    zf: zipfile.ZipFile,
    ws,
    artifacts: Iterable[RunArtifact],
    prefix: str = "",
    reserved: set[str] | None = None,
) -> None:
    """Write artifact rows into an open ZipFile, deduping name collisions.

    ``prefix`` nests every entry under a directory (e.g. an export bundle dir);
    leave it empty for a flat zip. The single home for the read + collision-
    dedupe logic so the flat-download and bundle-export surfaces can't drift.

    ``reserved`` is a set of UN-prefixed arcnames the caller has already written
    to ``zf`` outside this helper (e.g. a bundle's pre-written ``model.json``).
    The dedupe ``seen`` set is seeded from it so a companion artifact colliding
    with a reserved name dedupes (``model.json`` -> ``model_1.json``) instead of
    silently overwriting the pre-write. The caller's set is copied, not mutated.
    """
    seen: set[str] = set(reserved) if reserved else set()
    for a in artifacts:
        if not a.file_path:
            continue
        data = read_artifact_bytes(ws, a.file_path)
        arcname = dedupe_arcname(seen, artifact_filename(a.file_path))
        zf.writestr(f"{prefix}{arcname}", data)


def build_artifacts_zip_bytes(ws, artifacts: Iterable[RunArtifact]) -> bytes:
    """Pack artifact rows into a flat zip in memory, deduping name collisions."""
    buf = io.BytesIO()
    with zipfile.ZipFile(buf, "w", zipfile.ZIP_DEFLATED) as zf:
        write_artifacts_to_zip(zf, ws, artifacts)
    buf.seek(0)
    return buf.getvalue()

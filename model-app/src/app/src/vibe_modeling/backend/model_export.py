"""Model export — reconstruct a ``model.json`` bundle from the Lakebase
version rows. The inverse of :meth:`ModelSyncService.sync_from_model_json`.

``sync_from_model_json`` reads a ``model.json`` (agent envelope or flat form)
and writes ``Domain`` / ``Product`` / ``Attribute`` / ``ForeignKeyLink`` rows
keyed on a ``ModelVersion.id``. This module does the reverse: it reads those
rows back via a SQLModel ``Session`` and assembles a ``model.json`` that, when
fed back through ``sync_from_model_json``, reproduces the same structure.

Why a standalone reader (not a method on ``ModelSyncService``): the serializer
has no dependency on the sync service's WorkspaceClient / warehouse plumbing or
its private mutators — it only needs ORM reads. Keeping it here also avoids
coupling the export endpoint to the in-flight ``model_sync.py`` surface.

The export schema is the exact inverse of the import field map. The key
contract points (kept aligned with ``sync_from_model_json``):

* envelope: ``{"model": {type, name, version, description, domains[]}}`` —
  the same three-key-ish shape ``import_model.detect_schema`` unwraps. We emit
  ``type="business"`` and ``version="v{N}_{scope}"`` so a re-import passes the
  importer's v0.3+ fingerprint checks.
* ``domains[]`` → ``name`` / ``division`` / ``description`` / ``database_name``
  / ``references`` / ``products[]`` — mirrors the ``Domain`` columns that
  ``sync_from_model_json`` reads (``d.get("name")`` etc.).
* ``products[]`` → ``product`` (the importer accepts ``product`` or ``name``;
  we emit ``product`` to match what ``_assemble_model_dict`` writes) plus
  ``table_name`` / ``description`` / ``type`` / ``data_type`` / ``primary_key``
  / ``subdomain`` / ``reference`` / ``attributes[]``.
* ``attributes[]`` → ``attribute`` plus ``column_name`` / ``type`` /
  ``description`` / ``business_glossary_term`` / ``tags`` / ``value_regex`` /
  ``foreign_key_to`` (``domain.table.column``) / ``references`` / ``primary_key``.

The product-level ``primary_key`` name and ``foreign_key_to`` are the
load-bearing parts of the round-trip: on import, ``is_pk = attr_name ==
product.primary_key`` and ``fk_to`` drives the ``ForeignKeyLink`` rows. The
attribute-level ``primary_key`` boolean we emit is informational only -- it
does NOT survive the round-trip, since import re-derives each attribute's PK
flag from the product-level ``primary_key`` name rather than reading the
per-attribute boolean.
"""

from __future__ import annotations

import io
import json
import zipfile
from dataclasses import dataclass
from typing import Callable, Iterable, Optional

from sqlmodel import Session, select

from ._artifact_io import artifact_filename, dedupe_arcname, read_artifact_bytes
from .core._names import agent_business_segment
from .db_models import (
    Attribute,
    Business,
    Domain,
    ModelVersion,
    Product,
    RunArtifact,
)


# --- On-disk bundle layout descriptor --------------------------------------
#
# Single code-level source of truth for where an exported bundle lands on
# disk. This mirrors the agent's Volume folder layout: ``<industry>/<scope>_vN/``
# with ``model.json`` (and companion artifacts) under it. It is intentionally
# NOT UI-configurable — a constant/function so the layout is easy to change in
# exactly one place later (e.g. when GitHub publishing lands a richer tree).


@dataclass(frozen=True)
class BundleLayout:
    """Resolved on-disk paths for an exported model bundle.

    ``dir`` is the bundle root (relative); ``model_json_path`` is where the
    reconstructed ``model.json`` lives within it. Companion artifacts (the
    ``_artifact_io`` zip side) sit alongside ``model.json`` under ``dir``.
    """

    industry: str
    scope: str
    version: int
    dir: str
    model_json_path: str


def bundle_layout(
    industry: str, scope: str, version: int, *, dir_override: str | None = None
) -> BundleLayout:
    """Build the canonical bundle layout for ``<industry>/v{N}/<scope>/``.

    ``industry`` is normalized with :func:`agent_business_segment` so the
    folder is a safe path segment (lowercase, ``_``-joined). ``scope`` is
    lowercased (``ecm`` / ``mvm``). The version folder mirrors the agent's
    nested Volume convention (``v{N}/{scope}``) so an exported tree reads the
    same as the on-Volume layout. Importers resolve the legacy flat
    ``{scope}_v{N}`` layout on the read side (``core/_paths.version_dir_key``
    and the volume readers), so a round-trip of an older bundle still works.

    When ``dir_override`` is given (and non-blank after strip), it is used RAW
    as the bundle root (only surrounding ``/`` stripped) — it is a real path the
    caller resolved (e.g. a user-typed publish target or a round-tripped
    ``source_repo_path``), NOT run through ``agent_business_segment``. ``dir``
    and ``model_json_path`` derive from it; ``industry``/``scope``/``version``
    still reflect the passed args (they name the publish branch + PR title).
    """
    industry_seg = agent_business_segment(industry) or "model"
    scope_seg = (scope or "").lower()
    if dir_override is not None and dir_override.strip():
        root = dir_override.strip().strip("/")
    else:
        root = f"{industry_seg}/v{version}/{scope_seg}"
    return BundleLayout(
        industry=industry_seg,
        scope=scope_seg,
        version=version,
        dir=root,
        model_json_path=f"{root}/model.json",
    )


def resolve_bundle_root(
    *,
    override: str | None,
    business: Business | None,
    scope: str,
    version: int,
) -> str:
    """Resolve the bundle ROOT (relative path up to AND INCLUDING the version
    folder) for a publish / export, per ADR D-049 precedence:

      1. non-blank ``override`` (a user-typed publish ``target_path``) → returned
         RAW (already a full path incl. version folder; only surrounding ``/``
         stripped).
      2. else if ``business.source_repo_path`` is set → take its last path
         segment (the industry-folder id) and round-trip it through
         ``bundle_layout(<segment>, scope, version).dir`` → ``<industry>/v{N}/<scope>``.
      3. else → fall back to ``bundle_layout(business.name, scope, version).dir``.

    The single source of truth for where a bundle lands, shared by the GitHub
    publish tree and the downloadable zip so they can never diverge.
    ``industry_alignment`` is intentionally NOT consulted anywhere.
    """
    if override and override.strip():
        return override.strip().strip("/")
    if business is not None and business.source_repo_path:
        seg = business.source_repo_path.rstrip("/").rsplit("/", 1)[-1]
        if seg:
            return bundle_layout(seg, scope, version).dir
    name = business.name if business is not None else ""
    return bundle_layout(name, scope, version).dir


# --- Serializer (inverse of sync_from_model_json) --------------------------


def export_model_json(session: Session, version_id: str) -> dict:
    """Reconstruct a ``model.json`` envelope from a version's Lakebase rows.

    Reads the ``ModelVersion`` and its ``Domain`` → ``Product`` →
    ``Attribute`` rows and assembles the agent-envelope ``model.json`` shape
    the importer accepts. Raises :class:`LookupError` if ``version_id`` does
    not resolve to a ``ModelVersion``.

    The output is the exact inverse of ``sync_from_model_json``'s field map,
    so ``sync_from_model_json(export_model_json(...))`` is structure-stable.

    Batched: one set-based select per element table (domains/products/
    attributes), each scoped by the parent ids already collected from the
    previous select - not one select per domain plus one per product (the
    former per-row lazy-load shape). Each select is still ordered exactly as
    the old per-parent selects were (``created_at``, ``name``); since a
    single ORDER BY over the whole table is a total order, grouping the rows
    into per-parent lists afterwards (by simple append, in select order)
    preserves that same per-parent ordering.
    """
    mv = session.get(ModelVersion, version_id)
    if mv is None:
        raise LookupError(f"ModelVersion {version_id!r} not found")

    business = session.get(Business, mv.business_id)
    model_name = business.name if business else ""
    # ModelVersion carries no description column — the model-level
    # description lives on the Business row (the importer maps the
    # model.json ``description`` to nothing persisted per-version, so the
    # Business summary is the closest durable source for re-emit).
    model_description = business.description if business else ""

    scope = (mv.scope or "").lower()
    model_version = f"v{mv.version}_{scope}" if scope else f"v{mv.version}"

    domain_rows = session.exec(
        select(Domain)
        .where(Domain.version_id == version_id)
        .order_by(Domain.created_at, Domain.name)
    ).all()
    domain_ids = [d.id for d in domain_rows]

    products_by_domain: dict[str, list[Product]] = {did: [] for did in domain_ids}
    if domain_ids:
        product_rows = session.exec(
            select(Product)
            .where(Product.domain_id.in_(domain_ids))
            .order_by(Product.created_at, Product.name)
        ).all()
        for p in product_rows:
            products_by_domain[p.domain_id].append(p)
    else:
        product_rows = []

    product_ids = [p.id for p in product_rows]
    attrs_by_product: dict[str, list[Attribute]] = {pid: [] for pid in product_ids}
    if product_ids:
        attr_rows = session.exec(
            select(Attribute)
            .where(Attribute.product_id.in_(product_ids))
            .order_by(Attribute.created_at, Attribute.name)
        ).all()
        for a in attr_rows:
            attrs_by_product[a.product_id].append(a)

    domains_out: list[dict] = []
    for d in domain_rows:
        products_out: list[dict] = []
        for p in products_by_domain[d.id]:
            attributes_out = [
                {
                    "attribute": a.name,
                    "column_name": a.column_name,
                    "type": a.type,
                    "description": a.description,
                    "business_glossary_term": a.business_glossary_term,
                    "tags": a.tags,
                    "value_regex": a.value_regex,
                    "foreign_key_to": a.foreign_key_to,
                    "references": a.references,
                    "primary_key": a.is_primary_key,
                }
                for a in attrs_by_product[p.id]
            ]

            products_out.append(
                {
                    "product": p.name,
                    "table_name": p.table_name,
                    "description": p.description,
                    "type": p.type,
                    "data_type": p.data_type,
                    "primary_key": p.primary_key,
                    "subdomain": p.subdomain,
                    "reference": p.reference,
                    "attributes": attributes_out,
                }
            )

        domains_out.append(
            {
                "name": d.name,
                "division": d.division,
                "description": d.description,
                "database_name": d.database_name,
                "references": d.references,
                "products": products_out,
            }
        )

    model = {
        "type": "business",
        "name": model_name,
        "version": model_version,
        "description": model_description,
        "domains": domains_out,
    }

    return {"model": model}


# --- Bundle assembly -------------------------------------------------------


def iter_bundle_files(
    ws,
    layout: BundleLayout,
    model_json: dict,
    artifacts: Iterable[RunArtifact],
    read_artifact: Optional[Callable[[RunArtifact], bytes]] = None,
) -> Iterable[tuple[str, bytes]]:
    """Yield every file in an exported bundle as ``(path, bytes)`` pairs.

    The single source of truth for a bundle's on-disk contents: first the
    reconstructed ``model.json`` at :attr:`BundleLayout.model_json_path`, then
    each companion artifact nested under ``layout.dir/`` with the same
    filename-collision dedupe the flat artifact-download surface uses
    (``model.json`` -> ``model_1.json``, etc.). Both the zip packer
    (:func:`build_bundle_zip_bytes`) and the GitHub publish tree consume this
    so the two can't diverge on layout.

    ``read_artifact(artifact)``, when given, returns each artifact's bytes in
    place of reading its Volume file: the publish strips the prefixes an
    import added with it (``services/github_publish.PublishStrip.read``). The
    zip passes none.
    """
    model_arcname = artifact_filename(layout.model_json_path)
    yield (
        layout.model_json_path,
        json.dumps(model_json, indent=2, sort_keys=False).encode("utf-8"),
    )

    seen: set[str] = {model_arcname}
    for a in artifacts:
        if not a.file_path:
            continue
        data = (
            read_artifact(a) if read_artifact is not None else read_artifact_bytes(ws, a.file_path)
        )
        arcname = dedupe_arcname(seen, artifact_filename(a.file_path))
        yield (f"{layout.dir}/{arcname}", data)


def build_bundle_zip_bytes(
    ws,
    layout: BundleLayout,
    model_json: dict,
    artifacts: Iterable[RunArtifact],
) -> bytes:
    """Pack a model bundle into a zip in memory under the layout's directory.

    Consumes :func:`iter_bundle_files` so the zip's contents are identical to
    the GitHub publish tree — model.json + companion artifacts, same paths,
    same collision dedupe.
    """
    buf = io.BytesIO()
    with zipfile.ZipFile(buf, "w", zipfile.ZIP_DEFLATED) as zf:
        for path, data in iter_bundle_files(ws, layout, model_json, artifacts):
            zf.writestr(path, data)
    buf.seek(0)
    return buf.getvalue()

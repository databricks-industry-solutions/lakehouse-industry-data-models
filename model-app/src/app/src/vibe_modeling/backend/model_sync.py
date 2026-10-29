"""Model sync - loads model structure from model.json in Volumes (primary) or
the Delta metamodel tables (fallback) and syncs into Lakebase."""

import json
import logging
import re
import time
import uuid
from dataclasses import dataclass
from typing import Optional

from databricks.sdk import WorkspaceClient
from sqlalchemy import bindparam, insert as sa_insert, update as sa_update
from sqlmodel import Session, select

from .core import _sql
from .core._names import (
    _AGENT_SEGMENT_NON_SAFE,
    agent_business_segment,
    escape_sql_literal as _esc,
    normalize_scope as _normalize_scope,
)
from .core._paths import (
    metamodel_root_for_business,
    version_dir_candidates,
)
from .core.anchor_resolve import (
    AnchorMaps,
    _AnchorFKs,
    _Coords,
    _resolve_coords,
    prefetch_anchor_maps,
)
from .agent_compat import extract_version_provenance, extract_vibe_scope_facts
from .fk import is_fk_attribute
from .services._bulk_model_io import (
    _row_values,
    bulk_delete_version_elements,
    bulk_insert_elements,
)
from .db_models import (
    Attribute,
    Domain,
    ForeignKeyLink,
    ModelVersion,
    Product,
    Run,
    RunArtifact,
    RunProgressEvent,
    VibeInput,
    VibeInputContextLink,
    _now,
)
from .core._ids import LINK_NS as NV_LINK_NS, VI_NV_NS
from .model_lineage import link_previous_version, upsert_subdomains
from .services.metamodel_registry import ensure_metamodel_registry
from .models import NextVibeCategory, VibeInputOrigin, VibeInputPriority, VibeInputStatus

logger = logging.getLogger(__name__)


class _SyncEmptyError(RuntimeError):
    """Raised when a completed run's sync yields no model structure.

    Two structurally-empty cases raise this: ``sync_model()`` returning
    ``False`` (no Volume model.json and no Delta fallback), and a payload
    that parsed to 0 domains (the ``_assert_sync_complete`` zero-domain
    guard). Both mean a resync will not repair the version until the agent's
    Volume output is populated, so callers land the ``ModelVersion`` in
    ``sync_state="sync_empty"`` — distinct from ``incomplete_metadata``
    (data was found but a write failed, where resync may help).

    Defined here (not in ``_generation_common``) because ``model_sync`` is
    imported by ``_generation_common`` and ``vibe_iterate``; the reverse
    import would create a cycle.
    """


# Bound of a registry read during sync: the 50 s server wait, then polls 2 s
# apart, about 110 s in total (wall clock); then it is cancelled and raises.
_QUERY_WAIT = "50s"
_QUERY_TIMEOUT_S = 110.0
_QUERY_POLL_INTERVAL_S = 2.0
# The registry setup before a request-time Delta write: the same bound as the
# import writer's request budget.
_REGISTRY_SETUP_TIMEOUT_S = 90.0

# Fixed uuid5 namespaces so structured next-vibe input/link ids are stable across
# re-ingestion (idempotent upsert keying). VI_NV_NS + NV_LINK_NS are imported
# from ``core/_ids`` (the single home for derived-id namespaces) so the
# sync-time materializer keys ids off one source of truth. The sync-time
# materializer is the only producer of ``agent_next_vibe`` rows.
NV_ARTIFACT_NS = uuid.UUID("b1c2d3e4-5f6a-5b7c-8d9e-0f1a2b3c4d5e")

NEXT_VIBES_TXT_ARTIFACT_TYPE = "next_vibes_txt"

# Sentinel distinguishing "caller didn't pass a preload" from "caller passed
# a preload whose value is legitimately None" (e.g. no next-vibes artifact
# found) for the ``sync_model``/``_capture_run_metadata`` preload kwargs -
# see ``load_resync_sources``.
_NOT_PRELOADED = object()


def _warn_if_unsanitized(func_name: str, business_name: str) -> None:
    """Log a WARNING if ``business_name`` contains chars outside the agent
    normalization rule (lower → replace non-[a-z0-9_] with ``_`` →
    collapse ``_+`` → strip ``_`` → digit-prefix ``_``).

    Catches drift at the boundary: any ``ModelSyncService`` entry point that
    receives a raw ``business.name`` would otherwise build a Volume path
    pointing at a sibling folder the agent never wrote to. The check is
    advisory — it never raises — because callers may legitimately pass a
    pre-normalized value (which is what we expect; the warning fires when
    they don't).
    """
    if business_name and _AGENT_SEGMENT_NON_SAFE.search(business_name):
        logger.warning(
            "[%s] business_name=%r contains chars outside agent rule "
            "(lower → replace non-[a-z0-9_] with _ → collapse _ → strip _); "
            "caller likely forgot to normalize",
            func_name,
            business_name,
        )


def _batched(rows: list[str], n: int):
    """Yield successive n-sized batches from `rows`."""
    for i in range(0, len(rows), n):
        yield rows[i : i + n]


def _extract_confidence_score(payload: object) -> Optional[float]:
    """Pull a confidence score from a model.json or next_vibes.json payload.

    The agent publishes the score in multiple places depending on artifact:
    top-level `confidence_score`, `_vibe_session_metadata.confidence_score`
    (model.json), or `_next_vibe_metadata.confidence_score` (next_vibes.json).
    Values on the 0-100 scale are normalised to 0-1 so the stored float is
    consistent across sources.
    """
    if not isinstance(payload, dict):
        return None
    for key in ("confidence_score",):
        raw = payload.get(key)
        if isinstance(raw, (int, float)) and not isinstance(raw, bool):
            return float(raw) / 100.0 if raw > 1 else float(raw)
    for meta_key in ("_vibe_session_metadata", "_next_vibe_metadata"):
        meta = payload.get(meta_key)
        if isinstance(meta, dict):
            raw = meta.get("confidence_score")
            if isinstance(raw, (int, float)) and not isinstance(raw, bool):
                return float(raw) / 100.0 if raw > 1 else float(raw)
    return None


@dataclass
class _NextVibeFinding:
    """One structured agent next-vibe finding parsed from ``next_vibes.txt``.

    The lossy converter flattened every finding into a single instructions
    blob; this carries the per-finding signal the Model Evolution Metrics
    (ADR D-044) consume:

    * ``ordinal`` — stable per-payload key (drives the deterministic input id
      so re-ingestion is idempotent and ordering is preserved).
    * ``category`` — the :class:`NextVibeCategory` classification.
    * ``priority`` — severity mapped onto the canonical
      :class:`VibeInputPriority` (PRIORITY directives are ``high``; SA findings
      and other-known-issues are ``low``).
    * ``target`` — the ``domain.product`` element name the finding is about,
      resolved to an element anchor at materialization time (the D-045
      name-based anchoring pattern). The target is resolved to product level
      (domain.product); a trailing column segment, if present, is currently
      ignored.
    * ``quality_score`` — the payload's Model Quality Score as a 0..1 fraction
      (the Quality Score the metrics average over the open backlog).
    """

    ordinal: int
    category: NextVibeCategory
    priority: VibeInputPriority
    title: str
    description: str
    target: str
    quality_score: Optional[float]


def _extract_quality_score(text: str) -> Optional[int]:
    """Pull the integer Model Quality Score (0..100) from ``next_vibes.txt``.

    Accepts both the headline ``**Model Quality Score: N/100**`` and the
    footer ``Deterministic score: N/100`` forms the agent emits.
    """
    m = re.search(
        r"(?:Model Quality Score|Deterministic score)\s*[:=]\s*(\d+)\s*/\s*100",
        text,
    )
    if not m:
        return None
    try:
        return int(m.group(1))
    except ValueError:
        return None


# A ``domain.product`` or ``domain.product.column`` dotted element reference.
# A trailing column segment is accepted so the whole token is consumed, but
# ``_resolve_target_anchor`` anchors at the product and ignores the column.
_ELEMENT_REF_RE = re.compile(r"\b([a-z][a-z0-9_]*(?:\.[a-z][a-z0-9_]*){1,2})\b")

# SA finding line: ``  - [SA:<class>] <detail>``.
_SA_FINDING_RE = re.compile(
    r"(?:^|\n)\s*[-*]\s*\[SA:([a-z_]+)\]\s*([^\n]+)",
    re.IGNORECASE,
)

# PRIORITY directive: ``**PRIORITY N — <kind>: <target>** — <description>``.
# Tolerant of em-dash and double-hyphen separators (both occur in the wild).
_PRIORITY_RE = re.compile(
    r"\*\*PRIORITY\s+(\d+)\s+[—\-]+\s+([a-z_]+):\s*([^\*\n]+?)\*\*"
    r"\s*[—\-]+\s*([^\n*]+)",
    re.IGNORECASE,
)

# "Other known issues …(N):" section header, then one ``- <detail>`` per line.
_OTHER_HEADER_RE = re.compile(
    r"(?:^|\n)\s*Other known issues[^\n]*\n((?:\s*[-*]\s*[^\n]+\n?)+)",
    re.IGNORECASE,
)
_OTHER_LINE_RE = re.compile(r"\s*[-*]\s*([^\n]+)")


def _finding_text(finding: dict) -> str:
    """Render a finding dict's title + description into the input ``text``.

    The ``title\\n\\ndescription`` convention is the inverse of the
    ``_next_vibe_item_from_input`` split in ``routes/_helpers.py``, so a
    materialized row round-trips back to a card with title and body intact.
    """
    title = (finding.get("title") or "").strip()
    description = (finding.get("description") or "").strip()
    if title and description:
        return f"{title}\n\n{description}"
    return title or description


def _first_element_ref(text: str) -> str:
    """Return the first ``domain.product[.col]`` reference in ``text``, or ""."""
    m = _ELEMENT_REF_RE.search(text or "")
    return m.group(1) if m else ""


# Quoted element names (``'name'`` / ``"name"``) and snake_case/underscore
# tokens. A lone bare common word (no quotes, no underscore) is deliberately
# NOT a candidate, so a product literally named ``order`` does not match the
# English word "order" in prose (D-045 precision rule).
_QUOTED_TOKEN_RE = re.compile(r"['\"]([^'\"]+)['\"]")
_SNAKE_TOKEN_RE = re.compile(r"\b[a-z][a-z0-9]*(?:_[a-z0-9]+)+\b")


def _extract_name_tokens(detail: str) -> set[str]:
    """Extract lowercased element-name candidates from finding prose.

    Prefers quoted tokens, then snake_case/underscore tokens. A bare English
    word matches only when quoted or underscore-shaped.
    """
    if not detail:
        return set()
    tokens: set[str] = set()
    for m in _QUOTED_TOKEN_RE.finditer(detail):
        tokens.add(m.group(1).strip().lower())
    for m in _SNAKE_TOKEN_RE.finditer(detail.lower()):
        tokens.add(m.group(0))
    return tokens


def _match_target_by_name(
    pairs: list[tuple[str, str]], domain_names: set[str], detail: str
) -> str:
    """Resolve a prose finding to a ``domain.product`` or ``domain`` anchor.

    ``pairs`` are the version's ``(domain_name, product_name)`` tuples; product
    names are NOT globally unique, so resolution keys on the pair. Returns the
    canonical anchor string (fed through ``_resolve_target_anchor``), or "" for
    model-wide when nothing resolves.

    - Exactly one distinct product matches a token → product-level anchor.
    - Product matches are zero or ambiguous, but exactly one domain name
      matches → domain-level anchor (the ``duplicate_product_pair`` case).
    - Otherwise model-wide.
    """
    tokens = _extract_name_tokens(detail)
    if not tokens:
        return ""
    distinct_products = {
        (d, p) for (d, p) in pairs if p and p.lower() in tokens
    }
    if len(distinct_products) == 1:
        d, p = next(iter(distinct_products))
        return f"{d}.{p}"
    dom_matches = {dn for dn in domain_names if dn and dn.lower() in tokens}
    if len(dom_matches) == 1:
        return next(iter(dom_matches))
    return ""


def _parse_next_vibes_findings(text: str) -> list[_NextVibeFinding]:
    """Parse ``next_vibes.txt`` into structured, classified findings.

    Emits one :class:`_NextVibeFinding` per static-analysis finding
    (``static_analysis``), PRIORITY directive (``priority_remediation``), and
    "Other known issues" line (``other``). Ordinals are assigned densely in
    source order so re-parsing the same text is stable. Returns ``[]`` for a
    clean model with no actionable findings.
    """
    if not text:
        return []
    score = _extract_quality_score(text)
    fraction = score / 100 if score is not None else None
    findings: list[_NextVibeFinding] = []
    ordinal = 0

    for m in _SA_FINDING_RE.finditer(text):
        ordinal += 1
        sa_class = m.group(1).strip()
        detail = m.group(2).strip()
        findings.append(_NextVibeFinding(
            ordinal=ordinal,
            category=NextVibeCategory.STATIC_ANALYSIS,
            priority=VibeInputPriority.LOW,
            title=f"Static analysis: {sa_class}",
            description=detail,
            target=_first_element_ref(detail),
            quality_score=fraction,
        ))

    for m in _PRIORITY_RE.finditer(text):
        ordinal += 1
        kind = m.group(2).strip()
        target = m.group(3).strip()
        desc = m.group(4).strip()
        findings.append(_NextVibeFinding(
            ordinal=ordinal,
            category=NextVibeCategory.PRIORITY_REMEDIATION,
            priority=VibeInputPriority.HIGH,
            title=f"{kind} for {target}",
            description=desc,
            target=target,
            quality_score=fraction,
        ))

    other_block = _OTHER_HEADER_RE.search(text)
    if other_block:
        for line_m in _OTHER_LINE_RE.finditer(other_block.group(1)):
            detail = line_m.group(1).strip()
            if not detail:
                continue
            ordinal += 1
            findings.append(_NextVibeFinding(
                ordinal=ordinal,
                category=NextVibeCategory.OTHER,
                priority=VibeInputPriority.LOW,
                title="Other known issue",
                description=detail,
                target=_first_element_ref(detail),
                quality_score=fraction,
            ))

    return findings


def _next_vibes_payload_from_txt(text: str) -> dict:
    """Build the structured next-vibes payload directly from ``next_vibes.txt``.

    The .txt format the agent emits (v0.6.1+) looks like::

        **Model Quality Score: 76/100**

        **Static Analysis Findings (1 actionable):**
          - [SA:denormalized_natural_key] ...

        **PRIORITY 1 — remove_fk: customer.profile** — remove FK on
            column fulfillment_location_id to inventory.fulfillment_location ...

        Other known issues from static analysis (6):
          - ...

        Deterministic score: 76/100 (LLM assessment: 72/100)

    Parses each finding into a structured ``_next_vibe_metadata.findings``
    entry (the lossless source the sync-time materializer consumes). No lossy
    instructions blob is produced — the structured findings ARE the artifact.
    """
    score = _extract_quality_score(text)
    score_fraction = score / 100 if score is not None else None
    status = ""
    if score is not None:
        status = "needs_work" if score < 80 else "healthy"

    findings = [
        {
            "ordinal": f.ordinal,
            "category": f.category.value,
            "priority": f.priority.value,
            "title": f.title,
            "description": f.description,
            "target": f.target,
            "quality_score": f.quality_score,
        }
        for f in _parse_next_vibes_findings(text)
    ]

    return {
        "_next_vibe_metadata": {
            "summary": "",
            "status": status,
            "confidence_score": score_fraction,
            "findings": findings,
        },
    }


NEXT_VIBES_JSON_RELATIVE_PATHS = (
    "vibes/next_vibes.json",
    "next_vibes.json",
)
NEXT_VIBES_TXT_RELATIVE_PATHS = (
    "vibes/next_vibes.txt",
    "next_vibes.txt",
)
NEXT_VIBES_RELATIVE_PATHS = (
    NEXT_VIBES_JSON_RELATIVE_PATHS + NEXT_VIBES_TXT_RELATIVE_PATHS
)


def load_next_vibes_from_root(ws, version_root: str) -> tuple[Optional[dict], Optional[str]]:
    """Look up the next-vibes artifact under an arbitrary Volume folder.

    Tries the four candidates in :data:`NEXT_VIBES_RELATIVE_PATHS` order
    (.json first, .txt fallback for agent v0.6.1+). The .txt variant is
    parsed into the structured ``_next_vibe_metadata.findings`` payload the
    sync-time materializer consumes so the rest of the pipeline doesn't have
    to know about the .txt format.

    Returns ``(payload, resolved_path)`` — both ``None`` when nothing
    is found. ``resolved_path`` lets callers (e.g. the import preview)
    surface which file was actually picked up.

    Single source of truth for the four-way lookup; per-business
    agent-folder layouts compose ``version_root`` and call this; the
    import flow composes its own root from the user-picked Volume path.
    The relative-paths constants above are the canonical priority order
    so the preview endpoint and the loader can't drift.
    """
    if not ws or not version_root:
        return None, None
    root = version_root.rstrip("/")
    json_candidates = tuple(f"{root}/{rel}" for rel in NEXT_VIBES_JSON_RELATIVE_PATHS)
    for candidate in json_candidates:
        try:
            resp = ws.files.download(candidate)
            return json.loads(resp.contents.read()), candidate
        except Exception:
            continue
    txt_candidates = tuple(f"{root}/{rel}" for rel in NEXT_VIBES_TXT_RELATIVE_PATHS)
    for candidate in txt_candidates:
        try:
            resp = ws.files.download(candidate)
            text = resp.contents.read().decode("utf-8", errors="replace")
            return _next_vibes_payload_from_txt(text), candidate
        except Exception:
            continue
    return None, None


def ingest_next_vibes(
    ws,
    session,
    *,
    version_dir: str,
    version_id: str,
    business_id: str,
) -> int:
    """Load next-vibes from a version's Volume dir and materialize structured
    ``VibeInput(agent_next_vibe)`` rows.

    The single load-then-materialize path shared by every ingestion entry point
    that resolves a next-vibes artifact from a ``version_dir`` (Volume import,
    import-root, industry download). Returns the count inserted (0 when the
    artifact is absent). The run-sync path (``_capture_run_metadata``) is the
    documented exception - it reconstructs the path from catalog/business/version
    and does strictly more (raw-artifact registration + confidence back-fill).
    """
    payload, _path = load_next_vibes_from_root(ws, version_dir)
    if payload is None:
        return 0
    return ModelSyncService(session).materialize_next_vibe_inputs(
        version_id, business_id, payload
    )


def _unwrap_spec_description(value: object) -> str:
    """Defensive: agent vibe-iterate sometimes serializes the entire
    add-domain (or add-product) spec dict into the ``description`` field
    of model.json (observed 2026-04-27 on v=2 MVM loyalty domain).

    If ``value`` looks like a JSON object with its own ``description``
    field, unwrap to that string. Otherwise return ``value`` unchanged.
    A no-op for the normal case where the agent already wrote a plain
    description string.
    """
    if not isinstance(value, str):
        return str(value or "")
    s = value.strip()
    if not s.startswith("{") or not s.endswith("}"):
        return value
    try:
        parsed = json.loads(s)
    except (ValueError, TypeError):
        return value
    if isinstance(parsed, dict):
        inner = parsed.get("description")
        if isinstance(inner, str) and inner.strip():
            return inner
    return value


def _unwrap_model_envelope(model_json: dict) -> dict:
    """Return the inner ``model`` dict when handed the agent's envelope form.

    Volumes-fallback artifacts use the envelope (``{"model_requirements": ...,
    "_vibe_session_metadata": ..., "model": {"domains": [...]}}``); Delta-assembled
    payloads and external import tools use the flat ``{"domains": [...]}`` form.
    A no-op for the flat form.
    """
    if (
        isinstance(model_json, dict)
        and isinstance(model_json.get("model"), dict)
        and "domains" not in model_json
    ):
        return model_json["model"]
    return model_json


def _count_source_elements(model_json: dict) -> dict[str, int]:
    """Count the domains/products/attributes/FK-links a source payload carries.

    Uses the SAME rules as :meth:`ModelSyncService.sync_from_model_json` writes
    by (an FK link is counted only for a 3-part ``foreign_key_to``), so the
    post-sync gate compares like with like and never false-positives on a
    legitimately small model.
    """
    model_json = _unwrap_model_envelope(model_json)
    domains = model_json.get("domains", []) or []
    counts = {"domains": len(domains), "products": 0, "attributes": 0, "fk_links": 0}
    for d in domains:
        for p in d.get("products", []) or []:
            counts["products"] += 1
            for a in p.get("attributes", []) or []:
                counts["attributes"] += 1
                fk_to = a.get("foreign_key_to", "")
                if fk_to and len(fk_to.split(".")) == 3:
                    counts["fk_links"] += 1
    return counts


def _version_root_candidates(
    catalog: str, business_name: str, version: str, scope: str
) -> list[str]:
    """Reader lookup order for a version's Volume folder: nested-first, flat-next.

    Normal case (valid ``ecm``/``mvm`` scope + integer version) routes through
    the canonical :func:`core._paths.version_dir_candidates` builder, so the
    business segment matches the folder the agent wrote (``agent_business_segment``)
    and both the nested ``v{N}/{scope}`` (agent 4.9.8+) and legacy flat
    ``{scope}_v{N}`` (pre-upgrade rows) layouts are probed. Degenerate inputs
    (empty/unknown scope, non-integer version) fall back to the ``v{N}`` layout,
    composing on :func:`core._paths.metamodel_root_for_business` so the business
    segment is normalized the same way (and the shared empty-segment guard
    applies) - no raw ``business_name`` leaks into the path.

    Raises ``ValueError`` (via the ``_paths`` builders) when ``business_name``
    normalizes to an empty segment.
    """
    v_stripped = str(version or "").lstrip("vV") or str(version or "")
    scope_norm = _normalize_scope(scope)
    try:
        version_int: Optional[int] = int(v_stripped)
    except (TypeError, ValueError):
        version_int = None
    if version_int is not None and scope_norm in ("ecm", "mvm"):
        return version_dir_candidates(catalog, business_name, version_int, scope_norm)
    root = metamodel_root_for_business(catalog, business_name)
    if scope_norm:
        return [
            f"{root}/v{v_stripped}/{scope_norm}",
            f"{root}/{scope_norm}_v{v_stripped}",
        ]
    return [f"{root}/v{v_stripped}"]


def _version_root_in_volume(
    catalog: str, business_name: str, version: str, scope: str
) -> str:
    """Build the agent's canonical (nested) per-version Volume folder.

    Returns the PRIMARY nested root (``v{N}/{scope}`` for a valid scope +
    integer version). This is the write/path-record answer; readers that must
    also resolve legacy flat artifacts iterate :func:`_version_root_candidates`.

    Raises ``ValueError`` (via the ``_paths`` builders) when ``business_name``
    normalizes to an empty segment.
    """
    return _version_root_candidates(catalog, business_name, version, scope)[0]


class ModelSyncService:
    """Syncs model data into Lakebase Domain/Product/Attribute/FK tables.

    Primary source: model.json from UC Volumes - the agent's consolidated,
    deduplicated output (the single artifact it publishes as truth), and one
    Volume download rather than a chunked 21k-row warehouse scan.
    Fallback: the Delta metamodel tables (domain, product, attribute) via SQL,
    used only when model.json is absent.
    """

    def __init__(
        self,
        session: Session,
        ws: Optional[WorkspaceClient] = None,
        warehouse_id: str = "",
    ):
        self._session = session
        self._ws = ws
        self._warehouse_id = warehouse_id
        # Force-resync re-anchor state, keyed by version_id: captured
        # ``(link_id, NamedAnchor)`` pairs for the version's anchored context
        # links, taken BEFORE the element teardown in ``_delete_existing`` and
        # consumed AFTER the rebuild by ``_reanchor_context_links``. Keyed (not
        # a scalar) and skip-if-present so a ``clear_version_data`` followed by a
        # re-sync on the same service instance does not lose the natural keys
        # captured before the first teardown.
        self._pending_reanchor: dict[str, list] = {}
        # Canonical _vibe_progress drainer, injected at the model-producing
        # sync sites (ProgressTracker._sync_orch_progress_events via
        # OperationContext.extra). When None — imports, fixtures, base runs,
        # or no tracker — the synchronous final drain is skipped.
        self._drain_progress_fn = None

    # ------------------------------------------------------------------
    # Public sync entry point
    # ------------------------------------------------------------------

    def load_resync_sources(
        self,
        catalog: str,
        business_name: str,
        version_str: str,
        model_scope: str = "",
    ) -> tuple[Optional[dict], Optional[dict], Optional[str]]:
        """Load model.json (Volumes-primary, Delta-fallback) and the
        next-vibes artifact for a version - PURE Volume/warehouse I/O, never
        touches ``self._session``. Returns ``(model_data, next_vibes_payload,
        next_vibes_path)``.

        Call this with NO Lakebase transaction held open (commit/close any
        prior read first), then feed the result into :meth:`sync_model` via
        ``preloaded_model_data``/``next_vibes_preload`` so the write phase
        that follows never has the network read + JSON parse latency sitting
        inside an idle-open Postgres transaction. ``force_resync_version``
        is the intended caller; other ``sync_model`` call sites are
        unaffected (they don't pass the preload kwargs, so ``sync_model``
        loads lazily exactly as before).
        """
        model_data = self.load_model_json_from_volumes(
            catalog, business_name, version_str, model_scope
        )
        if not model_data:
            model_data = self.load_model_from_delta_tables(
                catalog, business_name, version_str, model_scope
            )
        next_vibes_payload: Optional[dict] = None
        next_vibes_path: Optional[str] = None
        if self._ws:
            next_vibes_payload, next_vibes_path = self.load_next_vibes_from_volumes(
                catalog, business_name, version_str, model_scope
            )
        return model_data, next_vibes_payload, next_vibes_path

    def sync_model(
        self,
        version_id: str,
        catalog: str,
        business_name: str,
        version_str: str,
        model_scope: str = "",
        run_id: Optional[str] = None,
        *,
        preloaded_model_data: object = _NOT_PRELOADED,
        next_vibes_preload: object = _NOT_PRELOADED,
    ) -> bool:
        """Sync model structure into Lakebase. Returns True if sync succeeded.

        Tries model.json from Volumes first, falls back to the Delta metamodel tables.
        Also ingests the agent's next-vibes artifact (best-effort) into structured
        ``VibeInput(origin=agent_next_vibe)`` rows at sync time so the UI can
        surface suggested next operations without a second round-trip to Volumes.

        ``preloaded_model_data``/``next_vibes_preload`` let a caller that
        already ran :meth:`load_resync_sources` (before opening the write
        transaction) hand the result straight through instead of this method
        re-reading Volumes itself. Left at the ``_NOT_PRELOADED`` sentinel
        (default), behavior is unchanged: this method does its own lazy
        Volumes/Delta/next-vibes loads, exactly as every non-resync caller
        already relies on.
        """
        _warn_if_unsanitized("sync_model", business_name)
        if preloaded_model_data is not _NOT_PRELOADED:
            model_data = preloaded_model_data
        else:
            # model.json is primary: the agent's consolidated, deduplicated
            # output, one Volume download rather than a chunked 21k-row
            # warehouse scan, and free of the stub/segment domains the
            # _metamodel Delta tables carry. Scope is passed through so the
            # path is built with the correct ``{scope}_v{N}`` folder suffix
            # (agent v0.5.9+ convention).
            model_data = self.load_model_json_from_volumes(
                catalog, business_name, version_str, model_scope
            )
            if not model_data:
                # Fallback to the Delta metamodel tables when model.json is absent.
                model_data = self.load_model_from_delta_tables(
                    catalog, business_name, version_str, model_scope
                )

        if model_data:
            self._sync_and_capture(
                version_id, model_data, catalog, business_name,
                version_str, model_scope, run_id,
                next_vibes_preload=next_vibes_preload,
            )
            return True

        logger.warning(
            f"No model data found for {business_name}/{version_str} in catalog {catalog}"
        )
        return False

    def _sync_and_capture(
        self,
        version_id: str,
        model_data: dict,
        catalog: str,
        business_name: str,
        version_str: str,
        model_scope: str,
        run_id: Optional[str],
        *,
        next_vibes_preload: object = _NOT_PRELOADED,
    ) -> None:
        """Write the loaded payload, gate it, capture metadata, drop the cache.

        Shared tail of both ``sync_model`` source branches so the primary and
        fallback paths cannot drift. Raises via :meth:`_assert_sync_complete`
        on a shortfall, before metadata capture or cache invalidation.
        """
        counts = self.sync_from_model_json(version_id, model_data, run_id=run_id)
        self._assert_sync_complete(model_data, counts)
        self._capture_run_metadata(
            version_id, catalog, business_name, version_str, model_scope,
            model_data, run_id=run_id, next_vibes_preload=next_vibes_preload,
        )
        self._invalidate_model_cache(version_id)

    def _assert_sync_complete(self, model_data: dict, counts: dict[str, int]) -> None:
        """HARD-FAIL post-sync gate: raise if the source parsed to 0 domains
        (``_SyncEmptyError`` → ``sync_empty``) or if fewer elements were
        written than the parsed source payload carries (``RuntimeError`` →
        ``incomplete_metadata``).

        Compares written-vs-parsed-source using identical counting rules
        (:func:`_count_source_elements`), so it fires only on genuine loss - a
        legitimately small model parses small and writes small. Raises before
        ``sync_model`` captures metadata or invalidates the cache; the raise
        propagates to the caller, which owns the failure handling (the run
        callers wrap the promote-and-sync region in a SAVEPOINT that reverts
        the partial write on this raise).
        """
        source = _count_source_elements(model_data)
        if source["domains"] == 0:
            raise _SyncEmptyError(
                "post-sync gate: source payload has 0 domains — refusing to "
                "commit a zero-domain model version"
            )
        shortfalls = {
            k: (source[k], counts.get(k, 0))
            for k in source
            if counts.get(k, 0) < source[k]
        }
        if shortfalls:
            detail = ", ".join(
                f"{k}: wrote {written} of {expected}"
                for k, (expected, written) in shortfalls.items()
            )
            raise RuntimeError(
                f"post-sync sanity gate failed - incomplete write ({detail}); "
                f"refusing to accept a truncated model"
            )

    def _invalidate_model_cache(self, version_id: str) -> None:
        """Drop the explorer model cache for this synced version so the next
        read reflects the freshly-written structure. Without this, a model dict
        cached during the run (version row exists, structure not yet synced)
        would be served stale — e.g. an empty v2 rendering as "all deleted."
        Lazy import keeps model_sync free of an explorer import at module load.
        """
        from .explorer import invalidate_model_cache
        mv = self._session.get(ModelVersion, version_id)
        if mv is not None:
            invalidate_model_cache(mv.business_id, mv.version)

    def _capture_run_metadata(
        self,
        version_id: str,
        catalog: str,
        business_name: str,
        version: str,
        model_scope: str = "",
        model_payload: Optional[dict] = None,
        run_id: Optional[str] = None,
        *,
        next_vibes_preload: object = _NOT_PRELOADED,
    ) -> None:
        """Persist run-level metadata and ingest next-vibes on the ModelVersion.

        Pulls the confidence score from the model.json payload (handles both
        top-level and nested `_vibe_session_metadata` shapes). Best-effort
        loads the agent's next-vibes artifact from Volumes and, when present,
        materializes structured ``VibeInput(origin=agent_next_vibe)`` rows AT
        SYNC TIME via :meth:`materialize_next_vibe_inputs` and registers the
        raw artifact via :meth:`register_next_vibes_artifact`. Falls back to
        the next-vibes metadata for confidence when the structure source was
        Delta (which doesn't carry confidence). Failures are non-fatal —
        metadata surfacing is additive.

        ``next_vibes_preload`` (default ``_NOT_PRELOADED``) lets a caller
        that already read the artifact via :meth:`load_resync_sources` hand
        the ``(payload, path)`` tuple through, skipping the Volume read here
        — see that method's docstring for why (keeping the read out of the
        open write transaction).
        """
        mv = self._session.get(ModelVersion, version_id)
        if mv is None:
            return

        changed = False
        confidence = _extract_confidence_score(model_payload)

        # Stamp version provenance from the model.json envelope. Only the
        # Volume-loaded payload carries the top-level ``agent_version`` /
        # ``release_version`` keys; the Delta-fallback payload does not, so
        # those columns legitimately stay NULL there. Never overwrite a
        # populated value with NULL — a re-sync off Delta must not erase
        # provenance an earlier model.json sync captured.
        agent_version, release_version = extract_version_provenance(model_payload)
        if agent_version is not None and agent_version != mv.agent_version:
            mv.agent_version = agent_version
            changed = True
        if release_version is not None and release_version != mv.release_version:
            mv.release_version = release_version
            changed = True
        # The file's ``_vibe_scope`` facts, under the same never-NULL rule.
        for attr, value in zip(
            ("scope_fence_mode", "scope_base_version", "scope_base_scope"),
            extract_vibe_scope_facts(model_payload),
        ):
            if value is not None and value != getattr(mv, attr):
                setattr(mv, attr, value)
                changed = True

        if next_vibes_preload is not _NOT_PRELOADED:
            next_vibes_payload, next_vibes_path = next_vibes_preload
        elif self._ws:
            next_vibes_payload, next_vibes_path = self.load_next_vibes_from_volumes(
                catalog, business_name, version, model_scope
            )
        else:
            next_vibes_payload, next_vibes_path = None, None
        if next_vibes_payload is not None:
            self.materialize_next_vibe_inputs(
                version_id, mv.business_id, next_vibes_payload
            )
            if next_vibes_path:
                self.register_next_vibes_artifact(version_id, run_id, next_vibes_path)
            if confidence is None:
                confidence = _extract_confidence_score(next_vibes_payload)

        if confidence is not None:
            mv.confidence_score = confidence
            changed = True

        if changed:
            self._session.add(mv)
            self._session.flush()

    def load_next_vibes_from_volumes(
        self, catalog: str, business_name: str, version: str, scope: str = ""
    ) -> tuple[Optional[dict], Optional[str]]:
        """Fetch the agent's next-vibes artifact from the version folder.

        Mirrors `load_model_json_from_volumes` but for the next-vibes
        artifact. Returns ``(None, None)`` if no artifact is found — the
        normal case for imported or pre-agent-v27 versions.

        Delegates the actual file lookup to
        :func:`load_next_vibes_from_root` so the import path (which
        composes its own root) can share the same priority order. Returns
        ``(payload, resolved_path)`` so the caller can both materialize the
        structured inputs and register the raw artifact.
        """
        _warn_if_unsanitized("load_next_vibes_from_volumes", business_name)
        if not self._ws:
            return None, None
        # Nested (agent 4.9.8+) first, legacy flat fallback for pre-upgrade rows.
        for version_root in _version_root_candidates(
            catalog, business_name, version, scope
        ):
            payload, resolved_path = load_next_vibes_from_root(self._ws, version_root)
            if payload is not None:
                return payload, resolved_path
        return None, None

    # ------------------------------------------------------------------
    # Structured next-vibes ingestion (ADR D-044 / D-045)
    # ------------------------------------------------------------------

    def materialize_next_vibe_inputs(
        self,
        version_id: str,
        business_id: str,
        payload: dict,
    ) -> int:
        """Materialize a next-vibes payload into structured ``VibeInput`` rows.

        One ``VibeInput(origin=agent_next_vibe)`` per parsed finding, carrying
        its :class:`NextVibeCategory`, severity (mapped to
        :class:`VibeInputPriority`), and Quality Score (``confidence_score``).
        Each input is anchored to the version via a ``VibeInputContextLink``
        resolved from the finding's ``domain.product`` target name using the
        canonical anchor resolver (the D-045 name-based pattern the
        re-link/backfill paths share); a trailing column segment, if present,
        is currently ignored (resolution is product-level) — so the Model
        Evolution Metrics can
        count and scope the open backlog. Unresolvable targets degrade UP the
        anchor hierarchy and flag ``needs_link_review`` rather than dropping.

        Idempotent: each row's id is a deterministic ``uuid5`` of
        ``(version_id, ordinal)`` (same namespace the boot backfill uses), and
        every insert is a guarded upsert. Returns the count of NEW inputs.

        Reads the structured ``_next_vibe_metadata.findings`` the loader
        builds from ``next_vibes.txt`` (or that the agent's structured JSON
        artifact carries directly); a payload without them yields zero inputs.

        Batched: every candidate id is computed up front, the existing-id
        dedup check is ONE ``WHERE id IN (...)`` select (not one
        ``session.get`` per finding), anchor resolution runs against a
        prefetched :class:`AnchorMaps` (not a query per finding), and the new
        ``VibeInput``/``VibeInputContextLink`` rows go in as one multi-row
        INSERT each - so the whole call is a small constant number of round
        trips regardless of finding count.
        """
        findings = self._payload_findings(payload)
        if not findings:
            return 0
        # Load the version's (domain, product) pairs + domain-name set, and
        # the AnchorMaps for anchor resolution, ONCE per call (hoisted out of
        # the finding loop) so this whole method is a small constant number
        # of selects regardless of finding count.
        pairs, domain_names = self._load_version_elements(version_id)
        maps = prefetch_anchor_maps(self._session, version_id)

        candidates: list[tuple[str, dict]] = []
        for f in findings:
            ordinal = f.get("ordinal")
            if ordinal is None:
                continue
            vi_id = str(uuid.uuid5(VI_NV_NS, f"{version_id}:{ordinal}"))
            candidates.append((vi_id, f))
        if not candidates:
            return 0

        existing_ids = set(self._session.exec(
            select(VibeInput.id).where(
                VibeInput.id.in_([vi_id for vi_id, _ in candidates])
            )
        ).all())

        new_input_rows = []
        new_link_rows = []
        inserted = 0
        for vi_id, f in candidates:
            if vi_id in existing_ids:
                continue
            new_input_rows.append(_row_values(VibeInput(
                id=vi_id,
                business_id=business_id,
                origin=VibeInputOrigin.AGENT_NEXT_VIBE.value,
                author="",
                text=_finding_text(f),
                category=f.get("category"),
                priority=f.get("priority") or VibeInputPriority.HIGH.value,
                confidence_score=f.get("quality_score"),
                consumed=False,
                status=VibeInputStatus.ACTIVE.value,
                deprecated_by=None,
                created_at=_now(),
                updated_at=_now(),
            )))
            anchor = self._resolve_finding_anchor(
                version_id, f, pairs, domain_names, maps
            )
            # The link id is a deterministic uuid5 of (input_id, version_id);
            # since vi_id was just confirmed NOT to already exist, and this
            # method is the sole producer of both rows (always inserted
            # together), the link cannot already exist either - no separate
            # existing-check needed.
            link_id = str(uuid.uuid5(NV_LINK_NS, f"{vi_id}:{version_id}"))
            new_link_rows.append(_row_values(VibeInputContextLink(
                id=link_id,
                input_id=vi_id,
                version_id=version_id,
                domain_id=anchor.domain_id,
                subdomain_id=anchor.subdomain_id,
                product_id=anchor.product_id,
                attribute_id=anchor.attribute_id,
                fk_link_id=anchor.fk_link_id,
                is_origin=True,
                needs_link_review=anchor.needs_link_review,
                created_at=_now(),
            )))
            inserted += 1

        if new_input_rows:
            self._session.execute(sa_insert(VibeInput), new_input_rows)
        if new_link_rows:
            self._session.execute(sa_insert(VibeInputContextLink), new_link_rows)
        self._session.flush()
        return inserted

    def _load_version_elements(
        self, version_id: str
    ) -> tuple[list[tuple[str, str]], set[str]]:
        """Return ``[(domain_name, product_name)]`` pairs + the domain-name set
        for a version. One select per table, filtered by ``version_id`` the same
        way the anchor resolver's ``Domain``/``Product`` selects are."""
        domains = self._session.exec(
            select(Domain).where(Domain.version_id == version_id)
        ).all()
        did_to_name = {d.id: d.name for d in domains}
        domain_names = {d.name for d in domains if d.name}
        products = self._session.exec(
            select(Product).where(Product.version_id == version_id)
        ).all()
        pairs = [
            (did_to_name.get(p.domain_id, ""), p.name)
            for p in products
            if p.name
        ]
        return pairs, domain_names

    def _resolve_finding_anchor(
        self,
        version_id: str,
        finding: dict,
        pairs: list[tuple[str, str]],
        domain_names: set[str],
        maps: Optional[AnchorMaps] = None,
    ) -> _AnchorFKs:
        """Resolve a finding to an element anchor.

        An explicit ``target`` (dotted ``domain.product[.col]`` OR a bare domain
        name, e.g. a PRIORITY directive's target) resolves as before, keeping the
        resolver's ``needs_link_review``. Only when there is NO explicit target
        is the finding's prose name-matched against the version's elements; a
        prose-inferred anchor is a heuristic, so it flags
        ``needs_link_review=True`` for a human to confirm. No match stays
        model-wide (unflagged).

        ``maps`` is an optional prefetched :class:`AnchorMaps`, threaded
        through to :meth:`_resolve_target_anchor` so resolving many findings
        against the same version does a query per element table once, not
        once per finding."""
        target = finding.get("target") or ""
        if target:
            return self._resolve_target_anchor(version_id, target, maps)
        matched = _match_target_by_name(
            pairs, domain_names, finding.get("description") or ""
        )
        if not matched:
            return _AnchorFKs()
        anchor = self._resolve_target_anchor(version_id, matched, maps)
        anchor.needs_link_review = True
        return anchor

    def _payload_findings(self, payload: object) -> list[dict]:
        """Pull the structured findings list out of a next-vibes payload."""
        if not isinstance(payload, dict):
            return []
        meta = payload.get("_next_vibe_metadata")
        if not isinstance(meta, dict):
            return []
        findings = meta.get("findings")
        return findings if isinstance(findings, list) else []

    def _resolve_target_anchor(
        self, version_id: str, target: str, maps: Optional[AnchorMaps] = None
    ) -> _AnchorFKs:
        """Resolve a ``domain.product`` target name to element FKs.

        Reuses the canonical :func:`_resolve_coords` (the same resolver the
        live-capture and backfill anchor paths use). An empty target is a
        legitimate model-wide anchor. A trailing column segment, if present,
        is currently ignored — resolution is product-level.

        ``maps`` is an optional prefetched :class:`AnchorMaps` threaded
        through to :func:`_resolve_coords` (see its docstring for the
        query-per-call-not-per-target tradeoff).
        """
        if not target:
            return _AnchorFKs()
        parts = target.split(".")
        if len(parts) >= 2:
            coords = _Coords(domain_name=parts[0], product_name=parts[1])
        else:
            coords = _Coords(domain_name=parts[0])
        return _resolve_coords(self._session, version_id, coords, maps)

    def register_next_vibes_artifact(
        self,
        version_id: str,
        run_id: Optional[str],
        file_path: str,
    ) -> Optional[str]:
        """Register the raw ``next_vibes.txt`` blob as a downloadable artifact.

        Reuses the shared ``RunArtifact`` plumbing (``_artifact_io.py`` serves
        the bytes on the per-version artifacts endpoint) so the raw file stays
        retrievable alongside the structured inputs. Idempotent: the row id is
        a deterministic ``uuid5`` of ``(version_id, file_path)``. Returns the
        artifact id, or ``None`` when ``file_path`` is empty.
        """
        if not file_path:
            return None
        art_id = str(uuid.uuid5(NV_ARTIFACT_NS, f"{version_id}:{file_path}"))
        if self._session.get(RunArtifact, art_id) is not None:
            return art_id
        self._session.add(RunArtifact(
            id=art_id,
            run_id=run_id,
            model_version_id=version_id,
            artifact_type=NEXT_VIBES_TXT_ARTIFACT_TYPE,
            file_path=file_path,
            created_at=_now(),
        ))
        self._session.flush()
        return art_id

    # ------------------------------------------------------------------
    # Delta table loader (primary)
    # ------------------------------------------------------------------

    def load_model_from_delta_tables(
        self,
        catalog: str,
        business_name: str,
        version: str,
        model_scope: str = "",
    ) -> Optional[dict]:
        """Load model structure from domain, product, attribute Delta tables.

        Returns a dict in the same shape as model.json, or None if tables don't exist
        or no data is found.
        """
        _warn_if_unsanitized("load_model_from_delta_tables", business_name)
        if not self._ws or not self._warehouse_id or not catalog:
            return None

        schema = "_metamodel"

        # Agent v27+ writes to `domain`, `product`, `attribute` (no underscore
        # prefix) — the handshake/progress table `_vibe_progress` is the one
        # exception. Older agent versions used `_domain`/`_product`/`_attribute`
        # but no workspace on the current deployment still runs those.
        domain_rows = self._query_delta_table(
            catalog, schema, "domain",
            business_name, version, model_scope,
        )
        if domain_rows is None:
            return None

        if not domain_rows:
            return None

        # Query products and attributes
        product_rows = self._query_delta_table(
            catalog, schema, "product",
            business_name, version, model_scope,
        ) or []
        attribute_rows = self._query_delta_table(
            catalog, schema, "attribute",
            business_name, version, model_scope,
        ) or []

        return self._assemble_model_dict(domain_rows, product_rows, attribute_rows)

    def _query_delta_table(
        self,
        catalog: str,
        schema: str,
        table: str,
        business_name: str,
        version: str,
        model_scope: str = "",
    ) -> Optional[list[dict]]:
        """Query a metamodel Delta table filtered by business/version/scope.

        Returns list of row dicts, or None if the table doesn't exist. Any
        other failure, including a result that is truncated or still running
        at the end of the bound, raises ``SqlStatementError``.
        """
        # The agent stores `version` in the metamodel tables as a bare
        # integer string ("1", "2", …) while the app carries it in widget
        # params as "v1"/"v2". Accept either format on the app side and
        # query with the bare number the agent actually writes.
        version_str = str(version or "").lstrip("vV") or str(version or "")

        # model_scope comes into the sync path as either the widget long
        # form ("Minimum Viable Model - MVM") or a pre-normalised short
        # form. Delta stores only the short form, so normalise before the
        # WHERE clause or we silently match zero rows.
        scope_str = _normalize_scope(model_scope)

        where = (
            f"LOWER(business) = LOWER('{_esc(business_name)}') "
            f"AND version = '{_esc(version_str)}'"
        )
        if scope_str:
            where += f" AND model_scope = '{_esc(scope_str)}'"

        sql = f"SELECT * FROM `{catalog}`.`{schema}`.`{table}` WHERE {where}"

        # A truncated or incomplete result raises here, during LOAD, before
        # any delete/write, so it can never leave a half-written version.
        return _sql.rows(
            self._ws, self._warehouse_id, sql,
            wait_timeout=_QUERY_WAIT, timeout_s=_QUERY_TIMEOUT_S,
            poll_interval_s=_QUERY_POLL_INTERVAL_S,
            missing_table="none", as_dicts=True,
        )

    def _assemble_model_dict(
        self,
        domain_rows: list[dict],
        product_rows: list[dict],
        attribute_rows: list[dict],
    ) -> dict:
        """Assemble query results into the model.json-compatible dict format.

        Output shape:
        {
            "domains": [
                {
                    "name": "...", "division": "...", "description": "...",
                    "database_name": "...", "references": "...",
                    "products": [
                        {
                            "product": "...", "description": "...", "type": "...",
                            "primary_key": "...", "subdomain": "...", ...
                            "attributes": [
                                {"attribute": "...", "type": "...", "foreign_key_to": "...", ...}
                            ]
                        }
                    ]
                }
            ]
        }
        """
        # Index products by domain name
        products_by_domain: dict[str, list[dict]] = {}
        for row in product_rows:
            domain_name = row.get("domain", "")
            products_by_domain.setdefault(domain_name, []).append(row)

        # Index attributes by (domain, product)
        attrs_by_product: dict[tuple[str, str], list[dict]] = {}
        for row in attribute_rows:
            key = (row.get("domain", ""), row.get("product", ""))
            attrs_by_product.setdefault(key, []).append(row)

        domains = []
        for d_row in domain_rows:
            domain_name = d_row.get("domain", "")
            products = []
            for p_row in products_by_domain.get(domain_name, []):
                product_name = p_row.get("product", "")
                attrs = []
                for a_row in attrs_by_product.get((domain_name, product_name), []):
                    attrs.append({
                        "attribute": a_row.get("attribute", ""),
                        "column_name": a_row.get("column_name", ""),
                        "type": a_row.get("type", ""),
                        "description": a_row.get("description", ""),
                        "business_glossary_term": a_row.get("business_glossary_term", ""),
                        "tags": a_row.get("tags", ""),
                        "value_regex": a_row.get("value_regex", ""),
                        "foreign_key_to": a_row.get("foreign_key_to", ""),
                        "references": a_row.get("reference", ""),
                    })

                products.append({
                    "product": product_name,
                    "table_name": p_row.get("table_name", product_name),
                    "description": p_row.get("description", ""),
                    "type": p_row.get("type", ""),
                    "data_type": p_row.get("data_type", ""),
                    "primary_key": p_row.get("primary_key", ""),
                    "subdomain": p_row.get("subdomain", ""),
                    "reference": p_row.get("reference", ""),
                    "attributes": attrs,
                })

            domains.append({
                "name": domain_name,
                "division": d_row.get("division", ""),
                "description": d_row.get("description", ""),
                "database_name": d_row.get("database_name", ""),
                "references": d_row.get("reference", ""),
                "products": products,
            })

        return {"domains": domains}

    # ------------------------------------------------------------------
    # Volume-based loader (fallback)
    # ------------------------------------------------------------------

    def load_model_json_from_volumes(
        self, catalog: str, business_name: str, version: str, scope: str = ""
    ) -> Optional[dict]:
        """Load model.json from UC Volumes. Returns None if not found.

        The agent (4.9.8+) writes to the nested
        `/Volumes/{catalog}/_metamodel/vol_root/business/{business_name}/v{N}/{scope}/`
        with `model.json` at the scope-dir top level. Pre-upgrade 0.7.x rows
        point at the legacy flat `{scope}_v{N}/` layout, so each candidate root
        (nested first, flat next) is probed in turn. Within a root, `model.json`
        is tried directly, then the `docs/` naming variants as a defensive
        fallback for older docs-only layouts.
        """
        _warn_if_unsanitized("load_model_json_from_volumes", business_name)
        if not self._ws:
            return None

        # Nested (agent 4.9.8+) first, legacy flat fallback for pre-upgrade rows.
        for version_root in _version_root_candidates(
            catalog, business_name, version, scope
        ):
            model_data = self._load_model_json_from_root(
                version_root, version, business_name
            )
            if model_data is not None:
                return model_data
        return None

    def _load_model_json_from_root(
        self, version_root: str, version: str, business_name: str
    ) -> Optional[dict]:
        """Probe a single version-root folder for ``model.json``.

        Order: direct ``model.json`` at the root, then a ``docs/`` listing for
        ``*_data_model_<version>.json``, then the sanitized-segment convention
        name under ``docs/``. Returns ``None`` when nothing resolves.
        """
        ws = self._ws
        if ws is None:
            return None
        docs_path = f"{version_root}/docs"
        suffix = f"_data_model_{version}.json"

        # 1. Direct model.json at the version-folder root (current agent layout).
        candidate1 = f"{version_root}/model.json"
        try:
            resp = ws.files.download(candidate1)
            return json.loads(resp.contents.read())
        except Exception:
            pass

        # 2. Directory listing of docs/ for `*_data_model_<version>.json`.
        try:
            for entry in ws.files.list_directory_contents(docs_path):
                if entry.name and entry.name.endswith(suffix):
                    candidate2 = f"{docs_path}/{entry.name}"
                    resp = ws.files.download(candidate2)
                    return json.loads(resp.contents.read())
        except Exception:
            pass

        # 3. Convention-based fallback for the docs/ naming scheme. The agent
        # names this file with the sanitized business segment, matching the
        # folder segment - not the raw business_name.
        biz_seg = agent_business_segment(business_name)
        try:
            path = f"{docs_path}/{biz_seg}{suffix}"
            resp = ws.files.download(path)
            return json.loads(resp.contents.read())
        except Exception:
            logger.warning(
                f"Could not load model.json from {version_root} "
                f"(tried root model.json, {docs_path}/*{suffix}, "
                f"and {docs_path}/{biz_seg}{suffix})"
            )
            return None

    # ------------------------------------------------------------------
    # Sync into Lakebase
    # ------------------------------------------------------------------

    def sync_from_model_json(
        self,
        version_id: str,
        model_json: dict,
        run_id: Optional[str] = None,
    ) -> dict[str, int]:
        """Bulk load from model dict. Deletes existing records for version_id first.

        Accepts either the flat form (`{"domains": [...]}`) or the agent's
        envelope form (`{"model_requirements": ..., "_vibe_session_metadata":
        ..., "model": {"domains": [...]}}`). Volumes-fallback artifacts use
        the envelope; Delta-assembled payloads and external import tools use
        the flat form.

        Returns the per-entity written counts (``domains``/``products``/
        ``attributes``/``fk_links``) and logs them at INFO, so the caller's
        post-sync gate can compare written-vs-source and a truncated write
        leaves log evidence.

        When ``run_id`` is provided (the two model-producing sync sites), a
        lineage pass runs after the final flush: it drains the run's terminal
        progress events, sets ``previous_element_id`` pointers against the
        prior version, upserts subdomains, and writes ``RunElementLineage``
        rows. With no ``run_id`` (imports, dev fixtures, base runs) the pass is
        a no-op, preserving every existing caller.
        """
        rebuild_started = time.monotonic()
        self._delete_existing(version_id)

        model_json = _unwrap_model_envelope(model_json)

        domains = model_json.get("domains", [])
        all_fk_links: list[dict] = []
        counts = {"domains": 0, "products": 0, "attributes": 0, "fk_links": 0}

        domain_objs: list[Domain] = []
        product_objs: list[Product] = []
        attribute_objs: list[Attribute] = []
        fk_link_objs: list[ForeignKeyLink] = []

        for d in domains:
            domain = Domain(
                version_id=version_id,
                name=d.get("name", ""),
                division=d.get("division", ""),
                description=_unwrap_spec_description(d.get("description", "")),
                database_name=d.get("database_name", ""),
                references=d.get("references", ""),
            )
            domain_objs.append(domain)
            counts["domains"] += 1

            for p in d.get("products", []):
                pk_name = p.get("primary_key", "")
                product_name = p.get("product") or p.get("name", "")
                product = Product(
                    domain_id=domain.id,
                    version_id=version_id,
                    name=product_name,
                    table_name=p.get("table_name", product_name),
                    description=_unwrap_spec_description(p.get("description", "")),
                    type=p.get("type", ""),
                    data_type=p.get("data_type", ""),
                    primary_key=pk_name,
                    subdomain=p.get("subdomain", ""),
                    reference=p.get("reference", ""),
                )
                product_objs.append(product)
                counts["products"] += 1

                for a in p.get("attributes", []):
                    attr_name = a.get("attribute") or a.get("name", "")
                    fk_to = a.get("foreign_key_to", "")
                    is_pk = attr_name == pk_name
                    is_fk = is_fk_attribute(a)

                    attr = Attribute(
                        product_id=product.id,
                        name=attr_name,
                        column_name=a.get("column_name", attr_name),
                        type=a.get("type", ""),
                        description=a.get("description", ""),
                        business_glossary_term=a.get("business_glossary_term", ""),
                        tags=a.get("tags", ""),
                        value_regex=a.get("value_regex", ""),
                        foreign_key_to=fk_to,
                        references=a.get("references", ""),
                        is_primary_key=is_pk,
                        is_foreign_key=is_fk,
                    )
                    attribute_objs.append(attr)
                    counts["attributes"] += 1

                    if fk_to:
                        parts = fk_to.split(".")
                        if len(parts) == 3:
                            all_fk_links.append({
                                "source_domain": d.get("name", ""),
                                "source_product": product_name,
                                "source_column": attr_name,
                                "target_domain": parts[0],
                                "target_product": parts[1],
                                "target_column": parts[2],
                            })

        for fk in all_fk_links:
            fk_link_objs.append(ForeignKeyLink(version_id=version_id, **fk))
        counts["fk_links"] = len(all_fk_links)

        bulk_insert_elements(
            self._session,
            domains=domain_objs,
            products=product_objs,
            attributes=attribute_objs,
            fk_links=fk_link_objs,
        )

        rebuild_elapsed = time.monotonic() - rebuild_started
        logger.info(
            "[sync_from_model_json] version=%s wrote domains=%d products=%d "
            "attributes=%d fk_links=%d (delete+bulk-insert took %.2fs)",
            version_id, counts["domains"], counts["products"],
            counts["attributes"], counts["fk_links"], rebuild_elapsed,
        )

        # Subdomains are structural (derived from product.subdomain names),
        # not lineage-dependent, so upsert them on EVERY sync — including the
        # no-run_id force-resync recovery path — so a Re-sync fully repairs a
        # subdomain-bearing model. The lineage pointer/drain pass below stays
        # run_id-gated.
        _mv = self._session.get(ModelVersion, version_id)
        upsert_subdomains(
            self._session, version_id, _mv.base_version_id if _mv else None
        )

        if run_id:
            self._link_previous_version(version_id, run_id)

        # Re-point context links detached in _delete_existing onto the rebuilt
        # same-version elements by natural key.
        reanchor_started = time.monotonic()
        self._reanchor_context_links(version_id)
        reanchor_elapsed = time.monotonic() - reanchor_started
        logger.info(
            "[sync_from_model_json] version=%s re-anchor pass took %.2fs",
            version_id, reanchor_elapsed,
        )

        return counts

    def _link_previous_version(self, version_id: str, run_id: str) -> None:
        """Run the rename/merge/delete lineage pass for version W.

        Performs a synchronous final drain of the run's terminal progress
        events (so a late Stage-8 QA ``rename_log`` is guaranteed mirrored
        into ``RunProgressEvent`` before any signal is read), then resolves
        old→new pointers + writes lineage rows. The drain reuses the canonical
        ``_sync_orch_progress_events`` drainer via ``self._drain_progress_fn``
        (injected at the sync site); when no drainer/ws is available the drain
        is skipped — same no-op gate as the rest of the pass.
        """
        self._final_drain(run_id)
        link_previous_version(self._session, version_id, run_id)

    def _final_drain(self, run_id: str) -> None:
        """Synchronously drain the run's terminal ``_vibe_progress`` events
        into ``RunProgressEvent``, terminating when the agent's "Session
        Ended" bookend is mirrored (provable completeness — every QA / rename
        / consolidation event precedes it in event_seq order), capped by a
        bounded retry budget as a safety backstop.

        Reuses the canonical drainer (``_sync_orch_progress_events``) supplied
        as ``self._drain_progress_fn``; no second ``_vibe_progress`` reader.
        Idempotent: the drainer cursors on ``last_consumed_step_id`` so
        re-draining mirrors zero duplicate rows.
        """
        drain_fn = self._drain_progress_fn
        if drain_fn is None:
            return
        run = self._session.get(Run, run_id)
        if run is None:
            return
        max_passes = 3
        for _ in range(max_passes):
            try:
                drain_fn(run, self._session)
            except Exception:
                logger.exception("[_final_drain] drainer raised for run %s", run_id)
                return
            if self._session_ended_mirrored(run_id):
                return

    def _session_ended_mirrored(self, run_id: str) -> bool:
        """True once the terminal "Session Ended" bookend event is present in
        ``RunProgressEvent`` for the run."""
        ev = self._session.exec(
            select(RunProgressEvent)
            .where(RunProgressEvent.run_id == run_id)
            .where(RunProgressEvent.stage_name == "Vibe Session")
            .where(RunProgressEvent.step_name == "Session Ended")
        ).first()
        return ev is not None

    # ------------------------------------------------------------------
    # Delta writer (for recovery: keep Delta in sync with Lakebase)
    # ------------------------------------------------------------------

    def write_model_to_delta(
        self,
        catalog: str,
        business_name: str,
        version: str,
        model_scope: str,
        volume_path: str,
        model_payload: dict,
    ) -> bool:
        """Write a model's structure into the agent's metamodel Delta tables
        (`business`, `domain`, `product`, `attribute`) from a parsed model
        JSON.

        Idempotent: if a `business` row already exists for the target
        (business, version, scope) we assume Delta is up-to-date and skip.
        Returns True if rows were written. The registry is set up first
        (``metamodel_registry.ensure_metamodel_registry``), so this works in a
        catalog the agent never ran in; a failed setup raises
        ``MetamodelSetupError``.

        This is the inverse of `sync_from_model_json` — that method writes
        Lakebase; this one writes Delta. Paired they keep both stores
        consistent so later vibe runs find a base version where the agent
        expects to look (Delta) regardless of how the version originally
        got there.
        """
        _warn_if_unsanitized("write_model_to_delta", business_name)
        if not self._ws or not self._warehouse_id:
            logger.warning("write_model_to_delta called without ws/warehouse — skipping")
            return False
        ensure_metamodel_registry(
            self._ws, catalog, self._warehouse_id, timeout_s=_REGISTRY_SETUP_TIMEOUT_S,
        )
        v_stripped = str(version or "").lstrip("vV") or str(version or "")
        scope_norm = _normalize_scope(model_scope)
        schema = "_metamodel"

        # Idempotency guard.
        check_sql = (
            f"SELECT COUNT(*) AS n FROM `{catalog}`.`{schema}`.business "
            f"WHERE LOWER(business) = LOWER('{_esc(business_name)}') "
            f"AND version = '{_esc(v_stripped)}' "
            f"AND model_scope = '{_esc(scope_norm)}'"
        )
        exists = self._execute_scalar(check_sql)
        if exists and int(exists) > 0:
            logger.info(
                f"Delta already has {business_name} v{v_stripped} ({scope_norm}) — skip write"
            )
            return False

        domains = model_payload.get("domains", []) or []

        # 1) business row
        now_ts = "CURRENT_TIMESTAMP()"
        description = _esc(
            (model_payload.get("description") or "")[:4000]
        )
        industry = _esc(model_payload.get("industry_alignment") or "")
        biz_sql = (
            f"INSERT INTO `{catalog}`.`{schema}`.business "
            f"(business, version, model_scope, description, industry_alignment, catalog, location, "
            f"completion_date, processing_status, completed_percent, session_started_at, last_updated_at) "
            f"VALUES ('{_esc(business_name)}', '{_esc(v_stripped)}', '{_esc(scope_norm)}', "
            f"'{description}', '{industry}', '{_esc(catalog)}', '{_esc(volume_path)}', "
            f"{now_ts}, 'done', 100.0, {now_ts}, {now_ts})"
        )
        self._execute(biz_sql)

        # 2) domain rows
        for d in domains:
            dname = _esc(d.get("name", ""))
            div = _esc(d.get("division", ""))
            ddesc = _esc((d.get("description") or "")[:4000])
            dbname = _esc(d.get("database_name", ""))
            dref = _esc(d.get("references") or d.get("reference") or "")
            dtags = _esc(",".join(d.get("tags", []) or []) if isinstance(d.get("tags"), list) else (d.get("tags") or ""))
            dom_sql = (
                f"INSERT INTO `{catalog}`.`{schema}`.domain "
                f"(business, version, model_scope, domain, division, description, database_name, catalog, reference, tags) "
                f"VALUES ('{_esc(business_name)}', '{_esc(v_stripped)}', '{_esc(scope_norm)}', "
                f"'{dname}', '{div}', '{ddesc}', '{dbname}', '{_esc(catalog)}', '{dref}', '{dtags}')"
            )
            self._execute(dom_sql)

        # 3+4) products and attributes — batch via multi-row VALUES for speed
        prod_rows: list[str] = []
        attr_rows: list[str] = []
        for d in domains:
            dname = d.get("name", "")
            for p in d.get("products", []):
                pname = p.get("name") or p.get("product", "")
                pk = _esc(p.get("primary_key", ""))
                prod_rows.append(
                    "("
                    f"'{_esc(business_name)}', '{_esc(v_stripped)}', '{_esc(scope_norm)}', "
                    f"'{_esc(dname)}', '{_esc(p.get('subdomain',''))}', '{_esc(pname)}', "
                    f"'{_esc((p.get('description') or '')[:4000])}', '{_esc(p.get('type',''))}', "
                    f"'{_esc(p.get('division',''))}', '{_esc(p.get('function',''))}', "
                    f"'{_esc(p.get('data_type',''))}', '{_esc(p.get('source_domains',''))}', "
                    f"'{_esc(p.get('association_edges',''))}', '{pk}', "
                    f"'{_esc(p.get('reference',''))}', '{_esc(p.get('table_name',''))}', "
                    f"'{_esc(p.get('sample_path',''))}', "
                    f"'{_esc(','.join(p.get('tags',[])) if isinstance(p.get('tags'), list) else (p.get('tags') or ''))}'"
                    ")"
                )
                for a in p.get("attributes", []) or []:
                    aname = _esc(a.get("attribute") or a.get("name") or "")
                    attr_rows.append(
                        "("
                        f"'{_esc(business_name)}', '{_esc(v_stripped)}', '{_esc(scope_norm)}', "
                        f"'{_esc(dname)}', '{_esc(pname)}', '{aname}', "
                        f"'{_esc(a.get('column_name',''))}', '{_esc(a.get('type',''))}', "
                        f"'{_esc(','.join(a.get('tags',[])) if isinstance(a.get('tags'), list) else (a.get('tags') or ''))}', "
                        f"'{_esc(a.get('value_regex',''))}', '{_esc(a.get('foreign_key_to',''))}', "
                        f"'{_esc(a.get('business_glossary_term',''))}', "
                        f"'{_esc((a.get('description') or '')[:4000])}', "
                        f"'{_esc(a.get('references') or a.get('reference') or '')}'"
                        ")"
                    )

        prod_cols = (
            "(business, version, model_scope, domain, subdomain, product, description, type, "
            "division, function, data_type, source_domains, association_edges, primary_key, "
            "reference, table_name, sample_path, tags)"
        )
        attr_cols = (
            "(business, version, model_scope, domain, product, attribute, column_name, type, "
            "tags, value_regex, foreign_key_to, business_glossary_term, description, reference)"
        )

        for batch in _batched(prod_rows, 100):
            self._execute(
                f"INSERT INTO `{catalog}`.`{schema}`.product {prod_cols} VALUES "
                + ", ".join(batch)
            )
        for batch in _batched(attr_rows, 100):
            self._execute(
                f"INSERT INTO `{catalog}`.`{schema}`.attribute {attr_cols} VALUES "
                + ", ".join(batch)
            )

        logger.info(
            f"Wrote Delta for {business_name} v{v_stripped} ({scope_norm}): "
            f"{len(domains)} domains / {len(prod_rows)} products / {len(attr_rows)} attrs"
        )
        return True

    def delete_metamodel_rows(
        self,
        catalog: str,
        business_name: str,
        version: str,
        model_scope: str,
    ) -> bool:
        """Delete this version's rows from the agent's metamodel Delta tables
        (`business`, `domain`, `product`, `attribute`).

        Inverse of :meth:`write_model_to_delta`. Returns True if a `business`
        row was found (and thus the cascade ran) for the target
        ``(business_name, version, model_scope)``; False if the version was
        never installed there (e.g. import-only versions that never made it
        into Delta).

        Silently skips if no workspace / warehouse is configured — the route
        falls back to deleting Lakebase rows only in that case.
        """
        _warn_if_unsanitized("delete_metamodel_rows", business_name)
        if not self._ws or not self._warehouse_id or not catalog:
            return False

        v_stripped = str(version or "").lstrip("vV") or str(version or "")
        scope_norm = _normalize_scope(model_scope)
        schema = "_metamodel"

        where = (
            f"LOWER(business) = LOWER('{_esc(business_name)}') "
            f"AND version = '{_esc(v_stripped)}' "
            f"AND model_scope = '{_esc(scope_norm)}'"
        )

        # Check the `business` row first — both as the existence gate and to
        # avoid issuing DELETEs against tables that the agent never created
        # in this catalog (import-only versions).
        check_sql = (
            f"SELECT COUNT(*) AS n FROM `{catalog}`.`{schema}`.business WHERE {where}"
        )
        # A missing business table means the version was never installed
        # here; any other failure raises.
        exists = self._execute_scalar(check_sql, missing_table="none")
        if not exists or int(exists) <= 0:
            return False

        # Order matters only loosely (no real FKs in the metamodel Delta
        # tables) — go child → parent to keep the intent obvious.
        for table in ("attribute", "product", "domain", "business"):
            self._execute(
                f"DELETE FROM `{catalog}`.`{schema}`.{table} WHERE {where}",
                missing_table="none",
            )
        return True

    def _execute(self, sql: str, *, missing_table: _sql.MissingTable = "raise") -> None:
        """A write on the registry tables: one 50 s wait, no polls; a write
        still running then is cancelled. Every failure raises
        ``SqlStatementError``; ``missing_table="none"`` skips a missing table."""
        _sql.run(
            self._ws, self._warehouse_id, sql,
            wait_timeout="50s", missing_table=missing_table,
        )

    def _execute_scalar(
        self, sql: str, *, missing_table: _sql.MissingTable = "raise",
    ) -> Optional[str]:
        """One value from the registry tables: one 30 s wait, no polls. Every
        failure raises ``SqlStatementError``; ``missing_table="none"`` reads a
        missing table as ``None``."""
        return _sql.scalar(
            self._ws, self._warehouse_id, sql,
            wait_timeout="30s", missing_table=missing_table,
        )

    def clear_version_data(self, version_id: str) -> None:
        """Delete all model data for a version. Public alias for force-resync."""
        self._delete_existing(version_id)

    def _delete_existing(self, version_id: str) -> None:
        """Delete a version's element rows (idempotent resync).

        The ``ModelVersion`` row SURVIVES this path, so ``version_id`` CASCADE
        never fires on the ``vibe_input_context_links`` anchored to this version,
        and their element columns are NO ACTION. So BEFORE tearing down the
        elements we capture each anchored link's natural key and detach its
        element columns (SET NULL); ``_reanchor_context_links`` re-points them by
        name after ``sync_from_model_json`` rebuilds. The actual row deletion
        (and, on Postgres, the DB-cascade to ``subdomains``/``product_reviews``)
        is delegated to :func:`bulk_delete_version_elements` (shared bulk-I/O
        module) - the capture/detach/reanchor contract above is untouched.

        Capture and clear are timed as distinct legs (rather than one combined
        number) so a retime can attribute time to either without re-running.
        """
        capture_started = time.monotonic()
        self._capture_and_detach_context_links(version_id)
        capture_elapsed = time.monotonic() - capture_started

        clear_started = time.monotonic()
        bulk_delete_version_elements(self._session, version_id)
        clear_elapsed = time.monotonic() - clear_started

        logger.info(
            "[_delete_existing] version=%s capture+detach took %.2fs, "
            "clear (delete) took %.2fs",
            version_id, capture_elapsed, clear_elapsed,
        )

    def _capture_and_detach_context_links(self, version_id: str) -> None:
        """Capture + detach the version's ANCHORED context links before teardown.

        Pure model-wide links (no element anchor) are left untouched. For
        anchored links, capture the natural-key anchor from the OLD element rows
        and NULL the element columns (keeping the row + its ``version_id``
        anchor) so the NO-ACTION element FKs raise no violation when the elements
        are deleted. Skip if this version was already captured on a prior
        ``_delete_existing`` in the same service instance (clear-then-resync).

        Captures every anchored link's names against one prefetched
        :class:`IdNameMaps` for ``version_id`` (five SELECTs total, not one
        point read per link per element table) - mirrors the prefetched-map
        pattern ``_reanchor_context_links`` uses on the resolve side.
        """
        from .core.anchor_resolve import capture_named_anchor, prefetch_id_name_maps

        if version_id in self._pending_reanchor:
            return
        links = self._session.exec(
            select(VibeInputContextLink).where(
                VibeInputContextLink.version_id == version_id
            )
        ).all()
        anchored = [
            link for link in links
            if any((
                link.domain_id, link.subdomain_id, link.product_id,
                link.attribute_id, link.fk_link_id,
            ))
        ]
        maps = prefetch_id_name_maps(self._session, version_id) if anchored else None
        self._pending_reanchor[version_id] = [
            (link.id, capture_named_anchor(self._session, link, maps)) for link in anchored
        ]
        for link in anchored:
            link.domain_id = None
            link.subdomain_id = None
            link.product_id = None
            link.attribute_id = None
            link.fk_link_id = None
            self._session.add(link)

        # Flush the detach UPDATEs now, before the caller's raw-connection
        # bulk delete runs. Postgres's bulk_delete_version_elements deletes
        # via session.connection() (SQLAlchemy Core), which does not see
        # this session's pending ORM state - only rows already flushed to
        # the DB. Without this flush the DELETE would see the OLD (still
        # anchored) FK values on these links and fail with a
        # ForeignKeyViolation on the rows it's trying to remove.
        self._session.flush()

    def _reanchor_context_links(self, version_id: str) -> None:
        """Re-point each captured context link by natural key against the NEW
        same-version element rows. A key that no longer resolves leaves its link
        detached (element ids NULL) with ``needs_link_review=True``.

        Resolves every captured anchor against one prefetched
        :class:`AnchorMaps` for ``version_id`` (five SELECTs total, not one
        per link) and applies the results with a single multi-row UPDATE,
        instead of a per-link point lookup followed by a per-link write.
        """
        from .core.anchor_resolve import prefetch_anchor_maps, resolve_named_anchor

        captured = self._pending_reanchor.pop(version_id, None)
        if not captured:
            return
        maps = prefetch_anchor_maps(self._session, version_id)
        updates = []
        for link_id, named in captured:
            fks = resolve_named_anchor(self._session, version_id, named, maps)
            updates.append({
                "_link_id": link_id,
                "domain_id": fks.domain_id,
                "subdomain_id": fks.subdomain_id,
                "product_id": fks.product_id,
                "attribute_id": fks.attribute_id,
                "fk_link_id": fks.fk_link_id,
                "needs_link_review": fks.needs_link_review,
            })
        if updates:
            self._session.connection().execute(
                sa_update(VibeInputContextLink).where(
                    VibeInputContextLink.id == bindparam("_link_id")
                ),
                updates,
            )
            # The Core UPDATE above bypasses the ORM, so any VibeInputContextLink
            # already in the identity map (e.g. loaded + detached earlier in
            # this same session, in _capture_and_detach_context_links) still
            # holds its pre-update in-memory values. Expire so the next ORM
            # access re-reads the resolved row from the DB.
            self._session.expire_all()
        self._session.flush()

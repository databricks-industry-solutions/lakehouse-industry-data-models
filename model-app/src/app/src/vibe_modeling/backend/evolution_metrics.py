"""Model evolution metrics (T16, "Model Evolution Metrics" epic).

Surfaces the size / quality / change / effort / provenance metrics the agent
stamps into ``model.json`` under ``_vibe_session_metadata`` so the overview
band (T10) and the Statistics report (T6) can render them. None of this lives
in Lakebase: ``_load_model_from_lakebase`` reconstructs only the model
*structure* (domains/products/attributes/FKs) from the synced tables and drops
the session metadata. The data is read on demand from the version's Volume
``model.json`` envelope — the same artifact ``explorer._load_model`` falls back
to — so this layer adds NO migration and NO new persisted column.

Authoritative shape (agent ``_vibe_session_metadata``, current notebook):

* ``model_stats_at_generation`` — ``{domain_count, product_count,
  attribute_count, fk_count, unlinked_id_count, siloed_count,
  llm_fk_skip_count}``. The agent's own size tally at generation time.
* ``confidence_score`` — 0..100 integer (a percentage). ECM runs never emit a
  confidence (the next-vibe quality judge only runs on MVM), so this is
  absent/0 there.
* ``issue_counts`` — ``{error, warning, info, warning_raw}``.
* ``progression`` — ``{version_trend, confidence_delta, warnings_delta,
  errors_delta, unlinked_delta, previous_version, previous_confidence,
  previous_warnings, previous_errors, previous_unlinked}``.
* ``version_history`` — list of ``{version, confidence, errors, warnings,
  unlinked, trend, products, fks}`` (newest last, capped at 20 by the agent).
* ``ai_usage`` — ``{total_ai_calls, estimated_input_tokens,
  estimated_output_tokens, total_input_chars, total_output_chars,
  estimated_total_cost_usd, per_model_cost_usd}`` (+ optional
  ``demoted_models`` / ``cumulative_failures``).
* ``agent_version`` (top-level on the envelope), ``status``,
  ``generated_from_version``, ``target_model_version``.

Degradation (never fabricate):

* **No confidence** — ECM, or any file where the agent didn't run the quality
  judge. ``confidence_score`` is surfaced as ``None`` and ``has_confidence``
  is ``False``. Never coerced to 0; a real 0 would be a legitimate score.
* **Baseline / first version** — ``progression.version_trend == "baseline"``
  (the agent sets this whenever there's no scored predecessor, i.e.
  ``previous_confidence == 0``). All deltas/previous_* are then zeros and the
  ``version_history`` has a single entry. ``has_predecessor`` is ``False`` so
  the FE shows "no predecessor" rather than rendering meaningless 0 deltas.

``has_predecessor`` is derived from ``version_trend`` (and a >1-entry history
as a fallback), NOT from ``progression.previous_version`` — that field is
unreliable: it labels the output version, and is ``"unknown"`` for many
real exports (see ``agent_compat.generated_from_version_tag``).

``has_metadata`` is ``False`` when the envelope carried no
``_vibe_session_metadata`` at all (hand-edited / pre-metadata imports). The
size block still degrades to the structure-derived fallback the caller passes
in; everything else is null/empty.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Optional

from .fk import count_fk_attributes

# The agent labels a first/predecessor-less run with this trend.
_BASELINE_TREND = "baseline"


def _as_int(value: object) -> Optional[int]:
    """Coerce a JSON scalar to int, or None when absent/non-numeric.

    Returns None (not 0) for missing values so callers can tell "the agent
    didn't record this" from "the agent recorded zero"."""
    if isinstance(value, bool):  # bool is an int subclass; never a count here
        return None
    if isinstance(value, (int, float)):
        return int(value)
    return None


def _as_float(value: object) -> Optional[float]:
    if isinstance(value, bool):
        return None
    if isinstance(value, (int, float)):
        return float(value)
    return None


@dataclass
class EvolutionSize:
    """Size tally at generation. Counts come from the agent's
    ``model_stats_at_generation`` when present, else from the structure-derived
    fallback the caller computes off the model dict (so the size block is
    always populated, even for metadata-less imports)."""

    domain_count: Optional[int] = None
    product_count: Optional[int] = None
    attribute_count: Optional[int] = None
    fk_count: Optional[int] = None
    unlinked_id_count: Optional[int] = None
    siloed_count: Optional[int] = None
    # Derived: mean attributes per product (None when product_count is 0/None).
    avg_attributes_per_product: Optional[float] = None


@dataclass
class EvolutionQuality:
    confidence_score: Optional[float] = None  # 0..100; None when not judged
    error_count: Optional[int] = None
    warning_count: Optional[int] = None
    info_count: Optional[int] = None
    issues_addressed: list[str] = field(default_factory=list)
    issues_not_addressed: list[str] = field(default_factory=list)


@dataclass
class EvolutionChange:
    """Change-vs-previous. All deltas/previous_* are None on a baseline
    version (no scored predecessor); ``version_trend`` is then ``"baseline"``.
    ``version_history`` is the full per-version timeline for sparklines."""

    version_trend: Optional[str] = None
    confidence_delta: Optional[int] = None
    warnings_delta: Optional[int] = None
    errors_delta: Optional[int] = None
    unlinked_delta: Optional[int] = None
    previous_confidence: Optional[int] = None
    previous_warnings: Optional[int] = None
    previous_errors: Optional[int] = None
    previous_unlinked: Optional[int] = None
    version_history: list["VersionHistoryEntry"] = field(default_factory=list)


@dataclass
class VersionHistoryEntry:
    version: str = ""
    confidence: Optional[int] = None
    errors: Optional[int] = None
    warnings: Optional[int] = None
    unlinked: Optional[int] = None
    trend: Optional[str] = None
    products: Optional[int] = None
    fks: Optional[int] = None


@dataclass
class EvolutionEffort:
    """AI effort/cost for the run that produced this version."""

    total_ai_calls: Optional[int] = None
    estimated_input_tokens: Optional[int] = None
    estimated_output_tokens: Optional[int] = None
    estimated_total_cost_usd: Optional[float] = None
    per_model_cost_usd: dict[str, float] = field(default_factory=dict)
    duration_hours: Optional[float] = None


@dataclass
class EvolutionProvenance:
    agent_version: Optional[str] = None
    generated_from_version: Optional[str] = None
    target_model_version: Optional[str] = None
    status: Optional[str] = None


@dataclass
class EvolutionMetrics:
    """All evolution metric areas for one model version, plus data-driven
    degradation flags so the FE doesn't have to re-derive them."""

    size: EvolutionSize = field(default_factory=EvolutionSize)
    quality: EvolutionQuality = field(default_factory=EvolutionQuality)
    change: EvolutionChange = field(default_factory=EvolutionChange)
    effort: EvolutionEffort = field(default_factory=EvolutionEffort)
    provenance: EvolutionProvenance = field(default_factory=EvolutionProvenance)

    has_metadata: bool = False
    has_confidence: bool = False
    has_predecessor: bool = False


def _parse_version_history(raw: object) -> list[VersionHistoryEntry]:
    if not isinstance(raw, list):
        return []
    out: list[VersionHistoryEntry] = []
    for item in raw:
        if not isinstance(item, dict):
            continue
        out.append(
            VersionHistoryEntry(
                version=str(item.get("version", "")),
                confidence=_as_int(item.get("confidence")),
                errors=_as_int(item.get("errors")),
                warnings=_as_int(item.get("warnings")),
                unlinked=_as_int(item.get("unlinked")),
                trend=item.get("trend") if isinstance(item.get("trend"), str) else None,
                products=_as_int(item.get("products")),
                fks=_as_int(item.get("fks")),
            )
        )
    return out


def _structure_size_fallback(model: Optional[dict]) -> EvolutionSize:
    """Derive size counts from the model structure dict.

    Used when the envelope has no ``model_stats_at_generation`` (hand-edited /
    pre-metadata files). ``unlinked_id_count``/``siloed_count`` stay None —
    those are static-analysis findings only the agent can compute, so we don't
    fabricate them from structure."""
    size = EvolutionSize()
    if not isinstance(model, dict):
        return size
    domains = model.get("domains", []) or []
    size.domain_count = len(domains)
    products = [p for d in domains for p in (d.get("products", []) or [])]
    size.product_count = len(products)
    attrs = [a for p in products for a in (p.get("attributes", []) or [])]
    size.attribute_count = len(attrs)
    size.fk_count = count_fk_attributes(attrs)
    return size


def _avg_attrs(product_count: Optional[int], attribute_count: Optional[int]) -> Optional[float]:
    if not product_count or attribute_count is None:
        return None
    return round(attribute_count / product_count, 1)


def compute_metrics(
    metadata: Optional[dict],
    model: Optional[dict] = None,
    *,
    agent_version: Optional[str] = None,
) -> EvolutionMetrics:
    """Project the agent's ``_vibe_session_metadata`` onto the metric areas.

    ``metadata`` is the ``_vibe_session_metadata`` block (or None). ``model``
    is the model-structure dict used only as the size fallback when the agent
    stats are absent. ``agent_version`` is the envelope's top-level
    ``agent_version`` (the metadata block doesn't carry it).
    """
    metrics = EvolutionMetrics()

    if not isinstance(metadata, dict):
        # No session metadata at all. Size still degrades to structure-derived
        # counts; every other area stays empty/null.
        metrics.size = _structure_size_fallback(model)
        metrics.size.avg_attributes_per_product = _avg_attrs(
            metrics.size.product_count, metrics.size.attribute_count
        )
        metrics.provenance = EvolutionProvenance(agent_version=agent_version)
        return metrics

    metrics.has_metadata = True

    # --- Size ---------------------------------------------------------------
    stats = metadata.get("model_stats_at_generation")
    if isinstance(stats, dict) and stats:
        size = EvolutionSize(
            domain_count=_as_int(stats.get("domain_count")),
            product_count=_as_int(stats.get("product_count")),
            attribute_count=_as_int(stats.get("attribute_count")),
            fk_count=_as_int(stats.get("fk_count")),
            unlinked_id_count=_as_int(stats.get("unlinked_id_count")),
            siloed_count=_as_int(stats.get("siloed_count")),
        )
        # Backfill any missing count from the structure so the FE always has a
        # number, but keep the agent's authoritative value when present.
        fallback = _structure_size_fallback(model)
        for f in ("domain_count", "product_count", "attribute_count", "fk_count"):
            if getattr(size, f) is None:
                setattr(size, f, getattr(fallback, f))
    else:
        size = _structure_size_fallback(model)
    size.avg_attributes_per_product = _avg_attrs(size.product_count, size.attribute_count)
    metrics.size = size

    # --- Quality ------------------------------------------------------------
    confidence = _as_float(metadata.get("confidence_score"))
    # ECM (and any unjudged run) emits no confidence; the agent default is 0,
    # which is indistinguishable from a real 0. Treat 0/absent as "no
    # confidence" — the quality judge never produces a genuine 0.
    if confidence is None or confidence == 0:
        confidence = None
    metrics.has_confidence = confidence is not None

    issue_counts = metadata.get("issue_counts")
    issue_counts = issue_counts if isinstance(issue_counts, dict) else {}
    addressed = metadata.get("issues_addressed")
    not_addressed = metadata.get("issues_not_addressed")
    metrics.quality = EvolutionQuality(
        confidence_score=confidence,
        error_count=_as_int(issue_counts.get("error")),
        warning_count=_as_int(issue_counts.get("warning")),
        info_count=_as_int(issue_counts.get("info")),
        issues_addressed=[str(x) for x in addressed] if isinstance(addressed, list) else [],
        issues_not_addressed=(
            [str(x) for x in not_addressed] if isinstance(not_addressed, list) else []
        ),
    )

    # --- Change vs previous -------------------------------------------------
    progression = metadata.get("progression")
    progression = progression if isinstance(progression, dict) else {}
    trend = progression.get("version_trend")
    trend = trend if isinstance(trend, str) and trend else None
    history = _parse_version_history(metadata.get("version_history"))

    # A version has a predecessor when the agent classified it against one.
    # ``version_trend`` is "baseline" exactly when there was no scored
    # predecessor; a >1-entry history is the fallback signal for older files
    # that didn't stamp a trend.
    metrics.has_predecessor = (trend is not None and trend != _BASELINE_TREND) or len(history) > 1

    if metrics.has_predecessor:
        change = EvolutionChange(
            version_trend=trend,
            confidence_delta=_as_int(progression.get("confidence_delta")),
            warnings_delta=_as_int(progression.get("warnings_delta")),
            errors_delta=_as_int(progression.get("errors_delta")),
            unlinked_delta=_as_int(progression.get("unlinked_delta")),
            previous_confidence=_as_int(progression.get("previous_confidence")),
            previous_warnings=_as_int(progression.get("previous_warnings")),
            previous_errors=_as_int(progression.get("previous_errors")),
            previous_unlinked=_as_int(progression.get("previous_unlinked")),
            version_history=history,
        )
    else:
        # Baseline: surface the trend (so the FE can label it) and the history
        # (single entry, for a degenerate sparkline) but leave deltas/previous
        # null — there is no predecessor to diff against, so a 0 would be a lie.
        change = EvolutionChange(
            version_trend=trend or _BASELINE_TREND,
            version_history=history,
        )
    metrics.change = change

    # --- Effort -------------------------------------------------------------
    ai_usage = metadata.get("ai_usage")
    ai_usage = ai_usage if isinstance(ai_usage, dict) else {}
    per_model = ai_usage.get("per_model_cost_usd")
    per_model_clean: dict[str, float] = {}
    if isinstance(per_model, dict):
        for k, v in per_model.items():
            fv = _as_float(v)
            if fv is not None:
                per_model_clean[str(k)] = fv
    metrics.effort = EvolutionEffort(
        total_ai_calls=_as_int(ai_usage.get("total_ai_calls")),
        estimated_input_tokens=_as_int(ai_usage.get("estimated_input_tokens")),
        estimated_output_tokens=_as_int(ai_usage.get("estimated_output_tokens")),
        estimated_total_cost_usd=_as_float(ai_usage.get("estimated_total_cost_usd")),
        per_model_cost_usd=per_model_clean,
        duration_hours=_as_float(metadata.get("duration_hours")),
    )

    # --- Provenance ---------------------------------------------------------
    metrics.provenance = EvolutionProvenance(
        agent_version=agent_version,
        generated_from_version=(
            str(metadata["generated_from_version"])
            if metadata.get("generated_from_version")
            else None
        ),
        target_model_version=(
            str(metadata["target_model_version"])
            if metadata.get("target_model_version")
            else None
        ),
        status=metadata.get("status") if isinstance(metadata.get("status"), str) else None,
    )

    return metrics


__all__ = [
    "EvolutionMetrics",
    "EvolutionSize",
    "EvolutionQuality",
    "EvolutionChange",
    "VersionHistoryEntry",
    "EvolutionEffort",
    "EvolutionProvenance",
    "compute_metrics",
]

"""The changes a vibe run made, and the modeler's accept or reject of each.

A vibe run with base version B and output version P changed whatever
``model_diff.compute_model_diff(B, P)`` reports. :func:`build_run_changes`
lists those changes at the grain the modeler decides on: a domain added or
removed, a product added or removed in a kept domain, an attribute added,
changed or removed in a kept product. A changed domain or product is only the
roll-up of its children, so it is not listed on its own.

Each change carries a hint, ``change_class``, read from what the run sent:

* ``asked``: the element, or its product or domain, is the anchor of an input
  the run sent, or the target of an ``applied`` outcome. A subdomain anchor or
  target counts as its domain (products are listed by domain, not subdomain);
* ``outside_scope``: a scoped run changed a domain outside its scope;
* ``unclear``: the run sent a model-wide input, so any change may be asked;
* ``not_asked``: none of the above.

Names compare with ``core/_vibe_scope.scope_key``, the agent's own rule.

The diff sees attribute type (case-insensitive here), ``foreign_key_to`` and
the first 100 characters of an attribute's description, plus added and removed
elements. It does not see product or domain descriptions, primary keys, table
or column names, tags, glossary terms or value patterns; a rename shows as a
removal and an addition.

Decisions are ``run_change_decisions`` rows, changeable until a model run
(``MODEL_PRODUCING_INTENTS``) starts from P and does not fail or get
cancelled before producing a version. A rejected change can become a feedback item
(``origin=change_rejection``), anchored on the element in P, or on its parent
for a removed element, and not selected for a run.
"""

from __future__ import annotations

import json
from dataclasses import dataclass
from datetime import datetime, timezone
from typing import Optional

from fastapi import HTTPException
from sqlalchemy import update
from sqlalchemy.exc import IntegrityError
from sqlmodel import Session, col, select

from ._compile import MODEL_WIDE_TARGET, anchor_domain_and_target
from .core._time import as_utc
from .core._vibe_input_create import create_vibe_input_with_anchor
from .core._vibe_scope import run_scope_domains, scope_key
from .core.anchor_resolve import NamedAnchor, prefetch_anchor_maps, resolve_named_anchor
from .db_models import (
    Domain,
    ModelVersion,
    Run,
    RunChangeDecision,
    RunInputLink,
    RunOperation,
    Subdomain,
    VibeInput,
    VibeInputContextLink,
)
from .explorer import _load_model
from .fk import build_fqn
from .model_diff import compute_model_diff
from .models import (
    ChangeStatus,
    RunChangeDecisionIn,
    RunChangeOut,
    RunChangesOut,
    VibeInputOrigin,
    VibeInputPriority,
)
from .run_report import OUTCOME_APPLIED, vibe_output_version_id
from .run_version_semantics import MODEL_PRODUCING_INTENTS

UNAVAILABLE_NO_VIBE_OUTPUT = "no_vibe_output"
UNAVAILABLE_NO_BASE = "no_base_version"
UNAVAILABLE_MODEL = "model_not_loaded"


class ChangesUnavailable(Exception):
    """The run's changes cannot be listed; ``reason`` is one of the
    ``UNAVAILABLE_*`` values."""

    def __init__(self, reason: str, message: str):
        super().__init__(message)
        self.reason = reason
        self.message = message


class DecisionsClosed(Exception):
    """A newer model run has started from the run's output version."""


class UnknownChanges(Exception):
    """A decision names a change the run did not make."""

    def __init__(self, keys: list[tuple[str, str]]):
        super().__init__(", ".join(f"{k}:{p}" for k, p in keys))
        self.keys = keys


@dataclass(frozen=True)
class ModelChange:
    """One listed change: ``parts`` are the element's names from the domain down."""

    element_kind: str
    parts: tuple[str, ...]
    change_kind: str

    @property
    def element_path(self) -> str:
        return build_fqn(*self.parts)


def list_model_changes(base_model: dict, output_model: dict) -> list[ModelChange]:
    """The decidable changes between two model dicts, sorted by path."""
    diff = compute_model_diff(base_model, output_model, type_case_sensitive=False)
    new_domains = {d for d, st in diff["domains"].items() if st == ChangeStatus.NEW}
    new_products = {k for k, st in diff["products"].items() if st == ChangeStatus.NEW}
    out: list[ModelChange] = []
    for dn in new_domains:
        out.append(ModelChange("domain", (dn,), "added"))
    for d in diff["deleted_domains"]:
        out.append(ModelChange("domain", (d.name,), "removed"))
    for dn, pn in new_products:
        if dn not in new_domains:
            out.append(ModelChange("product", (dn, pn), "added"))
    for dn, products in diff["deleted_products"].items():
        for p in products:
            out.append(ModelChange("product", (dn, p.name), "removed"))
    for (dn, pn, an), st in diff["attributes"].items():
        if (dn, pn) in new_products:
            continue
        out.append(ModelChange("attribute", (dn, pn, an), "added" if st == ChangeStatus.NEW else "modified"))
    for (dn, pn), attrs in diff["deleted_attributes"].items():
        for a in attrs:
            out.append(ModelChange("attribute", (dn, pn, a.name), "removed"))
    return sorted(out, key=lambda c: (tuple(p.lower() for p in c.parts), c.change_kind))


def _key(parts) -> tuple[str, ...]:
    return tuple(scope_key(p) for p in parts)


@dataclass
class _RunAsk:
    """What the run sent, reduced to what the hint needs."""

    anchor_paths: set[tuple[str, ...]]
    model_wide: bool
    scope_keys: Optional[set[str]]


@dataclass
class _BaseNames:
    """Keyed ``(domain, subdomain)`` and ``(domain, product)`` pairs of the base."""

    subdomains: set[tuple[str, str]]
    products: set[tuple[str, str]]

    def reduce(self, parts: tuple[str, ...]) -> tuple[str, ...]:
        """A ``domain.subdomain`` target counts as its domain."""
        keyed = _key(parts)
        if len(keyed) == 2 and keyed in self.subdomains and keyed not in self.products:
            return parts[:1]
        return parts


def _base_names(session: Session, base_id: str, base_model: dict) -> _BaseNames:
    subdomains: set[tuple[str, str]] = set()
    products: set[tuple[str, str]] = set()
    for d in base_model.get("domains", []):
        dk = scope_key(d.get("name", ""))
        for p in d.get("products", []):
            products.add((dk, scope_key(p.get("name") or p.get("product") or "")))
            if p.get("subdomain"):
                subdomains.add((dk, scope_key(p["subdomain"])))
    for dname, sname in session.exec(
        select(Domain.name, Subdomain.name)
        .join(Domain, Domain.id == Subdomain.domain_id)
        .where(Subdomain.version_id == base_id)
    ).all():
        subdomains.add((scope_key(dname), scope_key(sname)))
    return _BaseNames(subdomains=subdomains, products=products)


def _target_parts(target: str) -> tuple[str, ...]:
    """A compile or outcome target as names; empty when model-wide."""
    target = (target or "").strip()
    if not target or target == MODEL_WIDE_TARGET:
        return ()
    return tuple(target.split("."))


def _input_link(session: Session, input_id: str, base_version_id: str) -> Optional[VibeInputContextLink]:
    """The input's anchor on the base version the run compiled from, else its origin link."""
    links = session.exec(
        select(VibeInputContextLink).where(VibeInputContextLink.input_id == input_id)
    ).all()
    for lk in links:
        if lk.version_id == base_version_id:
            return lk
    return next((lk for lk in links if lk.is_origin), None)


def _run_scope_keys(run: Run) -> Optional[set[str]]:
    """The scoped run's domain keys, or None for an All Domains run. The stored
    launch parameters go through the same rule the compile used."""
    try:
        params = json.loads(run.parameters_json) if run.parameters_json else {}
    except (TypeError, ValueError):
        params = {}
    if not isinstance(params, dict):
        params = {}
    domains = run_scope_domains(params.get("vibe_scope"), params.get("vibe_scope_domains"))
    return {scope_key(d) for d in domains} if domains else None


def _run_ask(session: Session, run: Run, base_id: str, names: _BaseNames) -> _RunAsk:
    """The anchors use the same target the compile sent the agent
    (``_compile.anchor_domain_and_target``)."""
    ask = _RunAsk(anchor_paths=set(), model_wide=False, scope_keys=_run_scope_keys(run))
    for link in session.exec(select(RunInputLink).where(RunInputLink.run_id == run.id)).all():
        anchor = _input_link(session, link.input_id, base_id)
        if anchor is not None:
            path = _target_parts(anchor_domain_and_target(session, anchor)[1])
            if path:
                ask.anchor_paths.add(_key(names.reduce(path)))
            else:
                ask.model_wide = True
        if link.outcome_status == OUTCOME_APPLIED:
            path = _target_parts(link.outcome_target or "")
            if path:
                ask.anchor_paths.add(_key(names.reduce(path)))
    return ask


def classify_change(change: ModelChange, ask: _RunAsk) -> str:
    keyed = _key(change.parts)
    if any(keyed[: len(a)] == a for a in ask.anchor_paths):
        return "asked"
    if ask.scope_keys is not None and keyed[0] not in ask.scope_keys:
        return "outside_scope"
    if ask.model_wide:
        return "unclear"
    return "not_asked"


# A run in one of these states that produced no version never changed the model.
_ENDED_WITHOUT_OUTPUT = ("failed", "cancelled", "rolled_back_failed")


def decisions_open(session: Session, run: Run, version_id: str) -> bool:
    """False once another model-producing run has an operation that starts
    from ``version_id`` and is in flight, completed, or produced a version.
    Install, uninstall and sample runs, and model runs that failed or were
    cancelled before producing a version, leave decisions open."""
    candidates = session.exec(
        select(Run.id, Run.status)
        .join(RunOperation, RunOperation.run_id == Run.id)
        .where(RunOperation.parent_version_id == version_id)
        # An uninstall step names the version it removes (a source industry's
        # in a kickstarted business's run); it does not start from it.
        .where(RunOperation.operation_name != "uninstall")
        .where(Run.id != run.id)
        .where(col(Run.intent).in_(MODEL_PRODUCING_INTENTS))
    ).all()
    for run_id, status in candidates:
        if status not in _ENDED_WITHOUT_OUTPUT:
            return False
        produced = session.exec(
            select(RunOperation.id)
            .where(RunOperation.run_id == run_id)
            .where(RunOperation.output_version_id.is_not(None))
        ).first()
        if produced is not None:
            return False
    return True


@dataclass
class _Loaded:
    output: ModelVersion
    base: ModelVersion
    names: _BaseNames
    changes: list[ModelChange]


def _load_changes(session: Session, ws, run: Run) -> _Loaded:
    output_id = vibe_output_version_id(session, run.id)
    output = session.get(ModelVersion, output_id) if output_id else None
    if output is None:
        raise ChangesUnavailable(UNAVAILABLE_NO_VIBE_OUTPUT, "This run produced no vibe version.")
    base = session.get(ModelVersion, output.base_version_id) if output.base_version_id else None
    if base is None:
        raise ChangesUnavailable(
            UNAVAILABLE_NO_BASE,
            "The version this run started from is gone, so its changes cannot be listed.",
        )
    try:
        base_model = _load_model(session, ws, run.business_id, base.version, base.scope or "")
        output_model = _load_model(session, ws, run.business_id, output.version, output.scope or "")
    except HTTPException as exc:
        raise ChangesUnavailable(
            UNAVAILABLE_MODEL, f"A model of this run could not be loaded: {exc.detail}",
        ) from exc
    if not base_model.get("domains") or not output_model.get("domains"):
        raise ChangesUnavailable(UNAVAILABLE_MODEL, "A model of this run has no domains yet.")
    return _Loaded(
        output=output,
        base=base,
        names=_base_names(session, base.id, base_model),
        changes=list_model_changes(base_model, output_model),
    )


def _decision_rows(session: Session, run_id: str) -> dict[tuple[str, str], RunChangeDecision]:
    rows = session.exec(select(RunChangeDecision).where(RunChangeDecision.run_id == run_id)).all()
    return {(r.element_kind, r.element_path): r for r in rows}


def _assemble(session: Session, run: Run, loaded: _Loaded) -> RunChangesOut:
    output_id, base_id = loaded.output.id, loaded.base.id
    ask = _run_ask(session, run, base_id, loaded.names)
    rows = _decision_rows(session, run.id)
    out: list[RunChangeOut] = []
    for c in loaded.changes:
        row = rows.get((c.element_kind, c.element_path))
        out.append(RunChangeOut(
            element_kind=c.element_kind,
            element_path=c.element_path,
            change_kind=c.change_kind,
            change_class=classify_change(c, ask),
            decision=row.decision if row else None,
            decided_by=row.decided_by if row else None,
            decided_at=as_utc(row.decided_at) if row else None,
            feedback_input_id=row.feedback_input_id if row else None,
        ))
    return RunChangesOut(
        run_id=run.id,
        version_id=output_id,
        base_version_id=base_id,
        decisions_open=decisions_open(session, run, output_id),
        changes=out,
    )


def build_run_changes(session: Session, ws, run: Run) -> RunChangesOut:
    """``getRunChanges``. Raises :class:`ChangesUnavailable`."""
    return _assemble(session, run, _load_changes(session, ws, run))


def _apply_decisions(
    session: Session, run_id: str, output_id: str, decisions: list[RunChangeDecisionIn],
    by_key: dict[tuple[str, str], ModelChange], actor: str,
) -> None:
    rows = _decision_rows(session, run_id)
    now = datetime.now(timezone.utc)
    for d in decisions:
        key = (d.element_kind, d.element_path)
        row = rows.get(key)
        if row is None:
            row = RunChangeDecision(
                run_id=run_id,
                version_id=output_id,
                element_kind=d.element_kind,
                element_path=d.element_path,
                change_kind=by_key[key].change_kind,
            )
            rows[key] = row
        row.decision = d.decision
        row.decided_by = actor
        row.decided_at = now
        session.add(row)
    session.commit()


def set_run_change_decisions(
    session: Session, ws, run: Run, decisions: list[RunChangeDecisionIn], actor: str,
) -> RunChangesOut:
    """Record or change decisions, then commit. Every check runs before the
    first write: a closed run or a change the run did not make writes nothing.

    Two requests deciding the same new change both insert its row; the one
    that loses on the unique key rolls back, reads the winner's row and
    applies its own decision over it (the later decision wins).
    """
    loaded = _load_changes(session, ws, run)
    run_id, output_id = run.id, loaded.output.id
    if not decisions_open(session, run, output_id):
        raise DecisionsClosed()
    by_key = {(c.element_kind, c.element_path): c for c in loaded.changes}
    unknown = [(d.element_kind, d.element_path) for d in decisions if (d.element_kind, d.element_path) not in by_key]
    if unknown:
        raise UnknownChanges(unknown)
    try:
        _apply_decisions(session, run_id, output_id, decisions, by_key, actor)
    except IntegrityError:
        session.rollback()
        _apply_decisions(session, run_id, output_id, decisions, by_key, actor)
    return _assemble(session, run, loaded)


def rejection_feedback_text(change: ModelChange, version: int) -> str:
    """The feedback item text for one rejected change."""
    what = f"the {change.element_kind} {change.element_path}"
    if change.change_kind == "added":
        return f"Remove {what}. The run that made v{version} added it, and I did not ask for it."
    if change.change_kind == "removed":
        return f"Restore {what}. The run that made v{version} removed it, and I did not ask for that."
    return (
        f"Undo the change to {what}. The run that made v{version} changed its type, foreign key "
        "or description, and I did not ask for that."
    )


def _anchor_parts(change: ModelChange) -> tuple[str, ...]:
    """The element in P to anchor on: the element itself, or its parent when removed."""
    return change.parts[:-1] if change.change_kind == "removed" else change.parts


def add_rejected_as_feedback(session: Session, ws, run: Run, author: str) -> RunChangesOut:
    """One unselected feedback item per rejected change that has none yet,
    linked from its decision row; then commit.

    Anchors resolve against one prefetch of P's elements. Each item is linked
    with a compare-and-set on ``feedback_input_id IS NULL``; when another
    request linked that decision first, this request deletes the item it made,
    so a race leaves one item per rejection.
    """
    loaded = _load_changes(session, ws, run)
    output_id, output_version = loaded.output.id, loaded.output.version
    if not decisions_open(session, run, output_id):
        raise DecisionsClosed()
    by_key = {(c.element_kind, c.element_path): c for c in loaded.changes}
    pending = [
        (row.id, by_key[key])
        for key, row in sorted(_decision_rows(session, run.id).items())
        if row.decision == "rejected" and not row.feedback_input_id and key in by_key
    ]
    if not pending:
        return _assemble(session, run, loaded)
    maps = prefetch_anchor_maps(session, output_id)
    try:
        made: list[tuple[str, VibeInput]] = []
        for row_id, change in pending:
            parts = _anchor_parts(change)
            fks = resolve_named_anchor(session, output_id, NamedAnchor(
                domain_name=parts[0] if len(parts) > 0 else None,
                product_name=parts[1] if len(parts) > 1 else None,
                attribute_name=parts[2] if len(parts) > 2 else None,
            ), maps)
            made.append((row_id, create_vibe_input_with_anchor(
                session=session,
                business_id=run.business_id,
                text=rejection_feedback_text(change, output_version),
                author=author,
                version_id=output_id,
                origin=VibeInputOrigin.CHANGE_REJECTION,
                priority=VibeInputPriority.MEDIUM,
                confidence_score=None,
                domain_id=fks.domain_id,
                product_id=fks.product_id,
                attribute_id=fks.attribute_id,
                subdomain_id=fks.subdomain_id,
                needs_link_review=fks.needs_link_review,
            )))
        for row_id, vi in made:
            linked = session.execute(
                update(RunChangeDecision)
                .where(col(RunChangeDecision.id) == row_id, col(RunChangeDecision.feedback_input_id).is_(None))
                .values(feedback_input_id=vi.id)
                .execution_options(synchronize_session=False)
            ).rowcount
            if linked != 1:
                for link in session.exec(
                    select(VibeInputContextLink).where(VibeInputContextLink.input_id == vi.id)
                ).all():
                    session.delete(link)
                session.delete(vi)
        session.commit()
    except Exception:
        session.rollback()
        raise
    return _assemble(session, run, loaded)


__all__ = [
    "ChangesUnavailable",
    "DecisionsClosed",
    "ModelChange",
    "UnknownChanges",
    "add_rejected_as_feedback",
    "build_run_changes",
    "classify_change",
    "decisions_open",
    "list_model_changes",
    "rejection_feedback_text",
    "set_run_change_decisions",
]

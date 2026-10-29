"""Shared compile helper: serialize selected VibeInputs into one markdown doc.

This is the single source of truth for turning a set of anchored VibeInputs
into the instruction document handed to the agent. Both the run-launch path
and the read-only preview endpoint call :func:`compile_inputs` so they cannot
drift (replaces ``_merge_feedback_into_instructions`` +
``_merge_next_vibes_into_instructions``). See task5-backend-api.md §5.

Pure/read-only: it reads VibeInput + VibeInputContextLink + element rows and
returns a :class:`CompileOut`. It records nothing.

Provenance (origin/author/confidence) rides only in the structured ``blocks``.

Two documents come out of one pass:

- ``markdown`` is the human preview. It carries NO inline anchors and NO
  markers, and it is pinned byte-for-byte to the FE twin by the frozen fixture
  (tests/fixtures/compile_blocks_fixture.json).
- ``agent_markdown`` is what launch sends to the agent (``model_vibes``). It
  has the same headers and bodies plus, per item, an inline ``[<target>]``
  anchor at the start of each short bullet and a K1 marker
  ``<!-- vi:<input_id> target=<target> -->`` (integration guide §16.3). A short
  bullet carries a trailing marker (its span is that line); a rich block gets
  a standalone marker line just before its ``> Priority:`` line (an opener
  whose span runs to the next marker). ``<!--`` and ``-->`` in user text are
  escaped in ``agent_markdown`` only, so the app's markers are the only
  comments the agent sees.

Scoped compile (``scope_domains`` non-empty): only items whose anchor domain
matches a scope domain (``core._vibe_scope.scope_key`` normalization) are
included. Other items are excluded with ``out_of_scope``, and model-wide items
with ``model_wide_in_scoped_run``. Exclusion never touches ``selected_for_run``.
"""

from __future__ import annotations

from typing import Optional

from sqlmodel import Session, select

from .core._vibe_scope import scope_key
from .core.anchor_resolve import capture_named_anchor
from .db_models import (
    Attribute,
    Domain,
    ForeignKeyLink,
    Product,
    Subdomain,
    VibeInput,
    VibeInputContextLink,
)
from .models import CompiledBlockOut, CompileOut, VibeInputOrigin, VibeInputPriority

EXCLUDE_DEPRECATED = "deprecated"
EXCLUDE_NO_ANCHOR = "no_anchor_on_version"
EXCLUDE_MISSING = "missing"
EXCLUDE_OUT_OF_SCOPE = "out_of_scope"
EXCLUDE_MODEL_WIDE_SCOPED = "model_wide_in_scoped_run"

# K1 target for a model-wide item (only ever sent on an All Domains run).
MODEL_WIDE_TARGET = "model"


def _oneline(text: str) -> str:
    return " ".join((text or "").split())


def _is_rich(text: str) -> bool:
    """Long/rich input detector: a newline OR length > 150 on the RAW text.

    Mirrors the FE ``isRichText`` heuristic exactly; the two are kept in
    lockstep by the frozen fixture (tests/fixtures/compile_blocks_fixture.json),
    not by sharing code. Detection runs on the raw text, never the
    oneline-collapsed text — collapsing would destroy both signals.
    """
    t = text or ""
    return "\n" in t or len(t) > 150


def _block_body(text: str) -> str:
    """Outer-trim a rich block body, preserving internal structure.

    Leading newlines only are stripped (leading spaces/tabs on the first
    content line are meaningful Markdown indentation and survive); the
    trailing run over the exact class ``[ \\t\\r\\n]`` is stripped. NOT
    ``.rstrip()`` (Unicode whitespace) — the FE twin uses the same 4-char
    class so the two languages can never disagree.
    """
    return (text or "").lstrip("\n").rstrip(" \t\r\n")


def _sort_key(name: str) -> str:
    return (name or "").lower()


class _Anchor:
    """The resolved hierarchy path for a single link, used to group + sort."""

    __slots__ = ("kind", "names", "sort_keys", "section_path", "headers")

    def __init__(self, kind, names, sort_keys, section_path, headers):
        self.kind = kind                  # "model_wide" | "element"
        self.names = names                # raw element names for headers
        self.sort_keys = sort_keys        # case-insensitive sort tuple
        self.section_path = section_path  # for the block, e.g. ["Domain: X"]
        self.headers = headers            # [(level, text)] for markdown


def _resolve_anchor(session: Session, link: VibeInputContextLink) -> _Anchor:
    """Build the hierarchy headers + section path for a single link's anchor.

    Element names are resolved from the rows on the link's version via
    ``session.get`` (one row per element grain). For listing many links use
    :func:`build_anchor` with prefetched element maps to avoid an N+1.
    """
    return build_anchor(
        link,
        domain=session.get(Domain, link.domain_id) if link.domain_id else None,
        subdomain=session.get(Subdomain, link.subdomain_id) if link.subdomain_id else None,
        product=session.get(Product, link.product_id) if link.product_id else None,
        attribute=session.get(Attribute, link.attribute_id) if link.attribute_id else None,
        fk=session.get(ForeignKeyLink, link.fk_link_id) if link.fk_link_id else None,
    )


def build_anchor(
    link: VibeInputContextLink,
    *,
    domain=None,
    subdomain=None,
    product=None,
    attribute=None,
    fk=None,
) -> _Anchor:
    """Assemble an ``_Anchor`` from a link + its already-resolved element rows.

    The single source of the headers / section-path / sort-key construction;
    both the per-link resolver (``session.get``) and the batched list path feed
    their rows in here so the two can't drift.
    """
    if not any((link.domain_id, link.subdomain_id, link.product_id,
                link.attribute_id, link.fk_link_id)):
        return _Anchor("model_wide", {}, (), ["Model-wide"], [(2, "Model-wide")])

    headers: list[tuple[int, str]] = []
    section_path: list[str] = []
    names: dict[str, str] = {}

    dom = domain
    sub = subdomain
    prod = product
    attr = attribute

    if dom is not None:
        names["domain"] = dom.name
        headers.append((2, f"Domain: {dom.name}"))
        section_path.append(f"Domain: {dom.name}")
    if sub is not None:
        names["subdomain"] = sub.name
        headers.append((3, f"Subdomain: {sub.name}"))
        section_path.append(f"Subdomain: {sub.name}")
    if prod is not None:
        names["product"] = prod.name
        headers.append((4, f"Product: {prod.name}"))
        section_path.append(f"Product: {prod.name}")
    if attr is not None:
        names["attribute"] = attr.name
        headers.append((5, f"Attribute: {attr.name}"))
        section_path.append(f"Attribute: {attr.name}")
    if fk is not None:
        label = f"{fk.source_product}.{fk.source_column}→{fk.target_product}.{fk.target_column}"
        names["fk"] = label
        headers.append((5, f"Relationship: {label}"))
        section_path.append(f"Relationship: {label}")
        # Intra-domain relationship: surface the shared domain so consumers can
        # focus the diagram on it (both FK endpoints live there). Names-only — no
        # Domain header/section_path entry, so grouping + compiled output are
        # unchanged; this just lets the anchor's domain_name resolve.
        if fk.source_domain and fk.source_domain == fk.target_domain:
            names.setdefault("domain", fk.source_domain)

    # Sort on the TYPE-PREFIXED section-path labels (lowercased, element-wise),
    # NOT the bare element names. Sibling anchors of different element types
    # under one parent (e.g. a Subdomain "aaa" + a Relationship "zzz…") must
    # order by their prefixed display label so the BE matches the FE
    # `compilePreviewMarkdown`, which sorts on the same prefixed `anchorPath`.
    # Bare-name sort would diverge (aaa<zzz) from prefixed (relationship<subdomain).
    sort_keys = [_sort_key(p) for p in section_path]

    return _Anchor("element", names, tuple(sort_keys), section_path, headers)


def anchor_domain_and_target(
    session: Session, link: VibeInputContextLink
) -> tuple[Optional[str], str]:
    """Return ``(anchor domain name, K1 target)`` for one link.

    The domain comes from the canonical ``capture_named_anchor`` walk
    (product/attribute anchors resolve up to their domain). An FK anchor
    belongs to its SOURCE domain (where the column lives). A subdomain-only
    anchor, which ``capture_named_anchor`` does not walk up, resolves its
    domain through ``Subdomain.domain_id``. A model-wide link has no domain.

    Target: ``source_domain.source_product.source_column`` for an FK;
    ``domain.product[.attribute]`` for a product/attribute anchor;
    ``domain.subdomain`` for a subdomain anchor; ``domain`` for a domain
    anchor; ``model`` for a model-wide anchor.
    """
    if link.fk_link_id:
        fk = session.get(ForeignKeyLink, link.fk_link_id)
        if fk is not None:
            parts = [fk.source_domain, fk.source_product, fk.source_column]
            target = ".".join(p for p in parts if p)
            return (fk.source_domain or None), (target or MODEL_WIDE_TARGET)
    named = capture_named_anchor(session, link)
    domain_name = named.domain_name
    if domain_name is None and link.subdomain_id:
        sub = session.get(Subdomain, link.subdomain_id)
        dom = session.get(Domain, sub.domain_id) if sub is not None else None
        domain_name = dom.name if dom is not None else None
    if named.product_name:
        parts = [domain_name, named.product_name, named.attribute_name]
    elif named.subdomain_name:
        parts = [domain_name, named.subdomain_name]
    else:
        parts = [domain_name]
    target = ".".join(p for p in parts if p)
    return domain_name, (target or MODEL_WIDE_TARGET)


def _k1_marker(input_id: str, target: str) -> str:
    return f"<!-- vi:{input_id} target={target} -->"


def _neutralize_comments(text: str) -> str:
    """Escape HTML comment delimiters in USER text for ``agent_markdown``.

    The agent parses every ``<!-- vi:... -->`` in ``model_vibes`` as a K1
    marker, so a comment typed into feedback would claim another item or a
    foreign target. Only the app-written markers may open or close a comment;
    the ``markdown`` preview keeps the text verbatim.
    """
    return text.replace("<!--", "&lt;!--").replace("-->", "--&gt;")


def compile_inputs(
    session: Session,
    version_id: str,
    input_ids: list[str],
    *,
    scope_domains: Optional[list[str]] = None,
) -> CompileOut:
    """Serialize the selected inputs anchored to ``version_id`` into markdown.

    - Drops inputs with ``status=deprecated`` (reported in excluded).
    - Drops inputs with no link on ``version_id`` (reason ``no_anchor_on_version``).
    - When ``scope_domains`` is non-empty, drops inputs whose anchor domain is
      not in scope (``out_of_scope``) and model-wide inputs
      (``model_wide_in_scoped_run``). Runs before ordering, so ``markdown`` for
      the included set is exactly the unscoped output for those ids.
    - ``input_scope_domains`` maps each existing, non-deprecated input to the
      domain the scoped filter above matches it by (None for model-wide
      inputs, anchors that resolve to no domain, and inputs with no link on
      this version). Filled with or without a scope, so the run form can
      pre-fill its scope from the same rule that later includes or excludes
      each item.
    - Groups by anchor: model-wide first, then Domain → Subdomain → Product →
      Attribute/Relationship, each sorted by element name (case-insensitive).
    - One bullet per input ``- (<priority>) <text-oneline>`` under its header.
    - ``markdown`` has no markers; ``agent_markdown`` adds the inline anchor
      and the K1 marker per item (see the module docstring).
    """
    out = CompileOut(markdown="")
    if not input_ids:
        return out
    scope_keys = {scope_key(d) for d in (scope_domains or []) if scope_key(d)}

    # Preserve nothing about caller order; we sort deterministically below.
    inputs = session.exec(
        select(VibeInput).where(VibeInput.id.in_(input_ids))
    ).all()
    by_id = {vi.id: vi for vi in inputs}

    # Per-input link on THIS version.
    links = session.exec(
        select(VibeInputContextLink).where(
            VibeInputContextLink.version_id == version_id,
            VibeInputContextLink.input_id.in_(input_ids),
        )
    ).all()
    link_by_input = {lk.input_id: lk for lk in links}

    entries: list[tuple[_Anchor, VibeInput, str]] = []
    for iid in input_ids:
        vi = by_id.get(iid)
        if vi is None:
            out.excluded_input_ids.append(iid)
            out.excluded_reasons[iid] = EXCLUDE_MISSING
            continue
        if vi.status == "deprecated":
            out.excluded_input_ids.append(iid)
            out.excluded_reasons[iid] = EXCLUDE_DEPRECATED
            continue
        link = link_by_input.get(iid)
        if link is None:
            out.excluded_input_ids.append(iid)
            out.excluded_reasons[iid] = EXCLUDE_NO_ANCHOR
            out.input_scope_domains[iid] = None
            continue
        anchor = _resolve_anchor(session, link)
        if anchor.kind == "model_wide":
            domain_name, target = None, MODEL_WIDE_TARGET
        else:
            domain_name, target = anchor_domain_and_target(session, link)
        out.input_scope_domains[iid] = domain_name
        if scope_keys:
            if anchor.kind == "model_wide":
                out.excluded_input_ids.append(iid)
                out.excluded_reasons[iid] = EXCLUDE_MODEL_WIDE_SCOPED
                continue
            if domain_name is None or scope_key(domain_name) not in scope_keys:
                out.excluded_input_ids.append(iid)
                out.excluded_reasons[iid] = EXCLUDE_OUT_OF_SCOPE
                continue
        entries.append((anchor, vi, target))

    # Deterministic ordering: model-wide first, then hierarchy by sort keys,
    # then by input text so the round-trip is stable. ORDERING uses the
    # oneline-collapsed text (even for rich inputs) so short/rich inputs
    # interleave predictably; RENDERING uses verbatim text. This split is
    # intentional — do not "fix" the key to use verbatim text.
    def _order(item: tuple[_Anchor, VibeInput, str]):
        anchor, vi, _target = item
        is_model_wide = 0 if anchor.kind == "model_wide" else 1
        return (is_model_wide, anchor.sort_keys, _oneline(vi.text).lower())

    entries.sort(key=_order)

    lines: list[str] = []
    agent_lines: list[str] = []
    emitted_headers: list[tuple[int, str]] = []
    for anchor, vi, target in entries:
        # Emit only header levels not already on the current header stack.
        # Drop any trailing headers from the previous anchor that differ.
        common = 0
        for a, b in zip(emitted_headers, anchor.headers):
            if a == b:
                common += 1
            else:
                break
        emitted_headers = list(anchor.headers)
        for level, text in anchor.headers[common:]:
            lines.append(f"{'#' * level} {text}")
            agent_lines.append(f"{'#' * level} {text}")
        marker = _k1_marker(vi.id, target)
        # Long/rich inputs render as a blank-fenced markdown block that
        # preserves their own newlines/markdown; short inputs stay a
        # one-line bullet. Detection + format mirror the FE exactly via the
        # frozen fixture.
        if _is_rich(vi.text):
            body = _block_body(vi.text)
            body_lines = body.split("\n") + [""] if body != "" else []
            lines.extend(["", f"> Priority: {vi.priority}", ""] + body_lines)
            # Opener marker on its own line, just before the Priority line.
            agent_body = [_neutralize_comments(ln) for ln in body_lines]
            agent_lines.extend(
                ["", marker, f"> Priority: {vi.priority}", ""] + agent_body
            )
        else:
            lines.append(f"- ({vi.priority}) {_oneline(vi.text)}")
            agent_lines.append(
                f"- ({vi.priority}) [{target}] "
                f"{_neutralize_comments(_oneline(vi.text))} {marker}"
            )

        out.included_input_ids.append(vi.id)
        out.blocks.append(CompiledBlockOut(
            input_id=vi.id,
            origin=VibeInputOrigin(vi.origin),
            priority=VibeInputPriority(vi.priority),
            author=vi.author,
            confidence_score=vi.confidence_score,
            section_path=list(anchor.section_path),
            text=vi.text,
        ))

    out.markdown = "\n".join(lines)
    out.agent_markdown = "\n".join(agent_lines)
    return out

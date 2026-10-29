"""In-process draft store. Drafting runs as asyncio background tasks so no HTTP
request is held open for an LLM call; the browser polls GET /drafts/{id}.

State is memory-only: lost on app restart -> the poll 404s and the UI offers
Draft again, which seeds the parts the user already has (``create`` with
``seed_tree`` / ``seed_sections``) so only the missing parts are drafted. The
wizard itself is saved in the database (``saved_state.py``). A draft expires
``ttl_seconds`` after its last activity (create, poll, retry). The app runs
uvicorn --workers 1, so one process owns all drafts.

Concurrency (design §4.4):

- Every LLM call takes one slot of the app-wide ``LLMSlots`` and runs on
  ``TAXONOMY_EXECUTOR``. The store is the one owner of the slot capacity: it
  applies the stored ``max_concurrency`` on every create and retry.
- Each part has its own ceiling (``PART_CEILING_SECONDS``, enough for
  ``complete_json``'s corrective retry). It starts when the part's call is
  submitted (the part turns ``running``), not while it waits for a slot. A
  part that hits it is ``timed_out``; its thread finishes on its own and frees
  its slot then.
- A part takes a slot before it starts. With none free, the decision is made
  per draft: if the draft still has calls in flight (running siblings, or
  calls a cancel or retry abandoned) the part stays ``pending`` and waits for
  one of them to end, then tries again; only when nothing of its draft is in
  flight does it go ``busy``. So a draft never competes with itself and never
  queues behind other users. The tree, each section and the description wait
  the same way; the wait is bounded by those in-flight calls, each capped by
  the LLM client's HTTP timeout.
- ``busy``: no free slot, or the gateway rate-limited the call. A busy tree
  sets the sections ``busy`` too ("waiting for the domains"). The client
  retries busy parts on its own countdown; a busy part holds no slot.
- A draft call that comes back ``denied``/``not_found`` is recorded in the
  model-service access cache (so ``ready`` turns false; ``not_before`` = when
  the call started, so a newer Test result wins) and the part fails; parts of
  that draft that have not started fail with the same message.
- One active draft per user per kind (create vs condense): starting one, or
  retrying a part of one, cancels the user's other drafts of that kind that
  still have live tasks. ``cancel`` and ``_purge`` drop a draft's tasks at
  once; the old calls' slots free when their threads end.
"""

from __future__ import annotations

import asyncio
import logging
import time
import uuid
from concurrent.futures import Executor, Future
from dataclasses import dataclass, field
from datetime import datetime
from typing import Any, Awaitable, Callable, Coroutine, Literal

from .access import MODEL_SERVICE_ACCESS, ModelServiceAccess
from .llm import (
    LLM_HTTP_TIMEOUT_SECONDS,
    ProbeResult,
    TaxonomyLLMBusy,
    TaxonomyLLMDenied,
    TaxonomyLLMError,
    TaxonomyLLMNotFound,
)
from .models import (
    PART_DESCRIPTION,
    PART_TREE,
    SECTION_KEYS,
    DraftStatus,
    PartStatus,
    TaxonomyCondenseIn,
    TaxonomyDraftOut,
    TaxonomyDraftPartOut,
    TaxonomyIntake,
    TaxonomySection,
    TaxonomyTree,
)
from .prompts import build_condense_prompt, build_section_prompt, build_tree_prompt
from .slots import TAXONOMY_EXECUTOR, TAXONOMY_SLOTS, LLMSlots, NoFreeSlot

log = logging.getLogger(__name__)
DESCRIPTION_LIMIT = 2000
# Two HTTP calls (complete_json's corrective retry) plus headroom.
PART_CEILING_SECONDS = 2 * LLM_HTTP_TIMEOUT_SECONDS + 30
BUSY_ERROR = "The model is busy"
WAITING_FOR_TREE = "waiting for the domains"
TREE_FAILED_ERROR = "the domain draft failed - retry the domains first"
TIMED_OUT_ERROR = "drafting took longer than the time limit"
UNEXPECTED_ERROR = "unexpected error while drafting this part"

KIND_CREATE = "create"
KIND_CONDENSE = "condense"
DraftKind = Literal["create", "condense"]

_LIVE = {"pending", "running"}
_TERMINAL = {"done", "failed", "cancelled", "timed_out"}
# Parts a retry may re-run. Never "done" (edit it instead).
_RETRYABLE = {"failed", "cancelled", "timed_out", "busy"}
_REFUSALS = (TaxonomyLLMDenied, TaxonomyLLMNotFound)


RetryResult = Literal["ok", "not_found", "bad_part", "needs_tree", "in_progress", "not_retryable"]


@dataclass
class _Part:
    status: PartStatus = "pending"
    error: str | None = None
    tree: TaxonomyTree | None = None
    section: TaxonomySection | None = None
    description: str | None = None
    gen: int = 0  # bumped by cancel/retry; runners only write while their captured gen is current


@dataclass(eq=False)
class _Draft:
    draft_id: str
    owner: str
    kind: DraftKind
    intake: TaxonomyIntake
    # Last activity (create, poll, retry): the TTL counts from here.
    touched: float
    parts: dict[str, _Part]
    condense: TaxonomyCondenseIn | None = None
    # Runner tasks of the current attempt. ``cancel`` empties it at once.
    tasks: set[asyncio.Task] = field(default_factory=set)
    # Executor calls of this draft whose threads have not ended (abandoned ones too).
    calls: set[Future] = field(default_factory=set)
    call_ended: asyncio.Event | None = None
    # A call of this draft was refused; not-yet-started parts fail with this.
    refusal: str | None = None
    # When the current attempt (create or the latest retry) began: a refusal
    # from a call started before it (abandoned by a cancel/retry) is stale.
    attempt_started: datetime | None = None

    def live(self) -> bool:
        return any(not t.done() for t in self.tasks)


def _overall(parts: dict[str, _Part]) -> DraftStatus:
    statuses = [p.status for p in parts.values()]
    if any(s in _LIVE for s in statuses):
        return "running"
    if all(s == "done" for s in statuses):
        return "done"
    order: tuple[DraftStatus, ...] = ("busy", "cancelled", "timed_out")
    for s in order:
        if s in statuses:
            return s
    return "failed"


def _set(p: _Part, gen: int, status: PartStatus, error: str | None) -> None:
    if p.gen == gen:
        p.status, p.error = status, error


class DraftStore:
    def __init__(
        self,
        *,
        ceiling_seconds: float = PART_CEILING_SECONDS,
        ttl_seconds: float = 3600,
        clock: Callable[[], float] = time.monotonic,
        slots: LLMSlots = TAXONOMY_SLOTS,
        executor: Executor = TAXONOMY_EXECUTOR,
        access: ModelServiceAccess = MODEL_SERVICE_ACCESS,
    ) -> None:
        self._ceiling = ceiling_seconds
        self._ttl = ttl_seconds
        self._clock = clock
        self._slots = slots
        self._executor = executor
        self._access = access
        self._drafts: dict[str, _Draft] = {}

    @property
    def _active(self) -> dict[tuple[str, str], set[str]]:
        """(owner, kind) -> ids of that owner's drafts of that kind with live
        tasks. Test-only view (like ``wait``); the store itself uses
        ``_Draft.live`` directly."""
        out: dict[tuple[str, str], set[str]] = {}
        for d in self._drafts.values():
            if d.live():
                out.setdefault((d.owner, d.kind), set()).add(d.draft_id)
        return out

    # ---- lifecycle -------------------------------------------------------
    def _purge(self) -> None:
        now = self._clock()
        for did in [d for d, v in self._drafts.items() if now - v.touched > self._ttl]:
            self._drop_tasks(self._drafts.pop(did))

    def _apply_capacity(self, capacity: int | None) -> None:
        if capacity is not None:
            self._slots.set_capacity(capacity)

    def _new(
        self, owner: str, kind: DraftKind, intake: TaxonomyIntake, keys: list[str], capacity: int | None,
    ) -> _Draft:
        self._purge()
        self._apply_capacity(capacity)
        self._supersede(owner, kind, keep=None)
        draft = _Draft(
            draft_id=uuid.uuid4().hex, owner=owner, kind=kind, intake=intake, touched=self._clock(),
            parts={k: _Part() for k in keys}, attempt_started=self._access.now(),
        )
        self._drafts[draft.draft_id] = draft
        return draft

    def _supersede(self, owner: str, kind: str, *, keep: str | None) -> None:
        """Cancel the owner's other drafts of ``kind`` that still have live tasks."""
        for d in list(self._drafts.values()):
            if d.owner == owner and d.kind == kind and d.draft_id != keep and d.live():
                self._cancel_draft(d)

    def _spawn(self, draft: _Draft, coro: Coroutine[Any, Any, None]) -> None:
        task = asyncio.get_running_loop().create_task(coro)
        draft.tasks.add(task)
        task.add_done_callback(draft.tasks.discard)

    @staticmethod
    def _drop_tasks(d: _Draft) -> None:
        tasks, d.tasks = d.tasks, set()
        for t in tasks:
            t.cancel()

    def _cancel_draft(self, d: _Draft) -> None:
        """Mark every unfinished part (busy included) cancelled and drop the
        tasks - all before returning."""
        for p in d.parts.values():
            if p.status not in _TERMINAL:
                p.gen += 1
                p.status, p.error = "cancelled", None
        self._drop_tasks(d)

    def _lookup(self, draft_id: str, owner: str) -> _Draft | None:
        """The owner's live draft, touched; expired drafts are purged first."""
        self._purge()
        d = self._drafts.get(draft_id)
        if d is None or d.owner != owner:
            return None
        d.touched = self._clock()
        return d

    def _mark_busy(self, d: _Draft, part: str) -> None:
        """Report ``part`` busy without calling the model (the pre-draft test
        call was busy). A busy tree leaves the sections waiting for it."""
        d.parts[part].status, d.parts[part].error = "busy", BUSY_ERROR
        if part == PART_TREE:
            for k in SECTION_KEYS:
                sp = d.parts[k]
                if sp.status in _LIVE:
                    sp.status, sp.error = "busy", WAITING_FOR_TREE

    # ---- public API ------------------------------------------------------
    def create(
        self, owner: str, intake: TaxonomyIntake, llm: Any, *, capacity: int | None = None, busy: bool = False,
        seed_tree: TaxonomyTree | None = None, seed_sections: dict[str, TaxonomySection] | None = None,
    ) -> str:
        """Draft the tree, then the sections. Seeded parts start ``done``
        without a model call: with ``seed_tree`` only the unseeded sections
        are drafted, and with every part seeded nothing runs."""
        draft = self._new(owner, KIND_CREATE, intake, [PART_TREE, *SECTION_KEYS], capacity)
        if seed_tree is not None:
            self._apply_tree(draft.parts[PART_TREE], seed_tree)
        for k, section in (seed_sections or {}).items():
            self._apply_section(draft.parts[k], section)
        missing = [k for k in SECTION_KEYS if draft.parts[k].status == "pending"]
        if seed_tree is None:
            if busy:
                self._mark_busy(draft, PART_TREE)
            else:
                self._spawn(draft, self._run_all(draft, llm))
        elif busy:
            for k in missing:
                self._mark_busy(draft, k)
        elif missing:
            self._spawn(draft, self._run_sections(draft, missing, llm))
        return draft.draft_id

    def create_condense(
        self, owner: str, req: TaxonomyCondenseIn, llm: Any, *, capacity: int | None = None, busy: bool = False,
    ) -> str:
        draft = self._new(owner, KIND_CONDENSE, req.intake, [PART_DESCRIPTION], capacity)
        draft.condense = req
        if busy:
            self._mark_busy(draft, PART_DESCRIPTION)
        else:
            self._spawn(draft, self._run_condense(draft, llm))
        return draft.draft_id

    def get(self, draft_id: str, owner: str) -> TaxonomyDraftOut | None:
        d = self._lookup(draft_id, owner)
        if d is None:
            return None
        return TaxonomyDraftOut(
            draft_id=d.draft_id,
            status=_overall(d.parts),
            parts={
                k: TaxonomyDraftPartOut(
                    status=p.status, error=p.error, tree=p.tree, section=p.section, description=p.description,
                )
                for k, p in d.parts.items()
            },
        )

    def cancel(self, draft_id: str, owner: str) -> bool:
        d = self._lookup(draft_id, owner)
        if d is None:
            return False
        self._cancel_draft(d)
        return True

    def retry_part(
        self, draft_id: str, owner: str, part: str, llm: Any, *, capacity: int | None = None, busy: bool = False,
    ) -> RetryResult:
        """Re-run one part: a failed, cancelled, timed-out or busy section, the
        tree (which also re-runs every unfinished section), or a condense
        draft's description."""
        d = self._lookup(draft_id, owner)
        if d is None:
            return "not_found"
        if part not in d.parts:
            return "bad_part"
        p = d.parts[part]
        if p.status in _LIVE:
            return "in_progress"
        if part == PART_TREE and any(d.parts[k].status in _LIVE for k in SECTION_KEYS):
            return "in_progress"
        if part in SECTION_KEYS and d.parts[PART_TREE].tree is None:
            return "needs_tree"
        if p.status not in _RETRYABLE:
            return "not_retryable"
        self._apply_capacity(capacity)
        self._supersede(owner, d.kind, keep=d.draft_id)
        d.refusal = None
        d.attempt_started = self._access.now()
        p.gen += 1
        p.status, p.error = "pending", None
        if part == PART_TREE:
            for k in SECTION_KEYS:
                sp = d.parts[k]
                if sp.status != "done":
                    sp.gen += 1
                    sp.status, sp.error = "pending", None
        if busy:
            self._mark_busy(d, part)
        elif part == PART_TREE:
            self._spawn(d, self._run_all(d, llm))
        elif part == PART_DESCRIPTION:
            self._spawn(d, self._run_condense(d, llm))
        else:
            self._spawn(d, self._run_sections(d, [part], llm))
        return "ok"

    async def wait(self, draft_id: str) -> None:
        """Until the draft's tasks have finished (tests). Waits only on tasks
        that are not done, so it always yields and ends once all are done."""
        d = self._drafts.get(draft_id)
        while d is not None:
            pending = [t for t in d.tasks if not t.done()]
            if not pending:
                return
            await asyncio.wait(pending)

    # ---- calls -----------------------------------------------------------
    def _call_ended(self, d: _Draft, fut: Future, model_service: str, started: datetime) -> None:
        """On the loop, after a call's thread ended: record a refusal (before
        anything waiting on this draft wakes), then wake those waiters."""
        d.calls.discard(fut)
        if not fut.cancelled():
            exc = fut.exception()
            if isinstance(exc, _REFUSALS):
                if d.attempt_started is None or started >= d.attempt_started:
                    d.refusal = str(exc)
                if model_service:
                    status = "denied" if isinstance(exc, TaxonomyLLMDenied) else "not_found"
                    self._access.record(model_service, ProbeResult(status, str(exc)), not_before=started)
        if d.call_ended is not None:
            d.call_ended.set()

    async def _start_call(
        self, d: _Draft, p: _Part, gen: int, llm: Any, fn: Callable[..., Any], *args: Any,
    ) -> asyncio.Future | None:
        """Take a slot for one call of ``d`` and submit ``fn(*args)``. With no
        free slot it waits while the draft has calls in flight, and raises
        ``NoFreeSlot`` once nothing of the draft is. Returns None when the part
        was superseded or the draft was refused meanwhile (the part is
        updated)."""
        loop = asyncio.get_running_loop()
        name = getattr(llm, "model_service", None)
        name = name if isinstance(name, str) else ""
        while True:
            if p.gen != gen:
                return None
            if d.refusal is not None:
                _set(p, gen, "failed", d.refusal)
                return None
            started = self._access.now()  # before the call can possibly end
            try:
                fut = self._slots.submit(fn, *args, executor=self._executor)
            except NoFreeSlot:
                if not d.calls:
                    raise
                if d.call_ended is None:
                    d.call_ended = asyncio.Event()
                d.call_ended.clear()
                await d.call_ended.wait()
                continue
            d.calls.add(fut)
            result = asyncio.wrap_future(fut)

            def _ended(f: Future, d: _Draft = d, started: datetime = started) -> None:
                try:
                    loop.call_soon_threadsafe(self._call_ended, d, f, name, started)
                except RuntimeError:  # the loop is closed (shutdown)
                    d.calls.discard(f)

            fut.add_done_callback(_ended)
            return result

    # ---- runners ---------------------------------------------------------
    async def _settle(
        self, d: _Draft, key: str, gen: int, work: Awaitable[Any], apply: Callable[[_Part, Any], None],
    ) -> None:
        """Await one part's work under its ceiling and record the outcome."""
        p = d.parts[key]
        try:
            result = await asyncio.wait_for(work, self._ceiling)
        except asyncio.TimeoutError:
            _set(p, gen, "timed_out", TIMED_OUT_ERROR)
            return
        except (NoFreeSlot, TaxonomyLLMBusy):
            _set(p, gen, "busy", BUSY_ERROR)
            return
        except TaxonomyLLMError as e:
            _set(p, gen, "failed", str(e))
            return
        except asyncio.CancelledError:
            raise
        except Exception:  # never let one part crash the draft
            log.exception("taxonomy draft part %s failed", key)
            _set(p, gen, "failed", UNEXPECTED_ERROR)
            return
        if p.gen == gen:
            apply(p, result)

    @staticmethod
    def _apply_tree(p: _Part, tree: TaxonomyTree) -> None:
        p.tree, p.status = tree, "done"

    @staticmethod
    def _apply_section(p: _Part, section: TaxonomySection) -> None:
        p.section, p.status = section, "done"

    async def _run_part(self, d: _Draft, key: str, llm: Any) -> None:
        """The tree or one section: one ``complete_json`` call."""
        p = d.parts[key]
        if p.status != "pending":
            return  # cancelled/superseded before it started
        gen = p.gen
        try:
            if key == PART_TREE:
                system, user = build_tree_prompt(d.intake)
                model: type = TaxonomyTree
            else:
                tree = d.parts[PART_TREE].tree
                if tree is None:  # sections start only once the tree is drafted
                    raise RuntimeError(f"section '{key}' started without a drafted tree")
                system, user = build_section_prompt(key, d.intake, tree)
                model = TaxonomySection
            work = await self._start_call(d, p, gen, llm, llm.complete_json, system, user, model)
        except NoFreeSlot:
            _set(p, gen, "busy", BUSY_ERROR)
            return
        except asyncio.CancelledError:
            raise
        except Exception:
            log.exception("taxonomy draft part %s could not start", key)
            _set(p, gen, "failed", UNEXPECTED_ERROR)
            return
        if work is None:
            return
        p.status = "running"
        await self._settle(d, key, gen, work, self._apply_tree if key == PART_TREE else self._apply_section)

    async def _run_all(self, d: _Draft, llm: Any) -> None:
        tree = d.parts[PART_TREE]
        gen = tree.gen
        await self._run_part(d, PART_TREE, llm)
        if tree.gen != gen:
            return  # superseded by cancel/retry
        if tree.tree is None:
            busy = tree.status == "busy"
            for k in SECTION_KEYS:
                sp = d.parts[k]
                if sp.status == "pending":
                    sp.status = "busy" if busy else "failed"
                    sp.error = WAITING_FOR_TREE if busy else (d.refusal or TREE_FAILED_ERROR)
            return
        await self._run_sections(d, [k for k in SECTION_KEYS if d.parts[k].status == "pending"], llm)

    async def _run_sections(self, d: _Draft, keys: list[str], llm: Any) -> None:
        loop = asyncio.get_running_loop()
        tasks = [loop.create_task(self._run_part(d, k, llm)) for k in keys]
        try:
            await asyncio.gather(*tasks)
        finally:
            for t in tasks:
                t.cancel()

    async def _condense_text(
        self, d: _Draft, p: _Part, gen: int, llm: Any, req: TaxonomyCondenseIn, first: asyncio.Future,
    ) -> str:
        """The description, from the already-submitted first call; when it is
        over the limit, one tighter call. A failing second call keeps the first
        text rather than losing it."""
        text = await first
        if len(text) <= DESCRIPTION_LIMIT:
            return text
        system, user = build_condense_prompt(req.intake, req.tree, req.sections, limit=1600)
        try:
            work = await self._start_call(d, p, gen, llm, llm.complete_text, system, user)
            if work is None:
                return text
            return await work
        except (NoFreeSlot, TaxonomyLLMError):
            return text

    @staticmethod
    def _apply_description(p: _Part, text: str) -> None:
        p.description, p.status = text, "done"
        if len(text) > DESCRIPTION_LIMIT:
            p.error = f"description is {len(text):,} characters - over the {DESCRIPTION_LIMIT:,} limit; trim it before creating"

    async def _run_condense(self, d: _Draft, llm: Any) -> None:
        """Like ``_run_part``: wait for a slot as ``pending``, turn ``running``
        once the first call is submitted, and only then start the ceiling."""
        p = d.parts[PART_DESCRIPTION]
        if p.status != "pending":
            return
        gen = p.gen
        try:
            req = d.condense
            if req is None:  # only condense drafts run this
                raise RuntimeError("description drafted without a condense request")
            system, user = build_condense_prompt(req.intake, req.tree, req.sections, limit=1900)
            first = await self._start_call(d, p, gen, llm, llm.complete_text, system, user)
        except NoFreeSlot:
            _set(p, gen, "busy", BUSY_ERROR)
            return
        except asyncio.CancelledError:
            raise
        except Exception:
            log.exception("taxonomy condense could not start")
            _set(p, gen, "failed", UNEXPECTED_ERROR)
            return
        if first is None:
            return
        p.status = "running"
        await self._settle(
            d, PART_DESCRIPTION, gen, self._condense_text(d, p, gen, llm, req, first), self._apply_description,
        )

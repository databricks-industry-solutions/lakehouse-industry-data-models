import asyncio
import threading
import time
from concurrent.futures import ThreadPoolExecutor

import pytest

from vibe_modeling.backend.taxonomy.access import ModelServiceAccess
from vibe_modeling.backend.taxonomy.drafts import (
    BUSY_ERROR,
    PART_CEILING_SECONDS,
    WAITING_FOR_TREE,
    DraftStore,
)
from vibe_modeling.backend.taxonomy.example import load_ridgeline_example
from vibe_modeling.backend.taxonomy.llm import (
    TaxonomyLLMBusy,
    TaxonomyLLMDenied,
    TaxonomyLLMError,
    TaxonomyLLMNotFound,
)
from vibe_modeling.backend.taxonomy.models import (
    SECTION_HEADINGS,
    SECTION_KEYS,
    TaxonomyCondenseIn,
    TaxonomyIntake,
    TaxonomySection,
    TaxonomyTree,
)
from vibe_modeling.backend.taxonomy.slots import LLMSlots

INTAKE = TaxonomyIntake(company_name="Acme", industry="Utility")
EX = load_ridgeline_example()
SERVICE = "main.ai.drafter"


_EXECUTORS: list[ThreadPoolExecutor] = []


@pytest.fixture(autouse=True)
def _shutdown_executors():
    yield
    while _EXECUTORS:
        _EXECUTORS.pop().shutdown(wait=True, cancel_futures=True)


def _last_status(access: ModelServiceAccess) -> str | None:
    check = access.last_check(SERVICE)
    return check.status if check is not None else None


def _got(store, draft_id, owner):
    """``store.get`` for a draft the test knows exists."""
    out = store.get(draft_id, owner)
    assert out is not None, f"draft {draft_id} not found for {owner}"
    return out


def _store(**kw):
    """A store on its own slots, executor and access cache, so blocked threads
    from one test never hold another test's slots or workers. A small default
    ceiling keeps a stuck part from hanging a test."""
    executor = ThreadPoolExecutor(max_workers=16, thread_name_prefix="test-taxonomy")
    _EXECUTORS.append(executor)
    kw.setdefault("slots", LLMSlots())
    kw.setdefault("access", ModelServiceAccess())
    kw.setdefault("executor", executor)
    kw.setdefault("ceiling_seconds", 10)
    return DraftStore(**kw)


class FakeLLM:
    """Scripted: fail_parts -> raise; block -> wait on an Event; texts -> condense replies in order."""

    def __init__(self, fail_parts=(), block=None, texts=("A short summary.",)):
        self.fail_parts = set(fail_parts)
        self.block = block
        self.texts = list(texts)
        self.calls = []

    def complete_json(self, system, user, model):
        part = "tree" if model is TaxonomyTree else next(k for k in SECTION_KEYS if self._heading(k) in system)
        self.calls.append(part)
        if self.block is not None:
            self.block.wait(5)
        if part in self.fail_parts:
            raise TaxonomyLLMError(f"{part} failed")
        return EX.tree if model is TaxonomyTree else EX.sections[part]

    def complete_text(self, system, user):
        self.calls.append("description")
        return self.texts.pop(0)

    @staticmethod
    def _heading(key):
        from vibe_modeling.backend.taxonomy.models import SECTION_HEADINGS
        return f"'{SECTION_HEADINGS[key]}'"


@pytest.mark.asyncio
async def test_happy_path_tree_then_sections():
    store, llm = _store(), FakeLLM()
    did = store.create("a@x.com", INTAKE, llm)
    await store.wait(did)
    out = _got(store, did, "a@x.com")
    assert out.status == "done"
    tree = out.parts["tree"].tree
    assert tree is not None and tree.domains[0].name == "Customer & Premise"
    assert all(out.parts[k].status == "done" for k in SECTION_KEYS)
    assert llm.calls[0] == "tree" and set(llm.calls[1:]) == set(SECTION_KEYS)


@pytest.mark.asyncio
async def test_tree_failure_blocks_sections():
    store = _store()
    did = store.create("a", INTAKE, FakeLLM(fail_parts={"tree"}))
    await store.wait(did)
    out = _got(store, did, "a")
    assert out.parts["tree"].status == "failed"
    assert all(out.parts[k].status == "failed" and "domain" in (out.parts[k].error or "") for k in SECTION_KEYS)
    assert out.status == "failed"


@pytest.mark.asyncio
async def test_one_section_fails_others_done_then_retry():
    store = _store()
    did = store.create("a", INTAKE, FakeLLM(fail_parts={"terminology"}))
    await store.wait(did)
    out = _got(store, did, "a")
    assert out.parts["terminology"].status == "failed"
    assert out.parts["company"].status == "done"
    assert store.retry_part(did, "a", "terminology", FakeLLM()) == "ok"
    await store.wait(did)
    assert _got(store, did, "a").parts["terminology"].status == "done"
    assert _got(store, did, "a").status == "done"


@pytest.mark.asyncio
async def test_retry_validations():
    store = _store()
    did = store.create("a", INTAKE, FakeLLM(fail_parts={"tree"}))
    await store.wait(did)
    assert store.retry_part(did, "a", "nope", FakeLLM()) == "bad_part"
    assert store.retry_part(did, "a", "company", FakeLLM()) == "needs_tree"
    assert store.retry_part("missing", "a", "tree", FakeLLM()) == "not_found"


@pytest.mark.asyncio
async def test_owner_isolation():
    store = _store()
    did = store.create("a", INTAKE, FakeLLM())
    await store.wait(did)
    assert store.get(did, "b") is None
    assert store.cancel(did, "b") is False
    assert store.retry_part(did, "b", "tree", FakeLLM()) == "not_found"


@pytest.mark.asyncio
async def test_cancel_marks_unfinished_parts_cancelled():
    gate = threading.Event()
    store = _store()
    did = store.create("a", INTAKE, FakeLLM(block=gate))
    await asyncio.sleep(0.05)
    assert store.cancel(did, "a") is True
    gate.set()
    await store.wait(did)
    out = _got(store, did, "a")
    assert out.status == "cancelled"
    assert all(p.status == "cancelled" for p in out.parts.values())


@pytest.mark.asyncio
async def test_ceiling_times_out_unfinished_parts():
    gate = threading.Event()
    store = _store(ceiling_seconds=0.1)
    did = store.create("a", INTAKE, FakeLLM(block=gate))
    await store.wait(did)
    gate.set()
    out = _got(store, did, "a")
    assert out.status == "timed_out"
    assert out.parts["tree"].status == "timed_out"


@pytest.mark.asyncio
async def test_ttl_purges_old_drafts():
    now = [0.0]
    store = _store(ttl_seconds=10, clock=lambda: now[0])
    did = store.create("a", INTAKE, FakeLLM())
    await store.wait(did)
    now[0] = 11
    store.create("a", INTAKE, FakeLLM())  # create() purges expired drafts
    assert store.get(did, "a") is None


@pytest.mark.asyncio
async def test_condense_within_limit():
    store = _store()
    req = TaxonomyCondenseIn(intake=INTAKE, tree=EX.tree, sections=EX.sections)
    did = store.create_condense("a", req, FakeLLM(texts=["Ridgeline is a utility."]))
    await store.wait(did)
    out = _got(store, did, "a")
    assert list(out.parts) == ["description"]
    assert out.parts["description"].description == "Ridgeline is a utility."


@pytest.mark.asyncio
async def test_condense_retries_once_when_over_limit_then_returns_anyway():
    store = _store()
    req = TaxonomyCondenseIn(intake=INTAKE, tree=EX.tree, sections=EX.sections)
    llm = FakeLLM(texts=["x" * 2500, "y" * 2100])
    did = store.create_condense("a", req, llm)
    await store.wait(did)
    part = _got(store, did, "a").parts["description"]
    assert llm.calls == ["description", "description"]
    assert part.status == "done" and len(part.description or "") == 2100
    assert "over" in (part.error or "")


@pytest.mark.asyncio
async def test_condense_unexpected_error_marks_part_failed():
    """A non-TaxonomyLLMError must not leave the description part spinning forever."""

    class Boom(FakeLLM):
        def complete_text(self, system, user):
            raise RuntimeError("boom")

    store = _store()
    req = TaxonomyCondenseIn(intake=INTAKE, tree=EX.tree, sections=EX.sections)
    did = store.create_condense("a", req, Boom())
    await store.wait(did)
    out = _got(store, did, "a")
    assert out.parts["description"].status == "failed"
    assert "unexpected" in (out.parts["description"].error or "")
    assert out.status == "failed"


class PartGate(FakeLLM):
    """Blocks on `gate` for every part except those in `free`."""

    def __init__(self, gate, free=(), **kw):
        super().__init__(**kw)
        self.gate, self.free = gate, set(free)

    def complete_json(self, system, user, model):
        part = "tree" if model is TaxonomyTree else next(k for k in SECTION_KEYS if self._heading(k) in system)
        self.calls.append(part)
        if part not in self.free:
            self.gate.wait(5)
        if part in self.fail_parts:
            raise TaxonomyLLMError(f"{part} failed")
        return EX.tree if model is TaxonomyTree else EX.sections[part]


async def _wait_tree_done(store, did, owner="a", timeout=5.0):
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        if _got(store, did, owner).parts["tree"].status == "done":
            return
        await asyncio.sleep(0.02)
    raise AssertionError("tree never reached done")


@pytest.mark.asyncio
async def test_original_timeout_does_not_touch_retried_part():
    g1, g2 = threading.Event(), threading.Event()
    store = _store(ceiling_seconds=1.0)
    did = store.create("a", INTAKE, PartGate(g1, free={"tree", "terminology"}, fail_parts={"terminology"}))
    await asyncio.sleep(0.5)
    assert _got(store, did, "a").parts["terminology"].status == "failed"
    assert store.retry_part(did, "a", "terminology", FakeLLM(block=g2)) == "ok"
    seen = set()
    # original ceiling ends ~1.0s after create, the retry's own ~1.5s: ~0.5s margin each side
    deadline = time.monotonic() + 0.9
    observed = False
    while time.monotonic() < deadline:
        parts = _got(store, did, "a").parts
        seen.add(parts["terminology"].status)
        if parts["company"].status == "timed_out":  # original run's timeout observed
            observed = True
            break
        await asyncio.sleep(0.05)
    assert observed, "original run never timed out its own parts"
    assert "timed_out" not in seen
    assert _got(store, did, "a").parts["terminology"].status == "running"
    g2.set()
    g1.set()
    await store.wait(did)
    assert _got(store, did, "a").parts["terminology"].status == "done"


@pytest.mark.asyncio
async def test_retry_done_part_not_retryable_no_llm_call():
    store = _store()
    did = store.create("a", INTAKE, FakeLLM())
    await store.wait(did)
    llm = FakeLLM()
    assert store.retry_part(did, "a", "company", llm) == "not_retryable"
    assert store.retry_part(did, "a", "tree", llm) == "not_retryable"
    assert llm.calls == []


@pytest.mark.asyncio
async def test_retry_tree_busy_while_section_running():
    gate = threading.Event()
    store = _store()
    did = store.create("a", INTAKE, PartGate(gate, free={"tree"}))
    await _wait_tree_done(store, did)
    llm = FakeLLM()
    assert store.retry_part(did, "a", "tree", llm) == "in_progress"
    assert llm.calls == []
    gate.set()
    await store.wait(did)
    assert _got(store, did, "a").status == "done"


@pytest.mark.asyncio
async def test_cancel_then_retry_one_part_only_reruns_that_part():
    gate = threading.Event()
    store = _store()
    did = store.create("a", INTAKE, PartGate(gate, free={"tree"}))
    await _wait_tree_done(store, did)
    assert store.cancel(did, "a") is True
    llm = FakeLLM()
    assert store.retry_part(did, "a", "company", llm) == "ok"
    # The cancelled sections' threads still hold every slot; the retried part
    # waits for them (its draft has calls in flight) instead of going busy.
    await asyncio.sleep(0.1)
    assert _got(store, did, "a").parts["company"].status == "pending"
    assert llm.calls == []
    gate.set()
    await store.wait(did)
    out = _got(store, did, "a")
    assert llm.calls == ["company"]
    assert out.parts["company"].status == "done"
    assert out.parts["tree"].status == "done"
    assert all(out.parts[k].status == "cancelled" for k in SECTION_KEYS if k != "company")


@pytest.mark.asyncio
async def test_condense_second_call_raises_keeps_first_text():
    class SecondFails(FakeLLM):
        def complete_text(self, system, user):
            self.calls.append("description")
            if len(self.calls) == 1:
                return "x" * 2500
            raise TaxonomyLLMError("second failed")

    store = _store()
    req = TaxonomyCondenseIn(intake=INTAKE, tree=EX.tree, sections=EX.sections)
    did = store.create_condense("a", req, SecondFails())
    await store.wait(did)
    part = _got(store, did, "a").parts["description"]
    assert part.status == "done" and len(part.description or "") == 2500
    assert "over" in (part.error or "")


# --- concurrency and busy (design §4.4) ------------------------------------------


def _key(system, model):
    return "tree" if model is TaxonomyTree else next(k for k in SECTION_KEYS if f"'{SECTION_HEADINGS[k]}'" in system)


class CountingLLM:
    """Tracks the peak number of calls running at once. ``raise_for`` maps a
    part to the exception its call raises; ``block`` parts wait on ``gate``."""

    def __init__(self, delay=0.05, raise_for=None, block=(), gate=None):
        self.delay = delay
        self.raise_for = dict(raise_for or {})
        self.block, self.gate = set(block), gate
        self.model_service = SERVICE
        self.live = self.peak = 0
        self.calls = []
        self._lock = threading.Lock()

    def complete_json(self, system, user, model):
        part = _key(system, model)
        with self._lock:
            self.calls.append(part)
            self.live += 1
            self.peak = max(self.peak, self.live)
        try:
            if part in self.block:
                assert self.gate is not None, "block needs a gate"
                self.gate.wait(5)
            else:
                time.sleep(self.delay)
            exc = self.raise_for.get(part)
            if exc is not None:
                raise exc
            return EX.tree if model is TaxonomyTree else EX.sections[part]
        finally:
            with self._lock:
                self.live -= 1

    def complete_text(self, system, user):
        self.calls.append("description")
        exc = self.raise_for.get("description")
        if exc is not None:
            self.raise_for.pop("description")
            raise exc
        return "A short summary."


class LimitedSlots(LLMSlots):
    """Grants ``grants`` slots in total, then reports none free."""

    def __init__(self, grants, capacity=6):
        super().__init__(capacity)
        self.grants = grants

    def try_acquire(self):
        if self.grants <= 0:
            return False
        if super().try_acquire():
            self.grants -= 1
            return True
        return False


async def _until(pred, timeout=5.0):
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        if pred():
            return
        await asyncio.sleep(0.01)
    raise AssertionError("condition never met")


def test_part_ceiling_covers_two_calls():
    assert PART_CEILING_SECONDS == 210


@pytest.mark.asyncio
async def test_live_calls_never_exceed_capacity_and_sections_wait_for_siblings():
    slots = LLMSlots()
    store, llm = _store(slots=slots), CountingLLM()
    did = store.create("a", INTAKE, llm, capacity=2)
    assert slots.capacity == 2
    await store.wait(did)
    out = _got(store, did, "a")
    assert out.status == "done"
    assert llm.peak <= 2
    assert all(out.parts[k].status == "done" for k in SECTION_KEYS)


@pytest.mark.asyncio
async def test_no_free_slot_for_the_tree_makes_the_draft_busy():
    store, llm = _store(slots=LimitedSlots(0)), CountingLLM()
    did = store.create("a", INTAKE, llm)
    await store.wait(did)
    out = _got(store, did, "a")
    assert out.status == "busy"
    assert (out.parts["tree"].status, out.parts["tree"].error) == ("busy", BUSY_ERROR)
    assert all((out.parts[k].status, out.parts[k].error) == ("busy", WAITING_FOR_TREE) for k in SECTION_KEYS)
    assert llm.calls == []


@pytest.mark.asyncio
async def test_sections_go_busy_only_when_nothing_in_the_draft_runs():
    gate = threading.Event()
    slots = LimitedSlots(3)  # tree + two sections
    store = _store(slots=slots)
    llm = CountingLLM(block={"company", "channels"}, gate=gate)
    did = store.create("a", INTAKE, llm)
    await _until(lambda: _got(store, did, "a").parts["company"].status == "running")
    parts = _got(store, did, "a").parts
    # Two siblings run; the rest wait for them instead of going busy.
    assert parts["channels"].status == "running"
    assert all(parts[k].status == "pending" for k in SECTION_KEYS if k not in ("company", "channels"))
    gate.set()
    await store.wait(did)
    out = _got(store, did, "a")
    assert out.parts["company"].status == "done" and out.parts["channels"].status == "done"
    assert all(
        (out.parts[k].status, out.parts[k].error) == ("busy", BUSY_ERROR)
        for k in SECTION_KEYS if k not in ("company", "channels")
    )
    assert out.status == "busy"


@pytest.mark.asyncio
async def test_rate_limited_call_makes_only_that_part_busy_and_retry_finishes_it():
    store = _store()
    llm = CountingLLM(raise_for={"terminology": TaxonomyLLMBusy("busy")})
    did = store.create("a", INTAKE, llm)
    await store.wait(did)
    out = _got(store, did, "a")
    assert (out.parts["terminology"].status, out.parts["terminology"].error) == ("busy", BUSY_ERROR)
    assert out.parts["company"].status == "done"
    assert out.status == "busy"
    assert store.retry_part(did, "a", "terminology", CountingLLM()) == "ok"
    await store.wait(did)
    assert _got(store, did, "a").status == "done"


@pytest.mark.asyncio
async def test_retry_of_a_busy_tree_reruns_the_waiting_sections():
    slots = LimitedSlots(0)
    store = _store(slots=slots)
    did = store.create("a", INTAKE, CountingLLM())
    await store.wait(did)
    slots.grants = 99
    llm = CountingLLM()
    assert store.retry_part(did, "a", "tree", llm) == "ok"
    await store.wait(did)
    out = _got(store, did, "a")
    assert out.status == "done"
    assert llm.calls[0] == "tree" and set(llm.calls[1:]) == set(SECTION_KEYS)


@pytest.mark.asyncio
async def test_busy_flag_reports_busy_without_calling_the_model():
    store, llm = _store(), CountingLLM()
    did = store.create("a", INTAKE, llm, busy=True)
    out = _got(store, did, "a")
    assert out.status == "busy" and out.parts["tree"].status == "busy"
    assert all(out.parts[k].error == WAITING_FOR_TREE for k in SECTION_KEYS)
    assert store.retry_part(did, "a", "tree", llm, busy=True) == "ok"
    assert _got(store, did, "a").status == "busy"
    assert llm.calls == []
    assert store._active == {}


@pytest.mark.asyncio
async def test_section_ceiling_times_out_only_that_section():
    gate = threading.Event()
    store = _store(ceiling_seconds=0.3)
    did = store.create("a", INTAKE, CountingLLM(block={"regulatory"}, gate=gate))
    await store.wait(did)
    out = _got(store, did, "a")
    gate.set()
    assert out.parts["regulatory"].status == "timed_out"
    assert all(out.parts[k].status == "done" for k in SECTION_KEYS if k != "regulatory")
    assert out.status == "timed_out"


@pytest.mark.asyncio
async def test_description_retry_reruns_condense():
    store = _store()
    req = TaxonomyCondenseIn(intake=INTAKE, tree=EX.tree, sections=EX.sections)
    did = store.create_condense("a", req, CountingLLM(raise_for={"description": TaxonomyLLMBusy("busy")}))
    await store.wait(did)
    assert _got(store, did, "a").parts["description"].status == "busy"
    assert store.retry_part(did, "a", "description", CountingLLM()) == "ok"
    await store.wait(did)
    part = _got(store, did, "a").parts["description"]
    assert (part.status, part.description) == ("done", "A short summary.")


@pytest.mark.asyncio
async def test_condense_with_no_free_slot_is_busy():
    store = _store(slots=LimitedSlots(0))
    req = TaxonomyCondenseIn(intake=INTAKE, tree=EX.tree, sections=EX.sections)
    did = store.create_condense("a", req, CountingLLM())
    await store.wait(did)
    assert _got(store, did, "a").parts["description"].status == "busy"


@pytest.mark.asyncio
@pytest.mark.parametrize(
    "exc,status",
    [(TaxonomyLLMDenied("SP may not use it"), "denied"), (TaxonomyLLMNotFound("not found"), "not_found")],
)
async def test_draft_time_refusal_feeds_the_access_cache_and_fails_the_rest(exc, status):
    from vibe_modeling.backend.taxonomy.llm import ProbeResult

    access = ModelServiceAccess()
    access.record(SERVICE, ProbeResult("ok", "fine"))
    slots = LLMSlots(1)  # one section at a time, so the rest are still queued
    store = _store(slots=slots, access=access)
    did = store.create("a", INTAKE, CountingLLM(raise_for={"company": exc}))
    await store.wait(did)
    out = _got(store, did, "a")
    assert out.parts["company"].status == "failed" and out.parts["company"].error == str(exc)
    # Queued siblings fail with the same message instead of going busy or calling again.
    assert all(
        (out.parts[k].status, out.parts[k].error) == ("failed", str(exc)) for k in SECTION_KEYS if k != "company"
    )
    assert _last_status(access) == status
    assert not access.is_cached(SERVICE)


@pytest.mark.asyncio
async def test_refused_tree_fails_and_is_recorded():
    access = ModelServiceAccess()
    store = _store(access=access)
    did = store.create("a", INTAKE, CountingLLM(raise_for={"tree": TaxonomyLLMDenied("no access")}))
    await store.wait(did)
    out = _got(store, did, "a")
    assert out.parts["tree"].status == "failed"
    assert all((out.parts[k].status, out.parts[k].error) == ("failed", "no access") for k in SECTION_KEYS)
    assert _last_status(access) == "denied"


@pytest.mark.asyncio
async def test_one_active_draft_per_user_per_kind():
    gate = threading.Event()
    store = _store()
    blocked = CountingLLM(block={"tree"}, gate=gate)
    a1 = store.create("a", INTAKE, blocked)
    req = TaxonomyCondenseIn(intake=INTAKE, tree=EX.tree, sections=EX.sections)

    class SlowText(CountingLLM):
        def complete_text(self, system, user):
            gate.wait(5)
            return "text"

    c1 = store.create_condense("a", req, SlowText())
    b1 = store.create("b", INTAKE, CountingLLM(block={"tree"}, gate=gate))
    await asyncio.sleep(0.05)
    a2 = store.create("a", INTAKE, CountingLLM(block={"tree"}, gate=gate))
    # Synchronous: a1 is cancelled and out of the active set before create returns.
    assert _got(store, a1, "a").status == "cancelled"
    assert a1 not in store._active[("a", "create")]
    assert _got(store, c1, "a").status == "running"  # other kind untouched
    assert _got(store, b1, "b").status == "running"  # other user untouched
    c2 = store.create_condense("a", req, SlowText())
    assert _got(store, c1, "a").status == "cancelled"
    assert _got(store, a2, "a").status == "running"
    gate.set()
    for did in (a1, a2, b1, c1, c2):
        await store.wait(did)
    assert store._active == {}


@pytest.mark.asyncio
async def test_two_busy_tabs_do_not_cancel_each_other_until_one_retries():
    slots = LimitedSlots(0)
    store = _store(slots=slots)
    tab1 = store.create("a", INTAKE, CountingLLM())
    await store.wait(tab1)
    tab2 = store.create("a", INTAKE, CountingLLM())
    await store.wait(tab2)
    # Both busy: neither has a live task, so neither cancelled the other.
    assert _got(store, tab1, "a").status == "busy" and _got(store, tab2, "a").status == "busy"
    gate = threading.Event()
    slots.grants = 99
    assert store.retry_part(tab1, "a", "tree", CountingLLM(block={"tree"}, gate=gate)) == "ok"
    await asyncio.sleep(0.05)
    assert store.retry_part(tab2, "a", "tree", CountingLLM()) == "ok"
    # The most recent attempt wins: tab1 was running, so tab2's retry cancelled it.
    assert _got(store, tab1, "a").status == "cancelled"
    gate.set()
    await store.wait(tab1)
    await store.wait(tab2)
    assert _got(store, tab2, "a").status == "done"


@pytest.mark.asyncio
async def test_cancel_frees_bookkeeping_at_once_and_the_slot_when_the_thread_ends():
    gate = threading.Event()
    slots = LLMSlots()
    store = _store(slots=slots)
    llm = CountingLLM(block={"tree"}, gate=gate)
    did = store.create("a", INTAKE, llm)
    await _until(lambda: llm.live == 1)  # the thread is running, not just queued
    assert store.cancel(did, "a") is True
    assert store._active == {}
    assert slots.in_use == 1  # the thread is still calling the gateway
    gate.set()
    await _until(lambda: slots.in_use == 0)
    assert _got(store, did, "a").status == "cancelled"


@pytest.mark.asyncio
async def test_purge_drops_expired_drafts_from_the_active_set():
    gate = threading.Event()
    now = [0.0]
    slots = LLMSlots()
    store = _store(slots=slots, ttl_seconds=10, clock=lambda: now[0])
    old = store.create("a", INTAKE, CountingLLM(block={"tree"}, gate=gate))
    await _until(lambda: slots.in_use == 1)
    now[0] = 11
    store.create("b", INTAKE, CountingLLM())
    assert store.get(old, "a") is None
    assert ("a", "create") not in store._active
    gate.set()
    await _until(lambda: slots.in_use == 0)


@pytest.mark.asyncio
async def test_capacity_is_applied_on_create_and_retry():
    slots = LLMSlots()
    store = _store(slots=slots)
    did = store.create("a", INTAKE, CountingLLM(raise_for={"company": TaxonomyLLMError("x")}), capacity=3)
    assert slots.capacity == 3
    await store.wait(did)
    store.retry_part(did, "a", "company", CountingLLM(), capacity=5)
    assert slots.capacity == 5
    await store.wait(did)


# --- wave-3 fixes ------------------------------------------------------------------


def test_wait_never_spins_on_a_finished_task_still_in_the_set():
    """Python 3.12's gather completes eagerly when every child is done, so a
    loop of gathers over finished tasks never yields and the discard callbacks
    never run. ``wait`` must return once every task is done. Runs on its own
    loop in a thread so a regression fails here instead of hanging the run."""
    outcome: dict[str, object] = {}

    async def body():
        store = _store()
        did = store.create("a", INTAKE, CountingLLM(), busy=True)
        done = asyncio.get_running_loop().create_task(asyncio.sleep(0))
        await done
        store._drafts[did].tasks.add(done)  # done, and no callback will ever remove it
        await store.wait(did)
        outcome["active"] = store._active

    th = threading.Thread(target=lambda: asyncio.run(body()), daemon=True)
    th.start()
    th.join(5)
    assert not th.is_alive(), "DraftStore.wait spun on a finished task"
    assert outcome["active"] == {}


@pytest.mark.asyncio
async def test_active_ignores_finished_tasks_whose_callbacks_have_not_run():
    store = _store()
    did = store.create("a", INTAKE, CountingLLM(), busy=True)
    done = asyncio.get_running_loop().create_task(asyncio.sleep(0))
    await done
    store._drafts[did].tasks.add(done)
    other = store.create("a", INTAKE, CountingLLM(), busy=True)
    # The first draft has no live task, so the second create did not cancel it.
    assert _got(store, did, "a").status == "busy"
    assert _got(store, other, "a").status == "busy"


@pytest.mark.asyncio
async def test_single_section_retry_waits_for_running_siblings_instead_of_going_busy():
    gate = threading.Event()
    slots = LLMSlots(5)  # the five blocked siblings fill every slot
    store = _store(slots=slots)
    llm = CountingLLM(block={"company", "channels", "processes", "systems_of_record", "regulatory"}, gate=gate,
                      raise_for={"terminology": TaxonomyLLMError("boom")})
    did = store.create("a", INTAKE, llm)
    await _until(lambda: _got(store, did, "a").parts["terminology"].status == "failed")
    await _until(lambda: slots.in_use == 5)
    assert store.retry_part(did, "a", "terminology", CountingLLM()) == "ok"
    await asyncio.sleep(0.1)
    assert _got(store, did, "a").parts["terminology"].status == "pending"  # waiting, not busy
    gate.set()
    await asyncio.wait_for(store.wait(did), 5)
    assert _got(store, did, "a").status == "done"


@pytest.mark.asyncio
async def test_draft_denial_never_overwrites_a_newer_test_result():
    from vibe_modeling.backend.taxonomy.llm import ProbeResult

    gate = threading.Event()
    access = ModelServiceAccess()
    store = _store(access=access)
    llm = CountingLLM(block={"tree"}, gate=gate, raise_for={"tree": TaxonomyLLMDenied("revoked")})
    did = store.create("a", INTAKE, llm)
    await _until(lambda: llm.live == 1)  # the call has started
    access.record(SERVICE, ProbeResult("ok", "Test passed"))  # a Test that finished after it started
    gate.set()
    await asyncio.wait_for(store.wait(did), 5)
    assert _got(store, did, "a").parts["tree"].status == "failed"
    assert _last_status(access) == "ok"
    assert access.is_cached(SERVICE)


@pytest.mark.asyncio
async def test_a_failing_section_prompt_fails_only_that_part(monkeypatch):
    from vibe_modeling.backend.taxonomy import drafts as drafts_mod

    real = drafts_mod.build_section_prompt

    def broken(key, intake, tree):
        if key == "processes":
            raise KeyError("no template")
        return real(key, intake, tree)

    monkeypatch.setattr(drafts_mod, "build_section_prompt", broken)
    store = _store()
    did = store.create("a", INTAKE, CountingLLM())
    await asyncio.wait_for(store.wait(did), 5)
    out = _got(store, did, "a")
    assert (out.parts["processes"].status, out.parts["processes"].error) == ("failed", drafts_mod.UNEXPECTED_ERROR)
    assert all(out.parts[k].status == "done" for k in SECTION_KEYS if k != "processes")


@pytest.mark.asyncio
async def test_a_failing_tree_prompt_fails_the_tree(monkeypatch):
    from vibe_modeling.backend.taxonomy import drafts as drafts_mod

    def broken(intake):
        raise ValueError("bad intake")

    monkeypatch.setattr(drafts_mod, "build_tree_prompt", broken)
    store = _store()
    llm = CountingLLM()
    did = store.create("a", INTAKE, llm)
    await asyncio.wait_for(store.wait(did), 5)
    out = _got(store, did, "a")
    assert out.parts["tree"].status == "failed" and llm.calls == []
    assert all(out.parts[k].status == "failed" for k in SECTION_KEYS)


@pytest.mark.asyncio
async def test_condense_waits_for_a_slot_as_pending_outside_the_ceiling():
    gate = threading.Event()

    class Slow(CountingLLM):
        def complete_text(self, system, user):
            self.calls.append("description")
            gate.wait(5)
            return "old text"

    # One slot; ceiling far shorter than the wait for it.
    store = _store(slots=LLMSlots(1), ceiling_seconds=0.3)
    req = TaxonomyCondenseIn(intake=INTAKE, tree=EX.tree, sections=EX.sections)
    did = store.create_condense("a", req, Slow())
    await _until(lambda: _got(store, did, "a").parts["description"].status == "running")
    store.cancel(did, "a")
    llm = CountingLLM()
    assert store.retry_part(did, "a", "description", llm) == "ok"
    await asyncio.sleep(0.5)  # longer than the ceiling: still waiting, not timed out
    assert _got(store, did, "a").parts["description"].status == "pending"
    assert llm.calls == []
    gate.set()
    await asyncio.wait_for(store.wait(did), 5)
    part = _got(store, did, "a").parts["description"]
    assert (part.status, part.description) == ("done", "A short summary.")


@pytest.mark.asyncio
async def test_a_refusal_from_a_call_abandoned_before_a_retry_is_stale():
    gate = threading.Event()
    store = _store(slots=LLMSlots(1))
    old = CountingLLM(block={"tree"}, gate=gate, raise_for={"tree": TaxonomyLLMDenied("revoked earlier")})
    did = store.create("a", INTAKE, old)
    await _until(lambda: old.live == 1)
    store.cancel(did, "a")
    new = CountingLLM()
    assert store.retry_part(did, "a", "tree", new) == "ok"  # waits for the abandoned call's slot
    gate.set()  # the abandoned call now comes back denied
    await asyncio.wait_for(store.wait(did), 5)
    out = _got(store, did, "a")
    assert out.status == "done", {k: (p.status, p.error) for k, p in out.parts.items()}
    assert new.calls[0] == "tree"


# ---- seeded drafts (Draft again and resume reuse the user's parts) --------


@pytest.mark.asyncio
async def test_seeded_tree_makes_no_tree_call_and_drafts_every_section():
    store, llm = _store(), FakeLLM()
    did = store.create("a", INTAKE, llm, seed_tree=EX.tree)
    await store.wait(did)
    out = _got(store, did, "a")
    assert out.status == "done"
    assert out.parts["tree"].tree == EX.tree
    assert "tree" not in llm.calls
    assert sorted(llm.calls) == sorted(SECTION_KEYS)


@pytest.mark.asyncio
async def test_seeded_sections_are_done_and_not_drafted():
    store, llm = _store(), FakeLLM()
    seeded = {"company": EX.sections["company"], "regulatory": EX.sections["regulatory"]}
    did = store.create("a", INTAKE, llm, seed_tree=EX.tree, seed_sections=seeded)
    await store.wait(did)
    out = _got(store, did, "a")
    assert out.status == "done"
    assert out.parts["company"].section == EX.sections["company"]
    assert sorted(llm.calls) == sorted(set(SECTION_KEYS) - set(seeded))


@pytest.mark.asyncio
async def test_fully_seeded_draft_runs_nothing():
    store, llm = _store(), FakeLLM()
    did = store.create("a", INTAKE, llm, seed_tree=EX.tree, seed_sections=dict(EX.sections))
    assert store._active == {}
    out = _got(store, did, "a")
    assert out.status == "done" and llm.calls == []


@pytest.mark.asyncio
async def test_seeded_sections_without_a_tree_draft_the_tree_and_the_rest():
    store, llm = _store(), FakeLLM()
    did = store.create("a", INTAKE, llm, seed_sections={"company": EX.sections["company"]})
    await store.wait(did)
    out = _got(store, did, "a")
    assert out.status == "done"
    assert llm.calls[0] == "tree" and "company" not in llm.calls
    assert sorted(llm.calls[1:]) == sorted(set(SECTION_KEYS) - {"company"})


@pytest.mark.asyncio
async def test_seeded_tree_while_busy_marks_only_the_missing_sections_busy():
    store, llm = _store(), FakeLLM()
    did = store.create("a", INTAKE, llm, busy=True, seed_tree=EX.tree, seed_sections={"company": EX.sections["company"]})
    out = _got(store, did, "a")
    assert out.parts["tree"].status == "done"
    assert out.parts["company"].status == "done"
    missing = set(SECTION_KEYS) - {"company"}
    assert all(out.parts[k].status == "busy" and out.parts[k].error == BUSY_ERROR for k in missing)
    assert llm.calls == []
    assert store.retry_part(did, "a", "terminology", llm) == "ok"
    await store.wait(did)
    assert _got(store, did, "a").parts["terminology"].status == "done"
    assert llm.calls == ["terminology"]


# ---- TTL from last activity -------------------------------------------------


@pytest.mark.asyncio
async def test_ttl_counts_from_last_poll_not_from_creation():
    now = [0.0]
    store = _store(ttl_seconds=10, clock=lambda: now[0])
    did = store.create("a", INTAKE, FakeLLM())
    await store.wait(did)
    for t in (8.0, 16.0, 24.0):  # each poll is within the TTL of the previous one
        now[0] = t
        assert store.get(did, "a") is not None
    now[0] = 35.0
    assert store.get(did, "a") is None


@pytest.mark.asyncio
async def test_retry_counts_as_activity():
    now = [0.0]
    store = _store(ttl_seconds=10, clock=lambda: now[0])
    did = store.create("a", INTAKE, FakeLLM(fail_parts={"terminology"}))
    await store.wait(did)
    now[0] = 9.0
    assert store.retry_part(did, "a", "terminology", FakeLLM()) == "ok"
    await store.wait(did)
    now[0] = 18.0
    assert store.get(did, "a") is not None


@pytest.mark.asyncio
async def test_another_owners_poll_does_not_keep_a_draft_alive():
    now = [0.0]
    store = _store(ttl_seconds=10, clock=lambda: now[0])
    did = store.create("a", INTAKE, FakeLLM())
    await store.wait(did)
    now[0] = 8.0
    assert store.get(did, "b") is None
    now[0] = 12.0
    assert store.get(did, "a") is None

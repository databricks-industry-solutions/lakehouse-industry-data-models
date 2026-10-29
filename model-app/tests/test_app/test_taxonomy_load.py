"""Load test for the Domain Taxonomy Builder draft runner (design §4.4, §7).

Drives the real HTTP routes through an in-process ASGI client, so drafting
runs on the app's event loop next to ordinary requests. The stub model sleeps
0.5 s per call and every 5th call is rate-limited (busy); capacity is 4 on a
dedicated executor. Every test body runs under a hard ``asyncio.wait_for``
and the stub never waits unbounded.
"""

from __future__ import annotations

import asyncio
import statistics
import threading
import time
from concurrent.futures import ThreadPoolExecutor

import httpx
import pytest
from sqlalchemy.pool import StaticPool
from sqlmodel import Session, SQLModel, create_engine

from _test_app import make_test_app
from vibe_modeling.backend.core._config import AppConfig
from vibe_modeling.backend.core._defaults import _ConfigDependency
from vibe_modeling.backend.core._roles import UserRole, resolve_user_role
from vibe_modeling.backend.core.lakebase import _LakebaseDependency
from vibe_modeling.backend.db_models import AgentConfig
from vibe_modeling.backend.routes import businesses as business_routes
from vibe_modeling.backend.routes import config as config_routes
from vibe_modeling.backend.routes import taxonomy as taxonomy_routes
from vibe_modeling.backend.taxonomy.access import MODEL_SERVICE_ACCESS
from vibe_modeling.backend.taxonomy.drafts import BUSY_ERROR, DraftStore
from vibe_modeling.backend.taxonomy.example import load_ridgeline_example
from vibe_modeling.backend.taxonomy.llm import ProbeResult, TaxonomyLLMBusy, TaxonomyLLMDenied
from vibe_modeling.backend.taxonomy.models import SECTION_HEADINGS, SECTION_KEYS, TaxonomyTree
from vibe_modeling.backend.taxonomy.slots import LLMSlots

SERVICE = "main.ai.drafter"
CAPACITY = 4
CALL_SECONDS = 0.5
BUSY_EVERY = 5
OWNERS = [f"user{i:02d}@x.com" for i in range(20)]
INTAKE = {"company_name": "Acme", "industry": "Utility"}
TERMINAL = {"done", "busy", "cancelled", "timed_out", "failed"}
EX = load_ridgeline_example()


def _last_status() -> str | None:
    check = MODEL_SERVICE_ACCESS.last_check(SERVICE)
    return check.status if check is not None else None


def _part(system: str, model) -> str:
    return "tree" if model is TaxonomyTree else next(k for k in SECTION_KEYS if f"'{SECTION_HEADINGS[k]}'" in system)


class StubLLM:
    """Sleeps per call, rate-limits every ``busy_every``-th call, tracks the
    peak number of calls running at once. ``slow`` maps a part to a longer
    sleep; ``deny`` maps a part to the call number (1-based, for that part)
    that is refused; ``on_call_start`` runs as a call starts."""

    model_service = SERVICE

    def __init__(self, *, busy_every=BUSY_EVERY, slow=None, deny=None, on_call_start=None):
        self.busy_every = busy_every
        self.slow = dict(slow or {})
        self.deny = dict(deny or {})
        self.on_call_start = on_call_start
        self._lock = threading.Lock()
        self.live = self.peak = self.calls = 0
        self.per_part: dict[str, int] = {}

    def probe(self):
        return ProbeResult("ok", "answered")

    def _begin(self, part: str) -> tuple[int, int]:
        with self._lock:
            self.calls += 1
            self.live += 1
            self.peak = max(self.peak, self.live)
            self.per_part[part] = self.per_part.get(part, 0) + 1
            return self.calls, self.per_part[part]

    def _end(self):
        with self._lock:
            self.live -= 1

    def complete_json(self, system, user, model):
        part = _part(system, model)
        n, n_part = self._begin(part)
        try:
            if self.on_call_start is not None:
                self.on_call_start(part)
            time.sleep(self.slow.get(part, CALL_SECONDS))
            if self.deny.get(part) == n_part:
                raise TaxonomyLLMDenied(f"The app's service principal may not use model service '{SERVICE}'.")
            if self.busy_every and n % self.busy_every == 0:
                raise TaxonomyLLMBusy(BUSY_ERROR)
            return EX.tree if model is TaxonomyTree else EX.sections[part]
        finally:
            self._end()

    def complete_text(self, system, user):
        return "A short summary."


class Harness:
    def __init__(self, llm: StubLLM, *, ceiling: float = 10.0, capacity: int = CAPACITY):
        self.llm = llm
        self.executor = ThreadPoolExecutor(max_workers=16, thread_name_prefix="load-taxonomy")
        self.slots = LLMSlots()
        self.now = [0.0]
        self.store = DraftStore(
            slots=self.slots, executor=self.executor, access=MODEL_SERVICE_ACCESS,
            ceiling_seconds=ceiling, clock=lambda: self.now[0],
        )
        engine = create_engine("sqlite://", connect_args={"check_same_thread": False}, poolclass=StaticPool)
        SQLModel.metadata.create_all(engine)
        with Session(engine) as s:
            s.add(AgentConfig(taxonomy_model_service=SERVICE, taxonomy_llm_max_concurrency=capacity))
            s.commit()

        app = make_test_app(taxonomy_routes.router, config_routes.router, business_routes.router)

        @app.get("/api/load-probe/to-thread")
        async def to_thread_probe():
            # Ordinary work on asyncio's default pool: it must never queue behind LLM calls.
            return {"ok": await asyncio.to_thread(lambda: True)}

        # One shared in-memory SQLite connection: requests take turns on it
        # (a plain Lock, since the dependency may open and close on different threads).
        db_lock = threading.Lock()

        def _session():
            with db_lock:
                with Session(engine) as s:
                    yield s

        config = AppConfig(app_name="test", taxonomy_builder_enabled=True)
        app.dependency_overrides[_LakebaseDependency.__call__] = _session
        app.dependency_overrides[_ConfigDependency.__call__] = lambda: config
        app.dependency_overrides[resolve_user_role] = lambda: UserRole.APP_ADMIN
        app.dependency_overrides[taxonomy_routes.get_taxonomy_llm] = lambda: llm
        app.dependency_overrides[taxonomy_routes.get_draft_store] = lambda: self.store
        self.client = httpx.AsyncClient(transport=httpx.ASGITransport(app=app), base_url="http://test")

    async def close(self):
        await self.client.aclose()
        self.executor.shutdown(wait=True, cancel_futures=True)

    async def create(self, owner: str) -> str:
        r = await self.client.post("/api/taxonomy/drafts", json=INTAKE, headers={"X-Forwarded-Email": owner})
        assert r.status_code == 200, r.text
        return r.json()["draft_id"]

    async def get(self, owner: str, draft_id: str) -> dict:
        r = await self.client.get(f"/api/taxonomy/drafts/{draft_id}", headers={"X-Forwarded-Email": owner})
        assert r.status_code == 200, r.text
        return r.json()

    async def quiesce(self, drafts: dict[str, str], timeout: float = 30) -> dict[str, dict]:
        deadline = time.monotonic() + timeout
        while True:
            out = {o: await self.get(o, d) for o, d in drafts.items()}
            if all(v["status"] != "running" for v in out.values()):
                return out
            assert time.monotonic() < deadline, "drafts never settled"
            await asyncio.sleep(0.1)

    async def latency_p95(self, path: str, n: int = 20) -> float:
        samples = []
        for _ in range(n):
            t0 = time.perf_counter()
            r = await self.client.get(path)
            samples.append(time.perf_counter() - t0)
            assert r.status_code == 200, (path, r.text)
            await asyncio.sleep(0.01)
        return statistics.quantiles(samples, n=20)[-1]

    async def drained(self, timeout: float = 10) -> None:
        deadline = time.monotonic() + timeout
        while self.slots.in_use or self.llm.live:
            assert time.monotonic() < deadline, f"slots never drained: {self.slots.in_use} in use"
            await asyncio.sleep(0.05)


@pytest.fixture(autouse=True)
def _fresh_access():
    MODEL_SERVICE_ACCESS.clear()
    MODEL_SERVICE_ACCESS.record(SERVICE, ProbeResult("ok", "answered"))  # skip the pre-draft probe
    yield
    MODEL_SERVICE_ACCESS.clear()


def _run(coro, timeout: float):
    async def bounded():
        await asyncio.wait_for(coro, timeout)
    return bounded()


PATHS = ["/api/businesses", "/api/config/taxonomy", "/api/load-probe/to-thread"]


@pytest.mark.asyncio
async def test_twenty_owners_capped_responsive_and_converge():
    async def body():
        h = Harness(StubLLM())
        try:
            idle = {p: await h.latency_p95(p) for p in PATHS}
            ids = await asyncio.gather(*(h.create(o) for o in OWNERS))
            drafts = dict(zip(OWNERS, ids))
            assert h.slots.capacity == CAPACITY
            loaded = {p: await h.latency_p95(p) for p in PATHS}
            for p in PATHS:
                assert loaded[p] <= 2 * idle[p] + 0.05, (p, idle[p], loaded[p])

            out = await h.quiesce(drafts)
            for v in out.values():
                assert all(part["status"] in TERMINAL - {"failed"} for part in v["parts"].values()), v
                for part in v["parts"].values():
                    if part["status"] == "busy":
                        assert part["error"] in (BUSY_ERROR, "waiting for the domains")

            # Busy parts retried once slots free reach done.
            for _ in range(30):
                pending = {o: v for o, v in out.items() if v["status"] != "done"}
                if not pending:
                    break
                for owner, v in pending.items():
                    parts = v["parts"]
                    retry = ["tree"] if parts["tree"]["status"] == "busy" else [
                        k for k, p in parts.items() if p["status"] == "busy"
                    ]
                    for part in retry:
                        r = await h.client.post(
                            f"/api/taxonomy/drafts/{drafts[owner]}/parts/{part}/retry",
                            headers={"X-Forwarded-Email": owner},
                        )
                        assert r.status_code == 200, r.text
                out = await h.quiesce(drafts)
            assert all(v["status"] == "done" for v in out.values()), {o: v["status"] for o, v in out.items()}
            assert h.llm.peak <= CAPACITY
            await h.drained()
            assert h.store._active == {}
        finally:
            await h.close()

    await _run(body(), 60)


@pytest.mark.asyncio
async def test_churn_leaves_at_most_one_active_draft_per_owner_and_kind():
    async def body():
        h = Harness(StubLLM(busy_every=0))
        try:
            owners = OWNERS[:4]
            for _ in range(3):
                await asyncio.gather(*(h.create(o) for o in owners))
                await asyncio.sleep(0.2)  # mid-flight
                for (owner, kind), ids in h.store._active.items():
                    assert len(ids) <= 1, (owner, kind, ids)
            assert h.llm.peak <= CAPACITY
            for d in list(h.store._drafts.values()):
                h.store.cancel(d.draft_id, d.owner)
            await h.drained()
        finally:
            await h.close()

    await _run(body(), 30)


@pytest.mark.asyncio
async def test_cancel_all_then_purge_frees_every_slot_and_task():
    async def body():
        h = Harness(StubLLM(busy_every=0))
        try:
            ids = await asyncio.gather(*(h.create(o) for o in OWNERS[:8]))
            await asyncio.sleep(0.2)
            for owner, did in zip(OWNERS[:8], ids):
                r = await h.client.post(f"/api/taxonomy/drafts/{did}/cancel", headers={"X-Forwarded-Email": owner})
                assert r.status_code == 200 and r.json()["status"] == "cancelled"
            assert h.store._active == {}
            h.now[0] += h.store._ttl + 1
            h.store._purge()
            assert h.store._drafts == {}
            await h.drained()
            assert h.slots.in_use == 0
        finally:
            await h.close()

    await _run(body(), 30)


@pytest.mark.asyncio
async def test_a_call_over_the_ceiling_times_out_and_keeps_its_slot_until_the_thread_ends():
    async def body():
        h = Harness(StubLLM(busy_every=0, slow={"tree": 1.5}), ceiling=0.3)
        try:
            did = await h.create(OWNERS[0])
            out = await h.quiesce({OWNERS[0]: did}, timeout=5)
            assert out[OWNERS[0]]["parts"]["tree"]["status"] == "timed_out"
            assert h.slots.in_use == 1  # the thread is still calling the gateway
            await h.drained()
            assert h.slots.in_use == 0
        finally:
            await h.close()

    await _run(body(), 30)


@pytest.mark.asyncio
async def test_a_denial_mid_load_fails_the_queued_siblings_and_hides_the_service():
    async def body():
        h = Harness(StubLLM(busy_every=0, deny={"company": 1}), capacity=1)
        try:
            did = await h.create(OWNERS[0])
            out = (await h.quiesce({OWNERS[0]: did}))[OWNERS[0]]
            company = out["parts"]["company"]
            assert company["status"] == "failed" and "may not use" in company["error"]
            # Siblings queued behind the one slot fail with the same refusal instead of calling.
            queued = [k for k in SECTION_KEYS if k != "company" and out["parts"][k]["error"] == company["error"]]
            assert queued, out["parts"]
            assert h.llm.per_part.get("regulatory", 0) == 0
            assert _last_status() == "denied"
            r = await h.client.get("/api/config/taxonomy")
            assert r.json()["ready"] is False
            await h.drained()
        finally:
            await h.close()

    await _run(body(), 30)


@pytest.mark.asyncio
async def test_a_denial_never_overwrites_a_test_that_passed_after_the_call_started():
    async def body():
        started = threading.Event()

        def mark(part):
            if part == "tree":
                started.set()

        h = Harness(StubLLM(busy_every=0, deny={"tree": 1}, on_call_start=mark, slow={"tree": 0.5}))
        try:
            did = await h.create(OWNERS[0])
            assert await asyncio.to_thread(started.wait, 5)
            MODEL_SERVICE_ACCESS.record(SERVICE, ProbeResult("ok", "Test passed"))
            out = (await h.quiesce({OWNERS[0]: did}))[OWNERS[0]]
            assert out["parts"]["tree"]["status"] == "failed"
            assert _last_status() == "ok"
            await h.drained()
        finally:
            await h.close()

    await _run(body(), 30)


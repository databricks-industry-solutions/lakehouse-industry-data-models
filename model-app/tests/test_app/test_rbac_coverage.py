"""RBAC coverage — every mutating route must declare an auth marker.

Walks every route the app mounts (``backend/_routers.ROUTERS``, the list
``app.py`` passes to ``create_app``) and asserts each has either a role
guard (``Dependencies.AdminOnly`` / ``Dependencies.BusinessAdminOnly`` /
``Dependencies.ModelerOnly``, or a declared guard ``ModelerDeclared`` /
``ViewerDeclared``), or appears on a curated allow-list of intentionally
public / read-only routes (``/api/version``, ``/api/current-user``, etc.).

The intent is to make adding a *new* mutating route without an explicit
auth declaration a hard test failure — so the next handler that lands
in ``routes/`` cannot silently be open to anonymous traffic.

Public-by-design routes are listed in ``_PUBLIC_ROUTES``. Read-only
GETs that intentionally don't gate — list endpoints, explorer endpoints
that the UI shows to every signed-in user — are listed in
``_READ_ONLY_ROUTES``. Both lists are minimal: anything not on them
must declare a role guard.

Declared guards (``core/_roles.declared_role``) count as guards but do not
refuse anyone until ``VIBE_INPUT_ROLE_GUARDS_ENFORCED`` is True. Only the
routes in ``_DECLARED_UNENFORCED_ROUTES`` may use them, and they are
counted separately from the enforced ones.
"""

from __future__ import annotations

import os
import sys

sys.path.insert(
    0, os.path.join(os.path.dirname(__file__), "..", "..", "src", "app", "src")
)

import pytest
from fastapi import FastAPI
from fastapi.routing import APIRoute
from sqlmodel import Session

import vibe_modeling.backend.core._roles as _roles_mod
from vibe_modeling.backend._routers import ROUTERS, iter_route_methods
from vibe_modeling.backend.core._roles import (
    UserRole,
    require_admin,
    require_business_admin,
    require_modeler,
)
from vibe_modeling.backend.db_models import Business, ModelVersion
from vibe_modeling.backend.routes import vibe_inputs as _routes_vibe_inputs


# Routes deliberately exposed to anonymous traffic — typically health,
# version, and identity introspection endpoints the UI calls before the
# user is signed in / before role data is available.
_PUBLIC_ROUTES: set[tuple[str, str]] = {
    ("GET", "/api/version"),
    ("GET", "/api/current-user"),
    ("GET", "/api/user/role"),
    # Soft-drain status — UI banner + the deploy poller poll this before
    # the user is authenticated. No mutation, no PII (just a bool +
    # an integer count).
    ("GET", "/api/health"),
}


# Read-only routes that are visible to every signed-in user (any role).
# These are explorer / list / read endpoints — they don't mutate state
# and the UI shows them to viewers and modelers alike. Adding to this
# list is a deliberate signal that a route is read-only: if a future PR
# converts a GET to a mutator, the test should fail unless the role guard
# is added at the same time.
_READ_ONLY_ROUTES: set[tuple[str, str]] = {
    # Platform
    # The preference routes are per-user: they write only the caller's own rows and require an identity.
    ("GET", "/api/user/preferences"),
    ("PUT", "/api/user/preferences/{key}"),  # per-user write to own row
    ("DELETE", "/api/user/preferences/{key}"),  # per-user delete of own row
    ("GET", "/api/catalogs"),
    # Read-only UC grant reads as the app SP for the catalog picker; bounded, never grants.
    ("GET", "/api/catalogs/capabilities"),
    # Client telemetry beacon — any signed-in user; logs a warning only
    # (no DB write, no mutation, no domain access). Used by the kickstart
    # dialog to record a transient gateway 502 in the app logs.
    ("POST", "/api/client-telemetry/gateway-error"),
    # Businesses + contexts (reads)
    ("GET", "/api/businesses"),
    ("GET", "/api/businesses/{business_id}"),
    ("GET", "/api/businesses/{business_id}/contexts"),
    # Import preview (no DB write — reads model.json from Volumes and
    # returns an analysis report. The corresponding /execute endpoint
    # IS gated.)
    ("POST", "/api/businesses/{business_id}/import/analyze"),
    # Root import preview (no DB write, no target business; reads model.json
    # and lists the companion artifacts). Its /execute sibling is BusinessAdminOnly.
    ("POST", "/api/import/analyze"),
    ("GET", "/api/import/preview"),
    # Unity Catalog browse (reads as the app SP; no mutation) for the import
    # Volume picker and the new-run catalog schema warning.
    ("GET", "/api/uc/volumes/browse"),
    ("GET", "/api/uc/catalogs/{catalog_name}/schema-warning"),
    # Explorer (reads)
    ("GET", "/api/businesses/{business_id}/explorer/versions"),
    ("GET", "/api/businesses/{business_id}/versions/{version_int}/{scope}/model"),
    # Model-wide element search - read-only name lookup over domains/products/
    # attributes, version-scoped; no mutation.
    ("GET", "/api/businesses/{business_id}/versions/{version_int}/{scope}/search"),
    (
        "GET",
        "/api/businesses/{business_id}/versions/{version_int}/{scope}/domains/{domain_name}",
    ),
    (
        "GET",
        "/api/businesses/{business_id}/versions/{version_int}/{scope}/domains/{domain_name}/products/{product_name}",
    ),
    (
        "GET",
        "/api/businesses/{business_id}/versions/{version_int}/{scope}/relationships",
    ),
    # Review state (reads — effective per-product states + progress rollup).
    # The mutating marks live under routes/vibe_inputs.py (ModelerDeclared).
    (
        "GET",
        "/api/businesses/{business_id}/versions/{version_int}/{scope}/reviews",
    ),
    (
        "GET",
        "/api/businesses/{business_id}/versions/{version_int}/{scope}/review-progress",
    ),
    (
        "GET",
        "/api/businesses/{business_id}/versions/{version_int}/{scope}/review-progress/by-domain",
    ),
    # next_vibes "expected work" metrics (T13) — read-only aggregates over the
    # open agent-input backlog; no mutation. Model + per-domain scope.
    (
        "GET",
        "/api/businesses/{business_id}/versions/{version_int}/{scope}/next-vibe-metrics",
    ),
    (
        "GET",
        "/api/businesses/{business_id}/versions/{version_int}/{scope}/domains/{domain_name}/next-vibe-metrics",
    ),
    # Model evolution metrics (T16) — read-only projection of the version's
    # Volume model.json _vibe_session_metadata; no mutation. Model scope only.
    (
        "GET",
        "/api/businesses/{business_id}/versions/{version_int}/{scope}/evolution-metrics",
    ),
    # Statistics report Excel export (T15) — read-only render of the same
    # metrics readers into an .xlsx download; no mutation.
    (
        "GET",
        "/api/businesses/{business_id}/versions/{version_int}/{scope}/statistics-report.xlsx",
    ),
    # Diagram (reads — per (version, scope) variant only registered today)
    ("GET", "/api/businesses/{business_id}/versions/{version_int}/{scope}/diagram"),
    # Versions (per-business listing only — version detail is currently
    # served via /versions/{version_int}/model under the explorer surface)
    ("GET", "/api/businesses/{business_id}/versions"),
    # Model-version-scoped reads (joined view across runs / artifacts)
    ("GET", "/api/model-versions/{version_id}/runs"),
    ("GET", "/api/model-versions/{model_version_id}/next-vibes"),
    ("GET", "/api/businesses/{business_id}/model-versions/{model_version_id}/artifacts"),
    ("GET", "/api/businesses/{business_id}/model-versions/{model_version_id}/artifacts/download"),
    # The run form's pre-fill for a vibe of the version: reads its model.json
    # conventions and the producing run's widgets. No mutation.
    ("GET", "/api/businesses/{business_id}/model-versions/{model_version_id}/run-defaults"),
    # Model export (inverse of import) — read-only reconstruction of a
    # version's model.json / publishable bundle. No mutation.
    ("GET", "/api/businesses/{business_id}/model-versions/{model_version_id}/export"),
    ("GET", "/api/businesses/{business_id}/model-versions/{model_version_id}/export/bundle"),
    ("GET", "/api/businesses/{business_id}/model-versions/{model_version_id}/artifacts/{artifact_id}/content"),
    ("GET", "/api/businesses/{business_id}/model-versions/{model_version_id}/artifacts/{artifact_id}/download"),
    # Drift probe — read-only catalog-vs-Lakebase comparison (#69).
    # The reconcile endpoint that follows IS gated (BusinessAdminOnly).
    ("GET", "/api/model-versions/{model_version_id}/installation-status"),
    # Unfinished _metamodel cleanups of deleted versions (read; Retry is BusinessAdminOnly).
    ("GET", "/api/businesses/{business_id}/metamodel-cleanups"),
    # Runs (read endpoints — see router.py). Every run-scoped endpoint
    # nests under /api/businesses/{business_id}/runs/... so the bid in
    # the URL acts as the per-tenant scope check.
    ("GET", "/api/businesses/{business_id}/runs/{run_id}"),
    ("GET", "/api/businesses/{business_id}/runs/{run_id}/lineage"),
    ("GET", "/api/businesses/{business_id}/runs/{run_id}/progress"),
    # Run report (per-feedback outcomes) - read-only, any role.
    ("GET", "/api/businesses/{business_id}/runs/{run_id}/report"),
    ("GET", "/api/businesses/{business_id}/versions/{version_id}/report"),
    # Run change list (diff + hint + decisions) - read-only, any role; the
    # decision and rejected-feedback writes are ModelerOnly.
    ("GET", "/api/businesses/{business_id}/runs/{run_id}/changes"),
    # Whether the run change review is on (an AppConfig flag) - every role
    # reads it to decide whether to show the review.
    ("GET", "/api/config/run-change-review"),
    # New-Run live form feedback — no DB write, just runs the validator
    # and returns warnings/blockers. The mutating sibling POST /runs is
    # role-gated separately.
    ("POST", "/api/businesses/{business_id}/runs/validate"),
    # Per-step orchestrator state — read-only projection of
    # ``RunOperation`` rows the run's owner already has access to view
    # via GET /runs/{run_id}.
    ("GET", "/api/businesses/{business_id}/runs/{run_id}/operations"),
    ("GET", "/api/businesses/{business_id}/runs"),
    ("GET", "/api/businesses/{business_id}/runs/{run_id}/artifacts"),
    ("GET", "/api/businesses/{business_id}/runs/{run_id}/artifacts/{artifact_id}/content"),
    ("GET", "/api/businesses/{business_id}/runs/{run_id}/artifacts/download"),
    ("GET", "/api/businesses/{business_id}/runs/{run_id}/artifacts/{artifact_id}/download"),
    # Industries (reads)
    ("GET", "/api/industries"),
    # Sectors (reads — list is open; create/update/delete are AdminOnly)
    ("GET", "/api/sectors"),
    # Config (reads — agent-config GET is open; mutations are AdminOnly)
    ("GET", "/api/config/agent"),
    # GitHub config (read is open; the PUT is AdminOnly)
    ("GET", "/api/config/github"),
    # Source read-auth config (0.7.1) — read is open (never returns secret
    # values); the PUT is BusinessAdminOnly.
    ("GET", "/api/config/source-auth"),
    # Headless assessment config (read is open; the PUT is AdminOnly)
    ("GET", "/api/assess/config"),
    # Readiness check — POST for the body, but read-only (UC lookups only).
    ("POST", "/api/assess/readiness"),
    # Saved bronze source map — read is open; the PUT and launch are ModelerOnly.
    ("GET", "/api/businesses/{business_id}/assess-source-map"),
    # Assessment list/get — open to any role; cancels are ModelerOnly.
    ("GET", "/api/businesses/{business_id}/assessments"),
    ("GET", "/api/assessments/{batch_id}"),
    # Assessment results + docs — open to any role; answering a decision is ModelerOnly.
    ("GET", "/api/assessment-domain-runs/{domain_run_id}/results"),
    ("GET", "/api/assessment-domain-runs/{domain_run_id}/docs"),
    ("GET", "/api/assessment-domain-runs/{domain_run_id}/docs/content"),
    # Install-skills is role-free by design: it writes only into the caller's
    # own /Workspace/Users/<email>/.assistant/skills folder, through OBO.
    ("POST", "/api/assessment-domain-runs/{domain_run_id}/handoff/install-skills"),
    # Hand-off prompts + skills check — open to any role; the POST (copy into the caller's home) is ModelerOnly.
    ("GET", "/api/assessment-domain-runs/{domain_run_id}/handoff"),
    # Source explorer (Wave 1, Track C) — read-only browse of an external
    # catalog (GitHub today). No mutation in this story; publish/write lands
    # in a later wave behind the UC connection.
    ("GET", "/api/sources/capabilities"),
    ("GET", "/api/sources/sectors"),
    ("GET", "/api/sources/sectors/{sector_id}/industries"),
    ("GET", "/api/sources/industries/{industry_id}/models"),
    ("GET", "/api/sources/industries/{industry_id}/models/{model_id}/preview"),
    # Industry-model lifecycle router (Wave 2). Foundational health probe is
    # public-by-design (no-auth liveness); later lifecycle endpoints add their own guards.
    ("GET", "/api/industry-models/_health"),
    ("GET", "/api/config/agent/supported-version"),
    ("GET", "/api/config/agent-compat"),
    ("GET", "/api/config/agent/ready"),
    ("GET", "/api/config/agent/check-notebook"),
    ("GET", "/api/config/deployment-catalog"),
    ("GET", "/api/config/metamodel-catalog"),
    ("GET", "/api/config/warehouses"),
    ("GET", "/api/config/warehouse"),
    # Deployment (reads only — uc-schema / compare / catalog-check)
    ("GET", "/api/businesses/{business_id}/versions/{version_id}/deployment/catalog-check"),
    ("GET", "/api/businesses/{business_id}/versions/{version_id}/deployment/uc-schema"),
    ("GET", "/api/businesses/{business_id}/versions/{version_id}/deployment/compare"),
    # Domain Taxonomy Builder — reads + pure compute only. GET draft is a
    # per-owner read of in-memory state; /compile is pure code (no LLM, no
    # write); /example returns the built-in Ridgeline example. The drafting
    # mutators (create / cancel / retry / condense) are BusinessAdminOnly —
    # the same bar as createBusiness, where the wizard ends.
    ("GET", "/api/taxonomy/drafts/{draft_id}"),
    ("POST", "/api/taxonomy/compile"),
    ("GET", "/api/taxonomy/example"),
    # Taxonomy settings read — the landing card and the wizard read ``ready``
    # for every role. The PUT, the Test call and the model-services picker
    # are AdminOnly (asserted below).
    ("GET", "/api/config/taxonomy"),
    # What an orphan-schema drop run dropped; a run read like the others.
    ("GET", "/api/businesses/{business_id}/runs/{run_id}/schema-drops"),
}


# The 21 vibe_inputs routes. They declare a role (``ModelerDeclared`` on
# writes, ``ViewerDeclared`` on reads) that is not enforced until
# ``_roles.VIBE_INPUT_ROLE_GUARDS_ENFORCED`` is True. No other route may use a
# declared guard.
_VI = "/api/businesses/{business_id}"
_DECLARED_VIEWER_ROUTES: set[tuple[str, str]] = {
    ("GET", f"{_VI}/inputs"),
    ("GET", f"{_VI}/inputs/{{input_id}}"),
    ("GET", f"{_VI}/inputs/{{input_id}}/links"),
    ("GET", f"{_VI}/links/review-queue"),
    # Read-only computation over the selected inputs; no write.
    ("POST", f"{_VI}/versions/{{version_id}}/inputs/compile"),
}
_DECLARED_MODELER_ROUTES: set[tuple[str, str]] = {
    ("POST", f"{_VI}/inputs"),
    ("PATCH", f"{_VI}/inputs/{{input_id}}"),
    ("DELETE", f"{_VI}/inputs/{{input_id}}"),
    ("POST", f"{_VI}/inputs/{{input_id}}/restore"),
    ("POST", f"{_VI}/inputs/{{input_id}}/consume"),
    ("POST", f"{_VI}/inputs/{{input_id}}/unconsume"),
    ("POST", f"{_VI}/inputs/selection"),
    ("POST", f"{_VI}/inputs/{{input_id}}/links"),
    ("POST", f"{_VI}/versions/{{version_id}}/inputs/carry-forward"),
    ("POST", f"{_VI}/links/{{link_id}}/review/accept"),
    ("POST", f"{_VI}/links/{{link_id}}/review/reanchor"),
    ("POST", f"{_VI}/links/{{link_id}}/review/dismiss"),
    ("POST", f"{_VI}/versions/{{version_int}}/{{scope}}/reviews/product/{{product_id}}"),
    ("DELETE", f"{_VI}/versions/{{version_int}}/{{scope}}/reviews/product/{{product_id}}"),
    ("POST", f"{_VI}/versions/{{version_int}}/{{scope}}/reviews/domain/{{domain_id}}"),
    ("POST", f"{_VI}/versions/{{version_int}}/{{scope}}/reviews/subdomain/{{subdomain_id}}"),
}
_DECLARED_UNENFORCED_ROUTES = _DECLARED_VIEWER_ROUTES | _DECLARED_MODELER_ROUTES


# Enforced role guard callables. A route that depends on one of these, or on
# a declared guard (see ``_declared_min_role``), transitively, is RBAC-gated.
_ROLE_GUARDS = {require_admin, require_business_admin, require_modeler}


def _build_app() -> FastAPI:
    app = FastAPI()
    for r in ROUTERS:
        app.include_router(r)
    return app


def _dependant_calls(route: APIRoute) -> list:
    """Every callable in the route's dependency tree (FastAPI exposes the
    nested dependants on ``dependencies``)."""
    calls: list = []
    seen: set[int] = set()
    stack = [route.dependant]
    while stack:
        d = stack.pop()
        if id(d) in seen:
            continue
        seen.add(id(d))
        calls.append(d.call)
        stack.extend(getattr(d, "dependencies", []) or [])
    return calls


def _declared_min_role(route: APIRoute) -> UserRole | None:
    """The role a route declares through a ``declared_role`` guard, else None."""
    for call in _dependant_calls(route):
        role = getattr(call, "declared_min_role", None)
        if role is not None:
            return role
    return None


def _route_has_enforced_guard(route: APIRoute) -> bool:
    return any(call in _ROLE_GUARDS for call in _dependant_calls(route))


def _route_has_role_guard(route: APIRoute) -> bool:
    """True when the route depends on an enforced or a declared role guard."""
    return _route_has_enforced_guard(route) or _declared_min_role(route) is not None


def _enumerate_routes(app: FastAPI) -> list[tuple[str, str, APIRoute]]:
    """Yield (method, path, route) for every concrete APIRoute on the app."""
    return iter_route_methods(app.routes)


# ---------------------------------------------------------------------------
# Coverage tests
# ---------------------------------------------------------------------------


@pytest.fixture(scope="module")
def all_routes() -> list[tuple[str, str, APIRoute]]:
    return _enumerate_routes(_build_app())


def test_at_least_one_route_present(all_routes):
    """Sanity — if route discovery breaks, every other test in this file
    becomes a vacuous pass. Fail loud on an empty list."""
    assert len(all_routes) >= 50, (
        f"Discovered only {len(all_routes)} routes — registration likely broken."
    )


def test_every_route_is_classified(all_routes):
    """Every (method, path) pair must be either:
      * RBAC-gated (declares one of the role guards), OR
      * on the public allow-list, OR
      * on the read-only allow-list.

    A new route that doesn't fit any of these is a coverage gap — the
    fix is to either add a guard to the handler or add the route to one
    of the allow-lists with a comment explaining why."""
    failures: list[str] = []
    for method, path, route in all_routes:
        key = (method, path)
        gated = _route_has_role_guard(route)
        public = key in _PUBLIC_ROUTES
        read_only = key in _READ_ONLY_ROUTES
        if not (gated or public or read_only):
            failures.append(f"  {method} {path}")
    assert not failures, (
        "The following routes have no auth marker and are not on the "
        "public / read-only allow-lists:\n" + "\n".join(failures) + "\n"
        "Either add `_role: Dependencies.{Admin,BusinessAdmin,Modeler}Only` "
        "to the handler, or append the route to _PUBLIC_ROUTES / "
        "_READ_ONLY_ROUTES in tests/test_app/test_rbac_coverage.py with "
        "a one-line justification."
    )


def test_allowlist_entries_are_real_routes(all_routes):
    """Any (method, path) on the allow-list that doesn't exist on the
    app is rotten — either the route was renamed or removed. Catching
    this prevents the allow-list from silently growing forever."""
    discovered = {(m, p) for m, p, _ in all_routes}
    for label, allowlist in (
        ("_PUBLIC_ROUTES", _PUBLIC_ROUTES),
        ("_READ_ONLY_ROUTES", _READ_ONLY_ROUTES),
    ):
        stale = allowlist - discovered
        assert not stale, (
            f"{label} contains entries that no longer exist on the app:\n"
            + "\n".join(f"  {m} {p}" for m, p in sorted(stale))
            + f"\nRemove them from {label} (in test_rbac_coverage.py)."
        )


def test_admin_only_routes_have_admin_guard(all_routes):
    """The endpoints that absolutely must be admin-only — seed-model and
    switch-to-bundled are the obvious ones — get an explicit
    cross-check so a refactor that swaps AdminOnly for ModelerOnly
    fails this test even though the broader coverage test still
    passes (any guard is better than none, but the wrong guard is
    a privilege escalation)."""
    must_be_admin: set[tuple[str, str]] = {
        ("POST", "/api/businesses/{business_id}/seed-model"),
        ("POST", "/api/admin/agent/switch-to-bundled"),
        ("PUT", "/api/config/agent"),
        ("PUT", "/api/assess/config"),
        (
            "POST",
            "/api/businesses/{business_id}/versions/import-from-volume",
        ),
        ("DELETE", "/api/businesses/{business_id}/runs/{run_id}"),
        ("PUT", "/api/config/taxonomy"),
        ("POST", "/api/config/taxonomy/test"),
        ("GET", "/api/config/taxonomy/model-services"),
        # Orphan schemas: listing scans a catalog, the drop deletes schemas.
        ("GET", "/api/businesses/{business_id}/orphan-schemas"),
        ("POST", "/api/businesses/{business_id}/orphan-schemas/drop"),
        # Rewrites an industry's model files and registry rows.
        ("POST", "/api/industries/{business_id}/scope-prefixes"),
    }
    by_key = {(m, p): r for m, p, r in all_routes}

    for method, path in must_be_admin:
        route = by_key.get((method, path))
        assert route is not None, (
            f"{method} {path} not found — the admin-only assertion list "
            f"is stale; update test_rbac_coverage.py."
        )
        found_admin = require_admin in _dependant_calls(route)
        assert found_admin, (
            f"{method} {path} must be guarded by Dependencies.AdminOnly "
            f"(require_admin); currently has no admin guard in its "
            f"dependency chain."
        )


def test_oob_routes_take_their_sibling_roles(all_routes):
    """Out-of-band routes: reads, "Check now" and the per-business import are
    ModelerOnly like ``executeImport``; creating businesses is
    BusinessAdminOnly like ``createBusinessAndExecuteImport``."""
    expected = {
        ("GET", "/api/oob/summary"): require_modeler,
        ("POST", "/api/oob/check"): require_modeler,
        ("POST", "/api/businesses/{business_id}/oob/import"): require_modeler,
        ("POST", "/api/oob/import-new-businesses"): require_business_admin,
    }
    by_key = {(m, p): r for m, p, r in all_routes}
    for key, guard in expected.items():
        assert key in by_key, f"{key} is not mounted"
        guards = [c for c in _dependant_calls(by_key[key]) if c in _ROLE_GUARDS]
        assert guards == [guard], f"{key}: {guards}"


def test_link_run_routes_are_business_admin(all_routes):
    """Linking an imported version to its run records a Run for the business:
    BusinessAdminOnly, preview included (it reads the Jobs API and the
    registry as the app)."""
    by_key = {(m, p): r for m, p, r in all_routes}
    for path in (
        "/api/businesses/{business_id}/versions/{version_id}/link-run/preview",
        "/api/businesses/{business_id}/versions/{version_id}/link-run",
    ):
        key = ("POST", path)
        assert key in by_key, f"{key} is not mounted"
        guards = [c for c in _dependant_calls(by_key[key]) if c in _ROLE_GUARDS]
        assert guards == [require_business_admin], f"{key}: {guards}"


def test_route_walker_reports_total_count(all_routes, capsys):
    """Reporting hook: emits the counts to stdout so the CI log captures
    the number of routes the walker covered. Useful for spotting silent
    regressions in discovery (e.g. a router fails to register and the count
    drops). Declared-but-unenforced routes are their own bucket."""
    total = len(all_routes)
    enforced = sum(1 for _, _, r in all_routes if _route_has_enforced_guard(r))
    declared = sum(1 for _, _, r in all_routes if _declared_min_role(r) is not None)
    public = sum(
        1 for m, p, _ in all_routes if (m, p) in _PUBLIC_ROUTES
    )
    read_only = sum(
        1 for m, p, _ in all_routes if (m, p) in _READ_ONLY_ROUTES
    )
    print(
        f"\nRBAC coverage: total={total} "
        f"role-gated={enforced} declared(enforced="
        f"{_roles_mod.VIBE_INPUT_ROLE_GUARDS_ENFORCED})={declared} "
        f"public={public} read-only={read_only}"
    )
    # Every route is in at least one bucket. (Read-only entries that also
    # have a guard are fine; the bucket-coverage test only asserts each
    # route fits >= 1 bucket.)
    assert enforced + declared + public + read_only >= total, (
        f"Bucket coverage shortfall: enforced={enforced} + declared={declared} "
        f"+ public={public} + read_only={read_only} < total={total}"
    )


def test_no_lifespan_dependency_adds_routers_outside_routers():
    """``create_app`` mounts ``LifespanDependency.get_routers()`` beside ``ROUTERS``;
    the walker only sees ``ROUTERS``. No dependency may override it, or its routes
    would escape the RBAC coverage check."""
    from vibe_modeling.backend.core._base import LifespanDependency

    def subclasses(cls):
        for sub in cls.__subclasses__():
            yield sub
            yield from subclasses(sub)

    overriding = [
        c.__qualname__
        for c in subclasses(LifespanDependency)
        if "get_routers" in vars(c)
    ]
    assert not overriding, (
        f"{overriding} override get_routers(); extend this test's walker to "
        f"cover the routers they add"
    )


def test_every_mounted_router_is_walked(all_routes):
    """The walker sees every router the app mounts, including the ones a
    hand-kept list used to miss (uc_browse, import_root, vibe_inputs)."""
    discovered = {p for _, p, _ in all_routes}
    for path in (
        "/api/uc/volumes/browse",
        "/api/import/preview",
        f"{_VI}/inputs",
    ):
        assert path in discovered, f"{path} not mounted by ROUTERS"


def test_declared_guards_are_exactly_the_vibe_inputs_routes(all_routes):
    """Declared guards are used by the 21 vibe_inputs routes and nothing else,
    each with its intended role, so a new route cannot hide behind
    ``ModelerDeclared`` instead of an enforced guard."""
    assert len(_DECLARED_UNENFORCED_ROUTES) == 21
    declared = {
        (m, p): role
        for m, p, r in all_routes
        if (role := _declared_min_role(r)) is not None
    }
    assert set(declared) == _DECLARED_UNENFORCED_ROUTES, (
        "Declared-guard routes differ from _DECLARED_UNENFORCED_ROUTES:\n"
        + "\n".join(
            f"  extra {m} {p}" for m, p in sorted(set(declared) - _DECLARED_UNENFORCED_ROUTES)
        )
        + "\n"
        + "\n".join(
            f"  missing {m} {p}" for m, p in sorted(_DECLARED_UNENFORCED_ROUTES - set(declared))
        )
    )
    for key in _DECLARED_VIEWER_ROUTES:
        assert declared[key] == UserRole.VIEWER, key
    for key in _DECLARED_MODELER_ROUTES:
        assert declared[key] == UserRole.MODELER, key


def test_every_vibe_inputs_route_declares_a_role():
    """Every route on the vibe_inputs router declares a role."""
    routes = iter_route_methods(_routes_vibe_inputs.router.routes)
    assert len(routes) == 21
    missing = [f"  {m} {p}" for m, p, r in routes if _declared_min_role(r) is None]
    assert not missing, "vibe_inputs routes without a declared role:\n" + "\n".join(missing)


# ---------------------------------------------------------------------------
# Declared guards at request time: the two switches
# ---------------------------------------------------------------------------


def _viewer_ws():
    """Workspace client whose SCIM lookup finds the caller in no app group."""
    from unittest.mock import MagicMock

    ws = MagicMock()
    user = MagicMock()
    user.groups = []
    ws.users.list.return_value = [user]
    return ws


_VIEWER_HEADERS = {"X-Forwarded-Email": "viewer@example.com"}


@pytest.fixture
def seeded_version(engine) -> tuple[str, str]:
    """A business with one completed version: (business_id, version_id)."""
    with Session(engine) as session:
        b = Business(name="Acme")
        session.add(b)
        session.commit()
        mv = ModelVersion(business_id=b.id, version=1, status="completed", scope="ecm")
        session.add(mv)
        session.commit()
        return b.id, mv.id


@pytest.fixture
def declared_guard_client(client):
    """The shared test client, with role resolution left real (no override)
    so the RBAC switch and SCIM decide the caller's role."""
    client.app.state.workspace_client = _viewer_ws()
    return client


def _create_input(client, business_id: str, version_id: str):
    return client.post(
        f"/api/businesses/{business_id}/inputs",
        json={"text": "Rename the orders table", "version_id": version_id},
        headers=_VIEWER_HEADERS,
    )


def test_viewer_passes_modeler_declared_route_while_unenforced(
    declared_guard_client, seeded_version, monkeypatch, caplog
):
    """RBAC on, constant False: a VIEWER passes a Modeler-declared route.

    The guard's debug log proves the caller resolved to VIEWER, so the pass is
    not the no-identity APP_ADMIN fallback."""
    monkeypatch.setattr(_roles_mod, "RBAC_ENABLED", True)
    monkeypatch.setattr(_roles_mod, "VIBE_INPUT_ROLE_GUARDS_ENFORCED", False)
    bid, vid = seeded_version
    with caplog.at_level("DEBUG", logger=_roles_mod.__name__):
        r = _create_input(declared_guard_client, bid, vid)
    assert r.status_code == 200, r.text
    assert "would refuse role viewer (needs modeler)" in caplog.text


def test_viewer_gets_403_on_modeler_declared_route_when_enforced(
    declared_guard_client, seeded_version, monkeypatch
):
    """RBAC on, constant True: a VIEWER is refused before anything is written."""
    monkeypatch.setattr(_roles_mod, "RBAC_ENABLED", True)
    monkeypatch.setattr(_roles_mod, "VIBE_INPUT_ROLE_GUARDS_ENFORCED", True)
    bid, vid = seeded_version
    r = _create_input(declared_guard_client, bid, vid)
    assert r.status_code == 403, r.text
    assert r.json()["detail"] == "Modeler access required"
    listed = declared_guard_client.get(
        f"/api/businesses/{bid}/inputs", headers=_VIEWER_HEADERS
    )
    assert listed.status_code == 200, listed.text
    assert listed.json() == []


def test_enforced_constant_has_no_effect_with_rbac_off(
    declared_guard_client, seeded_version, monkeypatch
):
    """RBAC off: every caller resolves to APP_ADMIN, so the constant does not matter."""
    monkeypatch.setattr(_roles_mod, "RBAC_ENABLED", False)
    monkeypatch.setattr(_roles_mod, "VIBE_INPUT_ROLE_GUARDS_ENFORCED", True)
    bid, vid = seeded_version
    r = _create_input(declared_guard_client, bid, vid)
    assert r.status_code == 200, r.text


def test_assessment_grant_route_is_removed(all_routes):
    """The app grants nothing on customer catalogs: the assessment grant-read route is gone."""
    assert not any(p == "/api/assess/grant-model-read" for _, p, _ in all_routes)


def test_saved_taxonomy_wizard_routes_are_business_admin(all_routes):
    """The saved Domain Taxonomy wizard (read, save, discard) takes the same
    guard as createTaxonomyDraft and createBusiness: BusinessAdminOnly."""
    by_key = {(m, p): r for m, p, r in all_routes}
    for method in ("GET", "PUT", "DELETE"):
        route = by_key.get((method, "/api/taxonomy/saved"))
        assert route is not None, f"{method} /api/taxonomy/saved not mounted"
        assert require_business_admin in _dependant_calls(route), f"{method} /api/taxonomy/saved"

# Conventions

How changes are built in this app. Maintainers review every pull request against these rules. Each rule names the code that already does it: reuse that code. Where a test enforces a rule, the test is named; it fails your local checks before review does.

Paths: `backend/` is `src/app/src/vibe_modeling/backend/`, `ui/` is `src/app/src/vibe_modeling/ui/`. Tests live under `tests/test_app/`.

## 1. Reuse before you add

- Before writing a helper, search for the existing one that does the same job: sanitizer, path builder, API client, job creation, identity, time handling. Use it. If it is wrong, fix it there.
- If you find two or more inline copies and no shared helper, move the logic into the shared module (`backend/core/`, `ui/lib/`) and migrate every copy in the same PR.
- When backend and UI must agree on a rule (name patterns, presets), put the cases in one fixture under `tests/fixtures/` and test both sides against it. Example: `business_name_fixture.json`.
- Don't add a package if the repo already has one that does the job. Justify every new dependency in the PR.

## 2. Optional features

A new feature that needs anything beyond the core app (extra infrastructure, permissions, a workspace job, another service principal, or an external or model service) may be rolled in as optional at install time, off by default, or both. The development team decides when such a feature moves into the core app and is turned on. When a feature is optional, build it this way:

- The installer turns it on with `install/install.sh --enable-<feature>`. `install/render_app_yaml.py` writes it into `app.yml`, and `AppConfig` reads it as `<feature>_enabled: bool = False` (see `backend/core/_config.py`).
- With the feature turned off, the app is fully usable. No page, card, menu entry or background poller of the feature appears or starts, and no other feature depends on it.
- Gate every route of the feature with `core/_features.require_installed("<feature>_enabled", detail)`. Keep its router mounted, so the API surface is the same in every deployment; gated routes answer 404 while the feature is off. If the UI must know whether to show the feature, add one ungated status route (pattern: `GET /api/assess/config`).
- Settings hold the runtime configuration: a row in the app database, edited in the app. Environment variables don't hold it. An install flag may seed the first value; after that, Settings own it. Pattern: `AppConfig.taxonomy_install_default_model_service` seeds `AgentConfig.taxonomy_model_service`.
- Declare app scopes, resources or grants for the feature only when it is enabled. Example: the `workspace.workspace` user scope is rendered only with `--enable-assessment`.
- `INSTALL.md` gets an "Enabling <feature> (optional)" section: what the feature does, the flag, what an admin must grant, and where to change its settings later.
- Tests: the `app.yml` render with the flag on and off, every route answering 404 when off, the UI hiding the feature when off.
- Examples to copy: the Domain Taxonomy Builder (`backend/routes/taxonomy.py`) and the headless assessment (`backend/routes/assessments.py`).

## 3. Workspace jobs and files the app creates

- Notebooks the app runs ship inside the app under `src/app/vendored/`. They are never fetched at run time.
- The app service principal owns every job and workspace folder the app creates. Put files under its home, `core/_app_identity.app_sp_home(ws)`. Never use `/Workspace/Shared`: every workspace user can manage what is there. A `/Workspace/Shared` or `/Shared/` path literal in the backend, the installer, the vendored tree or `databricks.yml` fails `test_platform_drift_locks.py`.
- Create or update the job at app start and on the Settings save that changes it, with one check-then-act sync, so a redeploy points the job at the new notebook. Use `job_launcher.reset_or_create_job`. Patterns: `core/_bundled_agent_init.py`, `assessment/job_sync.sync_assessment_job`.
- Store the job id in the app database. Build job and run links with `routes/_helpers.build_job_run_url` (it keeps the `?o=` workspace parameter).
- Files written for a user go to that user's home with the user's own token (`Dependencies.UserClient`). Never write them with the app service principal and then grant access.

## 4. Grants and permissions

- The app grants only on objects it owns: the `_metamodel` schema and its volumes in the deployment catalog, and the workspace folders and jobs it created. In app code that is `assessment/job_sync.py`; in the installer, `install/grant_catalog.py`. A grant or permission SDK call (`grants.update`, `permissions.update`, `permissions.set`, `set_permissions`, `update_permissions`) in any other Python module of the backend or the installer fails `test_platform_drift_locks.py`. Adding a module to its allow-list needs a maintainer's agreement in the PR. SQL `GRANT` statements, raw permission REST calls and shell scripts are not checked; review covers them.
- The app never grants anything on a customer catalog, a model service or a SQL warehouse. When access is missing, check it read-only and show the admin the exact command to run. Patterns: `assessment/readiness.py`, `install/check_model_service.py`.
- Read effective privileges first and grant only what is missing (`assessment/job_sync._grant_missing`).

## 5. Model calls

- Call models only as Unity Catalog model services through the AI Gateway (`/ai-gateway/mlflow/v1/chat/completions`). Legacy `/serving-endpoints/` paths are not used. Today the client is `taxonomy/llm.py`. The second feature that calls a model first moves that client into a shared module. In the backend and the installer, `serving_endpoints.query`, a `/serving-endpoints/` or `/invocations` path, an `openai` import, or an AI Gateway path outside that client fails `test_platform_drift_locks.py`. (`serving_endpoints.http_request` for Unity Catalog HTTP connections is a different API and is allowed.)
- Never assume access. Many workspaces deny the default `system.ai` services. The installer checks USE CATALOG, USE SCHEMA and EXECUTE for the app service principal and prints the grant commands; it never grants (`install/check_model_service.py`). The app checks again on every Settings change with a one-token test call as the app service principal.
- Bound the load. Each feature caps its live model calls app-wide and per user, runs them on its own executor (never `asyncio.to_thread` on the shared default pool), and gives every call a timeout. Patterns: `taxonomy/slots.py`, `core/_taxonomy_executor.py`, `taxonomy/llm.LLM_HTTP_TIMEOUT_SECONDS`. A busy model is a retryable state the user sees.

## 6. Calls that change things

- **Check, then act.** A request that will be refused changes nothing outside the app's own database: no Unity Catalog objects, no Volume files, no jobs, no grants. Run every check first. Do preparation steps right before you save the row that records the action.
- **Decide from the real state.** When a call fails ambiguously ("already exists", a conflict, a timeout), read the state again and decide from what you read. Don't map SDK error classes to meanings. Example: an existing schema answers `BadRequest` with `SCHEMA_ALREADY_EXISTS`, which is not a conflict error.
- **Prefer the simpler idempotent path.** If always doing a harmless, idempotent step is simpler than doing it only when needed, always do it, and say in the PR why it is harmless.
- **Bound every external call.** A timeout, a retry limit with backoff, and a final state the user can see. No endless retry loops.
- **Change state in one step across layers.** When a run or batch changes state (cancel, fail, complete), one helper updates every dependent row and the external job in one transaction. If the external part can't be done (a job won't cancel), the state says so.
- **Errors reach users sanitized.** Pass error text through `error_sanitization.sanitize_error_message`. A caught database or connection error (SQLAlchemy, psycopg, requests) is never `str(e)` in a response or a stored column: its text carries the SQL, the bound parameters and the host. Use `error_sanitization.recorded_error_text` (logs the error with a reference, returns a fixed sentence plus that reference), `unhandled_error_detail`, or the `is_opaque_error` predicate. `test_error_text_drift_lock.py` fails a store of caught-error text in an error field that does none of these. When only an admin can fix the problem, raise `core/_errors.admin_help_error` (409 `{error: "admin_help", message, job_url, run_url}`) so the UI can say what to do and who can do it.
- **One status per error class.** Build structured errors with `core/_errors`, never by hand: an unset setting is 422 `config_missing` (`config_missing_error`), a refused model service is 400 `model_service_refused` and any other refused Save value is 400 `setting_refused`, a run-time failure only an admin can fix is 409 `admin_help`, and a missing identity or workspace email is 401 `identity_missing` (through `core/_identity`). The discriminators are spelled only in `core/_errors.py` (`test_contracts.TestFeatureErrorShapes`).
- **One error handler.** Every HTTPException detail goes through the one handler in `error_sanitization.register_error_handlers`: a string detail is sanitized whole, a dict detail only under `message`, `detail` and `error_message` (redacted, cut at 500 characters). Put anything the user must copy or click (paths, URLs, identities, SQL) under its own key. Don't register another HTTPException handler. Write a path in hint text as a `<placeholder>` template (`/Volumes/<catalog>/<schema>/<volume>`); the handler keeps those. Text the app composes from bounded parts that ends in the steps to fix it (a run blocker) can be an `error_sanitization.AppMessage`, cut at 2000 characters.
- **The app-agent boundary fails hard.** Model sync, progress mirroring and agent output ingestion assert counts and contracts and fail loudly. A silently wrong model is worse than a failed run.

## 7. Identity, catalogs, time, schema, routes

- Read the caller's identity only through `core/_identity.py` (`Dependencies.UserIdentity`, `actor_label`, `require_user_email`). Enforced by `test_identity_drift_lock.py`.
- Resolve catalogs only through `core/_catalogs.py`. Enforced by `test_catalog_drift_lock.py`.
- Store and compare times in UTC. Normalize with `core/_time.as_utc`. API datetimes carry a timezone, so a browser doesn't read them as local time.
- Database tables are normalized by default: one fact per row, relationships as foreign keys, no duplicated columns. A JSON blob, array or copied column needs a written reason in the model docstring. Assemble nested API shapes at read time.
- Routes: every route has `response_model` and `operation_id`. Use the `Dependencies.*` types in `core/dependencies.py` instead of building clients or reading `request.app.state`. Models follow `Entity` / `EntityIn` / `EntityOut`.
- Every new route is classified for access: it declares a role guard (`Dependencies.AdminOnly`, `BusinessAdminOnly`, `ModelerOnly`), or it is listed in `tests/test_app/test_rbac_coverage.py` with a one-line reason. `test_every_route_is_classified` checks every router the app mounts (`backend/_routers.ROUTERS`); a new router goes in that list. The declared guards `ModelerDeclared` and `ViewerDeclared` are for the `vibe_inputs` routes only; the test fails if another route uses them.

## 8. Versions and migrations

- A PR may change `version` in `src/app/pyproject.toml` and may add migrations. Both are suggestions: maintainers set the release version and may revert or fold them. Say in the PR why you chose them.
- Name a migration for the release it targets: `backend/migrations/v_X_Y_Z.py`, where X.Y.Z is above the latest release tag. If `v_X_Y_Z` already exists for that release, add `v_X_Y_Z_1` (then `_2`). One migration per release is the usual shape; maintainers may fold several into one before the release ships.
- Never edit, rename or delete a migration that has shipped: its X.Y.Z is at or below the X.Y.Z of the latest release, the highest `vX.Y.Z` tag reachable from the base branch, or tagged but not yet synced into it with an X.Y.Z at or below the base `pyproject` version (`v_0_8_0_1` has shipped once `v0.8.0` is tagged). A new migration at or below that version would never run on an installed database. Strict migration discipline applies between released versions only. Until the tag exists, the migrations of the version in preparation are unpublished: you may add to them, edit them and merge the code, even after the release-prep PR has set `pyproject` to that version. Without any release tag (a clone without tags), the gate falls back to the base `pyproject` version.
- Mirror every `ALTER TABLE ... ADD COLUMN` in `scripts/db/migrate.py`. Enforced by `test_migration_drift_owner.py`.
- Migrations are additive. Test them on Postgres as well as SQLite (section 10).
- `test_migrations.py` checks the naming: `v_X_Y_Z` or `v_X_Y_Z_N` matching its `MIGRATION.version`, registered in order, micro levels contiguous from `v_X_Y_Z`. The maintainers' gate also checks the diff against the base branch: an edited, renamed or deleted shipped migration, or a new one at or below the latest release, fails; a version bump or more than one new migration is reported as advisory.
- At the release, the tag `vX.Y.Z`, `pyproject` and the newest migration's X.Y.Z are the same. The maintainers enforce this when they cut the release, not on your PR.
- Vendored upstream content (agent notebook, skills, rule files) is pinned to a released upstream ref and recorded next to it (`VERSIONS.json` or a marker file). Vendoring from a personal or development branch needs a maintainer's decision.

## 9. Generated files

| File | Made by | Rule |
|---|---|---|
| `ui/lib/api.ts` | apx, from the backend OpenAPI | Committed. Regenerate after any route or model change and after every rebase. Never edit it by hand. Never resolve merge conflicts in it: take either side, then regenerate. |
| `ui/types/routeTree.gen.ts` | TanStack Router, run by apx | Same as `api.ts`. |
| `_version.py`, `_metadata.py` | hatch, apx | Not committed. `CONTRIBUTING.md` shows how to create them. |
| `src/app/package.json`, `bun.lock` | you | Change them only for a deliberate dependency change. apx can bump devDependencies during a build or a regen; revert that. |

To regenerate both client files, run `apx dev check` in `src/app`. It rewrites them before it type-checks, so its exit code reports only the type findings. A running `apx dev start` (its watcher) or apx's `refresh_openapi` MCP tool do the same. Then run the checks. `test_generated_client_fresh.py` fails when an operation of the app (its id, method or path) or a route file is missing from, or differs in, the committed files. A change to a request or response model alone is not detected, so regenerate after model changes too.

Don't commit session or tool files (`SESSION_HANDOFF.md`, `.isaac/`, editor folders). `.gitignore` covers the known ones.

## 10. Tests a change adds

| Layer | Location | Purpose |
|---|---|---|
| Unit | `tests/test_app/test_*.py` | Module logic, mocked dependencies |
| Contract | `tests/test_app/test_contracts.py` | In/Out/DB field alignment, enum consistency |
| Flow | `tests/test_app/test_flows.py` | Multi-step user journeys through the API |
| Regression baseline | `tests/test_app/test_regression_baseline.py` | API response shapes |
| Drift locks | `tests/test_app/test_*_drift_lock*.py` | One home per rule (identity, catalogs, platform) |
| Frontend | `ui/__tests__/` | Component rendering and behavior |

- New endpoint: unit tests, a contract test for new In/Out/DB models, a regression-baseline test for the response shape (`test_regression_baseline.py`), and its access classification (section 7).
- New table: `test_db_models.py` and `test_contracts.py`.
- Migrations, foreign-key cascades, `reconcile_schema`: SQLite can't show these. Add a Postgres test that skips without a database. Pattern: `tests/test_app/test_assess_ingest_pg.py` (skips without `ASSESS_PG_DATABASE`).
- A refused request writes nothing: assert the write surfaces are unchanged. Pattern: `tests/test_app/_assess_helpers.table_digests`.
- Every API test asserts the HTTP status.
- A changed component, label, route or field: update every test that still asserts the old one, including tests in files you didn't touch.
- UI changes: check light and dark themes; text meets WCAG AA contrast, computed from the theme tokens; after filling a form field, check its value.
- Don't leave a failing test as "pre-existing" without evidence: show the same failure on the base branch.

## 11. Docs a change updates

- Every added, moved or deleted module, component, test file or script gets its line in that directory's `INDEX.md` in the same PR. The INDEX describes what exists now; git keeps the history.
- `INSTALL.md` covers installing the app, including install-time setup. It never describes run-time behavior.
- Describe the design of a non-trivial change in the PR. Don't commit execution plans, agent transcripts or generated specs.
- No personal or environment-specific values in shared files: workspace hosts or ids, profile names, service principal ids, local paths. Use placeholders.
- Comments explain code that isn't obvious. No "removed X" comments and no history in comments; git keeps history.
- Fix every build error and warning your change causes before review.

## 12. Pull requests

- One feature or fix per PR. Ship infrastructure, refactors and features in separate PRs.
- The description says what and why, what changes for install, configuration or the API, how you tested it (the local check output and any live environment), and known limitations.

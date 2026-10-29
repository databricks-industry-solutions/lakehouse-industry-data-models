# Contributing to model-app

`model-app` is a component of the Databricks industry data models initiative
(the `databricks-industry-solutions/lakehouse-industry-data-models` repository).
It is a Databricks App control plane for AI-assisted data modeling. Third-party
pull requests are welcome as a secondary use case; the primary maintainers are
the Databricks industry-solutions team.

Read [docs/conventions.md](docs/conventions.md) before you start. Maintainers
review against it.

## Local setup

The app is a Python + FastAPI backend with a React + TypeScript frontend, built
with [`apx`](https://github.com/databricks-solutions/apx).

Prerequisites:

- **Python 3.11+.** Use one environment per checkout: uv (below) or any
  virtualenv with the pip line below.
- **[uv](https://github.com/astral-sh/uv)** (latest) for Python dependency management
- **[Bun](https://bun.sh) 1.2+** for the frontend build and dev server
- **Node.js 20.19+ (LTS 20 or 22) and npm** — required for the `npx tsc` / `npx vitest` checks below. The frontend *build* uses Bun, but the documented type-check and unit-test commands run through `npx`; you can skip Node.js if you run the checks via `apx dev check` (Bun) instead.
- **[apx](https://github.com/databricks-solutions/apx)** (latest) to drive the dev loop and build

Install dependencies:

```bash
# Backend (from the repo root): creates src/app/.venv with the app installed
# in editable mode, its runtime dependencies, and the `dev` group (ty, jsonschema)
uv sync --project src/app

# Frontend (from src/app)
cd src/app
bun install
```

The backend tests also need `pytest`, `pytest-asyncio` (for the async tests),
`httpx` and `pyyaml`, which are not in the `dev` group. `uv run --with` adds them for the test run (see below).

If you use `pip` instead of `uv`, install the same set into your virtualenv:

```bash
python -m pip install -e src/app 'jsonschema>=4.0' pytest pytest-asyncio httpx pyyaml
```

Two files under `src/app/src/vibe_modeling/` are generated and not checked in:

- `_version.py` is written by the hatch version hook whenever the package is
  built, including the editable install above.
- `_metadata.py` is written by apx (`apx build` or `apx dev start`).

If either is missing when you run the tests, create it by hand:

```python
# src/app/src/vibe_modeling/_version.py
version = "<version>"  # use the version in src/app/pyproject.toml
```

```python
# src/app/src/vibe_modeling/_metadata.py
from pathlib import Path

app_name = "vibe-modeling"
app_entrypoint = "vibe_modeling.backend.app:app"
app_slug = "vibe_modeling"
api_prefix = "/api"
dist_dir = Path(__file__).parent / "__dist__"
```

The public tree pins the public npm registry (`registry.npmjs.org`) in
`src/app/bunfig.toml`. If your organization uses an internal npm proxy or
registry, repoint `src/app/bunfig.toml` to it and re-resolve `bun.lock`
(`bun install`) before building.

## Running the checks

These checks run without a Databricks workspace and are the bar for a PR:

```bash
# Python backend tests (from the repo root)
uv run --project src/app --with pytest --with pytest-asyncio --with httpx --with pyyaml pytest tests/test_app
# or, in an activated virtualenv set up with pip:
pytest tests/test_app

# Frontend type-check and unit tests (from src/app)
cd src/app
npx tsc --noEmit
npx vitest run
```

`apx dev check` runs the type/lint checks across both stacks if you have apx
installed.

The maintainers run a wider gate on their side before merging; the checks
above are what a pull request needs to pass.

## Pull request conventions

Each item links the rule in [docs/conventions.md](docs/conventions.md):

- One feature or fix per PR; describe what and why, and note any change to
  install, configuration or the API ([12](docs/conventions.md#12-pull-requests)).
- A `version` change in `src/app/pyproject.toml` and new migrations are
  welcome as suggestions; maintainers may revert or fold them. Name a migration
  for its target release and never change a shipped one (covered by a release tag)
  ([8](docs/conventions.md#8-versions-and-migrations)).
- Regenerate `ui/lib/api.ts` and `ui/types/routeTree.gen.ts` after your last
  rebase; never edit or merge them by hand
  ([9](docs/conventions.md#9-generated-files)).
- Classify every new route for access
  ([7](docs/conventions.md#7-identity-catalogs-time-schema-routes)).
- Update the `INDEX.md` of every directory where you add, move or delete a file
  ([11](docs/conventions.md#11-docs-a-change-updates)).
- A new feature that needs more than the core app may come in as optional
  and/or off by default; the development team decides when it moves to core
  ([2](docs/conventions.md#2-optional-features)).
- Make the checks above pass, and back any failure you call pre-existing with
  the same failure on the base branch
  ([10](docs/conventions.md#10-tests-a-change-adds)).

## Contributor License Agreement

By submitting a contribution you certify that you have the right to submit it,
that you grant the project a license to use it under the repository's license,
and that it contains no confidential or proprietary information. Opening a pull
request is taken as acceptance of these terms.

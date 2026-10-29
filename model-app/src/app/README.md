# vibe-modeling ✨

> A modern full-stack application built with [`apx`](https://github.com/databricks-solutions/apx) 🚀

## 🛠️ Tech Stack

This application leverages a powerful, modern tech stack:

- **Backend** 🐍 Python + [FastAPI](https://fastapi.tiangolo.com/)
- **Frontend** ⚛️ React + [shadcn/ui](https://ui.shadcn.com/)
- **API Client** 🔄 Auto-generated TypeScript client from OpenAPI schema

## 🚀 Quick Start

### Development Mode

Start all development servers (backend, frontend, and OpenAPI watcher) in detached mode:

```bash
apx dev start
```

This will start an apx development server, which in it's turn runs backend, frontend and OpenAPI watcher.
All servers run in the background, with logs kept in-memory of the apx dev server.

### 📊 Monitoring & Logs

```bash
# View all logs
apx dev logs

# Stream logs in real-time
apx dev logs -f

# Check server status
apx dev status

# Stop all servers
apx dev stop
```

## ✅ Code Quality

Run type checking and linting for both TypeScript and Python:

```bash
apx dev check
```

## 📦 Build

Create a production-ready build:

```bash
apx build
```

## 🚢 Deployment

To deploy, re-run `install/install.sh` from the repo root with `--profile` and `--app-name`. For an app that exists it reads every setting from the running app, shows them and asks before it deploys; pass a flag only to change a value (see [Re-running the installer](../../INSTALL.md#re-running-the-installer)).

A deploy by hand needs the app name and every setting exported; `install/install.sh --dry-run --app-name <app-name>` prints the values the app runs with (see [Deploying without `install.sh`](../../INSTALL.md#deploying-without-installsh)):

```bash
export VIBE_MODELING_APP_NAME=<app-name>   # from the repo root
bash install/build_and_render.sh --profile <your-profile>   # before the deploy
databricks bundle plan -p <your-profile> --var "app_name=<app-name>"     # check: no delete or recreate of the app
databricks bundle deploy -p <your-profile> --var "app_name=<app-name>"
```

The render writes the bundle's user-scopes include, which the deploy reads before its own build step. If you skip it, re-run the deploy when that step stops with "The app's user API scopes changed". Without an app name or with a setting not exported, the build stops instead of resetting the app to defaults.

---

<p align="center">Built with ❤️ using <a href="https://github.com/databricks-solutions/apx">apx</a></p>

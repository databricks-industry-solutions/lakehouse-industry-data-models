# GitHub Integration Setup Guide

This guide sets up **publish-to-GitHub** for the Vibe Data Modelling app: publishing an
industry model version to a GitHub repository as a pull request, attributed to the **acting
user** (not the app service principal).

It is a one-time admin setup per workspace. Substitute the `<placeholders>` with your own
values — the GitHub OAuth app, client secret, repo, app URL, workspace host, and publisher
identities differ per installation. The fixed GitHub URLs and the connection field values
called out as literals are the same for everyone.

## How it works (why the setup looks the way it does)

The app calls the GitHub REST API through a **Unity Catalog HTTP connection** using
**OAuth User-to-Machine (U2M), Per User**. Each publisher authorizes once via GitHub's
consent screen; their personal token is minted on demand and the app never sees or stores a
raw token. The connection points at the GitHub **API host**; the target repository is chosen
in the app's config, so one connection serves any repo your publishers can push to.

> The connection must be created in the **Catalog Explorer UI** — a per-user U2M connection
> cannot be created via SQL/IaC/Terraform because the per-user token grant is interactive.

## Prerequisites

- Workspace admin (to enable app user-authorization and create the UC connection).
- A GitHub account/org that can own an OAuth app, with access to the target repo.
- The app deployed (you'll need its URL and, for the connection callback, the workspace host).

## Step A — Register a GitHub OAuth App

GitHub → **Settings → Developer settings → OAuth Apps → New OAuth App**. This is
account/org-level, not tied to a repository.

| Field | Value |
|---|---|
| Application name | any label, e.g. `vibe-modeling` |
| Homepage URL | your deployed app URL, e.g. `<your-app-url>` (cosmetic — shown on the consent screen, not used in the flow) |
| Application description | optional |
| Authorization callback URL | the Databricks connection callback (see note) |
| Enable Device Flow | **leave unchecked** — we use the standard authorization-code flow; the callback URL is that flow |

**Callback URL (chicken-and-egg):** the exact value is shown by Databricks when you create the
connection (Step B), and has the form `https://<workspace-host>/oidc/v1/oauth/connections/callback`.
If unsure, create the connection first to read the exact callback, then come back and set it here.

After **Register application**: copy the **Client ID**, then **Generate a new client secret**
and copy it immediately — GitHub shows it once.

**Where the secret goes:** paste it into the UC connection in Step B. Unity Catalog stores and
encrypts it as part of the connection. Do **not** put it in a secret scope, a file, an env var,
or a commit. (The app's `secret_scope`/`secret_key` config fields are for a deferred
personal-access-token fallback, not this OAuth path — leave them blank.)

## Step B — Create the `github_pr` UC HTTP connection

Catalog Explorer → the **"Manage Unity Catalog connections to external services and Lakehouse
Federation"** page → **Create connection**. Type **HTTP**, name **`github_pr`** (any name; you'll
reference it in the app config), Auth type **OAuth U2M (Per user)**. The wizard has two pages.

**Page 1 — Authentication**

| Field | Value |
|---|---|
| Host | `api.github.com` (hostname only — the GitHub **API** host) |
| Port | `443` |
| Client ID / Client secret | from the OAuth App (Step A) |
| Authorization endpoint | `https://github.com/login/oauth/authorize` |
| OAuth scope | `repo` (read + open-PR on public **and** private repos). Use `public_repo` instead to restrict the token to public repos only. |

**Page 2 — Connection details**

| Field | Value |
|---|---|
| is MCP connection | **off** |
| Base path | **leave empty** (the app calls `/repos/{owner}/{repo}/...`; a base path would be prepended and break them) |
| OAuth credential exchange method | **Body only** (`client_secret_post`) |
| Token endpoint | `https://github.com/login/oauth/access_token` |

> **Host gotcha:** GitHub's API host (`api.github.com`, in **Host**) differs from its OAuth host
> (`github.com`, in the authorization/token endpoints). The **Token endpoint is its own field on
> page 2** — set it explicitly; do not let it derive from Host (a derived `api.github.com` token
> URL fails the OAuth exchange).

## Step C — Grant connection usage

Because publishing runs **on behalf of the user**, Unity Catalog enforces the *user's* grant —
so grant the publishers, not only the app service principal:

```sql
GRANT USE CONNECTION ON CONNECTION github_pr TO `<app-service-principal>`;
GRANT USE CONNECTION ON CONNECTION github_pr TO `<publisher-or-group>`;
```

## Step D — Enable on-behalf-of-user (OBO) on the app

OBO forwarding (`X-Forwarded-Access-Token`) is gated by a workspace-admin setting:

1. **Enable user authorization** for the app (Databricks Apps settings). This is the
   prerequisite for the OBO token to be forwarded.
2. **Restart the app**.

The **`github_pr` connection app resource** is declared in the DAB bundle (`databricks.yml`) but
is **off by default** so fresh installs stay portable. It is applied only when you deploy the
**`github-publish`** target, which adds the `USE_CONNECTION` grant to the app's `resources`; the
default `dev` target declares no app resources. Install with
`bash install/install.sh --profile <your-profile> --app-name <app-name> --enable-github-publish`
(after Step B creates the connection). The installer records the target, so re-runs keep it and
the grant is re-applied on every deploy. On an app installed with the `dev` target, the same command
switches it to `github-publish` as an update of the same app; `--disable-github-publish` switches it
back and removes the grant. For a deploy
by hand, see [Deploying without `install.sh`](../INSTALL.md#deploying-without-installsh).
You do **not** add it in the app UI; a resource added in the UI is wiped on the next deploy.
The app resolves the connection by its **name** (`github_pr`); the bundle resource `name` is
cosmetic. The `USE CONNECTION` grant (Step C) is what authorizes the OBO publish call.

> **Open item (resolve at first publish):** whether the OBO publish additionally requires a
> `user_api_scope` for the Serving Endpoints API — and its exact string — is undetermined. The
> `iam.*` defaults are auto-granted (not declarable), and no Serving Endpoints scope is currently
> documented, so none is declared in the bundle. If the first publish returns a scope/authorization
> error, determine the required scope then and add it to `resources.apps.<app>.user_api_scopes`.

## Step E — Configure the app

In the app: **Settings → GitHub** tab:

- **Auth mode:** OAuth U2M
- **Connection name:** the UC connection's **name** (`github_pr`) — this is the connection name,
  **not** the app resource key.
- **Repository owner / name:** the target repo where PRs should land.
- Leave **secret scope / secret key** blank (PAT-fallback fields, unused in OAuth mode).

Until this is saved, the Publish action stays disabled.

## First publish (per user, automatic)

The first time each publisher clicks **Publish** on a model version, Databricks redirects them to
GitHub's consent screen. They authorize once; their per-user token is minted on demand and silent
thereafter. A successful publish opens one pull request and surfaces its link.

## Troubleshooting

- **Publish button disabled** → the app has no `connection_name` set (Step E not saved).
- **422 `github_connection_missing`** → auth mode isn't `oauth_u2m`, or the connection name is
  blank/wrong, or the OBO scope/grant isn't in place (Steps C/D).
- **OAuth exchange fails after consent** → check the **Token endpoint** is
  `https://github.com/login/oauth/access_token` (the `github.com` host), not derived from the
  `api.github.com` Host (the page-2 gotcha).
- **403 from GitHub on the PR** → the authorizing user lacks push access to the target repo, or
  the scope is `public_repo` against a private repo — use `repo`.

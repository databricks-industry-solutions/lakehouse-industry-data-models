/**
 * `GithubConfigSection` (Story 11, Track C) tests.
 *
 * Covers: suspense load + hydration, the amber empty-state when no UC
 * connection is set, and the build-of-record amendment (5) round-trip
 * contract — the PUT payload MUST carry ALL `GithubConfigIn` fields,
 * including the hidden `secret_scope` / `secret_key`, so an OAuth-fields
 * save never NULLs an already-configured secret scope/key.
 */
import { afterEach, describe, expect, it, vi } from "vitest";
import {
  render,
  screen,
  waitFor,
  fireEvent,
} from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { Suspense } from "react";

import { GithubConfigSection } from "@/routes/_sidebar/settings";
import { firstRunFetcher, jsonResponse } from "./helpers/first-run";

afterEach(() => {
  vi.restoreAllMocks();
  vi.unstubAllGlobals();
});

function makeClient() {
  return new QueryClient({
    defaultOptions: {
      queries: { retry: false, staleTime: 30_000 },
      mutations: { retry: false },
    },
  });
}

function renderSection(qc: QueryClient) {
  return render(
    <QueryClientProvider client={qc}>
      <Suspense fallback={<div>loading</div>}>
        <GithubConfigSection />
      </Suspense>
    </QueryClientProvider>,
  );
}

const EMPTY_CONFIG = {
  repo_owner: "",
  repo_name: "",
  auth_mode: "",
  connection_name: "",
  secret_scope: "",
  secret_key: "",
};

describe("GithubConfigSection", () => {
  it("shows the amber empty-state + setup-guide link when no connection is set", async () => {
    vi.stubGlobal(
      "fetch",
      firstRunFetcher({
        "/api/config/github": { status: 200, body: EMPTY_CONFIG },
      }),
    );
    renderSection(makeClient());

    await waitFor(() => {
      expect(
        screen.getByText(/GitHub publishing isn't configured yet/i),
      ).toBeInTheDocument();
    });
    const link = screen.getByRole("link", {
      name: /GitHub Integration Setup Guide/i,
    });
    expect(link).toHaveAttribute("href");
    expect(link.getAttribute("href")).toMatch(/setup/i);
  });

  it("hydrates form fields from the loaded config and hides the empty-state once a connection is set", async () => {
    vi.stubGlobal(
      "fetch",
      firstRunFetcher({
        "/api/config/github": {
          status: 200,
          body: {
            repo_owner: "databricks-industry-solutions",
            repo_name: "industry-models",
            auth_mode: "oauth_u2m",
            connection_name: "github_pr",
            secret_scope: "vibe_secrets",
            secret_key: "gh_token",
          },
        },
      }),
    );
    renderSection(makeClient());

    await waitFor(() => {
      expect(
        screen.getByDisplayValue("databricks-industry-solutions"),
      ).toBeInTheDocument();
    });
    expect(screen.getByDisplayValue("industry-models")).toBeInTheDocument();
    expect(screen.getByDisplayValue("github_pr")).toBeInTheDocument();
    // Connection is set → no amber empty-state.
    expect(
      screen.queryByText(/GitHub publishing isn't configured yet/i),
    ).not.toBeInTheDocument();
  });

  it("round-trips ALL GithubConfigIn fields on PUT, including hidden secret_scope/secret_key", async () => {
    const putSpy = vi.fn();
    vi.stubGlobal(
      "fetch",
      firstRunFetcher({
        "/api/config/github": (url: string, init?: RequestInit) => {
          if (init && init.method === "PUT") {
            putSpy(url, init);
            return Promise.resolve(jsonResponse(200, {}));
          }
          return Promise.resolve(jsonResponse(200, {
              repo_owner: "acme",
              repo_name: "models",
              auth_mode: "oauth_u2m",
              connection_name: "github_pr",
              // Secret pointers persisted server-side but never surfaced
              // in this OAuth-first UI. They MUST survive a save.
              secret_scope: "vibe_secrets",
              secret_key: "gh_token",
            }));
        },
      }),
    );
    renderSection(makeClient());

    const ownerInput = (await screen.findByDisplayValue(
      "acme",
    )) as HTMLInputElement;
    // Edit an OAuth field so the form is dirty and Save enables.
    fireEvent.change(ownerInput, { target: { value: "acme-corp" } });
    await waitFor(() => expect(ownerInput.value).toBe("acme-corp"));

    const form = ownerInput.closest("form")!;
    fireEvent.submit(form);

    await waitFor(() => expect(putSpy).toHaveBeenCalled());
    const [, init] = putSpy.mock.calls[0];
    const body = JSON.parse(init.body as string);

    // The edited OAuth field is sent.
    expect(body.repo_owner).toBe("acme-corp");
    // Amendment (5): hidden secret pointers are round-tripped, NOT nulled.
    expect(body.secret_scope).toBe("vibe_secrets");
    expect(body.secret_key).toBe("gh_token");
    // Every GithubConfigIn field is present in the payload.
    expect(Object.keys(body).sort()).toEqual(
      [
        "auth_mode",
        "connection_name",
        "repo_name",
        "repo_owner",
        "secret_key",
        "secret_scope",
      ].sort(),
    );
  });
});

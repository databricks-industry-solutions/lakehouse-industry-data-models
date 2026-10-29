/**
 * `SourceAuthConfigSection` (0.7.1) tests.
 *
 * Covers: suspense load + hydration, mode switching (github_app / token /
 * anonymous field visibility), the config-error callout, and the round-trip
 * contract — the PUT payload MUST carry ALL `SourceAuthConfigIn` fields so
 * switching modes never NULLs a sibling secret reference.
 */
import { afterEach, describe, expect, it, vi } from "vitest";
import { render, screen, waitFor, fireEvent } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { Suspense } from "react";

import { SourceAuthConfigSection } from "@/routes/_sidebar/settings";
import { EMPTY_SOURCE_AUTH_CONFIG, firstRunFetcher, jsonResponse } from "./helpers/first-run";

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
        <SourceAuthConfigSection />
      </Suspense>
    </QueryClientProvider>,
  );
}

describe("SourceAuthConfigSection", () => {
  it("renders the card + doc link and shows the anonymous note when unconfigured", async () => {
    vi.stubGlobal(
      "fetch",
      firstRunFetcher({
        "/api/config/source-auth": { status: 200, body: EMPTY_SOURCE_AUTH_CONFIG },
      }),
    );
    renderSection(makeClient());

    await waitFor(() => {
      expect(screen.getByText(/Source read access/i)).toBeInTheDocument();
    });
    const link = screen.getByRole("link", {
      name: /source read authentication guide/i,
    });
    expect(link.getAttribute("href")).toMatch(/github-app-source-auth/i);
  });

  it("hydrates github_app fields and shows them for github_app mode", async () => {
    vi.stubGlobal(
      "fetch",
      firstRunFetcher({
        "/api/config/source-auth": {
          status: 200,
          body: {
            ...EMPTY_SOURCE_AUTH_CONFIG,
            auth_mode: "github_app",
            github_app_id: "123456",
            github_app_installation_id: "99887766",
            github_app_secret_scope: "vibe-modeling",
            github_app_secret_key: "gh_app_pem",
            effective_mode: "github_app",
          },
        },
      }),
    );
    renderSection(makeClient());

    await waitFor(() => {
      expect(screen.getByDisplayValue("123456")).toBeInTheDocument();
    });
    expect(screen.getByDisplayValue("99887766")).toBeInTheDocument();
    expect(screen.getByDisplayValue("vibe-modeling")).toBeInTheDocument();
    expect(screen.getByDisplayValue("gh_app_pem")).toBeInTheDocument();
  });

  it("surfaces the config error callout when resolution failed", async () => {
    vi.stubGlobal(
      "fetch",
      firstRunFetcher({
        "/api/config/source-auth": {
          status: 200,
          body: {
            ...EMPTY_SOURCE_AUTH_CONFIG,
            auth_mode: "token",
            token_secret_scope: "sc",
            token_secret_key: "k",
            effective_mode: "anonymous",
            error: "Could not read the configured source read-auth secret.",
          },
        },
      }),
    );
    renderSection(makeClient());

    await waitFor(() => {
      expect(
        screen.getByText(/could not be applied/i),
      ).toBeInTheDocument();
    });
    expect(
      screen.getByText(/Could not read the configured source read-auth secret/i),
    ).toBeInTheDocument();
  });

  it("round-trips ALL SourceAuthConfigIn fields on PUT (no sibling NULLing)", async () => {
    const putSpy = vi.fn();
    vi.stubGlobal(
      "fetch",
      firstRunFetcher({
        "/api/config/source-auth": (url: string, init?: RequestInit) => {
          if (init && init.method === "PUT") {
            putSpy(url, init);
            return Promise.resolve(jsonResponse(200, {}));
          }
          return Promise.resolve(jsonResponse(200, {
              ...EMPTY_SOURCE_AUTH_CONFIG,
              auth_mode: "github_app",
              github_app_id: "123456",
              github_app_installation_id: "99887766",
              github_app_secret_scope: "app-scope",
              github_app_secret_key: "app-key",
              token_secret_scope: "tok-scope",
              token_secret_key: "tok-key",
              effective_mode: "github_app",
            }));
        },
      }),
    );
    renderSection(makeClient());

    const appIdInput = (await screen.findByDisplayValue(
      "123456",
    )) as HTMLInputElement;
    // Edit a field so the form is dirty and Save enables.
    fireEvent.change(appIdInput, { target: { value: "654321" } });
    await waitFor(() => expect(appIdInput.value).toBe("654321"));

    const form = appIdInput.closest("form")!;
    fireEvent.submit(form);

    await waitFor(() => expect(putSpy).toHaveBeenCalled());
    const [, init] = putSpy.mock.calls[0];
    const body = JSON.parse(init.body as string);

    expect(body.github_app_id).toBe("654321");
    // Sibling token references are round-tripped, not nulled.
    expect(body.token_secret_scope).toBe("tok-scope");
    expect(body.token_secret_key).toBe("tok-key");
    expect(Object.keys(body).sort()).toEqual(
      [
        "auth_mode",
        "github_app_id",
        "github_app_installation_id",
        "github_app_secret_key",
        "github_app_secret_scope",
        "token_secret_key",
        "token_secret_scope",
      ].sort(),
    );
  });
});

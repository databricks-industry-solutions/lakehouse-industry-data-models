/**
 * Track 4 (0.6.6) Settings redesign tests.
 *
 * Covers the re-cut tab IA and the new/relocated sections:
 *  - validateSearch redirects legacy tab names onto their new homes
 *    (diagram -> preferences, warehouse -> platform, github -> sources)
 *    and every new tab name survives round-trip.
 *  - The five section components each render.
 *  - MetamodelCatalogCard (Platform): inline UC-name validation disables
 *    Save on an invalid catalog, and a valid save PUTs metamodel_catalog.
 *  - SourceAuthBanner (Sources): the persistent unauthenticated rate-limit
 *    warning shows only when capabilities.auth_mode === "anonymous".
 *  - DiagramSettingsSection (Preferences): "Reset to defaults" writes the
 *    seed values back (hide for all-domains, keys for focal).
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

import {
  Route as SettingsRoute,
  PlatformSection,
  MetamodelCatalogCard,
  SourcesSection,
  SourceAuthBanner,
  SectorsSection,
  AgentConfigSection,
  DiagramSettingsSection,
} from "@/routes/_sidebar/settings";
import { firstRunFetcher, jsonResponse } from "./helpers/first-run";
import { renderWithRouter } from "./helpers/router-wrapper";

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

// validateSearch is a pure function on the route options; call it directly.
const parseTab = (tab: unknown) =>
  (SettingsRoute.options.validateSearch as (s: Record<string, unknown>) => {
    tab: string;
  })({ tab }).tab;

describe("Settings tab IA (Track 4)", () => {
  it("keeps every new tab name round-tripping", () => {
    for (const t of ["agent", "platform", "sources", "sectors", "preferences"]) {
      expect(parseTab(t)).toBe(t);
    }
  });

  it("redirects legacy deep-links to their new homes", () => {
    expect(parseTab("diagram")).toBe("preferences");
    expect(parseTab("warehouse")).toBe("platform");
    expect(parseTab("github")).toBe("sources");
    expect(parseTab("assessment")).toBe("platform");
  });

  it("falls back to agent for unknown tab values", () => {
    expect(parseTab("bogus")).toBe("agent");
    expect(parseTab(undefined)).toBe("agent");
  });
});

describe("Settings sections render (five tabs)", () => {
  it("renders all five section components", async () => {
    vi.stubGlobal(
      "fetch",
      firstRunFetcher({
        "/api/config/metamodel-catalog": {
          status: 200,
          body: { metamodel_catalog: "", is_configured: false },
        },
        // WarehouseSection suspends on these; give it real 200 bodies. The
        // api wrapper wraps the JSON in { data }, so bodies are bare here.
        // The list endpoint (longer key) must win over the single-warehouse one.
        "/api/config/warehouses": { status: 200, body: [] },
        "/api/config/warehouse": { status: 200, body: { warehouse_id: "" } },
        // SectorsSection suspends on the sectors list (bare array body).
        "/api/sectors": { status: 200, body: [] },
        "/api/user/preferences": { status: 200, body: [] },
        "/api/sources/capabilities": {
          status: 200,
          body: {
            discovery_mode: "eager",
            materialization_timing: "on_download",
            provides_sectors: false,
            source_kind: "github",
            target_kinds: [],
            auth_mode: "anonymous",
          },
        },
      }),
    );
    const qc = makeClient();

    // The Platform tab's Optional features cards carry help links, so this needs a router.
    renderWithRouter(
      <>
        <AgentConfigSection />
        <PlatformSection />
        <Suspense fallback={<div>loading</div>}>
          <SourcesSection />
        </Suspense>
        <Suspense fallback={<div>loading</div>}>
          <SectorsSection />
        </Suspense>
        <DiagramSettingsSection />
      </>,
      { queryClient: qc },
    );

    await waitFor(() => {
      expect(screen.getByText(/Agent Configuration/i)).toBeInTheDocument();
    });
    // Platform: metamodel catalog card.
    expect(screen.getByLabelText(/Metamodel catalog/i)).toBeInTheDocument();
    // Platform: the Optional features section, one card per feature.
    expect(screen.getByRole("heading", { name: "Optional features" })).toBeInTheDocument();
    expect(screen.getByTestId("feature-card-taxonomy")).toBeInTheDocument();
    expect(screen.getByTestId("feature-card-assessment")).toBeInTheDocument();
    // Sources: GitHub publishing card + the unauthenticated banner.
    await waitFor(() =>
      expect(
        screen.getByText(/Browsing unauthenticated - GitHub limits/i),
      ).toBeInTheDocument(),
    );
    // Preferences: diagram defaults + "Only affects you" badge.
    expect(screen.getByText(/Only affects you/i)).toBeInTheDocument();
  });
});

describe("MetamodelCatalogCard (Platform)", () => {
  function renderCard(qc: QueryClient) {
    return render(
      <QueryClientProvider client={qc}>
        <MetamodelCatalogCard />
      </QueryClientProvider>,
    );
  }

  it("disables Save and shows an error on an invalid catalog name", async () => {
    vi.stubGlobal(
      "fetch",
      firstRunFetcher({
        "/api/config/metamodel-catalog": {
          status: 200,
          body: { metamodel_catalog: "", is_configured: false },
        },
      }),
    );
    renderCard(makeClient());

    const input = (await screen.findByLabelText(
      /Metamodel catalog/i,
    )) as HTMLInputElement;
    // Leading uppercase / invalid chars violate ^[a-z][a-z0-9_]+$.
    fireEvent.change(input, { target: { value: "Bad-Catalog" } });

    await waitFor(() =>
      expect(
        screen.getByText(/must start with a lowercase letter/i),
      ).toBeInTheDocument(),
    );
    const saveBtn = screen.getByRole("button", { name: /save/i });
    expect(saveBtn).toBeDisabled();
  });

  it("PUTs metamodel_catalog on a valid save", async () => {
    const putSpy = vi.fn();
    vi.stubGlobal(
      "fetch",
      firstRunFetcher({
        "/api/config/metamodel-catalog": (url: string, init?: RequestInit) => {
          if (init && init.method === "PUT") {
            putSpy(url, init);
            return Promise.resolve(jsonResponse(200, {
                metamodel_catalog: "vibe_meta",
                is_configured: true,
              }));
          }
          return Promise.resolve(jsonResponse(200, { metamodel_catalog: "", is_configured: false }));
        },
      }),
    );
    renderCard(makeClient());

    const input = (await screen.findByLabelText(
      /Metamodel catalog/i,
    )) as HTMLInputElement;
    fireEvent.change(input, { target: { value: "vibe_meta" } });

    const saveBtn = screen.getByRole("button", { name: /save/i });
    await waitFor(() => expect(saveBtn).not.toBeDisabled());
    fireEvent.submit(input.closest("form")!);

    await waitFor(() => expect(putSpy).toHaveBeenCalled());
    const [, init] = putSpy.mock.calls[0];
    expect(JSON.parse(init.body as string)).toEqual({
      metamodel_catalog: "vibe_meta",
    });
  });
});

describe("SourceAuthBanner (Sources)", () => {
  it("shows the unauthenticated rate-limit warning when auth_mode is anonymous", async () => {
    vi.stubGlobal(
      "fetch",
      firstRunFetcher({
        "/api/sources/capabilities": {
          status: 200,
          body: {
            discovery_mode: "eager",
            materialization_timing: "on_download",
            provides_sectors: false,
            source_kind: "github",
            target_kinds: [],
            auth_mode: "anonymous",
          },
        },
      }),
    );
    render(
      <QueryClientProvider client={makeClient()}>
        <SourceAuthBanner />
      </QueryClientProvider>,
    );

    await waitFor(() =>
      expect(
        screen.getByText(/Browsing unauthenticated - GitHub limits this to 60/i),
      ).toBeInTheDocument(),
    );
  });

  it("renders nothing when auth_mode is github_app", async () => {
    vi.stubGlobal(
      "fetch",
      firstRunFetcher({
        "/api/sources/capabilities": {
          status: 200,
          body: {
            discovery_mode: "eager",
            materialization_timing: "on_download",
            provides_sectors: false,
            source_kind: "github",
            target_kinds: [],
            auth_mode: "github_app",
          },
        },
      }),
    );
    render(
      <QueryClientProvider client={makeClient()}>
        <SourceAuthBanner />
      </QueryClientProvider>,
    );

    // Give the query time to settle, then assert the banner is absent.
    await new Promise((r) => setTimeout(r, 50));
    expect(
      screen.queryByText(/Browsing unauthenticated/i),
    ).not.toBeInTheDocument();
  });
});

describe("DiagramSettingsSection - Reset to defaults (Track 4)", () => {
  it("writes the seed values (hide / keys) for both preference keys", async () => {
    const writes: Array<{ url: string; body: unknown }> = [];
    const writeHandler = (url: string, init?: RequestInit) => {
      writes.push({ url, body: JSON.parse((init?.body as string) ?? "{}") });
      return Promise.resolve(jsonResponse(200, { key: url, value: "x", updated_at: "" }));
    };
    vi.stubGlobal(
      "fetch",
      firstRunFetcher({
        "/api/user/preferences/diagram.default_column_mode_focal": writeHandler,
        "/api/user/preferences/diagram.default_column_mode": writeHandler,
        // Seed with non-default values so a reset is a real change.
        "/api/user/preferences": {
          status: 200,
          body: [
            {
              key: "diagram.default_column_mode",
              value: "all",
              updated_at: "2026-07-01T00:00:00Z",
            },
            {
              key: "diagram.default_column_mode_focal",
              value: "all",
              updated_at: "2026-07-01T00:00:00Z",
            },
          ],
        },
      }),
    );
    render(
      <QueryClientProvider client={makeClient()}>
        <DiagramSettingsSection />
      </QueryClientProvider>,
    );

    const resetBtn = await screen.findByRole("button", {
      name: /reset to defaults/i,
    });
    fireEvent.click(resetBtn);

    await waitFor(() => expect(writes.length).toBe(2));
    const byKey = Object.fromEntries(
      writes.map((w) => [
        w.url.split("/api/user/preferences/")[1],
        (w.body as { value: string }).value,
      ]),
    );
    expect(byKey["diagram.default_column_mode"]).toBe("hide");
    expect(byKey["diagram.default_column_mode_focal"]).toBe("keys");
  });
});

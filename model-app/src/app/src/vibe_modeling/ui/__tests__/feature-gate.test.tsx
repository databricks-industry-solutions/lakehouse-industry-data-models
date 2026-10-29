/**
 * `FeatureGate`, the one gate of both optional features (the Domain Taxonomy
 * Builder and the bronze assessment): loading, the config error with its
 * counted-down retry, not installed, not ready (admins see why and the
 * Settings button), ready, `keepMounted`; the help index's feature cards;
 * and `SettingsErrorNotice` for a refused setting.
 */
import { act, fireEvent, render, screen } from "@testing-library/react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";

const m = vi.hoisted(() => ({
  role: "modeler" as string,
  taxonomy: {} as Record<string, unknown>,
  assess: {} as Record<string, unknown>,
  refetch: vi.fn(async () => undefined),
}));

vi.mock("@tanstack/react-router", () => ({
  Link: ({ children, to, params, search, hash, ...rest }: any) => (
    <a href={`${String(to).replace("$topic", params?.topic ?? "")}${search?.tab ? `?tab=${search.tab}` : ""}${hash ? `#${hash}` : ""}`} {...rest}>
      {children}
    </a>
  ),
  createFileRoute: () => (opts: unknown) => ({ options: opts }),
}));
vi.mock("@/lib/hooks", async (importOriginal) => ({
  ...(await importOriginal<typeof import("@/lib/hooks")>()),
  useUserRole: () => m.role,
}));
vi.mock("@/lib/api", async (importOriginal) => ({
  ...(await importOriginal<typeof import("@/lib/api")>()),
  useGetTaxonomyConfig: () => ({ refetch: m.refetch, isLoading: false, error: null, ...m.taxonomy }),
  useGetAssessConfig: () => ({ refetch: m.refetch, isLoading: false, error: null, ...m.assess }),
}));

import { ApiError } from "@/lib/api";
import { FeatureGate, SettingsErrorNotice } from "@/components/feature-gate";
import { HelpIndexPage } from "@/routes/_sidebar/help.index";
import {
  ASSESS_NOT_READY_TEXT,
  FEATURE_INFO,
  TAXONOMY_NO_SERVICE_TEXT,
  TAXONOMY_UNAVAILABLE_TEXT,
  type OptionalFeature,
} from "@/lib/features";

const taxonomyConfig = (over: Record<string, unknown> = {}) => ({
  data: { data: { installed: true, ready: true, model_service: "a.b.c", last_check: null, ...over } },
});
const assessConfig = (over: Record<string, unknown> = {}) => ({
  data: { data: { installed: true, ready: true, missing: [], ...over } },
});
const setConfig = (feature: OptionalFeature, value: Record<string, unknown>) => {
  if (feature === "taxonomy") m.taxonomy = value;
  else m.assess = value;
};
const notReady: Record<OptionalFeature, () => Record<string, unknown>> = {
  taxonomy: () =>
    taxonomyConfig({
      ready: false,
      last_check: { status: "denied", message: "The app's service principal may not use it.", checked_at: "2026-10-19T10:00:00Z" },
    }),
  assessment: () => assessConfig({ ready: false, missing: ["No reader service principal"] }),
};
const notReadyText: Record<OptionalFeature, string> = {
  taxonomy: TAXONOMY_UNAVAILABLE_TEXT,
  assessment: ASSESS_NOT_READY_TEXT,
};
const reason: Record<OptionalFeature, string> = {
  taxonomy: "The app's service principal may not use it.",
  assessment: "No reader service principal",
};

const gate = (feature: OptionalFeature, props: Record<string, unknown> = {}) => (
  <FeatureGate feature={feature} {...props}>
    <div data-testid="feature-page" />
  </FeatureGate>
);

beforeEach(() => {
  m.role = "modeler";
  m.taxonomy = taxonomyConfig();
  m.assess = assessConfig();
  m.refetch.mockClear();
});
afterEach(() => vi.useRealTimers());

describe.each(["taxonomy", "assessment"] as const)("FeatureGate (%s)", (feature) => {
  it("waits while the config loads", () => {
    setConfig(feature, { isLoading: true, data: undefined });
    render(gate(feature));
    expect(screen.queryByTestId("feature-page")).toBeNull();
    expect(screen.queryByTestId("feature-not-installed")).toBeNull();
  });

  it("not installed: the not-installed page, no children", () => {
    setConfig(feature, feature === "taxonomy" ? taxonomyConfig({ installed: false, ready: false }) : assessConfig({ installed: false, ready: false }));
    render(gate(feature));
    expect(screen.getByTestId("feature-not-installed")).toHaveTextContent(FEATURE_INFO[feature].notInstalledText);
    expect(screen.queryByTestId("feature-page")).toBeNull();
  });

  it("requireReady, not ready, non-admin: the sentence only, no reason, no Settings button", () => {
    setConfig(feature, notReady[feature]());
    render(gate(feature, { requireReady: true }));
    const notice = screen.getByTestId("feature-not-ready");
    expect(notice.textContent).toBe(notReadyText[feature]);
    expect(screen.queryByRole("link", { name: /open settings/i })).toBeNull();
    expect(screen.queryByTestId("feature-page")).toBeNull();
  });

  it("requireReady, not ready, admin: the reason and the Settings button to the feature's card", () => {
    m.role = "app_admin";
    setConfig(feature, notReady[feature]());
    render(gate(feature, { requireReady: true }));
    expect(screen.getByTestId("feature-not-ready")).toHaveTextContent(reason[feature]);
    expect(screen.getByRole("link", { name: /open settings/i })).toHaveAttribute(
      "href",
      `/settings?tab=platform#${FEATURE_INFO[feature].settings.hash}`,
    );
  });

  it("installed but not ready, without requireReady: the page shows", () => {
    setConfig(feature, notReady[feature]());
    render(gate(feature));
    expect(screen.getByTestId("feature-page")).toBeInTheDocument();
  });

  it("ready: the page shows", () => {
    render(gate(feature, { requireReady: true }));
    expect(screen.getByTestId("feature-page")).toBeInTheDocument();
  });

  it("a config error counts down to an automatic retry, and Try again retries at once", async () => {
    vi.useFakeTimers({ now: new Date("2026-10-25T10:00:00Z") });
    setConfig(feature, {
      data: undefined,
      error: new ApiError(500, "Internal Server Error", { detail: "Lakebase unavailable" }),
    });
    render(gate(feature));
    const err = screen.getByTestId("feature-config-error");
    expect(err).toHaveTextContent(`Couldn't check whether the ${FEATURE_INFO[feature].nameInSentence} is available: Lakebase unavailable.`);
    expect(err).toHaveTextContent(/Next try in 00:(1[2-8])/);
    expect(screen.queryByTestId("feature-not-installed")).toBeNull();
    await act(async () => {
      vi.advanceTimersByTime(19_000);
    });
    expect(m.refetch).toHaveBeenCalledTimes(1);
    await act(async () => {
      fireEvent.click(screen.getByRole("button", { name: "Try again" }));
    });
    expect(m.refetch).toHaveBeenCalledTimes(2);
  });

  it("keepMounted: once shown, the page stays when the feature stops being ready", () => {
    const { rerender } = render(gate(feature, { requireReady: true, keepMounted: true }));
    expect(screen.getByTestId("feature-page")).toBeInTheDocument();
    setConfig(feature, notReady[feature]());
    rerender(gate(feature, { requireReady: true, keepMounted: true }));
    expect(screen.getByTestId("feature-page")).toBeInTheDocument();
    expect(screen.queryByTestId("feature-not-ready")).toBeNull();
  });
});

describe("taxonomy not-ready wording", () => {
  it("with no model service, everyone reads that an admin must choose one", () => {
    m.taxonomy = taxonomyConfig({ ready: false, model_service: "" });
    render(gate("taxonomy", { requireReady: true }));
    expect(screen.getByTestId("feature-not-ready").textContent).toBe(TAXONOMY_NO_SERVICE_TEXT);
  });
});

describe("help index feature cards", () => {
  it("shows each feature's topic only once that feature is ready", () => {
    m.taxonomy = taxonomyConfig({ ready: false });
    m.assess = assessConfig();
    const { unmount } = render(<HelpIndexPage />);
    expect(screen.queryByText("Building a business from your domains")).toBeNull();
    expect(screen.getByText("Assessing a model against your data")).toBeInTheDocument();
    unmount();
    m.taxonomy = taxonomyConfig();
    m.assess = assessConfig({ installed: false, ready: false });
    render(<HelpIndexPage />);
    expect(screen.getByText("Building a business from your domains")).toBeInTheDocument();
    expect(screen.queryByText("Assessing a model against your data")).toBeNull();
  });
});

describe("SettingsErrorNotice", () => {
  it("shows a refused model service's message with the link to its setting", () => {
    const err = new ApiError(400, "Bad Request", {
      detail: { error: "model_service_refused", key: "taxonomy_llm", status: "denied", message: "Access denied." },
    });
    render(<SettingsErrorNotice error={err} fallback="Failed" testId="n" />);
    const notice = screen.getByTestId("n");
    expect(notice).toHaveAttribute("role", "alert");
    expect(notice).toHaveTextContent("Access denied.");
    expect(notice).toHaveTextContent("Domain Taxonomy Builder model service");
    expect(screen.getByRole("link", { name: "Configure" })).toHaveAttribute("href", "/settings?tab=platform#feature-taxonomy");
  });

  it("any other error shows its message alone", () => {
    render(<SettingsErrorNotice error={new Error("boom")} fallback="Failed" testId="n" />);
    expect(screen.getByTestId("n")).toHaveTextContent("boom");
    expect(screen.queryByRole("link")).toBeNull();
  });
});

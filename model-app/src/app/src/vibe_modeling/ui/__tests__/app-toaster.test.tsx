/**
 * The app's Toaster follows the app theme. Sonner defaults to its light
 * palette, so without the `theme` prop a dark-mode toast paints a light
 * background under the dark theme's near-white foreground (1.24:1).
 */
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { act, cleanup, render, waitFor } from "@testing-library/react";
import { toast } from "sonner";
import { ThemeProvider } from "@/components/apx/theme-provider";
import { AppToaster } from "@/components/app-toaster";

function installLocalStorageShim(initial: Record<string, string> = {}) {
  const store = new Map<string, string>(Object.entries(initial));
  vi.stubGlobal("localStorage", {
    get length() {
      return store.size;
    },
    clear: () => store.clear(),
    getItem: (k: string) => (store.has(k) ? store.get(k)! : null),
    setItem: (k: string, v: string) => void store.set(k, String(v)),
    removeItem: (k: string) => void store.delete(k),
    key: (i: number) => Array.from(store.keys())[i] ?? null,
  } satisfies Storage);
}

function stubPrefersDark(dark: boolean) {
  vi.stubGlobal("matchMedia", (query: string) => ({
    matches: dark && query.includes("dark"),
    media: query,
    addEventListener: () => {},
    removeEventListener: () => {},
    addListener: () => {},
    removeListener: () => {},
    onchange: null,
    dispatchEvent: () => false,
  }));
}

function renderToaster(defaultTheme: "dark" | "light" | "system") {
  return render(
    <ThemeProvider defaultTheme={defaultTheme} storageKey="apx-ui-theme">
      <AppToaster />
    </ThemeProvider>,
  );
}

beforeEach(() => {
  installLocalStorageShim();
  document.documentElement.classList.remove("light", "dark");
});

afterEach(() => {
  act(() => {
    toast.dismiss();
  });
  cleanup();
  vi.unstubAllGlobals();
  document.documentElement.classList.remove("light", "dark");
});

describe("AppToaster", () => {
  it.each(["dark", "light"] as const)("renders sonner's %s palette under the app's own theme", async (theme) => {
    renderToaster(theme);
    expect(document.documentElement.classList.contains(theme)).toBe(true);
    act(() => {
      toast("hello");
    });
    await waitFor(() => {
      expect(document.querySelector("[data-sonner-toaster]")?.getAttribute("data-sonner-theme")).toBe(theme);
    });
  });

  it.each([
    [true, "dark"],
    [false, "light"],
  ] as const)("resolves 'system' with prefers-dark=%s to %s, the same as the theme class", async (prefersDark, expected) => {
    stubPrefersDark(prefersDark);
    renderToaster("system");
    expect(document.documentElement.classList.contains(expected)).toBe(true);
    act(() => {
      toast("hello");
    });
    await waitFor(() => {
      expect(document.querySelector("[data-sonner-toaster]")?.getAttribute("data-sonner-theme")).toBe(expected);
    });
  });

  it.each(["success", "warning", "error"] as const)(
    "gives a %s toast's title and description the theme foreground in dark mode",
    async (type) => {
      renderToaster("dark");
      act(() => {
        toast[type]("TITLE", { description: "DESCRIPTION" });
      });
      await waitFor(() => expect(document.querySelector("[data-title]")).not.toBeNull());
      const toastEl = document.querySelector("[data-sonner-toast]")!;
      expect(toastEl.getAttribute("data-type")).toBe(type);
      expect(toastEl.getAttribute("data-rich-colors")).toBe("true");
      expect(document.querySelector("[data-title]")!.className).toContain("text-foreground!");
      expect(document.querySelector("[data-description]")!.className).toContain("text-foreground!");
    },
  );
});

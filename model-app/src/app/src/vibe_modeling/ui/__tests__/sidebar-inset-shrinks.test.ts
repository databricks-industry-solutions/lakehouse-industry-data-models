/**
 * SidebarInset must be allowed to shrink below its content's min-content width.
 *
 * `<main class="w-full flex-1">` has an automatic minimum width of
 * min(min-content, 100% of the wrapper). Without `min-w-0`, any page whose
 * content cannot wrap makes the main column as wide as the whole window, so the
 * page overflows horizontally by the sidebar width (256px) at every viewport.
 * jsdom has no layout, so this reads the class string.
 */
import { readFileSync } from "node:fs";
import { resolve } from "node:path";
import { describe, expect, it } from "vitest";

describe("SidebarInset", () => {
  it("declares min-w-0 so wide content scrolls inside the page instead of overflowing it", () => {
    const src = readFileSync(resolve(__dirname, "..", "components", "ui", "sidebar.tsx"), "utf8");
    const inset = src.slice(src.indexOf("const SidebarInset"), src.indexOf("SidebarInset.displayName"));
    expect(inset).toMatch(/\bmin-w-0\b/);
  });

  it("lets the header breadcrumbs shrink and truncate so a long name cannot push the header icons off screen", () => {
    const src = readFileSync(resolve(__dirname, "..", "components", "apx", "sidebar-layout.tsx"), "utf8");
    const crumbs = src.slice(src.indexOf("function HeaderBreadcrumbs"));
    expect(crumbs).toMatch(/<nav className="[^"]*\bmin-w-0\b/);
    expect(crumbs).toMatch(/\btruncate\b/);
  });
});

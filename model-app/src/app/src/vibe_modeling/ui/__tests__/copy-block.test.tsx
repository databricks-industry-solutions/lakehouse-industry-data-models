import { beforeEach, describe, expect, it, vi } from "vitest";
import { fireEvent, render, screen } from "@testing-library/react";

import { CopyBlock } from "@/components/assessment/copy-block";
import { copyToClipboard } from "@/lib/notify";

vi.mock("@/lib/notify", async (importOriginal) => ({
  ...(await importOriginal<typeof import("@/lib/notify")>()),
  copyToClipboard: vi.fn(async () => {}),
}));

const LONG = `GRANT CREATE SCHEMA, USE CATALOG ON CATALOG \`${"a_very_long_catalog_name_".repeat(6)}\` TO \`app-sp\`;`;

describe("CopyBlock", () => {
  beforeEach(() => vi.mocked(copyToClipboard).mockClear());

  it("copies the text from the button named by label", () => {
    render(<CopyBlock text={LONG} label="Copy GRANT" />);
    fireEvent.click(screen.getByRole("button", { name: "Copy GRANT" }));
    expect(copyToClipboard).toHaveBeenCalledWith(LONG);
  });

  it("defaults the accessible name to Copy SQL", () => {
    render(<CopyBlock text="select 1" />);
    expect(screen.getByRole("button", { name: "Copy SQL" })).toBeInTheDocument();
  });

  it("keeps the button beside the scrolling snippet, not over it", () => {
    render(<CopyBlock text={LONG} />);
    const button = screen.getByRole("button", { name: "Copy SQL" });
    const pre = screen.getByText(LONG);
    expect(pre.tagName).toBe("PRE");
    expect(pre.parentElement).toBe(button.parentElement);
    expect(pre.parentElement).toHaveClass("flex");
    expect(pre).toHaveClass("overflow-x-auto", "min-w-0", "flex-1");
    expect(pre.className).not.toMatch(/\bp[rl]-\d/);
    expect(button).toHaveClass("shrink-0");
    expect(button.className).not.toMatch(/\babsolute\b/);
  });
});

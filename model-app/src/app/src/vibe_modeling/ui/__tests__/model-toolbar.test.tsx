/**
 * The shared wrapping-toolbar pieces (`components/model/toolbar.tsx`) used by
 * the version page and the domain page. jsdom has no layout, so these lock the
 * class contract that lets both rows break onto a new line.
 */
import { describe, expect, it } from "vitest";
import { render, screen } from "@testing-library/react";
import { Tabs, TabsTrigger } from "@/components/ui/tabs";
import { ToolbarActions, ToolbarTabsList } from "@/components/model/toolbar";

describe("model toolbar pieces", () => {
  it("wraps the tab list and keeps its rows touching", () => {
    render(
      <Tabs value="a">
        <ToolbarTabsList>
          <TabsTrigger value="a">A</TabsTrigger>
        </ToolbarTabsList>
      </Tabs>,
    );
    const cls = screen.getByRole("tablist").className;
    for (const token of ["flex-wrap", "min-w-0", "max-w-full", "h-auto", "gap-y-0"]) {
      expect(cls).toContain(token);
    }
  });

  it("right-aligns and wraps the actions, and passes props through", () => {
    render(
      <ToolbarActions data-testid="actions">
        <button>One</button>
      </ToolbarActions>,
    );
    const cls = screen.getByTestId("actions").className;
    for (const token of ["ml-auto", "flex-wrap", "justify-end", "max-w-full"]) {
      expect(cls).toContain(token);
    }
  });
});

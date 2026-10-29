import { describe, expect, it } from "vitest";
import { liveDomainOptions } from "@/lib/domain-options";

describe("liveDomainOptions", () => {
  it("drops deleted domains and defaults a missing division to empty", () => {
    expect(
      liveDomainOptions([
        { name: "Sales", division: "Commercial", change_status: "unchanged" },
        { name: "Legacy", division: "Ops", change_status: "deleted" },
        { name: "Inventory", division: null, change_status: "added" },
        { name: "Finance" },
      ]),
    ).toEqual([
      { name: "Sales", division: "Commercial" },
      { name: "Inventory", division: "" },
      { name: "Finance", division: "" },
    ]);
  });

  it("returns an empty list for no domains", () => {
    expect(liveDomainOptions(undefined)).toEqual([]);
    expect(liveDomainOptions(null)).toEqual([]);
  });
});

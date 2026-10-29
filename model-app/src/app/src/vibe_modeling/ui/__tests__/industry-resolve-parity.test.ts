/**
 * FE half of the industry resolution contract: ``industrySlug`` and
 * ``matchingIndustries`` / ``pickIndustry`` (lib/industry.ts) give the slugs and matches of
 * tests/fixtures/industry_slug_fixture.json, as backend/industry_resolve.py
 * does (BE half: tests/test_app/test_industry_resolve.py).
 */
import { describe, expect, it } from "vitest";
import fixture from "../../../../../../tests/fixtures/industry_slug_fixture.json";
import { industrySlug, matchingIndustries, pickIndustry } from "@/lib/industry";

describe("industry resolution parity with the backend", () => {
  it.each(fixture.slugs as [string, string][])("slug %j -> %j", (text, slug) => {
    expect(industrySlug(text)).toBe(slug);
  });

  it.each(fixture.resolve as [string, string | null][])("pick %j -> %j", (text, expected) => {
    expect(pickIndustry(fixture.industries, text)?.id ?? null).toBe(expected);
  });

  it.each(fixture.candidates as [string, string[]][])("candidates %j -> %j", (text, ids) => {
    expect(matchingIndustries(fixture.industries, text).map((i) => i.id)).toEqual(ids);
  });

  it("slugs null and undefined to empty", () => {
    expect(industrySlug(null)).toBe("");
    expect(industrySlug(undefined)).toBe("");
  });
});

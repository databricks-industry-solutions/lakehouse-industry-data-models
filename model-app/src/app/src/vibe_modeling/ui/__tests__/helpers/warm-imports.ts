import { beforeAll } from "vitest";

/**
 * Pay the cost of a large route module's first import in a hook with its own
 * budget instead of inside the first test. Under a busy host the transform of
 * a route and its dependency graph runs past the default test timeout, and
 * which test is first is arbitrary. Pass loaders as `() => import("@/...")`
 * so the specifier stays a literal the bundler resolves; any vi.mock in the
 * file applies as usual.
 */
export function warmImports(...loaders: Array<() => Promise<unknown>>) {
  beforeAll(async () => {
    await Promise.all(loaders.map((load) => load()));
  }, 30_000);
}

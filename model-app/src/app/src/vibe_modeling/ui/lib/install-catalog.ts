/**
 * The catalog the run form pre-fills for a version: the UI twin of the backend
 * `core/_catalogs.resolve_install_target_catalog` without an explicit request
 * catalog. An installed version (`deployed` with an install catalog) targets
 * that catalog; `uc_catalog` mirrors its latest open install row, so a version
 * installed in several catalogs resolves to the latest. Any other version
 * (a Dry Run draft, a kickstart, an uninstalled one) targets the catalog its
 * files were written to. `""` when neither is recorded: the server then uses
 * the installation's metamodel catalog.
 *
 * Cases are shared with the backend in `tests/fixtures/install_target_catalog_fixture.json`.
 */
import type { ModelVersionOut } from "@/lib/api";

export function installTargetCatalog(
  v: Pick<ModelVersionOut, "deployment_status" | "uc_catalog" | "files_catalog"> | undefined,
): string {
  const installed = (v?.uc_catalog ?? "").trim();
  if (installed && v?.deployment_status === "deployed") return installed;
  return (v?.files_catalog ?? "").trim();
}

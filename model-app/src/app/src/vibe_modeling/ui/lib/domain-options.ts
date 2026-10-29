/** A domain as the domain dropdown (`DomainSelect`) lists it. */
export interface DomainOption {
  name: string;
  division: string;
}

/** The domains of a model summary that the dropdown offers: the deleted ones
 *  (shown on a diff) are left out. */
export function liveDomainOptions(
  domains: readonly { name: string; division?: string | null; change_status?: string | null }[] | null | undefined,
): DomainOption[] {
  return (domains ?? [])
    .filter((d) => d.change_status !== "deleted")
    .map((d) => ({ name: d.name, division: d.division ?? "" }));
}

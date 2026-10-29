import type { ReactNode } from "react";
import { Link } from "@tanstack/react-router";

/** Building blocks every help page body uses, so the pages read alike. */

export const P = "text-sm leading-relaxed text-muted-foreground";
export const UL = "list-disc space-y-1 pl-5 text-sm leading-relaxed text-muted-foreground";
export const OL = "list-decimal space-y-1 pl-5 text-sm leading-relaxed text-muted-foreground";

export function Section({ heading, children }: { heading: string; children: ReactNode }) {
  return (
    <section className="space-y-2">
      <h2 className="text-base font-semibold">{heading}</h2>
      {children}
    </section>
  );
}

/** A link to another help topic, inline in prose. */
export function TopicLink({
  slug,
  children,
  label,
}: {
  slug: string;
  children: ReactNode;
  /** Accessible name, when the visible text repeats (e.g. "Read more" per table row). */
  label?: string;
}) {
  return (
    <Link to="/help/$topic" params={{ topic: slug }} aria-label={label} className="text-primary hover:underline">
      {children}
    </Link>
  );
}

/** A plain table for reference content: a header row and text cells. */
export function HelpTable({
  label,
  columns,
  rows,
}: {
  label: string;
  columns: readonly string[];
  rows: readonly (readonly ReactNode[])[];
}) {
  return (
    <div className="overflow-x-auto rounded-sm border border-border">
      <table className="w-full text-left text-xs" aria-label={label}>
        <thead className="bg-muted text-foreground">
          <tr>
            {columns.map((c) => (
              <th key={c} scope="col" className="px-2 py-1.5 font-semibold">
                {c}
              </th>
            ))}
          </tr>
        </thead>
        <tbody className="divide-y divide-border text-muted-foreground">
          {rows.map((row, i) => (
            <tr key={i} className="align-top">
              {row.map((cell, j) => (
                <td key={j} className="px-2 py-1.5">
                  {cell}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

import { useMemo } from "react";
import { SortableTableHead, useTableSort } from "@/components/ui/sortable-table-head";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import type { GapOut } from "@/lib/api";
import { AgentText } from "./agent-text";

/** Gap registry for the run: entity, column, type, description, status, and the ask. */
export function GapTable({ gaps }: { gaps: GapOut[] }) {
  const accessors = useMemo(
    () => ({
      entity: (g: GapOut) => g.entity,
      column: (g: GapOut) => g.column,
      type: (g: GapOut) => g.gap_type,
      status: (g: GapOut) => g.status,
    }),
    [],
  );
  const { sorted, sortKey, sortDir, toggle } = useTableSort<GapOut>({ rows: gaps, accessors });
  if (gaps.length === 0) return <p className="text-sm text-muted-foreground">No gaps recorded.</p>;
  const head = { sortKey, sortDir, onToggle: toggle };
  return (
    <Table>
      <TableHeader>
        <TableRow>
          <SortableTableHead columnKey="entity" {...head}>Entity</SortableTableHead>
          <SortableTableHead columnKey="column" {...head}>Column</SortableTableHead>
          <SortableTableHead columnKey="type" {...head}>Type</SortableTableHead>
          <TableHead>Description</TableHead>
          <SortableTableHead columnKey="status" {...head}>Status</SortableTableHead>
          <TableHead>Ask</TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>
        {sorted.map((g) => (
          <TableRow key={g.id}>
            <TableCell className="font-medium">{g.entity}</TableCell>
            <TableCell>{g.column}</TableCell>
            <TableCell>{g.gap_type}</TableCell>
            <TableCell><AgentText text={g.description} /></TableCell>
            <TableCell>{g.status}</TableCell>
            <TableCell><AgentText text={g.ask} /></TableCell>
          </TableRow>
        ))}
      </TableBody>
    </Table>
  );
}

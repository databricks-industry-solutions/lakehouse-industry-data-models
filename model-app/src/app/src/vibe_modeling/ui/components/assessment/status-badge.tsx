import { Badge } from "@/components/ui/badge";
import { STATUS_LABEL } from "@/lib/assessment";
import { nextTryAt } from "@/lib/retry-time";
import { useNow } from "@/lib/use-now";

const VARIANT: Record<string, "default" | "secondary" | "destructive" | "outline"> = {
  completed: "secondary",
  failed: "destructive",
  results_invalid: "destructive",
  cancelled: "outline",
};

/** Assessment status pill; a busy (rate-limited) run also shows the attempt and its next try. */
export function StatusBadge({
  status,
  attempt,
  resumeAt,
}: {
  status: string;
  attempt?: number;
  resumeAt?: string | null;
}) {
  const busy = status === "rate_limited";
  const now = useNow(busy && Boolean(resumeAt), 30000);
  let label = STATUS_LABEL[status] ?? status;
  if (busy) {
    if (attempt) label += ` · attempt ${attempt}`;
    if (resumeAt) label += ` · ${nextTryAt(resumeAt, now)}`;
  }
  return <Badge variant={VARIANT[status] ?? "default"}>{label}</Badge>;
}

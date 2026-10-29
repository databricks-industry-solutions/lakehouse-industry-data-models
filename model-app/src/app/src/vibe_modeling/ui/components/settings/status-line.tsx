import type { ReactNode } from "react";
import { AlertTriangle, Check } from "lucide-react";

export type StatusTone = "ok" | "warn" | "error";

// Theme tokens (styles/globals.css), not fixed palette shades: each reaches
// WCAG AA (4.5:1) on both card backgrounds - light card: success 5.67,
// warning 5.50, destructive 6.61; dark card: success 6.14, warning 7.07,
// destructive 5.31. The palette shades did not (green-600 3.16 on the light
// card, red-600 3.34 on the dark card).
const TONE_CLASS: Record<StatusTone, string> = {
  ok: "text-success",
  warn: "text-warning",
  error: "text-destructive",
};

/**
 * The one-line check result under a Settings field: green check for ok,
 * amber or red triangle for a warning or a failure.
 */
export function StatusLine({
  tone,
  children,
  testId,
  id,
}: {
  tone: StatusTone;
  children: ReactNode;
  testId?: string;
  /** For the field's `aria-describedby`. */
  id?: string;
}) {
  const Icon = tone === "ok" ? Check : AlertTriangle;
  return (
    <p
      id={id}
      className={`text-xs ${TONE_CLASS[tone]} flex items-start gap-1`}
      data-testid={testId}
      data-tone={tone}
    >
      <Icon className="h-3 w-3 mt-0.5 shrink-0" />
      <span>{children}</span>
    </p>
  );
}

/** The red box under a Settings form when a save failed (multi-line text kept). */
export function SaveErrorBox({ children, testId }: { children: ReactNode; testId?: string }) {
  return (
    <div
      className="rounded-md border border-red-500/30 bg-red-500/5 p-3 text-xs flex items-start gap-2"
      data-testid={testId}
    >
      <AlertTriangle className="h-4 w-4 text-red-600 shrink-0 mt-0.5" />
      <span className="text-red-700 dark:text-red-300 whitespace-pre-wrap">{children}</span>
    </div>
  );
}

const SAVED_SIZE = {
  sm: { row: "gap-2 text-sm", icon: "h-4 w-4" },
  xs: { row: "gap-1.5 text-xs", icon: "h-3.5 w-3.5" },
} as const;

/** The green confirmation after a Settings save; `xs` for inline field rows. */
export function SavedNotice({ children, size = "sm" }: { children: ReactNode; size?: keyof typeof SAVED_SIZE }) {
  const s = SAVED_SIZE[size];
  return (
    <div className={`flex items-center ${s.row} text-success`}>
      <Check className={s.icon} />
      {children}
    </div>
  );
}

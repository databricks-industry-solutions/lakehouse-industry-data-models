import type { ReactNode } from "react";
import { Link } from "@tanstack/react-router";
import { CircleHelp } from "lucide-react";
import { cn } from "@/lib/utils";

/** Padding around the 14 px icon to a 24 px square, offset by an equal negative margin. */
export const ICON_ONLY_HIT_TARGET = "-m-[5px] p-[5px] justify-center";

/**
 * A link from a working screen to a help topic: a help icon, with visible
 * text when `children` is given. Icon-only links need `label`, their
 * accessible name.
 */
export function HelpLink({
  topic,
  children,
  label,
  className,
}: {
  topic: string;
  children?: ReactNode;
  label?: string;
  className?: string;
}) {
  return (
    <Link
      to="/help/$topic"
      params={{ topic }}
      aria-label={children ? undefined : label}
      title={label}
      data-testid={`help-link-${topic}`}
      className={cn(
        "inline-flex items-center gap-1 text-xs font-normal text-primary underline-offset-2 hover:underline",
        // An icon-only link gets a 24x24 px hit target; the negative margin keeps the layout.
        !children && ICON_ONLY_HIT_TARGET,
        className,
      )}
    >
      <CircleHelp className="h-3.5 w-3.5 shrink-0" aria-hidden />
      {children}
    </Link>
  );
}

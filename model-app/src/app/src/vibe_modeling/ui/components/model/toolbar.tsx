import type { ComponentProps } from "react";
import { TabsList } from "@/components/ui/tabs";
import { cn } from "@/lib/utils";

/**
 * Building blocks of the model pages' wrapping toolbar (the version page's
 * `ModelView` and the domain page). Both rows must break onto a new line
 * instead of widening the page: the tab list wraps its tabs (rows touch, so
 * the one bottom border reads as a single block) and the actions cluster
 * right-aligns, wraps, and drops to its own line when the tabs leave no room.
 */
export function ToolbarTabsList({ className, ...props }: ComponentProps<typeof TabsList>) {
  return <TabsList className={cn("h-auto min-w-0 max-w-full flex-wrap gap-y-0", className)} {...props} />;
}

export function ToolbarActions({ className, ...props }: ComponentProps<"div">) {
  return (
    <div
      className={cn("ml-auto flex max-w-full flex-wrap items-center justify-end gap-2", className)}
      {...props}
    />
  );
}

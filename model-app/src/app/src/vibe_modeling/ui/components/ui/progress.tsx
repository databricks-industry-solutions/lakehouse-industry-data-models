"use client"

import * as React from "react"
import * as ProgressPrimitive from "@radix-ui/react-progress"

import { cn } from "@/lib/utils"

const Progress = React.forwardRef<
  React.ElementRef<typeof ProgressPrimitive.Root>,
  React.ComponentPropsWithoutRef<typeof ProgressPrimitive.Root>
>(({ className, value, ...props }, ref) => (
  <ProgressPrimitive.Root
    ref={ref}
    value={value}
    className={cn(
      // Thinner, squarer bar — DESIGN.md eschews pill-shaped UI.
      // Light mode: a darker-gold hairline bounds the track so the gold fill
      // clears WCAG 1.4.11 (3:1) against the near-white card; dark mode passes
      // on the fill alone, so the border is light-scoped.
      "relative h-1.5 w-full overflow-hidden rounded-sm bg-muted [.light_&]:border [.light_&]:border-[oklch(0.58_0.13_88)]",
      className
    )}
    {...props}
  >
    <ProgressPrimitive.Indicator
      className="h-full w-full flex-1 bg-tertiary transition-all [.light_&]:border-r [.light_&]:border-[oklch(0.58_0.13_88)]"
      style={{ transform: `translateX(-${100 - (value || 0)}%)` }}
    />
  </ProgressPrimitive.Root>
))
Progress.displayName = ProgressPrimitive.Root.displayName

export { Progress }

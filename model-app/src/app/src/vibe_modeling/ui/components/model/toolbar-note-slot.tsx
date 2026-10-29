import { createContext, useContext, useState, type ReactNode } from "react";
import { createPortal } from "react-dom";

/**
 * A full-width line under the model page's tab bar, for a note that belongs
 * to a tab-bar action (the Delete reason) but must not widen the tab bar.
 * `ModelTabsShell` renders the line and provides it; `ToolbarNote` portals
 * into it, and renders in place when no line is provided (a standalone
 * component, tests).
 */
const ToolbarNoteSlotContext = createContext<HTMLElement | null>(null);

export function useToolbarNoteSlot(): {
  slot: ReactNode;
  provide: (children: ReactNode) => ReactNode;
} {
  const [el, setEl] = useState<HTMLDivElement | null>(null);
  return {
    slot: <div ref={setEl} className="flex justify-end empty:hidden" data-testid="toolbar-note-slot" />,
    provide: (children) => (
      <ToolbarNoteSlotContext.Provider value={el}>{children}</ToolbarNoteSlotContext.Provider>
    ),
  };
}

export function ToolbarNote({ children }: { children: ReactNode }) {
  const el = useContext(ToolbarNoteSlotContext);
  return el ? createPortal(children, el) : <>{children}</>;
}

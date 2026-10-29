import { Copy } from "lucide-react";
import { Button } from "@/components/ui/button";
import { copyToClipboard } from "@/lib/notify";

/** A code/SQL snippet with a copy-to-clipboard button; shared by the readiness
 *  panel, the assessment setup checklist in Settings → Platform and the deployment catalog picker.
 *  The button sits beside the scrolling snippet, so a long line never runs under it. */
export function CopyBlock({ text, label = "Copy SQL" }: { text: string; label?: string }) {
  return (
    <div className="flex items-start gap-1 rounded-md border bg-muted/40">
      <pre className="min-w-0 flex-1 overflow-x-auto p-2 text-xs">{text}</pre>
      <Button
        type="button"
        variant="ghost"
        size="icon"
        className="m-1 h-6 w-6 shrink-0"
        aria-label={label}
        onClick={() => void copyToClipboard(text)}
      >
        <Copy className="h-3.5 w-3.5" />
      </Button>
    </div>
  );
}

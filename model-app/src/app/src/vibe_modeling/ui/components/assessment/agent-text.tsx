import { Fragment } from "react";
import { INLINE_CODE_CLASS } from "@/components/ui/markdown-view";

const CODE_SPAN = /`([^`\n]+)`/;
const CODE_SPANS = new RegExp(CODE_SPAN.source, "g");

/** Agent prose with its backticks dropped, for accessible names (the visible text shows the span as code). */
export function plainAgentText(text: string): string {
  return text.replace(CODE_SPANS, "$1");
}

/**
 * Inline agent prose with its `backtick` spans rendered as inline code, in the
 * MarkdownView code style. Only backticks are interpreted: the rest stays plain
 * text, so an unpaired backtick is shown as written.
 */
export function AgentText({ text }: { text: string | null | undefined }) {
  if (!text) return null;
  // split() with a capture group puts the code spans at the odd indices.
  const parts = text.split(CODE_SPAN);
  return (
    <>
      {parts.map((part, i) =>
        i % 2 === 1 ? (
          <code key={i} className={INLINE_CODE_CLASS}>
            {part}
          </code>
        ) : (
          <Fragment key={i}>{part}</Fragment>
        ),
      )}
    </>
  );
}

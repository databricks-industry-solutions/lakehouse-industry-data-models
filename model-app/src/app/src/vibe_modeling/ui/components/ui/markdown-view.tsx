import type { ComponentProps } from "react";
import ReactMarkdown from "react-markdown";
import remarkGfm from "remark-gfm";
import rehypeSlug from "rehype-slug";
import { cn } from "@/lib/utils";

/** Inline code spans: shared by MarkdownView and plain agent text (`components/assessment/agent-text.tsx`). Never below the 11px of block code. */
export const INLINE_CODE_CLASS = "bg-muted/70 rounded-sm px-1 py-0.5 font-mono text-[max(0.9em,11px)]";

/**
 * The single styled Markdown renderer for the app (GFM tables/strikethrough +
 * slugged headings + a consistent component map). Extracted from the Artifacts
 * tab so every read-only Markdown surface (artifact previews, the business
 * detailed description, …) renders identically — no per-site ReactMarkdown
 * drift.
 */
const MARKDOWN_COMPONENTS = {
  h1: (props: ComponentProps<"h1">) => (
    <h1 className="text-base font-semibold mt-3 mb-2 first:mt-0 scroll-m-20" {...props} />
  ),
  h2: (props: ComponentProps<"h2">) => (
    <h2 className="text-sm font-semibold mt-3 mb-1.5 first:mt-0 scroll-m-20" {...props} />
  ),
  h3: (props: ComponentProps<"h3">) => (
    <h3 className="text-xs font-semibold mt-2 mb-1 first:mt-0 scroll-m-20" {...props} />
  ),
  p: (props: ComponentProps<"p">) => <p className="my-1.5 leading-relaxed" {...props} />,
  ul: (props: ComponentProps<"ul">) => (
    <ul className="list-disc pl-5 my-1.5 space-y-0.5" {...props} />
  ),
  ol: (props: ComponentProps<"ol">) => (
    <ol className="list-decimal pl-5 my-1.5 space-y-0.5" {...props} />
  ),
  a: ({ href, ...props }: ComponentProps<"a">) => {
    const isAnchor = typeof href === "string" && href.startsWith("#");
    return (
      <a
        href={href}
        className="text-primary underline hover:no-underline"
        {...(isAnchor ? {} : { target: "_blank", rel: "noreferrer" })}
        {...props}
      />
    );
  },
  code: ({ className, children, ...props }: ComponentProps<"code"> & { className?: string }) => {
    const isBlock = /language-/.test(className ?? "");
    return isBlock ? (
      <code
        className="block bg-muted/70 rounded-sm px-2 py-1 font-mono text-[11px] overflow-x-auto"
        {...props}
      >
        {children}
      </code>
    ) : (
      <code className={INLINE_CODE_CLASS} {...props}>
        {children}
      </code>
    );
  },
  pre: (props: ComponentProps<"pre">) => (
    <pre className="bg-muted/70 rounded-sm p-2 my-2 overflow-x-auto text-[11px] leading-snug" {...props} />
  ),
  blockquote: (props: ComponentProps<"blockquote">) => (
    <blockquote className="border-l-2 border-border pl-3 italic text-muted-foreground my-2" {...props} />
  ),
  table: (props: ComponentProps<"table">) => (
    <div className="overflow-x-auto my-2">
      <table className="border-collapse text-[11px] w-full" {...props} />
    </div>
  ),
  th: (props: ComponentProps<"th">) => (
    <th className="border border-border px-2 py-1 text-left font-semibold bg-muted/40" {...props} />
  ),
  td: (props: ComponentProps<"td">) => <td className="border border-border px-2 py-1 align-top" {...props} />,
  hr: (props: ComponentProps<"hr">) => <hr className="my-4 border-border" {...props} />,
};

export interface MarkdownViewProps {
  content: string;
  /** Wrapper classes (sizing / overflow). Defaults to the artifact-preview look. */
  className?: string;
  /** Return true to handle a link click in-app (the default navigation is suppressed). */
  onLinkClick?: (href: string) => boolean;
}

export function MarkdownView({ content, className, onLinkClick }: MarkdownViewProps) {
  const components = onLinkClick
    ? {
        ...MARKDOWN_COMPONENTS,
        a: ({ href, ...props }: ComponentProps<"a">) => {
          const A = MARKDOWN_COMPONENTS.a;
          return (
            <A
              href={href}
              {...props}
              onClick={(e) => {
                if (href && onLinkClick(href)) e.preventDefault();
              }}
            />
          );
        },
      }
    : MARKDOWN_COMPONENTS;
  return (
    <div className={cn("text-xs leading-relaxed text-foreground", className)}>
      <ReactMarkdown
        remarkPlugins={[remarkGfm]}
        rehypePlugins={[rehypeSlug]}
        components={components}
      >
        {content}
      </ReactMarkdown>
    </div>
  );
}

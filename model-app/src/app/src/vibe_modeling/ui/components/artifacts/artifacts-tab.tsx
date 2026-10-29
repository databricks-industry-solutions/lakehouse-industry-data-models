import { Suspense, useMemo, useState } from "react";
import { QueryErrorResetBoundary, useQuery } from "@tanstack/react-query";
import { ErrorBoundary } from "react-error-boundary";
import { MarkdownView } from "@/components/ui/markdown-view";
import {
  useListArtifactsSuspense,
  useListArtifactsByVersionSuspense,
  getArtifactContent,
  getArtifactContentByVersion,
  type RunArtifactOut,
} from "@/lib/api";
import { apiErrorMessage } from "@/lib/api-error";
import { selector } from "@/lib/selector";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import {
  Download,
  FileCode,
  ChevronDown,
  ChevronRight,
  Archive,
  FileImage,
  FileText,
  FileSpreadsheet,
  Binary,
} from "lucide-react";
import { HighlightedText, type HighlightLanguage } from "./highlighted-text";
import { ExcelPreview } from "./excel-preview";

export type ArtifactsTabProps =
  | { businessId: string; runId: string; modelVersionId?: never }
  | { businessId: string; modelVersionId: string; runId?: never };

export function ArtifactsTab(props: ArtifactsTabProps) {
  return (
    <QueryErrorResetBoundary>
      {({ reset }) => (
        <ErrorBoundary
          onReset={reset}
          fallbackRender={({ error, resetErrorBoundary }) => (
            <Card className="border-destructive/40 bg-destructive/5">
              <CardContent className="py-4 space-y-2">
                <p className="text-sm text-destructive">
                  Failed to load artifacts: {apiErrorMessage(error, String(error))}
                </p>
                <Button size="sm" variant="outline" onClick={resetErrorBoundary}>
                  Try again
                </Button>
              </CardContent>
            </Card>
          )}
        >
          <Suspense fallback={<Skeleton className="h-48 w-full" />}>
            <ArtifactsTabContent {...props} />
          </Suspense>
        </ErrorBoundary>
      )}
    </QueryErrorResetBoundary>
  );
}

function ArtifactsTabContent(props: ArtifactsTabProps) {
  if ("modelVersionId" in props && props.modelVersionId) {
    return (
      <VersionScopedList
        businessId={props.businessId}
        modelVersionId={props.modelVersionId}
      />
    );
  }
  if ("runId" in props && props.runId) {
    return <RunScopedList businessId={props.businessId} runId={props.runId} />;
  }
  return null;
}

function RunScopedList({ businessId, runId }: { businessId: string; runId: string }) {
  const { data: artifacts } = useListArtifactsSuspense({
    params: { business_id: businessId, run_id: runId },
    ...selector<RunArtifactOut[]>(),
  });
  return (
    <ArtifactsList
      artifacts={artifacts}
      businessId={businessId}
      downloadHref={`/api/businesses/${businessId}/runs/${runId}/artifacts/download`}
      downloadFilename={`run-${runId.slice(0, 8)}-artifacts.zip`}
      emptyLabel="No artifacts were produced for this run."
    />
  );
}

function VersionScopedList({
  businessId,
  modelVersionId,
}: {
  businessId: string;
  modelVersionId: string;
}) {
  const { data: artifacts } = useListArtifactsByVersionSuspense({
    params: { business_id: businessId, model_version_id: modelVersionId },
    ...selector<RunArtifactOut[]>(),
  });
  return (
    <ArtifactsList
      artifacts={artifacts}
      businessId={businessId}
      downloadHref={`/api/businesses/${businessId}/model-versions/${modelVersionId}/artifacts/download`}
      downloadFilename={`model-version-${modelVersionId.slice(0, 8)}-artifacts.zip`}
      emptyLabel="No artifacts were indexed for this model version."
    />
  );
}

function ArtifactsList({
  artifacts,
  downloadHref,
  downloadFilename,
  emptyLabel,
  businessId,
}: {
  artifacts: RunArtifactOut[];
  downloadHref: string | undefined;
  downloadFilename: string;
  emptyLabel: string;
  /** Threaded into every ArtifactRow for the per-artifact preview/download
   *  URLs (the per-artifact endpoints are nested under businesses, so the
   *  ID is required regardless of whether the list itself was scoped to
   *  a run or a model version). */
  businessId: string;
}) {
  if (!artifacts.length) {
    return (
      <Card>
        <CardContent className="py-6 text-sm text-muted-foreground">
          {emptyLabel}
        </CardContent>
      </Card>
    );
  }

  const byType: Record<string, RunArtifactOut[]> = {};
  for (const a of artifacts) {
    (byType[a.artifact_type || "other"] ??= []).push(a);
  }

  return (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between gap-2 space-y-0">
        <CardTitle className="flex items-center gap-2">
          <FileCode className="h-5 w-5" />
          Artifacts ({artifacts.length})
        </CardTitle>
        {downloadHref && (
          <Button asChild size="sm" variant="outline">
            <a href={downloadHref} download={downloadFilename}>
              <Archive className="h-4 w-4 mr-2" />
              Download all (zip)
            </a>
          </Button>
        )}
      </CardHeader>
      <CardContent className="space-y-4">
        {Object.entries(byType).map(([type, items]) => (
          <div key={type}>
            <h4 className="text-xs font-semibold text-muted-foreground uppercase tracking-wider mb-2">
              {type} ({items.length})
            </h4>
            <ul className="space-y-1">
              {items.map((a) => (
                <ArtifactRow
                  key={a.id}
                  businessId={businessId}
                  runId={a.run_id ?? null}
                  modelVersionId={a.model_version_id ?? null}
                  artifactId={a.id}
                  filePath={a.file_path}
                />
              ))}
            </ul>
          </div>
        ))}
      </CardContent>
    </Card>
  );
}

function fileSuffix(path: string): string {
  if (!path || !path.includes(".")) return "";
  return path.split(".").pop()?.toLowerCase() ?? "";
}

function fileName(path: string): string {
  if (!path) return "artifact";
  const name = path.split("/").pop() ?? path;
  return name || "artifact";
}

type ArtifactPreviewKind =
  | "markdown"
  | "json"
  | "html"
  | "text"
  | "image"
  | "pdf"
  | "excel"
  | "binary";

const TURTLE_FAMILY = new Set([
  "ttl",
  "nt",
  "nq",
  "n3",
  "trig",
  "rdf",
  "owl",
  "shex",
  "shacl",
]);

function classifyArtifactPreview(suffix: string): ArtifactPreviewKind {
  const s = suffix.toLowerCase();
  if (s === "pdf") return "pdf";
  if (["png", "jpg", "jpeg", "gif", "webp", "bmp", "ico", "svg", "tif", "tiff"].includes(s)) {
    return "image";
  }
  if (["xlsx", "xls", "xlsm", "xlsb"].includes(s)) return "excel";
  if (s === "json" || s === "jsonl" || s === "ndjson" || s === "jsonld") return "json";
  if (s === "md" || s === "mdx") return "markdown";
  if (s === "html" || s === "htm") return "html";
  if (
    [
      "txt",
      "sql",
      "csv",
      "tsv",
      "yml",
      "yaml",
      "xml",
      "toml",
      "ini",
      "cfg",
      "conf",
      "properties",
      "env",
      "rst",
      "ipynb",
      "graphql",
      "gql",
      "log",
      "py",
      "pyi",
      "pyw",
      "ts",
      "tsx",
      "jsx",
      "mjs",
      "cjs",
      "js",
      "css",
      "scss",
      "sass",
      "less",
      "vue",
      "svelte",
      "rs",
      "go",
      "rb",
      "java",
      "kt",
      "scala",
      "php",
      "pl",
      "pm",
      "r",
      "c",
      "h",
      "cpp",
      "cc",
      "cxx",
      "hpp",
      "hh",
      "cs",
      "swift",
      "sh",
      "bash",
      "zsh",
      "ps1",
      "bat",
      "cmd",
      "tf",
      "hcl",
      "gradle",
      "lock",
      "cmake",
      "mk",
      "dockerignore",
      "editorconfig",
      "gitattributes",
      "feature",
      "dart",
      "ex",
      "exs",
      "erl",
      "hs",
      "lhs",
      "ml",
      "mli",
      "fs",
      "fsx",
      "clj",
      "cljs",
      "edn",
      "lua",
      "vim",
      "proto",
      "avsc",
      "wsdl",
      "xsl",
      "ttl",
      "rdf",
      "nt",
      "nq",
      "n3",
      "trig",
      "owl",
      "shex",
      "shacl",
    ].includes(s)
  ) {
    return "text";
  }
  return "binary";
}

function inlinePreviewUrl(
  businessId: string,
  runId: string | null,
  modelVersionId: string | null,
  artifactId: string,
): string {
  if (runId !== null) {
    return `/api/businesses/${businessId}/runs/${runId}/artifacts/${artifactId}/download?inline=1`;
  }
  return `/api/businesses/${businessId}/model-versions/${modelVersionId}/artifacts/${artifactId}/download?inline=1`;
}

function highlightLanguageForSuffix(suffix: string): HighlightLanguage | null {
  const s = suffix.toLowerCase();
  if (s === "sql") return "sql";
  if (TURTLE_FAMILY.has(s)) return "turtle";
  if (s === "py" || s === "pyi" || s === "pyw") return "python";
  if (s === "yml" || s === "yaml") return "yaml";
  return null;
}

function tryPrettyJson(raw: string): string | null {
  const t = raw.trim();
  if (!t.length) return null;
  try {
    return JSON.stringify(JSON.parse(t), null, 2);
  } catch {
    return null;
  }
}

function TextPreviewBody({ content, label }: { content: string; label?: string }) {
  return (
    <div className="space-y-1">
      {label && <p className="text-[10px] text-muted-foreground font-medium uppercase tracking-wide">{label}</p>}
      <pre className="text-xs whitespace-pre-wrap wrap-break-word max-h-[min(28rem,70vh)] overflow-auto font-mono leading-relaxed bg-muted/40 border border-border/60 rounded-md p-4 text-foreground/95">
        {content}
      </pre>
    </div>
  );
}

function ArtifactRow({
  businessId,
  runId,
  modelVersionId,
  artifactId,
  filePath,
}: {
  businessId: string;
  // Exactly one of runId / modelVersionId is set. Agent-produced runs
  // pass runId (preview hits the run-scoped endpoint); imported model
  // versions pass modelVersionId (preview hits the version-scoped
  // endpoint introduced in this commit). Both surface routes proxy to
  // the same shared `_artifact_io` reader so behaviour is identical.
  runId: string | null;
  modelVersionId: string | null;
  artifactId: string;
  filePath: string;
}) {
  const [expanded, setExpanded] = useState(false);
  const suffix = fileSuffix(filePath);
  const name = fileName(filePath);
  const kind = useMemo(() => classifyArtifactPreview(suffix), [suffix]);

  const usesTextApi = kind === "markdown" || kind === "json" || kind === "html" || kind === "text";
  const usesHexApi = kind === "binary";
  const highlightLanguage = kind === "text" ? highlightLanguageForSuffix(suffix) : null;

  const fetchContent = (format: "text" | "hex") => {
    if (runId !== null) {
      return getArtifactContent({
        business_id: businessId,
        run_id: runId,
        artifact_id: artifactId,
        format,
      });
    }
    return getArtifactContentByVersion({
      business_id: businessId,
      model_version_id: modelVersionId as string,
      artifact_id: artifactId,
      format,
    });
  };

  const queryScope = runId ?? modelVersionId ?? artifactId;

  const textQuery = useQuery({
    queryKey: ["artifact-content", businessId, queryScope, artifactId, "text"],
    queryFn: () => fetchContent("text"),
    enabled: expanded && usesTextApi,
    retry: false,
  });

  const hexQuery = useQuery({
    queryKey: ["artifact-content", businessId, queryScope, artifactId, "hex"],
    queryFn: () => fetchContent("hex"),
    enabled: expanded && usesHexApi,
    retry: false,
  });

  const textPayload = textQuery.data?.data as
    | { content: string; truncated: boolean; size_bytes: number }
    | undefined;
  const hexPayload = hexQuery.data?.data as
    | { hex: string; size_bytes: number; bytes_previewed: number; truncated: boolean }
    | undefined;

  const kindLabel =
    kind === "pdf"
      ? "PDF"
      : kind === "image"
        ? "Image"
        : kind === "markdown"
          ? "Markdown"
          : kind === "html"
            ? "HTML"
            : kind === "json"
              ? "JSON"
              : kind === "excel"
                ? "Spreadsheet"
                : kind === "text"
                  ? "Text"
                  : "Binary";

  const Icon =
    kind === "pdf" || kind === "image"
      ? FileImage
      : kind === "excel"
        ? FileSpreadsheet
        : kind === "binary"
          ? Binary
          : FileText;

  return (
    <li className="border border-border rounded-md overflow-hidden bg-card/30">
      <div className="flex items-stretch">
        <button
          type="button"
          onClick={() => setExpanded((v) => !v)}
          className="flex-1 flex items-center gap-2 px-2 py-1.5 text-left hover:bg-muted/50 transition-colors"
          aria-expanded={expanded}
          aria-label={expanded ? `Collapse preview for ${name}` : `Expand preview for ${name}`}
        >
          {expanded ? (
            <ChevronDown className="h-3.5 w-3.5 shrink-0 text-muted-foreground" />
          ) : (
            <ChevronRight className="h-3.5 w-3.5 shrink-0 text-muted-foreground" />
          )}
          <Icon className="h-3.5 w-3.5 shrink-0 text-muted-foreground" aria-hidden />
          <span className="text-xs font-medium truncate">{name}</span>
          <span className="text-[10px] text-muted-foreground uppercase shrink-0">{suffix || "file"}</span>
          <span className="text-[10px] text-muted-foreground/80 hidden sm:inline ml-auto shrink-0">
            {kindLabel}
          </span>
          <span className="text-[10px] font-mono break-all text-muted-foreground/60 hidden lg:inline max-w-[40%] truncate text-right">
            {filePath}
          </span>
        </button>
        <a
          href={
            runId !== null
              ? `/api/businesses/${businessId}/runs/${runId}/artifacts/${artifactId}/download`
              : `/api/businesses/${businessId}/model-versions/${modelVersionId}/artifacts/${artifactId}/download`
          }
          download={name}
          className="flex items-center gap-1 px-3 border-l border-border text-xs text-muted-foreground hover:bg-muted/50 hover:text-foreground transition-colors shrink-0"
          title={`Download ${name}`}
          aria-label={`Download ${name}`}
        >
          <Download className="h-3.5 w-3.5" />
        </a>
      </div>
      {expanded && (
        <div className="border-t border-border px-3 py-3 bg-muted/20 space-y-2">
          {kind === "pdf" && (
            <div className="space-y-2">
              <p className="text-[11px] text-muted-foreground">
                PDF preview (embedded). Use Download for the full file.
              </p>
              <iframe
                title={`Preview ${name}`}
                className="w-full min-h-[min(32rem,75vh)] rounded-md border border-border bg-background"
                src={inlinePreviewUrl(businessId, runId, modelVersionId, artifactId)}
              />
            </div>
          )}
          {kind === "image" && (
            <div className="space-y-2 flex flex-col items-center">
              <p className="text-[11px] text-muted-foreground w-full">Image preview</p>
              <img
                src={inlinePreviewUrl(businessId, runId, modelVersionId, artifactId)}
                alt={name}
                className="max-w-full max-h-[min(28rem,70vh)] object-contain rounded-md border border-border bg-background"
              />
            </div>
          )}
          {kind === "excel" && (
            <ExcelPreview
              src={inlinePreviewUrl(businessId, runId, modelVersionId, artifactId)}
              filename={name}
            />
          )}
          {usesTextApi && (
            <>
              {textQuery.isLoading && <Skeleton className="h-40 w-full rounded-md" />}
              {textQuery.isError && (
                <p className="text-xs text-destructive">
                  Could not load preview:{" "}
                  {textQuery.error instanceof Error ? textQuery.error.message : "unknown error"}
                </p>
              )}
              {textPayload && (
                <>
                  {textPayload.truncated && (
                    <p className="text-[10px] text-warning">
                      Preview truncated at ~500 KB of {(textPayload.size_bytes / 1024).toFixed(1)} KB total
                    </p>
                  )}
                  {kind === "markdown" && (
                    <MarkdownView
                      content={textPayload.content}
                      className="max-h-[min(28rem,70vh)] overflow-auto px-1"
                    />
                  )}
                  {kind === "json" && (
                    <>
                      {(() => {
                        const pretty = tryPrettyJson(textPayload.content);
                        if (pretty) {
                          return (
                            <HighlightedText
                              language="json"
                              source={pretty}
                              label="Formatted JSON"
                            />
                          );
                        }
                        return (
                          <TextPreviewBody
                            content={textPayload.content}
                            label="JSON (raw)"
                          />
                        );
                      })()}
                    </>
                  )}
                  {kind === "html" && (
                    <div className="space-y-1">
                      <p className="text-[10px] text-muted-foreground">
                        Rendered in a sandboxed frame (scripts and top navigation are restricted).
                      </p>
                      <iframe
                        title={`HTML preview ${name}`}
                        className="w-full min-h-[min(24rem,65vh)] rounded-md border border-border bg-background"
                        sandbox=""
                        srcDoc={textPayload.content}
                      />
                    </div>
                  )}
                  {kind === "text" &&
                    (highlightLanguage ? (
                      <HighlightedText
                        language={highlightLanguage}
                        source={textPayload.content}
                      />
                    ) : (
                      <TextPreviewBody content={textPayload.content} />
                    ))}
                </>
              )}
            </>
          )}
          {usesHexApi && (
            <>
              {hexQuery.isLoading && <Skeleton className="h-32 w-full rounded-md" />}
              {hexQuery.isError && (
                <p className="text-xs text-destructive">
                  Could not load hex preview:{" "}
                  {hexQuery.error instanceof Error ? hexQuery.error.message : "unknown error"}
                </p>
              )}
              {hexPayload && (
                <div className="space-y-2">
                  <p className="text-[11px] text-muted-foreground">
                    Binary file — first {hexPayload.bytes_previewed} byte(s) as hex
                    {hexPayload.truncated ? " (file continues beyond preview)" : ""}. Total size{" "}
                    {(hexPayload.size_bytes / 1024).toFixed(1)} KB. Download to open in an external tool.
                  </p>
                  <pre className="text-[11px] font-mono whitespace-pre-wrap wrap-break-word max-h-[min(20rem,50vh)] overflow-auto bg-muted/50 border border-border rounded-md p-3 leading-snug">
                    {hexPayload.hex}
                  </pre>
                </div>
              )}
            </>
          )}
        </div>
      )}
    </li>
  );
}

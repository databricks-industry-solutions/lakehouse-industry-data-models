/**
 * The one agent status line above the Agent Configuration form (add §8.3,
 * base §4 Settings card): which agent the configured notebook is, who owns it,
 * when the app last checked it, and how it stands against upstream.
 *
 * - App-owned notebook (`agent_owner` "app"): the app upgrades it with each
 *   app upgrade; there is no stored upgrade date, so the line shows
 *   `installed_checked_at` as "last checked".
 * - Admin-owned notebook: the gap to the bundled agent and "Switch to bundled"
 *   (`switchToBundledAgent`, AdminOnly; the tab is admin-gated).
 * - No notebook: "Use the bundled agent", the same switch.
 *
 * Upstream (`verdict`): up to date, a newer build (informational), or a newer
 * release that needs a newer app (warning, with the known breaking changes).
 */
import { useState } from "react";
import { useQueryClient } from "@tanstack/react-query";
import { AlertTriangle, Check } from "lucide-react";
import { toast } from "sonner";
import {
  getAgentCompatKey,
  getAgentConfigKey,
  switchToBundledAgent,
  useGetAgentCompat,
  type AgentCompatOut,
} from "@/lib/api";
import { formatRelative } from "@/lib/date";
import { agentReadyQueryKey } from "@/lib/hooks";
import { notifyError } from "@/lib/notify";
import { Button } from "@/components/ui/button";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog";

type Tone = "ok" | "warn";

export interface AgentStatus {
  tone: Tone;
  /** What the configured notebook is and who owns it. */
  identity: string;
  /** How it stands against upstream; null when unknown. */
  upstream: string | null;
  /** "Last checked 5 minutes ago", or null when never checked. */
  checked: string | null;
  /** Offer the switch: admin-owned or no notebook. */
  offerSwitch: boolean;
  switchLabel: string;
}

/** The line's text for an `AgentCompatOut` (pure, for tests). */
export function agentStatus(info: AgentCompatOut, hasNotebook: boolean): AgentStatus {
  const bundled = info.pinned_agent_marker || info.bundled_agent_marker || info.pinned_version;
  const release = info.installed_release_version;
  const marker = info.installed_agent_version;
  const name = [release, marker && marker !== release ? `(build ${marker})` : null]
    .filter(Boolean)
    .join(" ");
  let tone: Tone = "ok";
  let identity: string;
  let offerSwitch = false;
  if (!hasNotebook) {
    tone = "warn";
    identity = "No agent notebook is configured.";
    offerSwitch = true;
  } else if (info.agent_owner === "app") {
    identity = `Agent ${name || bundled}, managed by this app: it is upgraded with each app upgrade.`;
  } else {
    offerSwitch = true;
    const gap =
      info.installed_vs_bundled === "same"
        ? "the same as the bundled agent"
        : info.installed_vs_bundled === "older"
          ? `older than the bundled ${bundled}`
          : info.installed_vs_bundled === "newer"
            ? `newer than the bundled ${bundled}`
            : `not compared with the bundled ${bundled}`;
    if (info.installed_vs_bundled !== "same" && info.installed_vs_bundled !== "newer") tone = "warn";
    identity = `Your own notebook${name ? ` (agent ${name})` : ""}, ${gap}. The app does not upgrade it.`;
  }
  if (info.installed_check_error) tone = "warn";

  let upstream: string | null = null;
  if (info.verdict === "release_incompatible") {
    tone = "warn";
    upstream = `Upstream released agent ${info.latest_upstream_release ?? info.latest_known_upstream}; using it needs a newer version of this app.`;
  } else if (info.verdict === "build_update_available") {
    upstream = `A newer upstream build${info.latest_upstream_marker ? ` (${info.latest_upstream_marker})` : ""} exists for this release; no action needed.`;
  } else if (info.verdict === "up_to_date") {
    upstream = "Up to date with upstream.";
  }

  const at = info.installed_checked_at;
  return {
    tone,
    identity,
    upstream,
    checked: at ? `Last checked ${formatRelative(at)}.` : null,
    offerSwitch,
    switchLabel: hasNotebook ? `Switch to bundled ${bundled}` : `Use the bundled agent ${bundled}`,
  };
}

export function AgentStatusRow({
  hasNotebook,
  onSwitched,
}: {
  /** A notebook path is saved. */
  hasNotebook: boolean;
  /** After a switch, with the new notebook path. */
  onSwitched?: (path: string) => void;
}) {
  const queryClient = useQueryClient();
  const { data, isError } = useGetAgentCompat({ query: { retry: false, staleTime: 60_000 } });
  const [confirmOpen, setConfirmOpen] = useState(false);
  const [switching, setSwitching] = useState(false);
  // Advisory: the form still works without it.
  if (isError || !data) return null;
  const info = data.data;
  const status = agentStatus(info, hasNotebook);
  const Icon = status.tone === "ok" ? Check : AlertTriangle;
  const breaking = info.verdict === "release_incompatible" ? info.known_breaking_changes ?? [] : [];

  const doSwitch = async () => {
    setSwitching(true);
    try {
      const res = await switchToBundledAgent();
      await Promise.all([
        queryClient.invalidateQueries({ queryKey: getAgentConfigKey() }),
        queryClient.invalidateQueries({ queryKey: getAgentCompatKey() }),
        queryClient.invalidateQueries({ queryKey: agentReadyQueryKey() }),
      ]);
      toast.success("The agent now runs the bundled notebook.");
      onSwitched?.(res.data.notebook_path);
      setConfirmOpen(false);
    } catch (err) {
      notifyError(err, { title: "Switch to the bundled agent failed" });
    } finally {
      setSwitching(false);
    }
  };

  return (
    <div
      data-testid="agent-status-row"
      data-tone={status.tone}
      role={status.tone === "warn" ? "status" : undefined}
      className={`mb-4 flex flex-wrap items-start gap-x-3 gap-y-2 rounded-md border px-3 py-2 text-xs ${
        status.tone === "warn" ? "border-warning/40 bg-warning/5" : "border-border"
      }`}
    >
      <Icon
        className={`mt-0.5 h-4 w-4 shrink-0 ${status.tone === "warn" ? "text-warning" : "text-success"}`}
        aria-hidden
      />
      <div className="min-w-0 flex-1 space-y-0.5">
        <p className="text-foreground">
          {status.identity}
          {status.upstream && <> {status.upstream}</>}
          {status.checked && <span className="text-muted-foreground"> {status.checked}</span>}
        </p>
        {info.installed_check_error && (
          <p className="text-warning">The last check failed: {info.installed_check_error}</p>
        )}
        {breaking.length > 0 && (
          <ul className="list-disc pl-4 text-muted-foreground">
            {breaking.map((c, i) => (
              <li key={`${c.tag}-${c.area}-${i}`}>
                <span className="font-mono">{c.tag}</span> [{c.area}] {c.summary}
              </li>
            ))}
          </ul>
        )}
      </div>
      {status.offerSwitch && (
        <Button size="sm" variant="outline" onClick={() => setConfirmOpen(true)} data-testid="switch-to-bundled">
          {status.switchLabel}
        </Button>
      )}
      <AlertDialog open={confirmOpen} onOpenChange={(o) => !switching && setConfirmOpen(o)}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>{status.switchLabel}?</AlertDialogTitle>
            <AlertDialogDescription>
              The app uploads its bundled notebook and points the agent job at it. Your own
              notebook stays where it is, unchanged. From then on the app upgrades the agent
              with each app upgrade. Runs in flight block the switch.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel disabled={switching}>Cancel</AlertDialogCancel>
            <AlertDialogAction
              disabled={switching}
              onClick={(e) => {
                e.preventDefault();
                void doSwitch();
              }}
            >
              {switching ? "Switching..." : "Switch"}
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}

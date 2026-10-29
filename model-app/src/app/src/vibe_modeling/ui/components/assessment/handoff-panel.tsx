import { useId, useState } from "react";
import { useQueryClient } from "@tanstack/react-query";
import { Check, ExternalLink } from "lucide-react";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import {
  createAssessmentHandoff,
  getAssessmentHandoffKey,
  installAssessmentSkills,
  useGetAssessmentHandoffSuspense,
  type HandoffOut,
  type SkillStatus,
} from "@/lib/api";
import { parseAdminHelp, type AdminHelp } from "@/lib/api-error";
import { formatDateTime } from "@/lib/date";
import { toast } from "sonner";
import { notifyError } from "@/lib/notify";
import { selector } from "@/lib/selector";
import { AdminHelpBlock } from "./admin-help-block";
import { CopyBlock } from "./copy-block";

const SKILL_BADGE: Record<SkillStatus["state"], { label: string; variant: "secondary" | "outline" | "destructive" }> = {
  present: { label: "Installed", variant: "secondary" },
  update_available: { label: "Update available", variant: "outline" },
  missing: { label: "Missing", variant: "destructive" },
  unknown: { label: "Unknown", variant: "outline" },
};
const SKILL_LOCATION = { user: "in your folder", workspace: "workspace-wide", none: "" } as const;
const FOLDER_PLACEHOLDER = "/Workspace/Users/<your email>/vibe-assess";

/** Hand-off tab: copy conventions.yml + docs + decisions to a workspace folder, then run the hand-off prompts in order (four, or seven for hybrid models). */
export function HandoffPanel({ domainRunId }: { domainRunId: string }) {
  const queryClient = useQueryClient();
  const folderId = useId();
  const { data } = useGetAssessmentHandoffSuspense({
    params: { domain_run_id: domainRunId },
    ...selector<HandoffOut>(),
  });
  const [path, setPath] = useState(data.path ?? "");
  const [done, setDone] = useState<HandoffOut | null>(null);
  const [pending, setPending] = useState(false);
  const [copyHelp, setCopyHelp] = useState<AdminHelp | null>(null);
  const copied = done ?? (data.created_at ? data : null);
  const [installing, setInstalling] = useState(false);
  const [installHelp, setInstallHelp] = useState<AdminHelp | null>(null);
  const anyMissing = data.skills.some((s) => s.state === "missing");
  const anyUpdate = data.skills.some((s) => s.state === "update_available");
  const anyUnknown = data.skills.some((s) => s.state === "unknown");
  const overwrites = anyUpdate || anyUnknown;
  const actionLabel = anyMissing
    ? overwrites ? "Install / update skills" : "Install skills for me"
    : anyUpdate ? "Update skills" : "Try installing skills";
  const refetch = () => queryClient.invalidateQueries({ queryKey: getAssessmentHandoffKey({ domain_run_id: domainRunId }) });

  const recheck = async () => {
    // A deliberate re-check supersedes a stale inline install error.
    setInstallHelp(null);
    try {
      await queryClient.invalidateQueries(
        { queryKey: getAssessmentHandoffKey({ domain_run_id: domainRunId }) },
        { throwOnError: true },
      );
    } catch (err) {
      notifyError(err, { fallback: "Couldn't re-check skills" });
      return;
    }
    const fresh = queryClient.getQueryData<{ data: HandoffOut }>(
      getAssessmentHandoffKey({ domain_run_id: domainRunId }),
    )?.data;
    if (!fresh) return;
    const unknown = fresh.skills.filter((s) => s.state === "unknown").length;
    const missing = fresh.skills.filter((s) => s.state === "missing").length;
    const stale = fresh.skills.filter((s) => s.state === "update_available").length;
    if (unknown) toast.success(`Couldn't read ${unknown} skill${unknown === 1 ? "" : "s"}`);
    else if (missing || stale) {
      const parts = [missing && `${missing} missing`, stale && `${stale} need${stale === 1 ? "s" : ""} an update`];
      toast.success(parts.filter(Boolean).join(", "));
    } else toast.success("All skills up to date");
  };

  const install = async (body: { update?: string[]; names?: string[] }) => {
    setInstalling(true);
    setInstallHelp(null);
    try {
      const res = await installAssessmentSkills({ domain_run_id: domainRunId }, body);
      const n = res.data.installed.length;
      const u = res.data.updated.length;
      if (n === 0 && u === 0) toast.success("Nothing to install");
      else toast.success(`Installed ${n}, updated ${u}`);
    } catch (err) {
      const help = parseAdminHelp(err);
      if (help) setInstallHelp(help);
      else notifyError(err, { fallback: "Couldn't install skills" });
    } finally {
      // Partial installs aren't reported in error bodies, so refetch on every outcome.
      await refetch();
      setInstalling(false);
    }
  };

  const copy = async () => {
    setPending(true);
    setCopyHelp(null);
    try {
      const res = await createAssessmentHandoff({ domain_run_id: domainRunId }, { path });
      setDone(res.data);
      await queryClient.invalidateQueries({ queryKey: getAssessmentHandoffKey({ domain_run_id: domainRunId }) });
    } catch (err) {
      const help = parseAdminHelp(err);
      if (help) setCopyHelp(help);
      else notifyError(err, { fallback: "Couldn't copy to the workspace" });
    } finally {
      setPending(false);
    }
  };

  return (
    <div className="space-y-4 text-sm">
      <div className="rounded-md border p-4 space-y-2">
        <h3 className="font-medium">What to do next</h3>
        <ol className="space-y-2">
          {data.next_steps.map((st) => {
                        return (
              <li key={st.order} data-testid="next-step" className="flex gap-2">
                <span className="w-5 shrink-0 text-muted-foreground">
                  {st.done ? <Check aria-label="done" className="h-4 w-4 text-green-600" /> : `${st.order}.`}
                </span>
                <span>
                  <span className="font-medium">{st.title}</span>
                  <span className="block text-muted-foreground">{st.detail}</span>
                </span>
              </li>
            );
          })}
        </ol>
      </div>
      <p className="text-muted-foreground">
        Copies conventions.yml, the design docs and your decision answers into a workspace folder. Next vibes are
        read-only and are not imported automatically — add the ones you want as vibe inputs for your next modeling iteration.
      </p>
      <div className="space-y-1">
        <label htmlFor={folderId} className="font-medium">
          Workspace folder
        </label>
        <div className="flex items-center gap-2">
          <Input
            id={folderId}
            value={path}
            onChange={(e) => setPath(e.target.value)}
            placeholder={FOLDER_PLACEHOLDER}
            className="font-mono"
          />
          <Button onClick={copy} disabled={pending || !path.trim()}>
            Copy to workspace
          </Button>
        </div>
      </div>
      {copyHelp && <AdminHelpBlock help={copyHelp} testId="handoff-admin-help" live />}
      {copied && copied.path && (
        <p className="flex flex-wrap items-center gap-x-2 break-all">
          Copied to {copied.path} at {formatDateTime(copied.created_at as string)}
          <a
            href={copied.folder_url}
            target="_blank"
            rel="noreferrer"
            className="inline-flex items-center gap-1 text-primary hover:underline"
          >
            Open folder <ExternalLink className="h-3 w-3" />
          </a>
        </p>
      )}
      <div className="space-y-2">
        <h3 className="font-medium">Run these prompts in order</h3>
        {data.prompts.map((p) => (
          <div key={p.key} className="space-y-1">
            {/* The backend numbers the titles (the hand-off README uses them too). */}
            <p className="text-xs text-muted-foreground">
              {p.title} ({p.skill})
            </p>
            <CopyBlock text={p.prompt} label={`Copy ${p.title}`} />
          </div>
        ))}
      </div>
      <div className="space-y-1">
        <h3 className="font-medium">Workspace skills</h3>
        {data.skills_note && (
          <Alert data-testid="skills-note">
            <AlertDescription>{data.skills_note}</AlertDescription>
          </Alert>
        )}
        <ul className="space-y-1">
          {data.skills.map((s) => {
            const b = SKILL_BADGE[s.state];
            const loc = s.location ? SKILL_LOCATION[s.location] : "";
            return (
              <li key={s.name} className="flex items-center gap-2">
                <span>{s.name}</span>
                <span title={`Installed ${s.installed_version || "none"} · bundled ${s.bundled_version || "unknown"}`}>
                  <Badge variant={b.variant}>{b.label}</Badge>
                </span>
                {loc && <span className="text-xs text-muted-foreground">{loc}</span>}
                {s.state === "update_available" && (
                  <Button
                    size="sm"
                    variant="outline"
                    aria-label={`Update ${s.name}`}
                    disabled={installing}
                    onClick={() => install({ update: [s.name] })}
                  >
                    Update
                  </Button>
                )}
              </li>
            );
          })}
        </ul>
        <div className="flex items-center gap-2">
          {(anyMissing || anyUpdate || anyUnknown) && (
            <Button
              size="sm"
              disabled={installing}
              onClick={() =>
                install({
                  update: data.skills.filter((s) => s.state === "update_available" || s.state === "unknown").map((s) => s.name),
                  names: [],
                })
              }
            >
              {actionLabel}
            </Button>
          )}
          <Button size="sm" variant="outline" onClick={() => void recheck()}>
            Re-check
          </Button>
        </div>
        {overwrites && (
          <p className="text-xs text-muted-foreground">
            Replaces the listed skills in your folder with the app's bundled version.
          </p>
        )}
        {installHelp && <AdminHelpBlock help={installHelp} testId="install-skills-admin-help" live />}
        <Alert>
          <AlertDescription>{data.user_scope_note}</AlertDescription>
        </Alert>
      </div>
      {data.expected_handoffs.length > 0 && (
        <div className="space-y-1">
          <h3 className="font-medium">Expected in the folder</h3>
          <ul className="list-disc pl-5 text-muted-foreground">
            {data.expected_handoffs.map((h) => (
              <li key={h}>{h}</li>
            ))}
          </ul>
        </div>
      )}
    </div>
  );
}

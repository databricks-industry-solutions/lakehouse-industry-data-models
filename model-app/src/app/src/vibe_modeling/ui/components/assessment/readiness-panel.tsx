import { CheckCircle, HelpCircle, XCircle } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { AdminHelpBlock } from "@/components/assessment/admin-help-block";
import { CopyBlock } from "@/components/assessment/copy-block";
import { FeatureSettingsButton } from "@/components/feature-gate";
import type { Check, ReadinessOut } from "@/lib/api";
import { ADMIN_HELP_LEAD_CHECK } from "@/lib/assessment";

/** `fix_action` of a check the app's own setup owns: no SQL, the admin-help block instead. */
const ADMIN_HELP_ACTION = "admin_help";

const STATE_WORD: Record<Check["state"], string> = {
  ok: "OK",
  blocked: "Blocked",
  unverified: "Unverified",
};

function StateIcon({ state }: { state: Check["state"] }) {
  if (state === "ok") return <CheckCircle className="h-4 w-4 shrink-0 text-green-600" aria-hidden />;
  if (state === "blocked") return <XCircle className="h-4 w-4 shrink-0 text-destructive" aria-hidden />;
  return <HelpCircle className="h-4 w-4 shrink-0 text-warning" aria-hidden />;
}

function CheckRow({ check, scope }: { check: Check; scope: string }) {
  return (
    <li className="space-y-1" data-testid={`readiness-check-${check.key}`}>
      <div className="flex items-start gap-2 text-sm">
        <StateIcon state={check.state} />
        <span className="font-medium">{check.label}</span>
        <span className="text-xs text-muted-foreground">{STATE_WORD[check.state]}</span>
      </div>
      <div className="pl-6 space-y-1">
        {check.fix_action === ADMIN_HELP_ACTION ? (
          <AdminHelpBlock
            help={{ message: check.detail || `${check.label}: ${STATE_WORD[check.state]}` }}
            lead={ADMIN_HELP_LEAD_CHECK}
            testId={`readiness-admin-help-${scope}-${check.key}`}
          />
        ) : (
          check.detail && <p className="text-xs text-muted-foreground">{check.detail}</p>
        )}
        {check.state === "unverified" && (
          <p className="text-xs text-muted-foreground">
            Not checked from the app. The job's pre-flight will confirm before any model calls.
          </p>
        )}
        {check.fix_action === "open_settings" && (
          <FeatureSettingsButton feature="assessment" />
        )}
        {check.fix_sql && check.fix_action !== ADMIN_HELP_ACTION && <CopyBlock text={check.fix_sql} label="Copy SQL" />}
      </div>
    </li>
  );
}

/**
 * The readiness checks for a launch: a state per check, the `fix_sql` to
 * copy for model and bronze grants, the admin-help block for checks the
 * app's setup owns. `checking` dims it while a new check runs.
 */
export function ReadinessPanel({ readiness, checking = false }: { readiness: ReadinessOut; checking?: boolean }) {
  const allChecks = [
    ...readiness.global_checks,
    ...readiness.domains.flatMap((d) => d.checks),
  ];
  const allClear = allChecks.every((c) => c.state === "ok");

  if (allClear) {
    return (
      <Card data-testid="readiness-panel">
        <CardContent className="flex items-center gap-2 py-3 text-sm">
          <CheckCircle className="h-4 w-4 text-green-600" aria-hidden />
          All checks passed — ready to launch.
        </CardContent>
      </Card>
    );
  }

  return (
    <Card data-testid="readiness-panel" aria-busy={checking} className={checking ? "opacity-60" : undefined}>
      <CardHeader className="pb-2">
        <CardTitle className="text-base">Readiness</CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        {readiness.global_checks.length > 0 && (
          <ul className="space-y-2">
            {readiness.global_checks.map((c) => (
              <CheckRow key={c.key} check={c} scope="global" />
            ))}
          </ul>
        )}
        {readiness.domains
          .filter((d) => d.checks.length > 0)
          .map((d) => (
            <section key={d.domain_id} className="space-y-2">
              <h4 className="text-sm font-semibold">{d.domain_name}</h4>
              <ul className="space-y-2">
                {d.checks.map((c) => (
                  <CheckRow key={`${d.domain_id}:${c.key}`} check={c} scope={d.domain_id} />
                ))}
              </ul>
            </section>
          ))}
      </CardContent>
    </Card>
  );
}

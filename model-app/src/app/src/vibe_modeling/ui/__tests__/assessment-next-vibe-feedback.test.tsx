import { beforeEach, describe, expect, it, vi } from "vitest";
import { fireEvent, render, screen } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";

const api = vi.hoisted(() => ({
  useAddNextVibeToFeedback: vi.fn(),
  useAddNextVibesToFeedback: vi.fn(),
  getAssessmentResultsKey: vi.fn((params) => ["getAssessmentResults", params.domain_run_id]),
}));
vi.mock("@/lib/api", async () => {
  const actual = await vi.importActual<typeof import("@/lib/api")>("@/lib/api");
  return { ...actual, ...api };
});

const notify = vi.hoisted(() => ({
  notifyError: vi.fn(),
}));
vi.mock("@/lib/notify", () => notify);

const router = vi.hoisted(() => ({
  useNavigate: vi.fn(),
}));
vi.mock("@tanstack/react-router", async () => {
  const actual = await vi.importActual<typeof import("@tanstack/react-router")>(
    "@tanstack/react-router",
  );
  return { ...actual, useNavigate: router.useNavigate };
});

const sonner = vi.hoisted(() => ({
  toast: { success: vi.fn(), error: vi.fn() },
}));
vi.mock("sonner", () => sonner);

import { NextVibesList, bulkAddLabel } from "@/components/assessment/next-vibes-list";

const vibe = (over: Record<string, unknown>) => ({
  id: "v",
  domain_run_id: "r1",
  priority: 1,
  category: "source",
  text: "legacy text",
  confidence: 0.8,
  problem: "",
  proposed_change: "",
  impact_if_skipped: "",
  urgency: "",
  affected_entities: [],
  feedback_input_id: null,
  ...over,
});

const vibes = [
  vibe({ id: "a", urgency: "before_build", problem: "Before problem", feedback_input_id: null }),
  vibe({ id: "b", urgency: "before_build", problem: "Another before problem", feedback_input_id: "input-b" }),
  vibe({ id: "c", urgency: "during_build", problem: "During problem", feedback_input_id: null }),
];

function withQuery(ui: React.ReactNode, qc?: QueryClient) {
  const client = qc ?? new QueryClient({
    defaultOptions: { queries: { retry: false } },
  });
  return <QueryClientProvider client={client}>{ui}</QueryClientProvider>;
}

const target = { businessId: "b1", version: 1, scope: "production" };

describe("NextVibesList feedback functionality", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    // Set up default mock return values
    api.useAddNextVibeToFeedback.mockReturnValue({ mutate: vi.fn() });
    api.useAddNextVibesToFeedback.mockReturnValue({ mutate: vi.fn() });
    router.useNavigate.mockReturnValue(vi.fn());
  });

  describe("Per-card button rendering", () => {
    it("renders 'Add to feedback' button for unlinked vibes", () => {
      render(
        withQuery(
          <NextVibesList
            vibes={[vibes[0]]}
            verdict="iterate_first"
            domainRunId="r1"
            feedbackTarget={{ businessId: "b1", version: 1, scope: "production" }}
          />,
        ),
      );

      const button = screen.getByRole("button", { name: /Add to feedback/ });
      expect(button).toBeInTheDocument();
      expect(button).not.toBeDisabled();
    });

    it("renders 'Added ✓' label and a 'View feedback' link when linked with a target", () => {
      render(
        withQuery(
          <NextVibesList vibes={[vibes[1]]} verdict="iterate_first" domainRunId="r1" feedbackTarget={target} />,
        ),
      );

      expect(screen.getByText("Added ✓")).toBeInTheDocument();
      expect(screen.queryByRole("button", { name: /Added/ })).not.toBeInTheDocument();
      expect(screen.getByRole("button", { name: "View feedback" })).toBeInTheDocument();
    });

    it("shows only 'Added ✓' when feedbackTarget is absent", () => {
      render(withQuery(<NextVibesList vibes={[vibes[1]]} verdict="iterate_first" domainRunId="r1" />));

      expect(screen.getByText("Added ✓")).toBeInTheDocument();
      expect(screen.queryByText(/View feedback/)).not.toBeInTheDocument();
      expect(screen.queryByRole("button")).not.toBeInTheDocument();
    });
  });

  describe("Per-card actions", () => {
    it("single add calls the mutation, invalidates the results query and does not navigate", () => {
      const mutate = vi.fn((_vars, opts) => opts.onSuccess({ data: { created: true, feedback_input_id: "new-id" } }));
      api.useAddNextVibeToFeedback.mockReturnValue({ mutate });
      const navigate = vi.fn();
      router.useNavigate.mockReturnValue(navigate);
      const qc = new QueryClient();
      const invalidate = vi.spyOn(qc, "invalidateQueries");

      render(
        withQuery(
          <NextVibesList vibes={[vibes[0]]} verdict="iterate_first" domainRunId="r1" feedbackTarget={target} />,
          qc,
        ),
      );
      fireEvent.click(screen.getByRole("button", { name: /Add to feedback/ }));

      expect(mutate).toHaveBeenCalledWith(
        { params: { domain_run_id: "r1", next_vibe_id: "a" } },
        expect.any(Object),
      );
      expect(invalidate).toHaveBeenCalledWith({ queryKey: ["getAssessmentResults", "r1"] });
      expect(navigate).not.toHaveBeenCalled();
      expect(sonner.toast.success).toHaveBeenCalledWith("Added to feedback");
    });

    it("toasts 'Already in feedback' when the input was reused", () => {
      const mutate = vi.fn((_vars, opts) => opts.onSuccess({ data: { created: false, feedback_input_id: "old" } }));
      api.useAddNextVibeToFeedback.mockReturnValue({ mutate });

      render(withQuery(<NextVibesList vibes={[vibes[0]]} verdict="iterate_first" domainRunId="r1" />));
      fireEvent.click(screen.getByRole("button", { name: /Add to feedback/ }));

      expect(sonner.toast.success).toHaveBeenCalledWith("Already in feedback");
    });

    it("'View feedback' navigates to the linked input without calling the mutation", () => {
      const mutate = vi.fn();
      api.useAddNextVibeToFeedback.mockReturnValue({ mutate });
      const navigate = vi.fn();
      router.useNavigate.mockReturnValue(navigate);

      render(
        withQuery(
          <NextVibesList vibes={[vibes[1]]} verdict="iterate_first" domainRunId="r1" feedbackTarget={target} />,
        ),
      );
      fireEvent.click(screen.getByRole("button", { name: "View feedback" }));

      expect(mutate).not.toHaveBeenCalled();
      expect(navigate).toHaveBeenCalledWith({
        to: "/businesses/$businessId/model/$version/$scope/inputs/$inputId",
        params: { businessId: "b1", version: "1", scope: "production", inputId: "input-b" },
        search: { from: "feedback", tab: "diagram" },
      });
    });
  });

  describe("Bulk button rendering", () => {
    it("shows bulk button only when unlinked before_build vibes exist", () => {
      render(
        withQuery(
          <NextVibesList
            vibes={vibes}
            verdict="iterate_first"
            domainRunId="r1"
          />,
        ),
      );

      // One unlinked before_build vibe (a), one linked (b)
      expect(screen.getByRole("button", { name: "Add the remaining before-build vibe" })).toBeInTheDocument();
      expect(screen.queryByRole("button", { name: /Add all 1/ })).not.toBeInTheDocument();
    });

    it("counts the bulk button by what is left to add", () => {
      expect(bulkAddLabel(1, 1)).toBe("Add the before-build vibe");
      expect(bulkAddLabel(3, 3)).toBe("Add all 3 before-build vibes");
      expect(bulkAddLabel(1, 2)).toBe("Add the remaining before-build vibe");
      expect(bulkAddLabel(2, 3)).toBe("Add the remaining 2 before-build vibes");
    });

    it("hides bulk button when all before_build vibes are linked", () => {
      const allLinked = [
        vibe({ id: "a", urgency: "before_build", feedback_input_id: "input-a" }),
        vibe({ id: "b", urgency: "before_build", feedback_input_id: "input-b" }),
      ];

      render(
        withQuery(
          <NextVibesList
            vibes={allLinked}
            verdict="iterate_first"
            domainRunId="r1"
          />,
        ),
      );

      expect(screen.queryByRole("button", { name: /before-build vibe/ })).not.toBeInTheDocument();
    });

    it("hides bulk button when no before_build vibes exist", () => {
      const noBeforeBuild = [vibe({ id: "a", urgency: "during_build" }), vibe({ id: "b", urgency: "later" })];

      render(
        withQuery(
          <NextVibesList
            vibes={noBeforeBuild}
            verdict="iterate_first"
            domainRunId="r1"
          />,
        ),
      );

      expect(screen.queryByRole("button", { name: /before-build vibe/ })).not.toBeInTheDocument();
    });
  });

  describe("Failures", () => {
    const adminHelp = async () => {
      const { ApiError } = await import("@/lib/api");
      return new ApiError(409, "Conflict", { detail: { error: "admin_help", message: "Couldn't add the next vibe to feedback: database unavailable" } });
    };

    it("single add: an admin_help error shows the block on that card, not a toast", async () => {
      const err = await adminHelp();
      api.useAddNextVibeToFeedback.mockReturnValue({ mutate: vi.fn((_v, opts) => opts.onError(err)) });
      render(withQuery(<NextVibesList vibes={[vibes[0]]} verdict="iterate_first" domainRunId="r1" />));
      fireEvent.click(screen.getByRole("button", { name: /Add to feedback/ }));
      expect(await screen.findByTestId("vibe-admin-help-a")).toHaveTextContent("database unavailable");
      expect(notify.notifyError).not.toHaveBeenCalled();
    });

    it("single add: any other error still toasts", () => {
      const err = new Error("network down");
      api.useAddNextVibeToFeedback.mockReturnValue({ mutate: vi.fn((_v, opts) => opts.onError(err)) });
      render(withQuery(<NextVibesList vibes={[vibes[0]]} verdict="iterate_first" domainRunId="r1" />));
      fireEvent.click(screen.getByRole("button", { name: /Add to feedback/ }));
      expect(notify.notifyError).toHaveBeenCalledWith(err, { title: "Failed to add to feedback" });
      expect(screen.queryByTestId("vibe-admin-help-a")).toBeNull();
    });

    it("bulk add: an admin_help error shows the bulk block", async () => {
      const err = await adminHelp();
      api.useAddNextVibesToFeedback.mockReturnValue({ mutate: vi.fn((_v, opts) => opts.onError(err)) });
      render(withQuery(<NextVibesList vibes={vibes} verdict="iterate_first" domainRunId="r1" />));
      fireEvent.click(screen.getByRole("button", { name: "Add the remaining before-build vibe" }));
      expect(await screen.findByTestId("bulk-feedback-admin-help")).toHaveTextContent("database unavailable");
      expect(notify.notifyError).not.toHaveBeenCalled();
    });

    it("single add: a plain 409 conflict shows inline with Try again, not the admin-help block", async () => {
      const { ApiError } = await import("@/lib/api");
      const err = new ApiError(409, "Conflict", {
        detail: { message: "Another request changed this next vibe's feedback link at the same time; try again." },
      });
      const mutate = vi.fn((_v, opts) => opts.onError(err));
      api.useAddNextVibeToFeedback.mockReturnValue({ mutate });
      render(withQuery(<NextVibesList vibes={[vibes[0]]} verdict="iterate_first" domainRunId="r1" />));
      fireEvent.click(screen.getByRole("button", { name: /Add to feedback/ }));
      const notice = await screen.findByTestId("vibe-retry-a");
      expect(notice).toHaveTextContent("Another request changed this next vibe's feedback link at the same time; try again.");
      expect(notice).toHaveAttribute("role", "alert");
      expect(notice.querySelector("[data-tone='error']")).not.toBeNull();
      expect(screen.queryByTestId("vibe-admin-help-a")).toBeNull();
      expect(notify.notifyError).not.toHaveBeenCalled();
      fireEvent.click(screen.getByRole("button", { name: "Try again" }));
      expect(mutate).toHaveBeenCalledTimes(2);
    });

    it("bulk add: per-vibe failures in a 200 show inline on each card, retryable one by one", async () => {
      api.useAddNextVibesToFeedback.mockReturnValue({
        mutate: vi.fn((_v, opts) =>
          opts.onSuccess({
            data: {
              count_created: 0, count_reused: 0, items: [],
              failures: [
                { next_vibe_id: "a", message: "not a next vibe of this run" },
                { next_vibe_id: "zzz", message: "unknown id" },
              ],
            },
          }),
        ),
      });
      const single = vi.fn();
      api.useAddNextVibeToFeedback.mockReturnValue({ mutate: single });
      render(withQuery(<NextVibesList vibes={vibes} verdict="iterate_first" domainRunId="r1" />));
      fireEvent.click(screen.getByRole("button", { name: "Add the remaining before-build vibe" }));
      expect(await screen.findByTestId("vibe-retry-a")).toHaveTextContent("not a next vibe of this run");
      expect(screen.queryByTestId("vibe-retry-c")).toBeNull();
      expect(screen.queryByTestId("bulk-feedback-admin-help")).toBeNull();
      fireEvent.click(screen.getByRole("button", { name: "Try again" }));
      expect(single).toHaveBeenCalledWith({ params: { domain_run_id: "r1", next_vibe_id: "a" } }, expect.any(Object));
      expect(screen.queryByTestId("vibe-retry-a")).toBeNull();
    });

    it("bulk add: nothing created or reused means no success toast", () => {
      api.useAddNextVibesToFeedback.mockReturnValue({
        mutate: vi.fn((_v, opts) =>
          opts.onSuccess({ data: { count_created: 0, count_reused: 0, items: [], failures: [{ next_vibe_id: "a", message: "x" }] } }),
        ),
      });
      render(withQuery(<NextVibesList vibes={vibes} verdict="iterate_first" domainRunId="r1" />));
      fireEvent.click(screen.getByRole("button", { name: "Add the remaining before-build vibe" }));
      expect(sonner.toast.success).not.toHaveBeenCalled();
      expect(screen.getByTestId("vibe-retry-a")).toHaveTextContent("x");
    });

    it("bulk add: no failures, no block, a count toast", () => {
      api.useAddNextVibesToFeedback.mockReturnValue({
        mutate: vi.fn((_v, opts) => opts.onSuccess({ data: { count_created: 1, count_reused: 0, items: [], failures: [] } })),
      });
      render(withQuery(<NextVibesList vibes={vibes} verdict="iterate_first" domainRunId="r1" />));
      fireEvent.click(screen.getByRole("button", { name: "Add the remaining before-build vibe" }));
      expect(screen.queryByTestId("bulk-feedback-admin-help")).toBeNull();
      expect(sonner.toast.success).toHaveBeenCalledWith("Added 1 vibe as feedback");
    });
  });

  describe("Prop threading", () => {
    it("accepts feedbackTarget prop", () => {
      render(
        withQuery(
          <NextVibesList
            vibes={vibes}
            verdict="iterate_first"
            domainRunId="r1"
            feedbackTarget={{ businessId: "b1", version: 1, scope: "production" }}
          />,
        ),
      );

      expect(screen.getByText(/add the ones you keep as vibe inputs/i)).toBeInTheDocument();
    });

    it("renders without feedbackTarget", () => {
      render(
        withQuery(
          <NextVibesList
            vibes={vibes}
            verdict="iterate_first"
            domainRunId="r1"
          />,
        ),
      );

      expect(screen.getByText(/add the ones you keep as vibe inputs/i)).toBeInTheDocument();
    });
  });
});

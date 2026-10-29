import { beforeEach, describe, expect, it, vi } from "vitest";
import { fireEvent, render, screen, waitFor } from "@testing-library/react";

const { assess } = vi.hoisted(() => ({ assess: { data: undefined as unknown } }));

vi.mock("@/lib/api", () => ({
  useGetAssessConfig: () => ({ data: assess.data }),
}));

vi.mock("@tanstack/react-router", () => ({
  Link: ({ children, to, params, search, ...rest }: any) => (
    <a
      href={`${String(to).replace("$businessId", params?.businessId)}?versionId=${search?.versionId ?? ""}&domainId=${search?.domainId ?? ""}`}
      {...rest}
    >
      {children}
    </a>
  ),
}));

import { AssessButton } from "@/components/assessment/assess-button";

const ready = (value: boolean) => ({ data: { installed: true, ready: value } });
const NOT_INSTALLED_TEXT =
  /This version isn't installed yet\. Install it into a catalog first; Assess reads the installed tables\./;

/** The trigger span: the parent of the disabled button. */
function getTriggerSpan() {
  return screen.getByRole("button", { name: /assess/i }).parentElement;
}

describe("AssessButton", () => {
  beforeEach(() => {
    assess.data = ready(true);
  });

  it("renders nothing unless the assessment skill is ready", () => {
    for (const data of [undefined, ready(false), { data: { installed: false, ready: false } }]) {
      assess.data = data;
      const { container, unmount } = render(<AssessButton businessId="b1" versionId="v1" installed />);
      expect(container).toBeEmptyDOMElement();
      unmount();
    }
  });

  it("is disabled when the version is not installed", () => {
    render(<AssessButton businessId="b1" versionId="v1" installed={false} />);
    const btn = screen.getByRole("button", { name: /assess/i }) as HTMLButtonElement;
    expect(btn.disabled).toBe(true);
  });

  it("wraps the disabled button in a keyboard-accessible trigger span", () => {
    render(<AssessButton businessId="b1" versionId="v1" installed={false} />);
    const span = getTriggerSpan();
    expect(span).toBeInTheDocument();
    expect(span?.getAttribute("tabIndex")).toBe("0");
    expect(span?.querySelector("button")).toBeTruthy();
  });

  it("shows the tooltip text on hover when disabled", async () => {
    render(<AssessButton businessId="b1" versionId="v1" installed={false} />);
    // Radix opens on pointerMove, not pointerEnter
    fireEvent.pointerMove(getTriggerSpan()!);
    await waitFor(() => {
      expect(screen.getByRole("tooltip")).toBeInTheDocument();
      expect(screen.getAllByText(NOT_INSTALLED_TEXT).length).toBeGreaterThan(0);
    });
  });

  it("shows the tooltip text on keyboard focus when disabled", async () => {
    render(<AssessButton businessId="b1" versionId="v1" installed={false} />);
    fireEvent.focus(getTriggerSpan()!);
    await waitFor(() => {
      expect(screen.getByRole("tooltip")).toBeInTheDocument();
      expect(screen.getAllByText(NOT_INSTALLED_TEXT).length).toBeGreaterThan(0);
    });
  });

  it("links to the wizard with version and domain when installed", () => {
    render(<AssessButton businessId="b1" versionId="v1" domainId="d1" installed />);
    const link = screen.getByRole("link", { name: /assess/i });
    expect(link.getAttribute("href")).toBe("/businesses/b1/assessments/new?versionId=v1&domainId=d1");
  });

  it("does not show the tooltip when installed", () => {
    render(<AssessButton businessId="b1" versionId="v1" installed />);
    expect(screen.queryByText(/This version isn't installed yet/)).not.toBeInTheDocument();
  });
});

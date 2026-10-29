import { ThemeProvider } from "@/components/apx/theme-provider";
import { QueryClient } from "@tanstack/react-query";
import { createRootRouteWithContext, Outlet } from "@tanstack/react-router";
import { AppToaster } from "@/components/app-toaster";
import { ErrorDetailsHost } from "@/components/error-details-host";
import { FeedbackDraftPageScope } from "@/components/feedback/feedback-draft";

export const Route = createRootRouteWithContext<{
  queryClient: QueryClient;
}>()({
  component: () => (
    <ThemeProvider defaultTheme="dark" storageKey="apx-ui-theme">
      <Outlet />
      <AppToaster />
      <ErrorDetailsHost />
      <FeedbackDraftPageScope />
    </ThemeProvider>
  ),
});

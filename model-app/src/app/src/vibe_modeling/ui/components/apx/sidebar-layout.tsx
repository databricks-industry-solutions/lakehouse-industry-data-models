import { Outlet, Link } from "@tanstack/react-router";
import type { ReactNode } from "react";
import {
  Sidebar,
  SidebarContent,
  SidebarFooter,
  SidebarHeader,
  SidebarInset,
  SidebarProvider,
  SidebarRail,
  SidebarTrigger,
} from "@/components/ui/sidebar";
import SidebarUserFooter from "@/components/apx/sidebar-user-footer";
import { ModeToggle } from "@/components/apx/mode-toggle";
import Logo from "@/components/apx/logo";
import { BreadcrumbProvider, useBreadcrumbItems } from "@/components/explorer/breadcrumb-context";
import { HeaderHelpLink } from "@/components/help/header-help-link";
import { ChevronRight, Settings } from "lucide-react";

interface SidebarLayoutProps {
  children?: ReactNode;
}

function HeaderBreadcrumbs() {
  const items = useBreadcrumbItems();
  if (items.length === 0) return null;
  return (
    <nav className="flex min-w-0 items-center gap-1 text-sm text-muted-foreground">
      {items.map((item, i) => (
        <span key={i} className="flex min-w-0 items-center gap-1">
          {i > 0 && <ChevronRight className="h-3 w-3 shrink-0" />}
          {item.to ? (
            <Link
              to={item.to}
              params={item.params}
              search={item.search as any}
              title={item.label}
              className="truncate hover:text-foreground transition-colors"
            >
              {item.label}
            </Link>
          ) : (
            <span className="truncate text-foreground font-medium" title={item.label}>{item.label}</span>
          )}
        </span>
      ))}
    </nav>
  );
}

function SidebarLayout({ children }: SidebarLayoutProps) {
  return (
    <SidebarProvider>
      <Sidebar>
        <SidebarHeader>
          <div className="px-2 py-2">
            <Logo />
          </div>
        </SidebarHeader>
        <SidebarContent>{children}</SidebarContent>
        <SidebarFooter>
          <SidebarUserFooter />
        </SidebarFooter>
        <SidebarRail />
      </Sidebar>
      <BreadcrumbProvider>
        <SidebarInset className="flex flex-col h-screen">
          <header className="sticky top-0 z-50 bg-background border-b border-border flex h-12 shrink-0 items-center gap-2 px-4">
            <SidebarTrigger className="-ml-1 cursor-pointer" />
            <HeaderBreadcrumbs />
            <div className="flex-1" />
            <HeaderHelpLink />
            <Link
              to="/settings"
              search={{ tab: "agent" }}
              title="Settings"
              aria-label="Settings"
              className="flex h-8 w-8 items-center justify-center rounded-md text-muted-foreground transition-colors hover:bg-accent hover:text-foreground"
            >
              <Settings className="h-4 w-4" />
            </Link>
            <ModeToggle />
          </header>
          <div className="flex flex-1 justify-center overflow-auto">
            <div className="flex flex-1 flex-col w-full">
              <Outlet />
            </div>
          </div>
        </SidebarInset>
      </BreadcrumbProvider>
    </SidebarProvider>
  );
}
export default SidebarLayout;

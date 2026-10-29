import { Toaster } from "sonner";
import { resolveTheme, useTheme } from "@/components/apx/theme-provider";

/**
 * The app's one Toaster. Sonner defaults to its light palette, so the app
 * theme is passed in: without it a dark-mode toast keeps a light background.
 * Sonner's rich-colour text is under 4.5:1 on some light backgrounds (warning
 * 3.07, success 4.29, error 4.36), so title and description use the theme
 * foreground, which is above 13:1 on every rich background in both themes.
 * Icon and border keep the type colour.
 */
export function AppToaster() {
  const { theme } = useTheme();
  return (
    <Toaster
      richColors
      theme={resolveTheme(theme)}
      toastOptions={{
        closeButton: true,
        classNames: { title: "text-foreground!", description: "text-foreground!" },
      }}
    />
  );
}

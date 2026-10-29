import { defineConfig } from "vitest/config";
import path from "path";

export default defineConfig({
  test: {
    environment: "jsdom",
    globals: true,
    testTimeout: 15000,
    setupFiles: ["./src/vibe_modeling/ui/__tests__/setup.ts"],
  },
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src/vibe_modeling/ui"),
    },
  },
  define: {
    __APP_NAME__: JSON.stringify("vibe-modeling"),
  },
});

import type { CapacitorConfig } from "@capacitor/cli";

const config: CapacitorConfig = {
  appId: "app.lovable.charlottes",
  appName: "Charlotte's",
  webDir: "dist/client",
  server: {
    // Loads the live published site so the app always shows the latest content.
    // Remove this block to ship a fully bundled offline build instead.
    url: "https://charlottes.lovable.app",
    cleartext: true,
  },
  ios: {
    contentInset: "always",
    backgroundColor: "#0f2a1d",
  },
};

export default config;

import type { CapacitorConfig } from "@capacitor/cli";

const config: CapacitorConfig = {
  appId: "app.lovable.charlottes",
  appName: "Charlotte's",
  webDir: "dist/client",
  // No server.url: the app loads its own bundled build from dist/client,
  // so it runs natively (and offline) without depending on the website.
  ios: {
    contentInset: "always",
    backgroundColor: "#0f2a1d",
  },
};

export default config;

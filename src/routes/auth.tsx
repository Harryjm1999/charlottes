import { createFileRoute, useNavigate } from "@tanstack/react-router";
import { useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { lovable } from "@/integrations/lovable/index";
import { SiteFooter, SiteHeader } from "@/components/SiteHeader";
import { useAuth } from "@/hooks/useAuth";

export const Route = createFileRoute("/auth")({
  head: () => ({
    meta: [
      { title: "Sign in | Charlotte's Restaurants & Tea Rooms" },
      { name: "description", content: "Sign in or create an account to manage your Charlotte's table bookings." },
      { property: "og:title", content: "Sign in | Charlotte's" },
      { property: "og:description", content: "Manage your Charlotte's table bookings." },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary" },
    ],
  }),
  component: AuthPage,
});

const inputClass =
  "w-full rounded-sm border border-border bg-card px-3 py-2.5 text-sm outline-none focus:border-brass focus:ring-2 focus:ring-brass/30";

function AuthPage() {
  const navigate = useNavigate();
  const { user } = useAuth();
  const [mode, setMode] = useState<"signin" | "signup">("signin");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [msg, setMsg] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  useEffect(() => {
    if (user) navigate({ to: "/account" });
  }, [user, navigate]);

  async function submit(e: React.FormEvent) {
    e.preventDefault();
    setBusy(true);
    setMsg(null);
    if (mode === "signup") {
      const { error } = await supabase.auth.signUp({
        email,
        password,
        options: { emailRedirectTo: window.location.origin + "/account" },
      });
      setMsg(error ? error.message : "Check your email to confirm your account.");
    } else {
      const { error } = await supabase.auth.signInWithPassword({ email, password });
      if (error) setMsg(error.message);
    }
    setBusy(false);
  }

  async function google() {
    const r = await lovable.auth.signInWithOAuth("google", { redirect_uri: window.location.origin + "/auth" });
    if (r.error) setMsg(r.error.message ?? "Google sign-in failed");
  }

  return (
    <div className="min-h-screen">
      <SiteHeader />
      <main className="mx-auto max-w-md px-5 py-16">
        <h1 className="text-center text-5xl text-primary">{mode === "signin" ? "Sign in" : "Create account"}</h1>
        <div className="deco-rule mx-auto my-6 w-32" />
        <div className="rounded-sm border border-border bg-card p-6 shadow-[var(--shadow-soft)]">
          <button
            onClick={google}
            className="w-full rounded-sm border border-border px-4 py-2.5 text-sm transition-colors hover:border-brass"
          >
            Continue with Google
          </button>
          <p className="my-4 text-center text-xs uppercase tracking-[0.2em] text-muted-foreground">or</p>
          <form onSubmit={submit} className="space-y-4">
            <input required type="email" placeholder="Email" value={email} onChange={(e) => setEmail(e.target.value)} className={inputClass} />
            <input required type="password" minLength={6} placeholder="Password" value={password} onChange={(e) => setPassword(e.target.value)} className={inputClass} />
            <button disabled={busy} className="w-full rounded-sm bg-primary px-6 py-3 text-xs uppercase tracking-[0.22em] text-primary-foreground hover:opacity-90 disabled:opacity-50">
              {mode === "signin" ? "Sign in" : "Create account"}
            </button>
          </form>
          {msg && <p className="mt-4 text-center text-sm text-muted-foreground">{msg}</p>}
          <button
            onClick={() => setMode(mode === "signin" ? "signup" : "signin")}
            className="mt-5 w-full text-center text-sm text-primary underline"
          >
            {mode === "signin" ? "New here? Create an account" : "Already have an account? Sign in"}
          </button>
        </div>
      </main>
      <SiteFooter />
    </div>
  );
}

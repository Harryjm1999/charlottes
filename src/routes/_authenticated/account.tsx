import { createFileRoute, Link } from "@tanstack/react-router";
import { useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { SiteFooter, SiteHeader } from "@/components/SiteHeader";
import { restaurants } from "@/data/restaurants";

export const Route = createFileRoute("/_authenticated/account")({
  head: () => ({
    meta: [
      { title: "My bookings | Charlotte's" },
      { name: "description", content: "View the status of your Charlotte's table bookings." },
      { property: "og:title", content: "My bookings | Charlotte's" },
      { property: "og:description", content: "Your Charlotte's table bookings." },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary" },
    ],
  }),
  component: AccountPage,
});

type Booking = {
  id: string; restaurant_slug: string; booking_date: string; booking_time: string;
  guests: number; status: string; user_id: string | null;
};

export const statusClass: Record<string, string> = {
  pending: "border-border text-muted-foreground",
  accepted: "border-primary text-primary",
  declined: "border-destructive text-destructive",
};

function AccountPage() {
  const { user } = Route.useRouteContext();
  const [bookings, setBookings] = useState<Booking[] | null>(null);
  const [isStaff, setIsStaff] = useState(false);

  useEffect(() => {
    supabase.from("bookings").select("*").eq("user_id", user.id).order("booking_date", { ascending: false })
      .then(({ data }) => setBookings((data as Booking[]) ?? []));
    supabase.rpc("my_staff_access").then(({ data }) => {
      const row = Array.isArray(data) ? data[0] : data;
      setIsStaff(!!row?.slugs?.length);
    });
  }, [user.id]);

  return (
    <div className="min-h-screen">
      <SiteHeader />
      <main className="mx-auto max-w-3xl px-5 py-16">
        <h1 className="text-5xl text-primary">My bookings</h1>
        <p className="mt-2 text-sm text-muted-foreground">Signed in as {user.email}</p>
        {isStaff && (
          <Link to="/admin" className="mt-4 inline-block rounded-sm border border-brass px-4 py-2 text-xs uppercase tracking-[0.18em] text-primary">
            Open staff admin
          </Link>
        )}
        <div className="deco-rule my-6 w-32" />
        {bookings === null ? (
          <p className="text-muted-foreground">Loading…</p>
        ) : bookings.length === 0 ? (
          <p className="text-muted-foreground">
            No bookings yet. <Link to="/book" className="text-primary underline">Book a table</Link>
          </p>
        ) : (
          <ul className="space-y-3">
            {bookings.map((b) => (
              <li key={b.id} className="flex items-center justify-between rounded-sm border border-border bg-card p-4">
                <div>
                  <p className="font-display text-xl text-primary">{restaurants.find((r) => r.slug === b.restaurant_slug)?.name}</p>
                  <p className="text-sm text-muted-foreground">{b.booking_date} at {b.booking_time} · {b.guests} guests</p>
                </div>
                <span className={`rounded-sm border px-3 py-1 text-xs uppercase tracking-[0.15em] ${statusClass[b.status]}`}>{b.status}</span>
              </li>
            ))}
          </ul>
        )}
        <div className="mt-16 border-t border-border pt-6">
          <h2 className="font-display text-xl text-destructive">Delete account</h2>
          <p className="mt-1 text-sm text-muted-foreground">
            Permanently delete your account. Existing bookings stay with the restaurant but are no longer linked to you.
          </p>
          <button
            type="button"
            onClick={async () => {
              if (!window.confirm("Permanently delete your account? This cannot be undone.")) return;
              const { error } = await supabase.rpc("delete_own_account");
              if (error) { window.alert("Could not delete account: " + error.message); return; }
              await supabase.auth.signOut();
              window.location.href = "/";
            }}
            className="mt-4 rounded-sm border border-destructive px-4 py-2 text-xs uppercase tracking-[0.18em] text-destructive"
          >
            Delete my account
          </button>
        </div>
      </main>
      <SiteFooter />
    </div>
  );
}

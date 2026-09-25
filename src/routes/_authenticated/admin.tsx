import { createFileRoute } from "@tanstack/react-router";
import { useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { SiteFooter, SiteHeader } from "@/components/SiteHeader";
import { restaurants } from "@/data/restaurants";

export const Route = createFileRoute("/_authenticated/admin")({
  head: () => ({
    meta: [
      { title: "Staff admin | Charlotte's" },
      { name: "description", content: "Accept or decline table bookings for your Charlotte's restaurant." },
      { property: "og:title", content: "Staff admin | Charlotte's" },
      { property: "og:description", content: "Manage Charlotte's table bookings." },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary" },
    ],
  }),
  component: AdminPage,
});

type Booking = {
  id: string; restaurant_slug: string; name: string; email: string; phone: string;
  booking_date: string; booking_time: string; guests: number; notes: string | null; status: string;
};

const statusClass: Record<string, string> = {
  pending: "border-border text-muted-foreground",
  accepted: "border-primary text-primary",
  declined: "border-destructive text-destructive",
};

function AdminPage() {
  const [slugs, setSlugs] = useState<string[] | null>(null);
  const [bookings, setBookings] = useState<Booking[]>([]);
  const [filter, setFilter] = useState<"pending" | "all">("pending");

  async function load() {
    const { data: a } = await supabase.from("staff_assignments").select("restaurant_slug");
    const s = (a ?? []).map((x) => x.restaurant_slug);
    setSlugs(s);
    if (!s.length) return;
    const { data } = await supabase.from("bookings").select("*").in("restaurant_slug", s)
      .order("booking_date").order("booking_time");
    setBookings((data as Booking[]) ?? []);
  }
  useEffect(() => { load(); }, []);

  async function setStatus(id: string, status: "accepted" | "declined") {
    const { error } = await supabase.from("bookings").update({ status }).eq("id", id);
    if (!error) setBookings((bs) => bs.map((b) => (b.id === id ? { ...b, status } : b)));
  }

  const shown = bookings.filter((b) => filter === "all" || b.status === "pending");

  return (
    <div className="min-h-screen">
      <SiteHeader />
      <main className="mx-auto max-w-5xl px-5 py-16">
        <h1 className="text-5xl text-primary">Staff admin</h1>
        {slugs === null ? (
          <p className="mt-6 text-muted-foreground">Loading…</p>
        ) : slugs.length === 0 ? (
          <p className="mt-6 text-muted-foreground">
            Your account isn't linked to a restaurant yet. Ask the site owner to add you as staff.
          </p>
        ) : (
          <>
            <p className="mt-2 text-sm text-muted-foreground">
              {slugs.map((s) => restaurants.find((r) => r.slug === s)?.name).join(", ")}
            </p>
            <div className="mt-6 flex gap-2">
              {(["pending", "all"] as const).map((f) => (
                <button key={f} onClick={() => setFilter(f)}
                  className={`rounded-sm border px-4 py-2 text-xs uppercase tracking-[0.18em] ${filter === f ? "border-brass bg-primary text-primary-foreground" : "border-border"}`}>
                  {f === "pending" ? "Awaiting reply" : "All bookings"}
                </button>
              ))}
            </div>
            <div className="deco-rule my-6 w-32" />
            {shown.length === 0 ? (
              <p className="text-muted-foreground">Nothing here right now.</p>
            ) : (
              <ul className="space-y-3">
                {shown.map((b) => (
                  <li key={b.id} className="rounded-sm border border-border bg-card p-5">
                    <div className="flex flex-wrap items-start justify-between gap-3">
                      <div>
                        <p className="font-display text-xl text-primary">{b.name} · {b.guests} guests</p>
                        <p className="text-sm">{b.booking_date} at {b.booking_time} — {restaurants.find((r) => r.slug === b.restaurant_slug)?.name}</p>
                        <p className="text-sm text-muted-foreground">
                          <a className="underline" href={`tel:${b.phone}`}>{b.phone}</a> · <a className="underline" href={`mailto:${b.email}`}>{b.email}</a>
                        </p>
                        {b.notes && <p className="mt-2 text-sm italic text-muted-foreground">“{b.notes}”</p>}
                      </div>
                      <div className="flex items-center gap-2">
                        <span className={`rounded-sm border px-3 py-1 text-xs uppercase tracking-[0.15em] ${statusClass[b.status]}`}>{b.status}</span>
                        {b.status !== "accepted" && (
                          <button onClick={() => setStatus(b.id, "accepted")} className="rounded-sm bg-primary px-4 py-2 text-xs uppercase tracking-[0.18em] text-primary-foreground">Accept</button>
                        )}
                        {b.status !== "declined" && (
                          <button onClick={() => setStatus(b.id, "declined")} className="rounded-sm border border-destructive px-4 py-2 text-xs uppercase tracking-[0.18em] text-destructive">Decline</button>
                        )}
                      </div>
                    </div>
                  </li>
                ))}
              </ul>
            )}
          </>
        )}
      </main>
      <SiteFooter />
    </div>
  );
}

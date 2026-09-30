import { createFileRoute } from "@tanstack/react-router";
import { useEffect, useMemo, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { SiteFooter, SiteHeader } from "@/components/SiteHeader";
import { restaurants } from "@/data/restaurants";

export const Route = createFileRoute("/_authenticated/admin")({
  head: () => ({
    meta: [
      { title: "Staff admin | Charlotte's" },
      { name: "description", content: "Manage table bookings and staff for Charlotte's restaurants." },
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
  booking_date: string; booking_time: string; guests: number; notes: string | null;
  status: string; source: string;
};
type Staff = { id: string; email: string; restaurant_slug: string };

const rName = (s: string) => restaurants.find((r) => r.slug === s)?.name ?? s;
const today = () => new Date().toISOString().slice(0, 10);
const shiftDay = (d: string, n: number) => {
  const x = new Date(d + "T12:00:00"); x.setDate(x.getDate() + n); return x.toISOString().slice(0, 10);
};
const prettyDay = (d: string) =>
  new Date(d + "T12:00:00").toLocaleDateString("en-GB", { weekday: "long", day: "numeric", month: "long" });

const statusClass: Record<string, string> = {
  pending: "border-border text-muted-foreground",
  accepted: "border-primary text-primary",
  declined: "border-destructive text-destructive",
};
const input = "w-full rounded-sm border border-border bg-background px-3 py-2 text-sm";
const btn = "rounded-sm px-4 py-2 text-xs uppercase tracking-[0.18em]";
const tabBtn = (on: boolean) => `${btn} border ${on ? "border-brass bg-primary text-primary-foreground" : "border-border"}`;

function AdminPage() {
  const [access, setAccess] = useState<{ owner: boolean; slugs: string[] } | null>(null);
  const [tab, setTab] = useState<"bookings" | "staff">("bookings");

  useEffect(() => {
    supabase.rpc("my_staff_access").then(({ data }) => {
      const row = Array.isArray(data) ? data[0] : data;
      setAccess({ owner: !!row?.is_owner, slugs: row?.slugs ?? [] });
    });
  }, []);

  return (
    <div className="min-h-screen">
      <SiteHeader />
      <main className="mx-auto max-w-5xl px-5 py-16">
        <h1 className="text-5xl text-primary">Staff admin</h1>
        {access === null ? (
          <p className="mt-6 text-muted-foreground">Loading…</p>
        ) : access.slugs.length === 0 ? (
          <p className="mt-6 text-muted-foreground">
            Your account isn't linked to a restaurant yet. Ask the owner to add your email as staff.
          </p>
        ) : (
          <>
            <p className="mt-2 text-sm text-muted-foreground">
              {access.owner ? "Owner · all restaurants" : access.slugs.map(rName).join(", ")}
            </p>
            {access.owner && (
              <div className="mt-6 flex gap-2">
                <button className={tabBtn(tab === "bookings")} onClick={() => setTab("bookings")}>Bookings</button>
                <button className={tabBtn(tab === "staff")} onClick={() => setTab("staff")}>Staff</button>
              </div>
            )}
            <div className="deco-rule my-6 w-32" />
            {tab === "staff" && access.owner ? <StaffTab /> : <BookingsTab slugs={access.slugs} />}
          </>
        )}
      </main>
      <SiteFooter />
    </div>
  );
}

function BookingsTab({ slugs }: { slugs: string[] }) {
  const [bookings, setBookings] = useState<Booking[]>([]);
  const [view, setView] = useState<"day" | "pending" | "all">("day");
  const [day, setDay] = useState(today());
  const [rest, setRest] = useState<string>("all");
  const [q, setQ] = useState("");
  const [editing, setEditing] = useState<Booking | "new" | null>(null);

  async function load() {
    const { data } = await supabase.from("bookings").select("*").in("restaurant_slug", slugs)
      .order("booking_date").order("booking_time");
    setBookings((data as Booking[]) ?? []);
  }
  useEffect(() => { load(); }, [slugs.join()]);

  async function setStatus(id: string, status: "accepted" | "declined") {
    const { error } = await supabase.from("bookings").update({ status }).eq("id", id);
    if (!error) setBookings((bs) => bs.map((b) => (b.id === id ? { ...b, status } : b)));
  }

  const shown = useMemo(() => {
    const s = q.trim().toLowerCase();
    return bookings.filter((b) =>
      (rest === "all" || b.restaurant_slug === rest) &&
      (view === "all" || (view === "pending" ? b.status === "pending" : b.booking_date === day)) &&
      (!s || [b.name, b.email, b.phone].some((v) => v.toLowerCase().includes(s))));
  }, [bookings, rest, view, day, q]);
  const covers = shown.filter((b) => b.status !== "declined").reduce((n, b) => n + b.guests, 0);
  const pendingCount = bookings.filter((b) => b.status === "pending").length;

  return (
    <>
      <div className="flex flex-wrap items-center gap-2">
        <button className={tabBtn(view === "day")} onClick={() => setView("day")}>Day view</button>
        <button className={tabBtn(view === "pending")} onClick={() => setView("pending")}>Awaiting reply ({pendingCount})</button>
        <button className={tabBtn(view === "all")} onClick={() => setView("all")}>All</button>
        <button className={`${btn} ml-auto bg-primary text-primary-foreground`} onClick={() => setEditing("new")}>+ Phone booking</button>
      </div>

      <div className="mt-4 grid gap-2 sm:grid-cols-[1fr_1fr]">
        <input className={input} placeholder="Search name, email or phone" value={q} onChange={(e) => setQ(e.target.value)} />
        {slugs.length > 1 && (
          <select className={input} value={rest} onChange={(e) => setRest(e.target.value)}>
            <option value="all">All restaurants</option>
            {slugs.map((s) => <option key={s} value={s}>{rName(s)}</option>)}
          </select>
        )}
      </div>

      {view === "day" && (
        <div className="mt-4 flex flex-wrap items-center gap-2">
          <button className={`${btn} border border-border`} onClick={() => setDay(shiftDay(day, -1))}>‹</button>
          <input type="date" className={`${input} w-auto`} value={day} onChange={(e) => setDay(e.target.value)} />
          <button className={`${btn} border border-border`} onClick={() => setDay(shiftDay(day, 1))}>›</button>
          <button className={`${btn} border border-border`} onClick={() => setDay(today())}>Today</button>
          <span className="font-display text-lg text-primary">{prettyDay(day)}</span>
          <span className="text-sm text-muted-foreground">· {shown.length} bookings · {covers} guests</span>
        </div>
      )}

      <div className="mt-6">
        {shown.length === 0 ? (
          <p className="text-muted-foreground">Nothing here right now.</p>
        ) : (
          <ul className="space-y-3">
            {shown.map((b) => (
              <li key={b.id} className="rounded-sm border border-border bg-card p-5">
                <div className="flex flex-wrap items-start justify-between gap-3">
                  <div>
                    <p className="font-display text-xl text-primary">{b.booking_time} · {b.name} · {b.guests} guests</p>
                    <p className="text-sm">{prettyDay(b.booking_date)} — {rName(b.restaurant_slug)}{b.source === "phone" && " · by phone"}</p>
                    <p className="text-sm text-muted-foreground">
                      <a className="underline" href={`tel:${b.phone}`}>{b.phone}</a>
                      {b.email && <> · <a className="underline" href={`mailto:${b.email}`}>{b.email}</a></>}
                    </p>
                    {b.notes && <p className="mt-2 text-sm italic text-muted-foreground">"{b.notes}"</p>}
                  </div>
                  <div className="flex flex-wrap items-center gap-2">
                    <span className={`rounded-sm border px-3 py-1 text-xs uppercase tracking-[0.15em] ${statusClass[b.status]}`}>{b.status}</span>
                    {b.status !== "accepted" && (
                      <button onClick={() => setStatus(b.id, "accepted")} className={`${btn} bg-primary text-primary-foreground`}>Accept</button>
                    )}
                    {b.status !== "declined" && (
                      <button onClick={() => setStatus(b.id, "declined")} className={`${btn} border border-destructive text-destructive`}>Decline</button>
                    )}
                    <button onClick={() => setEditing(b)} className={`${btn} border border-border`}>Edit</button>
                  </div>
                </div>
              </li>
            ))}
          </ul>
        )}
      </div>

      {editing && (
        <BookingEditor
          booking={editing === "new" ? null : editing}
          slugs={slugs}
          defaultDate={day}
          onClose={() => setEditing(null)}
          onSaved={() => { setEditing(null); load(); }}
        />
      )}
    </>
  );
}

function BookingEditor({ booking, slugs, defaultDate, onClose, onSaved }: {
  booking: Booking | null; slugs: string[]; defaultDate: string; onClose: () => void; onSaved: () => void;
}) {
  const [f, setF] = useState({
    restaurant_slug: booking?.restaurant_slug ?? slugs[0] ?? "",
    name: booking?.name ?? "", email: booking?.email ?? "", phone: booking?.phone ?? "",
    booking_date: booking?.booking_date ?? defaultDate, booking_time: booking?.booking_time ?? "12:00",
    guests: booking?.guests ?? 2, notes: booking?.notes ?? "",
  });
  const [staffNote, setStaffNote] = useState("");
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState("");

  useEffect(() => {
    if (!booking) return;
    supabase.from("booking_notes").select("note").eq("booking_id", booking.id).maybeSingle()
      .then(({ data }) => setStaffNote(data?.note ?? ""));
  }, [booking?.id]);

  const set = (k: keyof typeof f) => (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) =>
    setF((x) => ({ ...x, [k]: k === "guests" ? Number(e.target.value) : e.target.value }));

  async function save(e: React.FormEvent) {
    e.preventDefault();
    setBusy(true); setErr("");
    const payload = { ...f, notes: f.notes || null };
    let id = booking?.id;
    if (booking) {
      const { error } = await supabase.from("bookings").update(payload).eq("id", booking.id);
      if (error) { setErr(error.message); setBusy(false); return; }
    } else {
      const newId = crypto.randomUUID();
      const { error } = await supabase.from("bookings").insert({ ...payload, id: newId, status: "accepted", source: "phone" });
      if (error) { setErr(error.message); setBusy(false); return; }
      id = newId;
    }
    if (id && (staffNote || booking)) {
      await supabase.from("booking_notes").upsert({ booking_id: id, note: staffNote, updated_at: new Date().toISOString() });
    }
    setBusy(false);
    onSaved();
  }

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-foreground/40 p-4" onClick={onClose}>
      <form onSubmit={save} onClick={(e) => e.stopPropagation()}
        className="max-h-[90vh] w-full max-w-lg overflow-y-auto rounded-sm border border-border bg-card p-6 space-y-3">
        <h2 className="font-display text-2xl text-primary">{booking ? "Edit booking" : "New phone booking"}</h2>
        {slugs.length > 1 && (
          <select className={input} value={f.restaurant_slug} onChange={set("restaurant_slug")}>
            {slugs.map((s) => <option key={s} value={s}>{rName(s)}</option>)}
          </select>
        )}
        <input required className={input} placeholder="Name" value={f.name} onChange={set("name")} />
        <input required className={input} placeholder="Phone" value={f.phone} onChange={set("phone")} />
        <input className={input} type="email" placeholder="Email (optional)" value={f.email} onChange={set("email")} />
        <div className="grid grid-cols-3 gap-2">
          <input required type="date" className={input} value={f.booking_date} onChange={set("booking_date")} />
          <input required type="time" className={input} value={f.booking_time} onChange={set("booking_time")} />
          <input required type="number" min={1} max={20} className={input} value={f.guests} onChange={set("guests")} />
        </div>
        <textarea className={input} rows={2} placeholder="Customer requests" value={f.notes} onChange={set("notes")} />
        <textarea className={input} rows={2} placeholder="Staff-only note (customer never sees this)" value={staffNote} onChange={(e) => setStaffNote(e.target.value)} />
        {err && <p className="text-sm text-destructive">{err}</p>}
        <div className="flex justify-end gap-2 pt-2">
          <button type="button" onClick={onClose} className={`${btn} border border-border`}>Cancel</button>
          <button disabled={busy} className={`${btn} bg-primary text-primary-foreground`}>{busy ? "Saving…" : "Save"}</button>
        </div>
      </form>
    </div>
  );
}

function StaffTab() {
  const [staff, setStaff] = useState<Staff[]>([]);
  const [email, setEmail] = useState("");
  const [slug, setSlug] = useState(restaurants[0]?.slug ?? "");
  const [err, setErr] = useState("");

  async function load() {
    const { data } = await supabase.from("staff_members").select("id,email,restaurant_slug").order("email");
    setStaff(data ?? []);
  }
  useEffect(() => { load(); }, []);

  async function add(e: React.FormEvent) {
    e.preventDefault(); setErr("");
    const { error } = await supabase.from("staff_members").insert({ email: email.trim().toLowerCase(), restaurant_slug: slug });
    if (error) setErr(error.code === "23505" ? "Already added to that restaurant." : error.message);
    else { setEmail(""); load(); }
  }
  async function remove(id: string) {
    await supabase.from("staff_members").delete().eq("id", id);
    load();
  }

  return (
    <>
      <p className="text-sm text-muted-foreground">
        Add a staff member's email and their restaurant. They sign up or sign in with that same email and the staff admin appears in their account.
      </p>
      <form onSubmit={add} className="mt-4 grid gap-2 sm:grid-cols-[2fr_1fr_auto]">
        <input required type="email" className={input} placeholder="staff@example.com" value={email} onChange={(e) => setEmail(e.target.value)} />
        <select className={input} value={slug} onChange={(e) => setSlug(e.target.value)}>
          {restaurants.map((r) => <option key={r.slug} value={r.slug}>{r.name}</option>)}
        </select>
        <button className={`${btn} bg-primary text-primary-foreground`}>Add staff</button>
      </form>
      {err && <p className="mt-2 text-sm text-destructive">{err}</p>}
      <ul className="mt-6 space-y-2">
        {staff.length === 0 && <p className="text-muted-foreground">No staff added yet.</p>}
        {staff.map((s) => (
          <li key={s.id} className="flex items-center justify-between rounded-sm border border-border bg-card px-4 py-3">
            <span className="text-sm">{s.email} <span className="text-muted-foreground">· {rName(s.restaurant_slug)}</span></span>
            <button onClick={() => remove(s.id)} className={`${btn} border border-destructive text-destructive`}>Remove</button>
          </li>
        ))}
      </ul>
    </>
  );
}

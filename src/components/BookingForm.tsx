import { useState } from "react";
import { restaurants } from "@/data/restaurants";

type Props = { defaultSlug?: string; lockLocation?: boolean };

const inputClass =
  "w-full rounded-sm border border-border bg-card px-3 py-2.5 text-sm outline-none transition-colors focus:border-brass focus:ring-2 focus:ring-brass/30";

export function BookingForm({ defaultSlug, lockLocation = false }: Props) {
  const [slug, setSlug] = useState(defaultSlug ?? restaurants[0].slug);
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [phone, setPhone] = useState("");
  const [date, setDate] = useState("");
  const [time, setTime] = useState("12:30");
  const [guests, setGuests] = useState("2");
  const [notes, setNotes] = useState("");
  const [submitted, setSubmitted] = useState(false);

  const restaurant = restaurants.find((r) => r.slug === slug)!;

  if (submitted) {
    return (
      <div className="rounded-sm border border-brass/50 bg-card p-8 text-center shadow-[var(--shadow-soft)]">
        <p className="font-display text-3xl text-primary">Thank you, {name.split(" ")[0]}</p>
        <div className="deco-rule mx-auto my-5 w-32" />
        <p className="text-sm text-muted-foreground">
          We've noted your request for a table of {guests} at {restaurant.name} on {date} at {time}.
        </p>
        <p className="mt-4 text-sm">
          A member of the team will confirm shortly. For an immediate booking please call{" "}
          <a className="font-semibold text-primary underline" href={`tel:${restaurant.phone.replace(/\s/g, "")}`}>
            {restaurant.phone}
          </a>
          .
        </p>
        <button
          onClick={() => setSubmitted(false)}
          className="mt-6 rounded-sm border border-border px-4 py-2 text-xs uppercase tracking-[0.18em] transition-colors hover:border-brass"
        >
          Make another booking
        </button>
      </div>
    );
  }

  return (
    <form
      onSubmit={(e) => {
        e.preventDefault();
        setSubmitted(true);
      }}
      className="rounded-sm border border-border bg-card p-6 shadow-[var(--shadow-soft)] sm:p-8"
    >
      <div className="grid gap-5 sm:grid-cols-2">
        <div className="sm:col-span-2">
          <label className="mb-1.5 block text-xs uppercase tracking-[0.18em] text-muted-foreground">
            Restaurant
          </label>
          {lockLocation ? (
            <p className="font-display text-xl text-primary">{restaurant.name}</p>
          ) : (
            <select
              value={slug}
              onChange={(e) => setSlug(e.target.value)}
              className={inputClass}
              aria-label="Restaurant"
            >
              {restaurants.map((r) => (
                <option key={r.slug} value={r.slug}>
                  {r.name}
                </option>
              ))}
            </select>
          )}
        </div>

        <div>
          <label className="mb-1.5 block text-xs uppercase tracking-[0.18em] text-muted-foreground">
            Name
          </label>
          <input required value={name} onChange={(e) => setName(e.target.value)} className={inputClass} />
        </div>
        <div>
          <label className="mb-1.5 block text-xs uppercase tracking-[0.18em] text-muted-foreground">
            Phone
          </label>
          <input required value={phone} onChange={(e) => setPhone(e.target.value)} className={inputClass} />
        </div>
        <div className="sm:col-span-2">
          <label className="mb-1.5 block text-xs uppercase tracking-[0.18em] text-muted-foreground">
            Email
          </label>
          <input
            required
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            className={inputClass}
          />
        </div>
        <div>
          <label className="mb-1.5 block text-xs uppercase tracking-[0.18em] text-muted-foreground">
            Date
          </label>
          <input
            required
            type="date"
            value={date}
            onChange={(e) => setDate(e.target.value)}
            className={inputClass}
          />
        </div>
        <div>
          <label className="mb-1.5 block text-xs uppercase tracking-[0.18em] text-muted-foreground">
            Time
          </label>
          <input
            required
            type="time"
            value={time}
            onChange={(e) => setTime(e.target.value)}
            className={inputClass}
          />
        </div>
        <div>
          <label className="mb-1.5 block text-xs uppercase tracking-[0.18em] text-muted-foreground">
            Guests
          </label>
          <select value={guests} onChange={(e) => setGuests(e.target.value)} className={inputClass}>
            {Array.from({ length: 12 }, (_, i) => String(i + 1)).map((n) => (
              <option key={n} value={n}>
                {n}
              </option>
            ))}
          </select>
        </div>
        <div className="sm:col-span-2">
          <label className="mb-1.5 block text-xs uppercase tracking-[0.18em] text-muted-foreground">
            Notes (allergies, high chairs, occasions)
          </label>
          <textarea
            rows={3}
            value={notes}
            onChange={(e) => setNotes(e.target.value)}
            className={inputClass}
          />
        </div>
      </div>

      <button
        type="submit"
        className="mt-6 w-full rounded-sm bg-primary px-6 py-3 text-xs uppercase tracking-[0.22em] text-primary-foreground transition-opacity hover:opacity-90"
      >
        Request table
      </button>
      <p className="mt-3 text-center text-xs text-muted-foreground">
        Requests are confirmed by the team — or call {restaurant.phone} to book straight away.
      </p>
    </form>
  );
}

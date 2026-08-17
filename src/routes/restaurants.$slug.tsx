import { createFileRoute, notFound, Link } from "@tanstack/react-router";
import { BookingForm } from "@/components/BookingForm";
import { SiteFooter, SiteHeader } from "@/components/SiteHeader";
import { allergenInfo, getRestaurant, restaurants } from "@/data/restaurants";

export const Route = createFileRoute("/restaurants/$slug")({
  loader: ({ params }) => {
    const restaurant = getRestaurant(params.slug);
    if (!restaurant) throw notFound();
    return restaurant;
  },
  head: ({ loaderData }) => {
    const title = loaderData ? `${loaderData.name} | Menus & Booking` : "Charlotte's";
    const description = loaderData
      ? `Menus, opening hours, location and table bookings for ${loaderData.name} at ${loaderData.centre}.`
      : "Charlotte's Restaurants & Tea Rooms.";
    return {
      meta: [
        { title },
        { name: "description", content: description },
        { property: "og:title", content: title },
        { property: "og:description", content: description },
      ],
    };
  },
  component: RestaurantPage,
});

function RestaurantPage() {
  const r = Route.useLoaderData();

  return (
    <div className="min-h-screen">
      <SiteHeader />

      <section className="panel-deep">
        <div className="mx-auto max-w-6xl px-5 py-16 text-center">
          <p className="text-xs uppercase tracking-[0.3em] text-brass">{r.centre}</p>
          <h1 className="mt-4 text-4xl sm:text-5xl">{r.name}</h1>
          <div className="deco-rule mx-auto my-6 w-40" />
          <p className="mx-auto max-w-xl text-sm opacity-80">
            {r.address.join(", ")} · <a href={`tel:${r.phone.replace(/\s/g, "")}`}>{r.phone}</a>
          </p>
        </div>
      </section>

      <main className="mx-auto max-w-6xl px-5 py-14">
        <div className="grid gap-8 md:grid-cols-3">
          <div className="rounded-sm border border-border bg-card p-6">
            <h2 className="text-xl text-primary">Opening hours</h2>
            <ul className="mt-3 space-y-1 text-sm text-muted-foreground">
              {r.hours.map((h) => (
                <li key={h}>{h}</li>
              ))}
            </ul>
            {r.serviceTimes && (
              <ul className="mt-4 space-y-2 border-t border-border pt-4 text-xs text-muted-foreground">
                {r.serviceTimes.map((s) => (
                  <li key={s}>{s}</li>
                ))}
              </ul>
            )}
          </div>
          <div className="overflow-hidden rounded-sm border border-border md:col-span-2">
            <iframe
              title={`Map of ${r.centre}`}
              src={r.mapEmbed}
              className="h-72 w-full md:h-full"
              loading="lazy"
              referrerPolicy="no-referrer-when-downgrade"
            />
          </div>
        </div>
        <a
          href={r.mapLink}
          target="_blank"
          rel="noreferrer"
          className="mt-4 inline-block text-sm font-semibold text-primary underline"
        >
          Open in Google Maps
        </a>

        <section className="mt-20" id="menus">
          <h2 className="text-center text-4xl text-primary">Our menus</h2>
          <div className="deco-rule mx-auto my-6 w-32" />
          <div className="grid gap-10 md:grid-cols-2">
            {r.menus.map((m) => (
              <figure key={m.label} className="rounded-sm border border-border bg-card p-4">
                <figcaption className="mb-3 text-center text-xs uppercase tracking-[0.22em] text-muted-foreground">
                  {m.label}
                </figcaption>
                <img
                  src={m.src}
                  alt={`${m.label} menu at ${r.name}`}
                  loading="lazy"
                  className="w-full rounded-sm"
                />
              </figure>
            ))}
          </div>
          <figure className="mx-auto mt-10 max-w-2xl">
            <img
              src={allergenInfo}
              alt="Allergen information"
              loading="lazy"
              className="w-full rounded-sm border border-border"
            />
          </figure>
        </section>

        <section className="mt-20" id="book">
          <h2 className="text-center text-4xl text-primary">Reserve a table</h2>
          <div className="deco-rule mx-auto my-6 w-32" />
          <div className="mx-auto max-w-2xl">
            <BookingForm defaultSlug={r.slug} lockLocation />
          </div>
        </section>

        <section className="mt-20 text-center">
          <h2 className="text-2xl text-primary">Other Charlotte's</h2>
          <div className="mt-5 flex flex-wrap justify-center gap-3">
            {restaurants
              .filter((o) => o.slug !== r.slug)
              .map((o) => (
                <Link
                  key={o.slug}
                  to="/restaurants/$slug"
                  params={{ slug: o.slug }}
                  className="rounded-sm border border-border px-4 py-2 text-sm transition-colors hover:border-brass"
                >
                  {o.name}
                </Link>
              ))}
          </div>
        </section>
      </main>

      <SiteFooter />
    </div>
  );
}

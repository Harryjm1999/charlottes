import { createFileRoute } from "@tanstack/react-router";
import { BookingForm } from "@/components/BookingForm";
import { SiteFooter, SiteHeader } from "@/components/SiteHeader";
import { restaurants } from "@/data/restaurants";

export const Route = createFileRoute("/book")({
  head: () => ({
    meta: [
      { title: "Book a Table | Charlotte's Restaurants & Tea Rooms" },
      {
        name: "description",
        content:
          "Reserve a table at Charlotte's Restaurants and Tea Rooms inside In-Excess Garden Centres at Fair Oak, Landford, Ringwood and Salisbury.",
      },
      { property: "og:title", content: "Book a Table | Charlotte's Restaurants & Tea Rooms" },
      {
        property: "og:description",
        content: "Reserve a table at Charlotte's inside In-Excess Garden Centres.",
      },
    ],
  }),
  component: BookPage,
});

function BookPage() {
  return (
    <div className="min-h-screen">
      <SiteHeader />
      <main className="mx-auto max-w-3xl px-5 py-16">
        <p className="text-center text-xs uppercase tracking-[0.3em] text-muted-foreground">
          Reservations
        </p>
        <h1 className="mt-3 text-center text-5xl text-primary">Book a table</h1>
        <div className="deco-rule mx-auto my-6 w-40" />
        <p className="mx-auto mb-10 max-w-xl text-center text-muted-foreground">
          Choose your garden centre, tell us when you'd like to visit, and we'll take care of the
          rest.
        </p>
        <BookingForm />

        <div className="mt-14 grid gap-4 sm:grid-cols-2">
          {restaurants.map((r) => (
            <div key={r.slug} className="rounded-sm border border-border bg-card p-5">
              <h2 className="font-display text-xl text-primary">{r.name}</h2>
              <p className="mt-1 text-sm text-muted-foreground">{r.address.join(", ")}</p>
              <a
                className="mt-2 inline-block text-sm font-semibold text-primary underline"
                href={`tel:${r.phone.replace(/\s/g, "")}`}
              >
                {r.phone}
              </a>
            </div>
          ))}
        </div>
      </main>
      <SiteFooter />
    </div>
  );
}

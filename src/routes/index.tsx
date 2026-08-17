import { createFileRoute, Link } from "@tanstack/react-router";
import { SiteFooter, SiteHeader } from "@/components/SiteHeader";
import { restaurants } from "@/data/restaurants";
import hero from "@/assets/charlottes-fair-oak.jpg";

export const Route = createFileRoute("/")({
  head: () => ({
    meta: [
      { title: "Charlotte's Restaurants & Tea Rooms | In-Excess Garden Centres" },
      {
        name: "description",
        content:
          "Breakfasts, light lunches and afternoon teas at Charlotte's Restaurants and Tea Rooms inside In-Excess Garden Centres. View menus, find us and book a table.",
      },
      {
        property: "og:title",
        content: "Charlotte's Restaurants & Tea Rooms | In-Excess Garden Centres",
      },
      {
        property: "og:description",
        content: "View menus, find your nearest Charlotte's and book a table online.",
      },
    ],
  }),
  component: Index,
});

const galleryImages = ["/menus/rest-1.jpg", "/menus/rest-3.jpg", "/menus/rest-5.jpg", "/menus/rest-7.jpg"];

function Index() {
  return (
    <div className="min-h-screen">
      <SiteHeader />

      <section className="relative">
        <img
          src={hero}
          alt="Charlotte's Restaurant interior at In-Excess Fair Oak Garden Centre"
          className="h-[52vh] min-h-80 w-full object-cover"
        />
        <div className="absolute inset-0 bg-deep/65" />
        <div className="absolute inset-0 flex flex-col items-center justify-center px-5 text-center text-primary-foreground">
          <p className="text-xs uppercase tracking-[0.35em] text-brass">In-Excess Garden Centres</p>
          <h1 className="mt-4 max-w-3xl text-5xl sm:text-6xl">
            Charlotte's Restaurants &amp; Tea Rooms
          </h1>
          <div className="deco-rule my-6 w-48" />
          <p className="max-w-xl text-sm opacity-90 sm:text-base">
            An eclectic dining experience where art deco glamour meets botanical luxury — breakfasts,
            artisan light lunches and locally sourced sweet treats.
          </p>
          <Link
            to="/book"
            className="mt-8 rounded-sm border border-brass px-8 py-3 text-xs uppercase tracking-[0.22em] text-brass transition-colors hover:bg-brass hover:text-deep"
          >
            Book a table
          </Link>
        </div>
      </section>

      <main className="mx-auto max-w-6xl px-5 py-16">
        <h2 className="text-center text-4xl text-primary">Find your Charlotte's</h2>
        <div className="deco-rule mx-auto my-6 w-32" />
        <div className="grid gap-6 sm:grid-cols-2">
          {restaurants.map((r, i) => (
            <article
              key={r.slug}
              className="overflow-hidden rounded-sm border border-border bg-card shadow-[var(--shadow-soft)]"
            >
              <img
                src={galleryImages[i % galleryImages.length]}
                alt={`${r.name} dining room`}
                loading="lazy"
                className="h-48 w-full object-cover"
              />
              <div className="p-6">
                <h3 className="text-2xl text-primary">{r.name}</h3>
                <p className="mt-2 text-sm text-muted-foreground">{r.address.join(", ")}</p>
                <ul className="mt-3 space-y-0.5 text-sm text-muted-foreground">
                  {r.hours.map((h) => (
                    <li key={h}>{h}</li>
                  ))}
                </ul>
                <div className="mt-5 flex flex-wrap gap-3">
                  <Link
                    to="/restaurants/$slug"
                    params={{ slug: r.slug }}
                    className="rounded-sm bg-primary px-5 py-2.5 text-xs uppercase tracking-[0.18em] text-primary-foreground transition-opacity hover:opacity-90"
                  >
                    Menus &amp; location
                  </Link>
                  <a
                    href={`tel:${r.phone.replace(/\s/g, "")}`}
                    className="rounded-sm border border-border px-5 py-2.5 text-xs uppercase tracking-[0.18em] transition-colors hover:border-brass"
                  >
                    {r.phone}
                  </a>
                </div>
              </div>
            </article>
          ))}
        </div>
      </main>

      <SiteFooter />
    </div>
  );
}

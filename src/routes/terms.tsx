import { createFileRoute, Link } from "@tanstack/react-router";
import { SiteFooter, SiteHeader } from "@/components/SiteHeader";

export const Route = createFileRoute("/terms")({
  head: () => ({
    meta: [
      { title: "Terms & Conditions | Charlotte's Restaurants & Tea Rooms" },
      {
        name: "description",
        content:
          "Terms and conditions for Charlotte's Restaurants & Tea Rooms, provided by our parent company In-Excess Garden Centres.",
      },
      { property: "og:title", content: "Terms & Conditions | Charlotte's Restaurants & Tea Rooms" },
      {
        property: "og:description",
        content: "The In-Excess terms and conditions that apply to Charlotte's Restaurants & Tea Rooms.",
      },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary" },
    ],
  }),
  component: TermsPage,
});

function TermsPage() {
  return (
    <div className="flex min-h-screen flex-col">
      <SiteHeader />
      <main className="mx-auto flex w-full max-w-6xl flex-1 flex-col px-5 py-10">
        <p className="text-xs uppercase tracking-[0.35em] text-brass">In-Excess Garden Centres</p>
        <h1 className="mt-3 text-4xl text-primary">Terms &amp; Conditions</h1>
        <div className="deco-rule my-6 w-32" />
        <p className="max-w-2xl text-sm text-muted-foreground">
          Charlotte's Restaurants &amp; Tea Rooms are part of In-Excess Garden Centres, so the
          In-Excess terms and conditions apply to this app. You can also{" "}
          <a
            href="https://www.in-excess.com/pages/terms-conditions"
            target="_blank"
            rel="noopener noreferrer"
            className="text-brass underline underline-offset-4"
          >
            read them on the In-Excess website
          </a>
          .
        </p>
        <iframe
          src="https://www.in-excess.com/pages/terms-conditions"
          title="In-Excess terms and conditions"
          className="mt-8 min-h-[70vh] w-full flex-1 rounded-sm border border-border bg-card"
        />
        <Link
          to="/"
          className="mt-8 inline-block text-xs uppercase tracking-[0.22em] text-brass hover:opacity-80"
        >
          &larr; Back to Charlotte's
        </Link>
      </main>
      <SiteFooter />
    </div>
  );
}

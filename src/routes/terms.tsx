import { createFileRoute } from "@tanstack/react-router";
import { LegalPage } from "@/components/LegalPage";
import { termsBlocks } from "@/data/legal";

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
        content: "The In-Excess terms of service that apply to Charlotte's Restaurants & Tea Rooms.",
      },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary" },
    ],
  }),
  component: TermsPage,
});

function TermsPage() {
  return (
    <LegalPage
      eyebrow="In-Excess Garden Centres"
      title="Terms & Conditions"
      intro="Charlotte's Restaurants & Tea Rooms are part of In-Excess Garden Centres, so the In-Excess terms of service apply to this app. You can also"
      sourceUrl="https://www.in-excess.com/policies/terms-of-service"
      sourceLabel="read them on the In-Excess website"
      blocks={termsBlocks}
    />
  );
}

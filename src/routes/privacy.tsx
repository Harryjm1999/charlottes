import { createFileRoute } from "@tanstack/react-router";
import { LegalPage } from "@/components/LegalPage";
import { privacyBlocks } from "@/data/legal";

export const Route = createFileRoute("/privacy")({
  head: () => ({
    meta: [
      { title: "Privacy Policy | Charlotte's Restaurants & Tea Rooms" },
      {
        name: "description",
        content:
          "Privacy policy for Charlotte's Restaurants & Tea Rooms, provided by our parent company In-Excess Garden Centres.",
      },
      { property: "og:title", content: "Privacy Policy | Charlotte's Restaurants & Tea Rooms" },
      {
        property: "og:description",
        content: "How In-Excess handles your data at Charlotte's Restaurants & Tea Rooms.",
      },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary" },
    ],
  }),
  component: PrivacyPage,
});

function PrivacyPage() {
  return (
    <LegalPage
      eyebrow="In-Excess Garden Centres"
      title="Privacy Policy"
      intro="This policy covers the Charlotte's Restaurants & Tea Rooms app and table bookings. For the In-Excess garden centres and online shop, you can"
      sourceUrl="https://www.in-excess.com/policies/privacy-policy"
      sourceLabel="read the In-Excess privacy policy"
      blocks={privacyBlocks}
    />
  );
}

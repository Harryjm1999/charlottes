import { Link } from "@tanstack/react-router";
import { SiteFooter, SiteHeader } from "@/components/SiteHeader";
import type { LegalBlock } from "@/data/legal";

type LegalPageProps = {
  eyebrow: string;
  title: string;
  intro: string;
  sourceUrl: string;
  sourceLabel: string;
  blocks: LegalBlock[];
};

export function LegalPage({ eyebrow, title, intro, sourceUrl, sourceLabel, blocks }: LegalPageProps) {
  return (
    <div className="flex min-h-screen flex-col">
      <SiteHeader />
      <main className="mx-auto w-full max-w-3xl flex-1 px-5 py-10">
        <p className="text-xs uppercase tracking-[0.35em] text-brass">{eyebrow}</p>
        <h1 className="mt-3 text-4xl text-primary">{title}</h1>
        <div className="deco-rule my-6 w-32" />
        <p className="text-sm text-muted-foreground">
          {intro}{" "}
          <a
            href={sourceUrl}
            target="_blank"
            rel="noopener noreferrer"
            className="text-brass underline underline-offset-4"
          >
            {sourceLabel}
          </a>
          .
        </p>
        <article className="mt-10 space-y-4">
          {blocks.map((b, i) =>
            b.kind === "heading" ? (
              <h2 key={i} className="pt-6 text-2xl text-primary first:pt-0">
                {b.text}
              </h2>
            ) : b.kind === "list" ? (
              <p key={i} className="pl-5 text-sm leading-relaxed text-foreground/90">
                <span className="mr-2 text-brass">•</span>
                {b.text}
              </p>
            ) : (
              <p key={i} className="text-sm leading-relaxed text-foreground/90">
                {b.text}
              </p>
            ),
          )}
        </article>
        <Link
          to="/"
          className="mt-12 inline-block text-xs uppercase tracking-[0.22em] text-brass hover:opacity-80"
        >
          &larr; Back to Charlotte's
        </Link>
      </main>
      <SiteFooter />
    </div>
  );
}

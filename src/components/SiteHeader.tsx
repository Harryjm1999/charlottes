import { Link } from "@tanstack/react-router";
import logo from "@/assets/in-excess-logo.png";

export function SiteHeader() {
  return (
    <header className="panel-deep sticky top-0 z-40 border-b border-brass/30">
      <div className="mx-auto flex max-w-6xl items-center justify-between gap-4 px-5 py-4">
        <Link to="/" className="flex items-center gap-4">
          <img src={logo} alt="In-Excess Garden Centres logo" className="h-8 w-auto" />
          <span className="hidden font-display text-xl tracking-wide text-brass sm:block">
            Charlotte's
          </span>
        </Link>
        <nav className="flex items-center gap-6 text-sm uppercase tracking-[0.18em]">
          <Link to="/" className="opacity-80 transition-opacity hover:opacity-100">
            Restaurants
          </Link>
          <Link
            to="/book"
            className="rounded-sm border border-brass px-4 py-2 text-brass transition-colors hover:bg-brass hover:text-deep"
          >
            Book
          </Link>
        </nav>
      </div>
    </header>
  );
}

export function SiteFooter() {
  return (
    <footer className="panel-deep mt-24 border-t border-brass/30">
      <div className="mx-auto max-w-6xl px-5 py-10 text-sm opacity-80">
        <img src={logo} alt="In-Excess logo" className="mb-4 h-7 w-auto" />
        <p>
          Charlotte's Restaurants &amp; Tea Rooms are found inside In-Excess Garden Centres across
          Hampshire, Wiltshire and Dorset.
        </p>
      </div>
    </footer>
  );
}

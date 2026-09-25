import { Link, useNavigate } from "@tanstack/react-router";
import logo from "@/assets/in-excess-logo.png";
import { supabase } from "@/integrations/supabase/client";
import { useAuth } from "@/hooks/useAuth";

export function SiteHeader() {
  const { user } = useAuth();
  const navigate = useNavigate();
  return (
    <header className="panel-deep sticky top-0 z-40 border-b border-brass/30">
      <div className="mx-auto flex max-w-6xl items-center justify-between gap-4 px-5 py-4">
        <Link to="/" className="flex items-center gap-4">
          <img src={logo} alt="In-Excess Garden Centres logo" className="h-8 w-auto" />
          <span className="hidden font-display text-xl tracking-wide text-brass sm:block">
            Charlotte's
          </span>
        </Link>
        <nav className="flex items-center gap-4 text-sm uppercase tracking-[0.18em] sm:gap-6">
          <Link to="/" className="hidden opacity-80 transition-opacity hover:opacity-100 sm:inline">
            Restaurants
          </Link>
          {user ? (
            <>
              <Link to="/account" className="opacity-80 transition-opacity hover:opacity-100">
                Account
              </Link>
              <button
                onClick={async () => {
                  await supabase.auth.signOut();
                  navigate({ to: "/auth", replace: true });
                }}
                className="uppercase opacity-80 transition-opacity hover:opacity-100"
              >
                Sign out
              </button>
            </>
          ) : (
            <Link to="/auth" className="opacity-80 transition-opacity hover:opacity-100">
              Sign in
            </Link>
          )}
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

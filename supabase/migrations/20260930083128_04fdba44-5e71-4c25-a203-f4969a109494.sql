CREATE TABLE public.owner_emails (email text PRIMARY KEY);
GRANT ALL ON public.owner_emails TO service_role;
ALTER TABLE public.owner_emails ENABLE ROW LEVEL SECURITY;
INSERT INTO public.owner_emails(email) VALUES ('carl@in-excess.co.uk'),('harryjm1999@gmail.com');

CREATE TABLE public.staff_members (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text NOT NULL,
  restaurant_slug text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (email, restaurant_slug)
);
GRANT SELECT, INSERT, DELETE ON public.staff_members TO authenticated;
GRANT ALL ON public.staff_members TO service_role;
ALTER TABLE public.staff_members ENABLE ROW LEVEL SECURITY;

CREATE OR REPLACE FUNCTION public.current_confirmed_email(_user_id uuid)
RETURNS text LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT lower(email) FROM auth.users WHERE id = _user_id AND email_confirmed_at IS NOT NULL
$$;

CREATE OR REPLACE FUNCTION public.is_owner(_user_id uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (SELECT 1 FROM public.owner_emails o WHERE lower(o.email) = public.current_confirmed_email(_user_id))
$$;

CREATE OR REPLACE FUNCTION public.is_staff_for(_user_id uuid, _slug text)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT public.is_owner(_user_id)
    OR EXISTS (SELECT 1 FROM public.staff_assignments WHERE user_id = _user_id AND restaurant_slug = _slug)
    OR EXISTS (SELECT 1 FROM public.staff_members WHERE lower(email) = public.current_confirmed_email(_user_id) AND restaurant_slug = _slug)
$$;

CREATE OR REPLACE FUNCTION public.my_staff_access()
RETURNS TABLE(is_owner boolean, slugs text[]) LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT public.is_owner(auth.uid()),
    CASE WHEN public.is_owner(auth.uid()) THEN ARRAY['fair-oak','landford','ringwood','salisbury']
    ELSE ARRAY(
      SELECT restaurant_slug FROM public.staff_assignments WHERE user_id = auth.uid()
      UNION SELECT restaurant_slug FROM public.staff_members WHERE lower(email) = public.current_confirmed_email(auth.uid())
    ) END
$$;

REVOKE EXECUTE ON FUNCTION public.current_confirmed_email(uuid) FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.is_owner(uuid) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.my_staff_access() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.is_owner(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.my_staff_access() TO authenticated;

CREATE POLICY "Owners manage staff (select)" ON public.staff_members FOR SELECT TO authenticated USING (public.is_owner(auth.uid()));
CREATE POLICY "Owners manage staff (insert)" ON public.staff_members FOR INSERT TO authenticated WITH CHECK (public.is_owner(auth.uid()));
CREATE POLICY "Owners manage staff (delete)" ON public.staff_members FOR DELETE TO authenticated USING (public.is_owner(auth.uid()));

ALTER TABLE public.bookings ADD COLUMN source text NOT NULL DEFAULT 'online';
CREATE POLICY "Staff add restaurant bookings" ON public.bookings FOR INSERT TO authenticated WITH CHECK (public.is_staff_for(auth.uid(), restaurant_slug));

CREATE TABLE public.booking_notes (
  booking_id uuid PRIMARY KEY REFERENCES public.bookings(id) ON DELETE CASCADE,
  note text NOT NULL DEFAULT '',
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE ON public.booking_notes TO authenticated;
GRANT ALL ON public.booking_notes TO service_role;
ALTER TABLE public.booking_notes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Staff manage notes" ON public.booking_notes FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.bookings b WHERE b.id = booking_id AND public.is_staff_for(auth.uid(), b.restaurant_slug)))
  WITH CHECK (EXISTS (SELECT 1 FROM public.bookings b WHERE b.id = booking_id AND public.is_staff_for(auth.uid(), b.restaurant_slug)));
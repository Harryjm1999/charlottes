CREATE TABLE public.staff_assignments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  restaurant_slug text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, restaurant_slug)
);
GRANT SELECT ON public.staff_assignments TO authenticated;
GRANT ALL ON public.staff_assignments TO service_role;
ALTER TABLE public.staff_assignments ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Staff see own assignments" ON public.staff_assignments FOR SELECT TO authenticated USING (auth.uid() = user_id);

CREATE OR REPLACE FUNCTION public.is_staff_for(_user_id uuid, _slug text)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (SELECT 1 FROM public.staff_assignments WHERE user_id = _user_id AND restaurant_slug = _slug)
$$;

CREATE TABLE public.bookings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid,
  restaurant_slug text NOT NULL,
  name text NOT NULL,
  email text NOT NULL,
  phone text NOT NULL,
  booking_date date NOT NULL,
  booking_time text NOT NULL,
  guests int NOT NULL CHECK (guests BETWEEN 1 AND 20),
  notes text,
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','accepted','declined')),
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT INSERT ON public.bookings TO anon;
GRANT SELECT, INSERT, UPDATE ON public.bookings TO authenticated;
GRANT ALL ON public.bookings TO service_role;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Guests can request bookings" ON public.bookings FOR INSERT TO anon WITH CHECK (user_id IS NULL AND status = 'pending');
CREATE POLICY "Users can request bookings" ON public.bookings FOR INSERT TO authenticated WITH CHECK ((user_id IS NULL OR user_id = auth.uid()) AND status = 'pending');
CREATE POLICY "Customers see own bookings" ON public.bookings FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY "Staff see restaurant bookings" ON public.bookings FOR SELECT TO authenticated USING (public.is_staff_for(auth.uid(), restaurant_slug));
CREATE POLICY "Staff update restaurant bookings" ON public.bookings FOR UPDATE TO authenticated USING (public.is_staff_for(auth.uid(), restaurant_slug)) WITH CHECK (public.is_staff_for(auth.uid(), restaurant_slug));
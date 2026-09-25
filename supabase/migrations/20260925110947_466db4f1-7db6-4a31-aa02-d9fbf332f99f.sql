REVOKE EXECUTE ON FUNCTION public.is_staff_for(uuid, text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.is_staff_for(uuid, text) TO authenticated;
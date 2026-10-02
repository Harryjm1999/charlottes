create or replace function public.delete_own_account()
returns void
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  _uid uuid := auth.uid();
  _email text := public.current_confirmed_email(auth.uid());
begin
  if _uid is null then
    raise exception 'Not signed in';
  end if;
  -- Keep bookings so restaurants can honour them, but unlink them from the account
  update public.bookings set user_id = null where user_id = _uid;
  delete from public.staff_assignments where user_id = _uid;
  if _email is not null then
    delete from public.staff_members where lower(email) = _email;
  end if;
  delete from auth.users where id = _uid;
end;
$$;

revoke execute on function public.delete_own_account() from public, anon;
grant execute on function public.delete_own_account() to authenticated;
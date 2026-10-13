-- Coaches privacy fix.
-- Before: the policy "coaches_name_public_read" (qr-import-schema.sql) let anyone holding the public
-- key read every column of `coaches`, including email and role.
-- After: anon and authenticated users can only read (id, name) -- enough for the tracker to show the
-- coach name -- and each coach reads their own full profile through get_my_coach_profile().
--
-- Run in the Supabase SQL editor. Idempotent.

-- 1. Column-level privileges: only id and name are readable through the API.
revoke select on table public.coaches from anon, authenticated;
grant select (id, name) on table public.coaches to anon, authenticated;

-- 2. Row policy stays public (rows), now limited to the granted columns.
drop policy if exists "coaches_name_public_read" on public.coaches;
create policy "coaches_name_public_read" on public.coaches
  for select
  to anon, authenticated
  using (true);

-- 3. Full profile (email, role, ...) only for the signed-in coach.
create or replace function public.get_my_coach_profile()
returns setof public.coaches
language sql
stable
security definer
set search_path = public
as $$
  select * from public.coaches where id = auth.uid();
$$;

revoke all on function public.get_my_coach_profile() from public, anon;
grant execute on function public.get_my_coach_profile() to authenticated;

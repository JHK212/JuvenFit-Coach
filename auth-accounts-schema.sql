-- Cuentas de alumno (Supabase Auth email OTP) sobre el bridge existente.
-- Fase 1 del camino comercial: el alumno se loguea una vez, su cuenta queda
-- atada al athlete que su device ya tiene vinculado, y el historial vive en
-- el server -> cambiar de telefono ya no pierde nada.
--
-- Ejecutar en Supabase SQL Editor. Idempotente.
--
-- ADEMAS, en el Dashboard (una sola vez):
--   1. Auth > Providers > Email: habilitado (viene por default).
--   2. Auth > Email Templates > Magic Link: agregar {{ .Token }} al template
--      para que el mail traiga el CODIGO de 6 digitos (el default solo trae
--      link; el Tracker usa codigo, no link, para evitar redirects en la PWA).
--   3. El mailer built-in de Supabase tiene rate limit bajo (~2-4 mails/hora).
--      Alcanza para probar; para alumnos reales configurar SMTP propio en
--      Auth > SMTP (Resend/Brevo tier gratis sobra).

-- ============================================================
-- 1. athletes.user_id  (la cuenta duena del atleta)
-- ============================================================

alter table athletes add column if not exists user_id uuid references auth.users(id) on delete set null;
create unique index if not exists idx_athletes_user_id on athletes(user_id) where user_id is not null;

-- ============================================================
-- 2. sessions.free / extra  (flags que push_session perdia)
-- ============================================================
-- El Tracker manda free/extra en el payload pero la tabla no los guardaba ->
-- una restauracion devolvia sesiones libres/extra sin su flag.

alter table sessions add column if not exists free  boolean not null default false;
alter table sessions add column if not exists extra boolean not null default false;

create or replace function push_session(
  p_athlete_id    uuid,
  p_device_secret text,
  p_session       jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_hash       text;
  v_session_id text;
begin
  v_hash := encode(extensions.digest(p_device_secret, 'sha256'), 'hex');

  update athlete_devices
  set last_seen = now()
  where athlete_id = p_athlete_id and secret_hash = v_hash;
  if not found then
    raise exception 'device_unauthorized' using hint = 'device_secret no reconocido para ese atleta';
  end if;

  if octet_length(p_session::text) > 524288 then
    raise exception 'payload_too_large' using hint = 'El payload de la sesion supera 512 KB';
  end if;

  v_session_id := p_session->>'id';
  if v_session_id is null or char_length(v_session_id) = 0 then
    raise exception 'session_id_missing' using hint = 'El campo id es obligatorio';
  end if;

  insert into sessions (
    id, athlete_id, routine_id, session_date, session_time,
    day_id, exercises, accessories, mobility, metabolic, free, extra, synced_at
  ) values (
    v_session_id,
    p_athlete_id,
    nullif(p_session->>'routineId', '')::uuid,
    (p_session->>'date')::date,
    p_session->>'time',
    p_session->>'dayId',
    coalesce(p_session->'exercises',   '[]'::jsonb),
    coalesce(p_session->'accessories', '{}'::jsonb),
    coalesce(p_session->'mobility',    '{}'::jsonb),
    coalesce(p_session->'metabolic',   '{}'::jsonb),
    coalesce((p_session->>'free')::boolean,  false),
    coalesce((p_session->>'extra')::boolean, false),
    now()
  )
  on conflict (id) do update
    set routine_id   = excluded.routine_id,
        exercises    = excluded.exercises,
        accessories  = excluded.accessories,
        mobility     = excluded.mobility,
        metabolic    = excluded.metabolic,
        session_time = excluded.session_time,
        day_id       = excluded.day_id,
        free         = excluded.free,
        extra        = excluded.extra,
        synced_at    = now()
    where sessions.athlete_id = p_athlete_id;

  return jsonb_build_object('ok', true, 'id', v_session_id);
end;
$$;

grant execute on function push_session(uuid, text, jsonb) to anon, authenticated;

-- ============================================================
-- 3. claim_athlete_account  (login en device ya vinculado)
-- ============================================================
-- La cuenta logueada reclama el athlete cuyo device_secret ya conoce (probado
-- por hash). Idempotente. Un athlete solo puede pertenecer a una cuenta.

create or replace function claim_athlete_account(
  p_athlete_id    uuid,
  p_device_secret text
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_hash  text;
  v_owner uuid;
begin
  if auth.uid() is null then
    raise exception 'not_authenticated';
  end if;

  v_hash := encode(extensions.digest(p_device_secret, 'sha256'), 'hex');
  perform 1 from athlete_devices
  where athlete_id = p_athlete_id and secret_hash = v_hash;
  if not found then
    raise exception 'device_unauthorized' using hint = 'device_secret no reconocido para ese atleta';
  end if;

  select user_id into v_owner from athletes where id = p_athlete_id;
  if v_owner is not null and v_owner <> auth.uid() then
    raise exception 'athlete_already_claimed' using hint = 'Ese alumno ya esta atado a otra cuenta';
  end if;

  update athletes set user_id = auth.uid() where id = p_athlete_id;
  return jsonb_build_object('ok', true, 'athlete_id', p_athlete_id);
end;
$$;

grant execute on function claim_athlete_account(uuid, text) to authenticated;

-- ============================================================
-- 4. register_device_for_account  (telefono nuevo, sin QR)
-- ============================================================
-- Una cuenta que ya reclamo su athlete puede registrar un device nuevo sin
-- pasar por el QR del coach. Habilita el flujo: login -> restaurar todo.

create or replace function register_device_for_account(
  p_device_secret text,
  p_label         text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_athlete uuid;
  v_hash    text;
begin
  if auth.uid() is null then
    raise exception 'not_authenticated';
  end if;
  if char_length(p_device_secret) < 16 then
    raise exception 'secret_too_short';
  end if;

  select id into v_athlete from athletes where user_id = auth.uid();
  if v_athlete is null then
    raise exception 'no_athlete_for_account'
      using hint = 'La cuenta no tiene alumno asociado; escanear el QR del coach una vez';
  end if;

  v_hash := encode(extensions.digest(p_device_secret, 'sha256'), 'hex');
  insert into athlete_devices (athlete_id, secret_hash, label)
  values (v_athlete, v_hash, coalesce(p_label, 'restore'))
  on conflict (athlete_id, secret_hash)
  do update set last_seen = now();

  return jsonb_build_object('ok', true, 'athlete_id', v_athlete);
end;
$$;

grant execute on function register_device_for_account(text, text) to authenticated;

-- ============================================================
-- 5. get_my_sessions  (historial completo para restaurar)
-- ============================================================

create or replace function get_my_sessions()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_athlete uuid;
  v_out     jsonb;
begin
  if auth.uid() is null then
    raise exception 'not_authenticated';
  end if;

  select id into v_athlete from athletes where user_id = auth.uid();
  if v_athlete is null then
    return '[]'::jsonb;
  end if;

  select coalesce(jsonb_agg(jsonb_build_object(
    'id', s.id,
    'date', s.session_date,
    'time', s.session_time,
    'dayId', s.day_id,
    'exercises', s.exercises,
    'accessories', s.accessories,
    'mobility', s.mobility,
    'metabolic', s.metabolic,
    'free', s.free,
    'extra', s.extra
  ) order by s.session_date, s.session_time), '[]'::jsonb)
  into v_out
  from sessions s
  where s.athlete_id = v_athlete and s.deleted_at is null;

  return v_out;
end;
$$;

grant execute on function get_my_sessions() to authenticated;

-- ============================================================
-- 6. RLS: "todos los coaches leen todo" ya no puede ser "todo authenticated"
-- ============================================================
-- Con cuentas de alumno, los alumnos tambien son `authenticated`. Las policies
-- del roster compartido (2026-06-16) usaban `using (true)` para authenticated:
-- un alumno logueado podria leer sesiones/atletas/rutinas ajenos via PostgREST.
-- Se restringen a cuentas presentes en `coaches` (coaches.id = auth.users.id).

drop policy if exists "sessions_select_all_coaches" on sessions;
create policy "sessions_select_all_coaches" on sessions
  for select to authenticated
  using (exists (select 1 from coaches c where c.id = auth.uid()));

drop policy if exists "athletes_select_all_coaches" on athletes;
create policy "athletes_select_all_coaches" on athletes
  for select to authenticated
  using (exists (select 1 from coaches c where c.id = auth.uid()));

drop policy if exists "routines_select_all_coaches" on routines;
create policy "routines_select_all_coaches" on routines
  for select to authenticated
  using (exists (select 1 from coaches c where c.id = auth.uid()));

-- ============================================================
-- 7. Verificacion
-- ============================================================
-- select column_name from information_schema.columns
--   where table_name='athletes' and column_name='user_id';
-- select proname from pg_proc where proname in
--   ('claim_athlete_account','register_device_for_account','get_my_sessions');
-- select policyname, tablename from pg_policies
--   where tablename in ('sessions','athletes','routines') order by 2,1;

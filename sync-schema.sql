-- Schema para el bridge bidireccional Coach <-> Tracker.
-- Pairing sin password: el Tracker (anonimo) se vincula a un athlete_id via
-- device_secret local, y a partir de ahi lee su rutina activa y sube sesiones.
--
-- Ejecutar en Supabase SQL Editor. Idempotente.
--
-- Modelo de seguridad: el anon key es publico. Toda la proteccion descansa en
--   (a) tablas con RLS deny-by-default para anon, y
--   (b) RPCs security definer que validan el device_secret (hasheado SHA-256).
-- Quien robe un device_secret puede leer/escribir datos de ESE atleta, no de otros.

create extension if not exists pgcrypto;  -- digest() para SHA-256

-- ============================================================
-- 1. athlete_devices  (dispositivos vinculados a un atleta)
-- ============================================================
-- secret_hash = SHA-256 del device_secret. No guardamos el secret en claro:
-- si la tabla se filtrara, el hash no permite impersonar sin el preimage.
-- Varios devices por atleta (phone + tablet + reinstall de la PWA).

create table if not exists athlete_devices (
  id          uuid        primary key default gen_random_uuid(),
  athlete_id  uuid        not null references athletes(id) on delete cascade,
  secret_hash text        not null,
  label       text,
  created_at  timestamptz not null default now(),
  last_seen   timestamptz,
  unique (athlete_id, secret_hash)
);

create index if not exists idx_athlete_devices_athlete on athlete_devices(athlete_id);

alter table athlete_devices enable row level security;
-- Sin policies: deny-by-default. Solo accesible via las RPCs security definer.

-- ============================================================
-- 2. sessions  (sesiones completadas, espejo del Tracker)
-- ============================================================
-- id = uid() generado por el Tracker -> PK del cliente -> upsert idempotente.
-- routine_id permite segmentar el progreso por rutina/fase. Las sesiones cuelgan
-- del athlete_id, no de la rutina: cambiar de rutina NO borra historial.

create table if not exists sessions (
  id           text        primary key,
  athlete_id   uuid        not null references athletes(id) on delete cascade,
  routine_id   uuid        references routines(id) on delete set null,
  session_date date        not null,
  session_time text,
  day_id       text,
  exercises    jsonb       not null default '[]',
  accessories  jsonb       not null default '{}',
  mobility     jsonb       not null default '{}',
  metabolic    jsonb       not null default '{}',
  synced_at    timestamptz not null default now(),
  constraint sessions_id_nonempty check (char_length(id) > 0)
);

create index if not exists idx_sessions_athlete on sessions(athlete_id, session_date desc);

alter table sessions enable row level security;

-- El coach lee las sesiones de SUS atletas. Aislamiento entre coaches: la
-- subquery corre por row server-side, no se puede bypassear desde el cliente.
drop policy if exists "sessions_select_coach_own_athletes" on sessions;
create policy "sessions_select_coach_own_athletes" on sessions
  for select to authenticated
  using (
    exists (
      select 1 from athletes a
      where a.id = sessions.athlete_id
        and a.coach_id = auth.uid()
    )
  );
-- Sin policy de insert/update/delete: las sesiones entran solo via push_session.

-- ============================================================
-- 3. claim_athlete_device  (pairing inicial)
-- ============================================================
-- Solo vincula si el qr_token es vigente Y corresponde a una rutina active de
-- ese athlete exacto -> un anonimo no puede vincularse a un athlete_id adivinado.

create or replace function claim_athlete_device(
  p_athlete_id    uuid,
  p_qr_token      text,
  p_device_secret text,
  p_label         text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_routine_id uuid;
  v_hash       text;
begin
  if char_length(p_device_secret) < 16 then
    raise exception 'secret_too_short' using hint = 'device_secret debe tener al menos 16 caracteres';
  end if;

  select r.id into v_routine_id
  from routines r
  where r.qr_token      = p_qr_token
    and r.athlete_id    = p_athlete_id
    and r.status        = 'active'
    and r.qr_expires_at > now()
  limit 1;

  if v_routine_id is null then
    raise exception 'token_invalid' using hint = 'QR token invalido, expirado o no corresponde a ese atleta';
  end if;

  v_hash := encode(digest(p_device_secret, 'sha256'), 'hex');

  insert into athlete_devices (athlete_id, secret_hash, label)
  values (p_athlete_id, v_hash, p_label)
  on conflict (athlete_id, secret_hash)
  do update set last_seen = now(),
                label     = coalesce(excluded.label, athlete_devices.label);

  return jsonb_build_object('ok', true, 'athlete_id', p_athlete_id);
end;
$$;

grant execute on function claim_athlete_device(uuid, text, text, text) to anon, authenticated;

-- ============================================================
-- 4. push_session  (subida de sesiones Tracker -> Supabase)
-- ============================================================
-- Valida (athlete_id, device_secret), upsert idempotente por id, tope de payload.

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
  v_hash := encode(digest(p_device_secret, 'sha256'), 'hex');

  update athlete_devices
  set last_seen = now()
  where athlete_id = p_athlete_id and secret_hash = v_hash;
  if not found then
    raise exception 'device_unauthorized' using hint = 'device_secret no reconocido para ese atleta';
  end if;

  if octet_length(p_session::text) > 524288 then  -- 512 KB
    raise exception 'payload_too_large' using hint = 'El payload de la sesion supera 512 KB';
  end if;

  v_session_id := p_session->>'id';
  if v_session_id is null or char_length(v_session_id) = 0 then
    raise exception 'session_id_missing' using hint = 'El campo id es obligatorio';
  end if;

  insert into sessions (
    id, athlete_id, routine_id, session_date, session_time,
    day_id, exercises, accessories, mobility, metabolic, synced_at
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
        synced_at    = now()
    where sessions.athlete_id = p_athlete_id;  -- no se puede robar una sesion de otro atleta

  return jsonb_build_object('ok', true, 'id', v_session_id);
end;
$$;

grant execute on function push_session(uuid, text, jsonb) to anon, authenticated;

-- ============================================================
-- 5. get_active_routine  (pull estable, sin token perecedero)
-- ============================================================
-- El qr_token expira a los 7 dias -> mala UX para el poll continuo. El device
-- vinculado lee su rutina activa por athlete_id. La RLS publica por qr_token
-- sigue intacta para el PRIMER import (antes de existir el device).

create or replace function get_active_routine(
  p_athlete_id    uuid,
  p_device_secret text
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_hash    text;
  v_routine jsonb;
begin
  v_hash := encode(digest(p_device_secret, 'sha256'), 'hex');

  update athlete_devices
  set last_seen = now()
  where athlete_id = p_athlete_id and secret_hash = v_hash;
  if not found then
    raise exception 'device_unauthorized' using hint = 'device_secret no reconocido para ese atleta';
  end if;

  -- Sin qr_token/qr_expires_at: el atleta no los necesita y no deben loguearse.
  select to_jsonb(r.*) - 'qr_token' - 'qr_expires_at' into v_routine
  from routines r
  where r.athlete_id = p_athlete_id and r.status = 'active'
  limit 1;

  return v_routine;  -- null si no hay rutina activa
end;
$$;

grant execute on function get_active_routine(uuid, text) to anon, authenticated;

-- ============================================================
-- 6. Verificacion
-- ============================================================
-- Las policies existentes (routines_qr_public_read, coaches_name_public_read)
-- quedan intactas. Confirmar policies tras correr este schema:
--
-- select policyname, tablename, cmd, roles::text from pg_policies
-- where tablename in ('routines','coaches','sessions','athlete_devices')
-- order by tablename, policyname;

-- Flag "plaza" en sesiones (modo plaza: día de rutina con ejercicios
-- sustituidos por equivalentes bodyweight). Ejecutar en Supabase SQL Editor
-- (ya corrido vía Management API el 2026-09-22). Idempotente.

alter table sessions add column if not exists plaza boolean not null default false;

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
    day_id, exercises, accessories, mobility, metabolic, free, extra, plaza, synced_at
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
    coalesce((p_session->>'plaza')::boolean, false),
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
        plaza        = excluded.plaza,
        synced_at    = now()
    where sessions.athlete_id = p_athlete_id;

  return jsonb_build_object('ok', true, 'id', v_session_id);
end;
$$;

grant execute on function push_session(uuid, text, jsonb) to anon, authenticated;

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
    'extra', s.extra,
    'plaza', s.plaza
  ) order by s.session_date, s.session_time), '[]'::jsonb)
  into v_out
  from sessions s
  where s.athlete_id = v_athlete and s.deleted_at is null;

  return v_out;
end;
$$;

grant execute on function get_my_sessions() to authenticated;

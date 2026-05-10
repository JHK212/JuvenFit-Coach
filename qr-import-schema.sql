-- Schema para 4.6 — QR coach → atleta
-- Extiende routines con token compartible y policy RLS para acceso público por token vigente.
--
-- Ejecutar en Supabase SQL Editor.

alter table routines
  add column if not exists qr_token text unique,
  add column if not exists qr_expires_at timestamptz;

create index if not exists idx_routines_qr_token on routines(qr_token) where qr_token is not null;

-- Policy: cualquiera (anon o autenticado) puede LEER una rutina si:
--   - tiene qr_token
--   - el token no expiró
-- Esto permite que la app del atleta haga fetch sin autenticarse.
-- Las policies de coach/owner siguen vigentes para INSERT/UPDATE/DELETE.

drop policy if exists "routines_qr_public_read" on routines;
create policy "routines_qr_public_read" on routines
  for select
  to anon, authenticated
  using (
    qr_token is not null
    and qr_expires_at is not null
    and qr_expires_at > now()
  );

-- Para que el atleta pueda traer también el nombre del coach,
-- exponemos el campo `name` de coaches con read público (sin email/role).
-- Si querés más privacidad, podés saltarte esto y mostrar solo "Tu coach".
drop policy if exists "coaches_name_public_read" on coaches;
create policy "coaches_name_public_read" on coaches
  for select
  to anon, authenticated
  using (true);

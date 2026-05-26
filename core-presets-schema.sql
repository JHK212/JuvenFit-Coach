-- Schema para presets de circuitos de Core (5.x)
-- Cada coach tiene sus propios presets reusables: un grupo (biserie/triserie/×4)
-- con N vueltas, descanso y una lista ordenada de exercise_ids.
--
-- Ejecutar en Supabase SQL Editor.

create table if not exists core_presets (
  id           uuid primary key default gen_random_uuid(),
  coach_id     uuid not null references coaches(id) on delete cascade,
  name         text not null,
  size         int  not null check (size between 2 and 4),
  rounds       int  not null check (rounds between 1 and 20) default 3,
  rest         text not null default '60 segs',
  exercise_ids text[] not null default '{}',
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

create index if not exists idx_core_presets_coach on core_presets(coach_id);

alter table core_presets enable row level security;

drop policy if exists "core_presets_select_own" on core_presets;
create policy "core_presets_select_own" on core_presets
  for select to authenticated
  using (coach_id = auth.uid());

drop policy if exists "core_presets_insert_own" on core_presets;
create policy "core_presets_insert_own" on core_presets
  for insert to authenticated
  with check (coach_id = auth.uid());

drop policy if exists "core_presets_update_own" on core_presets;
create policy "core_presets_update_own" on core_presets
  for update to authenticated
  using (coach_id = auth.uid())
  with check (coach_id = auth.uid());

drop policy if exists "core_presets_delete_own" on core_presets;
create policy "core_presets_delete_own" on core_presets
  for delete to authenticated
  using (coach_id = auth.uid());

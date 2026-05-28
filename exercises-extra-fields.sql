-- Migration: campos extra de la biblioteca de ejercicios (5.x)
-- Pedido del coach: nivel, dificultad técnica, fatiga, restricciones.
-- "Subcategoría" se mapea al campo existente `movement` (solo cambia el label en UI).
--
-- Ejecutar en Supabase SQL Editor.

alter table exercises
  add column if not exists level text
    check (level in ('principiante','intermedio','avanzado')),
  add column if not exists technical_difficulty text
    check (technical_difficulty in ('baja','media','alta')),
  add column if not exists fatigue text
    check (fatigue in ('baja','media','alta')),
  add column if not exists restrictions text[] not null default '{}';

-- Índice GIN para búsquedas por restricción (filtro de biblioteca)
create index if not exists idx_exercises_restrictions on exercises using gin (restrictions);

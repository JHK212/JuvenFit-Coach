-- Migration 5.x · agregar duration_secs a core_presets
-- Los circuitos de core se ejecutan por tiempo (30s, 60s, etc.) aunque el ejercicio
-- normalmente sea por reps. El profe elige el tiempo del circuito (intermedio = 30s,
-- avanzado = 60s, etc.) y aplica a todos los ej. del grupo.
--
-- Ejecutar en Supabase SQL Editor.

alter table core_presets
  add column if not exists duration_secs int not null default 30
    check (duration_secs between 5 and 600);

-- Clasificación de ejercicios — valores de clasificacion-ejercicios.html + correcciones del profe (jun 2026).
-- Correcciones aplicadas: Sentadilla con barra (dif media), Hip thrust (dif baja),
--   Remo con barra (fatiga alta), Plancha lateral (nivel principiante, dif baja, fatiga baja).
-- Restricción nueva 'muneca' incrustada en: Curl con barra, Press francés, Flexiones,
--   Fondos en paralelas, Plancha, Press militar.
-- NO toca 'movement' (subcategoría) — el HTML no la clasificó.
-- Pendiente/manual: "Sentadilla frontal" (no está en la lista) y "Dominadas" (muñeca solo "algunos casos").
--
-- ⚠️ Match por NOMBRE. Antes de correr, verificá con:
--     SELECT name FROM exercises ORDER BY name;
--   Si algún UPDATE da "0 rows affected", el nombre en tu base difiere — ajustalo.

UPDATE exercises SET level='intermedio',   technical_difficulty='media', fatigue='alta',  restrictions='{lumbar,rodilla,movilidad_limitada}'::text[] WHERE name='sentadilla con barra';
UPDATE exercises SET level='avanzado',      technical_difficulty='alta',  fatigue='alta',  restrictions='{lumbar,movilidad_limitada}'::text[]         WHERE name='Peso muerto con barra';
UPDATE exercises SET level='intermedio',   technical_difficulty='media', fatigue='alta',  restrictions='{lumbar}'::text[]                            WHERE name='Peso muerto mancuernas';
UPDATE exercises SET level='intermedio',   technical_difficulty='alta',  fatigue='alta',  restrictions='{lumbar}'::text[]                            WHERE name='Peso muerto rumano';
UPDATE exercises SET level='intermedio',   technical_difficulty='baja',  fatigue='alta',  restrictions='{lumbar}'::text[]                            WHERE name='Hip thrust';
UPDATE exercises SET level='avanzado',      technical_difficulty='alta',  fatigue='alta',  restrictions='{rodilla}'::text[]                           WHERE name='Búlgaras';
UPDATE exercises SET level='principiante', technical_difficulty='baja',  fatigue='media', restrictions='{rodilla}'::text[]                           WHERE name='Step up';
UPDATE exercises SET level='principiante', technical_difficulty='baja',  fatigue='baja',  restrictions='{}'::text[]                                  WHERE name='Gemelos de pie';
UPDATE exercises SET level='intermedio',   technical_difficulty='media', fatigue='media', restrictions='{hombro}'::text[]                            WHERE name='Press banca plano';
UPDATE exercises SET level='intermedio',   technical_difficulty='media', fatigue='media', restrictions='{hombro}'::text[]                            WHERE name='Press banca mancuernas';
UPDATE exercises SET level='intermedio',   technical_difficulty='media', fatigue='media', restrictions='{hombro}'::text[]                            WHERE name='Press inclinado con barra';
UPDATE exercises SET level='intermedio',   technical_difficulty='media', fatigue='media', restrictions='{hombro}'::text[]                            WHERE name='Press inclinado mancuernas';
UPDATE exercises SET level='avanzado',      technical_difficulty='alta',  fatigue='alta',  restrictions='{hombro,lumbar,movilidad_limitada,muneca}'::text[] WHERE name='Press militar';
UPDATE exercises SET level='intermedio',   technical_difficulty='media', fatigue='media', restrictions='{hombro}'::text[]                            WHERE name='Press mancuernas sentado';
UPDATE exercises SET level='principiante', technical_difficulty='baja',  fatigue='media', restrictions='{hombro,muneca}'::text[]                     WHERE name='Flexiones';
UPDATE exercises SET level='avanzado',      technical_difficulty='alta',  fatigue='alta',  restrictions='{hombro,muneca}'::text[]                     WHERE name='Fondos en paralelas';
UPDATE exercises SET level='intermedio',   technical_difficulty='media', fatigue='media', restrictions='{hombro}'::text[]                            WHERE name='Aperturas en banco plano';
UPDATE exercises SET level='intermedio',   technical_difficulty='media', fatigue='alta',  restrictions='{lumbar}'::text[]                            WHERE name='Remo con barra';
UPDATE exercises SET level='principiante', technical_difficulty='baja',  fatigue='media', restrictions='{lumbar}'::text[]                            WHERE name='Remo con mancuerna';
UPDATE exercises SET level='intermedio',   technical_difficulty='media', fatigue='media', restrictions='{}'::text[]                                  WHERE name='Remo australiano';
UPDATE exercises SET level='avanzado',      technical_difficulty='alta',  fatigue='alta',  restrictions='{hombro,movilidad_limitada}'::text[]         WHERE name='Dominadas';
UPDATE exercises SET level='principiante', technical_difficulty='baja',  fatigue='baja',  restrictions='{}'::text[]                                  WHERE name='Face pull (banda)';
UPDATE exercises SET level='principiante', technical_difficulty='baja',  fatigue='baja',  restrictions='{}'::text[]                                  WHERE name='Pájaros';
UPDATE exercises SET level='principiante', technical_difficulty='baja',  fatigue='baja',  restrictions='{hombro}'::text[]                            WHERE name='Elevaciones laterales';
UPDATE exercises SET level='principiante', technical_difficulty='baja',  fatigue='baja',  restrictions='{hombro}'::text[]                            WHERE name='Elevaciones frontales';
UPDATE exercises SET level='principiante', technical_difficulty='baja',  fatigue='baja',  restrictions='{}'::text[]                                  WHERE name='Encogimientos';
UPDATE exercises SET level='principiante', technical_difficulty='baja',  fatigue='baja',  restrictions='{muneca}'::text[]                            WHERE name='Curl con barra';
UPDATE exercises SET level='principiante', technical_difficulty='baja',  fatigue='baja',  restrictions='{}'::text[]                                  WHERE name='Curl alternado mancuernas';
UPDATE exercises SET level='principiante', technical_difficulty='baja',  fatigue='baja',  restrictions='{}'::text[]                                  WHERE name='Curl martillo';
UPDATE exercises SET level='principiante', technical_difficulty='baja',  fatigue='baja',  restrictions='{hombro}'::text[]                            WHERE name='Extensión de tríceps';
UPDATE exercises SET level='intermedio',   technical_difficulty='media', fatigue='baja',  restrictions='{hombro}'::text[]                            WHERE name='Rompecráneo';
UPDATE exercises SET level='intermedio',   technical_difficulty='media', fatigue='baja',  restrictions='{hombro,muneca}'::text[]                     WHERE name='Press francés';
UPDATE exercises SET level='principiante', technical_difficulty='baja',  fatigue='baja',  restrictions='{}'::text[]                                  WHERE name='Patada de tríceps';
UPDATE exercises SET level='principiante', technical_difficulty='baja',  fatigue='media', restrictions='{muneca}'::text[]                            WHERE name='Plancha';
UPDATE exercises SET level='principiante', technical_difficulty='baja',  fatigue='baja',  restrictions='{hombro}'::text[]                            WHERE name='Plancha lateral';
UPDATE exercises SET level='principiante', technical_difficulty='baja',  fatigue='media', restrictions='{lumbar}'::text[]                            WHERE name='Abdominales';
UPDATE exercises SET level='intermedio',   technical_difficulty='media', fatigue='media', restrictions='{lumbar}'::text[]                            WHERE name='Elevaciones de piernas';

-- Sentadilla frontal: NO estaba en el HTML revisado por el profe. Clasificación propuesta
-- por criterio (front rack → muñeca/movilidad). CONFIRMAR con el profe antes de dar por buena.
UPDATE exercises SET level='avanzado',      technical_difficulty='alta',  fatigue='alta',  restrictions='{lumbar,rodilla,movilidad_limitada,muneca}'::text[] WHERE name='sentadilla frontal';


-- ════════════════════════════════════════════════════════════════════════
-- BORRADOR — ejercicios que NO estaban en el HTML revisado por el profe.
-- Clasificados por criterio (mismas reglas del HTML). NADIE los confirmó: revisar.
-- 'muneca' agregada donde hay apoyo de manos / front rack.
-- ════════════════════════════════════════════════════════════════════════

-- MOVILIDAD — default parejo (principiante / baja / baja, sin restricciones).
UPDATE exercises SET level='principiante', technical_difficulty='baja', fatigue='baja', restrictions='{}'::text[] WHERE name IN (
  '90/90 hip flow',
  'Apertura de pecho con foam roller',
  'CARs de cadera',
  'CARs de hombro',
  'Colgado pasivo',
  'Cossack squat',
  'Dorsiflexion de tobillo',
  'Gato bueno Gato malo',
  'Inchworm/gusanito',
  'Movilidad Pecho y Hombro con Banda',
  'Perro abajo → cobra',
  'Rotación T-spine en cuadrupedia',
  'spider man'
);

-- CORE
UPDATE exercises SET level='principiante', technical_difficulty='baja', fatigue='baja', restrictions='{lumbar}'::text[]  WHERE name='Espinales';
UPDATE exercises SET level='principiante', technical_difficulty='baja', fatigue='baja', restrictions='{hombro}'::text[]  WHERE name='T I W';

-- AISLACIÓN (core / bodyweight)
UPDATE exercises SET level='principiante', technical_difficulty='baja', fatigue='baja',  restrictions='{}'::text[]              WHERE name='Bicho muerto';
UPDATE exercises SET level='principiante', technical_difficulty='baja', fatigue='baja',  restrictions='{lumbar}'::text[]        WHERE name='Bici Abdominal';
UPDATE exercises SET level='principiante', technical_difficulty='baja', fatigue='media', restrictions='{muneca}'::text[]        WHERE name='Escaladores';
UPDATE exercises SET level='principiante', technical_difficulty='baja', fatigue='baja',  restrictions='{lumbar}'::text[]        WHERE name='Giros Rusos';
UPDATE exercises SET level='principiante', technical_difficulty='baja', fatigue='baja',  restrictions='{rodilla}'::text[]       WHERE name='Isometrico Cuadriceps';
UPDATE exercises SET level='principiante', technical_difficulty='baja', fatigue='media', restrictions='{muneca,hombro}'::text[] WHERE name='Plancha Alta Toque de Hombros';
UPDATE exercises SET level='principiante', technical_difficulty='baja', fatigue='media', restrictions='{muneca,hombro}'::text[] WHERE name='Plancha Alta/Baja';
UPDATE exercises SET level='intermedio',   technical_difficulty='media',fatigue='media', restrictions='{hombro,muneca}'::text[] WHERE name='Plancha en V';
UPDATE exercises SET level='principiante', technical_difficulty='baja', fatigue='baja',  restrictions='{}'::text[]              WHERE name='Puente de Gluteo Unilateral';
UPDATE exercises SET level='intermedio',   technical_difficulty='media',fatigue='media', restrictions='{lumbar,hombro,muneca}'::text[] WHERE name='Rueda Abdominal';
UPDATE exercises SET level='principiante', technical_difficulty='baja', fatigue='baja',  restrictions='{rodilla}'::text[]       WHERE name='sentadilla en pared';
-- (guess) plancha barquito = hollow/boat hold:
UPDATE exercises SET level='principiante', technical_difficulty='baja', fatigue='baja',  restrictions='{}'::text[]              WHERE name='plancha barquito';
-- (guess) sentadilla con rotación = movilidad de cadera con sentadilla:
UPDATE exercises SET level='principiante', technical_difficulty='baja', fatigue='baja',  restrictions='{}'::text[]              WHERE name='Sentadilla con Rotacion de Cadera';

-- COMPOUND (variantes de fuerza)
UPDATE exercises SET level='intermedio',   technical_difficulty='media',fatigue='media', restrictions='{lumbar,movilidad_limitada}'::text[] WHERE name='Buenos dias';
UPDATE exercises SET level='intermedio',   technical_difficulty='media',fatigue='media', restrictions='{rodilla}'::text[]                   WHERE name='Estocadas con mancuernas';
UPDATE exercises SET level='principiante', technical_difficulty='baja', fatigue='media', restrictions='{hombro,muneca}'::text[]             WHERE name='Flexiones Diamante';
UPDATE exercises SET level='intermedio',   technical_difficulty='media',fatigue='media', restrictions='{hombro,muneca}'::text[]             WHERE name='Flexiones en Pica';
UPDATE exercises SET level='principiante', technical_difficulty='baja', fatigue='baja',  restrictions='{}'::text[]                          WHERE name='Puente de Gluteo';
UPDATE exercises SET level='principiante', technical_difficulty='baja', fatigue='media', restrictions='{rodilla}'::text[]                   WHERE name='sentadilla copa';
UPDATE exercises SET level='intermedio',   technical_difficulty='media',fatigue='alta',  restrictions='{lumbar,rodilla,movilidad_limitada}'::text[] WHERE name='sentadilla pausa';
UPDATE exercises SET level='intermedio',   technical_difficulty='media',fatigue='media', restrictions='{rodilla,lumbar}'::text[]            WHERE name='sentadilla sumo';

-- Antes "no sé qué son", ya definidos por Joaco:
UPDATE exercises SET level='principiante', technical_difficulty='baja', fatigue='baja', restrictions='{hombro}'::text[] WHERE name='Copa';          -- ext. tríceps overhead 2 manos
UPDATE exercises SET level='principiante', technical_difficulty='baja', fatigue='baja', restrictions='{lumbar}'::text[] WHERE name='Cortitos 90°';  -- crunches
UPDATE exercises SET level='principiante', technical_difficulty='baja', fatigue='baja', restrictions='{lumbar}'::text[] WHERE name='Toco Arriba';   -- abs piernas al techo, toque de talones

-- ════════════════════════════════════════════════════════════════════════
-- Recategorizar abdominales → category 'core' (estaban en 'aislacion').
-- ('Escaladores' incluido por ser core dinámico; sacalo del IN si no querés.)
-- ════════════════════════════════════════════════════════════════════════
UPDATE exercises SET category='core' WHERE name IN (
  'Abdominales',
  'Elevaciones de piernas',
  'Plancha',
  'Plancha lateral',
  'Bicho muerto',
  'Bici Abdominal',
  'Cortitos 90°',
  'Giros Rusos',
  'Plancha Alta Toque de Hombros',
  'Plancha Alta/Baja',
  'plancha barquito',
  'Plancha en V',
  'Rueda Abdominal',
  'Toco Arriba',
  'Escaladores'
);

-- ════════════════════════════════════════════════════════════════════════
-- Review de categorías (jun 2026): correcciones aceptadas por Joaco.
-- ════════════════════════════════════════════════════════════════════════
UPDATE exercises SET category='aislacion' WHERE name='T I W';                       -- elevaciones de hombro en prono, no core
UPDATE exercises SET category='compound'  WHERE name='Puente de Gluteo Unilateral'; -- igualar con Puente de Gluteo (compound)

-- ════════════════════════════════════════════════════════════════════════
-- Fusión de duplicados (jun 2026).
--   'fondos' (Fondos en paralelas, compound)  ← KEEP  | borrar 'fondos-2' (Fondos)
--   'sentadilla-con-barra' (tiene equipment)  ← KEEP  | borrar 'sentadilla-barra'
-- Enriquecer ganador Fondos (idempotente, seguro):
UPDATE exercises SET aliases='{"Dips","Fondos"}'::text[] WHERE id='fondos';
--
-- ⚠️ El resto corré A MANO, en este orden, tras verificar referencias (checks abajo):
--   1) checks:
--      SELECT name FROM core_presets WHERE 'fondos-2'=ANY(exercise_ids) OR 'sentadilla-barra'=ANY(exercise_ids);
--      SELECT id FROM routines t WHERE to_jsonb(t)::text LIKE '%fondos-2%' OR to_jsonb(t)::text LIKE '%sentadilla-barra%';
--   2) si ambos dan 0 filas, borrar perdedores:
--      DELETE FROM exercises WHERE id IN ('fondos-2','sentadilla-barra');
--   3) recién ahí renombrar el ganador (borrar antes evita choque si 'name' fuera único):
--      UPDATE exercises SET name='Sentadilla con barra',
--             aliases='{"back squat","sentadilla trasera","Squat","Sentadilla"}'::text[]
--        WHERE id='sentadilla-con-barra';

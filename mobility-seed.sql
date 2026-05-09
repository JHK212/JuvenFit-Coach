-- Seed de movilidades para JuvenFit-Coach
-- Ejecutar en Supabase SQL Editor cuando esté lista la categoría 'movilidad'.
--
-- Si la columna `category` tiene un CHECK constraint que solo permite ('compound','aislacion'),
-- antes de insertar hay que actualizar el constraint:
--
--   alter table exercises drop constraint if exists exercises_category_check;
--   alter table exercises add constraint exercises_category_check
--     check (category in ('compound','aislacion','movilidad'));
--
-- (Si no hay constraint, los inserts pasan directo.)

insert into exercises (id, name, aliases, category, movement, equipment, muscle_activation, similar_ids, cues, scope) values
  ('cat-cow', 'Cat-cow (gato-camello)', array['gato camello','cat camel'], 'movilidad', 'core', 'peso corporal', '{}'::jsonb, array[]::text[], 'Sincronizá respiración: inhalá al arquear, exhalá al redondear. Movimiento desde la columna, no desde el cuello.', 'official'),
  ('t-spine-rotacion-cuadrupedia', 'Rotación T-spine en cuadrupedia', array['thread the needle','enhebrar la aguja'], 'movilidad', 'core', 'peso corporal', '{}'::jsonb, array[]::text[], 'Mano detrás de la cabeza, rotá llevando el codo al techo y al piso. Cadera fija.', 'official'),
  ('worlds-greatest-stretch', 'World''s greatest stretch', array['estiramiento del mundo','wgs'], 'movilidad', 'core', 'peso corporal', '{}'::jsonb, array[]::text[], 'Lunge profundo, mano interna al piso, rotá llevando la otra mano al techo. Alterná lados.', 'official'),
  ('hip-flow-90-90', '90/90 hip flow', array['90 90','rotacion cadera'], 'movilidad', 'core', 'peso corporal', '{}'::jsonb, array[]::text[], 'Sentado con ambas rodillas a 90°, alterná lados pasando por el centro sin usar manos.', 'official'),
  ('cars-hombro', 'CARs de hombro', array['controlled articular rotations hombro','rotaciones controladas hombro'], 'movilidad', 'core', 'peso corporal', '{}'::jsonb, array[]::text[], 'Círculos lentos y máximos del hombro. Mantené el resto del cuerpo inmóvil.', 'official'),
  ('cars-cadera', 'CARs de cadera', array['controlled articular rotations cadera','rotaciones controladas cadera'], 'movilidad', 'core', 'peso corporal', '{}'::jsonb, array[]::text[], 'En cuadrupedia o de pie, rotación máxima de cadera dibujando un círculo. Tronco quieto.', 'official'),
  ('cossack-squat', 'Cossack squat', array['sentadilla cossack','sentadilla lateral'], 'movilidad', 'core', 'peso corporal', '{}'::jsonb, array[]::text[], 'Pies anchos, bajá a un lado manteniendo el otro pie estirado. Talón apoyado.', 'official'),
  ('inchworm', 'Inchworm', array['gusano','walkout'], 'movilidad', 'core', 'peso corporal', '{}'::jsonb, array[]::text[], 'De pie, manos al piso, caminá con manos hasta plancha y volvé. Piernas lo más rectas posibles.', 'official'),
  ('perro-cobra', 'Perro abajo → cobra', array['down dog cobra','flow yoga'], 'movilidad', 'core', 'peso corporal', '{}'::jsonb, array[]::text[], 'Alterná entre downward dog y cobra. Empujá con manos en perro, abrí pecho en cobra.', 'official'),
  ('knee-to-wall', 'Knee to wall (movilidad de tobillo)', array['movilidad tobillo','dorsiflexion'], 'movilidad', 'core', 'peso corporal', '{}'::jsonb, array[]::text[], 'Rodilla hacia la pared sin levantar el talón. Buscá distancia progresiva del pie.', 'official'),
  ('glute-bridge-activacion', 'Glute bridge (activación)', array['puente de gluteo','hip bridge'], 'movilidad', 'core', 'peso corporal', '{}'::jsonb, array[]::text[], 'Pies cerca de los glúteos, empujá con talones, contraé glúteo arriba. No arquees lumbar.', 'official'),
  ('apertura-pecho-foam-roller', 'Apertura de pecho con foam roller', array['t-spine foam roller','extension toracica'], 'movilidad', 'core', 'peso corporal', '{}'::jsonb, array[]::text[], 'Foam roller bajo escápulas, manos detrás de cabeza, dejá caer el pecho hacia atrás.', 'official')
on conflict (id) do nothing;

USE bdapp_metro;

ALTER TABLE detalle_orden
    ADD COLUMN IF NOT EXISTS hora_inicio TIME NULL AFTER cant_tec,
    ADD COLUMN IF NOT EXISTS hora_fin TIME NULL AFTER hora_inicio;

UPDATE detalle_orden
SET
    hora_inicio = COALESCE(hora_inicio, hora_ini_pre, hora_ini_tra, hora_ini_eje),
    hora_fin = COALESCE(hora_fin, hora_fin_eje, hora_fin_tra, hora_fin_pre)
WHERE hora_inicio IS NULL
   OR hora_fin IS NULL;

UPDATE herramientaot
SET estadoot = 'ASIGNADA'
WHERE estadoot IS NULL
   OR TRIM(estadoot) = '';

ALTER TABLE herramientaot
    MODIFY COLUMN estadoot varchar(60) NOT NULL DEFAULT 'ASIGNADA' COMMENT 'Estado o condición de la herramienta dentro de la OT';

CREATE INDEX IF NOT EXISTS idx_detalle_ot_fecha ON detalle_orden (n_ot, fecha);
CREATE INDEX IF NOT EXISTS idx_herramientaot_ot_estado ON herramientaot (n_ot, estadoot);

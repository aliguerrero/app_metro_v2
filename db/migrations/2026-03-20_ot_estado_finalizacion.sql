USE bdapp_metro;

ALTER TABLE orden_trabajo
    ADD COLUMN IF NOT EXISTS ot_finalizada TINYINT(1) NOT NULL DEFAULT 0 AFTER mes,
    ADD COLUMN IF NOT EXISTS fecha_finalizacion DATETIME NULL AFTER ot_finalizada,
    ADD COLUMN IF NOT EXISTS id_user_finaliza VARCHAR(30) NULL AFTER fecha_finalizacion,
    ADD COLUMN IF NOT EXISTS id_ai_estado INT(11) NULL AFTER id_ai_sitio;

SET @estado_ejecutada := (
    SELECT id_ai_estado
    FROM estado_ot
    WHERE UPPER(nombre_estado) = 'EJECUTADA'
      AND std_reg = 1
    ORDER BY id_ai_estado ASC
    LIMIT 1
);

UPDATE orden_trabajo
SET ot_finalizada = CASE
        WHEN id_ai_estado = COALESCE(@estado_ejecutada, id_ai_estado) THEN 1
        ELSE 0
    END,
    fecha_finalizacion = CASE
        WHEN id_ai_estado = COALESCE(@estado_ejecutada, id_ai_estado) THEN COALESCE(fecha_finalizacion, NOW())
        ELSE NULL
    END,
    id_user_finaliza = CASE
        WHEN id_ai_estado = COALESCE(@estado_ejecutada, id_ai_estado) THEN COALESCE(NULLIF(id_user_finaliza, ''), id_user)
        ELSE NULL
    END
WHERE std_reg = 1;

UPDATE herramientaot h
INNER JOIN orden_trabajo ot ON ot.n_ot = h.n_ot
SET h.estadoot = 'LIBERADA'
WHERE ot.std_reg = 1
  AND ot.id_ai_estado = COALESCE(@estado_ejecutada, ot.id_ai_estado)
  AND COALESCE(h.estadoot, 'ASIGNADA') <> 'LIBERADA';

CREATE INDEX IF NOT EXISTS idx_orden_trabajo_finalizada ON orden_trabajo (ot_finalizada, std_reg);

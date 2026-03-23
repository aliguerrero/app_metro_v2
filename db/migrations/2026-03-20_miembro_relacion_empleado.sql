USE bdapp_metro;

ALTER TABLE miembro
    ADD COLUMN IF NOT EXISTS id_empleado VARCHAR(30) NULL AFTER id_miembro;

UPDATE miembro
SET id_empleado = NULL
WHERE TRIM(COALESCE(id_empleado, '')) = '';

CREATE INDEX IF NOT EXISTS idx_miembro_tipo_std ON miembro (tipo_miembro, std_reg);
CREATE UNIQUE INDEX IF NOT EXISTS uk_miembro_id_empleado ON miembro (id_empleado);

SET @fk_miembro_empleado_exists := (
    SELECT COUNT(*)
    FROM information_schema.KEY_COLUMN_USAGE
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'miembro'
      AND CONSTRAINT_NAME = 'fk_miembro_empleado'
);

SET @fk_miembro_empleado_sql := IF(
    @fk_miembro_empleado_exists = 0,
    'ALTER TABLE miembro ADD CONSTRAINT fk_miembro_empleado FOREIGN KEY (id_empleado) REFERENCES empleado(id_empleado) ON UPDATE CASCADE',
    'SELECT 1'
);

PREPARE stmt_fk_miembro_empleado FROM @fk_miembro_empleado_sql;
EXECUTE stmt_fk_miembro_empleado;
DEALLOCATE PREPARE stmt_fk_miembro_empleado;

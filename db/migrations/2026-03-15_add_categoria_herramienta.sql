CREATE TABLE IF NOT EXISTS categoria_herramienta (
    id_ai_categoria_herramienta INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nombre_categoria VARCHAR(100) NOT NULL,
    descripcion VARCHAR(255) NULL,
    std_reg TINYINT(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (id_ai_categoria_herramienta),
    KEY idx_categoria_herramienta_nombre (nombre_categoria),
    KEY idx_categoria_herramienta_std_reg (std_reg)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO categoria_herramienta (nombre_categoria, descripcion, std_reg)
SELECT 'GENERAL', 'Categoria base para herramientas existentes', 1
WHERE NOT EXISTS (
    SELECT 1
    FROM categoria_herramienta
    WHERE nombre_categoria = 'GENERAL'
);

SET @has_herr_cat_col := (
    SELECT COUNT(1)
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'herramienta'
      AND COLUMN_NAME = 'id_ai_categoria_herramienta'
);

SET @sql_herr_cat_col := IF(
    @has_herr_cat_col = 0,
    'ALTER TABLE herramienta ADD COLUMN id_ai_categoria_herramienta INT UNSIGNED NULL AFTER nombre_herramienta',
    'SELECT 1'
);
PREPARE stmt_herr_cat_col FROM @sql_herr_cat_col;
EXECUTE stmt_herr_cat_col;
DEALLOCATE PREPARE stmt_herr_cat_col;

SET @categoria_general_id := (
    SELECT id_ai_categoria_herramienta
    FROM categoria_herramienta
    WHERE nombre_categoria = 'GENERAL'
    ORDER BY id_ai_categoria_herramienta ASC
    LIMIT 1
);

UPDATE herramienta
SET id_ai_categoria_herramienta = @categoria_general_id
WHERE id_ai_categoria_herramienta IS NULL
   OR id_ai_categoria_herramienta = 0;

SET @is_nullable_herr_cat := (
    SELECT COUNT(1)
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'herramienta'
      AND COLUMN_NAME = 'id_ai_categoria_herramienta'
      AND IS_NULLABLE = 'YES'
);

SET @sql_herr_cat_nullable := IF(
    @is_nullable_herr_cat > 0,
    'ALTER TABLE herramienta MODIFY COLUMN id_ai_categoria_herramienta INT UNSIGNED NOT NULL',
    'SELECT 1'
);
PREPARE stmt_herr_cat_nullable FROM @sql_herr_cat_nullable;
EXECUTE stmt_herr_cat_nullable;
DEALLOCATE PREPARE stmt_herr_cat_nullable;

SET @has_herr_cat_idx := (
    SELECT COUNT(1)
    FROM INFORMATION_SCHEMA.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'herramienta'
      AND INDEX_NAME = 'idx_herramienta_categoria'
);

SET @sql_herr_cat_idx := IF(
    @has_herr_cat_idx = 0,
    'ALTER TABLE herramienta ADD INDEX idx_herramienta_categoria (id_ai_categoria_herramienta)',
    'SELECT 1'
);
PREPARE stmt_herr_cat_idx FROM @sql_herr_cat_idx;
EXECUTE stmt_herr_cat_idx;
DEALLOCATE PREPARE stmt_herr_cat_idx;

SET @has_herr_cat_fk := (
    SELECT COUNT(1)
    FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'herramienta'
      AND CONSTRAINT_NAME = 'fk_herramienta_categoria'
      AND REFERENCED_TABLE_NAME = 'categoria_herramienta'
);

SET @sql_herr_cat_fk := IF(
    @has_herr_cat_fk = 0,
    'ALTER TABLE herramienta ADD CONSTRAINT fk_herramienta_categoria FOREIGN KEY (id_ai_categoria_herramienta) REFERENCES categoria_herramienta (id_ai_categoria_herramienta) ON UPDATE RESTRICT ON DELETE RESTRICT',
    'SELECT 1'
);
PREPARE stmt_herr_cat_fk FROM @sql_herr_cat_fk;
EXECUTE stmt_herr_cat_fk;
DEALLOCATE PREPARE stmt_herr_cat_fk;

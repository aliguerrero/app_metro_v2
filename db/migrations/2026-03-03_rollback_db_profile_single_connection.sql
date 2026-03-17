-- Rollback de perfiles de conexion por usuario (db_profile)
-- Fecha: 2026-03-03
-- Objetivo: dejar el sistema en conexion unica de BD (u_admin)

START TRANSACTION;

-- 1) Eliminar indice de db_profile si existe
SET @idx_exists := (
  SELECT COUNT(*)
  FROM information_schema.STATISTICS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'user_system'
    AND INDEX_NAME = 'idx_user_system_db_profile'
);

SET @sql_drop_idx := IF(
  @idx_exists > 0,
  "ALTER TABLE user_system DROP INDEX idx_user_system_db_profile",
  "SELECT 'Indice idx_user_system_db_profile no existe' AS info"
);

PREPARE stmt_drop_idx FROM @sql_drop_idx;
EXECUTE stmt_drop_idx;
DEALLOCATE PREPARE stmt_drop_idx;

-- 2) Eliminar columna db_profile si existe
SET @col_exists := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'user_system'
    AND COLUMN_NAME = 'db_profile'
);

SET @sql_drop_col := IF(
  @col_exists > 0,
  "ALTER TABLE user_system DROP COLUMN db_profile",
  "SELECT 'Columna db_profile no existe' AS info"
);

PREPARE stmt_drop_col FROM @sql_drop_col;
EXECUTE stmt_drop_col;
DEALLOCATE PREPARE stmt_drop_col;

COMMIT;

-- Verificacion
SHOW COLUMNS FROM user_system LIKE 'db_profile';
SHOW INDEX FROM user_system WHERE Key_name = 'idx_user_system_db_profile';

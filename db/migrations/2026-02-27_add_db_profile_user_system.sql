-- Migracion: agregar perfil de acceso a BD sin eliminar campo tipo
-- Fecha: 2026-02-27

START TRANSACTION;

-- 1) Agregar columna db_profile en user_system (si no existe)
SET @col_exists := (
  SELECT COUNT(*)
  FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'user_system'
    AND COLUMN_NAME = 'db_profile'
);

SET @sql_add_col := IF(
  @col_exists = 0,
  "ALTER TABLE user_system
     ADD COLUMN db_profile ENUM('lector','escritor','admin')
     NOT NULL DEFAULT 'lector'
     COMMENT 'Perfil de acceso real a BD'
     AFTER tipo",
  "SELECT 'Columna db_profile ya existe' AS info"
);

PREPARE stmt_add_col FROM @sql_add_col;
EXECUTE stmt_add_col;
DEALLOCATE PREPARE stmt_add_col;

-- 2) Agregar indice para filtros por perfil (si no existe)
SET @idx_exists := (
  SELECT COUNT(*)
  FROM INFORMATION_SCHEMA.STATISTICS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'user_system'
    AND INDEX_NAME = 'idx_user_system_db_profile'
);

SET @sql_add_idx := IF(
  @idx_exists = 0,
  "ALTER TABLE user_system ADD INDEX idx_user_system_db_profile (db_profile)",
  "SELECT 'Indice idx_user_system_db_profile ya existe' AS info"
);

PREPARE stmt_add_idx FROM @sql_add_idx;
EXECUTE stmt_add_idx;
DEALLOCATE PREPARE stmt_add_idx;

-- 3) Backfill inicial segun rol funcional (tipo -> roles_permisos)
--    admin: ROOT / ADMINISTRADOR
--    escritor: cualquier permiso de escritura
--    lector: solo lectura
UPDATE user_system u
JOIN roles_permisos r ON r.id = u.tipo
SET u.db_profile = CASE
  WHEN UPPER(TRIM(r.nombre_rol)) IN ('ROOT', 'ADMINISTRADOR') THEN 'admin'
  WHEN (
    COALESCE(r.perm_usuarios_add,0) = 1 OR
    COALESCE(r.perm_usuarios_edit,0) = 1 OR
    COALESCE(r.perm_usuarios_delete,0) = 1 OR
    COALESCE(r.perm_herramienta_add,0) = 1 OR
    COALESCE(r.perm_herramienta_edit,0) = 1 OR
    COALESCE(r.perm_herramienta_delete,0) = 1 OR
    COALESCE(r.perm_miembro_add,0) = 1 OR
    COALESCE(r.perm_miembro_edit,0) = 1 OR
    COALESCE(r.perm_miembro_delete,0) = 1 OR
    COALESCE(r.perm_ot_add,0) = 1 OR
    COALESCE(r.perm_ot_edit,0) = 1 OR
    COALESCE(r.perm_ot_delete,0) = 1 OR
    COALESCE(r.perm_ot_add_detalle,0) = 1 OR
    COALESCE(r.perm_ot_add_herramienta,0) = 1
  ) THEN 'escritor'
  ELSE 'lector'
END;

COMMIT;

-- Nota:
-- Si quieres que auditoria capture db_profile en data_old/data_new/data_diff,
-- actualiza los triggers trg_user_system_ai / trg_user_system_au.

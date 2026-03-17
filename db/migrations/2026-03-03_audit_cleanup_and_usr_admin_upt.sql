-- Migracion: limpieza de replicas de log_user y alta de usuario DB admin alterno
-- Fecha: 2026-03-03
-- Objetivo:
--   1) Mantener solo 2 copias de log_user:
--      - bdapp_metro.log_user
--      - bdapp_metro_audit.log_user
--   2) Eliminar tercera copia:
--      - bdapp_metro_audit.log_user_backup
--   3) Crear usr_admin_upt con clave/permisos equivalentes a u_admin

-- 0) Consolidar datos antes de retirar log_user_backup (si existe)
SET @has_backup := (
  SELECT COUNT(*)
  FROM information_schema.TABLES
  WHERE TABLE_SCHEMA = 'bdapp_metro_audit'
    AND TABLE_NAME = 'log_user_backup'
);

SET @sql_merge := IF(
  @has_backup = 1,
  "INSERT IGNORE INTO bdapp_metro_audit.log_user SELECT * FROM bdapp_metro_audit.log_user_backup",
  "SELECT 'log_user_backup no existe; merge omitido' AS info_msg"
);
PREPARE stmt_merge FROM @sql_merge;
EXECUTE stmt_merge;
DEALLOCATE PREPARE stmt_merge;

-- 1) Ajustar tarea periodica para solo sincronizar (sin tercera copia)
DROP PROCEDURE IF EXISTS bdapp_metro_audit.sp_minute_tasks;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE bdapp_metro_audit.sp_minute_tasks()
BEGIN
  DECLARE v_sync INT DEFAULT 0;

  CALL bdapp_metro_audit.sp_sync_log_user();
  SET v_sync = ROW_COUNT();

  INSERT INTO bdapp_metro_audit.backup_runs(run_at, synced_rows, backed_rows)
  VALUES (NOW(), v_sync, 0);
END$$
DELIMITER ;

-- 2) Retirar la capa de backup redundante
DROP PROCEDURE IF EXISTS bdapp_metro_audit.sp_backup_log_user;
DROP TABLE IF EXISTS bdapp_metro_audit.log_user_backup;

-- 3) Crear usuario alterno con misma clave hash de u_admin@%
SET @uadmin_hash := (
  SELECT authentication_string
  FROM mysql.user
  WHERE User = 'u_admin'
    AND Host = '%'
  LIMIT 1
);

SET @sql_create_usr := IF(
  @uadmin_hash IS NULL OR @uadmin_hash = '',
  "SELECT 'ERROR: no existe u_admin@% o no posee hash de autenticacion' AS error_msg",
  CONCAT(
    "CREATE USER IF NOT EXISTS 'usr_admin_upt'@'%' IDENTIFIED BY PASSWORD '",
    @uadmin_hash,
    "'"
  )
);
PREPARE stmt_create_usr FROM @sql_create_usr;
EXECUTE stmt_create_usr;
DEALLOCATE PREPARE stmt_create_usr;

SET @sql_alter_usr := IF(
  @uadmin_hash IS NULL OR @uadmin_hash = '',
  "SELECT 'ALTER USER omitido: hash no disponible' AS warn_msg",
  CONCAT(
    "ALTER USER 'usr_admin_upt'@'%' IDENTIFIED BY PASSWORD '",
    @uadmin_hash,
    "'"
  )
);
PREPARE stmt_alter_usr FROM @sql_alter_usr;
EXECUTE stmt_alter_usr;
DEALLOCATE PREPARE stmt_alter_usr;

-- Permisos directos equivalentes a los grants explicitos de u_admin@%
GRANT SELECT, INSERT, UPDATE, CREATE, DROP, ALTER, EXECUTE, EVENT
  ON bdapp_metro_audit.* TO 'usr_admin_upt'@'%';

GRANT SELECT, CREATE VIEW
  ON bdapp_metro_review.* TO 'usr_admin_upt'@'%';

GRANT SELECT
  ON bdapp_metro.log_user TO 'usr_admin_upt'@'%';

-- Rol admin (si existe)
SET @role_exists := (
  SELECT COUNT(*)
  FROM mysql.user
  WHERE User = 'rol_admin'
);

SET @sql_grant_role := IF(
  @role_exists > 0,
  "GRANT `rol_admin` TO 'usr_admin_upt'@'%'",
  "SELECT 'Rol rol_admin no existe; se mantienen permisos directos' AS warn_msg"
);
PREPARE stmt_grant_role FROM @sql_grant_role;
EXECUTE stmt_grant_role;
DEALLOCATE PREPARE stmt_grant_role;

SET @sql_default_role := IF(
  @role_exists > 0,
  "SET DEFAULT ROLE `rol_admin` FOR 'usr_admin_upt'@'%'",
  "SELECT 'SET DEFAULT ROLE omitido (rol inexistente)' AS warn_msg"
);
PREPARE stmt_default_role FROM @sql_default_role;
EXECUTE stmt_default_role;
DEALLOCATE PREPARE stmt_default_role;

FLUSH PRIVILEGES;

-- 4) Verificacion rapida
SELECT TABLE_SCHEMA, TABLE_NAME
FROM information_schema.TABLES
WHERE TABLE_NAME = 'log_user'
ORDER BY TABLE_SCHEMA;

SELECT TABLE_SCHEMA, TABLE_NAME
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'bdapp_metro_audit'
  AND TABLE_NAME = 'log_user_backup';

SHOW GRANTS FOR 'usr_admin_upt'@'%';

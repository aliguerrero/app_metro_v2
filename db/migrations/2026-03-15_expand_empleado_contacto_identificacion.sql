START TRANSACTION;

SET @col_nacionalidad_exists := (
  SELECT COUNT(*)
  FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'empleado'
    AND COLUMN_NAME = 'nacionalidad'
);

SET @sql_nacionalidad := IF(
  @col_nacionalidad_exists = 0,
  "ALTER TABLE `empleado` ADD COLUMN `nacionalidad` CHAR(1) NOT NULL DEFAULT 'V' COMMENT 'Identifica si la cedula es venezolana (V) o extranjera (E).' AFTER `id_empleado`",
  'SELECT 1'
);

PREPARE stmt_nacionalidad FROM @sql_nacionalidad;
EXECUTE stmt_nacionalidad;
DEALLOCATE PREPARE stmt_nacionalidad;

SET @col_telefono_exists := (
  SELECT COUNT(*)
  FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'empleado'
    AND COLUMN_NAME = 'telefono'
);

SET @sql_telefono := IF(
  @col_telefono_exists = 0,
  "ALTER TABLE `empleado` ADD COLUMN `telefono` VARCHAR(20) DEFAULT NULL COMMENT 'Telefono principal del empleado.' AFTER `nombre_empleado`",
  'SELECT 1'
);

PREPARE stmt_telefono FROM @sql_telefono;
EXECUTE stmt_telefono;
DEALLOCATE PREPARE stmt_telefono;

SET @col_direccion_exists := (
  SELECT COUNT(*)
  FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'empleado'
    AND COLUMN_NAME = 'direccion'
);

SET @sql_direccion := IF(
  @col_direccion_exists = 0,
  "ALTER TABLE `empleado` ADD COLUMN `direccion` VARCHAR(255) DEFAULT NULL COMMENT 'Direccion de residencia o ubicacion del empleado.' AFTER `telefono`",
  'SELECT 1'
);

PREPARE stmt_direccion FROM @sql_direccion;
EXECUTE stmt_direccion;
DEALLOCATE PREPARE stmt_direccion;

SET @col_correo_exists := (
  SELECT COUNT(*)
  FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'empleado'
    AND COLUMN_NAME = 'correo'
);

SET @sql_correo := IF(
  @col_correo_exists = 0,
  "ALTER TABLE `empleado` ADD COLUMN `correo` VARCHAR(120) DEFAULT NULL COMMENT 'Correo electronico del empleado.' AFTER `direccion`",
  'SELECT 1'
);

PREPARE stmt_correo FROM @sql_correo;
EXECUTE stmt_correo;
DEALLOCATE PREPARE stmt_correo;

UPDATE `empleado`
SET `nacionalidad` = 'V'
WHERE `nacionalidad` IS NULL
   OR UPPER(TRIM(`nacionalidad`)) NOT IN ('V', 'E');

COMMIT;

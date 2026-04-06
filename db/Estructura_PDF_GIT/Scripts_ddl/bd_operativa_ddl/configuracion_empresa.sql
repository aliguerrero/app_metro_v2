-- Modulo: Scripts_ddl
-- Archivo: configuracion_empresa.sql
-- Funcion: define la configuracion general de la empresa dentro del sistema.
-- Version: v_1.0

-- ============================================================================
-- Base de datos operativa
-- ============================================================================
CREATE DATABASE IF NOT EXISTS `bdapp_metro` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `bdapp_metro`;

-- -----------------------------------------------------------------------------
-- Bloque 1. Reinicio controlado y creacion de la tabla
-- elimina `empresa_config` si ya existe y la vuelve a crear con `IF NOT EXISTS` usando la definicion consolidada del esquema.
-- -----------------------------------------------------------------------------
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS `empresa_config`;
CREATE TABLE IF NOT EXISTS `empresa_config` (
  `id` int(11) NOT NULL COMMENT 'PK. Identificador unico de la configuracion de empresa (normalmente 1 registro).',
  `nombre` varchar(150) NOT NULL COMMENT 'Nombre legal o comercial de la empresa.',
  `rif` varchar(30) DEFAULT NULL COMMENT 'RIF / Identificador fiscal de la empresa.',
  `direccion` varchar(255) DEFAULT NULL COMMENT 'Direccion fisica o fiscal de la empresa.',
  `telefono` varchar(50) DEFAULT NULL COMMENT 'Telefono principal de contacto.',
  `email` varchar(120) DEFAULT NULL COMMENT 'Correo principal de contacto.',
  `logo` varchar(255) DEFAULT NULL COMMENT 'Ruta relativa del logo. Ej: app/views/icons/metro.png',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'Fecha/hora de creacion del registro.',
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Fecha/hora de ultima actualizacion del registro.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
SET FOREIGN_KEY_CHECKS = 1;

-- -----------------------------------------------------------------------------
-- Bloque 2. Disparador asociado
-- el disparador `trg_empresa_config_ad` registra la auditoria asociada a la eliminacion en `empresa_config` despues de ejecutarse la operacion.
-- -----------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER `trg_empresa_config_ad` AFTER DELETE ON `empresa_config` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
  'empresa_config',
  'DELETE',
  CONCAT('id=', OLD.`id`),
  JSON_OBJECT('id', OLD.`id`),
  CONCAT('ELIMINAR ', 'empresa_config'),
  CONCAT('DELETE empresa_config ', CONCAT('id=', OLD.`id`)),
  JSON_OBJECT('id', OLD.`id`, 'nombre', OLD.`nombre`, 'rif', OLD.`rif`, 'direccion', OLD.`direccion`, 'telefono', OLD.`telefono`, 'email', OLD.`email`, 'logo', OLD.`logo`, 'created_at', OLD.`created_at`, 'updated_at', OLD.`updated_at`),
  NULL,
  NULL,
  NULL,
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)
$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- Bloque 3. Disparador asociado
-- el disparador `trg_empresa_config_ai` registra la auditoria asociada a la insercion en `empresa_config` despues de ejecutarse la operacion.
-- -----------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER `trg_empresa_config_ai` AFTER INSERT ON `empresa_config` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
  'empresa_config',
  'INSERT',
  CONCAT('id=', NEW.`id`),
  JSON_OBJECT('id', NEW.`id`),
  CONCAT('CREAR ', 'empresa_config'),
  CONCAT('INSERT empresa_config ', CONCAT('id=', NEW.`id`)),
  NULL,
  JSON_OBJECT('id', NEW.`id`, 'nombre', NEW.`nombre`, 'rif', NEW.`rif`, 'direccion', NEW.`direccion`, 'telefono', NEW.`telefono`, 'email', NEW.`email`, 'logo', NEW.`logo`, 'created_at', NEW.`created_at`, 'updated_at', NEW.`updated_at`),
  JSON_OBJECT('id', NEW.`id`, 'nombre', NEW.`nombre`, 'rif', NEW.`rif`, 'direccion', NEW.`direccion`, 'telefono', NEW.`telefono`, 'email', NEW.`email`, 'logo', NEW.`logo`, 'created_at', NEW.`created_at`, 'updated_at', NEW.`updated_at`),
  'id,nombre,rif,direccion,telefono,email,logo,created_at,updated_at',
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)
$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- Bloque 4. Disparador asociado
-- el disparador `trg_empresa_config_au` registra la auditoria asociada a la actualizacion en `empresa_config` despues de ejecutarse la operacion.
-- -----------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER `trg_empresa_config_au` AFTER UPDATE ON `empresa_config` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
  'empresa_config',
  'UPDATE',
  CONCAT('id=', NEW.`id`),
  JSON_OBJECT('id', NEW.`id`),
  CONCAT('MODIFICAR ', 'empresa_config'),
  CONCAT('UPDATE empresa_config ', CONCAT('id=', NEW.`id`)),
  JSON_OBJECT('id', OLD.`id`, 'nombre', OLD.`nombre`, 'rif', OLD.`rif`, 'direccion', OLD.`direccion`, 'telefono', OLD.`telefono`, 'email', OLD.`email`, 'logo', OLD.`logo`, 'created_at', OLD.`created_at`, 'updated_at', OLD.`updated_at`),
  JSON_OBJECT('id', NEW.`id`, 'nombre', NEW.`nombre`, 'rif', NEW.`rif`, 'direccion', NEW.`direccion`, 'telefono', NEW.`telefono`, 'email', NEW.`email`, 'logo', NEW.`logo`, 'created_at', NEW.`created_at`, 'updated_at', NEW.`updated_at`),
  JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_OBJECT(), IF(NOT (OLD.`id` <=> NEW.`id`), JSON_OBJECT('id', JSON_ARRAY(OLD.`id`, NEW.`id`)), JSON_OBJECT())), IF(NOT (OLD.`nombre` <=> NEW.`nombre`), JSON_OBJECT('nombre', JSON_ARRAY(OLD.`nombre`, NEW.`nombre`)), JSON_OBJECT())), IF(NOT (OLD.`rif` <=> NEW.`rif`), JSON_OBJECT('rif', JSON_ARRAY(OLD.`rif`, NEW.`rif`)), JSON_OBJECT())), IF(NOT (OLD.`direccion` <=> NEW.`direccion`), JSON_OBJECT('direccion', JSON_ARRAY(OLD.`direccion`, NEW.`direccion`)), JSON_OBJECT())), IF(NOT (OLD.`telefono` <=> NEW.`telefono`), JSON_OBJECT('telefono', JSON_ARRAY(OLD.`telefono`, NEW.`telefono`)), JSON_OBJECT())), IF(NOT (OLD.`email` <=> NEW.`email`), JSON_OBJECT('email', JSON_ARRAY(OLD.`email`, NEW.`email`)), JSON_OBJECT())), IF(NOT (OLD.`logo` <=> NEW.`logo`), JSON_OBJECT('logo', JSON_ARRAY(OLD.`logo`, NEW.`logo`)), JSON_OBJECT())), IF(NOT (OLD.`created_at` <=> NEW.`created_at`), JSON_OBJECT('created_at', JSON_ARRAY(OLD.`created_at`, NEW.`created_at`)), JSON_OBJECT())), IF(NOT (OLD.`updated_at` <=> NEW.`updated_at`), JSON_OBJECT('updated_at', JSON_ARRAY(OLD.`updated_at`, NEW.`updated_at`)), JSON_OBJECT())),
  NULLIF(CONCAT_WS(',', IF(NOT (OLD.`id` <=> NEW.`id`), 'id', NULL), IF(NOT (OLD.`nombre` <=> NEW.`nombre`), 'nombre', NULL), IF(NOT (OLD.`rif` <=> NEW.`rif`), 'rif', NULL), IF(NOT (OLD.`direccion` <=> NEW.`direccion`), 'direccion', NULL), IF(NOT (OLD.`telefono` <=> NEW.`telefono`), 'telefono', NULL), IF(NOT (OLD.`email` <=> NEW.`email`), 'email', NULL), IF(NOT (OLD.`logo` <=> NEW.`logo`), 'logo', NULL), IF(NOT (OLD.`created_at` <=> NEW.`created_at`), 'created_at', NULL), IF(NOT (OLD.`updated_at` <=> NEW.`updated_at`), 'updated_at', NULL)), ''),
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)
$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- Bloque 5. Indices y clave primaria
-- declara la clave primaria e indices auxiliares requeridos para consultas, unicidad y rendimiento de `empresa_config`.
-- -----------------------------------------------------------------------------
ALTER TABLE `empresa_config`
  ADD PRIMARY KEY (`id`);


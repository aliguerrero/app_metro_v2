-- Modulo: Scripts_ddl
-- Archivo: sitio_trabajo.sql
-- Funcion: define los sitios donde se ejecutan las ordenes de trabajo.
-- Version: v_1.0

-- ============================================================================
-- Base de datos operativa
-- ============================================================================
CREATE DATABASE IF NOT EXISTS `bdapp_metro` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `bdapp_metro`;

-- -----------------------------------------------------------------------------
-- Bloque 1. Reinicio controlado y creacion de la tabla
-- elimina `sitio_trabajo` si ya existe y la vuelve a crear con `IF NOT EXISTS` usando la definicion consolidada del esquema.
-- -----------------------------------------------------------------------------
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS `sitio_trabajo`;
CREATE TABLE IF NOT EXISTS `sitio_trabajo` (
  `id_ai_sitio` int(11) NOT NULL COMMENT 'id autoincrementable',
  `nombre_sitio` varchar(100) NOT NULL COMMENT 'Nombre del sitio o ubicacion de trabajo',
  `std_reg` tinyint(1) NOT NULL COMMENT 'Estado logico del registro (1=activo, 0=inactivo/eliminado logico).'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
SET FOREIGN_KEY_CHECKS = 1;

-- -----------------------------------------------------------------------------
-- Bloque 2. Disparador asociado
-- el disparador `trg_sitio_trabajo_ai` registra la auditoria asociada a la insercion en `sitio_trabajo` despues de ejecutarse la operacion.
-- -----------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER `trg_sitio_trabajo_ai` AFTER INSERT ON `sitio_trabajo` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
  'sitio_trabajo',
  'INSERT',
  CONCAT('id_ai_sitio=', NEW.`id_ai_sitio`),
  JSON_OBJECT('id_ai_sitio', NEW.`id_ai_sitio`),
  CONCAT('CREAR ', 'sitio_trabajo'),
  CONCAT('INSERT sitio_trabajo ', CONCAT('id_ai_sitio=', NEW.`id_ai_sitio`)),
  NULL,
  JSON_OBJECT('id_ai_sitio', NEW.`id_ai_sitio`, 'nombre_sitio', NEW.`nombre_sitio`, 'std_reg', NEW.`std_reg`),
  JSON_OBJECT('id_ai_sitio', NEW.`id_ai_sitio`, 'nombre_sitio', NEW.`nombre_sitio`, 'std_reg', NEW.`std_reg`),
  'id_ai_sitio,nombre_sitio,std_reg',
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)
$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- Bloque 3. Disparador asociado
-- el disparador `trg_sitio_trabajo_au` registra la auditoria asociada a la actualizacion en `sitio_trabajo` despues de ejecutarse la operacion.
-- -----------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER `trg_sitio_trabajo_au` AFTER UPDATE ON `sitio_trabajo` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
  'sitio_trabajo',
  CASE WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN 'SOFT_DELETE' WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN 'RESTORE' ELSE 'UPDATE' END,
  CONCAT('id_ai_sitio=', NEW.`id_ai_sitio`),
  JSON_OBJECT('id_ai_sitio', NEW.`id_ai_sitio`),
  CASE WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN CONCAT('ELIMINAR (LOGICO) ', 'sitio_trabajo') WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN CONCAT('REACTIVAR ', 'sitio_trabajo') ELSE CONCAT('MODIFICAR ', 'sitio_trabajo') END,
  CASE WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN CONCAT('SOFT_DELETE sitio_trabajo ', CONCAT('id_ai_sitio=', NEW.`id_ai_sitio`)) WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN CONCAT('RESTORE sitio_trabajo ', CONCAT('id_ai_sitio=', NEW.`id_ai_sitio`)) ELSE CONCAT('UPDATE sitio_trabajo ', CONCAT('id_ai_sitio=', NEW.`id_ai_sitio`)) END,
  JSON_OBJECT('id_ai_sitio', OLD.`id_ai_sitio`, 'nombre_sitio', OLD.`nombre_sitio`, 'std_reg', OLD.`std_reg`),
  JSON_OBJECT('id_ai_sitio', NEW.`id_ai_sitio`, 'nombre_sitio', NEW.`nombre_sitio`, 'std_reg', NEW.`std_reg`),
  JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_OBJECT(), IF(NOT (OLD.`id_ai_sitio` <=> NEW.`id_ai_sitio`), JSON_OBJECT('id_ai_sitio', JSON_ARRAY(OLD.`id_ai_sitio`, NEW.`id_ai_sitio`)), JSON_OBJECT())), IF(NOT (OLD.`nombre_sitio` <=> NEW.`nombre_sitio`), JSON_OBJECT('nombre_sitio', JSON_ARRAY(OLD.`nombre_sitio`, NEW.`nombre_sitio`)), JSON_OBJECT())), IF(NOT (OLD.`std_reg` <=> NEW.`std_reg`), JSON_OBJECT('std_reg', JSON_ARRAY(OLD.`std_reg`, NEW.`std_reg`)), JSON_OBJECT())),
  NULLIF(CONCAT_WS(',', IF(NOT (OLD.`id_ai_sitio` <=> NEW.`id_ai_sitio`), 'id_ai_sitio', NULL), IF(NOT (OLD.`nombre_sitio` <=> NEW.`nombre_sitio`), 'nombre_sitio', NULL), IF(NOT (OLD.`std_reg` <=> NEW.`std_reg`), 'std_reg', NULL)), ''),
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)
$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- Bloque 4. Disparador asociado
-- el disparador `trg_sitio_trabajo_bd` valida o bloquea la eliminacion en `sitio_trabajo` antes de aplicar el cambio definitivo.
-- -----------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER `trg_sitio_trabajo_bd` BEFORE DELETE ON `sitio_trabajo` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE fisico en sitio_trabajo. Use eliminacion logica (UPDATE sitio_trabajo SET std_reg=0 ...).'
$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- Bloque 5. Indices y clave primaria
-- declara la clave primaria e indices auxiliares requeridos para consultas, unicidad y rendimiento de `sitio_trabajo`.
-- -----------------------------------------------------------------------------
ALTER TABLE `sitio_trabajo`
  ADD PRIMARY KEY (`id_ai_sitio`);

-- -----------------------------------------------------------------------------
-- Bloque 6. Configuracion autoincremental
-- habilita el comportamiento AUTO_INCREMENT definido para `sitio_trabajo` dentro de la base actual.
-- -----------------------------------------------------------------------------
ALTER TABLE `sitio_trabajo`
  MODIFY `id_ai_sitio` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable', AUTO_INCREMENT=6;


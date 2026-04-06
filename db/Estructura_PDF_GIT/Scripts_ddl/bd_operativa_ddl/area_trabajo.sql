-- Modulo: Scripts_ddl
-- Archivo: area_trabajo.sql
-- Funcion: define las areas de trabajo usadas para clasificar las ordenes de trabajo.
-- Version: v_1.0

-- ============================================================================
-- Base de datos operativa
-- ============================================================================
CREATE DATABASE IF NOT EXISTS `bdapp_metro` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `bdapp_metro`;

-- -----------------------------------------------------------------------------
-- Bloque 1. Reinicio controlado y creacion de la tabla
-- elimina `area_trabajo` si ya existe y la vuelve a crear con `IF NOT EXISTS` usando la definicion consolidada del esquema.
-- -----------------------------------------------------------------------------
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS `area_trabajo`;
CREATE TABLE IF NOT EXISTS `area_trabajo` (
  `id_ai_area` int(11) NOT NULL COMMENT 'id autoincrementable',
  `nombre_area` varchar(100) NOT NULL COMMENT 'Nombre del area de trabajo',
  `nomeclatura` varchar(20) NOT NULL COMMENT 'Nomenclatura o prefijo usado para generar codigos de OT',
  `std_reg` tinyint(1) NOT NULL COMMENT 'Estado logico del registro (1=activo, 0=inactivo/eliminado logico).'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
SET FOREIGN_KEY_CHECKS = 1;

-- -----------------------------------------------------------------------------
-- Bloque 2. Disparador asociado
-- el disparador `trg_area_trabajo_ai` registra la auditoria asociada a la insercion en `area_trabajo` despues de ejecutarse la operacion.
-- -----------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER `trg_area_trabajo_ai` AFTER INSERT ON `area_trabajo` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
  'area_trabajo',
  'INSERT',
  CONCAT('id_ai_area=', NEW.`id_ai_area`),
  JSON_OBJECT('id_ai_area', NEW.`id_ai_area`),
  CONCAT('CREAR ', 'area_trabajo'),
  CONCAT('INSERT area_trabajo ', CONCAT('id_ai_area=', NEW.`id_ai_area`)),
  NULL,
  JSON_OBJECT('id_ai_area', NEW.`id_ai_area`, 'nombre_area', NEW.`nombre_area`, 'nomeclatura', NEW.`nomeclatura`, 'std_reg', NEW.`std_reg`),
  JSON_OBJECT('id_ai_area', NEW.`id_ai_area`, 'nombre_area', NEW.`nombre_area`, 'nomeclatura', NEW.`nomeclatura`, 'std_reg', NEW.`std_reg`),
  'id_ai_area,nombre_area,nomeclatura,std_reg',
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)
$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- Bloque 3. Disparador asociado
-- el disparador `trg_area_trabajo_au` registra la auditoria asociada a la actualizacion en `area_trabajo` despues de ejecutarse la operacion.
-- -----------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER `trg_area_trabajo_au` AFTER UPDATE ON `area_trabajo` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
  'area_trabajo',
  CASE WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN 'SOFT_DELETE' WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN 'RESTORE' ELSE 'UPDATE' END,
  CONCAT('id_ai_area=', NEW.`id_ai_area`),
  JSON_OBJECT('id_ai_area', NEW.`id_ai_area`),
  CASE WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN CONCAT('ELIMINAR (LOGICO) ', 'area_trabajo') WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN CONCAT('REACTIVAR ', 'area_trabajo') ELSE CONCAT('MODIFICAR ', 'area_trabajo') END,
  CASE WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN CONCAT('SOFT_DELETE area_trabajo ', CONCAT('id_ai_area=', NEW.`id_ai_area`)) WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN CONCAT('RESTORE area_trabajo ', CONCAT('id_ai_area=', NEW.`id_ai_area`)) ELSE CONCAT('UPDATE area_trabajo ', CONCAT('id_ai_area=', NEW.`id_ai_area`)) END,
  JSON_OBJECT('id_ai_area', OLD.`id_ai_area`, 'nombre_area', OLD.`nombre_area`, 'nomeclatura', OLD.`nomeclatura`, 'std_reg', OLD.`std_reg`),
  JSON_OBJECT('id_ai_area', NEW.`id_ai_area`, 'nombre_area', NEW.`nombre_area`, 'nomeclatura', NEW.`nomeclatura`, 'std_reg', NEW.`std_reg`),
  JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_OBJECT(), IF(NOT (OLD.`id_ai_area` <=> NEW.`id_ai_area`), JSON_OBJECT('id_ai_area', JSON_ARRAY(OLD.`id_ai_area`, NEW.`id_ai_area`)), JSON_OBJECT())), IF(NOT (OLD.`nombre_area` <=> NEW.`nombre_area`), JSON_OBJECT('nombre_area', JSON_ARRAY(OLD.`nombre_area`, NEW.`nombre_area`)), JSON_OBJECT())), IF(NOT (OLD.`nomeclatura` <=> NEW.`nomeclatura`), JSON_OBJECT('nomeclatura', JSON_ARRAY(OLD.`nomeclatura`, NEW.`nomeclatura`)), JSON_OBJECT())), IF(NOT (OLD.`std_reg` <=> NEW.`std_reg`), JSON_OBJECT('std_reg', JSON_ARRAY(OLD.`std_reg`, NEW.`std_reg`)), JSON_OBJECT())),
  NULLIF(CONCAT_WS(',', IF(NOT (OLD.`id_ai_area` <=> NEW.`id_ai_area`), 'id_ai_area', NULL), IF(NOT (OLD.`nombre_area` <=> NEW.`nombre_area`), 'nombre_area', NULL), IF(NOT (OLD.`nomeclatura` <=> NEW.`nomeclatura`), 'nomeclatura', NULL), IF(NOT (OLD.`std_reg` <=> NEW.`std_reg`), 'std_reg', NULL)), ''),
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)
$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- Bloque 4. Disparador asociado
-- el disparador `trg_area_trabajo_bd` valida o bloquea la eliminacion en `area_trabajo` antes de aplicar el cambio definitivo.
-- -----------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER `trg_area_trabajo_bd` BEFORE DELETE ON `area_trabajo` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE fisico en area_trabajo. Use eliminacion logica (UPDATE area_trabajo SET std_reg=0 ...).'
$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- Bloque 5. Indices y clave primaria
-- declara la clave primaria e indices auxiliares requeridos para consultas, unicidad y rendimiento de `area_trabajo`.
-- -----------------------------------------------------------------------------
ALTER TABLE `area_trabajo`
  ADD PRIMARY KEY (`id_ai_area`),
  ADD UNIQUE KEY `nomeclatura` (`nomeclatura`);

-- -----------------------------------------------------------------------------
-- Bloque 6. Configuracion autoincremental
-- habilita el comportamiento AUTO_INCREMENT definido para `area_trabajo` dentro de la base actual.
-- -----------------------------------------------------------------------------
ALTER TABLE `area_trabajo`
  MODIFY `id_ai_area` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable', AUTO_INCREMENT=6;


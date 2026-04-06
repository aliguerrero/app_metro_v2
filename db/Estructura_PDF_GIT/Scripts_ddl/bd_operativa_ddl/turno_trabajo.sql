-- Modulo: Scripts_ddl
-- Archivo: turno_trabajo.sql
-- Funcion: define los turnos operativos disponibles para la planificacion.
-- Version: v_1.0

-- ============================================================================
-- Base de datos operativa
-- ============================================================================
CREATE DATABASE IF NOT EXISTS `bdapp_metro` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `bdapp_metro`;

-- -----------------------------------------------------------------------------
-- Bloque 1. Reinicio controlado y creacion de la tabla
-- elimina `turno_trabajo` si ya existe y la vuelve a crear con `IF NOT EXISTS` usando la definicion consolidada del esquema.
-- -----------------------------------------------------------------------------
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS `turno_trabajo`;
CREATE TABLE IF NOT EXISTS `turno_trabajo` (
  `id_ai_turno` int(11) NOT NULL COMMENT 'id autoincrementable',
  `nombre_turno` varchar(100) NOT NULL COMMENT 'Nombre descriptivo del turno de trabajo',
  `std_reg` tinyint(1) NOT NULL COMMENT 'Estado logico del registro (1=activo, 0=inactivo/eliminado logico).'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
SET FOREIGN_KEY_CHECKS = 1;

-- -----------------------------------------------------------------------------
-- Bloque 2. Disparador asociado
-- el disparador `trg_turno_trabajo_ai` registra la auditoria asociada a la insercion en `turno_trabajo` despues de ejecutarse la operacion.
-- -----------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER `trg_turno_trabajo_ai` AFTER INSERT ON `turno_trabajo` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
  'turno_trabajo',
  'INSERT',
  CONCAT('id_ai_turno=', NEW.`id_ai_turno`),
  JSON_OBJECT('id_ai_turno', NEW.`id_ai_turno`),
  CONCAT('CREAR ', 'turno_trabajo'),
  CONCAT('INSERT turno_trabajo ', CONCAT('id_ai_turno=', NEW.`id_ai_turno`)),
  NULL,
  JSON_OBJECT('id_ai_turno', NEW.`id_ai_turno`, 'nombre_turno', NEW.`nombre_turno`, 'std_reg', NEW.`std_reg`),
  JSON_OBJECT('id_ai_turno', NEW.`id_ai_turno`, 'nombre_turno', NEW.`nombre_turno`, 'std_reg', NEW.`std_reg`),
  'id_ai_turno,nombre_turno,std_reg',
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)
$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- Bloque 3. Disparador asociado
-- el disparador `trg_turno_trabajo_au` registra la auditoria asociada a la actualizacion en `turno_trabajo` despues de ejecutarse la operacion.
-- -----------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER `trg_turno_trabajo_au` AFTER UPDATE ON `turno_trabajo` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
  'turno_trabajo',
  CASE WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN 'SOFT_DELETE' WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN 'RESTORE' ELSE 'UPDATE' END,
  CONCAT('id_ai_turno=', NEW.`id_ai_turno`),
  JSON_OBJECT('id_ai_turno', NEW.`id_ai_turno`),
  CASE WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN CONCAT('ELIMINAR (LOGICO) ', 'turno_trabajo') WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN CONCAT('REACTIVAR ', 'turno_trabajo') ELSE CONCAT('MODIFICAR ', 'turno_trabajo') END,
  CASE WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN CONCAT('SOFT_DELETE turno_trabajo ', CONCAT('id_ai_turno=', NEW.`id_ai_turno`)) WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN CONCAT('RESTORE turno_trabajo ', CONCAT('id_ai_turno=', NEW.`id_ai_turno`)) ELSE CONCAT('UPDATE turno_trabajo ', CONCAT('id_ai_turno=', NEW.`id_ai_turno`)) END,
  JSON_OBJECT('id_ai_turno', OLD.`id_ai_turno`, 'nombre_turno', OLD.`nombre_turno`, 'std_reg', OLD.`std_reg`),
  JSON_OBJECT('id_ai_turno', NEW.`id_ai_turno`, 'nombre_turno', NEW.`nombre_turno`, 'std_reg', NEW.`std_reg`),
  JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_OBJECT(), IF(NOT (OLD.`id_ai_turno` <=> NEW.`id_ai_turno`), JSON_OBJECT('id_ai_turno', JSON_ARRAY(OLD.`id_ai_turno`, NEW.`id_ai_turno`)), JSON_OBJECT())), IF(NOT (OLD.`nombre_turno` <=> NEW.`nombre_turno`), JSON_OBJECT('nombre_turno', JSON_ARRAY(OLD.`nombre_turno`, NEW.`nombre_turno`)), JSON_OBJECT())), IF(NOT (OLD.`std_reg` <=> NEW.`std_reg`), JSON_OBJECT('std_reg', JSON_ARRAY(OLD.`std_reg`, NEW.`std_reg`)), JSON_OBJECT())),
  NULLIF(CONCAT_WS(',', IF(NOT (OLD.`id_ai_turno` <=> NEW.`id_ai_turno`), 'id_ai_turno', NULL), IF(NOT (OLD.`nombre_turno` <=> NEW.`nombre_turno`), 'nombre_turno', NULL), IF(NOT (OLD.`std_reg` <=> NEW.`std_reg`), 'std_reg', NULL)), ''),
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)
$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- Bloque 4. Disparador asociado
-- el disparador `trg_turno_trabajo_bd` valida o bloquea la eliminacion en `turno_trabajo` antes de aplicar el cambio definitivo.
-- -----------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER `trg_turno_trabajo_bd` BEFORE DELETE ON `turno_trabajo` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE fisico en turno_trabajo. Use eliminacion logica (UPDATE turno_trabajo SET std_reg=0 ...).'
$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- Bloque 5. Indices y clave primaria
-- declara la clave primaria e indices auxiliares requeridos para consultas, unicidad y rendimiento de `turno_trabajo`.
-- -----------------------------------------------------------------------------
ALTER TABLE `turno_trabajo`
  ADD PRIMARY KEY (`id_ai_turno`);

-- -----------------------------------------------------------------------------
-- Bloque 6. Configuracion autoincremental
-- habilita el comportamiento AUTO_INCREMENT definido para `turno_trabajo` dentro de la base actual.
-- -----------------------------------------------------------------------------
ALTER TABLE `turno_trabajo`
  MODIFY `id_ai_turno` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable', AUTO_INCREMENT=5;


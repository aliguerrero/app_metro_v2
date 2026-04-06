-- Modulo: Scripts_ddl
-- Archivo: miembro.sql
-- Funcion: define los miembros operativos vinculados a empleados.
-- Version: v_1.0

-- ============================================================================
-- Base de datos operativa
-- ============================================================================
CREATE DATABASE IF NOT EXISTS `bdapp_metro` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `bdapp_metro`;

-- -----------------------------------------------------------------------------
-- Bloque 1. Reinicio controlado y creacion de la tabla
-- elimina `miembro` si ya existe y la vuelve a crear con `IF NOT EXISTS` usando la definicion consolidada del esquema.
-- -----------------------------------------------------------------------------
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS `miembro`;
CREATE TABLE IF NOT EXISTS `miembro` (
  `id_ai_miembro` int(11) NOT NULL COMMENT 'id autoincrementable',
  `id_miembro` varchar(10) NOT NULL COMMENT 'Identificador unico del miembro',
  `id_empleado` varchar(30) DEFAULT NULL COMMENT 'Identificador unico del empleado asociado al miembro',
  `nombre_miembro` varchar(40) NOT NULL COMMENT 'Nombre completo del miembro',
  `tipo_miembro` int(11) NOT NULL COMMENT 'Tipo de miembro (por ejemplo, CCO, CCF, etc.)',
  `std_reg` tinyint(1) NOT NULL COMMENT 'Estado logico del registro (1=activo, 0=inactivo/eliminado logico).'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
SET FOREIGN_KEY_CHECKS = 1;

-- -----------------------------------------------------------------------------
-- Bloque 2. Disparador asociado
-- el disparador `trg_miembro_ai` registra la auditoria asociada a la insercion en `miembro` despues de ejecutarse la operacion.
-- -----------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER `trg_miembro_ai` AFTER INSERT ON `miembro` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
  'miembro',
  'INSERT',
  CONCAT('id_ai_miembro=', NEW.`id_ai_miembro`),
  JSON_OBJECT('id_ai_miembro', NEW.`id_ai_miembro`),
  CONCAT('CREAR ', 'miembro'),
  CONCAT('INSERT miembro ', CONCAT('id_ai_miembro=', NEW.`id_ai_miembro`)),
  NULL,
  JSON_OBJECT('id_ai_miembro', NEW.`id_ai_miembro`, 'id_miembro', NEW.`id_miembro`, 'nombre_miembro', NEW.`nombre_miembro`, 'tipo_miembro', NEW.`tipo_miembro`, 'std_reg', NEW.`std_reg`),
  JSON_OBJECT('id_ai_miembro', NEW.`id_ai_miembro`, 'id_miembro', NEW.`id_miembro`, 'nombre_miembro', NEW.`nombre_miembro`, 'tipo_miembro', NEW.`tipo_miembro`, 'std_reg', NEW.`std_reg`),
  'id_ai_miembro,id_miembro,nombre_miembro,tipo_miembro,std_reg',
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)
$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- Bloque 3. Disparador asociado
-- el disparador `trg_miembro_au` registra la auditoria asociada a la actualizacion en `miembro` despues de ejecutarse la operacion.
-- -----------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER `trg_miembro_au` AFTER UPDATE ON `miembro` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
  'miembro',
  CASE WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN 'SOFT_DELETE' WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN 'RESTORE' ELSE 'UPDATE' END,
  CONCAT('id_ai_miembro=', NEW.`id_ai_miembro`),
  JSON_OBJECT('id_ai_miembro', NEW.`id_ai_miembro`),
  CASE WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN CONCAT('ELIMINAR (LOGICO) ', 'miembro') WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN CONCAT('REACTIVAR ', 'miembro') ELSE CONCAT('MODIFICAR ', 'miembro') END,
  CASE WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN CONCAT('SOFT_DELETE miembro ', CONCAT('id_ai_miembro=', NEW.`id_ai_miembro`)) WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN CONCAT('RESTORE miembro ', CONCAT('id_ai_miembro=', NEW.`id_ai_miembro`)) ELSE CONCAT('UPDATE miembro ', CONCAT('id_ai_miembro=', NEW.`id_ai_miembro`)) END,
  JSON_OBJECT('id_ai_miembro', OLD.`id_ai_miembro`, 'id_miembro', OLD.`id_miembro`, 'nombre_miembro', OLD.`nombre_miembro`, 'tipo_miembro', OLD.`tipo_miembro`, 'std_reg', OLD.`std_reg`),
  JSON_OBJECT('id_ai_miembro', NEW.`id_ai_miembro`, 'id_miembro', NEW.`id_miembro`, 'nombre_miembro', NEW.`nombre_miembro`, 'tipo_miembro', NEW.`tipo_miembro`, 'std_reg', NEW.`std_reg`),
  JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_OBJECT(), IF(NOT (OLD.`id_ai_miembro` <=> NEW.`id_ai_miembro`), JSON_OBJECT('id_ai_miembro', JSON_ARRAY(OLD.`id_ai_miembro`, NEW.`id_ai_miembro`)), JSON_OBJECT())), IF(NOT (OLD.`id_miembro` <=> NEW.`id_miembro`), JSON_OBJECT('id_miembro', JSON_ARRAY(OLD.`id_miembro`, NEW.`id_miembro`)), JSON_OBJECT())), IF(NOT (OLD.`nombre_miembro` <=> NEW.`nombre_miembro`), JSON_OBJECT('nombre_miembro', JSON_ARRAY(OLD.`nombre_miembro`, NEW.`nombre_miembro`)), JSON_OBJECT())), IF(NOT (OLD.`tipo_miembro` <=> NEW.`tipo_miembro`), JSON_OBJECT('tipo_miembro', JSON_ARRAY(OLD.`tipo_miembro`, NEW.`tipo_miembro`)), JSON_OBJECT())), IF(NOT (OLD.`std_reg` <=> NEW.`std_reg`), JSON_OBJECT('std_reg', JSON_ARRAY(OLD.`std_reg`, NEW.`std_reg`)), JSON_OBJECT())),
  NULLIF(CONCAT_WS(',', IF(NOT (OLD.`id_ai_miembro` <=> NEW.`id_ai_miembro`), 'id_ai_miembro', NULL), IF(NOT (OLD.`id_miembro` <=> NEW.`id_miembro`), 'id_miembro', NULL), IF(NOT (OLD.`nombre_miembro` <=> NEW.`nombre_miembro`), 'nombre_miembro', NULL), IF(NOT (OLD.`tipo_miembro` <=> NEW.`tipo_miembro`), 'tipo_miembro', NULL), IF(NOT (OLD.`std_reg` <=> NEW.`std_reg`), 'std_reg', NULL)), ''),
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)
$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- Bloque 4. Disparador asociado
-- el disparador `trg_miembro_bd` valida o bloquea la eliminacion en `miembro` antes de aplicar el cambio definitivo.
-- -----------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER `trg_miembro_bd` BEFORE DELETE ON `miembro` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE fisico en miembro. Use eliminacion logica (UPDATE miembro SET std_reg=0 ...).'
$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- Bloque 5. Indices y clave primaria
-- declara la clave primaria e indices auxiliares requeridos para consultas, unicidad y rendimiento de `miembro`.
-- -----------------------------------------------------------------------------
ALTER TABLE `miembro`
  ADD PRIMARY KEY (`id_ai_miembro`),
  ADD UNIQUE KEY `id_miembro` (`id_miembro`),
  ADD UNIQUE KEY `uk_miembro_id_empleado` (`id_empleado`),
  ADD KEY `idx_miembro_tipo_std` (`tipo_miembro`,`std_reg`);

-- -----------------------------------------------------------------------------
-- Bloque 6. Configuracion autoincremental
-- habilita el comportamiento AUTO_INCREMENT definido para `miembro` dentro de la base actual.
-- -----------------------------------------------------------------------------
ALTER TABLE `miembro`
  MODIFY `id_ai_miembro` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable', AUTO_INCREMENT=9;

-- -----------------------------------------------------------------------------
-- Bloque 7. Claves foraneas
-- establece las relaciones referenciales que conectan `miembro` con otras tablas del esquema correspondiente.
-- -----------------------------------------------------------------------------
ALTER TABLE `miembro`
  ADD CONSTRAINT `fk_miembro_empleado` FOREIGN KEY (`id_empleado`) REFERENCES `empleado` (`id_empleado`) ON UPDATE CASCADE;


-- Modulo: Scripts_ddl
-- Archivo: herramienta_ot.sql
-- Funcion: define la asignacion de herramientas dentro de cada orden de trabajo y su vista operativa.
-- Version: v_1.0

-- ============================================================================
-- Base de datos operativa
-- ============================================================================
CREATE DATABASE IF NOT EXISTS `bdapp_metro` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `bdapp_metro`;

-- -----------------------------------------------------------------------------
-- Bloque 1. Reinicio controlado y creacion de la tabla
-- elimina `herramientaot` si ya existe y la vuelve a crear con `IF NOT EXISTS` usando la definicion consolidada del esquema.
-- -----------------------------------------------------------------------------
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS `herramientaot`;
CREATE TABLE IF NOT EXISTS `herramientaot` (
  `id_ai_herramientaOT` int(11) NOT NULL COMMENT 'id autoincrementable',
  `id_ai_herramienta` int(11) NOT NULL COMMENT 'Codigo de la herramienta asignada a la orden de trabajo',
  `n_ot` varchar(30) NOT NULL COMMENT 'Numero unico de la orden de trabajo',
  `cantidadot` int(11) NOT NULL COMMENT 'Cantidad de unidades de la herramienta asignadas a la OT',
  `estado_herramientaot` varchar(60) NOT NULL DEFAULT 'ASIGNADA' COMMENT 'Estado o condicion de la herramienta dentro de la OT'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
SET FOREIGN_KEY_CHECKS = 1;

-- -----------------------------------------------------------------------------
-- Bloque 2. Disparador asociado
-- el disparador `trg_herramientaot_ad` registra la auditoria asociada a la eliminacion en `herramientaot` despues de ejecutarse la operacion.
-- -----------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER `trg_herramientaot_ad` AFTER DELETE ON `herramientaot` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
  'herramientaot',
  'DELETE',
  CONCAT('id_ai_herramientaOT=', OLD.`id_ai_herramientaOT`),
  JSON_OBJECT('id_ai_herramientaOT', OLD.`id_ai_herramientaOT`),
  CONCAT('ELIMINAR ', 'herramientaot'),
  CONCAT('DELETE herramientaot ', CONCAT('id_ai_herramientaOT=', OLD.`id_ai_herramientaOT`)),
  JSON_OBJECT('id_ai_herramientaOT', OLD.`id_ai_herramientaOT`, 'id_ai_herramienta', OLD.`id_ai_herramienta`, 'n_ot', OLD.`n_ot`, 'cantidadot', OLD.`cantidadot`, 'estado_herramientaot', OLD.`estado_herramientaot`),
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
-- el disparador `trg_herramientaot_ai` registra la auditoria asociada a la insercion en `herramientaot` despues de ejecutarse la operacion.
-- -----------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER `trg_herramientaot_ai` AFTER INSERT ON `herramientaot` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
  'herramientaot',
  'INSERT',
  CONCAT('id_ai_herramientaOT=', NEW.`id_ai_herramientaOT`),
  JSON_OBJECT('id_ai_herramientaOT', NEW.`id_ai_herramientaOT`),
  CONCAT('CREAR ', 'herramientaot'),
  CONCAT('INSERT herramientaot ', CONCAT('id_ai_herramientaOT=', NEW.`id_ai_herramientaOT`)),
  NULL,
  JSON_OBJECT('id_ai_herramientaOT', NEW.`id_ai_herramientaOT`, 'id_ai_herramienta', NEW.`id_ai_herramienta`, 'n_ot', NEW.`n_ot`, 'cantidadot', NEW.`cantidadot`, 'estado_herramientaot', NEW.`estado_herramientaot`),
  JSON_OBJECT('id_ai_herramientaOT', NEW.`id_ai_herramientaOT`, 'id_ai_herramienta', NEW.`id_ai_herramienta`, 'n_ot', NEW.`n_ot`, 'cantidadot', NEW.`cantidadot`, 'estado_herramientaot', NEW.`estado_herramientaot`),
  'id_ai_herramientaOT,id_ai_herramienta,n_ot,cantidadot,estado_herramientaot',
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)
$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- Bloque 4. Disparador asociado
-- el disparador `trg_herramientaot_au` registra la auditoria asociada a la actualizacion en `herramientaot` despues de ejecutarse la operacion.
-- -----------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER `trg_herramientaot_au` AFTER UPDATE ON `herramientaot` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
  'herramientaot',
  'UPDATE',
  CONCAT('id_ai_herramientaOT=', NEW.`id_ai_herramientaOT`),
  JSON_OBJECT('id_ai_herramientaOT', NEW.`id_ai_herramientaOT`),
  CONCAT('MODIFICAR ', 'herramientaot'),
  CONCAT('UPDATE herramientaot ', CONCAT('id_ai_herramientaOT=', NEW.`id_ai_herramientaOT`)),
  JSON_OBJECT('id_ai_herramientaOT', OLD.`id_ai_herramientaOT`, 'id_ai_herramienta', OLD.`id_ai_herramienta`, 'n_ot', OLD.`n_ot`, 'cantidadot', OLD.`cantidadot`, 'estado_herramientaot', OLD.`estado_herramientaot`),
  JSON_OBJECT('id_ai_herramientaOT', NEW.`id_ai_herramientaOT`, 'id_ai_herramienta', NEW.`id_ai_herramienta`, 'n_ot', NEW.`n_ot`, 'cantidadot', NEW.`cantidadot`, 'estado_herramientaot', NEW.`estado_herramientaot`),
  JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_OBJECT(), IF(NOT (OLD.`id_ai_herramientaOT` <=> NEW.`id_ai_herramientaOT`), JSON_OBJECT('id_ai_herramientaOT', JSON_ARRAY(OLD.`id_ai_herramientaOT`, NEW.`id_ai_herramientaOT`)), JSON_OBJECT())), IF(NOT (OLD.`id_ai_herramienta` <=> NEW.`id_ai_herramienta`), JSON_OBJECT('id_ai_herramienta', JSON_ARRAY(OLD.`id_ai_herramienta`, NEW.`id_ai_herramienta`)), JSON_OBJECT())), IF(NOT (OLD.`n_ot` <=> NEW.`n_ot`), JSON_OBJECT('n_ot', JSON_ARRAY(OLD.`n_ot`, NEW.`n_ot`)), JSON_OBJECT())), IF(NOT (OLD.`cantidadot` <=> NEW.`cantidadot`), JSON_OBJECT('cantidadot', JSON_ARRAY(OLD.`cantidadot`, NEW.`cantidadot`)), JSON_OBJECT())), IF(NOT (OLD.`estado_herramientaot` <=> NEW.`estado_herramientaot`), JSON_OBJECT('estado_herramientaot', JSON_ARRAY(OLD.`estado_herramientaot`, NEW.`estado_herramientaot`)), JSON_OBJECT())),
  NULLIF(CONCAT_WS(',', IF(NOT (OLD.`id_ai_herramientaOT` <=> NEW.`id_ai_herramientaOT`), 'id_ai_herramientaOT', NULL), IF(NOT (OLD.`id_ai_herramienta` <=> NEW.`id_ai_herramienta`), 'id_ai_herramienta', NULL), IF(NOT (OLD.`n_ot` <=> NEW.`n_ot`), 'n_ot', NULL), IF(NOT (OLD.`cantidadot` <=> NEW.`cantidadot`), 'cantidadot', NULL), IF(NOT (OLD.`estado_herramientaot` <=> NEW.`estado_herramientaot`), 'estado_herramientaot', NULL)), ''),
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)
$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- Bloque 5. Indices y clave primaria
-- declara la clave primaria e indices auxiliares requeridos para consultas, unicidad y rendimiento de `herramientaot`.
-- -----------------------------------------------------------------------------
ALTER TABLE `herramientaot`
  ADD PRIMARY KEY (`id_ai_herramientaOT`),
  ADD KEY `id_herramienta` (`id_ai_herramienta`),
  ADD KEY `n_ot` (`n_ot`),
  ADD KEY `idx_herramientaot_ot_estado` (`n_ot`,`estado_herramientaot`),
  ADD KEY `idx_herramientaot_herr_estado_ot` (`id_ai_herramienta`,`estado_herramientaot`,`n_ot`);

-- -----------------------------------------------------------------------------
-- Bloque 6. Configuracion autoincremental
-- habilita el comportamiento AUTO_INCREMENT definido para `herramientaot` dentro de la base actual.
-- -----------------------------------------------------------------------------
ALTER TABLE `herramientaot`
  MODIFY `id_ai_herramientaOT` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable', AUTO_INCREMENT=17;

-- -----------------------------------------------------------------------------
-- Bloque 7. Claves foraneas
-- establece las relaciones referenciales que conectan `herramientaot` con otras tablas del esquema correspondiente.
-- -----------------------------------------------------------------------------
ALTER TABLE `herramientaot`
  ADD CONSTRAINT `herramientaot_ibfk_1` FOREIGN KEY (`n_ot`) REFERENCES `orden_trabajo` (`n_ot`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `herramientaot_ibfk_2` FOREIGN KEY (`id_ai_herramienta`) REFERENCES `herramienta` (`id_ai_herramienta`) ON DELETE CASCADE ON UPDATE CASCADE;

-- -----------------------------------------------------------------------------
-- Bloque de vista asociada
-- expone las herramientas actualmente comprometidas en ordenes de trabajo activas.
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS `vw_herramientas_ocupadas`;
DROP TABLE IF EXISTS `vw_herramientas_ocupadas`;

CREATE ALGORITHM=UNDEFINED DEFINER=CURRENT_USER SQL SECURITY INVOKER VIEW `vw_herramientas_ocupadas`  AS SELECT `hot`.`id_ai_herramientaOT` AS `id_ai_herramientaOT`, `hot`.`id_ai_herramienta` AS `id_ai_herramienta`, `h`.`nombre_herramienta` AS `nombre_herramienta`, `hot`.`n_ot` AS `n_ot`, `ot`.`nombre_trab` AS `nombre_trab`, `hot`.`cantidadot` AS `cantidadot`, coalesce(`eo`.`nombre_estado`,'SIN ESTADO') AS `estado_ot`, coalesce(`det`.`id_user_act`,`ot`.`id_user`,'') AS `tecnico_id`, coalesce(`emp_det`.`nombre_empleado`,`emp_ot`.`nombre_empleado`,'Sin tecnico asignado') AS `tecnico_nombre`, coalesce(`emp_det`.`telefono`,`emp_ot`.`telefono`,'') AS `telefono`, coalesce(`emp_det`.`correo`,`emp_ot`.`correo`,'') AS `correo`, coalesce(`emp_det`.`direccion`,`emp_ot`.`direccion`,'') AS `direccion`, `hot`.`estado_herramientaot` AS `estado_herramientaot`, `ot`.`fecha` AS `fecha_ot` FROM ((((((`herramientaot` `hot` join `herramienta` `h` on(`h`.`id_ai_herramienta` = `hot`.`id_ai_herramienta` and `h`.`std_reg` = 1)) join `orden_trabajo` `ot` on(`ot`.`n_ot` = `hot`.`n_ot` and `ot`.`std_reg` = 1)) left join `estado_ot` `eo` on(`eo`.`id_ai_estado` = `ot`.`id_ai_estado`)) left join (select `d1`.`n_ot` AS `n_ot`,`d1`.`id_user_act` AS `id_user_act` from (`detalle_orden` `d1` join (select `detalle_orden`.`n_ot` AS `n_ot`,max(`detalle_orden`.`id_ai_detalle`) AS `max_id` from `detalle_orden` group by `detalle_orden`.`n_ot`) `d2` on(`d2`.`n_ot` = `d1`.`n_ot` and `d2`.`max_id` = `d1`.`id_ai_detalle`))) `det` on(`det`.`n_ot` = `hot`.`n_ot`)) left join `empleado` `emp_det` on(`emp_det`.`id_empleado` = `det`.`id_user_act` and `emp_det`.`std_reg` = 1)) left join `empleado` `emp_ot` on(`emp_ot`.`id_empleado` = `ot`.`id_user` and `emp_ot`.`std_reg` = 1)) WHERE coalesce(`hot`.`estado_herramientaot`,'ASIGNADA') <> 'LIBERADA' ;


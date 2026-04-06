-- Modulo: Scripts_ddl
-- Archivo: herramienta.sql
-- Funcion: define el inventario base de herramientas registradas en el sistema y su vista de disponibilidad.
-- Version: v_1.0

-- ============================================================================
-- Base de datos operativa
-- ============================================================================
CREATE DATABASE IF NOT EXISTS `bdapp_metro` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `bdapp_metro`;

-- -----------------------------------------------------------------------------
-- Bloque 1. Reinicio controlado y creacion de la tabla
-- elimina `herramienta` si ya existe y la vuelve a crear con `IF NOT EXISTS` usando la definicion consolidada del esquema.
-- -----------------------------------------------------------------------------
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS `herramienta`;
CREATE TABLE IF NOT EXISTS `herramienta` (
  `id_ai_herramienta` int(11) NOT NULL COMMENT 'id autoincrementable',
  `nombre_herramienta` varchar(250) NOT NULL COMMENT 'Nombre descriptivo de la herramienta',
  `id_ai_categoria_herramienta` int(10) UNSIGNED NOT NULL COMMENT 'Categoria asociada a la herramienta',
  `cantidad` int(11) NOT NULL COMMENT 'Cantidad total de unidades disponibles de la herramienta',
  `estado` varchar(5) NOT NULL COMMENT 'Descripcion del estado general de la herramienta',
  `std_reg` tinyint(1) NOT NULL COMMENT 'Estado logico del registro (1=activo, 0=inactivo/eliminado logico).'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
SET FOREIGN_KEY_CHECKS = 1;

-- -----------------------------------------------------------------------------
-- Bloque 2. Disparador asociado
-- el disparador `trg_herramienta_ai` registra la auditoria asociada a la insercion en `herramienta` despues de ejecutarse la operacion.
-- -----------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER `trg_herramienta_ai` AFTER INSERT ON `herramienta` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
  'herramienta',
  'INSERT',
  CONCAT('id_ai_herramienta=', NEW.`id_ai_herramienta`),
  JSON_OBJECT('id_ai_herramienta', NEW.`id_ai_herramienta`),
  CONCAT('CREAR ', 'herramienta'),
  CONCAT('INSERT herramienta ', CONCAT('id_ai_herramienta=', NEW.`id_ai_herramienta`)),
  NULL,
  JSON_OBJECT('id_ai_herramienta', NEW.`id_ai_herramienta`, 'nombre_herramienta', NEW.`nombre_herramienta`, 'cantidad', NEW.`cantidad`, 'estado', NEW.`estado`, 'std_reg', NEW.`std_reg`),
  JSON_OBJECT('id_ai_herramienta', NEW.`id_ai_herramienta`, 'nombre_herramienta', NEW.`nombre_herramienta`, 'cantidad', NEW.`cantidad`, 'estado', NEW.`estado`, 'std_reg', NEW.`std_reg`),
  'id_ai_herramienta,nombre_herramienta,cantidad,estado,std_reg',
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)
$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- Bloque 3. Disparador asociado
-- el disparador `trg_herramienta_au` registra la auditoria asociada a la actualizacion en `herramienta` despues de ejecutarse la operacion.
-- -----------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER `trg_herramienta_au` AFTER UPDATE ON `herramienta` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
  'herramienta',
  CASE WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN 'SOFT_DELETE' WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN 'RESTORE' ELSE 'UPDATE' END,
  CONCAT('id_ai_herramienta=', NEW.`id_ai_herramienta`),
  JSON_OBJECT('id_ai_herramienta', NEW.`id_ai_herramienta`),
  CASE WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN CONCAT('ELIMINAR (LOGICO) ', 'herramienta') WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN CONCAT('REACTIVAR ', 'herramienta') ELSE CONCAT('MODIFICAR ', 'herramienta') END,
  CASE WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN CONCAT('SOFT_DELETE herramienta ', CONCAT('id_ai_herramienta=', NEW.`id_ai_herramienta`)) WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN CONCAT('RESTORE herramienta ', CONCAT('id_ai_herramienta=', NEW.`id_ai_herramienta`)) ELSE CONCAT('UPDATE herramienta ', CONCAT('id_ai_herramienta=', NEW.`id_ai_herramienta`)) END,
  JSON_OBJECT('id_ai_herramienta', OLD.`id_ai_herramienta`, 'nombre_herramienta', OLD.`nombre_herramienta`, 'cantidad', OLD.`cantidad`, 'estado', OLD.`estado`, 'std_reg', OLD.`std_reg`),
  JSON_OBJECT('id_ai_herramienta', NEW.`id_ai_herramienta`, 'nombre_herramienta', NEW.`nombre_herramienta`, 'cantidad', NEW.`cantidad`, 'estado', NEW.`estado`, 'std_reg', NEW.`std_reg`),
  JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_OBJECT(), IF(NOT (OLD.`id_ai_herramienta` <=> NEW.`id_ai_herramienta`), JSON_OBJECT('id_ai_herramienta', JSON_ARRAY(OLD.`id_ai_herramienta`, NEW.`id_ai_herramienta`)), JSON_OBJECT())), IF(NOT (OLD.`nombre_herramienta` <=> NEW.`nombre_herramienta`), JSON_OBJECT('nombre_herramienta', JSON_ARRAY(OLD.`nombre_herramienta`, NEW.`nombre_herramienta`)), JSON_OBJECT())), IF(NOT (OLD.`cantidad` <=> NEW.`cantidad`), JSON_OBJECT('cantidad', JSON_ARRAY(OLD.`cantidad`, NEW.`cantidad`)), JSON_OBJECT())), IF(NOT (OLD.`estado` <=> NEW.`estado`), JSON_OBJECT('estado', JSON_ARRAY(OLD.`estado`, NEW.`estado`)), JSON_OBJECT())), IF(NOT (OLD.`std_reg` <=> NEW.`std_reg`), JSON_OBJECT('std_reg', JSON_ARRAY(OLD.`std_reg`, NEW.`std_reg`)), JSON_OBJECT())),
  NULLIF(CONCAT_WS(',', IF(NOT (OLD.`id_ai_herramienta` <=> NEW.`id_ai_herramienta`), 'id_ai_herramienta', NULL), IF(NOT (OLD.`nombre_herramienta` <=> NEW.`nombre_herramienta`), 'nombre_herramienta', NULL), IF(NOT (OLD.`cantidad` <=> NEW.`cantidad`), 'cantidad', NULL), IF(NOT (OLD.`estado` <=> NEW.`estado`), 'estado', NULL), IF(NOT (OLD.`std_reg` <=> NEW.`std_reg`), 'std_reg', NULL)), ''),
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)
$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- Bloque 4. Disparador asociado
-- el disparador `trg_herramienta_bd` valida o bloquea la eliminacion en `herramienta` antes de aplicar el cambio definitivo.
-- -----------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER `trg_herramienta_bd` BEFORE DELETE ON `herramienta` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE fisico en herramienta. Use eliminacion logica (UPDATE herramienta SET std_reg=0 ...).'
$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- Bloque 5. Indices y clave primaria
-- declara la clave primaria e indices auxiliares requeridos para consultas, unicidad y rendimiento de `herramienta`.
-- -----------------------------------------------------------------------------
ALTER TABLE `herramienta`
  ADD PRIMARY KEY (`id_ai_herramienta`),
  ADD KEY `idx_herramienta_categoria` (`id_ai_categoria_herramienta`);

-- -----------------------------------------------------------------------------
-- Bloque 6. Configuracion autoincremental
-- habilita el comportamiento AUTO_INCREMENT definido para `herramienta` dentro de la base actual.
-- -----------------------------------------------------------------------------
ALTER TABLE `herramienta`
  MODIFY `id_ai_herramienta` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable', AUTO_INCREMENT=17;

-- -----------------------------------------------------------------------------
-- Bloque 7. Claves foraneas
-- establece las relaciones referenciales que conectan `herramienta` con otras tablas del esquema correspondiente.
-- -----------------------------------------------------------------------------
ALTER TABLE `herramienta`
  ADD CONSTRAINT `fk_herramienta_categoria` FOREIGN KEY (`id_ai_categoria_herramienta`) REFERENCES `categoria_herramienta` (`id_ai_categoria_herramienta`);

-- -----------------------------------------------------------------------------
-- Bloque de vista asociada
-- resume la disponibilidad real de herramientas considerando asignaciones vigentes.
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS `vw_herramienta_disponibilidad`;
DROP TABLE IF EXISTS `vw_herramienta_disponibilidad`;

CREATE ALGORITHM=UNDEFINED DEFINER=CURRENT_USER SQL SECURITY INVOKER VIEW `vw_herramienta_disponibilidad`  AS SELECT `h`.`id_ai_herramienta` AS `id_ai_herramienta`, `h`.`nombre_herramienta` AS `nombre_herramienta`, `h`.`id_ai_categoria_herramienta` AS `id_ai_categoria_herramienta`, `ch`.`nombre_categoria` AS `nombre_categoria`, `h`.`cantidad` AS `cantidad_total`, coalesce(`occ`.`cantidad_ocupada`,0) AS `cantidad_ocupada`, greatest(`h`.`cantidad` - coalesce(`occ`.`cantidad_ocupada`,0),0) AS `cantidad_disponible`, coalesce(`occ`.`ots_activas`,0) AS `ots_activas`, `h`.`estado` AS `estado`, `h`.`std_reg` AS `std_reg` FROM ((`herramienta` `h` left join `categoria_herramienta` `ch` on(`ch`.`id_ai_categoria_herramienta` = `h`.`id_ai_categoria_herramienta`)) left join (select `hot`.`id_ai_herramienta` AS `id_ai_herramienta`,coalesce(sum(case when coalesce(`hot`.`estado_herramientaot`,'ASIGNADA') <> 'LIBERADA' then `hot`.`cantidadot` else 0 end),0) AS `cantidad_ocupada`,count(distinct case when coalesce(`hot`.`estado_herramientaot`,'ASIGNADA') <> 'LIBERADA' then `hot`.`n_ot` end) AS `ots_activas` from `herramientaot` `hot` group by `hot`.`id_ai_herramienta`) `occ` on(`occ`.`id_ai_herramienta` = `h`.`id_ai_herramienta`)) WHERE `h`.`std_reg` = 1 ;


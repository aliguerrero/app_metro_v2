-- ========================================
-- Respaldo de base de datos
-- DB: bdapp_metro
-- Fecha: 2026-02-27 16:36:34
-- Tipo: PARCIAL
-- Tablas incluidas: herramienta, herramientaot
-- ========================================

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";
SET FOREIGN_KEY_CHECKS=0;
SET UNIQUE_CHECKS=0;

-- Tabla: herramienta
DROP TABLE IF EXISTS `herramienta`;
CREATE TABLE `herramienta` (
  `id_ai_herramienta` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable',
  `nombre_herramienta` varchar(250) NOT NULL COMMENT 'Nombre descriptivo de la herramienta',
  `cantidad` int(11) NOT NULL COMMENT 'Cantidad total de unidades disponibles de la herramienta',
  `estado` varchar(5) NOT NULL COMMENT 'Descripción del estado general de la herramienta',
  `std_reg` tinyint(1) NOT NULL COMMENT 'Estado lógico del registro (1=activo, 0=inactivo/eliminado lógico).',
  PRIMARY KEY (`id_ai_herramienta`)
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

INSERT INTO `herramienta` VALUES
('0', 'cemento', '9', '1', '0'),
('1', 'Martillo electricos', '11', '1', '1'),
('3', 'PRUEBA', '2', '3', '0'),
('4', 'tubo', '1', '2', '0'),
('5', 'tubo de 1/2 6m // 56', '1', '1', '0'),
('6', 'eduardo carmona', '1', '3', '0'),
('7', 'ADMINISTRADOR SISTEMA', '4', '1', '0'),
('8', 'cemento', '2', '1', '0'),
('9', 'ADMINISTRADOR SISTEMA 66', '5', '1', '0'),
('10', 'ADMINISTRADOR SISTEMA', '4', '1', '0'),
('11', 'Taladro percutor', '4', '3', '1'),
('12', 'Llave inglesa', '7', '1', '1'),
('13', 'Juego de destornilladores', '10', '2', '1'),
('14', 'Pinza de presión', '3', '3', '1'),
('15', 'Sierra manual', '6', '1', '0'),
('16', 'Amoladora', '9', '2', '0'),
('17', 'Cinta métrica 5m', '2', '3', '1'),
('18', 'Nivel de burbuja', '5', '1', '1'),
('19', 'Escalera aluminio', '8', '2', '1'),
('20', 'Multímetro digital', '1', '3', '1'),
('21', 'Soldadora inverter', '4', '1', '1'),
('22', 'Careta de soldar', '7', '2', '1'),
('23', 'Guantes dieléctricos', '10', '3', '1'),
('24', 'Casco de seguridad', '3', '1', '1'),
('25', 'Arnés de seguridad', '6', '2', '1'),
('26', 'Linterna recargable', '9', '3', '1'),
('27', 'Generador portátil', '2', '1', '1'),
('28', 'Compresor de aire', '5', '2', '1'),
('29', 'Gato hidráulico', '8', '3', '1'),
('30', 'Cizalla para cables', '1', '1', '1'),
('31', 'limpia contacto', '10', '1', '1'),
('32', 'Martillo electricos', '2', '1', '1'),
('33', 'Martillo electricos', '12', '1', '1'),
('34', 'Martillo electricos', '111', '1', '1'),
('35', 'Martillo electricos', '4', '1', '1'),
('36', 'Martillo electricos', '52', '1', '1'),
('37', 'cables', '100', '1', '1'),
('38', 'herramienta xxx', '5', '1', '1');

-- Tabla: herramientaot
DROP TABLE IF EXISTS `herramientaot`;
CREATE TABLE `herramientaot` (
  `id_ai_herramientaOT` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable',
  `id_ai_herramienta` int(11) NOT NULL COMMENT 'Código de la herramienta asignada a la orden de trabajo',
  `n_ot` varchar(30) NOT NULL COMMENT 'Número único de la orden de trabajo',
  `cantidadot` int(11) NOT NULL COMMENT 'Cantidad de unidades de la herramienta asignadas a la OT',
  `estadoot` varchar(60) DEFAULT NULL COMMENT 'Estado o condición de la herramienta dentro de la OT',
  PRIMARY KEY (`id_ai_herramientaOT`),
  KEY `id_herramienta` (`id_ai_herramienta`),
  KEY `n_ot` (`n_ot`),
  CONSTRAINT `herramientaot_ibfk_1` FOREIGN KEY (`n_ot`) REFERENCES `orden_trabajo` (`n_ot`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `herramientaot_ibfk_2` FOREIGN KEY (`id_ai_herramienta`) REFERENCES `herramienta` (`id_ai_herramienta`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

INSERT INTO `herramientaot` VALUES
('3', '11', 'VF-SEÑ-02', '1', 'OK'),
('4', '12', 'VF-SEÑ-03', '2', 'REGULAR'),
('5', '13', 'VF-SEÑ-04', '3', 'EN REPARACION'),
('6', '14', 'VF-SEÑ-05', '1', 'OK'),
('7', '15', 'VF-SEÑ-06', '2', 'REGULAR'),
('9', '17', 'VF-APV-02', '1', 'OK'),
('10', '18', 'VF-APV-03', '2', 'REGULAR'),
('11', '19', 'VF-APV-04', '3', 'EN REPARACION'),
('12', '20', 'VF-APV-05', '1', 'OK'),
('13', '21', 'VF-INF-01', '2', 'REGULAR'),
('14', '22', 'VF-INF-02', '3', 'EN REPARACION'),
('15', '23', 'VF-INF-03', '1', 'OK'),
('16', '24', 'VF-INF-04', '2', 'REGULAR'),
('17', '25', 'VF-INF-05', '3', 'EN REPARACION'),
('18', '26', 'VF-NP-01', '1', 'OK'),
('19', '27', 'VF-NP-02', '2', 'REGULAR'),
('20', '28', 'VF-NP-03', '3', 'EN REPARACION'),
('21', '29', 'VF-NP-04', '1', 'OK'),
('22', '30', 'VF-NP-05', '2', 'REGULAR'),
('23', '1', 'VF-APV-01', '1', NULL),
('26', '11', 'VF-APV-01', '1', NULL),
('28', '11', 'VF-SEÑ-07', '1', NULL),
('29', '12', 'VF-SEÑ-07', '1', NULL),
('30', '31', 'VF-SEÑ-08', '1', NULL);

-- Trigger: trg_herramienta_ai
DROP TRIGGER IF EXISTS `trg_herramienta_ai`;
DELIMITER $$
CREATE TRIGGER `trg_herramienta_ai` AFTER INSERT ON `herramienta` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_user` FROM `user_system` WHERE `id_user` = @app_user LIMIT 1),
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
)$$
DELIMITER ;

-- Trigger: trg_herramienta_au
DROP TRIGGER IF EXISTS `trg_herramienta_au`;
DELIMITER $$
CREATE TRIGGER `trg_herramienta_au` AFTER UPDATE ON `herramienta` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_user` FROM `user_system` WHERE `id_user` = @app_user LIMIT 1),
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
)$$
DELIMITER ;

-- Trigger: trg_herramienta_bd
DROP TRIGGER IF EXISTS `trg_herramienta_bd`;
DELIMITER $$
CREATE TRIGGER `trg_herramienta_bd` BEFORE DELETE ON `herramienta` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE físico en herramienta. Use eliminación lógica (UPDATE herramienta SET std_reg=0 ...).'$$
DELIMITER ;

-- Trigger: trg_herramientaot_ai
DROP TRIGGER IF EXISTS `trg_herramientaot_ai`;
DELIMITER $$
CREATE TRIGGER `trg_herramientaot_ai` AFTER INSERT ON `herramientaot` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_user` FROM `user_system` WHERE `id_user` = @app_user LIMIT 1),
  'herramientaot',
  'INSERT',
  CONCAT('id_ai_herramientaOT=', NEW.`id_ai_herramientaOT`),
  JSON_OBJECT('id_ai_herramientaOT', NEW.`id_ai_herramientaOT`),
  CONCAT('CREAR ', 'herramientaot'),
  CONCAT('INSERT herramientaot ', CONCAT('id_ai_herramientaOT=', NEW.`id_ai_herramientaOT`)),
  NULL,
  JSON_OBJECT('id_ai_herramientaOT', NEW.`id_ai_herramientaOT`, 'id_ai_herramienta', NEW.`id_ai_herramienta`, 'n_ot', NEW.`n_ot`, 'cantidadot', NEW.`cantidadot`, 'estadoot', NEW.`estadoot`),
  JSON_OBJECT('id_ai_herramientaOT', NEW.`id_ai_herramientaOT`, 'id_ai_herramienta', NEW.`id_ai_herramienta`, 'n_ot', NEW.`n_ot`, 'cantidadot', NEW.`cantidadot`, 'estadoot', NEW.`estadoot`),
  'id_ai_herramientaOT,id_ai_herramienta,n_ot,cantidadot,estadoot',
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)$$
DELIMITER ;

-- Trigger: trg_herramientaot_au
DROP TRIGGER IF EXISTS `trg_herramientaot_au`;
DELIMITER $$
CREATE TRIGGER `trg_herramientaot_au` AFTER UPDATE ON `herramientaot` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_user` FROM `user_system` WHERE `id_user` = @app_user LIMIT 1),
  'herramientaot',
  'UPDATE',
  CONCAT('id_ai_herramientaOT=', NEW.`id_ai_herramientaOT`),
  JSON_OBJECT('id_ai_herramientaOT', NEW.`id_ai_herramientaOT`),
  CONCAT('MODIFICAR ', 'herramientaot'),
  CONCAT('UPDATE herramientaot ', CONCAT('id_ai_herramientaOT=', NEW.`id_ai_herramientaOT`)),
  JSON_OBJECT('id_ai_herramientaOT', OLD.`id_ai_herramientaOT`, 'id_ai_herramienta', OLD.`id_ai_herramienta`, 'n_ot', OLD.`n_ot`, 'cantidadot', OLD.`cantidadot`, 'estadoot', OLD.`estadoot`),
  JSON_OBJECT('id_ai_herramientaOT', NEW.`id_ai_herramientaOT`, 'id_ai_herramienta', NEW.`id_ai_herramienta`, 'n_ot', NEW.`n_ot`, 'cantidadot', NEW.`cantidadot`, 'estadoot', NEW.`estadoot`),
  JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_OBJECT(), IF(NOT (OLD.`id_ai_herramientaOT` <=> NEW.`id_ai_herramientaOT`), JSON_OBJECT('id_ai_herramientaOT', JSON_ARRAY(OLD.`id_ai_herramientaOT`, NEW.`id_ai_herramientaOT`)), JSON_OBJECT())), IF(NOT (OLD.`id_ai_herramienta` <=> NEW.`id_ai_herramienta`), JSON_OBJECT('id_ai_herramienta', JSON_ARRAY(OLD.`id_ai_herramienta`, NEW.`id_ai_herramienta`)), JSON_OBJECT())), IF(NOT (OLD.`n_ot` <=> NEW.`n_ot`), JSON_OBJECT('n_ot', JSON_ARRAY(OLD.`n_ot`, NEW.`n_ot`)), JSON_OBJECT())), IF(NOT (OLD.`cantidadot` <=> NEW.`cantidadot`), JSON_OBJECT('cantidadot', JSON_ARRAY(OLD.`cantidadot`, NEW.`cantidadot`)), JSON_OBJECT())), IF(NOT (OLD.`estadoot` <=> NEW.`estadoot`), JSON_OBJECT('estadoot', JSON_ARRAY(OLD.`estadoot`, NEW.`estadoot`)), JSON_OBJECT())),
  NULLIF(CONCAT_WS(',', IF(NOT (OLD.`id_ai_herramientaOT` <=> NEW.`id_ai_herramientaOT`), 'id_ai_herramientaOT', NULL), IF(NOT (OLD.`id_ai_herramienta` <=> NEW.`id_ai_herramienta`), 'id_ai_herramienta', NULL), IF(NOT (OLD.`n_ot` <=> NEW.`n_ot`), 'n_ot', NULL), IF(NOT (OLD.`cantidadot` <=> NEW.`cantidadot`), 'cantidadot', NULL), IF(NOT (OLD.`estadoot` <=> NEW.`estadoot`), 'estadoot', NULL)), ''),
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)$$
DELIMITER ;

-- Trigger: trg_herramientaot_ad
DROP TRIGGER IF EXISTS `trg_herramientaot_ad`;
DELIMITER $$
CREATE TRIGGER `trg_herramientaot_ad` AFTER DELETE ON `herramientaot` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_user` FROM `user_system` WHERE `id_user` = @app_user LIMIT 1),
  'herramientaot',
  'DELETE',
  CONCAT('id_ai_herramientaOT=', OLD.`id_ai_herramientaOT`),
  JSON_OBJECT('id_ai_herramientaOT', OLD.`id_ai_herramientaOT`),
  CONCAT('ELIMINAR ', 'herramientaot'),
  CONCAT('DELETE herramientaot ', CONCAT('id_ai_herramientaOT=', OLD.`id_ai_herramientaOT`)),
  JSON_OBJECT('id_ai_herramientaOT', OLD.`id_ai_herramientaOT`, 'id_ai_herramienta', OLD.`id_ai_herramienta`, 'n_ot', OLD.`n_ot`, 'cantidadot', OLD.`cantidadot`, 'estadoot', OLD.`estadoot`),
  NULL,
  NULL,
  NULL,
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)$$
DELIMITER ;

SET FOREIGN_KEY_CHECKS=1;
SET UNIQUE_CHECKS=1;

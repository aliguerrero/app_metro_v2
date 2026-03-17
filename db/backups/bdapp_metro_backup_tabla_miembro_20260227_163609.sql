-- ========================================
-- Respaldo de base de datos
-- DB: bdapp_metro
-- Fecha: 2026-02-27 16:36:09
-- Tipo: PARCIAL
-- Tablas incluidas: miembro
-- ========================================

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";
SET FOREIGN_KEY_CHECKS=0;
SET UNIQUE_CHECKS=0;

-- Tabla: miembro
DROP TABLE IF EXISTS `miembro`;
CREATE TABLE `miembro` (
  `id_ai_miembro` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable',
  `id_miembro` varchar(10) NOT NULL COMMENT 'Identificador único del miembro',
  `nombre_miembro` varchar(40) NOT NULL COMMENT 'Nombre completo del miembro',
  `tipo_miembro` int(11) NOT NULL COMMENT 'Tipo de miembro (por ejemplo, CCO, CCF, etc.)',
  `std_reg` tinyint(1) NOT NULL COMMENT 'Estado lógico del registro (1=activo, 0=inactivo/eliminado lógico).',
  PRIMARY KEY (`id_ai_miembro`),
  UNIQUE KEY `id_miembro` (`id_miembro`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

INSERT INTO `miembro` VALUES
('2', 'M-001', 'PEDRO PEREZ', '2', '1'),
('3', 'M-003', 'Eduardo Carmona', '1', '0'),
('5', 'E-M-002', 'ADMINISTRADOR SISTEMA', '1', '0'),
('6', 'M-005', 'alejandro', '1', '1'),
('7', 'M-006', 'MIEMBRO 006', '1', '1'),
('8', 'M-007', 'MIEMBRO 007', '2', '1'),
('9', 'M-008', 'MIEMBRO 008', '1', '1'),
('10', 'M-009', 'MIEMBRO 009', '2', '1'),
('11', 'M-010', 'MIEMBRO 010', '1', '1'),
('12', 'M-011', 'MIEMBRO 011', '2', '1'),
('13', 'M-012', 'MIEMBRO 012', '1', '1'),
('14', 'M-013', 'MIEMBRO 013', '2', '1'),
('15', 'M-014', 'MIEMBRO 014', '1', '1'),
('16', 'M-015', 'MIEMBRO 015', '2', '1'),
('17', 'M-016', 'MIEMBRO 016', '1', '1'),
('18', 'M-017', 'MIEMBRO 017', '2', '1'),
('19', 'M-018', 'MIEMBRO 018', '1', '1'),
('20', 'M-019', 'MIEMBRO 019', '2', '1'),
('21', 'M-020', 'MIEMBRO 020', '1', '1'),
('22', 'M-021', 'MIEMBRO 021', '2', '1'),
('23', 'M-022', 'MIEMBRO 022', '1', '1'),
('24', 'M-023', 'MIEMBRO 023', '2', '1'),
('25', 'M-024', 'MIEMBRO 024', '1', '1'),
('26', 'M-025', 'MIEMBRO 025', '2', '1'),
('27', 'M-055', 'ADMINISTRADOR', '1', '1');

-- Trigger: trg_miembro_ai
DROP TRIGGER IF EXISTS `trg_miembro_ai`;
DELIMITER $$
CREATE TRIGGER `trg_miembro_ai` AFTER INSERT ON `miembro` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_user` FROM `user_system` WHERE `id_user` = @app_user LIMIT 1),
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
)$$
DELIMITER ;

-- Trigger: trg_miembro_au
DROP TRIGGER IF EXISTS `trg_miembro_au`;
DELIMITER $$
CREATE TRIGGER `trg_miembro_au` AFTER UPDATE ON `miembro` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_user` FROM `user_system` WHERE `id_user` = @app_user LIMIT 1),
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
)$$
DELIMITER ;

-- Trigger: trg_miembro_bd
DROP TRIGGER IF EXISTS `trg_miembro_bd`;
DELIMITER $$
CREATE TRIGGER `trg_miembro_bd` BEFORE DELETE ON `miembro` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE físico en miembro. Use eliminación lógica (UPDATE miembro SET std_reg=0 ...).'$$
DELIMITER ;

SET FOREIGN_KEY_CHECKS=1;
SET UNIQUE_CHECKS=1;

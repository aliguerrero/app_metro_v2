-- ========================================
-- Respaldo de base de datos
-- DB: bdapp_metro
-- Fecha: 2026-02-28 19:42:56
-- Tipo: COMPLETO
-- Tablas incluidas: area_trabajo, backup_auto_config, detalle_orden, empresa_config, estado_ot, herramienta, herramientaot, log_user, miembro, orden_trabajo, roles_permisos, sitio_trabajo, turno_trabajo, user_system
-- ========================================

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";
SET FOREIGN_KEY_CHECKS=0;
SET UNIQUE_CHECKS=0;

-- Tabla: area_trabajo
DROP TABLE IF EXISTS `area_trabajo`;
CREATE TABLE `area_trabajo` (
  `id_ai_area` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable',
  `nombre_area` varchar(100) NOT NULL COMMENT 'Nombre del área de trabajo',
  `nomeclatura` varchar(20) NOT NULL COMMENT 'Nomenclatura o prefijo usado para generar códigos de OT',
  `std_reg` tinyint(1) NOT NULL COMMENT 'Estado lógico del registro (1=activo, 0=inactivo/eliminado lógico).',
  PRIMARY KEY (`id_ai_area`),
  UNIQUE KEY `nomeclatura` (`nomeclatura`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

INSERT INTO `area_trabajo` VALUES
('1', 'SEÑALIZACION', 'VF-SEÑ-', '1'),
('2', 'APARATO DE VIA', 'VF-APV-', '1'),
('3', 'INFRAESTRUCTURA', 'VF-INF-', '1'),
('5', 'NO PROGRAMADA', 'VF-NP-', '1'),
('11', 'PRUEBA AREA', 'AREA-', '0'),
('12', 'Tecnologia', 'Redes', '0');

-- Tabla: backup_auto_config
DROP TABLE IF EXISTS `backup_auto_config`;
CREATE TABLE `backup_auto_config` (
  `id` tinyint(3) unsigned NOT NULL,
  `enabled` tinyint(1) NOT NULL DEFAULT 0,
  `frequency` enum('daily','weekly','monthly') NOT NULL DEFAULT 'daily',
  `run_time` char(5) NOT NULL DEFAULT '02:00',
  `weekday` tinyint(3) unsigned NOT NULL DEFAULT 1,
  `month_day` tinyint(3) unsigned NOT NULL DEFAULT 1,
  `mode` enum('full','specific') NOT NULL DEFAULT 'full',
  `tables_json` longtext DEFAULT NULL,
  `retain_count` smallint(5) unsigned NOT NULL DEFAULT 30,
  `runner_token` varchar(80) NOT NULL,
  `last_run_at` datetime DEFAULT NULL,
  `last_file` varchar(255) DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `backup_auto_config` VALUES
('1', '0', 'daily', '02:00', '1', '1', 'full', '[]', '30', '5ee6f76deb29e778692e931e813ec5cda042cc38054a5296', '2026-02-27 16:58:36', 'bdapp_metro_backup_auto_general_20260227_165836.sql', '2026-02-27 16:58:47');

-- Tabla: detalle_orden
DROP TABLE IF EXISTS `detalle_orden`;
CREATE TABLE `detalle_orden` (
  `id_ai_detalle` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable',
  `n_ot` varchar(30) NOT NULL COMMENT 'Número único de la orden de trabajo',
  `fecha` date NOT NULL COMMENT 'Fecha programada de la orden de trabajo',
  `descripcion` varchar(250) NOT NULL COMMENT 'Descripción de la actividad o trabajo a realizar',
  `id_ai_turno` int(11) NOT NULL COMMENT 'Identificador único del turno de trabajo',
  `id_miembro_cco` varchar(10) NOT NULL COMMENT 'Miembro responsable en CCO (Centro de Control de Operaciones)',
  `id_user_act` varchar(30) NOT NULL COMMENT 'Usuario técnico responsable de ejecutar la actividad',
  `id_miembro_ccf` varchar(10) NOT NULL COMMENT 'Miembro responsable en CCF',
  `id_ai_estado` int(11) NOT NULL COMMENT 'Identificador único del estado de la orden de trabajo',
  `cant_tec` int(11) NOT NULL COMMENT 'Cantidad de técnicos involucrados en la actividad',
  `hora_ini_pre` varchar(12) NOT NULL COMMENT 'Hora de inicio de la etapa de preparación',
  `hora_fin_pre` varchar(12) NOT NULL COMMENT 'Hora de finalización de la etapa de preparación',
  `hora_ini_tra` varchar(12) NOT NULL COMMENT 'Hora de inicio de la etapa de traslado',
  `hora_fin_tra` varchar(12) NOT NULL COMMENT 'Hora de finalización de la etapa de traslado',
  `hora_ini_eje` varchar(12) NOT NULL COMMENT 'Hora de inicio de la etapa de ejecución',
  `hora_fin_eje` varchar(12) NOT NULL COMMENT 'Hora de finalización de la etapa de ejecución',
  `observacion` varchar(250) DEFAULT NULL COMMENT 'Observaciones adicionales sobre la actividad',
  PRIMARY KEY (`id_ai_detalle`),
  KEY `responsable_ccf` (`id_miembro_ccf`),
  KEY `responsable_cco` (`id_miembro_cco`),
  KEY `responsable_act` (`id_user_act`),
  KEY `turno` (`id_ai_turno`),
  KEY `status` (`id_ai_estado`),
  KEY `n_ot` (`n_ot`),
  CONSTRAINT `detalle_orden_ibfk_2` FOREIGN KEY (`id_user_act`) REFERENCES `user_system` (`id_user`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `detalle_orden_ibfk_3` FOREIGN KEY (`id_miembro_ccf`) REFERENCES `miembro` (`id_miembro`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `detalle_orden_ibfk_4` FOREIGN KEY (`id_miembro_cco`) REFERENCES `miembro` (`id_miembro`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `detalle_orden_ibfk_5` FOREIGN KEY (`id_ai_estado`) REFERENCES `estado_ot` (`id_ai_estado`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `detalle_orden_ibfk_6` FOREIGN KEY (`id_ai_turno`) REFERENCES `turno_trabajo` (`id_ai_turno`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `detalle_orden_ibfk_7` FOREIGN KEY (`n_ot`) REFERENCES `orden_trabajo` (`n_ot`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

INSERT INTO `detalle_orden` VALUES
('2', 'VF-SEÑ-02', '2026-02-11', 'DETALLE PRUEBA VF-SEÑ-02: actividad programada (2026-02-11)', '1', 'M-006', '000000', 'M-007', '1', '2', '07:00', '07:30', '07:30', '08:00', '08:00', '09:30', NULL),
('3', 'VF-SEÑ-03', '2026-02-12', 'DETALLE PRUEBA VF-SEÑ-03: actividad programada (2026-02-12)', '2', 'M-007', '12345678', 'M-008', '3', '3', '07:00', '07:30', '07:30', '08:00', '08:00', '10:00', 'PRUEBA - generar datos'),
('4', 'VF-SEÑ-04', '2026-02-13', 'DETALLE PRUEBA VF-SEÑ-04: actividad programada (2026-02-13)', '3', 'M-008', '000000', 'M-009', '2', '4', '07:00', '07:30', '07:30', '08:00', '08:00', '10:30', 'PRUEBA - generar datos'),
('5', 'VF-SEÑ-05', '2026-02-14', 'DETALLE PRUEBA VF-SEÑ-05: actividad programada (2026-02-14)', '4', 'M-009', '12345678', 'M-010', '4', '5', '07:00', '07:30', '07:30', '08:00', '08:00', '11:00', NULL),
('6', 'VF-SEÑ-06', '2026-02-15', 'DETALLE PRUEBA VF-SEÑ-06: actividad programada (2026-02-15)', '1', 'M-010', '000000', 'M-011', '1', '2', '07:00', '07:30', '07:30', '08:00', '08:00', '09:30', 'PRUEBA - generar datos'),
('8', 'VF-APV-02', '2026-02-17', 'DETALLE PRUEBA VF-APV-02: actividad programada (2026-02-17)', '3', 'M-012', '000000', 'M-013', '2', '4', '07:00', '07:30', '07:30', '08:00', '08:00', '10:30', NULL),
('9', 'VF-APV-03', '2026-02-18', 'DETALLE PRUEBA VF-APV-03: actividad programada (2026-02-18)', '4', 'M-013', '12345678', 'M-014', '4', '5', '07:00', '07:30', '07:30', '08:00', '08:00', '11:00', 'PRUEBA - generar datos'),
('10', 'VF-APV-04', '2026-02-19', 'DETALLE PRUEBA VF-APV-04: actividad programada (2026-02-19)', '1', 'M-014', '000000', 'M-015', '1', '2', '07:00', '07:30', '07:30', '08:00', '08:00', '09:30', 'PRUEBA - generar datos'),
('11', 'VF-APV-05', '2026-02-20', 'DETALLE PRUEBA VF-APV-05: actividad programada (2026-02-20)', '2', 'M-015', '12345678', 'M-016', '3', '3', '07:00', '07:30', '07:30', '08:00', '08:00', '10:00', NULL),
('12', 'VF-INF-01', '2026-02-21', 'DETALLE PRUEBA VF-INF-01: actividad programada (2026-02-21)', '3', 'M-016', '000000', 'M-017', '2', '4', '07:00', '07:30', '07:30', '08:00', '08:00', '10:30', 'PRUEBA - generar datos'),
('13', 'VF-INF-02', '2026-02-22', 'DETALLE PRUEBA VF-INF-02: actividad programada (2026-02-22)', '4', 'M-017', '12345678', 'M-018', '4', '5', '07:00', '07:30', '07:30', '08:00', '08:00', '11:00', 'PRUEBA - generar datos'),
('14', 'VF-INF-03', '2026-02-23', 'DETALLE PRUEBA VF-INF-03: actividad programada (2026-02-23)', '1', 'M-018', '000000', 'M-019', '1', '2', '07:00', '07:30', '07:30', '08:00', '08:00', '09:30', NULL),
('15', 'VF-INF-04', '2026-02-24', 'DETALLE PRUEBA VF-INF-04: actividad programada (2026-02-24)', '2', 'M-019', '12345678', 'M-020', '3', '3', '07:00', '07:30', '07:30', '08:00', '08:00', '10:00', 'PRUEBA - generar datos'),
('16', 'VF-INF-05', '2026-02-25', 'DETALLE PRUEBA VF-INF-05: actividad programada (2026-02-25)', '3', 'M-020', '000000', 'M-021', '2', '4', '07:00', '07:30', '07:30', '08:00', '08:00', '10:30', 'PRUEBA - generar datos'),
('17', 'VF-NP-01', '2026-02-26', 'DETALLE PRUEBA VF-NP-01: actividad programada (2026-02-26)', '4', 'M-021', '12345678', 'M-022', '4', '5', '07:00', '07:30', '07:30', '08:00', '08:00', '11:00', NULL),
('18', 'VF-NP-02', '2026-02-27', 'DETALLE PRUEBA VF-NP-02: actividad programada (2026-02-27)', '1', 'M-022', '000000', 'M-023', '1', '2', '07:00', '07:30', '07:30', '08:00', '08:00', '09:30', 'PRUEBA - generar datos'),
('19', 'VF-NP-03', '2026-02-28', 'DETALLE PRUEBA VF-NP-03: actividad programada (2026-02-28)', '2', 'M-023', '12345678', 'M-024', '3', '3', '07:00', '07:30', '07:30', '08:00', '08:00', '10:00', 'PRUEBA - generar datos'),
('20', 'VF-NP-04', '2026-03-01', 'DETALLE PRUEBA VF-NP-04: actividad programada (2026-03-01)', '3', 'M-024', '000000', 'M-025', '2', '4', '07:00', '07:30', '07:30', '08:00', '08:00', '10:30', NULL),
('21', 'VF-NP-05', '2026-03-02', 'DETALLE PRUEBA VF-NP-05: actividad programada (2026-03-02)', '4', 'M-025', '12345678', 'M-006', '4', '5', '07:00', '07:30', '07:30', '08:00', '08:00', '11:00', 'PRUEBA - generar datos'),
('29', 'VF-APV-01', '2026-02-16', 'DETALLE PRUEBA VF-APV-01', '2', 'M-001', '12345678', 'M-012', '12', '4', '07:00', '07:30', '07:30', '08:00', '08:00', '10:00', 'PRUEBA'),
('32', 'VF-SEÑ-08', '2026-02-13', 'mantenimiento general', '1', 'M-001', '26580187', 'M-005', '1', '5', '01:00', '01:00', '01:00', '01:00', '01:00', '01:00', NULL),
('33', 'VF-SEÑ-09', '2026-02-12', 'mantenimineto', '1', 'M-001', '26580187', 'M-005', '1', '4', '09:00', '12:00', '10:00', '01:00', '11:00', '03:11', NULL);

-- Tabla: empresa_config
DROP TABLE IF EXISTS `empresa_config`;
CREATE TABLE `empresa_config` (
  `id` int(11) NOT NULL COMMENT 'PK. Identificador único de la configuración de empresa (normalmente 1 registro).',
  `nombre` varchar(150) NOT NULL COMMENT 'Nombre legal o comercial de la empresa.',
  `rif` varchar(30) DEFAULT NULL COMMENT 'RIF / Identificador fiscal de la empresa.',
  `direccion` varchar(255) DEFAULT NULL COMMENT 'Dirección física o fiscal de la empresa.',
  `telefono` varchar(50) DEFAULT NULL COMMENT 'Teléfono principal de contacto.',
  `email` varchar(120) DEFAULT NULL COMMENT 'Correo principal de contacto.',
  `logo` varchar(255) DEFAULT NULL COMMENT 'Ruta relativa del logo. Ej: app/views/icons/metro.png',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'Fecha/hora de creación del registro.',
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Fecha/hora de última actualización del registro.',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `empresa_config` VALUES
('1', 'C.A. Metro Valencia', 'G-0000000-1', 'Av. Sesquicentenaria, local Parque Recreacional Sur, parte Sur Oeste N° S/N, zona Valencia Sur. Estado Carabobo.', '0241-0000000', 'metrodevalencia@correo.com', 'app/views/img/empresa/logo_empresa.jpg', '2026-01-07 16:59:31', '2026-02-11 19:26:46');

-- Tabla: estado_ot
DROP TABLE IF EXISTS `estado_ot`;
CREATE TABLE `estado_ot` (
  `id_ai_estado` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable',
  `nombre_estado` varchar(100) NOT NULL COMMENT 'Nombre descriptivo del estado de la orden de trabajo',
  `color` varchar(15) NOT NULL COMMENT 'Código de color asociado al estado para representación visual',
  `std_reg` tinyint(1) NOT NULL COMMENT 'Estado lógico del registro (1=activo, 0=inactivo/eliminado lógico).',
  PRIMARY KEY (`id_ai_estado`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

INSERT INTO `estado_ot` VALUES
('1', 'EJECUTADA', '#25ef28', '1'),
('2', 'NO EJECUTADA', '#fa0025', '1'),
('3', 'RE-PROGRAMADA', '#001eff', '1'),
('4', 'SUSPENDIDA', '#ffae00', '1'),
('12', 'CORRECTIVA', '#ff00bb', '1'),
('19', 'PRUEBA', '#e1ff00', '0'),
('20', 'bfbfbfbf', '#00ffcc', '0'),
('21', 'PRUEBA 2', '#e1c537', '0'),
('22', 'DVDDV', '#00ffcc', '0'),
('23', 'PENDIENTE1', '#ff00bb', '0');

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

-- Tabla: log_user
DROP TABLE IF EXISTS `log_user`;
CREATE TABLE `log_user` (
  `id_log` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable',
  `event_uuid` char(36) NOT NULL,
  `id_user` varchar(30) DEFAULT NULL COMMENT 'Identificador de user (FK o referencia).',
  `tabla` varchar(64) NOT NULL COMMENT 'Tabla origen del evento.',
  `operacion` enum('INSERT','UPDATE','DELETE','SOFT_DELETE','RESTORE','UNKNOWN') NOT NULL COMMENT 'Tipo de operación registrada.',
  `pk_registro` varchar(255) DEFAULT NULL COMMENT 'Clave primaria (o identificador) del registro afectado.',
  `pk_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Identificador/PK en formato JSON.' CHECK (json_valid(`pk_json`)),
  `accion` varchar(150) NOT NULL,
  `resp_system` text NOT NULL COMMENT 'Detalle técnico de la operación registrada.',
  `data_old` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Snapshot anterior (UPDATE/DELETE).' CHECK (json_valid(`data_old`)),
  `data_new` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Snapshot posterior (INSERT/UPDATE).' CHECK (json_valid(`data_new`)),
  `data_diff` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Solo campos modificados con [old,new].' CHECK (json_valid(`data_diff`)),
  `fecha_hora` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'Fecha asociada a fecha hora.',
  `connection_id` bigint(20) unsigned DEFAULT NULL COMMENT 'CONNECTION_ID() de la sesión.',
  `db_user` varchar(128) NOT NULL COMMENT 'Usuario de base de datos que ejecutó la operación.',
  `db_host` varchar(128) DEFAULT NULL COMMENT 'Host extraído de USER().',
  `changed_cols` varchar(1024) DEFAULT NULL COMMENT 'Lista CSV de columnas modificadas.',
  `std_reg` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Estado logico del registro',
  PRIMARY KEY (`id_log`),
  KEY `idx_log_id_user_fecha` (`id_user`,`fecha_hora`),
  KEY `idx_log_tabla_fecha` (`tabla`,`fecha_hora`),
  KEY `idx_log_event_uuid` (`event_uuid`),
  KEY `idx_log_tabla_operacion_fecha` (`tabla`,`operacion`,`fecha_hora`),
  CONSTRAINT `fk_log_user_user` FOREIGN KEY (`id_user`) REFERENCES `user_system` (`id_user`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

INSERT INTO `log_user` VALUES
('1', 'ae1320ea-1402-11f1-9511-989096ab40dc', '000000', 'herramienta', 'INSERT', 'id_ai_herramienta=38', '{\"id_ai_herramienta\": 38}', 'CREAR herramienta', 'INSERT herramienta id_ai_herramienta=38', NULL, '{\"id_ai_herramienta\": 38, \"nombre_herramienta\": \"herramienta xxx\", \"cantidad\": 5, \"estado\": \"1\", \"std_reg\": 1}', '{\"id_ai_herramienta\": 38, \"nombre_herramienta\": \"herramienta xxx\", \"cantidad\": 5, \"estado\": \"1\", \"std_reg\": 1}', '2026-02-27 13:35:12', '1476', 'root@localhost', 'localhost', 'id_ai_herramienta,nombre_herramienta,cantidad,estado,std_reg', '1'),
('2', 'ca164c46-1402-11f1-9511-989096ab40dc', '000000', 'user_system', 'UPDATE', 'id_user=26580187', '{\"id_user\": \"26580187\"}', 'MODIFICAR user_system', 'UPDATE user_system id_user=26580187', '{\"id_ai_user\": 4, \"id_user\": \"26580187\", \"user\": \"Walter Ramone\", \"username\": \"prueba\", \"password\": \"***\", \"tipo\": 17, \"std_reg\": 1}', '{\"id_ai_user\": 4, \"id_user\": \"26580187\", \"user\": \"Walter Ramone\", \"username\": \"prueba\", \"password\": \"***\", \"tipo\": 17, \"std_reg\": 1}', '{}', '2026-02-27 13:35:59', '1488', 'root@localhost', 'localhost', NULL, '1'),
('3', 'd53c387e-1402-11f1-9511-989096ab40dc', '000000', 'user_system', 'UPDATE', 'id_user=26580187', '{\"id_user\": \"26580187\"}', 'MODIFICAR user_system', 'UPDATE user_system id_user=26580187', '{\"id_ai_user\": 4, \"id_user\": \"26580187\", \"user\": \"Walter Ramone\", \"username\": \"prueba\", \"password\": \"***\", \"tipo\": 17, \"std_reg\": 1}', '{\"id_ai_user\": 4, \"id_user\": \"26580187\", \"user\": \"Walter Ramone\", \"username\": \"prueba\", \"password\": \"***\", \"tipo\": 17, \"std_reg\": 1}', '{\"password\": \"CHANGED\"}', '2026-02-27 13:36:18', '1493', 'root@localhost', 'localhost', 'password', '1'),
('4', 'ecd6e8be-1402-11f1-9511-989096ab40dc', '26580187', 'detalle_orden', 'UPDATE', 'id_ai_detalle=29', '{\"id_ai_detalle\": 29}', 'MODIFICAR detalle_orden', 'UPDATE detalle_orden id_ai_detalle=29', '{\"id_ai_detalle\": 29, \"n_ot\": \"VF-APV-01\", \"fecha\": \"2026-02-16\", \"descripcion\": \"DETALLE PRUEBA VF-APV-01: actividad programada\", \"id_ai_turno\": 2, \"id_miembro_cco\": \"M-001\", \"id_user_act\": \"12345678\", \"id_miembro_ccf\": \"M-012\", \"id_ai_estado\": 12, \"cant_tec\": 4, \"hora_ini_pre\": \"07:00\", \"hora_fin_pre\": \"07:30\", \"hora_ini_tra\": \"07:30\", \"hora_fin_tra\": \"08:00\", \"hora_ini_eje\": \"08:00\", \"hora_fin_eje\": \"10:00\", \"observacion\": \"PRUEBA\"}', '{\"id_ai_detalle\": 29, \"n_ot\": \"VF-APV-01\", \"fecha\": \"2026-02-16\", \"descripcion\": \"DETALLE PRUEBA VF-APV-01: actividad programada\", \"id_ai_turno\": 2, \"id_miembro_cco\": \"M-001\", \"id_user_act\": \"12345678\", \"id_miembro_ccf\": \"M-012\", \"id_ai_estado\": 12, \"cant_tec\": 4, \"hora_ini_pre\": \"07:00\", \"hora_fin_pre\": \"07:30\", \"hora_ini_tra\": \"07:30\", \"hora_fin_tra\": \"08:00\", \"hora_ini_eje\": \"08:00\", \"hora_fin_eje\": \"10:00\", \"observacion\": \"PRUEBA\"}', '{}', '2026-02-27 13:36:57', '1524', 'root@localhost', 'localhost', NULL, '1'),
('5', 'eb87e46e-1403-11f1-9511-989096ab40dc', '26580187', 'detalle_orden', 'UPDATE', 'id_ai_detalle=29', '{\"id_ai_detalle\": 29}', 'MODIFICAR detalle_orden', 'UPDATE detalle_orden id_ai_detalle=29', '{\"id_ai_detalle\": 29, \"n_ot\": \"VF-APV-01\", \"fecha\": \"2026-02-16\", \"descripcion\": \"DETALLE PRUEBA VF-APV-01: actividad programada\", \"id_ai_turno\": 2, \"id_miembro_cco\": \"M-001\", \"id_user_act\": \"12345678\", \"id_miembro_ccf\": \"M-012\", \"id_ai_estado\": 12, \"cant_tec\": 4, \"hora_ini_pre\": \"07:00\", \"hora_fin_pre\": \"07:30\", \"hora_ini_tra\": \"07:30\", \"hora_fin_tra\": \"08:00\", \"hora_ini_eje\": \"08:00\", \"hora_fin_eje\": \"10:00\", \"observacion\": \"PRUEBA\"}', '{\"id_ai_detalle\": 29, \"n_ot\": \"VF-APV-01\", \"fecha\": \"2026-02-16\", \"descripcion\": \"DETALLE PRUEBA VF-APV-01\", \"id_ai_turno\": 2, \"id_miembro_cco\": \"M-001\", \"id_user_act\": \"12345678\", \"id_miembro_ccf\": \"M-012\", \"id_ai_estado\": 12, \"cant_tec\": 4, \"hora_ini_pre\": \"07:00\", \"hora_fin_pre\": \"07:30\", \"hora_ini_tra\": \"07:30\", \"hora_fin_tra\": \"08:00\", \"hora_ini_eje\": \"08:00\", \"hora_fin_eje\": \"10:00\", \"observacion\": \"PRUEBA\"}', '{\"descripcion\": [\"DETALLE PRUEBA VF-APV-01: actividad programada\", \"DETALLE PRUEBA VF-APV-01\"]}', '2026-02-27 13:44:05', '1576', 'u_admin@localhost', 'localhost', 'descripcion', '1'),
('6', '2da71a02-14e8-11f1-93d3-989096ab40dc', '000000', 'miembro', 'UPDATE', 'id_ai_miembro=2', '{\"id_ai_miembro\": 2}', 'MODIFICAR miembro', 'UPDATE miembro id_ai_miembro=2', '{\"id_ai_miembro\": 2, \"id_miembro\": \"M-001\", \"nombre_miembro\": \"PEDRO PEREZ\", \"tipo_miembro\": 2, \"std_reg\": 1}', '{\"id_ai_miembro\": 2, \"id_miembro\": \"M-001\", \"nombre_miembro\": \"PEDRO PEREZ\", \"tipo_miembro\": 2, \"std_reg\": 1}', '{}', '2026-02-28 16:58:00', '214', 'u_admin@localhost', 'localhost', NULL, '1'),
('7', 'c5045577-14f1-11f1-93d3-989096ab40dc', '000000', 'user_system', 'UPDATE', 'id_user=12345678', '{\"id_user\": \"12345678\"}', 'MODIFICAR user_system', 'UPDATE user_system id_user=12345678', '{\"id_ai_user\": 1, \"id_user\": \"12345678\", \"user\": \"ADMINISTRADOR SISTEMA\", \"username\": \"administrador\", \"password\": \"***\", \"tipo\": 5, \"std_reg\": 1}', '{\"id_ai_user\": 1, \"id_user\": \"12345678\", \"user\": \"ADMINISTRADOR SISTEMA\", \"username\": \"administrador\", \"password\": \"***\", \"tipo\": 5, \"std_reg\": 1}', '{\"password\": \"CHANGED\"}', '2026-02-28 18:06:39', '326', 'u_admin@localhost', 'localhost', 'password', '1'),
('8', 'd1f23cf2-14fc-11f1-93d3-989096ab40dc', '000000', 'user_system', 'UPDATE', 'id_user=000000', '{\"id_user\": \"000000\"}', 'MODIFICAR user_system', 'UPDATE user_system id_user=000000', '{\"id_ai_user\": 2, \"id_user\": \"000000\", \"user\": \"USUARIO SISTEMA\", \"username\": \"root\", \"password\": \"***\", \"tipo\": 1, \"std_reg\": 1}', '{\"id_ai_user\": 2, \"id_user\": \"000000\", \"user\": \"USUARIO SISTEMA\", \"username\": \"admin\", \"password\": \"***\", \"tipo\": 1, \"std_reg\": 1}', '{\"username\": [\"root\", \"admin\"], \"password\": \"CHANGED\"}', '2026-02-28 19:25:46', '497', 'u_admin@localhost', 'localhost', 'username,password', '1');

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

-- Tabla: orden_trabajo
DROP TABLE IF EXISTS `orden_trabajo`;
CREATE TABLE `orden_trabajo` (
  `id_ai_ot` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable',
  `n_ot` varchar(30) NOT NULL COMMENT 'Número único de la orden de trabajo',
  `id_ai_area` int(11) NOT NULL COMMENT 'Área de trabajo responsable de la orden',
  `id_user` varchar(30) NOT NULL COMMENT 'Identificador único del usuario del sistema',
  `id_ai_sitio` int(11) NOT NULL COMMENT 'Identificador único del sitio de trabajo',
  `nombre_trab` varchar(500) NOT NULL COMMENT 'Descripción o nombre del trabajo a realizar',
  `fecha` date NOT NULL COMMENT 'Fecha programada de la orden de trabajo',
  `semana` varchar(100) NOT NULL COMMENT 'Semana del año correspondiente a la orden',
  `mes` varchar(100) NOT NULL COMMENT 'Mes correspondiente a la orden de trabajo',
  `std_reg` tinyint(1) NOT NULL COMMENT 'Estado lógico del registro (1=activo, 0=inactivo/eliminado lógico).',
  PRIMARY KEY (`id_ai_ot`),
  UNIQUE KEY `n_ot` (`n_ot`),
  KEY `status` (`std_reg`),
  KEY `id_user` (`id_user`),
  KEY `sitio_trab` (`id_ai_sitio`),
  KEY `id_area` (`id_ai_area`),
  CONSTRAINT `orden_trabajo_ibfk_1` FOREIGN KEY (`id_user`) REFERENCES `user_system` (`id_user`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `orden_trabajo_ibfk_2` FOREIGN KEY (`id_ai_sitio`) REFERENCES `sitio_trabajo` (`id_ai_sitio`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `orden_trabajo_ibfk_3` FOREIGN KEY (`id_ai_area`) REFERENCES `area_trabajo` (`id_ai_area`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

INSERT INTO `orden_trabajo` VALUES
('1', 'VF-SEÑ-01', '1', '000000', '1', 'MANTENIMIENTO DE DURMIENTES ÁREA PATIO', '2026-01-09', '2', '1', '1'),
('2', 'VF-SEÑ-02', '1', '000000', '1', 'TRABAJO PRUEBA VF-SEÑ-02 (AREA 1)', '2026-02-11', '7', '2', '1'),
('3', 'VF-SEÑ-03', '1', '12345678', '2', 'TRABAJO PRUEBA VF-SEÑ-03 (AREA 1)', '2026-02-12', '7', '2', '1'),
('4', 'VF-SEÑ-04', '1', '000000', '1', 'TRABAJO PRUEBA VF-SEÑ-04 (AREA 1)', '2026-02-13', '7', '2', '1'),
('5', 'VF-SEÑ-05', '1', '12345678', '2', 'TRABAJO PRUEBA VF-SEÑ-05 (AREA 1)', '2026-02-14', '7', '2', '1'),
('6', 'VF-SEÑ-06', '1', '000000', '1', 'TRABAJO PRUEBA VF-SEÑ-06 (AREA 1)', '2026-02-15', '7', '2', '1'),
('7', 'VF-APV-01', '2', '12345678', '2', 'TRABAJO PRUEBA VF-APV-01 (AREA 2)', '2026-03-13', '11', '3', '1'),
('8', 'VF-APV-02', '2', '000000', '1', 'TRABAJO PRUEBA VF-APV-02 (AREA 2)', '2026-02-17', '8', '2', '1'),
('9', 'VF-APV-03', '2', '12345678', '2', 'TRABAJO PRUEBA VF-APV-03 (AREA 2)', '2026-02-18', '8', '2', '1'),
('10', 'VF-APV-04', '2', '000000', '1', 'TRABAJO PRUEBA VF-APV-04 (AREA 2)', '2026-02-19', '8', '2', '1'),
('11', 'VF-APV-05', '2', '12345678', '2', 'TRABAJO PRUEBA VF-APV-05 (AREA 2)', '2026-02-20', '8', '2', '1'),
('12', 'VF-INF-01', '3', '000000', '1', 'TRABAJO PRUEBA VF-INF-01 (AREA 3)', '2026-02-21', '8', '2', '1'),
('13', 'VF-INF-02', '3', '12345678', '2', 'TRABAJO PRUEBA VF-INF-02 (AREA 3)', '2026-02-22', '8', '2', '1'),
('14', 'VF-INF-03', '3', '000000', '1', 'TRABAJO PRUEBA VF-INF-03 (AREA 3)', '2026-02-23', '9', '2', '1'),
('15', 'VF-INF-04', '3', '12345678', '2', 'TRABAJO PRUEBA VF-INF-04 (AREA 3)', '2026-02-24', '9', '2', '1'),
('16', 'VF-INF-05', '3', '000000', '1', 'TRABAJO PRUEBA VF-INF-05 (AREA 3)', '2026-02-25', '9', '2', '1'),
('17', 'VF-NP-01', '5', '12345678', '2', 'TRABAJO PRUEBA VF-NP-01 (AREA 5)', '2026-02-26', '9', '2', '1'),
('18', 'VF-NP-02', '5', '000000', '1', 'TRABAJO PRUEBA VF-NP-02 (AREA 5)', '2026-02-27', '9', '2', '1'),
('19', 'VF-NP-03', '5', '12345678', '2', 'TRABAJO PRUEBA VF-NP-03 (AREA 5)', '2026-02-28', '9', '2', '1'),
('20', 'VF-NP-04', '5', '000000', '1', 'TRABAJO PRUEBA VF-NP-04 (AREA 5)', '2026-03-01', '9', '3', '1'),
('21', 'VF-NP-05', '5', '12345678', '2', 'TRABAJO PRUEBA VF-NP-05 (AREA 5)', '2026-03-02', '10', '3', '1'),
('22', 'VF-APV-025', '2', '000000', '1', 'TRABAJO DE PRUEBA', '2026-02-18', '7', '2', '1'),
('23', 'VF-SEÑ-07', '1', '000000', '2', 'MANTENIMINETO DE VIAS', '2026-02-12', '1', '2', '1'),
('24', 'VF-SEÑ-08', '1', '000000', '1', 'MANTENIMINETO DE VIAS1', '2026-02-12', '1', '2', '1'),
('30', 'VF-SEÑ-09', '1', '000000', '1', 'MANTENIMINETO DE VIAS', '2026-02-12', '7', '2', '1');

-- Tabla: roles_permisos
DROP TABLE IF EXISTS `roles_permisos`;
CREATE TABLE `roles_permisos` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable',
  `nombre_rol` varchar(100) NOT NULL COMMENT 'Nombre del rol de usuario',
  `perm_usuarios_view` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Permiso para visualizar usuarios',
  `perm_usuarios_add` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Permiso para registrar nuevos usuarios',
  `perm_usuarios_edit` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Permiso para editar usuarios existentes',
  `perm_usuarios_delete` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Permiso para eliminar usuarios',
  `perm_herramienta_view` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Permiso para visualizar herramientas',
  `perm_herramienta_add` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Permiso para registrar nuevas herramientas',
  `perm_herramienta_edit` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Permiso para editar herramientas',
  `perm_herramienta_delete` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Permiso para eliminar herramientas',
  `perm_miembro_view` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Permiso para visualizar miembros',
  `perm_miembro_add` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Permiso para registrar nuevos miembros',
  `perm_miembro_edit` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Permiso para editar miembros',
  `perm_miembro_delete` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Permiso para eliminar miembros',
  `perm_ot_view` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Permiso para visualizar órdenes de trabajo',
  `perm_ot_add` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Permiso para registrar nuevas órdenes de trabajo',
  `perm_ot_edit` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Permiso para editar órdenes de trabajo',
  `perm_ot_delete` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Permiso para eliminar órdenes de trabajo',
  `perm_ot_add_detalle` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Permiso para agregar detalles a órdenes de trabajo',
  `perm_ot_generar_reporte` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Permiso para generar reportes de órdenes de trabajo',
  `perm_ot_add_herramienta` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Permiso para asociar herramientas a órdenes de trabajo',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

INSERT INTO `roles_permisos` VALUES
('1', 'ROOT', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1'),
('5', 'ADMINISTRADOR', '1', '1', '1', '1', '1', '1', '0', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1'),
('17', 'PRUEBA', '0', '0', '0', '0', '1', '0', '0', '0', '0', '0', '0', '0', '1', '0', '0', '0', '1', '0', '1');

-- Tabla: sitio_trabajo
DROP TABLE IF EXISTS `sitio_trabajo`;
CREATE TABLE `sitio_trabajo` (
  `id_ai_sitio` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable',
  `nombre_sitio` varchar(100) NOT NULL COMMENT 'Nombre del sitio o ubicación de trabajo',
  `std_reg` tinyint(1) NOT NULL COMMENT 'Estado lógico del registro (1=activo, 0=inactivo/eliminado lógico).',
  PRIMARY KEY (`id_ai_sitio`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

INSERT INTO `sitio_trabajo` VALUES
('1', 'PATIO', '1'),
('2', 'LINEA', '1'),
('10', 'PRUEBA SITIO', '0'),
('11', 'PRUEBA SITIO', '1'),
('12', 'DDGDG', '0'),
('13', 'NOMINA1', '0');

-- Tabla: turno_trabajo
DROP TABLE IF EXISTS `turno_trabajo`;
CREATE TABLE `turno_trabajo` (
  `id_ai_turno` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable',
  `nombre_turno` varchar(100) NOT NULL COMMENT 'Nombre descriptivo del turno de trabajo',
  `std_reg` tinyint(1) NOT NULL COMMENT 'Estado lógico del registro (1=activo, 0=inactivo/eliminado lógico).',
  PRIMARY KEY (`id_ai_turno`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

INSERT INTO `turno_trabajo` VALUES
('1', 'MAÑANA', '1'),
('2', 'TARDE', '1'),
('3', 'NOCHE', '1'),
('4', 'MEDIA-NOCHE', '1'),
('6', 'PRUEBA TUERNO', '0'),
('7', 'PRUEBA TURNO', '0'),
('8', 'MEDIO-DIA1', '0'),
('9', 'MEDA-NOCHE', '0');

-- Tabla: user_system
DROP TABLE IF EXISTS `user_system`;
CREATE TABLE `user_system` (
  `id_ai_user` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable',
  `id_user` varchar(30) NOT NULL COMMENT 'Identificador único del usuario del sistema',
  `user` varchar(30) NOT NULL COMMENT 'Nombre completo del usuario del sistema',
  `username` varchar(50) NOT NULL COMMENT 'Nombre de usuario utilizado para iniciar sesión',
  `password` varchar(60) NOT NULL COMMENT 'Contraseña encriptada del usuario',
  `tipo` int(11) NOT NULL COMMENT 'Rol o perfil de permisos asociado al usuario',
  `db_profile` enum('lector','escritor','admin') NOT NULL DEFAULT 'lector' COMMENT 'Perfil de acceso real a BD',
  `std_reg` tinyint(1) NOT NULL COMMENT 'Estado lógico del registro (1=activo, 0=inactivo/eliminado lógico).',
  PRIMARY KEY (`id_ai_user`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `id_user` (`id_user`),
  KEY `tipo` (`tipo`),
  KEY `idx_user_system_db_profile` (`db_profile`),
  CONSTRAINT `fk_user_system_roles` FOREIGN KEY (`tipo`) REFERENCES `roles_permisos` (`id`),
  CONSTRAINT `user_system_ibfk_1` FOREIGN KEY (`tipo`) REFERENCES `roles_permisos` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

INSERT INTO `user_system` VALUES
('1', '12345678', 'ADMINISTRADOR SISTEMA', 'administrador', '$2y$10$u4GboEjP3kgQCgRlwN7/MObm.qx6omuXdzycYHVIYTiUHgGh.ye7a', '5', 'admin', '1'),
('2', '000000', 'USUARIO SISTEMA', 'admin', '$2y$10$zj.SJ/wXBW0Ofh1F3kynoO/0SN2C.KxZIA3e2qD1h4IstUVDAqR0q', '1', 'admin', '1'),
('4', '26580187', 'Walter Ramone', 'prueba', '$2y$10$pRFd8LlDu5WVnACktZBFZuv47EuR2nsxx1qvLVdEKJoQBLtMfT0ku', '17', 'admin', '1');

-- Trigger: trg_area_trabajo_ai
DROP TRIGGER IF EXISTS `trg_area_trabajo_ai`;
DELIMITER $$
CREATE TRIGGER `trg_area_trabajo_ai` AFTER INSERT ON `area_trabajo` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_user` FROM `user_system` WHERE `id_user` = @app_user LIMIT 1),
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
)$$
DELIMITER ;

-- Trigger: trg_area_trabajo_au
DROP TRIGGER IF EXISTS `trg_area_trabajo_au`;
DELIMITER $$
CREATE TRIGGER `trg_area_trabajo_au` AFTER UPDATE ON `area_trabajo` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_user` FROM `user_system` WHERE `id_user` = @app_user LIMIT 1),
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
)$$
DELIMITER ;

-- Trigger: trg_area_trabajo_bd
DROP TRIGGER IF EXISTS `trg_area_trabajo_bd`;
DELIMITER $$
CREATE TRIGGER `trg_area_trabajo_bd` BEFORE DELETE ON `area_trabajo` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE físico en area_trabajo. Use eliminación lógica (UPDATE area_trabajo SET std_reg=0 ...).'$$
DELIMITER ;

-- Trigger: trg_detalle_orden_ai
DROP TRIGGER IF EXISTS `trg_detalle_orden_ai`;
DELIMITER $$
CREATE TRIGGER `trg_detalle_orden_ai` AFTER INSERT ON `detalle_orden` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_user` FROM `user_system` WHERE `id_user` = @app_user LIMIT 1),
  'detalle_orden',
  'INSERT',
  CONCAT('id_ai_detalle=', NEW.`id_ai_detalle`),
  JSON_OBJECT('id_ai_detalle', NEW.`id_ai_detalle`),
  CONCAT('CREAR ', 'detalle_orden'),
  CONCAT('INSERT detalle_orden ', CONCAT('id_ai_detalle=', NEW.`id_ai_detalle`)),
  NULL,
  JSON_OBJECT('id_ai_detalle', NEW.`id_ai_detalle`, 'n_ot', NEW.`n_ot`, 'fecha', NEW.`fecha`, 'descripcion', NEW.`descripcion`, 'id_ai_turno', NEW.`id_ai_turno`, 'id_miembro_cco', NEW.`id_miembro_cco`, 'id_user_act', NEW.`id_user_act`, 'id_miembro_ccf', NEW.`id_miembro_ccf`, 'id_ai_estado', NEW.`id_ai_estado`, 'cant_tec', NEW.`cant_tec`, 'hora_ini_pre', NEW.`hora_ini_pre`, 'hora_fin_pre', NEW.`hora_fin_pre`, 'hora_ini_tra', NEW.`hora_ini_tra`, 'hora_fin_tra', NEW.`hora_fin_tra`, 'hora_ini_eje', NEW.`hora_ini_eje`, 'hora_fin_eje', NEW.`hora_fin_eje`, 'observacion', NEW.`observacion`),
  JSON_OBJECT('id_ai_detalle', NEW.`id_ai_detalle`, 'n_ot', NEW.`n_ot`, 'fecha', NEW.`fecha`, 'descripcion', NEW.`descripcion`, 'id_ai_turno', NEW.`id_ai_turno`, 'id_miembro_cco', NEW.`id_miembro_cco`, 'id_user_act', NEW.`id_user_act`, 'id_miembro_ccf', NEW.`id_miembro_ccf`, 'id_ai_estado', NEW.`id_ai_estado`, 'cant_tec', NEW.`cant_tec`, 'hora_ini_pre', NEW.`hora_ini_pre`, 'hora_fin_pre', NEW.`hora_fin_pre`, 'hora_ini_tra', NEW.`hora_ini_tra`, 'hora_fin_tra', NEW.`hora_fin_tra`, 'hora_ini_eje', NEW.`hora_ini_eje`, 'hora_fin_eje', NEW.`hora_fin_eje`, 'observacion', NEW.`observacion`),
  'id_ai_detalle,n_ot,fecha,descripcion,id_ai_turno,id_miembro_cco,id_user_act,id_miembro_ccf,id_ai_estado,cant_tec,hora_ini_pre,hora_fin_pre,hora_ini_tra,hora_fin_tra,hora_ini_eje,hora_fin_eje,observacion',
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)$$
DELIMITER ;

-- Trigger: trg_detalle_orden_au
DROP TRIGGER IF EXISTS `trg_detalle_orden_au`;
DELIMITER $$
CREATE TRIGGER `trg_detalle_orden_au` AFTER UPDATE ON `detalle_orden` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_user` FROM `user_system` WHERE `id_user` = @app_user LIMIT 1),
  'detalle_orden',
  'UPDATE',
  CONCAT('id_ai_detalle=', NEW.`id_ai_detalle`),
  JSON_OBJECT('id_ai_detalle', NEW.`id_ai_detalle`),
  CONCAT('MODIFICAR ', 'detalle_orden'),
  CONCAT('UPDATE detalle_orden ', CONCAT('id_ai_detalle=', NEW.`id_ai_detalle`)),
  JSON_OBJECT('id_ai_detalle', OLD.`id_ai_detalle`, 'n_ot', OLD.`n_ot`, 'fecha', OLD.`fecha`, 'descripcion', OLD.`descripcion`, 'id_ai_turno', OLD.`id_ai_turno`, 'id_miembro_cco', OLD.`id_miembro_cco`, 'id_user_act', OLD.`id_user_act`, 'id_miembro_ccf', OLD.`id_miembro_ccf`, 'id_ai_estado', OLD.`id_ai_estado`, 'cant_tec', OLD.`cant_tec`, 'hora_ini_pre', OLD.`hora_ini_pre`, 'hora_fin_pre', OLD.`hora_fin_pre`, 'hora_ini_tra', OLD.`hora_ini_tra`, 'hora_fin_tra', OLD.`hora_fin_tra`, 'hora_ini_eje', OLD.`hora_ini_eje`, 'hora_fin_eje', OLD.`hora_fin_eje`, 'observacion', OLD.`observacion`),
  JSON_OBJECT('id_ai_detalle', NEW.`id_ai_detalle`, 'n_ot', NEW.`n_ot`, 'fecha', NEW.`fecha`, 'descripcion', NEW.`descripcion`, 'id_ai_turno', NEW.`id_ai_turno`, 'id_miembro_cco', NEW.`id_miembro_cco`, 'id_user_act', NEW.`id_user_act`, 'id_miembro_ccf', NEW.`id_miembro_ccf`, 'id_ai_estado', NEW.`id_ai_estado`, 'cant_tec', NEW.`cant_tec`, 'hora_ini_pre', NEW.`hora_ini_pre`, 'hora_fin_pre', NEW.`hora_fin_pre`, 'hora_ini_tra', NEW.`hora_ini_tra`, 'hora_fin_tra', NEW.`hora_fin_tra`, 'hora_ini_eje', NEW.`hora_ini_eje`, 'hora_fin_eje', NEW.`hora_fin_eje`, 'observacion', NEW.`observacion`),
  JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_OBJECT(), IF(NOT (OLD.`id_ai_detalle` <=> NEW.`id_ai_detalle`), JSON_OBJECT('id_ai_detalle', JSON_ARRAY(OLD.`id_ai_detalle`, NEW.`id_ai_detalle`)), JSON_OBJECT())), IF(NOT (OLD.`n_ot` <=> NEW.`n_ot`), JSON_OBJECT('n_ot', JSON_ARRAY(OLD.`n_ot`, NEW.`n_ot`)), JSON_OBJECT())), IF(NOT (OLD.`fecha` <=> NEW.`fecha`), JSON_OBJECT('fecha', JSON_ARRAY(OLD.`fecha`, NEW.`fecha`)), JSON_OBJECT())), IF(NOT (OLD.`descripcion` <=> NEW.`descripcion`), JSON_OBJECT('descripcion', JSON_ARRAY(OLD.`descripcion`, NEW.`descripcion`)), JSON_OBJECT())), IF(NOT (OLD.`id_ai_turno` <=> NEW.`id_ai_turno`), JSON_OBJECT('id_ai_turno', JSON_ARRAY(OLD.`id_ai_turno`, NEW.`id_ai_turno`)), JSON_OBJECT())), IF(NOT (OLD.`id_miembro_cco` <=> NEW.`id_miembro_cco`), JSON_OBJECT('id_miembro_cco', JSON_ARRAY(OLD.`id_miembro_cco`, NEW.`id_miembro_cco`)), JSON_OBJECT())), IF(NOT (OLD.`id_user_act` <=> NEW.`id_user_act`), JSON_OBJECT('id_user_act', JSON_ARRAY(OLD.`id_user_act`, NEW.`id_user_act`)), JSON_OBJECT())), IF(NOT (OLD.`id_miembro_ccf` <=> NEW.`id_miembro_ccf`), JSON_OBJECT('id_miembro_ccf', JSON_ARRAY(OLD.`id_miembro_ccf`, NEW.`id_miembro_ccf`)), JSON_OBJECT())), IF(NOT (OLD.`id_ai_estado` <=> NEW.`id_ai_estado`), JSON_OBJECT('id_ai_estado', JSON_ARRAY(OLD.`id_ai_estado`, NEW.`id_ai_estado`)), JSON_OBJECT())), IF(NOT (OLD.`cant_tec` <=> NEW.`cant_tec`), JSON_OBJECT('cant_tec', JSON_ARRAY(OLD.`cant_tec`, NEW.`cant_tec`)), JSON_OBJECT())), IF(NOT (OLD.`hora_ini_pre` <=> NEW.`hora_ini_pre`), JSON_OBJECT('hora_ini_pre', JSON_ARRAY(OLD.`hora_ini_pre`, NEW.`hora_ini_pre`)), JSON_OBJECT())), IF(NOT (OLD.`hora_fin_pre` <=> NEW.`hora_fin_pre`), JSON_OBJECT('hora_fin_pre', JSON_ARRAY(OLD.`hora_fin_pre`, NEW.`hora_fin_pre`)), JSON_OBJECT())), IF(NOT (OLD.`hora_ini_tra` <=> NEW.`hora_ini_tra`), JSON_OBJECT('hora_ini_tra', JSON_ARRAY(OLD.`hora_ini_tra`, NEW.`hora_ini_tra`)), JSON_OBJECT())), IF(NOT (OLD.`hora_fin_tra` <=> NEW.`hora_fin_tra`), JSON_OBJECT('hora_fin_tra', JSON_ARRAY(OLD.`hora_fin_tra`, NEW.`hora_fin_tra`)), JSON_OBJECT())), IF(NOT (OLD.`hora_ini_eje` <=> NEW.`hora_ini_eje`), JSON_OBJECT('hora_ini_eje', JSON_ARRAY(OLD.`hora_ini_eje`, NEW.`hora_ini_eje`)), JSON_OBJECT())), IF(NOT (OLD.`hora_fin_eje` <=> NEW.`hora_fin_eje`), JSON_OBJECT('hora_fin_eje', JSON_ARRAY(OLD.`hora_fin_eje`, NEW.`hora_fin_eje`)), JSON_OBJECT())), IF(NOT (OLD.`observacion` <=> NEW.`observacion`), JSON_OBJECT('observacion', JSON_ARRAY(OLD.`observacion`, NEW.`observacion`)), JSON_OBJECT())),
  NULLIF(CONCAT_WS(',', IF(NOT (OLD.`id_ai_detalle` <=> NEW.`id_ai_detalle`), 'id_ai_detalle', NULL), IF(NOT (OLD.`n_ot` <=> NEW.`n_ot`), 'n_ot', NULL), IF(NOT (OLD.`fecha` <=> NEW.`fecha`), 'fecha', NULL), IF(NOT (OLD.`descripcion` <=> NEW.`descripcion`), 'descripcion', NULL), IF(NOT (OLD.`id_ai_turno` <=> NEW.`id_ai_turno`), 'id_ai_turno', NULL), IF(NOT (OLD.`id_miembro_cco` <=> NEW.`id_miembro_cco`), 'id_miembro_cco', NULL), IF(NOT (OLD.`id_user_act` <=> NEW.`id_user_act`), 'id_user_act', NULL), IF(NOT (OLD.`id_miembro_ccf` <=> NEW.`id_miembro_ccf`), 'id_miembro_ccf', NULL), IF(NOT (OLD.`id_ai_estado` <=> NEW.`id_ai_estado`), 'id_ai_estado', NULL), IF(NOT (OLD.`cant_tec` <=> NEW.`cant_tec`), 'cant_tec', NULL), IF(NOT (OLD.`hora_ini_pre` <=> NEW.`hora_ini_pre`), 'hora_ini_pre', NULL), IF(NOT (OLD.`hora_fin_pre` <=> NEW.`hora_fin_pre`), 'hora_fin_pre', NULL), IF(NOT (OLD.`hora_ini_tra` <=> NEW.`hora_ini_tra`), 'hora_ini_tra', NULL), IF(NOT (OLD.`hora_fin_tra` <=> NEW.`hora_fin_tra`), 'hora_fin_tra', NULL), IF(NOT (OLD.`hora_ini_eje` <=> NEW.`hora_ini_eje`), 'hora_ini_eje', NULL), IF(NOT (OLD.`hora_fin_eje` <=> NEW.`hora_fin_eje`), 'hora_fin_eje', NULL), IF(NOT (OLD.`observacion` <=> NEW.`observacion`), 'observacion', NULL)), ''),
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)$$
DELIMITER ;

-- Trigger: trg_detalle_orden_ad
DROP TRIGGER IF EXISTS `trg_detalle_orden_ad`;
DELIMITER $$
CREATE TRIGGER `trg_detalle_orden_ad` AFTER DELETE ON `detalle_orden` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_user` FROM `user_system` WHERE `id_user` = @app_user LIMIT 1),
  'detalle_orden',
  'DELETE',
  CONCAT('id_ai_detalle=', OLD.`id_ai_detalle`),
  JSON_OBJECT('id_ai_detalle', OLD.`id_ai_detalle`),
  CONCAT('ELIMINAR ', 'detalle_orden'),
  CONCAT('DELETE detalle_orden ', CONCAT('id_ai_detalle=', OLD.`id_ai_detalle`)),
  JSON_OBJECT('id_ai_detalle', OLD.`id_ai_detalle`, 'n_ot', OLD.`n_ot`, 'fecha', OLD.`fecha`, 'descripcion', OLD.`descripcion`, 'id_ai_turno', OLD.`id_ai_turno`, 'id_miembro_cco', OLD.`id_miembro_cco`, 'id_user_act', OLD.`id_user_act`, 'id_miembro_ccf', OLD.`id_miembro_ccf`, 'id_ai_estado', OLD.`id_ai_estado`, 'cant_tec', OLD.`cant_tec`, 'hora_ini_pre', OLD.`hora_ini_pre`, 'hora_fin_pre', OLD.`hora_fin_pre`, 'hora_ini_tra', OLD.`hora_ini_tra`, 'hora_fin_tra', OLD.`hora_fin_tra`, 'hora_ini_eje', OLD.`hora_ini_eje`, 'hora_fin_eje', OLD.`hora_fin_eje`, 'observacion', OLD.`observacion`),
  NULL,
  NULL,
  NULL,
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)$$
DELIMITER ;

-- Trigger: trg_empresa_config_ai
DROP TRIGGER IF EXISTS `trg_empresa_config_ai`;
DELIMITER $$
CREATE TRIGGER `trg_empresa_config_ai` AFTER INSERT ON `empresa_config` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_user` FROM `user_system` WHERE `id_user` = @app_user LIMIT 1),
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
)$$
DELIMITER ;

-- Trigger: trg_empresa_config_au
DROP TRIGGER IF EXISTS `trg_empresa_config_au`;
DELIMITER $$
CREATE TRIGGER `trg_empresa_config_au` AFTER UPDATE ON `empresa_config` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_user` FROM `user_system` WHERE `id_user` = @app_user LIMIT 1),
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
)$$
DELIMITER ;

-- Trigger: trg_empresa_config_ad
DROP TRIGGER IF EXISTS `trg_empresa_config_ad`;
DELIMITER $$
CREATE TRIGGER `trg_empresa_config_ad` AFTER DELETE ON `empresa_config` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_user` FROM `user_system` WHERE `id_user` = @app_user LIMIT 1),
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
)$$
DELIMITER ;

-- Trigger: trg_estado_ot_ai
DROP TRIGGER IF EXISTS `trg_estado_ot_ai`;
DELIMITER $$
CREATE TRIGGER `trg_estado_ot_ai` AFTER INSERT ON `estado_ot` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_user` FROM `user_system` WHERE `id_user` = @app_user LIMIT 1),
  'estado_ot',
  'INSERT',
  CONCAT('id_ai_estado=', NEW.`id_ai_estado`),
  JSON_OBJECT('id_ai_estado', NEW.`id_ai_estado`),
  CONCAT('CREAR ', 'estado_ot'),
  CONCAT('INSERT estado_ot ', CONCAT('id_ai_estado=', NEW.`id_ai_estado`)),
  NULL,
  JSON_OBJECT('id_ai_estado', NEW.`id_ai_estado`, 'nombre_estado', NEW.`nombre_estado`, 'color', NEW.`color`, 'std_reg', NEW.`std_reg`),
  JSON_OBJECT('id_ai_estado', NEW.`id_ai_estado`, 'nombre_estado', NEW.`nombre_estado`, 'color', NEW.`color`, 'std_reg', NEW.`std_reg`),
  'id_ai_estado,nombre_estado,color,std_reg',
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)$$
DELIMITER ;

-- Trigger: trg_estado_ot_au
DROP TRIGGER IF EXISTS `trg_estado_ot_au`;
DELIMITER $$
CREATE TRIGGER `trg_estado_ot_au` AFTER UPDATE ON `estado_ot` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_user` FROM `user_system` WHERE `id_user` = @app_user LIMIT 1),
  'estado_ot',
  CASE WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN 'SOFT_DELETE' WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN 'RESTORE' ELSE 'UPDATE' END,
  CONCAT('id_ai_estado=', NEW.`id_ai_estado`),
  JSON_OBJECT('id_ai_estado', NEW.`id_ai_estado`),
  CASE WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN CONCAT('ELIMINAR (LOGICO) ', 'estado_ot') WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN CONCAT('REACTIVAR ', 'estado_ot') ELSE CONCAT('MODIFICAR ', 'estado_ot') END,
  CASE WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN CONCAT('SOFT_DELETE estado_ot ', CONCAT('id_ai_estado=', NEW.`id_ai_estado`)) WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN CONCAT('RESTORE estado_ot ', CONCAT('id_ai_estado=', NEW.`id_ai_estado`)) ELSE CONCAT('UPDATE estado_ot ', CONCAT('id_ai_estado=', NEW.`id_ai_estado`)) END,
  JSON_OBJECT('id_ai_estado', OLD.`id_ai_estado`, 'nombre_estado', OLD.`nombre_estado`, 'color', OLD.`color`, 'std_reg', OLD.`std_reg`),
  JSON_OBJECT('id_ai_estado', NEW.`id_ai_estado`, 'nombre_estado', NEW.`nombre_estado`, 'color', NEW.`color`, 'std_reg', NEW.`std_reg`),
  JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_OBJECT(), IF(NOT (OLD.`id_ai_estado` <=> NEW.`id_ai_estado`), JSON_OBJECT('id_ai_estado', JSON_ARRAY(OLD.`id_ai_estado`, NEW.`id_ai_estado`)), JSON_OBJECT())), IF(NOT (OLD.`nombre_estado` <=> NEW.`nombre_estado`), JSON_OBJECT('nombre_estado', JSON_ARRAY(OLD.`nombre_estado`, NEW.`nombre_estado`)), JSON_OBJECT())), IF(NOT (OLD.`color` <=> NEW.`color`), JSON_OBJECT('color', JSON_ARRAY(OLD.`color`, NEW.`color`)), JSON_OBJECT())), IF(NOT (OLD.`std_reg` <=> NEW.`std_reg`), JSON_OBJECT('std_reg', JSON_ARRAY(OLD.`std_reg`, NEW.`std_reg`)), JSON_OBJECT())),
  NULLIF(CONCAT_WS(',', IF(NOT (OLD.`id_ai_estado` <=> NEW.`id_ai_estado`), 'id_ai_estado', NULL), IF(NOT (OLD.`nombre_estado` <=> NEW.`nombre_estado`), 'nombre_estado', NULL), IF(NOT (OLD.`color` <=> NEW.`color`), 'color', NULL), IF(NOT (OLD.`std_reg` <=> NEW.`std_reg`), 'std_reg', NULL)), ''),
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)$$
DELIMITER ;

-- Trigger: trg_estado_ot_bd
DROP TRIGGER IF EXISTS `trg_estado_ot_bd`;
DELIMITER $$
CREATE TRIGGER `trg_estado_ot_bd` BEFORE DELETE ON `estado_ot` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE físico en estado_ot. Use eliminación lógica (UPDATE estado_ot SET std_reg=0 ...).'$$
DELIMITER ;

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

-- Trigger: trg_log_user_no_update
DROP TRIGGER IF EXISTS `trg_log_user_no_update`;
DELIMITER $$
CREATE TRIGGER `trg_log_user_no_update` BEFORE UPDATE ON `log_user` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite modificar registros de auditoría (log_user).'$$
DELIMITER ;

-- Trigger: trg_log_user_no_delete
DROP TRIGGER IF EXISTS `trg_log_user_no_delete`;
DELIMITER $$
CREATE TRIGGER `trg_log_user_no_delete` BEFORE DELETE ON `log_user` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite eliminar registros de auditoría (log_user).'$$
DELIMITER ;

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

-- Trigger: trg_orden_trabajo_ai
DROP TRIGGER IF EXISTS `trg_orden_trabajo_ai`;
DELIMITER $$
CREATE TRIGGER `trg_orden_trabajo_ai` AFTER INSERT ON `orden_trabajo` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_user` FROM `user_system` WHERE `id_user` = @app_user LIMIT 1),
  'orden_trabajo',
  'INSERT',
  CONCAT('n_ot=', NEW.`n_ot`),
  JSON_OBJECT('n_ot', NEW.`n_ot`),
  CONCAT('CREAR ', 'orden_trabajo'),
  CONCAT('INSERT orden_trabajo ', CONCAT('n_ot=', NEW.`n_ot`)),
  NULL,
  JSON_OBJECT('id_ai_ot', NEW.`id_ai_ot`, 'n_ot', NEW.`n_ot`, 'id_ai_area', NEW.`id_ai_area`, 'id_user', NEW.`id_user`, 'id_ai_sitio', NEW.`id_ai_sitio`, 'nombre_trab', NEW.`nombre_trab`, 'fecha', NEW.`fecha`, 'semana', NEW.`semana`, 'mes', NEW.`mes`, 'std_reg', NEW.`std_reg`),
  JSON_OBJECT('id_ai_ot', NEW.`id_ai_ot`, 'n_ot', NEW.`n_ot`, 'id_ai_area', NEW.`id_ai_area`, 'id_user', NEW.`id_user`, 'id_ai_sitio', NEW.`id_ai_sitio`, 'nombre_trab', NEW.`nombre_trab`, 'fecha', NEW.`fecha`, 'semana', NEW.`semana`, 'mes', NEW.`mes`, 'std_reg', NEW.`std_reg`),
  'id_ai_ot,n_ot,id_ai_area,id_user,id_ai_sitio,nombre_trab,fecha,semana,mes,std_reg',
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)$$
DELIMITER ;

-- Trigger: trg_orden_trabajo_au
DROP TRIGGER IF EXISTS `trg_orden_trabajo_au`;
DELIMITER $$
CREATE TRIGGER `trg_orden_trabajo_au` AFTER UPDATE ON `orden_trabajo` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_user` FROM `user_system` WHERE `id_user` = @app_user LIMIT 1),
  'orden_trabajo',
  CASE WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN 'SOFT_DELETE' WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN 'RESTORE' ELSE 'UPDATE' END,
  CONCAT('n_ot=', NEW.`n_ot`),
  JSON_OBJECT('n_ot', NEW.`n_ot`),
  CASE WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN CONCAT('ELIMINAR (LOGICO) ', 'orden_trabajo') WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN CONCAT('REACTIVAR ', 'orden_trabajo') ELSE CONCAT('MODIFICAR ', 'orden_trabajo') END,
  CASE WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN CONCAT('SOFT_DELETE orden_trabajo ', CONCAT('n_ot=', NEW.`n_ot`)) WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN CONCAT('RESTORE orden_trabajo ', CONCAT('n_ot=', NEW.`n_ot`)) ELSE CONCAT('UPDATE orden_trabajo ', CONCAT('n_ot=', NEW.`n_ot`)) END,
  JSON_OBJECT('id_ai_ot', OLD.`id_ai_ot`, 'n_ot', OLD.`n_ot`, 'id_ai_area', OLD.`id_ai_area`, 'id_user', OLD.`id_user`, 'id_ai_sitio', OLD.`id_ai_sitio`, 'nombre_trab', OLD.`nombre_trab`, 'fecha', OLD.`fecha`, 'semana', OLD.`semana`, 'mes', OLD.`mes`, 'std_reg', OLD.`std_reg`),
  JSON_OBJECT('id_ai_ot', NEW.`id_ai_ot`, 'n_ot', NEW.`n_ot`, 'id_ai_area', NEW.`id_ai_area`, 'id_user', NEW.`id_user`, 'id_ai_sitio', NEW.`id_ai_sitio`, 'nombre_trab', NEW.`nombre_trab`, 'fecha', NEW.`fecha`, 'semana', NEW.`semana`, 'mes', NEW.`mes`, 'std_reg', NEW.`std_reg`),
  JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_OBJECT(), IF(NOT (OLD.`id_ai_ot` <=> NEW.`id_ai_ot`), JSON_OBJECT('id_ai_ot', JSON_ARRAY(OLD.`id_ai_ot`, NEW.`id_ai_ot`)), JSON_OBJECT())), IF(NOT (OLD.`n_ot` <=> NEW.`n_ot`), JSON_OBJECT('n_ot', JSON_ARRAY(OLD.`n_ot`, NEW.`n_ot`)), JSON_OBJECT())), IF(NOT (OLD.`id_ai_area` <=> NEW.`id_ai_area`), JSON_OBJECT('id_ai_area', JSON_ARRAY(OLD.`id_ai_area`, NEW.`id_ai_area`)), JSON_OBJECT())), IF(NOT (OLD.`id_user` <=> NEW.`id_user`), JSON_OBJECT('id_user', JSON_ARRAY(OLD.`id_user`, NEW.`id_user`)), JSON_OBJECT())), IF(NOT (OLD.`id_ai_sitio` <=> NEW.`id_ai_sitio`), JSON_OBJECT('id_ai_sitio', JSON_ARRAY(OLD.`id_ai_sitio`, NEW.`id_ai_sitio`)), JSON_OBJECT())), IF(NOT (OLD.`nombre_trab` <=> NEW.`nombre_trab`), JSON_OBJECT('nombre_trab', JSON_ARRAY(OLD.`nombre_trab`, NEW.`nombre_trab`)), JSON_OBJECT())), IF(NOT (OLD.`fecha` <=> NEW.`fecha`), JSON_OBJECT('fecha', JSON_ARRAY(OLD.`fecha`, NEW.`fecha`)), JSON_OBJECT())), IF(NOT (OLD.`semana` <=> NEW.`semana`), JSON_OBJECT('semana', JSON_ARRAY(OLD.`semana`, NEW.`semana`)), JSON_OBJECT())), IF(NOT (OLD.`mes` <=> NEW.`mes`), JSON_OBJECT('mes', JSON_ARRAY(OLD.`mes`, NEW.`mes`)), JSON_OBJECT())), IF(NOT (OLD.`std_reg` <=> NEW.`std_reg`), JSON_OBJECT('std_reg', JSON_ARRAY(OLD.`std_reg`, NEW.`std_reg`)), JSON_OBJECT())),
  NULLIF(CONCAT_WS(',', IF(NOT (OLD.`id_ai_ot` <=> NEW.`id_ai_ot`), 'id_ai_ot', NULL), IF(NOT (OLD.`n_ot` <=> NEW.`n_ot`), 'n_ot', NULL), IF(NOT (OLD.`id_ai_area` <=> NEW.`id_ai_area`), 'id_ai_area', NULL), IF(NOT (OLD.`id_user` <=> NEW.`id_user`), 'id_user', NULL), IF(NOT (OLD.`id_ai_sitio` <=> NEW.`id_ai_sitio`), 'id_ai_sitio', NULL), IF(NOT (OLD.`nombre_trab` <=> NEW.`nombre_trab`), 'nombre_trab', NULL), IF(NOT (OLD.`fecha` <=> NEW.`fecha`), 'fecha', NULL), IF(NOT (OLD.`semana` <=> NEW.`semana`), 'semana', NULL), IF(NOT (OLD.`mes` <=> NEW.`mes`), 'mes', NULL), IF(NOT (OLD.`std_reg` <=> NEW.`std_reg`), 'std_reg', NULL)), ''),
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)$$
DELIMITER ;

-- Trigger: trg_orden_trabajo_bd
DROP TRIGGER IF EXISTS `trg_orden_trabajo_bd`;
DELIMITER $$
CREATE TRIGGER `trg_orden_trabajo_bd` BEFORE DELETE ON `orden_trabajo` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE físico en orden_trabajo. Use eliminación lógica (UPDATE orden_trabajo SET std_reg=0 ...).'$$
DELIMITER ;

-- Trigger: trg_roles_permisos_ai
DROP TRIGGER IF EXISTS `trg_roles_permisos_ai`;
DELIMITER $$
CREATE TRIGGER `trg_roles_permisos_ai` AFTER INSERT ON `roles_permisos` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_user` FROM `user_system` WHERE `id_user` = @app_user LIMIT 1),
  'roles_permisos',
  'INSERT',
  CONCAT('id=', NEW.`id`),
  JSON_OBJECT('id', NEW.`id`),
  CONCAT('CREAR ', 'roles_permisos'),
  CONCAT('INSERT roles_permisos ', CONCAT('id=', NEW.`id`)),
  NULL,
  JSON_OBJECT('id', NEW.`id`, 'nombre_rol', NEW.`nombre_rol`, 'perm_usuarios_view', NEW.`perm_usuarios_view`, 'perm_usuarios_add', NEW.`perm_usuarios_add`, 'perm_usuarios_edit', NEW.`perm_usuarios_edit`, 'perm_usuarios_delete', NEW.`perm_usuarios_delete`, 'perm_herramienta_view', NEW.`perm_herramienta_view`, 'perm_herramienta_add', NEW.`perm_herramienta_add`, 'perm_herramienta_edit', NEW.`perm_herramienta_edit`, 'perm_herramienta_delete', NEW.`perm_herramienta_delete`, 'perm_miembro_view', NEW.`perm_miembro_view`, 'perm_miembro_add', NEW.`perm_miembro_add`, 'perm_miembro_edit', NEW.`perm_miembro_edit`, 'perm_miembro_delete', NEW.`perm_miembro_delete`, 'perm_ot_view', NEW.`perm_ot_view`, 'perm_ot_add', NEW.`perm_ot_add`, 'perm_ot_edit', NEW.`perm_ot_edit`, 'perm_ot_delete', NEW.`perm_ot_delete`, 'perm_ot_add_detalle', NEW.`perm_ot_add_detalle`, 'perm_ot_generar_reporte', NEW.`perm_ot_generar_reporte`, 'perm_ot_add_herramienta', NEW.`perm_ot_add_herramienta`),
  JSON_OBJECT('id', NEW.`id`, 'nombre_rol', NEW.`nombre_rol`, 'perm_usuarios_view', NEW.`perm_usuarios_view`, 'perm_usuarios_add', NEW.`perm_usuarios_add`, 'perm_usuarios_edit', NEW.`perm_usuarios_edit`, 'perm_usuarios_delete', NEW.`perm_usuarios_delete`, 'perm_herramienta_view', NEW.`perm_herramienta_view`, 'perm_herramienta_add', NEW.`perm_herramienta_add`, 'perm_herramienta_edit', NEW.`perm_herramienta_edit`, 'perm_herramienta_delete', NEW.`perm_herramienta_delete`, 'perm_miembro_view', NEW.`perm_miembro_view`, 'perm_miembro_add', NEW.`perm_miembro_add`, 'perm_miembro_edit', NEW.`perm_miembro_edit`, 'perm_miembro_delete', NEW.`perm_miembro_delete`, 'perm_ot_view', NEW.`perm_ot_view`, 'perm_ot_add', NEW.`perm_ot_add`, 'perm_ot_edit', NEW.`perm_ot_edit`, 'perm_ot_delete', NEW.`perm_ot_delete`, 'perm_ot_add_detalle', NEW.`perm_ot_add_detalle`, 'perm_ot_generar_reporte', NEW.`perm_ot_generar_reporte`, 'perm_ot_add_herramienta', NEW.`perm_ot_add_herramienta`),
  'id,nombre_rol,perm_usuarios_view,perm_usuarios_add,perm_usuarios_edit,perm_usuarios_delete,perm_herramienta_view,perm_herramienta_add,perm_herramienta_edit,perm_herramienta_delete,perm_miembro_view,perm_miembro_add,perm_miembro_edit,perm_miembro_delete,perm_ot_view,perm_ot_add,perm_ot_edit,perm_ot_delete,perm_ot_add_detalle,perm_ot_generar_reporte,perm_ot_add_herramienta',
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)$$
DELIMITER ;

-- Trigger: trg_roles_permisos_au
DROP TRIGGER IF EXISTS `trg_roles_permisos_au`;
DELIMITER $$
CREATE TRIGGER `trg_roles_permisos_au` AFTER UPDATE ON `roles_permisos` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_user` FROM `user_system` WHERE `id_user` = @app_user LIMIT 1),
  'roles_permisos',
  'UPDATE',
  CONCAT('id=', NEW.`id`),
  JSON_OBJECT('id', NEW.`id`),
  CONCAT('MODIFICAR ', 'roles_permisos'),
  CONCAT('UPDATE roles_permisos ', CONCAT('id=', NEW.`id`)),
  JSON_OBJECT('id', OLD.`id`, 'nombre_rol', OLD.`nombre_rol`, 'perm_usuarios_view', OLD.`perm_usuarios_view`, 'perm_usuarios_add', OLD.`perm_usuarios_add`, 'perm_usuarios_edit', OLD.`perm_usuarios_edit`, 'perm_usuarios_delete', OLD.`perm_usuarios_delete`, 'perm_herramienta_view', OLD.`perm_herramienta_view`, 'perm_herramienta_add', OLD.`perm_herramienta_add`, 'perm_herramienta_edit', OLD.`perm_herramienta_edit`, 'perm_herramienta_delete', OLD.`perm_herramienta_delete`, 'perm_miembro_view', OLD.`perm_miembro_view`, 'perm_miembro_add', OLD.`perm_miembro_add`, 'perm_miembro_edit', OLD.`perm_miembro_edit`, 'perm_miembro_delete', OLD.`perm_miembro_delete`, 'perm_ot_view', OLD.`perm_ot_view`, 'perm_ot_add', OLD.`perm_ot_add`, 'perm_ot_edit', OLD.`perm_ot_edit`, 'perm_ot_delete', OLD.`perm_ot_delete`, 'perm_ot_add_detalle', OLD.`perm_ot_add_detalle`, 'perm_ot_generar_reporte', OLD.`perm_ot_generar_reporte`, 'perm_ot_add_herramienta', OLD.`perm_ot_add_herramienta`),
  JSON_OBJECT('id', NEW.`id`, 'nombre_rol', NEW.`nombre_rol`, 'perm_usuarios_view', NEW.`perm_usuarios_view`, 'perm_usuarios_add', NEW.`perm_usuarios_add`, 'perm_usuarios_edit', NEW.`perm_usuarios_edit`, 'perm_usuarios_delete', NEW.`perm_usuarios_delete`, 'perm_herramienta_view', NEW.`perm_herramienta_view`, 'perm_herramienta_add', NEW.`perm_herramienta_add`, 'perm_herramienta_edit', NEW.`perm_herramienta_edit`, 'perm_herramienta_delete', NEW.`perm_herramienta_delete`, 'perm_miembro_view', NEW.`perm_miembro_view`, 'perm_miembro_add', NEW.`perm_miembro_add`, 'perm_miembro_edit', NEW.`perm_miembro_edit`, 'perm_miembro_delete', NEW.`perm_miembro_delete`, 'perm_ot_view', NEW.`perm_ot_view`, 'perm_ot_add', NEW.`perm_ot_add`, 'perm_ot_edit', NEW.`perm_ot_edit`, 'perm_ot_delete', NEW.`perm_ot_delete`, 'perm_ot_add_detalle', NEW.`perm_ot_add_detalle`, 'perm_ot_generar_reporte', NEW.`perm_ot_generar_reporte`, 'perm_ot_add_herramienta', NEW.`perm_ot_add_herramienta`),
  JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_OBJECT(), IF(NOT (OLD.`id` <=> NEW.`id`), JSON_OBJECT('id', JSON_ARRAY(OLD.`id`, NEW.`id`)), JSON_OBJECT())), IF(NOT (OLD.`nombre_rol` <=> NEW.`nombre_rol`), JSON_OBJECT('nombre_rol', JSON_ARRAY(OLD.`nombre_rol`, NEW.`nombre_rol`)), JSON_OBJECT())), IF(NOT (OLD.`perm_usuarios_view` <=> NEW.`perm_usuarios_view`), JSON_OBJECT('perm_usuarios_view', JSON_ARRAY(OLD.`perm_usuarios_view`, NEW.`perm_usuarios_view`)), JSON_OBJECT())), IF(NOT (OLD.`perm_usuarios_add` <=> NEW.`perm_usuarios_add`), JSON_OBJECT('perm_usuarios_add', JSON_ARRAY(OLD.`perm_usuarios_add`, NEW.`perm_usuarios_add`)), JSON_OBJECT())), IF(NOT (OLD.`perm_usuarios_edit` <=> NEW.`perm_usuarios_edit`), JSON_OBJECT('perm_usuarios_edit', JSON_ARRAY(OLD.`perm_usuarios_edit`, NEW.`perm_usuarios_edit`)), JSON_OBJECT())), IF(NOT (OLD.`perm_usuarios_delete` <=> NEW.`perm_usuarios_delete`), JSON_OBJECT('perm_usuarios_delete', JSON_ARRAY(OLD.`perm_usuarios_delete`, NEW.`perm_usuarios_delete`)), JSON_OBJECT())), IF(NOT (OLD.`perm_herramienta_view` <=> NEW.`perm_herramienta_view`), JSON_OBJECT('perm_herramienta_view', JSON_ARRAY(OLD.`perm_herramienta_view`, NEW.`perm_herramienta_view`)), JSON_OBJECT())), IF(NOT (OLD.`perm_herramienta_add` <=> NEW.`perm_herramienta_add`), JSON_OBJECT('perm_herramienta_add', JSON_ARRAY(OLD.`perm_herramienta_add`, NEW.`perm_herramienta_add`)), JSON_OBJECT())), IF(NOT (OLD.`perm_herramienta_edit` <=> NEW.`perm_herramienta_edit`), JSON_OBJECT('perm_herramienta_edit', JSON_ARRAY(OLD.`perm_herramienta_edit`, NEW.`perm_herramienta_edit`)), JSON_OBJECT())), IF(NOT (OLD.`perm_herramienta_delete` <=> NEW.`perm_herramienta_delete`), JSON_OBJECT('perm_herramienta_delete', JSON_ARRAY(OLD.`perm_herramienta_delete`, NEW.`perm_herramienta_delete`)), JSON_OBJECT())), IF(NOT (OLD.`perm_miembro_view` <=> NEW.`perm_miembro_view`), JSON_OBJECT('perm_miembro_view', JSON_ARRAY(OLD.`perm_miembro_view`, NEW.`perm_miembro_view`)), JSON_OBJECT())), IF(NOT (OLD.`perm_miembro_add` <=> NEW.`perm_miembro_add`), JSON_OBJECT('perm_miembro_add', JSON_ARRAY(OLD.`perm_miembro_add`, NEW.`perm_miembro_add`)), JSON_OBJECT())), IF(NOT (OLD.`perm_miembro_edit` <=> NEW.`perm_miembro_edit`), JSON_OBJECT('perm_miembro_edit', JSON_ARRAY(OLD.`perm_miembro_edit`, NEW.`perm_miembro_edit`)), JSON_OBJECT())), IF(NOT (OLD.`perm_miembro_delete` <=> NEW.`perm_miembro_delete`), JSON_OBJECT('perm_miembro_delete', JSON_ARRAY(OLD.`perm_miembro_delete`, NEW.`perm_miembro_delete`)), JSON_OBJECT())), IF(NOT (OLD.`perm_ot_view` <=> NEW.`perm_ot_view`), JSON_OBJECT('perm_ot_view', JSON_ARRAY(OLD.`perm_ot_view`, NEW.`perm_ot_view`)), JSON_OBJECT())), IF(NOT (OLD.`perm_ot_add` <=> NEW.`perm_ot_add`), JSON_OBJECT('perm_ot_add', JSON_ARRAY(OLD.`perm_ot_add`, NEW.`perm_ot_add`)), JSON_OBJECT())), IF(NOT (OLD.`perm_ot_edit` <=> NEW.`perm_ot_edit`), JSON_OBJECT('perm_ot_edit', JSON_ARRAY(OLD.`perm_ot_edit`, NEW.`perm_ot_edit`)), JSON_OBJECT())), IF(NOT (OLD.`perm_ot_delete` <=> NEW.`perm_ot_delete`), JSON_OBJECT('perm_ot_delete', JSON_ARRAY(OLD.`perm_ot_delete`, NEW.`perm_ot_delete`)), JSON_OBJECT())), IF(NOT (OLD.`perm_ot_add_detalle` <=> NEW.`perm_ot_add_detalle`), JSON_OBJECT('perm_ot_add_detalle', JSON_ARRAY(OLD.`perm_ot_add_detalle`, NEW.`perm_ot_add_detalle`)), JSON_OBJECT())), IF(NOT (OLD.`perm_ot_generar_reporte` <=> NEW.`perm_ot_generar_reporte`), JSON_OBJECT('perm_ot_generar_reporte', JSON_ARRAY(OLD.`perm_ot_generar_reporte`, NEW.`perm_ot_generar_reporte`)), JSON_OBJECT())), IF(NOT (OLD.`perm_ot_add_herramienta` <=> NEW.`perm_ot_add_herramienta`), JSON_OBJECT('perm_ot_add_herramienta', JSON_ARRAY(OLD.`perm_ot_add_herramienta`, NEW.`perm_ot_add_herramienta`)), JSON_OBJECT())),
  NULLIF(CONCAT_WS(',', IF(NOT (OLD.`id` <=> NEW.`id`), 'id', NULL), IF(NOT (OLD.`nombre_rol` <=> NEW.`nombre_rol`), 'nombre_rol', NULL), IF(NOT (OLD.`perm_usuarios_view` <=> NEW.`perm_usuarios_view`), 'perm_usuarios_view', NULL), IF(NOT (OLD.`perm_usuarios_add` <=> NEW.`perm_usuarios_add`), 'perm_usuarios_add', NULL), IF(NOT (OLD.`perm_usuarios_edit` <=> NEW.`perm_usuarios_edit`), 'perm_usuarios_edit', NULL), IF(NOT (OLD.`perm_usuarios_delete` <=> NEW.`perm_usuarios_delete`), 'perm_usuarios_delete', NULL), IF(NOT (OLD.`perm_herramienta_view` <=> NEW.`perm_herramienta_view`), 'perm_herramienta_view', NULL), IF(NOT (OLD.`perm_herramienta_add` <=> NEW.`perm_herramienta_add`), 'perm_herramienta_add', NULL), IF(NOT (OLD.`perm_herramienta_edit` <=> NEW.`perm_herramienta_edit`), 'perm_herramienta_edit', NULL), IF(NOT (OLD.`perm_herramienta_delete` <=> NEW.`perm_herramienta_delete`), 'perm_herramienta_delete', NULL), IF(NOT (OLD.`perm_miembro_view` <=> NEW.`perm_miembro_view`), 'perm_miembro_view', NULL), IF(NOT (OLD.`perm_miembro_add` <=> NEW.`perm_miembro_add`), 'perm_miembro_add', NULL), IF(NOT (OLD.`perm_miembro_edit` <=> NEW.`perm_miembro_edit`), 'perm_miembro_edit', NULL), IF(NOT (OLD.`perm_miembro_delete` <=> NEW.`perm_miembro_delete`), 'perm_miembro_delete', NULL), IF(NOT (OLD.`perm_ot_view` <=> NEW.`perm_ot_view`), 'perm_ot_view', NULL), IF(NOT (OLD.`perm_ot_add` <=> NEW.`perm_ot_add`), 'perm_ot_add', NULL), IF(NOT (OLD.`perm_ot_edit` <=> NEW.`perm_ot_edit`), 'perm_ot_edit', NULL), IF(NOT (OLD.`perm_ot_delete` <=> NEW.`perm_ot_delete`), 'perm_ot_delete', NULL), IF(NOT (OLD.`perm_ot_add_detalle` <=> NEW.`perm_ot_add_detalle`), 'perm_ot_add_detalle', NULL), IF(NOT (OLD.`perm_ot_generar_reporte` <=> NEW.`perm_ot_generar_reporte`), 'perm_ot_generar_reporte', NULL), IF(NOT (OLD.`perm_ot_add_herramienta` <=> NEW.`perm_ot_add_herramienta`), 'perm_ot_add_herramienta', NULL)), ''),
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)$$
DELIMITER ;

-- Trigger: trg_roles_permisos_ad
DROP TRIGGER IF EXISTS `trg_roles_permisos_ad`;
DELIMITER $$
CREATE TRIGGER `trg_roles_permisos_ad` AFTER DELETE ON `roles_permisos` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_user` FROM `user_system` WHERE `id_user` = @app_user LIMIT 1),
  'roles_permisos',
  'DELETE',
  CONCAT('id=', OLD.`id`),
  JSON_OBJECT('id', OLD.`id`),
  CONCAT('ELIMINAR ', 'roles_permisos'),
  CONCAT('DELETE roles_permisos ', CONCAT('id=', OLD.`id`)),
  JSON_OBJECT('id', OLD.`id`, 'nombre_rol', OLD.`nombre_rol`, 'perm_usuarios_view', OLD.`perm_usuarios_view`, 'perm_usuarios_add', OLD.`perm_usuarios_add`, 'perm_usuarios_edit', OLD.`perm_usuarios_edit`, 'perm_usuarios_delete', OLD.`perm_usuarios_delete`, 'perm_herramienta_view', OLD.`perm_herramienta_view`, 'perm_herramienta_add', OLD.`perm_herramienta_add`, 'perm_herramienta_edit', OLD.`perm_herramienta_edit`, 'perm_herramienta_delete', OLD.`perm_herramienta_delete`, 'perm_miembro_view', OLD.`perm_miembro_view`, 'perm_miembro_add', OLD.`perm_miembro_add`, 'perm_miembro_edit', OLD.`perm_miembro_edit`, 'perm_miembro_delete', OLD.`perm_miembro_delete`, 'perm_ot_view', OLD.`perm_ot_view`, 'perm_ot_add', OLD.`perm_ot_add`, 'perm_ot_edit', OLD.`perm_ot_edit`, 'perm_ot_delete', OLD.`perm_ot_delete`, 'perm_ot_add_detalle', OLD.`perm_ot_add_detalle`, 'perm_ot_generar_reporte', OLD.`perm_ot_generar_reporte`, 'perm_ot_add_herramienta', OLD.`perm_ot_add_herramienta`),
  NULL,
  NULL,
  NULL,
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)$$
DELIMITER ;

-- Trigger: trg_sitio_trabajo_ai
DROP TRIGGER IF EXISTS `trg_sitio_trabajo_ai`;
DELIMITER $$
CREATE TRIGGER `trg_sitio_trabajo_ai` AFTER INSERT ON `sitio_trabajo` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_user` FROM `user_system` WHERE `id_user` = @app_user LIMIT 1),
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
)$$
DELIMITER ;

-- Trigger: trg_sitio_trabajo_au
DROP TRIGGER IF EXISTS `trg_sitio_trabajo_au`;
DELIMITER $$
CREATE TRIGGER `trg_sitio_trabajo_au` AFTER UPDATE ON `sitio_trabajo` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_user` FROM `user_system` WHERE `id_user` = @app_user LIMIT 1),
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
)$$
DELIMITER ;

-- Trigger: trg_sitio_trabajo_bd
DROP TRIGGER IF EXISTS `trg_sitio_trabajo_bd`;
DELIMITER $$
CREATE TRIGGER `trg_sitio_trabajo_bd` BEFORE DELETE ON `sitio_trabajo` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE físico en sitio_trabajo. Use eliminación lógica (UPDATE sitio_trabajo SET std_reg=0 ...).'$$
DELIMITER ;

-- Trigger: trg_turno_trabajo_ai
DROP TRIGGER IF EXISTS `trg_turno_trabajo_ai`;
DELIMITER $$
CREATE TRIGGER `trg_turno_trabajo_ai` AFTER INSERT ON `turno_trabajo` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_user` FROM `user_system` WHERE `id_user` = @app_user LIMIT 1),
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
)$$
DELIMITER ;

-- Trigger: trg_turno_trabajo_au
DROP TRIGGER IF EXISTS `trg_turno_trabajo_au`;
DELIMITER $$
CREATE TRIGGER `trg_turno_trabajo_au` AFTER UPDATE ON `turno_trabajo` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_user` FROM `user_system` WHERE `id_user` = @app_user LIMIT 1),
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
)$$
DELIMITER ;

-- Trigger: trg_turno_trabajo_bd
DROP TRIGGER IF EXISTS `trg_turno_trabajo_bd`;
DELIMITER $$
CREATE TRIGGER `trg_turno_trabajo_bd` BEFORE DELETE ON `turno_trabajo` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE físico en turno_trabajo. Use eliminación lógica (UPDATE turno_trabajo SET std_reg=0 ...).'$$
DELIMITER ;

-- Trigger: trg_user_system_ai
DROP TRIGGER IF EXISTS `trg_user_system_ai`;
DELIMITER $$
CREATE TRIGGER `trg_user_system_ai` AFTER INSERT ON `user_system` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_user` FROM `user_system` WHERE `id_user` = @app_user LIMIT 1),
  'user_system',
  'INSERT',
  CONCAT('id_user=', NEW.`id_user`),
  JSON_OBJECT('id_user', NEW.`id_user`),
  CONCAT('CREAR ', 'user_system'),
  CONCAT('INSERT user_system ', CONCAT('id_user=', NEW.`id_user`)),
  NULL,
  JSON_OBJECT('id_ai_user', NEW.`id_ai_user`, 'id_user', NEW.`id_user`, 'user', NEW.`user`, 'username', NEW.`username`, 'password', '***', 'tipo', NEW.`tipo`, 'std_reg', NEW.`std_reg`),
  JSON_OBJECT('id_ai_user', NEW.`id_ai_user`, 'id_user', NEW.`id_user`, 'user', NEW.`user`, 'username', NEW.`username`, 'password', '***', 'tipo', NEW.`tipo`, 'std_reg', NEW.`std_reg`),
  'id_ai_user,id_user,user,username,password,tipo,std_reg',
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)$$
DELIMITER ;

-- Trigger: trg_user_system_au
DROP TRIGGER IF EXISTS `trg_user_system_au`;
DELIMITER $$
CREATE TRIGGER `trg_user_system_au` AFTER UPDATE ON `user_system` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_user` FROM `user_system` WHERE `id_user` = @app_user LIMIT 1),
  'user_system',
  CASE WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN 'SOFT_DELETE' WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN 'RESTORE' ELSE 'UPDATE' END,
  CONCAT('id_user=', NEW.`id_user`),
  JSON_OBJECT('id_user', NEW.`id_user`),
  CASE WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN CONCAT('ELIMINAR (LOGICO) ', 'user_system') WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN CONCAT('REACTIVAR ', 'user_system') ELSE CONCAT('MODIFICAR ', 'user_system') END,
  CASE WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN CONCAT('SOFT_DELETE user_system ', CONCAT('id_user=', NEW.`id_user`)) WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN CONCAT('RESTORE user_system ', CONCAT('id_user=', NEW.`id_user`)) ELSE CONCAT('UPDATE user_system ', CONCAT('id_user=', NEW.`id_user`)) END,
  JSON_OBJECT('id_ai_user', OLD.`id_ai_user`, 'id_user', OLD.`id_user`, 'user', OLD.`user`, 'username', OLD.`username`, 'password', '***', 'tipo', OLD.`tipo`, 'std_reg', OLD.`std_reg`),
  JSON_OBJECT('id_ai_user', NEW.`id_ai_user`, 'id_user', NEW.`id_user`, 'user', NEW.`user`, 'username', NEW.`username`, 'password', '***', 'tipo', NEW.`tipo`, 'std_reg', NEW.`std_reg`),
  JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_OBJECT(), IF(NOT (OLD.`id_ai_user` <=> NEW.`id_ai_user`), JSON_OBJECT('id_ai_user', JSON_ARRAY(OLD.`id_ai_user`, NEW.`id_ai_user`)), JSON_OBJECT())), IF(NOT (OLD.`id_user` <=> NEW.`id_user`), JSON_OBJECT('id_user', JSON_ARRAY(OLD.`id_user`, NEW.`id_user`)), JSON_OBJECT())), IF(NOT (OLD.`user` <=> NEW.`user`), JSON_OBJECT('user', JSON_ARRAY(OLD.`user`, NEW.`user`)), JSON_OBJECT())), IF(NOT (OLD.`username` <=> NEW.`username`), JSON_OBJECT('username', JSON_ARRAY(OLD.`username`, NEW.`username`)), JSON_OBJECT())), IF(NOT (OLD.`password` <=> NEW.`password`), JSON_OBJECT('password', 'CHANGED'), JSON_OBJECT())), IF(NOT (OLD.`tipo` <=> NEW.`tipo`), JSON_OBJECT('tipo', JSON_ARRAY(OLD.`tipo`, NEW.`tipo`)), JSON_OBJECT())), IF(NOT (OLD.`std_reg` <=> NEW.`std_reg`), JSON_OBJECT('std_reg', JSON_ARRAY(OLD.`std_reg`, NEW.`std_reg`)), JSON_OBJECT())),
  NULLIF(CONCAT_WS(',', IF(NOT (OLD.`id_ai_user` <=> NEW.`id_ai_user`), 'id_ai_user', NULL), IF(NOT (OLD.`id_user` <=> NEW.`id_user`), 'id_user', NULL), IF(NOT (OLD.`user` <=> NEW.`user`), 'user', NULL), IF(NOT (OLD.`username` <=> NEW.`username`), 'username', NULL), IF(NOT (OLD.`password` <=> NEW.`password`), 'password', NULL), IF(NOT (OLD.`tipo` <=> NEW.`tipo`), 'tipo', NULL), IF(NOT (OLD.`std_reg` <=> NEW.`std_reg`), 'std_reg', NULL)), ''),
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)$$
DELIMITER ;

-- Trigger: trg_user_system_bd
DROP TRIGGER IF EXISTS `trg_user_system_bd`;
DELIMITER $$
CREATE TRIGGER `trg_user_system_bd` BEFORE DELETE ON `user_system` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE físico en user_system. Use eliminación lógica (UPDATE user_system SET std_reg=0 ...).'$$
DELIMITER ;

SET FOREIGN_KEY_CHECKS=1;
SET UNIQUE_CHECKS=1;

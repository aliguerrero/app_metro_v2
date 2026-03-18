-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 18-03-2026 a las 19:03:20
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `bdapp_metro`
--
CREATE DATABASE IF NOT EXISTS `bdapp_metro` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `bdapp_metro`;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `area_trabajo`
--

CREATE TABLE `area_trabajo` (
  `id_ai_area` int(11) NOT NULL COMMENT 'id autoincrementable',
  `nombre_area` varchar(100) NOT NULL COMMENT 'Nombre del área de trabajo',
  `nomeclatura` varchar(20) NOT NULL COMMENT 'Nomenclatura o prefijo usado para generar códigos de OT',
  `std_reg` tinyint(1) NOT NULL COMMENT 'Estado lógico del registro (1=activo, 0=inactivo/eliminado lógico).'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `area_trabajo`
--

INSERT INTO `area_trabajo` (`id_ai_area`, `nombre_area`, `nomeclatura`, `std_reg`) VALUES
(1, 'SEÑALIZACION', 'VF-SEÑ-', 1),
(2, 'APARATO DE VIA', 'VF-APV-', 1),
(3, 'INFRAESTRUCTURA', 'VF-INF-', 1),
(5, 'NO PROGRAMADA', 'VF-NP-', 1),
(11, 'PRUEBA AREA', 'AREA-', 0),
(12, 'Tecnologia', 'Redes', 0);

--
-- Disparadores `area_trabajo`
--
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
DELIMITER $$
CREATE TRIGGER `trg_area_trabajo_bd` BEFORE DELETE ON `area_trabajo` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE físico en area_trabajo. Use eliminación lógica (UPDATE area_trabajo SET std_reg=0 ...).'
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categoria_empleado`
--

CREATE TABLE `categoria_empleado` (
  `id_ai_categoria_empleado` int(11) NOT NULL COMMENT 'id autoincrementable',
  `nombre_categoria` varchar(100) NOT NULL COMMENT 'Nombre de la categoria del empleado',
  `descripcion` varchar(255) DEFAULT NULL COMMENT 'Descripcion breve de la categoria',
  `std_reg` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Estado logico del registro (1=activo, 0=inactivo).'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `categoria_empleado`
--

INSERT INTO `categoria_empleado` (`id_ai_categoria_empleado`, `nombre_categoria`, `descripcion`, `std_reg`) VALUES
(1, 'SIN CATEGORIA', 'Categoria por defecto para la migracion de usuarios existentes.', 1);

--
-- Disparadores `categoria_empleado`
--
DELIMITER $$
CREATE TRIGGER `trg_categoria_empleado_ai` AFTER INSERT ON `categoria_empleado` FOR EACH ROW INSERT INTO `log_user`(
    `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
    `accion`,`resp_system`,`data_old`,`data_new`,`data_diff`,`changed_cols`,
    `connection_id`,`db_user`,`db_host`
) VALUES (
    UUID(),
    (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
    'categoria_empleado',
    'INSERT',
    CONCAT('id_ai_categoria_empleado=', NEW.`id_ai_categoria_empleado`),
    JSON_OBJECT('id_ai_categoria_empleado', NEW.`id_ai_categoria_empleado`),
    'CREAR categoria_empleado',
    CONCAT('INSERT categoria_empleado ', CONCAT('id_ai_categoria_empleado=', NEW.`id_ai_categoria_empleado`)),
    NULL,
    JSON_OBJECT(
        'id_ai_categoria_empleado', NEW.`id_ai_categoria_empleado`,
        'nombre_categoria', NEW.`nombre_categoria`,
        'descripcion', NEW.`descripcion`,
        'std_reg', NEW.`std_reg`
    ),
    JSON_OBJECT(
        'id_ai_categoria_empleado', NEW.`id_ai_categoria_empleado`,
        'nombre_categoria', NEW.`nombre_categoria`,
        'descripcion', NEW.`descripcion`,
        'std_reg', NEW.`std_reg`
    ),
    'id_ai_categoria_empleado,nombre_categoria,descripcion,std_reg',
    CONNECTION_ID(),
    USER(),
    SUBSTRING_INDEX(USER(),'@',-1)
)
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_categoria_empleado_au` AFTER UPDATE ON `categoria_empleado` FOR EACH ROW INSERT INTO `log_user`(
    `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
    `accion`,`resp_system`,`data_old`,`data_new`,`data_diff`,`changed_cols`,
    `connection_id`,`db_user`,`db_host`
) VALUES (
    UUID(),
    (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
    'categoria_empleado',
    CASE
        WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN 'SOFT_DELETE'
        WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN 'RESTORE'
        ELSE 'UPDATE'
    END,
    CONCAT('id_ai_categoria_empleado=', NEW.`id_ai_categoria_empleado`),
    JSON_OBJECT('id_ai_categoria_empleado', NEW.`id_ai_categoria_empleado`),
    CASE
        WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN 'ELIMINAR (LOGICO) categoria_empleado'
        WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN 'REACTIVAR categoria_empleado'
        ELSE 'MODIFICAR categoria_empleado'
    END,
    CASE
        WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN CONCAT('SOFT_DELETE categoria_empleado ', CONCAT('id_ai_categoria_empleado=', NEW.`id_ai_categoria_empleado`))
        WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN CONCAT('RESTORE categoria_empleado ', CONCAT('id_ai_categoria_empleado=', NEW.`id_ai_categoria_empleado`))
        ELSE CONCAT('UPDATE categoria_empleado ', CONCAT('id_ai_categoria_empleado=', NEW.`id_ai_categoria_empleado`))
    END,
    JSON_OBJECT(
        'id_ai_categoria_empleado', OLD.`id_ai_categoria_empleado`,
        'nombre_categoria', OLD.`nombre_categoria`,
        'descripcion', OLD.`descripcion`,
        'std_reg', OLD.`std_reg`
    ),
    JSON_OBJECT(
        'id_ai_categoria_empleado', NEW.`id_ai_categoria_empleado`,
        'nombre_categoria', NEW.`nombre_categoria`,
        'descripcion', NEW.`descripcion`,
        'std_reg', NEW.`std_reg`
    ),
    JSON_OBJECT(
        'changed_cols', NULLIF(CONCAT_WS(',',
            IF(NOT (OLD.`id_ai_categoria_empleado` <=> NEW.`id_ai_categoria_empleado`), 'id_ai_categoria_empleado', NULL),
            IF(NOT (OLD.`nombre_categoria` <=> NEW.`nombre_categoria`), 'nombre_categoria', NULL),
            IF(NOT (OLD.`descripcion` <=> NEW.`descripcion`), 'descripcion', NULL),
            IF(NOT (OLD.`std_reg` <=> NEW.`std_reg`), 'std_reg', NULL)
        ), '')
    ),
    NULLIF(CONCAT_WS(',',
        IF(NOT (OLD.`id_ai_categoria_empleado` <=> NEW.`id_ai_categoria_empleado`), 'id_ai_categoria_empleado', NULL),
        IF(NOT (OLD.`nombre_categoria` <=> NEW.`nombre_categoria`), 'nombre_categoria', NULL),
        IF(NOT (OLD.`descripcion` <=> NEW.`descripcion`), 'descripcion', NULL),
        IF(NOT (OLD.`std_reg` <=> NEW.`std_reg`), 'std_reg', NULL)
    ), ''),
    CONNECTION_ID(),
    USER(),
    SUBSTRING_INDEX(USER(),'@',-1)
)
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_categoria_empleado_bd` BEFORE DELETE ON `categoria_empleado` FOR EACH ROW SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'No se permite DELETE fisico en categoria_empleado. Use eliminacion logica (UPDATE categoria_empleado SET std_reg=0 ...).'
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categoria_herramienta`
--

CREATE TABLE `categoria_herramienta` (
  `id_ai_categoria_herramienta` int(10) UNSIGNED NOT NULL COMMENT 'Id autoincrementable de la categoria de herramienta',
  `nombre_categoria` varchar(100) NOT NULL COMMENT 'Nombre de la categoria de la herramienta',
  `descripcion` varchar(255) DEFAULT NULL COMMENT 'Descripcion breve de la categoria de herramienta',
  `std_reg` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Estado logico del registro (1=activo, 0=inactivo).'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `categoria_herramienta`
--

INSERT INTO `categoria_herramienta` (`id_ai_categoria_herramienta`, `nombre_categoria`, `descripcion`, `std_reg`) VALUES
(1, 'GENERAL', 'Categoria base para herramientas existentes', 1);

--
-- Disparadores `categoria_herramienta`
--
DELIMITER $$
CREATE TRIGGER `trg_categoria_herramienta_ai` AFTER INSERT ON `categoria_herramienta` FOR EACH ROW INSERT INTO `log_user`(
    `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
    `accion`,`resp_system`,`data_old`,`data_new`,`data_diff`,`changed_cols`,
    `connection_id`,`db_user`,`db_host`
) VALUES (
    UUID(),
    (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
    'categoria_herramienta',
    'INSERT',
    CONCAT('id_ai_categoria_herramienta=', NEW.`id_ai_categoria_herramienta`),
    JSON_OBJECT('id_ai_categoria_herramienta', NEW.`id_ai_categoria_herramienta`),
    'CREAR categoria_herramienta',
    CONCAT('INSERT categoria_herramienta ', CONCAT('id_ai_categoria_herramienta=', NEW.`id_ai_categoria_herramienta`)),
    NULL,
    JSON_OBJECT(
        'id_ai_categoria_herramienta', NEW.`id_ai_categoria_herramienta`,
        'nombre_categoria', NEW.`nombre_categoria`,
        'descripcion', NEW.`descripcion`,
        'std_reg', NEW.`std_reg`
    ),
    JSON_OBJECT(
        'id_ai_categoria_herramienta', NEW.`id_ai_categoria_herramienta`,
        'nombre_categoria', NEW.`nombre_categoria`,
        'descripcion', NEW.`descripcion`,
        'std_reg', NEW.`std_reg`
    ),
    'id_ai_categoria_herramienta,nombre_categoria,descripcion,std_reg',
    CONNECTION_ID(),
    USER(),
    SUBSTRING_INDEX(USER(),'@',-1)
)
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_categoria_herramienta_au` AFTER UPDATE ON `categoria_herramienta` FOR EACH ROW INSERT INTO `log_user`(
    `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
    `accion`,`resp_system`,`data_old`,`data_new`,`data_diff`,`changed_cols`,
    `connection_id`,`db_user`,`db_host`
) VALUES (
    UUID(),
    (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
    'categoria_herramienta',
    CASE
        WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN 'SOFT_DELETE'
        WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN 'RESTORE'
        ELSE 'UPDATE'
    END,
    CONCAT('id_ai_categoria_herramienta=', NEW.`id_ai_categoria_herramienta`),
    JSON_OBJECT('id_ai_categoria_herramienta', NEW.`id_ai_categoria_herramienta`),
    CASE
        WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN 'ELIMINAR (LOGICO) categoria_herramienta'
        WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN 'REACTIVAR categoria_herramienta'
        ELSE 'MODIFICAR categoria_herramienta'
    END,
    CASE
        WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN CONCAT('SOFT_DELETE categoria_herramienta ', CONCAT('id_ai_categoria_herramienta=', NEW.`id_ai_categoria_herramienta`))
        WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN CONCAT('RESTORE categoria_herramienta ', CONCAT('id_ai_categoria_herramienta=', NEW.`id_ai_categoria_herramienta`))
        ELSE CONCAT('UPDATE categoria_herramienta ', CONCAT('id_ai_categoria_herramienta=', NEW.`id_ai_categoria_herramienta`))
    END,
    JSON_OBJECT(
        'id_ai_categoria_herramienta', OLD.`id_ai_categoria_herramienta`,
        'nombre_categoria', OLD.`nombre_categoria`,
        'descripcion', OLD.`descripcion`,
        'std_reg', OLD.`std_reg`
    ),
    JSON_OBJECT(
        'id_ai_categoria_herramienta', NEW.`id_ai_categoria_herramienta`,
        'nombre_categoria', NEW.`nombre_categoria`,
        'descripcion', NEW.`descripcion`,
        'std_reg', NEW.`std_reg`
    ),
    JSON_OBJECT(
        'changed_cols', NULLIF(CONCAT_WS(',',
            IF(NOT (OLD.`id_ai_categoria_herramienta` <=> NEW.`id_ai_categoria_herramienta`), 'id_ai_categoria_herramienta', NULL),
            IF(NOT (OLD.`nombre_categoria` <=> NEW.`nombre_categoria`), 'nombre_categoria', NULL),
            IF(NOT (OLD.`descripcion` <=> NEW.`descripcion`), 'descripcion', NULL),
            IF(NOT (OLD.`std_reg` <=> NEW.`std_reg`), 'std_reg', NULL)
        ), '')
    ),
    NULLIF(CONCAT_WS(',',
        IF(NOT (OLD.`id_ai_categoria_herramienta` <=> NEW.`id_ai_categoria_herramienta`), 'id_ai_categoria_herramienta', NULL),
        IF(NOT (OLD.`nombre_categoria` <=> NEW.`nombre_categoria`), 'nombre_categoria', NULL),
        IF(NOT (OLD.`descripcion` <=> NEW.`descripcion`), 'descripcion', NULL),
        IF(NOT (OLD.`std_reg` <=> NEW.`std_reg`), 'std_reg', NULL)
    ), ''),
    CONNECTION_ID(),
    USER(),
    SUBSTRING_INDEX(USER(),'@',-1)
)
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_categoria_herramienta_bd` BEFORE DELETE ON `categoria_herramienta` FOR EACH ROW SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'No se permite DELETE fisico en categoria_herramienta. Use eliminacion logica (UPDATE categoria_herramienta SET std_reg=0 ...).'
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalle_orden`
--

CREATE TABLE `detalle_orden` (
  `id_ai_detalle` int(11) NOT NULL COMMENT 'id autoincrementable',
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
  `observacion` varchar(250) DEFAULT NULL COMMENT 'Observaciones adicionales sobre la actividad'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `detalle_orden`
--

INSERT INTO `detalle_orden` (`id_ai_detalle`, `n_ot`, `fecha`, `descripcion`, `id_ai_turno`, `id_miembro_cco`, `id_user_act`, `id_miembro_ccf`, `id_ai_estado`, `cant_tec`, `hora_ini_pre`, `hora_fin_pre`, `hora_ini_tra`, `hora_fin_tra`, `hora_ini_eje`, `hora_fin_eje`, `observacion`) VALUES
(2, 'VF-SEÑ-02', '2026-02-11', 'DETALLE PRUEBA VF-SEÑ-02: actividad programada (2026-02-11)', 1, 'M-006', '000000', 'M-007', 1, 2, '07:00', '07:30', '07:30', '08:00', '08:00', '09:30', NULL),
(3, 'VF-SEÑ-03', '2026-02-12', 'DETALLE PRUEBA VF-SEÑ-03: actividad programada (2026-02-12)', 2, 'M-007', '12345678', 'M-008', 3, 3, '07:00', '07:30', '07:30', '08:00', '08:00', '10:00', 'PRUEBA - generar datos'),
(4, 'VF-SEÑ-04', '2026-02-13', 'DETALLE PRUEBA VF-SEÑ-04: actividad programada (2026-02-13)', 3, 'M-008', '000000', 'M-009', 2, 4, '07:00', '07:30', '07:30', '08:00', '08:00', '10:30', 'PRUEBA - generar datos'),
(5, 'VF-SEÑ-05', '2026-02-14', 'DETALLE PRUEBA VF-SEÑ-05: actividad programada (2026-02-14)', 4, 'M-009', '12345678', 'M-010', 4, 5, '07:00', '07:30', '07:30', '08:00', '08:00', '11:00', NULL),
(6, 'VF-SEÑ-06', '2026-02-15', 'DETALLE PRUEBA VF-SEÑ-06: actividad programada (2026-02-15)', 1, 'M-010', '000000', 'M-011', 1, 2, '07:00', '07:30', '07:30', '08:00', '08:00', '09:30', 'PRUEBA - generar datos'),
(8, 'VF-APV-02', '2026-02-17', 'DETALLE PRUEBA VF-APV-02: actividad programada (2026-02-17)', 3, 'M-012', '000000', 'M-013', 2, 4, '07:00', '07:30', '07:30', '08:00', '08:00', '10:30', NULL),
(9, 'VF-APV-03', '2026-02-18', 'DETALLE PRUEBA VF-APV-03: actividad programada (2026-02-18)', 4, 'M-013', '12345678', 'M-014', 4, 5, '07:00', '07:30', '07:30', '08:00', '08:00', '11:00', 'PRUEBA - generar datos'),
(10, 'VF-APV-04', '2026-02-19', 'DETALLE PRUEBA VF-APV-04: actividad programada (2026-02-19)', 1, 'M-014', '000000', 'M-015', 1, 2, '07:00', '07:30', '07:30', '08:00', '08:00', '09:30', 'PRUEBA - generar datos'),
(11, 'VF-APV-05', '2026-02-20', 'DETALLE PRUEBA VF-APV-05: actividad programada (2026-02-20)', 2, 'M-015', '12345678', 'M-016', 3, 3, '07:00', '07:30', '07:30', '08:00', '08:00', '10:00', NULL),
(12, 'VF-INF-01', '2026-02-21', 'DETALLE PRUEBA VF-INF-01: actividad programada (2026-02-21)', 3, 'M-016', '000000', 'M-017', 2, 4, '07:00', '07:30', '07:30', '08:00', '08:00', '10:30', 'PRUEBA - generar datos'),
(13, 'VF-INF-02', '2026-02-22', 'DETALLE PRUEBA VF-INF-02: actividad programada (2026-02-22)', 4, 'M-017', '12345678', 'M-018', 4, 5, '07:00', '07:30', '07:30', '08:00', '08:00', '11:00', 'PRUEBA - generar datos'),
(14, 'VF-INF-03', '2026-02-23', 'DETALLE PRUEBA VF-INF-03: actividad programada (2026-02-23)', 1, 'M-018', '000000', 'M-019', 1, 2, '07:00', '07:30', '07:30', '08:00', '08:00', '09:30', NULL),
(15, 'VF-INF-04', '2026-02-24', 'DETALLE PRUEBA VF-INF-04: actividad programada (2026-02-24)', 2, 'M-019', '12345678', 'M-020', 3, 3, '07:00', '07:30', '07:30', '08:00', '08:00', '10:00', 'PRUEBA - generar datos'),
(16, 'VF-INF-05', '2026-02-25', 'DETALLE PRUEBA VF-INF-05: actividad programada (2026-02-25)', 3, 'M-020', '000000', 'M-021', 2, 4, '07:00', '07:30', '07:30', '08:00', '08:00', '10:30', 'PRUEBA - generar datos'),
(17, 'VF-NP-01', '2026-02-26', 'DETALLE PRUEBA VF-NP-01: actividad programada (2026-02-26)', 4, 'M-021', '12345678', 'M-022', 4, 5, '07:00', '07:30', '07:30', '08:00', '08:00', '11:00', NULL),
(18, 'VF-NP-02', '2026-02-27', 'DETALLE PRUEBA VF-NP-02: actividad programada (2026-02-27)', 1, 'M-022', '000000', 'M-023', 1, 2, '07:00', '07:30', '07:30', '08:00', '08:00', '09:30', 'PRUEBA - generar datos'),
(19, 'VF-NP-03', '2026-02-28', 'DETALLE PRUEBA VF-NP-03: actividad programada (2026-02-28)', 2, 'M-023', '12345678', 'M-024', 3, 3, '07:00', '07:30', '07:30', '08:00', '08:00', '10:00', 'PRUEBA - generar datos'),
(20, 'VF-NP-04', '2026-03-01', 'DETALLE PRUEBA VF-NP-04: actividad programada (2026-03-01)', 3, 'M-024', '000000', 'M-025', 2, 4, '07:00', '07:30', '07:30', '08:00', '08:00', '10:30', NULL),
(21, 'VF-NP-05', '2026-03-02', 'DETALLE PRUEBA VF-NP-05: actividad programada (2026-03-02)', 4, 'M-025', '12345678', 'M-006', 4, 5, '07:00', '07:30', '07:30', '08:00', '08:00', '11:00', 'PRUEBA - generar datos'),
(29, 'VF-APV-01', '2026-02-16', 'DETALLE PRUEBA VF-APV-01', 2, 'M-001', '12345678', 'M-012', 12, 4, '07:00', '07:30', '07:30', '08:00', '08:00', '10:00', 'PRUEBA'),
(32, 'VF-SEÑ-08', '2026-02-13', 'mantenimiento general', 1, 'M-001', '26580187', 'M-005', 1, 5, '01:00', '01:00', '01:00', '01:00', '01:00', '01:00', NULL),
(33, 'VF-SEÑ-09', '2026-02-12', 'mantenimineto', 1, 'M-001', '26580187', 'M-005', 1, 4, '09:00', '12:00', '10:00', '01:00', '11:00', '03:11', NULL);

--
-- Disparadores `detalle_orden`
--
DELIMITER $$
CREATE TRIGGER `trg_detalle_orden_ad` AFTER DELETE ON `detalle_orden` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
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
)
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_detalle_orden_ai` AFTER INSERT ON `detalle_orden` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
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
)
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_detalle_orden_au` AFTER UPDATE ON `detalle_orden` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
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
)
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `empleado`
--

CREATE TABLE `empleado` (
  `id_ai_empleado` int(11) NOT NULL COMMENT 'id autoincrementable',
  `id_empleado` varchar(30) NOT NULL COMMENT 'Identificador unico del empleado',
  `nacionalidad` char(1) NOT NULL DEFAULT 'V' COMMENT 'Identifica si la cedula es venezolana (V) o extranjera (E).',
  `nombre_empleado` varchar(100) NOT NULL COMMENT 'Nombre completo del empleado',
  `telefono` varchar(20) DEFAULT NULL COMMENT 'Telefono principal del empleado.',
  `direccion` varchar(255) DEFAULT NULL COMMENT 'Direccion de residencia o ubicacion del empleado.',
  `correo` varchar(120) DEFAULT NULL COMMENT 'Correo electronico del empleado.',
  `id_ai_categoria_empleado` int(11) NOT NULL COMMENT 'Categoria asociada al empleado',
  `std_reg` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Estado logico del registro (1=activo, 0=inactivo).'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `empleado`
--

INSERT INTO `empleado` (`id_ai_empleado`, `id_empleado`, `nacionalidad`, `nombre_empleado`, `telefono`, `direccion`, `correo`, `id_ai_categoria_empleado`, `std_reg`) VALUES
(1, '12345678', 'V', 'ALI GUERRERO', '0615-8251111', 'DGDDGGDGD', 'aliguerrero102@gmail.com', 1, 1),
(2, '000000', 'V', 'USUARIO SISTEMA', NULL, NULL, NULL, 1, 1),
(3, '26580187', 'V', 'Walter Ramone', NULL, NULL, NULL, 1, 1);

--
-- Disparadores `empleado`
--
DELIMITER $$
CREATE TRIGGER `trg_empleado_ai` AFTER INSERT ON `empleado` FOR EACH ROW INSERT INTO `log_user`(
    `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
    `accion`,`resp_system`,`data_old`,`data_new`,`data_diff`,`changed_cols`,
    `connection_id`,`db_user`,`db_host`
) VALUES (
    UUID(),
    (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
    'empleado',
    'INSERT',
    CONCAT('id_ai_empleado=', NEW.`id_ai_empleado`),
    JSON_OBJECT('id_ai_empleado', NEW.`id_ai_empleado`),
    'CREAR empleado',
    CONCAT('INSERT empleado ', CONCAT('id_ai_empleado=', NEW.`id_ai_empleado`)),
    NULL,
    JSON_OBJECT(
        'id_ai_empleado', NEW.`id_ai_empleado`,
        'id_empleado', NEW.`id_empleado`,
        'nacionalidad', NEW.`nacionalidad`,
        'nombre_empleado', NEW.`nombre_empleado`,
        'telefono', NEW.`telefono`,
        'direccion', NEW.`direccion`,
        'correo', NEW.`correo`,
        'id_ai_categoria_empleado', NEW.`id_ai_categoria_empleado`,
        'std_reg', NEW.`std_reg`
    ),
    JSON_OBJECT(
        'id_ai_empleado', NEW.`id_ai_empleado`,
        'id_empleado', NEW.`id_empleado`,
        'nacionalidad', NEW.`nacionalidad`,
        'nombre_empleado', NEW.`nombre_empleado`,
        'telefono', NEW.`telefono`,
        'direccion', NEW.`direccion`,
        'correo', NEW.`correo`,
        'id_ai_categoria_empleado', NEW.`id_ai_categoria_empleado`,
        'std_reg', NEW.`std_reg`
    ),
    'id_ai_empleado,id_empleado,nacionalidad,nombre_empleado,telefono,direccion,correo,id_ai_categoria_empleado,std_reg',
    CONNECTION_ID(),
    USER(),
    SUBSTRING_INDEX(USER(),'@',-1)
)
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_empleado_au` AFTER UPDATE ON `empleado` FOR EACH ROW INSERT INTO `log_user`(
    `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
    `accion`,`resp_system`,`data_old`,`data_new`,`data_diff`,`changed_cols`,
    `connection_id`,`db_user`,`db_host`
) VALUES (
    UUID(),
    (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
    'empleado',
    CASE
        WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN 'SOFT_DELETE'
        WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN 'RESTORE'
        ELSE 'UPDATE'
    END,
    CONCAT('id_ai_empleado=', NEW.`id_ai_empleado`),
    JSON_OBJECT('id_ai_empleado', NEW.`id_ai_empleado`),
    CASE
        WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN 'ELIMINAR (LOGICO) empleado'
        WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN 'REACTIVAR empleado'
        ELSE 'MODIFICAR empleado'
    END,
    CASE
        WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN CONCAT('SOFT_DELETE empleado ', CONCAT('id_ai_empleado=', NEW.`id_ai_empleado`))
        WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN CONCAT('RESTORE empleado ', CONCAT('id_ai_empleado=', NEW.`id_ai_empleado`))
        ELSE CONCAT('UPDATE empleado ', CONCAT('id_ai_empleado=', NEW.`id_ai_empleado`))
    END,
    JSON_OBJECT(
        'id_ai_empleado', OLD.`id_ai_empleado`,
        'id_empleado', OLD.`id_empleado`,
        'nacionalidad', OLD.`nacionalidad`,
        'nombre_empleado', OLD.`nombre_empleado`,
        'telefono', OLD.`telefono`,
        'direccion', OLD.`direccion`,
        'correo', OLD.`correo`,
        'id_ai_categoria_empleado', OLD.`id_ai_categoria_empleado`,
        'std_reg', OLD.`std_reg`
    ),
    JSON_OBJECT(
        'id_ai_empleado', NEW.`id_ai_empleado`,
        'id_empleado', NEW.`id_empleado`,
        'nacionalidad', NEW.`nacionalidad`,
        'nombre_empleado', NEW.`nombre_empleado`,
        'telefono', NEW.`telefono`,
        'direccion', NEW.`direccion`,
        'correo', NEW.`correo`,
        'id_ai_categoria_empleado', NEW.`id_ai_categoria_empleado`,
        'std_reg', NEW.`std_reg`
    ),
    JSON_OBJECT(
        'changed_cols', NULLIF(CONCAT_WS(',',
            IF(NOT (OLD.`id_ai_empleado` <=> NEW.`id_ai_empleado`), 'id_ai_empleado', NULL),
            IF(NOT (OLD.`id_empleado` <=> NEW.`id_empleado`), 'id_empleado', NULL),
            IF(NOT (OLD.`nacionalidad` <=> NEW.`nacionalidad`), 'nacionalidad', NULL),
            IF(NOT (OLD.`nombre_empleado` <=> NEW.`nombre_empleado`), 'nombre_empleado', NULL),
            IF(NOT (OLD.`telefono` <=> NEW.`telefono`), 'telefono', NULL),
            IF(NOT (OLD.`direccion` <=> NEW.`direccion`), 'direccion', NULL),
            IF(NOT (OLD.`correo` <=> NEW.`correo`), 'correo', NULL),
            IF(NOT (OLD.`id_ai_categoria_empleado` <=> NEW.`id_ai_categoria_empleado`), 'id_ai_categoria_empleado', NULL),
            IF(NOT (OLD.`std_reg` <=> NEW.`std_reg`), 'std_reg', NULL)
        ), '')
    ),
    NULLIF(CONCAT_WS(',',
        IF(NOT (OLD.`id_ai_empleado` <=> NEW.`id_ai_empleado`), 'id_ai_empleado', NULL),
        IF(NOT (OLD.`id_empleado` <=> NEW.`id_empleado`), 'id_empleado', NULL),
        IF(NOT (OLD.`nacionalidad` <=> NEW.`nacionalidad`), 'nacionalidad', NULL),
        IF(NOT (OLD.`nombre_empleado` <=> NEW.`nombre_empleado`), 'nombre_empleado', NULL),
        IF(NOT (OLD.`telefono` <=> NEW.`telefono`), 'telefono', NULL),
        IF(NOT (OLD.`direccion` <=> NEW.`direccion`), 'direccion', NULL),
        IF(NOT (OLD.`correo` <=> NEW.`correo`), 'correo', NULL),
        IF(NOT (OLD.`id_ai_categoria_empleado` <=> NEW.`id_ai_categoria_empleado`), 'id_ai_categoria_empleado', NULL),
        IF(NOT (OLD.`std_reg` <=> NEW.`std_reg`), 'std_reg', NULL)
    ), ''),
    CONNECTION_ID(),
    USER(),
    SUBSTRING_INDEX(USER(),'@',-1)
)
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_empleado_bd` BEFORE DELETE ON `empleado` FOR EACH ROW SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'No se permite DELETE fisico en empleado. Use eliminacion logica (UPDATE empleado SET std_reg=0 ...).'
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `empresa_config`
--

CREATE TABLE `empresa_config` (
  `id` int(11) NOT NULL COMMENT 'PK. Identificador único de la configuración de empresa (normalmente 1 registro).',
  `nombre` varchar(150) NOT NULL COMMENT 'Nombre legal o comercial de la empresa.',
  `rif` varchar(30) DEFAULT NULL COMMENT 'RIF / Identificador fiscal de la empresa.',
  `direccion` varchar(255) DEFAULT NULL COMMENT 'Dirección física o fiscal de la empresa.',
  `telefono` varchar(50) DEFAULT NULL COMMENT 'Teléfono principal de contacto.',
  `email` varchar(120) DEFAULT NULL COMMENT 'Correo principal de contacto.',
  `logo` varchar(255) DEFAULT NULL COMMENT 'Ruta relativa del logo. Ej: app/views/icons/metro.png',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'Fecha/hora de creación del registro.',
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Fecha/hora de última actualización del registro.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `empresa_config`
--

INSERT INTO `empresa_config` (`id`, `nombre`, `rif`, `direccion`, `telefono`, `email`, `logo`, `created_at`, `updated_at`) VALUES
(1, 'C.A. Metro Valencia', 'G-0000000-1', 'Av. Sesquicentenaria, local Parque Recreacional Sur, parte Sur Oeste N° S/N, zona Valencia Sur. Estado Carabobo.', '0241-0000000', 'metrodevalencia@correo.com', 'app/views/img/empresa/logo_empresa.jpg', '2026-01-07 20:59:31', '2026-02-11 23:26:46');

--
-- Disparadores `empresa_config`
--
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

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `estado_ot`
--

CREATE TABLE `estado_ot` (
  `id_ai_estado` int(11) NOT NULL COMMENT 'id autoincrementable',
  `nombre_estado` varchar(100) NOT NULL COMMENT 'Nombre descriptivo del estado de la orden de trabajo',
  `color` varchar(15) NOT NULL COMMENT 'Código de color asociado al estado para representación visual',
  `std_reg` tinyint(1) NOT NULL COMMENT 'Estado lógico del registro (1=activo, 0=inactivo/eliminado lógico).'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `estado_ot`
--

INSERT INTO `estado_ot` (`id_ai_estado`, `nombre_estado`, `color`, `std_reg`) VALUES
(1, 'EJECUTADA', '#25ef28', 1),
(2, 'NO EJECUTADA', '#fa0025', 1),
(3, 'RE-PROGRAMADA', '#001eff', 1),
(4, 'SUSPENDIDA', '#ffae00', 1),
(12, 'CORRECTIVA', '#ff00bb', 1),
(19, 'PRUEBA', '#e1ff00', 0),
(20, 'bfbfbfbf', '#00ffcc', 0),
(21, 'PRUEBA 2', '#e1c537', 0),
(22, 'DVDDV', '#00ffcc', 0),
(23, 'PENDIENTE1', '#ff00bb', 0);

--
-- Disparadores `estado_ot`
--
DELIMITER $$
CREATE TRIGGER `trg_estado_ot_ai` AFTER INSERT ON `estado_ot` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
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
)
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_estado_ot_au` AFTER UPDATE ON `estado_ot` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
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
)
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_estado_ot_bd` BEFORE DELETE ON `estado_ot` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE físico en estado_ot. Use eliminación lógica (UPDATE estado_ot SET std_reg=0 ...).'
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `herramienta`
--

CREATE TABLE `herramienta` (
  `id_ai_herramienta` int(11) NOT NULL COMMENT 'id autoincrementable',
  `nombre_herramienta` varchar(250) NOT NULL COMMENT 'Nombre descriptivo de la herramienta',
  `id_ai_categoria_herramienta` int(10) UNSIGNED NOT NULL COMMENT 'Categoria asociada a la herramienta',
  `cantidad` int(11) NOT NULL COMMENT 'Cantidad total de unidades disponibles de la herramienta',
  `estado` varchar(5) NOT NULL COMMENT 'Descripción del estado general de la herramienta',
  `std_reg` tinyint(1) NOT NULL COMMENT 'Estado lógico del registro (1=activo, 0=inactivo/eliminado lógico).'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `herramienta`
--

INSERT INTO `herramienta` (`id_ai_herramienta`, `nombre_herramienta`, `id_ai_categoria_herramienta`, `cantidad`, `estado`, `std_reg`) VALUES
(0, 'cemento', 1, 9, '1', 0),
(1, 'Martillo electricos', 1, 11, '1', 1),
(3, 'PRUEBA', 1, 2, '3', 0),
(4, 'tubo', 1, 1, '2', 0),
(5, 'tubo de 1/2 6m // 56', 1, 1, '1', 0),
(6, 'eduardo carmona', 1, 1, '3', 0),
(7, 'ADMINISTRADOR SISTEMA', 1, 4, '1', 0),
(8, 'cemento', 1, 2, '1', 0),
(9, 'ADMINISTRADOR SISTEMA 66', 1, 5, '1', 0),
(10, 'ADMINISTRADOR SISTEMA', 1, 4, '1', 0),
(11, 'Taladro percutor', 1, 4, '3', 1),
(12, 'Llave inglesa', 1, 7, '1', 1),
(13, 'Juego de destornilladores', 1, 10, '2', 1),
(14, 'Pinza de presión', 1, 3, '3', 1),
(15, 'Sierra manual', 1, 6, '1', 0),
(16, 'Amoladora', 1, 9, '2', 0),
(17, 'Cinta mtrica m5', 1, 2, '3', 1),
(18, 'Nivel de burbuja', 1, 5, '1', 1),
(19, 'Escalera aluminio', 1, 8, '2', 1),
(20, 'Multímetro digital', 1, 1, '3', 1),
(21, 'Soldadora inverter', 1, 4, '1', 1),
(22, 'Careta de soldar', 1, 7, '2', 1),
(23, 'Guantes dieléctricos', 1, 10, '3', 1),
(24, 'Casco de seguridad', 1, 3, '1', 1),
(25, 'Arnés de seguridad', 1, 6, '2', 1),
(26, 'Linterna recargable', 1, 9, '3', 1),
(27, 'Generador portátil', 1, 2, '1', 1),
(28, 'Compresor de aire', 1, 5, '2', 1),
(29, 'Gato hidráulico', 1, 8, '3', 1),
(30, 'Cizalla para cables', 1, 1, '1', 1),
(31, 'limpia contacto', 1, 10, '1', 1),
(32, 'Martillo electricos', 1, 2, '1', 1),
(33, 'Martillo electricos', 1, 12, '1', 1),
(34, 'Martillo electricos', 1, 111, '1', 1),
(35, 'Martillo electricos', 1, 4, '1', 1),
(36, 'Martillo electricos', 1, 52, '1', 1),
(37, 'cables', 1, 100, '1', 1),
(38, 'herramienta xxx', 1, 5, '1', 1),
(39, 'xxxx', 1, 10, '1', 1);

--
-- Disparadores `herramienta`
--
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
DELIMITER $$
CREATE TRIGGER `trg_herramienta_bd` BEFORE DELETE ON `herramienta` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE físico en herramienta. Use eliminación lógica (UPDATE herramienta SET std_reg=0 ...).'
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `herramientaot`
--

CREATE TABLE `herramientaot` (
  `id_ai_herramientaOT` int(11) NOT NULL COMMENT 'id autoincrementable',
  `id_ai_herramienta` int(11) NOT NULL COMMENT 'Código de la herramienta asignada a la orden de trabajo',
  `n_ot` varchar(30) NOT NULL COMMENT 'Número único de la orden de trabajo',
  `cantidadot` int(11) NOT NULL COMMENT 'Cantidad de unidades de la herramienta asignadas a la OT',
  `estadoot` varchar(60) DEFAULT NULL COMMENT 'Estado o condición de la herramienta dentro de la OT'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `herramientaot`
--

INSERT INTO `herramientaot` (`id_ai_herramientaOT`, `id_ai_herramienta`, `n_ot`, `cantidadot`, `estadoot`) VALUES
(3, 11, 'VF-SEÑ-02', 1, 'OK'),
(4, 12, 'VF-SEÑ-03', 2, 'REGULAR'),
(5, 13, 'VF-SEÑ-04', 3, 'EN REPARACION'),
(6, 14, 'VF-SEÑ-05', 1, 'OK'),
(7, 15, 'VF-SEÑ-06', 2, 'REGULAR'),
(9, 17, 'VF-APV-02', 1, 'OK'),
(10, 18, 'VF-APV-03', 2, 'REGULAR'),
(11, 19, 'VF-APV-04', 3, 'EN REPARACION'),
(12, 20, 'VF-APV-05', 1, 'OK'),
(13, 21, 'VF-INF-01', 2, 'REGULAR'),
(14, 22, 'VF-INF-02', 3, 'EN REPARACION'),
(15, 23, 'VF-INF-03', 1, 'OK'),
(16, 24, 'VF-INF-04', 2, 'REGULAR'),
(17, 25, 'VF-INF-05', 3, 'EN REPARACION'),
(18, 26, 'VF-NP-01', 1, 'OK'),
(19, 27, 'VF-NP-02', 2, 'REGULAR'),
(20, 28, 'VF-NP-03', 3, 'EN REPARACION'),
(21, 29, 'VF-NP-04', 1, 'OK'),
(22, 30, 'VF-NP-05', 2, 'REGULAR'),
(23, 1, 'VF-APV-01', 1, NULL),
(26, 11, 'VF-APV-01', 1, NULL),
(28, 11, 'VF-SEÑ-07', 1, NULL),
(29, 12, 'VF-SEÑ-07', 1, NULL),
(30, 31, 'VF-SEÑ-08', 1, NULL);

--
-- Disparadores `herramientaot`
--
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
  JSON_OBJECT('id_ai_herramientaOT', OLD.`id_ai_herramientaOT`, 'id_ai_herramienta', OLD.`id_ai_herramienta`, 'n_ot', OLD.`n_ot`, 'cantidadot', OLD.`cantidadot`, 'estadoot', OLD.`estadoot`),
  NULL,
  NULL,
  NULL,
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)
$$
DELIMITER ;
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
  JSON_OBJECT('id_ai_herramientaOT', NEW.`id_ai_herramientaOT`, 'id_ai_herramienta', NEW.`id_ai_herramienta`, 'n_ot', NEW.`n_ot`, 'cantidadot', NEW.`cantidadot`, 'estadoot', NEW.`estadoot`),
  JSON_OBJECT('id_ai_herramientaOT', NEW.`id_ai_herramientaOT`, 'id_ai_herramienta', NEW.`id_ai_herramienta`, 'n_ot', NEW.`n_ot`, 'cantidadot', NEW.`cantidadot`, 'estadoot', NEW.`estadoot`),
  'id_ai_herramientaOT,id_ai_herramienta,n_ot,cantidadot,estadoot',
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)
$$
DELIMITER ;
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
  JSON_OBJECT('id_ai_herramientaOT', OLD.`id_ai_herramientaOT`, 'id_ai_herramienta', OLD.`id_ai_herramienta`, 'n_ot', OLD.`n_ot`, 'cantidadot', OLD.`cantidadot`, 'estadoot', OLD.`estadoot`),
  JSON_OBJECT('id_ai_herramientaOT', NEW.`id_ai_herramientaOT`, 'id_ai_herramienta', NEW.`id_ai_herramienta`, 'n_ot', NEW.`n_ot`, 'cantidadot', NEW.`cantidadot`, 'estadoot', NEW.`estadoot`),
  JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_OBJECT(), IF(NOT (OLD.`id_ai_herramientaOT` <=> NEW.`id_ai_herramientaOT`), JSON_OBJECT('id_ai_herramientaOT', JSON_ARRAY(OLD.`id_ai_herramientaOT`, NEW.`id_ai_herramientaOT`)), JSON_OBJECT())), IF(NOT (OLD.`id_ai_herramienta` <=> NEW.`id_ai_herramienta`), JSON_OBJECT('id_ai_herramienta', JSON_ARRAY(OLD.`id_ai_herramienta`, NEW.`id_ai_herramienta`)), JSON_OBJECT())), IF(NOT (OLD.`n_ot` <=> NEW.`n_ot`), JSON_OBJECT('n_ot', JSON_ARRAY(OLD.`n_ot`, NEW.`n_ot`)), JSON_OBJECT())), IF(NOT (OLD.`cantidadot` <=> NEW.`cantidadot`), JSON_OBJECT('cantidadot', JSON_ARRAY(OLD.`cantidadot`, NEW.`cantidadot`)), JSON_OBJECT())), IF(NOT (OLD.`estadoot` <=> NEW.`estadoot`), JSON_OBJECT('estadoot', JSON_ARRAY(OLD.`estadoot`, NEW.`estadoot`)), JSON_OBJECT())),
  NULLIF(CONCAT_WS(',', IF(NOT (OLD.`id_ai_herramientaOT` <=> NEW.`id_ai_herramientaOT`), 'id_ai_herramientaOT', NULL), IF(NOT (OLD.`id_ai_herramienta` <=> NEW.`id_ai_herramienta`), 'id_ai_herramienta', NULL), IF(NOT (OLD.`n_ot` <=> NEW.`n_ot`), 'n_ot', NULL), IF(NOT (OLD.`cantidadot` <=> NEW.`cantidadot`), 'cantidadot', NULL), IF(NOT (OLD.`estadoot` <=> NEW.`estadoot`), 'estadoot', NULL)), ''),
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `log_user`
--

CREATE TABLE `log_user` (
  `id_log` bigint(20) UNSIGNED NOT NULL COMMENT 'id autoincrementable',
  `event_uuid` char(36) NOT NULL COMMENT 'Identificador unico del evento de auditoria.',
  `id_user` varchar(30) DEFAULT NULL COMMENT 'Identificador de user (FK o referencia).',
  `tabla` varchar(64) NOT NULL COMMENT 'Tabla origen del evento.',
  `operacion` enum('INSERT','UPDATE','DELETE','SOFT_DELETE','RESTORE','UNKNOWN') NOT NULL COMMENT 'Tipo de operación registrada.',
  `pk_registro` varchar(255) DEFAULT NULL COMMENT 'Clave primaria (o identificador) del registro afectado.',
  `pk_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Identificador/PK en formato JSON.' CHECK (json_valid(`pk_json`)),
  `accion` varchar(150) NOT NULL COMMENT 'Accion funcional mostrada al usuario o al sistema.',
  `resp_system` text NOT NULL COMMENT 'Detalle técnico de la operación registrada.',
  `data_old` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Snapshot anterior (UPDATE/DELETE).' CHECK (json_valid(`data_old`)),
  `data_new` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Snapshot posterior (INSERT/UPDATE).' CHECK (json_valid(`data_new`)),
  `data_diff` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Solo campos modificados con [old,new].' CHECK (json_valid(`data_diff`)),
  `fecha_hora` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'Fecha asociada a fecha hora.',
  `connection_id` bigint(20) UNSIGNED DEFAULT NULL COMMENT 'CONNECTION_ID() de la sesión.',
  `db_user` varchar(128) NOT NULL COMMENT 'Usuario de base de datos que ejecutó la operación.',
  `db_host` varchar(128) DEFAULT NULL COMMENT 'Host extraído de USER().',
  `changed_cols` varchar(1024) DEFAULT NULL COMMENT 'Lista CSV de columnas modificadas.',
  `std_reg` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Estado logico del registro'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `log_user`
--

INSERT INTO `log_user` (`id_log`, `event_uuid`, `id_user`, `tabla`, `operacion`, `pk_registro`, `pk_json`, `accion`, `resp_system`, `data_old`, `data_new`, `data_diff`, `fecha_hora`, `connection_id`, `db_user`, `db_host`, `changed_cols`, `std_reg`) VALUES
(1, 'ae1320ea-1402-11f1-9511-989096ab40dc', '000000', 'herramienta', 'INSERT', 'id_ai_herramienta=38', '{\"id_ai_herramienta\": 38}', 'CREAR herramienta', 'INSERT herramienta id_ai_herramienta=38', NULL, '{\"id_ai_herramienta\": 38, \"nombre_herramienta\": \"herramienta xxx\", \"cantidad\": 5, \"estado\": \"1\", \"std_reg\": 1}', '{\"id_ai_herramienta\": 38, \"nombre_herramienta\": \"herramienta xxx\", \"cantidad\": 5, \"estado\": \"1\", \"std_reg\": 1}', '2026-02-27 17:35:12', 1476, 'root@localhost', 'localhost', 'id_ai_herramienta,nombre_herramienta,cantidad,estado,std_reg', 1),
(2, 'ca164c46-1402-11f1-9511-989096ab40dc', '000000', 'user_system', 'UPDATE', 'id_user=26580187', '{\"id_user\": \"26580187\"}', 'MODIFICAR user_system', 'UPDATE user_system id_user=26580187', '{\"id_ai_user\": 4, \"id_user\": \"26580187\", \"user\": \"Walter Ramone\", \"username\": \"prueba\", \"password\": \"***\", \"tipo\": 17, \"std_reg\": 1}', '{\"id_ai_user\": 4, \"id_user\": \"26580187\", \"user\": \"Walter Ramone\", \"username\": \"prueba\", \"password\": \"***\", \"tipo\": 17, \"std_reg\": 1}', '{}', '2026-02-27 17:35:59', 1488, 'root@localhost', 'localhost', NULL, 1),
(3, 'd53c387e-1402-11f1-9511-989096ab40dc', '000000', 'user_system', 'UPDATE', 'id_user=26580187', '{\"id_user\": \"26580187\"}', 'MODIFICAR user_system', 'UPDATE user_system id_user=26580187', '{\"id_ai_user\": 4, \"id_user\": \"26580187\", \"user\": \"Walter Ramone\", \"username\": \"prueba\", \"password\": \"***\", \"tipo\": 17, \"std_reg\": 1}', '{\"id_ai_user\": 4, \"id_user\": \"26580187\", \"user\": \"Walter Ramone\", \"username\": \"prueba\", \"password\": \"***\", \"tipo\": 17, \"std_reg\": 1}', '{\"password\": \"CHANGED\"}', '2026-02-27 17:36:18', 1493, 'root@localhost', 'localhost', 'password', 1),
(4, 'ecd6e8be-1402-11f1-9511-989096ab40dc', '26580187', 'detalle_orden', 'UPDATE', 'id_ai_detalle=29', '{\"id_ai_detalle\": 29}', 'MODIFICAR detalle_orden', 'UPDATE detalle_orden id_ai_detalle=29', '{\"id_ai_detalle\": 29, \"n_ot\": \"VF-APV-01\", \"fecha\": \"2026-02-16\", \"descripcion\": \"DETALLE PRUEBA VF-APV-01: actividad programada\", \"id_ai_turno\": 2, \"id_miembro_cco\": \"M-001\", \"id_user_act\": \"12345678\", \"id_miembro_ccf\": \"M-012\", \"id_ai_estado\": 12, \"cant_tec\": 4, \"hora_ini_pre\": \"07:00\", \"hora_fin_pre\": \"07:30\", \"hora_ini_tra\": \"07:30\", \"hora_fin_tra\": \"08:00\", \"hora_ini_eje\": \"08:00\", \"hora_fin_eje\": \"10:00\", \"observacion\": \"PRUEBA\"}', '{\"id_ai_detalle\": 29, \"n_ot\": \"VF-APV-01\", \"fecha\": \"2026-02-16\", \"descripcion\": \"DETALLE PRUEBA VF-APV-01: actividad programada\", \"id_ai_turno\": 2, \"id_miembro_cco\": \"M-001\", \"id_user_act\": \"12345678\", \"id_miembro_ccf\": \"M-012\", \"id_ai_estado\": 12, \"cant_tec\": 4, \"hora_ini_pre\": \"07:00\", \"hora_fin_pre\": \"07:30\", \"hora_ini_tra\": \"07:30\", \"hora_fin_tra\": \"08:00\", \"hora_ini_eje\": \"08:00\", \"hora_fin_eje\": \"10:00\", \"observacion\": \"PRUEBA\"}', '{}', '2026-02-27 17:36:57', 1524, 'root@localhost', 'localhost', NULL, 1),
(5, 'eb87e46e-1403-11f1-9511-989096ab40dc', '26580187', 'detalle_orden', 'UPDATE', 'id_ai_detalle=29', '{\"id_ai_detalle\": 29}', 'MODIFICAR detalle_orden', 'UPDATE detalle_orden id_ai_detalle=29', '{\"id_ai_detalle\": 29, \"n_ot\": \"VF-APV-01\", \"fecha\": \"2026-02-16\", \"descripcion\": \"DETALLE PRUEBA VF-APV-01: actividad programada\", \"id_ai_turno\": 2, \"id_miembro_cco\": \"M-001\", \"id_user_act\": \"12345678\", \"id_miembro_ccf\": \"M-012\", \"id_ai_estado\": 12, \"cant_tec\": 4, \"hora_ini_pre\": \"07:00\", \"hora_fin_pre\": \"07:30\", \"hora_ini_tra\": \"07:30\", \"hora_fin_tra\": \"08:00\", \"hora_ini_eje\": \"08:00\", \"hora_fin_eje\": \"10:00\", \"observacion\": \"PRUEBA\"}', '{\"id_ai_detalle\": 29, \"n_ot\": \"VF-APV-01\", \"fecha\": \"2026-02-16\", \"descripcion\": \"DETALLE PRUEBA VF-APV-01\", \"id_ai_turno\": 2, \"id_miembro_cco\": \"M-001\", \"id_user_act\": \"12345678\", \"id_miembro_ccf\": \"M-012\", \"id_ai_estado\": 12, \"cant_tec\": 4, \"hora_ini_pre\": \"07:00\", \"hora_fin_pre\": \"07:30\", \"hora_ini_tra\": \"07:30\", \"hora_fin_tra\": \"08:00\", \"hora_ini_eje\": \"08:00\", \"hora_fin_eje\": \"10:00\", \"observacion\": \"PRUEBA\"}', '{\"descripcion\": [\"DETALLE PRUEBA VF-APV-01: actividad programada\", \"DETALLE PRUEBA VF-APV-01\"]}', '2026-02-27 17:44:05', 1576, 'u_admin@localhost', 'localhost', 'descripcion', 1),
(6, '2da71a02-14e8-11f1-93d3-989096ab40dc', '000000', 'miembro', 'UPDATE', 'id_ai_miembro=2', '{\"id_ai_miembro\": 2}', 'MODIFICAR miembro', 'UPDATE miembro id_ai_miembro=2', '{\"id_ai_miembro\": 2, \"id_miembro\": \"M-001\", \"nombre_miembro\": \"PEDRO PEREZ\", \"tipo_miembro\": 2, \"std_reg\": 1}', '{\"id_ai_miembro\": 2, \"id_miembro\": \"M-001\", \"nombre_miembro\": \"PEDRO PEREZ\", \"tipo_miembro\": 2, \"std_reg\": 1}', '{}', '2026-02-28 20:58:00', 214, 'u_admin@localhost', 'localhost', NULL, 1),
(7, 'c5045577-14f1-11f1-93d3-989096ab40dc', '000000', 'user_system', 'UPDATE', 'id_user=12345678', '{\"id_user\": \"12345678\"}', 'MODIFICAR user_system', 'UPDATE user_system id_user=12345678', '{\"id_ai_user\": 1, \"id_user\": \"12345678\", \"user\": \"ADMINISTRADOR SISTEMA\", \"username\": \"administrador\", \"password\": \"***\", \"tipo\": 5, \"std_reg\": 1}', '{\"id_ai_user\": 1, \"id_user\": \"12345678\", \"user\": \"ADMINISTRADOR SISTEMA\", \"username\": \"administrador\", \"password\": \"***\", \"tipo\": 5, \"std_reg\": 1}', '{\"password\": \"CHANGED\"}', '2026-02-28 22:06:39', 326, 'u_admin@localhost', 'localhost', 'password', 1),
(8, 'd1f23cf2-14fc-11f1-93d3-989096ab40dc', '000000', 'user_system', 'UPDATE', 'id_user=000000', '{\"id_user\": \"000000\"}', 'MODIFICAR user_system', 'UPDATE user_system id_user=000000', '{\"id_ai_user\": 2, \"id_user\": \"000000\", \"user\": \"USUARIO SISTEMA\", \"username\": \"root\", \"password\": \"***\", \"tipo\": 1, \"std_reg\": 1}', '{\"id_ai_user\": 2, \"id_user\": \"000000\", \"user\": \"USUARIO SISTEMA\", \"username\": \"admin\", \"password\": \"***\", \"tipo\": 1, \"std_reg\": 1}', '{\"username\": [\"root\", \"admin\"], \"password\": \"CHANGED\"}', '2026-02-28 23:25:46', 497, 'u_admin@localhost', 'localhost', 'username,password', 1),
(9, '3d297bd0-1db7-11f1-943a-989096ab40dc', '000000', 'herramienta', 'INSERT', 'id_ai_herramienta=39', '{\"id_ai_herramienta\": 39}', 'CREAR herramienta', 'INSERT herramienta id_ai_herramienta=39', NULL, '{\"id_ai_herramienta\": 39, \"nombre_herramienta\": \"xxxx\", \"cantidad\": 10, \"estado\": \"1\", \"std_reg\": 1}', '{\"id_ai_herramienta\": 39, \"nombre_herramienta\": \"xxxx\", \"cantidad\": 10, \"estado\": \"1\", \"std_reg\": 1}', '2026-03-12 02:00:15', 37495, 'u_app@localhost', 'localhost', 'id_ai_herramienta,nombre_herramienta,cantidad,estado,std_reg', 1),
(10, '1bab4765-207e-11f1-94fd-989096ab40dc', NULL, 'user_system', 'UPDATE', 'id_user=12345678', '{\"id_user\": \"12345678\"}', 'MODIFICAR user_system', 'UPDATE user_system id_user=12345678', '{\"id_ai_user\": 1, \"id_user\": \"12345678\", \"user\": \"ADMINISTRADOR SISTEMA\", \"username\": \"administrador\", \"password\": \"***\", \"tipo\": 5, \"std_reg\": 1}', '{\"id_ai_user\": 1, \"id_user\": \"12345678\", \"user\": \"ADMINISTRADOR SISTEMA\", \"username\": \"administrador\", \"password\": \"***\", \"tipo\": 5, \"std_reg\": 1}', '{}', '2026-03-15 14:49:02', 29, 'u_admin@localhost', 'localhost', NULL, 1),
(11, '1bab80ad-207e-11f1-94fd-989096ab40dc', NULL, 'user_system', 'UPDATE', 'id_user=000000', '{\"id_user\": \"000000\"}', 'MODIFICAR user_system', 'UPDATE user_system id_user=000000', '{\"id_ai_user\": 2, \"id_user\": \"000000\", \"user\": \"USUARIO SISTEMA\", \"username\": \"admin\", \"password\": \"***\", \"tipo\": 1, \"std_reg\": 1}', '{\"id_ai_user\": 2, \"id_user\": \"000000\", \"user\": \"USUARIO SISTEMA\", \"username\": \"admin\", \"password\": \"***\", \"tipo\": 1, \"std_reg\": 1}', '{}', '2026-03-15 14:49:02', 29, 'u_admin@localhost', 'localhost', NULL, 1),
(12, '1bab89d3-207e-11f1-94fd-989096ab40dc', NULL, 'user_system', 'UPDATE', 'id_user=26580187', '{\"id_user\": \"26580187\"}', 'MODIFICAR user_system', 'UPDATE user_system id_user=26580187', '{\"id_ai_user\": 4, \"id_user\": \"26580187\", \"user\": \"Walter Ramone\", \"username\": \"prueba\", \"password\": \"***\", \"tipo\": 17, \"std_reg\": 1}', '{\"id_ai_user\": 4, \"id_user\": \"26580187\", \"user\": \"Walter Ramone\", \"username\": \"prueba\", \"password\": \"***\", \"tipo\": 17, \"std_reg\": 1}', '{}', '2026-03-15 14:49:02', 29, 'u_admin@localhost', 'localhost', NULL, 1),
(14, 'ac22a904-2083-11f1-94fd-989096ab40dc', '12345678', 'user_system', 'UPDATE', 'id_user=12345678', '{\"id_user\": \"12345678\"}', 'MODIFICAR user_system', 'UPDATE user_system id_user=12345678', '{\"id_ai_user\": 1, \"id_user\": \"12345678\", \"user\": \"ADMINISTRADOR SISTEMA\", \"username\": \"administrador\", \"password\": \"***\", \"tipo\": 5, \"std_reg\": 1}', '{\"id_ai_user\": 1, \"id_user\": \"12345678\", \"user\": \"ADMINISTRADOR SISTEMA\", \"username\": \"administrador\", \"password\": \"***\", \"tipo\": 5, \"std_reg\": 1}', '{}', '2026-03-15 15:28:52', 141, 'u_app@localhost', 'localhost', NULL, 1),
(15, 'd31dc38f-2084-11f1-94fd-989096ab40dc', '000000', 'user_system', 'UPDATE', 'id_user=12345678', '{\"id_user\": \"12345678\"}', 'MODIFICAR user_system', 'UPDATE user_system id_user=12345678', '{\"id_ai_user\": 1, \"id_user\": \"12345678\", \"user\": \"ADMINISTRADOR SISTEMA\", \"username\": \"administrador\", \"password\": \"***\", \"tipo\": 5, \"std_reg\": 1}', '{\"id_ai_user\": 1, \"id_user\": \"12345678\", \"user\": \"ADMINISTRADOR SISTEMA\", \"username\": \"administrador\", \"password\": \"***\", \"tipo\": 5, \"std_reg\": 1}', '{}', '2026-03-15 15:37:07', 155, 'u_app@localhost', 'localhost', NULL, 1),
(16, 'c99bf257-209a-11f1-94fd-989096ab40dc', NULL, 'herramienta', 'UPDATE', 'id_ai_herramienta=0', '{\"id_ai_herramienta\": 0}', 'MODIFICAR herramienta', 'UPDATE herramienta id_ai_herramienta=0', '{\"id_ai_herramienta\": 0, \"nombre_herramienta\": \"cemento\", \"cantidad\": 9, \"estado\": \"1\", \"std_reg\": 0}', '{\"id_ai_herramienta\": 0, \"nombre_herramienta\": \"cemento\", \"cantidad\": 9, \"estado\": \"1\", \"std_reg\": 0}', '{}', '2026-03-15 18:14:20', 248, 'u_admin@localhost', 'localhost', NULL, 1),
(17, 'c99caf7f-209a-11f1-94fd-989096ab40dc', NULL, 'herramienta', 'UPDATE', 'id_ai_herramienta=1', '{\"id_ai_herramienta\": 1}', 'MODIFICAR herramienta', 'UPDATE herramienta id_ai_herramienta=1', '{\"id_ai_herramienta\": 1, \"nombre_herramienta\": \"Martillo electricos\", \"cantidad\": 11, \"estado\": \"1\", \"std_reg\": 1}', '{\"id_ai_herramienta\": 1, \"nombre_herramienta\": \"Martillo electricos\", \"cantidad\": 11, \"estado\": \"1\", \"std_reg\": 1}', '{}', '2026-03-15 18:14:20', 248, 'u_admin@localhost', 'localhost', NULL, 1),
(18, 'c99cbdd2-209a-11f1-94fd-989096ab40dc', NULL, 'herramienta', 'UPDATE', 'id_ai_herramienta=3', '{\"id_ai_herramienta\": 3}', 'MODIFICAR herramienta', 'UPDATE herramienta id_ai_herramienta=3', '{\"id_ai_herramienta\": 3, \"nombre_herramienta\": \"PRUEBA\", \"cantidad\": 2, \"estado\": \"3\", \"std_reg\": 0}', '{\"id_ai_herramienta\": 3, \"nombre_herramienta\": \"PRUEBA\", \"cantidad\": 2, \"estado\": \"3\", \"std_reg\": 0}', '{}', '2026-03-15 18:14:20', 248, 'u_admin@localhost', 'localhost', NULL, 1),
(19, 'c99cc833-209a-11f1-94fd-989096ab40dc', NULL, 'herramienta', 'UPDATE', 'id_ai_herramienta=4', '{\"id_ai_herramienta\": 4}', 'MODIFICAR herramienta', 'UPDATE herramienta id_ai_herramienta=4', '{\"id_ai_herramienta\": 4, \"nombre_herramienta\": \"tubo\", \"cantidad\": 1, \"estado\": \"2\", \"std_reg\": 0}', '{\"id_ai_herramienta\": 4, \"nombre_herramienta\": \"tubo\", \"cantidad\": 1, \"estado\": \"2\", \"std_reg\": 0}', '{}', '2026-03-15 18:14:20', 248, 'u_admin@localhost', 'localhost', NULL, 1),
(20, 'c99cd1d4-209a-11f1-94fd-989096ab40dc', NULL, 'herramienta', 'UPDATE', 'id_ai_herramienta=5', '{\"id_ai_herramienta\": 5}', 'MODIFICAR herramienta', 'UPDATE herramienta id_ai_herramienta=5', '{\"id_ai_herramienta\": 5, \"nombre_herramienta\": \"tubo de 1/2 6m // 56\", \"cantidad\": 1, \"estado\": \"1\", \"std_reg\": 0}', '{\"id_ai_herramienta\": 5, \"nombre_herramienta\": \"tubo de 1/2 6m // 56\", \"cantidad\": 1, \"estado\": \"1\", \"std_reg\": 0}', '{}', '2026-03-15 18:14:20', 248, 'u_admin@localhost', 'localhost', NULL, 1),
(21, 'c99cda96-209a-11f1-94fd-989096ab40dc', NULL, 'herramienta', 'UPDATE', 'id_ai_herramienta=6', '{\"id_ai_herramienta\": 6}', 'MODIFICAR herramienta', 'UPDATE herramienta id_ai_herramienta=6', '{\"id_ai_herramienta\": 6, \"nombre_herramienta\": \"eduardo carmona\", \"cantidad\": 1, \"estado\": \"3\", \"std_reg\": 0}', '{\"id_ai_herramienta\": 6, \"nombre_herramienta\": \"eduardo carmona\", \"cantidad\": 1, \"estado\": \"3\", \"std_reg\": 0}', '{}', '2026-03-15 18:14:20', 248, 'u_admin@localhost', 'localhost', NULL, 1),
(22, 'c99ce0c0-209a-11f1-94fd-989096ab40dc', NULL, 'herramienta', 'UPDATE', 'id_ai_herramienta=7', '{\"id_ai_herramienta\": 7}', 'MODIFICAR herramienta', 'UPDATE herramienta id_ai_herramienta=7', '{\"id_ai_herramienta\": 7, \"nombre_herramienta\": \"ADMINISTRADOR SISTEMA\", \"cantidad\": 4, \"estado\": \"1\", \"std_reg\": 0}', '{\"id_ai_herramienta\": 7, \"nombre_herramienta\": \"ADMINISTRADOR SISTEMA\", \"cantidad\": 4, \"estado\": \"1\", \"std_reg\": 0}', '{}', '2026-03-15 18:14:20', 248, 'u_admin@localhost', 'localhost', NULL, 1),
(23, 'c99ce63b-209a-11f1-94fd-989096ab40dc', NULL, 'herramienta', 'UPDATE', 'id_ai_herramienta=8', '{\"id_ai_herramienta\": 8}', 'MODIFICAR herramienta', 'UPDATE herramienta id_ai_herramienta=8', '{\"id_ai_herramienta\": 8, \"nombre_herramienta\": \"cemento\", \"cantidad\": 2, \"estado\": \"1\", \"std_reg\": 0}', '{\"id_ai_herramienta\": 8, \"nombre_herramienta\": \"cemento\", \"cantidad\": 2, \"estado\": \"1\", \"std_reg\": 0}', '{}', '2026-03-15 18:14:20', 248, 'u_admin@localhost', 'localhost', NULL, 1),
(24, 'c99ceb76-209a-11f1-94fd-989096ab40dc', NULL, 'herramienta', 'UPDATE', 'id_ai_herramienta=9', '{\"id_ai_herramienta\": 9}', 'MODIFICAR herramienta', 'UPDATE herramienta id_ai_herramienta=9', '{\"id_ai_herramienta\": 9, \"nombre_herramienta\": \"ADMINISTRADOR SISTEMA 66\", \"cantidad\": 5, \"estado\": \"1\", \"std_reg\": 0}', '{\"id_ai_herramienta\": 9, \"nombre_herramienta\": \"ADMINISTRADOR SISTEMA 66\", \"cantidad\": 5, \"estado\": \"1\", \"std_reg\": 0}', '{}', '2026-03-15 18:14:20', 248, 'u_admin@localhost', 'localhost', NULL, 1),
(25, 'c99cf08f-209a-11f1-94fd-989096ab40dc', NULL, 'herramienta', 'UPDATE', 'id_ai_herramienta=10', '{\"id_ai_herramienta\": 10}', 'MODIFICAR herramienta', 'UPDATE herramienta id_ai_herramienta=10', '{\"id_ai_herramienta\": 10, \"nombre_herramienta\": \"ADMINISTRADOR SISTEMA\", \"cantidad\": 4, \"estado\": \"1\", \"std_reg\": 0}', '{\"id_ai_herramienta\": 10, \"nombre_herramienta\": \"ADMINISTRADOR SISTEMA\", \"cantidad\": 4, \"estado\": \"1\", \"std_reg\": 0}', '{}', '2026-03-15 18:14:20', 248, 'u_admin@localhost', 'localhost', NULL, 1),
(26, 'c99cf5a2-209a-11f1-94fd-989096ab40dc', NULL, 'herramienta', 'UPDATE', 'id_ai_herramienta=11', '{\"id_ai_herramienta\": 11}', 'MODIFICAR herramienta', 'UPDATE herramienta id_ai_herramienta=11', '{\"id_ai_herramienta\": 11, \"nombre_herramienta\": \"Taladro percutor\", \"cantidad\": 4, \"estado\": \"3\", \"std_reg\": 1}', '{\"id_ai_herramienta\": 11, \"nombre_herramienta\": \"Taladro percutor\", \"cantidad\": 4, \"estado\": \"3\", \"std_reg\": 1}', '{}', '2026-03-15 18:14:20', 248, 'u_admin@localhost', 'localhost', NULL, 1),
(27, 'c99cfa90-209a-11f1-94fd-989096ab40dc', NULL, 'herramienta', 'UPDATE', 'id_ai_herramienta=12', '{\"id_ai_herramienta\": 12}', 'MODIFICAR herramienta', 'UPDATE herramienta id_ai_herramienta=12', '{\"id_ai_herramienta\": 12, \"nombre_herramienta\": \"Llave inglesa\", \"cantidad\": 7, \"estado\": \"1\", \"std_reg\": 1}', '{\"id_ai_herramienta\": 12, \"nombre_herramienta\": \"Llave inglesa\", \"cantidad\": 7, \"estado\": \"1\", \"std_reg\": 1}', '{}', '2026-03-15 18:14:20', 248, 'u_admin@localhost', 'localhost', NULL, 1),
(28, 'c99cff7c-209a-11f1-94fd-989096ab40dc', NULL, 'herramienta', 'UPDATE', 'id_ai_herramienta=13', '{\"id_ai_herramienta\": 13}', 'MODIFICAR herramienta', 'UPDATE herramienta id_ai_herramienta=13', '{\"id_ai_herramienta\": 13, \"nombre_herramienta\": \"Juego de destornilladores\", \"cantidad\": 10, \"estado\": \"2\", \"std_reg\": 1}', '{\"id_ai_herramienta\": 13, \"nombre_herramienta\": \"Juego de destornilladores\", \"cantidad\": 10, \"estado\": \"2\", \"std_reg\": 1}', '{}', '2026-03-15 18:14:20', 248, 'u_admin@localhost', 'localhost', NULL, 1),
(29, 'c99d0477-209a-11f1-94fd-989096ab40dc', NULL, 'herramienta', 'UPDATE', 'id_ai_herramienta=14', '{\"id_ai_herramienta\": 14}', 'MODIFICAR herramienta', 'UPDATE herramienta id_ai_herramienta=14', '{\"id_ai_herramienta\": 14, \"nombre_herramienta\": \"Pinza de presión\", \"cantidad\": 3, \"estado\": \"3\", \"std_reg\": 1}', '{\"id_ai_herramienta\": 14, \"nombre_herramienta\": \"Pinza de presión\", \"cantidad\": 3, \"estado\": \"3\", \"std_reg\": 1}', '{}', '2026-03-15 18:14:20', 248, 'u_admin@localhost', 'localhost', NULL, 1),
(30, 'c99d1dbc-209a-11f1-94fd-989096ab40dc', NULL, 'herramienta', 'UPDATE', 'id_ai_herramienta=15', '{\"id_ai_herramienta\": 15}', 'MODIFICAR herramienta', 'UPDATE herramienta id_ai_herramienta=15', '{\"id_ai_herramienta\": 15, \"nombre_herramienta\": \"Sierra manual\", \"cantidad\": 6, \"estado\": \"1\", \"std_reg\": 0}', '{\"id_ai_herramienta\": 15, \"nombre_herramienta\": \"Sierra manual\", \"cantidad\": 6, \"estado\": \"1\", \"std_reg\": 0}', '{}', '2026-03-15 18:14:20', 248, 'u_admin@localhost', 'localhost', NULL, 1),
(31, 'c99d9d6a-209a-11f1-94fd-989096ab40dc', NULL, 'herramienta', 'UPDATE', 'id_ai_herramienta=16', '{\"id_ai_herramienta\": 16}', 'MODIFICAR herramienta', 'UPDATE herramienta id_ai_herramienta=16', '{\"id_ai_herramienta\": 16, \"nombre_herramienta\": \"Amoladora\", \"cantidad\": 9, \"estado\": \"2\", \"std_reg\": 0}', '{\"id_ai_herramienta\": 16, \"nombre_herramienta\": \"Amoladora\", \"cantidad\": 9, \"estado\": \"2\", \"std_reg\": 0}', '{}', '2026-03-15 18:14:20', 248, 'u_admin@localhost', 'localhost', NULL, 1),
(32, 'c99dfe86-209a-11f1-94fd-989096ab40dc', NULL, 'herramienta', 'UPDATE', 'id_ai_herramienta=17', '{\"id_ai_herramienta\": 17}', 'MODIFICAR herramienta', 'UPDATE herramienta id_ai_herramienta=17', '{\"id_ai_herramienta\": 17, \"nombre_herramienta\": \"Cinta métrica 5m\", \"cantidad\": 2, \"estado\": \"3\", \"std_reg\": 1}', '{\"id_ai_herramienta\": 17, \"nombre_herramienta\": \"Cinta métrica 5m\", \"cantidad\": 2, \"estado\": \"3\", \"std_reg\": 1}', '{}', '2026-03-15 18:14:20', 248, 'u_admin@localhost', 'localhost', NULL, 1),
(33, 'c99e1a7c-209a-11f1-94fd-989096ab40dc', NULL, 'herramienta', 'UPDATE', 'id_ai_herramienta=18', '{\"id_ai_herramienta\": 18}', 'MODIFICAR herramienta', 'UPDATE herramienta id_ai_herramienta=18', '{\"id_ai_herramienta\": 18, \"nombre_herramienta\": \"Nivel de burbuja\", \"cantidad\": 5, \"estado\": \"1\", \"std_reg\": 1}', '{\"id_ai_herramienta\": 18, \"nombre_herramienta\": \"Nivel de burbuja\", \"cantidad\": 5, \"estado\": \"1\", \"std_reg\": 1}', '{}', '2026-03-15 18:14:20', 248, 'u_admin@localhost', 'localhost', NULL, 1),
(34, 'c99e30e8-209a-11f1-94fd-989096ab40dc', NULL, 'herramienta', 'UPDATE', 'id_ai_herramienta=19', '{\"id_ai_herramienta\": 19}', 'MODIFICAR herramienta', 'UPDATE herramienta id_ai_herramienta=19', '{\"id_ai_herramienta\": 19, \"nombre_herramienta\": \"Escalera aluminio\", \"cantidad\": 8, \"estado\": \"2\", \"std_reg\": 1}', '{\"id_ai_herramienta\": 19, \"nombre_herramienta\": \"Escalera aluminio\", \"cantidad\": 8, \"estado\": \"2\", \"std_reg\": 1}', '{}', '2026-03-15 18:14:20', 248, 'u_admin@localhost', 'localhost', NULL, 1),
(35, 'c99e3fae-209a-11f1-94fd-989096ab40dc', NULL, 'herramienta', 'UPDATE', 'id_ai_herramienta=20', '{\"id_ai_herramienta\": 20}', 'MODIFICAR herramienta', 'UPDATE herramienta id_ai_herramienta=20', '{\"id_ai_herramienta\": 20, \"nombre_herramienta\": \"Multímetro digital\", \"cantidad\": 1, \"estado\": \"3\", \"std_reg\": 1}', '{\"id_ai_herramienta\": 20, \"nombre_herramienta\": \"Multímetro digital\", \"cantidad\": 1, \"estado\": \"3\", \"std_reg\": 1}', '{}', '2026-03-15 18:14:20', 248, 'u_admin@localhost', 'localhost', NULL, 1),
(36, 'c99e4be6-209a-11f1-94fd-989096ab40dc', NULL, 'herramienta', 'UPDATE', 'id_ai_herramienta=21', '{\"id_ai_herramienta\": 21}', 'MODIFICAR herramienta', 'UPDATE herramienta id_ai_herramienta=21', '{\"id_ai_herramienta\": 21, \"nombre_herramienta\": \"Soldadora inverter\", \"cantidad\": 4, \"estado\": \"1\", \"std_reg\": 1}', '{\"id_ai_herramienta\": 21, \"nombre_herramienta\": \"Soldadora inverter\", \"cantidad\": 4, \"estado\": \"1\", \"std_reg\": 1}', '{}', '2026-03-15 18:14:20', 248, 'u_admin@localhost', 'localhost', NULL, 1),
(37, 'c99e5570-209a-11f1-94fd-989096ab40dc', NULL, 'herramienta', 'UPDATE', 'id_ai_herramienta=22', '{\"id_ai_herramienta\": 22}', 'MODIFICAR herramienta', 'UPDATE herramienta id_ai_herramienta=22', '{\"id_ai_herramienta\": 22, \"nombre_herramienta\": \"Careta de soldar\", \"cantidad\": 7, \"estado\": \"2\", \"std_reg\": 1}', '{\"id_ai_herramienta\": 22, \"nombre_herramienta\": \"Careta de soldar\", \"cantidad\": 7, \"estado\": \"2\", \"std_reg\": 1}', '{}', '2026-03-15 18:14:20', 248, 'u_admin@localhost', 'localhost', NULL, 1),
(38, 'c99e5d3a-209a-11f1-94fd-989096ab40dc', NULL, 'herramienta', 'UPDATE', 'id_ai_herramienta=23', '{\"id_ai_herramienta\": 23}', 'MODIFICAR herramienta', 'UPDATE herramienta id_ai_herramienta=23', '{\"id_ai_herramienta\": 23, \"nombre_herramienta\": \"Guantes dieléctricos\", \"cantidad\": 10, \"estado\": \"3\", \"std_reg\": 1}', '{\"id_ai_herramienta\": 23, \"nombre_herramienta\": \"Guantes dieléctricos\", \"cantidad\": 10, \"estado\": \"3\", \"std_reg\": 1}', '{}', '2026-03-15 18:14:20', 248, 'u_admin@localhost', 'localhost', NULL, 1),
(39, 'c99e653c-209a-11f1-94fd-989096ab40dc', NULL, 'herramienta', 'UPDATE', 'id_ai_herramienta=24', '{\"id_ai_herramienta\": 24}', 'MODIFICAR herramienta', 'UPDATE herramienta id_ai_herramienta=24', '{\"id_ai_herramienta\": 24, \"nombre_herramienta\": \"Casco de seguridad\", \"cantidad\": 3, \"estado\": \"1\", \"std_reg\": 1}', '{\"id_ai_herramienta\": 24, \"nombre_herramienta\": \"Casco de seguridad\", \"cantidad\": 3, \"estado\": \"1\", \"std_reg\": 1}', '{}', '2026-03-15 18:14:20', 248, 'u_admin@localhost', 'localhost', NULL, 1),
(40, 'c99e6c3c-209a-11f1-94fd-989096ab40dc', NULL, 'herramienta', 'UPDATE', 'id_ai_herramienta=25', '{\"id_ai_herramienta\": 25}', 'MODIFICAR herramienta', 'UPDATE herramienta id_ai_herramienta=25', '{\"id_ai_herramienta\": 25, \"nombre_herramienta\": \"Arnés de seguridad\", \"cantidad\": 6, \"estado\": \"2\", \"std_reg\": 1}', '{\"id_ai_herramienta\": 25, \"nombre_herramienta\": \"Arnés de seguridad\", \"cantidad\": 6, \"estado\": \"2\", \"std_reg\": 1}', '{}', '2026-03-15 18:14:20', 248, 'u_admin@localhost', 'localhost', NULL, 1),
(41, 'c99e71fe-209a-11f1-94fd-989096ab40dc', NULL, 'herramienta', 'UPDATE', 'id_ai_herramienta=26', '{\"id_ai_herramienta\": 26}', 'MODIFICAR herramienta', 'UPDATE herramienta id_ai_herramienta=26', '{\"id_ai_herramienta\": 26, \"nombre_herramienta\": \"Linterna recargable\", \"cantidad\": 9, \"estado\": \"3\", \"std_reg\": 1}', '{\"id_ai_herramienta\": 26, \"nombre_herramienta\": \"Linterna recargable\", \"cantidad\": 9, \"estado\": \"3\", \"std_reg\": 1}', '{}', '2026-03-15 18:14:20', 248, 'u_admin@localhost', 'localhost', NULL, 1),
(42, 'c99e77f6-209a-11f1-94fd-989096ab40dc', NULL, 'herramienta', 'UPDATE', 'id_ai_herramienta=27', '{\"id_ai_herramienta\": 27}', 'MODIFICAR herramienta', 'UPDATE herramienta id_ai_herramienta=27', '{\"id_ai_herramienta\": 27, \"nombre_herramienta\": \"Generador portátil\", \"cantidad\": 2, \"estado\": \"1\", \"std_reg\": 1}', '{\"id_ai_herramienta\": 27, \"nombre_herramienta\": \"Generador portátil\", \"cantidad\": 2, \"estado\": \"1\", \"std_reg\": 1}', '{}', '2026-03-15 18:14:20', 248, 'u_admin@localhost', 'localhost', NULL, 1),
(43, 'c99e7d36-209a-11f1-94fd-989096ab40dc', NULL, 'herramienta', 'UPDATE', 'id_ai_herramienta=28', '{\"id_ai_herramienta\": 28}', 'MODIFICAR herramienta', 'UPDATE herramienta id_ai_herramienta=28', '{\"id_ai_herramienta\": 28, \"nombre_herramienta\": \"Compresor de aire\", \"cantidad\": 5, \"estado\": \"2\", \"std_reg\": 1}', '{\"id_ai_herramienta\": 28, \"nombre_herramienta\": \"Compresor de aire\", \"cantidad\": 5, \"estado\": \"2\", \"std_reg\": 1}', '{}', '2026-03-15 18:14:20', 248, 'u_admin@localhost', 'localhost', NULL, 1),
(44, 'c99e8271-209a-11f1-94fd-989096ab40dc', NULL, 'herramienta', 'UPDATE', 'id_ai_herramienta=29', '{\"id_ai_herramienta\": 29}', 'MODIFICAR herramienta', 'UPDATE herramienta id_ai_herramienta=29', '{\"id_ai_herramienta\": 29, \"nombre_herramienta\": \"Gato hidráulico\", \"cantidad\": 8, \"estado\": \"3\", \"std_reg\": 1}', '{\"id_ai_herramienta\": 29, \"nombre_herramienta\": \"Gato hidráulico\", \"cantidad\": 8, \"estado\": \"3\", \"std_reg\": 1}', '{}', '2026-03-15 18:14:20', 248, 'u_admin@localhost', 'localhost', NULL, 1),
(45, 'c99e8797-209a-11f1-94fd-989096ab40dc', NULL, 'herramienta', 'UPDATE', 'id_ai_herramienta=30', '{\"id_ai_herramienta\": 30}', 'MODIFICAR herramienta', 'UPDATE herramienta id_ai_herramienta=30', '{\"id_ai_herramienta\": 30, \"nombre_herramienta\": \"Cizalla para cables\", \"cantidad\": 1, \"estado\": \"1\", \"std_reg\": 1}', '{\"id_ai_herramienta\": 30, \"nombre_herramienta\": \"Cizalla para cables\", \"cantidad\": 1, \"estado\": \"1\", \"std_reg\": 1}', '{}', '2026-03-15 18:14:20', 248, 'u_admin@localhost', 'localhost', NULL, 1),
(46, 'c99e8ce7-209a-11f1-94fd-989096ab40dc', NULL, 'herramienta', 'UPDATE', 'id_ai_herramienta=31', '{\"id_ai_herramienta\": 31}', 'MODIFICAR herramienta', 'UPDATE herramienta id_ai_herramienta=31', '{\"id_ai_herramienta\": 31, \"nombre_herramienta\": \"limpia contacto\", \"cantidad\": 10, \"estado\": \"1\", \"std_reg\": 1}', '{\"id_ai_herramienta\": 31, \"nombre_herramienta\": \"limpia contacto\", \"cantidad\": 10, \"estado\": \"1\", \"std_reg\": 1}', '{}', '2026-03-15 18:14:20', 248, 'u_admin@localhost', 'localhost', NULL, 1),
(47, 'c99e9248-209a-11f1-94fd-989096ab40dc', NULL, 'herramienta', 'UPDATE', 'id_ai_herramienta=32', '{\"id_ai_herramienta\": 32}', 'MODIFICAR herramienta', 'UPDATE herramienta id_ai_herramienta=32', '{\"id_ai_herramienta\": 32, \"nombre_herramienta\": \"Martillo electricos\", \"cantidad\": 2, \"estado\": \"1\", \"std_reg\": 1}', '{\"id_ai_herramienta\": 32, \"nombre_herramienta\": \"Martillo electricos\", \"cantidad\": 2, \"estado\": \"1\", \"std_reg\": 1}', '{}', '2026-03-15 18:14:20', 248, 'u_admin@localhost', 'localhost', NULL, 1),
(48, 'c99e9808-209a-11f1-94fd-989096ab40dc', NULL, 'herramienta', 'UPDATE', 'id_ai_herramienta=33', '{\"id_ai_herramienta\": 33}', 'MODIFICAR herramienta', 'UPDATE herramienta id_ai_herramienta=33', '{\"id_ai_herramienta\": 33, \"nombre_herramienta\": \"Martillo electricos\", \"cantidad\": 12, \"estado\": \"1\", \"std_reg\": 1}', '{\"id_ai_herramienta\": 33, \"nombre_herramienta\": \"Martillo electricos\", \"cantidad\": 12, \"estado\": \"1\", \"std_reg\": 1}', '{}', '2026-03-15 18:14:20', 248, 'u_admin@localhost', 'localhost', NULL, 1),
(49, 'c99e9cfa-209a-11f1-94fd-989096ab40dc', NULL, 'herramienta', 'UPDATE', 'id_ai_herramienta=34', '{\"id_ai_herramienta\": 34}', 'MODIFICAR herramienta', 'UPDATE herramienta id_ai_herramienta=34', '{\"id_ai_herramienta\": 34, \"nombre_herramienta\": \"Martillo electricos\", \"cantidad\": 111, \"estado\": \"1\", \"std_reg\": 1}', '{\"id_ai_herramienta\": 34, \"nombre_herramienta\": \"Martillo electricos\", \"cantidad\": 111, \"estado\": \"1\", \"std_reg\": 1}', '{}', '2026-03-15 18:14:20', 248, 'u_admin@localhost', 'localhost', NULL, 1),
(50, 'c99ee438-209a-11f1-94fd-989096ab40dc', NULL, 'herramienta', 'UPDATE', 'id_ai_herramienta=35', '{\"id_ai_herramienta\": 35}', 'MODIFICAR herramienta', 'UPDATE herramienta id_ai_herramienta=35', '{\"id_ai_herramienta\": 35, \"nombre_herramienta\": \"Martillo electricos\", \"cantidad\": 4, \"estado\": \"1\", \"std_reg\": 1}', '{\"id_ai_herramienta\": 35, \"nombre_herramienta\": \"Martillo electricos\", \"cantidad\": 4, \"estado\": \"1\", \"std_reg\": 1}', '{}', '2026-03-15 18:14:20', 248, 'u_admin@localhost', 'localhost', NULL, 1),
(51, 'c99eeb02-209a-11f1-94fd-989096ab40dc', NULL, 'herramienta', 'UPDATE', 'id_ai_herramienta=36', '{\"id_ai_herramienta\": 36}', 'MODIFICAR herramienta', 'UPDATE herramienta id_ai_herramienta=36', '{\"id_ai_herramienta\": 36, \"nombre_herramienta\": \"Martillo electricos\", \"cantidad\": 52, \"estado\": \"1\", \"std_reg\": 1}', '{\"id_ai_herramienta\": 36, \"nombre_herramienta\": \"Martillo electricos\", \"cantidad\": 52, \"estado\": \"1\", \"std_reg\": 1}', '{}', '2026-03-15 18:14:20', 248, 'u_admin@localhost', 'localhost', NULL, 1),
(52, 'c99ef110-209a-11f1-94fd-989096ab40dc', NULL, 'herramienta', 'UPDATE', 'id_ai_herramienta=37', '{\"id_ai_herramienta\": 37}', 'MODIFICAR herramienta', 'UPDATE herramienta id_ai_herramienta=37', '{\"id_ai_herramienta\": 37, \"nombre_herramienta\": \"cables\", \"cantidad\": 100, \"estado\": \"1\", \"std_reg\": 1}', '{\"id_ai_herramienta\": 37, \"nombre_herramienta\": \"cables\", \"cantidad\": 100, \"estado\": \"1\", \"std_reg\": 1}', '{}', '2026-03-15 18:14:20', 248, 'u_admin@localhost', 'localhost', NULL, 1),
(53, 'c99ef69e-209a-11f1-94fd-989096ab40dc', NULL, 'herramienta', 'UPDATE', 'id_ai_herramienta=38', '{\"id_ai_herramienta\": 38}', 'MODIFICAR herramienta', 'UPDATE herramienta id_ai_herramienta=38', '{\"id_ai_herramienta\": 38, \"nombre_herramienta\": \"herramienta xxx\", \"cantidad\": 5, \"estado\": \"1\", \"std_reg\": 1}', '{\"id_ai_herramienta\": 38, \"nombre_herramienta\": \"herramienta xxx\", \"cantidad\": 5, \"estado\": \"1\", \"std_reg\": 1}', '{}', '2026-03-15 18:14:20', 248, 'u_admin@localhost', 'localhost', NULL, 1),
(54, 'c99efc00-209a-11f1-94fd-989096ab40dc', NULL, 'herramienta', 'UPDATE', 'id_ai_herramienta=39', '{\"id_ai_herramienta\": 39}', 'MODIFICAR herramienta', 'UPDATE herramienta id_ai_herramienta=39', '{\"id_ai_herramienta\": 39, \"nombre_herramienta\": \"xxxx\", \"cantidad\": 10, \"estado\": \"1\", \"std_reg\": 1}', '{\"id_ai_herramienta\": 39, \"nombre_herramienta\": \"xxxx\", \"cantidad\": 10, \"estado\": \"1\", \"std_reg\": 1}', '{}', '2026-03-15 18:14:20', 248, 'u_admin@localhost', 'localhost', NULL, 1),
(63, '72132445-20a5-11f1-94fd-989096ab40dc', NULL, 'user_system', 'UPDATE', 'id_user=12345678', '{\"id_user\": \"12345678\"}', 'MODIFICAR user_system', 'UPDATE user_system id_user=12345678', '{\"id_ai_user\": 1, \"id_user\": \"12345678\", \"user\": \"ADMINISTRADOR SISTEMA\", \"username\": \"administrador\", \"password\": \"***\", \"tipo\": 5, \"std_reg\": 1}', '{\"id_ai_user\": 1, \"id_user\": \"12345678\", \"user\": \"ADMINISTRADOR SISTEMA\", \"username\": \"administrador\", \"password\": \"***\", \"tipo\": 5, \"std_reg\": 1}', '{}', '2026-03-15 19:30:38', 462, 'u_admin@localhost', 'localhost', NULL, 1),
(64, '721355ad-20a5-11f1-94fd-989096ab40dc', NULL, 'user_system', 'UPDATE', 'id_user=000000', '{\"id_user\": \"000000\"}', 'MODIFICAR user_system', 'UPDATE user_system id_user=000000', '{\"id_ai_user\": 2, \"id_user\": \"000000\", \"user\": \"USUARIO SISTEMA\", \"username\": \"admin\", \"password\": \"***\", \"tipo\": 1, \"std_reg\": 1}', '{\"id_ai_user\": 2, \"id_user\": \"000000\", \"user\": \"USUARIO SISTEMA\", \"username\": \"admin\", \"password\": \"***\", \"tipo\": 1, \"std_reg\": 1}', '{}', '2026-03-15 19:30:38', 462, 'u_admin@localhost', 'localhost', NULL, 1),
(65, '72135bed-20a5-11f1-94fd-989096ab40dc', NULL, 'user_system', 'UPDATE', 'id_user=26580187', '{\"id_user\": \"26580187\"}', 'MODIFICAR user_system', 'UPDATE user_system id_user=26580187', '{\"id_ai_user\": 4, \"id_user\": \"26580187\", \"user\": \"Walter Ramone\", \"username\": \"prueba\", \"password\": \"***\", \"tipo\": 17, \"std_reg\": 1}', '{\"id_ai_user\": 4, \"id_user\": \"26580187\", \"user\": \"Walter Ramone\", \"username\": \"prueba\", \"password\": \"***\", \"tipo\": 17, \"std_reg\": 1}', '{}', '2026-03-15 19:30:38', 462, 'u_admin@localhost', 'localhost', NULL, 1),
(66, '7a27f387-20a5-11f1-94fd-989096ab40dc', NULL, 'user_system', 'UPDATE', 'id_user=12345678', '{\"id_user\": \"12345678\"}', 'MODIFICAR user_system', 'UPDATE user_system id_user=12345678', '{\"id_ai_user\": 1, \"id_user\": \"12345678\", \"user\": \"ADMINISTRADOR SISTEMA\", \"username\": \"administrador\", \"password\": \"***\", \"tipo\": 5, \"std_reg\": 1}', '{\"id_ai_user\": 1, \"id_user\": \"12345678\", \"user\": \"ADMINISTRADOR SISTEMA\", \"username\": \"administrador\", \"password\": \"***\", \"tipo\": 5, \"std_reg\": 1}', '{}', '2026-03-15 19:30:51', 464, 'u_admin@localhost', 'localhost', NULL, 1),
(67, '7a28201d-20a5-11f1-94fd-989096ab40dc', NULL, 'user_system', 'UPDATE', 'id_user=000000', '{\"id_user\": \"000000\"}', 'MODIFICAR user_system', 'UPDATE user_system id_user=000000', '{\"id_ai_user\": 2, \"id_user\": \"000000\", \"user\": \"USUARIO SISTEMA\", \"username\": \"admin\", \"password\": \"***\", \"tipo\": 1, \"std_reg\": 1}', '{\"id_ai_user\": 2, \"id_user\": \"000000\", \"user\": \"USUARIO SISTEMA\", \"username\": \"admin\", \"password\": \"***\", \"tipo\": 1, \"std_reg\": 1}', '{}', '2026-03-15 19:30:51', 464, 'u_admin@localhost', 'localhost', NULL, 1),
(68, '7a282caa-20a5-11f1-94fd-989096ab40dc', NULL, 'user_system', 'UPDATE', 'id_user=26580187', '{\"id_user\": \"26580187\"}', 'MODIFICAR user_system', 'UPDATE user_system id_user=26580187', '{\"id_ai_user\": 4, \"id_user\": \"26580187\", \"user\": \"Walter Ramone\", \"username\": \"prueba\", \"password\": \"***\", \"tipo\": 17, \"std_reg\": 1}', '{\"id_ai_user\": 4, \"id_user\": \"26580187\", \"user\": \"Walter Ramone\", \"username\": \"prueba\", \"password\": \"***\", \"tipo\": 17, \"std_reg\": 1}', '{}', '2026-03-15 19:30:51', 464, 'u_admin@localhost', 'localhost', NULL, 1),
(70, '2a779d9e-20ad-11f1-94fd-989096ab40dc', '000000', 'user_system', 'UPDATE', 'id_empleado=000000', '{\"id_empleado\": \"000000\"}', 'MODIFICAR user_system', 'UPDATE user_system id_empleado=000000', '{\"id_ai_user\": 2, \"id_empleado\": \"000000\", \"username\": \"admin\", \"password\": \"***\", \"tipo\": 1, \"std_reg\": 1}', '{\"id_ai_user\": 2, \"id_empleado\": \"000000\", \"username\": \"admin\", \"password\": \"***\", \"tipo\": 1, \"std_reg\": 1}', '{}', '2026-03-15 20:25:53', 583, 'u_app@localhost', 'localhost', NULL, 1),
(71, 'e9d48348-20ad-11f1-94fd-989096ab40dc', '000000', 'herramienta', 'UPDATE', 'id_ai_herramienta=17', '{\"id_ai_herramienta\": 17}', 'MODIFICAR herramienta', 'UPDATE herramienta id_ai_herramienta=17', '{\"id_ai_herramienta\": 17, \"nombre_herramienta\": \"Cinta métrica 5m\", \"cantidad\": 2, \"estado\": \"3\", \"std_reg\": 1}', '{\"id_ai_herramienta\": 17, \"nombre_herramienta\": \"Cinta mtrica m\", \"cantidad\": 2, \"estado\": \"3\", \"std_reg\": 1}', '{\"nombre_herramienta\": [\"Cinta métrica 5m\", \"Cinta mtrica m\"]}', '2026-03-15 20:31:14', 608, 'u_app@localhost', 'localhost', 'nombre_herramienta', 1),
(72, '98ca19b7-20b0-11f1-94fd-989096ab40dc', '000000', 'herramienta', 'UPDATE', 'id_ai_herramienta=17', '{\"id_ai_herramienta\": 17}', 'MODIFICAR herramienta', 'UPDATE herramienta id_ai_herramienta=17', '{\"id_ai_herramienta\": 17, \"nombre_herramienta\": \"Cinta mtrica m\", \"cantidad\": 2, \"estado\": \"3\", \"std_reg\": 1}', '{\"id_ai_herramienta\": 17, \"nombre_herramienta\": \"Cinta mtrica m5\", \"cantidad\": 2, \"estado\": \"3\", \"std_reg\": 1}', '{\"nombre_herramienta\": [\"Cinta mtrica m\", \"Cinta mtrica m5\"]}', '2026-03-15 20:50:27', 688, 'u_app@localhost', 'localhost', 'nombre_herramienta', 1),
(73, '0dd7b1e4-2147-11f1-968b-989096ab40dc', '000000', 'empleado', 'UPDATE', 'id_ai_empleado=1', '{\"id_ai_empleado\": 1}', 'MODIFICAR empleado', 'UPDATE empleado id_ai_empleado=1', '{\"id_ai_empleado\": 1, \"id_empleado\": \"12345678\", \"nacionalidad\": \"V\", \"nombre_empleado\": \"ADMINISTRADOR SISTEMA\", \"telefono\": \"0615-8251111\", \"direccion\": \"DGDDGGDGD\", \"correo\": \"aliguerrero102@gmail.com\", \"id_ai_categoria_empleado\": 1, \"std_reg\": 1}', '{\"id_ai_empleado\": 1, \"id_empleado\": \"12345678\", \"nacionalidad\": \"V\", \"nombre_empleado\": \"ALI GUERRERO\", \"telefono\": \"0615-8251111\", \"direccion\": \"DGDDGGDGD\", \"correo\": \"aliguerrero102@gmail.com\", \"id_ai_categoria_empleado\": 1, \"std_reg\": 1}', '{\"changed_cols\": \"nombre_empleado\"}', '2026-03-16 14:47:23', 188, 'u_app@localhost', 'localhost', 'nombre_empleado', 1),
(74, '0f261d9b-214b-11f1-968b-989096ab40dc', NULL, 'user_system', 'UPDATE', 'id_empleado=12345678', '{\"id_empleado\": \"12345678\"}', 'MODIFICAR user_system', 'UPDATE user_system id_empleado=12345678', '{\"id_ai_user\": 1, \"id_empleado\": \"12345678\", \"username\": \"administrador\", \"password\": \"***\", \"tipo\": 5, \"std_reg\": 1}', '{\"id_ai_user\": 1, \"id_empleado\": \"12345678\", \"username\": \"administrador\", \"password\": \"***\", \"tipo\": 5, \"std_reg\": 1}', '{\"password\": \"CHANGED\"}', '2026-03-16 15:16:04', 202, 'u_app@localhost', 'localhost', 'password', 1),
(75, '038d9dbb-214c-11f1-968b-989096ab40dc', NULL, 'user_system', 'UPDATE', 'id_empleado=12345678', '{\"id_empleado\": \"12345678\"}', 'MODIFICAR user_system', 'UPDATE user_system id_empleado=12345678', '{\"id_ai_user\": 1, \"id_empleado\": \"12345678\", \"username\": \"administrador\", \"password\": \"***\", \"tipo\": 5, \"std_reg\": 1}', '{\"id_ai_user\": 1, \"id_empleado\": \"12345678\", \"username\": \"administrador\", \"password\": \"***\", \"tipo\": 5, \"std_reg\": 1}', '{\"password\": \"CHANGED\"}', '2026-03-16 15:22:54', 204, 'u_app@localhost', 'localhost', 'password', 1),
(76, '58b6580d-214c-11f1-968b-989096ab40dc', '000000', 'user_system', 'UPDATE', 'id_empleado=12345678', '{\"id_empleado\": \"12345678\"}', 'MODIFICAR user_system', 'UPDATE user_system id_empleado=12345678', '{\"id_ai_user\": 1, \"id_empleado\": \"12345678\", \"username\": \"administrador\", \"password\": \"***\", \"tipo\": 5, \"std_reg\": 1}', '{\"id_ai_user\": 1, \"id_empleado\": \"12345678\", \"username\": \"administrador\", \"password\": \"***\", \"tipo\": 5, \"std_reg\": 1}', '{\"password\": \"CHANGED\"}', '2026-03-16 15:25:17', 206, 'u_app@localhost', 'localhost', 'password', 1),
(77, '82d6d348-214d-11f1-968b-989096ab40dc', '000000', 'user_system', 'UPDATE', 'id_empleado=12345678', '{\"id_empleado\": \"12345678\"}', 'MODIFICAR user_system', 'UPDATE user_system id_empleado=12345678', '{\"id_ai_user\": 1, \"id_empleado\": \"12345678\", \"username\": \"administrador\", \"password\": \"***\", \"tipo\": 5, \"std_reg\": 1}', '{\"id_ai_user\": 1, \"id_empleado\": \"12345678\", \"username\": \"administrador\", \"password\": \"***\", \"tipo\": 5, \"std_reg\": 1}', '{\"password\": \"CHANGED\"}', '2026-03-16 15:33:37', 208, 'u_app@localhost', 'localhost', 'password', 1),
(79, '651d7554-214e-11f1-968b-989096ab40dc', '000000', 'user_system', 'UPDATE', 'id_empleado=12345678', '{\"id_empleado\": \"12345678\"}', 'MODIFICAR user_system', 'UPDATE user_system id_empleado=12345678', '{\"id_ai_user\": 1, \"id_empleado\": \"12345678\", \"username\": \"administrador\", \"password\": \"***\", \"tipo\": 5, \"std_reg\": 1}', '{\"id_ai_user\": 1, \"id_empleado\": \"12345678\", \"username\": \"administrador\", \"password\": \"***\", \"tipo\": 5, \"std_reg\": 1}', '{\"password\": \"CHANGED\"}', '2026-03-16 15:39:56', 214, 'u_app@localhost', 'localhost', 'password', 1),
(80, 'b2b72274-214e-11f1-968b-989096ab40dc', '000000', 'user_system', 'UPDATE', 'id_empleado=12345678', '{\"id_empleado\": \"12345678\"}', 'MODIFICAR user_system', 'UPDATE user_system id_empleado=12345678', '{\"id_ai_user\": 1, \"id_empleado\": \"12345678\", \"username\": \"administrador\", \"password\": \"***\", \"tipo\": 5, \"std_reg\": 1}', '{\"id_ai_user\": 1, \"id_empleado\": \"12345678\", \"username\": \"administrador\", \"password\": \"***\", \"tipo\": 5, \"std_reg\": 1}', '{\"password\": \"CHANGED\"}', '2026-03-16 15:42:07', 216, 'u_app@localhost', 'localhost', 'password', 1),
(81, 'bc0ecae0-214f-11f1-968b-989096ab40dc', '000000', 'user_system', 'UPDATE', 'id_empleado=12345678', '{\"id_empleado\": \"12345678\"}', 'MODIFICAR user_system', 'UPDATE user_system id_empleado=12345678', '{\"id_ai_user\": 1, \"id_empleado\": \"12345678\", \"username\": \"administrador\", \"password\": \"***\", \"tipo\": 5, \"std_reg\": 1}', '{\"id_ai_user\": 1, \"id_empleado\": \"12345678\", \"username\": \"administrador\", \"password\": \"***\", \"tipo\": 5, \"std_reg\": 1}', '{\"password\": \"CHANGED\"}', '2026-03-16 15:49:32', 218, 'u_app@localhost', 'localhost', 'password', 1);

--
-- Disparadores `log_user`
--
DELIMITER $$
CREATE TRIGGER `trg_log_user_no_delete` BEFORE DELETE ON `log_user` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite eliminar registros de auditoría (log_user).'
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_log_user_no_update` BEFORE UPDATE ON `log_user` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite modificar registros de auditoría (log_user).'
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `miembro`
--

CREATE TABLE `miembro` (
  `id_ai_miembro` int(11) NOT NULL COMMENT 'id autoincrementable',
  `id_miembro` varchar(10) NOT NULL COMMENT 'Identificador único del miembro',
  `nombre_miembro` varchar(40) NOT NULL COMMENT 'Nombre completo del miembro',
  `tipo_miembro` int(11) NOT NULL COMMENT 'Tipo de miembro (por ejemplo, CCO, CCF, etc.)',
  `std_reg` tinyint(1) NOT NULL COMMENT 'Estado lógico del registro (1=activo, 0=inactivo/eliminado lógico).'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `miembro`
--

INSERT INTO `miembro` (`id_ai_miembro`, `id_miembro`, `nombre_miembro`, `tipo_miembro`, `std_reg`) VALUES
(2, 'M-001', 'PEDRO PEREZ', 2, 1),
(3, 'M-003', 'Eduardo Carmona', 1, 0),
(5, 'E-M-002', 'ADMINISTRADOR SISTEMA', 1, 0),
(6, 'M-005', 'alejandro', 1, 1),
(7, 'M-006', 'MIEMBRO 006', 1, 1),
(8, 'M-007', 'MIEMBRO 007', 2, 1),
(9, 'M-008', 'MIEMBRO 008', 1, 1),
(10, 'M-009', 'MIEMBRO 009', 2, 1),
(11, 'M-010', 'MIEMBRO 010', 1, 1),
(12, 'M-011', 'MIEMBRO 011', 2, 1),
(13, 'M-012', 'MIEMBRO 012', 1, 1),
(14, 'M-013', 'MIEMBRO 013', 2, 1),
(15, 'M-014', 'MIEMBRO 014', 1, 1),
(16, 'M-015', 'MIEMBRO 015', 2, 1),
(17, 'M-016', 'MIEMBRO 016', 1, 1),
(18, 'M-017', 'MIEMBRO 017', 2, 1),
(19, 'M-018', 'MIEMBRO 018', 1, 1),
(20, 'M-019', 'MIEMBRO 019', 2, 1),
(21, 'M-020', 'MIEMBRO 020', 1, 1),
(22, 'M-021', 'MIEMBRO 021', 2, 1),
(23, 'M-022', 'MIEMBRO 022', 1, 1),
(24, 'M-023', 'MIEMBRO 023', 2, 1),
(25, 'M-024', 'MIEMBRO 024', 1, 1),
(26, 'M-025', 'MIEMBRO 025', 2, 1),
(27, 'M-055', 'ADMINISTRADOR', 1, 1);

--
-- Disparadores `miembro`
--
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
DELIMITER $$
CREATE TRIGGER `trg_miembro_bd` BEFORE DELETE ON `miembro` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE físico en miembro. Use eliminación lógica (UPDATE miembro SET std_reg=0 ...).'
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `orden_trabajo`
--

CREATE TABLE `orden_trabajo` (
  `id_ai_ot` int(11) NOT NULL COMMENT 'id autoincrementable',
  `n_ot` varchar(30) NOT NULL COMMENT 'Número único de la orden de trabajo',
  `id_ai_area` int(11) NOT NULL COMMENT 'Área de trabajo responsable de la orden',
  `id_user` varchar(30) NOT NULL COMMENT 'Identificador único del usuario del sistema',
  `id_ai_sitio` int(11) NOT NULL COMMENT 'Identificador único del sitio de trabajo',
  `nombre_trab` varchar(500) NOT NULL COMMENT 'Descripción o nombre del trabajo a realizar',
  `fecha` date NOT NULL COMMENT 'Fecha programada de la orden de trabajo',
  `semana` varchar(100) NOT NULL COMMENT 'Semana del año correspondiente a la orden',
  `mes` varchar(100) NOT NULL COMMENT 'Mes correspondiente a la orden de trabajo',
  `std_reg` tinyint(1) NOT NULL COMMENT 'Estado lógico del registro (1=activo, 0=inactivo/eliminado lógico).'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `orden_trabajo`
--

INSERT INTO `orden_trabajo` (`id_ai_ot`, `n_ot`, `id_ai_area`, `id_user`, `id_ai_sitio`, `nombre_trab`, `fecha`, `semana`, `mes`, `std_reg`) VALUES
(1, 'VF-SEÑ-01', 1, '000000', 1, 'MANTENIMIENTO DE DURMIENTES ÁREA PATIO', '2026-01-09', '2', '1', 1),
(2, 'VF-SEÑ-02', 1, '000000', 1, 'TRABAJO PRUEBA VF-SEÑ-02 (AREA 1)', '2026-02-11', '7', '2', 1),
(3, 'VF-SEÑ-03', 1, '12345678', 2, 'TRABAJO PRUEBA VF-SEÑ-03 (AREA 1)', '2026-02-12', '7', '2', 1),
(4, 'VF-SEÑ-04', 1, '000000', 1, 'TRABAJO PRUEBA VF-SEÑ-04 (AREA 1)', '2026-02-13', '7', '2', 1),
(5, 'VF-SEÑ-05', 1, '12345678', 2, 'TRABAJO PRUEBA VF-SEÑ-05 (AREA 1)', '2026-02-14', '7', '2', 1),
(6, 'VF-SEÑ-06', 1, '000000', 1, 'TRABAJO PRUEBA VF-SEÑ-06 (AREA 1)', '2026-02-15', '7', '2', 1),
(7, 'VF-APV-01', 2, '12345678', 2, 'TRABAJO PRUEBA VF-APV-01 (AREA 2)', '2026-03-13', '11', '3', 1),
(8, 'VF-APV-02', 2, '000000', 1, 'TRABAJO PRUEBA VF-APV-02 (AREA 2)', '2026-02-17', '8', '2', 1),
(9, 'VF-APV-03', 2, '12345678', 2, 'TRABAJO PRUEBA VF-APV-03 (AREA 2)', '2026-02-18', '8', '2', 1),
(10, 'VF-APV-04', 2, '000000', 1, 'TRABAJO PRUEBA VF-APV-04 (AREA 2)', '2026-02-19', '8', '2', 1),
(11, 'VF-APV-05', 2, '12345678', 2, 'TRABAJO PRUEBA VF-APV-05 (AREA 2)', '2026-02-20', '8', '2', 1),
(12, 'VF-INF-01', 3, '000000', 1, 'TRABAJO PRUEBA VF-INF-01 (AREA 3)', '2026-02-21', '8', '2', 1),
(13, 'VF-INF-02', 3, '12345678', 2, 'TRABAJO PRUEBA VF-INF-02 (AREA 3)', '2026-02-22', '8', '2', 1),
(14, 'VF-INF-03', 3, '000000', 1, 'TRABAJO PRUEBA VF-INF-03 (AREA 3)', '2026-02-23', '9', '2', 1),
(15, 'VF-INF-04', 3, '12345678', 2, 'TRABAJO PRUEBA VF-INF-04 (AREA 3)', '2026-02-24', '9', '2', 1),
(16, 'VF-INF-05', 3, '000000', 1, 'TRABAJO PRUEBA VF-INF-05 (AREA 3)', '2026-02-25', '9', '2', 1),
(17, 'VF-NP-01', 5, '12345678', 2, 'TRABAJO PRUEBA VF-NP-01 (AREA 5)', '2026-02-26', '9', '2', 1),
(18, 'VF-NP-02', 5, '000000', 1, 'TRABAJO PRUEBA VF-NP-02 (AREA 5)', '2026-02-27', '9', '2', 1),
(19, 'VF-NP-03', 5, '12345678', 2, 'TRABAJO PRUEBA VF-NP-03 (AREA 5)', '2026-02-28', '9', '2', 1),
(20, 'VF-NP-04', 5, '000000', 1, 'TRABAJO PRUEBA VF-NP-04 (AREA 5)', '2026-03-01', '9', '3', 1),
(21, 'VF-NP-05', 5, '12345678', 2, 'TRABAJO PRUEBA VF-NP-05 (AREA 5)', '2026-03-02', '10', '3', 1),
(22, 'VF-APV-025', 2, '000000', 1, 'TRABAJO DE PRUEBA', '2026-02-18', '7', '2', 1),
(23, 'VF-SEÑ-07', 1, '000000', 2, 'MANTENIMINETO DE VIAS', '2026-02-12', '1', '2', 1),
(24, 'VF-SEÑ-08', 1, '000000', 1, 'MANTENIMINETO DE VIAS1', '2026-02-12', '1', '2', 1),
(30, 'VF-SEÑ-09', 1, '000000', 1, 'MANTENIMINETO DE VIAS', '2026-02-12', '7', '2', 1);

--
-- Disparadores `orden_trabajo`
--
DELIMITER $$
CREATE TRIGGER `trg_orden_trabajo_ai` AFTER INSERT ON `orden_trabajo` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
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
)
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_orden_trabajo_au` AFTER UPDATE ON `orden_trabajo` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
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
)
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_orden_trabajo_bd` BEFORE DELETE ON `orden_trabajo` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE físico en orden_trabajo. Use eliminación lógica (UPDATE orden_trabajo SET std_reg=0 ...).'
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `reporte_generado`
--

CREATE TABLE `reporte_generado` (
  `id_ai_reporte_generado` int(10) UNSIGNED NOT NULL COMMENT 'Id autoincrementable del reporte generado',
  `tipo_reporte` varchar(50) NOT NULL COMMENT 'Codigo o tipo funcional del reporte generado',
  `titulo_reporte` varchar(150) NOT NULL COMMENT 'Titulo descriptivo mostrado al usuario para el reporte',
  `nombre_archivo` varchar(255) NOT NULL COMMENT 'Nombre final del archivo PDF generado',
  `ruta_archivo` varchar(255) NOT NULL COMMENT 'Ruta relativa o absoluta donde se almacena el PDF generado',
  `mime_type` varchar(100) NOT NULL DEFAULT 'application/pdf' COMMENT 'Tipo MIME del archivo generado',
  `tamano_bytes` bigint(20) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Tamano del archivo generado expresado en bytes',
  `parametros_json` longtext DEFAULT NULL COMMENT 'Parametros de entrada usados para construir el reporte',
  `id_user_generador` varchar(30) NOT NULL COMMENT 'Identificador del usuario que genero el reporte',
  `nombre_user_generador` varchar(150) NOT NULL COMMENT 'Nombre visible del usuario que genero el reporte',
  `username_generador` varchar(60) NOT NULL COMMENT 'Nombre de acceso del usuario que genero el reporte',
  `created_at` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Fecha y hora de generacion del reporte',
  `std_reg` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Estado logico del registro (1=activo, 0=inactivo).'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `reporte_generado`
--

INSERT INTO `reporte_generado` (`id_ai_reporte_generado`, `tipo_reporte`, `titulo_reporte`, `nombre_archivo`, `ruta_archivo`, `mime_type`, `tamano_bytes`, `parametros_json`, `id_user_generador`, `nombre_user_generador`, `username_generador`, `created_at`, `std_reg`) VALUES
(1, 'ot_resumen', 'Reporte OT (Resumen)', 'reporte_ot_resumen_20260315_133527.pdf', 'storage/reportes_generados/2026/03/reporte_ot_resumen_ot_resumen_20260315_133527_e95a29f7.pdf', 'application/pdf', 125171, '{\"tipo\":\"ot_resumen\",\"papel\":\"A4\",\"orientacion\":\"portrait\",\"membrete\":1,\"logo\":1,\"filtros\":{\"n_ot\":\"\",\"desde\":\"\",\"hasta\":\"\",\"area\":\"\",\"sitio\":\"\",\"estado\":\"\",\"usuario\":\"\",\"q\":\"\"}}', '000000', 'USUARIO SISTEMA', 'admin', '2026-03-15 13:35:28', 1);

--
-- Disparadores `reporte_generado`
--
DELIMITER $$
CREATE TRIGGER `trg_reporte_generado_ai` AFTER INSERT ON `reporte_generado` FOR EACH ROW INSERT INTO `log_user`(
    `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
    `accion`,`resp_system`,`data_old`,`data_new`,`data_diff`,`changed_cols`,
    `connection_id`,`db_user`,`db_host`
) VALUES (
    UUID(),
    (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
    'reporte_generado',
    'INSERT',
    CONCAT('id_ai_reporte_generado=', NEW.`id_ai_reporte_generado`),
    JSON_OBJECT('id_ai_reporte_generado', NEW.`id_ai_reporte_generado`),
    'CREAR reporte_generado',
    CONCAT('INSERT reporte_generado ', CONCAT('id_ai_reporte_generado=', NEW.`id_ai_reporte_generado`)),
    NULL,
    JSON_OBJECT(
        'id_ai_reporte_generado', NEW.`id_ai_reporte_generado`,
        'tipo_reporte', NEW.`tipo_reporte`,
        'titulo_reporte', NEW.`titulo_reporte`,
        'nombre_archivo', NEW.`nombre_archivo`,
        'ruta_archivo', NEW.`ruta_archivo`,
        'mime_type', NEW.`mime_type`,
        'tamano_bytes', NEW.`tamano_bytes`,
        'parametros_json', NEW.`parametros_json`,
        'id_user_generador', NEW.`id_user_generador`,
        'nombre_user_generador', NEW.`nombre_user_generador`,
        'username_generador', NEW.`username_generador`,
        'created_at', NEW.`created_at`,
        'std_reg', NEW.`std_reg`
    ),
    JSON_OBJECT(
        'id_ai_reporte_generado', NEW.`id_ai_reporte_generado`,
        'tipo_reporte', NEW.`tipo_reporte`,
        'titulo_reporte', NEW.`titulo_reporte`,
        'nombre_archivo', NEW.`nombre_archivo`,
        'ruta_archivo', NEW.`ruta_archivo`,
        'mime_type', NEW.`mime_type`,
        'tamano_bytes', NEW.`tamano_bytes`,
        'parametros_json', NEW.`parametros_json`,
        'id_user_generador', NEW.`id_user_generador`,
        'nombre_user_generador', NEW.`nombre_user_generador`,
        'username_generador', NEW.`username_generador`,
        'created_at', NEW.`created_at`,
        'std_reg', NEW.`std_reg`
    ),
    'id_ai_reporte_generado,tipo_reporte,titulo_reporte,nombre_archivo,ruta_archivo,mime_type,tamano_bytes,parametros_json,id_user_generador,nombre_user_generador,username_generador,created_at,std_reg',
    CONNECTION_ID(),
    USER(),
    SUBSTRING_INDEX(USER(),'@',-1)
)
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_reporte_generado_au` AFTER UPDATE ON `reporte_generado` FOR EACH ROW INSERT INTO `log_user`(
    `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
    `accion`,`resp_system`,`data_old`,`data_new`,`data_diff`,`changed_cols`,
    `connection_id`,`db_user`,`db_host`
) VALUES (
    UUID(),
    (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
    'reporte_generado',
    CASE
        WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN 'SOFT_DELETE'
        WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN 'RESTORE'
        ELSE 'UPDATE'
    END,
    CONCAT('id_ai_reporte_generado=', NEW.`id_ai_reporte_generado`),
    JSON_OBJECT('id_ai_reporte_generado', NEW.`id_ai_reporte_generado`),
    CASE
        WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN 'ELIMINAR (LOGICO) reporte_generado'
        WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN 'REACTIVAR reporte_generado'
        ELSE 'MODIFICAR reporte_generado'
    END,
    CASE
        WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN CONCAT('SOFT_DELETE reporte_generado ', CONCAT('id_ai_reporte_generado=', NEW.`id_ai_reporte_generado`))
        WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN CONCAT('RESTORE reporte_generado ', CONCAT('id_ai_reporte_generado=', NEW.`id_ai_reporte_generado`))
        ELSE CONCAT('UPDATE reporte_generado ', CONCAT('id_ai_reporte_generado=', NEW.`id_ai_reporte_generado`))
    END,
    JSON_OBJECT(
        'id_ai_reporte_generado', OLD.`id_ai_reporte_generado`,
        'tipo_reporte', OLD.`tipo_reporte`,
        'titulo_reporte', OLD.`titulo_reporte`,
        'nombre_archivo', OLD.`nombre_archivo`,
        'ruta_archivo', OLD.`ruta_archivo`,
        'mime_type', OLD.`mime_type`,
        'tamano_bytes', OLD.`tamano_bytes`,
        'parametros_json', OLD.`parametros_json`,
        'id_user_generador', OLD.`id_user_generador`,
        'nombre_user_generador', OLD.`nombre_user_generador`,
        'username_generador', OLD.`username_generador`,
        'created_at', OLD.`created_at`,
        'std_reg', OLD.`std_reg`
    ),
    JSON_OBJECT(
        'id_ai_reporte_generado', NEW.`id_ai_reporte_generado`,
        'tipo_reporte', NEW.`tipo_reporte`,
        'titulo_reporte', NEW.`titulo_reporte`,
        'nombre_archivo', NEW.`nombre_archivo`,
        'ruta_archivo', NEW.`ruta_archivo`,
        'mime_type', NEW.`mime_type`,
        'tamano_bytes', NEW.`tamano_bytes`,
        'parametros_json', NEW.`parametros_json`,
        'id_user_generador', NEW.`id_user_generador`,
        'nombre_user_generador', NEW.`nombre_user_generador`,
        'username_generador', NEW.`username_generador`,
        'created_at', NEW.`created_at`,
        'std_reg', NEW.`std_reg`
    ),
    JSON_OBJECT(
        'changed_cols', NULLIF(CONCAT_WS(',',
            IF(NOT (OLD.`id_ai_reporte_generado` <=> NEW.`id_ai_reporte_generado`), 'id_ai_reporte_generado', NULL),
            IF(NOT (OLD.`tipo_reporte` <=> NEW.`tipo_reporte`), 'tipo_reporte', NULL),
            IF(NOT (OLD.`titulo_reporte` <=> NEW.`titulo_reporte`), 'titulo_reporte', NULL),
            IF(NOT (OLD.`nombre_archivo` <=> NEW.`nombre_archivo`), 'nombre_archivo', NULL),
            IF(NOT (OLD.`ruta_archivo` <=> NEW.`ruta_archivo`), 'ruta_archivo', NULL),
            IF(NOT (OLD.`mime_type` <=> NEW.`mime_type`), 'mime_type', NULL),
            IF(NOT (OLD.`tamano_bytes` <=> NEW.`tamano_bytes`), 'tamano_bytes', NULL),
            IF(NOT (OLD.`parametros_json` <=> NEW.`parametros_json`), 'parametros_json', NULL),
            IF(NOT (OLD.`id_user_generador` <=> NEW.`id_user_generador`), 'id_user_generador', NULL),
            IF(NOT (OLD.`nombre_user_generador` <=> NEW.`nombre_user_generador`), 'nombre_user_generador', NULL),
            IF(NOT (OLD.`username_generador` <=> NEW.`username_generador`), 'username_generador', NULL),
            IF(NOT (OLD.`created_at` <=> NEW.`created_at`), 'created_at', NULL),
            IF(NOT (OLD.`std_reg` <=> NEW.`std_reg`), 'std_reg', NULL)
        ), '')
    ),
    NULLIF(CONCAT_WS(',',
        IF(NOT (OLD.`id_ai_reporte_generado` <=> NEW.`id_ai_reporte_generado`), 'id_ai_reporte_generado', NULL),
        IF(NOT (OLD.`tipo_reporte` <=> NEW.`tipo_reporte`), 'tipo_reporte', NULL),
        IF(NOT (OLD.`titulo_reporte` <=> NEW.`titulo_reporte`), 'titulo_reporte', NULL),
        IF(NOT (OLD.`nombre_archivo` <=> NEW.`nombre_archivo`), 'nombre_archivo', NULL),
        IF(NOT (OLD.`ruta_archivo` <=> NEW.`ruta_archivo`), 'ruta_archivo', NULL),
        IF(NOT (OLD.`mime_type` <=> NEW.`mime_type`), 'mime_type', NULL),
        IF(NOT (OLD.`tamano_bytes` <=> NEW.`tamano_bytes`), 'tamano_bytes', NULL),
        IF(NOT (OLD.`parametros_json` <=> NEW.`parametros_json`), 'parametros_json', NULL),
        IF(NOT (OLD.`id_user_generador` <=> NEW.`id_user_generador`), 'id_user_generador', NULL),
        IF(NOT (OLD.`nombre_user_generador` <=> NEW.`nombre_user_generador`), 'nombre_user_generador', NULL),
        IF(NOT (OLD.`username_generador` <=> NEW.`username_generador`), 'username_generador', NULL),
        IF(NOT (OLD.`created_at` <=> NEW.`created_at`), 'created_at', NULL),
        IF(NOT (OLD.`std_reg` <=> NEW.`std_reg`), 'std_reg', NULL)
    ), ''),
    CONNECTION_ID(),
    USER(),
    SUBSTRING_INDEX(USER(),'@',-1)
)
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_reporte_generado_bd` BEFORE DELETE ON `reporte_generado` FOR EACH ROW SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'No se permite DELETE fisico en reporte_generado. Use eliminacion logica (UPDATE reporte_generado SET std_reg=0 ...).'
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `roles_permisos`
--

CREATE TABLE `roles_permisos` (
  `id` int(11) NOT NULL COMMENT 'id autoincrementable',
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
  `perm_ot_add_herramienta` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Permiso para asociar herramientas a órdenes de trabajo'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `roles_permisos`
--

INSERT INTO `roles_permisos` (`id`, `nombre_rol`, `perm_usuarios_view`, `perm_usuarios_add`, `perm_usuarios_edit`, `perm_usuarios_delete`, `perm_herramienta_view`, `perm_herramienta_add`, `perm_herramienta_edit`, `perm_herramienta_delete`, `perm_miembro_view`, `perm_miembro_add`, `perm_miembro_edit`, `perm_miembro_delete`, `perm_ot_view`, `perm_ot_add`, `perm_ot_edit`, `perm_ot_delete`, `perm_ot_add_detalle`, `perm_ot_generar_reporte`, `perm_ot_add_herramienta`) VALUES
(1, 'ROOT', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(5, 'ADMINISTRADOR', 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
(17, 'PRUEBA', 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1);

--
-- Disparadores `roles_permisos`
--
DELIMITER $$
CREATE TRIGGER `trg_roles_permisos_ad` AFTER DELETE ON `roles_permisos` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
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
)
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_roles_permisos_ai` AFTER INSERT ON `roles_permisos` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
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
)
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_roles_permisos_au` AFTER UPDATE ON `roles_permisos` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
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
)
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sitio_trabajo`
--

CREATE TABLE `sitio_trabajo` (
  `id_ai_sitio` int(11) NOT NULL COMMENT 'id autoincrementable',
  `nombre_sitio` varchar(100) NOT NULL COMMENT 'Nombre del sitio o ubicación de trabajo',
  `std_reg` tinyint(1) NOT NULL COMMENT 'Estado lógico del registro (1=activo, 0=inactivo/eliminado lógico).'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `sitio_trabajo`
--

INSERT INTO `sitio_trabajo` (`id_ai_sitio`, `nombre_sitio`, `std_reg`) VALUES
(1, 'PATIO', 1),
(2, 'LINEA', 1),
(10, 'PRUEBA SITIO', 0),
(11, 'PRUEBA SITIO', 1),
(12, 'DDGDG', 0),
(13, 'NOMINA1', 0);

--
-- Disparadores `sitio_trabajo`
--
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
DELIMITER $$
CREATE TRIGGER `trg_sitio_trabajo_bd` BEFORE DELETE ON `sitio_trabajo` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE físico en sitio_trabajo. Use eliminación lógica (UPDATE sitio_trabajo SET std_reg=0 ...).'
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `smtp_config`
--

CREATE TABLE `smtp_config` (
  `id` int(11) NOT NULL,
  `enabled` tinyint(1) NOT NULL DEFAULT 0 COMMENT '1=habilitado, 0=deshabilitado',
  `provider` varchar(30) NOT NULL DEFAULT 'google' COMMENT 'Proveedor (ej: google)',
  `host` varchar(255) NOT NULL DEFAULT 'smtp.gmail.com' COMMENT 'Servidor SMTP',
  `port` int(11) NOT NULL DEFAULT 587 COMMENT 'Puerto SMTP (587 STARTTLS, 465 SSL)',
  `encryption` enum('tls','ssl','none') NOT NULL DEFAULT 'tls' COMMENT 'Metodo de cifrado',
  `username` varchar(255) NOT NULL DEFAULT '' COMMENT 'Usuario/correo SMTP',
  `password` varchar(255) NOT NULL DEFAULT '' COMMENT 'Clave o App Password',
  `from_email` varchar(255) NOT NULL DEFAULT '' COMMENT 'Remitente (From)',
  `from_name` varchar(255) DEFAULT NULL COMMENT 'Nombre remitente',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `smtp_config`
--

INSERT INTO `smtp_config` (`id`, `enabled`, `provider`, `host`, `port`, `encryption`, `username`, `password`, `from_email`, `from_name`, `created_at`, `updated_at`) VALUES
(1, 1, 'google', 'smtp.gmail.com', 587, 'tls', 'aliguerrerodev@gmail.com', 'gcm:0PcNOJmDgi8C/lqWWxyLBiHV63Y/fqJMXC2PgqRyBxMHjmhUVB3Ma+r/GU4=', 'aliguerrerodev@gmail.com', 'FerreNet System', '2026-03-16 14:17:18', '2026-03-16 14:46:38');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `turno_trabajo`
--

CREATE TABLE `turno_trabajo` (
  `id_ai_turno` int(11) NOT NULL COMMENT 'id autoincrementable',
  `nombre_turno` varchar(100) NOT NULL COMMENT 'Nombre descriptivo del turno de trabajo',
  `std_reg` tinyint(1) NOT NULL COMMENT 'Estado lógico del registro (1=activo, 0=inactivo/eliminado lógico).'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `turno_trabajo`
--

INSERT INTO `turno_trabajo` (`id_ai_turno`, `nombre_turno`, `std_reg`) VALUES
(1, 'MAÑANA', 1),
(2, 'TARDE', 1),
(3, 'NOCHE', 1),
(4, 'MEDIA-NOCHE', 1),
(6, 'PRUEBA TUERNO', 0),
(7, 'PRUEBA TURNO', 0),
(8, 'MEDIO-DIA1', 0),
(9, 'MEDA-NOCHE', 0);

--
-- Disparadores `turno_trabajo`
--
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
DELIMITER $$
CREATE TRIGGER `trg_turno_trabajo_bd` BEFORE DELETE ON `turno_trabajo` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE físico en turno_trabajo. Use eliminación lógica (UPDATE turno_trabajo SET std_reg=0 ...).'
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `user_system`
--

CREATE TABLE `user_system` (
  `id_ai_user` int(11) NOT NULL COMMENT 'id autoincrementable',
  `id_empleado` varchar(30) NOT NULL COMMENT 'Identificador del empleado asociado al usuario del sistema',
  `username` varchar(50) NOT NULL COMMENT 'Nombre de usuario utilizado para iniciar sesión',
  `password` varchar(60) NOT NULL COMMENT 'Contraseña encriptada del usuario',
  `tipo` int(11) NOT NULL COMMENT 'Rol o perfil de permisos asociado al usuario',
  `std_reg` tinyint(1) NOT NULL COMMENT 'Estado lógico del registro (1=activo, 0=inactivo/eliminado lógico).'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Volcado de datos para la tabla `user_system`
--

INSERT INTO `user_system` (`id_ai_user`, `id_empleado`, `username`, `password`, `tipo`, `std_reg`) VALUES
(1, '12345678', 'administrador', '$2y$10$4XbvzXDX8rqEcvTEFytGsOjjKT5JiWaCOCO74J0dRda7gRsEU0vAW', 5, 1),
(2, '000000', 'admin', '$2y$10$zj.SJ/wXBW0Ofh1F3kynoO/0SN2C.KxZIA3e2qD1h4IstUVDAqR0q', 1, 1),
(4, '26580187', 'prueba', '$2y$10$pRFd8LlDu5WVnACktZBFZuv47EuR2nsxx1qvLVdEKJoQBLtMfT0ku', 17, 1);

--
-- Disparadores `user_system`
--
DELIMITER $$
CREATE TRIGGER `trg_user_system_ai` AFTER INSERT ON `user_system` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
  'user_system',
  'INSERT',
  CONCAT('id_empleado=', NEW.`id_empleado`),
  JSON_OBJECT('id_empleado', NEW.`id_empleado`),
  CONCAT('CREAR ', 'user_system'),
  CONCAT('INSERT user_system ', CONCAT('id_empleado=', NEW.`id_empleado`)),
  NULL,
  JSON_OBJECT('id_ai_user', NEW.`id_ai_user`, 'id_empleado', NEW.`id_empleado`, 'username', NEW.`username`, 'password', '***', 'tipo', NEW.`tipo`, 'std_reg', NEW.`std_reg`),
  JSON_OBJECT('id_ai_user', NEW.`id_ai_user`, 'id_empleado', NEW.`id_empleado`, 'username', NEW.`username`, 'password', '***', 'tipo', NEW.`tipo`, 'std_reg', NEW.`std_reg`),
  'id_ai_user,id_empleado,username,password,tipo,std_reg',
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_user_system_au` AFTER UPDATE ON `user_system` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
  'user_system',
  CASE WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN 'SOFT_DELETE' WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN 'RESTORE' ELSE 'UPDATE' END,
  CONCAT('id_empleado=', NEW.`id_empleado`),
  JSON_OBJECT('id_empleado', NEW.`id_empleado`),
  CASE WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN CONCAT('ELIMINAR (LOGICO) ', 'user_system') WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN CONCAT('REACTIVAR ', 'user_system') ELSE CONCAT('MODIFICAR ', 'user_system') END,
  CASE WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN CONCAT('SOFT_DELETE user_system ', CONCAT('id_empleado=', NEW.`id_empleado`)) WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN CONCAT('RESTORE user_system ', CONCAT('id_empleado=', NEW.`id_empleado`)) ELSE CONCAT('UPDATE user_system ', CONCAT('id_empleado=', NEW.`id_empleado`)) END,
  JSON_OBJECT('id_ai_user', OLD.`id_ai_user`, 'id_empleado', OLD.`id_empleado`, 'username', OLD.`username`, 'password', '***', 'tipo', OLD.`tipo`, 'std_reg', OLD.`std_reg`),
  JSON_OBJECT('id_ai_user', NEW.`id_ai_user`, 'id_empleado', NEW.`id_empleado`, 'username', NEW.`username`, 'password', '***', 'tipo', NEW.`tipo`, 'std_reg', NEW.`std_reg`),
  JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_OBJECT(), IF(NOT (OLD.`id_ai_user` <=> NEW.`id_ai_user`), JSON_OBJECT('id_ai_user', JSON_ARRAY(OLD.`id_ai_user`, NEW.`id_ai_user`)), JSON_OBJECT())), IF(NOT (OLD.`id_empleado` <=> NEW.`id_empleado`), JSON_OBJECT('id_empleado', JSON_ARRAY(OLD.`id_empleado`, NEW.`id_empleado`)), JSON_OBJECT())), IF(NOT (OLD.`username` <=> NEW.`username`), JSON_OBJECT('username', JSON_ARRAY(OLD.`username`, NEW.`username`)), JSON_OBJECT())), IF(NOT (OLD.`password` <=> NEW.`password`), JSON_OBJECT('password', 'CHANGED'), JSON_OBJECT())), IF(NOT (OLD.`tipo` <=> NEW.`tipo`), JSON_OBJECT('tipo', JSON_ARRAY(OLD.`tipo`, NEW.`tipo`)), JSON_OBJECT())), IF(NOT (OLD.`std_reg` <=> NEW.`std_reg`), JSON_OBJECT('std_reg', JSON_ARRAY(OLD.`std_reg`, NEW.`std_reg`)), JSON_OBJECT())),
  NULLIF(CONCAT_WS(',', IF(NOT (OLD.`id_ai_user` <=> NEW.`id_ai_user`), 'id_ai_user', NULL), IF(NOT (OLD.`id_empleado` <=> NEW.`id_empleado`), 'id_empleado', NULL), IF(NOT (OLD.`username` <=> NEW.`username`), 'username', NULL), IF(NOT (OLD.`password` <=> NEW.`password`), 'password', NULL), IF(NOT (OLD.`tipo` <=> NEW.`tipo`), 'tipo', NULL), IF(NOT (OLD.`std_reg` <=> NEW.`std_reg`), 'std_reg', NULL)), ''),
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_user_system_bd` BEFORE DELETE ON `user_system` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE fisico en user_system. Use eliminacion logica (UPDATE user_system SET std_reg=0 ...).'
$$
DELIMITER ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `area_trabajo`
--
ALTER TABLE `area_trabajo`
  ADD PRIMARY KEY (`id_ai_area`),
  ADD UNIQUE KEY `nomeclatura` (`nomeclatura`);

--
-- Indices de la tabla `categoria_empleado`
--
ALTER TABLE `categoria_empleado`
  ADD PRIMARY KEY (`id_ai_categoria_empleado`),
  ADD UNIQUE KEY `uk_categoria_empleado_nombre` (`nombre_categoria`);

--
-- Indices de la tabla `categoria_herramienta`
--
ALTER TABLE `categoria_herramienta`
  ADD PRIMARY KEY (`id_ai_categoria_herramienta`),
  ADD KEY `idx_categoria_herramienta_nombre` (`nombre_categoria`),
  ADD KEY `idx_categoria_herramienta_std_reg` (`std_reg`);

--
-- Indices de la tabla `detalle_orden`
--
ALTER TABLE `detalle_orden`
  ADD PRIMARY KEY (`id_ai_detalle`),
  ADD KEY `responsable_ccf` (`id_miembro_ccf`),
  ADD KEY `responsable_cco` (`id_miembro_cco`),
  ADD KEY `responsable_act` (`id_user_act`),
  ADD KEY `turno` (`id_ai_turno`),
  ADD KEY `status` (`id_ai_estado`),
  ADD KEY `n_ot` (`n_ot`);

--
-- Indices de la tabla `empleado`
--
ALTER TABLE `empleado`
  ADD PRIMARY KEY (`id_ai_empleado`),
  ADD UNIQUE KEY `uk_empleado_codigo` (`id_empleado`),
  ADD KEY `idx_empleado_categoria` (`id_ai_categoria_empleado`);

--
-- Indices de la tabla `empresa_config`
--
ALTER TABLE `empresa_config`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `estado_ot`
--
ALTER TABLE `estado_ot`
  ADD PRIMARY KEY (`id_ai_estado`);

--
-- Indices de la tabla `herramienta`
--
ALTER TABLE `herramienta`
  ADD PRIMARY KEY (`id_ai_herramienta`),
  ADD KEY `idx_herramienta_categoria` (`id_ai_categoria_herramienta`);

--
-- Indices de la tabla `herramientaot`
--
ALTER TABLE `herramientaot`
  ADD PRIMARY KEY (`id_ai_herramientaOT`),
  ADD KEY `id_herramienta` (`id_ai_herramienta`),
  ADD KEY `n_ot` (`n_ot`);

--
-- Indices de la tabla `log_user`
--
ALTER TABLE `log_user`
  ADD PRIMARY KEY (`id_log`),
  ADD KEY `idx_log_id_user_fecha` (`id_user`,`fecha_hora`),
  ADD KEY `idx_log_tabla_fecha` (`tabla`,`fecha_hora`),
  ADD KEY `idx_log_event_uuid` (`event_uuid`),
  ADD KEY `idx_log_tabla_operacion_fecha` (`tabla`,`operacion`,`fecha_hora`);

--
-- Indices de la tabla `miembro`
--
ALTER TABLE `miembro`
  ADD PRIMARY KEY (`id_ai_miembro`),
  ADD UNIQUE KEY `id_miembro` (`id_miembro`);

--
-- Indices de la tabla `orden_trabajo`
--
ALTER TABLE `orden_trabajo`
  ADD PRIMARY KEY (`id_ai_ot`),
  ADD UNIQUE KEY `n_ot` (`n_ot`),
  ADD KEY `status` (`std_reg`),
  ADD KEY `id_user` (`id_user`),
  ADD KEY `sitio_trab` (`id_ai_sitio`),
  ADD KEY `id_area` (`id_ai_area`);

--
-- Indices de la tabla `reporte_generado`
--
ALTER TABLE `reporte_generado`
  ADD PRIMARY KEY (`id_ai_reporte_generado`),
  ADD KEY `idx_reporte_generado_fecha` (`created_at`),
  ADD KEY `idx_reporte_generado_tipo` (`tipo_reporte`),
  ADD KEY `idx_reporte_generado_user` (`id_user_generador`);

--
-- Indices de la tabla `roles_permisos`
--
ALTER TABLE `roles_permisos`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `sitio_trabajo`
--
ALTER TABLE `sitio_trabajo`
  ADD PRIMARY KEY (`id_ai_sitio`);

--
-- Indices de la tabla `smtp_config`
--
ALTER TABLE `smtp_config`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `turno_trabajo`
--
ALTER TABLE `turno_trabajo`
  ADD PRIMARY KEY (`id_ai_turno`);

--
-- Indices de la tabla `user_system`
--
ALTER TABLE `user_system`
  ADD PRIMARY KEY (`id_ai_user`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `uk_user_system_id_empleado` (`id_empleado`),
  ADD KEY `tipo` (`tipo`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `area_trabajo`
--
ALTER TABLE `area_trabajo`
  MODIFY `id_ai_area` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable', AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT de la tabla `categoria_empleado`
--
ALTER TABLE `categoria_empleado`
  MODIFY `id_ai_categoria_empleado` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable', AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `categoria_herramienta`
--
ALTER TABLE `categoria_herramienta`
  MODIFY `id_ai_categoria_herramienta` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Id autoincrementable de la categoria de herramienta', AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `detalle_orden`
--
ALTER TABLE `detalle_orden`
  MODIFY `id_ai_detalle` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable', AUTO_INCREMENT=34;

--
-- AUTO_INCREMENT de la tabla `empleado`
--
ALTER TABLE `empleado`
  MODIFY `id_ai_empleado` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable', AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `estado_ot`
--
ALTER TABLE `estado_ot`
  MODIFY `id_ai_estado` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable', AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT de la tabla `herramienta`
--
ALTER TABLE `herramienta`
  MODIFY `id_ai_herramienta` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable', AUTO_INCREMENT=40;

--
-- AUTO_INCREMENT de la tabla `herramientaot`
--
ALTER TABLE `herramientaot`
  MODIFY `id_ai_herramientaOT` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable', AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT de la tabla `log_user`
--
ALTER TABLE `log_user`
  MODIFY `id_log` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable', AUTO_INCREMENT=82;

--
-- AUTO_INCREMENT de la tabla `miembro`
--
ALTER TABLE `miembro`
  MODIFY `id_ai_miembro` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable', AUTO_INCREMENT=28;

--
-- AUTO_INCREMENT de la tabla `orden_trabajo`
--
ALTER TABLE `orden_trabajo`
  MODIFY `id_ai_ot` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable', AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT de la tabla `reporte_generado`
--
ALTER TABLE `reporte_generado`
  MODIFY `id_ai_reporte_generado` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Id autoincrementable del reporte generado', AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `roles_permisos`
--
ALTER TABLE `roles_permisos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable', AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT de la tabla `sitio_trabajo`
--
ALTER TABLE `sitio_trabajo`
  MODIFY `id_ai_sitio` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable', AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT de la tabla `turno_trabajo`
--
ALTER TABLE `turno_trabajo`
  MODIFY `id_ai_turno` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable', AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT de la tabla `user_system`
--
ALTER TABLE `user_system`
  MODIFY `id_ai_user` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable', AUTO_INCREMENT=5;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `detalle_orden`
--
ALTER TABLE `detalle_orden`
  ADD CONSTRAINT `detalle_orden_ibfk_2` FOREIGN KEY (`id_user_act`) REFERENCES `user_system` (`id_empleado`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `detalle_orden_ibfk_3` FOREIGN KEY (`id_miembro_ccf`) REFERENCES `miembro` (`id_miembro`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `detalle_orden_ibfk_4` FOREIGN KEY (`id_miembro_cco`) REFERENCES `miembro` (`id_miembro`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `detalle_orden_ibfk_5` FOREIGN KEY (`id_ai_estado`) REFERENCES `estado_ot` (`id_ai_estado`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `detalle_orden_ibfk_6` FOREIGN KEY (`id_ai_turno`) REFERENCES `turno_trabajo` (`id_ai_turno`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `detalle_orden_ibfk_7` FOREIGN KEY (`n_ot`) REFERENCES `orden_trabajo` (`n_ot`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `empleado`
--
ALTER TABLE `empleado`
  ADD CONSTRAINT `fk_empleado_categoria` FOREIGN KEY (`id_ai_categoria_empleado`) REFERENCES `categoria_empleado` (`id_ai_categoria_empleado`) ON UPDATE CASCADE;

--
-- Filtros para la tabla `herramienta`
--
ALTER TABLE `herramienta`
  ADD CONSTRAINT `fk_herramienta_categoria` FOREIGN KEY (`id_ai_categoria_herramienta`) REFERENCES `categoria_herramienta` (`id_ai_categoria_herramienta`);

--
-- Filtros para la tabla `herramientaot`
--
ALTER TABLE `herramientaot`
  ADD CONSTRAINT `herramientaot_ibfk_1` FOREIGN KEY (`n_ot`) REFERENCES `orden_trabajo` (`n_ot`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `herramientaot_ibfk_2` FOREIGN KEY (`id_ai_herramienta`) REFERENCES `herramienta` (`id_ai_herramienta`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `log_user`
--
ALTER TABLE `log_user`
  ADD CONSTRAINT `fk_log_user_user` FOREIGN KEY (`id_user`) REFERENCES `user_system` (`id_empleado`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Filtros para la tabla `orden_trabajo`
--
ALTER TABLE `orden_trabajo`
  ADD CONSTRAINT `orden_trabajo_ibfk_1` FOREIGN KEY (`id_user`) REFERENCES `user_system` (`id_empleado`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `orden_trabajo_ibfk_2` FOREIGN KEY (`id_ai_sitio`) REFERENCES `sitio_trabajo` (`id_ai_sitio`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `orden_trabajo_ibfk_3` FOREIGN KEY (`id_ai_area`) REFERENCES `area_trabajo` (`id_ai_area`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `user_system`
--
ALTER TABLE `user_system`
  ADD CONSTRAINT `fk_user_system_empleado` FOREIGN KEY (`id_empleado`) REFERENCES `empleado` (`id_empleado`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_user_system_roles` FOREIGN KEY (`tipo`) REFERENCES `roles_permisos` (`id`),
  ADD CONSTRAINT `user_system_ibfk_1` FOREIGN KEY (`tipo`) REFERENCES `roles_permisos` (`id`) ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

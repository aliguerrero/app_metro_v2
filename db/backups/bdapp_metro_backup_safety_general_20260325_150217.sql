-- ========================================
-- Respaldo de base de datos
-- APP_METRO_BACKUP_SIGNATURE: 1
-- APP_METRO_BACKUP_GENERATOR: MYSQLDUMP
-- DB: bdapp_metro
-- Fecha: 2026-03-25 15:02:17
-- Tipo: COMPLETO
-- Tablas incluidas: area_trabajo, categoria_empleado, categoria_herramienta, detalle_orden, empleado, empresa_config, estado_ot, herramienta, herramientaot, log_user, miembro, orden_trabajo, reporte_generado, roles_permisos, sitio_trabajo, smtp_config, turno_trabajo, user_system
-- ========================================

-- Esquemas incluidos: bdapp_metro, bdapp_metro_audit, bdapp_metro_review

-- Esquema: bdapp_metro
CREATE DATABASE IF NOT EXISTS `bdapp_metro` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `bdapp_metro`;


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
DROP TABLE IF EXISTS `area_trabajo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `area_trabajo` (
  `id_ai_area` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable',
  `nombre_area` varchar(100) NOT NULL COMMENT 'Nombre del area de trabajo',
  `nomeclatura` varchar(20) NOT NULL COMMENT 'Nomenclatura o prefijo usado para generar codigos de OT',
  `std_reg` tinyint(1) NOT NULL COMMENT 'Estado logico del registro (1=activo, 0=inactivo/eliminado logico).',
  PRIMARY KEY (`id_ai_area`),
  UNIQUE KEY `nomeclatura` (`nomeclatura`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `area_trabajo` WRITE;
/*!40000 ALTER TABLE `area_trabajo` DISABLE KEYS */;
INSERT INTO `area_trabajo` VALUES (1,'SENALIZACION','VF-SEN-',1),(2,'APARATO DE VIA','VF-APV-',1),(3,'INFRAESTRUCTURA','VF-INF-',1),(5,'NO PROGRAMADA','VF-NP-',1);
/*!40000 ALTER TABLE `area_trabajo` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_area_trabajo_ai` AFTER INSERT ON `area_trabajo` FOR EACH ROW INSERT INTO `log_user`(
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
) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_area_trabajo_au` AFTER UPDATE ON `area_trabajo` FOR EACH ROW INSERT INTO `log_user`(
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
) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_area_trabajo_bd` BEFORE DELETE ON `area_trabajo` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE fisico en area_trabajo. Use eliminacion logica (UPDATE area_trabajo SET std_reg=0 ...).' */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
DROP TABLE IF EXISTS `categoria_empleado`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `categoria_empleado` (
  `id_ai_categoria_empleado` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable',
  `nombre_categoria` varchar(100) NOT NULL COMMENT 'Nombre de la categoria del empleado',
  `descripcion` varchar(255) DEFAULT NULL COMMENT 'Descripcion breve de la categoria',
  `std_reg` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Estado logico del registro (1=activo, 0=inactivo).',
  PRIMARY KEY (`id_ai_categoria_empleado`),
  UNIQUE KEY `uk_categoria_empleado_nombre` (`nombre_categoria`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `categoria_empleado` WRITE;
/*!40000 ALTER TABLE `categoria_empleado` DISABLE KEYS */;
INSERT INTO `categoria_empleado` VALUES (1,'COORDINACION OPERATIVA','Personal responsable de la coordinacion general y seguimiento de mantenimiento.',1),(2,'SUPERVISION DE MANTENIMIENTO','Supervisores responsables de planificar y validar la ejecucion de trabajos.',1),(3,'TECNICO DE MANTENIMIENTO','Tecnicos que ejecutan actividades de campo y atienden incidencias operativas.',1),(4,'OPERADOR CCF','Personal de apoyo operativo asignado al Centro de Control de Fallas.',1),(5,'OPERADOR CCO','Personal de apoyo operativo asignado al Centro de Control de Operaciones.',1);
/*!40000 ALTER TABLE `categoria_empleado` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_categoria_empleado_ai` AFTER INSERT ON `categoria_empleado` FOR EACH ROW INSERT INTO `log_user`(
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
) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_categoria_empleado_au` AFTER UPDATE ON `categoria_empleado` FOR EACH ROW INSERT INTO `log_user`(
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
) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_categoria_empleado_bd` BEFORE DELETE ON `categoria_empleado` FOR EACH ROW SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'No se permite DELETE fisico en categoria_empleado. Use eliminacion logica (UPDATE categoria_empleado SET std_reg=0 ...).' */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
DROP TABLE IF EXISTS `categoria_herramienta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `categoria_herramienta` (
  `id_ai_categoria_herramienta` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id autoincrementable de la categoria de herramienta',
  `nombre_categoria` varchar(100) NOT NULL COMMENT 'Nombre de la categoria de la herramienta',
  `descripcion` varchar(255) DEFAULT NULL COMMENT 'Descripcion breve de la categoria de herramienta',
  `std_reg` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Estado logico del registro (1=activo, 0=inactivo).',
  PRIMARY KEY (`id_ai_categoria_herramienta`),
  KEY `idx_categoria_herramienta_nombre` (`nombre_categoria`),
  KEY `idx_categoria_herramienta_std_reg` (`std_reg`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `categoria_herramienta` WRITE;
/*!40000 ALTER TABLE `categoria_herramienta` DISABLE KEYS */;
INSERT INTO `categoria_herramienta` VALUES (1,'HERRAMIENTAS MANUALES','Herramientas de uso mecanico y de ajuste general en campo.',1),(2,'MEDICION Y DIAGNOSTICO','Instrumentos para medicion electrica, continuidad y verificacion tecnica.',1),(3,'EQUIPOS ELECTRICOS','Equipos electricos portatiles para perforacion, corte y apoyo operativo.',1),(4,'SEGURIDAD INDUSTRIAL','Dotacion de proteccion personal y apoyo para trabajo seguro.',1),(5,'SOLDADURA Y CORTE','Equipos para soldadura, corte y adecuacion metalmecanica.',1);
/*!40000 ALTER TABLE `categoria_herramienta` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_categoria_herramienta_ai` AFTER INSERT ON `categoria_herramienta` FOR EACH ROW INSERT INTO `log_user`(
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
) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_categoria_herramienta_au` AFTER UPDATE ON `categoria_herramienta` FOR EACH ROW INSERT INTO `log_user`(
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
) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_categoria_herramienta_bd` BEFORE DELETE ON `categoria_herramienta` FOR EACH ROW SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'No se permite DELETE fisico en categoria_herramienta. Use eliminacion logica (UPDATE categoria_herramienta SET std_reg=0 ...).' */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
DROP TABLE IF EXISTS `detalle_orden`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `detalle_orden` (
  `id_ai_detalle` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable',
  `n_ot` varchar(30) NOT NULL COMMENT 'Numero unico de la orden de trabajo',
  `fecha` date NOT NULL COMMENT 'Fecha programada de la orden de trabajo',
  `descripcion` varchar(250) NOT NULL COMMENT 'Descripcion de la actividad o trabajo a realizar',
  `id_ai_turno` int(11) NOT NULL COMMENT 'Identificador unico del turno de trabajo',
  `id_miembro_cco` varchar(10) NOT NULL COMMENT 'Miembro responsable en CCO (Centro de Control de Operaciones)',
  `id_user_act` varchar(30) NOT NULL COMMENT 'Usuario tecnico responsable de ejecutar la actividad',
  `id_miembro_ccf` varchar(10) NOT NULL COMMENT 'Miembro responsable en CCF',
  `cant_tec` int(11) NOT NULL COMMENT 'Cantidad de tecnicos involucrados en la actividad',
  `hora_inicio` time DEFAULT NULL COMMENT 'Hora de inicio del trabajo',
  `hora_fin` time DEFAULT NULL COMMENT 'Hora de fin del trabajo',
  `observacion` varchar(250) DEFAULT NULL COMMENT 'Observaciones adicionales sobre la actividad',
  PRIMARY KEY (`id_ai_detalle`),
  KEY `responsable_ccf` (`id_miembro_ccf`),
  KEY `responsable_cco` (`id_miembro_cco`),
  KEY `responsable_act` (`id_user_act`),
  KEY `turno` (`id_ai_turno`),
  KEY `n_ot` (`n_ot`),
  KEY `idx_detalle_ot_fecha` (`n_ot`,`fecha`),
  CONSTRAINT `detalle_orden_ibfk_2` FOREIGN KEY (`id_user_act`) REFERENCES `user_system` (`id_empleado`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `detalle_orden_ibfk_3` FOREIGN KEY (`id_miembro_ccf`) REFERENCES `miembro` (`id_miembro`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `detalle_orden_ibfk_4` FOREIGN KEY (`id_miembro_cco`) REFERENCES `miembro` (`id_miembro`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `detalle_orden_ibfk_6` FOREIGN KEY (`id_ai_turno`) REFERENCES `turno_trabajo` (`id_ai_turno`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `detalle_orden_ibfk_7` FOREIGN KEY (`n_ot`) REFERENCES `orden_trabajo` (`n_ot`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `detalle_orden` WRITE;
/*!40000 ALTER TABLE `detalle_orden` DISABLE KEYS */;
INSERT INTO `detalle_orden` VALUES (1,'VF-SEN-001','2026-03-16','Revision de conexionado, limpieza de borneras y ajuste de tres balizas de via en tramo sur.',1,'M-002','8840285','M-001',3,'07:30:00','10:30:00','Trabajo coordinado con ventana de mantenimiento.'),(2,'VF-SEN-002','2026-03-17','Prueba funcional del circuito de anuncio, verificacion de tarjetas y recalibracion de tiempos de enclavamiento.',2,'M-004','26580187','M-003',2,'13:00:00','16:30:00','OT en seguimiento por pruebas operativas.'),(3,'VF-APV-001','2026-03-18','Lubricacion de agujas, torque de fijaciones y verificacion de desplazamiento del cambio 04.',1,'M-006','8840285','M-005',4,'08:00:00','11:30:00','Actividad completada sin novedades.'),(4,'VF-APV-002','2026-03-19','Desmontaje parcial para reemplazo de pernos de sujecion; pendiente ingreso de repuesto.',3,'M-008','26580187','M-007',3,'20:00:00','23:30:00','Reprogramada por falta de pernos calibre 7/8.'),(5,'VF-INF-001','2026-03-20','Limpieza de drenaje, picado de zona afectada y resane con mortero de alta adherencia.',1,'M-002','8840285','M-005',3,'08:30:00','12:00:00','Pendiente suministro de mortero epoxico.'),(6,'VF-INF-002','2026-03-21','Reposicion de tapas, nivelacion de soporte y reparacion puntual de borde de anden.',2,'M-004','26580187','M-007',2,'14:00:00','17:00:00','Se ejecuto conforme al plan de mantenimiento.'),(7,'VF-NP-001','2026-03-21','Inspeccion de toma energizada y prueba de continuidad; se suspende por aislador fisurado.',4,'M-006','8840285','M-003',2,'05:30:00','07:00:00','Suspension preventiva por componente aislante danado.'),(8,'VF-NP-002','2026-03-22','Revision inicial del gabinete, lectura de alarmas y verificacion de voltajes en fuente secundaria.',2,'M-008','26580187','M-001',2,'13:30:00','15:30:00','A la espera de ventana nocturna para intervencion.');
/*!40000 ALTER TABLE `detalle_orden` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_detalle_orden_ai` AFTER INSERT ON `detalle_orden` FOR EACH ROW BEGIN
  INSERT INTO log_user(
    event_uuid, id_user, tabla, operacion, pk_registro, pk_json,
    accion, resp_system,
    data_old, data_new, data_diff, changed_cols,
    connection_id, db_user, db_host
  ) VALUES (
    UUID(),
    (SELECT id_empleado FROM user_system WHERE id_empleado = @app_user LIMIT 1),
    'detalle_orden',
    'INSERT',
    CONCAT('id_ai_detalle=', NEW.id_ai_detalle),
    JSON_OBJECT('id_ai_detalle', NEW.id_ai_detalle),
    'CREAR detalle_orden',
    CONCAT('INSERT detalle_orden id_ai_detalle=', NEW.id_ai_detalle),
    NULL,
    JSON_OBJECT(
      'id_ai_detalle', NEW.id_ai_detalle,
      'n_ot', NEW.n_ot,
      'fecha', NEW.fecha,
      'descripcion', NEW.descripcion,
      'id_ai_turno', NEW.id_ai_turno,
      'id_miembro_cco', NEW.id_miembro_cco,
      'id_user_act', NEW.id_user_act,
      'id_miembro_ccf', NEW.id_miembro_ccf,
      'cant_tec', NEW.cant_tec,
      'hora_inicio', NEW.hora_inicio,
      'hora_fin', NEW.hora_fin,
      'observacion', NEW.observacion
    ),
    JSON_OBJECT(
      'id_ai_detalle', NEW.id_ai_detalle,
      'n_ot', NEW.n_ot,
      'fecha', NEW.fecha,
      'descripcion', NEW.descripcion,
      'id_ai_turno', NEW.id_ai_turno,
      'id_miembro_cco', NEW.id_miembro_cco,
      'id_user_act', NEW.id_user_act,
      'id_miembro_ccf', NEW.id_miembro_ccf,
      'cant_tec', NEW.cant_tec,
      'hora_inicio', NEW.hora_inicio,
      'hora_fin', NEW.hora_fin,
      'observacion', NEW.observacion
    ),
    'id_ai_detalle,n_ot,fecha,descripcion,id_ai_turno,id_miembro_cco,id_user_act,id_miembro_ccf,cant_tec,hora_inicio,hora_fin,observacion',
    CONNECTION_ID(),
    USER(),
    SUBSTRING_INDEX(USER(), '@', -1)
  );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_detalle_orden_au` AFTER UPDATE ON `detalle_orden` FOR EACH ROW BEGIN
  INSERT INTO log_user(
    event_uuid, id_user, tabla, operacion, pk_registro, pk_json,
    accion, resp_system,
    data_old, data_new, data_diff, changed_cols,
    connection_id, db_user, db_host
  ) VALUES (
    UUID(),
    (SELECT id_empleado FROM user_system WHERE id_empleado = @app_user LIMIT 1),
    'detalle_orden',
    'UPDATE',
    CONCAT('id_ai_detalle=', NEW.id_ai_detalle),
    JSON_OBJECT('id_ai_detalle', NEW.id_ai_detalle),
    'MODIFICAR detalle_orden',
    CONCAT('UPDATE detalle_orden id_ai_detalle=', NEW.id_ai_detalle),
    JSON_OBJECT(
      'id_ai_detalle', OLD.id_ai_detalle,
      'n_ot', OLD.n_ot,
      'fecha', OLD.fecha,
      'descripcion', OLD.descripcion,
      'id_ai_turno', OLD.id_ai_turno,
      'id_miembro_cco', OLD.id_miembro_cco,
      'id_user_act', OLD.id_user_act,
      'id_miembro_ccf', OLD.id_miembro_ccf,
      'cant_tec', OLD.cant_tec,
      'hora_inicio', OLD.hora_inicio,
      'hora_fin', OLD.hora_fin,
      'observacion', OLD.observacion
    ),
    JSON_OBJECT(
      'id_ai_detalle', NEW.id_ai_detalle,
      'n_ot', NEW.n_ot,
      'fecha', NEW.fecha,
      'descripcion', NEW.descripcion,
      'id_ai_turno', NEW.id_ai_turno,
      'id_miembro_cco', NEW.id_miembro_cco,
      'id_user_act', NEW.id_user_act,
      'id_miembro_ccf', NEW.id_miembro_ccf,
      'cant_tec', NEW.cant_tec,
      'hora_inicio', NEW.hora_inicio,
      'hora_fin', NEW.hora_fin,
      'observacion', NEW.observacion
    ),
    JSON_MERGE_PATCH(
      JSON_MERGE_PATCH(
        JSON_MERGE_PATCH(
          JSON_MERGE_PATCH(
            JSON_MERGE_PATCH(
              JSON_MERGE_PATCH(
                JSON_MERGE_PATCH(
                  JSON_MERGE_PATCH(
                    JSON_MERGE_PATCH(
                      JSON_MERGE_PATCH(
                        JSON_MERGE_PATCH(
                          JSON_OBJECT(),
                          IF(NOT (OLD.id_ai_detalle <=> NEW.id_ai_detalle), JSON_OBJECT('id_ai_detalle', JSON_ARRAY(OLD.id_ai_detalle, NEW.id_ai_detalle)), JSON_OBJECT())
                        ),
                        IF(NOT (OLD.n_ot <=> NEW.n_ot), JSON_OBJECT('n_ot', JSON_ARRAY(OLD.n_ot, NEW.n_ot)), JSON_OBJECT())
                      ),
                      IF(NOT (OLD.fecha <=> NEW.fecha), JSON_OBJECT('fecha', JSON_ARRAY(OLD.fecha, NEW.fecha)), JSON_OBJECT())
                    ),
                    IF(NOT (OLD.descripcion <=> NEW.descripcion), JSON_OBJECT('descripcion', JSON_ARRAY(OLD.descripcion, NEW.descripcion)), JSON_OBJECT())
                  ),
                  IF(NOT (OLD.id_ai_turno <=> NEW.id_ai_turno), JSON_OBJECT('id_ai_turno', JSON_ARRAY(OLD.id_ai_turno, NEW.id_ai_turno)), JSON_OBJECT())
                ),
                IF(NOT (OLD.id_miembro_cco <=> NEW.id_miembro_cco), JSON_OBJECT('id_miembro_cco', JSON_ARRAY(OLD.id_miembro_cco, NEW.id_miembro_cco)), JSON_OBJECT())
              ),
              IF(NOT (OLD.id_user_act <=> NEW.id_user_act), JSON_OBJECT('id_user_act', JSON_ARRAY(OLD.id_user_act, NEW.id_user_act)), JSON_OBJECT())
            ),
            IF(NOT (OLD.id_miembro_ccf <=> NEW.id_miembro_ccf), JSON_OBJECT('id_miembro_ccf', JSON_ARRAY(OLD.id_miembro_ccf, NEW.id_miembro_ccf)), JSON_OBJECT())
          ),
          IF(NOT (OLD.cant_tec <=> NEW.cant_tec), JSON_OBJECT('cant_tec', JSON_ARRAY(OLD.cant_tec, NEW.cant_tec)), JSON_OBJECT())
        ),
        IF(NOT (OLD.hora_inicio <=> NEW.hora_inicio), JSON_OBJECT('hora_inicio', JSON_ARRAY(OLD.hora_inicio, NEW.hora_inicio)), JSON_OBJECT())
      ),
      JSON_MERGE_PATCH(
        IF(NOT (OLD.hora_fin <=> NEW.hora_fin), JSON_OBJECT('hora_fin', JSON_ARRAY(OLD.hora_fin, NEW.hora_fin)), JSON_OBJECT()),
        IF(NOT (OLD.observacion <=> NEW.observacion), JSON_OBJECT('observacion', JSON_ARRAY(OLD.observacion, NEW.observacion)), JSON_OBJECT())
      )
    ),
    NULLIF(
      CONCAT_WS(',',
        IF(NOT (OLD.id_ai_detalle <=> NEW.id_ai_detalle), 'id_ai_detalle', NULL),
        IF(NOT (OLD.n_ot <=> NEW.n_ot), 'n_ot', NULL),
        IF(NOT (OLD.fecha <=> NEW.fecha), 'fecha', NULL),
        IF(NOT (OLD.descripcion <=> NEW.descripcion), 'descripcion', NULL),
        IF(NOT (OLD.id_ai_turno <=> NEW.id_ai_turno), 'id_ai_turno', NULL),
        IF(NOT (OLD.id_miembro_cco <=> NEW.id_miembro_cco), 'id_miembro_cco', NULL),
        IF(NOT (OLD.id_user_act <=> NEW.id_user_act), 'id_user_act', NULL),
        IF(NOT (OLD.id_miembro_ccf <=> NEW.id_miembro_ccf), 'id_miembro_ccf', NULL),
        IF(NOT (OLD.cant_tec <=> NEW.cant_tec), 'cant_tec', NULL),
        IF(NOT (OLD.hora_inicio <=> NEW.hora_inicio), 'hora_inicio', NULL),
        IF(NOT (OLD.hora_fin <=> NEW.hora_fin), 'hora_fin', NULL),
        IF(NOT (OLD.observacion <=> NEW.observacion), 'observacion', NULL)
      ),
      ''
    ),
    CONNECTION_ID(),
    USER(),
    SUBSTRING_INDEX(USER(), '@', -1)
  );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_detalle_orden_ad` AFTER DELETE ON `detalle_orden` FOR EACH ROW BEGIN
  INSERT INTO log_user(
    event_uuid, id_user, tabla, operacion, pk_registro, pk_json,
    accion, resp_system,
    data_old, data_new, data_diff, changed_cols,
    connection_id, db_user, db_host
  ) VALUES (
    UUID(),
    (SELECT id_empleado FROM user_system WHERE id_empleado = @app_user LIMIT 1),
    'detalle_orden',
    'DELETE',
    CONCAT('id_ai_detalle=', OLD.id_ai_detalle),
    JSON_OBJECT('id_ai_detalle', OLD.id_ai_detalle),
    'ELIMINAR detalle_orden',
    CONCAT('DELETE detalle_orden id_ai_detalle=', OLD.id_ai_detalle),
    JSON_OBJECT(
      'id_ai_detalle', OLD.id_ai_detalle,
      'n_ot', OLD.n_ot,
      'fecha', OLD.fecha,
      'descripcion', OLD.descripcion,
      'id_ai_turno', OLD.id_ai_turno,
      'id_miembro_cco', OLD.id_miembro_cco,
      'id_user_act', OLD.id_user_act,
      'id_miembro_ccf', OLD.id_miembro_ccf,
      'cant_tec', OLD.cant_tec,
      'hora_inicio', OLD.hora_inicio,
      'hora_fin', OLD.hora_fin,
      'observacion', OLD.observacion
    ),
    NULL,
    NULL,
    NULL,
    CONNECTION_ID(),
    USER(),
    SUBSTRING_INDEX(USER(), '@', -1)
  );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
DROP TABLE IF EXISTS `empleado`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `empleado` (
  `id_ai_empleado` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable',
  `id_empleado` varchar(30) NOT NULL COMMENT 'Identificador unico del empleado',
  `nacionalidad` char(1) NOT NULL DEFAULT 'V' COMMENT 'Identifica si la cedula es venezolana (V) o extranjera (E).',
  `nombre_empleado` varchar(100) NOT NULL COMMENT 'Nombre completo del empleado',
  `telefono` varchar(20) DEFAULT NULL COMMENT 'Telefono principal del empleado.',
  `direccion` varchar(255) DEFAULT NULL COMMENT 'Direccion de residencia o ubicacion del empleado.',
  `correo` varchar(120) NOT NULL COMMENT 'Correo electronico del empleado.',
  `id_ai_categoria_empleado` int(11) NOT NULL COMMENT 'Categoria asociada al empleado',
  `std_reg` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Estado logico del registro (1=activo, 0=inactivo).',
  PRIMARY KEY (`id_ai_empleado`),
  UNIQUE KEY `uk_empleado_codigo` (`id_empleado`),
  KEY `idx_empleado_categoria` (`id_ai_categoria_empleado`),
  CONSTRAINT `fk_empleado_categoria` FOREIGN KEY (`id_ai_categoria_empleado`) REFERENCES `categoria_empleado` (`id_ai_categoria_empleado`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `empleado` WRITE;
/*!40000 ALTER TABLE `empleado` DISABLE KEYS */;
INSERT INTO `empleado` VALUES (1,'22206460','V','ALI GUERRERO','0412-8251111','LOS CAOBOS - VALENCIA','aliguerrero102@gmail.com',1,1),(2,'8840285','V','MANUEL ALZURUTT','04129357834','CENTRO - VALENCIA','manuelalzurutt@gmail.com',2,1),(3,'26580187','V','WALTER RAMONE','04128453283','LAS PALMAS - VALENCIA','walramone@gmail.com',3,1),(4,'30114567','V','CARLA MENDOZA','0412-5184401','SAN BLAS - VALENCIA','carla.mendoza@metrovalencia.local',4,1),(5,'29654781','V','JOSE PENA','0414-6883210','PARQUE VALENCIA - VALENCIA','jose.pena@metrovalencia.local',5,1),(6,'31890245','V','LUIS RAMIREZ','0412-5441188','FLOR AMARILLO - VALENCIA','luis.ramirez@metrovalencia.local',4,1),(7,'28765431','V','MARIA FERNANDEZ','0424-6013359','LA ISABELICA - VALENCIA','maria.fernandez@metrovalencia.local',5,1),(8,'27411890','V','ANDRES PEREZ','0414-6092271','SANTA ROSA - VALENCIA','andres.perez@metrovalencia.local',4,1),(9,'29987456','V','DIANA RODRIGUEZ','0412-7712240','LA CANDELARIA - VALENCIA','diana.rodriguez@metrovalencia.local',5,1),(10,'31244780','V','OSCAR SALAZAR','0424-7731180','LOS COLORADOS - VALENCIA','oscar.salazar@metrovalencia.local',4,1),(11,'30599871','V','ELIANA TORRES','0414-5513072','NAGUANAGUA - CARABOBO','eliana.torres@metrovalencia.local',5,1);
/*!40000 ALTER TABLE `empleado` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_empleado_ai` AFTER INSERT ON `empleado` FOR EACH ROW INSERT INTO `log_user`(
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
) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_empleado_au` AFTER UPDATE ON `empleado` FOR EACH ROW INSERT INTO `log_user`(
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
) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_empleado_bd` BEFORE DELETE ON `empleado` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE fisico en empleado. Use eliminacion logica (UPDATE empleado SET std_reg=0 ...).' */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
DROP TABLE IF EXISTS `empresa_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `empresa_config` (
  `id` int(11) NOT NULL COMMENT 'PK. Identificador unico de la configuracion de empresa (normalmente 1 registro).',
  `nombre` varchar(150) NOT NULL COMMENT 'Nombre legal o comercial de la empresa.',
  `rif` varchar(30) DEFAULT NULL COMMENT 'RIF / Identificador fiscal de la empresa.',
  `direccion` varchar(255) DEFAULT NULL COMMENT 'Direccion fisica o fiscal de la empresa.',
  `telefono` varchar(50) DEFAULT NULL COMMENT 'Telefono principal de contacto.',
  `email` varchar(120) DEFAULT NULL COMMENT 'Correo principal de contacto.',
  `logo` varchar(255) DEFAULT NULL COMMENT 'Ruta relativa del logo. Ej: app/views/icons/metro.png',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'Fecha/hora de creacion del registro.',
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Fecha/hora de ultima actualizacion del registro.',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `empresa_config` WRITE;
/*!40000 ALTER TABLE `empresa_config` DISABLE KEYS */;
INSERT INTO `empresa_config` VALUES (1,'C.A. Metro Valencia','G-0000000-1','Av. Sesquicentenaria, local Parque Recreacional Sur, parte Sur Oeste Nro. S/N, zona Valencia Sur. Estado Carabobo.','0241-0000000','metrodevalencia@correo.com','app/views/img/empresa/logo_empresa.jpg','2026-01-07 20:59:31','2026-02-11 23:26:46');
/*!40000 ALTER TABLE `empresa_config` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_empresa_config_ai` AFTER INSERT ON `empresa_config` FOR EACH ROW INSERT INTO `log_user`(
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
) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_empresa_config_au` AFTER UPDATE ON `empresa_config` FOR EACH ROW INSERT INTO `log_user`(
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
) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_empresa_config_ad` AFTER DELETE ON `empresa_config` FOR EACH ROW INSERT INTO `log_user`(
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
) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
DROP TABLE IF EXISTS `estado_ot`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `estado_ot` (
  `id_ai_estado` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable',
  `nombre_estado` varchar(100) NOT NULL COMMENT 'Nombre descriptivo del estado de la orden de trabajo',
  `color` varchar(15) NOT NULL COMMENT 'Codigo de color asociado al estado para representacion visual',
  `libera_herramientas` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Indica si el estado libera automaticamente las herramientas asociadas a la O.T. (1=si, 0=no).',
  `bloquea_ot` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Indica si el estado bloquea cambios operativos adicionales en la O.T. (1=si, 0=no).',
  `std_reg` tinyint(1) NOT NULL COMMENT 'Estado logico del registro (1=activo, 0=inactivo/eliminado logico).',
  PRIMARY KEY (`id_ai_estado`),
  KEY `idx_estado_ot_libera_herramientas` (`libera_herramientas`,`std_reg`),
  KEY `idx_estado_ot_bloquea_ot` (`bloquea_ot`,`std_reg`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `estado_ot` WRITE;
/*!40000 ALTER TABLE `estado_ot` DISABLE KEYS */;
INSERT INTO `estado_ot` VALUES (1,'EJECUTADA','#25ef28',1,1,1),(2,'NO EJECUTADA','#dc3545',0,0,1),(3,'RE-PROGRAMADA','#0d6efd',0,0,1),(4,'SUSPENDIDA','#fd7e14',0,0,1),(12,'EN EJECUCION','#ffc107',0,0,1);
/*!40000 ALTER TABLE `estado_ot` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_estado_ot_bi` BEFORE INSERT ON `estado_ot` FOR EACH ROW BEGIN
  IF COALESCE(NEW.bloquea_ot, 0) = 1 THEN
    SET NEW.libera_herramientas = 1;

    IF EXISTS (
      SELECT 1
      FROM estado_ot
      WHERE std_reg = 1
        AND COALESCE(bloquea_ot, 0) = 1
    ) THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Solo puede existir un estado activo configurado para bloquear la O.T.';
    END IF;
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_estado_ot_ai` AFTER INSERT ON `estado_ot` FOR EACH ROW BEGIN
  INSERT INTO log_user(
    event_uuid, id_user, tabla, operacion, pk_registro, pk_json,
    accion, resp_system,
    data_old, data_new, data_diff, changed_cols,
    connection_id, db_user, db_host
  ) VALUES (
    UUID(),
    (SELECT id_empleado FROM user_system WHERE id_empleado = @app_user LIMIT 1),
    'estado_ot',
    'INSERT',
    CONCAT('id_ai_estado=', NEW.id_ai_estado),
    JSON_OBJECT('id_ai_estado', NEW.id_ai_estado),
    'CREAR estado_ot',
    CONCAT('INSERT estado_ot id_ai_estado=', NEW.id_ai_estado),
    NULL,
    JSON_OBJECT(
      'id_ai_estado', NEW.id_ai_estado,
      'nombre_estado', NEW.nombre_estado,
      'color', NEW.color,
      'libera_herramientas', NEW.libera_herramientas,
      'bloquea_ot', NEW.bloquea_ot,
      'std_reg', NEW.std_reg
    ),
    JSON_OBJECT(
      'id_ai_estado', NEW.id_ai_estado,
      'nombre_estado', NEW.nombre_estado,
      'color', NEW.color,
      'libera_herramientas', NEW.libera_herramientas,
      'bloquea_ot', NEW.bloquea_ot,
      'std_reg', NEW.std_reg
    ),
    'id_ai_estado,nombre_estado,color,libera_herramientas,bloquea_ot,std_reg',
    CONNECTION_ID(),
    USER(),
    SUBSTRING_INDEX(USER(), '@', -1)
  );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_estado_ot_bu` BEFORE UPDATE ON `estado_ot` FOR EACH ROW BEGIN
  IF COALESCE(NEW.bloquea_ot, 0) = 1 THEN
    SET NEW.libera_herramientas = 1;

    IF EXISTS (
      SELECT 1
      FROM estado_ot
      WHERE std_reg = 1
        AND COALESCE(bloquea_ot, 0) = 1
        AND id_ai_estado <> OLD.id_ai_estado
    ) THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Solo puede existir un estado activo configurado para bloquear la O.T.';
    END IF;
  END IF;

  IF COALESCE(OLD.bloquea_ot, 0) = 1
     AND (
       NOT (OLD.nombre_estado <=> NEW.nombre_estado)
       OR NOT (OLD.color <=> NEW.color)
       OR NOT (OLD.libera_herramientas <=> NEW.libera_herramientas)
       OR NOT (OLD.bloquea_ot <=> NEW.bloquea_ot)
       OR NOT (OLD.std_reg <=> NEW.std_reg)
     ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'El estado configurado para bloquear la O.T. es protegido y no puede modificarse ni eliminarse.';
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_estado_ot_au` AFTER UPDATE ON `estado_ot` FOR EACH ROW BEGIN
  INSERT INTO log_user(
    event_uuid, id_user, tabla, operacion, pk_registro, pk_json,
    accion, resp_system,
    data_old, data_new, data_diff, changed_cols,
    connection_id, db_user, db_host
  ) VALUES (
    UUID(),
    (SELECT id_empleado FROM user_system WHERE id_empleado = @app_user LIMIT 1),
    'estado_ot',
    CASE
      WHEN NEW.std_reg = 0 AND OLD.std_reg = 1 THEN 'SOFT_DELETE'
      WHEN NEW.std_reg = 1 AND OLD.std_reg = 0 THEN 'RESTORE'
      ELSE 'UPDATE'
    END,
    CONCAT('id_ai_estado=', NEW.id_ai_estado),
    JSON_OBJECT('id_ai_estado', NEW.id_ai_estado),
    CASE
      WHEN NEW.std_reg = 0 AND OLD.std_reg = 1 THEN 'ELIMINAR (LOGICO) estado_ot'
      WHEN NEW.std_reg = 1 AND OLD.std_reg = 0 THEN 'REACTIVAR estado_ot'
      ELSE 'MODIFICAR estado_ot'
    END,
    CASE
      WHEN NEW.std_reg = 0 AND OLD.std_reg = 1 THEN CONCAT('SOFT_DELETE estado_ot id_ai_estado=', NEW.id_ai_estado)
      WHEN NEW.std_reg = 1 AND OLD.std_reg = 0 THEN CONCAT('RESTORE estado_ot id_ai_estado=', NEW.id_ai_estado)
      ELSE CONCAT('UPDATE estado_ot id_ai_estado=', NEW.id_ai_estado)
    END,
    JSON_OBJECT(
      'id_ai_estado', OLD.id_ai_estado,
      'nombre_estado', OLD.nombre_estado,
      'color', OLD.color,
      'libera_herramientas', OLD.libera_herramientas,
      'bloquea_ot', OLD.bloquea_ot,
      'std_reg', OLD.std_reg
    ),
    JSON_OBJECT(
      'id_ai_estado', NEW.id_ai_estado,
      'nombre_estado', NEW.nombre_estado,
      'color', NEW.color,
      'libera_herramientas', NEW.libera_herramientas,
      'bloquea_ot', NEW.bloquea_ot,
      'std_reg', NEW.std_reg
    ),
    JSON_MERGE_PATCH(
      JSON_MERGE_PATCH(
        JSON_MERGE_PATCH(
          JSON_MERGE_PATCH(
            JSON_MERGE_PATCH(
              JSON_OBJECT(),
              IF(NOT (OLD.id_ai_estado <=> NEW.id_ai_estado), JSON_OBJECT('id_ai_estado', JSON_ARRAY(OLD.id_ai_estado, NEW.id_ai_estado)), JSON_OBJECT())
            ),
            IF(NOT (OLD.nombre_estado <=> NEW.nombre_estado), JSON_OBJECT('nombre_estado', JSON_ARRAY(OLD.nombre_estado, NEW.nombre_estado)), JSON_OBJECT())
          ),
          IF(NOT (OLD.color <=> NEW.color), JSON_OBJECT('color', JSON_ARRAY(OLD.color, NEW.color)), JSON_OBJECT())
        ),
        IF(NOT (OLD.libera_herramientas <=> NEW.libera_herramientas), JSON_OBJECT('libera_herramientas', JSON_ARRAY(OLD.libera_herramientas, NEW.libera_herramientas)), JSON_OBJECT())
      ),
      JSON_MERGE_PATCH(
        IF(NOT (OLD.bloquea_ot <=> NEW.bloquea_ot), JSON_OBJECT('bloquea_ot', JSON_ARRAY(OLD.bloquea_ot, NEW.bloquea_ot)), JSON_OBJECT()),
        IF(NOT (OLD.std_reg <=> NEW.std_reg), JSON_OBJECT('std_reg', JSON_ARRAY(OLD.std_reg, NEW.std_reg)), JSON_OBJECT())
      )
    ),
    NULLIF(
      CONCAT_WS(',',
        IF(NOT (OLD.id_ai_estado <=> NEW.id_ai_estado), 'id_ai_estado', NULL),
        IF(NOT (OLD.nombre_estado <=> NEW.nombre_estado), 'nombre_estado', NULL),
        IF(NOT (OLD.color <=> NEW.color), 'color', NULL),
        IF(NOT (OLD.libera_herramientas <=> NEW.libera_herramientas), 'libera_herramientas', NULL),
        IF(NOT (OLD.bloquea_ot <=> NEW.bloquea_ot), 'bloquea_ot', NULL),
        IF(NOT (OLD.std_reg <=> NEW.std_reg), 'std_reg', NULL)
      ),
      ''
    ),
    CONNECTION_ID(),
    USER(),
    SUBSTRING_INDEX(USER(), '@', -1)
  );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_estado_ot_bd` BEFORE DELETE ON `estado_ot` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE fisico en estado_ot. Use eliminacion logica (UPDATE estado_ot SET std_reg=0 ...).' */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
DROP TABLE IF EXISTS `herramienta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `herramienta` (
  `id_ai_herramienta` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable',
  `nombre_herramienta` varchar(250) NOT NULL COMMENT 'Nombre descriptivo de la herramienta',
  `id_ai_categoria_herramienta` int(10) unsigned NOT NULL COMMENT 'Categoria asociada a la herramienta',
  `cantidad` int(11) NOT NULL COMMENT 'Cantidad total de unidades disponibles de la herramienta',
  `estado` varchar(5) NOT NULL COMMENT 'Descripcion del estado general de la herramienta',
  `std_reg` tinyint(1) NOT NULL COMMENT 'Estado logico del registro (1=activo, 0=inactivo/eliminado logico).',
  PRIMARY KEY (`id_ai_herramienta`),
  KEY `idx_herramienta_categoria` (`id_ai_categoria_herramienta`),
  CONSTRAINT `fk_herramienta_categoria` FOREIGN KEY (`id_ai_categoria_herramienta`) REFERENCES `categoria_herramienta` (`id_ai_categoria_herramienta`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `herramienta` WRITE;
/*!40000 ALTER TABLE `herramienta` DISABLE KEYS */;
INSERT INTO `herramienta` VALUES (1,'Martillo de via',1,6,'1',1),(2,'Llave de impacto 3/4',1,4,'1',1),(3,'Juego de destornilladores aislados',1,8,'1',1),(4,'Pinza amperimetrica',2,3,'1',1),(5,'Multimetro digital',2,4,'1',1),(6,'Medidor laser de distancia',2,2,'2',1),(7,'Taladro percutor industrial',3,5,'1',1),(8,'Amoladora angular 7in',3,3,'2',1),(9,'Generador portatil 5kVA',3,2,'1',1),(10,'Casco de seguridad',4,20,'1',1),(11,'Arnes de seguridad',4,10,'1',1),(12,'Guantes dielectricos',4,15,'1',1),(13,'Soldadora inverter',5,2,'1',1),(14,'Careta de soldar',5,4,'1',1),(15,'Cizalla para cables',5,3,'2',1),(16,'Escalera telescopica',4,4,'1',1);
/*!40000 ALTER TABLE `herramienta` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_herramienta_ai` AFTER INSERT ON `herramienta` FOR EACH ROW INSERT INTO `log_user`(
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
) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_herramienta_au` AFTER UPDATE ON `herramienta` FOR EACH ROW INSERT INTO `log_user`(
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
) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_herramienta_bd` BEFORE DELETE ON `herramienta` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE fisico en herramienta. Use eliminacion logica (UPDATE herramienta SET std_reg=0 ...).' */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
DROP TABLE IF EXISTS `herramientaot`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `herramientaot` (
  `id_ai_herramientaOT` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable',
  `id_ai_herramienta` int(11) NOT NULL COMMENT 'Codigo de la herramienta asignada a la orden de trabajo',
  `n_ot` varchar(30) NOT NULL COMMENT 'Numero unico de la orden de trabajo',
  `cantidadot` int(11) NOT NULL COMMENT 'Cantidad de unidades de la herramienta asignadas a la OT',
  `estado_herramientaot` varchar(60) NOT NULL DEFAULT 'ASIGNADA' COMMENT 'Estado o condicion de la herramienta dentro de la OT',
  PRIMARY KEY (`id_ai_herramientaOT`),
  KEY `id_herramienta` (`id_ai_herramienta`),
  KEY `n_ot` (`n_ot`),
  KEY `idx_herramientaot_ot_estado` (`n_ot`,`estado_herramientaot`),
  CONSTRAINT `herramientaot_ibfk_1` FOREIGN KEY (`n_ot`) REFERENCES `orden_trabajo` (`n_ot`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `herramientaot_ibfk_2` FOREIGN KEY (`id_ai_herramienta`) REFERENCES `herramienta` (`id_ai_herramienta`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `herramientaot` WRITE;
/*!40000 ALTER TABLE `herramientaot` DISABLE KEYS */;
INSERT INTO `herramientaot` VALUES (1,4,'VF-SEN-001',1,'ASIGNADA'),(2,5,'VF-SEN-001',1,'ASIGNADA'),(3,10,'VF-SEN-001',3,'ASIGNADA'),(4,7,'VF-SEN-002',1,'ASIGNADA'),(5,10,'VF-SEN-002',2,'ASIGNADA'),(6,11,'VF-SEN-002',1,'ASIGNADA'),(7,1,'VF-APV-001',2,'LIBERADA'),(8,2,'VF-APV-001',1,'LIBERADA'),(9,10,'VF-APV-001',4,'LIBERADA'),(10,10,'VF-INF-001',3,'ASIGNADA'),(11,16,'VF-INF-001',1,'ASIGNADA'),(12,6,'VF-INF-002',1,'LIBERADA'),(13,7,'VF-INF-002',1,'LIBERADA'),(14,10,'VF-INF-002',2,'LIBERADA'),(15,4,'VF-NP-002',1,'ASIGNADA'),(16,5,'VF-NP-002',1,'ASIGNADA');
/*!40000 ALTER TABLE `herramientaot` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_herramientaot_ai` AFTER INSERT ON `herramientaot` FOR EACH ROW INSERT INTO `log_user`(
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
) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_herramientaot_au` AFTER UPDATE ON `herramientaot` FOR EACH ROW INSERT INTO `log_user`(
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
) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_herramientaot_ad` AFTER DELETE ON `herramientaot` FOR EACH ROW INSERT INTO `log_user`(
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
) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
DROP TABLE IF EXISTS `log_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `log_user` (
  `id_log` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable',
  `event_uuid` char(36) NOT NULL COMMENT 'Identificador unico del evento de auditoria.',
  `id_user` varchar(30) DEFAULT NULL COMMENT 'Identificador del usuario asociado al evento de auditoria.',
  `tabla` varchar(64) NOT NULL COMMENT 'Tabla origen del evento.',
  `operacion` enum('INSERT','UPDATE','DELETE','SOFT_DELETE','RESTORE','UNKNOWN') NOT NULL COMMENT 'Tipo de operacion registrada.',
  `pk_registro` varchar(255) DEFAULT NULL COMMENT 'Clave primaria (o identificador) del registro afectado.',
  `pk_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Identificador/PK en formato JSON.' CHECK (json_valid(`pk_json`)),
  `accion` varchar(150) NOT NULL COMMENT 'Accion funcional mostrada al usuario o al sistema.',
  `resp_system` text NOT NULL COMMENT 'Detalle tecnico de la operacion registrada.',
  `data_old` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Snapshot anterior (UPDATE/DELETE).' CHECK (json_valid(`data_old`)),
  `data_new` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Snapshot posterior (INSERT/UPDATE).' CHECK (json_valid(`data_new`)),
  `data_diff` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Solo campos modificados con [old,new].' CHECK (json_valid(`data_diff`)),
  `fecha_hora` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'Fecha y hora en que se registro el evento.',
  `connection_id` bigint(20) unsigned DEFAULT NULL COMMENT 'CONNECTION_ID() de la sesion.',
  `db_user` varchar(128) NOT NULL COMMENT 'Usuario de base de datos que ejecuto la operacion.',
  `db_host` varchar(128) DEFAULT NULL COMMENT 'Host extraido de USER().',
  `changed_cols` varchar(1024) DEFAULT NULL COMMENT 'Lista CSV de columnas modificadas.',
  `std_reg` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Estado logico del registro',
  PRIMARY KEY (`id_log`),
  KEY `idx_log_id_user_fecha` (`id_user`,`fecha_hora`),
  KEY `idx_log_tabla_fecha` (`tabla`,`fecha_hora`),
  KEY `idx_log_event_uuid` (`event_uuid`),
  KEY `idx_log_tabla_operacion_fecha` (`tabla`,`operacion`,`fecha_hora`),
  CONSTRAINT `fk_log_user_user` FOREIGN KEY (`id_user`) REFERENCES `user_system` (`id_empleado`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `log_user` WRITE;
/*!40000 ALTER TABLE `log_user` DISABLE KEYS */;
INSERT INTO `log_user` VALUES (1,'59a4939d-2876-11f1-95e1-989096ab40dc','22206460','user_system','UPDATE','id_empleado=22206460','{\"id_empleado\": \"22206460\"}','MODIFICAR user_system','UPDATE user_system id_empleado=22206460','{\"id_ai_user\": 1, \"id_empleado\": \"22206460\", \"username\": \"administrador\", \"password\": \"***\", \"tipo\": 1, \"std_reg\": 1}','{\"id_ai_user\": 1, \"id_empleado\": \"22206460\", \"username\": \"admin\", \"password\": \"***\", \"tipo\": 1, \"std_reg\": 1}','{\"username\": [\"administrador\", \"admin\"], \"password\": \"CHANGED\"}','2026-03-25 18:13:36',1427,'u_admin@localhost','localhost','username,password',1),(2,'59ad6287-2876-11f1-95e1-989096ab40dc','22206460','roles_permisos','UPDATE','id=1','{\"id\": 1}','MODIFICAR roles_permisos','UPDATE roles_permisos id=1','{\"id\": 1, \"nombre_rol\": \"ROOT\", \"perm_usuarios_view\": 1, \"perm_usuarios_add\": 1, \"perm_usuarios_edit\": 1, \"perm_usuarios_delete\": 1, \"perm_herramienta_view\": 1, \"perm_herramienta_add\": 1, \"perm_herramienta_edit\": 1, \"perm_herramienta_delete\": 1, \"perm_miembro_view\": 1, \"perm_miembro_add\": 1, \"perm_miembro_edit\": 1, \"perm_miembro_delete\": 1, \"perm_ot_view\": 1, \"perm_ot_add\": 1, \"perm_ot_edit\": 1, \"perm_ot_delete\": 1, \"perm_ot_add_detalle\": 1, \"perm_ot_generar_reporte\": 1, \"perm_ot_add_herramienta\": 1}','{\"id\": 1, \"nombre_rol\": \"ROOT\", \"perm_usuarios_view\": 1, \"perm_usuarios_add\": 1, \"perm_usuarios_edit\": 1, \"perm_usuarios_delete\": 1, \"perm_herramienta_view\": 1, \"perm_herramienta_add\": 1, \"perm_herramienta_edit\": 1, \"perm_herramienta_delete\": 1, \"perm_miembro_view\": 1, \"perm_miembro_add\": 1, \"perm_miembro_edit\": 1, \"perm_miembro_delete\": 1, \"perm_ot_view\": 1, \"perm_ot_add\": 1, \"perm_ot_edit\": 1, \"perm_ot_delete\": 1, \"perm_ot_add_detalle\": 1, \"perm_ot_generar_reporte\": 1, \"perm_ot_add_herramienta\": 1}','{}','2026-03-25 18:13:36',1428,'u_admin@localhost','localhost',NULL,1),(3,'59af0ea4-2876-11f1-95e1-989096ab40dc','22206460','roles_permisos','UPDATE','id=1','{\"id\": 1}','MODIFICAR roles_permisos','UPDATE roles_permisos id=1','{\"id\": 1, \"nombre_rol\": \"ROOT\", \"perm_usuarios_view\": 1, \"perm_usuarios_add\": 1, \"perm_usuarios_edit\": 1, \"perm_usuarios_delete\": 1, \"perm_herramienta_view\": 1, \"perm_herramienta_add\": 1, \"perm_herramienta_edit\": 1, \"perm_herramienta_delete\": 1, \"perm_miembro_view\": 1, \"perm_miembro_add\": 1, \"perm_miembro_edit\": 1, \"perm_miembro_delete\": 1, \"perm_ot_view\": 1, \"perm_ot_add\": 1, \"perm_ot_edit\": 1, \"perm_ot_delete\": 1, \"perm_ot_add_detalle\": 1, \"perm_ot_generar_reporte\": 1, \"perm_ot_add_herramienta\": 1}','{\"id\": 1, \"nombre_rol\": \"ROOT\", \"perm_usuarios_view\": 1, \"perm_usuarios_add\": 1, \"perm_usuarios_edit\": 1, \"perm_usuarios_delete\": 1, \"perm_herramienta_view\": 1, \"perm_herramienta_add\": 1, \"perm_herramienta_edit\": 1, \"perm_herramienta_delete\": 1, \"perm_miembro_view\": 1, \"perm_miembro_add\": 1, \"perm_miembro_edit\": 1, \"perm_miembro_delete\": 1, \"perm_ot_view\": 1, \"perm_ot_add\": 1, \"perm_ot_edit\": 1, \"perm_ot_delete\": 1, \"perm_ot_add_detalle\": 1, \"perm_ot_generar_reporte\": 1, \"perm_ot_add_herramienta\": 1}','{}','2026-03-25 18:13:36',1428,'u_admin@localhost','localhost',NULL,1),(4,'63cc3953-2876-11f1-95e1-989096ab40dc','22206460','roles_permisos','UPDATE','id=1','{\"id\": 1}','MODIFICAR roles_permisos','UPDATE roles_permisos id=1','{\"id\": 1, \"nombre_rol\": \"ROOT\", \"perm_usuarios_view\": 1, \"perm_usuarios_add\": 1, \"perm_usuarios_edit\": 1, \"perm_usuarios_delete\": 1, \"perm_herramienta_view\": 1, \"perm_herramienta_add\": 1, \"perm_herramienta_edit\": 1, \"perm_herramienta_delete\": 1, \"perm_miembro_view\": 1, \"perm_miembro_add\": 1, \"perm_miembro_edit\": 1, \"perm_miembro_delete\": 1, \"perm_ot_view\": 1, \"perm_ot_add\": 1, \"perm_ot_edit\": 1, \"perm_ot_delete\": 1, \"perm_ot_add_detalle\": 1, \"perm_ot_generar_reporte\": 1, \"perm_ot_add_herramienta\": 1}','{\"id\": 1, \"nombre_rol\": \"ROOT\", \"perm_usuarios_view\": 1, \"perm_usuarios_add\": 1, \"perm_usuarios_edit\": 1, \"perm_usuarios_delete\": 1, \"perm_herramienta_view\": 1, \"perm_herramienta_add\": 1, \"perm_herramienta_edit\": 1, \"perm_herramienta_delete\": 1, \"perm_miembro_view\": 1, \"perm_miembro_add\": 1, \"perm_miembro_edit\": 1, \"perm_miembro_delete\": 1, \"perm_ot_view\": 1, \"perm_ot_add\": 1, \"perm_ot_edit\": 1, \"perm_ot_delete\": 1, \"perm_ot_add_detalle\": 1, \"perm_ot_generar_reporte\": 1, \"perm_ot_add_herramienta\": 1}','{}','2026-03-25 18:13:53',1429,'u_admin@localhost','localhost',NULL,1),(5,'63ccf011-2876-11f1-95e1-989096ab40dc','22206460','roles_permisos','UPDATE','id=1','{\"id\": 1}','MODIFICAR roles_permisos','UPDATE roles_permisos id=1','{\"id\": 1, \"nombre_rol\": \"ROOT\", \"perm_usuarios_view\": 1, \"perm_usuarios_add\": 1, \"perm_usuarios_edit\": 1, \"perm_usuarios_delete\": 1, \"perm_herramienta_view\": 1, \"perm_herramienta_add\": 1, \"perm_herramienta_edit\": 1, \"perm_herramienta_delete\": 1, \"perm_miembro_view\": 1, \"perm_miembro_add\": 1, \"perm_miembro_edit\": 1, \"perm_miembro_delete\": 1, \"perm_ot_view\": 1, \"perm_ot_add\": 1, \"perm_ot_edit\": 1, \"perm_ot_delete\": 1, \"perm_ot_add_detalle\": 1, \"perm_ot_generar_reporte\": 1, \"perm_ot_add_herramienta\": 1}','{\"id\": 1, \"nombre_rol\": \"ROOT\", \"perm_usuarios_view\": 1, \"perm_usuarios_add\": 1, \"perm_usuarios_edit\": 1, \"perm_usuarios_delete\": 1, \"perm_herramienta_view\": 1, \"perm_herramienta_add\": 1, \"perm_herramienta_edit\": 1, \"perm_herramienta_delete\": 1, \"perm_miembro_view\": 1, \"perm_miembro_add\": 1, \"perm_miembro_edit\": 1, \"perm_miembro_delete\": 1, \"perm_ot_view\": 1, \"perm_ot_add\": 1, \"perm_ot_edit\": 1, \"perm_ot_delete\": 1, \"perm_ot_add_detalle\": 1, \"perm_ot_generar_reporte\": 1, \"perm_ot_add_herramienta\": 1}','{}','2026-03-25 18:13:53',1429,'u_admin@localhost','localhost',NULL,1),(6,'63dbd496-2876-11f1-95e1-989096ab40dc','22206460','user_system','UPDATE','id_empleado=22206460','{\"id_empleado\": \"22206460\"}','MODIFICAR user_system','UPDATE user_system id_empleado=22206460','{\"id_ai_user\": 1, \"id_empleado\": \"22206460\", \"username\": \"admin\", \"password\": \"***\", \"tipo\": 1, \"std_reg\": 1}','{\"id_ai_user\": 1, \"id_empleado\": \"22206460\", \"username\": \"admin\", \"password\": \"***\", \"tipo\": 1, \"std_reg\": 1}','{}','2026-03-25 18:13:53',1429,'u_admin@localhost','localhost',NULL,1),(7,'63de89a9-2876-11f1-95e1-989096ab40dc','22206460','auth_session','UNKNOWN','id_empleado=22206460','{\"id_empleado\":\"22206460\"}','LOGIN_INTENTO_FALLIDO','Clave incorrecta en inicio de sesion.',NULL,'{\"username\":\"ADMIN\",\"ip\":\"::1\",\"user_agent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36\",\"timestamp\":\"2026-03-25 14:13:53\",\"failed_login_attempts\":1,\"remaining_attempts\":2}','{\"username\":\"ADMIN\",\"ip\":\"::1\",\"user_agent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36\",\"timestamp\":\"2026-03-25 14:13:53\",\"failed_login_attempts\":1,\"remaining_attempts\":2}','2026-03-25 18:13:53',1429,'u_admin','localhost','failed_login_attempts,remaining_attempts',1),(8,'6b54cfc5-2876-11f1-95e1-989096ab40dc','22206460','roles_permisos','UPDATE','id=1','{\"id\": 1}','MODIFICAR roles_permisos','UPDATE roles_permisos id=1','{\"id\": 1, \"nombre_rol\": \"ROOT\", \"perm_usuarios_view\": 1, \"perm_usuarios_add\": 1, \"perm_usuarios_edit\": 1, \"perm_usuarios_delete\": 1, \"perm_herramienta_view\": 1, \"perm_herramienta_add\": 1, \"perm_herramienta_edit\": 1, \"perm_herramienta_delete\": 1, \"perm_miembro_view\": 1, \"perm_miembro_add\": 1, \"perm_miembro_edit\": 1, \"perm_miembro_delete\": 1, \"perm_ot_view\": 1, \"perm_ot_add\": 1, \"perm_ot_edit\": 1, \"perm_ot_delete\": 1, \"perm_ot_add_detalle\": 1, \"perm_ot_generar_reporte\": 1, \"perm_ot_add_herramienta\": 1}','{\"id\": 1, \"nombre_rol\": \"ROOT\", \"perm_usuarios_view\": 1, \"perm_usuarios_add\": 1, \"perm_usuarios_edit\": 1, \"perm_usuarios_delete\": 1, \"perm_herramienta_view\": 1, \"perm_herramienta_add\": 1, \"perm_herramienta_edit\": 1, \"perm_herramienta_delete\": 1, \"perm_miembro_view\": 1, \"perm_miembro_add\": 1, \"perm_miembro_edit\": 1, \"perm_miembro_delete\": 1, \"perm_ot_view\": 1, \"perm_ot_add\": 1, \"perm_ot_edit\": 1, \"perm_ot_delete\": 1, \"perm_ot_add_detalle\": 1, \"perm_ot_generar_reporte\": 1, \"perm_ot_add_herramienta\": 1}','{}','2026-03-25 18:14:05',1431,'u_admin@localhost','localhost',NULL,1),(9,'6b559a8b-2876-11f1-95e1-989096ab40dc','22206460','roles_permisos','UPDATE','id=1','{\"id\": 1}','MODIFICAR roles_permisos','UPDATE roles_permisos id=1','{\"id\": 1, \"nombre_rol\": \"ROOT\", \"perm_usuarios_view\": 1, \"perm_usuarios_add\": 1, \"perm_usuarios_edit\": 1, \"perm_usuarios_delete\": 1, \"perm_herramienta_view\": 1, \"perm_herramienta_add\": 1, \"perm_herramienta_edit\": 1, \"perm_herramienta_delete\": 1, \"perm_miembro_view\": 1, \"perm_miembro_add\": 1, \"perm_miembro_edit\": 1, \"perm_miembro_delete\": 1, \"perm_ot_view\": 1, \"perm_ot_add\": 1, \"perm_ot_edit\": 1, \"perm_ot_delete\": 1, \"perm_ot_add_detalle\": 1, \"perm_ot_generar_reporte\": 1, \"perm_ot_add_herramienta\": 1}','{\"id\": 1, \"nombre_rol\": \"ROOT\", \"perm_usuarios_view\": 1, \"perm_usuarios_add\": 1, \"perm_usuarios_edit\": 1, \"perm_usuarios_delete\": 1, \"perm_herramienta_view\": 1, \"perm_herramienta_add\": 1, \"perm_herramienta_edit\": 1, \"perm_herramienta_delete\": 1, \"perm_miembro_view\": 1, \"perm_miembro_add\": 1, \"perm_miembro_edit\": 1, \"perm_miembro_delete\": 1, \"perm_ot_view\": 1, \"perm_ot_add\": 1, \"perm_ot_edit\": 1, \"perm_ot_delete\": 1, \"perm_ot_add_detalle\": 1, \"perm_ot_generar_reporte\": 1, \"perm_ot_add_herramienta\": 1}','{}','2026-03-25 18:14:05',1431,'u_admin@localhost','localhost',NULL,1),(10,'6b66b11d-2876-11f1-95e1-989096ab40dc','22206460','user_system','UPDATE','id_empleado=22206460','{\"id_empleado\": \"22206460\"}','MODIFICAR user_system','UPDATE user_system id_empleado=22206460','{\"id_ai_user\": 1, \"id_empleado\": \"22206460\", \"username\": \"admin\", \"password\": \"***\", \"tipo\": 1, \"std_reg\": 1}','{\"id_ai_user\": 1, \"id_empleado\": \"22206460\", \"username\": \"admin\", \"password\": \"***\", \"tipo\": 1, \"std_reg\": 1}','{}','2026-03-25 18:14:05',1431,'u_admin@localhost','localhost',NULL,1),(11,'6b69410b-2876-11f1-95e1-989096ab40dc','22206460','auth_session','UNKNOWN','id_empleado=22206460','{\"id_empleado\":\"22206460\"}','LOGIN_EXITOSO','Inicio de sesion exitoso.',NULL,'{\"username\":\"admin\",\"ip\":\"::1\",\"user_agent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36\",\"timestamp\":\"2026-03-25 14:14:05\",\"rol\":\"ROOT\",\"tipo\":1}','{\"username\":\"admin\",\"ip\":\"::1\",\"user_agent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36\",\"timestamp\":\"2026-03-25 14:14:05\",\"rol\":\"ROOT\",\"tipo\":1}','2026-03-25 18:14:05',1431,'u_admin','localhost','rol,tipo',1),(12,'75599f63-2876-11f1-95e1-989096ab40dc','22206460','user_system','UPDATE','id_empleado=22206460','{\"id_empleado\": \"22206460\"}','MODIFICAR user_system','UPDATE user_system id_empleado=22206460','{\"id_ai_user\": 1, \"id_empleado\": \"22206460\", \"username\": \"admin\", \"password\": \"***\", \"tipo\": 1, \"std_reg\": 1}','{\"id_ai_user\": 1, \"id_empleado\": \"22206460\", \"username\": \"admin\", \"password\": \"***\", \"tipo\": 1, \"std_reg\": 1}','{\"password\": \"CHANGED\"}','2026-03-25 18:14:22',1456,'u_admin@localhost','localhost','password',1),(13,'756301cc-2876-11f1-95e1-989096ab40dc','22206460','roles_permisos','UPDATE','id=1','{\"id\": 1}','MODIFICAR roles_permisos','UPDATE roles_permisos id=1','{\"id\": 1, \"nombre_rol\": \"ROOT\", \"perm_usuarios_view\": 1, \"perm_usuarios_add\": 1, \"perm_usuarios_edit\": 1, \"perm_usuarios_delete\": 1, \"perm_herramienta_view\": 1, \"perm_herramienta_add\": 1, \"perm_herramienta_edit\": 1, \"perm_herramienta_delete\": 1, \"perm_miembro_view\": 1, \"perm_miembro_add\": 1, \"perm_miembro_edit\": 1, \"perm_miembro_delete\": 1, \"perm_ot_view\": 1, \"perm_ot_add\": 1, \"perm_ot_edit\": 1, \"perm_ot_delete\": 1, \"perm_ot_add_detalle\": 1, \"perm_ot_generar_reporte\": 1, \"perm_ot_add_herramienta\": 1}','{\"id\": 1, \"nombre_rol\": \"ROOT\", \"perm_usuarios_view\": 1, \"perm_usuarios_add\": 1, \"perm_usuarios_edit\": 1, \"perm_usuarios_delete\": 1, \"perm_herramienta_view\": 1, \"perm_herramienta_add\": 1, \"perm_herramienta_edit\": 1, \"perm_herramienta_delete\": 1, \"perm_miembro_view\": 1, \"perm_miembro_add\": 1, \"perm_miembro_edit\": 1, \"perm_miembro_delete\": 1, \"perm_ot_view\": 1, \"perm_ot_add\": 1, \"perm_ot_edit\": 1, \"perm_ot_delete\": 1, \"perm_ot_add_detalle\": 1, \"perm_ot_generar_reporte\": 1, \"perm_ot_add_herramienta\": 1}','{}','2026-03-25 18:14:22',1457,'u_admin@localhost','localhost',NULL,1),(14,'7563eede-2876-11f1-95e1-989096ab40dc','22206460','roles_permisos','UPDATE','id=1','{\"id\": 1}','MODIFICAR roles_permisos','UPDATE roles_permisos id=1','{\"id\": 1, \"nombre_rol\": \"ROOT\", \"perm_usuarios_view\": 1, \"perm_usuarios_add\": 1, \"perm_usuarios_edit\": 1, \"perm_usuarios_delete\": 1, \"perm_herramienta_view\": 1, \"perm_herramienta_add\": 1, \"perm_herramienta_edit\": 1, \"perm_herramienta_delete\": 1, \"perm_miembro_view\": 1, \"perm_miembro_add\": 1, \"perm_miembro_edit\": 1, \"perm_miembro_delete\": 1, \"perm_ot_view\": 1, \"perm_ot_add\": 1, \"perm_ot_edit\": 1, \"perm_ot_delete\": 1, \"perm_ot_add_detalle\": 1, \"perm_ot_generar_reporte\": 1, \"perm_ot_add_herramienta\": 1}','{\"id\": 1, \"nombre_rol\": \"ROOT\", \"perm_usuarios_view\": 1, \"perm_usuarios_add\": 1, \"perm_usuarios_edit\": 1, \"perm_usuarios_delete\": 1, \"perm_herramienta_view\": 1, \"perm_herramienta_add\": 1, \"perm_herramienta_edit\": 1, \"perm_herramienta_delete\": 1, \"perm_miembro_view\": 1, \"perm_miembro_add\": 1, \"perm_miembro_edit\": 1, \"perm_miembro_delete\": 1, \"perm_ot_view\": 1, \"perm_ot_add\": 1, \"perm_ot_edit\": 1, \"perm_ot_delete\": 1, \"perm_ot_add_detalle\": 1, \"perm_ot_generar_reporte\": 1, \"perm_ot_add_herramienta\": 1}','{}','2026-03-25 18:14:22',1457,'u_admin@localhost','localhost',NULL,1),(15,'7a9ae81e-2876-11f1-95e1-989096ab40dc','22206460','roles_permisos','UPDATE','id=1','{\"id\": 1}','MODIFICAR roles_permisos','UPDATE roles_permisos id=1','{\"id\": 1, \"nombre_rol\": \"ROOT\", \"perm_usuarios_view\": 1, \"perm_usuarios_add\": 1, \"perm_usuarios_edit\": 1, \"perm_usuarios_delete\": 1, \"perm_herramienta_view\": 1, \"perm_herramienta_add\": 1, \"perm_herramienta_edit\": 1, \"perm_herramienta_delete\": 1, \"perm_miembro_view\": 1, \"perm_miembro_add\": 1, \"perm_miembro_edit\": 1, \"perm_miembro_delete\": 1, \"perm_ot_view\": 1, \"perm_ot_add\": 1, \"perm_ot_edit\": 1, \"perm_ot_delete\": 1, \"perm_ot_add_detalle\": 1, \"perm_ot_generar_reporte\": 1, \"perm_ot_add_herramienta\": 1}','{\"id\": 1, \"nombre_rol\": \"ROOT\", \"perm_usuarios_view\": 1, \"perm_usuarios_add\": 1, \"perm_usuarios_edit\": 1, \"perm_usuarios_delete\": 1, \"perm_herramienta_view\": 1, \"perm_herramienta_add\": 1, \"perm_herramienta_edit\": 1, \"perm_herramienta_delete\": 1, \"perm_miembro_view\": 1, \"perm_miembro_add\": 1, \"perm_miembro_edit\": 1, \"perm_miembro_delete\": 1, \"perm_ot_view\": 1, \"perm_ot_add\": 1, \"perm_ot_edit\": 1, \"perm_ot_delete\": 1, \"perm_ot_add_detalle\": 1, \"perm_ot_generar_reporte\": 1, \"perm_ot_add_herramienta\": 1}','{}','2026-03-25 18:14:31',1458,'u_admin@localhost','localhost',NULL,1),(16,'7a9bb990-2876-11f1-95e1-989096ab40dc','22206460','roles_permisos','UPDATE','id=1','{\"id\": 1}','MODIFICAR roles_permisos','UPDATE roles_permisos id=1','{\"id\": 1, \"nombre_rol\": \"ROOT\", \"perm_usuarios_view\": 1, \"perm_usuarios_add\": 1, \"perm_usuarios_edit\": 1, \"perm_usuarios_delete\": 1, \"perm_herramienta_view\": 1, \"perm_herramienta_add\": 1, \"perm_herramienta_edit\": 1, \"perm_herramienta_delete\": 1, \"perm_miembro_view\": 1, \"perm_miembro_add\": 1, \"perm_miembro_edit\": 1, \"perm_miembro_delete\": 1, \"perm_ot_view\": 1, \"perm_ot_add\": 1, \"perm_ot_edit\": 1, \"perm_ot_delete\": 1, \"perm_ot_add_detalle\": 1, \"perm_ot_generar_reporte\": 1, \"perm_ot_add_herramienta\": 1}','{\"id\": 1, \"nombre_rol\": \"ROOT\", \"perm_usuarios_view\": 1, \"perm_usuarios_add\": 1, \"perm_usuarios_edit\": 1, \"perm_usuarios_delete\": 1, \"perm_herramienta_view\": 1, \"perm_herramienta_add\": 1, \"perm_herramienta_edit\": 1, \"perm_herramienta_delete\": 1, \"perm_miembro_view\": 1, \"perm_miembro_add\": 1, \"perm_miembro_edit\": 1, \"perm_miembro_delete\": 1, \"perm_ot_view\": 1, \"perm_ot_add\": 1, \"perm_ot_edit\": 1, \"perm_ot_delete\": 1, \"perm_ot_add_detalle\": 1, \"perm_ot_generar_reporte\": 1, \"perm_ot_add_herramienta\": 1}','{}','2026-03-25 18:14:31',1458,'u_admin@localhost','localhost',NULL,1),(17,'7ab15ebb-2876-11f1-95e1-989096ab40dc','22206460','user_system','UPDATE','id_empleado=22206460','{\"id_empleado\": \"22206460\"}','MODIFICAR user_system','UPDATE user_system id_empleado=22206460','{\"id_ai_user\": 1, \"id_empleado\": \"22206460\", \"username\": \"admin\", \"password\": \"***\", \"tipo\": 1, \"std_reg\": 1}','{\"id_ai_user\": 1, \"id_empleado\": \"22206460\", \"username\": \"admin\", \"password\": \"***\", \"tipo\": 1, \"std_reg\": 1}','{}','2026-03-25 18:14:31',1458,'u_admin@localhost','localhost',NULL,1),(18,'7ab3e36e-2876-11f1-95e1-989096ab40dc','22206460','auth_session','UNKNOWN','id_empleado=22206460','{\"id_empleado\":\"22206460\"}','LOGIN_EXITOSO','Inicio de sesion exitoso.',NULL,'{\"username\":\"admin\",\"ip\":\"::1\",\"user_agent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36\",\"timestamp\":\"2026-03-25 14:14:31\",\"rol\":\"ROOT\",\"tipo\":1}','{\"username\":\"admin\",\"ip\":\"::1\",\"user_agent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36\",\"timestamp\":\"2026-03-25 14:14:31\",\"rol\":\"ROOT\",\"tipo\":1}','2026-03-25 18:14:31',1458,'u_admin','localhost','rol,tipo',1);
/*!40000 ALTER TABLE `log_user` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_log_user_no_update` BEFORE UPDATE ON `log_user` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite modificar registros de auditoria (log_user).' */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_log_user_no_delete` BEFORE DELETE ON `log_user` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite eliminar registros de auditoria (log_user).' */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
DROP TABLE IF EXISTS `miembro`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `miembro` (
  `id_ai_miembro` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable',
  `id_miembro` varchar(10) NOT NULL COMMENT 'Identificador unico del miembro',
  `id_empleado` varchar(30) DEFAULT NULL COMMENT 'Identificador unico del empleado asociado al miembro',
  `nombre_miembro` varchar(40) NOT NULL COMMENT 'Nombre completo del miembro',
  `tipo_miembro` int(11) NOT NULL COMMENT 'Tipo de miembro (por ejemplo, CCO, CCF, etc.)',
  `std_reg` tinyint(1) NOT NULL COMMENT 'Estado logico del registro (1=activo, 0=inactivo/eliminado logico).',
  PRIMARY KEY (`id_ai_miembro`),
  UNIQUE KEY `id_miembro` (`id_miembro`),
  UNIQUE KEY `uk_miembro_id_empleado` (`id_empleado`),
  KEY `idx_miembro_tipo_std` (`tipo_miembro`,`std_reg`),
  CONSTRAINT `fk_miembro_empleado` FOREIGN KEY (`id_empleado`) REFERENCES `empleado` (`id_empleado`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `miembro` WRITE;
/*!40000 ALTER TABLE `miembro` DISABLE KEYS */;
INSERT INTO `miembro` VALUES (1,'M-001','30114567','CARLA MENDOZA',1,1),(2,'M-002','29654781','JOSE PENA',2,1),(3,'M-003','31890245','LUIS RAMIREZ',1,1),(4,'M-004','28765431','MARIA FERNANDEZ',2,1),(5,'M-005','27411890','ANDRES PEREZ',1,1),(6,'M-006','29987456','DIANA RODRIGUEZ',2,1),(7,'M-007','31244780','OSCAR SALAZAR',1,1),(8,'M-008','30599871','ELIANA TORRES',2,1);
/*!40000 ALTER TABLE `miembro` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_miembro_ai` AFTER INSERT ON `miembro` FOR EACH ROW INSERT INTO `log_user`(
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
) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_miembro_au` AFTER UPDATE ON `miembro` FOR EACH ROW INSERT INTO `log_user`(
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
) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_miembro_bd` BEFORE DELETE ON `miembro` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE fisico en miembro. Use eliminacion logica (UPDATE miembro SET std_reg=0 ...).' */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
DROP TABLE IF EXISTS `orden_trabajo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `orden_trabajo` (
  `id_ai_ot` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable',
  `n_ot` varchar(30) NOT NULL COMMENT 'Numero unico de la orden de trabajo',
  `id_ai_area` int(11) NOT NULL COMMENT 'Area de trabajo responsable de la orden',
  `id_user` varchar(30) NOT NULL COMMENT 'Identificador unico del usuario del sistema',
  `id_ai_sitio` int(11) NOT NULL COMMENT 'Identificador unico del sitio de trabajo',
  `id_ai_estado` int(11) NOT NULL COMMENT 'Estado operativo actual de la orden de trabajo',
  `nombre_trab` varchar(500) NOT NULL COMMENT 'Descripcion o nombre del trabajo a realizar',
  `fecha` date NOT NULL COMMENT 'Fecha programada de la orden de trabajo',
  `semana` varchar(100) NOT NULL COMMENT 'Semana del ano correspondiente a la orden',
  `mes` varchar(100) NOT NULL COMMENT 'Mes correspondiente a la orden de trabajo',
  `ot_finalizada` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Indica si la orden de trabajo fue finalizada (1=si, 0=no).',
  `fecha_finalizacion` datetime DEFAULT NULL COMMENT 'Fecha y hora en que se finalizo la orden de trabajo.',
  `id_user_finaliza` varchar(30) DEFAULT NULL COMMENT 'Identificador unico del usuario que finalizo la orden de trabajo.',
  `std_reg` tinyint(1) NOT NULL COMMENT 'Estado logico del registro (1=activo, 0=inactivo/eliminado logico).',
  PRIMARY KEY (`id_ai_ot`),
  UNIQUE KEY `n_ot` (`n_ot`),
  KEY `status` (`std_reg`),
  KEY `id_user` (`id_user`),
  KEY `sitio_trab` (`id_ai_sitio`),
  KEY `id_area` (`id_ai_area`),
  KEY `idx_orden_trabajo_finalizada` (`ot_finalizada`,`std_reg`),
  KEY `idx_orden_trabajo_estado` (`id_ai_estado`,`std_reg`),
  CONSTRAINT `orden_trabajo_ibfk_1` FOREIGN KEY (`id_user`) REFERENCES `user_system` (`id_empleado`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `orden_trabajo_ibfk_2` FOREIGN KEY (`id_ai_sitio`) REFERENCES `sitio_trabajo` (`id_ai_sitio`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `orden_trabajo_ibfk_3` FOREIGN KEY (`id_ai_area`) REFERENCES `area_trabajo` (`id_ai_area`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `orden_trabajo_ibfk_4` FOREIGN KEY (`id_ai_estado`) REFERENCES `estado_ot` (`id_ai_estado`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `orden_trabajo` WRITE;
/*!40000 ALTER TABLE `orden_trabajo` DISABLE KEYS */;
INSERT INTO `orden_trabajo` VALUES (1,'VF-SEN-001',1,'8840285',2,2,'INSPECCION Y AJUSTE DE BALIZAS EN TRAMO SUR','2026-03-16','12','3',0,NULL,NULL,1),(2,'VF-SEN-002',1,'26580187',5,12,'CALIBRACION DE CIRCUITO DE ANUNCIO EN ESTACION CEDENO','2026-03-17','12','3',0,NULL,NULL,1),(3,'VF-APV-001',2,'8840285',1,1,'LUBRICACION Y AJUSTE DE CAMBIO 04 EN PATIO OPERACIONAL','2026-03-18','12','3',1,'2026-03-22 17:03:33','8840285',1),(4,'VF-APV-002',2,'26580187',3,3,'SUSTITUCION PROGRAMADA DE PERNOS EN DESVIO NORTE','2026-03-19','12','3',0,NULL,NULL,1),(5,'VF-INF-001',3,'8840285',4,2,'CORRECCION DE FILTRACION EN CANALETA TECNICA','2026-03-20','12','3',0,NULL,NULL,1),(6,'VF-INF-002',3,'26580187',2,1,'RESANE DE BORDE Y REPOSICION DE TAPAS DE REGISTRO EN ANDEN','2026-03-21','12','3',1,'2026-03-22 17:03:33','26580187',1),(7,'VF-NP-001',5,'8840285',1,4,'ATENCION DE FALLA EN TOMA DE ENERGIA DE TALLER LIGERO','2026-03-21','12','3',0,NULL,NULL,1),(8,'VF-NP-002',5,'26580187',2,2,'REVISION DE GABINETE DE COMUNICACIONES POR ALARMA INTERMITENTE','2026-03-22','12','3',0,NULL,NULL,1);
/*!40000 ALTER TABLE `orden_trabajo` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_orden_trabajo_ai` AFTER INSERT ON `orden_trabajo` FOR EACH ROW BEGIN
  INSERT INTO log_user(
    event_uuid, id_user, tabla, operacion, pk_registro, pk_json,
    accion, resp_system,
    data_old, data_new, data_diff, changed_cols,
    connection_id, db_user, db_host
  ) VALUES (
    UUID(),
    (SELECT id_empleado FROM user_system WHERE id_empleado = @app_user LIMIT 1),
    'orden_trabajo',
    'INSERT',
    CONCAT('n_ot=', NEW.n_ot),
    JSON_OBJECT('n_ot', NEW.n_ot),
    'CREAR orden_trabajo',
    CONCAT('INSERT orden_trabajo n_ot=', NEW.n_ot),
    NULL,
    JSON_OBJECT(
      'id_ai_ot', NEW.id_ai_ot,
      'n_ot', NEW.n_ot,
      'id_ai_area', NEW.id_ai_area,
      'id_user', NEW.id_user,
      'id_ai_sitio', NEW.id_ai_sitio,
      'id_ai_estado', NEW.id_ai_estado,
      'nombre_trab', NEW.nombre_trab,
      'fecha', NEW.fecha,
      'semana', NEW.semana,
      'mes', NEW.mes,
      'ot_finalizada', NEW.ot_finalizada,
      'fecha_finalizacion', NEW.fecha_finalizacion,
      'id_user_finaliza', NEW.id_user_finaliza,
      'std_reg', NEW.std_reg
    ),
    JSON_OBJECT(
      'id_ai_ot', NEW.id_ai_ot,
      'n_ot', NEW.n_ot,
      'id_ai_area', NEW.id_ai_area,
      'id_user', NEW.id_user,
      'id_ai_sitio', NEW.id_ai_sitio,
      'id_ai_estado', NEW.id_ai_estado,
      'nombre_trab', NEW.nombre_trab,
      'fecha', NEW.fecha,
      'semana', NEW.semana,
      'mes', NEW.mes,
      'ot_finalizada', NEW.ot_finalizada,
      'fecha_finalizacion', NEW.fecha_finalizacion,
      'id_user_finaliza', NEW.id_user_finaliza,
      'std_reg', NEW.std_reg
    ),
    'id_ai_ot,n_ot,id_ai_area,id_user,id_ai_sitio,id_ai_estado,nombre_trab,fecha,semana,mes,ot_finalizada,fecha_finalizacion,id_user_finaliza,std_reg',
    CONNECTION_ID(),
    USER(),
    SUBSTRING_INDEX(USER(), '@', -1)
  );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_orden_trabajo_au` AFTER UPDATE ON `orden_trabajo` FOR EACH ROW BEGIN
  INSERT INTO log_user(
    event_uuid, id_user, tabla, operacion, pk_registro, pk_json,
    accion, resp_system,
    data_old, data_new, data_diff, changed_cols,
    connection_id, db_user, db_host
  ) VALUES (
    UUID(),
    (SELECT id_empleado FROM user_system WHERE id_empleado = @app_user LIMIT 1),
    'orden_trabajo',
    CASE
      WHEN NEW.std_reg = 0 AND OLD.std_reg = 1 THEN 'SOFT_DELETE'
      WHEN NEW.std_reg = 1 AND OLD.std_reg = 0 THEN 'RESTORE'
      ELSE 'UPDATE'
    END,
    CONCAT('n_ot=', NEW.n_ot),
    JSON_OBJECT('n_ot', NEW.n_ot),
    CASE
      WHEN NEW.std_reg = 0 AND OLD.std_reg = 1 THEN 'ELIMINAR (LOGICO) orden_trabajo'
      WHEN NEW.std_reg = 1 AND OLD.std_reg = 0 THEN 'REACTIVAR orden_trabajo'
      ELSE 'MODIFICAR orden_trabajo'
    END,
    CASE
      WHEN NEW.std_reg = 0 AND OLD.std_reg = 1 THEN CONCAT('SOFT_DELETE orden_trabajo n_ot=', NEW.n_ot)
      WHEN NEW.std_reg = 1 AND OLD.std_reg = 0 THEN CONCAT('RESTORE orden_trabajo n_ot=', NEW.n_ot)
      ELSE CONCAT('UPDATE orden_trabajo n_ot=', NEW.n_ot)
    END,
    JSON_OBJECT(
      'id_ai_ot', OLD.id_ai_ot,
      'n_ot', OLD.n_ot,
      'id_ai_area', OLD.id_ai_area,
      'id_user', OLD.id_user,
      'id_ai_sitio', OLD.id_ai_sitio,
      'id_ai_estado', OLD.id_ai_estado,
      'nombre_trab', OLD.nombre_trab,
      'fecha', OLD.fecha,
      'semana', OLD.semana,
      'mes', OLD.mes,
      'ot_finalizada', OLD.ot_finalizada,
      'fecha_finalizacion', OLD.fecha_finalizacion,
      'id_user_finaliza', OLD.id_user_finaliza,
      'std_reg', OLD.std_reg
    ),
    JSON_OBJECT(
      'id_ai_ot', NEW.id_ai_ot,
      'n_ot', NEW.n_ot,
      'id_ai_area', NEW.id_ai_area,
      'id_user', NEW.id_user,
      'id_ai_sitio', NEW.id_ai_sitio,
      'id_ai_estado', NEW.id_ai_estado,
      'nombre_trab', NEW.nombre_trab,
      'fecha', NEW.fecha,
      'semana', NEW.semana,
      'mes', NEW.mes,
      'ot_finalizada', NEW.ot_finalizada,
      'fecha_finalizacion', NEW.fecha_finalizacion,
      'id_user_finaliza', NEW.id_user_finaliza,
      'std_reg', NEW.std_reg
    ),
    JSON_MERGE_PATCH(
      JSON_MERGE_PATCH(
        JSON_MERGE_PATCH(
          JSON_MERGE_PATCH(
            JSON_MERGE_PATCH(
              JSON_MERGE_PATCH(
                JSON_MERGE_PATCH(
                  JSON_MERGE_PATCH(
                    JSON_MERGE_PATCH(
                      JSON_MERGE_PATCH(
                        JSON_MERGE_PATCH(
                          JSON_MERGE_PATCH(
                            JSON_MERGE_PATCH(
                              JSON_OBJECT(),
                              IF(NOT (OLD.id_ai_ot <=> NEW.id_ai_ot), JSON_OBJECT('id_ai_ot', JSON_ARRAY(OLD.id_ai_ot, NEW.id_ai_ot)), JSON_OBJECT())
                            ),
                            IF(NOT (OLD.n_ot <=> NEW.n_ot), JSON_OBJECT('n_ot', JSON_ARRAY(OLD.n_ot, NEW.n_ot)), JSON_OBJECT())
                          ),
                          IF(NOT (OLD.id_ai_area <=> NEW.id_ai_area), JSON_OBJECT('id_ai_area', JSON_ARRAY(OLD.id_ai_area, NEW.id_ai_area)), JSON_OBJECT())
                        ),
                        IF(NOT (OLD.id_user <=> NEW.id_user), JSON_OBJECT('id_user', JSON_ARRAY(OLD.id_user, NEW.id_user)), JSON_OBJECT())
                      ),
                      IF(NOT (OLD.id_ai_sitio <=> NEW.id_ai_sitio), JSON_OBJECT('id_ai_sitio', JSON_ARRAY(OLD.id_ai_sitio, NEW.id_ai_sitio)), JSON_OBJECT())
                    ),
                    IF(NOT (OLD.id_ai_estado <=> NEW.id_ai_estado), JSON_OBJECT('id_ai_estado', JSON_ARRAY(OLD.id_ai_estado, NEW.id_ai_estado)), JSON_OBJECT())
                  ),
                  IF(NOT (OLD.nombre_trab <=> NEW.nombre_trab), JSON_OBJECT('nombre_trab', JSON_ARRAY(OLD.nombre_trab, NEW.nombre_trab)), JSON_OBJECT())
                ),
                IF(NOT (OLD.fecha <=> NEW.fecha), JSON_OBJECT('fecha', JSON_ARRAY(OLD.fecha, NEW.fecha)), JSON_OBJECT())
              ),
              IF(NOT (OLD.semana <=> NEW.semana), JSON_OBJECT('semana', JSON_ARRAY(OLD.semana, NEW.semana)), JSON_OBJECT())
            ),
            IF(NOT (OLD.mes <=> NEW.mes), JSON_OBJECT('mes', JSON_ARRAY(OLD.mes, NEW.mes)), JSON_OBJECT())
          ),
          IF(NOT (OLD.ot_finalizada <=> NEW.ot_finalizada), JSON_OBJECT('ot_finalizada', JSON_ARRAY(OLD.ot_finalizada, NEW.ot_finalizada)), JSON_OBJECT())
        ),
        JSON_MERGE_PATCH(
          IF(NOT (OLD.fecha_finalizacion <=> NEW.fecha_finalizacion), JSON_OBJECT('fecha_finalizacion', JSON_ARRAY(OLD.fecha_finalizacion, NEW.fecha_finalizacion)), JSON_OBJECT()),
          IF(NOT (OLD.id_user_finaliza <=> NEW.id_user_finaliza), JSON_OBJECT('id_user_finaliza', JSON_ARRAY(OLD.id_user_finaliza, NEW.id_user_finaliza)), JSON_OBJECT())
        )
      ),
      IF(NOT (OLD.std_reg <=> NEW.std_reg), JSON_OBJECT('std_reg', JSON_ARRAY(OLD.std_reg, NEW.std_reg)), JSON_OBJECT())
    ),
    NULLIF(
      CONCAT_WS(',',
        IF(NOT (OLD.id_ai_ot <=> NEW.id_ai_ot), 'id_ai_ot', NULL),
        IF(NOT (OLD.n_ot <=> NEW.n_ot), 'n_ot', NULL),
        IF(NOT (OLD.id_ai_area <=> NEW.id_ai_area), 'id_ai_area', NULL),
        IF(NOT (OLD.id_user <=> NEW.id_user), 'id_user', NULL),
        IF(NOT (OLD.id_ai_sitio <=> NEW.id_ai_sitio), 'id_ai_sitio', NULL),
        IF(NOT (OLD.id_ai_estado <=> NEW.id_ai_estado), 'id_ai_estado', NULL),
        IF(NOT (OLD.nombre_trab <=> NEW.nombre_trab), 'nombre_trab', NULL),
        IF(NOT (OLD.fecha <=> NEW.fecha), 'fecha', NULL),
        IF(NOT (OLD.semana <=> NEW.semana), 'semana', NULL),
        IF(NOT (OLD.mes <=> NEW.mes), 'mes', NULL),
        IF(NOT (OLD.ot_finalizada <=> NEW.ot_finalizada), 'ot_finalizada', NULL),
        IF(NOT (OLD.fecha_finalizacion <=> NEW.fecha_finalizacion), 'fecha_finalizacion', NULL),
        IF(NOT (OLD.id_user_finaliza <=> NEW.id_user_finaliza), 'id_user_finaliza', NULL),
        IF(NOT (OLD.std_reg <=> NEW.std_reg), 'std_reg', NULL)
      ),
      ''
    ),
    CONNECTION_ID(),
    USER(),
    SUBSTRING_INDEX(USER(), '@', -1)
  );
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_orden_trabajo_bd` BEFORE DELETE ON `orden_trabajo` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE fisico en orden_trabajo. Use eliminacion logica (UPDATE orden_trabajo SET std_reg=0 ...).' */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
DROP TABLE IF EXISTS `reporte_generado`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `reporte_generado` (
  `id_ai_reporte_generado` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id autoincrementable del reporte generado',
  `tipo_reporte` varchar(50) NOT NULL COMMENT 'Codigo o tipo funcional del reporte generado',
  `titulo_reporte` varchar(150) NOT NULL COMMENT 'Titulo descriptivo mostrado al usuario para el reporte',
  `nombre_archivo` varchar(255) NOT NULL COMMENT 'Nombre final del archivo PDF generado',
  `ruta_archivo` varchar(255) NOT NULL COMMENT 'Ruta relativa o absoluta donde se almacena el PDF generado',
  `mime_type` varchar(100) NOT NULL DEFAULT 'application/pdf' COMMENT 'Tipo MIME del archivo generado',
  `tamano_bytes` bigint(20) unsigned NOT NULL DEFAULT 0 COMMENT 'Tamano del archivo generado expresado en bytes',
  `parametros_json` longtext DEFAULT NULL COMMENT 'Parametros de entrada usados para construir el reporte',
  `id_user_generador` varchar(30) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT 'Identificador del usuario que genero el reporte',
  `nombre_user_generador` varchar(150) NOT NULL COMMENT 'Nombre visible del usuario que genero el reporte',
  `username_generador` varchar(60) NOT NULL COMMENT 'Nombre de acceso del usuario que genero el reporte',
  `created_at` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Fecha y hora de generacion del reporte',
  `std_reg` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Estado logico del registro (1=activo, 0=inactivo).',
  PRIMARY KEY (`id_ai_reporte_generado`),
  KEY `idx_reporte_generado_fecha` (`created_at`),
  KEY `idx_reporte_generado_tipo` (`tipo_reporte`),
  KEY `idx_reporte_generado_user` (`id_user_generador`),
  CONSTRAINT `reporte_generado_ibfk_1` FOREIGN KEY (`id_user_generador`) REFERENCES `empleado` (`id_empleado`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `reporte_generado` WRITE;
/*!40000 ALTER TABLE `reporte_generado` DISABLE KEYS */;
/*!40000 ALTER TABLE `reporte_generado` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_reporte_generado_ai` AFTER INSERT ON `reporte_generado` FOR EACH ROW INSERT INTO `log_user`(
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
) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_reporte_generado_au` AFTER UPDATE ON `reporte_generado` FOR EACH ROW INSERT INTO `log_user`(
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
) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_reporte_generado_bd` BEFORE DELETE ON `reporte_generado` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE fisico en reporte_generado. Use eliminacion logica (UPDATE reporte_generado SET std_reg=0 ...).' */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
DROP TABLE IF EXISTS `roles_permisos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
  `perm_ot_view` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Permiso para visualizar ordenes de trabajo',
  `perm_ot_add` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Permiso para registrar nuevas ordenes de trabajo',
  `perm_ot_edit` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Permiso para editar ordenes de trabajo',
  `perm_ot_delete` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Permiso para eliminar ordenes de trabajo',
  `perm_ot_add_detalle` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Permiso para agregar detalles a ordenes de trabajo',
  `perm_ot_generar_reporte` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Permiso para generar reportes de ordenes de trabajo',
  `perm_ot_add_herramienta` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Permiso para asociar herramientas a ordenes de trabajo',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `roles_permisos` WRITE;
/*!40000 ALTER TABLE `roles_permisos` DISABLE KEYS */;
INSERT INTO `roles_permisos` VALUES (1,'ROOT',1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1),(18,'SUPERVISOR',1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1),(19,'OPERADOR',0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1);
/*!40000 ALTER TABLE `roles_permisos` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_roles_permisos_ai` AFTER INSERT ON `roles_permisos` FOR EACH ROW INSERT INTO `log_user`(
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
) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_roles_permisos_au` AFTER UPDATE ON `roles_permisos` FOR EACH ROW INSERT INTO `log_user`(
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
) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_roles_permisos_ad` AFTER DELETE ON `roles_permisos` FOR EACH ROW INSERT INTO `log_user`(
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
) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
DROP TABLE IF EXISTS `sitio_trabajo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sitio_trabajo` (
  `id_ai_sitio` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable',
  `nombre_sitio` varchar(100) NOT NULL COMMENT 'Nombre del sitio o ubicacion de trabajo',
  `std_reg` tinyint(1) NOT NULL COMMENT 'Estado logico del registro (1=activo, 0=inactivo/eliminado logico).',
  PRIMARY KEY (`id_ai_sitio`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `sitio_trabajo` WRITE;
/*!40000 ALTER TABLE `sitio_trabajo` DISABLE KEYS */;
INSERT INTO `sitio_trabajo` VALUES (1,'PATIO OPERACIONAL',1),(2,'LINEA 1',1),(3,'TALLER CENTRAL',1),(4,'SUBESTACION SUR',1),(5,'ESTACION CEDENO',1);
/*!40000 ALTER TABLE `sitio_trabajo` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_sitio_trabajo_ai` AFTER INSERT ON `sitio_trabajo` FOR EACH ROW INSERT INTO `log_user`(
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
) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_sitio_trabajo_au` AFTER UPDATE ON `sitio_trabajo` FOR EACH ROW INSERT INTO `log_user`(
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
) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_sitio_trabajo_bd` BEFORE DELETE ON `sitio_trabajo` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE fisico en sitio_trabajo. Use eliminacion logica (UPDATE sitio_trabajo SET std_reg=0 ...).' */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
DROP TABLE IF EXISTS `smtp_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `smtp_config` (
  `id` int(11) NOT NULL COMMENT 'Identificador unico de la configuracion SMTP.',
  `enabled` tinyint(1) NOT NULL DEFAULT 0 COMMENT '1=habilitado, 0=deshabilitado',
  `provider` varchar(30) NOT NULL DEFAULT 'google' COMMENT 'Proveedor (ej: google)',
  `host` varchar(255) NOT NULL DEFAULT 'smtp.gmail.com' COMMENT 'Servidor SMTP',
  `port` int(11) NOT NULL DEFAULT 587 COMMENT 'Puerto SMTP (587 STARTTLS, 465 SSL)',
  `encryption` enum('tls','ssl','none') NOT NULL DEFAULT 'tls' COMMENT 'Metodo de cifrado',
  `username` varchar(255) NOT NULL DEFAULT '' COMMENT 'Usuario/correo SMTP',
  `password` varchar(255) NOT NULL DEFAULT '' COMMENT 'Clave o App Password',
  `from_email` varchar(255) NOT NULL DEFAULT '' COMMENT 'Remitente (From)',
  `from_name` varchar(255) DEFAULT NULL COMMENT 'Nombre remitente',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'Fecha y hora de creacion del registro SMTP.',
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Fecha y hora de ultima actualizacion del registro SMTP.',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `smtp_config` WRITE;
/*!40000 ALTER TABLE `smtp_config` DISABLE KEYS */;
INSERT INTO `smtp_config` VALUES (1,1,'google','smtp.gmail.com',587,'tls','aliguerrerodev@gmail.com','gcm:0PcNOJmDgi8C/lqWWxyLBiHV63Y/fqJMXC2PgqRyBxMHjmhUVB3Ma+r/GU4=','aliguerrerodev@gmail.com','FerreNet System','2026-03-16 14:17:18','2026-03-16 14:46:38');
/*!40000 ALTER TABLE `smtp_config` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `turno_trabajo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `turno_trabajo` (
  `id_ai_turno` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable',
  `nombre_turno` varchar(100) NOT NULL COMMENT 'Nombre descriptivo del turno de trabajo',
  `std_reg` tinyint(1) NOT NULL COMMENT 'Estado logico del registro (1=activo, 0=inactivo/eliminado logico).',
  PRIMARY KEY (`id_ai_turno`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `turno_trabajo` WRITE;
/*!40000 ALTER TABLE `turno_trabajo` DISABLE KEYS */;
INSERT INTO `turno_trabajo` VALUES (1,'MANANA',1),(2,'TARDE',1),(3,'NOCHE',1),(4,'MADRUGADA',1);
/*!40000 ALTER TABLE `turno_trabajo` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_turno_trabajo_ai` AFTER INSERT ON `turno_trabajo` FOR EACH ROW INSERT INTO `log_user`(
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
) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_turno_trabajo_au` AFTER UPDATE ON `turno_trabajo` FOR EACH ROW INSERT INTO `log_user`(
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
) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_turno_trabajo_bd` BEFORE DELETE ON `turno_trabajo` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE fisico en turno_trabajo. Use eliminacion logica (UPDATE turno_trabajo SET std_reg=0 ...).' */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
DROP TABLE IF EXISTS `user_system`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_system` (
  `id_ai_user` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable',
  `id_empleado` varchar(30) NOT NULL COMMENT 'Identificador del empleado asociado al usuario del sistema',
  `username` varchar(50) NOT NULL COMMENT 'Nombre de usuario utilizado para iniciar sesion',
  `password` varchar(60) NOT NULL COMMENT 'Contrasena encriptada del usuario',
  `failed_login_attempts` smallint(5) unsigned NOT NULL DEFAULT 0 COMMENT 'Intentos fallidos consecutivos de login',
  `account_locked` tinyint(1) NOT NULL DEFAULT 0 COMMENT '1=cuenta bloqueada por seguridad',
  `locked_at` datetime DEFAULT NULL COMMENT 'Fecha/hora de bloqueo de la cuenta',
  `password_reset_required` tinyint(1) NOT NULL DEFAULT 0 COMMENT '1=debe recuperar clave para desbloquear',
  `last_login_at` datetime DEFAULT NULL COMMENT 'Ultimo inicio de sesion exitoso',
  `last_login_ip` varchar(45) DEFAULT NULL COMMENT 'IP del ultimo inicio de sesion exitoso',
  `tipo` int(11) NOT NULL COMMENT 'Rol o perfil de permisos asociado al usuario',
  `std_reg` tinyint(1) NOT NULL COMMENT 'Estado logico del registro (1=activo, 0=inactivo/eliminado logico).',
  PRIMARY KEY (`id_ai_user`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `uk_user_system_id_empleado` (`id_empleado`),
  KEY `tipo` (`tipo`),
  KEY `idx_user_system_login_lock` (`username`,`account_locked`,`password_reset_required`),
  CONSTRAINT `fk_user_system_empleado` FOREIGN KEY (`id_empleado`) REFERENCES `empleado` (`id_empleado`) ON UPDATE CASCADE,
  CONSTRAINT `fk_user_system_roles` FOREIGN KEY (`tipo`) REFERENCES `roles_permisos` (`id`),
  CONSTRAINT `user_system_ibfk_1` FOREIGN KEY (`tipo`) REFERENCES `roles_permisos` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `user_system` WRITE;
/*!40000 ALTER TABLE `user_system` DISABLE KEYS */;
INSERT INTO `user_system` VALUES (1,'22206460','admin','$2y$10$ws8nlIr6SZ2OWbA581rRrOY/skpzBJtNLn/Tfz50LOpB6tOGggk0W',0,0,NULL,0,'2026-03-25 14:14:31','::1',1,1),(2,'8840285','manuel','$2y$10$lxd/rybwToLb3Db1sG60fud56CayMxaMy/VOpwhBb0WZwG7v/uOY.',0,0,NULL,0,'2026-03-22 16:27:14','::1',18,1),(4,'26580187','walter','$2y$10$IwC3zzWb.by5LYUIpsLc..PNokUdad2bjT59LsOFO1pQqRrEL9A6W',0,0,NULL,0,NULL,NULL,19,1);
/*!40000 ALTER TABLE `user_system` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_user_system_ai` AFTER INSERT ON `user_system` FOR EACH ROW INSERT INTO `log_user`(
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
) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_user_system_au` AFTER UPDATE ON `user_system` FOR EACH ROW INSERT INTO `log_user`(
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
) */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `trg_user_system_bd` BEFORE DELETE ON `user_system` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE fisico en user_system. Use eliminacion logica (UPDATE user_system SET std_reg=0 ...).' */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
DROP TABLE IF EXISTS `vw_herramienta_disponibilidad`;
/*!50001 DROP VIEW IF EXISTS `vw_herramienta_disponibilidad`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `vw_herramienta_disponibilidad` AS SELECT
 1 AS `id_ai_herramienta`,
  1 AS `nombre_herramienta`,
  1 AS `id_ai_categoria_herramienta`,
  1 AS `nombre_categoria`,
  1 AS `cantidad_total`,
  1 AS `cantidad_ocupada`,
  1 AS `cantidad_disponible`,
  1 AS `ots_activas`,
  1 AS `estado`,
  1 AS `std_reg` */;
SET character_set_client = @saved_cs_client;
DROP TABLE IF EXISTS `vw_herramientas_ocupadas`;
/*!50001 DROP VIEW IF EXISTS `vw_herramientas_ocupadas`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `vw_herramientas_ocupadas` AS SELECT
 1 AS `id_ai_herramientaOT`,
  1 AS `id_ai_herramienta`,
  1 AS `nombre_herramienta`,
  1 AS `n_ot`,
  1 AS `nombre_trab`,
  1 AS `cantidadot`,
  1 AS `estado_ot`,
  1 AS `tecnico_id`,
  1 AS `tecnico_nombre`,
  1 AS `telefono`,
  1 AS `correo`,
  1 AS `direccion`,
  1 AS `estado_herramientaot`,
  1 AS `fecha_ot` */;
SET character_set_client = @saved_cs_client;
DROP TABLE IF EXISTS `vw_log_user_resumen`;
/*!50001 DROP VIEW IF EXISTS `vw_log_user_resumen`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `vw_log_user_resumen` AS SELECT
 1 AS `id_log`,
  1 AS `fecha_hora`,
  1 AS `tabla`,
  1 AS `operacion`,
  1 AS `accion`,
  1 AS `id_user`,
  1 AS `username`,
  1 AS `nombre_empleado`,
  1 AS `db_user`,
  1 AS `db_host`,
  1 AS `changed_cols`,
  1 AS `std_reg` */;
SET character_set_client = @saved_cs_client;
DROP TABLE IF EXISTS `vw_ot_detallada`;
/*!50001 DROP VIEW IF EXISTS `vw_ot_detallada`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `vw_ot_detallada` AS SELECT
 1 AS `id_ai_detalle`,
  1 AS `n_ot`,
  1 AS `id_ai_ot`,
  1 AS `fecha_ot`,
  1 AS `nombre_trab`,
  1 AS `semana`,
  1 AS `mes`,
  1 AS `id_ai_area`,
  1 AS `nombre_area`,
  1 AS `area_nomeclatura`,
  1 AS `id_ai_sitio`,
  1 AS `nombre_sitio`,
  1 AS `id_ai_estado`,
  1 AS `estado_ot`,
  1 AS `color_estado_ot`,
  1 AS `libera_herramientas`,
  1 AS `bloquea_ot`,
  1 AS `fecha_detalle`,
  1 AS `descripcion`,
  1 AS `id_ai_turno`,
  1 AS `nombre_turno`,
  1 AS `id_user_act`,
  1 AS `username_usuario_act`,
  1 AS `usuario_act_nombre`,
  1 AS `id_miembro_cco`,
  1 AS `miembro_cco_nombre`,
  1 AS `id_miembro_ccf`,
  1 AS `miembro_ccf_nombre`,
  1 AS `cant_tec`,
  1 AS `hora_inicio`,
  1 AS `hora_fin`,
  1 AS `observacion`,
  1 AS `ot_finalizada` */;
SET character_set_client = @saved_cs_client;
DROP TABLE IF EXISTS `vw_ot_resumen`;
/*!50001 DROP VIEW IF EXISTS `vw_ot_resumen`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `vw_ot_resumen` AS SELECT
 1 AS `id_ai_ot`,
  1 AS `n_ot`,
  1 AS `fecha`,
  1 AS `semana`,
  1 AS `mes`,
  1 AS `nombre_trab`,
  1 AS `id_ai_area`,
  1 AS `nombre_area`,
  1 AS `area_nomeclatura`,
  1 AS `id_ai_sitio`,
  1 AS `nombre_sitio`,
  1 AS `id_ai_estado`,
  1 AS `nombre_estado`,
  1 AS `color_estado`,
  1 AS `libera_herramientas`,
  1 AS `bloquea_ot`,
  1 AS `ot_finalizada`,
  1 AS `fecha_finalizacion`,
  1 AS `id_user_finaliza`,
  1 AS `id_user_responsable`,
  1 AS `username_responsable`,
  1 AS `empleado_responsable`,
  1 AS `telefono_responsable`,
  1 AS `correo_responsable`,
  1 AS `total_detalles`,
  1 AS `herramientas_asignadas`,
  1 AS `herramientas_activas`,
  1 AS `std_reg` */;
SET character_set_client = @saved_cs_client;
DROP TABLE IF EXISTS `vw_reportes_generados`;
/*!50001 DROP VIEW IF EXISTS `vw_reportes_generados`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `vw_reportes_generados` AS SELECT
 1 AS `id_ai_reporte_generado`,
  1 AS `tipo_reporte`,
  1 AS `titulo_reporte`,
  1 AS `nombre_archivo`,
  1 AS `ruta_archivo`,
  1 AS `mime_type`,
  1 AS `tamano_bytes`,
  1 AS `parametros_json`,
  1 AS `id_user_generador`,
  1 AS `nombre_user_generador`,
  1 AS `username_generador`,
  1 AS `created_at`,
  1 AS `nombre_empleado`,
  1 AS `correo`,
  1 AS `id_rol`,
  1 AS `nombre_rol`,
  1 AS `std_reg` */;
SET character_set_client = @saved_cs_client;
DROP TABLE IF EXISTS `vw_usuario_empleado`;
/*!50001 DROP VIEW IF EXISTS `vw_usuario_empleado`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `vw_usuario_empleado` AS SELECT
 1 AS `id_ai_user`,
  1 AS `id_empleado`,
  1 AS `username`,
  1 AS `id_rol`,
  1 AS `nombre_rol`,
  1 AS `failed_login_attempts`,
  1 AS `account_locked`,
  1 AS `locked_at`,
  1 AS `password_reset_required`,
  1 AS `last_login_at`,
  1 AS `last_login_ip`,
  1 AS `std_reg`,
  1 AS `nacionalidad`,
  1 AS `nombre_empleado`,
  1 AS `telefono`,
  1 AS `correo`,
  1 AS `direccion`,
  1 AS `id_ai_categoria_empleado`,
  1 AS `categoria_empleado` */;
SET character_set_client = @saved_cs_client;
/*!50001 DROP VIEW IF EXISTS `vw_herramienta_disponibilidad`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */

/*!50001 VIEW `vw_herramienta_disponibilidad` AS select `h`.`id_ai_herramienta` AS `id_ai_herramienta`,`h`.`nombre_herramienta` AS `nombre_herramienta`,`h`.`id_ai_categoria_herramienta` AS `id_ai_categoria_herramienta`,`ch`.`nombre_categoria` AS `nombre_categoria`,`h`.`cantidad` AS `cantidad_total`,coalesce(`occ`.`cantidad_ocupada`,0) AS `cantidad_ocupada`,greatest(`h`.`cantidad` - coalesce(`occ`.`cantidad_ocupada`,0),0) AS `cantidad_disponible`,coalesce(`occ`.`ots_activas`,0) AS `ots_activas`,`h`.`estado` AS `estado`,`h`.`std_reg` AS `std_reg` from ((`herramienta` `h` left join `categoria_herramienta` `ch` on(`ch`.`id_ai_categoria_herramienta` = `h`.`id_ai_categoria_herramienta`)) left join (select `hot`.`id_ai_herramienta` AS `id_ai_herramienta`,coalesce(sum(case when coalesce(`hot`.`estado_herramientaot`,'ASIGNADA') <> 'LIBERADA' then `hot`.`cantidadot` else 0 end),0) AS `cantidad_ocupada`,count(distinct case when coalesce(`hot`.`estado_herramientaot`,'ASIGNADA') <> 'LIBERADA' then `hot`.`n_ot` end) AS `ots_activas` from `herramientaot` `hot` group by `hot`.`id_ai_herramienta`) `occ` on(`occ`.`id_ai_herramienta` = `h`.`id_ai_herramienta`)) where `h`.`std_reg` = 1 */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!50001 DROP VIEW IF EXISTS `vw_herramientas_ocupadas`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */

/*!50001 VIEW `vw_herramientas_ocupadas` AS select `hot`.`id_ai_herramientaOT` AS `id_ai_herramientaOT`,`hot`.`id_ai_herramienta` AS `id_ai_herramienta`,`h`.`nombre_herramienta` AS `nombre_herramienta`,`hot`.`n_ot` AS `n_ot`,`ot`.`nombre_trab` AS `nombre_trab`,`hot`.`cantidadot` AS `cantidadot`,coalesce(`eo`.`nombre_estado`,'SIN ESTADO') AS `estado_ot`,coalesce(`det`.`id_user_act`,`ot`.`id_user`,'') AS `tecnico_id`,coalesce(`emp_det`.`nombre_empleado`,`emp_ot`.`nombre_empleado`,'Sin tecnico asignado') AS `tecnico_nombre`,coalesce(`emp_det`.`telefono`,`emp_ot`.`telefono`,'') AS `telefono`,coalesce(`emp_det`.`correo`,`emp_ot`.`correo`,'') AS `correo`,coalesce(`emp_det`.`direccion`,`emp_ot`.`direccion`,'') AS `direccion`,`hot`.`estado_herramientaot` AS `estado_herramientaot`,`ot`.`fecha` AS `fecha_ot` from ((((((`herramientaot` `hot` join `herramienta` `h` on(`h`.`id_ai_herramienta` = `hot`.`id_ai_herramienta` and `h`.`std_reg` = 1)) join `orden_trabajo` `ot` on(`ot`.`n_ot` = `hot`.`n_ot` and `ot`.`std_reg` = 1)) left join `estado_ot` `eo` on(`eo`.`id_ai_estado` = `ot`.`id_ai_estado`)) left join (select `d1`.`n_ot` AS `n_ot`,`d1`.`id_user_act` AS `id_user_act` from (`detalle_orden` `d1` join (select `detalle_orden`.`n_ot` AS `n_ot`,max(`detalle_orden`.`id_ai_detalle`) AS `max_id` from `detalle_orden` group by `detalle_orden`.`n_ot`) `d2` on(`d2`.`n_ot` = `d1`.`n_ot` and `d2`.`max_id` = `d1`.`id_ai_detalle`))) `det` on(`det`.`n_ot` = `hot`.`n_ot`)) left join `empleado` `emp_det` on(`emp_det`.`id_empleado` = `det`.`id_user_act` and `emp_det`.`std_reg` = 1)) left join `empleado` `emp_ot` on(`emp_ot`.`id_empleado` = `ot`.`id_user` and `emp_ot`.`std_reg` = 1)) where coalesce(`hot`.`estado_herramientaot`,'ASIGNADA') <> 'LIBERADA' */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!50001 DROP VIEW IF EXISTS `vw_log_user_resumen`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */

/*!50001 VIEW `vw_log_user_resumen` AS select `lu`.`id_log` AS `id_log`,`lu`.`fecha_hora` AS `fecha_hora`,`lu`.`tabla` AS `tabla`,`lu`.`operacion` AS `operacion`,`lu`.`accion` AS `accion`,`lu`.`id_user` AS `id_user`,`us`.`username` AS `username`,`emp`.`nombre_empleado` AS `nombre_empleado`,`lu`.`db_user` AS `db_user`,`lu`.`db_host` AS `db_host`,`lu`.`changed_cols` AS `changed_cols`,`lu`.`std_reg` AS `std_reg` from ((`log_user` `lu` left join `user_system` `us` on(`us`.`id_empleado` = `lu`.`id_user`)) left join `empleado` `emp` on(`emp`.`id_empleado` = `lu`.`id_user`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!50001 DROP VIEW IF EXISTS `vw_ot_detallada`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */

/*!50001 VIEW `vw_ot_detallada` AS select `det`.`id_ai_detalle` AS `id_ai_detalle`,`det`.`n_ot` AS `n_ot`,`ot`.`id_ai_ot` AS `id_ai_ot`,`ot`.`fecha` AS `fecha_ot`,`ot`.`nombre_trab` AS `nombre_trab`,`ot`.`semana` AS `semana`,`ot`.`mes` AS `mes`,`ot`.`id_ai_area` AS `id_ai_area`,`area`.`nombre_area` AS `nombre_area`,`area`.`nomeclatura` AS `area_nomeclatura`,`ot`.`id_ai_sitio` AS `id_ai_sitio`,`sitio`.`nombre_sitio` AS `nombre_sitio`,`ot`.`id_ai_estado` AS `id_ai_estado`,`eo`.`nombre_estado` AS `estado_ot`,`eo`.`color` AS `color_estado_ot`,coalesce(`eo`.`libera_herramientas`,0) AS `libera_herramientas`,coalesce(`eo`.`bloquea_ot`,0) AS `bloquea_ot`,`det`.`fecha` AS `fecha_detalle`,`det`.`descripcion` AS `descripcion`,`det`.`id_ai_turno` AS `id_ai_turno`,`tt`.`nombre_turno` AS `nombre_turno`,`det`.`id_user_act` AS `id_user_act`,`us_det`.`username` AS `username_usuario_act`,`emp_det`.`nombre_empleado` AS `usuario_act_nombre`,`det`.`id_miembro_cco` AS `id_miembro_cco`,`mcco`.`nombre_miembro` AS `miembro_cco_nombre`,`det`.`id_miembro_ccf` AS `id_miembro_ccf`,`mccf`.`nombre_miembro` AS `miembro_ccf_nombre`,`det`.`cant_tec` AS `cant_tec`,`det`.`hora_inicio` AS `hora_inicio`,`det`.`hora_fin` AS `hora_fin`,`det`.`observacion` AS `observacion`,coalesce(`ot`.`ot_finalizada`,0) AS `ot_finalizada` from (((((((((`detalle_orden` `det` join `orden_trabajo` `ot` on(`ot`.`n_ot` = `det`.`n_ot` and `ot`.`std_reg` = 1)) left join `area_trabajo` `area` on(`area`.`id_ai_area` = `ot`.`id_ai_area`)) left join `sitio_trabajo` `sitio` on(`sitio`.`id_ai_sitio` = `ot`.`id_ai_sitio`)) left join `estado_ot` `eo` on(`eo`.`id_ai_estado` = `ot`.`id_ai_estado`)) left join `turno_trabajo` `tt` on(`tt`.`id_ai_turno` = `det`.`id_ai_turno`)) left join `user_system` `us_det` on(`us_det`.`id_empleado` = `det`.`id_user_act`)) left join `empleado` `emp_det` on(`emp_det`.`id_empleado` = `det`.`id_user_act`)) left join `miembro` `mcco` on(`mcco`.`id_miembro` = `det`.`id_miembro_cco`)) left join `miembro` `mccf` on(`mccf`.`id_miembro` = `det`.`id_miembro_ccf`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!50001 DROP VIEW IF EXISTS `vw_ot_resumen`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */

/*!50001 VIEW `vw_ot_resumen` AS select `ot`.`id_ai_ot` AS `id_ai_ot`,`ot`.`n_ot` AS `n_ot`,`ot`.`fecha` AS `fecha`,`ot`.`semana` AS `semana`,`ot`.`mes` AS `mes`,`ot`.`nombre_trab` AS `nombre_trab`,`ot`.`id_ai_area` AS `id_ai_area`,`area`.`nombre_area` AS `nombre_area`,`area`.`nomeclatura` AS `area_nomeclatura`,`ot`.`id_ai_sitio` AS `id_ai_sitio`,`sitio`.`nombre_sitio` AS `nombre_sitio`,`ot`.`id_ai_estado` AS `id_ai_estado`,`eo`.`nombre_estado` AS `nombre_estado`,`eo`.`color` AS `color_estado`,coalesce(`eo`.`libera_herramientas`,0) AS `libera_herramientas`,coalesce(`eo`.`bloquea_ot`,0) AS `bloquea_ot`,coalesce(`ot`.`ot_finalizada`,0) AS `ot_finalizada`,`ot`.`fecha_finalizacion` AS `fecha_finalizacion`,`ot`.`id_user_finaliza` AS `id_user_finaliza`,`ot`.`id_user` AS `id_user_responsable`,`us`.`username` AS `username_responsable`,`emp`.`nombre_empleado` AS `empleado_responsable`,`emp`.`telefono` AS `telefono_responsable`,`emp`.`correo` AS `correo_responsable`,coalesce(`det`.`total_detalles`,0) AS `total_detalles`,coalesce(`hot`.`herramientas_asignadas`,0) AS `herramientas_asignadas`,coalesce(`hot`.`herramientas_activas`,0) AS `herramientas_activas`,`ot`.`std_reg` AS `std_reg` from (((((((`orden_trabajo` `ot` left join `area_trabajo` `area` on(`area`.`id_ai_area` = `ot`.`id_ai_area`)) left join `sitio_trabajo` `sitio` on(`sitio`.`id_ai_sitio` = `ot`.`id_ai_sitio`)) left join `estado_ot` `eo` on(`eo`.`id_ai_estado` = `ot`.`id_ai_estado`)) left join `user_system` `us` on(`us`.`id_empleado` = `ot`.`id_user`)) left join `empleado` `emp` on(`emp`.`id_empleado` = `ot`.`id_user`)) left join (select `detalle_orden`.`n_ot` AS `n_ot`,count(0) AS `total_detalles` from `detalle_orden` group by `detalle_orden`.`n_ot`) `det` on(`det`.`n_ot` = `ot`.`n_ot`)) left join (select `herramientaot`.`n_ot` AS `n_ot`,coalesce(sum(`herramientaot`.`cantidadot`),0) AS `herramientas_asignadas`,coalesce(sum(case when coalesce(`herramientaot`.`estado_herramientaot`,'ASIGNADA') <> 'LIBERADA' then `herramientaot`.`cantidadot` else 0 end),0) AS `herramientas_activas` from `herramientaot` group by `herramientaot`.`n_ot`) `hot` on(`hot`.`n_ot` = `ot`.`n_ot`)) where `ot`.`std_reg` = 1 */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!50001 DROP VIEW IF EXISTS `vw_reportes_generados`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */

/*!50001 VIEW `vw_reportes_generados` AS select `rg`.`id_ai_reporte_generado` AS `id_ai_reporte_generado`,`rg`.`tipo_reporte` AS `tipo_reporte`,`rg`.`titulo_reporte` AS `titulo_reporte`,`rg`.`nombre_archivo` AS `nombre_archivo`,`rg`.`ruta_archivo` AS `ruta_archivo`,`rg`.`mime_type` AS `mime_type`,`rg`.`tamano_bytes` AS `tamano_bytes`,`rg`.`parametros_json` AS `parametros_json`,`rg`.`id_user_generador` AS `id_user_generador`,`rg`.`nombre_user_generador` AS `nombre_user_generador`,`rg`.`username_generador` AS `username_generador`,`rg`.`created_at` AS `created_at`,`emp`.`nombre_empleado` AS `nombre_empleado`,`emp`.`correo` AS `correo`,`us`.`tipo` AS `id_rol`,`rp`.`nombre_rol` AS `nombre_rol`,`rg`.`std_reg` AS `std_reg` from (((`reporte_generado` `rg` left join `empleado` `emp` on(`emp`.`id_empleado` = `rg`.`id_user_generador`)) left join `user_system` `us` on(`us`.`id_empleado` = `rg`.`id_user_generador`)) left join `roles_permisos` `rp` on(`rp`.`id` = `us`.`tipo`)) where `rg`.`std_reg` = 1 */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!50001 DROP VIEW IF EXISTS `vw_usuario_empleado`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */

/*!50001 VIEW `vw_usuario_empleado` AS select `us`.`id_ai_user` AS `id_ai_user`,`us`.`id_empleado` AS `id_empleado`,`us`.`username` AS `username`,`us`.`tipo` AS `id_rol`,`rp`.`nombre_rol` AS `nombre_rol`,`us`.`failed_login_attempts` AS `failed_login_attempts`,`us`.`account_locked` AS `account_locked`,`us`.`locked_at` AS `locked_at`,`us`.`password_reset_required` AS `password_reset_required`,`us`.`last_login_at` AS `last_login_at`,`us`.`last_login_ip` AS `last_login_ip`,`us`.`std_reg` AS `std_reg`,`emp`.`nacionalidad` AS `nacionalidad`,`emp`.`nombre_empleado` AS `nombre_empleado`,`emp`.`telefono` AS `telefono`,`emp`.`correo` AS `correo`,`emp`.`direccion` AS `direccion`,`emp`.`id_ai_categoria_empleado` AS `id_ai_categoria_empleado`,`ce`.`nombre_categoria` AS `categoria_empleado` from (((`user_system` `us` left join `empleado` `emp` on(`emp`.`id_empleado` = `us`.`id_empleado`)) left join `categoria_empleado` `ce` on(`ce`.`id_ai_categoria_empleado` = `emp`.`id_ai_categoria_empleado`)) left join `roles_permisos` `rp` on(`rp`.`id` = `us`.`tipo`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Objetos programables del esquema: bdapp_metro
CREATE DATABASE IF NOT EXISTS `bdapp_metro` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `bdapp_metro`;

-- PROCEDURE: sp_herramienta_ocupaciones
DROP PROCEDURE IF EXISTS `bdapp_metro`.`sp_herramienta_ocupaciones`;
DELIMITER $$
CREATE PROCEDURE `sp_herramienta_ocupaciones`(IN `p_id_ai_herramienta` INT, IN `p_busqueda` VARCHAR(100))
BEGIN
    IF p_id_ai_herramienta IS NULL OR p_id_ai_herramienta <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La herramienta es obligatoria.';
    END IF;

    SELECT *
    FROM vw_herramientas_ocupadas
    WHERE id_ai_herramienta = p_id_ai_herramienta
      AND (
          TRIM(COALESCE(p_busqueda, '')) = ''
          OR n_ot LIKE CONCAT('%', p_busqueda, '%')
          OR nombre_trab LIKE CONCAT('%', p_busqueda, '%')
          OR tecnico_nombre LIKE CONCAT('%', p_busqueda, '%')
      )
    ORDER BY n_ot ASC, id_ai_herramientaOT ASC;
END$$
DELIMITER ;

-- PROCEDURE: sp_ot_agregar_detalle
DROP PROCEDURE IF EXISTS `bdapp_metro`.`sp_ot_agregar_detalle`;
DELIMITER $$
CREATE PROCEDURE `sp_ot_agregar_detalle`(IN `p_n_ot` VARCHAR(30), IN `p_fecha` DATE, IN `p_descripcion` VARCHAR(250), IN `p_id_ai_turno` INT, IN `p_id_miembro_cco` VARCHAR(10), IN `p_id_user_act` VARCHAR(30), IN `p_id_miembro_ccf` VARCHAR(10), IN `p_cant_tec` INT, IN `p_hora_inicio` TIME, IN `p_hora_fin` TIME, IN `p_observacion` VARCHAR(250))
BEGIN
    DECLARE v_bloqueada INT DEFAULT NULL;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF TRIM(COALESCE(p_n_ot, '')) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La O.T. es obligatoria.';
    END IF;

    IF TRIM(COALESCE(p_descripcion, '')) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La descripcion del detalle es obligatoria.';
    END IF;

    IF p_cant_tec IS NULL OR p_cant_tec <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cantidad de tecnicos debe ser mayor a cero.';
    END IF;

    IF p_hora_inicio IS NOT NULL AND p_hora_fin IS NOT NULL AND p_hora_fin < p_hora_inicio THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La hora fin no puede ser menor que la hora inicio.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM turno_trabajo WHERE id_ai_turno = p_id_ai_turno AND std_reg = 1) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El turno indicado no existe o esta inactivo.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM miembro WHERE id_miembro = p_id_miembro_cco AND std_reg = 1) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El miembro CCO no existe o esta inactivo.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM miembro WHERE id_miembro = p_id_miembro_ccf AND std_reg = 1) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El miembro CCF no existe o esta inactivo.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM user_system WHERE id_empleado = p_id_user_act AND std_reg = 1) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario que registra el detalle no existe o esta inactivo.';
    END IF;

    SET @app_user = p_id_user_act;

    START TRANSACTION;

    SELECT CASE
             WHEN COALESCE(ot.ot_finalizada, 0) = 1 THEN 1
             WHEN COALESCE(eo.bloquea_ot, 0) = 1 THEN 1
             ELSE 0
           END
      INTO v_bloqueada
    FROM orden_trabajo ot
    LEFT JOIN estado_ot eo
      ON eo.id_ai_estado = ot.id_ai_estado
    WHERE ot.n_ot = p_n_ot
      AND ot.std_reg = 1
    LIMIT 1
    FOR UPDATE;

    IF v_bloqueada IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La O.T. indicada no existe o esta inactiva.';
    END IF;

    IF v_bloqueada = 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La O.T. esta bloqueada y no admite nuevos detalles.';
    END IF;

    INSERT INTO detalle_orden (
        n_ot, fecha, descripcion, id_ai_turno, id_miembro_cco,
        id_user_act, id_miembro_ccf, cant_tec, hora_inicio, hora_fin, observacion
    ) VALUES (
        p_n_ot, COALESCE(p_fecha, CURDATE()), p_descripcion, p_id_ai_turno, p_id_miembro_cco,
        p_id_user_act, p_id_miembro_ccf, p_cant_tec, p_hora_inicio, p_hora_fin, p_observacion
    );

    COMMIT;

    SELECT *
    FROM vw_ot_detallada
    WHERE id_ai_detalle = LAST_INSERT_ID()
    LIMIT 1;
END$$
DELIMITER ;

-- PROCEDURE: sp_ot_asignar_herramienta
DROP PROCEDURE IF EXISTS `bdapp_metro`.`sp_ot_asignar_herramienta`;
DELIMITER $$
CREATE PROCEDURE `sp_ot_asignar_herramienta`(IN `p_n_ot` VARCHAR(30), IN `p_id_ai_herramienta` INT, IN `p_cantidad` INT, IN `p_id_user_operacion` VARCHAR(30))
BEGIN
    DECLARE v_bloqueada INT DEFAULT NULL;
    DECLARE v_total INT DEFAULT NULL;
    DECLARE v_ocupada INT DEFAULT 0;
    DECLARE v_disponible INT DEFAULT 0;
    DECLARE v_actual_ot INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF TRIM(COALESCE(p_n_ot, '')) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La O.T. es obligatoria.';
    END IF;

    IF p_id_ai_herramienta IS NULL OR p_id_ai_herramienta <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La herramienta es obligatoria.';
    END IF;

    IF p_cantidad IS NULL OR p_cantidad <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cantidad a asignar debe ser mayor a cero.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM user_system WHERE id_empleado = p_id_user_operacion AND std_reg = 1) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario de la operacion no existe o esta inactivo.';
    END IF;

    SET @app_user = p_id_user_operacion;

    START TRANSACTION;

    SELECT CASE
             WHEN COALESCE(ot.ot_finalizada, 0) = 1 THEN 1
             WHEN COALESCE(eo.bloquea_ot, 0) = 1 THEN 1
             ELSE 0
           END
      INTO v_bloqueada
    FROM orden_trabajo ot
    LEFT JOIN estado_ot eo
      ON eo.id_ai_estado = ot.id_ai_estado
    WHERE ot.n_ot = p_n_ot
      AND ot.std_reg = 1
    LIMIT 1
    FOR UPDATE;

    IF v_bloqueada IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La O.T. indicada no existe o esta inactiva.';
    END IF;

    IF v_bloqueada = 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La O.T. esta bloqueada y no admite asignacion de herramientas.';
    END IF;

    SELECT h.cantidad
      INTO v_total
    FROM herramienta h
    WHERE h.id_ai_herramienta = p_id_ai_herramienta
      AND h.std_reg = 1
    FOR UPDATE;

    IF v_total IS NULL OR v_total <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La herramienta no existe o esta inactiva.';
    END IF;

    SELECT COALESCE(SUM(cantidadot), 0)
      INTO v_ocupada
    FROM herramientaot
    WHERE id_ai_herramienta = p_id_ai_herramienta
      AND COALESCE(estado_herramientaot, 'ASIGNADA') <> 'LIBERADA';

    SET v_disponible = GREATEST(v_total - v_ocupada, 0);

    IF v_disponible < p_cantidad THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay disponibilidad suficiente para asignar la herramienta.';
    END IF;

    SELECT COALESCE(SUM(cantidadot), 0)
      INTO v_actual_ot
    FROM herramientaot
    WHERE n_ot = p_n_ot
      AND id_ai_herramienta = p_id_ai_herramienta
      AND COALESCE(estado_herramientaot, 'ASIGNADA') <> 'LIBERADA';

    DELETE FROM herramientaot
    WHERE n_ot = p_n_ot
      AND id_ai_herramienta = p_id_ai_herramienta
      AND COALESCE(estado_herramientaot, 'ASIGNADA') <> 'LIBERADA';

    INSERT INTO herramientaot (
        id_ai_herramienta, n_ot, cantidadot, estado_herramientaot
    ) VALUES (
        p_id_ai_herramienta, p_n_ot, (v_actual_ot + p_cantidad), 'ASIGNADA'
    );

    COMMIT;

    SELECT *
    FROM vw_herramienta_disponibilidad
    WHERE id_ai_herramienta = p_id_ai_herramienta
    LIMIT 1;
END$$
DELIMITER ;

-- PROCEDURE: sp_ot_cambiar_estado
DROP PROCEDURE IF EXISTS `bdapp_metro`.`sp_ot_cambiar_estado`;
DELIMITER $$
CREATE PROCEDURE `sp_ot_cambiar_estado`(IN `p_n_ot` VARCHAR(30), IN `p_id_ai_estado` INT, IN `p_id_user_operacion` VARCHAR(30))
BEGIN
    DECLARE v_estado_actual INT DEFAULT NULL;
    DECLARE v_ot_finalizada INT DEFAULT 0;
    DECLARE v_ot_bloqueada INT DEFAULT 0;
    DECLARE v_estado_destino_nombre VARCHAR(100) DEFAULT NULL;
    DECLARE v_libera_herramientas INT DEFAULT 0;
    DECLARE v_bloquea_ot INT DEFAULT 0;
    DECLARE v_tiene_detalles INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF TRIM(COALESCE(p_n_ot, '')) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La O.T. es obligatoria.';
    END IF;

    IF p_id_ai_estado IS NULL OR p_id_ai_estado <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El estado destino es obligatorio.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM user_system WHERE id_empleado = p_id_user_operacion AND std_reg = 1) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario de la operacion no existe o esta inactivo.';
    END IF;

    SET @app_user = p_id_user_operacion;

    START TRANSACTION;

    SELECT
        ot.id_ai_estado,
        COALESCE(ot.ot_finalizada, 0),
        COALESCE(eo.bloquea_ot, 0)
      INTO v_estado_actual, v_ot_finalizada, v_ot_bloqueada
    FROM orden_trabajo ot
    LEFT JOIN estado_ot eo
      ON eo.id_ai_estado = ot.id_ai_estado
    WHERE ot.n_ot = p_n_ot
      AND ot.std_reg = 1
    LIMIT 1
    FOR UPDATE;

    IF v_estado_actual IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La O.T. indicada no existe o esta inactiva.';
    END IF;

    IF v_ot_finalizada = 1 OR v_ot_bloqueada = 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La O.T. ya esta bloqueada y no puede volver a cambiar de estado.';
    END IF;

    IF v_estado_actual = p_id_ai_estado THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La O.T. ya posee el estado indicado.';
    END IF;

    SELECT
        nombre_estado,
        COALESCE(libera_herramientas, 0),
        COALESCE(bloquea_ot, 0)
      INTO v_estado_destino_nombre, v_libera_herramientas, v_bloquea_ot
    FROM estado_ot
    WHERE id_ai_estado = p_id_ai_estado
      AND std_reg = 1
    LIMIT 1;

    IF v_estado_destino_nombre IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El estado destino no existe o esta inactivo.';
    END IF;

    IF v_bloquea_ot = 1 THEN
        SELECT COUNT(*) INTO v_tiene_detalles
        FROM detalle_orden
        WHERE n_ot = p_n_ot;

        IF v_tiene_detalles <= 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La O.T. debe tener al menos un detalle antes de pasar a un estado bloqueante.';
        END IF;
    END IF;

    UPDATE orden_trabajo
       SET id_ai_estado = p_id_ai_estado,
           ot_finalizada = CASE WHEN v_bloquea_ot = 1 THEN 1 ELSE 0 END,
           fecha_finalizacion = CASE WHEN v_bloquea_ot = 1 THEN NOW() ELSE NULL END,
           id_user_finaliza = CASE WHEN v_bloquea_ot = 1 THEN p_id_user_operacion ELSE NULL END
     WHERE n_ot = p_n_ot
       AND std_reg = 1;

    IF v_libera_herramientas = 1 THEN
        UPDATE herramientaot
           SET estado_herramientaot = 'LIBERADA'
         WHERE n_ot = p_n_ot
           AND COALESCE(estado_herramientaot, 'ASIGNADA') <> 'LIBERADA';
    END IF;

    COMMIT;

    SELECT *
    FROM vw_ot_resumen
    WHERE n_ot = p_n_ot
    LIMIT 1;
END$$
DELIMITER ;

-- PROCEDURE: sp_ot_crear
DROP PROCEDURE IF EXISTS `bdapp_metro`.`sp_ot_crear`;
DELIMITER $$
CREATE PROCEDURE `sp_ot_crear`(IN `p_n_ot` VARCHAR(30), IN `p_id_ai_area` INT, IN `p_id_user` VARCHAR(30), IN `p_id_ai_sitio` INT, IN `p_id_ai_estado` INT, IN `p_nombre_trab` VARCHAR(500), IN `p_fecha` DATE, IN `p_semana` VARCHAR(100), IN `p_mes` VARCHAR(100))
BEGIN
    DECLARE v_estado_id INT DEFAULT 0;
    DECLARE v_ot_existente INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF TRIM(COALESCE(p_n_ot, '')) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El numero de O.T. es obligatorio.';
    END IF;

    IF TRIM(COALESCE(p_id_user, '')) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario responsable es obligatorio.';
    END IF;

    IF TRIM(COALESCE(p_nombre_trab, '')) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre del trabajo es obligatorio.';
    END IF;

    SELECT COUNT(*) INTO v_ot_existente
    FROM orden_trabajo
    WHERE n_ot = p_n_ot
      AND std_reg = 1;

    IF v_ot_existente > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe una O.T. activa con ese codigo.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM area_trabajo WHERE id_ai_area = p_id_ai_area AND std_reg = 1) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El area de trabajo no existe o esta inactiva.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM sitio_trabajo WHERE id_ai_sitio = p_id_ai_sitio AND std_reg = 1) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El sitio de trabajo no existe o esta inactivo.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM user_system WHERE id_empleado = p_id_user AND std_reg = 1) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario responsable no existe o esta inactivo.';
    END IF;

    IF p_id_ai_estado IS NULL OR p_id_ai_estado <= 0 THEN
        SELECT id_ai_estado
          INTO v_estado_id
        FROM estado_ot
        WHERE std_reg = 1
          AND COALESCE(bloquea_ot, 0) = 0
        ORDER BY CASE
            WHEN UPPER(nombre_estado) = 'NO EJECUTADA' THEN 1
            WHEN UPPER(nombre_estado) = 'RE-PROGRAMADA' THEN 2
            WHEN UPPER(nombre_estado) = 'SUSPENDIDA' THEN 3
            ELSE 10
        END,
        id_ai_estado ASC
        LIMIT 1;
    ELSE
        SET v_estado_id = p_id_ai_estado;
    END IF;

    IF v_estado_id IS NULL OR v_estado_id <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No existe un estado inicial valido para la O.T.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM estado_ot WHERE id_ai_estado = v_estado_id AND std_reg = 1) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El estado seleccionado no existe o esta inactivo.';
    END IF;

    SET @app_user = p_id_user;

    START TRANSACTION;

    INSERT INTO orden_trabajo (
        n_ot, id_ai_area, id_user, id_ai_sitio, id_ai_estado,
        nombre_trab, fecha, semana, mes, ot_finalizada, std_reg
    ) VALUES (
        p_n_ot, p_id_ai_area, p_id_user, p_id_ai_sitio, v_estado_id,
        p_nombre_trab, COALESCE(p_fecha, CURDATE()), COALESCE(p_semana, ''), COALESCE(p_mes, ''), 0, 1
    );

    COMMIT;

    SELECT *
    FROM vw_ot_resumen
    WHERE n_ot = p_n_ot
    LIMIT 1;
END$$
DELIMITER ;

-- PROCEDURE: sp_reporte_registrar_generado
DROP PROCEDURE IF EXISTS `bdapp_metro`.`sp_reporte_registrar_generado`;
DELIMITER $$
CREATE PROCEDURE `sp_reporte_registrar_generado`(IN `p_tipo_reporte` VARCHAR(50), IN `p_titulo_reporte` VARCHAR(150), IN `p_nombre_archivo` VARCHAR(255), IN `p_ruta_archivo` VARCHAR(255), IN `p_mime_type` VARCHAR(100), IN `p_tamano_bytes` BIGINT, IN `p_parametros_json` LONGTEXT, IN `p_id_user_generador` VARCHAR(30))
BEGIN
    DECLARE v_nombre_empleado VARCHAR(150);
    DECLARE v_username VARCHAR(60);

    IF TRIM(COALESCE(p_tipo_reporte, '')) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El tipo de reporte es obligatorio.';
    END IF;

    IF TRIM(COALESCE(p_titulo_reporte, '')) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El titulo del reporte es obligatorio.';
    END IF;

    IF TRIM(COALESCE(p_nombre_archivo, '')) = '' OR TRIM(COALESCE(p_ruta_archivo, '')) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre y la ruta del archivo son obligatorios.';
    END IF;

    SELECT emp.nombre_empleado, us.username
      INTO v_nombre_empleado, v_username
    FROM empleado emp
    LEFT JOIN user_system us
      ON us.id_empleado = emp.id_empleado
     AND us.std_reg = 1
    WHERE emp.id_empleado = p_id_user_generador
      AND emp.std_reg = 1
    LIMIT 1;

    IF v_nombre_empleado IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario generador no existe o no esta vinculado a un empleado activo.';
    END IF;

    SET @app_user = p_id_user_generador;

    INSERT INTO reporte_generado (
        tipo_reporte,
        titulo_reporte,
        nombre_archivo,
        ruta_archivo,
        mime_type,
        tamano_bytes,
        parametros_json,
        id_user_generador,
        nombre_user_generador,
        username_generador,
        std_reg
    ) VALUES (
        p_tipo_reporte,
        p_titulo_reporte,
        p_nombre_archivo,
        p_ruta_archivo,
        COALESCE(NULLIF(TRIM(COALESCE(p_mime_type, '')), ''), 'application/pdf'),
        COALESCE(p_tamano_bytes, 0),
        p_parametros_json,
        p_id_user_generador,
        v_nombre_empleado,
        COALESCE(v_username, ''),
        1
    );

    SELECT *
    FROM vw_reportes_generados
    WHERE id_ai_reporte_generado = LAST_INSERT_ID()
    LIMIT 1;
END$$
DELIMITER ;

-- PROCEDURE: sp_usuario_registrar_login_exitoso
DROP PROCEDURE IF EXISTS `bdapp_metro`.`sp_usuario_registrar_login_exitoso`;
DELIMITER $$
CREATE PROCEDURE `sp_usuario_registrar_login_exitoso`(IN `p_id_empleado` VARCHAR(30), IN `p_ip` VARCHAR(45))
BEGIN
    IF TRIM(COALESCE(p_id_empleado, '')) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El id del usuario es obligatorio.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM user_system WHERE id_empleado = p_id_empleado AND std_reg = 1) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario no existe o esta inactivo.';
    END IF;

    SET @app_user = p_id_empleado;

    UPDATE user_system
       SET failed_login_attempts = 0,
           account_locked = 0,
           locked_at = NULL,
           password_reset_required = 0,
           last_login_at = NOW(),
           last_login_ip = NULLIF(TRIM(COALESCE(p_ip, '')), '')
     WHERE id_empleado = p_id_empleado
       AND std_reg = 1;

    SELECT id_empleado, username, failed_login_attempts, account_locked, password_reset_required, last_login_at, last_login_ip
    FROM user_system
    WHERE id_empleado = p_id_empleado
    LIMIT 1;
END$$
DELIMITER ;

-- PROCEDURE: sp_usuario_registrar_login_fallido
DROP PROCEDURE IF EXISTS `bdapp_metro`.`sp_usuario_registrar_login_fallido`;
DELIMITER $$
CREATE PROCEDURE `sp_usuario_registrar_login_fallido`(IN `p_username` VARCHAR(50), IN `p_ip` VARCHAR(45))
BEGIN
    DECLARE v_id_empleado VARCHAR(30) DEFAULT NULL;
    DECLARE v_intentos INT DEFAULT 0;
    DECLARE v_nuevo_intento INT DEFAULT 0;
    DECLARE v_bloqueado INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF TRIM(COALESCE(p_username, '')) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El username es obligatorio.';
    END IF;

    START TRANSACTION;

    SELECT id_empleado, COALESCE(failed_login_attempts, 0), COALESCE(account_locked, 0)
      INTO v_id_empleado, v_intentos, v_bloqueado
    FROM user_system
    WHERE username = p_username
      AND std_reg = 1
    LIMIT 1
    FOR UPDATE;

    IF v_id_empleado IS NULL THEN
        ROLLBACK;
        SELECT 0 AS usuario_encontrado, 0 AS bloqueado, 0 AS failed_login_attempts, NULL AS id_empleado;
    ELSE
        SET v_nuevo_intento = v_intentos + 1;
        SET @app_user = v_id_empleado;

        UPDATE user_system
           SET failed_login_attempts = v_nuevo_intento,
               account_locked = CASE WHEN v_nuevo_intento >= 3 THEN 1 ELSE account_locked END,
               locked_at = CASE WHEN v_nuevo_intento >= 3 THEN NOW() ELSE locked_at END,
               password_reset_required = CASE WHEN v_nuevo_intento >= 3 THEN 1 ELSE password_reset_required END,
               last_login_ip = NULLIF(TRIM(COALESCE(p_ip, '')), '')
         WHERE id_empleado = v_id_empleado
           AND std_reg = 1;

        COMMIT;

        SELECT 1 AS usuario_encontrado,
               CASE WHEN v_nuevo_intento >= 3 THEN 1 ELSE 0 END AS bloqueado,
               v_nuevo_intento AS failed_login_attempts,
               v_id_empleado AS id_empleado;
    END IF;
END$$
DELIMITER ;


-- Esquema: bdapp_metro_audit
CREATE DATABASE IF NOT EXISTS `bdapp_metro_audit` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `bdapp_metro_audit`;


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
DROP TABLE IF EXISTS `backup_runs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `backup_runs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `run_at` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Fecha y hora en que se ejecuto la sincronizacion o respaldo.',
  `synced_rows` int(11) NOT NULL COMMENT 'Cantidad de registros sincronizados hacia la base de auditoria.',
  `backed_rows` int(11) NOT NULL COMMENT 'Cantidad de registros respaldados durante la ejecucion.',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1797 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `backup_runs` WRITE;
/*!40000 ALTER TABLE `backup_runs` DISABLE KEYS */;
INSERT INTO `backup_runs` VALUES (1761,'2026-03-25 18:13:57',7,0),(1762,'2026-03-25 18:14:57',11,0),(1763,'2026-03-25 18:15:57',0,0),(1764,'2026-03-25 18:16:57',0,0),(1765,'2026-03-25 18:17:57',0,0),(1766,'2026-03-25 18:18:57',0,0),(1767,'2026-03-25 18:19:57',0,0),(1768,'2026-03-25 18:20:57',0,0),(1769,'2026-03-25 18:21:57',0,0),(1770,'2026-03-25 18:22:57',0,0),(1771,'2026-03-25 18:23:57',0,0),(1772,'2026-03-25 18:24:57',0,0),(1773,'2026-03-25 18:25:57',0,0),(1774,'2026-03-25 18:26:57',0,0),(1775,'2026-03-25 18:27:57',0,0),(1776,'2026-03-25 18:28:57',0,0),(1777,'2026-03-25 18:29:57',0,0),(1778,'2026-03-25 18:30:57',0,0),(1779,'2026-03-25 18:31:57',0,0),(1780,'2026-03-25 18:32:57',0,0),(1781,'2026-03-25 18:33:57',0,0),(1782,'2026-03-25 18:34:57',0,0),(1783,'2026-03-25 18:35:57',0,0),(1784,'2026-03-25 18:36:57',0,0),(1785,'2026-03-25 18:37:57',0,0),(1786,'2026-03-25 14:51:57',0,0),(1787,'2026-03-25 14:52:57',0,0),(1788,'2026-03-25 14:53:57',0,0),(1789,'2026-03-25 14:54:57',0,0),(1790,'2026-03-25 14:55:57',0,0),(1791,'2026-03-25 14:56:57',0,0),(1792,'2026-03-25 14:57:57',0,0),(1793,'2026-03-25 14:58:57',0,0),(1794,'2026-03-25 14:59:57',0,0),(1795,'2026-03-25 15:00:57',0,0),(1796,'2026-03-25 15:01:57',0,0);
/*!40000 ALTER TABLE `backup_runs` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `log_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `log_user` (
  `id_log` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable',
  `event_uuid` char(36) NOT NULL COMMENT 'Identificador unico del evento de auditoria.',
  `id_user` varchar(30) DEFAULT NULL COMMENT 'Identificador del usuario asociado al evento de auditoria.',
  `tabla` varchar(64) NOT NULL COMMENT 'Tabla origen del evento.',
  `operacion` enum('INSERT','UPDATE','DELETE','SOFT_DELETE','RESTORE','UNKNOWN') NOT NULL COMMENT 'Tipo de operacion registrada.',
  `pk_registro` varchar(255) DEFAULT NULL COMMENT 'Clave primaria (o identificador) del registro afectado.',
  `pk_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Identificador/PK en formato JSON.' CHECK (json_valid(`pk_json`)),
  `accion` varchar(150) NOT NULL COMMENT 'Accion funcional mostrada al usuario o al sistema.',
  `resp_system` text NOT NULL COMMENT 'Detalle tecnico de la operacion registrada.',
  `data_old` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Snapshot anterior (UPDATE/DELETE).' CHECK (json_valid(`data_old`)),
  `data_new` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Snapshot posterior (INSERT/UPDATE).' CHECK (json_valid(`data_new`)),
  `data_diff` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Solo campos modificados con [old,new].' CHECK (json_valid(`data_diff`)),
  `fecha_hora` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'Fecha y hora en que se registro el evento.',
  `connection_id` bigint(20) unsigned DEFAULT NULL COMMENT 'CONNECTION_ID() de la sesion.',
  `db_user` varchar(128) NOT NULL COMMENT 'Usuario de base de datos que ejecuto la operacion.',
  `db_host` varchar(128) DEFAULT NULL COMMENT 'Host extraido de USER().',
  `changed_cols` varchar(1024) DEFAULT NULL COMMENT 'Lista CSV de columnas modificadas.',
  `std_reg` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Estado logico del registro',
  PRIMARY KEY (`id_log`),
  KEY `idx_log_id_user_fecha` (`id_user`,`fecha_hora`),
  KEY `idx_log_tabla_fecha` (`tabla`,`fecha_hora`),
  KEY `idx_log_event_uuid` (`event_uuid`),
  KEY `idx_log_tabla_operacion_fecha` (`tabla`,`operacion`,`fecha_hora`)
) ENGINE=InnoDB AUTO_INCREMENT=473 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `log_user` WRITE;
/*!40000 ALTER TABLE `log_user` DISABLE KEYS */;
INSERT INTO `log_user` VALUES (1,'59a4939d-2876-11f1-95e1-989096ab40dc','22206460','user_system','UPDATE','id_empleado=22206460','{\"id_empleado\": \"22206460\"}','MODIFICAR user_system','UPDATE user_system id_empleado=22206460','{\"id_ai_user\": 1, \"id_empleado\": \"22206460\", \"username\": \"administrador\", \"password\": \"***\", \"tipo\": 1, \"std_reg\": 1}','{\"id_ai_user\": 1, \"id_empleado\": \"22206460\", \"username\": \"admin\", \"password\": \"***\", \"tipo\": 1, \"std_reg\": 1}','{\"username\": [\"administrador\", \"admin\"], \"password\": \"CHANGED\"}','2026-03-25 18:13:36',1427,'u_admin@localhost','localhost','username,password',1),(2,'59ad6287-2876-11f1-95e1-989096ab40dc','22206460','roles_permisos','UPDATE','id=1','{\"id\": 1}','MODIFICAR roles_permisos','UPDATE roles_permisos id=1','{\"id\": 1, \"nombre_rol\": \"ROOT\", \"perm_usuarios_view\": 1, \"perm_usuarios_add\": 1, \"perm_usuarios_edit\": 1, \"perm_usuarios_delete\": 1, \"perm_herramienta_view\": 1, \"perm_herramienta_add\": 1, \"perm_herramienta_edit\": 1, \"perm_herramienta_delete\": 1, \"perm_miembro_view\": 1, \"perm_miembro_add\": 1, \"perm_miembro_edit\": 1, \"perm_miembro_delete\": 1, \"perm_ot_view\": 1, \"perm_ot_add\": 1, \"perm_ot_edit\": 1, \"perm_ot_delete\": 1, \"perm_ot_add_detalle\": 1, \"perm_ot_generar_reporte\": 1, \"perm_ot_add_herramienta\": 1}','{\"id\": 1, \"nombre_rol\": \"ROOT\", \"perm_usuarios_view\": 1, \"perm_usuarios_add\": 1, \"perm_usuarios_edit\": 1, \"perm_usuarios_delete\": 1, \"perm_herramienta_view\": 1, \"perm_herramienta_add\": 1, \"perm_herramienta_edit\": 1, \"perm_herramienta_delete\": 1, \"perm_miembro_view\": 1, \"perm_miembro_add\": 1, \"perm_miembro_edit\": 1, \"perm_miembro_delete\": 1, \"perm_ot_view\": 1, \"perm_ot_add\": 1, \"perm_ot_edit\": 1, \"perm_ot_delete\": 1, \"perm_ot_add_detalle\": 1, \"perm_ot_generar_reporte\": 1, \"perm_ot_add_herramienta\": 1}','{}','2026-03-25 18:13:36',1428,'u_admin@localhost','localhost',NULL,1),(3,'59af0ea4-2876-11f1-95e1-989096ab40dc','22206460','roles_permisos','UPDATE','id=1','{\"id\": 1}','MODIFICAR roles_permisos','UPDATE roles_permisos id=1','{\"id\": 1, \"nombre_rol\": \"ROOT\", \"perm_usuarios_view\": 1, \"perm_usuarios_add\": 1, \"perm_usuarios_edit\": 1, \"perm_usuarios_delete\": 1, \"perm_herramienta_view\": 1, \"perm_herramienta_add\": 1, \"perm_herramienta_edit\": 1, \"perm_herramienta_delete\": 1, \"perm_miembro_view\": 1, \"perm_miembro_add\": 1, \"perm_miembro_edit\": 1, \"perm_miembro_delete\": 1, \"perm_ot_view\": 1, \"perm_ot_add\": 1, \"perm_ot_edit\": 1, \"perm_ot_delete\": 1, \"perm_ot_add_detalle\": 1, \"perm_ot_generar_reporte\": 1, \"perm_ot_add_herramienta\": 1}','{\"id\": 1, \"nombre_rol\": \"ROOT\", \"perm_usuarios_view\": 1, \"perm_usuarios_add\": 1, \"perm_usuarios_edit\": 1, \"perm_usuarios_delete\": 1, \"perm_herramienta_view\": 1, \"perm_herramienta_add\": 1, \"perm_herramienta_edit\": 1, \"perm_herramienta_delete\": 1, \"perm_miembro_view\": 1, \"perm_miembro_add\": 1, \"perm_miembro_edit\": 1, \"perm_miembro_delete\": 1, \"perm_ot_view\": 1, \"perm_ot_add\": 1, \"perm_ot_edit\": 1, \"perm_ot_delete\": 1, \"perm_ot_add_detalle\": 1, \"perm_ot_generar_reporte\": 1, \"perm_ot_add_herramienta\": 1}','{}','2026-03-25 18:13:36',1428,'u_admin@localhost','localhost',NULL,1),(4,'63cc3953-2876-11f1-95e1-989096ab40dc','22206460','roles_permisos','UPDATE','id=1','{\"id\": 1}','MODIFICAR roles_permisos','UPDATE roles_permisos id=1','{\"id\": 1, \"nombre_rol\": \"ROOT\", \"perm_usuarios_view\": 1, \"perm_usuarios_add\": 1, \"perm_usuarios_edit\": 1, \"perm_usuarios_delete\": 1, \"perm_herramienta_view\": 1, \"perm_herramienta_add\": 1, \"perm_herramienta_edit\": 1, \"perm_herramienta_delete\": 1, \"perm_miembro_view\": 1, \"perm_miembro_add\": 1, \"perm_miembro_edit\": 1, \"perm_miembro_delete\": 1, \"perm_ot_view\": 1, \"perm_ot_add\": 1, \"perm_ot_edit\": 1, \"perm_ot_delete\": 1, \"perm_ot_add_detalle\": 1, \"perm_ot_generar_reporte\": 1, \"perm_ot_add_herramienta\": 1}','{\"id\": 1, \"nombre_rol\": \"ROOT\", \"perm_usuarios_view\": 1, \"perm_usuarios_add\": 1, \"perm_usuarios_edit\": 1, \"perm_usuarios_delete\": 1, \"perm_herramienta_view\": 1, \"perm_herramienta_add\": 1, \"perm_herramienta_edit\": 1, \"perm_herramienta_delete\": 1, \"perm_miembro_view\": 1, \"perm_miembro_add\": 1, \"perm_miembro_edit\": 1, \"perm_miembro_delete\": 1, \"perm_ot_view\": 1, \"perm_ot_add\": 1, \"perm_ot_edit\": 1, \"perm_ot_delete\": 1, \"perm_ot_add_detalle\": 1, \"perm_ot_generar_reporte\": 1, \"perm_ot_add_herramienta\": 1}','{}','2026-03-25 18:13:53',1429,'u_admin@localhost','localhost',NULL,1),(5,'63ccf011-2876-11f1-95e1-989096ab40dc','22206460','roles_permisos','UPDATE','id=1','{\"id\": 1}','MODIFICAR roles_permisos','UPDATE roles_permisos id=1','{\"id\": 1, \"nombre_rol\": \"ROOT\", \"perm_usuarios_view\": 1, \"perm_usuarios_add\": 1, \"perm_usuarios_edit\": 1, \"perm_usuarios_delete\": 1, \"perm_herramienta_view\": 1, \"perm_herramienta_add\": 1, \"perm_herramienta_edit\": 1, \"perm_herramienta_delete\": 1, \"perm_miembro_view\": 1, \"perm_miembro_add\": 1, \"perm_miembro_edit\": 1, \"perm_miembro_delete\": 1, \"perm_ot_view\": 1, \"perm_ot_add\": 1, \"perm_ot_edit\": 1, \"perm_ot_delete\": 1, \"perm_ot_add_detalle\": 1, \"perm_ot_generar_reporte\": 1, \"perm_ot_add_herramienta\": 1}','{\"id\": 1, \"nombre_rol\": \"ROOT\", \"perm_usuarios_view\": 1, \"perm_usuarios_add\": 1, \"perm_usuarios_edit\": 1, \"perm_usuarios_delete\": 1, \"perm_herramienta_view\": 1, \"perm_herramienta_add\": 1, \"perm_herramienta_edit\": 1, \"perm_herramienta_delete\": 1, \"perm_miembro_view\": 1, \"perm_miembro_add\": 1, \"perm_miembro_edit\": 1, \"perm_miembro_delete\": 1, \"perm_ot_view\": 1, \"perm_ot_add\": 1, \"perm_ot_edit\": 1, \"perm_ot_delete\": 1, \"perm_ot_add_detalle\": 1, \"perm_ot_generar_reporte\": 1, \"perm_ot_add_herramienta\": 1}','{}','2026-03-25 18:13:53',1429,'u_admin@localhost','localhost',NULL,1),(6,'63dbd496-2876-11f1-95e1-989096ab40dc','22206460','user_system','UPDATE','id_empleado=22206460','{\"id_empleado\": \"22206460\"}','MODIFICAR user_system','UPDATE user_system id_empleado=22206460','{\"id_ai_user\": 1, \"id_empleado\": \"22206460\", \"username\": \"admin\", \"password\": \"***\", \"tipo\": 1, \"std_reg\": 1}','{\"id_ai_user\": 1, \"id_empleado\": \"22206460\", \"username\": \"admin\", \"password\": \"***\", \"tipo\": 1, \"std_reg\": 1}','{}','2026-03-25 18:13:53',1429,'u_admin@localhost','localhost',NULL,1),(7,'63de89a9-2876-11f1-95e1-989096ab40dc','22206460','auth_session','UNKNOWN','id_empleado=22206460','{\"id_empleado\":\"22206460\"}','LOGIN_INTENTO_FALLIDO','Clave incorrecta en inicio de sesion.',NULL,'{\"username\":\"ADMIN\",\"ip\":\"::1\",\"user_agent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36\",\"timestamp\":\"2026-03-25 14:13:53\",\"failed_login_attempts\":1,\"remaining_attempts\":2}','{\"username\":\"ADMIN\",\"ip\":\"::1\",\"user_agent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36\",\"timestamp\":\"2026-03-25 14:13:53\",\"failed_login_attempts\":1,\"remaining_attempts\":2}','2026-03-25 18:13:53',1429,'u_admin','localhost','failed_login_attempts,remaining_attempts',1),(8,'6b54cfc5-2876-11f1-95e1-989096ab40dc','22206460','roles_permisos','UPDATE','id=1','{\"id\": 1}','MODIFICAR roles_permisos','UPDATE roles_permisos id=1','{\"id\": 1, \"nombre_rol\": \"ROOT\", \"perm_usuarios_view\": 1, \"perm_usuarios_add\": 1, \"perm_usuarios_edit\": 1, \"perm_usuarios_delete\": 1, \"perm_herramienta_view\": 1, \"perm_herramienta_add\": 1, \"perm_herramienta_edit\": 1, \"perm_herramienta_delete\": 1, \"perm_miembro_view\": 1, \"perm_miembro_add\": 1, \"perm_miembro_edit\": 1, \"perm_miembro_delete\": 1, \"perm_ot_view\": 1, \"perm_ot_add\": 1, \"perm_ot_edit\": 1, \"perm_ot_delete\": 1, \"perm_ot_add_detalle\": 1, \"perm_ot_generar_reporte\": 1, \"perm_ot_add_herramienta\": 1}','{\"id\": 1, \"nombre_rol\": \"ROOT\", \"perm_usuarios_view\": 1, \"perm_usuarios_add\": 1, \"perm_usuarios_edit\": 1, \"perm_usuarios_delete\": 1, \"perm_herramienta_view\": 1, \"perm_herramienta_add\": 1, \"perm_herramienta_edit\": 1, \"perm_herramienta_delete\": 1, \"perm_miembro_view\": 1, \"perm_miembro_add\": 1, \"perm_miembro_edit\": 1, \"perm_miembro_delete\": 1, \"perm_ot_view\": 1, \"perm_ot_add\": 1, \"perm_ot_edit\": 1, \"perm_ot_delete\": 1, \"perm_ot_add_detalle\": 1, \"perm_ot_generar_reporte\": 1, \"perm_ot_add_herramienta\": 1}','{}','2026-03-25 18:14:05',1431,'u_admin@localhost','localhost',NULL,1),(9,'6b559a8b-2876-11f1-95e1-989096ab40dc','22206460','roles_permisos','UPDATE','id=1','{\"id\": 1}','MODIFICAR roles_permisos','UPDATE roles_permisos id=1','{\"id\": 1, \"nombre_rol\": \"ROOT\", \"perm_usuarios_view\": 1, \"perm_usuarios_add\": 1, \"perm_usuarios_edit\": 1, \"perm_usuarios_delete\": 1, \"perm_herramienta_view\": 1, \"perm_herramienta_add\": 1, \"perm_herramienta_edit\": 1, \"perm_herramienta_delete\": 1, \"perm_miembro_view\": 1, \"perm_miembro_add\": 1, \"perm_miembro_edit\": 1, \"perm_miembro_delete\": 1, \"perm_ot_view\": 1, \"perm_ot_add\": 1, \"perm_ot_edit\": 1, \"perm_ot_delete\": 1, \"perm_ot_add_detalle\": 1, \"perm_ot_generar_reporte\": 1, \"perm_ot_add_herramienta\": 1}','{\"id\": 1, \"nombre_rol\": \"ROOT\", \"perm_usuarios_view\": 1, \"perm_usuarios_add\": 1, \"perm_usuarios_edit\": 1, \"perm_usuarios_delete\": 1, \"perm_herramienta_view\": 1, \"perm_herramienta_add\": 1, \"perm_herramienta_edit\": 1, \"perm_herramienta_delete\": 1, \"perm_miembro_view\": 1, \"perm_miembro_add\": 1, \"perm_miembro_edit\": 1, \"perm_miembro_delete\": 1, \"perm_ot_view\": 1, \"perm_ot_add\": 1, \"perm_ot_edit\": 1, \"perm_ot_delete\": 1, \"perm_ot_add_detalle\": 1, \"perm_ot_generar_reporte\": 1, \"perm_ot_add_herramienta\": 1}','{}','2026-03-25 18:14:05',1431,'u_admin@localhost','localhost',NULL,1),(10,'6b66b11d-2876-11f1-95e1-989096ab40dc','22206460','user_system','UPDATE','id_empleado=22206460','{\"id_empleado\": \"22206460\"}','MODIFICAR user_system','UPDATE user_system id_empleado=22206460','{\"id_ai_user\": 1, \"id_empleado\": \"22206460\", \"username\": \"admin\", \"password\": \"***\", \"tipo\": 1, \"std_reg\": 1}','{\"id_ai_user\": 1, \"id_empleado\": \"22206460\", \"username\": \"admin\", \"password\": \"***\", \"tipo\": 1, \"std_reg\": 1}','{}','2026-03-25 18:14:05',1431,'u_admin@localhost','localhost',NULL,1),(11,'6b69410b-2876-11f1-95e1-989096ab40dc','22206460','auth_session','UNKNOWN','id_empleado=22206460','{\"id_empleado\":\"22206460\"}','LOGIN_EXITOSO','Inicio de sesion exitoso.',NULL,'{\"username\":\"admin\",\"ip\":\"::1\",\"user_agent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36\",\"timestamp\":\"2026-03-25 14:14:05\",\"rol\":\"ROOT\",\"tipo\":1}','{\"username\":\"admin\",\"ip\":\"::1\",\"user_agent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36\",\"timestamp\":\"2026-03-25 14:14:05\",\"rol\":\"ROOT\",\"tipo\":1}','2026-03-25 18:14:05',1431,'u_admin','localhost','rol,tipo',1),(12,'75599f63-2876-11f1-95e1-989096ab40dc','22206460','user_system','UPDATE','id_empleado=22206460','{\"id_empleado\": \"22206460\"}','MODIFICAR user_system','UPDATE user_system id_empleado=22206460','{\"id_ai_user\": 1, \"id_empleado\": \"22206460\", \"username\": \"admin\", \"password\": \"***\", \"tipo\": 1, \"std_reg\": 1}','{\"id_ai_user\": 1, \"id_empleado\": \"22206460\", \"username\": \"admin\", \"password\": \"***\", \"tipo\": 1, \"std_reg\": 1}','{\"password\": \"CHANGED\"}','2026-03-25 18:14:22',1456,'u_admin@localhost','localhost','password',1),(13,'756301cc-2876-11f1-95e1-989096ab40dc','22206460','roles_permisos','UPDATE','id=1','{\"id\": 1}','MODIFICAR roles_permisos','UPDATE roles_permisos id=1','{\"id\": 1, \"nombre_rol\": \"ROOT\", \"perm_usuarios_view\": 1, \"perm_usuarios_add\": 1, \"perm_usuarios_edit\": 1, \"perm_usuarios_delete\": 1, \"perm_herramienta_view\": 1, \"perm_herramienta_add\": 1, \"perm_herramienta_edit\": 1, \"perm_herramienta_delete\": 1, \"perm_miembro_view\": 1, \"perm_miembro_add\": 1, \"perm_miembro_edit\": 1, \"perm_miembro_delete\": 1, \"perm_ot_view\": 1, \"perm_ot_add\": 1, \"perm_ot_edit\": 1, \"perm_ot_delete\": 1, \"perm_ot_add_detalle\": 1, \"perm_ot_generar_reporte\": 1, \"perm_ot_add_herramienta\": 1}','{\"id\": 1, \"nombre_rol\": \"ROOT\", \"perm_usuarios_view\": 1, \"perm_usuarios_add\": 1, \"perm_usuarios_edit\": 1, \"perm_usuarios_delete\": 1, \"perm_herramienta_view\": 1, \"perm_herramienta_add\": 1, \"perm_herramienta_edit\": 1, \"perm_herramienta_delete\": 1, \"perm_miembro_view\": 1, \"perm_miembro_add\": 1, \"perm_miembro_edit\": 1, \"perm_miembro_delete\": 1, \"perm_ot_view\": 1, \"perm_ot_add\": 1, \"perm_ot_edit\": 1, \"perm_ot_delete\": 1, \"perm_ot_add_detalle\": 1, \"perm_ot_generar_reporte\": 1, \"perm_ot_add_herramienta\": 1}','{}','2026-03-25 18:14:22',1457,'u_admin@localhost','localhost',NULL,1),(14,'7563eede-2876-11f1-95e1-989096ab40dc','22206460','roles_permisos','UPDATE','id=1','{\"id\": 1}','MODIFICAR roles_permisos','UPDATE roles_permisos id=1','{\"id\": 1, \"nombre_rol\": \"ROOT\", \"perm_usuarios_view\": 1, \"perm_usuarios_add\": 1, \"perm_usuarios_edit\": 1, \"perm_usuarios_delete\": 1, \"perm_herramienta_view\": 1, \"perm_herramienta_add\": 1, \"perm_herramienta_edit\": 1, \"perm_herramienta_delete\": 1, \"perm_miembro_view\": 1, \"perm_miembro_add\": 1, \"perm_miembro_edit\": 1, \"perm_miembro_delete\": 1, \"perm_ot_view\": 1, \"perm_ot_add\": 1, \"perm_ot_edit\": 1, \"perm_ot_delete\": 1, \"perm_ot_add_detalle\": 1, \"perm_ot_generar_reporte\": 1, \"perm_ot_add_herramienta\": 1}','{\"id\": 1, \"nombre_rol\": \"ROOT\", \"perm_usuarios_view\": 1, \"perm_usuarios_add\": 1, \"perm_usuarios_edit\": 1, \"perm_usuarios_delete\": 1, \"perm_herramienta_view\": 1, \"perm_herramienta_add\": 1, \"perm_herramienta_edit\": 1, \"perm_herramienta_delete\": 1, \"perm_miembro_view\": 1, \"perm_miembro_add\": 1, \"perm_miembro_edit\": 1, \"perm_miembro_delete\": 1, \"perm_ot_view\": 1, \"perm_ot_add\": 1, \"perm_ot_edit\": 1, \"perm_ot_delete\": 1, \"perm_ot_add_detalle\": 1, \"perm_ot_generar_reporte\": 1, \"perm_ot_add_herramienta\": 1}','{}','2026-03-25 18:14:22',1457,'u_admin@localhost','localhost',NULL,1),(15,'7a9ae81e-2876-11f1-95e1-989096ab40dc','22206460','roles_permisos','UPDATE','id=1','{\"id\": 1}','MODIFICAR roles_permisos','UPDATE roles_permisos id=1','{\"id\": 1, \"nombre_rol\": \"ROOT\", \"perm_usuarios_view\": 1, \"perm_usuarios_add\": 1, \"perm_usuarios_edit\": 1, \"perm_usuarios_delete\": 1, \"perm_herramienta_view\": 1, \"perm_herramienta_add\": 1, \"perm_herramienta_edit\": 1, \"perm_herramienta_delete\": 1, \"perm_miembro_view\": 1, \"perm_miembro_add\": 1, \"perm_miembro_edit\": 1, \"perm_miembro_delete\": 1, \"perm_ot_view\": 1, \"perm_ot_add\": 1, \"perm_ot_edit\": 1, \"perm_ot_delete\": 1, \"perm_ot_add_detalle\": 1, \"perm_ot_generar_reporte\": 1, \"perm_ot_add_herramienta\": 1}','{\"id\": 1, \"nombre_rol\": \"ROOT\", \"perm_usuarios_view\": 1, \"perm_usuarios_add\": 1, \"perm_usuarios_edit\": 1, \"perm_usuarios_delete\": 1, \"perm_herramienta_view\": 1, \"perm_herramienta_add\": 1, \"perm_herramienta_edit\": 1, \"perm_herramienta_delete\": 1, \"perm_miembro_view\": 1, \"perm_miembro_add\": 1, \"perm_miembro_edit\": 1, \"perm_miembro_delete\": 1, \"perm_ot_view\": 1, \"perm_ot_add\": 1, \"perm_ot_edit\": 1, \"perm_ot_delete\": 1, \"perm_ot_add_detalle\": 1, \"perm_ot_generar_reporte\": 1, \"perm_ot_add_herramienta\": 1}','{}','2026-03-25 18:14:31',1458,'u_admin@localhost','localhost',NULL,1),(16,'7a9bb990-2876-11f1-95e1-989096ab40dc','22206460','roles_permisos','UPDATE','id=1','{\"id\": 1}','MODIFICAR roles_permisos','UPDATE roles_permisos id=1','{\"id\": 1, \"nombre_rol\": \"ROOT\", \"perm_usuarios_view\": 1, \"perm_usuarios_add\": 1, \"perm_usuarios_edit\": 1, \"perm_usuarios_delete\": 1, \"perm_herramienta_view\": 1, \"perm_herramienta_add\": 1, \"perm_herramienta_edit\": 1, \"perm_herramienta_delete\": 1, \"perm_miembro_view\": 1, \"perm_miembro_add\": 1, \"perm_miembro_edit\": 1, \"perm_miembro_delete\": 1, \"perm_ot_view\": 1, \"perm_ot_add\": 1, \"perm_ot_edit\": 1, \"perm_ot_delete\": 1, \"perm_ot_add_detalle\": 1, \"perm_ot_generar_reporte\": 1, \"perm_ot_add_herramienta\": 1}','{\"id\": 1, \"nombre_rol\": \"ROOT\", \"perm_usuarios_view\": 1, \"perm_usuarios_add\": 1, \"perm_usuarios_edit\": 1, \"perm_usuarios_delete\": 1, \"perm_herramienta_view\": 1, \"perm_herramienta_add\": 1, \"perm_herramienta_edit\": 1, \"perm_herramienta_delete\": 1, \"perm_miembro_view\": 1, \"perm_miembro_add\": 1, \"perm_miembro_edit\": 1, \"perm_miembro_delete\": 1, \"perm_ot_view\": 1, \"perm_ot_add\": 1, \"perm_ot_edit\": 1, \"perm_ot_delete\": 1, \"perm_ot_add_detalle\": 1, \"perm_ot_generar_reporte\": 1, \"perm_ot_add_herramienta\": 1}','{}','2026-03-25 18:14:31',1458,'u_admin@localhost','localhost',NULL,1),(17,'7ab15ebb-2876-11f1-95e1-989096ab40dc','22206460','user_system','UPDATE','id_empleado=22206460','{\"id_empleado\": \"22206460\"}','MODIFICAR user_system','UPDATE user_system id_empleado=22206460','{\"id_ai_user\": 1, \"id_empleado\": \"22206460\", \"username\": \"admin\", \"password\": \"***\", \"tipo\": 1, \"std_reg\": 1}','{\"id_ai_user\": 1, \"id_empleado\": \"22206460\", \"username\": \"admin\", \"password\": \"***\", \"tipo\": 1, \"std_reg\": 1}','{}','2026-03-25 18:14:31',1458,'u_admin@localhost','localhost',NULL,1),(18,'7ab3e36e-2876-11f1-95e1-989096ab40dc','22206460','auth_session','UNKNOWN','id_empleado=22206460','{\"id_empleado\":\"22206460\"}','LOGIN_EXITOSO','Inicio de sesion exitoso.',NULL,'{\"username\":\"admin\",\"ip\":\"::1\",\"user_agent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36\",\"timestamp\":\"2026-03-25 14:14:31\",\"rol\":\"ROOT\",\"tipo\":1}','{\"username\":\"admin\",\"ip\":\"::1\",\"user_agent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36\",\"timestamp\":\"2026-03-25 14:14:31\",\"rol\":\"ROOT\",\"tipo\":1}','2026-03-25 18:14:31',1458,'u_admin','localhost','rol,tipo',1);
/*!40000 ALTER TABLE `log_user` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Objetos programables del esquema: bdapp_metro_audit
CREATE DATABASE IF NOT EXISTS `bdapp_metro_audit` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `bdapp_metro_audit`;

-- PROCEDURE: sp_minute_tasks
DROP PROCEDURE IF EXISTS `bdapp_metro_audit`.`sp_minute_tasks`;
DELIMITER $$
CREATE PROCEDURE `sp_minute_tasks`()
BEGIN
  DECLARE v_before BIGINT UNSIGNED DEFAULT 0;
  DECLARE v_after  BIGINT UNSIGNED DEFAULT 0;
  DECLARE v_sync   INT DEFAULT 0;

  SELECT IFNULL(MAX(id_log),0) INTO v_before
  FROM bdapp_metro_audit.log_user;

  CALL bdapp_metro_audit.sp_sync_log_user();

  SELECT IFNULL(MAX(id_log),0) INTO v_after
  FROM bdapp_metro_audit.log_user;

  SET v_sync = GREATEST(v_after - v_before, 0);

  INSERT INTO bdapp_metro_audit.backup_runs(run_at, synced_rows, backed_rows)
  VALUES (NOW(), v_sync, 0);
END$$
DELIMITER ;

-- PROCEDURE: sp_sync_log_user
DROP PROCEDURE IF EXISTS `bdapp_metro_audit`.`sp_sync_log_user`;
DELIMITER $$
CREATE PROCEDURE `sp_sync_log_user`()
BEGIN
  DECLARE v_last BIGINT UNSIGNED DEFAULT 0;

  SELECT IFNULL(MAX(id_log),0) INTO v_last
  FROM bdapp_metro_audit.log_user;

  INSERT INTO bdapp_metro_audit.log_user
  (id_log, event_uuid, id_user, tabla, operacion, pk_registro, pk_json,
   accion, resp_system, data_old, data_new, data_diff, fecha_hora,
   connection_id, db_user, db_host, changed_cols, std_reg)
  SELECT
   id_log, event_uuid, id_user, tabla, operacion, pk_registro, pk_json,
   accion, resp_system, data_old, data_new, data_diff, fecha_hora,
   connection_id, db_user, db_host, changed_cols, std_reg
  FROM bdapp_metro.log_user
  WHERE id_log > v_last;
END$$
DELIMITER ;

-- EVENTO: ev_minute_backup
DROP EVENT IF EXISTS `bdapp_metro_audit`.`ev_minute_backup`;
DELIMITER $$
CREATE EVENT `ev_minute_backup` ON SCHEDULE EVERY 1 MINUTE STARTS '2026-03-19 15:34:57' ON COMPLETION NOT PRESERVE ENABLE DO CALL bdapp_metro_audit.sp_minute_tasks()$$
DELIMITER ;


-- Esquema: bdapp_metro_review
CREATE DATABASE IF NOT EXISTS `bdapp_metro_review` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `bdapp_metro_review`;


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
DROP TABLE IF EXISTS `vw_backup_runs`;
/*!50001 DROP VIEW IF EXISTS `vw_backup_runs`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `vw_backup_runs` AS SELECT
 1 AS `id`,
  1 AS `run_at`,
  1 AS `synced_rows`,
  1 AS `backed_rows` */;
SET character_set_client = @saved_cs_client;
DROP TABLE IF EXISTS `vw_eventos`;
/*!50001 DROP VIEW IF EXISTS `vw_eventos`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `vw_eventos` AS SELECT
 1 AS `EVENT_SCHEMA`,
  1 AS `EVENT_NAME`,
  1 AS `STATUS`,
  1 AS `INTERVAL_VALUE`,
  1 AS `INTERVAL_FIELD`,
  1 AS `LAST_EXECUTED` */;
SET character_set_client = @saved_cs_client;
DROP TABLE IF EXISTS `vw_log_user_detalle`;
/*!50001 DROP VIEW IF EXISTS `vw_log_user_detalle`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `vw_log_user_detalle` AS SELECT
 1 AS `id_log`,
  1 AS `fecha_hora`,
  1 AS `tabla`,
  1 AS `operacion`,
  1 AS `pk_registro`,
  1 AS `accion`,
  1 AS `changed_cols`,
  1 AS `data_diff`,
  1 AS `data_old`,
  1 AS `data_new`,
  1 AS `id_user`,
  1 AS `db_user`,
  1 AS `db_host`,
  1 AS `connection_id`,
  1 AS `event_uuid` */;
SET character_set_client = @saved_cs_client;
DROP TABLE IF EXISTS `vw_log_user_resumen`;
/*!50001 DROP VIEW IF EXISTS `vw_log_user_resumen`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `vw_log_user_resumen` AS SELECT
 1 AS `dia`,
  1 AS `tabla`,
  1 AS `operacion`,
  1 AS `total` */;
SET character_set_client = @saved_cs_client;
/*!50001 DROP VIEW IF EXISTS `vw_backup_runs`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */

/*!50001 VIEW `vw_backup_runs` AS select `bdapp_metro_audit`.`backup_runs`.`id` AS `id`,`bdapp_metro_audit`.`backup_runs`.`run_at` AS `run_at`,`bdapp_metro_audit`.`backup_runs`.`synced_rows` AS `synced_rows`,`bdapp_metro_audit`.`backup_runs`.`backed_rows` AS `backed_rows` from `bdapp_metro_audit`.`backup_runs` order by `bdapp_metro_audit`.`backup_runs`.`run_at` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!50001 DROP VIEW IF EXISTS `vw_eventos`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */

/*!50001 VIEW `vw_eventos` AS select `information_schema`.`events`.`EVENT_SCHEMA` AS `EVENT_SCHEMA`,`information_schema`.`events`.`EVENT_NAME` AS `EVENT_NAME`,`information_schema`.`events`.`STATUS` AS `STATUS`,`information_schema`.`events`.`INTERVAL_VALUE` AS `INTERVAL_VALUE`,`information_schema`.`events`.`INTERVAL_FIELD` AS `INTERVAL_FIELD`,`information_schema`.`events`.`LAST_EXECUTED` AS `LAST_EXECUTED` from `information_schema`.`events` where `information_schema`.`events`.`EVENT_SCHEMA` = 'bdapp_metro_audit' */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!50001 DROP VIEW IF EXISTS `vw_log_user_detalle`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */

/*!50001 VIEW `vw_log_user_detalle` AS select `bdapp_metro_audit`.`log_user`.`id_log` AS `id_log`,`bdapp_metro_audit`.`log_user`.`fecha_hora` AS `fecha_hora`,`bdapp_metro_audit`.`log_user`.`tabla` AS `tabla`,`bdapp_metro_audit`.`log_user`.`operacion` AS `operacion`,`bdapp_metro_audit`.`log_user`.`pk_registro` AS `pk_registro`,`bdapp_metro_audit`.`log_user`.`accion` AS `accion`,`bdapp_metro_audit`.`log_user`.`changed_cols` AS `changed_cols`,`bdapp_metro_audit`.`log_user`.`data_diff` AS `data_diff`,`bdapp_metro_audit`.`log_user`.`data_old` AS `data_old`,`bdapp_metro_audit`.`log_user`.`data_new` AS `data_new`,`bdapp_metro_audit`.`log_user`.`id_user` AS `id_user`,`bdapp_metro_audit`.`log_user`.`db_user` AS `db_user`,`bdapp_metro_audit`.`log_user`.`db_host` AS `db_host`,`bdapp_metro_audit`.`log_user`.`connection_id` AS `connection_id`,`bdapp_metro_audit`.`log_user`.`event_uuid` AS `event_uuid` from `bdapp_metro_audit`.`log_user` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!50001 DROP VIEW IF EXISTS `vw_log_user_resumen`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */

/*!50001 VIEW `vw_log_user_resumen` AS select cast(`bdapp_metro_audit`.`log_user`.`fecha_hora` as date) AS `dia`,`bdapp_metro_audit`.`log_user`.`tabla` AS `tabla`,`bdapp_metro_audit`.`log_user`.`operacion` AS `operacion`,count(0) AS `total` from `bdapp_metro_audit`.`log_user` group by cast(`bdapp_metro_audit`.`log_user`.`fecha_hora` as date),`bdapp_metro_audit`.`log_user`.`tabla`,`bdapp_metro_audit`.`log_user`.`operacion` order by cast(`bdapp_metro_audit`.`log_user`.`fecha_hora` as date) desc,`bdapp_metro_audit`.`log_user`.`tabla`,`bdapp_metro_audit`.`log_user`.`operacion` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Objetos programables del esquema: bdapp_metro_review
CREATE DATABASE IF NOT EXISTS `bdapp_metro_review` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `bdapp_metro_review`;



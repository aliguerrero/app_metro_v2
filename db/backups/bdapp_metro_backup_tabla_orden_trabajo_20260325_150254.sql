-- ========================================
-- Respaldo de base de datos
-- APP_METRO_BACKUP_SIGNATURE: 1
-- APP_METRO_BACKUP_GENERATOR: MYSQLDUMP
-- DB: bdapp_metro
-- Fecha: 2026-03-25 15:02:54
-- Tipo: PARCIAL
-- Tablas incluidas: orden_trabajo
-- ========================================

-- Esquemas incluidos: bdapp_metro

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
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;



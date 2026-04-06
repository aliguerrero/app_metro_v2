-- Modulo: Scripts_ddl
-- Archivo: bitacora_usuario.sql
-- Funcion: define la bitacora de auditoria y sus estructuras de consulta operativa y consolidada.
-- Version: v_1.0
-- Opciones:
--   no admite opciones; organiza el DDL por base de datos y agrega las vistas vinculadas al objeto funcional.

-- ============================================================================
-- Base de datos de vistas
-- ============================================================================
CREATE DATABASE IF NOT EXISTS `bdapp_metro_review` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `bdapp_metro_review`;

-- -----------------------------------------------------------------------------
-- Bloque de vista asociada
-- muestra el detalle completo de cada evento almacenado en la base de auditoria.
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS `vw_log_user_detalle`;
DROP TABLE IF EXISTS `vw_log_user_detalle`;

CREATE ALGORITHM=UNDEFINED DEFINER=CURRENT_USER SQL SECURITY DEFINER VIEW `vw_log_user_detalle`  AS SELECT `bdapp_metro_audit`.`log_user`.`id_log` AS `id_log`, `bdapp_metro_audit`.`log_user`.`fecha_hora` AS `fecha_hora`, `bdapp_metro_audit`.`log_user`.`tabla` AS `tabla`, `bdapp_metro_audit`.`log_user`.`operacion` AS `operacion`, `bdapp_metro_audit`.`log_user`.`pk_registro` AS `pk_registro`, `bdapp_metro_audit`.`log_user`.`accion` AS `accion`, `bdapp_metro_audit`.`log_user`.`changed_cols` AS `changed_cols`, `bdapp_metro_audit`.`log_user`.`data_diff` AS `data_diff`, `bdapp_metro_audit`.`log_user`.`data_old` AS `data_old`, `bdapp_metro_audit`.`log_user`.`data_new` AS `data_new`, `bdapp_metro_audit`.`log_user`.`id_user` AS `id_user`, `bdapp_metro_audit`.`log_user`.`db_user` AS `db_user`, `bdapp_metro_audit`.`log_user`.`db_host` AS `db_host`, `bdapp_metro_audit`.`log_user`.`connection_id` AS `connection_id`, `bdapp_metro_audit`.`log_user`.`event_uuid` AS `event_uuid` FROM `bdapp_metro_audit`.`log_user` ;

-- -----------------------------------------------------------------------------
-- Bloque de vista asociada
-- resume por dia, tabla y operacion los eventos almacenados en la base de auditoria.
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS `vw_log_user_resumen`;
DROP TABLE IF EXISTS `vw_log_user_resumen`;

CREATE ALGORITHM=UNDEFINED DEFINER=CURRENT_USER SQL SECURITY DEFINER VIEW `vw_log_user_resumen`  AS SELECT cast(`bdapp_metro_audit`.`log_user`.`fecha_hora` as date) AS `dia`, `bdapp_metro_audit`.`log_user`.`tabla` AS `tabla`, `bdapp_metro_audit`.`log_user`.`operacion` AS `operacion`, count(0) AS `total` FROM `bdapp_metro_audit`.`log_user` GROUP BY cast(`bdapp_metro_audit`.`log_user`.`fecha_hora` as date), `bdapp_metro_audit`.`log_user`.`tabla`, `bdapp_metro_audit`.`log_user`.`operacion` ORDER BY cast(`bdapp_metro_audit`.`log_user`.`fecha_hora` as date) DESC, `bdapp_metro_audit`.`log_user`.`tabla` ASC, `bdapp_metro_audit`.`log_user`.`operacion` ASC ;


-- Modulo: Scripts_ddl
-- Archivo: respaldo_auditoria.sql
-- Funcion: define el seguimiento de respaldos y la infraestructura programada de auditoria.
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
-- expone el historial de ejecuciones de sincronizacion y respaldo de auditoria.
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS `vw_backup_runs`;
DROP TABLE IF EXISTS `vw_backup_runs`;

CREATE ALGORITHM=UNDEFINED DEFINER=CURRENT_USER SQL SECURITY DEFINER VIEW `vw_backup_runs`  AS SELECT `bdapp_metro_audit`.`backup_runs`.`id` AS `id`, `bdapp_metro_audit`.`backup_runs`.`run_at` AS `run_at`, `bdapp_metro_audit`.`backup_runs`.`synced_rows` AS `synced_rows`, `bdapp_metro_audit`.`backup_runs`.`backed_rows` AS `backed_rows` FROM `bdapp_metro_audit`.`backup_runs` ORDER BY `bdapp_metro_audit`.`backup_runs`.`run_at` DESC ;

-- -----------------------------------------------------------------------------
-- Bloque de vista asociada
-- expone el estado del evento programado que atiende la auditoria automatizada.
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS `vw_eventos`;
DROP TABLE IF EXISTS `vw_eventos`;

CREATE ALGORITHM=UNDEFINED DEFINER=CURRENT_USER SQL SECURITY DEFINER VIEW `vw_eventos`  AS SELECT `information_schema`.`events`.`EVENT_SCHEMA` AS `EVENT_SCHEMA`, `information_schema`.`events`.`EVENT_NAME` AS `EVENT_NAME`, `information_schema`.`events`.`STATUS` AS `STATUS`, `information_schema`.`events`.`INTERVAL_VALUE` AS `INTERVAL_VALUE`, `information_schema`.`events`.`INTERVAL_FIELD` AS `INTERVAL_FIELD`, `information_schema`.`events`.`LAST_EXECUTED` AS `LAST_EXECUTED` FROM `information_schema`.`events` WHERE `information_schema`.`events`.`EVENT_SCHEMA` = 'bdapp_metro_audit' ;


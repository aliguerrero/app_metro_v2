-- Modulo: Scripts_ddl
-- Archivo: respaldo_auditoria.sql
-- Funcion: define el seguimiento de respaldos y la infraestructura programada de auditoria.
-- Version: v_1.0
-- Opciones:
--   no admite opciones; organiza el DDL por base de datos y agrega las vistas vinculadas al objeto funcional.

-- ============================================================================
-- Base de datos de auditoria
-- ============================================================================
CREATE DATABASE IF NOT EXISTS `bdapp_metro_audit` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `bdapp_metro_audit`;

-- -----------------------------------------------------------------------------
-- Bloque 1. Reinicio controlado y creacion de la tabla
-- elimina `backup_runs` si ya existe y la vuelve a crear con `IF NOT EXISTS` usando la definicion consolidada del esquema.
-- -----------------------------------------------------------------------------
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS `backup_runs`;
CREATE TABLE IF NOT EXISTS `backup_runs` (
  `id` bigint(20) UNSIGNED NOT NULL COMMENT 'Identificador unico de la ejecucion de respaldo.',
  `run_at` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Fecha y hora en que se ejecuto la sincronizacion o respaldo.',
  `synced_rows` int(11) NOT NULL COMMENT 'Cantidad de registros sincronizados hacia la base de auditoria.',
  `backed_rows` int(11) NOT NULL COMMENT 'Cantidad de registros respaldados durante la ejecucion.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
SET FOREIGN_KEY_CHECKS = 1;

-- -----------------------------------------------------------------------------
-- Bloque 2. Indices y clave primaria
-- declara la clave primaria e indices auxiliares requeridos para consultas, unicidad y rendimiento de `backup_runs`.
-- -----------------------------------------------------------------------------
ALTER TABLE `backup_runs`
  ADD PRIMARY KEY (`id`);

-- -----------------------------------------------------------------------------
-- Bloque 3. Configuracion autoincremental
-- habilita el comportamiento AUTO_INCREMENT definido para `backup_runs` dentro de la base actual.
-- -----------------------------------------------------------------------------
ALTER TABLE `backup_runs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1761;


-- Modulo: Scripts_ddl
-- Archivo: bitacora_usuario.sql
-- Funcion: define la bitacora de auditoria y sus estructuras de consulta operativa y consolidada.
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
-- elimina `log_user` si ya existe y la vuelve a crear con `IF NOT EXISTS` usando la definicion consolidada del esquema.
-- -----------------------------------------------------------------------------
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS `log_user`;
CREATE TABLE IF NOT EXISTS `log_user` (
  `id_log` bigint(20) UNSIGNED NOT NULL COMMENT 'id autoincrementable',
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
  `connection_id` bigint(20) UNSIGNED DEFAULT NULL COMMENT 'CONNECTION_ID() de la sesion.',
  `db_user` varchar(128) NOT NULL COMMENT 'Usuario de base de datos que ejecuto la operacion.',
  `db_host` varchar(128) DEFAULT NULL COMMENT 'Host extraido de USER().',
  `changed_cols` varchar(1024) DEFAULT NULL COMMENT 'Lista CSV de columnas modificadas.',
  `std_reg` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Estado logico del registro'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
SET FOREIGN_KEY_CHECKS = 1;

-- -----------------------------------------------------------------------------
-- Bloque 2. Indices y clave primaria
-- declara la clave primaria e indices auxiliares requeridos para consultas, unicidad y rendimiento de `log_user`.
-- -----------------------------------------------------------------------------
ALTER TABLE `log_user`
  ADD PRIMARY KEY (`id_log`),
  ADD KEY `idx_log_id_user_fecha` (`id_user`,`fecha_hora`),
  ADD KEY `idx_log_tabla_fecha` (`tabla`,`fecha_hora`),
  ADD KEY `idx_log_event_uuid` (`event_uuid`),
  ADD KEY `idx_log_tabla_operacion_fecha` (`tabla`,`operacion`,`fecha_hora`);

-- -----------------------------------------------------------------------------
-- Bloque 3. Configuracion autoincremental
-- habilita el comportamiento AUTO_INCREMENT definido para `log_user` dentro de la base actual.
-- -----------------------------------------------------------------------------
ALTER TABLE `log_user`
  MODIFY `id_log` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable', AUTO_INCREMENT=473;


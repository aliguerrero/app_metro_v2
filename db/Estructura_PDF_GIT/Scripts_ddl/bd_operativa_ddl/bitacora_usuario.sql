-- Modulo: Scripts_ddl
-- Archivo: bitacora_usuario.sql
-- Funcion: define la bitacora de auditoria y sus estructuras de consulta operativa y consolidada.
-- Version: v_1.0

-- ============================================================================
-- Base de datos operativa
-- ============================================================================
CREATE DATABASE IF NOT EXISTS `bdapp_metro` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `bdapp_metro`;

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
-- Bloque 2. Disparador asociado
-- el disparador `trg_log_user_no_delete` valida o bloquea la eliminacion en `log_user` antes de aplicar el cambio definitivo.
-- -----------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER `trg_log_user_no_delete` BEFORE DELETE ON `log_user` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite eliminar registros de auditoria (log_user).'
$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- Bloque 3. Disparador asociado
-- el disparador `trg_log_user_no_update` valida o bloquea la actualizacion en `log_user` antes de aplicar el cambio definitivo.
-- -----------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER `trg_log_user_no_update` BEFORE UPDATE ON `log_user` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite modificar registros de auditoria (log_user).'
$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- Bloque 4. Indices y clave primaria
-- declara la clave primaria e indices auxiliares requeridos para consultas, unicidad y rendimiento de `log_user`.
-- -----------------------------------------------------------------------------
ALTER TABLE `log_user`
  ADD PRIMARY KEY (`id_log`),
  ADD KEY `idx_log_id_user_fecha` (`id_user`,`fecha_hora`),
  ADD KEY `idx_log_tabla_fecha` (`tabla`,`fecha_hora`),
  ADD KEY `idx_log_event_uuid` (`event_uuid`),
  ADD KEY `idx_log_tabla_operacion_fecha` (`tabla`,`operacion`,`fecha_hora`);

-- -----------------------------------------------------------------------------
-- Bloque 5. Configuracion autoincremental
-- habilita el comportamiento AUTO_INCREMENT definido para `log_user` dentro de la base actual.
-- -----------------------------------------------------------------------------
ALTER TABLE `log_user`
  MODIFY `id_log` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable';

-- -----------------------------------------------------------------------------
-- Bloque 6. Claves foraneas
-- establece las relaciones referenciales que conectan `log_user` con otras tablas del esquema correspondiente.
-- -----------------------------------------------------------------------------
ALTER TABLE `log_user`
  ADD CONSTRAINT `fk_log_user_user` FOREIGN KEY (`id_user`) REFERENCES `user_system` (`id_empleado`) ON DELETE SET NULL ON UPDATE CASCADE;

-- -----------------------------------------------------------------------------
-- Bloque de vista asociada
-- resume la auditoria operativa enlazando usuario de sistema y empleado responsable.
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS `vw_log_user_resumen`;
DROP TABLE IF EXISTS `vw_log_user_resumen`;

CREATE ALGORITHM=UNDEFINED DEFINER=CURRENT_USER SQL SECURITY INVOKER VIEW `vw_log_user_resumen`  AS SELECT `lu`.`id_log` AS `id_log`, `lu`.`fecha_hora` AS `fecha_hora`, `lu`.`tabla` AS `tabla`, `lu`.`operacion` AS `operacion`, `lu`.`accion` AS `accion`, `lu`.`id_user` AS `id_user`, `us`.`username` AS `username`, `emp`.`nombre_empleado` AS `nombre_empleado`, `lu`.`db_user` AS `db_user`, `lu`.`db_host` AS `db_host`, `lu`.`changed_cols` AS `changed_cols`, `lu`.`std_reg` AS `std_reg` FROM ((`log_user` `lu` left join `user_system` `us` on(`us`.`id_empleado` = `lu`.`id_user`)) left join `empleado` `emp` on(`emp`.`id_empleado` = `lu`.`id_user`)) ;


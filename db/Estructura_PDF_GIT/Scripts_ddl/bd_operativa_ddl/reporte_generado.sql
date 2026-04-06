-- Modulo: Scripts_ddl
-- Archivo: reporte_generado.sql
-- Funcion: define el almacenamiento de metadatos de reportes generados y su vista de consulta.
-- Version: v_1.0

-- ============================================================================
-- Base de datos operativa
-- ============================================================================
CREATE DATABASE IF NOT EXISTS `bdapp_metro` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `bdapp_metro`;

-- -----------------------------------------------------------------------------
-- Bloque 1. Reinicio controlado y creacion de la tabla
-- elimina `reporte_generado` si ya existe y la vuelve a crear con `IF NOT EXISTS` usando la definicion consolidada del esquema.
-- -----------------------------------------------------------------------------
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS `reporte_generado`;
CREATE TABLE IF NOT EXISTS `reporte_generado` (
  `id_ai_reporte_generado` int(10) UNSIGNED NOT NULL COMMENT 'Id autoincrementable del reporte generado',
  `tipo_reporte` varchar(50) NOT NULL COMMENT 'Codigo o tipo funcional del reporte generado',
  `titulo_reporte` varchar(150) NOT NULL COMMENT 'Titulo descriptivo mostrado al usuario para el reporte',
  `nombre_archivo` varchar(255) NOT NULL COMMENT 'Nombre final del archivo PDF generado',
  `ruta_archivo` varchar(255) NOT NULL COMMENT 'Ruta relativa o absoluta donde se almacena el PDF generado',
  `mime_type` varchar(100) NOT NULL DEFAULT 'application/pdf' COMMENT 'Tipo MIME del archivo generado',
  `tamano_bytes` bigint(20) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Tamano del archivo generado expresado en bytes',
  `parametros_json` longtext DEFAULT NULL COMMENT 'Parametros de entrada usados para construir el reporte',
  `id_user_generador` varchar(30) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT 'Identificador del usuario que genero el reporte',
  `nombre_user_generador` varchar(150) NOT NULL COMMENT 'Nombre visible del usuario que genero el reporte',
  `username_generador` varchar(60) NOT NULL COMMENT 'Nombre de acceso del usuario que genero el reporte',
  `created_at` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Fecha y hora de generacion del reporte',
  `std_reg` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Estado logico del registro (1=activo, 0=inactivo).'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
SET FOREIGN_KEY_CHECKS = 1;

-- -----------------------------------------------------------------------------
-- Bloque 2. Disparador asociado
-- el disparador `trg_reporte_generado_ai` registra la auditoria asociada a la insercion en `reporte_generado` despues de ejecutarse la operacion.
-- -----------------------------------------------------------------------------
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

-- -----------------------------------------------------------------------------
-- Bloque 3. Disparador asociado
-- el disparador `trg_reporte_generado_au` registra la auditoria asociada a la actualizacion en `reporte_generado` despues de ejecutarse la operacion.
-- -----------------------------------------------------------------------------
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

-- -----------------------------------------------------------------------------
-- Bloque 4. Disparador asociado
-- el disparador `trg_reporte_generado_bd` valida o bloquea la eliminacion en `reporte_generado` antes de aplicar el cambio definitivo.
-- -----------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER `trg_reporte_generado_bd` BEFORE DELETE ON `reporte_generado` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE fisico en reporte_generado. Use eliminacion logica (UPDATE reporte_generado SET std_reg=0 ...).'
$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- Bloque 5. Indices y clave primaria
-- declara la clave primaria e indices auxiliares requeridos para consultas, unicidad y rendimiento de `reporte_generado`.
-- -----------------------------------------------------------------------------
ALTER TABLE `reporte_generado`
  ADD PRIMARY KEY (`id_ai_reporte_generado`),
  ADD KEY `idx_reporte_generado_fecha` (`created_at`),
  ADD KEY `idx_reporte_generado_tipo` (`tipo_reporte`),
  ADD KEY `idx_reporte_generado_user` (`id_user_generador`);

-- -----------------------------------------------------------------------------
-- Bloque 6. Configuracion autoincremental
-- habilita el comportamiento AUTO_INCREMENT definido para `reporte_generado` dentro de la base actual.
-- -----------------------------------------------------------------------------
ALTER TABLE `reporte_generado`
  MODIFY `id_ai_reporte_generado` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Id autoincrementable del reporte generado';

-- -----------------------------------------------------------------------------
-- Bloque 7. Claves foraneas
-- establece las relaciones referenciales que conectan `reporte_generado` con otras tablas del esquema correspondiente.
-- -----------------------------------------------------------------------------
ALTER TABLE `reporte_generado`
  ADD CONSTRAINT `reporte_generado_ibfk_1` FOREIGN KEY (`id_user_generador`) REFERENCES `empleado` (`id_empleado`) ON DELETE CASCADE ON UPDATE CASCADE;

-- -----------------------------------------------------------------------------
-- Bloque de vista asociada
-- presenta los reportes generados junto con su usuario emisor y rol vinculado.
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS `vw_reportes_generados`;
DROP TABLE IF EXISTS `vw_reportes_generados`;

CREATE ALGORITHM=UNDEFINED DEFINER=CURRENT_USER SQL SECURITY INVOKER VIEW `vw_reportes_generados`  AS SELECT `rg`.`id_ai_reporte_generado` AS `id_ai_reporte_generado`, `rg`.`tipo_reporte` AS `tipo_reporte`, `rg`.`titulo_reporte` AS `titulo_reporte`, `rg`.`nombre_archivo` AS `nombre_archivo`, `rg`.`ruta_archivo` AS `ruta_archivo`, `rg`.`mime_type` AS `mime_type`, `rg`.`tamano_bytes` AS `tamano_bytes`, `rg`.`parametros_json` AS `parametros_json`, `rg`.`id_user_generador` AS `id_user_generador`, `rg`.`nombre_user_generador` AS `nombre_user_generador`, `rg`.`username_generador` AS `username_generador`, `rg`.`created_at` AS `created_at`, `emp`.`nombre_empleado` AS `nombre_empleado`, `emp`.`correo` AS `correo`, `us`.`tipo` AS `id_rol`, `rp`.`nombre_rol` AS `nombre_rol`, `rg`.`std_reg` AS `std_reg` FROM (((`reporte_generado` `rg` left join `empleado` `emp` on(`emp`.`id_empleado` = `rg`.`id_user_generador`)) left join `user_system` `us` on(`us`.`id_empleado` = `rg`.`id_user_generador`)) left join `roles_permisos` `rp` on(`rp`.`id` = `us`.`tipo`)) WHERE `rg`.`std_reg` = 1 ;


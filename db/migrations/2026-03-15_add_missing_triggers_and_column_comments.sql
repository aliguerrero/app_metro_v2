-- Migracion: completar comentarios de columnas y triggers de auditoria faltantes
-- Fecha: 2026-03-15

-- 1) Comentarios faltantes en columnas
ALTER TABLE `categoria_herramienta`
    MODIFY COLUMN `id_ai_categoria_herramienta` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id autoincrementable de la categoria de herramienta',
    MODIFY COLUMN `nombre_categoria` varchar(100) NOT NULL COMMENT 'Nombre de la categoria de la herramienta',
    MODIFY COLUMN `descripcion` varchar(255) DEFAULT NULL COMMENT 'Descripcion breve de la categoria de herramienta',
    MODIFY COLUMN `std_reg` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Estado logico del registro (1=activo, 0=inactivo).';

ALTER TABLE `herramienta`
    MODIFY COLUMN `id_ai_categoria_herramienta` int(10) unsigned NOT NULL COMMENT 'Categoria asociada a la herramienta';

ALTER TABLE `log_user`
    MODIFY COLUMN `event_uuid` char(36) NOT NULL COMMENT 'Identificador unico del evento de auditoria.',
    MODIFY COLUMN `accion` varchar(150) NOT NULL COMMENT 'Accion funcional mostrada al usuario o al sistema.';

ALTER TABLE `reporte_generado`
    MODIFY COLUMN `id_ai_reporte_generado` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id autoincrementable del reporte generado',
    MODIFY COLUMN `tipo_reporte` varchar(50) NOT NULL COMMENT 'Codigo o tipo funcional del reporte generado',
    MODIFY COLUMN `titulo_reporte` varchar(150) NOT NULL COMMENT 'Titulo descriptivo mostrado al usuario para el reporte',
    MODIFY COLUMN `nombre_archivo` varchar(255) NOT NULL COMMENT 'Nombre final del archivo PDF generado',
    MODIFY COLUMN `ruta_archivo` varchar(255) NOT NULL COMMENT 'Ruta relativa o absoluta donde se almacena el PDF generado',
    MODIFY COLUMN `mime_type` varchar(100) NOT NULL DEFAULT 'application/pdf' COMMENT 'Tipo MIME del archivo generado',
    MODIFY COLUMN `tamano_bytes` bigint(20) unsigned NOT NULL DEFAULT 0 COMMENT 'Tamano del archivo generado expresado en bytes',
    MODIFY COLUMN `parametros_json` longtext DEFAULT NULL COMMENT 'Parametros de entrada usados para construir el reporte',
    MODIFY COLUMN `id_user_generador` varchar(30) NOT NULL COMMENT 'Identificador del usuario que genero el reporte',
    MODIFY COLUMN `nombre_user_generador` varchar(150) NOT NULL COMMENT 'Nombre visible del usuario que genero el reporte',
    MODIFY COLUMN `username_generador` varchar(60) NOT NULL COMMENT 'Nombre de acceso del usuario que genero el reporte',
    MODIFY COLUMN `created_at` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Fecha y hora de generacion del reporte',
    MODIFY COLUMN `std_reg` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Estado logico del registro (1=activo, 0=inactivo).';

DROP TRIGGER IF EXISTS `trg_categoria_empleado_ai`;
DROP TRIGGER IF EXISTS `trg_categoria_empleado_au`;
DROP TRIGGER IF EXISTS `trg_categoria_empleado_bd`;
DROP TRIGGER IF EXISTS `trg_categoria_herramienta_ai`;
DROP TRIGGER IF EXISTS `trg_categoria_herramienta_au`;
DROP TRIGGER IF EXISTS `trg_categoria_herramienta_bd`;
DROP TRIGGER IF EXISTS `trg_empleado_ai`;
DROP TRIGGER IF EXISTS `trg_empleado_au`;
DROP TRIGGER IF EXISTS `trg_empleado_bd`;
DROP TRIGGER IF EXISTS `trg_reporte_generado_ai`;
DROP TRIGGER IF EXISTS `trg_reporte_generado_au`;
DROP TRIGGER IF EXISTS `trg_reporte_generado_bd`;

DELIMITER $$

CREATE DEFINER=`root`@`localhost` TRIGGER `trg_categoria_empleado_ai`
AFTER INSERT ON `categoria_empleado`
FOR EACH ROW
INSERT INTO `log_user`(
    `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
    `accion`,`resp_system`,`data_old`,`data_new`,`data_diff`,`changed_cols`,
    `connection_id`,`db_user`,`db_host`
) VALUES (
    UUID(),
    (SELECT `id_user` FROM `user_system` WHERE `id_user` = @app_user LIMIT 1),
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
)$$

CREATE DEFINER=`root`@`localhost` TRIGGER `trg_categoria_empleado_au`
AFTER UPDATE ON `categoria_empleado`
FOR EACH ROW
INSERT INTO `log_user`(
    `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
    `accion`,`resp_system`,`data_old`,`data_new`,`data_diff`,`changed_cols`,
    `connection_id`,`db_user`,`db_host`
) VALUES (
    UUID(),
    (SELECT `id_user` FROM `user_system` WHERE `id_user` = @app_user LIMIT 1),
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
)$$

CREATE DEFINER=`root`@`localhost` TRIGGER `trg_categoria_empleado_bd`
BEFORE DELETE ON `categoria_empleado`
FOR EACH ROW
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'No se permite DELETE fisico en categoria_empleado. Use eliminacion logica (UPDATE categoria_empleado SET std_reg=0 ...).'$$

CREATE DEFINER=`root`@`localhost` TRIGGER `trg_categoria_herramienta_ai`
AFTER INSERT ON `categoria_herramienta`
FOR EACH ROW
INSERT INTO `log_user`(
    `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
    `accion`,`resp_system`,`data_old`,`data_new`,`data_diff`,`changed_cols`,
    `connection_id`,`db_user`,`db_host`
) VALUES (
    UUID(),
    (SELECT `id_user` FROM `user_system` WHERE `id_user` = @app_user LIMIT 1),
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
)$$

CREATE DEFINER=`root`@`localhost` TRIGGER `trg_categoria_herramienta_au`
AFTER UPDATE ON `categoria_herramienta`
FOR EACH ROW
INSERT INTO `log_user`(
    `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
    `accion`,`resp_system`,`data_old`,`data_new`,`data_diff`,`changed_cols`,
    `connection_id`,`db_user`,`db_host`
) VALUES (
    UUID(),
    (SELECT `id_user` FROM `user_system` WHERE `id_user` = @app_user LIMIT 1),
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
)$$

CREATE DEFINER=`root`@`localhost` TRIGGER `trg_categoria_herramienta_bd`
BEFORE DELETE ON `categoria_herramienta`
FOR EACH ROW
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'No se permite DELETE fisico en categoria_herramienta. Use eliminacion logica (UPDATE categoria_herramienta SET std_reg=0 ...).'$$

CREATE DEFINER=`root`@`localhost` TRIGGER `trg_empleado_ai`
AFTER INSERT ON `empleado`
FOR EACH ROW
INSERT INTO `log_user`(
    `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
    `accion`,`resp_system`,`data_old`,`data_new`,`data_diff`,`changed_cols`,
    `connection_id`,`db_user`,`db_host`
) VALUES (
    UUID(),
    (SELECT `id_user` FROM `user_system` WHERE `id_user` = @app_user LIMIT 1),
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
)$$

CREATE DEFINER=`root`@`localhost` TRIGGER `trg_empleado_au`
AFTER UPDATE ON `empleado`
FOR EACH ROW
INSERT INTO `log_user`(
    `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
    `accion`,`resp_system`,`data_old`,`data_new`,`data_diff`,`changed_cols`,
    `connection_id`,`db_user`,`db_host`
) VALUES (
    UUID(),
    (SELECT `id_user` FROM `user_system` WHERE `id_user` = @app_user LIMIT 1),
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
)$$

CREATE DEFINER=`root`@`localhost` TRIGGER `trg_empleado_bd`
BEFORE DELETE ON `empleado`
FOR EACH ROW
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'No se permite DELETE fisico en empleado. Use eliminacion logica (UPDATE empleado SET std_reg=0 ...).'$$

CREATE DEFINER=`root`@`localhost` TRIGGER `trg_reporte_generado_ai`
AFTER INSERT ON `reporte_generado`
FOR EACH ROW
INSERT INTO `log_user`(
    `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
    `accion`,`resp_system`,`data_old`,`data_new`,`data_diff`,`changed_cols`,
    `connection_id`,`db_user`,`db_host`
) VALUES (
    UUID(),
    (SELECT `id_user` FROM `user_system` WHERE `id_user` = @app_user LIMIT 1),
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
)$$

CREATE DEFINER=`root`@`localhost` TRIGGER `trg_reporte_generado_au`
AFTER UPDATE ON `reporte_generado`
FOR EACH ROW
INSERT INTO `log_user`(
    `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
    `accion`,`resp_system`,`data_old`,`data_new`,`data_diff`,`changed_cols`,
    `connection_id`,`db_user`,`db_host`
) VALUES (
    UUID(),
    (SELECT `id_user` FROM `user_system` WHERE `id_user` = @app_user LIMIT 1),
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
)$$

CREATE DEFINER=`root`@`localhost` TRIGGER `trg_reporte_generado_bd`
BEFORE DELETE ON `reporte_generado`
FOR EACH ROW
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'No se permite DELETE fisico en reporte_generado. Use eliminacion logica (UPDATE reporte_generado SET std_reg=0 ...).'$$

DELIMITER ;

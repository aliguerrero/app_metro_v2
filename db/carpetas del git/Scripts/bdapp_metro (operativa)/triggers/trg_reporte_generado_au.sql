USE `bdapp_metro`;

DROP TRIGGER IF EXISTS `trg_reporte_generado_au`;
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

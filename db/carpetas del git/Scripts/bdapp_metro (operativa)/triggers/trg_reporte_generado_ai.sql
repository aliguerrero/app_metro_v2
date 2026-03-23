USE `bdapp_metro`;

DROP TRIGGER IF EXISTS `trg_reporte_generado_ai`;
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

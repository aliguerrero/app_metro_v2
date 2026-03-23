USE `bdapp_metro`;

DROP TRIGGER IF EXISTS `trg_empleado_ai`;
DELIMITER $$
CREATE TRIGGER `trg_empleado_ai` AFTER INSERT ON `empleado` FOR EACH ROW INSERT INTO `log_user`(
    `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
    `accion`,`resp_system`,`data_old`,`data_new`,`data_diff`,`changed_cols`,
    `connection_id`,`db_user`,`db_host`
) VALUES (
    UUID(),
    (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
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
)
$$
DELIMITER ;

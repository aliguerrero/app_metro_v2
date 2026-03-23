USE `bdapp_metro`;

DROP TRIGGER IF EXISTS `trg_categoria_empleado_ai`;
DELIMITER $$
CREATE TRIGGER `trg_categoria_empleado_ai` AFTER INSERT ON `categoria_empleado` FOR EACH ROW INSERT INTO `log_user`(
    `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
    `accion`,`resp_system`,`data_old`,`data_new`,`data_diff`,`changed_cols`,
    `connection_id`,`db_user`,`db_host`
) VALUES (
    UUID(),
    (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
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
)
$$
DELIMITER ;

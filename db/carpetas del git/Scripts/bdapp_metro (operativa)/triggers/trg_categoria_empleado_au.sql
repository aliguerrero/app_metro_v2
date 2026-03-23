USE `bdapp_metro`;

DROP TRIGGER IF EXISTS `trg_categoria_empleado_au`;
DELIMITER $$
CREATE TRIGGER `trg_categoria_empleado_au` AFTER UPDATE ON `categoria_empleado` FOR EACH ROW INSERT INTO `log_user`(
    `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
    `accion`,`resp_system`,`data_old`,`data_new`,`data_diff`,`changed_cols`,
    `connection_id`,`db_user`,`db_host`
) VALUES (
    UUID(),
    (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
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
)
$$
DELIMITER ;

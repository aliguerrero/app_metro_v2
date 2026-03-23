USE `bdapp_metro`;

DROP TRIGGER IF EXISTS `trg_empleado_au`;
DELIMITER $$
CREATE TRIGGER `trg_empleado_au` AFTER UPDATE ON `empleado` FOR EACH ROW INSERT INTO `log_user`(
    `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
    `accion`,`resp_system`,`data_old`,`data_new`,`data_diff`,`changed_cols`,
    `connection_id`,`db_user`,`db_host`
) VALUES (
    UUID(),
    (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
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
)
$$
DELIMITER ;

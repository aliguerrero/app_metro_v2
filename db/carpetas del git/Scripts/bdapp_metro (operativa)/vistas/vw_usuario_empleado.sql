USE `bdapp_metro`;

--
-- Estructura para la vista `vw_usuario_empleado`
--
DROP VIEW IF EXISTS `vw_usuario_empleado`;
DROP TABLE IF EXISTS `vw_usuario_empleado`;

CREATE ALGORITHM=UNDEFINED DEFINER=CURRENT_USER SQL SECURITY INVOKER VIEW `vw_usuario_empleado`  AS SELECT `us`.`id_ai_user` AS `id_ai_user`, `us`.`id_empleado` AS `id_empleado`, `us`.`username` AS `username`, `us`.`tipo` AS `id_rol`, `rp`.`nombre_rol` AS `nombre_rol`, `us`.`failed_login_attempts` AS `failed_login_attempts`, `us`.`account_locked` AS `account_locked`, `us`.`locked_at` AS `locked_at`, `us`.`password_reset_required` AS `password_reset_required`, `us`.`last_login_at` AS `last_login_at`, `us`.`last_login_ip` AS `last_login_ip`, `us`.`std_reg` AS `std_reg`, `emp`.`nacionalidad` AS `nacionalidad`, `emp`.`nombre_empleado` AS `nombre_empleado`, `emp`.`telefono` AS `telefono`, `emp`.`correo` AS `correo`, `emp`.`direccion` AS `direccion`, `emp`.`id_ai_categoria_empleado` AS `id_ai_categoria_empleado`, `ce`.`nombre_categoria` AS `categoria_empleado` FROM (((`user_system` `us` left join `empleado` `emp` on(`emp`.`id_empleado` = `us`.`id_empleado`)) left join `categoria_empleado` `ce` on(`ce`.`id_ai_categoria_empleado` = `emp`.`id_ai_categoria_empleado`)) left join `roles_permisos` `rp` on(`rp`.`id` = `us`.`tipo`)) ;

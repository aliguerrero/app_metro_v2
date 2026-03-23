USE `bdapp_metro`;

--
-- Estructura para la vista `vw_log_user_resumen`
--
DROP VIEW IF EXISTS `vw_log_user_resumen`;
DROP TABLE IF EXISTS `vw_log_user_resumen`;

CREATE ALGORITHM=UNDEFINED DEFINER=CURRENT_USER SQL SECURITY INVOKER VIEW `vw_log_user_resumen`  AS SELECT `lu`.`id_log` AS `id_log`, `lu`.`fecha_hora` AS `fecha_hora`, `lu`.`tabla` AS `tabla`, `lu`.`operacion` AS `operacion`, `lu`.`accion` AS `accion`, `lu`.`id_user` AS `id_user`, `us`.`username` AS `username`, `emp`.`nombre_empleado` AS `nombre_empleado`, `lu`.`db_user` AS `db_user`, `lu`.`db_host` AS `db_host`, `lu`.`changed_cols` AS `changed_cols`, `lu`.`std_reg` AS `std_reg` FROM ((`log_user` `lu` left join `user_system` `us` on(`us`.`id_empleado` = `lu`.`id_user`)) left join `empleado` `emp` on(`emp`.`id_empleado` = `lu`.`id_user`)) ;

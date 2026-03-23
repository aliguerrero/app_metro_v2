USE `bdapp_metro`;

--
-- Estructura para la vista `vw_reportes_generados`
--
DROP VIEW IF EXISTS `vw_reportes_generados`;
DROP TABLE IF EXISTS `vw_reportes_generados`;

CREATE ALGORITHM=UNDEFINED DEFINER=CURRENT_USER SQL SECURITY INVOKER VIEW `vw_reportes_generados`  AS SELECT `rg`.`id_ai_reporte_generado` AS `id_ai_reporte_generado`, `rg`.`tipo_reporte` AS `tipo_reporte`, `rg`.`titulo_reporte` AS `titulo_reporte`, `rg`.`nombre_archivo` AS `nombre_archivo`, `rg`.`ruta_archivo` AS `ruta_archivo`, `rg`.`mime_type` AS `mime_type`, `rg`.`tamano_bytes` AS `tamano_bytes`, `rg`.`parametros_json` AS `parametros_json`, `rg`.`id_user_generador` AS `id_user_generador`, `rg`.`nombre_user_generador` AS `nombre_user_generador`, `rg`.`username_generador` AS `username_generador`, `rg`.`created_at` AS `created_at`, `emp`.`nombre_empleado` AS `nombre_empleado`, `emp`.`correo` AS `correo`, `us`.`tipo` AS `id_rol`, `rp`.`nombre_rol` AS `nombre_rol`, `rg`.`std_reg` AS `std_reg` FROM (((`reporte_generado` `rg` left join `empleado` `emp` on(`emp`.`id_empleado` = `rg`.`id_user_generador`)) left join `user_system` `us` on(`us`.`id_empleado` = `rg`.`id_user_generador`)) left join `roles_permisos` `rp` on(`rp`.`id` = `us`.`tipo`)) WHERE `rg`.`std_reg` = 1 ;

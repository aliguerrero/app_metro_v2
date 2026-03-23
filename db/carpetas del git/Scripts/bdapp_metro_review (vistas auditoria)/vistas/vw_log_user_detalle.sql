USE `bdapp_metro_review`;

--
-- Estructura para la vista `vw_log_user_detalle`
--
DROP VIEW IF EXISTS `vw_log_user_detalle`;
DROP TABLE IF EXISTS `vw_log_user_detalle`;

CREATE ALGORITHM=UNDEFINED DEFINER=CURRENT_USER SQL SECURITY DEFINER VIEW `vw_log_user_detalle`  AS SELECT `bdapp_metro_audit`.`log_user`.`id_log` AS `id_log`, `bdapp_metro_audit`.`log_user`.`fecha_hora` AS `fecha_hora`, `bdapp_metro_audit`.`log_user`.`tabla` AS `tabla`, `bdapp_metro_audit`.`log_user`.`operacion` AS `operacion`, `bdapp_metro_audit`.`log_user`.`pk_registro` AS `pk_registro`, `bdapp_metro_audit`.`log_user`.`accion` AS `accion`, `bdapp_metro_audit`.`log_user`.`changed_cols` AS `changed_cols`, `bdapp_metro_audit`.`log_user`.`data_diff` AS `data_diff`, `bdapp_metro_audit`.`log_user`.`data_old` AS `data_old`, `bdapp_metro_audit`.`log_user`.`data_new` AS `data_new`, `bdapp_metro_audit`.`log_user`.`id_user` AS `id_user`, `bdapp_metro_audit`.`log_user`.`db_user` AS `db_user`, `bdapp_metro_audit`.`log_user`.`db_host` AS `db_host`, `bdapp_metro_audit`.`log_user`.`connection_id` AS `connection_id`, `bdapp_metro_audit`.`log_user`.`event_uuid` AS `event_uuid` FROM `bdapp_metro_audit`.`log_user` ;

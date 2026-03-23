USE `bdapp_metro_review`;

--
-- Estructura para la vista `vw_log_user_resumen`
--
DROP VIEW IF EXISTS `vw_log_user_resumen`;
DROP TABLE IF EXISTS `vw_log_user_resumen`;

CREATE ALGORITHM=UNDEFINED DEFINER=CURRENT_USER SQL SECURITY DEFINER VIEW `vw_log_user_resumen`  AS SELECT cast(`bdapp_metro_audit`.`log_user`.`fecha_hora` as date) AS `dia`, `bdapp_metro_audit`.`log_user`.`tabla` AS `tabla`, `bdapp_metro_audit`.`log_user`.`operacion` AS `operacion`, count(0) AS `total` FROM `bdapp_metro_audit`.`log_user` GROUP BY cast(`bdapp_metro_audit`.`log_user`.`fecha_hora` as date), `bdapp_metro_audit`.`log_user`.`tabla`, `bdapp_metro_audit`.`log_user`.`operacion` ORDER BY cast(`bdapp_metro_audit`.`log_user`.`fecha_hora` as date) DESC, `bdapp_metro_audit`.`log_user`.`tabla` ASC, `bdapp_metro_audit`.`log_user`.`operacion` ASC ;

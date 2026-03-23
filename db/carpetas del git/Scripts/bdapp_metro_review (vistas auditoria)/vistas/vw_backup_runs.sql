USE `bdapp_metro_review`;

--
-- Estructura para la vista `vw_backup_runs`
--
DROP VIEW IF EXISTS `vw_backup_runs`;
DROP TABLE IF EXISTS `vw_backup_runs`;

CREATE ALGORITHM=UNDEFINED DEFINER=CURRENT_USER SQL SECURITY DEFINER VIEW `vw_backup_runs`  AS SELECT `bdapp_metro_audit`.`backup_runs`.`id` AS `id`, `bdapp_metro_audit`.`backup_runs`.`run_at` AS `run_at`, `bdapp_metro_audit`.`backup_runs`.`synced_rows` AS `synced_rows`, `bdapp_metro_audit`.`backup_runs`.`backed_rows` AS `backed_rows` FROM `bdapp_metro_audit`.`backup_runs` ORDER BY `bdapp_metro_audit`.`backup_runs`.`run_at` DESC ;

USE `bdapp_metro`;

DROP TRIGGER IF EXISTS `trg_turno_trabajo_au`;
DELIMITER $$
CREATE TRIGGER `trg_turno_trabajo_au` AFTER UPDATE ON `turno_trabajo` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
  'turno_trabajo',
  CASE WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN 'SOFT_DELETE' WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN 'RESTORE' ELSE 'UPDATE' END,
  CONCAT('id_ai_turno=', NEW.`id_ai_turno`),
  JSON_OBJECT('id_ai_turno', NEW.`id_ai_turno`),
  CASE WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN CONCAT('ELIMINAR (LOGICO) ', 'turno_trabajo') WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN CONCAT('REACTIVAR ', 'turno_trabajo') ELSE CONCAT('MODIFICAR ', 'turno_trabajo') END,
  CASE WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN CONCAT('SOFT_DELETE turno_trabajo ', CONCAT('id_ai_turno=', NEW.`id_ai_turno`)) WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN CONCAT('RESTORE turno_trabajo ', CONCAT('id_ai_turno=', NEW.`id_ai_turno`)) ELSE CONCAT('UPDATE turno_trabajo ', CONCAT('id_ai_turno=', NEW.`id_ai_turno`)) END,
  JSON_OBJECT('id_ai_turno', OLD.`id_ai_turno`, 'nombre_turno', OLD.`nombre_turno`, 'std_reg', OLD.`std_reg`),
  JSON_OBJECT('id_ai_turno', NEW.`id_ai_turno`, 'nombre_turno', NEW.`nombre_turno`, 'std_reg', NEW.`std_reg`),
  JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_OBJECT(), IF(NOT (OLD.`id_ai_turno` <=> NEW.`id_ai_turno`), JSON_OBJECT('id_ai_turno', JSON_ARRAY(OLD.`id_ai_turno`, NEW.`id_ai_turno`)), JSON_OBJECT())), IF(NOT (OLD.`nombre_turno` <=> NEW.`nombre_turno`), JSON_OBJECT('nombre_turno', JSON_ARRAY(OLD.`nombre_turno`, NEW.`nombre_turno`)), JSON_OBJECT())), IF(NOT (OLD.`std_reg` <=> NEW.`std_reg`), JSON_OBJECT('std_reg', JSON_ARRAY(OLD.`std_reg`, NEW.`std_reg`)), JSON_OBJECT())),
  NULLIF(CONCAT_WS(',', IF(NOT (OLD.`id_ai_turno` <=> NEW.`id_ai_turno`), 'id_ai_turno', NULL), IF(NOT (OLD.`nombre_turno` <=> NEW.`nombre_turno`), 'nombre_turno', NULL), IF(NOT (OLD.`std_reg` <=> NEW.`std_reg`), 'std_reg', NULL)), ''),
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)
$$
DELIMITER ;

USE `bdapp_metro`;

DROP TRIGGER IF EXISTS `trg_herramienta_au`;
DELIMITER $$
CREATE TRIGGER `trg_herramienta_au` AFTER UPDATE ON `herramienta` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
  'herramienta',
  CASE WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN 'SOFT_DELETE' WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN 'RESTORE' ELSE 'UPDATE' END,
  CONCAT('id_ai_herramienta=', NEW.`id_ai_herramienta`),
  JSON_OBJECT('id_ai_herramienta', NEW.`id_ai_herramienta`),
  CASE WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN CONCAT('ELIMINAR (LOGICO) ', 'herramienta') WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN CONCAT('REACTIVAR ', 'herramienta') ELSE CONCAT('MODIFICAR ', 'herramienta') END,
  CASE WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN CONCAT('SOFT_DELETE herramienta ', CONCAT('id_ai_herramienta=', NEW.`id_ai_herramienta`)) WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN CONCAT('RESTORE herramienta ', CONCAT('id_ai_herramienta=', NEW.`id_ai_herramienta`)) ELSE CONCAT('UPDATE herramienta ', CONCAT('id_ai_herramienta=', NEW.`id_ai_herramienta`)) END,
  JSON_OBJECT('id_ai_herramienta', OLD.`id_ai_herramienta`, 'nombre_herramienta', OLD.`nombre_herramienta`, 'cantidad', OLD.`cantidad`, 'estado', OLD.`estado`, 'std_reg', OLD.`std_reg`),
  JSON_OBJECT('id_ai_herramienta', NEW.`id_ai_herramienta`, 'nombre_herramienta', NEW.`nombre_herramienta`, 'cantidad', NEW.`cantidad`, 'estado', NEW.`estado`, 'std_reg', NEW.`std_reg`),
  JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_OBJECT(), IF(NOT (OLD.`id_ai_herramienta` <=> NEW.`id_ai_herramienta`), JSON_OBJECT('id_ai_herramienta', JSON_ARRAY(OLD.`id_ai_herramienta`, NEW.`id_ai_herramienta`)), JSON_OBJECT())), IF(NOT (OLD.`nombre_herramienta` <=> NEW.`nombre_herramienta`), JSON_OBJECT('nombre_herramienta', JSON_ARRAY(OLD.`nombre_herramienta`, NEW.`nombre_herramienta`)), JSON_OBJECT())), IF(NOT (OLD.`cantidad` <=> NEW.`cantidad`), JSON_OBJECT('cantidad', JSON_ARRAY(OLD.`cantidad`, NEW.`cantidad`)), JSON_OBJECT())), IF(NOT (OLD.`estado` <=> NEW.`estado`), JSON_OBJECT('estado', JSON_ARRAY(OLD.`estado`, NEW.`estado`)), JSON_OBJECT())), IF(NOT (OLD.`std_reg` <=> NEW.`std_reg`), JSON_OBJECT('std_reg', JSON_ARRAY(OLD.`std_reg`, NEW.`std_reg`)), JSON_OBJECT())),
  NULLIF(CONCAT_WS(',', IF(NOT (OLD.`id_ai_herramienta` <=> NEW.`id_ai_herramienta`), 'id_ai_herramienta', NULL), IF(NOT (OLD.`nombre_herramienta` <=> NEW.`nombre_herramienta`), 'nombre_herramienta', NULL), IF(NOT (OLD.`cantidad` <=> NEW.`cantidad`), 'cantidad', NULL), IF(NOT (OLD.`estado` <=> NEW.`estado`), 'estado', NULL), IF(NOT (OLD.`std_reg` <=> NEW.`std_reg`), 'std_reg', NULL)), ''),
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)
$$
DELIMITER ;

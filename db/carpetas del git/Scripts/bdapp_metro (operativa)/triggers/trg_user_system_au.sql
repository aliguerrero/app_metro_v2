USE `bdapp_metro`;

DROP TRIGGER IF EXISTS `trg_user_system_au`;
DELIMITER $$
CREATE TRIGGER `trg_user_system_au` AFTER UPDATE ON `user_system` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
  'user_system',
  CASE WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN 'SOFT_DELETE' WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN 'RESTORE' ELSE 'UPDATE' END,
  CONCAT('id_empleado=', NEW.`id_empleado`),
  JSON_OBJECT('id_empleado', NEW.`id_empleado`),
  CASE WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN CONCAT('ELIMINAR (LOGICO) ', 'user_system') WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN CONCAT('REACTIVAR ', 'user_system') ELSE CONCAT('MODIFICAR ', 'user_system') END,
  CASE WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN CONCAT('SOFT_DELETE user_system ', CONCAT('id_empleado=', NEW.`id_empleado`)) WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN CONCAT('RESTORE user_system ', CONCAT('id_empleado=', NEW.`id_empleado`)) ELSE CONCAT('UPDATE user_system ', CONCAT('id_empleado=', NEW.`id_empleado`)) END,
  JSON_OBJECT('id_ai_user', OLD.`id_ai_user`, 'id_empleado', OLD.`id_empleado`, 'username', OLD.`username`, 'password', '***', 'tipo', OLD.`tipo`, 'std_reg', OLD.`std_reg`),
  JSON_OBJECT('id_ai_user', NEW.`id_ai_user`, 'id_empleado', NEW.`id_empleado`, 'username', NEW.`username`, 'password', '***', 'tipo', NEW.`tipo`, 'std_reg', NEW.`std_reg`),
  JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_OBJECT(), IF(NOT (OLD.`id_ai_user` <=> NEW.`id_ai_user`), JSON_OBJECT('id_ai_user', JSON_ARRAY(OLD.`id_ai_user`, NEW.`id_ai_user`)), JSON_OBJECT())), IF(NOT (OLD.`id_empleado` <=> NEW.`id_empleado`), JSON_OBJECT('id_empleado', JSON_ARRAY(OLD.`id_empleado`, NEW.`id_empleado`)), JSON_OBJECT())), IF(NOT (OLD.`username` <=> NEW.`username`), JSON_OBJECT('username', JSON_ARRAY(OLD.`username`, NEW.`username`)), JSON_OBJECT())), IF(NOT (OLD.`password` <=> NEW.`password`), JSON_OBJECT('password', 'CHANGED'), JSON_OBJECT())), IF(NOT (OLD.`tipo` <=> NEW.`tipo`), JSON_OBJECT('tipo', JSON_ARRAY(OLD.`tipo`, NEW.`tipo`)), JSON_OBJECT())), IF(NOT (OLD.`std_reg` <=> NEW.`std_reg`), JSON_OBJECT('std_reg', JSON_ARRAY(OLD.`std_reg`, NEW.`std_reg`)), JSON_OBJECT())),
  NULLIF(CONCAT_WS(',', IF(NOT (OLD.`id_ai_user` <=> NEW.`id_ai_user`), 'id_ai_user', NULL), IF(NOT (OLD.`id_empleado` <=> NEW.`id_empleado`), 'id_empleado', NULL), IF(NOT (OLD.`username` <=> NEW.`username`), 'username', NULL), IF(NOT (OLD.`password` <=> NEW.`password`), 'password', NULL), IF(NOT (OLD.`tipo` <=> NEW.`tipo`), 'tipo', NULL), IF(NOT (OLD.`std_reg` <=> NEW.`std_reg`), 'std_reg', NULL)), ''),
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)
$$
DELIMITER ;

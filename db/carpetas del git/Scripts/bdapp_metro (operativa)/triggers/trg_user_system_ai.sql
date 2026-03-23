USE `bdapp_metro`;

DROP TRIGGER IF EXISTS `trg_user_system_ai`;
DELIMITER $$
CREATE TRIGGER `trg_user_system_ai` AFTER INSERT ON `user_system` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
  'user_system',
  'INSERT',
  CONCAT('id_empleado=', NEW.`id_empleado`),
  JSON_OBJECT('id_empleado', NEW.`id_empleado`),
  CONCAT('CREAR ', 'user_system'),
  CONCAT('INSERT user_system ', CONCAT('id_empleado=', NEW.`id_empleado`)),
  NULL,
  JSON_OBJECT('id_ai_user', NEW.`id_ai_user`, 'id_empleado', NEW.`id_empleado`, 'username', NEW.`username`, 'password', '***', 'tipo', NEW.`tipo`, 'std_reg', NEW.`std_reg`),
  JSON_OBJECT('id_ai_user', NEW.`id_ai_user`, 'id_empleado', NEW.`id_empleado`, 'username', NEW.`username`, 'password', '***', 'tipo', NEW.`tipo`, 'std_reg', NEW.`std_reg`),
  'id_ai_user,id_empleado,username,password,tipo,std_reg',
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)
$$
DELIMITER ;

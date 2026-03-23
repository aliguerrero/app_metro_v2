USE `bdapp_metro`;

DROP TRIGGER IF EXISTS `trg_herramienta_ai`;
DELIMITER $$
CREATE TRIGGER `trg_herramienta_ai` AFTER INSERT ON `herramienta` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
  'herramienta',
  'INSERT',
  CONCAT('id_ai_herramienta=', NEW.`id_ai_herramienta`),
  JSON_OBJECT('id_ai_herramienta', NEW.`id_ai_herramienta`),
  CONCAT('CREAR ', 'herramienta'),
  CONCAT('INSERT herramienta ', CONCAT('id_ai_herramienta=', NEW.`id_ai_herramienta`)),
  NULL,
  JSON_OBJECT('id_ai_herramienta', NEW.`id_ai_herramienta`, 'nombre_herramienta', NEW.`nombre_herramienta`, 'cantidad', NEW.`cantidad`, 'estado', NEW.`estado`, 'std_reg', NEW.`std_reg`),
  JSON_OBJECT('id_ai_herramienta', NEW.`id_ai_herramienta`, 'nombre_herramienta', NEW.`nombre_herramienta`, 'cantidad', NEW.`cantidad`, 'estado', NEW.`estado`, 'std_reg', NEW.`std_reg`),
  'id_ai_herramienta,nombre_herramienta,cantidad,estado,std_reg',
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)
$$
DELIMITER ;

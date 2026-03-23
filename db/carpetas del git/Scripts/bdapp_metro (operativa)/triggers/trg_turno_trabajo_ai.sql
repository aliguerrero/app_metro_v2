USE `bdapp_metro`;

DROP TRIGGER IF EXISTS `trg_turno_trabajo_ai`;
DELIMITER $$
CREATE TRIGGER `trg_turno_trabajo_ai` AFTER INSERT ON `turno_trabajo` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
  'turno_trabajo',
  'INSERT',
  CONCAT('id_ai_turno=', NEW.`id_ai_turno`),
  JSON_OBJECT('id_ai_turno', NEW.`id_ai_turno`),
  CONCAT('CREAR ', 'turno_trabajo'),
  CONCAT('INSERT turno_trabajo ', CONCAT('id_ai_turno=', NEW.`id_ai_turno`)),
  NULL,
  JSON_OBJECT('id_ai_turno', NEW.`id_ai_turno`, 'nombre_turno', NEW.`nombre_turno`, 'std_reg', NEW.`std_reg`),
  JSON_OBJECT('id_ai_turno', NEW.`id_ai_turno`, 'nombre_turno', NEW.`nombre_turno`, 'std_reg', NEW.`std_reg`),
  'id_ai_turno,nombre_turno,std_reg',
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)
$$
DELIMITER ;

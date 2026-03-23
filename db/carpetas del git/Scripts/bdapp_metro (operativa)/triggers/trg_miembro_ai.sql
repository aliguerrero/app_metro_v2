USE `bdapp_metro`;

DROP TRIGGER IF EXISTS `trg_miembro_ai`;
DELIMITER $$
CREATE TRIGGER `trg_miembro_ai` AFTER INSERT ON `miembro` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
  'miembro',
  'INSERT',
  CONCAT('id_ai_miembro=', NEW.`id_ai_miembro`),
  JSON_OBJECT('id_ai_miembro', NEW.`id_ai_miembro`),
  CONCAT('CREAR ', 'miembro'),
  CONCAT('INSERT miembro ', CONCAT('id_ai_miembro=', NEW.`id_ai_miembro`)),
  NULL,
  JSON_OBJECT('id_ai_miembro', NEW.`id_ai_miembro`, 'id_miembro', NEW.`id_miembro`, 'nombre_miembro', NEW.`nombre_miembro`, 'tipo_miembro', NEW.`tipo_miembro`, 'std_reg', NEW.`std_reg`),
  JSON_OBJECT('id_ai_miembro', NEW.`id_ai_miembro`, 'id_miembro', NEW.`id_miembro`, 'nombre_miembro', NEW.`nombre_miembro`, 'tipo_miembro', NEW.`tipo_miembro`, 'std_reg', NEW.`std_reg`),
  'id_ai_miembro,id_miembro,nombre_miembro,tipo_miembro,std_reg',
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)
$$
DELIMITER ;

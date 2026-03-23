USE `bdapp_metro`;

DROP TRIGGER IF EXISTS `trg_sitio_trabajo_ai`;
DELIMITER $$
CREATE TRIGGER `trg_sitio_trabajo_ai` AFTER INSERT ON `sitio_trabajo` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
  'sitio_trabajo',
  'INSERT',
  CONCAT('id_ai_sitio=', NEW.`id_ai_sitio`),
  JSON_OBJECT('id_ai_sitio', NEW.`id_ai_sitio`),
  CONCAT('CREAR ', 'sitio_trabajo'),
  CONCAT('INSERT sitio_trabajo ', CONCAT('id_ai_sitio=', NEW.`id_ai_sitio`)),
  NULL,
  JSON_OBJECT('id_ai_sitio', NEW.`id_ai_sitio`, 'nombre_sitio', NEW.`nombre_sitio`, 'std_reg', NEW.`std_reg`),
  JSON_OBJECT('id_ai_sitio', NEW.`id_ai_sitio`, 'nombre_sitio', NEW.`nombre_sitio`, 'std_reg', NEW.`std_reg`),
  'id_ai_sitio,nombre_sitio,std_reg',
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)
$$
DELIMITER ;

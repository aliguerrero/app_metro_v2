USE `bdapp_metro`;

DROP TRIGGER IF EXISTS `trg_area_trabajo_ai`;
DELIMITER $$
CREATE TRIGGER `trg_area_trabajo_ai` AFTER INSERT ON `area_trabajo` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
  'area_trabajo',
  'INSERT',
  CONCAT('id_ai_area=', NEW.`id_ai_area`),
  JSON_OBJECT('id_ai_area', NEW.`id_ai_area`),
  CONCAT('CREAR ', 'area_trabajo'),
  CONCAT('INSERT area_trabajo ', CONCAT('id_ai_area=', NEW.`id_ai_area`)),
  NULL,
  JSON_OBJECT('id_ai_area', NEW.`id_ai_area`, 'nombre_area', NEW.`nombre_area`, 'nomeclatura', NEW.`nomeclatura`, 'std_reg', NEW.`std_reg`),
  JSON_OBJECT('id_ai_area', NEW.`id_ai_area`, 'nombre_area', NEW.`nombre_area`, 'nomeclatura', NEW.`nomeclatura`, 'std_reg', NEW.`std_reg`),
  'id_ai_area,nombre_area,nomeclatura,std_reg',
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)
$$
DELIMITER ;

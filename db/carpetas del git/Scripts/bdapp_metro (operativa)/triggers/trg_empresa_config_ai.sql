USE `bdapp_metro`;

DROP TRIGGER IF EXISTS `trg_empresa_config_ai`;
DELIMITER $$
CREATE TRIGGER `trg_empresa_config_ai` AFTER INSERT ON `empresa_config` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
  'empresa_config',
  'INSERT',
  CONCAT('id=', NEW.`id`),
  JSON_OBJECT('id', NEW.`id`),
  CONCAT('CREAR ', 'empresa_config'),
  CONCAT('INSERT empresa_config ', CONCAT('id=', NEW.`id`)),
  NULL,
  JSON_OBJECT('id', NEW.`id`, 'nombre', NEW.`nombre`, 'rif', NEW.`rif`, 'direccion', NEW.`direccion`, 'telefono', NEW.`telefono`, 'email', NEW.`email`, 'logo', NEW.`logo`, 'created_at', NEW.`created_at`, 'updated_at', NEW.`updated_at`),
  JSON_OBJECT('id', NEW.`id`, 'nombre', NEW.`nombre`, 'rif', NEW.`rif`, 'direccion', NEW.`direccion`, 'telefono', NEW.`telefono`, 'email', NEW.`email`, 'logo', NEW.`logo`, 'created_at', NEW.`created_at`, 'updated_at', NEW.`updated_at`),
  'id,nombre,rif,direccion,telefono,email,logo,created_at,updated_at',
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)
$$
DELIMITER ;

USE `bdapp_metro`;

DROP TRIGGER IF EXISTS `trg_empresa_config_ad`;
DELIMITER $$
CREATE TRIGGER `trg_empresa_config_ad` AFTER DELETE ON `empresa_config` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
  'empresa_config',
  'DELETE',
  CONCAT('id=', OLD.`id`),
  JSON_OBJECT('id', OLD.`id`),
  CONCAT('ELIMINAR ', 'empresa_config'),
  CONCAT('DELETE empresa_config ', CONCAT('id=', OLD.`id`)),
  JSON_OBJECT('id', OLD.`id`, 'nombre', OLD.`nombre`, 'rif', OLD.`rif`, 'direccion', OLD.`direccion`, 'telefono', OLD.`telefono`, 'email', OLD.`email`, 'logo', OLD.`logo`, 'created_at', OLD.`created_at`, 'updated_at', OLD.`updated_at`),
  NULL,
  NULL,
  NULL,
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)
$$
DELIMITER ;

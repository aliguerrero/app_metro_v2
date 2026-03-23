USE `bdapp_metro`;

DROP TRIGGER IF EXISTS `trg_roles_permisos_ad`;
DELIMITER $$
CREATE TRIGGER `trg_roles_permisos_ad` AFTER DELETE ON `roles_permisos` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
  'roles_permisos',
  'DELETE',
  CONCAT('id=', OLD.`id`),
  JSON_OBJECT('id', OLD.`id`),
  CONCAT('ELIMINAR ', 'roles_permisos'),
  CONCAT('DELETE roles_permisos ', CONCAT('id=', OLD.`id`)),
  JSON_OBJECT('id', OLD.`id`, 'nombre_rol', OLD.`nombre_rol`, 'perm_usuarios_view', OLD.`perm_usuarios_view`, 'perm_usuarios_add', OLD.`perm_usuarios_add`, 'perm_usuarios_edit', OLD.`perm_usuarios_edit`, 'perm_usuarios_delete', OLD.`perm_usuarios_delete`, 'perm_herramienta_view', OLD.`perm_herramienta_view`, 'perm_herramienta_add', OLD.`perm_herramienta_add`, 'perm_herramienta_edit', OLD.`perm_herramienta_edit`, 'perm_herramienta_delete', OLD.`perm_herramienta_delete`, 'perm_miembro_view', OLD.`perm_miembro_view`, 'perm_miembro_add', OLD.`perm_miembro_add`, 'perm_miembro_edit', OLD.`perm_miembro_edit`, 'perm_miembro_delete', OLD.`perm_miembro_delete`, 'perm_ot_view', OLD.`perm_ot_view`, 'perm_ot_add', OLD.`perm_ot_add`, 'perm_ot_edit', OLD.`perm_ot_edit`, 'perm_ot_delete', OLD.`perm_ot_delete`, 'perm_ot_add_detalle', OLD.`perm_ot_add_detalle`, 'perm_ot_generar_reporte', OLD.`perm_ot_generar_reporte`, 'perm_ot_add_herramienta', OLD.`perm_ot_add_herramienta`),
  NULL,
  NULL,
  NULL,
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)
$$
DELIMITER ;

USE `bdapp_metro`;

DROP TRIGGER IF EXISTS `trg_roles_permisos_ai`;
DELIMITER $$
CREATE TRIGGER `trg_roles_permisos_ai` AFTER INSERT ON `roles_permisos` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
  'roles_permisos',
  'INSERT',
  CONCAT('id=', NEW.`id`),
  JSON_OBJECT('id', NEW.`id`),
  CONCAT('CREAR ', 'roles_permisos'),
  CONCAT('INSERT roles_permisos ', CONCAT('id=', NEW.`id`)),
  NULL,
  JSON_OBJECT('id', NEW.`id`, 'nombre_rol', NEW.`nombre_rol`, 'perm_usuarios_view', NEW.`perm_usuarios_view`, 'perm_usuarios_add', NEW.`perm_usuarios_add`, 'perm_usuarios_edit', NEW.`perm_usuarios_edit`, 'perm_usuarios_delete', NEW.`perm_usuarios_delete`, 'perm_herramienta_view', NEW.`perm_herramienta_view`, 'perm_herramienta_add', NEW.`perm_herramienta_add`, 'perm_herramienta_edit', NEW.`perm_herramienta_edit`, 'perm_herramienta_delete', NEW.`perm_herramienta_delete`, 'perm_miembro_view', NEW.`perm_miembro_view`, 'perm_miembro_add', NEW.`perm_miembro_add`, 'perm_miembro_edit', NEW.`perm_miembro_edit`, 'perm_miembro_delete', NEW.`perm_miembro_delete`, 'perm_ot_view', NEW.`perm_ot_view`, 'perm_ot_add', NEW.`perm_ot_add`, 'perm_ot_edit', NEW.`perm_ot_edit`, 'perm_ot_delete', NEW.`perm_ot_delete`, 'perm_ot_add_detalle', NEW.`perm_ot_add_detalle`, 'perm_ot_generar_reporte', NEW.`perm_ot_generar_reporte`, 'perm_ot_add_herramienta', NEW.`perm_ot_add_herramienta`),
  JSON_OBJECT('id', NEW.`id`, 'nombre_rol', NEW.`nombre_rol`, 'perm_usuarios_view', NEW.`perm_usuarios_view`, 'perm_usuarios_add', NEW.`perm_usuarios_add`, 'perm_usuarios_edit', NEW.`perm_usuarios_edit`, 'perm_usuarios_delete', NEW.`perm_usuarios_delete`, 'perm_herramienta_view', NEW.`perm_herramienta_view`, 'perm_herramienta_add', NEW.`perm_herramienta_add`, 'perm_herramienta_edit', NEW.`perm_herramienta_edit`, 'perm_herramienta_delete', NEW.`perm_herramienta_delete`, 'perm_miembro_view', NEW.`perm_miembro_view`, 'perm_miembro_add', NEW.`perm_miembro_add`, 'perm_miembro_edit', NEW.`perm_miembro_edit`, 'perm_miembro_delete', NEW.`perm_miembro_delete`, 'perm_ot_view', NEW.`perm_ot_view`, 'perm_ot_add', NEW.`perm_ot_add`, 'perm_ot_edit', NEW.`perm_ot_edit`, 'perm_ot_delete', NEW.`perm_ot_delete`, 'perm_ot_add_detalle', NEW.`perm_ot_add_detalle`, 'perm_ot_generar_reporte', NEW.`perm_ot_generar_reporte`, 'perm_ot_add_herramienta', NEW.`perm_ot_add_herramienta`),
  'id,nombre_rol,perm_usuarios_view,perm_usuarios_add,perm_usuarios_edit,perm_usuarios_delete,perm_herramienta_view,perm_herramienta_add,perm_herramienta_edit,perm_herramienta_delete,perm_miembro_view,perm_miembro_add,perm_miembro_edit,perm_miembro_delete,perm_ot_view,perm_ot_add,perm_ot_edit,perm_ot_delete,perm_ot_add_detalle,perm_ot_generar_reporte,perm_ot_add_herramienta',
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)
$$
DELIMITER ;

-- Modulo: Scripts_ddl
-- Archivo: roles_permisos.sql
-- Funcion: define los roles y permisos funcionales del sistema.
-- Version: v_1.0

-- ============================================================================
-- Base de datos operativa
-- ============================================================================
CREATE DATABASE IF NOT EXISTS `bdapp_metro` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `bdapp_metro`;

-- -----------------------------------------------------------------------------
-- Bloque 1. Reinicio controlado y creacion de la tabla
-- elimina `roles_permisos` si ya existe y la vuelve a crear con `IF NOT EXISTS` usando la definicion consolidada del esquema.
-- -----------------------------------------------------------------------------
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS `roles_permisos`;
CREATE TABLE IF NOT EXISTS `roles_permisos` (
  `id` int(11) NOT NULL COMMENT 'id autoincrementable',
  `nombre_rol` varchar(100) NOT NULL COMMENT 'Nombre del rol de usuario',
  `perm_usuarios_view` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Permiso para visualizar usuarios',
  `perm_usuarios_add` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Permiso para registrar nuevos usuarios',
  `perm_usuarios_edit` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Permiso para editar usuarios existentes',
  `perm_usuarios_delete` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Permiso para eliminar usuarios',
  `perm_herramienta_view` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Permiso para visualizar herramientas',
  `perm_herramienta_add` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Permiso para registrar nuevas herramientas',
  `perm_herramienta_edit` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Permiso para editar herramientas',
  `perm_herramienta_delete` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Permiso para eliminar herramientas',
  `perm_miembro_view` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Permiso para visualizar miembros',
  `perm_miembro_add` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Permiso para registrar nuevos miembros',
  `perm_miembro_edit` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Permiso para editar miembros',
  `perm_miembro_delete` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Permiso para eliminar miembros',
  `perm_ot_view` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Permiso para visualizar ordenes de trabajo',
  `perm_ot_add` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Permiso para registrar nuevas ordenes de trabajo',
  `perm_ot_edit` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Permiso para editar ordenes de trabajo',
  `perm_ot_delete` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Permiso para eliminar ordenes de trabajo',
  `perm_ot_add_detalle` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Permiso para agregar detalles a ordenes de trabajo',
  `perm_ot_generar_reporte` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Permiso para generar reportes de ordenes de trabajo',
  `perm_ot_add_herramienta` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Permiso para asociar herramientas a ordenes de trabajo'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
SET FOREIGN_KEY_CHECKS = 1;

-- -----------------------------------------------------------------------------
-- Bloque 2. Disparador asociado
-- el disparador `trg_roles_permisos_ad` registra la auditoria asociada a la eliminacion en `roles_permisos` despues de ejecutarse la operacion.
-- -----------------------------------------------------------------------------
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

-- -----------------------------------------------------------------------------
-- Bloque 3. Disparador asociado
-- el disparador `trg_roles_permisos_ai` registra la auditoria asociada a la insercion en `roles_permisos` despues de ejecutarse la operacion.
-- -----------------------------------------------------------------------------
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

-- -----------------------------------------------------------------------------
-- Bloque 4. Disparador asociado
-- el disparador `trg_roles_permisos_au` registra la auditoria asociada a la actualizacion en `roles_permisos` despues de ejecutarse la operacion.
-- -----------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER `trg_roles_permisos_au` AFTER UPDATE ON `roles_permisos` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
  'roles_permisos',
  'UPDATE',
  CONCAT('id=', NEW.`id`),
  JSON_OBJECT('id', NEW.`id`),
  CONCAT('MODIFICAR ', 'roles_permisos'),
  CONCAT('UPDATE roles_permisos ', CONCAT('id=', NEW.`id`)),
  JSON_OBJECT('id', OLD.`id`, 'nombre_rol', OLD.`nombre_rol`, 'perm_usuarios_view', OLD.`perm_usuarios_view`, 'perm_usuarios_add', OLD.`perm_usuarios_add`, 'perm_usuarios_edit', OLD.`perm_usuarios_edit`, 'perm_usuarios_delete', OLD.`perm_usuarios_delete`, 'perm_herramienta_view', OLD.`perm_herramienta_view`, 'perm_herramienta_add', OLD.`perm_herramienta_add`, 'perm_herramienta_edit', OLD.`perm_herramienta_edit`, 'perm_herramienta_delete', OLD.`perm_herramienta_delete`, 'perm_miembro_view', OLD.`perm_miembro_view`, 'perm_miembro_add', OLD.`perm_miembro_add`, 'perm_miembro_edit', OLD.`perm_miembro_edit`, 'perm_miembro_delete', OLD.`perm_miembro_delete`, 'perm_ot_view', OLD.`perm_ot_view`, 'perm_ot_add', OLD.`perm_ot_add`, 'perm_ot_edit', OLD.`perm_ot_edit`, 'perm_ot_delete', OLD.`perm_ot_delete`, 'perm_ot_add_detalle', OLD.`perm_ot_add_detalle`, 'perm_ot_generar_reporte', OLD.`perm_ot_generar_reporte`, 'perm_ot_add_herramienta', OLD.`perm_ot_add_herramienta`),
  JSON_OBJECT('id', NEW.`id`, 'nombre_rol', NEW.`nombre_rol`, 'perm_usuarios_view', NEW.`perm_usuarios_view`, 'perm_usuarios_add', NEW.`perm_usuarios_add`, 'perm_usuarios_edit', NEW.`perm_usuarios_edit`, 'perm_usuarios_delete', NEW.`perm_usuarios_delete`, 'perm_herramienta_view', NEW.`perm_herramienta_view`, 'perm_herramienta_add', NEW.`perm_herramienta_add`, 'perm_herramienta_edit', NEW.`perm_herramienta_edit`, 'perm_herramienta_delete', NEW.`perm_herramienta_delete`, 'perm_miembro_view', NEW.`perm_miembro_view`, 'perm_miembro_add', NEW.`perm_miembro_add`, 'perm_miembro_edit', NEW.`perm_miembro_edit`, 'perm_miembro_delete', NEW.`perm_miembro_delete`, 'perm_ot_view', NEW.`perm_ot_view`, 'perm_ot_add', NEW.`perm_ot_add`, 'perm_ot_edit', NEW.`perm_ot_edit`, 'perm_ot_delete', NEW.`perm_ot_delete`, 'perm_ot_add_detalle', NEW.`perm_ot_add_detalle`, 'perm_ot_generar_reporte', NEW.`perm_ot_generar_reporte`, 'perm_ot_add_herramienta', NEW.`perm_ot_add_herramienta`),
  JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_OBJECT(), IF(NOT (OLD.`id` <=> NEW.`id`), JSON_OBJECT('id', JSON_ARRAY(OLD.`id`, NEW.`id`)), JSON_OBJECT())), IF(NOT (OLD.`nombre_rol` <=> NEW.`nombre_rol`), JSON_OBJECT('nombre_rol', JSON_ARRAY(OLD.`nombre_rol`, NEW.`nombre_rol`)), JSON_OBJECT())), IF(NOT (OLD.`perm_usuarios_view` <=> NEW.`perm_usuarios_view`), JSON_OBJECT('perm_usuarios_view', JSON_ARRAY(OLD.`perm_usuarios_view`, NEW.`perm_usuarios_view`)), JSON_OBJECT())), IF(NOT (OLD.`perm_usuarios_add` <=> NEW.`perm_usuarios_add`), JSON_OBJECT('perm_usuarios_add', JSON_ARRAY(OLD.`perm_usuarios_add`, NEW.`perm_usuarios_add`)), JSON_OBJECT())), IF(NOT (OLD.`perm_usuarios_edit` <=> NEW.`perm_usuarios_edit`), JSON_OBJECT('perm_usuarios_edit', JSON_ARRAY(OLD.`perm_usuarios_edit`, NEW.`perm_usuarios_edit`)), JSON_OBJECT())), IF(NOT (OLD.`perm_usuarios_delete` <=> NEW.`perm_usuarios_delete`), JSON_OBJECT('perm_usuarios_delete', JSON_ARRAY(OLD.`perm_usuarios_delete`, NEW.`perm_usuarios_delete`)), JSON_OBJECT())), IF(NOT (OLD.`perm_herramienta_view` <=> NEW.`perm_herramienta_view`), JSON_OBJECT('perm_herramienta_view', JSON_ARRAY(OLD.`perm_herramienta_view`, NEW.`perm_herramienta_view`)), JSON_OBJECT())), IF(NOT (OLD.`perm_herramienta_add` <=> NEW.`perm_herramienta_add`), JSON_OBJECT('perm_herramienta_add', JSON_ARRAY(OLD.`perm_herramienta_add`, NEW.`perm_herramienta_add`)), JSON_OBJECT())), IF(NOT (OLD.`perm_herramienta_edit` <=> NEW.`perm_herramienta_edit`), JSON_OBJECT('perm_herramienta_edit', JSON_ARRAY(OLD.`perm_herramienta_edit`, NEW.`perm_herramienta_edit`)), JSON_OBJECT())), IF(NOT (OLD.`perm_herramienta_delete` <=> NEW.`perm_herramienta_delete`), JSON_OBJECT('perm_herramienta_delete', JSON_ARRAY(OLD.`perm_herramienta_delete`, NEW.`perm_herramienta_delete`)), JSON_OBJECT())), IF(NOT (OLD.`perm_miembro_view` <=> NEW.`perm_miembro_view`), JSON_OBJECT('perm_miembro_view', JSON_ARRAY(OLD.`perm_miembro_view`, NEW.`perm_miembro_view`)), JSON_OBJECT())), IF(NOT (OLD.`perm_miembro_add` <=> NEW.`perm_miembro_add`), JSON_OBJECT('perm_miembro_add', JSON_ARRAY(OLD.`perm_miembro_add`, NEW.`perm_miembro_add`)), JSON_OBJECT())), IF(NOT (OLD.`perm_miembro_edit` <=> NEW.`perm_miembro_edit`), JSON_OBJECT('perm_miembro_edit', JSON_ARRAY(OLD.`perm_miembro_edit`, NEW.`perm_miembro_edit`)), JSON_OBJECT())), IF(NOT (OLD.`perm_miembro_delete` <=> NEW.`perm_miembro_delete`), JSON_OBJECT('perm_miembro_delete', JSON_ARRAY(OLD.`perm_miembro_delete`, NEW.`perm_miembro_delete`)), JSON_OBJECT())), IF(NOT (OLD.`perm_ot_view` <=> NEW.`perm_ot_view`), JSON_OBJECT('perm_ot_view', JSON_ARRAY(OLD.`perm_ot_view`, NEW.`perm_ot_view`)), JSON_OBJECT())), IF(NOT (OLD.`perm_ot_add` <=> NEW.`perm_ot_add`), JSON_OBJECT('perm_ot_add', JSON_ARRAY(OLD.`perm_ot_add`, NEW.`perm_ot_add`)), JSON_OBJECT())), IF(NOT (OLD.`perm_ot_edit` <=> NEW.`perm_ot_edit`), JSON_OBJECT('perm_ot_edit', JSON_ARRAY(OLD.`perm_ot_edit`, NEW.`perm_ot_edit`)), JSON_OBJECT())), IF(NOT (OLD.`perm_ot_delete` <=> NEW.`perm_ot_delete`), JSON_OBJECT('perm_ot_delete', JSON_ARRAY(OLD.`perm_ot_delete`, NEW.`perm_ot_delete`)), JSON_OBJECT())), IF(NOT (OLD.`perm_ot_add_detalle` <=> NEW.`perm_ot_add_detalle`), JSON_OBJECT('perm_ot_add_detalle', JSON_ARRAY(OLD.`perm_ot_add_detalle`, NEW.`perm_ot_add_detalle`)), JSON_OBJECT())), IF(NOT (OLD.`perm_ot_generar_reporte` <=> NEW.`perm_ot_generar_reporte`), JSON_OBJECT('perm_ot_generar_reporte', JSON_ARRAY(OLD.`perm_ot_generar_reporte`, NEW.`perm_ot_generar_reporte`)), JSON_OBJECT())), IF(NOT (OLD.`perm_ot_add_herramienta` <=> NEW.`perm_ot_add_herramienta`), JSON_OBJECT('perm_ot_add_herramienta', JSON_ARRAY(OLD.`perm_ot_add_herramienta`, NEW.`perm_ot_add_herramienta`)), JSON_OBJECT())),
  NULLIF(CONCAT_WS(',', IF(NOT (OLD.`id` <=> NEW.`id`), 'id', NULL), IF(NOT (OLD.`nombre_rol` <=> NEW.`nombre_rol`), 'nombre_rol', NULL), IF(NOT (OLD.`perm_usuarios_view` <=> NEW.`perm_usuarios_view`), 'perm_usuarios_view', NULL), IF(NOT (OLD.`perm_usuarios_add` <=> NEW.`perm_usuarios_add`), 'perm_usuarios_add', NULL), IF(NOT (OLD.`perm_usuarios_edit` <=> NEW.`perm_usuarios_edit`), 'perm_usuarios_edit', NULL), IF(NOT (OLD.`perm_usuarios_delete` <=> NEW.`perm_usuarios_delete`), 'perm_usuarios_delete', NULL), IF(NOT (OLD.`perm_herramienta_view` <=> NEW.`perm_herramienta_view`), 'perm_herramienta_view', NULL), IF(NOT (OLD.`perm_herramienta_add` <=> NEW.`perm_herramienta_add`), 'perm_herramienta_add', NULL), IF(NOT (OLD.`perm_herramienta_edit` <=> NEW.`perm_herramienta_edit`), 'perm_herramienta_edit', NULL), IF(NOT (OLD.`perm_herramienta_delete` <=> NEW.`perm_herramienta_delete`), 'perm_herramienta_delete', NULL), IF(NOT (OLD.`perm_miembro_view` <=> NEW.`perm_miembro_view`), 'perm_miembro_view', NULL), IF(NOT (OLD.`perm_miembro_add` <=> NEW.`perm_miembro_add`), 'perm_miembro_add', NULL), IF(NOT (OLD.`perm_miembro_edit` <=> NEW.`perm_miembro_edit`), 'perm_miembro_edit', NULL), IF(NOT (OLD.`perm_miembro_delete` <=> NEW.`perm_miembro_delete`), 'perm_miembro_delete', NULL), IF(NOT (OLD.`perm_ot_view` <=> NEW.`perm_ot_view`), 'perm_ot_view', NULL), IF(NOT (OLD.`perm_ot_add` <=> NEW.`perm_ot_add`), 'perm_ot_add', NULL), IF(NOT (OLD.`perm_ot_edit` <=> NEW.`perm_ot_edit`), 'perm_ot_edit', NULL), IF(NOT (OLD.`perm_ot_delete` <=> NEW.`perm_ot_delete`), 'perm_ot_delete', NULL), IF(NOT (OLD.`perm_ot_add_detalle` <=> NEW.`perm_ot_add_detalle`), 'perm_ot_add_detalle', NULL), IF(NOT (OLD.`perm_ot_generar_reporte` <=> NEW.`perm_ot_generar_reporte`), 'perm_ot_generar_reporte', NULL), IF(NOT (OLD.`perm_ot_add_herramienta` <=> NEW.`perm_ot_add_herramienta`), 'perm_ot_add_herramienta', NULL)), ''),
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)
$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- Bloque 5. Indices y clave primaria
-- declara la clave primaria e indices auxiliares requeridos para consultas, unicidad y rendimiento de `roles_permisos`.
-- -----------------------------------------------------------------------------
ALTER TABLE `roles_permisos`
  ADD PRIMARY KEY (`id`);

-- -----------------------------------------------------------------------------
-- Bloque 6. Configuracion autoincremental
-- habilita el comportamiento AUTO_INCREMENT definido para `roles_permisos` dentro de la base actual.
-- -----------------------------------------------------------------------------
ALTER TABLE `roles_permisos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable', AUTO_INCREMENT=20;


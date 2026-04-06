-- Modulo: Scripts_ddl
-- Archivo: usuario_sistema.sql
-- Funcion: define las credenciales y banderas de seguridad de los usuarios del sistema y su vista consolidada.
-- Version: v_1.0

-- ============================================================================
-- Base de datos operativa
-- ============================================================================
CREATE DATABASE IF NOT EXISTS `bdapp_metro` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `bdapp_metro`;

-- -----------------------------------------------------------------------------
-- Bloque 1. Reinicio controlado y creacion de la tabla
-- elimina `user_system` si ya existe y la vuelve a crear con `IF NOT EXISTS` usando la definicion consolidada del esquema.
-- -----------------------------------------------------------------------------
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS `user_system`;
CREATE TABLE IF NOT EXISTS `user_system` (
  `id_ai_user` int(11) NOT NULL COMMENT 'id autoincrementable',
  `id_empleado` varchar(30) NOT NULL COMMENT 'Identificador del empleado asociado al usuario del sistema',
  `username` varchar(50) NOT NULL COMMENT 'Nombre de usuario utilizado para iniciar sesion',
  `password` varchar(60) NOT NULL COMMENT 'Contrasena encriptada del usuario',
  `failed_login_attempts` smallint(5) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Intentos fallidos consecutivos de login',
  `account_locked` tinyint(1) NOT NULL DEFAULT 0 COMMENT '1=cuenta bloqueada por seguridad',
  `locked_at` datetime DEFAULT NULL COMMENT 'Fecha/hora de bloqueo de la cuenta',
  `password_reset_required` tinyint(1) NOT NULL DEFAULT 0 COMMENT '1=debe recuperar clave para desbloquear',
  `last_login_at` datetime DEFAULT NULL COMMENT 'Ultimo inicio de sesion exitoso',
  `last_login_ip` varchar(45) DEFAULT NULL COMMENT 'IP del ultimo inicio de sesion exitoso',
  `tipo` int(11) NOT NULL COMMENT 'Rol o perfil de permisos asociado al usuario',
  `std_reg` tinyint(1) NOT NULL COMMENT 'Estado logico del registro (1=activo, 0=inactivo/eliminado logico).'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
SET FOREIGN_KEY_CHECKS = 1;

-- -----------------------------------------------------------------------------
-- Bloque 2. Disparador asociado
-- el disparador `trg_user_system_ai` registra la auditoria asociada a la insercion en `user_system` despues de ejecutarse la operacion.
-- -----------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER `trg_user_system_ai` AFTER INSERT ON `user_system` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
  'user_system',
  'INSERT',
  CONCAT('id_empleado=', NEW.`id_empleado`),
  JSON_OBJECT('id_empleado', NEW.`id_empleado`),
  CONCAT('CREAR ', 'user_system'),
  CONCAT('INSERT user_system ', CONCAT('id_empleado=', NEW.`id_empleado`)),
  NULL,
  JSON_OBJECT('id_ai_user', NEW.`id_ai_user`, 'id_empleado', NEW.`id_empleado`, 'username', NEW.`username`, 'password', '***', 'tipo', NEW.`tipo`, 'std_reg', NEW.`std_reg`),
  JSON_OBJECT('id_ai_user', NEW.`id_ai_user`, 'id_empleado', NEW.`id_empleado`, 'username', NEW.`username`, 'password', '***', 'tipo', NEW.`tipo`, 'std_reg', NEW.`std_reg`),
  'id_ai_user,id_empleado,username,password,tipo,std_reg',
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)
$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- Bloque 3. Disparador asociado
-- el disparador `trg_user_system_au` registra la auditoria asociada a la actualizacion en `user_system` despues de ejecutarse la operacion.
-- -----------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER `trg_user_system_au` AFTER UPDATE ON `user_system` FOR EACH ROW INSERT INTO `log_user`(
  `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
  `accion`,`resp_system`,
  `data_old`,`data_new`,`data_diff`,`changed_cols`,
  `connection_id`,`db_user`,`db_host`
) VALUES (
  UUID(),
  (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
  'user_system',
  CASE WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN 'SOFT_DELETE' WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN 'RESTORE' ELSE 'UPDATE' END,
  CONCAT('id_empleado=', NEW.`id_empleado`),
  JSON_OBJECT('id_empleado', NEW.`id_empleado`),
  CASE WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN CONCAT('ELIMINAR (LOGICO) ', 'user_system') WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN CONCAT('REACTIVAR ', 'user_system') ELSE CONCAT('MODIFICAR ', 'user_system') END,
  CASE WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN CONCAT('SOFT_DELETE user_system ', CONCAT('id_empleado=', NEW.`id_empleado`)) WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN CONCAT('RESTORE user_system ', CONCAT('id_empleado=', NEW.`id_empleado`)) ELSE CONCAT('UPDATE user_system ', CONCAT('id_empleado=', NEW.`id_empleado`)) END,
  JSON_OBJECT('id_ai_user', OLD.`id_ai_user`, 'id_empleado', OLD.`id_empleado`, 'username', OLD.`username`, 'password', '***', 'tipo', OLD.`tipo`, 'std_reg', OLD.`std_reg`),
  JSON_OBJECT('id_ai_user', NEW.`id_ai_user`, 'id_empleado', NEW.`id_empleado`, 'username', NEW.`username`, 'password', '***', 'tipo', NEW.`tipo`, 'std_reg', NEW.`std_reg`),
  JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_MERGE_PATCH(JSON_OBJECT(), IF(NOT (OLD.`id_ai_user` <=> NEW.`id_ai_user`), JSON_OBJECT('id_ai_user', JSON_ARRAY(OLD.`id_ai_user`, NEW.`id_ai_user`)), JSON_OBJECT())), IF(NOT (OLD.`id_empleado` <=> NEW.`id_empleado`), JSON_OBJECT('id_empleado', JSON_ARRAY(OLD.`id_empleado`, NEW.`id_empleado`)), JSON_OBJECT())), IF(NOT (OLD.`username` <=> NEW.`username`), JSON_OBJECT('username', JSON_ARRAY(OLD.`username`, NEW.`username`)), JSON_OBJECT())), IF(NOT (OLD.`password` <=> NEW.`password`), JSON_OBJECT('password', 'CHANGED'), JSON_OBJECT())), IF(NOT (OLD.`tipo` <=> NEW.`tipo`), JSON_OBJECT('tipo', JSON_ARRAY(OLD.`tipo`, NEW.`tipo`)), JSON_OBJECT())), IF(NOT (OLD.`std_reg` <=> NEW.`std_reg`), JSON_OBJECT('std_reg', JSON_ARRAY(OLD.`std_reg`, NEW.`std_reg`)), JSON_OBJECT())),
  NULLIF(CONCAT_WS(',', IF(NOT (OLD.`id_ai_user` <=> NEW.`id_ai_user`), 'id_ai_user', NULL), IF(NOT (OLD.`id_empleado` <=> NEW.`id_empleado`), 'id_empleado', NULL), IF(NOT (OLD.`username` <=> NEW.`username`), 'username', NULL), IF(NOT (OLD.`password` <=> NEW.`password`), 'password', NULL), IF(NOT (OLD.`tipo` <=> NEW.`tipo`), 'tipo', NULL), IF(NOT (OLD.`std_reg` <=> NEW.`std_reg`), 'std_reg', NULL)), ''),
  CONNECTION_ID(),
  USER(),
  SUBSTRING_INDEX(USER(),'@',-1)
)
$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- Bloque 4. Disparador asociado
-- el disparador `trg_user_system_bd` valida o bloquea la eliminacion en `user_system` antes de aplicar el cambio definitivo.
-- -----------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER `trg_user_system_bd` BEFORE DELETE ON `user_system` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE fisico en user_system. Use eliminacion logica (UPDATE user_system SET std_reg=0 ...).'
$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- Bloque 5. Indices y clave primaria
-- declara la clave primaria e indices auxiliares requeridos para consultas, unicidad y rendimiento de `user_system`.
-- -----------------------------------------------------------------------------
ALTER TABLE `user_system`
  ADD PRIMARY KEY (`id_ai_user`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `uk_user_system_id_empleado` (`id_empleado`),
  ADD KEY `tipo` (`tipo`),
  ADD KEY `idx_user_system_login_lock` (`username`,`account_locked`,`password_reset_required`);

-- -----------------------------------------------------------------------------
-- Bloque 6. Configuracion autoincremental
-- habilita el comportamiento AUTO_INCREMENT definido para `user_system` dentro de la base actual.
-- -----------------------------------------------------------------------------
ALTER TABLE `user_system`
  MODIFY `id_ai_user` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable', AUTO_INCREMENT=5;

-- -----------------------------------------------------------------------------
-- Bloque 7. Claves foraneas
-- establece las relaciones referenciales que conectan `user_system` con otras tablas del esquema correspondiente.
-- -----------------------------------------------------------------------------
ALTER TABLE `user_system`
  ADD CONSTRAINT `fk_user_system_empleado` FOREIGN KEY (`id_empleado`) REFERENCES `empleado` (`id_empleado`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_user_system_roles` FOREIGN KEY (`tipo`) REFERENCES `roles_permisos` (`id`),
  ADD CONSTRAINT `user_system_ibfk_1` FOREIGN KEY (`tipo`) REFERENCES `roles_permisos` (`id`) ON UPDATE CASCADE;

-- -----------------------------------------------------------------------------
-- Bloque de vista asociada
-- consolida el usuario del sistema con los datos maestros del empleado asociado.
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS `vw_usuario_empleado`;
DROP TABLE IF EXISTS `vw_usuario_empleado`;

CREATE ALGORITHM=UNDEFINED DEFINER=CURRENT_USER SQL SECURITY INVOKER VIEW `vw_usuario_empleado`  AS SELECT `us`.`id_ai_user` AS `id_ai_user`, `us`.`id_empleado` AS `id_empleado`, `us`.`username` AS `username`, `us`.`tipo` AS `id_rol`, `rp`.`nombre_rol` AS `nombre_rol`, `us`.`failed_login_attempts` AS `failed_login_attempts`, `us`.`account_locked` AS `account_locked`, `us`.`locked_at` AS `locked_at`, `us`.`password_reset_required` AS `password_reset_required`, `us`.`last_login_at` AS `last_login_at`, `us`.`last_login_ip` AS `last_login_ip`, `us`.`std_reg` AS `std_reg`, `emp`.`nacionalidad` AS `nacionalidad`, `emp`.`nombre_empleado` AS `nombre_empleado`, `emp`.`telefono` AS `telefono`, `emp`.`correo` AS `correo`, `emp`.`direccion` AS `direccion`, `emp`.`id_ai_categoria_empleado` AS `id_ai_categoria_empleado`, `ce`.`nombre_categoria` AS `categoria_empleado` FROM (((`user_system` `us` left join `empleado` `emp` on(`emp`.`id_empleado` = `us`.`id_empleado`)) left join `categoria_empleado` `ce` on(`ce`.`id_ai_categoria_empleado` = `emp`.`id_ai_categoria_empleado`)) left join `roles_permisos` `rp` on(`rp`.`id` = `us`.`tipo`)) ;


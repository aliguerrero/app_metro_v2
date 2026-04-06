-- Modulo: Scripts_ddl
-- Archivo: categoria_herramienta.sql
-- Funcion: define las categorias utilizadas para clasificar herramientas.
-- Version: v_1.0

-- ============================================================================
-- Base de datos operativa
-- ============================================================================
CREATE DATABASE IF NOT EXISTS `bdapp_metro` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `bdapp_metro`;

-- -----------------------------------------------------------------------------
-- Bloque 1. Reinicio controlado y creacion de la tabla
-- elimina `categoria_herramienta` si ya existe y la vuelve a crear con `IF NOT EXISTS` usando la definicion consolidada del esquema.
-- -----------------------------------------------------------------------------
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS `categoria_herramienta`;
CREATE TABLE IF NOT EXISTS `categoria_herramienta` (
  `id_ai_categoria_herramienta` int(10) UNSIGNED NOT NULL COMMENT 'Id autoincrementable de la categoria de herramienta',
  `nombre_categoria` varchar(100) NOT NULL COMMENT 'Nombre de la categoria de la herramienta',
  `descripcion` varchar(255) DEFAULT NULL COMMENT 'Descripcion breve de la categoria de herramienta',
  `std_reg` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Estado logico del registro (1=activo, 0=inactivo).'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
SET FOREIGN_KEY_CHECKS = 1;

-- -----------------------------------------------------------------------------
-- Bloque 2. Disparador asociado
-- el disparador `trg_categoria_herramienta_ai` registra la auditoria asociada a la insercion en `categoria_herramienta` despues de ejecutarse la operacion.
-- -----------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER `trg_categoria_herramienta_ai` AFTER INSERT ON `categoria_herramienta` FOR EACH ROW INSERT INTO `log_user`(
    `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
    `accion`,`resp_system`,`data_old`,`data_new`,`data_diff`,`changed_cols`,
    `connection_id`,`db_user`,`db_host`
) VALUES (
    UUID(),
    (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
    'categoria_herramienta',
    'INSERT',
    CONCAT('id_ai_categoria_herramienta=', NEW.`id_ai_categoria_herramienta`),
    JSON_OBJECT('id_ai_categoria_herramienta', NEW.`id_ai_categoria_herramienta`),
    'CREAR categoria_herramienta',
    CONCAT('INSERT categoria_herramienta ', CONCAT('id_ai_categoria_herramienta=', NEW.`id_ai_categoria_herramienta`)),
    NULL,
    JSON_OBJECT(
        'id_ai_categoria_herramienta', NEW.`id_ai_categoria_herramienta`,
        'nombre_categoria', NEW.`nombre_categoria`,
        'descripcion', NEW.`descripcion`,
        'std_reg', NEW.`std_reg`
    ),
    JSON_OBJECT(
        'id_ai_categoria_herramienta', NEW.`id_ai_categoria_herramienta`,
        'nombre_categoria', NEW.`nombre_categoria`,
        'descripcion', NEW.`descripcion`,
        'std_reg', NEW.`std_reg`
    ),
    'id_ai_categoria_herramienta,nombre_categoria,descripcion,std_reg',
    CONNECTION_ID(),
    USER(),
    SUBSTRING_INDEX(USER(),'@',-1)
)
$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- Bloque 3. Disparador asociado
-- el disparador `trg_categoria_herramienta_au` registra la auditoria asociada a la actualizacion en `categoria_herramienta` despues de ejecutarse la operacion.
-- -----------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER `trg_categoria_herramienta_au` AFTER UPDATE ON `categoria_herramienta` FOR EACH ROW INSERT INTO `log_user`(
    `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
    `accion`,`resp_system`,`data_old`,`data_new`,`data_diff`,`changed_cols`,
    `connection_id`,`db_user`,`db_host`
) VALUES (
    UUID(),
    (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
    'categoria_herramienta',
    CASE
        WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN 'SOFT_DELETE'
        WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN 'RESTORE'
        ELSE 'UPDATE'
    END,
    CONCAT('id_ai_categoria_herramienta=', NEW.`id_ai_categoria_herramienta`),
    JSON_OBJECT('id_ai_categoria_herramienta', NEW.`id_ai_categoria_herramienta`),
    CASE
        WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN 'ELIMINAR (LOGICO) categoria_herramienta'
        WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN 'REACTIVAR categoria_herramienta'
        ELSE 'MODIFICAR categoria_herramienta'
    END,
    CASE
        WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN CONCAT('SOFT_DELETE categoria_herramienta ', CONCAT('id_ai_categoria_herramienta=', NEW.`id_ai_categoria_herramienta`))
        WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN CONCAT('RESTORE categoria_herramienta ', CONCAT('id_ai_categoria_herramienta=', NEW.`id_ai_categoria_herramienta`))
        ELSE CONCAT('UPDATE categoria_herramienta ', CONCAT('id_ai_categoria_herramienta=', NEW.`id_ai_categoria_herramienta`))
    END,
    JSON_OBJECT(
        'id_ai_categoria_herramienta', OLD.`id_ai_categoria_herramienta`,
        'nombre_categoria', OLD.`nombre_categoria`,
        'descripcion', OLD.`descripcion`,
        'std_reg', OLD.`std_reg`
    ),
    JSON_OBJECT(
        'id_ai_categoria_herramienta', NEW.`id_ai_categoria_herramienta`,
        'nombre_categoria', NEW.`nombre_categoria`,
        'descripcion', NEW.`descripcion`,
        'std_reg', NEW.`std_reg`
    ),
    JSON_OBJECT(
        'changed_cols', NULLIF(CONCAT_WS(',',
            IF(NOT (OLD.`id_ai_categoria_herramienta` <=> NEW.`id_ai_categoria_herramienta`), 'id_ai_categoria_herramienta', NULL),
            IF(NOT (OLD.`nombre_categoria` <=> NEW.`nombre_categoria`), 'nombre_categoria', NULL),
            IF(NOT (OLD.`descripcion` <=> NEW.`descripcion`), 'descripcion', NULL),
            IF(NOT (OLD.`std_reg` <=> NEW.`std_reg`), 'std_reg', NULL)
        ), '')
    ),
    NULLIF(CONCAT_WS(',',
        IF(NOT (OLD.`id_ai_categoria_herramienta` <=> NEW.`id_ai_categoria_herramienta`), 'id_ai_categoria_herramienta', NULL),
        IF(NOT (OLD.`nombre_categoria` <=> NEW.`nombre_categoria`), 'nombre_categoria', NULL),
        IF(NOT (OLD.`descripcion` <=> NEW.`descripcion`), 'descripcion', NULL),
        IF(NOT (OLD.`std_reg` <=> NEW.`std_reg`), 'std_reg', NULL)
    ), ''),
    CONNECTION_ID(),
    USER(),
    SUBSTRING_INDEX(USER(),'@',-1)
)
$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- Bloque 4. Disparador asociado
-- el disparador `trg_categoria_herramienta_bd` valida o bloquea la eliminacion en `categoria_herramienta` antes de aplicar el cambio definitivo.
-- -----------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER `trg_categoria_herramienta_bd` BEFORE DELETE ON `categoria_herramienta` FOR EACH ROW SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'No se permite DELETE fisico en categoria_herramienta. Use eliminacion logica (UPDATE categoria_herramienta SET std_reg=0 ...).'
$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- Bloque 5. Indices y clave primaria
-- declara la clave primaria e indices auxiliares requeridos para consultas, unicidad y rendimiento de `categoria_herramienta`.
-- -----------------------------------------------------------------------------
ALTER TABLE `categoria_herramienta`
  ADD PRIMARY KEY (`id_ai_categoria_herramienta`),
  ADD KEY `idx_categoria_herramienta_nombre` (`nombre_categoria`),
  ADD KEY `idx_categoria_herramienta_std_reg` (`std_reg`);

-- -----------------------------------------------------------------------------
-- Bloque 6. Configuracion autoincremental
-- habilita el comportamiento AUTO_INCREMENT definido para `categoria_herramienta` dentro de la base actual.
-- -----------------------------------------------------------------------------
ALTER TABLE `categoria_herramienta`
  MODIFY `id_ai_categoria_herramienta` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Id autoincrementable de la categoria de herramienta', AUTO_INCREMENT=6;


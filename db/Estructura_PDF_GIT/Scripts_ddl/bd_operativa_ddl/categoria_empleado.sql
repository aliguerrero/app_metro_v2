-- Modulo: Scripts_ddl
-- Archivo: categoria_empleado.sql
-- Funcion: define las categorias disponibles para los empleados del sistema.
-- Version: v_1.0

-- ============================================================================
-- Base de datos operativa
-- ============================================================================
CREATE DATABASE IF NOT EXISTS `bdapp_metro` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `bdapp_metro`;

-- -----------------------------------------------------------------------------
-- Bloque 1. Reinicio controlado y creacion de la tabla
-- elimina `categoria_empleado` si ya existe y la vuelve a crear con `IF NOT EXISTS` usando la definicion consolidada del esquema.
-- -----------------------------------------------------------------------------
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS `categoria_empleado`;
CREATE TABLE IF NOT EXISTS `categoria_empleado` (
  `id_ai_categoria_empleado` int(11) NOT NULL COMMENT 'id autoincrementable',
  `nombre_categoria` varchar(100) NOT NULL COMMENT 'Nombre de la categoria del empleado',
  `descripcion` varchar(255) DEFAULT NULL COMMENT 'Descripcion breve de la categoria',
  `std_reg` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Estado logico del registro (1=activo, 0=inactivo).'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
SET FOREIGN_KEY_CHECKS = 1;

-- -----------------------------------------------------------------------------
-- Bloque 2. Disparador asociado
-- el disparador `trg_categoria_empleado_ai` registra la auditoria asociada a la insercion en `categoria_empleado` despues de ejecutarse la operacion.
-- -----------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER `trg_categoria_empleado_ai` AFTER INSERT ON `categoria_empleado` FOR EACH ROW INSERT INTO `log_user`(
    `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
    `accion`,`resp_system`,`data_old`,`data_new`,`data_diff`,`changed_cols`,
    `connection_id`,`db_user`,`db_host`
) VALUES (
    UUID(),
    (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
    'categoria_empleado',
    'INSERT',
    CONCAT('id_ai_categoria_empleado=', NEW.`id_ai_categoria_empleado`),
    JSON_OBJECT('id_ai_categoria_empleado', NEW.`id_ai_categoria_empleado`),
    'CREAR categoria_empleado',
    CONCAT('INSERT categoria_empleado ', CONCAT('id_ai_categoria_empleado=', NEW.`id_ai_categoria_empleado`)),
    NULL,
    JSON_OBJECT(
        'id_ai_categoria_empleado', NEW.`id_ai_categoria_empleado`,
        'nombre_categoria', NEW.`nombre_categoria`,
        'descripcion', NEW.`descripcion`,
        'std_reg', NEW.`std_reg`
    ),
    JSON_OBJECT(
        'id_ai_categoria_empleado', NEW.`id_ai_categoria_empleado`,
        'nombre_categoria', NEW.`nombre_categoria`,
        'descripcion', NEW.`descripcion`,
        'std_reg', NEW.`std_reg`
    ),
    'id_ai_categoria_empleado,nombre_categoria,descripcion,std_reg',
    CONNECTION_ID(),
    USER(),
    SUBSTRING_INDEX(USER(),'@',-1)
)
$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- Bloque 3. Disparador asociado
-- el disparador `trg_categoria_empleado_au` registra la auditoria asociada a la actualizacion en `categoria_empleado` despues de ejecutarse la operacion.
-- -----------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER `trg_categoria_empleado_au` AFTER UPDATE ON `categoria_empleado` FOR EACH ROW INSERT INTO `log_user`(
    `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
    `accion`,`resp_system`,`data_old`,`data_new`,`data_diff`,`changed_cols`,
    `connection_id`,`db_user`,`db_host`
) VALUES (
    UUID(),
    (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
    'categoria_empleado',
    CASE
        WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN 'SOFT_DELETE'
        WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN 'RESTORE'
        ELSE 'UPDATE'
    END,
    CONCAT('id_ai_categoria_empleado=', NEW.`id_ai_categoria_empleado`),
    JSON_OBJECT('id_ai_categoria_empleado', NEW.`id_ai_categoria_empleado`),
    CASE
        WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN 'ELIMINAR (LOGICO) categoria_empleado'
        WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN 'REACTIVAR categoria_empleado'
        ELSE 'MODIFICAR categoria_empleado'
    END,
    CASE
        WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN CONCAT('SOFT_DELETE categoria_empleado ', CONCAT('id_ai_categoria_empleado=', NEW.`id_ai_categoria_empleado`))
        WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN CONCAT('RESTORE categoria_empleado ', CONCAT('id_ai_categoria_empleado=', NEW.`id_ai_categoria_empleado`))
        ELSE CONCAT('UPDATE categoria_empleado ', CONCAT('id_ai_categoria_empleado=', NEW.`id_ai_categoria_empleado`))
    END,
    JSON_OBJECT(
        'id_ai_categoria_empleado', OLD.`id_ai_categoria_empleado`,
        'nombre_categoria', OLD.`nombre_categoria`,
        'descripcion', OLD.`descripcion`,
        'std_reg', OLD.`std_reg`
    ),
    JSON_OBJECT(
        'id_ai_categoria_empleado', NEW.`id_ai_categoria_empleado`,
        'nombre_categoria', NEW.`nombre_categoria`,
        'descripcion', NEW.`descripcion`,
        'std_reg', NEW.`std_reg`
    ),
    JSON_OBJECT(
        'changed_cols', NULLIF(CONCAT_WS(',',
            IF(NOT (OLD.`id_ai_categoria_empleado` <=> NEW.`id_ai_categoria_empleado`), 'id_ai_categoria_empleado', NULL),
            IF(NOT (OLD.`nombre_categoria` <=> NEW.`nombre_categoria`), 'nombre_categoria', NULL),
            IF(NOT (OLD.`descripcion` <=> NEW.`descripcion`), 'descripcion', NULL),
            IF(NOT (OLD.`std_reg` <=> NEW.`std_reg`), 'std_reg', NULL)
        ), '')
    ),
    NULLIF(CONCAT_WS(',',
        IF(NOT (OLD.`id_ai_categoria_empleado` <=> NEW.`id_ai_categoria_empleado`), 'id_ai_categoria_empleado', NULL),
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
-- el disparador `trg_categoria_empleado_bd` valida o bloquea la eliminacion en `categoria_empleado` antes de aplicar el cambio definitivo.
-- -----------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER `trg_categoria_empleado_bd` BEFORE DELETE ON `categoria_empleado` FOR EACH ROW SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'No se permite DELETE fisico en categoria_empleado. Use eliminacion logica (UPDATE categoria_empleado SET std_reg=0 ...).'
$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- Bloque 5. Indices y clave primaria
-- declara la clave primaria e indices auxiliares requeridos para consultas, unicidad y rendimiento de `categoria_empleado`.
-- -----------------------------------------------------------------------------
ALTER TABLE `categoria_empleado`
  ADD PRIMARY KEY (`id_ai_categoria_empleado`),
  ADD UNIQUE KEY `uk_categoria_empleado_nombre` (`nombre_categoria`);

-- -----------------------------------------------------------------------------
-- Bloque 6. Configuracion autoincremental
-- habilita el comportamiento AUTO_INCREMENT definido para `categoria_empleado` dentro de la base actual.
-- -----------------------------------------------------------------------------
ALTER TABLE `categoria_empleado`
  MODIFY `id_ai_categoria_empleado` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable', AUTO_INCREMENT=6;


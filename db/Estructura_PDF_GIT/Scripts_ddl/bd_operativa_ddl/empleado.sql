-- Modulo: Scripts_ddl
-- Archivo: empleado.sql
-- Funcion: define el maestro de empleados y sus datos de identificacion y contacto.
-- Version: v_1.0

-- ============================================================================
-- Base de datos operativa
-- ============================================================================
CREATE DATABASE IF NOT EXISTS `bdapp_metro` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `bdapp_metro`;

-- -----------------------------------------------------------------------------
-- Bloque 1. Reinicio controlado y creacion de la tabla
-- elimina `empleado` si ya existe y la vuelve a crear con `IF NOT EXISTS` usando la definicion consolidada del esquema.
-- -----------------------------------------------------------------------------
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS `empleado`;
CREATE TABLE IF NOT EXISTS `empleado` (
  `id_ai_empleado` int(11) NOT NULL COMMENT 'id autoincrementable',
  `id_empleado` varchar(30) NOT NULL COMMENT 'Identificador unico del empleado',
  `nacionalidad` char(1) NOT NULL DEFAULT 'V' COMMENT 'Identifica si la cedula es venezolana (V) o extranjera (E).',
  `nombre_empleado` varchar(100) NOT NULL COMMENT 'Nombre completo del empleado',
  `telefono` varchar(20) DEFAULT NULL COMMENT 'Telefono principal del empleado.',
  `direccion` varchar(255) DEFAULT NULL COMMENT 'Direccion de residencia o ubicacion del empleado.',
  `correo` varchar(120) NOT NULL COMMENT 'Correo electronico del empleado.',
  `id_ai_categoria_empleado` int(11) NOT NULL COMMENT 'Categoria asociada al empleado',
  `std_reg` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Estado logico del registro (1=activo, 0=inactivo).'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
SET FOREIGN_KEY_CHECKS = 1;

-- -----------------------------------------------------------------------------
-- Bloque 2. Disparador asociado
-- el disparador `trg_empleado_ai` registra la auditoria asociada a la insercion en `empleado` despues de ejecutarse la operacion.
-- -----------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER `trg_empleado_ai` AFTER INSERT ON `empleado` FOR EACH ROW INSERT INTO `log_user`(
    `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
    `accion`,`resp_system`,`data_old`,`data_new`,`data_diff`,`changed_cols`,
    `connection_id`,`db_user`,`db_host`
) VALUES (
    UUID(),
    (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
    'empleado',
    'INSERT',
    CONCAT('id_ai_empleado=', NEW.`id_ai_empleado`),
    JSON_OBJECT('id_ai_empleado', NEW.`id_ai_empleado`),
    'CREAR empleado',
    CONCAT('INSERT empleado ', CONCAT('id_ai_empleado=', NEW.`id_ai_empleado`)),
    NULL,
    JSON_OBJECT(
        'id_ai_empleado', NEW.`id_ai_empleado`,
        'id_empleado', NEW.`id_empleado`,
        'nacionalidad', NEW.`nacionalidad`,
        'nombre_empleado', NEW.`nombre_empleado`,
        'telefono', NEW.`telefono`,
        'direccion', NEW.`direccion`,
        'correo', NEW.`correo`,
        'id_ai_categoria_empleado', NEW.`id_ai_categoria_empleado`,
        'std_reg', NEW.`std_reg`
    ),
    JSON_OBJECT(
        'id_ai_empleado', NEW.`id_ai_empleado`,
        'id_empleado', NEW.`id_empleado`,
        'nacionalidad', NEW.`nacionalidad`,
        'nombre_empleado', NEW.`nombre_empleado`,
        'telefono', NEW.`telefono`,
        'direccion', NEW.`direccion`,
        'correo', NEW.`correo`,
        'id_ai_categoria_empleado', NEW.`id_ai_categoria_empleado`,
        'std_reg', NEW.`std_reg`
    ),
    'id_ai_empleado,id_empleado,nacionalidad,nombre_empleado,telefono,direccion,correo,id_ai_categoria_empleado,std_reg',
    CONNECTION_ID(),
    USER(),
    SUBSTRING_INDEX(USER(),'@',-1)
)
$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- Bloque 3. Disparador asociado
-- el disparador `trg_empleado_au` registra la auditoria asociada a la actualizacion en `empleado` despues de ejecutarse la operacion.
-- -----------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER `trg_empleado_au` AFTER UPDATE ON `empleado` FOR EACH ROW INSERT INTO `log_user`(
    `event_uuid`,`id_user`,`tabla`,`operacion`,`pk_registro`,`pk_json`,
    `accion`,`resp_system`,`data_old`,`data_new`,`data_diff`,`changed_cols`,
    `connection_id`,`db_user`,`db_host`
) VALUES (
    UUID(),
    (SELECT `id_empleado` FROM `user_system` WHERE `id_empleado` = @app_user LIMIT 1),
    'empleado',
    CASE
        WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN 'SOFT_DELETE'
        WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN 'RESTORE'
        ELSE 'UPDATE'
    END,
    CONCAT('id_ai_empleado=', NEW.`id_ai_empleado`),
    JSON_OBJECT('id_ai_empleado', NEW.`id_ai_empleado`),
    CASE
        WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN 'ELIMINAR (LOGICO) empleado'
        WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN 'REACTIVAR empleado'
        ELSE 'MODIFICAR empleado'
    END,
    CASE
        WHEN NEW.`std_reg` = 0 AND OLD.`std_reg` = 1 THEN CONCAT('SOFT_DELETE empleado ', CONCAT('id_ai_empleado=', NEW.`id_ai_empleado`))
        WHEN NEW.`std_reg` = 1 AND OLD.`std_reg` = 0 THEN CONCAT('RESTORE empleado ', CONCAT('id_ai_empleado=', NEW.`id_ai_empleado`))
        ELSE CONCAT('UPDATE empleado ', CONCAT('id_ai_empleado=', NEW.`id_ai_empleado`))
    END,
    JSON_OBJECT(
        'id_ai_empleado', OLD.`id_ai_empleado`,
        'id_empleado', OLD.`id_empleado`,
        'nacionalidad', OLD.`nacionalidad`,
        'nombre_empleado', OLD.`nombre_empleado`,
        'telefono', OLD.`telefono`,
        'direccion', OLD.`direccion`,
        'correo', OLD.`correo`,
        'id_ai_categoria_empleado', OLD.`id_ai_categoria_empleado`,
        'std_reg', OLD.`std_reg`
    ),
    JSON_OBJECT(
        'id_ai_empleado', NEW.`id_ai_empleado`,
        'id_empleado', NEW.`id_empleado`,
        'nacionalidad', NEW.`nacionalidad`,
        'nombre_empleado', NEW.`nombre_empleado`,
        'telefono', NEW.`telefono`,
        'direccion', NEW.`direccion`,
        'correo', NEW.`correo`,
        'id_ai_categoria_empleado', NEW.`id_ai_categoria_empleado`,
        'std_reg', NEW.`std_reg`
    ),
    JSON_OBJECT(
        'changed_cols', NULLIF(CONCAT_WS(',',
            IF(NOT (OLD.`id_ai_empleado` <=> NEW.`id_ai_empleado`), 'id_ai_empleado', NULL),
            IF(NOT (OLD.`id_empleado` <=> NEW.`id_empleado`), 'id_empleado', NULL),
            IF(NOT (OLD.`nacionalidad` <=> NEW.`nacionalidad`), 'nacionalidad', NULL),
            IF(NOT (OLD.`nombre_empleado` <=> NEW.`nombre_empleado`), 'nombre_empleado', NULL),
            IF(NOT (OLD.`telefono` <=> NEW.`telefono`), 'telefono', NULL),
            IF(NOT (OLD.`direccion` <=> NEW.`direccion`), 'direccion', NULL),
            IF(NOT (OLD.`correo` <=> NEW.`correo`), 'correo', NULL),
            IF(NOT (OLD.`id_ai_categoria_empleado` <=> NEW.`id_ai_categoria_empleado`), 'id_ai_categoria_empleado', NULL),
            IF(NOT (OLD.`std_reg` <=> NEW.`std_reg`), 'std_reg', NULL)
        ), '')
    ),
    NULLIF(CONCAT_WS(',',
        IF(NOT (OLD.`id_ai_empleado` <=> NEW.`id_ai_empleado`), 'id_ai_empleado', NULL),
        IF(NOT (OLD.`id_empleado` <=> NEW.`id_empleado`), 'id_empleado', NULL),
        IF(NOT (OLD.`nacionalidad` <=> NEW.`nacionalidad`), 'nacionalidad', NULL),
        IF(NOT (OLD.`nombre_empleado` <=> NEW.`nombre_empleado`), 'nombre_empleado', NULL),
        IF(NOT (OLD.`telefono` <=> NEW.`telefono`), 'telefono', NULL),
        IF(NOT (OLD.`direccion` <=> NEW.`direccion`), 'direccion', NULL),
        IF(NOT (OLD.`correo` <=> NEW.`correo`), 'correo', NULL),
        IF(NOT (OLD.`id_ai_categoria_empleado` <=> NEW.`id_ai_categoria_empleado`), 'id_ai_categoria_empleado', NULL),
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
-- el disparador `trg_empleado_bd` valida o bloquea la eliminacion en `empleado` antes de aplicar el cambio definitivo.
-- -----------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER `trg_empleado_bd` BEFORE DELETE ON `empleado` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE fisico en empleado. Use eliminacion logica (UPDATE empleado SET std_reg=0 ...).'
$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- Bloque 5. Indices y clave primaria
-- declara la clave primaria e indices auxiliares requeridos para consultas, unicidad y rendimiento de `empleado`.
-- -----------------------------------------------------------------------------
ALTER TABLE `empleado`
  ADD PRIMARY KEY (`id_ai_empleado`),
  ADD UNIQUE KEY `uk_empleado_codigo` (`id_empleado`),
  ADD KEY `idx_empleado_categoria` (`id_ai_categoria_empleado`);

-- -----------------------------------------------------------------------------
-- Bloque 6. Configuracion autoincremental
-- habilita el comportamiento AUTO_INCREMENT definido para `empleado` dentro de la base actual.
-- -----------------------------------------------------------------------------
ALTER TABLE `empleado`
  MODIFY `id_ai_empleado` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable', AUTO_INCREMENT=12;

-- -----------------------------------------------------------------------------
-- Bloque 7. Claves foraneas
-- establece las relaciones referenciales que conectan `empleado` con otras tablas del esquema correspondiente.
-- -----------------------------------------------------------------------------
ALTER TABLE `empleado`
  ADD CONSTRAINT `fk_empleado_categoria` FOREIGN KEY (`id_ai_categoria_empleado`) REFERENCES `categoria_empleado` (`id_ai_categoria_empleado`) ON UPDATE CASCADE;


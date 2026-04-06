-- Modulo: Scripts_ddl
-- Archivo: estado_orden_trabajo.sql
-- Funcion: define los estados permitidos para las ordenes de trabajo y sus reglas.
-- Version: v_1.0

-- ============================================================================
-- Base de datos operativa
-- ============================================================================
CREATE DATABASE IF NOT EXISTS `bdapp_metro` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `bdapp_metro`;

-- -----------------------------------------------------------------------------
-- Bloque 1. Reinicio controlado y creacion de la tabla
-- elimina `estado_ot` si ya existe y la vuelve a crear con `IF NOT EXISTS` usando la definicion consolidada del esquema.
-- -----------------------------------------------------------------------------
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS `estado_ot`;
CREATE TABLE IF NOT EXISTS `estado_ot` (
  `id_ai_estado` int(11) NOT NULL COMMENT 'id autoincrementable',
  `nombre_estado` varchar(100) NOT NULL COMMENT 'Nombre descriptivo del estado de la orden de trabajo',
  `color` varchar(15) NOT NULL COMMENT 'Codigo de color asociado al estado para representacion visual',
  `libera_herramientas` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Indica si el estado libera automaticamente las herramientas asociadas a la O.T. (1=si, 0=no).',
  `bloquea_ot` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Indica si el estado bloquea cambios operativos adicionales en la O.T. (1=si, 0=no).',
  `std_reg` tinyint(1) NOT NULL COMMENT 'Estado logico del registro (1=activo, 0=inactivo/eliminado logico).'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
SET FOREIGN_KEY_CHECKS = 1;

-- -----------------------------------------------------------------------------
-- Bloque 2. Disparador asociado
-- el disparador `trg_estado_ot_ai` concentra la logica definida para la insercion sobre `estado_ot` despues de la operacion.
-- -----------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER `trg_estado_ot_ai` AFTER INSERT ON `estado_ot` FOR EACH ROW BEGIN
  INSERT INTO log_user(
    event_uuid, id_user, tabla, operacion, pk_registro, pk_json,
    accion, resp_system,
    data_old, data_new, data_diff, changed_cols,
    connection_id, db_user, db_host
  ) VALUES (
    UUID(),
    (SELECT id_empleado FROM user_system WHERE id_empleado = @app_user LIMIT 1),
    'estado_ot',
    'INSERT',
    CONCAT('id_ai_estado=', NEW.id_ai_estado),
    JSON_OBJECT('id_ai_estado', NEW.id_ai_estado),
    'CREAR estado_ot',
    CONCAT('INSERT estado_ot id_ai_estado=', NEW.id_ai_estado),
    NULL,
    JSON_OBJECT(
      'id_ai_estado', NEW.id_ai_estado,
      'nombre_estado', NEW.nombre_estado,
      'color', NEW.color,
      'libera_herramientas', NEW.libera_herramientas,
      'bloquea_ot', NEW.bloquea_ot,
      'std_reg', NEW.std_reg
    ),
    JSON_OBJECT(
      'id_ai_estado', NEW.id_ai_estado,
      'nombre_estado', NEW.nombre_estado,
      'color', NEW.color,
      'libera_herramientas', NEW.libera_herramientas,
      'bloquea_ot', NEW.bloquea_ot,
      'std_reg', NEW.std_reg
    ),
    'id_ai_estado,nombre_estado,color,libera_herramientas,bloquea_ot,std_reg',
    CONNECTION_ID(),
    USER(),
    SUBSTRING_INDEX(USER(), '@', -1)
  );
END
$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- Bloque 3. Disparador asociado
-- el disparador `trg_estado_ot_au` concentra la logica definida para la actualizacion sobre `estado_ot` despues de la operacion.
-- -----------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER `trg_estado_ot_au` AFTER UPDATE ON `estado_ot` FOR EACH ROW BEGIN
  INSERT INTO log_user(
    event_uuid, id_user, tabla, operacion, pk_registro, pk_json,
    accion, resp_system,
    data_old, data_new, data_diff, changed_cols,
    connection_id, db_user, db_host
  ) VALUES (
    UUID(),
    (SELECT id_empleado FROM user_system WHERE id_empleado = @app_user LIMIT 1),
    'estado_ot',
    CASE
      WHEN NEW.std_reg = 0 AND OLD.std_reg = 1 THEN 'SOFT_DELETE'
      WHEN NEW.std_reg = 1 AND OLD.std_reg = 0 THEN 'RESTORE'
      ELSE 'UPDATE'
    END,
    CONCAT('id_ai_estado=', NEW.id_ai_estado),
    JSON_OBJECT('id_ai_estado', NEW.id_ai_estado),
    CASE
      WHEN NEW.std_reg = 0 AND OLD.std_reg = 1 THEN 'ELIMINAR (LOGICO) estado_ot'
      WHEN NEW.std_reg = 1 AND OLD.std_reg = 0 THEN 'REACTIVAR estado_ot'
      ELSE 'MODIFICAR estado_ot'
    END,
    CASE
      WHEN NEW.std_reg = 0 AND OLD.std_reg = 1 THEN CONCAT('SOFT_DELETE estado_ot id_ai_estado=', NEW.id_ai_estado)
      WHEN NEW.std_reg = 1 AND OLD.std_reg = 0 THEN CONCAT('RESTORE estado_ot id_ai_estado=', NEW.id_ai_estado)
      ELSE CONCAT('UPDATE estado_ot id_ai_estado=', NEW.id_ai_estado)
    END,
    JSON_OBJECT(
      'id_ai_estado', OLD.id_ai_estado,
      'nombre_estado', OLD.nombre_estado,
      'color', OLD.color,
      'libera_herramientas', OLD.libera_herramientas,
      'bloquea_ot', OLD.bloquea_ot,
      'std_reg', OLD.std_reg
    ),
    JSON_OBJECT(
      'id_ai_estado', NEW.id_ai_estado,
      'nombre_estado', NEW.nombre_estado,
      'color', NEW.color,
      'libera_herramientas', NEW.libera_herramientas,
      'bloquea_ot', NEW.bloquea_ot,
      'std_reg', NEW.std_reg
    ),
    JSON_MERGE_PATCH(
      JSON_MERGE_PATCH(
        JSON_MERGE_PATCH(
          JSON_MERGE_PATCH(
            JSON_MERGE_PATCH(
              JSON_OBJECT(),
              IF(NOT (OLD.id_ai_estado <=> NEW.id_ai_estado), JSON_OBJECT('id_ai_estado', JSON_ARRAY(OLD.id_ai_estado, NEW.id_ai_estado)), JSON_OBJECT())
            ),
            IF(NOT (OLD.nombre_estado <=> NEW.nombre_estado), JSON_OBJECT('nombre_estado', JSON_ARRAY(OLD.nombre_estado, NEW.nombre_estado)), JSON_OBJECT())
          ),
          IF(NOT (OLD.color <=> NEW.color), JSON_OBJECT('color', JSON_ARRAY(OLD.color, NEW.color)), JSON_OBJECT())
        ),
        IF(NOT (OLD.libera_herramientas <=> NEW.libera_herramientas), JSON_OBJECT('libera_herramientas', JSON_ARRAY(OLD.libera_herramientas, NEW.libera_herramientas)), JSON_OBJECT())
      ),
      JSON_MERGE_PATCH(
        IF(NOT (OLD.bloquea_ot <=> NEW.bloquea_ot), JSON_OBJECT('bloquea_ot', JSON_ARRAY(OLD.bloquea_ot, NEW.bloquea_ot)), JSON_OBJECT()),
        IF(NOT (OLD.std_reg <=> NEW.std_reg), JSON_OBJECT('std_reg', JSON_ARRAY(OLD.std_reg, NEW.std_reg)), JSON_OBJECT())
      )
    ),
    NULLIF(
      CONCAT_WS(',',
        IF(NOT (OLD.id_ai_estado <=> NEW.id_ai_estado), 'id_ai_estado', NULL),
        IF(NOT (OLD.nombre_estado <=> NEW.nombre_estado), 'nombre_estado', NULL),
        IF(NOT (OLD.color <=> NEW.color), 'color', NULL),
        IF(NOT (OLD.libera_herramientas <=> NEW.libera_herramientas), 'libera_herramientas', NULL),
        IF(NOT (OLD.bloquea_ot <=> NEW.bloquea_ot), 'bloquea_ot', NULL),
        IF(NOT (OLD.std_reg <=> NEW.std_reg), 'std_reg', NULL)
      ),
      ''
    ),
    CONNECTION_ID(),
    USER(),
    SUBSTRING_INDEX(USER(), '@', -1)
  );
END
$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- Bloque 4. Disparador asociado
-- el disparador `trg_estado_ot_bd` valida o bloquea la eliminacion en `estado_ot` antes de aplicar el cambio definitivo.
-- -----------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER `trg_estado_ot_bd` BEFORE DELETE ON `estado_ot` FOR EACH ROW SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'No se permite DELETE fisico en estado_ot. Use eliminacion logica (UPDATE estado_ot SET std_reg=0 ...).'
$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- Bloque 5. Disparador asociado
-- el disparador `trg_estado_ot_bi` valida o bloquea la insercion en `estado_ot` antes de aplicar el cambio definitivo.
-- -----------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER `trg_estado_ot_bi` BEFORE INSERT ON `estado_ot` FOR EACH ROW BEGIN
  IF COALESCE(NEW.bloquea_ot, 0) = 1 THEN
    SET NEW.libera_herramientas = 1;

    IF EXISTS (
      SELECT 1
      FROM estado_ot
      WHERE std_reg = 1
        AND COALESCE(bloquea_ot, 0) = 1
    ) THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Solo puede existir un estado activo configurado para bloquear la O.T.';
    END IF;
  END IF;
END
$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- Bloque 6. Disparador asociado
-- el disparador `trg_estado_ot_bu` valida o bloquea la actualizacion en `estado_ot` antes de aplicar el cambio definitivo.
-- -----------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER `trg_estado_ot_bu` BEFORE UPDATE ON `estado_ot` FOR EACH ROW BEGIN
  IF COALESCE(NEW.bloquea_ot, 0) = 1 THEN
    SET NEW.libera_herramientas = 1;

    IF EXISTS (
      SELECT 1
      FROM estado_ot
      WHERE std_reg = 1
        AND COALESCE(bloquea_ot, 0) = 1
        AND id_ai_estado <> OLD.id_ai_estado
    ) THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Solo puede existir un estado activo configurado para bloquear la O.T.';
    END IF;
  END IF;

  IF COALESCE(OLD.bloquea_ot, 0) = 1
     AND (
       NOT (OLD.nombre_estado <=> NEW.nombre_estado)
       OR NOT (OLD.color <=> NEW.color)
       OR NOT (OLD.libera_herramientas <=> NEW.libera_herramientas)
       OR NOT (OLD.bloquea_ot <=> NEW.bloquea_ot)
       OR NOT (OLD.std_reg <=> NEW.std_reg)
     ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'El estado configurado para bloquear la O.T. es protegido y no puede modificarse ni eliminarse.';
  END IF;
END
$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- Bloque 7. Indices y clave primaria
-- declara la clave primaria e indices auxiliares requeridos para consultas, unicidad y rendimiento de `estado_ot`.
-- -----------------------------------------------------------------------------
ALTER TABLE `estado_ot`
  ADD PRIMARY KEY (`id_ai_estado`),
  ADD KEY `idx_estado_ot_libera_herramientas` (`libera_herramientas`,`std_reg`),
  ADD KEY `idx_estado_ot_bloquea_ot` (`bloquea_ot`,`std_reg`);

-- -----------------------------------------------------------------------------
-- Bloque 8. Configuracion autoincremental
-- habilita el comportamiento AUTO_INCREMENT definido para `estado_ot` dentro de la base actual.
-- -----------------------------------------------------------------------------
ALTER TABLE `estado_ot`
  MODIFY `id_ai_estado` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable', AUTO_INCREMENT=13;


-- Modulo: Scripts_ddl
-- Archivo: detalle_orden.sql
-- Funcion: define el detalle operativo y horario asociado a cada orden de trabajo.
-- Version: v_1.0

-- ============================================================================
-- Base de datos operativa
-- ============================================================================
CREATE DATABASE IF NOT EXISTS `bdapp_metro` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `bdapp_metro`;

-- -----------------------------------------------------------------------------
-- Bloque 1. Reinicio controlado y creacion de la tabla
-- elimina `detalle_orden` si ya existe y la vuelve a crear con `IF NOT EXISTS` usando la definicion consolidada del esquema.
-- -----------------------------------------------------------------------------
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS `detalle_orden`;
CREATE TABLE IF NOT EXISTS `detalle_orden` (
  `id_ai_detalle` int(11) NOT NULL COMMENT 'id autoincrementable',
  `n_ot` varchar(30) NOT NULL COMMENT 'Numero unico de la orden de trabajo',
  `fecha` date NOT NULL COMMENT 'Fecha programada de la orden de trabajo',
  `descripcion` varchar(250) NOT NULL COMMENT 'Descripcion de la actividad o trabajo a realizar',
  `id_ai_turno` int(11) NOT NULL COMMENT 'Identificador unico del turno de trabajo',
  `id_miembro_cco` varchar(10) NOT NULL COMMENT 'Miembro responsable en CCO (Centro de Control de Operaciones)',
  `id_user_act` varchar(30) NOT NULL COMMENT 'Usuario tecnico responsable de ejecutar la actividad',
  `id_miembro_ccf` varchar(10) NOT NULL COMMENT 'Miembro responsable en CCF',
  `cant_tec` int(11) NOT NULL COMMENT 'Cantidad de tecnicos involucrados en la actividad',
  `hora_inicio` time DEFAULT NULL COMMENT 'Hora de inicio del trabajo',
  `hora_fin` time DEFAULT NULL COMMENT 'Hora de fin del trabajo',
  `observacion` varchar(250) DEFAULT NULL COMMENT 'Observaciones adicionales sobre la actividad'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
SET FOREIGN_KEY_CHECKS = 1;

-- -----------------------------------------------------------------------------
-- Bloque 2. Disparador asociado
-- el disparador `trg_detalle_orden_ad` concentra la logica definida para la eliminacion sobre `detalle_orden` despues de la operacion.
-- -----------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER `trg_detalle_orden_ad` AFTER DELETE ON `detalle_orden` FOR EACH ROW BEGIN
  INSERT INTO log_user(
    event_uuid, id_user, tabla, operacion, pk_registro, pk_json,
    accion, resp_system,
    data_old, data_new, data_diff, changed_cols,
    connection_id, db_user, db_host
  ) VALUES (
    UUID(),
    (SELECT id_empleado FROM user_system WHERE id_empleado = @app_user LIMIT 1),
    'detalle_orden',
    'DELETE',
    CONCAT('id_ai_detalle=', OLD.id_ai_detalle),
    JSON_OBJECT('id_ai_detalle', OLD.id_ai_detalle),
    'ELIMINAR detalle_orden',
    CONCAT('DELETE detalle_orden id_ai_detalle=', OLD.id_ai_detalle),
    JSON_OBJECT(
      'id_ai_detalle', OLD.id_ai_detalle,
      'n_ot', OLD.n_ot,
      'fecha', OLD.fecha,
      'descripcion', OLD.descripcion,
      'id_ai_turno', OLD.id_ai_turno,
      'id_miembro_cco', OLD.id_miembro_cco,
      'id_user_act', OLD.id_user_act,
      'id_miembro_ccf', OLD.id_miembro_ccf,
      'cant_tec', OLD.cant_tec,
      'hora_inicio', OLD.hora_inicio,
      'hora_fin', OLD.hora_fin,
      'observacion', OLD.observacion
    ),
    NULL,
    NULL,
    NULL,
    CONNECTION_ID(),
    USER(),
    SUBSTRING_INDEX(USER(), '@', -1)
  );
END
$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- Bloque 3. Disparador asociado
-- el disparador `trg_detalle_orden_ai` concentra la logica definida para la insercion sobre `detalle_orden` despues de la operacion.
-- -----------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER `trg_detalle_orden_ai` AFTER INSERT ON `detalle_orden` FOR EACH ROW BEGIN
  INSERT INTO log_user(
    event_uuid, id_user, tabla, operacion, pk_registro, pk_json,
    accion, resp_system,
    data_old, data_new, data_diff, changed_cols,
    connection_id, db_user, db_host
  ) VALUES (
    UUID(),
    (SELECT id_empleado FROM user_system WHERE id_empleado = @app_user LIMIT 1),
    'detalle_orden',
    'INSERT',
    CONCAT('id_ai_detalle=', NEW.id_ai_detalle),
    JSON_OBJECT('id_ai_detalle', NEW.id_ai_detalle),
    'CREAR detalle_orden',
    CONCAT('INSERT detalle_orden id_ai_detalle=', NEW.id_ai_detalle),
    NULL,
    JSON_OBJECT(
      'id_ai_detalle', NEW.id_ai_detalle,
      'n_ot', NEW.n_ot,
      'fecha', NEW.fecha,
      'descripcion', NEW.descripcion,
      'id_ai_turno', NEW.id_ai_turno,
      'id_miembro_cco', NEW.id_miembro_cco,
      'id_user_act', NEW.id_user_act,
      'id_miembro_ccf', NEW.id_miembro_ccf,
      'cant_tec', NEW.cant_tec,
      'hora_inicio', NEW.hora_inicio,
      'hora_fin', NEW.hora_fin,
      'observacion', NEW.observacion
    ),
    JSON_OBJECT(
      'id_ai_detalle', NEW.id_ai_detalle,
      'n_ot', NEW.n_ot,
      'fecha', NEW.fecha,
      'descripcion', NEW.descripcion,
      'id_ai_turno', NEW.id_ai_turno,
      'id_miembro_cco', NEW.id_miembro_cco,
      'id_user_act', NEW.id_user_act,
      'id_miembro_ccf', NEW.id_miembro_ccf,
      'cant_tec', NEW.cant_tec,
      'hora_inicio', NEW.hora_inicio,
      'hora_fin', NEW.hora_fin,
      'observacion', NEW.observacion
    ),
    'id_ai_detalle,n_ot,fecha,descripcion,id_ai_turno,id_miembro_cco,id_user_act,id_miembro_ccf,cant_tec,hora_inicio,hora_fin,observacion',
    CONNECTION_ID(),
    USER(),
    SUBSTRING_INDEX(USER(), '@', -1)
  );
END
$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- Bloque 4. Disparador asociado
-- el disparador `trg_detalle_orden_au` concentra la logica definida para la actualizacion sobre `detalle_orden` despues de la operacion.
-- -----------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER `trg_detalle_orden_au` AFTER UPDATE ON `detalle_orden` FOR EACH ROW BEGIN
  INSERT INTO log_user(
    event_uuid, id_user, tabla, operacion, pk_registro, pk_json,
    accion, resp_system,
    data_old, data_new, data_diff, changed_cols,
    connection_id, db_user, db_host
  ) VALUES (
    UUID(),
    (SELECT id_empleado FROM user_system WHERE id_empleado = @app_user LIMIT 1),
    'detalle_orden',
    'UPDATE',
    CONCAT('id_ai_detalle=', NEW.id_ai_detalle),
    JSON_OBJECT('id_ai_detalle', NEW.id_ai_detalle),
    'MODIFICAR detalle_orden',
    CONCAT('UPDATE detalle_orden id_ai_detalle=', NEW.id_ai_detalle),
    JSON_OBJECT(
      'id_ai_detalle', OLD.id_ai_detalle,
      'n_ot', OLD.n_ot,
      'fecha', OLD.fecha,
      'descripcion', OLD.descripcion,
      'id_ai_turno', OLD.id_ai_turno,
      'id_miembro_cco', OLD.id_miembro_cco,
      'id_user_act', OLD.id_user_act,
      'id_miembro_ccf', OLD.id_miembro_ccf,
      'cant_tec', OLD.cant_tec,
      'hora_inicio', OLD.hora_inicio,
      'hora_fin', OLD.hora_fin,
      'observacion', OLD.observacion
    ),
    JSON_OBJECT(
      'id_ai_detalle', NEW.id_ai_detalle,
      'n_ot', NEW.n_ot,
      'fecha', NEW.fecha,
      'descripcion', NEW.descripcion,
      'id_ai_turno', NEW.id_ai_turno,
      'id_miembro_cco', NEW.id_miembro_cco,
      'id_user_act', NEW.id_user_act,
      'id_miembro_ccf', NEW.id_miembro_ccf,
      'cant_tec', NEW.cant_tec,
      'hora_inicio', NEW.hora_inicio,
      'hora_fin', NEW.hora_fin,
      'observacion', NEW.observacion
    ),
    JSON_MERGE_PATCH(
      JSON_MERGE_PATCH(
        JSON_MERGE_PATCH(
          JSON_MERGE_PATCH(
            JSON_MERGE_PATCH(
              JSON_MERGE_PATCH(
                JSON_MERGE_PATCH(
                  JSON_MERGE_PATCH(
                    JSON_MERGE_PATCH(
                      JSON_MERGE_PATCH(
                        JSON_MERGE_PATCH(
                          JSON_OBJECT(),
                          IF(NOT (OLD.id_ai_detalle <=> NEW.id_ai_detalle), JSON_OBJECT('id_ai_detalle', JSON_ARRAY(OLD.id_ai_detalle, NEW.id_ai_detalle)), JSON_OBJECT())
                        ),
                        IF(NOT (OLD.n_ot <=> NEW.n_ot), JSON_OBJECT('n_ot', JSON_ARRAY(OLD.n_ot, NEW.n_ot)), JSON_OBJECT())
                      ),
                      IF(NOT (OLD.fecha <=> NEW.fecha), JSON_OBJECT('fecha', JSON_ARRAY(OLD.fecha, NEW.fecha)), JSON_OBJECT())
                    ),
                    IF(NOT (OLD.descripcion <=> NEW.descripcion), JSON_OBJECT('descripcion', JSON_ARRAY(OLD.descripcion, NEW.descripcion)), JSON_OBJECT())
                  ),
                  IF(NOT (OLD.id_ai_turno <=> NEW.id_ai_turno), JSON_OBJECT('id_ai_turno', JSON_ARRAY(OLD.id_ai_turno, NEW.id_ai_turno)), JSON_OBJECT())
                ),
                IF(NOT (OLD.id_miembro_cco <=> NEW.id_miembro_cco), JSON_OBJECT('id_miembro_cco', JSON_ARRAY(OLD.id_miembro_cco, NEW.id_miembro_cco)), JSON_OBJECT())
              ),
              IF(NOT (OLD.id_user_act <=> NEW.id_user_act), JSON_OBJECT('id_user_act', JSON_ARRAY(OLD.id_user_act, NEW.id_user_act)), JSON_OBJECT())
            ),
            IF(NOT (OLD.id_miembro_ccf <=> NEW.id_miembro_ccf), JSON_OBJECT('id_miembro_ccf', JSON_ARRAY(OLD.id_miembro_ccf, NEW.id_miembro_ccf)), JSON_OBJECT())
          ),
          IF(NOT (OLD.cant_tec <=> NEW.cant_tec), JSON_OBJECT('cant_tec', JSON_ARRAY(OLD.cant_tec, NEW.cant_tec)), JSON_OBJECT())
        ),
        IF(NOT (OLD.hora_inicio <=> NEW.hora_inicio), JSON_OBJECT('hora_inicio', JSON_ARRAY(OLD.hora_inicio, NEW.hora_inicio)), JSON_OBJECT())
      ),
      JSON_MERGE_PATCH(
        IF(NOT (OLD.hora_fin <=> NEW.hora_fin), JSON_OBJECT('hora_fin', JSON_ARRAY(OLD.hora_fin, NEW.hora_fin)), JSON_OBJECT()),
        IF(NOT (OLD.observacion <=> NEW.observacion), JSON_OBJECT('observacion', JSON_ARRAY(OLD.observacion, NEW.observacion)), JSON_OBJECT())
      )
    ),
    NULLIF(
      CONCAT_WS(',',
        IF(NOT (OLD.id_ai_detalle <=> NEW.id_ai_detalle), 'id_ai_detalle', NULL),
        IF(NOT (OLD.n_ot <=> NEW.n_ot), 'n_ot', NULL),
        IF(NOT (OLD.fecha <=> NEW.fecha), 'fecha', NULL),
        IF(NOT (OLD.descripcion <=> NEW.descripcion), 'descripcion', NULL),
        IF(NOT (OLD.id_ai_turno <=> NEW.id_ai_turno), 'id_ai_turno', NULL),
        IF(NOT (OLD.id_miembro_cco <=> NEW.id_miembro_cco), 'id_miembro_cco', NULL),
        IF(NOT (OLD.id_user_act <=> NEW.id_user_act), 'id_user_act', NULL),
        IF(NOT (OLD.id_miembro_ccf <=> NEW.id_miembro_ccf), 'id_miembro_ccf', NULL),
        IF(NOT (OLD.cant_tec <=> NEW.cant_tec), 'cant_tec', NULL),
        IF(NOT (OLD.hora_inicio <=> NEW.hora_inicio), 'hora_inicio', NULL),
        IF(NOT (OLD.hora_fin <=> NEW.hora_fin), 'hora_fin', NULL),
        IF(NOT (OLD.observacion <=> NEW.observacion), 'observacion', NULL)
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
-- Bloque 5. Indices y clave primaria
-- declara la clave primaria e indices auxiliares requeridos para consultas, unicidad y rendimiento de `detalle_orden`.
-- -----------------------------------------------------------------------------
ALTER TABLE `detalle_orden`
  ADD PRIMARY KEY (`id_ai_detalle`),
  ADD KEY `responsable_ccf` (`id_miembro_ccf`),
  ADD KEY `responsable_cco` (`id_miembro_cco`),
  ADD KEY `responsable_act` (`id_user_act`),
  ADD KEY `turno` (`id_ai_turno`),
  ADD KEY `n_ot` (`n_ot`),
  ADD KEY `idx_detalle_ot_fecha` (`n_ot`,`fecha`);

-- -----------------------------------------------------------------------------
-- Bloque 6. Configuracion autoincremental
-- habilita el comportamiento AUTO_INCREMENT definido para `detalle_orden` dentro de la base actual.
-- -----------------------------------------------------------------------------
ALTER TABLE `detalle_orden`
  MODIFY `id_ai_detalle` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id autoincrementable', AUTO_INCREMENT=9;

-- -----------------------------------------------------------------------------
-- Bloque 7. Claves foraneas
-- establece las relaciones referenciales que conectan `detalle_orden` con otras tablas del esquema correspondiente.
-- -----------------------------------------------------------------------------
ALTER TABLE `detalle_orden`
  ADD CONSTRAINT `detalle_orden_ibfk_2` FOREIGN KEY (`id_user_act`) REFERENCES `user_system` (`id_empleado`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `detalle_orden_ibfk_3` FOREIGN KEY (`id_miembro_ccf`) REFERENCES `miembro` (`id_miembro`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `detalle_orden_ibfk_4` FOREIGN KEY (`id_miembro_cco`) REFERENCES `miembro` (`id_miembro`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `detalle_orden_ibfk_6` FOREIGN KEY (`id_ai_turno`) REFERENCES `turno_trabajo` (`id_ai_turno`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `detalle_orden_ibfk_7` FOREIGN KEY (`n_ot`) REFERENCES `orden_trabajo` (`n_ot`) ON DELETE CASCADE ON UPDATE CASCADE;


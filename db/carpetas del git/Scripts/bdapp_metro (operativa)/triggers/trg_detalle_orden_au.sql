USE `bdapp_metro`;

DROP TRIGGER IF EXISTS `trg_detalle_orden_au`;
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

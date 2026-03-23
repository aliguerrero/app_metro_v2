USE `bdapp_metro`;

DROP TRIGGER IF EXISTS `trg_detalle_orden_ai`;
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

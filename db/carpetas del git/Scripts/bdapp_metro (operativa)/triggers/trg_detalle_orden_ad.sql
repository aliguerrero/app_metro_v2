USE `bdapp_metro`;

DROP TRIGGER IF EXISTS `trg_detalle_orden_ad`;
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

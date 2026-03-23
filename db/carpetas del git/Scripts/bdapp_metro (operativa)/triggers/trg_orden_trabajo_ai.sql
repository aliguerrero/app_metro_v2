USE `bdapp_metro`;

DROP TRIGGER IF EXISTS `trg_orden_trabajo_ai`;
DELIMITER $$
CREATE TRIGGER `trg_orden_trabajo_ai` AFTER INSERT ON `orden_trabajo` FOR EACH ROW BEGIN
  INSERT INTO log_user(
    event_uuid, id_user, tabla, operacion, pk_registro, pk_json,
    accion, resp_system,
    data_old, data_new, data_diff, changed_cols,
    connection_id, db_user, db_host
  ) VALUES (
    UUID(),
    (SELECT id_empleado FROM user_system WHERE id_empleado = @app_user LIMIT 1),
    'orden_trabajo',
    'INSERT',
    CONCAT('n_ot=', NEW.n_ot),
    JSON_OBJECT('n_ot', NEW.n_ot),
    'CREAR orden_trabajo',
    CONCAT('INSERT orden_trabajo n_ot=', NEW.n_ot),
    NULL,
    JSON_OBJECT(
      'id_ai_ot', NEW.id_ai_ot,
      'n_ot', NEW.n_ot,
      'id_ai_area', NEW.id_ai_area,
      'id_user', NEW.id_user,
      'id_ai_sitio', NEW.id_ai_sitio,
      'id_ai_estado', NEW.id_ai_estado,
      'nombre_trab', NEW.nombre_trab,
      'fecha', NEW.fecha,
      'semana', NEW.semana,
      'mes', NEW.mes,
      'ot_finalizada', NEW.ot_finalizada,
      'fecha_finalizacion', NEW.fecha_finalizacion,
      'id_user_finaliza', NEW.id_user_finaliza,
      'std_reg', NEW.std_reg
    ),
    JSON_OBJECT(
      'id_ai_ot', NEW.id_ai_ot,
      'n_ot', NEW.n_ot,
      'id_ai_area', NEW.id_ai_area,
      'id_user', NEW.id_user,
      'id_ai_sitio', NEW.id_ai_sitio,
      'id_ai_estado', NEW.id_ai_estado,
      'nombre_trab', NEW.nombre_trab,
      'fecha', NEW.fecha,
      'semana', NEW.semana,
      'mes', NEW.mes,
      'ot_finalizada', NEW.ot_finalizada,
      'fecha_finalizacion', NEW.fecha_finalizacion,
      'id_user_finaliza', NEW.id_user_finaliza,
      'std_reg', NEW.std_reg
    ),
    'id_ai_ot,n_ot,id_ai_area,id_user,id_ai_sitio,id_ai_estado,nombre_trab,fecha,semana,mes,ot_finalizada,fecha_finalizacion,id_user_finaliza,std_reg',
    CONNECTION_ID(),
    USER(),
    SUBSTRING_INDEX(USER(), '@', -1)
  );
END
$$
DELIMITER ;

USE `bdapp_metro`;

DROP TRIGGER IF EXISTS `trg_orden_trabajo_au`;
DELIMITER $$
CREATE TRIGGER `trg_orden_trabajo_au` AFTER UPDATE ON `orden_trabajo` FOR EACH ROW BEGIN
  INSERT INTO log_user(
    event_uuid, id_user, tabla, operacion, pk_registro, pk_json,
    accion, resp_system,
    data_old, data_new, data_diff, changed_cols,
    connection_id, db_user, db_host
  ) VALUES (
    UUID(),
    (SELECT id_empleado FROM user_system WHERE id_empleado = @app_user LIMIT 1),
    'orden_trabajo',
    CASE
      WHEN NEW.std_reg = 0 AND OLD.std_reg = 1 THEN 'SOFT_DELETE'
      WHEN NEW.std_reg = 1 AND OLD.std_reg = 0 THEN 'RESTORE'
      ELSE 'UPDATE'
    END,
    CONCAT('n_ot=', NEW.n_ot),
    JSON_OBJECT('n_ot', NEW.n_ot),
    CASE
      WHEN NEW.std_reg = 0 AND OLD.std_reg = 1 THEN 'ELIMINAR (LOGICO) orden_trabajo'
      WHEN NEW.std_reg = 1 AND OLD.std_reg = 0 THEN 'REACTIVAR orden_trabajo'
      ELSE 'MODIFICAR orden_trabajo'
    END,
    CASE
      WHEN NEW.std_reg = 0 AND OLD.std_reg = 1 THEN CONCAT('SOFT_DELETE orden_trabajo n_ot=', NEW.n_ot)
      WHEN NEW.std_reg = 1 AND OLD.std_reg = 0 THEN CONCAT('RESTORE orden_trabajo n_ot=', NEW.n_ot)
      ELSE CONCAT('UPDATE orden_trabajo n_ot=', NEW.n_ot)
    END,
    JSON_OBJECT(
      'id_ai_ot', OLD.id_ai_ot,
      'n_ot', OLD.n_ot,
      'id_ai_area', OLD.id_ai_area,
      'id_user', OLD.id_user,
      'id_ai_sitio', OLD.id_ai_sitio,
      'id_ai_estado', OLD.id_ai_estado,
      'nombre_trab', OLD.nombre_trab,
      'fecha', OLD.fecha,
      'semana', OLD.semana,
      'mes', OLD.mes,
      'ot_finalizada', OLD.ot_finalizada,
      'fecha_finalizacion', OLD.fecha_finalizacion,
      'id_user_finaliza', OLD.id_user_finaliza,
      'std_reg', OLD.std_reg
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
                          JSON_MERGE_PATCH(
                            JSON_MERGE_PATCH(
                              JSON_OBJECT(),
                              IF(NOT (OLD.id_ai_ot <=> NEW.id_ai_ot), JSON_OBJECT('id_ai_ot', JSON_ARRAY(OLD.id_ai_ot, NEW.id_ai_ot)), JSON_OBJECT())
                            ),
                            IF(NOT (OLD.n_ot <=> NEW.n_ot), JSON_OBJECT('n_ot', JSON_ARRAY(OLD.n_ot, NEW.n_ot)), JSON_OBJECT())
                          ),
                          IF(NOT (OLD.id_ai_area <=> NEW.id_ai_area), JSON_OBJECT('id_ai_area', JSON_ARRAY(OLD.id_ai_area, NEW.id_ai_area)), JSON_OBJECT())
                        ),
                        IF(NOT (OLD.id_user <=> NEW.id_user), JSON_OBJECT('id_user', JSON_ARRAY(OLD.id_user, NEW.id_user)), JSON_OBJECT())
                      ),
                      IF(NOT (OLD.id_ai_sitio <=> NEW.id_ai_sitio), JSON_OBJECT('id_ai_sitio', JSON_ARRAY(OLD.id_ai_sitio, NEW.id_ai_sitio)), JSON_OBJECT())
                    ),
                    IF(NOT (OLD.id_ai_estado <=> NEW.id_ai_estado), JSON_OBJECT('id_ai_estado', JSON_ARRAY(OLD.id_ai_estado, NEW.id_ai_estado)), JSON_OBJECT())
                  ),
                  IF(NOT (OLD.nombre_trab <=> NEW.nombre_trab), JSON_OBJECT('nombre_trab', JSON_ARRAY(OLD.nombre_trab, NEW.nombre_trab)), JSON_OBJECT())
                ),
                IF(NOT (OLD.fecha <=> NEW.fecha), JSON_OBJECT('fecha', JSON_ARRAY(OLD.fecha, NEW.fecha)), JSON_OBJECT())
              ),
              IF(NOT (OLD.semana <=> NEW.semana), JSON_OBJECT('semana', JSON_ARRAY(OLD.semana, NEW.semana)), JSON_OBJECT())
            ),
            IF(NOT (OLD.mes <=> NEW.mes), JSON_OBJECT('mes', JSON_ARRAY(OLD.mes, NEW.mes)), JSON_OBJECT())
          ),
          IF(NOT (OLD.ot_finalizada <=> NEW.ot_finalizada), JSON_OBJECT('ot_finalizada', JSON_ARRAY(OLD.ot_finalizada, NEW.ot_finalizada)), JSON_OBJECT())
        ),
        JSON_MERGE_PATCH(
          IF(NOT (OLD.fecha_finalizacion <=> NEW.fecha_finalizacion), JSON_OBJECT('fecha_finalizacion', JSON_ARRAY(OLD.fecha_finalizacion, NEW.fecha_finalizacion)), JSON_OBJECT()),
          IF(NOT (OLD.id_user_finaliza <=> NEW.id_user_finaliza), JSON_OBJECT('id_user_finaliza', JSON_ARRAY(OLD.id_user_finaliza, NEW.id_user_finaliza)), JSON_OBJECT())
        )
      ),
      IF(NOT (OLD.std_reg <=> NEW.std_reg), JSON_OBJECT('std_reg', JSON_ARRAY(OLD.std_reg, NEW.std_reg)), JSON_OBJECT())
    ),
    NULLIF(
      CONCAT_WS(',',
        IF(NOT (OLD.id_ai_ot <=> NEW.id_ai_ot), 'id_ai_ot', NULL),
        IF(NOT (OLD.n_ot <=> NEW.n_ot), 'n_ot', NULL),
        IF(NOT (OLD.id_ai_area <=> NEW.id_ai_area), 'id_ai_area', NULL),
        IF(NOT (OLD.id_user <=> NEW.id_user), 'id_user', NULL),
        IF(NOT (OLD.id_ai_sitio <=> NEW.id_ai_sitio), 'id_ai_sitio', NULL),
        IF(NOT (OLD.id_ai_estado <=> NEW.id_ai_estado), 'id_ai_estado', NULL),
        IF(NOT (OLD.nombre_trab <=> NEW.nombre_trab), 'nombre_trab', NULL),
        IF(NOT (OLD.fecha <=> NEW.fecha), 'fecha', NULL),
        IF(NOT (OLD.semana <=> NEW.semana), 'semana', NULL),
        IF(NOT (OLD.mes <=> NEW.mes), 'mes', NULL),
        IF(NOT (OLD.ot_finalizada <=> NEW.ot_finalizada), 'ot_finalizada', NULL),
        IF(NOT (OLD.fecha_finalizacion <=> NEW.fecha_finalizacion), 'fecha_finalizacion', NULL),
        IF(NOT (OLD.id_user_finaliza <=> NEW.id_user_finaliza), 'id_user_finaliza', NULL),
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

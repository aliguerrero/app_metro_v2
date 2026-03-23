USE `bdapp_metro`;

DROP TRIGGER IF EXISTS `trg_estado_ot_au`;
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

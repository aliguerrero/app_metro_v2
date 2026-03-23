USE bdapp_metro;

ALTER TABLE estado_ot
    ADD COLUMN IF NOT EXISTS bloquea_ot TINYINT(1) NOT NULL DEFAULT 0 AFTER libera_herramientas;

CREATE INDEX IF NOT EXISTS idx_estado_ot_bloquea_ot ON estado_ot (bloquea_ot, std_reg);

UPDATE estado_ot
SET bloquea_ot = 0
WHERE bloquea_ot IS NULL;

UPDATE estado_ot
SET bloquea_ot = 1,
    libera_herramientas = 1
WHERE UPPER(TRIM(nombre_estado)) = 'EJECUTADA';

UPDATE estado_ot
SET bloquea_ot = 0
WHERE UPPER(TRIM(nombre_estado)) <> 'EJECUTADA'
  AND bloquea_ot <> 0;

UPDATE orden_trabajo ot
LEFT JOIN estado_ot eo
    ON eo.id_ai_estado = ot.id_ai_estado
SET
    ot.ot_finalizada = CASE WHEN COALESCE(eo.bloquea_ot, 0) = 1 THEN 1 ELSE 0 END,
    ot.fecha_finalizacion = CASE
        WHEN COALESCE(eo.bloquea_ot, 0) = 1 THEN COALESCE(ot.fecha_finalizacion, NOW())
        ELSE NULL
    END,
    ot.id_user_finaliza = CASE
        WHEN COALESCE(eo.bloquea_ot, 0) = 1 THEN COALESCE(NULLIF(ot.id_user_finaliza, ''), ot.id_user)
        ELSE NULL
    END
WHERE ot.std_reg = 1;

UPDATE herramientaot hot
INNER JOIN orden_trabajo ot
    ON ot.n_ot = hot.n_ot
   AND ot.std_reg = 1
INNER JOIN estado_ot eo
    ON eo.id_ai_estado = ot.id_ai_estado
SET hot.estadoot = 'LIBERADA'
WHERE COALESCE(eo.libera_herramientas, 0) = 1
  AND COALESCE(hot.estadoot, 'ASIGNADA') <> 'LIBERADA';

DROP TRIGGER IF EXISTS trg_estado_ot_ai;
DROP TRIGGER IF EXISTS trg_estado_ot_bi;
DROP TRIGGER IF EXISTS trg_estado_ot_bu;
DROP TRIGGER IF EXISTS trg_estado_ot_au;

DELIMITER $$

CREATE TRIGGER trg_estado_ot_bi BEFORE INSERT ON estado_ot
FOR EACH ROW
BEGIN
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
END$$

CREATE TRIGGER trg_estado_ot_ai AFTER INSERT ON estado_ot
FOR EACH ROW
BEGIN
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
END$$

CREATE TRIGGER trg_estado_ot_bu BEFORE UPDATE ON estado_ot
FOR EACH ROW
BEGIN
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
END$$

CREATE TRIGGER trg_estado_ot_au AFTER UPDATE ON estado_ot
FOR EACH ROW
BEGIN
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
END$$

DELIMITER ;

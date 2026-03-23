USE bdapp_metro;

ALTER TABLE orden_trabajo
    ADD COLUMN IF NOT EXISTS id_ai_estado INT(11) NULL AFTER id_ai_sitio;

SET @estado_ejecutada := (
    SELECT id_ai_estado
    FROM estado_ot
    WHERE UPPER(nombre_estado) = 'EJECUTADA'
      AND std_reg = 1
    ORDER BY id_ai_estado ASC
    LIMIT 1
);

SET @estado_predeterminado := COALESCE(
    (
        SELECT id_ai_estado
        FROM estado_ot
        WHERE UPPER(nombre_estado) = 'NO EJECUTADA'
          AND std_reg = 1
        ORDER BY id_ai_estado ASC
        LIMIT 1
    ),
    (
        SELECT id_ai_estado
        FROM estado_ot
        WHERE std_reg = 1
          AND id_ai_estado <> COALESCE(@estado_ejecutada, -1)
        ORDER BY id_ai_estado ASC
        LIMIT 1
    ),
    COALESCE(@estado_ejecutada, 1)
);

UPDATE orden_trabajo ot
LEFT JOIN (
    SELECT d1.n_ot, d1.id_ai_estado
    FROM detalle_orden d1
    INNER JOIN (
        SELECT n_ot, MAX(id_ai_detalle) AS max_id
        FROM detalle_orden
        GROUP BY n_ot
    ) d2 ON d2.n_ot = d1.n_ot AND d2.max_id = d1.id_ai_detalle
) ult_det ON ult_det.n_ot = ot.n_ot
SET ot.id_ai_estado = COALESCE(
        ot.id_ai_estado,
        ult_det.id_ai_estado,
        CASE
            WHEN COALESCE(ot.ot_finalizada, 0) = 1 THEN COALESCE(@estado_ejecutada, @estado_predeterminado)
            ELSE @estado_predeterminado
        END
    )
WHERE ot.id_ai_estado IS NULL;

UPDATE orden_trabajo
SET id_ai_estado = COALESCE(@estado_ejecutada, id_ai_estado)
WHERE COALESCE(ot_finalizada, 0) = 1
  AND @estado_ejecutada IS NOT NULL;

UPDATE orden_trabajo
SET ot_finalizada = CASE
        WHEN id_ai_estado = COALESCE(@estado_ejecutada, id_ai_estado) THEN 1
        ELSE 0
    END,
    fecha_finalizacion = CASE
        WHEN id_ai_estado = COALESCE(@estado_ejecutada, id_ai_estado) THEN COALESCE(fecha_finalizacion, NOW())
        ELSE NULL
    END,
    id_user_finaliza = CASE
        WHEN id_ai_estado = COALESCE(@estado_ejecutada, id_ai_estado) THEN COALESCE(NULLIF(id_user_finaliza, ''), id_user)
        ELSE NULL
    END
WHERE std_reg = 1;

UPDATE herramientaot h
INNER JOIN orden_trabajo ot ON ot.n_ot = h.n_ot
SET h.estadoot = 'LIBERADA'
WHERE ot.std_reg = 1
  AND ot.id_ai_estado = COALESCE(@estado_ejecutada, ot.id_ai_estado)
  AND COALESCE(h.estadoot, 'ASIGNADA') <> 'LIBERADA';

ALTER TABLE orden_trabajo
    MODIFY COLUMN id_ai_estado INT(11) NOT NULL COMMENT 'Estado operativo actual de la orden de trabajo';

SET @fk_ot_estado_exists := (
    SELECT COUNT(1)
    FROM information_schema.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = DATABASE()
      AND TABLE_NAME = 'orden_trabajo'
      AND CONSTRAINT_NAME = 'orden_trabajo_ibfk_4'
      AND CONSTRAINT_TYPE = 'FOREIGN KEY'
);
SET @sql_add_fk_ot_estado := IF(
    @fk_ot_estado_exists = 0,
    'ALTER TABLE orden_trabajo ADD CONSTRAINT orden_trabajo_ibfk_4 FOREIGN KEY (id_ai_estado) REFERENCES estado_ot (id_ai_estado) ON DELETE RESTRICT ON UPDATE CASCADE',
    'SELECT 1'
);
PREPARE stmt_add_fk_ot_estado FROM @sql_add_fk_ot_estado;
EXECUTE stmt_add_fk_ot_estado;
DEALLOCATE PREPARE stmt_add_fk_ot_estado;

CREATE INDEX IF NOT EXISTS idx_orden_trabajo_estado ON orden_trabajo (id_ai_estado, std_reg);

DROP TRIGGER IF EXISTS trg_detalle_orden_ad;
DROP TRIGGER IF EXISTS trg_detalle_orden_ai;
DROP TRIGGER IF EXISTS trg_detalle_orden_au;

SET @fk_det_estado_exists := (
    SELECT COUNT(1)
    FROM information_schema.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = DATABASE()
      AND TABLE_NAME = 'detalle_orden'
      AND CONSTRAINT_NAME = 'detalle_orden_ibfk_5'
      AND CONSTRAINT_TYPE = 'FOREIGN KEY'
);
SET @sql_drop_fk_det_estado := IF(
    @fk_det_estado_exists > 0,
    'ALTER TABLE detalle_orden DROP FOREIGN KEY detalle_orden_ibfk_5',
    'SELECT 1'
);
PREPARE stmt_drop_fk_det_estado FROM @sql_drop_fk_det_estado;
EXECUTE stmt_drop_fk_det_estado;
DEALLOCATE PREPARE stmt_drop_fk_det_estado;

SET @idx_det_estado_exists := (
    SELECT COUNT(1)
    FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'detalle_orden'
      AND INDEX_NAME = 'status'
);
SET @sql_drop_idx_det_estado := IF(
    @idx_det_estado_exists > 0,
    'ALTER TABLE detalle_orden DROP INDEX status',
    'SELECT 1'
);
PREPARE stmt_drop_idx_det_estado FROM @sql_drop_idx_det_estado;
EXECUTE stmt_drop_idx_det_estado;
DEALLOCATE PREPARE stmt_drop_idx_det_estado;

ALTER TABLE detalle_orden
    DROP COLUMN IF EXISTS id_ai_estado;

DELIMITER $$

CREATE TRIGGER trg_detalle_orden_ad
AFTER DELETE ON detalle_orden
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
END$$

CREATE TRIGGER trg_detalle_orden_ai
AFTER INSERT ON detalle_orden
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
END$$

CREATE TRIGGER trg_detalle_orden_au
AFTER UPDATE ON detalle_orden
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
END$$

DROP TRIGGER IF EXISTS trg_orden_trabajo_ai$$
DROP TRIGGER IF EXISTS trg_orden_trabajo_au$$

CREATE TRIGGER trg_orden_trabajo_ai
AFTER INSERT ON orden_trabajo
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
END$$

CREATE TRIGGER trg_orden_trabajo_au
AFTER UPDATE ON orden_trabajo
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
END$$

DROP TRIGGER IF EXISTS trg_estado_ot_bu$$
CREATE TRIGGER trg_estado_ot_bu
BEFORE UPDATE ON estado_ot
FOR EACH ROW
BEGIN
  IF UPPER(OLD.nombre_estado) = 'EJECUTADA'
     AND (
       NOT (OLD.nombre_estado <=> NEW.nombre_estado)
       OR NOT (OLD.color <=> NEW.color)
       OR NOT (OLD.std_reg <=> NEW.std_reg)
     ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'El estado EJECUTADA es protegido y no puede modificarse ni eliminarse.';
  END IF;
END$$

DELIMITER ;

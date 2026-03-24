SET @schema_name = DATABASE();

SET @old_col_exists = (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = @schema_name
      AND TABLE_NAME = 'herramientaot'
      AND COLUMN_NAME = 'estadoot'
);

SET @new_col_exists = (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = @schema_name
      AND TABLE_NAME = 'herramientaot'
      AND COLUMN_NAME = 'estado_herramientaot'
);

SET @sql = IF(
    @old_col_exists = 1 AND @new_col_exists = 0,
    "ALTER TABLE herramientaot CHANGE COLUMN estadoot estado_herramientaot VARCHAR(60) NOT NULL DEFAULT 'ASIGNADA' COMMENT 'Estado o condicion de la herramienta dentro de la OT'",
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = IF(
    (
        SELECT COUNT(*)
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = @schema_name
          AND TABLE_NAME = 'herramientaot'
          AND COLUMN_NAME = 'estado_herramientaot'
    ) = 1,
    "ALTER TABLE herramientaot MODIFY COLUMN estado_herramientaot VARCHAR(60) NOT NULL DEFAULT 'ASIGNADA' COMMENT 'Estado o condicion de la herramienta dentro de la OT'",
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

CREATE OR REPLACE SQL SECURITY INVOKER VIEW vw_ot_resumen AS
SELECT
    ot.id_ai_ot,
    ot.n_ot,
    ot.fecha,
    ot.semana,
    ot.mes,
    ot.nombre_trab,
    ot.id_ai_area,
    area.nombre_area,
    area.nomeclatura AS area_nomeclatura,
    ot.id_ai_sitio,
    sitio.nombre_sitio,
    ot.id_ai_estado,
    eo.nombre_estado,
    eo.color AS color_estado,
    COALESCE(eo.libera_herramientas, 0) AS libera_herramientas,
    COALESCE(eo.bloquea_ot, 0) AS bloquea_ot,
    COALESCE(ot.ot_finalizada, 0) AS ot_finalizada,
    ot.fecha_finalizacion,
    ot.id_user_finaliza,
    ot.id_user AS id_user_responsable,
    us.username AS username_responsable,
    emp.nombre_empleado AS empleado_responsable,
    emp.telefono AS telefono_responsable,
    emp.correo AS correo_responsable,
    COALESCE(det.total_detalles, 0) AS total_detalles,
    COALESCE(hot.herramientas_asignadas, 0) AS herramientas_asignadas,
    COALESCE(hot.herramientas_activas, 0) AS herramientas_activas,
    ot.std_reg
FROM orden_trabajo ot
LEFT JOIN area_trabajo area
    ON area.id_ai_area = ot.id_ai_area
LEFT JOIN sitio_trabajo sitio
    ON sitio.id_ai_sitio = ot.id_ai_sitio
LEFT JOIN estado_ot eo
    ON eo.id_ai_estado = ot.id_ai_estado
LEFT JOIN user_system us
    ON us.id_empleado = ot.id_user
LEFT JOIN empleado emp
    ON emp.id_empleado = ot.id_user
LEFT JOIN (
    SELECT n_ot, COUNT(*) AS total_detalles
    FROM detalle_orden
    GROUP BY n_ot
) det
    ON det.n_ot = ot.n_ot
LEFT JOIN (
    SELECT
        n_ot,
        COALESCE(SUM(cantidadot), 0) AS herramientas_asignadas,
        COALESCE(SUM(CASE WHEN COALESCE(estado_herramientaot, 'ASIGNADA') <> 'LIBERADA' THEN cantidadot ELSE 0 END), 0) AS herramientas_activas
    FROM herramientaot
    GROUP BY n_ot
) hot
    ON hot.n_ot = ot.n_ot
WHERE ot.std_reg = 1;

CREATE OR REPLACE SQL SECURITY INVOKER VIEW vw_herramienta_disponibilidad AS
SELECT
    h.id_ai_herramienta,
    h.nombre_herramienta,
    h.id_ai_categoria_herramienta,
    ch.nombre_categoria,
    h.cantidad AS cantidad_total,
    COALESCE(occ.cantidad_ocupada, 0) AS cantidad_ocupada,
    GREATEST(h.cantidad - COALESCE(occ.cantidad_ocupada, 0), 0) AS cantidad_disponible,
    COALESCE(occ.ots_activas, 0) AS ots_activas,
    h.estado,
    h.std_reg
FROM herramienta h
LEFT JOIN categoria_herramienta ch
    ON ch.id_ai_categoria_herramienta = h.id_ai_categoria_herramienta
LEFT JOIN (
    SELECT
        hot.id_ai_herramienta,
        COALESCE(SUM(CASE WHEN COALESCE(hot.estado_herramientaot, 'ASIGNADA') <> 'LIBERADA' THEN hot.cantidadot ELSE 0 END), 0) AS cantidad_ocupada,
        COUNT(DISTINCT CASE WHEN COALESCE(hot.estado_herramientaot, 'ASIGNADA') <> 'LIBERADA' THEN hot.n_ot END) AS ots_activas
    FROM herramientaot hot
    GROUP BY hot.id_ai_herramienta
) occ
    ON occ.id_ai_herramienta = h.id_ai_herramienta
WHERE h.std_reg = 1;

CREATE OR REPLACE SQL SECURITY INVOKER VIEW vw_herramientas_ocupadas AS
SELECT
    hot.id_ai_herramientaOT,
    hot.id_ai_herramienta,
    h.nombre_herramienta,
    hot.n_ot,
    ot.nombre_trab,
    hot.cantidadot,
    COALESCE(eo.nombre_estado, 'SIN ESTADO') AS estado_ot,
    COALESCE(det.id_user_act, ot.id_user, '') AS tecnico_id,
    COALESCE(emp_det.nombre_empleado, emp_ot.nombre_empleado, 'Sin tecnico asignado') AS tecnico_nombre,
    COALESCE(emp_det.telefono, emp_ot.telefono, '') AS telefono,
    COALESCE(emp_det.correo, emp_ot.correo, '') AS correo,
    COALESCE(emp_det.direccion, emp_ot.direccion, '') AS direccion,
    hot.estado_herramientaot,
    ot.fecha AS fecha_ot
FROM herramientaot hot
INNER JOIN herramienta h
    ON h.id_ai_herramienta = hot.id_ai_herramienta
   AND h.std_reg = 1
INNER JOIN orden_trabajo ot
    ON ot.n_ot = hot.n_ot
   AND ot.std_reg = 1
LEFT JOIN estado_ot eo
    ON eo.id_ai_estado = ot.id_ai_estado
LEFT JOIN (
    SELECT d1.n_ot, d1.id_user_act
    FROM detalle_orden d1
    INNER JOIN (
        SELECT n_ot, MAX(id_ai_detalle) AS max_id
        FROM detalle_orden
        GROUP BY n_ot
    ) d2
        ON d2.n_ot = d1.n_ot
       AND d2.max_id = d1.id_ai_detalle
) det
    ON det.n_ot = hot.n_ot
LEFT JOIN empleado emp_det
    ON emp_det.id_empleado = det.id_user_act
   AND emp_det.std_reg = 1
LEFT JOIN empleado emp_ot
    ON emp_ot.id_empleado = ot.id_user
   AND emp_ot.std_reg = 1
WHERE COALESCE(hot.estado_herramientaot, 'ASIGNADA') <> 'LIBERADA';

DROP PROCEDURE IF EXISTS sp_ot_asignar_herramienta;
DROP PROCEDURE IF EXISTS sp_ot_cambiar_estado;
DROP PROCEDURE IF EXISTS sp_herramienta_ocupaciones;

DELIMITER $$

CREATE PROCEDURE sp_ot_asignar_herramienta(
    IN p_n_ot VARCHAR(30),
    IN p_id_ai_herramienta INT,
    IN p_cantidad INT,
    IN p_id_user_operacion VARCHAR(30)
)
BEGIN
    DECLARE v_bloqueada INT DEFAULT NULL;
    DECLARE v_total INT DEFAULT NULL;
    DECLARE v_ocupada INT DEFAULT 0;
    DECLARE v_disponible INT DEFAULT 0;
    DECLARE v_actual_ot INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF TRIM(COALESCE(p_n_ot, '')) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La O.T. es obligatoria.';
    END IF;

    IF p_id_ai_herramienta IS NULL OR p_id_ai_herramienta <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La herramienta es obligatoria.';
    END IF;

    IF p_cantidad IS NULL OR p_cantidad <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cantidad a asignar debe ser mayor a cero.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM user_system WHERE id_empleado = p_id_user_operacion AND std_reg = 1) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario de la operacion no existe o esta inactivo.';
    END IF;

    SET @app_user = p_id_user_operacion;

    START TRANSACTION;

    SELECT CASE
             WHEN COALESCE(ot.ot_finalizada, 0) = 1 THEN 1
             WHEN COALESCE(eo.bloquea_ot, 0) = 1 THEN 1
             ELSE 0
           END
      INTO v_bloqueada
    FROM orden_trabajo ot
    LEFT JOIN estado_ot eo
      ON eo.id_ai_estado = ot.id_ai_estado
    WHERE ot.n_ot = p_n_ot
      AND ot.std_reg = 1
    LIMIT 1
    FOR UPDATE;

    IF v_bloqueada IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La O.T. indicada no existe o esta inactiva.';
    END IF;

    IF v_bloqueada = 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La O.T. esta bloqueada y no admite asignacion de herramientas.';
    END IF;

    SELECT h.cantidad
      INTO v_total
    FROM herramienta h
    WHERE h.id_ai_herramienta = p_id_ai_herramienta
      AND h.std_reg = 1
    FOR UPDATE;

    IF v_total IS NULL OR v_total <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La herramienta no existe o esta inactiva.';
    END IF;

    SELECT COALESCE(SUM(cantidadot), 0)
      INTO v_ocupada
    FROM herramientaot
    WHERE id_ai_herramienta = p_id_ai_herramienta
      AND COALESCE(estado_herramientaot, 'ASIGNADA') <> 'LIBERADA';

    SET v_disponible = GREATEST(v_total - v_ocupada, 0);

    IF v_disponible < p_cantidad THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay disponibilidad suficiente para asignar la herramienta.';
    END IF;

    SELECT COALESCE(SUM(cantidadot), 0)
      INTO v_actual_ot
    FROM herramientaot
    WHERE n_ot = p_n_ot
      AND id_ai_herramienta = p_id_ai_herramienta
      AND COALESCE(estado_herramientaot, 'ASIGNADA') <> 'LIBERADA';

    DELETE FROM herramientaot
    WHERE n_ot = p_n_ot
      AND id_ai_herramienta = p_id_ai_herramienta
      AND COALESCE(estado_herramientaot, 'ASIGNADA') <> 'LIBERADA';

    INSERT INTO herramientaot (
        id_ai_herramienta, n_ot, cantidadot, estado_herramientaot
    ) VALUES (
        p_id_ai_herramienta, p_n_ot, (v_actual_ot + p_cantidad), 'ASIGNADA'
    );

    COMMIT;

    SELECT *
    FROM vw_herramienta_disponibilidad
    WHERE id_ai_herramienta = p_id_ai_herramienta
    LIMIT 1;
END$$

CREATE PROCEDURE sp_ot_cambiar_estado(
    IN p_n_ot VARCHAR(30),
    IN p_id_ai_estado INT,
    IN p_id_user_operacion VARCHAR(30)
)
BEGIN
    DECLARE v_estado_actual INT DEFAULT NULL;
    DECLARE v_ot_finalizada INT DEFAULT 0;
    DECLARE v_ot_bloqueada INT DEFAULT 0;
    DECLARE v_estado_destino_nombre VARCHAR(100) DEFAULT NULL;
    DECLARE v_libera_herramientas INT DEFAULT 0;
    DECLARE v_bloquea_ot INT DEFAULT 0;
    DECLARE v_tiene_detalles INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF TRIM(COALESCE(p_n_ot, '')) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La O.T. es obligatoria.';
    END IF;

    IF p_id_ai_estado IS NULL OR p_id_ai_estado <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El estado destino es obligatorio.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM user_system WHERE id_empleado = p_id_user_operacion AND std_reg = 1) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario de la operacion no existe o esta inactivo.';
    END IF;

    SET @app_user = p_id_user_operacion;

    START TRANSACTION;

    SELECT
        ot.id_ai_estado,
        COALESCE(ot.ot_finalizada, 0),
        COALESCE(eo.bloquea_ot, 0)
      INTO v_estado_actual, v_ot_finalizada, v_ot_bloqueada
    FROM orden_trabajo ot
    LEFT JOIN estado_ot eo
      ON eo.id_ai_estado = ot.id_ai_estado
    WHERE ot.n_ot = p_n_ot
      AND ot.std_reg = 1
    LIMIT 1
    FOR UPDATE;

    IF v_estado_actual IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La O.T. indicada no existe o esta inactiva.';
    END IF;

    IF v_ot_finalizada = 1 OR v_ot_bloqueada = 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La O.T. ya esta bloqueada y no puede volver a cambiar de estado.';
    END IF;

    IF v_estado_actual = p_id_ai_estado THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La O.T. ya posee el estado indicado.';
    END IF;

    SELECT
        nombre_estado,
        COALESCE(libera_herramientas, 0),
        COALESCE(bloquea_ot, 0)
      INTO v_estado_destino_nombre, v_libera_herramientas, v_bloquea_ot
    FROM estado_ot
    WHERE id_ai_estado = p_id_ai_estado
      AND std_reg = 1
    LIMIT 1;

    IF v_estado_destino_nombre IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El estado destino no existe o esta inactivo.';
    END IF;

    IF v_bloquea_ot = 1 THEN
        SELECT COUNT(*) INTO v_tiene_detalles
        FROM detalle_orden
        WHERE n_ot = p_n_ot;

        IF v_tiene_detalles <= 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La O.T. debe tener al menos un detalle antes de pasar a un estado bloqueante.';
        END IF;
    END IF;

    UPDATE orden_trabajo
       SET id_ai_estado = p_id_ai_estado,
           ot_finalizada = CASE WHEN v_bloquea_ot = 1 THEN 1 ELSE 0 END,
           fecha_finalizacion = CASE WHEN v_bloquea_ot = 1 THEN NOW() ELSE NULL END,
           id_user_finaliza = CASE WHEN v_bloquea_ot = 1 THEN p_id_user_operacion ELSE NULL END
     WHERE n_ot = p_n_ot
       AND std_reg = 1;

    IF v_libera_herramientas = 1 THEN
        UPDATE herramientaot
           SET estado_herramientaot = 'LIBERADA'
         WHERE n_ot = p_n_ot
           AND COALESCE(estado_herramientaot, 'ASIGNADA') <> 'LIBERADA';
    END IF;

    COMMIT;

    SELECT *
    FROM vw_ot_resumen
    WHERE n_ot = p_n_ot
    LIMIT 1;
END$$

CREATE PROCEDURE sp_herramienta_ocupaciones(
    IN p_id_ai_herramienta INT,
    IN p_busqueda VARCHAR(100)
)
BEGIN
    IF p_id_ai_herramienta IS NULL OR p_id_ai_herramienta <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La herramienta es obligatoria.';
    END IF;

    SELECT *
    FROM vw_herramientas_ocupadas
    WHERE id_ai_herramienta = p_id_ai_herramienta
      AND (
          TRIM(COALESCE(p_busqueda, '')) = ''
          OR n_ot LIKE CONCAT('%', p_busqueda, '%')
          OR nombre_trab LIKE CONCAT('%', p_busqueda, '%')
          OR tecnico_nombre LIKE CONCAT('%', p_busqueda, '%')
      )
    ORDER BY n_ot ASC, id_ai_herramientaOT ASC;
END$$

DELIMITER ;

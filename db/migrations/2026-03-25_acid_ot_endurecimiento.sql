USE `bdapp_metro`;

SET @schema_name = DATABASE();

SET @idx_exists = (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.STATISTICS
    WHERE TABLE_SCHEMA = @schema_name
      AND TABLE_NAME = 'herramientaot'
      AND INDEX_NAME = 'idx_herramientaot_herr_estado_ot'
);

SET @sql = IF(
    @idx_exists = 0,
    "ALTER TABLE herramientaot ADD KEY idx_herramientaot_herr_estado_ot (id_ai_herramienta, estado_herramientaot, n_ot)",
    'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

DROP PROCEDURE IF EXISTS `sp_ot_actualizar`;
DROP PROCEDURE IF EXISTS `sp_ot_eliminar_logico`;
DROP PROCEDURE IF EXISTS `sp_ot_actualizar_detalle`;
DROP PROCEDURE IF EXISTS `sp_ot_eliminar_detalle`;
DROP PROCEDURE IF EXISTS `sp_ot_ajustar_herramienta_delta`;
DROP PROCEDURE IF EXISTS `sp_ot_set_herramienta_cantidad`;
DROP PROCEDURE IF EXISTS `sp_ot_asignar_herramienta`;

DELIMITER $$

CREATE PROCEDURE `sp_ot_actualizar`(
    IN `p_n_ot` VARCHAR(30),
    IN `p_id_ai_sitio` INT,
    IN `p_nombre_trab` VARCHAR(500),
    IN `p_fecha` DATE,
    IN `p_semana` VARCHAR(100),
    IN `p_mes` VARCHAR(100),
    IN `p_id_user_operacion` VARCHAR(30)
)
BEGIN
    DECLARE v_bloqueada INT DEFAULT NULL;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF TRIM(COALESCE(p_n_ot, '')) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La O.T. es obligatoria.';
    END IF;

    IF p_id_ai_sitio IS NULL OR p_id_ai_sitio <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El sitio de trabajo es obligatorio.';
    END IF;

    IF TRIM(COALESCE(p_nombre_trab, '')) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre del trabajo es obligatorio.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM sitio_trabajo
        WHERE id_ai_sitio = p_id_ai_sitio
          AND std_reg = 1
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El sitio de trabajo no existe o esta inactivo.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM user_system
        WHERE id_empleado = p_id_user_operacion
          AND std_reg = 1
    ) THEN
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
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La O.T. esta bloqueada y no admite modificaciones.';
    END IF;

    UPDATE orden_trabajo
       SET id_ai_sitio = p_id_ai_sitio,
           nombre_trab = p_nombre_trab,
           fecha = COALESCE(p_fecha, fecha),
           semana = COALESCE(p_semana, ''),
           mes = COALESCE(p_mes, '')
     WHERE n_ot = p_n_ot
       AND std_reg = 1;

    COMMIT;

    SELECT *
    FROM vw_ot_resumen
    WHERE n_ot = p_n_ot
    LIMIT 1;
END$$

CREATE PROCEDURE `sp_ot_eliminar_logico`(
    IN `p_n_ot` VARCHAR(30),
    IN `p_id_user_operacion` VARCHAR(30)
)
BEGIN
    DECLARE v_std_reg INT DEFAULT NULL;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF TRIM(COALESCE(p_n_ot, '')) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La O.T. es obligatoria.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM user_system
        WHERE id_empleado = p_id_user_operacion
          AND std_reg = 1
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario de la operacion no existe o esta inactivo.';
    END IF;

    SET @app_user = p_id_user_operacion;

    START TRANSACTION;

    SELECT std_reg
      INTO v_std_reg
    FROM orden_trabajo
    WHERE n_ot = p_n_ot
    LIMIT 1
    FOR UPDATE;

    IF v_std_reg IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La O.T. indicada no existe.';
    END IF;

    IF v_std_reg <> 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La O.T. indicada ya se encuentra inactiva.';
    END IF;

    UPDATE orden_trabajo
       SET std_reg = 0
     WHERE n_ot = p_n_ot
       AND std_reg = 1;

    COMMIT;

    SELECT n_ot, nombre_trab, std_reg, id_ai_estado, COALESCE(ot_finalizada, 0) AS ot_finalizada
    FROM orden_trabajo
    WHERE n_ot = p_n_ot
    LIMIT 1;
END$$

CREATE PROCEDURE `sp_ot_actualizar_detalle`(
    IN `p_id_ai_detalle` INT,
    IN `p_n_ot` VARCHAR(30),
    IN `p_fecha` DATE,
    IN `p_descripcion` VARCHAR(250),
    IN `p_id_ai_turno` INT,
    IN `p_id_miembro_cco` VARCHAR(10),
    IN `p_id_user_act` VARCHAR(30),
    IN `p_id_miembro_ccf` VARCHAR(10),
    IN `p_cant_tec` INT,
    IN `p_hora_inicio` TIME,
    IN `p_hora_fin` TIME,
    IN `p_observacion` VARCHAR(250),
    IN `p_id_user_operacion` VARCHAR(30)
)
BEGIN
    DECLARE v_bloqueada INT DEFAULT NULL;
    DECLARE v_detalle_ot VARCHAR(30) DEFAULT NULL;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_id_ai_detalle IS NULL OR p_id_ai_detalle <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El detalle a actualizar es obligatorio.';
    END IF;

    IF TRIM(COALESCE(p_n_ot, '')) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La O.T. es obligatoria.';
    END IF;

    IF TRIM(COALESCE(p_descripcion, '')) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La descripcion del detalle es obligatoria.';
    END IF;

    IF p_cant_tec IS NULL OR p_cant_tec <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cantidad de tecnicos debe ser mayor a cero.';
    END IF;

    IF p_hora_inicio IS NOT NULL AND p_hora_fin IS NOT NULL AND p_hora_fin < p_hora_inicio THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La hora fin no puede ser menor que la hora inicio.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM turno_trabajo
        WHERE id_ai_turno = p_id_ai_turno
          AND std_reg = 1
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El turno indicado no existe o esta inactivo.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM miembro
        WHERE id_miembro = p_id_miembro_cco
          AND std_reg = 1
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El miembro CCO no existe o esta inactivo.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM miembro
        WHERE id_miembro = p_id_miembro_ccf
          AND std_reg = 1
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El miembro CCF no existe o esta inactivo.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM user_system
        WHERE id_empleado = p_id_user_act
          AND std_reg = 1
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El tecnico indicado no existe o esta inactivo.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM user_system
        WHERE id_empleado = p_id_user_operacion
          AND std_reg = 1
    ) THEN
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
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La O.T. esta bloqueada y no admite modificaciones en sus detalles.';
    END IF;

    SELECT n_ot
      INTO v_detalle_ot
    FROM detalle_orden
    WHERE id_ai_detalle = p_id_ai_detalle
    LIMIT 1
    FOR UPDATE;

    IF v_detalle_ot IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El detalle indicado no existe.';
    END IF;

    IF v_detalle_ot <> p_n_ot THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El detalle indicado no pertenece a la O.T. enviada.';
    END IF;

    UPDATE detalle_orden
       SET fecha = COALESCE(p_fecha, fecha),
           descripcion = p_descripcion,
           id_ai_turno = p_id_ai_turno,
           id_miembro_cco = p_id_miembro_cco,
           id_user_act = p_id_user_act,
           id_miembro_ccf = p_id_miembro_ccf,
           cant_tec = p_cant_tec,
           hora_inicio = p_hora_inicio,
           hora_fin = p_hora_fin,
           observacion = p_observacion
     WHERE id_ai_detalle = p_id_ai_detalle;

    COMMIT;

    SELECT *
    FROM vw_ot_detallada
    WHERE id_ai_detalle = p_id_ai_detalle
    LIMIT 1;
END$$

CREATE PROCEDURE `sp_ot_eliminar_detalle`(
    IN `p_id_ai_detalle` INT,
    IN `p_n_ot` VARCHAR(30),
    IN `p_id_user_operacion` VARCHAR(30)
)
BEGIN
    DECLARE v_bloqueada INT DEFAULT NULL;
    DECLARE v_detalle_ot VARCHAR(30) DEFAULT NULL;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_id_ai_detalle IS NULL OR p_id_ai_detalle <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El detalle a eliminar es obligatorio.';
    END IF;

    IF TRIM(COALESCE(p_n_ot, '')) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La O.T. es obligatoria.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM user_system
        WHERE id_empleado = p_id_user_operacion
          AND std_reg = 1
    ) THEN
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
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La O.T. esta bloqueada y no admite eliminacion de detalles.';
    END IF;

    SELECT n_ot
      INTO v_detalle_ot
    FROM detalle_orden
    WHERE id_ai_detalle = p_id_ai_detalle
    LIMIT 1
    FOR UPDATE;

    IF v_detalle_ot IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El detalle indicado no existe.';
    END IF;

    IF v_detalle_ot <> p_n_ot THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El detalle indicado no pertenece a la O.T. enviada.';
    END IF;

    DELETE FROM detalle_orden
    WHERE id_ai_detalle = p_id_ai_detalle;

    COMMIT;

    SELECT 1 AS ok, p_id_ai_detalle AS id_ai_detalle, p_n_ot AS n_ot;
END$$

CREATE PROCEDURE `sp_ot_ajustar_herramienta_delta`(
    IN `p_n_ot` VARCHAR(30),
    IN `p_id_ai_herramienta` INT,
    IN `p_delta` INT,
    IN `p_id_user_operacion` VARCHAR(30)
)
BEGIN
    DECLARE v_bloqueada INT DEFAULT NULL;
    DECLARE v_total INT DEFAULT NULL;
    DECLARE v_ocupada INT DEFAULT 0;
    DECLARE v_actual_ot INT DEFAULT 0;
    DECLARE v_nueva_cantidad INT DEFAULT 0;

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

    IF p_delta IS NULL OR p_delta = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El ajuste de cantidad no puede ser cero.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM user_system
        WHERE id_empleado = p_id_user_operacion
          AND std_reg = 1
    ) THEN
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
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La O.T. esta bloqueada y no admite cambios en herramientas.';
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
      INTO v_actual_ot
    FROM herramientaot
    WHERE n_ot = p_n_ot
      AND id_ai_herramienta = p_id_ai_herramienta
      AND COALESCE(estado_herramientaot, 'ASIGNADA') <> 'LIBERADA';

    SET v_nueva_cantidad = v_actual_ot + p_delta;

    IF v_nueva_cantidad < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La O.T. no tiene cantidad suficiente asignada para retirar esa herramienta.';
    END IF;

    IF p_delta > 0 THEN
        SELECT COALESCE(SUM(cantidadot), 0)
          INTO v_ocupada
        FROM herramientaot
        WHERE id_ai_herramienta = p_id_ai_herramienta
          AND COALESCE(estado_herramientaot, 'ASIGNADA') <> 'LIBERADA';

        IF GREATEST(v_total - v_ocupada, 0) < p_delta THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay disponibilidad suficiente para asignar la herramienta.';
        END IF;
    END IF;

    DELETE FROM herramientaot
    WHERE n_ot = p_n_ot
      AND id_ai_herramienta = p_id_ai_herramienta
      AND COALESCE(estado_herramientaot, 'ASIGNADA') <> 'LIBERADA';

    IF v_nueva_cantidad > 0 THEN
        INSERT INTO herramientaot (
            id_ai_herramienta,
            n_ot,
            cantidadot,
            estado_herramientaot
        ) VALUES (
            p_id_ai_herramienta,
            p_n_ot,
            v_nueva_cantidad,
            'ASIGNADA'
        );
    END IF;

    COMMIT;

    SELECT *
    FROM vw_herramienta_disponibilidad
    WHERE id_ai_herramienta = p_id_ai_herramienta
    LIMIT 1;
END$$

CREATE PROCEDURE `sp_ot_set_herramienta_cantidad`(
    IN `p_n_ot` VARCHAR(30),
    IN `p_id_ai_herramienta` INT,
    IN `p_cantidad_final` INT,
    IN `p_id_user_operacion` VARCHAR(30)
)
BEGIN
    DECLARE v_bloqueada INT DEFAULT NULL;
    DECLARE v_total INT DEFAULT NULL;
    DECLARE v_ocupada INT DEFAULT 0;
    DECLARE v_actual_ot INT DEFAULT 0;
    DECLARE v_requerida_adicional INT DEFAULT 0;

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

    IF p_cantidad_final IS NULL OR p_cantidad_final < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cantidad final no puede ser negativa.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM user_system
        WHERE id_empleado = p_id_user_operacion
          AND std_reg = 1
    ) THEN
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
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La O.T. esta bloqueada y no admite cambios en herramientas.';
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
      INTO v_actual_ot
    FROM herramientaot
    WHERE n_ot = p_n_ot
      AND id_ai_herramienta = p_id_ai_herramienta
      AND COALESCE(estado_herramientaot, 'ASIGNADA') <> 'LIBERADA';

    SET v_requerida_adicional = GREATEST(p_cantidad_final - v_actual_ot, 0);

    IF v_requerida_adicional > 0 THEN
        SELECT COALESCE(SUM(cantidadot), 0)
          INTO v_ocupada
        FROM herramientaot
        WHERE id_ai_herramienta = p_id_ai_herramienta
          AND COALESCE(estado_herramientaot, 'ASIGNADA') <> 'LIBERADA';

        IF GREATEST(v_total - v_ocupada, 0) < v_requerida_adicional THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay disponibilidad suficiente para actualizar la herramienta.';
        END IF;
    END IF;

    DELETE FROM herramientaot
    WHERE n_ot = p_n_ot
      AND id_ai_herramienta = p_id_ai_herramienta
      AND COALESCE(estado_herramientaot, 'ASIGNADA') <> 'LIBERADA';

    IF p_cantidad_final > 0 THEN
        INSERT INTO herramientaot (
            id_ai_herramienta,
            n_ot,
            cantidadot,
            estado_herramientaot
        ) VALUES (
            p_id_ai_herramienta,
            p_n_ot,
            p_cantidad_final,
            'ASIGNADA'
        );
    END IF;

    COMMIT;

    SELECT *
    FROM vw_herramienta_disponibilidad
    WHERE id_ai_herramienta = p_id_ai_herramienta
    LIMIT 1;
END$$

CREATE PROCEDURE `sp_ot_asignar_herramienta`(
    IN `p_n_ot` VARCHAR(30),
    IN `p_id_ai_herramienta` INT,
    IN `p_cantidad` INT,
    IN `p_id_user_operacion` VARCHAR(30)
)
BEGIN
    IF p_cantidad IS NULL OR p_cantidad <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cantidad a asignar debe ser mayor a cero.';
    END IF;

    CALL sp_ot_ajustar_herramienta_delta(
        p_n_ot,
        p_id_ai_herramienta,
        p_cantidad,
        p_id_user_operacion
    );
END$$

DELIMITER ;

CREATE USER IF NOT EXISTS 'u_app'@'%' IDENTIFIED BY 'metro123';
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON `bdapp_metro`.* TO 'u_app'@'%';
GRANT ALL PRIVILEGES ON `bdapp_metro`.* TO 'u_admin'@'%' WITH GRANT OPTION;

GRANT EXECUTE ON PROCEDURE `bdapp_metro`.`sp_ot_actualizar` TO rol_escritor;
GRANT EXECUTE ON PROCEDURE `bdapp_metro`.`sp_ot_eliminar_logico` TO rol_escritor;
GRANT EXECUTE ON PROCEDURE `bdapp_metro`.`sp_ot_actualizar_detalle` TO rol_escritor;
GRANT EXECUTE ON PROCEDURE `bdapp_metro`.`sp_ot_eliminar_detalle` TO rol_escritor;
GRANT EXECUTE ON PROCEDURE `bdapp_metro`.`sp_ot_ajustar_herramienta_delta` TO rol_escritor;
GRANT EXECUTE ON PROCEDURE `bdapp_metro`.`sp_ot_set_herramienta_cantidad` TO rol_escritor;

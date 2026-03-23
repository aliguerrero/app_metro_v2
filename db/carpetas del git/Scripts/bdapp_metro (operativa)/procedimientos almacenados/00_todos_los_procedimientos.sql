USE `bdapp_metro`;

DROP PROCEDURE IF EXISTS `sp_herramienta_ocupaciones`;
DROP PROCEDURE IF EXISTS `sp_ot_agregar_detalle`;
DROP PROCEDURE IF EXISTS `sp_ot_asignar_herramienta`;
DROP PROCEDURE IF EXISTS `sp_ot_cambiar_estado`;
DROP PROCEDURE IF EXISTS `sp_ot_crear`;
DROP PROCEDURE IF EXISTS `sp_reporte_registrar_generado`;
DROP PROCEDURE IF EXISTS `sp_usuario_registrar_login_exitoso`;
DROP PROCEDURE IF EXISTS `sp_usuario_registrar_login_fallido`;

DELIMITER $$
CREATE DEFINER=CURRENT_USER PROCEDURE `sp_herramienta_ocupaciones` (IN `p_id_ai_herramienta` INT, IN `p_busqueda` VARCHAR(100))   BEGIN
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

CREATE DEFINER=CURRENT_USER PROCEDURE `sp_ot_agregar_detalle` (IN `p_n_ot` VARCHAR(30), IN `p_fecha` DATE, IN `p_descripcion` VARCHAR(250), IN `p_id_ai_turno` INT, IN `p_id_miembro_cco` VARCHAR(10), IN `p_id_user_act` VARCHAR(30), IN `p_id_miembro_ccf` VARCHAR(10), IN `p_cant_tec` INT, IN `p_hora_inicio` TIME, IN `p_hora_fin` TIME, IN `p_observacion` VARCHAR(250))   BEGIN
    DECLARE v_bloqueada INT DEFAULT NULL;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

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

    IF NOT EXISTS (SELECT 1 FROM turno_trabajo WHERE id_ai_turno = p_id_ai_turno AND std_reg = 1) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El turno indicado no existe o esta inactivo.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM miembro WHERE id_miembro = p_id_miembro_cco AND std_reg = 1) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El miembro CCO no existe o esta inactivo.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM miembro WHERE id_miembro = p_id_miembro_ccf AND std_reg = 1) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El miembro CCF no existe o esta inactivo.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM user_system WHERE id_empleado = p_id_user_act AND std_reg = 1) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario que registra el detalle no existe o esta inactivo.';
    END IF;

    SET @app_user = p_id_user_act;

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
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La O.T. esta bloqueada y no admite nuevos detalles.';
    END IF;

    INSERT INTO detalle_orden (
        n_ot, fecha, descripcion, id_ai_turno, id_miembro_cco,
        id_user_act, id_miembro_ccf, cant_tec, hora_inicio, hora_fin, observacion
    ) VALUES (
        p_n_ot, COALESCE(p_fecha, CURDATE()), p_descripcion, p_id_ai_turno, p_id_miembro_cco,
        p_id_user_act, p_id_miembro_ccf, p_cant_tec, p_hora_inicio, p_hora_fin, p_observacion
    );

    COMMIT;

    SELECT *
    FROM vw_ot_detallada
    WHERE id_ai_detalle = LAST_INSERT_ID()
    LIMIT 1;
END$$

CREATE DEFINER=CURRENT_USER PROCEDURE `sp_ot_asignar_herramienta` (IN `p_n_ot` VARCHAR(30), IN `p_id_ai_herramienta` INT, IN `p_cantidad` INT, IN `p_id_user_operacion` VARCHAR(30))   BEGIN
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
      AND COALESCE(estadoot, 'ASIGNADA') <> 'LIBERADA';

    SET v_disponible = GREATEST(v_total - v_ocupada, 0);

    IF v_disponible < p_cantidad THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay disponibilidad suficiente para asignar la herramienta.';
    END IF;

    SELECT COALESCE(SUM(cantidadot), 0)
      INTO v_actual_ot
    FROM herramientaot
    WHERE n_ot = p_n_ot
      AND id_ai_herramienta = p_id_ai_herramienta
      AND COALESCE(estadoot, 'ASIGNADA') <> 'LIBERADA';

    DELETE FROM herramientaot
    WHERE n_ot = p_n_ot
      AND id_ai_herramienta = p_id_ai_herramienta
      AND COALESCE(estadoot, 'ASIGNADA') <> 'LIBERADA';

    INSERT INTO herramientaot (
        id_ai_herramienta, n_ot, cantidadot, estadoot
    ) VALUES (
        p_id_ai_herramienta, p_n_ot, (v_actual_ot + p_cantidad), 'ASIGNADA'
    );

    COMMIT;

    SELECT *
    FROM vw_herramienta_disponibilidad
    WHERE id_ai_herramienta = p_id_ai_herramienta
    LIMIT 1;
END$$

CREATE DEFINER=CURRENT_USER PROCEDURE `sp_ot_cambiar_estado` (IN `p_n_ot` VARCHAR(30), IN `p_id_ai_estado` INT, IN `p_id_user_operacion` VARCHAR(30))   BEGIN
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
           SET estadoot = 'LIBERADA'
         WHERE n_ot = p_n_ot
           AND COALESCE(estadoot, 'ASIGNADA') <> 'LIBERADA';
    END IF;

    COMMIT;

    SELECT *
    FROM vw_ot_resumen
    WHERE n_ot = p_n_ot
    LIMIT 1;
END$$

CREATE DEFINER=CURRENT_USER PROCEDURE `sp_ot_crear` (IN `p_n_ot` VARCHAR(30), IN `p_id_ai_area` INT, IN `p_id_user` VARCHAR(30), IN `p_id_ai_sitio` INT, IN `p_id_ai_estado` INT, IN `p_nombre_trab` VARCHAR(500), IN `p_fecha` DATE, IN `p_semana` VARCHAR(100), IN `p_mes` VARCHAR(100))   BEGIN
    DECLARE v_estado_id INT DEFAULT 0;
    DECLARE v_ot_existente INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF TRIM(COALESCE(p_n_ot, '')) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El numero de O.T. es obligatorio.';
    END IF;

    IF TRIM(COALESCE(p_id_user, '')) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario responsable es obligatorio.';
    END IF;

    IF TRIM(COALESCE(p_nombre_trab, '')) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre del trabajo es obligatorio.';
    END IF;

    SELECT COUNT(*) INTO v_ot_existente
    FROM orden_trabajo
    WHERE n_ot = p_n_ot
      AND std_reg = 1;

    IF v_ot_existente > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe una O.T. activa con ese codigo.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM area_trabajo WHERE id_ai_area = p_id_ai_area AND std_reg = 1) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El area de trabajo no existe o esta inactiva.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM sitio_trabajo WHERE id_ai_sitio = p_id_ai_sitio AND std_reg = 1) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El sitio de trabajo no existe o esta inactivo.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM user_system WHERE id_empleado = p_id_user AND std_reg = 1) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario responsable no existe o esta inactivo.';
    END IF;

    IF p_id_ai_estado IS NULL OR p_id_ai_estado <= 0 THEN
        SELECT id_ai_estado
          INTO v_estado_id
        FROM estado_ot
        WHERE std_reg = 1
          AND COALESCE(bloquea_ot, 0) = 0
        ORDER BY CASE
            WHEN UPPER(nombre_estado) = 'NO EJECUTADA' THEN 1
            WHEN UPPER(nombre_estado) = 'RE-PROGRAMADA' THEN 2
            WHEN UPPER(nombre_estado) = 'SUSPENDIDA' THEN 3
            ELSE 10
        END,
        id_ai_estado ASC
        LIMIT 1;
    ELSE
        SET v_estado_id = p_id_ai_estado;
    END IF;

    IF v_estado_id IS NULL OR v_estado_id <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No existe un estado inicial valido para la O.T.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM estado_ot WHERE id_ai_estado = v_estado_id AND std_reg = 1) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El estado seleccionado no existe o esta inactivo.';
    END IF;

    SET @app_user = p_id_user;

    START TRANSACTION;

    INSERT INTO orden_trabajo (
        n_ot, id_ai_area, id_user, id_ai_sitio, id_ai_estado,
        nombre_trab, fecha, semana, mes, ot_finalizada, std_reg
    ) VALUES (
        p_n_ot, p_id_ai_area, p_id_user, p_id_ai_sitio, v_estado_id,
        p_nombre_trab, COALESCE(p_fecha, CURDATE()), COALESCE(p_semana, ''), COALESCE(p_mes, ''), 0, 1
    );

    COMMIT;

    SELECT *
    FROM vw_ot_resumen
    WHERE n_ot = p_n_ot
    LIMIT 1;
END$$

CREATE DEFINER=CURRENT_USER PROCEDURE `sp_reporte_registrar_generado` (IN `p_tipo_reporte` VARCHAR(50), IN `p_titulo_reporte` VARCHAR(150), IN `p_nombre_archivo` VARCHAR(255), IN `p_ruta_archivo` VARCHAR(255), IN `p_mime_type` VARCHAR(100), IN `p_tamano_bytes` BIGINT, IN `p_parametros_json` LONGTEXT, IN `p_id_user_generador` VARCHAR(30))   BEGIN
    DECLARE v_nombre_empleado VARCHAR(150);
    DECLARE v_username VARCHAR(60);

    IF TRIM(COALESCE(p_tipo_reporte, '')) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El tipo de reporte es obligatorio.';
    END IF;

    IF TRIM(COALESCE(p_titulo_reporte, '')) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El titulo del reporte es obligatorio.';
    END IF;

    IF TRIM(COALESCE(p_nombre_archivo, '')) = '' OR TRIM(COALESCE(p_ruta_archivo, '')) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre y la ruta del archivo son obligatorios.';
    END IF;

    SELECT emp.nombre_empleado, us.username
      INTO v_nombre_empleado, v_username
    FROM empleado emp
    LEFT JOIN user_system us
      ON us.id_empleado = emp.id_empleado
     AND us.std_reg = 1
    WHERE emp.id_empleado = p_id_user_generador
      AND emp.std_reg = 1
    LIMIT 1;

    IF v_nombre_empleado IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario generador no existe o no esta vinculado a un empleado activo.';
    END IF;

    SET @app_user = p_id_user_generador;

    INSERT INTO reporte_generado (
        tipo_reporte,
        titulo_reporte,
        nombre_archivo,
        ruta_archivo,
        mime_type,
        tamano_bytes,
        parametros_json,
        id_user_generador,
        nombre_user_generador,
        username_generador,
        std_reg
    ) VALUES (
        p_tipo_reporte,
        p_titulo_reporte,
        p_nombre_archivo,
        p_ruta_archivo,
        COALESCE(NULLIF(TRIM(COALESCE(p_mime_type, '')), ''), 'application/pdf'),
        COALESCE(p_tamano_bytes, 0),
        p_parametros_json,
        p_id_user_generador,
        v_nombre_empleado,
        COALESCE(v_username, ''),
        1
    );

    SELECT *
    FROM vw_reportes_generados
    WHERE id_ai_reporte_generado = LAST_INSERT_ID()
    LIMIT 1;
END$$

CREATE DEFINER=CURRENT_USER PROCEDURE `sp_usuario_registrar_login_exitoso` (IN `p_id_empleado` VARCHAR(30), IN `p_ip` VARCHAR(45))   BEGIN
    IF TRIM(COALESCE(p_id_empleado, '')) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El id del usuario es obligatorio.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM user_system WHERE id_empleado = p_id_empleado AND std_reg = 1) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario no existe o esta inactivo.';
    END IF;

    SET @app_user = p_id_empleado;

    UPDATE user_system
       SET failed_login_attempts = 0,
           account_locked = 0,
           locked_at = NULL,
           password_reset_required = 0,
           last_login_at = NOW(),
           last_login_ip = NULLIF(TRIM(COALESCE(p_ip, '')), '')
     WHERE id_empleado = p_id_empleado
       AND std_reg = 1;

    SELECT id_empleado, username, failed_login_attempts, account_locked, password_reset_required, last_login_at, last_login_ip
    FROM user_system
    WHERE id_empleado = p_id_empleado
    LIMIT 1;
END$$

CREATE DEFINER=CURRENT_USER PROCEDURE `sp_usuario_registrar_login_fallido` (IN `p_username` VARCHAR(50), IN `p_ip` VARCHAR(45))   BEGIN
    DECLARE v_id_empleado VARCHAR(30) DEFAULT NULL;
    DECLARE v_intentos INT DEFAULT 0;
    DECLARE v_nuevo_intento INT DEFAULT 0;
    DECLARE v_bloqueado INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF TRIM(COALESCE(p_username, '')) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El username es obligatorio.';
    END IF;

    START TRANSACTION;

    SELECT id_empleado, COALESCE(failed_login_attempts, 0), COALESCE(account_locked, 0)
      INTO v_id_empleado, v_intentos, v_bloqueado
    FROM user_system
    WHERE username = p_username
      AND std_reg = 1
    LIMIT 1
    FOR UPDATE;

    IF v_id_empleado IS NULL THEN
        ROLLBACK;
        SELECT 0 AS usuario_encontrado, 0 AS bloqueado, 0 AS failed_login_attempts, NULL AS id_empleado;
    ELSE
        SET v_nuevo_intento = v_intentos + 1;
        SET @app_user = v_id_empleado;

        UPDATE user_system
           SET failed_login_attempts = v_nuevo_intento,
               account_locked = CASE WHEN v_nuevo_intento >= 3 THEN 1 ELSE account_locked END,
               locked_at = CASE WHEN v_nuevo_intento >= 3 THEN NOW() ELSE locked_at END,
               password_reset_required = CASE WHEN v_nuevo_intento >= 3 THEN 1 ELSE password_reset_required END,
               last_login_ip = NULLIF(TRIM(COALESCE(p_ip, '')), '')
         WHERE id_empleado = v_id_empleado
           AND std_reg = 1;

        COMMIT;

        SELECT 1 AS usuario_encontrado,
               CASE WHEN v_nuevo_intento >= 3 THEN 1 ELSE 0 END AS bloqueado,
               v_nuevo_intento AS failed_login_attempts,
               v_id_empleado AS id_empleado;
    END IF;
END$$
DELIMITER ;

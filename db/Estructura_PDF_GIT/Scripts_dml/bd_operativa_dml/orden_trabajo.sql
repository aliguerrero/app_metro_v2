-- Modulo: Scripts_dml
-- Archivo: orden_trabajo.sql
-- Funcion: reune las consultas y escrituras de datos asociadas a las ordenes de trabajo y sus vistas operativas.
-- Version: v_1.0

-- -----------------------------------------------------------------------------
-- Bloque 1. Carga maestra inicial
-- inserta los datos maestros base definidos para este objeto en el respaldo general del sistema.
-- -----------------------------------------------------------------------------
START TRANSACTION;
INSERT INTO `orden_trabajo` (`id_ai_ot`, `n_ot`, `id_ai_area`, `id_user`, `id_ai_sitio`, `id_ai_estado`, `nombre_trab`, `fecha`, `semana`, `mes`, `ot_finalizada`, `fecha_finalizacion`, `id_user_finaliza`, `std_reg`) VALUES
(1, 'VF-SEN-001', 1, '8840285', 2, 2, 'INSPECCION Y AJUSTE DE BALIZAS EN TRAMO SUR', '2026-03-16', '12', '3', 0, NULL, NULL, 1),
(2, 'VF-SEN-002', 1, '26580187', 5, 12, 'CALIBRACION DE CIRCUITO DE ANUNCIO EN ESTACION CEDENO', '2026-03-17', '12', '3', 0, NULL, NULL, 1),
(3, 'VF-APV-001', 2, '8840285', 1, 1, 'LUBRICACION Y AJUSTE DE CAMBIO 04 EN PATIO OPERACIONAL', '2026-03-18', '12', '3', 1, '2026-03-22 17:03:33', '8840285', 1),
(4, 'VF-APV-002', 2, '26580187', 3, 3, 'SUSTITUCION PROGRAMADA DE PERNOS EN DESVIO NORTE', '2026-03-19', '12', '3', 0, NULL, NULL, 1),
(5, 'VF-INF-001', 3, '8840285', 4, 2, 'CORRECCION DE FILTRACION EN CANALETA TECNICA', '2026-03-20', '12', '3', 0, NULL, NULL, 1),
(6, 'VF-INF-002', 3, '26580187', 2, 1, 'RESANE DE BORDE Y REPOSICION DE TAPAS DE REGISTRO EN ANDEN', '2026-03-21', '12', '3', 1, '2026-03-22 17:03:33', '26580187', 1),
(7, 'VF-NP-001', 5, '8840285', 1, 4, 'ATENCION DE FALLA EN TOMA DE ENERGIA DE TALLER LIGERO', '2026-03-21', '12', '3', 0, NULL, NULL, 1),
(8, 'VF-NP-002', 5, '26580187', 2, 2, 'REVISION DE GABINETE DE COMUNICACIONES POR ALARMA INTERMITENTE', '2026-03-22', '12', '3', 0, NULL, NULL, 1);
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 2. Bloque de modulo: estados_ot / actualizar
-- documenta la operacion 'actualizar' del modulo 'estados_ot' segun el codigo fuente indicado en app/controllers/estadoCrud.php.
-- -----------------------------------------------------------------------------
SELECT COUNT(1)
         FROM orden_trabajo
         WHERE id_ai_estado = :id
           AND std_reg = 1;

-- -----------------------------------------------------------------------------
-- Bloque 3. Bloque de modulo: ordenes_trabajo / actualizar
-- documenta la operacion 'actualizar' del modulo 'ordenes_trabajo' segun el codigo fuente indicado en app/controllers/otController.php -> modificarOtControlador.
-- -----------------------------------------------------------------------------
CALL sp_ot_actualizar(:n_ot, :id_ai_sitio, :nombre_trab, :fecha, :semana, :mes, :id_user_operacion);

-- -----------------------------------------------------------------------------
-- Bloque 4. Bloque de modulo: ordenes_trabajo / actualizar
-- documenta la operacion 'actualizar' del modulo 'ordenes_trabajo' segun el codigo fuente indicado en app/controllers/otController.php -> cambiarEstadoOtControlador.
-- -----------------------------------------------------------------------------
CALL sp_ot_cambiar_estado(:n_ot, :id_ai_estado, :id_user_operacion);

-- -----------------------------------------------------------------------------
-- Bloque 5. Bloque de modulo: ordenes_trabajo / buscar
-- documenta la operacion 'buscar' del modulo 'ordenes_trabajo' segun el codigo fuente indicado en app/controllers/cargarDatosOt.php.
-- -----------------------------------------------------------------------------
SELECT *,
            CASE
              WHEN COALESCE(ot_finalizada, 0) = 1 OR COALESCE(bloquea_ot, 0) = 1 THEN 1
              ELSE 0
            END AS ot_finalizada
     FROM vw_ot_resumen
     WHERE n_ot = :id
       AND std_reg = 1
     LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 6. Bloque de modulo: ordenes_trabajo / buscar
-- documenta la operacion 'buscar' del modulo 'ordenes_trabajo' segun el codigo fuente indicado en app/controllers/cargarDatosBuscadorOt.php.
-- -----------------------------------------------------------------------------
SELECT
        ot.n_ot,
        ot.fecha,
        ot.nombre_trab,
        ot.id_ai_estado,
        ot.nombre_estado,
        ot.color_estado AS color,
        COALESCE(ot.herramientas_activas, 0) AS herramientas_activas,
        CASE
            WHEN COALESCE(ot.ot_finalizada, 0) = 1 OR COALESCE(ot.bloquea_ot, 0) = 1 THEN 1
            ELSE 0
        END AS ot_finalizada,
        ot.area_nomeclatura
    FROM vw_ot_resumen ot
    WHERE ot.std_reg = 1
AND ot.n_ot = :id
AND ot.fecha BETWEEN :fecha_i AND :fecha_f
AND ot.area_nomeclatura = :area
AND ot.id_ai_estado = :estado
AND EXISTS (
            SELECT 1
            FROM vw_ot_detallada det
            WHERE det.n_ot = ot.n_ot
              AND det.id_user_act = :user
        )
ORDER BY ot.n_ot ASC;

-- -----------------------------------------------------------------------------
-- Bloque 7. Bloque de modulo: ordenes_trabajo / buscar
-- documenta la operacion 'buscar' del modulo 'ordenes_trabajo' segun el codigo fuente indicado en app/controllers/cargarDatosDetalle.php.
-- -----------------------------------------------------------------------------
SELECT n_ot, COALESCE(ot_finalizada, 0) AS ot_finalizada, id_ai_estado
         FROM orden_trabajo
         WHERE n_ot = :not
           AND std_reg = 1
         LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 8. Bloque de modulo: ordenes_trabajo / crear
-- documenta la operacion 'crear' del modulo 'ordenes_trabajo' segun el codigo fuente indicado en app/controllers/otController.php -> registrarOtControlador.
-- -----------------------------------------------------------------------------
SELECT n_ot FROM orden_trabajo WHERE n_ot = :n_ot;

-- -----------------------------------------------------------------------------
-- Bloque 9. Bloque de modulo: ordenes_trabajo / crear
-- documenta la operacion 'crear' del modulo 'ordenes_trabajo' segun el codigo fuente indicado en app/controllers/otController.php -> registrarOtControlador.
-- -----------------------------------------------------------------------------
CALL sp_ot_crear(:n_ot, :id_ai_area, :id_user, :id_ai_sitio, :id_ai_estado, :nombre_trab, :fecha, :semana, :mes);

-- -----------------------------------------------------------------------------
-- Bloque 10. Bloque de modulo: ordenes_trabajo / eliminar
-- documenta la operacion 'eliminar' del modulo 'ordenes_trabajo' segun el codigo fuente indicado en app/controllers/otController.php -> eliminarOtControlador.
-- -----------------------------------------------------------------------------
SELECT n_ot, nombre_trab
FROM orden_trabajo
WHERE n_ot = :id
  AND std_reg = '1'
LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 11. Bloque de modulo: ordenes_trabajo / eliminar
-- documenta la operacion 'eliminar' del modulo 'ordenes_trabajo' segun el codigo fuente indicado en app/controllers/otController.php -> eliminarOtControlador.
-- -----------------------------------------------------------------------------
CALL sp_ot_eliminar_logico(:n_ot, :id_user_operacion);

-- -----------------------------------------------------------------------------
-- Bloque 12. Bloque de modulo: ordenes_trabajo / listar
-- documenta la operacion 'listar' del modulo 'ordenes_trabajo' segun el codigo fuente indicado en app/controllers/otController.php -> listarOtControlador.
-- -----------------------------------------------------------------------------
SELECT
            n_ot,
            fecha,
            nombre_trab,
            id_ai_estado,
            nombre_estado,
            color_estado AS color,
            COALESCE(herramientas_activas, 0) AS herramientas_activas,
            CASE
              WHEN COALESCE(ot_finalizada, 0) = 1 OR COALESCE(bloquea_ot, 0) = 1 THEN 1
              ELSE 0
            END AS ot_finalizada
        FROM vw_ot_resumen
        WHERE std_reg = 1
        ORDER BY n_ot ASC;

-- -----------------------------------------------------------------------------
-- Bloque 13. Bloque de modulo: ordenes_trabajo / listar
-- documenta la operacion 'listar' del modulo 'ordenes_trabajo' segun el codigo fuente indicado en app/controllers/otController.php -> listarOtControlador.
-- -----------------------------------------------------------------------------
SELECT COUNT(1)
        FROM vw_ot_resumen
        WHERE std_reg = 1;

-- -----------------------------------------------------------------------------
-- Bloque 14. Bloque de modulo: ordenes_trabajo / listar
-- documenta la operacion 'listar' del modulo 'ordenes_trabajo' segun el codigo fuente indicado en app/controllers/otController.php -> listarDetalles.
-- -----------------------------------------------------------------------------
SELECT
        id_ai_detalle,
        n_ot,
        fecha_detalle AS fecha,
        descripcion,
        id_user_act,
        COALESCE(NULLIF(usuario_act_nombre, ''), id_user_act) AS user
      FROM vw_ot_detallada
      WHERE n_ot = :n_ot
      ORDER BY id_ai_detalle DESC;

-- -----------------------------------------------------------------------------
-- Bloque 15. Bloque de modulo: ordenes_trabajo / listar
-- documenta la operacion 'listar' del modulo 'ordenes_trabajo' segun el codigo fuente indicado en app/controllers/cargarDatosDetalles.php.
-- -----------------------------------------------------------------------------
SELECT
                    id_ai_detalle,
                    n_ot,
                    fecha_detalle AS fecha,
                    descripcion,
                    id_user_act,
                    COALESCE(NULLIF(usuario_act_nombre, ''), id_user_act) AS user
                 FROM vw_ot_detallada
                 WHERE n_ot = :not
                 ORDER BY fecha_detalle DESC, id_ai_detalle DESC;

-- -----------------------------------------------------------------------------
-- Bloque 16. Bloque de modulo: reportes / buscar
-- documenta la operacion 'buscar' del modulo 'reportes' segun el codigo fuente indicado en app/controllers/cargarDatosReporte.php.
-- -----------------------------------------------------------------------------
SELECT *
              FROM vw_ot_resumen
              WHERE n_ot = :id AND std_reg = 1
              LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 17. Bloque de modulo: reportes / buscar
-- documenta la operacion 'buscar' del modulo 'reportes' segun el codigo fuente indicado en app/controllers/cargarDatosReporte.php.
-- -----------------------------------------------------------------------------
SELECT
                    id_ai_detalle,
                    fecha_detalle AS fecha,
                    nombre_turno,
                    COALESCE(NULLIF(usuario_act_nombre, ''), id_user_act) AS tecnico_nombre,
                    miembro_cco_nombre AS cco_nombre,
                    miembro_ccf_nombre AS ccf_nombre,
                    descripcion,
                    hora_inicio,
                    hora_fin,
                    observacion
                  FROM vw_ot_detallada
                  WHERE n_ot = :id
                  ORDER BY id_ai_detalle ASC;

-- -----------------------------------------------------------------------------
-- Bloque 18. Bloque de modulo: reportes / extras
-- documenta la operacion 'extras' del modulo 'reportes' segun el codigo fuente indicado en app/controllers/reporteController.php -> renderOtHtml.
-- -----------------------------------------------------------------------------
SELECT
                fecha_detalle AS fecha,
                descripcion,
                observacion,
                cant_tec,
                hora_inicio,
                hora_fin,
                nombre_turno,
                miembro_cco_nombre AS cco_nombre,
                miembro_ccf_nombre AS ccf_nombre,
                COALESCE(NULLIF(usuario_act_nombre, ''), id_user_act) AS tecnico_nombre,
                username_usuario_act AS tecnico_username
              FROM vw_ot_detallada
              WHERE n_ot = :n_ot
              ORDER BY fecha_detalle ASC, id_ai_detalle ASC;


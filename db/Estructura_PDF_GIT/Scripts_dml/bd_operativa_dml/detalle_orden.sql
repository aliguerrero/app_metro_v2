-- Modulo: Scripts_dml
-- Archivo: detalle_orden.sql
-- Funcion: reune las consultas y escrituras de datos asociadas al detalle de cada orden de trabajo.
-- Version: v_1.0

-- -----------------------------------------------------------------------------
-- Bloque 1. Carga maestra inicial
-- inserta los datos maestros base definidos para este objeto en el respaldo general del sistema.
-- -----------------------------------------------------------------------------
START TRANSACTION;
INSERT INTO `detalle_orden` (`id_ai_detalle`, `n_ot`, `fecha`, `descripcion`, `id_ai_turno`, `id_miembro_cco`, `id_user_act`, `id_miembro_ccf`, `cant_tec`, `hora_inicio`, `hora_fin`, `observacion`) VALUES
(1, 'VF-SEN-001', '2026-03-16', 'Revision de conexionado, limpieza de borneras y ajuste de tres balizas de via en tramo sur.', 1, 'M-002', '8840285', 'M-001', 3, '07:30:00', '10:30:00', 'Trabajo coordinado con ventana de mantenimiento.'),
(2, 'VF-SEN-002', '2026-03-17', 'Prueba funcional del circuito de anuncio, verificacion de tarjetas y recalibracion de tiempos de enclavamiento.', 2, 'M-004', '26580187', 'M-003', 2, '13:00:00', '16:30:00', 'OT en seguimiento por pruebas operativas.'),
(3, 'VF-APV-001', '2026-03-18', 'Lubricacion de agujas, torque de fijaciones y verificacion de desplazamiento del cambio 04.', 1, 'M-006', '8840285', 'M-005', 4, '08:00:00', '11:30:00', 'Actividad completada sin novedades.'),
(4, 'VF-APV-002', '2026-03-19', 'Desmontaje parcial para reemplazo de pernos de sujecion; pendiente ingreso de repuesto.', 3, 'M-008', '26580187', 'M-007', 3, '20:00:00', '23:30:00', 'Reprogramada por falta de pernos calibre 7/8.'),
(5, 'VF-INF-001', '2026-03-20', 'Limpieza de drenaje, picado de zona afectada y resane con mortero de alta adherencia.', 1, 'M-002', '8840285', 'M-005', 3, '08:30:00', '12:00:00', 'Pendiente suministro de mortero epoxico.'),
(6, 'VF-INF-002', '2026-03-21', 'Reposicion de tapas, nivelacion de soporte y reparacion puntual de borde de anden.', 2, 'M-004', '26580187', 'M-007', 2, '14:00:00', '17:00:00', 'Se ejecuto conforme al plan de mantenimiento.'),
(7, 'VF-NP-001', '2026-03-21', 'Inspeccion de toma energizada y prueba de continuidad; se suspende por aislador fisurado.', 4, 'M-006', '8840285', 'M-003', 2, '05:30:00', '07:00:00', 'Suspension preventiva por componente aislante danado.'),
(8, 'VF-NP-002', '2026-03-22', 'Revision inicial del gabinete, lectura de alarmas y verificacion de voltajes en fuente secundaria.', 2, 'M-008', '26580187', 'M-001', 2, '13:30:00', '15:30:00', 'A la espera de ventana nocturna para intervencion.');
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 2. Bloque de modulo: ordenes_trabajo / actualizar
-- documenta la operacion 'actualizar' del modulo 'ordenes_trabajo' segun el codigo fuente indicado en app/controllers/otController.php -> cambiarEstadoOtControlador.
-- -----------------------------------------------------------------------------
SELECT COUNT(1)
         FROM detalle_orden
         WHERE n_ot = :n_ot;

-- -----------------------------------------------------------------------------
-- Bloque 3. Bloque de modulo: ordenes_trabajo / actualizar
-- documenta la operacion 'actualizar' del modulo 'ordenes_trabajo' segun el codigo fuente indicado en app/controllers/cargarDatosDetalle.php -> guardar (insert).
-- -----------------------------------------------------------------------------
CALL sp_ot_agregar_detalle(
            :not,
            :fecha,
            :desc,
            :turno,
            :cco,
            :tec,
            :ccf,
            :cant,
            :hora_inicio,
            :hora_fin,
            :obs
        );

-- -----------------------------------------------------------------------------
-- Bloque 4. Bloque de modulo: ordenes_trabajo / actualizar
-- documenta la operacion 'actualizar' del modulo 'ordenes_trabajo' segun el codigo fuente indicado en app/controllers/cargarDatosDetalle.php -> guardar (update).
-- -----------------------------------------------------------------------------
CALL sp_ot_actualizar_detalle(
            :id_ai_detalle,
            :not,
            :fecha,
            :desc,
            :turno,
            :cco,
            :tec,
            :ccf,
            :cant,
            :hora_inicio,
            :hora_fin,
            :obs,
            :id_user_operacion
        );

-- -----------------------------------------------------------------------------
-- Bloque 5. Bloque de modulo: ordenes_trabajo / eliminar
-- documenta la operacion 'eliminar' del modulo 'ordenes_trabajo' segun el codigo fuente indicado en app/controllers/cargarDatosDetalle.php -> eliminar.
-- -----------------------------------------------------------------------------
CALL sp_ot_eliminar_detalle(:id_ai_detalle, :not, :id_user_operacion);


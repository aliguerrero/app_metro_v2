-- Modulo: Scripts_dml
-- Archivo: herramienta_ot.sql
-- Funcion: reune las consultas y escrituras de datos asociadas a la asignacion de herramientas por orden de trabajo.
-- Version: v_1.0

-- -----------------------------------------------------------------------------
-- Bloque 1. Carga maestra inicial
-- inserta los datos maestros base definidos para este objeto en el respaldo general del sistema.
-- -----------------------------------------------------------------------------
START TRANSACTION;
INSERT INTO `herramientaot` (`id_ai_herramientaOT`, `id_ai_herramienta`, `n_ot`, `cantidadot`, `estado_herramientaot`) VALUES
(1, 4, 'VF-SEN-001', 1, 'ASIGNADA'),
(2, 5, 'VF-SEN-001', 1, 'ASIGNADA'),
(3, 10, 'VF-SEN-001', 3, 'ASIGNADA'),
(4, 7, 'VF-SEN-002', 1, 'ASIGNADA'),
(5, 10, 'VF-SEN-002', 2, 'ASIGNADA'),
(6, 11, 'VF-SEN-002', 1, 'ASIGNADA'),
(7, 1, 'VF-APV-001', 2, 'LIBERADA'),
(8, 2, 'VF-APV-001', 1, 'LIBERADA'),
(9, 10, 'VF-APV-001', 4, 'LIBERADA'),
(10, 10, 'VF-INF-001', 3, 'ASIGNADA'),
(11, 16, 'VF-INF-001', 1, 'ASIGNADA'),
(12, 6, 'VF-INF-002', 1, 'LIBERADA'),
(13, 7, 'VF-INF-002', 1, 'LIBERADA'),
(14, 10, 'VF-INF-002', 2, 'LIBERADA'),
(15, 4, 'VF-NP-002', 1, 'ASIGNADA'),
(16, 5, 'VF-NP-002', 1, 'ASIGNADA');
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 2. Bloque de modulo: ordenes_trabajo / buscar
-- documenta la operacion 'buscar' del modulo 'ordenes_trabajo' segun el codigo fuente indicado en app/controllers/cargarHerramientaOt.php.
-- -----------------------------------------------------------------------------
SELECT
        hot.id_ai_herramientaOT,
        hot.n_ot,
        h.nombre_herramienta,
        hot.cantidadot
     FROM herramientaot hot
     LEFT JOIN herramienta h ON hot.id_ai_herramienta = h.id_ai_herramienta
     ORDER BY hot.id_ai_herramientaOT;

-- -----------------------------------------------------------------------------
-- Bloque 3. Bloque de modulo: ordenes_trabajo / extras
-- documenta la operacion 'extras' del modulo 'ordenes_trabajo' segun el codigo fuente indicado en app/controllers/cargarHerramientasOt.php -> inventario.
-- -----------------------------------------------------------------------------
SELECT
                vhd.id_ai_herramienta AS id,
                vhd.nombre_herramienta AS nombre,
                vhd.cantidad_disponible AS disponible_total,
                COALESCE(otq.en_ot, 0) AS en_ot,
                vhd.cantidad_disponible AS disponible_para_agregar
            FROM vw_herramienta_disponibilidad vhd
            LEFT JOIN (
                SELECT id_ai_herramienta, SUM(cantidadot) AS en_ot
                FROM herramientaot
                WHERE n_ot = :ot
                  AND COALESCE(estado_herramientaot, 'ASIGNADA') <> 'LIBERADA'
                GROUP BY id_ai_herramienta
            ) otq ON vhd.id_ai_herramienta = otq.id_ai_herramienta;

-- -----------------------------------------------------------------------------
-- Bloque 4. Bloque de modulo: ordenes_trabajo / extras
-- documenta la operacion 'extras' del modulo 'ordenes_trabajo' segun el codigo fuente indicado en app/controllers/cargarHerramientasOt.php -> asignadas.
-- -----------------------------------------------------------------------------
SELECT
                hot.id_ai_herramienta AS id,
                h.nombre_herramienta AS nombre,
                SUM(hot.cantidadot) AS cantidad
            FROM herramientaot hot
            INNER JOIN herramienta h ON hot.id_ai_herramienta = h.id_ai_herramienta
            WHERE hot.n_ot = :ot
              AND COALESCE(hot.estado_herramientaot, 'ASIGNADA') <> 'LIBERADA'
            GROUP BY hot.id_ai_herramienta, h.nombre_herramienta;

-- -----------------------------------------------------------------------------
-- Bloque 5. Bloque de modulo: ordenes_trabajo / extras
-- documenta la operacion 'extras' del modulo 'ordenes_trabajo' segun el codigo fuente indicado en app/controllers/cargarHerramientasOt.php -> agregar.
-- -----------------------------------------------------------------------------
CALL sp_ot_asignar_herramienta(:ot, :hid, :cant, :id_user_operacion);

-- -----------------------------------------------------------------------------
-- Bloque 6. Bloque de modulo: ordenes_trabajo / extras
-- documenta la operacion 'extras' del modulo 'ordenes_trabajo' segun el codigo fuente indicado en app/controllers/cargarHerramientasOt.php -> actualizar/quitar.
-- -----------------------------------------------------------------------------
CALL sp_ot_set_herramienta_cantidad(:ot, :hid, :cant, :id_user_operacion);

-- -----------------------------------------------------------------------------
-- Bloque 7. Bloque de modulo: ordenes_trabajo / extras
-- documenta la operacion 'extras' del modulo 'ordenes_trabajo' segun el codigo fuente indicado en app/controllers/cargarDatosBuscadorHOT.php -> botones +/- en modal legacy.
-- -----------------------------------------------------------------------------
CALL sp_ot_ajustar_herramienta_delta(:not, :idher, :delta, :id_user_operacion);

-- -----------------------------------------------------------------------------
-- Bloque 8. Bloque de modulo: ordenes_trabajo / listar
-- documenta la operacion 'listar' del modulo 'ordenes_trabajo' segun el codigo fuente indicado en app/controllers/cargarDatosDetalles.php.
-- -----------------------------------------------------------------------------
SELECT COALESCE(SUM(cantidadot),0) AS ocupada
         FROM herramientaot
         WHERE id_ai_herramienta = :id
         FOR UPDATE;

-- -----------------------------------------------------------------------------
-- Bloque 9. Bloque de modulo: ordenes_trabajo / listar
-- documenta la operacion 'listar' del modulo 'ordenes_trabajo' segun el codigo fuente indicado en app/controllers/cargarDatosDetalles.php.
-- -----------------------------------------------------------------------------
SELECT id_ai_herramientaOT, cantidadot
         FROM herramientaot
         WHERE n_ot = :not AND id_ai_herramienta = :id
         LIMIT 1
         FOR UPDATE;

-- -----------------------------------------------------------------------------
-- Bloque 10. Bloque de modulo: reportes / extras
-- documenta la operacion 'extras' del modulo 'reportes' segun el codigo fuente indicado en app/controllers/reporteController.php -> renderOtHtml.
-- -----------------------------------------------------------------------------
SELECT
                `ho`.`id_ai_herramientaOT`, `ho`.`id_ai_herramienta`, `ho`.`n_ot`, `ho`.`cantidadot`, `ho`.`estado_herramientaot`,
                h.nombre_herramienta
              FROM herramientaot ho
              INNER JOIN herramienta h ON h.id_ai_herramienta = ho.id_ai_herramienta
              WHERE ho.n_ot = :n_ot
              ORDER BY ho.id_ai_herramientaOT ASC;


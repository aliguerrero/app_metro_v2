-- Modulo: Scripts_dml
-- Archivo: estado_orden_trabajo.sql
-- Funcion: reune las consultas y escrituras de datos asociadas a los estados de orden de trabajo.
-- Version: v_1.0

-- -----------------------------------------------------------------------------
-- Bloque 1. Carga maestra inicial
-- inserta los datos maestros base definidos para este objeto en el respaldo general del sistema.
-- -----------------------------------------------------------------------------
START TRANSACTION;
INSERT INTO `estado_ot` (`id_ai_estado`, `nombre_estado`, `color`, `libera_herramientas`, `bloquea_ot`, `std_reg`) VALUES
(1, 'EJECUTADA', '#25ef28', 1, 1, 1),
(2, 'NO EJECUTADA', '#dc3545', 0, 0, 1),
(3, 'RE-PROGRAMADA', '#0d6efd', 0, 0, 1),
(4, 'SUSPENDIDA', '#fd7e14', 0, 0, 1),
(12, 'EN EJECUCION', '#ffc107', 0, 0, 1);
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 2. Bloque de modulo: estados_ot / actualizar
-- documenta la operacion 'actualizar' del modulo 'estados_ot' segun el codigo fuente indicado en app/controllers/estadoCrud.php.
-- -----------------------------------------------------------------------------
SELECT id_ai_estado, nombre_estado, color,
                COALESCE(`libera_herramientas`, 0) AS libera_herramientas,
                COALESCE(`bloquea_ot`, 0) AS bloquea_ot,
                std_reg
         FROM estado_ot
         WHERE id_ai_estado = :id
         LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 3. Bloque de modulo: estados_ot / actualizar
-- documenta la operacion 'actualizar' del modulo 'estados_ot' segun el codigo fuente indicado en app/controllers/estadoCrud.php.
-- -----------------------------------------------------------------------------
SELECT COUNT(1)
            FROM estado_ot
            WHERE std_reg = 1
              AND COALESCE(`bloquea_ot`, 0) = 1
AND id_ai_estado <> :id;

-- -----------------------------------------------------------------------------
-- Bloque 4. Bloque de modulo: estados_ot / actualizar
-- documenta la operacion 'actualizar' del modulo 'estados_ot' segun el codigo fuente indicado en app/controllers/estadoCrud.php.
-- -----------------------------------------------------------------------------
SELECT id_ai_estado, std_reg
             FROM estado_ot
             WHERE UPPER(nombre_estado) = UPPER(:n)
             LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 5. Bloque de modulo: estados_ot / actualizar
-- documenta la operacion 'actualizar' del modulo 'estados_ot' segun el codigo fuente indicado en app/controllers/estadoCrud.php.
-- -----------------------------------------------------------------------------
START TRANSACTION;
UPDATE estado_ot
                     SET std_reg = 1, color = :c, libera_herramientas = :libera, bloquea_ot = :bloquea
                     WHERE id_ai_estado = :id
                     LIMIT 1;
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 6. Bloque de modulo: estados_ot / actualizar
-- documenta la operacion 'actualizar' del modulo 'estados_ot' segun el codigo fuente indicado en app/controllers/estadoCrud.php.
-- -----------------------------------------------------------------------------
START TRANSACTION;
UPDATE estado_ot
             SET nombre_estado = :n, color = :c, libera_herramientas = :libera, bloquea_ot = :bloquea
             WHERE id_ai_estado = :id;
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 7. Bloque de modulo: estados_ot / crear
-- documenta la operacion 'crear' del modulo 'estados_ot' segun el codigo fuente indicado en app/controllers/estadoCrud.php.
-- -----------------------------------------------------------------------------
START TRANSACTION;
INSERT INTO estado_ot (nombre_estado, color, libera_herramientas, bloquea_ot, std_reg)
             VALUES (:n, :c, :libera, :bloquea, 1);
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 8. Bloque de modulo: estados_ot / eliminar
-- documenta la operacion 'eliminar' del modulo 'estados_ot' segun el codigo fuente indicado en app/controllers/estadoCrud.php.
-- -----------------------------------------------------------------------------
START TRANSACTION;
UPDATE estado_ot
             SET std_reg = 0
             WHERE id_ai_estado = :id
             LIMIT 1;
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 9. Bloque de modulo: estados_ot / listar
-- documenta la operacion 'listar' del modulo 'estados_ot' segun el codigo fuente indicado en app/controllers/configController.php -> listarEstadoControlador.
-- -----------------------------------------------------------------------------
SELECT `id_ai_estado`, `nombre_estado`, `color`, `libera_herramientas`, `bloquea_ot`, `std_reg`,
                COALESCE(`libera_herramientas`, 0) AS libera_herramientas_estado,
                COALESCE(`bloquea_ot`, 0) AS bloquea_ot_estado
            FROM estado_ot
            WHERE std_reg='1'
            ORDER BY id_ai_estado ASC;

-- -----------------------------------------------------------------------------
-- Bloque 10. Bloque de modulo: estados_ot / listar
-- documenta la operacion 'listar' del modulo 'estados_ot' segun el codigo fuente indicado en app/controllers/configController.php -> listarEstadoControlador.
-- -----------------------------------------------------------------------------
SELECT COUNT(id_ai_estado) FROM estado_ot where std_reg='1';

-- -----------------------------------------------------------------------------
-- Bloque 11. Bloque de modulo: ordenes_trabajo / actualizar
-- documenta la operacion 'actualizar' del modulo 'ordenes_trabajo' segun el codigo fuente indicado en app/controllers/otController.php -> cambiarEstadoOtControlador.
-- -----------------------------------------------------------------------------
SELECT id_ai_estado, nombre_estado,
              COALESCE(`libera_herramientas`, 0) AS libera_herramientas,
              COALESCE(`bloquea_ot`, 0) AS bloquea_ot
       FROM estado_ot
       WHERE id_ai_estado = :id
         AND std_reg = 1
       LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 12. Bloque de modulo: ordenes_trabajo / extras
-- documenta la operacion 'extras' del modulo 'ordenes_trabajo' segun el codigo fuente indicado en app/controllers/otController.php -> listarComboEstadoControlador.
-- -----------------------------------------------------------------------------
SELECT id_ai_estado, nombre_estado,
      COALESCE(`libera_herramientas`, 0) AS libera_herramientas,
      COALESCE(`bloquea_ot`, 0) AS bloquea_ot
      FROM estado_ot
      WHERE std_reg=1
      ORDER BY id_ai_estado ASC;


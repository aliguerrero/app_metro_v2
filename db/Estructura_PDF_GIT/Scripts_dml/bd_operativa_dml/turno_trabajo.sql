-- Modulo: Scripts_dml
-- Archivo: turno_trabajo.sql
-- Funcion: reune las consultas y escrituras de datos asociadas a los turnos de trabajo.
-- Version: v_1.0

-- -----------------------------------------------------------------------------
-- Bloque 1. Carga maestra inicial
-- inserta los datos maestros base definidos para este objeto en el respaldo general del sistema.
-- -----------------------------------------------------------------------------
START TRANSACTION;
INSERT INTO `turno_trabajo` (`id_ai_turno`, `nombre_turno`, `std_reg`) VALUES
(1, 'MANANA', 1),
(2, 'TARDE', 1),
(3, 'NOCHE', 1),
(4, 'MADRUGADA', 1);
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 2. Bloque de modulo: ordenes_trabajo / extras
-- documenta la operacion 'extras' del modulo 'ordenes_trabajo' segun el codigo fuente indicado en app/controllers/otController.php -> listarComboTurnoControlador.
-- -----------------------------------------------------------------------------
SELECT id_ai_turno, nombre_turno FROM turno_trabajo WHERE std_reg=1;

-- -----------------------------------------------------------------------------
-- Bloque 3. Bloque de modulo: turnos_trabajo / actualizar
-- documenta la operacion 'actualizar' del modulo 'turnos_trabajo' segun el codigo fuente indicado en app/controllers/turnoCrud.php.
-- -----------------------------------------------------------------------------
SELECT COUNT(id_ai_turno) FROM turno_trabajo where std_reg = 1;

-- -----------------------------------------------------------------------------
-- Bloque 4. Bloque de modulo: turnos_trabajo / actualizar
-- documenta la operacion 'actualizar' del modulo 'turnos_trabajo' segun el codigo fuente indicado en app/controllers/turnoCrud.php.
-- -----------------------------------------------------------------------------
SELECT `id_ai_turno`, `nombre_turno`, `std_reg` FROM turno_trabajo WHERE id_ai_turno = :id LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 5. Bloque de modulo: turnos_trabajo / actualizar
-- documenta la operacion 'actualizar' del modulo 'turnos_trabajo' segun el codigo fuente indicado en app/controllers/turnoCrud.php.
-- -----------------------------------------------------------------------------
SELECT id_ai_turno, std_reg
         FROM turno_trabajo
         WHERE nombre_turno = :n
         LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 6. Bloque de modulo: turnos_trabajo / actualizar
-- documenta la operacion 'actualizar' del modulo 'turnos_trabajo' segun el codigo fuente indicado en app/controllers/turnoCrud.php.
-- -----------------------------------------------------------------------------
START TRANSACTION;
UPDATE turno_trabajo
                 SET std_reg = 1, nombre_turno = :n
                 WHERE id_ai_turno = :id
                 LIMIT 1;
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 7. Bloque de modulo: turnos_trabajo / actualizar
-- documenta la operacion 'actualizar' del modulo 'turnos_trabajo' segun el codigo fuente indicado en app/controllers/turnoCrud.php.
-- -----------------------------------------------------------------------------
START TRANSACTION;
UPDATE turno_trabajo SET nombre_turno = :n WHERE id_ai_turno = :id;
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 8. Bloque de modulo: turnos_trabajo / actualizar
-- documenta la operacion 'actualizar' del modulo 'turnos_trabajo' segun el codigo fuente indicado en app/controllers/turnoCrud.php.
-- -----------------------------------------------------------------------------
SELECT id_ai_turno, std_reg
         FROM turno_trabajo
         WHERE id_ai_turno = :id
         LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 9. Bloque de modulo: turnos_trabajo / crear
-- documenta la operacion 'crear' del modulo 'turnos_trabajo' segun el codigo fuente indicado en app/controllers/turnoCrud.php.
-- -----------------------------------------------------------------------------
START TRANSACTION;
INSERT INTO turno_trabajo (nombre_turno, std_reg)
         VALUES (:n, 1);
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 10. Bloque de modulo: turnos_trabajo / eliminar
-- documenta la operacion 'eliminar' del modulo 'turnos_trabajo' segun el codigo fuente indicado en app/controllers/turnoCrud.php.
-- -----------------------------------------------------------------------------
START TRANSACTION;
UPDATE turno_trabajo
         SET std_reg = 0
         WHERE id_ai_turno = :id
         LIMIT 1;
COMMIT;


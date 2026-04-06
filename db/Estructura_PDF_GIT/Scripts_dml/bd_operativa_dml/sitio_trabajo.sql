-- Modulo: Scripts_dml
-- Archivo: sitio_trabajo.sql
-- Funcion: reune las consultas y escrituras de datos asociadas a los sitios de trabajo.
-- Version: v_1.0

-- -----------------------------------------------------------------------------
-- Bloque 1. Carga maestra inicial
-- inserta los datos maestros base definidos para este objeto en el respaldo general del sistema.
-- -----------------------------------------------------------------------------
START TRANSACTION;
INSERT INTO `sitio_trabajo` (`id_ai_sitio`, `nombre_sitio`, `std_reg`) VALUES
(1, 'PATIO OPERACIONAL', 1),
(2, 'LINEA 1', 1),
(3, 'TALLER CENTRAL', 1),
(4, 'SUBESTACION SUR', 1),
(5, 'ESTACION CEDENO', 1);
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 2. Bloque de modulo: ordenes_trabajo / extras
-- documenta la operacion 'extras' del modulo 'ordenes_trabajo' segun el codigo fuente indicado en app/controllers/otController.php -> listarComboSitioControlador.
-- -----------------------------------------------------------------------------
SELECT id_ai_sitio, nombre_sitio FROM sitio_trabajo WHERE std_reg=1;

-- -----------------------------------------------------------------------------
-- Bloque 3. Bloque de modulo: sitios_trabajo / actualizar
-- documenta la operacion 'actualizar' del modulo 'sitios_trabajo' segun el codigo fuente indicado en app/controllers/sitioCrud.php.
-- -----------------------------------------------------------------------------
SELECT COUNT(id_ai_sitio) FROM sitio_trabajo where std_reg = 1;

-- -----------------------------------------------------------------------------
-- Bloque 4. Bloque de modulo: sitios_trabajo / actualizar
-- documenta la operacion 'actualizar' del modulo 'sitios_trabajo' segun el codigo fuente indicado en app/controllers/sitioCrud.php.
-- -----------------------------------------------------------------------------
SELECT `id_ai_sitio`, `nombre_sitio`, `std_reg` FROM sitio_trabajo WHERE id_ai_sitio = :id AND std_reg = 1 LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 5. Bloque de modulo: sitios_trabajo / actualizar
-- documenta la operacion 'actualizar' del modulo 'sitios_trabajo' segun el codigo fuente indicado en app/controllers/sitioCrud.php.
-- -----------------------------------------------------------------------------
SELECT id_ai_sitio, std_reg
         FROM sitio_trabajo
         WHERE nombre_sitio = :n
         LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 6. Bloque de modulo: sitios_trabajo / actualizar
-- documenta la operacion 'actualizar' del modulo 'sitios_trabajo' segun el codigo fuente indicado en app/controllers/sitioCrud.php.
-- -----------------------------------------------------------------------------
START TRANSACTION;
UPDATE sitio_trabajo
                 SET std_reg = 1, nombre_sitio = :n
                 WHERE id_ai_sitio = :id
                 LIMIT 1;
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 7. Bloque de modulo: sitios_trabajo / actualizar
-- documenta la operacion 'actualizar' del modulo 'sitios_trabajo' segun el codigo fuente indicado en app/controllers/sitioCrud.php.
-- -----------------------------------------------------------------------------
START TRANSACTION;
UPDATE sitio_trabajo SET nombre_sitio = :n WHERE id_ai_sitio = :id;
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 8. Bloque de modulo: sitios_trabajo / actualizar
-- documenta la operacion 'actualizar' del modulo 'sitios_trabajo' segun el codigo fuente indicado en app/controllers/sitioCrud.php.
-- -----------------------------------------------------------------------------
SELECT id_ai_sitio, std_reg
         FROM sitio_trabajo
         WHERE id_ai_sitio = :id
         LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 9. Bloque de modulo: sitios_trabajo / crear
-- documenta la operacion 'crear' del modulo 'sitios_trabajo' segun el codigo fuente indicado en app/controllers/sitioCrud.php.
-- -----------------------------------------------------------------------------
START TRANSACTION;
INSERT INTO sitio_trabajo (nombre_sitio, std_reg)
         VALUES (:n, 1);
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 10. Bloque de modulo: sitios_trabajo / eliminar
-- documenta la operacion 'eliminar' del modulo 'sitios_trabajo' segun el codigo fuente indicado en app/controllers/sitioCrud.php.
-- -----------------------------------------------------------------------------
START TRANSACTION;
UPDATE sitio_trabajo
         SET std_reg = 0
         WHERE id_ai_sitio = :id
         LIMIT 1;
COMMIT;


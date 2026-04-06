-- Modulo: Scripts_dml
-- Archivo: area_trabajo.sql
-- Funcion: reune las consultas y escrituras de datos asociadas a las areas de trabajo.
-- Version: v_1.0

-- -----------------------------------------------------------------------------
-- Bloque 1. Carga maestra inicial
-- inserta los datos maestros base definidos para este objeto en el respaldo general del sistema.
-- -----------------------------------------------------------------------------
START TRANSACTION;
INSERT INTO `area_trabajo` (`id_ai_area`, `nombre_area`, `nomeclatura`, `std_reg`) VALUES
(1, 'SENALIZACION', 'VF-SEN-', 1),
(2, 'APARATO DE VIA', 'VF-APV-', 1),
(3, 'INFRAESTRUCTURA', 'VF-INF-', 1),
(5, 'NO PROGRAMADA', 'VF-NP-', 1);
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 2. Bloque de modulo: areas / actualizar
-- documenta la operacion 'actualizar' del modulo 'areas' segun el codigo fuente indicado en app/controllers/areaCrud.php.
-- -----------------------------------------------------------------------------
SELECT `id_ai_area`, `nombre_area`, `nomeclatura`, `std_reg` FROM area_trabajo WHERE id_ai_area = :id AND std_reg = 1 LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 3. Bloque de modulo: areas / actualizar
-- documenta la operacion 'actualizar' del modulo 'areas' segun el codigo fuente indicado en app/controllers/areaCrud.php.
-- -----------------------------------------------------------------------------
SELECT id_ai_area, std_reg
         FROM area_trabajo
         WHERE nomeclatura = :no OR nombre_area = :n
         LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 4. Bloque de modulo: areas / actualizar
-- documenta la operacion 'actualizar' del modulo 'areas' segun el codigo fuente indicado en app/controllers/areaCrud.php.
-- -----------------------------------------------------------------------------
START TRANSACTION;
UPDATE area_trabajo
                 SET std_reg = 1, nombre_area = :n, nomeclatura = :no
                 WHERE id_ai_area = :id
                 LIMIT 1;
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 5. Bloque de modulo: areas / actualizar
-- documenta la operacion 'actualizar' del modulo 'areas' segun el codigo fuente indicado en app/controllers/areaCrud.php.
-- -----------------------------------------------------------------------------
START TRANSACTION;
UPDATE area_trabajo SET nombre_area = :n, nomeclatura = :no WHERE id_ai_area = :id;
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 6. Bloque de modulo: areas / actualizar
-- documenta la operacion 'actualizar' del modulo 'areas' segun el codigo fuente indicado en app/controllers/areaCrud.php.
-- -----------------------------------------------------------------------------
SELECT id_ai_area, std_reg
         FROM area_trabajo
         WHERE id_ai_area = :id
         LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 7. Bloque de modulo: areas / crear
-- documenta la operacion 'crear' del modulo 'areas' segun el codigo fuente indicado en app/controllers/areaCrud.php.
-- -----------------------------------------------------------------------------
START TRANSACTION;
INSERT INTO area_trabajo (nombre_area, nomeclatura, std_reg)
         VALUES (:n, :no, 1);
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 8. Bloque de modulo: areas / eliminar
-- documenta la operacion 'eliminar' del modulo 'areas' segun el codigo fuente indicado en app/controllers/areaCrud.php.
-- -----------------------------------------------------------------------------
START TRANSACTION;
UPDATE area_trabajo
         SET std_reg = 0
         WHERE id_ai_area = :id
         LIMIT 1;
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 9. Bloque de modulo: areas / listar
-- documenta la operacion 'listar' del modulo 'areas' segun el codigo fuente indicado en app/controllers/configController.php -> listarAreaControlador.
-- -----------------------------------------------------------------------------
SELECT `id_ai_area`, `nombre_area`, `nomeclatura`, `std_reg` FROM area_trabajo WHERE std_reg='1' ORDER BY id_ai_area ASC;

-- -----------------------------------------------------------------------------
-- Bloque 10. Bloque de modulo: areas / listar
-- documenta la operacion 'listar' del modulo 'areas' segun el codigo fuente indicado en app/controllers/configController.php -> listarAreaControlador.
-- -----------------------------------------------------------------------------
SELECT COUNT(id_ai_area) FROM area_trabajo where std_reg='1';

-- -----------------------------------------------------------------------------
-- Bloque 11. Bloque de modulo: ordenes_trabajo / crear
-- documenta la operacion 'crear' del modulo 'ordenes_trabajo' segun el codigo fuente indicado en app/controllers/otController.php -> registrarOtControlador.
-- -----------------------------------------------------------------------------
SELECT `id_ai_area`, `nombre_area`, `nomeclatura`, `std_reg` FROM area_trabajo WHERE nomeclatura = :area LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 12. Bloque de modulo: ordenes_trabajo / extras
-- documenta la operacion 'extras' del modulo 'ordenes_trabajo' segun el codigo fuente indicado en app/controllers/otController.php -> listarComboAreaControlador.
-- -----------------------------------------------------------------------------
SELECT id_ai_area, nombre_area, nomeclatura FROM area_trabajo WHERE std_reg=1;


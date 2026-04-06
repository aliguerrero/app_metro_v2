-- Modulo: Scripts_dml
-- Archivo: categoria_herramienta.sql
-- Funcion: reune las consultas y escrituras de datos asociadas a las categorias de herramienta.
-- Version: v_1.0

-- -----------------------------------------------------------------------------
-- Bloque 1. Carga maestra inicial
-- inserta los datos maestros base definidos para este objeto en el respaldo general del sistema.
-- -----------------------------------------------------------------------------
START TRANSACTION;
INSERT INTO `categoria_herramienta` (`id_ai_categoria_herramienta`, `nombre_categoria`, `descripcion`, `std_reg`) VALUES
(1, 'HERRAMIENTAS MANUALES', 'Herramientas de uso mecanico y de ajuste general en campo.', 1),
(2, 'MEDICION Y DIAGNOSTICO', 'Instrumentos para medicion electrica, continuidad y verificacion tecnica.', 1),
(3, 'EQUIPOS ELECTRICOS', 'Equipos electricos portatiles para perforacion, corte y apoyo operativo.', 1),
(4, 'SEGURIDAD INDUSTRIAL', 'Dotacion de proteccion personal y apoyo para trabajo seguro.', 1),
(5, 'SOLDADURA Y CORTE', 'Equipos para soldadura, corte y adecuacion metalmecanica.', 1);
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 2. Bloque de modulo: categorias_herramienta / actualizar
-- documenta la operacion 'actualizar' del modulo 'categorias_herramienta' segun el codigo fuente indicado en app/controllers/categoriaHerramientaCrud.php.
-- -----------------------------------------------------------------------------
SELECT id_ai_categoria_herramienta, std_reg
             FROM categoria_herramienta
             WHERE nombre_categoria = :nombre
             LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 3. Bloque de modulo: categorias_herramienta / actualizar
-- documenta la operacion 'actualizar' del modulo 'categorias_herramienta' segun el codigo fuente indicado en app/controllers/categoriaHerramientaCrud.php.
-- -----------------------------------------------------------------------------
START TRANSACTION;
UPDATE categoria_herramienta
                     SET nombre_categoria = :nombre,
                         descripcion = :descripcion,
                         std_reg = 1
                     WHERE id_ai_categoria_herramienta = :id;
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 4. Bloque de modulo: categorias_herramienta / actualizar
-- documenta la operacion 'actualizar' del modulo 'categorias_herramienta' segun el codigo fuente indicado en app/controllers/categoriaHerramientaCrud.php.
-- -----------------------------------------------------------------------------
SELECT 1
             FROM categoria_herramienta
             WHERE nombre_categoria = :nombre
               AND id_ai_categoria_herramienta <> :id
             LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 5. Bloque de modulo: categorias_herramienta / actualizar
-- documenta la operacion 'actualizar' del modulo 'categorias_herramienta' segun el codigo fuente indicado en app/controllers/categoriaHerramientaCrud.php.
-- -----------------------------------------------------------------------------
START TRANSACTION;
UPDATE categoria_herramienta
             SET nombre_categoria = :nombre,
                 descripcion = :descripcion
             WHERE id_ai_categoria_herramienta = :id;
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 6. Bloque de modulo: categorias_herramienta / crear
-- documenta la operacion 'crear' del modulo 'categorias_herramienta' segun el codigo fuente indicado en app/controllers/categoriaHerramientaCrud.php.
-- -----------------------------------------------------------------------------
START TRANSACTION;
INSERT INTO categoria_herramienta (nombre_categoria, descripcion, std_reg)
             VALUES (:nombre, :descripcion, 1);
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 7. Bloque de modulo: categorias_herramienta / eliminar
-- documenta la operacion 'eliminar' del modulo 'categorias_herramienta' segun el codigo fuente indicado en app/controllers/categoriaHerramientaCrud.php.
-- -----------------------------------------------------------------------------
START TRANSACTION;
UPDATE categoria_herramienta
             SET std_reg = 0
             WHERE id_ai_categoria_herramienta = :id;
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 8. Bloque de modulo: categorias_herramienta / listar
-- documenta la operacion 'listar' del modulo 'categorias_herramienta' segun el codigo fuente indicado en app/controllers/herramientaController.php -> listarCategoriaHerramientaControlador.
-- -----------------------------------------------------------------------------
SELECT
                c.id_ai_categoria_herramienta,
                c.nombre_categoria,
                c.descripcion,
                COUNT(h.id_ai_herramienta) AS total_herramientas
             FROM categoria_herramienta c
             LEFT JOIN herramienta h
               ON h.id_ai_categoria_herramienta = c.id_ai_categoria_herramienta
              AND h.std_reg = 1
             WHERE c.std_reg = 1
             GROUP BY c.id_ai_categoria_herramienta, c.nombre_categoria, c.descripcion
             ORDER BY c.nombre_categoria ASC;


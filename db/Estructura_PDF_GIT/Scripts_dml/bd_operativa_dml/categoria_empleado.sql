-- Modulo: Scripts_dml
-- Archivo: categoria_empleado.sql
-- Funcion: reune las consultas y escrituras de datos asociadas a las categorias de empleado.
-- Version: v_1.0

-- -----------------------------------------------------------------------------
-- Bloque 1. Carga maestra inicial
-- inserta los datos maestros base definidos para este objeto en el respaldo general del sistema.
-- -----------------------------------------------------------------------------
START TRANSACTION;
INSERT INTO `categoria_empleado` (`id_ai_categoria_empleado`, `nombre_categoria`, `descripcion`, `std_reg`) VALUES
(1, 'COORDINACION OPERATIVA', 'Personal responsable de la coordinacion general y seguimiento de mantenimiento.', 1),
(2, 'SUPERVISION DE MANTENIMIENTO', 'Supervisores responsables de planificar y validar la ejecucion de trabajos.', 1),
(3, 'TECNICO DE MANTENIMIENTO', 'Tecnicos que ejecutan actividades de campo y atienden incidencias operativas.', 1),
(4, 'OPERADOR CCF', 'Personal de apoyo operativo asignado al Centro de Control de Fallas.', 1),
(5, 'OPERADOR CCO', 'Personal de apoyo operativo asignado al Centro de Control de Operaciones.', 1);
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 2. Bloque de modulo: autenticacion / buscar
-- documenta la operacion 'buscar' del modulo 'autenticacion' segun el codigo fuente indicado en app/controllers/loginController.php -> asegurarCategoriaRoot.
-- -----------------------------------------------------------------------------
SELECT id_ai_categoria_empleado, std_reg
             FROM categoria_empleado
             WHERE nombre_categoria = :nombre
             LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 3. Bloque de modulo: autenticacion / buscar
-- documenta la operacion 'buscar' del modulo 'autenticacion' segun el codigo fuente indicado en app/controllers/loginController.php -> asegurarCategoriaRoot.
-- -----------------------------------------------------------------------------
START TRANSACTION;
UPDATE categoria_empleado
                     SET descripcion = :descripcion,
                         std_reg = 1
                     WHERE id_ai_categoria_empleado = :id;
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 4. Bloque de modulo: autenticacion / buscar
-- documenta la operacion 'buscar' del modulo 'autenticacion' segun el codigo fuente indicado en app/controllers/loginController.php -> asegurarCategoriaRoot.
-- -----------------------------------------------------------------------------
START TRANSACTION;
INSERT INTO categoria_empleado (nombre_categoria, descripcion, std_reg)
             VALUES (:nombre, :descripcion, 1);
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 5. Bloque de modulo: autenticacion / buscar
-- documenta la operacion 'buscar' del modulo 'autenticacion' segun el codigo fuente indicado en app/controllers/loginController.php -> asegurarCategoriaRoot.
-- -----------------------------------------------------------------------------
SELECT id_ai_categoria_empleado
             FROM categoria_empleado
             WHERE nombre_categoria = :nombre
             ORDER BY id_ai_categoria_empleado DESC
             LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 6. Bloque de modulo: categorias_empleado / actualizar
-- documenta la operacion 'actualizar' del modulo 'categorias_empleado' segun el codigo fuente indicado en app/controllers/categoriaEmpleadoCrud.php.
-- -----------------------------------------------------------------------------
START TRANSACTION;
UPDATE categoria_empleado
                     SET nombre_categoria = :nombre,
                         descripcion = :descripcion,
                         std_reg = 1
                     WHERE id_ai_categoria_empleado = :id;
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 7. Bloque de modulo: categorias_empleado / actualizar
-- documenta la operacion 'actualizar' del modulo 'categorias_empleado' segun el codigo fuente indicado en app/controllers/categoriaEmpleadoCrud.php.
-- -----------------------------------------------------------------------------
SELECT 1
             FROM categoria_empleado
             WHERE nombre_categoria = :nombre
               AND id_ai_categoria_empleado <> :id
             LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 8. Bloque de modulo: categorias_empleado / actualizar
-- documenta la operacion 'actualizar' del modulo 'categorias_empleado' segun el codigo fuente indicado en app/controllers/categoriaEmpleadoCrud.php.
-- -----------------------------------------------------------------------------
START TRANSACTION;
UPDATE categoria_empleado
             SET nombre_categoria = :nombre,
                 descripcion = :descripcion
             WHERE id_ai_categoria_empleado = :id;
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 9. Bloque de modulo: categorias_empleado / eliminar
-- documenta la operacion 'eliminar' del modulo 'categorias_empleado' segun el codigo fuente indicado en app/controllers/categoriaEmpleadoCrud.php.
-- -----------------------------------------------------------------------------
START TRANSACTION;
UPDATE categoria_empleado
             SET std_reg = 0
             WHERE id_ai_categoria_empleado = :id;
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 10. Bloque de modulo: categorias_empleado / listar
-- documenta la operacion 'listar' del modulo 'categorias_empleado' segun el codigo fuente indicado en app/controllers/empleadoController.php -> listarCategoriaEmpleadoControlador.
-- -----------------------------------------------------------------------------
SELECT
                c.id_ai_categoria_empleado,
                c.nombre_categoria,
                c.descripcion,
                COUNT(e.id_ai_empleado) AS total_empleados
             FROM categoria_empleado c
             LEFT JOIN empleado e
               ON e.id_ai_categoria_empleado = c.id_ai_categoria_empleado
              AND e.std_reg = 1
             WHERE c.std_reg = 1
             GROUP BY c.id_ai_categoria_empleado, c.nombre_categoria, c.descripcion
             ORDER BY c.nombre_categoria ASC;


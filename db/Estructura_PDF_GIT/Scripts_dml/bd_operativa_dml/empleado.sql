-- Modulo: Scripts_dml
-- Archivo: empleado.sql
-- Funcion: reune las consultas y escrituras de datos asociadas a los empleados.
-- Version: v_1.0

-- -----------------------------------------------------------------------------
-- Bloque 1. Carga maestra inicial
-- inserta los datos maestros base definidos para este objeto en el respaldo general del sistema.
-- -----------------------------------------------------------------------------
START TRANSACTION;
INSERT INTO `empleado` (`id_ai_empleado`, `id_empleado`, `nacionalidad`, `nombre_empleado`, `telefono`, `direccion`, `correo`, `id_ai_categoria_empleado`, `std_reg`) VALUES
(1, '22206460', 'V', 'ALI GUERRERO', '0412-8251111', 'LOS CAOBOS - VALENCIA', 'aliguerrero102@gmail.com', 1, 1),
(2, '8840285', 'V', 'MANUEL ALZURUTT', '04129357834', 'CENTRO - VALENCIA', 'manuelalzurutt@gmail.com', 2, 1),
(3, '26580187', 'V', 'WALTER RAMONE', '04128453283', 'LAS PALMAS - VALENCIA', 'walramone@gmail.com', 3, 1),
(4, '30114567', 'V', 'CARLA MENDOZA', '0412-5184401', 'SAN BLAS - VALENCIA', 'carla.mendoza@metrovalencia.local', 4, 1),
(5, '29654781', 'V', 'JOSE PENA', '0414-6883210', 'PARQUE VALENCIA - VALENCIA', 'jose.pena@metrovalencia.local', 5, 1),
(6, '31890245', 'V', 'LUIS RAMIREZ', '0412-5441188', 'FLOR AMARILLO - VALENCIA', 'luis.ramirez@metrovalencia.local', 4, 1),
(7, '28765431', 'V', 'MARIA FERNANDEZ', '0424-6013359', 'LA ISABELICA - VALENCIA', 'maria.fernandez@metrovalencia.local', 5, 1),
(8, '27411890', 'V', 'ANDRES PEREZ', '0414-6092271', 'SANTA ROSA - VALENCIA', 'andres.perez@metrovalencia.local', 4, 1),
(9, '29987456', 'V', 'DIANA RODRIGUEZ', '0412-7712240', 'LA CANDELARIA - VALENCIA', 'diana.rodriguez@metrovalencia.local', 5, 1),
(10, '31244780', 'V', 'OSCAR SALAZAR', '0424-7731180', 'LOS COLORADOS - VALENCIA', 'oscar.salazar@metrovalencia.local', 4, 1),
(11, '30599871', 'V', 'ELIANA TORRES', '0414-5513072', 'NAGUANAGUA - CARABOBO', 'eliana.torres@metrovalencia.local', 5, 1);
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 2. Bloque de modulo: autenticacion / buscar
-- documenta la operacion 'buscar' del modulo 'autenticacion' segun el codigo fuente indicado en app/controllers/loginController.php -> registrarPrimerUsuarioRootControlador.
-- -----------------------------------------------------------------------------
SELECT id_ai_empleado
                 FROM empleado
                 WHERE id_empleado = :id_empleado
                 LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 3. Bloque de modulo: autenticacion / buscar
-- documenta la operacion 'buscar' del modulo 'autenticacion' segun el codigo fuente indicado en app/controllers/loginController.php -> registrarPrimerUsuarioRootControlador.
-- -----------------------------------------------------------------------------
START TRANSACTION;
UPDATE empleado
                     SET nacionalidad = :nacionalidad,
                         nombre_empleado = :nombre_empleado,
                         telefono = :telefono,
                         direccion = :direccion,
                         correo = :correo,
                         id_ai_categoria_empleado = :categoria,
                         std_reg = 1
                     WHERE id_empleado = :id_empleado;
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 4. Bloque de modulo: autenticacion / buscar
-- documenta la operacion 'buscar' del modulo 'autenticacion' segun el codigo fuente indicado en app/controllers/loginController.php -> registrarPrimerUsuarioRootControlador.
-- -----------------------------------------------------------------------------
START TRANSACTION;
INSERT INTO empleado (
                        id_empleado,
                        nacionalidad,
                        nombre_empleado,
                        telefono,
                        direccion,
                        correo,
                        id_ai_categoria_empleado,
                        std_reg
                     ) VALUES (
                        :id_empleado,
                        :nacionalidad,
                        :nombre_empleado,
                        :telefono,
                        :direccion,
                        :correo,
                        :categoria,
                        1
                     );
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 5. Bloque de modulo: categorias_empleado / actualizar
-- documenta la operacion 'actualizar' del modulo 'categorias_empleado' segun el codigo fuente indicado en app/controllers/categoriaEmpleadoCrud.php.
-- -----------------------------------------------------------------------------
SELECT COUNT(1) FROM empleado
             WHERE id_ai_categoria_empleado = :id
               AND std_reg = 1;

-- -----------------------------------------------------------------------------
-- Bloque 6. Bloque de modulo: empleados / actualizar
-- documenta la operacion 'actualizar' del modulo 'empleados' segun el codigo fuente indicado en app/controllers/empleadoCrud.php.
-- -----------------------------------------------------------------------------
SELECT id_ai_empleado, std_reg
                 FROM empleado
                 WHERE id_empleado = :id
                 LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 7. Bloque de modulo: empleados / actualizar
-- documenta la operacion 'actualizar' del modulo 'empleados' segun el codigo fuente indicado en app/controllers/empleadoCrud.php.
-- -----------------------------------------------------------------------------
START TRANSACTION;
UPDATE empleado
                         SET nacionalidad = :nacionalidad,
                             nombre_empleado = :nombre,
                             telefono = :telefono,
                             direccion = :direccion,
                             correo = :correo,
                             id_ai_categoria_empleado = :categoria,
                             std_reg = 1
                         WHERE id_ai_empleado = :id;
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 8. Bloque de modulo: empleados / actualizar
-- documenta la operacion 'actualizar' del modulo 'empleados' segun el codigo fuente indicado en app/controllers/empleadoCrud.php.
-- -----------------------------------------------------------------------------
SELECT 1
                 FROM empleado
                 WHERE id_empleado = :id
                   AND id_ai_empleado <> :pk
                 LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 9. Bloque de modulo: empleados / actualizar
-- documenta la operacion 'actualizar' del modulo 'empleados' segun el codigo fuente indicado en app/controllers/empleadoCrud.php.
-- -----------------------------------------------------------------------------
START TRANSACTION;
UPDATE empleado
                 SET id_empleado = :idEmpleado,
                     nacionalidad = :nacionalidad,
                     nombre_empleado = :nombre,
                     telefono = :telefono,
                     direccion = :direccion,
                     correo = :correo,
                     id_ai_categoria_empleado = :categoria
                 WHERE id_ai_empleado = :pk;
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 10. Bloque de modulo: empleados / crear
-- documenta la operacion 'crear' del modulo 'empleados' segun el codigo fuente indicado en app/controllers/empleadoCrud.php.
-- -----------------------------------------------------------------------------
START TRANSACTION;
INSERT INTO empleado (
                    id_empleado,
                    nacionalidad,
                    nombre_empleado,
                    telefono,
                    direccion,
                    correo,
                    id_ai_categoria_empleado,
                    std_reg
                 ) VALUES (
                    :id,
                    :nacionalidad,
                    :nombre,
                    :telefono,
                    :direccion,
                    :correo,
                    :categoria,
                    1
                 );
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 11. Bloque de modulo: empleados / eliminar
-- documenta la operacion 'eliminar' del modulo 'empleados' segun el codigo fuente indicado en app/controllers/empleadoCrud.php.
-- -----------------------------------------------------------------------------
START TRANSACTION;
UPDATE empleado
                 SET std_reg = 0
                 WHERE id_ai_empleado = :id;
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 12. Bloque de modulo: empleados / listar
-- documenta la operacion 'listar' del modulo 'empleados' segun el codigo fuente indicado en app/controllers/empleadoController.php -> listarEmpleadoControlador.
-- -----------------------------------------------------------------------------
SELECT
                e.id_ai_empleado,
                e.id_empleado,
                e.nacionalidad,
                e.nombre_empleado,
                e.telefono,
                e.correo,
                e.direccion,
                COALESCE(c.nombre_categoria, 'SIN CATEGORIA') AS nombre_categoria,
                CASE
                    WHEN u.id_ai_user IS NULL THEN 'NO ASOCIADO'
                    ELSE CONCAT('@', u.username)
                END AS usuario_sistema
             FROM empleado e
             LEFT JOIN categoria_empleado c
               ON c.id_ai_categoria_empleado = e.id_ai_categoria_empleado
             LEFT JOIN user_system u
               ON u.id_empleado = e.id_empleado
              AND u.std_reg = 1
             WHERE e.std_reg = 1
             ORDER BY e.nombre_empleado ASC;

-- -----------------------------------------------------------------------------
-- Bloque 13. Bloque de modulo: miembros / actualizar
-- documenta la operacion 'actualizar' del modulo 'miembros' segun el codigo fuente indicado en app/controllers/miembroController.php -> obtenerEmpleadoActivo.
-- -----------------------------------------------------------------------------
SELECT
                e.id_empleado,
                e.nacionalidad,
                e.nombre_empleado,
                COALESCE(NULLIF(e.telefono, ''), '') AS telefono,
                COALESCE(NULLIF(e.correo, ''), '') AS correo
             FROM empleado e
             WHERE e.id_empleado = :id_empleado
               AND e.std_reg = 1
             LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 14. Bloque de modulo: usuarios / actualizar
-- documenta la operacion 'actualizar' del modulo 'usuarios' segun el codigo fuente indicado en app/controllers/userController.php -> obtenerEmpleadoActivo.
-- -----------------------------------------------------------------------------
SELECT
                e.id_ai_empleado,
                e.id_empleado,
                e.nombre_empleado,
                e.id_ai_categoria_empleado,
                e.std_reg,
                COALESCE(c.nombre_categoria, 'SIN CATEGORIA') AS nombre_categoria
             FROM empleado e
             LEFT JOIN categoria_empleado c
               ON c.id_ai_categoria_empleado = e.id_ai_categoria_empleado
             WHERE e.id_empleado = :id
               AND e.std_reg = 1
             LIMIT 1;


-- Modulo: Scripts_dml
-- Archivo: miembro.sql
-- Funcion: reune las consultas y escrituras de datos asociadas a los miembros operativos.
-- Version: v_1.0

-- -----------------------------------------------------------------------------
-- Bloque 1. Carga maestra inicial
-- inserta los datos maestros base definidos para este objeto en el respaldo general del sistema.
-- -----------------------------------------------------------------------------
START TRANSACTION;
INSERT INTO `miembro` (`id_ai_miembro`, `id_miembro`, `id_empleado`, `nombre_miembro`, `tipo_miembro`, `std_reg`) VALUES
(1, 'M-001', '30114567', 'CARLA MENDOZA', 1, 1),
(2, 'M-002', '29654781', 'JOSE PENA', 2, 1),
(3, 'M-003', '31890245', 'LUIS RAMIREZ', 1, 1),
(4, 'M-004', '28765431', 'MARIA FERNANDEZ', 2, 1),
(5, 'M-005', '27411890', 'ANDRES PEREZ', 1, 1),
(6, 'M-006', '29987456', 'DIANA RODRIGUEZ', 2, 1),
(7, 'M-007', '31244780', 'OSCAR SALAZAR', 1, 1),
(8, 'M-008', '30599871', 'ELIANA TORRES', 2, 1);
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 2. Bloque de modulo: miembros / actualizar
-- documenta la operacion 'actualizar' del modulo 'miembros' segun el codigo fuente indicado en app/controllers/miembroController.php -> obtenerMiembroPorCodigo.
-- -----------------------------------------------------------------------------
SELECT
                m.id_ai_miembro,
                m.id_miembro,
                m.id_empleado,
                m.nombre_miembro,
                m.tipo_miembro,
                m.std_reg
             FROM miembro m
             WHERE m.id_miembro = :id_miembro
             LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 3. Bloque de modulo: miembros / actualizar
-- documenta la operacion 'actualizar' del modulo 'miembros' segun el codigo fuente indicado en app/controllers/miembroController.php -> obtenerMiembroPorEmpleado.
-- -----------------------------------------------------------------------------
SELECT
                m.id_ai_miembro,
                m.id_miembro,
                m.id_empleado,
                m.nombre_miembro,
                m.tipo_miembro,
                m.std_reg
             FROM miembro m
             WHERE m.id_empleado = :id_empleado
             LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 4. Bloque de modulo: miembros / actualizar
-- documenta la operacion 'actualizar' del modulo 'miembros' segun el codigo fuente indicado en app/controllers/miembroController.php -> actualizarDatosMiembro.
-- -----------------------------------------------------------------------------
START TRANSACTION;
UPDATE miembro
                 SET id_empleado = :id_empleado,
                     nombre_miembro = :nombre_miembro,
                     tipo_miembro = :tipo_miembro
                 WHERE id_miembro = :id_miembro;
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 5. Bloque de modulo: miembros / buscar
-- documenta la operacion 'buscar' del modulo 'miembros' segun el codigo fuente indicado en app/controllers/cargarDatosMiembro.php.
-- -----------------------------------------------------------------------------
SELECT
        m.id_miembro,
        m.id_empleado,
        m.nombre_miembro,
        m.tipo_miembro,
        m.std_reg,
        e.nacionalidad,
        e.nombre_empleado,
        COALESCE(NULLIF(e.telefono, ''), '') AS telefono_empleado,
        COALESCE(NULLIF(e.correo, ''), '') AS correo_empleado,
        CASE
            WHEN e.id_empleado IS NOT NULL AND TRIM(e.id_empleado) <> ''
                THEN CONCAT(COALESCE(NULLIF(e.nacionalidad, ''), ''), IF(COALESCE(NULLIF(e.nacionalidad, ''), '') = '', '', '-'), e.id_empleado)
            ELSE 'No vinculado'
        END AS documento_empleado,
        CASE
            WHEN e.nombre_empleado IS NOT NULL AND TRIM(e.nombre_empleado) <> ''
                THEN e.nombre_empleado
            ELSE m.nombre_miembro
        END AS nombre_visual
     FROM miembro m
     LEFT JOIN empleado e
       ON e.id_empleado = m.id_empleado
     WHERE m.id_miembro = :id
       AND m.std_reg = 1
     LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 6. Bloque de modulo: miembros / buscar
-- documenta la operacion 'buscar' del modulo 'miembros' segun el codigo fuente indicado en app/controllers/cargarDatosBuscadorMiem.php.
-- -----------------------------------------------------------------------------
SELECT
        m.id_miembro,
        m.id_empleado,
        m.nombre_miembro,
        m.tipo_miembro,
        m.std_reg,
        e.nacionalidad,
        e.nombre_empleado,
        COALESCE(NULLIF(e.telefono, ''), '') AS telefono_empleado,
        COALESCE(NULLIF(e.correo, ''), '') AS correo_empleado,
        CASE
            WHEN e.id_empleado IS NOT NULL AND TRIM(e.id_empleado) <> ''
                THEN CONCAT(COALESCE(NULLIF(e.nacionalidad, ''), ''), IF(COALESCE(NULLIF(e.nacionalidad, ''), '') = '', '', '-'), e.id_empleado)
            ELSE 'No vinculado'
        END AS documento_empleado,
        CASE
            WHEN e.nombre_empleado IS NOT NULL AND TRIM(e.nombre_empleado) <> ''
                THEN e.nombre_empleado
            ELSE m.nombre_miembro
        END AS nombre_visual,
        CASE
            WHEN e.id_empleado IS NOT NULL AND TRIM(e.id_empleado) <> '' THEN 1
            ELSE 0
        END AS empleado_vinculado
    FROM miembro m
    LEFT JOIN empleado e
      ON e.id_empleado = m.id_empleado
    WHERE m.std_reg = 1
AND (
                m.id_miembro LIKE :q_codigo
                OR COALESCE(e.id_empleado, '') LIKE :q_doc
                OR COALESCE(e.nombre_empleado, m.nombre_miembro) LIKE :q_nombre
            )
ORDER BY nombre_visual ASC, m.id_miembro ASC;

-- -----------------------------------------------------------------------------
-- Bloque 7. Bloque de modulo: miembros / buscar
-- documenta la operacion 'buscar' del modulo 'miembros' segun el codigo fuente indicado en app/controllers/cargarDatosBuscadorMiem.php.
-- -----------------------------------------------------------------------------
SELECT id_miembro, std_reg
         FROM miembro
         WHERE id_miembro = :id
         LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 8. Bloque de modulo: miembros / crear
-- documenta la operacion 'crear' del modulo 'miembros' segun el codigo fuente indicado en app/controllers/miembroController.php -> siguienteCodigoMiembro.
-- -----------------------------------------------------------------------------
SELECT COALESCE(MAX(CAST(SUBSTRING(id_miembro, 3) AS UNSIGNED)), 0)
             FROM miembro
             WHERE id_miembro REGEXP '^M-[0-9]+$';

-- -----------------------------------------------------------------------------
-- Bloque 9. Bloque de modulo: miembros / crear
-- documenta la operacion 'crear' del modulo 'miembros' segun el codigo fuente indicado en app/controllers/miembroController.php -> registrarMiembroControlador.
-- -----------------------------------------------------------------------------
START TRANSACTION;
UPDATE miembro
                     SET id_empleado = :id_empleado,
                         nombre_miembro = :nombre_miembro,
                         tipo_miembro = :tipo_miembro,
                         std_reg = 1
                     WHERE id_miembro = :id_miembro;
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 10. Bloque de modulo: miembros / crear
-- documenta la operacion 'crear' del modulo 'miembros' segun el codigo fuente indicado en app/controllers/miembroController.php -> registrarMiembroControlador.
-- -----------------------------------------------------------------------------
START TRANSACTION;
INSERT INTO miembro (id_miembro, id_empleado, nombre_miembro, tipo_miembro, std_reg) VALUES (:id_miembro, :id_empleado, :nombre_miembro, :tipo_miembro, :std_reg);
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 11. Bloque de modulo: miembros / eliminar
-- documenta la operacion 'eliminar' del modulo 'miembros' segun el codigo fuente indicado en app/controllers/cargarDatosBuscadorMiem.php.
-- -----------------------------------------------------------------------------
START TRANSACTION;
UPDATE miembro SET std_reg = 0 WHERE id_miembro = :id;
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 12. Bloque de modulo: miembros / listar
-- documenta la operacion 'listar' del modulo 'miembros' segun el codigo fuente indicado en app/controllers/miembroController.php -> consultaMiembroListado.
-- -----------------------------------------------------------------------------
SELECT
            m.id_miembro,
            m.id_empleado,
            m.nombre_miembro,
            m.tipo_miembro,
            m.std_reg,
            e.nacionalidad,
            e.nombre_empleado,
            e.telefono AS telefono_empleado,
            e.correo AS correo_empleado,
            CASE
                WHEN e.id_empleado IS NOT NULL AND TRIM(e.id_empleado) <> ''
                    THEN CONCAT(COALESCE(NULLIF(e.nacionalidad, ''), ''), IF(COALESCE(NULLIF(e.nacionalidad, ''), '') = '', '', '-'), e.id_empleado)
                ELSE 'No vinculado'
            END AS documento_empleado,
            CASE
                WHEN e.nombre_empleado IS NOT NULL AND TRIM(e.nombre_empleado) <> ''
                    THEN e.nombre_empleado
                ELSE m.nombre_miembro
            END AS nombre_visual,
            CASE
                WHEN e.id_empleado IS NOT NULL AND TRIM(e.id_empleado) <> '' THEN 1
                ELSE 0
            END AS empleado_vinculado
        FROM miembro m
        LEFT JOIN empleado e
          ON e.id_empleado = m.id_empleado
        WHERE m.std_reg = 1;

-- -----------------------------------------------------------------------------
-- Bloque 13. Bloque de modulo: reportes / buscar
-- documenta la operacion 'buscar' del modulo 'reportes' segun el codigo fuente indicado en app/controllers/cargarDatosReporte.php.
-- -----------------------------------------------------------------------------
SELECT `id_ai_miembro`, `id_miembro`, `id_empleado`, `nombre_miembro`, `tipo_miembro`, `std_reg`
FROM miembro
WHERE std_reg = 1
  AND (:q IS NULL OR :q = '' OR id_miembro LIKE :q OR nombre_miembro LIKE :q)
ORDER BY nombre_miembro ASC
LIMIT 800;

-- -----------------------------------------------------------------------------
-- Bloque 14. Bloque de modulo: reportes / extras
-- documenta la operacion 'extras' del modulo 'reportes' segun el codigo fuente indicado en app/controllers/exportarReportePdf.php.
-- -----------------------------------------------------------------------------
SELECT `id_ai_miembro`, `id_miembro`, `id_empleado`, `nombre_miembro`, `tipo_miembro`, `std_reg`
FROM miembro
WHERE std_reg = 1
  AND (:q IS NULL OR :q = '' OR id_miembro LIKE :q OR nombre_miembro LIKE :q)
ORDER BY nombre_miembro ASC
LIMIT 5000;


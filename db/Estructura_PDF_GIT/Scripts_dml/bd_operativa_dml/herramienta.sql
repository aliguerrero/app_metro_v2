-- Modulo: Scripts_dml
-- Archivo: herramienta.sql
-- Funcion: reune las consultas y escrituras de datos asociadas al inventario de herramientas y su disponibilidad.
-- Version: v_1.0

-- -----------------------------------------------------------------------------
-- Bloque 1. Carga maestra inicial
-- inserta los datos maestros base definidos para este objeto en el respaldo general del sistema.
-- -----------------------------------------------------------------------------
START TRANSACTION;
INSERT INTO `herramienta` (`id_ai_herramienta`, `nombre_herramienta`, `id_ai_categoria_herramienta`, `cantidad`, `estado`, `std_reg`) VALUES
(1, 'Martillo de via', 1, 6, '1', 1),
(2, 'Llave de impacto 3/4', 1, 4, '1', 1),
(3, 'Juego de destornilladores aislados', 1, 8, '1', 1),
(4, 'Pinza amperimetrica', 2, 3, '1', 1),
(5, 'Multimetro digital', 2, 4, '1', 1),
(6, 'Medidor laser de distancia', 2, 2, '2', 1),
(7, 'Taladro percutor industrial', 3, 5, '1', 1),
(8, 'Amoladora angular 7in', 3, 3, '2', 1),
(9, 'Generador portatil 5kVA', 3, 2, '1', 1),
(10, 'Casco de seguridad', 4, 20, '1', 1),
(11, 'Arnes de seguridad', 4, 10, '1', 1),
(12, 'Guantes dielectricos', 4, 15, '1', 1),
(13, 'Soldadora inverter', 5, 2, '1', 1),
(14, 'Careta de soldar', 5, 4, '1', 1),
(15, 'Cizalla para cables', 5, 3, '2', 1),
(16, 'Escalera telescopica', 4, 4, '1', 1);
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 2. Bloque de modulo: categorias_herramienta / actualizar
-- documenta la operacion 'actualizar' del modulo 'categorias_herramienta' segun el codigo fuente indicado en app/controllers/categoriaHerramientaCrud.php.
-- -----------------------------------------------------------------------------
SELECT COUNT(1)
             FROM herramienta
             WHERE id_ai_categoria_herramienta = :id
               AND std_reg = 1;

-- -----------------------------------------------------------------------------
-- Bloque 3. Bloque de modulo: herramientas / actualizar
-- documenta la operacion 'actualizar' del modulo 'herramientas' segun el codigo fuente indicado en app/controllers/herramientaController.php -> actualizarDatosHeramienta.
-- -----------------------------------------------------------------------------
SELECT id_ai_herramienta
             FROM herramienta
             WHERE TRIM(LOWER(nombre_herramienta)) = TRIM(LOWER(:nombre))
               AND id_ai_herramienta <> :id
               AND std_reg = 1
             LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 4. Bloque de modulo: herramientas / actualizar
-- documenta la operacion 'actualizar' del modulo 'herramientas' segun el codigo fuente indicado en app/controllers/herramientaController.php -> actualizarDatosHeramienta.
-- -----------------------------------------------------------------------------
START TRANSACTION;
UPDATE herramienta SET nombre_herramienta = :Nombre, id_ai_categoria_herramienta = :Categoria, cantidad = :Cant, estado = :Estado WHERE id_ai_herramienta = :ID;
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 5. Bloque de modulo: herramientas / buscar
-- documenta la operacion 'buscar' del modulo 'herramientas' segun el codigo fuente indicado en app/controllers/cargarDatosHerramienta.php.
-- -----------------------------------------------------------------------------
SELECT
        h.id_ai_herramienta,
        h.nombre_herramienta,
        h.id_ai_categoria_herramienta,
        COALESCE(ch.nombre_categoria, 'SIN CATEGORIA') AS nombre_categoria,
        h.cantidad,
        h.estado,
        h.std_reg
     FROM herramienta h
     LEFT JOIN categoria_herramienta ch
       ON ch.id_ai_categoria_herramienta = h.id_ai_categoria_herramienta
     WHERE h.id_ai_herramienta = :id
       AND h.std_reg = 1
     LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 6. Bloque de modulo: herramientas / buscar
-- documenta la operacion 'buscar' del modulo 'herramientas' segun el codigo fuente indicado en app/controllers/cargarDatosBuscadorTools.php.
-- -----------------------------------------------------------------------------
SELECT
                id_ai_herramienta,
                nombre_herramienta,
                id_ai_categoria_herramienta,
                COALESCE(nombre_categoria, 'SIN CATEGORIA') AS nombre_categoria,
                cantidad_total AS cantidad,
                estado,
                std_reg,
                cantidad_disponible,
                cantidad_ocupada AS herramienta_ocupada
            FROM vw_herramienta_disponibilidad
            WHERE std_reg = 1
              AND (
                    CAST(id_ai_herramienta AS CHAR) LIKE :term1
                    OR nombre_herramienta LIKE :term2
                    OR COALESCE(nombre_categoria, '') LIKE :term3
              )
            ORDER BY id_ai_herramienta ASC;

-- -----------------------------------------------------------------------------
-- Bloque 7. Bloque de modulo: herramientas / buscar
-- documenta la operacion 'buscar' del modulo 'herramientas' segun el codigo fuente indicado en app/controllers/cargarDatosBuscadorTools.php.
-- -----------------------------------------------------------------------------
SELECT
                id_ai_herramienta,
                nombre_herramienta,
                id_ai_categoria_herramienta,
                COALESCE(nombre_categoria, 'SIN CATEGORIA') AS nombre_categoria,
                cantidad_total AS cantidad,
                estado,
                std_reg,
                cantidad_disponible,
                cantidad_ocupada AS herramienta_ocupada
            FROM vw_herramienta_disponibilidad
            WHERE std_reg = 1
            ORDER BY id_ai_herramienta ASC;

-- -----------------------------------------------------------------------------
-- Bloque 8. Bloque de modulo: herramientas / crear
-- documenta la operacion 'crear' del modulo 'herramientas' segun el codigo fuente indicado en app/controllers/herramientaController.php -> registrarHerramientaControlador.
-- -----------------------------------------------------------------------------
SELECT id_ai_herramienta, std_reg
                 FROM herramienta
                 WHERE TRIM(LOWER(nombre_herramienta)) = TRIM(LOWER(:nombre))
                 LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 9. Bloque de modulo: herramientas / crear
-- documenta la operacion 'crear' del modulo 'herramientas' segun el codigo fuente indicado en app/controllers/herramientaController.php -> registrarHerramientaControlador.
-- -----------------------------------------------------------------------------
START TRANSACTION;
INSERT INTO herramienta (nombre_herramienta, id_ai_categoria_herramienta, cantidad, estado, std_reg) VALUES (:Nombre, :Categoria, :Cant, :Estado, :std_reg);
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 10. Bloque de modulo: herramientas / eliminar
-- documenta la operacion 'eliminar' del modulo 'herramientas' segun el codigo fuente indicado en app/controllers/herramientaController.php -> eliminarHerramientaControlador.
-- -----------------------------------------------------------------------------
SELECT `id_ai_herramienta`, `nombre_herramienta`, `id_ai_categoria_herramienta`, `cantidad`, `estado`, `std_reg` FROM herramienta WHERE id_ai_herramienta = :id LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 11. Bloque de modulo: herramientas / eliminar
-- documenta la operacion 'eliminar' del modulo 'herramientas' segun el codigo fuente indicado en app/controllers/herramientaController.php -> eliminarHerramientaControlador.
-- -----------------------------------------------------------------------------
START TRANSACTION;
UPDATE herramienta SET std_reg = :std_reg WHERE id_ai_herramienta = :id_ai_herramienta;
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 12. Bloque de modulo: herramientas / listar
-- documenta la operacion 'listar' del modulo 'herramientas' segun el codigo fuente indicado en app/controllers/herramientaController.php -> listarHerramientaControlador.
-- -----------------------------------------------------------------------------
SELECT COUNT(1) FROM vw_herramienta_disponibilidad WHERE std_reg = 1;

-- -----------------------------------------------------------------------------
-- Bloque 13. Bloque de modulo: ordenes_trabajo / listar
-- documenta la operacion 'listar' del modulo 'ordenes_trabajo' segun el codigo fuente indicado en app/controllers/cargarDatosDetalles.php.
-- -----------------------------------------------------------------------------
SELECT cantidad
         FROM herramienta
         WHERE std_reg = 1 AND id_ai_herramienta = :id
         FOR UPDATE;


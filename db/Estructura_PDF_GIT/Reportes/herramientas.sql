-- Modulo: reportes
-- Archivo: herramientas.sql
-- Funcion: generar el reporte de herramientas con busqueda opcional por codigo o nombre.
-- Version: v_1.0
-- Parametros opcionales:
--   :q_codigo = texto a buscar sobre el codigo de herramienta.
--   :q_nombre = texto a buscar sobre el nombre de la herramienta.

SELECT
    id_ai_herramienta AS herramienta_id,
    nombre_herramienta,
    cantidad_total AS cantidad,
    cantidad_disponible,
    cantidad_ocupada,
    estado
FROM vw_herramienta_disponibilidad
WHERE std_reg = 1
  AND (
        (:q_codigo IS NULL OR :q_codigo = '')
        OR CAST(id_ai_herramienta AS CHAR) LIKE :q_codigo
        OR nombre_herramienta LIKE :q_nombre
      )
ORDER BY nombre_herramienta ASC
LIMIT 800;

-- Modulo: reportes
-- Archivo: ot_detallado_herramientas.sql
-- Funcion: listar las herramientas asignadas a una O.T. para el reporte detallado.
-- Version: v_1.0
-- Parametros:
--   :id = numero de O.T. requerido.

SELECT
    h.id_ai_herramienta AS herramienta_id,
    he.nombre_herramienta,
    h.cantidadot
FROM herramientaot h
LEFT JOIN herramienta he
    ON he.id_ai_herramienta = h.id_ai_herramienta
WHERE h.n_ot = :id
ORDER BY he.nombre_herramienta ASC;

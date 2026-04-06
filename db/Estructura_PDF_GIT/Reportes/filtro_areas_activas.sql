-- Modulo: reportes
-- Archivo: filtro_areas_activas.sql
-- Funcion: cargar las areas activas disponibles para filtrar reportes de O.T.
-- Version: v_1.0
-- Parametros: no requiere parametros.

SELECT
    id_ai_area AS id_area,
    id_ai_area AS id_ai_area,
    nombre_area
FROM area_trabajo
WHERE std_reg = 1
ORDER BY nombre_area ASC;

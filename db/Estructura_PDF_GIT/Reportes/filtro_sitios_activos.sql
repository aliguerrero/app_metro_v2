-- Modulo: reportes
-- Archivo: filtro_sitios_activos.sql
-- Funcion: cargar los sitios activos disponibles para filtrar reportes de O.T.
-- Version: v_1.0
-- Parametros: no requiere parametros.

SELECT
    id_ai_sitio AS id_sitio,
    id_ai_sitio AS id_ai_sitio,
    nombre_sitio
FROM sitio_trabajo
WHERE std_reg = 1
ORDER BY nombre_sitio ASC;

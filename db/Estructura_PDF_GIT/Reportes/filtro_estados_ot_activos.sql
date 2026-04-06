-- Modulo: reportes
-- Archivo: filtro_estados_ot_activos.sql
-- Funcion: cargar los estados de O.T. activos para el panel de filtros.
-- Version: v_1.0
-- Parametros: no requiere parametros.

SELECT
    id_ai_estado AS id_estado,
    id_ai_estado AS id_ai_estado,
    nombre_estado,
    color
FROM estado_ot
WHERE std_reg = 1
ORDER BY id_ai_estado ASC;

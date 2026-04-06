-- Modulo: reportes
-- Archivo: filtro_usuarios_activos.sql
-- Funcion: cargar los usuarios activos disponibles para filtrar reportes.
-- Version: v_1.0
-- Parametros: no requiere parametros.

SELECT
    id_empleado AS id_user,
    COALESCE(NULLIF(nombre_empleado, ''), id_empleado) AS user,
    username
FROM vw_usuario_empleado
WHERE std_reg = 1
ORDER BY COALESCE(NULLIF(nombre_empleado, ''), id_empleado) ASC;

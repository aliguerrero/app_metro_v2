-- Modulo: reportes
-- Archivo: empresa_config_encabezado_reporte.sql
-- Funcion: obtener la configuracion de empresa usada en el encabezado del reporte.
-- Version: v_1.0
-- Parametros: no requiere parametros.

SELECT
    id,
    nombre,
    rif,
    direccion,
    telefono,
    email,
    logo,
    created_at,
    updated_at
FROM empresa_config
WHERE id = 1
LIMIT 1;

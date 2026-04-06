-- Modulo: reportes
-- Archivo: ot_detallado_ot.sql
-- Funcion: obtener la cabecera de una O.T. especifica para el reporte detallado.
-- Version: v_1.0
-- Parametros:
--   :id = numero de O.T. requerido.

SELECT *
FROM vw_ot_resumen
WHERE n_ot = :id
  AND std_reg = 1
LIMIT 1;

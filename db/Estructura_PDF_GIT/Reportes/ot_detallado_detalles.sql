-- Modulo: reportes
-- Archivo: ot_detallado_detalles.sql
-- Funcion: listar los detalles operativos asociados a una O.T. para el reporte detallado.
-- Version: v_1.0
-- Parametros:
--   :id = numero de O.T. requerido.

SELECT
    id_ai_detalle,
    fecha_detalle AS fecha,
    nombre_turno,
    COALESCE(NULLIF(usuario_act_nombre, ''), id_user_act) AS tecnico_nombre,
    miembro_cco_nombre AS cco_nombre,
    miembro_ccf_nombre AS ccf_nombre,
    descripcion,
    hora_inicio,
    hora_fin,
    observacion
FROM vw_ot_detallada
WHERE n_ot = :id
ORDER BY id_ai_detalle ASC;

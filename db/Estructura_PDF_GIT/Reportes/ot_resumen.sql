-- Modulo: reportes
-- Archivo: ot_resumen.sql
-- Funcion: generar el reporte resumen de ordenes de trabajo.
-- Version: v_1.0
-- Parametros opcionales:
--   :n_ot = filtra por numero exacto de O.T.
--   :desde = fecha inicial.
--   :hasta = fecha final.
--   :area = id_ai_area.
--   :sitio = id_ai_sitio.
--   :estado = id_ai_estado.
--   :usuario = id del tecnico/usuario actuante encontrado en vw_ot_detallada.

SELECT
    ot.n_ot,
    ot.fecha,
    ot.semana,
    ot.mes,
    ot.nombre_trab,
    ot.nombre_area,
    ot.nombre_sitio,
    ot.nombre_estado AS estado_actual,
    ot.total_detalles,
    ot.herramientas_asignadas AS total_herr
FROM vw_ot_resumen ot
WHERE ot.std_reg = 1
  AND (:n_ot IS NULL OR :n_ot = '' OR ot.n_ot = :n_ot)
  AND (:desde IS NULL OR :desde = '' OR ot.fecha >= :desde)
  AND (:hasta IS NULL OR :hasta = '' OR ot.fecha <= :hasta)
  AND (:area IS NULL OR :area = '' OR ot.id_ai_area = :area)
  AND (:sitio IS NULL OR :sitio = '' OR ot.id_ai_sitio = :sitio)
  AND (:estado IS NULL OR :estado = '' OR ot.id_ai_estado = :estado)
  AND (
        :usuario IS NULL
        OR :usuario = ''
        OR EXISTS (
            SELECT 1
            FROM vw_ot_detallada d2
            WHERE d2.n_ot = ot.n_ot
              AND d2.id_user_act = :usuario
        )
      )
ORDER BY ot.fecha DESC, ot.n_ot DESC
LIMIT 500;

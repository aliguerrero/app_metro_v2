-- Modulo: reportes
-- Archivo: miembros.sql
-- Funcion: generar el reporte de miembros con busqueda opcional por codigo o nombre.
-- Version: v_1.0
-- Parametros opcionales:
--   :q = texto a buscar sobre `id_miembro` o `nombre_miembro`.

SELECT
    id_ai_miembro,
    id_miembro,
    id_empleado,
    nombre_miembro,
    tipo_miembro,
    std_reg
FROM miembro
WHERE std_reg = 1
  AND (
        :q IS NULL
        OR :q = ''
        OR id_miembro LIKE :q
        OR nombre_miembro LIKE :q
      )
ORDER BY nombre_miembro ASC
LIMIT 800;

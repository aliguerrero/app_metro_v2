-- Modulo: reportes
-- Archivo: usuarios.sql
-- Funcion: generar el reporte de usuarios con busqueda opcional por ID, nombre, username o rol.
-- Version: v_1.0
-- Parametros opcionales:
--   :q_id = texto a buscar sobre `id_empleado`.
--   :q_nombre = texto a buscar sobre `nombre_empleado`.
--   :q_username = texto a buscar sobre `username`.
--   :q_rol = texto a buscar sobre `nombre_rol`.

SELECT
    id_empleado AS id_user,
    COALESCE(nombre_empleado, id_empleado) AS user,
    username,
    nombre_rol
FROM vw_usuario_empleado
WHERE std_reg = 1
  AND (
        (:q_id IS NULL OR :q_id = '')
        OR id_empleado LIKE :q_id
        OR COALESCE(nombre_empleado, '') LIKE :q_nombre
        OR username LIKE :q_username
        OR COALESCE(nombre_rol, '') LIKE :q_rol
      )
ORDER BY COALESCE(nombre_empleado, id_empleado) ASC
LIMIT 800;

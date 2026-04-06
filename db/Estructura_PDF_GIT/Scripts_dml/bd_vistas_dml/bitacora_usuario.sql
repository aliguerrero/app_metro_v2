-- Modulo: Scripts_dml
-- Archivo: bitacora_usuario.sql
-- Funcion: reune las consultas de lectura contra las vistas de auditoria.
-- Version: v_1.0

-- -----------------------------------------------------------------------------
-- Bloque 1. Consultar detalle de eventos
-- consulta el detalle expandido de la auditoria de respaldo para fines de revision.
-- -----------------------------------------------------------------------------
SELECT * FROM vw_log_user_detalle WHERE (:id_log IS NULL OR id_log = :id_log) ORDER BY fecha_hora DESC, id_log DESC LIMIT 200;

-- -----------------------------------------------------------------------------
-- Bloque 2. Consultar resumen diario de eventos
-- consulta el resumen diario de eventos agrupado por tabla y operacion en la base de vistas.
-- -----------------------------------------------------------------------------
SELECT * FROM vw_log_user_resumen WHERE (:tabla IS NULL OR :tabla = '' OR tabla = :tabla) ORDER BY dia DESC, tabla ASC, operacion ASC;


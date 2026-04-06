-- Modulo: Scripts_dml
-- Archivo: bitacora_usuario.sql
-- Funcion: reune las consultas y escrituras de datos asociadas a la bitacora de la base de auditoria.
-- Version: v_1.0

-- -----------------------------------------------------------------------------
-- Bloque 1. Consultar ultimo evento sincronizado
-- recupera el ultimo identificador de auditoria ya persistido en la base de respaldo para calcular el incremental pendiente.
-- -----------------------------------------------------------------------------
SELECT IFNULL(MAX(id_log), 0) AS ultimo_id_log FROM bdapp_metro_audit.log_user;

-- -----------------------------------------------------------------------------
-- Bloque 2. Sincronizar eventos operativos
-- copia hacia la bitacora de auditoria los eventos nuevos generados en la base operativa.
-- -----------------------------------------------------------------------------
START TRANSACTION;
INSERT INTO bdapp_metro_audit.log_user (id_log, event_uuid, id_user, tabla, operacion, pk_registro, pk_json, accion, resp_system, data_old, data_new, data_diff, fecha_hora, connection_id, db_user, db_host, changed_cols, std_reg) SELECT id_log, event_uuid, id_user, tabla, operacion, pk_registro, pk_json, accion, resp_system, data_old, data_new, data_diff, fecha_hora, connection_id, db_user, db_host, changed_cols, std_reg FROM bdapp_metro.log_user WHERE id_log > :ultimo_id_log;
COMMIT;


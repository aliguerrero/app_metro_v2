-- Modulo: Scripts_dml
-- Archivo: respaldo_auditoria.sql
-- Funcion: reune las consultas y escrituras de datos asociadas al historial de respaldos y sincronizaciones.
-- Version: v_1.0

-- -----------------------------------------------------------------------------
-- Bloque 1. Medir el punto inicial de sincronizacion
-- lee el ultimo id de auditoria antes de ejecutar una corrida de respaldo para calcular cuantas filas fueron sincronizadas.
-- -----------------------------------------------------------------------------
SELECT IFNULL(MAX(id_log), 0) AS ultimo_id_log_antes FROM bdapp_metro_audit.log_user;

-- -----------------------------------------------------------------------------
-- Bloque 2. Registrar la corrida de respaldo
-- inserta la traza resumen de la sincronizacion efectuada dentro del historial de respaldos.
-- -----------------------------------------------------------------------------
START TRANSACTION;
INSERT INTO bdapp_metro_audit.backup_runs (run_at, synced_rows, backed_rows) VALUES (NOW(), :synced_rows, :backed_rows);
COMMIT;


-- Modulo: Scripts_dml
-- Archivo: respaldo_auditoria.sql
-- Funcion: reune las consultas de lectura contra las vistas del seguimiento de respaldos.
-- Version: v_1.0

-- -----------------------------------------------------------------------------
-- Bloque 1. Consultar corridas de respaldo
-- recupera el historial visible de corridas de respaldo publicadas en la base de vistas.
-- -----------------------------------------------------------------------------
SELECT * FROM vw_backup_runs ORDER BY run_at DESC LIMIT 200;

-- -----------------------------------------------------------------------------
-- Bloque 2. Consultar eventos programados
-- recupera el estado visible de los eventos programados asociados al respaldo de auditoria.
-- -----------------------------------------------------------------------------
SELECT * FROM vw_eventos ORDER BY EVENT_NAME ASC;


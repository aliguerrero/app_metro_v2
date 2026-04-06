-- Modulo: Scripts_dml
-- Archivo: bitacora_usuario.sql
-- Funcion: reune las consultas y escrituras de datos asociadas a la bitacora operativa de auditoria.
-- Version: v_1.0

-- -----------------------------------------------------------------------------
-- Bloque 1. Bloque de modulo: logs_auditoria / buscar
-- documenta la operacion 'buscar' del modulo 'logs_auditoria' segun el codigo fuente indicado en app/controllers/logDetail.php.
-- -----------------------------------------------------------------------------
SELECT `id_log`, `event_uuid`, `id_user`, `tabla`, `operacion`, `pk_registro`, `pk_json`, `accion`, `resp_system`, `data_old`, `data_new`, `data_diff`, `fecha_hora`, `connection_id`, `db_user`, `db_host`, `changed_cols`, `std_reg` FROM log_user WHERE id_log = :id LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 2. Bloque de modulo: logs_auditoria / listar
-- documenta la operacion 'listar' del modulo 'logs_auditoria' segun el codigo fuente indicado en app/controllers/logFilters.php.
-- -----------------------------------------------------------------------------
SELECT DISTINCT tabla FROM log_user ORDER BY tabla ASC;

-- -----------------------------------------------------------------------------
-- Bloque 3. Bloque de modulo: logs_auditoria / listar
-- documenta la operacion 'listar' del modulo 'logs_auditoria' segun el codigo fuente indicado en app/controllers/logFilters.php.
-- -----------------------------------------------------------------------------
SELECT DISTINCT id_user FROM log_user WHERE id_user IS NOT NULL AND id_user <> '' ORDER BY id_user ASC;


-- Modulo: Scripts_dml
-- Archivo: reporte_generado.sql
-- Funcion: reune las consultas y escrituras de datos asociadas a los reportes generados.
-- Version: v_1.0

-- -----------------------------------------------------------------------------
-- Bloque 1. Bloque de modulo: reportes / crear
-- documenta la operacion 'crear' del modulo 'reportes' segun el codigo fuente indicado en app/controllers/reporteGeneradoController.php -> guardarReporteGenerado.
-- -----------------------------------------------------------------------------
CALL sp_reporte_registrar_generado(
                :tipo_reporte,
                :titulo_reporte,
                :nombre_archivo,
                :ruta_archivo,
                :mime_type,
                :tamano_bytes,
                :parametros_json,
                :id_user_generador
            );

-- -----------------------------------------------------------------------------
-- Bloque 2. Bloque de modulo: reportes / extras
-- documenta la operacion 'extras' del modulo 'reportes' segun el codigo fuente indicado en app/controllers/reporteGeneradoController.php -> emitirReporteGuardado.
-- -----------------------------------------------------------------------------
SELECT
                id_ai_reporte_generado,
                tipo_reporte,
                titulo_reporte,
                nombre_archivo,
                ruta_archivo,
                mime_type,
                tamano_bytes,
                id_user_generador,
                nombre_user_generador,
                username_generador,
                created_at,
                 std_reg
             FROM vw_reportes_generados
             WHERE id_ai_reporte_generado = :id
             LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 3. Bloque de modulo: reportes / listar
-- documenta la operacion 'listar' del modulo 'reportes' segun el codigo fuente indicado en app/controllers/reporteGeneradoController.php -> listarReportesGeneradosHtml.
-- -----------------------------------------------------------------------------
SELECT
                id_ai_reporte_generado,
                tipo_reporte,
                titulo_reporte,
                nombre_archivo,
                ruta_archivo,
                mime_type,
                tamano_bytes,
                parametros_json,
                id_user_generador,
                nombre_user_generador,
                username_generador,
                created_at,
                std_reg
             FROM vw_reportes_generados
             ORDER BY created_at DESC, id_ai_reporte_generado DESC
             LIMIT 200;


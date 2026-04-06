<!-- Encabezado -->
<div class="d-flex align-items-center gap-2 mb-2">
    <div class="avatar avatar-md bg-light d-flex align-items-center justify-content-center">
        <i class="bi bi-database-fill-gear fs-4"></i>
    </div>
    <div>
        <h4 class="mb-0">Respaldo y restauracion</h4>
        <small class="text-muted">Gestiona copias de seguridad de la base de datos.</small>
    </div>
</div>

<hr>

<div class="alert alert-info d-none db-backup-busy-state" id="dbBackupBusyState" role="status" aria-live="polite" aria-atomic="true">
    <div class="d-flex align-items-center gap-3">
        <div class="spinner-border spinner-border-sm text-info flex-shrink-0" aria-hidden="true"></div>
        <div class="flex-grow-1">
            <div class="fw-semibold" id="dbBackupBusyTitle">Procesando accion</div>
            <div class="small mb-0" id="dbBackupBusyText">Espera un momento mientras el sistema completa la operacion.</div>
        </div>
    </div>
</div>

<div class="card mb-4">
    <div class="card-header d-flex align-items-center justify-content-between flex-wrap gap-2">
        <strong>Crear respaldo</strong>
        <div class="d-flex gap-2">
            <button type="button" class="btn btn-sm btn-primary" id="btnCrearRespaldoDb">
                <i class="bi bi-hdd-stack me-1"></i>Generar y guardar
            </button>
            <button type="button" class="btn btn-sm btn-outline-primary" id="btnRecargarRespaldosDb" title="Recargar">
                <i class="bi bi-arrow-clockwise"></i>
            </button>
        </div>
    </div>
    <div class="card-body">
        <div class="form-check form-switch mb-3">
            <input class="form-check-input" type="checkbox" id="backupUseSpecificTables">
            <label class="form-check-label" for="backupUseSpecificTables">
                Respaldar tablas especificas
            </label>
        </div>

        <div id="backupTablesPicker" class="border rounded p-3 mb-3 d-none">
            <div class="d-flex flex-wrap gap-2 mb-2">
                <button type="button" class="btn btn-sm btn-outline-secondary" id="btnSelectAllBackupTables">
                    Seleccionar todas
                </button>
                <button type="button" class="btn btn-sm btn-outline-secondary" id="btnClearBackupTables">
                    Limpiar seleccion
                </button>
            </div>
            <div id="backupTablesList" class="row g-2">
                <div class="col-12 text-muted small">Cargando tablas...</div>
            </div>
            <div class="form-text mt-2">
                Si activas esta opcion, debes seleccionar al menos una tabla.
            </div>
        </div>

        <p class="mb-0 text-muted">
            Se generara un archivo SQL con la estructura y los datos actuales del sistema.
            En respaldos completos tambien se incluyen vistas, triggers, procedimientos, eventos y esquemas auxiliares de auditoria/revision cuando existen.
            El archivo queda guardado en <code>db/backups/</code> dentro del proyecto.
        </p>
    </div>
</div>



<div class="card mb-4 border-warning">
    <div class="card-header bg-warning bg-opacity-10">
        <strong>Restaurar base de datos</strong>
    </div>
    <div class="card-body">
        <form id="formRestoreDb" enctype="multipart/form-data" autocomplete="off">
            <div class="mb-3">
                <label for="restoreSqlFile" class="form-label"><b>Archivo SQL (.sql)</b></label>
                <input type="file" class="form-control" id="restoreSqlFile" name="sql_file" accept=".sql" required>
                <div class="form-text">Usa respaldos SQL generados por este sistema para restauraciones completas y sin conflictos.</div>
            </div>

            <div class="alert alert-secondary py-2 px-3 small mb-3">
                Antes de restaurar, el sistema te preguntara si deseas generar un respaldo de seguridad previo.
            </div>

            <div class="mb-3">
                <label for="restoreConfirmText" class="form-label">
                    <b>Confirmacion</b> (escribe <code>RESTAURAR</code>)
                </label>
                <input type="text" class="form-control" id="restoreConfirmText" placeholder="RESTAURAR"
                    autocomplete="off">
            </div>

            <button type="submit" class="btn btn-danger" id="btnRestaurarDb">
                <i class="bi bi-arrow-counterclockwise me-1"></i>Restaurar base de datos
            </button>
        </form>
    </div>
</div>

<div class="card mb-2">
    <div class="card-header">
        <strong>Respaldos disponibles</strong>
    </div>
    <div class="card-body p-0" id="dbBackupListWrap">
        <div class="p-3 text-muted">Cargando respaldos...</div>
    </div>
</div>

<style>
.tools-scope .db-backup-busy-state {
    border: 1px solid rgba(13, 110, 253, .2);
    box-shadow: 0 10px 24px rgba(13, 110, 253, .08);
}

.tools-scope .db-backup-busy-state .spinner-border {
    width: 1.1rem;
    height: 1.1rem;
}

.tools-scope .btn.is-busy {
    opacity: 1;
    display: inline-flex;
    align-items: center;
    justify-content: center;
}

.tools-scope .db-backup-actions {
    display: inline-flex;
    align-items: center;
    gap: .4rem;
    flex-wrap: nowrap;
    white-space: nowrap;
}

.tools-scope .db-backup-btn {
    border: none !important;
    color: #fff !important;
    border-radius: .7rem !important;
    font-weight: 700;
    box-shadow: 0 6px 12px rgba(2, 6, 23, .16);
}

.tools-scope .db-backup-btn-restore {
    background: #2e7d32 !important;
}

.tools-scope .db-backup-btn-download {
    background: #1565c0 !important;
}

.tools-scope .db-backup-btn-delete {
    background: #c62828 !important;
}

.tools-scope .db-backup-btn-restore:hover,
.tools-scope .db-backup-btn-download:hover,
.tools-scope .db-backup-btn-delete:hover {
    filter: brightness(.94);
}

.tools-scope .db-backup-cards .tool-actions.db-backup-card-actions {
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: .5rem;
}

.tools-scope .db-backup-cards .tool-actions.db-backup-card-actions .btn {
    width: 100%;
    justify-content: center;
    display: inline-flex;
    align-items: center;
}

.tools-scope .db-backup-cards .tool-row {
    align-items: flex-start;
}

.tools-scope .db-backup-cards .tool-row .tool-label {
    min-width: 60px;
}

.tools-scope .db-backup-cards .tool-row .tool-value {
    flex: 1 1 auto;
    min-width: 0;
    text-align: right;
}

.tools-scope .db-backup-cards .db-backup-text-break,
.tools-scope .db-backup-cards .db-backup-text-break code,
.tools-scope .db-backup-cards .db-backup-text-break small {
    display: block;
    max-width: 100%;
    white-space: normal;
    overflow-wrap: anywhere;
    word-break: break-word;
}

.tools-scope #backupTablesPicker,
.tools-scope #autoBackupTablesList {
    background: #fff;
}

.tools-scope #backupTablesList,
.tools-scope #autoBackupTablesList {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
    gap: .75rem;
    max-height: 340px;
    overflow: auto;
    padding-right: .2rem;
}

.tools-scope .db-backup-table-item {
    min-width: 0;
}

.tools-scope .db-backup-table-option {
    margin: 0;
    border: 1px solid var(--line);
    border-radius: .8rem;
    background: #fff;
    padding: .7rem .8rem;
    min-height: 76px;
    display: flex;
    align-items: flex-start;
    gap: .55rem;
}

.tools-scope .db-backup-table-option .form-check-input {
    margin-top: .15rem;
}

.tools-scope .db-backup-table-option .db-backup-table-text {
    min-width: 0;
}

.tools-scope .db-backup-table-option .db-backup-table-name {
    display: block;
    white-space: normal;
    overflow-wrap: anywhere;
    word-break: break-word;
}

@media (max-width: 767.98px) {

    .tools-scope #backupTablesList,
    .tools-scope #autoBackupTablesList {
        grid-template-columns: 1fr;
        max-height: 300px;
    }
}
</style>

<script src="<?php echo APP_URL; ?>app/views/js/db_backup.js"></script>

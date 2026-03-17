<?php
$isAdmin = (isset($_SESSION['tipo']) && (int)$_SESSION['tipo'] === 1);
?>
<style>
.logs-user-page .help-tip {
    border: 0;
    background: transparent;
    color: #6c757d;
    padding: 0;
    line-height: 1;
}

.logs-user-page .help-tip:hover {
    color: #0d6efd;
}

.logs-user-page .logs-kpi {
    border: 1px solid #e8ecf1;
    border-radius: 0.75rem;
    background: linear-gradient(180deg, #ffffff, #f8fafc);
    padding: 0.8rem 1rem;
}

.logs-user-page .logs-kpi .kpi-label {
    color: #6c757d;
    font-size: 0.8rem;
    margin-bottom: 0.2rem;
    text-transform: uppercase;
    letter-spacing: .04em;
}

.logs-user-page .logs-kpi .kpi-value {
    font-size: 1.2rem;
    font-weight: 700;
}

.logs-user-page .logs-filters input[type="date"] {
    min-width: 165px;
}

.logs-user-page .logs-filters .row.align-items-end {
    align-items: stretch !important;
}

.logs-user-page .logs-filters .row>[class*="col-"] {
    display: flex;
    flex-direction: column;
    justify-content: flex-start;
}

.logs-user-page .logs-filters .form-label {
    display: flex;
    align-items: center;
    gap: .35rem;
    min-height: 30px;
    margin-bottom: .35rem !important;
    line-height: 1.1;
}

.logs-user-page .logs-filters .input-group,
.logs-user-page .logs-filters .form-select,
.logs-user-page .logs-filters .form-control {
    margin-top: 0;
}

.logs-user-page .logs-table th,
.logs-user-page .logs-table td {
    vertical-align: middle;
}

.logs-user-page .logs-col-date {
    width: 170px;
    white-space: nowrap;
}

.logs-user-page .logs-col-record {
    min-width: 180px;
}

.logs-user-page .logs-json {
    white-space: pre-wrap;
    word-break: break-word;
    background: #f8f9fa;
    border: 1px solid #e9ecef;
    border-radius: 0.5rem;
    padding: .75rem;
    max-height: 220px;
    overflow: auto;
}

.logs-user-page .logs-card {
    border: 1px solid #e8ecf1;
    border-radius: 0.75rem;
    padding: .75rem;
    background: #fff;
}

.logs-user-page .logs-card+.logs-card {
    margin-top: .55rem;
}
</style>

<div class="tools-scope logs-user-page" data-is-admin="<?php echo $isAdmin ? '1' : '0'; ?>">
    <div class="row pb-3">
        <div class="container-fluid d-flex align-items-center justify-content-between flex-wrap gap-2">
            <div>
                <h3 class="mb-0">Auditoria de acciones de usuario</h3>
            </div>
            <div class="d-flex align-items-center gap-2">
                <button class="btn btn-sm btn-outline-secondary" id="f_reset" type="button">
                    <i class="bi bi-eraser"></i> Limpiar filtros
                </button>
                <button class="btn btn-sm btn-outline-primary" id="btnLogsReload" type="button"
                    title="Recargar listado">
                    <i class="bi bi-arrow-clockwise"></i> Recargar
                </button>
            </div>
        </div>
    </div>

    <div class="row g-2 mb-3">
        <div class="col-12 col-md-4">
            <div class="logs-kpi">
                <div class="kpi-label">Total de eventos visibles</div>
                <div class="kpi-value" id="logsCountBadge">0</div>
            </div>
        </div>
        <div class="col-12 col-md-4">
            <div class="logs-kpi">
                <div class="kpi-label">Eliminaciones logicas (pagina)</div>
                <div class="kpi-value text-warning" id="logsSoftDeleteBadge">0</div>
            </div>
        </div>
        <div class="col-12 col-md-4">
            <div class="logs-kpi">
                <div class="kpi-label">Restauraciones (pagina)</div>
                <div class="kpi-value text-primary" id="logsRestoreBadge">0</div>
            </div>
        </div>
    </div>

    <div class="card mb-4 border-0 shadow-sm">
        <div class="card-body">
            <div class="logs-filters mb-3">
                <div class="row g-2 align-items-end">
                    <div class="col-12 col-lg-4">
                        <label class="form-label form-label-sm mb-1 d-flex align-items-center gap-1" for="f_q">
                            Buscar
                            <button class="help-tip" type="button"
                                data-help="Busca por usuario, modulo, operacion, PK o texto tecnico."
                                data-bs-toggle="tooltip"
                                title="Busca por usuario, modulo, operacion, PK o texto tecnico."
                                aria-label="Ayuda de busqueda">
                                <i class="bi bi-question-circle"></i>
                            </button>
                        </label>
                        <div class="input-group input-group-sm">
                            <span class="input-group-text"><i class="bi bi-search"></i></span>
                            <input type="text" class="form-control" id="f_q"
                                placeholder="Ej: M-001, SOFT_DELETE, orden_trabajo...">
                            <button class="btn btn-outline-secondary" id="f_q_clear" type="button"
                                title="Limpiar texto">
                                <i class="bi bi-x-lg"></i>
                            </button>
                        </div>
                    </div>

                    <div class="col-6 col-md-3 col-lg-2">
                        <label class="form-label form-label-sm mb-1 d-flex align-items-center gap-1" for="f_tabla">
                            Modulo
                            <button class="help-tip" type="button"
                                data-help="Tabla o modulo del sistema que genero el evento." data-bs-toggle="tooltip"
                                title="Tabla o modulo del sistema que genero el evento." aria-label="Ayuda de modulo">
                                <i class="bi bi-question-circle"></i>
                            </button>
                        </label>
                        <select class="form-select form-select-sm" id="f_tabla">
                            <option value="">Todos</option>
                        </select>
                    </div>

                    <div class="col-6 col-md-3 col-lg-2">
                        <label class="form-label form-label-sm mb-1 d-flex align-items-center gap-1" for="f_operacion">
                            Operacion
                            <button class="help-tip" type="button"
                                data-help="Tipo tecnico de evento: INSERT, UPDATE, SOFT_DELETE, RESTORE, etc."
                                data-bs-toggle="tooltip"
                                title="Tipo tecnico de evento: INSERT, UPDATE, SOFT_DELETE, RESTORE, etc."
                                aria-label="Ayuda de operacion">
                                <i class="bi bi-question-circle"></i>
                            </button>
                        </label>
                        <select class="form-select form-select-sm" id="f_operacion">
                            <option value="">Todas</option>
                        </select>
                    </div>

                    <div class="col-12 col-md-6 col-lg-2">
                        <label class="form-label form-label-sm mb-1 d-flex align-items-center gap-1" for="f_usuario">
                            Usuario
                            <button class="help-tip" type="button"
                                data-help="Usuario de aplicacion relacionado al evento." data-bs-toggle="tooltip"
                                title="Usuario de aplicacion relacionado al evento." aria-label="Ayuda de usuario">
                                <i class="bi bi-question-circle"></i>
                            </button>
                        </label>
                        <select class="form-select form-select-sm" id="f_usuario">
                            <option value="">Todos</option>
                        </select>
                    </div>

                    <div class="col-6 col-md-3 col-lg-2">
                        <label class="form-label form-label-sm mb-1 d-flex align-items-center gap-1" for="f_estado_log">
                            Estado logico
                            <button class="help-tip" type="button"
                                data-help="Activos: visibles. Restaurados: ocultados despues de restaurar."
                                data-bs-toggle="tooltip"
                                title="Activos: visibles. Restaurados: ocultados despues de restaurar."
                                aria-label="Ayuda de estado logico">
                                <i class="bi bi-question-circle"></i>
                            </button>
                        </label>
                        <select class="form-select form-select-sm" id="f_estado_log">
                            <option value="active">Activos</option>
                            <option value="restored">Restaurados</option>
                            <option value="all">Todos</option>
                        </select>
                    </div>

                    <div class="col-6 col-md-3 col-lg-1">
                        <label class="form-label form-label-sm mb-1" for="f_perPage">Items</label>
                        <select class="form-select form-select-sm" id="f_perPage">
                            <option value="10">10</option>
                            <option value="20" selected>20</option>
                            <option value="50">50</option>
                            <option value="100">100</option>
                        </select>
                    </div>

                    <div class="col-6 col-md-3 col-lg-2">
                        <label class="form-label form-label-sm mb-1" for="f_desde">Desde</label>
                        <input type="date" class="form-control form-control-sm" id="f_desde">
                    </div>

                    <div class="col-6 col-md-3 col-lg-2">
                        <label class="form-label form-label-sm mb-1" for="f_hasta">Hasta</label>
                        <input type="date" class="form-control form-control-sm" id="f_hasta">
                    </div>
                </div>
            </div>

            <div class="border rounded overflow-hidden">
                <div class="d-none d-md-block">
                    <div class="table-responsive" style="max-height:65vh; overflow:auto;">
                        <table class="table table-sm table-hover mb-0 logs-table" id="logsTable">
                            <thead class="table-light">
                                <tr class="align-middle">
                                    <th class="text-nowrap" style="width:60px;">#</th>
                                    <th class="logs-col-date">Fecha</th>
                                    <th class="text-nowrap">Usuario</th>
                                    <th class="text-nowrap">Modulo</th>
                                    <th>Accion</th>
                                    <th>Detalles</th>
                                    <th class="text-nowrap">Estado</th>
                                    <th class="logs-col-record">Registro</th>
                                    <th class="text-center text-nowrap" style="width:80px;">Detalle</th>
                                </tr>
                            </thead>
                            <tbody></tbody>
                        </table>
                    </div>
                </div>
                <div class="d-md-none p-2" id="logsCards"></div>
            </div>

            <div class="d-flex justify-content-between align-items-center mt-3 flex-wrap gap-2">
                <small class="text-muted" id="logsMeta">-</small>
                <div class="d-flex gap-2 align-items-center">
                    <button class="btn btn-sm btn-outline-secondary" id="btnPrev" type="button">Anterior</button>
                    <span class="small" id="pageLabel">1 / 1</span>
                    <button class="btn btn-sm btn-outline-secondary" id="btnNext" type="button">Siguiente</button>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="offcanvas offcanvas-end" tabindex="-1" id="logViewer" aria-labelledby="logViewerLabel">
    <div class="offcanvas-header">
        <h5 class="offcanvas-title" id="logViewerLabel">Detalle del evento</h5>
        <button type="button" class="btn-close" data-bs-dismiss="offcanvas"></button>
    </div>
    <div class="offcanvas-body">
        <div class="border rounded p-3 mb-3 bg-light">
            <div class="d-flex justify-content-between align-items-start gap-2">
                <div>
                    <div class="small text-muted">Interpretacion</div>
                    <div class="fw-semibold" id="v_title">-</div>
                    <div class="small text-muted" id="v_sub">-</div>
                </div>
                <span class="badge bg-secondary" id="v_state">-</span>
            </div>
        </div>

        <div class="row g-2 mb-3">
            <div class="col-6">
                <div class="small text-muted">Usuario</div>
                <div class="fw-semibold" id="v_user">-</div>
            </div>
            <div class="col-6">
                <div class="small text-muted">Fecha</div>
                <div class="fw-semibold" id="v_date">-</div>
            </div>
            <div class="col-6">
                <div class="small text-muted">Modulo</div>
                <div class="fw-semibold" id="v_table">-</div>
            </div>
            <div class="col-6">
                <div class="small text-muted">Operacion tecnica</div>
                <div class="fw-semibold" id="v_op">-</div>
            </div>
            <div class="col-12">
                <div class="small text-muted">Registro afectado</div>
                <div class="fw-semibold font-monospace" id="v_pk">-</div>
                <div class="small text-muted" id="v_pk_tech">PK tecnica: -</div>
            </div>
            <div class="col-12">
                <div class="small text-muted">UUID del evento</div>
                <div class="fw-semibold font-monospace" id="v_uuid">-</div>
            </div>
            <div class="col-12">
                <div class="small text-muted">Campos modificados</div>
                <div class="fw-semibold" id="v_changed_cols">-</div>
            </div>
            <div class="col-12">
                <div class="small text-muted">Detalle tecnico del sistema</div>
                <div class="small border rounded p-2" style="white-space:pre-wrap;" id="v_resp">-</div>
            </div>
        </div>

        <div class="accordion mb-3" id="logDetailAccordion">
            <div class="accordion-item">
                <h2 class="accordion-header" id="hPkJson">
                    <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse"
                        data-bs-target="#cPkJson" aria-expanded="false" aria-controls="cPkJson">
                        PK en JSON
                    </button>
                </h2>
                <div id="cPkJson" class="accordion-collapse collapse" aria-labelledby="hPkJson"
                    data-bs-parent="#logDetailAccordion">
                    <div class="accordion-body">
                        <pre class="logs-json" id="v_pk_json">-</pre>
                    </div>
                </div>
            </div>
            <div class="accordion-item">
                <h2 class="accordion-header" id="hOld">
                    <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse"
                        data-bs-target="#cOld" aria-expanded="false" aria-controls="cOld">
                        Datos anteriores (data_old)
                    </button>
                </h2>
                <div id="cOld" class="accordion-collapse collapse" aria-labelledby="hOld"
                    data-bs-parent="#logDetailAccordion">
                    <div class="accordion-body">
                        <pre class="logs-json" id="v_old">-</pre>
                    </div>
                </div>
            </div>
            <div class="accordion-item">
                <h2 class="accordion-header" id="hNew">
                    <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse"
                        data-bs-target="#cNew" aria-expanded="false" aria-controls="cNew">
                        Datos nuevos (data_new)
                    </button>
                </h2>
                <div id="cNew" class="accordion-collapse collapse" aria-labelledby="hNew"
                    data-bs-parent="#logDetailAccordion">
                    <div class="accordion-body">
                        <pre class="logs-json" id="v_new">-</pre>
                    </div>
                </div>
            </div>
            <div class="accordion-item">
                <h2 class="accordion-header" id="hDiff">
                    <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse"
                        data-bs-target="#cDiff" aria-expanded="false" aria-controls="cDiff">
                        Diferencias (data_diff)
                    </button>
                </h2>
                <div id="cDiff" class="accordion-collapse collapse" aria-labelledby="hDiff"
                    data-bs-parent="#logDetailAccordion">
                    <div class="accordion-body">
                        <pre class="logs-json" id="v_diff">-</pre>
                    </div>
                </div>
            </div>
        </div>

        <div class="d-grid gap-2">
            <button class="btn btn-primary" id="btnRestore" type="button" style="display:none;">
                <i class="bi bi-arrow-counterclockwise"></i> Restaurar registro eliminado logicamente
            </button>
            <small class="text-muted" id="restoreHint"></small>
        </div>
    </div>
</div>

<script src="<?php echo APP_URL; ?>app/views/js/logsView.js?v=3"></script>
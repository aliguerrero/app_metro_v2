<?php
// app/views/content/reporte-view.php

$perms = $_SESSION['permisos'] ?? [];
$can = function (string $key) use ($perms): bool {
    return isset($perms[$key]) && (int)$perms[$key] === 1;
};

if (!$can('perm_ot_view') && !$can('perm_ot_generar_reporte')) {
    echo '<div class="alert alert-danger mt-3">Acceso denegado: no tienes permisos para reportes.</div>';
    return;
}
?>

<div class="container-fluid mt-3">
    <style>
        #report-builder .card,
        #report-preview .card {
            min-height: 580px;
        }

        #report-preview .preview-wrapper {
            min-height: 64vh;
        }

        @media (min-width: 992px) {
            #report-preview .preview-wrapper {
                min-height: 78vh;
            }
        }

        @media (max-width: 991px) {
            #report-builder .card,
            #report-preview .card {
                min-height: auto;
            }
        }

        #previewFrame {
            border: 0;
            background: #eef2f7;
        }
    </style>

    <div class="row g-3 align-items-stretch">
        <div class="col-12 col-lg-3" id="report-builder">
            <div class="card shadow-sm h-100">
                <div class="card-header d-flex align-items-center justify-content-between">
                    <div>
                        <h5 class="mb-0">Constructor de Reportes</h5>
                        <small class="text-muted">Selecciona tipo, filtros y formato</small>
                    </div>
                    <button
                        class="btn btn-outline-dark btn-sm"
                        id="btn_abrir_reportes_generados"
                        type="button"
                        data-bs-toggle="modal"
                        data-bs-target="#modalReportesGenerados"
                    >
                        <i class="bi bi-folder2-open"></i> Reportes generados
                    </button>
                </div>

                <div class="card-body d-flex flex-column">
                    <div class="flex-grow-1">
                        <div class="mb-3">
                            <label class="form-label"><b>Tipo de reporte</b></label>
                            <select id="tipo_reporte" class="form-select">
                                <option value="">Seleccione...</option>
                                <option value="ot_resumen">OT (Resumen)</option>
                                <option value="ot_detallado">OT (Detallado)</option>
                                <option value="herramientas">Herramientas</option>
                                <option value="miembros">Miembros</option>
                                <option value="usuarios">Usuarios</option>
                            </select>
                        </div>

                        <div class="row g-2 mb-3">
                            <div class="col-6">
                                <label class="form-label"><b>Papel</b></label>
                                <select id="papel" class="form-select">
                                    <option value="A4" selected>A4</option>
                                    <option value="LETTER">Carta</option>
                                </select>
                            </div>
                            <div class="col-6">
                                <label class="form-label"><b>Orientacion</b></label>
                                <select id="orientacion" class="form-select">
                                    <option value="portrait" selected>Vertical</option>
                                    <option value="landscape">Horizontal</option>
                                </select>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label"><b>Encabezado</b></label>
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" id="incluir_membrete" checked>
                                <label class="form-check-label" for="incluir_membrete">Incluir membrete</label>
                            </div>
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" id="incluir_logo" checked>
                                <label class="form-check-label" for="incluir_logo">Incluir logo</label>
                            </div>
                        </div>

                        <hr>

                        <div id="filtros_ot" style="display:none;">
                            <div class="mb-2">
                                <label class="form-label"><b>Nro. OT</b> (opcional)</label>
                                <input type="text" class="form-control" id="f_n_ot" placeholder="Ej: 000123">
                                <small class="text-muted">En OT Detallado, si colocas Nro. OT genera el reporte de esa OT.</small>
                            </div>

                            <div class="row g-2 mb-2">
                                <div class="col-6">
                                    <label class="form-label"><b>Desde</b></label>
                                    <input type="date" class="form-control" id="f_desde">
                                </div>
                                <div class="col-6">
                                    <label class="form-label"><b>Hasta</b></label>
                                    <input type="date" class="form-control" id="f_hasta">
                                </div>
                            </div>

                            <div class="mb-2">
                                <label class="form-label"><b>Area</b></label>
                                <select id="f_area" class="form-select">
                                    <option value="">Todas</option>
                                </select>
                            </div>

                            <div class="mb-2">
                                <label class="form-label"><b>Sitio</b></label>
                                <select id="f_sitio" class="form-select">
                                    <option value="">Todos</option>
                                </select>
                            </div>

                            <div class="mb-2">
                                <label class="form-label"><b>Estado</b></label>
                                <select id="f_estado" class="form-select">
                                    <option value="">Todos</option>
                                </select>
                            </div>

                            <div class="mb-2">
                                <label class="form-label"><b>Operador/Tecnico</b></label>
                                <select id="f_usuario" class="form-select">
                                    <option value="">Todos</option>
                                </select>
                            </div>
                        </div>

                        <div id="filtros_general" style="display:none;">
                            <div class="mb-2">
                                <label class="form-label"><b>Buscar</b></label>
                                <input type="text" class="form-control" id="f_q" placeholder="Escribe para filtrar...">
                                <small class="text-muted">Filtra mientras escribes (si queda vacio, muestra todo).</small>
                            </div>
                        </div>
                    </div>

                    <hr class="my-3 mb-0">

                    <div class="mt-3">
                        <div class="d-grid gap-2">
                            <button class="btn btn-primary" id="btn_previsualizar">
                                <i class="bi bi-eye"></i> Previsualizar
                            </button>

                            <button class="btn btn-danger" id="btn_pdf">
                                <i class="bi bi-filetype-pdf"></i> Descargar PDF
                            </button>
                        </div>

                        <div class="mt-3">
                            <div class="alert alert-info mb-0">
                                <small>La vista previa se genera en HTML a la derecha.</small>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-12 col-lg-9" id="report-preview">
            <div class="card shadow-sm h-100">
                <div class="card-header d-flex align-items-center justify-content-between">
                    <div>
                        <h5 class="mb-0">Vista previa</h5>
                        <small class="text-muted">Se actualiza al previsualizar y tambien automaticamente</small>
                    </div>
                    <button class="btn btn-outline-secondary btn-sm" id="btn_limpiar_preview" type="button">
                        Limpiar
                    </button>
                </div>

                <div class="card-body p-0 d-flex flex-column">
                    <div class="preview-wrapper flex-grow-1 position-relative">
                        <iframe id="previewFrame" class="w-100 h-100" sandbox="allow-scripts"></iframe>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="modalReportesGenerados" tabindex="-1" aria-labelledby="modalReportesGeneradosLabel" aria-hidden="true">
    <div class="modal-dialog modal-xl modal-dialog-scrollable">
        <div class="modal-content">
            <div class="modal-header">
                <div>
                    <h5 class="modal-title mb-0" id="modalReportesGeneradosLabel">Reportes Generados</h5>
                    <small class="text-muted">Historial de PDFs guardados con usuario, fecha y acciones</small>
                </div>
                <div class="d-flex align-items-center gap-2">
                    <button class="btn btn-outline-secondary btn-sm" id="btn_recargar_reportes_modal" type="button">
                        <i class="bi bi-arrow-clockwise"></i> Recargar
                    </button>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
                </div>
            </div>
            <div class="modal-body p-0">
                <div id="reportesGeneradosWrap" class="p-3">
                    <div class="text-muted">Abre este modal para cargar el historial de reportes.</div>
                </div>
            </div>
        </div>
    </div>
</div>

<?php require_once "./app/views/scripts/script-reporte.php"; ?>

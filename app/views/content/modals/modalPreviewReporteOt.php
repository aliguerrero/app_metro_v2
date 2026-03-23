<style>
    #modalPreviewReporteOt .modal-dialog.modal-reporte-ot {
        max-width: min(96vw, 1560px);
        margin: 1rem auto;
    }

    #modalPreviewReporteOt .modal-content {
        min-height: calc(100vh - 2rem);
    }

    #modalPreviewReporteOt .modal-body {
        padding: 1rem 1rem 1.25rem;
    }

    #previewReporteOtFrame {
        width: 100%;
        min-height: 78vh;
        border: 1px solid #dee2e6;
        border-radius: .85rem;
        background: #fff;
    }

    @media (max-width: 991.98px) {
        #modalPreviewReporteOt .modal-dialog.modal-reporte-ot {
            max-width: 100vw;
            margin: 0;
        }

        #modalPreviewReporteOt .modal-content {
            min-height: 100vh;
            border-radius: 0;
        }

        #previewReporteOtFrame {
            min-height: 74vh;
        }
    }
</style>

<div class="modal fade" id="modalPreviewReporteOt" tabindex="-1" aria-labelledby="modalPreviewReporteOtLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable modal-reporte-ot">
        <div class="modal-content">
            <div class="modal-header">
                <div>
                    <h5 class="modal-title mb-0" id="modalPreviewReporteOtLabel">Reporte detallado de O.T.</h5>
                    <small class="text-muted" id="modalPreviewReporteOtMeta">Vista previa del reporte.</small>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
            </div>

            <div class="modal-body">
                <input type="hidden" id="previewReporteOtCodigo" value="">

                <div class="d-flex flex-wrap gap-2 align-items-center p-2 border rounded mb-3">
                    <span class="badge bg-dark px-3 py-2" id="previewReporteOtBadge">-</span>
                    <span class="text-muted small">El PDF descargado se registrara en <b>reporte_generado</b>.</span>
                </div>

                <div id="previewReporteOtEstado" class="mb-3 text-muted">Generando vista previa...</div>

                <iframe id="previewReporteOtFrame" title="Vista previa reporte O.T."></iframe>
            </div>

            <div class="modal-footer justify-content-between">
                <small class="text-muted">La vista previa no altera la base de datos. El registro se genera al descargar el PDF.</small>
                <div class="d-flex gap-2">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cerrar</button>
                    <button type="button" class="btn btn-primary" id="btnDescargarReporteOtPdf">
                        <i class="bi bi-download"></i> Descargar PDF
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>

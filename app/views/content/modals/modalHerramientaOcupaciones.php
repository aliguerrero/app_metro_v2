<div class="modal fade herramienta-ocupaciones-modal" id="herramientaOcupacionesModal" tabindex="-1" aria-labelledby="herramientaOcupacionesModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-xxl-wide herramienta-ocupaciones-dialog modal-dialog-centered modal-dialog-scrollable modal-fullscreen-sm-down">
        <div class="modal-content">
            <div class="modal-header">
                <div>
                    <h5 class="modal-title mb-0" id="herramientaOcupacionesModalLabel">Herramienta ocupada en O.T.</h5>
                    <small class="text-muted">Consulta las O.T. activas que tienen esta herramienta asignada y el tecnico responsable para contacto.</small>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar">X</button>
            </div>

            <div class="modal-body">
                <div class="d-flex flex-wrap align-items-center gap-2 p-2 border rounded mb-3">
                    <span class="badge bg-dark px-3 py-2" id="ocupHerrToolCode">-</span>
                    <span class="fw-semibold" id="ocupHerrToolName">-</span>
                    <span class="ms-auto text-muted small" id="ocupHerrToolSummary"></span>
                </div>

                <div class="overflow-auto border rounded herramienta-ocupaciones-shell">
                    <div class="d-none d-md-block">
                        <table class="table table-sm table-hover mb-0" id="ocupHerrTable">
                            <thead class="table-light">
                                <tr class="align-middle">
                                    <th>#</th>
                                    <th>O.T.</th>
                                    <th>Trabajo</th>
                                    <th class="text-center">Cant.</th>
                                    <th>Estado O.T.</th>
                                    <th>Tecnico responsable</th>
                                    <th>Telefono</th>
                                    <th>Correo</th>
                                </tr>
                            </thead>
                            <tbody></tbody>
                        </table>
                    </div>

                    <div class="d-md-none p-2" id="ocupHerrCards"></div>
                </div>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cerrar</button>
            </div>
        </div>
    </div>
</div>

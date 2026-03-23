<!-- MODAL: Herramientas para O.T. -->
<div class="modal fade" id="ModificarHerrOt" tabindex="-1" aria-labelledby="ModificarHerrOtLabel" aria-hidden="true">
    <div class="modal-dialog modal-xl modal-dialog-centered modal-dialog-scrollable modal-fullscreen-sm-down modal-xxl-wide">
        <div class="modal-content">

            <div class="modal-header align-items-start">
                <div class="d-flex align-items-center gap-3">
                    <div>
                        <h5 class="modal-title mb-0" id="ModificarHerrOtLabel">Herramientas para Orden de Trabajo</h5>
                        <small class="text-muted">Asigna herramientas y revisa disponibilidad para esta O.T.</small>
                    </div>
                </div>

                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar">
                    <i class="bi bi-x-lg"></i>
                </button>
            </div>

            <div class="modal-body">
                <div class="d-flex flex-wrap align-items-center gap-2 p-2 border rounded mb-3">
                    <span class="badge bg-dark px-3 py-2" id="otCodigoBadge">-</span>
                    <span class="fw-semibold text-uppercase" id="otNombreBadge">-</span>
                    <span class="ms-auto text-muted small" id="otMetaBadge"></span>
                </div>

                <input type="hidden" id="otCodigoHidden" value="">

                <div class="row g-3">
                    <div class="col-12 col-lg-6">
                        <div class="card h-100">
                            <div class="card-header d-flex align-items-center gap-2">
                                <strong class="me-auto">Inventario</strong>
                                <span class="badge bg-secondary" id="invCount">0</span>
                                <button type="button" class="btn btn-sm btn-secondary" id="btnInvReload" title="Recargar">
                                    <i class="bi bi-arrow-clockwise"></i>
                                </button>
                            </div>

                            <div class="card-body p-2">
                                <div class="input-group input-group-sm mb-2">
                                    <span class="input-group-text"><i class="bi bi-search"></i></span>
                                    <input class="form-control" id="invSearch" type="text" placeholder="Buscar por codigo o nombre">
                                    <button class="btn btn-secondary" type="button" id="invClear" title="Limpiar">
                                        <i class="bi bi-x-lg"></i>
                                    </button>
                                </div>

                                <div class="overflow-auto border rounded" style="max-height:55vh;">
                                    <div class="d-none d-md-block">
                                        <table class="table table-sm table-hover mb-0" id="invTable">
                                            <thead class="table-light">
                                                <tr class="align-middle">
                                                    <th class="col-p">#</th>
                                                    <th class="col-p">Codigo</th>
                                                    <th>Nombre</th>
                                                    <th class="text-center col-p">Disp.</th>
                                                    <th class="text-center col-p">En OT</th>
                                                    <th class="text-center col-p">Acciones</th>
                                                </tr>
                                            </thead>
                                            <tbody></tbody>
                                        </table>
                                    </div>

                                    <div class="d-md-none p-2" id="invCards"></div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-12 col-lg-6">
                        <div class="card h-100">
                            <div class="card-header d-flex align-items-center gap-2">
                                <strong class="me-auto">Asignadas a esta O.T.</strong>
                                <span class="badge bg-secondary" id="asigCount">0</span>
                                <button type="button" class="btn btn-sm btn-secondary" id="btnAsigReload" title="Recargar">
                                    <i class="bi bi-arrow-clockwise"></i>
                                </button>
                            </div>

                            <div class="card-body p-2">
                                <div class="input-group input-group-sm mb-2">
                                    <span class="input-group-text"><i class="bi bi-search"></i></span>
                                    <input class="form-control" id="asigSearch" type="text" placeholder="Buscar asignadas...">
                                    <button class="btn btn-secondary" type="button" id="asigClear" title="Limpiar">
                                        <i class="bi bi-x-lg"></i>
                                    </button>
                                </div>

                                <div class="overflow-auto border rounded" style="max-height:55vh;">
                                    <div class="d-none d-md-block">
                                        <table class="table table-sm table-hover mb-0" id="asigTable">
                                            <thead class="table-light">
                                                <tr class="align-middle">
                                                    <th class="col-p">#</th>
                                                    <th class="col-p">Codigo</th>
                                                    <th>Nombre</th>
                                                    <th class="text-center col-p">Cant.</th>
                                                    <th class="text-center col-p">Acciones</th>
                                                </tr>
                                            </thead>
                                            <tbody></tbody>
                                        </table>
                                    </div>

                                    <div class="d-md-none p-2" id="asigCards"></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="modal-footer d-flex justify-content-between">
                <small class="text-muted">Cada accion actualiza la disponibilidad en tiempo real.</small>
                <button type="button" class="btn btn-primary" data-bs-dismiss="modal">Cerrar</button>
            </div>

        </div>
    </div>
</div>

<script src="<?php echo APP_URL; ?>app/views/js/herramientasOtModal.js?v=5"></script>

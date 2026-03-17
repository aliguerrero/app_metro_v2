<!-- MODAL: Herramientas para O.T. (Nuevo) -->
<div class="modal fade" id="ModificarHerrOt" tabindex="-1" aria-labelledby="ModificarHerrOtLabel" aria-hidden="true">
    <div class="modal-dialog modal-xl modal-dialog-centered modal-dialog-scrollable modal-fullscreen-sm-down modal-xxl-wide">
        <div class="modal-content">

            <!-- HEADER -->
            <div class="modal-header align-items-start">
                <div class="d-flex align-items-center gap-3">
                    <div>
                        <h5 class="modal-title mb-0" id="ModificarHerrOtLabel">Herramientas para Orden de Trabajo</h5>
                        <small class="text-muted">Selecciona del inventario y asigna cantidades a la O.T.</small>
                    </div>
                </div>

                <button type="button" class="btn-close" data-bs-dismiss="modal">
                    <i class="bi bi-x-lg"></i> 
                </button>
            </div>

            <div class="modal-body">
                <!-- RESUMEN OT -->
                <div class="d-flex flex-wrap align-items-center gap-2 p-2 border rounded mb-3">
                    <span class="badge bg-dark px-3 py-2" id="otCodigoBadge">—</span>
                    <span class="fw-semibold text-uppercase" id="otNombreBadge">—</span>
                    <span class="ms-auto text-muted small" id="otMetaBadge"></span>
                </div>

                <!-- hidden OT -->
                <input type="hidden" id="otCodigoHidden" value="">

                <!-- GRID -->
                <div class="row g-3">

                    <!-- INVENTARIO -->
                    <div class="col-12 col-lg-6">
                        <div class="card h-100">
                            <div class="card-header d-flex align-items-center gap-2">
                                <strong class="me-auto">Inventario</strong>
                                <span class="badge bg-secondary" id="invCount">0</span>
                                <button type="button" class="btn btn-sm btn-outline-secondary" id="btnInvReload" title="Recargar">
                                    <i class="bi bi-arrow-clockwise"></i>
                                </button>
                            </div>

                            <div class="card-body p-2">
                                <div class="input-group input-group-sm mb-2">
                                    <span class="input-group-text"><i class="bi bi-search"></i></span>
                                    <input class="form-control" id="invSearch" type="text" placeholder="Buscar por código o nombre">
                                    <button class="btn btn-outline-secondary" type="button" id="invClear" title="Limpiar">
                                        <i class="bi bi-x-lg"></i>
                                    </button>
                                </div>

                                <div class="overflow-auto border rounded" style="max-height:55vh;">
                                    <!-- DESKTOP -->
                                    <div class="d-none d-md-block">
                                        <table class="table table-sm table-hover mb-0" id="invTable">
                                            <thead class="table-light">
                                                <tr class="align-middle">
                                                    <th class="col-p">#</th>
                                                    <th class="col-p">Código</th>
                                                    <th>Nombre</th>
                                                    <th class="text-center col-p">Disp.</th>
                                                    <th class="text-center col-p">En OT</th>
                                                    <th class="text-center col-p">Acción</th>
                                                </tr>
                                            </thead>
                                            <tbody></tbody>
                                        </table>
                                    </div>

                                    <!-- MOVIL -->
                                    <div class="d-md-none p-2" id="invCards"></div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- ASIGNADAS -->
                    <div class="col-12 col-lg-6">
                        <div class="card h-100">
                            <div class="card-header d-flex align-items-center gap-2">
                                <strong class="me-auto">Asignadas a esta O.T.</strong>
                                <span class="badge bg-secondary" id="asigCount">0</span>
                                <button type="button" class="btn btn-sm btn-outline-secondary" id="btnAsigReload" title="Recargar">
                                    <i class="bi bi-arrow-clockwise"></i>
                                </button>
                            </div>

                            <div class="card-body p-2">
                                <div class="input-group input-group-sm mb-2">
                                    <span class="input-group-text"><i class="bi bi-search"></i></span>
                                    <input class="form-control" id="asigSearch" type="text" placeholder="Buscar asignadas...">
                                    <button class="btn btn-outline-secondary" type="button" id="asigClear" title="Limpiar">
                                        <i class="bi bi-x-lg"></i>
                                    </button>
                                </div>

                                <div class="overflow-auto border rounded" style="max-height:55vh;">
                                    <!-- DESKTOP -->
                                    <div class="d-none d-md-block">
                                        <table class="table table-sm table-hover mb-0" id="asigTable">
                                            <thead class="table-light">
                                                <tr class="align-middle">
                                                    <th class="col-p">#</th>
                                                    <th class="col-p">Código</th>
                                                    <th>Nombre</th>
                                                    <th class="text-center col-p">Cant.</th>
                                                    <th class="text-center col-p">Acción</th>
                                                </tr>
                                            </thead>
                                            <tbody></tbody>
                                        </table>
                                    </div>

                                    <!-- MOVIL -->
                                    <div class="d-md-none p-2" id="asigCards"></div>
                                </div>

                            </div>
                        </div>
                    </div>

                </div>
            </div>

            <div class="modal-footer d-flex justify-content-between">
                <small class="text-muted">Los cambios se guardan al asignar / editar / quitar.</small>
                <button type="button" class="btn btn-primary" data-bs-dismiss="modal">Cerrar</button>
            </div>

        </div>
    </div>
</div>

<script src="<?php echo APP_URL; ?>app/views/js/herramientasOtModal.js?v=3"></script>
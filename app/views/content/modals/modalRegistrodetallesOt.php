<!-- MODAL: Detalles OT -->
<div class="modal fade" id="detallesOt" tabindex="-1" aria-labelledby="detallesOtLabel" aria-hidden="true">
    <div class="modal-dialog modal-xl modal-dialog-centered modal-dialog-scrollable modal-fullscreen-sm-down detalles-ot-dialog">
        <div class="modal-content">

            <div class="modal-header align-items-center">
                <div class="d-flex align-items-center gap-3">
                    <i class="bx bx-clipboard fs-2 text-primary" aria-hidden="true"></i>
                    <div>
                        <h5 class="modal-title mb-0" id="detallesOtLabel">Detalles de Orden de Trabajo</h5>
                        <small class="text-muted">Consulta, busca y administra los detalles registrados de la O.T.</small>
                    </div>
                </div>

                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar">X</button>
            </div>

            <div class="modal-body">
                <div class="d-flex flex-wrap align-items-center gap-2 p-2 border rounded mb-3">
                    <span class="badge bg-dark px-3 py-2" id="codigoOt">-</span>
                    <span class="fw-semibold text-uppercase" id="nombreOt">-</span>
                    <span class="ms-auto text-muted small" id="metaOt"></span>
                </div>

                <div class="alert alert-warning border-0 shadow-sm d-none" id="detalleOtLockNotice" role="alert">
                    Esta O.T. esta bloqueada. Solo puedes consultar los detalles existentes.
                </div>

                <div class="card shadow-sm border-0">
                    <div class="card-header d-flex flex-wrap gap-2 align-items-center">
                        <strong class="me-auto">Lista de detalles registrados</strong>

                        <div class="input-group input-group-sm" style="max-width: 260px;">
                            <span class="input-group-text"><i class="bi bi-search"></i></span>
                            <input type="text" class="form-control" id="buscarDetalle" placeholder="Buscar por fecha, descripcion o tecnico...">
                        </div>

                        <div class="btn-group btn-group-sm" role="group">
                            <button type="button" class="btn btn-outline-primary" id="btnRecargarDetalle" title="Recargar lista">
                                <i class="bi bi-arrow-clockwise"></i>
                            </button>

                            <?php if (isset($can) && $can('perm_ot_add_detalle')) { ?>
                                <button type="button" class="btn btn-success" id="btnNuevoDetalleOt" title="Registrar nuevo detalle">
                                    <i class="bi bi-plus-lg"></i> Nuevo detalle
                                </button>
                            <?php } ?>
                        </div>
                    </div>

                    <div class="card-body p-2">
                        <div class="overflow-auto" style="max-height:68vh;">
                            <?php echo $insOt->listarDetalles(); ?>
                        </div>
                    </div>
                </div>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal" onclick="cerrarVentana()">
                    Cerrar
                </button>
            </div>

        </div>
    </div>
</div>

<!-- MODAL: Formulario de detalle -->
<div class="modal fade" id="detalleOtFormModal" tabindex="-1" aria-labelledby="detalleOtFormModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable modal-fullscreen-sm-down">
        <div class="modal-content">
            <div class="modal-header">
                <div>
                    <h5 class="modal-title mb-0" id="detalleOtFormModalLabel">Registrar detalle</h5>
                    <small class="text-muted" id="modoEdicionLabel">Nuevo</small>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar">X</button>
            </div>

            <div class="modal-body" id="contenedorFormularioDetalle">
                <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-3 pb-2 border-bottom">
                    <div class="d-flex flex-wrap align-items-center gap-2">
                        <span class="badge bg-dark px-3 py-2" id="detalleFormCodigoOt">-</span>
                        <span class="text-muted small" id="detalleFormMeta">Completa la informacion del detalle.</span>
                    </div>
                    <small class="text-muted"><span class="text-danger fw-bold">*</span> Campo obligatorio</small>
                </div>

                <form id="formDetalleOt" action="<?php echo APP_URL; ?>app/controllers/cargarDatosDetalle.php" method="POST">
                    <input type="hidden" name="tipo" id="tipo" value="guardar">
                    <input type="hidden" name="codigo" id="id" value="">
                    <input type="hidden" name="id" id="id2" value="">

                    <div class="row g-3">
                        <div class="col-12 col-md-4">
                            <label class="form-label">
                                Fecha <span class="text-danger fw-bold">*</span>
                            </label>
                            <input type="date" class="form-control" id="fecha" name="fecha">
                        </div>

                        <div class="col-12">
                            <label class="form-label">
                                Descripcion <span class="text-danger fw-bold">*</span>
                            </label>
                            <textarea id="desc" name="desc" class="form-control" rows="3" maxlength="250" placeholder="Descripcion del trabajo realizado"></textarea>
                        </div>

                        <div class="col-12 col-md-6">
                            <label class="form-label">
                                Cant. Operador(es) <span class="text-danger fw-bold">*</span>
                            </label>
                            <input class="form-control" id="cant" name="cant" type="number" min="0" placeholder="Cantidad de operadores">
                        </div>

                        <div class="col-12 col-md-6">
                            <label class="form-label">
                                Turno <span class="text-danger fw-bold">*</span>
                            </label>
                            <?php echo $insOt->listarComboTurnoControlador(); ?>
                        </div>

                        <div class="col-12 col-md-6">
                            <label class="form-label">
                                CCO <span class="text-danger fw-bold">*</span>
                            </label>
                            <?php echo $insOt->listarComboOtControlador(2); ?>
                        </div>

                        <div class="col-12 col-md-6">
                            <label class="form-label">
                                CCF <span class="text-danger fw-bold">*</span>
                            </label>
                            <?php echo $insOt->listarComboOtControlador(1); ?>
                        </div>

                        <div class="col-12">
                            <label class="form-label">
                                Tecnico <span class="text-danger fw-bold">*</span>
                            </label>
                            <?php echo $insOt->listarComboTecControlador(); ?>
                        </div>

                        <div class="col-12 detalle-time-row">
                            <div class="row g-3">
                                <div class="col-12 col-md-6">
                                    <label class="form-label fw-semibold">
                                        Hora de inicio <span class="text-danger fw-bold">*</span>
                                    </label>
                                    <div class="input-group">
                                        <span class="input-group-text">Ini</span>
                                        <input type="time" class="form-control" id="hora_inicio" name="hora_inicio">
                                    </div>
                                </div>

                                <div class="col-12 col-md-6">
                                    <label class="form-label fw-semibold">
                                        Hora de fin <span class="text-danger fw-bold">*</span>
                                    </label>
                                    <div class="input-group">
                                        <span class="input-group-text">Fin</span>
                                        <input type="time" class="form-control" id="hora_fin" name="hora_fin">
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="col-12">
                            <label class="form-label">
                                Observacion <small class="text-muted">(opcional)</small>
                            </label>
                            <textarea id="observacion" name="observacion" class="form-control" rows="3" maxlength="250"></textarea>
                        </div>
                    </div>
                </form>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cerrar</button>
                <?php if (isset($can) && $can('perm_ot_add_detalle')) { ?>
                    <button type="submit" class="btn btn-success" id="btnGuardarDetalleOt" form="formDetalleOt">
                        <i class="bi bi-save"></i> Guardar
                    </button>
                <?php } ?>
            </div>
        </div>
    </div>
</div>

<script>
    document.addEventListener('input', (e) => {
        if (e.target.id !== 'buscarDetalle') return;
        const q = e.target.value.toLowerCase().trim();

        const table = document.getElementById('tablaDetalles');
        if (table) {
            table.querySelectorAll('tbody tr').forEach(tr => {
                const text = tr.innerText.toLowerCase();
                tr.style.display = text.includes(q) ? '' : 'none';
            });
        }

        const cards = document.getElementById('detalleCards');
        if (cards) {
            cards.querySelectorAll('.tool-card').forEach(card => {
                const text = card.innerText.toLowerCase();
                card.style.display = text.includes(q) ? '' : 'none';
            });
        }
    });
</script>

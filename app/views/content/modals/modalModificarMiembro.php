<?php
$insMiembroModal = isset($insMiembro) ? $insMiembro : new \app\controllers\miembroController();
?>
<div class="modal fade miembro-modal-shell" id="ventanaModalModificarMiem" tabindex="-1" aria-labelledby="ventanaModalModificarMiemLabel" aria-hidden="true">
    <div class="modal-dialog modal-fullscreen-md-down modal-dialog-centered modal-dialog-scrollable miembro-modal-dialog">
        <div class="modal-content miembro-modal-content">
            <div class="modal-header">
                <i class="bx bx-edit-alt fs-1 me-2 text-primary" aria-hidden="true"></i>
                <h5 class="modal-title" id="ventanaModalModificarMiemLabel">Actualizar miembro</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close">X</button>
            </div>
            <div class="modal-body">
                <form class="row g-3 FormularioAjax" action="<?php echo APP_URL ?>app/ajax/miembroAjax.php" method="POST" id="formEditarMiembro">
                    <input type="hidden" name="modulo_miembro" value="modificar">
                    <input type="hidden" name="id" id="miembro_id_edicion">

                    <div class="col-12 col-xl-3">
                        <label class="form-label"><b>CODIGO</b></label>
                        <input class="form-control" id="codigo_edicion_miembro" type="text" value="" readonly>
                        <small class="text-muted">El codigo se conserva para no afectar historicos.</small>
                    </div>

                    <div class="col-12 col-xl-9">
                        <label class="form-label"><b>EMPLEADO</b></label>
                        <?php echo $insMiembroModal->listarComboEmpleadoMiembroControlador('id_empleado', 'id_empleado_edicion'); ?>
                    </div>

                    <div class="col-md-12">
                        <div class="alert d-none mb-0" id="estadoEmpleadoEdicionMiembro" role="alert"></div>
                    </div>

                    <div class="col-md-12">
                        <div class="miembro-empleado-panel">
                            <div class="row g-3">
                                <div class="col-12 col-lg-4">
                                    <label class="form-label mb-1">Empleado seleccionado</label>
                                    <div class="miembro-empleado-value" id="resumenNombreEdicionMiembro">Sin seleccionar</div>
                                </div>
                                <div class="col-12 col-md-4 col-lg-3">
                                    <label class="form-label mb-1">Documento</label>
                                    <div class="miembro-empleado-value" id="resumenDocumentoEdicionMiembro">-</div>
                                </div>
                                <div class="col-12 col-md-8 col-lg-5">
                                    <label class="form-label mb-1">Contacto</label>
                                    <div class="miembro-empleado-value" id="resumenContactoEdicionMiembro">-</div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-12">
                        <label class="form-label"><b>TIPO DE OPERADOR</b></label>
                        <select class="form-select" name="tipo" id="tipo_edicion_miembro" required>
                            <option value="">Seleccionar</option>
                            <option value="1">Operador / Centro de Control de Falla</option>
                            <option value="2">Operador / Centro de Control de Operaciones</option>
                        </select>
                    </div>

                    <div class="col-md-12 pt-2">
                        <div class="btn-group w-100">
                            <button class="btn bg-success text-white" type="submit" id="btnGuardarEdicionMiembro">Guardar</button>
                            <button class="btn bg-danger text-white" type="button" data-bs-dismiss="modal">Cancelar</button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

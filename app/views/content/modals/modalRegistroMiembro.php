<?php
$insMiembroModal = isset($insMiembro) ? $insMiembro : new \app\controllers\miembroController();
$codigoSugerido = $insMiembroModal->siguienteCodigoMiembroControlador();
?>
<div class="modal fade miembro-modal-shell" id="ventanaModalRegistrarMiem" tabindex="-1" aria-labelledby="ventanaModalRegistrarMiemLabel" aria-hidden="true">
    <div class="modal-dialog modal-fullscreen-md-down modal-dialog-centered modal-dialog-scrollable miembro-modal-dialog">
        <div class="modal-content miembro-modal-content">
            <div class="modal-header">
                <i class="bx bx-plus-circle fs-1 me-2 text-success" aria-hidden="true"></i>
                <h5 class="modal-title" id="ventanaModalRegistrarMiemLabel">Registrar miembro desde empleados</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close">X</button>
            </div>
            <div class="modal-body">
                <form class="row g-3 FormularioAjax" action="<?php echo APP_URL ?>app/ajax/miembroAjax.php" method="POST" id="formRegistroMiembro">
                    <input type="hidden" name="modulo_miembro" value="registrar">

                    <div class="col-12 col-xl-3">
                        <label class="form-label"><b>CODIGO ASIGNADO</b></label>
                        <input class="form-control" id="codigo_generado_registro" type="text" value="<?php echo htmlspecialchars($codigoSugerido, ENT_QUOTES, 'UTF-8'); ?>" data-next-code="<?php echo htmlspecialchars($codigoSugerido, ENT_QUOTES, 'UTF-8'); ?>" readonly>
                        <small class="text-muted">Se genera automaticamente al guardar.</small>
                    </div>

                    <div class="col-12 col-xl-9">
                        <label class="form-label"><b>EMPLEADO</b></label>
                        <?php echo $insMiembroModal->listarComboEmpleadoMiembroControlador('id_empleado', 'id_empleado_registro'); ?>
                        <small class="text-muted">Solo se pueden registrar empleados activos.</small>
                    </div>

                    <div class="col-md-12">
                        <div class="alert d-none mb-0" id="estadoEmpleadoRegistroMiembro" role="alert"></div>
                    </div>

                    <div class="col-md-12">
                        <div class="miembro-empleado-panel">
                            <div class="row g-3">
                                <div class="col-12 col-lg-4">
                                    <label class="form-label mb-1">Empleado seleccionado</label>
                                    <div class="miembro-empleado-value" id="resumenNombreRegistroMiembro">Sin seleccionar</div>
                                </div>
                                <div class="col-12 col-md-4 col-lg-3">
                                    <label class="form-label mb-1">Documento</label>
                                    <div class="miembro-empleado-value" id="resumenDocumentoRegistroMiembro">-</div>
                                </div>
                                <div class="col-12 col-md-8 col-lg-5">
                                    <label class="form-label mb-1">Contacto</label>
                                    <div class="miembro-empleado-value" id="resumenContactoRegistroMiembro">-</div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-12">
                        <label class="form-label"><b>TIPO DE OPERADOR</b></label>
                        <select class="form-select" name="tipo" id="tipo_registro_miembro" required>
                            <option value="">Seleccionar</option>
                            <option value="1">Operador / Centro de Control de Falla</option>
                            <option value="2">Operador / Centro de Control de Operaciones</option>
                        </select>
                    </div>

                    <div class="col-md-12 pt-2">
                        <div class="btn-group w-100">
                            <button class="btn bg-success text-white" type="submit" id="btnGuardarRegistroMiembro">Guardar</button>
                            <button class="btn bg-danger text-white" type="button" data-bs-dismiss="modal">Cancelar</button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

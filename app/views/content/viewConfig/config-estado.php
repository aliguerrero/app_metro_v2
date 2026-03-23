<!-- Encabezado -->
<div class="d-flex align-items-center gap-2 mb-2">
    <div class="avatar avatar-md bg-light d-flex align-items-center justify-content-center">
        <i class="bi bi-list-task fs-4"></i>
    </div>
    <div>
        <h4 class="mb-0">Estados de O.T.</h4>
        <small class="text-muted">Crea, edita o elimina estados, define su color y controla por separado si liberan herramientas o si bloquean la O.T.</small>
    </div>
</div>

<hr>

<div class="card mb-4">
    <div class="card-header">
        <strong>Estados de Ordenes de Trabajo</strong>
    </div>

    <div class="card-body">
        <form id="formEstadoCreate" autocomplete="off">
            <div class="row g-3 estado-row">
                <div class="col-12 col-lg-6">
                    <label class="form-label"><b>Nombre del estado</b></label>
                    <div class="input-group estado-join-group">
                        <input class="form-control estado-h estado-join-input" name="nombre_estado" id="nombre_estado" type="text"
                            placeholder="Ej: En progreso">
                        <span class="input-group-text estado-join-color">
                            <span class="me-2 fw-semibold">Color</span>
                            <input type="color"
                                class="form-control-color estado-color"
                                id="color" name="color" value="#00FFCC"
                                title="Seleccionar color">
                        </span>
                    </div>
                    <div class="form-text">El color se usa como indicador visual en la tabla y lista de O.T.</div>
                </div>

                <div class="col-12 col-lg-2">
                    <label class="form-label"><b>Libera herramientas</b></label>
                    <div class="form-check form-switch pt-2">
                        <input class="form-check-input" type="checkbox" id="libera_herramientas" name="libera_herramientas" value="1">
                        <label class="form-check-label" for="libera_herramientas">Si</label>
                    </div>
                    <div class="form-text">Si se activa, al aplicar el estado en la O.T. se liberaran sus herramientas.</div>
                </div>

                <div class="col-12 col-lg-2">
                    <label class="form-label"><b>Bloquea O.T.</b></label>
                    <div class="form-check form-switch pt-2">
                        <input class="form-check-input" type="checkbox" id="bloquea_ot" name="bloquea_ot" value="1">
                        <label class="form-check-label" for="bloquea_ot">Si</label>
                    </div>
                    <div class="form-text">Solo debe activarse para el estado final que cierre definitivamente la orden.</div>
                </div>

                <div class="col-12 col-lg-2">
                    <div class="estado-action-wrap">
                        <button class="btn btn-success w-100 estado-h" type="submit" title="Guardar" id="btnEstadoCrear">
                            <i class="bi bi-save"></i>
                            <span class="d-none d-md-inline ms-1">Guardar</span>
                        </button>
                    </div>
                </div>
            </div>
        </form>
    </div>
</div>

<div class="card mb-4">
    <div class="card-header d-flex align-items-center justify-content-between">
        <strong>Lista de Estados</strong>

        <button type="button" class="btn btn-sm btn-primary" id="btnRecargarEstados" title="Recargar">
            <i class="bi bi-arrow-clockwise"></i>
        </button>
    </div>

    <div class="card-body p-0" id="estadoListContainer">
        <?php

        use app\controllers\configController;

        $insConfig = new configController();
        echo $insConfig->listarEstadoControlador("");
        ?>
    </div>
</div>

<div class="modal fade" id="ventanaModalModificarEstado" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content">

            <div class="modal-header">
                <i class="bx bx-edit-alt fs-2 text-primary" aria-hidden="true"></i>
                <div class="ms-2">
                    <h5 class="modal-title mb-0" id="tituloModalModificarEstado">Modificar Estado</h5>
                    <small class="text-muted">Actualiza nombre, color y comportamiento del estado.</small>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close">X</button>
            </div>

            <div class="modal-body">
                <form id="formEstadoUpdate" autocomplete="off">
                    <input type="hidden" name="id_ai_estado" id="edit_id_estado">

                    <div class="row g-3">
                        <div class="col-12 col-lg-6">
                            <label class="form-label"><b>Nombre</b></label>
                            <input type="text" class="form-control" name="nombre_estado" id="edit_nombre_estado" placeholder="Nombre del estado">
                        </div>

                        <div class="col-12 col-lg-3">
                            <label class="form-label"><b>Color</b></label>
                            <div class="estado-color-wrap">
                                <input type="color" class="form-control-color estado-color" name="color" id="edit_color" value="#00FFCC">
                            </div>
                        </div>

                        <div class="col-12 col-lg-3">
                            <label class="form-label"><b>Libera herramientas</b></label>
                            <div class="form-check form-switch pt-2">
                                <input class="form-check-input" type="checkbox" name="libera_herramientas" id="edit_libera_herramientas" value="1">
                                <label class="form-check-label" for="edit_libera_herramientas">Si</label>
                            </div>
                        </div>

                        <div class="col-12 col-lg-3">
                            <label class="form-label"><b>Bloquea O.T.</b></label>
                            <div class="form-check form-switch pt-2">
                                <input class="form-check-input" type="checkbox" name="bloquea_ot" id="edit_bloquea_ot" value="1">
                                <label class="form-check-label" for="edit_bloquea_ot">Si</label>
                            </div>
                        </div>
                    </div>

                    <hr>

                    <div class="btn-group w-100">
                        <button type="submit" class="btn bg-success text-white">
                            <i class="bi bi-check2-circle me-1"></i> Guardar cambios
                        </button>
                        <button type="button" class="btn bg-danger text-white" data-bs-dismiss="modal">
                            <i class="bi bi-x-circle me-1"></i> Cancelar
                        </button>
                    </div>
                </form>
            </div>

        </div>
    </div>
</div>

<script src="<?php echo APP_URL; ?>app/views/js/estado_crud.js?v=3"></script>

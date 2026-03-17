<!-- Encabezado -->
<div class="d-flex align-items-center gap-2 mb-2">
    <div class="avatar avatar-md bg-light d-flex align-items-center justify-content-center">
        <i class="bi bi-list-task fs-4"></i>
    </div>
    <div>
        <h4 class="mb-0">Estados de O.T.</h4>
        <small class="text-muted">Crea, edita o elimina estados e identifica con color.</small>
    </div>
</div>

<hr>

<!-- CARD: Crear -->
<div class="card mb-4">
    <div class="card-header">
        <strong>Estados de Órdenes de trabajo</strong>
    </div>

    <div class="card-body">
        <!-- 👇 IMPORTANTE: quitamos FormularioAjax para controlar todo con JS -->
        <form id="formEstadoCreate" autocomplete="off">
            <div class="row g-3 estado-row">
                <!-- Nombre -->
                <div class="col-12 col-lg-7">
                    <label class="form-label"><b>Nombre del estado</b></label>
                    <input class="form-control estado-h" name="nombre_estado" id="nombre_estado" type="text"
                        placeholder="Ej: En progreso">
                    <div class="form-text">El color se usa como indicador visual en la tabla/lista.</div>
                </div>

                <!-- Color -->
                <div class="col-6 col-lg-2">
                    <label class="form-label"><b>Color</b></label>
                    <div class="estado-color-wrap estado-h">
                        <input type="color"
                            class="form-control-color estado-color"
                            id="color" name="color" value="#00FFCC"
                            title="Seleccionar color">
                    </div>
                </div>

                <!-- Botón -->
                <div class="col-6 col-lg-3">
                    <label class="form-label d-block invisible">Acción</label>
                    <button class="btn btn-success w-100 estado-h" type="submit" title="Guardar" id="btnEstadoCrear">
                        <i class="bi bi-save"></i>
                        <span class="d-none d-md-inline ms-1">Guardar</span>
                    </button>
                </div>
            </div>
        </form>
    </div>
</div>

<!-- CARD: Lista -->
<div class="card mb-4">
    <div class="card-header d-flex align-items-center justify-content-between">
        <strong>Lista de Estados</strong>

        <button type="button" class="btn btn-sm btn-primary" id="btnRecargarEstados" title="Recargar">
            <i class="bi bi-arrow-clockwise"></i>
        </button>
    </div>

    <!-- ✅ Este contenedor se reemplaza por JS sin refrescar la página -->
    <div class="card-body p-0" id="estadoListContainer">
        <?php

        use app\controllers\configController;

        $insConfig = new configController();
        echo $insConfig->listarEstadoControlador("");
        ?>
    </div>
</div>

<!-- MODAL: Editar Estado -->
<div class="modal fade" id="ventanaModalModificarEstado" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content">

            <div class="modal-header">
                <i class="bx bx-edit-alt fs-2 text-primary" aria-hidden="true"></i>
                <div class="ms-2">
                    <h5 class="modal-title mb-0" id="tituloModalModificarEstado">Modificar Estado</h5>
                    <small class="text-muted">Actualiza nombre y color del estado.</small>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close">X</button>
            </div>

            <div class="modal-body">
                <form id="formEstadoUpdate" autocomplete="off">
                    <input type="hidden" name="id_ai_estado" id="edit_id_estado">

                    <div class="row g-3">
                        <div class="col-12 col-lg-8">
                            <label class="form-label"><b>Nombre</b></label>
                            <input type="text" class="form-control" name="nombre_estado" id="edit_nombre_estado" placeholder="Nombre del estado">
                        </div>

                        <div class="col-12 col-lg-4">
                            <label class="form-label"><b>Color</b></label>
                            <div class="estado-color-wrap">
                                <input type="color" class="form-control-color estado-color" name="color" id="edit_color" value="#00FFCC">
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

<!-- ✅ JS de estados -->
<script src="<?php echo APP_URL; ?>app/views/js/estado_crud.js"></script>

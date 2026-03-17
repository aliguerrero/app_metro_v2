<!-- Encabezado -->
<div class="d-flex align-items-center gap-2 mb-2">
    <div class="avatar avatar-md bg-light d-flex align-items-center justify-content-center">
        <i class="bi bi-geo-fill fs-4"></i>
    </div>
    <div>
        <h4 class="mb-0">Áreas de trabajo</h4>
        <small class="text-muted">Crea, edita o elimina áreas y su nomenclatura.</small>
    </div>
</div>

<hr>

<div class="card mb-4">
    <div class="card-header">
        <strong>Registrar Área</strong>
    </div>

    <div class="card-body">
        <!-- IMPORTANTE: id form -->
        <form id="formAreaCreate" class="FormularioAjax" action="<?php echo APP_URL; ?>app/ajax/configAjax.php" method="POST">
            <input type="hidden" name="modulo_rol" value="registrar_area" id="accion">

            <div class="row g-3 align-items-end area-row">
                <div class="col-12 col-lg-7">
                    <label class="form-label"><b>Nombre del área</b></label>
                    <input class="form-control area-h" name="nombre_area" id="nombre_area" type="text"
                        placeholder="Ej: Mantenimiento / Operaciones / Taller">
                </div>

                <div class="col-12 col-sm-6 col-lg-2">
                    <label class="form-label"><b>Nomenclatura</b></label>
                    <input class="form-control area-h" name="nome" id="nome" type="text"
                        placeholder="Ej: MTTO" maxlength="10">
                </div>

                <div class="col-12 col-sm-6 col-lg-3">
                    <label class="form-label d-none d-lg-block invisible">Acción</label>
                    <button class="btn btn-success w-100 area-h" type="submit" title="Guardar">
                        <i class="bi bi-save"></i>
                        <span class="d-none d-md-inline ms-1">Guardar</span>
                    </button>
                </div>
            </div>

            <div class="form-text mt-2">
                La nomenclatura se usa como identificador corto en listados y reportes.
            </div>
        </form>
    </div>
</div>

<div class="card mb-4">
    <div class="card-header d-flex align-items-center justify-content-between">
        <strong>Lista de Áreas</strong>

        <!-- opcional -->
        <button type="button" class="btn btn-sm btn-primary" id="btnRecargarAreas" title="Recargar">
            <i class="bi bi-arrow-clockwise"></i>
        </button>
    </div>

    <!-- IMPORTANTE: contenedor AJAX -->
    <div id="areaListContainer">
        <?php echo $insConfig->listarAreaControlador(""); ?>
    </div>
</div>

<div class="modal fade" id="ventanaModalModificarArea" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">

            <div class="modal-header">
                <i class="bx bx-edit-alt fs-1 me-2 text-primary" aria-hidden="true"></i>
                <h5 class="modal-title">Modificar Área</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close">X</button>
            </div>

            <div class="modal-body">
                <form id="formAreaUpdate" class="FormularioAjax" action="#" method="POST">
                    <input type="hidden" id="edit_id_area" name="id_ai_area" value="">

                    <div class="row g-3">
                        <div class="col-12 col-lg-8">
                            <label class="form-label"><b>Nombre del área</b></label>
                            <input class="form-control" id="edit_nombre_area" name="nombre_area" type="text"
                                placeholder="Nombre del área">
                        </div>

                        <div class="col-12 col-lg-4">
                            <label class="form-label"><b>Nomenclatura</b></label>
                            <input class="form-control" id="edit_nome" name="nome" type="text"
                                placeholder="Ej: MTTO" maxlength="10">
                        </div>
                    </div>

                    <hr>

                    <div class="btn-group w-100">
                        <button class="btn bg-success text-white" type="submit">Guardar</button>
                        <button class="btn bg-danger text-white" type="button" data-bs-dismiss="modal">Cancelar</button>
                    </div>
                </form>
            </div>

        </div>
    </div>
</div>


<!-- Script CRUD -->
<script src="<?php echo APP_URL; ?>app/views/js/area_crud.js"></script>

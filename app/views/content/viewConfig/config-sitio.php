<!-- Encabezado -->
<div class="d-flex align-items-center gap-2 mb-2">
    <div class="avatar avatar-md bg-light d-flex align-items-center justify-content-center">
        <i class="bi bi-geo-alt-fill fs-4"></i>
    </div>
    <div>
        <h4 class="mb-0">Sitios de trabajo</h4>
        <small class="text-muted">Crea, edita o elimina sitios donde se ejecutan las O.T.</small>
    </div>
</div>

<hr>

<!-- Crear -->
<div class="card mb-4">
    <div class="card-header">
        <strong>Sitios de trabajo</strong>
    </div>

    <div class="card-body">
        <!-- Recomendado: sin FormularioAjax para evitar doble handler global -->
        <form id="formSitioCrear" action="#" method="POST" autocomplete="off">
            <div class="row g-3 sitio-row align-items-end">
                <div class="col-12 col-lg-9">
                    <label class="form-label mb-1">
                        <b>Nombre del sitio</b>
                        <small class="text-muted d-block d-lg-inline ms-lg-2">
                            Se mostrará en formularios y reportes de O.T.
                        </small>
                    </label>

                    <input class="form-control sitio-h" name="sitio" id="sitio" type="text"
                        placeholder="Ej: Planta Norte / Subestación X / Taller Central">
                </div>

                <div class="col-12 col-lg-3 d-flex">
                    <button class="btn btn-success w-100 sitio-h" type="submit" title="Guardar">
                        <i class="bi bi-save"></i>
                        <span class="d-none d-md-inline ms-1">Guardar</span>
                    </button>
                </div>
            </div>
        </form>
    </div>
</div>

<!-- Lista -->
<div class="card mb-4">
    <div class="card-header d-flex align-items-center justify-content-between">
        <strong>Lista de Sitios</strong>

        <button type="button" class="btn btn-sm btn-primary" id="btnRecargarSitio" title="Recargar">
            <i class="bi bi-arrow-clockwise"></i>
        </button>
    </div>

    <div class="card-body p-0">
        <div id="sitioListWrap">
            <?php echo $insConfig->listarSitioControlador(""); ?>
        </div>
    </div>
</div>

<!-- Modal Editar -->
<div class="modal fade" id="ventanaModalModificarSitio" tabindex="-1" aria-labelledby="ventanaModalModificarSitioLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">

            <div class="modal-header">
                <div class="d-flex align-items-center gap-2">
                    <i class="bx bx-edit-alt fs-2 text-primary" aria-hidden="true"></i>
                    <div>
                        <h5 class="modal-title mb-0" id="ventanaModalModificarSitioLabel">Modificar Sitio</h5>
                        <small class="text-muted">Actualiza el nombre del sitio seleccionado.</small>
                    </div>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close">X</button>
            </div>

            <div class="modal-body">
                <!-- Recomendado: sin FormularioAjax para evitar doble handler global -->
                <form id="formSitioEditar" action="#" method="POST" autocomplete="off">
                    <input type="hidden" id="edit_id_sitio" name="id_ai_sitio" value="">

                    <div class="card mb-3">
                        <div class="card-header">
                            <strong>Datos del sitio</strong>
                        </div>
                        <div class="card-body">
                            <div class="row g-3">
                                <div class="col-12">
                                    <label class="form-label"><b>Nombre del sitio</b></label>
                                    <input class="form-control" id="edit_nombre_sitio" name="nombre_sitio" type="text"
                                        placeholder="Ej: Planta Norte / Subestación X / Taller Central">
                                    <div class="form-text">Este nombre se usa en formularios y reportes.</div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="btn-group w-100">
                        <button type="submit" class="btn bg-success text-white">Guardar</button>
                        <button type="button" class="btn bg-danger text-white" data-bs-dismiss="modal">Cancelar</button>
                    </div>
                </form>
            </div>

        </div>
    </div>
</div>

<script src="<?php echo APP_URL; ?>app/views/js/sitio_crud.js"></script>

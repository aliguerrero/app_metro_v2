<?php

use app\controllers\herramientaController;

$insHerramienta = new herramientaController();
?>

<div class="d-flex align-items-center gap-2 mb-2">
    <div class="avatar avatar-md bg-light d-flex align-items-center justify-content-center">
        <i class="bi bi-tools fs-4"></i>
    </div>
    <div>
        <h4 class="mb-0">Categorias de herramienta</h4>
        <small class="text-muted">Define las categorias usadas para clasificar el inventario de herramientas.</small>
    </div>
</div>

<hr>

<div class="card mb-4">
    <div class="card-header">
        <strong>Registrar Categoria</strong>
    </div>

    <div class="card-body">
        <form id="formCategoriaHerramientaCreate" class="FormularioAjax" action="#" method="POST">
            <div class="row g-3">
                <div class="col-12 col-lg-4">
                    <label class="form-label"><b>Nombre</b></label>
                    <input class="form-control" name="nombre_categoria" id="nombre_categoria_herramienta" type="text"
                        placeholder="Ej: ELECTRICA / MANUAL">
                </div>

                <div class="col-12 col-lg-5">
                    <label class="form-label"><b>Descripcion</b></label>
                    <input class="form-control" name="descripcion" id="descripcion_categoria_herramienta" type="text"
                        placeholder="Descripcion corta de la categoria">
                </div>

                <div class="col-12 col-lg-3">
                    <label class="form-label invisible d-none d-lg-block"><b>Guardar</b></label>
                    <button class="btn btn-success w-100" type="submit">
                        <i class="bi bi-save"></i>
                        <span class="d-none d-md-inline ms-1">Guardar</span>
                    </button>
                </div>
            </div>
        </form>
    </div>
</div>

<div class="card mb-4">
    <div class="card-header d-flex align-items-center justify-content-between">
        <strong>Lista de Categorias</strong>
        <button type="button" class="btn btn-sm btn-primary" id="btnRecargarCategoriaHerramienta" title="Recargar">
            <i class="bi bi-arrow-clockwise"></i>
        </button>
    </div>

    <div id="categoriaHerramientaListContainer">
        <?php echo $insHerramienta->listarCategoriaHerramientaControlador(); ?>
    </div>
</div>

<div class="modal fade" id="ventanaModalModificarCategoriaHerramienta" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <i class="bx bx-edit-alt fs-1 me-2 text-primary" aria-hidden="true"></i>
                <h5 class="modal-title">Modificar Categoria</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close">X</button>
            </div>

            <div class="modal-body">
                <form id="formCategoriaHerramientaUpdate" class="FormularioAjax" action="#" method="POST">
                    <input type="hidden" id="edit_id_ai_categoria_herramienta" name="id_ai_categoria_herramienta" value="">

                    <div class="row g-3">
                        <div class="col-12 col-lg-4 d-flex flex-column">
                            <label class="form-label"><b>Nombre</b></label>
                            <input class="form-control" id="edit_nombre_categoria_herramienta" name="nombre_categoria" type="text"
                                placeholder="Nombre de la categoria">
                        </div>

                        <div class="col-12 col-lg-8 d-flex flex-column">
                            <label class="form-label"><b>Descripcion</b></label>
                            <input class="form-control" id="edit_descripcion_categoria_herramienta" name="descripcion" type="text"
                                placeholder="Descripcion corta de la categoria">
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

<script src="<?php echo APP_URL; ?>app/views/js/categoria_herramienta_crud.js"></script>

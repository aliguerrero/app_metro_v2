<?php

use app\controllers\empleadoController;

$insEmpleado = new empleadoController();
?>

<div class="d-flex align-items-center gap-2 mb-2">
    <div class="avatar avatar-md bg-light d-flex align-items-center justify-content-center">
        <i class="bi bi-person-vcard-fill fs-4"></i>
    </div>
    <div>
        <h4 class="mb-0">Empleados</h4>
        <small class="text-muted">Administra la ficha del personal asociado a usuarios del sistema.</small>
    </div>
</div>

<hr>

<div class="card mb-4">
    <div class="card-body d-flex flex-column flex-lg-row align-items-lg-center justify-content-between gap-3">
        <div>
            <h5 class="mb-1">Registro de empleados</h5>
        </div>

        <button type="button" class="btn btn-success flex-shrink-0" data-bs-toggle="modal"
            data-bs-target="#ventanaModalRegistrarEmpleado">
            <i class="bi bi-plus-circle me-1"></i> Nuevo empleado
        </button>
    </div>
</div>

<div class="card mb-4">
    <div class="card-header d-flex align-items-center justify-content-between">
        <strong>Lista de Empleados</strong>
        <button type="button" class="btn btn-sm btn-primary" id="btnRecargarEmpleado" title="Recargar">
            <i class="bi bi-arrow-clockwise"></i>
        </button>
    </div>

    <div id="empleadoListContainer">
        <?php echo $insEmpleado->listarEmpleadoControlador(); ?>
    </div>
</div>

<div class="modal fade" id="ventanaModalRegistrarEmpleado" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content">
            <div class="modal-header">
                <i class="bx bx-plus-circle fs-1 me-2 text-success" aria-hidden="true"></i>
                <h5 class="modal-title">Registrar Empleado</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close">X</button>
            </div>

            <div class="modal-body">
                <form id="formEmpleadoCreate" class="FormularioAjax" action="#" method="POST">
                    <div class="row g-3">
                        <div class="col-12 col-md-4">
                            <label class="form-label"><b>Nacionalidad</b></label>
                            <select class="form-select" name="nacionalidad" id="nacionalidad_create">
                                <option value="V" selected>Venezolano (V)</option>
                                <option value="E">Extranjero (E)</option>
                            </select>
                        </div>

                        <div class="col-12 col-md-8">
                            <label class="form-label"><b>Cedula</b></label>
                            <input class="form-control" name="id_empleado" id="id_empleado_create" type="text"
                                placeholder="Numero de cedula">
                        </div>

                        <div class="col-12">
                            <label class="form-label"><b>Nombre completo</b></label>
                            <input class="form-control" name="nombre_empleado" id="nombre_empleado_create" type="text"
                                placeholder="Nombre del empleado">
                        </div>

                        <div class="col-12 col-md-6">
                            <label class="form-label"><b>Telefono</b></label>
                            <input class="form-control" name="telefono" id="telefono_create" type="text"
                                placeholder="Ej: 0412-0000000" inputmode="tel" minlength="10" maxlength="20"
                                pattern="[0-9()+ -]{10,20}">
                            <small class="text-muted">Usa entre 10 y 15 digitos. Puedes incluir `+`, parentesis, espacios o guiones.</small>
                        </div>

                        <div class="col-12 col-md-6">
                            <label class="form-label"><b>Correo</b></label>
                            <input class="form-control" name="correo" id="correo_create" type="email"
                                placeholder="correo@dominio.com" autocomplete="email" required>
                            <small class="text-muted">El correo es obligatorio.</small>
                        </div>

                        <div class="col-12">
                            <label class="form-label"><b>Direccion</b></label>
                            <textarea class="form-control" name="direccion" id="direccion_create" rows="3"
                                placeholder="Direccion del empleado"></textarea>
                        </div>

                        <div class="col-12">
                            <label class="form-label"><b>Categoria</b></label>
                            <?php echo $insEmpleado->listarComboCategoriasEmpleadoControlador('id_ai_categoria_empleado', 'id_ai_categoria_empleado_create'); ?>
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

<div class="modal fade" id="ventanaModalModificarEmpleado" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content">
            <div class="modal-header">
                <i class="bx bx-edit-alt fs-1 me-2 text-primary" aria-hidden="true"></i>
                <h5 class="modal-title">Modificar Empleado</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close">X</button>
            </div>

            <div class="modal-body">
                <form id="formEmpleadoUpdate" class="FormularioAjax" action="#" method="POST">
                    <input type="hidden" id="edit_id_ai_empleado" name="id_ai_empleado" value="">

                    <div class="row g-3">
                        <div class="col-12 col-md-4">
                            <label class="form-label"><b>Nacionalidad</b></label>
                            <select class="form-select" name="nacionalidad" id="edit_nacionalidad">
                                <option value="V">Venezolano (V)</option>
                                <option value="E">Extranjero (E)</option>
                            </select>
                        </div>

                        <div class="col-12 col-md-8">
                            <label class="form-label"><b>Cedula</b></label>
                            <input class="form-control" id="edit_id_empleado" name="id_empleado" type="text"
                                placeholder="Numero de cedula">
                        </div>

                        <div class="col-12">
                            <label class="form-label"><b>Nombre completo</b></label>
                            <input class="form-control" id="edit_nombre_empleado" name="nombre_empleado" type="text"
                                placeholder="Nombre del empleado">
                        </div>

                        <div class="col-12 col-md-6">
                            <label class="form-label"><b>Telefono</b></label>
                            <input class="form-control" id="edit_telefono" name="telefono" type="text"
                                placeholder="Ej: 0412-0000000" inputmode="tel" minlength="10" maxlength="20"
                                pattern="[0-9()+ -]{10,20}">
                            <small class="text-muted">Usa entre 10 y 15 digitos. Puedes incluir `+`, parentesis, espacios o guiones.</small>
                        </div>

                        <div class="col-12 col-md-6">
                            <label class="form-label"><b>Correo</b></label>
                            <input class="form-control" id="edit_correo" name="correo" type="email"
                                placeholder="correo@dominio.com" autocomplete="email" required>
                            <small class="text-muted">El correo es obligatorio.</small>
                        </div>

                        <div class="col-12">
                            <label class="form-label"><b>Direccion</b></label>
                            <textarea class="form-control" id="edit_direccion" name="direccion" rows="3"
                                placeholder="Direccion del empleado"></textarea>
                        </div>

                        <div class="col-12">
                            <label class="form-label"><b>Categoria</b></label>
                            <?php echo $insEmpleado->listarComboCategoriasEmpleadoControlador('id_ai_categoria_empleado', 'edit_id_ai_categoria_empleado'); ?>
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

<script src="<?php echo APP_URL; ?>app/views/js/empleado_crud.js"></script>

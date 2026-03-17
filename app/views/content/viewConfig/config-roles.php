<div class="row g-3 align-items-center p-2">
    <!-- Título -->
    <div class="col-12 col-lg-8">
        <div class="d-flex align-items-center gap-2 h-100">
            <div class="avatar avatar-md bg-light d-flex align-items-center justify-content-center flex-shrink-0">
                <i class="bi bi-people-fill fs-4"></i>
            </div>

            <div class="lh-sm">
                <h4 class="mb-0">Roles y permisos</h4>
                <small class="text-muted">Administra los roles del sistema y asigna accesos.</small>
            </div>
        </div>
    </div>

    <!-- Selector acción -->
    <div class="col-12 col-lg-4">
        <div class="d-flex flex-column justify-content-center h-100">
            <label for="selectAccion" class="form-label mb-1"><b>Acción</b></label>
            <select class="form-select" id="selectAccion">
                <option value="1">Roles</option>
                <option value="2">Crear nuevo rol</option>
            </select>
        </div>
    </div>
</div>

<hr>

<!-- Nota: dejamos un solo form principal, pero el JS intercepta todo -->
<form id="formRolesPermisos" action="#" method="POST" autocomplete="off">
    <!-- BLOQUE ROLES -->
    <div class="card mb-3">
        <div class="card-header d-flex align-items-center">
            <strong>Gestión de roles</strong>
            <div class="ms-auto small text-muted" id="rolesMsgTop"></div>
        </div>

        <div class="card-body">
            <!-- LISTAR -->
            <div id="listar">
                <label class="form-label"><b>Roles</b></label>

                <div class="input-group flex-nowrap w-100 roles-join">
                    <div id="rolesSelectWrap" class="flex-grow-1 roles-join-select">
                        <?php

                        use app\controllers\configController;

                        $insConfig = new configController();
                        echo $insConfig->listarComboRolControlador();
                        ?>
                    </div>

                    <button class="btn bg-danger text-white roles-join-btn" type="button" id="btnEliminarRol" title="Eliminar">
                        <i class="bi bi-trash"></i>
                        <span class="d-none d-md-inline ms-1">Eliminar</span>
                    </button>
                </div>


                <div class="form-text mt-2">
                    Selecciona un rol para cargar sus permisos. Puedes eliminar el rol seleccionado.
                </div>
            </div>

            <!-- NUEVO -->
            <div id="nuevo" style="display:none;" class="mt-3">
                <label class="form-label"><b>Nuevo Rol</b></label>
                <div class="input-group flex-nowrap w-100">
                    <input class="form-control" id="rol_name" type="text" placeholder="Nombre del rol">

                    <button class="btn btn-success flex-shrink-0" type="button" id="btnCrearRol" title="Guardar">
                        <i class="bi bi-save"></i>
                        <span class="d-none d-md-inline ms-1">Guardar</span>
                    </button>
                </div>
                <div class="form-text">Escribe el nombre y guarda para crear el rol.</div>
            </div>
        </div>
    </div>

    <!-- PERMISOS -->
    <div class="card mb-3">
        <div class="card-header d-flex align-items-center">
            <strong>Permisos</strong>
            <div class="ms-auto small text-muted" id="permMsgTop"></div>
        </div>

        <div class="card-body">
            <div class="row g-3" id="contenido">

                <!-- Usuarios -->
                <div class="col-12 col-md-6 col-xl-4">
                    <div class="card h-100">
                        <div class="card-header">
                            <strong><i class="bi bi-person-badge me-1"></i> Usuarios</strong>
                        </div>
                        <div class="card-body">
                            <div class="form-check form-switch">
                                <input class="form-check-input" type="checkbox" id="permisoUsuarios0">
                                <label class="form-check-label" for="permisoUsuarios0">Permitir acceso</label>
                            </div>
                            <div class="form-check form-switch">
                                <input class="form-check-input" type="checkbox" id="permisoUsuarios1">
                                <label class="form-check-label" for="permisoUsuarios1">Registrar</label>
                            </div>
                            <div class="form-check form-switch">
                                <input class="form-check-input" type="checkbox" id="permisoUsuarios2">
                                <label class="form-check-label" for="permisoUsuarios2">Modificar</label>
                            </div>
                            <div class="form-check form-switch">
                                <input class="form-check-input" type="checkbox" id="permisoUsuarios3">
                                <label class="form-check-label" for="permisoUsuarios3">Eliminar</label>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Herramienta -->
                <div class="col-12 col-md-6 col-xl-4">
                    <div class="card h-100">
                        <div class="card-header">
                            <strong><i class="bi bi-tools me-1"></i> Herramienta</strong>
                        </div>
                        <div class="card-body">
                            <div class="form-check form-switch">
                                <input class="form-check-input" type="checkbox" id="permisoHerramienta0">
                                <label class="form-check-label" for="permisoHerramienta0">Permitir acceso</label>
                            </div>
                            <div class="form-check form-switch">
                                <input class="form-check-input" type="checkbox" id="permisoHerramienta1">
                                <label class="form-check-label" for="permisoHerramienta1">Registrar</label>
                            </div>
                            <div class="form-check form-switch">
                                <input class="form-check-input" type="checkbox" id="permisoHerramienta2">
                                <label class="form-check-label" for="permisoHerramienta2">Modificar</label>
                            </div>
                            <div class="form-check form-switch">
                                <input class="form-check-input" type="checkbox" id="permisoHerramienta3">
                                <label class="form-check-label" for="permisoHerramienta3">Eliminar</label>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Miembro -->
                <div class="col-12 col-md-6 col-xl-4">
                    <div class="card h-100">
                        <div class="card-header">
                            <strong><i class="bi bi-person-lines-fill me-1"></i> Miembro</strong>
                        </div>
                        <div class="card-body">
                            <div class="form-check form-switch">
                                <input class="form-check-input" type="checkbox" id="permisoMiembro0">
                                <label class="form-check-label" for="permisoMiembro0">Permitir acceso</label>
                            </div>
                            <div class="form-check form-switch">
                                <input class="form-check-input" type="checkbox" id="permisoMiembro1">
                                <label class="form-check-label" for="permisoMiembro1">Registrar</label>
                            </div>
                            <div class="form-check form-switch">
                                <input class="form-check-input" type="checkbox" id="permisoMiembro2">
                                <label class="form-check-label" for="permisoMiembro2">Modificar</label>
                            </div>
                            <div class="form-check form-switch">
                                <input class="form-check-input" type="checkbox" id="permisoMiembro3">
                                <label class="form-check-label" for="permisoMiembro3">Eliminar</label>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Orden de Trabajo -->
                <div class="col-8">
                    <div class="card">
                        <div class="card-header">
                            <strong><i class="bi bi-clipboard-check me-1"></i> Orden de Trabajo</strong>
                        </div>

                        <div class="card-body">
                            <div class="row g-3">
                                <div class="col-12 col-md-4 col-xl-4">
                                    <div class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" id="permisoOrdenTrabajo0">
                                        <label class="form-check-label" for="permisoOrdenTrabajo0">Permitir acceso</label>
                                    </div>
                                    <div class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" id="permisoOrdenTrabajo1">
                                        <label class="form-check-label" for="permisoOrdenTrabajo1">Registrar O.T.</label>
                                    </div>
                                    <div class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" id="permisoOrdenTrabajo2">
                                        <label class="form-check-label" for="permisoOrdenTrabajo2">Modificar O.T.</label>
                                    </div>
                                </div>

                                <div class="col-12 col-md-4 col-xl-4">
                                    <div class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" id="permisoOrdenTrabajo3">
                                        <label class="form-check-label" for="permisoOrdenTrabajo3">Agregar Detalle</label>
                                    </div>
                                    <div class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" id="permisoOrdenTrabajo4">
                                        <label class="form-check-label" for="permisoOrdenTrabajo4">Eliminar O.T.</label>
                                    </div>
                                    <div class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" id="permisoOrdenTrabajo6">
                                        <label class="form-check-label" for="permisoOrdenTrabajo6">Agregar Herramienta</label>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <!-- Reporte -->

                <div class="col-12 col-md-4 col-xl-4">
                    <div class="card h-100">
                        <div class="card-header">
                            <strong><i class="bi bi-clipboard-check me-1"></i> Reportes</strong>
                        </div>
                        <div class="card-body">
                            <div class="form-check form-switch">
                                <input class="form-check-input" type="checkbox" id="permisoOrdenTrabajo5">
                                <label class="form-check-label" for="permisoOrdenTrabajo5">Generar Reportes</label>
                            </div>
                        </div>
                    </div>
                </div>
            </div><!-- /row -->
        </div>
    </div>

    <!-- ACTIONS -->
    <div class="col-12">
        <div class="btn-group w-100" role="group" aria-label="Acciones permisos">
            <button type="button" class="btn bg-success text-white" id="btnGuardarPermisos">
                <i class="bi bi-check2-circle me-1"></i> Guardar cambios
            </button>
            <button type="reset" class="btn bg-danger text-white" id="btnLimpiarPermisos">
                <i class="bi bi-arrow-counterclockwise me-1"></i> Limpiar
            </button>
        </div>
    </div>
</form>

<script src="<?php echo APP_URL; ?>app/views/js/rol_crud.js"></script>
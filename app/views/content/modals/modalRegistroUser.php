<?php

use app\controllers\empleadoController;

$insEmpleado = new empleadoController();
?>

<div class="modal fade" id="ventanaModalRegistrar" tabindex="-1" aria-labelledby="ventanaModalRegistrar" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <i class="bx bx-plus-circle fs-1 me-2 text-success" aria-hidden="true"></i>
                <h5 class="modal-title" id="tituloModal">Registrar Nuevo Usuario</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close">X</button>
            </div>

            <div class="modal-body">
                <form class="row g-3 FormularioAjax" action="<?php echo APP_URL; ?>app/ajax/userAjax.php" method="POST">
                    <input type="hidden" name="modulo_user" value="registrar">

                    <div class="col-12">
                        <label class="form-label"><b>EMPLEADO</b></label>
                        <?php echo $insEmpleado->listarComboEmpleadosDisponiblesControlador('id_empleado', 'id_empleado_create_user'); ?>
                        <small class="text-muted">Primero registra el empleado en Configuracion si todavia no existe. Si ya tiene usuario, se mostrara su <b>@username</b>.</small>
                    </div>

                    <div class="col-12">
                        <label class="form-label"><b>USERNAME</b>
                            <a href="#" title="Instrucciones" onclick="mostrarAlertaUsername()">
                                <i class="bx bx-error-circle fs-5 text-warning align-middle" aria-hidden="true"></i>
                            </a>
                        </label>

                        <div class="input-group">
                            <span class="input-group-text">@</span>
                            <input type="text" class="form-control" name="username" placeholder="Ingresar nombre de usuario" autocomplete="off">
                        </div>
                    </div>

                    <div class="col-12 col-md-6">
                        <label class="form-label"><b>CONTRASENA</b>
                            <a href="#" title="Instrucciones" onclick="mostrarAlertaContrasena()">
                                <i class="bx bx-error-circle fs-5 text-warning align-middle" aria-hidden="true"></i>
                            </a>
                        </label>
                        <input class="form-control" name="clave1" type="password" placeholder="Ingresar contrasena" autocomplete="off">
                    </div>

                    <div class="col-12 col-md-6">
                        <label class="form-label"><b>REPETIR CONTRASENA</b></label>
                        <input class="form-control" name="clave2" type="password" placeholder="Repetir contrasena" autocomplete="off">
                    </div>

                    <div class="col-12">
                        <?php echo $insUsuario->listarComboRolesControlador('tipo1'); ?>
                    </div>

                    <hr>

                    <div class="col-12">
                        <div class="btn-group w-100">
                            <button class="btn bg-success text-white" type="submit">Guardar</button>
                            <button class="btn bg-danger text-white" type="button" data-bs-dismiss="modal">Cancelar</button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

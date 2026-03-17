<?php

use app\controllers\empleadoController;

$insEmpleado = new empleadoController();
?>

<div class="modal fade" id="ventanaModalModificar" tabindex="-1" aria-labelledby="ventanaModalModificar" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <i class="bx bx-edit-alt fs-1 me-2 text-primary" aria-hidden="true"></i>
                <h5 class="modal-title" id="tituloModal">Modificar Usuario</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close">X</button>
            </div>

            <div class="modal-body">
                <form class="row g-3 FormularioAjax" action="<?php echo APP_URL; ?>app/ajax/userAjax.php" method="POST">
                    <input type="hidden" name="modulo_user" value="modificar">
                    <input type="hidden" name="id" id="id">

                    <div class="col-12">
                        <label class="form-label"><b>EMPLEADO</b></label>
                        <?php echo $insEmpleado->listarComboEmpleadosDisponiblesControlador('id_empleado', 'id_empleado'); ?>
                    </div>

                    <div class="col-12">
                        <label class="form-label"><b>USERNAME</b></label>
                        <div class="input-group">
                            <span class="input-group-text">@</span>
                            <input type="text" class="form-control" name="username" id="username" placeholder="Ingresar nombre de usuario">
                        </div>
                    </div>

                    <div class="col-12">
                        <?php echo $insUsuario->listarComboRolesControlador('tipo2'); ?>
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

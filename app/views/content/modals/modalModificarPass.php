<div class="modal fade" id="ventanaModalModificarPass" tabindex="-1" aria-labelledby="ventanaModalModificarPass" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">

            <!-- HEADER -->
            <div class="modal-header">
                <i class="bx bx-lock-alt fs-1 me-2 text-primary" aria-hidden="true"></i>
                <h5 class="modal-title" id="tituloModal">Cambiar Contraseña</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close">X</button>
            </div>

            <!-- BODY -->
            <div class="modal-body">
                <!-- Nombre del usuario (centrado y responsive) -->
                <div class="text-center mb-3">
                    <h6 class="mb-0 text-muted">Empleado / usuario</h6>
                    <h5 class="mb-0" id="nombreUser" name="nombreUser"></h5>
                </div>

                <form class="row g-3 FormularioAjax" action="<?php echo APP_URL; ?>app/ajax/userAjax.php" method="POST">
                    <input type="hidden" name="modulo_user" value="clave">
                    <input type="hidden" name="id2" id="id2">

                    <!-- Password 1 -->
                    <div class="col-12">
                        <label class="form-label"><b>CONTRASEÑA</b></label>
                        <div class="input-group">
                            <input class="form-control" name="clave1" id="clave1" type="password" placeholder="Ingresar contraseña">
                            <button class="btn btn-outline-secondary" type="button" id="togglePassword1" title="Mostrar / ocultar">
                                <i class="bx bx-show fs-4" aria-hidden="true"></i>
                            </button>
                        </div>
                    </div>

                    <!-- Password 2 -->
                    <div class="col-12">
                        <label class="form-label"><b>REPETIR CONTRASEÑA</b></label>
                        <div class="input-group">
                            <input class="form-control" name="clave2" id="clave2" type="password" placeholder="Repetir contraseña">
                            <button class="btn btn-outline-secondary" type="button" id="togglePassword2" title="Mostrar / ocultar">
                                <i class="bx bx-show fs-4" aria-hidden="true"></i>
                            </button>
                        </div>
                    </div>

                    <hr>

                    <!-- ACTIONS -->
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

<div class="modal fade" id="ventanaModalRegistrarMiem" tabindex="-1" aria-labelledby="ventanaModalRegistrarMiem" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <i class="bx bx-plus-circle fs-1 me-2 text-success" aria-hidden="true"></i>
                <h5 class="modal-title" id="tituloModal">Registrar Nuevo Miembro</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close">X</button>
            </div>
            <div class="modal-body">
                <form class="row g-3 FormularioAjax" action="<?php echo APP_URL ?>app/ajax/miembroAjax.php" method="POST">
                    <input type="hidden" name="modulo_miembro" value="registrar">

                    <!-- Código -->
                    <div class="col-md-6">
                        <label class="form-label"><b>CÓDIGO:</b></label>
                        <input class="form-control" name="codigo" id="codigo" type="text" placeholder="Ingrese código" value="M-">
                    </div>

                    <!-- Nombre del Operador -->
                    <div class="col-md-12">
                        <label class="form-label"><b>NOMBRE DEL OPERADOR:</b></label>
                        <input class="form-control" name="nombre" id="nombre" type="text" placeholder="Ingrese Nombre/Apellido">
                    </div>

                    <!-- Tipo de Operador -->
                    <div class="col-md-12">
                        <label class="form-label"><b>TIPO DE OPERADOR:</b></label>
                        <select class="form-select" name="tipo" id="tipo" aria-label="Default select example">
                            <option selected>Seleccionar</option>
                            <option value="1">Op./Centro de Control de Falla</option>
                            <option value="2">Op./Centro de Control de Operaciones</option>
                        </select>
                    </div>

                    <hr>

                    <!-- Botones de acción -->
                    <div class="col-md-12">
                        <div class="btn-group w-100">
                            <!-- Botón Guardar -->
                            <button class="btn bg-success text-white" type="submit">Guardar</button>

                            <!-- Botón Cancelar -->
                            <button class="btn bg-danger text-white" type="button" data-bs-dismiss="modal">Cancelar</button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="ventanaModalRegistrarHerr" tabindex="-1" aria-labelledby="ventanaModalRegistrarHerr" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <i class="bx bx-plus-circle fs-1 me-2 text-success" aria-hidden="true"></i>
                <h5 class="modal-title" id="tituloModal">Registrar Herramienta</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close">X</button>
            </div>

            <div class="modal-body">
                <form class="row g-3 FormularioAjax" action="<?php echo APP_URL; ?>app/ajax/herramientaAjax.php" method="POST">
                    <input type="hidden" name="modulo_herramienta" value="registrar">

                    <div class="col-md-12">
                        <label class="form-label"><b>NOMBRE DE LA HERRAMIENTA:</b></label>
                        <input class="form-control" name="nombre" id="nombre" type="text" maxlength="90" placeholder="Ingrese nombre de la herramienta" title="Puedes usar letras, numeros y acentos">
                    </div>

                    <div class="col-md-12">
                        <label class="form-label"><b>CATEGORIA:</b></label>
                        <?php echo $insHerramienta->listarComboCategoriasHerramientaControlador('id_ai_categoria_herramienta', 'id_ai_categoria_herramienta_create'); ?>
                    </div>

                    <div class="col-md-12">
                        <div class="form-row">
                            <div class="col-md-4">
                                <label class="form-label"><b>CANTIDAD:</b></label>
                                <input class="form-control" name="cant" id="cant" type="number" min="0" placeholder="Ingrese cantidad">
                            </div>

                            <div class="col-md-8">
                                <label class="form-label"><b>ESTADO:</b></label>
                                <select class="form-select" name="estado" id="estado" aria-label="Default select example">
                                    <option selected>Seleccionar</option>
                                    <option value="1">Buen Estado</option>
                                    <option value="2">Regular</option>
                                    <option value="3">Mal Estado</option>
                                </select>
                            </div>
                        </div>
                    </div>
                    <hr>
                    <div class="col-md-12">
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

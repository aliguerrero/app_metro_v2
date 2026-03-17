<div class="modal fade" id="ventanaModalModificarOt" tabindex="-1" aria-labelledby="ventanaModalModificarOt" aria-hidden="true">
    <div class="modal-dialog modal-xl modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content">

            <!-- HEADER -->
            <div class="modal-header">
                <div class="d-flex align-items-center gap-2">
                    <i class="bx bx-edit-alt fs-2 text-primary" aria-hidden="true"></i>
                    <div>
                        <h5 class="modal-title mb-0" id="tituloModal">Modificar Orden de Trabajo</h5>
                        <small class="text-muted">Edita los detalles de la O.T.</small>
                    </div>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close">X</button>
            </div>

            <!-- BODY -->
            <div class="modal-body">
                <form class="FormularioAjax" action="<?php echo APP_URL; ?>app/ajax/otAjax.php" method="POST">
                    <input type="hidden" name="modulo_ot" value="modificar_ot">

                    <!-- CARD: Datos principales -->
                    <div class="card mb-3">
                        <div class="card-header">
                            <strong>Datos principales</strong>
                        </div>
                        <div class="card-body">
                            <div class="row g-3">
                                <div class="col-6">
                                    <label class="form-label"><b>NRO O.T.</b></label>
                                    <h5 id="codigo" name="codigo"></h5>
                                </div>
                                <div class="col-6">
                                    <input type="hidden" name="id" id="id">
                                    <label class="form-label"><b>Fecha O.T.</b></label>
                                    <input type="date" class="form-control" id="fecha1" name="fecha1" onchange="calcularSemanaYMes1()">
                                </div>                               

                                <div class="col-12">
                                    <label class="form-label"><b>Nombre del Trabajo</b></label>
                                    <input class="form-control" id="nombre" name="nombre" type="text" value="" placeholder="Título del trabajo a registrar">
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- CARD: Planificación -->
                    <div class="card mb-3">
                        <div class="card-header">
                            <strong>Planificación</strong>
                        </div>
                        <div class="card-body">
                            <div class="row g-3">
                                <div class="col-12 col-md-6 col-lg-4">
                                    <label class="form-label"><b>Semana</b></label>
                                    <input class="form-control" id="semana1" name="semana1" type="number" min="1" placeholder="Número de semana">
                                </div>

                                <div class="col-12 col-md-6 col-lg-4">
                                    <label class="form-label"><b>Mes</b></label>
                                    <select class="form-select" id="mes1" name="mes1">
                                        <option selected>Seleccionar</option>
                                        <option value="1">Enero</option>
                                        <option value="2">Febrero</option>
                                        <option value="3">Marzo</option>
                                        <option value="4">Abril</option>
                                        <option value="5">Mayo</option>
                                        <option value="6">Junio</option>
                                        <option value="7">Julio</option>
                                        <option value="8">Agosto</option>
                                        <option value="9">Septiembre</option>
                                        <option value="10">Octubre</option>
                                        <option value="11">Noviembre</option>
                                        <option value="12">Diciembre</option>
                                    </select>
                                </div>

                                <div class="col-12 col-md-6 col-lg-4">
                                    <label class="form-label"><b>Sitio de Trabajo</b></label>
                                    <?php echo $insOt->listarComboSitioControlador(); ?>
                                </div>
                            </div>
                        </div>
                    </div>

                    <hr>

                    <!-- ACTIONS -->
                    <div class="col-md-12">
                        <div class="btn-group w-100">
                            <button class="btn bg-success text-white flex-grow-1" type="submit">
                                Guardar
                            </button>
                            <button class="btn bg-danger text-white flex-grow-1" type="button" data-bs-dismiss="modal">
                                Cancelar
                            </button>
                        </div>
                    </div>

                </form>
            </div>

        </div>
    </div>
</div>

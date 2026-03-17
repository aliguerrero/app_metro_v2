<!-- MODAL: Registrar OT -->
<div class="modal fade"
    id="ventanaModalRegistroOt"
    tabindex="-1"
    aria-labelledby="tituloModalRegistroOt"
    aria-hidden="true">

    <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable detalles-ot-dialog">
        <div class="modal-content">

            <!-- HEADER -->
            <div class="modal-header">
                <div class="d-flex align-items-center gap-2">
                    <i class="bx bx-plus-circle fs-2 text-success" aria-hidden="true"></i>
                    <div>
                        <h5 class="modal-title mb-0" id="tituloModalRegistroOt">Registrar Orden de Trabajo</h5>
                        <small class="text-muted">Completa los datos para crear la O.T.</small>
                    </div>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close">X</button>
            </div>

            <!-- BODY -->
            <div class="modal-body">

                <!-- Leyenda -->
                <div class="d-flex justify-content-end mb-2">
                    <small class="text-muted">
                        <span class="text-danger fw-bold">*</span> Campo obligatorio
                    </small>
                </div>

                <form class="FormularioAjax" action="<?php echo APP_URL; ?>app/ajax/otAjax.php" method="POST">
                    <input type="hidden" name="modulo_ot" value="registrar_ot">

                    <!-- CARD: Datos principales -->
                    <div class="card mb-3">
                        <div class="card-header">
                            <strong>Datos principales</strong>
                        </div>
                        <div class="card-body">
                            <div class="row g-3">

                                <!-- Área -->
                                <div class="col-12">
                                    <label class="form-label">
                                        <b>Área <span class="text-danger">*</span></b>
                                    </label>
                                    <?php echo $insOt->listarComboAreaControlador(); ?>
                                </div>

                                <div class="col-6">
                                    <label class="form-label">
                                        <b>NRO O.T. <span class="text-danger">*</span></b>
                                    </label>
                                    <input class="form-control" id="codigo" name="codigo" type="text" placeholder="Número de O.T.">
                                </div>

                                <div class="col-6">
                                    <label class="form-label">
                                        <b>Fecha O.T. <span class="text-danger">*</span></b>
                                    </label>
                                    <input type="date" class="form-control" id="fecha" name="fecha" onchange="calcularSemanaYMes()">
                                </div>

                                <div class="col-12">
                                    <label class="form-label">
                                        <b>Nombre del Trabajo <span class="text-danger">*</span></b>
                                    </label>
                                    <input class="form-control" id="nombre" name="nombre" type="text" placeholder="Título del trabajo a registrar">
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
                                    <label class="form-label">
                                        <b>Semana <span class="text-danger">*</span></b>
                                    </label>
                                    <input class="form-control" id="semana" name="semana" type="number" min="1" placeholder="Número de semana">
                                </div>

                                <div class="col-12 col-md-6 col-lg-4">
                                    <label class="form-label">
                                        <b>Mes <span class="text-danger">*</span></b>
                                    </label>
                                    <select class="form-select" id="mes" name="mes">
                                        <!-- mejor para validación: value vacío + disabled -->
                                        <option value="" selected disabled>Seleccionar</option>
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
                                    <label class="form-label">
                                        <b>Sitio de Trabajo <span class="text-danger">*</span></b>
                                    </label>
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

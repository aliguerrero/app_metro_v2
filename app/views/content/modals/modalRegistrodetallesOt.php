<!-- MODAL: Detalles OT (reorganizado + formulario incluido) -->
<div class="modal fade" id="detallesOt" tabindex="-1" aria-labelledby="detallesOtLabel" aria-hidden="true">
    <div class="modal-dialog modal-xl modal-dialog-centered modal-dialog-scrollable modal-fullscreen-sm-down detalles-ot-dialog">
        <div class="modal-content">

            <!-- HEADER -->
            <div class="modal-header align-items-center">
                <div class="d-flex align-items-center gap-3">
                    <i class="bx bx-clipboard fs-2 text-primary" aria-hidden="true"></i>
                    <div>
                        <h5 class="modal-title mb-0" id="detallesOtLabel">Detalles de Orden de Trabajo</h5>
                        <small class="text-muted">Gestión de avances, estado y tiempos</small>
                    </div>
                </div>

                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar">X</button>
            </div>

            <div class="modal-body">

                <!-- RESUMEN OT (compacto) -->
                <div class="d-flex flex-wrap align-items-center gap-2 p-2 border rounded mb-3">
                    <span class="badge bg-dark px-3 py-2" id="codigoOt">—</span>
                    <span class="fw-semibold text-uppercase" id="nombreOt">—</span>
                    <span class="ms-auto text-muted small" id="metaOt"></span>
                </div>

                <!-- GRID PRINCIPAL -->
                <div class="row g-3">

                    <!-- LISTA -->
                    <div class="col-12 col-lg-5 order-1">
                        <div class="card h-100">
                            <div class="card-header d-flex flex-wrap gap-2 align-items-center">
                                <strong class="me-auto">Lista de Detalles</strong>

                                <div class="input-group input-group-sm" style="max-width: 220px;">
                                    <span class="input-group-text"><i class="bi bi-search"></i></span>
                                    <input type="text" class="form-control" id="buscarDetalle" placeholder="Buscar...">
                                </div>

                                <div class="btn-group btn-group-sm" role="group">
                                    <button type="button" class="btn btn-primary" id="btnRecargarDetalle" title="Recargar">
                                        <i class="bi bi-arrow-clockwise"></i>
                                    </button>

                                    <button type="button" class="btn btn-success" id="btnCrear" title="Nuevo" onclick="limpiarDetalles(); enfocarFormularioDetalle();">
                                        <i class="bi bi-plus"></i> Nuevo
                                    </button>
                                </div>
                            </div>

                            <div class="card-body p-2">
                                <div class="overflow-auto" style="max-height:65vh;">
                                    <?php echo $insOt->listarDetalles(); ?>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- FORMULARIO -->
                    <div class="col-12 col-lg-7 order-2">
                        <div class="card">
                            <div class="card-header d-flex align-items-center">
                                <strong class="me-auto">Registro / Edición</strong>
                                <small class="text-muted" id="modoEdicionLabel">Nuevo</small>
                            </div>

                            <div class="card-body" id="contenedorFormularioDetalle">

                                <!-- Leyenda de obligatorios -->
                                <div class="d-flex justify-content-end mb-2">
                                    <small class="text-muted">
                                        <span class="text-danger fw-bold">*</span> Campo obligatorio
                                    </small>
                                </div>

                                <form id="formDetalleOt" action="<?php echo APP_URL; ?>app/controllers/cargarDatosDetalle.php" method="POST">
                                    <input type="hidden" name="tipo" id="tipo" value="guardar">

                                    <!-- n_ot -->
                                    <input type="hidden" name="codigo" id="id" value="">

                                    <!-- id_ai_detalle: vacío = INSERT / con valor = UPDATE -->
                                    <input type="hidden" name="id" id="id2" value="">

                                    <!-- ACCORDION -->
                                    <div class="accordion" id="accDetalleOt">

                                        <!-- BASICOS -->
                                        <div class="accordion-item">
                                            <h2 class="accordion-header" id="headBasicos">
                                                <button class="accordion-button" type="button" data-bs-toggle="collapse" data-bs-target="#colBasicos" aria-expanded="true" aria-controls="colBasicos">
                                                    Datos básicos
                                                </button>
                                            </h2>
                                            <div id="colBasicos" class="accordion-collapse collapse show" aria-labelledby="headBasicos" data-bs-parent="#accDetalleOt">
                                                <div class="accordion-body">
                                                    <div class="row g-3">
                                                        <div class="col-12 col-md-4">
                                                            <label class="form-label">
                                                                Fecha <span class="text-danger fw-bold">*</span>
                                                            </label>
                                                            <input type="date" class="form-control" id="fecha" name="fecha" >
                                                        </div>

                                                        <div class="col-12 col-md-8">
                                                            <label class="form-label">
                                                                Descripción <span class="text-danger fw-bold">*</span>
                                                            </label>
                                                            <input class="form-control" id="desc" name="desc" type="text" placeholder="Descripción del trabajo realizado" >
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- ASIGNACION -->
                                        <div class="accordion-item">
                                            <h2 class="accordion-header" id="headAsignacion">
                                                <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#colAsignacion" aria-expanded="false" aria-controls="colAsignacion">
                                                    Asignación
                                                </button>
                                            </h2>
                                            <div id="colAsignacion" class="accordion-collapse collapse" aria-labelledby="headAsignacion" data-bs-parent="#accDetalleOt">
                                                <div class="accordion-body">
                                                    <div class="row g-3">
                                                        <div class="col-12 col-md-6">
                                                            <label class="form-label">
                                                                Cant. Operador(es) <span class="text-danger fw-bold">*</span>
                                                            </label>
                                                            <input class="form-control" id="cant" name="cant" type="number" min="0" placeholder="Cantidad de operadores" >
                                                        </div>

                                                        <div class="col-12 col-md-6">
                                                            <!-- Debe renderizar select id="turno" name="turno" -->
                                                            <label class="form-label">
                                                                Turno <span class="text-danger fw-bold">*</span>
                                                            </label>
                                                            <?php echo $insOt->listarComboTurnoControlador(); ?>
                                                        </div>

                                                        <div class="col-12 col-md-6">
                                                            <label class="form-label">
                                                                Estado O.T. <span class="text-danger fw-bold">*</span>
                                                            </label>
                                                            <?php echo $insOt->listarComboEstadoControlador(); ?>
                                                        </div>

                                                        <div class="col-12 col-md-6">
                                                            <!-- Debe renderizar select id="cco" name="cco" -->
                                                            <label class="form-label">
                                                                CCO <span class="text-danger fw-bold">*</span>
                                                            </label>
                                                            <?php echo $insOt->listarComboOtControlador(2); ?>
                                                        </div>

                                                        <div class="col-12 col-md-6">
                                                            <!-- Debe renderizar select id="ccf" name="ccf" -->
                                                            <label class="form-label">
                                                                CCF <span class="text-danger fw-bold">*</span>
                                                            </label>
                                                            <?php echo $insOt->listarComboOtControlador(1); ?>
                                                        </div>

                                                        <div class="col-12 col-md-6">
                                                            <!-- Debe renderizar select id="tec" name="tec" -->
                                                            <label class="form-label">
                                                                Técnico <span class="text-danger fw-bold">*</span>
                                                            </label>
                                                            <?php echo $insOt->listarComboTecControlador(); ?>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- HORAS + OBS -->
                                        <div class="accordion-item">
                                            <h2 class="accordion-header" id="headHoras">
                                                <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#colHoras" aria-expanded="false" aria-controls="colHoras">
                                                    Horas y observación
                                                </button>
                                            </h2>
                                            <div id="colHoras" class="accordion-collapse collapse" aria-labelledby="headHoras" data-bs-parent="#accDetalleOt">
                                                <div class="accordion-body">

                                                    <div class="row g-3">
                                                        <!-- Preparación -->
                                                        <div class="col-12 col-md-4">
                                                            <label class="form-label fw-semibold">
                                                                Preparación <span class="text-danger fw-bold">*</span>
                                                            </label>
                                                            <div class="input-group mb-2">
                                                                <span class="input-group-text">Ini</span>
                                                                <input type="time" class="form-control" id="prep_ini" name="prep_ini" >
                                                            </div>
                                                            <div class="input-group">
                                                                <span class="input-group-text">Fin</span>
                                                                <input type="time" class="form-control" id="prep_fin" name="prep_fin" >
                                                            </div>
                                                        </div>

                                                        <!-- Traslado -->
                                                        <div class="col-12 col-md-4">
                                                            <label class="form-label fw-semibold">
                                                                Traslado <span class="text-danger fw-bold">*</span>
                                                            </label>
                                                            <div class="input-group mb-2">
                                                                <span class="input-group-text">Ini</span>
                                                                <input type="time" class="form-control" id="tras_ini" name="tras_ini" >
                                                            </div>
                                                            <div class="input-group">
                                                                <span class="input-group-text">Fin</span>
                                                                <input type="time" class="form-control" id="tras_fin" name="tras_fin" >
                                                            </div>
                                                        </div>

                                                        <!-- Ejecución -->
                                                        <div class="col-12 col-md-4">
                                                            <label class="form-label fw-semibold">
                                                                Ejecución <span class="text-danger fw-bold">*</span>
                                                            </label>
                                                            <div class="input-group mb-2">
                                                                <span class="input-group-text">Ini</span>
                                                                <input type="time" class="form-control" id="ejec_ini" name="ejec_ini" >
                                                            </div>
                                                            <div class="input-group">
                                                                <span class="input-group-text">Fin</span>
                                                                <input type="time" class="form-control" id="ejec_fin" name="ejec_fin" >
                                                            </div>
                                                        </div>
                                                    </div>

                                                    <hr class="my-3">

                                                    <label class="form-label">
                                                        Observación <small class="text-muted">(opcional)</small>
                                                    </label>
                                                    <textarea id="observacion" name="observacion" class="form-control" rows="3" maxlength="250"></textarea>

                                                </div>
                                            </div>
                                        </div>

                                    </div><!-- /accordion -->
                                </form>

                            </div>
                        </div>
                    </div>

                </div><!-- /row -->
            </div><!-- /modal-body -->

            <!-- FOOTER: acciones fijas -->
            <div class="modal-footer">
                <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal" onclick="cerrarVentana()">
                    Cerrar
                </button>
                <button type="submit" class="btn btn-success" form="formDetalleOt">
                    <i class="bi bi-save"></i> Guardar
                </button>
            </div>

        </div>
    </div>
</div>

<script>
    // Scroll/enfoque al formulario (cuando das "Nuevo" o al editar)
    function enfocarFormularioDetalle() {
        const el = document.getElementById('contenedorFormularioDetalle');
        if (!el) return;
        el.scrollIntoView({
            behavior: 'smooth',
            block: 'start'
        });
        setTimeout(() => document.getElementById('fecha')?.focus(), 250);
    }

    // Búsqueda simple (tabla desktop + cards móvil)
    document.addEventListener('input', (e) => {
        if (e.target.id !== 'buscarDetalle') return;
        const q = e.target.value.toLowerCase().trim();

        const table = document.getElementById('tablaDetalles');
        if (table) {
            table.querySelectorAll('tbody tr').forEach(tr => {
                const text = tr.innerText.toLowerCase();
                tr.style.display = text.includes(q) ? '' : 'none';
            });
        }

        const cards = document.getElementById('detalleCards');
        if (cards) {
            cards.querySelectorAll('.tool-card').forEach(card => {
                const text = card.innerText.toLowerCase();
                card.style.display = text.includes(q) ? '' : 'none';
            });
        }
    });
</script>

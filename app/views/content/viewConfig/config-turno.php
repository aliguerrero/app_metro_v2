<!-- Encabezado -->
<div class="d-flex align-items-center gap-2 mb-2">
    <div class="avatar avatar-md bg-light d-flex align-items-center justify-content-center">
        <i class="bi bi-clock-fill fs-4"></i>
    </div>
    <div>
        <h4 class="mb-0">Turnos de trabajo</h4>
        <small class="text-muted">Crea, edita o elimina turnos del sistema.</small>
    </div>
</div>

<hr>

<!-- Crear -->
<div class="card mb-4">
    <div class="card-header">
        <strong>Registrar Turno</strong>
    </div>

    <div class="card-body">
        <!-- Recomendado: sin FormularioAjax para evitar doble handler global -->
        <form id="formTurnoCrear" action="#" method="POST" autocomplete="off">
            <div class="row g-3 align-items-end turno-row">
                <!-- Nombre -->
                <div class="col-12 col-lg-9">
                    <label class="form-label"><b>Nombre del turno</b></label>
                    <input class="form-control turno-h" name="turno" id="turno" type="text"
                        placeholder="Ej: Turno Diurno / Turno Nocturno">
                </div>

                <!-- Botón -->
                <div class="col-12 col-lg-3">
                    <label class="form-label d-none d-lg-block invisible">Acción</label>
                    <button class="btn btn-success w-100 turno-h" type="submit" title="Guardar">
                        <i class="bi bi-save"></i>
                        <span class="d-none d-md-inline ms-1">Guardar</span>
                    </button>
                </div>
            </div>

            <div class="form-text mt-2">
                Usa nombres cortos y claros (ej: Diurno, Nocturno, Guardia).
            </div>
        </form>
    </div>
</div>

<!-- Lista -->
<div class="card mb-4">
    <div class="card-header d-flex align-items-center justify-content-between">
        <strong>Lista de Turnos</strong>
        <button type="button" class="btn btn-sm btn-primary" id="btnRecargarTurno" title="Recargar">
            <i class="bi bi-arrow-clockwise"></i>
        </button>
    </div>

    <div class="card-body p-0">
        <!-- Este contenedor se reemplaza por JS -->
        <div id="turnoListWrap">
            <?php echo $insConfig->listarTurnoControlador(""); ?>
        </div>
    </div>
</div>

<!-- Modal Editar -->
<div class="modal fade" id="ventanaModalModificarTurno" tabindex="-1" aria-labelledby="ventanaModalModificarTurnoLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">

            <div class="modal-header">
                <div class="d-flex align-items-center gap-2">
                    <i class="bx bx-edit-alt fs-2 text-primary" aria-hidden="true"></i>
                    <div>
                        <h5 class="modal-title mb-0" id="ventanaModalModificarTurnoLabel">Modificar Turno</h5>
                        <small class="text-muted">Actualiza el nombre del turno seleccionado.</small>
                    </div>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close">X</button>
            </div>

            <div class="modal-body">
                <!-- Recomendado: sin FormularioAjax para evitar doble handler global -->
                <form id="formTurnoEditar" action="#" method="POST" autocomplete="off">
                    <input type="hidden" id="edit_id_turno" name="id_ai_turno" value="">

                    <div class="card mb-3">
                        <div class="card-header">
                            <strong>Datos del turno</strong>
                        </div>
                        <div class="card-body">
                            <div class="row g-3">
                                <div class="col-12">
                                    <label class="form-label"><b>Nombre del turno</b></label>
                                    <input class="form-control" id="edit_nombre_turno" name="nombre_turno" type="text"
                                        placeholder="Ej: Turno Diurno / Turno Nocturno">
                                    <div class="form-text">Este nombre se usa en formularios y reportes.</div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="btn-group w-100">
                        <button type="submit" class="btn bg-success text-white">Guardar</button>
                        <button type="button" class="btn bg-danger text-white" data-bs-dismiss="modal">Cancelar</button>
                    </div>
                </form>
            </div>

        </div>
    </div>
</div>

<!-- JS -->
<script src="<?php echo APP_URL; ?>app/views/js/turno_crud.js"></script>

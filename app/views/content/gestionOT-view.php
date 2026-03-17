<div class="tools-scope">
    <?php
    $perms = $_SESSION['permisos'] ?? [];
    $can = function (string $key) use ($perms): bool {
        return isset($perms[$key]) && (int)$perms[$key] === 1;
    };

    if (!$can('perm_ot_view')) {
        echo '<div class="alert alert-danger mt-3">Acceso denegado: no tienes permiso para ver Órdenes de Trabajo.</div>';
        return;
    }

    use app\controllers\otController;

    $insOt = new otController();
    ?>

    <!-- Permisos para JS/UI (MISMO) -->
    <input type="hidden" id="perm_ot_view" value="<?php echo $can('perm_ot_view') ? '1' : '0'; ?>">
    <input type="hidden" id="perm_ot_add" value="<?php echo $can('perm_ot_add') ? '1' : '0'; ?>">
    <input type="hidden" id="perm_ot_add_detalle" value="<?php echo $can('perm_ot_add_detalle') ? '1' : '0'; ?>">
    <input type="hidden" id="perm_ot_edit" value="<?php echo $can('perm_ot_edit') ? '1' : '0'; ?>">
    <input type="hidden" id="perm_ot_delete" value="<?php echo $can('perm_ot_delete') ? '1' : '0'; ?>">

    <input type="hidden" id="perm_herr_view" value="<?php echo $can('perm_herramienta_view') ? '1' : '0'; ?>">
    <input type="hidden" id="perm_herr_edit" value="<?php echo $can('perm_herramienta_edit') ? '1' : '0'; ?>">
    <input type="hidden" id="perm_herr_delete" value="<?php echo $can('perm_herramienta_delete') ? '1' : '0'; ?>">

    <!-- ===== HEAD ===== -->
    <div class="row pb-3">
        <div class="container-fluid">
            <div class="page-head">
                <h3>Gestión de Órdenes de Trabajo</h3>
            </div>
        </div>
    </div>

    <!-- ===== BUSCADOR ===== -->
    <div class="row">
        <div class="card mb-4">
            <div class="card-header">
                <strong>Buscador</strong>
            </div>

            <!-- ✅ CARD BODY (con cambios aplicados) -->
            <div class="card-body">
                <div class="row m-0 align-items-end ot-search-row">

                    <!-- ✅ ÁREA (EXTREMO IZQUIERDO) -->
                    <div class="col-12 col-md-6 col-lg-2 ot-join-col ot-join-first">
                        <?php echo $insOt->listarComboAreaControlador(); ?>
                    </div>

                    <!-- ✅ TIPO DE BÚSQUEDA (EN MEDIO) -->
                    <div class="col-12 col-md-6 col-lg-2 ot-join-col">
                        <label class="form-label" for="tipo_busqueda"><b>TIPO DE BÚSQUEDA</b></label>
                        <select class="form-select" id="tipo_busqueda" name="tipo_busqueda">
                            <option value="1">NRO O.T.</option>
                            <option value="2">RANGO DE FECHA</option>
                            <option value="3">ESTADO</option>
                            <option value="4">OPERADOR</option>
                        </select>
                    </div>

                    <!-- ✅ NRO OT (EXTREMO DERECHO DEL GRUPO) -->
                    <div class="col-12 col-lg-4 ot-join-col ot-join-last" id="nrot_field">
                        <label class="form-label"><b>N° de O.T.</b></label>
                        <div class="input-group search-join flex-nowrap">
                            <input class="form-control" name="nrot" id="nrot" type="text" placeholder="Número de O.T.">
                            <button class="btn btn-primary" type="button" id="btnBuscarOt" title="Buscar">
                                <i class="bx bx-search fs-5" aria-hidden="true"></i>
                            </button>
                        </div>
                    </div>

                    <!-- ✅ FECHAS (MISMO ESPACIO, EXTREMO DERECHO DEL GRUPO) -->
                    <div class="col-12 col-lg-4 ot-join-col ot-join-last" id="fecha_field" style="display:none;">
                        <div class="row m-0">
                            <div class="col-12 col-sm-6">
                                <label for="fecha_desde" class="form-label"><b>DESDE</b></label>
                                <input type="date" class="form-control" id="fecha_desde" name="fecha_desde">
                            </div>

                            <div class="col-12 col-sm-6">
                                <label for="fecha_hasta" class="form-label"><b>HASTA</b></label>
                                <div class="input-group search-join flex-nowrap">
                                    <input type="date" class="form-control" id="fecha_hasta" name="fecha_hasta">
                                    <button class="btn btn-primary" type="button" id="btnBuscarFecha" title="Buscar">
                                        <i class="bx bx-search fs-5" aria-hidden="true"></i>
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- ✅ ESTADO (MISMO ESPACIO, EXTREMO DERECHO DEL GRUPO) -->
                    <div class="col-12 col-lg-4 ot-join-col ot-join-last" id="estado_field" style="display:none;">
                        <label class="form-label"><b>ESTADO</b></label>
                        <div class="input-group search-join flex-nowrap">
                            <?php echo $insOt->listarComboEstadoControlador(); ?>
                            <button class="btn btn-primary" type="button" id="btnBuscarEstado" title="Buscar">
                                <i class="bx bx-search fs-5" aria-hidden="true"></i>
                            </button>
                        </div>
                    </div>

                    <!-- ✅ OPERADOR (MISMO ESPACIO, EXTREMO DERECHO DEL GRUPO) -->
                    <div class="col-12 col-lg-4 ot-join-col ot-join-last" id="operador_field" style="display:none;">
                        <label class="form-label"><b>OPERADOR</b></label>
                        <div class="input-group search-join flex-nowrap">
                            <?php echo $insOt->listarComboUserControlador(); ?>
                            <button class="btn btn-primary" type="button" id="btnBuscarUser" title="Buscar">
                                <i class="bx bx-search fs-5" aria-hidden="true"></i>
                            </button>
                        </div>
                    </div>

                    <!-- ✅ NUEVA OT (FUERA DEL GRUPO, A LA DERECHA EN DESKTOP) -->
                    <?php if ($can('perm_ot_add')) { ?>
                        <div class="col-12 col-lg-2 ms-lg-auto d-flex pt-2 mb-4">
                            <button type="button" class="btn btn-success w-100"
                                data-bs-toggle="modal" data-bs-target="#ventanaModalRegistroOt">
                                <i class="bx bx-plus fs-5" aria-hidden="true"></i>
                                Nueva O.T.
                            </button>
                        </div>
                    <?php } ?>

                </div>
            </div>

        </div>
    </div>

    <!-- ===== LISTA ===== -->
    <div class="row">
        <div class="card mb-4">
            <div class="card-header">
                <!-- izquierda, como herramientas -->
                <button type="button" class="btn btn-sm btn-primary" onclick="reiniciarTablaOT('<?php echo APP_URL; ?>')" title="Recargar Tabla">
                    <i class="bi bi-arrow-clockwise"></i>
                </button>
                <strong>Lista de Órdenes de Trabajo</strong>
            </div>

            <div class="card-body">
                <?php echo $insOt->listarOtControlador(); ?>
            </div>
        </div>
    </div>

    <?php
    $modalsDir = __DIR__ . '/modals/';

    if ($can('perm_ot_add')) {
        $f = $modalsDir . 'modalRegistroOt.php';
        if (file_exists($f)) include $f;
    }
    if ($can('perm_ot_add_detalle')) {
        $f1 = $modalsDir . 'modalRegistroDetallesOt.php';
        $f2 = $modalsDir . 'modalRegistrodetallesOt.php';
        if (file_exists($f1)) include $f1;
        elseif (file_exists($f2)) include $f2;
    }
    if ($can('perm_ot_edit')) {
        $f = $modalsDir . 'modalModificarOt.php';
        if (file_exists($f)) include $f;
    }
    if ($can('perm_herramienta_view') || $can('perm_ot_edit')) {
        $fB = $modalsDir . 'modalHerramientaOt.php';
        if (file_exists($fB)) include $fB;
    }

    $scriptDetalle = __DIR__ . '/../scripts/script-detalle.php';
    if (!file_exists($scriptDetalle)) $scriptDetalle = __DIR__ . '/../../views/scripts/script-detalle.php';
    if (file_exists($scriptDetalle)) include_once $scriptDetalle;
    ?>
</div>

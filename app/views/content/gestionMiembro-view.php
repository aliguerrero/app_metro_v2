<div class="tools-scope">
    <?php
    $perms = $_SESSION['permisos'] ?? [];
    $can = function (string $key) use ($perms): bool {
        return !empty($perms[$key]) && (int)$perms[$key] === 1;
    };

    if (!$can('perm_miembro_view')) {
        echo '<div class="alert alert-danger mt-3">Acceso denegado: no tienes permiso para ver Miembros.</div>';
        return;
    }
    ?>

    <input type="hidden" id="perm_miem_edit" value="<?php echo $can('perm_miembro_edit') ? '1' : '0'; ?>">
    <input type="hidden" id="perm_miem_delete" value="<?php echo $can('perm_miembro_delete') ? '1' : '0'; ?>">

    <div class="row pb-3">
        <div class="container-fluid">
            <div class="page-head">
                <h3>Gestion de Miembros</h3>
            </div>
        </div>
    </div>

    <!-- Card del Buscador -->
    <div class="row">
        <div class="card mb-4">
            <div class="card-header">
                <strong>Buscador</strong>
            </div>
            <div class="card-body">
                <div class="row g-3 align-items-end">
                    <div class="col-12 col-lg-9" id="nrot_field">
                        <label class="form-label"><b>BUSCAR MIEMBRO</b></label>

                        <div class="input-group tools-join flex-nowrap w-100">
                            <!-- MISMO id/name -->
                            <input class="form-control flex-grow-1" name="campo" id="campo" type="text"
                                placeholder="Busqueda por codigo, empleado o documento">

                            <?php if ($can('perm_miembro_add')) { ?>
                                <button type="button" class="btn btn-success tools-join-btn flex-shrink-0"
                                    data-bs-toggle="modal" data-bs-target="#ventanaModalRegistrarMiem">
                                    <i class="bx bx-plus fs-5" aria-hidden="true"></i>
                                    <span class="d-none d-md-inline ms-1">Nuevo Miembro</span>
                                </button>
                            <?php } ?>
                        </div>

                    </div>
                </div>
            </div>

        </div>
    </div>
    <!-- Card de la lista de miembros -->
    <div class="row">
        <div class="card mb-4">
            <div class="card-header">
                <button type="button" class="btn btn-sm btn-primary" id="btnRecargar" title="Recargar Tabla">
                    <i class="bi bi-arrow-clockwise"></i>
                </button>
                <strong>Lista de Miembros</strong>
            </div>
            <div class="card-body">
                <?php

                use app\controllers\miembroController;

                $insMiembro = new miembroController();
                echo $insMiembro->listarMiembroControlador();
                ?>
            </div>
        </div>

        <!-- InclusiÃ³n de modales de registro y modificaciÃ³n de miembros -->
        <?php if ($can('perm_miembro_add')) {
            include 'modals/modalRegistroMiembro.php';
        } ?>
        <?php if ($can('perm_miembro_edit')) {
            include 'modals/modalModificarMiembro.php';
        } ?>

        <?php require_once "./app/views/scripts/script-miem.php"; ?>
    </div>
</div>


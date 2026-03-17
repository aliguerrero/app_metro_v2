<div class="tools-scope">
    <?php
    use app\controllers\herramientaController;

    $perms = $_SESSION['permisos'] ?? [];
    $can = function (string $key) use ($perms): bool {
        return !empty($perms[$key]) && (int)$perms[$key] === 1;
    };
    $insHerramienta = new herramientaController();

    if (!$can('perm_herramienta_view')) {
        echo '<div class="alert alert-danger mt-3">Acceso denegado: no tienes permiso para ver Herramientas.</div>';
        return;
    }
    ?>

    <input type="hidden" id="perm_herr_edit" value="<?php echo $can('perm_herramienta_edit') ? '1' : '0'; ?>">
    <input type="hidden" id="perm_herr_delete" value="<?php echo $can('perm_herramienta_delete') ? '1' : '0'; ?>">

    <div class="row pb-3">
        <div class="container-fluid">
            <div class="page-head">
                <h3>Gestion de Herramientas</h3>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="card mb-4">
            <div class="card-header">
                <strong>Buscador</strong>
            </div>
            <div class="card-body">
                <div class="row g-3 align-items-end">
                    <div class="col-12 col-lg-9" id="nrot_field">
                        <label class="form-label"><b>BUSCAR HERRAMIENTA</b></label>

                        <div class="input-group tools-join flex-nowrap w-100">
                            <input class="form-control flex-grow-1" name="campo" id="campo" type="text"
                                placeholder="Busqueda por codigo, nombre o categoria">

                            <?php if ($can('perm_herramienta_add')) { ?>
                                <button type="button" class="btn btn-success tools-join-btn flex-shrink-0"
                                    data-bs-toggle="modal" data-bs-target="#ventanaModalRegistrarHerr">
                                    <i class="bx bx-plus fs-5" aria-hidden="true"></i>
                                    <span class="d-none d-md-inline ms-1">Nueva Herramienta</span>
                                </button>
                            <?php } ?>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="card mb-4">
            <div class="card-header">
                <button type="button" class="btn btn-sm btn-primary" id="btnRecargar" title="Recargar Tabla">
                    <i class="bi bi-arrow-clockwise"></i>
                </button>
                <strong>Lista de Herramienta</strong>
            </div>

            <div class="card-body">
                <?php echo $insHerramienta->listarHerramientaControlador(); ?>
            </div>
        </div>
    </div>

    <?php if ($can('perm_herramienta_add')) {
        include 'modals/modalRegistroHerramienta.php';
    } ?>
    <?php if ($can('perm_herramienta_edit')) {
        include 'modals/modalModificarHerramienta.php';
    } ?>
    <?php include 'modals/modalVerHerramienta.php'; ?>

    <?php require_once "./app/views/scripts/script-herr.php"; ?>
</div>

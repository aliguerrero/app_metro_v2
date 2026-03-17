<div class="tools-scope">
    <?php
    $perms = $_SESSION['permisos'] ?? [];
    $can = function (string $key) use ($perms): bool {
        return !empty($perms[$key]) && (int)$perms[$key] === 1;
    };

    if (!$can('perm_usuarios_view')) {
        echo '<div class="alert alert-danger mt-3">Acceso denegado: no tienes permiso para ver Usuarios.</div>';
        return;
    }
    ?>

    <input type="hidden" id="perm_user_edit" value="<?php echo $can('perm_usuarios_edit') ? '1' : '0'; ?>">
    <input type="hidden" id="perm_user_delete" value="<?php echo $can('perm_usuarios_delete') ? '1' : '0'; ?>">

    <div class="row pb-3">
        <div class="container-fluid">
            <div class="page-head">
                <h3>Gestion de Usuarios</h3>
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
                    <div class="col-12 col-lg-9">
                        <label class="form-label"><b>BUSCAR USUARIO</b></label>

                        <div class="input-group tools-join flex-nowrap w-100">
                            <input class="form-control flex-grow-1" name="campo" id="campo" type="text"
                                placeholder="Busqueda por ID, empleado, categoria, username o rol">

                            <?php if ($can('perm_usuarios_add')) { ?>
                                <button type="button" class="btn btn-success tools-join-btn flex-shrink-0"
                                    data-bs-toggle="modal" data-bs-target="#ventanaModalRegistrar">
                                    <i class="bx bx-plus fs-5" aria-hidden="true"></i>
                                    <span class="d-none d-md-inline ms-1">Nuevo Usuario</span>
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
                <strong>Lista de Usuarios</strong>
            </div>

            <div class="card-body">
                <?php

                use app\controllers\userController;

                $insUsuario = new userController();
                echo $insUsuario->listarUsuarioControlador();
                ?>
            </div>
        </div>

        <?php if ($can('perm_usuarios_add')) {
            include 'modals/modalRegistroUser.php';
        } ?>
        <?php if ($can('perm_usuarios_edit')) {
            include 'modals/modalModificarUser.php';
        } ?>
        <?php if ($can('perm_usuarios_edit')) {
            include 'modals/modalModificarPass.php';
        } ?>
        <?php require_once "./app/views/scripts/script-user.php"; ?>
    </div>
</div>

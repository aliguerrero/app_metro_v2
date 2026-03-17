<?php
$isAdmin = (isset($_SESSION['tipo']) && (int)$_SESSION['tipo'] === 1);
$perms = $_SESSION['permisos'] ?? [];

$can = function (string $key) use ($perms): bool {
    return !empty($perms[$key]) && (int)$perms[$key] === 1;
};
?>
<div class="sidebar sidebar-dark sidebar-fixed" id="sidebar">
    <div class="sidebar-brand d-none d-md-flex p-2">
        <a class="nav-link" href="<?php echo APP_URL; ?>dashboard/">
            <img src="<?php echo APP_URL; ?>app/views/img/logo.png" alt="icon-metro" style="width: 10em;">
        </a>
    </div>

    <ul class="sidebar-nav" data-coreui="navigation" data-simplebar="">
        <!-- Menú del Usuario con icono de flecha -->
        <li class="nav-item dropdown">
            <a class="nav-link py-0" data-coreui-toggle="dropdown" href="#" role="button" aria-haspopup="true" aria-expanded="false">
                <div class="avatar avatar-md">
                    <img class="avatar-img" src="<?php echo APP_URL; ?>app/views/img/avatars/user.png" alt="user@email.com">
                </div>
                <label><?php echo $_SESSION['user'] ?></label>
                <!-- Icono de flecha hacia abajo (para indicar que es un dropdown) -->
                <i class="bx bx-chevron-down ms-2"></i>
            </a>
            <!-- Aquí estaba el dropdown menu que se estaba perdiendo -->
            <div class="dropdown-menu dropdown-menu-end pt-0">
                <div class="dropdown-header bg-light py-2">
                    <div class="fw-semibold">Opciones</div>
                </div>

                <?php if ($can('perm_usuarios_view')) { ?>
                    <a class="dropdown-item" href="<?php echo APP_URL; ?>usuario/">
                        <i class="bx bx-user me-2"></i> Usuarios
                    </a>
                <?php } ?>
                <?php if ($isAdmin) { ?>
                    <a class="dropdown-item" href="<?php echo APP_URL; ?>logsUser/">
                        <i class="bx bx-book-content me-2"></i>Entradas Logs
                    </a>
                <?php } ?>
                <a class="dropdown-item" href="<?php echo APP_URL; ?>config/">
                    <i class="bx bx-cog me-2"></i> Configuración
                </a>

                <div class="dropdown-divider"></div>

                <a class="dropdown-item" href="<?php echo APP_URL; ?>logOut/" id="btn_exit">
                    <i class="bx bx-log-out me-2"></i> Cerrar sesión
                </a>
            </div>
        </li>
        <hr>
        <li class="nav-item">
            <a class="nav-link" href="<?php echo APP_URL; ?>dashboard/">
                <i class="bx bx-tachometer nav-icon"></i> Panel
            </a>
        </li>

        <?php if ($can('perm_ot_view')) { ?>
            <li class="nav-item">
                <a class="nav-link" href="<?php echo APP_URL; ?>gestionOT/">
                    <i class="bx bx-clipboard nav-icon"></i> Ordenes de Trabajo
                </a>
            </li>
        <?php } ?>

        <?php if ($can('perm_miembro_view')) { ?>
            <li class="nav-item">
                <a class="nav-link" href="<?php echo APP_URL; ?>gestionMiembro/">
                    <i class="bx bx-group nav-icon"></i> Miembro
                </a>
            </li>
        <?php } ?>

        <?php if ($can('perm_herramienta_view')) { ?>
            <li class="nav-item">
                <a class="nav-link" href="<?php echo APP_URL; ?>gestionHerramienta/">
                    <i class="bx bx-wrench nav-icon"></i> Herramienta
                </a>
            </li>
        <?php } ?>

        <?php if ($can('perm_ot_generar_reporte')) { ?>
            <li class="nav-item">
                <a class="nav-link" href="<?php echo APP_URL; ?>reporte/">
                    <i class="bx bx-file nav-icon"></i> Reportes
                </a>
            </li>
        <?php } ?>
    </ul>
</div>

<div class="wrapper d-flex flex-column min-vh-100 bg-light">
    <header class="header header-sticky mb-4 w-100">
        <div class="container-fluid">
            <button class="header-toggler px-md-0 me-md-3" type="button" onclick="coreui.Sidebar.getInstance(document.querySelector('#sidebar')).toggle()">
                <i class="bx bx-menu fs-4"></i>
            </button>
            <a class="header-brand d-md-none mx-auto d-md-flex" href="<?php echo APP_URL; ?>dashboard/">
                <img src="<?php echo APP_URL; ?>app/views/img/logo.png" class="logo-flotante" width="110" height="110">
            </a>
        </div>
    </header>
    <main id="main" class="body flex-grow-1 px-3">
        <input type="hidden" id="userID" name="userID" value="<?php echo $_SESSION['id']; ?>">
        <input type="hidden" id="url" name="url" value="<?php echo APP_URL; ?>">
        <?php require_once $vista; ?>
    </main>
    <footer class="footer">
        <div class="container text-center">
            <div class="row">
                <div class="col-lg-12">
                    <p class="small mb-0">Desarrollado por Grupo de Proyecto UPT Valencia <i class="bi bi-building"></i> © 2026 C.A, Metro Valencia. Todos los derechos reservados.</p>
                </div>
            </div>
        </div>
    </footer>
</div>

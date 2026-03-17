<?php

use app\controllers\empleadoController;

$insEmpleado = new empleadoController();
$empleadoActual = $insEmpleado->obtenerEmpleadoPorCodigo((string)($_SESSION['id'] ?? ''));

$documentoEmpleado = (($empleadoActual['nacionalidad'] ?? 'V') === 'E' ? 'E' : 'V')
    . '-'
    . (string)($_SESSION['id'] ?? '');
$nombreEmpleado = $empleadoActual['nombre_empleado'] ?? ($_SESSION['user'] ?? '');
$categoriaEmpleado = $empleadoActual['nombre_categoria'] ?? ($_SESSION['categoria_empleado'] ?? 'SIN CATEGORIA');
?>

<div class="d-flex align-items-center gap-2 mb-2">
    <div class="avatar avatar-md bg-light d-flex align-items-center justify-content-center">
        <i class="bi bi-person-fill fs-4"></i>
    </div>
    <div>
        <h4 class="mb-0">Cuenta de usuario</h4>
        <small class="text-muted">Tu perfil de acceso ahora se vincula a un empleado registrado.</small>
    </div>

    <?php if (isset($_SESSION['tipo']) && (int)$_SESSION['tipo'] === 1) { ?>
        <span class="badge bg-success">Administrador</span>
    <?php } else { ?>
        <span class="badge bg-secondary">Usuario</span>
    <?php } ?>
</div>

<hr>

<div class="card mb-3">
    <div class="card-header">
        <strong>Empleado vinculado</strong>
    </div>

    <div class="card-body">
        <div class="row g-3">
            <div class="col-12 col-md-4">
                <label class="form-label"><b>ID EMPLEADO</b></label>
                <input class="form-control" type="text" value="<?php echo htmlspecialchars((string)$documentoEmpleado, ENT_QUOTES, 'UTF-8'); ?>" readonly>
            </div>

            <div class="col-12 col-md-5">
                <label class="form-label"><b>NOMBRE</b></label>
                <input class="form-control" type="text" value="<?php echo htmlspecialchars((string)$nombreEmpleado, ENT_QUOTES, 'UTF-8'); ?>" readonly>
            </div>

            <div class="col-12 col-md-3">
                <label class="form-label"><b>CATEGORIA</b></label>
                <input class="form-control" type="text" value="<?php echo htmlspecialchars((string)$categoriaEmpleado, ENT_QUOTES, 'UTF-8'); ?>" readonly>
            </div>
        </div>

        <div class="form-text mt-2">
            Los datos del empleado se administran desde las secciones <b>Empleados</b> y <b>Categorias Empleado</b>.
        </div>
    </div>
</div>

<form id="configUser" action="<?php echo APP_URL; ?>app/ajax/userAjax.php" method="POST" autocomplete="off">
    <input type="hidden" name="modulo_user" value="modificarUserSesion">

    <div class="card mb-3">
        <div class="card-header">
            <strong>Acceso al sistema</strong>
        </div>

        <div class="card-body">
            <div class="row g-3">
                <div class="col-12">
                    <label class="form-label"><b>USERNAME</b></label>
                    <div class="input-group">
                        <span class="input-group-text">@</span>
                        <input type="text" class="form-control" name="username" id="username"
                            value="<?php echo htmlspecialchars((string)($_SESSION['username'] ?? ''), ENT_QUOTES, 'UTF-8'); ?>"
                            placeholder="Ingresar nombre de usuario" autocomplete="off">
                    </div>
                    <small class="text-muted">Evita espacios y caracteres especiales.</small>
                </div>

                <div class="col-12 col-md-6">
                    <label class="form-label"><b>Nueva contrasena</b></label>
                    <input class="form-control" name="clave1" id="clave1_config" type="password" value=""
                        placeholder="Ingresar nueva contrasena" autocomplete="off">
                </div>

                <div class="col-12 col-md-6">
                    <label class="form-label"><b>Repetir contrasena</b></label>
                    <input class="form-control" name="clave2" id="clave2_config" type="password" value=""
                        placeholder="Repetir contrasena" autocomplete="off">
                </div>

                <div class="col-12">
                    <small class="text-muted">Si no deseas cambiar la contrasena, deja ambos campos vacios.</small>
                </div>
            </div>
        </div>
    </div>

    <div class="d-flex align-items-center gap-2 flex-wrap">
        <div class="btn-group w-100 w-lg-auto" role="group" aria-label="Acciones cuenta">
            <button class="btn bg-success text-white" type="submit" id="btnUserUpdate">
                <i class="bi bi-check2-circle me-1"></i> Actualizar
            </button>

            <button class="btn bg-danger text-white" type="reset">
                <i class="bi bi-arrow-counterclockwise me-1"></i> Limpiar
            </button>
        </div>

        <div id="msgUserConfig" class="ms-lg-auto small"></div>
    </div>
</form>

<script>
window.APP_URL = '<?php echo APP_URL; ?>';
</script>
<script src="<?php echo APP_URL; ?>app/views/js/user_config.js"></script>

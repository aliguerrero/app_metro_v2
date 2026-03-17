<?php
require_once "../../config/app.php";
require_once "../views/inc/session_start.php";
require_once "../../autoload.php";

use app\controllers\miembroController;

/**
 * Requiere un permiso por clave (roles_permisos).
 * Bloquea la ejecución devolviendo JSON si no hay permiso.
 */
function requirePerm(string $permKey): void
{
    $perms = $_SESSION['permisos'] ?? [];
    if (empty($perms[$permKey]) || (int)$perms[$permKey] !== 1) {
        echo json_encode([
            "tipo" => "simple",
            "titulo" => "Acceso denegado",
            "texto" => "No tienes permisos para realizar esta acción",
            "icono" => "error"
        ]);
        exit();
    }
}

if (isset($_POST['modulo_miembro'])) {

    $insMiembro = new miembroController();
    $accion = $_POST['modulo_miembro'];

    if ($accion === "registrar") {
        requirePerm('perm_miembro_add');
        echo $insMiembro->registrarMiembroControlador();
        exit();
    }

    if ($accion === "modificar") {
        requirePerm('perm_miembro_edit');
        echo $insMiembro->actualizarDatosMiembro();
        exit();
    }
  

    echo json_encode([
        "tipo" => "simple",
        "titulo" => "Ocurrió un error inesperado",
        "texto" => "Acción no válida",
        "icono" => "error"
    ]);
    exit();

} else {
    session_destroy();
    header("Location: " . APP_URL . "login/");
}

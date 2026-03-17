<?php
require_once "../../config/app.php";
require_once "../views/inc/session_start.php";
require_once "../../autoload.php";

use app\controllers\userController;

// helper local para permisos
function requirePerm(string $permKey)
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

if (isset($_POST['modulo_user'])) {

    $insUser = new userController();
    $accion = $_POST['modulo_user'];

    // ✅ Control real por permiso
    if ($accion == "registrar") {
        requirePerm('perm_usuarios_add');
        echo $insUser->registrarUserControlador();
        exit();
    }

    if ($accion == "eliminar") {
        requirePerm('perm_usuarios_delete');
        echo $insUser->eliminarUserControlador();
        exit();
    }

    if ($accion == "modificar") {
        requirePerm('perm_usuarios_edit');
        echo $insUser->actualizarDatosUser();
        exit();
    }

    if ($accion == "modificarUserSesion") {
        echo $insUser->actualizarDatosUserSesion();
        exit();
    }

    if ($accion == "clave") {
        requirePerm('perm_usuarios_edit');
        echo $insUser->actualizarClaveUser();
        exit();
    }

    // Acción no reconocida
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

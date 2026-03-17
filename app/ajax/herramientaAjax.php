<?php
require_once "../../config/app.php";
require_once "../views/inc/session_start.php";
require_once "../../autoload.php";

use app\controllers\herramientaController;

header('Content-Type: application/json; charset=utf-8');

if (!isset($_POST['modulo_herramienta'])) {
    // si llega aquí sin acción, lo tratamos como request inválido (no redirección)
    echo json_encode([
        "tipo" => "simple",
        "titulo" => "Solicitud inválida",
        "texto" => "Acción no especificada",
        "icono" => "error"
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

// (opcional pero recomendado) si no hay sesión, responde error
$idUser = $_SESSION['id_user'] ?? ($_SESSION['id'] ?? null);
if (empty($idUser)) {
    echo json_encode([
        "tipo" => "simple",
        "titulo" => "No autenticado",
        "texto" => "Debe iniciar sesión",
        "icono" => "error"
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

$insTools = new herramientaController();
$accion = $_POST['modulo_herramienta'];

switch ($accion) {
    case "registrar":
        echo $insTools->registrarHerramientaControlador();
        break;

    case "modificar":
        echo $insTools->actualizarDatosHeramienta();
        break;

    case "eliminar":
        echo $insTools->eliminarHerramientaControlador();
        break;

    default:
        echo json_encode([
            "tipo" => "simple",
            "titulo" => "Ocurrió un error inesperado",
            "texto" => "Acción no válida",
            "icono" => "error"
        ], JSON_UNESCAPED_UNICODE);
        break;
}

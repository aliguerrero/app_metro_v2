<?php
// otAjax.php

require_once "../../config/app.php";
require_once "../views/inc/session_start.php";
require_once "../../autoload.php";

use app\controllers\otController;

ini_set('display_errors', '0');
ini_set('log_errors', '1');
error_reporting(E_ALL);

/**
 * Respuesta JSON consistente
 */
function jsonResponse(array $payload, int $status = 200): void
{
    if (!headers_sent()) {
        header('Content-Type: application/json; charset=utf-8');
        http_response_code($status);
    }
    echo json_encode($payload, JSON_UNESCAPED_UNICODE);
    exit();
}

/**
 * Errores fatales -> JSON (evita HTML <br><b>...)
 */
register_shutdown_function(function () {
    $err = error_get_last();
    if ($err && in_array($err['type'], [E_ERROR, E_PARSE, E_CORE_ERROR, E_COMPILE_ERROR], true)) {
        jsonResponse([
            "ok" => false,
            "tipo" => "simple",
            "titulo" => "Error interno",
            "texto" => "Ocurrió un problema interno. Intenta nuevamente.",
            "icono" => "error",
            // opcional: comenta esto en producción
            "detail" => $err['message'],
        ], 500);
    }
});

/**
 * Requiere un permiso por clave (roles_permisos).
 */
function requirePerm(string $permKey): void
{
    $perms = $_SESSION['permisos'] ?? [];
    if (empty($perms[$permKey]) || (int)$perms[$permKey] !== 1) {
        jsonResponse([
            "ok" => false,
            "tipo" => "simple",
            "titulo" => "Acceso denegado",
            "texto" => "No tienes permisos para realizar esta acción",
            "icono" => "error"
        ], 403);
    }
}

// ✅ Si no viene el módulo: responde JSON (no redirección, para no romper el fetch/ajax)
if (!isset($_POST['modulo_ot'])) {
    jsonResponse([
        "ok" => false,
        "tipo" => "simple",
        "titulo" => "Solicitud inválida",
        "texto" => "No se recibió la acción del módulo.",
        "icono" => "error"
    ], 400);
}

try {
    $insOt = new otController();
    $accion = trim((string)$_POST['modulo_ot']);

    switch ($accion) {
        case "registrar_ot":
            requirePerm('perm_ot_add');
            // Se asume que el controlador retorna JSON (string)
            echo $insOt->registrarOtControlador();
            exit();

        case "modificar_ot":
            requirePerm('perm_ot_edit');
            echo $insOt->modificarOtControlador();
            exit();

        case "eliminar":
            requirePerm('perm_ot_delete');
            echo $insOt->eliminarOtControlador();
            exit();

        default:
            jsonResponse([
                "ok" => false,
                "tipo" => "simple",
                "titulo" => "Acción no válida",
                "texto" => "La acción solicitada no existe.",
                "icono" => "error"
            ], 400);
    }
} catch (Throwable $e) {
    jsonResponse([
        "ok" => false,
        "tipo" => "simple",
        "titulo" => "Error interno",
        "texto" => "Error interno al procesar la solicitud.",
        "icono" => "error",
        // opcional: comenta esto en producción
        "detail" => $e->getMessage()
    ], 500);
}

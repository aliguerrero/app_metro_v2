<?php
require_once "../../config/app.php";
require_once "../views/inc/session_start.php";
require_once "../../autoload.php";

use app\models\mainModel;

header('Content-Type: application/json; charset=utf-8');

function requirePerm(string $permKey): void
{
    $perms = $_SESSION['permisos'] ?? [];
    if (empty($perms[$permKey]) || (int)$perms[$permKey] !== 1) {
        echo json_encode(["ok" => false, "error" => "permiso_denegado"], JSON_UNESCAPED_UNICODE);
        exit();
    }
}

$mainModel = new mainModel();

$action = $mainModel->limpiarCadena($_POST['action'] ?? '');

if ($action === '') {
    echo json_encode(["ok" => false, "error" => "accion_vacia"], JSON_UNESCAPED_UNICODE);
    exit();
}

// Permisos (ajusta si quieres separar edit/delete)
requirePerm('perm_ot_view'); // ver config

try {

    if ($action === 'get') {
        $id = (int)($mainModel->limpiarCadena($_POST['id_ai_estado'] ?? '0'));
        if ($id <= 0) {
            echo json_encode(["ok" => false, "error" => "id_invalido"], JSON_UNESCAPED_UNICODE);
            exit();
        }

        $stmt = $mainModel->ejecutarConsultaConParametros(
            "SELECT id_ai_estado, nombre_estado, color FROM estado_ot WHERE id_ai_estado = :id and std_reg = 1 LIMIT 1",
            [":id" => $id]
        );

        $row = ($stmt && $stmt->rowCount() > 0) ? $stmt->fetch(PDO::FETCH_ASSOC) : null;

        if (!$row) {
            echo json_encode(["ok" => false, "error" => "no_encontrado"], JSON_UNESCAPED_UNICODE);
            exit();
        }

        echo json_encode(["ok" => true, "data" => $row], JSON_UNESCAPED_UNICODE);
        exit();
    }

    if ($action === 'create') {
        requirePerm('perm_ot_edit');

        $nombre = $mainModel->limpiarCadena($_POST['nombre_estado'] ?? '');
        $color  = $mainModel->limpiarCadena($_POST['color'] ?? '#00FFCC');

        if ($nombre === '') {
            echo json_encode(["ok" => false, "msg" => "Nombre requerido"], JSON_UNESCAPED_UNICODE);
            exit();
        }

        if (!preg_match('/^#[0-9A-Fa-f]{6}$/', $color)) {
            $color = '#00FFCC';
        }

        // ¿Existe?
        $q = $mainModel->ejecutarConsultaConParametros(
            "SELECT id_ai_estado, std_reg
         FROM estado_ot
         WHERE nombre_estado = :n
         LIMIT 1",
            [":n" => $nombre]
        );

        if ($q && $q->rowCount() > 0) {
            $row = $q->fetch(PDO::FETCH_ASSOC);

            // Si estaba eliminado -> reactivar
            if (isset($row['std_reg']) && (string)$row['std_reg'] === '0') {
                $mainModel->ejecutarConsultaConParametros(
                    "UPDATE estado_ot
                 SET std_reg = 1, color = :c
                 WHERE id_ai_estado = :id
                 LIMIT 1",
                    [":c" => $color, ":id" => (int)$row['id_ai_estado']]
                );

                echo json_encode(["ok" => true, "msg" => "Estado reactivado"], JSON_UNESCAPED_UNICODE);
                exit();
            }

            echo json_encode(["ok" => false, "msg" => "El estado ya existe"], JSON_UNESCAPED_UNICODE);
            exit();
        }

        // Nuevo
        $mainModel->ejecutarConsultaConParametros(
            "INSERT INTO estado_ot (nombre_estado, color, std_reg)
         VALUES (:n, :c, 1)",
            [":n" => $nombre, ":c" => $color]
        );

        echo json_encode(["ok" => true, "msg" => "Estado creado"], JSON_UNESCAPED_UNICODE);
        exit();
    }
    
    if ($action === 'update') {
        requirePerm('perm_ot_edit');

        $id     = (int)($mainModel->limpiarCadena($_POST['id_ai_estado'] ?? '0'));
        $nombre = $mainModel->limpiarCadena($_POST['nombre_estado'] ?? '');
        $color  = $mainModel->limpiarCadena($_POST['color'] ?? '#00FFCC');

        if ($id <= 0 || $nombre === '') {
            echo json_encode(["ok" => false, "error" => "datos_invalidos"], JSON_UNESCAPED_UNICODE);
            exit();
        }
        if (!preg_match('/^#[0-9A-Fa-f]{6}$/', $color)) {
            $color = '#00FFCC';
        }

        $mainModel->ejecutarConsultaConParametros(
            "UPDATE estado_ot SET nombre_estado = :n, color = :c WHERE id_ai_estado = :id",
            [":n" => $nombre, ":c" => $color, ":id" => $id]
        );

        echo json_encode(["ok" => true, "msg" => "Estado actualizado"], JSON_UNESCAPED_UNICODE);
        exit();
    }

    if ($action === 'delete') {
        requirePerm('perm_ot_edit'); // o el permiso que corresponda

        $id = (int)($mainModel->limpiarCadena($_POST['id_ai_estado'] ?? '0'));
        if ($id <= 0) {
            echo json_encode(["ok" => false, "msg" => "ID inválido"], JSON_UNESCAPED_UNICODE);
            exit();
        }

        // Verificar que exista y esté activo
        $q = $mainModel->ejecutarConsultaConParametros(
            "SELECT id_ai_estado, std_reg
         FROM estado_ot
         WHERE id_ai_estado = :id
         LIMIT 1",
            [":id" => $id]
        );

        if (!$q || $q->rowCount() <= 0) {
            echo json_encode(["ok" => false, "msg" => "No se encontró el estado"], JSON_UNESCAPED_UNICODE);
            exit();
        }

        $row = $q->fetch(PDO::FETCH_ASSOC);

        // Si ya está eliminado lógicamente
        if (isset($row['std_reg']) && (string)$row['std_reg'] === '0') {
            echo json_encode(["ok" => true, "msg" => "El estado ya estaba eliminado"], JSON_UNESCAPED_UNICODE);
            exit();
        }

        // ✅ Eliminación lógica
        $u = $mainModel->ejecutarConsultaConParametros(
            "UPDATE estado_ot
         SET std_reg = 0
         WHERE id_ai_estado = :id
         LIMIT 1",
            [":id" => $id]
        );

        echo json_encode(["ok" => true, "msg" => "Estado eliminado"], JSON_UNESCAPED_UNICODE);
        exit();
    }

    echo json_encode(["ok" => false, "error" => "accion_no_soportada"], JSON_UNESCAPED_UNICODE);
    exit();
} catch (Throwable $e) {
    echo json_encode(["ok" => false, "error" => "exception", "detail" => $e->getMessage()], JSON_UNESCAPED_UNICODE);
    exit();
}

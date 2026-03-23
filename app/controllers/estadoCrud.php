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

function boolPost(string $key): int
{
    return isset($_POST[$key]) && (string)$_POST[$key] === '1' ? 1 : 0;
}

function esEstadoProtegido(array $estado): bool
{
    return (int)($estado['bloquea_ot'] ?? 0) === 1
        || mb_strtoupper(trim((string)($estado['nombre_estado'] ?? '')), 'UTF-8') === 'EJECUTADA';
}

function fetchEstado(mainModel $mainModel, int $id): ?array
{
    $stmt = $mainModel->ejecutarConsultaConParametros(
        "SELECT id_ai_estado, nombre_estado, color,
                " . $mainModel->estadoOtLiberaHerramientasExpr() . " AS libera_herramientas,
                " . $mainModel->estadoOtBloqueaOtExpr() . " AS bloquea_ot,
                std_reg
         FROM estado_ot
         WHERE id_ai_estado = :id
         LIMIT 1",
        [":id" => $id]
    );

    if (!$stmt || $stmt->rowCount() <= 0) {
        return null;
    }

    return $stmt->fetch(PDO::FETCH_ASSOC) ?: null;
}

function estadoEnUso(mainModel $mainModel, int $id): int
{
    $stmt = $mainModel->ejecutarConsultaConParametros(
        "SELECT COUNT(1)
         FROM orden_trabajo
         WHERE id_ai_estado = :id
           AND std_reg = 1",
        [":id" => $id]
    );

    return $stmt ? (int)$stmt->fetchColumn() : 0;
}

function existeOtroEstadoBloqueante(mainModel $mainModel, int $excludeId = 0): bool
{
    $sql = "SELECT COUNT(1)
            FROM estado_ot
            WHERE std_reg = 1
              AND " . $mainModel->estadoOtBloqueaOtExpr() . " = 1";
    $params = [];

    if ($excludeId > 0) {
        $sql .= " AND id_ai_estado <> :id";
        $params[':id'] = $excludeId;
    }

    $stmt = $mainModel->ejecutarConsultaConParametros($sql, $params);
    return $stmt ? (int)$stmt->fetchColumn() > 0 : false;
}

$mainModel = new mainModel();
$action = $mainModel->limpiarCadena($_POST['action'] ?? '');

if ($action === '') {
    echo json_encode(["ok" => false, "error" => "accion_vacia"], JSON_UNESCAPED_UNICODE);
    exit();
}

requirePerm('perm_ot_view');

try {
    if ($action === 'get') {
        $id = (int)($mainModel->limpiarCadena($_POST['id_ai_estado'] ?? '0'));
        if ($id <= 0) {
            echo json_encode(["ok" => false, "error" => "id_invalido"], JSON_UNESCAPED_UNICODE);
            exit();
        }

        $row = fetchEstado($mainModel, $id);
        if (!$row || (int)$row['std_reg'] !== 1) {
            echo json_encode(["ok" => false, "error" => "no_encontrado"], JSON_UNESCAPED_UNICODE);
            exit();
        }

        $row['protegido'] = esEstadoProtegido($row);
        echo json_encode(["ok" => true, "data" => $row], JSON_UNESCAPED_UNICODE);
        exit();
    }

    if ($action === 'create') {
        requirePerm('perm_ot_edit');

        $nombre = mb_strtoupper($mainModel->limpiarCadena($_POST['nombre_estado'] ?? ''), 'UTF-8');
        $color  = $mainModel->limpiarCadena($_POST['color'] ?? '#00FFCC');
        $liberaHerramientas = boolPost('libera_herramientas');
        $bloqueaOt = boolPost('bloquea_ot');
        if ($bloqueaOt === 1) {
            $liberaHerramientas = 1;
        }

        if ($nombre === '') {
            echo json_encode(["ok" => false, "msg" => "Nombre requerido"], JSON_UNESCAPED_UNICODE);
            exit();
        }

        if (!preg_match('/^#[0-9A-Fa-f]{6}$/', $color)) {
            $color = '#00FFCC';
        }

        if ($bloqueaOt === 1 && existeOtroEstadoBloqueante($mainModel)) {
            echo json_encode(["ok" => false, "msg" => "Ya existe un estado activo que bloquea la O.T. Solo uno puede tener esa configuracion."], JSON_UNESCAPED_UNICODE);
            exit();
        }

        $q = $mainModel->ejecutarConsultaConParametros(
            "SELECT id_ai_estado, std_reg
             FROM estado_ot
             WHERE UPPER(nombre_estado) = UPPER(:n)
             LIMIT 1",
            [":n" => $nombre]
        );

        if ($q && $q->rowCount() > 0) {
            $row = $q->fetch(PDO::FETCH_ASSOC);

            if (isset($row['std_reg']) && (string)$row['std_reg'] === '0') {
                $mainModel->ejecutarConsultaConParametros(
                    "UPDATE estado_ot
                     SET std_reg = 1, color = :c, libera_herramientas = :libera, bloquea_ot = :bloquea
                     WHERE id_ai_estado = :id
                     LIMIT 1",
                    [":c" => $color, ":libera" => $liberaHerramientas, ":bloquea" => $bloqueaOt, ":id" => (int)$row['id_ai_estado']]
                );

                echo json_encode(["ok" => true, "msg" => "Estado reactivado"], JSON_UNESCAPED_UNICODE);
                exit();
            }

            echo json_encode(["ok" => false, "msg" => "El estado ya existe"], JSON_UNESCAPED_UNICODE);
            exit();
        }

        $mainModel->ejecutarConsultaConParametros(
            "INSERT INTO estado_ot (nombre_estado, color, libera_herramientas, bloquea_ot, std_reg)
             VALUES (:n, :c, :libera, :bloquea, 1)",
            [":n" => $nombre, ":c" => $color, ":libera" => $liberaHerramientas, ":bloquea" => $bloqueaOt]
        );

        echo json_encode(["ok" => true, "msg" => "Estado creado"], JSON_UNESCAPED_UNICODE);
        exit();
    }

    if ($action === 'update') {
        requirePerm('perm_ot_edit');

        $id     = (int)($mainModel->limpiarCadena($_POST['id_ai_estado'] ?? '0'));
        $nombre = mb_strtoupper($mainModel->limpiarCadena($_POST['nombre_estado'] ?? ''), 'UTF-8');
        $color  = $mainModel->limpiarCadena($_POST['color'] ?? '#00FFCC');
        $liberaHerramientas = boolPost('libera_herramientas');
        $bloqueaOt = boolPost('bloquea_ot');
        if ($bloqueaOt === 1) {
            $liberaHerramientas = 1;
        }

        if ($id <= 0 || $nombre === '') {
            echo json_encode(["ok" => false, "error" => "datos_invalidos"], JSON_UNESCAPED_UNICODE);
            exit();
        }
        if (!preg_match('/^#[0-9A-Fa-f]{6}$/', $color)) {
            $color = '#00FFCC';
        }

        $estado = fetchEstado($mainModel, $id);
        if (!$estado || (int)$estado['std_reg'] !== 1) {
            echo json_encode(["ok" => false, "msg" => "No se encontro el estado"], JSON_UNESCAPED_UNICODE);
            exit();
        }

        if (esEstadoProtegido($estado)) {
            echo json_encode(["ok" => false, "msg" => "El estado configurado para bloquear la O.T. es protegido y no puede modificarse."], JSON_UNESCAPED_UNICODE);
            exit();
        }

        if ($bloqueaOt === 1 && existeOtroEstadoBloqueante($mainModel, $id)) {
            echo json_encode(["ok" => false, "msg" => "Ya existe otro estado activo que bloquea la O.T. Solo uno puede tener esa configuracion."], JSON_UNESCAPED_UNICODE);
            exit();
        }

        $mainModel->ejecutarConsultaConParametros(
            "UPDATE estado_ot
             SET nombre_estado = :n, color = :c, libera_herramientas = :libera, bloquea_ot = :bloquea
             WHERE id_ai_estado = :id",
            [":n" => $nombre, ":c" => $color, ":libera" => $liberaHerramientas, ":bloquea" => $bloqueaOt, ":id" => $id]
        );

        echo json_encode(["ok" => true, "msg" => "Estado actualizado"], JSON_UNESCAPED_UNICODE);
        exit();
    }

    if ($action === 'delete') {
        requirePerm('perm_ot_edit');

        $id = (int)($mainModel->limpiarCadena($_POST['id_ai_estado'] ?? '0'));
        if ($id <= 0) {
            echo json_encode(["ok" => false, "msg" => "ID invalido"], JSON_UNESCAPED_UNICODE);
            exit();
        }

        $estado = fetchEstado($mainModel, $id);
        if (!$estado) {
            echo json_encode(["ok" => false, "msg" => "No se encontro el estado"], JSON_UNESCAPED_UNICODE);
            exit();
        }

        if (esEstadoProtegido($estado)) {
            echo json_encode(["ok" => false, "msg" => "El estado configurado para bloquear la O.T. es protegido y no puede eliminarse."], JSON_UNESCAPED_UNICODE);
            exit();
        }

        if ((string)$estado['std_reg'] === '0') {
            echo json_encode(["ok" => true, "msg" => "El estado ya estaba eliminado"], JSON_UNESCAPED_UNICODE);
            exit();
        }

        $uso = estadoEnUso($mainModel, $id);
        if ($uso > 0) {
            echo json_encode([
                "ok" => false,
                "msg" => "No puedes eliminar este estado porque esta asignado a {$uso} O.T. activa(s)."
            ], JSON_UNESCAPED_UNICODE);
            exit();
        }

        $mainModel->ejecutarConsultaConParametros(
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

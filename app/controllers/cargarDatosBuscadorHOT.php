<?php
require_once "../../config/app.php";
require_once "../views/inc/session_start.php";
require_once "../../autoload.php";

use app\models\mainModel;

function jsonOut($data): void
{
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($data, JSON_UNESCAPED_UNICODE);
    exit();
}

function requirePerm(string $permKey): void
{
    $perms = $_SESSION['permisos'] ?? [];
    if (empty($perms[$permKey]) || (int)$perms[$permKey] !== 1) {
        jsonOut([
            "error" => "permiso_denegado",
            "perm"  => $permKey
        ]);
    }
}

/**
 * Wrapper para ejecutar consultas preparadas con el metodo disponible en tu mainModel.
 * Ajusta aqui si tu metodo se llama diferente.
 */
function dbQuery(mainModel $m, string $sql, array $params = [])
{
    if (method_exists($m, 'ejecutarConsultaConParametros')) {
        return $m->ejecutarConsultaConParametros($sql, $params);
    }
    if (empty($params) && method_exists($m, 'ejecutarConsultas')) {
        return $m->ejecutarConsultas($sql);
    }
    return false;
}

$mainModel = new mainModel();
$estadoHerrExpr = $mainModel->herramientaOtEstadoExpr();
$estadoHerrHotExpr = $mainModel->herramientaOtEstadoExpr('hot');

$tipoBusqueda = $mainModel->limpiarCadena($_GET['tipoBusqueda'] ?? '');

if ($tipoBusqueda === '') {
    jsonOut([]);
}

if ($tipoBusqueda !== 'eliminar') {
    requirePerm('perm_ot_view');

    switch ($tipoBusqueda) {
        case 'todoHer': {
            $sql = "
                SELECT
                    id_ai_herramienta,
                    nombre_herramienta,
                    cantidad_total AS cantidad,
                    estado,
                    std_reg,
                    cantidad_disponible,
                    cantidad_ocupada AS herramienta_ocupada
                FROM vw_herramienta_disponibilidad
                ORDER BY id_ai_herramienta ASC
            ";
            $stmt = dbQuery($mainModel, $sql);
            $rows = ($stmt) ? $stmt->fetchAll(PDO::FETCH_ASSOC) : [];
            jsonOut($rows);
        }

        case 'todoHerOt':
        case 'cargarTabla': {
            $id = $mainModel->limpiarCadena($_GET['id'] ?? '');
            if ($id === '') {
                jsonOut([]);
            }

            $sql = "
                SELECT
                    hot.n_ot,
                    hot.id_ai_herramienta,
                    h.nombre_herramienta,
                    SUM(hot.cantidadot) AS cantidadot
                FROM herramientaot hot
                LEFT JOIN herramienta h ON hot.id_ai_herramienta = h.id_ai_herramienta
                WHERE hot.n_ot = :not
                  AND {$estadoHerrHotExpr} <> 'LIBERADA'
                GROUP BY hot.n_ot, hot.id_ai_herramienta, h.nombre_herramienta
                ORDER BY hot.id_ai_herramienta ASC
            ";
            $stmt = dbQuery($mainModel, $sql, [':not' => $id]);
            $rows = ($stmt) ? $stmt->fetchAll(PDO::FETCH_ASSOC) : [];
            jsonOut($rows);
        }

        case 'her': {
            $campo = $mainModel->limpiarCadena($_GET['campo'] ?? '');
            if ($campo === '') {
                jsonOut([]);
            }

            $q = '%' . $campo . '%';

            $sql = "
                SELECT
                    id_ai_herramienta,
                    nombre_herramienta,
                    cantidad_total AS cantidad,
                    estado,
                    std_reg,
                    cantidad_disponible,
                    cantidad_ocupada AS herramienta_ocupada
                FROM vw_herramienta_disponibilidad
                WHERE 1 = 1
                  AND (
                        CAST(id_ai_herramienta AS CHAR) LIKE :q
                        OR nombre_herramienta LIKE :q
                  )
                ORDER BY id_ai_herramienta ASC
            ";
            $stmt = dbQuery($mainModel, $sql, [':q' => $q]);
            $rows = ($stmt) ? $stmt->fetchAll(PDO::FETCH_ASSOC) : [];
            jsonOut($rows);
        }

        case 'herOt': {
            $campo = $mainModel->limpiarCadena($_GET['campo'] ?? '');
            $id = $mainModel->limpiarCadena($_GET['id'] ?? '');
            if ($id === '') {
                jsonOut([]);
            }

            $q = '%' . $campo . '%';

            $sql = "
                SELECT
                    hot.n_ot,
                    hot.id_ai_herramienta,
                    h.nombre_herramienta,
                    SUM(hot.cantidadot) AS cantidadot
                FROM herramientaot hot
                LEFT JOIN herramienta h ON hot.id_ai_herramienta = h.id_ai_herramienta
                WHERE hot.n_ot = :not
                  AND {$estadoHerrHotExpr} <> 'LIBERADA'
                  AND (
                        CAST(hot.id_ai_herramienta AS CHAR) LIKE :q
                        OR h.nombre_herramienta LIKE :q
                  )
                GROUP BY hot.n_ot, hot.id_ai_herramienta, h.nombre_herramienta
                ORDER BY hot.id_ai_herramienta ASC
            ";
            $stmt = dbQuery($mainModel, $sql, [':not' => $id, ':q' => $q]);
            $rows = ($stmt) ? $stmt->fetchAll(PDO::FETCH_ASSOC) : [];
            jsonOut($rows);
        }

        default:
            jsonOut([]);
    }
}

requirePerm('perm_ot_add_herramienta');

$tipo = $mainModel->limpiarCadena($_GET['tipo'] ?? '');
$n_ot = $mainModel->limpiarCadena($_GET['id'] ?? '');
$codigoHer = $mainModel->limpiarCadena($_GET['codigoHer'] ?? '');

if (!in_array($tipo, ['mas', 'menos'], true) || $n_ot === '' || $codigoHer === '' || !ctype_digit((string)$codigoHer)) {
    jsonOut(["error" => "parametros_invalidos"]);
}

$codigoHerInt = (int)$codigoHer;
$idUserOperacion = (string)($_SESSION['id_user'] ?? $_SESSION['id'] ?? '');

$stmtExist = dbQuery(
    $mainModel,
    "SELECT COALESCE(SUM(cantidadot), 0) AS cantidadot
     FROM herramientaot
     WHERE n_ot = :not
       AND id_ai_herramienta = :idher
       AND {$estadoHerrExpr} <> 'LIBERADA'",
    [':not' => $n_ot, ':idher' => $codigoHerInt]
);
$cantActual = ($stmtExist && $stmtExist->rowCount() > 0) ? (int)$stmtExist->fetchColumn() : 0;

if ($tipo === 'menos' && $cantActual <= 0) {
    jsonOut(["ok" => true]);
}

try {
    $mainModel->ejecutarProcedimientoFila(
        "CALL sp_ot_ajustar_herramienta_delta(:not, :idher, :delta, :id_user_operacion)",
        [
            ':not' => $n_ot,
            ':idher' => $codigoHerInt,
            ':delta' => ($tipo === 'mas' ? 1 : -1),
            ':id_user_operacion' => $idUserOperacion,
        ]
    );
    jsonOut(["ok" => true]);
} catch (Throwable $e) {
    $msg = $e->getMessage();
    if (stripos($msg, 'disponibilidad') !== false) {
        jsonOut("nohay");
    }
    if (stripos($msg, 'bloqueada') !== false) {
        jsonOut(["ok" => false, "error" => "ot_bloqueada"]);
    }
    if (stripos($msg, 'no existe') !== false || stripos($msg, 'inactiva') !== false) {
        jsonOut(["ok" => false, "error" => "herramienta_no_encontrada"]);
    }
    jsonOut(["ok" => false, "error" => "asignacion_fallida", "detail" => $msg]);
}

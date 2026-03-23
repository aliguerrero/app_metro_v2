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
 * Wrapper para ejecutar consultas preparadas con el método disponible en tu mainModel.
 * Ajusta aquí si tu método se llama diferente.
 */
function dbQuery(mainModel $m, string $sql, array $params = [])
{
    if (method_exists($m, 'ejecutarConsultaConParametros')) {
        return $m->ejecutarConsultaConParametros($sql, $params);
    }    
    // Último recurso (no recomendado). Ideal: NO llegar aquí.
    if (empty($params) && method_exists($m, 'ejecutarConsultas')) {
        return $m->ejecutarConsultas($sql);
    }
    return false;
}

$mainModel = new mainModel();

$tipoBusqueda = $mainModel->limpiarCadena($_GET['tipoBusqueda'] ?? '');

if ($tipoBusqueda === '') {
    jsonOut([]);
}

/**
 * ============================
 *  LISTADOS (GET)
 * ============================
 */
if ($tipoBusqueda !== 'eliminar') {

    // Este endpoint se usa dentro de OT (modal). Mínimo: ver OT.
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
                if ($id === '') jsonOut([]);

                $sql = "
                SELECT
                    hot.n_ot,
                    hot.id_ai_herramienta,
                    h.nombre_herramienta,
                    SUM(hot.cantidadot) AS cantidadot
                FROM herramientaot hot
                LEFT JOIN herramienta h ON hot.id_ai_herramienta = h.id_ai_herramienta
                WHERE hot.n_ot = :not
                  AND COALESCE(hot.estadoot, 'ASIGNADA') <> 'LIBERADA'
                GROUP BY hot.n_ot, hot.id_ai_herramienta, h.nombre_herramienta
                ORDER BY hot.id_ai_herramienta ASC
            ";
                $stmt = dbQuery($mainModel, $sql, [':not' => $id]);
                $rows = ($stmt) ? $stmt->fetchAll(PDO::FETCH_ASSOC) : [];
                jsonOut($rows);
            }

        case 'her': {
                $campo = $mainModel->limpiarCadena($_GET['campo'] ?? '');
                if ($campo === '') jsonOut([]);

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
                $id    = $mainModel->limpiarCadena($_GET['id'] ?? '');
                if ($id === '') jsonOut([]);

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
                  AND COALESCE(hot.estadoot, 'ASIGNADA') <> 'LIBERADA'
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

/**
 * ============================
 *  ACCIÓN MAS/MENOS (GET)  (mejor sería POST)
 * ============================
 */
requirePerm('perm_ot_add_herramienta');

$tipo      = $mainModel->limpiarCadena($_GET['tipo'] ?? '');
$n_ot      = $mainModel->limpiarCadena($_GET['id'] ?? '');
$codigoHer = $mainModel->limpiarCadena($_GET['codigoHer'] ?? '');

if (!in_array($tipo, ['mas', 'menos'], true) || $n_ot === '' || $codigoHer === '') {
    jsonOut(["error" => "parametros_invalidos"]);
}

/** 1) Stock actual (disponible) */
$sqlStock = "
    SELECT
        id_ai_herramienta,
        cantidad_total AS cantidad,
        cantidad_disponible
    FROM vw_herramienta_disponibilidad
    WHERE id_ai_herramienta = :idher
    LIMIT 1
";
$stmtStock = dbQuery($mainModel, $sqlStock, [':idher' => $codigoHer]);
$stock = ($stmtStock && $stmtStock->rowCount() > 0) ? $stmtStock->fetch(PDO::FETCH_ASSOC) : null;

if (!$stock) {
    jsonOut(["error" => "herramienta_no_encontrada"]);
}

/** 2) Existe vínculo OT-Herramienta? */
$sqlExist = "
    SELECT COALESCE(SUM(cantidadot), 0) AS cantidadot
    FROM herramientaot
    WHERE n_ot = :not AND id_ai_herramienta = :idher
      AND COALESCE(estadoot, 'ASIGNADA') <> 'LIBERADA'
";
$stmtExist = dbQuery($mainModel, $sqlExist, [':not' => $n_ot, ':idher' => $codigoHer]);
$exist = ($stmtExist && $stmtExist->rowCount() > 0) ? $stmtExist->fetch(PDO::FETCH_ASSOC) : null;

$disp = (int)($stock['cantidad_disponible'] ?? 0);

if ($exist && (int)($exist['cantidadot'] ?? 0) > 0) {
    $cantActual = (int)$exist['cantidadot'];

    if ($tipo === 'mas') {
        if ($disp <= 0) jsonOut("nohay");
        try {
            $mainModel->ejecutarProcedimientoFila(
                "CALL sp_ot_asignar_herramienta(:not, :idher, :cant, :id_user_operacion)",
                [
                    ':not' => $n_ot,
                    ':idher' => (int)$codigoHer,
                    ':cant' => 1,
                    ':id_user_operacion' => (string)($_SESSION['id_user'] ?? $_SESSION['id'] ?? ''),
                ]
            );
            jsonOut(["ok" => true]);
        } catch (Throwable $e) {
            if (stripos($e->getMessage(), 'disponibilidad') !== false) {
                jsonOut("nohay");
            }
            jsonOut(["ok" => false, "error" => "asignacion_fallida"]);
        }
    }

    // menos
    if ($cantActual <= 1) {
        $sqlDel = "DELETE FROM herramientaot WHERE n_ot = :not AND id_ai_herramienta = :idher AND COALESCE(estadoot, 'ASIGNADA') <> 'LIBERADA'";
        $stmt = dbQuery($mainModel, $sqlDel, [':not' => $n_ot, ':idher' => $codigoHer]);
        jsonOut(["ok" => (bool)$stmt]);
    }

    dbQuery($mainModel, "DELETE FROM herramientaot WHERE n_ot = :not AND id_ai_herramienta = :idher AND COALESCE(estadoot, 'ASIGNADA') <> 'LIBERADA'", [':not' => $n_ot, ':idher' => $codigoHer]);
    $stmt = dbQuery($mainModel, "INSERT INTO herramientaot (n_ot, id_ai_herramienta, cantidadot, estadoot) VALUES (:not, :idher, :cant, 'ASIGNADA')", [':not' => $n_ot, ':idher' => $codigoHer, ':cant' => ($cantActual - 1)]);
    jsonOut(["ok" => (bool)$stmt]);
}

// No existe vínculo -> insertar si hay disponible
if ($disp <= 0) jsonOut("nohay");

try {
    $mainModel->ejecutarProcedimientoFila(
        "CALL sp_ot_asignar_herramienta(:not, :idher, :cant, :id_user_operacion)",
        [
            ':not' => $n_ot,
            ':idher' => (int)$codigoHer,
            ':cant' => 1,
            ':id_user_operacion' => (string)($_SESSION['id_user'] ?? $_SESSION['id'] ?? ''),
        ]
    );
    jsonOut(["ok" => true]);
} catch (Throwable $e) {
    if (stripos($e->getMessage(), 'disponibilidad') !== false) {
        jsonOut("nohay");
    }
    jsonOut(["ok" => false, "error" => "asignacion_fallida"]);
}

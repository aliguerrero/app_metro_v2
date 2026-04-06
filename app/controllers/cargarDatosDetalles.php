<?php
require_once "../../config/app.php";
require_once "../views/inc/session_start.php";
require_once "../../autoload.php";

use app\models\mainModel;

header('Content-Type: application/json; charset=utf-8');

function requirePerm(string $permKey): void
{
    if (isset($_SESSION['tipo']) && (int)$_SESSION['tipo'] === 1) {
        return;
    }

    $perms = $_SESSION['permisos'] ?? [];
    if (empty($perms[$permKey]) || (int)$perms[$permKey] !== 1) {
        echo json_encode(["ok" => false, "error" => "permiso_denegado"], JSON_UNESCAPED_UNICODE);
        exit();
    }
}

try {
    $mainModel = new mainModel();
    $estadoHerrExpr = $mainModel->herramientaOtEstadoExpr();

    $tipoBusqueda = $mainModel->limpiarCadena($_GET['tipoBusqueda'] ?? '');

    if ($tipoBusqueda !== 'eliminar') {
        requirePerm('perm_ot_view');

        if ($tipoBusqueda === 'cargarTabla') {
            $id = $mainModel->limpiarCadena($_GET['id'] ?? '');

            if ($id === '') {
                echo json_encode(["ok" => false, "error" => "id_invalido"], JSON_UNESCAPED_UNICODE);
                exit();
            }

            $stmt = $mainModel->ejecutarConsultaConParametros(
                "SELECT
                    id_ai_detalle,
                    n_ot,
                    fecha_detalle AS fecha,
                    descripcion,
                    id_user_act,
                    COALESCE(NULLIF(usuario_act_nombre, ''), id_user_act) AS user
                 FROM vw_ot_detallada
                 WHERE n_ot = :not
                 ORDER BY fecha_detalle DESC, id_ai_detalle DESC",
                [':not' => $id]
            );

            $rows = $stmt ? $stmt->fetchAll(\PDO::FETCH_ASSOC) : [];
            echo json_encode(["ok" => true, "data" => $rows], JSON_UNESCAPED_UNICODE);
            exit();
        }

        echo json_encode(["ok" => true, "data" => []], JSON_UNESCAPED_UNICODE);
        exit();
    }

    requirePerm('perm_ot_add_herramienta');

    $tipo = $mainModel->limpiarCadena($_POST['tipo'] ?? ($_GET['tipo'] ?? ''));
    $n_ot = $mainModel->limpiarCadena($_POST['id'] ?? ($_GET['id'] ?? ''));
    $idHerr = $mainModel->limpiarCadena($_POST['codigoHer'] ?? ($_GET['codigoHer'] ?? ''));

    if (!in_array($tipo, ['mas', 'menos'], true) || $n_ot === '' || $idHerr === '' || !ctype_digit($idHerr)) {
        echo json_encode(["ok" => false, "error" => "parametros_invalidos"], JSON_UNESCAPED_UNICODE);
        exit();
    }

    $idHerrInt = (int)$idHerr;
    $idUserOperacion = (string)($_SESSION['id_user'] ?? $_SESSION['id'] ?? '');

    $stmtExist = $mainModel->ejecutarConsultaConParametros(
        "SELECT COALESCE(SUM(cantidadot), 0) AS cantidadot
         FROM herramientaot
         WHERE n_ot = :not
           AND id_ai_herramienta = :id
           AND {$estadoHerrExpr} <> 'LIBERADA'",
        [':not' => $n_ot, ':id' => $idHerrInt]
    );
    $cantActual = ($stmtExist && $stmtExist->rowCount() > 0) ? (int)$stmtExist->fetchColumn() : 0;

    if ($tipo === 'menos' && $cantActual <= 0) {
        echo json_encode(["ok" => true], JSON_UNESCAPED_UNICODE);
        exit();
    }

    $mainModel->ejecutarProcedimientoFila(
        "CALL sp_ot_ajustar_herramienta_delta(:not, :idher, :delta, :id_user_operacion)",
        [
            ':not' => $n_ot,
            ':idher' => $idHerrInt,
            ':delta' => ($tipo === 'mas' ? 1 : -1),
            ':id_user_operacion' => $idUserOperacion,
        ]
    );

    echo json_encode(["ok" => true], JSON_UNESCAPED_UNICODE);
    exit();
} catch (\Throwable $e) {
    $msg = $e->getMessage();
    if (stripos($msg, 'disponibilidad') !== false) {
        echo json_encode(["ok" => false, "error" => "nohay"], JSON_UNESCAPED_UNICODE);
        exit();
    }
    if (stripos($msg, 'bloqueada') !== false) {
        echo json_encode(["ok" => false, "error" => "ot_bloqueada"], JSON_UNESCAPED_UNICODE);
        exit();
    }
    echo json_encode(["ok" => false, "error" => "error_interno", "detail" => $msg], JSON_UNESCAPED_UNICODE);
    exit();
}

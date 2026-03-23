<?php
require_once "../../config/app.php";
require_once "../views/inc/session_start.php";
require_once "../../autoload.php";

use app\models\mainModel;

header('Content-Type: application/json; charset=utf-8');

function requirePerm(string $permKey): void
{
    // bypass admin (tu ROOT tiene tipo=1)
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
    $detalleCols = $mainModel->columnasTablaSql('detalle_orden', 'd');

    $tipoBusqueda = $mainModel->limpiarCadena($_GET['tipoBusqueda'] ?? '');

    // =========================
    //  DETALLE OT (cargarTabla)
    // =========================
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

    // ===============================
    //  AJUSTES HERRAMIENTA EN OT
    // ===============================
    requirePerm('perm_ot_add_herramienta');

    // Ideal: POST. Fallback a GET por compatibilidad.
    $tipo        = $mainModel->limpiarCadena($_POST['tipo']        ?? ($_GET['tipo'] ?? ''));          // mas|menos
    $n_ot        = $mainModel->limpiarCadena($_POST['id']          ?? ($_GET['id'] ?? ''));            // n_ot
    $idHerr      = $mainModel->limpiarCadena($_POST['codigoHer']   ?? ($_GET['codigoHer'] ?? ''));     // id_ai_herramienta

    if (!in_array($tipo, ['mas', 'menos'], true) || $n_ot === '' || $idHerr === '' || !ctype_digit($idHerr)) {
        echo json_encode(["ok" => false, "error" => "parametros_invalidos"], JSON_UNESCAPED_UNICODE);
        exit();
    }

    $idHerr = (int)$idHerr;

    // ✅ transacción para evitar asignaciones simultáneas del mismo stock
    $mainModel->beginTransaction();

    // 1) Lock de la herramienta (serializa operaciones por herramienta)
    $stmtTool = $mainModel->ejecutarConsultaConParametros(
        "SELECT cantidad
         FROM herramienta
         WHERE std_reg = 1 AND id_ai_herramienta = :id
         FOR UPDATE",
        [':id' => $idHerr]
    );

    if (!$stmtTool || $stmtTool->rowCount() === 0) {
        $mainModel->rollBack();
        echo json_encode(["ok" => false, "error" => "herramienta_no_encontrada"], JSON_UNESCAPED_UNICODE);
        exit();
    }

    $cantidadTotal = (int)$stmtTool->fetchColumn();

    // 2) Ocupación total (lock de filas de herramientaot de esa herramienta)
    $stmtOcc = $mainModel->ejecutarConsultaConParametros(
        "SELECT COALESCE(SUM(cantidadot),0) AS ocupada
         FROM herramientaot
         WHERE id_ai_herramienta = :id
         FOR UPDATE",
        [':id' => $idHerr]
    );
    $ocupada = (int)($stmtOcc ? $stmtOcc->fetchColumn() : 0);
    $disponible = $cantidadTotal - $ocupada;

    // 3) Lock del vínculo OT-herramienta
    $stmtExist = $mainModel->ejecutarConsultaConParametros(
        "SELECT id_ai_herramientaOT, cantidadot
         FROM herramientaot
         WHERE n_ot = :not AND id_ai_herramienta = :id
         LIMIT 1
         FOR UPDATE",
        [':not' => $n_ot, ':id' => $idHerr]
    );
    $exist = ($stmtExist && $stmtExist->rowCount() > 0) ? $stmtExist->fetch(\PDO::FETCH_ASSOC) : null;

    if ($tipo === 'mas') {

        if ($disponible <= 0) {
            $mainModel->rollBack();
            echo json_encode(["ok" => false, "error" => "nohay", "disponible" => 0], JSON_UNESCAPED_UNICODE);
            exit();
        }

        if ($exist) {
            $mainModel->ejecutarConsultaConParametros(
                "UPDATE herramientaot
                 SET cantidadot = cantidadot + 1
                 WHERE n_ot = :not AND id_ai_herramienta = :id",
                [':not' => $n_ot, ':id' => $idHerr]
            );
        } else {
            $mainModel->ejecutarConsultaConParametros(
                "INSERT INTO herramientaot (id_ai_herramienta, n_ot, cantidadot, estadoot)
                 VALUES (:id, :not, 1, 'ASIGNADA')",
                [':id' => $idHerr, ':not' => $n_ot]
            );
        }

        $mainModel->commit();
        echo json_encode(["ok" => true], JSON_UNESCAPED_UNICODE);
        exit();
    }

    // tipo === 'menos'
    if (!$exist) {
        $mainModel->rollBack();
        echo json_encode(["ok" => true], JSON_UNESCAPED_UNICODE); // nada que bajar
        exit();
    }

    $cantActual = (int)$exist['cantidadot'];

    if ($cantActual <= 1) {
        $mainModel->ejecutarConsultaConParametros(
            "DELETE FROM herramientaot
             WHERE n_ot = :not AND id_ai_herramienta = :id",
            [':not' => $n_ot, ':id' => $idHerr]
        );
    } else {
        $mainModel->ejecutarConsultaConParametros(
            "UPDATE herramientaot
             SET cantidadot = cantidadot - 1
             WHERE n_ot = :not AND id_ai_herramienta = :id",
            [':not' => $n_ot, ':id' => $idHerr]
        );
    }

    $mainModel->commit();
    echo json_encode(["ok" => true], JSON_UNESCAPED_UNICODE);
    exit();
} catch (\Throwable $e) {
    if (isset($mainModel) && method_exists($mainModel, 'inTransaction') && $mainModel->inTransaction()) {
        $mainModel->rollBack();
    }
    echo json_encode(["ok" => false, "error" => "error_interno", "detail" => $e->getMessage()], JSON_UNESCAPED_UNICODE);
    exit();
}

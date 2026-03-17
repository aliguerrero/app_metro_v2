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
        echo json_encode([
            "ok" => false,
            "tipo" => "simple",
            "titulo" => "Acceso denegado",
            "texto" => "No tienes permisos para realizar esta acción",
            "icono" => "error"
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }
}

try {
    $idUser = $_SESSION['id_user'] ?? ($_SESSION['id'] ?? null);
    if (empty($idUser)) {
        echo json_encode([
            "ok" => false,
            "tipo" => "simple",
            "titulo" => "No autenticado",
            "texto" => "Debe iniciar sesión",
            "icono" => "error"
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    $mainModel = new mainModel();
    $tipoBusqueda = $mainModel->limpiarCadena($_GET['tipoBusqueda'] ?? 'todo');

    // =========================
    // LISTAR / BUSCAR
    // =========================
    if ($tipoBusqueda !== 'eliminar') {

        requirePerm('perm_miembro_view');

        if ($tipoBusqueda === 'id') {
            $id = $mainModel->limpiarCadena($_GET['id'] ?? '');
            $q  = '%' . $id . '%';

            // ✅ NO repetir el mismo marcador :q (evita HY093)
            $sql = "SELECT id_miembro, nombre_miembro, tipo_miembro
                    FROM miembro
                    WHERE std_reg = 1
                      AND (id_miembro LIKE :q1 OR nombre_miembro LIKE :q2)
                    ORDER BY id_miembro ASC";

            // OJO: si tu helper NO quiere ":" en las keys, cambia a ["q1"=>$q,"q2"=>$q]
            $stmt = $mainModel->ejecutarConsultaConParametros($sql, [":q1" => $q, ":q2" => $q]);
        } else {
            $sql = "SELECT id_miembro, nombre_miembro, tipo_miembro
                    FROM miembro
                    WHERE std_reg = 1
                    ORDER BY id_miembro ASC";

            $stmt = $mainModel->ejecutarConsultaConParametros($sql, []);
        }

        $rows = $stmt ? $stmt->fetchAll(\PDO::FETCH_ASSOC) : [];

        echo json_encode([
            "ok"    => true,
            "data"  => $rows,
            "total" => count($rows)
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    // =========================
    // ELIMINAR (SOFT DELETE)
    // =========================
    requirePerm('perm_miembro_delete');

    // ✅ preferir POST, pero aceptamos GET si viene así
    $id = $mainModel->limpiarCadena($_POST['id'] ?? ($_GET['id'] ?? ''));

    if ($id === '') {
        echo json_encode([
            "ok" => false,
            "tipo" => "simple",
            "titulo" => "Error",
            "texto" => "ID inválido",
            "icono" => "error"
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    $mainModel->setAppUser((string)$idUser);

    // verificar existencia
    $sqlCheck = "SELECT id_miembro, std_reg
                 FROM miembro
                 WHERE id_miembro = :id
                 LIMIT 1";

    // OJO: si tu helper NO quiere ":" en keys, usa ["id"=>$id]
    $check = $mainModel->ejecutarConsultaConParametros($sqlCheck, [":id" => $id]);

    if (!$check || $check->rowCount() === 0) {
        echo json_encode([
            "ok" => false,
            "tipo" => "simple",
            "titulo" => "No encontrado",
            "texto" => "No hemos encontrado el miembro en el sistema",
            "icono" => "error"
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    $row = $check->fetch(\PDO::FETCH_ASSOC);
    if ((int)$row['std_reg'] === 0) {
        echo json_encode([
            "ok" => true,
            "tipo" => "simple",
            "titulo" => "Sin cambios",
            "texto" => "El miembro ya está inactivo",
            "icono" => "info"
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    // ✅ UPDATE directo (evita problemas internos de ejecutarSqlUpdate)
    $sqlUpd = "UPDATE miembro
               SET std_reg = 0
               WHERE id_miembro = :id";

    $updStmt = $mainModel->ejecutarConsultaConParametros($sqlUpd, [":id" => $id]);
    $ok = (bool)$updStmt && $updStmt->rowCount() > 0;

    echo json_encode([
        "ok" => $ok,
        "tipo" => $ok ? "recargar" : "simple",
        "titulo" => $ok ? "Miembro Eliminado" : "Error",
        "texto" => $ok ? "El miembro fue inactivado (baja lógica) con éxito" : "No se pudo eliminar el miembro",
        "icono" => $ok ? "success" : "error"
    ], JSON_UNESCAPED_UNICODE);
    exit();
} catch (\Throwable $e) {
    echo json_encode([
        "ok" => false,
        "tipo" => "simple",
        "titulo" => "Error interno",
        "texto" => "Ocurrió un error inesperado",
        "detail" => $e->getMessage(),
        "icono" => "error"
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

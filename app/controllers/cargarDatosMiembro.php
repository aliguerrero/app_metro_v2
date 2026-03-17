<?php
require_once "../../config/app.php";
require_once "../views/inc/session_start.php";
require_once "../../autoload.php";

use app\models\mainModel;

/**
 * Requiere permiso de visualizar miembros
 */
function requirePerm(string $permKey): void
{
    $perms = $_SESSION['permisos'] ?? [];
    if (empty($perms[$permKey]) || (int)$perms[$permKey] !== 1) {
        echo json_encode(["error" => "permiso_denegado"], JSON_UNESCAPED_UNICODE);
        exit();
    }
}

requirePerm('perm_miembro_view');

$mainModel = new mainModel();
$id = $mainModel->limpiarCadena($_POST['id'] ?? '');

$stmt = $mainModel->ejecutarConsultaConParametros(
    "SELECT " . $mainModel->columnasTablaSql('miembro') . " FROM miembro WHERE id_miembro = :id AND std_reg = 1 LIMIT 1",
    [':id' => $id]
);

$tdatos = [];
if ($stmt && $stmt->rowCount() > 0) {
    $tdatos = $stmt->fetch(\PDO::FETCH_ASSOC);
}

echo json_encode($tdatos, JSON_UNESCAPED_UNICODE);

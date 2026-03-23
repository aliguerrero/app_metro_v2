<?php
require_once "../../config/app.php";
require_once "../views/inc/session_start.php";
require_once "../../autoload.php";

use app\models\mainModel;

function requirePerm(string $permKey): void
{
    $perms = $_SESSION['permisos'] ?? [];
    if (empty($perms[$permKey]) || (int)$perms[$permKey] !== 1) {
        echo json_encode(["error" => "permiso_denegado"]);
        exit();
    }
}

requirePerm('perm_ot_view');

$mainModel = new mainModel();
$id = $mainModel->limpiarCadena($_POST['id'] ?? '');

$stmt = $mainModel->ejecutarConsultaConParametros(
    "SELECT *,
            CASE
              WHEN COALESCE(ot_finalizada, 0) = 1 OR COALESCE(bloquea_ot, 0) = 1 THEN 1
              ELSE 0
            END AS ot_finalizada
     FROM vw_ot_resumen
     WHERE n_ot = :id
       AND std_reg = 1
     LIMIT 1",
    [':id' => $id]
);

$tdatos = [];
if ($stmt && $stmt->rowCount() > 0) {
    $tdatos = $stmt->fetch(PDO::FETCH_ASSOC);
}

echo json_encode($tdatos, JSON_UNESCAPED_UNICODE);

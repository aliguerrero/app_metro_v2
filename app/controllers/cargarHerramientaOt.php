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

$stmt = $mainModel->ejecutarConsultaConParametros(
    "SELECT
        hot.id_ai_herramientaOT,
        hot.n_ot,
        h.nombre_herramienta,
        hot.cantidadot
     FROM herramientaot hot
     LEFT JOIN herramienta h ON hot.id_ai_herramienta = h.id_ai_herramienta
     ORDER BY hot.id_ai_herramientaOT",
    []
);

$tdatos = [];
if ($stmt) {
    $tdatos = $stmt->fetchAll(PDO::FETCH_ASSOC);
}

echo json_encode($tdatos, JSON_UNESCAPED_UNICODE);

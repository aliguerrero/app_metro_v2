<?php
require_once "../../config/app.php";
require_once "../views/inc/session_start.php";
require_once "../../autoload.php";

use app\models\mainModel;

function requirePerm(string $permKey): void
{
    $perms = $_SESSION['permisos'] ?? [];
    if (empty($perms[$permKey]) || (int)$perms[$permKey] !== 1) {
        echo json_encode(["error" => "permiso_denegado"], JSON_UNESCAPED_UNICODE);
        exit();
    }
}

requirePerm('perm_herramienta_view');

$mainModel = new mainModel();
$id = $mainModel->limpiarCadena($_POST['id'] ?? '');

$stmt = $mainModel->ejecutarConsultaConParametros(
    "SELECT
        h.id_ai_herramienta,
        h.nombre_herramienta,
        h.id_ai_categoria_herramienta,
        COALESCE(ch.nombre_categoria, 'SIN CATEGORIA') AS nombre_categoria,
        h.cantidad,
        h.estado,
        h.std_reg
     FROM herramienta h
     LEFT JOIN categoria_herramienta ch
       ON ch.id_ai_categoria_herramienta = h.id_ai_categoria_herramienta
     WHERE h.id_ai_herramienta = :id
       AND h.std_reg = 1
     LIMIT 1",
    [':id' => $id]
);

$tdatos = [];
if ($stmt && $stmt->rowCount() > 0) {
    $tdatos = $stmt->fetch(\PDO::FETCH_ASSOC);
}

echo json_encode($tdatos, JSON_UNESCAPED_UNICODE);

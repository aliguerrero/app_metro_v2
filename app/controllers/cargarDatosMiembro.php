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

requirePerm('perm_miembro_view');

$mainModel = new mainModel();
$id = $mainModel->limpiarCadena($_POST['id'] ?? '');

$stmt = $mainModel->ejecutarConsultaConParametros(
    "SELECT
        m.id_miembro,
        m.id_empleado,
        m.nombre_miembro,
        m.tipo_miembro,
        m.std_reg,
        e.nacionalidad,
        e.nombre_empleado,
        COALESCE(NULLIF(e.telefono, ''), '') AS telefono_empleado,
        COALESCE(NULLIF(e.correo, ''), '') AS correo_empleado,
        CASE
            WHEN e.id_empleado IS NOT NULL AND TRIM(e.id_empleado) <> ''
                THEN CONCAT(COALESCE(NULLIF(e.nacionalidad, ''), ''), IF(COALESCE(NULLIF(e.nacionalidad, ''), '') = '', '', '-'), e.id_empleado)
            ELSE 'No vinculado'
        END AS documento_empleado,
        CASE
            WHEN e.nombre_empleado IS NOT NULL AND TRIM(e.nombre_empleado) <> ''
                THEN e.nombre_empleado
            ELSE m.nombre_miembro
        END AS nombre_visual
     FROM miembro m
     LEFT JOIN empleado e
       ON e.id_empleado = m.id_empleado
     WHERE m.id_miembro = :id
       AND m.std_reg = 1
     LIMIT 1",
    [':id' => $id]
);

$tdatos = [];
if ($stmt && $stmt->rowCount() > 0) {
    $tdatos = $stmt->fetch(\PDO::FETCH_ASSOC);
}

echo json_encode($tdatos, JSON_UNESCAPED_UNICODE);

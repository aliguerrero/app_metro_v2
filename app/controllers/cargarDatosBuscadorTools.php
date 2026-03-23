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

$mainModel = new mainModel();

$tipoBusqueda = $mainModel->limpiarCadena($_GET['tipoBusqueda'] ?? 'todo');

if ($tipoBusqueda !== 'eliminar') {

    requirePerm('perm_herramienta_view');

    if ($tipoBusqueda === 'id') {
        $term = $mainModel->limpiarCadena($_GET['id'] ?? '');
        $like = "%" . $term . "%";

        $consulta = "
            SELECT
                id_ai_herramienta,
                nombre_herramienta,
                id_ai_categoria_herramienta,
                COALESCE(nombre_categoria, 'SIN CATEGORIA') AS nombre_categoria,
                cantidad_total AS cantidad,
                estado,
                std_reg,
                cantidad_disponible,
                cantidad_ocupada AS herramienta_ocupada
            FROM vw_herramienta_disponibilidad
            WHERE std_reg = 1
              AND (
                    CAST(id_ai_herramienta AS CHAR) LIKE :term1
                    OR nombre_herramienta LIKE :term2
                    OR COALESCE(nombre_categoria, '') LIKE :term3
              )
            ORDER BY id_ai_herramienta ASC
        ";

        $stmt = $mainModel->ejecutarConsultaConParametros($consulta, [
            'term1' => $like,
            'term2' => $like,
            'term3' => $like
        ]);
    } else {

        $consulta = "
            SELECT
                id_ai_herramienta,
                nombre_herramienta,
                id_ai_categoria_herramienta,
                COALESCE(nombre_categoria, 'SIN CATEGORIA') AS nombre_categoria,
                cantidad_total AS cantidad,
                estado,
                std_reg,
                cantidad_disponible,
                cantidad_ocupada AS herramienta_ocupada
            FROM vw_herramienta_disponibilidad
            WHERE std_reg = 1
            ORDER BY id_ai_herramienta ASC
        ";

        $stmt = $mainModel->ejecutarConsultaConParametros($consulta, []);
    }

    $tdatos = [];
    if ($stmt && $stmt->rowCount() > 0) {
        $tdatos = $stmt->fetchAll(\PDO::FETCH_ASSOC);
    }

    echo json_encode($tdatos, JSON_UNESCAPED_UNICODE);
    exit();
} else {

    // eliminar (compatibilidad con tu JS, pero con permisos)
    requirePerm('perm_herramienta_delete');

    $id = $mainModel->limpiarCadena($_GET['id'] ?? '');

    $datos_reg = [
        ["campo_nombre" => "std_reg", "campo_marcador" => ":std_reg",  "campo_valor" => 0],
    ];

    $condicion = [
        "condicion_campo"    => "id_ai_herramienta",
        "condicion_marcador" => ":id_ai_herramienta",
        "condicion_valor"    => $id
    ];

    $ok = $mainModel->ejecutarSqlUpdate("herramienta", $datos_reg, $condicion) ? true : false;
    echo json_encode($ok, JSON_UNESCAPED_UNICODE);
    exit();
}

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
                h.id_ai_herramienta,
                h.nombre_herramienta,
                h.id_ai_categoria_herramienta,
                COALESCE(ch.nombre_categoria, 'SIN CATEGORIA') AS nombre_categoria,
                h.cantidad,
                h.estado,
                h.std_reg,
                (h.cantidad - COALESCE(SUM(hot.cantidadot), 0)) AS cantidad_disponible,
                COALESCE(SUM(hot.cantidadot), 0) AS herramienta_ocupada
            FROM herramienta h
            LEFT JOIN categoria_herramienta ch
              ON ch.id_ai_categoria_herramienta = h.id_ai_categoria_herramienta
            LEFT JOIN herramientaot hot
              ON h.id_ai_herramienta = hot.id_ai_herramienta
            WHERE h.std_reg = 1
              AND (
                    CAST(h.id_ai_herramienta AS CHAR) LIKE :term1
                    OR h.nombre_herramienta LIKE :term2
                    OR COALESCE(ch.nombre_categoria, '') LIKE :term3
              )
            GROUP BY
                h.id_ai_herramienta,
                h.nombre_herramienta,
                h.id_ai_categoria_herramienta,
                ch.nombre_categoria,
                h.cantidad,
                h.estado,
                h.std_reg
            ORDER BY h.id_ai_herramienta ASC
        ";

        $stmt = $mainModel->ejecutarConsultaConParametros($consulta, [
            'term1' => $like,
            'term2' => $like,
            'term3' => $like
        ]);
    } else {

        $consulta = "
            SELECT
                h.id_ai_herramienta,
                h.nombre_herramienta,
                h.id_ai_categoria_herramienta,
                COALESCE(ch.nombre_categoria, 'SIN CATEGORIA') AS nombre_categoria,
                h.cantidad,
                h.estado,
                h.std_reg,
                (h.cantidad - COALESCE(SUM(hot.cantidadot), 0)) AS cantidad_disponible,
                COALESCE(SUM(hot.cantidadot), 0) AS herramienta_ocupada
            FROM herramienta h
            LEFT JOIN categoria_herramienta ch
              ON ch.id_ai_categoria_herramienta = h.id_ai_categoria_herramienta
            LEFT JOIN herramientaot hot
              ON h.id_ai_herramienta = hot.id_ai_herramienta
            WHERE h.std_reg = 1
            GROUP BY
                h.id_ai_herramienta,
                h.nombre_herramienta,
                h.id_ai_categoria_herramienta,
                ch.nombre_categoria,
                h.cantidad,
                h.estado,
                h.std_reg
            ORDER BY h.id_ai_herramienta ASC
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

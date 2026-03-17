<?php
// app/controllers/cargarFiltrosReporte.php

require_once "../../config/app.php";
require_once "../views/inc/session_start.php";
require_once "../../autoload.php";

use app\models\mainModel;

header('Content-Type: application/json; charset=utf-8');

$mm = new mainModel();

function q(mainModel $mm, string $sql, array $params = [])
{
    if (method_exists($mm, 'ejecutarConsultaConParametros')) {
        return $mm->ejecutarConsultaConParametros($sql, $params);
    }
    if (method_exists($mm, 'ejecutarConsultaParams')) {
        return $mm->ejecutarConsultaConParametros($sql, $params);
    }
    // Ãºltimo recurso (NO recomendado)
    return $mm->ejecutarConsultas($sql);
}

function columnExists(mainModel $mm, string $table, string $column): bool
{
    $sql = "SELECT COUNT(1) FROM INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_SCHEMA = DATABASE()
              AND TABLE_NAME = :t
              AND COLUMN_NAME = :c";

    $st = $mm->ejecutarConsultaConParametros($sql, [':t' => $table, ':c' => $column]);
    return $st && (int)$st->fetchColumn() > 0;
}

function pickColumn(mainModel $mm, string $table, array $candidates, string $fallback): string
{
    static $cache = [];
    $key = $table . '|' . implode(',', $candidates);

    if (isset($cache[$key])) {
        return $cache[$key];
    }

    foreach ($candidates as $column) {
        if (columnExists($mm, $table, $column)) {
            return $cache[$key] = $column;
        }
    }

    return $cache[$key] = $fallback;
}

try {
    $areaCol = pickColumn($mm, 'area_trabajo', ['id_ai_area', 'id_area'], 'id_ai_area');
    $sitioCol = pickColumn($mm, 'sitio_trabajo', ['id_ai_sitio', 'id_sitio'], 'id_ai_sitio');
    $estadoCol = pickColumn($mm, 'estado_ot', ['id_ai_estado', 'id_estado'], 'id_ai_estado');

    $areas = q($mm, "SELECT {$areaCol} AS id_area, {$areaCol} AS id_ai_area, nombre_area FROM area_trabajo WHERE std_reg = 1 ORDER BY nombre_area ASC");
    $sitios = q($mm, "SELECT {$sitioCol} AS id_sitio, {$sitioCol} AS id_ai_sitio, nombre_sitio FROM sitio_trabajo WHERE std_reg = 1 ORDER BY nombre_sitio ASC");
    $estados = q($mm, "SELECT {$estadoCol} AS id_estado, {$estadoCol} AS id_ai_estado, nombre_estado, color FROM estado_ot WHERE std_reg = 1 ORDER BY {$estadoCol} ASC");
    $usuarios = q(
        $mm,
        "SELECT
            u.id_empleado AS id_user,
            COALESCE(NULLIF(e.nombre_empleado, ''), u.id_empleado) AS user,
            u.username
         FROM user_system u
         LEFT JOIN empleado e
           ON e.id_empleado = u.id_empleado
         WHERE u.std_reg = 1
         ORDER BY COALESCE(NULLIF(e.nombre_empleado, ''), u.id_empleado) ASC"
    );

    echo json_encode([
        'ok' => true,
        'areas' => $areas ? $areas->fetchAll(PDO::FETCH_ASSOC) : [],
        'sitios' => $sitios ? $sitios->fetchAll(PDO::FETCH_ASSOC) : [],
        'estados' => $estados ? $estados->fetchAll(PDO::FETCH_ASSOC) : [],
        'usuarios' => $usuarios ? $usuarios->fetchAll(PDO::FETCH_ASSOC) : [],
    ]);
} catch (Exception $e) {
    error_log('[cargarFiltrosReporte] ' . $e->getMessage());
    error_log($e->getTraceAsString());
    echo json_encode(['ok' => false, 'msg' => 'Error cargando filtros']);
}


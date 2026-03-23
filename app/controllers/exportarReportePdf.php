<?php
// app/controllers/exportarReportePdf.php

require_once "../../config/app.php";
require_once "../views/inc/session_start.php";
require_once "../../autoload.php";

// DOMPDF local
require_once __DIR__ . "/../lib/dompdf/autoload.inc.php";

use app\models\mainModel;
use app\controllers\reporteGeneradoController;
use Dompdf\Dompdf;
use Dompdf\Options;

$mm = new mainModel();

function hasPerm(string $key): bool
{
    return isset($_SESSION['permisos'][$key]) && (int)$_SESSION['permisos'][$key] === 1;
}

function q(mainModel $mm, string $sql, array $params = [])
{
    if (method_exists($mm, 'ejecutarConsultaConParametros')) return $mm->ejecutarConsultaConParametros($sql, $params);
    if (method_exists($mm, 'ejecutarConsultaParams')) return $mm->ejecutarConsultaConParametros($sql, $params);
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

function getEmpresa(mainModel $mm): array
{
    try {
        $st = q($mm, "SELECT " . $mm->columnasTablaSql('empresa_config') . " FROM empresa_config WHERE id = 1 LIMIT 1");
        if ($st && $st->rowCount() === 1) return $st->fetch(PDO::FETCH_ASSOC);
    } catch (Exception $e) {
    }
    return [
        'nombre' => 'Empresa',
        'rif' => '',
        'direccion' => '',
        'telefono' => '',
        'email' => '',
        'logo' => 'app/views/img/logo.png'
    ];
}

function normalizeLogoPath(string $logoPath): string
{
    $path = trim($logoPath);
    if ($path === '') {
        return '';
    }

    if (preg_match('#^https?://#i', $path)) {
        $urlPath = (string)parse_url($path, PHP_URL_PATH);
        if ($urlPath !== '') {
            $path = $urlPath;
        }
    }

    $path = str_replace('\\', '/', $path);
    $path = ltrim($path, '/');

    $basePath = trim((string)parse_url(APP_URL, PHP_URL_PATH), '/');
    if ($basePath !== '' && strpos($path, $basePath . '/') === 0) {
        $path = substr($path, strlen($basePath) + 1);
    }

    return $path;
}

function resolveLogoAbsolutePath(string $logoPath): string
{
    $path = trim($logoPath);
    $defaultRel = 'app/views/img/logo.png';

    if ($path === '') {
        $path = $defaultRel;
    }

    if (preg_match('#^[a-zA-Z]:[\\\\/]#', $path)) {
        return is_file($path) ? $path : '';
    }

    if (strpos($path, '/') === 0 && is_file($path)) {
        return $path;
    }

    $path = normalizeLogoPath($path);
    if ($path === '') {
        $path = $defaultRel;
    }

    $root = realpath(APP_ROOT);
    if ($root === false) {
        return '';
    }

    $abs = $root . DIRECTORY_SEPARATOR . str_replace('/', DIRECTORY_SEPARATOR, $path);
    if (is_file($abs)) {
        return $abs;
    }

    $fallback = $root . DIRECTORY_SEPARATOR . str_replace('/', DIRECTORY_SEPARATOR, $defaultRel);
    return is_file($fallback) ? $fallback : '';
}

function imgToDataUri(string $absPath): string
{
    if ($absPath === '' || !is_file($absPath)) {
        return '';
    }

    $ext = strtolower(pathinfo($absPath, PATHINFO_EXTENSION));
    $mime = 'image/png';
    if ($ext === 'jpg' || $ext === 'jpeg') $mime = 'image/jpeg';
    if ($ext === 'gif') $mime = 'image/gif';
    if ($ext === 'webp') $mime = 'image/webp';

    $raw = @file_get_contents($absPath);
    if ($raw === false) {
        return '';
    }

    $data = base64_encode($raw);
    return "data:{$mime};base64,{$data}";
}

function cssBase(string $papel, string $orientacion): string
{
    $papel = strtoupper($papel ?: 'A4');
    $orientacion = ($orientacion === 'landscape') ? 'landscape' : 'portrait';
    return "
    <style>
      @page { size: {$papel} {$orientacion}; margin: 24px 26px; }
      html, body { margin:0; padding:0; }
      body { font-family: DejaVu Sans, Arial, Helvetica, sans-serif; font-size: 11px; line-height:1.45; color:#111; }
      body.report-ot-detallado { font-size:10.5px; }
      .sheet { padding: 10px 14px 8px 10px; }
      .wrap { padding: 12px 0; }
      .muted { color:#666; }
      .header { display:flex; align-items:center; justify-content:space-between; gap:12px; border-bottom:1px solid #ddd; padding-bottom:12px; margin-bottom:18px; }
      .brand { display:flex; align-items:center; gap:12px; }
      .brand img { width: 56px; height: 56px; object-fit: contain; }
      .title { font-size: 16px; font-weight: 700; margin:0; }
      .sub { margin:2px 0 0 0; font-size: 12px; }
      table { width:100%; border-collapse:collapse; margin-top:12px; table-layout:fixed; }
      th, td { border:1px solid #ddd; padding:7px 8px; vertical-align:top; word-wrap:break-word; }
      body.report-ot-detallado th, body.report-ot-detallado td { padding:5px; }
      th { background:#f3f5f7; text-align:left; } .badge { display:inline-block; padding:3px 8px; border-radius:999px; background:#eee; font-size:11px; }
      .grid2 { display:grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap:10px; } .card { border:1px solid #ddd; border-radius:8px; padding:10px; } .h6 { font-size: 13px; font-weight: 700; margin:0 0 6px 0; } body.report-ot-detallado .h6 { font-size:12px; }
    </style>
    ";
}


function headerHtmlPdf(array $empresa, string $titulo, bool $membrete, bool $logo): string
{
    $empresaNombre = htmlspecialchars($empresa['nombre'] ?? 'Empresa');
    $rif = htmlspecialchars($empresa['rif'] ?? '');
    $dir = htmlspecialchars($empresa['direccion'] ?? '');
    $tel = htmlspecialchars($empresa['telefono'] ?? '');
    $email = htmlspecialchars($empresa['email'] ?? '');

    $logoTag = '';
    if ($logo) {
        $abs = resolveLogoAbsolutePath($empresa['logo'] ?? '');
        if ($abs) {
            $src = imgToDataUri($abs);
            $logoTag = "<img src=\"{$src}\" alt=\"logo\">";
        }
    }

    if (!$membrete) {
        return "<div class='wrap'><div class='title'>{$titulo}</div></div>";
    }

    return "
      <div class='header'>
        <div class='brand'>
          {$logoTag}
          <div>
            <p class='title'>{$empresaNombre}</p>
            <p class='sub muted'>
              " . ($rif ? "RIF: {$rif} &nbsp;|&nbsp; " : "") . "
              " . ($tel ? "Tel: {$tel} &nbsp;|&nbsp; " : "") . "
              " . ($email ? "{$email}" : "") . "
              " . ($dir ? "<br>{$dir}" : "") . "
            </p>
          </div>
        </div>
        <div style='text-align:right;'>
          <div class='badge'>" . date('d/m/Y H:i') . "</div>
          <div style='margin-top:6px;font-weight:700;'>" . htmlspecialchars($titulo) . "</div>
        </div>
      </div>
    ";
}

function renderTable(string $titulo, array $cols, array $rows): string
{
    $th = '';
    foreach ($cols as $c) $th .= '<th>' . htmlspecialchars($c) . '</th>';

    $tb = '';
    if (count($rows) === 0) {
        $tb = '<tr><td colspan="' . count($cols) . '" class="muted">Sin resultados</td></tr>';
    } else {
        foreach ($rows as $r) {
            $tb .= '<tr>';
            foreach ($r as $cell) $tb .= '<td>' . $cell . '</td>';
            $tb .= '</tr>';
        }
    }

    return "
      <div class='wrap'>
        <div class='h6'>" . htmlspecialchars($titulo) . "</div>
        <table>
          <thead><tr>{$th}</tr></thead>
          <tbody>{$tb}</tbody>
        </table>
      </div>
    ";
}

function buildWhereOT(array $f, array &$params, string $otAreaCol, string $otSitioCol, string $otEstadoCol): string
{
    $w = " WHERE ot.std_reg = 1 ";

    if (!empty($f['n_ot'])) {
        $w .= " AND ot.n_ot = :n_ot ";
        $params[':n_ot'] = $f['n_ot'];
    }
    if (!empty($f['desde'])) {
        $w .= " AND ot.fecha >= :desde ";
        $params[':desde'] = $f['desde'];
    }
    if (!empty($f['hasta'])) {
        $w .= " AND ot.fecha <= :hasta ";
        $params[':hasta'] = $f['hasta'];
    }
    if (!empty($f['area'])) {
        $w .= " AND ot.{$otAreaCol} = :area ";
        $params[':area'] = $f['area'];
    }
    if (!empty($f['sitio'])) {
        $w .= " AND ot.{$otSitioCol} = :sitio ";
        $params[':sitio'] = $f['sitio'];
    }

    if (!empty($f['estado'])) {
        $w .= " AND ot.{$otEstadoCol} = :estado ";
        $params[':estado'] = $f['estado'];
    }
    if (!empty($f['usuario'])) {
        $w .= " AND EXISTS (SELECT 1 FROM vw_ot_detallada d2 WHERE d2.n_ot = ot.n_ot AND d2.id_user_act = :usuario) ";
        $params[':usuario'] = $f['usuario'];
    }
    return $w;
}

// =======================
// Parametros del request
// =======================
$tipo = $mm->limpiarCadena($_GET['tipo'] ?? '');
$papel = $mm->limpiarCadena($_GET['papel'] ?? 'A4');
$orientacionParam = $mm->limpiarCadena($_GET['orientacion'] ?? ''); $orientacion = $orientacionParam !== '' ? $orientacionParam : (($tipo === 'ot_detallado') ? 'landscape' : 'portrait');
$membrete = (int)($mm->limpiarCadena($_GET['membrete'] ?? '1')) === 1;
$logo = (int)($mm->limpiarCadena($_GET['logo'] ?? '1')) === 1;

$f = [
    'n_ot' => $mm->limpiarCadena($_GET['n_ot'] ?? ''),
    'desde' => $mm->limpiarCadena($_GET['desde'] ?? ''),
    'hasta' => $mm->limpiarCadena($_GET['hasta'] ?? ''),
    'area' => $mm->limpiarCadena($_GET['area'] ?? ''),
    'sitio' => $mm->limpiarCadena($_GET['sitio'] ?? ''),
    'estado' => $mm->limpiarCadena($_GET['estado'] ?? ''),
    'usuario' => $mm->limpiarCadena($_GET['usuario'] ?? ''),
    'q' => $mm->limpiarCadena($_GET['q'] ?? ''),
];

    $areaCol = pickColumn($mm, 'area_trabajo', ['id_ai_area', 'id_area'], 'id_ai_area');
    $sitioCol = pickColumn($mm, 'sitio_trabajo', ['id_ai_sitio', 'id_sitio'], 'id_ai_sitio');
    $estadoCol = pickColumn($mm, 'estado_ot', ['id_ai_estado', 'id_estado'], 'id_ai_estado');
    $otEstadoCol = pickColumn($mm, 'orden_trabajo', ['id_ai_estado', 'id_estado'], $estadoCol);
    $turnoCol = pickColumn($mm, 'turno_trabajo', ['id_ai_turno', 'id_turno'], 'id_ai_turno');
    $detalleTurnoCol = pickColumn($mm, 'detalle_orden', ['id_ai_turno', 'id_turno'], $turnoCol);
    $detalleIdCol = pickColumn($mm, 'detalle_orden', ['id_ai_detalle', 'id'], 'id_ai_detalle');
    $herramientaCol = pickColumn($mm, 'herramienta', ['id_ai_herramienta', 'id_herramienta'], 'id_ai_herramienta');
    $herrOtCol = pickColumn($mm, 'herramientaot', ['id_ai_herramienta', 'id_herramienta'], $herramientaCol);
    $otAreaCol = pickColumn($mm, 'orden_trabajo', ['id_ai_area', 'id_area'], 'id_ai_area');
    $otSitioCol = pickColumn($mm, 'orden_trabajo', ['id_ai_sitio', 'id_sitio'], 'id_ai_sitio');

if ($tipo === '') {
    http_response_code(400);
    exit("Tipo de reporte invalido");
}

// Permisos por tipo
if (in_array($tipo, ['ot_resumen', 'ot_detallado'], true)) {
    if (!hasPerm('perm_ot_view') && !hasPerm('perm_ot_generar_reporte')) {
        http_response_code(403);
        exit("No tienes permiso para reportes de OT");
    }
}
if ($tipo === 'usuarios' && !hasPerm('perm_usuarios_view')) {
    http_response_code(403);
    exit("No tienes permiso");
}
if ($tipo === 'herramientas' && !hasPerm('perm_herramienta_view')) {
    http_response_code(403);
    exit("No tienes permiso");
}
if ($tipo === 'miembros' && !hasPerm('perm_miembro_view')) {
    http_response_code(403);
    exit("No tienes permiso");
}

$empresa = getEmpresa($mm);
$bodyClass = 'report-' . preg_replace('/[^a-z0-9_-]+/i', '-', $tipo);
$html = '<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8">' . cssBase($papel, $orientacion) . '</head><body class="' . $bodyClass . '"><div class="sheet">';

try {

    if ($tipo === 'ot_resumen') {
        $reportTitle = "Reporte OT (Resumen)";

        $params = [];
        $where = buildWhereOT($f, $params, 'id_ai_area', 'id_ai_sitio', 'id_ai_estado');

        $st = q($mm, "
          SELECT
            ot.n_ot, ot.fecha, ot.semana, ot.mes, ot.nombre_trab,
            ot.nombre_area,
            ot.nombre_sitio,
            ot.nombre_estado AS estado_actual,
            ot.total_detalles,
            ot.herramientas_asignadas AS total_herr
          FROM vw_ot_resumen ot
          {$where}
          ORDER BY ot.fecha DESC, ot.n_ot DESC
          LIMIT 2000
        ", $params);

        $rows = $st ? $st->fetchAll(PDO::FETCH_ASSOC) : [];

        $html .= headerHtmlPdf($empresa, $reportTitle, $membrete, $logo);

        $tableRows = [];
        foreach ($rows as $r) {
            $tableRows[] = [
                htmlspecialchars($r['n_ot']),
                htmlspecialchars(date('d/m/Y', strtotime($r['fecha']))),
                htmlspecialchars($r['nombre_area'] ?? ''),
                htmlspecialchars($r['nombre_sitio'] ?? ''),
                htmlspecialchars($r['nombre_trab'] ?? ''),
                htmlspecialchars($r['estado_actual'] ?? 'SIN ESTADO'),
                htmlspecialchars((string)($r['total_detalles'] ?? 0)),
                htmlspecialchars((string)($r['total_herr'] ?? 0)),
            ];
        }

        $html .= renderTable(
            "Listado de Ordenes de Trabajo",
            ['Nro OT', 'Fecha', 'Area', 'Sitio', 'Trabajo', 'Estado', 'Detalles', 'Herramientas'],
            $tableRows
        );

        $filename = "reporte_ot_resumen_" . date('Ymd_His') . ".pdf";
    } elseif ($tipo === 'ot_detallado') {
        $reportTitle = "Reporte OT (Detallado)";

        $html .= headerHtmlPdf($empresa, $reportTitle, $membrete, $logo);

        if (!empty($f['n_ot'])) {
            $ot = q($mm, "
              SELECT *
              FROM vw_ot_resumen
              WHERE n_ot = :id AND std_reg = 1
              LIMIT 1
            ", [':id' => $f['n_ot']]);

            if (!$ot || $ot->rowCount() === 0) {
                $html .= "<div class='wrap'><div class='card'>No existe la OT indicada.</div></div>";
            } else {
                $ot = $ot->fetch(PDO::FETCH_ASSOC);

                $html .= "
                  <div class='wrap'>
                    <div class='grid2'>
                      <div class='card'>
                        <div class='h6'>Datos de la OT</div>
                        <div><b>Nro OT:</b> " . htmlspecialchars($ot['n_ot']) . "</div>
                        <div><b>Fecha:</b> " . htmlspecialchars(date('d/m/Y', strtotime($ot['fecha']))) . "</div>
                        <div><b>Area:</b> " . htmlspecialchars($ot['nombre_area'] ?? '') . "</div>
                        <div><b>Sitio:</b> " . htmlspecialchars($ot['nombre_sitio'] ?? '') . "</div>
                        <div><b>Trabajo:</b> " . htmlspecialchars($ot['nombre_trab'] ?? '') . "</div>
                        <div><b>Estado:</b> " . htmlspecialchars($ot['nombre_estado'] ?? 'SIN ESTADO') . "</div>
                        <div><b>Semana/Mes:</b> " . htmlspecialchars((string)$ot['semana']) . " / " . htmlspecialchars((string)$ot['mes']) . "</div>
                      </div>
                      <div class='card'>
                        <div class='h6'>Resumen</div>
                        <div class='muted'>Incluye todos los registros de detalle asociados y herramientas asignadas.</div>
                      </div>
                    </div>
                  </div>
                ";

                $det = q($mm, "
                  SELECT
                    id_ai_detalle,
                    fecha_detalle AS fecha,
                    nombre_turno,
                    COALESCE(NULLIF(usuario_act_nombre, ''), id_user_act) AS tecnico_nombre,
                    miembro_cco_nombre AS cco_nombre,
                    miembro_ccf_nombre AS ccf_nombre,
                    descripcion,
                    hora_inicio,
                    hora_fin,
                    observacion
                  FROM vw_ot_detallada
                  WHERE n_ot = :id
                  ORDER BY id_ai_detalle ASC
                ", [':id' => $f['n_ot']]);

                $detRows = $det ? $det->fetchAll(PDO::FETCH_ASSOC) : [];

                $tableRows = [];
                foreach ($detRows as $r) {
                    $horaInicio = $mm->detalleHoraInicioValor($r);
                    $horaFin = $mm->detalleHoraFinValor($r);
                    $tableRows[] = [
                        htmlspecialchars((string)($r['id_ai_detalle'] ?? '')),
                        htmlspecialchars(date('d/m/Y', strtotime($r['fecha']))),
                        htmlspecialchars($r['nombre_turno'] ?? ''),
                        htmlspecialchars($r['tecnico_nombre'] ?? ''),
                        htmlspecialchars($r['cco_nombre'] ?? ''),
                        htmlspecialchars($r['ccf_nombre'] ?? ''),
                        htmlspecialchars($r['descripcion'] ?? ''),
                        htmlspecialchars($horaInicio),
                        htmlspecialchars($horaFin),
                        htmlspecialchars($r['observacion'] ?? ''),
                    ];
                }

                $html .= renderTable(
                    "Detalles de la OT",
                    ['ID', 'Fecha', 'Turno', 'Tecnico', 'CCO', 'CCF', 'Descripcion', 'Hora inicio', 'Hora fin', 'Observacion'],
                    $tableRows
                );

                $hot = q($mm, "
                  SELECT h.{$herrOtCol} AS herramienta_id, he.nombre_herramienta, h.cantidadot
                  FROM herramientaot h
                  LEFT JOIN herramienta he ON he.{$herramientaCol} = h.{$herrOtCol}
                  WHERE h.n_ot = :id
                  ORDER BY he.nombre_herramienta ASC
                ", [':id' => $f['n_ot']]);

                $hotRows = $hot ? $hot->fetchAll(PDO::FETCH_ASSOC) : [];
                $tableRows = [];
                foreach ($hotRows as $r) {
                    $tableRows[] = [
                        htmlspecialchars($r['herramienta_id']),
                        htmlspecialchars($r['nombre_herramienta'] ?? ''),
                        htmlspecialchars((string)$r['cantidadot']),
                    ];
                }

                $html .= renderTable(
                    "Herramientas asignadas",
                    ['Codigo', 'Herramienta', 'Cantidad'],
                    $tableRows
                );
            }
        } else {
            $html .= "<div class='wrap'><div class='card'>Para PDF detallado se recomienda indicar Nro OT.</div></div>";
        }

        $filename = "reporte_ot_detallado_" . ($f['n_ot'] ?: date('Ymd_His')) . ".pdf";
    } elseif ($tipo === 'herramientas') {
        $reportTitle = "Reporte de Herramientas";

        $qtxt = trim($f['q']);
        $params = [];
        $where = " WHERE std_reg = 1 ";
        if ($qtxt !== '') {
            $where .= " AND (CAST(id_ai_herramienta AS CHAR) LIKE :q_codigo OR nombre_herramienta LIKE :q_nombre) ";
            $params[':q_codigo'] = "%{$qtxt}%";
            $params[':q_nombre'] = "%{$qtxt}%";
        }

        $st = q($mm, "SELECT id_ai_herramienta AS herramienta_id, nombre_herramienta, cantidad_total AS cantidad, cantidad_disponible, cantidad_ocupada, estado FROM vw_herramienta_disponibilidad {$where} ORDER BY nombre_herramienta ASC LIMIT 5000", $params);
        $rows = $st ? $st->fetchAll(PDO::FETCH_ASSOC) : [];

        $html .= headerHtmlPdf($empresa, $reportTitle, $membrete, $logo);

        $tableRows = [];
        foreach ($rows as $r) {
            $tableRows[] = [
                htmlspecialchars($r['herramienta_id']),
                htmlspecialchars($r['nombre_herramienta']),
                htmlspecialchars((string)$r['cantidad']),
                htmlspecialchars((string)$r['cantidad_disponible']),
                htmlspecialchars((string)$r['cantidad_ocupada']),
                htmlspecialchars((string)$r['estado']),
            ];
        }

        $html .= renderTable("Listado de herramientas", ['Codigo', 'Nombre', 'Total', 'Disponible', 'Ocupada', 'Estado'], $tableRows);
        $filename = "reporte_herramientas_" . date('Ymd_His') . ".pdf";
    } elseif ($tipo === 'miembros') {
        $reportTitle = "Reporte de Miembros";

        $qtxt = trim($f['q']);
        $params = [];
        $where = " WHERE std_reg = 1 ";
        if ($qtxt !== '') {
            $where .= " AND (id_miembro LIKE :q OR nombre_miembro LIKE :q) ";
            $params[':q'] = "%{$qtxt}%";
        }

        $st = q($mm, "SELECT " . $mm->columnasTablaSql('miembro') . " FROM miembro {$where} ORDER BY nombre_miembro ASC LIMIT 5000", $params);
        $rows = $st ? $st->fetchAll(PDO::FETCH_ASSOC) : [];

        $html .= headerHtmlPdf($empresa, $reportTitle, $membrete, $logo);

        $tableRows = [];
        foreach ($rows as $r) {
            $tipoTxt = ((int)$r['tipo_miembro'] === 1) ? 'CCF' : 'CCO';
            $tableRows[] = [htmlspecialchars($r['id_miembro']), htmlspecialchars($r['nombre_miembro']), htmlspecialchars($tipoTxt)];
        }

        $html .= renderTable("Listado de miembros", ['Codigo', 'Nombre', 'Tipo'], $tableRows);
        $filename = "reporte_miembros_" . date('Ymd_His') . ".pdf";
    } elseif ($tipo === 'usuarios') {
        $reportTitle = "Reporte de Usuarios";

        $qtxt = trim($f['q']);
        $params = [];
        $where = " WHERE std_reg = 1 ";
        if ($qtxt !== '') {
            $where .= " AND (
                id_empleado LIKE :q_id
                OR COALESCE(nombre_empleado, '') LIKE :q_nombre
                OR username LIKE :q_username
                OR COALESCE(nombre_rol, '') LIKE :q_rol
            ) ";
            $params[':q_id'] = "%{$qtxt}%";
            $params[':q_nombre'] = "%{$qtxt}%";
            $params[':q_username'] = "%{$qtxt}%";
            $params[':q_rol'] = "%{$qtxt}%";
        }

        $st = q($mm, "
          SELECT id_empleado AS id_user, COALESCE(nombre_empleado, id_empleado) AS user, username, nombre_rol
          FROM vw_usuario_empleado
          {$where}
          ORDER BY COALESCE(nombre_empleado, id_empleado) ASC
          LIMIT 5000
        ", $params);

        $rows = $st ? $st->fetchAll(PDO::FETCH_ASSOC) : [];

        $html .= headerHtmlPdf($empresa, $reportTitle, $membrete, $logo);

        $tableRows = [];
        foreach ($rows as $r) {
            $tableRows[] = [htmlspecialchars($r['id_user']), htmlspecialchars($r['user']), htmlspecialchars($r['username']), htmlspecialchars($r['nombre_rol'] ?? '')];
        }

        $html .= renderTable("Listado de usuarios", ['Cedula/ID', 'Nombre', 'Username', 'Rol'], $tableRows);
        $filename = "reporte_usuarios_" . date('Ymd_His') . ".pdf";
    } else {
        http_response_code(400);
        exit("Tipo de reporte no soportado");
    }

    $html .= "</div></body></html>";

    // DOMPDF
    $options = new Options();
    $options->set('isRemoteEnabled', true);
    $options->set('isHtml5ParserEnabled', true);
    $options->setDefaultFont('DejaVu Sans');
    $dompdf = new Dompdf($options);
    $dompdf->loadHtml($html, 'UTF-8');
    $dompdf->setPaper(strtoupper($papel ?: 'A4'), ($orientacion === 'landscape') ? 'landscape' : 'portrait');
    $dompdf->render();
    $pdfBinary = $dompdf->output();

    try {
        $storage = new reporteGeneradoController();
        $storage->guardarReporteGenerado(
            $tipo,
            [
                'tipo' => $tipo,
                'papel' => $papel,
                'orientacion' => $orientacion,
                'membrete' => $membrete ? 1 : 0,
                'logo' => $logo ? 1 : 0,
                'filtros' => $f,
            ],
            $pdfBinary,
            $reportTitle ?? 'Reporte Generado',
            $filename
        );
    } catch (Throwable $storageError) {
        error_log('[exportarReportePdf] No se pudo guardar el PDF generado: ' . $storageError->getMessage());
    }

    header('Content-Type: application/pdf');
    header('Content-Disposition: attachment; filename="' . $filename . '"');
    echo $pdfBinary;
    exit;
} catch (Exception $e) {
    http_response_code(500);
    exit("Error generando PDF");
}

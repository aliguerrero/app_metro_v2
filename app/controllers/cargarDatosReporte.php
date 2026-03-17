<?php
// app/controllers/cargarDatosReporte.php

require_once "../../config/app.php";
require_once "../views/inc/session_start.php";
require_once "../../autoload.php";

use app\models\mainModel;

header('Content-Type: application/json; charset=utf-8');

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
    if ($ext === 'jpg' || $ext === 'jpeg') {
        $mime = 'image/jpeg';
    } elseif ($ext === 'gif') {
        $mime = 'image/gif';
    } elseif ($ext === 'webp') {
        $mime = 'image/webp';
    }

    $raw = @file_get_contents($absPath);
    if ($raw === false) {
        return '';
    }

    return "data:{$mime};base64," . base64_encode($raw);
}

function cssBase(string $papel, string $orientacion): string
{
    $papel = strtoupper($papel ?: 'A4');
    $orientacion = ($orientacion === 'landscape') ? 'landscape' : 'portrait';

    return "
    <style>
      @page { size: {$papel} {$orientacion}; margin: 18px; }
      body { font-family: Arial, Helvetica, sans-serif; font-size: 12px; color:#111; }
      .wrap { padding: 14px; }
      .muted { color:#666; }
      .header { display:flex; align-items:center; justify-content:space-between; gap:12px; border-bottom:1px solid #ddd; padding-bottom:10px; margin-bottom:14px; }
      .brand { display:flex; align-items:center; gap:12px; }
      .brand img { width: 56px; height: 56px; object-fit: contain; }
      .title { font-size: 16px; font-weight: 700; margin:0; }
      .sub { margin:2px 0 0 0; font-size: 12px; }
      table { width:100%; border-collapse:collapse; margin-top:10px; }
      th, td { border:1px solid #ddd; padding:7px; vertical-align:top; }
      th { background:#f3f5f7; text-align:left; }
      .badge { display:inline-block; padding:3px 8px; border-radius:999px; background:#eee; font-size:11px; }
      .grid2 { display:grid; grid-template-columns: 1fr 1fr; gap:10px; }
      .card { border:1px solid #ddd; border-radius:8px; padding:10px; }
      .h6 { font-size: 13px; font-weight: 700; margin:0 0 6px 0; }
    </style>
    ";
}

function headerHtml(array $empresa, string $titulo, bool $membrete, bool $logo): string
{
    $empresaNombre = htmlspecialchars($empresa['nombre'] ?? 'Empresa');
    $rif = htmlspecialchars($empresa['rif'] ?? '');
    $dir = htmlspecialchars($empresa['direccion'] ?? '');
    $tel = htmlspecialchars($empresa['telefono'] ?? '');
    $email = htmlspecialchars($empresa['email'] ?? '');

    $logoTag = '';
    if ($logo) {
        $ruta = (string)($empresa['logo'] ?? '');
        $abs = resolveLogoAbsolutePath($ruta);
        if ($abs !== '') {
            $src = imgToDataUri($abs);
            if ($src !== '') {
                $logoTag = "<img src=\"{$src}\" alt=\"logo\">";
            }
        }
    }

    if (!$membrete) {
        return "<div class='wrap'><h2 class='title'>{$titulo}</h2></div>";
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

function buildWhereOT(array $f, array &$params, string $otAreaCol, string $otSitioCol, string $detalleEstadoCol): string
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

    // estado y usuario vienen desde detalle_orden (último estado y/o último técnico)
    // lo filtramos con EXISTS (compatible y simple)
    if (!empty($f['estado'])) {
        $w .= " AND EXISTS (
            SELECT 1 FROM detalle_orden d
            WHERE d.n_ot = ot.n_ot AND d.{$detalleEstadoCol} = :estado
        ) ";
        $params[':estado'] = $f['estado'];
    }

    if (!empty($f['usuario'])) {
        $w .= " AND EXISTS (
            SELECT 1 FROM detalle_orden d2
            WHERE d2.n_ot = ot.n_ot AND d2.id_user_act = :usuario
        ) ";
        $params[':usuario'] = $f['usuario'];
    }

    return $w;
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

// =====================
// Entrada y validación
// =====================
$tipo = $mm->limpiarCadena($_GET['tipo'] ?? '');
$papel = $mm->limpiarCadena($_GET['papel'] ?? 'A4');
$orientacion = $mm->limpiarCadena($_GET['orientacion'] ?? 'portrait');
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

if ($tipo === '') {
    echo json_encode(['ok' => false, 'msg' => 'Tipo de reporte inválido']);
    exit;
}

$empresa = getEmpresa($mm);
$html = "<html><head>" . cssBase($papel, $orientacion) . "</head><body>";

try {

    $areaCol = pickColumn($mm, 'area_trabajo', ['id_ai_area', 'id_area'], 'id_ai_area');
    $sitioCol = pickColumn($mm, 'sitio_trabajo', ['id_ai_sitio', 'id_sitio'], 'id_ai_sitio');
    $estadoCol = pickColumn($mm, 'estado_ot', ['id_ai_estado', 'id_estado'], 'id_ai_estado');
    $detalleEstadoCol = pickColumn($mm, 'detalle_orden', ['id_ai_estado', 'id_estado'], $estadoCol);
    $otAreaCol = pickColumn($mm, 'orden_trabajo', ['id_ai_area', 'id_area'], 'id_ai_area');
    $otSitioCol = pickColumn($mm, 'orden_trabajo', ['id_ai_sitio', 'id_sitio'], 'id_ai_sitio');
    $turnoCol = pickColumn($mm, 'turno_trabajo', ['id_ai_turno', 'id_turno'], 'id_ai_turno');
    $detalleTurnoCol = pickColumn($mm, 'detalle_orden', ['id_ai_turno', 'id_turno'], $turnoCol);
    $detalleIdCol = pickColumn($mm, 'detalle_orden', ['id_ai_detalle', 'id'], 'id_ai_detalle');
    $herramientaCol = pickColumn($mm, 'herramienta', ['id_ai_herramienta', 'id_herramienta'], 'id_ai_herramienta');
    $herrOtCol = pickColumn($mm, 'herramientaot', ['id_ai_herramienta', 'id_herramienta'], $herramientaCol);

    // Permisos por tipo
    if (in_array($tipo, ['ot_resumen', 'ot_detallado'], true)) {
        if (!hasPerm('perm_ot_view') && !hasPerm('perm_ot_generar_reporte')) {
            echo json_encode(['ok' => false, 'msg' => 'No tienes permiso para reportes de OT']);
            exit;
        }
    }
    if ($tipo === 'usuarios' && !hasPerm('perm_usuarios_view')) {
        echo json_encode(['ok' => false, 'msg' => 'No tienes permiso para reportes de usuarios']);
        exit;
    }
    if ($tipo === 'herramientas' && !hasPerm('perm_herramienta_view')) {
        echo json_encode(['ok' => false, 'msg' => 'No tienes permiso para reportes de herramientas']);
        exit;
    }
    if ($tipo === 'miembros' && !hasPerm('perm_miembro_view')) {
        echo json_encode(['ok' => false, 'msg' => 'No tienes permiso para reportes de miembros']);
        exit;
    }

    // ==========================
    // Generación por tipo reporte
    // ==========================
    if ($tipo === 'ot_resumen') {

        $params = [];
        $where = buildWhereOT($f, $params, $otAreaCol, $otSitioCol, $detalleEstadoCol);

        $sql = "
          SELECT
            ot.n_ot, ot.fecha, ot.semana, ot.mes, ot.nombre_trab,
            a.nombre_area,
            s.nombre_sitio,
            (SELECT e.nombre_estado
             FROM detalle_orden d
             LEFT JOIN estado_ot e ON e.{$estadoCol} = d.{$detalleEstadoCol}
             WHERE d.n_ot = ot.n_ot
             ORDER BY d.{$detalleIdCol} DESC
             LIMIT 1) AS estado_actual,
            (SELECT COUNT(1) FROM detalle_orden d2 WHERE d2.n_ot = ot.n_ot) AS total_detalles,
            (SELECT COUNT(1) FROM herramientaot h WHERE h.n_ot = ot.n_ot) AS total_herr
          FROM orden_trabajo ot
          LEFT JOIN area_trabajo a ON a.{$areaCol} = ot.{$otAreaCol}
          LEFT JOIN sitio_trabajo s ON s.{$sitioCol} = ot.{$otSitioCol}
          {$where}
          ORDER BY ot.fecha DESC, ot.n_ot DESC
          LIMIT 500
        ";

        $st = q($mm, $sql, $params);
        $rows = $st ? $st->fetchAll(PDO::FETCH_ASSOC) : [];

        $html .= headerHtml($empresa, "Reporte OT (Resumen)", $membrete, $logo);

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
            "Listado de Órdenes de Trabajo",
            ['N° OT', 'Fecha', 'Área', 'Sitio', 'Trabajo', 'Estado', 'Detalles', 'Herramientas'],
            $tableRows
        );
    } elseif ($tipo === 'ot_detallado') {

        $html .= headerHtml($empresa, "Reporte OT (Detallado)", $membrete, $logo);

        // Si viene N° OT, hacemos reporte por 1 OT (ideal)
        if (!empty($f['n_ot'])) {
            $ot = q($mm, "
              SELECT {$mm->columnasTablaSql('orden_trabajo', 'ot')}, a.nombre_area, s.nombre_sitio
              FROM orden_trabajo ot
              LEFT JOIN area_trabajo a ON a.{$areaCol} = ot.{$otAreaCol}
              LEFT JOIN sitio_trabajo s ON s.{$sitioCol} = ot.{$otSitioCol}
              WHERE ot.n_ot = :id AND ot.std_reg = 1
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
                        <div><b>N° OT:</b> " . htmlspecialchars($ot['n_ot']) . "</div>
                        <div><b>Fecha:</b> " . htmlspecialchars(date('d/m/Y', strtotime($ot['fecha']))) . "</div>
                        <div><b>Área:</b> " . htmlspecialchars($ot['nombre_area'] ?? '') . "</div>
                        <div><b>Sitio:</b> " . htmlspecialchars($ot['nombre_sitio'] ?? '') . "</div>
                        <div><b>Trabajo:</b> " . htmlspecialchars($ot['nombre_trab'] ?? '') . "</div>
                        <div><b>Semana/Mes:</b> " . htmlspecialchars((string)$ot['semana']) . " / " . htmlspecialchars((string)$ot['mes']) . "</div>
                      </div>
                      <div class='card'>
                        <div class='h6'>Resumen</div>
                        <div class='muted'>Incluye todos los registros de detalle asociados y herramientas asignadas.</div>
                      </div>
                    </div>
                  </div>
                ";

                // Detalles (pueden ser muchos)
                $det = q($mm, "
                  SELECT {$mm->columnasTablaSql('detalle_orden', 'd')}, 
                         t.nombre_turno,
                         e.nombre_estado,
                         COALESCE(emp.nombre_empleado, d.id_user_act) AS tecnico_nombre,
                         cco.nombre_miembro AS cco_nombre,
                         ccf.nombre_miembro AS ccf_nombre
                  FROM detalle_orden d
                  LEFT JOIN turno_trabajo t ON t.{$turnoCol} = d.{$detalleTurnoCol}
                  LEFT JOIN estado_ot e ON e.{$estadoCol} = d.{$detalleEstadoCol}
                  LEFT JOIN empleado emp ON emp.id_empleado = d.id_user_act
                  LEFT JOIN miembro cco ON cco.id_miembro = d.id_miembro_cco
                  LEFT JOIN miembro ccf ON ccf.id_miembro = d.id_miembro_ccf
                  WHERE d.n_ot = :id
                  ORDER BY d.{$detalleIdCol} ASC
                ", [':id' => $f['n_ot']]);

                $detRows = $det ? $det->fetchAll(PDO::FETCH_ASSOC) : [];

                $tableRows = [];
                foreach ($detRows as $r) {
                    $tableRows[] = [
                        htmlspecialchars((string)($r[$detalleIdCol] ?? '')),
                        htmlspecialchars(date('d/m/Y', strtotime($r['fecha']))),
                        htmlspecialchars($r['nombre_turno'] ?? ''),
                        htmlspecialchars($r['tecnico_nombre'] ?? ''),
                        htmlspecialchars($r['cco_nombre'] ?? ''),
                        htmlspecialchars($r['ccf_nombre'] ?? ''),
                        htmlspecialchars($r['nombre_estado'] ?? ''),
                        htmlspecialchars($r['descripcion'] ?? ''),
                        htmlspecialchars($r['hora_ini_pre'] ?? '') . " - " . htmlspecialchars($r['hora_fin_pre'] ?? ''),
                        htmlspecialchars($r['hora_ini_tra'] ?? '') . " - " . htmlspecialchars($r['hora_fin_tra'] ?? ''),
                        htmlspecialchars($r['hora_ini_eje'] ?? '') . " - " . htmlspecialchars($r['hora_fin_eje'] ?? ''),
                        htmlspecialchars($r['observacion'] ?? ''),
                    ];
                }

                $html .= renderTable(
                    "Detalles de la OT (pueden existir múltiples registros)",
                    ['ID', 'Fecha', 'Turno', 'Técnico', 'CCO', 'CCF', 'Estado', 'Descripción', 'Prep', 'Tras', 'Ejec', 'Observación'],
                    $tableRows
                );

                // Herramientas asignadas a la OT
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
                    "Herramientas asignadas a la OT",
                    ['Código', 'Herramienta', 'Cantidad'],
                    $tableRows
                );
            }
        } else {
            // Sin N° OT => hacemos un “detallado por rango” (limitado para no explotar)
            $params = [];
            $where = buildWhereOT($f, $params, $otAreaCol, $otSitioCol, $detalleEstadoCol);

            $ots = q($mm, "
              SELECT ot.n_ot, ot.fecha, ot.nombre_trab, a.nombre_area, s.nombre_sitio
              FROM orden_trabajo ot
              LEFT JOIN area_trabajo a ON a.{$areaCol} = ot.{$otAreaCol}
              LEFT JOIN sitio_trabajo s ON s.{$sitioCol} = ot.{$otSitioCol}
              {$where}
              ORDER BY ot.fecha DESC
              LIMIT 50
            ", $params);

            $ots = $ots ? $ots->fetchAll(PDO::FETCH_ASSOC) : [];
            if (!$ots) {
                $html .= "<div class='wrap'><div class='card'>Sin resultados para el filtro actual.</div></div>";
            } else {
                $tableRows = [];
                foreach ($ots as $r) {
                    $tableRows[] = [
                        htmlspecialchars($r['n_ot']),
                        htmlspecialchars(date('d/m/Y', strtotime($r['fecha']))),
                        htmlspecialchars($r['nombre_area'] ?? ''),
                        htmlspecialchars($r['nombre_sitio'] ?? ''),
                        htmlspecialchars($r['nombre_trab'] ?? ''),
                        "<span class='muted'>Seleccione N° OT para ver el detalle completo</span>"
                    ];
                }
                $html .= renderTable(
                    "OTs encontradas (modo detallado por rango - limitado)",
                    ['N° OT', 'Fecha', 'Área', 'Sitio', 'Trabajo', 'Nota'],
                    $tableRows
                );
            }
        }
    } elseif ($tipo === 'herramientas') {

        $qtxt = trim($f['q']);
        $params = [];
        $where = " WHERE std_reg = 1 ";
        if ($qtxt !== '') {
            $where .= " AND ({$herramientaCol} LIKE :q OR nombre_herramienta LIKE :q) ";
            $params[':q'] = "%{$qtxt}%";
        }

        $st = q($mm, "SELECT {$herramientaCol} AS herramienta_id, nombre_herramienta, cantidad, estado FROM herramienta {$where} ORDER BY nombre_herramienta ASC LIMIT 800", $params);
        $rows = $st ? $st->fetchAll(PDO::FETCH_ASSOC) : [];

        $html .= headerHtml($empresa, "Reporte de Herramientas", $membrete, $logo);

        $tableRows = [];
        foreach ($rows as $r) {
            $tableRows[] = [
                htmlspecialchars($r['herramienta_id']),
                htmlspecialchars($r['nombre_herramienta']),
                htmlspecialchars((string)$r['cantidad']),
                htmlspecialchars((string)$r['estado']),
            ];
        }

        $html .= renderTable(
            "Listado de herramientas",
            ['Código', 'Nombre', 'Cantidad', 'Estado'],
            $tableRows
        );
    } elseif ($tipo === 'miembros') {

        $qtxt = trim($f['q']);
        $params = [];
        $where = " WHERE std_reg = 1 ";
        if ($qtxt !== '') {
            $where .= " AND (id_miembro LIKE :q OR nombre_miembro LIKE :q) ";
            $params[':q'] = "%{$qtxt}%";
        }

        $st = q($mm, "SELECT " . $mm->columnasTablaSql('miembro') . " FROM miembro {$where} ORDER BY nombre_miembro ASC LIMIT 800", $params);
        $rows = $st ? $st->fetchAll(PDO::FETCH_ASSOC) : [];

        $html .= headerHtml($empresa, "Reporte de Miembros", $membrete, $logo);

        $tableRows = [];
        foreach ($rows as $r) {
            $tipoTxt = ((int)$r['tipo_miembro'] === 1) ? 'CCF' : 'CCO';
            $tableRows[] = [
                htmlspecialchars($r['id_miembro']),
                htmlspecialchars($r['nombre_miembro']),
                htmlspecialchars($tipoTxt),
            ];
        }

        $html .= renderTable(
            "Listado de miembros",
            ['Código', 'Nombre', 'Tipo'],
            $tableRows
        );
    } elseif ($tipo === 'usuarios') {

        $qtxt = trim($f['q']);
        $params = [];
        $where = " WHERE u.std_reg = 1 ";
        if ($qtxt !== '') {
            $where .= " AND (u.id_empleado LIKE :q OR COALESCE(e.nombre_empleado, '') LIKE :q OR u.username LIKE :q) ";
            $params[':q'] = "%{$qtxt}%";
        }

        $st = q($mm, "
          SELECT u.id_empleado AS id_user, COALESCE(e.nombre_empleado, u.id_empleado) AS user, u.username, r.nombre_rol
          FROM user_system u
          LEFT JOIN empleado e ON e.id_empleado = u.id_empleado
          LEFT JOIN roles_permisos r ON r.id = u.tipo
          {$where}
          ORDER BY COALESCE(e.nombre_empleado, u.id_empleado) ASC
          LIMIT 800
        ", $params);

        $rows = $st ? $st->fetchAll(PDO::FETCH_ASSOC) : [];

        $html .= headerHtml($empresa, "Reporte de Usuarios", $membrete, $logo);

        $tableRows = [];
        foreach ($rows as $r) {
            $tableRows[] = [
                htmlspecialchars($r['id_user']),
                htmlspecialchars($r['user']),
                htmlspecialchars($r['username']),
                htmlspecialchars($r['nombre_rol'] ?? ''),
            ];
        }

        $html .= renderTable(
            "Listado de usuarios",
            ['Cédula/ID', 'Nombre', 'Username', 'Rol'],
            $tableRows
        );
    } else {
        echo json_encode(['ok' => false, 'msg' => 'Tipo de reporte no soportado']);
        exit;
    }

    $html .= "</body></html>";

    echo json_encode(['ok' => true, 'html' => $html]);
} catch (Exception $e) {
    error_log('[cargarDatosReporte] ' . $e->getMessage());
    error_log($e->getTraceAsString());
    echo json_encode(['ok' => false, 'msg' => 'Error generando reporte (preview)']);
}

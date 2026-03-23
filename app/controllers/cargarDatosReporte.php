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
    $screenMaxWidth = ($orientacion === 'landscape') ? '1520px' : '1240px';
    return "
    <style>
      @page { size: {$papel} {$orientacion}; margin: 24px 26px; }
      html, body { margin:0; padding:0; }
      body { font-family: Arial, Helvetica, sans-serif; font-size: 13px; line-height:1.45; color:#111; background:#eef2f7; padding:30px; }
      .sheet { width:100%; max-width: {$screenMaxWidth}; margin:0 auto; background:#fff; border:1px solid #d8dee6; border-radius:16px; box-shadow:0 14px 40px rgba(15,23,42,.08); padding:28px 34px 34px; box-sizing:border-box; }
      .wrap { padding: 16px 0; }
      .muted { color:#666; }
      .header { display:flex; align-items:center; justify-content:space-between; gap:12px; border-bottom:1px solid #ddd; padding-bottom:10px; margin-bottom:14px; }
      .brand { display:flex; align-items:center; gap:12px; }
      .brand img { width: 56px; height: 56px; object-fit: contain; }
      .title { font-size: 16px; font-weight: 700; margin:0; }
      .sub { margin:2px 0 0 0; font-size: 12px; }
      table { width:100%; border-collapse:collapse; margin-top:14px; table-layout:auto; }
      th, td { border:1px solid #ddd; padding:8px 9px; vertical-align:top; word-break:break-word; }
      th { background:#f3f5f7; text-align:left; } .badge { display:inline-block; padding:3px 8px; border-radius:999px; background:#eee; font-size:11px; }
      .grid2 { display:grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap:12px; } .card { border:1px solid #ddd; border-radius:8px; padding:10px; } .h6 { font-size: 13px; font-weight: 700; margin:0 0 6px 0; }
      @media (max-width: 900px) { body { padding:14px; } .sheet { padding:18px; border-radius:12px; } .header { display:block; } .brand { margin-bottom:12px; } }
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

    // estado y usuario vienen desde detalle_orden (ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Âºltimo estado y/o ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Âºltimo tÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â©cnico)
    // lo filtramos con EXISTS (compatible y simple)
    if (!empty($f['estado'])) {
        $w .= " AND ot.{$otEstadoCol} = :estado ";
        $params[':estado'] = $f['estado'];
    }

    if (!empty($f['usuario'])) {
        $w .= " AND EXISTS (
            SELECT 1 FROM vw_ot_detallada d2
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
// Entrada y validacion
// =====================
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

if ($tipo === '') {
    echo json_encode(['ok' => false, 'msg' => 'Tipo de reporte invalido']);
    exit;
}

$empresa = getEmpresa($mm);
$html = '<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">' . cssBase($papel, $orientacion) . '</head><body><div class="sheet">';

try {

    $areaCol = pickColumn($mm, 'area_trabajo', ['id_ai_area', 'id_area'], 'id_ai_area');
    $sitioCol = pickColumn($mm, 'sitio_trabajo', ['id_ai_sitio', 'id_sitio'], 'id_ai_sitio');
    $estadoCol = pickColumn($mm, 'estado_ot', ['id_ai_estado', 'id_estado'], 'id_ai_estado');
    $otEstadoCol = pickColumn($mm, 'orden_trabajo', ['id_ai_estado', 'id_estado'], $estadoCol);
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
    // GeneraciÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â³n por tipo reporte
    // ==========================
    if ($tipo === 'ot_resumen') {

        $params = [];
        $where = buildWhereOT($f, $params, 'id_ai_area', 'id_ai_sitio', 'id_ai_estado');

        $sql = "
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
            "Listado de Ordenes de Trabajo",
            ['Nro. OT', 'Fecha', 'Area', 'Sitio', 'Trabajo', 'Estado', 'Detalles', 'Herramientas'],
            $tableRows
        );
    } elseif ($tipo === 'ot_detallado') {

        $html .= headerHtml($empresa, "Reporte OT (Detallado)", $membrete, $logo);

        // Si viene Nro. OT, hacemos reporte por 1 OT.
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
                        <div><b>Nro. OT:</b> " . htmlspecialchars($ot['n_ot']) . "</div>
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

                // Detalles (pueden ser muchos)
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
                    "Detalles de la OT (pueden existir multiples registros)",
                    ['ID', 'Fecha', 'Turno', 'Tecnico', 'CCO', 'CCF', 'Descripcion', 'Hora inicio', 'Hora fin', 'Observacion'],
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
                    ['Codigo', 'Herramienta', 'Cantidad'],
                    $tableRows
                );
            }
        } else {
            // Sin Nro. OT => hacemos un detallado por rango limitado.
            $params = [];
            $where = buildWhereOT($f, $params, 'id_ai_area', 'id_ai_sitio', 'id_ai_estado');

            $ots = q($mm, "
              SELECT ot.n_ot, ot.fecha, ot.nombre_trab, ot.nombre_area, ot.nombre_sitio
              FROM vw_ot_resumen ot
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
                        "<span class='muted'>Seleccione Nro. OT para ver el detalle completo</span>"
                    ];
                }
                $html .= renderTable(
                    "OTs encontradas (modo detallado por rango - limitado)",
                    ['Nro. OT', 'Fecha', 'Area', 'Sitio', 'Trabajo', 'Nota'],
                    $tableRows
                );
            }
        }
    } elseif ($tipo === 'herramientas') {

        $qtxt = trim($f['q']);
        $params = [];
        $where = " WHERE std_reg = 1 ";
        if ($qtxt !== '') {
            $where .= " AND (CAST(id_ai_herramienta AS CHAR) LIKE :q_codigo OR nombre_herramienta LIKE :q_nombre) ";
            $params[':q_codigo'] = "%{$qtxt}%";
            $params[':q_nombre'] = "%{$qtxt}%";
        }

        $st = q($mm, "SELECT id_ai_herramienta AS herramienta_id, nombre_herramienta, cantidad_total AS cantidad, cantidad_disponible, cantidad_ocupada, estado FROM vw_herramienta_disponibilidad {$where} ORDER BY nombre_herramienta ASC LIMIT 800", $params);
        $rows = $st ? $st->fetchAll(PDO::FETCH_ASSOC) : [];

        $html .= headerHtml($empresa, "Reporte de Herramientas", $membrete, $logo);

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

        $html .= renderTable(
            "Listado de herramientas",
            ['Codigo', 'Nombre', 'Total', 'Disponible', 'Ocupada', 'Estado'],
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
            ['Codigo', 'Nombre', 'Tipo'],
            $tableRows
        );
    } elseif ($tipo === 'usuarios') {

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
            ['Cedula/ID', 'Nombre', 'Username', 'Rol'],
            $tableRows
        );
    } else {
        echo json_encode(['ok' => false, 'msg' => 'Tipo de reporte no soportado']);
        exit;
    }

    $html .= "</div></body></html>";

    echo json_encode(['ok' => true, 'html' => $html]);
} catch (Exception $e) {
    error_log('[cargarDatosReporte] ' . $e->getMessage());
    error_log($e->getTraceAsString());
    echo json_encode(['ok' => false, 'msg' => 'Error generando reporte (preview)']);
}


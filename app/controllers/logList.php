<?php
require_once __DIR__ . "/securityBootstrap.php";

use app\controllers\configController;

appsec_require_admin();
appsec_set_security_headers();

header('Content-Type: text/html; charset=utf-8');

$ins = new configController();

$q = trim(appsec_request_string('q'));
$tabla = trim(appsec_request_string('tabla'));
$op = trim(appsec_request_string('op'));
$user = trim(appsec_request_string('user'));
$from = trim(appsec_request_string('from'));
$to = trim(appsec_request_string('to'));
$limit = (int)appsec_request_string('limit', '100');

if ($limit <= 0) {
    $limit = 100;
}
if ($limit > 500) {
    $limit = 500;
}

$where = [];
$params = [];

if ($tabla !== '') {
    $where[] = "l.tabla = :tabla";
    $params[':tabla'] = $tabla;
}
if ($op !== '') {
    $where[] = "l.operacion = :op";
    $params[':op'] = $op;
}
if ($user !== '') {
    $where[] = "l.id_user = :user";
    $params[':user'] = $user;
}
if ($from !== '') {
    $where[] = "DATE(l.fecha_hora) >= :from";
    $params[':from'] = $from;
}
if ($to !== '') {
    $where[] = "DATE(l.fecha_hora) <= :to";
    $params[':to'] = $to;
}
if ($q !== '') {
    $where[] = "(l.accion LIKE :q OR l.pk_registro LIKE :q OR l.resp_system LIKE :q OR l.tabla LIKE :q)";
    $params[':q'] = "%{$q}%";
}

$sqlBase = "FROM log_user l";
$sqlWhere = count($where) ? (" WHERE " . implode(" AND ", $where)) : "";

$sqlTotal = "SELECT COUNT(1) AS total {$sqlBase} {$sqlWhere}";
$stmtTotal = $ins->ejecutarConsultaConParametros($sqlTotal, $params);
$total = 0;

if ($stmtTotal) {
    $rowTotal = $stmtTotal->fetch(PDO::FETCH_ASSOC);
    $total = (int)($rowTotal['total'] ?? 0);
}

$sql = "SELECT " . $ins->columnasTablaSql('log_user', 'l') . " {$sqlBase} {$sqlWhere} ORDER BY l.fecha_hora DESC, l.id_log DESC LIMIT {$limit}";
$stmt = $ins->ejecutarConsultaConParametros($sql, $params);
$rows = $stmt ? $stmt->fetchAll(PDO::FETCH_ASSOC) : [];

function opHuman($op)
{
    return match ($op) {
        'INSERT' => 'Creacion',
        'UPDATE' => 'Actualizacion',
        'DELETE' => 'Eliminacion definitiva',
        'SOFT_DELETE' => 'Eliminacion logica',
        default => 'Sistema'
    };
}

function esc($value)
{
    return htmlspecialchars((string)$value, ENT_QUOTES, 'UTF-8');
}

echo '<span class="d-none" id="logTotalCount" data-total="' . esc($total) . '"></span>';
echo '<div class="d-flex justify-content-between align-items-center px-2 py-2">';
echo '<div class="small text-muted">Mostrando <b>' . esc(count($rows)) . '</b> de <b>' . esc($total) . '</b></div>';
echo '</div>';
echo '<div class="log-table-wrap d-none d-md-block">';
echo '<table class="table table-sm table-hover mb-0">';
echo '<thead class="table-light"><tr class="align-middle">';
echo '<th>#</th><th>Fecha</th><th>Modulo</th><th>Accion</th><th>Operacion</th><th>Usuario</th><th class="text-center">Ver</th>';
echo '</tr></thead><tbody>';

if (!count($rows)) {
    echo '<tr><td colspan="7" class="text-center text-muted py-4">Sin resultados</td></tr>';
} else {
    $i = 1;
    foreach ($rows as $row) {
        echo '<tr class="align-middle">';
        echo '<td><b>' . esc($i) . '</b></td>';
        echo '<td class="small">' . esc($row['fecha_hora']) . '</td>';
        echo '<td><b>' . esc($row['tabla']) . '</b></td>';
        echo '<td>' . esc($row['accion']) . '<div class="small text-muted">' . esc($row['pk_registro']) . '</div></td>';
        echo '<td><span class="badge bg-secondary">' . esc(opHuman($row['operacion'])) . '</span></td>';
        echo '<td>' . esc($row['id_user'] ?? '-') . '</td>';
        echo '<td class="text-center"><button class="btn btn-sm btn-outline-primary js-log-view" data-id="' . esc($row['id_log']) . '"><i class="bi bi-eye"></i></button></td>';
        echo '</tr>';
        $i++;
    }
}

echo '</tbody></table></div>';
echo '<div class="d-md-none p-2">';

if (!count($rows)) {
    echo '<div class="text-muted text-center py-3">Sin resultados</div>';
} else {
    $i = 1;
    foreach ($rows as $row) {
        echo '<div class="log-card">';
        echo '  <div class="top">';
        echo '    <div><b>#' . esc($i) . '</b> • <b>' . esc($row['tabla']) . '</b></div>';
        echo '    <span class="badge bg-secondary">' . esc(opHuman($row['operacion'])) . '</span>';
        echo '  </div>';
        echo '  <div class="meta">' . esc($row['fecha_hora']) . ' • Usuario: ' . esc($row['id_user'] ?? '-') . '</div>';
        echo '  <div class="mt-1">' . esc($row['accion']) . '</div>';
        echo '  <div class="meta">' . esc($row['pk_registro']) . '</div>';
        echo '  <div class="mt-2 d-flex justify-content-end">';
        echo '    <button class="btn btn-sm btn-outline-primary js-log-view" data-id="' . esc($row['id_log']) . '"><i class="bi bi-eye"></i> Ver</button>';
        echo '  </div>';
        echo '</div>';
        $i++;
    }
}

echo '</div>';

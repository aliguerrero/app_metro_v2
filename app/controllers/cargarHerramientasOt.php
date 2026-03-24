<?php
require_once __DIR__ . "/../../config/app.php";
require_once __DIR__ . "/../views/inc/session_start.php";
require_once __DIR__ . "/../../autoload.php";

use app\models\mainModel;

ini_set('display_errors', '0');
ini_set('log_errors', '1');
error_reporting(E_ALL);

register_shutdown_function(function () {
  $err = error_get_last();
  if ($err && in_array($err['type'], [E_ERROR, E_PARSE, E_CORE_ERROR, E_COMPILE_ERROR], true)) {
    if (!headers_sent()) {
      header('Content-Type: application/json; charset=utf-8');
      http_response_code(500);
    }
    echo json_encode([
      "ok" => false,
      "error" => "fatal_error",
      "detail" => $err['message'],
      "file" => $err['file'],
      "line" => $err['line'],
    ], JSON_UNESCAPED_UNICODE);
  }
});

function jsonResponse(array $payload, int $status = 200): void
{
  if (!headers_sent()) {
    header('Content-Type: application/json; charset=utf-8');
    http_response_code($status);
  }
  echo json_encode($payload, JSON_UNESCAPED_UNICODE);
  exit();
}

function requirePerm(string $permKey): void
{
  $perms = $_SESSION['permisos'] ?? [];
  if (empty($perms[$permKey]) || (int)$perms[$permKey] !== 1) {
    jsonResponse(["ok" => false, "error" => "permiso_denegado"], 403);
  }
}

function requireAnyPerm(array $permKeys): void
{
  $perms = $_SESSION['permisos'] ?? [];
  foreach ($permKeys as $k) {
    if (!empty($perms[$k]) && (int)$perms[$k] === 1) return;
  }
  jsonResponse(["ok" => false, "error" => "permiso_denegado"], 403);
}

function rq(string $k, string $default = ''): string
{
  if (isset($_POST[$k])) return trim((string)$_POST[$k]);
  if (isset($_GET[$k]))  return trim((string)$_GET[$k]);
  return $default;
}

function isDigits(string $v): bool
{
  return $v !== '' && ctype_digit($v);
}

function detallePkOt(mainModel $m): string
{
  return $m->columnaExiste('detalle_orden', 'id_ai_detalle') ? 'id_ai_detalle' : 'id_detalle';
}

function otEstaFinalizada(mainModel $m, string $ot): bool
{
  $select = ["n_ot"];
  if ($m->columnaExiste('orden_trabajo', 'ot_finalizada')) {
    $select[] = "COALESCE(ot_finalizada, 0) AS ot_finalizada";
  }
  if ($m->columnaExiste('orden_trabajo', 'id_ai_estado')) {
    $select[] = "id_ai_estado";
  }

  $stmt = $m->ejecutarConsultaConParametros(
    "SELECT " . implode(', ', $select) . "
     FROM orden_trabajo
     WHERE n_ot = :ot
       AND std_reg = 1
     LIMIT 1",
    [':ot' => $ot]
  );

  if (!$stmt || $stmt->rowCount() === 0) {
    return false;
  }

  $row = $stmt->fetch(PDO::FETCH_ASSOC);
  if ((int)($row['ot_finalizada'] ?? 0) === 1) {
    return true;
  }

  return isset($row['id_ai_estado']) && $m->estadoOtEsFinalPorId((int)$row['id_ai_estado']);
}

$mainModel = new mainModel();
$estadoHerrCol = $mainModel->herramientaOtEstadoCol();
$estadoHerrExpr = $mainModel->herramientaOtEstadoExpr();
$estadoHerrHotExpr = $mainModel->herramientaOtEstadoExpr('hot');

try {
  // Para ver inventario/asignadas:
  requirePerm('perm_herramienta_view');

  $tipo = rq('tipo', '');
  $ot   = rq('ot', '');
  $q    = rq('q', '');

  if ($tipo === '') {
    jsonResponse(["ok" => false, "error" => "parametros_invalidos"], 400);
  }

  $tipoRequiereOt = in_array($tipo, ['inventario', 'asignadas', 'agregar', 'actualizar', 'quitar'], true);
  if ($tipoRequiereOt && $ot === '') {
    jsonResponse(["ok" => false, "error" => "ot_requerida"], 400);
  }

  $qLike = '%' . $q . '%';

  // =========================
  // GET: INVENTARIO
  // =========================
  if ($tipo === 'inventario' && $_SERVER['REQUEST_METHOD'] === 'GET') {

    $sql = "
            SELECT
                vhd.id_ai_herramienta AS id,
                vhd.nombre_herramienta AS nombre,
                vhd.cantidad_disponible AS disponible_total,
                COALESCE(otq.en_ot, 0) AS en_ot,
                vhd.cantidad_disponible AS disponible_para_agregar
            FROM vw_herramienta_disponibilidad vhd
            LEFT JOIN (
                SELECT id_ai_herramienta, SUM(cantidadot) AS en_ot
                FROM herramientaot
                WHERE n_ot = :ot
                  AND {$estadoHerrExpr} <> 'LIBERADA'
                GROUP BY id_ai_herramienta
            ) otq ON vhd.id_ai_herramienta = otq.id_ai_herramienta
            WHERE (
                    :q = ''
                    OR CAST(vhd.id_ai_herramienta AS CHAR) LIKE :qLike1
                    OR vhd.nombre_herramienta LIKE :qLike2
              )
            ORDER BY vhd.id_ai_herramienta ASC
        ";

    // usa el mÃ©todo que ya tienes en tu mainModel (lo vi en tu herramientaController)
    $st = $mainModel->ejecutarConsultaConParametros($sql, [
      ':ot' => $ot,
      ':q' => $q,
      ':qLike1' => $qLike,
      ':qLike2' => $qLike,
    ]);

    $rows = $st ? $st->fetchAll(PDO::FETCH_ASSOC) : [];
    jsonResponse(["ok" => true, "data" => $rows]);
  }

  // =========================
  // GET: ASIGNADAS (SUMA por herramienta)
  // =========================
  if ($tipo === 'asignadas' && $_SERVER['REQUEST_METHOD'] === 'GET') {

    $sql = "
            SELECT
                hot.id_ai_herramienta AS id,
                h.nombre_herramienta AS nombre,
                SUM(hot.cantidadot) AS cantidad
            FROM herramientaot hot
            INNER JOIN herramienta h ON hot.id_ai_herramienta = h.id_ai_herramienta
            WHERE hot.n_ot = :ot
              AND {$estadoHerrHotExpr} <> 'LIBERADA'
              AND (
                    :q = ''
                    OR CAST(hot.id_ai_herramienta AS CHAR) LIKE :qLike1
                    OR h.nombre_herramienta LIKE :qLike2
              )
            GROUP BY hot.id_ai_herramienta, h.nombre_herramienta
            ORDER BY hot.id_ai_herramienta ASC
        ";

    $st = $mainModel->ejecutarConsultaConParametros($sql, [
      ':ot' => $ot,
      ':q' => $q,
      ':qLike1' => $qLike,
      ':qLike2' => $qLike,
    ]);

    $rows = $st ? $st->fetchAll(PDO::FETCH_ASSOC) : [];
    jsonResponse(["ok" => true, "data" => $rows]);
  }

  // =========================
  // GET: OCUPACIONES POR HERRAMIENTA
  // =========================
  if ($tipo === 'ocupaciones' && $_SERVER['REQUEST_METHOD'] === 'GET') {
    $herrId = rq('herramienta_id', '');
    $detallePk = detallePkOt($mainModel);

    if (!isDigits($herrId)) {
      jsonResponse(["ok" => false, "error" => "herramienta_invalida"], 400);
    }

    $rows = $mainModel->ejecutarProcedimientoTodos(
      "SELECT
          hot.id_ai_herramientaOT,
          hot.id_ai_herramienta,
          h.nombre_herramienta,
          hot.n_ot,
          ot.nombre_trab,
          hot.cantidadot AS cantidad,
          COALESCE(eo.nombre_estado, 'SIN ESTADO') AS estado_ot,
          COALESCE(det.id_user_act, ot.id_user, '') AS tecnico_id,
          COALESCE(emp_det.nombre_empleado, emp_ot.nombre_empleado, 'Sin tecnico asignado') AS tecnico_nombre,
          COALESCE(emp_det.telefono, emp_ot.telefono, '') AS telefono,
          COALESCE(emp_det.correo, emp_ot.correo, '') AS correo,
          COALESCE(emp_det.direccion, emp_ot.direccion, '') AS direccion,
          " . $mainModel->herramientaOtEstadoSelect('hot') . ",
          ot.fecha AS fecha_ot
       FROM herramientaot hot
       INNER JOIN herramienta h
         ON h.id_ai_herramienta = hot.id_ai_herramienta
        AND h.std_reg = 1
       INNER JOIN orden_trabajo ot
         ON ot.n_ot = hot.n_ot
        AND ot.std_reg = 1
       LEFT JOIN estado_ot eo
         ON eo.id_ai_estado = ot.id_ai_estado
       LEFT JOIN (
          SELECT d1.n_ot, d1.id_user_act
          FROM detalle_orden d1
          INNER JOIN (
              SELECT n_ot, MAX({$detallePk}) AS max_id
              FROM detalle_orden
              GROUP BY n_ot
          ) d2
            ON d2.n_ot = d1.n_ot
           AND d2.max_id = d1.{$detallePk}
       ) det
         ON det.n_ot = hot.n_ot
       LEFT JOIN empleado emp_det
         ON emp_det.id_empleado = det.id_user_act
        AND emp_det.std_reg = 1
       LEFT JOIN empleado emp_ot
         ON emp_ot.id_empleado = ot.id_user
        AND emp_ot.std_reg = 1
       WHERE hot.id_ai_herramienta = :hid
         AND {$estadoHerrHotExpr} <> 'LIBERADA'
         AND (
              :q = ''
              OR hot.n_ot LIKE :qLike1
              OR ot.nombre_trab LIKE :qLike2
              OR COALESCE(emp_det.nombre_empleado, emp_ot.nombre_empleado, 'Sin tecnico asignado') LIKE :qLike3
         )
       ORDER BY hot.n_ot ASC, hot.id_ai_herramientaOT ASC",
      [
        ':hid' => (int)$herrId,
        ':q' => $q,
        ':qLike1' => $qLike,
        ':qLike2' => $qLike,
        ':qLike3' => $qLike,
      ]
    );

    jsonResponse(["ok" => true, "data" => $rows]);
  }

  // =========================
  // POST: ACCIONES (agregar/actualizar/quitar)
  // =========================
  if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse(["ok" => false, "error" => "metodo_no_permitido"], 405);
  }

  // Para modificar asignaciÃ³n en OT (ajusta si tienes otro permiso)
  requireAnyPerm(['perm_herramienta_view', 'perm_ot_add_herramienta', 'perm_ot_add_detalle', 'perm_ot_edit']);

  if (otEstaFinalizada($mainModel, $ot)) {
    jsonResponse([
      "ok" => false,
      "tipo" => "simple",
      "icono" => "info",
      "titulo" => "O.T. finalizada",
      "texto" => "La O.T. ya esta finalizada. No se pueden modificar sus herramientas."
    ], 409);
  }

  $herrId = rq('herramienta_id', '');
  $cant   = rq('cant', '');

  if (!isDigits($herrId)) {
    jsonResponse([
      "ok" => false,
      "tipo" => "simple",
      "icono" => "warning",
      "titulo" => "Dato invalido",
      "texto" => "Herramienta invalida."
    ], 400);
  }

  // herramienta existe?
  $stTool = $mainModel->ejecutarConsultaConParametros(
    "SELECT id_ai_herramienta, cantidad, std_reg
         FROM herramienta
         WHERE id_ai_herramienta = :id
         LIMIT 1",
    [':id' => (int)$herrId]
  );

  if (!$stTool || $stTool->rowCount() <= 0) {
    jsonResponse(["ok" => false, "tipo" => "simple", "icono" => "warning", "titulo" => "No encontrada", "texto" => "La herramienta no existe."], 404);
  }

  $tool = $stTool->fetch(PDO::FETCH_ASSOC);
  if ((string)($tool['std_reg'] ?? '0') !== '1') {
    jsonResponse(["ok" => false, "tipo" => "simple", "icono" => "warning", "titulo" => "No disponible", "texto" => "Herramienta deshabilitada."], 409);
  }

  // Cantidad actual en OT (SUMA, por si hay duplicados)
  $stCur = $mainModel->ejecutarConsultaConParametros(
    "SELECT COALESCE(SUM(cantidadot),0) AS cur
         FROM herramientaot
         WHERE n_ot = :ot AND id_ai_herramienta = :hid
           AND {$estadoHerrExpr} <> 'LIBERADA'",
    [':ot' => $ot, ':hid' => (int)$herrId]
  );
  $cur = $stCur ? (int)$stCur->fetchColumn() : 0;

  // Disponibilidad global actual (total - ocupada)
  $stDisp = $mainModel->ejecutarConsultaConParametros(
    "SELECT (h.cantidad - COALESCE(occ.ocupada,0)) AS disp
         FROM herramienta h
         LEFT JOIN (
            SELECT id_ai_herramienta, SUM(cantidadot) AS ocupada
            FROM herramientaot
            WHERE {$estadoHerrExpr} <> 'LIBERADA'
            GROUP BY id_ai_herramienta
         ) occ ON h.id_ai_herramienta = occ.id_ai_herramienta
         WHERE h.id_ai_herramienta = :id AND h.std_reg='1'
         LIMIT 1",
    [':id' => (int)$herrId]
  );
  $disp = ($stDisp && $stDisp->rowCount() > 0) ? (int)$stDisp->fetchColumn() : 0;

  // Helper: deja 1 sola fila por OT+Herr (evita duplicados)
  $normalizarSet = function (int $newQty) use ($mainModel, $ot, $herrId, $estadoHerrExpr, $estadoHerrCol) {
    // borra duplicados
    $mainModel->ejecutarConsultaConParametros(
      "DELETE FROM herramientaot
       WHERE n_ot = :ot AND id_ai_herramienta = :hid
         AND {$estadoHerrExpr} <> 'LIBERADA'",
      [':ot' => $ot, ':hid' => (int)$herrId]
    );
    // inserta una sola
    $mainModel->ejecutarConsultaConParametros(
      "INSERT INTO herramientaot (id_ai_herramienta, n_ot, cantidadot, `{$estadoHerrCol}`)
             VALUES (:hid, :ot, :cant, 'ASIGNADA')",
      [':hid' => (int)$herrId, ':ot' => $ot, ':cant' => $newQty]
    );
  };

  // ========= agregar =========
  if ($tipo === 'agregar') {
    if (!isDigits((string)$cant) || (int)$cant < 1) {
      jsonResponse(["ok" => false, "tipo" => "simple", "icono" => "warning", "titulo" => "Cantidad invalida", "texto" => "Minimo 1."], 400);
    }

    $mainModel->ejecutarProcedimientoFila(
      "CALL sp_ot_asignar_herramienta(:ot, :hid, :cant, :id_user_operacion)",
      [
        ':ot' => $ot,
        ':hid' => (int)$herrId,
        ':cant' => (int)$cant,
        ':id_user_operacion' => (string)($_SESSION['id_user'] ?? $_SESSION['id'] ?? ''),
      ]
    );

    jsonResponse(["ok" => true, "tipo" => "simple", "icono" => "success", "titulo" => "Asignada", "texto" => "Herramienta asignada."]);
  }

  // ========= actualizar =========
  if ($tipo === 'actualizar') {
    if (!isDigits((string)$cant) || (int)$cant < 0) {
      jsonResponse(["ok" => false, "tipo" => "simple", "icono" => "warning", "titulo" => "Cantidad invalida", "texto" => "0 o mas."], 400);
    }
    $new = (int)$cant;

    if ($new === 0) {
      $mainModel->ejecutarConsultaConParametros(
        "DELETE FROM herramientaot
         WHERE n_ot = :ot AND id_ai_herramienta = :hid
           AND {$estadoHerrExpr} <> 'LIBERADA'",
        [':ot' => $ot, ':hid' => (int)$herrId]
      );
      jsonResponse(["ok" => true, "tipo" => "simple", "icono" => "success", "titulo" => "Quitada", "texto" => "Herramienta quitada."]);
    }

    $delta = $new - $cur;
    if ($delta > 0 && $delta > $disp) {
      jsonResponse(["ok" => false, "tipo" => "simple", "icono" => "info", "titulo" => "Sin disponibilidad", "texto" => "No hay disponibilidad para aumentar."], 409);
    }

    $normalizarSet($new);
    jsonResponse(["ok" => true, "tipo" => "simple", "icono" => "success", "titulo" => "Actualizada", "texto" => "Cantidad actualizada."]);
  }

  // ========= quitar =========
  if ($tipo === 'quitar') {
    $mainModel->ejecutarConsultaConParametros(
      "DELETE FROM herramientaot
       WHERE n_ot = :ot AND id_ai_herramienta = :hid
         AND {$estadoHerrExpr} <> 'LIBERADA'",
      [':ot' => $ot, ':hid' => (int)$herrId]
    );
    jsonResponse(["ok" => true, "tipo" => "simple", "icono" => "success", "titulo" => "Quitada", "texto" => "Herramienta quitada."]);
  }

  jsonResponse(["ok" => false, "error" => "tipo_no_soportado"], 400);
} catch (Throwable $e) {
  jsonResponse([
    "ok" => false,
    "error" => "exception",
    "detail" => $e->getMessage()
  ], 500);
}


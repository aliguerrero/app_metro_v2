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

$mainModel = new mainModel();

try {
  // Para ver inventario/asignadas:
  requirePerm('perm_herramienta_view');

  $tipo = rq('tipo', '');
  $ot   = rq('ot', '');
  $q    = rq('q', '');

  if ($tipo === '' || $ot === '') {
    jsonResponse(["ok" => false, "error" => "parametros_invalidos"], 400);
  }

  $qLike = '%' . $q . '%';

  // =========================
  // GET: INVENTARIO
  // =========================
  if ($tipo === 'inventario' && $_SERVER['REQUEST_METHOD'] === 'GET') {

    $sql = "
            SELECT
                h.id_ai_herramienta AS id,
                h.nombre_herramienta AS nombre,
                (h.cantidad - COALESCE(occ.ocupada, 0)) AS disponible_total,
                COALESCE(otq.en_ot, 0) AS en_ot,
                (h.cantidad - COALESCE(occ.ocupada, 0)) AS disponible_para_agregar
            FROM herramienta h
            LEFT JOIN (
                SELECT id_ai_herramienta, SUM(cantidadot) AS ocupada
                FROM herramientaot
                GROUP BY id_ai_herramienta
            ) occ ON h.id_ai_herramienta = occ.id_ai_herramienta
            LEFT JOIN (
                SELECT id_ai_herramienta, SUM(cantidadot) AS en_ot
                FROM herramientaot
                WHERE n_ot = :ot
                GROUP BY id_ai_herramienta
            ) otq ON h.id_ai_herramienta = otq.id_ai_herramienta
            WHERE h.std_reg = '1'
              AND (
                    :q = ''
                    OR CAST(h.id_ai_herramienta AS CHAR) LIKE :qLike1
                    OR h.nombre_herramienta LIKE :qLike2
              )
            ORDER BY h.id_ai_herramienta ASC
        ";

    // usa el método que ya tienes en tu mainModel (lo vi en tu herramientaController)
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
  // POST: ACCIONES (agregar/actualizar/quitar)
  // =========================
  if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse(["ok" => false, "error" => "metodo_no_permitido"], 405);
  }

  // Para modificar asignación en OT (ajusta si tienes otro permiso)
  requireAnyPerm(['perm_herramienta_view', 'perm_ot_add_herramienta', 'perm_ot_add_detalle', 'perm_ot_edit']);

  $herrId = rq('herramienta_id', '');
  $cant   = rq('cant', '');

  if (!isDigits($herrId)) {
    jsonResponse([
      "ok" => false,
      "tipo" => "simple",
      "icono" => "warning",
      "titulo" => "Dato inválido",
      "texto" => "Herramienta inválida."
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
         WHERE n_ot = :ot AND id_ai_herramienta = :hid",
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
            GROUP BY id_ai_herramienta
         ) occ ON h.id_ai_herramienta = occ.id_ai_herramienta
         WHERE h.id_ai_herramienta = :id AND h.std_reg='1'
         LIMIT 1",
    [':id' => (int)$herrId]
  );
  $disp = ($stDisp && $stDisp->rowCount() > 0) ? (int)$stDisp->fetchColumn() : 0;

  // Helper: deja 1 sola fila por OT+Herr (evita duplicados)
  $normalizarSet = function (int $newQty) use ($mainModel, $ot, $herrId) {
    // borra duplicados
    $mainModel->ejecutarConsultaConParametros(
      "DELETE FROM herramientaot WHERE n_ot = :ot AND id_ai_herramienta = :hid",
      [':ot' => $ot, ':hid' => (int)$herrId]
    );
    // inserta una sola
    $mainModel->ejecutarConsultaConParametros(
      "INSERT INTO herramientaot (id_ai_herramienta, n_ot, cantidadot, estadoot)
             VALUES (:hid, :ot, :cant, NULL)",
      [':hid' => (int)$herrId, ':ot' => $ot, ':cant' => $newQty]
    );
  };

  // ========= agregar =========
  if ($tipo === 'agregar') {
    if (!isDigits((string)$cant) || (int)$cant < 1) {
      jsonResponse(["ok" => false, "tipo" => "simple", "icono" => "warning", "titulo" => "Cantidad inválida", "texto" => "Mínimo 1."], 400);
    }
    $add = (int)$cant;

    // Para agregar solo importa lo nuevo contra la disponibilidad actual
    if ($add > $disp) {
      jsonResponse(["ok" => false, "tipo" => "simple", "icono" => "info", "titulo" => "Sin disponibilidad", "texto" => "No hay cantidad suficiente."], 409);
    }

    $new = $cur + $add;
    $normalizarSet($new);

    jsonResponse(["ok" => true, "tipo" => "simple", "icono" => "success", "titulo" => "Asignada", "texto" => "Herramienta asignada."]);
  }

  // ========= actualizar =========
  if ($tipo === 'actualizar') {
    if (!isDigits((string)$cant) || (int)$cant < 0) {
      jsonResponse(["ok" => false, "tipo" => "simple", "icono" => "warning", "titulo" => "Cantidad inválida", "texto" => "0 o más."], 400);
    }
    $new = (int)$cant;

    if ($new === 0) {
      $mainModel->ejecutarConsultaConParametros(
        "DELETE FROM herramientaot WHERE n_ot = :ot AND id_ai_herramienta = :hid",
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
      "DELETE FROM herramientaot WHERE n_ot = :ot AND id_ai_herramienta = :hid",
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

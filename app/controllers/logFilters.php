<?php
require_once __DIR__ . "/securityBootstrap.php";

use app\controllers\configController;

appsec_require_admin();
header('Content-Type: application/json; charset=utf-8');

try {
    $ins = new configController();

    $tablas = [];
    $usuarios = [];

    $stmtT = $ins->ejecutarConsultas("SELECT DISTINCT tabla FROM log_user ORDER BY tabla ASC");
    if ($stmtT) {
        while ($row = $stmtT->fetch(PDO::FETCH_ASSOC)) {
            if (!empty($row['tabla'])) {
                $tablas[] = $row['tabla'];
            }
        }
    }

    $stmtU = $ins->ejecutarConsultas("SELECT DISTINCT id_user FROM log_user WHERE id_user IS NOT NULL AND id_user <> '' ORDER BY id_user ASC");
    if ($stmtU) {
        while ($row = $stmtU->fetch(PDO::FETCH_ASSOC)) {
            if (!empty($row['id_user'])) {
                $usuarios[] = $row['id_user'];
            }
        }
    }

    appsec_json_response([
        'ok' => true,
        'tablas' => $tablas,
        'usuarios' => $usuarios,
    ]);
} catch (Throwable $e) {
    appsec_json_response([
        'ok' => false,
        'msg' => 'Error interno',
        'detail' => $e->getMessage(),
    ], 500);
}

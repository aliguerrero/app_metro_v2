<?php
require_once __DIR__ . "/securityBootstrap.php";

use app\controllers\reporteGeneradoController;

appsec_require_perm('perm_ot_generar_reporte');

$id = (int)appsec_request_string('id', '0');
$action = strtolower(appsec_request_string('action', 'download'));
$mode = $action === 'view' ? 'view' : 'download';

if ($id <= 0) {
    http_response_code(400);
    echo 'ID de reporte invalido.';
    exit();
}

try {
    $ins = new reporteGeneradoController();
    $ins->emitirReporteGuardado($id, $mode);
    exit();
} catch (Throwable $e) {
    http_response_code(404);
    echo 'No se pudo abrir el reporte solicitado.';
    exit();
}

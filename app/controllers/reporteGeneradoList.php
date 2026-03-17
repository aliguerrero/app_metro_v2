<?php
require_once __DIR__ . "/securityBootstrap.php";

use app\controllers\reporteGeneradoController;

appsec_require_perm('perm_ot_generar_reporte');

header('Content-Type: text/html; charset=utf-8');

try {
    $ins = new reporteGeneradoController();
    echo $ins->listarReportesGeneradosHtml();
} catch (Throwable $e) {
    echo '<div class="alert alert-danger m-3 mb-0">No se pudo cargar el historial de reportes generados.</div>';
}

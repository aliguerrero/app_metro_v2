<?php
require_once __DIR__ . "/../controllers/securityBootstrap.php";

use app\controllers\empresaConfigController;

appsec_require_login();
appsec_require_admin();

header('Content-Type: application/json; charset=utf-8');

$insEmpresa = new empresaConfigController();
$modulo = appsec_clean_string(appsec_request_string('modulo_empresa'));

if ($modulo === "obtener") {
    echo $insEmpresa->obtenerEmpresaControlador();
    exit;
}

if ($modulo === "actualizar") {
    appsec_require_method('POST');
    echo $insEmpresa->actualizarEmpresaControlador();
    exit;
}

appsec_fail('El modulo solicitado no es valido.', 400, ['error' => 'accion_invalida']);

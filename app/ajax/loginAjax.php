<?php

require_once __DIR__ . "/../controllers/securityBootstrap.php";

use app\controllers\loginController;

appsec_require_method('POST');

header('Content-Type: application/json; charset=utf-8');

$modulo = appsec_clean_string(appsec_request_string('modulo_login'));

if ($modulo === 'recuperar_clave') {
    $insLogin = new loginController();
    echo $insLogin->recuperarClaveControlador();
    exit;
}

appsec_fail('El modulo solicitado no es valido.', 400, ['error' => 'accion_invalida']);


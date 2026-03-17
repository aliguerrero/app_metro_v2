<?php

require_once __DIR__ . "/../controllers/securityBootstrap.php";

use app\controllers\smtpConfigController;

appsec_require_login();
appsec_require_admin();

header('Content-Type: application/json; charset=utf-8');

$insSmtp = new smtpConfigController();
$modulo = appsec_clean_string(appsec_request_string('modulo_smtp'));

if ($modulo === 'obtener') {
    appsec_require_method('GET');
    echo $insSmtp->obtenerSmtpControlador();
    exit;
}

if ($modulo === 'guardar') {
    appsec_require_method('POST');
    echo $insSmtp->guardarSmtpControlador();
    exit;
}

if ($modulo === 'probar') {
    appsec_require_method('POST');
    echo $insSmtp->probarEnvioSmtpControlador();
    exit;
}

appsec_fail('El modulo solicitado no es valido.', 400, ['error' => 'accion_invalida']);


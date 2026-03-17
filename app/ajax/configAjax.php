<?php
require_once __DIR__ . "/../controllers/securityBootstrap.php";

appsec_require_method('POST');
appsec_require_admin();

use app\controllers\configController;

$accion = appsec_request_string('modulo_rol');
if ($accion === '') {
    appsec_fail('Accion no valida.', 400, ['error' => 'accion_invalida']);
}

$insConfig = new configController();

switch ($accion) {
    case 'registrar_rol':
        echo $insConfig->registrarRolControlador();
        break;

    case 'modificar_rol':
        echo $insConfig->ModificarRolControlador();
        break;

    case 'eliminar_rol':
        echo $insConfig->eliminarRolControlador();
        break;

    case 'registrar_area':
        echo $insConfig->registrarAreaControlador();
        break;

    case 'eliminar_area':
        echo $insConfig->eliminarAreaControlador();
        break;

    case 'registrar_sitio':
        echo $insConfig->registrarSitioControlador();
        break;

    case 'eliminar_sitio':
        echo $insConfig->eliminarSitioControlador();
        break;

    case 'registrar_turno':
        echo $insConfig->registrarTurnoControlador();
        break;

    default:
        appsec_fail('Accion no valida.', 400, ['error' => 'accion_invalida']);
}

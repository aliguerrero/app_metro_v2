<?php
require_once __DIR__ . "/securityBootstrap.php";

appsec_require_perm('perm_ot_add_detalle');
appsec_fail(
    'El endpoint legacy registrarDetalle.php fue deshabilitado por seguridad. Usa cargarDatosDetalle.php.',
    410,
    ['error' => 'endpoint_obsoleto']
);

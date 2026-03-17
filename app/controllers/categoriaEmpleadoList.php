<?php
require_once __DIR__ . "/securityBootstrap.php";

use app\controllers\empleadoController;

appsec_require_admin();

$insEmpleado = new empleadoController();
echo $insEmpleado->listarCategoriaEmpleadoControlador();

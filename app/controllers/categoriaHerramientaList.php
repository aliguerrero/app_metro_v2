<?php
require_once __DIR__ . "/securityBootstrap.php";

use app\controllers\herramientaController;

appsec_require_admin();

$insHerramienta = new herramientaController();
echo $insHerramienta->listarCategoriaHerramientaControlador();

<?php
require 'C:/xampp/htdocs/app_metro/config/app.php';
require 'C:/xampp/htdocs/app_metro/autoload.php';
$_SESSION = [];
$ctrl = new \app\controllers\loginController();
$ctrl->asegurarRolRootControlador();
echo 'BOOTSTRAP_REQUIRED=' . ($ctrl->sistemaRequiereBootstrapControlador() ? '1' : '0') . PHP_EOL;
?>

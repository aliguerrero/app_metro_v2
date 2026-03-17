<?php
require_once "../../config/app.php";
require_once "../views/inc/session_start.php";
require_once "../../autoload.php";

use app\controllers\configController;

$ins = new configController();
echo $ins->listarAreaControlador("");

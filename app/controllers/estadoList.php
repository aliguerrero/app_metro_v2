<?php
require_once "../../config/app.php";
require_once "../views/inc/session_start.php";
require_once "../../autoload.php";

use app\controllers\configController;

$perms = $_SESSION['permisos'] ?? [];
if (empty($perms['perm_ot_view']) || (int)$perms['perm_ot_view'] !== 1) {
    echo '<div class="alert alert-danger m-3">Permiso denegado.</div>';
    exit();
}

$insConfig = new configController();
echo $insConfig->listarEstadoControlador("");

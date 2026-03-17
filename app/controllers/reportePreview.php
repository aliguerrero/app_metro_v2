<?php
require_once "../../config/app.php";
require_once "../views/inc/session_start.php";
require_once "../../autoload.php";

use app\controllers\reporteController;

if (!isset($_SESSION['id'])) {
    http_response_code(401);
    echo "No autorizado";
    exit;
}

$tipo = $_GET['tipo'] ?? 'ot';

$ins = new reporteController();

header("Content-Type: text/html; charset=utf-8");

if ($tipo === 'ot') {
    echo $ins->renderOtHtml($_GET);
    exit;
}

echo "<html><body>Tipo de reporte no soportado</body></html>";

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

if ($tipo === 'ot') {
    // IMPORTANTE: no imprimir nada antes (ni espacios) para que el PDF no se corrompa
    $ins->outputOtPdf($_GET);
    exit;
}

http_response_code(400);
echo "Tipo de reporte no soportado";

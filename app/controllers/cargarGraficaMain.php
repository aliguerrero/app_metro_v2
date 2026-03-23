<?php
require_once __DIR__ . "/securityBootstrap.php";

appsec_require_login();

$mainModel = appsec_main_model();
$stmt = $mainModel->ejecutarConsultas(
    "SELECT nombre_estado, COUNT(1) AS total_registros
     FROM vw_ot_resumen
     WHERE std_reg = 1
     GROUP BY id_ai_estado, nombre_estado"
);

$rows = $stmt ? $stmt->fetchAll(PDO::FETCH_ASSOC) : [];
appsec_json_response($rows);

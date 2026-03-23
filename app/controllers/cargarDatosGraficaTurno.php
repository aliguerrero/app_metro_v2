<?php
require_once __DIR__ . "/securityBootstrap.php";

appsec_require_login();

$mainModel = appsec_main_model();
$stmt = $mainModel->ejecutarConsultas(
    "SELECT nombre_turno,
            COUNT(id_ai_detalle) AS total_registros,
            ROUND((COUNT(id_ai_detalle) * 100.0) / SUM(COUNT(id_ai_detalle)) OVER (), 2) AS porcentaje_total
     FROM vw_ot_detallada
     GROUP BY id_ai_turno, nombre_turno"
);

$rows = $stmt ? $stmt->fetchAll(PDO::FETCH_ASSOC) : [];
appsec_json_response($rows);

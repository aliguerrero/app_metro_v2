<?php
require_once __DIR__ . "/securityBootstrap.php";

appsec_require_login();

$mainModel = appsec_main_model();
$stmt = $mainModel->ejecutarConsultas(
    "SELECT e.nombre_estado, COUNT(ot.id_ai_estado) AS total_registros
     FROM detalle_orden ot
     JOIN estado_ot e ON ot.id_ai_estado = e.id_ai_estado
     GROUP BY ot.id_ai_estado"
);

$rows = $stmt ? $stmt->fetchAll(PDO::FETCH_ASSOC) : [];
appsec_json_response($rows);

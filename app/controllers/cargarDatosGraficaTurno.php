<?php
require_once __DIR__ . "/securityBootstrap.php";

appsec_require_login();

$mainModel = appsec_main_model();
$stmt = $mainModel->ejecutarConsultas(
    "SELECT e.nombre_turno,
            COUNT(ot.id_ai_turno) AS total_registros,
            ROUND((COUNT(ot.id_ai_turno) * 100.0) / SUM(COUNT(ot.id_ai_turno)) OVER (), 2) AS porcentaje_total
     FROM detalle_orden ot
     JOIN turno_trabajo e ON ot.id_ai_turno = e.id_ai_turno
     GROUP BY ot.id_ai_turno, e.nombre_turno"
);

$rows = $stmt ? $stmt->fetchAll(PDO::FETCH_ASSOC) : [];
appsec_json_response($rows);

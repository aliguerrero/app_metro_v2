<?php
require_once __DIR__ . "/securityBootstrap.php";

appsec_require_login();

$mainModel = appsec_main_model();
$stmt = $mainModel->ejecutarConsultas("SELECT " . $mainModel->columnasTablaSql('area_trabajo') . " FROM area_trabajo WHERE std_reg = 1 ORDER BY id_ai_area ASC");

$rows = $stmt ? $stmt->fetchAll(PDO::FETCH_ASSOC) : [];
appsec_json_response($rows);

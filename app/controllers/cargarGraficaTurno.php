<?php
require_once __DIR__ . "/securityBootstrap.php";

appsec_require_login();

$mainModel = appsec_main_model();
$stmt = $mainModel->ejecutarConsultas("SELECT " . $mainModel->columnasTablaSql('turno_trabajo') . " FROM turno_trabajo WHERE std_reg = 1 ORDER BY id_ai_turno ASC");

$rows = $stmt ? $stmt->fetchAll(PDO::FETCH_ASSOC) : [];
appsec_json_response($rows);

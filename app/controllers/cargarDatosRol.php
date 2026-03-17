<?php
require_once __DIR__ . "/securityBootstrap.php";

appsec_require_method('POST');
appsec_require_admin();

$mainModel = appsec_main_model();
$id = appsec_clean_string(appsec_request_string('id'));

if (!appsec_is_digits($id)) {
    appsec_fail('ID de rol invalido.', 400, ['error' => 'id_invalido']);
}

$stmt = $mainModel->ejecutarConsultaConParametros(
    "SELECT " . $mainModel->columnasTablaSql('roles_permisos') . " FROM roles_permisos WHERE id = :id LIMIT 1",
    [':id' => (int)$id]
);

$data = [];
if ($stmt && $stmt->rowCount() > 0) {
    $data = $stmt->fetch(PDO::FETCH_ASSOC);
}

appsec_json_response($data);

<?php
require_once __DIR__ . "/securityBootstrap.php";

appsec_require_method('POST');
appsec_require_perm('perm_usuarios_view');

$mainModel = appsec_main_model();
$id = appsec_clean_string(appsec_request_string('id'));

if ($id === '') {
    appsec_fail('ID de usuario invalido.', 400, ['error' => 'id_invalido']);
}

$stmt = $mainModel->ejecutarConsultaConParametros(
    "SELECT
        u.id_ai_user,
        u.id_empleado AS id_user,
        u.username,
        u.tipo,
        u.std_reg,
        COALESCE(NULLIF(e.nombre_empleado, ''), u.id_empleado) AS nombre_empleado,
        e.id_ai_categoria_empleado,
        COALESCE(c.nombre_categoria, 'SIN CATEGORIA') AS nombre_categoria
     FROM user_system u
     LEFT JOIN empleado e
       ON e.id_empleado = u.id_empleado
     LEFT JOIN categoria_empleado c
       ON c.id_ai_categoria_empleado = e.id_ai_categoria_empleado
     WHERE u.id_empleado = :id
     AND u.std_reg = 1
     LIMIT 1",
    [':id' => $id]
);

$data = [];
if ($stmt && $stmt->rowCount() > 0) {
    $data = $stmt->fetch(PDO::FETCH_ASSOC);
}

appsec_json_response($data);

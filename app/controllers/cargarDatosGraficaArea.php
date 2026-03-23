<?php
require_once __DIR__ . "/securityBootstrap.php";

appsec_require_login();

$mainModel = appsec_main_model();
$id = appsec_clean_string(appsec_request_string('id'));

if (!appsec_is_digits($id)) {
    appsec_fail('ID de area invalido.', 400, ['error' => 'id_invalido']);
}

$stmt = $mainModel->ejecutarConsultaConParametros(
    "SELECT nombre_estado,
            COUNT(1) AS total_ordenes,
            ROUND(
                COUNT(1) * 100.0 /
                NULLIF((SELECT COUNT(1) FROM vw_ot_resumen WHERE id_ai_area = :area_total AND std_reg = 1), 0),
                2
            ) AS porcentaje_total
     FROM vw_ot_resumen
     WHERE id_ai_area = :area
       AND std_reg = 1
     GROUP BY id_ai_estado, nombre_estado",
    [
        ':area_total' => (int)$id,
        ':area' => (int)$id,
    ]
);

$rows = $stmt ? $stmt->fetchAll(PDO::FETCH_ASSOC) : [];
appsec_json_response($rows);

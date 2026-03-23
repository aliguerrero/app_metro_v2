<?php
require_once __DIR__ . "/securityBootstrap.php";

appsec_require_login();

$mainModel = appsec_main_model();
$id = appsec_clean_string(appsec_request_string('id'));

if (!appsec_is_digits($id)) {
    appsec_fail('ID de turno invalido.', 400, ['error' => 'id_invalido']);
}

$stmt = $mainModel->ejecutarConsultaConParametros(
    "SELECT estado_ot AS nombre_estado,
            COUNT(DISTINCT n_ot) AS total_ordenes,
            ROUND(
                COUNT(DISTINCT n_ot) * 100.0 /
                NULLIF((
                    SELECT COUNT(DISTINCT n_ot)
                    FROM vw_ot_detallada
                    WHERE id_ai_turno = :turno_total
                ), 0),
                2
            ) AS porcentaje_total
     FROM vw_ot_detallada
     WHERE id_ai_turno = :turno
     GROUP BY id_ai_estado, estado_ot",
    [
        ':turno_total' => (int)$id,
        ':turno' => (int)$id,
    ]
);

$rows = $stmt ? $stmt->fetchAll(PDO::FETCH_ASSOC) : [];
appsec_json_response($rows);

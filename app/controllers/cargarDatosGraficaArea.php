<?php
require_once __DIR__ . "/securityBootstrap.php";

appsec_require_login();

$mainModel = appsec_main_model();
$id = appsec_clean_string(appsec_request_string('id'));

if (!appsec_is_digits($id)) {
    appsec_fail('ID de turno invalido.', 400, ['error' => 'id_invalido']);
}

$stmt = $mainModel->ejecutarConsultaConParametros(
    "SELECT e.nombre_estado,
            COUNT(dord.id_ai_estado) AS total_ordenes,
            ROUND(
                COUNT(dord.id_ai_estado) * 100.0 /
                NULLIF((SELECT COUNT(1) FROM detalle_orden WHERE id_ai_turno = :turno_total), 0),
                2
            ) AS porcentaje_total
     FROM detalle_orden dord
     JOIN turno_trabajo tu ON dord.id_ai_turno = tu.id_ai_turno
     JOIN estado_ot e ON dord.id_ai_estado = e.id_ai_estado
     WHERE dord.id_ai_turno = :turno
     GROUP BY dord.id_ai_estado, e.nombre_estado",
    [
        ':turno_total' => (int)$id,
        ':turno' => (int)$id,
    ]
);

$rows = $stmt ? $stmt->fetchAll(PDO::FETCH_ASSOC) : [];
appsec_json_response($rows);


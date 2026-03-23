<?php
require_once __DIR__ . "/securityBootstrap.php";

appsec_require_perm('perm_ot_view');

$mainModel = appsec_main_model();
$tipoBusqueda = appsec_clean_string(appsec_request_string('tipoBusqueda', 'todo'));
$params = [];
$sql = "
    SELECT
        ot.n_ot,
        ot.fecha,
        ot.nombre_trab,
        ot.id_ai_estado,
        ot.nombre_estado,
        ot.color_estado AS color,
        COALESCE(ot.herramientas_activas, 0) AS herramientas_activas,
        CASE
            WHEN COALESCE(ot.ot_finalizada, 0) = 1 OR COALESCE(ot.bloquea_ot, 0) = 1 THEN 1
            ELSE 0
        END AS ot_finalizada,
        ot.area_nomeclatura
    FROM vw_ot_resumen ot
    WHERE ot.std_reg = 1
";

switch ($tipoBusqueda) {
    case 'ot':
        $id = appsec_clean_string(appsec_request_string('id'));
        if ($id === '') {
            appsec_fail('Codigo de OT invalido.', 400, ['error' => 'id_invalido']);
        }
        $sql .= " AND ot.n_ot = :id";
        $params[':id'] = $id;
        break;

    case 'fecha':
        $fechaI = appsec_clean_string(appsec_request_string('fechaI'));
        $fechaF = appsec_clean_string(appsec_request_string('fechaF'));
        $area = appsec_clean_string(appsec_request_string('area', 'Seleccionar'));

        if (!appsec_is_valid_date($fechaI) || !appsec_is_valid_date($fechaF)) {
            appsec_fail('Rango de fechas invalido.', 400, ['error' => 'fecha_invalida']);
        }

        $sql .= " AND ot.fecha BETWEEN :fecha_i AND :fecha_f";
        $params[':fecha_i'] = $fechaI;
        $params[':fecha_f'] = $fechaF;

        if ($area !== '' && $area !== 'Seleccionar') {
            $sql .= " AND ot.area_nomeclatura = :area";
            $params[':area'] = $area;
        }
        break;

    case 'estado':
        $estado = appsec_clean_string(appsec_request_string('estado'));
        $area = appsec_clean_string(appsec_request_string('area', 'Seleccionar'));

        if (!appsec_is_digits($estado)) {
            appsec_fail('Estado invalido.', 400, ['error' => 'estado_invalido']);
        }

        $sql .= " AND ot.id_ai_estado = :estado";
        $params[':estado'] = (int)$estado;

        if ($area !== '' && $area !== 'Seleccionar') {
            $sql .= " AND ot.area_nomeclatura = :area";
            $params[':area'] = $area;
        }
        break;

    case 'user':
        $user = appsec_clean_string(appsec_request_string('user'));
        $area = appsec_clean_string(appsec_request_string('area', 'Seleccionar'));

        if (!appsec_is_digits($user)) {
            appsec_fail('Usuario invalido.', 400, ['error' => 'usuario_invalido']);
        }

        $sql .= " AND EXISTS (
            SELECT 1
            FROM vw_ot_detallada det
            WHERE det.n_ot = ot.n_ot
              AND det.id_user_act = :user
        )";
        $params[':user'] = (int)$user;

        if ($area !== '' && $area !== 'Seleccionar') {
            $sql .= " AND ot.area_nomeclatura = :area";
            $params[':area'] = $area;
        }
        break;

    case 'todo':
        break;

    default:
        appsec_fail('Tipo de busqueda no valido.', 400, ['error' => 'tipo_busqueda_invalido']);
}

$sql .= " ORDER BY ot.n_ot ASC";

$stmt = $mainModel->ejecutarConsultaConParametros($sql, $params);
$rows = $stmt ? $stmt->fetchAll(PDO::FETCH_ASSOC) : [];

appsec_json_response($rows);

<?php
require_once __DIR__ . "/securityBootstrap.php";

appsec_require_perm('perm_ot_view');

$mainModel = appsec_main_model();
$tipoBusqueda = appsec_clean_string(appsec_request_string('tipoBusqueda', 'todo'));
$otCols = $mainModel->columnasTablaSql('orden_trabajo', 'ot');

$subDetalle = "
    SELECT n_ot,
           MAX(id_ai_estado) AS id_ai_estado,
           MAX(id_user_act) AS id_user_act
    FROM detalle_orden
    GROUP BY n_ot
";

$params = [];
$sql = "
    SELECT {$otCols}, eo.nombre_estado, eo.color
    FROM orden_trabajo ot
    LEFT JOIN ({$subDetalle}) det ON ot.n_ot = det.n_ot
    LEFT JOIN estado_ot eo ON det.id_ai_estado = eo.id_ai_estado
    LEFT JOIN area_trabajo ae ON ot.id_ai_area = ae.id_ai_area
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
            $sql .= " AND ae.nomeclatura = :area";
            $params[':area'] = $area;
        }
        break;

    case 'estado':
        $estado = appsec_clean_string(appsec_request_string('estado'));
        $area = appsec_clean_string(appsec_request_string('area', 'Seleccionar'));

        if (!appsec_is_digits($estado)) {
            appsec_fail('Estado invalido.', 400, ['error' => 'estado_invalido']);
        }

        $sql .= " AND det.id_ai_estado = :estado";
        $params[':estado'] = (int)$estado;

        if ($area !== '' && $area !== 'Seleccionar') {
            $sql .= " AND ae.nomeclatura = :area";
            $params[':area'] = $area;
        }
        break;

    case 'user':
        $user = appsec_clean_string(appsec_request_string('user'));
        $area = appsec_clean_string(appsec_request_string('area', 'Seleccionar'));

        if (!appsec_is_digits($user)) {
            appsec_fail('Usuario invalido.', 400, ['error' => 'usuario_invalido']);
        }

        $sql .= " AND det.id_user_act = :user";
        $params[':user'] = (int)$user;

        if ($area !== '' && $area !== 'Seleccionar') {
            $sql .= " AND ae.nomeclatura = :area";
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

<?php
require_once __DIR__ . "/securityBootstrap.php";

$mainModel = appsec_main_model();
$tipoBusqueda = appsec_clean_string(appsec_request_string('tipoBusqueda', 'todo'));
$sessionUserId = appsec_session_user_id();

if ($tipoBusqueda === 'eliminar') {
    appsec_require_method('POST');
    appsec_require_perm('perm_usuarios_delete');

    $id = appsec_clean_string(appsec_request_string('id'));
    if ($id === '' || $id === $sessionUserId) {
        appsec_fail('ID de usuario invalido.', 400, ['error' => 'id_invalido']);
    }

    $stmt = $mainModel->ejecutarConsultaConParametros(
        "UPDATE user_system
         SET std_reg = 0
         WHERE id_empleado = :id
           AND id_empleado <> :session_user
           AND std_reg = 1",
        [
            ':id' => $id,
            ':session_user' => $sessionUserId,
        ]
    );

    appsec_json_response([
        'ok' => $stmt && $stmt->rowCount() > 0,
    ]);
}

appsec_require_perm('perm_usuarios_view');

$params = [
    ':session_user' => $sessionUserId,
];

$sql = "
    SELECT
        u.id_ai_user,
        u.id_empleado AS id_user,
        COALESCE(NULLIF(e.nombre_empleado, ''), u.id_empleado) AS nombre_empleado,
        COALESCE(c.nombre_categoria, 'SIN CATEGORIA') AS nombre_categoria,
        u.username,
        u.tipo,
        r.nombre_rol
    FROM user_system u
    LEFT JOIN empleado e
      ON e.id_empleado = u.id_empleado
    LEFT JOIN categoria_empleado c
      ON c.id_ai_categoria_empleado = e.id_ai_categoria_empleado
    JOIN roles_permisos r ON u.tipo = r.id
    WHERE u.id_empleado <> :session_user
      AND u.std_reg = 1
";

if ($tipoBusqueda === 'id') {
    $term = appsec_clean_string(appsec_request_string('id'));
    $sql .= "
      AND (
            u.id_empleado LIKE :term
         OR COALESCE(NULLIF(e.nombre_empleado, ''), u.id_empleado) LIKE :term
         OR COALESCE(c.nombre_categoria, '') LIKE :term
         OR u.username LIKE :term
         OR r.nombre_rol LIKE :term
      )
    ";
    $params[':term'] = '%' . $term . '%';
}

$sql .= " ORDER BY COALESCE(NULLIF(e.nombre_empleado, ''), u.id_empleado) ASC";

$stmt = $mainModel->ejecutarConsultaConParametros($sql, $params);
$rows = $stmt ? $stmt->fetchAll(PDO::FETCH_ASSOC) : [];

appsec_json_response($rows);

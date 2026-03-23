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
        id_ai_user,
        id_empleado AS id_user,
        COALESCE(NULLIF(nombre_empleado, ''), id_empleado) AS nombre_empleado,
        COALESCE(categoria_empleado, 'SIN CATEGORIA') AS nombre_categoria,
        username,
        id_rol AS tipo,
        nombre_rol
    FROM vw_usuario_empleado
    WHERE id_empleado <> :session_user
      AND std_reg = 1
";

if ($tipoBusqueda === 'id') {
    $term = appsec_clean_string(appsec_request_string('id'));
    $sql .= "
      AND (
            id_empleado LIKE :term_id
         OR COALESCE(NULLIF(nombre_empleado, ''), id_empleado) LIKE :term_nombre
         OR COALESCE(categoria_empleado, '') LIKE :term_categoria
         OR username LIKE :term_username
         OR nombre_rol LIKE :term_rol
      )
    ";
    $like = '%' . $term . '%';
    $params[':term_id'] = $like;
    $params[':term_nombre'] = $like;
    $params[':term_categoria'] = $like;
    $params[':term_username'] = $like;
    $params[':term_rol'] = $like;
}

$sql .= " ORDER BY COALESCE(NULLIF(nombre_empleado, ''), id_empleado) ASC";

$stmt = $mainModel->ejecutarConsultaConParametros($sql, $params);
$rows = $stmt ? $stmt->fetchAll(PDO::FETCH_ASSOC) : [];

appsec_json_response($rows);

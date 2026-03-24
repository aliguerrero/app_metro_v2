<?php
require_once __DIR__ . "/securityBootstrap.php";

use app\controllers\empleadoController;

appsec_require_method('POST');
appsec_require_admin();

$insEmpleado = new empleadoController();
$action = appsec_clean_string(appsec_request_string('action'));

if ($action === '') {
    appsec_fail('Accion no valida.', 400, ['error' => 'accion_invalida']);
}

$idPattern = '/^[a-zA-Z0-9-]{3,30}$/';
$nombrePattern = '/^[\p{L}0-9 .-]{3,100}$/u';
$telefonoPattern = '/^[0-9()+ -]{10,20}$/';

$normalizarNacionalidad = static function (string $nacionalidad): string {
    $nacionalidad = strtoupper(trim($nacionalidad));
    return in_array($nacionalidad, ['V', 'E'], true) ? $nacionalidad : '';
};

$normalizarTelefono = static function (string $telefono): string {
    $telefono = preg_replace('/\s+/u', ' ', trim($telefono));
    return is_string($telefono) ? $telefono : '';
};

$telefonoEsValido = static function (string $telefono) use ($telefonoPattern): bool {
    if ($telefono === '') {
        return true;
    }

    if (!preg_match($telefonoPattern, $telefono)) {
        return false;
    }

    $digitos = preg_replace('/\D+/', '', $telefono);
    $totalDigitos = is_string($digitos) ? strlen($digitos) : 0;

    return $totalDigitos >= 10 && $totalDigitos <= 15;
};

$normalizarDireccion = static function (string $direccion): ?string {
    $direccion = trim($direccion);
    return $direccion !== '' ? mb_strtoupper($direccion, 'UTF-8') : null;
};

$normalizarCorreo = static function (string $correo): ?string {
    $correo = trim($correo);
    return $correo !== '' ? mb_strtolower($correo, 'UTF-8') : null;
};

try {
    switch ($action) {
        case 'get':
            $id = (int)appsec_clean_string(appsec_request_string('id_ai_empleado'));
            if ($id <= 0) {
                appsec_fail('ID invalido.', 400, ['error' => 'id_invalido']);
            }

            $row = $insEmpleado->obtenerEmpleadoPorPk($id);
            if (!$row) {
                appsec_fail('Empleado no encontrado.', 404, ['error' => 'no_encontrado']);
            }

            appsec_json_response(['ok' => true, 'data' => $row]);
            break;

        case 'create':
            $idEmpleado = appsec_clean_string(appsec_request_string('id_empleado'));
            $nacionalidad = $normalizarNacionalidad(appsec_clean_string(appsec_request_string('nacionalidad')));
            $nombre = appsec_clean_string(appsec_request_string('nombre_empleado'));
            $telefono = $normalizarTelefono(appsec_clean_string(appsec_request_string('telefono')));
            $direccion = appsec_clean_string(appsec_request_string('direccion'));
            $correo = appsec_request_string('correo');
            $idCategoria = (int)appsec_clean_string(appsec_request_string('id_ai_categoria_empleado'));

            if ($idEmpleado === '' || $nombre === '' || $idCategoria <= 0) {
                appsec_fail('Debes completar todos los campos obligatorios.', 400, ['error' => 'datos_invalidos']);
            }

            if (!preg_match($idPattern, $idEmpleado)) {
                appsec_fail('La cedula del empleado no cumple con el formato solicitado.', 400, ['error' => 'id_invalido']);
            }

            if ($nacionalidad === '') {
                appsec_fail('Debes seleccionar una nacionalidad valida.', 400, ['error' => 'nacionalidad_invalida']);
            }

            if (!preg_match($nombrePattern, $nombre)) {
                appsec_fail('El nombre del empleado no cumple con el formato solicitado.', 400, ['error' => 'nombre_invalido']);
            }

            if (!$telefonoEsValido($telefono)) {
                appsec_fail('El telefono no cumple con el formato solicitado.', 400, ['error' => 'telefono_invalido']);
            }

            if ($direccion !== '') {
                $direccionLength = mb_strlen(trim($direccion), 'UTF-8');
                if ($direccionLength < 5 || $direccionLength > 255) {
                    appsec_fail('La direccion debe tener entre 5 y 255 caracteres.', 400, ['error' => 'direccion_invalida']);
                }
            }

            $correoNormalizado = $normalizarCorreo($correo);
            if ($correoNormalizado === null) {
                appsec_fail('El correo es obligatorio.', 400, ['error' => 'correo_requerido']);
            }

            if (!filter_var($correoNormalizado, FILTER_VALIDATE_EMAIL)) {
                appsec_fail('El correo no es valido.', 400, ['error' => 'correo_invalido']);
            }

            $categoria = $insEmpleado->obtenerCategoriaEmpleadoPorId($idCategoria);
            if (!$categoria || (int)$categoria['std_reg'] !== 1) {
                appsec_fail('Debes seleccionar una categoria valida.', 400, ['error' => 'categoria_invalida']);
            }

            $stmt = $insEmpleado->ejecutarConsultaConParametros(
                "SELECT id_ai_empleado, std_reg
                 FROM empleado
                 WHERE id_empleado = :id
                 LIMIT 1",
                [':id' => $idEmpleado]
            );
            $exists = $stmt ? $stmt->fetch(PDO::FETCH_ASSOC) : null;
            $nombreGuardado = mb_strtoupper($nombre, 'UTF-8');

            $params = [
                ':nacionalidad' => $nacionalidad,
                ':nombre' => $nombreGuardado,
                ':telefono' => $telefono !== '' ? $telefono : null,
                ':direccion' => $normalizarDireccion($direccion),
                ':correo' => $correoNormalizado,
                ':categoria' => $idCategoria,
            ];

            if ($exists) {
                if ((int)$exists['std_reg'] === 0) {
                    $insEmpleado->ejecutarConsultaConParametros(
                        "UPDATE empleado
                         SET nacionalidad = :nacionalidad,
                             nombre_empleado = :nombre,
                             telefono = :telefono,
                             direccion = :direccion,
                             correo = :correo,
                             id_ai_categoria_empleado = :categoria,
                             std_reg = 1
                         WHERE id_ai_empleado = :id",
                        $params + [
                            ':id' => (int)$exists['id_ai_empleado'],
                        ]
                    );

                    appsec_json_response(['ok' => true, 'msg' => 'Empleado reactivado.']);
                }

                appsec_fail('Ya existe un empleado con esa cedula.', 400, ['error' => 'duplicado']);
            }

            $insEmpleado->ejecutarConsultaConParametros(
                "INSERT INTO empleado (
                    id_empleado,
                    nacionalidad,
                    nombre_empleado,
                    telefono,
                    direccion,
                    correo,
                    id_ai_categoria_empleado,
                    std_reg
                 ) VALUES (
                    :id,
                    :nacionalidad,
                    :nombre,
                    :telefono,
                    :direccion,
                    :correo,
                    :categoria,
                    1
                 )",
                $params + [
                    ':id' => $idEmpleado,
                ]
            );

            appsec_json_response(['ok' => true, 'msg' => 'Empleado creado.']);
            break;

        case 'update':
            $idAiEmpleado = (int)appsec_clean_string(appsec_request_string('id_ai_empleado'));
            $idEmpleado = appsec_clean_string(appsec_request_string('id_empleado'));
            $nacionalidad = $normalizarNacionalidad(appsec_clean_string(appsec_request_string('nacionalidad')));
            $nombre = appsec_clean_string(appsec_request_string('nombre_empleado'));
            $telefono = $normalizarTelefono(appsec_clean_string(appsec_request_string('telefono')));
            $direccion = appsec_clean_string(appsec_request_string('direccion'));
            $correo = appsec_request_string('correo');
            $idCategoria = (int)appsec_clean_string(appsec_request_string('id_ai_categoria_empleado'));

            if ($idAiEmpleado <= 0 || $idEmpleado === '' || $nombre === '' || $idCategoria <= 0) {
                appsec_fail('Debes completar todos los campos obligatorios.', 400, ['error' => 'datos_invalidos']);
            }

            if (!preg_match($idPattern, $idEmpleado)) {
                appsec_fail('La cedula del empleado no cumple con el formato solicitado.', 400, ['error' => 'id_invalido']);
            }

            if ($nacionalidad === '') {
                appsec_fail('Debes seleccionar una nacionalidad valida.', 400, ['error' => 'nacionalidad_invalida']);
            }

            if (!preg_match($nombrePattern, $nombre)) {
                appsec_fail('El nombre del empleado no cumple con el formato solicitado.', 400, ['error' => 'nombre_invalido']);
            }

            if (!$telefonoEsValido($telefono)) {
                appsec_fail('El telefono no cumple con el formato solicitado.', 400, ['error' => 'telefono_invalido']);
            }

            if ($direccion !== '') {
                $direccionLength = mb_strlen(trim($direccion), 'UTF-8');
                if ($direccionLength < 5 || $direccionLength > 255) {
                    appsec_fail('La direccion debe tener entre 5 y 255 caracteres.', 400, ['error' => 'direccion_invalida']);
                }
            }

            $correoNormalizado = $normalizarCorreo($correo);
            if ($correoNormalizado === null) {
                appsec_fail('El correo es obligatorio.', 400, ['error' => 'correo_requerido']);
            }

            if (!filter_var($correoNormalizado, FILTER_VALIDATE_EMAIL)) {
                appsec_fail('El correo no es valido.', 400, ['error' => 'correo_invalido']);
            }

            $categoria = $insEmpleado->obtenerCategoriaEmpleadoPorId($idCategoria);
            if (!$categoria || (int)$categoria['std_reg'] !== 1) {
                appsec_fail('Debes seleccionar una categoria valida.', 400, ['error' => 'categoria_invalida']);
            }

            $current = $insEmpleado->obtenerEmpleadoPorPk($idAiEmpleado);
            if (!$current) {
                appsec_fail('Empleado no encontrado.', 404, ['error' => 'no_encontrado']);
            }

            $dup = $insEmpleado->ejecutarConsultaConParametros(
                "SELECT 1
                 FROM empleado
                 WHERE id_empleado = :id
                   AND id_ai_empleado <> :pk
                 LIMIT 1",
                [
                    ':id' => $idEmpleado,
                    ':pk' => $idAiEmpleado,
                ]
            );

            if ($dup && $dup->rowCount() > 0) {
                appsec_fail('Ya existe otro empleado con esa cedula.', 400, ['error' => 'duplicado']);
            }

            $nombreGuardado = mb_strtoupper($nombre, 'UTF-8');
            $idAnterior = (string)$current['id_empleado'];

            $insEmpleado->ejecutarConsultaConParametros(
                "UPDATE empleado
                 SET id_empleado = :idEmpleado,
                     nacionalidad = :nacionalidad,
                     nombre_empleado = :nombre,
                     telefono = :telefono,
                     direccion = :direccion,
                     correo = :correo,
                     id_ai_categoria_empleado = :categoria
                 WHERE id_ai_empleado = :pk",
                [
                    ':idEmpleado' => $idEmpleado,
                    ':nacionalidad' => $nacionalidad,
                    ':nombre' => $nombreGuardado,
                    ':telefono' => $telefono !== '' ? $telefono : null,
                    ':direccion' => $normalizarDireccion($direccion),
                    ':correo' => $correoNormalizado,
                    ':categoria' => $idCategoria,
                    ':pk' => $idAiEmpleado,
                ]
            );

            appsec_json_response(['ok' => true, 'msg' => 'Empleado actualizado.']);
            break;

        case 'delete':
            $idAiEmpleado = (int)appsec_clean_string(appsec_request_string('id_ai_empleado'));
            if ($idAiEmpleado <= 0) {
                appsec_fail('ID invalido.', 400, ['error' => 'id_invalido']);
            }

            $current = $insEmpleado->obtenerEmpleadoPorPk($idAiEmpleado);
            if (!$current) {
                appsec_fail('Empleado no encontrado.', 404, ['error' => 'no_encontrado']);
            }

            $activeUser = $insEmpleado->ejecutarConsultaConParametros(
                "SELECT 1
                 FROM user_system
                 WHERE id_empleado = :id
                   AND std_reg = 1
                 LIMIT 1",
                [':id' => (string)$current['id_empleado']]
            );

            if ($activeUser && $activeUser->rowCount() > 0) {
                appsec_fail('No puedes eliminar un empleado que todavia tiene un usuario del sistema activo.', 400, ['error' => 'empleado_en_uso']);
            }

            $insEmpleado->ejecutarConsultaConParametros(
                "UPDATE empleado
                 SET std_reg = 0
                 WHERE id_ai_empleado = :id",
                [':id' => $idAiEmpleado]
            );

            appsec_json_response(['ok' => true, 'msg' => 'Empleado eliminado.']);
            break;

        default:
            appsec_fail('Accion no valida.', 400, ['error' => 'accion_invalida']);
    }
} catch (\Throwable $e) {
    error_log('[empleadoCrud] ' . $e->getMessage());
    appsec_fail('Ocurrio un error al procesar el empleado.', 500, ['error' => 'server_error']);
}

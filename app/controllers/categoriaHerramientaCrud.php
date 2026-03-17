<?php
require_once __DIR__ . "/securityBootstrap.php";

use app\controllers\herramientaController;

appsec_require_method('POST');
appsec_require_admin();

$insHerramienta = new herramientaController();
$action = appsec_clean_string(appsec_request_string('action'));

if ($action === '') {
    appsec_fail('Accion no valida.', 400, ['error' => 'accion_invalida']);
}

$nombrePattern = '/^[\p{L}0-9 .-]{3,100}$/u';

switch ($action) {
    case 'get':
        $id = (int)appsec_clean_string(appsec_request_string('id_ai_categoria_herramienta'));
        if ($id <= 0) {
            appsec_fail('ID invalido.', 400, ['error' => 'id_invalido']);
        }

        $row = $insHerramienta->obtenerCategoriaHerramientaPorId($id);
        if (!$row) {
            appsec_fail('Categoria no encontrada.', 404, ['error' => 'no_encontrado']);
        }

        appsec_json_response(['ok' => true, 'data' => $row]);
        break;

    case 'create':
        $nombre = appsec_clean_string(appsec_request_string('nombre_categoria'));
        $descripcion = appsec_clean_string(appsec_request_string('descripcion'));

        if ($nombre === '') {
            appsec_fail('Debes indicar el nombre de la categoria.', 400, ['error' => 'nombre_requerido']);
        }

        if (!preg_match($nombrePattern, $nombre)) {
            appsec_fail('El nombre de la categoria no cumple con el formato solicitado.', 400, ['error' => 'nombre_invalido']);
        }

        $stmt = $insHerramienta->ejecutarConsultaConParametros(
            "SELECT id_ai_categoria_herramienta, std_reg
             FROM categoria_herramienta
             WHERE nombre_categoria = :nombre
             LIMIT 1",
            [':nombre' => mb_strtoupper($nombre, 'UTF-8')]
        );
        $exists = $stmt ? $stmt->fetch(\PDO::FETCH_ASSOC) : null;

        if ($exists) {
            if ((int)$exists['std_reg'] === 0) {
                $insHerramienta->ejecutarConsultaConParametros(
                    "UPDATE categoria_herramienta
                     SET nombre_categoria = :nombre,
                         descripcion = :descripcion,
                         std_reg = 1
                     WHERE id_ai_categoria_herramienta = :id",
                    [
                        ':nombre' => mb_strtoupper($nombre, 'UTF-8'),
                        ':descripcion' => $descripcion !== '' ? $descripcion : null,
                        ':id' => (int)$exists['id_ai_categoria_herramienta'],
                    ]
                );

                appsec_json_response(['ok' => true, 'msg' => 'Categoria reactivada.']);
            }

            appsec_fail('La categoria ya existe.', 400, ['error' => 'duplicado']);
        }

        $insHerramienta->ejecutarConsultaConParametros(
            "INSERT INTO categoria_herramienta (nombre_categoria, descripcion, std_reg)
             VALUES (:nombre, :descripcion, 1)",
            [
                ':nombre' => mb_strtoupper($nombre, 'UTF-8'),
                ':descripcion' => $descripcion !== '' ? $descripcion : null,
            ]
        );

        appsec_json_response(['ok' => true, 'msg' => 'Categoria creada.']);
        break;

    case 'update':
        $id = (int)appsec_clean_string(appsec_request_string('id_ai_categoria_herramienta'));
        $nombre = appsec_clean_string(appsec_request_string('nombre_categoria'));
        $descripcion = appsec_clean_string(appsec_request_string('descripcion'));

        if ($id <= 0 || $nombre === '') {
            appsec_fail('Datos incompletos.', 400, ['error' => 'datos_invalidos']);
        }

        if (!preg_match($nombrePattern, $nombre)) {
            appsec_fail('El nombre de la categoria no cumple con el formato solicitado.', 400, ['error' => 'nombre_invalido']);
        }

        $dup = $insHerramienta->ejecutarConsultaConParametros(
            "SELECT 1
             FROM categoria_herramienta
             WHERE nombre_categoria = :nombre
               AND id_ai_categoria_herramienta <> :id
             LIMIT 1",
            [
                ':nombre' => mb_strtoupper($nombre, 'UTF-8'),
                ':id' => $id,
            ]
        );

        if ($dup && $dup->rowCount() > 0) {
            appsec_fail('Ya existe otra categoria con ese nombre.', 400, ['error' => 'duplicado']);
        }

        $insHerramienta->ejecutarConsultaConParametros(
            "UPDATE categoria_herramienta
             SET nombre_categoria = :nombre,
                 descripcion = :descripcion
             WHERE id_ai_categoria_herramienta = :id",
            [
                ':nombre' => mb_strtoupper($nombre, 'UTF-8'),
                ':descripcion' => $descripcion !== '' ? $descripcion : null,
                ':id' => $id,
            ]
        );

        appsec_json_response(['ok' => true, 'msg' => 'Categoria actualizada.']);
        break;

    case 'delete':
        $id = (int)appsec_clean_string(appsec_request_string('id_ai_categoria_herramienta'));
        if ($id <= 0) {
            appsec_fail('ID invalido.', 400, ['error' => 'id_invalido']);
        }

        $inUse = $insHerramienta->ejecutarConsultaConParametros(
            "SELECT COUNT(1)
             FROM herramienta
             WHERE id_ai_categoria_herramienta = :id
               AND std_reg = 1",
            [':id' => $id]
        );

        if ($inUse && (int)$inUse->fetchColumn() > 0) {
            appsec_fail('No puedes eliminar una categoria con herramientas activas asociadas.', 400, ['error' => 'categoria_en_uso']);
        }

        $insHerramienta->ejecutarConsultaConParametros(
            "UPDATE categoria_herramienta
             SET std_reg = 0
             WHERE id_ai_categoria_herramienta = :id",
            [':id' => $id]
        );

        appsec_json_response(['ok' => true, 'msg' => 'Categoria eliminada.']);
        break;

    default:
        appsec_fail('Accion no valida.', 400, ['error' => 'accion_invalida']);
}

<?php
require_once __DIR__ . "/securityBootstrap.php";

use app\controllers\configController;

appsec_require_admin();
header('Content-Type: application/json; charset=utf-8');

function escPkHuman($pk)
{
    $pk = trim((string)$pk);
    if ($pk === '') {
        return '';
    }

    $parts = explode('=', $pk, 2);
    if (count($parts) === 2) {
        return trim($parts[0]) . ': ' . trim($parts[1]);
    }

    return $pk;
}

function parsePk($pk)
{
    $pk = trim((string)$pk);
    $parts = explode('=', $pk, 2);
    if (count($parts) !== 2) {
        return [null, null];
    }

    return [trim($parts[0]), trim($parts[1])];
}

function tableHasStdReg($ins, $table)
{
    $table = trim($table);
    if (!preg_match('/^[a-zA-Z0-9_]+$/', $table)) {
        return false;
    }

    $sql = "SELECT COUNT(1) AS c
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_SCHEMA = DATABASE()
              AND TABLE_NAME = :t
              AND COLUMN_NAME = 'std_reg'";
    $stmt = $ins->ejecutarConsultaConParametros($sql, [':t' => $table]);
    if (!$stmt) {
        return false;
    }

    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    return ((int)($row['c'] ?? 0)) > 0;
}

try {
    $ins = new configController();
    $idLog = (int)appsec_request_string('id_log', '0');

    if ($idLog <= 0) {
        appsec_json_response(["ok" => false, "msg" => "ID invalido"], 400);
    }

    $stmt = $ins->ejecutarConsultaConParametros(
        "SELECT " . $ins->columnasTablaSql('log_user') . " FROM log_user WHERE id_log = :id LIMIT 1",
        [':id' => $idLog]
    );
    $row = $stmt ? $stmt->fetch(PDO::FETCH_ASSOC) : null;

    if (!$row) {
        appsec_json_response(["ok" => false, "msg" => "No existe el log"], 404);
    }

    $op = $row['operacion'] ?? 'UNKNOWN';
    $tabla = $row['tabla'] ?? '';
    $pkRegistro = $row['pk_registro'] ?? '';

    $humanText = match ($op) {
        'INSERT' => 'Se creo un registro.',
        'UPDATE' => 'Se actualizo un registro.',
        'DELETE' => 'Se elimino un registro de forma definitiva.',
        'SOFT_DELETE' => 'Se elimino un registro de forma logica (se puede restaurar).',
        default => 'Evento del sistema.'
    };

    $canRestore = false;
    $hint = '';

    if ($op === 'SOFT_DELETE' && $tabla !== '') {
        $hasStd = tableHasStdReg($ins, $tabla);
        if ($hasStd) {
            [$pkCol, $pkVal] = parsePk($pkRegistro);
            if ($pkCol && $pkVal && preg_match('/^[a-zA-Z0-9_]+$/', $pkCol)) {
                $sqlChk = "SELECT std_reg FROM `$tabla` WHERE `$pkCol` = :v LIMIT 1";
                $stmt2 = $ins->ejecutarConsultaConParametros($sqlChk, [':v' => $pkVal]);
                $row2 = $stmt2 ? $stmt2->fetch(PDO::FETCH_ASSOC) : null;
                if ($row2 && isset($row2['std_reg']) && (int)$row2['std_reg'] === 0) {
                    $canRestore = true;
                    $hint = 'Restaurara el registro y sus dependencias logicas asociadas.';
                } else {
                    $hint = 'No se encontro el registro eliminado o ya esta activo.';
                }
            } else {
                $hint = 'No se pudo interpretar la clave del registro.';
            }
        } else {
            $hint = 'La tabla no maneja borrado logico con std_reg.';
        }
    } else {
        $hint = 'Solo se puede restaurar un evento SOFT_DELETE.';
    }

    appsec_json_response([
        "ok" => true,
        "data" => [
            "id_log" => $row['id_log'],
            "id_user" => $row['id_user'],
            "tabla" => $tabla,
            "operacion" => $op,
            "pk_registro" => $pkRegistro,
            "pk_human" => escPkHuman($pkRegistro),
            "accion" => $row['accion'],
            "resp_system" => $row['resp_system'],
            "fecha_hora" => $row['fecha_hora'],
            "human_text" => $humanText,
            "can_restore" => $canRestore,
            "restore_hint" => $hint,
        ]
    ]);
} catch (Throwable $e) {
    appsec_json_response([
        "ok" => false,
        "msg" => "Error interno",
        "detail" => $e->getMessage(),
    ], 500);
}

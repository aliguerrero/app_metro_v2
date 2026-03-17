<?php
require_once "../../config/app.php";
require_once "../views/inc/session_start.php";
require_once "../../autoload.php";

use app\models\mainModel;

ini_set('display_errors', '0');
ini_set('log_errors', '1');
error_reporting(E_ALL);

register_shutdown_function(function () {
    $err = error_get_last();
    if ($err && in_array($err['type'], [E_ERROR, E_PARSE, E_CORE_ERROR, E_COMPILE_ERROR], true)) {
        if (!headers_sent()) {
            header('Content-Type: application/json; charset=utf-8');
            http_response_code(500);
        }
        echo json_encode([
            "ok" => false,
            "error" => "fatal_error",
            "msg" => "Ocurrió un problema interno. Intenta nuevamente.",
            "detail" => $err['message'],
            "file" => $err['file'],
            "line" => $err['line'],
        ], JSON_UNESCAPED_UNICODE);
    }
});

function jsonResponse(array $payload, int $status = 200): void
{
    if (!headers_sent()) {
        header('Content-Type: application/json; charset=utf-8');
        http_response_code($status);
    }
    echo json_encode($payload, JSON_UNESCAPED_UNICODE);
    exit();
}

function fail(string $error, string $msg, int $status = 400, array $extra = []): void
{
    jsonResponse(array_merge([
        "ok" => false,
        "error" => $error,
        "msg" => $msg,
    ], $extra), $status);
}

function requirePerm(string $permKey): void
{
    $perms = $_SESSION['permisos'] ?? [];
    if (empty($perms[$permKey]) || (int)$perms[$permKey] !== 1) {
        fail("permiso_denegado", "No tienes permisos para realizar esta acción.", 403);
    }
}

function requireAnyPerm(array $permKeys): void
{
    $perms = $_SESSION['permisos'] ?? [];
    foreach ($permKeys as $k) {
        if (!empty($perms[$k]) && (int)$perms[$k] === 1) return;
    }
    fail("permiso_denegado", "No tienes permisos para realizar esta acción.", 403);
}

function postv(string $k, string $default = ''): string
{
    return isset($_POST[$k]) ? trim((string)$_POST[$k]) : $default;
}

function firstPost(array $keys, string $default = ''): string
{
    foreach ($keys as $k) {
        if (isset($_POST[$k])) {
            $v = trim((string)$_POST[$k]);
            if ($v !== '') return $v;
        }
    }
    return $default;
}

function isValidDateYmd(string $v): bool
{
    return (bool)preg_match('/^\d{4}-\d{2}-\d{2}$/', $v);
}

function isValidTimeStrict(string $v): bool
{
    return (bool)preg_match('/^\d{2}:\d{2}(:\d{2})?$/', $v);
}

function isDigits(string $v): bool
{
    return $v !== '' && ctype_digit($v);
}

/**
 * Código OT: permite letras UNICODE (Ñ/acentos), números, guion y underscore.
 * Ej: VF-SEÑ-01
 */
function isOtCode(string $v): bool
{
    return $v !== '' && (bool)preg_match('/^[\p{L}0-9_-]{1,30}$/u', $v);
}

/**
 * IDs tipo miembro (M-001), etc: letras unicode + números + guion/underscore.
 */
function isIdLike(string $v, int $maxLen = 30): bool
{
    if ($v === '' || mb_strlen($v, 'UTF-8') > $maxLen) return false;
    return (bool)preg_match('/^[\p{L}0-9_-]+$/u', $v);
}

/**
 * id_user es VARCHAR(30) en tu BD (ej: 000000). NO castear a int.
 */
function existsUserId(mainModel $m, string $idUser): bool
{
    $st = $m->ejecutarConsultaConParametros(
        "SELECT 1 FROM user_system WHERE id_empleado = :id LIMIT 1",
        [':id' => $idUser]
    );
    return $st && $st->rowCount() > 0;
}

function columnExists(mainModel $m, string $table, string $column): bool
{
    $sql = "SELECT COUNT(1)
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_SCHEMA = DATABASE()
              AND TABLE_NAME = :t
              AND COLUMN_NAME = :c";
    $st = $m->ejecutarConsultaConParametros($sql, [':t' => $table, ':c' => $column]);
    return $st && (int)$st->fetchColumn() > 0;
}

function existsDetalle(mainModel $m, string $pk, string $codigo, int $idDet, ?string $fecha = null): bool
{
    $sql = "SELECT 1 FROM detalle_orden WHERE n_ot = :not AND $pk = :id";
    $params = [':not' => $codigo, ':id' => $idDet];
    if ($fecha !== null) {
        $sql .= " AND fecha = :fecha";
        $params[':fecha'] = $fecha;
    }
    $sql .= " LIMIT 1";
    $st = $m->ejecutarConsultaConParametros($sql, $params);
    return $st && $st->rowCount() > 0;
}

$mainModel = new mainModel();

try {
    $tipo = postv('tipo', 'ver'); // ver | eliminar | guardar

    // Detectar PK real del detalle
    $pk = null;
    if (columnExists($mainModel, 'detalle_orden', 'id_ai_detalle')) $pk = 'id_ai_detalle';
    elseif (columnExists($mainModel, 'detalle_orden', 'id_detalle')) $pk = 'id_detalle';
    else fail("schema_pk_no_encontrada", "No se pudo identificar el ID del detalle. Contacta a soporte.", 500);

    // ==========================
    // VER / ELIMINAR
    // ==========================
    if ($tipo === 'ver' || $tipo === 'eliminar') {

        $id     = postv('id');      // id detalle (num)
        $fecha  = postv('fecha');   // YYYY-MM-DD
        $codigo = postv('codigo');  // n_ot

        if ($codigo === '' || $fecha === '' || $id === '') {
            fail("parametros_invalidos", "No se pudo identificar el registro seleccionado. Vuelve a intentarlo.");
        }
        if (!isValidDateYmd($fecha)) {
            fail("fecha_invalida", "La fecha no es válida. Selecciona una fecha con formato YYYY-MM-DD.");
        }
        if (!ctype_digit($id)) {
            fail("id_invalido", "No se pudo identificar el detalle seleccionado. Vuelve a seleccionarlo.");
        }
        if (!isOtCode($codigo)) {
            fail("codigo_invalido", "El código de la O.T. no es válido. Vuelve a abrir la orden e intenta nuevamente.");
        }

        if ($tipo === 'ver') {
            requirePerm('perm_ot_view');
            $detalleCols = $mainModel->columnasTablaSql('detalle_orden', 'd');

            $stmt = $mainModel->ejecutarConsultaConParametros(
                "SELECT {$detalleCols}, COALESCE(NULLIF(e.nombre_empleado, ''), d.id_user_act) AS user
                 FROM detalle_orden d
                 LEFT JOIN empleado e ON e.id_empleado = d.id_user_act
                 WHERE d.n_ot = :not
                   AND d.fecha = :fecha
                   AND d.$pk = :id
                 LIMIT 1",
                [':not' => $codigo, ':fecha' => $fecha, ':id' => (int)$id]
            );

            if ($stmt && $stmt->rowCount() > 0) {
                jsonResponse(["ok" => true, "data" => $stmt->fetch(PDO::FETCH_ASSOC)]);
            }
            fail("no_encontrado", "El registro ya no existe o fue eliminado.", 404);
        }

        // eliminar
        requireAnyPerm(['perm_ot_add_detalle', 'perm_ot_delete']);

        $stmt = $mainModel->ejecutarConsultaConParametros(
            "DELETE FROM detalle_orden
             WHERE n_ot = :not
               AND $pk = :id
               AND fecha = :fecha",
            [':not' => $codigo, ':id' => (int)$id, ':fecha' => $fecha]
        );

        $deleted = ($stmt && method_exists($stmt, 'rowCount') && $stmt->rowCount() > 0);
        jsonResponse(["ok" => $deleted]);
    }

    // ==========================
    // GUARDAR
    // ==========================
    if ($tipo !== 'guardar') {
        fail("tipo_no_soportado", "La operación solicitada no es válida.");
    }

    requireAnyPerm(['perm_ot_add_detalle']);

    // Código OT (acepta que venga como codigo/n_ot/id)
    $codigo = firstPost(['codigo', 'n_ot', 'id_ot', 'ot', 'id'], '');

    // ID del detalle (NO uses 'id' aquí porque en tu UI suele ser el n_ot)
    $idDet = firstPost(['id2', 'detalle_id', 'id_detalle', 'id_ai_detalle'], '');

    // fallback por si tu form manda el id detalle como "id" (solo si es num y el codigo viene por otro campo)
    if ($idDet === '') {
        $cand = postv('id', '');
        if ($cand !== '' && ctype_digit($cand) && (isset($_POST['codigo']) || isset($_POST['n_ot']) || isset($_POST['id_ot']) || isset($_POST['ot']))) {
            $idDet = $cand;
        }
    }

    $fecha = firstPost(['fecha'], '');

    $desc   = firstPost(['desc', 'descripcion'], '');
    $cant   = firstPost(['cant', 'cant_tec'], '');
    $turno  = firstPost(['turno', 'id_ai_turno'], '');
    $status = firstPost(['status', 'id_ai_estado', 'estado'], '');
    $cco    = firstPost(['cco', 'id_miembro_cco'], '');
    $ccf    = firstPost(['ccf', 'id_miembro_ccf'], '');
    $tec    = firstPost(['tec', 'id_user_act', 'id_tecnico'], '');

    $prep_ini = firstPost(['prep_ini', 'hora_ini_pre'], '');
    $prep_fin = firstPost(['prep_fin', 'hora_fin_pre'], '');
    $tras_ini = firstPost(['tras_ini', 'hora_ini_tra'], '');
    $tras_fin = firstPost(['tras_fin', 'hora_fin_tra'], '');
    $ejec_ini = firstPost(['ejec_ini', 'hora_ini_eje'], '');
    $ejec_fin = firstPost(['ejec_fin', 'hora_fin_eje'], '');

    $obs = postv('observacion', '');

    $required = [
        'codigo' => $codigo,
        'fecha' => $fecha,
        'desc' => $desc,
        'cant' => $cant,
        'turno' => $turno,
        'status' => $status,
        'cco' => $cco,
        'ccf' => $ccf,
        'tec' => $tec,
        'prep_ini' => $prep_ini,
        'prep_fin' => $prep_fin,
        'tras_ini' => $tras_ini,
        'tras_fin' => $tras_fin,
        'ejec_ini' => $ejec_ini,
        'ejec_fin' => $ejec_fin,
    ];

    $fieldLabels = [
        'codigo'   => 'Código de la O.T.',
        'fecha'    => 'Fecha',
        'desc'     => 'Descripción',
        'cant'     => 'Cantidad de operador(es)',
        'turno'    => 'Turno',
        'status'   => 'Estado',
        'cco'      => 'CCO',
        'ccf'      => 'CCF',
        'tec'      => 'Técnico',
        'prep_ini' => 'Preparación (inicio)',
        'prep_fin' => 'Preparación (fin)',
        'tras_ini' => 'Traslado (inicio)',
        'tras_fin' => 'Traslado (fin)',
        'ejec_ini' => 'Ejecución (inicio)',
        'ejec_fin' => 'Ejecución (fin)',
    ];

    $missing = [];
    foreach ($required as $k => $v) {
        if (trim((string)$v) === '') $missing[] = $k;
    }
    if (!empty($missing)) {
        $names = array_map(fn($k) => $fieldLabels[$k] ?? $k, $missing);
        fail("campos_vacios", "Faltan datos obligatorios. Completa: " . implode(', ', $names) . ".", 400, ["missing" => $missing]);
    }

    // Validaciones
    if (!isOtCode($codigo)) {
        fail("codigo_invalido", "El código de la O.T. no es válido. Vuelve a abrir la orden e intenta nuevamente.");
    }
    if (!isValidDateYmd($fecha)) {
        fail("fecha_invalida", "La fecha no es válida. Selecciona una fecha con formato YYYY-MM-DD.");
    }

    if ($idDet !== '' && !ctype_digit($idDet)) {
        fail("id_invalido", "No se pudo identificar el detalle a editar. Vuelve a seleccionarlo.");
    }

    if (!isDigits($cant))   fail("cant_invalido", "La cantidad de operadores debe ser un número entero.");
    if (!isDigits($turno))  fail("turno_invalido", "Selecciona un turno válido.");
    if (!isDigits($status)) fail("status_invalido", "Selecciona un estado válido.");

    if (!isIdLike($cco, 20)) fail("cco_invalido", "El CCO seleccionado no tiene un formato válido.");
    if (!isIdLike($ccf, 20)) fail("ccf_invalido", "El CCF seleccionado no tiene un formato válido.");

    // técnico: VARCHAR(30) (no int)
    if (!isIdLike($tec, 30)) {
        fail("tec_invalido", "Selecciona un técnico válido.");
    }
    if (!existsUserId($mainModel, $tec)) {
        fail("tec_no_existe", "El técnico seleccionado no existe en el sistema. Vuelve a seleccionarlo.");
    }

    if (
        !isValidTimeStrict($prep_ini) || !isValidTimeStrict($prep_fin) ||
        !isValidTimeStrict($tras_ini) || !isValidTimeStrict($tras_fin) ||
        !isValidTimeStrict($ejec_ini) || !isValidTimeStrict($ejec_fin)
    ) {
        fail("hora_invalida", "Verifica las horas: deben estar completas y en formato HH:MM.");
    }

    $params = [
        ':not'    => $codigo,
        ':fecha'  => $fecha,
        ':desc'   => $mainModel->limpiarCadena($desc),
        ':cant'   => (int)$cant,
        ':turno'  => (int)$turno,
        ':estado' => (int)$status,
        ':cco'    => $cco,
        ':ccf'    => $ccf,
        ':tec'    => $tec, // <-- string
        ':pre_i'  => $prep_ini,
        ':pre_f'  => $prep_fin,
        ':tra_i'  => $tras_ini,
        ':tra_f'  => $tras_fin,
        ':eje_i'  => $ejec_ini,
        ':eje_f'  => $ejec_fin,
        ':obs'    => ($obs === '' ? null : $mainModel->limpiarCadena($obs)),
    ];

    // ==========================
    // UPDATE
    // ==========================
    if ($idDet !== '') {
        $idInt = (int)$idDet;

        // 1) update estricto (n_ot + fecha + pk)
        $st = $mainModel->ejecutarConsultaConParametros(
            "UPDATE detalle_orden
             SET descripcion    = :desc,
                 cant_tec       = :cant,
                 id_ai_turno    = :turno,
                 id_ai_estado   = :estado,
                 id_miembro_cco = :cco,
                 id_miembro_ccf = :ccf,
                 id_user_act    = :tec,
                 hora_ini_pre   = :pre_i,
                 hora_fin_pre   = :pre_f,
                 hora_ini_tra   = :tra_i,
                 hora_fin_tra   = :tra_f,
                 hora_ini_eje   = :eje_i,
                 hora_fin_eje   = :eje_f,
                 observacion    = :obs
             WHERE n_ot = :not
               AND fecha = :fecha
               AND $pk = :id",
            $params + [':id' => $idInt]
        );

        $rows = ($st && method_exists($st, 'rowCount')) ? (int)$st->rowCount() : 0;

        // 0 filas puede ser "sin cambios"
        if ($rows === 0 && existsDetalle($mainModel, $pk, $codigo, $idInt, $fecha)) {
            jsonResponse(["ok" => true, "modo" => "update", "sin_cambios" => true]);
        }

        // 2) fallback si la fecha no coincide (actualiza por n_ot + pk y setea fecha)
        if ($rows === 0) {
            $st2 = $mainModel->ejecutarConsultaConParametros(
                "UPDATE detalle_orden
                 SET fecha          = :fecha,
                     descripcion    = :desc,
                     cant_tec       = :cant,
                     id_ai_turno    = :turno,
                     id_ai_estado   = :estado,
                     id_miembro_cco = :cco,
                     id_miembro_ccf = :ccf,
                     id_user_act    = :tec,
                     hora_ini_pre   = :pre_i,
                     hora_fin_pre   = :pre_f,
                     hora_ini_tra   = :tra_i,
                     hora_fin_tra   = :tra_f,
                     hora_ini_eje   = :eje_i,
                     hora_fin_eje   = :eje_f,
                     observacion    = :obs
                 WHERE n_ot = :not
                   AND $pk = :id",
                $params + [':id' => $idInt]
            );

            $rows2 = ($st2 && method_exists($st2, 'rowCount')) ? (int)$st2->rowCount() : 0;

            if ($rows2 === 0 && existsDetalle($mainModel, $pk, $codigo, $idInt, null)) {
                jsonResponse(["ok" => true, "modo" => "update", "sin_cambios" => true, "fallback" => true]);
            }

            if ($rows2 === 0) {
                fail("no_actualizo", "No se pudo actualizar el registro. Vuelve a cargar el detalle e intenta nuevamente.", 409);
            }

            jsonResponse(["ok" => true, "modo" => "update", "fallback" => true]);
        }

        jsonResponse(["ok" => true, "modo" => "update"]);
    }

    // ==========================
    // INSERT
    // ==========================
    $st = $mainModel->ejecutarConsultaConParametros(
        "INSERT INTO detalle_orden
          (n_ot, fecha, descripcion, cant_tec, id_ai_turno, id_ai_estado,
           id_miembro_cco, id_miembro_ccf, id_user_act,
           hora_ini_pre, hora_fin_pre, hora_ini_tra, hora_fin_tra, hora_ini_eje, hora_fin_eje,
           observacion)
         VALUES
          (:not, :fecha, :desc, :cant, :turno, :estado,
           :cco, :ccf, :tec,
           :pre_i, :pre_f, :tra_i, :tra_f, :eje_i, :eje_f,
           :obs)",
        $params
    );

    jsonResponse(["ok" => ($st !== false), "modo" => "insert"]);
} catch (Throwable $e) {
    jsonResponse([
        "ok" => false,
        "error" => "exception",
        "msg" => "No se pudo guardar la información. Intenta nuevamente.",
        "detail" => $e->getMessage()
    ], 500);
}

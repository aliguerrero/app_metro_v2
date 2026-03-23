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
            "msg" => "Ocurrio un problema interno. Intenta nuevamente.",
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
        fail("permiso_denegado", "No tienes permisos para realizar esta accion.", 403);
    }
}

function requireAnyPerm(array $permKeys): void
{
    $perms = $_SESSION['permisos'] ?? [];
    foreach ($permKeys as $k) {
        if (!empty($perms[$k]) && (int)$perms[$k] === 1) return;
    }
    fail("permiso_denegado", "No tienes permisos para realizar esta accion.", 403);
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
 * Codigo OT: permite letras UNICODE (N/acentos), numeros, guion y underscore.
 * Ej: VF-SEN-01
 */
function isOtCode(string $v): bool
{
    return $v !== '' && (bool)preg_match('/^[\p{L}0-9_-]{1,30}$/u', $v);
}

/**
 * IDs tipo miembro (M-001), etc: letras unicode + numeros + guion/underscore.
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

function otEstaFinalizada(mainModel $m, string $codigo): bool
{
    $select = ["n_ot"];
    if (columnExists($m, 'orden_trabajo', 'ot_finalizada')) {
        $select[] = "COALESCE(ot_finalizada, 0) AS ot_finalizada";
    }
    if (columnExists($m, 'orden_trabajo', 'id_ai_estado')) {
        $select[] = "id_ai_estado";
    }

    $st = $m->ejecutarConsultaConParametros(
        "SELECT " . implode(', ', $select) . "
         FROM orden_trabajo
         WHERE n_ot = :not
           AND std_reg = 1
         LIMIT 1",
        [':not' => $codigo]
    );

    if (!$st || $st->rowCount() === 0) {
        return false;
    }

    $row = $st->fetch(PDO::FETCH_ASSOC);
    if ((int)($row['ot_finalizada'] ?? 0) === 1) {
        return true;
    }

    if (!isset($row['id_ai_estado'])) {
        return false;
    }

    return $m->estadoOtEsFinalPorId((int)$row['id_ai_estado']);
}

function detalleHoraColumnMap(mainModel $m): array
{
    $start = [];
    $end = [];

    foreach (['hora_inicio', 'hora_ini_pre', 'hora_ini_tra', 'hora_ini_eje'] as $column) {
        if (columnExists($m, 'detalle_orden', $column)) {
            $start[] = $column;
        }
    }

    foreach (['hora_fin', 'hora_fin_pre', 'hora_fin_tra', 'hora_fin_eje'] as $column) {
        if (columnExists($m, 'detalle_orden', $column)) {
            $end[] = $column;
        }
    }

    return ['start' => $start, 'end' => $end];
}

$mainModel = new mainModel();

try {
    $tipo = postv('tipo', 'ver'); // ver | eliminar | guardar

    // Detectar PK real del detalle
    $pk = null;
    if (columnExists($mainModel, 'detalle_orden', 'id_ai_detalle')) $pk = 'id_ai_detalle';
    elseif (columnExists($mainModel, 'detalle_orden', 'id_detalle')) $pk = 'id_detalle';
    else fail("schema_pk_no_encontrada", "No se pudo identificar el ID del detalle. Contacta a soporte.", 500);

    $horaColumns = detalleHoraColumnMap($mainModel);
    if ($horaColumns['start'] === [] || $horaColumns['end'] === []) {
        fail("schema_horas_no_encontrado", "No se encontraron columnas de hora configuradas para detalle_orden.", 500);
    }

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
            fail("fecha_invalida", "La fecha no es valida. Selecciona una fecha con formato YYYY-MM-DD.");
        }
        if (!ctype_digit($id)) {
            fail("id_invalido", "No se pudo identificar el detalle seleccionado. Vuelve a seleccionarlo.");
        }
        if (!isOtCode($codigo)) {
            fail("codigo_invalido", "El codigo de la O.T. no es valido. Vuelve a abrir la orden e intenta nuevamente.");
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
                $data = $stmt->fetch(PDO::FETCH_ASSOC);
                $data['hora_inicio'] = $mainModel->detalleHoraInicioValor($data);
                $data['hora_fin'] = $mainModel->detalleHoraFinValor($data);
                jsonResponse(["ok" => true, "data" => $data]);
            }
            fail("no_encontrado", "El registro ya no existe o fue eliminado.", 404);
        }

        // eliminar
        requireAnyPerm(['perm_ot_add_detalle', 'perm_ot_delete']);

        if (otEstaFinalizada($mainModel, $codigo)) {
            fail(
                "ot_bloqueada",
                "La O.T. esta bloqueada. Los detalles solo se pueden consultar.",
                409
            );
        }

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
        fail("tipo_no_soportado", "La operacion solicitada no es valida.");
    }

    requireAnyPerm(['perm_ot_add_detalle']);

    // Codigo OT (acepta que venga como codigo/n_ot/id)
    $codigo = firstPost(['codigo', 'n_ot', 'id_ot', 'ot', 'id'], '');

    // ID del detalle (NO uses 'id' aqui porque en tu UI suele ser el n_ot)
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
    $cco    = firstPost(['cco', 'id_miembro_cco'], '');
    $ccf    = firstPost(['ccf', 'id_miembro_ccf'], '');
    $tec    = firstPost(['tec', 'id_user_act', 'id_tecnico'], '');

    $horaInicio = firstPost(['hora_inicio', 'prep_ini', 'hora_ini_pre', 'tras_ini', 'hora_ini_tra', 'ejec_ini', 'hora_ini_eje'], '');
    $horaFin = firstPost(['hora_fin', 'prep_fin', 'hora_fin_pre', 'tras_fin', 'hora_fin_tra', 'ejec_fin', 'hora_fin_eje'], '');

    $obs = postv('observacion', '');

    $required = [
        'codigo' => $codigo,
        'fecha' => $fecha,
        'desc' => $desc,
        'cant' => $cant,
        'turno' => $turno,
        'cco' => $cco,
        'ccf' => $ccf,
        'tec' => $tec,
        'hora_inicio' => $horaInicio,
        'hora_fin' => $horaFin,
    ];

    $fieldLabels = [
        'codigo'   => 'Codigo de la O.T.',
        'fecha'    => 'Fecha',
        'desc'     => 'Descripcion',
        'cant'     => 'Cantidad de operador(es)',
        'turno'    => 'Turno',
        'cco'      => 'CCO',
        'ccf'      => 'CCF',
        'hora_inicio' => 'Hora de inicio',
        'hora_fin' => 'Hora de fin',
        'prep_ini' => 'Preparacion (inicio)',
        'prep_fin' => 'Preparacion (fin)',
        'tras_ini' => 'Traslado (inicio)',
        'tras_fin' => 'Traslado (fin)',
        'ejec_ini' => 'Ejecucion (inicio)',
        'ejec_fin' => 'Ejecucion (fin)',
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
        fail("codigo_invalido", "El codigo de la O.T. no es valido. Vuelve a abrir la orden e intenta nuevamente.");
    }
    if (!isValidDateYmd($fecha)) {
        fail("fecha_invalida", "La fecha no es valida. Selecciona una fecha con formato YYYY-MM-DD.");
    }

    if (otEstaFinalizada($mainModel, $codigo)) {
        fail(
            "ot_finalizada",
            "La O.T. esta bloqueada. Solo se permite consultar los detalles existentes y generar el reporte.",
            409
        );
    }

    if ($idDet !== '' && !ctype_digit($idDet)) {
        fail("id_invalido", "No se pudo identificar el detalle a editar. Vuelve a seleccionarlo.");
    }

    if (!isDigits($cant))   fail("cant_invalido", "La cantidad de operadores debe ser un numero entero.");
    if (!isDigits($turno))  fail("turno_invalido", "Selecciona un turno valido.");
    if (!isIdLike($cco, 20)) fail("cco_invalido", "El CCO seleccionado no tiene un formato valido.");
    if (!isIdLike($ccf, 20)) fail("ccf_invalido", "El CCF seleccionado no tiene un formato valido.");

    // tecnico: VARCHAR(30) (no int)
    if (!isIdLike($tec, 30)) {
        fail("tec_invalido", "Selecciona un tecnico valido.");
    }
    if (!existsUserId($mainModel, $tec)) {
        fail("tec_no_existe", "El tecnico seleccionado no existe en el sistema. Vuelve a seleccionarlo.");
    }

    if (!isValidTimeStrict($horaInicio) || !isValidTimeStrict($horaFin)) {
        fail("hora_invalida", "Verifica las horas: deben estar completas y en formato HH:MM.");
    }

    $params = [
        ':not'    => $codigo,
        ':fecha'  => $fecha,
        ':desc'   => $mainModel->limpiarCadena($desc),
        ':cant'   => (int)$cant,
        ':turno'  => (int)$turno,
        ':cco'    => $cco,
        ':ccf'    => $ccf,
        ':tec'    => $tec, // <-- string
        ':hora_inicio' => $horaInicio,
        ':hora_fin' => $horaFin,
        ':obs'    => ($obs === '' ? null : $mainModel->limpiarCadena($obs)),
    ];

    $updateAssignments = [
        "descripcion    = :desc",
        "cant_tec       = :cant",
        "id_ai_turno    = :turno",
        "id_miembro_cco = :cco",
        "id_miembro_ccf = :ccf",
        "id_user_act    = :tec",
    ];

    foreach ($horaColumns['start'] as $column) {
        $updateAssignments[] = "{$column} = :hora_inicio";
    }

    foreach ($horaColumns['end'] as $column) {
        $updateAssignments[] = "{$column} = :hora_fin";
    }

    $updateAssignments[] = "observacion    = :obs";
    $updateSetSql = implode(",\n                 ", $updateAssignments);

    $insertColumns = [
        'n_ot',
        'fecha',
        'descripcion',
        'cant_tec',
        'id_ai_turno',
        'id_miembro_cco',
        'id_miembro_ccf',
        'id_user_act',
    ];

    $insertMarkers = [
        ':not',
        ':fecha',
        ':desc',
        ':cant',
        ':turno',
        ':cco',
        ':ccf',
        ':tec',
    ];

    foreach ($horaColumns['start'] as $column) {
        $insertColumns[] = $column;
        $insertMarkers[] = ':hora_inicio';
    }

    foreach ($horaColumns['end'] as $column) {
        $insertColumns[] = $column;
        $insertMarkers[] = ':hora_fin';
    }

    $insertColumns[] = 'observacion';
    $insertMarkers[] = ':obs';

    // ==========================
    // UPDATE
    // ==========================
    if ($idDet !== '') {
        $idInt = (int)$idDet;

        // 1) update estricto (n_ot + fecha + pk)
        $st = $mainModel->ejecutarConsultaConParametros(
            "UPDATE detalle_orden
             SET {$updateSetSql}
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
                     {$updateSetSql}
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
    $result = $mainModel->ejecutarProcedimientoFila(
        "CALL sp_ot_agregar_detalle(
            :not,
            :fecha,
            :desc,
            :turno,
            :cco,
            :tec,
            :ccf,
            :cant,
            :hora_inicio,
            :hora_fin,
            :obs
        )",
        $params
    );

    jsonResponse([
        "ok" => ($result !== null),
        "modo" => "insert",
        "data" => $result
    ]);
} catch (Throwable $e) {
    jsonResponse([
        "ok" => false,
        "error" => "exception",
        "msg" => "No se pudo guardar la informacion. Intenta nuevamente.",
        "detail" => $e->getMessage()
    ], 500);
}



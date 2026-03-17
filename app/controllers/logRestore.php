<?php
require_once __DIR__ . "/securityBootstrap.php";

use app\controllers\configController;

header('Content-Type: application/json; charset=utf-8');

function parsePk($pk)
{
    $pk = trim((string)$pk);
    $parts = explode('=', $pk, 2);
    if (count($parts) !== 2) return [null, null];
    $col = trim($parts[0]);
    $val = trim($parts[1]);
    return [$col, $val];
}

function safeIdent($s)
{
    return (is_string($s) && preg_match('/^[a-zA-Z0-9_]+$/', $s)) ? $s : null;
}

function tableHasColumn($ins, $table, $col)
{
    $table = safeIdent($table);
    $col = safeIdent($col);
    if (!$table || !$col) return false;

    $sql = "SELECT COUNT(1) AS c
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_SCHEMA = DATABASE()
              AND TABLE_NAME = :t
              AND COLUMN_NAME = :c";
    $st = $ins->ejecutarConsultaConParametros($sql, [':t' => $table, ':c' => $col]);
    $r = $st ? $st->fetch(PDO::FETCH_ASSOC) : null;
    return ((int)($r['c'] ?? 0)) > 0;
}

function getSinglePkCol($ins, $table)
{
    $table = safeIdent($table);
    if (!$table) return null;

    $sql = "SELECT COLUMN_NAME
            FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
            WHERE TABLE_SCHEMA = DATABASE()
              AND TABLE_NAME = :t
              AND CONSTRAINT_NAME = 'PRIMARY'
            ORDER BY ORDINAL_POSITION ASC";
    $st = $ins->ejecutarConsultaConParametros($sql, [':t' => $table]);
    if (!$st) return null;

    $cols = [];
    while ($r = $st->fetch(PDO::FETCH_ASSOC)) {
        $cols[] = $r['COLUMN_NAME'];
    }
    if (count($cols) === 1) return $cols[0];
    return null; // compuesta o no detectada
}

function restoreCascade($ins, $table, $pkCol, $pkVal, &$visited, &$restored, $depth = 0)
{
    if ($depth > 6) return; // límite anti loops

    $table = safeIdent($table);
    $pkCol = safeIdent($pkCol);
    if (!$table || !$pkCol) return;

    $key = $table . '|' . $pkCol . '|' . $pkVal;
    if (isset($visited[$key])) return;
    $visited[$key] = true;

    // debe tener std_reg
    if (!tableHasColumn($ins, $table, 'std_reg')) return;

    // leer fila (aunque esté std_reg=0)
    $stRow = $ins->ejecutarConsultaConParametros(
        "SELECT " . $ins->columnasTablaSql($table) . " FROM `$table` WHERE `$pkCol` = :v LIMIT 1",
        [':v' => $pkVal]
    );
    $row = $stRow ? $stRow->fetch(PDO::FETCH_ASSOC) : null;
    if (!$row) return;

    // restaurar actual
    $ins->ejecutarConsultaConParametros("UPDATE `$table` SET std_reg = 1 WHERE `$pkCol` = :v", [':v' => $pkVal]);
    $restored[] = ["table" => $table, "pk" => $pkCol, "val" => $pkVal];

    // ====== 1) RESTAURAR PADRES (FK hacia arriba)
    $sqlUp = "SELECT COLUMN_NAME, REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME
              FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
              WHERE TABLE_SCHEMA = DATABASE()
                AND TABLE_NAME = :t
                AND REFERENCED_TABLE_NAME IS NOT NULL";
    $stUp = $ins->ejecutarConsultaConParametros($sqlUp, [':t' => $table]);

    if ($stUp) {
        while ($fk = $stUp->fetch(PDO::FETCH_ASSOC)) {
            $col = $fk['COLUMN_NAME'] ?? '';
            $pt  = $fk['REFERENCED_TABLE_NAME'] ?? '';
            $pc  = $fk['REFERENCED_COLUMN_NAME'] ?? '';

            $col = safeIdent($col);
            $pt  = safeIdent($pt);
            $pc  = safeIdent($pc);
            if (!$col || !$pt || !$pc) continue;

            if (!array_key_exists($col, $row)) continue;
            $parentVal = $row[$col];
            if ($parentVal === null || $parentVal === '') continue;

            // solo si padre maneja std_reg
            if (!tableHasColumn($ins, $pt, 'std_reg')) continue;

            // si padre está eliminado, restaurar
            $stP = $ins->ejecutarConsultaConParametros("SELECT std_reg FROM `$pt` WHERE `$pc` = :v LIMIT 1", [':v' => $parentVal]);
            $pRow = $stP ? $stP->fetch(PDO::FETCH_ASSOC) : null;
            if ($pRow && isset($pRow['std_reg']) && (int)$pRow['std_reg'] === 0) {
                restoreCascade($ins, $pt, $pc, $parentVal, $visited, $restored, $depth + 1);
            }
        }
    }

    // ====== 2) RESTAURAR HIJOS (FK hacia abajo)
    // buscamos tablas que referencian a esta
    $sqlDown = "SELECT TABLE_NAME, COLUMN_NAME, REFERENCED_COLUMN_NAME
                FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
                WHERE TABLE_SCHEMA = DATABASE()
                  AND REFERENCED_TABLE_NAME = :t
                  AND REFERENCED_COLUMN_NAME = :pc";
    $stDown = $ins->ejecutarConsultaConParametros($sqlDown, [':t' => $table, ':pc' => $pkCol]);

    if ($stDown) {
        while ($fk = $stDown->fetch(PDO::FETCH_ASSOC)) {
            $ct = safeIdent($fk['TABLE_NAME'] ?? '');
            $cc = safeIdent($fk['COLUMN_NAME'] ?? '');
            if (!$ct || !$cc) continue;

            if (!tableHasColumn($ins, $ct, 'std_reg')) continue;

            // restaurar hijos eliminados (limite 50 para no romper)
            $childPk = getSinglePkCol($ins, $ct);
            if ($childPk) {
                $sqlKids = "SELECT `$childPk` AS pk
                            FROM `$ct`
                            WHERE `$cc` = :v AND std_reg = 0
                            LIMIT 50";
                $stKids = $ins->ejecutarConsultaConParametros($sqlKids, [':v' => $pkVal]);
                if ($stKids) {
                    while ($kid = $stKids->fetch(PDO::FETCH_ASSOC)) {
                        $kidVal = $kid['pk'] ?? null;
                        if ($kidVal === null) continue;
                        restoreCascade($ins, $ct, $childPk, $kidVal, $visited, $restored, $depth + 1);
                    }
                }
            } else {
                // si no hay PK simple, al menos hacemos update masivo
                $ins->ejecutarConsultaConParametros("UPDATE `$ct` SET std_reg = 1 WHERE `$cc` = :v AND std_reg = 0", [':v' => $pkVal]);
                $restored[] = ["table" => $ct, "pk" => $cc, "val" => $pkVal];
            }
        }
    }
}

try {
    appsec_require_admin();

    $ins = new configController();

    $id_log = (int)($_POST['id_log'] ?? 0);
    if ($id_log <= 0) {
        echo json_encode(["ok" => false, "msg" => "ID inválido"], JSON_UNESCAPED_UNICODE);
        exit();
    }

    $st = $ins->ejecutarConsultaConParametros(
        "SELECT " . $ins->columnasTablaSql('log_user') . " FROM log_user WHERE id_log = :id LIMIT 1",
        [':id' => $id_log]
    );
    $log = $st ? $st->fetch(PDO::FETCH_ASSOC) : null;

    if (!$log) {
        echo json_encode(["ok" => false, "msg" => "No existe el log"], JSON_UNESCAPED_UNICODE);
        exit();
    }

    if (($log['operacion'] ?? '') !== 'SOFT_DELETE') {
        echo json_encode(["ok" => false, "msg" => "Solo se restaura cuando la operación es SOFT_DELETE"], JSON_UNESCAPED_UNICODE);
        exit();
    }

    $tabla = safeIdent($log['tabla'] ?? '');
    if (!$tabla) {
        echo json_encode(["ok" => false, "msg" => "Tabla inválida"], JSON_UNESCAPED_UNICODE);
        exit();
    }

    [$pkCol, $pkVal] = parsePk($log['pk_registro'] ?? '');
    $pkCol = safeIdent($pkCol);
    if (!$pkCol || $pkVal === null || $pkVal === '') {
        echo json_encode(["ok" => false, "msg" => "No se pudo interpretar pk_registro"], JSON_UNESCAPED_UNICODE);
        exit();
    }

    if (!tableHasColumn($ins, $tabla, 'std_reg')) {
        echo json_encode(["ok" => false, "msg" => "La tabla no maneja std_reg (no restaurable)"], JSON_UNESCAPED_UNICODE);
        exit();
    }

    // comprobar que existe y está std_reg=0
    $stChk = $ins->ejecutarConsultaConParametros("SELECT std_reg FROM `$tabla` WHERE `$pkCol` = :v LIMIT 1", [':v' => $pkVal]);
    $row = $stChk ? $stChk->fetch(PDO::FETCH_ASSOC) : null;

    if (!$row) {
        echo json_encode(["ok" => false, "msg" => "No se encontró el registro en la tabla"], JSON_UNESCAPED_UNICODE);
        exit();
    }
    if ((int)($row['std_reg'] ?? 1) === 1) {
        echo json_encode(["ok" => false, "msg" => "El registro ya está activo"], JSON_UNESCAPED_UNICODE);
        exit();
    }

    $visited = [];
    $restored = [];

    restoreCascade($ins, $tabla, $pkCol, $pkVal, $visited, $restored);

    // (Opcional) registrar evento en log_user como UPDATE/UNKNOWN (si quieres)
    // Aquí no lo forzamos para no interferir con triggers.

    echo json_encode([
        "ok" => true,
        "msg" => "Registro restaurado",
        "restored" => $restored
    ], JSON_UNESCAPED_UNICODE);
} catch (Throwable $e) {
    echo json_encode(["ok" => false, "msg" => "Error interno", "detail" => $e->getMessage()], JSON_UNESCAPED_UNICODE);
}

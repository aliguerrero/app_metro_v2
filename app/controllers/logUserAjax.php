<?php
require_once __DIR__ . "/securityBootstrap.php";

use app\models\mainModel;

header('Content-Type: application/json; charset=utf-8');

error_reporting(E_ALL);
ini_set('display_errors', '0');

try {
    $m = new mainModel();

    appsec_require_admin();

    $action = $_GET['action'] ?? ($_POST['action'] ?? 'list');

    $asString = function ($value): string {
        if ($value === null) return '';
        if (is_array($value) || is_object($value)) return '';
        return trim((string)$value);
    };

    $q = function (string $sql, array $params = []) use ($m) {
        return $m->ejecutarConsultaConParametros($sql, $params);
    };

    $dbStmt = $m->ejecutarConsultas("SELECT DATABASE()");
    $DB = $dbStmt ? (string)$dbStmt->fetchColumn() : '';
    if ($DB === '') {
        throw new \RuntimeException('No se pudo detectar la base de datos activa.');
    }

    $safeIdent = function ($name) {
        return (is_string($name) && preg_match('/^[a-zA-Z0-9_]+$/', $name)) ? $name : null;
    };

    $tableExists = function ($table) use ($q, $DB, $safeIdent): bool {
        $t = $safeIdent($table);
        if (!$t) return false;
        $st = $q(
            "SELECT 1
             FROM information_schema.TABLES
             WHERE TABLE_SCHEMA=:db AND TABLE_NAME=:t
             LIMIT 1",
            [':db' => $DB, ':t' => $t]
        );
        return $st && $st->rowCount() > 0;
    };

    $hasColumn = function ($table, $column) use ($q, $DB, $safeIdent): bool {
        $t = $safeIdent($table);
        $c = $safeIdent($column);
        if (!$t || !$c) return false;
        $st = $q(
            "SELECT 1
             FROM information_schema.COLUMNS
             WHERE TABLE_SCHEMA=:db AND TABLE_NAME=:t AND COLUMN_NAME=:c
             LIMIT 1",
            [':db' => $DB, ':t' => $t, ':c' => $c]
        );
        return $st && $st->rowCount() > 0;
    };

    $getPrimaryKey = function ($table) use ($q, $DB, $safeIdent) {
        $t = $safeIdent($table);
        if (!$t) return null;
        $st = $q(
            "SELECT COLUMN_NAME
             FROM information_schema.COLUMNS
             WHERE TABLE_SCHEMA=:db AND TABLE_NAME=:t AND COLUMN_KEY='PRI'
             ORDER BY ORDINAL_POSITION ASC
             LIMIT 1",
            [':db' => $DB, ':t' => $t]
        );
        $col = $st ? $st->fetchColumn() : null;
        return $safeIdent($col);
    };

    $tableHasStd = function ($table) use ($hasColumn): bool {
        return $hasColumn($table, 'std_reg');
    };

    $detectLogPk = function () use ($hasColumn, $getPrimaryKey, $safeIdent) {
        foreach (['id_log', 'id_ai_log'] as $cand) {
            if ($hasColumn('log_user', $cand)) {
                return $cand;
            }
        }
        return $safeIdent($getPrimaryKey('log_user'));
    };

    $detectLogDateCol = function () use ($hasColumn) {
        foreach (['fecha_hora', 'fecha', 'created_at', 'f_registro', 'f_reg', 'timestamp'] as $cand) {
            if ($hasColumn('log_user', $cand)) return $cand;
        }
        return null;
    };

    $logPk = $detectLogPk() ?: 'id_log';
    $logDateCol = $detectLogDateCol();
    if (!$logDateCol) $logDateCol = $logPk;

    $logHasStd = $hasColumn('log_user', 'std_reg');
    $logHasPkJson = $hasColumn('log_user', 'pk_json');
    $logHasRestoreOp = $hasColumn('log_user', 'operacion')
        && $hasColumn('log_user', 'tabla')
        && $hasColumn('log_user', 'pk_registro');
    $restoreMatchCondition = $logHasPkJson
        ? "(lr.pk_registro = l.pk_registro OR (lr.pk_json IS NOT NULL AND l.pk_json IS NOT NULL AND lr.pk_json = l.pk_json))"
        : "lr.pk_registro = l.pk_registro";

    $logSelect = function ($column, $alias = null) use ($hasColumn, $safeIdent): string {
        $c = $safeIdent((string)$column);
        $a = $safeIdent((string)($alias ?: $column));
        if (!$a) {
            return 'NULL AS invalid_alias';
        }
        if ($c && $hasColumn('log_user', $c)) {
            return "l.`$c` AS `$a`";
        }
        return "NULL AS `$a`";
    };

    $opHuman = function ($op): string {
        $op = strtoupper(trim((string)$op));
        return match ($op) {
            'INSERT' => 'Creacion',
            'UPDATE' => 'Actualizacion',
            'DELETE' => 'Eliminacion fisica',
            'SOFT_DELETE' => 'Eliminacion logica',
            'RESTORE', 'REACTIVAR' => 'Restauracion',
            default => ($op !== '' ? $op : 'Sin operacion'),
        };
    };

    $rowStatusHuman = function (array $row) use ($logHasStd): string {
        $op = strtoupper(trim((string)($row['operacion'] ?? '')));
        $logStd = isset($row['log_std_reg']) ? (int)$row['log_std_reg'] : 1;

        if ($logHasStd && $logStd === 0) return 'Restaurado (oculto)';
        if (in_array($op, ['SOFT_DELETE', 'DELETE'], true)) return 'Pendiente de restauracion';
        if (in_array($op, ['RESTORE', 'REACTIVAR'], true)) return 'Restauracion ejecutada';
        return 'Registrado';
    };

    $accionHuman = function ($tabla, $op, $pk) use ($opHuman): string {
        $modulo = trim((string)$tabla) !== '' ? trim((string)$tabla) : 'modulo';
        $registro = trim((string)$pk) !== '' ? trim((string)$pk) : 'registro';
        return $opHuman($op) . " en {$modulo} ({$registro})";
    };

    $parsePkRegistro = function ($pkStr) use ($safeIdent): array {
        $pkStr = trim((string)$pkStr);
        if ($pkStr === '') return [null, null];

        $parts = explode('=', $pkStr, 2);
        if (count($parts) !== 2) return [null, null];

        $col = $safeIdent(trim($parts[0]));
        $val = trim($parts[1]);
        if (!$col || $val === '') return [null, null];

        return [$col, $val];
    };

    $parsePkJson = function ($pkJson) use ($safeIdent): array {
        if ($pkJson === null || trim((string)$pkJson) === '') return [null, null];
        $decoded = json_decode((string)$pkJson, true);
        if (!is_array($decoded) || !$decoded) return [null, null];

        foreach ($decoded as $k => $v) {
            $key = $safeIdent((string)$k);
            if (!$key) continue;
            if (is_scalar($v) || $v === null) {
                $val = trim((string)$v);
                if ($val !== '') return [$key, $val];
            }
        }
        return [null, null];
    };

    $resolvePkFromLog = function (array $logRow) use ($parsePkRegistro, $parsePkJson): array {
        [$pkCol, $pkVal] = $parsePkRegistro((string)($logRow['pk_registro'] ?? ''));
        if ($pkCol && $pkVal !== null) return [$pkCol, $pkVal];

        [$pkCol2, $pkVal2] = $parsePkJson((string)($logRow['pk_json'] ?? ''));
        if ($pkCol2 && $pkVal2 !== null) return [$pkCol2, $pkVal2];

        return [null, null];
    };

    $jsonToAssoc = function ($value): array {
        if (is_array($value)) return $value;
        if ($value === null) return [];

        $txt = trim((string)$value);
        if ($txt === '' || strtoupper($txt) === 'NULL') return [];

        $decoded = json_decode($txt, true);
        if (json_last_error() !== JSON_ERROR_NONE || !is_array($decoded)) {
            return [];
        }
        return $decoded;
    };

    $toScalarText = function ($value): string {
        if ($value === null) return '';
        if (is_bool($value)) return $value ? '1' : '0';
        if (is_scalar($value)) return trim((string)$value);
        return '';
    };

    $pickBusinessIdFromAssoc = function (array $assoc) use ($toScalarText): string {
        if (!$assoc) return '';

        $priority = [
            'codigo', 'codigo_id', 'cod', 'n_ot', 'id_user', 'id_miembro', 'id_herramienta',
            'id_herramientaot', 'id_ot', 'id_area', 'id_sitio', 'id_turno', 'id_estado',
            'username', 'user', 'uuid', 'event_uuid'
        ];

        $normalized = [];
        foreach ($assoc as $k => $v) {
            if (!is_string($k)) continue;
            $val = $toScalarText($v);
            if ($val === '') continue;
            $normalized[strtolower($k)] = [$k, $val];
        }

        $isAutoNumber = function ($v): bool {
            return (bool)preg_match('/^\d+$/', $v);
        };

        $hasCodeShape = function ($v): bool {
            return (bool)preg_match('/[A-Za-z\-]/', $v);
        };

        foreach ($priority as $p) {
            if (!isset($normalized[$p])) continue;
            [$origKey, $val] = $normalized[$p];
            if ($hasCodeShape($val) || !$isAutoNumber($val) || in_array($p, ['n_ot', 'codigo', 'codigo_id', 'cod'], true)) {
                return $origKey . '=' . $val;
            }
        }

        foreach ($normalized as $lowerKey => [$origKey, $val]) {
            if (!preg_match('/^(id_|codigo|cod|n_ot|uuid|event_uuid)/', $lowerKey)) continue;
            if ($hasCodeShape($val) || !$isAutoNumber($val)) {
                return $origKey . '=' . $val;
            }
        }

        return '';
    };

    $buildRegistroLabel = function (array $row) use ($jsonToAssoc, $pickBusinessIdFromAssoc, $toScalarText): string {
        $pkRegistro = trim((string)($row['pk_registro'] ?? ''));

        $pkAssoc = $jsonToAssoc($row['pk_json'] ?? null);
        $newAssoc = $jsonToAssoc($row['data_new'] ?? null);
        $oldAssoc = $jsonToAssoc($row['data_old'] ?? null);

        $candidate = $pickBusinessIdFromAssoc($pkAssoc);
        if ($candidate === '') $candidate = $pickBusinessIdFromAssoc($newAssoc);
        if ($candidate === '') $candidate = $pickBusinessIdFromAssoc($oldAssoc);

        if ($candidate !== '') return $candidate;

        if ($pkRegistro !== '') return $pkRegistro;

        if ($pkAssoc) {
            $pairs = [];
            foreach ($pkAssoc as $k => $v) {
                if (!is_string($k)) continue;
                $txt = $toScalarText($v);
                if ($txt === '') continue;
                $pairs[] = $k . '=' . $txt;
            }
            if ($pairs) return implode(', ', $pairs);
        }

        return '-';
    };

    $inferChangedCols = function (array $row) use ($jsonToAssoc): string {
        $changed = trim((string)($row['changed_cols'] ?? ''));
        if ($changed !== '') return $changed;

        $diff = $jsonToAssoc($row['data_diff'] ?? null);
        if ($diff) {
            $keys = array_keys($diff);
            $keys = array_values(array_filter($keys, fn($k) => is_string($k) && trim($k) !== ''));
            if ($keys) return implode(', ', $keys);
        }

        $old = $jsonToAssoc($row['data_old'] ?? null);
        $new = $jsonToAssoc($row['data_new'] ?? null);
        if (!$old && !$new) return '';

        $keys = array_unique(array_merge(array_keys($old), array_keys($new)));
        $changedKeys = [];

        foreach ($keys as $k) {
            if (!is_string($k) || trim($k) === '') continue;
            $oldVal = $old[$k] ?? null;
            $newVal = $new[$k] ?? null;
            if (json_encode($oldVal, JSON_UNESCAPED_UNICODE) !== json_encode($newVal, JSON_UNESCAPED_UNICODE)) {
                $changedKeys[] = $k;
            }
        }

        return $changedKeys ? implode(', ', $changedKeys) : '';
    };

    $buildDetailSummary = function (array $row) use ($inferChangedCols): string {
        $op = strtoupper(trim((string)($row['operacion'] ?? '')));
        $accion = trim((string)($row['accion'] ?? ''));
        $resp = trim((string)($row['resp_system'] ?? ''));
        $changed = $inferChangedCols($row);

        if ($op === 'UPDATE' && $changed !== '') return 'Campos modificados: ' . $changed;
        if (in_array($op, ['SOFT_DELETE', 'DELETE'], true)) return 'Registro marcado como eliminado.';
        if (in_array($op, ['RESTORE', 'REACTIVAR'], true)) return 'Registro restaurado.';

        if ($accion !== '') return $accion;
        if ($resp !== '') return $resp;
        if ($changed !== '') return 'Campos modificados: ' . $changed;

        return 'Sin detalle';
    };

    $recordStdState = function ($table, $pkCol, $pkVal) use ($q, $tableExists, $tableHasStd, $safeIdent) {
        $table = $safeIdent($table);
        $pkCol = $safeIdent($pkCol);
        if (!$table || !$pkCol) return null;
        if (!$tableExists($table) || !$tableHasStd($table)) return null;

        $st = $q(
            "SELECT std_reg
             FROM `$table`
             WHERE `$pkCol` = :pk
             LIMIT 1",
            [':pk' => $pkVal]
        );
        if (!$st || $st->rowCount() <= 0) return null;

        $row = $st->fetch(\PDO::FETCH_ASSOC);
        if (!isset($row['std_reg'])) return null;
        return (int)$row['std_reg'] === 1 ? 1 : 0;
    };

    $getFKParents = function ($table) use ($q, $DB, $safeIdent): array {
        $t = $safeIdent($table);
        if (!$t) return [];

        $st = $q(
            "SELECT COLUMN_NAME, REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME
             FROM information_schema.KEY_COLUMN_USAGE
             WHERE TABLE_SCHEMA=:db
               AND TABLE_NAME=:t
               AND REFERENCED_TABLE_NAME IS NOT NULL",
            [':db' => $DB, ':t' => $t]
        );
        return $st ? $st->fetchAll(\PDO::FETCH_ASSOC) : [];
    };

    $getFKChildren = function ($table) use ($q, $DB, $safeIdent): array {
        $t = $safeIdent($table);
        if (!$t) return [];

        $st = $q(
            "SELECT TABLE_NAME AS CHILD_TABLE, COLUMN_NAME AS CHILD_FK
             FROM information_schema.KEY_COLUMN_USAGE
             WHERE TABLE_SCHEMA=:db
               AND REFERENCED_TABLE_NAME=:t",
            [':db' => $DB, ':t' => $t]
        );
        return $st ? $st->fetchAll(\PDO::FETCH_ASSOC) : [];
    };

    $restoreCascade = null;
    $restoreCascade = function ($table, $pkColName, $pkVal, &$restored = [], &$visited = []) use (
        &$restoreCascade,
        $q,
        $tableExists,
        $tableHasStd,
        $getFKParents,
        $getFKChildren,
        $getPrimaryKey,
        $safeIdent
    ) {
        $table = $safeIdent($table);
        $pkColName = $safeIdent($pkColName);

        if (!$table || !$pkColName) {
            $restored[] = ['table' => (string)$table, 'pk' => 'invalid', 'status' => 'invalid_ident'];
            return;
        }

        if (!$tableExists($table)) {
            $restored[] = ['table' => $table, 'pk' => "$pkColName=$pkVal", 'status' => 'table_not_found'];
            return;
        }

        $key = $table . '|' . $pkColName . '=' . $pkVal;
        if (isset($visited[$key])) return;
        $visited[$key] = true;

        if (!$tableHasStd($table)) {
            $restored[] = ['table' => $table, 'pk' => "$pkColName=$pkVal", 'status' => 'skip_no_std_reg'];
            return;
        }

        $stmt = $q(
            "SELECT " . $m->columnasTablaSql($table) . " FROM `$table` WHERE `$pkColName` = :pk LIMIT 1",
            [':pk' => $pkVal]
        );
        if (!$stmt || $stmt->rowCount() <= 0) {
            $restored[] = ['table' => $table, 'pk' => "$pkColName=$pkVal", 'status' => 'not_found'];
            return;
        }
        $row = $stmt->fetch(\PDO::FETCH_ASSOC);

        foreach ($getFKParents($table) as $fk) {
            $col = $fk['COLUMN_NAME'] ?? '';
            $parentT = $fk['REFERENCED_TABLE_NAME'] ?? '';
            $parentPk = $fk['REFERENCED_COLUMN_NAME'] ?? '';

            if (!$col || !$parentT || !$parentPk) continue;
            if (!array_key_exists($col, $row)) continue;

            $parentVal = $row[$col];
            if ($parentVal === null || $parentVal === '') continue;

            $restoreCascade($parentT, $parentPk, $parentVal, $restored, $visited);
            if ($tableHasStd($parentT)) {
                $q("UPDATE `$parentT` SET std_reg=1 WHERE `$parentPk`=:v AND std_reg=0", [':v' => $parentVal]);
            }
        }

        $q("UPDATE `$table` SET std_reg=1 WHERE `$pkColName`=:pk AND std_reg=0", [':pk' => $pkVal]);
        $restored[] = ['table' => $table, 'pk' => "$pkColName=$pkVal", 'status' => 'restored_or_already_active'];

        foreach ($getFKChildren($table) as $child) {
            $childT = $safeIdent($child['CHILD_TABLE'] ?? '');
            $childFk = $safeIdent($child['CHILD_FK'] ?? '');

            if (!$childT || !$childFk) continue;
            if (!$tableHasStd($childT)) continue;

            $childPk = $safeIdent($getPrimaryKey($childT));
            if (!$childPk) continue;

            $st2 = $q("SELECT `$childPk` FROM `$childT` WHERE `$childFk`=:v AND std_reg=0", [':v' => $pkVal]);
            if (!$st2) continue;

            while ($r2 = $st2->fetch(\PDO::FETCH_ASSOC)) {
                $restoreCascade($childT, $childPk, $r2[$childPk], $restored, $visited);
            }
        }
    };

    if ($action === 'filters') {
        $tablas = $q("SELECT DISTINCT tabla FROM log_user WHERE tabla IS NOT NULL AND tabla <> '' ORDER BY tabla ASC");
        $ops = $q("SELECT DISTINCT operacion FROM log_user WHERE operacion IS NOT NULL AND operacion <> '' ORDER BY operacion ASC");
        $usuarios = $q(
            "SELECT DISTINCT l.id_user, COALESCE(e.nombre_empleado, l.id_user) AS user
             FROM log_user l
             LEFT JOIN empleado e ON e.id_empleado = l.id_user
             WHERE l.id_user IS NOT NULL AND l.id_user <> ''
             ORDER BY user ASC"
        );

        $outTablas = $tablas ? $tablas->fetchAll(\PDO::FETCH_ASSOC) : [];
        $outOpsRaw = $ops ? $ops->fetchAll(\PDO::FETCH_ASSOC) : [];
        $outUsers = $usuarios ? $usuarios->fetchAll(\PDO::FETCH_ASSOC) : [];

        $outOps = array_map(function ($item) use ($opHuman) {
            $op = $item['operacion'] ?? '';
            return ['operacion' => $op, 'label' => $opHuman($op)];
        }, $outOpsRaw);

        echo json_encode([
            'ok' => true,
            'tablas' => $outTablas,
            'operaciones' => $outOps,
            'usuarios' => $outUsers,
            'date_col' => $logDateCol,
            'log_std_supported' => $logHasStd ? 1 : 0,
            'default_state' => 'active'
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    if ($action === 'list') {
        $page = max(1, (int)$asString($_GET['page'] ?? 1));
        $perPage = max(10, min(100, (int)$asString($_GET['perPage'] ?? 20)));

        $qText = $asString($_GET['q'] ?? '');
        $tabla = $asString($_GET['tabla'] ?? '');
        $operacion = $asString($_GET['operacion'] ?? '');
        $usuario = $asString($_GET['usuario'] ?? '');
        $desde = $asString($_GET['desde'] ?? '');
        $hasta = $asString($_GET['hasta'] ?? '');
        $estadoLog = strtolower($asString($_GET['estado_log'] ?? 'active'));
        if (!in_array($estadoLog, ['active', 'restored', 'all'], true)) {
            $estadoLog = 'active';
        }

        $where = " WHERE 1=1 ";
        $params = [];

        if ($qText !== '') {
            $where .= " AND (
                l.tabla LIKE :q
                OR l.operacion LIKE :q
                OR l.pk_registro LIKE :q
                OR l.accion LIKE :q
                OR l.id_user LIKE :q
                OR COALESCE(e.nombre_empleado, '') LIKE :q
            ) ";
            $params[':q'] = '%' . $qText . '%';
        }
        if ($tabla !== '') {
            $where .= " AND l.tabla = :tabla ";
            $params[':tabla'] = $tabla;
        }
        if ($operacion !== '') {
            $where .= " AND l.operacion = :op ";
            $params[':op'] = $operacion;
        }
        if ($usuario !== '') {
            $where .= " AND l.id_user = :u ";
            $params[':u'] = $usuario;
        }
        if ($desde !== '' && $logDateCol) {
            $where .= " AND DATE(l.`$logDateCol`) >= :d1 ";
            $params[':d1'] = $desde;
        }
        if ($hasta !== '' && $logDateCol) {
            $where .= " AND DATE(l.`$logDateCol`) <= :d2 ";
            $params[':d2'] = $hasta;
        }

        if ($estadoLog === 'active') {
            if ($logHasStd) {
                $where .= " AND l.std_reg = 1 ";
            }
            if ($logHasRestoreOp) {
                $where .= " AND NOT (
                    l.operacion IN ('SOFT_DELETE', 'DELETE')
                    AND EXISTS (
                        SELECT 1
                        FROM log_user lr
                        WHERE lr.tabla = l.tabla
                          AND $restoreMatchCondition
                          AND lr.operacion IN ('RESTORE', 'REACTIVAR')
                          AND lr.`$logPk` > l.`$logPk`
                    )
                ) ";
            }
        } elseif ($estadoLog === 'restored') {
            if ($logHasStd) {
                $where .= " AND l.std_reg = 0 ";
            } elseif ($logHasRestoreOp) {
                $where .= " AND l.operacion IN ('RESTORE', 'REACTIVAR') ";
            }
        }

        $stCount = $q(
            "SELECT COUNT(1) AS c
             FROM log_user l
             LEFT JOIN empleado e ON e.id_empleado = l.id_user
             $where",
            $params
        );
        $total = $stCount ? (int)$stCount->fetchColumn() : 0;

        $pages = max(1, (int)ceil($total / $perPage));
        if ($page > $pages) $page = $pages;
        $offset = ($page - 1) * $perPage;

        $select = implode(",\n                ", [
            "l.`$logPk` AS id",
            "l.`$logDateCol` AS fecha",
            "l.id_user",
            "COALESCE(e.nombre_empleado, l.id_user) AS usuario",
            $logSelect('tabla', 'tabla'),
            $logSelect('operacion', 'operacion'),
            $logSelect('pk_registro', 'pk_registro'),
            $logSelect('pk_json', 'pk_json'),
            $logSelect('accion', 'accion'),
            $logSelect('resp_system', 'resp_system'),
            $logSelect('changed_cols', 'changed_cols'),
            $logSelect('data_old', 'data_old'),
            $logSelect('data_new', 'data_new'),
            $logSelect('data_diff', 'data_diff'),
            ($logHasStd ? "l.std_reg" : "1") . " AS log_std_reg"
        ]);

        $sql = "
            SELECT
                $select
            FROM log_user l
            LEFT JOIN empleado e ON e.id_empleado = l.id_user
            $where
            ORDER BY l.`$logDateCol` DESC, l.`$logPk` DESC
            LIMIT $perPage OFFSET $offset
        ";

        $st = $q($sql, $params);
        $rows = $st ? $st->fetchAll(\PDO::FETCH_ASSOC) : [];

        foreach ($rows as &$row) {
            $row['op_human'] = $opHuman($row['operacion'] ?? '');
            $row['status_human'] = $rowStatusHuman($row);
            $row['changed_cols'] = $inferChangedCols($row);
            $row['registro_label'] = $buildRegistroLabel($row);
            $row['detail_summary'] = $buildDetailSummary($row);

            unset($row['data_old'], $row['data_new'], $row['data_diff'], $row['pk_json']);
        }

        $from = $total > 0 ? ($offset + 1) : 0;
        $to = min($total, $offset + count($rows));

        echo json_encode([
            'ok' => true,
            'rows' => $rows,
            'meta' => [
                'page' => $page,
                'perPage' => $perPage,
                'total' => $total,
                'pages' => $pages,
                'from' => $from,
                'to' => $to
            ],
            'log_std_supported' => $logHasStd ? 1 : 0
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    if ($action === 'detail') {
        $id = $asString($_GET['id'] ?? '');
        if ($id === '') {
            echo json_encode(['ok' => false, 'msg' => 'ID invalido'], JSON_UNESCAPED_UNICODE);
            exit();
        }

        $select = implode(",\n                ", [
            "l.`$logPk` AS id",
            $logSelect($logDateCol, 'fecha'),
            $logSelect('id_user', 'id_user'),
            "COALESCE(e.nombre_empleado, l.id_user) AS usuario",
            $logSelect('tabla', 'tabla'),
            $logSelect('operacion', 'operacion'),
            $logSelect('pk_registro', 'pk_registro'),
            $logSelect('pk_json', 'pk_json'),
            $logSelect('accion', 'accion'),
            $logSelect('resp_system', 'resp_system'),
            $logSelect('event_uuid', 'event_uuid'),
            $logSelect('data_old', 'data_old'),
            $logSelect('data_new', 'data_new'),
            $logSelect('data_diff', 'data_diff'),
            $logSelect('changed_cols', 'changed_cols'),
            ($logHasStd ? "l.std_reg" : "1") . " AS log_std_reg"
        ]);

        $st = $q(
            "SELECT
                $select
             FROM log_user l
             LEFT JOIN empleado e ON e.id_empleado = l.id_user
             WHERE l.`$logPk` = :id
             LIMIT 1",
            [':id' => $id]
        );

        if (!$st || $st->rowCount() <= 0) {
            echo json_encode(['ok' => false, 'msg' => 'Registro no encontrado'], JSON_UNESCAPED_UNICODE);
            exit();
        }

        $row = $st->fetch(\PDO::FETCH_ASSOC);
        $op = strtoupper(trim((string)($row['operacion'] ?? '')));

        $row['op_human'] = $opHuman($row['operacion'] ?? '');
        $row['changed_cols'] = $inferChangedCols($row);
        $row['registro_label'] = $buildRegistroLabel($row);
        $row['detail_summary'] = $buildDetailSummary($row);
        $row['accion_human'] = $accionHuman($row['tabla'] ?? '', $row['operacion'] ?? '', $row['registro_label'] ?? ($row['pk_registro'] ?? ''));
        $row['status_human'] = $rowStatusHuman($row);

        [$pkCol, $pkVal] = $resolvePkFromLog($row);
        $targetStd = null;
        $canRestore = false;
        $hint = 'Este evento no es restaurable.';

        if (in_array($op, ['SOFT_DELETE', 'DELETE'], true)) {
            if (!($row['tabla'] ?? '') || !$tableExists($row['tabla'])) {
                $hint = 'La tabla objetivo ya no existe o no es valida.';
            } elseif (!$tableHasStd($row['tabla'])) {
                $hint = 'La tabla objetivo no maneja std_reg, por lo que no puede restaurarse logicamente.';
            } elseif (!$pkCol || $pkVal === null) {
                $hint = 'No se pudo interpretar la clave primaria desde pk_registro/pk_json.';
            } else {
                $targetStd = $recordStdState($row['tabla'], $pkCol, $pkVal);
                if ($targetStd === 0) {
                    $canRestore = true;
                    $hint = 'Se reactivara este registro y dependencias relacionadas que esten desactivadas.';
                } elseif ($targetStd === 1) {
                    $hint = 'El registro objetivo ya esta activo, no requiere restauracion.';
                } else {
                    $hint = 'No se encontro el registro objetivo en la tabla.';
                }
            }
        }

        $row['pk_col'] = $pkCol;
        $row['pk_val'] = $pkVal;
        $row['pk_tecnico'] = trim((string)($row['pk_registro'] ?? '')) !== '' ? trim((string)$row['pk_registro']) : '-';
        $row['target_std_reg'] = $targetStd;
        $row['can_restore'] = $canRestore ? 1 : 0;
        $row['restore_hint'] = $hint;

        echo json_encode(['ok' => true, 'row' => $row], JSON_UNESCAPED_UNICODE);
        exit();
    }

    if ($action === 'restore') {
        appsec_require_admin();

        $id = $asString($_POST['id'] ?? '');
        if ($id === '') {
            echo json_encode(['ok' => false, 'msg' => 'ID invalido'], JSON_UNESCAPED_UNICODE);
            exit();
        }

        $select = implode(", ", [
            "l.`$logPk` AS id",
            $logSelect('tabla', 'tabla'),
            $logSelect('operacion', 'operacion'),
            $logSelect('pk_registro', 'pk_registro'),
            $logSelect('pk_json', 'pk_json')
        ]);

        $st = $q(
            "SELECT $select
             FROM log_user l
             WHERE l.`$logPk` = :id
             LIMIT 1",
            [':id' => $id]
        );

        if (!$st || $st->rowCount() <= 0) {
            echo json_encode(['ok' => false, 'msg' => 'Log no encontrado'], JSON_UNESCAPED_UNICODE);
            exit();
        }

        $log = $st->fetch(\PDO::FETCH_ASSOC);
        $table = (string)($log['tabla'] ?? '');
        $op = strtoupper(trim((string)($log['operacion'] ?? '')));

        if (!in_array($op, ['SOFT_DELETE', 'DELETE'], true)) {
            echo json_encode(['ok' => false, 'msg' => 'Solo se puede restaurar desde un evento de eliminacion.'], JSON_UNESCAPED_UNICODE);
            exit();
        }

        if (!$tableExists($table)) {
            echo json_encode(['ok' => false, 'msg' => 'Tabla objetivo invalida o inexistente.'], JSON_UNESCAPED_UNICODE);
            exit();
        }

        if (!$tableHasStd($table)) {
            echo json_encode(['ok' => false, 'msg' => 'La tabla objetivo no soporta restauracion logica (std_reg).'], JSON_UNESCAPED_UNICODE);
            exit();
        }

        [$pkCol, $pkVal] = $resolvePkFromLog($log);
        if (!$pkCol || $pkVal === null) {
            echo json_encode(['ok' => false, 'msg' => 'No se pudo interpretar la clave primaria del registro.'], JSON_UNESCAPED_UNICODE);
            exit();
        }

        $targetStd = $recordStdState($table, $pkCol, $pkVal);
        if ($targetStd === null) {
            echo json_encode(['ok' => false, 'msg' => 'El registro objetivo no fue encontrado en la tabla.'], JSON_UNESCAPED_UNICODE);
            exit();
        }
        if ($targetStd === 1) {
            echo json_encode(['ok' => false, 'msg' => 'El registro ya se encuentra activo.'], JSON_UNESCAPED_UNICODE);
            exit();
        }

        $restored = [];
        $visited = [];
        $restoreCascade($table, $pkCol, $pkVal, $restored, $visited);

        $logHidden = false;
        $warning = null;

        if ($logHasStd) {
            try {
                $q("UPDATE log_user SET std_reg=0 WHERE `$logPk`=:id", [':id' => $id]);
                $stStd = $q("SELECT std_reg FROM log_user WHERE `$logPk`=:id LIMIT 1", [':id' => $id]);
                $stdRow = $stStd ? $stStd->fetch(\PDO::FETCH_ASSOC) : null;
                $logHidden = ($stdRow && isset($stdRow['std_reg']) && (int)$stdRow['std_reg'] === 0);
                if (!$logHidden) {
                    $warning = 'Se restauro el registro, pero no se pudo inactivar este log.';
                }
            } catch (\Throwable $t) {
                $warning = 'Se restauro el registro, pero la base de datos bloqueo inactivar este log.';
            }
        }

        echo json_encode([
            'ok' => true,
            'msg' => 'Restauracion ejecutada',
            'restored' => $restored,
            'log_hidden' => $logHidden ? 1 : 0,
            'warning' => $warning
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    echo json_encode(['ok' => false, 'msg' => 'Accion no valida'], JSON_UNESCAPED_UNICODE);
} catch (\Throwable $e) {
    echo json_encode([
        'ok' => false,
        'msg' => 'Error interno',
        'detail' => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}

<?php

namespace app\controllers;

use app\models\mainModel;
use DateTimeImmutable;
use PDO;
use RuntimeException;

class dbBackupController extends mainModel
{
    private string $backupDir;

    public function __construct()
    {
        $this->backupDir = dirname(__DIR__, 2) . DIRECTORY_SEPARATOR . 'db' . DIRECTORY_SEPARATOR . 'backups';
    }

    public function assertAdmin(): void
    {
        if (!isset($_SESSION['tipo']) || (int)$_SESSION['tipo'] !== 1) {
            throw new RuntimeException('Solo un administrador puede gestionar respaldos de base de datos.', 403);
        }
    }

    public function listBackups(): array
    {
        $this->ensureBackupDirectory();

        $files = glob($this->backupDir . DIRECTORY_SEPARATOR . '*.sql') ?: [];

        usort($files, static function (string $a, string $b): int {
            return filemtime($b) <=> filemtime($a);
        });

        $result = [];
        foreach ($files as $path) {
            if (!is_file($path)) {
                continue;
            }

            $fileName = basename($path);
            $createdAt = $this->inferBackupDateFromFilename($fileName);
            if ($createdAt === null) {
                $createdAt = date('Y-m-d H:i:s', (int)filemtime($path));
            }

            $result[] = [
                'file' => $fileName,
                'size' => (int)filesize($path),
                'created_at' => $createdAt,
                'modified_at' => date('Y-m-d H:i:s', (int)filemtime($path)),
                'relative_path' => 'db/backups/' . $fileName
            ];
        }

        return $result;
    }

    public function createBackup(array $selectedTables = [], string $origin = 'manual'): array
    {
        $this->ensureBackupDirectory();

        $pdo = $this->connectAsAuth();
        $availableTables = $this->fetchBaseTables($pdo);
        $requestedTables = $this->normalizeTableList($selectedTables);

        $isPartial = $requestedTables !== [];
        if ($isPartial) {
            $invalid = array_values(array_diff($requestedTables, array_keys($availableTables)));
            if ($invalid !== []) {
                throw new RuntimeException('Hay tablas invalidas en la seleccion: ' . implode(', ', $invalid));
            }
            $tablesToExport = $requestedTables;
        } else {
            $tablesToExport = array_keys($availableTables);
        }

        if ($tablesToExport === []) {
            throw new RuntimeException('No hay tablas disponibles para exportar.');
        }

        sort($tablesToExport, SORT_STRING);

        $dbName = preg_replace('/[^a-zA-Z0-9_-]/', '_', (string)DB_NAME);
        $fileScope = 'general';
        $backupKind = 'full';

        if ($isPartial) {
            if (count($tablesToExport) === 1) {
                $tableTag = strtolower($tablesToExport[0]);
                $fileScope = 'tabla_' . $tableTag;
                $backupKind = 'single_table';
            } else {
                $fileScope = 'tablas_' . count($tablesToExport) . 'tbl';
                $backupKind = 'multi_table';
            }
        }

        $originTag = strtolower(trim($origin));
        if (!in_array($originTag, ['manual', 'auto'], true)) {
            $originTag = 'manual';
        }

        $fileName = $dbName . '_backup_' . ($originTag === 'auto' ? 'auto_' : '') . $fileScope . '_' . date('Ymd_His') . '.sql';
        $fullPath = $this->backupDir . DIRECTORY_SEPARATOR . $fileName;

        $this->writeDumpToFile($fullPath, $tablesToExport, $isPartial);

        return [
            'file' => $fileName,
            'path' => $fullPath,
            'is_partial' => $isPartial,
            'tables' => $tablesToExport,
            'backup_kind' => $backupKind,
            'origin' => $originTag
        ];
    }

    public function listDatabaseTables(): array
    {
        $pdo = $this->connectAsAuth();
        $tables = $this->fetchBaseTables($pdo);

        return array_values($tables);
    }

    public function getAutoBackupConfig(): array
    {
        $pdo = $this->connectAsAuth();
        $row = $this->loadAutoConfigRow($pdo);
        $tables = $this->decodeJsonTables((string)($row['tables_json'] ?? '[]'));
        $mode = (string)($row['mode'] ?? 'full');
        $frequency = (string)($row['frequency'] ?? 'daily');
        $runTime = $this->normalizeTimeValue((string)($row['run_time'] ?? '02:00'));
        $weekday = $this->safeInt($row['weekday'] ?? 1, 1);
        $monthDay = $this->safeInt($row['month_day'] ?? 1, 1);
        $enabled = ((int)($row['enabled'] ?? 0)) === 1;
        $retainCount = $this->safeInt($row['retain_count'] ?? 30, 30);
        $runnerToken = (string)($row['runner_token'] ?? '');

        $normalized = [
            'enabled' => $enabled ? 1 : 0,
            'frequency' => in_array($frequency, ['daily', 'weekly', 'monthly'], true) ? $frequency : 'daily',
            'run_time' => $runTime,
            'weekday' => max(1, min(7, $weekday)),
            'month_day' => max(1, min(31, $monthDay)),
            'mode' => in_array($mode, ['full', 'specific'], true) ? $mode : 'full',
            'tables' => $tables,
            'retain_count' => max(0, min(365, $retainCount)),
            'runner_token' => $runnerToken,
            'last_run_at' => $row['last_run_at'] ?? null,
            'last_file' => $row['last_file'] ?? null,
        ];

        $normalized['next_run_at'] = $this->calculateNextRunAt($normalized);

        return $normalized;
    }

    public function saveAutoBackupConfig(array $input): array
    {
        $pdo = $this->connectAsAuth();
        $this->ensureAutoConfigTable($pdo);

        $current = $this->getAutoBackupConfig();
        $availableTables = array_column($this->listDatabaseTables(), 'name');
        $availableMap = array_fill_keys($availableTables, true);

        $enabled = isset($input['enabled']) ? ((string)$input['enabled'] === '1' ? 1 : 0) : (int)$current['enabled'];

        $frequency = isset($input['frequency']) ? strtolower(trim((string)$input['frequency'])) : (string)$current['frequency'];
        if (!in_array($frequency, ['daily', 'weekly', 'monthly'], true)) {
            throw new RuntimeException('Frecuencia de respaldo automatico invalida.');
        }

        $runTime = isset($input['run_time']) ? $this->normalizeTimeValue((string)$input['run_time']) : (string)$current['run_time'];

        $weekday = isset($input['weekday']) ? $this->safeInt($input['weekday'], 1) : (int)$current['weekday'];
        $weekday = max(1, min(7, $weekday));

        $monthDay = isset($input['month_day']) ? $this->safeInt($input['month_day'], 1) : (int)$current['month_day'];
        $monthDay = max(1, min(31, $monthDay));

        $mode = isset($input['mode']) ? strtolower(trim((string)$input['mode'])) : (string)$current['mode'];
        if (!in_array($mode, ['full', 'specific'], true)) {
            throw new RuntimeException('Modo de respaldo automatico invalido.');
        }

        $tables = [];
        if (isset($input['tables']) && is_array($input['tables'])) {
            $tables = $this->normalizeTableList($input['tables']);
        } elseif ($mode === 'specific') {
            $tables = is_array($current['tables']) ? $current['tables'] : [];
        }

        if ($mode === 'specific') {
            if ($tables === []) {
                throw new RuntimeException('Debes seleccionar al menos una tabla para el respaldo automatico especifico.');
            }

            $invalid = [];
            foreach ($tables as $table) {
                if (!isset($availableMap[$table])) {
                    $invalid[] = $table;
                }
            }
            if ($invalid !== []) {
                throw new RuntimeException('Hay tablas invalidas en el respaldo automatico: ' . implode(', ', $invalid));
            }
        } else {
            $tables = [];
        }

        $retainCount = isset($input['retain_count']) ? $this->safeInt($input['retain_count'], 30) : (int)$current['retain_count'];
        $retainCount = max(0, min(365, $retainCount));

        $runnerToken = (string)$current['runner_token'];
        $rotateToken = isset($input['rotate_token']) && ((string)$input['rotate_token'] === '1');
        if ($runnerToken === '' || $rotateToken) {
            $runnerToken = $this->generateRunnerToken();
        }

        $sql = "UPDATE backup_auto_config
                SET enabled = :enabled,
                    frequency = :frequency,
                    run_time = :run_time,
                    weekday = :weekday,
                    month_day = :month_day,
                    mode = :mode,
                    tables_json = :tables_json,
                    retain_count = :retain_count,
                    runner_token = :runner_token,
                    updated_at = NOW()
                WHERE id = 1";

        $stmt = $pdo->prepare($sql);
        $stmt->execute([
            ':enabled' => $enabled,
            ':frequency' => $frequency,
            ':run_time' => $runTime,
            ':weekday' => $weekday,
            ':month_day' => $monthDay,
            ':mode' => $mode,
            ':tables_json' => json_encode(array_values($tables), JSON_UNESCAPED_UNICODE),
            ':retain_count' => $retainCount,
            ':runner_token' => $runnerToken
        ]);

        return $this->getAutoBackupConfig();
    }

    public function validateAutoRunnerToken(string $token): bool
    {
        $token = trim($token);
        if ($token === '') {
            return false;
        }

        $cfg = $this->getAutoBackupConfig();
        $expected = (string)($cfg['runner_token'] ?? '');
        if ($expected === '') {
            return false;
        }

        return hash_equals($expected, $token);
    }

    public function runAutomaticBackup(bool $force = false): array
    {
        $cfg = $this->getAutoBackupConfig();
        if ((int)$cfg['enabled'] !== 1 && !$force) {
            return [
                'ran' => false,
                'reason' => 'disabled',
                'next_run_at' => null,
                'config' => $cfg
            ];
        }

        if (!$force && !$this->isAutoBackupDueNow($cfg)) {
            return [
                'ran' => false,
                'reason' => 'not_due',
                'next_run_at' => $cfg['next_run_at'] ?? null,
                'config' => $cfg
            ];
        }

        $tables = ((string)$cfg['mode'] === 'specific') ? (array)$cfg['tables'] : [];
        $backup = $this->createBackup($tables, 'auto');

        $pdo = $this->connectAsAuth();
        $this->ensureAutoConfigTable($pdo);
        $stmt = $pdo->prepare("UPDATE backup_auto_config
                               SET last_run_at = NOW(),
                                   last_file = :last_file,
                                   updated_at = NOW()
                               WHERE id = 1");
        $stmt->execute([':last_file' => (string)$backup['file']]);

        $this->purgeOldAutoBackups((int)$cfg['retain_count']);

        $updatedCfg = $this->getAutoBackupConfig();

        return [
            'ran' => true,
            'backup' => $backup,
            'next_run_at' => $updatedCfg['next_run_at'] ?? null,
            'config' => $updatedCfg
        ];
    }

    public function resolveBackupPath(string $fileName): string
    {
        $file = basename((string)$fileName);

        if ($file === '' || !preg_match('/^[a-zA-Z0-9._-]+\.sql$/', $file)) {
            throw new RuntimeException('Nombre de respaldo invalido.');
        }

        $fullPath = $this->backupDir . DIRECTORY_SEPARATOR . $file;
        if (!is_file($fullPath)) {
            throw new RuntimeException('No se encontro el respaldo solicitado.');
        }

        return $fullPath;
    }

    public function deleteBackup(string $fileName): void
    {
        $fullPath = $this->resolveBackupPath($fileName);

        if (!@unlink($fullPath)) {
            throw new RuntimeException('No se pudo eliminar el respaldo.');
        }
    }

    public function restoreFromFile(string $sourceFilePath): int
    {
        if (!is_file($sourceFilePath) || !is_readable($sourceFilePath)) {
            throw new RuntimeException('El archivo de restauracion no es valido o no se puede leer.');
        }

        $pdo = $this->connectAsAuth();
        $handle = fopen($sourceFilePath, 'rb');
        if ($handle === false) {
            throw new RuntimeException('No se pudo abrir el archivo para restaurar.');
        }

        $executed = 0;
        $delimiter = ';';
        $statement = '';
        $firstLine = true;

        try {
            $pdo->exec("SET FOREIGN_KEY_CHECKS=0");
            $pdo->exec("SET UNIQUE_CHECKS=0");
            $pdo->exec("SET SQL_NOTES=0");

            while (($line = fgets($handle)) !== false) {
                if ($firstLine) {
                    $line = preg_replace('/^\xEF\xBB\xBF/', '', $line);
                    $firstLine = false;
                }

                $trimmed = trim($line);
                if ($trimmed === '') {
                    continue;
                }

                if (preg_match('/^DELIMITER\s+(.+)$/i', $trimmed, $match)) {
                    $delimiter = (string)$match[1];
                    continue;
                }

                if ($delimiter === ';' && preg_match('/^(--\s|#)/', $trimmed)) {
                    continue;
                }

                $statement .= $line;

                if (!$this->statementEndsWithDelimiter($statement, $delimiter)) {
                    continue;
                }

                $sql = rtrim($statement);
                $sql = substr($sql, 0, -strlen($delimiter));
                $sql = trim($sql);
                $statement = '';

                if ($sql === '') {
                    continue;
                }

                $pdo->exec($sql);
                $executed++;
            }

            $remaining = trim($statement);
            if ($remaining !== '') {
                $pdo->exec($remaining);
                $executed++;
            }
        } finally {
            fclose($handle);
            $pdo->exec("SET FOREIGN_KEY_CHECKS=1");
            $pdo->exec("SET UNIQUE_CHECKS=1");
            $pdo->exec("SET SQL_NOTES=1");
        }

        return $executed;
    }

    private function ensureBackupDirectory(): void
    {
        if (!is_dir($this->backupDir) && !mkdir($this->backupDir, 0775, true) && !is_dir($this->backupDir)) {
            throw new RuntimeException('No se pudo crear el directorio de respaldos.');
        }
    }

    private function writeDumpToFile(string $fullPath, array $tablesToExport, bool $isPartial): void
    {
        $pdo = $this->connectAsAuth();
        $fh = fopen($fullPath, 'wb');
        $tableSet = array_fill_keys($tablesToExport, true);

        if ($fh === false) {
            throw new RuntimeException('No se pudo crear el archivo de respaldo.');
        }

        try {
            $this->writeLine($fh, '-- ========================================');
            $this->writeLine($fh, '-- Respaldo de base de datos');
            $this->writeLine($fh, '-- DB: ' . DB_NAME);
            $this->writeLine($fh, '-- Fecha: ' . date('Y-m-d H:i:s'));
            $this->writeLine($fh, '-- Tipo: ' . ($isPartial ? 'PARCIAL' : 'COMPLETO'));
            $this->writeLine($fh, '-- Tablas incluidas: ' . implode(', ', $tablesToExport));
            $this->writeLine($fh, '-- ========================================');
            $this->writeLine($fh, '');

            $this->writeLine($fh, 'SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";');
            $this->writeLine($fh, 'SET time_zone = "+00:00";');
            $this->writeLine($fh, 'SET FOREIGN_KEY_CHECKS=0;');
            $this->writeLine($fh, 'SET UNIQUE_CHECKS=0;');
            $this->writeLine($fh, '');

            foreach ($tablesToExport as $tableName) {

                $tableId = $this->qi($tableName);
                $columnIds = array_map(fn(string $column): string => $this->qi($column), $this->columnasTabla($tableName));
                $columnListSql = implode(', ', $columnIds);
                $createStmt = $pdo->query("SHOW CREATE TABLE {$tableId}");
                $createRow = $createStmt ? $createStmt->fetch(PDO::FETCH_ASSOC) : null;
                if (!$createRow) {
                    continue;
                }

                $createTableSql = $createRow['Create Table'] ?? null;
                if ($createTableSql === null) {
                    $vals = array_values($createRow);
                    $createTableSql = $vals[1] ?? '';
                }

                $this->writeLine($fh, '-- Tabla: ' . $tableName);
                $this->writeLine($fh, 'DROP TABLE IF EXISTS ' . $tableId . ';');
                $this->writeLine($fh, rtrim((string)$createTableSql, ';') . ';');
                $this->writeLine($fh, '');

                $dataStmt = $pdo->query("SELECT {$columnListSql} FROM {$tableId}");
                if (!$dataStmt) {
                    continue;
                }

                $batch = [];
                while (($row = $dataStmt->fetch(PDO::FETCH_NUM)) !== false) {
                    $batch[] = '(' . $this->serializeRow($pdo, $row) . ')';

                    if (count($batch) >= 100) {
                        $this->writeLine($fh, 'INSERT INTO ' . $tableId . ' (' . $columnListSql . ') VALUES');
                        $this->writeLine($fh, implode(",\n", $batch) . ';');
                        $this->writeLine($fh, '');
                        $batch = [];
                    }
                }

                if ($batch !== []) {
                    $this->writeLine($fh, 'INSERT INTO ' . $tableId . ' (' . $columnListSql . ') VALUES');
                    $this->writeLine($fh, implode(",\n", $batch) . ';');
                    $this->writeLine($fh, '');
                }
            }

            if (!$isPartial) {
                $viewStmt = $pdo->query("SHOW FULL TABLES WHERE Table_type = 'VIEW'");
                $views = $viewStmt ? $viewStmt->fetchAll(PDO::FETCH_NUM) : [];
                foreach ($views as $viewRow) {
                    $viewName = (string)($viewRow[0] ?? '');
                    if ($viewName === '') {
                        continue;
                    }

                    $viewId = $this->qi($viewName);
                    $createViewStmt = $pdo->query("SHOW CREATE VIEW {$viewId}");
                    $createViewRow = $createViewStmt ? $createViewStmt->fetch(PDO::FETCH_ASSOC) : null;
                    if (!$createViewRow) {
                        continue;
                    }

                    $createViewSql = $createViewRow['Create View'] ?? null;
                    if ($createViewSql === null) {
                        $vals = array_values($createViewRow);
                        $createViewSql = $vals[1] ?? '';
                    }

                    $createViewSql = preg_replace('/\sDEFINER=`[^`]+`@`[^`]+`\s/i', ' ', (string)$createViewSql);

                    $this->writeLine($fh, '-- Vista: ' . $viewName);
                    $this->writeLine($fh, 'DROP VIEW IF EXISTS ' . $viewId . ';');
                    $this->writeLine($fh, rtrim((string)$createViewSql, ';') . ';');
                    $this->writeLine($fh, '');
                }
            }

            $triggerStmt = $pdo->query("SHOW TRIGGERS");
            $triggers = $triggerStmt ? $triggerStmt->fetchAll(PDO::FETCH_ASSOC) : [];
            foreach ($triggers as $triggerRow) {
                $triggerName = (string)($triggerRow['Trigger'] ?? '');
                $triggerTable = (string)($triggerRow['Table'] ?? '');
                if ($triggerName === '') {
                    continue;
                }
                if ($isPartial && $triggerTable !== '' && !isset($tableSet[$triggerTable])) {
                    continue;
                }

                $triggerId = $this->qi($triggerName);
                $createTriggerStmt = $pdo->query("SHOW CREATE TRIGGER {$triggerId}");
                $createTriggerRow = $createTriggerStmt ? $createTriggerStmt->fetch(PDO::FETCH_ASSOC) : null;
                if (!$createTriggerRow) {
                    continue;
                }

                $createTriggerSql = $createTriggerRow['SQL Original Statement'] ?? ($createTriggerRow['Create Trigger'] ?? null);
                if ($createTriggerSql === null) {
                    $vals = array_values($createTriggerRow);
                    $createTriggerSql = $vals[2] ?? ($vals[1] ?? '');
                }

                $createTriggerSql = preg_replace(
                    '/CREATE\s+DEFINER=`[^`]+`@`[^`]+`\s+TRIGGER/i',
                    'CREATE TRIGGER',
                    (string)$createTriggerSql
                );
                $createTriggerSql = rtrim((string)$createTriggerSql, ';');

                $this->writeLine($fh, '-- Trigger: ' . $triggerName);
                $this->writeLine($fh, 'DROP TRIGGER IF EXISTS ' . $triggerId . ';');
                $this->writeLine($fh, 'DELIMITER $$');
                $this->writeLine($fh, $createTriggerSql . '$$');
                $this->writeLine($fh, 'DELIMITER ;');
                $this->writeLine($fh, '');
            }

            $this->writeLine($fh, 'SET FOREIGN_KEY_CHECKS=1;');
            $this->writeLine($fh, 'SET UNIQUE_CHECKS=1;');
        } catch (\Throwable $e) {
            @fclose($fh);
            @unlink($fullPath);
            throw $e;
        }

        fclose($fh);
    }

    private function writeLine($handle, string $line): void
    {
        fwrite($handle, $line . PHP_EOL);
    }

    private function qi(string $identifier): string
    {
        return '`' . str_replace('`', '``', $identifier) . '`';
    }

    private function serializeRow(PDO $pdo, array $row): string
    {
        $values = [];
        foreach ($row as $value) {
            if ($value === null) {
                $values[] = 'NULL';
                continue;
            }

            if (is_bool($value)) {
                $values[] = $value ? '1' : '0';
                continue;
            }

            $values[] = $pdo->quote((string)$value);
        }

        return implode(', ', $values);
    }

    private function statementEndsWithDelimiter(string $statement, string $delimiter): bool
    {
        $trimmed = rtrim($statement);
        if ($trimmed === '') {
            return false;
        }

        if ($delimiter === ';') {
            return substr($trimmed, -1) === ';';
        }

        $len = strlen($delimiter);
        if ($len <= 0) {
            return false;
        }

        return substr($trimmed, -$len) === $delimiter;
    }

    private function fetchBaseTables(PDO $pdo): array
    {
        $sql = "SELECT TABLE_NAME, TABLE_ROWS
                FROM INFORMATION_SCHEMA.TABLES
                WHERE TABLE_SCHEMA = :db
                  AND TABLE_TYPE = 'BASE TABLE'
                ORDER BY TABLE_NAME ASC";
        $stmt = $pdo->prepare($sql);
        $stmt->execute([':db' => DB_NAME]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $tables = [];
        foreach ($rows as $row) {
            $name = trim((string)($row['TABLE_NAME'] ?? ''));
            if (!$this->isSafeIdentifier($name)) {
                continue;
            }

            $tables[$name] = [
                'name' => $name,
                'rows' => (int)($row['TABLE_ROWS'] ?? 0)
            ];
        }

        return $tables;
    }

    private function normalizeTableList(array $tables): array
    {
        $normalized = [];
        foreach ($tables as $table) {
            if (!is_string($table)) {
                continue;
            }

            $name = trim($table);
            if (!$this->isSafeIdentifier($name)) {
                continue;
            }

            $normalized[$name] = true;
        }

        return array_keys($normalized);
    }

    private function isSafeIdentifier(string $value): bool
    {
        return $value !== '' && preg_match('/^[a-zA-Z0-9_]+$/', $value) === 1;
    }

    private function inferBackupDateFromFilename(string $fileName): ?string
    {
        if (!preg_match('/_(\d{8})_(\d{6})\.sql$/', $fileName, $match)) {
            return null;
        }

        $date = $match[1];
        $time = $match[2];

        $year = (int)substr($date, 0, 4);
        $month = (int)substr($date, 4, 2);
        $day = (int)substr($date, 6, 2);
        $hour = (int)substr($time, 0, 2);
        $minute = (int)substr($time, 2, 2);
        $second = (int)substr($time, 4, 2);

        if (!checkdate($month, $day, $year)) {
            return null;
        }

        if ($hour > 23 || $minute > 59 || $second > 59) {
            return null;
        }

        return sprintf('%04d-%02d-%02d %02d:%02d:%02d', $year, $month, $day, $hour, $minute, $second);
    }

    private function ensureAutoConfigTable(PDO $pdo): void
    {
        $sql = "CREATE TABLE IF NOT EXISTS backup_auto_config (
                    id TINYINT UNSIGNED NOT NULL PRIMARY KEY,
                    enabled TINYINT(1) NOT NULL DEFAULT 0,
                    frequency ENUM('daily','weekly','monthly') NOT NULL DEFAULT 'daily',
                    run_time CHAR(5) NOT NULL DEFAULT '02:00',
                    weekday TINYINT UNSIGNED NOT NULL DEFAULT 1,
                    month_day TINYINT UNSIGNED NOT NULL DEFAULT 1,
                    mode ENUM('full','specific') NOT NULL DEFAULT 'full',
                    tables_json LONGTEXT NULL,
                    retain_count SMALLINT UNSIGNED NOT NULL DEFAULT 30,
                    runner_token VARCHAR(80) NOT NULL,
                    last_run_at DATETIME NULL,
                    last_file VARCHAR(255) NULL,
                    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";
        $pdo->exec($sql);

        $stmt = $pdo->prepare("SELECT COUNT(1) FROM backup_auto_config WHERE id = 1");
        $stmt->execute();
        $exists = (int)$stmt->fetchColumn() > 0;
        if ($exists) {
            return;
        }

        $insert = $pdo->prepare("INSERT INTO backup_auto_config
                    (id, enabled, frequency, run_time, weekday, month_day, mode, tables_json, retain_count, runner_token)
                    VALUES (1, 0, 'daily', '02:00', 1, 1, 'full', '[]', 30, :token)");
        $insert->execute([':token' => $this->generateRunnerToken()]);
    }

    private function loadAutoConfigRow(PDO $pdo): array
    {
        $this->ensureAutoConfigTable($pdo);
        $stmt = $pdo->prepare("SELECT " . $this->columnasTablaSql('backup_auto_config') . " FROM backup_auto_config WHERE id = 1 LIMIT 1");
        $stmt->execute();
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        return is_array($row) ? $row : [];
    }

    private function decodeJsonTables(string $json): array
    {
        $decoded = json_decode($json, true);
        if (!is_array($decoded)) {
            return [];
        }
        return $this->normalizeTableList($decoded);
    }

    private function isAutoBackupDueNow(array $cfg): bool
    {
        $enabled = (int)($cfg['enabled'] ?? 0) === 1;
        if (!$enabled) {
            return false;
        }

        $now = new DateTimeImmutable('now');
        $today = $now->format('Y-m-d');

        $lastRunDate = null;
        if (!empty($cfg['last_run_at'])) {
            $last = strtotime((string)$cfg['last_run_at']);
            if ($last !== false) {
                $lastRunDate = date('Y-m-d', $last);
            }
        }

        if ($lastRunDate === $today) {
            return false;
        }

        $runTime = $this->normalizeTimeValue((string)($cfg['run_time'] ?? '02:00'));
        $nowTime = $now->format('H:i');
        if ($nowTime < $runTime) {
            return false;
        }

        $frequency = (string)($cfg['frequency'] ?? 'daily');
        if ($frequency === 'daily') {
            return true;
        }

        if ($frequency === 'weekly') {
            $weekday = max(1, min(7, $this->safeInt($cfg['weekday'] ?? 1, 1)));
            $nowWeekday = (int)$now->format('N');
            return $nowWeekday === $weekday;
        }

        if ($frequency === 'monthly') {
            $monthDay = max(1, min(31, $this->safeInt($cfg['month_day'] ?? 1, 1)));
            $daysCurrentMonth = (int)$now->format('t');
            $effectiveDay = min($monthDay, $daysCurrentMonth);
            return (int)$now->format('j') === $effectiveDay;
        }

        return false;
    }

    private function calculateNextRunAt(array $cfg): ?string
    {
        if ((int)($cfg['enabled'] ?? 0) !== 1) {
            return null;
        }

        $frequency = (string)($cfg['frequency'] ?? 'daily');
        $runTime = $this->normalizeTimeValue((string)($cfg['run_time'] ?? '02:00'));
        [$runHour, $runMinute] = array_map('intval', explode(':', $runTime));

        $now = new DateTimeImmutable('now');
        $candidate = $now->setTime($runHour, $runMinute, 0);

        if ($frequency === 'daily') {
            if ($candidate <= $now) {
                $candidate = $candidate->modify('+1 day');
            }
            return $candidate->format('Y-m-d H:i:s');
        }

        if ($frequency === 'weekly') {
            $weekday = max(1, min(7, $this->safeInt($cfg['weekday'] ?? 1, 1)));
            $nowWeekday = (int)$now->format('N');
            $diff = $weekday - $nowWeekday;
            if ($diff < 0) {
                $diff += 7;
            }

            $candidate = $candidate->modify('+' . $diff . ' day');
            if ($candidate <= $now) {
                $candidate = $candidate->modify('+7 day');
            }

            return $candidate->format('Y-m-d H:i:s');
        }

        if ($frequency === 'monthly') {
            $monthDay = max(1, min(31, $this->safeInt($cfg['month_day'] ?? 1, 1)));
            $year = (int)$now->format('Y');
            $month = (int)$now->format('n');

            $daysCurrentMonth = cal_days_in_month(CAL_GREGORIAN, $month, $year);
            $effectiveDay = min($monthDay, $daysCurrentMonth);
            $candidate = $candidate->setDate($year, $month, $effectiveDay);

            if ($candidate <= $now) {
                $month++;
                if ($month > 12) {
                    $month = 1;
                    $year++;
                }
                $daysNextMonth = cal_days_in_month(CAL_GREGORIAN, $month, $year);
                $effectiveNextDay = min($monthDay, $daysNextMonth);
                $candidate = $candidate->setDate($year, $month, $effectiveNextDay);
            }

            return $candidate->format('Y-m-d H:i:s');
        }

        return null;
    }

    private function safeInt($value, int $default): int
    {
        if ($value === null || $value === '') {
            return $default;
        }
        if (!is_numeric($value)) {
            return $default;
        }
        return (int)$value;
    }

    private function normalizeTimeValue(string $time): string
    {
        $time = trim($time);
        if (!preg_match('/^([01]?[0-9]|2[0-3]):([0-5][0-9])$/', $time, $match)) {
            return '02:00';
        }

        $h = (int)$match[1];
        $m = (int)$match[2];
        return sprintf('%02d:%02d', $h, $m);
    }

    private function generateRunnerToken(): string
    {
        return bin2hex(random_bytes(24));
    }

    private function purgeOldAutoBackups(int $retainCount): void
    {
        if ($retainCount <= 0) {
            return;
        }

        $this->ensureBackupDirectory();
        $files = glob($this->backupDir . DIRECTORY_SEPARATOR . '*_backup_auto_*.sql') ?: [];
        if (count($files) <= $retainCount) {
            return;
        }

        usort($files, static function (string $a, string $b): int {
            return filemtime($b) <=> filemtime($a);
        });

        $toDelete = array_slice($files, $retainCount);
        foreach ($toDelete as $path) {
            if (is_file($path)) {
                @unlink($path);
            }
        }
    }

    private function connectAsAuth(): PDO
    {
        $user = defined('DB_AUTH_USER') ? DB_AUTH_USER : DB_USER;
        $pass = defined('DB_AUTH_PASS') ? DB_AUTH_PASS : DB_PASS;

        $dsn = "mysql:host=" . DB_SERVER . ";dbname=" . DB_NAME . ";charset=utf8mb4";
        $pdo = new PDO(
            $dsn,
            $user,
            $pass,
            [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES => false
            ]
        );

        $pdo->exec("SET NAMES utf8mb4");
        $pdo->exec("SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED");

        $idUser = $_SESSION['id_user'] ?? ($_SESSION['id'] ?? null);
        if (!empty($idUser)) {
            $stmt = $pdo->prepare("SET @app_user = :id_user");
            $stmt->execute([':id_user' => (string)$idUser]);
        }

        return $pdo;
    }
}

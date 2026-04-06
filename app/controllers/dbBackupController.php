<?php

namespace app\controllers;

use app\models\mainModel;
use DateTimeImmutable;
use PDO;
use PDOException;
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
            $origin = $this->inferBackupOriginFromFilename($fileName);
            if ($createdAt === null) {
                $createdAt = date('Y-m-d H:i:s', (int)filemtime($path));
            }

            $result[] = [
                'file' => $fileName,
                'size' => (int)filesize($path),
                'created_at' => $createdAt,
                'modified_at' => date('Y-m-d H:i:s', (int)filemtime($path)),
                'relative_path' => 'db/backups/' . $fileName,
                'origin' => $origin,
                'origin_label' => $this->backupOriginLabel($origin),
            ];
        }

        return $result;
    }

    public function createBackup(array $selectedTables = [], string $origin = 'manual', bool $allowIncompleteFullBackup = false): array
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

        $missingRequiredSchemas = [];
        if (!$isPartial) {
            $presentSchemas = $this->getSchemasForFullBackup($pdo);
            $missingRequiredSchemas = $this->missingRequiredFullBackupSchemas($presentSchemas);
            if (!$allowIncompleteFullBackup && $missingRequiredSchemas !== []) {
                throw new RuntimeException(
                    'No se puede generar un respaldo completo porque faltan esquemas auxiliares obligatorios: '
                    . implode(', ', $missingRequiredSchemas)
                    . '. Restaura primero esas bases o ejecuta la restauracion sin respaldo de seguridad previo.',
                    409
                );
            }
        }

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
        if (!in_array($originTag, ['manual', 'auto', 'safety'], true)) {
            $originTag = 'manual';
        }

        $originPrefix = '';
        if ($originTag === 'auto') {
            $originPrefix = 'auto_';
        } elseif ($originTag === 'safety') {
            $originPrefix = 'safety_';
        }

        $fileName = $dbName . '_backup_' . $originPrefix . $fileScope . '_' . date('Ymd_His') . '.sql';
        $fullPath = $this->backupDir . DIRECTORY_SEPARATOR . $fileName;

        $usedMysqlDump = $this->writeDumpWithMysqlDump($fullPath, $tablesToExport, $isPartial);
        if (!$usedMysqlDump && !$isPartial) {
            throw new RuntimeException('El respaldo completo del sistema requiere mysqldump para incluir los esquemas auxiliares, rutinas y eventos.');
        }

        if (!$usedMysqlDump) {
            $this->writeDumpToFile($fullPath, $tablesToExport, $isPartial);
        }

        return [
            'file' => $fileName,
            'path' => $fullPath,
            'is_partial' => $isPartial,
            'tables' => $tablesToExport,
            'backup_kind' => $backupKind,
            'origin' => $originTag,
            'missing_required_schemas' => $missingRequiredSchemas,
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

        $restoreInspection = $this->inspectRestoreSourceFile($sourceFilePath);
        if ($restoreInspection['empty_routines'] !== []) {
            throw new RuntimeException(
                'El archivo SQL no es restaurable porque contiene rutinas vacias: '
                . implode(', ', $restoreInspection['empty_routines'])
                . '. Este respaldo fue generado sin poder leer el cuerpo real de los procedimientos almacenados.'
            );
        }

        if (($restoreInspection['missing_required_schemas'] ?? []) !== []) {
            throw new RuntimeException(
                'El archivo SQL no es restaurable como respaldo completo porque no incluye los esquemas auxiliares obligatorios: '
                . implode(', ', $restoreInspection['missing_required_schemas'])
                . '. Ese archivo fue generado cuando el sistema ya estaba incompleto.'
            );
        }

        if ($this->restoreWithMysqlClient($sourceFilePath)) {
            $this->validateRequiredObjectsAfterRestore($restoreInspection);
            return 0;
        }

        $pdo = $this->connectAsAuth(null);
        $handle = fopen($sourceFilePath, 'rb');
        if ($handle === false) {
            throw new RuntimeException('No se pudo abrir el archivo para restaurar.');
        }

        $executed = 0;
        $delimiter = ';';
        $statement = '';
        $firstLine = true;
        $insideBlockComment = false;

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

                if ($insideBlockComment) {
                    if (strpos($trimmed, '*/') !== false) {
                        $insideBlockComment = false;
                    }
                    continue;
                }

                if (preg_match('/^DELIMITER\s+(.+)$/i', $trimmed, $match)) {
                    $delimiter = (string)$match[1];
                    continue;
                }

                if ($delimiter === ';' && preg_match('/^(--\s|#)/', $trimmed)) {
                    continue;
                }

                if (
                    $delimiter === ';'
                    && str_starts_with($trimmed, '/*')
                    && !str_starts_with($trimmed, '/*!')
                    && !str_starts_with($trimmed, '/*M!')
                ) {
                    if (strpos($trimmed, '*/') === false) {
                        $insideBlockComment = true;
                    }
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

        $this->validateRequiredObjectsAfterRestore($restoreInspection);
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
            $this->writeBackupHeader($fh, $tablesToExport, $isPartial, 'GENERADOR_INTERNO');
            $this->writeLine($fh, '-- Esquemas incluidos: ' . (string)DB_NAME);
            $this->writeLine($fh, '');

            $this->writeLine($fh, 'SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";');
            $this->writeLine($fh, 'SET time_zone = "+00:00";');
            $this->writeLine($fh, 'SET FOREIGN_KEY_CHECKS=0;');
            $this->writeLine($fh, 'SET UNIQUE_CHECKS=0;');
            $this->writeLine($fh, 'SET SQL_NOTES=0;');
            $this->writeLine($fh, '');
            $this->writeSchemaBootstrap($fh, $pdo, (string)DB_NAME);

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
                $this->writeViewsToFile($fh, $pdo);
                $this->writeRoutinesToFile($fh, $pdo, DB_NAME);
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

            if (!$isPartial) {
                $this->writeEventsToFile($fh, $pdo, DB_NAME);
            }

            $this->writeLine($fh, 'SET FOREIGN_KEY_CHECKS=1;');
            $this->writeLine($fh, 'SET UNIQUE_CHECKS=1;');
            $this->writeLine($fh, 'SET SQL_NOTES=1;');
        } catch (\Throwable $e) {
            @fclose($fh);
            @unlink($fullPath);
            throw $e;
        }

        fclose($fh);
    }

    private function writeBackupHeader($handle, array $tablesToExport, bool $isPartial, string $generator): void
    {
        $this->writeLine($handle, '-- ========================================');
        $this->writeLine($handle, '-- Respaldo de base de datos');
        $this->writeLine($handle, '-- APP_METRO_BACKUP_SIGNATURE: 1');
        $this->writeLine($handle, '-- APP_METRO_BACKUP_GENERATOR: ' . $generator);
        $this->writeLine($handle, '-- DB: ' . DB_NAME);
        $this->writeLine($handle, '-- Fecha: ' . date('Y-m-d H:i:s'));
        $this->writeLine($handle, '-- Tipo: ' . ($isPartial ? 'PARCIAL' : 'COMPLETO'));
        $this->writeLine($handle, '-- Tablas incluidas: ' . implode(', ', $tablesToExport));
        $this->writeLine($handle, '-- ========================================');
        $this->writeLine($handle, '');
    }

    private function writeViewsToFile($handle, PDO $pdo): void
    {
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

            $createViewSql = $this->extractCreateStatement($createViewRow, ['Create View']);
            $createViewSql = preg_replace('/\sDEFINER=`[^`]+`@`[^`]+`\s/i', ' ', (string)$createViewSql);

            $this->writeLine($handle, '-- Vista: ' . $viewName);
            $this->writeLine($handle, 'DROP VIEW IF EXISTS ' . $viewId . ';');
            $this->writeLine($handle, rtrim((string)$createViewSql, ';') . ';');
            $this->writeLine($handle, '');
        }
    }

    private function writeRoutinesToFile($handle, PDO $pdo, string $schemaName = DB_NAME, ?string $connectedUser = null): void
    {
        $stmt = $pdo->prepare(
            "SELECT ROUTINE_NAME, ROUTINE_TYPE
             FROM INFORMATION_SCHEMA.ROUTINES
             WHERE ROUTINE_SCHEMA = :schema
             ORDER BY ROUTINE_TYPE ASC, ROUTINE_NAME ASC"
        );
        $stmt->execute([':schema' => $schemaName]);
        $routines = $stmt->fetchAll(PDO::FETCH_ASSOC);

        foreach ($routines as $routineRow) {
            $routineName = trim((string)($routineRow['ROUTINE_NAME'] ?? ''));
            $routineType = strtoupper(trim((string)($routineRow['ROUTINE_TYPE'] ?? '')));
            if ($routineName === '' || !in_array($routineType, ['PROCEDURE', 'FUNCTION'], true)) {
                continue;
            }

            $routineId = $this->qualifyIdentifier($schemaName, $routineName);
            $showSql = $routineType === 'FUNCTION'
                ? "SHOW CREATE FUNCTION {$routineId}"
                : "SHOW CREATE PROCEDURE {$routineId}";

            try {
                $createStmt = $pdo->query($showSql);
                $createRow = $createStmt ? $createStmt->fetch(PDO::FETCH_ASSOC) : null;
            } catch (\Throwable $e) {
                $accountLabel = ($connectedUser !== null && trim($connectedUser) !== '')
                    ? ' con la cuenta "' . trim($connectedUser) . '"'
                    : '';
                throw new RuntimeException(
                    'No se pudo exportar la rutina '
                    . $schemaName . '.' . $routineName
                    . $accountLabel
                    . ': ' . $e->getMessage(),
                    0,
                    $e
                );
            }

            if (!$createRow) {
                continue;
            }

            $createSql = $this->extractCreateStatement(
                $createRow,
                $routineType === 'FUNCTION' ? ['Create Function'] : ['Create Procedure']
            );
            $createSql = $this->stripDefinerMetadata((string)$createSql);

            if ($createSql === '') {
                $accountLabel = ($connectedUser !== null && trim($connectedUser) !== '')
                    ? ' con la cuenta "' . trim($connectedUser) . '"'
                    : '';
                throw new RuntimeException(
                    'No se pudo exportar la definicion de la rutina '
                    . $schemaName . '.' . $routineName
                    . $accountLabel
                    . '. La cuenta usada para el respaldo no puede leer SHOW CREATE '
                    . strtolower($routineType)
                    . '; revisa DB_AUTH_USER/DB_AUTH_PASS o los privilegios del usuario de respaldo.'
                );
            }

            $this->writeLine($handle, '-- ' . $routineType . ': ' . $routineName);
            $this->writeLine($handle, 'DROP ' . $routineType . ' IF EXISTS ' . $routineId . ';');
            $this->writeLine($handle, 'DELIMITER $$');
            $this->writeLine($handle, rtrim($createSql, ';') . '$$');
            $this->writeLine($handle, 'DELIMITER ;');
            $this->writeLine($handle, '');
        }
    }

    private function writeEventsToFile($handle, PDO $pdo, string $schemaName = DB_NAME): void
    {
        $stmt = $pdo->prepare(
            "SELECT EVENT_NAME
             FROM INFORMATION_SCHEMA.EVENTS
             WHERE EVENT_SCHEMA = :schema
             ORDER BY EVENT_NAME ASC"
        );
        $stmt->execute([':schema' => $schemaName]);
        $events = $stmt->fetchAll(PDO::FETCH_ASSOC);

        foreach ($events as $eventRow) {
            $eventName = trim((string)($eventRow['EVENT_NAME'] ?? ''));
            if ($eventName === '') {
                continue;
            }

            $eventId = $this->qualifyIdentifier($schemaName, $eventName);
            try {
                $createStmt = $pdo->query("SHOW CREATE EVENT {$eventId}");
                $createRow = $createStmt ? $createStmt->fetch(PDO::FETCH_ASSOC) : null;
            } catch (\Throwable $e) {
                $this->writeLine($handle, '-- Advertencia: no se pudo exportar el evento ' . $schemaName . '.' . $eventName . ': ' . $e->getMessage());
                $this->writeLine($handle, '');
                continue;
            }

            if (!$createRow) {
                continue;
            }

            $createSql = $this->extractCreateStatement($createRow, ['Create Event']);
            $createSql = $this->stripDefinerMetadata((string)$createSql);

            $this->writeLine($handle, '-- EVENTO: ' . $eventName);
            $this->writeLine($handle, 'DROP EVENT IF EXISTS ' . $eventId . ';');
            $this->writeLine($handle, 'DELIMITER $$');
            $this->writeLine($handle, rtrim($createSql, ';') . '$$');
            $this->writeLine($handle, 'DELIMITER ;');
            $this->writeLine($handle, '');
        }
    }

    private function extractCreateStatement(?array $row, array $preferredKeys): string
    {
        if (!is_array($row)) {
            return '';
        }

        foreach ($preferredKeys as $key) {
            if (isset($row[$key]) && is_string($row[$key])) {
                return $row[$key];
            }
        }

        foreach ($row as $value) {
            if (is_string($value) && stripos($value, 'CREATE ') === 0) {
                return $value;
            }
        }

        $values = array_values($row);
        foreach ($values as $value) {
            if (is_string($value) && stripos($value, 'CREATE ') === 0) {
                return $value;
            }
        }

        return '';
    }

    private function stripDefinerMetadata(string $sql): string
    {
        $sql = preg_replace('/\/\*![0-9]{5}\s+DEFINER=`[^`]+`@`[^`]+`[^*]*\*\//i', '', $sql);
        $sql = preg_replace('/CREATE\s+DEFINER=`[^`]+`@`[^`]+`\s+/i', 'CREATE ', $sql);
        $sql = preg_replace('/\sDEFINER=`[^`]+`@`[^`]+`\s/i', ' ', $sql);

        return trim((string)$sql);
    }

    private function writeDumpWithMysqlDump(string $fullPath, array $tablesToExport, bool $isPartial): bool
    {
        $binary = $this->resolveMysqlBinary('mysqldump');
        if ($binary === null) {
            return false;
        }

        $resolved = $this->resolveWorkingDatabaseAccess(null);
        $connection = $this->getDatabaseConnectionOptions();
        $schemasToDump = $isPartial ? [DB_NAME] : $this->getSchemasForFullBackup($resolved['pdo']);
        $fh = fopen($fullPath, 'wb');
        if ($fh === false) {
            throw new RuntimeException('No se pudo crear el archivo de respaldo.');
        }

        try {
            $this->writeBackupHeader($fh, $tablesToExport, $isPartial, 'MYSQLDUMP');
            $this->writeLine($fh, '-- Esquemas incluidos: ' . implode(', ', $schemasToDump));
            $this->writeLine($fh, '');

            foreach ($schemasToDump as $schemaName) {
                $this->writeLine($fh, '-- Esquema: ' . $schemaName);
                $this->writeSchemaBootstrap($fh, $resolved['pdo'], $schemaName);

                $args = [
                    $binary,
                    '--host=' . $connection['host'],
                    '--protocol=tcp',
                    '--default-character-set=utf8mb4',
                    '--single-transaction',
                    '--skip-lock-tables',
                    '--hex-blob',
                    '--skip-comments',
                    '--user=' . $resolved['user'],
                    '--password=' . (string)$resolved['pass'],
                ];

                if ($connection['port'] !== null) {
                    $args[] = '--port=' . $connection['port'];
                }

                $args[] = $schemaName;
                if ($isPartial && $schemaName === DB_NAME) {
                    foreach ($tablesToExport as $tableName) {
                        $args[] = $tableName;
                    }
                }

                $command = $this->buildShellCommand($args);
                $descriptor = [
                    0 => ['pipe', 'r'],
                    1 => ['pipe', 'w'],
                    2 => ['pipe', 'w'],
                ];

                $process = proc_open($command, $descriptor, $pipes);
                if (!is_resource($process)) {
                    throw new RuntimeException('No se pudo iniciar mysqldump para generar el respaldo.');
                }

                fclose($pipes[0]);

                while (($line = fgets($pipes[1])) !== false) {
                    fwrite($fh, $this->normalizeDumpLine($line));
                }

                $remaining = stream_get_contents($pipes[1]);
                if ($remaining !== false && $remaining !== '') {
                    fwrite($fh, $this->normalizeDumpLine($remaining));
                }

                fclose($pipes[1]);
                $stderr = stream_get_contents($pipes[2]);
                fclose($pipes[2]);

                $exitCode = proc_close($process);
                if ($exitCode !== 0) {
                    throw new RuntimeException('mysqldump no pudo generar el respaldo: ' . trim((string)$stderr));
                }

                if (!$isPartial) {
                    $this->writeLine($fh, '-- Objetos programables del esquema: ' . $schemaName);
                    $this->writeSchemaBootstrap($fh, $resolved['pdo'], $schemaName);
                    $this->writeRoutinesToFile($fh, $resolved['pdo'], $schemaName, (string)$resolved['user']);
                    $this->writeEventsToFile($fh, $resolved['pdo'], $schemaName);
                }

                $this->writeLine($fh, '');
            }
        } catch (\Throwable $e) {
            @fclose($fh);
            @unlink($fullPath);
            throw $e;
        }

        fclose($fh);
        return true;
    }

    private function restoreWithMysqlClient(string $sourceFilePath): bool
    {
        $binary = $this->resolveMysqlBinary('mysql');
        if ($binary === null) {
            return false;
        }

        $resolved = $this->resolveWorkingDatabaseAccess(null);
        $connection = $this->getDatabaseConnectionOptions();

        $args = [
            $binary,
            '--host=' . $connection['host'],
            '--protocol=tcp',
            '--default-character-set=utf8mb4',
            '--user=' . $resolved['user'],
            '--password=' . (string)$resolved['pass'],
        ];

        if ($connection['port'] !== null) {
            $args[] = '--port=' . $connection['port'];
        }

        $command = $this->buildShellCommand($args);
        $descriptor = [
            0 => ['file', $sourceFilePath, 'r'],
            1 => ['pipe', 'w'],
            2 => ['pipe', 'w'],
        ];

        $process = proc_open($command, $descriptor, $pipes);
        if (!is_resource($process)) {
            throw new RuntimeException('No se pudo iniciar el cliente mysql para restaurar el respaldo.');
        }

        $stdout = stream_get_contents($pipes[1]);
        fclose($pipes[1]);
        $stderr = stream_get_contents($pipes[2]);
        fclose($pipes[2]);

        $exitCode = proc_close($process);
        if ($exitCode !== 0) {
            $detail = trim((string)$stderr);
            if ($detail === '') {
                $detail = trim((string)$stdout);
            }
            throw new RuntimeException('El cliente mysql no pudo restaurar el respaldo: ' . $detail);
        }

        return true;
    }

    private function normalizeDumpLine(string $content): string
    {
        $content = preg_replace('/\/\*![0-9]{5}\s+DEFINER=`[^`]+`@`[^`]+`[^*]*\*\//i', '', $content);
        $content = preg_replace('/CREATE\s+DEFINER=`[^`]+`@`[^`]+`\s+(PROCEDURE|FUNCTION|TRIGGER|EVENT)/i', 'CREATE $1', $content);
        $content = preg_replace('/\sDEFINER=`[^`]+`@`[^`]+`\s/i', ' ', $content);

        return (string)$content;
    }

    private function resolveMysqlBinary(string $binaryName): ?string
    {
        $isWindows = DIRECTORY_SEPARATOR === '\\';
        $projectRoot = dirname(__DIR__, 2);
        $xamppRoot = dirname(dirname($projectRoot));
        $fileName = $isWindows ? $binaryName . '.exe' : $binaryName;

        $candidates = [
            $xamppRoot . DIRECTORY_SEPARATOR . 'mysql' . DIRECTORY_SEPARATOR . 'bin' . DIRECTORY_SEPARATOR . $fileName,
        ];

        $pathEnv = getenv('PATH') ?: '';
        if ($pathEnv !== '') {
            foreach (explode(PATH_SEPARATOR, $pathEnv) as $dir) {
                $dir = trim($dir, " \t\n\r\0\x0B\"'");
                if ($dir === '') {
                    continue;
                }
                $candidates[] = rtrim($dir, '\\/') . DIRECTORY_SEPARATOR . $fileName;
            }
        }

        foreach ($candidates as $candidate) {
            if (is_file($candidate)) {
                return $candidate;
            }
        }

        return null;
    }

    private function buildShellCommand(array $parts): string
    {
        return implode(' ', array_map(static function ($part): string {
            return escapeshellarg((string)$part);
        }, $parts));
    }

    private function getDatabaseConnectionOptions(): array
    {
        $server = (string)DB_SERVER;
        $host = $server;
        $port = null;

        if (preg_match('/^([^:]+):(\d+)$/', $server, $match) === 1) {
            $host = trim((string)$match[1]);
            $port = (int)$match[2];
        }

        if ($host === '') {
            $host = '127.0.0.1';
        }

        return [
            'host' => $host,
            'port' => $port,
        ];
    }

    private function writeSchemaBootstrap($handle, PDO $pdo, string $schemaName): void
    {
        $this->writeLine($handle, $this->buildCreateDatabaseStatement($pdo, $schemaName));
        $this->writeLine($handle, 'USE ' . $this->qi($schemaName) . ';');
        $this->writeLine($handle, '');
    }

    private function buildCreateDatabaseStatement(PDO $pdo, string $schemaName): string
    {
        $stmt = $pdo->prepare(
            "SELECT DEFAULT_CHARACTER_SET_NAME, DEFAULT_COLLATION_NAME
             FROM INFORMATION_SCHEMA.SCHEMATA
             WHERE SCHEMA_NAME = :schema
             LIMIT 1"
        );
        $stmt->execute([':schema' => $schemaName]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC) ?: [];

        $charset = trim((string)($row['DEFAULT_CHARACTER_SET_NAME'] ?? ''));
        if (!$this->isSafeIdentifier($charset)) {
            $charset = 'utf8mb4';
        }

        $collation = trim((string)($row['DEFAULT_COLLATION_NAME'] ?? ''));
        if (!$this->isSafeIdentifier($collation)) {
            $collation = 'utf8mb4_general_ci';
        }

        return 'CREATE DATABASE IF NOT EXISTS '
            . $this->qi($schemaName)
            . ' DEFAULT CHARACTER SET '
            . $charset
            . ' COLLATE '
            . $collation
            . ';';
    }

    private function getSchemasForFullBackup(PDO $pdo): array
    {
        $candidateSchemas = $this->requiredFullBackupSchemas();

        $stmt = $pdo->prepare(
            "SELECT SCHEMA_NAME
             FROM INFORMATION_SCHEMA.SCHEMATA
             WHERE SCHEMA_NAME = :schema
             LIMIT 1"
        );

        $schemas = [];
        foreach ($candidateSchemas as $schemaName) {
            if ($schemaName === '') {
                continue;
            }

            $stmt->execute([':schema' => $schemaName]);
            $exists = $stmt->fetchColumn();
            if ($exists !== false) {
                $schemas[] = $schemaName;
            }
        }

        if ($schemas === []) {
            $schemas[] = (string)DB_NAME;
        }

        return $schemas;
    }

    private function requiredFullBackupSchemas(): array
    {
        return array_values(array_unique([
            (string)DB_NAME,
            (string)DB_NAME . '_audit',
            (string)DB_NAME . '_review',
        ]));
    }

    private function missingRequiredFullBackupSchemas(array $presentSchemas): array
    {
        $presentMap = [];
        foreach ($presentSchemas as $schemaName) {
            $presentMap[(string)$schemaName] = true;
        }

        $missing = [];
        foreach ($this->requiredFullBackupSchemas() as $schemaName) {
            if (!isset($presentMap[$schemaName])) {
                $missing[] = $schemaName;
            }
        }

        return $missing;
    }

    private function writeLine($handle, string $line): void
    {
        fwrite($handle, $line . PHP_EOL);
    }

    private function qi(string $identifier): string
    {
        return '`' . str_replace('`', '``', $identifier) . '`';
    }

    private function qualifyIdentifier(string $schemaName, string $objectName): string
    {
        return $this->qi($schemaName) . '.' . $this->qi($objectName);
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

    private function inferBackupOriginFromFilename(string $fileName): string
    {
        if (preg_match('/_backup_auto_/i', $fileName) === 1) {
            return 'auto';
        }

        if (preg_match('/_backup_safety_/i', $fileName) === 1) {
            return 'safety';
        }

        return 'manual';
    }

    private function backupOriginLabel(string $origin): string
    {
        if ($origin === 'auto') {
            return 'Automatico';
        }

        if ($origin === 'safety') {
            return 'Seguridad previa';
        }

        return 'Manual';
    }

    private function inspectRestoreSourceFile(string $sourceFilePath): array
    {
        $handle = fopen($sourceFilePath, 'rb');
        if ($handle === false) {
            throw new RuntimeException('No se pudo abrir el archivo de restauracion para validarlo.');
        }

        $hasSignature = false;
        $isFullBackup = false;
        $containsProgrammableObjects = false;
        $emptyRoutines = [];
        $includedSchemas = [];
        $currentRoutine = null;
        $awaitingRoutineBody = false;
        $firstLine = true;

        try {
            while (($line = fgets($handle)) !== false) {
                if ($firstLine) {
                    $line = preg_replace('/^\xEF\xBB\xBF/', '', $line);
                    $firstLine = false;
                }

                $trimmed = trim($line);
                if ($trimmed === '') {
                    continue;
                }

                if (strpos($trimmed, '-- APP_METRO_BACKUP_SIGNATURE: 1') === 0) {
                    $hasSignature = true;
                    continue;
                }

                if (strpos($trimmed, '-- Tipo: COMPLETO') === 0) {
                    $isFullBackup = true;
                    continue;
                }

                if (strpos($trimmed, '-- Esquemas incluidos: ') === 0) {
                    $rawSchemaList = trim((string)substr($trimmed, strlen('-- Esquemas incluidos: ')));
                    if ($rawSchemaList !== '') {
                        foreach (explode(',', $rawSchemaList) as $schemaName) {
                            $schemaName = trim($schemaName);
                            if ($schemaName !== '') {
                                $includedSchemas[$schemaName] = true;
                            }
                        }
                    }
                    continue;
                }

                if (
                    preg_match('/^--\s+(PROCEDURE|FUNCTION):\s+(.+)$/i', $trimmed, $match) === 1
                ) {
                    $containsProgrammableObjects = true;
                    $currentRoutine = [
                        'type' => strtoupper((string)$match[1]),
                        'name' => trim((string)$match[2]),
                    ];
                    $awaitingRoutineBody = false;
                    continue;
                }

                if (
                    !$containsProgrammableObjects
                    && preg_match('/^(CREATE|DROP)\s+(PROCEDURE|FUNCTION|TRIGGER|EVENT)\b/i', $trimmed) === 1
                ) {
                    $containsProgrammableObjects = true;
                }

                if ($currentRoutine === null) {
                    continue;
                }

                if (preg_match('/^DELIMITER\s+\$\$$/i', $trimmed) === 1) {
                    $awaitingRoutineBody = true;
                    continue;
                }

                if (!$awaitingRoutineBody) {
                    continue;
                }

                if ($trimmed === '$$') {
                    $emptyRoutines[] = $currentRoutine['type'] . ' ' . $currentRoutine['name'];
                    $currentRoutine = null;
                    $awaitingRoutineBody = false;
                    continue;
                }

                if (preg_match('/^CREATE\s+/i', $trimmed) === 1) {
                    $currentRoutine = null;
                    $awaitingRoutineBody = false;
                    continue;
                }

                if (preg_match('/^DELIMITER\s+;$/i', $trimmed) === 1) {
                    $currentRoutine = null;
                    $awaitingRoutineBody = false;
                }
            }
        } finally {
            fclose($handle);
        }

        $missingRequiredSchemas = [];
        if ($hasSignature && $isFullBackup && $includedSchemas !== []) {
            $missingRequiredSchemas = $this->missingRequiredFullBackupSchemas(array_keys($includedSchemas));
        }

        return [
            'has_signature' => $hasSignature,
            'is_full_backup' => $isFullBackup,
            'contains_programmable_objects' => $containsProgrammableObjects,
            'empty_routines' => array_values(array_unique($emptyRoutines)),
            'included_schemas' => array_keys($includedSchemas),
            'missing_required_schemas' => $missingRequiredSchemas,
        ];
    }

    private function validateRequiredObjectsAfterRestore(array $restoreInspection): void
    {
        $shouldValidateRequiredProcedures =
            (($restoreInspection['has_signature'] ?? false) && ($restoreInspection['is_full_backup'] ?? false))
            || ($restoreInspection['contains_programmable_objects'] ?? false);

        if (!$shouldValidateRequiredProcedures) {
            return;
        }

        $pdo = $this->connectAsAuth();
        $requiredBySchema = $this->requiredProcedureMatrix();
        $missing = [];

        foreach ($requiredBySchema as $schemaName => $routineNames) {
            $placeholders = implode(', ', array_fill(0, count($routineNames), '?'));
            $sql = "SELECT ROUTINE_NAME
                    FROM INFORMATION_SCHEMA.ROUTINES
                    WHERE ROUTINE_SCHEMA = ?
                      AND ROUTINE_TYPE = 'PROCEDURE'
                      AND ROUTINE_NAME IN ({$placeholders})";
            $stmt = $pdo->prepare($sql);
            $stmt->execute(array_merge([$schemaName], $routineNames));
            $found = $stmt->fetchAll(PDO::FETCH_COLUMN);
            $foundMap = [];
            foreach ($found as $routineName) {
                $foundMap[(string)$routineName] = true;
            }

            foreach ($routineNames as $routineName) {
                if (!isset($foundMap[$routineName])) {
                    $missing[] = $schemaName . '.' . $routineName;
                }
            }
        }

        if ($missing !== []) {
            throw new RuntimeException(
                'La restauracion termino, pero faltan procedimientos obligatorios: '
                . implode(', ', $missing)
                . '. El respaldo no quedo completo o fue generado sin acceso a SHOW CREATE PROCEDURE.'
            );
        }
    }

    private function requiredProcedureMatrix(): array
    {
        return [
            (string)DB_NAME => [
                'sp_herramienta_ocupaciones',
                'sp_ot_agregar_detalle',
                'sp_ot_actualizar',
                'sp_ot_eliminar_logico',
                'sp_ot_actualizar_detalle',
                'sp_ot_eliminar_detalle',
                'sp_ot_ajustar_herramienta_delta',
                'sp_ot_set_herramienta_cantidad',
                'sp_ot_asignar_herramienta',
                'sp_ot_cambiar_estado',
                'sp_ot_crear',
                'sp_reporte_registrar_generado',
                'sp_usuario_registrar_login_exitoso',
                'sp_usuario_registrar_login_fallido',
            ],
            (string)DB_NAME . '_audit' => [
                'sp_minute_tasks',
                'sp_sync_log_user',
            ],
        ];
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

    private function resolveWorkingDatabaseAccess(?string $databaseName = null): array
    {
        $lastException = null;
        $authUser = defined('DB_AUTH_USER') ? trim((string)DB_AUTH_USER) : '';

        foreach ($this->getDatabaseCredentialCandidates() as $candidate) {
            try {
                $pdo = $this->createDatabaseConnection(
                    (string)$candidate['user'],
                    (string)$candidate['pass'],
                    $databaseName ?? (string)DB_NAME
                );
                $this->applyConnectionSessionSettings($pdo);
                return [
                    'pdo' => $pdo,
                    'user' => (string)$candidate['user'],
                    'pass' => (string)$candidate['pass'],
                ];
            } catch (PDOException $e) {
                $lastException = $e;
            }
        }

        if ($authUser !== '') {
            $message = 'No se pudo conectar con la cuenta de respaldo/restauracion configurada en DB_AUTH_USER (' . $authUser . ').';
        } else {
            $message = 'No se pudo conectar con la cuenta operativa porque no hay una cuenta DB_AUTH_USER configurada para respaldo/restauracion.';
        }

        if ($lastException instanceof PDOException) {
            $message .= ' ' . $lastException->getMessage();
        }

        throw new RuntimeException($message, 0, $lastException);
    }

    private function getDatabaseCredentialCandidates(): array
    {
        $candidates = [];
        $authUser = defined('DB_AUTH_USER') ? (string)DB_AUTH_USER : '';
        $authPass = defined('DB_AUTH_PASS') ? (string)DB_AUTH_PASS : '';

        if (trim($authUser) !== '') {
            $candidates[] = [
                'user' => $authUser,
                'pass' => $authPass,
            ];
        } else {
            $candidates[] = [
                'user' => (string)DB_USER,
                'pass' => (string)DB_PASS,
            ];
        }

        return $candidates;
    }

    private function createDatabaseConnection(string $user, string $pass, ?string $databaseName = null): PDO
    {
        $connection = $this->getDatabaseConnectionOptions();
        $dsn = "mysql:host=" . $connection['host']
            . ($connection['port'] !== null ? ";port=" . $connection['port'] : '')
            . ($databaseName !== null && $databaseName !== '' ? ";dbname=" . $databaseName : '')
            . ";charset=utf8mb4";

        return new PDO(
            $dsn,
            $user,
            $pass,
            [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES => false
            ]
        );
    }

    private function applyConnectionSessionSettings(PDO $pdo): void
    {
        $pdo->exec("SET NAMES utf8mb4");
        $pdo->exec("SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED");

        $idUser = $_SESSION['id_user'] ?? ($_SESSION['id'] ?? null);
        if (!empty($idUser)) {
            $stmt = $pdo->prepare("SET @app_user = :id_user");
            $stmt->execute([':id_user' => (string)$idUser]);
        }
    }

    private function connectAsAuth(?string $databaseName = null): PDO
    {
        $resolved = $this->resolveWorkingDatabaseAccess($databaseName);
        return $resolved['pdo'];
    }
}

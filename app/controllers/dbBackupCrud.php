<?php

require_once "../../config/app.php";
require_once "../views/inc/session_start.php";
require_once "../../autoload.php";

use app\controllers\dbBackupController;

$action = $_GET['action'] ?? ($_POST['action'] ?? 'list');

if ($action !== 'download') {
    header('Content-Type: application/json; charset=utf-8');
}

try {
    set_time_limit(0);

    $ins = new dbBackupController();
    $isAutoRunner = ($action === 'auto_runner');

    if (!$isAutoRunner) {
        $ins->assertAdmin();
    } else {
        $token = (string)($_GET['token'] ?? ($_POST['token'] ?? ''));
        if (!$ins->validateAutoRunnerToken($token)) {
            http_response_code(401);
            echo json_encode([
                'ok' => false,
                'msg' => 'Token de ejecucion automatica invalido.'
            ], JSON_UNESCAPED_UNICODE);
            exit();
        }
    }

    if ($action === 'download') {
        $file = (string)($_GET['file'] ?? '');
        $path = $ins->resolveBackupPath($file);

        if (!is_readable($path)) {
            http_response_code(404);
            echo 'No se pudo leer el respaldo solicitado.';
            exit();
        }

        header('Content-Description: File Transfer');
        header('Content-Type: application/sql');
        header('Content-Disposition: attachment; filename="' . basename($path) . '"');
        header('Content-Length: ' . (string)filesize($path));
        header('Cache-Control: no-store, no-cache, must-revalidate');
        header('Pragma: no-cache');
        header('Expires: 0');

        readfile($path);
        exit();
    }

    if ($action === 'list') {
        $files = $ins->listBackups();
        echo json_encode([
            'ok' => true,
            'files' => $files
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    if ($action === 'tables') {
        $tables = $ins->listDatabaseTables();
        echo json_encode([
            'ok' => true,
            'tables' => $tables
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    if ($action === 'auto_get') {
        $cfg = $ins->getAutoBackupConfig();
        $runnerUrl = APP_URL . 'app/controllers/dbBackupCrud.php?action=auto_runner&token=' . rawurlencode((string)$cfg['runner_token']);
        echo json_encode([
            'ok' => true,
            'config' => $cfg,
            'runner_url' => $runnerUrl
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    if ($action === 'auto_save') {
        $tables = [];
        if (isset($_POST['auto_tables'])) {
            $rawTables = $_POST['auto_tables'];
            if (is_array($rawTables)) {
                $tables = $rawTables;
            }
        }

        $payload = [
            'enabled' => $_POST['enabled'] ?? '0',
            'frequency' => $_POST['frequency'] ?? 'daily',
            'run_time' => $_POST['run_time'] ?? '02:00',
            'weekday' => $_POST['weekday'] ?? '1',
            'month_day' => $_POST['month_day'] ?? '1',
            'mode' => $_POST['mode'] ?? 'full',
            'retain_count' => $_POST['retain_count'] ?? '30',
            'rotate_token' => $_POST['rotate_token'] ?? '0',
            'tables' => $tables
        ];

        $cfg = $ins->saveAutoBackupConfig($payload);
        $runnerUrl = APP_URL . 'app/controllers/dbBackupCrud.php?action=auto_runner&token=' . rawurlencode((string)$cfg['runner_token']);

        echo json_encode([
            'ok' => true,
            'msg' => 'Configuracion de respaldo automatico guardada.',
            'config' => $cfg,
            'runner_url' => $runnerUrl
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    if ($action === 'auto_run_now') {
        $result = $ins->runAutomaticBackup(true);
        echo json_encode([
            'ok' => true,
            'msg' => 'Respaldo automatico ejecutado manualmente.',
            'result' => $result
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    if ($action === 'auto_runner') {
        $result = $ins->runAutomaticBackup(false);
        echo json_encode([
            'ok' => true,
            'result' => $result
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    if ($action === 'create') {
        $selectedTables = [];
        if (isset($_POST['selected_tables'])) {
            $raw = $_POST['selected_tables'];
            if (is_array($raw)) {
                $selectedTables = $raw;
            } elseif (is_string($raw) && trim($raw) !== '') {
                $decoded = json_decode($raw, true);
                if (json_last_error() === JSON_ERROR_NONE && is_array($decoded)) {
                    $selectedTables = $decoded;
                } else {
                    $selectedTables = array_values(array_filter(array_map('trim', explode(',', $raw))));
                }
            }
        }

        $backup = $ins->createBackup($selectedTables);
        $downloadUrl = APP_URL . 'app/controllers/dbBackupCrud.php?action=download&file=' . rawurlencode($backup['file']);
        $typeLabel = 'general';
        if (!empty($backup['is_partial'])) {
            if (!empty($backup['tables']) && count($backup['tables']) === 1) {
                $typeLabel = 'tabla: ' . $backup['tables'][0];
            } else {
                $typeLabel = 'tablas (' . count($backup['tables'] ?? []) . ')';
            }
        }
        $storedIn = 'db/backups/' . $backup['file'];

        echo json_encode([
            'ok' => true,
            'msg' => 'Respaldo ' . $typeLabel . ' generado y almacenado en ' . $storedIn,
            'file' => $backup['file'],
            'download_url' => $downloadUrl,
            'is_partial' => !empty($backup['is_partial']) ? 1 : 0,
            'tables' => $backup['tables'] ?? [],
            'stored_in' => $storedIn,
            'backup_kind' => $backup['backup_kind'] ?? 'full'
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    if ($action === 'delete') {
        $file = (string)($_POST['file'] ?? '');
        if ($file === '') {
            echo json_encode([
                'ok' => false,
                'msg' => 'Debes indicar el archivo a eliminar.'
            ], JSON_UNESCAPED_UNICODE);
            exit();
        }

        $ins->deleteBackup($file);
        echo json_encode([
            'ok' => true,
            'msg' => 'Respaldo eliminado correctamente.'
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    if ($action === 'restore_saved') {
        $file = (string)($_POST['file'] ?? '');
        if ($file === '') {
            echo json_encode([
                'ok' => false,
                'msg' => 'Debes indicar el respaldo a restaurar.'
            ], JSON_UNESCAPED_UNICODE);
            exit();
        }

        $path = $ins->resolveBackupPath($file);

        $createSafetyBackup = ((string)($_POST['create_safety_backup'] ?? '0')) === '1';
        $safety = null;
        $safetyWarning = null;
        if ($createSafetyBackup) {
            $safety = $ins->createBackup([], 'safety', true);
            if (!empty($safety['missing_required_schemas']) && is_array($safety['missing_required_schemas'])) {
                $safetyWarning = 'El respaldo de seguridad previo se genero sin los esquemas auxiliares: '
                    . implode(', ', $safety['missing_required_schemas'])
                    . '.';
            }
        }

        $executed = $ins->restoreFromFile($path);

        echo json_encode([
            'ok' => true,
            'msg' => 'Restauracion completada desde respaldo guardado.',
            'source_file' => $file,
            'executed_statements' => $executed,
            'safety_backup' => $safety,
            'safety_backup_warning' => $safetyWarning,
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    if ($action === 'restore') {
        if (!isset($_FILES['sql_file']) || !is_array($_FILES['sql_file'])) {
            echo json_encode([
                'ok' => false,
                'msg' => 'No se recibio el archivo para restaurar.'
            ], JSON_UNESCAPED_UNICODE);
            exit();
        }

        $upload = $_FILES['sql_file'];
        if ((int)($upload['error'] ?? UPLOAD_ERR_NO_FILE) !== UPLOAD_ERR_OK) {
            echo json_encode([
                'ok' => false,
                'msg' => 'Error al subir el archivo SQL.'
            ], JSON_UNESCAPED_UNICODE);
            exit();
        }

        $originalName = (string)($upload['name'] ?? '');
        if (!preg_match('/\.sql$/i', $originalName)) {
            echo json_encode([
                'ok' => false,
                'msg' => 'Solo se permiten archivos con extension .sql'
            ], JSON_UNESCAPED_UNICODE);
            exit();
        }

        $tmpPath = (string)($upload['tmp_name'] ?? '');
        if ($tmpPath === '' || !is_uploaded_file($tmpPath)) {
            echo json_encode([
                'ok' => false,
                'msg' => 'El archivo temporal no es valido.'
            ], JSON_UNESCAPED_UNICODE);
            exit();
        }

        $createSafetyBackup = ((string)($_POST['create_safety_backup'] ?? '0')) === '1';
        $safety = null;
        $safetyWarning = null;
        if ($createSafetyBackup) {
            $safety = $ins->createBackup([], 'safety', true);
            if (!empty($safety['missing_required_schemas']) && is_array($safety['missing_required_schemas'])) {
                $safetyWarning = 'El respaldo de seguridad previo se genero sin los esquemas auxiliares: '
                    . implode(', ', $safety['missing_required_schemas'])
                    . '.';
            }
        }

        $executed = $ins->restoreFromFile($tmpPath);

        echo json_encode([
            'ok' => true,
            'msg' => 'Restauracion completada correctamente.',
            'executed_statements' => $executed,
            'safety_backup' => $safety,
            'safety_backup_warning' => $safetyWarning,
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    echo json_encode([
        'ok' => false,
        'msg' => 'Accion no valida.'
    ], JSON_UNESCAPED_UNICODE);
} catch (Throwable $e) {
    if ($action === 'download') {
        $code = ((int)$e->getCode() === 403) ? 403 : 500;
        http_response_code($code);
        echo 'Error al descargar el respaldo: ' . $e->getMessage();
        exit();
    }

    $statusCode = ((int)$e->getCode() === 403) ? 403 : 500;
    http_response_code($statusCode);

    echo json_encode([
        'ok' => false,
        'msg' => 'Error interno del modulo de respaldos.',
        'detail' => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}

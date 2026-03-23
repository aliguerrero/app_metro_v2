<?php

require_once __DIR__ . "/../../config/app.php";
require_once __DIR__ . "/../views/inc/session_start.php";
require_once __DIR__ . "/../../autoload.php";

use app\models\mainModel;

if (!function_exists('appsec_set_security_headers')) {
    function appsec_set_security_headers(): void
    {
        if (headers_sent()) {
            return;
        }

        header('X-Content-Type-Options: nosniff');
        header('X-Frame-Options: SAMEORIGIN');
        header('Referrer-Policy: strict-origin-when-cross-origin');
        header('Cross-Origin-Resource-Policy: same-origin');
    }
}

if (!function_exists('appsec_json_response')) {
    function appsec_json_response($payload, int $status = 200): void
    {
        appsec_set_security_headers();

        if (!headers_sent()) {
            header('Content-Type: application/json; charset=utf-8');
            http_response_code($status);
        }

        echo json_encode($payload, JSON_UNESCAPED_UNICODE);
        exit();
    }
}

if (!function_exists('appsec_fail')) {
    function appsec_fail(string $message, int $status = 400, array $extra = []): void
    {
        appsec_json_response(array_merge([
            'ok' => false,
            'msg' => $message,
        ], $extra), $status);
    }
}

if (!function_exists('appsec_main_model')) {
    function appsec_main_model(): mainModel
    {
        static $instance = null;

        if (!$instance instanceof mainModel) {
            $instance = new mainModel();
        }

        return $instance;
    }
}

if (!function_exists('appsec_session_user_id')) {
    function appsec_session_user_id(): string
    {
        $idUser = $_SESSION['id_user'] ?? ($_SESSION['id'] ?? '');
        return is_scalar($idUser) ? trim((string)$idUser) : '';
    }
}

if (!function_exists('appsec_is_admin')) {
    function appsec_is_admin(): bool
    {
        return isset($_SESSION['tipo']) && (int)$_SESSION['tipo'] === 1;
    }
}

if (!function_exists('appsec_require_login')) {
    function appsec_require_login(): void
    {
        if (appsec_session_user_id() !== '') {
            return;
        }

        appsec_fail('Debes iniciar sesion para continuar.', 401, ['error' => 'no_autenticado']);
    }
}

if (!function_exists('appsec_require_admin')) {
    function appsec_require_admin(): void
    {
        appsec_require_login();

        if (appsec_is_admin()) {
            return;
        }

        appsec_fail('Solo un administrador puede realizar esta accion.', 403, ['error' => 'permiso_denegado']);
    }
}

if (!function_exists('appsec_require_perm')) {
    function appsec_require_perm(string $permKey, bool $allowAdmin = true): void
    {
        appsec_require_login();

        if ($allowAdmin && appsec_is_admin()) {
            return;
        }

        $perms = $_SESSION['permisos'] ?? [];
        if (!empty($perms[$permKey]) && (int)$perms[$permKey] === 1) {
            return;
        }

        appsec_fail('No tienes permisos para realizar esta accion.', 403, ['error' => 'permiso_denegado']);
    }
}

if (!function_exists('appsec_request_string')) {
    function appsec_request_string(string $key, string $default = ''): string
    {
        $value = $_POST[$key] ?? $_GET[$key] ?? $default;
        if (!is_scalar($value)) {
            return $default;
        }

        return trim((string)$value);
    }
}

if (!function_exists('appsec_clean_string')) {
    function appsec_clean_string(string $value): string
    {
        return appsec_main_model()->limpiarCadena($value);
    }
}

if (!function_exists('appsec_require_method')) {
    function appsec_require_method(string $method): void
    {
        if (strcasecmp($_SERVER['REQUEST_METHOD'] ?? 'GET', $method) === 0) {
            return;
        }

        appsec_fail('Metodo HTTP no permitido.', 405, ['error' => 'metodo_no_permitido']);
    }
}

if (!function_exists('appsec_is_valid_date')) {
    function appsec_is_valid_date(string $value): bool
    {
        return (bool)preg_match('/^\d{4}-\d{2}-\d{2}$/', $value);
    }
}

if (!function_exists('appsec_is_digits')) {
    function appsec_is_digits(string $value): bool
    {
        return $value !== '' && ctype_digit($value);
    }
}

if (!function_exists('appsec_escape')) {
    function appsec_escape(string $value): string
    {
        return htmlspecialchars($value, ENT_QUOTES, 'UTF-8');
    }
}

if (!function_exists('appsec_system_log_path')) {
    function appsec_system_log_path(): string
    {
        $base = defined('APP_ROOT') ? APP_ROOT : dirname(__DIR__, 2);
        $logDir = $base . DIRECTORY_SEPARATOR . 'storage' . DIRECTORY_SEPARATOR . 'logs';

        if (!is_dir($logDir)) {
            @mkdir($logDir, 0775, true);
        }

        return $logDir . DIRECTORY_SEPARATOR . 'system_errors.log';
    }
}

if (!function_exists('appsec_log_system_error')) {
    function appsec_log_system_error(string $nivel, string $modulo, string $mensaje, array $contexto = []): void
    {
        try {
            appsec_main_model()->registrarLogSistema($nivel, $modulo, $mensaje, $contexto);
        } catch (\Throwable $e) {
            error_log('[appsec_log_system_error] ' . $e->getMessage());
        }
    }
}

ini_set('display_errors', '0');
ini_set('html_errors', '0');
ini_set('log_errors', '1');
ini_set('error_log', appsec_system_log_path());
error_reporting(E_ALL);

appsec_set_security_headers();

if (!defined('APPSEC_ERROR_HANDLERS_REGISTERED')) {
    define('APPSEC_ERROR_HANDLERS_REGISTERED', true);

    set_error_handler(static function (int $severity, string $message, string $file = '', int $line = 0): bool {
        appsec_log_system_error('ERROR', 'php.error', 'Error PHP capturado.', [
            'severity' => $severity,
            'message' => $message,
            'file' => $file,
            'line' => $line,
        ]);

        return false;
    });

    register_shutdown_function(static function (): void {
        $error = error_get_last();
        if (!is_array($error)) {
            return;
        }

        $fatalTypes = [E_ERROR, E_PARSE, E_CORE_ERROR, E_COMPILE_ERROR, E_USER_ERROR];
        if (!in_array((int)($error['type'] ?? 0), $fatalTypes, true)) {
            return;
        }

        appsec_log_system_error('CRITICAL', 'php.shutdown', 'Error fatal en shutdown.', [
            'type' => (int)($error['type'] ?? 0),
            'message' => (string)($error['message'] ?? ''),
            'file' => (string)($error['file'] ?? ''),
            'line' => (int)($error['line'] ?? 0),
        ]);
    });
}

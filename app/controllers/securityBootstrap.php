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

ini_set('display_errors', '0');
ini_set('html_errors', '0');
ini_set('log_errors', '1');
error_reporting(E_ALL);

appsec_set_security_headers();

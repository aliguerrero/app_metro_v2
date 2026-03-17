<?php

if (!function_exists('app_first_server_value')) {
    function app_first_server_value(array $keys): string
    {
        foreach ($keys as $key) {
            if (!array_key_exists($key, $_SERVER)) {
                continue;
            }

            $value = trim((string)$_SERVER[$key]);
            if ($value === '') {
                continue;
            }

            $parts = explode(',', $value);
            $value = trim((string)$parts[0]);

            if ($value !== '') {
                return $value;
            }
        }

        return '';
    }
}

if (!function_exists('app_host_has_explicit_port')) {
    function app_host_has_explicit_port(string $host): bool
    {
        return preg_match('/^\[[^\]]+\]:\d+$/', $host) === 1
            || preg_match('/^[^:\[\]]+:\d+$/', $host) === 1;
    }
}

if (!function_exists('app_detect_scheme')) {
    function app_detect_scheme(): string
    {
        $forwardedProto = strtolower(app_first_server_value([
            'HTTP_X_FORWARDED_PROTO',
            'HTTP_X_FORWARDED_PROTOCOL',
            'HTTP_X_FORWARDED_SCHEME',
        ]));

        if (in_array($forwardedProto, ['https', 'wss'], true)) {
            return 'https';
        }

        foreach (['HTTP_X_FORWARDED_SSL', 'HTTP_X_FORWARDED_HTTPS', 'HTTP_FRONT_END_HTTPS'] as $key) {
            $flag = strtolower(app_first_server_value([$key]));

            if (in_array($flag, ['on', '1', 'https'], true)) {
                return 'https';
            }
        }

        $requestScheme = strtolower((string)($_SERVER['REQUEST_SCHEME'] ?? ''));
        if ($requestScheme === 'https') {
            return 'https';
        }

        $https = strtolower((string)($_SERVER['HTTPS'] ?? ''));
        if ($https !== '' && $https !== 'off') {
            return 'https';
        }

        $forwardedPort = (int)app_first_server_value(['HTTP_X_FORWARDED_PORT']);
        if ($forwardedPort === 443) {
            return 'https';
        }

        $serverPort = isset($_SERVER['SERVER_PORT']) ? (int)$_SERVER['SERVER_PORT'] : 0;
        if ($serverPort === 443) {
            return 'https';
        }

        return 'http';
    }
}

if (!function_exists('app_detect_host')) {
    function app_detect_host(): string
    {
        $appHost = app_first_server_value(['HTTP_X_FORWARDED_HOST', 'HTTP_HOST', 'SERVER_NAME']);
        $appHost = preg_replace('/[^a-zA-Z0-9.:\-\[\]]/', '', $appHost);

        if ($appHost === '') {
            $appHost = 'localhost';
        }

        $port = (int)app_first_server_value(['HTTP_X_FORWARDED_PORT']);

        if ($port > 0 && !app_host_has_explicit_port($appHost)) {
            $appHost .= ':' . $port;
        }

        return $appHost;
    }
}

$envAppUrl = getenv('APP_URL');

if (is_string($envAppUrl) && trim($envAppUrl) !== '') {
    define('APP_URL', rtrim(trim($envAppUrl), '/') . '/');
} else {
    define('APP_URL', app_detect_scheme() . '://' . app_detect_host() . '/app_metro/');
}

define('APP_IS_HTTPS', strtolower((string)parse_url(APP_URL, PHP_URL_SCHEME)) === 'https');

$envMailLogoUrl = getenv('APP_MAIL_LOGO_URL');
if (is_string($envMailLogoUrl) && trim($envMailLogoUrl) !== '') {
    define('APP_MAIL_LOGO_URL', trim($envMailLogoUrl));
} else {
    define('APP_MAIL_LOGO_URL', APP_URL . 'app/views/img/logo.png');
}

const APP_NAME = "FERRENET SYSTEM";
const APP_SESSION_NAME = "app_metro";
const APP_ROOT = __DIR__ . "/..";

date_default_timezone_set("America/Caracas");

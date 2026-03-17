<?php

namespace app\controllers;

use app\lib\SmtpClient;
use app\models\mainModel;

class smtpConfigController extends mainModel
{
    private const CONFIG_ID = 1;

    private function ensureDefaultRow(): void
    {
        $st = $this->ejecutarConsultaConParametros(
            "SELECT `id` FROM `smtp_config` WHERE `id` = :id LIMIT 1",
            [':id' => self::CONFIG_ID]
        );

        if ($st && (int)$st->rowCount() === 1) {
            return;
        }

        $this->guardarDatos('smtp_config', [
            ['campo_nombre' => 'id', 'campo_marcador' => ':id', 'campo_valor' => self::CONFIG_ID],
            ['campo_nombre' => 'enabled', 'campo_marcador' => ':enabled', 'campo_valor' => 0],
            ['campo_nombre' => 'provider', 'campo_marcador' => ':provider', 'campo_valor' => 'google'],
            ['campo_nombre' => 'host', 'campo_marcador' => ':host', 'campo_valor' => 'smtp.gmail.com'],
            ['campo_nombre' => 'port', 'campo_marcador' => ':port', 'campo_valor' => 587],
            ['campo_nombre' => 'encryption', 'campo_marcador' => ':encryption', 'campo_valor' => 'tls'],
            ['campo_nombre' => 'username', 'campo_marcador' => ':username', 'campo_valor' => ''],
            ['campo_nombre' => 'password', 'campo_marcador' => ':password', 'campo_valor' => ''],
            ['campo_nombre' => 'from_email', 'campo_marcador' => ':from_email', 'campo_valor' => ''],
            ['campo_nombre' => 'from_name', 'campo_marcador' => ':from_name', 'campo_valor' => null],
        ]);
    }

    private function tableMissingMessage(): string
    {
        return "No existe la tabla smtp_config. Ejecuta la migracion db/migrations/2026-03-16_create_smtp_config.sql.";
    }

    private function isEncryptedSecret(string $value): bool
    {
        return strncmp($value, 'gcm:', 4) === 0;
    }

    private function cryptKeyBytes(): string
    {
        $keyB64 = getenv('APP_SMTP_CRYPT_KEY');
        if (!is_string($keyB64) || trim($keyB64) === '') {
            $keyB64 = defined('APP_SMTP_CRYPT_KEY') ? (string)APP_SMTP_CRYPT_KEY : '';
        }

        $keyB64 = trim((string)$keyB64);
        if ($keyB64 !== '') {
            $raw = base64_decode($keyB64, true);
            if ($raw === false || strlen($raw) !== 32) {
                throw new \RuntimeException('APP_SMTP_CRYPT_KEY invalida. Debe ser Base64 de 32 bytes.');
            }
            return $raw;
        }

        // Fallback: deriva una clave estable desde DB_PASS (evita guardar la clave en la BD en texto plano).
        if (defined('DB_PASS')) {
            return hash('sha256', (string)DB_PASS, true);
        }

        throw new \RuntimeException('Falta APP_SMTP_CRYPT_KEY para cifrar la clave SMTP.');
    }

    private function encryptSecret(string $plaintext): string
    {
        if ($plaintext === '') {
            return '';
        }

        if (!function_exists('openssl_encrypt')) {
            throw new \RuntimeException('OpenSSL no esta disponible para cifrar.');
        }

        $key = $this->cryptKeyBytes();
        $iv = random_bytes(12);
        $tag = '';

        $cipher = openssl_encrypt(
            $plaintext,
            'aes-256-gcm',
            $key,
            OPENSSL_RAW_DATA,
            $iv,
            $tag,
            '',
            16
        );

        if ($cipher === false || $tag === '') {
            throw new \RuntimeException('No se pudo cifrar la clave SMTP.');
        }

        return 'gcm:' . base64_encode($iv . $tag . $cipher);
    }

    private function decryptSecret(string $stored): string
    {
        if ($stored === '') {
            return '';
        }

        // Compatibilidad: si aun esta en texto plano, retorna tal cual.
        if (!$this->isEncryptedSecret($stored)) {
            return $stored;
        }

        if (!function_exists('openssl_decrypt')) {
            throw new \RuntimeException('OpenSSL no esta disponible para descifrar.');
        }

        $b64 = substr($stored, 4);
        $raw = base64_decode($b64, true);
        if ($raw === false || strlen($raw) < 28) {
            throw new \RuntimeException('Formato de clave SMTP cifrada invalido.');
        }

        $iv = substr($raw, 0, 12);
        $tag = substr($raw, 12, 16);
        $cipher = substr($raw, 28);

        $key = $this->cryptKeyBytes();
        $plain = openssl_decrypt($cipher, 'aes-256-gcm', $key, OPENSSL_RAW_DATA, $iv, $tag);
        if ($plain === false) {
            throw new \RuntimeException('No se pudo descifrar la clave SMTP. Revisa APP_SMTP_CRYPT_KEY.');
        }

        return $plain;
    }

    public function enviarCorreoConfigurado(
        string $toEmail,
        string $subject,
        string $htmlBody = '',
        string $textBody = '',
        array $inlineAttachments = []
    ): array {
        $toEmail = trim($toEmail);
        if ($toEmail === '' || filter_var($toEmail, FILTER_VALIDATE_EMAIL) === false) {
            return ['ok' => false, 'msg' => 'Correo destino invalido.'];
        }

        try {
            $this->ensureDefaultRow();

            $st = $this->ejecutarConsultaConParametros(
                "SELECT `enabled`, `host`, `port`, `encryption`, `username`, `password`, `from_email`, `from_name`
                 FROM `smtp_config`
                 WHERE `id` = :id
                 LIMIT 1",
                [':id' => self::CONFIG_ID]
            );

            if (!$st || (int)$st->rowCount() !== 1) {
                return ['ok' => false, 'msg' => 'No se encontro la configuracion SMTP.'];
            }

            $cfg = $st->fetch(\PDO::FETCH_ASSOC) ?: [];
            $enabled = (int)($cfg['enabled'] ?? 0);
            $host = trim((string)($cfg['host'] ?? ''));
            $port = (int)($cfg['port'] ?? 0);
            $encryption = strtolower(trim((string)($cfg['encryption'] ?? 'tls')));
            $username = trim((string)($cfg['username'] ?? ''));
            $storedPassword = (string)($cfg['password'] ?? '');
            $fromEmail = trim((string)($cfg['from_email'] ?? ''));
            $fromName = trim((string)($cfg['from_name'] ?? ''));

            if ($enabled !== 1) {
                return ['ok' => false, 'msg' => 'SMTP esta deshabilitado en configuracion.'];
            }

            if ($fromEmail === '' && $username !== '') {
                $fromEmail = $username;
            }

            if ($host === '' || $port <= 0) {
                return ['ok' => false, 'msg' => 'Configura host y puerto SMTP.'];
            }

            if ($username === '' || trim($storedPassword) === '') {
                return ['ok' => false, 'msg' => 'Configura usuario y clave SMTP (App Password).'];
            }

            if ($fromEmail === '' || filter_var($fromEmail, FILTER_VALIDATE_EMAIL) === false) {
                return ['ok' => false, 'msg' => 'Configura un correo From valido.'];
            }

            $password = $this->decryptSecret($storedPassword);
            if (trim($password) === '') {
                return ['ok' => false, 'msg' => 'La clave SMTP no es valida.'];
            }

            // Migra en caliente secretos en texto plano a formato cifrado.
            if ($storedPassword !== '' && !$this->isEncryptedSecret($storedPassword)) {
                try {
                    $this->actualizarDatos(
                        'smtp_config',
                        [[
                            'campo_nombre' => 'password',
                            'campo_marcador' => ':password',
                            'campo_valor' => $this->encryptSecret($storedPassword),
                        ]],
                        [
                            'condicion_campo' => 'id',
                            'condicion_marcador' => ':id',
                            'condicion_valor' => self::CONFIG_ID,
                        ]
                    );
                } catch (\Throwable $e) {
                    // No bloquea el envio por fallo de migracion.
                }
            }

            $clientName = 'localhost';
            try {
                $urlHost = (string)parse_url(defined('APP_URL') ? APP_URL : '', PHP_URL_HOST);
                if (trim($urlHost) !== '') {
                    $clientName = trim($urlHost);
                }
            } catch (\Throwable $e) {
                // ignore
            }

            $smtp = new SmtpClient([
                'host' => $host,
                'port' => $port,
                'encryption' => $encryption,
                'username' => $username,
                'password' => $password,
                'timeout' => 15,
                'client_name' => $clientName,
            ]);

            $subject = trim($subject);
            if ($subject === '') {
                $subject = 'Notificacion del sistema';
            }

            $htmlBody = trim($htmlBody);
            $textBody = trim($textBody);

            if ($htmlBody !== '') {
                if ($inlineAttachments !== []) {
                    $smtp->sendHtmlInline($fromEmail, $fromName, $toEmail, $subject, $htmlBody, $inlineAttachments);
                } else {
                    $smtp->sendHtml($fromEmail, $fromName, $toEmail, $subject, $htmlBody);
                }
            } else {
                $smtp->sendText($fromEmail, $fromName, $toEmail, $subject, $textBody);
            }

            return ['ok' => true, 'msg' => 'Correo enviado correctamente.'];
        } catch (\Throwable $e) {
            $msg = trim($e->getMessage());
            if ($msg === '') {
                $msg = 'Error enviando correo.';
            }
            return ['ok' => false, 'msg' => $msg];
        }
    }

    public function obtenerSmtpControlador(): string
    {
        if (!isset($_SESSION['id'])) {
            return json_encode([
                'ok' => false,
                'msg' => 'Sesion invalida.',
            ]);
        }

        try {
            $this->ensureDefaultRow();
        } catch (\Throwable $e) {
            if (stripos($e->getMessage(), 'smtp_config') !== false) {
                return json_encode(['ok' => false, 'msg' => $this->tableMissingMessage()]);
            }

            return json_encode(['ok' => false, 'msg' => 'No se pudo cargar la configuracion SMTP.']);
        }

        try {
            $cols = $this->columnasTablaSql('smtp_config');
            $st = $this->ejecutarConsultaConParametros(
                "SELECT {$cols} FROM `smtp_config` WHERE `id` = :id LIMIT 1",
                [':id' => self::CONFIG_ID]
            );

            if (!$st || (int)$st->rowCount() !== 1) {
                return json_encode(['ok' => false, 'msg' => 'No se encontro la configuracion SMTP.']);
            }

            $cfg = $st->fetch(\PDO::FETCH_ASSOC) ?: [];
            $storedPassword = isset($cfg['password']) ? (string)$cfg['password'] : '';
            $passwordSet = trim($storedPassword) !== '';

            // Migracion best-effort: si aun esta en texto plano, cifrarla al leer.
            if ($passwordSet && !$this->isEncryptedSecret($storedPassword)) {
                try {
                    $this->actualizarDatos(
                        'smtp_config',
                        [[
                            'campo_nombre' => 'password',
                            'campo_marcador' => ':password',
                            'campo_valor' => $this->encryptSecret($storedPassword),
                        ]],
                        [
                            'condicion_campo' => 'id',
                            'condicion_marcador' => ':id',
                            'condicion_valor' => self::CONFIG_ID,
                        ]
                    );
                } catch (\Throwable $e) {
                    // Ignorar: no bloquear la carga si la migracion falla.
                }
            }
            unset($cfg['password']);
            $cfg['password_set'] = $passwordSet;

            return json_encode([
                'ok' => true,
                'data' => $cfg,
            ]);
        } catch (\Throwable $e) {
            return json_encode(['ok' => false, 'msg' => 'Error consultando la configuracion SMTP.']);
        }
    }

    public function guardarSmtpControlador(): string
    {
        if (!isset($_SESSION['id'])) {
            return json_encode(['ok' => false, 'msg' => 'Sesion invalida.']);
        }

        try {
            $this->ensureDefaultRow();
        } catch (\Throwable $e) {
            if (stripos($e->getMessage(), 'smtp_config') !== false) {
                return json_encode(['ok' => false, 'msg' => $this->tableMissingMessage()]);
            }
            return json_encode(['ok' => false, 'msg' => 'No se pudo inicializar la configuracion SMTP.']);
        }

        $enabledRaw = $_POST['enabled'] ?? '0';
        $enabled = ($enabledRaw === '1' || $enabledRaw === 1 || $enabledRaw === true || $enabledRaw === 'true' || $enabledRaw === 'on') ? 1 : 0;

        $host = strtolower(trim((string)($_POST['host'] ?? 'smtp.gmail.com')));
        $host = preg_replace('/[^a-z0-9\\.-]/', '', $host);
        if ($host === '') {
            $host = 'smtp.gmail.com';
        }

        $port = (int)($_POST['port'] ?? 587);
        if ($port < 1 || $port > 65535) {
            return json_encode(['ok' => false, 'msg' => 'Puerto SMTP invalido.']);
        }

        $encryption = strtolower(trim((string)($_POST['encryption'] ?? 'tls')));
        if (!in_array($encryption, ['tls', 'ssl', 'none'], true)) {
            $encryption = 'tls';
        }

        $username = trim((string)($_POST['username'] ?? ''));
        $fromEmail = trim((string)($_POST['from_email'] ?? ''));
        $fromName = trim((string)($_POST['from_name'] ?? ''));

        // Password: no pasarlo por limpiarCadena; solo trim para preservar App Password.
        $password = (string)($_POST['password'] ?? '');
        $password = trim($password);

        if ($fromEmail === '' && $username !== '') {
            $fromEmail = $username;
        }

        if ($username !== '' && filter_var($username, FILTER_VALIDATE_EMAIL) === false) {
            return json_encode(['ok' => false, 'msg' => 'El usuario SMTP debe ser un correo valido.']);
        }

        if ($fromEmail !== '' && filter_var($fromEmail, FILTER_VALIDATE_EMAIL) === false) {
            return json_encode(['ok' => false, 'msg' => 'El correo From debe ser valido.']);
        }

        // Si habilita, exigimos campos minimos.
        if ($enabled === 1) {
            if ($username === '' || $fromEmail === '') {
                return json_encode(['ok' => false, 'msg' => 'Completa usuario SMTP y correo From para habilitar.']);
            }
        }

        // Si no trae password, se mantiene el actual.
        $currentPassword = '';
        try {
            $st = $this->ejecutarConsultaConParametros(
                "SELECT `password` FROM `smtp_config` WHERE `id` = :id LIMIT 1",
                [':id' => self::CONFIG_ID]
            );
            if ($st && (int)$st->rowCount() === 1) {
                $row = $st->fetch(\PDO::FETCH_ASSOC);
                $currentPassword = is_array($row) ? (string)($row['password'] ?? '') : '';
            }
        } catch (\Throwable $e) {
            // Ignorar; se validara abajo.
        }

        $hasPassword = $password !== '' || trim($currentPassword) !== '';
        if ($enabled === 1 && !$hasPassword) {
            return json_encode(['ok' => false, 'msg' => 'Debes colocar una clave (App Password) para habilitar.']);
        }

        $datos = [
            ['campo_nombre' => 'enabled', 'campo_marcador' => ':enabled', 'campo_valor' => $enabled],
            ['campo_nombre' => 'provider', 'campo_marcador' => ':provider', 'campo_valor' => 'google'],
            ['campo_nombre' => 'host', 'campo_marcador' => ':host', 'campo_valor' => $host],
            ['campo_nombre' => 'port', 'campo_marcador' => ':port', 'campo_valor' => $port],
            ['campo_nombre' => 'encryption', 'campo_marcador' => ':encryption', 'campo_valor' => $encryption],
            ['campo_nombre' => 'username', 'campo_marcador' => ':username', 'campo_valor' => $username],
            ['campo_nombre' => 'from_email', 'campo_marcador' => ':from_email', 'campo_valor' => $fromEmail],
            ['campo_nombre' => 'from_name', 'campo_marcador' => ':from_name', 'campo_valor' => ($fromName !== '' ? $fromName : null)],
        ];

        // Siempre guardamos la clave cifrada (AES-256-GCM). Si no llega clave nueva, migramos la existente si esta en texto plano.
        $plainToEncrypt = '';
        if ($password !== '') {
            $plainToEncrypt = $password;
        } elseif (trim($currentPassword) !== '' && !$this->isEncryptedSecret($currentPassword)) {
            $plainToEncrypt = $currentPassword;
        }

        if ($plainToEncrypt !== '') {
            try {
                $datos[] = [
                    'campo_nombre' => 'password',
                    'campo_marcador' => ':password',
                    'campo_valor' => $this->encryptSecret($plainToEncrypt),
                ];
            } catch (\Throwable $e) {
                $msg = trim($e->getMessage());
                if ($msg === '') {
                    $msg = 'No se pudo cifrar la clave SMTP.';
                }
                return json_encode(['ok' => false, 'msg' => $msg]);
            }
        }

        $condicion = [
            'condicion_campo' => 'id',
            'condicion_marcador' => ':id',
            'condicion_valor' => self::CONFIG_ID,
        ];

        try {
            $this->actualizarDatos('smtp_config', $datos, $condicion);
            return json_encode(['ok' => true, 'msg' => 'Configuracion SMTP guardada.']);
        } catch (\Throwable $e) {
            return json_encode(['ok' => false, 'msg' => 'No se pudo guardar la configuracion SMTP.']);
        }
    }

    public function probarEnvioSmtpControlador(): string
    {
        if (!isset($_SESSION['id'])) {
            return json_encode(['ok' => false, 'msg' => 'Sesion invalida.']);
        }

        $toEmail = trim((string)($_POST['to_email'] ?? ''));
        if ($toEmail === '' || filter_var($toEmail, FILTER_VALIDATE_EMAIL) === false) {
            return json_encode(['ok' => false, 'msg' => 'Correo destino invalido.']);
        }
        $subject = 'Prueba SMTP (Google)';
        $text = "Hola,\n\nEste es un correo de prueba enviado desde el modulo de configuracion SMTP.\n\nFecha: " . date('Y-m-d H:i:s') . "\n";

        $send = $this->enviarCorreoConfigurado($toEmail, $subject, '', $text);
        if (!empty($send['ok'])) {
            return json_encode(['ok' => true, 'msg' => 'Correo de prueba enviado correctamente.']);
        }

        $msg = trim((string)($send['msg'] ?? ''));
        if ($msg === '') {
            $msg = 'Error enviando el correo de prueba.';
        }
        return json_encode(['ok' => false, 'msg' => $msg]);
    }
}

<?php

namespace app\lib;

use RuntimeException;

class SmtpClient
{
    private string $host;
    private int $port;
    private string $encryption; // tls|ssl|none
    private string $username;
    private string $password;
    private int $timeout;
    private string $clientName;

    public function __construct(array $options = [])
    {
        $this->host = trim((string)($options['host'] ?? ''));
        $this->port = (int)($options['port'] ?? 0);
        $this->encryption = strtolower(trim((string)($options['encryption'] ?? 'tls')));
        $this->username = trim((string)($options['username'] ?? ''));
        $this->password = (string)($options['password'] ?? '');
        $this->timeout = max(3, (int)($options['timeout'] ?? 12));
        $this->clientName = trim((string)($options['client_name'] ?? 'localhost'));

        if ($this->clientName === '') {
            $this->clientName = 'localhost';
        }

        if (!in_array($this->encryption, ['tls', 'ssl', 'none'], true)) {
            $this->encryption = 'tls';
        }
    }

    public function sendText(string $fromEmail, string $fromName, string $toEmail, string $subject, string $body): void
    {
        $this->sendWithBody($fromEmail, $fromName, $toEmail, $subject, $body, 'text/plain; charset=UTF-8');
    }

    public function sendHtml(string $fromEmail, string $fromName, string $toEmail, string $subject, string $htmlBody): void
    {
        $this->sendWithBody($fromEmail, $fromName, $toEmail, $subject, $htmlBody, 'text/html; charset=UTF-8');
    }

    public function sendHtmlInline(
        string $fromEmail,
        string $fromName,
        string $toEmail,
        string $subject,
        string $htmlBody,
        array $inlineAttachments
    ): void {
        if ($inlineAttachments === []) {
            $this->sendHtml($fromEmail, $fromName, $toEmail, $subject, $htmlBody);
            return;
        }

        $boundary = 'rel_' . bin2hex(random_bytes(12));
        $headersContentType = 'multipart/related; boundary="' . $boundary . '"';

        $parts = [];
        $parts[] = "--{$boundary}";
        $parts[] = 'Content-Type: text/html; charset=UTF-8';
        $parts[] = 'Content-Transfer-Encoding: 8bit';
        $parts[] = '';
        $parts[] = $htmlBody;

        foreach ($inlineAttachments as $attachment) {
            $cid = $this->sanitizeHeader((string)($attachment['cid'] ?? ''));
            $path = (string)($attachment['path'] ?? '');
            $mime = $this->sanitizeHeader((string)($attachment['mime'] ?? 'application/octet-stream'));

            if ($cid === '' || $path === '') {
                continue;
            }

            if (!is_file($path)) {
                throw new RuntimeException("Archivo inline no encontrado: {$path}");
            }

            $raw = @file_get_contents($path);
            if (!is_string($raw) || $raw === '') {
                throw new RuntimeException("No se pudo leer archivo inline: {$path}");
            }

            $parts[] = "--{$boundary}";
            $parts[] = "Content-Type: {$mime}";
            $parts[] = 'Content-Transfer-Encoding: base64';
            $parts[] = "Content-ID: <{$cid}>";
            $parts[] = "X-Attachment-Id: {$cid}";
            $parts[] = 'Content-Disposition: inline';
            $parts[] = '';
            $parts[] = rtrim(chunk_split(base64_encode($raw), 76, "\r\n"));
        }

        $parts[] = "--{$boundary}--";
        $body = implode("\r\n", $parts);

        $this->sendWithBody($fromEmail, $fromName, $toEmail, $subject, $body, $headersContentType);
    }

    private function sendWithBody(
        string $fromEmail,
        string $fromName,
        string $toEmail,
        string $subject,
        string $body,
        string $contentType
    ): void
    {
        $stream = $this->connect();

        try {
            $this->expect($stream, [220]);

            $this->cmd($stream, 'EHLO ' . $this->clientName, [250]);

            if ($this->encryption === 'tls') {
                $this->cmd($stream, 'STARTTLS', [220]);

                $cryptoOk = stream_socket_enable_crypto($stream, true, STREAM_CRYPTO_METHOD_TLS_CLIENT);
                if ($cryptoOk !== true) {
                    throw new RuntimeException('No se pudo iniciar TLS (STARTTLS).');
                }

                $this->cmd($stream, 'EHLO ' . $this->clientName, [250]);
            }

            if ($this->username !== '') {
                $this->cmd($stream, 'AUTH LOGIN', [334]);
                $this->cmd($stream, base64_encode($this->username), [334]);
                $this->cmd($stream, base64_encode($this->password), [235]);
            }

            $envelopeFrom = $this->username !== '' ? $this->username : $fromEmail;
            $this->cmd($stream, 'MAIL FROM:<' . $this->sanitizePath($envelopeFrom) . '>', [250]);
            $this->cmd($stream, 'RCPT TO:<' . $this->sanitizePath($toEmail) . '>', [250, 251]);
            $this->cmd($stream, 'DATA', [354]);

            $headers = $this->buildHeaders($fromEmail, $fromName, $toEmail, $subject, $contentType);
            $this->writeData($stream, $headers . "\r\n\r\n" . $body);
            $this->expect($stream, [250]);

            $this->cmd($stream, 'QUIT', [221]);
        } finally {
            if (is_resource($stream)) {
                fclose($stream);
            }
        }
    }

    private function connect()
    {
        if ($this->host === '' || $this->port <= 0 || $this->port > 65535) {
            throw new RuntimeException('Host/puerto SMTP no configurado.');
        }

        $scheme = 'tcp';
        if ($this->encryption === 'ssl') {
            $scheme = 'ssl';
        }

        $remote = $scheme . '://' . $this->host . ':' . $this->port;

        $context = stream_context_create([
            'ssl' => [
                'verify_peer' => true,
                'verify_peer_name' => true,
                'allow_self_signed' => false,
                'SNI_enabled' => true,
            ],
        ]);

        $errno = 0;
        $errstr = '';
        $stream = @stream_socket_client(
            $remote,
            $errno,
            $errstr,
            $this->timeout,
            STREAM_CLIENT_CONNECT,
            $context
        );

        if ($stream === false) {
            $errstr = trim((string)$errstr);
            throw new RuntimeException('No se pudo conectar al servidor SMTP. ' . ($errstr !== '' ? $errstr : 'Error desconocido') . " ({$errno}).");
        }

        stream_set_timeout($stream, $this->timeout);
        return $stream;
    }

    private function cmd($stream, string $command, array $okCodes): void
    {
        $this->writeLine($stream, $command);
        $this->expect($stream, $okCodes);
    }

    private function writeLine($stream, string $line): void
    {
        $line = rtrim($line, "\r\n");
        $written = fwrite($stream, $line . "\r\n");
        if ($written === false) {
            throw new RuntimeException('No se pudo escribir al socket SMTP.');
        }
    }

    private function writeData($stream, string $data): void
    {
        // Normaliza a \n, luego envia con \r\n y dot-stuffing.
        $data = str_replace(["\r\n", "\r"], "\n", $data);
        $lines = explode("\n", $data);

        foreach ($lines as &$line) {
            if ($line !== '' && $line[0] === '.') {
                $line = '.' . $line;
            }
        }
        unset($line);

        $payload = implode("\r\n", $lines);
        $payload = rtrim($payload, "\r\n");

        $written = fwrite($stream, $payload . "\r\n.\r\n");
        if ($written === false) {
            throw new RuntimeException('No se pudo enviar el cuerpo del mensaje SMTP.');
        }
    }

    private function expect($stream, array $okCodes): void
    {
        [$code, $raw] = $this->readResponse($stream);
        if (!in_array($code, $okCodes, true)) {
            $expected = implode(', ', $okCodes);
            $raw = trim($raw);
            throw new RuntimeException("SMTP respondio {$code} (esperado {$expected}). {$raw}");
        }
    }

    private function readResponse($stream): array
    {
        $all = '';
        $code = 0;

        while (!feof($stream)) {
            $line = fgets($stream, 515);
            if ($line === false) {
                $meta = stream_get_meta_data($stream);
                if (!empty($meta['timed_out'])) {
                    throw new RuntimeException('Timeout leyendo respuesta SMTP.');
                }
                break;
            }

            $all .= $line;

            if (preg_match('/^(\\d{3})([ -])/', $line, $m)) {
                $code = (int)$m[1];
                $sep = $m[2];
                if ($sep === ' ') {
                    break;
                }
                continue;
            }

            if (strlen($all) > 4096) {
                break;
            }
        }

        if ($code === 0) {
            $trim = trim($all);
            if ($trim === '') {
                $trim = 'Respuesta vacia.';
            }
            throw new RuntimeException('Respuesta SMTP invalida. ' . $trim);
        }

        return [$code, $all];
    }

    private function buildHeaders(
        string $fromEmail,
        string $fromName,
        string $toEmail,
        string $subject,
        string $contentType
    ): string
    {
        $from = $this->formatAddress($fromEmail, $fromName);
        $to = $this->formatAddress($toEmail, '');

        $date = gmdate('D, d M Y H:i:s') . ' +0000';
        $msgId = '<' . bin2hex(random_bytes(16)) . '@' . $this->clientName . '>';

        $subject = $this->sanitizeHeader($subject);

        $headers = [];
        $headers[] = "From: {$from}";
        $headers[] = "To: {$to}";
        $headers[] = "Subject: {$subject}";
        $headers[] = "Date: {$date}";
        $headers[] = "Message-ID: {$msgId}";
        $headers[] = "MIME-Version: 1.0";
        $headers[] = "Content-Type: " . $this->sanitizeHeader($contentType);
        $headers[] = "Content-Transfer-Encoding: 8bit";

        return implode("\r\n", $headers);
    }

    private function formatAddress(string $email, string $name): string
    {
        $email = $this->sanitizeAddress($email);
        $name = $this->sanitizeHeader($name);

        if ($name === '') {
            return "<{$email}>";
        }

        $name = trim($name, " \t\"");
        return "\"{$name}\" <{$email}>";
    }

    private function sanitizeHeader(string $value): string
    {
        // Evita header injection.
        $value = str_replace(["\r", "\n"], ' ', (string)$value);
        return trim($value);
    }

    private function sanitizeAddress(string $email): string
    {
        $email = trim($email);
        $email = str_replace(["\r", "\n", "<", ">"], '', $email);
        return $email;
    }

    private function sanitizePath(string $email): string
    {
        return $this->sanitizeAddress($email);
    }
}

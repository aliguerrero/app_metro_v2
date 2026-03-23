<?php

namespace app\controllers;

use app\models\mainModel;

class loginController extends mainModel
{
    private const MAX_FAILED_ATTEMPTS = 3;
    private const AUTH_LOG_TABLE = 'auth_session';
    private const ROOT_ROLE_ID = 1;
    private const ROOT_ROLE_NAME = 'ROOT';
    private const ROOT_USERNAME = 'root';
    private const ROOT_CATEGORY_NAME = 'ROOT / ADMINISTRACION DEL SISTEMA';
    private const ROOT_CATEGORY_DESC = 'Categoria inicial para el administrador principal del sistema.';

    private function columnasPermisosRol(): array
    {
        return array_values(array_filter(
            $this->columnasTabla('roles_permisos'),
            static fn(string $column): bool => strpos($column, 'perm_') === 0
        ));
    }

    private function asegurarRolRoot(): int
    {
        $permissionColumns = $this->columnasPermisosRol();
        if ($permissionColumns === []) {
            return self::ROOT_ROLE_ID;
        }

        $params = [
            ':id' => self::ROOT_ROLE_ID,
            ':nombre_rol' => self::ROOT_ROLE_NAME,
        ];

        foreach ($permissionColumns as $column) {
            $params[':' . $column] = 1;
        }

        $exists = $this->ejecutarConsultaConParametros(
            "SELECT id FROM roles_permisos WHERE id = :id LIMIT 1",
            [':id' => self::ROOT_ROLE_ID]
        );

        if ($exists && $exists->rowCount() > 0) {
            $sets = ['nombre_rol = :nombre_rol'];
            foreach ($permissionColumns as $column) {
                $sets[] = "`{$column}` = :{$column}";
            }

            $this->ejecutarConsultaConParametros(
                "UPDATE roles_permisos
                 SET " . implode(', ', $sets) . "
                 WHERE id = :id",
                $params
            );

            return self::ROOT_ROLE_ID;
        }

        $columnsSql = implode(', ', array_map(static fn(string $column): string => "`{$column}`", $permissionColumns));
        $markersSql = implode(', ', array_map(static fn(string $column): string => ':' . $column, $permissionColumns));

        $sql = "INSERT INTO roles_permisos (
                    id,
                    nombre_rol" . ($columnsSql !== '' ? ', ' . $columnsSql : '') . "
                ) VALUES (
                    :id,
                    :nombre_rol" . ($markersSql !== '' ? ', ' . $markersSql : '') . "
                )";

        $this->ejecutarConsultaConParametros($sql, $params);

        return self::ROOT_ROLE_ID;
    }

    public function asegurarRolRootControlador(): void
    {
        try {
            $this->asegurarRolRoot();
        } catch (\Throwable $e) {
            $this->registrarLogSistema('ERROR', 'auth.bootstrap', 'No se pudo asegurar el rol ROOT.', [
                'exception' => $e->getMessage(),
            ]);
        }
    }

    public function sistemaRequiereBootstrapControlador(): bool
    {
        $this->asegurarRolRootControlador();

        try {
            $stmt = $this->ejecutarConsultaConParametros(
                "SELECT COUNT(*) FROM user_system WHERE std_reg = 1"
            );

            return ((int)($stmt ? $stmt->fetchColumn() : 0)) === 0;
        } catch (\Throwable $e) {
            $this->registrarLogSistema('ERROR', 'auth.bootstrap', 'No se pudo determinar si el sistema requiere configuracion inicial.', [
                'exception' => $e->getMessage(),
            ]);
            return false;
        }
    }

    private function asegurarCategoriaRoot(): int
    {
        $stmt = $this->ejecutarConsultaConParametros(
            "SELECT id_ai_categoria_empleado, std_reg
             FROM categoria_empleado
             WHERE nombre_categoria = :nombre
             LIMIT 1",
            [':nombre' => self::ROOT_CATEGORY_NAME]
        );

        if ($stmt && $stmt->rowCount() > 0) {
            $row = $stmt->fetch(\PDO::FETCH_ASSOC) ?: [];
            $idCategoria = (int)($row['id_ai_categoria_empleado'] ?? 0);

            if ($idCategoria > 0) {
                $this->ejecutarConsultaConParametros(
                    "UPDATE categoria_empleado
                     SET descripcion = :descripcion,
                         std_reg = 1
                     WHERE id_ai_categoria_empleado = :id",
                    [
                        ':descripcion' => self::ROOT_CATEGORY_DESC,
                        ':id' => $idCategoria,
                    ]
                );

                return $idCategoria;
            }
        }

        $this->ejecutarConsultaConParametros(
            "INSERT INTO categoria_empleado (nombre_categoria, descripcion, std_reg)
             VALUES (:nombre, :descripcion, 1)",
            [
                ':nombre' => self::ROOT_CATEGORY_NAME,
                ':descripcion' => self::ROOT_CATEGORY_DESC,
            ]
        );

        $stmtId = $this->ejecutarConsultaConParametros(
            "SELECT id_ai_categoria_empleado
             FROM categoria_empleado
             WHERE nombre_categoria = :nombre
             ORDER BY id_ai_categoria_empleado DESC
             LIMIT 1",
            [':nombre' => self::ROOT_CATEGORY_NAME]
        );

        return (int)($stmtId ? $stmtId->fetchColumn() : 0);
    }

    private function cargarUsuarioAuthPorUsername(string $username): ?array
    {
        $stmt = $this->ejecutarConsultaConParametros(
            "SELECT
                " . $this->columnasTablaSql('user_system', 'u') . ",
                COALESCE(NULLIF(e.nombre_empleado, ''), u.id_empleado) AS nombre_empleado,
                COALESCE(c.nombre_categoria, 'SIN CATEGORIA') AS nombre_categoria,
                e.correo,
                " . $this->columnasTablaSql('roles_permisos', 'r') . "
             FROM user_system u
             LEFT JOIN empleado e
               ON e.id_empleado = u.id_empleado
             LEFT JOIN categoria_empleado c
               ON c.id_ai_categoria_empleado = e.id_ai_categoria_empleado
             LEFT JOIN roles_permisos r
               ON r.id = u.tipo
             WHERE u.username = :username
             LIMIT 1",
            [':username' => $username]
        );

        if (!$stmt || (int)$stmt->rowCount() !== 1) {
            return null;
        }

        return $stmt->fetch(\PDO::FETCH_ASSOC) ?: null;
    }

    private function cargarUsuarioAuthPorIdEmpleado(string $idEmpleado): ?array
    {
        $stmt = $this->ejecutarConsultaConParametros(
            "SELECT
                " . $this->columnasTablaSql('user_system', 'u') . ",
                COALESCE(NULLIF(e.nombre_empleado, ''), u.id_empleado) AS nombre_empleado,
                COALESCE(c.nombre_categoria, 'SIN CATEGORIA') AS nombre_categoria,
                e.correo,
                " . $this->columnasTablaSql('roles_permisos', 'r') . "
             FROM user_system u
             LEFT JOIN empleado e
               ON e.id_empleado = u.id_empleado
             LEFT JOIN categoria_empleado c
               ON c.id_ai_categoria_empleado = e.id_ai_categoria_empleado
             LEFT JOIN roles_permisos r
               ON r.id = u.tipo
             WHERE u.id_empleado = :id_empleado
             LIMIT 1",
            [':id_empleado' => $idEmpleado]
        );

        if (!$stmt || (int)$stmt->rowCount() !== 1) {
            return null;
        }

        return $stmt->fetch(\PDO::FETCH_ASSOC) ?: null;
    }

    private function inicializarSesionUsuario(array $row): void
    {
        if (!headers_sent() && session_status() === PHP_SESSION_ACTIVE) {
            session_regenerate_id(true);
        }

        $idEmpleado = trim((string)($row['id_empleado'] ?? ''));

        $_SESSION['id_user'] = $idEmpleado;
        $_SESSION['id'] = $idEmpleado;
        $_SESSION['user'] = $row['nombre_empleado'] ?? $idEmpleado;
        $_SESSION['username'] = $row['username'] ?? '';
        $_SESSION['tipo'] = (int)($row['tipo'] ?? 0);
        $_SESSION['categoria_empleado'] = $row['nombre_categoria'] ?? 'SIN CATEGORIA';

        $_SESSION['permisos'] = [];
        foreach ($row as $k => $v) {
            if (is_string($k) && strpos($k, 'perm_') === 0) {
                $_SESSION['permisos'][$k] = (int)$v;
            }
        }

        $_SESSION['rol_nombre'] = $row['nombre_rol'] ?? '';

        $this->setAppUser($idEmpleado);
    }

    public function registrarPrimerUsuarioRootControlador(): void
    {
        if (!ob_get_level()) {
            ob_start();
        }

        if (session_status() !== PHP_SESSION_ACTIVE) {
            session_start();
        }

        if (!$this->sistemaRequiereBootstrapControlador()) {
            $this->mostrarAlertaScript('info', 'Configuracion completada', 'El sistema ya tiene usuarios registrados. Inicia sesion normalmente.');
            return;
        }

        $nacionalidad = strtoupper($this->limpiarCadena($_POST['bootstrap_nacionalidad'] ?? 'V'));
        $idEmpleado = $this->limpiarCadena($_POST['bootstrap_id_empleado'] ?? '');
        $nombreEmpleado = $this->limpiarCadena($_POST['bootstrap_nombre_empleado'] ?? '');
        $telefono = $this->limpiarCadena($_POST['bootstrap_telefono'] ?? '');
        $correo = trim((string)($_POST['bootstrap_correo'] ?? ''));
        $direccion = $this->limpiarCadena($_POST['bootstrap_direccion'] ?? '');
        $clave1 = (string)($_POST['bootstrap_password'] ?? '');
        $clave2 = (string)($_POST['bootstrap_password_confirm'] ?? '');

        if (!in_array($nacionalidad, ['V', 'E'], true)) {
            $this->mostrarAlertaScript('error', 'Datos invalidos', 'Debes seleccionar una nacionalidad valida.');
            return;
        }

        if ($idEmpleado === '' || $nombreEmpleado === '' || $correo === '' || $clave1 === '' || $clave2 === '') {
            $this->mostrarAlertaScript('error', 'Datos incompletos', 'Debes completar los campos obligatorios para crear el usuario root.');
            return;
        }

        if ($this->verificarDatos('[a-zA-Z0-9-]{3,30}', $idEmpleado)) {
            $this->mostrarAlertaScript('error', 'Datos invalidos', 'La identificacion del empleado no cumple con el formato solicitado.');
            return;
        }

        if ($this->verificarDatos('[a-zA-ZáéíóúÁÉÍÓÚñÑ ]{3,100}', $nombreEmpleado)) {
            $this->mostrarAlertaScript('error', 'Datos invalidos', 'El nombre del empleado no cumple con el formato solicitado.');
            return;
        }

        if ($telefono !== '' && $this->verificarDatos('[0-9()+ -]{7,20}', $telefono)) {
            $this->mostrarAlertaScript('error', 'Datos invalidos', 'El telefono no cumple con el formato solicitado.');
            return;
        }

        if (!filter_var($correo, FILTER_VALIDATE_EMAIL)) {
            $this->mostrarAlertaScript('error', 'Datos invalidos', 'Debes indicar un correo electronico valido para la cuenta root.');
            return;
        }

        if ($clave1 !== $clave2) {
            $this->mostrarAlertaScript('error', 'Datos invalidos', 'Las claves no coinciden.');
            return;
        }

        $passwordLength = strlen($clave1);
        if ($passwordLength < 8 || $passwordLength > 100) {
            $this->mostrarAlertaScript('error', 'Datos invalidos', 'La clave root debe tener entre 8 y 100 caracteres.');
            return;
        }

        if (preg_match('/[\x00-\x1F\x7F]/', $clave1)) {
            $this->mostrarAlertaScript('error', 'Datos invalidos', 'La clave root contiene caracteres no permitidos.');
            return;
        }

        try {
            $this->beginTransaction();

            $usersCountStmt = $this->ejecutarConsultaConParametros(
                "SELECT COUNT(*) FROM user_system WHERE std_reg = 1"
            );
            $usersCount = (int)($usersCountStmt ? $usersCountStmt->fetchColumn() : 0);

            if ($usersCount > 0) {
                $this->rollBack();
                $this->mostrarAlertaScript('info', 'Configuracion completada', 'La configuracion inicial ya fue realizada.');
                return;
            }

            $this->asegurarRolRoot();
            $categoriaId = $this->asegurarCategoriaRoot();

            if ($categoriaId <= 0) {
                throw new \RuntimeException('No se pudo asegurar la categoria inicial del root.');
            }

            $stmtEmpleado = $this->ejecutarConsultaConParametros(
                "SELECT id_ai_empleado
                 FROM empleado
                 WHERE id_empleado = :id_empleado
                 LIMIT 1",
                [':id_empleado' => $idEmpleado]
            );

            if ($stmtEmpleado && $stmtEmpleado->rowCount() > 0) {
                $this->ejecutarConsultaConParametros(
                    "UPDATE empleado
                     SET nacionalidad = :nacionalidad,
                         nombre_empleado = :nombre_empleado,
                         telefono = :telefono,
                         direccion = :direccion,
                         correo = :correo,
                         id_ai_categoria_empleado = :categoria,
                         std_reg = 1
                     WHERE id_empleado = :id_empleado",
                    [
                        ':nacionalidad' => $nacionalidad,
                        ':nombre_empleado' => $nombreEmpleado,
                        ':telefono' => ($telefono !== '' ? $telefono : null),
                        ':direccion' => ($direccion !== '' ? $direccion : null),
                        ':correo' => $correo,
                        ':categoria' => $categoriaId,
                        ':id_empleado' => $idEmpleado,
                    ]
                );
            } else {
                $this->ejecutarConsultaConParametros(
                    "INSERT INTO empleado (
                        id_empleado,
                        nacionalidad,
                        nombre_empleado,
                        telefono,
                        direccion,
                        correo,
                        id_ai_categoria_empleado,
                        std_reg
                     ) VALUES (
                        :id_empleado,
                        :nacionalidad,
                        :nombre_empleado,
                        :telefono,
                        :direccion,
                        :correo,
                        :categoria,
                        1
                     )",
                    [
                        ':id_empleado' => $idEmpleado,
                        ':nacionalidad' => $nacionalidad,
                        ':nombre_empleado' => $nombreEmpleado,
                        ':telefono' => ($telefono !== '' ? $telefono : null),
                        ':direccion' => ($direccion !== '' ? $direccion : null),
                        ':correo' => $correo,
                        ':categoria' => $categoriaId,
                    ]
                );
            }

            $stmtUserByEmployee = $this->ejecutarConsultaConParametros(
                "SELECT id_ai_user, id_empleado, username
                 FROM user_system
                 WHERE id_empleado = :id_empleado
                 LIMIT 1",
                [':id_empleado' => $idEmpleado]
            );
            $userByEmployee = $stmtUserByEmployee && $stmtUserByEmployee->rowCount() > 0
                ? ($stmtUserByEmployee->fetch(\PDO::FETCH_ASSOC) ?: null)
                : null;

            $stmtUserByRoot = $this->ejecutarConsultaConParametros(
                "SELECT id_ai_user, id_empleado, username
                 FROM user_system
                 WHERE username = :username
                 LIMIT 1",
                [':username' => self::ROOT_USERNAME]
            );
            $userByRoot = $stmtUserByRoot && $stmtUserByRoot->rowCount() > 0
                ? ($stmtUserByRoot->fetch(\PDO::FETCH_ASSOC) ?: null)
                : null;

            if ($userByEmployee && $userByRoot && (int)$userByEmployee['id_ai_user'] !== (int)$userByRoot['id_ai_user']) {
                throw new \RuntimeException('Existe informacion previa inconsistente para la cuenta root. Revisa user_system antes de continuar.');
            }

            $targetUser = $userByEmployee ?: $userByRoot;
            $passwordHash = password_hash($clave1, PASSWORD_BCRYPT, ['cost' => 10]);

            if ($targetUser) {
                $this->ejecutarConsultaConParametros(
                    "UPDATE user_system
                     SET id_empleado = :id_empleado,
                         username = :username,
                         password = :password,
                         failed_login_attempts = 0,
                         account_locked = 0,
                         locked_at = NULL,
                         password_reset_required = 0,
                         last_login_at = NULL,
                         last_login_ip = NULL,
                         tipo = :tipo,
                         std_reg = 1
                     WHERE id_ai_user = :id_ai_user",
                    [
                        ':id_empleado' => $idEmpleado,
                        ':username' => self::ROOT_USERNAME,
                        ':password' => $passwordHash,
                        ':tipo' => self::ROOT_ROLE_ID,
                        ':id_ai_user' => (int)$targetUser['id_ai_user'],
                    ]
                );
            } else {
                $this->ejecutarConsultaConParametros(
                    "INSERT INTO user_system (
                        id_empleado,
                        username,
                        password,
                        failed_login_attempts,
                        account_locked,
                        locked_at,
                        password_reset_required,
                        last_login_at,
                        last_login_ip,
                        tipo,
                        std_reg
                     ) VALUES (
                        :id_empleado,
                        :username,
                        :password,
                        0,
                        0,
                        NULL,
                        0,
                        NULL,
                        NULL,
                        :tipo,
                        1
                     )",
                    [
                        ':id_empleado' => $idEmpleado,
                        ':username' => self::ROOT_USERNAME,
                        ':password' => $passwordHash,
                        ':tipo' => self::ROOT_ROLE_ID,
                    ]
                );
            }

            $this->commit();

            $row = $this->cargarUsuarioAuthPorIdEmpleado($idEmpleado);
            if (!$row) {
                throw new \RuntimeException('No se pudo recuperar la cuenta root recien creada.');
            }

            $this->inicializarSesionUsuario($row);
            $this->registrarEventoAuth(
                $idEmpleado,
                self::ROOT_USERNAME,
                'CONFIG_INICIAL_ROOT',
                'Se completo la configuracion inicial del sistema y se creo la cuenta root.',
                [
                    'rol' => self::ROOT_ROLE_NAME,
                    'categoria' => self::ROOT_CATEGORY_NAME,
                ]
            );

            $to = APP_URL . "dashboard/";
            if (!headers_sent()) {
                header("Location: " . $to);
                exit();
            }

            echo "<script>window.location.href='" . $to . "';</script>";
        } catch (\Throwable $e) {
            if ($this->inTransaction()) {
                $this->rollBack();
            }

            $this->registrarErrorSistema('Error en la configuracion inicial del sistema.', $e, [
                'id_empleado' => $idEmpleado,
                'username' => self::ROOT_USERNAME,
            ]);

            $this->mostrarAlertaScript('error', 'Configuracion inicial', 'No se pudo crear la cuenta root inicial. Revisa los datos e intenta nuevamente.');
        }
    }

    private function jsonResponse(bool $ok, string $msg, array $extra = []): string
    {
        return json_encode(array_merge([
            'ok' => $ok,
            'msg' => $msg,
        ], $extra), JSON_UNESCAPED_UNICODE);
    }

    private function escHtml(string $value): string
    {
        return htmlspecialchars($value, ENT_QUOTES, 'UTF-8');
    }

    private function resolveClientIp(): string
    {
        $keys = [
            'HTTP_CF_CONNECTING_IP',
            'HTTP_X_FORWARDED_FOR',
            'HTTP_X_REAL_IP',
            'REMOTE_ADDR',
        ];

        foreach ($keys as $key) {
            if (!isset($_SERVER[$key])) {
                continue;
            }

            $raw = trim((string) $_SERVER[$key]);
            if ($raw === '') {
                continue;
            }

            $parts = explode(',', $raw);
            $ip = trim((string) $parts[0]);

            if (filter_var($ip, FILTER_VALIDATE_IP)) {
                return $ip;
            }
        }

        return '0.0.0.0';
    }

    private function resolveUserAgent(): string
    {
        return substr(trim((string)($_SERVER['HTTP_USER_AGENT'] ?? '')), 0, 255);
    }

    private function normalizeChangedColumns(array $extra): ?string
    {
        $keys = array_keys($extra);
        $keys = array_values(array_filter($keys, static fn($key) => is_string($key) && $key !== ''));

        if ($keys === []) {
            return null;
        }

        return implode(',', $keys);
    }

    private function registrarEventoAuth(?string $idEmpleado, string $username, string $accion, string $detalle, array $extra = []): void
    {
        try {
            $idEmpleado = trim((string)($idEmpleado ?? ''));
            $username = trim($username);
            $ip = $this->resolveClientIp();
            $ua = $this->resolveUserAgent();

            $payload = array_merge([
                'username' => $username,
                'ip' => $ip,
                'user_agent' => $ua,
                'timestamp' => date('Y-m-d H:i:s'),
            ], $extra);

            $payloadJson = json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
            $pkJson = $idEmpleado !== '' ? json_encode(['id_empleado' => $idEmpleado], JSON_UNESCAPED_UNICODE) : null;
            $changedCols = $this->normalizeChangedColumns($extra);

            $this->ejecutarConsultaConParametros(
                "INSERT INTO `log_user` (
                    `event_uuid`,
                    `id_user`,
                    `tabla`,
                    `operacion`,
                    `pk_registro`,
                    `pk_json`,
                    `accion`,
                    `resp_system`,
                    `data_old`,
                    `data_new`,
                    `data_diff`,
                    `fecha_hora`,
                    `connection_id`,
                    `db_user`,
                    `db_host`,
                    `changed_cols`,
                    `std_reg`
                ) VALUES (
                    UUID(),
                    :id_user,
                    :tabla,
                    'UNKNOWN',
                    :pk_registro,
                    :pk_json,
                    :accion,
                    :resp_system,
                    NULL,
                    :data_new,
                    :data_diff,
                    NOW(),
                    CONNECTION_ID(),
                    SUBSTRING_INDEX(USER(),'@',1),
                    SUBSTRING_INDEX(USER(),'@',-1),
                    :changed_cols,
                    1
                )",
                [
                    ':id_user' => ($idEmpleado !== '' ? $idEmpleado : null),
                    ':tabla' => self::AUTH_LOG_TABLE,
                    ':pk_registro' => ($idEmpleado !== '' ? 'id_empleado=' . $idEmpleado : null),
                    ':pk_json' => $pkJson,
                    ':accion' => mb_substr($accion, 0, 150),
                    ':resp_system' => mb_substr($detalle, 0, 65535),
                    ':data_new' => $payloadJson !== false ? $payloadJson : null,
                    ':data_diff' => $payloadJson !== false ? $payloadJson : null,
                    ':changed_cols' => $changedCols,
                ]
            );
        } catch (\Throwable $e) {
            $this->registrarLogSistema('WARNING', 'auth.login', 'No se pudo registrar evento de autenticacion en log_user.', [
                'exception' => $e->getMessage(),
                'accion' => $accion,
                'username' => $username,
            ]);
        }
    }

    private function registrarErrorSistema(string $mensaje, \Throwable $e, array $context = []): void
    {
        $context['exception'] = $e->getMessage();
        $context['file'] = $e->getFile();
        $context['line'] = $e->getLine();
        $context['trace'] = mb_substr($e->getTraceAsString(), 0, 3000);

        $this->registrarLogSistema('ERROR', 'auth.login', $mensaje, $context);
    }

    private function generarClaveTemporal(int $length = 12): string
    {
        $alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789$@.-';
        $max = strlen($alphabet) - 1;
        $pass = '';

        for ($i = 0; $i < $length; $i++) {
            $pass .= $alphabet[random_int(0, $max)];
        }

        return $pass;
    }

    private function plantillaRecuperacionHtml(string $nombreEmpleado, string $nuevaClave): string
    {
        $logoUrl = defined('APP_MAIL_LOGO_URL')
            ? (string)APP_MAIL_LOGO_URL
            : (APP_URL . 'app/views/img/logo.png');

        $nombreEmpleado = $this->escHtml($nombreEmpleado);
        $nuevaClave = $this->escHtml($nuevaClave);
        $appName = $this->escHtml(APP_NAME);
        $loginUrl = $this->escHtml(APP_URL);

        return '<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Recuperacion de clave</title>
</head>
<body style="margin:0;padding:0;background:#f4f6fb;font-family:Segoe UI,Arial,sans-serif;color:#1f2937;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background:#f4f6fb;padding:24px 0;">
    <tr>
      <td align="center">
        <table width="640" cellpadding="0" cellspacing="0" style="max-width:640px;background:#ffffff;border-radius:12px;overflow:hidden;border:1px solid #e5e7eb;">
          <tr>
            <td style="background:#0f172a;padding:22px 24px;text-align:center;">
              <h1 style="margin:0;font-size:20px;line-height:1.3;color:#ffffff;">Recuperacion de acceso</h1>
              <p style="margin:8px 0 0 0;color:#cbd5e1;font-size:14px;">' . $appName . '</p>
            </td>
          </tr>
          <tr>
            <td style="padding:24px;">
              <p style="margin:0 0 14px 0;font-size:15px;">Hola <strong>' . $nombreEmpleado . '</strong>,</p>
              <p style="margin:0 0 14px 0;font-size:15px;">
                Recibimos una solicitud para restablecer tu clave de acceso. Te hemos generado una clave temporal:
              </p>
              <table width="100%" cellpadding="0" cellspacing="0" style="margin:16px 0;border:1px solid #e5e7eb;border-radius:10px;overflow:hidden;">
                <tr>
                  <td style="padding:12px 14px;background:#f9fafb;font-size:14px;"><strong>Nueva clave</strong></td>
                </tr>
                <tr>
                  <td style="padding:14px;background:#ffffff;">
                    <table width="100%" cellpadding="0" cellspacing="0" style="border-collapse:separate;border-spacing:0;">
                      <tr>
                        <td style="padding:12px 14px;border:1px solid #dbe2ea;border-right:0;border-radius:8px 0 0 8px;background:#f8fafc;font-family:Consolas,Monaco,monospace;font-size:16px;font-weight:700;letter-spacing:0.4px;">
                          <span data-clave="1">' . $nuevaClave . '</span>
                        </td>
                        <td style="width:148px;padding:0;">
                          <a href="' . $loginUrl . '"
                             style="display:block;padding:12px 14px;text-align:center;background:#0f766e;color:#ffffff;text-decoration:none;border-radius:0 8px 8px 0;font-size:13px;font-weight:700;">
                            Abrir sistema
                          </a>
                        </td>
                      </tr>
                    </table>
                    <p style="margin:10px 0 0 0;font-size:12px;color:#64748b;">
                      Selecciona la clave manualmente desde este correo y luego ingresa al sistema con el boton lateral.
                    </p>
                  </td>
                </tr>
              </table>
              <p style="margin:0 0 14px 0;font-size:14px;">
                Por seguridad, te recomendamos <strong>cambiar esta clave inmediatamente</strong> despues de iniciar sesion.
              </p>
              <p style="margin:0 0 14px 0;font-size:14px;color:#4b5563;">
                Si no solicitaste este cambio, notifica al administrador del sistema.
              </p>
            </td>
          </tr>
          <tr>
            <td style="background:#f9fafb;padding:14px 24px;font-size:12px;color:#6b7280;text-align:center;">
              Mensaje automatico. No respondas este correo.
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>';
    }

    private function plantillaRecuperacionTexto(string $nombreEmpleado, string $nuevaClave): string
    {
        return "Hola {$nombreEmpleado},\n\n"
            . "Se genero una nueva clave temporal para tu cuenta.\n\n"
            . "Nueva clave: {$nuevaClave}\n\n"
            . "Recomendacion: cambia esta clave inmediatamente despues de iniciar sesion.\n"
            . "Si no solicitaste este cambio, contacta al administrador.\n";
    }

    private function plantillaBloqueoHtml(string $nombreEmpleado, string $username): string
    {
        $logoUrl = defined('APP_MAIL_LOGO_URL')
            ? (string)APP_MAIL_LOGO_URL
            : (APP_URL . 'app/views/img/logo.png');

        $nombreEmpleado = $this->escHtml($nombreEmpleado);
        $username = $this->escHtml($username);
        $appName = $this->escHtml(APP_NAME);

        return '<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Cuenta bloqueada</title>
</head>
<body style="margin:0;padding:0;background:#f4f6fb;font-family:Segoe UI,Arial,sans-serif;color:#1f2937;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background:#f4f6fb;padding:24px 0;">
    <tr>
      <td align="center">
        <table width="640" cellpadding="0" cellspacing="0" style="max-width:640px;background:#ffffff;border-radius:12px;overflow:hidden;border:1px solid #e5e7eb;">
          <tr>
            <td style="background:#7f1d1d;padding:22px 24px;text-align:center;">
              <h1 style="margin:0;font-size:20px;line-height:1.3;color:#ffffff;">Cuenta bloqueada por seguridad</h1>
              <p style="margin:8px 0 0 0;color:#fecaca;font-size:14px;">' . $appName . '</p>
            </td>
          </tr>
          <tr>
            <td style="padding:24px;">
              <p style="margin:0 0 14px 0;font-size:15px;">Hola <strong>' . $nombreEmpleado . '</strong>,</p>
              <p style="margin:0 0 14px 0;font-size:15px;">
                Detectamos multiples intentos fallidos de inicio de sesion para tu cuenta <strong>' . $username . '</strong>.
              </p>
              <p style="margin:0 0 14px 0;font-size:15px;">
                Por proteccion, la cuenta fue bloqueada y ahora requiere <strong>recuperacion de clave</strong> desde la pantalla de acceso.
              </p>
              <p style="margin:0 0 14px 0;font-size:14px;color:#4b5563;">
                Si no fuiste tu, reportalo inmediatamente al administrador.
              </p>
            </td>
          </tr>
          <tr>
            <td style="background:#f9fafb;padding:14px 24px;font-size:12px;color:#6b7280;text-align:center;">
              Mensaje automatico de seguridad. No respondas este correo.
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>';
    }

    private function plantillaBloqueoTexto(string $nombreEmpleado, string $username): string
    {
        return "Hola {$nombreEmpleado},\n\n"
            . "Tu cuenta ({$username}) fue bloqueada por multiples intentos fallidos de inicio de sesion.\n"
            . "Para volver a entrar debes recuperar tu clave desde la pantalla de login.\n\n"
            . "Si no reconoces esta actividad, contacta al administrador.\n";
    }

    private function enviarCorreoBloqueo(string $correo, string $nombreEmpleado, string $username): void
    {
        $smtpCtrl = new smtpConfigController();
        $subject = 'Cuenta bloqueada por seguridad - ' . APP_NAME;
        $html = $this->plantillaBloqueoHtml($nombreEmpleado, $username);
        $text = $this->plantillaBloqueoTexto($nombreEmpleado, $username);

        $send = $smtpCtrl->enviarCorreoConfigurado($correo, $subject, $html, $text);
        if (empty($send['ok'])) {
            $this->registrarLogSistema('WARNING', 'auth.login', 'No se pudo enviar correo de bloqueo de cuenta.', [
                'username' => $username,
                'correo' => $correo,
                'smtp_msg' => trim((string)($send['msg'] ?? '')),
            ]);
        }
    }

    private function mostrarAlertaScript(string $icon, string $title, string $text): void
    {
        $icon = $this->escHtml($icon);
        $title = $this->escHtml($title);
        $text = $this->escHtml($text);

        echo "
            <script>
                Swal.fire({
                    icon: '{$icon}',
                    title: '{$title}',
                    text: '{$text}',
                    confirmButtonText: 'Aceptar'
                });
            </script>
        ";
    }

    public function recuperarClaveControlador(): string
    {
        $username = $this->limpiarCadena($_POST['username'] ?? '');

        if ($username === '') {
            return $this->jsonResponse(false, 'Debes indicar tu username.');
        }

        if ($this->verificarDatos('[a-zA-Z0-9]{4,20}', $username)) {
            return $this->jsonResponse(false, 'El username no cumple con el formato solicitado.');
        }

        $genericMsg = 'Si la cuenta existe y tiene correo registrado, enviaremos una clave temporal.';
        $pdo = null;

        try {
            $stmt = $this->ejecutarConsultaConParametros(
                "SELECT
                    u.id_ai_user,
                    u.id_empleado,
                    u.username,
                    u.std_reg AS user_std_reg,
                    COALESCE(NULLIF(e.nombre_empleado, ''), u.id_empleado) AS nombre_empleado,
                    e.correo,
                    e.std_reg AS empleado_std_reg
                 FROM user_system u
                 LEFT JOIN empleado e
                   ON e.id_empleado = u.id_empleado
                 WHERE u.username = :username
                 LIMIT 1",
                [':username' => $username]
            );

            if (!$stmt || (int)$stmt->rowCount() !== 1) {
                return $this->jsonResponse(true, $genericMsg);
            }

            $row = $stmt->fetch(\PDO::FETCH_ASSOC) ?: [];

            if ((int)($row['user_std_reg'] ?? 0) !== 1) {
                return $this->jsonResponse(true, $genericMsg);
            }

            if ((int)($row['empleado_std_reg'] ?? 0) !== 1) {
                return $this->jsonResponse(true, $genericMsg);
            }

            $correo = trim((string)($row['correo'] ?? ''));
            if ($correo === '' || filter_var($correo, FILTER_VALIDATE_EMAIL) === false) {
                return $this->jsonResponse(true, $genericMsg);
            }

            $idEmpleado = trim((string)($row['id_empleado'] ?? ''));
            $nombreEmpleado = trim((string)($row['nombre_empleado'] ?? ''));

            if ($idEmpleado === '') {
                return $this->jsonResponse(true, $genericMsg);
            }

            $nuevaClave = $this->generarClaveTemporal(12);
            $hash = password_hash($nuevaClave, PASSWORD_BCRYPT, ['cost' => 10]);

            $smtpCtrl = new smtpConfigController();
            $subject = 'Recuperacion de clave - ' . APP_NAME;
            $html = $this->plantillaRecuperacionHtml($nombreEmpleado, $nuevaClave);
            $text = $this->plantillaRecuperacionTexto($nombreEmpleado, $nuevaClave);

            $pdo = $this->conectar();
            $pdo->beginTransaction();

            $up = $pdo->prepare(
                "UPDATE user_system
                 SET password = :password,
                     failed_login_attempts = 0,
                     account_locked = 0,
                     locked_at = NULL,
                     password_reset_required = 0
                 WHERE id_empleado = :id
                   AND std_reg = 1"
            );
            $up->execute([
                ':password' => $hash,
                ':id' => $idEmpleado,
            ]);

            if ((int)$up->rowCount() !== 1) {
                $pdo->rollBack();
                return $this->jsonResponse(true, $genericMsg);
            }

            $send = $smtpCtrl->enviarCorreoConfigurado($correo, $subject, $html, $text);
            if (empty($send['ok'])) {
                $pdo->rollBack();
                $smtpMsg = trim((string)($send['msg'] ?? ''));
                if ($smtpMsg === '') {
                    $smtpMsg = 'No se pudo enviar el correo de recuperacion.';
                }
                return $this->jsonResponse(false, $smtpMsg);
            }

            $pdo->commit();

            $this->registrarEventoAuth(
                $idEmpleado,
                (string)($row['username'] ?? $username),
                'RECUPERACION_CLAVE',
                'Recuperacion de clave completada y cuenta desbloqueada.',
                ['password_reset_required' => 0, 'account_locked' => 0]
            );

            return $this->jsonResponse(true, 'Te enviamos una nueva clave temporal a tu correo registrado.');
        } catch (\Throwable $e) {
            if ($pdo instanceof \PDO && $pdo->inTransaction()) {
                $pdo->rollBack();
            }

            $this->registrarErrorSistema('Error en recuperacion de clave.', $e, [
                'username' => $username,
            ]);

            return $this->jsonResponse(false, 'No fue posible procesar la recuperacion de clave.');
        }
    }

    public function iniciarSesionControlador(): void
    {
        if (!ob_get_level()) {
            ob_start();
        }

        if (session_status() !== PHP_SESSION_ACTIVE) {
            session_start();
        }

        $username = $this->limpiarCadena($_POST['username'] ?? '');
        $password = (string)($_POST['password'] ?? '');

        if ($username === '' || $password === '') {
            $this->mostrarAlertaScript('error', 'Ocurrio un error inesperado', 'No has llenado todos los campos obligatorios.');
            return;
        }

        if ($this->verificarDatos('[a-zA-Z0-9]{4,20}', $username)) {
            $this->mostrarAlertaScript('error', 'Ocurrio un error inesperado', 'El USERNAME no cumple con el formato solicitado.');
            return;
        }

        $passwordLength = strlen($password);
        if ($passwordLength < 7 || $passwordLength > 100) {
            $this->mostrarAlertaScript('error', 'Ocurrio un error inesperado', 'La CLAVE debe tener entre 7 y 100 caracteres.');
            return;
        }

        if (preg_match('/[\x00-\x1F\x7F]/', $password)) {
            $this->mostrarAlertaScript('error', 'Ocurrio un error inesperado', 'La CLAVE contiene caracteres no permitidos.');
            return;
        }

        try {
            $row = $this->cargarUsuarioAuthPorUsername($username);

            if (!$row) {
                $this->ejecutarProcedimientoFila(
                    "CALL sp_usuario_registrar_login_fallido(:username, :ip)",
                    [
                        ':username' => $username,
                        ':ip' => $this->resolveClientIp(),
                    ]
                );
                $this->registrarEventoAuth(null, $username, 'LOGIN_INTENTO_FALLIDO', 'Intento fallido: username inexistente.');
                $this->mostrarAlertaScript('error', 'Ocurrio un error inesperado', 'Username o clave incorrectos.');
                return;
            }

            $idEmpleado = trim((string)($row['id_empleado'] ?? ''));
            $correo = trim((string)($row['correo'] ?? ''));

            if ((int)($row['std_reg'] ?? 0) !== 1) {
                $this->registrarEventoAuth($idEmpleado, $username, 'LOGIN_DENEGADO', 'Acceso denegado: cuenta inactiva o eliminada.');
                $this->mostrarAlertaScript('warning', 'Acceso denegado', 'Su cuenta esta inactiva o eliminada.');
                return;
            }

            $isLocked = (int)($row['account_locked'] ?? 0) === 1;
            $requiresReset = (int)($row['password_reset_required'] ?? 0) === 1;
            if ($isLocked || $requiresReset) {
                $this->registrarEventoAuth($idEmpleado, $username, 'SESION_BLOQUEADA', 'Intento de acceso a cuenta bloqueada. Debe recuperar clave.');
                $this->mostrarAlertaScript(
                    'warning',
                    'Cuenta bloqueada',
                    'Tu cuenta esta bloqueada por seguridad. Debes recuperar tu clave para volver a iniciar sesion.'
                );
                return;
            }

            if (!password_verify($password, (string)($row['password'] ?? ''))) {
                $falloLogin = $this->ejecutarProcedimientoFila(
                    "CALL sp_usuario_registrar_login_fallido(:username, :ip)",
                    [
                        ':username' => $username,
                        ':ip' => $this->resolveClientIp(),
                    ]
                ) ?? [];

                $attempts = (int)($falloLogin['failed_login_attempts'] ?? ((int)($row['failed_login_attempts'] ?? 0) + 1));
                $remaining = max(0, self::MAX_FAILED_ATTEMPTS - $attempts);

                if ($attempts >= self::MAX_FAILED_ATTEMPTS) {
                    $this->registrarEventoAuth(
                        $idEmpleado,
                        $username,
                        'LOGIN_BLOQUEADO',
                        'Cuenta bloqueada por exceder intentos fallidos de inicio de sesion.',
                        [
                            'failed_login_attempts' => $attempts,
                            'account_locked' => 1,
                            'password_reset_required' => 1,
                        ]
                    );

                    if ($correo !== '' && filter_var($correo, FILTER_VALIDATE_EMAIL) !== false) {
                        $this->enviarCorreoBloqueo(
                            $correo,
                            trim((string)($row['nombre_empleado'] ?? $idEmpleado)),
                            $username
                        );
                    }

                    $this->mostrarAlertaScript(
                        'error',
                        'Cuenta bloqueada',
                        'Superaste el maximo de intentos permitidos. Tu cuenta fue bloqueada y debes recuperar tu clave.'
                    );
                    return;
                }

                $this->registrarEventoAuth(
                    $idEmpleado,
                    $username,
                    'LOGIN_INTENTO_FALLIDO',
                    'Clave incorrecta en inicio de sesion.',
                    [
                        'failed_login_attempts' => $attempts,
                        'remaining_attempts' => $remaining,
                    ]
                );

                $msg = 'Clave incorrecta.';
                if ($remaining > 0) {
                    $msg .= ' Te quedan ' . $remaining . ' intento(s) antes del bloqueo.';
                }
                $this->mostrarAlertaScript('error', 'Advertencia', $msg);
                return;
            }

            $this->inicializarSesionUsuario($row);

            $this->ejecutarProcedimientoFila(
                "CALL sp_usuario_registrar_login_exitoso(:id_empleado, :ip)",
                [
                    ':id_empleado' => $idEmpleado,
                    ':ip' => $this->resolveClientIp(),
                ]
            );

            $this->registrarEventoAuth(
                $idEmpleado,
                $username,
                'LOGIN_EXITOSO',
                'Inicio de sesion exitoso.',
                [
                    'rol' => (string)($row['nombre_rol'] ?? ''),
                    'tipo' => (int)($row['tipo'] ?? 0),
                ]
            );

            $to = APP_URL . "dashboard/";
            if (!headers_sent()) {
                header("Location: " . $to);
                exit();
            }

            echo "<script>window.location.href='" . $to . "';</script>";
            return;
        } catch (\Throwable $e) {
            $this->registrarErrorSistema('Error interno durante inicio de sesion.', $e, [
                'username' => $username,
                'ip' => $this->resolveClientIp(),
            ]);

            $this->mostrarAlertaScript('error', 'Error interno', 'No se pudo procesar el inicio de sesion. Intenta de nuevo.');
        }
    }

    public function cerrarSesionControlador(): void
    {
        if (session_status() !== PHP_SESSION_ACTIVE) {
            session_start();
        }

        $idEmpleado = trim((string)($_SESSION['id_user'] ?? ($_SESSION['id'] ?? '')));
        $username = trim((string)($_SESSION['username'] ?? ''));

        if ($idEmpleado !== '' || $username !== '') {
            $this->registrarEventoAuth(
                ($idEmpleado !== '' ? $idEmpleado : null),
                $username,
                'LOGOUT_EXITOSO',
                'Cierre de sesion ejecutado por el usuario.'
            );
        }

        $canSendHeaders = !headers_sent();

        $_SESSION = [];
        if ($canSendHeaders && ini_get("session.use_cookies")) {
            $params = session_get_cookie_params();
            setcookie(
                session_name(),
                '',
                time() - 42000,
                $params["path"],
                $params["domain"],
                $params["secure"],
                $params["httponly"]
            );
        }
        session_destroy();

        $to = APP_URL . "login/";

        if ($canSendHeaders) {
            header("Location: " . $to);
            exit();
        }

        echo "<script>window.location.href='" . $to . "';</script>";
    }
}

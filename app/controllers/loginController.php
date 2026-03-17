<?php

namespace app\controllers;

use app\models\mainModel;

class loginController extends mainModel
{
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
              <img src="' . $this->escHtml($logoUrl) . '" alt="Logo" style="width:92px;height:92px;object-fit:contain;display:block;margin:0 auto 12px auto;">
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
                  <td style="padding:12px 14px;background:#ffffff;font-size:14px;"><code style="font-size:15px;background:#eef2ff;padding:4px 8px;border-radius:6px;">' . $nuevaClave . '</code></td>
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
            $stmt = $this->ejecutarConsultaParams(
                "SELECT
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
                 SET password = :password
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
            return $this->jsonResponse(true, 'Te enviamos una nueva clave temporal a tu correo registrado.');
        } catch (\Throwable $e) {
            if ($pdo instanceof \PDO && $pdo->inTransaction()) {
                $pdo->rollBack();
            }

            return $this->jsonResponse(false, 'No fue posible procesar la recuperacion de clave.');
        }
    }

    public function iniciarSesionControlador()
    {
        // Blindaje: buffer activo por si este controlador se llama “tarde”
        if (!ob_get_level()) {
            ob_start();
        }

        // Asegura sesión activa
        if (session_status() !== PHP_SESSION_ACTIVE) {
            session_start();
        }

        $username = $this->limpiarCadena($_POST['username'] ?? '');
        $password = (string)($_POST['password'] ?? ''); // NO limpiarCadena()

        if ($username === "" || $password === "") {
            echo "
                <script>
                    Swal.fire({
                        icon: 'error',
                        title: 'Ocurrió un error inesperado',
                        text: 'No has llenado todos los campos que son obligatorios',
                        confirmButtonText: 'Aceptar'
                    });
                </script>
            ";
            return;
        }

        if ($this->verificarDatos('[a-zA-Z0-9]{4,20}', $username)) {
            echo "
                <script>
                    Swal.fire({
                        icon: 'error',
                        title: 'Ocurrió un error inesperado',
                        text: 'El USERNAME no cumple con el formato solicitado',
                        confirmButtonText: 'Aceptar'
                    });
                </script>
            ";
            return;
        }

        // Si quieres mantener validación de formato:
        if ($this->verificarDatos('[a-zA-Z0-9$@.-]{7,100}', $password)) {
            echo "
                <script>
                    Swal.fire({
                        icon: 'error',
                        title: 'Ocurrió un error inesperado',
                        text: 'La CLAVE no cumple con el formato solicitado',
                        confirmButtonText: 'Aceptar'
                    });
                </script>
            ";
            return;
        }

        $stmt = $this->ejecutarConsultaParams(
            "SELECT
                " . $this->columnasTablaSql('user_system', 'u') . ",
                COALESCE(NULLIF(e.nombre_empleado, ''), u.id_empleado) AS nombre_empleado,
                COALESCE(c.nombre_categoria, 'SIN CATEGORIA') AS nombre_categoria,
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

        if (!$stmt || $stmt->rowCount() !== 1) {
            echo "
                <script>
                    Swal.fire({
                        icon: 'error',
                        title: 'Ocurrió un error inesperado',
                        text: 'Username o Clave incorrectos',
                        confirmButtonText: 'Aceptar'
                    });
                </script>
            ";
            return;
        }

        $row = $stmt->fetch(\PDO::FETCH_ASSOC);

        if (!password_verify($password, $row['password'])) {
            echo "
                <script>
                    Swal.fire({
                        icon: 'error',
                        title: 'Ocurrió un error inesperado',
                        text: 'Clave incorrecta',
                        confirmButtonText: 'Aceptar'
                    });
                </script>
            ";
            return;
        }

        if ((int)$row['std_reg'] !== 1) {
            echo "
                <script>
                    Swal.fire({
                        icon: 'warning',
                        title: 'Acceso denegado',
                        text: 'Su cuenta ha sido eliminada',
                        confirmButtonText: 'Aceptar'
                    });
                </script>
            ";
            return;
        }

        // ✅ REGENERAR SOLO SI AÚN SE PUEDEN ENVIAR HEADERS
        // (esto elimina el warning incluso si algo ya imprimió salida)
        if (!headers_sent() && session_status() === PHP_SESSION_ACTIVE) {
            session_regenerate_id(true);
        }

        // Guardar sesión
        $sessionEmpleadoId = (string)($row['id_empleado'] ?? '');

        $_SESSION['id_user']  = $sessionEmpleadoId;
        $_SESSION['id']       = $sessionEmpleadoId; // compat
        $_SESSION['user']     = $row['nombre_empleado'];
        $_SESSION['username'] = $row['username'];
        $_SESSION['tipo']     = (int)$row['tipo'];
        $_SESSION['categoria_empleado'] = $row['nombre_categoria'] ?? 'SIN CATEGORIA';

        $_SESSION['permisos'] = [];
        foreach ($row as $k => $v) {
            if (is_string($k) && strpos($k, 'perm_') === 0) {
                $_SESSION['permisos'][$k] = (int)$v;
            }
        }
        $_SESSION['rol_nombre'] = $row['nombre_rol'] ?? '';

        // Contexto auditoría
        $this->setAppUser((string)$_SESSION['id_user']);

        // Redirección (si ya hay salida, usa JS)
        $to = APP_URL . "dashboard/";

        if (!headers_sent()) {
            header("Location: " . $to);
            exit();
        }

        echo "<script>window.location.href='" . $to . "';</script>";
        return;
    }

    public function cerrarSesionControlador()
    {
        if (session_status() !== PHP_SESSION_ACTIVE) {
            session_start();
        }

        $canSendHeaders = !headers_sent();

        // Limpieza segura
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
        return;
    }
}

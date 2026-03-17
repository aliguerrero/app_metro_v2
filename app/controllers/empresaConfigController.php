<?php

namespace app\controllers;

use app\models\mainModel;

class empresaConfigController extends mainModel
{
    private function getAppRootPath(): string
    {
        $root = realpath(APP_ROOT);
        if ($root === false || $root === '') {
            $root = dirname(__DIR__, 2);
        }

        return rtrim($root, "\\/");
    }

    private function normalizeLogoPath(string $logoPath): string
    {
        $path = trim($logoPath);
        if ($path === '') {
            return '';
        }

        if (preg_match('#^https?://#i', $path)) {
            $urlPath = (string)parse_url($path, PHP_URL_PATH);
            if ($urlPath !== '') {
                $path = $urlPath;
            }
        }

        $path = str_replace("\\", "/", $path);
        $path = ltrim($path, "/");

        $basePath = trim((string)parse_url(APP_URL, PHP_URL_PATH), "/");
        if ($basePath !== '' && strpos($path, $basePath . '/') === 0) {
            $path = substr($path, strlen($basePath) + 1);
        }

        return $path;
    }

    public function obtenerEmpresaControlador()
    {
        // validar sesión como tu sistema
        if (!isset($_SESSION['id'])) {
            return json_encode([
                "tipo" => "simple",
                "titulo" => "Sesión inválida",
                "texto" => "Debes iniciar sesión nuevamente.",
                "icono" => "error"
            ]);
        }

        try {
            $st = $this->ejecutarConsulta("SELECT " . $this->columnasTablaSql('empresa_config') . " FROM empresa_config WHERE id = 1 LIMIT 1");

            if ($st && $st->rowCount() === 1) {
                $empresa = $st->fetch(\PDO::FETCH_ASSOC);

                // Depuración: muestra la respuesta antes de enviarla
                error_log(json_encode(["ok" => true, "data" => $empresa]));

                // Para cargar la vista, devolvemos data
                return json_encode([
                    "ok" => true,
                    "data" => $empresa
                ]);
            }

            return json_encode([
                "tipo" => "simple",
                "titulo" => "Sin configuración",
                "texto" => "No existe el registro de empresa_config (id=1).",
                "icono" => "warning"
            ]);
        } catch (\Exception $e) {
            return json_encode([
                "tipo" => "simple",
                "titulo" => "Error",
                "texto" => "No se pudo cargar la información de la empresa.",
                "icono" => "error"
            ]);
        }
    }

    public function actualizarEmpresaControlador()
    {
        if (!isset($_SESSION['id'])) {
            return json_encode([
                "tipo" => "simple",
                "titulo" => "Sesión inválida",
                "texto" => "Debes iniciar sesión nuevamente.",
                "icono" => "error"
            ]);
        }

        $nombre    = $this->limpiarCadena($_POST['nombre'] ?? '');
        $rif       = $this->limpiarCadena($_POST['rif'] ?? '');
        $direccion = $this->limpiarCadena($_POST['direccion'] ?? '');
        $telefono  = $this->limpiarCadena($_POST['telefono'] ?? '');
        $email     = $this->limpiarCadena($_POST['email'] ?? '');

        if ($nombre === "") {
            return json_encode([
                "tipo" => "simple",
                "titulo" => "Campos obligatorios",
                "texto" => "El nombre de la empresa es obligatorio.",
                "icono" => "error"
            ]);
        }

        $datos = [
            ["campo_nombre" => "nombre",    "campo_marcador" => ":nombre",    "campo_valor" => $nombre],
            ["campo_nombre" => "rif",       "campo_marcador" => ":rif",       "campo_valor" => $rif],
            ["campo_nombre" => "direccion", "campo_marcador" => ":direccion", "campo_valor" => $direccion],
            ["campo_nombre" => "telefono",  "campo_marcador" => ":telefono",  "campo_valor" => $telefono],
            ["campo_nombre" => "email",     "campo_marcador" => ":email",     "campo_valor" => $email],
        ];

        // ==========================
        // LOGO (opcional)
        // - si NO llega: se mantiene
        // - si llega: borra anterior y mueve el nuevo
        // ==========================
        if (!empty($_FILES['logo_file']['name'])) {

            // Validar error de subida
            $upErr = $_FILES['logo_file']['error'] ?? UPLOAD_ERR_NO_FILE;
            if ($upErr !== UPLOAD_ERR_OK) {
                return json_encode([
                    "tipo" => "simple",
                    "titulo" => "Logo",
                    "texto" => "Error al subir el archivo (código: {$upErr}).",
                    "icono" => "error"
                ]);
            }

            // 1) Buscar logo actual en BD (para borrarlo)
            $logoActual = "";
            try {
                $stLogo = $this->ejecutarConsulta("SELECT logo FROM empresa_config WHERE id = 1 LIMIT 1");
                if ($stLogo && $stLogo->rowCount() === 1) {
                    $rowLogo = $stLogo->fetch(\PDO::FETCH_ASSOC);
                    $logoActual = $rowLogo['logo'] ?? "";
                }
            } catch (\Exception $e) {
                // seguimos igual (no imprimimos nada)
            }

            // 2) Rutas correctas (ABS para filesystem, REL para BD)
            $root = $this->getAppRootPath(); // .../app_metro
            $dirRel = "app/views/img/empresa/";
            $dirAbs = $root . DIRECTORY_SEPARATOR . str_replace("/", DIRECTORY_SEPARATOR, trim($dirRel, "/"));

            // Asegurar separador final
            if (substr($dirAbs, -1) !== DIRECTORY_SEPARATOR) {
                $dirAbs .= DIRECTORY_SEPARATOR;
            }

            // 3) Crear carpeta si no existe
            if (!is_dir($dirAbs)) {
                if (!@mkdir($dirAbs, 0777, true)) {
                    return json_encode([
                        "tipo" => "simple",
                        "titulo" => "Carpeta",
                        "texto" => "No se pudo crear la carpeta del logo.",
                        "icono" => "error"
                    ]);
                }
            }

            // 4) Validar extensión
            $ext = strtolower(pathinfo($_FILES['logo_file']['name'], PATHINFO_EXTENSION));
            $permitidas = ["png", "jpg", "jpeg", "webp"];
            if (!in_array($ext, $permitidas, true)) {
                return json_encode([
                    "tipo" => "simple",
                    "titulo" => "Logo",
                    "texto" => "Formato no permitido. Usa PNG/JPG/JPEG/WEBP.",
                    "icono" => "error"
                ]);
            }

            // 5) Borrar logo anterior (ruta real)
            if ($logoActual !== "") {
                $oldRel = $this->normalizeLogoPath($logoActual);
                if ($oldRel !== '' && strpos($oldRel, "app/views/img/") === 0) {
                    $oldAbs = $root . DIRECTORY_SEPARATOR . str_replace("/", DIRECTORY_SEPARATOR, $oldRel);
                    if (is_file($oldAbs)) {
                        @unlink($oldAbs);
                    }
                }
            }

            // 5.1) Limpieza extra por si cambiaste de extensión (logo_empresa.png/jpg/etc)
            foreach (glob($dirAbs . "logo_empresa.*") as $f) {
                if (is_file($f)) @unlink($f);
            }

            // 6) Mover el nuevo logo
            $tmp = $_FILES['logo_file']['tmp_name'];
            if (!is_uploaded_file($tmp)) {
                return json_encode([
                    "tipo" => "simple",
                    "titulo" => "Logo",
                    "texto" => "El archivo temporal no es válido.",
                    "icono" => "error"
                ]);
            }

            $nombreLogo = "logo_empresa." . $ext;
            $rutaFinalAbs = $dirAbs . $nombreLogo;

            $ok = @move_uploaded_file($tmp, $rutaFinalAbs);
            if (!$ok) {
                // fallback por si move falla (permisos/config)
                $ok = @copy($tmp, $rutaFinalAbs);
            }

            if (!$ok || !is_file($rutaFinalAbs)) {
                return json_encode([
                    "tipo" => "simple",
                    "titulo" => "Logo",
                    "texto" => "No se pudo guardar el logo en la carpeta destino.",
                    "icono" => "error"
                ]);
            }

            // 7) Guardar ruta en BD (relativa)
            $datos[] = [
                "campo_nombre" => "logo",
                "campo_marcador" => ":logo",
                "campo_valor" => $dirRel . $nombreLogo
            ];
        }

        $condicion = [
            "condicion_campo" => "id",
            "condicion_marcador" => ":id",
            "condicion_valor" => 1
        ];

        try {
            if ($this->actualizarDatos("empresa_config", $datos, $condicion)) {
                return json_encode([
                    "tipo" => "recargar",
                    "titulo" => "Actualizado",
                    "texto" => "Datos de la empresa actualizados correctamente.",
                    "icono" => "success"
                ]);
            }

            return json_encode([
                "tipo" => "simple",
                "titulo" => "Error",
                "texto" => "No se pudieron guardar los cambios.",
                "icono" => "error"
            ]);
        } catch (\Exception $e) {
            return json_encode([
                "tipo" => "simple",
                "titulo" => "Error",
                "texto" => "Ocurrió un error al guardar la configuración.",
                "icono" => "error"
            ]);
        }
    }
}

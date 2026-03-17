<?php

namespace app\controllers;

use app\models\mainModel;
use RuntimeException;

class reporteGeneradoController extends mainModel
{
    private string $storageBaseDir;
    private string $storageBaseRelative;

    public function __construct()
    {
        $this->storageBaseRelative = 'storage/reportes_generados';
        $this->storageBaseDir = rtrim(APP_ROOT, '\\/') . DIRECTORY_SEPARATOR . 'storage' . DIRECTORY_SEPARATOR . 'reportes_generados';
    }

    private function tablaDisponible(): bool
    {
        return $this->tableHasColumn('reporte_generado', 'id_ai_reporte_generado');
    }

    private function asegurarDirectorio(string $subdir = ''): string
    {
        $path = $this->storageBaseDir;
        if ($subdir !== '') {
            $path .= DIRECTORY_SEPARATOR . str_replace(['/', '\\'], DIRECTORY_SEPARATOR, trim($subdir, "\\/"));
        }

        if (!is_dir($path) && !mkdir($path, 0775, true) && !is_dir($path)) {
            throw new RuntimeException('No se pudo crear el directorio de reportes generados.');
        }

        return $path;
    }

    private function slug(string $text): string
    {
        $value = trim($text);
        $ascii = @iconv('UTF-8', 'ASCII//TRANSLIT//IGNORE', $value);
        if (is_string($ascii) && $ascii !== '') {
            $value = $ascii;
        }

        $value = strtolower($value);
        $value = preg_replace('/[^a-z0-9]+/', '_', $value) ?? '';
        $value = trim($value, '_');

        return $value !== '' ? $value : 'reporte';
    }

    private function tituloPorTipo(string $tipoReporte): string
    {
        return match ($tipoReporte) {
            'ot_resumen' => 'Reporte OT Resumen',
            'ot_detallado' => 'Reporte OT Detallado',
            'herramientas' => 'Reporte de Herramientas',
            'miembros' => 'Reporte de Miembros',
            'usuarios' => 'Reporte de Usuarios',
            default => 'Reporte Generado',
        };
    }

    private function descripcionTipo(string $tipoReporte): string
    {
        return match ($tipoReporte) {
            'ot_resumen' => 'OT Resumen',
            'ot_detallado' => 'OT Detallado',
            'herramientas' => 'Herramientas',
            'miembros' => 'Miembros',
            'usuarios' => 'Usuarios',
            default => $tipoReporte,
        };
    }

    private function bytesHumanos(int $bytes): string
    {
        if ($bytes <= 0) {
            return '0 B';
        }

        $units = ['B', 'KB', 'MB', 'GB'];
        $size = (float)$bytes;
        $unit = 0;

        while ($size >= 1024 && $unit < count($units) - 1) {
            $size /= 1024;
            $unit++;
        }

        return number_format($size, $unit === 0 ? 0 : 2, '.', ',') . ' ' . $units[$unit];
    }

    private function esc(string $text): string
    {
        return htmlspecialchars($text, ENT_QUOTES, 'UTF-8');
    }

    public function guardarReporteGenerado(
        string $tipoReporte,
        array $parametros,
        string $pdfBinary,
        ?string $tituloReporte = null,
        ?string $nombreArchivo = null
    ): array {
        if (!$this->tablaDisponible()) {
            throw new RuntimeException('La tabla reporte_generado no existe.');
        }

        $tituloReporte = trim((string)$tituloReporte);
        if ($tituloReporte === '') {
            $tituloReporte = $this->tituloPorTipo($tipoReporte);
        }

        $subdir = date('Y') . DIRECTORY_SEPARATOR . date('m');
        $dir = $this->asegurarDirectorio($subdir);

        $safeBase = $this->slug($tituloReporte . '_' . $tipoReporte);
        $storedFile = $safeBase . '_' . date('Ymd_His') . '_' . substr(bin2hex(random_bytes(4)), 0, 8) . '.pdf';
        $fullPath = $dir . DIRECTORY_SEPARATOR . $storedFile;

        if (file_put_contents($fullPath, $pdfBinary) === false) {
            throw new RuntimeException('No se pudo guardar el archivo PDF generado.');
        }

        $relativePath = $this->storageBaseRelative . '/' . str_replace('\\', '/', $subdir) . '/' . $storedFile;
        $displayName = trim((string)$nombreArchivo);
        if ($displayName === '') {
            $displayName = $storedFile;
        }

        $idUser = (string)($_SESSION['id_user'] ?? ($_SESSION['id'] ?? ''));
        $nombreUser = (string)($_SESSION['user'] ?? '');
        $username = (string)($_SESSION['username'] ?? '');

        $stmt = $this->ejecutarConsultaConParametros(
            "INSERT INTO reporte_generado (
                tipo_reporte,
                titulo_reporte,
                nombre_archivo,
                ruta_archivo,
                mime_type,
                tamano_bytes,
                parametros_json,
                id_user_generador,
                nombre_user_generador,
                username_generador,
                std_reg
            ) VALUES (
                :tipo_reporte,
                :titulo_reporte,
                :nombre_archivo,
                :ruta_archivo,
                :mime_type,
                :tamano_bytes,
                :parametros_json,
                :id_user_generador,
                :nombre_user_generador,
                :username_generador,
                1
            )",
            [
                ':tipo_reporte' => $tipoReporte,
                ':titulo_reporte' => $tituloReporte,
                ':nombre_archivo' => $displayName,
                ':ruta_archivo' => $relativePath,
                ':mime_type' => 'application/pdf',
                ':tamano_bytes' => strlen($pdfBinary),
                ':parametros_json' => json_encode($parametros, JSON_UNESCAPED_UNICODE),
                ':id_user_generador' => $idUser,
                ':nombre_user_generador' => $nombreUser,
                ':username_generador' => $username,
            ]
        );

        if (!$stmt) {
            @unlink($fullPath);
            throw new RuntimeException('No se pudo registrar el reporte generado en la base de datos.');
        }

        return [
            'tipo_reporte' => $tipoReporte,
            'titulo_reporte' => $tituloReporte,
            'nombre_archivo' => $displayName,
            'ruta_archivo' => $relativePath,
            'tamano_bytes' => strlen($pdfBinary),
        ];
    }

    public function listarReportesGeneradosHtml(): string
    {
        if (!$this->tablaDisponible()) {
            return '
                <div class="alert alert-warning m-3 mb-0">
                    La tabla <b>reporte_generado</b> no existe todavia. Ejecuta la migracion del modulo de reportes.
                </div>';
        }

        $stmt = $this->ejecutarConsultaConParametros(
            "SELECT
                id_ai_reporte_generado,
                tipo_reporte,
                titulo_reporte,
                nombre_archivo,
                ruta_archivo,
                mime_type,
                tamano_bytes,
                parametros_json,
                id_user_generador,
                nombre_user_generador,
                username_generador,
                created_at,
                std_reg
             FROM reporte_generado
             WHERE std_reg = 1
             ORDER BY created_at DESC, id_ai_reporte_generado DESC
             LIMIT 200"
        );

        $rows = $stmt ? $stmt->fetchAll(\PDO::FETCH_ASSOC) : [];
        $total = count($rows);

        $html = '
        <div class="report-generated-responsive p-3">
            <div class="d-none d-md-block">
                <div class="table-responsive table-wrapper3" style="max-height:70vh; overflow-y:auto;">
                    <table class="table border mb-0 table-hover table-sm table-striped">
                        <thead class="table-light fw-semibold">
                            <tr class="align-middle">
                                <th>#</th>
                                <th>Fecha</th>
                                <th>Tipo</th>
                                <th>Titulo</th>
                                <th>Archivo</th>
                                <th>Generado por</th>
                                <th>Tamano</th>
                                <th class="text-center" colspan="2">Acciones</th>
                            </tr>
                        </thead>
                        <tbody>';

        $cards = '
            <div class="d-md-none">
                <div class="tool-cards" id="toolCardsReportesGenerados">';

        if ($total > 0) {
            $contador = 1;

            foreach ($rows as $row) {
                $id = (int)$row['id_ai_reporte_generado'];
                $fecha = $row['created_at'] ? date('d/m/Y H:i', strtotime((string)$row['created_at'])) : '-';
                $tipo = $this->descripcionTipo((string)$row['tipo_reporte']);
                $titulo = (string)$row['titulo_reporte'];
                $archivo = (string)$row['nombre_archivo'];
                $usuario = trim((string)$row['nombre_user_generador']);
                $username = trim((string)$row['username_generador']);
                $idUser = trim((string)$row['id_user_generador']);
                $tamano = $this->bytesHumanos((int)$row['tamano_bytes']);
                $viewUrl = APP_URL . 'app/controllers/reporteGeneradoFile.php?action=view&id=' . $id;
                $downloadUrl = APP_URL . 'app/controllers/reporteGeneradoFile.php?action=download&id=' . $id;

                $usuarioLabel = $usuario !== '' ? $usuario : 'Usuario';
                if ($username !== '') {
                    $usuarioLabel .= ' (@' . $username . ')';
                }
                if ($idUser !== '') {
                    $usuarioLabel .= ' [' . $idUser . ']';
                }

                $html .= '
                    <tr class="align-middle">
                        <td><b>' . $contador . '</b></td>
                        <td><b>' . $this->esc($fecha) . '</b></td>
                        <td>' . $this->esc($tipo) . '</td>
                        <td><b>' . $this->esc($titulo) . '</b></td>
                        <td>' . $this->esc($archivo) . '</td>
                        <td>' . $this->esc($usuarioLabel) . '</td>
                        <td>' . $this->esc($tamano) . '</td>
                        <td class="text-center col-p">
                            <a class="btn btn-info btn-sm text-white" href="' . $this->esc($viewUrl) . '" target="_blank" rel="noopener" title="Visualizar">
                                <i class="bi bi-eye"></i>
                            </a>
                        </td>
                        <td class="text-center col-p">
                            <a class="btn btn-danger btn-sm" href="' . $this->esc($downloadUrl) . '" target="_blank" rel="noopener" title="Descargar">
                                <i class="bi bi-download"></i>
                            </a>
                        </td>
                    </tr>';

                $cards .= '
                    <div class="tool-card">
                        <div class="tool-card-head">
                            <span class="tool-code">#' . $contador . ' - ' . $this->esc($tipo) . '</span>
                            <span><b>' . $this->esc($fecha) . '</b></span>
                        </div>
                        <div class="tool-body">
                            <div class="tool-row">
                                <div class="tool-label">Titulo</div>
                                <div class="tool-value">' . $this->esc($titulo) . '</div>
                            </div>
                            <div class="tool-row">
                                <div class="tool-label">Archivo</div>
                                <div class="tool-value">' . $this->esc($archivo) . '</div>
                            </div>
                            <div class="tool-row">
                                <div class="tool-label">Generado por</div>
                                <div class="tool-value">' . $this->esc($usuarioLabel) . '</div>
                            </div>
                            <div class="tool-row">
                                <div class="tool-label">Tamano</div>
                                <div class="tool-value">' . $this->esc($tamano) . '</div>
                            </div>
                            <div class="tool-actions">
                                <a class="btn btn-info btn-sm text-white" href="' . $this->esc($viewUrl) . '" target="_blank" rel="noopener" title="Visualizar">
                                    <i class="bi bi-eye"></i>
                                </a>
                                <a class="btn btn-danger btn-sm" href="' . $this->esc($downloadUrl) . '" target="_blank" rel="noopener" title="Descargar">
                                    <i class="bi bi-download"></i>
                                </a>
                            </div>
                        </div>
                    </div>';

                $contador++;
            }
        } else {
            $html .= '
                <tr class="align-middle">
                    <td class="text-center" colspan="9">No hay reportes generados guardados en el sistema</td>
                </tr>';

            $cards .= '
                <div class="tool-card">
                    <div class="tool-card-head">
                        <span class="tool-code">Sin reportes</span>
                        <span>-</span>
                    </div>
                    <div class="tool-body">
                        <div class="tool-row" style="border-bottom:0;">
                            <div class="tool-label">Estado</div>
                            <div class="tool-value">No hay reportes generados guardados en el sistema</div>
                        </div>
                    </div>
                </div>';
        }

        $html .= '
                        </tbody>
                    </table>
                </div>
            </div>';

        $cards .= '
                </div>
            </div>';

        $html .= $cards . '
            <div class="mt-2">
                <label class="form-label mb-0">Total registros: <strong>' . $total . '</strong></label>
            </div>
        </div>';

        return $html;
    }

    public function emitirReporteGuardado(int $idReporte, string $modo = 'download'): void
    {
        if (!$this->tablaDisponible()) {
            throw new RuntimeException('La tabla reporte_generado no existe.');
        }

        $stmt = $this->ejecutarConsultaConParametros(
            "SELECT
                id_ai_reporte_generado,
                tipo_reporte,
                titulo_reporte,
                nombre_archivo,
                ruta_archivo,
                mime_type,
                tamano_bytes,
                id_user_generador,
                nombre_user_generador,
                username_generador,
                created_at,
                std_reg
             FROM reporte_generado
             WHERE id_ai_reporte_generado = :id
               AND std_reg = 1
             LIMIT 1",
            [':id' => $idReporte]
        );

        $row = $stmt ? $stmt->fetch(\PDO::FETCH_ASSOC) : null;
        if (!$row) {
            throw new RuntimeException('No se encontro el reporte solicitado.');
        }

        $storedRelative = trim((string)$row['ruta_archivo']);
        if ($storedRelative === '' || strpos(str_replace('\\', '/', $storedRelative), $this->storageBaseRelative . '/') !== 0) {
            throw new RuntimeException('La ruta del reporte almacenado es invalida.');
        }

        $candidate = rtrim(APP_ROOT, '\\/') . DIRECTORY_SEPARATOR . str_replace(['/', '\\'], DIRECTORY_SEPARATOR, $storedRelative);
        $baseReal = realpath($this->storageBaseDir);
        $fileReal = is_file($candidate) ? realpath($candidate) : false;

        if ($baseReal === false || $fileReal === false || strpos($fileReal, $baseReal) !== 0) {
            throw new RuntimeException('El archivo del reporte ya no existe en el almacenamiento.');
        }

        $downloadName = basename((string)$row['nombre_archivo']);
        $mime = trim((string)$row['mime_type']) !== '' ? (string)$row['mime_type'] : 'application/pdf';
        $disposition = strtolower($modo) === 'view' ? 'inline' : 'attachment';

        if (!headers_sent()) {
            header('Content-Type: ' . $mime);
            header('Content-Length: ' . (string)filesize($fileReal));
            header('Content-Disposition: ' . $disposition . '; filename="' . rawurlencode($downloadName) . '"');
        }

        readfile($fileReal);
    }
}

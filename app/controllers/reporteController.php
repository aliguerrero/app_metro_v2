<?php

namespace app\controllers;

use app\models\mainModel;

class reporteController extends mainModel
{
    /** Permiso mínimo para generar/descargar reportes */
    private function requireReportePerm(): void
    {
        // en tu tabla roles_permisos existe: perm_ot_generar_reporte
        $this->requirePerm('perm_ot_generar_reporte');
    }

    private function getEmpresaInfo(): array
    {
        $stmt = $this->ejecutarConsultaParams(
            "SELECT
                id AS id_empresa,
                nombre AS nombre_empresa,
                rif,
                direccion,
                telefono,
                email,
                logo AS logo_path,
                created_at,
                updated_at
             FROM empresa_config
             WHERE id = 1
             LIMIT 1",
            []
        );

        if ($stmt && $stmt->rowCount() === 1) {
            $row = $stmt->fetch(\PDO::FETCH_ASSOC);
            return is_array($row) ? $row : [];
        }
        return [];
    }

    private function logoToDataUri(?string $logoPath): ?string
    {
        if (!$logoPath) return null;

        // Permite rutas relativas tipo "app/views/icons/metro.png"
        $base = realpath(__DIR__ . '/../../');
        $full = $logoPath;

        if (!preg_match('#^([a-zA-Z]:\\\\|/|https?://)#', $logoPath)) {
            $full = $base . DIRECTORY_SEPARATOR . ltrim($logoPath, '/\\');
        }

        if (!is_file($full)) return null;

        $ext = strtolower(pathinfo($full, PATHINFO_EXTENSION));
        $mime = match ($ext) {
            'png'  => 'image/png',
            'jpg', 'jpeg' => 'image/jpeg',
            'gif'  => 'image/gif',
            'webp' => 'image/webp',
            default => null
        };
        if (!$mime) return null;

        $bin = @file_get_contents($full);
        if ($bin === false) return null;

        return "data:$mime;base64," . base64_encode($bin);
    }

    private function cssBase(): string
    {
        return '
        <style>
            * { font-family: DejaVu Sans, Arial, Helvetica, sans-serif; }
            body { font-size: 12px; color:#111; }
            .wrap { width: 100%; }
            .header { width: 100%; border-bottom: 2px solid #111; padding-bottom: 8px; margin-bottom: 10px; }
            .header-table { width: 100%; border-collapse: collapse; }
            .logo { width: 80px; }
            .title { font-size: 16px; font-weight: 700; margin:0; }
            .sub { font-size: 11px; margin:2px 0 0 0; color:#333; }
            .meta { margin-top: 8px; padding: 6px; border:1px solid #ddd; border-radius: 6px; }
            .meta b { display:inline-block; min-width: 110px; }
            h3 { margin: 12px 0 6px; }
            table { width: 100%; border-collapse: collapse; }
            th, td { border: 1px solid #999; padding: 6px; vertical-align: top; }
            th { background: #f1f1f1; }
            .muted { color:#666; font-size: 11px; }
            .badge { display:inline-block; padding:2px 8px; border-radius: 10px; background:#eee; border:1px solid #ccc; font-size: 11px; }
            .hr { height: 1px; background:#ddd; margin: 10px 0; }
            .footer { margin-top: 14px; font-size: 10px; color:#666; text-align:center; }
        </style>';
    }

    private function renderHeader(string $tituloReporte): string
    {
        $empresa = $this->getEmpresaInfo();
        $logoUri = $this->logoToDataUri($empresa['logo_path'] ?? null);

        $nombre = $empresa['nombre_empresa'] ?? 'Empresa';
        $rif = $empresa['rif'] ?? '';
        $dir = $empresa['direccion'] ?? '';
        $tel = $empresa['telefono'] ?? '';
        $mail = $empresa['email'] ?? '';

        $line2 = trim(implode(' | ', array_filter([$rif, $tel, $mail])));
        $line3 = trim($dir);

        $logoHtml = $logoUri
            ? '<img src="' . $logoUri . '" class="logo" />'
            : '<div class="logo" style="border:1px solid #ccc; height:60px; width:80px; display:flex; align-items:center; justify-content:center;">LOGO</div>';

        return '
        <div class="header">
          <table class="header-table">
            <tr>
              <td style="width:90px;">' . $logoHtml . '</td>
              <td>
                <p class="title">' . htmlspecialchars($nombre) . '</p>
                <p class="sub">' . htmlspecialchars($line2) . '</p>
                <p class="sub">' . htmlspecialchars($line3) . '</p>
              </td>
              <td style="width:220px; text-align:right;">
                <p class="title" style="font-size:14px;">' . htmlspecialchars($tituloReporte) . '</p>
                <p class="sub">Generado: ' . date('d/m/Y H:i') . '</p>
              </td>
            </tr>
          </table>
        </div>';
    }

    private function buildFiltrosOtFromRequest(array $req): array
    {
        // filtros (todos opcionales)
        return [
            'n_ot'        => $this->limpiarCadena($req['n_ot'] ?? ''),
            'fecha_desde' => $this->limpiarCadena($req['fecha_desde'] ?? ''),
            'fecha_hasta' => $this->limpiarCadena($req['fecha_hasta'] ?? ''),
            'id_ai_area'     => $this->limpiarCadena($req['id_ai_area'] ?? ''),
            'id_ai_sitio'    => $this->limpiarCadena($req['id_ai_sitio'] ?? ''),
            'id_ai_estado'   => $this->limpiarCadena($req['id_ai_estado'] ?? ''),
            'id_user'     => $this->limpiarCadena($req['id_user'] ?? ''),
        ];
    }

    /** HTML de vista previa (OT con detalles N) */
    public function renderOtHtml(array $req): string
    {
        $this->requireReportePerm();

        $f = $this->buildFiltrosOtFromRequest($req);

        // Armado dinámico WHERE + params
        $where = ["ot.std_reg = 1"];
        $params = [];

        if ($f['n_ot'] !== '') {
            $where[] = "ot.n_ot = :n_ot";
            $params[':n_ot'] = $f['n_ot'];
        }

        if ($f['fecha_desde'] !== '' && $f['fecha_hasta'] !== '') {
            $where[] = "ot.fecha BETWEEN :fd AND :fh";
            $params[':fd'] = $f['fecha_desde'];
            $params[':fh'] = $f['fecha_hasta'];
        }

        if ($f['id_ai_area'] !== '' && $f['id_ai_area'] !== 'Seleccionar') {
            $where[] = "ot.id_ai_area = :id_ai_area";
            $params[':id_ai_area'] = $f['id_ai_area'];
        }

        if ($f['id_ai_sitio'] !== '' && $f['id_ai_sitio'] !== 'Seleccionar') {
            $where[] = "ot.id_ai_sitio = :id_ai_sitio";
            $params[':id_ai_sitio'] = $f['id_ai_sitio'];
        }

        if ($f['id_user'] !== '' && $f['id_user'] !== 'Seleccionar') {
            $where[] = "ot.id_user = :id_user";
            $params[':id_user'] = $f['id_user'];
        }

        // Estado: se filtra por estado en detalle_orden (último estado o cualquiera)
        // Aquí lo aplico por "último estado" (más útil en listados).
        $estadoJoin = "";
        if ($f['id_ai_estado'] !== '' && $f['id_ai_estado'] !== 'Seleccionar') {
            $estadoJoin = "
              INNER JOIN (
                SELECT d1.n_ot, d1.id_ai_estado
                FROM detalle_orden d1
              INNER JOIN (
                  SELECT n_ot, MAX(id_ai_detalle) AS max_id
                  FROM detalle_orden
                  GROUP BY n_ot
                ) d2 ON d2.n_ot = d1.n_ot AND d2.max_id = d1.id_ai_detalle
              ) lastd ON lastd.n_ot = ot.n_ot AND lastd.id_ai_estado = :id_ai_estado
            ";
            $params[':id_ai_estado'] = $f['id_ai_estado'];
        }

        // Si no hay filtros, LIMIT para que no explote el preview
        $limit = "";
        if (
            $f['n_ot'] === '' &&
            $f['fecha_desde'] === '' &&
            $f['id_ai_area'] === '' &&
            $f['id_ai_sitio'] === '' &&
            $f['id_user'] === '' &&
            $f['id_ai_estado'] === ''
        ) {
            $limit = " LIMIT 50 ";
        }

        $sqlOt = "
          SELECT
            " . $this->columnasTablaSql('orden_trabajo', 'ot') . ",
            a.nombre_area,
            s.nombre_sitio,
            COALESCE(emp_resp.nombre_empleado, u.id_empleado) AS responsable_nombre,
            u.username AS responsable_username
          FROM orden_trabajo ot
          INNER JOIN area_trabajo a ON a.id_ai_area = ot.id_ai_area
          INNER JOIN sitio_trabajo s ON s.id_ai_sitio = ot.id_ai_sitio
          INNER JOIN user_system u ON u.id_empleado = ot.id_user
          LEFT JOIN empleado emp_resp ON emp_resp.id_empleado = u.id_empleado
          $estadoJoin
          WHERE " . implode(" AND ", $where) . "
          ORDER BY ot.fecha DESC, ot.n_ot DESC
          $limit
        ";

        $stmt = $this->ejecutarConsultaParams($sqlOt, $params);
        $ots = $stmt ? $stmt->fetchAll(\PDO::FETCH_ASSOC) : [];

        $html = '<!doctype html><html><head><meta charset="utf-8">' . $this->cssBase() . '</head><body>';
        $html .= $this->renderHeader('Reporte de Órdenes de Trabajo');
        $html .= '<div class="wrap">';

        if (!$ots || count($ots) === 0) {
            $html .= '<div class="meta"><b>Resultado:</b> No hay registros para los filtros seleccionados.</div>';
            $html .= '</div></body></html>';
            return $html;
        }

        if (count($ots) === 50 && $limit !== '') {
            $html .= '<div class="meta"><span class="badge">Vista previa limitada a 50 OT</span> <span class="muted">Aplica filtros para ver/descargar más preciso.</span></div>';
        }

        foreach ($ots as $ot) {
            $n_ot = $ot['n_ot'];

            // Detalles (N registros)
            $sqlDet = "
              SELECT
                " . $this->columnasTablaSql('detalle_orden', 'd') . ",
                t.nombre_turno,
                e.nombre_estado,
                e.color,
                cco.nombre_miembro AS cco_nombre,
                ccf.nombre_miembro AS ccf_nombre,
                COALESCE(emp_tec.nombre_empleado, usr.id_empleado) AS tecnico_nombre,
                usr.username AS tecnico_username
              FROM detalle_orden d
              INNER JOIN turno_trabajo t ON t.id_ai_turno = d.id_ai_turno
              INNER JOIN estado_ot e ON e.id_ai_estado = d.id_ai_estado
              INNER JOIN miembro cco ON cco.id_miembro = d.id_miembro_cco
              INNER JOIN miembro ccf ON ccf.id_miembro = d.id_miembro_ccf
              INNER JOIN user_system usr ON usr.id_empleado = d.id_user_act
              LEFT JOIN empleado emp_tec ON emp_tec.id_empleado = usr.id_empleado
              WHERE d.n_ot = :n_ot
              ORDER BY d.fecha ASC, d.id_ai_detalle ASC
            ";
            $detStmt = $this->ejecutarConsultaParams($sqlDet, [':n_ot' => $n_ot]);
            $detalles = $detStmt ? $detStmt->fetchAll(\PDO::FETCH_ASSOC) : [];

            // Herramientas usadas
            $sqlHerr = "
              SELECT
                " . $this->columnasTablaSql('herramientaot', 'ho') . ",
                h.nombre_herramienta
              FROM herramientaot ho
              INNER JOIN herramienta h ON h.id_ai_herramienta = ho.id_ai_herramienta
              WHERE ho.n_ot = :n_ot
              ORDER BY ho.id_ai_herramientaOT ASC
            ";
            $herrStmt = $this->ejecutarConsultaParams($sqlHerr, [':n_ot' => $n_ot]);
            $herrs = $herrStmt ? $herrStmt->fetchAll(\PDO::FETCH_ASSOC) : [];

            $html .= '<h3>OT: ' . htmlspecialchars($ot['n_ot']) . '</h3>';
            $html .= '<div class="meta">';
            $html .= '<div><b>Fecha:</b> ' . htmlspecialchars(date('d/m/Y', strtotime($ot['fecha']))) . '</div>';
            $html .= '<div><b>Área:</b> ' . htmlspecialchars($ot['nombre_area']) . '</div>';
            $html .= '<div><b>Sitio:</b> ' . htmlspecialchars($ot['nombre_sitio']) . '</div>';
            $html .= '<div><b>Trabajo:</b> ' . htmlspecialchars($ot['nombre_trab']) . '</div>';
            $html .= '<div><b>Semana/Mes:</b> ' . htmlspecialchars((string)$ot['semana']) . ' / ' . htmlspecialchars((string)$ot['mes']) . '</div>';
            $html .= '<div><b>Responsable:</b> ' . htmlspecialchars($ot['responsable_nombre']) . ' (' . htmlspecialchars($ot['responsable_username']) . ')</div>';
            $html .= '</div>';

            // Tabla detalles
            $html .= '<h3>Detalles de trabajo</h3>';
            if (!$detalles || count($detalles) === 0) {
                $html .= '<div class="meta"><span class="muted">Esta OT no tiene detalles registrados.</span></div>';
            } else {
                $html .= '<table>';
                $html .= '<thead><tr>
                    <th style="width:70px;">Fecha</th>
                    <th>Descripción</th>
                    <th style="width:90px;">Turno</th>
                    <th style="width:90px;">CCO</th>
                    <th style="width:90px;">CCF</th>
                    <th style="width:110px;">Técnico</th>
                    <th style="width:60px;">#Tec</th>
                    <th style="width:120px;">Horas</th>
                    <th style="width:90px;">Estado</th>
                </tr></thead><tbody>';

                foreach ($detalles as $d) {
                    $horas = "PRE: {$d['hora_ini_pre']}-{$d['hora_fin_pre']}<br>TRA: {$d['hora_ini_tra']}-{$d['hora_fin_tra']}<br>EJE: {$d['hora_ini_eje']}-{$d['hora_fin_eje']}";
                    $html .= '<tr>';
                    $html .= '<td>' . htmlspecialchars(date('d/m/Y', strtotime($d['fecha']))) . '</td>';
                    $html .= '<td>' . htmlspecialchars((string)$d['descripcion']) . '<br><span class="muted">' . htmlspecialchars((string)($d['observacion'] ?? '')) . '</span></td>';
                    $html .= '<td>' . htmlspecialchars((string)$d['nombre_turno']) . '</td>';
                    $html .= '<td>' . htmlspecialchars((string)$d['cco_nombre']) . '</td>';
                    $html .= '<td>' . htmlspecialchars((string)$d['ccf_nombre']) . '</td>';
                    $html .= '<td>' . htmlspecialchars((string)$d['tecnico_nombre']) . '<br><span class="muted">(' . htmlspecialchars((string)$d['tecnico_username']) . ')</span></td>';
                    $html .= '<td style="text-align:center;">' . htmlspecialchars((string)$d['cant_tec']) . '</td>';
                    $html .= '<td>' . $horas . '</td>';
                    $html .= '<td><span class="badge">' . htmlspecialchars((string)$d['nombre_estado']) . '</span></td>';
                    $html .= '</tr>';
                }

                $html .= '</tbody></table>';
            }

            // Tabla herramientas
            $html .= '<h3>Herramientas usadas</h3>';
            if (!$herrs || count($herrs) === 0) {
                $html .= '<div class="meta"><span class="muted">No hay herramientas asociadas a esta OT.</span></div>';
            } else {
                $html .= '<table>';
                $html .= '<thead><tr>
                    <th style="width:90px;">Código</th>
                    <th>Herramienta</th>
                    <th style="width:80px;">Cantidad</th>
                    <th style="width:90px;">Estado</th>
                </tr></thead><tbody>';

                foreach ($herrs as $h) {
                    $html .= '<tr>';
                    $html .= '<td>' . htmlspecialchars((string)$h['id_ai_herramienta']) . '</td>';
                    $html .= '<td>' . htmlspecialchars((string)$h['nombre_herramienta']) . '</td>';
                    $html .= '<td style="text-align:center;">' . htmlspecialchars((string)$h['cantidadot']) . '</td>';
                    $html .= '<td>' . htmlspecialchars((string)$h['estadoot']) . '</td>';
                    $html .= '</tr>';
                }

                $html .= '</tbody></table>';
            }

            $html .= '<div class="hr"></div>';
        }

        $html .= '<div class="footer">Documento generado por el sistema</div>';
        $html .= '</div></body></html>';

        return $html;
    }

    /** Genera PDF (descarga/stream) */
    public function outputOtPdf(array $req): void
    {
        $this->requireReportePerm();

        // DOMPDF local
        require_once __DIR__ . '/../lib/dompdf/autoload.inc.php';
        $dompdf = new \Dompdf\Dompdf([
            'isRemoteEnabled' => true,
            'isHtml5ParserEnabled' => true,
        ]);

        $paper = $this->limpiarCadena($req['paper'] ?? 'A4');
        $orientation = $this->limpiarCadena($req['orientation'] ?? 'portrait');

        $html = $this->renderOtHtml($req);

        $dompdf->loadHtml($html, 'UTF-8');
        $dompdf->setPaper($paper ?: 'A4', ($orientation === 'landscape') ? 'landscape' : 'portrait');
        $dompdf->render();

        // Nombre
        $n = $this->limpiarCadena($req['n_ot'] ?? '');
        $file = $n !== '' ? ("OT_" . $n . ".pdf") : ("Reporte_OT_" . date('Ymd_His') . ".pdf");

        // inline = false => descarga directa
        $dompdf->stream($file, ['Attachment' => true]);
    }
}

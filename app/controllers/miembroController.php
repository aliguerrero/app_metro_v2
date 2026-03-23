<?php

namespace app\controllers;

use app\models\mainModel;

class miembroController extends mainModel
{
    private function tipoMiembroLabelInterno(int $tipo): string
    {
        return $tipo === 1
            ? 'Operador CCF'
            : ($tipo === 2 ? 'Operador CCO' : 'Tipo no definido');
    }

    public function tipoMiembroLabelControlador(int $tipo): string
    {
        return $this->tipoMiembroLabelInterno($tipo);
    }

    private function validarTipoMiembro(string $tipo): int
    {
        if (!is_numeric($tipo)) {
            return 0;
        }

        $tipoInt = (int)$tipo;
        return in_array($tipoInt, [1, 2], true) ? $tipoInt : 0;
    }

    private function obtenerEmpleadoActivo(string $idEmpleado): ?array
    {
        $stmt = $this->ejecutarConsultaParams(
            "SELECT
                e.id_empleado,
                e.nacionalidad,
                e.nombre_empleado,
                COALESCE(NULLIF(e.telefono, ''), '') AS telefono,
                COALESCE(NULLIF(e.correo, ''), '') AS correo
             FROM empleado e
             WHERE e.id_empleado = :id_empleado
               AND e.std_reg = 1
             LIMIT 1",
            [':id_empleado' => $idEmpleado]
        );

        if (!$stmt || $stmt->rowCount() <= 0) {
            return null;
        }

        return $stmt->fetch();
    }

    private function obtenerMiembroPorEmpleado(string $idEmpleado): ?array
    {
        $stmt = $this->ejecutarConsultaParams(
            "SELECT
                m.id_ai_miembro,
                m.id_miembro,
                m.id_empleado,
                m.nombre_miembro,
                m.tipo_miembro,
                m.std_reg
             FROM miembro m
             WHERE m.id_empleado = :id_empleado
             LIMIT 1",
            [':id_empleado' => $idEmpleado]
        );

        if (!$stmt || $stmt->rowCount() <= 0) {
            return null;
        }

        return $stmt->fetch();
    }

    private function obtenerMiembroPorCodigo(string $codigo): ?array
    {
        $stmt = $this->ejecutarConsultaParams(
            "SELECT
                m.id_ai_miembro,
                m.id_miembro,
                m.id_empleado,
                m.nombre_miembro,
                m.tipo_miembro,
                m.std_reg
             FROM miembro m
             WHERE m.id_miembro = :id_miembro
             LIMIT 1",
            [':id_miembro' => $codigo]
        );

        if (!$stmt || $stmt->rowCount() <= 0) {
            return null;
        }

        return $stmt->fetch();
    }

    private function siguienteCodigoMiembro(): string
    {
        $stmt = $this->ejecutarConsultaParams(
            "SELECT COALESCE(MAX(CAST(SUBSTRING(id_miembro, 3) AS UNSIGNED)), 0)
             FROM miembro
             WHERE id_miembro REGEXP '^M-[0-9]+$'"
        );

        $maximo = $stmt ? (int)$stmt->fetchColumn() : 0;
        return 'M-' . str_pad((string)($maximo + 1), 3, '0', STR_PAD_LEFT);
    }

    public function siguienteCodigoMiembroControlador(): string
    {
        return $this->siguienteCodigoMiembro();
    }

    private function documentoEmpleado(array $row): string
    {
        $idEmpleado = trim((string)($row['id_empleado'] ?? ''));
        $nacionalidad = trim((string)($row['nacionalidad'] ?? ''));

        if ($idEmpleado === '') {
            return 'No vinculado';
        }

        if ($nacionalidad !== '') {
            return $nacionalidad . '-' . $idEmpleado;
        }

        return $idEmpleado;
    }

    private function datosSelectEmpleados(): array
    {
        $stmt = $this->ejecutarConsultaParams(
            "SELECT
                e.id_empleado,
                e.nacionalidad,
                e.nombre_empleado,
                COALESCE(NULLIF(e.telefono, ''), '') AS telefono,
                COALESCE(NULLIF(e.correo, ''), '') AS correo,
                m.id_miembro AS miembro_codigo,
                m.tipo_miembro AS miembro_tipo,
                m.std_reg AS miembro_activo
             FROM empleado e
             LEFT JOIN miembro m
               ON m.id_empleado = e.id_empleado
             WHERE e.std_reg = 1
             ORDER BY e.nombre_empleado ASC, e.id_empleado ASC"
        );

        return $stmt ? $stmt->fetchAll() : [];
    }

    public function listarComboEmpleadoMiembroControlador(string $selectName, string $selectId, ?string $selectedIdEmpleado = null): string
    {
        $selectName = htmlspecialchars($selectName, ENT_QUOTES, 'UTF-8');
        $selectId = htmlspecialchars($selectId, ENT_QUOTES, 'UTF-8');
        $selectedIdEmpleado = $selectedIdEmpleado !== null ? trim($selectedIdEmpleado) : null;

        $html = '<select class="form-select miembro-empleado-select" name="' . $selectName . '" id="' . $selectId . '" required>';
        $html .= '<option value="">Seleccionar empleado</option>';

        foreach ($this->datosSelectEmpleados() as $row) {
            $idEmpleado = trim((string)($row['id_empleado'] ?? ''));
            $nombre = trim((string)($row['nombre_empleado'] ?? ''));
            $telefono = trim((string)($row['telefono'] ?? ''));
            $correo = trim((string)($row['correo'] ?? ''));
            $documento = $this->documentoEmpleado($row);
            $miembroCodigo = trim((string)($row['miembro_codigo'] ?? ''));
            $miembroTipo = (int)($row['miembro_tipo'] ?? 0);
            $miembroActivo = (int)($row['miembro_activo'] ?? 0);

            $selected = ($selectedIdEmpleado !== null && $selectedIdEmpleado === $idEmpleado) ? ' selected' : '';
            $label = htmlspecialchars($nombre . ' | ' . $documento, ENT_QUOTES, 'UTF-8');

            $html .= '<option value="' . htmlspecialchars($idEmpleado, ENT_QUOTES, 'UTF-8') . '"'
                . ' data-doc="' . htmlspecialchars($documento, ENT_QUOTES, 'UTF-8') . '"'
                . ' data-nombre="' . htmlspecialchars($nombre, ENT_QUOTES, 'UTF-8') . '"'
                . ' data-telefono="' . htmlspecialchars($telefono, ENT_QUOTES, 'UTF-8') . '"'
                . ' data-correo="' . htmlspecialchars($correo, ENT_QUOTES, 'UTF-8') . '"'
                . ' data-miembro-codigo="' . htmlspecialchars($miembroCodigo, ENT_QUOTES, 'UTF-8') . '"'
                . ' data-miembro-activo="' . $miembroActivo . '"'
                . ' data-miembro-tipo="' . $miembroTipo . '"'
                . '>'
                . $label
                . '</option>';
        }

        $html .= '</select>';

        return $html;
    }

    private function contactoEmpleadoHtml(string $telefono, string $correo): string
    {
        $partes = [];

        if ($telefono !== '') {
            $partes[] = 'Tel. ' . htmlspecialchars($telefono, ENT_QUOTES, 'UTF-8');
        }

        if ($correo !== '') {
            $partes[] = htmlspecialchars($correo, ENT_QUOTES, 'UTF-8');
        }

        return $partes !== [] ? implode(' | ', $partes) : 'Sin contacto';
    }

    private function consultaMiembroListado(): string
    {
        return "SELECT
            m.id_miembro,
            m.id_empleado,
            m.nombre_miembro,
            m.tipo_miembro,
            m.std_reg,
            e.nacionalidad,
            e.nombre_empleado,
            e.telefono AS telefono_empleado,
            e.correo AS correo_empleado,
            CASE
                WHEN e.id_empleado IS NOT NULL AND TRIM(e.id_empleado) <> ''
                    THEN CONCAT(COALESCE(NULLIF(e.nacionalidad, ''), ''), IF(COALESCE(NULLIF(e.nacionalidad, ''), '') = '', '', '-'), e.id_empleado)
                ELSE 'No vinculado'
            END AS documento_empleado,
            CASE
                WHEN e.nombre_empleado IS NOT NULL AND TRIM(e.nombre_empleado) <> ''
                    THEN e.nombre_empleado
                ELSE m.nombre_miembro
            END AS nombre_visual,
            CASE
                WHEN e.id_empleado IS NOT NULL AND TRIM(e.id_empleado) <> '' THEN 1
                ELSE 0
            END AS empleado_vinculado
        FROM miembro m
        LEFT JOIN empleado e
          ON e.id_empleado = m.id_empleado
        WHERE m.std_reg = 1";
    }

    public function listarMiembroControlador()
    {
        $this->requirePerm('perm_miembro_view');

        $perms = $_SESSION['permisos'] ?? [];
        $canEdit = !empty($perms['perm_miembro_edit']) && (int)$perms['perm_miembro_edit'] === 1;
        $canDelete = !empty($perms['perm_miembro_delete']) && (int)$perms['perm_miembro_delete'] === 1;

        $datosStmt = $this->ejecutarConsulta($this->consultaMiembroListado() . " ORDER BY nombre_visual ASC, m.id_miembro ASC");
        $datos = $datosStmt ? $datosStmt->fetchAll() : [];

        $tabla = '
    <div class="miembro-responsive">
      <div class="d-none d-md-block">
        <div class="table-responsive table-wrapper3" id="tabla-ot" style="max-height:70vh; overflow-y:auto;">
          <table class="table border mb-0 table-hover table-sm table-striped" id="tablaDatosMiem">
            <thead class="table-light fw-semibold">
              <tr class="align-middle">
                <th>#</th>
                <th class="text-center"><i class="bx bx-group fs-5" aria-hidden="true"></i></th>
                <th>Codigo</th>
                <th>Empleado</th>
                <th>Documento</th>
                <th class="text-center">Tipo</th>
                <th>Contacto</th>
                <th class="text-center">Acciones</th>
              </tr>
            </thead>
            <tbody>
    ';

        $cards = '
      <div class="d-md-none">
        <div class="tool-cards" id="toolCardsMiem">
    ';

        if (!empty($datos)) {
            $contador = 1;

            foreach ($datos as $row) {
                $codigo = htmlspecialchars((string)$row['id_miembro'], ENT_QUOTES, 'UTF-8');
                $nombre = htmlspecialchars((string)$row['nombre_visual'], ENT_QUOTES, 'UTF-8');
                $documento = htmlspecialchars((string)$row['documento_empleado'], ENT_QUOTES, 'UTF-8');
                $tipo = htmlspecialchars($this->tipoMiembroLabelInterno((int)$row['tipo_miembro']), ENT_QUOTES, 'UTF-8');
                $contactoHtml = $this->contactoEmpleadoHtml(
                    trim((string)($row['telefono_empleado'] ?? '')),
                    trim((string)($row['correo_empleado'] ?? ''))
                );
                $badgeVinculo = ((int)($row['empleado_vinculado'] ?? 0) === 1)
                    ? '<span class="badge bg-success">Vinculado</span>'
                    : '<span class="badge bg-secondary">Legacy</span>';

                $acciones = '<div class="tools-action-group" role="group" aria-label="Acciones de miembro">';
                if ($canEdit) {
                    $acciones .= '
                        <a href="#" title="Modificar" class="btn btn-warning text-dark"
                           data-bs-toggle="modal" data-bs-target="#ventanaModalModificarMiem" data-bs-id="' . $codigo . '">
                          <i class="bi bi-pencil text-white"></i>
                        </a>';
                }
                if ($canDelete) {
                    $acciones .= '
                        <a href="#" title="Eliminar" class="btn btn-danger"
                           onclick="eliminarMiembro(\'' . $codigo . '\', \'' . APP_URL . '\', ' . ($canEdit ? 1 : 0) . ', ' . ($canDelete ? 1 : 0) . '); return false;">
                          <i class="bi bi-trash" style="color:white;"></i>
                        </a>';
                }
                $acciones .= '</div>';

                $tabla .= '
              <tr class="align-middle">
                <td><b>' . $contador . '</b></td>
                <td class="text-center col-p">
                  <div class="avatar avatar-md">
                    <img class="avatar-img" src="' . APP_URL . 'app/views/img/avatars/user.png" alt="miembro">
                  </div>
                </td>
                <td><b>' . $codigo . '</b></td>
                <td>
                  <div><b>' . $nombre . '</b></div>
                  <div class="small text-muted">' . $badgeVinculo . '</div>
                </td>
                <td>' . $documento . '</td>
                <td class="text-center"><b>' . $tipo . '</b></td>
                <td class="miembro-contact-cell">' . $contactoHtml . '</td>
                <td class="action-cell text-center">' . $acciones . '</td>
              </tr>';

                $cards .= '
              <div class="tool-card">
                <div class="tool-card-head">
                  <span class="tool-code">' . $codigo . '</span>
                  <span>' . $badgeVinculo . '</span>
                </div>

                <div class="tool-body">
                  <div class="tool-row">
                    <div class="tool-label">Empleado</div>
                    <div class="tool-value">' . $nombre . '</div>
                  </div>
                  <div class="tool-row">
                    <div class="tool-label">Documento</div>
                    <div class="tool-value">' . $documento . '</div>
                  </div>
                  <div class="tool-row">
                    <div class="tool-label">Tipo</div>
                    <div class="tool-value">' . $tipo . '</div>
                  </div>
                  <div class="tool-row">
                    <div class="tool-label">Contacto</div>
                    <div class="tool-value miembro-contact-value">' . $contactoHtml . '</div>
                  </div>
                  <div class="tool-actions">' . $acciones . '</div>
                </div>
              </div>';

                $contador++;
            }
        } else {
            $tabla .= '<tr class="align-middle"><td class="text-center" colspan="8">No hay registros en el sistema</td></tr>';
            $cards .= '
              <div class="tool-card">
                <div class="tool-card-head">
                  <span class="tool-code">Sin registros</span>
                  <span>-</span>
                </div>
                <div class="tool-body">
                  <div class="tool-row" style="border-bottom:0;">
                    <div class="tool-label">Estado</div>
                    <div class="tool-value">No hay miembros activos registrados</div>
                  </div>
                </div>
              </div>';
        }

        $tabla .= '</tbody></table></div></div>';
        $cards .= '</div></div>';
        $tabla .= $cards . '</div>';

        return $tabla;
    }

    private function respuestaError(string $texto): string
    {
        return json_encode([
            'tipo' => 'simple',
            'titulo' => 'No se pudo completar la operacion',
            'texto' => $texto,
            'icono' => 'error'
        ], JSON_UNESCAPED_UNICODE);
    }

    public function registrarMiembroControlador()
    {
        $this->requirePerm('perm_miembro_add');

        $idEmpleado = $this->limpiarCadena($_POST['id_empleado'] ?? '');
        $tipo = $this->validarTipoMiembro($this->limpiarCadena($_POST['tipo'] ?? ''));

        if ($idEmpleado === '' || $tipo === 0) {
            return $this->respuestaError('Debes seleccionar un empleado y un tipo de operador valido.');
        }

        $empleado = $this->obtenerEmpleadoActivo($idEmpleado);
        if (!$empleado) {
            return $this->respuestaError('El empleado seleccionado no esta disponible para registrarlo como miembro.');
        }

        $miembroExistente = $this->obtenerMiembroPorEmpleado($idEmpleado);
        if ($miembroExistente && (int)$miembroExistente['std_reg'] === 1) {
            return $this->respuestaError(
                'El empleado ' . $empleado['nombre_empleado'] . ' ya esta registrado como miembro '
                . $miembroExistente['id_miembro'] . ' (' . $this->tipoMiembroLabelInterno((int)$miembroExistente['tipo_miembro']) . ').'
            );
        }

        try {
            $this->beginTransaction();

            if ($miembroExistente) {
                $this->ejecutarConsultaParams(
                    "UPDATE miembro
                     SET id_empleado = :id_empleado,
                         nombre_miembro = :nombre_miembro,
                         tipo_miembro = :tipo_miembro,
                         std_reg = 1
                     WHERE id_miembro = :id_miembro",
                    [
                        ':id_empleado' => $idEmpleado,
                        ':nombre_miembro' => $empleado['nombre_empleado'],
                        ':tipo_miembro' => $tipo,
                        ':id_miembro' => $miembroExistente['id_miembro']
                    ]
                );

                $codigo = (string)$miembroExistente['id_miembro'];
                $mensaje = 'Se reactivo el miembro ' . $codigo . ' para ' . $empleado['nombre_empleado'] . '.';
            } else {
                $codigo = $this->siguienteCodigoMiembro();

                $this->guardarDatos('miembro', [
                    ['campo_nombre' => 'id_miembro', 'campo_marcador' => ':id_miembro', 'campo_valor' => $codigo],
                    ['campo_nombre' => 'id_empleado', 'campo_marcador' => ':id_empleado', 'campo_valor' => $idEmpleado],
                    ['campo_nombre' => 'nombre_miembro', 'campo_marcador' => ':nombre_miembro', 'campo_valor' => $empleado['nombre_empleado']],
                    ['campo_nombre' => 'tipo_miembro', 'campo_marcador' => ':tipo_miembro', 'campo_valor' => $tipo],
                    ['campo_nombre' => 'std_reg', 'campo_marcador' => ':std_reg', 'campo_valor' => 1],
                ]);

                $mensaje = 'El miembro ' . $codigo . ' fue asignado a ' . $empleado['nombre_empleado'] . '.';
            }

            $this->commit();

            return json_encode([
                'tipo' => 'limpiar',
                'titulo' => 'Miembro registrado',
                'texto' => $mensaje,
                'icono' => 'success'
            ], JSON_UNESCAPED_UNICODE);
        } catch (\Throwable $e) {
            if ($this->inTransaction()) {
                $this->rollBack();
            }

            $this->registrarLogSistema('ERROR', 'miembro', 'Error al registrar miembro', [
                'error' => $e->getMessage(),
                'id_empleado' => $idEmpleado,
                'tipo_miembro' => $tipo
            ]);

            if (stripos($e->getMessage(), 'uk_miembro_id_empleado') !== false) {
                return $this->respuestaError('El empleado seleccionado ya tiene un miembro asociado. Recarga la lista e intenta nuevamente.');
            }

            return $this->respuestaError('No se pudo registrar el miembro. Intenta nuevamente.');
        }
    }

    public function actualizarDatosMiembro()
    {
        $this->requirePerm('perm_miembro_edit');

        $idMiembro = $this->limpiarCadena($_POST['id'] ?? '');
        $idEmpleado = $this->limpiarCadena($_POST['id_empleado'] ?? '');
        $tipo = $this->validarTipoMiembro($this->limpiarCadena($_POST['tipo'] ?? ''));

        if ($idMiembro === '' || $idEmpleado === '' || $tipo === 0) {
            return $this->respuestaError('Debes completar los datos obligatorios del miembro.');
        }

        $miembroActual = $this->obtenerMiembroPorCodigo($idMiembro);
        if (!$miembroActual || (int)$miembroActual['std_reg'] !== 1) {
            return $this->respuestaError('No encontramos el miembro que intentas actualizar.');
        }

        $empleado = $this->obtenerEmpleadoActivo($idEmpleado);
        if (!$empleado) {
            return $this->respuestaError('El empleado seleccionado no esta disponible para vincularlo al miembro.');
        }

        $otroMiembro = $this->obtenerMiembroPorEmpleado($idEmpleado);
        if ($otroMiembro && (string)$otroMiembro['id_miembro'] !== $idMiembro) {
            $texto = 'El empleado ' . $empleado['nombre_empleado'] . ' ya esta asociado al miembro '
                . $otroMiembro['id_miembro'];

            if ((int)$otroMiembro['std_reg'] === 1) {
                $texto .= ' (' . $this->tipoMiembroLabelInterno((int)$otroMiembro['tipo_miembro']) . ').';
            } else {
                $texto .= ' en estado inactivo. Reactiva ese registro si deseas reutilizarlo.';
            }

            return $this->respuestaError($texto);
        }

        try {
            $this->ejecutarConsultaParams(
                "UPDATE miembro
                 SET id_empleado = :id_empleado,
                     nombre_miembro = :nombre_miembro,
                     tipo_miembro = :tipo_miembro
                 WHERE id_miembro = :id_miembro",
                [
                    ':id_empleado' => $idEmpleado,
                    ':nombre_miembro' => $empleado['nombre_empleado'],
                    ':tipo_miembro' => $tipo,
                    ':id_miembro' => $idMiembro
                ]
            );

            return json_encode([
                'tipo' => 'limpiar',
                'titulo' => 'Miembro actualizado',
                'texto' => 'Se actualizo el miembro ' . $idMiembro . ' con la informacion de ' . $empleado['nombre_empleado'] . '.',
                'icono' => 'success'
            ], JSON_UNESCAPED_UNICODE);
        } catch (\Throwable $e) {
            $this->registrarLogSistema('ERROR', 'miembro', 'Error al actualizar miembro', [
                'error' => $e->getMessage(),
                'id_miembro' => $idMiembro,
                'id_empleado' => $idEmpleado,
                'tipo_miembro' => $tipo
            ]);

            return $this->respuestaError('No se pudo actualizar el miembro. Intenta nuevamente.');
        }
    }
}

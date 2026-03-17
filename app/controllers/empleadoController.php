<?php

namespace app\controllers;

use app\models\mainModel;
use PDO;

class empleadoController extends mainModel
{
    private function esc(string $value): string
    {
        return htmlspecialchars($value, ENT_QUOTES, 'UTF-8');
    }

    private function normalizarNacionalidad(?string $nacionalidad): string
    {
        return strtoupper(trim((string)$nacionalidad)) === 'E' ? 'E' : 'V';
    }

    private function formatearDocumento(string $idEmpleado, ?string $nacionalidad): string
    {
        return $this->normalizarNacionalidad($nacionalidad) . '-' . trim($idEmpleado);
    }

    private function construirResumenContacto(?string $telefono, ?string $correo): string
    {
        $items = [];
        $telefono = trim((string)$telefono);
        $correo = trim((string)$correo);

        if ($telefono !== '') {
            $items[] = 'Tel: ' . $telefono;
        }

        if ($correo !== '') {
            $items[] = $correo;
        }

        return !empty($items) ? implode(' / ', $items) : 'Sin contacto';
    }

    private function construirDatoOpcional(?string $value, string $fallback): string
    {
        $value = trim((string)$value);
        return $value !== '' ? $value : $fallback;
    }

    public function obtenerCategoriaEmpleadoPorId(int $idCategoria): ?array
    {
        $stmt = $this->ejecutarConsultaConParametros(
            "SELECT id_ai_categoria_empleado, nombre_categoria, descripcion, std_reg
             FROM categoria_empleado
             WHERE id_ai_categoria_empleado = :id
             LIMIT 1",
            [':id' => $idCategoria]
        );

        if (!$stmt || $stmt->rowCount() === 0) {
            return null;
        }

        return $stmt->fetch(PDO::FETCH_ASSOC) ?: null;
    }

    public function obtenerEmpleadoPorCodigo(string $idEmpleado): ?array
    {
        $stmt = $this->ejecutarConsultaConParametros(
            "SELECT
                e.id_ai_empleado,
                e.id_empleado,
                e.nacionalidad,
                e.nombre_empleado,
                e.telefono,
                e.direccion,
                e.correo,
                e.id_ai_categoria_empleado,
                e.std_reg,
                COALESCE(c.nombre_categoria, 'SIN CATEGORIA') AS nombre_categoria
             FROM empleado e
             LEFT JOIN categoria_empleado c
               ON c.id_ai_categoria_empleado = e.id_ai_categoria_empleado
             WHERE e.id_empleado = :id
             LIMIT 1",
            [':id' => $idEmpleado]
        );

        if (!$stmt || $stmt->rowCount() === 0) {
            return null;
        }

        return $stmt->fetch(PDO::FETCH_ASSOC) ?: null;
    }

    public function obtenerEmpleadoPorPk(int $idAiEmpleado): ?array
    {
        $stmt = $this->ejecutarConsultaConParametros(
            "SELECT
                e.id_ai_empleado,
                e.id_empleado,
                e.nacionalidad,
                e.nombre_empleado,
                e.telefono,
                e.direccion,
                e.correo,
                e.id_ai_categoria_empleado,
                e.std_reg,
                COALESCE(c.nombre_categoria, 'SIN CATEGORIA') AS nombre_categoria,
                u.id_ai_user,
                u.username,
                u.std_reg AS user_std_reg
             FROM empleado e
             LEFT JOIN categoria_empleado c
               ON c.id_ai_categoria_empleado = e.id_ai_categoria_empleado
             LEFT JOIN user_system u
               ON u.id_empleado = e.id_empleado
              AND u.std_reg = 1
             WHERE e.id_ai_empleado = :id
             LIMIT 1",
            [':id' => $idAiEmpleado]
        );

        if (!$stmt || $stmt->rowCount() === 0) {
            return null;
        }

        return $stmt->fetch(PDO::FETCH_ASSOC) ?: null;
    }

    public function listarComboCategoriasEmpleadoControlador(
        string $name,
        string $idAttr = '',
        ?int $selected = null,
        bool $includePlaceholder = true
    ): string {
        $stmt = $this->ejecutarConsultaConParametros(
            "SELECT id_ai_categoria_empleado, nombre_categoria
             FROM categoria_empleado
             WHERE std_reg = 1
             ORDER BY nombre_categoria ASC"
        );

        $rows = $stmt ? $stmt->fetchAll(PDO::FETCH_ASSOC) : [];
        $idHtml = $idAttr !== '' ? ' id="' . $this->esc($idAttr) . '"' : '';

        $html = '<select class="form-select" name="' . $this->esc($name) . '"' . $idHtml . '>';

        if ($includePlaceholder) {
            $html .= '<option value="">Seleccionar</option>';
        }

        foreach ($rows as $row) {
            $value = (int)$row['id_ai_categoria_empleado'];
            $isSelected = ($selected !== null && $selected === $value) ? ' selected' : '';
            $html .= '<option value="' . $value . '"' . $isSelected . '>'
                . $this->esc((string)$row['nombre_categoria'])
                . '</option>';
        }

        $html .= '</select>';

        return $html;
    }

    public function listarComboEmpleadosDisponiblesControlador(
        string $name,
        string $idAttr = '',
        ?string $selectedIdEmpleado = null
    ): string {
        $stmt = $this->ejecutarConsultaConParametros(
            "SELECT
                e.id_empleado,
                e.nacionalidad,
                e.nombre_empleado,
                COALESCE(c.nombre_categoria, 'SIN CATEGORIA') AS nombre_categoria,
                u.username
             FROM empleado e
             LEFT JOIN categoria_empleado c
               ON c.id_ai_categoria_empleado = e.id_ai_categoria_empleado
             LEFT JOIN user_system u
               ON u.id_empleado = e.id_empleado
              AND u.std_reg = 1
             WHERE e.std_reg = 1
             ORDER BY e.nombre_empleado ASC",
            []
        );

        $rows = $stmt ? $stmt->fetchAll(PDO::FETCH_ASSOC) : [];
        $idHtml = $idAttr !== '' ? ' id="' . $this->esc($idAttr) . '"' : '';

        $html = '<select class="form-select" name="' . $this->esc($name) . '"' . $idHtml . '>';
        $html .= '<option value="">Seleccionar</option>';

        foreach ($rows as $row) {
            $idEmpleado = (string)$row['id_empleado'];
            $selected = ($selectedIdEmpleado !== null && $selectedIdEmpleado === $idEmpleado) ? ' selected' : '';
            $label = $this->formatearDocumento($idEmpleado, $row['nacionalidad'] ?? null)
                . ' - '
                . (string)$row['nombre_empleado'];
            $categoria = trim((string)($row['nombre_categoria'] ?? ''));
            if ($categoria !== '') {
                $label .= ' (' . $categoria . ')';
            }
            if (!empty($row['username'])) {
                $label .= ' - @' . (string)$row['username'];
            }

            $html .= '<option value="' . $this->esc($idEmpleado) . '"' . $selected . '>'
                . $this->esc($label)
                . '</option>';
        }

        $html .= '</select>';

        return $html;
    }

    public function listarCategoriaEmpleadoControlador(): string
    {
        $stmt = $this->ejecutarConsultaConParametros(
            "SELECT
                c.id_ai_categoria_empleado,
                c.nombre_categoria,
                c.descripcion,
                COUNT(e.id_ai_empleado) AS total_empleados
             FROM categoria_empleado c
             LEFT JOIN empleado e
               ON e.id_ai_categoria_empleado = c.id_ai_categoria_empleado
              AND e.std_reg = 1
             WHERE c.std_reg = 1
             GROUP BY c.id_ai_categoria_empleado, c.nombre_categoria, c.descripcion
             ORDER BY c.nombre_categoria ASC"
        );

        $rows = $stmt ? $stmt->fetchAll(PDO::FETCH_ASSOC) : [];
        $total = count($rows);

        $tabla = '
        <div class="categoria-empleado-responsive p-3">
            <div class="d-none d-md-block">
                <div class="table-responsive table-wrapper3" style="max-height:70vh; overflow-y:auto;">
                    <table class="table border mb-0 table-hover table-sm table-striped" id="tablaCategoriaEmpleado">
                        <thead class="table-light fw-semibold">
                            <tr class="align-middle">
                                <th>#</th>
                                <th>Categoria</th>
                                <th>Descripcion</th>
                                <th class="text-center">Empleados</th>
                                <th class="text-center" colspan="2">Acciones</th>
                            </tr>
                        </thead>
                        <tbody>';

        $cards = '
            <div class="d-md-none p-3">
                <div class="tool-cards" id="toolCardsCategoriaEmpleado">';

        if ($total > 0) {
            $contador = 1;

            foreach ($rows as $row) {
                $id = (int)$row['id_ai_categoria_empleado'];
                $nombre = (string)$row['nombre_categoria'];
                $descripcion = trim((string)($row['descripcion'] ?? ''));
                $descripcion = $descripcion !== '' ? $descripcion : 'Sin descripcion';
                $totalEmpleados = (int)$row['total_empleados'];

                $tabla .= '
                    <tr class="align-middle">
                        <td><b>' . $contador . '</b></td>
                        <td><b>' . $this->esc($nombre) . '</b></td>
                        <td>' . $this->esc($descripcion) . '</td>
                        <td class="text-center"><b>' . $totalEmpleados . '</b></td>
                        <td class="text-center">
                            <a href="#" class="btn btn-warning text-dark js-catemp-edit" data-id="' . $id . '" title="Modificar">
                                <i class="bi bi-pencil text-white"></i>
                            </a>
                        </td>
                        <td class="text-center">
                            <a href="#" class="btn btn-danger js-catemp-del" data-id="' . $id . '" title="Eliminar">
                                <i class="bi bi-trash" style="color:white;"></i>
                            </a>
                        </td>
                    </tr>';

                $cards .= '
                    <div class="tool-card">
                        <div class="tool-card-head">
                            <span class="tool-code">#' . $contador . ' - Categoria</span>
                            <span><b>' . $this->esc($nombre) . '</b></span>
                        </div>
                        <div class="tool-body">
                            <div class="tool-row">
                                <div class="tool-label">Descripcion</div>
                                <div class="tool-value">' . $this->esc($descripcion) . '</div>
                            </div>
                            <div class="tool-row">
                                <div class="tool-label">Empleados</div>
                                <div class="tool-value">' . $totalEmpleados . '</div>
                            </div>
                            <div class="tool-actions">
                                <a href="#" class="btn btn-warning text-dark btn-sm js-catemp-edit" data-id="' . $id . '" title="Modificar">
                                    <i class="bi bi-pencil text-white"></i>
                                </a>
                                <a href="#" class="btn btn-danger btn-sm js-catemp-del" data-id="' . $id . '" title="Eliminar">
                                    <i class="bi bi-trash"></i>
                                </a>
                            </div>
                        </div>
                    </div>';

                $contador++;
            }
        } else {
            $tabla .= '
                <tr class="align-middle">
                    <td class="text-center" colspan="6">No hay categorias registradas</td>
                </tr>';

            $cards .= '
                <div class="tool-card">
                    <div class="tool-card-head">
                        <span class="tool-code">Sin registros</span>
                        <span>-</span>
                    </div>
                    <div class="tool-body">
                        <div class="tool-row" style="border-bottom:0;">
                            <div class="tool-label">Estado</div>
                            <div class="tool-value">No hay categorias registradas</div>
                        </div>
                    </div>
                </div>';
        }

        $tabla .= '
                        </tbody>
                    </table>
                </div>
            </div>';

        $cards .= '
                </div>
            </div>';

        $tabla .= $cards . '
            <div class="mt-2">
                <label class="form-label mb-0">Total registros: <strong>' . $total . '</strong></label>
            </div>
        </div>';

        return $tabla;
    }

    public function listarEmpleadoControlador(): string
    {
        $stmt = $this->ejecutarConsultaConParametros(
            "SELECT
                e.id_ai_empleado,
                e.id_empleado,
                e.nacionalidad,
                e.nombre_empleado,
                e.telefono,
                e.correo,
                e.direccion,
                COALESCE(c.nombre_categoria, 'SIN CATEGORIA') AS nombre_categoria,
                CASE
                    WHEN u.id_ai_user IS NULL THEN 'NO ASOCIADO'
                    ELSE CONCAT('@', u.username)
                END AS usuario_sistema
             FROM empleado e
             LEFT JOIN categoria_empleado c
               ON c.id_ai_categoria_empleado = e.id_ai_categoria_empleado
             LEFT JOIN user_system u
               ON u.id_empleado = e.id_empleado
              AND u.std_reg = 1
             WHERE e.std_reg = 1
             ORDER BY e.nombre_empleado ASC"
        );

        $rows = $stmt ? $stmt->fetchAll(PDO::FETCH_ASSOC) : [];
        $total = count($rows);

        $tabla = '
        <div class="empleado-responsive p-3">
            <div class="d-none d-md-block">
                <div class="table-responsive table-wrapper3" style="max-height:70vh; overflow-y:auto;">
                    <table class="table border mb-0 table-hover table-sm table-striped" id="tablaEmpleado">
                        <thead class="table-light fw-semibold">
                            <tr class="align-middle">
                                <th>#</th>
                                <th>Documento</th>
                                <th>Empleado</th>
                                <th>Categoria</th>
                                <th>Contacto</th>
                                <th>Usuario sistema</th>
                                <th class="text-center" colspan="2">Acciones</th>
                            </tr>
                        </thead>
                        <tbody>';

        $cards = '
            <div class="d-md-none p-3">
                <div class="tool-cards" id="toolCardsEmpleado">';

        if ($total > 0) {
            $contador = 1;

            foreach ($rows as $row) {
                $idAi = (int)$row['id_ai_empleado'];
                $idEmpleado = (string)$row['id_empleado'];
                $documento = $this->formatearDocumento($idEmpleado, $row['nacionalidad'] ?? null);
                $nombre = (string)$row['nombre_empleado'];
                $categoria = (string)$row['nombre_categoria'];
                $telefono = trim((string)($row['telefono'] ?? ''));
                $correo = trim((string)($row['correo'] ?? ''));
                $direccion = $this->construirDatoOpcional($row['direccion'] ?? '', 'Sin direccion');
                $contacto = $this->construirResumenContacto($telefono, $correo);
                $usuarioSistema = (string)$row['usuario_sistema'];

                $tabla .= '
                    <tr class="align-middle">
                        <td><b>' . $contador . '</b></td>
                        <td><b>' . $this->esc($documento) . '</b></td>
                        <td>' . $this->esc($nombre) . '</td>
                        <td>' . $this->esc($categoria) . '</td>
                        <td>
                            <div class="small">' . $this->esc($contacto) . '</div>
                            <div class="small text-muted">' . $this->esc($direccion) . '</div>
                        </td>
                        <td>' . $this->esc($usuarioSistema) . '</td>
                        <td class="text-center">
                            <a href="#" class="btn btn-warning text-dark js-emp-edit" data-id="' . $idAi . '" title="Modificar">
                                <i class="bi bi-pencil text-white"></i>
                            </a>
                        </td>
                        <td class="text-center">
                            <a href="#" class="btn btn-danger js-emp-del" data-id="' . $idAi . '" title="Eliminar">
                                <i class="bi bi-trash" style="color:white;"></i>
                            </a>
                        </td>
                    </tr>';

                $cards .= '
                    <div class="tool-card">
                        <div class="tool-card-head">
                            <span class="tool-code">#' . $contador . ' - ' . $this->esc($documento) . '</span>
                            <span><b>' . $this->esc($nombre) . '</b></span>
                        </div>
                        <div class="tool-body">
                            <div class="tool-row">
                                <div class="tool-label">Categoria</div>
                                <div class="tool-value">' . $this->esc($categoria) . '</div>
                            </div>
                            <div class="tool-row">
                                <div class="tool-label">Contacto</div>
                                <div class="tool-value">' . $this->esc($contacto) . '</div>
                            </div>
                            <div class="tool-row">
                                <div class="tool-label">Direccion</div>
                                <div class="tool-value">' . $this->esc($direccion) . '</div>
                            </div>
                            <div class="tool-row">
                                <div class="tool-label">Usuario</div>
                                <div class="tool-value">' . $this->esc($usuarioSistema) . '</div>
                            </div>
                            <div class="tool-actions">
                                <a href="#" class="btn btn-warning text-dark btn-sm js-emp-edit" data-id="' . $idAi . '" title="Modificar">
                                    <i class="bi bi-pencil text-white"></i>
                                </a>
                                <a href="#" class="btn btn-danger btn-sm js-emp-del" data-id="' . $idAi . '" title="Eliminar">
                                    <i class="bi bi-trash"></i>
                                </a>
                            </div>
                        </div>
                    </div>';

                $contador++;
            }
        } else {
            $tabla .= '
                <tr class="align-middle">
                    <td class="text-center" colspan="8">No hay empleados registrados</td>
                </tr>';

            $cards .= '
                <div class="tool-card">
                    <div class="tool-card-head">
                        <span class="tool-code">Sin registros</span>
                        <span>-</span>
                    </div>
                    <div class="tool-body">
                        <div class="tool-row" style="border-bottom:0;">
                            <div class="tool-label">Estado</div>
                            <div class="tool-value">No hay empleados registrados</div>
                        </div>
                    </div>
                </div>';
        }

        $tabla .= '
                        </tbody>
                    </table>
                </div>
            </div>';

        $cards .= '
                </div>
            </div>';

        $tabla .= $cards . '
            <div class="mt-2">
                <label class="form-label mb-0">Total registros: <strong>' . $total . '</strong></label>
            </div>
        </div>';

        return $tabla;
    }
}

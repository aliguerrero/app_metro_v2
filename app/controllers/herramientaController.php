<?php

namespace app\controllers;

use app\models\mainModel;
use PDO;

class herramientaController extends mainModel
{
    private function esc(string $value): string
    {
        return htmlspecialchars($value, ENT_QUOTES, 'UTF-8');
    }

    private function nombreHerramientaValido(string $nombre): bool
    {
        return !$this->verificarDatos('[\p{L}0-9 ._\-()/&+]{3,90}', $nombre);
    }

    private function categoriaHerramientaActiva(int $idCategoria): bool
    {
        if ($idCategoria <= 0) {
            return false;
        }

        $stmt = $this->ejecutarConsultaConParametros(
            "SELECT COUNT(1)
             FROM categoria_herramienta
             WHERE id_ai_categoria_herramienta = :id
               AND std_reg = 1",
            [':id' => $idCategoria]
        );

        return $stmt && (int)$stmt->fetchColumn() > 0;
    }

    public function obtenerCategoriaHerramientaPorId(int $idCategoria): ?array
    {
        $stmt = $this->ejecutarConsultaConParametros(
            "SELECT
                id_ai_categoria_herramienta,
                nombre_categoria,
                descripcion,
                std_reg
             FROM categoria_herramienta
             WHERE id_ai_categoria_herramienta = :id
             LIMIT 1",
            [':id' => $idCategoria]
        );

        if (!$stmt || $stmt->rowCount() === 0) {
            return null;
        }

        return $stmt->fetch(PDO::FETCH_ASSOC) ?: null;
    }

    public function listarComboCategoriasHerramientaControlador(
        string $name,
        string $idAttr = '',
        ?int $selected = null,
        bool $includePlaceholder = true
    ): string {
        $stmt = $this->ejecutarConsultaConParametros(
            "SELECT
                id_ai_categoria_herramienta,
                nombre_categoria
             FROM categoria_herramienta
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
            $value = (int)$row['id_ai_categoria_herramienta'];
            $selectedAttr = ($selected !== null && $selected === $value) ? ' selected' : '';
            $html .= '<option value="' . $value . '"' . $selectedAttr . '>'
                . $this->esc((string)$row['nombre_categoria'])
                . '</option>';
        }

        $html .= '</select>';

        return $html;
    }

    public function listarCategoriaHerramientaControlador(): string
    {
        $stmt = $this->ejecutarConsultaConParametros(
            "SELECT
                c.id_ai_categoria_herramienta,
                c.nombre_categoria,
                c.descripcion,
                COUNT(h.id_ai_herramienta) AS total_herramientas
             FROM categoria_herramienta c
             LEFT JOIN herramienta h
               ON h.id_ai_categoria_herramienta = c.id_ai_categoria_herramienta
              AND h.std_reg = 1
             WHERE c.std_reg = 1
             GROUP BY c.id_ai_categoria_herramienta, c.nombre_categoria, c.descripcion
             ORDER BY c.nombre_categoria ASC"
        );

        $rows = $stmt ? $stmt->fetchAll(PDO::FETCH_ASSOC) : [];
        $total = count($rows);

        $tabla = '
        <div class="categoria-herramienta-responsive p-3">
            <div class="d-none d-md-block">
                <div class="table-responsive table-wrapper3" style="max-height:70vh; overflow-y:auto;">
                    <table class="table border mb-0 table-hover table-sm table-striped" id="tablaCategoriaHerramienta">
                        <thead class="table-light fw-semibold">
                            <tr class="align-middle">
                                <th>#</th>
                                <th>Categoria</th>
                                <th>Descripcion</th>
                                <th class="text-center">Herramientas</th>
                                <th class="text-center" colspan="2">Acciones</th>
                            </tr>
                        </thead>
                        <tbody>';

        $cards = '
            <div class="d-md-none p-3">
                <div class="tool-cards" id="toolCardsCategoriaHerramienta">';

        if ($total > 0) {
            $contador = 1;

            foreach ($rows as $row) {
                $id = (int)$row['id_ai_categoria_herramienta'];
                $nombre = (string)$row['nombre_categoria'];
                $descripcion = trim((string)($row['descripcion'] ?? ''));
                $descripcion = $descripcion !== '' ? $descripcion : 'Sin descripcion';
                $totalHerramientas = (int)$row['total_herramientas'];

                $tabla .= '
                    <tr class="align-middle">
                        <td><b>' . $contador . '</b></td>
                        <td><b>' . $this->esc($nombre) . '</b></td>
                        <td>' . $this->esc($descripcion) . '</td>
                        <td class="text-center"><b>' . $totalHerramientas . '</b></td>
                        <td class="text-center">
                            <a href="#" class="btn btn-warning text-dark js-catherr-edit" data-id="' . $id . '" title="Modificar">
                                <i class="bi bi-pencil text-white"></i>
                            </a>
                        </td>
                        <td class="text-center">
                            <a href="#" class="btn btn-danger js-catherr-del" data-id="' . $id . '" title="Eliminar">
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
                                <div class="tool-label">Herramientas</div>
                                <div class="tool-value">' . $totalHerramientas . '</div>
                            </div>
                            <div class="tool-actions">
                                <a href="#" class="btn btn-warning text-dark btn-sm js-catherr-edit" data-id="' . $id . '" title="Modificar">
                                    <i class="bi bi-pencil text-white"></i>
                                </a>
                                <a href="#" class="btn btn-danger btn-sm js-catherr-del" data-id="' . $id . '" title="Eliminar">
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

    public function registrarHerramientaControlador()
    {
        $this->requirePerm('perm_herramienta_add');

        $nombre = $this->limpiarCadena($_POST['nombre'] ?? '');
        $nombre = preg_replace('/\s+/u', ' ', trim($nombre));
        $categoriaId = (int)$this->limpiarCadena($_POST['id_ai_categoria_herramienta'] ?? '');
        $cant = $this->limpiarCadena($_POST['cant'] ?? '');
        $estado = $this->limpiarCadena($_POST['estado'] ?? '');

        if ($nombre === "" || $categoriaId <= 0 || $cant === "" || $estado === "Seleccionar") {
            return json_encode([
                "tipo" => "simple",
                "titulo" => "Ocurrio un error inesperado",
                "texto" => "No has llenado todos los campos que son obligatorios",
                "icono" => "error"
            ]);
        }

        if (!$this->categoriaHerramientaActiva($categoriaId)) {
            return json_encode([
                "tipo" => "simple",
                "titulo" => "Categoria invalida",
                "texto" => "Debes seleccionar una categoria de herramienta valida.",
                "icono" => "error"
            ]);
        }

        $nombreOriginal = $nombre;
        if (!$this->nombreHerramientaValido($nombreOriginal)) {
            return json_encode([
                "tipo" => "simple",
                "titulo" => "Ocurrio un error inesperado",
                "texto" => "El nombre de la herramienta no cumple con el formato solicitado",
                "icono" => "error"
            ]);
        }
        $nombre = preg_replace('/[^\x20-\x7E]/u', 'A', $nombreOriginal) ?? $nombreOriginal;


        if ($this->verificarDatos('^[a-zA-Z0-9ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â©ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â­ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â³ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚ÂºÃƒÆ’Ã†â€™Ãƒâ€šÃ‚ÂÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â°ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚ÂÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œÃƒÆ’Ã†â€™Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â±ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‹Å“ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¼ÃƒÆ’Ã†â€™Ãƒâ€¦Ã¢â‚¬Å“ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â§ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¡ ._\-()/&+]{3,90}$', $nombre)) {
            return json_encode([
                "tipo" => "simple",
                "titulo" => "Ocurrio un error inesperado",
                "texto" => "El nombre de la herramienta no cumple con el formato solicitado",
                "icono" => "error"
            ]);
        }

        if (!is_numeric($cant) || (int)$cant < 0) {
            $nombre = $nombreOriginal;
            return json_encode([
                "tipo" => "simple",
                "titulo" => "Ocurrio un error inesperado",
                "texto" => "Cantidad ingresada no valida",
                "icono" => "error"
            ]);
        }

        $nombre = $nombreOriginal;

        try {
            $st = $this->ejecutarConsultaConParametros(
                "SELECT id_ai_herramienta, std_reg
                 FROM herramienta
                 WHERE TRIM(LOWER(nombre_herramienta)) = TRIM(LOWER(:nombre))
                 LIMIT 1",
                [':nombre' => $nombre]
            );

            if ($st && $st->rowCount() > 0) {
                $row = $st->fetch(PDO::FETCH_ASSOC);

                if ((int)$row['std_reg'] === 1) {
                    return json_encode([
                        "tipo" => "simple",
                        "titulo" => "Herramienta duplicada",
                        "texto" => "Ya existe una herramienta registrada con ese mismo nombre.",
                        "icono" => "warning"
                    ]);
                }

                return json_encode([
                    "tipo" => "simple",
                    "titulo" => "Herramienta existente",
                    "texto" => "Ya existe una herramienta con ese nombre pero esta inactiva. Reactivala en lugar de registrarla nuevamente.",
                    "icono" => "warning"
                ]);
            }
        } catch (\Throwable $e) {
            return json_encode([
                "tipo" => "simple",
                "titulo" => "Ocurrio un error inesperado",
                "texto" => "No se pudo validar si la herramienta ya existe.",
                "icono" => "error"
            ]);
        }

        $tools_datos_reg = [
            ["campo_nombre" => "nombre_herramienta", "campo_marcador" => ":Nombre", "campo_valor" => $nombre],
            ["campo_nombre" => "id_ai_categoria_herramienta", "campo_marcador" => ":Categoria", "campo_valor" => $categoriaId],
            ["campo_nombre" => "cantidad", "campo_marcador" => ":Cant", "campo_valor" => (int)$cant],
            ["campo_nombre" => "estado", "campo_marcador" => ":Estado", "campo_valor" => $estado],
            ["campo_nombre" => "std_reg", "campo_marcador" => ":std_reg", "campo_valor" => "1"],
        ];

        $registrar_tools = $this->guardarDatos("herramienta", $tools_datos_reg);

        if ($registrar_tools && $registrar_tools->rowCount() === 1) {
            return json_encode([
                "tipo" => "limpiar",
                "titulo" => "Herramienta registrada",
                "texto" => "La herramienta se ha registrado con exito",
                "icono" => "success"
            ]);
        }

        return json_encode([
            "tipo" => "simple",
            "titulo" => "Ocurrio un error inesperado",
            "texto" => "La herramienta no se pudo registrar correctamente",
            "icono" => "error"
        ]);
    }

    public function listarHerramientaControlador()
    {
        $this->requirePerm('perm_herramienta_view');

        $perms = $_SESSION['permisos'] ?? [];
        $canEdit = !empty($perms['perm_herramienta_edit']) && (int)$perms['perm_herramienta_edit'] === 1;
        $canDelete = !empty($perms['perm_herramienta_delete']) && (int)$perms['perm_herramienta_delete'] === 1;

        $consulta_datos = "
        SELECT
            id_ai_herramienta,
            nombre_herramienta,
            id_ai_categoria_herramienta,
            COALESCE(nombre_categoria, 'SIN CATEGORIA') AS nombre_categoria,
            cantidad_total AS cantidad,
            estado,
            std_reg,
            cantidad_disponible,
            cantidad_ocupada AS herramienta_ocupada
        FROM vw_herramienta_disponibilidad
        WHERE std_reg = 1
        ORDER BY id_ai_herramienta ASC
        ";

        $consulta_total = "SELECT COUNT(1) FROM vw_herramienta_disponibilidad WHERE std_reg = 1";

        $datos = $this->ejecutarConsulta($consulta_datos);
        $datos = $datos ? $datos->fetchAll(PDO::FETCH_ASSOC) : [];

        $total = $this->ejecutarConsulta($consulta_total);
        $total = $total ? (int)$total->fetchColumn() : 0;

        $tabla = '
      <div class="herramienta-responsive">

        <div class="d-none d-md-block">
          <div class="table-responsive table-wrapper3" id="tabla-ot" style="max-height:70vh; overflow-y:auto;">
            <table class="table border mb-0 table-hover table-sm table-striped" id="tablaDatosTools">
              <thead class="table-light fw-semibold">
                <tr class="align-middle">
                  <th class="clearfix">#</th>
                  <th class="text-center">
                    <i class="bx bx-wrench fs-5" aria-hidden="true"></i>
                  </th>
                  <th class="clearfix">Codigo</th>
                  <th class="clearfix">Nombre</th>
                  <th class="clearfix">Categoria</th>
                  <th class="text-center">Total</th>
                  <th class="text-center">Cant. Disp.</th>
                  <th class="text-center">Cant. Ocup.</th>
                  <th class="text-center">Acciones</th>
                </tr>
              </thead>
              <tbody>
    ';

        $cards = '
        <div class="d-md-none">
            <div class="tool-cards" id="toolCardsTools">
        ';

        if ($total >= 1) {
            $contador = 1;

            foreach ($datos as $rows) {
                $id = (int)$rows['id_ai_herramienta'];
                $nombre = $this->esc((string)$rows['nombre_herramienta']);
                $categoria = $this->esc((string)($rows['nombre_categoria'] ?? 'SIN CATEGORIA'));
                $cantidad = (int)$rows['cantidad'];
                $disponible = (int)$rows['cantidad_disponible'];
                $ocupada = (int)$rows['herramienta_ocupada'];

                $tabla .= '
              <tr class="align-middle">
                <td class="clearfix col-p"><div><b>' . $contador . '</b></div></td>
                <td class="text-center col-p">
                  <div class="avatar avatar-md">
                    <img class="avatar-img" src="' . APP_URL . 'app/views/img/tools.png" alt="tool">
                  </div>
                </td>
                <td class="col-1"><div class="clearfix"><div><b>' . $id . '</b></div></div></td>
                <td><div class="clearfix"><div><b>' . $nombre . '</b></div></div></td>
                <td><div class="clearfix"><div>' . $categoria . '</div></div></td>
                <td class="col-1"><div class="text-center"><b>' . $cantidad . '</b></div></td>
                <td class="col-1"><div class="text-center"><b>' . $disponible . '</b></div></td>
                <td class="col-1"><div class="text-center"><b>' . $ocupada . '</b></div></td>
            ';

                $acciones = '
                  <div class="tools-action-group" role="group" aria-label="Acciones de herramienta">
                    <button type="button" class="btn btn-info text-white js-tool-ocupaciones"
                      data-bs-toggle="modal"
                      data-bs-target="#herramientaOcupacionesModal"
                      data-id="' . $id . '"
                      data-nombre="' . $nombre . '"
                      title="Ver ocupaciones">
                      <i class="bi bi-diagram-3"></i>
                    </button>';

                if ($canEdit) {
                    $acciones .= '
                    <a href="#" title="Modificar" class="btn btn-warning text-dark" data-bs-toggle="modal" data-bs-target="#ventanaModalModificarHerr" data-bs-id="' . $id . '">
                      <i class="bi bi-pencil text-white"></i>
                    </a>';
                }

                if ($canDelete) {
                    $acciones .= '
                    <button type="button" class="btn btn-danger" title="Eliminar"
                      onclick="eliminarHerramienta(\'' . $id . '\',\'' . APP_URL . '\', ' . ($canEdit ? 'true' : 'false') . ', ' . ($canDelete ? 'true' : 'false') . ')">
                      <i class="bi bi-trash"></i>
                    </button>';
                }

                $acciones .= '</div>';

                $tabla .= '
                <td class="col-p text-center action-cell">' . $acciones . '</td>
              </tr>';

                $cards .= '
              <div class="tool-card">
                <div class="tool-card-head">
                  <span class="tool-code">#' . $contador . ' - Codigo: ' . $id . '</span>
                  <span><b>Disp:</b> ' . $disponible . '</span>
                </div>

                <div class="tool-body">
                  <div class="tool-row">
                    <div class="tool-label">Nombre</div>
                    <div class="tool-value">' . $nombre . '</div>
                  </div>

                  <div class="tool-row">
                    <div class="tool-label">Categoria</div>
                    <div class="tool-value">' . $categoria . '</div>
                  </div>

                  <div class="tool-row">
                    <div class="tool-label">Total</div>
                    <div class="tool-value">' . $cantidad . '</div>
                  </div>

                  <div class="tool-row">
                    <div class="tool-label">Ocupada</div>
                    <div class="tool-value">' . $ocupada . '</div>
                  </div>

                  <div class="tool-actions">
                    <div class="tools-action-group" role="group" aria-label="Acciones de herramienta">
                      <button type="button" class="btn btn-info text-white js-tool-ocupaciones"
                        data-bs-toggle="modal"
                        data-bs-target="#herramientaOcupacionesModal"
                        data-id="' . $id . '"
                        data-nombre="' . $nombre . '"
                        title="Ver ocupaciones">
                        <i class="bi bi-diagram-3"></i>
                      </button>';

                if ($canEdit) {
                    $cards .= '
                      <a href="#" title="Modificar" class="btn btn-warning text-dark btn-sm" data-bs-toggle="modal" data-bs-target="#ventanaModalModificarHerr" data-bs-id="' . $id . '">
                        <i class="bi bi-pencil text-white"></i>
                      </a>';
                }

                if ($canDelete) {
                    $cards .= '
                      <button type="button" class="btn btn-danger btn-sm" title="Eliminar"
                        onclick="eliminarHerramienta(\'' . $id . '\',\'' . APP_URL . '\', ' . ($canEdit ? 'true' : 'false') . ', ' . ($canDelete ? 'true' : 'false') . ')">
                        <i class="bi bi-trash"></i>
                      </button>';
                }

                $cards .= '
                    </div>
                  </div>
                </div>
              </div>';

                $contador++;
            }
        } else {
            $tabla .= '
          <tr class="align-middle">
            <td class="text-center" colspan="9">No hay registros en el sistema</td>
          </tr>
        ';

            $cards .= '
          <div class="tool-card">
            <div class="tool-card-head">
              <span class="tool-code">Sin registros</span>
              <span>-</span>
            </div>
            <div class="tool-body">
              <div class="tool-row" style="border-bottom:0;">
                <div class="tool-label">Estado</div>
                <div class="tool-value">No hay registros en el sistema</div>
              </div>
            </div>
          </div>';
        }

        $tabla .= '</tbody></table></div></div>';
        $cards .= '</div></div>';
        $tabla .= $cards . '</div>';

        return $tabla;
    }

    public function listarHerramienta()
    {
        $this->requirePerm('perm_herramienta_view');

        $consulta_datos = "
            SELECT
                id_ai_herramienta,
                nombre_herramienta,
                id_ai_categoria_herramienta,
                COALESCE(nombre_categoria, 'SIN CATEGORIA') AS nombre_categoria,
                cantidad_total AS cantidad,
                estado,
                std_reg,
                cantidad_disponible
            FROM vw_herramienta_disponibilidad
            WHERE std_reg = 1
            ORDER BY id_ai_herramienta ASC
        ";

        $datos = $this->ejecutarConsulta($consulta_datos);
        $rows = $datos ? $datos->fetchAll(PDO::FETCH_ASSOC) : [];

        $tabla = '
            <div class="table-responsive table-wrapper4" id="tabla-ot" style="max-height:70vh; overflow-y:auto;">
            <table class="table border mb-0 table-hover table-sm table-striped" id="tablaHerramienta">
                <thead class="table-light fw-semibold">
                    <tr class="align-middle">
                        <th class="clearfix">#</th>
                        <th class="text-center">
                            <i class="bx bx-wrench fs-5" aria-hidden="true"></i>
                        </th>
                        <th class="clearfix">Codigo</th>
                        <th class="clearfix">Nombre</th>
                        <th class="clearfix">Categoria</th>
                        <th class="text-center">Cant. Disp.</th>
                        <th class="text-center">Acciones</th>
                    </tr>
                </thead>
                <tbody>';

        if (count($rows) > 0) {
            $contador = 1;
            foreach ($rows as $r) {
                $tabla .= '
                    <tr class="align-middle">
                        <td class="col-p"><b>' . $contador . '</b></td>
                        <td class="text-center col-p">
                            <div class="avatar avatar-md"><img class="avatar-img" src="' . APP_URL . 'app/views/img/tools.png" alt="tool"></div>
                        </td>
                        <td class="col-p"><b>' . (int)$r['id_ai_herramienta'] . '</b></td>
                        <td><b>' . $this->esc((string)$r['nombre_herramienta']) . '</b></td>
                        <td>' . $this->esc((string)$r['nombre_categoria']) . '</td>
                        <td class="text-center col-p"><b>' . (int)$r['cantidad_disponible'] . '</b></td>
                        <td class="text-center col-p">
                            <button type="button" class="btn btn-success btn-sm" title="Seleccionar">
                                <i class="bi bi-plus-lg"></i>
                            </button>
                        </td>
                    </tr>';
                $contador++;
            }
        } else {
            $tabla .= '
                <tr class="align-middle">
                    <td class="text-center" colspan="7">No hay registros en el sistema</td>
                </tr>';
        }

        $tabla .= '</tbody></table></div>';
        return $tabla;
    }

    public function listarHerramientaOT()
    {
        $this->requirePerm('perm_herramienta_view');

        $consulta_datos = "
            SELECT
                hot.id_ai_herramientaOT,
                hot.n_ot,
                hot.id_ai_herramienta,
                h.nombre_herramienta,
                hot.cantidadot
            FROM herramientaot hot
            LEFT JOIN herramienta h ON hot.id_ai_herramienta = h.id_ai_herramienta
            ORDER BY hot.id_ai_herramientaOT ASC
        ";

        $datos = $this->ejecutarConsulta($consulta_datos);
        $rows = $datos ? $datos->fetchAll(PDO::FETCH_ASSOC) : [];

        $tabla = '
            <div class="table-responsive table-wrapper4" id="tabla-ot" style="max-height:70vh; overflow-y:auto;">
            <table class="table border mb-0 table-hover table-sm table-striped" id="tablaHerramientaOt">
                <thead class="table-light fw-semibold">
                    <tr class="align-middle">
                        <th class="clearfix">#</th>
                        <th class="text-center">
                            <i class="bx bx-wrench fs-5" aria-hidden="true"></i>
                        </th>
                        <th class="clearfix">OT</th>
                        <th class="clearfix">Codigo</th>
                        <th class="clearfix">Nombre</th>
                        <th class="text-center">Cantidad</th>
                        <th class="text-center">Accion</th>
                    </tr>
                </thead>
                <tbody>';

        if (count($rows) > 0) {
            $contador = 1;
            foreach ($rows as $r) {
                $tabla .= '
                    <tr class="align-middle">
                        <td class="col-p"><b>' . $contador . '</b></td>
                        <td class="text-center col-p">
                            <div class="avatar avatar-md"><img class="avatar-img" src="' . APP_URL . 'app/views/img/tools.png" alt="tool"></div>
                        </td>
                        <td class="col-p"><b>' . $this->esc((string)$r['n_ot']) . '</b></td>
                        <td class="col-p"><b>' . (int)$r['id_ai_herramienta'] . '</b></td>
                        <td><b>' . $this->esc((string)$r['nombre_herramienta']) . '</b></td>
                        <td class="text-center col-p"><b>' . (int)$r['cantidadot'] . '</b></td>
                        <td class="text-center col-p">
                            <button type="button" class="btn btn-danger btn-sm" title="Quitar">
                                <i class="bi bi-dash-lg"></i>
                            </button>
                        </td>
                    </tr>';
                $contador++;
            }
        } else {
            $tabla .= '
                <tr class="align-middle">
                    <td class="text-center" colspan="7">No hay registros en el sistema</td>
                </tr>';
        }

        $tabla .= '</tbody></table></div>';
        return $tabla;
    }

    public function eliminarHerramientaControlador()
    {
        $this->requirePerm('perm_herramienta_delete');

        $id = (int)($_POST['herramienta_id'] ?? 0);

        $datos = $this->ejecutarConsultaParams(
            "SELECT " . $this->columnasTablaSql('herramienta') . " FROM herramienta WHERE id_ai_herramienta = :id LIMIT 1",
            [':id' => $id]
        );

        if (!$datos || $datos->rowCount() <= 0) {
            return json_encode([
                "tipo" => "simple",
                "titulo" => "Ocurrio un error inesperado",
                "texto" => "No hemos encontrado la herramienta en el sistema",
                "icono" => "error"
            ], JSON_UNESCAPED_UNICODE);
        }

        $tool = $datos->fetch(PDO::FETCH_ASSOC);

        $datos_reg = [
            ["campo_nombre" => "std_reg", "campo_marcador" => ":std_reg", "campo_valor" => 0],
        ];

        $condicion = [
            "condicion_campo" => "id_ai_herramienta",
            "condicion_marcador" => ":id_ai_herramienta",
            "condicion_valor" => $id
        ];

        if ($this->actualizarDatos("herramienta", $datos_reg, $condicion)) {
            return json_encode([
                "tipo" => "recargar",
                "titulo" => "Herramienta eliminada",
                "texto" => "La herramienta " . $tool['nombre_herramienta'] . " ha sido eliminada con exito",
                "icono" => "success"
            ], JSON_UNESCAPED_UNICODE);
        }

        return json_encode([
            "tipo" => "simple",
            "titulo" => "Ocurrio un error inesperado",
            "texto" => "No se pudo eliminar la herramienta, por favor intente nuevamente",
            "icono" => "error"
        ], JSON_UNESCAPED_UNICODE);
    }

    public function actualizarDatosHeramienta()
    {
        $this->requirePerm('perm_herramienta_edit');

        $id = $this->limpiarCadena($_POST['id'] ?? '');
        $nombre = $this->limpiarCadena($_POST['nombre'] ?? '');
        $categoriaId = (int)$this->limpiarCadena($_POST['id_ai_categoria_herramienta'] ?? '');
        $cant = $this->limpiarCadena($_POST['cant'] ?? '');
        $estado = $this->limpiarCadena($_POST['estado'] ?? '');

        if ($id === '' || $nombre === "" || $categoriaId <= 0 || $cant === "" || $estado === "Seleccionar") {
            return json_encode([
                "tipo" => "simple",
                "titulo" => "Ocurrio un error inesperado",
                "texto" => "No has llenado todos los campos que son obligatorios",
                "icono" => "error"
            ]);
        }

        if (!$this->categoriaHerramientaActiva($categoriaId)) {
            return json_encode([
                "tipo" => "simple",
                "titulo" => "Categoria invalida",
                "texto" => "Debes seleccionar una categoria de herramienta valida.",
                "icono" => "error"
            ]);
        }
        $nombreOriginal = $nombre;
        if (!$this->nombreHerramientaValido($nombreOriginal)) {
            return json_encode([
                "tipo" => "simple",
                "titulo" => "Ocurrio un error inesperado",
                "texto" => "El nombre de la herramienta no cumple con el formato solicitado",
                "icono" => "error"
            ]);
        }
        $nombre = preg_replace('/[^\x20-\x7E]/u', 'A', $nombreOriginal) ?? $nombreOriginal;

        if ($this->verificarDatos('^[a-zA-Z0-9ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â©ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â­ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â³ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚ÂºÃƒÆ’Ã†â€™Ãƒâ€šÃ‚ÂÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â°ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚ÂÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œÃƒÆ’Ã†â€™Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â±ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‹Å“ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¼ÃƒÆ’Ã†â€™Ãƒâ€¦Ã¢â‚¬Å“ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â§ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¡ ._\-()/&+]{3,90}$', $nombre)) {
            return json_encode([
                "tipo" => "simple",
                "titulo" => "Ocurrio un error inesperado",
                "texto" => "El nombre de la herramienta no cumple con el formato solicitado",
                "icono" => "error"
            ]);
        }

        if (!is_numeric($cant) || (int)$cant < 0) {
            $nombre = $nombreOriginal;
            return json_encode([
                "tipo" => "simple",
                "titulo" => "Ocurrio un error inesperado",
                "texto" => "Cantidad ingresada no valida",
                "icono" => "error"
            ]);
        }

        $nombre = $nombreOriginal;

        $dup = $this->ejecutarConsultaConParametros(
            "SELECT id_ai_herramienta
             FROM herramienta
             WHERE TRIM(LOWER(nombre_herramienta)) = TRIM(LOWER(:nombre))
               AND id_ai_herramienta <> :id
               AND std_reg = 1
             LIMIT 1",
            [
                ':nombre' => $nombre,
                ':id' => (int)$id,
            ]
        );

        if ($dup && $dup->rowCount() > 0) {
            return json_encode([
                "tipo" => "simple",
                "titulo" => "Herramienta duplicada",
                "texto" => "Ya existe otra herramienta activa con ese mismo nombre.",
                "icono" => "warning"
            ]);
        }

        $herr_datos = [
            ["campo_nombre" => "nombre_herramienta", "campo_marcador" => ":Nombre", "campo_valor" => $nombre],
            ["campo_nombre" => "id_ai_categoria_herramienta", "campo_marcador" => ":Categoria", "campo_valor" => $categoriaId],
            ["campo_nombre" => "cantidad", "campo_marcador" => ":Cant", "campo_valor" => (int)$cant],
            ["campo_nombre" => "estado", "campo_marcador" => ":Estado", "campo_valor" => $estado],
        ];

        $condicion = [
            "condicion_campo" => "id_ai_herramienta",
            "condicion_marcador" => ":ID",
            "condicion_valor" => $id
        ];

        if ($this->actualizarDatos("herramienta", $herr_datos, $condicion)) {
            return json_encode([
                "tipo" => "limpiar",
                "titulo" => "Datos actualizados",
                "texto" => "Se actualizo correctamente",
                "icono" => "success"
            ]);
        }

        return json_encode([
            "tipo" => "simple",
            "titulo" => "Ocurrio un error inesperado",
            "texto" => "Ha ocurrido un error durante la actualizacion",
            "icono" => "error"
        ]);
    }
}


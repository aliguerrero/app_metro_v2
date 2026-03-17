<?php

namespace app\controllers;

use app\models\mainModel;

class miembroController extends mainModel
{
    public function registrarMiembroControlador()
    {
        $this->requirePerm('perm_miembro_add');

        $codigo = $this->limpiarCadena($_POST['codigo'] ?? '');
        $nombre = $this->limpiarCadena($_POST['nombre'] ?? '');
        $tipo   = $this->limpiarCadena($_POST['tipo'] ?? '');

        if ($codigo === '' || $nombre === '' || $tipo === '' || $tipo === 'Seleccionar') {
            return json_encode([
                "tipo" => "simple",
                "titulo" => "Ocurrió un error inesperado",
                "texto" => "No has llenado todos los campos que son obligatorios",
                "icono" => "error"
            ]);
        }

        // id_miembro: varchar(10)
        if ($this->verificarDatos('[a-zA-Z0-9-]{1,10}', $codigo)) {
            return json_encode([
                "tipo" => "simple",
                "titulo" => "Ocurrió un error inesperado",
                "texto" => "El CÓDIGO no cumple con el formato solicitado",
                "icono" => "error"
            ]);
        }

        // nombre_miembro: varchar(40)
        if ($this->verificarDatos('[a-zA-ZáéíóúÁÉÍÓÚñÑ ]{3,40}', $nombre)) {
            return json_encode([
                "tipo" => "simple",
                "titulo" => "Ocurrió un error inesperado",
                "texto" => "El NOMBRE DEL OPERADOR no cumple con el formato solicitado",
                "icono" => "error"
            ]);
        }

        // tipo_miembro: int(11)
        if (!is_numeric($tipo) || (int)$tipo < 1) {
            return json_encode([
                "tipo" => "simple",
                "titulo" => "Ocurrió un error inesperado",
                "texto" => "Tipo de miembro no válido",
                "icono" => "error"
            ]);
        }
        $tipoInt = (int)$tipo;

        // Chequeo de PK (NO depende de std_reg; PK debe ser estable)
        $check = $this->ejecutarConsultaParams(
            "SELECT id_miembro, std_reg FROM miembro WHERE id_miembro = :id LIMIT 1",
            [':id' => $codigo]
        );

        if ($check && $check->rowCount() > 0) {
            $ex = $check->fetch();

            // Opcional: podrías "reactivar" si std_reg=0
            // Por ahora, mantenemos regla simple: no permitir duplicados
            return json_encode([
                "tipo" => "simple",
                "titulo" => "Ocurrió un error inesperado",
                "texto" => "El CÓDIGO ingresado ya existe en los registros",
                "icono" => "error"
            ]);
        }

        $miembro_datos_reg = [
            ["campo_nombre" => "id_miembro",     "campo_marcador" => ":Codigo",  "campo_valor" => $codigo],
            ["campo_nombre" => "nombre_miembro", "campo_marcador" => ":Nombre",  "campo_valor" => $nombre],
            ["campo_nombre" => "tipo_miembro",   "campo_marcador" => ":Tipo",    "campo_valor" => $tipoInt],
            ["campo_nombre" => "std_reg",        "campo_marcador" => ":std_reg", "campo_valor" => 1],
        ];

        $registrar = $this->guardarDatos("miembro", $miembro_datos_reg);

        if ($registrar && $registrar->rowCount() === 1) {
            return json_encode([
                "tipo" => "limpiar",
                "titulo" => "Miembro Registrado",
                "texto" => "El miembro {$nombre} se ha registrado con éxito",
                "icono" => "success"
            ]);
        }

        return json_encode([
            "tipo" => "simple",
            "titulo" => "Ocurrió un error inesperado",
            "texto" => "El miembro no se pudo registrar correctamente",
            "icono" => "error"
        ]);
    }

    public function listarMiembroControlador()
    {
        $this->requirePerm('perm_miembro_view');

        $perms = $_SESSION['permisos'] ?? [];
        $canEdit   = !empty($perms['perm_miembro_edit']) && (int)$perms['perm_miembro_edit'] === 1;
        $canDelete = !empty($perms['perm_miembro_delete']) && (int)$perms['perm_miembro_delete'] === 1;

        // para imprimir en onclick como 1/0
        $canEditJs   = $canEdit ? 1 : 0;
        $canDeleteJs = $canDelete ? 1 : 0;

        $consulta_datos = "
        SELECT id_miembro, nombre_miembro, tipo_miembro
        FROM miembro
        WHERE std_reg = 1
        ORDER BY id_miembro ASC
    ";

        $stmtDatos = $this->ejecutarConsulta($consulta_datos);
        $datos = $stmtDatos ? $stmtDatos->fetchAll() : [];
        $total = is_array($datos) ? count($datos) : 0;

        $tabla = '
    <div class="miembro-responsive">

      <!-- DESKTOP: TABLA -->
      <div class="d-none d-md-block">
        <div class="table-responsive table-wrapper3" id="tabla-ot" style="max-height:70vh; overflow-y:auto;">
          <table class="table border mb-0 table-hover table-sm table-striped" id="tablaDatosMiem">
            <thead class="table-light fw-semibold">
              <tr class="align-middle">
                <th class="clearfix">#</th>
                <th class="text-center">
                  <i class="bx bx-group fs-5" aria-hidden="true"></i>
                </th>
                <th class="clearfix">Código</th>
                <th class="clearfix">Nombre Completo</th>
                <th class="text-center">Tipo de Operador</th>
                <th class="text-center" colspan="2">Acciones</th>
              </tr>
            </thead>
            <tbody>
    ';

        $cards = '
      <!-- MÓVIL: CARDS -->
      <div class="d-md-none">
        <div class="tool-cards" id="toolCardsMiem">
    ';

        if ($total >= 1) {
            $contador = 1;

            foreach ($datos as $rows) {
                $tipo_user = ((int)$rows['tipo_miembro'] === 1) ? "C.C.F." : "C.C.O.";
                $idEsc = htmlspecialchars((string)$rows['id_miembro'], ENT_QUOTES, 'UTF-8');
                $nombreEsc = htmlspecialchars((string)$rows['nombre_miembro'], ENT_QUOTES, 'UTF-8');

                $tabla .= '
              <tr class="align-middle">
                <td class="clearfix col-p"><div><b>' . $contador . '</b></div></td>
                <td class="text-center col-p">
                  <div class="avatar avatar-md">
                    <img class="avatar-img" src="' . APP_URL . 'app/views/img/avatars/user.png" alt="user@email.com">
                  </div>
                </td>
                <td class="col-p"><div class="clearfix"><div><b>' . $idEsc . '</b></div></div></td>
                <td><div class="clearfix"><div><b>' . $nombreEsc . '</b></div></div></td>
                <td class="col-2"><div class="text-center"><b>' . $tipo_user . '</b></div></td>
            ';

                // EDIT
                $tabla .= $canEdit
                    ? '
                <td class="col-p">
                  <a href="#" title="Modificar" class="btn btn-warning text-dark"
                     data-bs-toggle="modal" data-bs-target="#ventanaModalModificarMiem" data-bs-id="' . $idEsc . '">
                    <i class="bi bi-pencil text-white"></i>
                  </a>
                </td>'
                    : '<td class="col-p"></td>';

                // DELETE (AHORA por JS, igual que el render dinámico)
                $tabla .= $canDelete
                    ? '
                <td class="col-p">
                  <a href="#" title="Eliminar" class="btn btn-danger"
                     onclick="eliminarMiembro(\'' . $idEsc . '\', \'' . APP_URL . '\', ' . $canEditJs . ', ' . $canDeleteJs . '); return false;">
                    <i class="bi bi-trash" style="color:white;"></i>
                  </a>
                </td>'
                    : '<td class="col-p"></td>';

                $tabla .= '</tr>';

                // CARDS
                $cards .= '
              <div class="tool-card">
                <div class="tool-card-head">
                  <span class="tool-code">#' . $contador . ' • Código: ' . $idEsc . '</span>
                  <span><b>Tipo:</b> ' . $tipo_user . '</span>
                </div>

                <div class="tool-body">
                  <div class="tool-row">
                    <div class="tool-label">Nombre</div>
                    <div class="tool-value">' . $nombreEsc . '</div>
                  </div>

                  <div class="tool-actions">
            ';

                if ($canEdit) {
                    $cards .= '
                    <a href="#" title="Modificar" class="btn btn-warning text-dark btn-sm"
                       data-bs-toggle="modal" data-bs-target="#ventanaModalModificarMiem" data-bs-id="' . $idEsc . '">
                      <i class="bi bi-pencil text-white"></i>
                    </a>
                ';
                }
                if ($canDelete) {
                    $cards .= '
                    <button type="button" class="btn btn-danger btn-sm" title="Eliminar"
                            onclick="eliminarMiembro(\'' . $idEsc . '\', \'' . APP_URL . '\', ' . $canEditJs . ', ' . $canDeleteJs . ')">
                      <i class="bi bi-trash"></i>
                    </button>
                ';
                }

                $cards .= '
                  </div>
                </div>
              </div>
            ';

                $contador++;
            }
        } else {
            // total columnas = 7 (incluye 2 acciones)
            $tabla .= '
          <tr class="align-middle">
            <td class="text-center" colspan="7">No hay registros en el sistema</td>
          </tr>
        ';

            $cards .= '
          <div class="tool-card">
            <div class="tool-card-head">
              <span class="tool-code">Sin registros</span>
              <span>—</span>
            </div>
            <div class="tool-body">
              <div class="tool-row" style="border-bottom:0;">
                <div class="tool-label">Estado</div>
                <div class="tool-value">No hay registros en el sistema</div>
              </div>
            </div>
          </div>
        ';
        }

        $tabla .= '</tbody></table></div></div>';
        $cards .= '</div></div>';
        $tabla .= $cards . '</div>';

        return $tabla;
    }  

    public function actualizarDatosMiembro()
    {
        $this->requirePerm('perm_miembro_edit');

        $id     = $this->limpiarCadena($_POST['id'] ?? '');
        $codigo = $this->limpiarCadena($_POST['codigo'] ?? '');
        $nombre = $this->limpiarCadena($_POST['nombre'] ?? '');
        $tipo   = $this->limpiarCadena($_POST['tipo'] ?? '');

        if ($id === '' || $codigo === '' || $nombre === '' || $tipo === '' || $tipo === 'Seleccionar') {
            return json_encode([
                "tipo" => "simple",
                "titulo" => "Ocurrió un error inesperado",
                "texto" => "No has llenado todos los campos que son obligatorios",
                "icono" => "error"
            ]);
        }

        if ($this->verificarDatos('[a-zA-Z0-9-]{1,10}', $codigo)) {
            return json_encode([
                "tipo" => "simple",
                "titulo" => "Ocurrió un error inesperado",
                "texto" => "El CÓDIGO no cumple con el formato solicitado",
                "icono" => "error"
            ]);
        }

        if ($this->verificarDatos('[a-zA-ZáéíóúÁÉÍÓÚñÑ ]{3,40}', $nombre)) {
            return json_encode([
                "tipo" => "simple",
                "titulo" => "Ocurrió un error inesperado",
                "texto" => "El NOMBRE DEL MIEMBRO no cumple con el formato solicitado",
                "icono" => "error"
            ]);
        }

        if (!is_numeric($tipo) || (int)$tipo < 1) {
            return json_encode([
                "tipo" => "simple",
                "titulo" => "Ocurrió un error inesperado",
                "texto" => "Tipo de miembro no válido",
                "icono" => "error"
            ]);
        }
        $tipoInt = (int)$tipo;

        // Evitar duplicado PK en otro registro
        $check = $this->ejecutarConsultaParams(
            "SELECT id_miembro FROM miembro WHERE id_miembro = :codigo AND id_miembro <> :id LIMIT 1",
            [':codigo' => $codigo, ':id' => $id]
        );
        if ($check && $check->rowCount() > 0) {
            return json_encode([
                "tipo" => "simple",
                "titulo" => "Ocurrió un error inesperado",
                "texto" => "El código ingresado ya existe en los registros",
                "icono" => "error"
            ]);
        }

        $miembro_datos = [
            ["campo_nombre" => "id_miembro",     "campo_marcador" => ":codigo", "campo_valor" => $codigo],
            ["campo_nombre" => "nombre_miembro", "campo_marcador" => ":Nombre", "campo_valor" => $nombre],
            ["campo_nombre" => "tipo_miembro",   "campo_marcador" => ":Tipo",   "campo_valor" => $tipoInt],
        ];

        $condicion = [
            "condicion_campo"    => "id_miembro",
            "condicion_marcador" => ":ID",
            "condicion_valor"    => $id
        ];

        if ($this->actualizarDatos("miembro", $miembro_datos, $condicion)) {
            return json_encode([
                "tipo" => "limpiar",
                "titulo" => "Datos Actualizados",
                "texto" => "Se actualizó correctamente",
                "icono" => "success"
            ]);
        }

        return json_encode([
            "tipo" => "simple",
            "titulo" => "Ocurrió un error inesperado",
            "texto" => "¡Ha ocurrido un error durante la actualización!",
            "icono" => "error"
        ]);
    }
}

<?php

namespace app\controllers;

use app\models\mainModel;

class otController extends mainModel
{

  public function registrarOtControlador()
  {
    #Se obtienen y limpian los datos del formulario
    $area = $this->limpiarCadena($_POST['area']);
    $codigo = $this->limpiarCadena($_POST['codigo']);
    $fecha   = $this->limpiarCadena($_POST['fecha']);
    $nombre = $this->limpiarCadena($_POST['nombre']);
    $semana = $this->limpiarCadena($_POST['semana']);
    $mes   = $this->limpiarCadena($_POST['mes']);
    $sitio = $this->limpiarCadena($_POST['sitio']);

    #variable codigof
    $codigof = '';

    # Verificación de campos obligatorios #
    if ($area == '' || $codigo == '' || $fecha == '' || $nombre == '' || $semana == '' || $mes == 'Seleccionar' || $sitio == 'Seleccionar') {
      // Si algún campo obligatorio está vacío, se devuelve una alerta de error
      $alerta = [
        'tipo' => 'simple',
        'titulo' => 'Ocurrió un error inesperado',
        'texto' => 'No has llenado todos los campos que son obligatorios',
        'icono' => 'error'
      ];
      return json_encode($alerta);
      exit();
    }

    # Verificar la integridad de los datos de código #
    if ($this->verificarDatos('^[0-9]{1,10}$', $codigo)) {
      #Si el formato del código no es válido, se devuelve una alerta de error
      $alerta = [
        'tipo' => 'simple',
        'titulo' => 'Ocurrió un error inesperado',
        'texto' => 'El código no cumple con el formato solicitado',
        'icono' => 'error'
      ];
      return json_encode($alerta);
      exit();
    }

    # Verificar la integridad de los datos de nombre #
    if ($this->verificarDatos('[a-zA-ZáéíóúÁÉÍÓÚñÑ ]{3,60}', $nombre)) {
      #Si el formato del nombre no es válido, se devuelve una alerta de error
      $alerta = [
        'tipo' => 'simple',
        'titulo' => 'Ocurrió un error inesperado',
        'texto' => 'El nombre de trabajo no cumple con el formato solicitado',
        'icono' => 'error'
      ];
      return json_encode($alerta);
      exit();
    }

    $codigof = $area . $codigo;

    # Verificar el codigo #
    $check_codigo = $this->ejecutarConsultaConParametros(
      "SELECT n_ot FROM orden_trabajo WHERE n_ot = :n_ot",
      [':n_ot' => $codigof]
    );
    if ($check_codigo->rowCount() > 0) {
      // Si la Cedula ya existe en la base de datos, se devuelve una alerta de error
      $alerta = [
        'tipo' => 'simple',
        'titulo' => 'Ocurrió un error inesperado',
        'texto' => 'El codigo ingresado ya existe en los registros',
        'icono' => 'error'
      ];
      return json_encode($alerta);
      exit();
    }
    $datos = $this->ejecutarConsultaConParametros(
      "SELECT " . $this->columnasTablaSql('area_trabajo') . " FROM area_trabajo WHERE nomeclatura = :area",
      [':area' => $area]
    );
    $datos = $datos->fetch();

    # Definición de un array asociativo $miembro_datos_reg que contiene los datos del miembro a registrar
    $ot_datos_reg = [
      [
        'campo_nombre' => 'n_ot',
        'campo_marcador' => ':nrot',
        'campo_valor' => $codigof
      ],
      [
        'campo_nombre' => 'id_ai_area',
        'campo_marcador' => ':id_ai_area',
        'campo_valor' => $datos['id_ai_area']
      ],
      [
        'campo_nombre' => 'id_user',
        'campo_marcador' => ':id',
        'campo_valor' => $_SESSION['id']
      ],
      [
        'campo_nombre' => 'nombre_trab',
        'campo_marcador' => ':trabajo',
        'campo_valor' => $nombre =  mb_strtoupper($nombre, 'UTF-8')
      ],
      [
        'campo_nombre' => 'id_ai_sitio',
        'campo_marcador' => ':sitio',
        'campo_valor' => $sitio
      ],
      [
        'campo_nombre' => 'fecha',
        'campo_marcador' => ':fecha',
        'campo_valor' => $fecha
      ],
      [
        'campo_nombre' => 'semana',
        'campo_marcador' => ':semana',
        'campo_valor' => $semana
      ],
      [
        'campo_nombre' => 'mes',
        'campo_marcador' => ':mes',
        'campo_valor' => $mes
      ],
      [
        'campo_nombre' => 'std_reg',
        'campo_marcador' => ':std_reg',
        'campo_valor' => '1'
      ]
    ];

    #Llamada al método guardarDatos() para guardar los datos del miembro en la base de datos
    $registrar_ot = $this->guardarDatos('orden_trabajo', $ot_datos_reg);

    #Verificar si se registró correctamente el miembro
    if ($registrar_ot->rowCount() == 1) {
      #Si se registró correctamente, se devuelve un mensaje de éxito
      $alerta = [
        'tipo' => 'limpiar',
        'titulo' => 'Orden Registrada',
        'texto' => 'La orden de trabajo se ha registrado con éxito',
        'icono' => 'success'
      ];
    } else {


      #Se devuelve un mensaje de error
      $alerta = [
        'tipo' => 'simple',
        'titulo' => 'Ocurrió un error inesperado',
        'texto' => 'La orden de trabajo no se pudo registrar correctamente',
        'icono' => 'error'
      ];
    }

    #Se devuelve el mensaje de alerta en formato JSON
    return json_encode($alerta);
  }

  public function modificarOtControlador()
  {
    #Se obtienen y limpian los datos del formulario
    $id = $this->limpiarCadena($_POST['id']);

    $fecha   = $this->limpiarCadena($_POST['fecha1']);
    $nombre = $this->limpiarCadena($_POST['nombre']);
    $semana = $this->limpiarCadena($_POST['semana1']);
    $mes   = $this->limpiarCadena($_POST['mes1']);
    $sitio = $this->limpiarCadena($_POST['sitio']);

    #variable codigof
    $codigof = '';

    # Verificación de campos obligatorios #
    if ($fecha == '' || $nombre == '' || $semana == '' || $mes == 'Seleccionar' || $sitio == 'Seleccionar') {
      // Si algún campo obligatorio está vacío, se devuelve una alerta de error
      $alerta = [
        'tipo' => 'simple',
        'titulo' => 'Ocurrió un error inesperado',
        'texto' => 'No has llenado todos los campos que son obligatorios',
        'icono' => 'error'
      ];
      return json_encode($alerta);
      exit();
    }

    # Verificar la integridad de los datos de nombre #
    if ($this->verificarDatos('^[a-zA-Z0-9áéíóúÁÉÍÓÚñÑ()\- ]{3,60}$', $nombre)) {
      #Si el formato del nombre no es válido, se devuelve una alerta de error
      $alerta = [
        'tipo' => 'simple',
        'titulo' => 'Ocurrió un error inesperado',
        'texto' => 'El nombre de trabajo no cumple con el formato solicitado',
        'icono' => 'error'
      ];
      return json_encode($alerta);
      exit();
    }

    # Definición de un array asociativo $miembro_datos_reg que contiene los datos del miembro a registrar
    $ot_datos_reg = [
      [
        'campo_nombre' => 'nombre_trab',
        'campo_marcador' => ':trabajo',
        'campo_valor' => $nombre =  mb_strtoupper($nombre, 'UTF-8')
      ],
      [
        'campo_nombre' => 'id_ai_sitio',
        'campo_marcador' => ':sitio',
        'campo_valor' => $sitio
      ],
      [
        'campo_nombre' => 'fecha',
        'campo_marcador' => ':fecha',
        'campo_valor' => $fecha
      ],
      [
        'campo_nombre' => 'semana',
        'campo_marcador' => ':semana',
        'campo_valor' => $semana
      ],
      [
        'campo_nombre' => 'mes',
        'campo_marcador' => ':mes',
        'campo_valor' => $mes
      ]
    ];
    $condicion = [
      'condicion_campo' => 'n_ot',
      'condicion_marcador' => ':ID',
      'condicion_valor' => $id
    ];

    if ($this->actualizarDatos('orden_trabajo', $ot_datos_reg, $condicion)) {
      $alerta = [
        'tipo' => 'limpiar',
        'titulo' => 'Datos Actualizados',
        'texto' => 'Se actualizo correctamente',
        'icono' => 'success'
      ];
    } else {
      $alerta = [
        'tipo' => 'simple',
        'titulo' => 'Ocurrió un error inesperado',
        'texto' => '¡Ha ocurrido un error durante el registro!',
        'icono' => 'error'
      ];
    }
    return json_encode($alerta);
  }


  public function listarOtControlador()
  {
    $tabla = '';
    $otCols = $this->columnasTablaSql('orden_trabajo', 'ot');

    $consulta_datos = "SELECT {$otCols}, det_ord.id_ai_estado, estado.nombre_estado, estado.color
        FROM orden_trabajo ot
        LEFT JOIN (
            SELECT n_ot, MAX(id_ai_estado) as id_ai_estado
            FROM detalle_orden
            GROUP BY n_ot
        ) det_ord ON ot.n_ot = det_ord.n_ot
        LEFT JOIN estado_ot estado ON det_ord.id_ai_estado = estado.id_ai_estado
        WHERE ot.std_reg = '1'
        ORDER BY ot.n_ot ASC";

    $consulta_total = "SELECT COUNT(ot.n_ot)
        FROM orden_trabajo ot
        LEFT JOIN (
            SELECT n_ot, MAX(id_ai_estado) as id_ai_estado
            FROM detalle_orden
            GROUP BY n_ot
        ) det_ord ON ot.n_ot = det_ord.n_ot
        LEFT JOIN estado_ot estado ON det_ord.id_ai_estado = estado.id_ai_estado
        WHERE ot.std_reg = '1'";

    $datos = $this->ejecutarConsulta($consulta_datos);
    $datos = $datos->fetchAll();

    $total = $this->ejecutarConsulta($consulta_total);
    $total = (int)$total->fetchColumn();

    /* =========================
       DESKTOP: TABLA
    ========================= */
    $tabla .= '
      <div class="ot-responsive">

        <div class="d-none d-md-block">
          <div class="table-responsive table-wrapper3" id="tabla-ot" style="max-height:70vh; overflow-y:auto;">
  <table class="table border mb-0 table-hover table-sm table-striped" id="tablaDatosOt">
              <thead class="table-light fw-semibold">
                <tr class="align-middle">
                  <th class="clearfix">#</th>
                  <th class="clearfix">Fecha</th>
                  <th class="clearfix">Codigo</th>
                  <th class="clearfix">Nombre Trabajo</th>
                  <th class="text-center col-auto" colspan="4">Acciones</th>
                </tr>
              </thead>
              <tbody>
    ';

    /* =========================
       MÓVIL: CARDS
       (reutiliza .tool-card / .tool-cards)
    ========================= */
    $cards = '
        <div class="d-md-none">
          <div class="tool-cards" id="toolCardsOt">
    ';

    if ($total >= 1) {
      $contador = 1;

      foreach ($datos as $rows) {

        $fecha = $this->ordenarFecha($rows['fecha']);
        $estadoNombre = !empty($rows['nombre_estado']) ? $rows['nombre_estado'] : '—';
        $estadoColor = !empty($rows['color']) ? $rows['color'] : '#6B7280'; // gris fallback

        /* ---------- FILA TABLA ---------- */
        $tabla .= '
              <tr class="align-middle">
                <td class="clearfix col-p"><div><b>' . $contador . '</b></div></td>
                <td class="col-p6"><div class="clearfix"><div><b>' . $fecha . '</b></div></div></td>
                <td class=""><div class="clearfix"><div><b>' . $rows['n_ot'] . '</b></div></div></td>
                <td><div class="clearfix"><div><b>' . $rows['nombre_trab'] . '</b></div></div></td>

             

            

                <td class="col-p">
                  <a href="#" title="Detalles Orden" id="detalleot" class="btn btn-info text-white"
                     data-bs-toggle="modal" data-bs-target="#detallesOt" data-bs-id="' . $rows['n_ot'] . '">
                    <i class="bi bi-card-list"></i>
                  </a>
                </td>

                <!-- DESKTOP: botón herramientas -->
                <td class="col-p">
                  <a href="#"
                    title="Agregar Herramienta"
                    class="btn btn-success js-open-herr-ot"
                    data-bs-toggle="modal"
                    data-bs-target="#ModificarHerrOt"
                    data-bs-id="' . $rows['n_ot'] . '">
                    <i class="bi bi-tools"></i>
                  </a>
                </td>

                <td class="col-p">
                  <a href="#" title="Modificar O.T." class="btn btn-warning text-dark"
                     data-bs-toggle="modal" data-bs-target="#ventanaModalModificarOt" data-bs-id="' . $rows['n_ot'] . '">
                    <i class="bi bi-pencil text-white"></i>
                  </a>
                </td>

                <td class="col-p">
                  <form class="FormularioAjax" action="' . APP_URL . 'app/ajax/otAjax.php" method="POST">
                    <input type="hidden" name="modulo_ot" value="eliminar">
                    <input type="hidden" name="miembro_id" value="' . $rows['n_ot'] . '">
                    <button type="submit" class="btn btn-danger" title="Eliminar">
                      <i class="bi bi-trash"></i>
                    </button>
                  </form>
                </td>
              </tr>
            ';

        /* ---------- CARD MÓVIL ---------- */
        $cards .= '
              <div class="tool-card">
                <div class="tool-card-head">
                  <span class="tool-code">#' . $contador . ' • O.T.: ' . $rows['n_ot'] . '</span>
                  
                </div>

                <div class="tool-body">
                  <div class="tool-row">
                    <div class="tool-label">Fecha</div>
                    <div class="tool-value">' . $fecha . '</div>
                  </div>

                  <div class="tool-row">
                    <div class="tool-label">Trabajo</div>
                    <div class="tool-value">' . $rows['nombre_trab'] . '</div>
                  </div>

                  <div class="tool-actions">                   
                    <a href="#" title="Detalles Orden" id="detalleot" class="btn btn-info text-white btn-sm"
                       data-bs-toggle="modal" data-bs-target="#detallesOt" data-bs-id="' . $rows['n_ot'] . '">
                      <i class="bi bi-card-list"></i>
                    </a>

                    <!-- MÓVIL: botón herramientas -->
<a href="#"
   title="Agregar Herramienta"
   class="btn btn-success btn-sm js-open-herr-ot"
   data-bs-toggle="modal"
   data-bs-target="#ModificarHerrOt"
   data-bs-id="' . $rows['n_ot'] . '">
  <i class="bi bi-tools"></i>
</a>

                    <a href="#" title="Modificar O.T." class="btn btn-warning text-dark btn-sm"
                       data-bs-toggle="modal" data-bs-target="#ventanaModalModificarOt" data-bs-id="' . $rows['n_ot'] . '">
                      <i class="bi bi-pencil text-white"></i>
                    </a>

                    <form class="FormularioAjax d-inline" action="' . APP_URL . 'app/ajax/otAjax.php" method="POST">
                      <input type="hidden" name="modulo_ot" value="eliminar">
                      <input type="hidden" name="miembro_id" value="' . $rows['n_ot'] . '">
                      <button type="submit" class="btn btn-danger btn-sm" title="Eliminar">
                        <i class="bi bi-trash"></i>
                      </button>
                    </form>
                  </div>
                </div>
              </div>
            ';

        $contador++;
      }
    } else {

      $tabla .= '
          <tr class="align-middle">
            <td class="text-center" colspan="10">No hay registros en el sistema</td>
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

    $tabla .= '</tbody></table></div></div>';  // cierra tabla desktop
    $cards .= '</div></div>';                  // cierra cards móvil

    $tabla .= $cards . '</div>';               // une ambos y cierra wrapper

    return $tabla;
  }

  /* LISTAR DETALLES (sin onclick; usa data-* + clases js-*) */
  public function listarDetalles($n_ot = null)
  {
    if ($n_ot === null) {
      $n_ot = $_GET['n_ot'] ?? $_POST['n_ot'] ?? null;
    }

    if (empty($n_ot)) {
      return '
        <div class="d-md-none">
          <div class="tool-cards" id="detalleCards">
            <div class="tool-card">
              <div class="tool-card-head">
                <span class="tool-code">Sin O.T.</span>
                <span>—</span>
              </div>
              <div class="tool-body">
                <div class="tool-row" style="border-bottom:0;">
                  <div class="tool-label">Estado</div>
                  <div class="tool-value">Seleccione una O.T. para ver sus detalles</div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="d-none d-md-block">
          <div class="table-responsive table-wrapper3">
            <table class="table border mb-0 table-hover table-sm table-striped" id="tablaDetalles">
              <thead class="table-light fw-semibold">
                <tr class="align-middle">
                  <th>#</th>
                  <th>Estado</th>
                  <th>Fecha</th>
                  <th>Descripción</th>
                  <th class="text-center" colspan="2">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr class="align-middle">
                  <td class="text-center" colspan="6">Seleccione una O.T. para ver sus detalles</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>';
    }

    $consulta_datos = "
      SELECT " . $this->columnasTablaSql('detalle_orden', 'd') . ", e.nombre_estado, e.color
      FROM detalle_orden d
      LEFT JOIN estado_ot e ON d.id_ai_estado = e.id_ai_estado
      WHERE d.n_ot = :n_ot
      ORDER BY d.id_ai_detalle DESC
    ";

    $stmt  = $this->ejecutarConsultaConParametros($consulta_datos, [':n_ot' => $n_ot]);
    $datos = $stmt->fetchAll();

    $tabla = '
      <div class="d-none d-md-block">
        <div class="table-responsive table-wrapper3">
          <table class="table border mb-0 table-hover table-sm table-striped" id="tablaDetalles">
            <thead class="table-light fw-semibold">
              <tr class="align-middle">
                <th>#</th>
                <th>Estado</th>
                <th>Fecha</th>
                <th>Descripción</th>
                <th class="text-center" colspan="2">Acciones</th>
              </tr>
            </thead>
            <tbody>
    ';

    $cards = '
      <div class="d-md-none">
        <div class="tool-cards" id="detalleCards">
    ';

    if (!empty($datos)) {
      $contador = 1;

      foreach ($datos as $r) {
        $estado = htmlspecialchars($r['nombre_estado'] ?? '—', ENT_QUOTES, 'UTF-8');
        $color  = htmlspecialchars($r['color'] ?? '#6B7280', ENT_QUOTES, 'UTF-8');
        $fechaShow = !empty($r['fecha']) ? htmlspecialchars($this->ordenarFecha($r['fecha']), ENT_QUOTES, 'UTF-8') : '—';
        $desc   = htmlspecialchars($r['descripcion'] ?? '—', ENT_QUOTES, 'UTF-8');

        $idDetalleAttr = htmlspecialchars((string)($r['id_ai_detalle'] ?? ''), ENT_QUOTES, 'UTF-8');
        $fechaAttr     = htmlspecialchars((string)($r['fecha'] ?? ''), ENT_QUOTES, 'UTF-8');
        $otAttr        = htmlspecialchars((string)($r['n_ot'] ?? $n_ot), ENT_QUOTES, 'UTF-8');

        $btnVer = '
              <button type="button" class="btn btn-info text-white btn-sm js-ver-detalle" title="Ver"
                data-id="' . $idDetalleAttr . '"
                data-fecha="' . $fechaAttr . '"
                data-ot="' . $otAttr . '">
                <i class="bi bi-eye"></i>
              </button>
            ';

        $btnDel = '
              <button type="button" class="btn btn-danger btn-sm js-del-detalle" title="Eliminar"
                data-id="' . $idDetalleAttr . '"
                data-fecha="' . $fechaAttr . '"
                data-ot="' . $otAttr . '">
                <i class="bi bi-trash"></i>
              </button>
            ';

        $tabla .= '
              <tr class="align-middle">
                <td class="col-p"><b>' . $contador . '</b></td>
                <td><span class="badge" style="background:' . $color . ';">' . $estado . '</span></td>
                <td><b>' . $fechaShow . '</b></td>
                <td>' . $desc . '</td>
                <td class="text-center col-p">' . $btnVer . '</td>
                <td class="text-center col-p">' . $btnDel . '</td>
              </tr>
            ';

        $cards .= '
              <div class="tool-card">
                <div class="tool-card-head">
                  <span class="tool-code">#' . $contador . ' • ' . $fechaShow . '</span>
                  <span class="badge" style="background:' . $color . ';">' . $estado . '</span>
                </div>

                <div class="tool-body">
                  <div class="tool-row">
                    <div class="tool-label">Descripción</div>
                    <div class="tool-value">' . $desc . '</div>
                  </div>

                  <div class="tool-actions">
                    ' . $btnVer . '
                    ' . $btnDel . '
                  </div>
                </div>
              </div>
            ';

        $contador++;
      }
    } else {
      $tabla .= '
          <tr class="align-middle">
            <td class="text-center" colspan="6">No hay registros en el sistema</td>
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

    return $tabla . $cards;
  }

  /**
   * Genera un combo de opciones de miembros según el tipo especificado.
   *
   * @param int $tipo El tipo de miembro para el cual se generará el combo.
   * @return string El HTML del combo de opciones.
   */

  private function estado($estado)
  {
    $std = 'SIN DETALLE';
    if ($estado != '') {
      $std = $estado;
    }
    return $std;
  }

  private function color($estado)
  {
    $std = '';
    if ($estado != '') {
      $std = $estado;
    }
    return $std;
  }

  public function listarComboOtControlador($tipo)
  {

    // Variable para almacenar el HTML del combo
    $combo = '';

    // Consulta para obtener los datos de los miembros según el tipo especificado
    $consulta_datos = "SELECT id_miembro, nombre_miembro, tipo_miembro FROM miembro WHERE tipo_miembro = $tipo and std_reg=1";

    // Ejecutar la consulta para obtener los datos de los miembros
    $datos = $this->ejecutarConsulta($consulta_datos);
    $datos = $datos->fetchAll();

    // Comprobar el tipo de miembro para determinar la etiqueta del combo
    if ($tipo == 1) {
      // Si el tipo es 1, el combo es para el responsable de control de falla
      $combo .= '
                    <select class="form-select" id="ccf" name="ccf" aria-label="Default select example">
                        <option value="">Seleccionar</option>
                ';
    } else {
      // Si el tipo no es 1, el combo es para el responsable de control de operaciones
      $combo .= '
                    <select class="form-select" id="cco" name="cco" aria-label="Default select example">
                        <option value="">Seleccionar</option>
                ';
    }

    // Comprobar si hay miembros disponibles para mostrar en el combo
    if (count($datos) > 0) {

      // Si hay miembros disponibles, iterar sobre ellos y agregar opciones al combo
      foreach ($datos as $rows) {
        $combo .= '
                        <option value="' . $rows['id_miembro'] . '">' . $rows['nombre_miembro'] . '</option>
                    ';
      }
    }

    // Cerrar el combo y devolver el HTML generado
    $combo .= '</select>';

    return $combo;
  }

  public function listarComboTecControlador()
  {

    // Variable para almacenar el HTML del combo
    $combo = '';

    // Consulta para obtener los datos de los miembros según el tipo especificado
    $consulta_datos = "SELECT
        u.id_empleado AS id_user,
        e.nombre_empleado AS user
      FROM user_system u
      INNER JOIN empleado e ON e.id_empleado = u.id_empleado
      WHERE u.std_reg = 1
        AND e.std_reg = 1
      ORDER BY e.nombre_empleado ASC";

    // Ejecutar la consulta para obtener los datos de los miembros
    $datos = $this->ejecutarConsulta($consulta_datos);
    $datos = $datos->fetchAll();

    // Comprobar el tipo de miembro para determinar la etiqueta del combo

    // Si el tipo no es 1, el combo es para el responsable de control de operaciones
    $combo .= '
                <select class="form-select" id="tec" name="tec" aria-label="Default select example">
                    <option value="">Seleccionar</option>
            ';

    // Comprobar si hay miembros disponibles para mostrar en el combo
    if (count($datos) > 0) {

      // Si hay miembros disponibles, iterar sobre ellos y agregar opciones al combo
      foreach ($datos as $rows) {
        $combo .= '
                        <option value="' . $rows['id_user'] . '">' . $rows['user'] . '</option>
                    ';
      }
    }

    // Cerrar el combo y devolver el HTML generado
    $combo .= '</select>';

    return $combo;
  }

  public function listarComboTurnoControlador()
  {

    // Variable para almacenar el HTML del combo
    $combo = '';

    // Consulta para obtener los datos de los miembros según el tipo especificado
    $consulta_datos = 'SELECT id_ai_turno, nombre_turno FROM turno_trabajo WHERE std_reg=1';

    // Ejecutar la consulta para obtener los datos de los miembros
    $datos = $this->ejecutarConsulta($consulta_datos);
    $datos = $datos->fetchAll();

    // Comprobar el tipo de miembro para determinar la etiqueta del combo

    // Si el tipo no es 1, el combo es para el responsable de control de operaciones
    $combo .= '
                <select class="form-select" id="turno" name="turno" aria-label="Default select example">
                <option value="">Seleccionar</option>
            ';

    // Comprobar si hay miembros disponibles para mostrar en el combo
    if (count($datos) > 0) {

      // Si hay miembros disponibles, iterar sobre ellos y agregar opciones al combo
      foreach ($datos as $rows) {
        $combo .= '
                        <option value="' . $rows['id_ai_turno'] . '">' . $rows['nombre_turno'] . '</option>
                    ';
      }
    }

    // Cerrar el combo y devolver el HTML generado
    $combo .= '</select>';

    return $combo;
  }

  public function listarComboEstadoControlador()
  {

    // Variable para almacenar el HTML del combo
    $combo = '';

    // Consulta para obtener los datos de los miembros según el tipo especificado
    $consulta_datos = 'SELECT id_ai_estado, nombre_estado FROM estado_ot WHERE std_reg=1';

    // Ejecutar la consulta para obtener los datos de los miembros
    $datos = $this->ejecutarConsulta($consulta_datos);
    $datos = $datos->fetchAll();

    // Comprobar el tipo de miembro para determinar la etiqueta del combo

    // Si el tipo no es 1, el combo es para el responsable de control de operaciones
    $combo .= '                
                <select class="form-select" id="status" name="status" aria-label="Default select example">
                    <option value="">Seleccionar</option>
            ';

    // Comprobar si hay miembros disponibles para mostrar en el combo
    if (count($datos) > 0) {

      // Si hay miembros disponibles, iterar sobre ellos y agregar opciones al combo
      foreach ($datos as $rows) {
        $combo .= '
                        <option value="' . $rows['id_ai_estado'] . '" >' . $rows['nombre_estado'] . '</option>
                    ';
      }
    }

    // Cerrar el combo y devolver el HTML generado
    $combo .= '</select>';

    return $combo;
  }

  public function listarComboAreaControlador()
  {

    // Variable para almacenar el HTML del combo
    $combo = '';

    // Consulta para obtener los datos de los miembros según el tipo especificado
    $consulta_datos = 'SELECT id_ai_area, nombre_area, nomeclatura FROM area_trabajo WHERE std_reg=1';

    // Ejecutar la consulta para obtener los datos de los miembros
    $datos = $this->ejecutarConsulta($consulta_datos);
    $datos = $datos->fetchAll();

    // Comprobar el tipo de miembro para determinar la etiqueta del combo

    // Si el tipo no es 1, el combo es para el responsable de control de operaciones
    $combo .= '
        <select class="form-select" id="area" name="area" aria-label="Default select example">
        <option value="">Seleccionar</option>
            ';

    // Comprobar si hay miembros disponibles para mostrar en el combo
    if (count($datos) > 0) {

      // Si hay miembros disponibles, iterar sobre ellos y agregar opciones al combo
      foreach ($datos as $rows) {
        $combo .= '
                        <option value="' . $rows['nomeclatura'] . '">' . $rows['nombre_area'] . '</option>
                    ';
      }
    }

    // Cerrar el combo y devolver el HTML generado
    $combo .= '</select>';

    return $combo;
  }

  public function listarComboSitioControlador()
  {

    // Variable para almacenar el HTML del combo
    $combo = '';

    // Consulta para obtener los datos de los miembros según el tipo especificado
    $consulta_datos = 'SELECT id_ai_sitio, nombre_sitio FROM sitio_trabajo WHERE std_reg=1';

    // Ejecutar la consulta para obtener los datos de los miembros
    $datos = $this->ejecutarConsulta($consulta_datos);
    $datos = $datos->fetchAll();

    // Comprobar el tipo de miembro para determinar la etiqueta del combo

    // Si el tipo no es 1, el combo es para el responsable de control de operaciones
    $combo .= '
        <select class="form-select" id="sitio" name="sitio" aria-label="Default select example">
                    <option value="">Seleccionar</option>
            ';

    // Comprobar si hay miembros disponibles para mostrar en el combo
    if (count($datos) > 0) {

      // Si hay miembros disponibles, iterar sobre ellos y agregar opciones al combo
      foreach ($datos as $rows) {
        $combo .= '
                        <option value="' . $rows['id_ai_sitio'] . '">' . $rows['nombre_sitio'] . '</option>
                    ';
      }
    }

    // Cerrar el combo y devolver el HTML generado
    $combo .= '</select>';

    return $combo;
  }

  public function listarComboUserControlador()
  {

    // Variable para almacenar el HTML del combo
    $combo = '';

    // Consulta para obtener los datos de los miembros según el tipo especificado
    $consulta_datos = "SELECT
        u.id_empleado AS id_user,
        e.nombre_empleado AS user
      FROM user_system u
      INNER JOIN empleado e ON e.id_empleado = u.id_empleado
      WHERE u.std_reg = 1
        AND e.std_reg = 1
      ORDER BY e.nombre_empleado ASC";

    // Ejecutar la consulta para obtener los datos de los miembros
    $datos = $this->ejecutarConsulta($consulta_datos);
    $datos = $datos->fetchAll();

    // Comprobar el tipo de miembro para determinar la etiqueta del combo
    // Si el tipo es 1, el combo es para el responsable de control de falla
    $combo .= '
                <select class="form-select" id="user" name="user" aria-label="Default select example">
                    <option value="">Seleccionar</option>
            ';

    // Comprobar si hay miembros disponibles para mostrar en el combo
    if (count($datos) > 0) {

      // Si hay miembros disponibles, iterar sobre ellos y agregar opciones al combo
      foreach ($datos as $rows) {
        $combo .= '
                        <option value="' . $rows['id_user'] . '">'  . $rows['user'] . '</option>
                    ';
      }
    }

    // Cerrar el combo y devolver el HTML generado
    $combo .= '</select>';

    return $combo;
  }

  public function eliminarOtControlador()
  {
    // Permiso (ajusta la key si en tu sistema se llama distinto)
    $this->requirePerm('perm_ot_delete');

    $id = $this->limpiarCadena($_POST['miembro_id'] ?? '');

    if ($id === '') {
      return json_encode([
        'tipo'   => 'simple',
        'titulo' => 'Ocurrió un error inesperado',
        'texto'  => 'No se recibió el código de la O.T.',
        'icono'  => 'error'
      ], JSON_UNESCAPED_UNICODE);
    }

    // Evita eliminar OT “protegida” (si aplica)
    if ($id === '1') {
      return json_encode([
        'tipo'   => 'simple',
        'titulo' => 'Ocurrió un error inesperado',
        'texto'  => 'No podemos eliminar este registro',
        'icono'  => 'error'
      ], JSON_UNESCAPED_UNICODE);
    }

    // Verificar OT (tabla correcta: orden_trabajo)
    $st = $this->ejecutarConsultaParams(
      "SELECT n_ot, nombre_trab FROM orden_trabajo WHERE n_ot = :id AND std_reg = '1' LIMIT 1",
      [':id' => $id]
    );

    if (!$st || $st->rowCount() <= 0) {
      return json_encode([
        'tipo'   => 'simple',
        'titulo' => 'Ocurrió un error inesperado',
        'texto'  => 'No hemos encontrado la O.T. en el sistema',
        'icono'  => 'error'
      ], JSON_UNESCAPED_UNICODE);
    }

    $ot = $st->fetch(\PDO::FETCH_ASSOC);

    // Soft delete recomendado (mantiene FK/history)
    $ok = $this->actualizarDatos(
      "orden_trabajo",
      [
        ["campo_nombre" => "std_reg", "campo_marcador" => ":std", "campo_valor" => 0],
      ],
      [
        "condicion_campo"    => "n_ot",
        "condicion_marcador" => ":id",
        "condicion_valor"    => $id
      ]
    );

    if ($ok) {
      return json_encode([
        'tipo'   => 'recargar',
        'titulo' => 'O.T. Eliminada',
        'texto'  => 'La O.T. ' . ($ot['n_ot'] ?? $id) . ' (' . ($ot['nombre_trab'] ?? '') . ') ha sido eliminada con éxito',
        'icono'  => 'success'
      ], JSON_UNESCAPED_UNICODE);
    }

    return json_encode([
      'tipo'   => 'simple',
      'titulo' => 'Ocurrió un error inesperado',
      'texto'  => 'No se pudo eliminar la O.T., por favor intente nuevamente',
      'icono'  => 'error'
    ], JSON_UNESCAPED_UNICODE);
  }
}

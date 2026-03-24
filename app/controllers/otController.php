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

    # VerificaciÃƒÂ³n de campos obligatorios #
    if ($area == '' || $codigo == '' || $fecha == '' || $nombre == '' || $semana == '' || $mes == 'Seleccionar' || $sitio == 'Seleccionar') {
      // Si algÃƒÂºn campo obligatorio estÃƒÂ¡ vacÃƒÂ­o, se devuelve una alerta de error
      $alerta = [
        'tipo' => 'simple',
        'titulo' => 'Ocurrio un error inesperado',
        'texto' => 'No has llenado todos los campos que son obligatorios',
        'icono' => 'error'
      ];
      return json_encode($alerta);
      exit();
    }

    # Verificar la integridad de los datos de cÃƒÂ³digo #
    if ($this->verificarDatos('^[0-9]{1,10}$', $codigo)) {
      #Si el formato del cÃƒÂ³digo no es vÃƒÂ¡lido, se devuelve una alerta de error
      $alerta = [
        'tipo' => 'simple',
        'titulo' => 'Ocurrio un error inesperado',
        'texto' => 'El codigo no cumple con el formato solicitado',
        'icono' => 'error'
      ];
      return json_encode($alerta);
      exit();
    }

    # Verificar la integridad de los datos de nombre #
    if ($this->verificarDatos('[a-zA-ZÃƒÂ¡ÃƒÂ©ÃƒÂ­ÃƒÂ³ÃƒÂºÃƒÂÃƒâ€°ÃƒÂÃƒâ€œÃƒÅ¡ÃƒÂ±Ãƒâ€˜ ]{3,60}', $nombre)) {
      #Si el formato del nombre no es vÃƒÂ¡lido, se devuelve una alerta de error
      $alerta = [
        'tipo' => 'simple',
        'titulo' => 'Ocurrio un error inesperado',
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
        'titulo' => 'Ocurrio un error inesperado',
        'texto' => 'El codigo ingresado ya existe en los registros',
        'icono' => 'error'
      ];
      return json_encode($alerta);
      exit();
    }
    $stmtArea = $this->ejecutarConsultaConParametros(
      "SELECT " . $this->columnasTablaSql('area_trabajo') . " FROM area_trabajo WHERE nomeclatura = :area LIMIT 1",
      [':area' => $area]
    );
    $datosArea = $stmtArea ? $stmtArea->fetch(\PDO::FETCH_ASSOC) : null;

    if (!$datosArea) {
      return json_encode([
        'tipo' => 'simple',
        'titulo' => 'Ocurrio un error inesperado',
        'texto' => 'El area seleccionada no existe o no esta disponible',
        'icono' => 'error'
      ]);
    }

    try {
      $resultado = $this->ejecutarProcedimientoFila(
        'CALL sp_ot_crear(:n_ot, :id_ai_area, :id_user, :id_ai_sitio, :id_ai_estado, :nombre_trab, :fecha, :semana, :mes)',
        [
          ':n_ot' => $codigof,
          ':id_ai_area' => (int)$datosArea['id_ai_area'],
          ':id_user' => (string)($_SESSION['id_user'] ?? $_SESSION['id'] ?? ''),
          ':id_ai_sitio' => (int)$sitio,
          ':id_ai_estado' => $this->estadoInicialOtId(),
          ':nombre_trab' => mb_strtoupper($nombre, 'UTF-8'),
          ':fecha' => $fecha,
          ':semana' => $semana,
          ':mes' => $mes,
        ]
      );

      if ($resultado !== null) {
        $alerta = [
          'tipo' => 'limpiar',
          'titulo' => 'Orden Registrada',
          'texto' => 'La orden de trabajo se ha registrado con exito',
          'icono' => 'success'
        ];
      } else {
        $alerta = [
          'tipo' => 'simple',
          'titulo' => 'Ocurrio un error inesperado',
          'texto' => 'La orden de trabajo no se pudo registrar correctamente',
          'icono' => 'error'
        ];
      }
    } catch (\Throwable $e) {
      $this->registrarLogSistema('ERROR', 'ot.registrar', 'Error al registrar O.T. mediante procedimiento almacenado.', [
        'n_ot' => $codigof,
        'exception' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine(),
      ]);

      $alerta = [
        'tipo' => 'simple',
        'titulo' => 'Ocurrio un error inesperado',
        'texto' => 'La orden de trabajo no se pudo registrar correctamente: ' . $e->getMessage(),
        'icono' => 'error'
      ];
    }

    return json_encode($alerta);
  }

  public function modificarOtControlador()
  {
    #Se obtienen y limpian los datos del formulario
    $id = $this->limpiarCadena($_POST['id']);

    if ($id !== '' && $this->otEstaFinalizada($id)) {
      return json_encode([
        'tipo' => 'simple',
        'titulo' => 'O.T. finalizada',
        'texto' => 'La O.T. ya esta finalizada. Solo se permite eliminarla o generar su reporte.',
        'icono' => 'info'
      ], JSON_UNESCAPED_UNICODE);
    }

    $fecha   = $this->limpiarCadena($_POST['fecha1']);
    $nombre = $this->limpiarCadena($_POST['nombre']);
    $semana = $this->limpiarCadena($_POST['semana1']);
    $mes   = $this->limpiarCadena($_POST['mes1']);
    $sitio = $this->limpiarCadena($_POST['sitio']);

    #variable codigof
    $codigof = '';

    # VerificaciÃƒÂ³n de campos obligatorios #
    if ($fecha == '' || $nombre == '' || $semana == '' || $mes == 'Seleccionar' || $sitio == 'Seleccionar') {
      // Si algÃƒÂºn campo obligatorio estÃƒÂ¡ vacÃƒÂ­o, se devuelve una alerta de error
      $alerta = [
        'tipo' => 'simple',
        'titulo' => 'Ocurrio un error inesperado',
        'texto' => 'No has llenado todos los campos que son obligatorios',
        'icono' => 'error'
      ];
      return json_encode($alerta);
      exit();
    }

    # Verificar la integridad de los datos de nombre #
    if ($this->verificarDatos('^[a-zA-Z0-9ÃƒÂ¡ÃƒÂ©ÃƒÂ­ÃƒÂ³ÃƒÂºÃƒÂÃƒâ€°ÃƒÂÃƒâ€œÃƒÅ¡ÃƒÂ±Ãƒâ€˜()\- ]{3,60}$', $nombre)) {
      #Si el formato del nombre no es vÃƒÂ¡lido, se devuelve una alerta de error
      $alerta = [
        'tipo' => 'simple',
        'titulo' => 'Ocurrio un error inesperado',
        'texto' => 'El nombre de trabajo no cumple con el formato solicitado',
        'icono' => 'error'
      ];
      return json_encode($alerta);
      exit();
    }

    # DefiniciÃƒÂ³n de un array asociativo $miembro_datos_reg que contiene los datos del miembro a registrar
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
        'titulo' => 'Ocurrio un error inesperado',
        'texto' => 'Ha ocurrido un error durante el registro!',
        'icono' => 'error'
      ];
    }
    return json_encode($alerta);
  }

  protected function hasPerm(string $permKey): bool
  {
    $perms = $_SESSION['permisos'] ?? [];
    return !empty($perms[$permKey]) && (int)$perms[$permKey] === 1;
  }

  private function canCambiarEstadoOt(): bool
  {
    return $this->hasPerm('perm_ot_edit') || $this->hasPerm('perm_ot_add_detalle');
  }

  private function detallePkOt(): string
  {
    return $this->tableHasColumn('detalle_orden', 'id_ai_detalle') ? 'id_ai_detalle' : 'id_detalle';
  }

  private function estadoFinalOtId(): int
  {
    return $this->primerEstadoFinalOtId();
  }

  private function estadoInicialOtId(): int
  {
    $stmt = $this->ejecutarConsultaConParametros(
      "SELECT id_ai_estado
       FROM estado_ot
       WHERE std_reg = 1
       ORDER BY CASE
         WHEN UPPER(nombre_estado) = 'NO EJECUTADA' THEN 1
         WHEN UPPER(nombre_estado) = 'RE-PROGRAMADA' THEN 2
         WHEN UPPER(nombre_estado) = 'SUSPENDIDA' THEN 3
         WHEN " . $this->estadoOtBloqueaOtExpr() . " = 1 THEN 99
         ELSE 10
       END,
       id_ai_estado ASC
       LIMIT 1"
    );

    if ($stmt && $stmt->rowCount() > 0) {
      return (int)$stmt->fetchColumn();
    }

    $primerEstado = $this->ejecutarConsultaConParametros(
      "SELECT id_ai_estado
       FROM estado_ot
       WHERE std_reg = 1
       ORDER BY id_ai_estado ASC
       LIMIT 1"
    );

    if ($primerEstado && $primerEstado->rowCount() > 0) {
      return (int)$primerEstado->fetchColumn();
    }

    return 0;
  }

  private function herramientasActivasOt(string $nOt): int
  {
    $stmt = $this->ejecutarConsultaConParametros(
      "SELECT COALESCE(SUM(cantidadot), 0)
       FROM herramientaot
       WHERE n_ot = :n_ot
         AND " . $this->herramientaOtEstadoExpr() . " <> 'LIBERADA'",
      [':n_ot' => $nOt]
    );

    return $stmt ? (int)$stmt->fetchColumn() : 0;
  }

  private function ordenTrabajoUsaBanderaFinalizacion(): bool
  {
    return $this->tableHasColumn('orden_trabajo', 'ot_finalizada');
  }

  private function ordenTrabajoUsaEstadoOt(): bool
  {
    return $this->tableHasColumn('orden_trabajo', 'id_ai_estado');
  }

  private function otEstaFinalizada(string $nOt): bool
  {
    $columns = ['n_ot'];
    if ($this->ordenTrabajoUsaBanderaFinalizacion()) {
      $columns[] = 'COALESCE(ot_finalizada, 0) AS ot_finalizada';
    }
    if ($this->ordenTrabajoUsaEstadoOt()) {
      $columns[] = 'ot.id_ai_estado';
    }

    $stmt = $this->ejecutarConsultaConParametros(
      "SELECT " . implode(', ', $columns) . ",
              " . $this->estadoOtLiberaHerramientasExpr('eo') . " AS estado_libera_herramientas,
              " . $this->estadoOtBloqueaOtExpr('eo') . " AS estado_bloquea_ot
       FROM orden_trabajo ot
       LEFT JOIN estado_ot eo ON eo.id_ai_estado = ot.id_ai_estado
       WHERE n_ot = :n_ot
       LIMIT 1",
      [':n_ot' => $nOt]
    );

    if (!$stmt || $stmt->rowCount() <= 0) {
      return false;
    }

    $row = $stmt->fetch(\PDO::FETCH_ASSOC);
    if ((int)($row['ot_finalizada'] ?? 0) === 1) {
      return true;
    }

    return (int)($row['estado_bloquea_ot'] ?? 0) === 1
      || ($this->ordenTrabajoUsaEstadoOt() && $this->estadoOtEsFinalPorId((int)($row['id_ai_estado'] ?? 0)));
  }

  private function otEstadoActual(string $nOt): ?array
  {
    $select = [
      'ot.n_ot',
      'ot.nombre_trab',
      'ot.id_user',
      'ot.std_reg'
    ];

    if ($this->ordenTrabajoUsaBanderaFinalizacion()) {
      $select[] = 'COALESCE(ot.ot_finalizada, 0) AS ot_finalizada';
      $select[] = 'ot.fecha_finalizacion';
      $select[] = 'ot.id_user_finaliza';
    }

    if ($this->ordenTrabajoUsaEstadoOt()) {
      $select[] = 'ot.id_ai_estado';
      $select[] = 'eo.nombre_estado';
      $select[] = 'eo.color';
      $select[] = $this->estadoOtLiberaHerramientasExpr('eo') . ' AS estado_libera_herramientas';
      $select[] = $this->estadoOtBloqueaOtExpr('eo') . ' AS estado_bloquea_ot';
    }

    $stmt = $this->ejecutarConsultaConParametros(
      "SELECT " . implode(', ', $select) . "
       FROM orden_trabajo ot
       LEFT JOIN estado_ot eo ON eo.id_ai_estado = ot.id_ai_estado
       WHERE ot.n_ot = :n_ot
         AND ot.std_reg = 1
       LIMIT 1",
      [':n_ot' => $nOt]
    );

    if (!$stmt || $stmt->rowCount() <= 0) {
      return null;
    }

    return $stmt->fetch(\PDO::FETCH_ASSOC);
  }

  private function estadoOtVisual(string $estadoNombre, string $estadoColor, bool $finalizada): array
  {
    $label = trim($estadoNombre) !== '' && trim($estadoNombre) !== '-' ? trim($estadoNombre) : ($finalizada ? 'FINALIZADA' : 'SIN ESTADO');
    $color = trim($estadoColor) !== '' ? trim($estadoColor) : '#6B7280';

    return [
      'label' => mb_strtoupper($label, 'UTF-8'),
      'color' => $color,
    ];
  }

  private function renderEstadoOtIndicator(string $estadoNombre, string $estadoColor, bool $finalizada): string
  {
    $visual = $this->estadoOtVisual($estadoNombre, $estadoColor, $finalizada);
    $label = htmlspecialchars($visual['label'], ENT_QUOTES, 'UTF-8');
    $color = htmlspecialchars($visual['color'], ENT_QUOTES, 'UTF-8');

    return '<span class="ot-status-indicator" style="--ot-status-color:' . $color . ';">'
      . '<span class="ot-status-dot"></span>'
      . '<span>' . $label . '</span>'
      . '</span>';
  }

  private function renderOtActionButtons(string $nOt, int $estadoId, string $estadoNombre, bool $finalizada, bool $mobile = false): array
  {
    $btnClass = $mobile ? 'btn btn-info text-white btn-sm' : 'btn btn-info text-white';
    $btnTools = $mobile ? 'btn btn-success btn-sm js-open-herr-ot' : 'btn btn-success js-open-herr-ot';
    $btnWarn = $mobile ? 'btn btn-warning text-dark btn-sm' : 'btn btn-warning text-dark';
    $btnDanger = $mobile ? 'btn btn-danger btn-sm' : 'btn btn-danger';
    $btnSecondary = $mobile ? 'btn btn-secondary btn-sm' : 'btn btn-secondary';
    $btnPrimary = $mobile ? 'btn btn-primary btn-sm js-preview-ot-report' : 'btn btn-primary js-preview-ot-report';
    $btnState = $mobile ? 'btn btn-outline-primary btn-sm js-cambiar-estado-ot' : 'btn btn-outline-primary js-cambiar-estado-ot';

    $detalleTitulo = $finalizada ? 'Ver detalles' : 'Detalles Orden';
    $detalle = '
      <a href="#" title="' . $detalleTitulo . '" id="detalleot" class="' . $btnClass . '"
         data-bs-toggle="modal" data-bs-target="#detallesOt" data-bs-id="' . $nOt . '">
        <i class="bi bi-card-list"></i>
      </a>';

    $reporte = $this->hasPerm('perm_ot_generar_reporte')
      ? '
      <button type="button" title="Generar reporte" class="' . $btnPrimary . '"
         data-bs-toggle="modal" data-bs-target="#modalPreviewReporteOt" data-bs-ot="' . $nOt . '">
        <i class="bi bi-file-earmark-pdf"></i>
      </button>'
      : '';

    if ($this->hasPerm('perm_herramienta_view') || $this->hasPerm('perm_ot_edit')) {
      if ($finalizada) {
        $herramientas = '
      <button type="button" title="OT finalizada" class="' . $btnSecondary . '" disabled>
        <i class="bi bi-tools"></i>
      </button>';
      } else {
        $herramientas = '
      <a href="#"
        title="Agregar Herramienta"
        class="' . $btnTools . '"
        data-bs-toggle="modal"
        data-bs-target="#ModificarHerrOt"
        data-bs-id="' . $nOt . '">
        <i class="bi bi-tools"></i>
      </a>';
      }
    } else {
      $herramientas = '';
    }

    if ($this->canCambiarEstadoOt()) {
      if ($finalizada) {
        $estado = '
      <button type="button" title="Estado bloqueado" class="' . $btnSecondary . '" disabled>
        <i class="bi bi-lock"></i>
      </button>';
      } else {
        $estado = '
      <button type="button" title="Cambiar estado O.T." class="' . $btnState . '"
        data-ot="' . $nOt . '"
        data-estado-id="' . $estadoId . '"
        data-estado-nombre="' . htmlspecialchars($estadoNombre, ENT_QUOTES, 'UTF-8') . '">
        <i class="bi bi-arrow-repeat"></i>
      </button>';
      }
    } else {
      $estado = '';
    }

    if ($this->hasPerm('perm_ot_edit')) {
      if ($finalizada) {
        $editar = '
      <button type="button" title="O.T. finalizada" class="' . $btnSecondary . '" disabled>
        <i class="bi bi-pencil"></i>
      </button>';
      } else {
        $editar = '
      <a href="#" title="Modificar O.T." class="' . $btnWarn . '"
         data-bs-toggle="modal" data-bs-target="#ventanaModalModificarOt" data-bs-id="' . $nOt . '">
        <i class="bi bi-pencil text-white"></i>
      </a>';
      }
    } else {
      $editar = '';
    }

    $eliminar = $this->hasPerm('perm_ot_delete')
      ? '
      <form class="' . ($mobile ? 'FormularioAjax d-inline' : 'FormularioAjax') . '" action="' . APP_URL . 'app/ajax/otAjax.php" method="POST">
        <input type="hidden" name="modulo_ot" value="eliminar">
        <input type="hidden" name="miembro_id" value="' . $nOt . '">
        <button type="submit" class="' . $btnDanger . '" title="Eliminar">
          <i class="bi bi-trash"></i>
        </button>
      </form>'
      : '';

    return [
      'detalle' => $detalle,
      'reporte' => $reporte,
      'herramientas' => $herramientas,
      'estado' => $estado,
      'editar' => $editar,
      'eliminar' => $eliminar,
    ];
  }


  public function listarOtControlador()
  {
    $tabla = '';
    $consulta_datos = "SELECT
            n_ot,
            fecha,
            nombre_trab,
            id_ai_estado,
            nombre_estado,
            color_estado AS color,
            COALESCE(herramientas_activas, 0) AS herramientas_activas,
            CASE
              WHEN COALESCE(ot_finalizada, 0) = 1 OR COALESCE(bloquea_ot, 0) = 1 THEN 1
              ELSE 0
            END AS ot_finalizada
        FROM vw_ot_resumen
        WHERE std_reg = 1
        ORDER BY n_ot ASC";

    $consulta_total = "SELECT COUNT(1)
        FROM vw_ot_resumen
        WHERE std_reg = 1";

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
                  <th class="clearfix">Estado O.T.</th>
                  <th class="text-center col-auto" colspan="6">Acciones</th>
                </tr>
              </thead>
              <tbody>
    ';

    /* =========================
       MÃƒâ€œVIL: CARDS
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
        $estadoNombre = !empty($rows['nombre_estado']) ? $rows['nombre_estado'] : '-';
        $estadoColor = !empty($rows['color']) ? $rows['color'] : '#6B7280'; // gris fallback
        $estadoId = (int)($rows['id_ai_estado'] ?? 0);
        $otFinalizada = (int)($rows['ot_finalizada'] ?? 0) === 1;
        $estadoIndicator = $this->renderEstadoOtIndicator($estadoNombre, $estadoColor, $otFinalizada);
        $acciones = $this->renderOtActionButtons((string)$rows['n_ot'], $estadoId, $estadoNombre, $otFinalizada, false);
        $accionesMobile = $this->renderOtActionButtons((string)$rows['n_ot'], $estadoId, $estadoNombre, $otFinalizada, true);

        /* ---------- FILA TABLA ---------- */
        $tabla .= '
              <tr class="align-middle">
                <td class="clearfix col-p"><div><b>' . $contador . '</b></div></td>
                <td class="col-p6"><div class="clearfix"><div><b>' . $fecha . '</b></div></div></td>
                <td class=""><div class="clearfix"><div><b>' . $rows['n_ot'] . '</b></div></div></td>
                <td><div class="clearfix"><div><b>' . $rows['nombre_trab'] . '</b></div></div></td>
                <td class="col-p6"><div class="clearfix">' . $estadoIndicator . '</div></td>
                <td class="col-p">' . $acciones['detalle'] . '</td>
                <td class="col-p">' . $acciones['reporte'] . '</td>
                <td class="col-p">' . $acciones['herramientas'] . '</td>
                <td class="col-p">' . $acciones['estado'] . '</td>
                <td class="col-p">' . $acciones['editar'] . '</td>
                <td class="col-p">' . $acciones['eliminar'] . '</td>
              </tr>
            ';

        /* ---------- CARD MOVIL ---------- */
        $cards .= '
              <div class="tool-card">
                <div class="tool-card-head">
                  <span class="tool-code">#' . $contador . ' - O.T.: ' . $rows['n_ot'] . '</span>
                  ' . $estadoIndicator . '
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

                  <div class="tool-row">
                    <div class="tool-label">Estado</div>
                    <div class="tool-value">' . $estadoIndicator . '</div>
                  </div>

                  <div class="tool-actions">
                    ' . $accionesMobile['detalle'] . '
                    ' . $accionesMobile['reporte'] . '
                    ' . $accionesMobile['herramientas'] . '
                    ' . $accionesMobile['estado'] . '
                    ' . $accionesMobile['editar'] . '
                    ' . $accionesMobile['eliminar'] . '
                  </div>
                </div>
              </div>
            ';

        $contador++;
      }
    } else {

      $tabla .= '
          <tr class="align-middle">
            <td class="text-center" colspan="11">No hay registros en el sistema</td>
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
          </div>
        ';
    }

    $tabla .= '</tbody></table></div></div>';  // cierra tabla desktop
    $cards .= '</div></div>';                  // cierra cards movil

    $tabla .= $cards . '</div>';               // une ambos y cierra wrapper

    return $tabla;
  }

  /* LISTAR DETALLES (sin onclick; usa data-* + clases js-*) */
  public function listarDetalles($n_ot = null)
  {
    if ($n_ot === null) {
      $n_ot = $_GET['n_ot'] ?? $_POST['n_ot'] ?? null;
    }

    $otFinalizada = !empty($n_ot) ? $this->otEstaFinalizada((string)$n_ot) : false;

    if (empty($n_ot)) {
      return '
        <div class="d-md-none">
          <div class="tool-cards" id="detalleCards">
            <div class="tool-card">
              <div class="tool-card-head">
                <span class="tool-code">Sin O.T.</span>
                <span>-</span>
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
                  <th>Fecha</th>
                  <th>Descripcion</th>
                  <th>Tecnico</th>
                  <th class="text-center" colspan="3">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr class="align-middle">
                  <td class="text-center" colspan="7">Seleccione una O.T. para ver sus detalles</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>';
    }

    $consulta_datos = "
      SELECT
        id_ai_detalle,
        n_ot,
        fecha_detalle AS fecha,
        descripcion,
        id_user_act,
        COALESCE(NULLIF(usuario_act_nombre, ''), id_user_act) AS user
      FROM vw_ot_detallada
      WHERE n_ot = :n_ot
      ORDER BY id_ai_detalle DESC
    ";

    $stmt  = $this->ejecutarConsultaConParametros($consulta_datos, [':n_ot' => $n_ot]);
    $datos = $stmt ? $stmt->fetchAll(\PDO::FETCH_ASSOC) : [];

    $tabla = '
      <div class="d-none d-md-block">
        <div class="table-responsive table-wrapper3">
          <table class="table border mb-0 table-hover table-sm table-striped" id="tablaDetalles">
            <thead class="table-light fw-semibold">
              <tr class="align-middle">
                <th>#</th>
                <th>Fecha</th>
                <th>Descripcion</th>
                <th>Tecnico</th>
                <th class="text-center" colspan="3">Acciones</th>
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
        $fechaShow = !empty($r['fecha']) ? htmlspecialchars($this->ordenarFecha($r['fecha']), ENT_QUOTES, 'UTF-8') : '-';
        $desc   = htmlspecialchars($r['descripcion'] ?? '-', ENT_QUOTES, 'UTF-8');
        $tecnico = htmlspecialchars($r['user'] ?? $r['id_user_act'] ?? '-', ENT_QUOTES, 'UTF-8');

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

        $btnEdit = $otFinalizada
          ? '
              <button type="button" class="btn btn-secondary btn-sm" title="O.T. bloqueada" disabled>
                <i class="bi bi-pencil"></i>
              </button>
            '
          : '
              <button type="button" class="btn btn-warning text-dark btn-sm js-edit-detalle" title="Editar"
                data-id="' . $idDetalleAttr . '"
                data-fecha="' . $fechaAttr . '"
                data-ot="' . $otAttr . '">
                <i class="bi bi-pencil text-white"></i>
              </button>
            ';

        $btnDel = $otFinalizada
          ? '
              <button type="button" class="btn btn-secondary btn-sm" title="O.T. bloqueada" disabled>
                <i class="bi bi-trash"></i>
              </button>
            '
          : '
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
                <td><b>' . $fechaShow . '</b></td>
                <td>' . $desc . '</td>
                <td>' . $tecnico . '</td>
                <td class="text-center col-p">' . $btnVer . '</td>
                <td class="text-center col-p">' . $btnEdit . '</td>
                <td class="text-center col-p">' . $btnDel . '</td>
              </tr>
            ';

        $cards .= '
              <div class="tool-card">
                <div class="tool-card-head">
                  <span class="tool-code">#' . $contador . ' - ' . $fechaShow . '</span>
                  <span class="badge bg-light text-dark">Detalle</span>
                </div>

                <div class="tool-body">
                  <div class="tool-row">
                    <div class="tool-label">Descripcion</div>
                    <div class="tool-value">' . $desc . '</div>
                  </div>

                  <div class="tool-row">
                    <div class="tool-label">Tecnico</div>
                    <div class="tool-value">' . $tecnico . '</div>
                  </div>

                  <div class="tool-actions">
                    ' . $btnVer . '
                    ' . $btnEdit . '
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
            <td class="text-center" colspan="7">No hay registros en el sistema</td>
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
          </div>
        ';
    }

    $tabla .= '</tbody></table></div></div>';
    $cards .= '</div></div>';

    return $tabla . $cards;
  }

  /**
   * Genera un combo de opciones de miembros segÃƒÂºn el tipo especificado.
   *
   * @param int $tipo El tipo de miembro para el cual se generarÃƒÂ¡ el combo.
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

    // Consulta para obtener los datos de los miembros segÃƒÂºn el tipo especificado
    $consulta_datos = "SELECT
        m.id_miembro,
        COALESCE(NULLIF(e.nombre_empleado, ''), m.nombre_miembro) AS nombre_miembro,
        m.tipo_miembro
      FROM miembro m
      LEFT JOIN empleado e
        ON e.id_empleado = m.id_empleado
      WHERE m.tipo_miembro = $tipo
        AND m.std_reg = 1
      ORDER BY nombre_miembro ASC";

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

    // Consulta para obtener los datos de los miembros segÃƒÂºn el tipo especificado
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

    // Consulta para obtener los datos de los miembros segÃƒÂºn el tipo especificado
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

    // Consulta para obtener los datos de los miembros segÃƒÂºn el tipo especificado
    $consulta_datos = "SELECT id_ai_estado, nombre_estado,
      " . $this->estadoOtLiberaHerramientasExpr() . " AS libera_herramientas,
      " . $this->estadoOtBloqueaOtExpr() . " AS bloquea_ot
      FROM estado_ot
      WHERE std_reg=1
      ORDER BY id_ai_estado ASC";

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
                        <option value="' . $rows['id_ai_estado'] . '" data-libera-herramientas="' . ((int)($rows['libera_herramientas'] ?? 0)) . '" data-bloquea-ot="' . ((int)($rows['bloquea_ot'] ?? 0)) . '" >' . $rows['nombre_estado'] . '</option>
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

    // Consulta para obtener los datos de los miembros segÃƒÂºn el tipo especificado
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

    // Consulta para obtener los datos de los miembros segÃƒÂºn el tipo especificado
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

    // Consulta para obtener los datos de los miembros segÃƒÂºn el tipo especificado
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

  public function cambiarEstadoOtControlador()
  {
    if (!$this->canCambiarEstadoOt()) {
      return json_encode([
        'tipo'   => 'simple',
        'titulo' => 'Acceso denegado',
        'texto'  => 'No tienes permisos para cambiar el estado de una O.T.',
        'icono'  => 'error'
      ], JSON_UNESCAPED_UNICODE);
    }

    $nOt = $this->limpiarCadena($_POST['n_ot'] ?? $_POST['miembro_id'] ?? '');
    $estadoDestino = (int)$this->limpiarCadena($_POST['id_ai_estado'] ?? $_POST['estado_ot'] ?? '');

    if ($nOt === '' || $estadoDestino <= 0) {
      return json_encode([
        'tipo'   => 'simple',
        'titulo' => 'Datos incompletos',
        'texto'  => 'Debes indicar la O.T. y el nuevo estado.',
        'icono'  => 'warning'
      ], JSON_UNESCAPED_UNICODE);
    }

    $ot = $this->otEstadoActual($nOt);
    if (!$ot) {
      return json_encode([
        'tipo'   => 'simple',
        'titulo' => 'O.T. no encontrada',
        'texto'  => 'La O.T. seleccionada no existe o ya no esta disponible.',
        'icono'  => 'error'
      ], JSON_UNESCAPED_UNICODE);
    }

    $estadoActual = (int)($ot['id_ai_estado'] ?? 0);
    $estadoActualNombre = trim((string)($ot['nombre_estado'] ?? ''));
    $estadoActualLibera = (int)($ot['estado_libera_herramientas'] ?? 0) === 1;
    $estadoActualBloquea = (int)($ot['estado_bloquea_ot'] ?? 0) === 1;
    $yaFinalizada = $this->otEstaFinalizada($nOt) || $estadoActualBloquea;

    if ($yaFinalizada) {
      $estadoBloqueante = $estadoActualNombre !== '' ? $estadoActualNombre : 'final';
      return json_encode([
        'tipo'   => 'simple',
        'titulo' => 'Estado bloqueado',
          'texto'  => 'La O.T. ya llego al estado ' . $estadoBloqueante . ', el cual bloquea la orden y no puede volver a cambiar de estado.',
        'icono'  => 'info'
      ], JSON_UNESCAPED_UNICODE);
    }

    if ($estadoActual === $estadoDestino) {
      return json_encode([
        'tipo'   => 'simple',
        'titulo' => 'Sin cambios',
        'texto'  => 'La O.T. ya tiene asignado ese estado.',
        'icono'  => 'info'
      ], JSON_UNESCAPED_UNICODE);
    }

    $stEstado = $this->ejecutarConsultaConParametros(
      "SELECT id_ai_estado, nombre_estado,
              " . $this->estadoOtLiberaHerramientasExpr() . " AS libera_herramientas,
              " . $this->estadoOtBloqueaOtExpr() . " AS bloquea_ot
       FROM estado_ot
       WHERE id_ai_estado = :id
         AND std_reg = 1
       LIMIT 1",
      [':id' => $estadoDestino]
    );

    if (!$stEstado || $stEstado->rowCount() <= 0) {
      return json_encode([
        'tipo'   => 'simple',
        'titulo' => 'Estado invalido',
        'texto'  => 'El estado seleccionado no esta disponible.',
        'icono'  => 'warning'
      ], JSON_UNESCAPED_UNICODE);
    }

    $estado = $stEstado->fetch(\PDO::FETCH_ASSOC);
    $liberaHerramientas = (int)($estado['libera_herramientas'] ?? 0) === 1;
    $bloqueaOt = (int)($estado['bloquea_ot'] ?? 0) === 1;

    if ($bloqueaOt) {
      $stDetalle = $this->ejecutarConsultaConParametros(
        "SELECT COUNT(1)
         FROM detalle_orden
         WHERE n_ot = :n_ot",
        [':n_ot' => $nOt]
      );

        if (!$stDetalle || (int)$stDetalle->fetchColumn() <= 0) {
          return json_encode([
            'tipo'   => 'simple',
            'titulo' => 'Falta informacion',
            'texto'  => 'La O.T. debe tener al menos un detalle antes de pasar a un estado que bloquea la orden.',
            'icono'  => 'warning'
          ], JSON_UNESCAPED_UNICODE);
        }
    }

    try {
      $resultado = $this->ejecutarProcedimientoFila(
        'CALL sp_ot_cambiar_estado(:n_ot, :id_ai_estado, :id_user_operacion)',
        [
          ':n_ot' => $nOt,
          ':id_ai_estado' => $estadoDestino,
          ':id_user_operacion' => (string)($_SESSION['id_user'] ?? $_SESSION['id'] ?? ''),
        ]
      );

      $estadoAplicado = trim((string)($resultado['nombre_estado'] ?? ($estado['nombre_estado'] ?? 'seleccionado')));
      $estadoLibera = (int)($resultado['libera_herramientas'] ?? ($liberaHerramientas ? 1 : 0)) === 1;
      $estadoBloquea = (int)($resultado['bloquea_ot'] ?? ($bloqueaOt ? 1 : 0)) === 1;

      $texto = 'La O.T. ' . $nOt . ' cambio al estado ' . $estadoAplicado . ' correctamente.';
      if ($estadoBloquea) {
        $texto .= ' La orden quedo bloqueada y ya no admite nuevos cambios.';
      }
      if ($estadoLibera) {
        $texto .= ' Las herramientas asociadas fueron liberadas.';
      }

      return json_encode([
        'tipo'   => 'recargar',
        'titulo' => 'Estado actualizado',
        'texto'  => $texto,
        'icono'  => 'success'
      ], JSON_UNESCAPED_UNICODE);
    } catch (\Throwable $e) {
      $this->registrarLogSistema('ERROR', 'ot.cambiar_estado', 'Error al cambiar estado de O.T.', [
        'n_ot' => $nOt,
        'estado_destino' => $estadoDestino,
        'exception' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine()
      ]);

      return json_encode([
        'tipo'   => 'simple',
        'titulo' => 'No se pudo cambiar el estado',
        'texto'  => 'Ocurrio un error al actualizar la O.T. Intenta nuevamente.',
        'icono'  => 'error'
      ], JSON_UNESCAPED_UNICODE);
    }
  }

  public function finalizarOtControlador()
  {
    $estadoFinal = $this->estadoFinalOtId();
    if ($estadoFinal <= 0) {
      return json_encode([
        'tipo'   => 'simple',
        'titulo' => 'Sin estado final',
          'texto'  => 'No existe un estado activo configurado para bloquear la O.T.',
        'icono'  => 'warning'
      ], JSON_UNESCAPED_UNICODE);
    }

    $_POST['id_ai_estado'] = (string)$estadoFinal;
    return $this->cambiarEstadoOtControlador();
  }

  public function eliminarOtControlador()
  {
    // Permiso (ajusta la key si en tu sistema se llama distinto)
    $this->requirePerm('perm_ot_delete');

    $id = $this->limpiarCadena($_POST['miembro_id'] ?? '');

    if ($id === '') {
      return json_encode([
        'tipo'   => 'simple',
        'titulo' => 'Ocurrio un error inesperado',
        'texto'  => 'No se recibio el codigo de la O.T.',
        'icono'  => 'error'
      ], JSON_UNESCAPED_UNICODE);
    }

    // Evita eliminar OT Ã¢â‚¬Å“protegidaÃ¢â‚¬Â (si aplica)
    if ($id === '1') {
      return json_encode([
        'tipo'   => 'simple',
        'titulo' => 'Ocurrio un error inesperado',
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
        'titulo' => 'Ocurrio un error inesperado',
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
        'texto'  => 'La O.T. ' . ($ot['n_ot'] ?? $id) . ' (' . ($ot['nombre_trab'] ?? '') . ') ha sido eliminada con exito',
        'icono'  => 'success'
      ], JSON_UNESCAPED_UNICODE);
    }

    return json_encode([
      'tipo'   => 'simple',
      'titulo' => 'Ocurrio un error inesperado',
      'texto'  => 'No se pudo eliminar la O.T., por favor intente nuevamente',
      'icono'  => 'error'
    ], JSON_UNESCAPED_UNICODE);
  }
}



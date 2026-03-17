<?php

namespace app\controllers;

use app\models\mainModel;

class configController extends mainModel
{

    public function registrarRolControlador()
    {
        // Se obtienen y limpian los datos del formulario
        // Permisos para Usuarios
        $rol_name = $this->limpiarCadena($_POST['rol_name']);

        // Permisos para Usuarios
        $permisoUsuarios0 = $this->limpiarCadena($_POST['permisoUsuarios0'] ?? '');
        $permisoUsuarios1 = $this->limpiarCadena($_POST['permisoUsuarios1'] ?? '');
        $permisoUsuarios2 = $this->limpiarCadena($_POST['permisoUsuarios2'] ?? '');
        $permisoUsuarios3 = $this->limpiarCadena($_POST['permisoUsuarios3'] ?? '');

        // Permisos para Herramienta
        $permisoHerramienta0 = $this->limpiarCadena($_POST['permisoHerramienta0'] ?? '');
        $permisoHerramienta1 = $this->limpiarCadena($_POST['permisoHerramienta1'] ?? '');
        $permisoHerramienta2 = $this->limpiarCadena($_POST['permisoHerramienta2'] ?? '');
        $permisoHerramienta3 = $this->limpiarCadena($_POST['permisoHerramienta3'] ?? '');

        // Permisos para Miembro
        $permisoMiembro0 = $this->limpiarCadena($_POST['permisoMiembro0'] ?? '');
        $permisoMiembro1 = $this->limpiarCadena($_POST['permisoMiembro1'] ?? '');
        $permisoMiembro2 = $this->limpiarCadena($_POST['permisoMiembro2'] ?? '');
        $permisoMiembro3 = $this->limpiarCadena($_POST['permisoMiembro3'] ?? '');

        // Permisos para Orden Trabajo
        $permisoOrdenTrabajo0 = $this->limpiarCadena($_POST['permisoOrdenTrabajo0'] ?? '');
        $permisoOrdenTrabajo1 = $this->limpiarCadena($_POST['permisoOrdenTrabajo1'] ?? '');
        $permisoOrdenTrabajo2 = $this->limpiarCadena($_POST['permisoOrdenTrabajo2'] ?? '');
        $permisoOrdenTrabajo3 = $this->limpiarCadena($_POST['permisoOrdenTrabajo3'] ?? '');
        $permisoOrdenTrabajo4 = $this->limpiarCadena($_POST['permisoOrdenTrabajo4'] ?? '');
        $permisoOrdenTrabajo5 = $this->limpiarCadena($_POST['permisoOrdenTrabajo5'] ?? '');
        $permisoOrdenTrabajo6 = $this->limpiarCadena($_POST['permisoOrdenTrabajo6'] ?? '');

        # Verificación de campos obligatorios #
        if ($rol_name == '') {
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
        if ($this->verificarDatos('[a-zA-ZáéíóúÁÉÍÓÚñÑ0-9 -]{3,40}', $rol_name)) {
            // Si el formato del nombre no es válido, se devuelve una alerta de error
            $alerta = [
                'tipo' => 'simple',
                'titulo' => 'Ocurrió un error inesperado',
                'texto' => 'El nombre rol no cumple con el formato solicitado',
                'icono' => 'error'
            ];
            return json_encode($alerta);
        }
        // Definición de un array asociativo $user_datos_reg que contiene los datos del rol a registrar
        // Array para almacenar los permisos
        $rol_datos_reg = [
            [
                'campo_nombre' => 'nombre_rol',
                'campo_marcador' => ':nombre_rol',
                'campo_valor' => $rol_name =  mb_strtoupper($rol_name, 'UTF-8')
            ],
            [
                'campo_nombre' => 'perm_usuarios_view',
                'campo_marcador' => ':PermUsuariosView',
                'campo_valor' => $this->respuestaCheck($permisoUsuarios0)
            ],
            [
                'campo_nombre' => 'perm_usuarios_add',
                'campo_marcador' => ':PermUsuariosAdd',
                'campo_valor' => $this->respuestaCheck($permisoUsuarios1)
            ],
            [
                'campo_nombre' => 'perm_usuarios_edit',
                'campo_marcador' => ':PermUsuariosEdit',
                'campo_valor' => $this->respuestaCheck($permisoUsuarios2)
            ],
            [
                'campo_nombre' => 'perm_usuarios_delete',
                'campo_marcador' => ':PermUsuariosDelete',
                'campo_valor' => $this->respuestaCheck($permisoUsuarios3)
            ],
            [
                'campo_nombre' => 'perm_herramienta_view',
                'campo_marcador' => ':PermHerramientaView',
                'campo_valor' => $this->respuestaCheck($permisoHerramienta0)
            ],
            [
                'campo_nombre' => 'perm_herramienta_add',
                'campo_marcador' => ':PermHerramientaAdd',
                'campo_valor' => $this->respuestaCheck($permisoHerramienta1)
            ],
            [
                'campo_nombre' => 'perm_herramienta_edit',
                'campo_marcador' => ':PermHerramientaEdit',
                'campo_valor' => $this->respuestaCheck($permisoHerramienta2)
            ],
            [
                'campo_nombre' => 'perm_herramienta_delete',
                'campo_marcador' => ':PermHerramientaDelete',
                'campo_valor' => $this->respuestaCheck($permisoHerramienta3)
            ],
            [
                'campo_nombre' => 'perm_miembro_view',
                'campo_marcador' => ':PermMiembroView',
                'campo_valor' => $this->respuestaCheck($permisoMiembro0)
            ],
            [
                'campo_nombre' => 'perm_miembro_add',
                'campo_marcador' => ':PermMiembroAdd',
                'campo_valor' => $this->respuestaCheck($permisoMiembro1)
            ],
            [
                'campo_nombre' => 'perm_miembro_edit',
                'campo_marcador' => ':PermMiembroEdit',
                'campo_valor' => $this->respuestaCheck($permisoMiembro2)
            ],
            [
                'campo_nombre' => 'perm_miembro_delete',
                'campo_marcador' => ':PermMiembroDelete',
                'campo_valor' => $this->respuestaCheck($permisoMiembro3)
            ],
            [
                'campo_nombre' => 'perm_ot_view',
                'campo_marcador' => ':PermOTView',
                'campo_valor' => $this->respuestaCheck($permisoOrdenTrabajo0)
            ],
            [
                'campo_nombre' => 'perm_ot_add',
                'campo_marcador' => ':PermOTAdd',
                'campo_valor' => $this->respuestaCheck($permisoOrdenTrabajo1)
            ],
            [
                'campo_nombre' => 'perm_ot_edit',
                'campo_marcador' => ':PermOTEdit',
                'campo_valor' => $this->respuestaCheck($permisoOrdenTrabajo2)
            ],
            [
                'campo_nombre' => 'perm_ot_delete',
                'campo_marcador' => ':PermOTDelete',
                'campo_valor' => $this->respuestaCheck($permisoOrdenTrabajo4)
            ],
            [
                'campo_nombre' => 'perm_ot_add_detalle',
                'campo_marcador' => ':PermOTAddDetalle',
                'campo_valor' => $this->respuestaCheck($permisoOrdenTrabajo3)
            ],
            [
                'campo_nombre' => 'perm_ot_generar_reporte',
                'campo_marcador' => ':PermOTGenerarReporte',
                'campo_valor' => $this->respuestaCheck($permisoOrdenTrabajo5)
            ],
            [
                'campo_nombre' => 'perm_ot_add_herramienta',
                'campo_marcador' => ':PermOTAddHerramienta',
                'campo_valor' => $this->respuestaCheck($permisoOrdenTrabajo6)
            ]
        ];

        // Llamada al método guardarDatos() para guardar los datos del usuario en la base de datos
        $registrar_dts = $this->guardarDatos('roles_permisos', $rol_datos_reg);

        if ($registrar_dts->rowCount() == 1) {
            // Si se registró correctamente, se devuelve un mensaje de éxito
            $alerta = [
                'tipo' => 'limpiar',
                'titulo' => 'Rol Registrado',
                'texto' => 'El Rol ' . $rol_name . ' se ha registrado con éxito',
                'icono' => 'success'
            ];
        } else {


            // Si no se pudo registrar, se devuelve un mensaje de error
            $alerta = [
                'tipo' => 'simple',
                'titulo' => 'Ocurrió un error inesperado',
                'texto' => 'El Rol no se pudo registrar correctamente',
                'icono' => 'error'
            ];
        }
        return json_encode($alerta);
    }

    public function ModificarRolControlador()
    {
        // Se obtienen y limpian los datos del formulario
        // Permisos para Usuarios
        $id = $this->limpiarCadena($_POST['opciones']);

        // Permisos para Usuarios
        $permisoUsuarios0 = $this->limpiarCadena($_POST['permisoUsuarios0'] ?? '');
        $permisoUsuarios1 = $this->limpiarCadena($_POST['permisoUsuarios1'] ?? '');
        $permisoUsuarios2 = $this->limpiarCadena($_POST['permisoUsuarios2'] ?? '');
        $permisoUsuarios3 = $this->limpiarCadena($_POST['permisoUsuarios3'] ?? '');

        // Permisos para Herramienta
        $permisoHerramienta0 = $this->limpiarCadena($_POST['permisoHerramienta0'] ?? '');
        $permisoHerramienta1 = $this->limpiarCadena($_POST['permisoHerramienta1'] ?? '');
        $permisoHerramienta2 = $this->limpiarCadena($_POST['permisoHerramienta2'] ?? '');
        $permisoHerramienta3 = $this->limpiarCadena($_POST['permisoHerramienta3'] ?? '');

        // Permisos para Miembro
        $permisoMiembro0 = $this->limpiarCadena($_POST['permisoMiembro0'] ?? '');
        $permisoMiembro1 = $this->limpiarCadena($_POST['permisoMiembro1'] ?? '');
        $permisoMiembro2 = $this->limpiarCadena($_POST['permisoMiembro2'] ?? '');
        $permisoMiembro3 = $this->limpiarCadena($_POST['permisoMiembro3'] ?? '');

        // Permisos para Orden Trabajo
        $permisoOrdenTrabajo0 = $this->limpiarCadena($_POST['permisoOrdenTrabajo0'] ?? '');
        $permisoOrdenTrabajo1 = $this->limpiarCadena($_POST['permisoOrdenTrabajo1'] ?? '');
        $permisoOrdenTrabajo2 = $this->limpiarCadena($_POST['permisoOrdenTrabajo2'] ?? '');
        $permisoOrdenTrabajo3 = $this->limpiarCadena($_POST['permisoOrdenTrabajo3'] ?? '');
        $permisoOrdenTrabajo4 = $this->limpiarCadena($_POST['permisoOrdenTrabajo4'] ?? '');
        $permisoOrdenTrabajo5 = $this->limpiarCadena($_POST['permisoOrdenTrabajo5'] ?? '');
        $permisoOrdenTrabajo6 = $this->limpiarCadena($_POST['permisoOrdenTrabajo6'] ?? '');

        # Verificación de campos obligatorios #
        if ($id == 'Seleccionar') {
            // Si algún campo obligatorio está vacío, se devuelve una alerta de error
            $alerta = [
                'tipo' => 'simple',
                'titulo' => 'Ocurrió un error inesperado',
                'texto' => 'Primero selecciona el rol que deseas modificar',
                'icono' => 'info'
            ];
            return json_encode($alerta);
            exit();
        }

        // Definición de un array asociativo $user_datos_reg que contiene los datos del rol a registrar
        // Array para almacenar los permisos
        $rol_datos_reg = [
            [
                'campo_nombre' => 'perm_usuarios_view',
                'campo_marcador' => ':PermUsuariosView',
                'campo_valor' => $this->respuestaCheck($permisoUsuarios0)
            ],
            [
                'campo_nombre' => 'perm_usuarios_add',
                'campo_marcador' => ':PermUsuariosAdd',
                'campo_valor' => $this->respuestaCheck($permisoUsuarios1)
            ],
            [
                'campo_nombre' => 'perm_usuarios_edit',
                'campo_marcador' => ':PermUsuariosEdit',
                'campo_valor' => $this->respuestaCheck($permisoUsuarios2)
            ],
            [
                'campo_nombre' => 'perm_usuarios_delete',
                'campo_marcador' => ':PermUsuariosDelete',
                'campo_valor' => $this->respuestaCheck($permisoUsuarios3)
            ],
            [
                'campo_nombre' => 'perm_herramienta_view',
                'campo_marcador' => ':PermHerramientaView',
                'campo_valor' => $this->respuestaCheck($permisoHerramienta0)
            ],
            [
                'campo_nombre' => 'perm_herramienta_add',
                'campo_marcador' => ':PermHerramientaAdd',
                'campo_valor' => $this->respuestaCheck($permisoHerramienta1)
            ],
            [
                'campo_nombre' => 'perm_herramienta_edit',
                'campo_marcador' => ':PermHerramientaEdit',
                'campo_valor' => $this->respuestaCheck($permisoHerramienta2)
            ],
            [
                'campo_nombre' => 'perm_herramienta_delete',
                'campo_marcador' => ':PermHerramientaDelete',
                'campo_valor' => $this->respuestaCheck($permisoHerramienta3)
            ],
            [
                'campo_nombre' => 'perm_miembro_view',
                'campo_marcador' => ':PermMiembroView',
                'campo_valor' => $this->respuestaCheck($permisoMiembro0)
            ],
            [
                'campo_nombre' => 'perm_miembro_add',
                'campo_marcador' => ':PermMiembroAdd',
                'campo_valor' => $this->respuestaCheck($permisoMiembro1)
            ],
            [
                'campo_nombre' => 'perm_miembro_edit',
                'campo_marcador' => ':PermMiembroEdit',
                'campo_valor' => $this->respuestaCheck($permisoMiembro2)
            ],
            [
                'campo_nombre' => 'perm_miembro_delete',
                'campo_marcador' => ':PermMiembroDelete',
                'campo_valor' => $this->respuestaCheck($permisoMiembro3)
            ],
            [
                'campo_nombre' => 'perm_ot_view',
                'campo_marcador' => ':PermOTView',
                'campo_valor' => $this->respuestaCheck($permisoOrdenTrabajo0)
            ],
            [
                'campo_nombre' => 'perm_ot_add',
                'campo_marcador' => ':PermOTAdd',
                'campo_valor' => $this->respuestaCheck($permisoOrdenTrabajo1)
            ],
            [
                'campo_nombre' => 'perm_ot_edit',
                'campo_marcador' => ':PermOTEdit',
                'campo_valor' => $this->respuestaCheck($permisoOrdenTrabajo2)
            ],
            [
                'campo_nombre' => 'perm_ot_delete',
                'campo_marcador' => ':PermOTDelete',
                'campo_valor' => $this->respuestaCheck($permisoOrdenTrabajo4)
            ],
            [
                'campo_nombre' => 'perm_ot_add_detalle',
                'campo_marcador' => ':PermOTAddDetalle',
                'campo_valor' => $this->respuestaCheck($permisoOrdenTrabajo3)
            ],
            [
                'campo_nombre' => 'perm_ot_generar_reporte',
                'campo_marcador' => ':PermOTGenerarReporte',
                'campo_valor' => $this->respuestaCheck($permisoOrdenTrabajo5)
            ],
            [
                'campo_nombre' => 'perm_ot_add_herramienta',
                'campo_marcador' => ':PermOTAddHerramienta',
                'campo_valor' => $this->respuestaCheck($permisoOrdenTrabajo6)
            ]
        ];
        $condicion = [
            'condicion_campo' => 'id',
            'condicion_marcador' => ':ID',
            'condicion_valor' => $id
        ];

        if ($this->actualizarDatos('roles_permisos', $rol_datos_reg, $condicion)) {
            // Si se registró correctamente, se devuelve un mensaje de éxito
            $alerta = [
                'tipo' => 'limpiar',
                'titulo' => 'Rol Modificado',
                'texto' => 'El Rol se ha modificado con éxito',
                'icono' => 'success'
            ];
        } else {


            // Si no se pudo registrar, se devuelve un mensaje de error
            $alerta = [
                'tipo' => 'simple',
                'titulo' => 'Ocurrió un error inesperado',
                'texto' => 'El Rol no se pudo modificar correctamente',
                'icono' => 'error'
            ];
        }
        return json_encode($alerta);
    }

    public function eliminarRolControlador()
    {

        $id = $this->limpiarCadena($_POST['opciones']);

        $datosC = $this->ejecutarConsultaConParametros("SELECT " . $this->columnasTablaSql('roles_permisos') . " FROM roles_permisos WHERE id = :id", [':id' => $id]);
        $datosC = $datosC->fetch();
        if ($id == 'Seleccionar') {
            // Si algún campo obligatorio está vacío, se devuelve una alerta de error
            $alerta = [
                'tipo' => 'simple',
                'titulo' => 'Ocurrió un error inesperado',
                'texto' => 'Primero selecciona el rol que deseas eliminar',
                'icono' => 'info'
            ];
            return json_encode($alerta);
            exit();
        }

        # verificar si el rol esta asignado algun usuario
        $datos = $this->ejecutarConsultaConParametros("SELECT " . $this->columnasTablaSql('user_system') . " FROM user_system WHERE tipo = :id", [':id' => $id]);
        if ($datos->rowCount() > 0) {
            $alerta = [
                'tipo' => 'simple',
                'titulo' => '¡Ups! No podemos realizar esta acción.',
                'texto' => 'Este rol esta asignado a ' . $datos->rowCount() . ' Usuario(s), primero debe reasignarle un nuevo rol a los usuarios asociados al rol que desea eliminar para poder realizar esta acción.',
                'icono' => 'warning'
            ];
            return json_encode($alerta);
            exit();
        } else {
            $datos = $datos->fetch();
        }

        $eliminar_reg = $this->eliminarRegistro('roles_permisos', 'id', $id);

        if ($eliminar_reg->rowCount() == 1) {
            $alerta = [
                'tipo' => 'recargar',
                'titulo' => 'Rol Eliminado',
                'texto' => 'El Rol ha sido eliminado con exito',
                'icono' => 'success'
            ];
        } else {
            $alerta = [
                'tipo' => 'simple',
                'titulo' => 'Ocurrió un error inesperado',
                'texto' => 'No se pudo eliminar el Rol, por favor intente nuevamente',
                'icono' => 'error'
            ];
        }
        return json_encode($alerta);
    }

    public function listarComboRolControlador()
    {

        // Variable para almacenar el HTML del combo
        $combo = '';

        // Consulta para obtener los datos de los miembros según el tipo especificado
        $consulta_datos = 'SELECT ' . $this->columnasTablaSql('roles_permisos') . ' FROM roles_permisos where id != 1 ORDER BY nombre_rol ASC';

        // Ejecutar la consulta para obtener los datos de los miembros
        $datos = $this->ejecutarConsulta($consulta_datos);
        $datos = $datos->fetchAll();

        // Comprobar el tipo de miembro para determinar la etiqueta del combo

        // Si el tipo no es 1, el combo es para el responsable de control de operaciones
        $combo .= '
                <select class="form-select" id="opciones" name="opciones" aria-label="Default select example">
            ';

        // Comprobar si hay miembros disponibles para mostrar en el combo
        if (count($datos) > 0) {

            // Si hay miembros disponibles, iterar sobre ellos y agregar opciones al combo
            foreach ($datos as $rows) {
                $combo .= '
                    <option value="' . $rows['id'] . '">' . $rows['nombre_rol'] . '</option>
                ';
            }
        }

        // Cerrar el combo y devolver el HTML generado
        $combo .= '</select>';

        return $combo;
    }

    public function registrarAreaControlador()
    {

        // Se obtienen y limpian los datos del formulario

        // Permisos para Usuarios
        $nombre_area = $this->limpiarCadena($_POST['nombre_area']);
        $nomeclatura = $this->limpiarCadena($_POST['nome']);

        # Verificación de campos obligatorios #
        if ($nombre_area == '' || $nomeclatura == '') {
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
        if ($this->verificarDatos('[a-zA-ZáéíóúÁÉÍÓÚñÑ0-9 -]{3,40}', $nombre_area)) {
            // Si el formato del nombre no es válido, se devuelve una alerta de error
            $alerta = [
                'tipo' => 'simple',
                'titulo' => 'Ocurrió un error inesperado',
                'texto' => 'El nombre del area no cumple con el formato solicitado',
                'icono' => 'error'
            ];
            return json_encode($alerta);
            exit();
        }
        // Definición de un array asociativo $user_datos_reg que contiene los datos del rol a registrar
        // Array para almacenar los permisos
        $area_datos_reg = [
            [
                'campo_nombre' => 'nombre_area',
                'campo_marcador' => ':nombre_area',
                'campo_valor' => $nombre_area =  mb_strtoupper($nombre_area, 'UTF-8')
            ],
            [
                'campo_nombre' => 'nomeclatura',
                'campo_marcador' => ':nomeclatura',
                'campo_valor' => $nomeclatura =  mb_strtoupper($nomeclatura, 'UTF-8')
            ]
        ];

        // Llamada al método guardarDatos() para guardar los datos del usuario en la base de datos
        $registrar_dts = $this->guardarDatos('area_trabajo', $area_datos_reg);

        if ($registrar_dts->rowCount() == 1) {
            // Si se registró correctamente, se devuelve un mensaje de éxito
            $alerta = [
                'tipo' => 'limpiar',
                'titulo' => 'Area Registrado',
                'texto' => 'El Area ' . $nombre_area . ' se ha registrado con éxito',
                'icono' => 'success'
            ];
        } else {


            // Si no se pudo registrar, se devuelve un mensaje de error
            $alerta = [
                'tipo' => 'simple',
                'titulo' => 'Ocurrió un error inesperado',
                'texto' => 'El Area no se pudo registrar correctamente',
                'icono' => 'error'
            ];
        }
        return json_encode($alerta);
    }

    public function eliminarAreaControlador()
    {

        $id = $this->limpiarCadena($_POST['id_ai_area']);

        # verificar si el rol esta asignado algun usuario
        $datosC = $this->ejecutarConsultaConParametros("SELECT " . $this->columnasTablaSql('area_trabajo') . " FROM area_trabajo WHERE id_ai_area = :id", [':id' => $id]);
        $datosC = $datosC->fetch();

        $datos = $this->ejecutarConsultaConParametros("SELECT " . $this->columnasTablaSql('orden_trabajo') . " FROM orden_trabajo WHERE id_ai_area = :id", [':id' => $id]);
        if ($datos->rowCount() > 0) {
            $alerta = [
                'tipo' => 'simple',
                'titulo' => '¡Ups! No podemos realizar esta acción.',
                'texto' => 'Esta Area esta asignada a ' . $datos->rowCount() . ' O.T.(s), primero debe reasignarle una nueva area a las O.T. asociadas al area que desea eliminar para poder realizar esta acción.',
                'icono' => 'warning'
            ];
            return json_encode($alerta);
            exit();
        } else {
            $datos = $datos->fetch();
        }

        $eliminar_reg = $this->eliminarRegistro('area_trabajo', 'id_ai_area', $id);

        if ($eliminar_reg->rowCount() == 1) {
            $alerta = [
                'tipo' => 'recargar',
                'titulo' => 'Area Eliminado',
                'texto' => 'El Area ' . $datosC['nombre_area'] . ' ha sido eliminado con exito',
                'icono' => 'success'
            ];
        } else {
            $alerta = [
                'tipo' => 'simple',
                'titulo' => 'Ocurrió un error inesperado',
                'texto' => 'No se pudo eliminar el Area, por favor intente nuevamente',
                'icono' => 'error'
            ];
        }
        return json_encode($alerta);
    }

    public function listarAreaControlador($busqueda)
    {
        $busqueda = $this->limpiarCadena($busqueda);

        $consulta_datos = "SELECT " . $this->columnasTablaSql('area_trabajo') . " FROM area_trabajo WHERE std_reg='1' ORDER BY id_ai_area ASC";
        $consulta_total = "SELECT COUNT(id_ai_area) FROM area_trabajo where std_reg='1'";

        $datos = $this->ejecutarConsulta($consulta_datos);
        $datos = $datos->fetchAll();

        $total = $this->ejecutarConsulta($consulta_total);
        $total = (int)$total->fetchColumn();

        $tabla = '
    <div class="area-responsive p-3">

        <!-- DESKTOP: TABLA -->
        <div class="d-none d-md-block">
            <div class="table-responsive table-wrapper3" id="tabla-area" style="max-height:70vh; overflow-y:auto;">
                <table class="table border mb-0 table-hover table-sm table-striped" id="tablaDatosArea">
                    <thead class="table-light fw-semibold">
                        <tr class="align-middle">
                            <th class="clearfix">#</th>
                            <th class="clearfix">Nombre</th>
                            <th class="text-center">Nomenclatura</th>
                            <th class="text-center" colspan="2">Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
    ';

        $cards = '
        <!-- MÓVIL: CARDS -->
        <div class="d-md-none p-3">
            <div class="tool-cards" id="toolCardsArea">
    ';

        if ($total >= 1) {
            $contador = 1;

            foreach ($datos as $rows) {
                $id   = $rows["id_ai_area"];
                $nom  = $rows["nombre_area"];
                $nome = $rows["nomeclatura"];

                /* ===== TABLA DESKTOP ===== */
                $tabla .= '
                <tr class="align-middle">
                    <td class="col-p"><b>' . $contador . '</b></td>

                    <td>
                        <div class="clearfix">
                            <div><b>' . $nom . '</b></div>
                        </div>
                    </td>

                    <td class="text-center col-p">
                        <span class="badge bg-light text-dark border">' . $nome . '</span>
                    </td>

                    <td class="col-p text-center">
                        <a href="#" title="Modificar" class="btn btn-warning text-dark js-area-edit" data-id="' . $id . '">
                        <i class="bi bi-pencil text-white"></i>
                        </a>
                    </td>

                    <td class="col-p text-center">
                        <a href="#" title="Eliminar" class="btn btn-danger js-area-del" data-id="' . $id . '">
                        <i class="bi bi-trash" style="color:white;"></i>
                        </a>
                    </td>
                </tr>
            ';

                /* ===== CARDS MÓVIL ===== */
                $cards .= '
                <div class="tool-card">
                    <div class="tool-card-head">
                        <span class="tool-code">#' . $contador . ' • Área</span>
                        <span class="badge bg-light text-dark border">' . $nome . '</span>
                    </div>

                    <div class="tool-body">
                        <div class="tool-row">
                            <div class="tool-label">Nombre</div>
                            <div class="tool-value">' . $nom . '</div>
                        </div>

                        <div class="tool-actions">
                            <a href="#" class="btn btn-warning text-dark btn-sm js-area-edit" data-id="' . $id . '" title="Modificar">
                            <i class="bi bi-pencil text-white"></i>
                            </a>

                            <a href="#" class="btn btn-danger btn-sm js-area-del" data-id="' . $id . '" title="Eliminar">
                            <i class="bi bi-trash"></i>
                            </a>
                        </div>
                    </div>
                </div>
            ';

                $contador++;
            }
        } else {
            $tabla .= '
            <tr class="align-middle">
                <td class="text-center" colspan="5">No hay registros en el sistema</td>
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
                        <div class="tool-label">Áreas</div>
                        <div class="tool-value">No hay registros en el sistema</div>
                    </div>
                </div>
            </div>
        ';
        }

        $tabla .= '
                    </tbody>
                </table>
            </div>
        </div>
    ';

        $cards .= '
            </div>
        </div>
    ';

        $tabla .= $cards . '
        <div class="mt-2">
            <label class="form-label mb-0">Total registros: <strong>' . $total . '</strong></label>
        </div>
    </div>';

        return $tabla;
    }


    public function registrarEstadoControlador()
    {
        // Se obtienen y limpian los datos del formulario

        // Permisos para Usuarios
        $nombre_estado = $this->limpiarCadena($_POST['nombre_estado']);
        $color = $this->limpiarCadena($_POST['color']);

        # Verificación de campos obligatorios #
        if ($nombre_estado == '') {
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
        if ($this->verificarDatos('[a-zA-ZáéíóúÁÉÍÓÚñÑ -]{3,40}', $nombre_estado)) {
            // Si el formato del nombre no es válido, se devuelve una alerta de error
            $alerta = [
                'tipo' => 'simple',
                'titulo' => 'Ocurrió un error inesperado',
                'texto' => 'El nombre no cumple con el formato solicitado',
                'icono' => 'error'
            ];
            return json_encode($alerta);
            exit();
        }
        // Definición de un array asociativo $user_datos_reg que contiene los datos del rol a registrar
        // Array para almacenar los permisos
        $estado_datos_reg = [
            [
                'campo_nombre' => 'nombre_estado',
                'campo_marcador' => ':nombre_estado',
                'campo_valor' => $nombre_estado =  mb_strtoupper($nombre_estado, 'UTF-8')
            ],
            [
                'campo_nombre' => 'color',
                'campo_marcador' => ':color',
                'campo_valor' => $color
            ]
        ];

        // Llamada al método guardarDatos() para guardar los datos del usuario en la base de datos
        $registrar_dts = $this->guardarDatos('estado_ot', $estado_datos_reg);

        if ($registrar_dts->rowCount() == 1) {
            // Si se registró correctamente, se devuelve un mensaje de éxito
            $alerta = [
                'tipo' => 'limpiar',
                'titulo' => 'Estado Registrado',
                'texto' => 'El Estado ' . $nombre_estado . ' se ha registrado con éxito',
                'icono' => 'success'
            ];
        } else {


            // Si no se pudo registrar, se devuelve un mensaje de error
            $alerta = [
                'tipo' => 'simple',
                'titulo' => 'Ocurrió un error inesperado',
                'texto' => 'El Rol no se pudo registrar correctamente',
                'icono' => 'error'
            ];
        }
        return json_encode($alerta);
    }

    public function eliminarEstadoControlador()
    {

        $id = $this->limpiarCadena($_POST['id_ai_estado']);

        # verificar si el rol esta asignado algun usuario
        $datosC = $this->ejecutarConsultaConParametros("SELECT " . $this->columnasTablaSql('estado_ot') . " FROM estado_ot WHERE id_ai_estado = :id", [':id' => $id]);
        $datosC = $datosC->fetch();

        $datos = $this->ejecutarConsultaConParametros("SELECT " . $this->columnasTablaSql('detalle_orden') . " FROM detalle_orden WHERE id_ai_estado = :id", [':id' => $id]);
        if ($datos->rowCount() > 0) {
            $alerta = [
                'tipo' => 'simple',
                'titulo' => '¡Ups! No podemos realizar esta acción.',
                'texto' => 'Este Estado esta asignado a ' . $datos->rowCount() . ' O.T.(s), primero debe reasignarle un nuevo estado a las O.T. asociadas al estado que desea eliminar para poder realizar esta acción.',
                'icono' => 'warning'
            ];
            return json_encode($alerta);
            exit();
        } else {
            $datos = $datos->fetch();
        }

        $eliminar_reg = $this->eliminarRegistro('estado_ot', 'id_ai_estado', $id);

        if ($eliminar_reg->rowCount() == 1) {
            $alerta = [
                'tipo' => 'recargar',
                'titulo' => 'Estado Eliminado',
                'texto' => 'El Estado ' . $datosC['nombre_estado'] . ' ha sido eliminado con exito',
                'icono' => 'success'
            ];
        } else {
            $alerta = [
                'tipo' => 'simple',
                'titulo' => 'Ocurrió un error inesperado',
                'texto' => 'No se pudo eliminar el Estado, por favor intente nuevamente',
                'icono' => 'error'
            ];
        }
        return json_encode($alerta);
    }

    public function listarEstadoControlador($busqueda)
    {
        $busqueda = $this->limpiarCadena($busqueda);

        // Por ahora no usas búsqueda, se deja listo para futuro
        $consulta_datos  = "SELECT " . $this->columnasTablaSql('estado_ot') . " FROM estado_ot WHERE std_reg='1' ORDER BY id_ai_estado ASC";
        $consulta_total  = "SELECT COUNT(id_ai_estado) FROM estado_ot where std_reg='1'";

        $datos = $this->ejecutarConsulta($consulta_datos);
        $datos = $datos->fetchAll();

        $total = $this->ejecutarConsulta($consulta_total);
        $total = (int)$total->fetchColumn();

        $tabla = '
        <div class="estado-responsive p-3">

            <!-- DESKTOP: TABLA -->
            <div class="d-none d-md-block">
                <div class="table-responsive table-wrapper3" id="tabla-estado" style="max-height:70vh; overflow-y:auto;">
                    <table class="table border mb-0 table-hover table-sm table-striped" id="tablaDatosEstado">
                        <thead class="table-light fw-semibold">
                            <tr class="align-middle">
                                <th class="clearfix">#</th>
                                <th class="clearfix">Nombre</th>
                                <th class="text-center">Indicador</th>
                                <th class="text-center" colspan="2">Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
        ';

        $cards = '
            <!-- MÓVIL: CARDS -->
            <div class="d-md-none p-3">
                <div class="tool-cards" id="toolCardsEstado">
        ';

        if ($total >= 1) {
            $contador = 1;

            foreach ($datos as $rows) {
                $id     = $rows["id_ai_estado"];
                $nombre = $rows["nombre_estado"];
                $color  = $rows["color"];

                /* ===== TABLA DESKTOP ===== */
                $tabla .= '
                <tr class="align-middle">
                    <td class="col-p"><b>' . $contador . '</b></td>

                    <td>
                        <div class="clearfix">
                            <div><b>' . $nombre . '</b></div>
                        </div>
                    </td>

                    <td class="text-center col-p">
                        <span style="
                            display:inline-block;
                            border:1px solid #fff;
                            border-radius:50em;
                            width:1.7333333333rem;
                            height:1.7333333333rem;
                            background-color:' . $color . ';
                        " title="' . $nombre . '"></span>
                    </td>

                    <td class="col-p text-center">
                        <a href="#"
                        class="btn btn-warning text-dark js-estado-edit"
                        data-bs-toggle="modal"
                        data-bs-target="#ventanaModalModificarEstado"
                        data-id="' . $id . '"
                        title="Modificar">
                            <i class="bi bi-pencil text-white"></i>
                        </a>
                    </td>

                    <td class="col-p text-center">
                        <button type="button"
                                class="btn btn-danger js-estado-del"
                                data-id="' . $id . '"
                                title="Eliminar">
                            <i class="bi bi-trash" style="color:white;"></i>
                        </button>
                    </td>

                </tr>
            ';

                /* ===== CARDS MÓVIL ===== */
                $cards .= '
                <div class="tool-card">
                    <div class="tool-card-head">
                        <span class="tool-code">#' . $contador . ' • Estado</span>
                        <span class="d-inline-flex align-items-center gap-2">
                            <span style="
                                display:inline-block;
                                border:1px solid #fff;
                                border-radius:50em;
                                width:1.15rem;
                                height:1.15rem;
                                background-color:' . $color . ';
                            "></span>
                            <b>' . $nombre . '</b>
                        </span>
                    </div>

                    <div class="tool-body">
                        <div class="tool-actions">
                           <a href="#"
                                class="btn btn-warning text-dark btn-sm js-estado-edit"
                                data-bs-toggle="modal"
                                data-bs-target="#ventanaModalModificarEstado"
                                data-id="' . $id . '"
                                title="Modificar">
                                    <i class="bi bi-pencil text-white"></i>
                                </a>

                                <button type="button"
                                        class="btn btn-danger btn-sm js-estado-del"
                                        data-id="' . $id . '"
                                        title="Eliminar">
                                    <i class="bi bi-trash"></i>
                                </button>

                        </div>
                    </div>
                </div>
            ';

                $contador++;
            }
        } else {
            $tabla .= '
            <tr class="align-middle">
                <td class="text-center" colspan="5">No hay registros en el sistema</td>
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

        $tabla .= '
                    </tbody>
                </table>
            </div>
        </div>
    ';

        $cards .= '
            </div>
        </div>
    ';

        $tabla .= $cards . '
        <div class="mt-2">
            <label class="form-label mb-0">Total registros: <strong>' . $total . '</strong></label>
        </div>
    </div>';

        return $tabla;
    }


    public function registrarSitioControlador()
    {
        // Se obtienen y limpian los datos del formulario

        // Permisos para Usuarios
        $nombre_sitio = $this->limpiarCadena($_POST['sitio']);

        # Verificación de campos obligatorios #
        if ($nombre_sitio == '') {
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
        if ($this->verificarDatos('[a-zA-ZáéíóúÁÉÍÓÚñÑ -]{3,40}', $nombre_sitio)) {
            // Si el formato del nombre no es válido, se devuelve una alerta de error
            $alerta = [
                'tipo' => 'simple',
                'titulo' => 'Ocurrió un error inesperado',
                'texto' => 'El nombre del sitio no cumple con el formato solicitado',
                'icono' => 'error'
            ];
            return json_encode($alerta);
            exit();
        }
        // Definición de un array asociativo $user_datos_reg que contiene los datos del rol a registrar
        // Array para almacenar los permisos
        $datos_reg = [
            [
                'campo_nombre' => 'nombre_sitio',
                'campo_marcador' => ':nombre_sitio',
                'campo_valor' => $nombre_sitio =  mb_strtoupper($nombre_sitio, 'UTF-8')
            ]
        ];

        // Llamada al método guardarDatos() para guardar los datos del usuario en la base de datos
        $registrar_dts = $this->guardarDatos('sitio_trabajo', $datos_reg);

        if ($registrar_dts->rowCount() == 1) {
            // Si se registró correctamente, se devuelve un mensaje de éxito
            $alerta = [
                'tipo' => 'limpiar',
                'titulo' => 'Sitio Registrado',
                'texto' => 'El Sitio ' . $nombre_sitio . ' se ha registrado con éxito',
                'icono' => 'success'
            ];
        } else {
            // Si no se pudo registrar, se devuelve un mensaje de error
            $alerta = [
                'tipo' => 'simple',
                'titulo' => 'Ocurrió un error inesperado',
                'texto' => 'El Sitio no se pudo registrar correctamente',
                'icono' => 'error'
            ];
        }
        return json_encode($alerta);
    }

    public function eliminarSitioControlador()
    {

        $id = $this->limpiarCadena($_POST['id_ai_sitio']);

        # verificar si el rol esta asignado algun usuario
        $datosC = $this->ejecutarConsultaConParametros("SELECT " . $this->columnasTablaSql('sitio_trabajo') . " FROM sitio_trabajo WHERE id_ai_sitio = :id", [':id' => $id]);
        $datosC = $datosC->fetch();

        $datos = $this->ejecutarConsultaConParametros("SELECT " . $this->columnasTablaSql('orden_trabajo') . " FROM orden_trabajo WHERE id_ai_sitio = :id", [':id' => $id]);
        if ($datos->rowCount() > 0) {
            $alerta = [
                'tipo' => 'simple',
                'titulo' => '¡Ups! No podemos realizar esta acción.',
                'texto' => 'Este Sitio esta asignado a ' . $datos->rowCount() . ' O.T.(s), primero debe reasignarle un nuevo sitio a las O.T. asociadas al sitio que desea eliminar para poder realizar esta acción.',
                'icono' => 'warning'
            ];
            return json_encode($alerta);
            exit();
        } else {
            $datos = $datos->fetch();
        }

        $eliminar_reg = $this->eliminarRegistro('sitio_trabajo', 'id_ai_sitio', $id);

        if ($eliminar_reg->rowCount() == 1) {
            $alerta = [
                'tipo' => 'recargar',
                'titulo' => 'Sitio Eliminado',
                'texto' => 'El sitio ' . $datosC['nombre_sitio'] . ' ha sido eliminado con exito',
                'icono' => 'success'
            ];
        } else {
            $alerta = [
                'tipo' => 'simple',
                'titulo' => 'Ocurrió un error inesperado',
                'texto' => 'No se pudo eliminar el Sitio, por favor intente nuevamente',
                'icono' => 'error'
            ];
        }
        return json_encode($alerta);
    }


    public function listarSitioControlador($busqueda)
    {
        $busqueda = $this->limpiarCadena($busqueda);

        $consulta_datos = "SELECT " . $this->columnasTablaSql('sitio_trabajo') . " FROM sitio_trabajo WHERE std_reg='1' ORDER BY id_ai_sitio ASC";
        $consulta_total = "SELECT COUNT(id_ai_sitio) FROM sitio_trabajo WHERE std_reg='1'";

        $datos = $this->ejecutarConsulta($consulta_datos);
        $datos = $datos->fetchAll();

        $total = $this->ejecutarConsulta($consulta_total);
        $total = (int)$total->fetchColumn();

        $tabla = '
    <div class="sitio-responsive p-3">

      <!-- DESKTOP: TABLA -->
      <div class="d-none d-md-block">
        <div class="table-responsive table-wrapper3" id="tabla-sitio" style="max-height:70vh; overflow-y:auto;">
          <table class="table border mb-0 table-hover table-sm table-striped" id="tablaDatosSitio">
            <thead class="table-light fw-semibold">
              <tr class="align-middle">
                <th class="clearfix">#</th>
                <th class="clearfix">Nombre</th>
                <th class="text-center" colspan="2">Acciones</th>
              </tr>
            </thead>
            <tbody>
    ';

        $cards = '
      <!-- MÓVIL: CARDS -->
      <div class="d-md-none p-3">
        <div class="tool-cards" id="toolCardsSitio">
    ';

        if ($total >= 1) {
            $contador = 1;

            foreach ($datos as $rows) {
                $id = $rows["id_ai_sitio"];
                $nombre = $rows["nombre_sitio"];

                $tabla .= '
              <tr class="align-middle">
                <td class="col-p"><b>' . $contador . '</b></td>
                <td><b>' . $nombre . '</b></td>

                <td class="col-p text-center">
                  <a href="#" class="btn btn-warning text-dark js-sitio-edit" data-action="edit" data-id="' . $id . '" title="Modificar">
                    <i class="bi bi-pencil text-white"></i>
                  </a>
                </td>

                <td class="col-p text-center">
                  <a href="#" class="btn btn-danger js-sitio-del" data-action="delete" data-id="' . $id . '" title="Eliminar">
                    <i class="bi bi-trash" style="color:white;"></i>
                  </a>
                </td>
              </tr>
            ';

                $cards .= '
              <div class="tool-card">
                <div class="tool-card-head">
                  <span class="tool-code">#' . $contador . ' • Sitio</span>
                  <span><b>' . $nombre . '</b></span>
                </div>

                <div class="tool-body">
                  <div class="tool-actions">
                    <a href="#" class="btn btn-warning text-dark btn-sm js-sitio-edit" data-action="edit" data-id="' . $id . '" title="Modificar">
                      <i class="bi bi-pencil text-white"></i>
                    </a>

                    <a href="#" class="btn btn-danger btn-sm js-sitio-del" data-action="delete" data-id="' . $id . '" title="Eliminar">
                      <i class="bi bi-trash"></i>
                    </a>
                  </div>
                </div>
              </div>
            ';

                $contador++;
            }
        } else {
            $tabla .= '<tr class="align-middle"><td class="text-center" colspan="4">No hay registros en el sistema</td></tr>';

            $cards .= '
          <div class="tool-card">
            <div class="tool-card-head">
              <span class="tool-code">Sin registros</span><span>—</span>
            </div>
            <div class="tool-body">
              <div class="tool-row" style="border-bottom:0;">
                <div class="tool-label">Sitios</div>
                <div class="tool-value">No hay registros en el sistema</div>
              </div>
            </div>
          </div>
        ';
        }

        $tabla .= '
            </tbody>
          </table>
        </div>
      </div>
    ';

        $cards .= '
        </div>
      </div>
    ';

        $tabla .= $cards . '
      <div class="mt-2">
        <label class="form-label mb-0">Total registros: <strong>' . $total . '</strong></label>
      </div>
    </div>';

        return $tabla;
    }



    public function registrarTurnoControlador()
    {

        // Se obtienen y limpian los datos del formulario

        // Permisos para Usuarios
        $nombre_turno = $this->limpiarCadena($_POST['turno']);

        # Verificación de campos obligatorios #
        if ($nombre_turno == '') {
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
        if ($this->verificarDatos('[a-zA-ZáéíóúÁÉÍÓÚñÑ0-9 -]{3,40}', $nombre_turno)) {
            // Si el formato del nombre no es válido, se devuelve una alerta de error
            $alerta = [
                'tipo' => 'simple',
                'titulo' => 'Ocurrió un error inesperado',
                'texto' => 'El nombre del turno no cumple con el formato solicitado',
                'icono' => 'error'
            ];
            return json_encode($alerta);
            exit();
        }
        // Definición de un array asociativo $user_datos_reg que contiene los datos del rol a registrar
        // Array para almacenar los permisos
        $datos_reg = [
            [
                'campo_nombre' => 'nombre_turno',
                'campo_marcador' => ':nombre_turno',
                'campo_valor' => $nombre_turno =  mb_strtoupper($nombre_turno, 'UTF-8')
            ]
        ];

        // Llamada al método guardarDatos() para guardar los datos del usuario en la base de datos
        $registrar_dts = $this->guardarDatos('turno_trabajo', $datos_reg);

        if ($registrar_dts->rowCount() == 1) {
            // Si se registró correctamente, se devuelve un mensaje de éxito
            $alerta = [
                'tipo' => 'limpiar',
                'titulo' => 'Turno Registrado',
                'texto' => 'El Turno ' . $nombre_turno . ' se ha registrado con éxito',
                'icono' => 'success'
            ];
        } else {


            // Si no se pudo registrar, se devuelve un mensaje de error
            $alerta = [
                'tipo' => 'simple',
                'titulo' => 'Ocurrió un error inesperado',
                'texto' => 'El Turno no se pudo registrar correctamente',
                'icono' => 'error'
            ];
        }
        return json_encode($alerta);
    }

    public function listarTurnoControlador($busqueda)
    {
        $busqueda = $this->limpiarCadena($busqueda);

        $consulta_datos = "SELECT " . $this->columnasTablaSql('turno_trabajo') . " FROM turno_trabajo WHERE std_reg='1' ORDER BY id_ai_turno ASC";
        $consulta_total = "SELECT COUNT(id_ai_turno) FROM turno_trabajo WHERE std_reg='1'";

        $datos = $this->ejecutarConsulta($consulta_datos);
        $datos = $datos->fetchAll();

        $total = $this->ejecutarConsulta($consulta_total);
        $total = (int)$total->fetchColumn();

        $tabla = '
    <div class="turno-responsive p-3">

        <!-- DESKTOP: TABLA -->
        <div class="d-none d-md-block">
            <div class="table-responsive table-wrapper3" id="tabla-turno" style="max-height:70vh; overflow-y:auto;">
                <table class="table border mb-0 table-hover table-sm table-striped" id="tablaDatosTurno">
                    <thead class="table-light fw-semibold">
                        <tr class="align-middle">
                            <th class="clearfix">#</th>
                            <th class="clearfix">Nombre</th>
                            <th class="text-center" colspan="2">Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
    ';

        $cards = '
        <!-- MÓVIL: CARDS -->
        <div class="d-md-none p-3">
            <div class="tool-cards" id="toolCardsTurno">
    ';

        if ($total >= 1) {
            $contador = 1;

            foreach ($datos as $rows) {
                $id     = $rows["id_ai_turno"];
                $nombre = $rows["nombre_turno"];

                /* ===== TABLA DESKTOP ===== */
                $tabla .= '
                <tr class="align-middle">
                    <td class="col-p"><b>' . $contador . '</b></td>

                    <td><b>' . $nombre . '</b></td>

                    <td class="col-p text-center">
                        <a href="#" class="btn btn-warning text-dark js-turno-edit"
                           data-action="edit" data-id="' . $id . '" title="Modificar">
                            <i class="bi bi-pencil text-white"></i>
                        </a>
                    </td>

                    <td class="col-p text-center">
                        <a href="#" class="btn btn-danger js-turno-del"
                           data-action="delete" data-id="' . $id . '" title="Eliminar">
                            <i class="bi bi-trash" style="color:white;"></i>
                        </a>
                    </td>
                </tr>
            ';

                /* ===== CARDS MÓVIL ===== */
                $cards .= '
                <div class="tool-card">
                    <div class="tool-card-head">
                        <span class="tool-code">#' . $contador . ' • Turno</span>
                        <span><b>' . $nombre . '</b></span>
                    </div>

                    <div class="tool-body">
                        <div class="tool-row">
                            <div class="tool-label">Nombre</div>
                            <div class="tool-value">' . $nombre . '</div>
                        </div>

                        <div class="tool-actions">
                            <a href="#" class="btn btn-warning text-dark btn-sm js-turno-edit"
                               data-action="edit" data-id="' . $id . '" title="Modificar">
                                <i class="bi bi-pencil text-white"></i>
                            </a>

                            <a href="#" class="btn btn-danger btn-sm js-turno-del"
                               data-action="delete" data-id="' . $id . '" title="Eliminar">
                                <i class="bi bi-trash"></i>
                            </a>
                        </div>
                    </div>
                </div>
            ';

                $contador++;
            }
        } else {
            $tabla .= '
            <tr class="align-middle">
                <td class="text-center" colspan="4">No hay registros en el sistema</td>
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
                        <div class="tool-label">Turnos</div>
                        <div class="tool-value">No hay registros en el sistema</div>
                    </div>
                </div>
            </div>
        ';
        }

        $tabla .= '
                    </tbody>
                </table>
            </div>
        </div>
    ';

        $cards .= '
            </div>
        </div>
    ';

        $tabla .= $cards . '
        <div class="mt-2">
            <label class="form-label mb-0">Total registros: <strong>' . $total . '</strong></label>
        </div>
    </div>';

        return $tabla;
    }



    private function respuestaCheck($check)
    {
        $resp = '1';
        if ($check != 'on') {
            $resp = '0';
        }
        return $resp;
    }

    private function respuestaCheckOnOff($check)
    {
        $resp = 'checked';
        if ($check != '1') {
            $resp = '';
        }
        return $resp;
    }
}

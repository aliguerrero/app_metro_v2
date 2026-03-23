<?php

namespace app\controllers;

use app\models\mainModel;
use PDO;

class mainController extends mainModel
{

    # controlador listar actividades #

    public function listarActividadesControlador(){
        $tabla = '';
        if ($_SESSION['tipo'] == 1) {
            $consulta_datos = "SELECT 
                COALESCE(e.nombre_empleado, l.id_user) AS nombre_usuario,
                ROUND(((SELECT COUNT(1) FROM log_user WHERE id_user = l.id_user) / (SELECT COUNT(1) FROM log_user)) * 100, 2) AS porcentaje_participacion,
                MIN(l.fecha_hora) AS primera_fecha_registro,
                MAX(l.fecha_hora) AS ultima_fecha_registro
                FROM 
                    log_user l
                LEFT JOIN 
                    user_system u ON l.id_user = u.id_empleado
                LEFT JOIN
                    empleado e ON e.id_empleado = l.id_user
                GROUP BY
                    l.id_user, COALESCE(e.nombre_empleado, l.id_user);
                ";
            $consulta_total = "SELECT COUNT(DISTINCT l.id_user)
                FROM log_user l;";
        } else {
            $consulta_datos = "SELECT 
                COALESCE(e.nombre_empleado, l.id_user) AS nombre_usuario,
                ROUND(((SELECT COUNT(1) FROM log_user WHERE id_user = '" . $_SESSION['id'] . "') / (SELECT COUNT(1) FROM log_user)) * 100, 2) AS porcentaje_participacion,
                MIN(l.fecha_hora) AS primera_fecha_registro,
                MAX(l.fecha_hora) AS ultima_fecha_registro
                FROM 
                    log_user l
                LEFT JOIN 
                    user_system u ON l.id_user = u.id_empleado
                LEFT JOIN
                    empleado e ON e.id_empleado = l.id_user
                WHERE 
                l.id_user = '" . $_SESSION['id'] . "';";

            $consulta_total = "SELECT COUNT(1)
                FROM log_user l
                WHERE 
                l.id_user = '" . $_SESSION['id'] . "';";
        }

        $datos = $this->ejecutarConsulta($consulta_datos);
        $datos = $datos->fetchAll();

        $total = $this->ejecutarConsulta($consulta_total);
        $total = (int) $total->fetchColumn();


        $tabla .= '
            <div class="table-responsive">
                <table class="table border mb-0 table-sm table-hover table-sm table-striped">
                    <thead class="table-light fw-semibold">
                        <tr class="align-middle">
                            <th class="text-center">
                                <i class="bx bx-group"></i>
                            </th>
                                <th>Usuario</th>
                                <th>% InteracciÃ³n Sistema</th>
                                <th>Ultima Actividad</th>
                            </tr>
                    </thead>
                    <tbody>
        ';
        $contador = 0;
        if ($total >= 1) {
            $contador = $contador + 1;
            foreach ($datos as $rows) {
                $tabla .= '
                    <tr class="align-middle">
                        <td class="text-center">
                            <div class="avatar avatar-md">
                                <img class="avatar-img" src="' . APP_URL . 'app/views/img/avatars/user.png" alt="user@email.com">                                
                            </div>
                        </td>
                        <td>
                            <div>' . $rows['nombre_usuario'] . '</div>                            
                        </td>
                        <td>
                            <div class="clearfix">
                                <div class="float-start">
                                    <div class="fw-semibold">' . $rows['porcentaje_participacion'] . '%</div>
                                </div>
                                <div class="float-end">
                                    <small class="text-medium-emphasis">' . $rows['primera_fecha_registro'] . ' - ' . $rows['ultima_fecha_registro'] . '</small>
                                </div>
                            </div>
                            <div class="progress progress-thin">
                                <div class="progress-bar bg-success" role="progressbar"
                                    style="width: ' . $rows['porcentaje_participacion'] . '%" aria-valuenow="' . $rows['porcentaje_participacion'] . '" aria-valuemin="0"
                                    aria-valuemax="100">
                                </div>
                            </div>
                        </td>
                        <td>
                            <div class="small text-medium-emphasis">Ultimo inicio de sesion</div>
                            <div class="fw-semibold">' . $rows['ultima_fecha_registro'] . '</div>
                        </td>
                    </tr>
                ';
                $contador++;
            }
        } else {
            $tabla .= '
                <tr class="align-middle">
                    <td class="text-center">
                        No hay registros en el sistema
                    </td>
                </tr>
            ';
        }

        $tabla .= '</tbody></table></div>';

        return $tabla;
    }

    public function listarCardEstadoControlador(){
        $tabla = '';
        
        $consulta_datos = "SELECT 
            nombre_estado, 
            COUNT(1) AS total_registros,
            ROUND((COUNT(1) * 100.0) / SUM(COUNT(1)) OVER (), 2) AS porcentaje_total
            FROM vw_ot_resumen
            WHERE std_reg = 1
            GROUP BY id_ai_estado, nombre_estado;
        ";
        

        $datos = $this->ejecutarConsulta($consulta_datos);
        $datos = $datos ? $datos->fetchAll(\PDO::FETCH_ASSOC) : [];
        $total = count($datos);


        $contador = 0;
        if ($total >= 1) {
            $contador = $contador + 1;
            foreach ($datos as $rows) {
                $tabla .= '
                <div class="col mb-sm-2 mb-0">
                    <div class="text-medium-emphasis">' . $rows['nombre_estado'] . '</div>
                        <div class="fw-semibold">Total O.T. = ' . $rows['total_registros'] . ' (' . $rows['porcentaje_total'] . '%)</div>
                        <div class="progress progress-thin mt-2">
                        <div class="progress-bar bg-success" role="progressbar" style="width: ' . $rows['porcentaje_total'] . '%" aria-valuenow="' . $rows['porcentaje_total'] . '" aria-valuemin="0" aria-valuemax="100"></div>
                    </div>
                </div>
                ';
                $contador++;
            }
        } else {
            $tabla .= '
            <div class="col mb-sm-2 mb-0">
                <div class="text-medium-emphasis">Sin detalles registrados</div>
                    <div class="fw-semibold">Total 0 (0%)</div>
                    <div class="progress progress-thin mt-2">
                    <div class="progress-bar bg-success" role="progressbar" style="width: 100%" aria-valuenow="100" aria-valuemin="0" aria-valuemax="100"></div>
                </div>
            </div>
            ';
        }
        return $tabla;
    }

    public function listarCardTurnoControlador(){
        $tabla = '';
        
        $consulta_datos = "SELECT 
            nombre_turno, 
            COUNT(id_ai_detalle) AS total_registros,
            ROUND((COUNT(id_ai_detalle) * 100.0) / SUM(COUNT(id_ai_detalle)) OVER (), 2) AS porcentaje_total
            FROM vw_ot_detallada
            GROUP BY id_ai_turno, nombre_turno;
        ";
        

        $datos = $this->ejecutarConsulta($consulta_datos);
        $datos = $datos ? $datos->fetchAll(\PDO::FETCH_ASSOC) : [];
        $total = count($datos);


        $contador = 0;
        if ($total >= 1) {
            $contador = $contador + 1;
            foreach ($datos as $rows) {
                $tabla .= '
                <div class="col mb-sm-2 mb-0">
                    <div class="text-medium-emphasis">' . $rows['nombre_turno'] . '</div>
                        <div class="fw-semibold">Total O.T. = ' . $rows['total_registros'] . ' (' . $rows['porcentaje_total'] . '%)</div>
                        <div class="progress progress-thin mt-2">
                        <div class="progress-bar bg-success" role="progressbar" style="width: ' . $rows['porcentaje_total'] . '%" aria-valuenow="' . $rows['porcentaje_total'] . '" aria-valuemin="0" aria-valuemax="100"></div>
                    </div>
                </div>
                ';
                $contador++;
            }
        } else {
            $tabla .= '
            <div class="col mb-sm-2 mb-0">
                <div class="text-medium-emphasis">Sin detalles registrados</div>
                    <div class="fw-semibold">Total 0 (0%)</div>
                    <div class="progress progress-thin mt-2">
                    <div class="progress-bar bg-success" role="progressbar" style="width: 100%" aria-valuenow="100" aria-valuemin="0" aria-valuemax="100"></div>
                </div>
            </div>
            ';
        }
        return $tabla;
    }

    public function obtenerResumenDashboard(): array
    {
        $consulta = "
            SELECT
                (SELECT COUNT(1) FROM vw_ot_resumen WHERE std_reg = 1) AS total_ot,
                (SELECT COUNT(1) FROM vw_ot_detallada) AS total_detalles,
                (SELECT COUNT(1) FROM vw_ot_resumen WHERE std_reg = 1 AND COALESCE(bloquea_ot, 0) = 1) AS detalles_ejecutados,
                (SELECT COUNT(1) FROM vw_ot_resumen WHERE std_reg = 1 AND COALESCE(bloquea_ot, 0) <> 1) AS detalles_pendientes,
                (SELECT COUNT(1) FROM vw_herramienta_disponibilidad WHERE std_reg = 1) AS herramientas,
                (SELECT COUNT(1) FROM miembro WHERE std_reg = 1) AS miembros_activos,
                (SELECT COUNT(1) FROM vw_usuario_empleado WHERE std_reg = 1) AS usuarios_activos,
                (SELECT COUNT(1) FROM log_user WHERE fecha_hora >= DATE_SUB(NOW(), INTERVAL 7 DAY)) AS logs_semana
        ";

        $datos = $this->ejecutarConsulta($consulta);
        if (!$datos) {
            return [];
        }

        return $datos->fetch(PDO::FETCH_ASSOC) ?: [];
    }
}


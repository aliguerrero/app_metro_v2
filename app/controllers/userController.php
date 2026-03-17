<?php

namespace app\controllers;

use app\models\mainModel;
use PDO;

class userController extends mainModel
{
    private function esc(string $value): string
    {
        return htmlspecialchars($value, ENT_QUOTES, 'UTF-8');
    }

    private function validarIdEmpleado(string $idEmpleado): bool
    {
        return !$this->verificarDatos('[a-zA-Z0-9-]{3,30}', $idEmpleado);
    }

    private function validarUsername(string $username): bool
    {
        return !$this->verificarDatos('[a-zA-Z0-9]{4,20}', $username);
    }

    private function validarClave(string $clave): bool
    {
        return !$this->verificarDatos('[a-zA-Z0-9$@.-]{8,15}', $clave);
    }

    private function obtenerEmpleadoActivo(string $idEmpleado): ?array
    {
        $stmt = $this->ejecutarConsultaParams(
            "SELECT
                e.id_ai_empleado,
                e.id_empleado,
                e.nombre_empleado,
                e.id_ai_categoria_empleado,
                e.std_reg,
                COALESCE(c.nombre_categoria, 'SIN CATEGORIA') AS nombre_categoria
             FROM empleado e
             LEFT JOIN categoria_empleado c
               ON c.id_ai_categoria_empleado = e.id_ai_categoria_empleado
             WHERE e.id_empleado = :id
               AND e.std_reg = 1
             LIMIT 1",
            [':id' => $idEmpleado]
        );

        if (!$stmt || $stmt->rowCount() === 0) {
            return null;
        }

        return $stmt->fetch(PDO::FETCH_ASSOC) ?: null;
    }

    private function obtenerUsuarioPorId(string $idUser): ?array
    {
        $stmt = $this->ejecutarConsultaParams(
            "SELECT
                id_ai_user,
                id_empleado,
                username,
                password,
                tipo,
                std_reg
             FROM user_system
             WHERE id_empleado = :id
             LIMIT 1",
            [':id' => $idUser]
        );

        if (!$stmt || $stmt->rowCount() === 0) {
            return null;
        }

        return $stmt->fetch(PDO::FETCH_ASSOC) ?: null;
    }

    private function existeUsernameEnOtroUsuario(string $username, ?string $excludeIdUser = null): bool
    {
        $sql = "SELECT 1
                FROM user_system
                WHERE username = :username";
        $params = [':username' => $username];

        if ($excludeIdUser !== null && $excludeIdUser !== '') {
            $sql .= " AND id_empleado <> :exclude";
            $params[':exclude'] = $excludeIdUser;
        }

        $sql .= " LIMIT 1";

        $stmt = $this->ejecutarConsultaParams($sql, $params);
        return $stmt && $stmt->rowCount() > 0;
    }

    private function existeRol(string $tipo): bool
    {
        if ($tipo === '' || !ctype_digit($tipo)) {
            return false;
        }

        $stmt = $this->ejecutarConsultaParams(
            "SELECT 1 FROM roles_permisos WHERE id = :id LIMIT 1",
            [':id' => (int)$tipo]
        );

        return $stmt && $stmt->rowCount() > 0;
    }

    private function alerta(array $payload): string
    {
        return json_encode($payload, JSON_UNESCAPED_UNICODE);
    }

    public function registrarUserControlador()
    {
        $idEmpleado = $this->limpiarCadena($_POST['id_empleado'] ?? '');
        $username = $this->limpiarCadena($_POST['username'] ?? '');
        $clave1 = $this->limpiarCadena($_POST['clave1'] ?? '');
        $clave2 = $this->limpiarCadena($_POST['clave2'] ?? '');
        $tipo = $this->limpiarCadena($_POST['tipo1'] ?? '');

        if ($idEmpleado === '' || $username === '' || $clave1 === '' || $clave2 === '' || $tipo === '' || $tipo === 'Seleccionar') {
            return $this->alerta([
                'tipo' => 'simple',
                'titulo' => 'OcurriÃ³ un error inesperado',
                'texto' => 'No has llenado todos los campos que son obligatorios',
                'icono' => 'error',
            ]);
        }

        if (!$this->validarIdEmpleado($idEmpleado)) {
            return $this->alerta([
                'tipo' => 'simple',
                'titulo' => 'OcurriÃ³ un error inesperado',
                'texto' => 'El ID del empleado no cumple con el formato solicitado',
                'icono' => 'error',
            ]);
        }

        if (!$this->validarUsername($username)) {
            return $this->alerta([
                'tipo' => 'simple',
                'titulo' => 'OcurriÃ³ un error inesperado',
                'texto' => 'El username no cumple con el formato solicitado',
                'icono' => 'error',
            ]);
        }

        if ($clave1 !== $clave2) {
            return $this->alerta([
                'tipo' => 'simple',
                'titulo' => 'OcurriÃ³ un error inesperado',
                'texto' => 'Las claves no coinciden',
                'icono' => 'error',
            ]);
        }

        if (!$this->validarClave($clave1)) {
            return $this->alerta([
                'tipo' => 'simple',
                'titulo' => 'OcurriÃ³ un error inesperado',
                'texto' => 'La clave no cumple con el formato solicitado',
                'icono' => 'error',
            ]);
        }

        if (!$this->existeRol($tipo)) {
            return $this->alerta([
                'tipo' => 'simple',
                'titulo' => 'OcurriÃ³ un error inesperado',
                'texto' => 'Debes seleccionar un rol vÃ¡lido',
                'icono' => 'error',
            ]);
        }

        $empleado = $this->obtenerEmpleadoActivo($idEmpleado);
        if (!$empleado) {
            return $this->alerta([
                'tipo' => 'simple',
                'titulo' => 'OcurriÃ³ un error inesperado',
                'texto' => 'El empleado seleccionado no existe o estÃ¡ inactivo',
                'icono' => 'error',
            ]);
        }

        $usuarioExistente = $this->obtenerUsuarioPorId($idEmpleado);
        if ($usuarioExistente && (int)$usuarioExistente['std_reg'] === 1) {
            return $this->alerta([
                'tipo' => 'simple',
                'titulo' => 'OcurriÃ³ un error inesperado',
                'texto' => 'Ese empleado ya tiene un usuario del sistema asociado',
                'icono' => 'error',
            ]);
        }

        if ($this->existeUsernameEnOtroUsuario($username, $usuarioExistente['id_empleado'] ?? null)) {
            return $this->alerta([
                'tipo' => 'simple',
                'titulo' => 'OcurriÃ³ un error inesperado',
                'texto' => 'El username ingresado ya existe en los registros',
                'icono' => 'error',
            ]);
        }

        $clave = password_hash($clave1, PASSWORD_BCRYPT, ['cost' => 10]);
        $nombreEmpleado = (string)$empleado['nombre_empleado'];

        if ($usuarioExistente) {
            $stmt = $this->ejecutarConsultaParams(
                "UPDATE user_system
                 SET username = :username,
                     password = :password,
                     tipo = :tipo,
                     std_reg = 1
                 WHERE id_empleado = :id",
                [
                    ':username' => $username,
                    ':password' => $clave,
                    ':tipo' => (int)$tipo,
                    ':id' => $idEmpleado,
                ]
            );
        } else {
            $stmt = $this->ejecutarConsultaParams(
                "INSERT INTO user_system (id_empleado, username, password, tipo, std_reg)
                 VALUES (:id, :username, :password, :tipo, 1)",
                [
                    ':id' => $idEmpleado,
                    ':username' => $username,
                    ':password' => $clave,
                    ':tipo' => (int)$tipo,
                ]
            );
        }

        if ($stmt) {
            return $this->alerta([
                'tipo' => 'limpiar',
                'titulo' => 'Usuario Registrado',
                'texto' => 'El usuario del empleado ' . $nombreEmpleado . ' se ha registrado con Ã©xito',
                'icono' => 'success',
            ]);
        }

        return $this->alerta([
            'tipo' => 'simple',
            'titulo' => 'OcurriÃ³ un error inesperado',
            'texto' => 'El usuario no se pudo registrar correctamente',
            'icono' => 'error',
        ]);
    }

    public function listarUsuarioControlador()
    {
        $this->requirePerm('perm_usuarios_view');

        $perms = $_SESSION['permisos'] ?? [];
        $canEdit = !empty($perms['perm_usuarios_edit']) && (int)$perms['perm_usuarios_edit'] === 1;
        $canDelete = !empty($perms['perm_usuarios_delete']) && (int)$perms['perm_usuarios_delete'] === 1;

        $stmt = $this->ejecutarConsultaParams(
            "SELECT
                u.id_ai_user,
                u.id_empleado AS id_user,
                u.username,
                u.tipo,
                COALESCE(NULLIF(e.nombre_empleado, ''), u.id_empleado) AS nombre_empleado,
                COALESCE(c.nombre_categoria, 'SIN CATEGORIA') AS nombre_categoria,
                r.nombre_rol
             FROM user_system u
             INNER JOIN roles_permisos r
               ON r.id = u.tipo
             LEFT JOIN empleado e
               ON e.id_empleado = u.id_empleado
             LEFT JOIN categoria_empleado c
               ON c.id_ai_categoria_empleado = e.id_ai_categoria_empleado
             WHERE u.id_empleado <> :sessionId
               AND u.std_reg = 1
             ORDER BY COALESCE(NULLIF(e.nombre_empleado, ''), u.id_empleado) ASC",
            [':sessionId' => $_SESSION['id'] ?? '']
        );

        $rows = $stmt ? $stmt->fetchAll(PDO::FETCH_ASSOC) : [];
        $total = count($rows);

        $tabla = '
        <div class="usuario-responsive">
            <div class="d-none d-md-block">
                <div class="table-responsive table-wrapper3" id="tabla-ot" style="max-height:70vh; overflow-y:auto;">
                    <table class="table border mb-0 table-hover table-sm table-striped" id="tablaDatosUser">
                        <thead class="table-light fw-semibold">
                            <tr class="align-middle">
                                <th>#</th>
                                <th class="text-center"><i class="bx bx-group fs-5" aria-hidden="true"></i></th>
                                <th>ID Empleado</th>
                                <th>Empleado</th>
                                <th>Categoria</th>
                                <th>Username</th>
                                <th>Rol</th>
                                <th class="text-center" colspan="3">Acciones</th>
                            </tr>
                        </thead>
                        <tbody>';

        $cards = '
            <div class="d-md-none">
                <div class="tool-cards" id="toolCardsUser">';

        if ($total > 0) {
            $contador = 1;

            foreach ($rows as $row) {
                $idUser = (string)$row['id_user'];
                $nombreEmpleado = (string)$row['nombre_empleado'];
                $categoria = (string)$row['nombre_categoria'];
                $username = (string)$row['username'];
                $rol = (string)$row['nombre_rol'];

                $tabla .= '
                    <tr class="align-middle">
                        <td><b>' . $contador . '</b></td>
                        <td class="text-center">
                            <div class="avatar avatar-md">
                                <img class="avatar-img" src="' . APP_URL . 'app/views/img/avatars/user.png" alt="avatar de usuario">
                            </div>
                        </td>
                        <td><b>' . $this->esc($idUser) . '</b></td>
                        <td><b>' . $this->esc($nombreEmpleado) . '</b></td>
                        <td>' . $this->esc($categoria) . '</td>
                        <td>@' . $this->esc($username) . '</td>
                        <td><div class="text-center"><b>' . $this->esc($rol) . '</b></div></td>
                        ' . ($canEdit
                            ? '<td class="col-p">
                            <a href="#" title="Cambiar Clave" class="btn btn-dark text-white"
                               data-bs-toggle="modal" data-bs-target="#ventanaModalModificarPass" data-bs-id="' . $this->esc($idUser) . '">
                                <i class="bi bi-lock"></i>
                            </a>
                        </td>'
                            : '<td class="col-p"></td>') . '';

                if ($canEdit) {
                    $tabla .= '
                        <td class="col-p">
                            <a href="#" title="Modificar" class="btn btn-warning text-dark"
                               data-bs-toggle="modal" data-bs-target="#ventanaModalModificar" data-bs-id="' . $this->esc($idUser) . '">
                                <i class="bi bi-pencil text-white"></i>
                            </a>
                        </td>';
                } else {
                    $tabla .= '<td class="col-p"></td>';
                }

                if ($canDelete) {
                    $tabla .= '
                        <td class="col-p">
                            <form class="FormularioAjax" action="' . APP_URL . 'app/ajax/userAjax.php" method="POST">
                                <input type="hidden" name="modulo_user" value="eliminar">
                                <input type="hidden" name="id_user" value="' . $this->esc($idUser) . '">
                                <button type="submit" class="btn btn-danger" title="Eliminar">
                                    <i class="bi bi-trash" style="color:white;"></i>
                                </button>
                            </form>
                        </td>';
                } else {
                    $tabla .= '<td class="col-p"></td>';
                }

                $tabla .= '</tr>';

                $cards .= '
                    <div class="tool-card">
                        <div class="tool-card-head">
                            <span class="tool-code">#' . $contador . ' - ' . $this->esc($idUser) . '</span>
                            <span><b>Rol:</b> ' . $this->esc($rol) . '</span>
                        </div>
                        <div class="tool-body">
                            <div class="tool-row">
                                <div class="tool-label">Empleado</div>
                                <div class="tool-value">' . $this->esc($nombreEmpleado) . '</div>
                            </div>
                            <div class="tool-row">
                                <div class="tool-label">Categoria</div>
                                <div class="tool-value">' . $this->esc($categoria) . '</div>
                            </div>
                            <div class="tool-row">
                                <div class="tool-label">Username</div>
                                <div class="tool-value">@' . $this->esc($username) . '</div>
                            </div>
                            <div class="tool-actions">';

                if ($canEdit) {
                    $cards .= '
                                <a href="#" title="Cambiar Clave" class="btn btn-dark text-white btn-sm"
                                   data-bs-toggle="modal" data-bs-target="#ventanaModalModificarPass" data-bs-id="' . $this->esc($idUser) . '">
                                    <i class="bi bi-lock"></i>
                                </a>';
                }

                if ($canEdit) {
                    $cards .= '
                                <a href="#" title="Modificar" class="btn btn-warning text-dark btn-sm"
                                   data-bs-toggle="modal" data-bs-target="#ventanaModalModificar" data-bs-id="' . $this->esc($idUser) . '">
                                    <i class="bi bi-pencil text-white"></i>
                                </a>';
                }

                if ($canDelete) {
                    $cards .= '
                                <form class="FormularioAjax d-inline" action="' . APP_URL . 'app/ajax/userAjax.php" method="POST">
                                    <input type="hidden" name="modulo_user" value="eliminar">
                                    <input type="hidden" name="id_user" value="' . $this->esc($idUser) . '">
                                    <button type="submit" class="btn btn-danger btn-sm" title="Eliminar">
                                        <i class="bi bi-trash"></i>
                                    </button>
                                </form>';
                }

                $cards .= '
                            </div>
                        </div>
                    </div>';

                $contador++;
            }
        } else {
            $tabla .= '
                <tr class="align-middle">
                    <td class="text-center" colspan="10">No hay registros en el sistema</td>
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
                            <div class="tool-value">No hay registros en el sistema</div>
                        </div>
                    </div>
                </div>';
        }

        $tabla .= '</tbody></table></div></div>';
        $cards .= '</div></div>';

        return $tabla . $cards . '</div>';
    }

    public function listarComboRolesControlador($tipo)
    {
        $stmt = $this->ejecutarConsultaParams(
            'SELECT id, nombre_rol FROM roles_permisos WHERE id != 1 ORDER BY nombre_rol ASC'
        );

        $rows = $stmt ? $stmt->fetchAll(PDO::FETCH_ASSOC) : [];

        $combo = '
            <label class="form-label">TIPO DE USUARIO</label>
            <select class="form-select" name="' . $this->esc((string)$tipo) . '" id="' . $this->esc((string)$tipo) . '" aria-label="Listado de roles">
                <option selected>Seleccionar</option>';

        foreach ($rows as $row) {
            $combo .= '<option value="' . (int)$row['id'] . '">' . $this->esc((string)$row['nombre_rol']) . '</option>';
        }

        $combo .= '</select>';

        return $combo;
    }

    public function eliminarUserControlador()
    {
        $id = $this->limpiarCadena($_POST['id_user'] ?? '');

        if ($id === '' || $id === ($_SESSION['id'] ?? '')) {
            return $this->alerta([
                'tipo' => 'simple',
                'titulo' => 'OcurriÃ³ un error inesperado',
                'texto' => 'No podemos eliminar este usuario',
                'icono' => 'error',
            ]);
        }

        $usuario = $this->obtenerUsuarioPorId($id);
        if (!$usuario) {
            return $this->alerta([
                'tipo' => 'simple',
                'titulo' => 'OcurriÃ³ un error inesperado',
                'texto' => 'No hemos encontrado el usuario en el sistema',
                'icono' => 'error',
            ]);
        }

        $stmt = $this->ejecutarConsultaParams(
            "UPDATE user_system
             SET std_reg = 0
             WHERE id_empleado = :id
               AND id_empleado <> :sessionUser",
            [
                ':id' => $id,
                ':sessionUser' => $_SESSION['id'] ?? '',
            ]
        );

        if ($stmt && $stmt->rowCount() > 0) {
            return $this->alerta([
                'tipo' => 'recargar',
                'titulo' => 'Usuario Eliminado',
                'texto' => 'El usuario ha sido eliminado con exito',
                'icono' => 'success',
            ]);
        }

        return $this->alerta([
            'tipo' => 'simple',
            'titulo' => 'OcurriÃ³ un error inesperado',
            'texto' => 'No se pudo eliminar el usuario, por favor intente nuevamente',
            'icono' => 'error',
        ]);
    }

    public function actualizarDatosUser()
    {
        $idActual = $this->limpiarCadena($_POST['id'] ?? '');
        $idEmpleado = $this->limpiarCadena($_POST['id_empleado'] ?? '');
        $username = $this->limpiarCadena($_POST['username'] ?? '');
        $tipo = $this->limpiarCadena($_POST['tipo2'] ?? '');

        if ($idActual === '' || $idEmpleado === '' || $username === '' || $tipo === '' || $tipo === 'Seleccionar') {
            return $this->alerta([
                'tipo' => 'simple',
                'titulo' => 'OcurriÃ³ un error inesperado',
                'texto' => 'No has llenado todos los campos que son obligatorios',
                'icono' => 'error',
            ]);
        }

        if (!$this->validarIdEmpleado($idEmpleado)) {
            return $this->alerta([
                'tipo' => 'simple',
                'titulo' => 'OcurriÃ³ un error inesperado',
                'texto' => 'El ID del empleado no cumple con el formato solicitado',
                'icono' => 'error',
            ]);
        }

        if (!$this->validarUsername($username)) {
            return $this->alerta([
                'tipo' => 'simple',
                'titulo' => 'OcurriÃ³ un error inesperado',
                'texto' => 'El USERNAME no cumple con el formato solicitado',
                'icono' => 'error',
            ]);
        }

        if (!$this->existeRol($tipo)) {
            return $this->alerta([
                'tipo' => 'simple',
                'titulo' => 'OcurriÃ³ un error inesperado',
                'texto' => 'Debes seleccionar un rol vÃ¡lido',
                'icono' => 'error',
            ]);
        }

        $empleado = $this->obtenerEmpleadoActivo($idEmpleado);
        if (!$empleado) {
            return $this->alerta([
                'tipo' => 'simple',
                'titulo' => 'OcurriÃ³ un error inesperado',
                'texto' => 'El empleado seleccionado no existe o estÃ¡ inactivo',
                'icono' => 'error',
            ]);
        }

        $usuarioActual = $this->obtenerUsuarioPorId($idActual);
        if (!$usuarioActual) {
            return $this->alerta([
                'tipo' => 'simple',
                'titulo' => 'OcurriÃ³ un error inesperado',
                'texto' => 'No hemos encontrado el usuario en el sistema',
                'icono' => 'error',
            ]);
        }

        $usuarioConEmpleado = $this->obtenerUsuarioPorId($idEmpleado);
        if ($usuarioConEmpleado && $idEmpleado !== $idActual) {
            return $this->alerta([
                'tipo' => 'simple',
                'titulo' => 'OcurriÃ³ un error inesperado',
                'texto' => 'Ese empleado ya tiene un usuario del sistema asociado',
                'icono' => 'error',
            ]);
        }

        if ($this->existeUsernameEnOtroUsuario($username, $idActual)) {
            return $this->alerta([
                'tipo' => 'simple',
                'titulo' => 'OcurriÃ³ un error inesperado',
                'texto' => 'El USERNAME ingresado ya existe en los registros',
                'icono' => 'error',
            ]);
        }

        $stmt = $this->ejecutarConsultaParams(
            "UPDATE user_system
             SET id_empleado = :idEmpleado,
                 username = :username,
                 tipo = :tipo
             WHERE id_empleado = :idActual",
            [
                ':idEmpleado' => $idEmpleado,
                ':username' => $username,
                ':tipo' => (int)$tipo,
                ':idActual' => $idActual,
            ]
        );

        if ($stmt) {
            return $this->alerta([
                'tipo' => 'limpiar',
                'titulo' => 'Datos Actualizados',
                'texto' => 'Se actualizo correctamente',
                'icono' => 'success',
            ]);
        }

        return $this->alerta([
            'tipo' => 'simple',
            'titulo' => 'OcurriÃ³ un error inesperado',
            'texto' => 'Ha ocurrido un error durante la actualizacion',
            'icono' => 'error',
        ]);
    }

    public function actualizarDatosUserSesion()
    {
        $idActual = (string)($_SESSION['id_user'] ?? ($_SESSION['id'] ?? ''));
        $username = $this->limpiarCadena($_POST['username'] ?? '');
        $clave1 = $this->limpiarCadena($_POST['clave1'] ?? '');
        $clave2 = $this->limpiarCadena($_POST['clave2'] ?? '');

        if ($idActual === '' || $username === '') {
            return $this->alerta([
                'tipo' => 'simple',
                'titulo' => 'OcurriÃ³ un error inesperado',
                'texto' => 'No has llenado todos los campos que son obligatorios',
                'icono' => 'error',
            ]);
        }

        if (!$this->validarUsername($username)) {
            return $this->alerta([
                'tipo' => 'simple',
                'titulo' => 'OcurriÃ³ un error inesperado',
                'texto' => 'El USERNAME no cumple con el formato solicitado',
                'icono' => 'error',
            ]);
        }

        if ($this->existeUsernameEnOtroUsuario($username, $idActual)) {
            return $this->alerta([
                'tipo' => 'simple',
                'titulo' => 'OcurriÃ³ un error inesperado',
                'texto' => 'El USERNAME ingresado ya existe en los registros',
                'icono' => 'error',
            ]);
        }

        $params = [
            ':username' => $username,
            ':id' => $idActual,
        ];

        $sql = "UPDATE user_system SET username = :username";

        if ($clave1 !== '' || $clave2 !== '') {
            if ($clave1 === '' || $clave2 === '') {
                return $this->alerta([
                    'tipo' => 'simple',
                    'titulo' => 'OcurriÃ³ un error inesperado',
                    'texto' => 'Debes completar ambos campos de clave para actualizarla',
                    'icono' => 'error',
                ]);
            }

            if ($clave1 !== $clave2) {
                return $this->alerta([
                    'tipo' => 'simple',
                    'titulo' => 'OcurriÃ³ un error inesperado',
                    'texto' => 'Las claves no coinciden',
                    'icono' => 'error',
                ]);
            }

            if (!$this->validarClave($clave1)) {
                return $this->alerta([
                    'tipo' => 'simple',
                    'titulo' => 'OcurriÃ³ un error inesperado',
                    'texto' => 'La clave no cumple con el formato solicitado',
                    'icono' => 'error',
                ]);
            }

            $sql .= ", password = :password";
            $params[':password'] = password_hash($clave1, PASSWORD_BCRYPT, ['cost' => 10]);
        }

        $sql .= " WHERE id_empleado = :id";

        $stmt = $this->ejecutarConsultaParams($sql, $params);

        if ($stmt) {
            return $this->alerta([
                'tipo' => 'cerrar',
                'titulo' => 'Datos Actualizados',
                'texto' => 'Tus datos de acceso fueron actualizados. Debes iniciar sesion nuevamente para aplicar los cambios.',
                'icono' => 'success',
            ]);
        }

        return $this->alerta([
            'tipo' => 'simple',
            'titulo' => 'OcurriÃ³ un error inesperado',
            'texto' => 'Ha ocurrido un error durante la actualizacion',
            'icono' => 'error',
        ]);
    }

    public function actualizarClaveUser()
    {
        $id = $this->limpiarCadena($_POST['id2'] ?? '');
        $clave1 = $this->limpiarCadena($_POST['clave1'] ?? '');
        $clave2 = $this->limpiarCadena($_POST['clave2'] ?? '');

        if ($id === '' || $clave1 === '' || $clave2 === '') {
            return $this->alerta([
                'tipo' => 'simple',
                'titulo' => 'OcurriÃ³ un error inesperado',
                'texto' => 'No has llenado todos los campos que son obligatorios',
                'icono' => 'error',
            ]);
        }

        if ($clave1 !== $clave2) {
            return $this->alerta([
                'tipo' => 'simple',
                'titulo' => 'OcurriÃ³ un error inesperado',
                'texto' => 'Las claves no coinciden',
                'icono' => 'error',
            ]);
        }

        if (!$this->validarClave($clave1)) {
            return $this->alerta([
                'tipo' => 'simple',
                'titulo' => 'OcurriÃ³ un error inesperado',
                'texto' => 'La clave no cumple con el formato solicitado',
                'icono' => 'error',
            ]);
        }

        $stmt = $this->ejecutarConsultaParams(
            "UPDATE user_system
             SET password = :password
             WHERE id_empleado = :id",
            [
                ':password' => password_hash($clave1, PASSWORD_BCRYPT, ['cost' => 10]),
                ':id' => $id,
            ]
        );

        if ($stmt) {
            return $this->alerta([
                'tipo' => 'limpiar',
                'titulo' => 'ContraseÃ±a Actualizada',
                'texto' => 'Se actualizo correctamente',
                'icono' => 'success',
            ]);
        }

        return $this->alerta([
            'tipo' => 'simple',
            'titulo' => 'OcurriÃ³ un error inesperado',
            'texto' => 'Ha ocurrido un error durante la actualizacion',
            'icono' => 'error',
        ]);
    }

    public function cerrarSesionControlador()
    {
        session_destroy();

        if (headers_sent()) {
            echo "<script>window.location.href='" . APP_URL . "login/';</script>";
            return;
        }

        header('Location: ' . APP_URL . 'login/');
        exit();
    }
}

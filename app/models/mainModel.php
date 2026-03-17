<?php

namespace app\models;

use PDO;
use PDOException;
use Exception;

if (file_exists(__DIR__ . '/../../config/server.php')) {
    require_once __DIR__ . '/../../config/server.php';
}

class mainModel
{
    private string $server = DB_SERVER;
    private string $db     = DB_NAME;
    private string $user   = DB_USER;
    private string $pass   = DB_PASS;

    private ?PDO $pdo = null;

    private ?string $appUserSet = null;
    private static array $tableColumnsCache = [];
    private const KNOWN_TABLE_COLUMNS = [
        'area_trabajo' => ['id_ai_area', 'nombre_area', 'nomeclatura', 'std_reg'],
        'backup_auto_config' => ['id', 'enabled', 'frequency', 'run_time', 'weekday', 'month_day', 'mode', 'tables_json', 'retain_count', 'runner_token', 'last_run_at', 'last_file', 'updated_at'],
        'categoria_empleado' => ['id_ai_categoria_empleado', 'nombre_categoria', 'descripcion', 'std_reg'],
        'categoria_herramienta' => ['id_ai_categoria_herramienta', 'nombre_categoria', 'descripcion', 'std_reg'],
        'detalle_orden' => ['id_ai_detalle', 'n_ot', 'fecha', 'descripcion', 'id_ai_turno', 'id_miembro_cco', 'id_user_act', 'id_miembro_ccf', 'id_ai_estado', 'cant_tec', 'hora_ini_pre', 'hora_fin_pre', 'hora_ini_tra', 'hora_fin_tra', 'hora_ini_eje', 'hora_fin_eje', 'observacion'],
        'empleado' => ['id_ai_empleado', 'id_empleado', 'nacionalidad', 'nombre_empleado', 'telefono', 'direccion', 'correo', 'id_ai_categoria_empleado', 'std_reg'],
        'empresa_config' => ['id', 'nombre', 'rif', 'direccion', 'telefono', 'email', 'logo', 'created_at', 'updated_at'],
        'estado_ot' => ['id_ai_estado', 'nombre_estado', 'color', 'std_reg'],
        'herramienta' => ['id_ai_herramienta', 'nombre_herramienta', 'id_ai_categoria_herramienta', 'cantidad', 'estado', 'std_reg'],
        'herramientaot' => ['id_ai_herramientaOT', 'id_ai_herramienta', 'n_ot', 'cantidadot', 'estadoot'],
        'log_user' => ['id_log', 'event_uuid', 'id_user', 'tabla', 'operacion', 'pk_registro', 'pk_json', 'accion', 'resp_system', 'data_old', 'data_new', 'data_diff', 'fecha_hora', 'connection_id', 'db_user', 'db_host', 'changed_cols', 'std_reg'],
        'miembro' => ['id_ai_miembro', 'id_miembro', 'nombre_miembro', 'tipo_miembro', 'std_reg'],
        'orden_trabajo' => ['id_ai_ot', 'n_ot', 'id_ai_area', 'id_user', 'id_ai_sitio', 'nombre_trab', 'fecha', 'semana', 'mes', 'std_reg'],
        'reporte_generado' => ['id_ai_reporte_generado', 'tipo_reporte', 'titulo_reporte', 'nombre_archivo', 'ruta_archivo', 'mime_type', 'tamano_bytes', 'parametros_json', 'id_user_generador', 'nombre_user_generador', 'username_generador', 'created_at', 'std_reg'],
        'roles_permisos' => ['id', 'nombre_rol', 'perm_usuarios_view', 'perm_usuarios_add', 'perm_usuarios_edit', 'perm_usuarios_delete', 'perm_herramienta_view', 'perm_herramienta_add', 'perm_herramienta_edit', 'perm_herramienta_delete', 'perm_miembro_view', 'perm_miembro_add', 'perm_miembro_edit', 'perm_miembro_delete', 'perm_ot_view', 'perm_ot_add', 'perm_ot_edit', 'perm_ot_delete', 'perm_ot_add_detalle', 'perm_ot_generar_reporte', 'perm_ot_add_herramienta'],
        'sitio_trabajo' => ['id_ai_sitio', 'nombre_sitio', 'std_reg'],
        'smtp_config' => ['id', 'enabled', 'provider', 'host', 'port', 'encryption', 'username', 'password', 'from_email', 'from_name', 'created_at', 'updated_at'],
        'turno_trabajo' => ['id_ai_turno', 'nombre_turno', 'std_reg'],
        'user_system' => ['id_ai_user', 'id_empleado', 'username', 'password', 'tipo', 'std_reg'],
    ];

    protected function conectar(): PDO
    {
        try {
            if ($this->pdo instanceof PDO) {
                $this->ensureAppUserContext();
                return $this->pdo;
            }

            $this->appUserSet = null;

            $dsn = "mysql:host={$this->server};dbname={$this->db};charset=utf8mb4";

            $options = [
                PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES   => false,
                // PDO::ATTR_PERSISTENT => false,
            ];

            // Cuenta operativa dedicada de la app
            $this->pdo = new PDO($dsn, $this->user, $this->pass, $options);

            $this->pdo->exec("SET NAMES utf8mb4");
            $this->pdo->exec("SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED");

            $this->ensureAppUserContext();

            return $this->pdo;
        } catch (PDOException $e) {
            throw new PDOException('Error al conectar con la base de datos: ' . $e->getMessage(), (int)$e->getCode());
        }
    }

    /**
     * Setea @app_user para auditoría por triggers.
     * ✅ Mejora: fallback consistente -> id_user (preferido) o id (compatibilidad).
     */
    private function ensureAppUserContext(): void
    {
        if (!$this->pdo) return;

        if (!isset($_SESSION) || empty($_SESSION)) return;

        // ✅ preferimos id_user, pero aceptamos id por compatibilidad
        $idUser = $_SESSION['id_user'] ?? ($_SESSION['id'] ?? null);
        if (empty($idUser)) return;

        $idUser = (string)$idUser;

        if ($this->appUserSet === $idUser) return;

        $stmt = $this->pdo->prepare("SET @app_user = :id_user");
        $stmt->execute([':id_user' => $idUser]);

        $this->appUserSet = $idUser;
    }

    public function setAppUser(string $idUser): void
    {
        $pdo = $this->conectar();
        $stmt = $pdo->prepare("SET @app_user = :id_user");
        $stmt->execute([':id_user' => $idUser]);
        $this->appUserSet = $idUser;
    }

    public function beginTransaction(): void
    {
        $this->conectar()->beginTransaction();
    }

    public function commit(): void
    {
        $pdo = $this->conectar();
        if ($pdo->inTransaction()) {
            $pdo->commit();
        }
    }

    public function rollBack(): void
    {
        $pdo = $this->conectar();
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
    }

    public function inTransaction(): bool
    {
        return $this->conectar()->inTransaction();
    }

    protected function ordenarFecha($fecha)
    {
        return date('d/m/Y', strtotime($fecha));
    }

    private function validarIdentificador(string $identificador): string
    {
        if (!preg_match('/^[a-zA-Z0-9_]+$/', $identificador)) {
            throw new Exception("Identificador SQL inválido: " . $identificador);
        }
        return $identificador;
    }

    private function q(string $identificador): string
    {
        return '`' . $this->validarIdentificador($identificador) . '`';
    }

    protected function tableHasColumn(string $table, string $column): bool
    {
        try {
            $table = $this->validarIdentificador($table);
            $column = $this->validarIdentificador($column);

            $sql = "SELECT COUNT(1) FROM INFORMATION_SCHEMA.COLUMNS
                    WHERE TABLE_SCHEMA = :schema
                      AND TABLE_NAME = :table
                      AND COLUMN_NAME = :column";

            $stmt = $this->conectar()->prepare($sql);
            $stmt->execute([
                ':schema' => $this->db,
                ':table' => $table,
                ':column' => $column
            ]);

            return ((int)$stmt->fetchColumn()) > 0;
        } catch (\Throwable $e) {
            return false;
        }
    }

    public function columnasTabla(string $table): array
    {
        $table = $this->validarIdentificador($table);

        if (isset(self::$tableColumnsCache[$table])) {
            return self::$tableColumnsCache[$table];
        }

        if (isset(self::KNOWN_TABLE_COLUMNS[$table])) {
            return self::$tableColumnsCache[$table] = self::KNOWN_TABLE_COLUMNS[$table];
        }

        $stmt = $this->conectar()->prepare(
            "SELECT COLUMN_NAME
             FROM INFORMATION_SCHEMA.COLUMNS
             WHERE TABLE_SCHEMA = :schema
               AND TABLE_NAME = :table
             ORDER BY ORDINAL_POSITION ASC"
        );
        $stmt->execute([
            ':schema' => $this->db,
            ':table' => $table
        ]);

        $cols = $stmt->fetchAll(PDO::FETCH_COLUMN);
        if (!is_array($cols) || $cols === []) {
            throw new Exception("No se encontraron columnas para la tabla {$table}");
        }

        return self::$tableColumnsCache[$table] = array_values($cols);
    }

    public function columnasTablaSql(string $table, string $alias = '', array $exclude = []): string
    {
        $cols = $this->columnasTabla($table);
        if ($exclude !== []) {
            $exclude = array_map(fn($col) => $this->validarIdentificador((string)$col), $exclude);
            $cols = array_values(array_filter($cols, fn($col) => !in_array($col, $exclude, true)));
        }

        $prefix = '';
        if ($alias !== '') {
            $prefix = $this->q($alias) . '.';
        }

        return implode(', ', array_map(function (string $col) use ($prefix) {
            return $prefix . $this->q($col);
        }, $cols));
    }

    protected function ejecutarConsulta($consulta)
    {
        try {
            $pdo = $this->conectar();
            $sql = $pdo->prepare($consulta);

            if ($sql->execute()) {
                return $sql;
            }
            return false;
        } catch (PDOException $e) {
            throw new Exception('Error al ejecutar la consulta SQL: ' . $e->getMessage());
        }
    }

    protected function ejecutarConsultaParams(string $consulta, array $params = [])
    {
        try {
            $pdo = $this->conectar();
            $sql = $pdo->prepare($consulta);

            if ($sql->execute($params)) {
                return $sql;
            }
            return false;
        } catch (PDOException $e) {
            throw new Exception('Error al ejecutar la consulta SQL (params): ' . $e->getMessage());
        }
    }

    public function ejecutarConsultaConParametros(string $consulta, array $params = [])
    {
        return $this->ejecutarConsultaParams($consulta, $params);
    }

    protected function hasPerm(string $permKey): bool
    {
        // ✅ Mejora: fallback consistente
        $idUser = $_SESSION['id_user'] ?? ($_SESSION['id'] ?? null);
        if (!isset($_SESSION) || empty($idUser)) {
            return false;
        }

        if (isset($_SESSION['tipo']) && (int)$_SESSION['tipo'] === 1) {
            return true;
        }

        $perms = $_SESSION['permisos'] ?? [];
        return isset($perms[$permKey]) && (int)$perms[$permKey] === 1;
    }

    protected function requireAdmin(): void
    {
        if (isset($_SESSION['tipo']) && (int)$_SESSION['tipo'] === 1) {
            return;
        }
        echo json_encode([
            'tipo' => 'simple',
            'titulo' => 'Acceso denegado',
            'texto' => 'Solo un administrador puede realizar esta acción',
            'icono' => 'error'
        ]);
        exit();
    }

    protected function requirePerm(string $permKey): void
    {
        $perms = $_SESSION['permisos'] ?? [];
        if (empty($perms[$permKey]) || (int)$perms[$permKey] !== 1) {
            echo json_encode([
                "tipo" => "simple",
                "titulo" => "Acceso denegado",
                "texto" => "No tienes permisos para realizar esta acción",
                "icono" => "error"
            ]);
            exit();
        }
    }
    
    

    public function ejecutarConsultas($consulta)
    {
        return $this->ejecutarConsulta($consulta);
    }

    public function ejecutarSqlUpdate($tabla, $datos, $condicion)
    {
        return $this->actualizarDatos($tabla, $datos, $condicion);
    }

    public function ejecutarSqlUpdateOT($consulta, $datos)
    {
        return $this->actualizarDatosHerramientaOt($consulta, $datos);
    }

    public function limpiarCadena($cadena)
    {
        $palabras = [
            '<script>',
            '</script>',
            '<script src',
            '<script type=',
            'SELECT ',
            ' SELECT ',
            'DELETE FROM',
            'INSERT INTO',
            'DROP TABLE',
            'DROP DATABASE',
            'TRUNCATE TABLE',
            'SHOW TABLES',
            'SHOW DATABASES',
            '<?php',
            '?>',
            '--',
            '^',
            '<',
            '>',
            '==',
            '=',
            ';',
            '::'
        ];
        $cadena = trim($cadena);
        $cadena = stripslashes($cadena);
        foreach ($palabras as $palabra) {
            $cadena = str_ireplace($palabra, '', $cadena);
        }
        $cadena = htmlspecialchars($cadena);
        $cadena = trim($cadena);
        $cadena = stripslashes($cadena);
        return $cadena;
    }

    public function verificarDatos($filtro, $cadena)
    {
        return !preg_match('~^' . $filtro . '$~u', $cadena);
    }

    protected function guardarDatos($tabla, $datos)
    {
        $tablaQ = $this->q($tabla);

        $cols = [];
        $marks = [];
        foreach ($datos as $d) {
            $cols[]  = $this->q($d['campo_nombre']);
            $marks[] = $d['campo_marcador'];
        }

        $query = "INSERT INTO {$tablaQ} (" . implode(',', $cols) . ") VALUES (" . implode(',', $marks) . ")";
        $sql = $this->conectar()->prepare($query);

        foreach ($datos as $d) {
            $sql->bindValue($d['campo_marcador'], $d['campo_valor']);
        }

        $sql->execute();
        return $sql;
    }

    public function seleccionarDatos($tipo, $tabla, $campo, $id)
    {
        $tipo = $this->limpiarCadena($tipo);
        $tablaQ = $this->q($tabla);
        $selectCols = $this->columnasTablaSql($tabla);

        if ($tipo === 'Unico') {
            $campoQ = $this->q($campo);
            $sql = $this->conectar()->prepare("SELECT {$selectCols} FROM {$tablaQ} WHERE {$campoQ} = :ID");
            $sql->bindValue(':ID', $id);
        } elseif ($tipo === 'Normal') {
            $sql = $this->conectar()->prepare("SELECT {$selectCols} FROM {$tablaQ}");
        } else {
            throw new Exception("Tipo de selección no válido");
        }

        $sql->execute();
        return $sql;
    }

    protected function actualizarDatos($tabla, $datos, $condicion)
    {
        $tablaQ = $this->q($tabla);

        $sets = [];
        foreach ($datos as $d) {
            $sets[] = $this->q($d['campo_nombre']) . ' = ' . $d['campo_marcador'];
        }

        $condCampoQ = $this->q($condicion['condicion_campo']);
        $query = "UPDATE {$tablaQ} SET " . implode(', ', $sets) . " WHERE {$condCampoQ} = " . $condicion['condicion_marcador'];

        $sql = $this->conectar()->prepare($query);

        foreach ($datos as $d) {
            $sql->bindValue($d['campo_marcador'], $d['campo_valor']);
        }
        $sql->bindValue($condicion['condicion_marcador'], $condicion['condicion_valor']);

        $sql->execute();
        return $sql;
    }

    protected function actualizarDatosMas($tabla, $datos, $condiciones)
    {
        $tablaQ = $this->q($tabla);

        $sets = [];
        foreach ($datos as $d) {
            $sets[] = $this->q($d['campo_nombre']) . ' = ' . $d['campo_marcador'];
        }

        $wheres = [];
        foreach ($condiciones as $c) {
            $wheres[] = $this->q($c['condicion_campo']) . ' = ' . $c['condicion_marcador'];
        }

        $query = "UPDATE {$tablaQ} SET " . implode(', ', $sets) . " WHERE " . implode(' AND ', $wheres);
        $sql = $this->conectar()->prepare($query);

        foreach ($datos as $d) {
            $sql->bindValue($d['campo_marcador'], $d['campo_valor']);
        }
        foreach ($condiciones as $c) {
            $sql->bindValue($c['condicion_marcador'], $c['condicion_valor']);
        }

        $sql->execute();
        return $sql;
    }

    protected function actualizarDatosHerramientaOt($consulta, $datos)
    {
        try {
            $sql = $this->conectar()->prepare($consulta);
            if ($sql->execute($datos)) {
                return $sql;
            }
            return false;
        } catch (PDOException $e) {
            throw new Exception('Error al ejecutar la consulta SQL: ' . $e->getMessage());
        }
    }

    protected function eliminarRegistro($tabla, $campo, $id)
    {
        $tablaQ = $this->q($tabla);
        $campoQ = $this->q($campo);

        $sql = $this->conectar()->prepare("DELETE FROM {$tablaQ} WHERE {$campoQ} = :id");
        $sql->bindValue(':id', $id);
        $sql->execute();

        return $sql;
    }

    protected function paginadorTablas($pagina, $numeroPagina, $url, $botones)
    {
        $tabla = '<nav aria-label="...">';

        if ($pagina <= 1) {
            $tabla .= '
                    <ul class="pagination">
                        <li class="page-item disabled">
                            <a class="page-link" href="#" tabindex="-1" aria-disabled="true">Anterior</a>
                        </li>
                ';
        } else {
            $tabla .= '
                    <ul class="pagination">
                        <li class="page-item">
                            <a class="page-link" href="' . $url . ($pagina - 1) . '/" tabindex="-1" aria-disabled="true">Anterior</a>
                        </li>
                        <li class="page-item"><a class="page-link" href="' . $url . '1/">1</a></li>
                ';
        }
        $ci = 0;
        for ($i = $pagina; $i <= $numeroPagina; $i++) {
            if ($ci >= $botones) {
                break;
            }
            if ($pagina == $i) {
                $tabla .= '
            <li class="page-item active" aria-current="page">
                <a class="page-link" href="' . $url . $i . '/">' . $i . '</a>
            </li>
            ';
            } else {
                $tabla .= '
            <li class="page-item">
                <a class="page-link" href="' . $url . $i . '/">' . $i . '</a>
            </li>
            ';
            }
            $ci++;
        }
        if ($pagina == $numeroPagina) {
            $tabla .= '
            <li class="page-item disabled">
                <a class="page-link" href="#">Siguiente</a>
            </li>
            ';
        } else {
            $tabla .= '
            <li class="page-item">
                <a class="page-link" href="' . $url . ($pagina + 1) . '/">Siguiente</a>
            </li>
            ';
        }
        $tabla .= '</ul>
    </nav>';

        return $tabla;
    }
}

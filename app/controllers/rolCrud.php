<?php
require_once "../../config/app.php";
require_once "../views/inc/session_start.php";
require_once "../../autoload.php";

use app\controllers\configController;

header('Content-Type: application/json; charset=utf-8');

$action = $_GET['action'] ?? ($_POST['action'] ?? '');

try {
    $ins = new configController();

    // Helper limpieza
    $clean = function ($v) use ($ins) {
        return $ins->limpiarCadena($v ?? '');
    };

    // Helper: checkbox -> 1/0
    $b = function ($key) {
        // soporta '1', 1, 'on', true
        if (!isset($_POST[$key])) return 0;
        $v = $_POST[$key];
        return ($v === '1' || $v === 1 || $v === 'on' || $v === true) ? 1 : 0;
    };

    // ====== Helper: detectar columnas en user_system (para no adivinar nombres)
    $pickColumn = function (string $table, array $candidates) use ($ins) {
        $db = defined('DB_NAME') ? DB_NAME : '';
        if ($db === '') return null;

        $in = "'" . implode("','", array_map(function ($c) { return str_replace("'", "''", $c); }, $candidates)) . "'";
        $sql = "SELECT COLUMN_NAME
                FROM INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_SCHEMA = :db AND TABLE_NAME = :t AND COLUMN_NAME IN ($in)
                LIMIT 1";

        $stmt = $ins->ejecutarConsultaConParametros($sql, [':db' => $db, ':t' => $table]);
        $col = $stmt ? $stmt->fetchColumn() : null;
        return $col ?: null;
    };

    // ====== Helper: lee permisos del POST (mismas keys que JS envía)
    $readPerms = function () use ($b) {
        return [
            'perm_usuarios_view'        => $b('perm_usuarios_view'),
            'perm_usuarios_add'         => $b('perm_usuarios_add'),
            'perm_usuarios_edit'        => $b('perm_usuarios_edit'),
            'perm_usuarios_delete'      => $b('perm_usuarios_delete'),

            'perm_herramienta_view'     => $b('perm_herramienta_view'),
            'perm_herramienta_add'      => $b('perm_herramienta_add'),
            'perm_herramienta_edit'     => $b('perm_herramienta_edit'),
            'perm_herramienta_delete'   => $b('perm_herramienta_delete'),

            'perm_miembro_view'         => $b('perm_miembro_view'),
            'perm_miembro_add'          => $b('perm_miembro_add'),
            'perm_miembro_edit'         => $b('perm_miembro_edit'),
            'perm_miembro_delete'       => $b('perm_miembro_delete'),

            'perm_ot_view'              => $b('perm_ot_view'),
            'perm_ot_add'               => $b('perm_ot_add'),
            'perm_ot_edit'              => $b('perm_ot_edit'),
            'perm_ot_delete'            => $b('perm_ot_delete'),

            'perm_ot_add_detalle'       => $b('perm_ot_add_detalle'),
            'perm_ot_generar_reporte'   => $b('perm_ot_generar_reporte'),
            'perm_ot_add_herramienta'   => $b('perm_ot_add_herramienta'),
        ];
    };

    // ====== 1) Recargar combo roles (HTML)
    if ($action === 'roles') {
        $html = $ins->listarComboRolControlador();
        echo json_encode(["ok" => true, "html" => $html], JSON_UNESCAPED_UNICODE);
        exit();
    }

    // ====== 2) Crear rol (GUARDA permisos también)
    if ($action === 'create') {
        $name = $clean($_POST['name'] ?? '');
        if ($name === '') {
            echo json_encode(["ok" => false, "msg" => "Nombre requerido"], JSON_UNESCAPED_UNICODE);
            exit();
        }

        // (opcional) evita duplicados
        $dup = $ins->ejecutarConsultaConParametros(
            "SELECT id FROM roles_permisos WHERE nombre_rol = :n LIMIT 1",
            [':n' => $name]
        );
        if ($dup && $dup->rowCount() > 0) {
            echo json_encode(["ok" => false, "msg" => "Ya existe un rol con ese nombre"], JSON_UNESCAPED_UNICODE);
            exit();
        }

        $perms = $readPerms();

        $sql = "INSERT INTO roles_permisos (
                    nombre_rol,
                    perm_usuarios_view, perm_usuarios_add, perm_usuarios_edit, perm_usuarios_delete,
                    perm_herramienta_view, perm_herramienta_add, perm_herramienta_edit, perm_herramienta_delete,
                    perm_miembro_view, perm_miembro_add, perm_miembro_edit, perm_miembro_delete,
                    perm_ot_view, perm_ot_add, perm_ot_edit, perm_ot_delete,
                    perm_ot_add_detalle, perm_ot_generar_reporte, perm_ot_add_herramienta
                ) VALUES (
                    :nombre,
                    :puv, :pua, :pue, :pud,
                    :phv, :pha, :phe, :phd,
                    :pmv, :pma, :pme, :pmd,
                    :potv, :pota, :pote, :potd,
                    :potad, :potgr, :potah
                )";

        $params = [
            ':nombre' => $name,

            ':puv' => $perms['perm_usuarios_view'],
            ':pua' => $perms['perm_usuarios_add'],
            ':pue' => $perms['perm_usuarios_edit'],
            ':pud' => $perms['perm_usuarios_delete'],

            ':phv' => $perms['perm_herramienta_view'],
            ':pha' => $perms['perm_herramienta_add'],
            ':phe' => $perms['perm_herramienta_edit'],
            ':phd' => $perms['perm_herramienta_delete'],

            ':pmv' => $perms['perm_miembro_view'],
            ':pma' => $perms['perm_miembro_add'],
            ':pme' => $perms['perm_miembro_edit'],
            ':pmd' => $perms['perm_miembro_delete'],

            ':potv' => $perms['perm_ot_view'],
            ':pota' => $perms['perm_ot_add'],
            ':pote' => $perms['perm_ot_edit'],
            ':potd' => $perms['perm_ot_delete'],

            ':potad' => $perms['perm_ot_add_detalle'],
            ':potgr' => $perms['perm_ot_generar_reporte'],
            ':potah' => $perms['perm_ot_add_herramienta'],
        ];

        $ins->ejecutarConsultaConParametros($sql, $params);

        // Obtener ID creado (sin lastInsertId, por compatibilidad)
        $stmtId = $ins->ejecutarConsultaConParametros(
            "SELECT id FROM roles_permisos WHERE nombre_rol = :n ORDER BY id DESC LIMIT 1",
            [':n' => $name]
        );
        $newId = $stmtId ? (int)$stmtId->fetchColumn() : 0;

        echo json_encode(["ok" => true, "msg" => "Rol creado", "id" => $newId], JSON_UNESCAPED_UNICODE);
        exit();
    }

    // ====== 3) Eliminar rol (BLOQUEA si hay usuarios y lista cuáles)
    if ($action === 'delete') {
        $id = (int)$clean($_POST['id'] ?? '0');
        if ($id <= 0) {
            echo json_encode(["ok" => false, "msg" => "ID inválido"], JSON_UNESCAPED_UNICODE);
            exit();
        }

        // (opcional) protege rol root
        // if ($id === 1) {
        //     echo json_encode(["ok" => false, "msg" => "No se puede eliminar el rol ROOT"], JSON_UNESCAPED_UNICODE);
        //     exit();
        // }

        // Detecta columna rol en user_system
        $roleCol = $pickColumn('user_system', ['tipo','id_rol','id_ai_rol','rol_id','id_role','role_id']);
        if ($roleCol) {
            $sqlUsers = "SELECT
                            u.id_empleado AS id_user,
                            COALESCE(NULLIF(e.nombre_empleado, ''), u.username, u.id_empleado) AS label
                         FROM user_system u
                         LEFT JOIN empleado e
                           ON e.id_empleado = u.id_empleado
                         WHERE u.$roleCol = :rid
                         ORDER BY u.id_empleado ASC";
            $stmtU = $ins->ejecutarConsultaConParametros($sqlUsers, [':rid' => $id]);
            $users = $stmtU ? $stmtU->fetchAll(\PDO::FETCH_ASSOC) : [];

            if (!empty($users)) {
                $labels = array_map(function ($u) {
                    $lab = trim((string)($u['label'] ?? ''));
                    $idU = (string)($u['id_user'] ?? '');
                    return $lab !== '' ? ($lab . " (ID " . $idU . ")") : ("ID " . $idU);
                }, $users);

                echo json_encode([
                    "ok" => false,
                    "msg" => "No se puede eliminar: hay usuarios con este rol.",
                    "users" => $labels
                ], JSON_UNESCAPED_UNICODE);
                exit();
            }
        }

        // Si no encontramos columna o no hay usuarios, intenta borrar
        try {
            $ins->ejecutarConsultaConParametros(
                "DELETE FROM roles_permisos WHERE id = :id",
                [':id' => $id]
            );
            echo json_encode(["ok" => true, "msg" => "Rol eliminado"], JSON_UNESCAPED_UNICODE);
            exit();
        } catch (\Throwable $e) {
            // Si había FK y falló, devuelve mensaje genérico
            echo json_encode([
                "ok" => false,
                "msg" => "No se pudo eliminar el rol (restricción de datos).",
                "detail" => $e->getMessage()
            ], JSON_UNESCAPED_UNICODE);
            exit();
        }
    }

    // ====== 4) Cargar permisos por rol
    if ($action === 'getPerms') {
        $id = (int)$clean($_POST['id'] ?? '0');
        if ($id <= 0) {
            echo json_encode(["ok" => false, "msg" => "ID inválido"], JSON_UNESCAPED_UNICODE);
            exit();
        }

        $stmt = $ins->ejecutarConsultaConParametros(
            "SELECT " . $ins->columnasTablaSql('roles_permisos') . " FROM roles_permisos WHERE id = :id LIMIT 1",
            [':id' => $id]
        );
        $row = $stmt ? $stmt->fetch(\PDO::FETCH_ASSOC) : null;

        echo json_encode(["ok" => true, "data" => $row ?: []], JSON_UNESCAPED_UNICODE);
        exit();
    }

    // ====== 5) Guardar permisos por rol
    if ($action === 'savePerms') {
        $id = (int)$clean($_POST['id'] ?? '0');
        if ($id <= 0) {
            echo json_encode(["ok" => false, "msg" => "ID inválido"], JSON_UNESCAPED_UNICODE);
            exit();
        }

        $perms = $readPerms();

        $sql = "UPDATE roles_permisos SET
            perm_usuarios_view        = :puv,
            perm_usuarios_add         = :pua,
            perm_usuarios_edit        = :pue,
            perm_usuarios_delete      = :pud,

            perm_herramienta_view     = :phv,
            perm_herramienta_add      = :pha,
            perm_herramienta_edit     = :phe,
            perm_herramienta_delete   = :phd,

            perm_miembro_view         = :pmv,
            perm_miembro_add          = :pma,
            perm_miembro_edit         = :pme,
            perm_miembro_delete       = :pmd,

            perm_ot_view              = :potv,
            perm_ot_add               = :pota,
            perm_ot_edit              = :pote,
            perm_ot_delete            = :potd,

            perm_ot_add_detalle       = :potad,
            perm_ot_generar_reporte   = :potgr,
            perm_ot_add_herramienta   = :potah
        WHERE id = :id";

        $params = [
            ':id' => $id,

            ':puv' => $perms['perm_usuarios_view'],
            ':pua' => $perms['perm_usuarios_add'],
            ':pue' => $perms['perm_usuarios_edit'],
            ':pud' => $perms['perm_usuarios_delete'],

            ':phv' => $perms['perm_herramienta_view'],
            ':pha' => $perms['perm_herramienta_add'],
            ':phe' => $perms['perm_herramienta_edit'],
            ':phd' => $perms['perm_herramienta_delete'],

            ':pmv' => $perms['perm_miembro_view'],
            ':pma' => $perms['perm_miembro_add'],
            ':pme' => $perms['perm_miembro_edit'],
            ':pmd' => $perms['perm_miembro_delete'],

            ':potv' => $perms['perm_ot_view'],
            ':pota' => $perms['perm_ot_add'],
            ':pote' => $perms['perm_ot_edit'],
            ':potd' => $perms['perm_ot_delete'],

            ':potad' => $perms['perm_ot_add_detalle'],
            ':potgr' => $perms['perm_ot_generar_reporte'],
            ':potah' => $perms['perm_ot_add_herramienta'],
        ];

        $ins->ejecutarConsultaConParametros($sql, $params);

        echo json_encode(["ok" => true, "msg" => "Permisos guardados"], JSON_UNESCAPED_UNICODE);
        exit();
    }

    echo json_encode(["ok" => false, "msg" => "Acción no válida"], JSON_UNESCAPED_UNICODE);
} catch (\Throwable $e) {
    echo json_encode([
        "ok" => false,
        "msg" => "Error interno",
        "detail" => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}

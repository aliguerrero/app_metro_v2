<?php
require_once "../../config/app.php";
require_once "../views/inc/session_start.php";
require_once "../../autoload.php";

use app\models\mainModel;

header('Content-Type: application/json; charset=utf-8');

function requirePerm(string $permKey): void
{
    $perms = $_SESSION['permisos'] ?? [];
    if (empty($perms[$permKey]) || (int)$perms[$permKey] !== 1) {
        echo json_encode([
            "ok" => false,
            "tipo" => "simple",
            "titulo" => "Acceso denegado",
            "texto" => "No tienes permisos para realizar esta accion",
            "icono" => "error"
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }
}

function consultaBaseMiembros(): string
{
    return "SELECT
        m.id_miembro,
        m.id_empleado,
        m.nombre_miembro,
        m.tipo_miembro,
        m.std_reg,
        e.nacionalidad,
        e.nombre_empleado,
        COALESCE(NULLIF(e.telefono, ''), '') AS telefono_empleado,
        COALESCE(NULLIF(e.correo, ''), '') AS correo_empleado,
        CASE
            WHEN e.id_empleado IS NOT NULL AND TRIM(e.id_empleado) <> ''
                THEN CONCAT(COALESCE(NULLIF(e.nacionalidad, ''), ''), IF(COALESCE(NULLIF(e.nacionalidad, ''), '') = '', '', '-'), e.id_empleado)
            ELSE 'No vinculado'
        END AS documento_empleado,
        CASE
            WHEN e.nombre_empleado IS NOT NULL AND TRIM(e.nombre_empleado) <> ''
                THEN e.nombre_empleado
            ELSE m.nombre_miembro
        END AS nombre_visual,
        CASE
            WHEN e.id_empleado IS NOT NULL AND TRIM(e.id_empleado) <> '' THEN 1
            ELSE 0
        END AS empleado_vinculado
    FROM miembro m
    LEFT JOIN empleado e
      ON e.id_empleado = m.id_empleado
    WHERE m.std_reg = 1";
}

try {
    $idUser = $_SESSION['id_user'] ?? ($_SESSION['id'] ?? null);
    if (empty($idUser)) {
        echo json_encode([
            "ok" => false,
            "tipo" => "simple",
            "titulo" => "No autenticado",
            "texto" => "Debe iniciar sesion",
            "icono" => "error"
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    $mainModel = new mainModel();
    $tipoBusqueda = $mainModel->limpiarCadena($_GET['tipoBusqueda'] ?? 'todo');

    if ($tipoBusqueda !== 'eliminar') {
        requirePerm('perm_miembro_view');

        $params = [];
        $sql = consultaBaseMiembros();

        if ($tipoBusqueda === 'id') {
            $campo = $mainModel->limpiarCadena($_GET['id'] ?? '');
            $q = '%' . $campo . '%';

            $sql .= " AND (
                m.id_miembro LIKE :q_codigo
                OR COALESCE(e.id_empleado, '') LIKE :q_doc
                OR COALESCE(e.nombre_empleado, m.nombre_miembro) LIKE :q_nombre
            )";

            $params = [
                ':q_codigo' => $q,
                ':q_doc' => $q,
                ':q_nombre' => $q,
            ];
        }

        $sql .= " ORDER BY nombre_visual ASC, m.id_miembro ASC";

        $stmt = $mainModel->ejecutarConsultaConParametros($sql, $params);
        $rows = $stmt ? $stmt->fetchAll(\PDO::FETCH_ASSOC) : [];

        echo json_encode([
            "ok" => true,
            "data" => $rows,
            "total" => count($rows)
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    requirePerm('perm_miembro_delete');

    $id = $mainModel->limpiarCadena($_POST['id'] ?? ($_GET['id'] ?? ''));
    if ($id === '') {
        echo json_encode([
            "ok" => false,
            "tipo" => "simple",
            "titulo" => "Error",
            "texto" => "ID invalido",
            "icono" => "error"
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    $mainModel->setAppUser((string)$idUser);

    $check = $mainModel->ejecutarConsultaConParametros(
        "SELECT id_miembro, std_reg
         FROM miembro
         WHERE id_miembro = :id
         LIMIT 1",
        [':id' => $id]
    );

    if (!$check || $check->rowCount() === 0) {
        echo json_encode([
            "ok" => false,
            "tipo" => "simple",
            "titulo" => "No encontrado",
            "texto" => "No encontramos el miembro solicitado",
            "icono" => "error"
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    $row = $check->fetch(\PDO::FETCH_ASSOC);
    if ((int)$row['std_reg'] === 0) {
        echo json_encode([
            "ok" => true,
            "tipo" => "simple",
            "titulo" => "Sin cambios",
            "texto" => "El miembro ya estaba inactivo",
            "icono" => "info"
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    $upd = $mainModel->ejecutarConsultaConParametros(
        "UPDATE miembro SET std_reg = 0 WHERE id_miembro = :id",
        [':id' => $id]
    );

    $ok = (bool)$upd && $upd->rowCount() > 0;

    echo json_encode([
        "ok" => $ok,
        "tipo" => $ok ? "recargar" : "simple",
        "titulo" => $ok ? "Miembro eliminado" : "Error",
        "texto" => $ok ? "El miembro fue inactivado correctamente" : "No se pudo eliminar el miembro",
        "icono" => $ok ? "success" : "error"
    ], JSON_UNESCAPED_UNICODE);
    exit();
} catch (\Throwable $e) {
    echo json_encode([
        "ok" => false,
        "tipo" => "simple",
        "titulo" => "Error interno",
        "texto" => "Ocurrio un error inesperado",
        "detail" => $e->getMessage(),
        "icono" => "error"
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

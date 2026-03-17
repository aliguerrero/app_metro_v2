<?php
require_once "../../config/app.php";
require_once "../views/inc/session_start.php";
require_once "../../autoload.php";

use app\controllers\configController;

header('Content-Type: application/json; charset=utf-8');

$action = $_GET['action'] ?? ($_POST['action'] ?? '');

try {
    $ins = new configController();

    $clean = function ($v) use ($ins) {
        return $ins->limpiarCadena($v ?? '');
    };

    if ($action === 'list') {
        $html = $ins->listarSitioControlador("");
        // total lo sacamos con query rápida
        $total = (int)$ins->ejecutarConsultas("SELECT COUNT(id_ai_sitio) FROM sitio_trabajo where std_reg = 1")->fetchColumn();
        echo json_encode(["ok" => true, "html" => $html, "total" => $total], JSON_UNESCAPED_UNICODE);
        exit();
    }

    if ($action === 'get') {
        $id = $clean($_POST['id'] ?? '');
        if ($id === '') {
            echo json_encode(["ok" => false, "msg" => "ID inválido"]);
            exit();
        }

        $stmt = $ins->ejecutarConsultaConParametros(
            "SELECT " . $ins->columnasTablaSql('sitio_trabajo') . " FROM sitio_trabajo WHERE id_ai_sitio = :id AND std_reg = 1 LIMIT 1",
            [':id' => $id]
        );
        $row = $stmt ? $stmt->fetch(PDO::FETCH_ASSOC) : null;

        if ($row) echo json_encode(["ok" => true, "data" => $row], JSON_UNESCAPED_UNICODE);
        else echo json_encode(["ok" => false, "msg" => "Sitio no encontrado"]);
        exit();
    }

    if ($action === 'create') {
        $nombre = $clean($_POST['nombre'] ?? '');
        if ($nombre === '') {
            echo json_encode(["ok" => false, "msg" => "Nombre requerido"], JSON_UNESCAPED_UNICODE);
            exit();
        }

        // ¿Existe?
        $q = $ins->ejecutarConsultaConParametros(
            "SELECT id_ai_sitio, std_reg
         FROM sitio_trabajo
         WHERE nombre_sitio = :n
         LIMIT 1",
            [':n' => $nombre]
        );

        if ($q && $q->rowCount() > 0) {
            $row = $q->fetch(PDO::FETCH_ASSOC);

            if (isset($row['std_reg']) && (string)$row['std_reg'] === '0') {
                $ins->ejecutarConsultaConParametros(
                    "UPDATE sitio_trabajo
                 SET std_reg = 1, nombre_sitio = :n
                 WHERE id_ai_sitio = :id
                 LIMIT 1",
                    [':n' => $nombre, ':id' => (int)$row['id_ai_sitio']]
                );

                echo json_encode(["ok" => true, "msg" => "Sitio reactivado"], JSON_UNESCAPED_UNICODE);
                exit();
            }

            echo json_encode(["ok" => false, "msg" => "El sitio ya existe"], JSON_UNESCAPED_UNICODE);
            exit();
        }

        // Nuevo
        $ins->ejecutarConsultaConParametros(
            "INSERT INTO sitio_trabajo (nombre_sitio, std_reg)
         VALUES (:n, 1)",
            [':n' => $nombre]
        );

        echo json_encode(["ok" => true, "msg" => "Sitio creado"], JSON_UNESCAPED_UNICODE);
        exit();
    }

    if ($action === 'update') {
        $id = $clean($_POST['id'] ?? '');
        $nombre = $clean($_POST['nombre'] ?? '');

        if ($id === '' || $nombre === '') {
            echo json_encode(["ok" => false, "msg" => "Datos incompletos"]);
            exit();
        }

        $sql = "UPDATE sitio_trabajo SET nombre_sitio = :n WHERE id_ai_sitio = :id";
        $ins->ejecutarConsultaConParametros($sql, [':n' => $nombre, ':id' => $id]);

        echo json_encode(["ok" => true, "msg" => "Sitio actualizado"], JSON_UNESCAPED_UNICODE);
        exit();
    }

    if ($action === 'delete') {

        $id = (int)$clean($_POST['id'] ?? 0);
        if ($id <= 0) {
            echo json_encode(["ok" => false, "msg" => "ID inválido"], JSON_UNESCAPED_UNICODE);
            exit();
        }

        // Verificar existencia
        $q = $ins->ejecutarConsultaConParametros(
            "SELECT id_ai_sitio, std_reg
         FROM sitio_trabajo
         WHERE id_ai_sitio = :id
         LIMIT 1",
            [':id' => $id]
        );

        if (!$q || $q->rowCount() <= 0) {
            echo json_encode(["ok" => false, "msg" => "No se encontró el sitio"], JSON_UNESCAPED_UNICODE);
            exit();
        }

        $row = $q->fetch(PDO::FETCH_ASSOC);

        // Ya eliminado
        if (isset($row['std_reg']) && (string)$row['std_reg'] === '0') {
            echo json_encode(["ok" => true, "msg" => "El sitio ya estaba eliminado"], JSON_UNESCAPED_UNICODE);
            exit();
        }

        // ✅ Eliminación lógica
        $ins->ejecutarConsultaConParametros(
            "UPDATE sitio_trabajo
         SET std_reg = 0
         WHERE id_ai_sitio = :id
         LIMIT 1",
            [':id' => $id]
        );

        echo json_encode(["ok" => true, "msg" => "Sitio eliminado"], JSON_UNESCAPED_UNICODE);
        exit();
    }

    echo json_encode(["ok" => false, "msg" => "Acción no válida"]);
} catch (Throwable $e) {
    echo json_encode(["ok" => false, "msg" => "Error interno", "detail" => $e->getMessage()]);
}

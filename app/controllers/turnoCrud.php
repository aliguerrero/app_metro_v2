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
        $html = $ins->listarTurnoControlador("");
        $total = (int)$ins->ejecutarConsultas("SELECT COUNT(id_ai_turno) FROM turno_trabajo where std_reg = 1")->fetchColumn();
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
            "SELECT " . $ins->columnasTablaSql('turno_trabajo') . " FROM turno_trabajo WHERE id_ai_turno = :id LIMIT 1",
            [':id' => $id]
        );
        $row = $stmt ? $stmt->fetch(PDO::FETCH_ASSOC) : null;

        if ($row) echo json_encode(["ok" => true, "data" => $row], JSON_UNESCAPED_UNICODE);
        else echo json_encode(["ok" => false, "msg" => "Turno no encontrado"]);
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
            "SELECT id_ai_turno, std_reg
         FROM turno_trabajo
         WHERE nombre_turno = :n
         LIMIT 1",
            [':n' => $nombre]
        );

        if ($q && $q->rowCount() > 0) {
            $row = $q->fetch(PDO::FETCH_ASSOC);

            if (isset($row['std_reg']) && (string)$row['std_reg'] === '0') {
                $ins->ejecutarConsultaConParametros(
                    "UPDATE turno_trabajo
                 SET std_reg = 1, nombre_turno = :n
                 WHERE id_ai_turno = :id
                 LIMIT 1",
                    [':n' => $nombre, ':id' => (int)$row['id_ai_turno']]
                );

                echo json_encode(["ok" => true, "msg" => "Turno reactivado"], JSON_UNESCAPED_UNICODE);
                exit();
            }

            echo json_encode(["ok" => false, "msg" => "El turno ya existe"], JSON_UNESCAPED_UNICODE);
            exit();
        }

        // Nuevo
        $ins->ejecutarConsultaConParametros(
            "INSERT INTO turno_trabajo (nombre_turno, std_reg)
         VALUES (:n, 1)",
            [':n' => $nombre]
        );

        echo json_encode(["ok" => true, "msg" => "Turno creado"], JSON_UNESCAPED_UNICODE);
        exit();
    }

    if ($action === 'update') {
        $id = $clean($_POST['id'] ?? '');
        $nombre = $clean($_POST['nombre'] ?? '');

        if ($id === '' || $nombre === '') {
            echo json_encode(["ok" => false, "msg" => "Datos incompletos"]);
            exit();
        }

        $sql = "UPDATE turno_trabajo SET nombre_turno = :n WHERE id_ai_turno = :id";
        $ins->ejecutarConsultaConParametros($sql, [':n' => $nombre, ':id' => $id]);

        echo json_encode(["ok" => true, "msg" => "Turno actualizado"], JSON_UNESCAPED_UNICODE);
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
            "SELECT id_ai_turno, std_reg
         FROM turno_trabajo
         WHERE id_ai_turno = :id
         LIMIT 1",
            [':id' => $id]
        );

        if (!$q || $q->rowCount() <= 0) {
            echo json_encode(["ok" => false, "msg" => "No se encontró el turno"], JSON_UNESCAPED_UNICODE);
            exit();
        }

        $row = $q->fetch(PDO::FETCH_ASSOC);

        if (isset($row['std_reg']) && (string)$row['std_reg'] === '0') {
            echo json_encode(["ok" => true, "msg" => "El turno ya estaba eliminado"], JSON_UNESCAPED_UNICODE);
            exit();
        }

        // ✅ Eliminación lógica
        $ins->ejecutarConsultaConParametros(
            "UPDATE turno_trabajo
         SET std_reg = 0
         WHERE id_ai_turno = :id
         LIMIT 1",
            [':id' => $id]
        );

        echo json_encode(["ok" => true, "msg" => "Turno eliminado"], JSON_UNESCAPED_UNICODE);
        exit();
    }

    echo json_encode(["ok" => false, "msg" => "Acción no válida"]);
} catch (Throwable $e) {
    echo json_encode(["ok" => false, "msg" => "Error interno", "detail" => $e->getMessage()]);
}

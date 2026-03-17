<?php
require_once "../../config/app.php";
require_once "../views/inc/session_start.php";
require_once "../../autoload.php";

use app\controllers\configController;

header('Content-Type: application/json; charset=utf-8');

$action = $_POST['action'] ?? '';

try {
    $ins = new configController();

    // Helpers
    $clean = function ($v) use ($ins) {
        return $ins->limpiarCadena($v ?? '');
    };

    if ($action === 'get') {
        $id = $clean($_POST['id_ai_area'] ?? '');
        if ($id === '') {
            echo json_encode(["ok" => false, "msg" => "ID inválido"]);
            exit();
        }

        $stmt = $ins->ejecutarConsultaConParametros(
            "SELECT " . $ins->columnasTablaSql('area_trabajo') . " FROM area_trabajo WHERE id_ai_area = :id AND std_reg = 1 LIMIT 1",
            [':id' => $id]
        );
        $row = $stmt ? $stmt->fetch(PDO::FETCH_ASSOC) : null;

        if ($row) {
            echo json_encode(["ok" => true, "data" => $row], JSON_UNESCAPED_UNICODE);
        } else {
            echo json_encode(["ok" => false, "msg" => "Área no encontrada"]);
        }
        exit();
    }

    if ($action === 'create') {
        $nombre = $clean($_POST['nombre_area'] ?? '');
        $nome   = $clean($_POST['nome'] ?? '');

        if ($nombre === '' || $nome === '') {
            echo json_encode(["ok" => false, "msg" => "Nombre y nomenclatura requeridos"], JSON_UNESCAPED_UNICODE);
            exit();
        }

        // ¿Existe por nomeclatura o nombre?
        $q = $ins->ejecutarConsultaConParametros(
            "SELECT id_ai_area, std_reg
         FROM area_trabajo
         WHERE nomeclatura = :no OR nombre_area = :n
         LIMIT 1",
            [':no' => $nome, ':n' => $nombre]
        );

        if ($q && $q->rowCount() > 0) {
            $row = $q->fetch(PDO::FETCH_ASSOC);

            if (isset($row['std_reg']) && (string)$row['std_reg'] === '0') {
                $ins->ejecutarConsultaConParametros(
                    "UPDATE area_trabajo
                 SET std_reg = 1, nombre_area = :n, nomeclatura = :no
                 WHERE id_ai_area = :id
                 LIMIT 1",
                    [':n' => $nombre, ':no' => $nome, ':id' => (int)$row['id_ai_area']]
                );

                echo json_encode(["ok" => true, "msg" => "Área reactivada"], JSON_UNESCAPED_UNICODE);
                exit();
            }

            echo json_encode(["ok" => false, "msg" => "El área ya existe"], JSON_UNESCAPED_UNICODE);
            exit();
        }

        // Nuevo
        $ins->ejecutarConsultaConParametros(
            "INSERT INTO area_trabajo (nombre_area, nomeclatura, std_reg)
         VALUES (:n, :no, 1)",
            [':n' => $nombre, ':no' => $nome]
        );

        echo json_encode(["ok" => true, "msg" => "Área creada"], JSON_UNESCAPED_UNICODE);
        exit();
    }

    if ($action === 'update') {
        $id     = $clean($_POST['id_ai_area'] ?? '');
        $nombre = $clean($_POST['nombre_area'] ?? '');
        $nome   = $clean($_POST['nome'] ?? '');

        if ($id === '' || $nombre === '') {
            echo json_encode(["ok" => false, "msg" => "Datos incompletos"]);
            exit();
        }

        $sql = "UPDATE area_trabajo SET nombre_area = :n, nomeclatura = :no WHERE id_ai_area = :id";
        $ins->ejecutarConsultaConParametros($sql, [':n' => $nombre, ':no' => $nome, ':id' => $id]);

        echo json_encode(["ok" => true, "msg" => "Área actualizada"], JSON_UNESCAPED_UNICODE);
        exit();
    }

    if ($action === 'delete') {
        $id = (int)$clean($_POST['id_ai_area'] ?? 0);
        if ($id <= 0) {
            echo json_encode(["ok" => false, "msg" => "ID inválido"], JSON_UNESCAPED_UNICODE);
            exit();
        }

        // Verificar existencia
        $q = $ins->ejecutarConsultaConParametros(
            "SELECT id_ai_area, std_reg
         FROM area_trabajo
         WHERE id_ai_area = :id
         LIMIT 1",
            [':id' => $id]
        );

        if (!$q || $q->rowCount() <= 0) {
            echo json_encode(["ok" => false, "msg" => "No se encontró el área"], JSON_UNESCAPED_UNICODE);
            exit();
        }

        $row = $q->fetch(PDO::FETCH_ASSOC);

        if (isset($row['std_reg']) && (string)$row['std_reg'] === '0') {
            echo json_encode(["ok" => true, "msg" => "El área ya estaba eliminada"], JSON_UNESCAPED_UNICODE);
            exit();
        }

        // ✅ Eliminación lógica
        $ins->ejecutarConsultaConParametros(
            "UPDATE area_trabajo
         SET std_reg = 0
         WHERE id_ai_area = :id
         LIMIT 1",
            [':id' => $id]
        );

        echo json_encode(["ok" => true, "msg" => "Área eliminada"], JSON_UNESCAPED_UNICODE);
        exit();
    }

    echo json_encode(["ok" => false, "msg" => "Acción no válida"]);
} catch (Throwable $e) {
    echo json_encode(["ok" => false, "msg" => "Error interno", "detail" => $e->getMessage()]);
}

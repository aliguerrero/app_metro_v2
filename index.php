<?php
require_once "./config/app.php";
require_once "./autoload.php";
require_once "./app/views/inc/session_start.php";

if (!headers_sent()) {
    header('X-Content-Type-Options: nosniff');
    header('X-Frame-Options: SAMEORIGIN');
    header('Referrer-Policy: strict-origin-when-cross-origin');
    header('Cross-Origin-Resource-Policy: same-origin');

    if (defined('APP_IS_HTTPS') ? APP_IS_HTTPS : false) {
        header('Strict-Transport-Security: max-age=31536000; includeSubDomains');
    }
}

if (isset($_GET['views'])) {
    $url = explode("/", $_GET['views']);
} else {
    $url = ['login'];
}
?>

<!DOCTYPE html>
<html lang="es" data-bs-theme="light">

<head>
    <?php require_once "./app/views/inc/head.php"; ?>
</head>

<body class="d-flex justify-content-center align-items-center">
    <?php
    use app\controllers\viewsController;
    use app\controllers\loginController;

    $insLogin = new loginController();
    $viewsControllers = new viewsController();
    $vista = $viewsControllers->obternerVistaControlador($url[0]);

    if ($vista == "login" || $vista == "404") {
        ob_start();
        require_once "./app/views/content/" . $vista . "-view.php";
        $contenidoVista = ob_get_clean() ?: '';
        $contenidoVista = preg_replace('/^[\\s\\r\\n]*"/', '', $contenidoVista, 1);
        $contenidoVista = preg_replace('/"(?=\\s*<style)/', '', $contenidoVista, 1);
        $contenidoVista = preg_replace('/"(\\s*)<style/', '<style', $contenidoVista, 1);
        echo $contenidoVista;
    } else {
        if (
            !isset($_SESSION['id']) || !isset($_SESSION['user']) || !isset($_SESSION['username']) ||
            !isset($_SESSION['tipo']) || $_SESSION['id'] == "" || $_SESSION['user'] == "" ||
            $_SESSION['username'] == "" || $_SESSION['tipo'] == ""
        ) {
            $insLogin->cerrarSesionControlador();
            exit();
        }

        require_once "./app/views/inc/navbar.php";
    }

    require_once "./app/views/inc/script.php";
    ?>
</body>

</html>

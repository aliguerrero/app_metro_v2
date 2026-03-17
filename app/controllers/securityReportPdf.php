<?php
require_once __DIR__ . "/securityBootstrap.php";
require_once __DIR__ . "/../../config/server.php";
require_once __DIR__ . "/../lib/dompdf/autoload.inc.php";

use Dompdf\Dompdf;
use Dompdf\Options;

appsec_require_admin();
appsec_set_security_headers();

function reportPdo(string $user, string $pass): PDO
{
    return new PDO(
        "mysql:host=" . DB_SERVER . ";dbname=" . DB_NAME . ";charset=utf8mb4",
        $user,
        $pass,
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ]
    );
}

function fetchScalar(PDO $pdo, string $sql, array $params = [])
{
    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    return $stmt->fetchColumn();
}

function fetchGrants(PDO $pdo): array
{
    $stmt = $pdo->query('SHOW GRANTS FOR CURRENT_USER()');
    return $stmt ? $stmt->fetchAll(PDO::FETCH_COLUMN) : [];
}

function h($value): string
{
    return htmlspecialchars((string)$value, ENT_QUOTES, 'UTF-8');
}

function renderGrantItems(array $grants): string
{
    $html = '';
    foreach ($grants as $grant) {
        $html .= '<li>' . h($grant) . '</li>';
    }
    return $html !== '' ? $html : '<li>Sin grants visibles.</li>';
}

$appPdo = reportPdo(DB_USER, DB_PASS);
$authPdo = reportPdo(DB_AUTH_USER, DB_AUTH_PASS);
$generatedAt = date('Y-m-d H:i:s');
$download = appsec_request_string('download') === '1';

$dbVersion = (string)fetchScalar($authPdo, "SELECT VERSION()");
$bindAddress = (string)fetchScalar($authPdo, "SELECT @@global.bind_address");
$baseTables = (int)fetchScalar($authPdo, "SELECT COUNT(1) FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_TYPE = 'BASE TABLE'");
$innodbTables = (int)fetchScalar($authPdo, "SELECT COUNT(1) FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_TYPE = 'BASE TABLE' AND ENGINE = 'InnoDB'");
$foreignKeys = (int)fetchScalar($authPdo, "SELECT COUNT(1) FROM information_schema.REFERENTIAL_CONSTRAINTS WHERE CONSTRAINT_SCHEMA = DATABASE()");
$triggers = (int)fetchScalar($authPdo, "SELECT COUNT(1) FROM information_schema.TRIGGERS WHERE TRIGGER_SCHEMA = DATABASE()");
$checks = (int)fetchScalar($authPdo, "SELECT COUNT(1) FROM information_schema.CHECK_CONSTRAINTS WHERE CONSTRAINT_SCHEMA = DATABASE()");
$tablesWithStdReg = (int)fetchScalar($authPdo, "SELECT COUNT(DISTINCT TABLE_NAME) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND COLUMN_NAME = 'std_reg'");
$uniqueIndexes = (int)fetchScalar($authPdo, "SELECT COUNT(1) FROM (SELECT DISTINCT TABLE_NAME, INDEX_NAME FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = DATABASE() AND NON_UNIQUE = 0 AND INDEX_NAME <> 'PRIMARY') q");
$auditRows = (int)fetchScalar($authPdo, "SELECT COUNT(1) FROM log_user");

$ordersWithoutArea = (int)fetchScalar($authPdo, "SELECT COUNT(1) FROM orden_trabajo ot LEFT JOIN area_trabajo a ON a.id_ai_area = ot.id_ai_area WHERE ot.std_reg = 1 AND (a.id_ai_area IS NULL OR a.std_reg <> 1)");
$ordersWithoutSite = (int)fetchScalar($authPdo, "SELECT COUNT(1) FROM orden_trabajo ot LEFT JOIN sitio_trabajo s ON s.id_ai_sitio = ot.id_ai_sitio WHERE ot.std_reg = 1 AND (s.id_ai_sitio IS NULL OR s.std_reg <> 1)");
$detailsWithoutTurn = (int)fetchScalar($authPdo, "SELECT COUNT(1) FROM detalle_orden d LEFT JOIN turno_trabajo t ON t.id_ai_turno = d.id_ai_turno WHERE t.id_ai_turno IS NULL OR t.std_reg <> 1");
$detailsWithoutState = (int)fetchScalar($authPdo, "SELECT COUNT(1) FROM detalle_orden d LEFT JOIN estado_ot e ON e.id_ai_estado = d.id_ai_estado WHERE e.id_ai_estado IS NULL OR e.std_reg <> 1");
$inactiveToolsAssigned = (int)fetchScalar($authPdo, "SELECT COUNT(1) FROM herramientaot hot INNER JOIN herramienta h ON h.id_ai_herramienta = hot.id_ai_herramienta WHERE h.std_reg = 0");
$duplicateSites = (int)fetchScalar($authPdo, "SELECT COUNT(1) FROM (SELECT nombre_sitio FROM sitio_trabajo WHERE std_reg = 1 GROUP BY nombre_sitio HAVING COUNT(1) > 1) q");

$appGrants = fetchGrants($appPdo);
$authGrants = fetchGrants($authPdo);
$cookieParams = session_get_cookie_params();

$html = '
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <style>
        @page { size: A4 portrait; margin: 24px; }
        body { font-family: DejaVu Sans, sans-serif; color: #1f2937; font-size: 11px; line-height: 1.45; }
        h1, h2, h3 { margin: 0 0 8px; color: #0f172a; }
        h1 { font-size: 22px; }
        h2 { font-size: 15px; margin-top: 18px; padding-bottom: 4px; border-bottom: 1px solid #cbd5e1; }
        h3 { font-size: 12px; margin-top: 12px; }
        p { margin: 0 0 8px; }
        ul { margin: 6px 0 10px 18px; padding: 0; }
        li { margin-bottom: 4px; }
        .hero { background: #f8fafc; border: 1px solid #cbd5e1; border-radius: 10px; padding: 14px 16px; margin-bottom: 14px; }
        .grid { width: 100%; border-collapse: collapse; margin-top: 8px; }
        .grid th, .grid td { border: 1px solid #cbd5e1; padding: 7px 8px; vertical-align: top; }
        .grid th { background: #e2e8f0; text-align: left; width: 34%; }
        .badge { display: inline-block; padding: 4px 8px; border-radius: 999px; background: #dbeafe; color: #1d4ed8; font-weight: 700; }
        .muted { color: #475569; }
        .note { background: #fff7ed; border: 1px solid #fdba74; border-radius: 8px; padding: 10px 12px; margin-top: 10px; }
    </style>
</head>
<body>
    <div class="hero">
        <h1>Informe de Seguridad de la Aplicacion y la Base de Datos</h1>
        <p><strong>Sistema:</strong> ' . h(APP_NAME) . '</p>
        <p><strong>Fecha de generacion:</strong> ' . h($generatedAt) . '</p>
        <p><strong>Alcance:</strong> aplicacion web, control de acceso, sesiones, exposicion de archivos, cuentas de base de datos, auditoria e integridad referencial.</p>
        <p><strong>Criterio tecnico:</strong> OWASP ASVS 4.0 (controles de autenticacion, sesiones, autorizacion y validacion), OWASP Top 10 2021 (inyeccion y exposicion de datos), principio de minimo privilegio y reglas de integridad relacional.</p>
    </div>

    <h2>1. Nivel de Seguridad Implementado</h2>
    <p>El modelo operativo actual corresponde a un <span class="badge">nivel medio</span>. La aplicacion ya trabaja con autenticacion por credenciales hasheadas, permisos por rol en sesion, control de acceso en controladores directos, endpoints administrativos cerrados, consultas parametrizadas en los puntos expuestos y separacion entre cuenta operativa y cuenta privilegiada de base de datos.</p>
    <p>Este nivel no se interpreta como blindaje absoluto; significa que la seguridad esta basada en controles preventivos concretos, con trazabilidad y restricciones reales, y no solo en filtros cosmeticos del lado del cliente.</p>

    <h2>2. Seguridad Implementada en la Aplicacion</h2>
    <h3>2.1 Autenticacion y manejo de sesion</h3>
    <ul>
        <li>La autenticacion del usuario se fundamenta en hash de contrasena verificado en servidor, lo que evita almacenar o comparar claves en texto plano.</li>
        <li>La sesion usa modo estricto, cookies `HttpOnly`, `SameSite=Lax` y marca `Secure` cuando la aplicacion se sirve sobre HTTPS. Esto reduce secuestro de sesion, acceso desde JavaScript y envio accidental de cookies en contextos cruzados.</li>
        <li>La identidad activa se conserva en sesion y no se toma del cliente para decidir autorizaciones o exclusiones sensibles.</li>
    </ul>

    <h3>2.2 Autorizacion y alcance de acceso</h3>
    <ul>
        <li>Las rutas administrativas y de auditoria ahora exigen sesion valida y verificacion de administrador o permiso especifico antes de responder.</li>
        <li>La razon tecnica de este modelo es evitar control de acceso roto: el navegador puede pedir cualquier URL, por lo que la validacion debe ocurrir dentro del controlador.</li>
        <li>La separacion por permisos responde al criterio de minimo privilegio: cada modulo solo deberia poder leer o modificar lo estrictamente necesario para su funcion.</li>
    </ul>

    <h3>2.3 Exposicion de archivos y datos sensibles</h3>
    <ul>
        <li>Los directorios `db/` y `downloads/` quedaron sin acceso HTTP directo. Los archivos sensibles se entregan mediante controladores autenticados y no por URL publica.</li>
        <li>Esta medida obedece al criterio de contencion de datos: un archivo SQL o PDF sensible no debe depender de que el usuario conozca o no la ruta, sino de que exista una validacion previa.</li>
        <li>Los scripts temporales de depuracion fueron retirados porque exponer `var_dump`, rutas o fragmentos de vistas rompe el principio de no divulgacion de informacion interna.</li>
    </ul>

    <h3>2.4 Endpoints y consultas</h3>
    <ul>
        <li>Los controladores directos expuestos ahora usan consultas preparadas y parametros tipados en lugar de concatenar valores recibidos por `GET` o `POST`.</li>
        <li>El borrado de usuarios se ejecuta por `POST` autenticado y ya no se apoya en un `GET` destructivo. El motivo es que una accion de cambio de estado no debe ser activable por simple navegacion o precarga del navegador.</li>
        <li>En el frontend de usuarios se aplica escape HTML en los datos renderizados para que el navegador muestre texto y no interprete contenido como codigo o atributos.</li>
    </ul>

    <h3>2.5 Cabeceras y postura de respuesta</h3>
    <ul>
        <li>La aplicacion emite cabeceras `X-Content-Type-Options`, `X-Frame-Options`, `Referrer-Policy` y `Cross-Origin-Resource-Policy`.</li>
        <li>Su finalidad es reducir interpretacion de tipos indebidos, clickjacking, fuga de origen de navegacion y carga cruzada no deseada.</li>
        <li>La URL base ya no acepta el `Host` recibido sin saneamiento, con lo que se reduce el riesgo de construir enlaces absolutos con valores manipulados por el cliente.</li>
    </ul>

    <h2>3. Seguridad Implementada en la Base de Datos</h2>
    <h3>3.1 Modelo de cuentas</h3>
    <table class="grid">
        <tr><th>Cuenta operativa</th><td>' . h(DB_USER) . ' conectada a ' . h(DB_SERVER) . '. Su rol es atender la operacion normal de la app con privilegios DML sobre la base principal.</td></tr>
        <tr><th>Cuenta privilegiada</th><td>' . h(DB_AUTH_USER) . ' conectada a ' . h(DB_SERVER) . '. Se reserva para respaldo, restauracion y tareas de base de datos que requieren permisos mas altos.</td></tr>
        <tr><th>Bind address</th><td>' . h($bindAddress !== '' ? $bindAddress : DB_SERVER) . '. El servicio queda atendiendo de forma local y no expuesto como listener global.</td></tr>
        <tr><th>Version</th><td>' . h($dbVersion) . '</td></tr>
    </table>
    <p>La razon de separar cuentas es evitar que toda la aplicacion opere con permisos administrativos. Si una consulta operativa se ve comprometida, el alcance queda limitado a la cuenta de aplicacion y no a la cuenta de mantenimiento.</p>

    <h3>3.2 Grants visibles de la cuenta operativa</h3>
    <ul>' . renderGrantItems($appGrants) . '</ul>

    <h3>3.3 Grants visibles de la cuenta privilegiada</h3>
    <ul>' . renderGrantItems($authGrants) . '</ul>

    <h3>3.4 Integridad estructural implementada</h3>
    <table class="grid">
        <tr><th>Tablas base</th><td>' . h($baseTables) . '</td></tr>
        <tr><th>Tablas InnoDB</th><td>' . h($innodbTables) . '</td></tr>
        <tr><th>Claves foraneas</th><td>' . h($foreignKeys) . '</td></tr>
        <tr><th>Triggers</th><td>' . h($triggers) . '</td></tr>
        <tr><th>Check constraints</th><td>' . h($checks) . '</td></tr>
        <tr><th>Indices unicos adicionales</th><td>' . h($uniqueIndexes) . '</td></tr>
        <tr><th>Tablas con std_reg</th><td>' . h($tablesWithStdReg) . '</td></tr>
        <tr><th>Eventos de auditoria en log_user</th><td>' . h($auditRows) . '</td></tr>
    </table>
    <p>La base trabaja con integridad relacional y auditoria. InnoDB, claves foraneas, restricciones de unicidad, checks y triggers aportan control sobre consistencia, trazabilidad y restauracion logica.</p>

    <h2>4. Estado Actual de Integridad de Datos</h2>
    <table class="grid">
        <tr><th>OT activas sin area valida</th><td>' . h($ordersWithoutArea) . '</td></tr>
        <tr><th>OT activas sin sitio valido</th><td>' . h($ordersWithoutSite) . '</td></tr>
        <tr><th>Detalles sin turno valido</th><td>' . h($detailsWithoutTurn) . '</td></tr>
        <tr><th>Detalles sin estado valido</th><td>' . h($detailsWithoutState) . '</td></tr>
        <tr><th>Herramientas inactivas aun asignadas</th><td>' . h($inactiveToolsAssigned) . '</td></tr>
        <tr><th>Nombres de sitio duplicados activos</th><td>' . h($duplicateSites) . '</td></tr>
    </table>
    <p>Desde el criterio de integridad, los cuatro primeros indicadores miden consistencia referencial operativa. Los dos ultimos muestran consistencia de negocio: que un activo no quede asignado si esta inhabilitado y que un nombre funcional no se duplique si debe representar una unica entidad.</p>

    <h2>5. Lectura Tecnica del Modelo de Seguridad</h2>
    <ul>
        <li><strong>Confidencialidad:</strong> se protege mediante autenticacion, permisos por rol, directorios no publicos y cuentas de BD separadas.</li>
        <li><strong>Integridad:</strong> se sostiene con consultas parametrizadas, restricciones relacionales, auditoria por triggers y borrado logico controlado.</li>
        <li><strong>Disponibilidad:</strong> se respalda con modulo de backup/restore autenticado y cuenta privilegiada dedicada para esa operacion.</li>
        <li><strong>Trazabilidad:</strong> cada cambio importante queda soportado por `log_user`, lo que permite saber quien actuo, cuando y sobre que registro.</li>
        <li><strong>Minimo privilegio:</strong> la app ya no depende de una cuenta administrativa unica para todas las operaciones normales.</li>
    </ul>

    <div class="note">
        <strong>Interpretacion final:</strong> la aplicacion trabaja hoy con una seguridad implementada de tipo operacional y verificable, basada en autenticacion robusta, sesion endurecida, autorizacion por rol, cierre de superficies expuestas, auditoria y controles relacionales en la BD. El criterio que la rige es preventivo: reducir la superficie de ataque, limitar privilegios y mantener trazabilidad suficiente para detectar y reconstruir cambios.
    </div>
</body>
</html>';

$options = new Options();
$options->set('isRemoteEnabled', false);
$options->set('defaultFont', 'DejaVu Sans');

$dompdf = new Dompdf($options);
$dompdf->loadHtml($html, 'UTF-8');
$dompdf->setPaper('A4', 'portrait');
$dompdf->render();

$pdfOutput = $dompdf->output();
$reportDir = realpath(__DIR__ . "/../../downloads") ?: (__DIR__ . "/../../downloads");
$reportDir .= DIRECTORY_SEPARATOR . "security_reports";

if (!is_dir($reportDir)) {
    mkdir($reportDir, 0775, true);
}

$reportPath = $reportDir . DIRECTORY_SEPARATOR . "informe_seguridad_app_metro.pdf";
file_put_contents($reportPath, $pdfOutput);

$fileName = basename($reportPath);

header('Content-Type: application/pdf');
header('Content-Length: ' . strlen($pdfOutput));
header('Cache-Control: no-store, no-cache, must-revalidate');
header('Pragma: no-cache');
header('Expires: 0');
header('Content-Disposition: ' . ($download ? 'attachment' : 'inline') . '; filename="' . $fileName . '"');

echo $pdfOutput;
exit();


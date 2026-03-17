<?php
use app\controllers\mainController;

$insMain = new mainController();
$resumen = $insMain->obtenerResumenDashboard();

if (!function_exists('dashboardMetric')) {
    function dashboardMetric(array $data, string $key): string
    {
        return number_format((int)($data[$key] ?? 0));
    }
}
?>

<div class="container-fluid px-4 py-4">
    <div class="row g-3 mb-4">
        <div class="col-12 col-sm-6 col-xl-3">
            <div class="card border-0 shadow-sm h-100">
                <div class="card-body">
                    <p class="text-uppercase text-muted small mb-1">Órdenes activas</p>
                    <div class="d-flex align-items-center justify-content-between">
                        <h3 class="fw-bold mb-0"><?php echo dashboardMetric($resumen, 'total_ot'); ?></h3>
                        <span class="badge rounded-pill text-success bg-success bg-opacity-10">Activas</span>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-12 col-sm-6 col-xl-3">
            <div class="card border-0 shadow-sm h-100">
                <div class="card-body">
                    <p class="text-uppercase text-muted small mb-1">Detalles planificados</p>
                    <h3 class="fw-bold mb-0"><?php echo dashboardMetric($resumen, 'total_detalles'); ?></h3>
                    <p class="text-muted small mb-0">Eventos registrados</p>
                </div>
            </div>
        </div>
        <div class="col-12 col-sm-6 col-xl-3">
            <div class="card border-0 shadow-sm h-100">
                <div class="card-body">
                    <p class="text-uppercase text-muted small mb-1">Herramientas activas</p>
                    <h3 class="fw-bold mb-0"><?php echo dashboardMetric($resumen, 'herramientas'); ?></h3>
                </div>
            </div>
        </div>
        <div class="col-12 col-sm-6 col-xl-3">
            <div class="card border-0 shadow-sm h-100">
                <div class="card-body">
                    <p class="text-uppercase text-muted small mb-1">Miembros activos</p>
                    <h3 class="fw-bold mb-0"><?php echo dashboardMetric($resumen, 'miembros_activos'); ?></h3>
                </div>
            </div>
        </div>
    </div>

    <div class="row g-3 mb-4">
        <div class="col-12 col-lg-6">
            <div class="card border-0 shadow-sm h-100">
                <div class="card-body">
                    <h6 class="text-muted mb-3">Detalle de ejecución</h6>
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <p class="mb-1 text-muted small">Ejecutadas</p>
                            <h4 class="fw-bold mb-0"><?php echo dashboardMetric($resumen, 'detalles_ejecutados'); ?></h4>
                        </div>
                        <div>
                            <p class="mb-1 text-muted small">Pendientes</p>
                            <h4 class="fw-bold mb-0"><?php echo dashboardMetric($resumen, 'detalles_pendientes'); ?></h4>
                        </div>
                    </div>
                    <?php
                        $ejecutados = (int)($resumen['detalles_ejecutados'] ?? 0);
                        $pendientes = (int)($resumen['detalles_pendientes'] ?? 0);
                        $totalDetalle = max(1, $ejecutados + $pendientes);
                        $porcEjecutados = round(($ejecutados / $totalDetalle) * 100);
                    ?>
                    <div class="progress mt-3" style="height: 6px;">
                        <div class="progress-bar bg-success" role="progressbar"
                            style="width: <?php echo $porcEjecutados; ?>%" aria-valuenow="<?php echo $porcEjecutados; ?>"
                            aria-valuemin="0" aria-valuemax="100">
                        </div>
                    </div>
                    <p class="text-muted small mb-0 mt-2"><?php echo $porcEjecutados; ?>% completado en la última ventana.</p>
                </div>
            </div>
        </div>
        <div class="col-12 col-lg-6">
            <div class="card border-0 shadow-sm h-100">
                <div class="card-body">
                    <h6 class="text-muted mb-3">Usuarios y actividad</h6>
                    <div class="row text-center">
                        <div class="col-6">
                            <p class="text-muted small mb-1">Usuarios activos</p>
                            <h4 class="fw-bold mb-0"><?php echo dashboardMetric($resumen, 'usuarios_activos'); ?></h4>
                        </div>
                        <div class="col-6">
                            <p class="text-muted small mb-1">Logs (últimos 7 días)</p>
                            <h4 class="fw-bold mb-0"><?php echo dashboardMetric($resumen, 'logs_semana'); ?></h4>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="row g-4 mb-4">
        <div class="col-lg-8">
            <div class="card border-0 shadow-sm h-100">
                <div class="card-header bg-transparent border-bottom-0 d-flex justify-content-between align-items-center">
                    <div>
                        <p class="text-uppercase text-muted small mb-1">Visión general</p>
                        <h5 class="mb-0">Órdenes de trabajo por estado</h5>
                    </div>
                    <small class="text-muted"><?php echo date('d/m/Y H:i'); ?></small>
                </div>
                <div class="card-body">
                    <div class="c-chart-wrapper" style="min-height: 320px;">
                        <canvas id="ChartOt"></canvas>
                    </div>
                </div>
                <div class="card-footer bg-light border-top-0">
                    <div class="row row-cols-1 row-cols-md-2 g-3">
                        <?php echo $insMain->listarCardEstadoControlador(); ?>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-lg-4">
            <div class="card border-0 shadow-sm h-100">
                <div class="card-header">
                    <h5 class="mb-0">Turnos activos</h5>
                    <small class="text-muted">Participación por franja</small>
                </div>
                <div class="card-body">
                    <div class="c-chart-wrapper" style="min-height: 220px;">
                        <canvas id="ChartTurno"></canvas>
                    </div>
                    <div class="row row-cols-1 g-3 mt-3">
                        <?php echo $insMain->listarCardTurnoControlador(); ?>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="row g-4 mb-4">
        <div class="col-lg-6">
            <div class="card border-0 shadow-sm h-100">
                <div class="card-header">
                    <div>
                        <p class="text-uppercase text-muted small mb-1">Detalle por área</p>
                        <h6 class="mb-0">Porcentaje de estados</h6>
                    </div>
                </div>
                <div class="card-body" style="min-height: 320px;">
                    <div id="graficas-container1" class="d-flex flex-wrap gap-2 justify-content-center"></div>
                </div>
            </div>
        </div>
        <div class="col-lg-6">
            <div class="card border-0 shadow-sm h-100">
                <div class="card-header">
                    <div>
                        <p class="text-uppercase text-muted small mb-1">Detalle por turno</p>
                        <h6 class="mb-0">Estados dentro de cada turno</h6>
                    </div>
                </div>
                <div class="card-body" style="min-height: 320px;">
                    <div id="graficas-container2" class="d-flex flex-wrap gap-2 justify-content-center"></div>
                </div>
            </div>
        </div>
    </div>

    <div class="row mb-4">
        <div class="col-12">
            <div class="card border-0 shadow-sm">
                <div class="card-header">
                    <h5 class="mb-0">Actividad del sistema</h5>
                    <small class="text-muted">Participación histórica y logs</small>
                </div>
                <div class="card-body p-0" style="max-height: 360px; overflow-y: auto;">
                    <?php echo $insMain->listarActividadesControlador(); ?>
                </div>
            </div>
        </div>
    </div>
</div>

<?php require_once "./app/views/scripts/script-panel.php"; ?>

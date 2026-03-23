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

$ejecutados = (int)($resumen['detalles_ejecutados'] ?? 0);
$pendientes = (int)($resumen['detalles_pendientes'] ?? 0);
$totalDetalle = max(1, $ejecutados + $pendientes);
$porcEjecutados = round(($ejecutados / $totalDetalle) * 100);
?>

<div class="container-xxl dashboard-shell">
    <div class="dashboard-head">
        <div class="page-head">
            <div class="dashboard-head__row">
                <div>
                    <h3>Panel de Control</h3>
                    <p class="dashboard-head__subtitle mb-0">Resumen operativo de ordenes, herramientas, usuarios y actividad del sistema.</p>
                </div>
                <div class="dashboard-head__stamp">
                    <span>Actualizado</span>
                    <strong><?php echo date('d/m/Y H:i'); ?></strong>
                </div>
            </div>
        </div>
    </div>

    <section class="dashboard-grid dashboard-grid--metrics">
        <article class="card border-0 shadow-sm dashboard-card dashboard-card--metric">
            <div class="card-body">
                <p class="dashboard-eyebrow mb-2">Ordenes activas</p>
                <div class="dashboard-metric-row">
                    <h3 class="dashboard-metric-value mb-0"><?php echo dashboardMetric($resumen, 'total_ot'); ?></h3>
                    <span class="badge rounded-pill text-success bg-success bg-opacity-10">Activas</span>
                </div>
            </div>
        </article>

        <article class="card border-0 shadow-sm dashboard-card dashboard-card--metric">
            <div class="card-body">
                <p class="dashboard-eyebrow mb-2">Detalles planificados</p>
                <h3 class="dashboard-metric-value mb-1"><?php echo dashboardMetric($resumen, 'total_detalles'); ?></h3>
                <p class="text-muted small mb-0">Eventos registrados</p>
            </div>
        </article>

        <article class="card border-0 shadow-sm dashboard-card dashboard-card--metric">
            <div class="card-body">
                <p class="dashboard-eyebrow mb-2">Herramientas activas</p>
                <h3 class="dashboard-metric-value mb-0"><?php echo dashboardMetric($resumen, 'herramientas'); ?></h3>
            </div>
        </article>

        <article class="card border-0 shadow-sm dashboard-card dashboard-card--metric">
            <div class="card-body">
                <p class="dashboard-eyebrow mb-2">Miembros activos</p>
                <h3 class="dashboard-metric-value mb-0"><?php echo dashboardMetric($resumen, 'miembros_activos'); ?></h3>
            </div>
        </article>
    </section>

    <section class="dashboard-grid dashboard-grid--summary">
        <article class="card border-0 shadow-sm dashboard-card">
            <div class="card-body">
                <h6 class="text-muted mb-3">Detalle de ejecucion</h6>
                <div class="dashboard-inline-stats">
                    <div>
                        <p class="mb-1 text-muted small">Ejecutadas</p>
                        <h4 class="fw-bold mb-0"><?php echo dashboardMetric($resumen, 'detalles_ejecutados'); ?></h4>
                    </div>
                    <div class="text-end">
                        <p class="mb-1 text-muted small">Pendientes</p>
                        <h4 class="fw-bold mb-0"><?php echo dashboardMetric($resumen, 'detalles_pendientes'); ?></h4>
                    </div>
                </div>
                <div class="progress mt-3" style="height: 6px;">
                    <div class="progress-bar bg-success" role="progressbar"
                        style="width: <?php echo $porcEjecutados; ?>%" aria-valuenow="<?php echo $porcEjecutados; ?>"
                        aria-valuemin="0" aria-valuemax="100"></div>
                </div>
                <p class="text-muted small mb-0 mt-2"><?php echo $porcEjecutados; ?>% completado en la ultima ventana.</p>
            </div>
        </article>

        <article class="card border-0 shadow-sm dashboard-card">
            <div class="card-body">
                <h6 class="text-muted mb-3">Usuarios y actividad</h6>
                <div class="dashboard-inline-stats dashboard-inline-stats--center">
                    <div class="text-center">
                        <p class="text-muted small mb-1">Usuarios activos</p>
                        <h4 class="fw-bold mb-0"><?php echo dashboardMetric($resumen, 'usuarios_activos'); ?></h4>
                    </div>
                    <div class="text-center">
                        <p class="text-muted small mb-1">Logs (ultimos 7 dias)</p>
                        <h4 class="fw-bold mb-0"><?php echo dashboardMetric($resumen, 'logs_semana'); ?></h4>
                    </div>
                </div>
            </div>
        </article>
    </section>

    <section class="dashboard-grid dashboard-grid--charts">
        <article class="card border-0 shadow-sm dashboard-card">
            <div class="card-header bg-transparent border-bottom-0 d-flex justify-content-between align-items-center">
                <div>
                    <p class="dashboard-eyebrow mb-1">Vision general</p>
                    <h5 class="mb-0">Ordenes de trabajo por estado</h5>
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
        </article>

        <article class="card border-0 shadow-sm dashboard-card">
            <div class="card-header">
                <h5 class="mb-0">Turnos activos</h5>
                <small class="text-muted">Participacion por franja</small>
            </div>
            <div class="card-body">
                <div class="c-chart-wrapper" style="min-height: 220px;">
                    <canvas id="ChartTurno"></canvas>
                </div>
                <div class="row row-cols-1 g-3 mt-3">
                    <?php echo $insMain->listarCardTurnoControlador(); ?>
                </div>
            </div>
        </article>
    </section>

    <section class="dashboard-grid dashboard-grid--secondary">
        <article class="card border-0 shadow-sm dashboard-card">
            <div class="card-header">
                <div>
                    <p class="dashboard-eyebrow mb-1">Detalle por area</p>
                    <h6 class="mb-0">Porcentaje de estados</h6>
                </div>
            </div>
            <div class="card-body" style="min-height: 320px;">
                <div id="graficas-container1" class="d-flex flex-wrap gap-2 justify-content-center"></div>
            </div>
        </article>

        <article class="card border-0 shadow-sm dashboard-card">
            <div class="card-header">
                <div>
                    <p class="dashboard-eyebrow mb-1">Detalle por turno</p>
                    <h6 class="mb-0">Estados dentro de cada turno</h6>
                </div>
            </div>
            <div class="card-body" style="min-height: 320px;">
                <div id="graficas-container2" class="d-flex flex-wrap gap-2 justify-content-center"></div>
            </div>
        </article>
    </section>

    <section class="dashboard-grid dashboard-grid--activity">
        <article class="card border-0 shadow-sm dashboard-card">
            <div class="card-header">
                <h5 class="mb-0">Actividad del sistema</h5>
                <small class="text-muted">Participacion historica y logs</small>
            </div>
            <div class="card-body p-0" style="max-height: 360px; overflow-y: auto;">
                <?php echo $insMain->listarActividadesControlador(); ?>
            </div>
        </article>
    </section>
</div>

<?php require_once "./app/views/scripts/script-panel.php"; ?>

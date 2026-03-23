<?php $isAdmin = (isset($_SESSION['tipo']) && (int)$_SESSION['tipo'] === 1); ?>

<div class="tools-scope">

    <div class="row pb-3">
        <div class="container-fluid">
            <div class="page-head">
                <h3>Configuración</h3>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="card mb-4">

            <!-- ✅ HEADER con BADGE -->
            <div class="card-header d-flex align-items-center justify-content-between flex-wrap gap-2">
                <div class="d-flex align-items-center gap-2">
                    <strong>Parámetros del sistema</strong>

                    <?php if ($isAdmin) { ?>
                    <span class="badge section-role-badge bg-success">
                        <i class="bi bi-shield-check me-1"></i>Administrador
                    </span>
                    <?php } else { ?>
                    <span class="badge section-role-badge bg-secondary">
                        <i class="bi bi-person me-1"></i>Usuario
                    </span>
                    <?php } ?>
                </div>

                <!-- MÓVIL: selector de sección -->
                <div class="d-md-none w-100">
                    <select class="form-select form-select-sm" id="configTabSelect">
                        <option value="#v-pills-cuenta" selected>Cuenta</option>
                        <?php if ($isAdmin) { ?>
                        <option value="#v-pills-empresa">Datos Empresa</option>
                        <option value="#v-pills-smtp">SMTP (Google)</option>
                        <option value="#v-pills-categoria-empleado">Categorias Empleado</option>
                        <option value="#v-pills-categoria-herramienta">Categorias Herramienta</option>
                        <option value="#v-pills-empleado">Empleados</option>
                        <option value="#v-pills-roles">Roles</option>
                        <option value="#v-pills-estado">Estados</option>
                        <option value="#v-pills-sitio">Sitios</option>
                        <option value="#v-pills-area">Áreas</option>
                        <option value="#v-pills-turno">Turnos</option>
                        <option value="#v-pills-backup">Respaldo BD</option>
                        <?php } ?>
                    </select>
                </div>
            </div>

            <div class="card-body">
                <div class="row g-3">

                    <!-- DESKTOP: menú lateral -->
                    <div class="col-md-4 col-lg-3 d-none d-md-block">
                        <div class="list-group config-menu" id="v-pills-tab" role="tablist" aria-orientation="vertical">

                            <button class="list-group-item list-group-item-action active" id="v-pills-cuenta-tab"
                                data-bs-toggle="pill" data-bs-target="#v-pills-cuenta" type="button" role="tab"
                                aria-controls="v-pills-cuenta" aria-selected="true">
                                <div class="d-flex align-items-center gap-2">
                                    <i class="bi bi-person-gear"></i>
                                    <div>
                                        <div class="fw-semibold">Cuenta</div>
                                        <small class="">Datos personales y seguridad</small>
                                    </div>
                                </div>
                            </button>

                            <?php if ($isAdmin) { ?>
                            <button class="list-group-item list-group-item-action" id="v-pills-empresa-tab"
                                data-bs-toggle="pill" data-bs-target="#v-pills-empresa" type="button" role="tab"
                                aria-controls="v-pills-empresa" aria-selected="false">
                                <div class="d-flex align-items-center gap-2">
                                    <i class="bi bi-building"></i>
                                    <div>
                                        <div class="fw-semibold">Datos Empresa</div>
                                        <small class="">Identidad y ajustes generales</small>
                                    </div>
                                </div>
                            </button>

                            <button class="list-group-item list-group-item-action" id="v-pills-smtp-tab"
                                data-bs-toggle="pill" data-bs-target="#v-pills-smtp" type="button" role="tab"
                                aria-controls="v-pills-smtp" aria-selected="false">
                                <div class="d-flex align-items-center gap-2">
                                    <i class="bi bi-envelope-at"></i>
                                    <div>
                                        <div class="fw-semibold">SMTP (Google)</div>
                                        <small class="">Correo y notificaciones</small>
                                    </div>
                                </div>
                            </button>

                            <button class="list-group-item list-group-item-action" id="v-pills-categoria-empleado-tab"
                                data-bs-toggle="pill" data-bs-target="#v-pills-categoria-empleado" type="button" role="tab"
                                aria-controls="v-pills-categoria-empleado" aria-selected="false">
                                <div class="d-flex align-items-center gap-2">
                                    <i class="bi bi-tags"></i>
                                    <div>
                                        <div class="fw-semibold">Categorias Empleado</div>
                                        <small class="">Clasificacion del personal</small>
                                    </div>
                                </div>
                            </button>

                            <button class="list-group-item list-group-item-action" id="v-pills-categoria-herramienta-tab"
                                data-bs-toggle="pill" data-bs-target="#v-pills-categoria-herramienta" type="button" role="tab"
                                aria-controls="v-pills-categoria-herramienta" aria-selected="false">
                                <div class="d-flex align-items-center gap-2">
                                    <i class="bi bi-tools"></i>
                                    <div>
                                        <div class="fw-semibold">Categorias Herramienta</div>
                                        <small class="">Clasificacion del inventario</small>
                                    </div>
                                </div>
                            </button>

                            <button class="list-group-item list-group-item-action" id="v-pills-empleado-tab"
                                data-bs-toggle="pill" data-bs-target="#v-pills-empleado" type="button" role="tab"
                                aria-controls="v-pills-empleado" aria-selected="false">
                                <div class="d-flex align-items-center gap-2">
                                    <i class="bi bi-person-vcard"></i>
                                    <div>
                                        <div class="fw-semibold">Empleados</div>
                                        <small class="">Datos base del personal</small>
                                    </div>
                                </div>
                            </button>

                            <button class="list-group-item list-group-item-action" id="v-pills-roles-tab"
                                data-bs-toggle="pill" data-bs-target="#v-pills-roles" type="button" role="tab"
                                aria-controls="v-pills-roles" aria-selected="false">
                                <div class="d-flex align-items-center gap-2">
                                    <i class="bi bi-shield-lock"></i>
                                    <div>
                                        <div class="fw-semibold">Roles</div>
                                        <small class="">Permisos y perfiles</small>
                                    </div>
                                </div>
                            </button>

                            <button class="list-group-item list-group-item-action" id="v-pills-estado-tab"
                                data-bs-toggle="pill" data-bs-target="#v-pills-estado" type="button" role="tab"
                                aria-controls="v-pills-estado" aria-selected="false">
                                <div class="d-flex align-items-center gap-2">
                                    <i class="bi bi-flag"></i>
                                    <div>
                                        <div class="fw-semibold">Estados</div>
                                        <small class="">Estados de O.T.</small>
                                    </div>
                                </div>
                            </button>

                            <button class="list-group-item list-group-item-action" id="v-pills-sitio-tab"
                                data-bs-toggle="pill" data-bs-target="#v-pills-sitio" type="button" role="tab"
                                aria-controls="v-pills-sitio" aria-selected="false">
                                <div class="d-flex align-items-center gap-2">
                                    <i class="bi bi-geo-alt"></i>
                                    <div>
                                        <div class="fw-semibold">Sitios</div>
                                        <small class="">Ubicaciones / estaciones</small>
                                    </div>
                                </div>
                            </button>

                            <button class="list-group-item list-group-item-action" id="v-pills-area-tab"
                                data-bs-toggle="pill" data-bs-target="#v-pills-area" type="button" role="tab"
                                aria-controls="v-pills-area" aria-selected="false">
                                <div class="d-flex align-items-center gap-2">
                                    <i class="bi bi-diagram-3"></i>
                                    <div>
                                        <div class="fw-semibold">Áreas</div>
                                        <small class="">Áreas de trabajo</small>
                                    </div>
                                </div>
                            </button>

                            <button class="list-group-item list-group-item-action" id="v-pills-turno-tab"
                                data-bs-toggle="pill" data-bs-target="#v-pills-turno" type="button" role="tab"
                                aria-controls="v-pills-turno" aria-selected="false">
                                <div class="d-flex align-items-center gap-2">
                                    <i class="bi bi-clock"></i>
                                    <div>
                                        <div class="fw-semibold">Turnos</div>
                                        <small class="">Horarios y turnos</small>
                                    </div>
                                </div>
                            </button>

                            <button class="list-group-item list-group-item-action" id="v-pills-backup-tab"
                                data-bs-toggle="pill" data-bs-target="#v-pills-backup" type="button" role="tab"
                                aria-controls="v-pills-backup" aria-selected="false">
                                <div class="d-flex align-items-center gap-2">
                                    <i class="bi bi-database"></i>
                                    <div>
                                        <div class="fw-semibold">Respaldo BD</div>
                                        <small class="">Respaldo y restauracion</small>
                                    </div>
                                </div>
                            </button>
                            <?php } ?>
                        </div>


                    </div>

                    <!-- CONTENIDO -->
                    <div class="col-12 col-md-8 col-lg-9 p-2">

                        <?php if (!$isAdmin) { ?>
                        <div class="alert alert-info d-md-none">
                            <i class="bi bi-info-circle me-1"></i>
                            Tu cuenta <b>no tiene permisos de administrador</b> para ver/editar <b>Roles</b> ni
                            parámetros del sistema.
                            <br>
                            Solo puedes actualizar tus datos de acceso: <b>Username</b> y <b>Contraseña</b>.
                            <br>
                            <small class="d-block mt-1">
                                Antes de realizar cualquier cambio, consulta con tu <b>administrador</b> para evitar
                                inconsistencias en el sistema.
                            </small>
                        </div>

                        <?php } ?>

                        <div class="tab-content" id="v-pills-tabContent">

                            <div class="tab-pane fade show active" id="v-pills-cuenta" role="tabpanel"
                                aria-labelledby="v-pills-cuenta-tab">
                                <?php include "./app/views/content/viewConfig/config-user.php"; ?>
                            </div>

                            <?php if ($isAdmin) { ?>
                            <div class="tab-pane fade" id="v-pills-empresa" role="tabpanel"
                                aria-labelledby="v-pills-empresa-tab">
                                <?php include "./app/views/content/viewConfig/config-empresa.php"; ?>
                            </div>

                            <div class="tab-pane fade" id="v-pills-smtp" role="tabpanel"
                                aria-labelledby="v-pills-smtp-tab">
                                <?php include "./app/views/content/viewConfig/config-smtp.php"; ?>
                            </div>

                            <div class="tab-pane fade" id="v-pills-categoria-empleado" role="tabpanel"
                                aria-labelledby="v-pills-categoria-empleado-tab">
                                <?php include "./app/views/content/viewConfig/config-categoria-empleado.php"; ?>
                            </div>

                            <div class="tab-pane fade" id="v-pills-categoria-herramienta" role="tabpanel"
                                aria-labelledby="v-pills-categoria-herramienta-tab">
                                <?php include "./app/views/content/viewConfig/config-categoria-herramienta.php"; ?>
                            </div>

                            <div class="tab-pane fade" id="v-pills-empleado" role="tabpanel"
                                aria-labelledby="v-pills-empleado-tab">
                                <?php include "./app/views/content/viewConfig/config-empleado.php"; ?>
                            </div>

                            <div class="tab-pane fade" id="v-pills-roles" role="tabpanel"
                                aria-labelledby="v-pills-roles-tab">
                                <?php include "./app/views/content/viewConfig/config-roles.php"; ?>
                            </div>

                            <div class="tab-pane fade" id="v-pills-estado" role="tabpanel"
                                aria-labelledby="v-pills-estado-tab">
                                <?php include "./app/views/content/viewConfig/config-estado.php"; ?>
                            </div>

                            <div class="tab-pane fade" id="v-pills-sitio" role="tabpanel"
                                aria-labelledby="v-pills-sitio-tab">
                                <?php include "./app/views/content/viewConfig/config-sitio.php"; ?>
                            </div>

                            <div class="tab-pane fade" id="v-pills-area" role="tabpanel"
                                aria-labelledby="v-pills-area-tab">
                                <?php include "./app/views/content/viewConfig/config-area.php"; ?>
                            </div>

                            <div class="tab-pane fade" id="v-pills-turno" role="tabpanel"
                                aria-labelledby="v-pills-turno-tab">
                                <?php include "./app/views/content/viewConfig/config-turno.php"; ?>
                            </div>

                            <div class="tab-pane fade" id="v-pills-backup" role="tabpanel"
                                aria-labelledby="v-pills-backup-tab">
                                <?php include "./app/views/content/viewConfig/config-backup.php"; ?>
                            </div>
                            <?php } ?>

                        </div>
                    </div>

                </div>
            </div>
        </div>
    </div>
</div>

<?php require_once "./app/views/scripts/script-config.php"; ?>
<script>
document.addEventListener('DOMContentLoaded', function() {
    const select = document.getElementById('configTabSelect');
    if (!select) return;

    if (!window.bootstrap || !bootstrap.Tab) {
        console.error('[Config] Bootstrap Tab no disponible. Revisa carga de bootstrap.bundle.min.js');
        return;
    }

    select.addEventListener('change', function() {
        const target = this.value;
        const btn = document.querySelector(`[data-bs-target="${target}"]`);
        if (btn) bootstrap.Tab.getOrCreateInstance(btn).show();
    });

    document.querySelectorAll('#v-pills-tab [data-bs-toggle="pill"]').forEach(btn => {
        btn.addEventListener('shown.bs.tab', function(e) {
            const target = e.target.getAttribute('data-bs-target');
            if (target) select.value = target;
        });
    });
});
</script>

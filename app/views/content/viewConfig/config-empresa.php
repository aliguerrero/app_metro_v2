    <!-- Encabezado -->
    <div class="d-flex align-items-center gap-2 mb-2">
        <div class="avatar avatar-md bg-light d-flex align-items-center justify-content-center">
            <i class="bi bi-building fs-4"></i>
        </div>
        <div>
            <h4 class="mb-0">Configuración de Empresa</h4>
            <small class="text-muted">Administra identidad y datos de contacto</small>
        </div>
        <span class="badge bg-primary">
            ID: <?= htmlspecialchars($empresa['id'] ?? '1') ?>
        </span>
    </div>
    <hr class="my-3">

    <form id="formEmpresaConfig" autocomplete="off" enctype="multipart/form-data">
        <input type="hidden" name="id" value="<?= htmlspecialchars($empresa['id'] ?? '1') ?>">

        <!-- BLOQUE: Logo -->
        <div class="card mb-3">
            <div class="card-header">
                <strong>Identidad visual</strong>
            </div>

            <div class="card-body">
                <div class="row g-3 align-items-stretch">

                    <!-- Logo actual -->
                    <div class="col-12 col-lg-6">
                        <label class="form-label"><b>Logo actual</b></label>

                        <div class=" rounded-3 p-3 h-100 d-flex flex-column flex-sm-row gap-3 align-items-center align-items-sm-start">
                            <div class="border rounded-3 bg-light d-flex align-items-center justify-content-center empresa-logo-box">
                                <img
                                    id="logoImage"
                                    src=""
                                    alt="logo"
                                    class="empresa-logo-img">
                            </div>

                            <div class="flex-grow-1 w-100">
                                <div class="fw-semibold">Ruta actual</div>
                                <div class="small text-muted text-break">
                                    <?= htmlspecialchars($empresa['logo'] ?? '') ?>
                                </div>

                                <div class="small text-muted mt-2">
                                    Recomendado: imagen cuadrada (PNG/JPG). Tamaño ideal: 512×512.
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Cambiar logo -->
                    <div class="col-12 col-lg-6">
                        <label class="form-label"><b>Cambiar logo (opcional)</b></label>

                        <div class="rounded-3 p-3 h-100">
                            <input type="file" class="form-control" name="logo_file" accept="image/*">
                            <div class="form-text">
                                Al guardar, el logo actual se reemplaza automáticamente.
                            </div>
                        </div>
                    </div>

                </div>
            </div>
        </div>

        <!-- BLOQUE: Datos Empresa -->
        <div class="card mb-3">
            <div class="card-header">
                <strong>Datos de la empresa</strong>
            </div>

            <div class="card-body">
                <div class="row g-3">

                    <div class="col-12 col-md-6">
                        <label class="form-label"><b>Nombre</b></label>
                        <input type="text" class="form-control" name="nombre"
                            value="<?= htmlspecialchars($empresa['nombre'] ?? '') ?>" required>
                    </div>

                    <div class="col-12 col-md-6">
                        <label class="form-label"><b>RIF</b></label>
                        <input type="text" class="form-control" name="rif"
                            value="<?= htmlspecialchars($empresa['rif'] ?? '') ?>">
                    </div>

                    <div class="col-12">
                        <label class="form-label"><b>Dirección</b></label>
                        <textarea class="form-control" name="direccion" rows="2"><?= htmlspecialchars($empresa['direccion'] ?? '') ?></textarea>
                    </div>

                    <div class="col-12 col-md-6">
                        <label class="form-label"><b>Teléfono</b></label>
                        <input type="text" class="form-control" name="telefono"
                            value="<?= htmlspecialchars($empresa['telefono'] ?? '') ?>">
                    </div>

                    <div class="col-12 col-md-6">
                        <label class="form-label"><b>Email</b></label>
                        <input type="email" class="form-control" name="email"
                            value="<?= htmlspecialchars($empresa['email'] ?? '') ?>">
                    </div>

                </div>
            </div>
        </div>

        <!-- ACTIONS (igual que las otras vistas) -->
        <div class="d-flex align-items-center gap-2 flex-wrap">
            <div class="btn-group w-100 w-lg-auto" role="group" aria-label="Acciones empresa">
                <button type="submit" class="btn bg-success text-white" id="btnGuardarEmpresa">
                    <i class="bi bi-check2-circle me-1"></i> Guardar cambios
                </button>

                <button type="reset" class="btn bg-danger text-white">
                    <i class="bi bi-arrow-counterclockwise me-1"></i> Restablecer
                </button>
            </div>

            <div id="msgEmpresaConfig" class="ms-lg-auto small"></div>
        </div>


    </form>


    <!-- CSS mínimo (solo para el logo) -->
    <style>
        .empresa-logo-box {
            width: 140px;
            height: 140px;
            overflow: hidden;
        }

        .empresa-logo-img {
            width: 100%;
            height: 100%;
            object-fit: contain;
        }

        /* En móvil, que no se vea apretado */
        @media (max-width: 575.98px) {
            .empresa-logo-box {
                width: 160px;
                height: 160px;
                margin: 0 auto;
            }
        }
    </style>

    <script src="<?= APP_URL ?>app/views/js/empresa_config.js"></script>
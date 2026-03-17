<!-- Encabezado -->
<div class="d-flex align-items-center gap-2 mb-2">
    <div class="avatar avatar-md bg-light d-flex align-items-center justify-content-center">
        <i class="bi bi-envelope-at-fill fs-4"></i>
    </div>
    <div>
        <h4 class="mb-0">SMTP (Google)</h4>
        <small class="text-muted">Configura el envio de correos usando Gmail / Google Workspace.</small>
    </div>
</div>

<hr>

<form id="formSmtpConfig" autocomplete="off">
    <div class="card mb-3">
        <div class="card-header d-flex align-items-center justify-content-between flex-wrap gap-2">
            <strong>Conexion SMTP</strong>
            <div id="msgSmtpConfig" class="small text-muted"></div>
        </div>

        <div class="card-body">
            <div class="row g-3">
                <div class="col-12">
                    <div class="form-check form-switch">
                        <input class="form-check-input" type="checkbox" id="smtp_enabled" name="enabled" value="1">
                        <label class="form-check-label" for="smtp_enabled"><b>Habilitar envio por SMTP</b></label>
                    </div>
                    <div class="form-text">
                        Recomendado: usa una <b>App Password</b> de Google (cuenta con 2FA).
                    </div>
                </div>

                <div class="col-12 col-lg-6">
                    <label class="form-label"><b>Host</b></label>
                    <input class="form-control" type="text" id="smtp_host" name="host" value="smtp.gmail.com"
                        placeholder="smtp.gmail.com">
                </div>

                <div class="col-6 col-lg-3">
                    <label class="form-label"><b>Puerto</b></label>
                    <input class="form-control" type="number" id="smtp_port" name="port" value="587" min="1"
                        max="65535">
                    <div class="form-text">587 (STARTTLS) o 465 (SSL)</div>
                </div>

                <div class="col-6 col-lg-3">
                    <label class="form-label"><b>Cifrado</b></label>
                    <select class="form-select" id="smtp_encryption" name="encryption">
                        <option value="tls" selected>TLS (STARTTLS)</option>
                        <option value="ssl">SSL</option>
                        <option value="none">Sin cifrado</option>
                    </select>
                </div>

                <div class="col-12 col-lg-6">
                    <label class="form-label"><b>Usuario (correo)</b></label>
                    <input class="form-control" type="email" id="smtp_username" name="username"
                        placeholder="tucuenta@gmail.com">
                </div>

                <div class="col-12 col-lg-6">
                    <label class="form-label"><b>Clave (App Password)</b></label>
                    <div class="input-group">
                        <input class="form-control" type="password" id="smtp_password" name="password"
                            placeholder="Deja en blanco para mantener la clave" autocomplete="new-password">
                        <button class="btn btn-outline-secondary" type="button" id="smtpPassToggle"
                            aria-label="Mostrar contraseña" title="Mostrar/ocultar">
                            <i class="bi bi-eye"></i>
                        </button>
                    </div>
                    <div class="form-text" id="smtpPassNote">
                        Coloca tu App Password de Google. Si ya hay una guardada, deja en blanco para mantenerla.
                    </div>
                </div>

                <div class="col-12 col-lg-6">
                    <label class="form-label"><b>From (correo)</b></label>
                    <input class="form-control" type="email" id="smtp_from_email" name="from_email"
                        placeholder="tucuenta@gmail.com">
                </div>

                <div class="col-12 col-lg-6">
                    <label class="form-label"><b>From (nombre)</b></label>
                    <input class="form-control" type="text" id="smtp_from_name" name="from_name"
                        placeholder="Nombre remitente (opcional)">
                </div>
            </div>
        </div>
    </div>

    <div class="d-flex align-items-center gap-2 flex-wrap mb-4">
        <div class="btn-group w-100 w-lg-auto" role="group" aria-label="Acciones SMTP">
            <button type="submit" class="btn bg-success text-white" id="btnGuardarSmtp">
                <i class="bi bi-check2-circle me-1"></i> Guardar
            </button>
            <button type="reset" class="btn bg-danger text-white">
                <i class="bi bi-arrow-counterclockwise me-1"></i> Restablecer
            </button>
        </div>
    </div>
</form>

<div class="card border-primary">
    <div class="card-header d-flex align-items-center justify-content-between flex-wrap gap-2 bg-primary bg-opacity-10">
        <strong>Prueba de envio</strong>
    </div>
    <div class="card-body">
        <div class="row g-3 align-items-end">
            <div class="col-12 col-lg-8">
                <label class="form-label"><b>Enviar a (correo destino)</b></label>
                <input class="form-control" type="email" id="smtp_test_to" placeholder="destino@correo.com">
                <div class="form-text">
                    La prueba usa la configuracion actual guardada en el sistema.
                </div>
            </div>
            <div class="col-12 col-lg-4 d-flex">
                <button type="button" class="btn btn-primary w-100" id="btnTestSmtpSecondary">
                    <i class="bi bi-send me-1"></i> Enviar
                </button>
            </div>
        </div>
    </div>
</div>

<script src="<?php echo APP_URL; ?>app/views/js/smtp_config.js"></script>
<?php
if (!isset($insLogin) || !($insLogin instanceof \app\controllers\loginController)) {
    $insLogin = new \app\controllers\loginController();
}

$insLogin->asegurarRolRootControlador();
$bootstrapMode = $insLogin->sistemaRequiereBootstrapControlador();
?>
<style>
:root {
    --brand-orange: #c8841c;
    --brand-orange-2: #efb55a;
    --brand-dark: #102030;
    --brand-ink: #1f2933;
    --brand-gray: #4f6475;
    --brand-light: #f4f7fa;
    --line: rgba(31, 41, 55, .10);
}

/* Fondo general */
.login-shell {
    width: 100%;
    min-height: 100vh;
    display: flex;
    align-items: center;
    background:
        radial-gradient(1100px 520px at 12% 10%, rgba(42, 90, 142, .20), transparent 60%),
        radial-gradient(900px 460px at 90% 30%, rgba(200, 132, 28, .18), transparent 55%),
        linear-gradient(180deg, #f4f7fa 0%, #e6edf4 100%);
}

/* Tarjeta principal */
.login-card {
    border: 0;
    border-radius: 1.25rem;
    overflow: hidden;
    box-shadow: 0 28px 70px rgba(15, 23, 42, .16);
    border: 1px solid rgba(31, 41, 55, .08);
    background: #fff;
}

/* Panel de marca */
.login-brand {
    position: relative;
    color: #fff;
    background:
        linear-gradient(155deg, #102030 0%, #18344d 56%, #24506f 100%);
    padding: 2rem 2.5rem;
}

/* acento naranja arriba (tipo highlight del logo) */
.login-brand::before {
    content: "";
    position: absolute;
    inset: 0 0 auto 0;
    height: 4px;
    background: linear-gradient(90deg, var(--brand-orange), var(--brand-orange-2));
}

.login-brand::after {
    content: "";
    position: absolute;
    inset: -70px -70px auto auto;
    width: 240px;
    height: 240px;
    border-radius: 999px;
    background: radial-gradient(circle at 30% 30%, rgba(239, 181, 90, .34), rgba(255, 255, 255, .08) 52%, transparent 70%);
}

.login-brand small {
    opacity: .9;
}

/* Seccion formulario */
.login-form {
    background: linear-gradient(180deg, #ffffff 0%, #f7fafc 100%);
    padding: 2rem 3rem;
}

/* Tipografia del form */
.login-form h1,
.login-form .h3 {
    color: var(--brand-ink);
    letter-spacing: .2px;
    font-family: "Cambria", "Georgia", serif;
}

.login-form .text-muted {
    color: rgba(17, 24, 39, .65) !important;
}

/* Inputs */
.login-card .input-group-text {
    background: #edf3f9;
    border: 1px solid rgba(31, 41, 55, .10);
    border-right: 0;
    color: #415669;
}

.login-card .form-control,
.login-card .form-select,
.login-card textarea.form-control {
    border: 1px solid rgba(31, 41, 55, .10);
    padding-top: .8rem;
    padding-bottom: .8rem;
    color: #1f2933;
}

.login-card .input-group .form-control {
    border-left: 0;
}

.login-card .form-control:focus {
    box-shadow: 0 0 0 .22rem rgba(53, 85, 111, .16);
    border-color: rgba(53, 85, 111, .42);
}

/* Boton (naranja) */
.btn-login {
    padding: .85rem 1rem;
    border-radius: .9rem;
    font-weight: 700;
    border: 0;
    background: linear-gradient(135deg, #1d5f92 0%, #2a79b6 100%);
    box-shadow: 0 14px 26px rgba(29, 95, 146, .24);
}

.btn-login:hover {
    filter: brightness(.98);
    box-shadow: 0 18px 30px rgba(29, 95, 146, .28);
}

/* Si tu boton usa btn-primary, lo "tinteamos" sin tocar HTML */
.login-form .btn.btn-primary {
    background: linear-gradient(135deg, #1d5f92 0%, #2a79b6 100%) !important;
    border-color: transparent !important;
}

.login-form .btn.btn-primary:focus {
    box-shadow: 0 0 0 .22rem rgba(29, 95, 146, .20) !important;
}

.login-form .btn-link {
    color: #1d5f92;
    font-weight: 700;
}

.login-form .btn-link:hover {
    color: #174f79;
}

.setup-badge {
    display: inline-flex;
    align-items: center;
    gap: .45rem;
    padding: .45rem .8rem;
    border-radius: 999px;
    background: rgba(16, 32, 48, .06);
    color: #1d4d72;
    font-weight: 700;
    font-size: .88rem;
}

.setup-panel {
    padding: 1rem 1.05rem;
    border-radius: 1rem;
    border: 1px solid rgba(31, 41, 55, .10);
    background: linear-gradient(180deg, #ffffff 0%, #f8fafc 100%);
}

.setup-panel .setup-value {
    min-height: 52px;
    display: flex;
    align-items: center;
    padding: .78rem .9rem;
    border-radius: .9rem;
    border: 1px solid rgba(31, 41, 55, .08);
    background: #ffffff;
    color: var(--brand-ink);
    font-weight: 600;
}

.setup-note {
    font-size: .92rem;
    color: rgba(17, 24, 39, .65);
}

.auth-page .modal-content {
    border-radius: 1.1rem;
    border: 1px solid rgba(31, 41, 55, .10);
    box-shadow: 0 20px 55px rgba(15, 23, 42, .14);
}

.auth-page .modal-header {
    background: linear-gradient(180deg, #fbfcfd 0%, #f2f5f8 100%);
    border-bottom: 1px solid rgba(31, 41, 55, .10);
}

.auth-page .modal-body {
    background: linear-gradient(180deg, #ffffff 0%, #fafbfd 100%);
}

/* Ajustes para escritorio */
@media (min-width: 992px) {
    .login-shell {
        background:
            radial-gradient(1200px 520px at 10% 12%, rgba(42, 90, 142, .18), transparent 60%),
            radial-gradient(900px 460px at 92% 10%, rgba(200, 132, 28, .14), transparent 58%),
            linear-gradient(180deg, #f6f8fb 0%, #e8eef5 100%);
    }

    .login-card {
        max-width: 900px;
        /* un poco mas ancho */
        margin: 0 auto;
    }

    .login-brand {
        padding: 3rem 3rem;
    }

    .login-form {
        padding: 3rem 4rem;
    }

    .login-form h1 {
        font-size: 2.5rem;
    }

    .login-form .form-control {
        font-size: 1.05rem;
        padding: .78rem;
    }

    .login-form .btn-login,
    .login-form .btn.btn-primary {
        font-size: 1.05rem;
    }

    .login-brand h2 {
        font-size: 2.2rem;
        margin-bottom: 1.25rem;
    }

    .login-form .text-muted,
    .login-form small {
        font-size: 1rem;
    }
}

/* Ajustes mobile: que se vea tipo "hero" arriba */
@media (max-width: 991.98px) {
    .login-brand {
        padding: 1.75rem 1.5rem !important;
    }

    .login-form {
        padding: 1.5rem 1.5rem;
    }
}
</style>

<div class="login-shell">
    <div class="container py-4">
        <div class="row justify-content-center">
            <div class="col-12 col-md-10 col-lg-8">

                <div class="card login-card">
                    <div class="row g-0">

                        <!-- Panel Marca / Info -->
                        <div class="col-lg-5 login-brand p-4 p-lg-5 d-flex flex-column justify-content-between">
                            <div class="d-flex flex-column align-items-center text-center gap-2 mb-4">
                                <img src="<?php echo APP_URL; ?>app/views/img/logo.png" alt="Logo de la empresa"
                                    style="width:180px; height:180px; object-fit:contain;">
                            </div>

                            <h2 class="fw-bold mb-2" style="letter-spacing:.2px;"><?php echo $bootstrapMode ? 'Configuracion inicial' : 'Bienvenido'; ?></h2>
                            <p class="mb-0" style="opacity:.92;">
                                <?php if ($bootstrapMode) { ?>
                                    Crea el primer empleado administrador y el sistema preparara automaticamente la categoria inicial y el rol ROOT.
                                <?php } else { ?>
                                    Controla ordenes de trabajo, personal operativo y reportes con una interfaz clara y segura.
                                <?php } ?>
                            </p>

                            <div class="mt-4">
                                <small>
                                    <?php echo $bootstrapMode
                                        ? 'Esta configuracion solo aparece cuando el sistema aun no tiene usuarios activos.'
                                        : 'Solicita acceso al administrador del sistema si aun no tienes una cuenta.'; ?>
                                </small>
                            </div>
                        </div>

                        <!-- Formulario -->
                        <div class="col-lg-7 login-form p-4 p-lg-5">
                            <?php if ($bootstrapMode) { ?>
                                <div class="mb-4">
                                    <span class="setup-badge mb-3">
                                        <i class="bi bi-shield-lock"></i>
                                        Primer arranque
                                    </span>
                                    <h1 class="h3 fw-bold mb-1">Crear usuario root</h1>
                                    <div class="text-muted">El sistema no tiene usuarios activos. Completa este formulario para crear el primer administrador.</div>
                                </div>

                                <form action="" method="POST" autocomplete="off">
                                    <input type="hidden" name="bootstrap_root" value="1">

                                    <div class="row g-3">
                                        <div class="col-12 col-md-3">
                                            <label for="bootstrap_nacionalidad" class="form-label">Nacionalidad</label>
                                            <select class="form-select" id="bootstrap_nacionalidad" name="bootstrap_nacionalidad" required>
                                                <option value="V">V</option>
                                                <option value="E">E</option>
                                            </select>
                                        </div>
                                        <div class="col-12 col-md-9">
                                            <label for="bootstrap_id_empleado" class="form-label">Identificacion</label>
                                            <input type="text" class="form-control" id="bootstrap_id_empleado" name="bootstrap_id_empleado" placeholder="Ej: 12345678" required>
                                        </div>

                                        <div class="col-12">
                                            <label for="bootstrap_nombre_empleado" class="form-label">Nombre completo</label>
                                            <input type="text" class="form-control" id="bootstrap_nombre_empleado" name="bootstrap_nombre_empleado" placeholder="Nombre y apellido del administrador" required>
                                        </div>

                                        <div class="col-12 col-md-6">
                                            <label for="bootstrap_telefono" class="form-label">Telefono</label>
                                            <input type="text" class="form-control" id="bootstrap_telefono" name="bootstrap_telefono" placeholder="0412-0000000">
                                        </div>
                                        <div class="col-12 col-md-6">
                                            <label for="bootstrap_correo" class="form-label">Correo</label>
                                            <input type="email" class="form-control" id="bootstrap_correo" name="bootstrap_correo" placeholder="correo@dominio.com" required>
                                        </div>

                                        <div class="col-12">
                                            <label for="bootstrap_direccion" class="form-label">Direccion</label>
                                            <textarea class="form-control" id="bootstrap_direccion" name="bootstrap_direccion" rows="2" placeholder="Direccion del administrador root"></textarea>
                                        </div>

                                        <div class="col-12">
                                            <div class="setup-panel">
                                                <div class="row g-3">
                                                    <div class="col-12 col-lg-4">
                                                        <label class="form-label mb-1">Username reservado</label>
                                                        <div class="setup-value">root</div>
                                                    </div>
                                                    <div class="col-12 col-lg-8">
                                                        <label class="form-label mb-1">Preparacion automatica</label>
                                                        <div class="setup-value">Se creara la categoria inicial y el rol ROOT con todos los permisos activos.</div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="col-12 col-md-6">
                                            <label for="bootstrap_password" class="form-label">Clave root</label>
                                            <div class="input-group">
                                                <span class="input-group-text" aria-hidden="true">
                                                    <i class="bx bx-lock-alt fs-5"></i>
                                                </span>
                                                <input type="password" class="form-control" id="bootstrap_password" name="bootstrap_password" placeholder="Crea una clave segura" required>
                                            </div>
                                        </div>
                                        <div class="col-12 col-md-6">
                                            <label for="bootstrap_password_confirm" class="form-label">Confirmar clave</label>
                                            <div class="input-group">
                                                <span class="input-group-text" aria-hidden="true">
                                                    <i class="bx bx-lock-alt fs-5"></i>
                                                </span>
                                                <input type="password" class="form-control" id="bootstrap_password_confirm" name="bootstrap_password_confirm" placeholder="Repite la clave" required>
                                                <button type="button" class="btn btn-outline-secondary" id="toggleBootstrapPasswords" aria-label="Mostrar claves" title="Mostrar">
                                                    <i class="bi bi-eye"></i>
                                                </button>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="setup-note mt-3">
                                        Recomendacion: usa un correo valido y una clave robusta. Esta cuenta tendra el control total del sistema.
                                    </div>

                                    <button class="btn btn-primary w-100 btn-login mt-4" type="submit">Crear administrador root</button>

                                    <div class="text-center text-muted mt-3" style="font-size:.9rem;">
                                        <small>&copy; <?php echo date('Y'); ?> Sistema de gestion operativa Metro</small>
                                    </div>
                                </form>
                            <?php } else { ?>
                                <div class="mb-4">
                                    <h1 class="h3 fw-bold mb-1">Iniciar sesion</h1>
                                    <div class="text-muted">Ingresa tus credenciales para acceder al sistema operativo</div>
                                </div>

                                <form action="" method="POST" class="needs-validation" novalidate>
                                    <div class="mb-3">
                                        <label for="username" class="form-label">Username</label>
                                        <div class="input-group">
                                            <span class="input-group-text" aria-hidden="true">
                                                <i class="bx bx-user fs-5"></i>
                                            </span>
                                            <input type="text" class="form-control" id="username" name="username"
                                                placeholder="Username" required>
                                            <div class="invalid-feedback">Por favor ingresa tu nombre de usuario.</div>
                                        </div>
                                    </div>

                                    <div class="mb-4">
                                        <label for="password" class="form-label">Contrasena</label>
                                        <div class="input-group">
                                            <span class="input-group-text" aria-hidden="true">
                                                <i class="bx bx-lock-alt fs-5"></i>
                                            </span>
                                            <input type="password" class="form-control" id="password" name="password"
                                                placeholder="Contrasena" required>
                                            <button type="button" class="btn btn-outline-secondary" id="toggleLoginPassword"
                                                aria-label="Mostrar clave" title="Mostrar">
                                                <i class="bi bi-eye"></i>
                                            </button>
                                            <div class="invalid-feedback">Por favor ingresa tu contrasena.</div>
                                        </div>
                                    </div>

                                    <div class="text-end mb-3">
                                        <button type="button" class="btn btn-link p-0 text-decoration-none"
                                            data-bs-toggle="modal" data-bs-target="#modalRecuperarClave">
                                            Olvide mi contrasena
                                        </button>
                                    </div>

                                    <button class="btn btn-primary w-100 btn-login" type="submit">Entrar</button>

                                    <div class="text-center text-muted mt-3" style="font-size:.9rem;">
                                        <small>&copy; <?php echo date('Y'); ?> Sistema de gestion operativa Metro</small>
                                    </div>
                                </form>
                            <?php } ?>
                        </div>

                    </div>
                </div>

            </div>
        </div>
    </div>
</div>

<?php if (!$bootstrapMode) { ?>
<div class="modal fade" id="modalRecuperarClave" tabindex="-1" aria-labelledby="modalRecuperarClaveLabel"
    aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg">
            <div class="modal-header">
                <h5 class="modal-title" id="modalRecuperarClaveLabel">Recuperar clave</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <form id="formRecuperarClave" autocomplete="off">
                    <div class="mb-3">
                        <label for="recovery_username" class="form-label"><b>Username</b></label>
                        <input type="text" class="form-control" id="recovery_username" name="username"
                            placeholder="Ingresa tu username" required>
                    </div>
                    <div class="form-text mb-3">
                        Si la cuenta existe y tiene correo registrado, enviaremos una clave temporal.
                    </div>
                    <button type="submit" class="btn btn-primary w-100" id="btnRecuperarClave">Enviar nueva
                        clave</button>
                </form>
            </div>
        </div>
    </div>
</div>
<?php } ?>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const passwordInput = document.getElementById('password');
    const togglePasswordBtn = document.getElementById('toggleLoginPassword');
    const togglePasswordIcon = togglePasswordBtn ? togglePasswordBtn.querySelector('i') : null;
    const bootstrapPasswordInput = document.getElementById('bootstrap_password');
    const bootstrapPasswordConfirmInput = document.getElementById('bootstrap_password_confirm');
    const toggleBootstrapPasswordsBtn = document.getElementById('toggleBootstrapPasswords');
    const toggleBootstrapPasswordsIcon = toggleBootstrapPasswordsBtn ? toggleBootstrapPasswordsBtn.querySelector('i') : null;
    const formRec = document.getElementById('formRecuperarClave');
    const btnRec = document.getElementById('btnRecuperarClave');
    const modalEl = document.getElementById('modalRecuperarClave');
    const urlAjax = '<?php echo APP_URL; ?>app/ajax/loginAjax.php';

    if (passwordInput && togglePasswordBtn && togglePasswordIcon) {
        togglePasswordBtn.addEventListener('click', function() {
            const show = passwordInput.type === 'password';
            passwordInput.type = show ? 'text' : 'password';
            togglePasswordIcon.className = show ? 'bi bi-eye-slash' : 'bi bi-eye';
            togglePasswordBtn.setAttribute('aria-label', show ? 'Ocultar clave' : 'Mostrar clave');
            togglePasswordBtn.title = show ? 'Ocultar' : 'Mostrar';
        });
    }

    if (bootstrapPasswordInput && bootstrapPasswordConfirmInput && toggleBootstrapPasswordsBtn && toggleBootstrapPasswordsIcon) {
        toggleBootstrapPasswordsBtn.addEventListener('click', function() {
            const show = bootstrapPasswordInput.type === 'password';
            bootstrapPasswordInput.type = show ? 'text' : 'password';
            bootstrapPasswordConfirmInput.type = show ? 'text' : 'password';
            toggleBootstrapPasswordsIcon.className = show ? 'bi bi-eye-slash' : 'bi bi-eye';
            toggleBootstrapPasswordsBtn.setAttribute('aria-label', show ? 'Ocultar claves' : 'Mostrar claves');
            toggleBootstrapPasswordsBtn.title = show ? 'Ocultar' : 'Mostrar';
        });
    }

    if (!formRec || !btnRec || !modalEl) return;

    const fetchJsonSafe = async (url, options = {}) => {
        const res = await fetch(url, options);
        const text = await res.text();

        if (text.trim().startsWith('<')) {
            throw new Error('Respuesta invalida del servidor.');
        }

        try {
            return JSON.parse(text);
        } catch (e) {
            throw new Error('JSON invalido en recuperacion de clave.');
        }
    };

    const alertMsg = async (icon, title, text) => {
        if (window.Swal) {
            await Swal.fire({
                icon: icon || 'info',
                title: title || '',
                text: text || '',
                confirmButtonText: 'Aceptar'
            });
            return;
        }

        alert((title ? title + '\n' : '') + (text || ''));
    };

    const cleanModalArtifacts = () => {
        document.body.classList.remove('modal-open');
        document.body.style.removeProperty('padding-right');
        document.body.style.removeProperty('overflow');
        document.querySelectorAll('.modal-backdrop').forEach((backdrop) => backdrop.remove());
    };

    const closeRecoveryModal = async () => {
        if (!(window.bootstrap && bootstrap.Modal)) {
            cleanModalArtifacts();
            return;
        }

        const modalInst = bootstrap.Modal.getOrCreateInstance(modalEl);

        await new Promise((resolve) => {
            let settled = false;
            const done = () => {
                if (settled) return;
                settled = true;
                cleanModalArtifacts();
                resolve();
            };

            modalEl.addEventListener('hidden.bs.modal', done, {
                once: true
            });
            modalInst.hide();
            setTimeout(done, 350);
        });
    };

    formRec.addEventListener('submit', async function(e) {
        e.preventDefault();

        const usernameInput = document.getElementById('recovery_username');
        const username = (usernameInput?.value || '').trim();

        if (!username) {
            await alertMsg('warning', 'Campo requerido', 'Debes indicar tu username.');
            return;
        }

        const oldText = btnRec.textContent;
        btnRec.disabled = true;
        btnRec.textContent = 'Procesando...';

        try {
            const fd = new FormData();
            fd.append('modulo_login', 'recuperar_clave');
            fd.append('username', username);

            const data = await fetchJsonSafe(urlAjax, {
                method: 'POST',
                body: fd
            });

            if (!data || data.ok !== true) {
                await alertMsg('error', 'Recuperacion', data?.msg ||
                    'No se pudo procesar la recuperacion.');
                return;
            }

            formRec.reset();
            await closeRecoveryModal();
            await alertMsg('success', 'Recuperacion', data.msg ||
                'Solicitud procesada correctamente.');
        } catch (err) {
            await alertMsg('error', 'Recuperacion', err?.message ||
                'Error inesperado en recuperacion.');
        } finally {
            btnRec.disabled = false;
            btnRec.textContent = oldText;
        }
    });

    modalEl.addEventListener('hidden.bs.modal', function() {
        cleanModalArtifacts();
        formRec.reset();
        btnRec.disabled = false;
        btnRec.textContent = 'Enviar nueva clave';
    });
});
</script>

<?php
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
  if ($bootstrapMode && isset($_POST['bootstrap_root'])) {
    $insLogin->registrarPrimerUsuarioRootControlador();
  } elseif (!$bootstrapMode && isset($_POST['username']) && isset($_POST['password'])) {
    $insLogin->iniciarSesionControlador();
  }
}
?>





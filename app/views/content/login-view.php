<style>
:root {
    --brand-orange: #F57C00;
    /* naranja principal */
    --brand-orange-2: #FF9800;
    /* naranja secundario */
    --brand-dark: #0B0F14;
    /* negro */
    --brand-ink: #111827;
    /* texto oscuro */
    --brand-gray: #6B7280;
    /* gris medio */
    --brand-light: #F6F7FB;
    /* fondo claro */
    --line: rgba(17, 24, 39, .10);
    /* borde suave */
}

/* Fondo general */
.login-shell {
    width: 100%;
    min-height: 100vh;
    display: flex;
    align-items: center;
    background:
        radial-gradient(1100px 520px at 12% 10%, rgba(245, 124, 0, .18), transparent 62%),
        radial-gradient(900px 460px at 90% 30%, rgba(0, 0, 0, .10), transparent 58%),
        var(--brand-light);
}

/* Tarjeta principal */
.login-card {
    border: 0;
    border-radius: 1.25rem;
    overflow: hidden;
    box-shadow: 0 18px 55px rgba(2, 6, 23, .14);
    border: 1px solid rgba(2, 6, 23, .06);
    background: #fff;
}

/* Panel de marca */
.login-brand {
    position: relative;
    color: #fff;
    background:
        linear-gradient(145deg, var(--brand-dark) 0%, #141a22 55%, #1b2430 100%);
    padding: 2rem 2.5rem;
}

/* acento naranja arriba (tipo highlight del logo) */
.login-brand::before {
    content: "";
    position: absolute;
    inset: 0 0 auto 0;
    height: 6px;
    background: linear-gradient(90deg, var(--brand-orange), var(--brand-orange-2));
}

.login-brand::after {
    content: "";
    position: absolute;
    inset: -70px -70px auto auto;
    width: 240px;
    height: 240px;
    border-radius: 999px;
    background: radial-gradient(circle at 30% 30%, rgba(255, 152, 0, .22), rgba(255, 255, 255, .06) 55%, transparent 70%);
}

.login-brand small {
    opacity: .9;
}

/* Seccion formulario */
.login-form {
    background: #fff;
    padding: 2rem 3rem;
}

/* Tipografia del form */
.login-form h1,
.login-form .h3 {
    color: var(--brand-ink);
    letter-spacing: .2px;
}

.login-form .text-muted {
    color: rgba(17, 24, 39, .65) !important;
}

/* Inputs */
.login-card .input-group-text {
    background: #F3F4F6;
    border: 1px solid rgba(17, 24, 39, .10);
    border-right: 0;
}

.login-card .form-control {
    border: 1px solid rgba(17, 24, 39, .10);
    border-left: 0;
    padding-top: .8rem;
    padding-bottom: .8rem;
}

.login-card .form-control:focus {
    box-shadow: 0 0 0 .22rem rgba(245, 124, 0, .18);
    border-color: rgba(245, 124, 0, .45);
}

/* Boton (naranja) */
.btn-login {
    padding: .85rem 1rem;
    border-radius: .9rem;
    font-weight: 700;
    border: 0;
    background: linear-gradient(135deg, var(--brand-orange) 0%, var(--brand-orange-2) 100%);
    box-shadow: 0 10px 18px rgba(245, 124, 0, .22);
}

.btn-login:hover {
    filter: brightness(.98);
    box-shadow: 0 14px 22px rgba(245, 124, 0, .26);
}

/* Si tu boton usa btn-primary, lo "tinteamos" sin tocar HTML */
.login-form .btn.btn-primary {
    background: linear-gradient(135deg, var(--brand-orange) 0%, var(--brand-orange-2) 100%) !important;
    border-color: transparent !important;
}

.login-form .btn.btn-primary:focus {
    box-shadow: 0 0 0 .22rem rgba(245, 124, 0, .22) !important;
}

/* Ajustes para escritorio */
@media (min-width: 992px) {
    .login-shell {
        background:
            radial-gradient(1200px 520px at 10% 12%, rgba(245, 124, 0, .16), transparent 62%),
            radial-gradient(900px 460px at 92% 10%, rgba(0, 0, 0, .08), transparent 60%),
            linear-gradient(180deg, #F7F8FC 0%, #EEF1F7 100%);
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

                            <h2 class="fw-bold mb-2" style="letter-spacing:.2px;">Bienvenido</h2>
                            <p class="mb-0" style="opacity:.92;">
                                Organiza tu trabajo con una experiencia más rápida, clara y eficiente.
                            </p>

                            <div class="mt-4">
                                <small>¿No tienes una cuenta? Contacta al administrador.</small>
                            </div>
                        </div>

                        <!-- Formulario -->
                        <div class="col-lg-7 login-form p-4 p-lg-5">
                            <div class="mb-4">
                                <h1 class="h3 fw-bold mb-1">Iniciar sesión</h1>
                                <div class="text-muted">Ingresa tu usuario y contraseña</div>
                            </div>

                            <form action="" method="POST" class="needs-validation" novalidate>
                                <div class="mb-3">
                                    <label for="username" class="form-label">Username</label>
                                    <div class="input-group">
                                        <span class="input-group-text" aria-hidden="true">
                                            <i class="bx bx-user fs-5"></i>
                                        </span>
                                        <!-- NO CAMBIAR id / name -->
                                        <input type="text" class="form-control" id="username" name="username"
                                            placeholder="Username" required>
                                        <div class="invalid-feedback">Por favor ingresa tu nombre de usuario.</div>
                                    </div>
                                </div>

                                <div class="mb-4">
                                    <label for="password" class="form-label">Contraseña</label>
                                    <div class="input-group">
                                        <span class="input-group-text" aria-hidden="true">
                                            <i class="bx bx-lock-alt fs-5"></i>
                                        </span>
                                        <!-- NO CAMBIAR id / name -->
                                        <input type="password" class="form-control" id="password" name="password"
                                            placeholder="Contraseña" required>
                                        <button type="button" class="btn btn-outline-secondary" id="toggleLoginPassword"
                                            aria-label="Mostrar clave" title="Mostrar">
                                            <i class="bi bi-eye"></i>
                                        </button>
                                        <div class="invalid-feedback">Por favor ingresa tu contraseña.</div>
                                    </div>
                                </div>

                                <div class="text-end mb-3">
                                    <button type="button" class="btn btn-link p-0 text-decoration-none"
                                        data-bs-toggle="modal" data-bs-target="#modalRecuperarClave">
                                        ¿Olvidaste tu contraseña?
                                    </button>
                                </div>

                                <button class="btn btn-primary w-100 btn-login" type="submit">Entrar</button>

                                <div class="text-center text-muted mt-3" style="font-size:.9rem;">
                                    <small>© <?php echo date('Y'); ?> FerreNet System</small>
                                </div>
                            </form>
                        </div>

                    </div>
                </div>

            </div>
        </div>
    </div>
</div>

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

<script>
document.addEventListener('DOMContentLoaded', function() {
    const passwordInput = document.getElementById('password');
    const togglePasswordBtn = document.getElementById('toggleLoginPassword');
    const togglePasswordIcon = togglePasswordBtn ? togglePasswordBtn.querySelector('i') : null;
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

    if (!formRec || !btnRec || !modalEl) return;

    const fetchJsonSafe = async (url, options = {}) => {
        const res = await fetch(url, options);
        const text = await res.text();

        if (text.trim().startsWith('<')) {
            throw new Error('Respuesta inválida del servidor.');
        }

        try {
            return JSON.parse(text);
        } catch (e) {
            throw new Error('JSON inválido en recuperación de clave.');
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
                await alertMsg('error', 'Recuperación', data?.msg ||
                    'No se pudo procesar la recuperación.');
                return;
            }

            formRec.reset();
            await closeRecoveryModal();
            await alertMsg('success', 'Recuperación', data.msg ||
                'Solicitud procesada correctamente.');
        } catch (err) {
            await alertMsg('error', 'Recuperación', err?.message ||
                'Error inesperado en recuperación.');
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
if (isset($_POST['username']) && isset($_POST['password'])) {
  $insLogin->iniciarSesionControlador();
}
?>

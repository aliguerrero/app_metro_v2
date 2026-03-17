document.addEventListener('DOMContentLoaded', () => {
    const dir = (document.getElementById('url')?.value || window.APP_URL || '/').trim();
    const form = document.getElementById('formSmtpConfig');
    const msg = document.getElementById('msgSmtpConfig');

    const btnTestTop = document.getElementById('btnTestSmtp');
    const btnTest = document.getElementById('btnTestSmtpSecondary');
    const testTo = document.getElementById('smtp_test_to');

    const btnTogglePass = document.getElementById('smtpPassToggle');
    const inputPass = document.getElementById('smtp_password');
    const passNote = document.getElementById('smtpPassNote');
    const passIcon = btnTogglePass ? btnTogglePass.querySelector('i') : null;

    if (!dir || !form) return;

    const URL_AJAX = `${dir}app/ajax/smtpAjax.php`;

    const setMsg = (html, cls = 'text-muted') => {
        if (!msg) return;
        msg.className = `small ${cls}`;
        msg.innerHTML = html || '';
    };

    const toast = (icon, title) => {
        if (!window.Swal) return;
        Swal.fire({
            toast: true,
            position: 'bottom-end',
            timer: 2800,
            showConfirmButton: false,
            icon: icon || 'info',
            title: title || '',
        });
    };

    const confirmDialog = async ({ title, text, confirmText }) => {
        if (!window.Swal) return confirm(text || title || 'Confirmar?');
        const r = await Swal.fire({
            title: title || 'Confirmar?',
            text: text || 'Deseas continuar?',
            icon: 'question',
            showCancelButton: true,
            confirmButtonText: confirmText || 'Si',
            cancelButtonText: 'Cancelar',
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            allowOutsideClick: false,
            allowEscapeKey: true,
        });
        return r.isConfirmed;
    };

    async function fetchJSONSafe(url, options = {}) {
        const res = await fetch(url, options);
        const text = await res.text();

        if (text.trim().startsWith('<')) {
            console.error('Respuesta NO JSON (HTML):', text);
            throw new Error('Respuesta invalida (HTML). Revisa backend/ruta/permisos.');
        }

        try {
            return JSON.parse(text);
        } catch (e) {
            console.error('JSON invalido:', text);
            throw new Error('JSON invalido. Revisa el echo/print del backend.');
        }
    }

    function setDisabledTest(disabled) {
        if (btnTestTop) btnTestTop.disabled = !!disabled;
        if (btnTest) btnTest.disabled = !!disabled;
    }

    function setPassVisibility(visible) {
        if (!btnTogglePass || !inputPass) return;
        inputPass.type = visible ? 'text' : 'password';
        if (passIcon) {
            passIcon.className = visible ? 'bi bi-eye-slash' : 'bi bi-eye';
        }
        btnTogglePass.setAttribute('aria-label', visible ? 'Ocultar contraseña' : 'Mostrar contraseña');
        btnTogglePass.title = visible ? 'Ocultar' : 'Mostrar';
    }

    async function cargarConfig() {
        try {
            setMsg('Cargando...', 'text-muted');

            const data = await fetchJSONSafe(`${URL_AJAX}?modulo_smtp=obtener`, {
                method: 'GET',
                headers: { Accept: 'application/json' },
            });

            if (!data || data.ok !== true) {
                setMsg(data?.msg || 'No se pudo cargar la configuracion SMTP.', 'text-danger');
                return;
            }

            const d = data.data || {};

            const enabledEl = document.getElementById('smtp_enabled');
            const hostEl = document.getElementById('smtp_host');
            const portEl = document.getElementById('smtp_port');
            const encEl = document.getElementById('smtp_encryption');
            const userEl = document.getElementById('smtp_username');
            const fromEmailEl = document.getElementById('smtp_from_email');
            const fromNameEl = document.getElementById('smtp_from_name');

            if (enabledEl) enabledEl.checked = String(d.enabled ?? '0') === '1';
            if (hostEl) hostEl.value = d.host ?? 'smtp.gmail.com';
            if (portEl) portEl.value = d.port ?? 587;
            if (encEl) encEl.value = d.encryption ?? 'tls';
            if (userEl) userEl.value = d.username ?? '';
            if (fromEmailEl) fromEmailEl.value = d.from_email ?? '';
            if (fromNameEl) fromNameEl.value = d.from_name ?? '';

            if (inputPass) inputPass.value = '';
            setPassVisibility(false);

            const passSet = !!d.password_set;
            if (passNote) {
                passNote.textContent = passSet
                    ? 'Clave guardada. Deja en blanco para mantenerla.'
                    : 'Coloca tu App Password de Google (16 caracteres).';
            }

            setMsg('Configuracion cargada.', 'text-muted');
            setTimeout(() => setMsg('', 'text-muted'), 1600);
        } catch (err) {
            console.error(err);
            setMsg('Error cargando la configuracion SMTP.', 'text-danger');
            toast('error', 'No se pudo cargar SMTP');
        }
    }

    cargarConfig();

    if (btnTogglePass && inputPass) {
        btnTogglePass.addEventListener('click', () => {
            setPassVisibility(inputPass.type === 'password');
        });
    }

    form.addEventListener(
        'submit',
        async (e) => {
            e.preventDefault();
            e.stopPropagation();
            e.stopImmediatePropagation();

            const ok = await confirmDialog({
                title: 'Guardar configuracion SMTP?',
                text: 'Se aplicaran los cambios del envio por correo.',
                confirmText: 'Si, guardar',
            });
            if (!ok) return;

            try {
                setMsg('Guardando...', 'text-muted');

                const enabledEl = document.getElementById('smtp_enabled');
                const fd = new FormData(form);
                fd.set('enabled', enabledEl && enabledEl.checked ? '1' : '0');
                fd.append('modulo_smtp', 'guardar');

                const resp = await fetchJSONSafe(URL_AJAX, { method: 'POST', body: fd });
                if (!resp || resp.ok !== true) {
                    setMsg(resp?.msg || 'No se pudo guardar.', 'text-danger');
                    toast('error', resp?.msg || 'No se pudo guardar SMTP');
                    return;
                }

                toast('success', resp.msg || 'SMTP guardado');
                setMsg(resp.msg || 'Guardado.', 'text-success');
                await cargarConfig();
            } catch (err) {
                console.error(err);
                setMsg('Error guardando la configuracion SMTP.', 'text-danger');
                toast('error', 'Error guardando SMTP');
            }
        },
        true
    );

    form.addEventListener(
        'reset',
        async () => {
            setMsg('', 'text-muted');
            // recarga desde servidor para evitar reset a valores viejos del DOM
            setTimeout(cargarConfig, 0);
        },
        true
    );

    async function enviarPrueba() {
        const email = (testTo?.value || '').trim();
        if (!email) {
            toast('warning', 'Escribe el correo destino');
            return;
        }

        const ok = await confirmDialog({
            title: 'Enviar correo de prueba?',
            text: `Se enviara un correo a: ${email}`,
            confirmText: 'Si, enviar',
        });
        if (!ok) return;

        setDisabledTest(true);
        try {
            setMsg('Enviando prueba...', 'text-muted');

            const fd = new FormData();
            fd.append('modulo_smtp', 'probar');
            fd.append('to_email', email);

            const resp = await fetchJSONSafe(URL_AJAX, { method: 'POST', body: fd });
            if (!resp || resp.ok !== true) {
                setMsg(resp?.msg || 'No se pudo enviar la prueba.', 'text-danger');
                toast('error', resp?.msg || 'Fallo envio');
                return;
            }

            setMsg(resp.msg || 'Prueba enviada.', 'text-success');
            toast('success', resp.msg || 'Prueba enviada');
        } catch (err) {
            console.error(err);
            setMsg('Error enviando la prueba SMTP.', 'text-danger');
            toast('error', 'Error enviando prueba');
        } finally {
            setDisabledTest(false);
        }
    }

    if (btnTestTop) btnTestTop.addEventListener('click', enviarPrueba);
    if (btnTest) btnTest.addEventListener('click', enviarPrueba);
});

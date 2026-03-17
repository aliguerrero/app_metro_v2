document.addEventListener("DOMContentLoaded", () => {
    const dir = (document.getElementById("url")?.value || window.APP_URL || "/").trim();
    const form = document.getElementById("formEmpresaConfig");
    const msg = document.getElementById("msgEmpresaConfig");
    const logoImg = document.getElementById("logoImage");

    if (!form) return;

    // Ajusta esta ruta a tu backend real
    const URL_AJAX = `${dir}app/ajax/empresaAjax.php`;

    // =========================
    // Helpers UI
    // =========================
    const setMsg = (html, cls = "text-muted") => {
        if (!msg) return;
        msg.className = `ms-lg-auto small ${cls}`;
        msg.innerHTML = html || "";
    };

    const toast = (icon, title) => {
        if (!window.Swal) return;
        Swal.fire({
            toast: true,
            position: "bottom-end",
            timer: 2800,
            showConfirmButton: false,
            icon: icon || "info",
            title: title || "",
        });
    };

    const confirmDialog = async ({ title, text, confirmText }) => {
        if (!window.Swal) return confirm(text || title || "¿Confirmar?");
        const r = await Swal.fire({
            title: title || "¿Confirmar?",
            text: text || "¿Deseas continuar?",
            icon: "question",
            showCancelButton: true,
            confirmButtonText: confirmText || "Sí, guardar",
            cancelButtonText: "Cancelar",
            confirmButtonColor: "#3085d6",
            cancelButtonColor: "#d33",
            allowOutsideClick: false,
            allowEscapeKey: true,
        });
        return r.isConfirmed;
    };

    // Respuesta segura JSON (evita HTML inesperado)
    async function fetchJSONSafe(url, options = {}) {
        const res = await fetch(url, options);
        const text = await res.text();

        if (text.trim().startsWith("<")) {
            console.error("Respuesta NO JSON (HTML):", text);
            throw new Error("Respuesta inválida (HTML). Revisa backend/ruta/permisos.");
        }

        try {
            return JSON.parse(text);
        } catch (e) {
            console.error("JSON inválido:", text);
            throw new Error("JSON inválido. Revisa el echo/print del backend.");
        }
    }

    // Si tu backend devuelve el formato {tipo, titulo, texto, icono}
    function handleLegacyAlert(a) {
        if (!a || typeof a !== "object") return false;

        if (a.tipo) {
            // IMPORTANTE: NO recargamos la página; si el backend pide "recargar", hacemos refresh del bloque
            const icon = a.icono || "info";
            const title = a.titulo || "";
            const text = a.texto || "";

            if (window.Swal) {
                Swal.fire({
                    icon,
                    title,
                    text,
                    confirmButtonText: "Aceptar",
                });
            } else {
                alert(`${title}\n${text}`);
            }

            // Acciones clásicas, pero sin reload total
            if (a.tipo === "limpiar") form.reset();
            // si a.tipo === "recargar" => lo manejamos llamando cargarEmpresa()
            return true;
        }

        return false;
    }

    // =========================
    // Cargar datos (sin recargar página)
    // =========================
    async function cargarEmpresa() {
        try {
            setMsg("Cargando...", "text-muted");

            const data = await fetchJSONSafe(`${URL_AJAX}?modulo_empresa=obtener`, {
                method: "GET",
                headers: { Accept: "application/json" },
            });

            // Si viene formato legacy
            if (handleLegacyAlert(data)) {
                setMsg("", "text-muted");
                return;
            }

            if (!data || data.ok !== true || !data.data) {
                setMsg("No se pudo cargar la información.", "text-danger");
                console.warn("Respuesta obtener:", data);
                return;
            }

            const d = data.data;

            // Rellena campos (seguro)
            if (form.nombre) form.nombre.value = d.nombre ?? "";
            if (form.rif) form.rif.value = d.rif ?? "";
            if (form.direccion) form.direccion.value = d.direccion ?? "";
            if (form.telefono) form.telefono.value = d.telefono ?? "";
            if (form.email) form.email.value = d.email ?? "";

            // Actualiza logo si viene ruta
            if (logoImg && d.logo) {
                // Si d.logo viene como ruta relativa, armamos con dir
                const newSrc = (d.logo.startsWith("http") ? d.logo : `${dir}${d.logo}`).replace(/([^:]\/)\/+/g, "$1");
                // cache-bust opcional para ver el nuevo al actualizar
                logoImg.src = `${newSrc}?v=${Date.now()}`;
            }

            setMsg("Datos cargados.", "text-muted");
            setTimeout(() => setMsg("", "text-muted"), 1800);
        } catch (err) {
            console.error(err);
            setMsg("Error cargando datos de empresa.", "text-danger");
            toast("error", "No se pudo cargar la empresa");
        }
    }

    // Cargar al entrar (opcional, sirve si quieres refresco sin recargar)
    cargarEmpresa();

    // =========================
    // Preview del logo al seleccionar archivo (opcional)
    // =========================
    const inputLogo = form.querySelector('input[type="file"][name="logo_file"]');
    if (inputLogo && logoImg) {
        inputLogo.addEventListener("change", () => {
            const file = inputLogo.files && inputLogo.files[0];
            if (!file) return;
            const url = URL.createObjectURL(file);
            logoImg.src = url;
        });
    }

    // =========================
    // SUBMIT (UPDATE) con confirmación real
    // =========================
    form.addEventListener(
        "submit",
        async (e) => {
            // CRÍTICO: evita el submit normal y evita handlers globales
            e.preventDefault();
            e.stopPropagation();
            e.stopImmediatePropagation();

            const ok = await confirmDialog({
                title: "¿Guardar cambios?",
                text: "Se actualizarán los datos de la empresa.",
                confirmText: "Sí, guardar",
            });

            if (!ok) return;

            try {
                setMsg("Guardando...", "text-muted");

                const fd = new FormData(form);
                fd.append("modulo_empresa", "actualizar");

                const resp = await fetchJSONSafe(URL_AJAX, {
                    method: "POST",
                    body: fd,
                });

                // formato legacy
                if (handleLegacyAlert(resp)) {
                    // Si el backend “pide recargar”, en vez de reload hacemos refresh del bloque
                    await cargarEmpresa();
                    setMsg("Cambios aplicados.", "text-success");
                    setTimeout(() => setMsg("", "text-muted"), 2200);
                    return;
                }

                // formato moderno
                if (!resp || resp.ok !== true) {
                    setMsg(resp?.msg || "No se pudo guardar.", "text-danger");
                    toast("error", resp?.msg || "No se pudo guardar");
                    console.warn("Respuesta actualizar:", resp);
                    return;
                }

                toast("success", resp.msg || "Cambios guardados");
                setMsg(resp.msg || "Cambios guardados.", "text-success");

                // Refresca solo la sección (para actualizar ruta/logo y valores)
                await cargarEmpresa();
            } catch (err) {
                console.error(err);
                setMsg("Error guardando cambios.", "text-danger");
                toast("error", "Error guardando");
            }
        },
        true // captura: le ganamos a otros listeners
    );

    // =========================
    // RESET (opcional: confirmación antes de limpiar)
    // =========================
    form.addEventListener(
        "reset",
        async (e) => {
            // Si quieres confirmación antes de restablecer:
            // e.preventDefault(); e.stopImmediatePropagation();
            // const ok = await confirmDialog({ title:'¿Restablecer?', text:'Se perderán los cambios no guardados.', confirmText:'Sí, restablecer' });
            // if(!ok) return;
            // form.reset(); cargarEmpresa();
            setMsg("", "text-muted");
        },
        true
    );
});

document.addEventListener("DOMContentLoaded", () => {
    const dir = (document.getElementById("url")?.value || window.APP_URL || "/").trim();

    const form = document.getElementById("configUser");
    const msg = document.getElementById("msgUserConfig");

    if (!form) return;

    const URL_AJAX = `${dir}app/ajax/userAjax.php`;

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
            confirmButtonText: confirmText || "Sí, actualizar",
            cancelButtonText: "Cancelar",
            confirmButtonColor: "#3085d6",
            cancelButtonColor: "#d33",
            allowOutsideClick: false,
            allowEscapeKey: true,
        });
        return r.isConfirmed;
    };

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

    // Soporte al formato legacy: {tipo, titulo, texto, icono}
    function handleLegacyAlert(a) {
        if (!a || typeof a !== "object") return false;
        if (!a.tipo) return false;

        if (window.Swal) {
            Swal.fire({
                icon: a.icono || "info",
                title: a.titulo || "",
                text: a.texto || "",
                confirmButtonText: "Aceptar",
            });
        } else {
            alert(`${a.titulo || ""}\n${a.texto || ""}`);
        }

        if (a.tipo === "limpiar") form.reset();
        if (a.tipo === "cerrar") window.location.href = `${dir}login/`;
        // a.tipo === "recargar" -> NO recargamos página aquí (si lo necesitas, actualiza inputs manualmente)
        return true;
    }

    form.addEventListener(
        "submit",
        async (e) => {
            // CRÍTICO: evita que el submit se ejecute por otros handlers (FormularioAjax)
            e.preventDefault();
            e.stopPropagation();
            e.stopImmediatePropagation();

            const ok = await confirmDialog({
                title: "¿Actualizar cuenta?",
                text: "Se guardarán los cambios de tu cuenta.",
                confirmText: "Sí, actualizar",
            });
            if (!ok) return;

            try {
                setMsg("Actualizando...", "text-muted");

                const fd = new FormData(form);
                // Asegura que el backend entienda el módulo
                fd.set("modulo_user", "modificarUserSesion");

                const resp = await fetchJSONSafe(URL_AJAX, {
                    method: "POST",
                    body: fd,
                });

                // Legacy
                if (handleLegacyAlert(resp)) {
                    setMsg("Cambios aplicados.", "text-success");
                    setTimeout(() => setMsg("", "text-muted"), 2200);
                    return;
                }

                // Moderno esperado: {ok:true,msg:"..."} (si lo tienes)
                if (resp && resp.ok === true) {
                    toast("success", resp.msg || "Actualizado");
                    setMsg(resp.msg || "Cambios guardados.", "text-success");
                    setTimeout(() => setMsg("", "text-muted"), 2200);
                    return;
                }

                // Si viene algo distinto, igual lo mostramos
                toast("info", "Respuesta recibida");
                setMsg("Actualización procesada.", "text-muted");
                console.warn("Respuesta update user:", resp);
            } catch (err) {
                console.error(err);
                toast("error", "No se pudo actualizar");
                setMsg("Error actualizando la cuenta.", "text-danger");
            }
        },
        true // captura para ganarle a listeners globales
    );

    form.addEventListener(
        "reset",
        () => {
            setMsg("", "text-muted");
        },
        true
    );
});

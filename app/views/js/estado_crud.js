/* estadoCrudUI.js (COMPLETO - fix bug backdrop intermitente) */
document.addEventListener('DOMContentLoaded', () => {
    // Evita doble inicialización si el archivo se carga 2 veces
    if (window.__estadoCrudUI_inited) return;
    window.__estadoCrudUI_inited = true;

    const dir = (document.getElementById('url')?.value || '').trim();
    const listContainer = document.getElementById('estadoListContainer');
    const btnRecargar = document.getElementById('btnRecargarEstados');

    const formCreate = document.getElementById('formEstadoCreate');
    const formUpdate = document.getElementById('formEstadoUpdate');

    if (!dir || !listContainer || !formCreate) return;

    const URL_CRUD = dir + 'app/controllers/estadoCrud.php';
    const URL_LIST = dir + 'app/controllers/estadoList.php';

    const MODAL_ID = 'ventanaModalModificarEstado';

    // =========================
    // Helpers UI
    // =========================
    const toast = (icon, title) => {
        if (typeof Swal === 'undefined') return alert(title);
        Swal.fire({
            toast: true,
            position: "bottom-end",
            timer: 3000,
            showConfirmButton: false,
            icon,
            title
        });
    };

    const confirmDialog = async ({ title, text, confirmText }) => {
        if (typeof Swal === 'undefined') return confirm(text || title || "¿Confirmar?");
        const res = await Swal.fire({
            title: title || "¿Confirmar?",
            text: text || "¿Deseas continuar?",
            icon: "question",
            showCancelButton: true,
            confirmButtonColor: "#3085d6",
            cancelButtonColor: "#d33",
            confirmButtonText: confirmText || "Sí, continuar",
            cancelButtonText: "Cancelar",
            allowOutsideClick: false,
            allowEscapeKey: true
        });
        return res.isConfirmed;
    };

    // =========================
    // Modal helpers
    // =========================
    function getModalEl() {
        return document.getElementById(MODAL_ID);
    }

    function anyModalOpen() {
        return !!document.querySelector('.modal.show');
    }

    function cleanupModalUI() {
        // Solo limpia si NO hay ningún modal visible
        if (anyModalOpen()) return;

        document.body.classList.remove('modal-open');
        document.body.style.removeProperty('padding-right');
        document.body.style.removeProperty('overflow');

        document.querySelectorAll('.modal-backdrop').forEach(b => b.remove());
    }

    function ensureBackdropIfMissing(modalEl) {
        // Si el modal está abierto y NO hay backdrop, lo reponemos
        if (!modalEl || !modalEl.classList.contains('show')) return;

        const hasBackdrop = !!document.querySelector('.modal-backdrop.show');
        if (hasBackdrop) return;

        const bd = document.createElement('div');
        bd.className = 'modal-backdrop fade show';
        document.body.appendChild(bd);

        document.body.classList.add('modal-open');
        document.body.style.overflow = 'hidden';
    }

    function safeHideModal() {
        const modalEl = getModalEl();
        if (!modalEl || !window.bootstrap || !bootstrap.Modal) return;

        const inst = bootstrap.Modal.getInstance(modalEl) || bootstrap.Modal.getOrCreateInstance(modalEl);
        inst.hide();
    }

    // Eventos del modal: asegurar backdrop al mostrar; limpiar al cerrar
    document.addEventListener('shown.bs.modal', (e) => {
        if (e.target && e.target.id === MODAL_ID) {
            ensureBackdropIfMissing(e.target);
        }
    });

    document.addEventListener('hidden.bs.modal', (e) => {
        if (e.target && e.target.id === MODAL_ID) {
            cleanupModalUI();
        }
    });

    // =========================
    // Fetch helpers
    // =========================
    async function postCrud(formData) {
        const res = await fetch(URL_CRUD, { method: 'POST', body: formData });
        const text = await res.text();

        if (text.trim().startsWith('<')) {
            console.error("Respuesta no JSON:", text);
            return { ok: false, error: 'respuesta_no_json', raw: text, msg: 'Respuesta inválida del servidor' };
        }

        try {
            return JSON.parse(text);
        } catch (e) {
            console.error("JSON inválido:", text);
            return { ok: false, error: 'json_invalido', raw: text, msg: 'JSON inválido del servidor' };
        }
    }

    async function refreshEstadoList() {
        try {
            const res = await fetch(URL_LIST, { method: 'GET' });
            const html = await res.text();
            listContainer.innerHTML = html;
        } catch (e) {
            console.error(e);
            toast('error', 'No se pudo recargar la lista');
        }
    }

    // =========================================================
    // CREATE
    // =========================================================
    formCreate.addEventListener('submit', async (e) => {
        e.preventDefault();
        e.stopPropagation();
        e.stopImmediatePropagation();

        const nombreEl = document.getElementById('nombre_estado');
        const colorEl = document.getElementById('color');

        const nombre = (nombreEl?.value || '').trim();
        const color = (colorEl?.value || '#00FFCC');

        if (!nombre) {
            toast('warning', 'Escribe el nombre del estado');
            return;
        }

        const ok = await confirmDialog({
            title: "¿Crear estado?",
            text: "Se registrará un nuevo estado para las O.T.",
            confirmText: "Sí, crear"
        });

        if (!ok) return;

        const fd = new FormData();
        fd.append('action', 'create');
        fd.append('nombre_estado', nombre);
        fd.append('color', color);

        const r = await postCrud(fd);

        if (r.ok) {
            toast('success', r.msg || 'Estado creado');
            formCreate.reset();
            if (colorEl) colorEl.value = '#00FFCC';
            await refreshEstadoList();
        } else {
            toast('error', r.msg || 'No se pudo crear');
            console.error(r);
        }
    }, true);

    // =========================================================
    // UPDATE
    // =========================================================
    if (formUpdate) {
        formUpdate.addEventListener('submit', async (e) => {
            e.preventDefault();
            e.stopPropagation();
            e.stopImmediatePropagation();

            const idEl = document.getElementById('edit_id_estado');
            const nombreEl = document.getElementById('edit_nombre_estado');
            const colorEl = document.getElementById('edit_color');

            const id = (idEl?.value || '').trim();
            const nombre = (nombreEl?.value || '').trim();
            const color = (colorEl?.value || '#00FFCC');

            if (!id || !nombre) {
                toast('warning', 'Completa los datos');
                return;
            }

            const ok = await confirmDialog({
                title: "¿Guardar cambios?",
                text: "Se actualizará el estado con la nueva información.",
                confirmText: "Sí, guardar"
            });

            if (!ok) return;

            const fd = new FormData();
            fd.append('action', 'update');
            fd.append('id_ai_estado', id);
            fd.append('nombre_estado', nombre);
            fd.append('color', color);

            const r = await postCrud(fd);

            if (r.ok) {
                toast('success', r.msg || 'Estado actualizado');

                // ✅ Cierra con Bootstrap y NO borres backdrop con timeout
                safeHideModal();

                // ✅ Recarga la lista; la limpieza final ocurre en hidden.bs.modal
                await refreshEstadoList();
            } else {
                toast('error', r.msg || 'No se pudo actualizar');
                console.error(r);
            }
        }, true);
    }

    // =========================================================
    // Delegación: EDIT/DELETE
    // =========================================================
    listContainer.addEventListener('click', async (e) => {
        const btnDel = e.target.closest('.js-estado-del');
        const btnEdit = e.target.closest('.js-estado-edit');

        // DELETE
        if (btnDel) {
            e.preventDefault();

            const id = btnDel.getAttribute('data-id');
            if (!id) return;

            const ok = await confirmDialog({
                title: "¿Eliminar estado?",
                text: "Esta acción eliminará el estado. No se puede deshacer.",
                confirmText: "Sí, eliminar"
            });

            if (!ok) return;

            const fd = new FormData();
            fd.append('action', 'delete');
            fd.append('id_ai_estado', id);

            const r = await postCrud(fd);

            if (r.ok) {
                toast('success', r.msg || 'Estado eliminado');
                await refreshEstadoList();
            } else {
                toast('error', r.msg || 'No se pudo eliminar');
                console.error(r);
            }
            return;
        }

        // EDIT
        if (btnEdit) {
            e.preventDefault();

            const id = btnEdit.getAttribute('data-id');
            if (!id) return;

            const fd = new FormData();
            fd.append('action', 'get');
            fd.append('id_ai_estado', id);

            const r = await postCrud(fd);

            if (r.ok && r.data) {
                const idEl = document.getElementById('edit_id_estado');
                const nombreEl = document.getElementById('edit_nombre_estado');
                const colorEl = document.getElementById('edit_color');

                if (idEl) idEl.value = r.data.id_ai_estado;
                if (nombreEl) nombreEl.value = r.data.nombre_estado;
                if (colorEl) colorEl.value = r.data.color || '#00FFCC';

                const modalEl = getModalEl();
                if (!modalEl) {
                    toast('error', 'No encuentro el modal en el DOM.');
                    return;
                }
                if (!window.bootstrap || !bootstrap.Modal) {
                    toast('error', 'Bootstrap no está disponible (bootstrap.Modal).');
                    return;
                }

                const inst = bootstrap.Modal.getOrCreateInstance(modalEl, {
                    backdrop: true,
                    keyboard: true,
                    focus: true
                });

                inst.show();

                // ✅ si por alguna razón no aparece, lo reponemos
                setTimeout(() => ensureBackdropIfMissing(modalEl), 50);
            } else {
                toast('error', r.msg || 'No se pudo cargar el estado');
                console.error(r);
                cleanupModalUI();
            }
        }
    });

    // =========================================================
    // Recargar manual
    // =========================================================
    if (btnRecargar) {
        btnRecargar.addEventListener('click', async (e) => {
            e.preventDefault();
            toast('success', 'Lista recargada');
            await refreshEstadoList();
        });
    }
});
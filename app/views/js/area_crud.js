document.addEventListener('DOMContentLoaded', () => {
    const dir = (document.getElementById('url')?.value || '').trim();
    const listContainer = document.getElementById('areaListContainer');
    const btnRecargar = document.getElementById('btnRecargarAreas');

    const formCreate = document.getElementById('formAreaCreate');
    const formUpdate = document.getElementById('formAreaUpdate');

    if (!dir || !listContainer || !formCreate) return;

    const URL_CRUD = dir + 'app/controllers/areaCrud.php';
    const URL_LIST = dir + 'app/controllers/areaList.php';

    const modalEl = document.getElementById('ventanaModalModificarArea');

    // =========================
    // Helpers UI
    // =========================
    const toast = (icon, title) => {
        if (typeof Swal === 'undefined') return alert(title);
        Swal.fire({ toast: true, position: "bottom-end", timer: 3000, showConfirmButton: false, icon, title });
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
    // Fetch helpers
    // =========================
    async function postCrud(formData) {
        const res = await fetch(URL_CRUD, { method: 'POST', body: formData });
        const text = await res.text();

        if (text.trim().startsWith('<')) {
            console.error("Respuesta no JSON:", text);
            return { ok: false, error: 'respuesta_no_json', raw: text };
        }

        try {
            return JSON.parse(text);
        } catch (e) {
            console.error("JSON inválido:", text);
            return { ok: false, error: 'json_invalido', raw: text };
        }
    }

    async function refreshAreaList() {
        try {
            const res = await fetch(URL_LIST, { method: 'GET' });
            const html = await res.text();
            listContainer.innerHTML = html;
        } catch (e) {
            console.error(e);
            toast('error', 'No se pudo recargar la lista');
        }
    }

    // =========================
    // Modal/backdrop fix
    // =========================
    function hardResetModalUI() {
        document.body.classList.remove('modal-open');
        document.body.style.removeProperty('padding-right');
        document.body.style.removeProperty('overflow');
        document.querySelectorAll('.modal-backdrop').forEach(b => b.remove());

        if (modalEl) {
            modalEl.classList.remove('show');
            modalEl.style.display = 'none';
            modalEl.removeAttribute('aria-modal');
            modalEl.setAttribute('aria-hidden', 'true');
        }
    }

    function safeHideModal() {
        if (!modalEl || !window.bootstrap) return;
        const inst = bootstrap.Modal.getInstance(modalEl) || bootstrap.Modal.getOrCreateInstance(modalEl);
        inst.hide();
    }

    if (modalEl) {
        modalEl.addEventListener('hidden.bs.modal', () => hardResetModalUI());
    }

    // =========================
    // CREATE (confirmación REAL)
    // =========================
    formCreate.addEventListener('submit', async (e) => {
        e.preventDefault();
        e.stopPropagation();
        e.stopImmediatePropagation();

        const nombre = (document.getElementById('nombre_area')?.value || '').trim();
        const nome = (document.getElementById('nome')?.value || '').trim();

        if (!nombre) {
            toast('warning', 'Escribe el nombre del área');
            return;
        }

        const ok = await confirmDialog({
            title: "¿Crear área?",
            text: "Se registrará una nueva área de trabajo.",
            confirmText: "Sí, crear"
        });
        if (!ok) return;

        const fd = new FormData();
        fd.append('action', 'create');
        fd.append('nombre_area', nombre);
        fd.append('nome', nome);

        const r = await postCrud(fd);

        if (r.ok) {
            toast('success', r.msg || 'Área creada');
            formCreate.reset();
            await refreshAreaList();
        } else {
            toast('error', r.msg || 'No se pudo crear');
            console.error(r);
        }
    }, true);

    // =========================
    // UPDATE (confirmación REAL)
    // =========================
    if (formUpdate) {
        formUpdate.addEventListener('submit', async (e) => {
            e.preventDefault();
            e.stopPropagation();
            e.stopImmediatePropagation();

            const id = (document.getElementById('edit_id_area')?.value || '').trim();
            const nombre = (document.getElementById('edit_nombre_area')?.value || '').trim();
            const nome = (document.getElementById('edit_nome')?.value || '').trim();

            if (!id || !nombre) {
                toast('warning', 'Completa los datos');
                return;
            }

            const ok = await confirmDialog({
                title: "¿Guardar cambios?",
                text: "Se actualizará el área con la nueva información.",
                confirmText: "Sí, guardar"
            });
            if (!ok) return;

            const fd = new FormData();
            fd.append('action', 'update');
            fd.append('id_ai_area', id);
            fd.append('nombre_area', nombre);
            fd.append('nome', nome);

            const r = await postCrud(fd);

            if (r.ok) {
                toast('success', r.msg || 'Área actualizada');
                safeHideModal();
                setTimeout(() => hardResetModalUI(), 300);
                await refreshAreaList();
            } else {
                toast('error', r.msg || 'No se pudo actualizar');
                console.error(r);
            }
        }, true);
    }

    // =========================
    // Delegación: EDIT / DELETE
    // =========================
    listContainer.addEventListener('click', async (e) => {
        const btnEdit = e.target.closest('.js-area-edit');
        const btnDel = e.target.closest('.js-area-del');

        // DELETE
        if (btnDel) {
            e.preventDefault();
            const id = btnDel.getAttribute('data-id');
            if (!id) return;

            const ok = await confirmDialog({
                title: "¿Eliminar área?",
                text: "Esta acción eliminará el área. No se puede deshacer.",
                confirmText: "Sí, eliminar"
            });
            if (!ok) return;

            const fd = new FormData();
            fd.append('action', 'delete');
            fd.append('id_ai_area', id);

            const r = await postCrud(fd);

            if (r.ok) {
                toast('success', r.msg || 'Área eliminada');
                await refreshAreaList();
            } else {
                toast('error', r.msg || 'No se pudo eliminar');
                console.error(r);
            }
            return;
        }

        // EDIT (cargar datos y abrir modal)
        if (btnEdit) {
            e.preventDefault();
            const id = btnEdit.getAttribute('data-id');
            if (!id) return;

            const fd = new FormData();
            fd.append('action', 'get');
            fd.append('id_ai_area', id);

            const r = await postCrud(fd);

            if (r.ok && r.data) {
                const idEl = document.getElementById('edit_id_area');
                const nombreEl = document.getElementById('edit_nombre_area');
                const nomeEl = document.getElementById('edit_nome');

                if (idEl) idEl.value = r.data.id_ai_area;
                if (nombreEl) nombreEl.value = r.data.nombre_area || '';
                if (nomeEl) nomeEl.value = r.data.nomeclatura || '';

                if (modalEl && window.bootstrap) {
                    const inst = bootstrap.Modal.getOrCreateInstance(modalEl, { backdrop: true, keyboard: true });
                    inst.show();
                }
            } else {
                toast('error', r.msg || 'No se pudo cargar el área');
                console.error(r);
            }
        }
    });

    // =========================
    // Recargar manual
    // =========================
    if (btnRecargar) {
        btnRecargar.addEventListener('click', async (e) => {
            e.preventDefault();
            toast('success', 'Lista recargada');
            await refreshAreaList();
        });
    }
});

document.addEventListener('DOMContentLoaded', () => {
    const dir = (document.getElementById('url')?.value || '').trim();
    if (!dir) return;

    const API = dir + 'app/controllers/turnoCrud.php';

    const turnoListWrap = document.getElementById('turnoListWrap');
    const totalTop = document.getElementById('turnoTotalTop');
    const btnRecargar = document.getElementById('btnRecargarTurno');

    const formCreate = document.getElementById('formTurnoCrear');
    const inputCreate = document.getElementById('turno');

    const modalEl = document.getElementById('ventanaModalModificarTurno');
    const formEdit = document.getElementById('formTurnoEditar');
    const editId = document.getElementById('edit_id_turno');
    const editNombre = document.getElementById('edit_nombre_turno');

    if (!turnoListWrap || !formCreate || !inputCreate) return;

    async function fetchJSON(url, options = {}) {
        const res = await fetch(url, options);
        const text = await res.text();

        if (text.trim().startsWith('<')) {
            console.error('Respuesta NO JSON:', text);
            throw new Error('Respuesta inválida (HTML). Revisa errores PHP/back-end.');
        }

        try {
            return JSON.parse(text);
        } catch (e) {
            console.error('JSON inválido:', text);
            throw new Error('JSON inválido');
        }
    }

    const toast = (icon, title) => {
        if (!window.Swal) return;
        Swal.fire({ toast: true, position: "bottom-end", timer: 2800, showConfirmButton: false, icon, title });
    };

    async function confirmDialog({ title, text, confirmText }) {
        if (!window.Swal) return confirm(text || title || '¿Confirmar?');
        const r = await Swal.fire({
            title: title || '¿Confirmar?',
            text: text || '¿Deseas continuar?',
            icon: 'question',
            showCancelButton: true,
            confirmButtonText: confirmText || 'Sí',
            cancelButtonText: 'Cancelar',
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            allowOutsideClick: false,
            allowEscapeKey: true,
        });
        return r.isConfirmed;
    }

    function safeShowModal() {
        if (!modalEl || !window.bootstrap) return;
        const inst = bootstrap.Modal.getOrCreateInstance(modalEl, { backdrop: true, keyboard: true });
        inst.show();
    }

    function safeHideModal() {
        if (!modalEl || !window.bootstrap) return;
        const inst = bootstrap.Modal.getInstance(modalEl) || bootstrap.Modal.getOrCreateInstance(modalEl);
        inst.hide();
    }

    function hardCleanModalBackdrop() {
        document.body.classList.remove('modal-open');
        document.body.style.removeProperty('padding-right');
        document.body.style.removeProperty('overflow');
        document.querySelectorAll('.modal-backdrop').forEach(b => b.remove());
    }

    if (modalEl) {
        modalEl.addEventListener('hidden.bs.modal', () => {
            hardCleanModalBackdrop();
            if (editId) editId.value = '';
            if (editNombre) editNombre.value = '';
        });
    }

    async function cargarLista() {
        const data = await fetchJSON(API + '?action=list', { method: 'GET' });
        if (data.ok && typeof data.html === 'string') {
            turnoListWrap.innerHTML = data.html;
            if (totalTop) totalTop.textContent = `Total: ${data.total ?? ''}`;
        } else {
            toast('error', data.msg || 'No se pudo recargar la lista');
        }
    }

    // CREATE (captura + confirmación REAL)
    formCreate.addEventListener('submit', async (e) => {
        e.preventDefault();
        e.stopPropagation();
        e.stopImmediatePropagation();

        const nombre = (inputCreate.value || '').trim();
        if (!nombre) {
            toast('warning', 'Escribe el nombre del turno');
            return;
        }

        const ok = await confirmDialog({
            title: '¿Crear turno?',
            text: 'Se registrará un nuevo turno.',
            confirmText: 'Sí, crear'
        });
        if (!ok) return;

        const fd = new FormData();
        fd.append('action', 'create');
        fd.append('nombre', nombre);

        const resp = await fetchJSON(API, { method: 'POST', body: fd });
        if (!resp.ok) {
            toast('error', resp.msg || 'No se pudo crear');
            return;
        }

        inputCreate.value = '';
        await cargarLista();
        toast('success', resp.msg || 'Turno creado');
    }, true);

    // Delegación: Edit + Delete
    turnoListWrap.addEventListener('click', async (e) => {
        const btnEdit = e.target.closest('[data-action="edit"]');
        const btnDel = e.target.closest('[data-action="delete"]');

        // EDIT open
        if (btnEdit) {
            e.preventDefault();
            const id = btnEdit.getAttribute('data-id');
            if (!id) return;

            const fd = new FormData();
            fd.append('action', 'get');
            fd.append('id', id);

            const data = await fetchJSON(API, { method: 'POST', body: fd });
            if (!data.ok || !data.data) {
                toast('error', data.msg || 'No se pudo cargar');
                return;
            }

            if (editId) editId.value = data.data.id_ai_turno;
            if (editNombre) editNombre.value = data.data.nombre_turno || '';

            safeShowModal();
            return;
        }

        // DELETE
        if (btnDel) {
            e.preventDefault();
            const id = btnDel.getAttribute('data-id');
            if (!id) return;

            const ok = await confirmDialog({
                title: '¿Eliminar turno?',
                text: 'Esta acción no se puede deshacer.',
                confirmText: 'Sí, eliminar'
            });
            if (!ok) return;

            const fd = new FormData();
            fd.append('action', 'delete');
            fd.append('id', id);

            const resp = await fetchJSON(API, { method: 'POST', body: fd });
            if (!resp.ok) {
                toast('error', resp.msg || 'No se pudo eliminar');
                return;
            }

            await cargarLista();
            toast('success', resp.msg || 'Turno eliminado');
            return;
        }
    });

    // UPDATE (captura + confirmación REAL)
    if (formEdit) {
        formEdit.addEventListener('submit', async (e) => {
            e.preventDefault();
            e.stopPropagation();
            e.stopImmediatePropagation();

            const id = (editId?.value || '').trim();
            const nombre = (editNombre?.value || '').trim();

            if (!id || !nombre) {
                toast('warning', 'Completa los datos');
                return;
            }

            const ok = await confirmDialog({
                title: '¿Guardar cambios?',
                text: 'Se actualizará el turno con la nueva información.',
                confirmText: 'Sí, guardar'
            });
            if (!ok) return;

            const fd = new FormData();
            fd.append('action', 'update');
            fd.append('id', id);
            fd.append('nombre', nombre);

            const resp = await fetchJSON(API, { method: 'POST', body: fd });
            if (!resp.ok) {
                toast('error', resp.msg || 'No se pudo actualizar');
                return;
            }

            await cargarLista();
            safeHideModal();
            setTimeout(hardCleanModalBackdrop, 250);
            toast('success', resp.msg || 'Turno actualizado');
        }, true);
    }

    // Recargar
    if (btnRecargar) {
        btnRecargar.addEventListener('click', async (e) => {
            e.preventDefault();
            await cargarLista();
            toast('success', 'Lista recargada');
        });
    }

    // Opcional: refresco inicial si quieres forzar HTML render desde controller
    // cargarLista();
});

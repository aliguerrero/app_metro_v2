document.addEventListener('DOMContentLoaded', () => {
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

    const toast = (icon, title) => {
        if (typeof Swal === 'undefined') {
            alert(title);
            return;
        }

        Swal.fire({
            toast: true,
            position: 'bottom-end',
            timer: 3000,
            showConfirmButton: false,
            icon,
            title
        });
    };

    const confirmDialog = async ({ title, text, confirmText }) => {
        if (typeof Swal === 'undefined') return confirm(text || title || 'Confirmar');
        const res = await Swal.fire({
            title: title || 'Confirmar',
            text: text || 'Deseas continuar?',
            icon: 'question',
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: confirmText || 'Si, continuar',
            cancelButtonText: 'Cancelar',
            allowOutsideClick: false,
            allowEscapeKey: true
        });
        return res.isConfirmed;
    };

    function getModalEl() {
        return document.getElementById(MODAL_ID);
    }

    function anyModalOpen() {
        return !!document.querySelector('.modal.show');
    }

    function cleanupModalUI() {
        if (anyModalOpen()) return;
        document.body.classList.remove('modal-open');
        document.body.style.removeProperty('padding-right');
        document.body.style.removeProperty('overflow');
        document.querySelectorAll('.modal-backdrop').forEach((backdrop) => backdrop.remove());
    }

    function ensureBackdropIfMissing(modalEl) {
        if (!modalEl || !modalEl.classList.contains('show')) return;
        const hasBackdrop = !!document.querySelector('.modal-backdrop.show');
        if (hasBackdrop) return;

        const backdrop = document.createElement('div');
        backdrop.className = 'modal-backdrop fade show';
        document.body.appendChild(backdrop);
        document.body.classList.add('modal-open');
        document.body.style.overflow = 'hidden';
    }

    function safeHideModal() {
        const modalEl = getModalEl();
        if (!modalEl || !window.bootstrap || !bootstrap.Modal) return;
        const instance = bootstrap.Modal.getInstance(modalEl) || bootstrap.Modal.getOrCreateInstance(modalEl);
        instance.hide();
    }

    function checkboxValue(id) {
        return document.getElementById(id)?.checked ? '1' : '0';
    }

    function wireEstadoFlags(liberaId, bloqueaId) {
        const liberaEl = document.getElementById(liberaId);
        const bloqueaEl = document.getElementById(bloqueaId);
        if (!liberaEl || !bloqueaEl) return;

        bloqueaEl.addEventListener('change', () => {
            if (bloqueaEl.checked) {
                liberaEl.checked = true;
            }
        });

        liberaEl.addEventListener('change', () => {
            if (!liberaEl.checked && bloqueaEl.checked) {
                bloqueaEl.checked = false;
            }
        });
    }

    async function postCrud(formData) {
        const res = await fetch(URL_CRUD, { method: 'POST', body: formData });
        const text = await res.text();

        if (text.trim().startsWith('<')) {
            console.error('Respuesta no JSON:', text);
            return { ok: false, error: 'respuesta_no_json', raw: text, msg: 'Respuesta invalida del servidor' };
        }

        try {
            return JSON.parse(text);
        } catch (error) {
            console.error('JSON invalido:', text);
            return { ok: false, error: 'json_invalido', raw: text, msg: 'JSON invalido del servidor' };
        }
    }

    async function refreshEstadoList() {
        try {
            const res = await fetch(URL_LIST, { method: 'GET' });
            const html = await res.text();
            listContainer.innerHTML = html;
        } catch (error) {
            console.error(error);
            toast('error', 'No se pudo recargar la lista');
        }
    }

    document.addEventListener('shown.bs.modal', (event) => {
        if (event.target && event.target.id === MODAL_ID) {
            ensureBackdropIfMissing(event.target);
        }
    });

    document.addEventListener('hidden.bs.modal', (event) => {
        if (event.target && event.target.id === MODAL_ID) {
            cleanupModalUI();
        }
    });

    wireEstadoFlags('libera_herramientas', 'bloquea_ot');
    wireEstadoFlags('edit_libera_herramientas', 'edit_bloquea_ot');

    formCreate.addEventListener('submit', async (event) => {
        event.preventDefault();
        event.stopPropagation();
        event.stopImmediatePropagation();

        const nombreEl = document.getElementById('nombre_estado');
        const colorEl = document.getElementById('color');
        const nombre = (nombreEl?.value || '').trim();
        const color = colorEl?.value || '#00FFCC';
        const bloqueaOt = checkboxValue('bloquea_ot');
        const liberaHerramientas = bloqueaOt === '1' ? '1' : checkboxValue('libera_herramientas');

        if (!nombre) {
            toast('warning', 'Escribe el nombre del estado');
            return;
        }

        const ok = await confirmDialog({
            title: 'Crear estado?',
            text: bloqueaOt === '1'
                ? 'Se registrara un estado que bloquea la O.T. y tambien liberara herramientas al aplicarse.'
                : liberaHerramientas === '1'
                ? 'Se registrara un estado que liberara herramientas sin bloquear la O.T.'
                : 'Se registrara un nuevo estado para las O.T.',
            confirmText: 'Si, crear'
        });

        if (!ok) return;

        const fd = new FormData();
        fd.append('action', 'create');
        fd.append('nombre_estado', nombre);
        fd.append('color', color);
        fd.append('libera_herramientas', liberaHerramientas);
        fd.append('bloquea_ot', bloqueaOt);

        const response = await postCrud(fd);
        if (response.ok) {
            toast('success', response.msg || 'Estado creado');
            formCreate.reset();
            if (colorEl) colorEl.value = '#00FFCC';
            await refreshEstadoList();
            return;
        }

        toast('error', response.msg || 'No se pudo crear');
        console.error(response);
    }, true);

    if (formUpdate) {
        formUpdate.addEventListener('submit', async (event) => {
            event.preventDefault();
            event.stopPropagation();
            event.stopImmediatePropagation();

            const id = (document.getElementById('edit_id_estado')?.value || '').trim();
            const nombre = (document.getElementById('edit_nombre_estado')?.value || '').trim();
            const color = document.getElementById('edit_color')?.value || '#00FFCC';
            const bloqueaOt = checkboxValue('edit_bloquea_ot');
            const liberaHerramientas = bloqueaOt === '1' ? '1' : checkboxValue('edit_libera_herramientas');

            if (!id || !nombre) {
                toast('warning', 'Completa los datos');
                return;
            }

            const ok = await confirmDialog({
                title: 'Guardar cambios?',
                text: bloqueaOt === '1'
                    ? 'El estado quedara configurado para bloquear la O.T. y liberar herramientas al aplicarse.'
                    : liberaHerramientas === '1'
                    ? 'El estado quedara configurado para liberar herramientas sin bloquear la O.T.'
                    : 'Se actualizara el estado con la nueva informacion.',
                confirmText: 'Si, guardar'
            });

            if (!ok) return;

            const fd = new FormData();
            fd.append('action', 'update');
            fd.append('id_ai_estado', id);
            fd.append('nombre_estado', nombre);
            fd.append('color', color);
            fd.append('libera_herramientas', liberaHerramientas);
            fd.append('bloquea_ot', bloqueaOt);

            const response = await postCrud(fd);
            if (response.ok) {
                toast('success', response.msg || 'Estado actualizado');
                safeHideModal();
                await refreshEstadoList();
                return;
            }

            toast('error', response.msg || 'No se pudo actualizar');
            console.error(response);
        }, true);
    }

    listContainer.addEventListener('click', async (event) => {
        const btnDelete = event.target.closest('.js-estado-del');
        const btnEdit = event.target.closest('.js-estado-edit');

        if (btnDelete) {
            event.preventDefault();
            const id = btnDelete.getAttribute('data-id');
            if (!id) return;

            const ok = await confirmDialog({
                title: 'Eliminar estado?',
                text: 'Esta accion eliminara el estado de forma logica. No se puede deshacer.',
                confirmText: 'Si, eliminar'
            });

            if (!ok) return;

            const fd = new FormData();
            fd.append('action', 'delete');
            fd.append('id_ai_estado', id);

            const response = await postCrud(fd);
            if (response.ok) {
                toast('success', response.msg || 'Estado eliminado');
                await refreshEstadoList();
                return;
            }

            toast('error', response.msg || 'No se pudo eliminar');
            console.error(response);
            return;
        }

        if (btnEdit) {
            event.preventDefault();
            const id = btnEdit.getAttribute('data-id');
            if (!id) return;

            const fd = new FormData();
            fd.append('action', 'get');
            fd.append('id_ai_estado', id);

            const response = await postCrud(fd);
            if (response.ok && response.data) {
                if (response.data.protegido) {
                    toast('info', 'Este estado bloquea la O.T. y esta protegido.');
                    return;
                }

                const idEl = document.getElementById('edit_id_estado');
                const nombreEl = document.getElementById('edit_nombre_estado');
                const colorEl = document.getElementById('edit_color');
                const liberaEl = document.getElementById('edit_libera_herramientas');
                const bloqueaEl = document.getElementById('edit_bloquea_ot');

                if (idEl) idEl.value = response.data.id_ai_estado;
                if (nombreEl) nombreEl.value = response.data.nombre_estado;
                if (colorEl) colorEl.value = response.data.color || '#00FFCC';
                if (liberaEl) liberaEl.checked = Number(response.data.libera_herramientas || 0) === 1;
                if (bloqueaEl) bloqueaEl.checked = Number(response.data.bloquea_ot || 0) === 1;

                const modalEl = getModalEl();
                if (!modalEl) {
                    toast('error', 'No encuentro el modal en el DOM.');
                    return;
                }
                if (!window.bootstrap || !bootstrap.Modal) {
                    toast('error', 'Bootstrap no esta disponible.');
                    return;
                }

                const instance = bootstrap.Modal.getOrCreateInstance(modalEl, {
                    backdrop: true,
                    keyboard: true,
                    focus: true
                });

                instance.show();
                setTimeout(() => ensureBackdropIfMissing(modalEl), 50);
                return;
            }

            toast('error', response.msg || 'No se pudo cargar el estado');
            console.error(response);
            cleanupModalUI();
        }
    });

    if (btnRecargar) {
        btnRecargar.addEventListener('click', async (event) => {
            event.preventDefault();
            toast('success', 'Lista recargada');
            await refreshEstadoList();
        });
    }
});

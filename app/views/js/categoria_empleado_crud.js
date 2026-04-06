document.addEventListener('DOMContentLoaded', () => {
    const dir = (document.getElementById('url')?.value || '').trim();
    const listContainer = document.getElementById('categoriaEmpleadoListContainer');
    const btnRecargar = document.getElementById('btnRecargarCategoriaEmpleado');
    const formCreate = document.getElementById('formCategoriaEmpleadoCreate');
    const formUpdate = document.getElementById('formCategoriaEmpleadoUpdate');
    const modalEl = document.getElementById('ventanaModalModificarCategoriaEmpleado');

    if (!dir || !listContainer || !formCreate) return;

    const URL_CRUD = dir + 'app/controllers/categoriaEmpleadoCrud.php';
    const URL_LIST = dir + 'app/controllers/categoriaEmpleadoList.php';

    const toast = (icon, title) => {
        if (!window.Swal) return;
        Swal.fire({ toast: true, position: 'bottom-end', timer: 2800, showConfirmButton: false, icon, title });
    };

    const confirmDialog = async ({ title, text, confirmText }) => {
        if (!window.Swal) return confirm(text || title || 'Confirmar');
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
            allowEscapeKey: true,
        });
        return res.isConfirmed;
    };

    async function postCrud(formData) {
        const res = await fetch(URL_CRUD, { method: 'POST', body: formData });
        const text = await res.text();
        if (text.trim().startsWith('<')) {
            return { ok: false, msg: 'Respuesta invalida del servidor.' };
        }
        try {
            return JSON.parse(text);
        } catch (error) {
            console.error(error, text);
            return { ok: false, msg: 'No se pudo procesar la respuesta.' };
        }
    }

    async function refreshList() {
        const res = await fetch(URL_LIST, { method: 'GET' });
        listContainer.innerHTML = await res.text();
    }

    function hardResetModal() {
        document.body.classList.remove('modal-open');
        document.body.style.removeProperty('padding-right');
        document.body.style.removeProperty('overflow');
        document.querySelectorAll('.modal-backdrop').forEach((backdrop) => backdrop.remove());
    }

    if (modalEl) {
        modalEl.addEventListener('hidden.bs.modal', () => hardResetModal());
    }

    formCreate.addEventListener('submit', async (event) => {
        event.preventDefault();
        event.stopPropagation();
        event.stopImmediatePropagation();

        const nombre = (document.getElementById('nombre_categoria')?.value || '').trim();
        if (!nombre) {
            toast('warning', 'Escribe el nombre de la categoria');
            return;
        }

        const ok = await confirmDialog({
            title: 'Crear categoria?',
            text: 'Se registrara una nueva categoria de empleado.',
            confirmText: 'Si, crear',
        });
        if (!ok) return;

        const fd = new FormData(formCreate);
        fd.append('action', 'create');

        const resp = await postCrud(fd);
        if (resp.ok) {
            toast('success', resp.msg || 'Categoria creada');
            formCreate.reset();
            await refreshList();
            return;
        }

        toast('error', resp.msg || 'No se pudo crear la categoria');
    }, true);

    if (formUpdate) {
        formUpdate.addEventListener('submit', async (event) => {
            event.preventDefault();
            event.stopPropagation();
            event.stopImmediatePropagation();

            const ok = await confirmDialog({
                title: 'Guardar cambios?',
                text: 'Se actualizara la categoria seleccionada.',
                confirmText: 'Si, guardar',
            });
            if (!ok) return;

            const fd = new FormData(formUpdate);
            fd.append('action', 'update');

            const resp = await postCrud(fd);
            if (resp.ok) {
                toast('success', resp.msg || 'Categoria actualizada');
                if (modalEl && window.bootstrap) {
                    bootstrap.Modal.getOrCreateInstance(modalEl).hide();
                }
                await refreshList();
                return;
            }

            toast('error', resp.msg || 'No se pudo actualizar la categoria');
        }, true);
    }

    listContainer.addEventListener('click', async (event) => {
        const btnEdit = event.target.closest('.js-catemp-edit');
        const btnDel = event.target.closest('.js-catemp-del');

        if (btnDel) {
            event.preventDefault();

            const ok = await confirmDialog({
                title: 'Eliminar categoria?',
                text: 'La categoria se desactivara si no tiene empleados activos asociados.',
                confirmText: 'Si, eliminar',
            });
            if (!ok) return;

            const fd = new FormData();
            fd.append('action', 'delete');
            fd.append('id_ai_categoria_empleado', btnDel.getAttribute('data-id') || '');

            const resp = await postCrud(fd);
            if (resp.ok) {
                toast('success', resp.msg || 'Categoria eliminada');
                await refreshList();
                return;
            }

            toast('error', resp.msg || 'No se pudo eliminar la categoria');
            return;
        }

        if (btnEdit) {
            event.preventDefault();

            const fd = new FormData();
            fd.append('action', 'get');
            fd.append('id_ai_categoria_empleado', btnEdit.getAttribute('data-id') || '');

            const resp = await postCrud(fd);
            if (!resp.ok || !resp.data) {
                toast('error', resp.msg || 'No se pudo cargar la categoria');
                return;
            }

            const idInput = formUpdate?.querySelector('[name="id_ai_categoria_empleado"]');
            const nombreInput = formUpdate?.querySelector('#edit_nombre_categoria');
            const descripcionInput = formUpdate?.querySelector('#edit_descripcion_categoria');

            if (idInput) {
                idInput.value = resp.data.id_ai_categoria_empleado || '';
            }
            if (nombreInput) {
                nombreInput.value = resp.data.nombre_categoria || '';
            }
            if (descripcionInput) {
                descripcionInput.value = resp.data.descripcion || '';
            }

            if (modalEl && window.bootstrap) {
                bootstrap.Modal.getOrCreateInstance(modalEl).show();
            }
        }
    });

    if (btnRecargar) {
        btnRecargar.addEventListener('click', async (event) => {
            event.preventDefault();
            await refreshList();
            toast('success', 'Lista recargada');
        });
    }
});

document.addEventListener('DOMContentLoaded', () => {
    const dir = (document.getElementById('url')?.value || '').trim();
    const listContainer = document.getElementById('empleadoListContainer');
    const btnRecargar = document.getElementById('btnRecargarEmpleado');
    const formCreate = document.getElementById('formEmpleadoCreate');
    const formUpdate = document.getElementById('formEmpleadoUpdate');
    const createModalEl = document.getElementById('ventanaModalRegistrarEmpleado');
    const updateModalEl = document.getElementById('ventanaModalModificarEmpleado');

    if (!dir || !listContainer || !formCreate || !formUpdate) return;

    const URL_CRUD = dir + 'app/controllers/empleadoCrud.php';
    const URL_LIST = dir + 'app/controllers/empleadoList.php';
    const telefonoRegex = /^(?=(?:\D*\d){10,15}\D*$)[0-9()+ -]{10,20}$/;

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
        if (text.trim() === '') {
            return { ok: false, msg: 'Respuesta vacia del servidor.' };
        }
        if (text.trim().startsWith('<')) {
            return { ok: false, msg: 'Respuesta invalida del servidor.' };
        }
        try {
            return JSON.parse(text);
        } catch (error) {
            console.error(error, text);
            return { ok: false, msg: 'No se pudo procesar la respuesta del servidor.' };
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

    function resetCreateForm() {
        formCreate.reset();
        const nacionalidad = document.getElementById('nacionalidad_create');
        if (nacionalidad) {
            nacionalidad.value = 'V';
        }
    }

    function validarEmpleadoForm(form) {
        const idEmpleado = (form.querySelector('[name="id_empleado"]')?.value || '').trim();
        const nombreEmpleado = (form.querySelector('[name="nombre_empleado"]')?.value || '').trim();
        const categoria = (form.querySelector('[name="id_ai_categoria_empleado"]')?.value || '').trim();
        const telefono = (form.querySelector('[name="telefono"]')?.value || '').trim();
        const correoInput = form.querySelector('[name="correo"]');
        const correo = (correoInput?.value || '').trim();

        if (!idEmpleado || !nombreEmpleado || !categoria) {
            toast('warning', 'Completa los datos obligatorios');
            return false;
        }

        if (!correo) {
            toast('warning', 'El correo es obligatorio');
            correoInput?.focus();
            return false;
        }

        if (telefono && !telefonoRegex.test(telefono)) {
            toast('warning', 'El telefono debe tener entre 10 y 15 digitos validos');
            form.querySelector('[name="telefono"]')?.focus();
            return false;
        }

        if (correoInput && !correoInput.checkValidity()) {
            correoInput.reportValidity();
            toast('warning', 'Escribe un correo valido');
            correoInput.focus();
            return false;
        }

        return true;
    }

    [createModalEl, updateModalEl].forEach((modalEl) => {
        if (!modalEl) return;
        modalEl.addEventListener('hidden.bs.modal', () => hardResetModal());
    });

    if (createModalEl) {
        createModalEl.addEventListener('hidden.bs.modal', () => resetCreateForm());
    }

    formCreate.addEventListener('submit', async (event) => {
        event.preventDefault();
        event.stopPropagation();
        event.stopImmediatePropagation();

        if (!validarEmpleadoForm(formCreate)) {
            return;
        }

        const ok = await confirmDialog({
            title: 'Crear empleado?',
            text: 'Se registrara un nuevo empleado con su ficha de contacto.',
            confirmText: 'Si, crear',
        });
        if (!ok) return;

        const fd = new FormData(formCreate);
        fd.append('action', 'create');

        const resp = await postCrud(fd);
        if (resp.ok) {
            toast('success', resp.msg || 'Empleado creado');
            if (createModalEl && window.bootstrap) {
                bootstrap.Modal.getOrCreateInstance(createModalEl).hide();
            }
            resetCreateForm();
            await refreshList();
            return;
        }

        toast('error', resp.msg || 'No se pudo crear el empleado');
    }, true);

    formUpdate.addEventListener('submit', async (event) => {
        event.preventDefault();
        event.stopPropagation();
        event.stopImmediatePropagation();

        if (!validarEmpleadoForm(formUpdate)) {
            return;
        }

        const ok = await confirmDialog({
            title: 'Guardar cambios?',
            text: 'Se actualizara la ficha del empleado seleccionado.',
            confirmText: 'Si, guardar',
        });
        if (!ok) return;

        const fd = new FormData(formUpdate);
        fd.append('action', 'update');

        const resp = await postCrud(fd);
        if (resp.ok) {
            toast('success', resp.msg || 'Empleado actualizado');
            if (updateModalEl && window.bootstrap) {
                bootstrap.Modal.getOrCreateInstance(updateModalEl).hide();
            }
            await refreshList();
            return;
        }

        toast('error', resp.msg || 'No se pudo actualizar el empleado');
    }, true);

    listContainer.addEventListener('click', async (event) => {
        const btnEdit = event.target.closest('.js-emp-edit');
        const btnDel = event.target.closest('.js-emp-del');

        if (btnDel) {
            event.preventDefault();

            const ok = await confirmDialog({
                title: 'Eliminar empleado?',
                text: 'El empleado se desactivara si no tiene un usuario activo asociado.',
                confirmText: 'Si, eliminar',
            });
            if (!ok) return;

            const fd = new FormData();
            fd.append('action', 'delete');
            fd.append('id_ai_empleado', btnDel.getAttribute('data-id') || '');

            const resp = await postCrud(fd);
            if (resp.ok) {
                toast('success', resp.msg || 'Empleado eliminado');
                await refreshList();
                return;
            }

            toast('error', resp.msg || 'No se pudo eliminar el empleado');
            return;
        }

        if (btnEdit) {
            event.preventDefault();

            const fd = new FormData();
            fd.append('action', 'get');
            fd.append('id_ai_empleado', btnEdit.getAttribute('data-id') || '');

            const resp = await postCrud(fd);
            if (!resp.ok || !resp.data) {
                toast('error', resp.msg || 'No se pudo cargar el empleado');
                return;
            }

            document.getElementById('edit_id_ai_empleado').value = resp.data.id_ai_empleado || '';
            document.getElementById('edit_nacionalidad').value = resp.data.nacionalidad || 'V';
            document.getElementById('edit_id_empleado').value = resp.data.id_empleado || '';
            document.getElementById('edit_nombre_empleado').value = resp.data.nombre_empleado || '';
            document.getElementById('edit_telefono').value = resp.data.telefono || '';
            document.getElementById('edit_correo').value = resp.data.correo || '';
            document.getElementById('edit_direccion').value = resp.data.direccion || '';
            document.getElementById('edit_id_ai_categoria_empleado').value = resp.data.id_ai_categoria_empleado || '';

            if (updateModalEl && window.bootstrap) {
                bootstrap.Modal.getOrCreateInstance(updateModalEl).show();
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

document.addEventListener('DOMContentLoaded', function () {
    const tipoLabels = {
        1: 'Operador CCF',
        2: 'Operador CCO'
    };

    function tipoLabel(tipo) {
        return tipoLabels[parseInt(tipo || 0, 10)] || 'Tipo no definido';
    }

    function textoContacto(option) {
        const telefono = (option?.dataset?.telefono || '').trim();
        const correo = (option?.dataset?.correo || '').trim();

        if (telefono && correo) return `${telefono} | ${correo}`;
        if (telefono) return telefono;
        if (correo) return correo;
        return 'Sin contacto';
    }

    function mostrarEstado(alertEl, tipo, mensaje) {
        if (!alertEl) return;

        if (!mensaje) {
            alertEl.className = 'alert d-none mb-0';
            alertEl.textContent = '';
            return;
        }

        const classMap = {
            danger: 'alert alert-danger mb-0',
            warning: 'alert alert-warning mb-0',
            info: 'alert alert-info mb-0',
            success: 'alert alert-success mb-0'
        };

        alertEl.className = classMap[tipo] || 'alert alert-secondary mb-0';
        alertEl.textContent = mensaje;
    }

    function syncEmpleadoPanel(config) {
        const {
            select,
            codeInput,
            alertEl,
            submitBtn,
            summaryName,
            summaryDoc,
            summaryContact,
            currentCode,
            allowReuseInactive
        } = config;

        if (!select) return;

        const option = select.options[select.selectedIndex];
        const defaultCode = codeInput?.dataset?.nextCode || currentCode || '';
        const selectedValue = (select.value || '').trim();
        const existingCode = (option?.dataset?.miembroCodigo || '').trim();
        const existingType = parseInt(option?.dataset?.miembroTipo || 0, 10);
        const existingActive = parseInt(option?.dataset?.miembroActivo || 0, 10) === 1;

        if (summaryName) summaryName.textContent = selectedValue ? (option.dataset.nombre || 'Sin seleccionar') : 'Sin seleccionar';
        if (summaryDoc) summaryDoc.textContent = selectedValue ? (option.dataset.doc || '-') : '-';
        if (summaryContact) summaryContact.textContent = selectedValue ? textoContacto(option) : '-';

        if (codeInput) {
            codeInput.value = currentCode || defaultCode;
        }

        if (submitBtn) {
            submitBtn.disabled = false;
        }

        if (!selectedValue) {
            mostrarEstado(alertEl, '', '');
            if (codeInput && !currentCode) {
                codeInput.value = defaultCode;
            }
            return;
        }

        if (existingCode) {
            if (currentCode && existingCode === currentCode) {
                mostrarEstado(alertEl, 'info', `El empleado ya esta vinculado a este miembro como ${tipoLabel(existingType)}.`);
                return;
            }

            if (!currentCode && allowReuseInactive && !existingActive) {
                if (codeInput) {
                    codeInput.value = existingCode;
                }
                mostrarEstado(alertEl, 'info', `El empleado ya tuvo el codigo ${existingCode}. Al guardar se reactivara usando ese mismo codigo.`);
                return;
            }

            if (codeInput && !currentCode) {
                codeInput.value = existingCode;
            }

            if (submitBtn) {
                submitBtn.disabled = true;
            }

            const estadoTexto = existingActive ? 'ya esta activo' : 'ya tiene un registro previo';
            mostrarEstado(
                alertEl,
                existingActive ? 'danger' : 'warning',
                `El empleado ${estadoTexto} como miembro ${existingCode} (${tipoLabel(existingType)}).`
            );
            return;
        }

        mostrarEstado(alertEl, 'success', 'Empleado disponible para registrarlo como miembro.');
    }

    const modalRegistro = document.getElementById('ventanaModalRegistrarMiem');
    if (modalRegistro) {
        const formRegistro = document.getElementById('formRegistroMiembro');
        const selectRegistro = document.getElementById('id_empleado_registro');
        const codigoRegistro = document.getElementById('codigo_generado_registro');
        const estadoRegistro = document.getElementById('estadoEmpleadoRegistroMiembro');
        const btnGuardarRegistro = document.getElementById('btnGuardarRegistroMiembro');

        const registroConfig = {
            select: selectRegistro,
            codeInput: codigoRegistro,
            alertEl: estadoRegistro,
            submitBtn: btnGuardarRegistro,
            summaryName: document.getElementById('resumenNombreRegistroMiembro'),
            summaryDoc: document.getElementById('resumenDocumentoRegistroMiembro'),
            summaryContact: document.getElementById('resumenContactoRegistroMiembro'),
            currentCode: '',
            allowReuseInactive: true
        };

        modalRegistro.addEventListener('show.bs.modal', function () {
            if (formRegistro) formRegistro.reset();
            if (codigoRegistro) {
                codigoRegistro.value = codigoRegistro.dataset.nextCode || codigoRegistro.value || '';
            }
            syncEmpleadoPanel(registroConfig);
        });

        if (selectRegistro) {
            selectRegistro.addEventListener('change', function () {
                syncEmpleadoPanel(registroConfig);
            });
        }
    }

    const modalEdicion = document.getElementById('ventanaModalModificarMiem');
    if (!modalEdicion) return;

    const dir = document.getElementById('url').value;
    const selectEdicion = document.getElementById('id_empleado_edicion');
    const codigoEdicion = document.getElementById('codigo_edicion_miembro');
    const estadoEdicion = document.getElementById('estadoEmpleadoEdicionMiembro');
    const btnGuardarEdicion = document.getElementById('btnGuardarEdicionMiembro');
    const idInput = document.getElementById('miembro_id_edicion');
    const tipoInput = document.getElementById('tipo_edicion_miembro');

    const edicionConfig = {
        select: selectEdicion,
        codeInput: codigoEdicion,
        alertEl: estadoEdicion,
        submitBtn: btnGuardarEdicion,
        summaryName: document.getElementById('resumenNombreEdicionMiembro'),
        summaryDoc: document.getElementById('resumenDocumentoEdicionMiembro'),
        summaryContact: document.getElementById('resumenContactoEdicionMiembro'),
        currentCode: '',
        allowReuseInactive: false
    };

    function sincronizarEdicion() {
        edicionConfig.currentCode = (idInput?.value || '').trim();
        syncEmpleadoPanel(edicionConfig);
    }

    if (selectEdicion) {
        selectEdicion.addEventListener('change', sincronizarEdicion);
    }

    modalEdicion.addEventListener('show.bs.modal', function (event) {
        const button = event.relatedTarget;
        const id = button?.getAttribute('data-bs-id') || '';

        if (!id) return;

        const formData = new FormData();
        formData.append('id', id);

        fetch(dir + 'app/controllers/cargarDatosMiembro.php', {
            method: 'POST',
            body: formData
        })
            .then(response => {
                if (!response.ok) {
                    throw new Error('No se pudieron cargar los datos del miembro.');
                }
                return response.json();
            })
            .then(data => {
                if (!data || !data.id_miembro) {
                    throw new Error('No se encontraron datos del miembro solicitado.');
                }

                if (idInput) idInput.value = data.id_miembro || '';
                if (codigoEdicion) codigoEdicion.value = data.id_miembro || '';
                if (selectEdicion) selectEdicion.value = data.id_empleado || '';
                if (tipoInput) tipoInput.value = data.tipo_miembro || '';

                sincronizarEdicion();
            })
            .catch(error => {
                console.error('Error:', error);
                Swal.fire({
                    icon: 'error',
                    title: 'No se pudo cargar el miembro',
                    text: 'Ocurrio un problema al abrir los datos del miembro.'
                });
            });
    });
});

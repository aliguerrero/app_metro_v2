document.addEventListener('DOMContentLoaded', function () {
    const dir = document.getElementById('url').value;
    const btnBuscarMiembro = document.getElementById('btnBuscarMiembro');
    const btnRecargar = document.getElementById('btnRecargar');
    const inputCampo = document.getElementById('campo');

    const canEdit = document.getElementById('perm_miem_edit')
        ? document.getElementById('perm_miem_edit').value === '1'
        : false;

    const canDelete = document.getElementById('perm_miem_delete')
        ? document.getElementById('perm_miem_delete').value === '1'
        : false;

    let typingTimer = null;
    const DEBOUNCE_MS = 300;

    function getRows(payload) {
        if (Array.isArray(payload)) return payload;
        if (payload && Array.isArray(payload.data)) return payload.data;
        if (payload && Array.isArray(payload.rows)) return payload.rows;
        return [];
    }

    function fetchMiembros(tipoBusqueda, campo) {
        return $.ajax({
            url: dir + 'app/controllers/cargarDatosBuscadorMiem.php',
            method: 'GET',
            dataType: 'json',
            data: {
                tipoBusqueda: tipoBusqueda,
                id: campo || ''
            }
        });
    }

    function buscarMiembro() {
        const campo = limpiarCadena(inputCampo.value || '');

        if (campo === '') {
            reiniciarTabla(dir, canEdit, canDelete);
            return;
        }

        fetchMiembros('id', campo)
            .done(function (data) {
                const rows = getRows(data);
                renderMiemTable(dir, rows, canEdit, canDelete, rows.length === 0);
                renderMiemCards(dir, rows, canEdit, canDelete, rows.length === 0);

                if (rows.length === 0) {
                    alerta('info', 'No existen registros', 3000);
                }
            })
            .fail(function (xhr, status, error) {
                console.error('Error al obtener miembros:', error);
                console.error(xhr.responseText);
            });
    }

    if (inputCampo) {
        inputCampo.addEventListener('input', function () {
            clearTimeout(typingTimer);
            typingTimer = setTimeout(buscarMiembro, DEBOUNCE_MS);
        });
    }

    if (btnBuscarMiembro) {
        btnBuscarMiembro.addEventListener('click', buscarMiembro);
    }

    if (btnRecargar) {
        btnRecargar.addEventListener('click', function () {
            if (inputCampo) inputCampo.value = '';
            reiniciarTabla(dir, canEdit, canDelete);
            alerta('success', 'Tabla recargada', 2500);
        });
    }

    reiniciarTabla(dir, canEdit, canDelete);
});

function alerta(icono, texto, segundo) {
    if (typeof Swal === 'undefined') {
        console.warn(texto);
        return;
    }

    Swal.fire({
        toast: true,
        position: 'top-end',
        icon: icono || 'info',
        title: texto || '',
        showConfirmButton: false,
        timer: segundo || 2500,
        timerProgressBar: true
    });
}

function tipoOperadorMiembro(tipo) {
    return parseInt(tipo || 0, 10) === 1
        ? 'Operador CCF'
        : (parseInt(tipo || 0, 10) === 2 ? 'Operador CCO' : 'Tipo no definido');
}

function escapeHtml(value) {
    return String(value ?? '')
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#039;');
}

function badgeVinculoMiembro(miembro) {
    return parseInt(miembro.empleado_vinculado || 0, 10) === 1
        ? '<span class="badge bg-success">Vinculado</span>'
        : '<span class="badge bg-secondary">Legacy</span>';
}

function contactoMiembro(miembro) {
    const telefono = (miembro.telefono_empleado || '').trim();
    const correo = (miembro.correo_empleado || '').trim();

    if (telefono && correo) return `${telefono} | ${correo}`;
    if (telefono) return telefono;
    if (correo) return correo;
    return 'Sin contacto';
}

function reiniciarTabla(dir, canEdit, canDelete) {
    $.ajax({
        url: dir + 'app/controllers/cargarDatosBuscadorMiem.php',
        method: 'GET',
        dataType: 'json',
        data: { tipoBusqueda: 'todo' },
        success: function (data) {
            const rows = Array.isArray(data?.data) ? data.data : [];
            renderMiemTable(dir, rows, canEdit, canDelete, rows.length === 0);
            renderMiemCards(dir, rows, canEdit, canDelete, rows.length === 0);
        },
        error: function (xhr, status, error) {
            console.error('Error al obtener miembros:', error);
            console.error(xhr.responseText);
        }
    });
}

function renderMiemTable(dir, data, canEdit, canDelete, empty = false) {
    const table = document.getElementById('tablaDatosMiem');
    if (!table) return;

    const tbody = table.getElementsByTagName('tbody')[0];
    if (!tbody) return;

    tbody.innerHTML = '';

    if (empty || !Array.isArray(data) || data.length === 0) {
        const fila = tbody.insertRow();
        fila.classList.add('align-middle');
        fila.innerHTML = '<td class="text-center" colspan="8">No hay registros en el sistema</td>';
        return;
    }

    data.forEach(function (miem, index) {
        const fila = tbody.insertRow();
        fila.classList.add('align-middle');
        fila.innerHTML = buildRowMiembro(dir, index + 1, miem, canEdit, canDelete);
    });
}

function renderMiemCards(dir, data, canEdit, canDelete, empty = false) {
    const scope = document.querySelector('.miembro-responsive') || document;
    const cardsWrap =
        scope.querySelector('#toolCardsMiem') ||
        scope.querySelector('.tool-cards') ||
        document.getElementById('toolCardsMiem');

    if (!cardsWrap) return;

    cardsWrap.innerHTML = '';

    if (empty || !Array.isArray(data) || data.length === 0) {
        cardsWrap.innerHTML = `
            <div class="tool-card">
                <div class="tool-card-head">
                    <span class="tool-code">Sin registros</span>
                    <span>-</span>
                </div>
                <div class="tool-body">
                    <div class="tool-row" style="border-bottom:0;">
                        <div class="tool-label">Estado</div>
                        <div class="tool-value">No hay miembros activos registrados</div>
                    </div>
                </div>
            </div>`;
        return;
    }

    cardsWrap.innerHTML = data.map((miem, index) => cardMiembro(dir, index + 1, miem, canEdit, canDelete)).join('');
}

function buildRowMiembro(dir, contador, miem, canEdit, canDelete) {
    const acciones = [];

    if (canEdit) {
        acciones.push(`
            <a href="#" title="Modificar" class="btn btn-warning text-dark"
               data-bs-toggle="modal" data-bs-target="#ventanaModalModificarMiem" data-bs-id="${miem.id_miembro}">
                <i class="bi bi-pencil text-white"></i>
            </a>`);
    }

    if (canDelete) {
        acciones.push(`
            <a href="#" title="Eliminar" class="btn btn-danger"
               onclick="eliminarMiembro('${miem.id_miembro}', '${dir}', ${canEdit ? 1 : 0}, ${canDelete ? 1 : 0}); return false;">
                <i class="bi bi-trash" style="color:white;"></i>
            </a>`);
    }

    return `
        <td><b>${contador}</b></td>
        <td class="text-center col-p">
            <div class="avatar avatar-md">
                <img class="avatar-img" src="${dir}app/views/img/avatars/user.png" alt="miembro">
            </div>
        </td>
        <td><b>${escapeHtml(miem.id_miembro)}</b></td>
        <td>
            <div><b>${escapeHtml(miem.nombre_visual)}</b></div>
            <div class="small text-muted">${badgeVinculoMiembro(miem)}</div>
        </td>
        <td>${escapeHtml(miem.documento_empleado || 'No vinculado')}</td>
        <td class="text-center"><b>${tipoOperadorMiembro(miem.tipo_miembro)}</b></td>
        <td class="miembro-contact-cell">${escapeHtml(contactoMiembro(miem))}</td>
        <td class="action-cell text-center">
            <div class="tools-action-group" role="group" aria-label="Acciones de miembro">
                ${acciones.join('')}
            </div>
        </td>`;
}

function cardMiembro(dir, contador, miem, canEdit, canDelete) {
    const acciones = [];

    if (canEdit) {
        acciones.push(`
            <a href="#" title="Modificar" class="btn btn-warning text-dark btn-sm"
               data-bs-toggle="modal" data-bs-target="#ventanaModalModificarMiem" data-bs-id="${miem.id_miembro}">
                <i class="bi bi-pencil text-white"></i>
            </a>`);
    }

    if (canDelete) {
        acciones.push(`
            <button type="button" class="btn btn-danger btn-sm" title="Eliminar"
                    onclick="eliminarMiembro('${miem.id_miembro}', '${dir}', ${canEdit ? 1 : 0}, ${canDelete ? 1 : 0})">
                <i class="bi bi-trash"></i>
            </button>`);
    }

    return `
            <div class="tool-card">
                <div class="tool-card-head">
                    <span class="tool-code">${escapeHtml(miem.id_miembro)}</span>
                    <span>${badgeVinculoMiembro(miem)}</span>
                </div>
            <div class="tool-body">
                <div class="tool-row">
                    <div class="tool-label">Empleado</div>
                    <div class="tool-value">${escapeHtml(miem.nombre_visual)}</div>
                </div>
                <div class="tool-row">
                    <div class="tool-label">Documento</div>
                    <div class="tool-value">${escapeHtml(miem.documento_empleado || 'No vinculado')}</div>
                </div>
                <div class="tool-row">
                    <div class="tool-label">Tipo</div>
                    <div class="tool-value">${tipoOperadorMiembro(miem.tipo_miembro)}</div>
                </div>
                <div class="tool-row">
                    <div class="tool-label">Contacto</div>
                    <div class="tool-value miembro-contact-value">${escapeHtml(contactoMiembro(miem))}</div>
                </div>
                <div class="tool-actions">
                    <div class="tools-action-group" role="group" aria-label="Acciones de miembro">${acciones.join('')}</div>
                </div>
            </div>
        </div>`;
}

function eliminarMiembro(parametro, dir, canEdit, canDelete) {
    Swal.fire({
        title: 'Estas seguro?',
        text: 'El miembro quedara inactivo.',
        icon: 'question',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Si, eliminar',
        cancelButtonText: 'No, cancelar',
    }).then((result) => {
        if (!result.isConfirmed) return;

        $.ajax({
            url: dir + 'app/controllers/cargarDatosBuscadorMiem.php',
            method: 'GET',
            dataType: 'json',
            data: { id: parametro, tipoBusqueda: 'eliminar' },
            success: function (data) {
                reiniciarTabla(dir, canEdit, canDelete);

                if (data && data.ok) {
                    alertas_ajax({
                        tipo: 'simple',
                        icono: 'success',
                        titulo: 'Miembro eliminado',
                        texto: data.texto || 'El miembro fue inactivado con exito.'
                    });
                } else {
                    alertas_ajax({
                        tipo: 'simple',
                        icono: 'error',
                        titulo: 'No se pudo eliminar',
                        texto: (data && data.texto) ? data.texto : 'No se pudo eliminar el miembro.'
                    });
                }
            },
            error: function (xhr, status, error) {
                console.error('Error al eliminar miembro:', error);
                console.error(xhr.responseText);
            }
        });
    });
}

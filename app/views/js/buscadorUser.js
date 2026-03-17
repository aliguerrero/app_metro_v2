document.addEventListener('DOMContentLoaded', function () {
    const dir = document.getElementById('url') ? document.getElementById('url').value : '';
    const inputCampo = document.getElementById('campo');
    const btnRecargar = document.getElementById('btnRecargar');
    const table = document.getElementById('tablaDatosUser');
    const cardsWrap = document.getElementById('toolCardsUser');
    const canEdit = (document.getElementById('perm_user_edit')?.value || '') === '1';
    const canDelete = (document.getElementById('perm_user_delete')?.value || '') === '1';

    let typingTimer = null;
    const debounceMs = 300;

    function buscarUser() {
        const campo = limpiarCadena(inputCampo ? inputCampo.value : '');

        if (!campo) {
            reiniciarTabla(dir);
            return;
        }

        $.ajax({
            url: dir + 'app/controllers/cargarDatosBuscadorUser.php',
            method: 'GET',
            dataType: 'json',
            data: { id: campo, tipoBusqueda: 'id' },
            success: function (data) {
                if (Array.isArray(data) && data.length > 0) {
                    renderUsersTable(dir, data, canEdit, canDelete);
                    renderUsersCards(dir, data, canEdit, canDelete);
                    return;
                }

                renderUsersTable(dir, [], canEdit, canDelete, true);
                renderUsersCards(dir, [], canEdit, canDelete, true);
                alerta('info', 'No existen registros', 3000);
            },
            error: function (xhr, status, error) {
                console.error('Error al buscar usuarios:', error);
                console.log('Respuesta completa del servidor:', xhr.responseText);
            }
        });
    }

    if (inputCampo) {
        inputCampo.addEventListener('input', function () {
            clearTimeout(typingTimer);
            typingTimer = setTimeout(buscarUser, debounceMs);
        });
    }

    if (btnRecargar) {
        btnRecargar.addEventListener('click', function () {
            if (inputCampo) {
                inputCampo.value = '';
            }
            alerta('success', 'Tabla recargada', 2500);
            reiniciarTabla(dir);
        });
    }

    function handleDeleteClick(event) {
        const button = event.target.closest('.js-user-delete');
        if (!button) {
            return;
        }

        const id = button.getAttribute('data-id') || '';
        eliminarUser(id, dir);
    }

    if (table) {
        table.addEventListener('click', handleDeleteClick);
    }

    if (cardsWrap) {
        cardsWrap.addEventListener('click', handleDeleteClick);
    }

    reiniciarTabla(dir);
});

function reiniciarTabla(dir) {
    const canEdit = (document.getElementById('perm_user_edit')?.value || '') === '1';
    const canDelete = (document.getElementById('perm_user_delete')?.value || '') === '1';

    $.ajax({
        url: dir + 'app/controllers/cargarDatosBuscadorUser.php',
        method: 'GET',
        dataType: 'json',
        data: { tipoBusqueda: 'todo' },
        success: function (data) {
            if (Array.isArray(data) && data.length > 0) {
                renderUsersTable(dir, data, canEdit, canDelete);
                renderUsersCards(dir, data, canEdit, canDelete);
                return;
            }

            renderUsersTable(dir, [], canEdit, canDelete, true);
            renderUsersCards(dir, [], canEdit, canDelete, true);
        },
        error: function (xhr, status, error) {
            console.error('Error:', xhr.status, error);
            console.log('responseText:', xhr.responseText);
        }
    });
}

function renderUsersTable(dir, data, canEdit, canDelete, empty = false) {
    const table = document.getElementById('tablaDatosUser');
    if (!table) {
        return;
    }

    const tbody = table.getElementsByTagName('tbody')[0];
    if (!tbody) {
        return;
    }

    tbody.innerHTML = '';

    if (empty || !Array.isArray(data) || data.length === 0) {
        const row = tbody.insertRow();
        row.classList.add('align-middle');
        row.innerHTML = '<td class="text-center" colspan="10">No hay registros en el sistema</td>';
        return;
    }

    let contador = 1;
    data.forEach(function (user) {
        const row = tbody.insertRow();
        row.classList.add('align-middle');
        row.innerHTML = buildRowUser(dir, contador, user, canEdit, canDelete);
        contador++;
    });
}

function renderUsersCards(dir, data, canEdit, canDelete, empty = false) {
    const cardsWrap = document.getElementById('toolCardsUser');
    if (!cardsWrap) {
        return;
    }

    cardsWrap.innerHTML = '';

    if (empty || !Array.isArray(data) || data.length === 0) {
        cardsWrap.innerHTML = userCardVacia();
        return;
    }

    let contador = 1;
    let html = '';
    data.forEach(function (user) {
        html += userCardUser(dir, contador, user, canEdit, canDelete);
        contador++;
    });

    cardsWrap.innerHTML = html;
}

function buildRowUser(dir, contador, user, canEdit, canDelete) {
    const codigo = escapeHtml(user.id_user || '');
    const nombre = escapeHtml(user.nombre_empleado || '');
    const categoria = escapeHtml(user.nombre_categoria || 'SIN CATEGORIA');
    const username = escapeHtml(user.username || '');
    const rol = escapeHtml(user.nombre_rol || '');
    const safeDir = escapeHtml(dir);

    const passBtn = canEdit
        ? `
        <td class="col-p">
            <a href="#" title="Cambiar Clave" class="btn btn-dark text-white"
               data-bs-toggle="modal" data-bs-target="#ventanaModalModificarPass" data-bs-id="${codigo}">
                <i class="bi bi-lock"></i>
            </a>
        </td>`
        : '<td class="col-p"></td>';

    const editBtn = canEdit
        ? `
        <td class="col-p">
            <a href="#" title="Modificar" class="btn btn-warning text-dark"
               data-bs-toggle="modal" data-bs-target="#ventanaModalModificar" data-bs-id="${codigo}">
                <i class="bi bi-pencil text-white"></i>
            </a>
        </td>`
        : '<td class="col-p"></td>';

    const deleteBtn = canDelete
        ? `
        <td class="col-p">
            <button type="button" title="Eliminar" class="btn btn-danger js-user-delete" data-id="${codigo}">
                <i class="bi bi-trash" style="color:white;"></i>
            </button>
        </td>`
        : '<td class="col-p"></td>';

    return `
        <td class="clearfix col-p"><div><b>${contador}</b></div></td>
        <td class="text-center col-p">
            <div class="avatar avatar-md">
                <img class="avatar-img" src="${safeDir}app/views/img/avatars/user.png" alt="avatar de usuario">
            </div>
        </td>
        <td><div><b>${codigo}</b></div></td>
        <td><div><b>${nombre}</b></div></td>
        <td>${categoria}</td>
        <td>@${username}</td>
        <td><div class="text-center"><b>${rol}</b></div></td>
        ${passBtn}
        ${editBtn}
        ${deleteBtn}
    `;
}

function userCardUser(dir, contador, user, canEdit, canDelete) {
    const codigo = escapeHtml(user.id_user || '');
    const nombre = escapeHtml(user.nombre_empleado || '');
    const categoria = escapeHtml(user.nombre_categoria || 'SIN CATEGORIA');
    const username = escapeHtml(user.username || '');
    const rol = escapeHtml(user.nombre_rol || '');

    const passBtn = canEdit
        ? `
                <a href="#" title="Cambiar Clave" class="btn btn-dark text-white btn-sm"
                   data-bs-toggle="modal" data-bs-target="#ventanaModalModificarPass" data-bs-id="${codigo}">
                    <i class="bi bi-lock"></i>
                </a>`
        : '';

    const editBtn = canEdit
        ? `
            <a href="#" title="Modificar" class="btn btn-warning text-dark btn-sm"
               data-bs-toggle="modal" data-bs-target="#ventanaModalModificar" data-bs-id="${codigo}">
                <i class="bi bi-pencil text-white"></i>
            </a>`
        : '';

    const deleteBtn = canDelete
        ? `
            <button type="button" class="btn btn-danger btn-sm js-user-delete" title="Eliminar" data-id="${codigo}">
                <i class="bi bi-trash"></i>
            </button>`
        : '';

    return `
    <div class="tool-card">
        <div class="tool-card-head">
            <span class="tool-code">#${contador} - ${codigo}</span>
            <span><b>Rol:</b> ${rol}</span>
        </div>
        <div class="tool-body">
            <div class="tool-row">
                <div class="tool-label">Empleado</div>
                <div class="tool-value">${nombre}</div>
            </div>
            <div class="tool-row">
                <div class="tool-label">Categoria</div>
                <div class="tool-value">${categoria}</div>
            </div>
            <div class="tool-row">
                <div class="tool-label">Username</div>
                <div class="tool-value">@${username}</div>
            </div>
            <div class="tool-actions">
                ${passBtn}
                ${editBtn}
                ${deleteBtn}
            </div>
        </div>
    </div>
    `;
}

function userCardVacia() {
    return `
    <div class="tool-card">
        <div class="tool-card-head">
            <span class="tool-code">Sin registros</span>
            <span>-</span>
        </div>
        <div class="tool-body">
            <div class="tool-row" style="border-bottom:0;">
                <div class="tool-label">Estado</div>
                <div class="tool-value">No hay registros en el sistema</div>
            </div>
        </div>
    </div>
    `;
}

function eliminarUser(id, dir) {
    if (!id) {
        return;
    }

    Swal.fire({
        title: 'Estas seguro?',
        text: 'Quieres realizar la accion solicitada?',
        icon: 'question',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Si, realizar',
        cancelButtonText: 'No, cancelar',
    }).then((result) => {
        if (!result.isConfirmed) {
            return;
        }

        const formData = new FormData();
        formData.append('id', id);
        formData.append('tipoBusqueda', 'eliminar');

        $.ajax({
            url: dir + 'app/controllers/cargarDatosBuscadorUser.php',
            method: 'POST',
            dataType: 'json',
            data: formData,
            processData: false,
            contentType: false,
            success: function (data) {
                reiniciarTabla(dir);

                if (data && data.ok) {
                    alertas_ajax({
                        tipo: 'simple',
                        icono: 'success',
                        titulo: 'Usuario eliminado',
                        texto: 'El usuario ha sido eliminado con exito'
                    });
                    return;
                }

                alertas_ajax({
                    tipo: 'simple',
                    icono: 'error',
                    titulo: 'Ocurrio un error inesperado',
                    texto: 'No se pudo eliminar el usuario, por favor intenta nuevamente'
                });
            },
            error: function (xhr, status, error) {
                console.error('Error al eliminar usuario:', error);
                reiniciarTabla(dir);
            }
        });
    });
}

function escapeHtml(value) {
    return String(value || '')
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#039;');
}

function alerta(icono, texto, segundo) {
    let Toast = Swal.mixin({
        toast: true,
        position: 'bottom-end',
        showConfirmButton: false,
        timer: segundo,
        timerProgressBar: true,
        didOpen: (toast) => {
            toast.onmouseenter = Swal.stopTimer;
            toast.onmouseleave = Swal.resumeTimer;
        }
    });
    Toast.fire({ icon: icono, title: texto });
}

function mostrarAlerta(icono, titulo, texto) {
    Swal.fire({
        icon: icono,
        title: titulo,
        text: texto,
        confirmButtonText: 'Aceptar'
    });
}

function limpiarCadena(cadena) {
    const palabras = [
        '<script>', '</script>', '<script src', '<script type=',
        'SELECT * FROM', 'SELECT ', ' SELECT ', 'DELETE FROM',
        'INSERT INTO', 'DROP TABLE', 'DROP DATABASE', 'TRUNCATE TABLE',
        'SHOW TABLES', 'SHOW DATABASES', '\\<\\?php', '\\?\\>', '--',
        '^', '<', '>', '==', '=', ';', '::'
    ];

    cadena = (cadena || '').trim();
    cadena = cadena.replace(/\\/g, '');

    palabras.forEach(function (palabra) {
        cadena = cadena.replace(new RegExp(palabra, 'gi'), '');
    });

    cadena = cadena.replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#039;');

    return cadena.trim().replace(/\\/g, '');
}

document.addEventListener('DOMContentLoaded', function () {

    let dir = document.getElementById('url').value;

    let btnBuscarMiembro = document.getElementById('btnBuscarMiembro');
    let btnRecargar = document.getElementById('btnRecargar');
    let inputCampo = document.getElementById('campo');

    let canEdit = document.getElementById('perm_miem_edit')
        ? (document.getElementById('perm_miem_edit').value === '1')
        : false;

    let canDelete = document.getElementById('perm_miem_delete')
        ? (document.getElementById('perm_miem_delete').value === '1')
        : false;

    // Debounce
    let typingTimer = null;
    const DEBOUNCE_MS = 300;

    function getRows(payload) {
        // Acepta: []  ó  {data:[]}  ó  {rows:[]}
        if (Array.isArray(payload)) return payload;
        if (payload && Array.isArray(payload.data)) return payload.data;
        if (payload && Array.isArray(payload.rows)) return payload.rows;
        return [];
    }

    function buscarMiembro() {
        let tipoBusqueda = 'id';
        let campo = limpiarCadena(inputCampo.value);

        if (campo === "") {
            reiniciarTabla(dir, canEdit, canDelete);
            return;
        }

        $.ajax({
            url: dir + 'app/controllers/cargarDatosBuscadorMiem.php',
            method: 'GET',
            dataType: 'json',
            data: { id: campo, tipoBusqueda: tipoBusqueda },
            success: function (data) {
                const rows = getRows(data);

                if (rows.length > 0) {
                    renderMiemTable(dir, rows, canEdit, canDelete);
                    renderMiemCards(dir, rows, canEdit, canDelete);
                } else {
                    renderMiemTable(dir, [], canEdit, canDelete, true);
                    renderMiemCards(dir, [], canEdit, canDelete, true);
                    alerta("info", "No existen registros", 4000);
                }
            },
            error: function (xhr, status, error) {
                console.error('Error al obtener miembros:', error);
                console.error('Respuesta (por si no era JSON válido):', xhr.responseText);
            }
        });
    }

    if (inputCampo) {
        inputCampo.addEventListener('input', function () {
            clearTimeout(typingTimer);
            typingTimer = setTimeout(buscarMiembro, DEBOUNCE_MS);
        });
    }

    if (btnBuscarMiembro) {
        btnBuscarMiembro.addEventListener('click', function () {
            buscarMiembro();
        });
    }

    if (btnRecargar) {
        btnRecargar.addEventListener('click', function () {
            alerta("success", "Tabla recargada", 4000);
            if (inputCampo) inputCampo.value = '';
            reiniciarTabla(dir, canEdit, canDelete);
        });
    }

    // Carga inicial
    reiniciarTabla(dir, canEdit, canDelete);
});


function reiniciarTabla(dir, canEdit, canDelete) {
    let tipoBusqueda = 'todo';

    $.ajax({
        url: dir + 'app/controllers/cargarDatosBuscadorMiem.php',
        method: 'GET',
        dataType: 'json',
        data: { tipoBusqueda: tipoBusqueda },
        success: function (data) {
            const rows = (function getRows(payload) {
                if (Array.isArray(payload)) return payload;
                if (payload && Array.isArray(payload.data)) return payload.data;
                if (payload && Array.isArray(payload.rows)) return payload.rows;
                return [];
            })(data);

            if (rows.length > 0) {
                renderMiemTable(dir, rows, canEdit, canDelete);
                renderMiemCards(dir, rows, canEdit, canDelete);
            } else {
                renderMiemTable(dir, [], canEdit, canDelete, true);
                renderMiemCards(dir, [], canEdit, canDelete, true);
            }
        },
        error: function (xhr, status, error) {
            console.error('Error al obtener miembros:', error);
            console.error('Respuesta (por si no era JSON válido):', xhr.responseText);
        }
    });
}


/* =========================
   TABLA DESKTOP
========================= */
function renderMiemTable(dir, data, canEdit, canDelete, empty = false) {
    let table = document.getElementById('tablaDatosMiem');
    if (!table) return;

    let tbody = table.getElementsByTagName('tbody')[0];
    if (!tbody) return;

    tbody.innerHTML = '';

    // total columnas = 7 (no 8)
    if (empty || !Array.isArray(data) || data.length === 0) {
        let fila = tbody.insertRow();
        fila.classList.add('align-middle');
        fila.innerHTML = `<td class="text-center" colspan="7">No hay registros en el sistema</td>`;
        return;
    }

    let contador = 1;
    data.forEach(function (miem) {
        let fila = tbody.insertRow();
        fila.classList.add('align-middle');
        fila.innerHTML = buildRowMiembro(dir, contador, miem, canEdit, canDelete);
        contador++;
    });
}


/* =========================
   CARDS MÓVIL
========================= */
function renderMiemCards(dir, data, canEdit, canDelete, empty = false) {
    let scope = document.querySelector('.miembro-responsive') || document;

    let cardsWrap =
        scope.querySelector('#toolCardsMiem') ||
        scope.querySelector('.tool-cards') ||
        document.getElementById('toolCardsMiem') ||
        document.querySelector('.tool-cards');

    if (!cardsWrap) return;

    cardsWrap.innerHTML = '';

    if (empty || !Array.isArray(data) || data.length === 0) {
        cardsWrap.innerHTML = cardMiembroVacia();
        return;
    }

    let contador = 1;
    let html = '';
    data.forEach(function (miem) {
        html += cardMiembro(dir, contador, miem, canEdit, canDelete);
        contador++;
    });

    cardsWrap.innerHTML = html;
}


/* =========================
   BUILDERS
========================= */
function buildRowMiembro(dir, contador, miem, canEdit, canDelete) {

    let btnEdit = canEdit ? `
    <td class="col-p">
      <a href="#" title="Modificar" class="btn btn-warning text-dark"
         data-bs-toggle="modal" data-bs-target="#ventanaModalModificarMiem" data-bs-id="${miem.id_miembro}">
        <i class="bi bi-pencil text-white"></i>
      </a>
    </td>` : `<td class="col-p"></td>`;

    let btnDel = canDelete ? `
    <td class="col-p">
      <a href="#" title="Eliminar" class="btn btn-danger"
         onclick="eliminarMiembro('${miem.id_miembro}','${dir}', ${canEdit}, ${canDelete}); return false;">
        <i class="bi bi-trash" style="color: white;"></i>
      </a>
    </td>` : `<td class="col-p"></td>`;

    return `
    <td class="clearfix col-p"><div><b>${contador}</b></div></td>

    <td class="text-center col-p">
      <div class="avatar avatar-md">
        <img class="avatar-img" src="${dir}app/views/img/avatars/user.png" alt="user@email.com">
      </div>
    </td>

    <td class="col-p"><div class="clearfix"><div><b>${miem.id_miembro}</b></div></div></td>

    <td><div class="clearfix"><div><b>${miem.nombre_miembro}</b></div></div></td>

    <td class="col-2">
      <div class="text-center"><div><b>${tipoOperador(parseInt(miem.tipo_miembro, 10))}</b></div></div>
    </td>

    ${btnEdit}
    ${btnDel}
  `;
}

function cardMiembro(dir, contador, miem, canEdit, canDelete) {
    let tipo = tipoOperador(parseInt(miem.tipo_miembro, 10));

    let btnEdit = canEdit ? `
    <a href="#" title="Modificar" class="btn btn-warning text-dark btn-sm"
       data-bs-toggle="modal" data-bs-target="#ventanaModalModificarMiem" data-bs-id="${miem.id_miembro}">
      <i class="bi bi-pencil text-white"></i>
    </a>` : '';

    let btnDel = canDelete ? `
    <button type="button" class="btn btn-danger btn-sm" title="Eliminar"
            onclick="eliminarMiembro('${miem.id_miembro}','${dir}', ${canEdit}, ${canDelete})">
      <i class="bi bi-trash"></i>
    </button>` : '';

    return `
    <div class="tool-card">
      <div class="tool-card-head">
        <span class="tool-code">#${contador} • Código: ${miem.id_miembro}</span>
        <span><b>Tipo:</b> ${tipo}</span>
      </div>

      <div class="tool-body">
        <div class="tool-row">
          <div class="tool-label">Nombre</div>
          <div class="tool-value">${miem.nombre_miembro}</div>
        </div>

        <div class="tool-actions">
          ${btnEdit}
          ${btnDel}
        </div>
      </div>
    </div>
  `;
}

function cardMiembroVacia() {
    return `
    <div class="tool-card">
      <div class="tool-card-head">
        <span class="tool-code">Sin registros</span>
        <span>—</span>
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


/* =========================
   ELIMINAR (JS)
========================= */
function eliminarMiembro(parametro, dir, canEdit, canDelete) {
    let tipoBusqueda = 'eliminar';

    Swal.fire({
        title: "¿Estás seguro?",
        text: "¡Quieres realizar la acción solicitada!",
        icon: "question",
        showCancelButton: true,
        confirmButtonColor: "#3085d6",
        cancelButtonColor: "#d33",
        confirmButtonText: "Sí, realizar",
        cancelButtonText: "No, cancelar",
    }).then((result) => {
        if (!result.isConfirmed) return;

        $.ajax({
            url: dir + 'app/controllers/cargarDatosBuscadorMiem.php',
            method: 'GET',
            dataType: 'json',
            data: { id: parametro, tipoBusqueda: tipoBusqueda },
            success: function (data) {
                reiniciarTabla(dir, canEdit, canDelete);

                if (data) {
                    var alerta = { tipo: "simple", icono: "success", titulo: "Miembro Eliminado", texto: 'El Miembro ha sido eliminado con exito' };
                    alertas_ajax(alerta);
                } else {
                    var alerta = { tipo: "simple", icono: "error", titulo: "Ocurrió un error inesperado", texto: 'No se pudo eliminar el Miembro, por favor intente nuevamente' };
                    alertas_ajax(alerta);
                }
            },
            error: function (xhr, status, error) {
                console.error('Error al eliminar miembro:', error);
                console.error('Respuesta (por si no era JSON válido):', xhr.responseText);
            }
        });
    });
}

function tipoOperador(tipo) {
    return (tipo === 1) ? "C.C.F." : "C.C.O.";
}

function alerta(icono, texto, segundo) {
    let Toast = Swal.mixin({
        toast: true,
        position: "bottom-end",
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

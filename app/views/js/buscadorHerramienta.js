document.addEventListener('DOMContentLoaded', function () {
    const dir = document.getElementById('url')?.value || '';
    const btnBuscarHerramienta = document.getElementById('btnBuscarHerramienta');
    const btnRecargar = document.getElementById('btnRecargar');
    const inputCampo = document.getElementById('campo');

    const canEdit = document.getElementById('perm_herr_edit') ? (document.getElementById('perm_herr_edit').value === '1') : false;
    const canDelete = document.getElementById('perm_herr_delete') ? (document.getElementById('perm_herr_delete').value === '1') : false;

    let typingTimer = null;
    const DEBOUNCE_MS = 300;

    function buscarHerramienta() {
        const tipoBusqueda = 'id';
        const campo = limpiarCadena(inputCampo.value);

        if (campo === '') {
            reiniciarTabla(dir, canEdit, canDelete);
            return;
        }

        $.ajax({
            url: dir + 'app/controllers/cargarDatosBuscadorTools.php',
            method: 'GET',
            dataType: 'json',
            data: { id: campo, tipoBusqueda: tipoBusqueda },
            success: function (data) {
                if (Array.isArray(data) && data.length > 0) {
                    renderToolsTable(dir, data, canEdit, canDelete);
                    renderToolsCards(dir, data, canEdit, canDelete);
                } else {
                    renderToolsTable(dir, [], canEdit, canDelete, true);
                    renderToolsCards(dir, [], canEdit, canDelete, true);
                    alerta('info', 'No existen registros', 4000);
                }
            },
            error: function (xhr, status, error) {
                console.error('Error:', error);
            }
        });
    }

    if (inputCampo) {
        inputCampo.addEventListener('input', function () {
            clearTimeout(typingTimer);
            typingTimer = setTimeout(buscarHerramienta, DEBOUNCE_MS);
        });
    }

    if (btnBuscarHerramienta) {
        btnBuscarHerramienta.addEventListener('click', function () {
            buscarHerramienta();
        });
    }

    if (btnRecargar) {
        btnRecargar.addEventListener('click', function () {
            alerta('success', 'Tabla recargada', 4000);
            if (inputCampo) inputCampo.value = '';
            reiniciarTabla(dir, canEdit, canDelete);
        });
    }

    reiniciarTabla(dir, canEdit, canDelete);
});

function escapeHtml(value) {
    return String(value ?? '')
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#039;');
}

function reiniciarTabla(dir, canEdit, canDelete) {
    $.ajax({
        url: dir + 'app/controllers/cargarDatosBuscadorTools.php',
        method: 'GET',
        dataType: 'json',
        data: { tipoBusqueda: 'todo' },
        success: function (data) {
            if (Array.isArray(data) && data.length > 0) {
                renderToolsTable(dir, data, canEdit, canDelete);
                renderToolsCards(dir, data, canEdit, canDelete);
            } else {
                renderToolsTable(dir, [], canEdit, canDelete, true);
                renderToolsCards(dir, [], canEdit, canDelete, true);
            }
        },
        error: function (xhr, status, error) {
            console.error('Error:', error);
        }
    });
}

function renderToolsTable(dir, data, canEdit, canDelete, empty = false) {
    const table = document.getElementById('tablaDatosTools');
    if (!table) return;

    const tbody = table.getElementsByTagName('tbody')[0];
    if (!tbody) return;

    tbody.innerHTML = '';

    if (empty || !Array.isArray(data) || data.length === 0) {
        const fila = tbody.insertRow();
        fila.classList.add('align-middle');
        fila.innerHTML = '<td class="text-center" colspan="9">No hay registros en el sistema</td>';
        return;
    }

    let contador = 1;
    data.forEach(function (datos) {
        const fila = tbody.insertRow();
        fila.classList.add('align-middle');
        fila.innerHTML = buildRowHerramienta(dir, contador, datos, canEdit, canDelete);
        contador++;
    });
}

function renderToolsCards(dir, data, canEdit, canDelete, empty = false) {
    const scope = document.querySelector('.herramienta-responsive') || document;
    const cardsWrap =
        scope.querySelector('#toolCardsTools') ||
        scope.querySelector('.tool-cards') ||
        document.getElementById('toolCardsTools') ||
        document.querySelector('.tool-cards');

    if (!cardsWrap) return;

    cardsWrap.innerHTML = '';

    if (empty || !Array.isArray(data) || data.length === 0) {
        cardsWrap.innerHTML = toolCardVacia();
        return;
    }

    let contador = 1;
    let html = '';
    data.forEach(function (datos) {
        html += toolCardHerramienta(dir, contador, datos, canEdit, canDelete);
        contador++;
    });

    cardsWrap.innerHTML = html;
}

function buildRowHerramienta(dir, contador, datos, canEdit, canDelete) {
    const categoria = escapeHtml(datos.nombre_categoria || 'SIN CATEGORIA');
    const id = escapeHtml(datos.id_ai_herramienta);
    const nombre = escapeHtml(datos.nombre_herramienta || '');

    const buttons = [`
    <button type="button" title="Ver ocupaciones" class="btn btn-info text-white js-tool-ocupaciones"
        data-bs-toggle="modal" data-bs-target="#herramientaOcupacionesModal" data-id="${id}" data-nombre="${nombre}">
      <i class="bi bi-diagram-3"></i>
    </button>`];

    if (canEdit) {
        buttons.push(`
    <a href="#" title="Modificar" class="btn btn-warning text-dark"
       data-bs-toggle="modal" data-bs-target="#ventanaModalModificarHerr" data-bs-id="${id}">
      <i class="bi bi-pencil text-white"></i>
    </a>`);
    }

    if (canDelete) {
        buttons.push(`
    <button type="button" title="Eliminar" class="btn btn-danger"
            onclick="eliminarHerramienta('${id}','${dir}', ${canEdit}, ${canDelete})">
      <i class="bi bi-trash" style="color:white;"></i>
    </button>`);
    }

    return `
    <td class="clearfix col-p"><div><b>${contador}</b></div></td>
    <td class="text-center col-p">
      <div class="avatar avatar-md">
        <img class="avatar-img" src="${dir}app/views/img/tools.png" alt="tool">
      </div>
    </td>
    <td class="col-p"><div class="clearfix"><div><b>${id}</b></div></div></td>
    <td><div class="clearfix"><div><b>${nombre}</b></div></div></td>
    <td><div class="clearfix"><div>${categoria}</div></div></td>
    <td class="col-1"><div class="text-center"><b>${datos.cantidad}</b></div></td>
    <td class="col-1"><div class="text-center"><b>${datos.cantidad_disponible}</b></div></td>
    <td class="col-1"><div class="text-center"><b>${datos.herramienta_ocupada}</b></div></td>
    <td class="col-p text-center action-cell"><div class="tools-action-group" role="group" aria-label="Acciones de herramienta">${buttons.join('')}</div></td>
  `;
}

function toolCardHerramienta(dir, contador, datos, canEdit, canDelete) {
    const categoria = escapeHtml(datos.nombre_categoria || 'SIN CATEGORIA');
    const id = escapeHtml(datos.id_ai_herramienta);
    const nombre = escapeHtml(datos.nombre_herramienta || '');

    const buttons = [`
    <button type="button" class="btn btn-info text-white btn-sm js-tool-ocupaciones" title="Ver ocupaciones"
            data-bs-toggle="modal" data-bs-target="#herramientaOcupacionesModal" data-id="${id}" data-nombre="${nombre}">
      <i class="bi bi-diagram-3"></i>
    </button>`];

    if (canEdit) {
        buttons.push(`
    <a href="#" title="Modificar" class="btn btn-warning text-dark btn-sm"
       data-bs-toggle="modal" data-bs-target="#ventanaModalModificarHerr" data-bs-id="${id}">
      <i class="bi bi-pencil text-white"></i>
    </a>`);
    }

    if (canDelete) {
        buttons.push(`
    <button type="button" class="btn btn-danger btn-sm" title="Eliminar"
            onclick="eliminarHerramienta('${id}','${dir}', ${canEdit}, ${canDelete})">
      <i class="bi bi-trash"></i>
    </button>`);
    }

    return `
    <div class="tool-card">
      <div class="tool-card-head">
        <span class="tool-code">#${contador} - Codigo: ${id}</span>
        <span><b>Disp:</b> ${datos.cantidad_disponible}</span>
      </div>

      <div class="tool-body">
        <div class="tool-row">
          <div class="tool-label">Nombre</div>
          <div class="tool-value">${nombre}</div>
        </div>

        <div class="tool-row">
          <div class="tool-label">Categoria</div>
          <div class="tool-value">${categoria}</div>
        </div>

        <div class="tool-row">
          <div class="tool-label">Total</div>
          <div class="tool-value">${datos.cantidad}</div>
        </div>

        <div class="tool-row">
          <div class="tool-label">Ocupada</div>
          <div class="tool-value">${datos.herramienta_ocupada}</div>
        </div>

        <div class="tool-actions">
          <div class="tools-action-group" role="group" aria-label="Acciones de herramienta">${buttons.join('')}</div>
        </div>
      </div>
    </div>
  `;
}

function toolCardVacia() {
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

function eliminarHerramienta(parametro, dir, canEdit, canDelete) {
    Swal.fire({
        title: 'Estas seguro?',
        text: 'Quieres realizar la accion solicitada',
        icon: 'question',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Si, realizar',
        cancelButtonText: 'No, cancelar',
    }).then((result) => {
        if (!result.isConfirmed) return;

        $.ajax({
            url: dir + 'app/controllers/cargarDatosBuscadorTools.php',
            method: 'GET',
            dataType: 'json',
            data: { id: parametro, tipoBusqueda: 'eliminar' },
            success: function (data) {
                if (data) {
                    reiniciarTabla(dir, canEdit, canDelete);
                    const alerta = { tipo: 'simple', icono: 'success', titulo: 'Herramienta eliminada', texto: 'La herramienta ha sido eliminada con exito' };
                    alertas_ajax(alerta);
                } else {
                    const alerta = { tipo: 'simple', icono: 'error', titulo: 'Ocurrio un error inesperado', texto: 'No se pudo eliminar la herramienta' };
                    alertas_ajax(alerta);
                }
            },
            error: function (xhr, status, error) {
                console.error('Error:', error);
            }
        });
    });
}

function alerta(icono, texto, segundo) {
    const Toast = Swal.mixin({
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

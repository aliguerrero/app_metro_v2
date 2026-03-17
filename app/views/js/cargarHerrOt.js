$(document).ready(function () {

  $('#ModificarHerrOt').on('shown.bs.modal', function () {
    const dir = document.getElementById('url') ? document.getElementById('url').value : '';
    const codigoOth = ($('#codigoOth').text() || '').trim();

    // --- 1) Tabla herramientas asignadas a OT ---
    $.ajax({
      url: dir + 'app/controllers/cargarDatosBuscadorHOT.php',
      method: 'GET',
      dataType: 'json',
      data: { id: codigoOth, tipoBusqueda: 'cargarTabla' },
      success: function (data) {
        const tbody = document.getElementById('tablaHerramientaOt')?.getElementsByTagName('tbody')[0];
        if (!tbody) return;

        tbody.innerHTML = '';

        if (Array.isArray(data) && data.length > 0) {
          let contador = 1;
          data.forEach(function (datos) {
            const fila = tbody.insertRow();
            fila.classList.add('align-middle');

            // ✅ AJUSTA AQUÍ si tu backend devuelve id_herramienta en vez de id_ai_herramienta
            const idHerr = datos.id_ai_herramienta ?? datos.id_herramienta ?? '';

            fila.innerHTML = tablaHerramientaOT(
              dir,
              contador,
              datos.n_ot ?? codigoOth,
              idHerr,
              datos.nombre_herramienta ?? '',
              datos.cantidadot ?? 0
            );
            contador++;
          });
        } else {
          tbody.innerHTML = tablaVaciaRow(6);
        }
      },
      error: function (xhr, status, error) {
        console.error('Error:', error);
        const tbody = document.getElementById('tablaHerramientaOt')?.getElementsByTagName('tbody')[0];
        if (tbody) tbody.innerHTML = tablaVaciaRow(6);
      }
    });

    // --- 2) Tabla inventario completo ---
    $.ajax({
      url: dir + 'app/controllers/cargarDatosBuscadorHOT.php',
      method: 'GET',
      dataType: 'json',
      data: { tipoBusqueda: 'todoHer' },
      success: function (data) {
        const tbody = document.getElementById('tablaHerramienta')?.getElementsByTagName('tbody')[0];
        if (!tbody) return;

        tbody.innerHTML = '';

        if (Array.isArray(data) && data.length > 0) {
          let contador = 1;
          data.forEach(function (datos) {
            const fila = tbody.insertRow();
            fila.classList.add('align-middle');

            const idHerr = datos.id_ai_herramienta ?? datos.id_herramienta ?? '';

            fila.innerHTML = tablaHerramienta(
              dir,
              contador,
              codigoOth,
              idHerr,
              datos.nombre_herramienta ?? '',
              datos.cantidad_disponible ?? 0
            );
            contador++;
          });
        } else {
          tbody.innerHTML = tablaVaciaRow(6);
        }
      },
      error: function (xhr, status, error) {
        console.error('Error inventario:', error);
        const tbody = document.getElementById('tablaHerramienta')?.getElementsByTagName('tbody')[0];
        if (tbody) tbody.innerHTML = tablaVaciaRow(6);
      }
    });
  });

  $('#ModificarHerrOt').on('hidden.bs.modal', function () {
    $('#codigoOth').text('');

    const tbody1 = document.getElementById('tablaHerramientaOt')?.getElementsByTagName('tbody')[0];
    if (tbody1) tbody1.innerHTML = tablaVaciaRow(6);

    const tbody2 = document.getElementById('tablaHerramienta')?.getElementsByTagName('tbody')[0];
    if (tbody2) tbody2.innerHTML = tablaVaciaRow(6);
  });

});

function tablaHerramienta(dir, contador, n_ot, id_herramienta, nombre_herramienta, cantidad_disponible) {
  const op = 'mas';

  return `
    <td class="clearfix col-p"><b>${contador}</b></td>

    <td class="text-center col-p">
      <div class="avatar avatar-md">
        <img class="avatar-img" src="${dir}app/views/img/tools.png" alt="tool">
      </div>
    </td>

    <td class="col-2"><b>${id_herramienta}</b></td>

    <td><b>${nombre_herramienta}</b></td>

    <td class="col-2 text-center"><b>${cantidad_disponible}</b></td>

    <td class="col-p">
      <a href="#" title="Agregar" class="btn btn-success"
        onclick="agregarQuitarHerramienta('${op}','${n_ot}','${id_herramienta}','${dir}')">
        <i class="bx bx-plus fs-4" aria-hidden="true"></i>
      </a>
    </td>
  `;
}

// ✅ OJO: aquí NO debe venir <tr> ... </tr> porque ya lo crea insertRow()
function tablaHerramientaOT(dir, contador, n_ot, id_herramienta, nombre_herramienta, cantidadot) {
  const op = 'menos';

  return `
    <td class="col-p"><b>${contador}</b></td>

    <td class="text-center col-p">
      <div class="avatar avatar-md">
        <img class="avatar-img" src="${dir}app/views/img/tools.png" alt="tool">
      </div>
    </td>

    <td class="col-2"><b>${id_herramienta}</b></td>

    <td class="col-5"><b>${nombre_herramienta}</b></td>

    <td class="col-p text-center"><b>${cantidadot}</b></td>

    <td class="col-p">
      <a href="#" title="Quitar" class="btn btn-danger"
        onclick="agregarQuitarHerramienta('${op}','${n_ot}','${id_herramienta}','${dir}')">
        <i class="bx bx-minus fs-4" aria-hidden="true"></i>
      </a>
    </td>
  `;
}

function tablaVaciaRow(colspan) {
  return `
    <tr class="align-middle">
      <td class="text-center" colspan="${colspan}">No hay registros en el sistema</td>
    </tr>
  `;
}

/* herramientasOtModal.js */
document.addEventListener('DOMContentLoaded', () => {
  const dir = document.getElementById('url') ? document.getElementById('url').value : '';

  // OJO: si hay IDs duplicados, esto puede agarrar un <a> y no el modal.
  const modal = document.getElementById('ModificarHerrOt');
  if (!modal) return;

  // Validación fuerte: debe ser el DIV modal
  if (!modal.classList.contains('modal')) {
    console.error('[herramientasOtModal] El elemento con id="ModificarHerrOt" NO es el modal. Tienes IDs duplicados en botones/links.');
    return;
  }

  const urlOtInfo = dir + 'app/controllers/cargarDatosOt.php';
  const urlHerrOt = dir + 'app/controllers/cargarHerramientasOt.php'; // tu controlador

  // Elementos resumen
  const otCodigoBadge = modal.querySelector('#otCodigoBadge');
  const otNombreBadge = modal.querySelector('#otNombreBadge');
  const otCodigoHidden = modal.querySelector('#otCodigoHidden');

  // Buscadores
  const invSearch = modal.querySelector('#invSearch');
  const asigSearch = modal.querySelector('#asigSearch');

  // Contadores
  const invCount = modal.querySelector('#invCount');
  const asigCount = modal.querySelector('#asigCount');

  // Tablas / Cards
  const invTableBody = modal.querySelector('#invTable tbody');
  const asigTableBody = modal.querySelector('#asigTable tbody');
  const invCards = modal.querySelector('#invCards');
  const asigCards = modal.querySelector('#asigCards');

  // Botones
  const btnInvReload = modal.querySelector('#btnInvReload');
  const btnAsigReload = modal.querySelector('#btnAsigReload');
  const invClear = modal.querySelector('#invClear');
  const asigClear = modal.querySelector('#asigClear');

  // Validación mínima del layout
  const essentialsOk =
    otCodigoBadge && otNombreBadge && otCodigoHidden &&
    invSearch && asigSearch &&
    invCount && asigCount &&
    invTableBody && asigTableBody &&
    invCards && asigCards;

  if (!essentialsOk) {
    console.error('[herramientasOtModal] Faltan elementos en el DOM dentro del modal. Revisa que el HTML sea el del layout nuevo (IDs invTable/asigTable/etc.).');
    return;
  }

  let tInv = null;
  let tAsig = null;

  function escapeHtml(str) {
    return String(str ?? '')
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#039;');
  }

  function showAlert(payload, fallback = { icono: 'error', titulo: 'Aviso', texto: 'Intenta nuevamente.' }) {
    if (typeof alertas_ajax === 'function' && payload && payload.tipo) return alertas_ajax(payload);

    return Swal.fire({
      icon: payload?.icono || fallback.icono || 'error',
      title: payload?.titulo || fallback.titulo || 'Aviso',
      text: payload?.texto || fallback.texto || 'Intenta nuevamente.'
    });
  }

  async function fetchJson(url, params, method = 'GET') {
    const opt = {
      method,
      headers: { 'Accept': 'application/json', 'X-Requested-With': 'XMLHttpRequest' }
    };

    let finalUrl = url;

    if (method === 'POST') {
      opt.headers['Content-Type'] = 'application/x-www-form-urlencoded; charset=UTF-8';
      opt.body = params;
    } else {
      finalUrl = url + '?' + params.toString();
    }

    const res = await fetch(finalUrl, opt);
    const text = await res.text();

    let payload = null;
    try {
      payload = JSON.parse(text);
    } catch (e) {
      console.error('[herramientasOtModal] NO JSON:', text.slice(0, 900));
      return {
        ok: false,
        payload: { tipo: 'simple', icono: 'error', titulo: 'Respuesta inválida', texto: 'El servidor devolvió una respuesta inesperada.' }
      };
    }

    return { ok: res.ok, payload };
  }

  async function cargarResumenOt(n_ot) {
    const fd = new FormData();
    fd.append('id', n_ot);

    try {
      const r = await fetch(urlOtInfo, { method: 'POST', body: fd });
      const payload = await r.json();
      const data = payload?.data ?? payload;

      otCodigoBadge.textContent = data?.n_ot ?? n_ot;
      otNombreBadge.textContent = data?.nombre_trab ?? '—';
      otCodigoHidden.value = data?.n_ot ?? n_ot;
    } catch (e) {
      otCodigoBadge.textContent = n_ot;
      otNombreBadge.textContent = '—';
      otCodigoHidden.value = n_ot;
    }
  }

  function renderInventario(data) {
    invCount.textContent = String(data.length || 0);

    invTableBody.innerHTML = '';
    invCards.innerHTML = '';

    if (!Array.isArray(data) || !data.length) {
      invTableBody.innerHTML = `<tr><td colspan="6" class="text-center">No hay registros</td></tr>`;
      invCards.innerHTML = `<div class="text-muted text-center py-3">No hay registros</div>`;
      return;
    }

    data.forEach((x, i) => {
      const disp = Number(x.disponible_total || 0);
      const enOt = Number(x.en_ot || 0);
      const maxAdd = Number(x.disponible_para_agregar || 0);

      invTableBody.insertAdjacentHTML('beforeend', `
        <tr class="align-middle">
          <td class="col-p"><b>${i + 1}</b></td>
          <td class="col-p"><b>${escapeHtml(x.id)}</b></td>
          <td><b>${escapeHtml(x.nombre)}</b></td>
          <td class="text-center col-p"><b>${disp}</b></td>
          <td class="text-center col-p"><b>${enOt}</b></td>
          <td class="text-center col-p">
            <button type="button" class="btn btn-success btn-sm js-asignar"
              data-id="${escapeHtml(x.id)}"
              data-nombre="${escapeHtml(x.nombre)}"
              data-max="${maxAdd}">
              <i class="bi bi-plus-lg"></i>
            </button>
          </td>
        </tr>
      `);

      invCards.insertAdjacentHTML('beforeend', `
        <div class="border rounded p-2 mb-2">
          <div class="d-flex justify-content-between align-items-start">
            <div>
              <div class="fw-bold">#${i + 1} • ${escapeHtml(x.id)}</div>
              <div>${escapeHtml(x.nombre)}</div>
              <div class="small text-muted">Disp: <b>${disp}</b> • En OT: <b>${enOt}</b></div>
            </div>
            <button type="button" class="btn btn-success btn-sm js-asignar"
              data-id="${escapeHtml(x.id)}"
              data-nombre="${escapeHtml(x.nombre)}"
              data-max="${maxAdd}">
              <i class="bi bi-plus-lg"></i>
            </button>
          </div>
        </div>
      `);
    });
  }

  function renderAsignadas(data) {
    asigCount.textContent = String(data.length || 0);

    asigTableBody.innerHTML = '';
    asigCards.innerHTML = '';

    if (!Array.isArray(data) || !data.length) {
      asigTableBody.innerHTML = `<tr><td colspan="5" class="text-center">No hay herramientas asignadas</td></tr>`;
      asigCards.innerHTML = `<div class="text-muted text-center py-3">No hay herramientas asignadas</div>`;
      return;
    }

    data.forEach((x, i) => {
      asigTableBody.insertAdjacentHTML('beforeend', `
        <tr class="align-middle">
          <td class="col-p"><b>${i + 1}</b></td>
          <td class="col-p"><b>${escapeHtml(x.id)}</b></td>
          <td><b>${escapeHtml(x.nombre)}</b></td>
          <td class="text-center col-p"><b>${escapeHtml(x.cantidad)}</b></td>
          <td class="text-center col-p">
            <button type="button" class="btn btn-outline-warning text-dark btn-sm js-editar"
              data-id="${escapeHtml(x.id)}"
              data-nombre="${escapeHtml(x.nombre)}"
              data-cant="${escapeHtml(x.cantidad)}">
              <i class="bi bi-pencil text-white"></i>
            </button>
            <button type="button" class="btn btn-outline-danger btn-sm js-quitar"
              data-id="${escapeHtml(x.id)}"
              data-nombre="${escapeHtml(x.nombre)}">
              <i class="bi bi-dash-lg"></i>
            </button>
          </td>
        </tr>
      `);

      asigCards.insertAdjacentHTML('beforeend', `
        <div class="border rounded p-2 mb-2">
          <div class="fw-bold">#${i + 1} • ${escapeHtml(x.id)}</div>
          <div>${escapeHtml(x.nombre)}</div>
          <div class="small text-muted mb-2">Cantidad: <b>${escapeHtml(x.cantidad)}</b></div>
          <div class="d-flex gap-2">
            <button type="button" class="btn btn-outline-warning text-dark btn-sm js-editar"
              data-id="${escapeHtml(x.id)}"
              data-nombre="${escapeHtml(x.nombre)}"
              data-cant="${escapeHtml(x.cantidad)}">
              <i class="bi bi-pencil text-white"></i> Editar
            </button>
            <button type="button" class="btn btn-outline-danger btn-sm js-quitar"
              data-id="${escapeHtml(x.id)}"
              data-nombre="${escapeHtml(x.nombre)}">
              <i class="bi bi-dash-lg"></i> Quitar
            </button>
          </div>
        </div>
      `);
    });
  }

  async function cargarInventario() {
    const ot = otCodigoHidden.value;
    const q = String(invSearch.value || '').trim();

    const params = new URLSearchParams();
    params.append('tipo', 'inventario');
    params.append('ot', ot);
    params.append('q', q);

    const { ok, payload } = await fetchJson(urlHerrOt, params, 'GET');
    if (!ok || payload?.ok === false) return showAlert(payload);
    renderInventario(payload.data || []);
  }

  async function cargarAsignadas() {
    const ot = otCodigoHidden.value;
    const q = String(asigSearch.value || '').trim();

    const params = new URLSearchParams();
    params.append('tipo', 'asignadas');
    params.append('ot', ot);
    params.append('q', q);

    const { ok, payload } = await fetchJson(urlHerrOt, params, 'GET');
    if (!ok || payload?.ok === false) return showAlert(payload);
    renderAsignadas(payload.data || []);
  }

  async function accionPOST(tipo, extra = {}) {
    const params = new URLSearchParams();
    params.append('tipo', tipo);
    params.append('ot', otCodigoHidden.value);

    Object.entries(extra).forEach(([k, v]) => params.append(k, String(v)));

    const { ok, payload } = await fetchJson(urlHerrOt, params, 'POST');
    if (!ok || payload?.ok === false) {
      showAlert(payload, { icono: 'error', titulo: 'No se pudo completar', texto: 'Intenta nuevamente.' });
      return false;
    }

    if (payload?.tipo) showAlert(payload);
    return true;
  }

  // Abrir modal: cargar OT + listas
  modal.addEventListener('show.bs.modal', async (event) => {
    const btn = event.relatedTarget;
    const ot = btn ? btn.getAttribute('data-bs-id') : '';
    if (!ot) return;

    invSearch.value = '';
    asigSearch.value = '';

    await cargarResumenOt(ot);
    await Promise.all([cargarInventario(), cargarAsignadas()]);
  });

  // binds seguros
  if (btnInvReload) btnInvReload.addEventListener('click', () => cargarInventario());
  if (btnAsigReload) btnAsigReload.addEventListener('click', () => cargarAsignadas());

  if (invClear) invClear.addEventListener('click', () => { invSearch.value = ''; cargarInventario(); });
  if (asigClear) asigClear.addEventListener('click', () => { asigSearch.value = ''; cargarAsignadas(); });

  invSearch.addEventListener('input', () => {
    clearTimeout(tInv);
    tInv = setTimeout(cargarInventario, 250);
  });

  asigSearch.addEventListener('input', () => {
    clearTimeout(tAsig);
    tAsig = setTimeout(cargarAsignadas, 250);
  });

  // Delegación: acciones
  modal.addEventListener('click', async (e) => {
    const btnAsignar = e.target.closest('.js-asignar');
    if (btnAsignar) {
      const id = btnAsignar.dataset.id;
      const nombre = btnAsignar.dataset.nombre;
      const max = Number(btnAsignar.dataset.max || 0);

      if (max <= 0) {
        return Swal.fire({ icon: 'info', title: 'Sin disponibilidad', text: 'No hay cantidad disponible para asignar.' });
      }

      const r = await Swal.fire({
        icon: 'question',
        title: 'Asignar herramienta',
        html: `<div style="text-align:left">
          <div><b>${escapeHtml(id)}</b> • ${escapeHtml(nombre)}</div>
          <div class="text-muted" style="margin-top:6px">Disponible para agregar: <b>${max}</b></div>
        </div>`,
        input: 'number',
        inputLabel: 'Cantidad a asignar',
        inputValue: 1,
        inputAttributes: { min: 1, max: max, step: 1 },
        showCancelButton: true,
        confirmButtonText: 'Asignar',
        cancelButtonText: 'Cancelar',
        preConfirm: (v) => {
          const n = Number(v);
          if (!Number.isInteger(n) || n < 1) return Swal.showValidationMessage('Ingresa una cantidad válida.');
          if (n > max) return Swal.showValidationMessage('La cantidad supera la disponibilidad.');
          return n;
        }
      });

      if (!r.isConfirmed) return;

      const ok = await accionPOST('agregar', { herramienta_id: id, cant: r.value });
      if (ok) await Promise.all([cargarInventario(), cargarAsignadas()]);
      return;
    }

    const btnEditar = e.target.closest('.js-editar');
    if (btnEditar) {
      const id = btnEditar.dataset.id;
      const nombre = btnEditar.dataset.nombre;
      const actual = Number(btnEditar.dataset.cant || 0);

      const r = await Swal.fire({
        icon: 'question',
        title: 'Editar cantidad',
        html: `<div style="text-align:left"><b>${escapeHtml(id)}</b> • ${escapeHtml(nombre)}</div>`,
        input: 'number',
        inputLabel: 'Nueva cantidad',
        inputValue: actual,
        inputAttributes: { min: 0, step: 1 },
        showCancelButton: true,
        confirmButtonText: 'Guardar',
        cancelButtonText: 'Cancelar',
        preConfirm: (v) => {
          const n = Number(v);
          if (!Number.isInteger(n) || n < 0) return Swal.showValidationMessage('Ingresa una cantidad válida (0 o más).');
          return n;
        }
      });

      if (!r.isConfirmed) return;

      const ok = await accionPOST('actualizar', { herramienta_id: id, cant: r.value });
      if (ok) await Promise.all([cargarInventario(), cargarAsignadas()]);
      return;
    }

    const btnQuitar = e.target.closest('.js-quitar');
    if (btnQuitar) {
      const id = btnQuitar.dataset.id;
      const nombre = btnQuitar.dataset.nombre;

      const r = await Swal.fire({
        icon: 'warning',
        title: 'Quitar herramienta',
        text: `Se quitará ${id} - ${nombre} de esta O.T.`,
        showCancelButton: true,
        confirmButtonText: 'Sí, quitar',
        cancelButtonText: 'Cancelar'
      });

      if (!r.isConfirmed) return;

      const ok = await accionPOST('quitar', { herramienta_id: id });
      if (ok) await Promise.all([cargarInventario(), cargarAsignadas()]);
    }
  });
});

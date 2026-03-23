/* cargarVentanaDetalle.js */
document.addEventListener('DOMContentLoaded', function () {
  const dir = document.getElementById('url') ? document.getElementById('url').value : '';
  const listModal = document.getElementById('detallesOt');
  const formModalEl = document.getElementById('detalleOtFormModal');
  const form = document.getElementById('formDetalleOt');

  if (!listModal || !formModalEl || !form) return;

  const btnRecargarDetalle = document.getElementById('btnRecargarDetalle');
  const btnCrear = document.getElementById('btnNuevoDetalleOt');
  const btnGuardar = document.getElementById('btnGuardarDetalleOt');
  const lockNotice = document.getElementById('detalleOtLockNotice');
  const metaOt = document.getElementById('metaOt');
  const modoEdicionLabel = document.getElementById('modoEdicionLabel');
  const formTitle = document.getElementById('detalleOtFormModalLabel');
  const detalleFormCodigoOt = document.getElementById('detalleFormCodigoOt');
  const detalleFormMeta = document.getElementById('detalleFormMeta');

  const urlCargarOt = dir + 'app/controllers/cargarDatosOt.php';
  const urlCargarDetalles = dir + 'app/controllers/cargarDatosDetalles.php';
  const urlDetalleAccion = dir + 'app/controllers/cargarDatosDetalle.php';

  let submitInFlight = false;
  let formMode = 'new';

  const FIELD_LABELS = {
    codigo: 'Codigo O.T.',
    fecha: 'Fecha',
    desc: 'Descripcion',
    cant: 'Cantidad de operadores',
    turno: 'Turno',
    cco: 'CCO',
    ccf: 'CCF',
    tec: 'Tecnico',
    hora_inicio: 'Hora de inicio',
    hora_fin: 'Hora de fin',
    observacion: 'Observacion'
  };

  function getFormModalInstance() {
    return bootstrap.Modal.getOrCreateInstance(formModalEl);
  }

  function pick(root, ...selectors) {
    for (const s of selectors) {
      const el = root.querySelector(s);
      if (el) return el;
    }
    return null;
  }

  function setVal(el, value, fallback = '') {
    if (!el) return;
    el.value = value ?? fallback;
  }

  function getValue(sel) {
    return String(pick(formModalEl, sel)?.value || '').trim();
  }

  function isYmd(v) {
    return /^\d{4}-\d{2}-\d{2}$/.test(String(v || ''));
  }

  function escapeHtml(str) {
    return String(str ?? '')
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#039;');
  }

  function escapeAttr(str) {
    return escapeHtml(str);
  }

  function unwrapList(payload) {
    if (Array.isArray(payload)) return { ok: true, data: payload };
    if (payload && typeof payload === 'object' && Array.isArray(payload.data)) {
      return { ok: !!payload.ok, data: payload.data };
    }
    return { ok: false, data: [] };
  }

  function toHtmlMultiline(txt) {
    return escapeHtml(String(txt || '')).replace(/\n/g, '<br>');
  }

  function formatearFecha(fecha) {
    if (!fecha) return '';
    const partes = String(fecha).split('-');
    if (partes.length !== 3) return fecha;
    return `${partes[2]}/${partes[1]}/${partes[0]}`;
  }

  function codigoOtActual() {
    return (document.getElementById('codigoOt')?.textContent ?? '').trim();
  }

  function otActualFinalizada() {
    return String(listModal.dataset.otFinalizada || '0') === '1';
  }

  function syncFormOtBadge() {
    const codigo = codigoOtActual() || '-';
    if (detalleFormCodigoOt) detalleFormCodigoOt.textContent = codigo;
  }

  function setFormReadonly(readonly) {
    form.querySelectorAll('input, select, textarea').forEach((field) => {
      if (field.type === 'hidden') return;
      field.disabled = readonly;
    });

    if (btnGuardar) {
      btnGuardar.disabled = readonly;
      btnGuardar.classList.toggle('d-none', readonly);
    }
  }

  function updateFormChrome(mode, readonly) {
    formMode = mode;
    syncFormOtBadge();

    if (formTitle) {
      formTitle.textContent = mode === 'view'
        ? 'Ver detalle'
        : (mode === 'edit' ? 'Editar detalle' : 'Registrar detalle');
    }

    if (modoEdicionLabel) {
      modoEdicionLabel.textContent = readonly
        ? 'Consulta'
        : (mode === 'edit' ? 'Edicion' : 'Nuevo');
    }

    if (detalleFormMeta) {
      detalleFormMeta.textContent = readonly
        ? 'Consulta del detalle seleccionado. Los campos estan en solo lectura.'
        : (mode === 'edit'
          ? 'Actualiza el detalle seleccionado.'
          : 'Completa la informacion del detalle.');
    }

    setFormReadonly(readonly);
  }

  function setOtFinalizadaState(finalizada) {
    const locked = !!finalizada;
    listModal.dataset.otFinalizada = locked ? '1' : '0';

    if (lockNotice) {
      lockNotice.classList.toggle('d-none', !locked);
    }

    if (btnCrear) {
      btnCrear.disabled = locked;
      btnCrear.classList.toggle('disabled', locked);
      btnCrear.title = locked ? 'La O.T. esta bloqueada' : 'Registrar nuevo detalle';
    }

    if (metaOt) {
      metaOt.textContent = locked
        ? 'O.T. bloqueada. Solo se permite consultar los detalles existentes.'
        : '';
    }

    if (locked && bootstrap.Modal.getInstance(formModalEl)) {
      updateFormChrome('view', true);
    }
  }

  function showAlertFromBackend(payload, fallback = {}) {
    if (typeof alertas_ajax === 'function' && payload && payload.tipo) {
      alertas_ajax(payload);
      return;
    }

    if (payload && payload.tipo === 'simple') {
      if (Array.isArray(payload.missing_labels) && payload.missing_labels.length) {
        const items = payload.missing_labels.map(x => `<li>${escapeHtml(x)}</li>`).join('');
        return Swal.fire({
          icon: payload.icono || 'info',
          title: payload.titulo || fallback.title || 'Aviso',
          html: `
            <div style="text-align:left">
              <p style="margin-bottom:8px">${toHtmlMultiline(payload.texto || '')}</p>
              <ul style="margin:0; padding-left:18px;">${items}</ul>
            </div>
          `
        });
      }

      return Swal.fire({
        icon: payload.icono || 'info',
        title: payload.titulo || fallback.title || 'Aviso',
        html: toHtmlMultiline(payload.texto || fallback.text || '')
      });
    }

    const msg = payload?.texto || payload?.message || fallback.text || 'Intenta nuevamente.';
    return Swal.fire({
      icon: fallback.icon || 'error',
      title: fallback.title || 'No se pudo completar la accion',
      html: toHtmlMultiline(msg)
    });
  }

  function showMissingFieldsAlert(missingKeys, titulo = 'Faltan datos') {
    const pretty = missingKeys.map(k => FIELD_LABELS[k] || k);
    const items = pretty.map(x => `<li>${escapeHtml(x)}</li>`).join('');

    return Swal.fire({
      icon: 'warning',
      title: titulo,
      html: `
        <div style="text-align:left">
          <p style="margin-bottom:8px">Completa los siguientes campos antes de guardar:</p>
          <ul style="margin:0; padding-left:18px;">${items}</ul>
          <p style="margin-top:10px; margin-bottom:0"><b>Observacion</b> es el unico campo opcional.</p>
        </div>
      `
    });
  }

  function validateBeforeSave() {
    if (otActualFinalizada()) {
      Swal.fire({
        icon: 'info',
        title: 'O.T. bloqueada',
        text: 'La O.T. esta bloqueada. Solo puedes consultar los detalles existentes.'
      });
      return { ok: false };
    }

    const codigo = String(pick(formModalEl, '#id', '[name="codigo"]')?.value || '').trim();
    const idDetalle = String(pick(formModalEl, '#id2', '[name="id"]')?.value || '').trim();
    const missing = [];

    if (!codigo) missing.push('codigo');

    const fecha = getValue('#fecha');
    if (!fecha) missing.push('fecha');
    else if (!isYmd(fecha)) {
      Swal.fire({ icon: 'warning', title: 'Fecha invalida', text: 'Selecciona una fecha valida.' });
      return { ok: false };
    }

    if (!getValue('#desc')) missing.push('desc');
    if (!getValue('#cant')) missing.push('cant');
    if (!getValue('#turno')) missing.push('turno');
    if (!getValue('#cco')) missing.push('cco');
    if (!getValue('#ccf')) missing.push('ccf');
    if (!getValue('#tec')) missing.push('tec');
    if (!getValue('#hora_inicio')) missing.push('hora_inicio');
    if (!getValue('#hora_fin')) missing.push('hora_fin');

    if (formMode === 'edit' && !idDetalle) {
      Swal.fire({
        icon: 'error',
        title: 'No se pudo actualizar',
        text: 'No se identifico el detalle a modificar. Seleccionalo nuevamente desde la lista.'
      });
      return { ok: false };
    }

    if (missing.length) {
      showMissingFieldsAlert(missing);
      return { ok: false };
    }

    return { ok: true, codigo, idDetalle };
  }

  async function fetchJsonSafe(url, bodyParams) {
    const res = await fetch(url, {
      method: 'POST',
      credentials: 'same-origin',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest'
      },
      body: bodyParams
    });

    const text = await res.text();

    if (!text) {
      console.error('Respuesta vacia', { url, status: res.status });
      return {
        res,
        payload: {
          ok: false,
          tipo: 'simple',
          titulo: 'Sin respuesta del servidor',
          texto: 'No se recibio respuesta. Intenta nuevamente.',
          icono: 'error'
        }
      };
    }

    let payload = null;
    try {
      payload = JSON.parse(text);
    } catch (e) {
      console.error('Respuesta NO JSON (primeros 1500 chars):\n', text.slice(0, 1500));
      return {
        res,
        payload: {
          ok: false,
          tipo: 'simple',
          titulo: 'Respuesta invalida',
          texto: 'El servidor devolvio una respuesta inesperada. Intenta nuevamente o contacta al administrador.',
          icono: 'error'
        }
      };
    }

    if (!res.ok) console.error('HTTP', res.status, payload);
    return { res, payload };
  }

  function resetFormFields() {
    setVal(pick(formModalEl, '#id2', '[name="id"]'), '');

    ['fecha', 'desc', 'cant', 'hora_inicio', 'hora_fin', 'observacion']
      .forEach(id => setVal(pick(formModalEl, `#${id}`), ''));

    ['turno', 'tec', 'cco', 'ccf']
      .forEach(id => setVal(pick(formModalEl, `#${id}`, `[name="${id}"]`), ''));
  }

  function fillDetail(detail, fallback) {
    const realId = String(detail?.id_ai_detalle ?? detail?.id_detalle ?? detail?.id ?? fallback.id);

    setVal(pick(formModalEl, '#id', '[name="codigo"]'), detail.n_ot ?? fallback.codigo, '');
    setVal(pick(formModalEl, '#id2', '[name="id"]'), realId, '');
    setVal(pick(formModalEl, '#fecha', '[name="fecha"]'), detail.fecha ?? fallback.fecha, '');
    setVal(pick(formModalEl, '#desc', '[name="desc"]'), detail.descripcion ?? '', '');
    setVal(pick(formModalEl, '#cant', '[name="cant"]'), detail.cant_tec ?? '', '');
    setVal(pick(formModalEl, '#turno', '[name="turno"]'), detail.id_ai_turno ?? '', '');
    setVal(pick(formModalEl, '#cco', '[name="cco"]'), detail.id_miembro_cco ?? '', '');
    setVal(pick(formModalEl, '#ccf', '[name="ccf"]'), detail.id_miembro_ccf ?? '', '');
    setVal(pick(formModalEl, '#tec', '[name="tec"]'), detail.id_user_act ?? '', '');

    const horaInicio = detail.hora_inicio ?? detail.hora_ini_pre ?? detail.hora_ini_tra ?? detail.hora_ini_eje ?? '';
    const horaFin = detail.hora_fin ?? detail.hora_fin_eje ?? detail.hora_fin_tra ?? detail.hora_fin_pre ?? '';

    setVal(pick(formModalEl, '#hora_inicio', '[name="hora_inicio"]'), horaInicio, '');
    setVal(pick(formModalEl, '#hora_fin', '[name="hora_fin"]'), horaFin, '');
    setVal(pick(formModalEl, '#observacion', '[name="observacion"]'), detail.observacion ?? '', '');
  }

  async function cargarDetalle(id, fecha, codigo) {
    if (!id || !fecha || !codigo || !isYmd(fecha)) {
      return null;
    }

    const body = new URLSearchParams();
    body.append('tipo', 'ver');
    body.append('id', id);
    body.append('fecha', fecha);
    body.append('codigo', codigo);

    const { res, payload } = await fetchJsonSafe(urlDetalleAccion, body);
    if (!res.ok) {
      showAlertFromBackend(payload, { title: 'No se pudo cargar el detalle', text: 'Intenta nuevamente.' });
      return null;
    }

    return payload?.data ?? payload;
  }

  async function abrirFormularioDetalle(mode, detailRef = null) {
    const codigo = detailRef?.codigo || codigoOtActual();
    if (!codigo) return;

    if (mode === 'new' && otActualFinalizada()) {
      Swal.fire({
        icon: 'info',
        title: 'O.T. bloqueada',
        text: 'La O.T. esta bloqueada. No se pueden registrar nuevos detalles.'
      });
      return;
    }

    resetFormFields();
    setVal(pick(formModalEl, '#id', '[name="codigo"]'), codigo, '');
    syncFormOtBadge();

    if (mode === 'new') {
      updateFormChrome('new', false);
      getFormModalInstance().show();
      setTimeout(() => pick(formModalEl, '#fecha')?.focus(), 150);
      return;
    }

    const detail = await cargarDetalle(detailRef.id, detailRef.fecha, codigo);
    if (!detail) return;

    fillDetail(detail, detailRef);

    const readonly = mode === 'view' || otActualFinalizada();
    updateFormChrome(mode, readonly);
    getFormModalInstance().show();
    setTimeout(() => pick(formModalEl, '#fecha')?.focus(), 150);
  }

  function buildActionButton(kind, attrs, disabled = false) {
    const data = `data-id="${escapeAttr(attrs.id)}" data-fecha="${escapeAttr(attrs.fecha)}" data-ot="${escapeAttr(attrs.ot)}"`;

    if (kind === 'view') {
      return `
        <button type="button" class="btn btn-info text-white btn-sm js-view-detalle" title="Ver" ${data}>
          <i class="bi bi-eye"></i>
        </button>
      `;
    }

    if (kind === 'edit') {
      if (disabled) {
        return `
          <button type="button" class="btn btn-secondary btn-sm" title="O.T. bloqueada" disabled>
            <i class="bi bi-pencil"></i>
          </button>
        `;
      }

      return `
        <button type="button" class="btn btn-warning text-dark btn-sm js-edit-detalle" title="Editar" ${data}>
          <i class="bi bi-pencil text-white"></i>
        </button>
      `;
    }

    if (disabled) {
      return `
        <button type="button" class="btn btn-secondary btn-sm" title="O.T. bloqueada" disabled>
          <i class="bi bi-trash"></i>
        </button>
      `;
    }

    return `
      <button type="button" class="btn btn-danger btn-sm js-del-detalle" title="Eliminar" ${data}>
        <i class="bi bi-trash"></i>
      </button>
    `;
  }

  function buildRowDetalle(contador, d) {
    const fechaRaw = d.fecha ?? '';
    const fecha = fechaRaw ? formatearFecha(fechaRaw) : '-';
    const descripcion = escapeHtml(d.descripcion ?? d.desc ?? '-');
    const tecnico = escapeHtml(d.user ?? d.nombre_empleado ?? d.id_user_act ?? '-');
    const attrs = {
      id: d.id_detalle ?? d.id_ai_detalle ?? d.id ?? '',
      fecha: fechaRaw,
      ot: d.n_ot ?? codigoOtActual()
    };
    const bloqueada = otActualFinalizada();

    return `
      <td class="col-p"><b>${contador}</b></td>
      <td class="col-1"><b>${fecha}</b></td>
      <td class="col-5"><b>${descripcion}</b></td>
      <td class="col-2">${tecnico}</td>
      <td class="col-p text-center">${buildActionButton('view', attrs)}</td>
      <td class="col-p text-center">${buildActionButton('edit', attrs, bloqueada)}</td>
      <td class="col-p text-center">${buildActionButton('delete', attrs, bloqueada)}</td>
    `;
  }

  function buildCardDetalle(contador, d) {
    const fechaRaw = d.fecha ?? '';
    const fecha = fechaRaw ? formatearFecha(fechaRaw) : '-';
    const descripcion = escapeHtml(d.descripcion ?? d.desc ?? '-');
    const tecnico = escapeHtml(d.user ?? d.nombre_empleado ?? d.id_user_act ?? '-');
    const attrs = {
      id: d.id_detalle ?? d.id_ai_detalle ?? d.id ?? '',
      fecha: fechaRaw,
      ot: d.n_ot ?? codigoOtActual()
    };
    const bloqueada = otActualFinalizada();

    return `
      <div class="tool-card">
        <div class="tool-card-head">
          <span class="tool-code">#${contador} - ${fecha}</span>
          <span class="badge bg-light text-dark">Detalle</span>
        </div>
        <div class="tool-body">
          <div class="tool-row">
            <div class="tool-label">Descripcion</div>
            <div class="tool-value">${descripcion}</div>
          </div>
          <div class="tool-row">
            <div class="tool-label">Tecnico</div>
            <div class="tool-value">${tecnico}</div>
          </div>
          <div class="tool-actions">
            ${buildActionButton('view', attrs)}
            ${buildActionButton('edit', attrs, bloqueada)}
            ${buildActionButton('delete', attrs, bloqueada)}
          </div>
        </div>
      </div>
    `;
  }

  function renderDetallesTable(data, empty = false) {
    const table = document.getElementById('tablaDetalles');
    if (!table) return;
    const tbody = table.querySelector('tbody');
    if (!tbody) return;

    tbody.innerHTML = '';
    if (empty || !Array.isArray(data) || data.length === 0) {
      tbody.innerHTML = '<tr class="align-middle"><td class="text-center" colspan="7">No hay registros en el sistema</td></tr>';
      return;
    }

    let c = 1;
    data.forEach((d) => {
      const tr = document.createElement('tr');
      tr.className = 'align-middle';
      tr.innerHTML = buildRowDetalle(c++, d);
      tbody.appendChild(tr);
    });
  }

  function renderDetallesCards(data, empty = false) {
    const wrap = document.getElementById('detalleCards');
    if (!wrap) return;

    if (empty || !Array.isArray(data) || data.length === 0) {
      wrap.innerHTML = '<div class="tool-card"><div class="tool-card-head"><span class="tool-code">Sin registros</span><span>-</span></div></div>';
      return;
    }

    let c = 1;
    wrap.innerHTML = data.map(d => buildCardDetalle(c++, d)).join('');
  }

  function reiniciarTabla() {
    const codigoOt = codigoOtActual();
    if (!codigoOt) {
      renderDetallesTable([], true);
      renderDetallesCards([], true);
      return;
    }

    $.ajax({
      url: urlCargarDetalles,
      method: 'GET',
      dataType: 'json',
      data: { id: codigoOt, tipoBusqueda: 'cargarTabla' },
      success: function (payload) {
        const { ok, data } = unwrapList(payload);
        if (ok && data.length) {
          renderDetallesTable(data, false);
          renderDetallesCards(data, false);
        } else {
          renderDetallesTable([], true);
          renderDetallesCards([], true);
        }
      },
      error: function () {
        renderDetallesTable([], true);
        renderDetallesCards([], true);
      }
    });
  }

  async function eliminarDetalles(id, fecha, codigo) {
    if (!id || !fecha || !codigo) return;

    if (otActualFinalizada()) {
      Swal.fire({
        icon: 'info',
        title: 'O.T. bloqueada',
        text: 'La O.T. esta bloqueada. Los detalles solo se pueden consultar.'
      });
      return;
    }

    const r = await Swal.fire({
      title: 'Eliminar detalle?',
      text: 'Se eliminara el registro seleccionado.',
      icon: 'warning',
      showCancelButton: true,
      confirmButtonText: 'Si, eliminar',
      cancelButtonText: 'Cancelar'
    });

    if (!r.isConfirmed) return;

    const body = new URLSearchParams();
    body.append('tipo', 'eliminar');
    body.append('id', id);
    body.append('fecha', fecha);
    body.append('codigo', codigo);

    const { res, payload } = await fetchJsonSafe(urlDetalleAccion, body);
    if (!res.ok || payload?.ok === false) {
      showAlertFromBackend(payload, {
        title: 'No se pudo eliminar',
        text: 'No fue posible eliminar el detalle. Intenta nuevamente.'
      });
      return;
    }

    Swal.fire({ icon: 'success', title: 'Eliminado', text: 'Detalle eliminado correctamente.' });
    resetFormFields();
    reiniciarTabla();
  }

  listModal.addEventListener('click', function (e) {
    const viewBtn = e.target.closest('.js-view-detalle');
    if (viewBtn) {
      abrirFormularioDetalle('view', {
        id: viewBtn.dataset.id || '',
        fecha: viewBtn.dataset.fecha || '',
        codigo: viewBtn.dataset.ot || ''
      });
      return;
    }

    const editBtn = e.target.closest('.js-edit-detalle');
    if (editBtn) {
      abrirFormularioDetalle('edit', {
        id: editBtn.dataset.id || '',
        fecha: editBtn.dataset.fecha || '',
        codigo: editBtn.dataset.ot || ''
      });
      return;
    }

    const delBtn = e.target.closest('.js-del-detalle');
    if (delBtn) {
      eliminarDetalles(delBtn.dataset.id || '', delBtn.dataset.fecha || '', delBtn.dataset.ot || '');
    }
  });

  listModal.addEventListener('show.bs.modal', function (event) {
    const button = event.relatedTarget;
    const idBtn = button ? button.getAttribute('data-bs-id') : null;
    if (!idBtn) return;

    const codigoOtEl = listModal.querySelector('#codigoOt');
    const nombreOtEl = listModal.querySelector('#nombreOt');
    const inputCodigo = formModalEl.querySelector('#id');
    const inputId2 = formModalEl.querySelector('#id2');

    setOtFinalizadaState(false);

    const fd = new FormData();
    fd.append('id', idBtn);

    fetch(urlCargarOt, { method: 'POST', body: fd })
      .then(r => r.json())
      .then(payload => {
        const data = payload?.data ?? payload;
        if (!data) return;

        const finalizada = Number(data.ot_finalizada || 0) === 1;

        if (codigoOtEl) codigoOtEl.textContent = data.n_ot ?? '';
        if (nombreOtEl) nombreOtEl.textContent = data.nombre_trab ?? '';

        setVal(inputCodigo, data.n_ot ?? '');
        setVal(inputId2, '');
        syncFormOtBadge();
        resetFormFields();
        setOtFinalizadaState(finalizada);
        reiniciarTabla();
      })
      .catch(console.error);
  });

  listModal.addEventListener('shown.bs.modal', function () {
    if (codigoOtActual()) {
      reiniciarTabla();
    }
  });

  listModal.addEventListener('hidden.bs.modal', function () {
    const codigo = listModal.querySelector('#codigoOt');
    const nombre = listModal.querySelector('#nombreOt');
    if (codigo) codigo.textContent = '';
    if (nombre) nombre.textContent = '-';
    if (metaOt) metaOt.textContent = '';
    setOtFinalizadaState(false);
    resetFormFields();
    renderDetallesTable([], true);
    renderDetallesCards([], true);
    const instance = bootstrap.Modal.getInstance(formModalEl);
    if (instance) instance.hide();
  });

  formModalEl.addEventListener('hidden.bs.modal', function () {
    resetFormFields();
    updateFormChrome('new', otActualFinalizada());
  });

  if (btnRecargarDetalle) {
    btnRecargarDetalle.addEventListener('click', reiniciarTabla);
  }

  if (btnCrear) {
    btnCrear.addEventListener('click', function () {
      abrirFormularioDetalle('new');
    });
  }

  if (form) {
    form.addEventListener('submit', function (e) {
      e.preventDefault();
      e.stopImmediatePropagation();

      if (submitInFlight || formMode === 'view') return;

      const validation = validateBeforeSave();
      if (!validation.ok) return;

      Swal.fire({
        title: 'Guardar cambios?',
        text: validation.idDetalle ? 'Se actualizara el detalle.' : 'Se registrara un nuevo detalle.',
        icon: 'question',
        showCancelButton: true,
        confirmButtonText: 'Si, guardar',
        cancelButtonText: 'Cancelar'
      }).then(async (r) => {
        if (!r.isConfirmed) return;

        submitInFlight = true;

        const body = new URLSearchParams();
        body.append('tipo', 'guardar');
        body.append('codigo', validation.codigo);
        body.append('id', validation.idDetalle);
        body.append('fecha', getValue('#fecha'));
        body.append('desc', getValue('#desc'));
        body.append('cant', getValue('#cant'));
        body.append('turno', getValue('#turno'));
        body.append('cco', getValue('#cco'));
        body.append('ccf', getValue('#ccf'));
        body.append('tec', getValue('#tec'));
        body.append('hora_inicio', getValue('#hora_inicio'));
        body.append('hora_fin', getValue('#hora_fin'));
        body.append('observacion', getValue('#observacion'));

        const { res, payload } = await fetchJsonSafe(urlDetalleAccion, body);
        submitInFlight = false;

        if (!res.ok || payload?.ok === false) {
          showAlertFromBackend(payload, {
            title: 'No se pudo guardar',
            text: 'Revisa los datos e intentalo nuevamente.',
            icon: 'error'
          });
          return;
        }

        Swal.fire({
          icon: 'success',
          title: 'Guardado',
          text: payload?.modo === 'update'
            ? 'Detalle actualizado correctamente.'
            : 'Detalle registrado correctamente.'
        });

        getFormModalInstance().hide();
        resetFormFields();
        reiniciarTabla();
      });
    }, true);
  }

  window.limpiarDetalles = function () {
    resetFormFields();
    updateFormChrome('new', otActualFinalizada());
  };

  window.enfocarFormularioDetalle = function () {
    abrirFormularioDetalle('new');
  };

  window.reiniciarTabla = reiniciarTabla;
  window.cerrarVentana = function () {
    resetFormFields();
    renderDetallesTable([], true);
    renderDetallesCards([], true);
  };
});

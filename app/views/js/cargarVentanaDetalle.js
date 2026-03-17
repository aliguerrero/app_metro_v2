/* cargarVentanaDetalle.js (PRODUCCIÓN + ALERTAS SWEETALERT2)
   SOLO cargarDatosDetalle.php:
   - ver     : tipo=ver (id, fecha, codigo)
   - eliminar: tipo=eliminar (id, fecha, codigo)
   - guardar : tipo=guardar (codigo, id(opcional=id_ai_detalle), fecha, ...campos)

   ✅ Incluye:
   - Validación FRONT (obligatorios excepto observación) con SweetAlert (lista de campos faltantes)
   - Manejo de respuesta BACK con formato del sistema:
       { ok, tipo:'simple', titulo, texto, icono, missing_labels? }
     -> Se muestra SIN “Error 400/500” (eso queda en consola)
*/

document.addEventListener('DOMContentLoaded', function () {
  const dir = document.getElementById('url') ? document.getElementById('url').value : '';
  const modal = document.getElementById('detallesOt');
  if (!modal) return;

  const btnRecargarDetalle = document.getElementById('btnRecargarDetalle');
  const form = document.getElementById('formDetalleOt');

  const urlCargarOt = dir + 'app/controllers/cargarDatosOt.php';
  const urlCargarDetalles = dir + 'app/controllers/cargarDatosDetalles.php';
  const urlDetalleAccion = dir + 'app/controllers/cargarDatosDetalle.php';

  let submitInFlight = false;

  // =========================
  // Helpers
  // =========================
  const FIELD_LABELS = {
    codigo: 'Código O.T.',
    fecha: 'Fecha',
    desc: 'Descripción',
    cant: 'Cantidad de operadores',
    turno: 'Turno',
    status: 'Estado',
    cco: 'CCO',
    ccf: 'CCF',
    tec: 'Técnico',
    prep_ini: 'Preparación (Inicio)',
    prep_fin: 'Preparación (Fin)',
    tras_ini: 'Traslado (Inicio)',
    tras_fin: 'Traslado (Fin)',
    ejec_ini: 'Ejecución (Inicio)',
    ejec_fin: 'Ejecución (Fin)',
    observacion: 'Observación'
  };

  function pick(root, ...selectors) {
    for (const s of selectors) {
      const el = root.querySelector(s);
      if (el) return el;
    }
    return null;
  }

  function setVal(el, value, fallback = '') {
    if (!el) return;
    el.value = (value ?? fallback);
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
    return String(str ?? '')
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#039;');
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

  function showAlertFromBackend(payload, fallback = {}) {
    // Handler global (si existe)
    if (typeof alertas_ajax === 'function' && payload && payload.tipo) {
      alertas_ajax(payload);
      return;
    }

    // Formato del sistema
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

    // Respuestas técnicas
    const msg = payload?.texto || payload?.message || fallback.text || 'Intenta nuevamente.';
    return Swal.fire({
      icon: fallback.icon || 'error',
      title: fallback.title || 'No se pudo completar la acción',
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
          <p style="margin-top:10px; margin-bottom:0"><b>Observación</b> es el único campo opcional.</p>
        </div>
      `
    });
  }

  function getValue(sel) {
    return String(pick(form, sel)?.value || '').trim();
  }

  function validateBeforeSave({ modoTxt, codigo, idDetalle }) {
    const missing = [];

    if (!codigo) missing.push('codigo');

    const fecha = getValue('#fecha');
    if (!fecha) missing.push('fecha');
    else if (!isYmd(fecha)) {
      Swal.fire({ icon: 'warning', title: 'Fecha inválida', text: 'Selecciona una fecha válida.' });
      return { ok: false, missing: null };
    }

    if (!getValue('#desc')) missing.push('desc');
    if (!getValue('#cant')) missing.push('cant');
    if (!getValue('#turno')) missing.push('turno');
    if (!getValue('#status')) missing.push('status');
    if (!getValue('#cco')) missing.push('cco');
    if (!getValue('#ccf')) missing.push('ccf');
    if (!getValue('#tec')) missing.push('tec');

    if (!getValue('#prep_ini')) missing.push('prep_ini');
    if (!getValue('#prep_fin')) missing.push('prep_fin');
    if (!getValue('#tras_ini')) missing.push('tras_ini');
    if (!getValue('#tras_fin')) missing.push('tras_fin');
    if (!getValue('#ejec_ini')) missing.push('ejec_ini');
    if (!getValue('#ejec_fin')) missing.push('ejec_fin');

    if (modoTxt === 'Edición' && !idDetalle) {
      Swal.fire({
        icon: 'error',
        title: 'No se pudo actualizar',
        text: 'No se identificó el detalle a modificar. Vuelve a seleccionar el registro desde la lista.'
      });
      return { ok: false, missing: null };
    }

    if (missing.length) {
      showMissingFieldsAlert(missing);
      return { ok: false, missing };
    }

    return { ok: true, missing: [] };
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
      console.error('Respuesta vacía', { url, status: res.status });
      return {
        res,
        payload: {
          ok: false,
          tipo: 'simple',
          titulo: 'Sin respuesta del servidor',
          texto: 'No se recibió respuesta. Intenta nuevamente.',
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
          titulo: 'Respuesta inválida',
          texto: 'El servidor devolvió una respuesta inesperada. Intenta nuevamente o contacta al administrador.',
          icono: 'error'
        }
      };
    }

    if (!res.ok) console.error('HTTP', res.status, payload);
    return { res, payload };
  }

  // =========================
  // Render lista (tabla/cards)
  // =========================
  function buildRowDetalle(contador, d) {
    const fechaRaw = d.fecha ?? '';
    const fecha = fechaRaw ? formatearFecha(fechaRaw) : '—';
    const descripcion = escapeHtml(d.descripcion ?? d.desc ?? '—');
    const color = d.color ?? '#6B7280';
    const estado = d.nombre_estado ?? '—';

    const idDetalle = d.id_detalle ?? d.id_ai_detalle ?? d.id ?? '';
    const n_ot = d.n_ot ?? (document.getElementById('codigoOt')?.textContent ?? '').trim();

    return `
      <td class="col-p"><b>${contador}</b></td>
      <td class="col-p">
        <span style="display:block;border:1px solid #fff;border-radius:50em;width:1.7333333333rem;height:1.7333333333rem;background-color:${color};"
          title="${escapeHtml(estado)}"></span>
      </td>
      <td class="col-1"><b>${fecha}</b></td>
      <td class="col-5"><b>${descripcion}</b></td>

      <td class="col-p text-center">
        <button type="button" class="btn btn-warning text-dark btn-sm js-ver-detalle" title="Ver/Editar"
          data-id="${escapeAttr(idDetalle)}"
          data-fecha="${escapeAttr(fechaRaw)}"
          data-ot="${escapeAttr(n_ot)}">
          <i class="bi bi-pencil text-white"></i>
        </button>
      </td>

      <td class="col-p text-center">
        <button type="button" class="btn btn-danger btn-sm js-del-detalle" title="Eliminar"
          data-id="${escapeAttr(idDetalle)}"
          data-fecha="${escapeAttr(fechaRaw)}"
          data-ot="${escapeAttr(n_ot)}">
          <i class="bi bi-trash"></i>
        </button>
      </td>
    `;
  }

  function buildCardDetalle(contador, d) {
    const fechaRaw = d.fecha ?? '';
    const fecha = fechaRaw ? formatearFecha(fechaRaw) : '—';
    const descripcion = escapeHtml(d.descripcion ?? d.desc ?? '—');
    const color = d.color ?? '#6B7280';
    const estado = d.nombre_estado ?? '—';

    const idDetalle = d.id_detalle ?? d.id_ai_detalle ?? d.id ?? '';
    const n_ot = d.n_ot ?? (document.getElementById('codigoOt')?.textContent ?? '').trim();

    return `
      <div class="tool-card">
        <div class="tool-card-head">
          <span class="tool-code">#${contador} • ${fecha}</span>
          <span class="badge" style="background:${color};">${escapeHtml(estado)}</span>
        </div>
        <div class="tool-body">
          <div class="tool-row">
            <div class="tool-label">Descripción</div>
            <div class="tool-value">${descripcion}</div>
          </div>
          <div class="tool-actions">
            <button type="button" class="btn btn-warning text-dark btn-sm js-ver-detalle" title="Ver/Editar"
              data-id="${escapeAttr(idDetalle)}"
              data-fecha="${escapeAttr(fechaRaw)}"
              data-ot="${escapeAttr(n_ot)}">
              <i class="bi bi-pencil text-white"></i>
            </button>
            <button type="button" class="btn btn-danger btn-sm js-del-detalle" title="Eliminar"
              data-id="${escapeAttr(idDetalle)}"
              data-fecha="${escapeAttr(fechaRaw)}"
              data-ot="${escapeAttr(n_ot)}">
              <i class="bi bi-trash"></i>
            </button>
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
      tbody.innerHTML = `<tr class="align-middle"><td class="text-center" colspan="6">No hay registros en el sistema</td></tr>`;
      return;
    }

    let c = 1;
    data.forEach(d => {
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
      wrap.innerHTML = `<div class="tool-card"><div class="tool-card-head"><span class="tool-code">Sin registros</span><span>—</span></div></div>`;
      return;
    }

    let c = 1;
    wrap.innerHTML = data.map(d => buildCardDetalle(c++, d)).join('');
  }

  function reiniciarTabla() {
    const codigoOt = (document.getElementById('codigoOt')?.textContent ?? '').trim();
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

  // =========================
  // Delegación: Ver/Eliminar
  // =========================
  modal.addEventListener('click', function (e) {
    const ver = e.target.closest('.js-ver-detalle');
    if (ver) {
      verDetalles(ver.dataset.id || '', ver.dataset.fecha || '', ver.dataset.ot || '');
      if (typeof enfocarFormularioDetalle === 'function') enfocarFormularioDetalle();
      return;
    }

    const del = e.target.closest('.js-del-detalle');
    if (del) {
      eliminarDetalles(del.dataset.id || '', del.dataset.fecha || '', del.dataset.ot || '');
      return;
    }
  });

  // =========================
  // Abrir modal: cargar OT + setear codigo (#id) y reset id2
  // =========================
  modal.addEventListener('show.bs.modal', function (event) {
    const button = event.relatedTarget;
    const idBtn = button ? button.getAttribute('data-bs-id') : null;
    if (!idBtn) return;

    const codigoOtEl = modal.querySelector('#codigoOt');
    const nombreOtEl = modal.querySelector('#nombreOt');

    const inputCodigo = modal.querySelector('#id');   // name="codigo"
    const inputId2 = modal.querySelector('#id2');     // name="id" (id_detalle)

    const fd = new FormData();
    fd.append('id', idBtn);

    fetch(urlCargarOt, { method: "POST", body: fd })
      .then(r => r.json())
      .then(payload => {
        const data = payload?.data ?? payload;
        if (!data) return;

        if (codigoOtEl) codigoOtEl.textContent = data.n_ot ?? '';
        if (nombreOtEl) nombreOtEl.textContent = data.nombre_trab ?? '';

        setVal(inputCodigo, data.n_ot ?? '');
        setVal(inputId2, ''); // nuevo

        limpiarDetalles();
      })
      .catch(console.error);
  });

  modal.addEventListener('shown.bs.modal', reiniciarTabla);
  if (btnRecargarDetalle) btnRecargarDetalle.addEventListener('click', reiniciarTabla);

  modal.addEventListener('hidden.bs.modal', function () {
    const c = modal.querySelector('#codigoOt');
    if (c) c.textContent = '';
    limpiarDetalles();
    renderDetallesTable([], true);
    renderDetallesCards([], true);
  });

  // =========================
  // VER (tipo=ver)
  // =========================
  async function verDetalles(id, fecha, codigo) {
    if (!id || !fecha || !codigo) return;
    if (!isYmd(fecha)) return;

    const body = new URLSearchParams();
    body.append('tipo', 'ver');
    body.append('id', id);
    body.append('fecha', fecha);
    body.append('codigo', codigo);

    const { res, payload } = await fetchJsonSafe(urlDetalleAccion, body);
    if (!res.ok) {
      showAlertFromBackend(payload, { title: 'No se pudo cargar el detalle', text: 'Intenta nuevamente.' });
      return;
    }

    const detail = payload?.data ?? payload;
    const realId = String(detail?.id_ai_detalle ?? detail?.id_detalle ?? detail?.id ?? id);

    setVal(pick(modal, '#id', '[name="codigo"]'), detail.n_ot ?? codigo, '');
    setVal(pick(modal, '#id2', '[name="id"]'), realId, '');

    setVal(pick(modal, '#fecha', '[name="fecha"]'), detail.fecha ?? fecha, '');
    setVal(pick(modal, '#desc', '[name="desc"]'), detail.descripcion ?? '', '');
    setVal(pick(modal, '#cant', '[name="cant"]'), detail.cant_tec ?? '', '');

    setVal(pick(modal, '#turno', '[name="turno"]'), detail.id_ai_turno ?? '', '');
    setVal(pick(modal, '#status', '[name="status"]'), detail.id_ai_estado ?? '', '');
    setVal(pick(modal, '#cco', '[name="cco"]'), detail.id_miembro_cco ?? '', '');
    setVal(pick(modal, '#ccf', '[name="ccf"]'), detail.id_miembro_ccf ?? '', '');
    setVal(pick(modal, '#tec', '[name="tec"]'), detail.id_user_act ?? '', '');

    setVal(pick(modal, '#prep_ini', '[name="prep_ini"]'), detail.hora_ini_pre ?? '', '');
    setVal(pick(modal, '#prep_fin', '[name="prep_fin"]'), detail.hora_fin_pre ?? '', '');
    setVal(pick(modal, '#tras_ini', '[name="tras_ini"]'), detail.hora_ini_tra ?? '', '');
    setVal(pick(modal, '#tras_fin', '[name="tras_fin"]'), detail.hora_fin_tra ?? '', '');
    setVal(pick(modal, '#ejec_ini', '[name="ejec_ini"]'), detail.hora_ini_eje ?? '', '');
    setVal(pick(modal, '#ejec_fin', '[name="ejec_fin"]'), detail.hora_fin_eje ?? '', '');
    setVal(pick(modal, '#observacion', '[name="observacion"]'), detail.observacion ?? '', '');

    const modo = document.getElementById('modoEdicionLabel');
    if (modo) modo.textContent = 'Edición';
  }

  // =========================
  // ELIMINAR (tipo=eliminar)
  // =========================
  function eliminarDetalles(id, fecha, codigo) {
    if (!id || !fecha || !codigo) return;

    Swal.fire({
      title: "¿Eliminar detalle?",
      text: "Se eliminará el registro.",
      icon: "warning",
      showCancelButton: true,
      confirmButtonText: "Sí, eliminar",
      cancelButtonText: "Cancelar"
    }).then(async (r) => {
      if (!r.isConfirmed) return;

      const body = new URLSearchParams();
      body.append('tipo', 'eliminar');
      body.append('id', id);
      body.append('fecha', fecha);
      body.append('codigo', codigo);

      const { res, payload } = await fetchJsonSafe(urlDetalleAccion, body);

      if (!res.ok || payload?.ok === false) {
        console.error('[ELIMINAR] fallo', { status: res.status, payload });
        showAlertFromBackend(payload, {
          title: 'No se pudo eliminar',
          text: 'No fue posible eliminar el detalle. Intenta nuevamente.'
        });
        return;
      }

      Swal.fire({ icon: 'success', title: 'Eliminado', text: 'Detalle eliminado correctamente.' });
      limpiarDetalles();
      reiniciarTabla();
    });
  }

  // =========================
  // GUARDAR (submit => tipo=guardar)
  // =========================
  if (form) {
    form.addEventListener('submit', function (e) {
      e.preventDefault();
      e.stopImmediatePropagation();

      if (submitInFlight) return;

      const codigo = String(pick(form, '#id', '[name="codigo"]')?.value || '').trim();
      const idDetalle = String(pick(form, '#id2', '[name="id"]')?.value || '').trim();
      const modoTxt = document.getElementById('modoEdicionLabel')?.textContent?.trim() || 'Nuevo';

      const v = validateBeforeSave({ modoTxt, codigo, idDetalle });
      if (!v.ok) return;

      Swal.fire({
        title: "¿Guardar cambios?",
        text: (idDetalle ? "Se actualizará el detalle." : "Se registrará un nuevo detalle."),
        icon: "question",
        showCancelButton: true,
        confirmButtonText: "Sí, guardar",
        cancelButtonText: "Cancelar"
      }).then(async (r) => {
        if (!r.isConfirmed) return;

        submitInFlight = true;

        const body = new URLSearchParams();
        body.append('tipo', 'guardar');
        body.append('codigo', codigo);
        body.append('id', idDetalle);
        body.append('fecha', getValue('#fecha'));

        body.append('desc', getValue('#desc'));
        body.append('cant', getValue('#cant'));
        body.append('turno', getValue('#turno'));
        body.append('status', getValue('#status'));
        body.append('cco', getValue('#cco'));
        body.append('ccf', getValue('#ccf'));
        body.append('tec', getValue('#tec'));

        body.append('prep_ini', getValue('#prep_ini'));
        body.append('prep_fin', getValue('#prep_fin'));
        body.append('tras_ini', getValue('#tras_ini'));
        body.append('tras_fin', getValue('#tras_fin'));
        body.append('ejec_ini', getValue('#ejec_ini'));
        body.append('ejec_fin', getValue('#ejec_fin'));
        body.append('observacion', getValue('#observacion'));

        const { res, payload } = await fetchJsonSafe(urlDetalleAccion, body);
        submitInFlight = false;

        if (!res.ok || payload?.ok === false) {
          console.error('[GUARDAR] fallo', { status: res.status, payload });
          showAlertFromBackend(payload, {
            title: 'No se pudo guardar',
            text: 'Revisa los datos e inténtalo nuevamente.',
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

        limpiarDetalles();
        reiniciarTabla();
      });
    }, true);
  }

  // =========================
  // LIMPIAR
  // =========================
  window.limpiarDetalles = function () {
    setVal(pick(modal, '#id2', '[name="id"]'), '');

    ['fecha', 'desc', 'cant', 'prep_ini', 'prep_fin', 'tras_ini', 'tras_fin', 'ejec_ini', 'ejec_fin', 'observacion']
      .forEach(id => setVal(pick(modal, `#${id}`), ''));

    ['turno', 'status', 'tec', 'cco', 'ccf']
      .forEach(id => setVal(pick(modal, `#${id}`, `[name="${id}"]`), ''));

    const modo = document.getElementById('modoEdicionLabel');
    if (modo) modo.textContent = 'Nuevo';
  };

  window.reiniciarTabla = reiniciarTabla;
});

function formatearFecha(fecha) {
  if (!fecha) return '';
  const partes = String(fecha).split('-');
  if (partes.length !== 3) return fecha;
  return `${partes[2]}/${partes[1]}/${partes[0]}`;
}

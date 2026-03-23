document.addEventListener('DOMContentLoaded', () => {
  const dir = document.getElementById('url') ? document.getElementById('url').value : '';
  const modal = document.getElementById('modalPreviewReporteOt');
  const badge = document.getElementById('previewReporteOtBadge');
  const meta = document.getElementById('modalPreviewReporteOtMeta');
  const estado = document.getElementById('previewReporteOtEstado');
  const frame = document.getElementById('previewReporteOtFrame');
  const btnPdf = document.getElementById('btnDescargarReporteOtPdf');
  const inputCodigo = document.getElementById('previewReporteOtCodigo');

  function showAlert(payload, fallback = {}) {
    if (typeof alertas_ajax === 'function' && payload?.tipo) {
      alertas_ajax(payload);
      return;
    }

    Swal.fire({
      icon: payload?.icono || fallback.icono || 'info',
      title: payload?.titulo || fallback.titulo || 'Aviso',
      text: payload?.texto || fallback.texto || 'Intenta nuevamente.'
    });
  }

  function getEstadoCatalog() {
    const select = document.getElementById('status');
    if (!select) return { options: {}, meta: {} };

    const options = {};
    const meta = {};
    Array.from(select.options).forEach((opt) => {
      const value = String(opt.value || '').trim();
      if (!value) return;
      options[value] = opt.textContent.trim();
      meta[value] = {
        liberaHerramientas: String(opt.dataset.liberaHerramientas || '0') === '1',
        bloqueaOt: String(opt.dataset.bloqueaOt || '0') === '1'
      };
    });
    return { options, meta };
  }

  async function cargarPreviewOt(nOt) {
    if (!frame || !estado) return;

    estado.textContent = 'Generando vista previa...';
    frame.srcdoc = '<div style="font-family:Arial;padding:16px;color:#555;">Generando vista previa...</div>';

    const params = new URLSearchParams();
    params.append('tipo', 'ot_detallado');
    params.append('n_ot', nOt);
    params.append('orientacion', 'landscape');

    try {
      const res = await fetch(dir + 'app/controllers/cargarDatosReporte.php?' + params.toString(), {
        credentials: 'same-origin',
        headers: { Accept: 'application/json' }
      });

      const payload = await res.json();
      if (!res.ok || payload?.ok === false) {
        estado.textContent = 'No se pudo generar la vista previa.';
        frame.srcdoc = `<div style="font-family:Arial;padding:16px;color:#b00020;">${payload?.msg || 'No se pudo generar la vista previa.'}</div>`;
        return;
      }

      estado.textContent = 'Vista previa lista.';
      frame.srcdoc = payload.html || '<div style="font-family:Arial;padding:16px;color:#555;">Sin contenido.</div>';
    } catch (error) {
      console.error('Error cargando preview OT:', error);
      estado.textContent = 'Ocurrio un error cargando la vista previa.';
      frame.srcdoc = '<div style="font-family:Arial;padding:16px;color:#b00020;">Error cargando la vista previa.</div>';
    }
  }

  if (modal) {
    modal.addEventListener('show.bs.modal', (event) => {
      const trigger = event.relatedTarget;
      const nOt = trigger ? String(trigger.getAttribute('data-bs-ot') || '') : '';
      inputCodigo.value = nOt;

      if (badge) badge.textContent = nOt || '-';
      if (meta) meta.textContent = nOt ? `Vista previa del reporte detallado de la O.T. ${nOt}.` : 'Vista previa del reporte.';

      if (nOt) {
        cargarPreviewOt(nOt);
      }
    });
  }

  if (btnPdf) {
    btnPdf.addEventListener('click', () => {
      const nOt = String(inputCodigo?.value || '').trim();
      if (!nOt) return;

      const params = new URLSearchParams();
      params.append('tipo', 'ot_detallado');
      params.append('n_ot', nOt);
      params.append('orientacion', 'landscape');

      window.open(dir + 'app/controllers/exportarReportePdf.php?' + params.toString(), '_blank');
    });
  }

  document.addEventListener('click', async (event) => {
    const btnEstado = event.target.closest('.js-cambiar-estado-ot');
    if (!btnEstado) return;

    const nOt = String(btnEstado.getAttribute('data-ot') || '').trim();
    const estadoActualId = String(btnEstado.getAttribute('data-estado-id') || '').trim();
    const estadoActualNombre = String(btnEstado.getAttribute('data-estado-nombre') || '').trim();

    if (!nOt) return;

    const catalog = getEstadoCatalog();
    const inputOptions = catalog.options;
    if (Object.keys(inputOptions).length === 0) {
      Swal.fire({
        icon: 'warning',
        title: 'Sin estados disponibles',
        text: 'No se encontraron estados activos para asignar.'
      });
      return;
    }

    const seleccion = await Swal.fire({
      icon: 'question',
      title: 'Cambiar estado de O.T.',
      text: estadoActualNombre
        ? `Estado actual: ${estadoActualNombre}`
        : 'Selecciona el nuevo estado para la O.T.',
      input: 'select',
      inputOptions,
      inputValue: estadoActualId || undefined,
      inputPlaceholder: 'Seleccionar estado',
      showCancelButton: true,
      confirmButtonText: 'Actualizar estado',
      cancelButtonText: 'Cancelar',
      inputValidator: (value) => {
        if (!value) {
          return 'Debes seleccionar un estado.';
        }
        return null;
      }
    });

    if (!seleccion.isConfirmed) return;

    const estadoDestino = String(seleccion.value || '').trim();
    if (!estadoDestino) return;

    const nombreDestino = inputOptions[estadoDestino] || 'seleccionado';
    const liberaHerramientas = catalog.meta[estadoDestino]?.liberaHerramientas === true;
    const bloqueaOt = catalog.meta[estadoDestino]?.bloqueaOt === true;

    const confirmacion = await Swal.fire({
      icon: bloqueaOt || liberaHerramientas ? 'warning' : 'question',
      title: 'Confirmar cambio de estado',
      text: bloqueaOt
        ? `La O.T. ${nOt} pasara al estado ${nombreDestino}, quedara bloqueada y sus herramientas se liberaran.`
        : liberaHerramientas
        ? `La O.T. ${nOt} pasara al estado ${nombreDestino} y sus herramientas se liberaran, pero la orden seguira disponible.`
        : `La O.T. ${nOt} cambiara al estado ${nombreDestino}.`,
      showCancelButton: true,
      confirmButtonText: 'Si, continuar',
      cancelButtonText: 'Cancelar'
    });

    if (!confirmacion.isConfirmed) return;

    const body = new URLSearchParams();
    body.append('modulo_ot', 'cambiar_estado_ot');
    body.append('n_ot', nOt);
    body.append('id_ai_estado', estadoDestino);

    try {
      const res = await fetch(dir + 'app/ajax/otAjax.php', {
        method: 'POST',
        credentials: 'same-origin',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
          Accept: 'application/json',
          'X-Requested-With': 'XMLHttpRequest'
        },
        body
      });

      const payload = await res.json();
      if (!res.ok || payload?.icono === 'error') {
        showAlert(payload, {
          icono: 'error',
          titulo: 'No se pudo cambiar el estado',
          texto: 'Ocurrio un error al actualizar la O.T.'
        });
        return;
      }

      showAlert(payload, {
        icono: 'success',
        titulo: 'Estado actualizado',
        texto: 'La orden de trabajo fue actualizada correctamente.'
      });

      if (typeof reiniciarTablaOT === 'function') {
        reiniciarTablaOT(dir);
      }
    } catch (error) {
      console.error('Error cambiando estado OT:', error);
      Swal.fire({
        icon: 'error',
        title: 'No se pudo cambiar el estado',
        text: 'Ocurrio un error al procesar la solicitud.'
      });
    }
  });
});

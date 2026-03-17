document.addEventListener('DOMContentLoaded', () => {
  const dir = (document.getElementById('url')?.value || '').trim();
  if (!dir) return;

  const API = dir + 'app/controllers/sitioCrud.php';

  const sitioListWrap = document.getElementById('sitioListWrap');
  const totalTop = document.getElementById('sitioTotalTop');
  const btnRecargar = document.getElementById('btnRecargarSitio');

  const formCreate = document.getElementById('formSitioCrear');
  const inputCreate = document.getElementById('sitio');

  const modalEl = document.getElementById('ventanaModalModificarSitio');
  const formEdit = document.getElementById('formSitioEditar');
  const editId = document.getElementById('edit_id_sitio');
  const editNombre = document.getElementById('edit_nombre_sitio');

  if (!sitioListWrap || !formCreate || !inputCreate) return;

  // =========================
  // Helpers
  // =========================
  async function fetchJSON(url, options = {}) {
    const res = await fetch(url, options);
    const text = await res.text();

    if (text.trim().startsWith('<')) {
      console.error('Respuesta NO JSON:', text);
      throw new Error('Respuesta inválida (HTML). Revisa errores PHP/back-end.');
    }

    try {
      return JSON.parse(text);
    } catch (e) {
      console.error('JSON inválido:', text);
      throw new Error('JSON inválido');
    }
  }

  const toast = (icon, title) => {
    if (!window.Swal) return;
    Swal.fire({ toast: true, position: "bottom-end", timer: 2800, showConfirmButton: false, icon, title });
  };

  async function confirmDialog({ title, text, confirmText }) {
    if (!window.Swal) return confirm(text || title || '¿Confirmar?');
    const r = await Swal.fire({
      title: title || '¿Confirmar?',
      text: text || '¿Deseas continuar?',
      icon: 'question',
      showCancelButton: true,
      confirmButtonText: confirmText || 'Sí',
      cancelButtonText: 'Cancelar',
      confirmButtonColor: '#3085d6',
      cancelButtonColor: '#d33',
      allowOutsideClick: false,
      allowEscapeKey: true,
    });
    return r.isConfirmed;
  }

  function safeShowModal() {
    if (!modalEl || !window.bootstrap) return;
    const inst = bootstrap.Modal.getOrCreateInstance(modalEl, { backdrop: true, keyboard: true });
    inst.show();
  }

  function safeHideModal() {
    if (!modalEl || !window.bootstrap) return;
    const inst = bootstrap.Modal.getInstance(modalEl) || bootstrap.Modal.getOrCreateInstance(modalEl);
    inst.hide();
  }

  function hardCleanModalBackdrop() {
    document.body.classList.remove('modal-open');
    document.body.style.removeProperty('padding-right');
    document.body.style.removeProperty('overflow');
    document.querySelectorAll('.modal-backdrop').forEach(b => b.remove());
  }

  if (modalEl) {
    modalEl.addEventListener('hidden.bs.modal', () => {
      hardCleanModalBackdrop();
      if (editId) editId.value = '';
      if (editNombre) editNombre.value = '';
    });
  }

  // =========================
  // List
  // =========================
  async function cargarLista() {
    const data = await fetchJSON(API + '?action=list', { method: 'GET' });
    if (data.ok && typeof data.html === 'string') {
      sitioListWrap.innerHTML = data.html;
      if (totalTop) totalTop.textContent = `Total: ${data.total ?? ''}`;
    } else {
      toast('error', data.msg || 'No se pudo recargar la lista');
    }
  }

  // =========================
  // CREATE (captura + confirmación REAL)
  // =========================
  formCreate.addEventListener('submit', async (e) => {
    e.preventDefault();
    e.stopPropagation();
    e.stopImmediatePropagation();

    const nombre = (inputCreate.value || '').trim();
    if (!nombre) {
      toast('warning', 'Escribe el nombre del sitio');
      return;
    }

    const ok = await confirmDialog({
      title: '¿Crear sitio?',
      text: 'Se registrará un nuevo sitio de trabajo.',
      confirmText: 'Sí, crear'
    });
    if (!ok) return;

    const fd = new FormData();
    fd.append('action', 'create');
    fd.append('nombre', nombre);

    const resp = await fetchJSON(API, { method: 'POST', body: fd });
    if (!resp.ok) {
      toast('error', resp.msg || 'No se pudo crear');
      return;
    }

    inputCreate.value = '';
    await cargarLista();
    toast('success', resp.msg || 'Sitio creado');
  }, true);

  // =========================
  // EDIT open + DELETE (delegación)
  // =========================
  sitioListWrap.addEventListener('click', async (e) => {
    const btnEdit = e.target.closest('[data-action="edit"]');
    const btnDel = e.target.closest('[data-action="delete"]');

    // Edit
    if (btnEdit) {
      e.preventDefault();
      const id = btnEdit.getAttribute('data-id');
      if (!id) return;

      const fd = new FormData();
      fd.append('action', 'get');
      fd.append('id', id);

      const data = await fetchJSON(API, { method: 'POST', body: fd });
      if (!data.ok || !data.data) {
        toast('error', data.msg || 'No se pudo cargar');
        return;
      }

      if (editId) editId.value = data.data.id_ai_sitio;
      if (editNombre) editNombre.value = data.data.nombre_sitio || '';

      safeShowModal();
      return;
    }

    // Delete
    if (btnDel) {
      e.preventDefault();
      const id = btnDel.getAttribute('data-id');
      if (!id) return;

      const ok = await confirmDialog({
        title: '¿Eliminar sitio?',
        text: 'Esta acción no se puede deshacer.',
        confirmText: 'Sí, eliminar'
      });
      if (!ok) return;

      const fd = new FormData();
      fd.append('action', 'delete');
      fd.append('id', id);

      const resp = await fetchJSON(API, { method: 'POST', body: fd });
      if (!resp.ok) {
        toast('error', resp.msg || 'No se pudo eliminar');
        return;
      }

      await cargarLista();
      toast('success', resp.msg || 'Sitio eliminado');
      return;
    }
  });

  // =========================
  // UPDATE (captura + confirmación REAL)
  // =========================
  if (formEdit) {
    formEdit.addEventListener('submit', async (e) => {
      e.preventDefault();
      e.stopPropagation();
      e.stopImmediatePropagation();

      const id = (editId?.value || '').trim();
      const nombre = (editNombre?.value || '').trim();

      if (!id || !nombre) {
        toast('warning', 'Completa los datos');
        return;
      }

      const ok = await confirmDialog({
        title: '¿Guardar cambios?',
        text: 'Se actualizará el sitio con la nueva información.',
        confirmText: 'Sí, guardar'
      });
      if (!ok) return;

      const fd = new FormData();
      fd.append('action', 'update');
      fd.append('id', id);
      fd.append('nombre', nombre);

      const resp = await fetchJSON(API, { method: 'POST', body: fd });
      if (!resp.ok) {
        toast('error', resp.msg || 'No se pudo actualizar');
        return;
      }

      await cargarLista();
      safeHideModal();
      setTimeout(hardCleanModalBackdrop, 250);
      toast('success', resp.msg || 'Sitio actualizado');
    }, true);
  }

  // =========================
  // Recargar
  // =========================
  if (btnRecargar) {
    btnRecargar.addEventListener('click', async (e) => {
      e.preventDefault();
      await cargarLista();
      toast('success', 'Lista recargada');
    });
  }

  // Carga inicial (opcional)
  // cargarLista();
});

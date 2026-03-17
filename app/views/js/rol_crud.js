document.addEventListener('DOMContentLoaded', () => {
    const dir = (document.getElementById('url')?.value || '').trim();
    if (!dir) return;

    const API = dir + 'app/controllers/rolCrud.php';

    const selectAccion = document.getElementById('selectAccion');
    const bloqueListar = document.getElementById('listar');
    const bloqueNuevo = document.getElementById('nuevo');

    const rolesSelectWrap = document.getElementById('rolesSelectWrap');
    const rolNameInput = document.getElementById('rol_name');

    const btnCrearRol = document.getElementById('btnCrearRol');
    const btnEliminarRol = document.getElementById('btnEliminarRol');

    const permisosWrap = document.getElementById('contenido');
    const btnGuardarPermisos = document.getElementById('btnGuardarPermisos');

    const msgRolesTop = document.getElementById('rolesMsgTop');
    const msgPermTop = document.getElementById('permMsgTop');

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

    async function fetchJSON(url, options = {}) {
        const res = await fetch(url, options);
        const text = await res.text();

        if (text.trim().startsWith('<')) {
            console.error('Respuesta NO JSON:', text);
            throw new Error('Respuesta inválida (HTML). Revisa backend.');
        }
        try {
            return JSON.parse(text);
        } catch {
            console.error('JSON inválido:', text);
            throw new Error('JSON inválido');
        }
    }

    // ====== MAP UI -> DB ======
    const MAP = {
        permisoUsuarios0: 'perm_usuarios_view',
        permisoUsuarios1: 'perm_usuarios_add',
        permisoUsuarios2: 'perm_usuarios_edit',
        permisoUsuarios3: 'perm_usuarios_delete',

        permisoHerramienta0: 'perm_herramienta_view',
        permisoHerramienta1: 'perm_herramienta_add',
        permisoHerramienta2: 'perm_herramienta_edit',
        permisoHerramienta3: 'perm_herramienta_delete',

        permisoMiembro0: 'perm_miembro_view',
        permisoMiembro1: 'perm_miembro_add',
        permisoMiembro2: 'perm_miembro_edit',
        permisoMiembro3: 'perm_miembro_delete',

        permisoOrdenTrabajo0: 'perm_ot_view',
        permisoOrdenTrabajo1: 'perm_ot_add',
        permisoOrdenTrabajo2: 'perm_ot_edit',
        permisoOrdenTrabajo3: 'perm_ot_add_detalle',
        permisoOrdenTrabajo4: 'perm_ot_delete',
        permisoOrdenTrabajo5: 'perm_ot_generar_reporte',
        permisoOrdenTrabajo6: 'perm_ot_add_herramienta'
    };

    const qsInPerms = (sel) => (permisosWrap ? permisosWrap.querySelector(sel) : null);

    function resetChecks() {
        if (!permisosWrap) return;
        permisosWrap.querySelectorAll('input[type="checkbox"]').forEach(cb => (cb.checked = false));
    }

    function setCheckedSafe(id, value) {
        const el = qsInPerms(`#${id}`) || document.getElementById(id);
        if (!el) {
            console.warn('[Roles/Permisos] Checkbox no existe:', id);
            return;
        }
        el.checked = (value === 1 || value === '1' || value === true);
    }

    function aplicarPermisos(data) {
        if (!data || Object.keys(data).length === 0) {
            resetChecks();
            return;
        }
        Object.entries(MAP).forEach(([checkboxId, dbKey]) => {
            setCheckedSafe(checkboxId, data[dbKey] ?? 0);
        });
    }

    function getRolSelect() {
        if (rolesSelectWrap) {
            const s = rolesSelectWrap.querySelector('select');
            if (s) return s;
        }
        const direct = document.getElementById('opciones');
        if (direct) return direct;

        if (bloqueListar) {
            const s2 = bloqueListar.querySelector('select');
            if (s2) return s2;
        }
        return null;
    }

    function replaceSelectHTML(html) {
        if (rolesSelectWrap) {
            rolesSelectWrap.innerHTML = html;
            return;
        }

        const oldSel = getRolSelect();
        if (!oldSel) {
            console.warn('[Roles] No existe select para reemplazar. Crea #rolesSelectWrap en la vista.');
            return;
        }

        const tmp = document.createElement('div');
        tmp.innerHTML = html;
        const newSel = tmp.querySelector('select');

        if (!newSel) {
            console.warn('[Roles] HTML de roles no trae <select>');
            return;
        }

        oldSel.replaceWith(newSel);
    }

    async function refrescarComboRoles(keepSelectedId = null) {
        const data = await fetchJSON(API + '?action=roles', { method: 'GET' });

        if (!data.ok || typeof data.html !== 'string') {
            toast('error', data.msg || 'No se pudo recargar roles');
            return;
        }

        replaceSelectHTML(data.html);

        const sel = getRolSelect();
        if (sel && keepSelectedId) sel.value = keepSelectedId;

        wireRolSelectChange(true);
    }

    async function cargarPermisosDeRol(rolId) {
        if (!rolId) {
            resetChecks();
            if (msgPermTop) msgPermTop.textContent = '';
            return;
        }

        const fd = new FormData();
        fd.append('action', 'getPerms');
        fd.append('id', rolId);

        const data = await fetchJSON(API, { method: 'POST', body: fd });
        if (!data.ok) {
            resetChecks();
            toast('error', data.msg || 'No se pudieron cargar permisos');
            return;
        }

        aplicarPermisos(data.data);
        if (msgPermTop) msgPermTop.textContent = `Rol ID: ${rolId}`;
    }

    function getPermsPayload() {
        const payload = {};
        Object.entries(MAP).forEach(([checkboxId, dbKey]) => {
            const el = document.getElementById(checkboxId);
            payload[dbKey] = el && el.checked ? '1' : '0';
        });
        return payload;
    }

    function setModo(v) {
        if (v === '2') {
            if (bloqueListar) bloqueListar.style.display = 'none';
            if (bloqueNuevo) bloqueNuevo.style.display = '';
            resetChecks();
            if (msgPermTop) msgPermTop.textContent = '';
        } else {
            if (bloqueListar) bloqueListar.style.display = '';
            if (bloqueNuevo) bloqueNuevo.style.display = 'none';
            const sel = getRolSelect();
            if (sel && sel.value) cargarPermisosDeRol(sel.value);
        }
    }

    if (selectAccion) {
        selectAccion.addEventListener('change', () => setModo(selectAccion.value));
    }

    // ====== change rol
    let rolSelectWired = false;
    const wireRolSelectChange = (forceRewire = false) => {
        const sel = getRolSelect();
        if (!sel) return;

        if (forceRewire) {
            const clone = sel.cloneNode(true);
            sel.replaceWith(clone);
            rolSelectWired = false;
        }

        const sel2 = getRolSelect();
        if (!sel2 || rolSelectWired) return;

        sel2.addEventListener('change', () => cargarPermisosDeRol(sel2.value));
        rolSelectWired = true;
    };

    // ====== Crear rol (AHORA ENVÍA PERMISOS)
    if (btnCrearRol) {
        btnCrearRol.addEventListener('click', async (e) => {
            e.preventDefault();

            const name = (rolNameInput?.value || '').trim();
            if (!name) {
                toast('warning', 'Escribe el nombre del rol');
                return;
            }

            const ok = await confirmDialog({
                title: '¿Crear rol?',
                text: 'Se registrará un nuevo rol en el sistema con los permisos seleccionados.',
                confirmText: 'Sí, crear'
            });
            if (!ok) return;

            const perms = getPermsPayload();

            const fd = new FormData();
            fd.append('action', 'create');
            fd.append('name', name);
            Object.entries(perms).forEach(([k, v]) => fd.append(k, v));

            const resp = await fetchJSON(API, { method: 'POST', body: fd });
            if (!resp.ok) {
                toast('error', resp.msg || 'No se pudo crear');
                return;
            }

            toast('success', resp.msg || 'Rol creado');
            if (msgRolesTop) msgRolesTop.textContent = 'Rol creado correctamente';
            rolNameInput.value = '';

            // refresca combo y selecciona el rol nuevo por ID si viene
            await refrescarComboRoles(resp.id ? String(resp.id) : null);

            if (selectAccion) {
                selectAccion.value = '1';
                setModo('1');
            }

            const sel = getRolSelect();
            if (sel && sel.value) await cargarPermisosDeRol(sel.value);
        }, true);
    }

    // ====== Eliminar rol (MUESTRA USUARIOS SI NO SE PUEDE)
    if (btnEliminarRol) {
        btnEliminarRol.addEventListener('click', async (e) => {
            e.preventDefault();

            const sel = getRolSelect();
            const id = sel ? sel.value : '';
            if (!id) {
                toast('warning', 'Selecciona un rol');
                return;
            }

            const ok = await confirmDialog({
                title: '¿Eliminar rol?',
                text: 'Esta acción no se puede deshacer.',
                confirmText: 'Sí, eliminar'
            });
            if (!ok) return;

            const fd = new FormData();
            fd.append('action', 'delete');
            fd.append('id', id);

            const resp = await fetchJSON(API, { method: 'POST', body: fd });

            if (!resp.ok) {
                // ✅ si backend trae lista de usuarios
                if (window.Swal && Array.isArray(resp.users) && resp.users.length) {
                    await Swal.fire({
                        icon: 'warning',
                        title: 'No se puede eliminar el rol',
                        html: `
                          <div style="text-align:left">
                            <div style="margin-bottom:8px">${resp.msg || 'Hay usuarios con este rol:'}</div>
                            <ul style="margin:0;padding-left:18px">
                              ${resp.users.map(u => `<li>${String(u)}</li>`).join('')}
                            </ul>
                          </div>
                        `,
                        confirmButtonText: 'Entendido'
                    });
                } else {
                    toast('error', resp.msg || 'No se pudo eliminar');
                }
                return;
            }

            toast('success', resp.msg || 'Rol eliminado');
            if (msgRolesTop) msgRolesTop.textContent = 'Rol eliminado';
            resetChecks();

            await refrescarComboRoles();

            const sel2 = getRolSelect();
            if (sel2 && sel2.value) cargarPermisosDeRol(sel2.value);
        }, true);
    }

    // ====== Guardar permisos
    if (btnGuardarPermisos) {
        btnGuardarPermisos.addEventListener('click', async (e) => {
            e.preventDefault();

            const sel = getRolSelect();
            const rolId = sel ? sel.value : '';
            if (!rolId) {
                toast('warning', 'Selecciona un rol para guardar permisos');
                return;
            }

            const ok = await confirmDialog({
                title: '¿Guardar cambios?',
                text: 'Se actualizarán los permisos del rol seleccionado.',
                confirmText: 'Sí, guardar'
            });
            if (!ok) return;

            const perms = getPermsPayload();

            const fd = new FormData();
            fd.append('action', 'savePerms');
            fd.append('id', rolId);
            Object.entries(perms).forEach(([k, v]) => fd.append(k, v));

            const resp = await fetchJSON(API, { method: 'POST', body: fd });
            if (!resp.ok) {
                toast('error', resp.msg || 'No se pudo guardar permisos');
                return;
            }

            toast('success', resp.msg || 'Permisos guardados');
            if (msgPermTop) msgPermTop.textContent = 'Permisos guardados';
        }, true);
    }

    // ====== Init
    (async function init() {
        setModo(selectAccion?.value || '1');
        wireRolSelectChange();

        const sel = getRolSelect();
        if (sel && sel.value) {
            try {
                await cargarPermisosDeRol(sel.value);
            } catch (e) {
                console.error(e);
                resetChecks();
            }
        }
    })();
});
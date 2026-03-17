document.addEventListener('DOMContentLoaded', () => {
    const dir = (document.getElementById('url')?.value || '').trim();
    if (!dir) return;

    const API = dir + 'app/controllers/logUserAjax.php';

    const els = {
        q: document.getElementById('f_q'),
        qClear: document.getElementById('f_q_clear'),
        tabla: document.getElementById('f_tabla'),
        op: document.getElementById('f_operacion'),
        user: document.getElementById('f_usuario'),
        estadoLog: document.getElementById('f_estado_log'),
        perPage: document.getElementById('f_perPage'),
        desde: document.getElementById('f_desde'),
        hasta: document.getElementById('f_hasta'),
        reset: document.getElementById('f_reset'),

        reload: document.getElementById('btnLogsReload'),
        count: document.getElementById('logsCountBadge'),
        softCount: document.getElementById('logsSoftDeleteBadge'),
        restoreCount: document.getElementById('logsRestoreBadge'),
        meta: document.getElementById('logsMeta'),

        tableBody: document.querySelector('#logsTable tbody'),
        cards: document.getElementById('logsCards'),

        prev: document.getElementById('btnPrev'),
        next: document.getElementById('btnNext'),
        pageLabel: document.getElementById('pageLabel'),

        viewerEl: document.getElementById('logViewer'),
        vTitle: document.getElementById('v_title'),
        vSub: document.getElementById('v_sub'),
        vState: document.getElementById('v_state'),
        vUser: document.getElementById('v_user'),
        vDate: document.getElementById('v_date'),
        vTable: document.getElementById('v_table'),
        vOp: document.getElementById('v_op'),
        vPk: document.getElementById('v_pk'),
        vPkTech: document.getElementById('v_pk_tech'),
        vUuid: document.getElementById('v_uuid'),
        vChangedCols: document.getElementById('v_changed_cols'),
        vResp: document.getElementById('v_resp'),
        vPkJson: document.getElementById('v_pk_json'),
        vOld: document.getElementById('v_old'),
        vNew: document.getElementById('v_new'),
        vDiff: document.getElementById('v_diff'),

        btnRestore: document.getElementById('btnRestore'),
        restoreHint: document.getElementById('restoreHint'),
    };

    const state = {
        page: 1,
        perPage: Number(els.perPage?.value || 20),
        pages: 1,
        total: 0,
        lastDetailId: null,
        logStdSupported: true,
    };

    const OP_META = {
        INSERT: { label: 'Creacion', badge: 'bg-success', icon: 'bi-plus-circle' },
        UPDATE: { label: 'Actualizacion', badge: 'bg-info text-white', icon: 'bi-pencil-square' },
        DELETE: { label: 'Eliminacion fisica', badge: 'bg-danger', icon: 'bi-trash' },
        SOFT_DELETE: { label: 'Eliminacion logica', badge: 'bg-warning text-dark', icon: 'bi-trash3' },
        RESTORE: { label: 'Restauracion', badge: 'bg-primary', icon: 'bi-arrow-counterclockwise' },
        REACTIVAR: { label: 'Restauracion', badge: 'bg-primary', icon: 'bi-arrow-counterclockwise' },
        UNKNOWN: { label: 'Sistema', badge: 'bg-secondary', icon: 'bi-question-circle' },
    };

    const toast = (icon, title) => {
        if (!window.Swal) return;
        Swal.fire({
            toast: true,
            position: 'bottom-end',
            timer: 2800,
            showConfirmButton: false,
            icon,
            title
        });
    };

    function initTooltips(scope = document) {
        if (!window.bootstrap) return;
        const nodes = scope.querySelectorAll('[data-bs-toggle="tooltip"]');
        nodes.forEach((node) => {
            const old = bootstrap.Tooltip.getInstance(node);
            if (old) old.dispose();
            new bootstrap.Tooltip(node);
        });
    }

    function initHelpButtons() {
        document.addEventListener('click', (e) => {
            const btn = e.target.closest('.help-tip');
            if (!btn) return;
            e.preventDefault();

            const msg = (btn.getAttribute('data-help') || btn.getAttribute('title') || '').trim();
            if (!msg) return;

            if (window.Swal) {
                Swal.fire({
                    icon: 'info',
                    title: 'Ayuda',
                    text: msg,
                    confirmButtonText: 'Entendido'
                });
            } else {
                alert(msg);
            }
        });
    }

    async function confirmDialog({ title, text, confirmText }) {
        if (!window.Swal) return confirm(text || title || 'Confirmar');

        const r = await Swal.fire({
            title: title || 'Confirmar',
            text: text || 'Deseas continuar?',
            icon: 'question',
            showCancelButton: true,
            confirmButtonText: confirmText || 'Si',
            cancelButtonText: 'Cancelar',
            allowOutsideClick: false,
            allowEscapeKey: true,
        });
        return r.isConfirmed;
    }

    async function fetchJSON(url, options = {}) {
        const res = await fetch(url, options);
        const text = await res.text();

        if (text.trim().startsWith('<')) {
            console.error('Respuesta no JSON:', text);
            return { ok: false, msg: 'Respuesta invalida del servidor (HTML).' };
        }

        try {
            return JSON.parse(text);
        } catch (e) {
            console.error('JSON invalido:', text);
            return { ok: false, msg: 'JSON invalido del servidor.' };
        }
    }

    function escapeHtml(str) {
        return String(str ?? '')
            .replaceAll('&', '&amp;')
            .replaceAll('<', '&lt;')
            .replaceAll('>', '&gt;')
            .replaceAll('"', '&quot;')
            .replaceAll("'", '&#039;');
    }

    function toPrettyJSON(value) {
        if (value === null || value === undefined || value === '') return 'Sin datos';
        if (typeof value === 'object') return JSON.stringify(value, null, 2);

        const raw = String(value).trim();
        if (!raw) return 'Sin datos';

        try {
            const parsed = JSON.parse(raw);
            return JSON.stringify(parsed, null, 2);
        } catch (_) {
            return raw;
        }
    }

    function setText(el, value, fallback = '-') {
        if (!el) return;
        const txt = String(value ?? '').trim();
        el.textContent = txt !== '' ? txt : fallback;
    }

    function fillSelect(select, items, { valueKey = 'v', textKey = 't', emptyText = '-' } = {}) {
        if (!select) return;
        const prev = select.value;

        select.innerHTML = '';
        const opt0 = document.createElement('option');
        opt0.value = '';
        opt0.textContent = emptyText;
        select.appendChild(opt0);

        (items || []).forEach((it) => {
            const o = document.createElement('option');
            o.value = String(it[valueKey] ?? '');
            o.textContent = String(it[textKey] ?? it[valueKey] ?? '');
            select.appendChild(o);
        });

        if (prev) {
            const hasValue = [...select.options].some((o) => o.value === prev);
            if (hasValue) select.value = prev;
        }
    }

    function getOpMeta(op) {
        const key = String(op || '').toUpperCase();
        return OP_META[key] || {
            label: key || 'Evento',
            badge: 'bg-secondary',
            icon: 'bi-journal-text'
        };
    }

    function getStatusMeta(row) {
        const op = String(row.operacion || '').toUpperCase();
        const logStd = Number(row.log_std_reg ?? 1);

        if (logStd === 0) return { label: 'Restaurado', badge: 'bg-primary' };
        if (['SOFT_DELETE', 'DELETE'].includes(op)) return { label: 'Pendiente', badge: 'bg-warning text-dark' };
        if (['RESTORE', 'REACTIVAR'].includes(op)) return { label: 'Ejecutado', badge: 'bg-primary' };
        return { label: 'Registrado', badge: 'bg-success' };
    }

    function renderOpBadge(op) {
        const meta = getOpMeta(op);
        return `<span class="badge ${meta.badge}"><i class="bi ${meta.icon}"></i> ${escapeHtml(meta.label)}</span>`;
    }

    function renderStatusBadge(row) {
        const meta = getStatusMeta(row);
        return `<span class="badge ${meta.badge}">${escapeHtml(meta.label)}</span>`;
    }

    function getRegistroLabel(row) {
        return row.registro_label || row.pk_registro || '-';
    }

    function inferChangedColsClient(row) {
        const changed = String(row.changed_cols || '').trim();
        if (changed) return changed;

        try {
            const diff = row.data_diff ? (typeof row.data_diff === 'object' ? row.data_diff : JSON.parse(row.data_diff)) : null;
            if (diff && typeof diff === 'object' && !Array.isArray(diff)) {
                const keys = Object.keys(diff).filter(Boolean);
                if (keys.length) return keys.join(', ');
            }
        } catch (_) {
            // noop
        }

        return '';
    }

    function getQueryParams() {
        const p = new URLSearchParams();
        p.append('action', 'list');
        p.append('page', String(state.page));
        p.append('perPage', String(state.perPage));

        if (els.q?.value?.trim()) p.append('q', els.q.value.trim());
        if (els.tabla?.value) p.append('tabla', els.tabla.value);
        if (els.op?.value) p.append('operacion', els.op.value);
        if (els.user?.value) p.append('usuario', els.user.value);
        if (els.estadoLog?.value) p.append('estado_log', els.estadoLog.value);
        if (els.desde?.value) p.append('desde', els.desde.value);
        if (els.hasta?.value) p.append('hasta', els.hasta.value);

        return p;
    }

    function updateCounters(rows = []) {
        if (els.count) els.count.textContent = String(state.total || 0);

        const softDeletes = rows.filter((r) => ['SOFT_DELETE', 'DELETE'].includes(String(r.operacion || '').toUpperCase())).length;
        const restores = rows.filter((r) => ['RESTORE', 'REACTIVAR'].includes(String(r.operacion || '').toUpperCase()) || Number(r.log_std_reg || 1) === 0).length;

        if (els.softCount) els.softCount.textContent = String(softDeletes);
        if (els.restoreCount) els.restoreCount.textContent = String(restores);
    }

    function renderList(rows) {
        if (els.tableBody) els.tableBody.innerHTML = '';
        if (els.cards) els.cards.innerHTML = '';

        if (!rows || rows.length === 0) {
            if (els.tableBody) {
                els.tableBody.innerHTML = '<tr><td colspan="9" class="text-center text-muted py-3">Sin resultados</td></tr>';
            }
            if (els.cards) {
                els.cards.innerHTML = '<div class="text-center text-muted py-3">Sin resultados</div>';
            }
            updateCounters([]);
            return;
        }

        rows.forEach((r, i) => {
            const idx = (state.page - 1) * state.perPage + (i + 1);
            const registro = getRegistroLabel(r);
            const detalle = escapeHtml(r.detail_summary || r.resp_system || 'Sin detalle');
            const opBadge = renderOpBadge(r.operacion);
            const statusBadge = renderStatusBadge(r);
            const actionText = escapeHtml(r.accion || r.op_human || 'Evento del sistema');

            if (els.tableBody) {
                els.tableBody.insertAdjacentHTML('beforeend', `
                    <tr class="align-middle">
                        <td><b>${idx}</b></td>
                        <td class="logs-col-date">${escapeHtml(r.fecha || '-')}</td>
                        <td>${escapeHtml(r.usuario || r.id_user || '-')}</td>
                        <td><span class="badge bg-light text-dark">${escapeHtml(r.tabla || '-')}</span></td>
                        <td>
                            ${opBadge}
                            <div class="small text-muted mt-1">${actionText}</div>
                        </td>
                        <td class="small">${detalle}</td>
                        <td>${statusBadge}</td>
                        <td class="small font-monospace logs-col-record">${escapeHtml(registro)}</td>
                        <td class="text-center">
                            <button class="btn btn-sm btn-outline-primary js-view" data-id="${escapeHtml(r.id)}" type="button" title="Ver detalle">
                                <i class="bi bi-eye"></i>
                            </button>
                        </td>
                    </tr>
                `);
            }

            if (els.cards) {
                els.cards.insertAdjacentHTML('beforeend', `
                    <div class="logs-card">
                        <div class="d-flex justify-content-between align-items-start gap-2">
                            <div>
                                <div>${opBadge}</div>
                                <div class="small text-muted mt-1">${escapeHtml(r.fecha || '-')} - ${escapeHtml(r.usuario || r.id_user || '-')}</div>
                            </div>
                            ${statusBadge}
                        </div>
                        <div class="mt-2 small"><b>Modulo:</b> ${escapeHtml(r.tabla || '-')}</div>
                        <div class="small"><b>Accion:</b> ${actionText}</div>
                        <div class="small"><b>Detalle:</b> ${detalle}</div>
                        <div class="small font-monospace text-muted">${escapeHtml(registro)}</div>
                        <div class="mt-2 text-end">
                            <button class="btn btn-sm btn-outline-primary js-view" data-id="${escapeHtml(r.id)}" type="button">
                                <i class="bi bi-eye"></i> Ver detalle
                            </button>
                        </div>
                    </div>
                `);
            }
        });

        updateCounters(rows);
    }

    function updatePager(meta) {
        state.total = Number(meta.total || 0);
        state.pages = Number(meta.pages || 1);

        if (els.pageLabel) els.pageLabel.textContent = `${state.page} / ${state.pages}`;
        if (els.meta) els.meta.textContent = `Mostrando ${meta.from || 0}-${meta.to || 0} de ${state.total}`;
        if (els.prev) els.prev.disabled = state.page <= 1;
        if (els.next) els.next.disabled = state.page >= state.pages;
    }

    async function loadFilters() {
        const p = new URLSearchParams();
        p.append('action', 'filters');

        const data = await fetchJSON(API + '?' + p.toString(), { method: 'GET' });
        if (!data.ok) {
            toast('error', data.msg || 'No se pudieron cargar filtros');
            return;
        }

        fillSelect(els.tabla, data.tablas || [], { valueKey: 'tabla', textKey: 'tabla', emptyText: 'Todos' });
        fillSelect(els.op, data.operaciones || [], { valueKey: 'operacion', textKey: 'label', emptyText: 'Todas' });
        fillSelect(els.user, data.usuarios || [], { valueKey: 'id_user', textKey: 'user', emptyText: 'Todos' });

        state.logStdSupported = Number(data.log_std_supported || 0) === 1;
        if (!state.logStdSupported && els.estadoLog) {
            els.estadoLog.value = 'all';
            [...els.estadoLog.options].forEach((opt) => {
                if (['active', 'restored'].includes(opt.value)) opt.disabled = true;
            });
        }
    }

    async function loadList() {
        state.perPage = Number(els.perPage?.value || state.perPage || 20);

        const p = getQueryParams();
        const data = await fetchJSON(API + '?' + p.toString(), { method: 'GET' });

        if (!data.ok) {
            toast('error', data.msg || 'No se pudo cargar el listado');
            return;
        }

        renderList(data.rows || []);
        updatePager(data.meta || {});
    }

    function setStateBadge(row) {
        if (!els.vState) return;
        const meta = getStatusMeta(row || {});
        els.vState.className = `badge ${meta.badge}`;
        els.vState.textContent = meta.label;
    }

    function setJsonField(el, value) {
        if (!el) return;
        el.textContent = toPrettyJSON(value);
    }

    async function openDetail(id) {
        state.lastDetailId = id;

        const p = new URLSearchParams();
        p.append('action', 'detail');
        p.append('id', String(id));

        const data = await fetchJSON(API + '?' + p.toString(), { method: 'GET' });
        if (!data.ok) {
            toast('error', data.msg || 'No se pudo cargar el detalle');
            return;
        }

        const r = data.row || {};

        setText(els.vTitle, r.op_human, '-');
        setText(els.vSub, r.accion_human || r.accion, '-');
        setStateBadge(r);

        setText(els.vUser, r.usuario || r.id_user, '-');
        setText(els.vDate, r.fecha, '-');
        setText(els.vTable, r.tabla, '-');
        setText(els.vOp, r.operacion, '-');
        setText(els.vPk, getRegistroLabel(r), '-');
        setText(els.vPkTech, `PK tecnica: ${r.pk_tecnico || r.pk_registro || '-'}`, 'PK tecnica: -');
        setText(els.vUuid, r.event_uuid, '-');

        const changedCols = inferChangedColsClient(r);
        setText(els.vChangedCols, changedCols, 'Sin campos reportados');

        const detailText = [r.detail_summary || '', r.resp_system || ''].filter(Boolean).join('\n');
        setText(els.vResp, detailText, '-');

        setJsonField(els.vPkJson, r.pk_json);
        setJsonField(els.vOld, r.data_old);
        setJsonField(els.vNew, r.data_new);
        setJsonField(els.vDiff, r.data_diff);

        if (Number(r.can_restore || 0) === 1) {
            if (els.btnRestore) {
                els.btnRestore.style.display = '';
                els.btnRestore.dataset.id = String(id);
            }
            setText(els.restoreHint, r.restore_hint || 'Este evento es restaurable.');
        } else {
            if (els.btnRestore) {
                els.btnRestore.style.display = 'none';
                els.btnRestore.dataset.id = '';
            }
            setText(els.restoreHint, r.restore_hint || '');
        }

        if (window.bootstrap && els.viewerEl) {
            const inst = bootstrap.Offcanvas.getOrCreateInstance(els.viewerEl);
            inst.show();
        }
    }

    let debounceTimer = null;
    const debounceReload = () => {
        clearTimeout(debounceTimer);
        debounceTimer = setTimeout(() => {
            state.page = 1;
            loadList();
        }, 250);
    };

    els.q?.addEventListener('input', debounceReload);
    els.tabla?.addEventListener('change', debounceReload);
    els.op?.addEventListener('change', debounceReload);
    els.user?.addEventListener('change', debounceReload);
    els.estadoLog?.addEventListener('change', debounceReload);
    els.desde?.addEventListener('change', debounceReload);
    els.hasta?.addEventListener('change', debounceReload);
    els.perPage?.addEventListener('change', debounceReload);

    els.qClear?.addEventListener('click', () => {
        if (!els.q) return;
        els.q.value = '';
        debounceReload();
    });

    els.reset?.addEventListener('click', () => {
        if (els.q) els.q.value = '';
        if (els.tabla) els.tabla.value = '';
        if (els.op) els.op.value = '';
        if (els.user) els.user.value = '';
        if (els.desde) els.desde.value = '';
        if (els.hasta) els.hasta.value = '';
        if (els.estadoLog) els.estadoLog.value = state.logStdSupported ? 'active' : 'all';
        if (els.perPage) els.perPage.value = '20';

        state.page = 1;
        state.perPage = 20;
        loadList();
    });

    els.reload?.addEventListener('click', async () => {
        await loadFilters();
        await loadList();
        toast('success', 'Listado actualizado');
    });

    els.prev?.addEventListener('click', () => {
        if (state.page <= 1) return;
        state.page -= 1;
        loadList();
    });

    els.next?.addEventListener('click', () => {
        if (state.page >= state.pages) return;
        state.page += 1;
        loadList();
    });

    document.addEventListener('click', (e) => {
        const btn = e.target.closest('.js-view');
        if (!btn) return;
        const id = btn.getAttribute('data-id');
        if (!id) return;
        openDetail(id);
    });

    els.btnRestore?.addEventListener('click', async () => {
        const id = els.btnRestore.dataset.id;
        if (!id) return;

        const ok = await confirmDialog({
            title: 'Restaurar registro?',
            text: 'Se activara nuevamente el registro y sus dependencias eliminadas logicamente.',
            confirmText: 'Si, restaurar'
        });
        if (!ok) return;

        const fd = new FormData();
        fd.append('action', 'restore');
        fd.append('id', id);

        const r = await fetchJSON(API, { method: 'POST', body: fd });
        if (!r.ok) {
            toast('error', r.msg || 'No se pudo restaurar');
            return;
        }

        toast('success', r.msg || 'Restauracion ejecutada');
        if (r.warning) {
            toast('warning', r.warning);
        }

        await loadList();
        await openDetail(id);
    });

    (async function init() {
        initTooltips();
        initHelpButtons();
        await loadFilters();
        await loadList();
    })();
});

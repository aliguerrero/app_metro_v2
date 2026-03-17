document.addEventListener('DOMContentLoaded', () => {
    const dir = (document.getElementById('url')?.value || '').trim();
    const wrap = document.getElementById('dbBackupListWrap');
    const btnCreate = document.getElementById('btnCrearRespaldoDb');
    const btnReload = document.getElementById('btnRecargarRespaldosDb');
    const formRestore = document.getElementById('formRestoreDb');
    const fileInput = document.getElementById('restoreSqlFile');
    const confirmInput = document.getElementById('restoreConfirmText');
    const safetyCheck = document.getElementById('createSafetyBackup');

    const useSpecificTables = document.getElementById('backupUseSpecificTables');
    const tablesPicker = document.getElementById('backupTablesPicker');
    const tablesList = document.getElementById('backupTablesList');
    const btnSelectAllTables = document.getElementById('btnSelectAllBackupTables');
    const btnClearTables = document.getElementById('btnClearBackupTables');

    const formAutoConfig = document.getElementById('formAutoBackupConfig');
    const autoEnabled = document.getElementById('autoBackupEnabled');
    const autoFrequency = document.getElementById('autoBackupFrequency');
    const autoTime = document.getElementById('autoBackupTime');
    const autoWeekdayWrap = document.getElementById('autoBackupWeekdayWrap');
    const autoWeekday = document.getElementById('autoBackupWeekday');
    const autoMonthDayWrap = document.getElementById('autoBackupMonthDayWrap');
    const autoMonthDay = document.getElementById('autoBackupMonthDay');
    const autoMode = document.getElementById('autoBackupMode');
    const autoRetainCount = document.getElementById('autoBackupRetainCount');
    const autoTablesWrap = document.getElementById('autoBackupTablesWrap');
    const autoTablesList = document.getElementById('autoBackupTablesList');
    const autoTableActions = document.getElementById('autoBackupTableActions');
    const autoRunnerUrl = document.getElementById('autoBackupRunnerUrl');
    const btnCopyRunnerUrl = document.getElementById('btnCopyAutoRunnerUrl');
    const btnSaveAutoConfig = document.getElementById('btnSaveAutoBackupConfig');
    const btnRunAutoNow = document.getElementById('btnRunAutoBackupNow');
    const btnRotateAutoToken = document.getElementById('btnRotateAutoToken');
    const btnSelectAllAutoTables = document.getElementById('btnSelectAllAutoBackupTables');
    const btnClearAutoTables = document.getElementById('btnClearAutoBackupTables');
    const autoMetaInfo = document.getElementById('autoBackupMetaInfo');

    if (!dir || !wrap || !btnCreate || !formRestore) return;

    const API = dir + 'app/controllers/dbBackupCrud.php';
    const AUTO_FREQUENCY_LABELS = {
        daily: 'Diario',
        weekly: 'Semanal',
        monthly: 'Mensual'
    };

    let cachedTables = [];
    let autoConfigState = null;

    const escapeHtml = (text) => {
        return String(text || '')
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#039;');
    };

    const toSize = (bytes) => {
        const size = Number(bytes) || 0;
        if (size < 1024) return `${size} B`;
        if (size < 1024 * 1024) return `${(size / 1024).toFixed(2)} KB`;
        return `${(size / (1024 * 1024)).toFixed(2)} MB`;
    };

    const toRows = (rows) => {
        const n = Number(rows) || 0;
        return n.toLocaleString('es-VE');
    };

    const toast = (icon, title) => {
        if (!window.Swal) {
            alert(title);
            return;
        }
        Swal.fire({
            toast: true,
            position: 'bottom-end',
            timer: 3200,
            showConfirmButton: false,
            icon,
            title
        });
    };

    async function confirmDialog({ title, text, confirmText }) {
        if (!window.Swal) return confirm(text || title || 'Confirmar');

        const res = await Swal.fire({
            title: title || 'Confirmar',
            text: text || 'Deseas continuar?',
            icon: 'question',
            showCancelButton: true,
            confirmButtonText: confirmText || 'Si, continuar',
            cancelButtonText: 'Cancelar',
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            allowOutsideClick: false,
            allowEscapeKey: true
        });
        return res.isConfirmed;
    }

    async function fetchJSON(url, options = {}) {
        const res = await fetch(url, options);
        const text = await res.text();

        if (text.trim().startsWith('<')) {
            console.error('Respuesta HTML inesperada:', text);
            throw new Error('Respuesta no valida del servidor.');
        }

        try {
            return JSON.parse(text);
        } catch (e) {
            console.error('JSON invalido:', text);
            throw new Error('Respuesta JSON invalida.');
        }
    }

    function renderTableSelector(container, tables, checkboxClass, selectedTables = []) {
        if (!container) return;

        if (!Array.isArray(tables) || tables.length === 0) {
            container.innerHTML = '<div class="db-backup-table-item text-muted small">No se encontraron tablas.</div>';
            return;
        }

        const selectedSet = new Set((selectedTables || []).map((name) => String(name)));
        container.innerHTML = tables.map((item) => {
            const rawName = String(item?.name || '');
            const safeName = escapeHtml(rawName);
            const rows = toRows(item?.rows || 0);
            const checked = selectedSet.has(rawName) ? 'checked' : '';

            return `
                <div class="db-backup-table-item">
                    <label class="form-check db-backup-table-option">
                        <input class="form-check-input ${checkboxClass}" type="checkbox" value="${safeName}" ${checked}>
                        <span class="form-check-label ms-1 db-backup-table-text">
                            <b class="db-backup-table-name">${safeName}</b>
                            <small class="d-block text-muted">Filas aprox: ${rows}</small>
                        </span>
                    </label>
                </div>
            `;
        }).join('');
    }

    function getSelectedTables() {
        if (!tablesList) return [];
        return Array.from(tablesList.querySelectorAll('.js-backup-table:checked')).map((el) => el.value);
    }

    function setAllTablesChecked(checked) {
        if (!tablesList) return;
        tablesList.querySelectorAll('.js-backup-table').forEach((el) => {
            el.checked = !!checked;
        });
    }

    function getSelectedAutoTables() {
        if (!autoTablesList) return [];
        return Array.from(autoTablesList.querySelectorAll('.js-auto-backup-table:checked')).map((el) => el.value);
    }

    function setAllAutoTablesChecked(checked) {
        if (!autoTablesList) return;
        autoTablesList.querySelectorAll('.js-auto-backup-table').forEach((el) => {
            el.checked = !!checked;
        });
    }
    function renderList(files) {
        if (!Array.isArray(files) || files.length === 0) {
            wrap.innerHTML = '<div class="p-3 text-muted">No hay respaldos disponibles en db/backups/.</div>';
            return;
        }

        const rows = files.map((item, index) => {
            const file = escapeHtml(item.file);
            const date = escapeHtml(item.created_at || item.modified_at || '');
            const path = escapeHtml(item.relative_path || ('db/backups/' + item.file));
            const size = toSize(item.size);

            return `
                <tr class="align-middle">
                    <td class="text-center">${index + 1}</td>
                    <td>
                        <code>${file}</code>
                        <small class="d-block text-muted">${path}</small>
                    </td>
                    <td>${date}</td>
                    <td class="text-end">${size}</td>
                    <td class="text-center">
                        <div class="db-backup-actions">
                            <button type="button" class="btn btn-sm db-backup-btn db-backup-btn-restore js-db-backup-restore" data-file="${file}" title="Restaurar">
                                <i class="bi bi-arrow-counterclockwise"></i>
                            </button>
                            <button type="button" class="btn btn-sm db-backup-btn db-backup-btn-download js-db-backup-download" data-file="${file}" title="Descargar">
                                <i class="bi bi-download"></i>
                            </button>
                            <button type="button" class="btn btn-sm db-backup-btn db-backup-btn-delete js-db-backup-delete" data-file="${file}" title="Eliminar">
                                <i class="bi bi-trash"></i>
                            </button>
                        </div>
                    </td>
                </tr>
            `;
        }).join('');

        const cards = files.map((item, index) => {
            const file = escapeHtml(item.file);
            const date = escapeHtml(item.created_at || item.modified_at || '');
            const path = escapeHtml(item.relative_path || ('db/backups/' + item.file));
            const size = toSize(item.size);

            return `
                <div class="tool-card">
                    <div class="tool-card-head">
                        <span class="tool-code">#${index + 1} | Respaldo</span>
                        <span><b>${date}</b></span>
                    </div>
                    <div class="tool-body">
                        <div class="tool-row">
                            <div class="tool-label">Archivo</div>
                            <div class="tool-value db-backup-text-break" title="${file}">
                                <code>${file}</code>
                            </div>
                        </div>
                        <div class="tool-row">
                            <div class="tool-label">Ruta</div>
                            <div class="tool-value db-backup-text-break" title="${path}">
                                <small>${path}</small>
                            </div>
                        </div>
                        <div class="tool-row">
                            <div class="tool-label">Tamano</div>
                            <div class="tool-value">${size}</div>
                        </div>
                        <div class="tool-actions db-backup-card-actions">
                            <button type="button" class="btn btn-sm db-backup-btn db-backup-btn-restore js-db-backup-restore" data-file="${file}" title="Restaurar">
                                <i class="bi bi-arrow-counterclockwise me-1"></i>
                            </button>
                            <button type="button" class="btn btn-sm db-backup-btn db-backup-btn-download js-db-backup-download" data-file="${file}" title="Descargar">
                                <i class="bi bi-download me-1"></i>
                            </button>
                            <button type="button" class="btn btn-sm db-backup-btn db-backup-btn-delete js-db-backup-delete" data-file="${file}" title="Eliminar">
                                <i class="bi bi-trash me-1"></i>
                            </button>
                        </div>
                    </div>
                </div>
            `;
        }).join('');

        wrap.innerHTML = `
            <div class="d-none d-md-block">
                <div class="table-responsive p-3">
                    <table class="table table-sm table-striped table-hover mb-0">
                        <thead class="table-light">
                            <tr>
                                <th class="text-center">#</th>
                                <th>Archivo</th>
                                <th>Fecha y hora</th>
                                <th class="text-end">Tamano</th>
                                <th class="text-center">Acciones</th>
                            </tr>
                        </thead>
                        <tbody>${rows}</tbody>
                    </table>
                </div>
            </div>
            <div class="d-md-none p-3">
                <div class="tool-cards db-backup-cards">
                    ${cards}
                </div>
            </div>
        `;
    }

    function syncAutoFrequencyVisibility() {
        if (!autoFrequency) return;
        const frequency = String(autoFrequency.value || 'daily');

        if (autoWeekdayWrap) {
            autoWeekdayWrap.style.display = frequency === 'weekly' ? '' : 'none';
        }
        if (autoMonthDayWrap) {
            autoMonthDayWrap.style.display = frequency === 'monthly' ? '' : 'none';
        }
    }

    function syncAutoModeVisibility() {
        if (!autoMode) return;
        const mode = String(autoMode.value || 'full');
        const visible = mode === 'specific';

        if (autoTablesWrap) {
            autoTablesWrap.style.display = visible ? '' : 'none';
        }
        if (autoTableActions) {
            autoTableActions.style.display = visible ? '' : 'none';
        }
    }

    function buildAutoMetaText(cfg) {
        const enabled = Number(cfg?.enabled || 0) === 1;
        const frequency = String(cfg?.frequency || 'daily');
        const nextRunAt = cfg?.next_run_at ? String(cfg.next_run_at) : 'No programado';
        const lastRunAt = cfg?.last_run_at ? String(cfg.last_run_at) : 'Nunca';
        const lastFile = cfg?.last_file ? String(cfg.last_file) : 'Sin ejecuciones';
        const mode = String(cfg?.mode || 'full');
        const selectedCount = Array.isArray(cfg?.tables) ? cfg.tables.length : 0;
        const modeLabel = mode === 'specific' ? `Tablas especificas (${selectedCount})` : 'General';
        const statusLabel = enabled ? 'Activo' : 'Inactivo';
        const frequencyLabel = AUTO_FREQUENCY_LABELS[frequency] || frequency;

        return `Estado: ${statusLabel} | Frecuencia: ${frequencyLabel} | Modo: ${modeLabel} | Proximo: ${nextRunAt} | Ultimo: ${lastRunAt} | Archivo: ${lastFile}`;
    }

    function applyAutoConfig(config, runnerUrl = '') {
        if (!formAutoConfig || !config || typeof config !== 'object') return;

        autoConfigState = {
            enabled: Number(config.enabled || 0),
            frequency: String(config.frequency || 'daily'),
            run_time: String(config.run_time || '02:00'),
            weekday: Number(config.weekday || 1),
            month_day: Number(config.month_day || 1),
            mode: String(config.mode || 'full'),
            tables: Array.isArray(config.tables) ? config.tables.map((item) => String(item)) : [],
            retain_count: Number(config.retain_count || 30),
            runner_token: String(config.runner_token || ''),
            next_run_at: config.next_run_at || null,
            last_run_at: config.last_run_at || null,
            last_file: config.last_file || null
        };

        if (autoEnabled) autoEnabled.checked = autoConfigState.enabled === 1;
        if (autoFrequency) autoFrequency.value = autoConfigState.frequency;
        if (autoTime) autoTime.value = autoConfigState.run_time;
        if (autoWeekday) autoWeekday.value = String(Math.min(Math.max(autoConfigState.weekday, 1), 7));
        if (autoMonthDay) autoMonthDay.value = String(Math.min(Math.max(autoConfigState.month_day, 1), 31));
        if (autoMode) autoMode.value = autoConfigState.mode;
        if (autoRetainCount) autoRetainCount.value = String(Math.min(Math.max(autoConfigState.retain_count, 0), 365));
        if (autoRunnerUrl) {
            const fallbackRunner = `${API}?action=auto_runner&token=${encodeURIComponent(autoConfigState.runner_token || '')}`;
            autoRunnerUrl.value = runnerUrl || fallbackRunner;
        }
        if (autoMetaInfo) {
            autoMetaInfo.textContent = buildAutoMetaText(autoConfigState);
        }

        syncAutoFrequencyVisibility();
        syncAutoModeVisibility();
        renderTableSelector(autoTablesList, cachedTables, 'js-auto-backup-table', autoConfigState.tables);
    }

    function setAutoButtonsState(disabled) {
        [btnSaveAutoConfig, btnRunAutoNow, btnRotateAutoToken, btnCopyRunnerUrl].forEach((btn) => {
            if (btn) btn.disabled = !!disabled;
        });
    }
    async function copyToClipboard(text) {
        const value = String(text || '').trim();
        if (!value) {
            throw new Error('No hay URL para copiar.');
        }

        if (navigator.clipboard && typeof navigator.clipboard.writeText === 'function') {
            await navigator.clipboard.writeText(value);
            return;
        }

        const helper = document.createElement('input');
        helper.type = 'text';
        helper.value = value;
        helper.style.position = 'fixed';
        helper.style.opacity = '0';
        document.body.appendChild(helper);
        helper.focus();
        helper.select();
        const ok = document.execCommand('copy');
        document.body.removeChild(helper);

        if (!ok) {
            throw new Error('No se pudo copiar la URL.');
        }
    }

    async function loadBackups() {
        const data = await fetchJSON(API + '?action=list', { method: 'GET' });
        if (!data.ok) {
            throw new Error(data.msg || 'No se pudo cargar la lista de respaldos.');
        }
        renderList(data.files || []);
    }

    async function loadTables() {
        if (!tablesList) return;

        const data = await fetchJSON(API + '?action=tables', { method: 'GET' });
        if (!data.ok) {
            throw new Error(data.msg || 'No se pudo cargar la lista de tablas.');
        }

        cachedTables = Array.isArray(data.tables) ? data.tables : [];
        renderTableSelector(tablesList, cachedTables, 'js-backup-table');
        renderTableSelector(autoTablesList, cachedTables, 'js-auto-backup-table', autoConfigState?.tables || []);
    }

    async function loadAutoConfig() {
        if (!formAutoConfig) return;

        const data = await fetchJSON(API + '?action=auto_get', { method: 'GET' });
        if (!data.ok) {
            throw new Error(data.msg || 'No se pudo cargar la configuracion automatica.');
        }

        applyAutoConfig(data.config || {}, data.runner_url || '');
    }

    async function saveAutoConfig({ rotateToken = false } = {}) {
        if (!formAutoConfig) return null;

        const modeValue = String(autoMode?.value || 'full');
        const tables = modeValue === 'specific' ? getSelectedAutoTables() : [];

        if (modeValue === 'specific' && tables.length === 0) {
            toast('warning', 'Selecciona al menos una tabla para respaldo automatico especifico.');
            return null;
        }

        setAutoButtonsState(true);
        try {
            const fd = new FormData();
            fd.append('action', 'auto_save');
            fd.append('enabled', autoEnabled?.checked ? '1' : '0');
            fd.append('frequency', autoFrequency?.value || 'daily');
            fd.append('run_time', autoTime?.value || '02:00');
            fd.append('weekday', autoWeekday?.value || '1');
            fd.append('month_day', autoMonthDay?.value || '1');
            fd.append('mode', modeValue);
            fd.append('retain_count', autoRetainCount?.value || '30');
            fd.append('rotate_token', rotateToken ? '1' : '0');
            tables.forEach((table) => fd.append('auto_tables[]', table));

            const data = await fetchJSON(API, { method: 'POST', body: fd });
            if (!data.ok) {
                throw new Error(data.msg || 'No se pudo guardar la configuracion automatica.');
            }

            applyAutoConfig(data.config || {}, data.runner_url || '');
            toast('success', data.msg || 'Configuracion automatica guardada.');
            return data;
        } finally {
            setAutoButtonsState(false);
        }
    }

    if (useSpecificTables && tablesPicker) {
        useSpecificTables.addEventListener('change', () => {
            if (useSpecificTables.checked) {
                tablesPicker.classList.remove('d-none');
                return;
            }
            tablesPicker.classList.add('d-none');
        });
    }

    if (btnSelectAllTables) {
        btnSelectAllTables.addEventListener('click', () => setAllTablesChecked(true));
    }

    if (btnClearTables) {
        btnClearTables.addEventListener('click', () => setAllTablesChecked(false));
    }

    if (btnSelectAllAutoTables) {
        btnSelectAllAutoTables.addEventListener('click', () => setAllAutoTablesChecked(true));
    }

    if (btnClearAutoTables) {
        btnClearAutoTables.addEventListener('click', () => setAllAutoTablesChecked(false));
    }

    if (autoFrequency) {
        autoFrequency.addEventListener('change', syncAutoFrequencyVisibility);
    }

    if (autoMode) {
        autoMode.addEventListener('change', syncAutoModeVisibility);
    }

    if (btnCopyRunnerUrl) {
        btnCopyRunnerUrl.addEventListener('click', async () => {
            try {
                await copyToClipboard(autoRunnerUrl?.value || '');
                toast('success', 'URL copiada al portapapeles.');
            } catch (error) {
                toast('error', error.message || 'No se pudo copiar la URL.');
            }
        });
    }

    if (formAutoConfig) {
        formAutoConfig.addEventListener('submit', async (e) => {
            e.preventDefault();
            try {
                await saveAutoConfig({ rotateToken: false });
            } catch (error) {
                toast('error', error.message || 'No se pudo guardar la configuracion automatica.');
            }
        });
    }

    if (btnRotateAutoToken) {
        btnRotateAutoToken.addEventListener('click', async () => {
            const ok = await confirmDialog({
                title: 'Regenerar token',
                text: 'La URL actual dejara de funcionar. Debes actualizarla en tu programador.',
                confirmText: 'Si, regenerar'
            });
            if (!ok) return;

            try {
                await saveAutoConfig({ rotateToken: true });
            } catch (error) {
                toast('error', error.message || 'No se pudo regenerar el token.');
            }
        });
    }

    if (btnRunAutoNow) {
        btnRunAutoNow.addEventListener('click', async () => {
            const ok = await confirmDialog({
                title: 'Ejecutar respaldo automatico',
                text: 'Se ejecutara un respaldo con la configuracion automatica actual.',
                confirmText: 'Si, ejecutar'
            });
            if (!ok) return;

            setAutoButtonsState(true);
            try {
                const fd = new FormData();
                fd.append('action', 'auto_run_now');
                const data = await fetchJSON(API, { method: 'POST', body: fd });

                if (!data.ok) {
                    throw new Error(data.msg || 'No se pudo ejecutar el respaldo automatico.');
                }

                const result = data.result || {};
                if (result.ran && result.backup?.file) {
                    toast('success', `Respaldo automatico generado: ${result.backup.file}`);
                } else {
                    toast('info', 'El respaldo automatico no se ejecuto en este momento.');
                }

                await loadBackups();
                await loadAutoConfig();
            } catch (error) {
                toast('error', error.message || 'Error al ejecutar respaldo automatico.');
            } finally {
                setAutoButtonsState(false);
            }
        });
    }
    btnCreate.addEventListener('click', async () => {
        const isPartial = !!(useSpecificTables && useSpecificTables.checked);
        const selectedTables = isPartial ? getSelectedTables() : [];

        if (isPartial && selectedTables.length === 0) {
            toast('warning', 'Selecciona al menos una tabla para generar respaldo parcial.');
            return;
        }

        const confirmText = isPartial
            ? `Se generara un respaldo de ${selectedTables.length} tabla(s) seleccionada(s).`
            : 'Se generara una copia completa de la base de datos actual.';

        const ok = await confirmDialog({
            title: 'Crear respaldo',
            text: confirmText,
            confirmText: 'Si, generar'
        });
        if (!ok) return;

        btnCreate.disabled = true;
        try {
            const fd = new FormData();
            fd.append('action', 'create');
            if (isPartial) {
                selectedTables.forEach((table) => fd.append('selected_tables[]', table));
            }

            const data = await fetchJSON(API, { method: 'POST', body: fd });
            if (!data.ok) {
                toast('error', data.msg || 'No se pudo crear el respaldo.');
                return;
            }

            toast('success', data.msg || 'Respaldo generado.');
            await loadBackups();

            if (window.Swal) {
                const result = await Swal.fire({
                    icon: 'success',
                    title: 'Respaldo generado',
                    text: (data.msg || 'Respaldo generado.') + ' Puedes descargarlo desde la lista.',
                    showCancelButton: !!data.download_url,
                    confirmButtonText: data.download_url ? 'Descargar ahora' : 'Aceptar',
                    cancelButtonText: 'Cerrar'
                });
                if (result.isConfirmed && data.download_url) {
                    window.location.href = data.download_url;
                }
            }
        } catch (error) {
            toast('error', error.message || 'Error al generar respaldo.');
        } finally {
            btnCreate.disabled = false;
        }
    });

    if (btnReload) {
        btnReload.addEventListener('click', async () => {
            try {
                await loadBackups();
                toast('success', 'Lista de respaldos actualizada.');
            } catch (error) {
                toast('error', error.message || 'No se pudo recargar.');
            }
        });
    }

    wrap.addEventListener('click', async (e) => {
        const btnRestoreSaved = e.target.closest('.js-db-backup-restore');
        const btnDownload = e.target.closest('.js-db-backup-download');
        const btnDelete = e.target.closest('.js-db-backup-delete');

        if (btnRestoreSaved) {
            const file = btnRestoreSaved.getAttribute('data-file');
            if (!file) return;

            const ok = await confirmDialog({
                title: 'Restaurar respaldo guardado',
                text: `Se restaurara ${file}. Se creara un respaldo de seguridad antes de ejecutar.`,
                confirmText: 'Si, restaurar'
            });
            if (!ok) return;

            try {
                const fd = new FormData();
                fd.append('action', 'restore_saved');
                fd.append('file', file);
                fd.append('create_safety_backup', '1');

                const data = await fetchJSON(API, { method: 'POST', body: fd });
                if (!data.ok) {
                    toast('error', data.msg || 'No se pudo restaurar el respaldo.');
                    return;
                }

                let msg = data.msg || 'Restauracion completada.';
                if (data.safety_backup && data.safety_backup.file) {
                    msg += ` Respaldo de seguridad: ${data.safety_backup.file}`;
                }

                if (window.Swal) {
                    await Swal.fire({
                        icon: 'success',
                        title: 'Restauracion completada',
                        text: msg,
                        confirmButtonText: 'Aceptar'
                    });
                } else {
                    alert(msg);
                }

                await loadBackups();
            } catch (error) {
                toast('error', error.message || 'Error al restaurar respaldo guardado.');
            }
            return;
        }

        if (btnDownload) {
            const file = btnDownload.getAttribute('data-file');
            if (!file) return;
            window.location.href = API + '?action=download&file=' + encodeURIComponent(file);
            return;
        }

        if (btnDelete) {
            const file = btnDelete.getAttribute('data-file');
            if (!file) return;

            const ok = await confirmDialog({
                title: 'Eliminar respaldo',
                text: `Se eliminara el archivo ${file}.`,
                confirmText: 'Si, eliminar'
            });
            if (!ok) return;

            try {
                const fd = new FormData();
                fd.append('action', 'delete');
                fd.append('file', file);

                const data = await fetchJSON(API, { method: 'POST', body: fd });
                if (!data.ok) {
                    toast('error', data.msg || 'No se pudo eliminar el respaldo.');
                    return;
                }

                toast('success', data.msg || 'Respaldo eliminado.');
                await loadBackups();
            } catch (error) {
                toast('error', error.message || 'Error al eliminar respaldo.');
            }
        }
    });

    formRestore.addEventListener('submit', async (e) => {
        e.preventDefault();

        const file = fileInput?.files?.[0];
        if (!file) {
            toast('warning', 'Debes seleccionar un archivo .sql');
            return;
        }

        if (!/\.sql$/i.test(file.name)) {
            toast('warning', 'El archivo debe tener extension .sql');
            return;
        }

        const token = (confirmInput?.value || '').trim().toUpperCase();
        if (token !== 'RESTAURAR') {
            toast('warning', 'Escribe RESTAURAR para confirmar la accion.');
            return;
        }

        const ok = await confirmDialog({
            title: 'Restaurar base de datos',
            text: 'La restauracion sobrescribira datos existentes. Esta accion puede tardar varios minutos.',
            confirmText: 'Si, restaurar'
        });
        if (!ok) return;

        const btnRestore = document.getElementById('btnRestaurarDb');
        if (btnRestore) btnRestore.disabled = true;

        try {
            const fd = new FormData();
            fd.append('action', 'restore');
            fd.append('sql_file', file);
            fd.append('create_safety_backup', safetyCheck?.checked ? '1' : '0');

            const data = await fetchJSON(API, { method: 'POST', body: fd });
            if (!data.ok) {
                toast('error', data.msg || 'No se pudo restaurar la base de datos.');
                return;
            }

            let msg = data.msg || 'Restauracion completada.';
            if (data.safety_backup && data.safety_backup.file) {
                msg += ` Respaldo de seguridad: ${data.safety_backup.file}`;
            }

            if (window.Swal) {
                await Swal.fire({
                    icon: 'success',
                    title: 'Restauracion completada',
                    text: msg,
                    confirmButtonText: 'Aceptar'
                });
            } else {
                alert(msg);
            }

            formRestore.reset();
            if (useSpecificTables && tablesPicker) {
                useSpecificTables.checked = false;
                tablesPicker.classList.add('d-none');
            }
            setAllTablesChecked(false);
            await loadBackups();
        } catch (error) {
            toast('error', error.message || 'Error al restaurar.');
        } finally {
            if (btnRestore) btnRestore.disabled = false;
        }
    });

    loadBackups().catch((error) => {
        wrap.innerHTML = '<div class="p-3 text-danger">No se pudo cargar la lista de respaldos.</div>';
        console.error(error);
    });

    loadTables().catch((error) => {
        if (tablesList) {
            tablesList.innerHTML = '<div class="db-backup-table-item text-danger small">No se pudo cargar la lista de tablas.</div>';
        }
        if (autoTablesList) {
            autoTablesList.innerHTML = '<div class="db-backup-table-item text-danger small">No se pudo cargar la lista de tablas.</div>';
        }
        console.error(error);
    });

    loadAutoConfig().catch((error) => {
        if (autoMetaInfo) {
            autoMetaInfo.textContent = 'No se pudo cargar la configuracion automatica.';
        }
        if (autoTablesList && autoTablesList.children.length === 0) {
            autoTablesList.innerHTML = '<div class="db-backup-table-item text-danger small">No se pudo cargar la configuracion automatica.</div>';
        }
        console.error(error);
    });
});

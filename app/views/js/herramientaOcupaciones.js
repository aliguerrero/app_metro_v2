document.addEventListener('DOMContentLoaded', () => {
    const dir = document.getElementById('url')?.value || '';
    const modal = document.getElementById('herramientaOcupacionesModal');

    if (!modal) return;

    const toolCode = modal.querySelector('#ocupHerrToolCode');
    const toolName = modal.querySelector('#ocupHerrToolName');
    const toolSummary = modal.querySelector('#ocupHerrToolSummary');
    const tableBody = modal.querySelector('#ocupHerrTable tbody');
    const cards = modal.querySelector('#ocupHerrCards');
    const endpoint = `${dir}app/controllers/cargarHerramientasOt.php`;

    function escapeHtml(value) {
        return String(value ?? '')
            .replaceAll('&', '&amp;')
            .replaceAll('<', '&lt;')
            .replaceAll('>', '&gt;')
            .replaceAll('"', '&quot;')
            .replaceAll("'", '&#039;');
    }

    function contactValue(value, type) {
        const clean = String(value || '').trim();
        if (!clean) return '<span class="text-muted">No disponible</span>';

        if (type === 'phone') {
            const href = clean.replace(/[^\d+]/g, '');
            return `<a href="tel:${escapeHtml(href)}">${escapeHtml(clean)}</a>`;
        }

        if (type === 'email') {
            return `<a href="mailto:${escapeHtml(clean)}">${escapeHtml(clean)}</a>`;
        }

        return escapeHtml(clean);
    }

    function renderRows(data) {
        tableBody.innerHTML = '';
        cards.innerHTML = '';

        if (!Array.isArray(data) || data.length === 0) {
            tableBody.innerHTML = '<tr><td colspan="8" class="text-center">No hay O.T. ocupando esta herramienta</td></tr>';
            cards.innerHTML = '<div class="text-muted text-center py-3">No hay O.T. ocupando esta herramienta</div>';
            return;
        }

        data.forEach((row, index) => {
            const telefono = contactValue(row.telefono, 'phone');
            const correo = contactValue(row.correo, 'email');
            const tecnicoNombre = escapeHtml(row.tecnico_nombre || 'Sin tecnico asignado');
            const tecnicoId = escapeHtml(row.tecnico_id || '');
            const estado = escapeHtml(row.estado_ot || 'SIN ESTADO');
            const trabajo = escapeHtml(row.nombre_trab || '-');
            const ot = escapeHtml(row.n_ot || '-');
            const cantidad = escapeHtml(row.cantidad || '0');

            tableBody.insertAdjacentHTML('beforeend', `
                <tr class="align-middle">
                    <td><b>${index + 1}</b></td>
                    <td><b>${ot}</b></td>
                    <td>${trabajo}</td>
                    <td class="text-center"><b>${cantidad}</b></td>
                    <td>${estado}</td>
                    <td>${tecnicoNombre}<br><small class="text-muted">${tecnicoId}</small></td>
                    <td>${telefono}</td>
                    <td>${correo}</td>
                </tr>
            `);

            cards.insertAdjacentHTML('beforeend', `
                <div class="tool-card mb-2">
                    <div class="tool-card-head">
                        <span class="tool-code">#${index + 1} - ${ot}</span>
                        <span><b>Cant:</b> ${cantidad}</span>
                    </div>
                    <div class="tool-body">
                        <div class="tool-row">
                            <div class="tool-label">Trabajo</div>
                            <div class="tool-value">${trabajo}</div>
                        </div>
                        <div class="tool-row">
                            <div class="tool-label">Estado O.T.</div>
                            <div class="tool-value">${estado}</div>
                        </div>
                        <div class="tool-row">
                            <div class="tool-label">Tecnico</div>
                            <div class="tool-value">${tecnicoNombre}<br><small class="text-muted">${tecnicoId}</small></div>
                        </div>
                        <div class="tool-row">
                            <div class="tool-label">Telefono</div>
                            <div class="tool-value">${telefono}</div>
                        </div>
                        <div class="tool-row" style="border-bottom:0;">
                            <div class="tool-label">Correo</div>
                            <div class="tool-value">${correo}</div>
                        </div>
                    </div>
                </div>
            `);
        });
    }

    async function cargarOcupaciones(toolId, toolLabel) {
        if (!toolId) return;

        if (toolCode) toolCode.textContent = toolId;
        if (toolName) toolName.textContent = toolLabel || '-';
        if (toolSummary) toolSummary.textContent = 'Consultando ocupaciones...';
        tableBody.innerHTML = '<tr><td colspan="8" class="text-center">Cargando...</td></tr>';
        cards.innerHTML = '<div class="text-muted text-center py-3">Cargando...</div>';

        const params = new URLSearchParams({
            tipo: 'ocupaciones',
            herramienta_id: toolId,
            q: ''
        });

        try {
            const res = await fetch(`${endpoint}?${params.toString()}`, {
                headers: {
                    'Accept': 'application/json',
                    'X-Requested-With': 'XMLHttpRequest'
                }
            });
            const payload = await res.json();

            if (!res.ok || payload?.ok === false) {
                throw new Error(payload?.detail || payload?.error || 'No fue posible consultar las ocupaciones.');
            }

            const data = payload.data || [];
            if (toolSummary) {
                toolSummary.textContent = data.length
                    ? `${data.length} O.T. con esta herramienta asignada`
                    : 'No hay O.T. ocupando esta herramienta';
            }
            renderRows(data);
        } catch (error) {
            if (toolSummary) toolSummary.textContent = 'No fue posible completar la consulta';
            renderRows([]);
            if (typeof Swal !== 'undefined') {
                Swal.fire({
                    icon: 'error',
                    title: 'No se pudo cargar',
                    text: error.message || 'No fue posible consultar las ocupaciones.'
                });
            }
        }
    }

    document.addEventListener('click', (event) => {
        const trigger = event.target.closest('.js-tool-ocupaciones');
        if (!trigger) return;
        cargarOcupaciones(trigger.dataset.id || '', trigger.dataset.nombre || '');
    });
});

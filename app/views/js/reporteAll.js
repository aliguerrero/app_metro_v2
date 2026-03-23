// app/views/js/reporteAll.js

document.addEventListener('DOMContentLoaded', () => {
    const dir = document.getElementById('url')
        ? document.getElementById('url').value
        : (window.APP_URL || '/');

    const base = (dir.endsWith('/') ? dir : dir + '/');

    const tipoReporte = document.getElementById('tipo_reporte');
    const papel = document.getElementById('papel');
    const orientacion = document.getElementById('orientacion');
    const incMembrete = document.getElementById('incluir_membrete');
    const incLogo = document.getElementById('incluir_logo');

    const filtrosOt = document.getElementById('filtros_ot');
    const filtrosGeneral = document.getElementById('filtros_general');

    const fNot = document.getElementById('f_n_ot');
    const fDesde = document.getElementById('f_desde');
    const fHasta = document.getElementById('f_hasta');
    const fArea = document.getElementById('f_area');
    const fSitio = document.getElementById('f_sitio');
    const fEstado = document.getElementById('f_estado');
    const fUsuario = document.getElementById('f_usuario');

    const fQ = document.getElementById('f_q');

    const btnPrev = document.getElementById('btn_previsualizar');
    const btnPdf = document.getElementById('btn_pdf');
    const btnLimpiar = document.getElementById('btn_limpiar_preview');
    const btnRecargarReportes = document.getElementById('btn_recargar_reportes_modal');
    const modalReportesGenerados = document.getElementById('modalReportesGenerados');
    const previewFrame = document.getElementById('previewFrame');
    const reportesGeneradosWrap = document.getElementById('reportesGeneradosWrap');

    const debounce = (fn, wait = 450) => {
        let t = null;
        return (...args) => {
            clearTimeout(t);
            t = setTimeout(() => fn(...args), wait);
        };
    };

    const setPreviewHtml = (html) => {
        previewFrame.srcdoc =
            html || '<div style="font-family:Arial;padding:16px;color:#666;">Sin vista previa</div>';
    };

    const buildParams = () => {
        const params = new URLSearchParams();
        params.set('tipo', tipoReporte.value || '');
        params.set('papel', papel.value || 'A4');
        params.set('orientacion', orientacion.value || 'portrait');
        params.set('membrete', incMembrete.checked ? '1' : '0');
        params.set('logo', incLogo.checked ? '1' : '0');

        params.set('n_ot', (fNot && fNot.value) ? fNot.value.trim() : '');
        params.set('desde', (fDesde && fDesde.value) ? fDesde.value : '');
        params.set('hasta', (fHasta && fHasta.value) ? fHasta.value : '');
        params.set('area', (fArea && fArea.value) ? fArea.value : '');
        params.set('sitio', (fSitio && fSitio.value) ? fSitio.value : '');
        params.set('estado', (fEstado && fEstado.value) ? fEstado.value : '');
        params.set('usuario', (fUsuario && fUsuario.value) ? fUsuario.value : '');

        params.set('q', (fQ && fQ.value) ? fQ.value.trim() : '');

        return params;
    };

    const actualizarSecciones = () => {
        const t = tipoReporte.value;
        const esOT = (t === 'ot_resumen' || t === 'ot_detallado');

        filtrosOt.style.display = esOT ? '' : 'none';
        filtrosGeneral.style.display = (!esOT && t) ? '' : 'none';

        if (!t) {
            filtrosOt.style.display = 'none';
            filtrosGeneral.style.display = 'none';
        }
    };

    const aplicarPresetTipo = () => {
        const t = tipoReporte.value;

        if (t === 'ot_detallado') {
            if (orientacion.value === 'portrait') {
                orientacion.value = 'landscape';
                orientacion.dataset.autoPreset = '1';
            }
            return;
        }

        if (orientacion.dataset.autoPreset === '1') {
            orientacion.value = 'portrait';
            delete orientacion.dataset.autoPreset;
        }
    };

    const cargarReportesGenerados = async () => {
        if (!reportesGeneradosWrap) return;

        reportesGeneradosWrap.innerHTML = '<div class="text-muted">Cargando historial de reportes...</div>';

        try {
            const res = await fetch(base + 'app/controllers/reporteGeneradoList.php', {
                method: 'GET',
                credentials: 'include',
                headers: { Accept: 'text/html' }
            });

            const html = await res.text();

            if (!res.ok) {
                reportesGeneradosWrap.innerHTML = '<div class="alert alert-danger m-0">No se pudo cargar el historial de reportes.</div>';
                return;
            }

            reportesGeneradosWrap.innerHTML = html;
            reportesGeneradosWrap.dataset.loaded = '1';
        } catch (error) {
            console.error('Error cargando historial de reportes:', error);
            reportesGeneradosWrap.innerHTML = '<div class="alert alert-danger m-0">Error cargando el historial de reportes.</div>';
            reportesGeneradosWrap.dataset.loaded = '0';
        }
    };

    const cargarCombos = async () => {
        try {
            const res = await fetch(base + 'app/controllers/cargarFiltrosReporte.php', {
                method: 'GET',
                credentials: 'include',
                headers: { Accept: 'application/json' }
            });

            if (res.status === 401) {
                console.error('401: sesion no iniciada (cookie no enviada o sesion expirada)');
                return;
            }

            if (res.status === 403) {
                console.error('403: permiso denegado (perm_ot_view)');
                return;
            }

            if (!res.ok) {
                console.error('HTTP error cargando filtros:', res.status);
                return;
            }

            const data = await res.json();

            if (!data?.ok) {
                console.error('Backend ok=false cargando filtros:', data);
                return;
            }

            if (fArea && Array.isArray(data.areas)) {
                data.areas.forEach((a) => {
                    const opt = document.createElement('option');
                    opt.value = a.id_area ?? a.id_ai_area ?? '';
                    opt.textContent = a.nombre_area;
                    fArea.appendChild(opt);
                });
            }

            if (fSitio && Array.isArray(data.sitios)) {
                data.sitios.forEach((s) => {
                    const opt = document.createElement('option');
                    opt.value = s.id_sitio ?? s.id_ai_sitio ?? '';
                    opt.textContent = s.nombre_sitio;
                    fSitio.appendChild(opt);
                });
            }

            if (fEstado && Array.isArray(data.estados)) {
                data.estados.forEach((e) => {
                    const opt = document.createElement('option');
                    opt.value = e.id_estado ?? e.id_ai_estado ?? '';
                    opt.textContent = e.nombre_estado;
                    fEstado.appendChild(opt);
                });
            }

            if (fUsuario && Array.isArray(data.usuarios)) {
                data.usuarios.forEach((u) => {
                    const opt = document.createElement('option');
                    opt.value = u.id_user;
                    opt.textContent = `${u.user} (${u.username})`;
                    fUsuario.appendChild(opt);
                });
            }
        } catch (e) {
            console.error('Error cargando combos de reportes:', e);
        }
    };

    const previsualizar = async () => {
        const t = tipoReporte.value;
        if (!t) {
            setPreviewHtml('<div style="font-family:Arial;padding:16px;">Selecciona un tipo de reporte.</div>');
            return;
        }

        const params = buildParams();

        try {
            const res = await fetch(base + 'app/controllers/cargarDatosReporte.php?' + params.toString(), {
                credentials: 'include',
                headers: { Accept: 'application/json' }
            });

            const raw = await res.text();

            if (res.status === 401) {
                setPreviewHtml('<div style="font-family:Arial;padding:16px;color:#b00;">Sesion no iniciada o expirada.</div>');
                return;
            }

            if (res.status === 403) {
                setPreviewHtml('<div style="font-family:Arial;padding:16px;color:#b00;">Permiso denegado.</div>');
                return;
            }

            if (!res.ok) {
                const safe = (raw || '')
                    .replace(/&/g, '&amp;')
                    .replace(/</g, '&lt;')
                    .replace(/>/g, '&gt;');

                setPreviewHtml(`
        <div style="font-family:Arial;padding:16px;color:#b00;">
          Error HTTP (${res.status}) generando vista previa.
          <pre style="white-space:pre-wrap;background:#fff3f3;padding:12px;border:1px solid #f2b8b8;margin-top:12px;">${safe}</pre>
        </div>
      `);
                return;
            }

            if (raw.trim().startsWith('<')) {
                console.error('Respuesta no JSON (probable error PHP):', raw);

                const safe = raw
                    .replace(/&/g, '&amp;')
                    .replace(/</g, '&lt;')
                    .replace(/>/g, '&gt;');

                setPreviewHtml(`
        <div style="font-family:Arial;padding:16px;color:#b00;">
          El servidor devolvio HTML en lugar de JSON (probable error PHP).
          <pre style="white-space:pre-wrap;background:#fff3f3;padding:12px;border:1px solid #f2b8b8;margin-top:12px;">${safe}</pre>
        </div>
      `);
                return;
            }

            let data;
            try {
                data = JSON.parse(raw);
            } catch (e) {
                console.error('JSON invalido:', raw);

                const safe = (raw || '')
                    .replace(/&/g, '&amp;')
                    .replace(/</g, '&lt;')
                    .replace(/>/g, '&gt;');

                setPreviewHtml(`
        <div style="font-family:Arial;padding:16px;color:#b00;">
          Respuesta no es JSON valido.
          <pre style="white-space:pre-wrap;background:#fff3f3;padding:12px;border:1px solid #f2b8b8;margin-top:12px;">${safe}</pre>
        </div>
      `);
                return;
            }

            if (data?.ok) {
                setPreviewHtml(data.html);
            } else {
                setPreviewHtml(
                    `<div style="font-family:Arial;padding:16px;color:#b00;">${data?.msg ? data.msg : 'No se pudo generar la vista previa.'}</div>`
                );
            }
        } catch (e) {
            console.error(e);
            setPreviewHtml('<div style="font-family:Arial;padding:16px;color:#b00;">Error generando vista previa.</div>');
        }
    };

    const autoPreview = debounce(previsualizar, 500);

    tipoReporte.addEventListener('change', () => {
        aplicarPresetTipo();
        actualizarSecciones();
        autoPreview();
    });

    [papel, orientacion, incMembrete, incLogo].forEach((el) => {
        el.addEventListener('change', autoPreview);
    });

    [fNot, fDesde, fHasta, fArea, fSitio, fEstado, fUsuario].forEach((el) => {
        if (!el) return;
        el.addEventListener('input', autoPreview);
        el.addEventListener('change', autoPreview);
    });

    if (fQ) fQ.addEventListener('input', autoPreview);

    btnPrev.addEventListener('click', (e) => {
        e.preventDefault();
        previsualizar();
    });

    btnPdf.addEventListener('click', (e) => {
        e.preventDefault();
        const t = tipoReporte.value;
        if (!t) return;

        const params = buildParams();
        window.open(base + 'app/controllers/exportarReportePdf.php?' + params.toString(), '_blank');

        window.setTimeout(() => {
            const modalVisible = modalReportesGenerados && modalReportesGenerados.classList.contains('show');
            const historialYaCargado = reportesGeneradosWrap && reportesGeneradosWrap.dataset.loaded === '1';
            if (modalVisible || historialYaCargado) {
                cargarReportesGenerados();
            }
        }, 1200);
    });

    btnLimpiar.addEventListener('click', () => {
        setPreviewHtml('');
    });

    if (btnRecargarReportes) {
        btnRecargarReportes.addEventListener('click', cargarReportesGenerados);
    }

    if (modalReportesGenerados) {
        modalReportesGenerados.addEventListener('shown.bs.modal', cargarReportesGenerados);
    }

    aplicarPresetTipo();
    actualizarSecciones();
    cargarCombos().then(() => {
        // Opcional: previsualizar de una vez si ya hay seleccion.
        // previsualizar();
    });
});

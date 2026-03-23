// ============================
// ajax.js (parcheado)
// - limpiarDetalles() ya no revienta si falta algún campo
// - NO asume ".modal-body #id" etc (usa pick + setVal)
// - deja los selects en '' (más correcto que "Seleccionar")
// ============================

// Seleccionar todos los formularios con la clase "FormularioAjax"
const formularios_ajax = document.querySelectorAll(".FormularioAjax");

// Iterar sobre cada formulario
formularios_ajax.forEach(formulario => {
    formulario.addEventListener("submit", function (e) {
        e.preventDefault();

        Swal.fire({
            title: "¿Estás seguro?",
            text: "¡Quieres realizar la acción solicitada!",
            icon: "question",
            showCancelButton: true,
            confirmButtonColor: "#3085d6",
            cancelButtonColor: "#d33",
            confirmButtonText: "Sí, realizar",
            cancelButtonText: "No, cancelar",
        }).then((result) => {
            if (result.isConfirmed) {
                let data = new FormData(this);
                let method = this.getAttribute("method");
                let action = this.getAttribute("action");

                let encabezados = new Headers();
                let config = {
                    method: method,
                    headers: encabezados,
                    mode: 'cors',
                    cache: 'no-cache',
                    body: data
                };

                fetch(action, config)
                    .then(respuesta => respuesta.json())
                    .then(respuesta => alertas_ajax(respuesta));
            }
        });
    });
});

function alertas_ajax(alerta) {
    if (alerta.tipo == "simple") {
        Swal.fire({
            icon: alerta.icono,
            title: alerta.titulo,
            text: alerta.texto,
            confirmButtonText: 'Aceptar'
        });

    } else if (alerta.tipo == "recargar") {
        Swal.fire({
            icon: alerta.icono,
            title: alerta.titulo,
            text: alerta.texto,
            confirmButtonText: 'Aceptar'
        }).then((result) => {
            if (result.isConfirmed) location.reload();
        });

    } else if (alerta.tipo == "limpiar") {
        Swal.fire({
            icon: alerta.icono,
            title: alerta.titulo,
            text: alerta.texto,
            confirmButtonText: 'Aceptar'
        }).then((result) => {
            if (result.isConfirmed) {
                location.reload();
                // document.querySelector(".FormularioAjax").reset();
            }
        });

    } else if (alerta.tipo == "redireccionar") {
        window.location.href = alerta.url;

    } else if (alerta.tipo == "cerrar") {
        Swal.fire({
            title: alerta.titulo,
            text: alerta.texto,
            icon: alerta.icono,
            allowOutsideClick: false,
            confirmButtonColor: "#3085d6",
            confirmButtonText: "Cerrar Sesión",
        }).then((result) => {
            if (result.isConfirmed) {
                let url = dir + "logOut/";
                window.location.href = url;
            }
        });

    } else if (alerta.tipo == "detalle") {
        // ✅ ahora limpiarDetalles() es segura
        limpiarDetalles();

        // reiniciarTabla podría estar en otro archivo; llamamos solo si existe
        if (typeof reiniciarTabla === 'function') reiniciarTabla('');

        Swal.fire({
            icon: alerta.icono,
            title: alerta.titulo,
            text: alerta.texto,
            confirmButtonText: 'Aceptar'
        });
    }
}

// ============================
// Botón cerrar sesión (seguro si no existe en algunas páginas)
// ============================
let btn_exit = document.getElementById("btn_exit");
if (btn_exit) {
    btn_exit.addEventListener("click", function (e) {
        e.preventDefault();

        Swal.fire({
            title: "¿Deseas cerrar sesión?",
            text: "¡La sesión actual se cerrará y saldrás del sistema!",
            icon: "question",
            showCancelButton: true,
            confirmButtonColor: "#3085d6",
            cancelButtonColor: "#d33",
            confirmButtonText: "Sí, salir",
            cancelButtonText: "No, cancelar",
        }).then((result) => {
            if (result.isConfirmed) {
                let url = this.getAttribute("href");
                window.location.href = url;
            }
        });
    });
}

// ============================
// limpiarCadena (tu versión, sin cambios)
// ============================
function limpiarCadena(cadena) {
    const palabras = [
        '<script>',
        '</script>',
        '<script src',
        '<script type=',
        'SELECT * FROM',
        'SELECT ',
        ' SELECT ',
        'DELETE FROM',
        'INSERT INTO',
        'DROP TABLE',
        'DROP DATABASE',
        'TRUNCATE TABLE',
        'SHOW TABLES',
        'SHOW DATABASES',
        '<?php',
        '?>',
        '--',
        '^',
        '<',
        '>',
        '==',
        '=',
        ';',
        '::'
    ];

    cadena = (cadena || '').trim();
    cadena = cadena.replace(/\\+/g, '');

    const escapeForRegex = s => s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    for (const palabra of palabras) {
        const pattern = new RegExp(escapeForRegex(palabra), 'gi');
        cadena = cadena.replace(pattern, '');
    }

    const entityMap = {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#039;'
    };
    cadena = cadena.replace(/[&<>"']/g, function (m) { return entityMap[m]; });

    cadena = cadena.trim();
    cadena = cadena.replace(/\\+/g, '');

    return cadena;
}


// ============================
// ✅ limpiarDetalles (REEMPLAZO SEGURO)
// ============================
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

function limpiarDetalles() {
    const modal = document.getElementById('detallesOt');
    if (!modal) return;

    // OJO: ya no forzamos ".modal-body ..." porque a veces no coincide
    const inputT = pick(modal, '#detalle', '[name="modulo_ot"]');
    const inputId2 = pick(modal, '#id2', '[name="id2"]');
    const inputFecha = pick(modal, '#fecha', '[name="fecha"]');
    const inputDesc = pick(modal, '#desc', '[name="desc"]');
    const inputCant = pick(modal, '#cant', '[name="cant"]');

    const inputTurno = pick(modal, '#turno', '[name="turno"]');
    const inputStatus = pick(modal, '#status', '[name="status"]');
    const inputCco = pick(modal, '#cco', '[name="cco"]');
    const inputCcf = pick(modal, '#ccf', '[name="ccf"]');
    const inputTecnico = pick(modal, '#tec', '[name="tec"]');

    const inputHoraInicio = pick(modal, '#hora_inicio', '[name="hora_inicio"]');
    const inputHoraFin = pick(modal, '#hora_fin', '[name="hora_fin"]');
    const inputObserv = pick(modal, '#observacion', '[name="observacion"]');

    // reset seguro
    setVal(inputT, "registrar_detalle");
    setVal(inputId2, '');

    setVal(inputFecha, '');
    setVal(inputDesc, '');
    setVal(inputCant, '');

    // ✅ mejor '' para selects (si tienes <option value="">Seleccionar</option>)
    setVal(inputTurno, '');
    setVal(inputStatus, '');
    setVal(inputCco, '');
    setVal(inputCcf, '');
    setVal(inputTecnico, '');

    setVal(inputHoraInicio, '');
    setVal(inputHoraFin, '');
    setVal(inputObserv, '');

    const modo = document.getElementById('modoEdicionLabel');
    if (modo) modo.textContent = 'Nuevo';
}

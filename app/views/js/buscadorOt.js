// Esperar a que el DOM este completamente cargado
document.addEventListener('DOMContentLoaded', function () {
    // Obtener el modal de modificacion por su ID
    let tipoBusqueda = '';
    let dir = document.getElementById('url').value;
    let btnBuscarOt = document.getElementById('btnBuscarOt');
    let btnBuscarFecha = document.getElementById('btnBuscarFecha');
    let btnBuscarEstado = document.getElementById('btnBuscarEstado');
    let btnBuscarUser = document.getElementById('btnBuscarUser');
    let btnRecargarOT = document.getElementById('btnRecargarOT');

    // Agregar un listener para el evento "shown.bs.modal", que se dispara cuando el modal se muestra al usuario
    btnBuscarOt.addEventListener('click', function (event) {
        tipoBusqueda = 'ot';
        let area = limpiarCadena(document.getElementById('area').value);
        let nrot = limpiarCadena(document.getElementById('nrot').value);
        if (area === "Seleccionar") {
            mostrarAlerta('warning', 'Ups!', 'No has seleccionado el area');
        } else {
            if (nrot === "") {
                reiniciarTablaOT(dir);
                var alerta = {
                    tipo: "simple",
                    icono: "warning",
                    titulo: "Ups!",
                    texto: "Ingresa un numero de orden de trabajo."
                };
                alertas_ajax(alerta);
                return;
            } else {
                if (verificarDatos('^[0-9]{1,10}$', nrot)) {
                    var alerta = {
                        tipo: "simple",
                        icono: "warning",
                        titulo: "Ups!",
                        texto: "El codigo no cumple con el formato solicitado."
                    };
                    alertas_ajax(alerta);
                    return; // Detener la ejecucion del codigo aqui
                }
                let codigo = area + nrot;
                $.ajax({
                    url: dir + 'app/controllers/cargarDatosBuscadorOt.php',
                    method: 'GET',
                    dataType: 'json',
                    data: { id: codigo, tipoBusqueda: tipoBusqueda },
                    success: function (data) {
                        if (data.length > 0) {
                            let tabla = document.getElementById('tablaDatosOt').getElementsByTagName('tbody')[0];
                            tabla.innerHTML = ''; // Limpiar el cuerpo de la tabla antes de insertar nuevos datos
                            let contador = 1;
                            data.forEach(function (orden) {
                                let fila = tabla.insertRow();
                                fila.classList.add('align-middle'); // Agregar clase para centrar verticalmente la fila
                                // Celdas de la fila con el mismo estilo que en tu HTML
                                fila.innerHTML = tablaOt(dir, contador, orden);
                                contador++;
                            });
                        } else {
                            reiniciarTablaOT(dir);
                            var alerta = {
                                tipo: "simple",
                                icono: "info",
                                titulo: "Ups!",
                                texto: 'No existen registros con el codigo: ' + codigo
                            };
                            alertas_ajax(alerta);
                            return;
                        }
                    },
                    error: function (xhr, status, error) {
                        console.error('Error al obtener la orden de trabajo:', error);
                    }
                });
            }
        }
    });

    btnBuscarFecha.addEventListener('click', function (event) {
        tipoBusqueda = 'fecha';
        let area = limpiarCadena(document.getElementById('area').value);
        let fechaDesde = limpiarCadena(document.getElementById('fecha_desde').value);
        let fechaHasta = limpiarCadena(document.getElementById('fecha_hasta').value);

        if (fechaDesde === "" || fechaHasta === "") {
            reiniciarTablaOT(dir);
            var alerta = {
                tipo: "simple",
                icono: "info",
                titulo: "Ups!",
                texto: 'Seleccione el rango de fecha a consultar'
            };
            alertas_ajax(alerta);
            return;
        } else {
            $.ajax({
                url: dir + 'app/controllers/cargarDatosBuscadorOt.php',
                method: 'GET',
                dataType: 'json',
                data: { fechaI: fechaDesde, fechaF: fechaHasta, area: area, tipoBusqueda: tipoBusqueda },
                success: function (data) {
                    if (data.length > 0) {
                        let tabla = document.getElementById('tablaDatosOt').getElementsByTagName('tbody')[0];
                        tabla.innerHTML = ''; // Limpiar el cuerpo de la tabla antes de insertar nuevos datos
                        let contador = 1;
                        data.forEach(function (orden) {
                            let fila = tabla.insertRow();
                            fila.classList.add('align-middle'); // Agregar clase para centrar verticalmente la fila
                            // Celdas de la fila con el mismo estilo que en tu HTML
                            fila.innerHTML = tablaOt(dir, contador, orden);
                            contador++;
                        });
                    } else {
                        reiniciarTablaOT(dir);
                        var alerta = {
                            tipo: "simple",
                            icono: "info",
                            titulo: "Ups!",
                            texto: 'No existen registros en este rango de fecha'
                        };
                        alertas_ajax(alerta);
                        return;
                    }
                },
                error: function (xhr, status, error) {
                    console.error('Error al obtener la orden de trabajo:', error);
                }
            });
        }
    });
    btnBuscarEstado.addEventListener('click', function (event) {
        tipoBusqueda = 'estado';
        let area = limpiarCadena(document.getElementById('area').value);
        let estado = limpiarCadena(document.getElementById('status').value);

        if (estado === "Seleccionar") {
            reiniciarTablaOT(dir);
            var alerta = {
                tipo: "simple",
                icono: "info",
                titulo: "Ups!",
                texto: 'Selecciona el estado.'
            };
            alertas_ajax(alerta);
            return;
        } else {
            $.ajax({
                url: dir + 'app/controllers/cargarDatosBuscadorOt.php',
                method: 'GET',
                dataType: 'json',
                data: { estado: estado, area: area, tipoBusqueda: tipoBusqueda },
                success: function (data) {
                    if (data.length > 0) {
                        let tabla = document.getElementById('tablaDatosOt').getElementsByTagName('tbody')[0];
                        tabla.innerHTML = ''; // Limpiar el cuerpo de la tabla antes de insertar nuevos datos
                        let contador = 1;
                        data.forEach(function (orden) {
                            let fila = tabla.insertRow();
                            fila.classList.add('align-middle'); // Agregar clase para centrar verticalmente la fila
                            // Celdas de la fila con el mismo estilo que en tu HTML
                            fila.innerHTML = tablaOt(dir, contador, orden);
                            contador++;
                        });
                    } else {
                        reiniciarTablaOT(dir);
                        var alerta = {
                            tipo: "simple",
                            icono: "info",
                            titulo: "Ups!",
                            texto: 'No existen registros'
                        };
                        alertas_ajax(alerta);
                        return;
                    }
                },
                error: function (xhr, status, error) {
                    console.error('Error al obtener la orden de trabajo:', error);
                }
            });
        }

    });
    btnBuscarUser.addEventListener('click', function (event) {
        tipoBusqueda = 'user';
        let area = limpiarCadena(document.getElementById('area').value);
        let user = limpiarCadena(document.getElementById('user').value);

        if (user === "Seleccionar") {
            reiniciarTablaOT(dir);
            var alerta = {
                tipo: "simple",
                icono: "info",
                titulo: "Ups!",
                texto: 'Selecciona el Usuario.'
            };
            alertas_ajax(alerta);
            return;
        } else {
            $.ajax({
                url: dir + 'app/controllers/cargarDatosBuscadorOt.php',
                method: 'GET',
                dataType: 'json',
                data: { user: user, area: area, tipoBusqueda: tipoBusqueda },
                success: function (data) {
                    if (data.length > 0) {
                        let tabla = document.getElementById('tablaDatosOt').getElementsByTagName('tbody')[0];
                        tabla.innerHTML = ''; // Limpiar el cuerpo de la tabla antes de insertar nuevos datos
                        let contador = 1;
                        data.forEach(function (orden) {
                            let fila = tabla.insertRow();
                            fila.classList.add('align-middle'); // Agregar clase para centrar verticalmente la fila
                            // Celdas de la fila con el mismo estilo que en tu HTML
                            fila.innerHTML = tablaOt(dir, contador, orden);
                            contador++;
                        });
                    } else {
                        reiniciarTablaOT(dir);
                        var alerta = {
                            tipo: "simple",
                            icono: "info",
                            titulo: "Ups!",
                            texto: 'No existen registros'
                        };
                        alertas_ajax(alerta);
                        return;
                    }
                },
                error: function (xhr, status, error) {
                    console.error('Error al obtener la orden de trabajo:', error);
                }
            });
        }
    });

 
});



function reiniciarTablaOT(dir) {
    let tipoBusqueda = 'todo';
    $.ajax({
        url: dir + 'app/controllers/cargarDatosBuscadorOt.php',
        method: 'GET',
        dataType: 'json',
        cache: false,
        data: { tipoBusqueda: tipoBusqueda, _ts: Date.now() },
        success: function (data) {
            let tabla = document.getElementById('tablaDatosOt').getElementsByTagName('tbody')[0];
            tabla.innerHTML = '';

            if (Array.isArray(data) && data.length > 0) {
                let contador = 1;
                data.forEach(function (orden) {
                    let fila = tabla.insertRow();
                    fila.classList.add('align-middle');
                    fila.innerHTML = tablaOt(dir, contador, orden);
                    contador++;
                });
            } else {
                tabla.innerHTML = tablaOtVacia();
            }
        },
        error: function (xhr, status, error) {
            console.error('Error al obtener la orden de trabajo:', error);
        }
    });
}

function tablaOtVacia() {
    tabla = `
        <tr class="align-middle">
            <td class="text-center" colspan="11">
                No hay registros en el sistema
            </td>
        </tr>                    
    `;
    return tabla;
}
function permisoOt(id) {
    return document.getElementById(id)?.value === '1';
}

function escapeHtmlOt(value) {
    return String(value ?? '')
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#039;');
}

function renderOtAccionHtml(dir, orden) {
    const nOt = orden.n_ot;
    const finalizada = Number(orden.ot_finalizada || 0) === 1;
    const estadoId = Number(orden.id_ai_estado || 0);
    const estadoNombre = String(orden.nombre_estado || '').trim();
    const acciones = {
        detalle: `
            <a href="#" title="${finalizada ? 'Ver detalles' : 'Detalles Orden'}" id="detalleot" class="btn btn-info text-white" data-bs-toggle="modal" data-bs-target="#detallesOt" data-bs-id="${nOt}">
                <i class="bi bi-card-list"></i>
            </a>
        `,
        reporte: permisoOt('perm_ot_generar_reporte') ? `
            <button type="button" title="Generar reporte" class="btn btn-primary js-preview-ot-report" data-bs-toggle="modal" data-bs-target="#modalPreviewReporteOt" data-bs-ot="${nOt}">
                <i class="bi bi-file-earmark-pdf"></i>
            </button>
        ` : '',
        herramientas: (permisoOt('perm_herr_view') || permisoOt('perm_ot_edit')) ? (
            finalizada
                ? `
            <button type="button" title="OT finalizada" class="btn btn-secondary" disabled>
                <i class="bi bi-tools"></i>
            </button>
        `
                : `
            <a href="#" title="Agregar Herramienta" class="btn btn-success js-open-herr-ot" data-bs-toggle="modal" data-bs-target="#ModificarHerrOt" data-bs-id="${nOt}">
                <i class="bi bi-tools"></i>
            </a>
        `
        ) : '',
        estado: (permisoOt('perm_ot_edit') || permisoOt('perm_ot_add_detalle')) ? (
            finalizada
                ? `
            <button type="button" title="Estado bloqueado" class="btn btn-secondary" disabled>
                <i class="bi bi-lock"></i>
            </button>
        `
                : `
            <button type="button" title="Cambiar estado O.T." class="btn btn-outline-primary js-cambiar-estado-ot"
                data-ot="${nOt}"
                data-estado-id="${estadoId}"
                data-estado-nombre="${escapeHtmlOt(estadoNombre)}">
                <i class="bi bi-arrow-repeat"></i>
            </button>
        `
        ) : '',
        editar: permisoOt('perm_ot_edit') ? (
            finalizada
                ? `
            <button type="button" title="O.T. finalizada" class="btn btn-secondary" disabled>
                <i class="bi bi-pencil"></i>
            </button>
        `
                : `
            <a href="#" title="Modificar O.T." class="btn btn-warning text-dark" data-bs-toggle="modal" data-bs-target="#ventanaModalModificarOt" data-bs-id="${nOt}">
                <i class="bi bi-pencil text-white"></i>
            </a>
        `
        ) : '',
        eliminar: permisoOt('perm_ot_delete') ? `
            <form class="FormularioAjaxJs" action="${dir}app/ajax/otAjax.php" method="POST">
                <input type="hidden" name="modulo_ot" value="eliminar">
                <input type="hidden" name="miembro_id" value="${nOt}">
                <button type="submit" class="btn btn-danger" title="Eliminar">
                    <i class="bi bi-trash"></i>
                </button> 
            </form>
        ` : ''
    };

    return acciones;
}

function estadoOtVisual(orden) {
    const finalizada = Number(orden.ot_finalizada || 0) === 1;
    const raw = String(orden.nombre_estado || '').trim();
    const color = String(orden.color || '').trim() || '#6B7280';

    return {
        label: raw !== '' ? raw.toUpperCase() : (finalizada ? 'FINALIZADA' : 'SIN ESTADO'),
        color
    };
}

function renderEstadoOtIndicator(orden) {
    const visual = estadoOtVisual(orden);
    return `
        <span class="ot-status-indicator" style="--ot-status-color:${escapeHtmlOt(visual.color)};">
            <span class="ot-status-dot"></span>
            <span>${escapeHtmlOt(visual.label)}</span>
        </span>
    `;
}

function tablaOt(dir, contador, orden) {
    let self = this;
    const acciones = renderOtAccionHtml(dir, orden);
    const n_ot = orden.n_ot;
    const nombre_trab = orden.nombre_trab;
    const fecha = orden.fecha;
    const estadoOt = renderEstadoOtIndicator(orden);
    tabla = `
            <td class="clearfix col-auto">
                            <div class=""><b>${contador}</b></div>
                        </td>                        
                        <td class="col-p6">
                            <div class="clearfix">
                                <div class=""><b>${self.formatearFecha(fecha)}</b></div>
                            </div>
                        </td>                            
                        <td class="col-p6">
                            <div class="clearfix">
                                <div class=""><b>${n_ot}</b></div>
                            </div>
                        </td>
                        <td class="">
                            <div class="clearfix">
                                <div class=""><b>${nombre_trab}</b></div>
                            </div>
                        </td>
                        <td class="col-p6">
                            <div class="clearfix">${estadoOt}</div>
                        </td>
                        <td class="col-p">${acciones.detalle}</td>
                        <td class="col-p">${acciones.reporte}</td>
                        <td class="col-p">${acciones.herramientas}</td>
                        <td class="col-p">${acciones.estado}</td>
                        <td class="col-p">${acciones.editar}</td>
                        <td class="col-p">${acciones.eliminar}</td>
    `;
    return tabla;
}
function formatearFecha(fecha) {
    var partes = fecha.split('-');
    var dia = partes[2];
    var mes = partes[1];
    var ano = partes[0];
    return dia + '/' + mes + '/' + ano;
}
function estado(estado) {
    if (!estado || estado.trim() === '') {
        return 'SIN DETALLE';
    } else {
        return estado;
    }
}

function verificarDatos(filtro, cadena) {
    let regex = new RegExp('^' + filtro + '$');
    if (regex.test(cadena)) {
        return false;
    } else {
        return true;
    }
}

function alerta(icono, texto, segundo) {
    let Toast = Swal.mixin({
        toast: true,
        position: "bottom-end",
        showConfirmButton: false,
        timer: segundo,
        timerProgressBar: true,
        didOpen: (toast) => {
            toast.onmouseenter = Swal.stopTimer;
            toast.onmouseleave = Swal.resumeTimer;
        }
    });
    Toast.fire({
        icon: icono,
        title: texto,
    });
}
function mostrarAlerta(icono, titulo, texto) {
    Swal.fire({
        icon: icono,
        title: titulo,
        text: texto,
        confirmButtonText: 'Aceptar'
    });
}
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
        '\\<\\?php',
        '\\?\\>',
        '--',
        '^',
        '<', '>', '==', '=', ';', '::'
    ];


    // Eliminar espacios en blanco al inicio y al final de la cadena
    cadena = cadena.trim();

    // Eliminar barras invertidas (\)
    cadena = cadena.replace(/\\/g, '');

    // Iterar sobre cada palabra prohibida y eliminarla de la cadena
    palabras.forEach(function (palabra) {
        cadena = cadena.replace(new RegExp(palabra, 'gi'), '');
    });

    // Escapar caracteres HTML
    cadena = cadena.replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");

    // Eliminar espacios en blanco adicionales
    cadena = cadena.trim();

    // Eliminar barras invertidas (\)
    cadena = cadena.replace(/\\/g, '');

    return cadena;
}


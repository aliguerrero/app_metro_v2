document.addEventListener('DOMContentLoaded', function () {
    const modificarModalHerr = document.getElementById('ventanaModalModificarHerr');
    const dir = document.getElementById('url')?.value || '';

    if (!modificarModalHerr || !dir) return;

    modificarModalHerr.addEventListener('show.bs.modal', function (event) {
        const button = event.relatedTarget;
        const id = button?.getAttribute('data-bs-id');
        if (!id) return;

        const inputId = modificarModalHerr.querySelector('.modal-body #id');
        const inputNombre = modificarModalHerr.querySelector('.modal-body #nombre');
        const inputCategoria = modificarModalHerr.querySelector('.modal-body #id_ai_categoria_herramienta_edit');
        const inputCant = modificarModalHerr.querySelector('.modal-body #cant');
        const inputEstado = modificarModalHerr.querySelector('.modal-body #estado');

        const url = dir + 'app/controllers/cargarDatosHerramienta.php';
        const formData = new FormData();
        formData.append('id', id);

        fetch(url, {
            method: 'POST',
            body: formData
        })
            .then(response => {
                if (!response.ok) {
                    throw new Error('Error al cargar los datos de la herramienta');
                }
                return response.json();
            })
            .then(data => {
                inputId.value = data.id_ai_herramienta || '';
                inputNombre.value = data.nombre_herramienta || '';
                if (inputCategoria) {
                    inputCategoria.value = data.id_ai_categoria_herramienta || '';
                }
                inputCant.value = data.cantidad || '';
                inputEstado.value = data.estado || 'Seleccionar';
            })
            .catch(error => {
                console.error('Error:', error);
                alert('Ocurrio un error al cargar los datos de la herramienta. Por favor, intentalo de nuevo mas tarde.');
            });
    });
});

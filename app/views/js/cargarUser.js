document.addEventListener('DOMContentLoaded', function () {
    const modificarModalUser = document.getElementById('ventanaModalModificar');
    const modificarModalPassUser = document.getElementById('ventanaModalModificarPass');
    const dir = document.getElementById('url')?.value || '';

    async function obtenerUsuario(id) {
        const url = dir + 'app/controllers/cargarDatosUser.php';
        const formData = new FormData();
        formData.append('id', id);

        const response = await fetch(url, {
            method: 'POST',
            body: formData
        });

        if (!response.ok) {
            throw new Error('Error al cargar los datos del usuario');
        }

        return response.json();
    }

    if (modificarModalUser) {
        modificarModalUser.addEventListener('show.bs.modal', async function (event) {
            const button = event.relatedTarget;
            const id = button ? button.getAttribute('data-bs-id') : null;
            if (!id) return;

            try {
                const data = await obtenerUsuario(id);

                modificarModalUser.querySelector('.modal-body #id').value = data.id_user || '';
                modificarModalUser.querySelector('.modal-body #id_empleado').value = data.id_user || '';
                modificarModalUser.querySelector('.modal-body #username').value = data.username || '';
                modificarModalUser.querySelector('.modal-body #tipo2').value = data.tipo || '';
            } catch (error) {
                console.error('Error:', error);
                alert('Ocurrio un error al cargar los datos del usuario. Por favor, intentalo de nuevo mas tarde.');
            }
        });
    }

    if (modificarModalPassUser) {
        modificarModalPassUser.addEventListener('show.bs.modal', async function (event) {
            const button = event.relatedTarget;
            const id = button ? button.getAttribute('data-bs-id') : null;
            if (!id) return;

            try {
                const data = await obtenerUsuario(id);
                modificarModalPassUser.querySelector('.modal-body #id2').value = data.id_user || '';

                const nombre = data.nombre_empleado || data.id_user || '';
                const username = data.username ? ` (@${data.username})` : '';
                modificarModalPassUser.querySelector('.modal-body #nombreUser').textContent = `${nombre}${username}`;
            } catch (error) {
                console.error('Error:', error);
                alert('Ocurrio un error al cargar los datos del usuario. Por favor, intentalo de nuevo mas tarde.');
            }
        });
    }
});

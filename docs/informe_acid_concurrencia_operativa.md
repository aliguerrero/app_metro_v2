# Informe ACID y Concurrencia Operativa

## Diagnostico actual

Antes del endurecimiento, el sistema ya tenia una base tecnica importante:

- motor `InnoDB`
- claves foraneas, `UNIQUE` y `CHECK`
- auditoria por triggers
- `READ COMMITTED` en la conexion PHP
- procedimientos almacenados para crear O.T., agregar detalle, asignar herramientas y cambiar estado

Sin embargo, el cumplimiento no era completo en toda la capa de aplicacion. Persistian rutas de escritura directa sobre tablas criticas:

- edicion de `orden_trabajo`
- eliminacion logica de `orden_trabajo`
- actualizacion y eliminacion de `detalle_orden`
- ajuste manual de `herramientaot` por `DELETE/INSERT`
- endpoints legacy de botones `+/-` que podian modificar herramientas sin pasar por una regla comun de bloqueo por estado

## Por que no se usa una sola transaccion larga

El proceso real de una orden de trabajo es por etapas y puede intervenir mas de un usuario:

1. Un usuario crea la O.T.
2. Otro usuario recibe o ejecuta la O.T.
3. Se asignan herramientas.
4. Se ejecuta el trabajo.
5. Se registra el detalle.
6. Se cambia a estado bloqueante o final.

Mantener una sola transaccion desde el paso 1 hasta el paso 6 seria incorrecto y costoso:

- mantendria filas bloqueadas durante demasiado tiempo
- aumentaria la probabilidad de esperas y conflictos
- afectaria la experiencia de uso diario
- generaria mas riesgo de cuellos de botella que beneficios reales

Por eso se adopto el modelo correcto para este sistema: transacciones cortas por operacion critica.

## Cambios implementados

### 1. O.T.

Se agregaron procedimientos para centralizar las escrituras criticas del encabezado:

- `sp_ot_actualizar`
- `sp_ot_eliminar_logico`

Estos procedimientos:

- validan que la O.T. exista y siga activa
- bloquean la fila de `orden_trabajo` con `SELECT ... FOR UPDATE`
- impiden modificar una O.T. bloqueada o finalizada
- conservan la eliminacion logica en lugar de borrado fisico
- registran auditoria con `@app_user`

### 2. Detalles de O.T.

Se completaron las operaciones seguras sobre detalle con:

- `sp_ot_actualizar_detalle`
- `sp_ot_eliminar_detalle`

Cada operacion:

- bloquea primero la O.T.
- verifica si la O.T. ya esta bloqueada
- bloquea el detalle objetivo
- valida que el detalle pertenezca a la O.T. recibida
- ejecuta `COMMIT` o `ROLLBACK` segun corresponda

Con esto se evita que un usuario cambie o elimine detalles mientras otro ya esta cerrando la orden.

### 3. Herramientas e inventario

Se agregaron dos procedimientos nuevos y se reencamino el procedimiento existente:

- `sp_ot_ajustar_herramienta_delta`
- `sp_ot_set_herramienta_cantidad`
- `sp_ot_asignar_herramienta` ahora delega la operacion incremental al flujo seguro

La logica aplicada fue:

- bloqueo de la O.T. afectada
- bloqueo de la herramienta afectada
- validacion de disponibilidad real
- normalizacion a una sola asignacion activa por `OT + herramienta`
- soporte seguro para botones `+/-` y para actualizacion de cantidad final

Esto evita sobreasignacion de stock y elimina el riesgo que existia cuando algunos endpoints hacian `DELETE` seguido de `INSERT` por fuera de un procedimiento comun.

### 4. Indice de concurrencia

Se agrego el indice:

- `idx_herramientaot_herr_estado_ot (id_ai_herramienta, estado_herramientaot, n_ot)`

Su objetivo es reducir el costo de busqueda y el rango de trabajo sobre `herramientaot` durante los ajustes concurrentes de inventario.

### 5. Cuenta operativa de la app

La aplicacion dejo de apuntar a `u_admin` como cuenta runtime y ahora usa `u_app`.

La razon es separar:

- cuenta operativa diaria: `u_app`
- cuenta administrativa y de respaldo: `u_backup_restore`

Con eso se reduce el riesgo de ejecutar el sistema completo con privilegios administrativos innecesarios.

## Relacion con ACID

### Atomicidad

Cada operacion critica se ejecuta como una unidad:

- actualizar O.T.
- eliminar logicamente O.T.
- agregar, actualizar o eliminar detalle
- sumar, restar o fijar cantidad de herramienta
- cambiar estado de O.T.

Si una validacion falla, se ejecuta `ROLLBACK` y no queda un cambio parcial.

### Consistencia

La consistencia se protege con:

- validacion de existencia y actividad de catalogos
- validacion del estado de la O.T.
- restricciones fisicas de la base de datos
- normalizacion de herramientas activas por `OT + herramienta`
- liberacion controlada de herramientas cuando el estado lo exige

### Aislamiento

El aislamiento se implementa con:

- `READ COMMITTED`
- `SELECT ... FOR UPDATE` solo sobre filas criticas
- serializacion por herramienta en ajustes de stock

Esto evita lectura sucia y reduce el riesgo de actualizacion perdida sin degradar el uso normal de la app.

### Durabilidad

Una vez hecho `COMMIT`, los cambios quedan persistidos en InnoDB y ademas quedan registrados por auditoria en `log_user`.

## Impacto en rendimiento

Los cambios se disenaron para no crear cuello de botella:

- no se usa `SERIALIZABLE`
- no se abren transacciones largas de extremo a extremo
- no se bloquean tablas completas
- los bloqueos son por fila y por operacion puntual
- el nuevo indice reduce el trabajo sobre `herramientaot`

En consecuencia, el sistema gana consistencia y trazabilidad sin castigar el flujo operativo diario.



# Proyecto Metro Valencia (FerreNet System)
Este directorio concentra la organizacion documental y tecnica de los scripts de base de datos del sistema, siguiendo una estructura modular orientada a facilitar la ubicacion, revision y mantenimiento de los objetos SQL del proyecto.

## Objetivo de esta estructura
Fue organizada para separar de forma clara:

- el script general de base de datos;
- los scripts de reportes;
- los scripts DDL de cada base de datos;
- y los scripts DML de cada base de datos.

Esta distribucion permite identificar con rapidez el rol de cada archivo dentro de la arquitectura de datos del sistema y documentar por separado la estructura y la manipulacion de la informacion.

## Organizacion general del directorio

### `BD_general`
Contiene el script general consolidado del proyecto.

En esta seccion se encuentra el archivo maestro que integra:

- la creacion de la base de datos operativa;
- la creacion de la base de datos de auditoria;
- la creacion de la base de datos de vistas;
- la definicion estructural de tablas, vistas, procedimientos, eventos y relaciones;
- y la carga base de los datos iniciales del sistema.
- incluyendo la creacion de los usuarios gestores de base de datos y sus roles.

### `Reportes`
Contiene los scripts SQL vinculados a la generacion de reportes y consultas de apoyo utilizadas por el sistema.

Aqui se agrupan sentencias relacionadas con:

- reportes operativos;
- consultas de filtros;
- consultas de detalle;
- y consultas auxiliares para emision o visualizacion de informacion.

La organizacion de esta carpeta responde a una estructura funcional, centrada en las necesidades del modulo de reportes.

### `Scripts_ddl`
Contiene los scripts de definicion estructural de las bases de datos.

Su contenido esta separado por esquema:

- `bd_operativa_ddl`
- `bd_auditoria_ddl`
- `bd_vistas_ddl`

En estas carpetas se documentan los objetos DDL del sistema, incluyendo:

- tablas;
- claves primarias y foraneas;
- indices;
- disparadores;
- vistas;
- procedimientos almacenados;
- y eventos, cuando corresponda.

Cada archivo fue organizado por tabla u objeto funcional, con encabezado descriptivo y comentarios por bloque SQL para facilitar su lectura tecnica.

### `Scripts_dml`
Contiene los scripts de manipulacion de datos del sistema.

Su contenido tambien esta separado por esquema:

- `bd_operativa_dml`
- `bd_auditoria_dml`
- `bd_vistas_dml`

En estas carpetas se agrupan los scripts relacionados con:

- inserciones iniciales o maestros;
- consultas utilizadas por los modulos del sistema;
- actualizaciones y eliminaciones logicas;
- operaciones de carga y mantenimiento de datos;
- y consultas funcionales asociadas a vistas o procesos de auditoria.

Cada archivo fue organizado por tabla o por objeto funcional equivalente, de manera que el DML pueda consultarse por entidad.

## Bases de datos contempladas
La estructura documenta las tres bases de datos que forman parte del proyecto:

### Base de datos operativa
Almacena la informacion principal del sistema y soporta la ejecucion diaria de los modulos funcionales.

### Base de datos de auditoria
Resguarda la informacion historica de eventos, sincronizaciones y trazas de respaldo.

### Base de datos de vistas
Centraliza vistas especializadas para consulta, revision y seguimiento de informacion consolidada.
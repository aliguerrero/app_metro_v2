# Proyecto Metro Valencia (FerreNet System)

Este repositorio está organizado de forma **modular y estructurada**, con el objetivo de separar claramente los componentes principales del sistema. 

## Organización general del repositorio

El proyecto reúne los recursos necesarios para la gestión de la base de datos del sistema, incluyendo:

- la **base de datos principal u operativa**;
- la **base de datos de auditoría**;
- la **base de datos de revisión**;
- y los **scripts de apoyo** correspondientes a los módulos del sistema.

Cada sección del repositorio está distribuida de manera que los objetos de base de datos y los scripts funcionales puedan localizarse fácilmente.

## Estructura principal

### `Bd`
Esta carpeta contiene la **base de datos completa del sistema**, incluyendo:

- creación de usuarios gestores;
- creación de roles;
- configuración de permisos;
- y definición de las **tres bases de datos** que trabajan en conjunto.

En esta sección se centraliza el script principal de importación y configuración de la arquitectura de base de datos del proyecto.

### `Scripts`
Esta carpeta contiene los **scripts organizados por funcionalidad**, permitiendo una separación más clara de los componentes técnicos del sistema.

Aquí se incluyen:

- scripts **CRUD** de los módulos del sistema;
- separación de las bases de datos por esquema;
- scripts de **procedimientos almacenados**;
- scripts de **vistas**;
- scripts de **triggers**;
- y scripts de **eventos**, cuando la base de datos correspondiente los posee.

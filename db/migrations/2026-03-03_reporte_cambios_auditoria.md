# Reporte de cambios - Auditoria y usuario DB admin alterno

Fecha de ejecucion: 2026-03-03
Proyecto: `app_metro`
Motor DB: MariaDB 10.4.32 (XAMPP)

## 1) Diagnostico realizado

Se validaron las bases y objetos de auditoria en MySQL:

- Bases detectadas:
  - `bdapp_metro`
  - `bdapp_metro_audit`
  - `bdapp_metro_review`
- Tablas `log_user` encontradas inicialmente:
  - `bdapp_metro.log_user`
  - `bdapp_metro_audit.log_user`
  - `bdapp_metro_audit.log_user_backup`

Hallazgo: existia una tercera copia redundante (`log_user_backup`) en `bdapp_metro_audit`.

## 2) Causa de la triple replica

En `bdapp_metro_audit` estaban definidos:

- `sp_sync_log_user`: copia de `bdapp_metro.log_user` hacia `bdapp_metro_audit.log_user`.
- `sp_backup_log_user`: copia de `bdapp_metro_audit.log_user` hacia `bdapp_metro_audit.log_user_backup`.
- `sp_minute_tasks`: llamaba ambos procedimientos.
- Evento `ev_minute_backup` (cada minuto): ejecuta `sp_minute_tasks`.

Esto generaba 3 capas de datos para el mismo log.

## 3) Cambios aplicados

Script aplicado:

- `db/migrations/2026-03-03_audit_cleanup_and_usr_admin_upt.sql`

Cambios:

1. Consolidacion previa de datos:
   - Se hizo `INSERT IGNORE` de `log_user_backup` hacia `log_user` en `bdapp_metro_audit` para no perder filas unicas.
2. Simplificacion de rutina por minuto:
   - Se recreo `bdapp_metro_audit.sp_minute_tasks` para:
     - solo ejecutar `sp_sync_log_user`
     - registrar corrida en `backup_runs` con `backed_rows = 0`
3. Eliminacion de tercera copia:
   - `DROP PROCEDURE IF EXISTS bdapp_metro_audit.sp_backup_log_user`
   - `DROP TABLE IF EXISTS bdapp_metro_audit.log_user_backup`
4. Alta de nuevo usuario DB:
   - Se creo `usr_admin_upt@'%'`
   - Se le asigno el mismo hash de clave de `u_admin@'%'`
   - Se aplicaron los mismos grants explicitos y rol por defecto `rol_admin`

## 4) Validaciones posteriores

Estado final de tablas `log_user`:

- `bdapp_metro.log_user`
- `bdapp_metro_audit.log_user`

No existe:

- `bdapp_metro_audit.log_user_backup`

Estado de procedimientos en `bdapp_metro_audit`:

- `sp_sync_log_user` (activo)
- `sp_minute_tasks` (actualizado)
- `sp_backup_log_user` (eliminado)

Usuario nuevo:

- Existe `usr_admin_upt@'%'`
- Tiene grants equivalentes a `u_admin@'%'` y mismo hash de autenticacion.

## 5) Observacion operativa

En este entorno, la variable `event_scheduler` estaba en `OFF` durante la revision.  
Si se requiere sincronizacion automatica por evento, debe activarse en el servidor MariaDB.


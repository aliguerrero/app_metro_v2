-- Modulo: Scripts_dml
-- Archivo: configuracion_correo_smtp.sql
-- Funcion: reune las consultas y escrituras de datos asociadas a la configuracion SMTP.
-- Version: v_1.0

-- -----------------------------------------------------------------------------
-- Bloque 1. Carga maestra inicial
-- inserta los datos maestros base definidos para este objeto en el respaldo general del sistema.
-- -----------------------------------------------------------------------------
START TRANSACTION;
INSERT INTO `smtp_config` (`id`, `enabled`, `provider`, `host`, `port`, `encryption`, `username`, `password`, `from_email`, `from_name`, `created_at`, `updated_at`) VALUES
(1, 1, 'google', 'smtp.gmail.com', 587, 'tls', 'aliguerrerodev@gmail.com', 'gcm:0PcNOJmDgi8C/lqWWxyLBiHV63Y/fqJMXC2PgqRyBxMHjmhUVB3Ma+r/GU4=', 'aliguerrerodev@gmail.com', 'FerreNet System', '2026-03-16 14:17:18', '2026-03-16 14:46:38');
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 2. Bloque de modulo: configuracion_smtp / asegurar_registro_base
-- verifica la existencia del registro unico de configuracion SMTP y prepara su alta inicial cuando hace falta.
-- -----------------------------------------------------------------------------
SELECT `id` FROM `smtp_config` WHERE `id` = :id LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 3. Bloque de modulo: configuracion_smtp / crear_registro_base
-- inserta el registro maestro inicial de configuracion SMTP cuando aun no existe.
-- -----------------------------------------------------------------------------
START TRANSACTION;
INSERT INTO `smtp_config` (`id`, `enabled`, `provider`, `host`, `port`, `encryption`, `username`, `password`, `from_email`, `from_name`) VALUES (:id, :enabled, :provider, :host, :port, :encryption, :username, :password, :from_email, :from_name);
COMMIT;

-- -----------------------------------------------------------------------------
-- Bloque 4. Bloque de modulo: configuracion_smtp / consultar_configuracion
-- recupera la configuracion SMTP persistida para mostrarla en pantalla o usarla en pantalla.
-- -----------------------------------------------------------------------------
SELECT `id`, `enabled`, `provider`, `host`, `port`, `encryption`, `username`, `password`, `from_email`, `from_name`, `created_at`, `updated_at`
FROM smtp_config WHERE id = :id LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 5. Bloque de modulo: configuracion_smtp / consultar_credenciales_activas
-- recupera los campos operativos minimos necesarios para ejecutar un envio de correo configurado.
-- -----------------------------------------------------------------------------
SELECT `enabled`, `host`, `port`, `encryption`, `username`, `password`, `from_email`, `from_name` FROM `smtp_config` WHERE `id` = :id LIMIT 1;

-- -----------------------------------------------------------------------------
-- Bloque 6. Bloque de modulo: configuracion_smtp / actualizar_configuracion
-- actualiza la configuracion persistida del servicio SMTP conservando la misma fila maestra.
-- -----------------------------------------------------------------------------
START TRANSACTION;
UPDATE `smtp_config` SET `enabled` = :enabled, `provider` = :provider, `host` = :host, `port` = :port, `encryption` = :encryption, `username` = :username, `from_email` = :from_email, `from_name` = :from_name, `password` = COALESCE(:password, `password`) WHERE `id` = :id;
COMMIT;

